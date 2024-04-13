// Example of a little command line tool that can be used to dump system-exclusive data from a MIDI source to a file.

OUTPUT_FILE :: "sysex.dat";

Callback_Data :: struct {
    semaphore: Semaphore;
    buffer: [] u8;
}

midi_input_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    if message.status == .System_Exclusive {
        callback_data := cast(*Callback_Data) user_data;
        callback_data.buffer = array_copy(message.system_exclusive_info.buffer);
        signal(*callback_data.semaphore);
    }
}

main :: () {
    args := get_command_line_arguments();

    if args.count < 2 {
        print("Usage: dump_sysex source_index\n");
        print("\nPlease provide the index of a MIDI source. Available sources:\n");

        number_of_sources := get_number_of_sources();
        for 0..number_of_sources - 1 {
            source_name := get_source_name(it);
            print("[%] %\n", it, source_name);
        }

        return;
    }

    source_index, parse_success := string_to_int(args[1]);
    if !parse_success || source_index < 0 {
        log_error("Invalid MIDI source index '%'.\n", args[1]);
        return;
    }

    callback_data: Callback_Data;
    init(*callback_data.semaphore);

    input := open_input(source_index, midi_input_callback, *callback_data);
    if input {
        print("Waiting for system-exclusive message...\n");
        wait_for(*callback_data.semaphore);

        print("System-exclusive message received (% bytes).\n", callback_data.buffer.count);
        success := write_entire_file(OUTPUT_FILE, callback_data.buffer.data, callback_data.buffer.count);

        if success {
            print("Wrote %.\n", OUTPUT_FILE);
        } else {
            log_error("Error writing to %.", OUTPUT_FILE);
        }

        close_input(input);
    }
}

#import,file "../module.jai";
#import "Basic";
#import "File";
#import "Thread";
