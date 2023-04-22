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
    timeStamp: MIDITimeStamp #align 4;
    wordCount: u32;
    words:     [64] u32;
}
#run {
    instance: MIDIEventPacket;
    assert(((cast(*void)(*instance.timeStamp)) - cast(*void)(*instance)) == 0, "MIDIEventPacket.timeStamp has unexpected offset % instead of 0", ((cast(*void)(*instance.timeStamp)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIEventPacket.timeStamp)) == 8, "MIDIEventPacket.timeStamp has unexpected size % instead of 8", size_of(type_of(MIDIEventPacket.timeStamp)));
    assert(((cast(*void)(*instance.wordCount)) - cast(*void)(*instance)) == 8, "MIDIEventPacket.wordCount has unexpected offset % instead of 8", ((cast(*void)(*instance.wordCount)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIEventPacket.wordCount)) == 4, "MIDIEventPacket.wordCount has unexpected size % instead of 4", size_of(type_of(MIDIEventPacket.wordCount)));
    assert(((cast(*void)(*instance.words)) - cast(*void)(*instance)) == 12, "MIDIEventPacket.words has unexpected offset % instead of 12", ((cast(*void)(*instance.words)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIEventPacket.words)) == 256, "MIDIEventPacket.words has unexpected size % instead of 256", size_of(type_of(MIDIEventPacket.words)));
    assert(size_of(MIDIEventPacket) == 268, "MIDIEventPacket has size % instead of 268", size_of(MIDIEventPacket));
}

MIDIEventList :: struct {
    protocol:   MIDIProtocolID;
    numPackets: u32;
    packet:     [1] MIDIEventPacket;
}
#run {
    instance: MIDIEventList;
    assert(((cast(*void)(*instance.protocol)) - cast(*void)(*instance)) == 0, "MIDIEventList.protocol has unexpected offset % instead of 0", ((cast(*void)(*instance.protocol)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIEventList.protocol)) == 4, "MIDIEventList.protocol has unexpected size % instead of 4", size_of(type_of(MIDIEventList.protocol)));
    assert(((cast(*void)(*instance.numPackets)) - cast(*void)(*instance)) == 4, "MIDIEventList.numPackets has unexpected offset % instead of 4", ((cast(*void)(*instance.numPackets)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIEventList.numPackets)) == 4, "MIDIEventList.numPackets has unexpected size % instead of 4", size_of(type_of(MIDIEventList.numPackets)));
    assert(((cast(*void)(*instance.packet)) - cast(*void)(*instance)) == 8, "MIDIEventList.packet has unexpected offset % instead of 8", ((cast(*void)(*instance.packet)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIEventList.packet)) == 268, "MIDIEventList.packet has unexpected size % instead of 268", size_of(type_of(MIDIEventList.packet)));
    assert(size_of(MIDIEventList) == 276, "MIDIEventList has size % instead of 276", size_of(MIDIEventList));
}

MIDIPacket :: struct {
    timeStamp: MIDITimeStamp #align 4;
    length:    u16;
    data:      [256] Byte;
}
#run {
    instance: MIDIPacket;
    assert(((cast(*void)(*instance.timeStamp)) - cast(*void)(*instance)) == 0, "MIDIPacket.timeStamp has unexpected offset % instead of 0", ((cast(*void)(*instance.timeStamp)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIPacket.timeStamp)) == 8, "MIDIPacket.timeStamp has unexpected size % instead of 8", size_of(type_of(MIDIPacket.timeStamp)));
    assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 8, "MIDIPacket.length has unexpected offset % instead of 8", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIPacket.length)) == 2, "MIDIPacket.length has unexpected size % instead of 2", size_of(type_of(MIDIPacket.length)));
    assert(((cast(*void)(*instance.data)) - cast(*void)(*instance)) == 10, "MIDIPacket.data has unexpected offset % instead of 10", ((cast(*void)(*instance.data)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIPacket.data)) == 256, "MIDIPacket.data has unexpected size % instead of 256", size_of(type_of(MIDIPacket.data)));
    assert(size_of(MIDIPacket) == 268, "MIDIPacket has size % instead of 268", size_of(MIDIPacket));
}

MIDIPacketList :: struct {
    numPackets: u32;
    packet:     [1] MIDIPacket #align 4;
}
#run {
    instance: MIDIPacketList;
    assert(((cast(*void)(*instance.numPackets)) - cast(*void)(*instance)) == 0, "MIDIPacketList.numPackets has unexpected offset % instead of 0", ((cast(*void)(*instance.numPackets)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIPacketList.numPackets)) == 4, "MIDIPacketList.numPackets has unexpected size % instead of 4", size_of(type_of(MIDIPacketList.numPackets)));
    assert(((cast(*void)(*instance.packet)) - cast(*void)(*instance)) == 4, "MIDIPacketList.packet has unexpected offset % instead of 4", ((cast(*void)(*instance.packet)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIPacketList.packet)) == 268, "MIDIPacketList.packet has unexpected size % instead of 268", size_of(type_of(MIDIPacketList.packet)));
    assert(size_of(MIDIPacketList) == 272, "MIDIPacketList has size % instead of 272", size_of(MIDIPacketList));
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
#run {
    instance: MIDISysexSendRequest;
    assert(((cast(*void)(*instance.destination)) - cast(*void)(*instance)) == 0, "MIDISysexSendRequest.destination has unexpected offset % instead of 0", ((cast(*void)(*instance.destination)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDISysexSendRequest.destination)) == 4, "MIDISysexSendRequest.destination has unexpected size % instead of 4", size_of(type_of(MIDISysexSendRequest.destination)));
    assert(((cast(*void)(*instance.data)) - cast(*void)(*instance)) == 8, "MIDISysexSendRequest.data has unexpected offset % instead of 8", ((cast(*void)(*instance.data)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDISysexSendRequest.data)) == 8, "MIDISysexSendRequest.data has unexpected size % instead of 8", size_of(type_of(MIDISysexSendRequest.data)));
    assert(((cast(*void)(*instance.bytesToSend)) - cast(*void)(*instance)) == 16, "MIDISysexSendRequest.bytesToSend has unexpected offset % instead of 16", ((cast(*void)(*instance.bytesToSend)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDISysexSendRequest.bytesToSend)) == 4, "MIDISysexSendRequest.bytesToSend has unexpected size % instead of 4", size_of(type_of(MIDISysexSendRequest.bytesToSend)));
    assert(((cast(*void)(*instance.complete)) - cast(*void)(*instance)) == 20, "MIDISysexSendRequest.complete has unexpected offset % instead of 20", ((cast(*void)(*instance.complete)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDISysexSendRequest.complete)) == 1, "MIDISysexSendRequest.complete has unexpected size % instead of 1", size_of(type_of(MIDISysexSendRequest.complete)));
    assert(((cast(*void)(*instance.reserved)) - cast(*void)(*instance)) == 21, "MIDISysexSendRequest.reserved has unexpected offset % instead of 21", ((cast(*void)(*instance.reserved)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDISysexSendRequest.reserved)) == 3, "MIDISysexSendRequest.reserved has unexpected size % instead of 3", size_of(type_of(MIDISysexSendRequest.reserved)));
    assert(((cast(*void)(*instance.completionProc)) - cast(*void)(*instance)) == 24, "MIDISysexSendRequest.completionProc has unexpected offset % instead of 24", ((cast(*void)(*instance.completionProc)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDISysexSendRequest.completionProc)) == 8, "MIDISysexSendRequest.completionProc has unexpected size % instead of 8", size_of(type_of(MIDISysexSendRequest.completionProc)));
    assert(((cast(*void)(*instance.completionRefCon)) - cast(*void)(*instance)) == 32, "MIDISysexSendRequest.completionRefCon has unexpected offset % instead of 32", ((cast(*void)(*instance.completionRefCon)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDISysexSendRequest.completionRefCon)) == 8, "MIDISysexSendRequest.completionRefCon has unexpected size % instead of 8", size_of(type_of(MIDISysexSendRequest.completionRefCon)));
    assert(size_of(MIDISysexSendRequest) == 40, "MIDISysexSendRequest has size % instead of 40", size_of(MIDISysexSendRequest));
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
#run {
    instance: MIDINotification;
    assert(((cast(*void)(*instance.messageID)) - cast(*void)(*instance)) == 0, "MIDINotification.messageID has unexpected offset % instead of 0", ((cast(*void)(*instance.messageID)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDINotification.messageID)) == 4, "MIDINotification.messageID has unexpected size % instead of 4", size_of(type_of(MIDINotification.messageID)));
    assert(((cast(*void)(*instance.messageSize)) - cast(*void)(*instance)) == 4, "MIDINotification.messageSize has unexpected offset % instead of 4", ((cast(*void)(*instance.messageSize)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDINotification.messageSize)) == 4, "MIDINotification.messageSize has unexpected size % instead of 4", size_of(type_of(MIDINotification.messageSize)));
    assert(size_of(MIDINotification) == 8, "MIDINotification has size % instead of 8", size_of(MIDINotification));
}

MIDIObjectAddRemoveNotification :: struct {
    messageID:   MIDINotificationMessageID;
    messageSize: u32;
    parent:      MIDIObjectRef;
    parentType:  MIDIObjectType;
    child:       MIDIObjectRef;
    childType:   MIDIObjectType;
}
#run {
    instance: MIDIObjectAddRemoveNotification;
    assert(((cast(*void)(*instance.messageID)) - cast(*void)(*instance)) == 0, "MIDIObjectAddRemoveNotification.messageID has unexpected offset % instead of 0", ((cast(*void)(*instance.messageID)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectAddRemoveNotification.messageID)) == 4, "MIDIObjectAddRemoveNotification.messageID has unexpected size % instead of 4", size_of(type_of(MIDIObjectAddRemoveNotification.messageID)));
    assert(((cast(*void)(*instance.messageSize)) - cast(*void)(*instance)) == 4, "MIDIObjectAddRemoveNotification.messageSize has unexpected offset % instead of 4", ((cast(*void)(*instance.messageSize)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectAddRemoveNotification.messageSize)) == 4, "MIDIObjectAddRemoveNotification.messageSize has unexpected size % instead of 4", size_of(type_of(MIDIObjectAddRemoveNotification.messageSize)));
    assert(((cast(*void)(*instance.parent)) - cast(*void)(*instance)) == 8, "MIDIObjectAddRemoveNotification.parent has unexpected offset % instead of 8", ((cast(*void)(*instance.parent)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectAddRemoveNotification.parent)) == 4, "MIDIObjectAddRemoveNotification.parent has unexpected size % instead of 4", size_of(type_of(MIDIObjectAddRemoveNotification.parent)));
    assert(((cast(*void)(*instance.parentType)) - cast(*void)(*instance)) == 12, "MIDIObjectAddRemoveNotification.parentType has unexpected offset % instead of 12", ((cast(*void)(*instance.parentType)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectAddRemoveNotification.parentType)) == 4, "MIDIObjectAddRemoveNotification.parentType has unexpected size % instead of 4", size_of(type_of(MIDIObjectAddRemoveNotification.parentType)));
    assert(((cast(*void)(*instance.child)) - cast(*void)(*instance)) == 16, "MIDIObjectAddRemoveNotification.child has unexpected offset % instead of 16", ((cast(*void)(*instance.child)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectAddRemoveNotification.child)) == 4, "MIDIObjectAddRemoveNotification.child has unexpected size % instead of 4", size_of(type_of(MIDIObjectAddRemoveNotification.child)));
    assert(((cast(*void)(*instance.childType)) - cast(*void)(*instance)) == 20, "MIDIObjectAddRemoveNotification.childType has unexpected offset % instead of 20", ((cast(*void)(*instance.childType)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectAddRemoveNotification.childType)) == 4, "MIDIObjectAddRemoveNotification.childType has unexpected size % instead of 4", size_of(type_of(MIDIObjectAddRemoveNotification.childType)));
    assert(size_of(MIDIObjectAddRemoveNotification) == 24, "MIDIObjectAddRemoveNotification has size % instead of 24", size_of(MIDIObjectAddRemoveNotification));
}

MIDIObjectPropertyChangeNotification :: struct {
    messageID:    MIDINotificationMessageID;
    messageSize:  u32;
    object:       MIDIObjectRef;
    objectType:   MIDIObjectType;
    propertyName: CFStringRef;
}
#run {
    instance: MIDIObjectPropertyChangeNotification;
    assert(((cast(*void)(*instance.messageID)) - cast(*void)(*instance)) == 0, "MIDIObjectPropertyChangeNotification.messageID has unexpected offset % instead of 0", ((cast(*void)(*instance.messageID)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectPropertyChangeNotification.messageID)) == 4, "MIDIObjectPropertyChangeNotification.messageID has unexpected size % instead of 4", size_of(type_of(MIDIObjectPropertyChangeNotification.messageID)));
    assert(((cast(*void)(*instance.messageSize)) - cast(*void)(*instance)) == 4, "MIDIObjectPropertyChangeNotification.messageSize has unexpected offset % instead of 4", ((cast(*void)(*instance.messageSize)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectPropertyChangeNotification.messageSize)) == 4, "MIDIObjectPropertyChangeNotification.messageSize has unexpected size % instead of 4", size_of(type_of(MIDIObjectPropertyChangeNotification.messageSize)));
    assert(((cast(*void)(*instance.object)) - cast(*void)(*instance)) == 8, "MIDIObjectPropertyChangeNotification.object has unexpected offset % instead of 8", ((cast(*void)(*instance.object)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectPropertyChangeNotification.object)) == 4, "MIDIObjectPropertyChangeNotification.object has unexpected size % instead of 4", size_of(type_of(MIDIObjectPropertyChangeNotification.object)));
    assert(((cast(*void)(*instance.objectType)) - cast(*void)(*instance)) == 12, "MIDIObjectPropertyChangeNotification.objectType has unexpected offset % instead of 12", ((cast(*void)(*instance.objectType)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectPropertyChangeNotification.objectType)) == 4, "MIDIObjectPropertyChangeNotification.objectType has unexpected size % instead of 4", size_of(type_of(MIDIObjectPropertyChangeNotification.objectType)));
    assert(((cast(*void)(*instance.propertyName)) - cast(*void)(*instance)) == 16, "MIDIObjectPropertyChangeNotification.propertyName has unexpected offset % instead of 16", ((cast(*void)(*instance.propertyName)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIObjectPropertyChangeNotification.propertyName)) == 8, "MIDIObjectPropertyChangeNotification.propertyName has unexpected size % instead of 8", size_of(type_of(MIDIObjectPropertyChangeNotification.propertyName)));
    assert(size_of(MIDIObjectPropertyChangeNotification) == 24, "MIDIObjectPropertyChangeNotification has size % instead of 24", size_of(MIDIObjectPropertyChangeNotification));
}

MIDIIOErrorNotification :: struct {
    messageID:    MIDINotificationMessageID;
    messageSize:  u32;
    driverDevice: MIDIDeviceRef;
    errorCode:    OSStatus;
}
#run {
    instance: MIDIIOErrorNotification;
    assert(((cast(*void)(*instance.messageID)) - cast(*void)(*instance)) == 0, "MIDIIOErrorNotification.messageID has unexpected offset % instead of 0", ((cast(*void)(*instance.messageID)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIIOErrorNotification.messageID)) == 4, "MIDIIOErrorNotification.messageID has unexpected size % instead of 4", size_of(type_of(MIDIIOErrorNotification.messageID)));
    assert(((cast(*void)(*instance.messageSize)) - cast(*void)(*instance)) == 4, "MIDIIOErrorNotification.messageSize has unexpected offset % instead of 4", ((cast(*void)(*instance.messageSize)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIIOErrorNotification.messageSize)) == 4, "MIDIIOErrorNotification.messageSize has unexpected size % instead of 4", size_of(type_of(MIDIIOErrorNotification.messageSize)));
    assert(((cast(*void)(*instance.driverDevice)) - cast(*void)(*instance)) == 8, "MIDIIOErrorNotification.driverDevice has unexpected offset % instead of 8", ((cast(*void)(*instance.driverDevice)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIIOErrorNotification.driverDevice)) == 4, "MIDIIOErrorNotification.driverDevice has unexpected size % instead of 4", size_of(type_of(MIDIIOErrorNotification.driverDevice)));
    assert(((cast(*void)(*instance.errorCode)) - cast(*void)(*instance)) == 12, "MIDIIOErrorNotification.errorCode has unexpected offset % instead of 12", ((cast(*void)(*instance.errorCode)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIIOErrorNotification.errorCode)) == 4, "MIDIIOErrorNotification.errorCode has unexpected size % instead of 4", size_of(type_of(MIDIIOErrorNotification.errorCode)));
    assert(size_of(MIDIIOErrorNotification) == 16, "MIDIIOErrorNotification has size % instead of 16", size_of(MIDIIOErrorNotification));
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
#run {
    instance: MIDIValueMap;
    assert(((cast(*void)(*instance.value)) - cast(*void)(*instance)) == 0, "MIDIValueMap.value has unexpected offset % instead of 0", ((cast(*void)(*instance.value)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIValueMap.value)) == 128, "MIDIValueMap.value has unexpected size % instead of 128", size_of(type_of(MIDIValueMap.value)));
    assert(size_of(MIDIValueMap) == 128, "MIDIValueMap has size % instead of 128", size_of(MIDIValueMap));
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
#run {
    instance: MIDITransform;
    assert(((cast(*void)(*instance.transform)) - cast(*void)(*instance)) == 0, "MIDITransform.transform has unexpected offset % instead of 0", ((cast(*void)(*instance.transform)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDITransform.transform)) == 2, "MIDITransform.transform has unexpected size % instead of 2", size_of(type_of(MIDITransform.transform)));
    assert(((cast(*void)(*instance.param)) - cast(*void)(*instance)) == 2, "MIDITransform.param has unexpected offset % instead of 2", ((cast(*void)(*instance.param)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDITransform.param)) == 2, "MIDITransform.param has unexpected size % instead of 2", size_of(type_of(MIDITransform.param)));
    assert(size_of(MIDITransform) == 4, "MIDITransform has size % instead of 4", size_of(MIDITransform));
}

MIDIControlTransform :: struct {
    controlType:         MIDITransformControlType;
    remappedControlType: MIDITransformControlType;
    controlNumber:       u16;
    transform:           MIDITransformType;
    param:               s16;
}
#run {
    instance: MIDIControlTransform;
    assert(((cast(*void)(*instance.controlType)) - cast(*void)(*instance)) == 0, "MIDIControlTransform.controlType has unexpected offset % instead of 0", ((cast(*void)(*instance.controlType)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIControlTransform.controlType)) == 1, "MIDIControlTransform.controlType has unexpected size % instead of 1", size_of(type_of(MIDIControlTransform.controlType)));
    assert(((cast(*void)(*instance.remappedControlType)) - cast(*void)(*instance)) == 1, "MIDIControlTransform.remappedControlType has unexpected offset % instead of 1", ((cast(*void)(*instance.remappedControlType)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIControlTransform.remappedControlType)) == 1, "MIDIControlTransform.remappedControlType has unexpected size % instead of 1", size_of(type_of(MIDIControlTransform.remappedControlType)));
    assert(((cast(*void)(*instance.controlNumber)) - cast(*void)(*instance)) == 2, "MIDIControlTransform.controlNumber has unexpected offset % instead of 2", ((cast(*void)(*instance.controlNumber)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIControlTransform.controlNumber)) == 2, "MIDIControlTransform.controlNumber has unexpected size % instead of 2", size_of(type_of(MIDIControlTransform.controlNumber)));
    assert(((cast(*void)(*instance.transform)) - cast(*void)(*instance)) == 4, "MIDIControlTransform.transform has unexpected offset % instead of 4", ((cast(*void)(*instance.transform)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIControlTransform.transform)) == 2, "MIDIControlTransform.transform has unexpected size % instead of 2", size_of(type_of(MIDIControlTransform.transform)));
    assert(((cast(*void)(*instance.param)) - cast(*void)(*instance)) == 6, "MIDIControlTransform.param has unexpected offset % instead of 6", ((cast(*void)(*instance.param)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIControlTransform.param)) == 2, "MIDIControlTransform.param has unexpected size % instead of 2", size_of(type_of(MIDIControlTransform.param)));
    assert(size_of(MIDIControlTransform) == 8, "MIDIControlTransform has size % instead of 8", size_of(MIDIControlTransform));
}

MIDIThruConnectionEndpoint :: struct {
    endpointRef: MIDIEndpointRef;
    uniqueID:    MIDIUniqueID;
}
#run {
    instance: MIDIThruConnectionEndpoint;
    assert(((cast(*void)(*instance.endpointRef)) - cast(*void)(*instance)) == 0, "MIDIThruConnectionEndpoint.endpointRef has unexpected offset % instead of 0", ((cast(*void)(*instance.endpointRef)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionEndpoint.endpointRef)) == 4, "MIDIThruConnectionEndpoint.endpointRef has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionEndpoint.endpointRef)));
    assert(((cast(*void)(*instance.uniqueID)) - cast(*void)(*instance)) == 4, "MIDIThruConnectionEndpoint.uniqueID has unexpected offset % instead of 4", ((cast(*void)(*instance.uniqueID)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionEndpoint.uniqueID)) == 4, "MIDIThruConnectionEndpoint.uniqueID has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionEndpoint.uniqueID)));
    assert(size_of(MIDIThruConnectionEndpoint) == 8, "MIDIThruConnectionEndpoint has size % instead of 8", size_of(MIDIThruConnectionEndpoint));
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
#run {
    instance: MIDIThruConnectionParams;
    assert(((cast(*void)(*instance.version)) - cast(*void)(*instance)) == 0, "MIDIThruConnectionParams.version has unexpected offset % instead of 0", ((cast(*void)(*instance.version)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.version)) == 4, "MIDIThruConnectionParams.version has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionParams.version)));
    assert(((cast(*void)(*instance.numSources)) - cast(*void)(*instance)) == 4, "MIDIThruConnectionParams.numSources has unexpected offset % instead of 4", ((cast(*void)(*instance.numSources)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.numSources)) == 4, "MIDIThruConnectionParams.numSources has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionParams.numSources)));
    assert(((cast(*void)(*instance.sources)) - cast(*void)(*instance)) == 8, "MIDIThruConnectionParams.sources has unexpected offset % instead of 8", ((cast(*void)(*instance.sources)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.sources)) == 64, "MIDIThruConnectionParams.sources has unexpected size % instead of 64", size_of(type_of(MIDIThruConnectionParams.sources)));
    assert(((cast(*void)(*instance.numDestinations)) - cast(*void)(*instance)) == 72, "MIDIThruConnectionParams.numDestinations has unexpected offset % instead of 72", ((cast(*void)(*instance.numDestinations)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.numDestinations)) == 4, "MIDIThruConnectionParams.numDestinations has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionParams.numDestinations)));
    assert(((cast(*void)(*instance.destinations)) - cast(*void)(*instance)) == 76, "MIDIThruConnectionParams.destinations has unexpected offset % instead of 76", ((cast(*void)(*instance.destinations)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.destinations)) == 64, "MIDIThruConnectionParams.destinations has unexpected size % instead of 64", size_of(type_of(MIDIThruConnectionParams.destinations)));
    assert(((cast(*void)(*instance.channelMap)) - cast(*void)(*instance)) == 140, "MIDIThruConnectionParams.channelMap has unexpected offset % instead of 140", ((cast(*void)(*instance.channelMap)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.channelMap)) == 16, "MIDIThruConnectionParams.channelMap has unexpected size % instead of 16", size_of(type_of(MIDIThruConnectionParams.channelMap)));
    assert(((cast(*void)(*instance.lowVelocity)) - cast(*void)(*instance)) == 156, "MIDIThruConnectionParams.lowVelocity has unexpected offset % instead of 156", ((cast(*void)(*instance.lowVelocity)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.lowVelocity)) == 1, "MIDIThruConnectionParams.lowVelocity has unexpected size % instead of 1", size_of(type_of(MIDIThruConnectionParams.lowVelocity)));
    assert(((cast(*void)(*instance.highVelocity)) - cast(*void)(*instance)) == 157, "MIDIThruConnectionParams.highVelocity has unexpected offset % instead of 157", ((cast(*void)(*instance.highVelocity)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.highVelocity)) == 1, "MIDIThruConnectionParams.highVelocity has unexpected size % instead of 1", size_of(type_of(MIDIThruConnectionParams.highVelocity)));
    assert(((cast(*void)(*instance.lowNote)) - cast(*void)(*instance)) == 158, "MIDIThruConnectionParams.lowNote has unexpected offset % instead of 158", ((cast(*void)(*instance.lowNote)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.lowNote)) == 1, "MIDIThruConnectionParams.lowNote has unexpected size % instead of 1", size_of(type_of(MIDIThruConnectionParams.lowNote)));
    assert(((cast(*void)(*instance.highNote)) - cast(*void)(*instance)) == 159, "MIDIThruConnectionParams.highNote has unexpected offset % instead of 159", ((cast(*void)(*instance.highNote)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.highNote)) == 1, "MIDIThruConnectionParams.highNote has unexpected size % instead of 1", size_of(type_of(MIDIThruConnectionParams.highNote)));
    assert(((cast(*void)(*instance.noteNumber)) - cast(*void)(*instance)) == 160, "MIDIThruConnectionParams.noteNumber has unexpected offset % instead of 160", ((cast(*void)(*instance.noteNumber)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.noteNumber)) == 4, "MIDIThruConnectionParams.noteNumber has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionParams.noteNumber)));
    assert(((cast(*void)(*instance.velocity)) - cast(*void)(*instance)) == 164, "MIDIThruConnectionParams.velocity has unexpected offset % instead of 164", ((cast(*void)(*instance.velocity)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.velocity)) == 4, "MIDIThruConnectionParams.velocity has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionParams.velocity)));
    assert(((cast(*void)(*instance.keyPressure)) - cast(*void)(*instance)) == 168, "MIDIThruConnectionParams.keyPressure has unexpected offset % instead of 168", ((cast(*void)(*instance.keyPressure)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.keyPressure)) == 4, "MIDIThruConnectionParams.keyPressure has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionParams.keyPressure)));
    assert(((cast(*void)(*instance.channelPressure)) - cast(*void)(*instance)) == 172, "MIDIThruConnectionParams.channelPressure has unexpected offset % instead of 172", ((cast(*void)(*instance.channelPressure)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.channelPressure)) == 4, "MIDIThruConnectionParams.channelPressure has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionParams.channelPressure)));
    assert(((cast(*void)(*instance.programChange)) - cast(*void)(*instance)) == 176, "MIDIThruConnectionParams.programChange has unexpected offset % instead of 176", ((cast(*void)(*instance.programChange)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.programChange)) == 4, "MIDIThruConnectionParams.programChange has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionParams.programChange)));
    assert(((cast(*void)(*instance.pitchBend)) - cast(*void)(*instance)) == 180, "MIDIThruConnectionParams.pitchBend has unexpected offset % instead of 180", ((cast(*void)(*instance.pitchBend)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.pitchBend)) == 4, "MIDIThruConnectionParams.pitchBend has unexpected size % instead of 4", size_of(type_of(MIDIThruConnectionParams.pitchBend)));
    assert(((cast(*void)(*instance.filterOutSysEx)) - cast(*void)(*instance)) == 184, "MIDIThruConnectionParams.filterOutSysEx has unexpected offset % instead of 184", ((cast(*void)(*instance.filterOutSysEx)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.filterOutSysEx)) == 1, "MIDIThruConnectionParams.filterOutSysEx has unexpected size % instead of 1", size_of(type_of(MIDIThruConnectionParams.filterOutSysEx)));
    assert(((cast(*void)(*instance.filterOutMTC)) - cast(*void)(*instance)) == 185, "MIDIThruConnectionParams.filterOutMTC has unexpected offset % instead of 185", ((cast(*void)(*instance.filterOutMTC)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.filterOutMTC)) == 1, "MIDIThruConnectionParams.filterOutMTC has unexpected size % instead of 1", size_of(type_of(MIDIThruConnectionParams.filterOutMTC)));
    assert(((cast(*void)(*instance.filterOutBeatClock)) - cast(*void)(*instance)) == 186, "MIDIThruConnectionParams.filterOutBeatClock has unexpected offset % instead of 186", ((cast(*void)(*instance.filterOutBeatClock)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.filterOutBeatClock)) == 1, "MIDIThruConnectionParams.filterOutBeatClock has unexpected size % instead of 1", size_of(type_of(MIDIThruConnectionParams.filterOutBeatClock)));
    assert(((cast(*void)(*instance.filterOutTuneRequest)) - cast(*void)(*instance)) == 187, "MIDIThruConnectionParams.filterOutTuneRequest has unexpected offset % instead of 187", ((cast(*void)(*instance.filterOutTuneRequest)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.filterOutTuneRequest)) == 1, "MIDIThruConnectionParams.filterOutTuneRequest has unexpected size % instead of 1", size_of(type_of(MIDIThruConnectionParams.filterOutTuneRequest)));
    assert(((cast(*void)(*instance.reserved2)) - cast(*void)(*instance)) == 188, "MIDIThruConnectionParams.reserved2 has unexpected offset % instead of 188", ((cast(*void)(*instance.reserved2)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.reserved2)) == 3, "MIDIThruConnectionParams.reserved2 has unexpected size % instead of 3", size_of(type_of(MIDIThruConnectionParams.reserved2)));
    assert(((cast(*void)(*instance.filterOutAllControls)) - cast(*void)(*instance)) == 191, "MIDIThruConnectionParams.filterOutAllControls has unexpected offset % instead of 191", ((cast(*void)(*instance.filterOutAllControls)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.filterOutAllControls)) == 1, "MIDIThruConnectionParams.filterOutAllControls has unexpected size % instead of 1", size_of(type_of(MIDIThruConnectionParams.filterOutAllControls)));
    assert(((cast(*void)(*instance.numControlTransforms)) - cast(*void)(*instance)) == 192, "MIDIThruConnectionParams.numControlTransforms has unexpected offset % instead of 192", ((cast(*void)(*instance.numControlTransforms)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.numControlTransforms)) == 2, "MIDIThruConnectionParams.numControlTransforms has unexpected size % instead of 2", size_of(type_of(MIDIThruConnectionParams.numControlTransforms)));
    assert(((cast(*void)(*instance.numMaps)) - cast(*void)(*instance)) == 194, "MIDIThruConnectionParams.numMaps has unexpected offset % instead of 194", ((cast(*void)(*instance.numMaps)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.numMaps)) == 2, "MIDIThruConnectionParams.numMaps has unexpected size % instead of 2", size_of(type_of(MIDIThruConnectionParams.numMaps)));
    assert(((cast(*void)(*instance.reserved3)) - cast(*void)(*instance)) == 196, "MIDIThruConnectionParams.reserved3 has unexpected offset % instead of 196", ((cast(*void)(*instance.reserved3)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIThruConnectionParams.reserved3)) == 8, "MIDIThruConnectionParams.reserved3 has unexpected size % instead of 8", size_of(type_of(MIDIThruConnectionParams.reserved3)));
    assert(size_of(MIDIThruConnectionParams) == 204, "MIDIThruConnectionParams has size % instead of 204", size_of(MIDIThruConnectionParams));
}

MIDIThruConnectionParamsInitialize :: (inConnectionParams: *MIDIThruConnectionParams) -> void #foreign coremidi;

MIDIThruConnectionCreate :: (inPersistentOwnerID: CFStringRef, inConnectionParams: CFDataRef, outConnection: *MIDIThruConnectionRef) -> OSStatus #foreign coremidi;

MIDIThruConnectionDispose :: (connection: MIDIThruConnectionRef) -> OSStatus #foreign coremidi;

MIDIThruConnectionGetParams :: (connection: MIDIThruConnectionRef, outConnectionParams: *CFDataRef) -> OSStatus #foreign coremidi;

MIDIThruConnectionSetParams :: (connection: MIDIThruConnectionRef, inConnectionParams: CFDataRef) -> OSStatus #foreign coremidi;

MIDIThruConnectionFind :: (inPersistentOwnerID: CFStringRef, outConnectionList: *CFDataRef) -> OSStatus #foreign coremidi;

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
#run {
    instance: MIDIMessage_64;
    assert(((cast(*void)(*instance.word0)) - cast(*void)(*instance)) == 0, "MIDIMessage_64.word0 has unexpected offset % instead of 0", ((cast(*void)(*instance.word0)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIMessage_64.word0)) == 4, "MIDIMessage_64.word0 has unexpected size % instead of 4", size_of(type_of(MIDIMessage_64.word0)));
    assert(((cast(*void)(*instance.word1)) - cast(*void)(*instance)) == 4, "MIDIMessage_64.word1 has unexpected offset % instead of 4", ((cast(*void)(*instance.word1)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIMessage_64.word1)) == 4, "MIDIMessage_64.word1 has unexpected size % instead of 4", size_of(type_of(MIDIMessage_64.word1)));
    assert(size_of(MIDIMessage_64) == 8, "MIDIMessage_64 has size % instead of 8", size_of(MIDIMessage_64));
}

MIDIMessage_96 :: struct {
    word0: u32;
    word1: u32;
    word2: u32;
}
#run {
    instance: MIDIMessage_96;
    assert(((cast(*void)(*instance.word0)) - cast(*void)(*instance)) == 0, "MIDIMessage_96.word0 has unexpected offset % instead of 0", ((cast(*void)(*instance.word0)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIMessage_96.word0)) == 4, "MIDIMessage_96.word0 has unexpected size % instead of 4", size_of(type_of(MIDIMessage_96.word0)));
    assert(((cast(*void)(*instance.word1)) - cast(*void)(*instance)) == 4, "MIDIMessage_96.word1 has unexpected offset % instead of 4", ((cast(*void)(*instance.word1)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIMessage_96.word1)) == 4, "MIDIMessage_96.word1 has unexpected size % instead of 4", size_of(type_of(MIDIMessage_96.word1)));
    assert(((cast(*void)(*instance.word2)) - cast(*void)(*instance)) == 8, "MIDIMessage_96.word2 has unexpected offset % instead of 8", ((cast(*void)(*instance.word2)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIMessage_96.word2)) == 4, "MIDIMessage_96.word2 has unexpected size % instead of 4", size_of(type_of(MIDIMessage_96.word2)));
    assert(size_of(MIDIMessage_96) == 12, "MIDIMessage_96 has size % instead of 12", size_of(MIDIMessage_96));
}

MIDIMessage_128 :: struct {
    word0: u32;
    word1: u32;
    word2: u32;
    word3: u32;
}
#run {
    instance: MIDIMessage_128;
    assert(((cast(*void)(*instance.word0)) - cast(*void)(*instance)) == 0, "MIDIMessage_128.word0 has unexpected offset % instead of 0", ((cast(*void)(*instance.word0)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIMessage_128.word0)) == 4, "MIDIMessage_128.word0 has unexpected size % instead of 4", size_of(type_of(MIDIMessage_128.word0)));
    assert(((cast(*void)(*instance.word1)) - cast(*void)(*instance)) == 4, "MIDIMessage_128.word1 has unexpected offset % instead of 4", ((cast(*void)(*instance.word1)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIMessage_128.word1)) == 4, "MIDIMessage_128.word1 has unexpected size % instead of 4", size_of(type_of(MIDIMessage_128.word1)));
    assert(((cast(*void)(*instance.word2)) - cast(*void)(*instance)) == 8, "MIDIMessage_128.word2 has unexpected offset % instead of 8", ((cast(*void)(*instance.word2)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIMessage_128.word2)) == 4, "MIDIMessage_128.word2 has unexpected size % instead of 4", size_of(type_of(MIDIMessage_128.word2)));
    assert(((cast(*void)(*instance.word3)) - cast(*void)(*instance)) == 12, "MIDIMessage_128.word3 has unexpected offset % instead of 12", ((cast(*void)(*instance.word3)) - cast(*void)(*instance)));
    assert(size_of(type_of(MIDIMessage_128.word3)) == 4, "MIDIMessage_128.word3 has unexpected size % instead of 4", size_of(type_of(MIDIMessage_128.word3)));
    assert(size_of(MIDIMessage_128) == 16, "MIDIMessage_128 has size % instead of 16", size_of(MIDIMessage_128));
}

mach_timebase_info :: struct {
    numer: u32;
    denom: u32;
}
#run {
    instance: mach_timebase_info;
    assert(((cast(*void)(*instance.numer)) - cast(*void)(*instance)) == 0, "mach_timebase_info.numer has unexpected offset % instead of 0", ((cast(*void)(*instance.numer)) - cast(*void)(*instance)));
    assert(size_of(type_of(mach_timebase_info.numer)) == 4, "mach_timebase_info.numer has unexpected size % instead of 4", size_of(type_of(mach_timebase_info.numer)));
    assert(((cast(*void)(*instance.denom)) - cast(*void)(*instance)) == 4, "mach_timebase_info.denom has unexpected offset % instead of 4", ((cast(*void)(*instance.denom)) - cast(*void)(*instance)));
    assert(size_of(type_of(mach_timebase_info.denom)) == 4, "mach_timebase_info.denom has unexpected size % instead of 4", size_of(type_of(mach_timebase_info.denom)));
    assert(size_of(mach_timebase_info) == 8, "mach_timebase_info has size % instead of 8", size_of(mach_timebase_info));
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

libc :: #system_library "libc";
coremidi :: #system_library "CoreMIDI";

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

