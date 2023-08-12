get_number_of_sources :: () -> int {
    return midiInGetNumDevs();
}

get_number_of_destinations :: () -> int {
    return midiOutGetNumDevs();
}

get_source_info :: (index: int) -> MIDI_Source_Info, bool {
    result: MIDI_Source_Info;
    mmresult := midiInGetDevCaps(cast(u64) index, xx *result, size_of(MIDIINCAPS));
    if mmresult != .NOERROR {
        log_error("Error getting information on source % (%).", index, mmresult);
        return result, false;
    }
    return result, true;
}

get_destination_info :: (index: int) -> MIDI_Destination_Info, bool {
    result: MIDI_Destination_Info;
    mmresult := midiOutGetDevCaps(cast(u64) index, xx *result, size_of(MIDIOUTCAPS));
    if mmresult != .NOERROR {
        log_error("Error getting information on destination % (%).", index, mmresult);
        return result, false;
    }
    return result, true;
}

get_source_name :: (index: int) -> string {
    source_info, success := get_source_info(index);
    if success  return copy_string(to_string(source_info.product_name.data), temp);
    return "";
}

get_destination_name :: (index: int) -> string {
    destination_info, success := get_destination_info(index);
    if success  return copy_string(to_string(destination_info.product_name.data), temp);
    return "";
}

open_input :: (source_index: int, callback: MIDI_Input_Callback, user_data: *void = null) -> *MIDI_Input #must {
    result := New(MIDI_Input);
    success := false;
    defer if !success  close_input(result);

    number_of_available_sources := midiInGetNumDevs();
    if source_index < 0 || source_index >= number_of_available_sources {
        additional_error_message := ifx number_of_available_sources > 0 then tprint("highest available source index is %", number_of_available_sources - 1) else "no sources are available";
        log_error("Cannot open MIDI input for source % (%).", source_index, additional_error_message);
        return null;
    }

    result.index = source_index;
    result.callback = callback;
    result.callback_data = user_data;

    open_result := midiInOpen(*result.handle, cast(u32) source_index, cast(u64) cast(*void) midi_input_callback, cast(u64) result, CALLBACK_FUNCTION);
    if error_in(open_result, "Unable to open MIDI device for input")  return null;

    sysex_buffer_result := init_sysex_buffers(result);
    if error_in(sysex_buffer_result, "Could not initialize buffers for system-exclusive messages.")  return null;

    start_result := midiInStart(result.handle);
    if error_in(start_result, "Unable to start MIDI input")  return null;

    success = true; // Needed in the defer handler!

    return result;
}

close_input :: (input: *MIDI_Input) {
    if input == null  return;
    index := input.index;
    stop_result := midiInStop(input.handle);
    reset_result := midiInReset(input.handle);
    deinit_sysex_buffers(input);
    close_result := midiInClose(input.handle);
    free_input(input);
}

open_output :: (destination_index: int) -> *MIDI_Output #must {
    number_of_available_outputs := midiOutGetNumDevs();
    if destination_index < 0 || destination_index >= number_of_available_outputs {
        additional_error_message := ifx number_of_available_outputs > 0 then tprint("highest available destination index is %", number_of_available_outputs - 1) else "no destinations are available";
        log_error("Cannot open MIDI output for destination % (%).", destination_index, additional_error_message);
        return null;
    }

    result := New(MIDI_Output);
    result.index = destination_index;
    out_result := midiOutOpen(*result.handle, cast(u32) destination_index, 0, 0, CALLBACK_NULL);
    if error_out(out_result, "Unable to open MIDI device for output") {
        close_output(result);
        return null;
    }

    return result;
}

close_output :: (output: *MIDI_Output) {
    if output == null  return;
    index := output.index;
    mmresult := midiOutClose(output.handle);
    if mmresult != .NOERROR  log_error("Error closing MIDI output: %.", mmresult);
    free(output);
}

send_midi_message :: (output: *MIDI_Output, message: [] u8) -> bool {
    if message.count == 0  return false;

    if get_status(message[0]) == .System_Exclusive {
        header: MIDIHDR;
        header.lpData = message.data;
        header.dwBufferLength = xx message.count;

        prepare_header_result := midiOutPrepareHeader(output.handle, *header, size_of(MIDIHDR));
        if error_out(prepare_header_result)  return false;

        long_msg_result := midiOutLongMsg(output.handle, *header, size_of(MIDIHDR));
        if error_out(long_msg_result)  return false;

        unprepare_header_result := midiOutUnprepareHeader(output.handle, *header, size_of(MIDIHDR));

        // Wait for device driver to finish with message, if necessary.
        while xx unprepare_header_result == MIDIERR.STILLPLAYING {
            sleep_milliseconds(1);
            unprepare_header_result = midiOutUnprepareHeader(output.handle, *header, size_of(MIDIHDR));
        }

        return !error_out(unprepare_header_result);
    }

    word := (cast(*u32) message.data).*;
    out_result := midiOutShortMsg(output.handle, word);
    return !error_out(out_result);
}

MIDI_Input_Platform_Data :: struct {
    handle: HMIDIIN;
    callback_context: Context;
    sysex_buffer_headers: [SYSEX_BUFFER_COUNT] MIDIHDR;
    sysex_buffers: [SYSEX_BUFFER_COUNT] [SYSEX_BUFFER_SIZE] u8;
}

MIDI_Output_Platform_Data :: struct {
    handle: HMIDIOUT;
}

MIDI_Source_Info :: struct {
    manufacturer_id: u16;
    product_id: u16;
    driver_version: MMVERSION;
    product_name: [MAXPNAMELEN] u8;
    support: MIDICAPS;
}

MIDI_Destination_Info :: struct {
    manufacturer_id: u16;
    product_id: u16;
    driver_version: MMVERSION;
    product_name: [MAXPNAMELEN] u8;
    technology: MOD;
    voices: u16;
    notes: u16;
    channel_mask: u16;
    support: MIDICAPS;
}

#assert size_of(MIDIINCAPS) == size_of(MIDI_Source_Info);
#assert size_of(MIDIOUTCAPS) == size_of(MIDI_Destination_Info);

#scope_file

// We could make these user-configurable?
SYSEX_BUFFER_COUNT :: 16;
SYSEX_BUFFER_SIZE  :: 1024;

midi_input_callback :: (handle: HMIDIIN, msg: MIM, instance: *void, param1: u64, param2: u64) #c_call {
    input := cast(*MIDI_Input) instance;

    push_context input.callback_context {
        // @Note: If we get an OPEN message, the MIDI_Input struct will not have its handle set yet. We could set it
        // here if we ever want to notify people of events like these.

        midi_event_bytes: [] u8;
        timestamp := milliseconds_to_apollo(cast(s64) param2);

        if msg == {
            // Regular MIDI message.
            case .DATA; {
                midi_event_bytes.data = cast(*u8) *param1;
                midi_event_bytes.count = 3; // Messages received here always have a status byte.
            }

            case .ERROR; {
                log_error("An invalid MIDI message was received by the driver.");
            }

            // System-exclusive message.
            case .LONGDATA; {
                header := cast(*MIDIHDR) param1;
                midi_event_bytes.data = xx header.lpData;
                midi_event_bytes.count = header.dwBytesRecorded;
            }

            case .LONGERROR; {
                log_error("An invalid or incomplete system-exclusive message was received by the driver.");
                reset_system_exclusive_buffer(*input.decoder);
            }

            // case .OPEN; // Input is opened.
            // case .CLOSE; // Input is closed.
        }

        if midi_event_bytes.count > 0 {
            message, message_decoded := decode_midi_packet(*input.decoder, midi_event_bytes);
            if message_decoded {
                post_message_to_input(input, message, timestamp);

                if message.status == .System_Exclusive {
                    // @Note: Windows seems to send zero-length LONGDATA messages when the input closes. We should *not*
                    // call reset_sysex_buffers in that case, or bad things will happen!
                    if midi_event_bytes.count > 0  reset_sysex_buffers(input);
                }
            }
        }
    }
}

init_sysex_buffers :: (input: *MIDI_Input) -> MMRESULT {
    for 0..input.sysex_buffers.count - 1 {
        header := *input.sysex_buffer_headers[it];
        buffer := *input.sysex_buffers[it];

        header.* = .{}; // Clear header struct.
        header.lpData = buffer.data;
        header.dwBufferLength = xx buffer.count;

        prepare_header_result := midiInPrepareHeader(input.handle, header, size_of(MIDIHDR));
        if prepare_header_result != .NOERROR {
            log_error("Error in midiInPrepareHeader.");
            return prepare_header_result;
        }

        add_buffer_result := midiInAddBuffer(input.handle, header, size_of(MIDIHDR));
        if add_buffer_result != .NOERROR {
            log_error("Error in midiInAddBuffer.");
            return add_buffer_result;
        }
    }

    return .NOERROR;
}

reset_sysex_buffers :: (input: *MIDI_Input) -> bool {
    success := true;

    for 0..input.sysex_buffers.count - 1 {
        header := *input.sysex_buffer_headers[it];
        buffer := *input.sysex_buffers[it];

        if header.dwFlags & .DONE {
            header.dwBytesRecorded = 0;

            // @Note: According to Microsoft, you are not supposed to call multimedia functions from the callback
            // provided to midiInOpen. We *are* doing that here, since we need to 're-add' the internal buffer that was
            // used when we receive a system-exclusive message in our callback (otherwise the driver won't use that
            // buffer anymore). My impression is that this used to be a problem in older Windows versions, but is okay
            // with the current MIDI driver; plenty of other implementations seem to do this as well. The alternative
            // would be to have a dedicated thread monitoring the state of the MIDIHDRs and re-add buffers when
            // necessary, but... bleh.
            add_buffer_result := midiInAddBuffer(input.handle, header, size_of(MIDIHDR));
            if add_buffer_result != .NOERROR {
                assert(false, "Error in midiInAddBuffer.");
                success = false;
                continue; // @TODO: Not sure what would be the best way of handling this.
            }
        }
    }

    return success;
}

deinit_sysex_buffers :: (input: *MIDI_Input) -> bool {
    success := true;

    for 0..input.sysex_buffers.count - 1 {
        header := *input.sysex_buffer_headers[it];
        buffer := *input.sysex_buffers[it];

        if header.dwFlags & .PREPARED {
            unprepare_header_result := midiInUnprepareHeader(input.handle, header, size_of(MIDIHDR));

            // @Robustness: Put a cap on how long we wait here?
            while xx unprepare_header_result == MIDIERR.STILLPLAYING {
                unprepare_header_result = midiInUnprepareHeader(input.handle, header, size_of(MIDIHDR));
            }

            if unprepare_header_result != .NOERROR {
                log_error("Error in midiOutUnprepareHeader.");
                success = false;
                continue;
            }
        }
    }

    return success;
}

error_in  :: #bake_arguments _error(midi_in = true);
error_out :: #bake_arguments _error(midi_in = false);

_error :: (result: MMRESULT, message: string = "", $midi_in: bool) -> bool {
    if result != .NOERROR {
        buffer: [512] u8;
        #if midi_in  error_text_result := midiInGetErrorText(result, buffer.data, buffer.count);
        else         error_text_result := midiOutGetErrorText(result, buffer.data, buffer.count);

        if message {
            if error_text_result == .NOERROR  log_error("%: % (%)", message, to_string(buffer.data), result);
            else                              log_error("% (%)", message, result);
        } else {
            if error_text_result == .NOERROR  log_error("% (%)", to_string(buffer.data), result);
            else                              log_error("%", result);
        }

        return true;
    }

    return false;
}

#load "bindings/windows.jai";
