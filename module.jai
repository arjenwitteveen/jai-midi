//
// This module aims to provide basic MIDI I/O support for Jai programs in a simple to use, cross-platform manner. It
// allows you to receive MIDI messages from a MIDI source, and send MIDI messages to a MIDI destination. Both regular
// messages and system-exclusive messages are supported. For receiving MIDI data, you have the choice of using a
// callback function, or polling a message queue. There is also basic support for reading MIDI files.
//
// The module does not aim to support all the possible functionality that MIDI (or the MIDI driver of each OS)
// provides. There is no support for MIDI 2.0.
//
// To use this module you need at least Jai beta 0.1.057.
//
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
//
//
// * Receiving MIDI.
//
// There are two ways of receiving MIDI input: through a callback that you provide, or by letting messages be written
// into a buffer that you can read from when you want (in a blocking or non-blocking way). The size of the buffer can be
// controlled using the MESSAGE_QUEUE_SIZE module parameter. If the buffer is full, further incoming messages will be
// discarded. In the case of a callback, be aware that the callback will generally run on a different thread than your
// main thread.
//
//   open_input :: (source_index: int, callback: MIDI_Input_Callback = null, user_data: *void = null) -> *MIDI_Input
//
//     Open an input connection to the MIDI source with the given index; returns null upon failure. If the callback
//     parameter is null, the message queue will used. If a callback is used, you can pass custom data to it using the
//     user_data pointer. Callbacks have the following signature:
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
//   read_message :: (input: *MIDI_Input, timeout := -1) -> MIDI_Message, Apollo_Time, bool
//
//     Read a message from the queue (this is only valid to do if you have not defined a callback for this input). By
//     default, this call blocks until a message is received; you can optionally provide a timeout in milliseconds. The
//     returned message and timestamp are analogous to what a callback function receives. The boolean denotes if a
//     message was successfully read from the queue.
//
//
// A note on system-exclusive messages: there is support for receiving arbitrary-length system-exclusive messages. The
// payload data for these is stored on a separate queue (which may become full if you don't use a callback and don't
// poll for messages often enough; further system-exclusive messages will then be discarded). Once either a callback
// fires or read_message is called, the system-exclusive buffer is transferred from this queue into temporary
// storage. This may not be the most optimal way of doing things, but this does make using the API easier: you decide if
// you want to copy the data to keep it around for longer, or just use it when you receive it, forget about it, and call
// reset_temporary_storage at some later point. This also means everything works the same, regardless of whether you're
// using a callback or a message queue. The received buffer will include the system-exclusive status bytes (0xf0 and
// 0xf7) as the first and last bytes. When sending a system-exclusive message, you are also responsible for adding those
// bytes to the buffer you want to send.
//
//
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
//
//
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
//
//
// * Reading MIDI files.
//
// Support for reading MIDI files is provided through midi_file.jai. The interface is very simple.
//
//   read_midi_file :: (file_path: string) -> MIDI_File, bool
//
//     Reads a MIDI file and returns it contents; the second return value indicates success.
//
//

//
// One good source of MIDI information is: https://www.recordingblogs.com/wiki/musical-instrument-digital-interface-midi.
//

#module_parameters(MESSAGE_QUEUE_SIZE := 256, VERBOSE_LOGGING := false, CLIENT_NAME := "");

#load "midi.jai";
#load "midi_file.jai";
