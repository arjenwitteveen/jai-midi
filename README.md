# jai-midi
This module aims to provide basic MIDI I/O support for Jai programs in a simple to use, cross-platform manner. It allows you to receive MIDI messages from a MIDI source, and send MIDI messages to a MIDI destination. There is also basic support for reading MIDI files. The module does not aim to support all the possible functionality that MIDI (or the MIDI driver of each OS) provides. There is no support for MIDI 2.0.

To use this module you need at least Jai beta 0.1.057.

## Backends
The following backends are used:
- On Windows, the [Windows Multimedia API](https://learn.microsoft.com/en-us/windows/win32/api/mmeapi/) is used.
- On macOS, [CoreMIDI](https://developer.apple.com/documentation/coremidi?language=objc) is used.
- On Linux, [ALSA](https://www.alsa-project.org/alsa-doc/alsa-lib/seq.html) is used. A version of `libasound` is included, as well as the necessary ALSA headers needed to generate bindings with.

## Getting started

The module's API is documented in [`module.jai`](module.jai). The [examples](examples) directory contains a set of sample programs that show how to use the module. If you want to dive into the code, the file to start with would be [`midi.jai`](midi.jai).

## Build script
A simple build script (`first.jai`) is included with the module. This is mainly useful when working on the module itself. It can be used to run tests, build the examples, and generate bindings. To see its options, run `jai first.jai`.

## Disclaimer

I only have so much MIDI hardware that I can experiment with, so do not consider this module to be thoroughly battle-tested. The Windows version has been tested on Windows 10; the macOS implementation has been tested on an Intel Mac on Big Sur; the Linux implementation has been tested on a virtual machine running Ubuntu 22.04 LTS. For questions, suggestions, or bug reports, feel free to contact me on the Jai beta Discord.

## License
This module is provided under the [MIT license](LICENSE).

If you are using Linux, this module uses the ALSA library, which is released under the [LGPL license](https://www.gnu.org/licenses/lgpl-3.0.html).
