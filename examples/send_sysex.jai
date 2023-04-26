// Example of sending a system-exclusive message.

BUFFER_TO_SEND :: u8.[0xf0, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0xf7];

main :: () {
    // Change destination_name to (part of) the name of an available MIDI destination. Be careful where you send
    // system-exclusive messages, since they can be used for stuff like updating firmware on some devices.
    destination_name :: "MIDI Monitor";

    destination_index := get_destination_index_by_name(destination_name, match_full_name = false);
    if destination_index >= 0 {
        output := open_output(destination_index);
        defer close_output(output);

        if output {
            print("Sending system-exclusive message...");
            message := create_system_exclusive_message(BUFFER_TO_SEND);
            send_midi_message(output, message);
            print(" done.\n");
        } else  log_error("Could not open output for destination '%'.", destination_name);
    } else {
        print("Destination with name '%' could not be found. There are ", destination_name);
        print_available_midi_endpoints(include_sources = false);
    }
}

#import "Basic";
#import "Random";

#import,file "../module.jai";

#load "shared.jai";
