// Example of a little command line tool that can be used to dump system-exclusive data from a MIDI source to a file.

Callback_Data :: struct {
    file_name: string;
    semaphore: Semaphore;
}

midi_input_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    if message.status == .System_Exclusive {
        callback_data := cast(*Callback_Data) user_data;

        sysex := message.system_exclusive_info;
        print("System-exclusive message received (% bytes).\n", sysex.buffer.count);
        success := write_entire_file(callback_data.file_name, sysex.buffer.data, sysex.buffer.count);

        if success {
            print("Wrote %.\n", callback_data.file_name);
        } else {
            log_error("Error writing to %.", callback_data.file_name);
        }

        signal(*callback_data.semaphore);
    }
}

main :: () {
    args := get_command_line_arguments();

    if args.count < 3 {
        print("Usage: dump_sysex <MIDI source name> <output filename>\n");
        return;
    }

    source_name := args[1];
    file_name := args[2];

    source_index := get_source_index_by_name(source_name, match_full_name = false);

    if source_index == -1 {
        print("Given MIDI source could not be found; there are ");
        print_available_midi_endpoints(include_destinations = false);
        return;
    }

    callback_data := Callback_Data.{file_name = file_name};
    init(*callback_data.semaphore);

    input := open_input(source_index, midi_input_callback, *callback_data);
    if !input {
        print("Error opening MIDI input.\n");
        return;
    }

    print("Waiting for system-exclusive message (press Ctrl+C to cancel)...\n");

    wait_for(*callback_data.semaphore);

    close_input(input);
}

#import,file "../module.jai";
#import "Basic";
#import "File";
#import "Thread";

#load "shared.jai";
