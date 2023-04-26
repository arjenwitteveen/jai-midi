get_number_of_sources :: () -> int {
    return cast(int) MIDIGetNumberOfSources();
}

get_number_of_destinations :: () -> int {
    return cast(int) MIDIGetNumberOfDestinations();
}

get_source_info :: (index: int) -> MIDI_Source_Info, bool {
    endpoint := MIDIGetSource(cast(u32) index);
    endpoint_info, success := get_endpoint_info(endpoint);
    return xx endpoint_info, success;
}

get_destination_info :: (index: int) -> MIDI_Destination_Info, bool {
    endpoint := MIDIGetDestination(cast(u32) index);
    endpoint_info, success := get_endpoint_info(endpoint);
    return xx endpoint_info, success;
}

get_source_name :: (index: int) -> string {
    endpoint := MIDIGetSource(cast(u32) index);

    if endpoint {
        cfstring: CFStringRef;
        result := MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, *cfstring);
        if result == 0  return cfstring_to_string(cfstring);
        // Error.
    }

    return "";
}

get_destination_name :: (index: int) -> string {
    endpoint := MIDIGetDestination(cast(u32) index);

    if endpoint {
        cfstring: CFStringRef;
        result := MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, *cfstring);
        if result == 0  return cfstring_to_string(cfstring);
        // Error.
    }

    return "";
}

open_input :: (source_index: int, callback: MIDI_Input_Callback, user_data: *void = null) -> *MIDI_Input #must {
    init_macos(); // @TODO: Check result;

    source_endpoint := MIDIGetSource(xx source_index);
    if !source_endpoint {
        log_error("Cannot open MIDI input for source %.", source_index);
        return null;
    }

    input := New(MIDI_Input);
    input.index = source_index;
    input.callback = callback;
    input.callback_data = user_data;
    input.source_endpoint = source_endpoint;
    input.time_base = mach_absolute_time();

    result := MIDIPortConnectSource(input_port, input.source_endpoint, cast(*void) input);
    assert(result == 0, "Error in MIDIPortConnectSource (%)", result);

    // @Note: This code is the version to use when you want to open an actual input that other clients can see. Maybe we
    // can support that in the future, although not every OS will support this.
    // input_name := make_cf_string("input");
    // result := MIDIDestinationCreateWithProtocol(core_midi_client, input_name, xx kMIDIProtocol._1_0, *input.handle, xx *input._input_block);

    if result {
        free(input);
        return null;
    }

    return input;
}

close_input :: (input: *MIDI_Input) {
    if input {
        MIDIPortDisconnectSource(input_port, input.source_endpoint);
        free(input);
    }
}

open_output :: (destination_index: int) -> *MIDI_Output #must {
    init_macos(); // @TODO: Check result;

    destination_endpoint := MIDIGetDestination(xx destination_index);
    if !destination_endpoint {
        log_error("Cannot open MIDI output for destination %.", destination_index);
        return null;
    }

    output := New(MIDI_Output);
    output.index = destination_index;
    output.destination_endpoint = destination_endpoint;
    output.time_base = mach_absolute_time();

    return output;
}

close_output :: (output: *MIDI_Output, reset_all_notes := false) {
    if output {
        free(output);
    }
}

send_midi_message :: (output: *MIDI_Output, message: [] u8) -> bool {
    if get_status(message[0]) == .System_Exclusive {
        request: MIDISysexSendRequest;
        request.destination = output.destination_endpoint;

        request.data = message.data;
        request.bytesToSend = xx message.count;

        err := MIDISendSysex(*request);
        if err  return false;

        // MIDISendSysex works asynchronously. We could roll with that, but then we need to keep the MIDISysexSendRequest
        // alive somewhere, configure a callback for completion and then release the request. Meh.
        while !request.complete {
            sleep_milliseconds(1);
        }

        return true;
    }

    result: OSStatus;

    event_list: MIDIEventList;
    packet := MIDIEventListInit(*event_list, xx kMIDIProtocol._1_0);

    message_word_count := cast(u64) (align_forward(message.count, 4) / 4);
    assert(message_word_count == 1);

    word := make_ump_word(0, message[0], message[1], ifx message.count > 2 then message[2] else 0);

    packet = MIDIEventListAdd(*event_list, size_of(MIDIEventList), packet, 0 /* timestamp */, 1, *word);
    assert(packet != null);

    // send_result := MIDIReceivedEventList(output.handle, *event_list);

    send_result := MIDISendEventList(output_port, output.destination_endpoint, *event_list);

    if send_result {
        log_error("Error in MIDIReceivedEventList: %.", send_result);
    }

    return result == 0;
}

MIDI_Input_Platform_Data :: struct {
    // callback_context: Context;
    source_endpoint: MIDIEndpointRef;
    time_base: u64;

    ump_system_exclusive_buffer: [256] u8;
    ump_system_exclusive_buffer_count: int;
    ump_system_exclusive_status := UMP_System_Exclusive_Message_Status.Invalid;
    ump_system_exclusive_bytes_to_read: u8;
}

MIDI_Output_Platform_Data :: struct {
    destination_endpoint: MIDIEndpointRef;
    time_base: u64;
}

MIDI_Source_Info :: MIDI_Endpoint_Info;
MIDI_Destination_Info :: MIDI_Endpoint_Info;

#scope_file

MIDI_Endpoint_Info :: struct {
    name: string;
    display_name: string;
    model: string;
    manufacturer: string;
    icon_path: string;
    driver_owner: string;
    driver_version: int;
}

get_endpoint_info :: (endpoint: MIDIEndpointRef) -> MIDI_Endpoint_Info, bool {
    result: MIDI_Endpoint_Info;
    if !endpoint  return result, false;

    success := true;

    get_string_property :: (property: CFStringRef) -> string #expand {
        value: CFStringRef;
        status := MIDIObjectGetStringProperty(endpoint, property, *value);
        if status == 0  return cfstring_to_string(value);
        return "";
    }

    get_integer_property :: (property: CFStringRef) -> int #expand {
        value: s32;
        status := MIDIObjectGetIntegerProperty(endpoint, property, *value);
        if status == 0  return value;
        return 0;
    }

    result.name = get_string_property(kMIDIPropertyName);
    result.display_name = get_string_property(kMIDIPropertyDisplayName);
    result.model = get_string_property(kMIDIPropertyModel);
    result.manufacturer = get_string_property(kMIDIPropertyManufacturer);
    result.icon_path = get_string_property(kMIDIPropertyImage);
    result.driver_owner = get_string_property(kMIDIPropertyDriverOwner);
    result.driver_version = get_integer_property(kMIDIPropertyDriverVersion);

    // @Incomplete: We could get way more property values here, although I feel a lot of them are either not relevant,
    // or not filled out consistently.

    return result, success;
}

core_midi_client: MIDIClientRef;
input_port: MIDIPortRef;
output_port: MIDIPortRef;

input_block_descriptor: Objective_C_Block_Basic_Descriptor;
input_block: Objective_C_Block_Basic;

mach_timebase: mach_timebase_info;

midi_input_callback :: (block: *Objective_C_Block_Basic, event_list: *MIDIEventList, src_conn_ref_con: *void) #c_call {
    input := cast(*MIDI_Input)src_conn_ref_con;

    ctx: Context;
    push_context ctx {
        assert(event_list.protocol == xx kMIDIProtocol._1_0, "Received event list using an unsupported MIDI protocol.");
        assert(input != null, "Invalid input pointer.");

        packet := event_list.packet.data;
        end_packet := packet + event_list.numPackets;

        message: MIDI_Message = ---;
        message_ready: bool;

        print_event_list :: (event_list: *MIDIEventList) {
            p := event_list.packet.data;
            print("event list (% packets):\n", event_list.numPackets);
            for 0..event_list.numPackets - 1 {
                print("  packet % (% words): ", it, p.wordCount);
                for word_index: 0..p.wordCount - 1 {
                    ump_bytes := ump_word_to_bytes(p.words[word_index]);
                    for ump_bytes  print("% ", formatInt(it, base=16, minimum_digits=2));
                    if word_index != p.wordCount - 1  print("- ");
                }
                print("\n");
                p += 1;
            }
        }

        // print_event_list(event_list);

        while packet != end_packet {
            defer packet += 1;

            timestamp := mach_timestamp_to_apollo_time(packet.timeStamp - input.time_base);

            word := packet.words.data;
            end_word := word + packet.wordCount;

            sysex_bytes_to_read: u8;

            while word != end_word {
                ump_bytes := ump_word_to_bytes(<<word);
                ump_message_type := cast(UMP_Message_Type) (ump_bytes[0] >> 4);

                if ump_message_type == .System_Exclusive_Data {
                    words_read := handle_ump_sysex_event_list(input, word, end_word);
                    word += words_read;

                    if !input.decoder.message_in_progress {
                        message = create_system_exclusive_message(input.decoder.message_buffer);
                        message_ready = true;
                    }
                } else {
                    midi_bytes: [] u8 = ump_bytes;
                    midi_bytes.data += 1;
                    midi_bytes.count -= 1;
                    message = decode_midi_bytes(*input.decoder, midi_bytes);
                    message_ready = true;

                    word += 1;
                }

                if message_ready  post_message_to_input(input, message, timestamp);
            }
        }
    }
}

slice :: (array: [] $T, start_index: int) -> [] T {
    assert(start_index >= 0 && start_index <= array.count);
    result: [] T = ---;
    result.data = array.data + start_index;
    result.count = array.count - start_index;
    return result;
}

slice :: (array: [] $T, start_index: int, count: int) -> [] T {
    assert(start_index >= 0 && start_index <= array.count && count <= (array.count - start_index));
    result: [] T = ---;
    result.data = array.data + start_index;
    result.count = count;
    return result;
}

handle_ump_sysex_event_list :: (input: *MIDI_Input, start_word: *u32, end_word: *u32) -> int {
    decoder := *input.decoder;
    word := start_word;

    append_bytes :: (bytes: [] u8, number_of_bytes: int) #expand {
        if number_of_bytes == 0  return;

        sysex_bytes_to_copy := min(number_of_bytes, 2);
        array_add(*decoder.message_buffer, ..slice(bytes, 2, sysex_bytes_to_copy)); // Add the first two bytes.
        number_of_bytes -= sysex_bytes_to_copy;
        while number_of_bytes > 0 {
            `word += 1;
            sysex_bytes_to_copy = min(number_of_bytes, 4);
            array_add(*decoder.message_buffer, ..slice(ump_word_to_bytes(<<word), 0, sysex_bytes_to_copy));
            number_of_bytes -= sysex_bytes_to_copy;
        }
    }

    while word != end_word {
        bytes := ump_word_to_bytes(<<word);

        assert((cast(UMP_Message_Type) (bytes[0] >> 4)) == .System_Exclusive_Data);

        sysex_status := cast(UMP_System_Exclusive_Message_Status) (bytes[1] >> 4);
        number_of_bytes := bytes[1] & 0xf;

        if sysex_status == .Start || sysex_status == .Complete_In_One_UMP {
            assert(!decoder.message_in_progress);
            reset_system_exclusive_buffer(decoder);
            decoder.message_in_progress = true;
            array_add(*decoder.message_buffer, cast(u8) MIDI_Status.System_Exclusive);
        }

        append_bytes(bytes, number_of_bytes);

        if sysex_status == .Complete_In_One_UMP || sysex_status == .End {
            array_add(*decoder.message_buffer, cast(u8) MIDI_Status.End_Of_System_Exclusive);
            decoder.message_in_progress = false;
        }

        word += 1;
    }

    return word - start_word;
}

make_ump_word :: (group: u32, status_channel: u32, data1: u32, data2: u32) -> u32 #expand {
    return (((0x2 << 4) | (group & 0xf)) << 24) | (status_channel << 16) | ((data1 & 0x7f) << 8) | (data2 & 0x7f);
}

ump_word_to_bytes :: (ump: u32) -> [4] u8 #expand {
    ump_word_reversed := byte_swap(ump);
    result: [4] u8;
    memcpy(result.data, cast(*u8) *ump_word_reversed, 4);
    return result;
}

UMP_Message_Type :: enum u8 {
    Utility                     :: 0x0;
    Real_Time_And_System_Common :: 0x1;
    Channel_Voice               :: 0x2;
    System_Exclusive_Data       :: 0x3;
    MIDI2_Channel_Voice         :: 0x4;
    Data                        :: 0x5;
}

UMP_System_Exclusive_Message_Status :: enum u8 {
    Complete_In_One_UMP :: 0x0;
    Start               :: 0x1;
    Continue            :: 0x2;
    End                 :: 0x3;

    Invalid             :: 0xff;
}

UMP_Message :: struct {
    type: UMP_Message_Type;
    group: u8;
    midi_bytes: [] u8;
}

decode_ump_bytes :: (decoder: *MIDI_Decoder, bytes: [] u8) -> UMP_Message, bool {
    message: UMP_Message;

    if bytes.count < 3 {
        assert(false, "Received invalid MIDI data.");
        return message, false;
    }

    message.type = xx (bytes[0] >> 4);
    message.group = bytes[0] & 0xf;
    message.midi_bytes = bytes;
    message.midi_bytes.data += 1;
    message.midi_bytes.count -= 1;

    return message, true;
}

init_macos :: () -> bool {
    // @Note: Apple advises not to dispose clients or ports explicitly; this will happen for you upon application exit.

    if core_midi_client == 0 {
        init_objective_c();

        // Initialize the client.
        cfstring := make_cf_string(CLIENT_NAME, false);
        result := MIDIClientCreate(cfstring, null, null, *core_midi_client); // @TODO: Posisbly we should use MIDIClientCreateWithBlock

        success := result == 0;

        // Setup Objective-C blocks for the MIDI input callback.
        input_block.isa = xx _NSConcreteGlobalBlock;
        input_block.invoke = xx midi_input_callback;
        input_block.descriptor = *input_block_descriptor;
        input_block_descriptor.size = size_of(Objective_C_Block_Basic);

        // Setup ports.
        if result == 0 {
            success &= init_input_port(*input_port);
            success &= init_output_port(*output_port);
        }

        mach_timebase_info_(*mach_timebase);

        return success;
    }
    return true;
}

init_input_port :: (port: *MIDIPortRef) -> bool {
    port_name := make_cf_string("input_port");
    result := MIDIInputPortCreateWithProtocol(core_midi_client, port_name, xx kMIDIProtocol._1_0, port, xx *input_block);
    assert(result == 0, "Error in MIDIInputPortCreateWithProtocol (%)", result);
    return result == 0;
}

init_output_port :: (port: *MIDIPortRef) -> bool {
    port_name := make_cf_string("output_port");
    result := MIDIOutputPortCreate(core_midi_client, port_name, port);
    assert(result == 0, "Error in MIDIOutputPortCreate (%)", result);
    return result == 0;
}

CFSTR :: (s: *u8) -> CFStringRef #expand {
    return cast(CFStringRef) s;
}

make_cf_string :: (s: string, $defer_release := true) -> CFStringRef #expand {
    cfstring := CFStringCreateWithBytes(null, s.data, s.count, .UTF8, false);
    #if defer_release  `defer CFRelease(cfstring);
    return cfstring;
}

make_cf_string :: ($defer_release := true) -> CFStringRef #expand {
    cfstring: CFStringRef;
    #if defer_release  `defer CFRelease(cfstring);
    return cfstring;
}

// @Note: This is a copy of to_string in the macos module, since that one contains some bugs at the moment.
cfstring_to_string :: (cfstring: CFStringRef) -> string {
    c_string := CFStringGetCStringPtr(cfstring, .UTF8);
    if c_string     return to_string(c_string);

    // Slow path: The CFString is not encoded in UTF-8, so it needs to be transcoded...
    utf16_length := CFStringGetLength(cfstring);
    max_size := CFStringGetMaximumSizeForEncoding(utf16_length, .UTF8);
    data := context.allocator.proc(.ALLOCATE, max_size + 1, 0, null, context.allocator.data);
    success := CFStringGetCString(cfstring, data, max_size + 1, .UTF8);
    if !success     return ""; // This should not happen since the buffer is supposedly big enough

    return to_string(cast(*u8) data);
}

mach_timestamp_to_apollo_time :: (timestamp: u64) -> Apollo_Time #expand {
    // @Incomplete: This is probably not the most accurate way of converting.
    time_milliseconds := (timestamp * mach_timebase.numer) / (1_000_000 * mach_timebase.denom);
    return milliseconds_to_apollo(cast(s64) time_milliseconds);
}

#load "bindings/macos.jai";
#import "Objective_C";
#import "Bit_Operations"; // For byte_swap.
