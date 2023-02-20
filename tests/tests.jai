//
// To run these tests, use this command in the module's main directory: jai first.jai - test
//

MESSAGE_QUEUE_SIZE :: 256;
VERBOSE_LOGGING :: false;
CLIENT_NAME :: "";

// We don't directly #import the module, since we want to be able to test functions in module scope.
#load "../midi.jai";
#load "../midi_file.jai";

TEST_LOGGING_ENABLED :: true;

test_log :: (format: string, args: ..Any) {
    if TEST_LOGGING_ENABLED  log(format, ..args);
}

assert_equal :: (a: [] u8, b: [] u8) {
    assert(a.count == b.count, "Buffers are not the same length (% vs. %).", a.count, b.count);
    for 0..a.count - 1  assert(a[it] == b[it], "Buffers are not equal at index % (0x% != 0x%).", it, formatInt(a[it], base=16), formatInt(b[it], base=16));
}

assert_equal :: (a: *[] u8, b: *[] u8) {
    assert(a != null && b != null, "At least one of the buffers is null.");
    assert_equal(<<a, <<b);
}

assert_equal :: (a: MIDI_Message, b: MIDI_Message) {
    assert(a.status == b.status, "Message statusses are not equal (% and %).", a.status, b.status);
    if a.status < .System_Exclusive  assert(a.channel == b.channel, "Message channels are not equal (% and %).", a.channel, b.channel);
    if a.status != .System_Exclusive {
        assert_equal(a.bytes, b.bytes);
    } else {
        assert_equal(a.system_exclusive_info.buffer, b.system_exclusive_info.buffer);
    }
}

#load "midi.jai";
#load "midi_files.jai";
