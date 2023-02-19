// Example of opening a MIDI output and sending data through it.

main :: () {
    // First let's list all the MIDI destinations.
    print_available_midi_endpoints(include_sources = false);
    print("\n");

    // Change destination_name to (part of) the name of an available MIDI destination. On Windows, the current value
    // should match the default Microsoft GS Wavetable Synth, for example.
    destination_name :: "Synth";

    destination_index := get_destination_index_by_name(destination_name, match_full_name = false);
    if destination_index >= 0 {
        output := open_output(destination_index);
        defer close_output(output);
        if output {
            play_a_song(output);
        } else  log_error("Could not open output for destination '%'.", destination_name);
    } else  log_error("Destination with name '%' could not be found.", destination_name);
}

play_a_song :: (output: *MIDI_Output) {
    print("Playing some MIDI music...");

    note_length_milliseconds : s32 : 300; // @Note: We use sleep to time our notes in this toy example, of course this isn't very accurate!
    root_note :: 0x40;
    relative_notes :: int.[0, -2, -7, -5];
    major_seventh_arpeggio :: u8.[0, 4, 7, 11, 12, 11, 7, 4];

    // Use the vibraphone! Assuming we're talking to an output using GM instrument patches, of course.
    send_midi_message(output, create_midi_message(.Program_Change, 11));

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
    send_midi_message(output, create_midi_message(.Note_On,  cast(u8) (root_note + relative_notes[3] - 12), 100));
    send_midi_message(output, create_midi_message(.Note_Off, cast(u8) (root_note + relative_notes[3] - 12)));
    sleep_milliseconds(6 * note_length_milliseconds);
    send_midi_message(output, create_control_change_message(.Sustain_Pedal, 0x0));
    sleep_milliseconds(200);

    print(" done!\n");
}

#import "Basic";
#import "Random";

#import,file "../module.jai";

#load "shared.jai";
