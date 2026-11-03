//
// Tests for regular MIDI messages: voice messages (note off and on, polyphonic and channel pressure, control and
// program changes, pitch bend), system common messages (time code, song position pointer, song select, tune request)
// and system realtime messages. System-exclusive messages have their own tests in sysex_tests.jai.
//
// Part 1 needs no MIDI hardware. It tests creating and encoding messages, the pitch bend helpers, the byte-stream
// decoder that every platform uses (including running status), the path that delivers messages from a MIDI_Input to its
// callback, and the Universal MIDI Packet (UMP) decoder that is used on macOS.
//
// Part 2 sends every type of message through a loopback and checks that it arrives unchanged:
//
//   - Windows: a loopback driver such as loopMIDI. By default a port whose name contains "loopMIDI" is used.
//   - Linux:   the ALSA 'Midi Through' port (snd-seq-dummy), which is present on most systems.
//   - macOS:   a virtual input created by the test itself, which the test then opens as an output.
//
// You can pass a different (partial) endpoint name as the first argument; it is used to find both the source and the
// destination. If no loopback is found, part 2 is skipped. Build and run the tests with:
//
//   jai tests/message_tests.jai
//   ./message_tests [loopback_name]
//
// Some of these tests describe behavior the module doesn't have yet, so not all of them pass. Each test states the
// intended behavior. Assertions inside the module are recorded instead of stopping the program, so one failure doesn't
// hide the others.
//

VERBOSE_LOGGING :: false;
CLIENT_NAME     :: "jai-midi-message-test";

// Loaded rather than imported, so that the tests can reach the encoder and decoder, which are internal to the module.
#load "../midi.jai";
#if OS != .MACOS {
    #load "../ump.jai"; // On macOS, the platform layer already loads this.
}

#import "Atomics";
#import "Math";

#if OS == .WINDOWS {
    DEFAULT_LOOPBACK_NAME :: "loopMIDI";
} else #if OS == .LINUX {
    DEFAULT_LOOPBACK_NAME :: "Midi Through";
} else {
    DEFAULT_LOOPBACK_NAME :: "jai-midi message test";
}

main :: () {
    context.assertion_failed = recording_assertion_handler;

    #if 1 {
        print("\n----- Creating and encoding -----\n");

        run_test("Number of data bytes per status",                 test_number_of_data_bytes);
        run_test("create_midi_message",                             test_create_midi_message);
        run_test("create_midi_message rejects invalid values",      test_create_rejects_invalid_values);
        run_test("create_control_change_message",                   test_create_control_change_message);
        run_test("Encoding every type of message",                  test_encode_every_type);
        run_test("Encoding every channel",                          test_encode_every_channel);
        run_test("Encoding rejects invalid channels",               test_encode_rejects_invalid_channels);
        run_test("Status bytes",                                    test_status_bytes);
        run_test("Status classes",                                  test_status_classes);
        run_test("Undefined status bytes",                          test_undefined_status_bytes);
        run_test("14-bit values",                                   test_14_bit_values);
        run_test("Pitch bend from an integer",                      test_pitch_bend_from_int);
        run_test("Pitch bend from an integer out of range",         test_pitch_bend_from_int_out_of_range);
        run_test("Pitch bend from a float",                         test_pitch_bend_from_float);
        run_test("Pitch bend as a float",                           test_pitch_bend_get_float);
        run_test("Pitch bend round trips",                          test_pitch_bend_round_trips);
    }

    #if 1 {
        print("\n----- Decoder tests -----\n");

        run_test("Decoding every type of message",                  test_decode_every_type);
        run_test("Decoded messages through their named fields",     test_decode_named_fields);
        run_test("Decoding every channel",                          test_decode_every_channel);
        run_test("Smallest and largest data bytes",                 test_decode_data_byte_range);
        run_test("Note-on with velocity 0",                         test_decode_note_on_velocity_zero);
        run_test("Packets padded to 3 bytes",                       test_decode_padded_packets);
        run_test("Empty packet",                                    test_decode_empty_packet);
        run_test("Packets with too few data bytes",                 test_decode_truncated_packets);
        run_test("Status byte where a data byte is expected",       test_decode_status_byte_as_data);
        run_test("Undefined status bytes",                          test_decode_undefined_status_bytes);
        run_test("Running status",                                  test_running_status);
        run_test("Running status with one data byte",               test_running_status_one_data_byte);
        run_test("Running status replaced by a new status",         test_running_status_replaced);
        run_test("Running status kept across realtime messages",    test_running_status_kept_by_realtime);
        run_test("Running status cancelled by system common",       test_running_status_cancelled_by_system_common);
        run_test("System messages do not set running status",       test_running_status_not_set_by_system_messages);
        run_test("Data bytes without running status",               test_data_without_running_status);
        run_test("Delivery through an input",                       test_delivery_through_input);

        run_test("UMP: voice messages",                             test_ump_voice_messages);
        run_test("UMP: system messages",                            test_ump_system_messages);
        run_test("UMP: group is ignored",                           test_ump_group_ignored);
        run_test("UMP: several messages in one list",               test_ump_several_messages);
        run_test("UMP: utility messages",                           test_ump_utility_messages);
        run_test("UMP: other message types are skipped",            test_ump_other_message_types_skipped);
    }

    #if 1 {
        print("\n----- Loopback tests -----\n");

        args := get_command_line_arguments();
        use_virtual_endpoint := OS == .MACOS && args.count < 2;
        loopback_name := ifx args.count > 1 then args[1] else DEFAULT_LOOPBACK_NAME;
        run_loopback_tests(loopback_name, use_virtual_endpoint);
    }

    print("\n% checks passed, % failed.\n", passed_checks, failed_checks);
    if failed_checks  exit(1);
}

//
// Test data.
//

Message_Case :: struct {
    status: MIDI_Status;
    channel: u8;
    data0: u8;
    data1: u8;
    encoded: [] u8;
}

// One or more messages of every type other than system-exclusive, with their encoding.
MESSAGE_CASES :: Message_Case.[
    // Voice messages.
    .{.Note_Off,              3,  0x3d, 0x70, u8.[0x83, 0x3d, 0x70]},
    .{.Note_On,               12, 0x1b, 0x60, u8.[0x9c, 0x1b, 0x60]},
    .{.Polyphonic_Pressure,   1,  0x19, 0x6f, u8.[0xa1, 0x19, 0x6f]},
    .{.Control_Change,        10, 0x0a, 0x43, u8.[0xba, 0x0a, 0x43]},
    .{.Program_Change,        0,  0x12, 0x00, u8.[0xc0, 0x12]},
    .{.Program_Change,        15, 0x7f, 0x00, u8.[0xcf, 0x7f]},
    .{.Channel_Pressure,      2,  0x5b, 0x00, u8.[0xd2, 0x5b]},
    .{.Pitch_Bend,            6,  0x7f, 0x4f, u8.[0xe6, 0x7f, 0x4f]},
    .{.Pitch_Bend,            15, 0x00, 0x40, u8.[0xef, 0x00, 0x40]},

    // System common messages.
    .{.Time_Code,             0,  0x36, 0x00, u8.[0xf1, 0x36]},
    .{.Song_Position_Pointer, 0,  0x01, 0x7f, u8.[0xf2, 0x01, 0x7f]},
    .{.Song_Select,           0,  0x42, 0x00, u8.[0xf3, 0x42]},
    .{.Tune_Request,          0,  0x00, 0x00, u8.[0xf6]},

    // System realtime messages.
    .{.Timing_Clock,          0,  0x00, 0x00, u8.[0xf8]},
    .{.Start,                 0,  0x00, 0x00, u8.[0xfa]},
    .{.Continue,              0,  0x00, 0x00, u8.[0xfb]},
    .{.Stop,                  0,  0x00, 0x00, u8.[0xfc]},
    .{.Active_Sensing,        0,  0x00, 0x00, u8.[0xfe]},
    .{.System_Reset,          0,  0x00, 0x00, u8.[0xff]},
];

VOICE_STATUSES :: MIDI_Status.[.Note_Off, .Note_On, .Polyphonic_Pressure, .Control_Change, .Program_Change, .Channel_Pressure, .Pitch_Bend];

// Status bytes that MIDI 1.0 leaves undefined: two system common and two realtime ones.
UNDEFINED_STATUS_BYTES :: u8.[0xf4, 0xf5, 0xf9, 0xfd];

//
// Part 1: creating and encoding messages.
//

test_number_of_data_bytes :: () {
    for enum_values_as_enum(MIDI_Status) {
        if it == .Invalid || it == .System_Exclusive  continue;
        actual := number_of_data_bytes(it);
        check(actual == data_byte_count(it), "% messages have % data bytes, but % were expected.", it, actual, data_byte_count(it));
    }
}

test_create_midi_message :: () {
    for MESSAGE_CASES {
        message := create_midi_message(it.status, it.data0, it.data1, it.channel);
        check_message(message, expected_message(it), tprint("created % message", it.status));
    }
}

// Data bytes above 0x7f and channels above 15 cannot be encoded, and system messages have no channel. These mistakes
// must be caught when the message is created, not only later when it is sent.
test_create_rejects_invalid_values :: () {
    assertions_before := library_assertions;
    create_midi_message(.Note_On, 0x80, 0x40);
    expect_assertion(assertions_before, "a first data byte of 0x80");

    assertions_before = library_assertions;
    create_midi_message(.Note_On, 0x40, 0x80);
    expect_assertion(assertions_before, "a second data byte of 0x80");

    assertions_before = library_assertions;
    create_midi_message(.Note_On, 0x40, 0x40, channel = 16);
    expect_assertion(assertions_before, "channel 16");

    assertions_before = library_assertions;
    create_midi_message(.Timing_Clock, channel = 1);
    expect_assertion(assertions_before, "a channel on a realtime message");

    assertions_before = library_assertions;
    create_midi_message(.Song_Select, 0x01, channel = 2);
    expect_assertion(assertions_before, "a channel on a system common message");

    assertions_before = library_assertions;
    create_midi_message(.Note_On, 0x7f, 0x7f, channel = 15);
    check(library_assertions == assertions_before, "The largest valid values triggered % assertion(s).", library_assertions - assertions_before);
}

test_create_control_change_message :: () {
    message := create_control_change_message(.Sustain_Pedal, 0x7f, channel = 9);
    check(message.status == .Control_Change, "Expected status Control_Change, got %.", message.status);
    check(message.channel == 9, "Expected channel 9, got %.", message.channel);
    check(message.control_change_info.controller == 64, "Expected controller 64, got %.", message.control_change_info.controller);
    check(message.control_change_info.value == 0x7f, "Expected value 0x7f, got 0x%.", hex(message.control_change_info.value));
}

test_encode_every_type :: () {
    for MESSAGE_CASES {
        encoded, count := encode_midi_message(expected_message(it));
        bytes: [] u8 = encoded;
        bytes.count = count;
        check_bytes(bytes, it.encoded, tprint("encoded % message", it.status));
    }
}

test_encode_every_channel :: () {
    for status: VOICE_STATUSES {
        for channel: 0..MIDI_CHANNEL_MAX {
            message := create_midi_message(status, 0x12, 0x34, cast(u8) channel);
            encoded := encode_midi_message(message);
            expected := (cast(u8) status) | cast(u8) channel;
            check(encoded[0] == expected, "A % message on channel % has status byte 0x%, expected 0x%.", status, channel, hex(encoded[0]), hex(expected));
        }
    }
}

// Messages with invalid channels can be built by hand, so encoding must also check them.
test_encode_rejects_invalid_channels :: () {
    message: MIDI_Message;
    message.status = .Note_On;
    message.channel = 16;
    assertions_before := library_assertions;
    encode_midi_message(message);
    expect_assertion(assertions_before, "a note-on message on channel 16");

    message.status = .Start;
    message.channel = 1;
    assertions_before = library_assertions;
    encode_midi_message(message);
    expect_assertion(assertions_before, "a start message with a channel");
}

test_status_bytes :: () {
    for enum_values_as_enum(MIDI_Status) {
        byte := make_status_byte(it);
        check(get_status(byte) == it, "Status byte 0x% gave status %, expected %.", hex(byte), get_status(byte), it);
    }

    for status: VOICE_STATUSES {
        for channel: 0..MIDI_CHANNEL_MAX {
            byte := make_status_byte(status, cast(u8) channel);
            check(get_status(byte) == status, "Status byte 0x% gave status %, expected %.", hex(byte), get_status(byte), status);
        }
    }

    // Data bytes are not status bytes.
    for byte: 0x00..0x7f {
        status := get_status(cast(u8) byte);
        check(status == .Invalid, "Data byte 0x% gave status %, expected Invalid.", hex(cast(u8) byte), status);
    }
}

test_status_classes :: () {
    for enum_values_as_enum(MIDI_Status) {
        voice    := is_voice_status(it);
        common   := is_system_common_status(it);
        realtime := is_realtime_status(it);

        expect_voice    := it >= .Note_Off && it <= .Pitch_Bend;
        expect_common   := it >= .System_Exclusive && it <= .End_Of_System_Exclusive;
        expect_realtime := it >= .Timing_Clock;

        check(voice == expect_voice,       "is_voice_status(%) returned %.", it, voice);
        check(common == expect_common,     "is_system_common_status(%) returned %.", it, common);
        check(realtime == expect_realtime, "is_realtime_status(%) returned %.", it, realtime);
    }
}

// Status bytes that MIDI leaves undefined are not statuses this module knows about.
test_undefined_status_bytes :: () {
    for UNDEFINED_STATUS_BYTES {
        status := get_status(it);
        check(status == .Invalid, "Undefined status byte 0x% gave status % (%), expected Invalid.", hex(it), status, cast(u8) status);
    }
}

test_14_bit_values :: () {
    check(get_14_bit_value(0x00, 0x00) == 0,       "get_14_bit_value(0x00, 0x00) returned %.", get_14_bit_value(0x00, 0x00));
    check(get_14_bit_value(0x00, 0x0a) == 0x0a,    "get_14_bit_value(0x00, 0x0a) returned %.", get_14_bit_value(0x00, 0x0a));
    check(get_14_bit_value(0x10, 0x20) == 0x820,   "get_14_bit_value(0x10, 0x20) returned %.", get_14_bit_value(0x10, 0x20));
    check(get_14_bit_value(0x40, 0x00) == 8192,    "get_14_bit_value(0x40, 0x00) returned %.", get_14_bit_value(0x40, 0x00));
    check(get_14_bit_value(0x7f, 0x7f) == U14_MAX, "get_14_bit_value(0x7f, 0x7f) returned %.", get_14_bit_value(0x7f, 0x7f));
}

test_pitch_bend_from_int :: () {
    for value: int.[0, 1, 0x7f, 0x80, 0x1234, 8191, 8192, 8193, U14_MAX] {
        message := create_pitch_bend_message(value, channel = 4);
        check(message.status == .Pitch_Bend, "Expected status Pitch_Bend, got %.", message.status);
        check(message.channel == 4, "Expected channel 4, got %.", message.channel);

        fine   := cast(u8) (value & 0x7f);
        coarse := cast(u8) (value >> 7);
        check(message.pitch_bend_info.fine == fine && message.pitch_bend_info.coarse == coarse,
              "Value % gave fine 0x% and coarse 0x%, expected 0x% and 0x%.", value,
              hex(message.pitch_bend_info.fine), hex(message.pitch_bend_info.coarse), hex(fine), hex(coarse));
    }

    mismatches := 0;
    first_mismatch := -1;
    for value: 0..U14_MAX {
        message := create_pitch_bend_message(value);
        if pitch_bend_get_value(message.pitch_bend_info) != value {
            if first_mismatch < 0  first_mismatch = value;
            mismatches += 1;
        }
    }
    check(mismatches == 0, "% of the 16384 values did not survive a round trip, the first being %.", mismatches, first_mismatch);
}

test_pitch_bend_from_int_out_of_range :: () {
    assertions_before := library_assertions;
    create_pitch_bend_message(-1);
    expect_assertion(assertions_before, "pitch bend value -1");

    assertions_before = library_assertions;
    create_pitch_bend_message(U14_MAX + 1);
    expect_assertion(assertions_before, "pitch bend value 16384");
}

// -1.0 is the lowest value, 0.0 is neutral (8192), and 1.0 is the highest value. Values outside that range are clamped.
test_pitch_bend_from_float :: () {
    Expected :: struct {
        input: float;
        value: int;
    }

    for Expected.[
        .{-1.0,  0},
        .{-0.5,  4096},
        .{ 0.0,  8192},
        .{ 0.5,  12288},
        .{ 1.0,  U14_MAX},
        .{-2.0,  0},
        .{ 2.0,  U14_MAX},
    ] {
        assertions_before := library_assertions;
        message := create_pitch_bend_message(it.input);
        value := pitch_bend_get_value(message.pitch_bend_info);
        check(value == it.value, "Float % gave value %, expected %.", it.input, value, it.value);
        check(library_assertions == assertions_before, "Float % triggered % assertion(s).", it.input, library_assertions - assertions_before);
    }
}

// The neutral position and both extremes must map exactly onto 0.0, -1.0 and 1.0, so that code like `if bend == 0`
// works. Below the neutral position there are exactly 8192 steps, so halfway down is exactly -0.5.
test_pitch_bend_get_float :: () {
    Expected :: struct {
        value: int;
        output: float;
    }

    for Expected.[
        .{0,       -1.0},
        .{4096,    -0.5},
        .{8192,     0.0},
        .{U14_MAX,  1.0},
    ] {
        message := create_pitch_bend_message(it.value);
        output := pitch_bend_get_float(message.pitch_bend_info);
        check(output == it.output, "Value % gave float %, expected exactly %.", it.value, output, it.output);
    }

    // Halfway up is not exact, since there are fewer steps above the neutral position than below it.
    message := create_pitch_bend_message(12288);
    output := pitch_bend_get_float(message.pitch_bend_info);
    check(abs(output - 0.5) < 0.001, "Value 12288 gave float %, expected about 0.5.", output);
}

// Converting a value to a float and back must give the same value, and a float must survive a round trip up to the
// resolution of a pitch bend message.
test_pitch_bend_round_trips :: () {
    mismatches := 0;
    first_mismatch := -1;
    for value: 0..U14_MAX {
        as_float := pitch_bend_get_float(create_pitch_bend_message(value).pitch_bend_info);
        back := pitch_bend_get_value(create_pitch_bend_message(as_float).pitch_bend_info);
        if back != value {
            if first_mismatch < 0  first_mismatch = value;
            mismatches += 1;
        }
    }
    check(mismatches == 0, "% of the 16384 values changed when converted to a float and back, the first being %.", mismatches, first_mismatch);

    for input: float.[-1.0, -0.75, -0.25, -0.001, 0.0, 0.001, 0.25, 0.75, 1.0] {
        output := pitch_bend_get_float(create_pitch_bend_message(input).pitch_bend_info);
        check(abs(output - input) <= 1.0 / 8192.0, "Float % came back as %.", input, output);
    }
}

//
// Part 1: the byte-stream decoder.
//

test_decode_every_type :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    for MESSAGE_CASES {
        decoded, message := decode_midi_packet(*decoder, it.encoded);
        if !check(decoded, "The % message was not decoded.", it.status)  continue;
        check_message(message, expected_message(it), tprint("decoded % message", it.status));
    }
}

test_decode_named_fields :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decoded, message := decode_midi_packet(*decoder, u8.[0x93, 0x3c, 0x64]);
    if check(decoded && message.status == .Note_On, "The note-on message was not decoded.") {
        check(message.note_info.note == 0x3c && message.note_info.velocity == 0x64, "Wrong note info: %.", message.note_info);
    }

    decoded, message = decode_midi_packet(*decoder, u8.[0x83, 0x3c, 0x40]);
    if check(decoded && message.status == .Note_Off, "The note-off message was not decoded.") {
        check(message.note_info.note == 0x3c && message.note_info.velocity == 0x40, "Wrong note info: %.", message.note_info);
    }

    decoded, message = decode_midi_packet(*decoder, u8.[0xa4, 0x30, 0x21]);
    if check(decoded && message.status == .Polyphonic_Pressure, "The polyphonic pressure message was not decoded.") {
        info := message.polyphonic_pressure_info;
        check(info.note == 0x30 && info.pressure == 0x21, "Wrong polyphonic pressure info: %.", info);
    }

    decoded, message = decode_midi_packet(*decoder, u8.[0xb5, 0x07, 0x65]);
    if check(decoded && message.status == .Control_Change, "The control change message was not decoded.") {
        info := message.control_change_info;
        check(info.controller == cast(u8) Control_Change.Volume && info.value == 0x65, "Wrong control change info: %.", info);
    }

    decoded, message = decode_midi_packet(*decoder, u8.[0xc6, 0x29]);
    if check(decoded && message.status == .Program_Change, "The program change message was not decoded.") {
        check(message.program_change_info.program == 0x29, "Wrong program change info: %.", message.program_change_info);
    }

    decoded, message = decode_midi_packet(*decoder, u8.[0xd7, 0x55]);
    if check(decoded && message.status == .Channel_Pressure, "The channel pressure message was not decoded.") {
        check(message.channel_pressure_info.pressure == 0x55, "Wrong channel pressure info: %.", message.channel_pressure_info);
    }

    decoded, message = decode_midi_packet(*decoder, u8.[0xe8, 0x00, 0x40]);
    if check(decoded && message.status == .Pitch_Bend, "The pitch bend message was not decoded.") {
        info := message.pitch_bend_info;
        check(info.fine == 0x00 && info.coarse == 0x40, "Wrong pitch bend info: %.", info);
        check(pitch_bend_get_value(info) == 8192, "Expected pitch bend value 8192, got %.", pitch_bend_get_value(info));
    }

    decoded, message = decode_midi_packet(*decoder, u8.[0xf1, 0x25]);
    if check(decoded && message.status == .Time_Code, "The time code message was not decoded.") {
        check(message.time_code_info.data == 0x25, "Wrong time code info: %.", message.time_code_info);
    }

    decoded, message = decode_midi_packet(*decoder, u8.[0xf2, 0x10, 0x20]);
    if check(decoded && message.status == .Song_Position_Pointer, "The song position pointer message was not decoded.") {
        info := message.song_position_pointer_info;
        check(info.pointer_lsb == 0x10 && info.pointer_msb == 0x20, "Wrong song position pointer info: %.", info);
        check(get_14_bit_value(info.pointer_msb, info.pointer_lsb) == 0x1010, "Expected song position 0x1010, got %.", get_14_bit_value(info.pointer_msb, info.pointer_lsb));
    }

    decoded, message = decode_midi_packet(*decoder, u8.[0xf3, 0x0b]);
    if check(decoded && message.status == .Song_Select, "The song select message was not decoded.") {
        check(message.song_request_info.song == 0x0b, "Wrong song select info: %.", message.song_request_info);
    }
}

test_decode_every_channel :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    for status: VOICE_STATUSES {
        for channel: 0..MIDI_CHANNEL_MAX {
            count := data_byte_count(status);
            bytes := u8.[0, 0x12, 0x34];
            bytes[0] = (cast(u8) status) | cast(u8) channel;
            packet: [] u8 = bytes;
            packet.count = 1 + count;

            decoded, message := decode_midi_packet(*decoder, packet);
            if !check(decoded, "A % message on channel % was not decoded.", status, channel)  continue;

            expected: MIDI_Message;
            expected.status = status;
            expected.channel = cast(u8) channel;
            expected.bytes[0] = 0x12;
            if count == 2  expected.bytes[1] = 0x34;
            check_message(message, expected, tprint("% message on channel %", status, channel));
        }
    }
}

test_decode_data_byte_range :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    for packet: ([] u8).[u8.[0x90, 0x00, 0x00], u8.[0x90, 0x7f, 0x7f], u8.[0x90, 0x00, 0x7f], u8.[0x90, 0x7f, 0x00]] {
        decoded, message := decode_midi_packet(*decoder, packet);
        if !check(decoded, "Packet % was not decoded.", it_index)  continue;
        check(message.bytes[0] == packet[1] && message.bytes[1] == packet[2], "Packet % gave data bytes 0x% 0x%, expected 0x% 0x%.",
              it_index, hex(message.bytes[0]), hex(message.bytes[1]), hex(packet[1]), hex(packet[2]));
    }
}

// Note-on messages with velocity 0 are kept as they are, not turned into note-off messages.
test_decode_note_on_velocity_zero :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decoded, message := decode_midi_packet(*decoder, u8.[0x92, 0x3c, 0x00]);
    if !check(decoded, "The message was not decoded.")  return;

    check(message.status == .Note_On, "Expected status Note_On, got %.", message.status);
    check(message.note_info.note == 0x3c && message.note_info.velocity == 0, "Wrong note info: %.", message.note_info);
}

// On Windows, short messages are handed to the decoder as 3 bytes, whatever their length. The extra bytes are padding
// and must not end up in the message or be treated as running status.
test_decode_padded_packets :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    for MESSAGE_CASES {
        if it.encoded.count == 3  continue;

        padded: [3] u8;
        for byte: it.encoded  padded[it_index] = byte;

        decoded, message := decode_midi_packet(*decoder, padded);
        if !check(decoded, "The padded % message was not decoded.", it.status)  continue;
        check_message(message, expected_message(it), tprint("padded % message", it.status));
    }
}

test_decode_empty_packet :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    assertions_before := library_assertions;
    decoded, message := decode_midi_packet(*decoder, u8.[]);
    check(!decoded, "An empty packet was decoded as a % message.", message.status);
    check(library_assertions == assertions_before, "An empty packet triggered % assertion(s).", library_assertions - assertions_before);
}

// A packet that is too short for its status must be rejected, and must not affect the next message.
test_decode_truncated_packets :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    assertions_before := library_assertions;

    for packet: ([] u8).[u8.[0x90], u8.[0x90, 0x40], u8.[0xe0, 0x00], u8.[0xc0], u8.[0xd0], u8.[0xf1], u8.[0xf2, 0x01], u8.[0xf3]] {
        decoded, message := decode_midi_packet(*decoder, packet);
        check(!decoded, "Truncated packet % (status byte 0x%) was decoded as a % message.", it_index, hex(packet[0]), message.status);
    }

    check(library_assertions == assertions_before, "Truncated packets triggered % assertion(s).", library_assertions - assertions_before);

    decoded, message := decode_midi_packet(*decoder, u8.[0x95, 0x40, 0x7f]);
    if check(decoded, "The decoder did not recover from truncated packets.") {
        check_message(message, make_message(.Note_On, 5, 0x40, 0x7f));
    }
}

// Data bytes never have their high bit set. A status byte where a data byte is expected means the packet is malformed.
test_decode_status_byte_as_data :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    for packet: ([] u8).[u8.[0x90, 0x40, 0x80], u8.[0x90, 0x90, 0x40], u8.[0xc0, 0xc1], u8.[0xf2, 0x01, 0xf8]] {
        decoded, message := decode_midi_packet(*decoder, packet);
        check(!decoded, "Packet % was decoded as a % message with data bytes 0x% 0x%.", it_index, message.status, hex(message.bytes[0]), hex(message.bytes[1]));
    }
}

// Undefined status bytes must be ignored, without an assertion, and must not affect the next message.
test_decode_undefined_status_bytes :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    assertions_before := library_assertions;

    for UNDEFINED_STATUS_BYTES {
        decoded, message := decode_midi_packet(*decoder, u8.[it]);
        check(!decoded, "Undefined status byte 0x% was decoded as a message with status % (%).", hex(it), message.status, cast(u8) message.status);

        decoded, message = decode_midi_packet(*decoder, u8.[it, 0x01, 0x02]);
        check(!decoded, "Undefined status byte 0x% with data bytes was decoded as a message with status % (%).", hex(it), message.status, cast(u8) message.status);
    }

    check(library_assertions == assertions_before, "Undefined status bytes triggered % assertion(s).", library_assertions - assertions_before);

    decoded, message := decode_midi_packet(*decoder, u8.[0xb1, 0x07, 0x64]);
    if check(decoded, "The decoder did not recover from undefined status bytes.") {
        check_message(message, make_message(.Control_Change, 1, 0x07, 0x64));
    }
}

//
// Part 1: running status.
//

// After a voice message, data bytes without a status byte belong to a message with the same status.
test_running_status :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decode_midi_packet(*decoder, u8.[0x93, 0x40, 0x7f]);

    decoded, message := decode_midi_packet(*decoder, u8.[0x41, 0x7f]);
    if check(decoded, "The first message with running status was not decoded.") {
        check_message(message, make_message(.Note_On, 3, 0x41, 0x7f), "first message with running status");
    }

    decoded, message = decode_midi_packet(*decoder, u8.[0x40, 0x00]);
    if check(decoded, "The second message with running status was not decoded.") {
        check_message(message, make_message(.Note_On, 3, 0x40, 0x00), "second message with running status");
    }
}

test_running_status_one_data_byte :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decode_midi_packet(*decoder, u8.[0xc5, 0x10]);
    decoded, message := decode_midi_packet(*decoder, u8.[0x11]);
    if check(decoded, "The program change with running status was not decoded.") {
        check_message(message, make_message(.Program_Change, 5, 0x11), "program change with running status");
    }

    decode_midi_packet(*decoder, u8.[0xd9, 0x20]);
    decoded, message = decode_midi_packet(*decoder, u8.[0x21]);
    if check(decoded, "The channel pressure with running status was not decoded.") {
        check_message(message, make_message(.Channel_Pressure, 9, 0x21), "channel pressure with running status");
    }
}

test_running_status_replaced :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decode_midi_packet(*decoder, u8.[0x90, 0x40, 0x7f]);
    decode_midi_packet(*decoder, u8.[0xb2, 0x07, 0x64]);

    decoded, message := decode_midi_packet(*decoder, u8.[0x0a, 0x40]);
    if check(decoded, "The message with running status was not decoded.") {
        check_message(message, make_message(.Control_Change, 2, 0x0a, 0x40));
    }
}

// Realtime messages can appear anywhere, and leave the running status alone.
test_running_status_kept_by_realtime :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decode_midi_packet(*decoder, u8.[0xe4, 0x00, 0x40]);

    for byte: u8.[0xf8, 0xfa, 0xfb, 0xfc, 0xfe] {
        decoded, message := decode_midi_packet(*decoder, u8.[byte]);
        check(decoded && message.status == get_status(byte), "Realtime byte 0x% was not decoded (got %).", hex(byte), message.status);

        decoded, message = decode_midi_packet(*decoder, u8.[0x7f, 0x7f]);
        if check(decoded, "The message with running status after realtime byte 0x% was not decoded.", hex(byte)) {
            check_message(message, make_message(.Pitch_Bend, 4, 0x7f, 0x7f), tprint("message after realtime byte 0x%", hex(byte)));
        }
    }
}

// System common messages cancel the running status, so data bytes after them have no status.
test_running_status_cancelled_by_system_common :: () {
    for packet: ([] u8).[u8.[0xf1, 0x10], u8.[0xf2, 0x01, 0x02], u8.[0xf3, 0x05], u8.[0xf6]] {
        decoder: MIDI_Decoder;
        defer array_free(decoder.system_exclusive_message_buffer);

        decode_midi_packet(*decoder, u8.[0x90, 0x40, 0x7f]);
        decode_midi_packet(*decoder, packet);

        decoded, message := decode_midi_packet(*decoder, u8.[0x41, 0x7f]);
        check(!decoded, "After a % message, data bytes were decoded as a % message.", get_status(packet[0]), message.status);
    }
}

// System common messages do not become the running status themselves.
test_running_status_not_set_by_system_messages :: () {
    for packet: ([] u8).[u8.[0xf1, 0x10], u8.[0xf2, 0x01, 0x02], u8.[0xf3, 0x05], u8.[0xf6], u8.[0xf8]] {
        decoder: MIDI_Decoder;
        defer array_free(decoder.system_exclusive_message_buffer);

        decode_midi_packet(*decoder, packet);

        decoded, message := decode_midi_packet(*decoder, u8.[0x03, 0x04]);
        check(!decoded, "After a % message, data bytes were decoded as a % message.", get_status(packet[0]), message.status);
    }
}

// When an input opens in the middle of a stream that uses running status, the first bytes it receives have no status.
// These are not an error in the program, so they must be ignored without an assertion.
test_data_without_running_status :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    assertions_before := library_assertions;

    decoded, message := decode_midi_packet(*decoder, u8.[0x40, 0x7f]);
    check(!decoded, "Data bytes without a status were decoded as a % message.", message.status);
    check(library_assertions == assertions_before, "Data bytes without a status triggered % assertion(s).", library_assertions - assertions_before);

    decoded, message = decode_midi_packet(*decoder, u8.[0x80, 0x40, 0x00]);
    if check(decoded, "The decoder did not recover from data bytes without a status.") {
        check_message(message, make_message(.Note_Off, 0, 0x40, 0x00));
    }
}

//
// Part 1: delivery from an input to its callback.
//

Delivered :: struct {
    message: MIDI_Message;
    timestamp: Apollo_Time;
}

Delivery_Log :: struct {
    messages: [..] Delivered;
}

recording_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    delivery_log := cast(*Delivery_Log) user_data;
    array_add(*delivery_log.messages, .{message, timestamp});
}

make_test_input :: (delivery_log: *Delivery_Log) -> *MIDI_Input {
    input := New(MIDI_Input);
    input.callback = recording_callback;
    input.callback_data = delivery_log;
    return input;
}

// Does what the platform layers do with incoming bytes.
deliver :: (input: *MIDI_Input, bytes: [] u8, timestamp: Apollo_Time) {
    decoded, message := decode_midi_packet(*input.decoder, bytes);
    if decoded  post_message_to_input(input, message, timestamp);
}

test_delivery_through_input :: () {
    delivery_log: Delivery_Log;
    defer array_free(delivery_log.messages);

    input := make_test_input(*delivery_log);
    defer free_input(input);

    for MESSAGE_CASES  deliver(input, it.encoded, milliseconds_to_apollo(100 + it_index));

    if !check(delivery_log.messages.count == MESSAGE_CASES.count, "Expected % callbacks, got %.", MESSAGE_CASES.count, delivery_log.messages.count)  return;

    for MESSAGE_CASES {
        delivered := delivery_log.messages[it_index];
        check_message(delivered.message, expected_message(it), tprint("delivered % message", it.status));

        milliseconds := to_milliseconds(delivered.timestamp);
        check(milliseconds == 100 + it_index, "The % message has timestamp % ms, expected % ms.", it.status, milliseconds, 100 + it_index);
    }
}

//
// Part 1: the UMP decoder.
//

// Builds a 32-bit UMP that carries a MIDI 1.0 message.
make_ump_for_case :: (message_case: Message_Case, group: u32 = 0) -> u32 {
    encoded := message_case.encoded;
    message_type := ifx is_voice_status(message_case.status) then UMP_Message_Type.MIDI_1_Voice else .System_Common_Or_Real_Time;
    data1 := ifx encoded.count > 1 then cast(u32) encoded[1] else 0;
    data2 := ifx encoded.count > 2 then cast(u32) encoded[2] else 0;
    return make_ump_word(message_type, group, encoded[0], data1, data2);
}

// Decodes a whole list of words, and returns the messages.
decode_all_ump_words :: (decoder: *MIDI_Decoder, words: [] u32) -> [..] MIDI_Message {
    result: [..] MIDI_Message;
    remaining := words;
    while remaining.count {
        decoded, message := decode_ump_words(decoder, *remaining);
        if decoded  array_add(*result, message);
    }
    return result;
}

test_ump_voice_messages :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    for MESSAGE_CASES {
        if !is_voice_status(it.status)  continue;

        packet: [1] u32;
        packet[0] = make_ump_for_case(it);
        words: [] u32 = packet;

        decoded, message := decode_ump_words(*decoder, *words);
        check(words.count == 0, "The % packet was not consumed.", it.status);
        if !check(decoded, "The % packet was not decoded.", it.status)  continue;
        check_message(message, expected_message(it), tprint("% message from a UMP", it.status));
    }
}

test_ump_system_messages :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    for MESSAGE_CASES {
        if is_voice_status(it.status)  continue;

        packet: [1] u32;
        packet[0] = make_ump_for_case(it);
        words: [] u32 = packet;

        decoded, message := decode_ump_words(*decoder, *words);
        check(words.count == 0, "The % packet was not consumed.", it.status);
        if !check(decoded, "The % packet was not decoded.", it.status)  continue;
        check_message(message, expected_message(it), tprint("% message from a UMP", it.status));
    }
}

// Groups are a MIDI 2.0 concept that this module does not use; messages in every group are decoded the same way.
test_ump_group_ignored :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    note_on := MESSAGE_CASES[1];
    for group: 0..15 {
        packet: [1] u32;
        packet[0] = make_ump_for_case(note_on, cast(u32) group);
        words: [] u32 = packet;

        decoded, message := decode_ump_words(*decoder, *words);
        if !check(decoded, "The note-on packet in group % was not decoded.", group)  continue;
        check_message(message, expected_message(note_on), tprint("note-on message in group %", group));
    }
}

// CoreMIDI can deliver several messages in one packet.
test_ump_several_messages :: () {
    words: [..] u32;
    defer array_free(words);

    expected: [..] MIDI_Message;
    defer array_free(expected);

    for MESSAGE_CASES {
        array_add(*words, make_ump_for_case(it));
        array_add(*expected, expected_message(it));
    }

    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    messages := decode_all_ump_words(*decoder, words);
    defer array_free(messages);

    if !check(messages.count == expected.count, "Expected % messages, got %.", expected.count, messages.count)  return;
    for messages  check_message(it, expected[it_index], tprint("message %", it_index));
}

// Utility messages (no-ops and jitter reduction timestamps) are one word each, and carry no MIDI message.
test_ump_utility_messages :: () {
    assertions_before := library_assertions;

    note_on := MESSAGE_CASES[1];
    words := u32.[
        0x0000_0000,                                                                               // No-op.
        ((cast(u32) UMP_Utility_Status.Jitter_Reduction_Clock) << 20)     | 0x1234,
        make_ump_for_case(note_on),
        ((cast(u32) UMP_Utility_Status.Jitter_Reduction_Timestamp) << 20) | 0x5678,
        0x0000_0000,                                                                               // No-op.
    ];

    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    messages := decode_all_ump_words(*decoder, words);
    defer array_free(messages);

    check(library_assertions == assertions_before, "Utility messages triggered % assertion(s).", library_assertions - assertions_before);
    if !check(messages.count == 1, "Expected 1 message, got %.", messages.count)  return;
    check_message(messages[0], expected_message(note_on), "note-on message between utility messages");
}

// UMPs of the types this module doesn't handle (MIDI 2.0 voice messages, 8-bit data, flex data, stream messages and
// reserved types) must be skipped without an assertion. Their size follows from their type, so the decoder must skip
// the right number of words, or it misreads the words that follow.
test_ump_other_message_types_skipped :: () {
    UMP_Type_Size :: struct {
        message_type: u32;
        word_count: int;
    }

    // Decoded as a note-off if the decoder skips too few words.
    FILLER :: 0x2080_1122;

    note_on := MESSAGE_CASES[1];

    for UMP_Type_Size.[
        .{0x4, 2}, // MIDI 2.0 channel voice.
        .{0x5, 4}, // 8-bit data.
        .{0x6, 1}, .{0x7, 1},
        .{0x8, 2}, .{0x9, 2}, .{0xa, 2},
        .{0xb, 3}, .{0xc, 3},
        .{0xd, 4}, // Flex data.
        .{0xe, 4},
        .{0xf, 4}, // UMP stream.
    ] {
        words: [..] u32;
        defer array_free(words);

        array_add(*words, (it.message_type << 28) | 0x0090_407f);
        for 2..it.word_count  array_add(*words, FILLER);
        array_add(*words, make_ump_for_case(note_on));

        decoder: MIDI_Decoder;
        defer array_free(decoder.system_exclusive_message_buffer);

        assertions_before := library_assertions;
        messages := decode_all_ump_words(*decoder, words);
        defer array_free(messages);

        check(library_assertions == assertions_before, "A UMP of type 0x% triggered % assertion(s).", formatInt(it.message_type, base = 16), library_assertions - assertions_before);
        if !check(messages.count == 1, "After a UMP of type 0x% (% words), expected 1 message, got %.", formatInt(it.message_type, base = 16), it.word_count, messages.count)  continue;
        check_message(messages[0], expected_message(note_on), tprint("note-on message after a UMP of type 0x%", formatInt(it.message_type, base = 16)));
    }
}

//
// Part 2: loopback.
//

LOOPBACK_TIMEOUT_MS   :: 5000;
MAX_LOOPBACK_MESSAGES :: 4096;

Loopback_State :: struct {
    received: Semaphore;
    write_count: s64;
    read_cursor: s64;
    messages: [MAX_LOOPBACK_MESSAGES] MIDI_Message;
}

loopback_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    state := cast(*Loopback_State) user_data;
    index := atomic_add(*state.write_count, 1);
    defer signal(*state.received);

    if index >= MAX_LOOPBACK_MESSAGES  return;
    state.messages[index] = message;
}

// Returns the next message the callback received, in order.
next_message :: (state: *Loopback_State, timeout_ms: s32 = LOOPBACK_TIMEOUT_MS) -> bool, MIDI_Message {
    if wait_for(*state.received, timeout_ms) != .SUCCESS  return false, .{};

    index := state.read_cursor;
    state.read_cursor += 1;
    if index >= MAX_LOOPBACK_MESSAGES  return false, .{};
    return true, state.messages[index];
}

// Skips everything that has been received so far, waiting until nothing arrives for a while.
drain :: (state: *Loopback_State) {
    while next_message(state, 200) {}
}

run_loopback_tests :: (loopback_name: string, use_virtual_endpoint: bool) {
    state := New(Loopback_State);
    init(*state.received);
    defer {
        destroy(*state.received);
        free(state);
    }

    found, input, output := open_loopback(loopback_name, use_virtual_endpoint, state);
    if !found {
        print("Skipped: no MIDI loopback named '%' was found. See the top of this file for how to set one up.\n", loopback_name);
        return;
    }

    defer {
        close_input(input);
        close_output(output);
    }

    print("Using loopback '%'.\n", loopback_name);

    // Inputs can miss messages sent right after they open, so wait until messages come through.
    connected := false;
    for 1..30 {
        send_midi_message(output, create_midi_message(.Note_Off, 0, 0));
        if next_message(state, 100) {
            connected = true;
            break;
        }
    }

    check(connected, "No messages came through the loopback.");
    if !connected  return;
    drain(state);

    begin_test("Every type of message");     test_loopback_every_type(state, output);     end_test();
    begin_test("Every channel");             test_loopback_every_channel(state, output);  end_test();
    begin_test("Note-on with velocity 0");   test_loopback_velocity_zero(state, output);  end_test();
    begin_test("Pitch bend values");         test_loopback_pitch_bend(state, output);     end_test();
    begin_test("Raw bytes");                 test_loopback_raw_bytes(state, output);      end_test();
    begin_test("Several messages at once");  test_loopback_batch(state, output);          end_test();
}

// Sends a message and checks that it comes back unchanged.
send_and_expect :: (state: *Loopback_State, output: *MIDI_Output, message: MIDI_Message, what: string, loc := #caller_location) {
    sent := send_midi_message(output, message);
    if !check(sent, "The % could not be sent.", what, loc = loc)  return;

    received, actual := next_message(state);
    if !check(received, "The % was not received.", what, loc = loc) {
        drain(state); // Don't let a late arrival be compared with the next message.
        return;
    }

    check_message(actual, message, what, loc = loc);
}

test_loopback_every_type :: (state: *Loopback_State, output: *MIDI_Output) {
    for MESSAGE_CASES  send_and_expect(state, output, expected_message(it), tprint("% message on channel %", it.status, it.channel));
}

test_loopback_every_channel :: (state: *Loopback_State, output: *MIDI_Output) {
    for status: VOICE_STATUSES {
        for channel: 0..MIDI_CHANNEL_MAX {
            data1: u8 = xx ifx data_byte_count(status) == 2 then 0x34 else 0;
            message := create_midi_message(status, 0x12, data1, cast(u8) channel);
            send_and_expect(state, output, message, tprint("% message on channel %", status, channel));
        }
    }
}

// Note-on messages with velocity 0 must arrive as they were sent, even though they mean the same as a note-off. Some
// backends convert them, which the module should undo or avoid.
test_loopback_velocity_zero :: (state: *Loopback_State, output: *MIDI_Output) {
    send_and_expect(state, output, create_midi_message(.Note_On, 0x3c, 0x00, channel = 7), "note-on message with velocity 0");
}

test_loopback_pitch_bend :: (state: *Loopback_State, output: *MIDI_Output) {
    for value: int.[0, 1, 0x7f, 0x80, 8191, 8192, 8193, U14_MAX - 1, U14_MAX] {
        send_and_expect(state, output, create_pitch_bend_message(value, channel = 11), tprint("pitch bend message with value %", value));
    }
}

// send_midi_message also takes the encoded bytes directly. Every length must work, including single-byte messages.
test_loopback_raw_bytes :: (state: *Loopback_State, output: *MIDI_Output) {
    for MESSAGE_CASES {
        what := tprint("% message sent as % raw byte(s)", it.status, it.encoded.count);

        sent := send_midi_message(output, it.encoded);
        if !check(sent, "The % could not be sent.", what)  continue;

        received, actual := next_message(state);
        if !check(received, "The % was not received.", what) {
            drain(state);
            continue;
        }

        check_message(actual, expected_message(it), what);
    }
}

test_loopback_batch :: (state: *Loopback_State, output: *MIDI_Output) {
    messages: [MESSAGE_CASES.count] MIDI_Message;
    for MESSAGE_CASES  messages[it_index] = expected_message(it);

    sent := send_midi_messages(output, messages);
    check(sent, "The messages could not be sent.");

    for messages {
        received, actual := next_message(state);
        if !check(received, "Message % of the batch (%) was not received.", it_index, it.status)  break;
        check_message(actual, it, tprint("message % of the batch", it_index));
    }
}

open_loopback :: (name: string, use_virtual_endpoint: bool, state: *Loopback_State) -> found: bool, input: *MIDI_Input, output: *MIDI_Output {
    #if OS == .MACOS {
        if use_virtual_endpoint {
            input := open_virtual_input(name, loopback_callback, state);
            if !input  return false, null, null;

            // Give CoreMIDI a moment to publish the new endpoint.
            for 1..20 {
                destination_index := get_destination_index_by_name(name, match_full_name = true);
                if destination_index >= 0 {
                    output := open_output(destination_index);
                    if output  return true, input, output;
                    break;
                }
                sleep_milliseconds(50);
            }

            close_input(input);
            return false, null, null;
        }
    }

    source_index      := get_source_index_by_name(name);
    destination_index := get_destination_index_by_name(name);
    if source_index < 0 || destination_index < 0  return false, null, null;

    output := open_output(destination_index);
    input  := open_input(source_index, loopback_callback, state);
    if !input || !output {
        close_input(input);
        close_output(output);
        return false, null, null;
    }

    return true, input, output;
}

//
// Helpers.
//

// The number of data bytes each status has according to the MIDI specification.
data_byte_count :: (status: MIDI_Status) -> int {
    if status == {
        case .Note_Off;              return 2;
        case .Note_On;               return 2;
        case .Polyphonic_Pressure;   return 2;
        case .Control_Change;        return 2;
        case .Program_Change;        return 1;
        case .Channel_Pressure;      return 1;
        case .Pitch_Bend;            return 2;
        case .Time_Code;             return 1;
        case .Song_Position_Pointer; return 2;
        case .Song_Select;           return 1;
    }
    return 0;
}

// Builds a message by hand, so that the expected values don't depend on the code under test.
make_message :: (status: MIDI_Status, channel: u8, data0: u8 = 0, data1: u8 = 0) -> MIDI_Message {
    result: MIDI_Message;
    result.status = status;
    result.channel = channel;
    result.bytes[0] = data0;
    result.bytes[1] = data1;
    return result;
}

expected_message :: (message_case: Message_Case) -> MIDI_Message {
    return make_message(message_case.status, message_case.channel, message_case.data0, message_case.data1);
}

// Compares status, channel and both data bytes. Data bytes a message doesn't use must be 0.
check_message :: (actual: MIDI_Message, expected: MIDI_Message, what := "message", loc := #caller_location) -> bool {
    if !check(actual.status == expected.status, "The % has status %, expected %.", what, actual.status, expected.status, loc = loc)  return false;

    result := check(actual.channel == expected.channel, "The % has channel %, expected %.", what, actual.channel, expected.channel, loc = loc);

    same_bytes := actual.bytes[0] == expected.bytes[0] && actual.bytes[1] == expected.bytes[1];
    result = check(same_bytes, "The % has data bytes 0x% 0x%, expected 0x% 0x%.", what,
                   hex(actual.bytes[0]), hex(actual.bytes[1]), hex(expected.bytes[0]), hex(expected.bytes[1]), loc = loc) && result;

    return result;
}

check_bytes :: (actual: [] u8, expected: [] u8, what := "message", loc := #caller_location) {
    if actual.count != expected.count {
        check(false, "The % has % bytes, but % were expected.", what, actual.count, expected.count, loc = loc);
        return;
    }

    for actual {
        if it != expected[it_index] {
            check(false, "The % differs at byte % (0x% instead of 0x%).", what, it_index, hex(it), hex(expected[it_index]), loc = loc);
            return;
        }
    }

    check(true, "");
}

// Checks that an assertion was triggered inside the module since the count was taken.
expect_assertion :: (assertions_before: int, what: string, loc := #caller_location) {
    check(library_assertions > assertions_before, "No assertion was triggered for %.", what, loc = loc);
}

// Returns a string rather than a FormatInt, since a FormatInt would point at the parameter after it has gone away.
hex :: (value: u8) -> string {
    return tprint("%", formatInt(value, base = 16, minimum_digits = 2));
}

run_test :: (name: string, test: () -> ()) {
    begin_test(name);
    test();
    end_test();
}

begin_test :: (name: string) {
    print("\n%\n", name);
    failures_at_test_start = failed_checks;
}

end_test :: () {
    if failed_checks == failures_at_test_start  print("  ok\n");
}

failures_at_test_start: int;

passed_checks: int;
failed_checks: int;

check :: (condition: bool, format: string, args: ..Any, loc := #caller_location) -> bool {
    if condition {
        passed_checks += 1;
        return true;
    }

    failed_checks += 1;
    print("  FAILED (line %): ", loc.line_number);
    print(format, ..args);
    print("\n");
    return false;
}

library_assertions: int;

// Reports assertions but keeps running, so that the remaining checks still run.
recording_assertion_handler :: (loc: Source_Code_Location, message: string) -> bool {
    library_assertions += 1;
    print("  (assertion in %:%: %)\n", path_filename(loc.fully_pathed_filename), loc.line_number, message);
    return false;
}
