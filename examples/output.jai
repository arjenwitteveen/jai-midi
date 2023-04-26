// Example of opening a MIDI output and sending data through it.

main :: () {
    args := get_command_line_arguments();

    if args.count < 2 {
        print("Usage: output destination\n\n");
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

    if output {
        play_a_song(output);
        close_output(output);
    }
}

play_a_song :: (output: *MIDI_Output) {
    print("Playing some MIDI music...");

    note_length_milliseconds : s32 : 300; // @Note: We use sleep to time our notes in this toy example, of course this isn't very accurate!
    root_note :: 0x40;
    relative_notes :: int.[0, -2, -7, -5];
    major_seventh_arpeggio :: u8.[0, 4, 7, 11, 12, 11, 7, 4];

    // Marvel at this beautiful musical composition.
    for relative_note: relative_notes {
        current_root_note := cast(u8) (root_note + relative_note);
        send_midi_message(output, create_control_change_message(.Sustain_Pedal, 0x0));
        send_midi_message(output, create_control_change_message(.Sustain_Pedal, 0x7f));
        for note: major_seventh_arpeggio {
            // Let's 'humanize' the velocity and note length a bit.
            velocity := 100 + cast(u8) (random_get() % 20);
            note_length := note_length_milliseconds + cast(s32) (random_get() % 10);
            send_midi_message(output, create_midi_message(.Note_On, current_root_note + note, velocity));
            send_midi_message(output, create_midi_message(.Note_Off, current_root_note + note)); // We're using the sustain pedal, so we can send the note off right away.
            sleep_milliseconds(note_length);
        }
    }
    send_midi_message(output, create_midi_message(.Note_On,  cast(u8) (root_note + relative_notes[relative_notes.count - 1] - 12), 100));
    send_midi_message(output, create_midi_message(.Note_Off, cast(u8) (root_note + relative_notes[relative_notes.count - 1] - 12)));
    sleep_milliseconds(6 * note_length_milliseconds);
    send_midi_message(output, create_control_change_message(.Sustain_Pedal, 0x0));
    sleep_milliseconds(200);

    print(" done!\n");
}

#import "Basic";
#import "Random";

#import,file "../module.jai";

#load "shared.jai";
