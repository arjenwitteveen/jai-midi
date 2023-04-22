// MIDI input example.

midi_input_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    print_message_info(message, timestamp);
}

main :: () {
    // First let's list all the MIDI sources.
    print_available_midi_endpoints(include_destinations = false);
    print("\n");

    // Change source_name to (part of) the name of an available MIDI source, like a MIDI keyboard.
    source_name :: "Keystation";
    source_index := get_source_index_by_name(source_name, match_full_name = false);

    if source_index >= 0 {
        input := open_input(source_index, midi_input_callback);
        defer close_input(input);

        if input {
            print("Listening for input from '%' for the next % seconds...\n", source_name, INPUT_WAIT_SECONDS);
            sleep_milliseconds(INPUT_WAIT_SECONDS * 1000); // Sleep and wait for messages to come in through the callback.
        } else  log_error("Could not open input for source '%'.", source_name);
    } else  log_error("Source with name '%' could not be found.", source_name);
}

INPUT_WAIT_SECONDS :: 10;

#import,file "../module.jai";
#import "Basic";

#load "shared.jai";
