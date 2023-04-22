# jai-midi
This module aims to provide basic MIDI I/O support for Jai programs in a simple to use, cross-platform manner. It allows you to receive MIDI messages from a MIDI source, and send MIDI messages to a MIDI destination. There is also basic support for reading MIDI files. The module does not aim to support all the possible functionality that MIDI (or the MIDI driver of each OS) provides. There is no support for MIDI 2.0.

To use this module you need at least Jai beta 0.1.057.

*Disclaimer: I only have so much MIDI hardware that I can experiment with, so do not consider this module to be thoroughly battle-tested. The Windows version has been developed on Windows 10. The Linux implementation has been tested on a virtual machine running Ubuntu 22.04 LTS.*

## Backends
The following backends are used:
- On Windows, the [Windows Multimedia API](https://learn.microsoft.com/en-us/windows/win32/api/mmeapi/) is used.
- On macOS, [CoreMIDI](https://developer.apple.com/documentation/coremidi?language=objc) is used.
- On Linux, [ALSA](https://www.alsa-project.org/alsa-doc/alsa-lib/seq.html) is used. A version of `libasound` is included, as well as the necessary ALSA headers needed to generate bindings with.

Once the compiler is available for macOS, the goal is to support that as well.

## Examples

The following [examples](examples) are available:

- [`output.jai`](examples/output.jai): Demonstrates sending MIDI messages through an output.
- [`input.jai`](examples/input.jai): Demonstrates receiving MIDI messages through an input using a callback procedure.
- [`thru.jai`](examples/thru.jai): Sample showing the use of a queue to pass MIDI messages from the input callback to the main thread.
- [`dump_sysex.jai`](examples/dump_sysex.jai): A simple command-line program that takes (a part of) the name of a MIDI source, waits until a system-exclusive message is received, and dumps its contents to a file.
- [`read_midi_file.jai`](examples/read_midi_file.jai): Another simple command-line example which takes a path to a MIDI file and reads it; some properties of the file will be printed.

Furthermore, a bunch of API documentation is provided in [`module.jai`](module.jai).

## Build script
A simple build script (`first.jai`) is included with the module. This is mainly useful when working on the module itself. It can be used to run tests, build the examples, and generate bindings. To see its options, run `jai first.jai`.

## License
This module is provided under the [MIT license](LICENSE).

If you are using Linux, this module uses the ALSA library, which is released under the [LGPL license](https://www.gnu.org/licenses/lgpl-3.0.html).
