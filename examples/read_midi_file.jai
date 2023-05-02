main :: () {
    args := get_command_line_arguments();
    if args.count != 2 {
        print("Usage: read_file <path to MIDI file>\n");
        return;
    }

    midi_file_path := args[1];

    midi_file, success := read_midi_file(midi_file_path);

    if success {
        print("Read MIDI file (format = %, time division = %, track count = %).\n", midi_file.format, midi_file.time_division, midi_file.tracks.count);
        for track: midi_file.tracks {
            print("Track % has % events.\n", it_index, track.events.count);
        }
    }
}

#import,file "../module.jai";
#import "Basic";
