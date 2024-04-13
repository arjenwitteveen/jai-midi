//
// This module aims to provide basic MIDI I/O support for Jai programs in a simple to use, cross-platform manner. It
// allows you to receive MIDI messages from a MIDI source, and send MIDI messages to a MIDI destination. Both regular
// messages and system-exclusive messages are supported. There is also basic support for reading MIDI files.
//
// The module does not aim to support all the possible functionality that MIDI (or the MIDI driver of each OS)
// provides. There is no support for MIDI 2.0.
//


// * Getting info on endpoints.
//
// Each OS handles MIDI endpoints a bit differently. This module uses the concept of zero-based endpoint indices: index
// 0 refers to the first endpoint, and index N - 1 refers to the last one, assuming there are N of them. MIDI sources
// and destinations are two separate lists in this regard. In general, you need to request the number of endpoints, and
// then get the name or other info on that endpoint to see which one you want. You then use the found index to open an
// input or output with.
//
//   get_number_of_sources :: () -> int
//   get_number_of_destinations :: () -> int
//
//     Use these to get the number of available endpoints that can serve as MIDI sources or destinations.
//
//   get_source_info :: (index: int) -> MIDI_Source_Info, bool
//   get_destination_info :: (index: int) -> MIDI_Destination_Info, bool
//
//     These functions return a struct that contains platform-specific information about an endpoint, and a boolean
//     indicating if the query succeeded.
//
//   get_source_name :: (index: int) -> string
//   get_destination_name :: (index: int) -> string
//
//     Get the name of the endpoint with the given index (the resulting string lives in temporary storage). Returns
//     the empty string if unsuccessful.
//
//   get_source_index_by_name :: (name: string, match_full_name := false) -> int
//   get_destination_index_by_name :: (name: string, match_full_name := false) -> int
//
//     Get the endpoint index based on a name; by default it returns the first endpoint that contains the given
//     string, but you can optionally require the full name to be matched instead. Returns -1 if no endpoint was
//     found.


// * Receiving MIDI.
//
// MIDI messages are received through a callback function that you have to provide. Two things are important to keep in
// mind. Firstly, the callback will generally run on a different thread than your main thread. Secondly, in general it
// is not a good idea to call other MIDI functions directly from the callback thread, as not every MIDI backend allows
// this. If needed, use something like a thread-safe queue to queue MIDI data on instead, and process it on another
// thread. See the examples for a sample of this.
//
//   open_input :: (source_index: int, callback: MIDI_Input_Callback, user_data: *void = null) -> *MIDI_Input
//
//     Open an input connection to the MIDI source with the given index; returns null upon failure. You can pass custom
//     data to the callback using the user_data pointer. Callbacks have the following signature:
//
//       (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) -> ()
//
//     When a message comes in, the callback is called with the input the message came in on, the message itself, the
//     timestamp of the message, and the optional user_data pointer that was configured when the input was opened.
//
//   close_input :: (input: *MIDI_Input)
//
//     Closes the input and frees its resources.
//
//
// A note on system-exclusive messages: the buffers containing these messages will be delivered through the callback,
// and are valid only while the callback is running. Do not store pointers to those buffers; if you want to keep them
// around, copy them. The received buffers will include the system-exclusive status bytes (0xf0 and 0xf7) as the first
// and last bytes. When sending a system-exclusive message, you are also responsible for adding those bytes to the
// buffer you want to send.


// * Sending MIDI.
//
// Sending is a more straightforward than receiving. You just open an output to a MIDI destination, and start sending
// messages through it.
//
//   open_output :: (destination_index: int) -> *MIDI_Output
//   close_output :: (output: *MIDI_Output)
//
//     These are analogous to open_input and close_input.
//
//   send_midi_message :: (output: *MIDI_Output, message: [] u8) -> bool
//   send_midi_message :: (output: *MIDI_Output, message: MIDI_Message) -> bool
//   send_midi_messages :: (output: *MIDI_Output, messages: [] MIDI_Message) -> bool
//
//     Send one or multiple MIDI messages to the given output. Returns false if at least one message failed to send.


// * Virtual endpoints.
//
// Instead of directly connecting to a MIDI source or destination, some platforms allow you to create a 'virtual'
// endpoint. Other clients can see these endpoints and connect to *you*, rather than the other way around. To accomodate
// this, the following procedures are available:
//
//   open_virtual_input :: (input_name: string, callback: MIDI_Input_Callback, user_data: *void = null) -> *MIDI_Input
//   open_virtual_output :: (output_name: string) -> *MIDI_Output
//
// After creation, virtual inputs and outputs can be used in the same way as regular ones. Currently we only support
// virtual endpoints for macOS.


// * Utilities.
//
// Some simple MIDI-related helper functions and enums are defined in the module. Some of the more useful ones to get
// started are listed here.
//
//   create_midi_message :: (bytes: [] u8) -> MIDI_Message
//   create_midi_message :: (status: MIDI_Status, data0: u8 = 0, data1: u8 = 0, channel: u8 = 0) -> MIDI_Message, bool
//   create_control_change_message :: (controller: Control_Change, value: u8, channel: u8 = 0) -> MIDI_Message
//   create_pitch_bend_message :: (value: float, channel: u8 = 0) -> MIDI_Message
//   create_system_exclusive_message :: (data: [] u8) -> MIDI_Message
//
//     Create a MIDI message in various ways. For system-exclusive messages you are responsible for keeping the
//     pointed-at memory valid until the message has been sent.
//
//   pitch_bend_get_value :: (info: MIDI_Pitch_Bend_Info) -> int
//   pitch_bend_get_float :: (info: MIDI_Pitch_Bend_Info) -> float
//
//     Get the pitch bend value as an integer in the range [0, 16383], or as float in the range [-1.0, 1.0].


// * Reading MIDI files.
//
// Support for reading MIDI files is provided through midi_file.jai. The interface is very simple.
//
//   read_midi_file :: (file_path: string) -> MIDI_File, bool
//
//     Reads a MIDI file and returns it contents; the second return value indicates success.


// * Further reading
//
// One good source of MIDI information is: https://www.recordingblogs.com/wiki/musical-instrument-digital-interface-midi


#module_parameters(VERBOSE_LOGGING := false, CLIENT_NAME := "jai-midi");

#load "midi.jai";
#load "midi_file.jai";
#load "queue.jai";

// Utility function used in the examples, which can also be useful for debugging.
print_message_info :: (using message: MIDI_Message, timestamp: Apollo_Time) {
    f :: (value: int, digits := 2) -> FormatInt #expand { return FormatInt.{value=value, base=16, minimum_digits=digits}; }

    print("%", status);
    if status < .Pitch_Bend  print(" (channel %): ", channel);
    else                             print(": ");

    if status == {
        case .Note_On; #through;
        case .Note_Off;            print("note = 0x%, velocity = 0x%", f(note_info.note), f(note_info.velocity));
        case .Polyphonic_Pressure; print("note = 0x%, pressure = 0x%", f(polyphonic_pressure_info.note), f(polyphonic_pressure_info.pressure));
        case .Control_Change;      print("controller = 0x%, value = 0x%", f(control_change_info.controller), f(control_change_info.value));
        case .Program_Change;      print("program = 0x%", f(program_change_info.program));
        case .Channel_Pressure;    print("pressure = 0x%", f(channel_pressure_info.pressure));
        case .Pitch_Bend;          print("value = 0x% (%)", f(pitch_bend_get_value(pitch_bend_info), digits=4), formatFloat(pitch_bend_get_float(pitch_bend_info), trailing_width = 2, zero_removal = .NO));

        case .System_Exclusive; {
            data := system_exclusive_info.buffer;
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
