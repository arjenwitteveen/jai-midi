//
// Tests for reading Standard MIDI Files.
//
// Each test builds a small MIDI file in memory, writes it to a temporary file and reads it back with read_midi_file.
//
// Build and run the tests with:
//
//   jai tests/midi_file_tests.jai
//   ./midi_file_tests
//
// Some of these tests describe behavior the module doesn't have yet, so not all of them pass. Each test states the
// intended behavior. Assertions inside the module are recorded instead of stopping the program, so one failure doesn't
// hide the others.
//
// The temporary file is written to the current directory and deleted afterwards.
//

VERBOSE_LOGGING :: false;
CLIENT_NAME     :: "jai-midi-file-test";

#load "../midi.jai";
#load "../midi_file.jai";

#import "File";

// Tests that can crash with the current code, because the reader reads past the end of the file. Enable them while
// working on bounds checking.
RUN_UNSAFE_TESTS :: false;

TEMPORARY_FILE :: "midi_file_tests.tmp.mid";

main :: () {
    context.assertion_failed = recording_assertion_handler;

    run_test("Success value is returned first",            test_return_order);
    run_test("Minimal format 0 file",                      test_minimal_format_0);
    run_test("Every channel message type",                 test_channel_message_types);
    run_test("Running status",                             test_running_status);
    run_test("Delta times",                                test_delta_times);
    run_test("Meta events",                                test_meta_events);
    run_test("Long meta event",                            test_long_meta_event);
    run_test("Unknown meta event type",                    test_unknown_meta_event);
    run_test("System-exclusive event",                     test_sysex_event);
    run_test("Escape event",                               test_escape_event);
    run_test("Format 1 with several tracks",               test_format_1);
    run_test("Header longer than 6 bytes",                 test_long_header);
    run_test("SMPTE time division",                        test_smpte_time_division);
    run_test("Unknown chunk",                              test_unknown_chunk);
    run_test("Note-on with velocity 0",                    test_note_on_velocity_zero);
    run_test("Event buffers point into the file content",  test_buffers_point_into_content);
    run_test("Running status cancelled by a meta event",   test_running_status_cancelled);
    run_test("Data byte at the start of a track",          test_data_byte_without_status);
    run_test("Realtime status in a track",                 test_realtime_status_in_track);
    run_test("Delta time longer than 4 bytes",             test_delta_time_too_long);
    run_test("Fewer tracks than the header says",          test_missing_track);
    run_test("Not a MIDI file",                            test_not_a_midi_file);
    run_test("Missing file",                               test_missing_file);

    #if RUN_UNSAFE_TESTS {
        run_test("Track longer than the file",             test_track_past_end_of_file);
        run_test("Event longer than its track",            test_event_past_end_of_track);
    }

    print("\n% checks passed, % failed.\n", passed_checks, failed_checks);
    if failed_checks  exit(1);
}

//
// Well-formed files.
//

// The rest of the module returns the success value first, and module.jai documents read_midi_file that way too.
test_return_order :: () {
    info := cast(*Type_Info_Procedure) type_info(type_of(read_midi_file));
    check(info.return_types.count == 2 && info.return_types[0] == type_info(bool),
          "read_midi_file should return (bool, MIDI_File), like the rest of the module and as module.jai documents.");
}

test_minimal_format_0 :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_event(*file, 0,  u8.[0x90, 0x3c, 0x64]);
    put_event(*file, 96, u8.[0x80, 0x3c, 0x40]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success  return;

    check(midi_file.format == 0, "Expected format 0, got %.", midi_file.format);
    check(midi_file.time_division == 96, "Expected time division 96, got %.", midi_file.time_division);
    if !check_track_count(midi_file, 1)  return;

    events := midi_file.tracks[0].events;
    if !check_event_count(events, 3)  return;

    check_note(events[0], .Note_On,  channel = 0, note = 0x3c, velocity = 0x64, delta_time = 0);
    check_note(events[1], .Note_Off, channel = 0, note = 0x3c, velocity = 0x40, delta_time = 96);
    check_meta(events[2], .End_Of_Track, u8.[]);
}

// Program change and channel pressure have one data byte, the others two. If either is read wrongly, every following
// event is misaligned.
test_channel_message_types :: () {
    Expected :: struct {
        bytes: [] u8;
        status: MIDI_Status;
    }

    expected := Expected.[
        .{u8.[0x80, 0x10, 0x20], .Note_Off},
        .{u8.[0x91, 0x11, 0x21], .Note_On},
        .{u8.[0xa2, 0x12, 0x22], .Polyphonic_Pressure},
        .{u8.[0xb3, 0x13, 0x23], .Control_Change},
        .{u8.[0xc4, 0x14],       .Program_Change},
        .{u8.[0xd5, 0x15],       .Channel_Pressure},
        .{u8.[0xe6, 0x16, 0x26], .Pitch_Bend},
        .{u8.[0xcf, 0x7f],       .Program_Change},
        .{u8.[0x9f, 0x7f, 0x7f], .Note_On},
    ];

    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 480);
    track := begin_track(*file);
    for expected  put_event(*file, cast(u32) it_index, it.bytes);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;

    events := midi_file.tracks[0].events;
    if !check_event_count(events, expected.count + 1)  return;

    for expected {
        event := events[it_index];
        if !check(!event.is_meta_event, "Event % is a meta event.", it_index)  continue;

        message := event.midi_event;
        check(event.delta_time == cast(u32) it_index, "Event % has delta time %, expected %.", it_index, event.delta_time, it_index);
        check(message.status == it.status, "Event % has status %, expected %.", it_index, message.status, it.status);
        check(message.channel == (it.bytes[0] & 0x0f), "Event % has channel %, expected %.", it_index, message.channel, it.bytes[0] & 0x0f);
        for 1..it.bytes.count - 1 {
            check(message.bytes[it - 1] == expected[it_index].bytes[it], "Event % has data byte % = 0x%, expected 0x%.",
                  it_index, it - 1, formatInt(message.bytes[it - 1], base = 16), formatInt(expected[it_index].bytes[it], base = 16));
        }
    }

    check_meta(events[expected.count], .End_Of_Track, u8.[]);
}

test_running_status :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_event(*file, 0,  u8.[0x93, 0x3c, 0x64]);
    put_event(*file, 10, u8.[0x3e, 0x65]);       // Running status: note-on, channel 3.
    put_event(*file, 10, u8.[0x40, 0x00]);       // Running status: note-on with velocity 0.
    put_event(*file, 10, u8.[0xc5, 0x10]);       // Program change, channel 5.
    put_event(*file, 0,  u8.[0x11]);             // Running status with one data byte.
    put_event(*file, 0,  u8.[0x12]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;

    events := midi_file.tracks[0].events;
    if !check_event_count(events, 7)  return;

    check_note(events[0], .Note_On, channel = 3, note = 0x3c, velocity = 0x64, delta_time = 0);
    check_note(events[1], .Note_On, channel = 3, note = 0x3e, velocity = 0x65, delta_time = 10);
    check_note(events[2], .Note_On, channel = 3, note = 0x40, velocity = 0x00, delta_time = 10);

    for program: u8.[0x10, 0x11, 0x12] {
        event := events[3 + it_index];
        check(!event.is_meta_event && event.midi_event.status == .Program_Change, "Event % is not a program change.", 3 + it_index);
        check(event.midi_event.channel == 5, "Event % has channel %, expected 5.", 3 + it_index, event.midi_event.channel);
        check(event.midi_event.program_change_info.program == program, "Event % has program 0x%, expected 0x%.",
              3 + it_index, formatInt(event.midi_event.program_change_info.program, base = 16), formatInt(program, base = 16));
    }
}

// Delta times are variable-length quantities of 1 to 4 bytes. The values cover each length and the boundaries between
// them.
test_delta_times :: () {
    deltas := u32.[0, 1, 0x7f, 0x80, 0x2000, 0x3fff, 0x4000, 0x1f_ffff, 0x20_0000, 0x0fff_ffff];

    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    for deltas  put_event(*file, it, u8.[0x90, 0x3c, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;

    events := midi_file.tracks[0].events;
    if !check_event_count(events, deltas.count + 1)  return;

    for deltas {
        check(events[it_index].delta_time == it, "Event % has delta time 0x%, expected 0x%.",
              it_index, formatInt(events[it_index].delta_time, base = 16), formatInt(it, base = 16));
    }
}

test_meta_events :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_meta(*file, 0, .Sequence_Or_Track_Name, cast([] u8) "Piano");
    put_meta(*file, 0, .Set_Tempo,              u8.[0x07, 0xa1, 0x20]);
    put_meta(*file, 0, .Time_Signature,         u8.[0x04, 0x02, 0x18, 0x08]);
    put_meta(*file, 0, .Key_Signature,          u8.[0xfd, 0x01]);
    put_meta(*file, 0, .Text_Event,             u8.[]);
    put_event(*file, 0, u8.[0x90, 0x3c, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;

    events := midi_file.tracks[0].events;
    if !check_event_count(events, 7)  return;

    check_meta(events[0], .Sequence_Or_Track_Name, cast([] u8) "Piano");
    check_meta(events[1], .Set_Tempo,              u8.[0x07, 0xa1, 0x20]);
    check_meta(events[2], .Time_Signature,         u8.[0x04, 0x02, 0x18, 0x08]);
    check_meta(events[3], .Key_Signature,          u8.[0xfd, 0x01]);
    check_meta(events[4], .Text_Event,             u8.[]);
    check_note(events[5], .Note_On, channel = 0, note = 0x3c, velocity = 0x64, delta_time = 0);
    check_meta(events[6], .End_Of_Track,           u8.[]);
}

// A meta event of more than 127 bytes has a length of more than one byte.
test_long_meta_event :: () {
    text: [300] u8;
    for * text  it.* = cast,trunc(u8) (#char "a" + it_index % 26);

    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_meta(*file, 0, .Lyric, text);
    put_event(*file, 0, u8.[0x90, 0x3c, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;

    events := midi_file.tracks[0].events;
    if !check_event_count(events, 3)  return;

    check_meta(events[0], .Lyric, text);
    check_note(events[1], .Note_On, channel = 0, note = 0x3c, velocity = 0x64, delta_time = 0);
}

// Readers must skip meta events they don't know, using their length.
test_unknown_meta_event :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_meta(*file, 0, cast(MIDI_Meta_Event_Type) 0x60, u8.[0x01, 0x02, 0x03]);
    put_event(*file, 0, u8.[0x90, 0x3c, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;

    events := midi_file.tracks[0].events;
    if !check_event_count(events, 3)  return;

    check_meta(events[0], cast(MIDI_Meta_Event_Type) 0x60, u8.[0x01, 0x02, 0x03]);
    check_note(events[1], .Note_On, channel = 0, note = 0x3c, velocity = 0x64, delta_time = 0);
}

// In a file, a system-exclusive event is stored as 0xf0, a length, and the rest of the message including 0xf7. The
// message read from the file should look the same as one received from an input: starting with 0xf0 and ending with
// 0xf7. Then it can also be sent with send_midi_message as it is.
test_sysex_event :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_vlq(*file, 0);
    put_bytes(*file, u8.[0xf0, 0x05, 0x43, 0x12, 0x00, 0x01, 0xf7]);
    put_event(*file, 0, u8.[0x90, 0x3c, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;

    events := midi_file.tracks[0].events;
    if !check_event_count(events, 3)  return;

    event := events[0];
    check(!event.is_meta_event && event.midi_event.status == .System_Exclusive, "The first event is not a system-exclusive message.");
    check_bytes(event.midi_event.system_exclusive_info.buffer, u8.[0xf0, 0x43, 0x12, 0x00, 0x01, 0xf7], "system-exclusive message");
    check_note(events[1], .Note_On, channel = 0, note = 0x3c, velocity = 0x64, delta_time = 0);
}

// An event starting with 0xf7 contains bytes to send as they are, such as realtime messages or the later parts of a
// system-exclusive message that is split up in time. Currently such an event is stored as a message with status
// End_Of_System_Exclusive whose buffer holds those bytes. This test documents that representation.
test_escape_event :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_vlq(*file, 0);
    put_bytes(*file, u8.[0xf7, 0x02, 0xf8, 0xfa]);
    put_event(*file, 0, u8.[0x90, 0x3c, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;

    events := midi_file.tracks[0].events;
    if !check_event_count(events, 3)  return;

    event := events[0];
    check(!event.is_meta_event && event.midi_event.status == .End_Of_System_Exclusive, "The escape event has status %.", event.midi_event.status);
    check_bytes(event.midi_event.system_exclusive_info.buffer, u8.[0xf8, 0xfa], "escaped bytes");
    check_note(events[1], .Note_On, channel = 0, note = 0x3c, velocity = 0x64, delta_time = 0);
}

test_format_1 :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 1, track_count = 3, time_division = 480);

    // Conductor track.
    track := begin_track(*file);
    put_meta(*file, 0, .Set_Tempo, u8.[0x07, 0xa1, 0x20]);
    put_end_of_track(*file);
    end_track(*file, track);

    // Two tracks with notes on different channels.
    for channel: u8.[1, 2] {
        track := begin_track(*file);
        for 0..channel {
            put_event(*file, 120, u8.[0x90 | channel, 0x30 + cast(u8) it, 0x50]);
        }
        put_end_of_track(*file);
        end_track(*file, track);
    }

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success  return;

    check(midi_file.format == 1, "Expected format 1, got %.", midi_file.format);
    if !check_track_count(midi_file, 3)  return;

    check(midi_file.tracks[0].events.count == 2, "Track 0 has % events, expected 2.", midi_file.tracks[0].events.count);
    check(midi_file.tracks[1].events.count == 3, "Track 1 has % events, expected 3.", midi_file.tracks[1].events.count);
    check(midi_file.tracks[2].events.count == 4, "Track 2 has % events, expected 4.", midi_file.tracks[2].events.count);

    for track: midi_file.tracks {
        channel := cast(u8) it_index;
        if it_index == 0  continue;
        for event: track.events {
            if event.is_meta_event  continue;
            check(event.midi_event.channel == channel, "Track % has an event on channel %.", it_index, event.midi_event.channel);
        }
    }
}

// The header length is stored in the file, and future versions may add fields. Readers must skip what they don't know.
test_long_header :: () {
    file: Smf;
    defer free_smf(*file);

    put_chars(*file, "MThd");
    put_u32(*file, 8);
    put_u16(*file, 0);
    put_u16(*file, 1);
    put_u16(*file, 96);
    put_u16(*file, 0xabcd); // Unknown extra field.

    track := begin_track(*file);
    put_event(*file, 0, u8.[0x90, 0x3c, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;
    check(midi_file.tracks[0].events.count == 2, "The track has % events, expected 2.", midi_file.tracks[0].events.count);
}

// A negative high byte means the time division is in SMPTE frames. It is stored as it is.
test_smpte_time_division :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 0xe728); // -25 frames per second, 40 ticks per frame.
    track := begin_track(*file);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success  return;
    check(midi_file.time_division == 0xe728, "Expected time division 0xe728, got 0x%.", formatInt(midi_file.time_division, base = 16));
}

// The format allows chunks of other types, which readers must skip. They don't count as tracks.
test_unknown_chunk :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 1, track_count = 2, time_division = 96);

    track := begin_track(*file);
    put_end_of_track(*file);
    end_track(*file, track);

    put_chars(*file, "XFIH");
    put_u32(*file, 4);
    put_bytes(*file, u8.[0x01, 0x02, 0x03, 0x04]);

    track = begin_track(*file);
    put_event(*file, 0, u8.[0x90, 0x3c, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "A file with an unknown chunk could not be read.");
    if !success || !check_track_count(midi_file, 2)  return;
    check(midi_file.tracks[1].events.count == 2, "The second track has % events, expected 2.", midi_file.tracks[1].events.count);
}

// Note-on messages with velocity 0 are kept as they are, not turned into note-off messages.
test_note_on_velocity_zero :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_event(*file, 0, u8.[0x90, 0x3c, 0x00]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;
    if !check_event_count(midi_file.tracks[0].events, 2)  return;

    check_note(midi_file.tracks[0].events[0], .Note_On, channel = 0, note = 0x3c, velocity = 0, delta_time = 0);
}

// Meta and system-exclusive buffers are not copied, but point into the file content, which the MIDI_File owns.
test_buffers_point_into_content :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_meta(*file, 0, .Marker, cast([] u8) "Verse");
    put_vlq(*file, 0);
    put_bytes(*file, u8.[0xf0, 0x03, 0x01, 0x02, 0xf7]);
    put_end_of_track(*file);
    end_track(*file, track);

    success, midi_file := parse(file.bytes);
    check(success, "The file could not be read.");
    if !success || !check_track_count(midi_file, 1)  return;

    events := midi_file.tracks[0].events;
    if !check_event_count(events, 3)  return;

    content_start := midi_file.content.data;
    content_end   := midi_file.content.data + midi_file.content.count;

    is_inside :: (buffer: [] u8, start: *u8, end: *u8) -> bool {
        return buffer.data >= start && buffer.data + buffer.count <= end;
    }

    check(is_inside(events[0].meta_event.buffer, content_start, content_end), "The meta event buffer is not inside the file content.");
    check(is_inside(events[1].midi_event.system_exclusive_info.buffer, content_start, content_end), "The system-exclusive buffer is not inside the file content.");
}

//
// Malformed files. read_midi_file must return false for these, without assertions: a bad file is not a bug in the
// program.
//

// Meta and system-exclusive events cancel running status, so a data byte after them is an error. (Some readers are
// lenient here and keep the earlier status. If you choose to do that, change this test.)
test_running_status_cancelled :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_event(*file, 0, u8.[0x90, 0x3c, 0x64]);
    put_meta(*file, 0, .Marker, u8.[]);
    put_event(*file, 0, u8.[0x3e, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    expect_rejected(file.bytes);
}

test_data_byte_without_status :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_event(*file, 0, u8.[0x3c, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    expect_rejected(file.bytes);
}

// Realtime and system common messages (other than system-exclusive) cannot appear in a track. 0xff is not in this
// list, because in a file it starts a meta event.
test_realtime_status_in_track :: () {
    for status: u8.[0xf1, 0xf2, 0xf3, 0xf6, 0xf8, 0xfa, 0xfc] {
        file: Smf;
        defer free_smf(*file);

        put_header(*file, format = 0, track_count = 1, time_division = 96);
        track := begin_track(*file);
        put_event(*file, 0, u8.[status]);
        put_event(*file, 0, u8.[0x90, 0x3c, 0x64]);
        put_end_of_track(*file);
        end_track(*file, track);

        expect_rejected(file.bytes, tprint("status 0x%", formatInt(status, base = 16)));
    }
}

test_delta_time_too_long :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_bytes(*file, u8.[0x81, 0x80, 0x80, 0x80, 0x00]); // Five bytes; at most four are allowed.
    put_bytes(*file, u8.[0x90, 0x3c, 0x64]);
    put_end_of_track(*file);
    end_track(*file, track);

    expect_rejected(file.bytes);
}

test_missing_track :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 1, track_count = 2, time_division = 96);
    track := begin_track(*file);
    put_end_of_track(*file);
    end_track(*file, track);

    expect_rejected(file.bytes);
}

test_not_a_midi_file :: () {
    expect_rejected(u8.[], "empty file");
    expect_rejected(cast([] u8) "MThd", "header type only");
    expect_rejected(cast([] u8) "RIFF\x24\x00\x00\x00WAVEfmt ", "a WAVE file");

    // A valid header, but the track chunk has the wrong type.
    file: Smf;
    defer free_smf(*file);
    put_header(*file, format = 0, track_count = 1, time_division = 96);
    put_chars(*file, "MTrx");
    put_u32(*file, 4);
    put_bytes(*file, u8.[0x00, 0xff, 0x2f, 0x00]);
    expect_rejected(file.bytes, "wrong track chunk type");
}

test_missing_file :: () {
    success, midi_file := read_midi_file("this file does not exist.mid");
    check(!success, "Reading a file that doesn't exist succeeded.");
}

// The track claims to be longer than the rest of the file.
test_track_past_end_of_file :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    put_chars(*file, "MTrk");
    put_u32(*file, 1000);
    put_event(*file, 0, u8.[0x90, 0x3c, 0x64]);

    expect_rejected(file.bytes);
}

// A meta event claims to be longer than the track that contains it.
test_event_past_end_of_track :: () {
    file: Smf;
    defer free_smf(*file);

    put_header(*file, format = 0, track_count = 1, time_division = 96);
    track := begin_track(*file);
    put_vlq(*file, 0);
    put_bytes(*file, u8.[0xff, 0x01, 0x40, 0x41, 0x42]); // Claims 64 bytes of text, has 2.
    end_track(*file, track);

    expect_rejected(file.bytes);
}

//
// Building files.
//

Smf :: struct {
    bytes: [..] u8;
}

free_smf :: (file: *Smf) {
    array_free(file.bytes);
}

put_bytes :: (file: *Smf, bytes: [] u8) {
    array_add(*file.bytes, ..bytes);
}

put_chars :: (file: *Smf, chars: string) {
    put_bytes(file, cast([] u8) chars);
}

put_u16 :: (file: *Smf, value: u16) {
    array_add(*file.bytes, cast,trunc(u8) (value >> 8), cast,trunc(u8) value);
}

put_u32 :: (file: *Smf, value: u32) {
    array_add(*file.bytes, cast,trunc(u8) (value >> 24), cast,trunc(u8) (value >> 16), cast,trunc(u8) (value >> 8), cast,trunc(u8) value);
}

// Writes a variable-length quantity: 7 bits per byte, most significant first, with the top bit set on all but the last.
put_vlq :: (file: *Smf, value: u32) {
    assert(value <= 0x0fff_ffff);

    bytes: [4] u8;
    count := 0;
    remaining := value;
    while true {
        bytes[count] = cast,trunc(u8) (remaining & 0x7f);
        count += 1;
        remaining >>= 7;
        if !remaining  break;
    }

    for < 0..count - 1 {
        byte := bytes[it];
        if it > 0  byte |= 0x80;
        array_add(*file.bytes, byte);
    }
}

put_header :: (file: *Smf, format: u16, track_count: u16, time_division: u16) {
    put_chars(file, "MThd");
    put_u32(file, 6);
    put_u16(file, format);
    put_u16(file, track_count);
    put_u16(file, time_division);
}

// Starts a track chunk and returns where its length must be filled in.
begin_track :: (file: *Smf) -> int {
    put_chars(file, "MTrk");
    length_offset := file.bytes.count;
    put_u32(file, 0);
    return length_offset;
}

end_track :: (file: *Smf, length_offset: int) {
    length := cast(u32) (file.bytes.count - length_offset - 4);
    file.bytes[length_offset + 0] = cast,trunc(u8) (length >> 24);
    file.bytes[length_offset + 1] = cast,trunc(u8) (length >> 16);
    file.bytes[length_offset + 2] = cast,trunc(u8) (length >> 8);
    file.bytes[length_offset + 3] = cast,trunc(u8) length;
}

put_event :: (file: *Smf, delta_time: u32, bytes: [] u8) {
    put_vlq(file, delta_time);
    put_bytes(file, bytes);
}

put_meta :: (file: *Smf, delta_time: u32, type: MIDI_Meta_Event_Type, data: [] u8) {
    put_vlq(file, delta_time);
    array_add(*file.bytes, 0xff, cast(u8) type);
    put_vlq(file, cast(u32) data.count);
    put_bytes(file, data);
}

put_end_of_track :: (file: *Smf) {
    put_meta(file, 0, .End_Of_Track, u8.[]);
}

//
// Reading files and checking the results.
//

parse :: (bytes: [] u8) -> success: bool, midi_file: MIDI_File {
    if !write_entire_file(TEMPORARY_FILE, bytes.data, bytes.count) {
        check(false, "Could not write the temporary file '%'.", TEMPORARY_FILE);
        return false, .{};
    }
    defer file_delete(TEMPORARY_FILE);

    success, midi_file := read_midi_file(TEMPORARY_FILE);
    return success, midi_file;
}

expect_rejected :: (bytes: [] u8, what := "", loc := #caller_location) {
    description := ifx what then tprint(" (%)", what) else "";
    assertions_before := library_assertions;

    success := parse(bytes);
    check(!success, "A malformed file was read successfully%.", description, loc = loc);
    check(library_assertions == assertions_before, "A malformed file triggered % assertion(s)%.",
          library_assertions - assertions_before, description, loc = loc);
}

check_track_count :: (midi_file: MIDI_File, expected: int, loc := #caller_location) -> bool {
    return check(midi_file.tracks.count == expected, "The file has % tracks, expected %.", midi_file.tracks.count, expected, loc = loc);
}

check_event_count :: (events: [] MIDI_File_Event, expected: int, loc := #caller_location) -> bool {
    return check(events.count == expected, "The track has % events, expected %.", events.count, expected, loc = loc);
}

check_note :: (event: MIDI_File_Event, status: MIDI_Status, channel: u8, note: u8, velocity: u8, delta_time: u32, loc := #caller_location) {
    if !check(!event.is_meta_event, "Expected a % event, got a meta event.", status, loc = loc)  return;

    message := event.midi_event;
    check(message.status == status, "Expected status %, got %.", status, message.status, loc = loc);
    check(message.channel == channel, "Expected channel %, got %.", channel, message.channel, loc = loc);
    check(message.note_info.note == note, "Expected note 0x%, got 0x%.", formatInt(note, base = 16), formatInt(message.note_info.note, base = 16), loc = loc);
    check(message.note_info.velocity == velocity, "Expected velocity 0x%, got 0x%.", formatInt(velocity, base = 16), formatInt(message.note_info.velocity, base = 16), loc = loc);
    check(event.delta_time == delta_time, "Expected delta time %, got %.", delta_time, event.delta_time, loc = loc);
}

check_meta :: (event: MIDI_File_Event, type: MIDI_Meta_Event_Type, data: [] u8, loc := #caller_location) {
    if !check(event.is_meta_event, "Expected a % meta event, got a % message.", type, event.midi_event.status, loc = loc)  return;

    check(event.meta_event.type == type, "Expected meta event type %, got %.", type, event.meta_event.type, loc = loc);
    check_bytes(event.meta_event.buffer, data, tprint("% meta event", type), loc = loc);
}

check_bytes :: (actual: [] u8, expected: [] u8, what := "data", loc := #caller_location) {
    if actual.count != expected.count {
        check(false, "The % has % bytes, but % were expected.", what, actual.count, expected.count, loc = loc);
        return;
    }

    for actual {
        if it != expected[it_index] {
            check(false, "The % differs at byte % (0x% instead of 0x%).", what, it_index,
                  formatInt(it, base = 16, minimum_digits = 2), formatInt(expected[it_index], base = 16, minimum_digits = 2), loc = loc);
            return;
        }
    }

    check(true, "");
}

run_test :: (name: string, test: () -> ()) {
    print("\n%\n", name);
    failures_before := failed_checks;
    test();
    if failed_checks == failures_before  print("  ok\n");
}

passed_checks: int;
failed_checks: int;

check :: (condition: bool, format: string, args: ..Any, loc := #caller_location) -> bool {
    if condition {
        passed_checks += 1;
        return true;
    }

    failed_checks += 1;
    print("  FAILED (line %): ", loc.line_number);
    print(format, ..args);
    print("\n");
    return false;
}

library_assertions: int;

// Reports assertions but keeps running, so that the remaining checks still run.
recording_assertion_handler :: (loc: Source_Code_Location, message: string) -> bool {
    library_assertions += 1;
    print("  (assertion in %:%: %)\n", path_filename(loc.fully_pathed_filename), loc.line_number, message);
    return false;
}
