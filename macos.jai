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

open_input :: (source_index: int, callback: MIDI_Input_Callback, user_data: *void = null) -> *MIDI_Input #must {
    ensure_client(); // @TODO: Check result;

    source_endpoint := MIDIGetSource(xx source_index);
    if !source_endpoint {
        log_error("Cannot open MIDI output with source %.", source_endpoint);
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
    ensure_client(); // @TODO: Check result;

    destination_endpoint := MIDIGetDestination(xx destination_index);
    if !destination_endpoint {
        log_error("Cannot open MIDI output with destination %.", destination_index);
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
        // result := MIDIEndpointDispose(output.handle);
        free(output);
    }
}

send_midi_message :: (output: *MIDI_Output, message: [] u8) -> bool {
    if get_status(message[0]) == .System_Exclusive {
        request: MIDISysexSendRequest;
        request.destination = output.destination_endpoint;

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

    result: OSStatus;

    event_list: MIDIEventList;
    packet := MIDIEventListInit(*event_list, xx kMIDIProtocol._1_0);

    message_word_count := cast(u64) (align_forward(message.count, 4) / 4);
    assert(message_word_count == 1);

    word := message_as_ump_word(0, message[0], message[1], ifx message.count > 2 then message[2] else 0);

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
}

MIDI_Output_Platform_Data :: struct {
    destination_endpoint: MIDIEndpointRef;

    time_base: u64;
}

#scope_file

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

        for 1..event_list.numPackets {
            timestamp := mach_timestamp_to_apollo_time(packet.timeStamp - input.time_base);

            for word_index: 0..packet.wordCount {
                midi_event_bytes := ump_word_to_bytes(packet.words[word_index]);
                message, message_ready := decode_midi_bytes(*input.decoder, midi_event_bytes);
                if message_ready  post_message_to_input(input, message, timestamp);
            }
        }
    }
}

message_as_ump_word :: (group: u32, status_channel: u32, data1: u32, data2: u32) -> u32 #expand {
    return (((0x2 << 4) | (group & 0xf)) << 24) | (status_channel << 16) | ((data1 & 0x7f) << 8) | (data2 & 0x7f);
}

ump_word_to_bytes :: (ump: u32) -> [3] u8 #expand {
    result: [3] u8;
    result[0] = cast(u8) ((ump >> 16) & 0xff);
    result[1] = cast(u8) ((ump >> 8) & 0x7f);
    result[2] = cast(u8) (ump & 0x7f);
    return result;
}

// @Note: There is a MIDIClientDispose, but Apple advises not to call this explicitly; the system will dispose clients
// automatically when the applicaton exits. The same goes for ports.

ensure_client :: () -> bool {
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

mach_timestamp_to_apollo_time :: (timestamp: u64) -> Apollo_Time #expand {
    time_milliseconds := (timestamp * mach_timebase.numer) / (1_000_000 * mach_timebase.denom);
    return milliseconds_to_apollo(cast(s64) time_milliseconds);
}

#load "bindings_macos.jai";
#import "Objective_C";
