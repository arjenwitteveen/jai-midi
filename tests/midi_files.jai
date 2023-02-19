MIDI_FILE_DIRECTORY :: "../midi_files";

#run read_midi_files();

read_midi_files :: () {
    #import "File_Utilities";
    #import "String";
    #import "System";

    builder: String_Builder;
    pwd := #filepath;

    midi_file_path := tprint("%0%0", #filepath, MIDI_FILE_DIRECTORY);

    if !is_directory(midi_file_path)  return; // Test files not present, skip this test.

    test_files := file_list(midi_file_path);

    for file: test_files {
        if ends_with(file, ".mid") || ends_with(file, ".midi") {
            test_log("Testing %...\n", file);
            midi_file, success := read_midi_file(file);
            assert(success, "MIDI file '%' could not be parsed.", file);
            assert(midi_file.format >= 0 && midi_file.format <= 2, "Unexpected format '%'.", midi_file.format);
            assert(midi_file.tracks.count > 0, "No tracks were parsed.");
            for midi_file.tracks  assert(it.events.count > 0, "Track without any events.");
        }
    }
}
