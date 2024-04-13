// Example of sending a system-exclusive message.

BUFFER_TO_SEND :: u8.[0xf0, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0xf7];

main :: () {
    args := get_command_line_arguments();

    if args.count < 2 {
        print("Usage: send_sysex destination_index\n\n");
        print("Please provide the index of a MIDI destination. Available destinations:\n");

        number_of_destinations := get_number_of_destinations();
        for 0..number_of_destinations - 1 {
            destination_name := get_destination_name(it);
            print("[%] %\n", it, destination_name);
        }

        return;
    }

    destination_index, parse_success := string_to_int(args[1]);
    if !parse_success || destination_index < 0 {
        log_error("Invalid MIDI destination index '%'.\n", args[1]);
        return;
    }

    output := open_output(destination_index);
    if output {
        print("Sending system-exclusive message...");
        message := create_system_exclusive_message(BUFFER_TO_SEND);
        send_midi_message(output, message);
        print(" done.\n");
        close_output(output);
    }
}

#import,file "../module.jai";
#import "Basic";
#import "Random";