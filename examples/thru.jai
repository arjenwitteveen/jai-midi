// This example program opens an output and an input. Messages received in the input's callback are placed in a queue,
// which the main thread then consumes and sends to the output, so this program functions as a sort of MIDI passthrough.
//
// It is important to realize that in general your input callbacks will run on a separate thread. The module includes a
// simple single producer/single consumer queue to handle message passing between the callback and the main program, but
// you might want to roll your own solution for 'real' programs. And why not call send_midi_message from the callback
// directly? Well, not every MIDI driver allows making calls to its API from the callback.

LOG_MESSAGES :: true;

midi_input_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    #if LOG_MESSAGES  print_message_info(message, timestamp);

    if message.status < .System_Exclusive {
        queue := cast(*MIDI_Queue) user_data;
        queue_message(queue, message);
    }
}

main :: () {
    args := get_command_line_arguments();

    if args.count < 3 {
        print("Usage: thru source_index destination_index\n");
        print("\nPlease provide the index of a MIDI source and destination.\n");

        print("\nAvailable sources:\n");
        number_of_sources := get_number_of_sources();
        for 0..number_of_sources - 1 {
            source_name := get_source_name(it);
            print("[%] %\n", it, source_name);
        }

        print("\nAvailable destinations:\n");
        number_of_destinations := get_number_of_destinations();
        for 0..number_of_destinations - 1 {
            destination_name := get_destination_name(it);
            print("[%] %\n", it, destination_name);
        }

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

    queue: MIDI_Queue;
    init(*queue);
    defer deinit(*queue);

    if source_index >= 0 && destination_index >= 0 {
        input  := open_input(source_index, midi_input_callback, *queue);
        output := open_output(destination_index);
        defer close_input(input);
        defer close_output(output);

        if input && output {
            print("Made a connection from source % to destination %. Press Ctrl+C to quit.\n", source_index, destination_index);

            while true {
                received_message, message := dequeue_message(*queue);
                if received_message  send_midi_message(output, message);
            }
        }
    }
}

#import,file "../module.jai";
#import "Basic";