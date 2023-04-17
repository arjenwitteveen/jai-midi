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

anon_enum :: enum u32 {
    kMIDIInvalidUniqueID :: 0;
}

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

MIDIEventPacket :: struct {
    timeStamp: MIDITimeStamp;
    wordCount: u32;
    words:     [64] u32;
}

MIDIEventList :: struct {
    protocol:   MIDIProtocolID;
    numPackets: u32;
    packet:     [1] MIDIEventPacket;
}

MIDIPacket :: struct {
    timeStamp: MIDITimeStamp;
    length:    u16;
    data:      [256] Byte;
}

MIDIPacketList :: struct {
    numPackets: u32;
    packet:     [1] MIDIPacket #align 4;
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

MIDINotificationMessageID :: s32;
kMIDIMsg :: enum u32 {
    SetupChanged           :: 1;
    ObjectAdded            :: 2;
    ObjectRemoved          :: 3;
    PropertyChanged        :: 4;
    ThruConnectionsChanged :: 5;
    SerialPortOwnerChanged :: 6;
    IOError                :: 7;

    kMIDIMsgSetupChanged           :: SetupChanged;
    kMIDIMsgObjectAdded            :: ObjectAdded;
    kMIDIMsgObjectRemoved          :: ObjectRemoved;
    kMIDIMsgPropertyChanged        :: PropertyChanged;
    kMIDIMsgThruConnectionsChanged :: ThruConnectionsChanged;
    kMIDIMsgSerialPortOwnerChanged :: SerialPortOwnerChanged;
    kMIDIMsgIOError                :: IOError;
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

MIDIReceivedEventList :: (src: MIDIEndpointRef, evtlist: *MIDIEventList) -> OSStatus #foreign coremidi;

MIDIReceived :: (src: MIDIEndpointRef, pktlist: *MIDIPacketList) -> OSStatus #foreign coremidi;

MIDIFlushOutput :: (dest: MIDIEndpointRef) -> OSStatus #foreign coremidi;

MIDIRestart :: () -> OSStatus #foreign coremidi;

MIDIEventListInit :: (evtlist: *MIDIEventList, protocol: MIDIProtocolID) -> *MIDIEventPacket #foreign coremidi;

MIDIEventListAdd :: (evtlist: *MIDIEventList, listSize: ByteCount, curPacket: *MIDIEventPacket, time: MIDITimeStamp, wordCount: ByteCount, words: *u32) -> *MIDIEventPacket #foreign coremidi;

MIDIPacketListInit :: (pktlist: *MIDIPacketList) -> *MIDIPacket #foreign coremidi;

MIDIPacketListAdd :: (pktlist: *MIDIPacketList, listSize: ByteCount, curPacket: *MIDIPacket, time: MIDITimeStamp, nData: ByteCount, data: *Byte) -> *MIDIPacket #foreign coremidi;

MIDISetupRef :: MIDIObjectRef;

MIDISetupCreate :: (outSetup: *MIDISetupRef) -> OSStatus #foreign coremidi;

MIDISetupDispose :: (setup: MIDISetupRef) -> OSStatus #foreign coremidi;

MIDISetupInstall :: (setup: MIDISetupRef) -> OSStatus #foreign coremidi;

MIDISetupGetCurrent :: (outSetup: *MIDISetupRef) -> OSStatus #foreign coremidi;

MIDISetupToData :: (setup: MIDISetupRef, outData: *CFDataRef) -> OSStatus #foreign coremidi;

MIDISetupFromData :: (data: CFDataRef, outSetup: *MIDISetupRef) -> OSStatus #foreign coremidi;

MIDIDeviceNewEntity :: (device: MIDIDeviceRef, name: CFStringRef, protocol: MIDIProtocolID, embedded: Boolean, numSourceEndpoints: ItemCount, numDestinationEndpoints: ItemCount, newEntity: *MIDIEntityRef) -> OSStatus #foreign coremidi;

MIDIDeviceAddEntity :: (device: MIDIDeviceRef, name: CFStringRef, embedded: Boolean, numSourceEndpoints: ItemCount, numDestinationEndpoints: ItemCount, newEntity: *MIDIEntityRef) -> OSStatus #foreign coremidi;

MIDIDeviceRemoveEntity :: (device: MIDIDeviceRef, entity: MIDIEntityRef) -> OSStatus #foreign coremidi;

MIDIEntityAddOrRemoveEndpoints :: (entity: MIDIEntityRef, numSourceEndpoints: ItemCount, numDestinationEndpoints: ItemCount) -> OSStatus #foreign coremidi;

MIDISetupAddDevice :: (device: MIDIDeviceRef) -> OSStatus #foreign coremidi;

MIDISetupRemoveDevice :: (device: MIDIDeviceRef) -> OSStatus #foreign coremidi;

MIDISetupAddExternalDevice :: (device: MIDIDeviceRef) -> OSStatus #foreign coremidi;

MIDISetupRemoveExternalDevice :: (device: MIDIDeviceRef) -> OSStatus #foreign coremidi;

MIDIGetSerialPortOwner :: (portName: CFStringRef, outDriverName: *CFStringRef) -> OSStatus #foreign coremidi;

MIDISetSerialPortOwner :: (portName: CFStringRef, driverName: CFStringRef) -> OSStatus #foreign coremidi;

MIDIGetSerialPortDrivers :: (outDriverNames: *CFArrayRef) -> OSStatus #foreign coremidi;

MIDIExternalDeviceCreate :: (name: CFStringRef, manufacturer: CFStringRef, model: CFStringRef, outDevice: *MIDIDeviceRef) -> OSStatus #foreign coremidi;

MIDIThruConnectionRef :: MIDIObjectRef;

MIDIValueMap :: struct {
    value: [128] u8;
}

MIDITransformType :: u16;
kMIDITransform :: enum u32 {
    None       :: 0;
    FilterOut  :: 1;
    MapControl :: 2;
    Add        :: 8;
    Scale      :: 9;
    MinValue   :: 10;
    MaxValue   :: 11;
    MapValue   :: 12;

    kMIDITransform_None       :: None;
    kMIDITransform_FilterOut  :: FilterOut;
    kMIDITransform_MapControl :: MapControl;
    kMIDITransform_Add        :: Add;
    kMIDITransform_Scale      :: Scale;
    kMIDITransform_MinValue   :: MinValue;
    kMIDITransform_MaxValue   :: MaxValue;
    kMIDITransform_MapValue   :: MapValue;
}

anon_enum_1 :: enum u32 {
    kMIDIThruConnection_MaxEndpoints :: 8;
}

MIDITransformControlType :: u8;
kMIDIControlType :: enum u32 {
    _7Bit      :: 0;
    _14Bit     :: 1;
    _7BitRPN   :: 2;
    _14BitRPN  :: 3;
    _7BitNRPN  :: 4;
    _14BitNRPN :: 5;

    kMIDIControlType_7Bit      :: _7Bit;
    kMIDIControlType_14Bit     :: _14Bit;
    kMIDIControlType_7BitRPN   :: _7BitRPN;
    kMIDIControlType_14BitRPN  :: _14BitRPN;
    kMIDIControlType_7BitNRPN  :: _7BitNRPN;
    kMIDIControlType_14BitNRPN :: _14BitNRPN;
}

MIDITransform :: struct {
    transform: MIDITransformType;
    param:     s16;
}

MIDIControlTransform :: struct {
    controlType:         MIDITransformControlType;
    remappedControlType: MIDITransformControlType;
    controlNumber:       u16;
    transform:           MIDITransformType;
    param:               s16;
}

MIDIThruConnectionEndpoint :: struct {
    endpointRef: MIDIEndpointRef;
    uniqueID:    MIDIUniqueID;
}

MIDIThruConnectionParams :: struct {
    version:              u32;
    numSources:           u32;
    sources:              [8] MIDIThruConnectionEndpoint;
    numDestinations:      u32;
    destinations:         [8] MIDIThruConnectionEndpoint;

    channelMap:           [16] u8;
    lowVelocity:          u8;
    highVelocity:         u8;
    lowNote:              u8;
    highNote:             u8;
    noteNumber:           MIDITransform;
    velocity:             MIDITransform;
    keyPressure:          MIDITransform;
    channelPressure:      MIDITransform;
    programChange:        MIDITransform;
    pitchBend:            MIDITransform;

    filterOutSysEx:       u8;
    filterOutMTC:         u8;
    filterOutBeatClock:   u8;
    filterOutTuneRequest: u8;
    reserved2:            [3] u8;
    filterOutAllControls: u8;

    numControlTransforms: u16;
    numMaps:              u16;
    reserved3:            [4] u16;
}

MIDIThruConnectionParamsInitialize :: (inConnectionParams: *MIDIThruConnectionParams) -> void #foreign coremidi;

MIDIThruConnectionCreate :: (inPersistentOwnerID: CFStringRef, inConnectionParams: CFDataRef, outConnection: *MIDIThruConnectionRef) -> OSStatus #foreign coremidi;

MIDIThruConnectionDispose :: (connection: MIDIThruConnectionRef) -> OSStatus #foreign coremidi;

MIDIThruConnectionGetParams :: (connection: MIDIThruConnectionRef, outConnectionParams: *CFDataRef) -> OSStatus #foreign coremidi;

MIDIThruConnectionSetParams :: (connection: MIDIThruConnectionRef, inConnectionParams: CFDataRef) -> OSStatus #foreign coremidi;

MIDIThruConnectionFind :: (inPersistentOwnerID: CFStringRef, outConnectionList: *CFDataRef) -> OSStatus #foreign coremidi;

MIDIDriverRef :: **MIDIDriverInterface;

MIDIDeviceListRef :: MIDIObjectRef;

MIDIDriverInterface :: struct {
    _reserved:      *void;
    QueryInterface: #type (thisPointer: *void, iid: REFIID, ppv: **void) -> HRESULT #c_call;
    AddRef:         #type (thisPointer: *void) -> u32 #c_call;
    Release:        #type (thisPointer: *void) -> u32 #c_call;

    FindDevices:    #type (self: MIDIDriverRef, devList: MIDIDeviceListRef) -> OSStatus #c_call;

    Start:          #type (self: MIDIDriverRef, devList: MIDIDeviceListRef) -> OSStatus #c_call;

    Stop:           #type (self: MIDIDriverRef) -> OSStatus #c_call;

    Configure:      #type (self: MIDIDriverRef, device: MIDIDeviceRef) -> OSStatus #c_call;

    Send:           #type (self: MIDIDriverRef, pktlist: *MIDIPacketList, destRefCon1: *void, destRefCon2: *void) -> OSStatus #c_call;

    EnableSource:   #type (self: MIDIDriverRef, src: MIDIEndpointRef, enabled: Boolean) -> OSStatus #c_call;

    Flush:          #type (self: MIDIDriverRef, dest: MIDIEndpointRef, destRefCon1: *void, destRefCon2: *void) -> OSStatus #c_call;

    Monitor:        #type (self: MIDIDriverRef, dest: MIDIEndpointRef, pktlist: *MIDIPacketList) -> OSStatus #c_call;

    SendPackets:    #type (self: MIDIDriverRef, pktlist: *MIDIEventList, destRefCon1: *void, destRefCon2: *void) -> OSStatus #c_call;

    MonitorEvents:  #type (self: MIDIDriverRef, dest: MIDIEndpointRef, pktlist: *MIDIEventList) -> OSStatus #c_call;
}

kMIDIDriverPropertyUsesSerial: CFStringRef #elsewhere coremidi;

MIDIDeviceCreate :: (owner: MIDIDriverRef, name: CFStringRef, manufacturer: CFStringRef, model: CFStringRef, outDevice: *MIDIDeviceRef) -> OSStatus #foreign coremidi;

MIDIDeviceDispose :: (device: MIDIDeviceRef) -> OSStatus #foreign coremidi;

MIDIDeviceListGetNumberOfDevices :: (devList: MIDIDeviceListRef) -> ItemCount #foreign coremidi;

MIDIDeviceListGetDevice :: (devList: MIDIDeviceListRef, index0: ItemCount) -> MIDIDeviceRef #foreign coremidi;

MIDIDeviceListAddDevice :: (devList: MIDIDeviceListRef, dev: MIDIDeviceRef) -> OSStatus #foreign coremidi;

MIDIDeviceListDispose :: (devList: MIDIDeviceListRef) -> OSStatus #foreign coremidi;

MIDIEndpointSetRefCons :: (endpt: MIDIEndpointRef, ref1: *void, ref2: *void) -> OSStatus #foreign coremidi;

MIDIEndpointGetRefCons :: (endpt: MIDIEndpointRef, ref1: **void, ref2: **void) -> OSStatus #foreign coremidi;

MIDIGetDriverIORunLoop :: () -> CFRunLoopRef #foreign coremidi;

MIDIGetDriverDeviceList :: (driver: MIDIDriverRef) -> MIDIDeviceListRef #foreign coremidi;

MIDIDriverEnableMonitoring :: (driver: MIDIDriverRef, enabled: Boolean) -> OSStatus #foreign coremidi;

MIDIMessageType :: u32;
kMIDIMessageType :: enum u32 {
    Utility       :: 0;
    System        :: 1;
    ChannelVoice1 :: 2;
    SysEx         :: 3;
    ChannelVoice2 :: 4;
    Data128       :: 5;

    kMIDIMessageTypeUtility       :: Utility;
    kMIDIMessageTypeSystem        :: System;
    kMIDIMessageTypeChannelVoice1 :: ChannelVoice1;
    kMIDIMessageTypeSysEx         :: SysEx;
    kMIDIMessageTypeChannelVoice2 :: ChannelVoice2;
    kMIDIMessageTypeData128       :: Data128;
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
    kMIDIStatusSystemReset      :: SystemReset;
}

MIDISysExStatus :: u32;
kMIDISysExStatus :: enum u32 {
    Complete :: 0;
    Start    :: 1;
    Continue :: 2;
    End      :: 3;

    kMIDISysExStatusComplete :: Complete;
    kMIDISysExStatusStart    :: Start;
    kMIDISysExStatusContinue :: Continue;
    kMIDISysExStatusEnd      :: End;
}

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

#scope_file

libc :: #system_library "libc";
coremidi :: #system_library "CoreMIDI";
