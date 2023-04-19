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

open_input :: (index: int, callback: MIDI_Input_Callback = null, user_data: *void = null, client_name := "") -> *MIDI_Input, bool {
    ensure_client(); // @TODO: Check result;

    input := New(MIDI_Input);

    input._input_block.isa = xx _NSConcreteGlobalBlock;
    input._input_block.invoke = xx midi_input_block;
    input._input_block.descriptor = *input._input_block_descriptor;
    input._input_block_descriptor.size = size_of(Objective_C_Block_Basic);

    #if TARGET_MACOS_11_PLUS {
        input_name := make_cf_string("default");
        result := MIDIDestinationCreateWithProtocol(core_midi_client, input_name, xx kMIDIProtocol._1_0, *input.handle, xx *input._input_block);
    } else {
        #assert false "macOS < 11 is not supported.";
        // result := MIDIDestinationCreate(core_midi_client, CFSTR("default"), *output.handle);
    }

    if result {
        free(input);
        return null, false;
    }

    return input, true;
}

close_input :: (input: *MIDI_Input) {
    if input {
        result := MIDIEndpointDispose(input.handle);
        free(input);
    }
}

open_output :: (index: int) -> *MIDI_Output, bool {
    ensure_client(); // @TODO: Check result;

    output := New(MIDI_Output);

    #if TARGET_MACOS_11_PLUS {
        output_name := make_cf_string("default");
        result := MIDISourceCreateWithProtocol(core_midi_client, output_name, xx kMIDIProtocol._1_0, *output.handle);
    } else {
        #assert false "macOS < 11 is not supported.";
        // result := MIDISourceCreate(core_midi_client, CFSTR("default"), *output.handle);
    }

    if result {
        free(output);
        return null, false;
    }

    return output, true;
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

    // packet_storage: struct {
    //     timestamp: MIDITimeStamp #align 4;
    //     length: u16;
    //     events: *u8;
    // }

    // assert(message.data < size_of(MIDIPacket.data));
    // packet_storage.length = xx message.count;
    // packet_storage.events = message.data;

    event_list_storage: [512] u8;

    event_list := cast(*MIDIEventList) event_list_storage.data;

    // event_list: MIDIEventList;
    packet := MIDIEventListInit(event_list, xx kMIDIProtocol._1_0);

    message_word_count := cast(u64) (align_forward(message.count, 4) / 4);
    assert(message_word_count == 1);
    words: [64] u32;

    memcpy(words.data, message.data, message.count);
    print("word = 0x% \n", formatInt(words[0], base=16));

    packet = MIDIEventListAdd(event_list, size_of(MIDIEventList), packet, 0 /* timestamp */, message_word_count, words.data);
    assert(packet != null);

    send_result := MIDIReceivedEventList(output.handle, event_list);

    if result {
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
    // packet_list: *MIDIPacketList;
    // packet: *MIDIPacket;
    // packet_buffer: [256] u8;

    // event_list: struct {
    //     protocol: kMIDIProtocol;
    //     count: u32;
    //     event_storagte: [256] u8;
    // }
}

#scope_file

core_midi_client: MIDIClientRef;

midi_input_block :: (block: *Objective_C_Block_Basic, event_list: *MIDIEventList, src_conn_ref_con: *void) #c_call {
    ctx: Context;
    push_context ctx {
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
        name := ifx CLIENT_NAME then CLIENT_NAME else "default";
        cfstring := make_cf_string(name, false); // @Leak
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
