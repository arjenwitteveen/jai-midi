get_number_of_sources :: () -> int {
    sequencer_success := with_sequencer();
    if sequencer_success  return get_port_count(sequencer, source = true);
    return 0;
}

get_number_of_destinations :: () -> int {
    sequencer_success := with_sequencer();
    if sequencer_success  return get_port_count(sequencer, source = false);
    return 0;
}

get_source_info :: (index: int) -> MIDI_Source_Info, bool {
    sequencer_success := with_sequencer();
    if sequencer_success {
        info, info_success := get_port_info(sequencer, index, source = true);
        if info_success  return xx info, true;
    }
    return .{}, false;
}

get_destination_info :: (index: int) -> MIDI_Destination_Info, bool {
    sequencer_success := with_sequencer();
    if sequencer_success {
        info, info_success := get_port_info(sequencer, index, source = false);
        if info_success  return xx info, true;
    }
    return .{}, false;
}

get_source_name :: (index: int) -> string {
    info, success := get_source_info(index);
    if success  return tprint("% (%) %:%", info.client_name, info.port_name, info.client_number, info.port_number);
    return "";
}

get_destination_name :: (index: int) -> string {
    info, success := get_destination_info(index);
    if success  return tprint("% (%) %:%", info.client_name, info.port_name, info.client_number, info.port_number);
    return "";
}

open_input :: (source_index: int, callback: MIDI_Input_Callback, user_data: *void = null) -> *MIDI_Input {
    result := New(MIDI_Input);
    result.index = -1;
    result.queue_id = -1;

    success := false;
    defer if !success  close_input(result);

    seq_open_result := snd_seq_open(*result.sequencer, "default", SND_SEQ_OPEN_DUPLEX, SND_SEQ_NONBLOCK);
    if seq_open_result < 0 {
        log_error("Could not intialize MIDI client.");
        return null;
    }

    if CLIENT_NAME  snd_seq_set_client_name(result.sequencer, CLIENT_NAME);

    number_of_sources := get_number_of_sources();
    if source_index < 0 || source_index >= number_of_sources {
        additional_error_message := ifx number_of_sources > 0 then tprint("highest available source index is %", number_of_sources - 1) else "no sources are available";
        log_error("Cannot open MIDI input with source % (%).", source_index, additional_error_message);
        return null;
    }

    port_info, port_found := get_port_info(result.sequencer, source_index, source = true);
    if !port_found {
        log_error("Could not find MIDI source with index %.", source_index);
        return null;
    }

    our_input_port_number := snd_seq_create_simple_port(result.sequencer, "input", xx (SND_SEQ_PORT_CAP.WRITE | .SUBS_WRITE), xx SND_SEQ_PORT_TYPE.APPLICATION);
    our_client_number := snd_seq_client_id(result.sequencer);

    // Create queue.
    queue_id := snd_seq_alloc_queue(result.sequencer);
    if queue_id < 0 {
        log_error("Could not create queue.");
        return null;
    }

    sender, destination: snd_seq_addr_t;
    sender.client = xx port_info.client_number;
    sender.port = xx port_info.port_number;
    destination.client = xx our_client_number;
    destination.port = xx our_input_port_number;

    // log_verbose("Creating input connection %:% -> %:%.", sender.client, sender.port, destination.client, destination.port);

    subscription: *snd_seq_port_subscribe_t;
    snd_seq_port_subscribe_malloc(*subscription);
    snd_seq_port_subscribe_set_sender(subscription, *sender);
    snd_seq_port_subscribe_set_dest(subscription, *destination);
    snd_seq_port_subscribe_set_queue(subscription, queue_id);
    snd_seq_port_subscribe_set_time_update(subscription, 1);
    snd_seq_port_subscribe_set_time_real(subscription, 1);
    subscribe_result := snd_seq_subscribe_port(result.sequencer, subscription);
    if subscribe_result < 0 {
        log_error("Could not set up port subscription.");
        return null;
    }

    snd_seq_start_queue(result.sequencer, cast(u8) queue_id, null);
    snd_seq_drain_output(result.sequencer);

    result.index = source_index;
    result.callback = callback;
    result.callback_data = user_data;
    result.queue_id = queue_id;
    result.subscription = subscription;
    pipe_result := pipe(*result.thread_notification_pipe);
    assert(pipe_result == 0);

    init(*result.thread_start_semaphore);

    // Create thread to handle callbacks.
    thread_init_success := thread_init(*result.thread, midi_input_thread);
    if !thread_init_success {
        log_error("Could not initialize callback thread.");
        return null;
    }
    result.thread.data = xx result;
    thread_start(*result.thread);

    // Wait until the thread's initialization status has been set.
    while wait_for(*result.thread_start_semaphore, 0) != .SUCCESS {
        if thread_is_done(*result.thread) {
            log_error("The callback thread shutdown unexpectedly.");
            return null;
        }
    }

    if !result.thread_start_success {
        log_error("Error during callback thread startup.");
        return null;
    }

    success = true; // Needed in the defer handler!

    return result;
}

close_input :: (using input: *MIDI_Input) {
    if input == null  return;

    // Shudown callback thread.
    if input.thread.index {
        dummy: u8 = 0xcd;
        write(thread_notification_pipe_write, *dummy, 1);
        for 1..100  if thread_is_done(*thread, 10)  break;
        thread_deinit(*thread);
    }

    if input.thread_notification_pipe {
        close(thread_notification_pipe_write);
        close(thread_notification_pipe_read);
    }

    if input.subscription {
        snd_seq_unsubscribe_port(sequencer, subscription);
        snd_seq_port_subscribe_free(subscription);
    }

    if input.index >= 0  snd_seq_delete_simple_port(sequencer, xx index);

    if input.queue_id >= 0 {
        // @Note: Not sure if the stop/drain are actually necessary.
        snd_seq_stop_queue(sequencer, xx queue_id, null);
        snd_seq_drain_output(sequencer);
        snd_seq_free_queue(sequencer, queue_id);
    }

    if input.sequencer {
        snd_seq_sync_output_queue(sequencer); // @Note: Not sure if this is needed.
        snd_seq_close(sequencer);
    }

    free_input(input);
}

open_output :: (destination_index: int) -> *MIDI_Output {
    result := New(MIDI_Output);
    result.index = -1;

    success := false;
    defer if !success  close_output(result);

    seq_open_result := snd_seq_open(*result.sequencer, "default", SND_SEQ_OPEN_DUPLEX, SND_SEQ_NONBLOCK);
    if seq_open_result < 0 {
        log_error("Could not intialize MIDI client.");
        return null;
    }

    if CLIENT_NAME  snd_seq_set_client_name(result.sequencer, CLIENT_NAME);

    number_of_destinations := get_number_of_destinations();
    if destination_index < 0 || destination_index >= number_of_destinations {
        additional_error_message := ifx number_of_destinations > 0 then tprint("highest available destination index is %", number_of_destinations - 1) else "no output devices are available";
        log_error("Cannot open MIDI output with destination % (%).", destination_index, additional_error_message);
        return null;
    }

    port_info, port_found := get_port_info(result.sequencer, destination_index, source = false);
    if !port_found {
        log_error("Could not find MIDI destination with index %.", destination_index);
        return null;
    }

    our_output_port_number := snd_seq_create_simple_port(result.sequencer, "output", xx (SND_SEQ_PORT_CAP.READ | .SUBS_READ), xx SND_SEQ_PORT_TYPE.APPLICATION);
    if our_output_port_number < 0 {
        log_error("Could not open MIDI port.");
        return null;
    }

    our_client_number := snd_seq_client_id(result.sequencer);

    sender, destination: snd_seq_addr_t;
    sender.client      = xx our_client_number;
    sender.port        = xx our_output_port_number;
    destination.client = xx port_info.client_number;
    destination.port   = xx port_info.port_number;

    connect_result := snd_seq_connect_to(result.sequencer, sender.port, destination.client, destination.port);
    if connect_result < 0 {
        log_error("Could not connect to the MIDI destination.");
        return null;
    }

    result.index = destination_index;
    result.sender = sender;
    result.destination = destination;

    midi_event_result := snd_midi_event_new(result.midi_event_encoder_max_event_size, *result.midi_event_encoder);
    if midi_event_result < 0 {
        log_error("Could not create MIDI event parser.");
        return null;
    }

    log_verbose("Opened output to % %:%.", port_info.client_name, destination.client, destination.port);

    success = true; // Needed in the defer handler!

    return result;
}

close_output :: (output: *MIDI_Output) {
    if output == null  return;

    if output.index >= 0          snd_seq_disconnect_to(output.sequencer, output.sender.port, output.destination.client, output.destination.port);
    if output.midi_event_encoder  snd_midi_event_free(output.midi_event_encoder);
    if output.sequencer           snd_seq_close(output.sequencer);

    free(output);
}

send_midi_message :: (output: *MIDI_Output, message: [] u8) -> bool {
    sender := output.sender;
    destination := output.destination;

    encoder := output.midi_event_encoder;
    snd_midi_event_reset_encode(encoder);

    event: snd_seq_event_t;
    snd_seq_ev_set_source(*event, sender.port);
    snd_seq_ev_set_subs(*event);
    snd_seq_ev_set_direct(*event);

    status := get_status(message[0]);

    if status == .System_Exclusive {
        total_bytes_written: int;
        while total_bytes_written < message.count {
            bytes_written := snd_midi_event_encode(encoder, message.data + total_bytes_written, message.count - total_bytes_written, *event);
            total_bytes_written += bytes_written;
        }

        if cast(snd_seq_event_type) event.type != .SYSEX {
            log_error("System-exclusive message was not encoded properly.");
            return false;
        }
    } else {
        bytes_written := snd_midi_event_encode(encoder, message.data, message.count, *event);

        if cast(snd_seq_event_type) event.type == .NONE {
            log_error("Message was not encoded properly.");
            return false;
        }
    }

    output_result := snd_seq_event_output_direct(output.sequencer, *event);

    return output_result >= 0;
}

MIDI_Input_Platform_Data :: struct {
    sequencer: *snd_seq_t;
    subscription: *snd_seq_port_subscribe_t;
    queue_id: s32;

    thread: Thread;
    thread_start_success: bool;
    thread_start_semaphore: Semaphore;

    union {
        thread_notification_pipe: [2] s32;
        struct {
            thread_notification_pipe_read: s32;
            thread_notification_pipe_write: s32;
        }
    }
}

MIDI_Output_Platform_Data :: struct {
    sequencer: *snd_seq_t;
    subscription: *snd_seq_port_subscribe_t;
    sender: snd_seq_addr_t;
    destination: snd_seq_addr_t;
    midi_event_encoder: *snd_midi_event_t;
    midi_event_encoder_max_event_size: u64 = 16;
}

MIDI_Source_Info :: MIDI_Port_Info;
MIDI_Destination_Info :: MIDI_Port_Info;



#scope_file



with_sequencer :: () -> bool #expand {
    `sequencer: *snd_seq_t;
    result := snd_seq_open(*sequencer, "default", SND_SEQ_OPEN_DUPLEX, SND_SEQ_NONBLOCK);
    if result  return false;
    `defer snd_seq_close(sequencer);
    return true;
}

midi_input_thread :: (thread: *Thread) -> s64 {
    log_verbose("Started MIDI input thread.");

    input := cast(*MIDI_Input) thread.data;
    sequencer := input.sequencer;

    input.thread_start_success = true;

    poll_descriptors_count := snd_seq_poll_descriptors_count(sequencer, POLLIN);
    poll_descriptors := NewArray(poll_descriptors_count + 1, pollfd);
    defer array_free(poll_descriptors);

    snd_seq_poll_descriptors(sequencer, poll_descriptors.data, xx poll_descriptors_count, POLLIN);

    // Add our notification pipe as an additional pollfd.
    poll_descriptors[poll_descriptors_count].fd = input.thread_notification_pipe_read;
    poll_descriptors[poll_descriptors_count].events = POLLIN;
    thread_notification_pollfd := *poll_descriptors[poll_descriptors_count];

    MAX_EVENT_SIZE :: 256; // Apparently ALSA will never return more than 256 bytes per message.
    midi_event_decoder: *snd_midi_event_t;
    midi_event_result := snd_midi_event_new(MAX_EVENT_SIZE, *midi_event_decoder);
    if midi_event_result < 0  input.thread_start_success = false;
    midi_data_buffer: [MAX_EVENT_SIZE] u8;

    signal(*input.thread_start_semaphore); // Signal to the main thread that we have set input.thread_start_success; if false, we shutdown the thread.
    if !input.thread_start_success  return -1;

    defer snd_midi_event_free(midi_event_decoder);

    // @TODO: It seems that we can receive MIDI messages here that were sent before our input even opened due to ALSA
    // buffering them internally. I have no idea how to prevent this. The promisingly named 'snd_seq_drop_input'
    // function doesn't seem to do the trick, and neither have other things I've tried. There must be some way to tell
    // ALSA to drop all pending inputs for our subscription or whatever before we start polling for events here?

    while poll(poll_descriptors.data, xx poll_descriptors.count, -1) >= 0 {
        while snd_seq_event_input_pending(sequencer, 1) > 0 {
            event: *snd_seq_event_t;
            snd_seq_event_input(sequencer, *event);

            if event == null  continue;

            snd_midi_event_reset_decode(midi_event_decoder);

            number_of_bytes := snd_midi_event_decode(midi_event_decoder, midi_data_buffer.data, midi_data_buffer.count, event);
            if number_of_bytes < 0 {
                if -number_of_bytes == {
                    case EINVAL;  log_error("Received an invalid sequencer event.");
                    case ENOENT;  log_error("Event is not a valid MIDI message.");
                    case ENOMEM;  log_error("Given buffer is too small.");
                }

                continue;
            }

            midi_event_bytes: [] u8 = ---;
            midi_event_bytes.data = midi_data_buffer.data;
            midi_event_bytes.count = number_of_bytes;

            timestamp := seconds_to_apollo(event.time.time.tv_sec) + nanoseconds_to_apollo(event.time.time.tv_nsec);
            decode_midi_packet(input, midi_event_bytes, timestamp);
        }

        if thread_notification_pollfd.revents & POLLIN { // Our own event to stop the thread.
            dummy: u8;
            read(thread_notification_pollfd.fd, *dummy, 1);
            assert(dummy == 0xcd); // Sanity check the payload.
            log_verbose("Stopping MIDI input thread.");
            snd_seq_drop_input(sequencer);
            break;
        }
    }

    return 0;
}

MIDI_Port_Info :: struct {
    client_name: string;
    client_number: int;
    port_name: string;
    port_number: int;
    port_capability: SND_SEQ_PORT_CAP;
    port_type: SND_SEQ_PORT_TYPE;
    number_of_midi_channels: s32;
    number_of_midi_voices: s32;
    number_of_synth_voices: s32;
    number_of_read_subscriptions: s32;
    number_of_write_subscriptions: s32;
    port_specified: bool;
    timestamping: bool;
    timestamping_realtime_mode: bool;
    timestamp_queue_id: s32;
}

get_port_info :: (sequencer: *snd_seq_t, index: int, source: bool) -> MIDI_Port_Info, bool {
    result: MIDI_Port_Info;
    current_index: int;
    client_info: *snd_seq_client_info_t;
    snd_seq_client_info_malloc(*client_info);
    defer snd_seq_client_info_free(client_info);

    snd_seq_client_info_set_client(client_info, -1);
    while snd_seq_query_next_client(sequencer, client_info) >= 0 {
        client_number := snd_seq_client_info_get_client(client_info);
        port_info: *snd_seq_port_info_t;
        snd_seq_port_info_malloc(*port_info);
        defer snd_seq_port_info_free(port_info);

        snd_seq_port_info_set_client(port_info, client_number);
        snd_seq_port_info_set_port(port_info, -1);
        while snd_seq_query_next_port(sequencer, port_info) >= 0 {
            port_number := snd_seq_port_info_get_port(port_info);
            port_name := snd_seq_port_info_get_name(port_info);
            port_capability := cast(SND_SEQ_PORT_CAP) snd_seq_port_info_get_capability(port_info);
            port_type := snd_seq_port_info_get_type(port_info);

            if source && (port_capability & (SND_SEQ_PORT_CAP.READ | .SUBS_READ)) {
                current_index += 1;
            } else if (port_capability & (SND_SEQ_PORT_CAP.WRITE | .SUBS_WRITE)) {
                current_index += 1;
            }

            if current_index - 1 == index {
                client_name := snd_seq_client_info_get_name(client_info);
                result.client_name = copy_temporary_string(to_string(client_name));
                result.port_name = copy_temporary_string(to_string(port_name));
                result.client_number = client_number;
                result.port_number = port_number;

                result.port_capability = xx port_capability;
                result.port_type = xx port_type;

                result.number_of_midi_channels = snd_seq_port_info_get_midi_channels(port_info);
                result.number_of_midi_voices = snd_seq_port_info_get_midi_voices(port_info);
                result.number_of_synth_voices = snd_seq_port_info_get_synth_voices(port_info);
                result.number_of_read_subscriptions = snd_seq_port_info_get_read_use(port_info);
                result.number_of_write_subscriptions = snd_seq_port_info_get_write_use(port_info);
                result.port_specified = snd_seq_port_info_get_port_specified(port_info) == 1;
                result.timestamping = snd_seq_port_info_get_timestamping(port_info) == 1;
                result.timestamping_realtime_mode = snd_seq_port_info_get_timestamp_real(port_info) == 1;
                result.timestamp_queue_id = snd_seq_port_info_get_timestamp_queue(port_info);

                return result, true;
            }
        }
    }

    return result, false;
}

get_port_count :: (sequencer: *snd_seq_t, source := true) -> int {
    result: int;
    client_info: *snd_seq_client_info_t;
    snd_seq_client_info_malloc(*client_info);
    defer snd_seq_client_info_free(client_info);

    snd_seq_client_info_set_client(client_info, -1);
    while snd_seq_query_next_client(sequencer, client_info) >= 0 {
        client_number := snd_seq_client_info_get_client(client_info);
        port_info: *snd_seq_port_info_t;
        snd_seq_port_info_malloc(*port_info);
        defer snd_seq_port_info_free(port_info);

        snd_seq_port_info_set_client(port_info, client_number);
        snd_seq_port_info_set_port(port_info, -1);
        while snd_seq_query_next_port(sequencer, port_info) >= 0 {
            port_number := snd_seq_port_info_get_port(port_info);
            port_capability := cast(SND_SEQ_PORT_CAP) snd_seq_port_info_get_capability(port_info);
            port_type := snd_seq_port_info_get_type(port_info);

            if source && (port_capability & (SND_SEQ_PORT_CAP.READ | .SUBS_READ)) {
                result += 1;
            } else if (port_capability & (SND_SEQ_PORT_CAP.WRITE | .SUBS_WRITE)) {
                result += 1;
            }
        }
    }

    return result;
}

#load "bindings/linux.jai";
