//
// Runs the test suites. Optionally pass which test suites to run.
//
// Example usage: jai tests.jai - [suites]
//

AT_COMPILE_TIME  :: true;
SELECTED_SUITES  :: string.[];
LOOPBACK_NAME    :: "";
RUN_UNSAFE_TESTS :: false;
VERBOSE_LOGGING  :: false;
CLIENT_NAME      :: "jai-midi-tests";

// Loaded rather than imported, so that the tests can reach the parts of the module that are internal to it.
#load "../midi.jai";
#load "../midi_file.jai";
#load "../queue.jai";
#if OS != .MACOS {
    #load "../ump.jai"; // On macOS, the platform layer already loads this.
}

#import "Atomics";
#import "File";
#import "Math";

#load "framework.jai";
#load "message_tests.jai";
#load "sysex_tests.jai";
#load "midi_file_tests.jai";
#load "endpoint_tests.jai";
#load "queue_tests.jai";

SUITES :: Test_Suite.[
    .{"message",   "Regular MIDI messages",     run_message_tests},
    .{"sysex",     "System-exclusive messages", run_sysex_tests},
    .{"midi-file", "MIDI files",                run_midi_file_tests},
    .{"endpoint",  "Endpoints",                 run_endpoint_tests},
    .{"queue",     "MIDI_Queue",                run_queue_tests},
];

#if AT_COMPILE_TIME {
    #run {
        #import "Compiler";

        args := get_build_options().compile_time_command_line;

        set_build_options_dc(.{do_output=false});

        if !run_test_suites(SUITES, args) {
            log_error("Some tests failed; see the summary above.");
        }
    }
} else {
    main :: () {
        if !run_test_suites(SUITES, SELECTED_SUITES)  exit(1);
    }
}
