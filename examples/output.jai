// Example of opening a MIDI output and sending data through it.

main :: () {
    args := get_command_line_arguments();

    if args.count < 2 {
        print("Usage: output destination_index\n\n");
        print("Please provide the index of a MIDI destination. There are ");
        print_available_midi_endpoints(include_sources = false);
        return;
    }

    destination_index, parse_success := string_to_int(args[1]);
    if !parse_success || destination_index < 0 {
        log_error("Invalid MIDI destination index '%'.\n", args[1]);
        return;
    }

    output := open_output(destination_index);

    // Instead of connecting to a specific destination, we can create a 'virtual' output. This output will be visible to other
    // clients, who can then choose to connect to us. This is not supported on all platforms, however.
    // output := open_virtual_output("My Output");

    if output {
        root_note :: 64;
        major_scale :: u8.[0, 2, 4, 5, 7, 9, 11];
        note_length_milliseconds :: 300;

        // Play some random notes from the major scale.
        for 1..64 {
            note := root_note + major_scale[random_get() % major_scale.count];
            velocity := 100 + cast(u8) (random_get() % 20);

            send_midi_message(output, create_midi_message(.Note_On, note, velocity));
            sleep_milliseconds(note_length_milliseconds);
            send_midi_message(output, create_midi_message(.Note_Off, note));
        }

        close_output(output);
    }
}

#import "Basic";
#import "Random";

#import,file "../module.jai";

#load "shared.jai";
