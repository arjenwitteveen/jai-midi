// MIDI input example.

midi_input_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    print_message_info(message, timestamp);
}

main :: () {
    args := get_command_line_arguments();

    if args.count < 2 {
        print("Usage: input source\n\n");
        print("Please provide the index of a MIDI source. There are ");
        print_available_midi_endpoints(include_destinations = false);
        return;
    }

    source_index, parse_success := string_to_int(args[1]);
    if !parse_success || source_index < 0 {
        log_error("Invalid MIDI source index '%'.\n", args[1]);
        return;
    }

    input := open_input(source_index, midi_input_callback);

    if input {
        print("Listening for the next % seconds...\n", INPUT_WAIT_SECONDS);
        sleep_milliseconds(INPUT_WAIT_SECONDS * 1000); // Sleep and wait for messages to come in through the callback.
        close_input(input);
    }
}

INPUT_WAIT_SECONDS :: 10;

#import,file "../module.jai";
#import "Basic";

#load "shared.jai";
