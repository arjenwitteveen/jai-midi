#run midi_encode_decode_test();
#run midi_utilities_test();
#run system_exclusive_buffer_test();
#run endpoint_info_test();

midi_encode_decode_test :: () {
    decoder: MIDI_Decoder;

    test_message :: (message: MIDI_Message, expected_bytes: [] u8) #expand {
        test_log("Testing % message...\n", message.status);
        result, count := encode_midi_message(message);
        bytes : [] u8 = result;
        bytes.count = count;
        assert_equal(bytes, expected_bytes);
        assert(message.status == .System_Exclusive || number_of_data_bytes(message.status) + 1 == expected_bytes.count);
        decoded := decode_midi_bytes(*decoder, result);
        assert_equal(message, decoded);
    }

    // Create each type of message, check if our encoding function turns it into the right byte representation, and then
    // use our decoder to decode those bytes again and check if we get the original message.

    // Voice messages.
    note_off := create_midi_message(.Note_Off, 0x3d, 0x70, channel = 3);
    test_message(note_off, u8.[0x83, 0x3d, 0x70]);

    note_on := create_midi_message(.Note_On, 0x1b, 0x60, channel = 12);
    test_message(note_on, u8.[0x9c, 0x1b, 0x60]);

    poly_message := create_midi_message(.Polyphonic_Pressure, 0x19, 0x6f, channel = 1);
    test_message(poly_message, u8.[0xa1, 0x19, 0x6f]);

    cc_message := create_control_change_message(.Pan, 0x43, channel = 10);
    test_message(cc_message, u8.[0xba, 0x0a, 0x43]);

    pc_message := create_midi_message(.Program_Change, 0x12);
    test_message(pc_message, u8.[0xc0, 0x12]);

    cp_message := create_midi_message(.Channel_Pressure, 0x5b, channel = 2);
    test_message(cp_message, u8.[0xd2, 0x5b]);

    pb_message := create_midi_message(.Pitch_Bend, 0x7f, 0x4f, channel = 6);
    test_message(pb_message, u8.[0xe6, 0x7f, 0x4f]);

    // System common messages.
    sysex_data := u8.[0xf0, 0x42, 0x31, 0x70, 0xf7];
    sysex_message := create_system_exclusive_message(sysex_data);
    assert_equal(sysex_message, decode_midi_bytes(*decoder, sysex_data)); // We don't do encoding for system-exclusive messages, just test decoding.

    quarter_frame_message := create_midi_message(.Time_Code_Quarter_Frame, 0x36);
    test_message(quarter_frame_message, u8.[0xf1, 0x36]);

    song_position_message := create_midi_message(.Song_Position_Pointer, 0x01, 0x7f);
    test_message(song_position_message, u8.[0xf2, 0x01, 0x7f]);

    song_select_message := create_midi_message(.Song_Select, 0x42);
    test_message(song_select_message, u8.[0xf3, 0x42]);

    tune_request_message := create_midi_message(.Tune_Request);
    test_message(tune_request_message, u8.[0xf6]);

    // System realtime messages.
    test_message(create_midi_message(.Timing_Clock),   u8.[0xf8]);
    test_message(create_midi_message(.Start),          u8.[0xfa]);
    test_message(create_midi_message(.Continue),       u8.[0xfb]);
    test_message(create_midi_message(.Stop),           u8.[0xfc]);
    test_message(create_midi_message(.Active_Sensing), u8.[0xfe]);
    test_message(create_midi_message(.System_Reset),   u8.[0xff]);
}

midi_utilities_test :: () {
    #import "Math";

    // Pitch bend value roundtrips.
    for value: int.[0, 1, 23, 435, 7235, U14_MAX] {
        pb_message := create_pitch_bend_message(value);
        output_value := pitch_bend_get_value(pb_message.pitch_bend_info);
        assert(output_value == value, "Input pitch bend value was %, but resulting value is %.", value, output_value);
    }

    for value: float.[-1.0, -0.5, 0.0, 0.5, 1.0] {
        pb_message := create_pitch_bend_message(value);
        output_value := pitch_bend_get_float(pb_message.pitch_bend_info);
        epsilon :: 0.001;
        assert(abs(output_value - value) < epsilon, "Input pitch bend value was %, but resulting value is %.", value, output_value);
    }

    assert(get_14_bit_value(0x7f, 0x7f) == U14_MAX);
    assert(get_14_bit_value(0x10, 0x20) == 0x820);
    assert(get_14_bit_value(0x00, 0x0a) == 0x0a);

    for enum_values_as_enum(MIDI_Status) {
        byte := make_status_byte(it);
        assert(get_status(byte) == it, "Got % but expected %.", get_status(byte), it);
    }
}

system_exclusive_buffer_test :: () {
    // Test with single small buffer.
    {
        input: MIDI_Input;
        decoder := *input.decoder;

        buffer := u8.[0xf0, 0x12, 0x34, 0x56, 0x78, 0xf7];

        message, handle_success := handle_system_exclusive_message(*input, buffer, false);
        assert(handle_success);

        assert(decoder.message_buffer.count == 6, "Unexpected value % for buffer.count.", decoder.message_buffer.count);
        assert(decoder.message_buffer.allocated == 6, "Unexpected value % for buffer.allocated.", decoder.message_buffer.allocated);
        assert(!decoder.message_in_progress, "Unexpected value for message_in_progress.");
        assert_equal(decoder.message_buffer, buffer);
        assert_equal(decoder.message_buffer, message.system_exclusive_info.buffer);
        assert(message.status == .System_Exclusive);
    }

    // Test with multiple buffers.
    {
        input: MIDI_Input;
        decoder := *input.decoder;

        slice :: (array: [] $T, start: int, count: int) -> [] T {
            result: [] T = ---;
            result.data = array.data + start;
            result.count = count;
            return result;
        }

        buffer := u8.[0xf0, 0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf7];
        buffer_1 := slice(buffer, 0, 3);
        buffer_2 := slice(buffer, 3, 3);
        buffer_3 := slice(buffer, 6, 3);

        message: MIDI_Message;
        message_ready: bool;

        message, message_ready = handle_system_exclusive_message(*input, buffer_1, false);
        assert(decoder.message_buffer.count == 3, "Unexpected value % for buffer.count.", decoder.message_buffer.count);
        assert(decoder.message_buffer.allocated == 3, "Unexpected value % for buffer.allocated.", decoder.message_buffer.allocated);
        assert(decoder.message_in_progress, "Unexpected value for message_in_progress.");
        assert_equal(decoder.message_buffer, buffer_1);
        assert(message_ready == false);

        message, message_ready = handle_system_exclusive_message(*input, buffer_2, false);
        assert(decoder.message_buffer.count == 6, "Unexpected value % for buffer.count.", decoder.message_buffer.count);
        assert(decoder.message_buffer.allocated == 6, "Unexpected value % for buffer.allocated.", decoder.message_buffer.allocated);
        assert(decoder.message_in_progress, "Unexpected value for message_in_progress.");
        assert_equal(decoder.message_buffer, slice(buffer, 0, 6));
        assert(message_ready == false);

        message, message_ready = handle_system_exclusive_message(*input, buffer_3, false);
        assert(decoder.message_buffer.count == buffer.count, "Unexpected value % for buffer.count.", decoder.message_buffer.count);
        assert(decoder.message_buffer.allocated == buffer.count, "Unexpected value % for buffer.allocated.", decoder.message_buffer.allocated);
        assert(!decoder.message_in_progress, "Unexpected value for message_in_progress.");
        assert_equal(decoder.message_buffer, buffer);
        assert_equal(decoder.message_buffer, message.system_exclusive_info.buffer);
        assert(message_ready == true);
    }

    // @TODO: Test sysex message being interrupted by other message (both voice and realtime).
}

endpoint_info_test :: () {

    dummy_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) { }

    number_of_sources := get_number_of_sources();
    test_log("Found % sources.", number_of_sources);
    for 0..number_of_sources - 1 {
        source_name := get_source_name(it);
        assert(source_name.count > 0, "Source name could not be retrieved.");
        info, info_success := get_source_info(it);
        assert(info_success, "Source info could not be retrieved.");
        // print("%\n", info);
    }

    number_of_destinations := get_number_of_destinations();
    test_log("Found % destinations.", number_of_destinations);
    for 0..number_of_destinations - 1 {
        destination_name := get_destination_name(it);
        assert(destination_name.count > 0, "Destination name could not be retrieved.");
        info, info_success := get_destination_info(it);
        assert(info_success, "Destination info could not be retrieved.");
        // print("%\n", info);
    }

    // Error handling; these are supposed to trigger some error messages, but no crashes.
    BAD_DEVICE_INDEX :: 12345;

    source_name := get_source_name(BAD_DEVICE_INDEX);
    assert(source_name == "", "Unexpected return value '%' for get_source_name.", source_name);
    destination_name := get_destination_name(BAD_DEVICE_INDEX);
    assert(destination_name == "", "Unexpected return value '%' for get_destination_name.", destination_name);

    source_info, source_info_success := get_source_info(BAD_DEVICE_INDEX);
    assert(!source_info_success);

    destination_info, destination_info_success := get_destination_info(BAD_DEVICE_INDEX);
    assert(!destination_info_success);

    assert(open_input(BAD_DEVICE_INDEX, dummy_callback) == null);
    assert(open_output(BAD_DEVICE_INDEX) == null);
}
