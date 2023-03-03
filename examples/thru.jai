// This example program opens an output and an input. The input uses a callback function which gets a pointer to the
// output as user data; the input callback logs each MIDI message and passes it on to the output, so this program
// functions as a sort of MIDI passthrough.
//
// The example also showcases a simple message queue that can be shared between two threads, where one thread queues
// message, and another dequeues them. Why not call send_midi_message from the callback directly? Well, not every MIDI
// driver allows making calls to its API from the callback.

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
    // source_name :: "Keystation";
    source_name :: "Impulse";
    destination_name :: "Synth";

    source_index  := get_source_index_by_name(source_name);
    destination_index := get_destination_index_by_name(destination_name);

    callback_data: Callback_Data;
    init(*callback_data.read_semaphore);
    init(*callback_data.write_semaphore, QUEUE_SIZE);

    if source_index >= 0 && destination_index >= 0 {
        input  := open_input(source_index, midi_input_callback, *callback_data);
        output := open_output(destination_index);
        defer close_input(input);
        defer close_output(output);

        if input && output {
            print("Made a connection from % to %. Press Ctrl+C to quit.\n", source_name, destination_name);

            while true {
                if wait_for(*callback_data.read_semaphore) == .SUCCESS {
                    message := callback_data.message_queue[callback_data.read_cursor];
                    send_midi_message(output, message);
                    signal(*callback_data.write_semaphore);
                    callback_data.read_cursor = (callback_data.read_cursor + 1) % QUEUE_SIZE;
                }
            }
        } else {
            if !input   log_error("Input '%' could not be opened.", source_name);
            if !output  log_error("Output '%' could not be opened.", destination_name);
        }
    } else {
        if source_index < 0       log_error("Input '%' could not be found.", source_name);
        if destination_index < 0  log_error("Output '%' could not be found.", destination_name);

        print("\n");
        print_available_midi_endpoints();
    }
}

#import,file "../module.jai";
#import "Basic";
#import "Thread";

#load "shared.jai";
