get_number_of_sources :: () -> int {
    return cast(int) MIDIGetNumberOfSources();
}

get_number_of_destinations :: () -> int {
    return cast(int) MIDIGetNumberOfDestinations();
}

get_source_info :: (index: int) -> bool, MIDI_Source_Info {
    endpoint := MIDIGetSource(cast(u32) index);
    success, endpoint_info := get_endpoint_info(endpoint);
    return success, xx endpoint_info;
}

get_destination_info :: (index: int) -> bool, MIDI_Destination_Info {
    endpoint := MIDIGetDestination(cast(u32) index);
    success, endpoint_info := get_endpoint_info(endpoint);
    return success, xx endpoint_info;
}

get_source_name :: (index: int) -> string {
    endpoint := MIDIGetSource(cast(u32) index);
    if endpoint {
        cfstring: CFStringRef;
        result := MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, *cfstring);
        if result == noErr  return to_string(cfstring);
    }

    return "";
}

get_destination_name :: (index: int) -> string {
    endpoint := MIDIGetDestination(cast(u32) index);
    if endpoint {
        cfstring: CFStringRef;
        result := MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, *cfstring);
        if result == noErr  return to_string(cfstring);
    }

    return "";
}

open_input :: (source_index: int, callback: MIDI_Input_Callback, user_data: *void = null) -> *MIDI_Input {
    if !init_macos() return null;

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

    init_input_block(input);
    if !init_input_port(*input.port, "input_port", *input.input_block) {
        close_input(input);
        return null;
    }

    result := MIDIPortConnectSource(input.port, input.source_endpoint, null);
    assert_coremidi("MIDIPortConnectSource", result);

    if result != noErr {
        close_input(input);
        return null;
    }

    return input;
}

open_virtual_input :: (input_name: string, callback: MIDI_Input_Callback, user_data: *void = null) -> *MIDI_Input {
    if !init_macos() return null;

    input := New(MIDI_Input);
    input.index = -1;
    input.callback = callback;
    input.callback_data = user_data;
    input.time_base = mach_absolute_time();
    init_input_block(input);

    cf_input_name := make_cf_string(input_name);
    result := MIDIDestinationCreateWithProtocol(core_midi_client, cf_input_name, xx kMIDIProtocol._1_0, *input.virtual_endpoint, xx *input.input_block);
    assert_coremidi("MIDIDestinationCreateWithProtocol", result);

    if result != noErr {
        close_input(input);
        return null;
    }

    return input;
}

close_input :: (input: *MIDI_Input) {
    if input {
        if input.virtual_endpoint {
            assert(input.source_endpoint == 0, "The given input seems to be a virtual input, but for some reason it has a regular source endpoint set.");
            result := MIDIEndpointDispose(input.virtual_endpoint);
            assert_coremidi("MIDIEndpointDispose", result);
        } else if input.source_endpoint {
            result := MIDIPortDisconnectSource(input.port, input.source_endpoint);
            assert_coremidi("MIDIPortDisconnectSource", result);
        }

        if input.port {
            result := MIDIPortDispose(input.port);
            assert_coremidi("MIDIPortDispose", result);
        }

        free_input(input);
    }
}

open_output :: (destination_index: int) -> *MIDI_Output {
    if !init_macos() return null;

    destination_endpoint := MIDIGetDestination(xx destination_index);
    if !destination_endpoint {
        log_error("Cannot open MIDI output for destination %.", destination_index);
        return null;
    }

    output := New(MIDI_Output);
    output.index = destination_index;
    output.destination_endpoint = destination_endpoint;
    output.time_base = mach_absolute_time();

    if !init_output_port(*output.port, "output_port") {
        close_output(output);
        return null;
    }

    return output;
}

open_virtual_output :: (output_name: string) -> *MIDI_Output {
    if !init_macos() return null;

    output := New(MIDI_Output);
    output.index = -1;
    output.time_base = mach_absolute_time();

    cf_output_name := make_cf_string(output_name);
    result := MIDISourceCreateWithProtocol(core_midi_client, cf_output_name, xx kMIDIProtocol._1_0, *output.virtual_endpoint);
    assert_coremidi("MIDISourceCreateWithProtocol", result);

    if result != noErr {
        close_output(output);
        return null;
    }

    return output;
}

close_output :: (output: *MIDI_Output) {
    if output {
        if output.virtual_endpoint {
            assert(output.destination_endpoint == 0, "The given output seems to be a virtual output, but for some reason it has a regular destination endpoint set.");
            result := MIDIEndpointDispose(output.virtual_endpoint);
            assert_coremidi("MIDIEndpointDispose", result);
        }

        if output.port {
            result := MIDIPortDispose(output.port);
            assert_coremidi("MIDIPortDispose", result);
        }

        free(output);
    }
}

send_midi_message :: (output: *MIDI_Output, message: [] u8) -> bool {
    status := get_status(message[0]);

    if status == .System_Exclusive {
        request: MIDISysexSendRequest;
        request.destination = output.destination_endpoint;

        request.data = message.data;
        request.bytesToSend = xx message.count;

        result := MIDISendSysex(*request);
        assert_coremidi("MIDISendSysex", result);
        if result != noErr  return false;

        // @Hack @Speed MIDISendSysex works asynchronously. We could roll with that, but then we need to keep the
        // MIDISysexSendRequest alive somewhere, configure a callback for completion and then free the request.
        while !request.complete {
            sleep_milliseconds(1);
        }

        return true;
    }

    event_list: MIDIEventList;
    packet := MIDIEventListInit(*event_list, xx kMIDIProtocol._1_0);

    message_word_count := cast(u64) (align_forward(message.count, 4) / 4);
    assert(message_word_count == 1);

    ump_message_type := UMP_Message_Type.MIDI_1_Voice;
    if is_realtime_status(status)  ump_message_type = .System_Common_Or_Real_Time;

    word := make_ump_word(ump_message_type, 0, message[0],
                          ifx message.count > 1 then message[1] else 0,
                          ifx message.count > 2 then message[2] else 0);

    packet = MIDIEventListAdd(*event_list, size_of(MIDIEventList), packet, 0 /* timestamp */, 1, *word);
    assert(packet != null);

    result: OSStatus;
    if output.virtual_endpoint {
        result = MIDIReceivedEventList(output.virtual_endpoint, *event_list);
        assert_coremidi("MIDIReceivedEventList", result);
    } else {
        result = MIDISendEventList(output.port, output.destination_endpoint, *event_list);
        assert_coremidi("MIDISendEventList", result);
    }

    return result == noErr;
}

MIDI_Input_Platform_Data :: struct {
    port: MIDIPortRef;
    source_endpoint: MIDIEndpointRef;
    virtual_endpoint: MIDIEndpointRef;
    time_base: u64;
    input_block: Objective_C_Block_MIDI_Input;
}

MIDI_Output_Platform_Data :: struct {
    port: MIDIPortRef;
    destination_endpoint: MIDIEndpointRef;
    virtual_endpoint: MIDIEndpointRef;
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

get_endpoint_info :: (endpoint: MIDIEndpointRef) -> bool, MIDI_Endpoint_Info {
    result: MIDI_Endpoint_Info;
    if !endpoint  return result, false;

    success := true;

    get_string_property :: (property: CFStringRef) -> string #expand {
        value: CFStringRef;
        status := MIDIObjectGetStringProperty(endpoint, property, *value);
        if status == noErr  return to_string(value);
        return "";
    }

    get_integer_property :: (property: CFStringRef) -> int #expand {
        value: s32;
        status := MIDIObjectGetIntegerProperty(endpoint, property, *value);
        if status == noErr  return value;
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

    return success, result;
}

Objective_C_Block_MIDI_Input :: struct {
    #as using block_basic: Objective_C_Block_Basic;
    input: *MIDI_Input;
}

core_midi_client: MIDIClientRef;

mach_timebase: mach_timebase_info;
mach_timebase_valid := false;

midi_input_callback :: (block: *Objective_C_Block_MIDI_Input, event_list: *MIDIEventList, src_conn_ref_con: *void) #c_call {
    input := block.input;

    push_context {
        assert(event_list.protocol == xx kMIDIProtocol._1_0, "Received event list using an unsupported MIDI protocol.");
        assert(input != null, "Invalid input pointer.");

        // @Note: The thing that is called a 'packet' in CoreMIDI can actually contain multiple UMPs!
        packet := event_list.packet.data;
        end_packet := packet + event_list.numPackets;

        while packet != end_packet {
            defer packet += 1;

            timestamp: Apollo_Time;
            if packet.timeStamp  timestamp = mach_timestamp_to_apollo_time(packet.timeStamp - input.time_base);

            words: [] u32 = ---;
            words.data = packet.words.data;
            words.count = packet.wordCount;

            while words.count {
                message_decoded, message := decode_ump_words(*input.decoder, *words);
                if message_decoded  post_message_to_input(input, message, timestamp);
            }
        }
    }
}

init_macos :: () -> bool {
    if core_midi_client == 0 {
        init_objective_c();

        // Initialize the client.
        cfstring := make_cf_string(CLIENT_NAME, false);

         // @Note: Possibly we should use MIDIClientCreateWithBlock to receive MIDI system state change notifications.
        result := MIDIClientCreate(cfstring, null, null, *core_midi_client);
        assert_coremidi("MIDIClientCreate", result);
        success := result == noErr;
        if !success  log_error("Could not create CoreMIDI client.");

        if mach_timebase_info_(*mach_timebase) == .SUCCESS {
            mach_timebase_valid = true;
        } else {
            log_error("Could not retrieve system timing information.");
        }

        return success;
    }

    return true;
}

input_block_descriptor :: Objective_C_Block_Basic_Descriptor.{size = size_of(Objective_C_Block_MIDI_Input)};

init_input_block :: (input: *MIDI_Input) {
    input.input_block.isa = xx _NSConcreteGlobalBlock;
    input.input_block.invoke = xx midi_input_callback;
    input.input_block.descriptor = *input_block_descriptor;
    input.input_block.input = input;
}

init_input_port :: (port: *MIDIPortRef, name: string, input_block: *Objective_C_Block_Basic) -> bool {
    port_name := make_cf_string(name);
    result := MIDIInputPortCreateWithProtocol(core_midi_client, port_name, xx kMIDIProtocol._1_0, port, xx input_block);
    assert_coremidi("MIDIInputPortCreateWithProtocol", result);

    if result != noErr {
        port.* = 0;
        return false;
    }

    return true;
}

init_output_port :: (port: *MIDIPortRef, name: string) -> bool {
    port_name := make_cf_string(name);
    result := MIDIOutputPortCreate(core_midi_client, port_name, port);
    assert_coremidi("MIDIOutputPortCreate", result);

    if result != noErr {
        port.* = 0;
        return false;
    }

    return true;
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

mach_timestamp_to_apollo_time :: (timestamp: u64) -> Apollo_Time #expand {
    if mach_timebase_valid {
        // @Incomplete: This is probably not the most accurate way of converting.
        time_milliseconds := (timestamp * mach_timebase.numer) / (1_000_000 * mach_timebase.denom);
        return milliseconds_to_apollo(cast(s64) time_milliseconds);
    }

    return .{};
}

assert_coremidi :: (procedure_name: string, result: OSStatus) #expand {
    assert(result == noErr, "Error in % (return code was %).", procedure_name, result);
}

#load "bindings/macos.jai";
#load "../ump.jai";

#import "Objective_C";
