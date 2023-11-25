// This example program opens an output and an input. Messages received in the input's callback are placed in a queue,
// which the main thread then consumes and sends to the output, so this program functions as a sort of MIDI passthrough.
//
// It is important to realize that in general your input callbacks will run on a separate thread. This example showcases
// a simple message queue that can be shared between two threads, where one thread queues messages, and another dequeues
// them. Why not call send_midi_message from the callback directly? Well, not every MIDI driver allows making calls to
// its API from the callback.

LOG_MESSAGES :: true;
QUEUE_SIZE :: 16;

Callback_Data :: struct {
    message_queue: [QUEUE_SIZE] MIDI_Message;
    read_semaphore: Semaphore;
    write_semaphore: Semaphore;
    read_cursor: int;
    write_cursor: int;
}

midi_input_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    #if LOG_MESSAGES  print_message_info(message, timestamp);

    if message.status < .System_Exclusive {
        using callback_data := cast(*Callback_Data) user_data;
        if wait_for(*write_semaphore, 1) == .SUCCESS {
            message_queue[write_cursor] = message;
            signal(*read_semaphore);
            write_cursor = (write_cursor + 1) % QUEUE_SIZE;
        }
    }
}

main :: () {
    args := get_command_line_arguments();

    if args.count < 3 {
        print("Usage: thru source_index destination_index\n");
        print("\nPlease provide the index of a MIDI source and destination:\n\n");
        print_available_midi_endpoints();
        return;
    }

    source_index, source_parse_success := string_to_int(args[1]);
    if !source_parse_success || source_index < 0 {
        log_error("Invalid MIDI source index '%'.\n", args[1]);
        return;
    }

    destination_index, destination_parse_success := string_to_int(args[2]);
    if !destination_parse_success || destination_index < 0 {
        log_error("Invalid MIDI destination index '%'.\n", args[2]);
        return;
    }

    callback_data: Callback_Data;
    init(*callback_data.read_semaphore);
    init(*callback_data.write_semaphore, QUEUE_SIZE);

    if source_index >= 0 && destination_index >= 0 {
        input  := open_input(source_index, midi_input_callback, *callback_data);
        output := open_output(destination_index);
        defer close_input(input);
        defer close_output(output);

        if input && output {
            print("Made a connection from source % to destination %. Press Ctrl+C to quit.\n", source_index, destination_index);

            while true {
                if wait_for(*callback_data.read_semaphore) == .SUCCESS {
                    message := callback_data.message_queue[callback_data.read_cursor];
                    send_midi_message(output, message);
                    signal(*callback_data.write_semaphore);
                    callback_data.read_cursor = (callback_data.read_cursor + 1) % QUEUE_SIZE;
                }
            }
        }
    }
}

#import,file "../module.jai";
#import "Basic";
#import "Thread";

#load "shared.jai";
