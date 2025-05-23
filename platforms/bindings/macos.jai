//
// This file was auto-generated using the following command:
//
// jai first.jai - generate
//



kMIDI :: enum s32 {
    InvalidClient     :: -10830;
    InvalidPort       :: -10831;
    WrongEndpointType :: -10832;
    NoConnection      :: -10833;
    UnknownEndpoint   :: -10834;
    UnknownProperty   :: -10835;
    WrongPropertyType :: -10836;
    NoCurrentSetup    :: -10837;
    MessageSendErr    :: -10838;
    ServerStartErr    :: -10839;
    SetupFormatErr    :: -10840;
    WrongThread       :: -10841;
    ObjectNotFound    :: -10842;
    IDNotUnique       :: -10843;
    NotPermitted      :: -10844;
    UnknownError      :: -10845;

    kMIDIInvalidClient     :: InvalidClient;
    kMIDIInvalidPort       :: InvalidPort;
    kMIDIWrongEndpointType :: WrongEndpointType;
    kMIDINoConnection      :: NoConnection;
    kMIDIUnknownEndpoint   :: UnknownEndpoint;
    kMIDIUnknownProperty   :: UnknownProperty;
    kMIDIWrongPropertyType :: WrongPropertyType;
    kMIDINoCurrentSetup    :: NoCurrentSetup;
    kMIDIMessageSendErr    :: MessageSendErr;
    kMIDIServerStartErr    :: ServerStartErr;
    kMIDISetupFormatErr    :: SetupFormatErr;
    kMIDIWrongThread       :: WrongThread;
    kMIDIObjectNotFound    :: ObjectNotFound;
    kMIDIIDNotUnique       :: IDNotUnique;
    kMIDINotPermitted      :: NotPermitted;
    kMIDIUnknownError      :: UnknownError;
}

MIDIObjectRef :: u32;

MIDIClientRef :: MIDIObjectRef;

MIDIPortRef :: MIDIObjectRef;

MIDIDeviceRef :: MIDIObjectRef;

MIDIEntityRef :: MIDIObjectRef;

MIDIEndpointRef :: MIDIObjectRef;

MIDITimeStamp :: u64;

MIDIObjectType :: s32;
kMIDIObjectType :: enum s32 {
    Other               :: -1;
    Device              :: 0;
    Entity              :: 1;
    Source              :: 2;
    Destination         :: 3;

    ExternalDevice      :: 16;
    ExternalEntity      :: 17;
    ExternalSource      :: 18;
    ExternalDestination :: 19;

    kMIDIObjectType_Other               :: Other;
    kMIDIObjectType_Device              :: Device;
    kMIDIObjectType_Entity              :: Entity;
    kMIDIObjectType_Source              :: Source;
    kMIDIObjectType_Destination         :: Destination;

    kMIDIObjectType_ExternalDevice      :: ExternalDevice;
    kMIDIObjectType_ExternalEntity      :: ExternalEntity;
    kMIDIObjectType_ExternalSource      :: ExternalSource;
    kMIDIObjectType_ExternalDestination :: ExternalDestination;
}

kMIDIObjectType_ExternalMask: MIDIObjectType : 16;

MIDIUniqueID :: s32;

MIDIProtocolID :: s32;
kMIDIProtocol :: enum u32 {
    _1_0 :: 1;
    _2_0 :: 2;

    kMIDIProtocol_1_0 :: _1_0;
    kMIDIProtocol_2_0 :: _2_0;
}

MIDINotifyProc :: #type (message: *MIDINotification, refCon: *void) -> void #c_call;

MIDINotifyBlock :: Block;

MIDIReceiveBlock :: Block;

MIDIReadProc :: #type (pktlist: *MIDIPacketList, readProcRefCon: *void, srcConnRefCon: *void) -> void #c_call;

MIDIReadBlock :: Block;

MIDICompletionProc :: #type (request: *MIDISysexSendRequest) -> void #c_call;

MIDICompletionProcUMP :: #type (request: *MIDISysexSendRequestUMP) -> void #c_call;

MIDIEventPacket :: struct {
    timeStamp: MIDITimeStamp #align 4;
    wordCount: u32;
    words:     [64] u32;
}

MIDIEventList :: struct {
    protocol:   MIDIProtocolID;
    numPackets: u32;
    packet:     [1] MIDIEventPacket;
}

MIDIPacket :: struct {
    timeStamp: MIDITimeStamp #align 4;
    length:    u16;
    data:      [256] Byte;
}

MIDIPacketList :: struct {
    numPackets: u32;
    packet:     [1] MIDIPacket;
}

MIDISysexSendRequest :: struct {
    destination:      MIDIEndpointRef;
    data:             *Byte;
    bytesToSend:      u32;
    complete:         Boolean;
    reserved:         [3] Byte;
    completionProc:   MIDICompletionProc;
    completionRefCon: *void;
}

MIDISysexSendRequestUMP :: struct {
    destination:      MIDIEndpointRef;
    words:            *u32;
    wordsToSend:      u32;
    complete:         Boolean;
    completionProc:   MIDICompletionProcUMP;
    completionRefCon: *void;
}

MIDINotificationMessageID :: s32;
kMIDIMsg :: enum u32 {
    SetupChanged           :: 1;
    ObjectAdded            :: 2;
    ObjectRemoved          :: 3;
    PropertyChanged        :: 4;
    ThruConnectionsChanged :: 5;
    SerialPortOwnerChanged :: 6;
    IOError                :: 7;
    InternalStart          :: 4096;

    kMIDIMsgSetupChanged           :: SetupChanged;
    kMIDIMsgObjectAdded            :: ObjectAdded;
    kMIDIMsgObjectRemoved          :: ObjectRemoved;
    kMIDIMsgPropertyChanged        :: PropertyChanged;
    kMIDIMsgThruConnectionsChanged :: ThruConnectionsChanged;
    kMIDIMsgSerialPortOwnerChanged :: SerialPortOwnerChanged;
    kMIDIMsgIOError                :: IOError;
    kMIDIMsgInternalStart          :: InternalStart;
}

MIDINotification :: struct {
    messageID:   MIDINotificationMessageID;
    messageSize: u32;
}

MIDIObjectAddRemoveNotification :: struct {
    messageID:   MIDINotificationMessageID;
    messageSize: u32;
    parent:      MIDIObjectRef;
    parentType:  MIDIObjectType;
    child:       MIDIObjectRef;
    childType:   MIDIObjectType;
}

MIDIObjectPropertyChangeNotification :: struct {
    messageID:    MIDINotificationMessageID;
    messageSize:  u32;
    object:       MIDIObjectRef;
    objectType:   MIDIObjectType;
    propertyName: CFStringRef;
}

MIDIIOErrorNotification :: struct {
    messageID:    MIDINotificationMessageID;
    messageSize:  u32;
    driverDevice: MIDIDeviceRef;
    errorCode:    OSStatus;
}

kMIDIPropertyName: CFStringRef #elsewhere coremidi;

kMIDIPropertyManufacturer: CFStringRef #elsewhere coremidi;

kMIDIPropertyModel: CFStringRef #elsewhere coremidi;

kMIDIPropertyUniqueID: CFStringRef #elsewhere coremidi;

kMIDIPropertyDeviceID: CFStringRef #elsewhere coremidi;

kMIDIPropertyReceiveChannels: CFStringRef #elsewhere coremidi;

kMIDIPropertyTransmitChannels: CFStringRef #elsewhere coremidi;

kMIDIPropertyMaxSysExSpeed: CFStringRef #elsewhere coremidi;

kMIDIPropertyAdvanceScheduleTimeMuSec: CFStringRef #elsewhere coremidi;

kMIDIPropertyIsEmbeddedEntity: CFStringRef #elsewhere coremidi;

kMIDIPropertyIsBroadcast: CFStringRef #elsewhere coremidi;

kMIDIPropertySingleRealtimeEntity: CFStringRef #elsewhere coremidi;

kMIDIPropertyConnectionUniqueID: CFStringRef #elsewhere coremidi;

kMIDIPropertyOffline: CFStringRef #elsewhere coremidi;

kMIDIPropertyPrivate: CFStringRef #elsewhere coremidi;

kMIDIPropertyDriverOwner: CFStringRef #elsewhere coremidi;

kMIDIPropertyFactoryPatchNameFile: CFStringRef #elsewhere coremidi;

kMIDIPropertyUserPatchNameFile: CFStringRef #elsewhere coremidi;

kMIDIPropertyNameConfiguration: CFStringRef #elsewhere coremidi;

kMIDIPropertyNameConfigurationDictionary: CFStringRef #elsewhere coremidi;

kMIDIPropertyImage: CFStringRef #elsewhere coremidi;

kMIDIPropertyDriverVersion: CFStringRef #elsewhere coremidi;

kMIDIPropertySupportsGeneralMIDI: CFStringRef #elsewhere coremidi;

kMIDIPropertySupportsMMC: CFStringRef #elsewhere coremidi;

kMIDIPropertyCanRoute: CFStringRef #elsewhere coremidi;

kMIDIPropertyReceivesClock: CFStringRef #elsewhere coremidi;

kMIDIPropertyReceivesMTC: CFStringRef #elsewhere coremidi;

kMIDIPropertyReceivesNotes: CFStringRef #elsewhere coremidi;

kMIDIPropertyReceivesProgramChanges: CFStringRef #elsewhere coremidi;

kMIDIPropertyReceivesBankSelectMSB: CFStringRef #elsewhere coremidi;

kMIDIPropertyReceivesBankSelectLSB: CFStringRef #elsewhere coremidi;

kMIDIPropertyTransmitsClock: CFStringRef #elsewhere coremidi;

kMIDIPropertyTransmitsMTC: CFStringRef #elsewhere coremidi;

kMIDIPropertyTransmitsNotes: CFStringRef #elsewhere coremidi;

kMIDIPropertyTransmitsProgramChanges: CFStringRef #elsewhere coremidi;

kMIDIPropertyTransmitsBankSelectMSB: CFStringRef #elsewhere coremidi;

kMIDIPropertyTransmitsBankSelectLSB: CFStringRef #elsewhere coremidi;

kMIDIPropertyPanDisruptsStereo: CFStringRef #elsewhere coremidi;

kMIDIPropertyIsSampler: CFStringRef #elsewhere coremidi;

kMIDIPropertyIsDrumMachine: CFStringRef #elsewhere coremidi;

kMIDIPropertyIsMixer: CFStringRef #elsewhere coremidi;

kMIDIPropertyIsEffectUnit: CFStringRef #elsewhere coremidi;

kMIDIPropertyMaxReceiveChannels: CFStringRef #elsewhere coremidi;

kMIDIPropertyMaxTransmitChannels: CFStringRef #elsewhere coremidi;

kMIDIPropertyDriverDeviceEditorApp: CFStringRef #elsewhere coremidi;

kMIDIPropertySupportsShowControl: CFStringRef #elsewhere coremidi;

kMIDIPropertyDisplayName: CFStringRef #elsewhere coremidi;

kMIDIPropertyProtocolID: CFStringRef #elsewhere coremidi;

kMIDIPropertyUMPActiveGroupBitmap: CFStringRef #elsewhere coremidi;

kMIDIPropertyUMPCanTransmitGroupless: CFStringRef #elsewhere coremidi;

kMIDIPropertyAssociatedEndpoint: CFStringRef #elsewhere coremidi;

MIDIClientCreate :: (name: CFStringRef, notifyProc: MIDINotifyProc, notifyRefCon: *void, outClient: *MIDIClientRef) -> OSStatus #foreign coremidi;

MIDIClientCreateWithBlock :: (name: CFStringRef, outClient: *MIDIClientRef, notifyBlock: MIDINotifyBlock) -> OSStatus #foreign coremidi;

MIDIClientDispose :: (client: MIDIClientRef) -> OSStatus #foreign coremidi;

MIDIInputPortCreateWithProtocol :: (client: MIDIClientRef, portName: CFStringRef, protocol: MIDIProtocolID, outPort: *MIDIPortRef, receiveBlock: MIDIReceiveBlock) -> OSStatus #foreign coremidi;

MIDIInputPortCreate :: (client: MIDIClientRef, portName: CFStringRef, readProc: MIDIReadProc, refCon: *void, outPort: *MIDIPortRef) -> OSStatus #foreign coremidi;

MIDIInputPortCreateWithBlock :: (client: MIDIClientRef, portName: CFStringRef, outPort: *MIDIPortRef, readBlock: MIDIReadBlock) -> OSStatus #foreign coremidi;

MIDIOutputPortCreate :: (client: MIDIClientRef, portName: CFStringRef, outPort: *MIDIPortRef) -> OSStatus #foreign coremidi;

MIDIPortDispose :: (port: MIDIPortRef) -> OSStatus #foreign coremidi;

MIDIPortConnectSource :: (port: MIDIPortRef, source: MIDIEndpointRef, connRefCon: *void) -> OSStatus #foreign coremidi;

MIDIPortDisconnectSource :: (port: MIDIPortRef, source: MIDIEndpointRef) -> OSStatus #foreign coremidi;

MIDIGetNumberOfDevices :: () -> ItemCount #foreign coremidi;

MIDIGetDevice :: (deviceIndex0: ItemCount) -> MIDIDeviceRef #foreign coremidi;

MIDIDeviceGetNumberOfEntities :: (device: MIDIDeviceRef) -> ItemCount #foreign coremidi;

MIDIDeviceGetEntity :: (device: MIDIDeviceRef, entityIndex0: ItemCount) -> MIDIEntityRef #foreign coremidi;

MIDIEntityGetNumberOfSources :: (entity: MIDIEntityRef) -> ItemCount #foreign coremidi;

MIDIEntityGetSource :: (entity: MIDIEntityRef, sourceIndex0: ItemCount) -> MIDIEndpointRef #foreign coremidi;

MIDIEntityGetNumberOfDestinations :: (entity: MIDIEntityRef) -> ItemCount #foreign coremidi;

MIDIEntityGetDestination :: (entity: MIDIEntityRef, destIndex0: ItemCount) -> MIDIEndpointRef #foreign coremidi;

MIDIEntityGetDevice :: (inEntity: MIDIEntityRef, outDevice: *MIDIDeviceRef) -> OSStatus #foreign coremidi;

MIDIGetNumberOfSources :: () -> ItemCount #foreign coremidi;

MIDIGetSource :: (sourceIndex0: ItemCount) -> MIDIEndpointRef #foreign coremidi;

MIDIGetNumberOfDestinations :: () -> ItemCount #foreign coremidi;

MIDIGetDestination :: (destIndex0: ItemCount) -> MIDIEndpointRef #foreign coremidi;

MIDIEndpointGetEntity :: (inEndpoint: MIDIEndpointRef, outEntity: *MIDIEntityRef) -> OSStatus #foreign coremidi;

MIDIDestinationCreateWithProtocol :: (client: MIDIClientRef, name: CFStringRef, protocol: MIDIProtocolID, outDest: *MIDIEndpointRef, readBlock: MIDIReceiveBlock) -> OSStatus #foreign coremidi;

MIDIDestinationCreate :: (client: MIDIClientRef, name: CFStringRef, readProc: MIDIReadProc, refCon: *void, outDest: *MIDIEndpointRef) -> OSStatus #foreign coremidi;

MIDIDestinationCreateWithBlock :: (client: MIDIClientRef, name: CFStringRef, outDest: *MIDIEndpointRef, readBlock: MIDIReadBlock) -> OSStatus #foreign coremidi;

MIDISourceCreateWithProtocol :: (client: MIDIClientRef, name: CFStringRef, protocol: MIDIProtocolID, outSrc: *MIDIEndpointRef) -> OSStatus #foreign coremidi;

MIDISourceCreate :: (client: MIDIClientRef, name: CFStringRef, outSrc: *MIDIEndpointRef) -> OSStatus #foreign coremidi;

MIDIEndpointDispose :: (endpt: MIDIEndpointRef) -> OSStatus #foreign coremidi;

MIDIGetNumberOfExternalDevices :: () -> ItemCount #foreign coremidi;

MIDIGetExternalDevice :: (deviceIndex0: ItemCount) -> MIDIDeviceRef #foreign coremidi;

MIDIObjectGetIntegerProperty :: (obj: MIDIObjectRef, propertyID: CFStringRef, outValue: *s32) -> OSStatus #foreign coremidi;

MIDIObjectSetIntegerProperty :: (obj: MIDIObjectRef, propertyID: CFStringRef, value: s32) -> OSStatus #foreign coremidi;

MIDIObjectGetStringProperty :: (obj: MIDIObjectRef, propertyID: CFStringRef, str: *CFStringRef) -> OSStatus #foreign coremidi;

MIDIObjectSetStringProperty :: (obj: MIDIObjectRef, propertyID: CFStringRef, str: CFStringRef) -> OSStatus #foreign coremidi;

MIDIObjectGetDataProperty :: (obj: MIDIObjectRef, propertyID: CFStringRef, outData: *CFDataRef) -> OSStatus #foreign coremidi;

MIDIObjectSetDataProperty :: (obj: MIDIObjectRef, propertyID: CFStringRef, data: CFDataRef) -> OSStatus #foreign coremidi;

MIDIObjectGetDictionaryProperty :: (obj: MIDIObjectRef, propertyID: CFStringRef, outDict: *CFDictionaryRef) -> OSStatus #foreign coremidi;

MIDIObjectSetDictionaryProperty :: (obj: MIDIObjectRef, propertyID: CFStringRef, dict: CFDictionaryRef) -> OSStatus #foreign coremidi;

MIDIObjectGetProperties :: (obj: MIDIObjectRef, outProperties: *CFPropertyListRef, deep: Boolean) -> OSStatus #foreign coremidi;

MIDIObjectRemoveProperty :: (obj: MIDIObjectRef, propertyID: CFStringRef) -> OSStatus #foreign coremidi;

MIDIObjectFindByUniqueID :: (inUniqueID: MIDIUniqueID, outObject: *MIDIObjectRef, outObjectType: *MIDIObjectType) -> OSStatus #foreign coremidi;

MIDISendEventList :: (port: MIDIPortRef, dest: MIDIEndpointRef, evtlist: *MIDIEventList) -> OSStatus #foreign coremidi;

MIDISend :: (port: MIDIPortRef, dest: MIDIEndpointRef, pktlist: *MIDIPacketList) -> OSStatus #foreign coremidi;

MIDISendSysex :: (request: *MIDISysexSendRequest) -> OSStatus #foreign coremidi;

MIDISendUMPSysex :: (umpRequest: *MIDISysexSendRequestUMP) -> OSStatus #foreign coremidi;

MIDISendUMPSysex8 :: (umpRequest: *MIDISysexSendRequestUMP) -> OSStatus #foreign coremidi;

MIDIEventPacketSysexBytesForGroup :: (pkt: *MIDIEventPacket, groupIndex: u8, outData: *CFDataRef) -> OSStatus #foreign coremidi;

MIDIReceivedEventList :: (src: MIDIEndpointRef, evtlist: *MIDIEventList) -> OSStatus #foreign coremidi;

MIDIReceived :: (src: MIDIEndpointRef, pktlist: *MIDIPacketList) -> OSStatus #foreign coremidi;

MIDIFlushOutput :: (dest: MIDIEndpointRef) -> OSStatus #foreign coremidi;

MIDIRestart :: () -> OSStatus #foreign coremidi;

MIDIEventListInit :: (evtlist: *MIDIEventList, protocol: MIDIProtocolID) -> *MIDIEventPacket #foreign coremidi;

MIDIEventListAdd :: (evtlist: *MIDIEventList, listSize: ByteCount, curPacket: *MIDIEventPacket, time: MIDITimeStamp, wordCount: ByteCount, words: *u32) -> *MIDIEventPacket #foreign coremidi;

MIDIPacketListInit :: (pktlist: *MIDIPacketList) -> *MIDIPacket #foreign coremidi;

MIDIPacketListAdd :: (pktlist: *MIDIPacketList, listSize: ByteCount, curPacket: *MIDIPacket, time: MIDITimeStamp, nData: ByteCount, data: *Byte) -> *MIDIPacket #foreign coremidi;

MIDIMessageType :: u32;
kMIDIMessageType :: enum u32 {
    Utility       :: 0;
    System        :: 1;
    ChannelVoice1 :: 2;
    SysEx         :: 3;
    ChannelVoice2 :: 4;
    Data128       :: 5;
    FlexData      :: 13;
    UnknownF      :: 15;
    Stream        :: 15;

    Invalid       :: 255;

    kMIDIMessageTypeUtility       :: Utility;
    kMIDIMessageTypeSystem        :: System;
    kMIDIMessageTypeChannelVoice1 :: ChannelVoice1;
    kMIDIMessageTypeSysEx         :: SysEx;
    kMIDIMessageTypeChannelVoice2 :: ChannelVoice2;
    kMIDIMessageTypeData128       :: Data128;
    kMIDIMessageTypeFlexData      :: FlexData;
    kMIDIMessageTypeUnknownF      :: UnknownF;
    kMIDIMessageTypeStream        :: Stream;

    kMIDIMessageTypeInvalid       :: Invalid;
}

MIDICVStatus :: u32;
kMIDICVStatus :: enum u32 {
    NoteOff              :: 8;
    NoteOn               :: 9;
    PolyPressure         :: 10;
    ControlChange        :: 11;
    ProgramChange        :: 12;
    ChannelPressure      :: 13;
    PitchBend            :: 14;

    RegisteredPNC        :: 0;
    AssignablePNC        :: 1;
    RegisteredControl    :: 2;
    AssignableControl    :: 3;
    RelRegisteredControl :: 4;
    RelAssignableControl :: 5;
    PerNotePitchBend     :: 6;
    PerNoteMgmt          :: 15;

    kMIDICVStatusNoteOff              :: NoteOff;
    kMIDICVStatusNoteOn               :: NoteOn;
    kMIDICVStatusPolyPressure         :: PolyPressure;
    kMIDICVStatusControlChange        :: ControlChange;
    kMIDICVStatusProgramChange        :: ProgramChange;
    kMIDICVStatusChannelPressure      :: ChannelPressure;
    kMIDICVStatusPitchBend            :: PitchBend;

    kMIDICVStatusRegisteredPNC        :: RegisteredPNC;
    kMIDICVStatusAssignablePNC        :: AssignablePNC;
    kMIDICVStatusRegisteredControl    :: RegisteredControl;
    kMIDICVStatusAssignableControl    :: AssignableControl;
    kMIDICVStatusRelRegisteredControl :: RelRegisteredControl;
    kMIDICVStatusRelAssignableControl :: RelAssignableControl;
    kMIDICVStatusPerNotePitchBend     :: PerNotePitchBend;
    kMIDICVStatusPerNoteMgmt          :: PerNoteMgmt;
}

MIDISystemStatus :: u32;
kMIDIStatus :: enum u32 {
    StartOfExclusive :: 240;
    EndOfExclusive   :: 247;

    MTC              :: 241;
    SongPosPointer   :: 242;
    SongSelect       :: 243;
    TuneRequest      :: 246;

    TimingClock      :: 248;
    Start            :: 250;
    Continue         :: 251;
    Stop             :: 252;
    ActiveSending    :: 254;
    ActiveSensing    :: 254;
    SystemReset      :: 255;

    kMIDIStatusStartOfExclusive :: StartOfExclusive;
    kMIDIStatusEndOfExclusive   :: EndOfExclusive;

    kMIDIStatusMTC              :: MTC;
    kMIDIStatusSongPosPointer   :: SongPosPointer;
    kMIDIStatusSongSelect       :: SongSelect;
    kMIDIStatusTuneRequest      :: TuneRequest;

    kMIDIStatusTimingClock      :: TimingClock;
    kMIDIStatusStart            :: Start;
    kMIDIStatusContinue         :: Continue;
    kMIDIStatusStop             :: Stop;
    kMIDIStatusActiveSending    :: ActiveSending;
    kMIDIStatusActiveSensing    :: ActiveSensing;
    kMIDIStatusSystemReset      :: SystemReset;
}

MIDISysExStatus :: u32;
kMIDISysExStatus :: enum u32 {
    Complete            :: 0;
    Start               :: 1;
    Continue            :: 2;
    End                 :: 3;

    MixedDataSetHeader  :: 8;
    MixedDataSetPayload :: 9;

    kMIDISysExStatusComplete            :: Complete;
    kMIDISysExStatusStart               :: Start;
    kMIDISysExStatusContinue            :: Continue;
    kMIDISysExStatusEnd                 :: End;

    kMIDISysExStatusMixedDataSetHeader  :: MixedDataSetHeader;
    kMIDISysExStatusMixedDataSetPayload :: MixedDataSetPayload;
}

MIDIUtilityStatus :: u32;
kMIDIUtilityStatus :: enum u32 {
    NOOP                               :: 0;
    JitterReductionClock               :: 1;
    JitterReductionTimestamp           :: 2;
    DeltaClockstampTicksPerQuarterNote :: 3;
    TicksSinceLastEvent                :: 4;

    kMIDIUtilityStatusNOOP                               :: NOOP;
    kMIDIUtilityStatusJitterReductionClock               :: JitterReductionClock;
    kMIDIUtilityStatusJitterReductionTimestamp           :: JitterReductionTimestamp;
    kMIDIUtilityStatusDeltaClockstampTicksPerQuarterNote :: DeltaClockstampTicksPerQuarterNote;
    kMIDIUtilityStatusTicksSinceLastEvent                :: TicksSinceLastEvent;
}

UMPStreamMessageStatus :: u32;
kUMPStreamMessageStatus :: enum u32 {
    EndpointDiscovery               :: 0;
    EndpointInfoNotification        :: 1;
    DeviceIdentityNotification      :: 2;
    EndpointNameNotification        :: 3;
    ProductInstanceIDNotification   :: 4;
    StreamConfigurationRequest      :: 5;
    StreamConfigurationNotification :: 6;
    FunctionBlockDiscovery          :: 16;
    FunctionBlockInfoNotification   :: 17;
    FunctionBlockNameNotification   :: 18;
    StartOfClip                     :: 32;
    EndOfClip                       :: 33;

    kUMPStreamMessageStatusEndpointDiscovery               :: EndpointDiscovery;
    kUMPStreamMessageStatusEndpointInfoNotification        :: EndpointInfoNotification;
    kUMPStreamMessageStatusDeviceIdentityNotification      :: DeviceIdentityNotification;
    kUMPStreamMessageStatusEndpointNameNotification        :: EndpointNameNotification;
    kUMPStreamMessageStatusProductInstanceIDNotification   :: ProductInstanceIDNotification;
    kUMPStreamMessageStatusStreamConfigurationRequest      :: StreamConfigurationRequest;
    kUMPStreamMessageStatusStreamConfigurationNotification :: StreamConfigurationNotification;
    kUMPStreamMessageStatusFunctionBlockDiscovery          :: FunctionBlockDiscovery;
    kUMPStreamMessageStatusFunctionBlockInfoNotification   :: FunctionBlockInfoNotification;
    kUMPStreamMessageStatusFunctionBlockNameNotification   :: FunctionBlockNameNotification;
    kUMPStreamMessageStatusStartOfClip                     :: StartOfClip;
    kUMPStreamMessageStatusEndOfClip                       :: EndOfClip;
}

MIDINoteAttribute :: u8;
kMIDINoteAttribute :: enum u32 {
    None                 :: 0;
    ManufacturerSpecific :: 1;
    ProfileSpecific      :: 2;
    Pitch                :: 3;

    kMIDINoteAttributeNone                 :: None;
    kMIDINoteAttributeManufacturerSpecific :: ManufacturerSpecific;
    kMIDINoteAttributeProfileSpecific      :: ProfileSpecific;
    kMIDINoteAttributePitch                :: Pitch;
}

MIDIProgramChangeOptions :: u8;
anon_enum_12 :: enum u32 {
    kMIDIProgramChangeBankValid :: 1;
}

MIDIPerNoteManagementOptions :: u8;
kMIDIPerNoteManagement :: enum u32 {
    Reset  :: 1;
    Detach :: 2;

    kMIDIPerNoteManagementReset  :: Reset;
    kMIDIPerNoteManagementDetach :: Detach;
}

MIDIUMPFunctionBlockMIDI1Info :: s32;
kMIDIUMPFunctionBlockMIDI1Info :: enum u32 {
    NotMIDI1              :: 0;
    UnrestrictedBandwidth :: 1;
    RestrictedBandwidth   :: 2;

    kMIDIUMPFunctionBlockMIDI1InfoNotMIDI1              :: NotMIDI1;
    kMIDIUMPFunctionBlockMIDI1InfoUnrestrictedBandwidth :: UnrestrictedBandwidth;
    kMIDIUMPFunctionBlockMIDI1InfoRestrictedBandwidth   :: RestrictedBandwidth;
}

MIDIUMPFunctionBlockUIHint :: s32;
kMIDIUMPFunctionBlockUIHint :: enum u32 {
    Unknown        :: 0;
    Receiver       :: 1;
    Sender         :: 2;
    SenderReceiver :: 3;

    kMIDIUMPFunctionBlockUIHintUnknown        :: Unknown;
    kMIDIUMPFunctionBlockUIHintReceiver       :: Receiver;
    kMIDIUMPFunctionBlockUIHintSender         :: Sender;
    kMIDIUMPFunctionBlockUIHintSenderReceiver :: SenderReceiver;
}

MIDIUMPFunctionBlockDirection :: s32;
kMIDIUMPFunctionBlockDirection :: enum u32 {
    Unknown       :: 0;
    Input         :: 1;
    Output        :: 2;
    Bidirectional :: 3;

    kMIDIUMPFunctionBlockDirectionUnknown       :: Unknown;
    kMIDIUMPFunctionBlockDirectionInput         :: Input;
    kMIDIUMPFunctionBlockDirectionOutput        :: Output;
    kMIDIUMPFunctionBlockDirectionBidirectional :: Bidirectional;
}

UMPStreamMessageFormat :: u8;
kUMPStreamMessageFormat :: enum u32 {
    Complete   :: 0;
    Start      :: 1;
    Continuing :: 2;
    End        :: 3;

    kUMPStreamMessageFormatComplete   :: Complete;
    kUMPStreamMessageFormatStart      :: Start;
    kUMPStreamMessageFormatContinuing :: Continuing;
    kUMPStreamMessageFormatEnd        :: End;
}

MIDIUInteger2 :: u8;
MIDIUInteger4 :: u8;
MIDIUInteger7 :: u8;
MIDIUInteger14 :: u16;
MIDIUInteger28 :: u32;

kMIDIUInteger2Max: MIDIUInteger2 : 3;
kMIDIUInteger4Max: MIDIUInteger4 : 15;
kMIDIUInteger7Max: MIDIUInteger7 : 127;
kMIDIUInteger14Max: MIDIUInteger14 : 16383;
kMIDIUInteger28Max: MIDIUInteger28 : 268435455;

MIDIUMPGroupNumber :: MIDIUInteger4;

MIDIChannelNumber :: MIDIUInteger4;

MIDICIDeviceID :: MIDIUInteger7;

kMIDIDeviceIDUMPGroup: MIDICIDeviceID : 126;

kMIDIDeviceIDFunctionBlock: MIDICIDeviceID : 127;

MIDICIMUID :: MIDIUInteger28;

MIDIMessage_32 :: u32;

MIDIMessage_64 :: struct {
    word0: u32;
    word1: u32;
}

MIDIMessage_96 :: struct {
    word0: u32;
    word1: u32;
    word2: u32;
}

MIDIMessage_128 :: struct {
    word0: u32;
    word1: u32;
    word2: u32;
    word3: u32;
}

kMIDI1UPMaxSysexSize: u8 : 6;

MIDIUniversalMessage :: struct {
    type:     MIDIMessageType;
    group:    u8;
    reserved: [3] u8;

    union {
        utility:       struct {
            status: MIDIUtilityStatus;
            union {
                jitterReductionClock:     u16;
                jitterReductionTimestamp: u16;
            }
        };

        system:        struct {
            status: MIDISystemStatus;
            union {
                timeCode:            u8;
                songPositionPointer: u16;
                songSelect:          u8;
            }
        };

        channelVoice1: struct {
            status:   MIDICVStatus;
            channel:  u8;
            reserved: [3] u8;
            union {
                note:            struct {
                    number:   u8;
                    velocity: u8;
                };

                polyPressure:    struct {
                    noteNumber: u8;
                    pressure:   u8;
                };

                controlChange:   struct {
                    index: u8;
                    data:  u8;
                };

                program:         u8;
                channelPressure: u8;
                pitchBend:       u16;
            }
        };

        sysEx:         struct {
            status:   MIDISysExStatus;
            channel:  u8;
            data:     [6] u8;
            reserved: u8;
        };

        channelVoice2: struct {
            status:   MIDICVStatus;
            channel:  u8;
            reserved: [3] u8;
            union {
                note:              struct {
                    number:        u8;
                    attributeType: MIDINoteAttribute;
                    velocity:      u16;
                    attribute:     u16;
                };

                polyPressure:      struct {
                    noteNumber: u8;
                    reserved:   u8;
                    pressure:   u32;
                };

                controlChange:     struct {
                    index:    u8;
                    reserved: u8;
                    data:     u32;
                };

                programChange:     struct {
                    options:  MIDIProgramChangeOptions;
                    program:  u8;
                    reserved: [2] u8;
                    bank:     u16;
                };

                channelPressure:   struct {
                    data:     u32;
                    reserved: [2] u8;
                };

                pitchBend:         struct {
                    data:     u32;
                    reserved: [2] u8;
                };

                perNoteController: struct {
                    noteNumber: u8;
                    index:      u8;
                    data:       u32;
                };

                controller:        struct {
                    bank:  u8;
                    index: u8;
                    data:  u32;
                };

                perNotePitchBend:  struct {
                    noteNumber: u8;
                    reserved:   u8;
                    bend:       u32;
                };

                perNoteManagement: struct {
                    note:     u8;
                    options:  MIDIPerNoteManagementOptions;
                    reserved: [4] u8;
                };
            }
        };

        data128:       struct {
            status: MIDISysExStatus;
            union {
                sysex8:       struct {
                    byteCount: u8;
                    streamID:  u8;
                    data:      [13] u8;
                    reserved:  u8;
                };

                mixedDataSet: struct {
                    mdsID:    u8;
                    data:     [14] u8;
                    reserved: u8;
                };
            }
        };

        unknown:       struct {
            words: [4] u32;
        };
    }
}

MIDIEventVisitor :: #type (_context: *void, timeStamp: MIDITimeStamp, message: MIDIUniversalMessage) -> void #c_call;

MIDIEventListForEachEvent :: (evtlist: *MIDIEventList, visitor: MIDIEventVisitor, visitorContext: *void) -> void #foreign coremidi;

mach_timebase_info :: struct {
    numer: u32;
    denom: u32;
}

mach_timebase_info_t :: *mach_timebase_info;
mach_timebase_info_data_t :: mach_timebase_info;

mach_timebase_info_ :: (info: mach_timebase_info_t) -> kern_return_t #foreign libc "mach_timebase_info";

mach_wait_until :: (deadline: u64) -> kern_return_t #foreign libc;

mach_absolute_time :: () -> u64 #foreign libc;

mach_approximate_time :: () -> u64 #foreign libc;

/*
* like mach_absolute_time, but advances during sleep
*/
mach_continuous_time :: () -> u64 #foreign libc;

/*
* like mach_approximate_time, but advances during sleep
*/
mach_continuous_approximate_time :: () -> u64 #foreign libc;

#scope_file

#import "Basic"; // For assert

libc :: #library,system "libc";
coremidi :: #library,system "CoreMIDI";

#run {
    {
        info := type_info(MIDIEventPacket);
        for info.members {
            if it.name == {
                case "timeStamp";
                    assert(it.offset_in_bytes == 0, "MIDIEventPacket.timeStamp has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "MIDIEventPacket.timeStamp has unexpected size % instead of 8", it.type.runtime_size);
                case "wordCount";
                    assert(it.offset_in_bytes == 8, "MIDIEventPacket.wordCount has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIEventPacket.wordCount has unexpected size % instead of 4", it.type.runtime_size);
                case "words";
                    assert(it.offset_in_bytes == 12, "MIDIEventPacket.words has unexpected offset % instead of 12", it.offset_in_bytes);
                    assert(it.type.runtime_size == 256, "MIDIEventPacket.words has unexpected size % instead of 256", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIEventPacket) == 268, "MIDIEventPacket has size % instead of 268", size_of(MIDIEventPacket));
    }

    {
        info := type_info(MIDIEventList);
        for info.members {
            if it.name == {
                case "protocol";
                    assert(it.offset_in_bytes == 0, "MIDIEventList.protocol has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIEventList.protocol has unexpected size % instead of 4", it.type.runtime_size);
                case "numPackets";
                    assert(it.offset_in_bytes == 4, "MIDIEventList.numPackets has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIEventList.numPackets has unexpected size % instead of 4", it.type.runtime_size);
                case "packet";
                    assert(it.offset_in_bytes == 8, "MIDIEventList.packet has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 268, "MIDIEventList.packet has unexpected size % instead of 268", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIEventList) == 276, "MIDIEventList has size % instead of 276", size_of(MIDIEventList));
    }

    {
        info := type_info(MIDIPacket);
        for info.members {
            if it.name == {
                case "timeStamp";
                    assert(it.offset_in_bytes == 0, "MIDIPacket.timeStamp has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "MIDIPacket.timeStamp has unexpected size % instead of 8", it.type.runtime_size);
                case "length";
                    assert(it.offset_in_bytes == 8, "MIDIPacket.length has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 2, "MIDIPacket.length has unexpected size % instead of 2", it.type.runtime_size);
                case "data";
                    assert(it.offset_in_bytes == 10, "MIDIPacket.data has unexpected offset % instead of 10", it.offset_in_bytes);
                    assert(it.type.runtime_size == 256, "MIDIPacket.data has unexpected size % instead of 256", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIPacket) == 268, "MIDIPacket has size % instead of 268", size_of(MIDIPacket));
    }

    {
        info := type_info(MIDIPacketList);
        for info.members {
            if it.name == {
                case "numPackets";
                    assert(it.offset_in_bytes == 0, "MIDIPacketList.numPackets has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIPacketList.numPackets has unexpected size % instead of 4", it.type.runtime_size);
                case "packet";
                    assert(it.offset_in_bytes == 4, "MIDIPacketList.packet has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 268, "MIDIPacketList.packet has unexpected size % instead of 268", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIPacketList) == 272, "MIDIPacketList has size % instead of 272", size_of(MIDIPacketList));
    }

    {
        info := type_info(MIDISysexSendRequest);
        for info.members {
            if it.name == {
                case "destination";
                    assert(it.offset_in_bytes == 0, "MIDISysexSendRequest.destination has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDISysexSendRequest.destination has unexpected size % instead of 4", it.type.runtime_size);
                case "data";
                    assert(it.offset_in_bytes == 8, "MIDISysexSendRequest.data has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "MIDISysexSendRequest.data has unexpected size % instead of 8", it.type.runtime_size);
                case "bytesToSend";
                    assert(it.offset_in_bytes == 16, "MIDISysexSendRequest.bytesToSend has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDISysexSendRequest.bytesToSend has unexpected size % instead of 4", it.type.runtime_size);
                case "complete";
                    assert(it.offset_in_bytes == 20, "MIDISysexSendRequest.complete has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 1, "MIDISysexSendRequest.complete has unexpected size % instead of 1", it.type.runtime_size);
                case "reserved";
                    assert(it.offset_in_bytes == 21, "MIDISysexSendRequest.reserved has unexpected offset % instead of 21", it.offset_in_bytes);
                    assert(it.type.runtime_size == 3, "MIDISysexSendRequest.reserved has unexpected size % instead of 3", it.type.runtime_size);
                case "completionProc";
                    assert(it.offset_in_bytes == 24, "MIDISysexSendRequest.completionProc has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "MIDISysexSendRequest.completionProc has unexpected size % instead of 8", it.type.runtime_size);
                case "completionRefCon";
                    assert(it.offset_in_bytes == 32, "MIDISysexSendRequest.completionRefCon has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "MIDISysexSendRequest.completionRefCon has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(MIDISysexSendRequest) == 40, "MIDISysexSendRequest has size % instead of 40", size_of(MIDISysexSendRequest));
    }

    {
        info := type_info(MIDISysexSendRequestUMP);
        for info.members {
            if it.name == {
                case "destination";
                    assert(it.offset_in_bytes == 0, "MIDISysexSendRequestUMP.destination has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDISysexSendRequestUMP.destination has unexpected size % instead of 4", it.type.runtime_size);
                case "words";
                    assert(it.offset_in_bytes == 8, "MIDISysexSendRequestUMP.words has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "MIDISysexSendRequestUMP.words has unexpected size % instead of 8", it.type.runtime_size);
                case "wordsToSend";
                    assert(it.offset_in_bytes == 16, "MIDISysexSendRequestUMP.wordsToSend has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDISysexSendRequestUMP.wordsToSend has unexpected size % instead of 4", it.type.runtime_size);
                case "complete";
                    assert(it.offset_in_bytes == 20, "MIDISysexSendRequestUMP.complete has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 1, "MIDISysexSendRequestUMP.complete has unexpected size % instead of 1", it.type.runtime_size);
                case "completionProc";
                    assert(it.offset_in_bytes == 24, "MIDISysexSendRequestUMP.completionProc has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "MIDISysexSendRequestUMP.completionProc has unexpected size % instead of 8", it.type.runtime_size);
                case "completionRefCon";
                    assert(it.offset_in_bytes == 32, "MIDISysexSendRequestUMP.completionRefCon has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "MIDISysexSendRequestUMP.completionRefCon has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(MIDISysexSendRequestUMP) == 40, "MIDISysexSendRequestUMP has size % instead of 40", size_of(MIDISysexSendRequestUMP));
    }

    {
        info := type_info(MIDINotification);
        for info.members {
            if it.name == {
                case "messageID";
                    assert(it.offset_in_bytes == 0, "MIDINotification.messageID has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDINotification.messageID has unexpected size % instead of 4", it.type.runtime_size);
                case "messageSize";
                    assert(it.offset_in_bytes == 4, "MIDINotification.messageSize has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDINotification.messageSize has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(MIDINotification) == 8, "MIDINotification has size % instead of 8", size_of(MIDINotification));
    }

    {
        info := type_info(MIDIObjectAddRemoveNotification);
        for info.members {
            if it.name == {
                case "messageID";
                    assert(it.offset_in_bytes == 0, "MIDIObjectAddRemoveNotification.messageID has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIObjectAddRemoveNotification.messageID has unexpected size % instead of 4", it.type.runtime_size);
                case "messageSize";
                    assert(it.offset_in_bytes == 4, "MIDIObjectAddRemoveNotification.messageSize has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIObjectAddRemoveNotification.messageSize has unexpected size % instead of 4", it.type.runtime_size);
                case "parent";
                    assert(it.offset_in_bytes == 8, "MIDIObjectAddRemoveNotification.parent has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIObjectAddRemoveNotification.parent has unexpected size % instead of 4", it.type.runtime_size);
                case "parentType";
                    assert(it.offset_in_bytes == 12, "MIDIObjectAddRemoveNotification.parentType has unexpected offset % instead of 12", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIObjectAddRemoveNotification.parentType has unexpected size % instead of 4", it.type.runtime_size);
                case "child";
                    assert(it.offset_in_bytes == 16, "MIDIObjectAddRemoveNotification.child has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIObjectAddRemoveNotification.child has unexpected size % instead of 4", it.type.runtime_size);
                case "childType";
                    assert(it.offset_in_bytes == 20, "MIDIObjectAddRemoveNotification.childType has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIObjectAddRemoveNotification.childType has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIObjectAddRemoveNotification) == 24, "MIDIObjectAddRemoveNotification has size % instead of 24", size_of(MIDIObjectAddRemoveNotification));
    }

    {
        info := type_info(MIDIObjectPropertyChangeNotification);
        for info.members {
            if it.name == {
                case "messageID";
                    assert(it.offset_in_bytes == 0, "MIDIObjectPropertyChangeNotification.messageID has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIObjectPropertyChangeNotification.messageID has unexpected size % instead of 4", it.type.runtime_size);
                case "messageSize";
                    assert(it.offset_in_bytes == 4, "MIDIObjectPropertyChangeNotification.messageSize has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIObjectPropertyChangeNotification.messageSize has unexpected size % instead of 4", it.type.runtime_size);
                case "object";
                    assert(it.offset_in_bytes == 8, "MIDIObjectPropertyChangeNotification.object has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIObjectPropertyChangeNotification.object has unexpected size % instead of 4", it.type.runtime_size);
                case "objectType";
                    assert(it.offset_in_bytes == 12, "MIDIObjectPropertyChangeNotification.objectType has unexpected offset % instead of 12", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIObjectPropertyChangeNotification.objectType has unexpected size % instead of 4", it.type.runtime_size);
                case "propertyName";
                    assert(it.offset_in_bytes == 16, "MIDIObjectPropertyChangeNotification.propertyName has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "MIDIObjectPropertyChangeNotification.propertyName has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIObjectPropertyChangeNotification) == 24, "MIDIObjectPropertyChangeNotification has size % instead of 24", size_of(MIDIObjectPropertyChangeNotification));
    }

    {
        info := type_info(MIDIIOErrorNotification);
        for info.members {
            if it.name == {
                case "messageID";
                    assert(it.offset_in_bytes == 0, "MIDIIOErrorNotification.messageID has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIIOErrorNotification.messageID has unexpected size % instead of 4", it.type.runtime_size);
                case "messageSize";
                    assert(it.offset_in_bytes == 4, "MIDIIOErrorNotification.messageSize has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIIOErrorNotification.messageSize has unexpected size % instead of 4", it.type.runtime_size);
                case "driverDevice";
                    assert(it.offset_in_bytes == 8, "MIDIIOErrorNotification.driverDevice has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIIOErrorNotification.driverDevice has unexpected size % instead of 4", it.type.runtime_size);
                case "errorCode";
                    assert(it.offset_in_bytes == 12, "MIDIIOErrorNotification.errorCode has unexpected offset % instead of 12", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIIOErrorNotification.errorCode has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIIOErrorNotification) == 16, "MIDIIOErrorNotification has size % instead of 16", size_of(MIDIIOErrorNotification));
    }

    {
        info := type_info(MIDIMessage_64);
        for info.members {
            if it.name == {
                case "word0";
                    assert(it.offset_in_bytes == 0, "MIDIMessage_64.word0 has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIMessage_64.word0 has unexpected size % instead of 4", it.type.runtime_size);
                case "word1";
                    assert(it.offset_in_bytes == 4, "MIDIMessage_64.word1 has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIMessage_64.word1 has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIMessage_64) == 8, "MIDIMessage_64 has size % instead of 8", size_of(MIDIMessage_64));
    }

    {
        info := type_info(MIDIMessage_96);
        for info.members {
            if it.name == {
                case "word0";
                    assert(it.offset_in_bytes == 0, "MIDIMessage_96.word0 has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIMessage_96.word0 has unexpected size % instead of 4", it.type.runtime_size);
                case "word1";
                    assert(it.offset_in_bytes == 4, "MIDIMessage_96.word1 has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIMessage_96.word1 has unexpected size % instead of 4", it.type.runtime_size);
                case "word2";
                    assert(it.offset_in_bytes == 8, "MIDIMessage_96.word2 has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIMessage_96.word2 has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIMessage_96) == 12, "MIDIMessage_96 has size % instead of 12", size_of(MIDIMessage_96));
    }

    {
        info := type_info(MIDIMessage_128);
        for info.members {
            if it.name == {
                case "word0";
                    assert(it.offset_in_bytes == 0, "MIDIMessage_128.word0 has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIMessage_128.word0 has unexpected size % instead of 4", it.type.runtime_size);
                case "word1";
                    assert(it.offset_in_bytes == 4, "MIDIMessage_128.word1 has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIMessage_128.word1 has unexpected size % instead of 4", it.type.runtime_size);
                case "word2";
                    assert(it.offset_in_bytes == 8, "MIDIMessage_128.word2 has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIMessage_128.word2 has unexpected size % instead of 4", it.type.runtime_size);
                case "word3";
                    assert(it.offset_in_bytes == 12, "MIDIMessage_128.word3 has unexpected offset % instead of 12", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIMessage_128.word3 has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIMessage_128) == 16, "MIDIMessage_128 has size % instead of 16", size_of(MIDIMessage_128));
    }

    {
        info := type_info(MIDIUniversalMessage);
        for info.members {
            if it.name == {
                case "type";
                    assert(it.offset_in_bytes == 0, "MIDIUniversalMessage.type has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "MIDIUniversalMessage.type has unexpected size % instead of 4", it.type.runtime_size);
                case "group";
                    assert(it.offset_in_bytes == 4, "MIDIUniversalMessage.group has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 1, "MIDIUniversalMessage.group has unexpected size % instead of 1", it.type.runtime_size);
                case "reserved";
                    assert(it.offset_in_bytes == 5, "MIDIUniversalMessage.reserved has unexpected offset % instead of 5", it.offset_in_bytes);
                    assert(it.type.runtime_size == 3, "MIDIUniversalMessage.reserved has unexpected size % instead of 3", it.type.runtime_size);
            }
        }
        assert(size_of(MIDIUniversalMessage) == 28, "MIDIUniversalMessage has size % instead of 28", size_of(MIDIUniversalMessage));
    }

    {
        info := type_info(mach_timebase_info);
        for info.members {
            if it.name == {
                case "numer";
                    assert(it.offset_in_bytes == 0, "mach_timebase_info.numer has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "mach_timebase_info.numer has unexpected size % instead of 4", it.type.runtime_size);
                case "denom";
                    assert(it.offset_in_bytes == 4, "mach_timebase_info.denom has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "mach_timebase_info.denom has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(mach_timebase_info) == 8, "mach_timebase_info has size % instead of 8", size_of(mach_timebase_info));
    }
}


#scope_export

kMIDIInvalidUniqueID : MIDIUniqueID : 0;

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

