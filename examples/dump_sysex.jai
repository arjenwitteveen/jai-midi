// Example of a little command line tool that can be used to dump system-exclusive data from a MIDI source to a file.

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

    input := open_input(source_index);
    if !input {
        print("Error opening MIDI input.\n");
        return;
    }

    print("Waiting for system-exclusive message (press Ctrl+C to cancel)...\n");
    while true {
        message, timestamp, message_success := read_message(input);
        if message_success && message.status == .System_Exclusive {
            sysex := message.system_exclusive_info;
            print("System-exclusive message received (% bytes).\n", sysex.buffer.count);
            success := write_entire_file(file_name, sysex.buffer.data, sysex.buffer.count);
            if success {
                print("Wrote %.\n", file_name);
            } else {
                log_error("Error writing to %.", file_name);
            }
            break;
        }
    }

    close_input(input);
}

#import,file "../module.jai";
#import "Basic";
#import "File";

#load "shared.jai";
