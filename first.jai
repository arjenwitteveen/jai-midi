//
// Simple build script used to run tests, build examples, and generate bindings.
//

EXAMPLES_PATH :: "examples";

print_help_message :: () {
    print("Usage: jai first.jai - <command>\n\n");
    print("Commands:\n");
    print("  test      Run test suite.\n");
    print("  examples  Build all examples.\n");
    print("  clean     Clean build artifacts for examples.\n");
    print("  generate  Generate bindings for the current OS.\n");
}

#run {
    args := get_build_options().compile_time_command_line;
    set_build_options_dc(.{do_output=false});
	options := get_build_options();

    if args.count == 0 {
        print_help_message();
        return;
    }

    if args[0] == {
        case "test";      do_tests();
        case "examples";  do_examples(build = true, clean = false);
        case "clean";     do_examples(build = false, clean = true);
        case "generate";  do_bindings();
        case;
        print("Unknown command '%'.\n\n", args[0]);
        print_help_message();
    }
}

do_tests :: () {
    w := compiler_create_workspace("Tests");
    options := get_build_options(w);
    copy_commonly_propagated_fields(get_build_options(), *options);
    options.output_type = .NO_OUTPUT;
    options.dead_code_elimination = .NONE;
    set_build_options(options, w);
    add_build_file("tests/tests.jai", w);
}

do_examples :: (build: bool, clean: bool) {
    examples := file_list(EXAMPLES_PATH);
    intermediate_path := tprint("%/.build", EXAMPLES_PATH);

    if clean && is_directory(intermediate_path)  delete_directory(intermediate_path);

    for file: examples {
        path_found, base_path, file_name := split_from_right(file, #char "/");
        if !path_found || file_name == "shared.jai" || !ends_with(file_name, ".jai")  continue;

        extension_found, file_name_without_extension, extension := split_from_right(file_name, ".");
        assert(extension_found);

        if clean {
            dsym_directory := tprint("%/%.dSYM", base_path, file_name_without_extension);
            if is_directory(dsym_directory)  delete_directory(dsym_directory);

            file_delete(tprint("%/%", base_path, file_name_without_extension));
            file_delete(tprint("%/%.exe", base_path, file_name_without_extension));
            file_delete(tprint("%/%.pdb", base_path, file_name_without_extension));
        }

        if build {
            w := compiler_create_workspace(file_name_without_extension);
            options := get_build_options(w);
            copy_commonly_propagated_fields(get_build_options(), *options);
            options.intermediate_path = intermediate_path;
            options.output_path = EXAMPLES_PATH;
            options.output_type = .EXECUTABLE;
            options.output_executable_name = file_name_without_extension;
            set_build_options(options, w);

            compiler_begin_intercept(w);

            add_build_file(file, w);

            success := true;

            while true {
                message := compiler_wait_for_message();
                if !message || message.workspace != w   continue;
                if message.kind == {
                    case .ERROR;     success = false; break;
                    case .COMPLETE;  break;
                }
            }

            compiler_end_intercept(w);

            if !success {
                compiler_set_workspace_status(.FAILED);
                break;
            }
        }
    }
}

do_bindings :: () {
    print("Generating bindings...\n");
    if !generate_bindings()  compiler_set_workspace_status(.FAILED);
}

#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "String";

#load "generate.jai";
