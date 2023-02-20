// MIDI input example using a message queue.

main :: () {
    // First let's list all the MIDI sources.
    print_available_midi_endpoints(include_destinations = false);
    print("\n");

    // Change source_name to (part of) the name of an available MIDI source, like a MIDI keyboard.
    source_name :: "Impulse";
    source_index := get_source_index_by_name(source_name, match_full_name = false);

    if source_index >= 0 {
        input := open_input(source_index);
        defer close_input(input);

        if input {
            print("Listening for input from '%' for the next % seconds...\n", source_name, INPUT_WAIT_SECONDS);

            start_time := current_time_monotonic();
            while to_seconds(current_time_monotonic() - start_time) < INPUT_WAIT_SECONDS {
                // Grab a message from the queue. You can do this in a blocking or non-blocking manner. In this case
                // we're using a short timeout period so that we can check the condition of the while loop every now and then.
                message, timestamp, message_success := read_message(input, timeout = 100);

                if message_success  print_message_info(message, timestamp);
            }
        } else  log_error("Could not open input for source '%'.", source_name);
    } else  log_error("Source with name '%' could not be found.", source_name);
}

INPUT_WAIT_SECONDS :: 10;

#import,file "../module.jai";
#import "Basic";

#load "shared.jai";
