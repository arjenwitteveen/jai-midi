//
// This file was auto-generated using the following command:
//
// jai first.jai - generate
//



MAXPNAMELEN :: 32;
MAXERRORLENGTH :: 256;

TIME_MS :: 0x0001;
TIME_SAMPLES :: 0x0002;
TIME_BYTES :: 0x0004;
TIME_SMPTE :: 0x0008;
TIME_MIDI :: 0x0010;
TIME_TICKS :: 0x0020;

MM_MCINOTIFY :: 0x3B9;

MM_MIM_OPEN :: 0x3C1;
MM_MIM_CLOSE :: 0x3C2;
MM_MIM_DATA :: 0x3C3;
MM_MIM_LONGDATA :: 0x3C4;
MM_MIM_ERROR :: 0x3C5;
MM_MIM_LONGERROR :: 0x3C6;

MM_MOM_OPEN :: 0x3C7;
MM_MOM_CLOSE :: 0x3C8;
MM_MOM_DONE :: 0x3C9;

MM_DRVM_OPEN :: 0x3D0;
MM_DRVM_CLOSE :: 0x3D1;
MM_DRVM_DATA :: 0x3D2;
MM_DRVM_ERROR :: 0x3D3;

MM_STREAM_OPEN :: 0x3D4;
MM_STREAM_CLOSE :: 0x3D5;
MM_STREAM_DONE :: 0x3D6;
MM_STREAM_ERROR :: 0x3D7;

MM_MOM_POSITIONCB :: 0x3CA;

MM_MCISIGNAL :: 0x3CB;

MM_MIM_MOREDATA :: 0x3CC;

MM_MIXM_LINE_CHANGE :: 0x3D0;
MM_MIXM_CONTROL_CHANGE :: 0x3D1;

MMSYSERR :: enum {
    BASE         :: 0;

    NOERROR      :: 0;
    ERROR        :: BASE + 1;
    BADDEVICEID  :: BASE + 2;
    NOTENABLED   :: BASE + 3;
    ALLOCATED    :: BASE + 4;
    INVALHANDLE  :: BASE + 5;
    NODRIVER     :: BASE + 6;
    NOMEM        :: BASE + 7;
    NOTSUPPORTED :: BASE + 8;
    BADERRNUM    :: BASE + 9;
    INVALFLAG    :: BASE + 10;
    INVALPARAM   :: BASE + 11;
    HANDLEBUSY   :: BASE + 12;

    INVALIDALIAS :: BASE + 13;
    BADDB        :: BASE + 14;
    KEYNOTFOUND  :: BASE + 15;
    READERROR    :: BASE + 16;
    WRITEERROR   :: BASE + 17;
    DELETEERROR  :: BASE + 18;
    VALNOTFOUND  :: BASE + 19;
    NODRIVERCB   :: BASE + 20;
    MOREDATA     :: BASE + 21;
    LASTERROR    :: BASE + 21;

    MMSYSERR_BASE         :: BASE;

    MMSYSERR_NOERROR      :: NOERROR;
    MMSYSERR_ERROR        :: ERROR;
    MMSYSERR_BADDEVICEID  :: BADDEVICEID;
    MMSYSERR_NOTENABLED   :: NOTENABLED;
    MMSYSERR_ALLOCATED    :: ALLOCATED;
    MMSYSERR_INVALHANDLE  :: INVALHANDLE;
    MMSYSERR_NODRIVER     :: NODRIVER;
    MMSYSERR_NOMEM        :: NOMEM;
    MMSYSERR_NOTSUPPORTED :: NOTSUPPORTED;
    MMSYSERR_BADERRNUM    :: BADERRNUM;
    MMSYSERR_INVALFLAG    :: INVALFLAG;
    MMSYSERR_INVALPARAM   :: INVALPARAM;
    MMSYSERR_HANDLEBUSY   :: HANDLEBUSY;

    MMSYSERR_INVALIDALIAS :: INVALIDALIAS;
    MMSYSERR_BADDB        :: BADDB;
    MMSYSERR_KEYNOTFOUND  :: KEYNOTFOUND;
    MMSYSERR_READERROR    :: READERROR;
    MMSYSERR_WRITEERROR   :: WRITEERROR;
    MMSYSERR_DELETEERROR  :: DELETEERROR;
    MMSYSERR_VALNOTFOUND  :: VALNOTFOUND;
    MMSYSERR_NODRIVERCB   :: NODRIVERCB;
    MMSYSERR_MOREDATA     :: MOREDATA;
    MMSYSERR_LASTERROR    :: LASTERROR;
}

MIDIERR :: enum {
    BASE          :: 64;

    UNPREPARED    :: BASE + 0;
    STILLPLAYING  :: BASE + 1;
    NOMAP         :: BASE + 2;
    NOTREADY      :: BASE + 3;
    NODEVICE      :: BASE + 4;
    INVALIDSETUP  :: BASE + 5;
    BADOPENMODE   :: BASE + 6;
    DONT_CONTINUE :: BASE + 7;
    LASTERROR     :: BASE + 7;

    MIDIERR_BASE          :: BASE;

    MIDIERR_UNPREPARED    :: UNPREPARED;
    MIDIERR_STILLPLAYING  :: STILLPLAYING;
    MIDIERR_NOMAP         :: NOMAP;
    MIDIERR_NOTREADY      :: NOTREADY;
    MIDIERR_NODEVICE      :: NODEVICE;
    MIDIERR_INVALIDSETUP  :: INVALIDSETUP;
    MIDIERR_BADOPENMODE   :: BADOPENMODE;
    MIDIERR_DONT_CONTINUE :: DONT_CONTINUE;
    MIDIERR_LASTERROR     :: LASTERROR;
}
TIMERR_BASE :: 96;

MCIERR_BASE :: 256;

MCI_STRING_OFFSET :: 512;
MCI_VD_OFFSET :: 1024;
MCI_CD_OFFSET :: 1088;

MCI_SEQ_OFFSET :: 1216;

CALLBACK_TYPEMASK :: 0x00070000;
CALLBACK_NULL :: 0x00000000;
CALLBACK_WINDOW :: 0x00010000;
CALLBACK_TASK :: 0x00020000;
CALLBACK_FUNCTION :: 0x00030000;

CALLBACK_THREAD :: CALLBACK_TASK;
CALLBACK_EVENT :: 0x00050000;

WHDR_DONE :: 0x00000001;
WHDR_PREPARED :: 0x00000002;
WHDR_BEGINLOOP :: 0x00000004;
WHDR_ENDLOOP :: 0x00000008;
WHDR_INQUEUE :: 0x00000010;

MIDIPATCHSIZE :: 128;

MIM :: enum u32 {
    OPEN      :: MM_MIM_OPEN;
    CLOSE     :: MM_MIM_CLOSE;
    DATA      :: MM_MIM_DATA;
    LONGDATA  :: MM_MIM_LONGDATA;
    ERROR     :: MM_MIM_ERROR;
    LONGERROR :: MM_MIM_LONGERROR;

    MOREDATA  :: MM_MIM_MOREDATA;

    MIM_OPEN      :: OPEN;
    MIM_CLOSE     :: CLOSE;
    MIM_DATA      :: DATA;
    MIM_LONGDATA  :: LONGDATA;
    MIM_ERROR     :: ERROR;
    MIM_LONGERROR :: LONGERROR;

    MIM_MOREDATA  :: MOREDATA;
}

MOM_OPEN :: MM_MOM_OPEN;
MOM_CLOSE :: MM_MOM_CLOSE;
MOM_DONE :: MM_MOM_DONE;

MOM_POSITIONCB :: MM_MOM_POSITIONCB;

MIDIMAPPER :: cast,trunc(u32)-1;
MIDI_MAPPER :: cast,trunc(u32)-1;

MIDI_IO_STATUS :: 0x00000020;

MIDI_CACHE_ALL :: 1;
MIDI_CACHE_BESTFIT :: 2;
MIDI_CACHE_QUERY :: 3;
MIDI_UNCACHE :: 4;

MOD :: enum u16 {
    MIDIPORT  :: 1;
    SYNTH     :: 2;
    SQSYNTH   :: 3;
    FMSYNTH   :: 4;
    MAPPER    :: 5;
    WAVETABLE :: 6;
    SWSYNTH   :: 7;

    MOD_MIDIPORT  :: MIDIPORT;
    MOD_SYNTH     :: SYNTH;
    MOD_SQSYNTH   :: SQSYNTH;
    MOD_FMSYNTH   :: FMSYNTH;
    MOD_MAPPER    :: MAPPER;
    MOD_WAVETABLE :: WAVETABLE;
    MOD_SWSYNTH   :: SWSYNTH;
}

MIDICAPS :: enum_flags u32 {
    VOLUME   :: 0x0001;
    LRVOLUME :: 0x0002;
    CACHE    :: 0x0004;

    STREAM   :: 0x0008;

    MIDICAPS_VOLUME   :: VOLUME;
    MIDICAPS_LRVOLUME :: LRVOLUME;
    MIDICAPS_CACHE    :: CACHE;

    MIDICAPS_STREAM   :: STREAM;
}

MHDR :: enum_flags u32 {
    DONE     :: 0x00000001;
    PREPARED :: 0x00000002;
    INQUEUE  :: 0x00000004;
    ISSTRM   :: 0x00000008;

    MHDR_DONE     :: DONE;
    MHDR_PREPARED :: PREPARED;
    MHDR_INQUEUE  :: INQUEUE;
    MHDR_ISSTRM   :: ISSTRM;
}

MEVT_F_SHORT :: 0x00000000;
MEVT_F_LONG :: 0x80000000;
MEVT_F_CALLBACK :: 0x40000000;

MEVT_SHORTMSG :: cast(u8)0x00;
MEVT_TEMPO :: cast(u8)0x01;
MEVT_NOP :: cast(u8)0x02;

MEVT_LONGMSG :: cast(u8)0x80;
MEVT_COMMENT :: cast(u8)0x82;
MEVT_VERSION :: cast(u8)0x84;

MIDISTRM_ERROR :: -2;

MIDIPROP_SET :: 0x80000000;
MIDIPROP_GET :: 0x40000000;

MIDIPROP_TIMEDIV :: 0x00000001;
MIDIPROP_TEMPO :: 0x00000002;

midiOutGetDevCaps :: midiOutGetDevCapsA;

midiOutGetErrorText :: midiOutGetErrorTextA;

midiInGetDevCaps :: midiInGetDevCapsA;

midiInGetErrorText :: midiInGetErrorTextA;

LPBYTE :: *u8;

LPWORD :: *u16;

_GUID :: struct {
    Data1: u32;
    Data2: u16;
    Data3: u16;
    Data4: [8] u8;
}

GUID :: _GUID;

HWND__ :: struct {
    unused: s32;
}
HWND :: *HWND__;

LPUINT :: *u32;

MMVERSION :: u32;

MMRESULT :: MMSYSERR;

mmtime_tag :: struct {
    wType: u32;
    u:     union {
        ms:     u32;
        sample: u32;
        cb:     u32;
        ticks:  u32;

        smpte:  struct {
            hour:  u8;
            min:   u8;
            sec:   u8;
            frame: u8;
            fps:   u8;
            dummy: u8;

            pad:   [2] u8;
        };

        midi:   struct {
            songptrpos: u32;
        };
    };
}

MMTIME :: mmtime_tag;
PMMTIME :: *mmtime_tag;
NPMMTIME :: *mmtime_tag;
LPMMTIME :: *mmtime_tag;

HDRVR__ :: struct {
    unused: s32;
}
HDRVR :: *HDRVR__;

DRVCALLBACK :: #type (hdrvr: HDRVR, uMsg: u32, dwUser: u64, dw1: u64, dw2: u64) -> void #c_call;

LPDRVCALLBACK :: #type () -> void #c_call;

PDRVCALLBACK :: #type () -> void #c_call;

HMIDI__ :: struct {
    unused: s32;
}
HMIDI :: *HMIDI__;
HMIDIIN__ :: struct {
    unused: s32;
}
HMIDIIN :: *HMIDIIN__;
HMIDIOUT__ :: struct {
    unused: s32;
}
HMIDIOUT :: *HMIDIOUT__;
HMIDISTRM__ :: struct {
    unused: s32;
}
HMIDISTRM :: *HMIDISTRM__;
LPHMIDI :: *HMIDI;
LPHMIDIIN :: *HMIDIIN;
LPHMIDIOUT :: *HMIDIOUT;
LPHMIDISTRM :: *HMIDISTRM;
MIDICALLBACK :: #type () -> void #c_call;
LPMIDICALLBACK :: #type () -> void #c_call;

PATCHARRAY :: [128] u16;
LPPATCHARRAY :: *u16;
KEYARRAY :: [128] u16;
LPKEYARRAY :: *u16;

tagMIDIOUTCAPSA :: struct {
    wMid:           u16;
    wPid:           u16;
    vDriverVersion: MMVERSION;
    szPname:        [32] u8;
    wTechnology:    u16;
    wVoices:        u16;
    wNotes:         u16;
    wChannelMask:   u16;
    dwSupport:      u32;
}

MIDIOUTCAPSA :: tagMIDIOUTCAPSA;
PMIDIOUTCAPSA :: *tagMIDIOUTCAPSA;
NPMIDIOUTCAPSA :: *tagMIDIOUTCAPSA;
LPMIDIOUTCAPSA :: *tagMIDIOUTCAPSA;
tagMIDIOUTCAPSW :: struct {
    wMid:           u16;
    wPid:           u16;
    vDriverVersion: MMVERSION;
    szPname:        [32] s16;
    wTechnology:    u16;
    wVoices:        u16;
    wNotes:         u16;
    wChannelMask:   u16;
    dwSupport:      u32;
}

MIDIOUTCAPSW :: tagMIDIOUTCAPSW;
PMIDIOUTCAPSW :: *tagMIDIOUTCAPSW;
NPMIDIOUTCAPSW :: *tagMIDIOUTCAPSW;
LPMIDIOUTCAPSW :: *tagMIDIOUTCAPSW;

MIDIOUTCAPS :: MIDIOUTCAPSA;
PMIDIOUTCAPS :: PMIDIOUTCAPSA;
NPMIDIOUTCAPS :: NPMIDIOUTCAPSA;
LPMIDIOUTCAPS :: LPMIDIOUTCAPSA;

tagMIDIOUTCAPS2A :: struct {
    wMid:             u16;
    wPid:             u16;
    vDriverVersion:   MMVERSION;
    szPname:          [32] u8;
    wTechnology:      u16;
    wVoices:          u16;
    wNotes:           u16;
    wChannelMask:     u16;
    dwSupport:        u32;
    ManufacturerGuid: GUID;
    ProductGuid:      GUID;
    NameGuid:         GUID;
}

MIDIOUTCAPS2A :: tagMIDIOUTCAPS2A;
PMIDIOUTCAPS2A :: *tagMIDIOUTCAPS2A;
NPMIDIOUTCAPS2A :: *tagMIDIOUTCAPS2A;
LPMIDIOUTCAPS2A :: *tagMIDIOUTCAPS2A;
tagMIDIOUTCAPS2W :: struct {
    wMid:             u16;
    wPid:             u16;
    vDriverVersion:   MMVERSION;
    szPname:          [32] s16;
    wTechnology:      u16;
    wVoices:          u16;
    wNotes:           u16;
    wChannelMask:     u16;
    dwSupport:        u32;
    ManufacturerGuid: GUID;
    ProductGuid:      GUID;
    NameGuid:         GUID;
}

MIDIOUTCAPS2W :: tagMIDIOUTCAPS2W;
PMIDIOUTCAPS2W :: *tagMIDIOUTCAPS2W;
NPMIDIOUTCAPS2W :: *tagMIDIOUTCAPS2W;
LPMIDIOUTCAPS2W :: *tagMIDIOUTCAPS2W;

MIDIOUTCAPS2 :: MIDIOUTCAPS2A;
PMIDIOUTCAPS2 :: PMIDIOUTCAPS2A;
NPMIDIOUTCAPS2 :: NPMIDIOUTCAPS2A;
LPMIDIOUTCAPS2 :: LPMIDIOUTCAPS2A;

tagMIDIINCAPSA :: struct {
    wMid:           u16;
    wPid:           u16;
    vDriverVersion: MMVERSION;
    szPname:        [32] u8;

    dwSupport:      u32;
}

MIDIINCAPSA :: tagMIDIINCAPSA;
PMIDIINCAPSA :: *tagMIDIINCAPSA;
NPMIDIINCAPSA :: *tagMIDIINCAPSA;
LPMIDIINCAPSA :: *tagMIDIINCAPSA;
tagMIDIINCAPSW :: struct {
    wMid:           u16;
    wPid:           u16;
    vDriverVersion: MMVERSION;
    szPname:        [32] s16;

    dwSupport:      u32;
}

MIDIINCAPSW :: tagMIDIINCAPSW;
PMIDIINCAPSW :: *tagMIDIINCAPSW;
NPMIDIINCAPSW :: *tagMIDIINCAPSW;
LPMIDIINCAPSW :: *tagMIDIINCAPSW;

MIDIINCAPS :: MIDIINCAPSA;
PMIDIINCAPS :: PMIDIINCAPSA;
NPMIDIINCAPS :: NPMIDIINCAPSA;
LPMIDIINCAPS :: LPMIDIINCAPSA;

tagMIDIINCAPS2A :: struct {
    wMid:             u16;
    wPid:             u16;
    vDriverVersion:   MMVERSION;
    szPname:          [32] u8;

    dwSupport:        u32;

    ManufacturerGuid: GUID;
    ProductGuid:      GUID;
    NameGuid:         GUID;
}

MIDIINCAPS2A :: tagMIDIINCAPS2A;
PMIDIINCAPS2A :: *tagMIDIINCAPS2A;
NPMIDIINCAPS2A :: *tagMIDIINCAPS2A;
LPMIDIINCAPS2A :: *tagMIDIINCAPS2A;
tagMIDIINCAPS2W :: struct {
    wMid:             u16;
    wPid:             u16;
    vDriverVersion:   MMVERSION;
    szPname:          [32] s16;

    dwSupport:        u32;

    ManufacturerGuid: GUID;
    ProductGuid:      GUID;
    NameGuid:         GUID;
}

MIDIINCAPS2W :: tagMIDIINCAPS2W;
PMIDIINCAPS2W :: *tagMIDIINCAPS2W;
NPMIDIINCAPS2W :: *tagMIDIINCAPS2W;
LPMIDIINCAPS2W :: *tagMIDIINCAPS2W;

MIDIINCAPS2 :: MIDIINCAPS2A;
PMIDIINCAPS2 :: PMIDIINCAPS2A;
NPMIDIINCAPS2 :: NPMIDIINCAPS2A;
LPMIDIINCAPS2 :: LPMIDIINCAPS2A;

midihdr_tag :: struct {
    lpData:          *u8;
    dwBufferLength:  u32;
    dwBytesRecorded: u32;
    dwUser:          u64;
    dwFlags:         MHDR;
    lpNext:          *midihdr_tag;
    reserved:        u64;

    dwOffset:        u32;
    dwReserved:      [8] u64;
}

MIDIHDR :: midihdr_tag;
PMIDIHDR :: *midihdr_tag;
NPMIDIHDR :: *midihdr_tag;
LPMIDIHDR :: *midihdr_tag;

midievent_tag :: struct {
    dwDeltaTime: u32;
    dwStreamID:  u32;
    dwEvent:     u32;
    dwParms:     [1] u32;
}

MIDIEVENT :: midievent_tag;

midistrmbuffver_tag :: struct {
    dwVersion:    u32;
    dwMid:        u32;
    dwOEMVersion: u32;
}

MIDISTRMBUFFVER :: midistrmbuffver_tag;

midiproptimediv_tag :: struct {
    cbStruct:  u32;
    dwTimeDiv: u32;
}

MIDIPROPTIMEDIV :: midiproptimediv_tag;
LPMIDIPROPTIMEDIV :: *midiproptimediv_tag;

midiproptempo_tag :: struct {
    cbStruct: u32;
    dwTempo:  u32;
}

MIDIPROPTEMPO :: midiproptempo_tag;
LPMIDIPROPTEMPO :: *midiproptempo_tag;

midiOutGetNumDevs :: () -> u32 #foreign winmm;

midiStreamOpen :: (phms: LPHMIDISTRM, puDeviceID: LPUINT, cMidi: u32, dwCallback: u64, dwInstance: u64, fdwOpen: u32) -> MMRESULT #foreign winmm;

midiStreamClose :: (hms: HMIDISTRM) -> MMRESULT #foreign winmm;

midiStreamProperty :: (hms: HMIDISTRM, lppropdata: LPBYTE, dwProperty: u32) -> MMRESULT #foreign winmm;

midiStreamPosition :: (hms: HMIDISTRM, lpmmt: LPMMTIME, cbmmt: u32) -> MMRESULT #foreign winmm;

midiStreamOut :: (hms: HMIDISTRM, pmh: LPMIDIHDR, cbmh: u32) -> MMRESULT #foreign winmm;

midiStreamPause :: (hms: HMIDISTRM) -> MMRESULT #foreign winmm;

midiStreamRestart :: (hms: HMIDISTRM) -> MMRESULT #foreign winmm;

midiStreamStop :: (hms: HMIDISTRM) -> MMRESULT #foreign winmm;

midiConnect :: (hmi: HMIDI, hmo: HMIDIOUT, pReserved: *void) -> MMRESULT #foreign winmm;

midiDisconnect :: (hmi: HMIDI, hmo: HMIDIOUT, pReserved: *void) -> MMRESULT #foreign winmm;

midiOutGetDevCapsA :: (uDeviceID: u64, pmoc: LPMIDIOUTCAPSA, cbmoc: u32) -> MMRESULT #foreign winmm;

midiOutGetDevCapsW :: (uDeviceID: u64, pmoc: LPMIDIOUTCAPSW, cbmoc: u32) -> MMRESULT #foreign winmm;

midiOutGetVolume :: (hmo: HMIDIOUT, pdwVolume: *u32) -> MMRESULT #foreign winmm;

midiOutSetVolume :: (hmo: HMIDIOUT, dwVolume: u32) -> MMRESULT #foreign winmm;

midiOutGetErrorTextA :: (mmrError: MMRESULT, pszText: *u8, cchText: u32) -> MMRESULT #foreign winmm;

midiOutGetErrorTextW :: (mmrError: MMRESULT, pszText: *s16, cchText: u32) -> MMRESULT #foreign winmm;

midiOutOpen :: (phmo: LPHMIDIOUT, uDeviceID: u32, dwCallback: u64, dwInstance: u64, fdwOpen: u32) -> MMRESULT #foreign winmm;

midiOutClose :: (hmo: HMIDIOUT) -> MMRESULT #foreign winmm;

midiOutPrepareHeader :: (hmo: HMIDIOUT, pmh: LPMIDIHDR, cbmh: u32) -> MMRESULT #foreign winmm;

midiOutUnprepareHeader :: (hmo: HMIDIOUT, pmh: LPMIDIHDR, cbmh: u32) -> MMRESULT #foreign winmm;

midiOutShortMsg :: (hmo: HMIDIOUT, dwMsg: u32) -> MMRESULT #foreign winmm;

midiOutLongMsg :: (hmo: HMIDIOUT, pmh: LPMIDIHDR, cbmh: u32) -> MMRESULT #foreign winmm;

midiOutReset :: (hmo: HMIDIOUT) -> MMRESULT #foreign winmm;

midiOutCachePatches :: (hmo: HMIDIOUT, uBank: u32, pwpa: LPWORD, fuCache: u32) -> MMRESULT #foreign winmm;

midiOutCacheDrumPatches :: (hmo: HMIDIOUT, uPatch: u32, pwkya: LPWORD, fuCache: u32) -> MMRESULT #foreign winmm;

midiOutGetID :: (hmo: HMIDIOUT, puDeviceID: LPUINT) -> MMRESULT #foreign winmm;

midiOutMessage :: (hmo: HMIDIOUT, uMsg: u32, dw1: u64, dw2: u64) -> MMRESULT #foreign winmm;

midiInGetNumDevs :: () -> u32 #foreign winmm;

midiInGetDevCapsA :: (uDeviceID: u64, pmic: LPMIDIINCAPSA, cbmic: u32) -> MMRESULT #foreign winmm;

midiInGetDevCapsW :: (uDeviceID: u64, pmic: LPMIDIINCAPSW, cbmic: u32) -> MMRESULT #foreign winmm;

midiInGetErrorTextA :: (mmrError: MMRESULT, pszText: *u8, cchText: u32) -> MMRESULT #foreign winmm;

midiInGetErrorTextW :: (mmrError: MMRESULT, pszText: *s16, cchText: u32) -> MMRESULT #foreign winmm;

midiInOpen :: (phmi: LPHMIDIIN, uDeviceID: u32, dwCallback: u64, dwInstance: u64, fdwOpen: u32) -> MMRESULT #foreign winmm;

midiInClose :: (hmi: HMIDIIN) -> MMRESULT #foreign winmm;

midiInPrepareHeader :: (hmi: HMIDIIN, pmh: LPMIDIHDR, cbmh: u32) -> MMRESULT #foreign winmm;

midiInUnprepareHeader :: (hmi: HMIDIIN, pmh: LPMIDIHDR, cbmh: u32) -> MMRESULT #foreign winmm;

midiInAddBuffer :: (hmi: HMIDIIN, pmh: LPMIDIHDR, cbmh: u32) -> MMRESULT #foreign winmm;

midiInStart :: (hmi: HMIDIIN) -> MMRESULT #foreign winmm;

midiInStop :: (hmi: HMIDIIN) -> MMRESULT #foreign winmm;

midiInReset :: (hmi: HMIDIIN) -> MMRESULT #foreign winmm;

midiInGetID :: (hmi: HMIDIIN, puDeviceID: LPUINT) -> MMRESULT #foreign winmm;

midiInMessage :: (hmi: HMIDIIN, uMsg: u32, dw1: u64, dw2: u64) -> MMRESULT #foreign winmm;

#scope_file

winmm :: #system_library "winmm";
