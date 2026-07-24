package post
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import machines.GWizMachSettings;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizGCParseData implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizGCParseData");
      
      private static var initialized:Boolean = false;
      
      public static const MACRO_FILE_UNAVAILABLE:String = "UNAVAILABLE";
      
      public static const MACRO_FILE_IGNORE:String = "IGNORE";
      
      public static const MACRO_FILE_MACRO_PREFIX:String = "MACRO";
      
      public static var defaultMCodes:ArrayCollection = null;
      
      private static var _2025240615MCodes:ArrayCollection;
      
      public static var defaultGCodes:ArrayCollection = null;
      
      private static var _2097951775GCodes:ArrayCollection = null;
      
      private static var _1785227030OtherCodes:ArrayCollection = new ArrayCollection([{
         "code":"F",
         "hint":"Set feedrate",
         "parameters":""
      },{
         "code":"S",
         "hint":"Set spindle speed",
         "parameters":""
      },{
         "code":"T",
         "hint":"Select tool",
         "parameters":""
      },{
         "code":"O",
         "hint":"sub/endsub, while/endwhile, if/else/endif, do/while, call, break/continue/return",
         "parameters":""
      },{
         "code":"(...)",
         "hint":"Comment",
         "parameters":""
      },{
         "code":"(MSG ...)",
         "hint":"Display popup message to operator",
         "parameters":""
      }]);
      
      private static var _866944620CodeTypes:Array = ["M-Code","Motion","Coordinate","Canned","Compensation","Other"];
      
      private static var thisMachine:String = GWizMachSettings.currMachine;
      
      private static var firstLoad:Boolean = true;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizGCParseData()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         init();
      }
      
      private static function init() : void
      {
         if(!initialized)
         {
            MCodes = new ArrayCollection([{
               "code":"0",
               "hint":"Program Stop, no rewind, modes intact (non-optional)",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"1",
               "hint":"Optional Stop, no rewind, modes intact: Operator Selected to Enable",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"2",
               "hint":"End of Program",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"3",
               "hint":"Spindle ON (CW rotation)",
               "parameters":"S",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"4",
               "hint":"Spindle ON (CCW rotation)",
               "parameters":"S",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"5",
               "hint":"Spindle Stop",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"6",
               "hint":"Tool Change",
               "parameters":"T",
               "enabled":"yes",
               "uses":"T designates the tool. M6 initiates the tool change. Use G43 to add tool length comp.",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"7",
               "hint":"Mist Coolant ON",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"8",
               "hint":"Flood Coolant ON",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"9",
               "hint":"Coolant OFF",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"10",
               "hint":"Clamps ON - Chuck on Lathes",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"11",
               "hint":"Clamps OFF - Chuck on Lathes",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"13",
               "hint":"Spindle ON CW + Coolant ON",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"14",
               "hint":"Spindle ON CCW + Coolant ON",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"16",
               "hint":"Air Blast / Tool Changer",
               "parameters":"",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"18",
               "hint":"Air Blast OFF",
               "parameters":"",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"19",
               "hint":"Spindle Orient ON",
               "parameters":"",
               "enabled":"IGNORE",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"20",
               "hint":"Spindle Orient OFF",
               "parameters":"",
               "enabled":"IGNORE",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"21",
               "hint":"Tool Magazine RIGHT",
               "parameters":"",
               "enabled":"IGNORE",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"22",
               "hint":"Tool Magazine LEFT",
               "parameters":"",
               "enabled":"IGNORE",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"23",
               "hint":"Tool Magazine UP",
               "parameters":"",
               "enabled":"IGNORE",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"24",
               "hint":"Tool Magazine DOWN",
               "parameters":"",
               "enabled":"IGNORE",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"25",
               "hint":"Tool Clamp",
               "parameters":"",
               "enabled":"IGNORE",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"26",
               "hint":"Tool Unclamp",
               "parameters":"",
               "enabled":"IGNORE",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"29",
               "hint":"Rigid Tapping Mode",
               "parameters":"",
               "enabled":"IGNORE",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"30",
               "hint":"End of program with rewind",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"36",
               "hint":"Parts Catcher ON - Pallet Changer for Mills",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"37",
               "hint":"Parts Catcher OFF - Pallet Changer for Mills",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"41",
               "hint":"Gear Selection: 1st Gear",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"L"
            },{
               "code":"42",
               "hint":"Gear Selection: 2nd Gear",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"L"
            },{
               "code":"43",
               "hint":"Gear Selection: 3rd Gear",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"L"
            },{
               "code":"44",
               "hint":"Gear Selection: 4th Gear",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"L"
            },{
               "code":"47",
               "hint":"Repeat program from first line.",
               "parameters":"",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"48",
               "hint":"Allow spindle/feedrate override",
               "parameters":"",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"49",
               "hint":"Disable spindle/feedrate override",
               "parameters":"",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"50",
               "hint":"Feedrate override control",
               "parameters":"P0 P1",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"51",
               "hint":"Spindle speed override control",
               "parameters":"P0 P1",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"52",
               "hint":"Adaptive feed control",
               "parameters":"P0 P1",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"53",
               "hint":"Feed stop control",
               "parameters":"P0 P1",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"60",
               "hint":"Exchange pallet shuttles and pause",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"61",
               "hint":"Load Pallet #1",
               "parameters":"",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"62",
               "hint":"Load Pallet #2",
               "parameters":"",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"97",
               "hint":"Haas-style Subroutine Call",
               "parameters":"P L",
               "enabled":"yes",
               "type":"M-Code",
               "uses":"Call a subprogram. P gives the N-line, L gives the number of times to repeat the subprogram.",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"98",
               "hint":"Subprogram Call",
               "parameters":"P L",
               "enabled":"yes",
               "type":"M-Code",
               "uses":"Call a subprogram. P gives the O-line, L gives the number of times to repeat the subprogram.",
               "type":"M-Code",
               "machine":"ML"
            },{
               "code":"99",
               "hint":"Subprogram Cancel",
               "parameters":"",
               "enabled":"yes",
               "type":"M-Code",
               "machine":"ML"
            }]);
            GCodes = new ArrayCollection([{
               "code":"0",
               "hint":"Rapid positioning (move at rapids speed)",
               "parameters":"XYZ Endpoint",
               "enabled":"yes",
               "type":"Motion",
               "uses":"Move in a straight line at rapids speed.",
               "machine":"ML"
            },{
               "code":"1",
               "hint":"Linear interpolation (move in a straight line at feed speed to XYZ)",
               "parameters":"XYZ Endpoint",
               "enabled":"yes",
               "type":"Motion",
               "uses":"Move in a straight line at the last speed commanded by a (F)eedrate change.",
               "machine":"ML"
            },{
               "code":"2",
               "hint":"Clockwise circular interpolation (move in a circular arc at feed speed)",
               "parameters":"Offset I J K or Radius R + XYZ Endpoint",
               "enabled":"yes",
               "type":"Motion",
               "uses":"Move in a clockwise arc from current location to XYZ endpoint.  Arc radius is described by R or by offset IJK from current position. G17/18/19 select the plane of the arc.",
               "machine":"ML"
            },{
               "code":"3",
               "hint":"Counter-clockwise circular interpolation (move in a circular arc at feed speed)",
               "parameters":"Offset I J K or Radius R + XYZ Endpoint",
               "enabled":"yes",
               "type":"Motion",
               "uses":"Move in a counter-clockwise arc from current location to XYZ endpoint.  Arc radius is described by R or by offset IJK from current position. G17/18/19 select the plane of the arc.",
               "machine":"ML"
            },{
               "code":"4",
               "hint":"Dwell: Stop for a specified time of (P)milli seconds or (X) seconds",
               "parameters":"P X",
               "enabled":"yes",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"5",
               "hint":"FADAL style non-modal rapids",
               "parameters":"XYZ Endpoint",
               "enabled":"no",
               "type":"Motion",
               "uses":"Move in a straight line at rapids speed then revert to prior mode.",
               "machine":"M"
            },{
               "code":"6",
               "hint":"Fagor style non-modal absolute arc centers",
               "parameters":"IJK",
               "enabled":"no",
               "type":"Motion",
               "uses":"Treat IJK as arc center in workpiece coordinates.",
               "machine":"M"
            },{
               "code":"7",
               "hint":"Imaginary axis designation",
               "parameters":"",
               "type":"Other",
               "machine":"ML"
            },{
               "code":"9",
               "hint":"Exact stop check (just this block)",
               "parameters":"",
               "enabled":"yes",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"10",
               "hint":"Programmable Parameter Input",
               "parameters":"",
               "enabled":"yes",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"11",
               "hint":"Programmable Parameter Cancel",
               "parameters":"",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"12",
               "hint":"CW Circle Cutting",
               "parameters":"Z I K Q L D F",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "notes":"Conventional milling",
               "machine":"M"
            },{
               "code":"13",
               "hint":"CCW Circle Cutting",
               "parameters":"Z I K Q L D F",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "notes":"Climb milling",
               "machine":"M"
            },{
               "code":"15",
               "hint":"Polar Coordinates Off",
               "parameters":"",
               "type":"Coordinate",
               "enabled":"yes",
               "uses":"Turn off polar coordinates and return to Cartesian.",
               "machine":"M"
            },{
               "code":"16",
               "hint":"Polar Coordinates",
               "parameters":"",
               "type":"Coordinate",
               "enabled":"yes",
               "uses":"Turn on polar coordinates.",
               "machine":"M"
            },{
               "code":"17",
               "hint":"X-Y plane selection",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"18",
               "hint":"X-Z plane selection",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"19",
               "hint":"Y-Z plane selection",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"20",
               "hint":"Programming in inches",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "uses":"Assume all coordinates are in inches. Note: Does not convert coordinates!",
               "machine":"ML"
            },{
               "code":"21",
               "hint":"Programming in mm",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "uses":"Assume all coordinates are in mm. Note: Does not convert coordinates!",
               "machine":"ML"
            },{
               "code":"27",
               "hint":"Reference point return check",
               "parameters":"",
               "enabled":"yes",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"28",
               "hint":"Return to home position",
               "parameters":"XYZABC",
               "enabled":"yes",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"29",
               "hint":"Return from the reference position",
               "parameters":"XYZABS",
               "enabled":"yes",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"30",
               "hint":"Return to 2nd, 3rd, 4th reference point",
               "parameters":"XYZABC P",
               "enabled":"yes",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"31",
               "hint":"Skip function (used for probes and tool length measurement systems)",
               "parameters":"",
               "type":"Other",
               "machine":"ML"
            },{
               "code":"32",
               "hint":"Constant Lead Threading (Like G01 sync\'d to spindle so it threads)",
               "parameters":"F = Lead",
               "type":"Canned",
               "enabled":"yes",
               "machine":"L"
            },{
               "code":"34",
               "hint":"Variable pitch threading",
               "parameters":"F K",
               "type":"Canned",
               "enabled":"yes",
               "machine":"L"
            },{
               "code":"40",
               "hint":"Tool cutter compensation off",
               "parameters":"",
               "enabled":"yes",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"41",
               "hint":"Tool cutter compensation left",
               "parameters":"D L",
               "enabled":"yes",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"42",
               "hint":"Tool cutter compensation right",
               "parameters":"",
               "enabled":"yes",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"43",
               "hint":"Apply tool length compensation (plus)",
               "parameters":"H",
               "enabled":"yes",
               "type":"Compensation",
               "uses":"Add an offset H to the assumed length of the tool. Offset is relative to the G17/18/19 plane.",
               "machine":"ML"
            },{
               "code":"44",
               "hint":"Apply tool length compensation (minus)",
               "parameters":"H",
               "enabled":"yes",
               "type":"Compensation",
               "uses":"Subtract an offset H to the assumed length of the tool. Offset is relative to the G17/18/19 plane.",
               "machine":"ML"
            },{
               "code":"45",
               "hint":"Axis offset single increase",
               "parameters":"",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"46",
               "hint":"Axis offset single decrease",
               "parameters":"",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"47",
               "hint":"Axis offset double increase",
               "parameters":"",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"48",
               "hint":"Axis offset double decrease",
               "parameters":"",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"49",
               "hint":"Tool length compensation cancel",
               "parameters":"",
               "enabled":"yes",
               "type":"Compensation",
               "uses":"Cancel tool length compensation.",
               "machine":"ML"
            },{
               "code":"50",
               "hint":"Reset all scale factors to 1.0",
               "parameters":"",
               "enabled":"yes",
               "type":"Compensation",
               "uses":"Turn off all G51 scaling.",
               "machine":"ML"
            },{
               "code":"51",
               "hint":"Turn on scale factors",
               "parameters":"P X Y Z I J K",
               "enabled":"yes",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"52",
               "hint":"Local workshift for all coordinate systems: add x, y, z offsets",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"53",
               "hint":"Machine coordinate system (cancel work coords)",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"54",
               "hint":"Work coordinate systems: 1st Workpiece",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"55",
               "hint":"Work coordinate systems: 2nd Workpiece",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"56",
               "hint":"Work coordinate systems: 3rd Workpiece",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"57",
               "hint":"Work coordinate systems: 4th Workpiece",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"58",
               "hint":"Work coordinate systems: 5th Workpiece",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"59",
               "hint":"Work coordinate systems: 6th Workpiece",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"60",
               "hint":"Single direction positioning",
               "parameters":"",
               "type":"Other",
               "machine":"ML"
            },{
               "code":"61",
               "hint":"Exact stop check mode",
               "parameters":"",
               "enabled":"yes",
               "type":"Other",
               "uses":"Pauses briefly after each block",
               "machine":"ML"
            },{
               "code":"62",
               "hint":"Automatic corner override",
               "parameters":"",
               "enabled":"yes",
               "type":"Other",
               "uses":"Slows on inside corners to improve surface finish",
               "machine":"ML"
            },{
               "code":"63",
               "hint":"Tapping mode",
               "parameters":"",
               "enabled":"yes",
               "type":"Other",
               "uses":"Exact Stop + Disables FRO and Feed Hold",
               "machine":"ML"
            },{
               "code":"64",
               "hint":"Best Speed Path",
               "parameters":"P",
               "enabled":"yes",
               "type":"Other",
               "machine":"ML"
            },{
               "code":"65",
               "hint":"Custom macro simple call",
               "parameters":"Varies with control",
               "enabled":"yes",
               "type":"Other",
               "machine":"ML"
            },{
               "code":"66",
               "hint":"Custom macro modal call",
               "parameters":"",
               "type":"Other",
               "machine":"ML"
            },{
               "code":"67",
               "hint":"Custom macro modal call",
               "parameters":"",
               "type":"Other",
               "machine":"ML"
            },{
               "code":"68",
               "hint":"Coordinate system rotation ON",
               "parameters":"",
               "enabled":"yes",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"69",
               "hint":"Coordinate system rotation OFF",
               "parameters":"",
               "enabled":"yes",
               "type":"Compensation",
               "machine":"ML"
            },{
               "code":"70",
               "hint":"Finish Turning Cycle",
               "parameters":"",
               "type":"Canned",
               "uses":"",
               "machine":"L"
            },{
               "code":"70",
               "hint":"Inch Units",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "uses":"Assume all coordinates are in inches. Note: Does not convert coordinates!",
               "machine":"M"
            },{
               "code":"71",
               "hint":"Metric Units",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "uses":"Assume all coordinates are in mm. Note: Does not convert coordinates!",
               "machine":"M"
            },{
               "code":"71",
               "hint":"Rough Turning Cycle",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "machine":"L"
            },{
               "code":"72",
               "hint":"Rough Face Cycle",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "machine":"L"
            },{
               "code":"73",
               "hint":"Pattern Repeat Turn Cycle",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "machine":"L"
            },{
               "code":"73",
               "hint":"High speed drilling canned cycle (Small Retract)",
               "parameters":"R L Q",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Peck drilling cycle with short (0.02-0.04\") retract for shallower holes.  Try G82 for deeper holes.",
               "notes":"Use incremental coordinates plus repeat to drill multiple holes.  G98/99 can be used to retract to initial point or not.",
               "machine":"M"
            },{
               "code":"74",
               "hint":"Face Drilling/Groove Cycle",
               "parameters":"",
               "type":"Canned",
               "uses":"",
               "machine":"L"
            },{
               "code":"74",
               "hint":"Left hand tapping canned cycle",
               "parameters":"R L P",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Left hand tapping. CCW going down then spindle reverses to CW at bottom of hole for retract.",
               "notes":"Use incremental coordinates plus repeat to tap multiple holes.",
               "machine":"M"
            },{
               "code":"75",
               "hint":"OD/ID Groove Cutoff Cycle",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "machine":"L"
            },{
               "code":"76",
               "hint":"Multipass Lathe Threading Cycle",
               "parameters":"",
               "parameters":"P R L Q",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "machine":"L"
            },{
               "code":"76",
               "hint":"Fine boring canned cycle",
               "parameters":"P R L Q",
               "enabled":"yes",
               "type":"Canned",
               "uses":"For fine boring, the tool is moved towards center so it is not in contact for retract.",
               "notes":"Use incremental coordinates plus repeat for multiple holes.",
               "machine":"M"
            },{
               "code":"79",
               "hint":"Modify canned cycle",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "machine":"ML"
            },{
               "code":"80",
               "hint":"Cancel canned cycle",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "machine":"ML"
            },{
               "code":"81",
               "hint":"Simple drilling cycle",
               "parameters":"R L",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Straight drilling cycle, no peck. Move to R and then drill to Z at feedrate.  Rapid retract to R depending on G98/G99",
               "notes":"Use incremental coordinates plus repeat for multiple holes.  G98/99 can be used to retract to initial point or not.",
               "machine":"ML"
            },{
               "code":"82",
               "hint":"Drilling cycle with dwell (Counterboring)",
               "parameters":"R L (P)",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Straight drilling cycle, no peck. Move to R and then drill to Z at feedrate. Dwell at bottom then rapid retract to R depending on G98/G99",
               "notes":"Can be more accurate than G81 due to dwell.  Use incremental coordinates plus repeat for multiple holes.  G98/99 can be used to retract to initial point or not.",
               "machine":"ML"
            },{
               "code":"83",
               "hint":"Peck drilling cycle (Full Retract)",
               "parameters":"R L Q",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Peck drilling cycle with full retract for deeper holes.  Try G73 for shallower holes.",
               "notes":"Use incremental coordinates plus repeat to drill multiple holes.  G98/99 can be used to retract to initial point or not.",
               "machine":"ML"
            },{
               "code":"84",
               "hint":"Tapping cycle",
               "parameters":"R L P",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Tapping cycle with dwell.",
               "notes":"Use incremental coordinates plus repeat for multiple holes.  G98/99 can be used to retract to initial point or not.",
               "machine":"ML"
            },{
               "code":"84.2",
               "hint":"Direct right hand tapping canned cycle",
               "parameters":"",
               "type":"Canned",
               "machine":"ML"
            },{
               "code":"85",
               "hint":"Boring canned cycle, No Dwell, Feed Out (G85)",
               "parameters":"R L",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Boring cycle, no dwell. Move to R and then bore to Z at feedrate.  Retract to R at feedrate depending on G98/G99",
               "notes":"Use incremental coordinates plus repeat to for multiple holes.  G98/99 can be used to retract to initial point or not.",
               "machine":"ML"
            },{
               "code":"86",
               "hint":"Boring canned cycle, Spindle Stop, Rapid Out (G86)",
               "parameters":"R L",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Boring cycle, no dwell. Move to R and then bore to Z at feedrate.  Stop spindle, retract to R at rapids depending on G98/G99",
               "notes":"Use incremental coordinates plus repeat to for multiple holes.  G98/99 can be used to retract to initial point or not.",
               "machine":"ML"
            },{
               "code":"87",
               "hint":"Back Boring canned cycle (G87)",
               "parameters":"R K P Q",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Back Boring cycle. Move to R rapid down to Z.  Start spindle, move tool by Q to start cutting, retract to R at feedrate depending on G98/G99",
               "notes":"Use incremental coordinates plus repeat to for multiple holes.  G98/99 can be used to retract to initial point or not.",
               "machine":"M"
            },{
               "code":"87",
               "hint":"Side drilling cycle (G87)",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "notes":"",
               "machine":"L"
            },{
               "code":"88",
               "hint":"Boring canned cycle, Spindle Stop, Manual Out (G88)",
               "parameters":"R K P",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Boring cycle, manual out. Move to R and then bore to Z at feedrate.  Stop spindle, manually retract to R. Next cycle begins when tool gets to R.",
               "notes":"Use incremental coordinates plus repeat to for multiple holes.",
               "machine":"M"
            },{
               "code":"88",
               "hint":"Side tapping cycle (G88)",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "notes":"",
               "machine":"L"
            },{
               "code":"89",
               "hint":"Boring canned cycle, Dwell, Feed Out (G89)",
               "parameters":"R L P",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Boring cycle. Move to R and then bore to Z at feedrate.  Dwell, then retract to R at feedrate depending on G98/G99",
               "notes":"Use incremental coordinates plus repeat to for multiple holes.  G98/99 can be used to retract to initial point or not.",
               "machine":"M"
            },{
               "code":"89",
               "hint":"Side boring cycle (G89)",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "notes":"",
               "machine":"L"
            },{
               "code":"90",
               "hint":"Absolute programming XYZ (type B and C systems)",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "uses":"Coordinates will be specified as absolute positions.",
               "machine":"ML"
            },{
               "code":"90.1",
               "hint":"Absolute programming IJK (type B and C systems)",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"91",
               "hint":"Incremental programming XYZ (type B and C systems)",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "uses":"Coordinates will be specified as offsets relative to the current position.",
               "machine":"ML"
            },{
               "code":"91.1",
               "hint":"Incremental programming IJK (type B and C systems)",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"92",
               "hint":"Offset coordinate system and save parameters",
               "parameters":"X Y Z",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"92.1",
               "hint":"Cancel offset and zero parameters",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"92.2",
               "hint":"Cancel offset and retain parameters",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"92.3",
               "hint":"Offset coordinate system with saved parameters",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"93",
               "hint":"Inverse time feed mode.",
               "parameters":"",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"94",
               "hint":"Units per minute feed mode. Units in inches or mm.",
               "parameters":"",
               "enabled":"yes",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"95",
               "hint":"Units per revolution mode. Units in inches or mm.",
               "parameters":"",
               "enabled":"yes",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"96",
               "hint":"Constant surface speed",
               "enabled":"yes",
               "parameters":"S = SFM, D = Max SFM",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"97",
               "hint":"Constant spindle speed",
               "enabled":"yes",
               "parameters":"S = RPM",
               "type":"Motion",
               "machine":"ML"
            },{
               "code":"98",
               "hint":"Return to Initial Z plane after canned cycle",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Specifies \'old-style\' return to initial Z plane rather than to the R plane at the end of a canned cycle. G99 returns to the R plane.",
               "machine":"ML"
            },{
               "code":"99",
               "hint":"Return to Initial R plane after canned cycle",
               "parameters":"",
               "enabled":"yes",
               "type":"Canned",
               "uses":"Specifies return to the R plane at the end of a canned cycle. G98 returns to the initial Z-plane.",
               "machine":"ML"
            },{
               "code":"154",
               "hint":"Work coordinate systems: P specifies which one (Haas)",
               "parameters":"P",
               "enabled":"yes",
               "type":"Coordinate",
               "machine":"ML"
            },{
               "code":"190",
               "hint":"Diameter programming deactivation",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "uses":"Deactivate means X-axis is radius.",
               "machine":"L"
            },{
               "code":"191",
               "hint":"Diameter programming ON",
               "parameters":"",
               "enabled":"yes",
               "type":"Coordinate",
               "uses":"Diameter programming ON means X-axis is diameter.",
               "machine":"L"
            },{
               "code":"290",
               "hint":"Lathe OD/ID Cutting Cycle",
               "parameters":"XZ UW R F",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "machine":"L"
            },{
               "code":"292",
               "hint":"Lathe Straight Threading Cycle",
               "parameters":"XZ UW Q R F",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "machine":"L"
            },{
               "code":"294",
               "hint":"Lathe Face Cutting Cycle",
               "parameters":"XZ UW R F",
               "enabled":"yes",
               "type":"Canned",
               "uses":"",
               "machine":"L"
            }]);
            defaultMCodes = GWizUtils.clone(MCodes);
            defaultGCodes = GWizUtils.clone(GCodes);
            GWizMachSettings.deleteMachineCC.addFunction("GWizGCParseData",deleteMachine);
            GWizMachSettings.selectMachineCC.addFunction("GWizGCParseData",selectMachine);
            initialized = true;
         }
      }
      
      public static function resetCodes() : void
      {
         init();
         GWizGCParseData.MCodes = GWizGCParseData.resetCodesAux(GWizGCParseData.MCodes,GWizGCParseData.defaultMCodes);
         GWizGCParseData.GCodes = GWizGCParseData.resetCodesAux(GWizGCParseData.GCodes,GWizGCParseData.defaultGCodes);
      }
      
      private static function resetCodesAux(param1:ArrayCollection, param2:ArrayCollection) : ArrayCollection
      {
         return GWizUtils.clone(param2);
      }
      
      public static function typeIndex(param1:String) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < CodeTypes.length)
         {
            if(CodeTypes[_loc2_] == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public static function processEnabled(param1:String, param2:String) : String
      {
         if(param1 == "yes")
         {
            return param2;
         }
         if(param1 == "ignore" || param1 == MACRO_FILE_IGNORE)
         {
            return MACRO_FILE_IGNORE;
         }
         if(param1 && param1.substr(0,MACRO_FILE_MACRO_PREFIX.length) == MACRO_FILE_MACRO_PREFIX)
         {
            return param1.substr(MACRO_FILE_MACRO_PREFIX.length,param1.length);
         }
         return MACRO_FILE_UNAVAILABLE;
      }
      
      private static function deleteMachine(param1:String) : Boolean
      {
         return true;
      }
      
      private static function selectMachine(param1:String) : Boolean
      {
         thisMachine = param1;
         firstLoad = false;
         return true;
      }
      
      public static function codesToPSTFile() : String
      {
         var _loc1_:String = "\n";
         init();
         return _loc1_ + codesToPSTFileAux(GCodes,defaultGCodes,"G") + codesToPSTFileAux(MCodes,defaultMCodes,"M");
      }
      
      private static function codesToPSTFileAux(param1:ArrayCollection, param2:ArrayCollection, param3:String) : String
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:* = false;
         var _loc4_:String = "\n";
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc7_ = param1.getItemAt(_loc5_);
            _loc6_ = 0;
            while(_loc6_ < param2.length)
            {
               _loc8_ = param2.getItemAt(_loc6_);
               if(_loc7_.code == _loc8_.code)
               {
                  break;
               }
               _loc6_++;
            }
            _loc9_ = _loc6_ >= param2.length;
            if(_loc6_ < param2.length)
            {
               if(GWizUtils.debug && _loc7_.code == "76")
               {
                  log.debug("gotcha");
               }
               _loc9_ = Boolean(_loc7_.hint != _loc8_.hint || _loc7_.parameters != _loc8_.parameters || _loc7_.enabled != _loc8_.enabled || _loc7_.uses != _loc8_.uses || _loc7_.type != _loc8_.type || _loc7_.notes != _loc8_.notes);
            }
            if(_loc9_)
            {
               if(!_loc7_.hasOwnProperty("hint"))
               {
                  _loc7_.hint = "";
               }
               if(!_loc7_.hasOwnProperty("parameters"))
               {
                  _loc7_.parameters = "";
               }
               if(!_loc7_.hasOwnProperty("enabled"))
               {
                  _loc7_.enabled = "";
               }
               if(!_loc7_.hasOwnProperty("uses"))
               {
                  _loc7_.uses = "";
               }
               if(!_loc7_.hasOwnProperty("type"))
               {
                  _loc7_.type = "";
               }
               if(!_loc7_.hasOwnProperty("notes"))
               {
                  _loc7_.notes = "";
               }
               _loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = (_loc4_ += param3 + "Codes." + param3 + _loc7_.code + ".Hint = \'" + _loc7_.hint.replace("\'","") + "\';\n") + (param3 + "Codes." + param3 + _loc7_.code + ".Parameters = \'" + _loc7_.parameters.replace("\'","") + "\';\n")) + (param3 + "Codes." + param3 + _loc7_.code + ".Enabled = \'" + _loc7_.enabled.replace("\'","") + "\';\n")) + (param3 + "Codes." + param3 + _loc7_.code + ".Uses = \'" + _loc7_.uses.replace("\'","") + "\';\n")) + (param3 + "Codes." + param3 + _loc7_.code + ".CodeType = \'" + _loc7_.type.replace("\'","") + "\';\n")) + (param3 + "Codes." + param3 + _loc7_.code + ".Notes = \'" + _loc7_.notes.replace("\'","") + "\';\n");
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      public static function savePSTCode(param1:String, param2:String) : Boolean
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc3_:* = false;
         if(param1.indexOf("GCodes.") == 0 || param1.indexOf("MCodes.") == 0)
         {
            init();
            param1 = param1.substr("GCodes.".length);
            _loc4_ = param1.substr(0,param1.indexOf("."));
            param1 = param1.substr(param1.indexOf(".") + 1);
            _loc5_ = _loc4_.charAt(0);
            _loc4_ = _loc4_.substr(1);
            _loc3_ = (_loc6_ = updateOrCreateEntry(_loc5_,Number(_loc4_),param1,param2)) >= 0;
         }
         return _loc3_;
      }
      
      private static function updateOrCreateEntry(param1:String, param2:Number, param3:String, param4:String) : int
      {
         var _loc6_:ArrayCollection = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc5_:int = -1;
         if(GWizUtils.debug && param3 == "1.Hint")
         {
            log.debug("gotcha");
         }
         if(!isNaN(param2))
         {
            _loc6_ = MCodes;
            if(param1 == "G")
            {
               _loc6_ = GCodes;
            }
            _loc7_ = "";
            _loc8_ = 0;
            while(param3.length > 0 && _loc8_ < param3.length && GWizStringUtils.DIGITS.indexOf(param3.charAt(_loc8_)) >= 0)
            {
               _loc7_ += param3.charAt(_loc8_);
               _loc8_++;
            }
            if(_loc7_.length > 0)
            {
               param3 = param3.substr(_loc7_.length);
               if(param3.length > 0 && param3.charAt(0) == ".")
               {
                  param3 = param3.substr(1);
               }
               param2 += Number(String("0." + _loc7_));
            }
            _loc10_ = false;
            _loc11_ = 0;
            while(_loc11_ < _loc6_.length)
            {
               if((_loc9_ = _loc6_.getItemAt(_loc11_)).hasOwnProperty("code") && _loc9_.code == param2)
               {
                  _loc5_ = _loc11_;
                  switch(param3)
                  {
                     case "Hint":
                        _loc9_.hint = param4;
                        break;
                     case "Parameters":
                        _loc9_.parameters = param4;
                        break;
                     case "Enabled":
                        _loc9_.enabled = param4;
                        break;
                     case "Uses":
                        _loc9_.uses = param4;
                        break;
                     case "CodeType":
                        _loc9_.type = param4;
                        break;
                     case "Notes":
                        _loc9_.notes = param4;
                        break;
                     case "Machine":
                        _loc9_.machine = param4;
                        break;
                     default:
                        GWizUtils.assert(false);
                  }
                  _loc10_ = true;
               }
               _loc11_++;
            }
            if(_loc11_ >= _loc6_.length && !_loc10_)
            {
               (_loc9_ = new Object()).code = param2;
               _loc9_.hint = "";
               _loc9_.parameters = "";
               _loc9_.enabled = "no";
               _loc9_.uses = "";
               _loc9_.type = param1 == "G" ? "Other" : "M-Code";
               _loc9_.notes = "";
               _loc9_.machine = "";
               _loc6_.addItemAt(_loc9_,_loc11_);
               _loc5_ = _loc11_;
               switch(param3)
               {
                  case "Hint":
                     _loc9_.hint = param4;
                     break;
                  case "Parameters":
                     _loc9_.parameters = param4;
                     break;
                  case "Enabled":
                     _loc9_.enabled = param4;
                     break;
                  case "Uses":
                     _loc9_.uses = param4;
                     break;
                  case "CodeType":
                     _loc9_.type = param4;
                     break;
                  case "Notes":
                     _loc9_.notes = param4;
                     break;
                  case "Machine":
                     _loc9_.machine = param4;
                     break;
                  default:
                     GWizUtils.assert(false);
               }
            }
         }
         return _loc5_;
      }
      
      [Bindable(event="propertyChange")]
      public static function get MCodes() : ArrayCollection
      {
         return GWizGCParseData._2025240615MCodes;
      }
      
      public static function set MCodes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizGCParseData._2025240615MCodes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizGCParseData,"MCodes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get GCodes() : ArrayCollection
      {
         return GWizGCParseData._2097951775GCodes;
      }
      
      public static function set GCodes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizGCParseData._2097951775GCodes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizGCParseData,"GCodes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get OtherCodes() : ArrayCollection
      {
         return GWizGCParseData._1785227030OtherCodes;
      }
      
      public static function set OtherCodes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizGCParseData._1785227030OtherCodes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizGCParseData,"OtherCodes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get CodeTypes() : Array
      {
         return GWizGCParseData._866944620CodeTypes;
      }
      
      public static function set CodeTypes(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizGCParseData._866944620CodeTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizGCParseData,"CodeTypes",_loc2_,param1));
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
