//
// This file was auto-generated using the following command:
//
// jai first.jai - generate
//



MIDI_CHANNELS :: 16;
MIDI_GM_DRUM_CHANNEL :: 10-1;

MIDI_CMD :: enum {
    NOTE_OFF            :: 0x80;
    NOTE_ON             :: 0x90;
    NOTE_PRESSURE       :: 0xa0;
    CONTROL             :: 0xb0;
    PGM_CHANGE          :: 0xc0;
    CHANNEL_PRESSURE    :: 0xd0;
    BENDER              :: 0xe0;
    COMMON_SYSEX        :: 0xf0;
    COMMON_MTC_QUARTER  :: 0xf1;
    COMMON_SONG_POS     :: 0xf2;
    COMMON_SONG_SELECT  :: 0xf3;
    COMMON_TUNE_REQUEST :: 0xf6;
    COMMON_SYSEX_END    :: 0xf7;
    COMMON_CLOCK        :: 0xf8;
    COMMON_START        :: 0xfa;
    COMMON_CONTINUE     :: 0xfb;
    COMMON_STOP         :: 0xfc;
    COMMON_SENSING      :: 0xfe;
    COMMON_RESET        :: 0xff;

    MIDI_CMD_NOTE_OFF            :: NOTE_OFF;
    MIDI_CMD_NOTE_ON             :: NOTE_ON;
    MIDI_CMD_NOTE_PRESSURE       :: NOTE_PRESSURE;
    MIDI_CMD_CONTROL             :: CONTROL;
    MIDI_CMD_PGM_CHANGE          :: PGM_CHANGE;
    MIDI_CMD_CHANNEL_PRESSURE    :: CHANNEL_PRESSURE;
    MIDI_CMD_BENDER              :: BENDER;
    MIDI_CMD_COMMON_SYSEX        :: COMMON_SYSEX;
    MIDI_CMD_COMMON_MTC_QUARTER  :: COMMON_MTC_QUARTER;
    MIDI_CMD_COMMON_SONG_POS     :: COMMON_SONG_POS;
    MIDI_CMD_COMMON_SONG_SELECT  :: COMMON_SONG_SELECT;
    MIDI_CMD_COMMON_TUNE_REQUEST :: COMMON_TUNE_REQUEST;
    MIDI_CMD_COMMON_SYSEX_END    :: COMMON_SYSEX_END;
    MIDI_CMD_COMMON_CLOCK        :: COMMON_CLOCK;
    MIDI_CMD_COMMON_START        :: COMMON_START;
    MIDI_CMD_COMMON_CONTINUE     :: COMMON_CONTINUE;
    MIDI_CMD_COMMON_STOP         :: COMMON_STOP;
    MIDI_CMD_COMMON_SENSING      :: COMMON_SENSING;
    MIDI_CMD_COMMON_RESET        :: COMMON_RESET;
}

MIDI_CTL :: enum {
    MSB_BANK             :: 0x00;
    MSB_MODWHEEL         :: 0x01;
    MSB_BREATH           :: 0x02;
    MSB_FOOT             :: 0x04;
    MSB_PORTAMENTO_TIME  :: 0x05;
    MSB_DATA_ENTRY       :: 0x06;
    MSB_MAIN_VOLUME      :: 0x07;
    MSB_BALANCE          :: 0x08;
    MSB_PAN              :: 0x0a;
    MSB_EXPRESSION       :: 0x0b;
    MSB_EFFECT1          :: 0x0c;
    MSB_EFFECT2          :: 0x0d;
    MSB_GENERAL_PURPOSE1 :: 0x10;
    MSB_GENERAL_PURPOSE2 :: 0x11;
    MSB_GENERAL_PURPOSE3 :: 0x12;
    MSB_GENERAL_PURPOSE4 :: 0x13;
    LSB_BANK             :: 0x20;
    LSB_MODWHEEL         :: 0x21;
    LSB_BREATH           :: 0x22;
    LSB_FOOT             :: 0x24;
    LSB_PORTAMENTO_TIME  :: 0x25;
    LSB_DATA_ENTRY       :: 0x26;
    LSB_MAIN_VOLUME      :: 0x27;
    LSB_BALANCE          :: 0x28;
    LSB_PAN              :: 0x2a;
    LSB_EXPRESSION       :: 0x2b;
    LSB_EFFECT1          :: 0x2c;
    LSB_EFFECT2          :: 0x2d;
    LSB_GENERAL_PURPOSE1 :: 0x30;
    LSB_GENERAL_PURPOSE2 :: 0x31;
    LSB_GENERAL_PURPOSE3 :: 0x32;
    LSB_GENERAL_PURPOSE4 :: 0x33;
    SUSTAIN              :: 0x40;
    PORTAMENTO           :: 0x41;
    SOSTENUTO            :: 0x42;
    SUSTENUTO            :: 0x42;
    SOFT_PEDAL           :: 0x43;
    LEGATO_FOOTSWITCH    :: 0x44;
    HOLD2                :: 0x45;
    SC1_SOUND_VARIATION  :: 0x46;
    SC2_TIMBRE           :: 0x47;
    SC3_RELEASE_TIME     :: 0x48;
    SC4_ATTACK_TIME      :: 0x49;
    SC5_BRIGHTNESS       :: 0x4a;
    SC6                  :: 0x4b;
    SC7                  :: 0x4c;
    SC8                  :: 0x4d;
    SC9                  :: 0x4e;
    SC10                 :: 0x4f;
    GENERAL_PURPOSE5     :: 0x50;
    GENERAL_PURPOSE6     :: 0x51;
    GENERAL_PURPOSE7     :: 0x52;
    GENERAL_PURPOSE8     :: 0x53;
    PORTAMENTO_CONTROL   :: 0x54;
    E1_REVERB_DEPTH      :: 0x5b;
    E2_TREMOLO_DEPTH     :: 0x5c;
    E3_CHORUS_DEPTH      :: 0x5d;
    E4_DETUNE_DEPTH      :: 0x5e;
    E5_PHASER_DEPTH      :: 0x5f;
    DATA_INCREMENT       :: 0x60;
    DATA_DECREMENT       :: 0x61;
    NONREG_PARM_NUM_LSB  :: 0x62;
    NONREG_PARM_NUM_MSB  :: 0x63;
    REGIST_PARM_NUM_LSB  :: 0x64;
    REGIST_PARM_NUM_MSB  :: 0x65;
    ALL_SOUNDS_OFF       :: 0x78;
    RESET_CONTROLLERS    :: 0x79;
    LOCAL_CONTROL_SWITCH :: 0x7a;
    ALL_NOTES_OFF        :: 0x7b;
    OMNI_OFF             :: 0x7c;
    OMNI_ON              :: 0x7d;
    MONO1                :: 0x7e;
    MONO2                :: 0x7f;

    MIDI_CTL_MSB_BANK             :: MSB_BANK;
    MIDI_CTL_MSB_MODWHEEL         :: MSB_MODWHEEL;
    MIDI_CTL_MSB_BREATH           :: MSB_BREATH;
    MIDI_CTL_MSB_FOOT             :: MSB_FOOT;
    MIDI_CTL_MSB_PORTAMENTO_TIME  :: MSB_PORTAMENTO_TIME;
    MIDI_CTL_MSB_DATA_ENTRY       :: MSB_DATA_ENTRY;
    MIDI_CTL_MSB_MAIN_VOLUME      :: MSB_MAIN_VOLUME;
    MIDI_CTL_MSB_BALANCE          :: MSB_BALANCE;
    MIDI_CTL_MSB_PAN              :: MSB_PAN;
    MIDI_CTL_MSB_EXPRESSION       :: MSB_EXPRESSION;
    MIDI_CTL_MSB_EFFECT1          :: MSB_EFFECT1;
    MIDI_CTL_MSB_EFFECT2          :: MSB_EFFECT2;
    MIDI_CTL_MSB_GENERAL_PURPOSE1 :: MSB_GENERAL_PURPOSE1;
    MIDI_CTL_MSB_GENERAL_PURPOSE2 :: MSB_GENERAL_PURPOSE2;
    MIDI_CTL_MSB_GENERAL_PURPOSE3 :: MSB_GENERAL_PURPOSE3;
    MIDI_CTL_MSB_GENERAL_PURPOSE4 :: MSB_GENERAL_PURPOSE4;
    MIDI_CTL_LSB_BANK             :: LSB_BANK;
    MIDI_CTL_LSB_MODWHEEL         :: LSB_MODWHEEL;
    MIDI_CTL_LSB_BREATH           :: LSB_BREATH;
    MIDI_CTL_LSB_FOOT             :: LSB_FOOT;
    MIDI_CTL_LSB_PORTAMENTO_TIME  :: LSB_PORTAMENTO_TIME;
    MIDI_CTL_LSB_DATA_ENTRY       :: LSB_DATA_ENTRY;
    MIDI_CTL_LSB_MAIN_VOLUME      :: LSB_MAIN_VOLUME;
    MIDI_CTL_LSB_BALANCE          :: LSB_BALANCE;
    MIDI_CTL_LSB_PAN              :: LSB_PAN;
    MIDI_CTL_LSB_EXPRESSION       :: LSB_EXPRESSION;
    MIDI_CTL_LSB_EFFECT1          :: LSB_EFFECT1;
    MIDI_CTL_LSB_EFFECT2          :: LSB_EFFECT2;
    MIDI_CTL_LSB_GENERAL_PURPOSE1 :: LSB_GENERAL_PURPOSE1;
    MIDI_CTL_LSB_GENERAL_PURPOSE2 :: LSB_GENERAL_PURPOSE2;
    MIDI_CTL_LSB_GENERAL_PURPOSE3 :: LSB_GENERAL_PURPOSE3;
    MIDI_CTL_LSB_GENERAL_PURPOSE4 :: LSB_GENERAL_PURPOSE4;
    MIDI_CTL_SUSTAIN              :: SUSTAIN;
    MIDI_CTL_PORTAMENTO           :: PORTAMENTO;
    MIDI_CTL_SOSTENUTO            :: SOSTENUTO;
    MIDI_CTL_SUSTENUTO            :: SUSTENUTO;
    MIDI_CTL_SOFT_PEDAL           :: SOFT_PEDAL;
    MIDI_CTL_LEGATO_FOOTSWITCH    :: LEGATO_FOOTSWITCH;
    MIDI_CTL_HOLD2                :: HOLD2;
    MIDI_CTL_SC1_SOUND_VARIATION  :: SC1_SOUND_VARIATION;
    MIDI_CTL_SC2_TIMBRE           :: SC2_TIMBRE;
    MIDI_CTL_SC3_RELEASE_TIME     :: SC3_RELEASE_TIME;
    MIDI_CTL_SC4_ATTACK_TIME      :: SC4_ATTACK_TIME;
    MIDI_CTL_SC5_BRIGHTNESS       :: SC5_BRIGHTNESS;
    MIDI_CTL_SC6                  :: SC6;
    MIDI_CTL_SC7                  :: SC7;
    MIDI_CTL_SC8                  :: SC8;
    MIDI_CTL_SC9                  :: SC9;
    MIDI_CTL_SC10                 :: SC10;
    MIDI_CTL_GENERAL_PURPOSE5     :: GENERAL_PURPOSE5;
    MIDI_CTL_GENERAL_PURPOSE6     :: GENERAL_PURPOSE6;
    MIDI_CTL_GENERAL_PURPOSE7     :: GENERAL_PURPOSE7;
    MIDI_CTL_GENERAL_PURPOSE8     :: GENERAL_PURPOSE8;
    MIDI_CTL_PORTAMENTO_CONTROL   :: PORTAMENTO_CONTROL;
    MIDI_CTL_E1_REVERB_DEPTH      :: E1_REVERB_DEPTH;
    MIDI_CTL_E2_TREMOLO_DEPTH     :: E2_TREMOLO_DEPTH;
    MIDI_CTL_E3_CHORUS_DEPTH      :: E3_CHORUS_DEPTH;
    MIDI_CTL_E4_DETUNE_DEPTH      :: E4_DETUNE_DEPTH;
    MIDI_CTL_E5_PHASER_DEPTH      :: E5_PHASER_DEPTH;
    MIDI_CTL_DATA_INCREMENT       :: DATA_INCREMENT;
    MIDI_CTL_DATA_DECREMENT       :: DATA_DECREMENT;
    MIDI_CTL_NONREG_PARM_NUM_LSB  :: NONREG_PARM_NUM_LSB;
    MIDI_CTL_NONREG_PARM_NUM_MSB  :: NONREG_PARM_NUM_MSB;
    MIDI_CTL_REGIST_PARM_NUM_LSB  :: REGIST_PARM_NUM_LSB;
    MIDI_CTL_REGIST_PARM_NUM_MSB  :: REGIST_PARM_NUM_MSB;
    MIDI_CTL_ALL_SOUNDS_OFF       :: ALL_SOUNDS_OFF;
    MIDI_CTL_RESET_CONTROLLERS    :: RESET_CONTROLLERS;
    MIDI_CTL_LOCAL_CONTROL_SWITCH :: LOCAL_CONTROL_SWITCH;
    MIDI_CTL_ALL_NOTES_OFF        :: ALL_NOTES_OFF;
    MIDI_CTL_OMNI_OFF             :: OMNI_OFF;
    MIDI_CTL_OMNI_ON              :: OMNI_ON;
    MIDI_CTL_MONO1                :: MONO1;
    MIDI_CTL_MONO2                :: MONO2;
}

SND_LIB_MAJOR :: 1;
SND_LIB_MINOR :: 2;
SND_LIB_SUBMINOR :: 6;
SND_LIB_EXTRAVER :: 1000000;

SND_LIB_VERSION_STR :: "1.2.6.1";

SND_ERROR_BEGIN :: 500000;
SND_ERROR_INCOMPATIBLE_VERSION :: SND_ERROR_BEGIN+0;
SND_ERROR_ALISP_NIL :: SND_ERROR_BEGIN+1;

SND_CHMAP_API_VERSION :: (1 << 16) | (0 << 8) | 1;

SND_CHMAP_POSITION_MASK :: 0xffff;

SND_CHMAP_PHASE_INVERSE :: 0x01 << 16;

SND_CHMAP_DRIVER_SPEC :: 0x02 << 16;

SND_RAWMIDI_APPEND :: 0x0001;

SND_RAWMIDI_NONBLOCK :: 0x0002;

SND_RAWMIDI_SYNC :: 0x0004;

SND_TIMER_GLOBAL_SYSTEM :: 0;

SND_TIMER_GLOBAL_RTC :: 1;

SND_TIMER_GLOBAL_HPET :: 2;

SND_TIMER_GLOBAL_HRTIMER :: 3;

SND_TIMER_OPEN_NONBLOCK :: 1<<0;

SND_TIMER_OPEN_TREAD :: 1<<1;

SND_SCTL_NOFREE :: 0x0001;

SND_SEQ_TIME_STAMP_TICK :: 0<<0;
SND_SEQ_TIME_STAMP_REAL :: 1<<0;
SND_SEQ_TIME_STAMP_MASK :: 1<<0;

SND_SEQ_TIME_MODE_ABS :: 0<<1;
SND_SEQ_TIME_MODE_REL :: 1<<1;
SND_SEQ_TIME_MODE_MASK :: 1<<1;

SND_SEQ_EVENT_LENGTH_FIXED :: 0<<2;
SND_SEQ_EVENT_LENGTH_VARIABLE :: 1<<2;
SND_SEQ_EVENT_LENGTH_VARUSR :: 2<<2;
SND_SEQ_EVENT_LENGTH_MASK :: 3<<2;

SND_SEQ_PRIORITY_NORMAL :: 0<<4;
SND_SEQ_PRIORITY_HIGH :: 1<<4;
SND_SEQ_PRIORITY_MASK :: 1<<4;

SND_SEQ_OPEN_OUTPUT :: 1;
SND_SEQ_OPEN_INPUT :: 2;
SND_SEQ_OPEN_DUPLEX :: SND_SEQ_OPEN_OUTPUT|SND_SEQ_OPEN_INPUT;

SND_SEQ_NONBLOCK :: 0x0001;

SND_SEQ_ADDRESS_UNKNOWN :: 253;
SND_SEQ_ADDRESS_SUBSCRIBERS :: 254;
SND_SEQ_ADDRESS_BROADCAST :: 255;

SND_SEQ_CLIENT_SYSTEM :: 0;

SND_SEQ_PORT_SYSTEM_TIMER :: 0;
SND_SEQ_PORT_SYSTEM_ANNOUNCE :: 1;

SND_SEQ_PORT_CAP :: enum_flags u32 {
    READ       :: 1<<0;
    WRITE      :: 1<<1;
    SYNC_READ  :: 1<<2;
    SYNC_WRITE :: 1<<3;
    DUPLEX     :: 1<<4;
    SUBS_READ  :: 1<<5;
    SUBS_WRITE :: 1<<6;
    NO_EXPORT  :: 1<<7;

    SND_SEQ_PORT_CAP_READ       :: READ;
    SND_SEQ_PORT_CAP_WRITE      :: WRITE;
    SND_SEQ_PORT_CAP_SYNC_READ  :: SYNC_READ;
    SND_SEQ_PORT_CAP_SYNC_WRITE :: SYNC_WRITE;
    SND_SEQ_PORT_CAP_DUPLEX     :: DUPLEX;
    SND_SEQ_PORT_CAP_SUBS_READ  :: SUBS_READ;
    SND_SEQ_PORT_CAP_SUBS_WRITE :: SUBS_WRITE;
    SND_SEQ_PORT_CAP_NO_EXPORT  :: NO_EXPORT;
}

SND_SEQ_PORT_TYPE :: enum_flags u32 {
    SPECIFIC      :: 1<<0;
    MIDI_GENERIC  :: 1<<1;
    MIDI_GM       :: 1<<2;
    MIDI_GS       :: 1<<3;
    MIDI_XG       :: 1<<4;
    MIDI_MT32     :: 1<<5;
    MIDI_GM2      :: 1<<6;
    SYNTH         :: 1<<10;
    DIRECT_SAMPLE :: 1<<11;
    SAMPLE        :: 1<<12;
    HARDWARE      :: 1<<16;
    SOFTWARE      :: 1<<17;
    SYNTHESIZER   :: 1<<18;
    PORT          :: 1<<19;
    APPLICATION   :: 1<<20;

    SND_SEQ_PORT_TYPE_SPECIFIC      :: SPECIFIC;
    SND_SEQ_PORT_TYPE_MIDI_GENERIC  :: MIDI_GENERIC;
    SND_SEQ_PORT_TYPE_MIDI_GM       :: MIDI_GM;
    SND_SEQ_PORT_TYPE_MIDI_GS       :: MIDI_GS;
    SND_SEQ_PORT_TYPE_MIDI_XG       :: MIDI_XG;
    SND_SEQ_PORT_TYPE_MIDI_MT32     :: MIDI_MT32;
    SND_SEQ_PORT_TYPE_MIDI_GM2      :: MIDI_GM2;
    SND_SEQ_PORT_TYPE_SYNTH         :: SYNTH;
    SND_SEQ_PORT_TYPE_DIRECT_SAMPLE :: DIRECT_SAMPLE;
    SND_SEQ_PORT_TYPE_SAMPLE        :: SAMPLE;
    SND_SEQ_PORT_TYPE_HARDWARE      :: HARDWARE;
    SND_SEQ_PORT_TYPE_SOFTWARE      :: SOFTWARE;
    SND_SEQ_PORT_TYPE_SYNTHESIZER   :: SYNTHESIZER;
    SND_SEQ_PORT_TYPE_PORT          :: PORT;
    SND_SEQ_PORT_TYPE_APPLICATION   :: APPLICATION;
}

SND_SEQ_QUEUE_DIRECT :: 253;

SND_SEQ_REMOVE :: enum_flags u32 {
    INPUT        :: 1<<0;
    OUTPUT       :: 1<<1;
    DEST         :: 1<<2;
    DEST_CHANNEL :: 1<<3;
    TIME_BEFORE  :: 1<<4;
    TIME_AFTER   :: 1<<5;
    TIME_TICK    :: 1<<6;
    EVENT_TYPE   :: 1<<7;
    IGNORE_OFF   :: 1<<8;
    TAG_MATCH    :: 1<<9;

    SND_SEQ_REMOVE_INPUT        :: INPUT;
    SND_SEQ_REMOVE_OUTPUT       :: OUTPUT;
    SND_SEQ_REMOVE_DEST         :: DEST;
    SND_SEQ_REMOVE_DEST_CHANNEL :: DEST_CHANNEL;
    SND_SEQ_REMOVE_TIME_BEFORE  :: TIME_BEFORE;
    SND_SEQ_REMOVE_TIME_AFTER   :: TIME_AFTER;
    SND_SEQ_REMOVE_TIME_TICK    :: TIME_TICK;
    SND_SEQ_REMOVE_EVENT_TYPE   :: EVENT_TYPE;
    SND_SEQ_REMOVE_IGNORE_OFF   :: IGNORE_OFF;
    SND_SEQ_REMOVE_TAG_MATCH    :: TAG_MATCH;
}

/**
*  \defgroup Global Global defines and functions
*  Global defines and functions.
*  \par
*  The ALSA library implementation uses these macros and functions.
*  Most applications probably do not need them.
*  \{
*/
snd_asoundlib_version :: () -> *u8 #foreign libasound;

snd_dlsym_link :: struct {
    next:       *snd_dlsym_link;
    dlsym_name: *u8;
    dlsym_ptr:  *void;
}

snd_dlsym_start: *snd_dlsym_link;

snd_dlpath :: (path: *u8, path_len: size_t, name: *u8) -> s32 #foreign libasound;
snd_dlopen :: (file: *u8, mode: s32, errbuf: *u8, errbuflen: size_t) -> *void #foreign libasound;
snd_dlsym :: (handle: *void, name: *u8, version: *u8) -> *void #foreign libasound;
snd_dlclose :: (handle: *void) -> s32 #foreign libasound;

snd_shm_area :: struct {}
snd_shm_area_create :: (shmid: s32, ptr: *void) -> *snd_shm_area #foreign libasound;
snd_shm_area_share :: (area: *snd_shm_area) -> *snd_shm_area #foreign libasound;
snd_shm_area_destroy :: (area: *snd_shm_area) -> s32 #foreign libasound;

snd_user_file :: (file: *u8, result: **u8) -> s32 #foreign libasound;

/** Timestamp */
snd_timestamp_t :: timeval;

/** Hi-res timestamp */
snd_htimestamp_t :: timespec;

snd_strerror :: (errnum: s32) -> *u8 #foreign libasound;

/**
* \brief Error handler callback.
* \param file Source file name.
* \param line Line number.
* \param function Function name.
* \param err Value of \c errno, or 0 if not relevant.
* \param fmt \c printf(3) format.
* \param ... \c printf(3) arguments.
*
* A function of this type is called by the ALSA library when an error occurs.
* This function usually shows the message on the screen, and/or logs it.
*/
snd_lib_error_handler_t :: #type (file: *u8, line: s32, function: *u8, err: s32, fmt: *u8, __args: ..Any) -> void #c_call;
snd_lib_error: snd_lib_error_handler_t;
snd_lib_error_set_handler :: (handler: snd_lib_error_handler_t) -> s32 #foreign libasound;

/** Local error handler function type */
snd_local_error_handler_t :: #type (file: *u8, line: s32, func: *u8, err: s32, fmt: *u8, arg: ..Any) -> void #c_call;

/**
* Device-name list element
*/
snd_devname_t :: snd_devname;

/**
* Device-name list element (definition)
*/
snd_devname :: struct {
    name:    *u8; /**< Device name string */
    comment: *u8; /**< Comments */
    next:    *snd_devname_t; /**< Next pointer */
}

snd_names_list :: (iface: *u8, list: **snd_devname_t) -> s32 #foreign libasound;
snd_names_list_free :: (list: *snd_devname_t) -> void #foreign libasound;

_snd_rawmidi_info :: struct {}
/** RawMidi information container */
snd_rawmidi_info_t :: _snd_rawmidi_info;

_snd_rawmidi_params :: struct {}
/** RawMidi settings container */
snd_rawmidi_params_t :: _snd_rawmidi_params;

_snd_rawmidi_status :: struct {}
/** RawMidi status container */
snd_rawmidi_status_t :: _snd_rawmidi_status;

/** RawMidi stream (direction) */
_snd_rawmidi_stream :: enum u32 {
    OUTPUT :: 0;
    INPUT  :: 1;
    LAST   :: 1;

    SND_RAWMIDI_STREAM_OUTPUT :: OUTPUT;
    SND_RAWMIDI_STREAM_INPUT  :: INPUT;
    SND_RAWMIDI_STREAM_LAST   :: LAST;
}

/** RawMidi stream (direction) */
snd_rawmidi_stream_t :: _snd_rawmidi_stream;

_snd_rawmidi :: struct {}
/** RawMidi handle */
snd_rawmidi_t :: _snd_rawmidi;

/** RawMidi type */
_snd_rawmidi_type :: enum u32 {
    HW      :: 0;
    SHM     :: 1;
    INET    :: 2;
    VIRTUAL :: 3;

    SND_RAWMIDI_TYPE_HW      :: HW;
    SND_RAWMIDI_TYPE_SHM     :: SHM;
    SND_RAWMIDI_TYPE_INET    :: INET;
    SND_RAWMIDI_TYPE_VIRTUAL :: VIRTUAL;
}

/** RawMidi type */
snd_rawmidi_type_t :: _snd_rawmidi_type;

/** Type of clock used with rawmidi timestamp */
_snd_rawmidi_clock :: enum u32 {
    NONE          :: 0;
    REALTIME      :: 1;
    MONOTONIC     :: 2;
    MONOTONIC_RAW :: 3;

    SND_RAWMIDI_CLOCK_NONE          :: NONE;
    SND_RAWMIDI_CLOCK_REALTIME      :: REALTIME;
    SND_RAWMIDI_CLOCK_MONOTONIC     :: MONOTONIC;
    SND_RAWMIDI_CLOCK_MONOTONIC_RAW :: MONOTONIC_RAW;
}

/** Type of clock used with rawmidi timestamp */
snd_rawmidi_clock_t :: _snd_rawmidi_clock;

/** Select the read mode (standard or with timestamps) */
_snd_rawmidi_read_mode :: enum u32 {
    STANDARD :: 0;
    TSTAMP   :: 1;

    SND_RAWMIDI_READ_STANDARD :: STANDARD;
    SND_RAWMIDI_READ_TSTAMP   :: TSTAMP;
}

/** Select the read mode (standard or with timestamps) */
snd_rawmidi_read_mode_t :: _snd_rawmidi_read_mode;

snd_rawmidi_open :: (in_rmidi: **snd_rawmidi_t, out_rmidi: **snd_rawmidi_t, name: *u8, mode: s32) -> s32 #foreign libasound;

snd_rawmidi_close :: (rmidi: *snd_rawmidi_t) -> s32 #foreign libasound;
snd_rawmidi_poll_descriptors_count :: (rmidi: *snd_rawmidi_t) -> s32 #foreign libasound;
snd_rawmidi_poll_descriptors :: (rmidi: *snd_rawmidi_t, pfds: *pollfd, space: u32) -> s32 #foreign libasound;
snd_rawmidi_poll_descriptors_revents :: (rawmidi: *snd_rawmidi_t, pfds: *pollfd, nfds: u32, revent: *u16) -> s32 #foreign libasound;
snd_rawmidi_nonblock :: (rmidi: *snd_rawmidi_t, nonblock: s32) -> s32 #foreign libasound;
snd_rawmidi_info_sizeof :: () -> size_t #foreign libasound;

snd_rawmidi_info_malloc :: (ptr: **snd_rawmidi_info_t) -> s32 #foreign libasound;
snd_rawmidi_info_free :: (obj: *snd_rawmidi_info_t) -> void #foreign libasound;
snd_rawmidi_info_copy :: (dst: *snd_rawmidi_info_t, src: *snd_rawmidi_info_t) -> void #foreign libasound;
snd_rawmidi_info_get_device :: (obj: *snd_rawmidi_info_t) -> u32 #foreign libasound;
snd_rawmidi_info_get_subdevice :: (obj: *snd_rawmidi_info_t) -> u32 #foreign libasound;
snd_rawmidi_info_get_stream :: (obj: *snd_rawmidi_info_t) -> snd_rawmidi_stream_t #foreign libasound;
snd_rawmidi_info_get_card :: (obj: *snd_rawmidi_info_t) -> s32 #foreign libasound;
snd_rawmidi_info_get_flags :: (obj: *snd_rawmidi_info_t) -> u32 #foreign libasound;
snd_rawmidi_info_get_id :: (obj: *snd_rawmidi_info_t) -> *u8 #foreign libasound;
snd_rawmidi_info_get_name :: (obj: *snd_rawmidi_info_t) -> *u8 #foreign libasound;
snd_rawmidi_info_get_subdevice_name :: (obj: *snd_rawmidi_info_t) -> *u8 #foreign libasound;
snd_rawmidi_info_get_subdevices_count :: (obj: *snd_rawmidi_info_t) -> u32 #foreign libasound;
snd_rawmidi_info_get_subdevices_avail :: (obj: *snd_rawmidi_info_t) -> u32 #foreign libasound;
snd_rawmidi_info_set_device :: (obj: *snd_rawmidi_info_t, val: u32) -> void #foreign libasound;
snd_rawmidi_info_set_subdevice :: (obj: *snd_rawmidi_info_t, val: u32) -> void #foreign libasound;
snd_rawmidi_info_set_stream :: (obj: *snd_rawmidi_info_t, val: snd_rawmidi_stream_t) -> void #foreign libasound;
snd_rawmidi_info :: (rmidi: *snd_rawmidi_t, info: *snd_rawmidi_info_t) -> s32 #foreign libasound;
snd_rawmidi_params_sizeof :: () -> size_t #foreign libasound;

snd_rawmidi_params_malloc :: (ptr: **snd_rawmidi_params_t) -> s32 #foreign libasound;
snd_rawmidi_params_free :: (obj: *snd_rawmidi_params_t) -> void #foreign libasound;
snd_rawmidi_params_copy :: (dst: *snd_rawmidi_params_t, src: *snd_rawmidi_params_t) -> void #foreign libasound;
snd_rawmidi_params_set_buffer_size :: (rmidi: *snd_rawmidi_t, params: *snd_rawmidi_params_t, val: size_t) -> s32 #foreign libasound;
snd_rawmidi_params_get_buffer_size :: (params: *snd_rawmidi_params_t) -> size_t #foreign libasound;
snd_rawmidi_params_set_avail_min :: (rmidi: *snd_rawmidi_t, params: *snd_rawmidi_params_t, val: size_t) -> s32 #foreign libasound;
snd_rawmidi_params_get_avail_min :: (params: *snd_rawmidi_params_t) -> size_t #foreign libasound;
snd_rawmidi_params_set_no_active_sensing :: (rmidi: *snd_rawmidi_t, params: *snd_rawmidi_params_t, val: s32) -> s32 #foreign libasound;
snd_rawmidi_params_get_no_active_sensing :: (params: *snd_rawmidi_params_t) -> s32 #foreign libasound;
snd_rawmidi_params_set_read_mode :: (rawmidi: *snd_rawmidi_t, params: *snd_rawmidi_params_t, val: snd_rawmidi_read_mode_t) -> s32 #foreign libasound;
snd_rawmidi_params_get_read_mode :: (params: *snd_rawmidi_params_t) -> snd_rawmidi_read_mode_t #foreign libasound;
snd_rawmidi_params_set_clock_type :: (rawmidi: *snd_rawmidi_t, params: *snd_rawmidi_params_t, val: snd_rawmidi_clock_t) -> s32 #foreign libasound;
snd_rawmidi_params_get_clock_type :: (params: *snd_rawmidi_params_t) -> snd_rawmidi_clock_t #foreign libasound;

snd_rawmidi_params :: (rmidi: *snd_rawmidi_t, params: *snd_rawmidi_params_t) -> s32 #foreign libasound;
snd_rawmidi_params_current :: (rmidi: *snd_rawmidi_t, params: *snd_rawmidi_params_t) -> s32 #foreign libasound;
snd_rawmidi_status_sizeof :: () -> size_t #foreign libasound;

snd_rawmidi_status_malloc :: (ptr: **snd_rawmidi_status_t) -> s32 #foreign libasound;
snd_rawmidi_status_free :: (obj: *snd_rawmidi_status_t) -> void #foreign libasound;
snd_rawmidi_status_copy :: (dst: *snd_rawmidi_status_t, src: *snd_rawmidi_status_t) -> void #foreign libasound;
snd_rawmidi_status_get_tstamp :: (obj: *snd_rawmidi_status_t, ptr: *snd_htimestamp_t) -> void #foreign libasound;
snd_rawmidi_status_get_avail :: (obj: *snd_rawmidi_status_t) -> size_t #foreign libasound;
snd_rawmidi_status_get_xruns :: (obj: *snd_rawmidi_status_t) -> size_t #foreign libasound;
snd_rawmidi_status :: (rmidi: *snd_rawmidi_t, status: *snd_rawmidi_status_t) -> s32 #foreign libasound;
snd_rawmidi_drain :: (rmidi: *snd_rawmidi_t) -> s32 #foreign libasound;
snd_rawmidi_drop :: (rmidi: *snd_rawmidi_t) -> s32 #foreign libasound;
snd_rawmidi_write :: (rmidi: *snd_rawmidi_t, buffer: *void, size: size_t) -> ssize_t #foreign libasound;
snd_rawmidi_read :: (rmidi: *snd_rawmidi_t, buffer: *void, size: size_t) -> ssize_t #foreign libasound;
snd_rawmidi_tread :: (rmidi: *snd_rawmidi_t, tstamp: *timespec, buffer: *void, size: size_t) -> ssize_t #foreign libasound;
snd_rawmidi_name :: (rmidi: *snd_rawmidi_t) -> *u8 #foreign libasound;
snd_rawmidi_type :: (rmidi: *snd_rawmidi_t) -> snd_rawmidi_type_t #foreign libasound;
snd_rawmidi_stream :: (rawmidi: *snd_rawmidi_t) -> snd_rawmidi_stream_t #foreign libasound;

/** IEC958 structure */
snd_aes_iec958 :: struct {
    status:       [24] u8; /**< AES/IEC958 channel status bits */
    subcode:      [147] u8; /**< AES/IEC958 subcode bits */
    pad:          u8; /**< nothing */
    dig_subframe: [4] u8; /**< AES/IEC958 subframe bits */
}

/** IEC958 structure */
snd_aes_iec958_t :: snd_aes_iec958;

snd_card_load :: (card: s32) -> s32 #foreign libasound;
snd_card_next :: (card: *s32) -> s32 #foreign libasound;
snd_card_get_index :: (name: *u8) -> s32 #foreign libasound;
snd_card_get_name :: (card: s32, name: **u8) -> s32 #foreign libasound;
snd_card_get_longname :: (card: s32, name: **u8) -> s32 #foreign libasound;

snd_device_name_hint :: (card: s32, iface: *u8, hints: ***void) -> s32 #foreign libasound;
snd_device_name_free_hint :: (hints: **void) -> s32 #foreign libasound;
snd_device_name_get_hint :: (hint: *void, id: *u8) -> *u8 #foreign libasound;

snd_tlv_parse_dB_info :: (tlv: *u32, tlv_size: u32, db_tlvp: **u32) -> s32 #foreign libasound;

snd_tlv_get_dB_range :: (tlv: *u32, rangemin: s64, rangemax: s64, min: *s64, max: *s64) -> s32 #foreign libasound;

snd_tlv_convert_to_dB :: (tlv: *u32, rangemin: s64, rangemax: s64, volume: s64, db_gain: *s64) -> s32 #foreign libasound;

snd_tlv_convert_from_dB :: (tlv: *u32, rangemin: s64, rangemax: s64, db_gain: s64, value: *s64, xdir: s32) -> s32 #foreign libasound;

/**
* Sequencer event data type
*/
snd_seq_event_type_t :: snd_seq_event_type;

/** Sequencer event type */
snd_seq_event_type :: enum u8 {
    SYSTEM            :: 0;
    RESULT            :: 1;
    NOTE              :: 5;
    NOTEON            :: 6;
    NOTEOFF           :: 7;
    KEYPRESS          :: 8;
    CONTROLLER        :: 10;
    PGMCHANGE         :: 11;
    CHANPRESS         :: 12;
    PITCHBEND         :: 13;
    CONTROL14         :: 14;
    NONREGPARAM       :: 15;
    REGPARAM          :: 16;
    SONGPOS           :: 20;
    SONGSEL           :: 21;
    QFRAME            :: 22;
    TIMESIGN          :: 23;
    KEYSIGN           :: 24;
    START             :: 30;
    CONTINUE          :: 31;
    STOP              :: 32;
    SETPOS_TICK       :: 33;
    SETPOS_TIME       :: 34;
    TEMPO             :: 35;
    CLOCK             :: 36;
    TICK              :: 37;
    QUEUE_SKEW        :: 38;
    SYNC_POS          :: 39;
    TUNE_REQUEST      :: 40;
    RESET             :: 41;
    SENSING           :: 42;
    ECHO              :: 50;
    OSS               :: 51;
    CLIENT_START      :: 60;
    CLIENT_EXIT       :: 61;
    CLIENT_CHANGE     :: 62;
    PORT_START        :: 63;
    PORT_EXIT         :: 64;
    PORT_CHANGE       :: 65;
    PORT_SUBSCRIBED   :: 66;
    PORT_UNSUBSCRIBED :: 67;
    USR0              :: 90;
    USR1              :: 91;
    USR2              :: 92;
    USR3              :: 93;
    USR4              :: 94;
    USR5              :: 95;
    USR6              :: 96;
    USR7              :: 97;
    USR8              :: 98;
    USR9              :: 99;
    SYSEX             :: 130;
    BOUNCE            :: 131;
    USR_VAR0          :: 135;
    USR_VAR1          :: 136;
    USR_VAR2          :: 137;
    USR_VAR3          :: 138;
    USR_VAR4          :: 139;
    NONE              :: 255;

    SND_SEQ_EVENT_SYSTEM            :: SYSTEM;
    SND_SEQ_EVENT_RESULT            :: RESULT;
    SND_SEQ_EVENT_NOTE              :: NOTE;
    SND_SEQ_EVENT_NOTEON            :: NOTEON;
    SND_SEQ_EVENT_NOTEOFF           :: NOTEOFF;
    SND_SEQ_EVENT_KEYPRESS          :: KEYPRESS;
    SND_SEQ_EVENT_CONTROLLER        :: CONTROLLER;
    SND_SEQ_EVENT_PGMCHANGE         :: PGMCHANGE;
    SND_SEQ_EVENT_CHANPRESS         :: CHANPRESS;
    SND_SEQ_EVENT_PITCHBEND         :: PITCHBEND;
    SND_SEQ_EVENT_CONTROL14         :: CONTROL14;
    SND_SEQ_EVENT_NONREGPARAM       :: NONREGPARAM;
    SND_SEQ_EVENT_REGPARAM          :: REGPARAM;
    SND_SEQ_EVENT_SONGPOS           :: SONGPOS;
    SND_SEQ_EVENT_SONGSEL           :: SONGSEL;
    SND_SEQ_EVENT_QFRAME            :: QFRAME;
    SND_SEQ_EVENT_TIMESIGN          :: TIMESIGN;
    SND_SEQ_EVENT_KEYSIGN           :: KEYSIGN;
    SND_SEQ_EVENT_START             :: START;
    SND_SEQ_EVENT_CONTINUE          :: CONTINUE;
    SND_SEQ_EVENT_STOP              :: STOP;
    SND_SEQ_EVENT_SETPOS_TICK       :: SETPOS_TICK;
    SND_SEQ_EVENT_SETPOS_TIME       :: SETPOS_TIME;
    SND_SEQ_EVENT_TEMPO             :: TEMPO;
    SND_SEQ_EVENT_CLOCK             :: CLOCK;
    SND_SEQ_EVENT_TICK              :: TICK;
    SND_SEQ_EVENT_QUEUE_SKEW        :: QUEUE_SKEW;
    SND_SEQ_EVENT_SYNC_POS          :: SYNC_POS;
    SND_SEQ_EVENT_TUNE_REQUEST      :: TUNE_REQUEST;
    SND_SEQ_EVENT_RESET             :: RESET;
    SND_SEQ_EVENT_SENSING           :: SENSING;
    SND_SEQ_EVENT_ECHO              :: ECHO;
    SND_SEQ_EVENT_OSS               :: OSS;
    SND_SEQ_EVENT_CLIENT_START      :: CLIENT_START;
    SND_SEQ_EVENT_CLIENT_EXIT       :: CLIENT_EXIT;
    SND_SEQ_EVENT_CLIENT_CHANGE     :: CLIENT_CHANGE;
    SND_SEQ_EVENT_PORT_START        :: PORT_START;
    SND_SEQ_EVENT_PORT_EXIT         :: PORT_EXIT;
    SND_SEQ_EVENT_PORT_CHANGE       :: PORT_CHANGE;
    SND_SEQ_EVENT_PORT_SUBSCRIBED   :: PORT_SUBSCRIBED;
    SND_SEQ_EVENT_PORT_UNSUBSCRIBED :: PORT_UNSUBSCRIBED;
    SND_SEQ_EVENT_USR0              :: USR0;
    SND_SEQ_EVENT_USR1              :: USR1;
    SND_SEQ_EVENT_USR2              :: USR2;
    SND_SEQ_EVENT_USR3              :: USR3;
    SND_SEQ_EVENT_USR4              :: USR4;
    SND_SEQ_EVENT_USR5              :: USR5;
    SND_SEQ_EVENT_USR6              :: USR6;
    SND_SEQ_EVENT_USR7              :: USR7;
    SND_SEQ_EVENT_USR8              :: USR8;
    SND_SEQ_EVENT_USR9              :: USR9;
    SND_SEQ_EVENT_SYSEX             :: SYSEX;
    SND_SEQ_EVENT_BOUNCE            :: BOUNCE;
    SND_SEQ_EVENT_USR_VAR0          :: USR_VAR0;
    SND_SEQ_EVENT_USR_VAR1          :: USR_VAR1;
    SND_SEQ_EVENT_USR_VAR2          :: USR_VAR2;
    SND_SEQ_EVENT_USR_VAR3          :: USR_VAR3;
    SND_SEQ_EVENT_USR_VAR4          :: USR_VAR4;
    SND_SEQ_EVENT_NONE              :: NONE;
}

/** Sequencer event address */
snd_seq_addr :: struct {
    client: u8; /**< Client id */
    port:   u8; /**< Port id */
}

/** Sequencer event address */
snd_seq_addr_t :: snd_seq_addr;

/** Connection (subscription) between ports */
snd_seq_connect :: struct {
    sender: snd_seq_addr_t; /**< sender address */
    dest:   snd_seq_addr_t; /**< destination address */
}

/** Connection (subscription) between ports */
snd_seq_connect_t :: snd_seq_connect;

/** Real-time data record */
snd_seq_real_time :: struct {
    tv_sec:  u32; /**< seconds */
    tv_nsec: u32; /**< nanoseconds */
}

/** Real-time data record */
snd_seq_real_time_t :: snd_seq_real_time;

/** (MIDI) Tick-time data record */
snd_seq_tick_time_t :: u32;

/** unioned time stamp */
snd_seq_timestamp :: union {
    tick: snd_seq_tick_time_t; /**< tick-time */
    time: snd_seq_real_time; /**< real-time */
}

/** unioned time stamp */
snd_seq_timestamp_t :: snd_seq_timestamp;

/** Note event */
snd_seq_ev_note :: struct {
    channel:      u8; /**< channel number */
    note:         u8; /**< note */
    velocity:     u8; /**< velocity */
    off_velocity: u8; /**< note-off velocity; only for #SND_SEQ_EVENT_NOTE */
    duration:     u32; /**< duration until note-off; only for #SND_SEQ_EVENT_NOTE */
}

/** Note event */
snd_seq_ev_note_t :: snd_seq_ev_note;

/** Controller event */
snd_seq_ev_ctrl :: struct {
    channel: u8; /**< channel number */
    unused:  [3] u8; /**< reserved */
    param:   u32; /**< control parameter */
    value:   s32; /**< control value */
}

/** Controller event */
snd_seq_ev_ctrl_t :: snd_seq_ev_ctrl;

/** generic set of bytes (12x8 bit) */
snd_seq_ev_raw8 :: struct {
    d: [12] u8; /**< 8 bit value */
}

/** generic set of bytes (12x8 bit) */
snd_seq_ev_raw8_t :: snd_seq_ev_raw8;

/** generic set of integers (3x32 bit) */
snd_seq_ev_raw32 :: struct {
    d: [3] u32; /**< 32 bit value */
}

/** generic set of integers (3x32 bit) */
snd_seq_ev_raw32_t :: snd_seq_ev_raw32;

/** external stored data */
snd_seq_ev_ext :: struct {
    len: u32; /**< length of data */
    ptr: *void #align 4; /**< pointer to data (note: can be 64-bit) */
}

/** external stored data */
snd_seq_ev_ext_t :: snd_seq_ev_ext;

/** Result events */
snd_seq_result :: struct {
    event:  s32; /**< processed event type */
    result: s32; /**< status */
}

/** Result events */
snd_seq_result_t :: snd_seq_result;

/** Queue skew values */
snd_seq_queue_skew :: struct {
    value: u32; /**< skew value */
    base:  u32; /**< skew base */
}

/** Queue skew values */
snd_seq_queue_skew_t :: snd_seq_queue_skew;

/** queue timer control */
snd_seq_ev_queue_control :: struct {
    queue:  u8; /**< affected queue */
    unused: [3] u8; /**< reserved */
    param:  union {
        value:    s32; /**< affected value (e.g. tempo) */
        time:     snd_seq_timestamp_t; /**< time */
        position: u32; /**< sync position */
        skew:     snd_seq_queue_skew_t; /**< queue skew */
        d32:      [2] u32; /**< any data */
        d8:       [8] u8; /**< any data */
    }; /**< data value union */
}

/** queue timer control */
snd_seq_ev_queue_control_t :: snd_seq_ev_queue_control;

/** Sequencer event */
snd_seq_event :: struct {
    type:   snd_seq_event_type_t; /**< event type */
    flags:  u8; /**< event flags */
    tag:    u8; /**< tag */

    queue:  u8; /**< schedule queue */
    time:   snd_seq_timestamp_t; /**< schedule time */

    source: snd_seq_addr_t; /**< source address */
    dest:   snd_seq_addr_t; /**< destination address */

    data:   union {
        note:    snd_seq_ev_note_t; /**< note information */
        control: snd_seq_ev_ctrl_t; /**< MIDI control information */
        raw8:    snd_seq_ev_raw8_t; /**< raw8 data */
        raw32:   snd_seq_ev_raw32_t; /**< raw32 data */
        ext:     snd_seq_ev_ext_t; /**< external data */
        queue:   snd_seq_ev_queue_control_t; /**< queue control */
        time:    snd_seq_timestamp_t; /**< timestamp */
        addr:    snd_seq_addr_t; /**< address */
        connect: snd_seq_connect_t; /**< connect information */
        result:  snd_seq_result_t; /**< operation result code */
    }; /**< event data... */
}

/** Sequencer event */
snd_seq_event_t :: snd_seq_event;

_snd_seq :: struct {}
/** Sequencer handle */
snd_seq_t :: _snd_seq;

/** sequencer handle type */
_snd_seq_type :: enum u32 {
    HW   :: 0;
    SHM  :: 1;
    INET :: 2;

    SND_SEQ_TYPE_HW   :: HW;
    SND_SEQ_TYPE_SHM  :: SHM;
    SND_SEQ_TYPE_INET :: INET;
}

/** sequencer handle type */
snd_seq_type_t :: _snd_seq_type;

/*
*/
snd_seq_open :: (handle: **snd_seq_t, name: *u8, streams: s32, mode: s32) -> s32 #foreign libasound;

snd_seq_name :: (seq: *snd_seq_t) -> *u8 #foreign libasound;
snd_seq_type :: (seq: *snd_seq_t) -> snd_seq_type_t #foreign libasound;
snd_seq_close :: (handle: *snd_seq_t) -> s32 #foreign libasound;
snd_seq_poll_descriptors_count :: (handle: *snd_seq_t, events: s16) -> s32 #foreign libasound;
snd_seq_poll_descriptors :: (handle: *snd_seq_t, pfds: *pollfd, space: u32, events: s16) -> s32 #foreign libasound;
snd_seq_poll_descriptors_revents :: (seq: *snd_seq_t, pfds: *pollfd, nfds: u32, revents: *u16) -> s32 #foreign libasound;
snd_seq_nonblock :: (handle: *snd_seq_t, nonblock: s32) -> s32 #foreign libasound;
snd_seq_client_id :: (handle: *snd_seq_t) -> s32 #foreign libasound;

snd_seq_get_output_buffer_size :: (handle: *snd_seq_t) -> size_t #foreign libasound;
snd_seq_get_input_buffer_size :: (handle: *snd_seq_t) -> size_t #foreign libasound;
snd_seq_set_output_buffer_size :: (handle: *snd_seq_t, size: size_t) -> s32 #foreign libasound;
snd_seq_set_input_buffer_size :: (handle: *snd_seq_t, size: size_t) -> s32 #foreign libasound;

_snd_seq_system_info :: struct {}
/** system information container */
snd_seq_system_info_t :: _snd_seq_system_info;

snd_seq_system_info_sizeof :: () -> size_t #foreign libasound;

snd_seq_system_info_malloc :: (ptr: **snd_seq_system_info_t) -> s32 #foreign libasound;
snd_seq_system_info_free :: (ptr: *snd_seq_system_info_t) -> void #foreign libasound;
snd_seq_system_info_copy :: (dst: *snd_seq_system_info_t, src: *snd_seq_system_info_t) -> void #foreign libasound;

snd_seq_system_info_get_queues :: (info: *snd_seq_system_info_t) -> s32 #foreign libasound;
snd_seq_system_info_get_clients :: (info: *snd_seq_system_info_t) -> s32 #foreign libasound;
snd_seq_system_info_get_ports :: (info: *snd_seq_system_info_t) -> s32 #foreign libasound;
snd_seq_system_info_get_channels :: (info: *snd_seq_system_info_t) -> s32 #foreign libasound;
snd_seq_system_info_get_cur_clients :: (info: *snd_seq_system_info_t) -> s32 #foreign libasound;
snd_seq_system_info_get_cur_queues :: (info: *snd_seq_system_info_t) -> s32 #foreign libasound;

snd_seq_system_info :: (handle: *snd_seq_t, info: *snd_seq_system_info_t) -> s32 #foreign libasound;

_snd_seq_client_info :: struct {}
/** client information container */
snd_seq_client_info_t :: _snd_seq_client_info;

/** client types */
snd_seq_client_type :: enum u32 {
    USER_CLIENT   :: 1;
    KERNEL_CLIENT :: 2;

    SND_SEQ_USER_CLIENT   :: USER_CLIENT;
    SND_SEQ_KERNEL_CLIENT :: KERNEL_CLIENT;
}

/** client types */
snd_seq_client_type_t :: snd_seq_client_type;

snd_seq_client_info_sizeof :: () -> size_t #foreign libasound;

snd_seq_client_info_malloc :: (ptr: **snd_seq_client_info_t) -> s32 #foreign libasound;
snd_seq_client_info_free :: (ptr: *snd_seq_client_info_t) -> void #foreign libasound;
snd_seq_client_info_copy :: (dst: *snd_seq_client_info_t, src: *snd_seq_client_info_t) -> void #foreign libasound;

snd_seq_client_info_get_client :: (info: *snd_seq_client_info_t) -> s32 #foreign libasound;
snd_seq_client_info_get_type :: (info: *snd_seq_client_info_t) -> snd_seq_client_type_t #foreign libasound;
snd_seq_client_info_get_name :: (info: *snd_seq_client_info_t) -> *u8 #foreign libasound;
snd_seq_client_info_get_broadcast_filter :: (info: *snd_seq_client_info_t) -> s32 #foreign libasound;
snd_seq_client_info_get_error_bounce :: (info: *snd_seq_client_info_t) -> s32 #foreign libasound;
snd_seq_client_info_get_card :: (info: *snd_seq_client_info_t) -> s32 #foreign libasound;
snd_seq_client_info_get_pid :: (info: *snd_seq_client_info_t) -> s32 #foreign libasound;
snd_seq_client_info_get_event_filter :: (info: *snd_seq_client_info_t) -> *u8 #foreign libasound;
snd_seq_client_info_get_num_ports :: (info: *snd_seq_client_info_t) -> s32 #foreign libasound;
snd_seq_client_info_get_event_lost :: (info: *snd_seq_client_info_t) -> s32 #foreign libasound;

snd_seq_client_info_set_client :: (info: *snd_seq_client_info_t, client: s32) -> void #foreign libasound;
snd_seq_client_info_set_name :: (info: *snd_seq_client_info_t, name: *u8) -> void #foreign libasound;
snd_seq_client_info_set_broadcast_filter :: (info: *snd_seq_client_info_t, val: s32) -> void #foreign libasound;
snd_seq_client_info_set_error_bounce :: (info: *snd_seq_client_info_t, val: s32) -> void #foreign libasound;
snd_seq_client_info_set_event_filter :: (info: *snd_seq_client_info_t, filter: *u8) -> void #foreign libasound;

snd_seq_client_info_event_filter_clear :: (info: *snd_seq_client_info_t) -> void #foreign libasound;
snd_seq_client_info_event_filter_add :: (info: *snd_seq_client_info_t, event_type: s32) -> void #foreign libasound;
snd_seq_client_info_event_filter_del :: (info: *snd_seq_client_info_t, event_type: s32) -> void #foreign libasound;
snd_seq_client_info_event_filter_check :: (info: *snd_seq_client_info_t, event_type: s32) -> s32 #foreign libasound;

snd_seq_get_client_info :: (handle: *snd_seq_t, info: *snd_seq_client_info_t) -> s32 #foreign libasound;
snd_seq_get_any_client_info :: (handle: *snd_seq_t, client: s32, info: *snd_seq_client_info_t) -> s32 #foreign libasound;
snd_seq_set_client_info :: (handle: *snd_seq_t, info: *snd_seq_client_info_t) -> s32 #foreign libasound;
snd_seq_query_next_client :: (handle: *snd_seq_t, info: *snd_seq_client_info_t) -> s32 #foreign libasound;

_snd_seq_client_pool :: struct {}
/** client pool information container */
snd_seq_client_pool_t :: _snd_seq_client_pool;

snd_seq_client_pool_sizeof :: () -> size_t #foreign libasound;

snd_seq_client_pool_malloc :: (ptr: **snd_seq_client_pool_t) -> s32 #foreign libasound;
snd_seq_client_pool_free :: (ptr: *snd_seq_client_pool_t) -> void #foreign libasound;
snd_seq_client_pool_copy :: (dst: *snd_seq_client_pool_t, src: *snd_seq_client_pool_t) -> void #foreign libasound;

snd_seq_client_pool_get_client :: (info: *snd_seq_client_pool_t) -> s32 #foreign libasound;
snd_seq_client_pool_get_output_pool :: (info: *snd_seq_client_pool_t) -> size_t #foreign libasound;
snd_seq_client_pool_get_input_pool :: (info: *snd_seq_client_pool_t) -> size_t #foreign libasound;
snd_seq_client_pool_get_output_room :: (info: *snd_seq_client_pool_t) -> size_t #foreign libasound;
snd_seq_client_pool_get_output_free :: (info: *snd_seq_client_pool_t) -> size_t #foreign libasound;
snd_seq_client_pool_get_input_free :: (info: *snd_seq_client_pool_t) -> size_t #foreign libasound;
snd_seq_client_pool_set_output_pool :: (info: *snd_seq_client_pool_t, size: size_t) -> void #foreign libasound;
snd_seq_client_pool_set_input_pool :: (info: *snd_seq_client_pool_t, size: size_t) -> void #foreign libasound;
snd_seq_client_pool_set_output_room :: (info: *snd_seq_client_pool_t, size: size_t) -> void #foreign libasound;

snd_seq_get_client_pool :: (handle: *snd_seq_t, info: *snd_seq_client_pool_t) -> s32 #foreign libasound;
snd_seq_set_client_pool :: (handle: *snd_seq_t, info: *snd_seq_client_pool_t) -> s32 #foreign libasound;

_snd_seq_port_info :: struct {}
/** port information container */
snd_seq_port_info_t :: _snd_seq_port_info;

snd_seq_port_info_sizeof :: () -> size_t #foreign libasound;

snd_seq_port_info_malloc :: (ptr: **snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_free :: (ptr: *snd_seq_port_info_t) -> void #foreign libasound;
snd_seq_port_info_copy :: (dst: *snd_seq_port_info_t, src: *snd_seq_port_info_t) -> void #foreign libasound;

snd_seq_port_info_get_client :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_get_port :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_get_addr :: (info: *snd_seq_port_info_t) -> *snd_seq_addr_t #foreign libasound;
snd_seq_port_info_get_name :: (info: *snd_seq_port_info_t) -> *u8 #foreign libasound;
snd_seq_port_info_get_capability :: (info: *snd_seq_port_info_t) -> u32 #foreign libasound;
snd_seq_port_info_get_type :: (info: *snd_seq_port_info_t) -> u32 #foreign libasound;
snd_seq_port_info_get_midi_channels :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_get_midi_voices :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_get_synth_voices :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_get_read_use :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_get_write_use :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_get_port_specified :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_get_timestamping :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_get_timestamp_real :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_port_info_get_timestamp_queue :: (info: *snd_seq_port_info_t) -> s32 #foreign libasound;

snd_seq_port_info_set_client :: (info: *snd_seq_port_info_t, client: s32) -> void #foreign libasound;
snd_seq_port_info_set_port :: (info: *snd_seq_port_info_t, port: s32) -> void #foreign libasound;
snd_seq_port_info_set_addr :: (info: *snd_seq_port_info_t, addr: *snd_seq_addr_t) -> void #foreign libasound;
snd_seq_port_info_set_name :: (info: *snd_seq_port_info_t, name: *u8) -> void #foreign libasound;
snd_seq_port_info_set_capability :: (info: *snd_seq_port_info_t, capability: u32) -> void #foreign libasound;
snd_seq_port_info_set_type :: (info: *snd_seq_port_info_t, type: u32) -> void #foreign libasound;
snd_seq_port_info_set_midi_channels :: (info: *snd_seq_port_info_t, channels: s32) -> void #foreign libasound;
snd_seq_port_info_set_midi_voices :: (info: *snd_seq_port_info_t, voices: s32) -> void #foreign libasound;
snd_seq_port_info_set_synth_voices :: (info: *snd_seq_port_info_t, voices: s32) -> void #foreign libasound;
snd_seq_port_info_set_port_specified :: (info: *snd_seq_port_info_t, val: s32) -> void #foreign libasound;
snd_seq_port_info_set_timestamping :: (info: *snd_seq_port_info_t, enable: s32) -> void #foreign libasound;
snd_seq_port_info_set_timestamp_real :: (info: *snd_seq_port_info_t, realtime: s32) -> void #foreign libasound;
snd_seq_port_info_set_timestamp_queue :: (info: *snd_seq_port_info_t, queue: s32) -> void #foreign libasound;

snd_seq_create_port :: (handle: *snd_seq_t, info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_delete_port :: (handle: *snd_seq_t, port: s32) -> s32 #foreign libasound;
snd_seq_get_port_info :: (handle: *snd_seq_t, port: s32, info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_get_any_port_info :: (handle: *snd_seq_t, client: s32, port: s32, info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_set_port_info :: (handle: *snd_seq_t, port: s32, info: *snd_seq_port_info_t) -> s32 #foreign libasound;
snd_seq_query_next_port :: (handle: *snd_seq_t, info: *snd_seq_port_info_t) -> s32 #foreign libasound;

_snd_seq_port_subscribe :: struct {}
/** port subscription container */
snd_seq_port_subscribe_t :: _snd_seq_port_subscribe;

snd_seq_port_subscribe_sizeof :: () -> size_t #foreign libasound;

snd_seq_port_subscribe_malloc :: (ptr: **snd_seq_port_subscribe_t) -> s32 #foreign libasound;
snd_seq_port_subscribe_free :: (ptr: *snd_seq_port_subscribe_t) -> void #foreign libasound;
snd_seq_port_subscribe_copy :: (dst: *snd_seq_port_subscribe_t, src: *snd_seq_port_subscribe_t) -> void #foreign libasound;

snd_seq_port_subscribe_get_sender :: (info: *snd_seq_port_subscribe_t) -> *snd_seq_addr_t #foreign libasound;
snd_seq_port_subscribe_get_dest :: (info: *snd_seq_port_subscribe_t) -> *snd_seq_addr_t #foreign libasound;
snd_seq_port_subscribe_get_queue :: (info: *snd_seq_port_subscribe_t) -> s32 #foreign libasound;
snd_seq_port_subscribe_get_exclusive :: (info: *snd_seq_port_subscribe_t) -> s32 #foreign libasound;
snd_seq_port_subscribe_get_time_update :: (info: *snd_seq_port_subscribe_t) -> s32 #foreign libasound;
snd_seq_port_subscribe_get_time_real :: (info: *snd_seq_port_subscribe_t) -> s32 #foreign libasound;

snd_seq_port_subscribe_set_sender :: (info: *snd_seq_port_subscribe_t, addr: *snd_seq_addr_t) -> void #foreign libasound;
snd_seq_port_subscribe_set_dest :: (info: *snd_seq_port_subscribe_t, addr: *snd_seq_addr_t) -> void #foreign libasound;
snd_seq_port_subscribe_set_queue :: (info: *snd_seq_port_subscribe_t, q: s32) -> void #foreign libasound;
snd_seq_port_subscribe_set_exclusive :: (info: *snd_seq_port_subscribe_t, val: s32) -> void #foreign libasound;
snd_seq_port_subscribe_set_time_update :: (info: *snd_seq_port_subscribe_t, val: s32) -> void #foreign libasound;
snd_seq_port_subscribe_set_time_real :: (info: *snd_seq_port_subscribe_t, val: s32) -> void #foreign libasound;

snd_seq_get_port_subscription :: (handle: *snd_seq_t, sub: *snd_seq_port_subscribe_t) -> s32 #foreign libasound;
snd_seq_subscribe_port :: (handle: *snd_seq_t, sub: *snd_seq_port_subscribe_t) -> s32 #foreign libasound;
snd_seq_unsubscribe_port :: (handle: *snd_seq_t, sub: *snd_seq_port_subscribe_t) -> s32 #foreign libasound;

_snd_seq_query_subscribe :: struct {}
/** subscription query container */
snd_seq_query_subscribe_t :: _snd_seq_query_subscribe;

/** type of query subscription */
snd_seq_query_subs_type_t :: enum u32 {
    READ  :: 0;
    WRITE :: 1;

    SND_SEQ_QUERY_SUBS_READ  :: READ;
    SND_SEQ_QUERY_SUBS_WRITE :: WRITE;
}

snd_seq_query_subscribe_sizeof :: () -> size_t #foreign libasound;

snd_seq_query_subscribe_malloc :: (ptr: **snd_seq_query_subscribe_t) -> s32 #foreign libasound;
snd_seq_query_subscribe_free :: (ptr: *snd_seq_query_subscribe_t) -> void #foreign libasound;
snd_seq_query_subscribe_copy :: (dst: *snd_seq_query_subscribe_t, src: *snd_seq_query_subscribe_t) -> void #foreign libasound;

snd_seq_query_subscribe_get_client :: (info: *snd_seq_query_subscribe_t) -> s32 #foreign libasound;
snd_seq_query_subscribe_get_port :: (info: *snd_seq_query_subscribe_t) -> s32 #foreign libasound;
snd_seq_query_subscribe_get_root :: (info: *snd_seq_query_subscribe_t) -> *snd_seq_addr_t #foreign libasound;
snd_seq_query_subscribe_get_type :: (info: *snd_seq_query_subscribe_t) -> snd_seq_query_subs_type_t #foreign libasound;
snd_seq_query_subscribe_get_index :: (info: *snd_seq_query_subscribe_t) -> s32 #foreign libasound;
snd_seq_query_subscribe_get_num_subs :: (info: *snd_seq_query_subscribe_t) -> s32 #foreign libasound;
snd_seq_query_subscribe_get_addr :: (info: *snd_seq_query_subscribe_t) -> *snd_seq_addr_t #foreign libasound;
snd_seq_query_subscribe_get_queue :: (info: *snd_seq_query_subscribe_t) -> s32 #foreign libasound;
snd_seq_query_subscribe_get_exclusive :: (info: *snd_seq_query_subscribe_t) -> s32 #foreign libasound;
snd_seq_query_subscribe_get_time_update :: (info: *snd_seq_query_subscribe_t) -> s32 #foreign libasound;
snd_seq_query_subscribe_get_time_real :: (info: *snd_seq_query_subscribe_t) -> s32 #foreign libasound;

snd_seq_query_subscribe_set_client :: (info: *snd_seq_query_subscribe_t, client: s32) -> void #foreign libasound;
snd_seq_query_subscribe_set_port :: (info: *snd_seq_query_subscribe_t, port: s32) -> void #foreign libasound;
snd_seq_query_subscribe_set_root :: (info: *snd_seq_query_subscribe_t, addr: *snd_seq_addr_t) -> void #foreign libasound;
snd_seq_query_subscribe_set_type :: (info: *snd_seq_query_subscribe_t, type: snd_seq_query_subs_type_t) -> void #foreign libasound;
snd_seq_query_subscribe_set_index :: (info: *snd_seq_query_subscribe_t, _index: s32) -> void #foreign libasound;

snd_seq_query_port_subscribers :: (seq: *snd_seq_t, subs: *snd_seq_query_subscribe_t) -> s32 #foreign libasound;

_snd_seq_queue_info :: struct {}
/** queue information container */
snd_seq_queue_info_t :: _snd_seq_queue_info;

_snd_seq_queue_status :: struct {}
/** queue status container */
snd_seq_queue_status_t :: _snd_seq_queue_status;

_snd_seq_queue_tempo :: struct {}
/** queue tempo container */
snd_seq_queue_tempo_t :: _snd_seq_queue_tempo;

snd_seq_queue_info_sizeof :: () -> size_t #foreign libasound;

snd_seq_queue_info_malloc :: (ptr: **snd_seq_queue_info_t) -> s32 #foreign libasound;
snd_seq_queue_info_free :: (ptr: *snd_seq_queue_info_t) -> void #foreign libasound;
snd_seq_queue_info_copy :: (dst: *snd_seq_queue_info_t, src: *snd_seq_queue_info_t) -> void #foreign libasound;

snd_seq_queue_info_get_queue :: (info: *snd_seq_queue_info_t) -> s32 #foreign libasound;
snd_seq_queue_info_get_name :: (info: *snd_seq_queue_info_t) -> *u8 #foreign libasound;
snd_seq_queue_info_get_owner :: (info: *snd_seq_queue_info_t) -> s32 #foreign libasound;
snd_seq_queue_info_get_locked :: (info: *snd_seq_queue_info_t) -> s32 #foreign libasound;
snd_seq_queue_info_get_flags :: (info: *snd_seq_queue_info_t) -> u32 #foreign libasound;

snd_seq_queue_info_set_name :: (info: *snd_seq_queue_info_t, name: *u8) -> void #foreign libasound;
snd_seq_queue_info_set_owner :: (info: *snd_seq_queue_info_t, owner: s32) -> void #foreign libasound;
snd_seq_queue_info_set_locked :: (info: *snd_seq_queue_info_t, locked: s32) -> void #foreign libasound;
snd_seq_queue_info_set_flags :: (info: *snd_seq_queue_info_t, flags: u32) -> void #foreign libasound;

snd_seq_create_queue :: (seq: *snd_seq_t, info: *snd_seq_queue_info_t) -> s32 #foreign libasound;
snd_seq_alloc_named_queue :: (seq: *snd_seq_t, name: *u8) -> s32 #foreign libasound;
snd_seq_alloc_queue :: (handle: *snd_seq_t) -> s32 #foreign libasound;
snd_seq_free_queue :: (handle: *snd_seq_t, q: s32) -> s32 #foreign libasound;
snd_seq_get_queue_info :: (seq: *snd_seq_t, q: s32, info: *snd_seq_queue_info_t) -> s32 #foreign libasound;
snd_seq_set_queue_info :: (seq: *snd_seq_t, q: s32, info: *snd_seq_queue_info_t) -> s32 #foreign libasound;
snd_seq_query_named_queue :: (seq: *snd_seq_t, name: *u8) -> s32 #foreign libasound;

snd_seq_get_queue_usage :: (handle: *snd_seq_t, q: s32) -> s32 #foreign libasound;
snd_seq_set_queue_usage :: (handle: *snd_seq_t, q: s32, used: s32) -> s32 #foreign libasound;

/*
*/
snd_seq_queue_status_sizeof :: () -> size_t #foreign libasound;

snd_seq_queue_status_malloc :: (ptr: **snd_seq_queue_status_t) -> s32 #foreign libasound;
snd_seq_queue_status_free :: (ptr: *snd_seq_queue_status_t) -> void #foreign libasound;
snd_seq_queue_status_copy :: (dst: *snd_seq_queue_status_t, src: *snd_seq_queue_status_t) -> void #foreign libasound;

snd_seq_queue_status_get_queue :: (info: *snd_seq_queue_status_t) -> s32 #foreign libasound;
snd_seq_queue_status_get_events :: (info: *snd_seq_queue_status_t) -> s32 #foreign libasound;
snd_seq_queue_status_get_tick_time :: (info: *snd_seq_queue_status_t) -> snd_seq_tick_time_t #foreign libasound;
snd_seq_queue_status_get_real_time :: (info: *snd_seq_queue_status_t) -> *snd_seq_real_time_t #foreign libasound;
snd_seq_queue_status_get_status :: (info: *snd_seq_queue_status_t) -> u32 #foreign libasound;

snd_seq_get_queue_status :: (handle: *snd_seq_t, q: s32, status: *snd_seq_queue_status_t) -> s32 #foreign libasound;

/*
*/
snd_seq_queue_tempo_sizeof :: () -> size_t #foreign libasound;

snd_seq_queue_tempo_malloc :: (ptr: **snd_seq_queue_tempo_t) -> s32 #foreign libasound;
snd_seq_queue_tempo_free :: (ptr: *snd_seq_queue_tempo_t) -> void #foreign libasound;
snd_seq_queue_tempo_copy :: (dst: *snd_seq_queue_tempo_t, src: *snd_seq_queue_tempo_t) -> void #foreign libasound;

snd_seq_queue_tempo_get_queue :: (info: *snd_seq_queue_tempo_t) -> s32 #foreign libasound;
snd_seq_queue_tempo_get_tempo :: (info: *snd_seq_queue_tempo_t) -> u32 #foreign libasound;
snd_seq_queue_tempo_get_ppq :: (info: *snd_seq_queue_tempo_t) -> s32 #foreign libasound;
snd_seq_queue_tempo_get_skew :: (info: *snd_seq_queue_tempo_t) -> u32 #foreign libasound;
snd_seq_queue_tempo_get_skew_base :: (info: *snd_seq_queue_tempo_t) -> u32 #foreign libasound;
snd_seq_queue_tempo_set_tempo :: (info: *snd_seq_queue_tempo_t, tempo: u32) -> void #foreign libasound;
snd_seq_queue_tempo_set_ppq :: (info: *snd_seq_queue_tempo_t, ppq: s32) -> void #foreign libasound;
snd_seq_queue_tempo_set_skew :: (info: *snd_seq_queue_tempo_t, skew: u32) -> void #foreign libasound;
snd_seq_queue_tempo_set_skew_base :: (info: *snd_seq_queue_tempo_t, base: u32) -> void #foreign libasound;

snd_seq_get_queue_tempo :: (handle: *snd_seq_t, q: s32, tempo: *snd_seq_queue_tempo_t) -> s32 #foreign libasound;
snd_seq_set_queue_tempo :: (handle: *snd_seq_t, q: s32, tempo: *snd_seq_queue_tempo_t) -> s32 #foreign libasound;

/**
*  \defgroup SeqEvent Sequencer Event API
*  Sequencer Event API
*  \ingroup Sequencer
*  \{
*/
snd_seq_free_event :: (ev: *snd_seq_event_t) -> s32 #foreign libasound;
snd_seq_event_length :: (ev: *snd_seq_event_t) -> ssize_t #foreign libasound;
snd_seq_event_output :: (handle: *snd_seq_t, ev: *snd_seq_event_t) -> s32 #foreign libasound;
snd_seq_event_output_buffer :: (handle: *snd_seq_t, ev: *snd_seq_event_t) -> s32 #foreign libasound;
snd_seq_event_output_direct :: (handle: *snd_seq_t, ev: *snd_seq_event_t) -> s32 #foreign libasound;
snd_seq_event_input :: (handle: *snd_seq_t, ev: **snd_seq_event_t) -> s32 #foreign libasound;
snd_seq_event_input_pending :: (seq: *snd_seq_t, fetch_sequencer: s32) -> s32 #foreign libasound;
snd_seq_drain_output :: (handle: *snd_seq_t) -> s32 #foreign libasound;
snd_seq_event_output_pending :: (seq: *snd_seq_t) -> s32 #foreign libasound;
snd_seq_extract_output :: (handle: *snd_seq_t, ev: **snd_seq_event_t) -> s32 #foreign libasound;
snd_seq_drop_output :: (handle: *snd_seq_t) -> s32 #foreign libasound;
snd_seq_drop_output_buffer :: (handle: *snd_seq_t) -> s32 #foreign libasound;
snd_seq_drop_input :: (handle: *snd_seq_t) -> s32 #foreign libasound;
snd_seq_drop_input_buffer :: (handle: *snd_seq_t) -> s32 #foreign libasound;

_snd_seq_remove_events :: struct {}
/** event removal conditionals */
snd_seq_remove_events_t :: _snd_seq_remove_events;

snd_seq_remove_events_sizeof :: () -> size_t #foreign libasound;

snd_seq_remove_events_malloc :: (ptr: **snd_seq_remove_events_t) -> s32 #foreign libasound;
snd_seq_remove_events_free :: (ptr: *snd_seq_remove_events_t) -> void #foreign libasound;
snd_seq_remove_events_copy :: (dst: *snd_seq_remove_events_t, src: *snd_seq_remove_events_t) -> void #foreign libasound;

snd_seq_remove_events_get_condition :: (info: *snd_seq_remove_events_t) -> u32 #foreign libasound;
snd_seq_remove_events_get_queue :: (info: *snd_seq_remove_events_t) -> s32 #foreign libasound;
snd_seq_remove_events_get_time :: (info: *snd_seq_remove_events_t) -> *snd_seq_timestamp_t #foreign libasound;
snd_seq_remove_events_get_dest :: (info: *snd_seq_remove_events_t) -> *snd_seq_addr_t #foreign libasound;
snd_seq_remove_events_get_channel :: (info: *snd_seq_remove_events_t) -> s32 #foreign libasound;
snd_seq_remove_events_get_event_type :: (info: *snd_seq_remove_events_t) -> s32 #foreign libasound;
snd_seq_remove_events_get_tag :: (info: *snd_seq_remove_events_t) -> s32 #foreign libasound;

snd_seq_remove_events_set_condition :: (info: *snd_seq_remove_events_t, flags: u32) -> void #foreign libasound;
snd_seq_remove_events_set_queue :: (info: *snd_seq_remove_events_t, queue: s32) -> void #foreign libasound;
snd_seq_remove_events_set_time :: (info: *snd_seq_remove_events_t, time: *snd_seq_timestamp_t) -> void #foreign libasound;
snd_seq_remove_events_set_dest :: (info: *snd_seq_remove_events_t, addr: *snd_seq_addr_t) -> void #foreign libasound;
snd_seq_remove_events_set_channel :: (info: *snd_seq_remove_events_t, channel: s32) -> void #foreign libasound;
snd_seq_remove_events_set_event_type :: (info: *snd_seq_remove_events_t, type: s32) -> void #foreign libasound;
snd_seq_remove_events_set_tag :: (info: *snd_seq_remove_events_t, tag: s32) -> void #foreign libasound;

snd_seq_remove_events :: (handle: *snd_seq_t, info: *snd_seq_remove_events_t) -> s32 #foreign libasound;

/**
*  \defgroup SeqMisc Sequencer Miscellaneous
*  Sequencer Miscellaneous
*  \ingroup Sequencer
*  \{
*/
snd_seq_set_bit :: (nr: s32, array: *void) -> void #foreign libasound;
snd_seq_unset_bit :: (nr: s32, array: *void) -> void #foreign libasound;
snd_seq_change_bit :: (nr: s32, array: *void) -> s32 #foreign libasound;
snd_seq_get_bit :: (nr: s32, array: *void) -> s32 #foreign libasound;

/* event type macros */
SND_SEQ_EVFLG :: enum u32 {
    RESULT     :: 0;
    NOTE       :: 1;
    CONTROL    :: 2;
    QUEUE      :: 3;
    SYSTEM     :: 4;
    MESSAGE    :: 5;
    CONNECTION :: 6;
    SAMPLE     :: 7;
    USERS      :: 8;
    INSTR      :: 9;
    QUOTE      :: 10;
    NONE       :: 11;
    RAW        :: 12;
    FIXED      :: 13;
    VARIABLE   :: 14;
    VARUSR     :: 15;

    SND_SEQ_EVFLG_RESULT     :: RESULT;
    SND_SEQ_EVFLG_NOTE       :: NOTE;
    SND_SEQ_EVFLG_CONTROL    :: CONTROL;
    SND_SEQ_EVFLG_QUEUE      :: QUEUE;
    SND_SEQ_EVFLG_SYSTEM     :: SYSTEM;
    SND_SEQ_EVFLG_MESSAGE    :: MESSAGE;
    SND_SEQ_EVFLG_CONNECTION :: CONNECTION;
    SND_SEQ_EVFLG_SAMPLE     :: SAMPLE;
    SND_SEQ_EVFLG_USERS      :: USERS;
    SND_SEQ_EVFLG_INSTR      :: INSTR;
    SND_SEQ_EVFLG_QUOTE      :: QUOTE;
    SND_SEQ_EVFLG_NONE       :: NONE;
    SND_SEQ_EVFLG_RAW        :: RAW;
    SND_SEQ_EVFLG_FIXED      :: FIXED;
    SND_SEQ_EVFLG_VARIABLE   :: VARIABLE;
    SND_SEQ_EVFLG_VARUSR     :: VARUSR;
}

SND_SEQ_EVFLG_NOTE :: enum u32 {
    ONEARG :: 0;
    TWOARG :: 1;

    SND_SEQ_EVFLG_NOTE_ONEARG :: ONEARG;
    SND_SEQ_EVFLG_NOTE_TWOARG :: TWOARG;
}

SND_SEQ_EVFLG_QUEUE :: enum u32 {
    NOARG :: 0;
    TICK  :: 1;
    TIME  :: 2;
    VALUE :: 3;

    SND_SEQ_EVFLG_QUEUE_NOARG :: NOARG;
    SND_SEQ_EVFLG_QUEUE_TICK  :: TICK;
    SND_SEQ_EVFLG_QUEUE_TIME  :: TIME;
    SND_SEQ_EVFLG_QUEUE_VALUE :: VALUE;
}

/**
* Exported event type table
*
* This table is referred by snd_seq_ev_is_xxx.
*/
snd_seq_event_types: *u32;

/* set and send a queue control event */
snd_seq_control_queue :: (seq: *snd_seq_t, q: s32, type: s32, value: s32, ev: *snd_seq_event_t) -> s32 #foreign libasound;

/* create a port - simple version - return the port number */
snd_seq_create_simple_port :: (seq: *snd_seq_t, name: *u8, caps: u32, type: u32) -> s32 #foreign libasound;

/* delete the port */
snd_seq_delete_simple_port :: (seq: *snd_seq_t, port: s32) -> s32 #foreign libasound;

/* simple subscription between this port and another port
(w/o exclusive & time conversion)
*/
snd_seq_connect_from :: (seq: *snd_seq_t, my_port: s32, src_client: s32, src_port: s32) -> s32 #foreign libasound;
snd_seq_connect_to :: (seq: *snd_seq_t, my_port: s32, dest_client: s32, dest_port: s32) -> s32 #foreign libasound;
snd_seq_disconnect_from :: (seq: *snd_seq_t, my_port: s32, src_client: s32, src_port: s32) -> s32 #foreign libasound;
snd_seq_disconnect_to :: (seq: *snd_seq_t, my_port: s32, dest_client: s32, dest_port: s32) -> s32 #foreign libasound;

/*
* set client information
*/
snd_seq_set_client_name :: (seq: *snd_seq_t, name: *u8) -> s32 #foreign libasound;
snd_seq_set_client_event_filter :: (seq: *snd_seq_t, event_type: s32) -> s32 #foreign libasound;
snd_seq_set_client_pool_output :: (seq: *snd_seq_t, size: size_t) -> s32 #foreign libasound;
snd_seq_set_client_pool_output_room :: (seq: *snd_seq_t, size: size_t) -> s32 #foreign libasound;
snd_seq_set_client_pool_input :: (seq: *snd_seq_t, size: size_t) -> s32 #foreign libasound;

/* sync output queue */
snd_seq_sync_output_queue :: (seq: *snd_seq_t) -> s32 #foreign libasound;

/*
* parse the given string and get the sequencer address
*/
snd_seq_parse_address :: (seq: *snd_seq_t, addr: *snd_seq_addr_t, str: *u8) -> s32 #foreign libasound;

/*
* reset client input/output pool
*/
snd_seq_reset_pool_output :: (seq: *snd_seq_t) -> s32 #foreign libasound;
snd_seq_reset_pool_input :: (seq: *snd_seq_t) -> s32 #foreign libasound;

snd_midi_event :: struct {}
/** container for sequencer midi event parsers */
snd_midi_event_t :: snd_midi_event;

snd_midi_event_new :: (bufsize: size_t, rdev: **snd_midi_event_t) -> s32 #foreign libasound;
snd_midi_event_resize_buffer :: (dev: *snd_midi_event_t, bufsize: size_t) -> s32 #foreign libasound;
snd_midi_event_free :: (dev: *snd_midi_event_t) -> void #foreign libasound;
snd_midi_event_init :: (dev: *snd_midi_event_t) -> void #foreign libasound;
snd_midi_event_reset_encode :: (dev: *snd_midi_event_t) -> void #foreign libasound;
snd_midi_event_reset_decode :: (dev: *snd_midi_event_t) -> void #foreign libasound;
snd_midi_event_no_status :: (dev: *snd_midi_event_t, on: s32) -> void #foreign libasound;

/* encode from byte stream - return number of written bytes if success */
snd_midi_event_encode :: (dev: *snd_midi_event_t, buf: *u8, count: s64, ev: *snd_seq_event_t) -> s64 #foreign libasound;
snd_midi_event_encode_byte :: (dev: *snd_midi_event_t, c: s32, ev: *snd_seq_event_t) -> s32 #foreign libasound;

/* decode from event to bytes - return number of written bytes if success */
snd_midi_event_decode :: (dev: *snd_midi_event_t, buf: *u8, count: s64, ev: *snd_seq_event_t) -> s64 #foreign libasound;

#scope_file

libasound :: #library "../linux/libasound";

#load "../linux/seqmid.jai";

#import "POSIX";
