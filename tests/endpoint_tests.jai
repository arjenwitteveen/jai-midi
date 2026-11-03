//
// Tests for endpoints, and for opening and closing inputs and outputs.
//
// Part 1 needs no particular MIDI setup. It checks that every endpoint the system reports has a name and info, that
// endpoints can be found by name, that invalid indices are handled without assertions, and that every input has its
// own decoder.
//
// Part 2 opens and closes inputs and outputs on a loopback, and checks that messages still arrive, that callbacks get
// the right arguments, that no callbacks run after close_input returns, and that nothing leaks:
//
//   - Windows: a loopback driver such as loopMIDI. By default a port whose name contains "loopMIDI" is used.
//   - Linux:   the ALSA 'Midi Through' port (snd-seq-dummy), which is present on most systems.
//   - macOS:   a virtual output created by the test itself, which the test then opens as an input.
//
// You can pass a different (partial) endpoint name as the first argument; it is used to find both the source and the
// destination. If no loopback is found, part 2 is skipped. Build and run the tests with:
//
//   jai tests/endpoint_tests.jai
//   ./endpoint_tests [loopback_name]
//
// Some of these tests describe behavior the module doesn't have yet, so not all of them pass. Each test states the
// intended behavior. Assertions inside the module are recorded instead of stopping the program, so one failure doesn't
// hide the others.
//

VERBOSE_LOGGING :: false;
CLIENT_NAME     :: "jai-midi-endpoint-test";

// Loaded rather than imported, so that the tests can reach the decoder, which is internal to the module.
#load "../midi.jai";

#import "Atomics";

#if OS == .WINDOWS {
    DEFAULT_LOOPBACK_NAME :: "loopMIDI";
} else #if OS == .LINUX {
    DEFAULT_LOOPBACK_NAME :: "Midi Through";
} else {
    DEFAULT_LOOPBACK_NAME :: "jai-midi endpoint test";
}

// Indices that no system has endpoints for, besides the ones just past the end of the lists.
LARGE_BAD_INDEX      :: 12345;
NEGATIVE_BAD_INDICES :: int.[-1, -12345];

// Tests that can crash with the current code. Enable them while working on the code they test.
RUN_UNSAFE_TESTS :: true;

// A name that no endpoint has.
MISSING_NAME :: "jai-midi: there is no endpoint with this name";

main :: () {
    context.assertion_failed = recording_assertion_handler;

    #if 1 {
        print("\n----- Endpoint tests -----\n");

        print("\n% source(s), % destination(s).\n", get_number_of_sources(), get_number_of_destinations());
        for 0..get_number_of_sources() - 1       print("  source %:      %\n", it, get_source_name(it));
        for 0..get_number_of_destinations() - 1  print("  destination %: %\n", it, get_destination_name(it));

        run_test("Endpoint counts",                             test_endpoint_counts);
        run_test("Every source has a name and info",            test_source_names_and_info);
        run_test("Every destination has a name and info",       test_destination_names_and_info);
        run_test("Invalid source indices",                      test_bad_source_indices);
        run_test("Invalid destination indices",                 test_bad_destination_indices);
        #if RUN_UNSAFE_TESTS {
            run_test("Negative source indices",                 test_negative_source_indices);
            run_test("Negative destination indices",            test_negative_destination_indices);
        }
        run_test("Finding endpoints by their full name",        test_find_by_full_name);
        run_test("Finding endpoints by part of their name",     test_find_by_partial_name);
        run_test("Full-name search ignores partial matches",    test_full_name_ignores_partial_matches);
        run_test("Finding a name that doesn't exist",           test_find_missing_name);
        run_test("Closing null inputs and outputs",             test_close_null);
        run_test("Every input has its own decoder",             test_inputs_have_own_decoder);
        #if OS == .MACOS {
            run_test("Virtual endpoints appear and disappear",  test_virtual_endpoints);
        }
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
// Part 1: endpoint info.
//

test_endpoint_counts :: () {
    sources      := get_number_of_sources();
    destinations := get_number_of_destinations();
    check(sources >= 0, "get_number_of_sources returned %.", sources);
    check(destinations >= 0, "get_number_of_destinations returned %.", destinations);

    // The counts must not change between calls when no devices are added or removed.
    check(get_number_of_sources() == sources, "The number of sources changed between two calls.");
    check(get_number_of_destinations() == destinations, "The number of destinations changed between two calls.");
}

test_source_names_and_info :: () {
    check_endpoints("source", get_number_of_sources(), get_source_name, source_info_found);
}

test_destination_names_and_info :: () {
    check_endpoints("destination", get_number_of_destinations(), get_destination_name, destination_info_found);
}

check_endpoints :: (kind: string, count: int, get_name: (int) -> string, info_found: (int) -> bool, loc := #caller_location) {
    for 0..count - 1 {
        name := get_name(it);
        check(name.count > 0, "The % with index % has no name.", kind, it, loc = loc);
        check(get_name(it) == name, "The name of the % with index % changed between two calls.", kind, it, loc = loc);
        check(info_found(it), "No info was found for the % with index %.", kind, it, loc = loc);
    }
}

source_info_found :: (index: int) -> bool {
    found := get_source_info(index);
    return found;
}

destination_info_found :: (index: int) -> bool {
    found := get_destination_info(index);
    return found;
}

// Invalid indices are reported through return values. They are a runtime condition (a device can disappear between
// counting and opening), not a programming error, so they must not trigger assertions.
test_bad_source_indices :: () {
    count := get_number_of_sources();
    check_bad_source_indices(int.[count, count + 1, LARGE_BAD_INDEX]);
}

test_bad_destination_indices :: () {
    count := get_number_of_destinations();
    check_bad_destination_indices(int.[count, count + 1, LARGE_BAD_INDEX]);
}

// Negative indices currently crash on Windows, in a cast bounds check in get_source_info and get_destination_info.
test_negative_source_indices :: () {
    check_bad_source_indices(NEGATIVE_BAD_INDICES);
}

test_negative_destination_indices :: () {
    check_bad_destination_indices(NEGATIVE_BAD_INDICES);
}

check_bad_source_indices :: (indices: [] int, loc := #caller_location) {
    assertions_before := library_assertions;

    push_silent_logger();
    for indices {
        name := get_source_name(it);
        check(name == "", "get_source_name(%) returned '%' instead of an empty string.", it, name, loc = loc);

        found := get_source_info(it);
        check(!found, "get_source_info(%) reported success.", it, loc = loc);

        input := open_input(it, ignoring_callback);
        check(input == null, "open_input(%) returned an input.", it, loc = loc);
        close_input(input);
    }
    pop_logger();

    check(library_assertions == assertions_before, "Invalid source indices triggered % assertion(s).", library_assertions - assertions_before, loc = loc);
}

check_bad_destination_indices :: (indices: [] int, loc := #caller_location) {
    assertions_before := library_assertions;

    push_silent_logger();
    for indices {
        name := get_destination_name(it);
        check(name == "", "get_destination_name(%) returned '%' instead of an empty string.", it, name, loc = loc);

        found := get_destination_info(it);
        check(!found, "get_destination_info(%) reported success.", it, loc = loc);

        output := open_output(it);
        check(output == null, "open_output(%) returned an output.", it, loc = loc);
        close_output(output);
    }
    pop_logger();

    check(library_assertions == assertions_before, "Invalid destination indices triggered % assertion(s).", library_assertions - assertions_before, loc = loc);
}

// Searching for an endpoint's full name finds the first endpoint with that name. Several endpoints can have the same
// name, for example two identical devices.
test_find_by_full_name :: () {
    for 0..get_number_of_sources() - 1 {
        name := get_source_name(it);
        found := get_source_index_by_name(name, match_full_name = true);
        if !check(found >= 0 && found <= it, "Searching for source '%' (index %) returned index %.", name, it, found)  continue;
        check(get_source_name(found) == name, "Searching for source '%' found source '%'.", name, get_source_name(found));
    }

    for 0..get_number_of_destinations() - 1 {
        name := get_destination_name(it);
        found := get_destination_index_by_name(name, match_full_name = true);
        if !check(found >= 0 && found <= it, "Searching for destination '%' (index %) returned index %.", name, it, found)  continue;
        check(get_destination_name(found) == name, "Searching for destination '%' found destination '%'.", name, get_destination_name(found));
    }
}

// By default, searching finds the first endpoint whose name contains the given text.
test_find_by_partial_name :: () {
    for 0..get_number_of_sources() - 1 {
        name := get_source_name(it);
        if name.count < 2  continue;
        part := slice(name, 1, name.count - 1);

        found := get_source_index_by_name(part);
        if !check(found >= 0 && found <= it, "Searching for '%' (part of source % '%') returned index %.", part, it, name, found)  continue;
        check(contains(get_source_name(found), part), "Searching for '%' found source '%', which doesn't contain it.", part, get_source_name(found));
    }

    for 0..get_number_of_destinations() - 1 {
        name := get_destination_name(it);
        if name.count < 2  continue;
        part := slice(name, 1, name.count - 1);

        found := get_destination_index_by_name(part);
        if !check(found >= 0 && found <= it, "Searching for '%' (part of destination % '%') returned index %.", part, it, name, found)  continue;
        check(contains(get_destination_name(found), part), "Searching for '%' found destination '%', which doesn't contain it.", part, get_destination_name(found));
    }
}

test_full_name_ignores_partial_matches :: () {
    for 0..get_number_of_sources() - 1 {
        name := get_source_name(it);
        if name.count < 2  continue;
        part := slice(name, 0, name.count - 1);
        if is_full_source_name(part)  continue;

        found := get_source_index_by_name(part, match_full_name = true);
        check(found == -1, "A full-name search for '%' found source % '%'.", part, found, ifx found >= 0 then get_source_name(found) else "");
    }

    for 0..get_number_of_destinations() - 1 {
        name := get_destination_name(it);
        if name.count < 2  continue;
        part := slice(name, 0, name.count - 1);
        if is_full_destination_name(part)  continue;

        found := get_destination_index_by_name(part, match_full_name = true);
        check(found == -1, "A full-name search for '%' found destination % '%'.", part, found, ifx found >= 0 then get_destination_name(found) else "");
    }
}

is_full_source_name :: (name: string) -> bool {
    for 0..get_number_of_sources() - 1  if get_source_name(it) == name  return true;
    return false;
}

is_full_destination_name :: (name: string) -> bool {
    for 0..get_number_of_destinations() - 1  if get_destination_name(it) == name  return true;
    return false;
}

test_find_missing_name :: () {
    check(get_source_index_by_name(MISSING_NAME) == -1, "A source was found for a name that doesn't exist.");
    check(get_source_index_by_name(MISSING_NAME, match_full_name = true) == -1, "A source was found for a full name that doesn't exist.");
    check(get_destination_index_by_name(MISSING_NAME) == -1, "A destination was found for a name that doesn't exist.");
    check(get_destination_index_by_name(MISSING_NAME, match_full_name = true) == -1, "A destination was found for a full name that doesn't exist.");
}

// Closing null does nothing, like free(null), so that cleanup code doesn't need to check what was opened.
test_close_null :: () {
    assertions_before := library_assertions;
    close_input(null);
    close_output(null);
    check(library_assertions == assertions_before, "Closing null triggered % assertion(s).", library_assertions - assertions_before);
}

//
// Part 1: decoders of different inputs.
//

Delivery_Log :: struct {
    messages: [..] MIDI_Message;
}

recording_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    delivery_log := cast(*Delivery_Log) user_data;
    array_add(*delivery_log.messages, message);
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

// Running status and unfinished system-exclusive messages belong to the stream of one input. Several inputs that are
// open at the same time must not see each other's state.
test_inputs_have_own_decoder :: () {
    log_a: Delivery_Log;
    log_b: Delivery_Log;
    defer array_free(log_a.messages);
    defer array_free(log_b.messages);

    input_a := make_test_input(*log_a);
    input_b := make_test_input(*log_b);
    defer free_input(input_a);
    defer free_input(input_b);

    // Running status on input A must not apply to input B.
    deliver(input_a, u8.[0x90, 0x40, 0x7f]);
    deliver(input_b, u8.[0x41, 0x7f]);
    check(log_b.messages.count == 0, "Input B decoded data bytes with the running status of input A.");

    // A system-exclusive message in progress on input A must not be interrupted by a message on input B.
    deliver(input_a, u8.[0xf0, 0x01, 0x02]);
    deliver(input_b, u8.[0xb0, 0x07, 0x64]);
    check(input_a.decoder.system_exclusive_message_in_progress, "A message on input B interrupted the system-exclusive message on input A.");
    check(!input_b.decoder.system_exclusive_message_in_progress, "Input B has a system-exclusive message in progress.");

    deliver(input_a, u8.[0x03, 0xf7]);
    if check(log_a.messages.count == 2, "Expected 2 messages on input A, got %.", log_a.messages.count) {
        check(log_a.messages[1].status == .System_Exclusive, "Expected a system-exclusive message on input A, got %.", log_a.messages[1].status);
    }
    if check(log_b.messages.count == 1, "Expected 1 message on input B, got %.", log_b.messages.count) {
        check(log_b.messages[0].status == .Control_Change, "Expected a control change on input B, got %.", log_b.messages[0].status);
    }
}

//
// Part 1: virtual endpoints.
//

#if OS == .MACOS {

VIRTUAL_ENDPOINT_NAME :: "jai-midi endpoint test (virtual)";

// A virtual input shows up as a destination for other programs, and a virtual output as a source. They must disappear
// again when they are closed.
test_virtual_endpoints :: () {
    destinations_before := get_number_of_destinations();
    input := open_virtual_input(VIRTUAL_ENDPOINT_NAME, ignoring_callback);
    if check(input != null, "The virtual input could not be opened.") {
        check(wait_for_endpoint(get_destination_index_by_name, true), "The virtual input did not appear as a destination.");
        check(get_number_of_destinations() == destinations_before + 1, "Expected % destinations with the virtual input open, got %.", destinations_before + 1, get_number_of_destinations());

        close_input(input);
        check(wait_for_endpoint(get_destination_index_by_name, false), "The virtual input was still a destination after it was closed.");
        check(get_number_of_destinations() == destinations_before, "Expected % destinations after closing the virtual input, got %.", destinations_before, get_number_of_destinations());
    }

    sources_before := get_number_of_sources();
    output := open_virtual_output(VIRTUAL_ENDPOINT_NAME);
    if check(output != null, "The virtual output could not be opened.") {
        check(wait_for_endpoint(get_source_index_by_name, true), "The virtual output did not appear as a source.");
        check(get_number_of_sources() == sources_before + 1, "Expected % sources with the virtual output open, got %.", sources_before + 1, get_number_of_sources());

        close_output(output);
        check(wait_for_endpoint(get_source_index_by_name, false), "The virtual output was still a source after it was closed.");
        check(get_number_of_sources() == sources_before, "Expected % sources after closing the virtual output, got %.", sources_before, get_number_of_sources());
    }
}

// CoreMIDI publishes changes to its endpoints with a small delay.
wait_for_endpoint :: (find: (string, bool) -> int, present: bool) -> bool {
    for 1..40 {
        if (find(VIRTUAL_ENDPOINT_NAME, true) >= 0) == present  return true;
        sleep_milliseconds(50);
    }
    return false;
}

}

//
// Part 2: loopback.
//

CALLBACK_TIMEOUT_MS :: 5000;
MAX_RECEIVED        :: 4096;
REOPEN_COUNT        :: 20;

Loopback :: struct {
    output: *MIDI_Output;     // Stays open for all tests.
    source_index: int;
    destination_index: int;   // -1 if the output is a virtual endpoint, which can't be opened again by index.
}

Received :: struct {
    message: MIDI_Message;
    input: *MIDI_Input;
    user_data: *void;
}

Receiver :: struct {
    received: Semaphore;
    write_count: s64;
    read_cursor: s64;
    records: [MAX_RECEIVED] Received;
}

receiving_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    receiver := cast(*Receiver) user_data;
    index := atomic_add(*receiver.write_count, 1);
    defer signal(*receiver.received);

    if index >= MAX_RECEIVED  return;
    receiver.records[index] = .{message, input, user_data};
}

ignoring_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
}

new_receiver :: () -> *Receiver {
    receiver := New(Receiver);
    init(*receiver.received);
    return receiver;
}

free_receiver :: (receiver: *Receiver) {
    destroy(*receiver.received);
    free(receiver);
}

// Returns the next message the callback received, in order.
next_received :: (receiver: *Receiver, timeout_ms: s32 = CALLBACK_TIMEOUT_MS) -> bool, Received {
    if wait_for(*receiver.received, timeout_ms) != .SUCCESS  return false, .{};

    index := receiver.read_cursor;
    receiver.read_cursor += 1;
    if index >= MAX_RECEIVED  return false, .{};
    return true, receiver.records[index];
}

// Skips everything that has been received so far, waiting until nothing arrives for a while.
drain :: (receiver: *Receiver) {
    while next_received(receiver, 200) {}
}

// Inputs can miss messages sent right after they open, so wait until messages come through.
wait_until_connected :: (receiver: *Receiver, output: *MIDI_Output) -> bool {
    for 1..30 {
        send_midi_message(output, create_midi_message(.Note_Off, 0, 0));
        if next_received(receiver, 100) {
            drain(receiver);
            return true;
        }
    }
    return false;
}

// Opens an input on the loopback and waits until messages come through. Returns null if that fails.
open_connected_input :: (loopback: Loopback, receiver: *Receiver, loc := #caller_location) -> *MIDI_Input {
    input := open_input(loopback.source_index, receiving_callback, receiver);
    if !check(input != null, "The input could not be opened.", loc = loc)  return null;

    if !check(wait_until_connected(receiver, loopback.output), "No messages came through the newly opened input.", loc = loc) {
        close_input(input);
        return null;
    }

    return input;
}

// A note-on message that is different for each number, so that lost or reordered messages are noticed.
numbered_message :: (number: int) -> MIDI_Message {
    note     := cast,trunc(u8) (number % 128);
    velocity := cast,trunc(u8) (1 + (number / 128) % 127);
    return create_midi_message(.Note_On, note, velocity);
}

// Sends `count` numbered messages and checks that the receiver gets them in order.
send_and_expect_numbered :: (loopback: Loopback, receiver: *Receiver, count: int, what: string, output: *MIDI_Output = null, loc := #caller_location) -> bool {
    if !output  output = loopback.output;

    for 0..count - 1 {
        if !check(send_midi_message(output, numbered_message(it)), "Message % could not be sent (%).", it, what, loc = loc)  return false;
    }

    for 0..count - 1 {
        received, record := next_received(receiver);
        if !check(received, "Message % was not received (%).", it, what, loc = loc) {
            drain(receiver);
            return false;
        }

        expected := numbered_message(it);
        if !check(record.message.status == expected.status && record.message.bytes[0] == expected.bytes[0] && record.message.bytes[1] == expected.bytes[1],
                  "Message % arrived as % 0x% 0x% (%).", it, record.message.status, hex(record.message.bytes[0]), hex(record.message.bytes[1]), what, loc = loc) {
            drain(receiver);
            return false;
        }
    }

    return true;
}

run_loopback_tests :: (loopback_name: string, use_virtual_endpoint: bool) {
    found, loopback := find_loopback(loopback_name, use_virtual_endpoint);
    if !found {
        print("Skipped: no MIDI loopback named '%' was found. See the top of this file for how to set one up.\n", loopback_name);
        return;
    }
    defer close_output(loopback.output);

    print("Using loopback '%'.\n", loopback_name);

    begin_test("Callback arguments");                     test_callback_arguments(loopback);           end_test();
    begin_test("Opening and closing an input repeatedly"); test_reopen_input(loopback);                end_test();
    begin_test("Opening and closing an output repeatedly");test_reopen_output(loopback);               end_test();
    begin_test("Two inputs on one source");               test_two_inputs_one_source(loopback);        end_test();
    begin_test("Two outputs on one destination");         test_two_outputs_one_destination(loopback);  end_test();
    begin_test("No callbacks after close_input");         test_no_callbacks_after_close(loopback);     end_test();
    begin_test("close_input waits for a running callback"); test_close_waits_for_callback(loopback);   end_test();
    begin_test("No leaks when opening and closing");      test_no_leaks(loopback);                     end_test();
}

// The callback gets the input that open_input returned, and the user_data that was passed to it.
test_callback_arguments :: (loopback: Loopback) {
    receiver := new_receiver();
    defer free_receiver(receiver);

    input := open_connected_input(loopback, receiver);
    if !input  return;
    defer close_input(input);

    send_midi_message(loopback.output, numbered_message(0));
    received, record := next_received(receiver);
    if !check(received, "The message was not received.")  return;

    check(record.input == input, "The callback got input %, but open_input returned %.", record.input, input);
    check(record.user_data == receiver, "The callback got user_data %, but % was passed to open_input.", record.user_data, receiver);
}

test_reopen_input :: (loopback: Loopback) {
    receiver := new_receiver();
    defer free_receiver(receiver);

    for cycle: 1..REOPEN_COUNT {
        input := open_connected_input(loopback, receiver);
        if !input  return;

        ok := send_and_expect_numbered(loopback, receiver, 10, tprint("cycle %", cycle));
        close_input(input);
        if !ok  return;
    }
}

test_reopen_output :: (loopback: Loopback) {
    if loopback.destination_index < 0 {
        print("  Skipped: the loopback output is a virtual endpoint.\n");
        return;
    }

    receiver := new_receiver();
    defer free_receiver(receiver);

    input := open_connected_input(loopback, receiver);
    if !input  return;
    defer close_input(input);

    for cycle: 1..REOPEN_COUNT {
        output := open_output(loopback.destination_index);
        if !check(output != null, "The output could not be opened in cycle %.", cycle)  return;

        ok := send_and_expect_numbered(loopback, receiver, 10, tprint("cycle %", cycle), output);
        close_output(output);
        if !ok  return;
    }
}

// Every input that is open on a source gets every message.
test_two_inputs_one_source :: (loopback: Loopback) {
    receiver_a := new_receiver();
    receiver_b := new_receiver();
    defer free_receiver(receiver_a);
    defer free_receiver(receiver_b);

    input_a := open_connected_input(loopback, receiver_a);
    if !input_a  return;
    defer close_input(input_a);

    input_b := open_input(loopback.source_index, receiving_callback, receiver_b);
    if !check(input_b != null, "A second input could not be opened on the same source.")  return;
    defer close_input(input_b);

    // Both inputs need to be connected before counting starts.
    if !check(wait_until_connected(receiver_b, loopback.output), "No messages came through the second input.")  return;
    drain(receiver_a);

    for 0..49  send_midi_message(loopback.output, numbered_message(it));

    receivers := (*Receiver).[receiver_a, receiver_b];
    inputs    := (*MIDI_Input).[input_a, input_b];
    names     := string.["first input", "second input"];

    for receiver, receiver_index: receivers {
        name := names[receiver_index];
        for 0..49 {
            received, record := next_received(receiver);
            if !check(received, "Message % was not received on the %.", it, name)  break;
            expected := numbered_message(it);
            if !check(record.message.bytes[0] == expected.bytes[0] && record.message.bytes[1] == expected.bytes[1], "Message % on the % was out of order.", it, name)  break;
            check(record.input == inputs[receiver_index], "Message % on the % was delivered with the wrong input.", it, name);
        }
    }
}

test_two_outputs_one_destination :: (loopback: Loopback) {
    if loopback.destination_index < 0 {
        print("  Skipped: the loopback output is a virtual endpoint.\n");
        return;
    }

    receiver := new_receiver();
    defer free_receiver(receiver);

    input := open_connected_input(loopback, receiver);
    if !input  return;
    defer close_input(input);

    second_output := open_output(loopback.destination_index);
    if !check(second_output != null, "A second output could not be opened on the same destination.")  return;
    defer close_output(second_output);

    send_and_expect_numbered(loopback, receiver, 10, "first output");
    send_and_expect_numbered(loopback, receiver, 10, "second output", second_output);
    send_and_expect_numbered(loopback, receiver, 10, "first output again");
}

//
// Part 2: closing inputs while messages arrive.
//

Close_State :: struct {
    callbacks: s64;
    in_callback: s64;
    callback_sleep_ms: s32;
}

closing_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    state := cast(*Close_State) user_data;
    atomic_add(*state.in_callback, 1);
    atomic_add(*state.callbacks, 1);
    if state.callback_sleep_ms  sleep_milliseconds(state.callback_sleep_ms);
    atomic_add(*state.in_callback, -1);
}

Sender :: struct {
    output: *MIDI_Output;
    stop: s64;
}

// Keeps sending messages until it is told to stop.
sender_thread :: (thread: *Thread) -> s64 {
    sender := cast(*Sender) thread.data;
    number := 0;
    while !atomic_read(*sender.stop) {
        send_midi_message(sender.output, numbered_message(number));
        number += 1;
        sleep_milliseconds(1);
    }
    return 0;
}

// Closes an input on the loopback while messages keep arriving. Returns the number of callbacks that were running
// when close_input returned, and the number that started after it returned.
close_during_traffic :: (loopback: Loopback, callback_sleep_ms: s32) -> opened: bool, running_at_close: s64, after_close: s64 {
    // Late callbacks would write to this, so it is only freed after the sender has stopped and a while has passed.
    state := New(Close_State);
    defer free(state);
    state.callback_sleep_ms = callback_sleep_ms;

    sender: Sender;
    sender.output = loopback.output;

    thread: Thread;
    thread_init(*thread, sender_thread);
    thread.data = *sender;
    thread_start(*thread);
    defer {
        atomic_swap(*sender.stop, 1);
        while !thread_is_done(*thread, 100) {}
        thread_deinit(*thread);
        sleep_milliseconds(300);
    }

    input := open_input(loopback.source_index, closing_callback, state);
    if !input  return false, 0, 0;

    // Wait until messages are arriving.
    for 1..500 {
        if atomic_read(*state.callbacks) >= 20  break;
        sleep_milliseconds(10);
    }
    if atomic_read(*state.callbacks) < 20 {
        close_input(input);
        return false, 0, 0;
    }

    close_input(input);
    running_at_close   := atomic_read(*state.in_callback);
    callbacks_at_close := atomic_read(*state.callbacks);

    sleep_milliseconds(300);
    return true, running_at_close, atomic_read(*state.callbacks) - callbacks_at_close;
}

// Once close_input returns, the callback must never run again, so that the user_data can be freed right away.
test_no_callbacks_after_close :: (loopback: Loopback) {
    for round: 1..5 {
        opened, running_at_close, after_close := close_during_traffic(loopback, callback_sleep_ms = 0);
        if !check(opened, "No messages arrived on the input in round %.", round)  return;
        check(after_close == 0, "In round %, % callback(s) ran after close_input returned.", round, after_close);
        check(running_at_close == 0, "In round %, % callback(s) were still running when close_input returned.", round, running_at_close);
    }
}

// A callback that is running when close_input is called must have finished when close_input returns.
test_close_waits_for_callback :: (loopback: Loopback) {
    for round: 1..5 {
        opened, running_at_close, after_close := close_during_traffic(loopback, callback_sleep_ms = 20);
        if !check(opened, "No messages arrived on the input in round %.", round)  return;
        check(running_at_close == 0, "In round %, % callback(s) were still running when close_input returned.", round, running_at_close);
        check(after_close == 0, "In round %, % callback(s) ran after close_input returned.", round, after_close);
    }
}

//
// Part 2: leaks.
//

// Everything that opening an input or output allocates must be freed when it is closed, also when opening fails.
test_no_leaks :: (loopback: Loopback) {
    receiver := new_receiver();
    defer free_receiver(receiver);

    // The first open may set up state that lives as long as the program, so it is not counted.
    close_input(open_input(loopback.source_index, receiving_callback, receiver));
    if loopback.destination_index >= 0  close_output(open_output(loopback.destination_index));
    drain(receiver);

    tracking_context := context;
    tracking_context.allocator = .{tracking_allocator_proc, *tracking_state};
    tracking_context.logger = silent_logger;

    bytes_before := atomic_read(*tracking_state.outstanding_bytes);
    failed_opens := 0;
    timeouts := 0;

    push_context tracking_context {
        // Nothing in here should print, since that would allocate through the tracking allocator.
        for 1..REOPEN_COUNT {
            input := open_input(loopback.source_index, receiving_callback, receiver);
            if !input {
                failed_opens += 1;
                continue;
            }

            // Make the input do some work, so that allocations in callbacks are included.
            if !wait_until_connected(receiver, loopback.output)  timeouts += 1;
            for 0..9  send_midi_message(loopback.output, numbered_message(it));
            for 0..9  if !next_received(receiver, 1000)  timeouts += 1;
            close_input(input);

            if loopback.destination_index >= 0 {
                output := open_output(loopback.destination_index);
                if output  close_output(output);
                else       failed_opens += 1;
            }
        }

        close_input(open_input(LARGE_BAD_INDEX, receiving_callback, receiver));
        close_output(open_output(LARGE_BAD_INDEX));
    }

    bytes_after := atomic_read(*tracking_state.outstanding_bytes);
    drain(receiver);

    check(failed_opens == 0, "% input(s) or output(s) could not be opened.", failed_opens);
    check(timeouts == 0, "% message(s) were not received.", timeouts);
    check(bytes_after == bytes_before, "% bytes were still allocated after opening and closing % times.", bytes_after - bytes_before, REOPEN_COUNT);
}

Tracking_Allocator_State :: struct {
    outstanding_bytes: s64;
    outstanding_allocations: s64;
}

tracking_state: Tracking_Allocator_State;

// A thread-safe allocator that forwards to the default allocator and counts the bytes that are still allocated. Each
// block gets a header that stores its size, since FREE does not pass one in.
tracking_allocator_proc :: (mode: Allocator_Mode, size: s64, old_size: s64, old_memory: *void, allocator_data: *void) -> *void {
    state := cast(*Tracking_Allocator_State) allocator_data;

    if mode == {
        case .ALLOCATE;
            return tracked_allocate(state, size);

        case .RESIZE;
            new_memory := tracked_allocate(state, size);
            if !new_memory  return null;
            if old_memory {
                previous_size := (cast(*s64) (cast(*u8) old_memory - TRACKING_HEADER_SIZE)).*;
                memcpy(new_memory, old_memory, min(previous_size, size));
                tracked_free(state, old_memory);
            }
            return new_memory;

        case .FREE;
            tracked_free(state, old_memory);
            return null;

        case .CAPS;
            if old_memory { (cast(*string) old_memory).* = "Tracking_Allocator"; }
            return cast(*void) (Allocator_Caps.MULTIPLE_THREADS | .FREE | .ACTUALLY_RESIZE);
    }

    return null;
}

TRACKING_HEADER_SIZE :: 16; // Keeps the 16-byte alignment of the underlying allocator.

tracked_allocate :: (state: *Tracking_Allocator_State, size: s64) -> *void {
    base := Context_Base.default_allocator;
    block := cast(*u8) base.proc(.ALLOCATE, size + TRACKING_HEADER_SIZE, 0, null, base.data);
    if !block  return null;

    (cast(*s64) block).* = size;
    atomic_add(*state.outstanding_bytes, size);
    atomic_add(*state.outstanding_allocations, 1);
    return block + TRACKING_HEADER_SIZE;
}

tracked_free :: (state: *Tracking_Allocator_State, memory: *void) {
    if !memory  return;

    base := Context_Base.default_allocator;
    block := cast(*u8) memory - TRACKING_HEADER_SIZE;
    size := (cast(*s64) block).*;
    atomic_add(*state.outstanding_bytes, -size);
    atomic_add(*state.outstanding_allocations, -1);
    base.proc(.FREE, 0, 0, block, base.data);
}

find_loopback :: (name: string, use_virtual_endpoint: bool) -> found: bool, loopback: Loopback {
    loopback: Loopback;

    #if OS == .MACOS {
        if use_virtual_endpoint {
            output := open_virtual_output(name);
            if !output  return false, loopback;

            // Give CoreMIDI a moment to publish the new endpoint.
            for 1..20 {
                source_index := get_source_index_by_name(name, match_full_name = true);
                if source_index >= 0 {
                    loopback.output = output;
                    loopback.source_index = source_index;
                    loopback.destination_index = -1;
                    return true, loopback;
                }
                sleep_milliseconds(50);
            }

            close_output(output);
            return false, loopback;
        }
    }

    source_index      := get_source_index_by_name(name);
    destination_index := get_destination_index_by_name(name);
    if source_index < 0 || destination_index < 0  return false, loopback;

    output := open_output(destination_index);
    if !output  return false, loopback;

    loopback.output = output;
    loopback.source_index = source_index;
    loopback.destination_index = destination_index;
    return true, loopback;
}

//
// Helpers.
//

// Used where the module is expected to log errors, to keep the output readable.
silent_logger :: (message: string, data: *void, info: Log_Info) {
}

saved_logger: type_of(context.logger);

push_silent_logger :: () {
    saved_logger = context.logger;
    context.logger = silent_logger;
}

pop_logger :: () {
    context.logger = saved_logger;
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
