//
// A small test framework shared by the test suites. tests.jai loads it together with the suites; see there for how to
// run them.
//
// A suite is a procedure that runs tests with run_test, or with begin_test and end_test for tests that take arguments.
// A test fails if any of its checks fail. Checks outside a test count towards the suite, and a failing one is reported
// as a failure in the suite's setup. Assertions inside the module are recorded instead of stopping the program, so one
// failure doesn't hide the others.
//

Test_Suite :: struct {
    name: string;   // Used to select the suite on the command line.
    title: string;
    run: () -> ();
}

// Runs the selected suites (all of them if none are selected), prints a summary, and returns whether everything passed.
run_test_suites :: (suites: [] Test_Suite, selected: [] string) -> bool {
    context.assertion_failed = recording_assertion_handler;

    for name: selected {
        found := false;
        for suites  if it.name == name  found = true;
        if !found {
            print("Unknown test suite '%'. The available suites are:", name);
            for suites  print(" %", it.name);
            print(".\n");
            return false;
        }
    }

    for suite: suites {
        if selected.count {
            is_selected := false;
            for selected  if it == suite.name  is_selected = true;
            if !is_selected  continue;
        }

        result: Suite_Result;
        result.name  = suite.name;
        result.title = suite.title;
        array_add(*suite_results, result);

        print("\n========== % ==========\n", suite.title);
        suite.run();
        if test_in_progress  end_test();
    }

    return print_summary();
}

// Prints a heading for a group of tests within a suite.
begin_section :: (name: string) {
    print("\n----- % -----\n", name);
    current_section = name;
}

run_test :: (name: string, test: () -> ()) {
    begin_test(name);
    test();
    end_test();
}

// For tests that are currently disabled because they can crash. Pass 'unsafe' to the test command to run them.
run_unsafe_test :: (name: string, test: () -> ()) {
    #if RUN_UNSAFE_TESTS {
        run_test(name, test);
    } else {
        skip_test(name, "can crash with the current code; pass 'unsafe' to run it");
    }
}

begin_test :: (name: string) {
    assert(!test_in_progress, "begin_test was called for '%' while '%' is still running.", name, current_test);
    print("\n%\n", name);

    current_test = name;
    test_in_progress = true;
    test_skip_reason = "";
    failures_at_test_start = current_result().checks_failed;
}

end_test :: () {
    result := current_result();
    failed := result.checks_failed > failures_at_test_start;

    if failed {
        result.tests_failed += 1;
        array_add(*failed_tests, .{result.name, current_test});
    } else if test_skip_reason {
        result.tests_skipped += 1;
        array_add(*skipped_tests, .{result.name, current_test, test_skip_reason});
        print("  skipped: %\n", test_skip_reason);
    } else {
        result.tests_passed += 1;
        print("  ok\n");
    }

    test_in_progress = false;
}

// Marks the running test as skipped, unless one of its checks failed.
skip_current_test :: (reason: string) {
    assert(test_in_progress, "skip_current_test was called outside a test.");
    test_skip_reason = reason;
}

// Records a test, or a group of tests, that is not run at all.
skip_test :: (name: string, reason: string) {
    print("\n%\n  skipped: %\n", name, reason);
    result := current_result();
    result.tests_skipped += 1;
    array_add(*skipped_tests, .{result.name, name, reason});
}

check :: (condition: bool, format: string, args: ..Any, loc := #caller_location) -> bool {
    result := current_result();

    if condition {
        result.checks_passed += 1;
        return true;
    }

    result.checks_failed += 1;
    print("  FAILED (%:%): ", path_filename(loc.fully_pathed_filename), loc.line_number);
    print(format, ..args);
    print("\n");

    // A failure outside a test belongs to the setup of the section it is in.
    if !test_in_progress {
        result.setup_failures += 1;
        what := ifx current_section then tprint("setup of '%'", current_section) else "setup";
        array_add(*failed_tests, .{result.name, what});
    }

    return false;
}

check_bytes :: (actual: [] u8, expected: [] u8, what := "data", loc := #caller_location) {
    if actual.count != expected.count {
        check(false, "The % has % bytes, but % were expected.", what, actual.count, expected.count, loc = loc);
        return;
    }

    for actual {
        if it != expected[it_index] {
            check(false, "The % differs at byte % (0x% instead of 0x%).", what, it_index, hex(it), hex(expected[it_index]), loc = loc);
            return;
        }
    }

    check(true, "");
}

// Returns a string rather than a FormatInt, since a FormatInt would point at the parameter after it has gone away.
hex :: (value: u8) -> string {
    return tprint("%", formatInt(value, base = 16, minimum_digits = 2));
}

// The loopback to use for the loopback tests: the one given on the command line, or the default for the OS. On macOS,
// the default is a virtual endpoint that the suite creates itself, under the given name.
loopback_settings :: (macos_virtual_name: string) -> name: string, use_virtual_endpoint: bool {
    if LOOPBACK_NAME  return LOOPBACK_NAME, false;

    #if OS == .WINDOWS {
        return "loopMIDI", false;
    } else #if OS == .LINUX {
        return "Midi Through", false;
    } else {
        return macos_virtual_name, true;
    }
}

library_assertions: int;

// Reports assertions but keeps running, so that the remaining checks still run.
recording_assertion_handler :: (loc: Source_Code_Location, message: string) -> bool {
    library_assertions += 1;
    print("  (assertion in %:%: %)\n", path_filename(loc.fully_pathed_filename), loc.line_number, message);
    return false;
}

#scope_file

Suite_Result :: struct {
    name: string;
    title: string;

    tests_passed: int;
    tests_failed: int;
    tests_skipped: int;
    setup_failures: int;

    checks_passed: int;
    checks_failed: int;
}

Failed_Test :: struct {
    suite: string;
    test: string;
}

Skipped_Test :: struct {
    suite: string;
    test: string;
    reason: string;
}

suite_results: [..] Suite_Result;
failed_tests:  [..] Failed_Test;
skipped_tests: [..] Skipped_Test;

current_section: string;
current_test: string;
test_in_progress: bool;
test_skip_reason: string;
failures_at_test_start: int;

current_result :: () -> *Suite_Result {
    assert(suite_results.count > 0, "Checks can only be made while a test suite is running.");
    return *suite_results[suite_results.count - 1];
}

print_summary :: () -> success: bool {
    total: Suite_Result;
    total.title = "Total";

    title_width := total.title.count;
    for suite_results  title_width = max(title_width, it.title.count);

    print("\n========== Summary ==========\n\n");

    for suite_results {
        print_result_line(it, title_width);
        total.tests_passed   += it.tests_passed;
        total.tests_failed   += it.tests_failed;
        total.tests_skipped  += it.tests_skipped;
        total.setup_failures += it.setup_failures;
        total.checks_passed  += it.checks_passed;
        total.checks_failed  += it.checks_failed;
    }

    print("  ");
    for 1..title_width  print("-");
    print("\n");
    print_result_line(total, title_width);

    if failed_tests.count {
        print("\nFailed:\n");
        for failed_tests  print("  [%] %\n", it.suite, it.test);
    }

    if skipped_tests.count {
        print("\nSkipped:\n");
        for skipped_tests  print("  [%] % (%)\n", it.suite, it.test, it.reason);
    }

    success := total.checks_failed == 0;
    if success  print("\nAll tests passed.\n");
    else        print("\n% test(s) failed.\n", total.tests_failed + total.setup_failures);
    return success;
}

print_result_line :: (result: Suite_Result, title_width: int) {
    print("  %", result.title);
    for result.title.count..title_width  print(" ");

    column :: (value: int) -> string { return tprint("%", formatInt(value, minimum_digits = 4, padding = #char " ")); }

    print("% passed  % failed  % skipped", column(result.tests_passed), column(result.tests_failed), column(result.tests_skipped));
    print("   (checks: % passed, % failed)", result.checks_passed, result.checks_failed);
    if result.setup_failures  print(", % setup failure(s)", result.setup_failures);
    print("\n");
}
