package post
{
   import comps.GWizPopUpManager;
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
   import utils.GWizFileUtils;
   import utils.GWizUtils;
   
   public dynamic class GWizPostVars implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizPostVars");
      
      private static var tested:Boolean = false;
      
      public static var allocNewSymbol:Function = null;
      
      private static var _12579193genericPostAC:ArrayCollection = new ArrayCollection([{
         "name":"ArcOptions.AllowHelix",
         "type":"Boolean",
         "value":"true",
         "prompt":"Helical Interpolation",
         "hint":"If selected, controller supports helical interpolation."
      },{
         "name":"ArcOptions.ArcEndpointTolerance",
         "type":"Number",
         "value":"0.001",
         "prompt":"Endpoint radius tolerance",
         "hint":"Its an error if distance from radius to endpoints differs by more than this amount."
      },{
         "name":"ArcOptions.AutoIJK",
         "type":"Boolean",
         "value":"false",
         "prompt":"Auto IJK",
         "hint":"Ignore IncrementalIJK and use Auto mode"
      },{
         "name":"ArcOptions.IJKRPrecendence",
         "type":"Boolean",
         "value":"true",
         "prompt":"Give R Precedence",
         "hint":"If selected, when both IJK and R are specified, R has precedence (Fanuc). Otherwise, IJK has precedence."
      },{
         "name":"ArcOptions.IncrementalIJ",
         "type":"Boolean",
         "value":"true",
         "prompt":"Incremental IJK",
         "hint":"IJK is incremental if checked and absolute if not."
      },{
         "name":"ArcOptions.ModalCenter",
         "type":"Boolean",
         "value":"false",
         "prompt":"Modal IJK Centers",
         "hint":""
      },{
         "name":"ArcOptions.ModalRCenter",
         "type":"Boolean",
         "value":"false",
         "prompt":"Modal R Centers",
         "hint":"If selected, R is modal.  Note: With both IJK and R present, IJK are ignored."
      },{
         "name":"AxisOptions.xMult",
         "type":"Number",
         "value":"1.0",
         "prompt":"Multiply all X-Axis values by",
         "hint":"Mostly useful for switching polarity of axis direction--multiply by -1."
      },{
         "name":"AxisOptions.yMult",
         "type":"Number",
         "value":"1.0",
         "prompt":"Multiply all Y-Axis values by",
         "hint":"Mostly useful for switching polarity of axis direction--multiply by -1."
      },{
         "name":"AxisOptions.zMult",
         "type":"Number",
         "value":"1.0",
         "prompt":"Multiply all Z-Axis values by",
         "hint":"Mostly useful for switching polarity of axis direction--multiply by -1."
      },{
         "name":"Comment",
         "type":"String",
         "value":"",
         "prompt":"Comment",
         "hint":"A comment so you can identify your post more easily."
      },{
         "name":"Cycles.CannedRepeatStyle",
         "type":"int",
         "value":"0",
         "prompt":"Canned Cycle Repeat",
         "hint":"0 = Use K for Repeat (Fanuc)\n1 = Use L for Repeat (Haas and Mach3)",
         "min":0,
         "max":1
      },{
         "name":"Cycles.CycleIncrZ",
         "type":"Boolean",
         "value":"false",
         "prompt":"Incremental Z for Depth",
         "hint":"Z is an unsigned incremental value added to initial Z for depth."
      },{
         "name":"Cycles.CycleROptional",
         "type":"Boolean",
         "value":"false",
         "prompt":"Retract: R and G98 Optional",
         "hint":"If no R, retraction to initial Z is assumed."
      },{
         "name":"Cycles.DrillDepthStyle",
         "type":"int",
         "value":"0",
         "prompt":"Canned Drill Depth Style",
         "hint":"0 = Fanuc/Mach3\n1 = Bridgeport DX32 (3 Z values = Total Z, First Peck, Later Pecks)",
         "min":0,
         "max":1
      },{
         "name":"Cycles.PeckRequired",
         "type":"Boolean",
         "value":"0",
         "prompt":"Require Peck Specification",
         "hint":"If true, it is an error to fail to specify a peck depth on drilling cycles that peck."
      },{
         "name":"Cycles.Mach3CannedZ",
         "type":"Boolean",
         "value":"true",
         "prompt":"Adjust Z to be &gt;= R before initial move for Mach3",
         "hint":""
      },{
         "name":"Cycles.HeidenhainPL",
         "type":"Boolean",
         "value":"false",
         "prompt":"Allow Heidenhain-style P01 and L1 on canned cycles",
         "hint":""
      },{
         "name":"Cycles.HeidenhainM99M89",
         "type":"Boolean",
         "value":"false",
         "prompt":"Allow Heidenhain-style M99 and M89 for canned cycles",
         "hint":""
      },{
         "name":"Cycles.FagorVariables",
         "type":"Boolean",
         "value":"false",
         "prompt":"Allow Fagor-style Variables, e.g. (P100 = 10.0)",
         "hint":""
      },{
         "name":"Cycles.LHTapping",
         "type":"String",
         "value":"G74 ZholeBottom RretractZ",
         "prompt":"Post for LH Tapping. Substitutes holeBottom and retractZ values wherever they are written",
         "hint":""
      },{
         "name":"Cycles.ModalCanned",
         "type":"Boolean",
         "value":"true",
         "prompt":"If true, canned cycle is in effect until another mode is commanded.",
         "hint":""
      },{
         "name":"Cycles.RHTapping",
         "type":"String",
         "value":"G84 ZholeBottom RretractZ",
         "prompt":"Post for RH Tapping. Substitutes holeBottom and retractZ values wherever they are written",
         "hint":""
      },{
         "name":"Cycles.RigidTapping",
         "type":"String",
         "value":"M29",
         "prompt":"Code to turn on rigid tapping. Leave blank if not needed.",
         "hint":""
      },{
         "name":"Errors.FeedrateCheck",
         "type":"Boolean",
         "value":"true",
         "prompt":"Show error if cutting with 0 feedrate",
         "hint":""
      },{
         "name":"Errors.SpindleCheck",
         "type":"Boolean",
         "value":"true",
         "prompt":"Show error if cutting without spindle running",
         "hint":""
      },{
         "name":"Errors.ToolCheck",
         "type":"Boolean",
         "value":"true",
         "prompt":"Show error if cutting without tool loaded",
         "hint":""
      },{
         "name":"Errors.ToolCheckMode",
         "type":"int",
         "value":"0",
         "prompt":"Min Tool Slot",
         "hint":"0 = T + M06 required\n1 = T required.",
         "min":0,
         "max":1
      },{
         "name":"FadalLSyntax",
         "type":"Boolean",
         "value":"false",
         "prompt":"Use Fadal L syntax to define and call subprograms",
         "hint":""
      },{
         "name":"FullLineComment",
         "type":"String",
         "value":"%;",
         "prompt":"Full Line Comment",
         "hint":"Rest of line is ignored after any of these characters.  Dont use spaces!"
      },{
         "name":"GCodes.G04.FracWord",
         "type":"String",
         "value":"P",
         "prompt":"G4 Dwell Fractional Word",
         "hint":"Word for dwell period.  Must be a whole number.  Most controls allow a whole word, usually P. Some allow fractional to, usually X."
      },{
         "name":"GCodes.G04.WholeWord",
         "type":"String",
         "value":"P",
         "prompt":"G4 Dwell Whole Word",
         "hint":"Word for dwell period.  May have a decimal point (Fanuc, Not Mach3).  Most controls allow a whole word, usually P. Some allow fractional to, usually X."
      },{
         "name":"GCodes.G10.Style",
         "type":"int",
         "value":"0",
         "prompt":"G10 Style",
         "hint":"0 = G10 Px L1 P Z (Mach3 Tool Length Offset)\n1 = G10 Px L10 P R (Fanuc Tool Length Offset)\n2 = G10 Px Ry (Roland)",
         "min":0,
         "max":2
      },{
         "name":"GCodes.G16.PolarMotions",
         "type":"int",
         "value":"1",
         "prompt":"G16 Style",
         "hint":"0 = G01 Only (Mach3)\n1 = All motions (Fanuc)",
         "min":0,
         "max":1
      },{
         "name":"GCodes.G16.PolarOrigin",
         "type":"int",
         "value":"1",
         "prompt":"G16 Origin Style",
         "hint":"0 = Relative to Curr Point\n1 = G90 Absolute, G91 Relative (Fanuc)\n2 = Relative to G16 (Mach3)",
         "min":0,
         "max":2
      },{
         "name":"GCodes.G51.ScalingStyle",
         "type":"int",
         "value":"2",
         "prompt":"G51 Scaling Style",
         "hint":"0 = Fanuc: P scales all or use to scale IJK individual axes.  XYZ scaling center.\n1 = Haas: P scale factor. IJK scaling center.\n2 = Mach3: XYZ are scale factors for each individual axes.",
         "min":0,
         "max":2
      },{
         "name":"Gcodes.G65.Fanuc",
         "type":"Boolean",
         "value":"true",
         "prompt":"G65 Handling",
         "hint":"Check for G65 PO# L repeat (Fanuc style)"
      },{
         "name":"GCodes.G68.Relative",
         "type":"Boolean",
         "value":"false",
         "prompt":"Mulhintle G68s are relative.",
         "hint":"(Not yet implemented)"
      },{
         "name":"GCodes.G68.Style",
         "type":"int",
         "value":"0",
         "prompt":"G68 Scaling Style",
         "hint":"0 = Fanuc Style (alpha~ beta~ R~)\n1 = Mach3 Style (A~ B~ I~ R~)\n2 = Haas Style (A~ B~ R~)",
         "min":0,
         "max":2
      },{
         "name":"GCodes.G7071Units",
         "type":"Boolean",
         "value":"false",
         "prompt":"Treat G70 as Inches and G71 as mm if true",
         "hint":""
      },{
         "name":"GCodes.G71.Retract",
         "type":"Number",
         "value":"0.05",
         "prompt":"Retract pullback between passes (Setting 73)",
         "hint":""
      },{
         "name":"GCodes.G71.Style",
         "type":"int",
         "value":"0",
         "prompt":"G71/72 Style",
         "hint":"0 = Double Block Fanuc Format (Most Common)\n1 = Single Block Fanuc Format (Haas and Fanuc 10T/11T/15T).",
         "min":0,
         "max":1
      },{
         "name":"GCodes.G71.Type2",
         "type":"Boolean",
         "value":"false",
         "prompt":"Allow Type 2 (pockets)",
         "hint":""
      },{
         "name":"GCodes.G76.Style",
         "type":"int",
         "value":"0",
         "prompt":"G76 Lathe Threading Style",
         "hint":"0 = Double Block Fanuc Format\n1 = Single Block Fanuc Format.\n2 = Haas Format.\n3 = LinuxCNC Format.\n4 = Mach3 Format.\n5 = Centroid Double Block Format",
         "min":0,
         "max":1
      },{
         "name":"IncrUVW",
         "type":"Boolean",
         "value":"true",
         "prompt":"Allow UVW for Incremental XYZ",
         "hint":""
      },{
         "name":"Lathe.LatheXAxisDiameter",
         "type":"Boolean",
         "value":"false",
         "prompt":"X as Diameter",
         "hint":"Check for Diameter (G191), Uncheck for Radius programming (G190). Leave as radius for mills!"
      },{
         "name":"Lathe.AllowLatheChamfer",
         "type":"Boolean",
         "value":"true",
         "prompt":"Lathe Chamfer",
         "hint":"Check to allow automatic chamfer on lathes."
      },{
         "name":"Lathe.AllowLatheCornerRounding",
         "type":"Boolean",
         "value":"true",
         "prompt":"Lathe Corner Round",
         "hint":"Check to allow automatic corner rounding on lathes."
      },{
         "name":"Macros.Colon4Subs",
         "type":"Boolean",
         "value":"true",
         "prompt":"Allow : for O",
         "hint":""
      },{
         "name":"Macros.Goto",
         "type":"Boolean",
         "value":"true",
         "prompt":"Macro GOTO",
         "hint":""
      },{
         "name":"Macros.IfGoto",
         "type":"Boolean",
         "value":"true",
         "prompt":"Macro IF..GOTO",
         "hint":""
      },{
         "name":"Macros.IfThen",
         "type":"Boolean",
         "value":"true",
         "prompt":"Macro IF..THEN",
         "hint":""
      },{
         "name":"Macros.SetVN",
         "type":"Boolean",
         "value":"true",
         "prompt":"Use SETVN for symbolic variable names",
         "hint":""
      },{
         "name":"Macros.LinuxCNCNamedParms",
         "type":"Boolean",
         "value":"false",
         "prompt":"Allow #<name> for symbolic variable names",
         "hint":""
      },{
         "name":"Macros.LinuxCNCFirstNamedParm",
         "type":"int",
         "value":"10000",
         "prompt":"Assign #numbers for symbolic variable names starting here",
         "hint":"",
         "min":0,
         "max":100000
      },{
         "name":"Macros.LinuxCNCSubroutines",
         "type":"Boolean",
         "value":"false",
         "prompt":"Allow LinuxCNC O-word subroutines",
         "hint":""
      },{
         "name":"Macros.While",
         "type":"Boolean",
         "value":"true",
         "prompt":"Macro WHILE..DO..END",
         "hint":""
      },{
         "name":"Macros.WhileNest",
         "type":"int",
         "value":"3",
         "prompt":"Max. WHILE Nesting Level",
         "hint":"",
         "min":0,
         "max":999
      },{
         "name":"MCodes.M98.MaxNest",
         "type":"int",
         "value":"4",
         "prompt":"Max. Subprogram Nesting Level",
         "hint":"",
         "min":0,
         "max":999
      },{
         "name":"MCodes.M98.ReportUndef",
         "type":"Boolean",
         "value":"true",
         "prompt":"Report undefined subprograms as errors. (Leave blank to ignore)",
         "hint":""
      },{
         "name":"MCodes.M98.Style",
         "type":"int",
         "value":"0",
         "prompt":"M98 Subprogram Call Style",
         "hint":"0 = M98/97 not configured, show error if used\n1 = M98 PO# Lrepeat (Mach3, Fanuc, Fadal)\n2 = M98 PO# Krepeat (Older Fanuc)\n3 = M98 Pxxxxyyyy (Fanuc: x = repeat, y = O#, 4 digits required)\n4 = M98 PO# HN# Lrepeat (Mitsubishi)\n5 = M98 Ox (x=O#)\n6 = M98 PO# QN# Lrepeat",
         "min":0,
         "max":6
      },{
         "name":"MCodes.M98.TryNForO",
         "type":"Boolean",
         "value":"true",
         "prompt":"Try N# if O# undefined",
         "hint":""
      },{
         "name":"MCodes.M98.DX32Replace",
         "type":"Boolean",
         "value":"false",
         "prompt":"Convert #, =#, and $ to Fanuc syntax",
         "hint":"Bridgeport DX32 syntax"
      },{
         "name":"MCodes.M99.IgnorePNum",
         "type":"Boolean",
         "value":"true",
         "prompt":"Ignore M99 P# unless in main program (Haas style)",
         "hint":""
      },{
         "name":"Name",
         "type":"String",
         "value":"genericmill",
         "prompt":"Name of post",
         "hint":"This will be the filename when the post is saved."
      },{
         "name":"Offsets.G54Mach3Offsets",
         "type":"Boolean",
         "value":"true",
         "prompt":"G59 P1..P255 (Mach3 style)",
         "hint":""
      },{
         "name":"Offsets.G54ToG59Offsets",
         "type":"Boolean",
         "value":"true",
         "prompt":"G53..G59",
         "hint":""
      },{
         "name":"Offsets.Okuma",
         "type":"Boolean",
         "value":"false",
         "prompt":"G15 H0..H50 (Okuma style)",
         "hint":""
      },{
         "name":"Offsets.OkumaOneShot",
         "type":"Boolean",
         "value":"false",
         "prompt":"G16 H0..H50 (Okuma one-shot style)",
         "hint":""
      },{
         "name":"Offsets.Plus300Offsets",
         "type":"Boolean",
         "value":"true",
         "prompt":"G54.1/G54 P1..P300 (Fanuc style)",
         "hint":""
      },{
         "name":"Offsets.Plus48Offsets",
         "type":"Boolean",
         "value":"true",
         "prompt":"G54.1/G54 P1..P48 (Fanuc style)",
         "hint":""
      },{
         "name":"Offsets.G110HaasOffsets",
         "type":"Boolean",
         "value":"false",
         "prompt":"G110..129 (Haas style)",
         "hint":""
      },{
         "name":"Offsets.G154HaasOffsets",
         "type":"Boolean",
         "value":"false",
         "prompt":"G154 P1..P99 (Haas style)",
         "hint":""
      },{
         "name":"Other.DecimalChar",
         "type":"String",
         "value":".",
         "prompt":"Decimal Point",
         "hint":"Character used for decimal points."
      },{
         "name":"PoundVars.VolatilityChoice",
         "type":"int",
         "value":"0",
         "prompt":"# Variable Volatility",
         "hint":"0 = Fanuc Style (#500-999)\n1 = Haas Style (#100-199, #500-699, #800-999)\n2 = Mach3 (#5220-#10306 = Work Offsets)",
         "min":0,
         "max":1
      },{
         "name":"StartupGCode",
         "type":"String",
         "value":"",
         "prompt":"Startup G-Code",
         "hint":"One line g-code program that is executed to establish the controllers startup state."
      },{
         "name":"Tools.MaxToolSlot",
         "type":"int",
         "value":"255",
         "prompt":"Max Tool Slot",
         "hint":"",
         "min":0,
         "max":99999
      },{
         "name":"Tools.MinToolSlot",
         "type":"int",
         "value":"0",
         "prompt":"Min Tool Slot",
         "hint":"",
         "min":0,
         "max":9999
      },{
         "name":"Tools.ToolOffsetDigits",
         "type":"int",
         "value":"0",
         "prompt":"Tool Offset Digits",
         "hint":"Use non-zero for Fanuc-style combined Tool Number and Offset.",
         "min":0,
         "max":9
      },{
         "name":"Word.AnyNumber",
         "type":"Boolean",
         "value":"true",
         "prompt":"Accept any valid number with any word.  Faster to backplot when this is true."
      },{
         "name":"Word.DefLetter",
         "type":"String",
         "value":"X",
         "prompt":"Startup G-Code",
         "hint":"Use this word if there is no definition."
      },{
         "name":"Word.A",
         "type":"WordAddress",
         "value":"->5.>3",
         "prompt":"",
         "hint":"A is used with ABC words for rotary axis coordinates."
      },{
         "name":"Word.F",
         "type":"WordAddress",
         "value":">3[.]>4",
         "prompt":"",
         "hint":"F-word is for feedrates."
      },{
         "name":"Word.G",
         "type":"WordAddress",
         "value":">2[.]>1",
         "prompt":"",
         "hint":"G-word specifies digits to identify a g-code."
      },{
         "name":"Word.I",
         "type":"WordAddress",
         "value":"->5[.]>4",
         "prompt":"",
         "hint":"I is used with IJK words for coordinates."
      },{
         "name":"Word.M",
         "type":"WordAddress",
         "value":">2",
         "prompt":"",
         "hint":"M-word specifies digits to identify an m-code."
      },{
         "name":"Word.N",
         "type":"WordAddress",
         "value":">5",
         "prompt":"",
         "hint":"N-word identifies block number."
      },{
         "name":"Word.O",
         "type":"WordAddress",
         "value":">5",
         "prompt":"",
         "hint":"O-word identifies subprogram number"
      },{
         "name":"Word.R",
         "type":"WordAddress",
         "value":">5[.]>4",
         "prompt":"",
         "hint":"R-word specifies radius, cycle retract, etc."
      },{
         "name":"Word.S",
         "type":"WordAddress",
         "value":">5[.]>1",
         "prompt":"",
         "hint":"S-word specifies spindle speed."
      },{
         "name":"Word.T",
         "type":"WordAddress",
         "value":">4",
         "prompt":"",
         "hint":"T-word specifies tools. T options are also applied for D-word."
      },{
         "name":"Word.X",
         "type":"WordAddress",
         "value":"->5[.]>4",
         "prompt":"",
         "hint":"X is used with XYZ words for coordinates."
      },{
         "name":"Word.H",
         "type":"WordAddress",
         "value":"->5[.]>4",
         "prompt":"",
         "hint":"H is used to select Tool Offsets."
      },{
         "name":"Word.#",
         "type":"WordAddress",
         "value":">4",
         "prompt":"",
         "hint":"# and its digits specify a macro variable."
      }]);
      
      private static var _1040875961noLoad:Boolean = false;
      
      private static const MAX_RECURSE_DEPTH:int = 10;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var stringRecursions:int = 0;
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizPostVars()
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         var _loc1_:int = 0;
         while(_loc1_ < genericPostAC.length)
         {
            _loc2_ = genericPostAC.getItemAt(_loc1_);
            _loc3_ = !!_loc2_.hasOwnProperty("min") ? int(int(_loc2_.min)) : -99999;
            _loc4_ = !!_loc2_.hasOwnProperty("max") ? int(int(_loc2_.max)) : -99999;
            this.setPostObjEntry(_loc2_.name,_loc2_.type,_loc2_.value,_loc3_,_loc4_);
            _loc1_++;
         }
         if(!tested)
         {
            tested = true;
            GWizUtils.assert(this.unitTest());
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get genericPostAC() : ArrayCollection
      {
         return GWizPostVars._12579193genericPostAC;
      }
      
      public static function set genericPostAC(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizPostVars._12579193genericPostAC;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizPostVars,"genericPostAC",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get noLoad() : Boolean
      {
         return GWizPostVars._1040875961noLoad;
      }
      
      public static function set noLoad(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizPostVars._1040875961noLoad;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizPostVars,"noLoad",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      private function poToNumParser(param1:Object) : Object
      {
         var _loc2_:String = param1.name;
         _loc2_ = _loc2_.charAt(_loc2_.length - 1);
         var _loc3_:Object = new Object();
         _loc3_.letter = _loc2_;
         _loc3_.pattern = param1.value;
         _loc3_.hint = param1.hint;
         return _loc3_;
      }
      
      private function setPOFromNumParser(param1:Object) : void
      {
         var _loc2_:String = "Word." + param1.letter;
         this[_loc2_ + ".name"] = _loc2_;
         this[_loc2_ + ".type"] = "WordAddress";
         this[_loc2_ + ".value"] = param1.pattern;
         this[_loc2_ + ".prompt"] = "";
         this[_loc2_ + ".hint"] = param1.hint;
      }
      
      private function setPostObjEntry(param1:String, param2:String, param3:String, param4:int, param5:int) : void
      {
         if(false && GWizUtils.debug && param1 == "GCodes.G7071Units")
         {
            log.debug("GCodes.G7071Units = " + param3);
         }
         this[param1 + ".type"] = param2;
         switch(param2)
         {
            case "Boolean":
               this[param1 + ".value"] = param3 == "true" ? true : false;
               break;
            case "Number":
               this[param1 + ".value"] = Number(param3);
               break;
            case "int":
               this[param1 + ".value"] = int(param3);
               this[param1 + ".min"] = int(param4);
               this[param1 + ".max"] = int(param5);
               break;
            case "String":
            case "WordAddress":
               this[param1 + ".value"] = param3;
               break;
            default:
               GWizUtils.assert(false);
               this[param1 + ".value"] = param3;
         }
      }
      
      public function getPostSettings(param1:GWizPostSettings) : void
      {
         this["ArcOptions.AllowHelix.value"] = param1.AllowHelix;
         this["ArcOptions.ArcEndpointTolerance.value"] = param1.arcEndpointTolerance;
         this["ArcOptions.AutoIJK.value"] = param1.autoIJK;
         this["ArcOptions.IJKRPrecendence.value"] = param1.IJKRPrec;
         this["ArcOptions.IncrementalIJ.value"] = param1.incrementalIJ;
         this["ArcOptions.ModalCenter.value"] = param1.modalCenter;
         this["ArcOptions.ModalRCenter.value"] = param1.modalRCenter;
         this["AxisOptions.xMult.value"] = GWizPostSettings.xMult;
         this["AxisOptions.yMult.value"] = GWizPostSettings.yMult;
         this["AxisOptions.zMult.value"] = GWizPostSettings.zMult;
         this["Comment.value"] = param1.postComment;
         this["Cycles.CannedRepeatStyle.value"] = param1.cannedRepeatStyle;
         this["Cycles.CycleIncrZ.value"] = param1.cycleIncrZ;
         this["Cycles.CycleROptional.value"] = param1.cycleROptional;
         this["Cycles.DrillDepthStyle.value"] = param1.drillDepthStyle;
         this["Cycles.PeckRequired.value"] = param1.peckRequired;
         this["Cycles.Mach3CannedZ.value"] = param1.mach3CannedZ;
         this["Cycles.HeidenhainPL.value"] = param1.HeidenhainPL;
         this["Cycles.HeidenhainM99M89.value"] = param1.HeidenhainM99M89;
         this["Cycles.FagorVariables.value"] = param1.FagorVariables;
         this["Cycles.LHTapping.value"] = param1.LHTapping;
         this["Cycles.ModalCanned.value"] = param1.modalCanned;
         this["Cycles.RHTapping.value"] = param1.RHTapping;
         this["Cycles.RigidTapping.value"] = param1.rigidTapping;
         this["Errors.FeedrateCheck.value"] = param1.feedrateCheck;
         this["Errors.SpindleCheck.value"] = param1.spindleCheck;
         this["Errors.ToolCheck.value"] = param1.toolCheck;
         this["Errors.ToolCheckMode.value"] = param1.toolCheckMode;
         this["FadalLSyntax.value"] = param1.FadalLSyntax;
         this["FullLineComment.value"] = param1.fullLineComment;
         this["GCodes.G04.FracWord.value"] = param1.g4FracWord;
         this["GCodes.G04.WholeWord.value"] = param1.g4WholeWord;
         this["GCodes.G10.Style.value"] = param1.g10Style;
         this["GCodes.G51.ScalingStyle.value"] = param1.g51Style;
         this["Gcodes.G65.Fanuc.value"] = param1.G65Fanuc;
         this["GCodes.G68.Relative.value"] = param1.g68relative;
         this["GCodes.G68.Style.value"] = param1.g68Style;
         this["GCodes.G7071Units.value"] = param1.g7071Units;
         this["GCodes.G71.Retract.value"] = param1.g71Retract;
         this["GCodes.G71.Style.value"] = param1.g71Style;
         this["GCodes.G71.Type2.value"] = param1.g71Type2;
         this["GCodes.G76.Style.value"] = param1.g76Style;
         this["IncrUVW.value"] = param1.incrUVW;
         this["Lathe.LatheXAxisDiameter.value"] = param1.latheXAxisDiameter;
         this["Lathe.AllowLatheChamfer.value"] = param1.allowLatheChamfer;
         this["Lathe.AllowLatheCornerRounding.value"] = param1.allowLatheCornerRound;
         this["Macros.Colon4Subs.value"] = param1.colon4Subs;
         this["Macros.Goto.value"] = param1.MacroGoto;
         this["Macros.IfGoto.value"] = param1.MacroIfGoto;
         this["Macros.IfThen.value"] = param1.MacroIfThen;
         this["Macros.SetVN.value"] = param1.MacroSetVN;
         this["Macros.LinuxCNCNamedParms.value"] = param1.LinuxCNCNamedParms;
         this["Macros.LinuxCNCFirstNamedParm.value"] = param1.LinuxCNCFirstNamedParm;
         this["Macros.LinuxCNCSubroutines.value"] = param1.LinuxCNCSubroutines;
         this["Macros.While.value"] = param1.MacroWhile;
         this["Macros.WhileNest.value"] = param1.MacroWhileNest;
         this["MCodes.M98.MaxNest.value"] = param1.M98MaxNest;
         this["MCodes.M98.ReportUndef.value"] = param1.M98ReportUndef;
         this["MCodes.M98.Style.value"] = param1.M98Style;
         this["MCodes.M98.TryNForO.value"] = param1.M98TryNForO;
         this["MCodes.M98.DX32Replace.value"] = param1.M98DX32Replace;
         this["MCodes.M99.IgnorePNum.value"] = param1.M99IgnorePNum;
         this["Name.value"] = param1.postName;
         this["Offsets.G54Mach3Offsets.value"] = param1.g54Mach3Offsets;
         this["Offsets.G54ToG59Offsets.value"] = param1.g54To59Offsets;
         this["Offsets.Okuma.value"] = param1.g54Okuma;
         this["Offsets.OkumaOneShot.value"] = param1.g54OkumaOneShot;
         this["Offsets.Plus300Offsets.value"] = param1.g54Plus300Offsets;
         this["Offsets.Plus48Offsets.value"] = param1.g54Plus48Offsets;
         this["Offsets.G110HaasOffsets"] = param1.g110HaasOffsets;
         this["Offsets.G154HaasOffsets"] = param1.g154HaasOffsets;
         this["GCodes.G16.PolarMotions.value"] = param1.polarMotions;
         this["GCodes.G16.PolarOrigin.value"] = param1.polarOrigin;
         this["Other.DecimalChar.value"] = param1.decimalChar;
         this["PoundVars.VolatilityChoice.value"] = param1.volatilityChoice;
         this["StartupGCode.value"] = param1.startupGCode;
         this["Tools.MaxToolSlot.value"] = param1.maxToolSlot;
         this["Tools.MinToolSlot.value"] = param1.minToolSlot;
         this["Tools.ToolOffsetDigits.value"] = param1.toolOffsetDigits;
         this.getNumberSettings(param1);
      }
      
      public function getNumberSettings(param1:GWizPostSettings) : void
      {
         this["Word.AnyNumber.value"] = param1.anyNumber;
         this["Word.DefLetter.value"] = param1.defLetter;
         var _loc2_:int = 0;
         while(_loc2_ < GWizSettings.post.wordArgs.length)
         {
            this.setPOFromNumParser(GWizSettings.post.wordArgs.getItemAt(_loc2_));
            _loc2_++;
         }
      }
      
      public function putPostSettings(param1:GWizPostSettings) : GWizPostSettings
      {
         param1.AllowHelix = this["ArcOptions.AllowHelix.value"];
         param1.arcEndpointTolerance = this["ArcOptions.ArcEndpointTolerance.value"];
         param1.autoIJK = this["ArcOptions.AutoIJK.value"];
         param1.IJKRPrec = this["ArcOptions.IJKRPrecendence.value"];
         param1.incrementalIJ = this["ArcOptions.IncrementalIJ.value"];
         param1.modalCenter = this["ArcOptions.ModalCenter.value"];
         log.debug(this["ArcOptions.ModalCenter.value"]);
         param1.modalRCenter = this["ArcOptions.ModalRCenter.value"];
         GWizPostSettings.xMult = this["AxisOptions.xMult.value"];
         GWizPostSettings.yMult = this["AxisOptions.yMult.value"];
         GWizPostSettings.zMult = this["AxisOptions.zMult.value"];
         param1.postComment = this["Comment.value"];
         param1.cannedRepeatStyle = this["Cycles.CannedRepeatStyle.value"];
         param1.cycleIncrZ = this["Cycles.CycleIncrZ.value"];
         param1.cycleROptional = this["Cycles.CycleROptional.value"];
         param1.drillDepthStyle = this["Cycles.DrillDepthStyle.value"];
         param1.peckRequired = this["Cycles.PeckRequired.value"];
         param1.LHTapping = this["Cycles.LHTapping.value"];
         param1.mach3CannedZ = this["Cycles.Mach3CannedZ.value"];
         param1.HeidenhainPL = this["Cycles.HeidenhainPL.value"];
         param1.HeidenhainM99M89 = this["Cycles.HeidenhainM99M89.value"];
         param1.FagorVariables = this["Cycles.FagorVariables.value"];
         param1.modalCanned = this["Cycles.ModalCanned.value"];
         param1.RHTapping = this["Cycles.RHTapping.value"];
         param1.rigidTapping = this["Cycles.RigidTapping.value"];
         param1.FadalLSyntax = this["FadalLSyntax.value"];
         param1.feedrateCheck = this["Errors.FeedrateCheck.value"];
         param1.spindleCheck = this["Errors.SpindleCheck.value"];
         param1.toolCheck = this["Errors.ToolCheck.value"];
         param1.toolCheckMode = this["Errors.ToolCheckMode.value"];
         param1.fullLineComment = this["FullLineComment.value"];
         param1.g4FracWord = this["GCodes.G04.FracWord.value"];
         param1.g4WholeWord = this["GCodes.G04.WholeWord.value"];
         param1.g10Style = this["GCodes.G10.Style.value"];
         param1.g51Style = this["GCodes.G51.ScalingStyle.value"];
         param1.G65Fanuc = this["Gcodes.G65.Fanuc.value"];
         param1.g68relative = this["GCodes.G68.Relative.value"];
         param1.g68Style = this["GCodes.G68.Style.value"];
         param1.g7071Units = this["GCodes.G7071Units.value"];
         log.debug("g7071Units = " + param1.g7071Units);
         param1.g71Retract = this["GCodes.G71.Retract.value"];
         param1.g71Style = this["GCodes.G71.Style.value"];
         param1.g71Type2 = this["GCodes.G71.Type2.value"];
         param1.g76Style = this["GCodes.G76.Style.value"];
         param1.incrUVW = this["IncrUVW.value"];
         param1.latheXAxisDiameter = this["Lathe.LatheXAxisDiameter.value"];
         param1.allowLatheChamfer = this["Lathe.AllowLatheChamfer.value"];
         param1.allowLatheCornerRound = this["Lathe.AllowLatheCornerRounding.value"];
         param1.colon4Subs = this["Macros.Colon4Subs.value"];
         param1.MacroGoto = this["Macros.Goto.value"];
         param1.MacroIfGoto = this["Macros.IfGoto.value"];
         param1.MacroIfThen = this["Macros.IfThen.value"];
         param1.MacroSetVN = this["Macros.SetVN.value"];
         param1.LinuxCNCNamedParms = this["Macros.LinuxCNCNamedParms.value"];
         param1.LinuxCNCFirstNamedParm = this["Macros.LinuxCNCFirstNamedParm.value"];
         param1.LinuxCNCSubroutines = this["Macros.LinuxCNCSubroutines.value"];
         param1.MacroWhile = this["Macros.While.value"];
         param1.MacroWhileNest = this["Macros.WhileNest.value"];
         param1.M98MaxNest = this["MCodes.M98.MaxNest.value"];
         param1.M98ReportUndef = this["MCodes.M98.ReportUndef.value"];
         param1.M98Style = this["MCodes.M98.Style.value"];
         param1.M98TryNForO = this["MCodes.M98.TryNForO.value"];
         param1.M98DX32Replace = this["MCodes.M98.DX32Replace.value"];
         param1.M99IgnorePNum = this["MCodes.M99.IgnorePNum.value"];
         param1.postName = this["Name.value"];
         param1.g54Mach3Offsets = this["Offsets.G54Mach3Offsets.value"];
         param1.g54To59Offsets = this["Offsets.G54ToG59Offsets.value"];
         param1.g54Okuma = this["Offsets.Okuma.value"];
         param1.g54OkumaOneShot = this["Offsets.OkumaOneShot.value"];
         param1.g54Plus300Offsets = this["Offsets.Plus300Offsets.value"];
         param1.g54Plus48Offsets = this["Offsets.Plus48Offsets.value"];
         param1.g110HaasOffsets = this["Offsets.G110HaasOffsets"];
         param1.g154HaasOffsets = this["Offsets.G154HaasOffsets"];
         param1.polarMotions = this["GCodes.G16.PolarMotions.value"];
         param1.polarOrigin = this["GCodes.G16.PolarOrigin.value"];
         param1.decimalChar = this["Other.DecimalChar.value"];
         param1.volatilityChoice = this["PoundVars.VolatilityChoice.value"];
         param1.startupGCode = this["StartupGCode.value"];
         param1.maxToolSlot = this["Tools.MaxToolSlot.value"];
         param1.minToolSlot = this["Tools.MinToolSlot.value"];
         param1.toolOffsetDigits = this["Tools.ToolOffsetDigits.value"];
         param1.anyNumber = this["Word.AnyNumber.value"];
         param1.defLetter = this["Word.DefLetter.value"];
         param1.wordArgs.removeAll();
         param1.wordArgs.addItem({
            "letter":"A",
            "pattern":this["Word.A.value"],
            "hint":this["Word.A.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"F",
            "pattern":this["Word.F.value"],
            "hint":this["Word.F.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"G",
            "pattern":this["Word.G.value"],
            "hint":this["Word.G.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"I",
            "pattern":this["Word.I.value"],
            "hint":this["Word.I.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"M",
            "pattern":this["Word.M.value"],
            "hint":this["Word.M.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"N",
            "pattern":this["Word.N.value"],
            "hint":this["Word.N.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"O",
            "pattern":this["Word.O.value"],
            "hint":this["Word.O.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"R",
            "pattern":this["Word.R.value"],
            "hint":this["Word.R.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"S",
            "pattern":this["Word.S.value"],
            "hint":this["Word.S.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"T",
            "pattern":this["Word.T.value"],
            "hint":this["Word.T.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"X",
            "pattern":this["Word.X.value"],
            "hint":this["Word.X.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"H",
            "pattern":this["Word.H.value"],
            "hint":this["Word.H.hint"]
         });
         param1.wordArgs.addItem({
            "letter":"#",
            "pattern":this["Word.#.value"],
            "hint":this["Word.#.hint"]
         });
         return param1;
      }
      
      public function poToString() : String
      {
         var _loc3_:Object = null;
         var _loc4_:* = null;
         var _loc1_:String = "";
         var _loc2_:int = 0;
         while(_loc2_ < genericPostAC.length)
         {
            _loc3_ = genericPostAC.getItemAt(_loc2_);
            _loc4_ = this[_loc3_.name + ".value"];
            if(this[_loc3_.name + ".type"] == "String")
            {
               _loc4_ = "\"" + _loc4_.replace("\"","") + "\"";
            }
            _loc1_ += _loc3_.name + " = " + _loc4_ + ";\n";
            _loc2_++;
         }
         _loc1_ += GWizGCParseData.codesToPSTFile();
         _loc1_ += GWizWordMapper.mapToPSTFile();
         return GWizFileUtils.denormalizeLineBreaks(_loc1_);
      }
      
      private function splitLines(param1:String) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         while(param1.length > 0 && _loc3_ < 1000)
         {
            if((_loc4_ = param1.indexOf("=")) > 0)
            {
               _loc5_ = StringUtil.trim(param1.substr(0,_loc4_));
               param1 = param1.substr(_loc4_ + 1);
               _loc6_ = 0;
               _loc7_ = "";
               while(param1.charAt(_loc6_) != ";" && _loc6_ < param1.length)
               {
                  if(param1.charAt(_loc6_) == "\'" || param1.charAt(_loc6_) == "\"")
                  {
                     _loc8_ = param1.charAt(_loc6_++);
                     while(param1.charAt(_loc6_) != _loc8_ && _loc6_ < param1.length)
                     {
                        _loc7_ += param1.charAt(_loc6_++);
                     }
                     while(param1.charAt(_loc6_) != ";" && _loc6_ < param1.length)
                     {
                        _loc6_++;
                     }
                     if(_loc6_ < param1.length)
                     {
                        break;
                     }
                  }
                  else
                  {
                     _loc7_ += param1.charAt(_loc6_);
                     _loc6_++;
                  }
               }
               param1 = param1.substr(_loc6_ + 1);
               _loc7_ = StringUtil.trim(_loc7_);
               var _loc9_:*;
               _loc2_[_loc9_ = _loc3_++] = {
                  "name":_loc5_,
                  "value":_loc7_
               };
            }
            else if(param1.length > 0)
            {
               param1 = "";
            }
         }
         return _loc2_;
      }
      
      public function poFromString(param1:String) : void
      {
         var name:String = null;
         var value:String = null;
         var postFile:File = null;
         var stream:FileStream = null;
         var s:String = param1;
         if(noLoad)
         {
            return;
         }
         ++this.stringRecursions;
         var errs:int = 0;
         GWizGCParseData.resetCodes();
         GWizWordMapper.clearMappings();
         s = GWizFileUtils.normalizeLineBreaks(s);
         var lines:Array = this.splitLines(s);
         var i:int = 0;
         while(i < lines.length)
         {
            name = lines[i].name;
            value = lines[i].value;
            if(name == "#include")
            {
               if(this.stringRecursions < MAX_RECURSE_DEPTH)
               {
                  postFile = GWizSettings.getPrefsFile("Posts/" + value);
                  try
                  {
                     stream = new FileStream();
                     if(postFile.exists)
                     {
                        stream.open(postFile,FileMode.READ);
                        this.poFromString(stream.readUTFBytes(stream.bytesAvailable));
                        stream.close();
                     }
                  }
                  catch(e:Error)
                  {
                     GWizUtils.LogError("Error with GWizPostObj #include: " + e.message);
                  }
               }
            }
            else if(name.indexOf("Macros.NamedParm.") >= 0)
            {
               name = name.substr(name.indexOf("Macros.NamedParm.") + "Macros.NamedParm.".length);
               if(allocNewSymbol != null)
               {
                  allocNewSymbol(name,int(value));
               }
            }
            else if(this.hasOwnProperty(name + ".value"))
            {
               if(GWizUtils.debug && name == "MCodes.M98.Style")
               {
                  log.debug("GCodes.G7071Units = " + value);
               }
               switch(this[name + ".type"])
               {
                  case "Boolean":
                     this[name + ".value"] = String(value) == "true";
                     break;
                  case "Number":
                     this[name + ".value"] = Number(String(value));
                     break;
                  case "int":
                     this[name + ".value"] = int(String(value));
                     break;
                  default:
                     this[name + ".value"] = value;
               }
            }
            else if(name != "")
            {
               if(!GWizGCParseData.savePSTCode(name,value) && !GWizWordMapper.savePSTCode(name,value))
               {
                  GWizUtils.LogError("Unknown post setting: \'" + name + "\'");
                  if(errs < 3)
                  {
                     GWizPopUpManager.Show("Unknown post setting: \'" + name + "\'.  You may need to update your software.","Warning: Unknown Setting",GWizPopUpManager.WARN);
                  }
                  errs++;
               }
            }
            i++;
         }
         --this.stringRecursions;
      }
      
      private function unitTest() : Boolean
      {
         var _loc1_:Boolean = true;
         _loc1_ = _loc1_ && this["Tools.ToolOffsetDigits.type"] == "int";
         _loc1_ = _loc1_ && this["Tools.ToolOffsetDigits.value"] == 0;
         _loc1_ = _loc1_ && this["Offsets.Okuma.value"] == false;
         return Boolean(_loc1_ && this["Offsets.Plus300Offsets.value"] == true);
      }
      
      public function wordArgsLen() : int
      {
         return GWizSettings.post.wordArgs.length;
      }
      
      public function getWordArgAt(param1:int) : Object
      {
         var _loc2_:Object = GWizSettings.post.wordArgs.getItemAt(param1);
         var _loc3_:String = "Word." + _loc2_.letter;
         _loc2_.pattern = this[_loc3_ + ".value"];
         return _loc2_;
      }
      
      public function setWordArgAt(param1:Object, param2:int) : void
      {
         var _loc3_:Object = GWizSettings.post.wordArgs.getItemAt(param2);
         var _loc4_:String = "Word." + _loc3_.letter;
         this[_loc4_ + ".value"] = param1.pattern;
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
