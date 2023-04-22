//
// To generate bindings: jai first.jai - generate
//

generate_bindings :: () -> bool {
    output_filename: string;

    options: Generate_Bindings_Options;
    {
        using options;

        array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);

        generate_compile_time_struct_checks = true;

        #if OS == .WINDOWS {
            output_filename = "bindings_windows.jai";
            strip_flags = 0;

            array_add(*libnames, "winmm");
            array_add(*source_files, "windows.h", "mmeapi.h");
            array_add(*path_fragments_to_treat_as_non_system_paths, "mmeapi.h", "mmsyscom.h");
            array_add(*system_types_to_include, "HWND", "GUID", "LPUINT", "LPWORD", "LPBYTE", "HWND__", "_GUID");
            array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN");
            array_add(*generate_enums_from_macros_with_prefixes, "MMSYSERR_", "MIDIERR_", "MOD_", "MIM_", "MHDR_", "MIDICAPS_");

            visitor = winmm_visitor;
        } else #if OS == .LINUX {
            // The Linux version is based on libasound/ALSA.
            output_filename = "bindings_linux.jai";
            array_add(*include_paths, "linux/alsa");
            array_add(*libpaths, "linux");
            array_add(*libnames, "libasound");
            array_add(*source_files, "linux/alsa/asoundlib.h");
            footer = "\n#load \"linux/seqmid.jai\";\n\n#import \"POSIX\";\n";
            array_add(*extra_clang_arguments, "-x", "c++");
            array_add(*generate_enums_from_macros_with_prefixes, "SND_SEQ_PORT_CAP_", "SND_SEQ_PORT_TYPE_", "SND_SEQ_REMOVE_", "MIDI_CMD_", "MIDI_CTL_");
            visitor = alsa_visitor;
        } else #if OS == .MACOS {
            MACOS_SDK_PATH :: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk";
            LIBC_PATH :: #run sprint("%/usr/include", MACOS_SDK_PATH);
            FRAMEWORKS_PATH :: #run sprint("%/System/Library/Frameworks", MACOS_SDK_PATH);
            COREMIDI_PATH :: #run sprint("%/CoreMIDI.framework/Headers", FRAMEWORKS_PATH);

            output_filename = "bindings_macos.jai";
            array_add(*libnames, "libc");
            array_add(*libnames, "CoreMIDI");
            array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);
            array_add(*system_include_paths, LIBC_PATH);
            array_add(*source_files,  tprint("%/CoreMIDI.h", COREMIDI_PATH));
            array_add(*source_files,  tprint("%/mach/mach_time.h", LIBC_PATH));
            // array_add(*source_files,  tprint("%/MacTypes.h", LIBC_PATH));
            array_add(*path_fragments_to_treat_as_non_system_paths,
                      "mach/mach_time.h",
                      "MIDICapabilityInquiry.h",
                      "MIDIMessages.h",
                      "MIDINetworkSession.h",
                      "MIDIServices.h",
                      "MIDISetup.h",
                      "MIDIThruConnection.h");

            footer = MACOS_FOOTER;

            array_add(*extra_clang_arguments, "-isysroot", MACOS_SDK_PATH, "-x", "c", tprint("-F%", FRAMEWORKS_PATH));

            visitor = macos_visitor;
        }
    }

    return generate_bindings(options, output_filename);
}

// Ignore symbols related to waveform audio rather than MIDI.
WINDOWS_SYMBOLS_TO_IGNORE :: string.["wave", "WAVE", "mixer", "MIXER", "aux", "AUX", "WOM", "WIM", "JOY"];

winmm_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    for WINDOWS_SYMBOLS_TO_IGNORE {
        if contains(decl.name, it)  decl.decl_flags |= .OMIT_FROM_OUTPUT;
    }

    // Change the type of MMRESULT from u32 to the generated MMSYSERR enum.
    if decl.name == "MMRESULT" {
        mmsyserr_type := New(CType);
        mmsyserr_type.hardcoded_jai_string = "MMSYSERR";
        decl.type = mmsyserr_type;
    }

    if decl.name == "dwFlags" && parent_decl.name == "midihdr_tag" {
        type := New(CType);
        type.hardcoded_jai_string = "MHDR";
        type.size = size_of(u32);
        decl.type = type;
    }

    if decl.kind == .ENUM {
        if decl.name == "MHDR" || decl.name == "MIDICAPS" {
            en := cast(*Enum) decl;
            en.flags |= .IS_ENUM_FLAGS;
            en.type = context.generator.type_def_u32;
        }

        if decl.name == "MOD" {
            en := cast(*Enum) decl;
            en.type = context.generator.type_def_u16;
        }
    }

    if decl.name == "MIM" {
        decl.type = context.generator.type_def_u32;
    }

    return .RECURSE;
}

// Ignore symbols related to waveform audio rather than MIDI.
ALSA_SYMBOLS_TO_IGNORE :: string.["pcm", "PCM", "mixer", "hctl", "timer", "hwdep", "snd_config", "snd_ctl", "SND_CTL",
                                  "snd_sctl", "snd_async", "snd_input", "snd_output", "lconf", "IEC958", "CEA861"];

alsa_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    for ALSA_SYMBOLS_TO_IGNORE {
        if contains(decl.name, it)  decl.decl_flags |= .OMIT_FROM_OUTPUT;
    }

    // Fix a [0] 32 being intialized with = 0.
    if decl.name == "pos" && parent_decl.name == "snd_pcm_chmap" {
        decl.expression = xx 0;
    }

    if decl.kind == .ENUM {
        en := cast(*Enum) decl;
        en.flags &= ~.MIMIC_SPACING;

        if decl.name == "SND_SEQ_PORT_CAP" || decl.name == "SND_SEQ_PORT_TYPE" || decl.name == "SND_SEQ_REMOVE" {
            en.flags |= .IS_ENUM_FLAGS;
            en.type = context.generator.type_def_u32;
        }
    }

    // Fix a va_args not being replace.
    if decl.name == "snd_local_error_handler_t" {
        arguments := decl.type.pointer_to.type_of_function.arguments;
        va_args_type := New(CType);
        va_args_type.hardcoded_jai_string = "..Any";
        arguments[arguments.count - 1].type = va_args_type;
    }

    if decl.name == "snd_seq_event_type" {
        u8_type := New(CType);
        u8_type.number_flags = ._8BIT;
        u8_type.size = 1;
        decl.type = u8_type;
    }

    if decl.name == "snd_seq_event_type_t" {
        type := New(CType);
        type.hardcoded_jai_string = "snd_seq_event_type";
        type.size = 1;
        decl.type = type;
    }

    return .RECURSE;
}


macos_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    // @TODO: The members with type MIDITimeStamp (u64) are 8 byte aligned, but in C they are 4 byte aligned...
    // if decl.name == "timeStamp" {

    // }

    return .RECURSE;
}

#scope_file

#import "Basic";
#import "String";
#import "Compiler";
// #import "Check";
#import "Bindings_Generator";
#import "File";


MACOS_FOOTER :: #string END

#scope_export

UTF32Char :: u32;
ConstStringPtr :: *u8;
StringPtr :: *u8;
ConstStr255Param :: *u8;
OSErr :: s16;
LogicalAddress :: *void;
ConstLogicalAddress :: *void;
PhysicalAddress :: *void;
BytePtr :: *u8;
ByteCount :: u64;
ByteOffset :: u64;
Duration :: s32;
OptionBits :: u32;
ItemCount :: u64;
PBVersion :: u32;
ScriptCode :: s16;
LangCode :: s16;
RegionCode :: s16;
ResType :: FourCharCode;
OSTypePtr :: *OSType;
ResTypePtr :: *ResType;
Boolean :: u8;
dispatch_queue_t :: *struct{};

// See Objective_C_Block_Basic in Objective-C. There are parts of the C API
// that use blocks so it may be valuable to include that full definition here.
Block :: *struct{};

wide :: struct {
    lo: u32;
    hi: s32;
}

UnsignedWide :: struct {
    lo: u32;
    hi: u32;
}

Fixed :: s32;
FixedPtr :: *Fixed;
Fract :: s32;
FractPtr :: *Fract;
UnsignedFixed :: u32;
UnsignedFixedPtr :: *UnsignedFixed;
ShortFixed :: s16;
ShortFixedPtr :: *ShortFixed;

Float32 :: float;
Float64 :: float64;

Byte :: u8;
SignedByte :: s8;
WidePtr :: *wide;
UnsignedWidePtr :: *UnsignedWide;

#import "macos";

END
