//
// Tests for system-exclusive messages.
//
// Part 1 tests the decoders directly and needs no MIDI hardware: the byte-stream decoder that every platform uses, the
// path that delivers messages from a MIDI_Input to its callback, and the Universal MIDI Packet (UMP) decoder that is used
// on macOS.
//
// Part 2 sends system-exclusive messages through a loopback and checks that they arrive intact:
//
//   - Windows: a loopback driver such as loopMIDI. By default a port whose name contains "loopMIDI" is used.
//   - Linux:   the ALSA 'Midi Through' port (snd-seq-dummy), which is present on most systems.
//   - macOS:   a virtual input created by the test itself, which the test then opens as an output.
//
// If no loopback is found, part 2 is skipped. Run them with `jai first.jai - test sysex`; see tests.jai for the
// options, including how to choose the loopback.
//
// Some of these tests describe behavior the module doesn't have yet, so not all of them pass. Each test states the
// intended behavior.
//

run_sysex_tests :: () {
    begin_section("Decoder tests");

    run_test("Single complete message",                     test_single_packet);
    run_test("Shortest possible message",                   test_minimal_message);
    run_test("Consecutive messages on one decoder",         test_consecutive_messages);
    run_test("Message split into chunks of various sizes",  test_chunk_sizes);
    run_test("Large message",                               test_large_message);
    run_test("Realtime message between chunks",             test_realtime_between_chunks);

    // We probably will not support these, since it does not seem like something that will occur with real MIDI drivers.
    // run_test("Realtime byte inside a chunk",                test_realtime_inside_chunk);
    // run_test("Status byte inside a chunk ends a message",   test_status_byte_inside_chunk);

    run_test("Voice message interrupts a message",          test_voice_message_interrupts);
    run_test("New start while a message is in progress",    test_restart_while_in_progress);
    run_test("Continuation without a start",                test_stray_continuation);
    run_test("create_system_exclusive_message",             test_create_system_exclusive_message);
    run_test("Delivery through an input",                   test_delivery_through_input);
    run_test("Interrupted message through an input",        test_interrupted_delivery_through_input);

    run_test("UMP: complete packets of every size",         test_ump_complete_packets);
    run_test("UMP: start, continue and end packets",        test_ump_multi_packet);
    run_test("UMP: message followed by a voice message",    test_ump_followed_by_voice_message);
    run_test("UMP: continue without a start",               test_ump_stray_continue);
    run_unsafe_test("UMP: invalid byte count",              test_ump_invalid_byte_count);

    begin_section("Loopback tests");

    loopback_name, use_virtual_endpoint := loopback_settings("jai-midi sysex test");
    run_loopback_tests(loopback_name, use_virtual_endpoint);
}

#scope_file

//
// Part 1: the byte-stream decoder.
//

test_single_packet :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    data := u8.[0xf0, 0x43, 0x10, 0x4c, 0x00, 0x00, 0x7e, 0x00, 0xf7];
    decoded, message := decode_midi_packet(*decoder, data);

    check(decoded, "The message was not decoded.");
    check(message.status == .System_Exclusive, "Expected status System_Exclusive, got %.", message.status);
    check_bytes(message.system_exclusive_info.buffer, data);
    check(!decoder.system_exclusive_message_in_progress, "The decoder still has a message in progress.");
}

test_minimal_message :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    data := u8.[0xf0, 0xf7];
    decoded, message := decode_midi_packet(*decoder, data);

    check(decoded, "The message was not decoded.");
    check_bytes(message.system_exclusive_info.buffer, data);
}

// Each message must contain only its own bytes, not those of earlier messages.
test_consecutive_messages :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    messages := ([] u8).[
        u8.[0xf0, 0x01, 0x02, 0xf7],
        u8.[0xf0, 0x0a, 0xf7],
        u8.[0xf0, 0x7e, 0x7f, 0x06, 0x01, 0xf7],
    ];

    for messages {
        decoded, message := decode_midi_packet(*decoder, it);
        check(decoded, "Message % was not decoded.", it_index);
        check_bytes(message.system_exclusive_info.buffer, it, tprint("message %", it_index));
    }
}

// Drivers deliver long messages in pieces of whatever size their buffers have. Every chunk size must give the same
// result, and the message must only be reported once its last chunk arrives.
test_chunk_sizes :: () {
    data := make_sysex(100, seed = 3);
    defer array_free(data);

    for chunk_size: int.[1, 2, 3, 7, 16, 64, 99, 100] {
        decoder: MIDI_Decoder;
        defer array_free(decoder.system_exclusive_message_buffer);

        decoded_early := false;
        decoded: bool;
        message: MIDI_Message;

        offset := 0;
        while offset < data.count {
            count := min(chunk_size, data.count - offset);
            decoded, message = decode_midi_packet(*decoder, slice(data, offset, count));
            offset += count;
            if decoded && offset < data.count  decoded_early = true;
        }

        check(!decoded_early, "With chunks of % bytes, the message was reported before its last chunk.", chunk_size);
        check(decoded, "With chunks of % bytes, the message was not decoded.", chunk_size);
        if decoded  check_bytes(message.system_exclusive_info.buffer, data, tprint("chunks of % bytes", chunk_size));
    }
}

test_large_message :: () {
    data := make_sysex(65536, seed = 11);
    defer array_free(data);

    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decoded: bool;
    message: MIDI_Message;
    offset := 0;
    while offset < data.count {
        count := min(1024, data.count - offset);
        decoded, message = decode_midi_packet(*decoder, slice(data, offset, count));
        offset += count;
    }

    check(decoded, "The message was not decoded.");
    if decoded  check_bytes(message.system_exclusive_info.buffer, data);
}

// MIDI allows realtime messages in the middle of a system-exclusive message. They must be delivered without disturbing
// the message.
test_realtime_between_chunks :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decode_midi_packet(*decoder, u8.[0xf0, 0x01, 0x02]);

    decoded, message := decode_midi_packet(*decoder, u8.[0xf8]);
    check(decoded && message.status == .Timing_Clock, "The realtime message was not decoded (got %).", message.status);
    check(decoder.system_exclusive_message_in_progress, "The realtime message ended the system-exclusive message.");

    decoded, message = decode_midi_packet(*decoder, u8.[0x03, 0xf7]);
    check(decoded, "The message was not decoded after the realtime message.");
    if decoded  check_bytes(message.system_exclusive_info.buffer, u8.[0xf0, 0x01, 0x02, 0x03, 0xf7]);
}

// The same as above, but with the realtime byte inside a chunk, as raw byte streams deliver it. The decoder can only
// return one message per call, so delivering the realtime message as well needs a change to its interface; this test
// only checks that the byte is not stored in the system-exclusive message.
test_realtime_inside_chunk :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decoded, message := decode_midi_packet(*decoder, u8.[0xf0, 0x01, 0xf8, 0x02, 0xf7]);
    check(decoded, "The message was not decoded.");
    if decoded  check_bytes(message.system_exclusive_info.buffer, u8.[0xf0, 0x01, 0x02, 0xf7]);
}

test_status_byte_inside_chunk :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decode_midi_packet(*decoder, u8.[0xf0, 0x01, 0x02, 0x90, 0x40, 0x7f]);
    check(!decoder.system_exclusive_message_in_progress, "A note-on status byte did not end the system-exclusive message.");

    decoded, message := decode_midi_packet(*decoder, u8.[0xf0, 0x09, 0xf7]);
    check(decoded, "The next message was not decoded.");
    if decoded  check_bytes(message.system_exclusive_info.buffer, u8.[0xf0, 0x09, 0xf7], "next message");
}

// Any status byte other than a realtime status or 0xf7 ends a system-exclusive message. The interrupted message is
// dropped, and the voice message must be decoded normally.
test_voice_message_interrupts :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decode_midi_packet(*decoder, u8.[0xf0, 0x01, 0x02]);

    decoded, message := decode_midi_packet(*decoder, u8.[0x90, 0x40, 0x7f]);
    check(decoded, "The note-on message was not decoded.");
    check(message.status == .Note_On, "Expected status Note_On, got %.", message.status);
    check(!decoder.system_exclusive_message_in_progress, "The interrupted message is still in progress.");

    // The next message must not contain any leftovers.
    decoded, message = decode_midi_packet(*decoder, u8.[0xf0, 0x05, 0xf7]);
    check(decoded, "The message after the interruption was not decoded.");
    if decoded  check_bytes(message.system_exclusive_info.buffer, u8.[0xf0, 0x05, 0xf7], "message after the interruption");
}

// A new 0xf0 drops the unfinished message and starts a new one.
test_restart_while_in_progress :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    decode_midi_packet(*decoder, u8.[0xf0, 0x01, 0x02]);
    decoded, message := decode_midi_packet(*decoder, u8.[0xf0, 0x03, 0xf7]);

    check(decoded, "The second message was not decoded.");
    if decoded  check_bytes(message.system_exclusive_info.buffer, u8.[0xf0, 0x03, 0xf7]);
}

// When an input opens in the middle of a message, the first bytes it receives are the rest of that message. These are
// not an error in the program, so they must be ignored without an assertion.
test_stray_continuation :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    assertions_before := library_assertions;

    decoded, message := decode_midi_packet(*decoder, u8.[0x01, 0x02, 0xf7]);
    check(!decoded, "Data bytes without a start were decoded as a % message.", message.status);

    decoded, message = decode_midi_packet(*decoder, u8.[0xf7]);
    check(!decoded, "A lone 0xf7 was decoded as a % message.", message.status);

    check(library_assertions == assertions_before, "Stray system-exclusive data triggered % assertion(s).", library_assertions - assertions_before);

    // The decoder must still work afterwards.
    decoded, message = decode_midi_packet(*decoder, u8.[0xf0, 0x04, 0xf7]);
    check(decoded, "The decoder did not recover from stray data.");
    if decoded  check_bytes(message.system_exclusive_info.buffer, u8.[0xf0, 0x04, 0xf7]);
}

test_create_system_exclusive_message :: () {
    data := u8.[0xf0, 0x01, 0x02, 0xf7];
    message := create_system_exclusive_message(data);

    check(message.status == .System_Exclusive, "Expected status System_Exclusive, got %.", message.status);
    check(message.system_exclusive_info.buffer.data == data.data && message.system_exclusive_info.buffer.count == data.count,
          "The message does not refer to the given buffer.");

    // A buffer without the start and end bytes must be rejected.
    assertions_before := library_assertions;
    create_system_exclusive_message(u8.[0x01, 0x02]);
    check(library_assertions > assertions_before, "A buffer without 0xf0 and 0xf7 was accepted.");
}

//
// Part 1: delivery from an input to its callback.
//

Delivered :: struct {
    status: MIDI_Status;
    bytes: [] u8;
}

Delivery_Log :: struct {
    messages: [..] Delivered;
}

recording_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    delivery_log := cast(*Delivery_Log) user_data;
    delivered: Delivered;
    delivered.status = message.status;

    // The buffer is only valid during the callback, so keep a copy.
    if message.status == .System_Exclusive  delivered.bytes = array_copy(message.system_exclusive_info.buffer);

    array_add(*delivery_log.messages, delivered);
}

make_test_input :: (delivery_log: *Delivery_Log) -> *MIDI_Input {
    input := New(MIDI_Input);
    input.callback = recording_callback;
    input.callback_data = delivery_log;
    return input;
}

// Does what the platform layers do with incoming bytes.
deliver :: (input: *MIDI_Input, bytes: [] u8) {
    decoded, message := decode_midi_packet(*input.decoder, bytes);
    if decoded  post_message_to_input(input, message, .{});
}

free_delivery_log :: (delivery_log: *Delivery_Log) {
    for delivery_log.messages  array_free(it.bytes);
    array_free(delivery_log.messages);
}

test_delivery_through_input :: () {
    delivery_log: Delivery_Log;
    defer free_delivery_log(*delivery_log);

    input := make_test_input(*delivery_log);
    defer free_input(input);

    first  := u8.[0xf0, 0x01, 0x02, 0xf7];
    second := u8.[0xf0, 0x03, 0xf7];
    deliver(input, first);
    deliver(input, second);

    check(delivery_log.messages.count == 2, "Expected 2 callbacks, got %.", delivery_log.messages.count);
    if delivery_log.messages.count == 2 {
        check_bytes(delivery_log.messages[0].bytes, first, "first message");
        check_bytes(delivery_log.messages[1].bytes, second, "second message");
    }
}

test_interrupted_delivery_through_input :: () {
    delivery_log: Delivery_Log;
    defer free_delivery_log(*delivery_log);

    input := make_test_input(*delivery_log);
    defer free_input(input);

    deliver(input, u8.[0xf0, 0x01]);
    deliver(input, u8.[0x90, 0x40, 0x7f]);
    deliver(input, u8.[0xf0, 0x05, 0xf7]);

    check(delivery_log.messages.count == 2, "Expected 2 callbacks (a note-on and a system-exclusive message), got %.", delivery_log.messages.count);
    if delivery_log.messages.count == 2 {
        check(delivery_log.messages[0].status == .Note_On, "Expected the first callback to be a note-on, got %.", delivery_log.messages[0].status);
        check(delivery_log.messages[1].status == .System_Exclusive, "Expected the second callback to be a system-exclusive message, got %.", delivery_log.messages[1].status);
        check_bytes(delivery_log.messages[1].bytes, u8.[0xf0, 0x05, 0xf7], "message after the interruption");
    }
}

//
// Part 1: the UMP decoder.
//

// Builds a 64-bit UMP that carries part of a 7-bit system-exclusive message (message type 0x3).
make_sysex7_packet :: (status: UMP_System_Exclusive_Status, payload: [] u8, group: u32 = 0) -> [2] u32 {
    assert(payload.count <= 6);
    bytes: [6] u8;
    for payload  bytes[it_index] = it;

    count := cast(u32) payload.count;

    result: [2] u32;
    result[0] = ((cast(u32) UMP_Message_Type.Data_System_Exclusive) << 28) | (group << 24) | ((cast(u32) status) << 20) | (count << 16)
              | ((cast(u32) bytes[0]) << 8) | (cast(u32) bytes[1]);
    result[1] = ((cast(u32) bytes[2]) << 24) | ((cast(u32) bytes[3]) << 16) | ((cast(u32) bytes[4]) << 8) | (cast(u32) bytes[5]);
    return result;
}

// Decodes a whole list of words, and returns the messages with copies of their system-exclusive buffers.
decode_all_ump_words :: (decoder: *MIDI_Decoder, words: [] u32) -> [..] Delivered {
    result: [..] Delivered;
    remaining := words;
    while remaining.count {
        decoded, message := decode_ump_words(decoder, *remaining);
        if !decoded  continue;

        delivered: Delivered;
        delivered.status = message.status;
        if message.status == .System_Exclusive  delivered.bytes = array_copy(message.system_exclusive_info.buffer);
        array_add(*result, delivered);
    }
    return result;
}

// A 7-bit system-exclusive UMP is always two words, whatever the number of bytes it carries.
test_ump_complete_packets :: () {
    for payload_size: 0..6 {
        payload: [6] u8;
        for 0..payload_size - 1  payload[it] = cast,trunc(u8) (0x10 + it);
        payload_slice: [] u8 = payload;
        payload_slice.count = payload_size;

        decoder: MIDI_Decoder;
        defer array_free(decoder.system_exclusive_message_buffer);

        packet := make_sysex7_packet(.Complete, payload_slice);
        words: [] u32 = packet;
        decoded, message := decode_ump_words(*decoder, *words);

        check(words.count == 0, "A complete packet with % bytes consumed % word(s) instead of 2.", payload_size, 2 - words.count);
        check(decoded, "A complete packet with % bytes was not decoded.", payload_size);

        if decoded {
            expected: [..] u8;
            defer array_free(expected);
            array_add(*expected, 0xf0);
            array_add(*expected, ..payload_slice);
            array_add(*expected, 0xf7);
            check_bytes(message.system_exclusive_info.buffer, expected, tprint("complete packet with % bytes", payload_size));
        }
    }
}

test_ump_multi_packet :: () {
    payload := make_sysex(17, seed = 5); // 0xf0, 15 data bytes, 0xf7.
    defer array_free(payload);
    data := slice(payload, 1, 15);

    words: [..] u32;
    defer array_free(words);
    for make_sysex7_packet(.Start,    slice(data, 0, 6))   array_add(*words, it);
    for make_sysex7_packet(.Continue, slice(data, 6, 6))   array_add(*words, it);
    for make_sysex7_packet(.End,      slice(data, 12, 3))  array_add(*words, it);

    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    messages := decode_all_ump_words(*decoder, words);
    defer { for messages  array_free(it.bytes); array_free(messages); }

    check(messages.count == 1, "Expected 1 message, got %.", messages.count);
    if messages.count == 1  check_bytes(messages[0].bytes, payload);
}

test_ump_followed_by_voice_message :: () {
    words: [..] u32;
    defer array_free(words);
    for make_sysex7_packet(.Complete, u8.[0x7e, 0x7f, 0x06, 0x01])  array_add(*words, it);
    array_add(*words, make_ump_word(.MIDI_1_Voice, 0, 0x90, 0x40, 0x7f));

    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    messages := decode_all_ump_words(*decoder, words);
    defer { for messages  array_free(it.bytes); array_free(messages); }

    check(messages.count == 2, "Expected 2 messages (a system-exclusive message and a note-on), got %.", messages.count);
    if messages.count == 2 {
        check(messages[0].status == .System_Exclusive, "Expected the first message to be system-exclusive, got %.", messages[0].status);
        check_bytes(messages[0].bytes, u8.[0xf0, 0x7e, 0x7f, 0x06, 0x01, 0xf7]);
        check(messages[1].status == .Note_On, "Expected the second message to be a note-on, got %.", messages[1].status);
    }
}

// Like test_stray_continuation, but for UMPs.
test_ump_stray_continue :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    assertions_before := library_assertions;

    words: [..] u32;
    defer array_free(words);
    for make_sysex7_packet(.Continue, u8.[0x01, 0x02])  array_add(*words, it);
    for make_sysex7_packet(.End,      u8.[0x03])        array_add(*words, it);

    messages := decode_all_ump_words(*decoder, words);
    defer { for messages  array_free(it.bytes); array_free(messages); }

    check(messages.count == 0, "Packets without a start produced % message(s).", messages.count);
    check(library_assertions == assertions_before, "Packets without a start triggered % assertion(s).", library_assertions - assertions_before);
}

// A packet can claim to carry up to 15 bytes, but only 6 fit. Such packets must be rejected. Currently the decoder writes
// past the end of a stack buffer.
test_ump_invalid_byte_count :: () {
    decoder: MIDI_Decoder;
    defer array_free(decoder.system_exclusive_message_buffer);

    packet := make_sysex7_packet(.Complete, u8.[0x01, 0x02, 0x03, 0x04, 0x05, 0x06]);
    packet[0] |= (0xf << 16); // Claim 15 bytes.

    words: [] u32 = packet;
    decoded, message := decode_ump_words(*decoder, *words);
    check(!decoded, "A packet with an invalid byte count was decoded.");
    check(words.count == 0, "A packet with an invalid byte count consumed % word(s) instead of 2.", 2 - words.count);
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
    messages: [MAX_LOOPBACK_MESSAGES] Delivered;
}

loopback_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    state := cast(*Loopback_State) user_data;
    index := atomic_add(*state.write_count, 1);
    defer signal(*state.received);

    if index >= MAX_LOOPBACK_MESSAGES  return;

    record := *state.messages[index];
    record.status = message.status;
    if message.status == .System_Exclusive  record.bytes = array_copy(message.system_exclusive_info.buffer);
}

// Returns the next message the callback received, in order.
next_message :: (state: *Loopback_State, timeout_ms: s32 = LOOPBACK_TIMEOUT_MS) -> bool, Delivered {
    if wait_for(*state.received, timeout_ms) != .SUCCESS  return false, .{};

    index := state.read_cursor;
    state.read_cursor += 1;
    if index >= MAX_LOOPBACK_MESSAGES  return false, .{};
    return true, state.messages[index];
}

// Returns the next system-exclusive message, skipping any other messages.
next_sysex :: (state: *Loopback_State) -> bool, Delivered {
    while true {
        received, message := next_message(state);
        if !received  return false, .{};
        if message.status == .System_Exclusive  return true, message;
    }
    return false, .{};
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
        skip_test("Loopback tests", tprint("no MIDI loopback named '%' was found", loopback_name));
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

    begin_test("Messages of various sizes"); test_loopback_sizes(state, output);       end_test();
    begin_test("The same message twice");    test_loopback_repeat(state, output);      end_test();
    begin_test("Interleaved with a note");   test_loopback_interleaved(state, output); end_test();
    begin_test("Burst of messages");         test_loopback_burst(state, output);       end_test();
}

// The sizes include the 0xf0 and 0xf7 bytes. They are chosen around the buffer sizes of the different backends: the
// 16-byte ALSA encoder, the 6 bytes that fit in a UMP, and the 16 buffers of 1024 bytes on Windows.
test_loopback_sizes :: (state: *Loopback_State, output: *MIDI_Output) {
    for size: int.[2, 3, 6, 7, 8, 12, 16, 17, 32, 100, 255, 256, 257, 1000, 1023, 1024, 1025, 2048, 4096, 16384, 16385, 65536] {
        print("Sending % byte message...\n", size);
        data := make_sysex(size, seed = size);
        defer array_free(data);

        sent := send_midi_message(output, create_system_exclusive_message(data));
        check(sent, "A message of % bytes could not be sent.", size);
        if !sent  continue;

        received, message := next_sysex(state);
        check(received, "A message of % bytes was not received.", size);
        if !received {
            drain(state); // Don't let a late arrival be compared with the next message.
            continue;
        }

        check_bytes(message.bytes, data, tprint("message of % bytes", size));
    }
}

test_loopback_repeat :: (state: *Loopback_State, output: *MIDI_Output) {
    data := u8.[0xf0, 0x7d, 0x12, 0x34, 0xf7];

    for 1..2 {
        send_midi_message(output, create_system_exclusive_message(data));
        received, message := next_sysex(state);
        check(received, "Message % was not received.", it);
        if received  check_bytes(message.bytes, data, tprint("message %", it));
    }
}

test_loopback_interleaved :: (state: *Loopback_State, output: *MIDI_Output) {
    first  := u8.[0xf0, 0x7d, 0x01, 0x02, 0x03, 0xf7];
    second := u8.[0xf0, 0x7d, 0x04, 0x05, 0x06, 0xf7];

    send_midi_message(output, create_system_exclusive_message(first));
    send_midi_message(output, create_midi_message(.Note_On, 0x40, 0x7f));
    send_midi_message(output, create_system_exclusive_message(second));

    expected_statuses := MIDI_Status.[.System_Exclusive, .Note_On, .System_Exclusive];
    expected_bytes    := ([] u8).[first, first /* Unused: not a system-exclusive message. */, second];

    for expected_statuses {
        received, message := next_message(state);
        check(received, "Message % was not received.", it_index);
        if !received  break;

        check(message.status == it, "Expected message % to be %, got %.", it_index, it, message.status);
        if message.status == .System_Exclusive  check_bytes(message.bytes, expected_bytes[it_index], tprint("message %", it_index));
    }
}

test_loopback_burst :: (state: *Loopback_State, output: *MIDI_Output) {
    BURST_COUNT :: 10;

    messages: [BURST_COUNT] [] u8;
    for * messages  it.* = make_sysex(200 + it_index * 37, seed = it_index);
    defer for messages  array_free(it);

    for messages  send_midi_message(output, create_system_exclusive_message(it));

    for messages {
        received, message := next_sysex(state);
        check(received, "Message % of the burst was not received.", it_index);
        if !received  break;
        check_bytes(message.bytes, it, tprint("message % of the burst", it_index));
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

// Makes a system-exclusive message of the given total size, including the 0xf0 and 0xf7 bytes.
make_sysex :: (size: int, seed: int) -> [] u8 {
    assert(size >= 2);
    result := NewArray(size, u8);
    result[0] = 0xf0;
    for 1..size - 2  result[it] = cast,trunc(u8) ((it * 7 + seed) % 128);
    result[size - 1] = 0xf7;
    return result;
}

slice :: (array: [] $T, start: int, count: int) -> [] T {
    result: [] T = ---;
    result.data = array.data + start;
    result.count = count;
    return result;
}
