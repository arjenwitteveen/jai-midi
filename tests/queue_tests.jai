//
// Tests for MIDI_Queue, the single producer/single consumer queue that module.jai recommends for passing messages from
// an input callback to another thread.
//
// Part 1 needs no MIDI hardware. It tests the queue on its own: order, wrapping around, full and empty queues,
// timeouts, blocking between threads, and system-exclusive messages, whose buffers are only valid during the callback.
//
// Part 2 uses the queue the way module.jai recommends: an input callback queues the messages that arrive through a
// loopback, and the main thread takes them off the queue.
//
//   - Windows: a loopback driver such as loopMIDI. By default a port whose name contains "loopMIDI" is used.
//   - Linux:   the ALSA 'Midi Through' port (snd-seq-dummy), which is present on most systems.
//   - macOS:   a virtual input created by the test itself, which the test then opens as an output.
//
// You can pass a different (partial) endpoint name as the first argument; it is used to find both the source and the
// destination. If no loopback is found, part 2 is skipped. Build and run the tests with:
//
//   jai tests/queue_tests.jai
//   ./queue_tests [loopback_name]
//
// Some of these tests describe behavior the module doesn't have yet, so not all of them pass. Each test states the
// intended behavior. Assertions inside the module are recorded instead of stopping the program, so one failure doesn't
// hide the others.
//

VERBOSE_LOGGING :: false;
CLIENT_NAME     :: "jai-midi-queue-test";

// Loaded rather than imported, like the other tests.
#load "../midi.jai";
#load "../queue.jai";

#import "Atomics";

#if OS == .WINDOWS {
    DEFAULT_LOOPBACK_NAME :: "loopMIDI";
} else #if OS == .LINUX {
    DEFAULT_LOOPBACK_NAME :: "Midi Through";
} else {
    DEFAULT_LOOPBACK_NAME :: "jai-midi queue test";
}

// How long a timeout may take beyond what was asked for. Generous, since thread scheduling varies.
TIMING_TOLERANCE_MS :: 500;

main :: () {
    context.assertion_failed = recording_assertion_handler;

    #if 1 {
        print("\n----- Queue tests -----\n");

        run_test("Empty queue",                                test_empty_queue);
        run_test("Messages come out in order",                 test_order);
        run_test("Every type of message is kept intact",       test_message_contents);
        run_test("Wrapping around",                            test_wrap_around);
        run_test("Full queue",                                 test_full_queue);
        run_test("Timeouts",                                   test_timeouts);
        run_test("Reinitializing a queue that holds messages", test_reinitialize);
        run_test("Consumer waits for the producer",            test_consumer_waits);
        run_test("Producer waits for the consumer",            test_producer_waits);
        run_test("Producer and consumer threads",              test_threads);
        run_test("System-exclusive messages",                  test_system_exclusive);
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
// Part 1: the queue on its own.
//

test_empty_queue :: () {
    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    dequeued, message := dequeue_message(*queue, 0);
    check(!dequeued, "A message (%) was taken off an empty queue.", message.status);
}

test_order :: () {
    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    for 0..9  check(queue_message(*queue, numbered_message(it), 0), "Message % could not be queued.", it);

    for 0..9 {
        dequeued, message := dequeue_message(*queue, 0);
        if !check(dequeued, "Message % was not dequeued.", it)  return;
        check_numbered(message, it);
    }

    dequeued := dequeue_message(*queue, 0);
    check(!dequeued, "The queue still had messages after all were taken off.");
}

test_message_contents :: () {
    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    messages := MIDI_Message.[
        create_midi_message(.Note_On, 0x3c, 0x64, channel = 15),
        create_midi_message(.Polyphonic_Pressure, 0x30, 0x21, channel = 4),
        create_control_change_message(.Sustain_Pedal, 0x7f, channel = 9),
        create_midi_message(.Program_Change, 0x29, channel = 6),
        create_pitch_bend_message(U14_MAX, channel = 3),
        create_midi_message(.Song_Position_Pointer, 0x10, 0x20),
        create_midi_message(.Timing_Clock),
    ];

    for messages  queue_message(*queue, it, 0);

    for messages {
        dequeued, message := dequeue_message(*queue, 0);
        if !check(dequeued, "Message % was not dequeued.", it_index)  return;
        check(message.status == it.status && message.channel == it.channel && message.bytes[0] == it.bytes[0] && message.bytes[1] == it.bytes[1],
              "Message % was % on channel % with data bytes %, expected % on channel % with data bytes %.", it_index,
              message.status, message.channel, message.bytes, it.status, it.channel, it.bytes);
    }
}

// The queue is a ring buffer, so it must keep working after its cursors wrap around, also when it is never emptied.
test_wrap_around :: () {
    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    next_in  := 0;
    next_out := 0;

    // Keep the queue partly filled, so that the cursors wrap around at different times.
    for 1..3  { queue_message(*queue, numbered_message(next_in), 0); next_in += 1; }

    for round: 1..MIDI_QUEUE_LENGTH * 5 {
        for 1..(round % 4) + 1 {
            if !check(queue_message(*queue, numbered_message(next_in), 0), "Message % could not be queued.", next_in)  return;
            next_in += 1;
        }

        for 1..(round % 4) + 1 {
            dequeued, message := dequeue_message(*queue, 0);
            if !check(dequeued, "Message % was not dequeued.", next_out)  return;
            if !check_numbered(message, next_out)  return;
            next_out += 1;
        }
    }
}

// A full queue rejects new messages without overwriting the ones it holds, and accepts them again once there is room.
test_full_queue :: () {
    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    for 0..MIDI_QUEUE_LENGTH - 1  check(queue_message(*queue, numbered_message(it), 0), "Message % could not be queued.", it);
    check(!queue_message(*queue, numbered_message(1000), 0), "A message was added to a full queue.");

    dequeued, message := dequeue_message(*queue, 0);
    if check(dequeued, "No message could be taken off the full queue.")  check_numbered(message, 0);

    check(queue_message(*queue, numbered_message(MIDI_QUEUE_LENGTH), 0), "No message could be added after making room.");

    for 1..MIDI_QUEUE_LENGTH {
        dequeued, message = dequeue_message(*queue, 0);
        if !check(dequeued, "Message % was not dequeued.", it)  return;
        if !check_numbered(message, it)  return;
    }
}

// A timeout on an empty or full queue returns after roughly that time.
test_timeouts :: () {
    TIMEOUT_MS :: 100;

    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    start := current_time_monotonic();
    dequeued := dequeue_message(*queue, TIMEOUT_MS);
    elapsed := to_milliseconds(current_time_monotonic() - start);
    check(!dequeued, "A message was taken off an empty queue.");
    check(elapsed >= TIMEOUT_MS - 20 && elapsed <= TIMEOUT_MS + TIMING_TOLERANCE_MS, "Waiting on an empty queue took % ms, expected about % ms.", elapsed, TIMEOUT_MS);

    for 0..MIDI_QUEUE_LENGTH - 1  queue_message(*queue, numbered_message(it), 0);

    start = current_time_monotonic();
    queued := queue_message(*queue, numbered_message(1000), TIMEOUT_MS);
    elapsed = to_milliseconds(current_time_monotonic() - start);
    check(!queued, "A message was added to a full queue.");
    check(elapsed >= TIMEOUT_MS - 20 && elapsed <= TIMEOUT_MS + TIMING_TOLERANCE_MS, "Waiting on a full queue took % ms, expected about % ms.", elapsed, TIMEOUT_MS);
}

// After deinit and init, a queue is empty, even if it held messages before.
test_reinitialize :: () {
    queue: MIDI_Queue;
    init(*queue);
    for 0..2  queue_message(*queue, numbered_message(it), 0);
    deinit(*queue);

    init(*queue);
    defer deinit(*queue);

    dequeued, message := dequeue_message(*queue, 0);
    check(!dequeued, "A reinitialized queue still had a message (%).", message.status);

    queue_message(*queue, numbered_message(100), 0);
    dequeued, message = dequeue_message(*queue, 0);
    if check(dequeued, "The message queued after reinitializing was not dequeued.")  check_numbered(message, 100, "first message after reinitializing");
}

//
// Part 1: threads.
//

Thread_Job :: struct {
    queue: *MIDI_Queue;
    count: int;
    delay_ms: s32;
    failures: s64;
}

// Queues `count` numbered messages, waiting as long as needed for room.
producer_thread :: (thread: *Thread) -> s64 {
    job := cast(*Thread_Job) thread.data;
    if job.delay_ms  sleep_milliseconds(job.delay_ms);

    for 0..job.count - 1 {
        if !queue_message(job.queue, numbered_message(it))  atomic_add(*job.failures, 1);
    }
    return 0;
}

// Takes `count` messages off the queue and checks that they are numbered in order.
consumer_thread :: (thread: *Thread) -> s64 {
    job := cast(*Thread_Job) thread.data;
    if job.delay_ms  sleep_milliseconds(job.delay_ms);

    for 0..job.count - 1 {
        dequeued, message := dequeue_message(job.queue, 5000);
        if !dequeued || !is_numbered(message, it)  atomic_add(*job.failures, 1);
    }
    return 0;
}

start_thread :: (thread: *Thread, procedure: Thread_Proc, job: *Thread_Job) {
    thread_init(thread, procedure);
    thread.data = job;
    thread_start(thread);
}

finish_thread :: (thread: *Thread) -> bool {
    done := thread_is_done(thread, 10000);
    if done  thread_deinit(thread);
    return done;
}

// A consumer that waits without a timeout is woken up as soon as a message is queued.
test_consumer_waits :: () {
    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    job := Thread_Job.{queue = *queue, count = 1, delay_ms = 100};
    thread: Thread;
    start_thread(*thread, producer_thread, *job);

    start := current_time_monotonic();
    dequeued, message := dequeue_message(*queue);
    elapsed := to_milliseconds(current_time_monotonic() - start);

    check(finish_thread(*thread), "The producer thread did not finish.");
    if check(dequeued, "No message was dequeued.")  check_numbered(message, 0);
    check(elapsed <= 100 + TIMING_TOLERANCE_MS, "The consumer was woken up after % ms.", elapsed);
}

// A producer that waits for room on a full queue is woken up as soon as a message is taken off.
test_producer_waits :: () {
    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    for 0..MIDI_QUEUE_LENGTH - 1  queue_message(*queue, numbered_message(it), 0);

    job := Thread_Job.{queue = *queue, count = MIDI_QUEUE_LENGTH + 1, delay_ms = 100};
    thread: Thread;
    start_thread(*thread, consumer_thread, *job);

    start := current_time_monotonic();
    queued := queue_message(*queue, numbered_message(MIDI_QUEUE_LENGTH));
    elapsed := to_milliseconds(current_time_monotonic() - start);

    check(queued, "The message could not be queued.");
    check(elapsed <= 100 + TIMING_TOLERANCE_MS, "The producer was woken up after % ms.", elapsed);
    check(finish_thread(*thread), "The consumer thread did not finish.");
    check(job.failures == 0, "The consumer got % message(s) that were missing or out of order.", job.failures);
}

// Many messages from one thread to another must all arrive, in order, also when the queue is often full or empty.
test_threads :: () {
    MESSAGE_COUNT :: 200_000;

    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    producer_job := Thread_Job.{queue = *queue, count = MESSAGE_COUNT};
    consumer_job := Thread_Job.{queue = *queue, count = MESSAGE_COUNT};

    producer: Thread;
    consumer: Thread;
    start_thread(*consumer, consumer_thread, *consumer_job);
    start_thread(*producer, producer_thread, *producer_job);

    check(finish_thread(*producer), "The producer thread did not finish.");
    check(finish_thread(*consumer), "The consumer thread did not finish.");
    check(producer_job.failures == 0, "% message(s) could not be queued.", producer_job.failures);
    check(consumer_job.failures == 0, "% of % message(s) were missing or out of order.", consumer_job.failures, MESSAGE_COUNT);
}

// The buffer of a system-exclusive message is only valid during the callback. A queue that hands the message to another
// thread must either copy the buffer, or refuse the message. Otherwise the consumer reads memory that has been reused.
test_system_exclusive :: () {
    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    original := u8.[0xf0, 0x7d, 0x01, 0x02, 0x03, 0xf7];

    // Stands in for the buffer the decoder delivers a message in.
    buffer: [6] u8;
    for original  buffer[it_index] = it;

    queued := queue_message(*queue, create_system_exclusive_message(buffer), 0);

    // The callback returns, and the decoder reuses its buffer for the next message.
    for * buffer  it.* = 0x55;

    if !queued  return; // Refusing the message is fine.

    dequeued, message := dequeue_message(*queue, 0);
    if !check(dequeued, "The system-exclusive message was queued, but not dequeued.")  return;
    check(message.status == .System_Exclusive, "Expected status System_Exclusive, got %.", message.status);
    check(message.system_exclusive_info.buffer.data != buffer.data, "The queued message still points at the buffer it was delivered in.");
    check_bytes(message.system_exclusive_info.buffer, original, "dequeued system-exclusive message");
}

//
// Part 2: loopback.
//

LOOPBACK_MESSAGE_COUNT :: 2000;

Callback_State :: struct {
    queue: MIDI_Queue;
    dropped: s64;
}

// Queues every message, as module.jai recommends. It doesn't wait for room, since that would stall the MIDI driver.
queueing_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    state := cast(*Callback_State) user_data;
    if !queue_message(*state.queue, message, 0)  atomic_add(*state.dropped, 1);
}

run_loopback_tests :: (loopback_name: string, use_virtual_endpoint: bool) {
    state := New(Callback_State);
    init(*state.queue);
    defer {
        deinit(*state.queue);
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
        if dequeue_message(*state.queue, 100) {
            connected = true;
            break;
        }
    }

    check(connected, "No messages came through the loopback.");
    if !connected  return;
    drain(state);

    begin_test("Messages from an input callback");             test_loopback_messages(state, output);       end_test();
    begin_test("System-exclusive messages from a callback");   test_loopback_system_exclusive(state, output); end_test();
}

// Skips everything that has been queued so far, waiting until nothing arrives for a while.
drain :: (state: *Callback_State) {
    while dequeue_message(*state.queue, 200) {}
    atomic_swap(*state.dropped, 0);
}

// The main thread keeps up with the messages, so none are dropped, and they arrive in order.
test_loopback_messages :: (state: *Callback_State, output: *MIDI_Output) {
    failures := 0;
    for 0..LOOPBACK_MESSAGE_COUNT - 1 {
        send_midi_message(output, numbered_message(it));

        dequeued, message := dequeue_message(*state.queue, 5000);
        if !check(dequeued, "Message % did not arrive.", it) {
            drain(state);
            return;
        }
        if !is_numbered(message, it)  failures += 1;
    }

    check(failures == 0, "% of % messages were wrong or out of order.", failures, LOOPBACK_MESSAGE_COUNT);
    check(atomic_read(*state.dropped) == 0, "% message(s) were dropped.", atomic_read(*state.dropped));
}

// The same as test_system_exclusive, but with a real callback. Several messages are sent before any is taken off the
// queue, so that the decoder has reused its buffer by then.
test_loopback_system_exclusive :: (state: *Callback_State, output: *MIDI_Output) {
    messages := ([] u8).[
        u8.[0xf0, 0x7d, 0x01, 0x02, 0x03, 0xf7],
        u8.[0xf0, 0x7d, 0x04, 0x05, 0x06, 0x07, 0x08, 0xf7],
        u8.[0xf0, 0x7d, 0x09, 0xf7],
    ];

    for messages  send_midi_message(output, create_system_exclusive_message(it));
    sleep_milliseconds(500);

    for messages {
        dequeued, message := dequeue_message(*state.queue, 0);
        if !dequeued {
            // Not queued at all, which is allowed.
            continue;
        }

        if !check(message.status == .System_Exclusive, "Expected system-exclusive message %, got %.", it_index, message.status)  break;
        check_bytes(message.system_exclusive_info.buffer, it, tprint("system-exclusive message % after taking it off the queue", it_index));
    }

    drain(state);
}

open_loopback :: (name: string, use_virtual_endpoint: bool, state: *Callback_State) -> found: bool, input: *MIDI_Input, output: *MIDI_Output {
    #if OS == .MACOS {
        if use_virtual_endpoint {
            input := open_virtual_input(name, queueing_callback, state);
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
    input  := open_input(source_index, queueing_callback, state);
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

// A note-on message that is different for each number, so that lost or reordered messages are noticed.
numbered_message :: (number: int) -> MIDI_Message {
    note     := cast,trunc(u8) (number % 128);
    velocity := cast,trunc(u8) (1 + (number / 128) % 127);
    return create_midi_message(.Note_On, note, velocity);
}

is_numbered :: (message: MIDI_Message, number: int) -> bool {
    expected := numbered_message(number);
    return message.status == expected.status && message.bytes[0] == expected.bytes[0] && message.bytes[1] == expected.bytes[1];
}

check_numbered :: (message: MIDI_Message, number: int, what := "", loc := #caller_location) -> bool {
    description := ifx what then what else tprint("message %", number);
    return check(is_numbered(message, number), "Got % with data bytes % for %.", message.status, message.bytes, description, loc = loc);
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
