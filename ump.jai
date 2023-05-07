/*

- UMP uses 16 'groups', which each have independent system messages and (16) channels.

- Optional: per-packet jitter reduction timestamp prepended to message.

- Each UMP consists of 1, 2, 3, or 4 u32s.
- Each UMP contains one entire MIDI message (except for Data Messages longer than 128 bits).
- Each UMP contains a message type (4 bits), group (4 bits), and status field.
- UMPs addressed to different groups may be freely interleaved.

- Each group can select which version of the MIDI protocol to use independently.

- For MIDI 2.0 note on messages, a velocity of 0 does not mean 'note off'. When translating to MIDI 1.0, use a note on
  message with a velocity of 1 instead of 0.

- For MIDI 1.0 style system-exclusive messages, the start/end (0xf0/0xf7) bytes are not included in the payload in UMP.

*/

make_ump_word :: (message_type: UMP_Message_Type, group: u32, status_channel: u32, data1: u32, data2: u32) -> u32 #expand {
    result: u32;
    result = ((cast(u8) message_type << 4) | (group & 0xf)) << 24;
    result |= status_channel << 16;
    result |= (data1 & 0x7f) << 8;
    result |= data2 & 0x7f;
    return result;
}

decode_ump_words :: (decoder: *MIDI_Decoder, words: *[] u32) -> MIDI_Message, bool {
    if words.count == 0  return .{}, false;

    word := words.data[0];
    message_type := cast(UMP_Message_Type) (word >> 28);
    group := (word >> 24) & 0xf;

    num_words_decoded := 1;

    defer {
        words.data += num_words_decoded;
        words.count -= num_words_decoded;
    }

    if message_type == {
        case .Utility; {
            status_byte := cast(u8) ((word >> 20) & 0xf);
            // @Incomplete: Currently not handled.
        }

        case .System_Common_Or_Real_Time; #through;
        case .MIDI_1_Voice; {
            bytes: [3] u8;
            bytes[0] = cast(u8) ((word >> 16) & 0xff); // Status.
            bytes[1] = cast(u8) ((word >>  8) & 0xff); // Data byte 1.
            bytes[2] = cast(u8) ((word >>  0) & 0xff); // Data byte 2.

            message, message_decoded := decode_midi_packet(decoder, bytes);
            return message, message_decoded;
        }

        case .Data; {
            status_byte               := cast(u8) ((word >> 20) & 0xf);
            number_of_bytes_in_packet := cast(u8) ((word >> 16) & 0xf);
            status := cast(UMP_System_Exclusive_Status) status_byte;

            assert(number_of_bytes_in_packet <= 6, "Unexpected number of bytes in data packet (expected at most 6, got %).", number_of_bytes_in_packet);

            data_bytes: [8] u8;
            data_bytes_cursor := data_bytes.data;

            if status == {
                case .Complete; {
                    assert(!decoder.system_exclusive_message_in_progress);
                    <<data_bytes_cursor = cast(u8) MIDI_Status.System_Exclusive;
                    data_bytes_cursor += 1;
                }
                case .Start; {
                    <<data_bytes_cursor = cast(u8) MIDI_Status.System_Exclusive;
                    data_bytes_cursor += 1;
                }
                case .Continue; {
                    assert(decoder.system_exclusive_message_in_progress);
                }
            }

            <<(data_bytes_cursor + 0) = cast(u8) ((word >> 8) & 0xff);
            <<(data_bytes_cursor + 1) = cast(u8) ((word >> 0) & 0xff);

            if number_of_bytes_in_packet > 2 {
                word = words.data[1];
                <<(data_bytes_cursor + 2) = cast(u8) ((word >> 24) & 0xff);
                <<(data_bytes_cursor + 3) = cast(u8) ((word >> 16) & 0xff);
                <<(data_bytes_cursor + 4) = cast(u8) ((word >>  8) & 0xff);
                <<(data_bytes_cursor + 5) = cast(u8) ((word >>  0) & 0xff);
                num_words_decoded += 1;
            }

            data_bytes_cursor += number_of_bytes_in_packet;

            if status == .End {
                <<data_bytes_cursor = cast(u8) MIDI_Status.End_Of_System_Exclusive;
                data_bytes_cursor += 1;
            }

            bytes: [] u8 = ---;
            bytes.data = data_bytes.data;
            bytes.count = data_bytes_cursor - data_bytes.data;

            message, message_decoded := decode_midi_packet(decoder, bytes);
            return message, message_decoded;
        }

        case; {
            assert(false, "Messages of type % are not currently supported.", message_type);
        }
    }

    return .{}, false;
}

UMP_Message_Type :: enum u8 {
    Utility                    :: 0x0;
    System_Common_Or_Real_Time :: 0x1; // Messages are always 32-bit.
    MIDI_1_Voice               :: 0x2; // Messages are always 32-bit. MIDI 1.0 only.
    Data                       :: 0x3; // Messages are 32-bit or 64-bit.
    MIDI_2_Voice               :: 0x4; // Messages are always 64-bit. MIDI 2.0 only.
    Data_128                   :: 0x5;
}

// Statuses used for 7-bit system-exclusive messages in UMPs.
UMP_System_Exclusive_Status :: enum u8 {
    Complete :: 0x0;
    Start    :: 0x1;
    Continue :: 0x2;
    End      :: 0x3;
}

UMP_Utility_Status :: enum u8 {
    Noop                       :: 0x0;
    Jitter_Reduction_Clock     :: 0x1;
    Jitter_Reduction_Timestamp :: 0x2;
}

#import "Bit_Operations"; // For byte_swap.
