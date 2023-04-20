/*
   CoreMIDI structs
   ================
   Header folder:
   /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/CoreMIDI.framework/Versions/A/Headers/
   struct MIDIPacket // A collection of simultaneous MIDI events.
   {
       MIDITimeStamp timeStamp; // Normally can have 0 to mean 'now', but NOT when using MIDIReceived!
       UInt16 length; // Length of valid MIDI bytes in data.
       Byte data[256]; // Variable-length stream of MIDI messages. Running status not allowed! Messages must always be complete.
                       // It is declared to be 256 bytes to handle simple situations.
   };
   struct MIDIPacketList
   {
       UInt32 numPackets; // Number of MIDIPackets in the list.
       MIDIPacket packet[1]; // Open-ended array of variable-length MIDIPackets. Do not access directly.
   };
*/

TARGET_MACOS_11_PLUS :: true;

get_number_of_sources :: () -> int {
    return cast(int) MIDIGetNumberOfSources();
}

get_number_of_destinations :: () -> int {
    return cast(int) MIDIGetNumberOfDestinations();
}

get_source_name :: (index: int) -> string {
    endpoint := MIDIGetSource(cast(u32) index);

    if endpoint {
        cfstring: CFStringRef;
        result := MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, *cfstring);
        if result == 0  return to_string(cfstring);
        // Error.
    }

    return "";
}

get_destination_name :: (index: int) -> string {
    endpoint := MIDIGetDestination(cast(u32) index);

    if endpoint {
        cfstring: CFStringRef;
        result := MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, *cfstring);
        if result == 0  return to_string(cfstring);
        // Error.
    }

    return "";
}

open_input :: (index: int, callback: MIDI_Input_Callback = null, user_data: *void = null) -> *MIDI_Input #must {
    ensure_client(); // @TODO: Check result;

    input := New(MIDI_Input);

    input._input_block.isa = xx _NSConcreteGlobalBlock;
    input._input_block.invoke = xx midi_input_block;
    input._input_block.descriptor = *input._input_block_descriptor;
    input._input_block_descriptor.size = size_of(Objective_C_Block_Basic);

    #if TARGET_MACOS_11_PLUS {
        input_name := make_cf_string("input");
        result := MIDIDestinationCreateWithProtocol(core_midi_client, input_name, xx kMIDIProtocol._1_0, *input.handle, xx *input._input_block);
    } else {
        #assert false "macOS < 11 is not supported.";
        // result := MIDIDestinationCreate(core_midi_client, CFSTR("default"), *output.handle);
    }

    if result {
        free(input);
        return null;
    }

    return input;
}

close_input :: (input: *MIDI_Input) {
    if input {
        result := MIDIEndpointDispose(input.handle);
        free(input);
    }
}

open_output :: (destination_index: int) -> *MIDI_Output #must {
    ensure_client(); // @TODO: Check result;

    destination_endpoint := MIDIGetDestination(xx destination_index);
    if !destination_endpoint {
        log_error("Cannot open MIDI output with destination %.", destination_index);
        return null;
    }

    output := New(MIDI_Output);
    output.destination_endpoint = destination_endpoint;

    #if TARGET_MACOS_11_PLUS {
        output_name := make_cf_string("output");
        result := MIDISourceCreateWithProtocol(core_midi_client, output_name, xx kMIDIProtocol._1_0, *output.handle);
        assert(result == 0);

        output_port_name := make_cf_string("output_port");
        result = MIDIOutputPortCreate(core_midi_client, output_port_name, *output.port);
        assert(result == 0);
    } else {
        #assert false "macOS < 11 is not supported.";
        // result := MIDISourceCreate(core_midi_client, CFSTR("default"), *output.handle);
    }

    if result {
        free(output);
        return null;
    }

    return output;
}

close_output :: (output: *MIDI_Output, reset_all_notes := false) {
    if output {
        result := MIDIEndpointDispose(output.handle);
        free(output);
    }
}

send_midi_message :: (output: *MIDI_Output, message: [] u8) -> bool {
    if get_status(message[0]) == .System_Exclusive {
        request: MIDISysexSendRequest;
        request.destination = output.handle;

        data_pointer := message.data;
        request.data = data_pointer;
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

    // packet_buffer: [256] u8;
    // packet_list := cast(*MIDIPacketList) output.packet_buffer;
    // packets := MIDIPacketListInit(output.packet_list);

    // macOS 11+:
    // event_list := cast(*MIDIReceivedEventList) output.packet_buffer;
    // events := MIDIEventListInit(output.packet_list, kMIDIProtocol_1_0);
    // next_packet := MIDIEventListAdd(event_list, event_buffer.count, events, timestamp, <word_count>, <word_pointer>);

    // timestamp := mach_absolute_time();
    // next_packet := MIDIPacketListAdd(packet_list, packet_buffer.count, packets, timestamp, number_of_bytes, bytes.data);
    // assert(next_packet != null, "No space for packet.");

    // result := MIDIReceived(output.handle, output.packet_list);

    // macOS 11+:
    result: OSStatus;

    event_list: MIDIEventList;
    packet := MIDIEventListInit(*event_list, xx kMIDIProtocol._1_0);

    message_word_count := cast(u64) (align_forward(message.count, 4) / 4);
    assert(message_word_count == 1);

    message_as_ump_word :: (group: u32, status_channel: u32, data1: u32, data2: u32) -> u32 #expand {
        return (((0x2 << 4) | (group & 0xf)) << 24) | (status_channel << 16) | ((data1 & 0x7f) << 8) | (data2 & 0x7f);
    }

    word := message_as_ump_word(0, message[0], message[1], ifx message.count > 2 then message[2] else 0);

    // print("message = %\nword = 0x%\n", message, formatInt(word, base=16));

    packet = MIDIEventListAdd(*event_list, size_of(MIDIEventList), packet, 0 /* timestamp */, 1, *word);
    assert(packet != null);

    // send_result := MIDIReceivedEventList(output.handle, *event_list);

    send_result := MIDISendEventList(output.port, output.destination_endpoint, *event_list);

    if send_result {
        log_error("Error in MIDIReceivedEventList: %.", send_result);
    }

    return result == 0;
}

MIDI_Input_Platform_Data :: struct {
    handle: MIDIEndpointRef;
    callback_context: Context;

    _input_block_descriptor: Objective_C_Block_Basic_Descriptor;
    _input_block: Objective_C_Block_Basic;
}

MIDI_Output_Platform_Data :: struct {
    handle: MIDIEndpointRef;

    port: MIDIPortRef;
    destination_endpoint: MIDIEndpointRef;
}

#scope_file

core_midi_client: MIDIClientRef;

midi_input_block :: (block: *Objective_C_Block_Basic, event_list: *MIDIEventList, src_conn_ref_con: *void) #c_call {
    ctx: Context;
    push_context ctx {
        debug_break();
        print("Reached the input block!!!\n");
    }
}

midi_input_callback :: (event_list: *MIDIEventList, src_conn_ref_con: *void) #c_call {
    new_context: Context;
    push_context new_context {

    }
}

// @Note: There is a MIDIClientDispose, but Apple advises not to call this explicitly; the system will dispose clients
// automatically when the applicaton exits.

ensure_client :: () -> bool {
    if core_midi_client == 0 {
        init_objective_c();
        cfstring := make_cf_string(CLIENT_NAME, false); // @Leak
        // @TODO: Posisbly we should use MIDIClientCreateWithBlock
        result := MIDIClientCreate(cfstring, null, null, *core_midi_client);
        return result == 0;
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

#load "bindings_macos.jai";
#import "Objective_C";
