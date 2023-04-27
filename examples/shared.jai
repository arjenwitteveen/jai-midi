// This file contains some utility functions used by the example programs.

print_available_midi_endpoints :: (include_sources := true, include_destinations := true) {
    if include_sources {
        number_of_sources := get_number_of_sources();
        if number_of_sources > 0 {
            print("% available MIDI source(s):\n", number_of_sources);
            for 0..number_of_sources - 1 {
                source_name := get_source_name(it);
                print("[%] %\n", it, source_name);
            }
        } else print("no available MIDI sources.\n");
    }

    if include_destinations {
        if include_sources  print("\n");
        number_of_destinations := get_number_of_destinations();
        if number_of_destinations > 0 {
            print("% available MIDI destination(s):\n", number_of_destinations);
            for 0..number_of_destinations - 1 {
                destination_name := get_destination_name(it);
                print("[%] %\n", it, destination_name);
            }
        } else print("no available MIDI destinations.\n");
    }
}

print_message_info :: (message: MIDI_Message, timestamp: Apollo_Time) {
    f :: (value: int, digits := 2) -> FormatInt #expand { return FormatInt.{value=value, base=16, minimum_digits=digits}; }

    print("%", message.status);
    if message.status < .Pitch_Bend  print(" (channel %): ", message.channel);
    else                             print(": ");

    if message.status == {
        case .Note_On; #through;
        case .Note_Off;            print("note = 0x%, velocity = 0x%", f(message.note_info.note), f(message.note_info.velocity));
        case .Polyphonic_Pressure; print("note = 0x%, pressure = 0x%", f(message.polyphonic_pressure_info.note), f(message.polyphonic_pressure_info.pressure));
        case .Control_Change;      print("controller = 0x%, value = 0x%", f(message.control_change_info.controller), f(message.control_change_info.value));
        case .Program_Change;      print("program = 0x%", f(message.program_change_info.program));
        case .Channel_Pressure;    print("pressure = 0x%", f(message.channel_pressure_info.pressure));
        case .Pitch_Bend;          print("value = 0x% (%)", f(pitch_bend_get_value(message.pitch_bend_info), digits=4), formatFloat(pitch_bend_get_float(message.pitch_bend_info), trailing_width = 2, zero_removal = .NO));

        case .System_Exclusive; {
            data := message.system_exclusive_info.buffer;
            print("data (% bytes):\n", data.count);
            for data {
                print("0x%", FormatInt.{value=it, base=16, minimum_digits=2});
                if it_index != data.count - 1 {
                    if (it_index + 1) % 16 == 0 print("\n"); else print(" ");
                }
            }
        }
    }

    print(" @ % ms ", to_milliseconds(timestamp));
    print("\n");
}
