#if OS == .WINDOWS {
    #load "windows.jai";
} else #if OS == .LINUX {
    #load "linux.jai";
} else #if OS == .MACOS {
    #load "macos.jai";
} else {
    #assert false "The current operating system is not supported yet.";
}

MIDI_Input_Callback :: #type (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) -> ();

MIDI_Input :: struct {
    index: int;
    callback: MIDI_Input_Callback;
    callback_data: *void;
    decoder: MIDI_Decoder;
    using platform_data: MIDI_Input_Platform_Data;
}

MIDI_Output :: struct {
    index: int;
    using platform_data: MIDI_Output_Platform_Data;
}

MIDI_Message :: struct {
    status: MIDI_Status;
    channel: u8;

    union {
        bytes: [2] u8;
        note_info: MIDI_Note_Info;
        polyphonic_pressure_info: MIDI_Polyphonic_Pressure_Info;
        control_change_info: MIDI_Control_Change_Info;
        program_change_info: MIDI_Program_Change_Info;
        channel_pressure_info: MIDI_Channel_Pressure_Info;
        pitch_bend_info: MIDI_Pitch_Bend_Info;
        system_exclusive_info: MIDI_System_Exclusive_Info;
        quarter_frame_info: MIDI_Quarter_Frame_Info;
        song_position_pointer_info: MIDI_Song_Position_Pointer_Info;
        song_request_info: MIDI_Song_Request_Info;
    }
}

MIDI_Note_Info                  :: struct { note: u8; velocity: u8; }
MIDI_Polyphonic_Pressure_Info   :: struct { note: u8; pressure: u8; }
MIDI_Control_Change_Info        :: struct { controller: u8; value: u8; }
MIDI_Program_Change_Info        :: struct { program: u8; }
MIDI_Channel_Pressure_Info      :: struct { pressure: u8; }
MIDI_Pitch_Bend_Info            :: struct { fine: u8; coarse: u8; }
MIDI_System_Exclusive_Info      :: struct { buffer: [] u8; }
MIDI_Quarter_Frame_Info         :: struct { data: u8; }
MIDI_Song_Position_Pointer_Info :: struct { pointer_lsb: u8; pointer_msb: u8; }
MIDI_Song_Request_Info          :: struct { song: u8; }

MIDI_Decoder :: struct {
    running_status: u8;
    message_buffer: [..] u8;
    message_in_progress: bool;
}

get_source_index_by_name :: (name: string, match_full_name := false) -> int {
    auto_release_temp();
    result := -1;
    sources := get_number_of_sources();
    for 0..sources - 1 {
        source_name := get_source_name(it);
        if (!match_full_name && contains(source_name, name)) || source_name == name {
            result = it;
            break;
        }
    }
    return result;
}

get_destination_index_by_name :: (name: string, match_full_name := false) -> int {
    auto_release_temp();
    result := -1;
    destinations := get_number_of_destinations();
    for 0..destinations - 1 {
        destination_name := get_destination_name(it);
        if (!match_full_name && contains(destination_name, name)) || destination_name == name {
            result = it;
            break;
        }
    }
    return result;
}

create_midi_message :: (bytes: [] u8) -> MIDI_Message, bool {
    decoder: MIDI_Decoder;
    result, success := decode_midi_bytes(*decoder, bytes);
    return result, success;
}

create_midi_message :: (status: MIDI_Status, data0: u8 = 0, data1: u8 = 0, channel: u8 = 0) -> MIDI_Message, bool {
    assert(data0 <= MIDI_DATA_BYTE_MAX, "First data byte is out of range (value is %, but the maximum allowed value is %).", data0, MIDI_DATA_BYTE_MAX);
    assert(data1 <= MIDI_DATA_BYTE_MAX, "Second data byte is out of range (value is %, but the maximum allowed value is %).", data1, MIDI_DATA_BYTE_MAX);
    decoder: MIDI_Decoder;
    bytes: [3] u8;
    bytes[0] = make_status_byte(status, channel);
    bytes[1] = data0;
    bytes[2] = data1;
    result, success := decode_midi_bytes(*decoder, bytes);
    return result, success;
}

create_control_change_message :: (controller: Control_Change, value: u8, channel: u8 = 0) -> MIDI_Message, bool {
    result, success := create_midi_message(.Control_Change, cast(u8) controller, value, channel);
    return result, success;
}

create_pitch_bend_message :: (value: int, channel: u8 = 0) -> MIDI_Message {
    assert(value >= 0 && value <= U14_MAX, "Pitch bend value is out of range (value is %, but the allowed range is [0, %]).", value, U14_MAX);
    coarse := cast,no_check(u8) ((value >> 7) & MIDI_DATA_BYTE_MAX);
    fine := cast,no_check(u8) (value & MIDI_DATA_BYTE_MAX);
    return create_midi_message(.Pitch_Bend, fine, coarse, channel);
}

create_pitch_bend_message :: (value: float, channel: u8 = 0) -> MIDI_Message {
    int_value := cast(int) (((clamp(value, -1.0, 1.0) + 1.0) / 2.0) * U14_MAX);
    return create_pitch_bend_message(int_value, channel);
}

create_system_exclusive_message :: (data: [] u8) -> MIDI_Message {
    assert(data.count >= 2 && data[0] == 0xf0 && data[data.count - 1] == 0xf7, "The given buffer must start with a system-exclusive status byte (0xf0) and end with an end-of system-exclusive status byte (0xf7).");
    result: MIDI_Message;
    result.status = .System_Exclusive;
    result.system_exclusive_info.buffer = data;
    return result;
}

send_midi_message :: (output: *MIDI_Output, message: MIDI_Message) -> bool {
    if message.status == .System_Exclusive {
        return send_midi_message(output, message.system_exclusive_info.buffer);
    }

    bytes, byte_count := encode_midi_message(message);
    message_bytes: [] u8 = bytes;
    message_bytes.count = byte_count;
    return send_midi_message(output, message_bytes);
}

send_midi_messages :: (output: *MIDI_Output, messages: [] MIDI_Message) -> bool {
    // @Speed: If possible, replace this with platform-specific versions that can batch the messages in a smarter way.
    success := true;
    for messages  success &= send_midi_message(output, it);
    return success;
}

send_midi_messages :: (output: *MIDI_Output, messages: ..MIDI_Message) -> bool {
    return send_midi_messages(output, messages);
}

// Get the pitch bend value as a unsigned 14-bit value (8192 is neutral, 0 is maximum down, 16383 is maximum up).
pitch_bend_get_value :: (info: MIDI_Pitch_Bend_Info) -> int {
    return get_14_bit_value(info.coarse, info.fine);
}

// Get the pitch bend value as a float value (0.0 is neutral, -1.0 is maximum down, 1.0 is maximum up).
pitch_bend_get_float :: (info: MIDI_Pitch_Bend_Info) -> float {
    result := cast(float) pitch_bend_get_value(info);
    result /= cast(float) U14_MAX;
    result = clamp(-1.0 + 2.0 * result, -1.0, 1.0);
    return result;
}

get_14_bit_value :: (msb: u8, lsb: u8) -> int {
    result: int;
    result = msb & MIDI_DATA_BYTE_MAX;
    result <<= 7;
    result |= lsb & MIDI_DATA_BYTE_MAX;
    assert(result >= 0 && result <= U14_MAX);
    return result;
}

make_status_byte :: (status: MIDI_Status, channel: u8 = 0) -> u8 #expand {
    assert(status < .System_Exclusive || channel == 0, "For a message with status %, no channel value should be set (channel value is %).", status, channel);
    assert(channel <= MIDI_CHANNEL_MAX, "Channel value is out of range (value is %, but the maximum allowed value is %).", channel, MIDI_CHANNEL_MAX);
    return (cast(u8) status) | channel;
}

get_status :: (byte: u8) -> MIDI_Status #expand {
    if byte >= 0xf0  return cast(MIDI_Status) byte;
    return cast(MIDI_Status) (byte & 0xf0);
}

is_voice_status :: (status: MIDI_Status) -> bool #expand {
    return status >= .Note_Off && status < .System_Exclusive;
}

is_realtime_status :: (status: MIDI_Status) -> bool #expand {
    return status >= .Timing_Clock && status <= .System_Reset;
}

MIDI_Status :: enum u8 {
    Invalid                 :: 0x00;

    // Voice messages.
    Note_Off                :: 0x80; // A lot of devices send a Note_On with a velocity of 0 rather than a Note_Off.
    Note_On                 :: 0x90;
    Polyphonic_Pressure     :: 0xa0;
    Control_Change          :: 0xb0;
    Program_Change          :: 0xc0;
    Channel_Pressure        :: 0xd0;
    Pitch_Bend              :: 0xe0;

    // System common messages.
    System_Exclusive        :: 0xf0;
    Time_Code_Quarter_Frame :: 0xf1;
    Song_Position_Pointer   :: 0xf2;
    Song_Select             :: 0xf3;
    Tune_Request            :: 0xf6;
    End_Of_System_Exclusive :: 0xf7;

    // System realtime messages.
    Timing_Clock            :: 0xf8;
    Start                   :: 0xfa;
    Continue                :: 0xfb;
    Stop                    :: 0xfc;
    Active_Sensing          :: 0xfe;
    System_Reset            :: 0xff;
};

// A non-exhaustive list with some of the named controllers you might want to use.
Control_Change :: enum u8 {
    Bank_Select                  :: 0;
    Modulation                   :: 1;
    Breath                       :: 2;
    Foot_Controller              :: 4;
    Portamento_Time              :: 5;
    Data_Entry                   :: 6;
    Volume                       :: 7;
    Balance                      :: 8;
    Pan                          :: 10;
    Expression                   :: 11;
    Effect_Control_1             :: 12;
    Effect_Control_2             :: 13;
    General_Purpose_Controller_1 :: 16;
    General_Purpose_Controller_2 :: 17;
    General_Purpose_Controller_3 :: 18;
    General_Purpose_Controller_4 :: 19;
    Sustain_Pedal                :: 64;
    Portamento_On_Off            :: 65;
    Sostenuto                    :: 66;
    Soft_Pedal                   :: 67;
    Legato_Footswitch            :: 68;
    Hold_2                       :: 69;
    Sound_Controller_1           :: 70;
    Sound_Controller_2           :: 71;
    Sound_Controller_3           :: 72;
    Sound_Controller_4           :: 73;
    Sound_Controller_5           :: 74;
    Decay_Time                   :: 75;
    Vibrato_Rate                 :: 76;
    Vibrato_Depth                :: 77;
    Vibrato_Delay                :: 78;
    General_Purpose_Controller_5 :: 80;
    General_Purpose_Controller_6 :: 81;
    General_Purpose_Controller_7 :: 82;
    General_Purpose_Controller_8 :: 83;
    Portamento_Control           :: 84;
    Effects_1_Depth              :: 91;
    Effects_2_Depth              :: 92;
    Effects_3_Depth              :: 93;
    Effects_4_Depth              :: 94;
    Effects_5_Depth              :: 95;
}

U14_MAX            :: 0x3fff;
MIDI_DATA_BYTE_MAX :: 0x7f;
MIDI_CHANNEL_MAX   :: 0x0f;

#scope_module

free_input :: (input: *MIDI_Input) {
    array_free(input.decoder.message_buffer);
    free(input);
}

number_of_data_bytes :: (status: MIDI_Status) -> int {
    if status == .System_Exclusive || status == .Tune_Request || is_realtime_status(status)  return 0;
    if status == .Channel_Pressure || status == .Program_Change || status == .Time_Code_Quarter_Frame || status == .Song_Select return 1;
    return 2;
}

encode_midi_message :: (message: MIDI_Message) -> [3] u8, int {
    assert(message.status != .System_Exclusive, "System-exclusive messages do not need encoding.");
    result: [3] u8;
    data_bytes := number_of_data_bytes(message.status);
    result[0] = make_status_byte(message.status, message.channel);
    for 0..data_bytes - 1  result[it + 1] = message.bytes[it];
    return result, data_bytes + 1;
}

decode_midi_bytes :: (decoder: *MIDI_Decoder, bytes: [] u8) -> MIDI_Message, bool {
    message: MIDI_Message;

    if bytes.count == 0 {
        assert(false, "Received empty byte array.");
        return message, false;
    }

    status_byte := bytes[0];
    status := get_status(status_byte);

    if status == .Invalid {
        if decoder.running_status == 0 {
            assert(false, "Received message without status byte, but no running status is available.");
            return message, false;
        }

        status_byte = decoder.running_status;
        status = get_status(decoder.running_status);
    } else {
        if is_voice_status(status)      decoder.running_status = status_byte;
        if status == .System_Exclusive  decoder.running_status = 0;
    }

    if status == .System_Exclusive {
        message.system_exclusive_info.buffer = bytes;
    } else {
        data_bytes := number_of_data_bytes(status);
        if bytes.count - 1 < data_bytes {
            log_error("Expected % bytes for % message, but only received % bytes.", data_bytes + 1, status, bytes.count);
            return message, false;
        }

        for 0..data_bytes - 1  message.bytes[it] = bytes[1 + it];
    }

    message.status = status;
    if status < .System_Exclusive  message.channel = status_byte & 0x0f;

    return message, true;
}

post_message_to_input :: (input: *MIDI_Input, _message: MIDI_Message, timestamp: Apollo_Time) {
    message := _message;

    if input.decoder.message_in_progress && message.status < .System_Exclusive {
        reset_system_exclusive_buffer(*input.decoder);
        input.decoder.message_in_progress = false;
        log_verbose("System-exclusive message was interrupted.");
    }

    input.callback(input, message, timestamp, input.callback_data);
}

reset_system_exclusive_buffer :: (decoder: *MIDI_Decoder) {
    array_reset_keeping_memory(*decoder.message_buffer);
}

handle_system_exclusive_message :: (input: *MIDI_Input, data: [] u8, error: bool) -> MIDI_Message, bool {
    decoder := *input.decoder;
    result: MIDI_Message;

    if error {
        if decoder.message_in_progress {
            log_error("Discarding an invalid system-exclusive message (% bytes).", decoder.message_buffer.count);
            decoder.message_in_progress = false;
        }

        return result, false;
    }

    if data.count == 0  return result, false;

    start_status := get_status(data[0]);
    end_status := get_status(data[data.count - 1]);

    message_is_starting := start_status == .System_Exclusive;
    message_is_complete := end_status == .End_Of_System_Exclusive;

    if !decoder.message_in_progress {
        // Start new system-exclusive message.
        if !message_is_starting {
            assert(false, "Given data does not start with a system-exclusive status byte (expected 0x%, but got 0x%).", formatInt(MIDI_Status.System_Exclusive, base=16), formatInt(start_status, base=16));
            return result, false;
        }

        reset_system_exclusive_buffer(decoder);
    }

    array_add(*decoder.message_buffer, ..data);

    decoder.message_in_progress = !message_is_complete;
    decoder.running_status = 0;

    message_ready := !decoder.message_in_progress;

    if message_ready  result = create_system_exclusive_message(decoder.message_buffer);

    return result, message_ready;
}

log_verbose :: (format: string, args: ..Any) #expand {
    #if VERBOSE_LOGGING  log(format, ..args);
}

#import "Basic";
#import "String";
#import "Thread";
