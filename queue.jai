// A simple single producer/single consumer queue to use in MIDI callbacks.

MIDI_QUEUE_LENGTH :: 16;

MIDI_Queue :: struct {
    message_queue: [MIDI_QUEUE_LENGTH] MIDI_Message;
    read_semaphore: Semaphore;
    write_semaphore: Semaphore;
    read_cursor: int;
    write_cursor: int;
}

init :: (using queue: *MIDI_Queue) {
    init(*read_semaphore);
    init(*write_semaphore, message_queue.count);
}

deinit :: (using queue: *MIDI_Queue) {
    destroy(*read_semaphore);
    destroy(*write_semaphore);
}

dequeue_message :: (using queue: *MIDI_Queue, timeout_milliseconds: s32 = -1) -> bool, MIDI_Message {
    if wait_for(*read_semaphore, timeout_milliseconds) == .SUCCESS {
        message := message_queue[read_cursor];
        signal(*write_semaphore);
        read_cursor = (read_cursor + 1) % message_queue.count;
        return true, message;
    }

    return false, .{};
}

queue_message :: (using queue: *MIDI_Queue, message: MIDI_Message, timeout_milliseconds: s32 = -1) -> bool {
    if wait_for(*write_semaphore, timeout_milliseconds) == .SUCCESS {
        message_queue[write_cursor] = message;
        signal(*read_semaphore);
        write_cursor = (write_cursor + 1) % message_queue.count;
        return true;
    }

    return false;
}

#import "Thread";