package post
{
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.TimerEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.Timer;
   import machines.GWizMachProfile;
   import machines.GWizMachSettings;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizCallChain;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizPostSettings implements IEventDispatcher
   {
      
      public static var xMult:Number = 1;
      
      public static var yMult:Number = 1;
      
      public static var zMult:Number = 1;
      
      public static const FANUC_DD:int = 0;
      
      public static const DX32_DD:int = 1;
      
      public static const DX32_Z2:String = "secondZ";
      
      public static const DX32_Z3:String = "thirdZ";
      
      public static const FANUC_VOL:int = 0;
      
      public static const HAAS_VOL:int = 1;
      
      public static const MACH3_VOL:int = 2;
      
      private static var _1448484543useSemiColComments:Boolean = false;
      
      private static var _1534454334useToolChangeOffset:Boolean = true;
      
      private static var _1980410795programStartBlockMill:String = "( Wizard Safe Start Block )\nG17\nG90\nG20\n\n";
      
      private static var _1262038317programStartBlockLathe:String = "( Wizard Safe Start Block )\nG18\nG90\nG20\n\n";
      
      private static var _1410827623g28Substitute:String = "G28";
      
      private static var _806200554programEndBlock:String = "( Wizard Complete )\nG28\nM05\nM09\n\n";
      
      public static var lastPostLoaded:String = "";
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private const log:ILogger = Log.getLogger("GWizPostSettings");
      
      public var PostVars:GWizPostVars;
      
      public var postName:String = "";
      
      public var postComment:String = "";
      
      public var startupGCode:String = "";
      
      public const G10_MACH3:int = 0;
      
      public const G10_FANUC:int = 1;
      
      public const G10_ROLAND:int = 2;
      
      public var g10Style:int = 0;
      
      public var incrementalIJ:Boolean = true;
      
      public var autoIJK:Boolean = true;
      
      public var modalCenter:Boolean = false;
      
      public var modalRCenter:Boolean = false;
      
      public var IJKRPrec:Boolean = true;
      
      public var AllowHelix:Boolean = true;
      
      public var arcEndpointTolerance:Number = 0.001;
      
      public var latheXAxisDiameter:Boolean = false;
      
      private var _g7071Units:Boolean = false;
      
      public const G71_DOUBLE:int = 0;
      
      public const G71_SINGLE:int = 1;
      
      public var g71Style:int = 0;
      
      public var g71Retract:Number = 0.05;
      
      public var g71Type2:Boolean = true;
      
      public const G76_FANUC_DOUBLE:int = 0;
      
      public const G76_FANUC_SINGLE:int = 1;
      
      public const G76_HAAS_SINGLE:int = 2;
      
      public const G76_LINUXCNC_SINGLE:int = 3;
      
      public const G76_MACH3_SINGLE:int = 4;
      
      public const G76_CENTROID_DOUBLE:int = 5;
      
      public var g76Style:int = 0;
      
      public var allowLatheChamfer:Boolean = true;
      
      public var allowLatheCornerRound:Boolean = true;
      
      public const G51_FANUC:int = 0;
      
      public const G51_HAAS:int = 1;
      
      public const G51_MACH3:int = 2;
      
      public var g51Style:int = 2;
      
      public const G68_FANUC:int = 0;
      
      public const G68_MACH3:int = 1;
      
      public const G68_HAAS:int = 2;
      
      public var g68Style:int = 0;
      
      public var g68relative:Boolean = false;
      
      public var g54To59Offsets:Boolean = true;
      
      public var g54Mach3Offsets:Boolean = true;
      
      public var g54Plus48Offsets:Boolean = true;
      
      public var g54Plus300Offsets:Boolean = true;
      
      public var g54Okuma:Boolean = false;
      
      public var g54OkumaOneShot:Boolean = false;
      
      public var g110HaasOffsets:Boolean = false;
      
      public var g154HaasOffsets:Boolean = false;
      
      public const POLAR_MOTIONS_LINEAR:int = 0;
      
      public const POLAR_MOTIONS_ALL:int = 1;
      
      public var polarMotions:int = 1;
      
      public const POLAR_ORIGIN_REL:int = 0;
      
      public const POLAR_ORIGIN_G90G91:int = 1;
      
      public const POLAR_ORIGIN_G16:int = 2;
      
      public var polarOrigin:int = 0;
      
      public var Mach3PolarOrigin:Boolean = false;
      
      public var mach3CannedZ:Boolean = true;
      
      public var HeidenhainPL:Boolean = false;
      
      public var modalCanned:Boolean = true;
      
      public var HeidenhainM99M89:Boolean = false;
      
      public var FagorVariables:Boolean = false;
      
      public const REPEAT_L:int = 0;
      
      public const REPEAT_K:int = 1;
      
      public var cannedRepeatStyle:int = 1;
      
      public var cycleROptional:Boolean = false;
      
      public var cycleIncrZ:Boolean = false;
      
      public var drillDepthStyle:int = 0;
      
      public var peckRequired:Boolean = true;
      
      public var LHTapping:String = "G74 ZholeBottom RretractZ";
      
      public var RHTapping:String = "G84 ZholeBottom RretractZ";
      
      public var rigidTapping:String = "M29";
      
      public var fanucNonVolatile:ArrayCollection;
      
      public var haasNonVolatile:ArrayCollection;
      
      public var mach3NonVolatile:ArrayCollection;
      
      public var volatilityChoices:Array;
      
      public var volatilityChoice:int = 0;
      
      public var minToolSlot:int = 0;
      
      public var maxToolSlot:int = 255;
      
      public var toolOffsetDigits:int = 0;
      
      public const M98_UNDEFINED:int = 0;
      
      public const M98_P1L1:int = 1;
      
      public const M98_P1K1:int = 2;
      
      public const M98_Prrrroooo:int = 3;
      
      public const M98_P1H1L1:int = 4;
      
      public const M98_O1:int = 5;
      
      public const M98_P1Q1:int = 6;
      
      public const M98_DX32:int = 7;
      
      public const M98_Named:int = 8;
      
      public var _M98Style:int = 0;
      
      public var _M98TryNForO:Boolean = true;
      
      public var M98ReportUndef:Boolean = true;
      
      public var M98MaxNest:int = 4;
      
      public var M99IgnorePNum:Boolean = true;
      
      public var G65Fanuc:Boolean = true;
      
      public var colon4Subs:Boolean = true;
      
      public var M98DX32Replace:Boolean = false;
      
      public var MacroGoto:Boolean = true;
      
      public var MacroIfGoto:Boolean = true;
      
      public var MacroIfThen:Boolean = true;
      
      public var MacroWhile:Boolean = true;
      
      public var MacroWhileNest:int = 3;
      
      public var MacroSetVN:Boolean = true;
      
      public var LinuxCNCNamedParms:Boolean = false;
      
      public var LinuxCNCFirstNamedParm:int = 10000;
      
      public var LinuxCNCSubroutines:Boolean = false;
      
      public var g4WholeWord:String = "P";
      
      public var g4FracWord:String = "X";
      
      public var incrUVW:Boolean = true;
      
      public var FadalLSyntax:Boolean = true;
      
      private var _1564418133anyNumber:Boolean = true;
      
      private var _27817735wordArgs:ArrayCollection;
      
      public var defWordArgs:ArrayCollection;
      
      public var decimalChar:String = ".";
      
      private var _defLetter:String = "X";
      
      public var O_np:GWizNumParser = null;
      
      public var N_np:GWizNumParser = null;
      
      public var G_np:GWizNumParser = null;
      
      public var X_np:GWizNumParser = null;
      
      public var I_np:GWizNumParser = null;
      
      public var A_np:GWizNumParser = null;
      
      public var F_np:GWizNumParser = null;
      
      public var S_np:GWizNumParser = null;
      
      public var R_np:GWizNumParser = null;
      
      public var M_np:GWizNumParser = null;
      
      public var T_np:GWizNumParser = null;
      
      public var H_np:GWizNumParser = null;
      
      public var Pound_np:GWizNumParser = null;
      
      public var default_np:GWizNumParser = null;
      
      public var fullLineComment:String = "%;";
      
      public var spindleCheck:Boolean = true;
      
      public var feedrateCheck:Boolean = true;
      
      public var toolCheck:Boolean = true;
      
      public const T_M06:int = 0;
      
      public const T_ONLY:int = 1;
      
      public var toolCheckMode:int = 0;
      
      private var thisMachine:String;
      
      private var firstLoad:Boolean = true;
      
      private var selectedMachine:String;
      
      public var postLoadedCC:GWizCallChain;
      
      private var postFile:File;
      
      private var postXML:XML;
      
      private var inLoadPost:Boolean = false;
      
      private var loadedFirstPost:Boolean = false;
      
      private var _1672176899GCodeVariables:GWizMacroVariables;
      
      public var postUpdated:GWizCallChain;
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizPostSettings()
      {
         this.PostVars = new GWizPostVars();
         this.fanucNonVolatile = new ArrayCollection([{
            "first":500,
            "last":999
         }]);
         this.haasNonVolatile = new ArrayCollection([{
            "first":100,
            "last":199
         },{
            "first":500,
            "last":699
         },{
            "first":800,
            "last":999
         }]);
         this.mach3NonVolatile = new ArrayCollection([]);
         this.volatilityChoices = ["Fanuc Style (#500-999)","Haas Style (#100-199, #500-699, #800-999)"];
         this._27817735wordArgs = new ArrayCollection([{
            "letter":"O",
            "pattern":">5",
            "hint":"O-word identifies subprogram number"
         },{
            "letter":"N",
            "pattern":">5",
            "hint":"N-word identifies block number."
         },{
            "letter":"G",
            "pattern":">2[.]>1",
            "hint":"G-word specifies digits to identify a g-code."
         },{
            "letter":"X",
            "pattern":"->5[.]>4",
            "hint":"X is used with XYZ words for coordinates."
         },{
            "letter":"I",
            "pattern":"->5[.]>4",
            "hint":"I is used with IJK words for coordinates."
         },{
            "letter":"A",
            "pattern":"->5.>3",
            "hint":"A is used with ABC words for rotary axis coordinates."
         },{
            "letter":"F",
            "pattern":">3[.]>4",
            "hint":"F-word is for feedrates."
         },{
            "letter":"S",
            "pattern":">5[.]>1",
            "hint":"S-word specifies spindle speed."
         },{
            "letter":"R",
            "pattern":">5[.]>1",
            "hint":"R-word specifies radius, cycle retract, etc."
         },{
            "letter":"M",
            "pattern":">2",
            "hint":"M-word specifies digits to identify an m-code."
         },{
            "letter":"T",
            "pattern":">4",
            "hint":"T-word specifies tools. T options are also applied for D-word."
         },{
            "letter":"H",
            "pattern":"->5[.]>4",
            "hint":"H is used to identify tool offsets."
         },{
            "letter":"#",
            "pattern":">4",
            "hint":"# and its digits specify a macro variable."
         }]);
         this.defWordArgs = new ArrayCollection([{
            "letter":"O",
            "pattern":">5",
            "hint":"O-word identifies subprogram number"
         },{
            "letter":"N",
            "pattern":">5",
            "hint":"N-word identifies block number."
         },{
            "letter":"G",
            "pattern":">2[.]>1",
            "hint":"G-word specifies digits to identify a g-code."
         },{
            "letter":"X",
            "pattern":"->5[.]>4",
            "hint":"X is used with XYZ words for coordinates."
         },{
            "letter":"I",
            "pattern":"->5[.]>4",
            "hint":"I is used with IJK words for coordinates."
         },{
            "letter":"A",
            "pattern":"->5.>3",
            "hint":"A is used with ABC words for rotary axis coordinates."
         },{
            "letter":"F",
            "pattern":">3[.]>4",
            "hint":"F-word is for feedrates."
         },{
            "letter":"S",
            "pattern":">5[.]>1",
            "hint":"S-word specifies spindle speed."
         },{
            "letter":"R",
            "pattern":">5[.]>1",
            "hint":"R-word specifies radius, cycle retract, etc."
         },{
            "letter":"M",
            "pattern":">2",
            "hint":"M-word specifies digits to identify an m-code."
         },{
            "letter":"T",
            "pattern":">4",
            "hint":"T-word specifies tools. T options are also applied for D-word."
         },{
            "letter":"H",
            "pattern":"->5[.]>4",
            "hint":"H is used to identify tool offsets."
         },{
            "letter":"#",
            "pattern":">4",
            "hint":"# and its digits specify a macro variable."
         }]);
         this.thisMachine = GWizMachSettings.currMachine;
         this.postLoadedCC = new GWizCallChain();
         this._1672176899GCodeVariables = new GWizMacroVariables();
         this.postUpdated = new GWizCallChain();
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         GWizMachSettings.deleteMachineCC.addFunction("GWizPostSettings",this.deleteMachine);
         GWizMachSettings.selectMachineCC.addFunction("GWizPostSettings",this.selectMachine);
      }
      
      [Bindable(event="propertyChange")]
      public static function get useSemiColComments() : Boolean
      {
         return GWizPostSettings._1448484543useSemiColComments;
      }
      
      public static function set useSemiColComments(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizPostSettings._1448484543useSemiColComments;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizPostSettings,"useSemiColComments",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get useToolChangeOffset() : Boolean
      {
         return GWizPostSettings._1534454334useToolChangeOffset;
      }
      
      public static function set useToolChangeOffset(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizPostSettings._1534454334useToolChangeOffset;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizPostSettings,"useToolChangeOffset",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get programStartBlockMill() : String
      {
         return GWizPostSettings._1980410795programStartBlockMill;
      }
      
      public static function set programStartBlockMill(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizPostSettings._1980410795programStartBlockMill;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizPostSettings,"programStartBlockMill",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get programStartBlockLathe() : String
      {
         return GWizPostSettings._1262038317programStartBlockLathe;
      }
      
      public static function set programStartBlockLathe(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizPostSettings._1262038317programStartBlockLathe;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizPostSettings,"programStartBlockLathe",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get g28Substitute() : String
      {
         return GWizPostSettings._1410827623g28Substitute;
      }
      
      public static function set g28Substitute(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizPostSettings._1410827623g28Substitute;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizPostSettings,"g28Substitute",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get programEndBlock() : String
      {
         return GWizPostSettings._806200554programEndBlock;
      }
      
      public static function set programEndBlock(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizPostSettings._806200554programEndBlock;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizPostSettings,"programEndBlock",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function set g7071Units(param1:Boolean) : void
      {
         this._g7071Units = param1;
      }
      
      public function get g7071Units() : Boolean
      {
         return this._g7071Units;
      }
      
      public function toolSlotError(param1:int) : Boolean
      {
         return param1 < this.minToolSlot || param1 > this.maxToolSlot;
      }
      
      public function get M98Style() : int
      {
         return this._M98Style;
      }
      
      public function set M98Style(param1:int) : void
      {
         this._M98Style = param1;
      }
      
      public function get M98TryNForO() : Boolean
      {
         return this._M98TryNForO;
      }
      
      public function set M98TryNForO(param1:Boolean) : void
      {
         this._M98TryNForO = param1;
      }
      
      private function set _2117878645defLetter(param1:String) : void
      {
         this._defLetter = param1;
      }
      
      public function get defLetter() : String
      {
         return this._defLetter;
      }
      
      public function getNumParserForWord(param1:String) : GWizNumParser
      {
         var _loc2_:GWizNumParser = null;
         switch(param1.toUpperCase())
         {
            case "O":
               _loc2_ = this.O_np;
               break;
            case "N":
               _loc2_ = this.N_np;
               break;
            case "G":
               _loc2_ = this.G_np;
               break;
            case "A":
               _loc2_ = this.A_np;
               break;
            case "F":
               _loc2_ = this.F_np;
               break;
            case "S":
               _loc2_ = this.S_np;
               break;
            case "R":
               _loc2_ = this.R_np;
               break;
            case "M":
               _loc2_ = this.M_np;
               break;
            case "T":
               _loc2_ = this.T_np;
               break;
            case "I":
            case "J":
            case "K":
               _loc2_ = this.I_np;
               break;
            case "H":
               _loc2_ = this.H_np;
               break;
            case "X":
            case "Y":
            case "Z":
            default:
               _loc2_ = this.X_np;
         }
         return _loc2_;
      }
      
      private function resetNumParser(param1:GWizNumParser, param2:String) : GWizNumParser
      {
         var _loc5_:Object = null;
         var _loc3_:String = "->3.>4";
         var _loc4_:int = 0;
         while(_loc4_ < this.wordArgs.length)
         {
            if((_loc5_ = this.wordArgs.getItemAt(_loc4_)).letter == param2)
            {
               _loc3_ = _loc5_.pattern;
               break;
            }
            _loc4_++;
         }
         param1 = null;
         param1 = new GWizNumParser();
         param1.setup(_loc3_);
         return param1;
      }
      
      public function rebuildNumberParsers() : void
      {
         this.O_np = GWizSettings.post.resetNumParser(GWizSettings.post.O_np,"O");
         this.N_np = GWizSettings.post.resetNumParser(GWizSettings.post.N_np,"N");
         this.G_np = GWizSettings.post.resetNumParser(GWizSettings.post.G_np,"G");
         this.X_np = GWizSettings.post.resetNumParser(GWizSettings.post.X_np,"X");
         this.I_np = GWizSettings.post.resetNumParser(GWizSettings.post.I_np,"I");
         this.A_np = GWizSettings.post.resetNumParser(GWizSettings.post.A_np,"A");
         this.F_np = GWizSettings.post.resetNumParser(GWizSettings.post.F_np,"F");
         this.S_np = GWizSettings.post.resetNumParser(GWizSettings.post.S_np,"S");
         this.R_np = GWizSettings.post.resetNumParser(GWizSettings.post.R_np,"R");
         this.M_np = GWizSettings.post.resetNumParser(GWizSettings.post.M_np,"M");
         this.T_np = GWizSettings.post.resetNumParser(GWizSettings.post.T_np,"T");
         this.H_np = GWizSettings.post.resetNumParser(GWizSettings.post.H_np,"H");
         this.Pound_np = GWizSettings.post.resetNumParser(GWizSettings.post.Pound_np,"#");
         switch(this.defLetter)
         {
            case "O":
               this.default_np = this.O_np;
               break;
            case "N":
               this.default_np = this.N_np;
               break;
            case "G":
               this.default_np = this.G_np;
               break;
            case "X":
               this.default_np = this.X_np;
               break;
            case "I":
               this.default_np = this.I_np;
               break;
            case "A":
               this.default_np = this.A_np;
               break;
            case "F":
               this.default_np = this.F_np;
               break;
            case "S":
               this.default_np = this.S_np;
               break;
            case "R":
               this.default_np = this.R_np;
               break;
            case "M":
               this.default_np = this.M_np;
               break;
            case "T":
               this.default_np = this.T_np;
               break;
            case "H":
               this.default_np = this.H_np;
               break;
            case "#":
               this.default_np = this.Pound_np;
         }
      }
      
      public function resetWordArgsToDefaults() : void
      {
         var _loc2_:Object = null;
         this.wordArgs.removeAll();
         var _loc1_:int = 0;
         while(_loc1_ < this.defWordArgs.length)
         {
            _loc2_ = new Object();
            _loc2_.letter = this.defWordArgs[_loc1_].letter;
            _loc2_.pattern = this.defWordArgs[_loc1_].pattern;
            this.wordArgs.addItemAt(_loc2_,_loc1_);
            _loc1_++;
         }
         this.defLetter = "X";
         this.default_np = this.X_np;
         this.anyNumber = true;
         this.rebuildNumberParsers();
      }
      
      private function deleteMachine(param1:String) : Boolean
      {
         return true;
      }
      
      private function selectMachine(param1:String) : Boolean
      {
         this.selectedMachine = param1;
         this.selectMachineAux();
         return true;
      }
      
      public function loadSelectedMachinesPost() : void
      {
         this.loadPost(this.selectedMachine);
      }
      
      private function selectMachineAux() : void
      {
         var _loc2_:Timer = null;
         var _loc1_:File = GWizPostFileBrowser.postsDirectory();
         if(_loc1_ && _loc1_.exists && !GWizMachProfile.downloading)
         {
            this.thisMachine = this.selectedMachine;
            this.loadSelectedMachinesPost();
            this.firstLoad = false;
         }
         else
         {
            _loc2_ = new Timer(1000,1);
            _loc2_.addEventListener("timer",this.waitTimerHandler);
            _loc2_.start();
         }
      }
      
      private function waitTimerHandler(param1:TimerEvent) : void
      {
         this.selectMachineAux();
      }
      
      private function getPostFile(param1:String) : File
      {
         if(false && GWizUtils.debug && param1.search("Haas") >= 0)
         {
            this.log.debug("gotcha");
         }
         if(!GWizSettings.prefs.sharePrefs)
         {
            this.postFile = GWizSettings.getPrefsFile("post" + param1 + ".pst");
         }
         else
         {
            this.postFile = new File(GWizSettings.prefs.sharingDir);
            if(this.postFile.exists)
            {
               this.postFile = this.postFile.resolvePath("post" + param1 + ".pst");
            }
            else
            {
               GWizUtils.assert(false);
            }
         }
         return this.postFile;
      }
      
      private function loadPost(param1:String) : void
      {
         var stream:FileStream = null;
         var machine:String = param1;
         if(this.inLoadPost || GWizSettings.loginBar.appNameParm != "GWizardE" || machine == "" || !GWizMachSettings.MachinesList)
         {
            return;
         }
         this.inLoadPost = true;
         var newController:String = GWizMachSettings.controllerFor(machine);
         newController = GWizStringUtils.replaceAll(newController,".","");
         if(newController == "Undefined")
         {
            newController = "FanucMill";
         }
         GWizSettings.savePost = true;
         if(newController == lastPostLoaded)
         {
            this.inLoadPost = false;
            return;
         }
         this.postFile = this.getPostFile(newController);
         try
         {
            stream = new FileStream();
            if(!this.postFile.exists)
            {
               this.postFile = GWizMachProfile.doBrowseFor(newController);
            }
            if(this.postFile && this.postFile.exists)
            {
               stream.open(this.postFile,FileMode.READ);
               this.log.debug("Post File URL = " + this.postFile.nativePath);
               this.processPSTData(stream);
            }
            else
            {
               this.savePost(machine);
            }
            lastPostLoaded = newController;
            this.postLoadedCC.callChain(null);
            this.loadedFirstPost = true;
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error with GWizPostSettings load/save: " + e.message);
            GWizPopUpManager.Show("Sorry, error with the post file: " + e.message + "\n" + e.getStackTrace(),"Error: Read Error",GWizPopUpManager.ERROR);
            GWizSettings.post = GWizSettings.post.PostVars.putPostSettings(GWizSettings.post);
            GWizSettings.post.rebuildNumberParsers();
         }
         this.inLoadPost = false;
      }
      
      private function processPSTData(param1:FileStream) : void
      {
         GWizSettings.post.PostVars = new GWizPostVars();
         GWizSettings.post.PostVars.poFromString(param1.readUTFBytes(param1.bytesAvailable));
         GWizSettings.post = GWizSettings.post.PostVars.putPostSettings(GWizSettings.post);
         GWizSettings.post.rebuildNumberParsers();
         param1.close();
      }
      
      public function resetPostPrefs() : void
      {
         GWizSettings.savePost = false;
         this.postFile.deleteFile();
         GWizPopUpManager.Show("Please Exit and Restart to load the reset Post.","Post Reset");
      }
      
      public function forceSavePost() : void
      {
         this.savePost(this.thisMachine);
      }
      
      private function savePost(param1:String) : void
      {
         var outputString:String = null;
         var stream:FileStream = null;
         var poFile:File = null;
         var machine:String = param1;
         if(!GWizSettings.savePost || !this.loadedFirstPost)
         {
            return;
         }
         this.checkPost();
         try
         {
            outputString = "";
            stream = new FileStream();
            poFile = this.getPostFile(GWizMachSettings.controllerFor(machine));
            outputString = this.PostVars.poToString();
            stream.open(poFile,FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
            lastPostLoaded = "";
         }
         catch(error:Error)
         {
            GWizPopUpManager.Show("Error saving Post changes: " + error.message);
         }
      }
      
      public function updatePost() : void
      {
         this.checkPost();
         this.rebuildNumberParsers();
         this.postUpdated.callChain(null);
      }
      
      private function checkPost() : void
      {
         this.sanitizeStartupGCode();
         this.sanitizeFullLineComment();
         this.modalCenter = this.modalCenter && !this.incrementalIJ;
         if(this.volatilityChoice == GWizPostSettings.FANUC_VOL)
         {
            GWizSettings.post.GCodeVariables.setVolatility(GWizSettings.post.fanucNonVolatile);
         }
         else if(this.volatilityChoice != GWizPostSettings.MACH3_VOL)
         {
            GWizSettings.post.GCodeVariables.setVolatility(GWizSettings.post.haasNonVolatile);
         }
      }
      
      private function sanitizeStartupGCode() : void
      {
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc1_:String = "().,";
         var _loc2_:String = "";
         this.startupGCode.toUpperCase();
         var _loc3_:int = 0;
         while(_loc3_ < this.startupGCode.length)
         {
            _loc4_ = this.startupGCode.charAt(_loc3_);
            _loc5_ = false;
            if("A" <= _loc4_.charAt(0) && _loc4_.charAt(0) <= "Z")
            {
               _loc5_ = true;
            }
            else if("0" <= _loc4_.charAt(0) && _loc4_.charAt(0) <= "9")
            {
               _loc5_ = true;
            }
            else if(_loc1_.search(_loc4_.charAt(0)) != -1)
            {
               _loc5_ = true;
            }
            if(_loc5_)
            {
               _loc2_ += _loc4_;
            }
            _loc3_++;
         }
         this.startupGCode = _loc2_;
      }
      
      private function sanitizeFullLineComment() : void
      {
         var _loc1_:String = " 0123456789.-+\t\n";
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            this.fullLineComment.replace(_loc1_.charAt(_loc2_),"");
            _loc2_++;
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get anyNumber() : Boolean
      {
         return this._1564418133anyNumber;
      }
      
      public function set anyNumber(param1:Boolean) : void
      {
         var _loc2_:Object = this._1564418133anyNumber;
         if(_loc2_ !== param1)
         {
            this._1564418133anyNumber = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"anyNumber",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get wordArgs() : ArrayCollection
      {
         return this._27817735wordArgs;
      }
      
      public function set wordArgs(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._27817735wordArgs;
         if(_loc2_ !== param1)
         {
            this._27817735wordArgs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"wordArgs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function set defLetter(param1:String) : void
      {
         var _loc2_:Object = this.defLetter;
         if(_loc2_ !== param1)
         {
            this._2117878645defLetter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"defLetter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GCodeVariables() : GWizMacroVariables
      {
         return this._1672176899GCodeVariables;
      }
      
      public function set GCodeVariables(param1:GWizMacroVariables) : void
      {
         var _loc2_:Object = this._1672176899GCodeVariables;
         if(_loc2_ !== param1)
         {
            this._1672176899GCodeVariables = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GCodeVariables",_loc2_,param1));
            }
         }
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
