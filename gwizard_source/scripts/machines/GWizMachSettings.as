package machines
{
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.utils.StringUtil;
   import utils.GWizCSVUtils;
   import utils.GWizCallChain;
   import utils.GWizFileUtils;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   public class GWizMachSettings implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizMachSettings");
      
      private static var _currMachine:String = "";
      
      public static const MACH_TYPE_MILL:String = "Mill";
      
      public static const MACH_TYPE_ROUTER:String = "Router";
      
      public static const MACH_TYPE_LATHE:String = "Lathe";
      
      public static var currMachType:String = MACH_TYPE_MILL;
      
      private static var _2019907562MachinesList:ArrayCollection = initMachinesList();
      
      public static var newMachineCC:GWizCallChain = new GWizCallChain();
      
      public static var deleteMachineCC:GWizCallChain = new GWizCallChain();
      
      public static var selectMachineCC:GWizCallChain = new GWizCallChain();
      
      public static var matchMachineCC:GWizCallChain = new GWizCallChain();
      
      private static var lmName:String = "";
      
      private static var lmSlot:int = -1;
      
      public static const UNDEF_CONTROLLER:String = "Undefined";
      
      private static var _1678770883Control:String = UNDEF_CONTROLLER;
      
      public static const GENERIC_VMC:String = "Generic VMC";
      
      public static var defaultMachinesList:ArrayCollection = new ArrayCollection([{
         "name":GENERIC_VMC,
         "make":"Generic",
         "model":"VMC",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":20,
         "rpmLimit":7500,
         "rpmMinLimit":0,
         "feedLimit":650,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":1000,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":20,
         "tcTime":5,
         "xTravel":20,
         "yTravel":16,
         "zTravel":20,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":5000,
         "adjustMode":0
      },{
         "name":"Generic CNC Router",
         "make":"Generic",
         "model":"Router",
         "type":"Mill",
         "taperType":"Other",
         "taperSize":"40",
         "hpLimit":2,
         "rpmLimit":24000,
         "rpmMinLimit":12000,
         "feedLimit":400,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":400,
         "accel":0.1,
         "flood":"false",
         "mist":"true",
         "slots":1,
         "tcTime":120,
         "xTravel":96,
         "yTravel":48,
         "zTravel":10,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":1200,
         "adjustMode":0
      },{
         "name":"Generic CNC Lathe",
         "make":"Generic",
         "model":"Lathe",
         "type":"Lathe",
         "taperType":"A2",
         "taperSize":"40",
         "hpLimit":7.5,
         "rpmLimit":2000,
         "rpmMinLimit":0,
         "feedLimit":75,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":75,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":0,
         "tcTime":3,
         "xTravel":8,
         "yTravel":0,
         "zTravel":30,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucLathe",
         "weight":0,
         "adjustMode":0
      },{
         "name":"Bridgeport Series I Mill",
         "make":"Bridgeport",
         "model":"Series I Knee Mill",
         "type":"Mill",
         "taperType":"R8",
         "taperSize":"40",
         "hpLimit":3,
         "rpmLimit":4200,
         "rpmMinLimit":60,
         "feedLimit":80,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":100,
         "accel":0.1,
         "flood":"false",
         "mist":"false",
         "slots":1,
         "tcTime":60,
         "xTravel":33,
         "yTravel":12,
         "zTravel":5,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":1930,
         "adjustMode":0
      },{
         "name":"Carbide3D Nomad 883",
         "make":"Carbide3D",
         "model":"Nomad 883",
         "type":"Router",
         "taperType":"Other",
         "taperSize":"11",
         "hpLimit":0.067,
         "rpmLimit":10000,
         "rpmMinLimit":2000,
         "feedLimit":80,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":100,
         "accel":0.1,
         "flood":"false",
         "mist":"false",
         "slots":1,
         "tcTime":60,
         "xTravel":8,
         "yTravel":8,
         "zTravel":3,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"GRBLMill",
         "weight":50,
         "adjustMode":0
      },{
         "name":"Datron M7",
         "make":"Datron",
         "model":"M7",
         "type":"Mill",
         "taperType":"HSK",
         "taperSize":"25",
         "hpLimit":2.54,
         "rpmLimit":60000,
         "rpmMinLimit":1000,
         "feedLimit":787,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":787,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":30,
         "tcTime":5,
         "xTravel":20,
         "yTravel":25,
         "zTravel":9,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":1584,
         "adjustMode":0
      },{
         "name":"Datron M8",
         "make":"Datron",
         "model":"M8",
         "type":"Mill",
         "taperType":"HSK",
         "taperSize":"25",
         "hpLimit":3.82,
         "rpmLimit":40000,
         "rpmMinLimit":1000,
         "feedLimit":787,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":787,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":10,
         "tcTime":5,
         "xTravel":40,
         "yTravel":32,
         "zTravel":9,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":1760,
         "adjustMode":0
      },{
         "name":"Datron M8Cube",
         "make":"Datron",
         "model":"M8Cube",
         "type":"Mill",
         "taperType":"HSK",
         "taperSize":"25",
         "hpLimit":3.92,
         "rpmLimit":40000,
         "rpmMinLimit":1000,
         "feedLimit":870,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":870,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":10,
         "tcTime":5,
         "xTravel":40,
         "yTravel":32,
         "zTravel":9,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":2886,
         "adjustMode":0
      },{
         "name":"Fadal VMC 15",
         "make":"Fadal",
         "model":"VMC 15",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":15,
         "rpmLimit":7500,
         "rpmMinLimit":10,
         "feedLimit":250,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":400,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":21,
         "tcTime":5,
         "xTravel":20,
         "yTravel":16,
         "zTravel":20,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":5500,
         "adjustMode":0
      },{
         "name":"Fadal VMC 15XT",
         "make":"Fadal",
         "model":"VMC 15XT",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":15,
         "rpmLimit":7500,
         "rpmMinLimit":10,
         "feedLimit":250,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":400,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":21,
         "tcTime":5,
         "xTravel":30,
         "yTravel":16,
         "zTravel":20,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":5800,
         "adjustMode":0
      },{
         "name":"Fadal VMC 4020",
         "make":"Fadal",
         "model":"VMC 4020",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":15,
         "rpmLimit":10000,
         "rpmMinLimit":10,
         "feedLimit":400,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":900,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":21,
         "tcTime":5,
         "xTravel":40,
         "yTravel":20,
         "zTravel":20,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":10500,
         "adjustMode":0
      },{
         "name":"Fadal VMC 4525",
         "make":"Fadal",
         "model":"VMC 4525",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":22.5,
         "rpmLimit":10000,
         "rpmMinLimit":10,
         "feedLimit":400,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":900,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":21,
         "tcTime":5,
         "xTravel":45,
         "yTravel":25,
         "zTravel":24,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":13600,
         "adjustMode":0
      },{
         "name":"Haas Minimill",
         "make":"Haas",
         "model":"Minimill",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":7.5,
         "rpmLimit":6000,
         "rpmMinLimit":0,
         "feedLimit":500,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":600,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":10,
         "tcTime":5,
         "xTravel":16,
         "yTravel":12,
         "zTravel":10,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"HaasMill",
         "weight":3400,
         "adjustMode":0
      },{
         "name":"Haas ST-10",
         "make":"Haas",
         "model":"ST-10",
         "type":"Lathe",
         "taperType":"A2",
         "taperSize":"40",
         "hpLimit":15,
         "rpmLimit":6000,
         "rpmMinLimit":0,
         "feedLimit":1200,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":1200,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":12,
         "tcTime":0.5,
         "xTravel":7.88,
         "yTravel":0,
         "zTravel":14,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"HaasLathe",
         "weight":5000,
         "adjustMode":0
      },{
         "name":"Haas TL-1",
         "make":"Haas",
         "model":"TL-1",
         "type":"Lathe",
         "taperType":"A2",
         "taperSize":"40",
         "hpLimit":7.5,
         "rpmLimit":2000,
         "rpmMinLimit":0,
         "feedLimit":75,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":75,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":0,
         "tcTime":60,
         "xTravel":8,
         "yTravel":0,
         "zTravel":29,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"HaasLathe",
         "weight":4100,
         "adjustMode":0
      },{
         "name":"Haas VF-1",
         "make":"Haas",
         "model":"VF-1",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":30,
         "rpmLimit":8100,
         "rpmMinLimit":0,
         "feedLimit":650,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":1000,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":20,
         "tcTime":4.5,
         "xTravel":20,
         "yTravel":16,
         "zTravel":20,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"HaasMill",
         "weight":7500,
         "adjustMode":0
      },{
         "name":"Haas VF-2",
         "make":"Haas",
         "model":"VF-2",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":30,
         "rpmLimit":8100,
         "rpmMinLimit":0,
         "feedLimit":650,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":1000,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":20,
         "tcTime":4.5,
         "xTravel":30,
         "yTravel":16,
         "zTravel":20,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"HaasMill",
         "weight":7300,
         "adjustMode":0
      },{
         "name":"Haas VF-3",
         "make":"Haas",
         "model":"VF-3",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":30,
         "rpmLimit":8100,
         "rpmMinLimit":0,
         "feedLimit":650,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":1000,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":20,
         "tcTime":4.5,
         "xTravel":40,
         "yTravel":20,
         "zTravel":25,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"HaasMill",
         "weight":12500,
         "adjustMode":0
      },{
         "name":"Haas VF-4",
         "make":"Haas",
         "model":"VF-4",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":30,
         "rpmLimit":8100,
         "rpmMinLimit":0,
         "feedLimit":650,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":1000,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":20,
         "tcTime":4.5,
         "xTravel":50,
         "yTravel":20,
         "zTravel":25,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"HaasMill",
         "weight":13300,
         "adjustMode":0
      },{
         "name":"Haas VF-10",
         "make":"Haas",
         "model":"VF-10",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":30,
         "rpmLimit":8100,
         "rpmMinLimit":0,
         "feedLimit":360,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":360,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":25,
         "tcTime":3.6,
         "xTravel":120,
         "yTravel":32,
         "zTravel":30,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"HaasMill",
         "weight":30100,
         "adjustMode":0
      },{
         "name":"Hurco VM20i",
         "make":"Hurco",
         "model":"VM20i",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":20,
         "rpmLimit":10000,
         "rpmMinLimit":0,
         "feedLimit":945,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":945,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":24,
         "tcTime":3.6,
         "xTravel":40,
         "yTravel":20,
         "zTravel":20,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":9039,
         "adjustMode":0
      },{
         "name":"Hurco VMX24i",
         "make":"Hurco",
         "model":"VMX24i",
         "type":"Mill",
         "taperType":"CAT",
         "taperSize":"40",
         "hpLimit":20,
         "rpmLimit":12000,
         "rpmMinLimit":0,
         "feedLimit":1181,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":1378,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":24,
         "tcTime":3.6,
         "xTravel":24,
         "yTravel":20,
         "zTravel":24,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"FanucMill",
         "weight":10468,
         "adjustMode":0
      },{
         "name":"IHCNC RF45",
         "make":"Industrial Hobbies",
         "model":"IHCNC RF45",
         "type":"Mill",
         "taperType":"R8",
         "taperSize":"40",
         "hpLimit":2,
         "rpmMinLimit":0,
         "rpmLimit":1600,
         "feedLimit":100,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":120,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":20,
         "tcTime":5,
         "xTravel":30.5,
         "yTravel":12.5,
         "zTravel":20,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"Mach3Mill",
         "weight":1100,
         "adjustMode":0
      },{
         "name":"Shapeoko3 DWP611",
         "make":"Shapeoko",
         "model":"Shapeoko3 DWP611",
         "type":"Router",
         "taperType":"Other",
         "taperSize":"11",
         "hpLimit":1.25,
         "rpmLimit":27000,
         "rpmMinLimit":16000,
         "feedLimit":100,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":100,
         "accel":0.1,
         "flood":"false",
         "mist":"false",
         "slots":0,
         "tcTime":60,
         "xTravel":16,
         "yTravel":16,
         "zTravel":3,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"GRBLMill",
         "weight":57,
         "adjustMode":0
      },{
         "name":"Shapeoko3 Porter 450",
         "make":"Shapeoko",
         "model":"Shapeoko3 Porter 450",
         "type":"Router",
         "taperType":"Other",
         "taperSize":"11",
         "hpLimit":1.25,
         "rpmLimit":27000,
         "rpmMinLimit":27000,
         "feedLimit":100,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":100,
         "accel":0.1,
         "flood":"false",
         "mist":"false",
         "slots":0,
         "tcTime":60,
         "xTravel":16,
         "yTravel":16,
         "zTravel":3,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"GRBLMill",
         "weight":57,
         "adjustMode":0
      },{
         "name":"Shopbot Desktop",
         "make":"Shopbot",
         "model":"Desktop Porter Cable",
         "type":"Router",
         "taperType":"Other",
         "taperSize":"11",
         "hpLimit":2.25,
         "rpmLimit":23000,
         "rpmMinLimit":10000,
         "feedLimit":180,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":240,
         "accel":0.1,
         "flood":"false",
         "mist":"false",
         "slots":0,
         "tcTime":60,
         "xTravel":24.8,
         "yTravel":18.5,
         "zTravel":5.5,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"GRBLMill",
         "weight":102,
         "adjustMode":0,
         "feedSecMode":true
      },{
         "name":"Shopbot Desktop Max",
         "make":"Shopbot",
         "model":"Desktop Max",
         "type":"Router",
         "taperType":"Other",
         "taperSize":"11",
         "hpLimit":1,
         "rpmLimit":24000,
         "rpmMinLimit":10000,
         "feedLimit":240,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":360,
         "accel":0.1,
         "flood":"false",
         "mist":"false",
         "slots":0,
         "tcTime":60,
         "xTravel":38,
         "yTravel":25,
         "zTravel":5.5,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"GRBLMill",
         "weight":194,
         "adjustMode":0,
         "feedSecMode":true
      },{
         "name":"Shopbot PRSalpha 96-48 Porter Cable",
         "make":"Shopbot",
         "model":"PRSalpha Porter Calble",
         "type":"Router",
         "taperType":"Other",
         "taperSize":"11",
         "hpLimit":3.5,
         "rpmLimit":21000,
         "rpmMinLimit":10000,
         "feedLimit":600,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":1800,
         "accel":0.1,
         "flood":"false",
         "mist":"false",
         "slots":0,
         "tcTime":60,
         "xTravel":102,
         "yTravel":50,
         "zTravel":8,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"GRBLMill",
         "weight":1500,
         "adjustMode":0,
         "feedSecMode":true
      },{
         "name":"Laguna Tools Swift 48x48",
         "make":"Laguna Tools",
         "model":"Swift 48x48",
         "type":"Router",
         "taperType":"Other",
         "taperSize":"20",
         "hpLimit":3,
         "rpmLimit":24000,
         "rpmMinLimit":5000,
         "feedLimit":600,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":900,
         "accel":0.1,
         "flood":"false",
         "mist":"false",
         "slots":0,
         "tcTime":60,
         "xTravel":48,
         "yTravel":48,
         "zTravel":6,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"Mach3Mill",
         "weight":1500,
         "adjustMode":0
      },{
         "name":"Laguna Tools Swift 48x96",
         "make":"Laguna Tools",
         "model":"Swift 48x96",
         "type":"Router",
         "taperType":"Other",
         "taperSize":"20",
         "hpLimit":3,
         "rpmLimit":24000,
         "rpmMinLimit":5000,
         "feedLimit":600,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":900,
         "accel":0.1,
         "flood":"false",
         "mist":"false",
         "slots":0,
         "tcTime":60,
         "xTravel":48,
         "yTravel":96,
         "zTravel":6,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"Mach3Mill",
         "weight":1900,
         "adjustMode":0
      },{
         "name":"Taig Mill",
         "make":"Taig",
         "model":"Micro Mill",
         "type":"Mill",
         "taperType":"Other",
         "taperSize":"40",
         "hpLimit":0.25,
         "rpmLimit":5200,
         "rpmMinLimit":0,
         "feedLimit":30,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":30,
         "accel":0.1,
         "flood":"false",
         "mist":"true",
         "slots":0,
         "tcTime":60,
         "xTravel":9.5,
         "yTravel":5.5,
         "zTravel":6,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"Mach3Mill",
         "weight":85,
         "adjustMode":0
      },{
         "name":"Tormach PCNC 440",
         "make":"Tormach",
         "model":"PCNC 440",
         "type":"Mill",
         "taperType":"R8",
         "taperSize":"40",
         "hpLimit":0.75,
         "rpmLimit":10000,
         "rpmMinLimit":300,
         "feedLimit":135,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":135,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":0,
         "tcTime":60,
         "xTravel":10,
         "yTravel":6.25,
         "zTravel":10,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"TormachMach3Mill",
         "weight":450,
         "adjustMode":0
      },{
         "name":"Tormach PCNC 770",
         "make":"Tormach",
         "model":"PCNC 770",
         "type":"Mill",
         "taperType":"R8",
         "taperSize":"40",
         "hpLimit":1,
         "rpmLimit":10000,
         "rpmMinLimit":0,
         "feedLimit":135,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":135,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":0,
         "tcTime":60,
         "xTravel":14,
         "yTravel":7.5,
         "zTravel":13.25,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"TormachMach3Mill",
         "weight":662,
         "adjustMode":0
      },{
         "name":"Tormach PCNC 1100",
         "make":"Tormach",
         "model":"PCNC 1100",
         "type":"Mill",
         "taperType":"R8",
         "taperSize":"40",
         "hpLimit":1.5,
         "rpmLimit":5100,
         "rpmMinLimit":0,
         "feedLimit":90,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":90,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":0,
         "tcTime":60,
         "xTravel":18,
         "yTravel":9.5,
         "zTravel":16.25,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"TormachMach3Mill",
         "weight":1100,
         "adjustMode":0
      },{
         "name":"Tormach 15L Slant-PRO",
         "make":"Tormach",
         "model":"15L Slant-PRO",
         "type":"Lathe",
         "taperType":"D1",
         "taperSize":"40",
         "hpLimit":3,
         "rpmLimit":3500,
         "rpmMinLimit":0,
         "feedLimit":60,
         "sfmAdjust":100,
         "chiploadAdjust":100,
         "rapids":60,
         "accel":0.1,
         "flood":"true",
         "mist":"true",
         "slots":0,
         "tcTime":60,
         "xTravel":10,
         "yTravel":0,
         "zTravel":12,
         "spindletime":2,
         "wordtime":5,
         "cooltime":1.5,
         "controller":"TormachMach3Mill",
         "weight":1500,
         "adjustMode":0
      }]);
      
      private static var machinesXML:XML;
      
      private static const MACHINES_FILE_NAME:String = "machines.xml";
      
      private static const MACHINES_CSV_FILE_NAME:String = "machines.csv";
      
      private static const MYSHOP_CSV_FILE_NAME:String = "myshop.csv";
      
      private static var loadTime:Date = null;
      
      private static const MACHINE_DB:String = "http://www.cnccookbook.com/img/GWizard/Downloads/machines.csv";
      
      private static const MACHINE_DB_OLD:String = "http://www.cnccookbook.com.s3.amazonaws.com/img/GWizard/Downloads/machines.csv";
      
      private static var addAllAndSave:Boolean = true;
      
      private static var nameHash:Object;
      
      private static var myShopFieldList:Array = ["description","name","make","model"];
      
      public static var machProfileFieldList:Array = ["name","make","model","type","taperType","taperSize","rpmLimit","rpmMinLimit","feedLimit","feedSecMode","hpLimit","sfmAdjust","chiploadAdjust","rapids","accel","weight","adjustMode","vmcRigidity","simAdj","tsc","pcn","flood","mist","slots","tcTime","xTravel","yTravel","zTravel","spindletime","wordtime","hourly","cooltime","controller","fourthAxis","parallelAxis","rapidsRate","xCenter","yCenter","zCenter","loRPM","loHP","peakRPM","peakHP","hiRPM","hiHP",GWizSpindleCurve.SPINDLE_CURVE + "0" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "1" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "2" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "3" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "4" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "5" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "6" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "7" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "8" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "9" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "10" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "11" + "RPM",GWizSpindleCurve.SPINDLE_CURVE + "0" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "1" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "2" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "3" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "4" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "5" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "6" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "7" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "8" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "9" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "10" + "HP",GWizSpindleCurve.SPINDLE_CURVE + "11" + "HP","version","changeDate","sessions","ignoreSpindleSpeedGCodes","ignoreToolchangeGCodes","safeMode"];
      
      public static const MAX_POWER_CURVE_PTS:int = 12;
      
      public static const MAX_RPM:Number = 200000;
      
      public static const MAX_FEEDRATE:Number = 100000;
      
      private static var _1535399988MyShopMachinesList:ArrayCollection = new ArrayCollection();
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizMachSettings()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      public static function get currMachine() : String
      {
         return _currMachine;
      }
      
      public static function set currMachine(param1:String) : void
      {
         _currMachine = param1;
         currMachType = lookupMachine(currMachine).type;
         matchMachineCC.callChain(param1);
         selectMachineCC.callChain(param1);
      }
      
      public static function isMill(param1:String) : Boolean
      {
         return param1 == MACH_TYPE_MILL || param1 == MACH_TYPE_ROUTER;
      }
      
      private static function initMachinesList() : ArrayCollection
      {
         return new ArrayCollection();
      }
      
      public static function lookupCurrentMachine() : Object
      {
         return lookupMachine(currMachine);
      }
      
      public static function currMachineSafeMode() : Boolean
      {
         var _loc1_:Object = lookupCurrentMachine();
         if(_loc1_)
         {
            return String(_loc1_.safeMode).toLowerCase() == "true";
         }
         return false;
      }
      
      public static function lookupMachine(param1:String) : Object
      {
         var _loc2_:Object = null;
         if(!MachinesList || MachinesList.length == 0)
         {
            return defaultMachinesList[0];
         }
         if(lmName == param1)
         {
            if(0 <= lmSlot && lmSlot < MachinesList.length)
            {
               _loc2_ = MachinesList.getItemAt(lmSlot);
               if(_loc2_.name == param1)
               {
                  return _loc2_;
               }
            }
         }
         var _loc3_:int = 0;
         while(_loc3_ < MachinesList.length)
         {
            _loc2_ = MachinesList.getItemAt(_loc3_);
            if(_loc2_.name == param1)
            {
               _loc2_.index = _loc3_;
               lmName = param1;
               lmSlot = _loc3_;
               return _loc2_;
            }
            _loc3_++;
         }
         return MachinesList.getItemAt(0);
      }
      
      public static function lookupMachineIdx(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(MachinesList && MachinesList.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < MachinesList.length)
            {
               _loc3_ = MachinesList.getItemAt(_loc2_);
               if(_loc3_.name == param1)
               {
                  return _loc2_;
               }
               _loc2_++;
            }
         }
         return 0;
      }
      
      public static function machineTypeByName(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc2_:Object = GWizMachSettings.lookupMachine(param1);
         if(_loc2_.name == param1)
         {
            return _loc2_.type;
         }
         return "Mill";
      }
      
      public static function getToolChangeTime() : Number
      {
         var _loc1_:Number = NaN;
         var _loc2_:Object = GWizMachSettings.lookupMachine(GWizMachSettings.currMachine);
         if(_loc2_ && _loc2_.hasOwnProperty("tcTime"))
         {
            _loc1_ = _loc2_.tcTime / 60;
         }
         return _loc1_;
      }
      
      public static function controllerFor(param1:String) : String
      {
         var _loc2_:Object = lookupMachine(param1);
         if(!_loc2_)
         {
            return "";
         }
         return _loc2_.controller;
      }
      
      public static function controllerDefined() : Boolean
      {
         return controllerFor(currMachine) != UNDEF_CONTROLLER;
      }
      
      public static function resetDefaults() : void
      {
         downloadDefaultMachinesFromCNCCookbook(false);
      }
      
      public static function updateMachinesList(param1:String, param2:Object, param3:Boolean = true) : void
      {
         var _loc5_:Object = null;
         var _loc4_:int = 0;
         while(_loc4_ < GWizMachSettings.MachinesList.length)
         {
            if((_loc5_ = GWizMachSettings.MachinesList.getItemAt(_loc4_)).name == param1)
            {
               if(!param3)
               {
                  return;
               }
               _loc5_.name = param2.name;
               _loc5_.make = param2.make;
               _loc5_.model = param2.model;
               _loc5_.type = param2.type;
               _loc5_.taperType = param2.taperType;
               _loc5_.taperSize = param2.taperSize;
               _loc5_.rpmLimit = param2.rpmLimit;
               _loc5_.rpmMinLimit = param2.rpmMinLimit;
               _loc5_.feedLimit = param2.feedLimit;
               _loc5_.feedSecMode = param2.feedSecMode;
               _loc5_.hpLimit = param2.hpLimit;
               _loc5_.sfmAdjust = param2.sfmAdjust;
               _loc5_.chiploadAdjust = param2.chiploadAdjust;
               _loc5_.rapids = param2.rapids;
               _loc5_.accel = param2.accel;
               _loc5_.weight = param2.weight;
               _loc5_.simAdj = param2.simAdj;
               _loc5_.adjustMode = param2.adjustMode;
               _loc5_.loRPM = param2.loRPM;
               _loc5_.loHP = param2.loHP;
               _loc5_.peakRPM = param2.peakRPM;
               _loc5_.peakHP = param2.peakHP;
               _loc5_.hiRPM = param2.hiRPM;
               _loc5_.hiHP = param2.hiHP;
               _loc5_.tsc = param2.tsc;
               _loc5_.pcn = param2.pcn;
               _loc5_.flood = param2.flood;
               _loc5_.mist = param2.mist;
               _loc5_.slots = param2.slots;
               _loc5_.tcTime = param2.tcTime;
               _loc5_.xTravel = param2.xTravel;
               _loc5_.yTravel = param2.yTravel;
               _loc5_.zTravel = param2.zTravel;
               _loc5_.spindletime = param2.spindletime;
               _loc5_.wordtime = param2.wordtime;
               if(!param2.hasOwnProperty("hourly"))
               {
                  param2.hourly = 60;
               }
               _loc5_.hourly = param2.hourly;
               _loc5_.cooltime = param2.cooltime;
               _loc5_.controller = param2.controller;
               if(_loc5_.controller == "")
               {
                  _loc5_.controller = _loc5_.name;
               }
               _loc5_.fourthAxis = param2.fourthAxis;
               _loc5_.parallelAxis = param2.parallelAxis;
               _loc5_.rapidsRate = param2.rapidsRate;
               _loc5_.xCenter = param2.xCenter;
               _loc5_.yCenter = param2.yCenter;
               _loc5_.zCenter = param2.zCenter;
               _loc5_.version = param2.version;
               if(!param2.hasOwnProperty("changeDate"))
               {
                  param2.changeDate = new Date();
                  param2.sessions = 0;
               }
               _loc5_.changeDate = param2.changeDate;
               _loc5_.sessions = param2.sessions;
               _loc5_.ignoreSpindleSpeedGCodes = param2.ignoreSpindleSpeedGCodes;
               _loc5_.ignoreToolchangeGCodes = param2.ignoreToolchangeGCodes;
               GWizMachSettings.MachinesList.setItemAt(_loc5_,_loc4_);
               return;
            }
            _loc4_++;
         }
         GWizMachSettings.MachinesList.addItem(param2);
         GWizMachSettings.newMachineCC.callChain(param2.name);
      }
      
      public static function machinesFileExists(param1:String) : Boolean
      {
         var _loc2_:File = new File(param1);
         _loc2_ = _loc2_.resolvePath(GWizMachSettings.MACHINES_FILE_NAME);
         return _loc2_.exists;
      }
      
      public static function loadMachines() : void
      {
         var machinesFile:File = null;
         var stream:FileStream = null;
         var ext:String = null;
         var msg:String = null;
         loadTime = new Date();
         var loadError:Boolean = false;
         try
         {
            machinesFile = getMachineProfileFile();
            if(machinesFile.exists)
            {
               stream = new FileStream();
               ext = machinesFile.url.substr(machinesFile.url.length - 3,3);
               if(ext.toUpperCase() == "CSV")
               {
                  GWizMachSettings.MachinesList = GWizCSVUtils.loadCSVFile(machinesFile);
                  if(GWizSettings.DEBUG_SHARING)
                  {
                     log.debug("Machines load from \'" + machinesFile.nativePath + "\'");
                  }
                  loadError = checkMachinesList();
                  GWizUtils.arrayCollectionSort(MachinesList,"name",false);
               }
               else
               {
                  stream.open(machinesFile,FileMode.READ);
                  processXMLData(stream);
               }
            }
            else
            {
               downloadDefaultMachinesFromCNCCookbook();
            }
         }
         catch(e:Error)
         {
            msg = "Error loading machine profiles." + " ID = " + e.errorID + " msg = " + e.message + " name = " + e.name;
            GWizUtils.LogError(msg);
            GWizPopUpManager.Show(msg,"Error loading machine profiles",GWizPopUpManager.WARN);
         }
         loadMyShop();
      }
      
      private static function downloadDefaultMachinesFromCNCCookbook(param1:Boolean = true) : void
      {
         addAllAndSave = param1;
         GWizCSVUtils.downloadCSV(MACHINE_DB,downloadMachines);
      }
      
      private static function downloadMachines(param1:ArrayCollection) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(param1)
         {
            if(GWizMachSettings.MachinesList.length <= 0)
            {
               GWizMachSettings.MachinesList = param1;
            }
            else
            {
               _loc2_ = 0;
               while(_loc2_ < param1.length)
               {
                  _loc3_ = param1.getItemAt(_loc2_);
                  updateMachinesList(_loc3_.name,_loc3_,false);
                  _loc2_++;
               }
            }
         }
         saveMachines();
      }
      
      public static function backupLocal() : String
      {
         var _loc2_:File = null;
         var _loc3_:File = null;
         var _loc1_:* = "Error";
         try
         {
            _loc2_ = getMachineProfileFile(true);
            if(_loc2_.exists)
            {
               _loc3_ = GWizSettings.getPrefsFile(MACHINES_CSV_FILE_NAME + ".BAK");
               _loc1_ = GWizMachSettings.MACHINES_CSV_FILE_NAME + ".BAK";
               _loc2_.copyTo(_loc3_,true);
            }
         }
         catch(e:Error)
         {
         }
         return _loc1_;
      }
      
      public static function newerMachinesAvailable() : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:File = null;
         var _loc4_:Date = null;
         var _loc1_:Boolean = false;
         try
         {
            _loc2_ = GWizSettings.prefs.sharingDir;
            if(GWizSettings.prefs.sharePrefs && GWizMachSettings.machinesFileExists(_loc2_))
            {
               _loc3_ = getMachineProfileFile();
               if(_loc3_.exists)
               {
                  _loc4_ = _loc3_.modificationDate;
                  if(loadTime.valueOf() < _loc4_.valueOf())
                  {
                     _loc1_ = true;
                  }
               }
            }
         }
         catch(e:Error)
         {
         }
         return _loc1_;
      }
      
      private static function processXMLData(param1:FileStream) : void
      {
         machinesXML = XML(param1.readUTFBytes(param1.bytesAvailable));
         param1.close();
         GWizUtils.XMLToArrayCollection(machinesXML,GWizMachSettings.MachinesList);
         cleanMachinesList(true);
      }
      
      public static function cleanName(param1:String) : String
      {
         var _loc2_:RegExp = null;
         while(param1.indexOf("<name>") != -1)
         {
            _loc2_ = /<name>/;
            param1 = param1.replace(_loc2_,"");
         }
         while(param1.indexOf("</name>") != -1)
         {
            _loc2_ = /<\/name>/;
            param1 = param1.replace(_loc2_,"");
         }
         param1 = GWizFileUtils.fixInvalidFilename(param1,"");
         return StringUtil.trim(param1);
      }
      
      private static function cleanMachinesList(param1:Boolean) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Boolean = false;
         var _loc6_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < GWizMachSettings.MachinesList.length)
         {
            _loc4_ = GWizMachSettings.MachinesList.getItemAt(_loc3_);
            _loc5_ = false;
            _loc6_ = _loc4_.name;
            _loc4_.name = cleanName(_loc6_);
            if(_loc4_.name != _loc6_)
            {
               _loc2_ = true;
            }
            if(_loc4_.name == "")
            {
               _loc5_ = true;
            }
            else if(_loc4_.controller == "")
            {
               _loc4_.controller = _loc4_.name.toString();
            }
            if(!_loc4_.hasOwnProperty("adjustMode"))
            {
               _loc4_.adjustMode = GWizSpindleCurve.NO_ADJUST;
               if(_loc4_.hasOwnProperty("doadjhp") && _loc4_.doadjhp == "true")
               {
                  _loc4_.adjustMode = GWizSpindleCurve.WEIGHT_ADJUST;
               }
            }
            if(!_loc4_.hasOwnProperty("rpmMinLimit") || isNaN(_loc4_.rpmMinLimit))
            {
               _loc4_.rpmMinLimit = 0;
            }
            _loc4_.version = GWizSettings.loginBar.appVersionParm;
            if(!_loc5_ && param1)
            {
               GWizMachSettings.newMachineCC.callChain(_loc4_.name);
            }
            if(_loc5_)
            {
               GWizMachSettings.MachinesList.removeItemAt(_loc3_);
               _loc3_--;
               _loc2_ = true;
            }
            _loc3_++;
         }
         if(_loc2_)
         {
            saveMachines();
         }
      }
      
      public static function saveMachines() : void
      {
         var _loc1_:GWizJustASec = new GWizJustASec(saveMachinesAux);
      }
      
      public static function saveMachinesAux() : void
      {
         var _loc1_:File = null;
         GWizUtils.LogError("GWizMachSettings.saveMachinesAux");
         if(GWizSettings.prefs.sharePrefs && !GWizAbstractPrefs.gotLock())
         {
            return;
         }
         if(GWizMachSettings.MachinesList.filterFunction != null)
         {
            GWizMachSettings.MachinesList.filterFunction = null;
            GWizMachSettings.MachinesList.refresh();
         }
         var _loc2_:String = GWizSettings.prefs.sharingDir;
         if(_loc2_ != "" && GWizSettings.prefs.sharePrefs)
         {
            _loc1_ = new File(_loc2_);
            _loc1_ = _loc1_.resolvePath(GWizMachSettings.MACHINES_CSV_FILE_NAME);
            saveMachinesCSV(_loc1_);
         }
         _loc1_ = GWizSettings.getPrefsFile(MACHINES_CSV_FILE_NAME);
         saveMachinesCSV(_loc1_);
      }
      
      public static function getMachineProfileFile(param1:Boolean = false) : File
      {
         var _loc2_:File = GWizAbstractPrefs.getShareablePrefsFile(GWizMachSettings.MACHINES_CSV_FILE_NAME);
         if(!_loc2_.exists || param1)
         {
            _loc2_ = GWizAbstractPrefs.getShareablePrefsFile(GWizMachSettings.MACHINES_FILE_NAME);
         }
         return _loc2_;
      }
      
      private static function getMyShopsFile(param1:Boolean = false) : File
      {
         var _loc2_:File = GWizAbstractPrefs.getShareablePrefsFile(GWizMachSettings.MYSHOP_CSV_FILE_NAME);
         if(!_loc2_.exists || param1)
         {
            _loc2_ = GWizAbstractPrefs.getShareablePrefsFile(GWizMachSettings.MYSHOP_CSV_FILE_NAME);
         }
         return _loc2_;
      }
      
      private static function checkMachinesList() : Boolean
      {
         var _loc6_:String = null;
         var _loc1_:ArrayCollection = GWizMachSettings.MachinesList;
         var _loc2_:Boolean = false;
         if(_loc1_.length <= 0)
         {
            _loc2_ = true;
         }
         var _loc3_:Object = _loc1_.getItemAt(0);
         var _loc4_:int = 0;
         while(_loc4_ < machProfileFieldList.length)
         {
            _loc6_ = machProfileFieldList[_loc4_];
            if(!_loc3_.hasOwnProperty(_loc6_))
            {
               _loc2_ = true;
            }
            if(_loc6_ == "name")
            {
               break;
            }
            _loc4_++;
         }
         _loc1_ = cleanMachList(_loc1_);
         if(GWizAbstractPrefs.isOEM && GWizAbstractPrefs.oemStr == GWizAbstractPrefs.GARR_OEM_STR)
         {
            _loc1_ = oemListFilter(_loc1_);
         }
         GWizMachSettings.MachinesList = _loc1_;
         var _loc5_:String = GWizMachSettings.currMachine;
         GWizMachSettings.currMachine = _loc5_;
         return _loc2_;
      }
      
      private static function oemListFilter(param1:ArrayCollection) : ArrayCollection
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1.getItemAt(_loc2_);
            if(GWizAbstractPrefs.isOEM && GWizAbstractPrefs.oemStr == GWizAbstractPrefs.GARR_OEM_STR)
            {
               if(String(_loc3_.type).toLowerCase() == "router")
               {
                  param1.removeItemAt(_loc2_);
                  _loc2_ = Math.max(-1,_loc2_ - 1);
               }
               else if(Number(_loc3_.hpLimit) <= 5)
               {
                  param1.removeItemAt(_loc2_);
                  _loc2_ = Math.max(-1,_loc2_ - 1);
               }
            }
            _loc2_++;
         }
         return param1;
      }
      
      private static function cleanMachList(param1:ArrayCollection) : ArrayCollection
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         nameHash = new Object();
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1.getItemAt(_loc2_);
            if(String(_loc3_.feedSecMode).toLowerCase() != "true")
            {
               _loc3_.feedSecMode = "FALSE";
            }
            if(_loc3_.vmcRigidity != "TRUE")
            {
               _loc3_.vmcRigidity = "FALSE";
            }
            if(nameHash.hasOwnProperty(_loc3_.name))
            {
               _loc4_ = 1;
               _loc5_ = _loc3_.name;
               while(nameHash.hasOwnProperty(_loc3_.name) && _loc4_ < 500)
               {
                  _loc3_.name = _loc5_ + " " + String(_loc4_);
                  _loc4_++;
               }
            }
            nameHash[_loc3_.name] = true;
            _loc2_++;
         }
         return GWizUtils.deDupeAC(param1,machProfileFieldList);
      }
      
      private static function saveMachinesCSV(param1:File) : void
      {
         if(!GWizSettings.saveMachines)
         {
            return;
         }
         if(!GWizMachSettings.checkMachinesList())
         {
            cleanMachineData();
            cleanMachinesList(false);
            GWizCSVUtils.saveCSVFile(param1,GWizMachSettings.MachinesList,machProfileFieldList);
            saveMyShopCSV();
         }
      }
      
      private static function saveMachinesXML(param1:File) : void
      {
         var item:Object = null;
         var done:Boolean = false;
         var j:int = 0;
         var stream:FileStream = null;
         var f:File = param1;
         if(!GWizSettings.saveMachines)
         {
            return;
         }
         cleanMachineData();
         var outputString:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
         outputString += "<root>\n";
         var i:int = 0;
         while(i < GWizMachSettings.MachinesList.length)
         {
            item = GWizMachSettings.MachinesList.getItemAt(i);
            outputString += "  <item>\n";
            outputString += "    <name>" + item.name + "</name>\n";
            outputString += "    <make>" + item.make + "</make>\n";
            outputString += "    <model>" + item.model + "</model>\n";
            outputString += "    <type>" + item.type + "</type>\n";
            outputString += "    <taperType>" + item.taperType + "</taperType>\n";
            outputString += "    <taperSize>" + item.taperSize + "</taperSize>\n";
            outputString += "    <rpmLimit>" + item.rpmLimit + "</rpmLimit>\n";
            outputString += "    <rpmMinLimit>" + item.rpmMinLimit + "</rpmMinLimit>\n";
            outputString += "    <feedLimit>" + item.feedLimit + "</feedLimit>\n";
            outputString += "    <hpLimit>" + item.hpLimit + "</hpLimit>\n";
            outputString += "    <sfmAdjust>" + item.sfmAdjust + "</sfmAdjust>\n";
            outputString += "    <chiploadAdjust>" + item.chiploadAdjust + "</chiploadAdjust>\n";
            outputString += "    <rapids>" + item.rapids + "</rapids>\n";
            outputString += "    <accel>" + item.accel + "</accel>\n";
            outputString += "    <weight>" + item.weight + "</weight>\n";
            outputString += "    <adjustMode>" + item.adjustMode + "</adjustMode>\n";
            if(item.hasOwnProperty(GWizSpindleCurve.SPINDLE_CURVE + "0" + "RPM"))
            {
               done = false;
               j = 0;
               done = !item.hasOwnProperty(GWizSpindleCurve.SPINDLE_CURVE + j + "RPM");
               while(!done)
               {
                  done = !item.hasOwnProperty(GWizSpindleCurve.SPINDLE_CURVE + j + "RPM");
                  outputString += "    <" + GWizSpindleCurve.SPINDLE_CURVE + j + "RPM" + ">" + item[GWizSpindleCurve.SPINDLE_CURVE + j + "RPM"] + "</" + GWizSpindleCurve.SPINDLE_CURVE + j + "RPM" + ">\n";
                  outputString += "    <" + GWizSpindleCurve.SPINDLE_CURVE + j + "HP" + ">" + item[GWizSpindleCurve.SPINDLE_CURVE + j + "HP"] + "</" + GWizSpindleCurve.SPINDLE_CURVE + j + "HP" + ">\n";
                  j++;
                  done = !item.hasOwnProperty(GWizSpindleCurve.SPINDLE_CURVE + j + "RPM");
                  done = done && j < 100;
               }
            }
            else
            {
               outputString += "    <loRPM>" + item.loRPM + "</loRPM>\n";
               outputString += "    <loHP>" + item.loHP + "</loHP>\n";
               outputString += "    <peakRPM>" + item.peakRPM + "</peakRPM>\n";
               outputString += "    <peakHP>" + item.peakHP + "</peakHP>\n";
               outputString += "    <hiRPM>" + item.hiRPM + "</hiRPM>\n";
               outputString += "    <hiHP>" + item.hiHP + "</hiHP>\n";
            }
            outputString += "    <simAdj>" + item.simAdj + "</simAdj>\n";
            outputString += "    <tsc>" + item.tsc + "</tsc>\n";
            outputString += "    <pcn>" + item.pcn + "</pcn>\n";
            outputString += "    <flood>" + item.flood + "</flood>\n";
            outputString += "    <mist>" + item.mist + "</mist>\n";
            outputString += "    <slots>" + item.slots + "</slots>\n";
            outputString += "    <tcTime>" + item.tcTime + "</tcTime>\n";
            outputString += "    <xTravel>" + item.xTravel + "</xTravel>\n";
            outputString += "    <yTravel>" + item.yTravel + "</yTravel>\n";
            outputString += "    <zTravel>" + item.zTravel + "</zTravel>\n";
            outputString += "    <spindletime>" + item.spindletime + "</spindletime>\n";
            outputString += "    <wordtime>" + item.wordtime + "</wordtime>\n";
            outputString += "    <hourly>" + item.hourly + "</hourly>\n";
            outputString += "    <cooltime>" + item.cooltime + "</cooltime>\n";
            outputString += "    <controller>" + item.controller + "</controller>\n";
            outputString += "    <fourthAxis>" + item.fourthAxis + "</fourthAxis>\n";
            outputString += "    <parallelAxis>" + item.parallelAxis + "</parallelAxis>\n";
            outputString += "    <rapidsRate>" + item.rapidsRate + "</rapidsRate>\n";
            outputString += "    <xCenter>" + item.xCenter + "</xCenter>\n";
            outputString += "    <yCenter>" + item.yCenter + "</yCenter>\n";
            outputString += "    <zCenter>" + item.zCenter + "</zCenter>\n";
            outputString += "    <version>" + item.version + "</version>\n";
            outputString += "  </item>\n";
            i++;
         }
         outputString += "</root>\n";
         cleanMachinesList(false);
         try
         {
            outputString = outputString.replace(/\n/g,File.lineEnding);
            stream = new FileStream();
            stream.open(f,FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error saving machine profiles.");
         }
      }
      
      private static function cleanMachineData() : void
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         while(_loc1_ < GWizMachSettings.MachinesList.length)
         {
            _loc2_ = GWizMachSettings.MachinesList.getItemAt(_loc1_);
            if(_loc2_.tcTime == 0)
            {
               _loc2_.tcTime = 3;
            }
            if(!_loc2_.hasOwnProperty("rpmMinLimit") || isNaN(_loc2_.rpmMinLimit))
            {
               _loc2_.rpmMinLimit = 0;
            }
            if(!_loc2_.hasOwnProperty("adjustMode"))
            {
               _loc2_.adjustMode = GWizSpindleCurve.NO_ADJUST;
               if(_loc2_.hasOwnProperty("doadjhp") && _loc2_.doadjhp == "true")
               {
                  _loc2_.adjustMode = GWizSpindleCurve.WEIGHT_ADJUST;
               }
            }
            if(!_loc2_.hasOwnProperty("simAdj"))
            {
               _loc2_.simAdj = 100;
            }
            if(!_loc2_.hasOwnProperty("hourly"))
            {
               _loc2_.hourly = 60;
            }
            if(!_loc2_.hasOwnProperty("tsc"))
            {
               _loc2_.tsc = false;
            }
            if(!_loc2_.hasOwnProperty("pcn"))
            {
               _loc2_.pcn = false;
            }
            if(!_loc2_.hasOwnProperty("fourthAxis"))
            {
               _loc2_.fourthAxis = "A";
            }
            if(!_loc2_.hasOwnProperty("parallelAxis"))
            {
               _loc2_.parallelAxis = "X";
            }
            if(!_loc2_.hasOwnProperty("rapidsRate"))
            {
               _loc2_.rapidsRate = 1800;
            }
            if(!_loc2_.hasOwnProperty("xCenter"))
            {
               _loc2_.xCenter = 0;
            }
            if(!_loc2_.hasOwnProperty("yCenter"))
            {
               _loc2_.yCenter = 0;
            }
            if(!_loc2_.hasOwnProperty("zCenter"))
            {
               _loc2_.zCenter = 0;
            }
            if(!_loc2_.hasOwnProperty("version"))
            {
               _loc2_.version = GWizSettings.loginBar.appVersionParm;
            }
            if(!_loc2_.hasOwnProperty("changeDate"))
            {
               _loc2_.changeDate = new Date();
               _loc2_.sessions = 0;
            }
            _loc1_++;
         }
      }
      
      public static function addToMyShop(param1:String, param2:String, param3:String) : void
      {
         var _loc6_:Object = null;
         var _loc4_:int = 0;
         while(_loc4_ < MyShopMachinesList.length)
         {
            if((_loc6_ = MyShopMachinesList.getItemAt(_loc4_)).name == param1)
            {
               _loc6_.make = param2;
               _loc6_.model = param3;
               return;
            }
            _loc4_++;
         }
         var _loc5_:Object;
         (_loc5_ = new Object()).name = param1;
         _loc5_.make = param2;
         _loc5_.model = param3;
         MyShopMachinesList.addItem(_loc5_);
      }
      
      private static function loadMyShop() : void
      {
         var shopFile:File = null;
         var stream:FileStream = null;
         var loadError:Boolean = false;
         try
         {
            shopFile = getMyShopsFile();
            if(shopFile.exists)
            {
               stream = new FileStream();
               GWizMachSettings.MyShopMachinesList = GWizCSVUtils.loadCSVFile(shopFile);
               if(GWizSettings.DEBUG_SHARING)
               {
                  log.debug("MyShop load from \'" + shopFile.nativePath + "\'");
               }
               GWizUtils.arrayCollectionSort(MyShopMachinesList,"description",false);
               checkMyShop(MyShopMachinesList);
            }
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error loading my shop data.");
            loadError = true;
         }
         if(!loadError)
         {
         }
      }
      
      private static function saveMyShopCSV() : void
      {
         if(!GWizSettings.saveMachines)
         {
            return;
         }
         GWizCSVUtils.saveCSVFile(getMyShopsFile(),GWizMachSettings.MyShopMachinesList,myShopFieldList);
      }
      
      private static function checkMyShop(param1:ArrayCollection) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               _loc3_ = param1.getItemAt(_loc2_);
               _loc4_ = lookupMachineIdx(_loc3_.name);
               if((_loc5_ = MachinesList.getItemAt(_loc4_)).name != _loc3_.name)
               {
                  param1.removeItemAt(_loc2_);
                  _loc2_ = 0;
               }
               _loc2_++;
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get MachinesList() : ArrayCollection
      {
         return GWizMachSettings._2019907562MachinesList;
      }
      
      public static function set MachinesList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMachSettings._2019907562MachinesList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMachSettings,"MachinesList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get Control() : String
      {
         return GWizMachSettings._1678770883Control;
      }
      
      public static function set Control(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMachSettings._1678770883Control;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMachSettings,"Control",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get MyShopMachinesList() : ArrayCollection
      {
         return GWizMachSettings._1535399988MyShopMachinesList;
      }
      
      public static function set MyShopMachinesList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMachSettings._1535399988MyShopMachinesList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMachSettings,"MyShopMachinesList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._bindingEventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.willTrigger(param1);
      }
   }
}
