// This file provides basic support for reading MIDI files. Variable-length arrays are used to store tracks and their
// events. Each event is represented by a MIDI_File_Event struct, which contains either a regular MIDI_Message, or a
// MIDI_Meta_Event with an associated Meta_Event_Type and a byte buffer containing its data.

MIDI_File :: struct {
    content: string;
    format: u16;
    time_division: u16;
    tracks: [..] MIDI_Track;
}

MIDI_Track :: struct {
    events: [..] MIDI_File_Event;
}

MIDI_File_Event :: struct {
    is_meta_event: bool;
    delta_time: u32;
    union {
        midi_event: MIDI_Message;
        meta_event: MIDI_Meta_Event;
    }
}

MIDI_Meta_Event :: struct {
    type: MIDI_Meta_Event_Type;
    buffer: [] u8;
}

MIDI_Meta_Event_Type :: enum u8 {
    Sequence_Number               :: 0x00;
    Text_Event                    :: 0x01;
    Copyright_Notice              :: 0x02;
    Sequence_Or_Track_Name        :: 0x03;
    Instrument_Name               :: 0x04;
    Lyric                         :: 0x05;
    Marker                        :: 0x06;
    Cue_Point                     :: 0x07;
    Channel_Prefix                :: 0x20;
    End_Of_Track                  :: 0x2f;
    Set_Tempo                     :: 0x51;
    SMPTE_Offset                  :: 0x54;
    Time_Signature                :: 0x58;
    Key_Signature                 :: 0x59;
    Sequencer_Specific_Meta_Event :: 0x7f;
}

read_midi_file :: (file_path: string) -> MIDI_File, bool {
    result: MIDI_File;

    file_content, read_success := read_entire_file(file_path);
    if !read_success  return result, false;

    result.content = file_content;

    // Read header chunk.
    cursor := result.content.data;
    if file_content.count < 14 || !is_header_type(cursor) {
        log_error("File did not start with a valid MIDI header chunk.");
        return result, false;
    }

    cursor += 4;
    header_length := read_big_endian(cursor, u32);
    result.format = read_big_endian(cursor + 4, u16);
    number_of_track_chunks := read_big_endian(cursor + 6, u16);
    result.time_division = read_big_endian(cursor + 8, u16);
    cursor += size_of(u32) + header_length;

    for 0..number_of_track_chunks - 1 {
        // Read track chunk.
        if !is_track_type(cursor) {
            log_error("Expected a MIDI track chunk, but we did not find it.");
            return result, false;
        }

        track: MIDI_Track;

        cursor += 4;
        chunk_length := read_big_endian(cursor, u32);
        cursor += size_of(u32);

        running_status: u8;
        event_cursor := cursor;
        event_index := 0;

        while event_cursor - cursor < chunk_length {
            // Read event list.
            delta_time, delta_time_bytes_read := read_variable_length_quantity(event_cursor);
            assert(delta_time_bytes_read > 0, "Invalid event.");
            event_cursor += delta_time_bytes_read;
            event_index += 1;

            event: MIDI_File_Event;
            event.delta_time = delta_time;

            first_byte := read(event_cursor, u8);
            event_cursor += 1;
            message: MIDI_Message;
            status_byte := first_byte;

            if !(status_byte & 0x80) {
                assert(running_status != 0, "Received event with no status byte, but no running status has been set.");
                status_byte = running_status;
                event_cursor -= 1;
            }

            if status_byte < 0xf0 {
                message.status = cast(MIDI_Status) (status_byte & 0xf0);
                message.channel = status_byte & 0x0f;
            } else {
                message.status = cast(MIDI_Status) status_byte;
            }

            if message.status == {
                case .End_Of_System_Exclusive; #through;
                case .System_Exclusive; {
                    message_length, message_length_bytes_read := read_variable_length_quantity(event_cursor);
                    assert(message_length_bytes_read > 0, "Invalid system-exclusive message.");
                    event_cursor += message_length_bytes_read;
                    message.system_exclusive_info.buffer.data = event_cursor;
                    message.system_exclusive_info.buffer.count = message_length;
                    event_cursor += message_length;
                    event.midi_event = message;
                    running_status = 0;
                }

                case .System_Reset; { // This means a meta-event in the context of a MIDI file.
                    type := cast(MIDI_Meta_Event_Type) event_cursor.*;
                    event_cursor += 1;
                    message_length, message_length_bytes_read := read_variable_length_quantity(event_cursor);
                    assert(message_length_bytes_read > 0, "Invalid meta-event.");
                    event_cursor += message_length_bytes_read;
                    event.is_meta_event = true;
                    event.meta_event.type = type;
                    event.meta_event.buffer.data = event_cursor;
                    event.meta_event.buffer.count = message_length;
                    event_cursor += message_length;
                    running_status = 0;
                }

                case; { // Regular MIDI event.
                    bytes_to_read := 2;
                    if message.status == .Program_Change || message.status == .Channel_Pressure  bytes_to_read = 1;
                    for 0..bytes_to_read - 1  message.bytes[it] = (event_cursor + it).*;
                    event_cursor += bytes_to_read;
                    event.midi_event = message;
                    running_status = status_byte;
                }
            }

            array_add(*track.events, event);
        }

        cursor += chunk_length;

        array_add(*result.tracks, track);
    }

    return result, true;
}

#scope_file

read_variable_length_quantity :: (cursor: *u8) -> u32, int {
    result: u32;

    byte_pointer := cursor;
    while true {
        assert(byte_pointer - cursor < 4, "Variable-length quantities cannot be more than 4 bytes long.");
        byte := byte_pointer.*;
        result |= (byte & 0x7f);
        byte_pointer += 1;
        if !(byte & 0x80)  break;
        result <<= 7;
    }

    return result, byte_pointer - cursor;
}

read :: (pointer: *u8, $T: Type) -> T #expand {
    return (cast(*T) pointer).*;
}

read_big_endian :: (pointer: *u8, $T: Type) -> T #expand {
    return byte_swap(read(pointer, T));
}

is_header_type :: (type: *u8) -> bool #expand {
    return type[0] == #char "M" && type[1] == #char "T" && type[2] == #char "h" && type[3] == #char "d";
}

is_track_type :: (type: *u8) -> bool #expand {
    return type[0] == #char "M" && type[1] == #char "T" && type[2] == #char "r" && type[3] == #char "k";
}

#import "File";
#import "Bit_Operations";
