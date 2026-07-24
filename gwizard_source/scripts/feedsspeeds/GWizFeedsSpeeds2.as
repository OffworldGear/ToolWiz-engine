package feedsspeeds
{
   import cadcamwiz.GWizCCWEstimatorInput;
   import cadcamwiz.GWizCadCam;
   import comps.GWizForePanel;
   import comps.GWizLabText;
   import comps.GWizNumStep;
   import comps.GWizNumStepOvr;
   import comps.GWizPopUpManager;
   import comps.GWizTempSlider;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.system.Capabilities;
   import flash.utils.Proxy;
   import flash.utils.getDefinitionByName;
   import localdb.GWizCustIPTSQL;
   import localdb.GWizCutKB;
   import localdb.GWizCutKBSQL;
   import login.GWizCredentials;
   import machines.GWizMachSettings;
   import machines.GWizSpindleCurve;
   import material.GWizFSMachineMaterialSelector;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.utils.ChangeWatcher;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GWizStylePalette;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.DropDownList;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.List;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import spark.layouts.HorizontalLayout;
   import spark.layouts.VerticalLayout;
   import tools.GWizCribList;
   import tools.GWizGWCToolCribSelector;
   import tools.GWizGarrOEMToolData;
   import tools.GWizToolCrib;
   import tools.GWizToolCribArray;
   import tools.GWizToolCribData;
   import tools.GWizToolCribEntry;
   import tools.GWizToolData;
   import tools.GWizToolDef;
   import tools.GWizToolMenu;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizCSVUtils;
   import utils.GWizClipUtils;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizFeedsSpeeds2 extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizFeedsSpeeds2");
      
      public static var custIPTSQL:GWizCustIPTSQL = null;
      
      private static const ALERT_TEXT_COLOR:uint = ColorPalette.secondaryb1;
      
      public static var recalcFinished:Date = new Date();
      
      private static var reportTortHareRough:Boolean = false;
      
      private static var _setFunctionsRecurse:Boolean = false;
      
      private static var _1979827721APP_NAME:String = "Feeds/Speeds";
      
      private static var _385935633showExport:Boolean = false;
      
      private static var _1324756428exportBtnLabel:String = "Copy";
      
      private static var _587876199exportBtnFileMode:Boolean = false;
      
      private static var _1583662185exportBtnDataFormat:String = GWizClipUtils.TSV_FORMAT;
      
      private static var xmlKeeper:XML;
      
      public static const PLUNGE_PLUNGE:int = 0;
      
      public static const PLUNGE_HELIX:int = 1;
      
      public static const PLUNGE_RAMP:int = 2;
      
      private static var _169348707PlungeModes:ArrayCollection = new ArrayCollection([{"label":"Plunge"},{"label":"Helix"},{"label":"Ramp"}]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _2006249AFPT:GWizLabText;
      
      private var _1489202876AxialEngagement:Label;
      
      private var _1085198065Deflect:GWizLabText;
      
      private var _170253098EffDiam:GWizLabText;
      
      private var _1868626456ExportBtn:Button;
      
      private var _1551631807GasPedal:GWizTortHare;
      
      private var _2312HP:GWizLabText;
      
      private var _71842HSM:VGroup;
      
      private var _436988286HSMPanel:GWizForePanel;
      
      private var _72710IPM:GWizNumStepOvr;
      
      private var _72715IPR:GWizLabText;
      
      private var _72717IPT:GWizNumStepOvr;
      
      private var _76621MRR:GWizLabText;
      
      private var _1511458169MiniCalcs:GWizFSMiniCalcs;
      
      private var _79035PCN:CheckBox;
      
      private var _836610861PlungeRate:GWizLabText;
      
      private var _81359RPM:GWizNumStepOvr;
      
      private var _798361566RadialEngagement:Label;
      
      private var _82010SFM:GWizNumStepOvr;
      
      private var _448623778SlotBtn:Button;
      
      private var _83364TSC:CheckBox;
      
      private var _1391077265TipsHGroup:HGroup;
      
      private var _2612664Tool:GWizToolMenu;
      
      private var _1784194942ToolFP:GWizForePanel;
      
      private var _524533773ToolGrp:VGroup;
      
      private var _1784099286Torque:GWizNumStepOvr;
      
      public var _GWizFeedsSpeeds2_Button2:Button;
      
      public var _GWizFeedsSpeeds2_GWizForePanel10:GWizForePanel;
      
      public var _GWizFeedsSpeeds2_GWizForePanel11:GWizForePanel;
      
      public var _GWizFeedsSpeeds2_GWizForePanel3:GWizForePanel;
      
      public var _GWizFeedsSpeeds2_Label1:Label;
      
      public var _GWizFeedsSpeeds2_Label10:Label;
      
      public var _GWizFeedsSpeeds2_Label11:Label;
      
      public var _GWizFeedsSpeeds2_Label2:Label;
      
      public var _GWizFeedsSpeeds2_Label8:Label;
      
      public var _GWizFeedsSpeeds2_Spacer6:Spacer;
      
      private var _1132353642advHBox:HGroup;
      
      private var _1318138705calcPanel:GWizForePanel;
      
      private var _1511647936coolantOptions:HGroup;
      
      private var _1032247510cribTbl:GWizGWCToolCribSelector;
      
      private var _590180769cutDepth:GWizNumStep;
      
      private var _1146488365cutDepthLabel:Label;
      
      private var _1349101757cutGrp:HGroup;
      
      private var _601141474cutPanel:GWizForePanel;
      
      private var _607835300cutWidth:GWizNumStep;
      
      private var _1335951536cutWidthLabel:Label;
      
      private var _364943979cutkbPanel:GWizForePanel;
      
      private var _1117618076deflectTempSlider:GWizTempSlider;
      
      private var _453751277feedTempSlider:GWizTempSlider;
      
      private var _1121656943feedsPanel:GWizForePanel;
      
      private var _3202695hint:Label;
      
      private var _1117982648hintDropdown:List;
      
      private var _558778115hpTempSlider:GWizTempSlider;
      
      private var _1467266933machPanel:HGroup;
      
      private var _52752074mfgSpecs:GWizMfgCutterSpecs;
      
      private var _1914960914mmsDefault:GWizFSMachineMaterialSelector;
      
      private var _113482800optDepth:GWizOptimizeBtn;
      
      private var _1212678516optSlider:GWizOptimizeBtn;
      
      private var _95828269optWidth:GWizOptimizeBtn;
      
      private var _1837217374plungeModeX:DropDownList;
      
      private var _1813401308rpmTempSlider:GWizTempSlider;
      
      private var _817627028secondCol:GWizForePanel;
      
      private var _1391678012showHSMFeedsSpeeds:CheckBox;
      
      private var _3696td:GWizToolDef;
      
      private var _1228027545thirdCol:GWizForePanel;
      
      private var _1209398868tipsPanel:HGroup;
      
      private var _2029271012tipsTitlePanel:GWizForePanel;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var setRPMIPMCallback:Function = null;
      
      public var api:GWizFeedSpeedAPI;
      
      public var fsm:GWizFeedSpeedMath;
      
      public var estInput:GWizCCWEstimatorInput = null;
      
      private var cfg:GWizConfigData;
      
      public const RPM_TOO_HIGH_ERR:String = "Min RPM too high for cut.  Use a smaller cutter or one that can go faster.";
      
      public const FEEDRATE_MAXED_OUT:String = "Feedrate maxed out. Check for rubbing warnings.";
      
      public const RPM_MAXED_OUT:String = "RPM maxed out.  Good for tool life, bad for productivity";
      
      public var didCC:Boolean = false;
      
      private var widthWatch:ChangeWatcher;
      
      private var heightWatch:ChangeWatcher;
      
      private var cribDownloadAttempts:int = 0;
      
      private var prefsGotten:Boolean = false;
      
      private var _stopRecalc:Boolean = false;
      
      private var gotMaterial:Boolean = false;
      
      private var gotTool:Boolean = false;
      
      private var mrrPct:Number = 0.0;
      
      private var rpmPct:Number = 0.0;
      
      private var ipmPct:Number = 0.0;
      
      private var sfmPct:Number = 0.0;
      
      private var iptPct:Number = 0.0;
      
      public var cuttingError:String = "";
      
      public var recalcAuxFcn:Function = null;
      
      public var runningAutomation:Boolean = false;
      
      private var lastGUIDsetTool:String = "";
      
      private var lastGensetTool:int = -1;
      
      private var lastCribNamesetTool:String = "";
      
      private var stopUMPRecurse:Boolean = false;
      
      private var rpmLimit:Number;
      
      private var rpmMinLimit:Number;
      
      private var feedLimit:Number;
      
      private var _hpLimit:Number;
      
      private var stopSMRecursion:Boolean = false;
      
      private var oldMachine:String = "";
      
      private var lastAliasToolType:String = "";
      
      private var lastToolAlias:String = "";
      
      private var errHint:String = "";
      
      private var advHBoxSave:HGroup = null;
      
      private var hsmSave:GWizForePanel = null;
      
      private var hsmEligible:Boolean;
      
      private var fsFile:File;
      
      private var defPct:Number;
      
      private var resizeExecuting:Boolean = false;
      
      private var _1311891495tipList:ArrayCollection;
      
      private var warnOn:Boolean = false;
      
      private var toolMenuSaves:int = 0;
      
      private var _166064001labelWidths:int = 90;
      
      private var _1699252388gapSizes:int = 5;
      
      public var mms:GWizFSMachineMaterialSelector;
      
      private var _513770495powerUserState:Boolean = true;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizFeedsSpeeds2()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.api = new GWizFeedSpeedAPI();
         this.fsm = new GWizFeedSpeedMath();
         this.cfg = new GWizConfigData();
         this._1311891495tipList = new ArrayCollection();
         this.mms = this.mmsDefault;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizFeedsSpeeds2_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizFeedsSpeeds2WatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizFeedsSpeeds2[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.paddingBottom = 1;
         this.paddingLeft = 1;
         this.paddingRight = 1;
         this.paddingTop = 1;
         this.gap = 1;
         this.mxmlContent = [this._GWizFeedsSpeeds2_HGroup1_i(),this._GWizFeedsSpeeds2_GWizToolDef1_i(),this._GWizFeedsSpeeds2_GWizMfgCutterSpecs1_i(),this._GWizFeedsSpeeds2_HGroup4_i(),this._GWizFeedsSpeeds2_HGroup8_c(),this._GWizFeedsSpeeds2_HGroup10_i(),this._GWizFeedsSpeeds2_HGroup13_i(),this._GWizFeedsSpeeds2_GWizForePanel12_i(),this._GWizFeedsSpeeds2_GWizForePanel13_i()];
         this.addEventListener("creationComplete",this.___GWizFeedsSpeeds2_VGroup1_creationComplete);
         this.addEventListener("initialize",this.___GWizFeedsSpeeds2_VGroup1_initialize);
         this.addEventListener("keyUp",this.___GWizFeedsSpeeds2_VGroup1_keyUp);
         this.addEventListener("click",this.___GWizFeedsSpeeds2_VGroup1_click);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function logFeedsSpeeds() : void
      {
         var _loc1_:Date = new Date();
         var _loc2_:Number = recalcFinished.valueOf() - _loc1_.valueOf();
         _loc2_ /= 1000;
         if(_loc2_ > 10)
         {
            GATracker.logPageView("FeedsSpeeds/Done","FeedsSpeeds/Done");
         }
         recalcFinished = _loc1_;
      }
      
      public static function set setFunctionsRecurse(param1:Boolean) : void
      {
         _setFunctionsRecurse = param1;
      }
      
      public static function get setFunctionsRecurse() : Boolean
      {
         return _setFunctionsRecurse;
      }
      
      private static function toolAndCribFromPrefs() : void
      {
         if(xmlKeeper)
         {
            GWizSettings.toolSelection = xmlKeeper.toolSelection;
            if(GWizSettings.toolSelection < 0)
            {
               GWizSettings.toolSelection = 0;
            }
            GWizSettings.FeedsSpeedsApp.Tool.selectedIndex = GWizSettings.toolSelection;
            GWizSettings.cribSelection = xmlKeeper.cribSelection;
            if(true || GWizSettings.cribSelection < 0)
            {
               GWizSettings.cribSelection = 0;
            }
            GWizSettings.FeedsSpeedsApp.cribTbl.selectedIndex = GWizSettings.cribSelection;
         }
      }
      
      public static function processXMLData(param1:XML) : XML
      {
         xmlKeeper = param1;
         GWizSettings.materialChoice = param1.materialChoice;
         if(GWizSettings.materialChoice < 0)
         {
            GWizSettings.materialChoice = 0;
         }
         GWizSettings.materialHardness = param1.materialHardness;
         if(GWizSettings.materialHardness <= 0)
         {
            GWizSettings.materialHardness = -1;
         }
         GWizSettings.materialSelection = param1.materialSelection;
         GWizSettings.showAdvanced = param1.ShowAdvanced == "true";
         if(!param1.hasOwnProperty("deflectPct"))
         {
            param1.deflectPct = 20;
         }
         GWizSettings.deflectPct = param1.deflectPct;
         if(GWizSettings.deflectPct > 80)
         {
            GWizSettings.deflectPct = 20;
         }
         if(!param1.hasOwnProperty("bestFinish"))
         {
            param1.bestFinish = "false";
         }
         GWizDeflectOptions.bestFinishAux = param1.bestFinish == "true";
         if(!param1.hasOwnProperty("limitChatter"))
         {
            param1.limitChatter = "true";
         }
         GWizDeflectOptions.limitChatterAux = param1.limitChatter == "true";
         if(GWizSettings.UPDATE_NOW <= param1.updatePref && param1.updatePref <= GWizSettings.UPDATE_URGENT)
         {
            GWizSettings.updatePref = param1.updatePref;
         }
         GWizFeedsSpeeds2.showExport = param1.ShowExport == "true";
         GWizFeedsSpeeds2.exportBtnLabel = param1.exportBtnLbl;
         if(GWizFeedsSpeeds2.exportBtnLabel == "")
         {
            GWizFeedsSpeeds2.exportBtnLabel = "Copy";
         }
         GWizFeedsSpeeds2.exportBtnFileMode = param1.exportBtnFileMode == "true";
         GWizFeedsSpeeds2.exportBtnDataFormat = param1.exportBtnDataFormat;
         if(GWizFeedsSpeeds2.exportBtnDataFormat.length == 0)
         {
            GWizFeedsSpeeds2.exportBtnDataFormat = GWizClipUtils.TSV_FORMAT;
         }
         return param1;
      }
      
      public static function createXMLData(param1:XML) : XML
      {
         param1.toolSelection = GWizSettings.toolSelection;
         param1.cribSelection = GWizSettings.cribSelection;
         param1.materialChoice = GWizSettings.materialChoice;
         param1.materialHardness = GWizSettings.materialHardness;
         param1.materialSelection = GWizSettings.materialSelection;
         param1.ShowAdvanced = GWizSettings.showAdvanced;
         param1.deflectPct = GWizSettings.deflectPct;
         param1.bestFinish = GWizDeflectOptions.bestFinishAux;
         param1.limitChatter = GWizDeflectOptions.limitChatterAux;
         param1.updatePref = GWizSettings.updatePref;
         param1.ShowExport = GWizFeedsSpeeds2.showExport;
         param1.exportBtnLbl = GWizFeedsSpeeds2.exportBtnLabel;
         param1.exportBtnFileMode = GWizFeedsSpeeds2.exportBtnFileMode;
         param1.exportBtnDataFormat = GWizFeedsSpeeds2.exportBtnDataFormat;
         return param1;
      }
      
      public static function popToolMenu() : void
      {
         GWizSettings.FeedsSpeedsApp.Tool.showToolMenu2();
      }
      
      public static function plungeModeToIdx(param1:String) : int
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < PlungeModes.length)
         {
            _loc3_ = PlungeModes.getItemAt(_loc2_);
            if(_loc3_.label == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizFeedsSpeeds2._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get APP_NAME() : String
      {
         return GWizFeedsSpeeds2._1979827721APP_NAME;
      }
      
      public static function set APP_NAME(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizFeedsSpeeds2._1979827721APP_NAME;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizFeedsSpeeds2,"APP_NAME",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get showExport() : Boolean
      {
         return GWizFeedsSpeeds2._385935633showExport;
      }
      
      public static function set showExport(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizFeedsSpeeds2._385935633showExport;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizFeedsSpeeds2,"showExport",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get exportBtnLabel() : String
      {
         return GWizFeedsSpeeds2._1324756428exportBtnLabel;
      }
      
      public static function set exportBtnLabel(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizFeedsSpeeds2._1324756428exportBtnLabel;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizFeedsSpeeds2,"exportBtnLabel",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get exportBtnFileMode() : Boolean
      {
         return GWizFeedsSpeeds2._587876199exportBtnFileMode;
      }
      
      public static function set exportBtnFileMode(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizFeedsSpeeds2._587876199exportBtnFileMode;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizFeedsSpeeds2,"exportBtnFileMode",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get exportBtnDataFormat() : String
      {
         return GWizFeedsSpeeds2._1583662185exportBtnDataFormat;
      }
      
      public static function set exportBtnDataFormat(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizFeedsSpeeds2._1583662185exportBtnDataFormat;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizFeedsSpeeds2,"exportBtnDataFormat",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get PlungeModes() : ArrayCollection
      {
         return GWizFeedsSpeeds2._169348707PlungeModes;
      }
      
      public static function set PlungeModes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizFeedsSpeeds2._169348707PlungeModes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizFeedsSpeeds2,"PlungeModes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function get plungeModeIdx#369() : int
      {
         return this.plungeModeX.selectedIndex;
      }
      
      public function set plungeModeIdx#1(param1:int) : void
      {
         this.plungeModeX.selectedIndex = param1;
      }
      
      override protected function commitProperties() : void
      {
         if(!GWizSettings.FeedsSpeedsApp)
         {
            this.onCreationComplete();
         }
         super.commitProperties();
         this.recalcAux();
      }
      
      private function onInit() : void
      {
         GWizSettings.FeedsSpeedsApp = this;
         if(Capabilities.screenResolutionX <= 1024)
         {
            setStyle("fontSize",10);
            this.RPM.setStyle("fontSize",12);
            this.IPM.setStyle("fontSize",12);
         }
         GWizNumStep.checkUnitsCC.addFunction("GWizFeedsSpeeds2",this.checkUnits,false);
      }
      
      private function setRPMIPM(param1:Number, param2:Number) : void
      {
         this.RPM.setVal(param1);
         this.rpmTempSlider.value = param1;
         if(this.fsm.toolParms.toolType.indexOf("Tapping") != -1)
         {
            this.IPM.resetOverride();
         }
         this.IPM.setVal(param2);
         this.feedTempSlider.value = param2;
         if(GWizCadCam.recalcEngine)
         {
            this.errHint = "";
            this.checkRedlineOvrOvr(this.RPM,this.rpmLimit,this.RPM_MAXED_OUT);
            this.checkRedlineOvrOvr(this.IPM,this.feedLimit);
            if(this.cuttingError == this.FEEDRATE_MAXED_OUT)
            {
               this.cuttingError = "";
            }
            if(this.fsm.minRPMError)
            {
               GWizSettings.showAdvanced = true;
               this.doAdvanced();
               this.cuttingError = this.RPM_TOO_HIGH_ERR;
               if(this.fsm.tooHighDia >= 0.125)
               {
                  this.cuttingError += " Try " + String(GWizUtils.roundThousandths(this.fsm.tooHighDia)) + " inch diameter.";
               }
               this.errHint = this.cuttingError;
               this.RPM.stepper.setAlertTextColor(true);
            }
            else
            {
               if(this.RPM.getVal() <= this.rpmLimit)
               {
                  this.RPM.stepper.setAlertTextColor(false);
               }
               if(this.cuttingError.indexOf(this.RPM_TOO_HIGH_ERR) >= 0)
               {
                  this.cuttingError = "";
               }
               if(this.errHint.indexOf(this.RPM_TOO_HIGH_ERR) >= 0)
               {
                  this.errHint = "";
               }
            }
         }
         if(this.setRPMIPMCallback != null)
         {
            this.setRPMIPMCallback(param1,param2);
         }
      }
      
      private function onCreationComplete() : void
      {
         if(GWizAbstractPrefs.isOEM)
         {
            this.tipsTitlePanel.title = "Tune";
            this.hint.visible = false;
            this.hint.includeInLayout = false;
            this.addTip(GWizAbstractPrefs.oemInfo(GWizAbstractPrefs.TIP1),false,true);
            this.addTip(GWizAbstractPrefs.oemInfo(GWizAbstractPrefs.TIP2),false,true);
            this.addTip(GWizAbstractPrefs.oemInfo(GWizAbstractPrefs.TIP3),false,true);
            this.addTip(GWizAbstractPrefs.oemInfo(GWizAbstractPrefs.TIP4),false,true);
         }
         if(GWizSettings.FeedsSpeedsApp == null)
         {
            this.onInit();
         }
         if(this.didCC)
         {
            return;
         }
         GWizAbstractPrefs.powerUserCC.addFunction("GWizFeedsSpeeds2",this.powerUserChanged,false);
         this.powerUserChanged(null);
         if(!this.mms)
         {
            this.mms = this.mmsDefault;
         }
         GWizMachSettings.selectMachineCC.addFunction("GWizFeedsSpeeds2",this.selectMachineCC);
         this.selectMachineCC();
         this.fsm.stopRecalc = false;
         this.cutDepth.customArrowInterval(GWizUtils.SIXTEENTH,GWizUtils.TENTH_MM);
         this.cutWidth.customArrowInterval(GWizUtils.SIXTEENTH,GWizUtils.TENTH_MM);
         this.td.IPT = this.IPT;
         this.td.recalcFcn = this.recalc;
         this.td.setFunctionsFcn = this.setFunctions;
         if(GWizSettings.theCrib)
         {
            GWizSettings.theCrib.verifyToolCrib = this.toolCribVerify;
         }
         this.setConstKeys();
         this.doCribTbl();
         this.MiniCalcs.td = this.td;
         this.MiniCalcs.fsr = this.recalc;
         this.MiniCalcs.setWidth = this.setWidth;
         this.MiniCalcs.fsm = this.fsm;
         this.didCC = true;
         this.doAdvanced();
         this.checkUnits();
         this.doAuxPrefs();
         if(xmlKeeper)
         {
            toolAndCribFromPrefs();
         }
         else
         {
            this.callLater(toolAndCribFromPrefs);
         }
         var _loc1_:GWizJustASec = new GWizJustASec(this.setFunctions);
      }
      
      private function doAuxPrefs() : void
      {
         var _loc1_:String = null;
         if(GWizAbstractPrefs.auxPrefsSet)
         {
            if(!GWizAbstractPrefs.isOEM)
            {
               return;
            }
            _loc1_ = GWizAbstractPrefs.oemStr;
            if(_loc1_ == "")
            {
               return;
            }
            GWizSettings.cribData.checkOEMCribExists(_loc1_);
         }
         this.callLater(this.doAuxPrefs);
      }
      
      private function setWidth(param1:Number) : void
      {
         this.cutWidth.setVal(param1);
      }
      
      private function getPrefs() : void
      {
         if(!this.prefsGotten && GWizSettings.gotPreferences && this.mms)
         {
            this.mms.MatChooser.MaterialSelectedIndex = GWizSettings.materialChoice;
            this.Tool.selectedIndex = 0;
            if(!GWizAbstractPrefs.isOEM)
            {
               this.cribTbl.selectedIndex = 0;
            }
            this.doAdvanced();
            this.prefsGotten = true;
         }
      }
      
      private function setConstKeys() : void
      {
         GWizUtils.assert(this.cutDepth.addConstKey(this.td._toolDiameter.getValCurrUnits(),"d"));
         GWizUtils.assert(this.cutDepth.addConstKey(this.td._toolDiameter.getValCurrUnits(),"D"));
      }
      
      private function set stopRecalc(param1:Boolean) : void
      {
         this._stopRecalc = false;
      }
      
      private function get stopRecalc() : Boolean
      {
         return this._stopRecalc;
      }
      
      private function recalcReady() : Boolean
      {
         var _loc1_:Boolean = false;
         return Boolean(!this.fsm.stopRecalc && !this.stopRecalc);
      }
      
      public function checkUnits(param1:Object = null) : Boolean
      {
         this.getPrefs();
         if(this.recalcReady())
         {
            this.stopRecalc = true;
            this.AFPT.checkUnits();
            this.MRR.checkUnits();
            this.PlungeRate.checkUnits();
            if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
            {
               this.SFM.titleTxt = "Surface Speed";
               this.mfgSpecs.mfgSFM.titleTxt = "Sfc Speed";
               this.IPT.titleTxt = "Chipload";
               this.mfgSpecs.mfgIPT.titleTxt = "Chipload";
               this.IPR.setLabTxt("IPR");
               this.MRR.setLabTxt("MRR (ci)");
               this.IPM.titleTxt = "Feedrate";
               this.IPM.steps = 0.001;
            }
            else
            {
               this.SFM.titleTxt = "Surface Speed";
               this.mfgSpecs.mfgSFM.titleTxt = "Sfc Speed";
               this.IPT.titleTxt = "Chipload";
               this.mfgSpecs.mfgIPT.titleTxt = "Chipload";
               this.IPR.setLabTxt("mm/rev");
               this.MRR.setLabTxt("MRR (cc)");
               this.IPM.titleTxt = "Feedrate";
               this.IPM.steps = 0.1;
            }
            this.selectMachine();
            this.setConstKeys();
            this.setFunctions();
            this.stopRecalc = false;
         }
         return true;
      }
      
      private function onToolChange() : void
      {
         this.gotTool = true;
      }
      
      private function onMatChange() : void
      {
         this.gotMaterial = true;
         this.resetNonLimits();
         this.recalc();
      }
      
      public function recalc(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.setFunctions();
         }
         this.invalidateProperties();
      }
      
      public function recalcAuxForCutKB() : void
      {
         var _loc11_:Boolean = false;
         GWizUtils.LogErrorContext = "GWizFeedsSpeeds2.recalcAux";
         var _loc1_:Number = -1;
         var _loc2_:Number = -1;
         var _loc3_:Number = -1;
         var _loc4_:Number = -1;
         var _loc5_:Boolean = false;
         if(this.RPM.isOverridden())
         {
            _loc1_ = this.RPM.getVal();
            this.RPM.resetOverride();
            _loc5_ = true;
         }
         if(this.IPM.isOverridden())
         {
            _loc2_ = this.IPM.getVal();
            this.IPM.resetOverride();
            _loc5_ = true;
         }
         if(this.SFM.isOverridden())
         {
            _loc3_ = this.SFM.getVal();
            this.SFM.resetOverride();
            _loc5_ = true;
         }
         if(this.IPT.isOverridden())
         {
            _loc4_ = this.IPT.getVal();
            this.IPT.resetOverride();
            _loc5_ = true;
         }
         this.recalcAux();
         var _loc6_:Number = this.MRR.getVal();
         var _loc7_:Number = this.RPM.getVal();
         var _loc8_:Number = this.IPM.getVal();
         var _loc9_:Number = this.SFM.getVal();
         var _loc10_:Number = this.IPT.getVal();
         if(_loc5_)
         {
            _loc11_ = false;
            if(_loc1_ != -1)
            {
               this.RPM.setValOverride(_loc1_);
               _loc11_ = true;
            }
            if(_loc2_ != -1)
            {
               this.IPM.setValOverride(_loc2_);
               _loc11_ = true;
            }
            if(_loc3_ != -1)
            {
               this.SFM.setValOverride(_loc3_);
               _loc11_ = true;
            }
            if(_loc4_ != -1)
            {
               this.IPT.setValOverride(_loc4_);
               _loc11_ = true;
            }
            if(_loc11_)
            {
               this.recalcAux();
            }
            this.mrrPct = GWizUtils.zeroNaN(GWizUtils.roundHundredths((this.MRR.getVal() - _loc6_) / _loc6_ * 100));
            this.rpmPct = GWizUtils.zeroNaN(GWizUtils.roundHundredths((this.RPM.getVal() - _loc7_) / _loc7_ * 100));
            this.ipmPct = GWizUtils.zeroNaN(GWizUtils.roundHundredths((this.IPM.getVal() - _loc8_) / _loc8_ * 100));
            this.sfmPct = GWizUtils.zeroNaN(GWizUtils.roundHundredths((this.SFM.getVal() - _loc9_) / _loc9_ * 100));
            this.iptPct = GWizUtils.zeroNaN(GWizUtils.roundHundredths((this.IPT.getVal() - _loc10_) / _loc10_ * 100));
         }
         else
         {
            this.mrrPct = 0;
            this.rpmPct = 0;
            this.ipmPct = 0;
            this.sfmPct = 0;
            this.iptPct = 0;
         }
         logFeedsSpeeds();
      }
      
      private function trackWimps() : void
      {
         if(!reportTortHareRough)
         {
            if(this.GasPedal.value > GWizTortHare.GAS_PEDAL_FINISH)
            {
               if(this.GasPedal.value < GWizTortHare.GAS_PEDAL_MAX)
               {
                  GATracker.logPageView("TortHare/LessRough");
                  reportTortHareRough = true;
               }
            }
         }
      }
      
      public function currMaterial() : String
      {
         return this.mms.MatChooser.Selection;
      }
      
      private function hideHSM() : Boolean
      {
         var _loc1_:Boolean = GWizAbstractPrefs.isOEM;
         var _loc2_:String = GWizGarrOEMToolData.materialToOEMISOCode(this.currMaterial());
         _loc1_ = this.cutWidth.value > this.fsm.toolParms.toolDiam * 0.15 || _loc2_.indexOf("S") >= 0 || _loc2_.indexOf("M") >= 0 || _loc2_.indexOf("N") >= 0;
         return Boolean(_loc1_ && GWizAbstractPrefs.isOEM);
      }
      
      public function useHSM() : Boolean
      {
         return this.showHSMFeedsSpeeds.selected && this.showHSMFeedsSpeeds.visible;
      }
      
      public function recalcAux() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:GWizDeflectMath = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         GWizUtils.LogErrorContext = "GWizFeedsSpeeds2.recalcAux";
         if(this.recalcReady())
         {
            if(GWizAbstractPrefs.isGarr() && !this.td.toolParms.isTwistDrill())
            {
               if(this.cutWidth.value / this.td._toolDiameter.value >= 0.3)
               {
                  this.cutDepth.value = Math.min(this.cutDepth.value,this.td._toolDiameter.value * 1.5);
                  if(this.td._flutes.value > 4 && this.cutWidth.value / this.td._toolDiameter.value >= 0.35)
                  {
                     this.cutWidth.value = this.td._toolDiameter.value * 0.35;
                  }
               }
            }
            this.stopRecalc = true;
            this.cuttingError = "";
            this.trackWimps();
            this.clearTips();
            this.selectMachine();
            _loc1_ = this.showHSMFeedsSpeeds.visible;
            if(this.hideHSM())
            {
               this.showHSMFeedsSpeeds.visible = false;
            }
            else if(this.hsmEligible)
            {
               this.showHSMFeedsSpeeds.visible = true;
            }
            if(!this.gotMaterial)
            {
               this.mms.MatChooser.MaterialSelectedIndex = GWizSettings.materialChoice;
            }
            this.fsm.materialName = this.currMaterial();
            this.fsm.materialIndex = this.mms.MatChooser.MaterialSelectedIndex;
            this.fsm.adjHardness = GWizSettings.materialHardness;
            this.fsm.toolParms.toolType = this.getToolType();
            this.fsm.toolParms.setFromTD(this.td);
            if(this.td.toolParms.toolDiam <= 0.1)
            {
               this.IPT.steps = 0.00001;
               this.IPR.decPlaces = 5;
            }
            else
            {
               this.IPT.steps = 0.00001;
               this.IPR.decPlaces = 4;
            }
            this.fsm.cutDepth = this.cutDepth.getVal();
            this.fsm.cutWidth = this.cutWidth.getVal();
            if(this.getToolType().indexOf("Turning") >= 0)
            {
               this.fsm.cutWidth = this.cutDepth.getVal();
            }
            this.fsm.sfm.setOverVal(this.SFM.getVal(),this.SFM.isOverridden());
            this.fsm.mfgSFM.setOverVal(this.mfgSpecs.mfgSFM.getVal(),this.mfgSpecs.mfgSFM.isOverridden());
            this.fsm.rpm.setOverVal(this.RPM.getVal(),this.RPM.isOverridden());
            this.fsm.rpmLimit.setOverVal(this.rpmLimit,false);
            this.fsm.rpmMinLimit.setOverVal(this.rpmMinLimit,false);
            this.fsm.feedLimit.setOverVal(this.feedLimit,false);
            _loc2_ = GWizCredentials.isGWLite();
            this.hpLimit = GWizSpindleCurve.calcHP(this.RPM.getVal(),0,this.fsm.toolParms.toolType.indexOf("Drill") < 0);
            if(this.Torque.isOverridden() && this.fsm.toolParms.toolType.indexOf("Drill") < 0)
            {
               if((_loc5_ = this.Torque.getVal() / 16 * this.fsm.rpm.value / 63030) < this.hpLimit)
               {
                  this.hpLimit = _loc5_;
                  this.addTip("Spindle power limited by torque limit");
               }
            }
            this.fsm.hpLimit.setOverVal(this.hpLimit,false);
            this.fsm.hpLimitHit = false;
            this.fsm.ipt.setOverVal(this.IPT.getVal(),this.IPT.isOverridden());
            this.fsm.mfgIPT.setOverVal(this.mfgSpecs.mfgIPT.getVal(),this.mfgSpecs.mfgIPT.isOverridden());
            this.fsm.ipm.setOverVal(this.IPM.getVal(),this.IPM.isOverridden());
            this.fsm.hsmFeedsSpeedsAdj = this.useHSM();
            this.fsm.gasPedal = this.GasPedal.value;
            this.fsm.tsc = this.TSC.selected;
            this.fsm.pcn = this.PCN.selected;
            this.fsm.recalc();
            if(this.cutWidth.value > this.fsm.effDiam && this.hsmSave == null)
            {
               this.cutWidth.setVal(this.fsm.effDiam);
            }
            this.AxialEngagement.text = "Axial: " + String(this.fsm.axialEngagement) + "%";
            this.fsm.axialEngagementHint(this.fsm.axialEngagement);
            this.RadialEngagement.text = "Radial: " + String(this.fsm.radialEngagement) + "%";
            this.fsm.radialEngagementHint(this.fsm.radialEngagement);
            if(this.fsm.toolParms.isTapping())
            {
               if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
               {
                  this.RadialEngagement.text = String(this.fsm.radialEngagement) + " TPI";
               }
               else
               {
                  this.RadialEngagement.text = String(this.fsm.radialEngagement) + " TPMM";
               }
            }
            else if(this.fsm.toolParms.isReamer())
            {
               this.RadialEngagement.text = "Make hole " + GWizUtils.roundThousandths(0.02 * this.td.toolParms.toolDiam,true) + " to " + GWizUtils.roundThousandths(0.05 * this.td.toolParms.toolDiam,true) + " undersized";
            }
            this.SFM.setVal(this.fsm.sfm.value);
            this.mfgSpecs.mfgSFM.setVal(this.fsm.mfgSFM.value);
            this.setRPMIPM(this.fsm.rpm.value,this.fsm.ipm.value);
            this.IPT.setVal(this.fsm.ipt.value);
            this.mfgSpecs.mfgIPT.setVal(this.fsm.mfgIPT.value);
            this.IPR.setVal(this.fsm.ipr);
            this.AFPT.setVal(this.fsm.afpt);
            this.MRR.setVal(this.fsm.mrr);
            this.HP.setVal(this.fsm.hp);
            this.hpTempSlider.value = this.fsm.hp;
            this.PlungeRate.setVal(this.getPlungeRate());
            this.EffDiam.value = this.fsm.effDiam;
            this.stopRecalc = false;
            _loc3_ = new GWizDeflectMath();
            this.Deflect.setVal(_loc3_.toolDeflection(this.cutDepth.getVal(),this.IPM.getVal(),this.RPM.getVal(),this.td.toolParms.stickout,false,this.td.toolParms.flutes,this.td.toolParms.helixAngle));
            if(this.deflectErr(this.GasPedal.value > GWizTortHare.GAS_PEDAL_FINISH))
            {
               if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
               {
                  this.Deflect.setAlertTextColor(true);
                  GWizSettings.showAdvanced = true;
                  this.doAdvanced();
               }
               this.cuttingError = "Deflection Error";
            }
            else if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
            {
               this.Deflect.setAlertTextColor(false);
            }
            _loc4_ = (_loc4_ = GWizDeflectMath.torque(this.fsm.hp,this.RPM.getVal())) * 16;
            this.Torque.setVal(_loc4_);
            if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
            {
               this.IPT.setStyle("color",GWizStylePalette.textColor);
               this.mfgSpecs.mfgIPT.setStyle("color",GWizStylePalette.textColor);
               this.SFM.setStyle("color",GWizStylePalette.textColor);
               this.mfgSpecs.mfgSFM.setStyle("color",GWizStylePalette.textColor);
            }
            this.checkForRubbing();
            this.addCoolantTips();
            this.hint.toolTip = this.hint.text;
            if(this.errHint != "")
            {
               this.addTip(this.errHintTip(),true);
            }
            if(this.recalcAuxFcn != null)
            {
               this.recalcAuxFcn(this.fsm.rpm.value,this.fsm.ipm.value);
            }
         }
      }
      
      private function addCoolantTips() : void
      {
         if(this.TSC.selected)
         {
            this.addTip("Using Through Spindle Coolant.");
         }
         else if(this.PCN.selected)
         {
            this.addTip("Using Programmable Coolant Nozzle.");
         }
      }
      
      public function recalcWidthDepth(param1:Number, param2:Number) : void
      {
         this.stopRecalc = true;
         this.cuttingError = "";
         this.clearTips();
         this.cutDepth.setVal(param2);
         this.cutWidth.setVal(param1);
         this.fsm.cutDepth = this.cutDepth.getVal();
         this.fsm.cutWidth = this.cutWidth.getVal();
         this.fsm.recalc();
         if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
         {
            this.RadialEngagement.text = "Radial: " + String(this.fsm.radialEngagement) + "%";
            this.fsm.axialEngagementHint(this.fsm.axialEngagement);
            this.fsm.radialEngagementHint(this.fsm.radialEngagement);
         }
         if(this.errHint != "")
         {
            this.addTip(this.errHintTip(),true);
         }
         this.SFM.setVal(this.fsm.sfm.value);
         this.mfgSpecs.mfgSFM.setVal(this.fsm.mfgSFM.value);
         this.setRPMIPM(this.fsm.rpm.value,this.fsm.ipm.value);
         this.IPT.setVal(this.fsm.ipt.value);
         this.mfgSpecs.mfgIPT.setVal(this.fsm.mfgIPT.value);
         this.IPR.setVal(this.fsm.ipr);
         this.AFPT.setVal(this.fsm.afpt);
         this.MRR.setVal(this.fsm.mrr);
         this.HP.setVal(this.fsm.hp);
         this.hpTempSlider.value = this.fsm.hp;
         this.PlungeRate.setVal(this.getPlungeRate());
         this.EffDiam.value = GWizUtils.roundThousandths(this.fsm.effDiam,true);
         this.stopRecalc = false;
         var _loc3_:GWizDeflectMath = new GWizDeflectMath();
         this.Deflect.setVal(_loc3_.toolDeflection(this.cutDepth.getVal(),this.IPM.getVal(),this.RPM.getVal(),this.td.toolParms.stickout,false,this.td.toolParms.flutes,this.td.toolParms.helixAngle));
         if(this.deflectErr(this.GasPedal.value > GWizTortHare.GAS_PEDAL_FINISH))
         {
            this.cuttingError = "Deflection Error";
            if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
            {
               this.Deflect.setAlertTextColor(true);
               GWizSettings.showAdvanced = true;
               this.doAdvanced();
            }
         }
         else if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
         {
            this.Deflect.setAlertTextColor(false);
         }
         this.checkForRubbing();
         this.hint.toolTip = this.hint.text;
      }
      
      private function errHintTip() : String
      {
         var _loc1_:String = this.errHint;
         switch(this.errHint)
         {
            case this.FEEDRATE_MAXED_OUT:
            case this.RPM_MAXED_OUT:
               break;
            default:
               _loc1_ = "Error: " + _loc1_;
         }
         return _loc1_;
      }
      
      private function checkForRubbing() : void
      {
         var _loc1_:Number = this.fsm.rubChipload(this.fsm.effDiam,this.fsm.mfgIPT.value);
         if(this.fsm.ipt.value < _loc1_ && this.fsm.toolParms.toolType.toLowerCase().indexOf("mill") >= 0 && this.fsm.toolParms.hasRubbingLimit())
         {
            this.addTip("Warning: Chipload is low, may cause rubbing!",true);
            this.cuttingError = "Rubbing Error: Increase Feedrate";
         }
      }
      
      public function resetAll() : void
      {
         var _loc1_:ArrayCollection = null;
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:Object = null;
         if(GWizUtils.debug)
         {
            _loc1_ = new ArrayCollection();
            _loc2_ = ["Axial","Radial","CutWidth","RPM","Feed","SFM","IPT","HSMRPM","HSMFeed","HSMSFM","HSMIPT"];
            _loc3_ = 5;
            while(_loc3_ <= 100)
            {
               _loc4_ = new Object();
               this.cutWidth.value = _loc3_ / 100 * this.td.toolParms.toolDiam;
               this.showHSMFeedsSpeeds.selected = false;
               this.recalcAux();
               _loc4_.Axial = String(this.fsm.axialEngagement) + "%";
               _loc4_.Radial = String(this.fsm.radialEngagement) + "%";
               _loc4_.CutWidth = this.fsm.cutWidth;
               _loc4_.RPM = this.fsm.rpm.value;
               _loc4_.Feed = this.fsm.ipm.value;
               _loc4_.SFM = this.fsm.sfm.value;
               _loc4_.IPT = this.fsm.ipt.value;
               this.showHSMFeedsSpeeds.selected = true;
               this.recalcAux();
               _loc4_.HSMRPM = this.fsm.rpm.value;
               _loc4_.HSMFeed = this.fsm.ipm.value;
               _loc4_.HSMSFM = this.fsm.sfm.value;
               _loc4_.HSMIPT = this.fsm.ipt.value;
               _loc1_.addItem(_loc4_);
               _loc3_ += 5;
            }
            GWizCSVUtils.saveCSVFileURL("C:\\Users\\Bob Warfield\\Downloads\\Bozon.csv",_loc1_,_loc2_);
            return;
         }
         this.cutWidth.value = 0;
         this.cutDepth.value = 0;
         this.showHSMFeedsSpeeds.selected = false;
         this.GasPedal.value = GWizTortHare.GAS_PEDAL_MAX;
         this.resetNonLimits();
      }
      
      private function resetNonLimits() : void
      {
         GWizUtils.LogErrorContext = "GWizFeedsSpeeds2.resetNonLimits";
         if(this.td && this.SFM && this.RPM && this.IPT && this.IPM)
         {
            this.SFM.resetOverride();
            this.RPM.resetOverride();
            this.IPT.resetOverride();
            this.IPM.resetOverride();
            this.mfgSpecs.resetOverride();
            this.recalc();
         }
      }
      
      public function setToolFromGUID(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:GWizToolCribEntry = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         if(!param1 || param1 == "")
         {
            return;
         }
         var _loc2_:Boolean = false;
         if(GWizSettings.cacheToolGUIDS && this.lastGUIDsetTool == param1 && this.lastGensetTool == GWizToolCrib.showGeneration)
         {
            _loc3_ = this.lastCribNamesetTool;
         }
         else
         {
            _loc3_ = (_loc4_ = GWizToolCribData.ToolCrib.getCribEntryByGUID(param1)).tabname;
            _loc2_ = true;
            this.lastGUIDsetTool = param1;
            this.lastGensetTool = GWizToolCrib.showGeneration;
            this.lastCribNamesetTool = _loc3_;
         }
         if(!this.cribTbl || !this.cribTbl.selectedItem || this.cribTbl.selectedItem.tabname != _loc3_)
         {
            _loc5_ = 0;
            while(_loc5_ < GWizCribList.cribListPlus.length)
            {
               if((_loc6_ = GWizCribList.cribListPlus.getItemAt(_loc5_)).tabname == _loc3_)
               {
                  this.cribTbl.selectedIndex = _loc5_;
                  this.cribTbl.validateNow();
                  _loc2_ = true;
                  break;
               }
               _loc5_++;
            }
         }
         if(_loc2_)
         {
            this.Tool.setGuid(param1);
            this.gotTool = true;
            this.doCribTbl();
            this.onCribTblVC();
         }
         this.Tool.setGuid(param1);
      }
      
      private function setFunctions() : void
      {
         var _loc3_:String = null;
         var _loc4_:GWizToolCribEntry = null;
         var _loc5_:GWizToolCribArray = null;
         var _loc6_:GWizToolCribEntry = null;
         GWizUtils.LogErrorContext = "GWizFeedsSpeeds2.setFunctions";
         if(this.td == null || !this.td.ccDone || setFunctionsRecurse || GWizSettings.cribGeneration == 0 || this.cribTbl.selectedItem == null || !this.stage)
         {
            if(!setFunctionsRecurse)
            {
               this.callLater(this.setFunctions);
            }
            return;
         }
         GWizSettings.cribSelection = this.cribTbl.selectedItem;
         setFunctionsRecurse = true;
         if(GWizToolCribData.isCrib(this.cribTbl.selectedItem.tabname) && GWizSettings.theCrib)
         {
            _loc3_ = this.Tool.currGUID;
            if(_loc3_ == "")
            {
               if(_loc6_ = (_loc5_ = GWizSettings.cribData.currCrib(this.cribTbl.selectedItem.tabname)).getCribEntryAt(this.Tool.selectedIndex))
               {
                  _loc3_ = _loc6_.guid;
                  this.Tool.setGuid(_loc3_);
               }
            }
            this.td = GWizToolCribData.ToolCrib.getCribToolDefGUID(_loc3_,this.td);
            GWizToolDef.lockForToolCrib = !GWizToolCribData.ToolCrib.getCribGenericGUID(_loc3_);
            _loc4_ = GWizToolCribData.ToolCrib.getCribEntryByGUID(_loc3_);
            this.mfgSpecs.mfgSFM.resetOverride();
            this.mfgSpecs.mfgSFM.setVal(0);
            GWizMfgCutterSpecs.lockForToolCrib = true;
            if(_loc4_)
            {
               if(_loc4_.useMfgSFM)
               {
                  this.mfgSpecs.mfgSFM.setValOverride(_loc4_.mfgSFM);
               }
               this.mfgSpecs.mfgIPT.resetOverride();
               this.mfgSpecs.mfgIPT.setVal(0);
               if(_loc4_.useMfgIPT)
               {
                  this.mfgSpecs.mfgIPT.setValOverride(_loc4_.mfgIPT);
               }
               this.mfgSpecs.ToolFamily = _loc4_.toolFamily;
            }
            if(this.td.toolParms.isTap())
            {
               this.cutWidth.value = this.td.toolParms.threadPitch;
            }
         }
         else
         {
            GWizToolDef.lockForToolCrib = false;
            GWizMfgCutterSpecs.lockForToolCrib = false;
            if(this.mfgSpecs)
            {
               this.mfgSpecs.resetFamily();
            }
         }
         this.fsm.adjustSFMForLength = false;
         this.IPT.visible = true;
         this.cutDepthLabel.text = "Cut Depth";
         this.cutWidthLabel.text = "Cut Width";
         this.cutWidth.steps = 0.0001;
         this.RadialEngagement.text = "Radial: 0%";
         this.SlotBtn.visible = false;
         this.optWidth.visible = false;
         this.Deflect.visible = false;
         this.optDepth.visible = false;
         this.optSlider.visible = false;
         this.td.optStick.visible = false;
         var _loc1_:String = this.getToolType();
         this.td.setFunctions(_loc1_);
         this.showHSM(false);
         this.MiniCalcs.SurfaceFinish.enabled = false;
         this.MiniCalcs.Interpolate.enabled = false;
         this.MiniCalcs.setInterpolate2CutDepth(false);
         this.MiniCalcs.Ramp.enabled = false;
         this.MiniCalcs.Plunge.enabled = false;
         this.cutDepth.visible = true;
         this.PlungeRate.visible = false;
         this.PlungeRate.decPlaces = 1;
         this.cutDepth.toolTip = "Depth of Cut (ap) of a pass.  A pass is the length of cutter actually cutting.";
         var _loc2_:Boolean = GWizOptimizeBtn.showOptimizeButtons && !GWizAbstractPrefs.isOEM;
         this.AFPT.visible = true;
         switch(_loc1_)
         {
            case "Gun Drill":
               this.cutDepth.visible = false;
            case "HSS Spot Drill":
            case "Carbide Spot Drill":
            case "HSS Center Drill":
            case "Carbide Center Drill":
            case "HSS Twist Drill":
            case "Carbide Twist Drill":
            case "HSS Spade Drill":
            case "Carbide Spade Drill":
            case "Cobalt Twist Drill":
            case "HP HSS Twist Drill":
            case "HP Carbide Twist Drill":
            case "Annular Cutter (Rotabroach®)":
               this.AxialEngagement.visible = _loc1_.indexOf("Gun Drill") < 0 && this.powerUserState;
               this.cutWidth.setVal(this.td.toolParms.toolDiam);
               this.cutWidth.visible = false;
               this.RadialEngagement.visible = false;
               this.AFPT.visible = false;
               this.fsm.engagementThreshold = 1;
               if(this.getToolType().indexOf("Spade Drill") < 0 && this.getToolType().indexOf("Gun Drill") < 0)
               {
                  this.fsm.adjustSFMForLength = true;
               }
               this.cutDepth.toolTip = "Depth of Cut (ap) is the total hole depth.";
               break;
            case "Indexable Drill":
            case "HSS Reamer":
            case "Carbide Reamer":
               this.AxialEngagement.visible = this.powerUserState;
               this.cutWidth.setVal(this.td.toolParms.toolDiam);
               this.cutWidth.visible = false;
               this.RadialEngagement.visible = false;
               if(this.getToolType() != "Indexable Drill")
               {
                  this.IPT.visible = false;
                  this.RadialEngagement.visible = this.powerUserState;
                  this.RadialEngagement.text = "Make hole " + 0.02 * this.td.toolParms.toolDiam + " to " + 0.05 * this.td.toolParms.toolDiam + " undersized";
               }
               this.AFPT.visible = false;
               this.fsm.engagementThreshold = 1;
               this.cutDepth.toolTip = "Depth of Cut (ap) is the total hole depth.";
               break;
            case "Turning: HSS":
            case "Turning: Carbide":
            case "HSS Turning":
            case "Carbide Turning":
            case "Carbide Threading":
            case "HSS Threading":
            case "Threading":
               this.MiniCalcs.Interpolate.enabled = true;
               this.MiniCalcs.setInterpolate2CutDepth(true);
            case "Carbide Parting/Grooving":
            case "HSS Parting/Grooving":
            case "Parting/Grooving":
            case "Carbide Parting":
            case "HSS Parting":
            case "Parting":
            case "Carbide Grooving":
            case "HSS Grooving":
            case "Grooving":
            case "HSS Boring":
            case "Carbide Boring":
            case "HSS Boring Bar":
            case "Carbide Boring Bar":
               this.AxialEngagement.visible = false;
               this.cutWidth.visible = false;
               this.RadialEngagement.visible = false;
               this.AFPT.visible = false;
               this.MiniCalcs.SurfaceFinish.enabled = this.IPT != null && _loc1_.indexOf("Parting") < 0 && _loc1_.indexOf("Threading") < 0;
               if(_loc1_.indexOf("Parting") < 0)
               {
                  this.cutDepthLabel.text = "Cut Depth";
                  this.cutDepth.toolTip = "Depth of Cut (ap)";
               }
               else
               {
                  this.cutDepthLabel.text = "Tool Width";
                  this.cutDepth.toolTip = "Width of the parting or grooving tool tip.";
               }
               break;
            case "Carbide Saws & Woodruff Cutters":
            case "HSS Saws & Woodruff Cutters":
            case "Saws & Woodruff Cutters":
               this.cutDepthLabel.text = "Saw Thickness";
               this.cutWidthLabel.text = "Saw DOC";
               this.fsm.adjustSFMForLength = false;
               this.cutWidth.visible = true;
               this.AxialEngagement.visible = this.powerUserState;
               this.RadialEngagement.visible = this.powerUserState;
               this.SlotBtn.visible = false;
               this.optWidth.visible = false;
               this.Deflect.visible = false;
               this.optDepth.visible = false;
               this.optSlider.visible = false;
               this.td.optStick.visible = false;
               this.AFPT.visible = false;
               this.fsm.engagementThreshold = 1;
               this.cutDepth.toolTip = "Depth of Cut is the saw\'s thickness.";
               break;
            case "Carbide Tapping":
            case "HSS Tapping":
            case "Tapping":
               this.AxialEngagement.visible = true;
               this.cutWidthLabel.text = "Thread Pitch";
               this.cutWidth.visible = true;
               this.cutWidth.steps = 0.00001;
               this.RadialEngagement.text = "0 TPI";
               this.RadialEngagement.visible = this.powerUserState;
               this.AFPT.visible = false;
               this.fsm.engagementThreshold = 1;
               this.fsm.adjustSFMForLength = true;
               this.IPT.visible = false;
               this.cutDepth.toolTip = "Depth of Cut (ap) is the total hole depth.";
               break;
            case "Carbide Thread Mill":
               this.cutWidth.visible = true;
               this.AxialEngagement.visible = this.powerUserState;
               this.RadialEngagement.visible = this.powerUserState;
               this.optWidth.visible = _loc2_;
               this.Deflect.visible = true;
               this.optDepth.visible = _loc2_;
               this.optSlider.visible = _loc2_;
               this.td.optStick.visible = _loc2_;
               this.fsm.engagementThreshold = this.fsm.ENGAGEMENT_THRESHOLD;
               this.MiniCalcs.Interpolate.enabled = true;
               break;
            default:
               this.fsm.adjustSFMForLength = false;
               this.cutWidth.visible = true;
               this.AxialEngagement.visible = this.powerUserState;
               this.RadialEngagement.visible = this.powerUserState;
               this.SlotBtn.visible = true;
               this.optWidth.visible = _loc2_;
               this.Deflect.visible = true;
               this.optDepth.visible = _loc2_;
               this.optSlider.visible = _loc2_;
               this.td.optStick.visible = _loc2_;
               this.fsm.engagementThreshold = this.fsm.ENGAGEMENT_THRESHOLD;
               this.PlungeRate.visible = true;
               if(this.td.toolParms.isDowncut() || this.td.toolParms.isDowncut())
               {
                  this.addTip("Careful plunging downcut-router fires possible.");
               }
               this.showHSM(true);
               this.MiniCalcs.Interpolate.enabled = true;
               this.MiniCalcs.Ramp.enabled = true;
               this.MiniCalcs.Plunge.enabled = true;
               this.MiniCalcs.SurfaceFinish.enabled = this.td.toolParms.isBallnose();
         }
         this.MiniCalcs.Vacuum.visible = GWizMachSettings.currMachType != "Lathe";
         this.recalc();
         setFunctionsRecurse = false;
      }
      
      private function filterMachines(param1:Object) : Boolean
      {
         return param1.name == GWizMachSettings.currMachine;
      }
      
      private function updateSFMIPTAdjust(param1:Object) : void
      {
         this.fsm.msfmAdjust = 1;
         this.fsm.miptAdjust = 1;
         this.fsm.msfmAdjust *= param1.sfmAdjust;
         this.fsm.miptAdjust *= param1.chiploadAdjust;
         this.mms.updateSafeMode(param1.sfmAdjust,param1.chiploadAdjust);
         if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
         {
            if(this.fsm.msfmAdjust > 100)
            {
               this.mms.sfmAdjust.setStyle("color","#fd0c0c");
            }
            else
            {
               this.mms.sfmAdjust.setStyle("color",GWizStylePalette.textColor);
            }
            if(this.fsm.miptAdjust > 100)
            {
               this.mms.chiploadAdjust.setStyle("color","#fd0c0c");
            }
            else
            {
               this.mms.chiploadAdjust.setStyle("color",GWizStylePalette.textColor);
            }
         }
      }
      
      private function set hpLimit(param1:Number) : void
      {
         this._hpLimit = param1;
         this.hpTempSlider.maximum = this._hpLimit;
      }
      
      private function get hpLimit() : Number
      {
         return this._hpLimit;
      }
      
      public function updateMachineParms(param1:Boolean = false) : void
      {
         GWizUtils.LogErrorContext = "GWizFeedsSpeeds2.updateMachineParms";
         if(this.stopUMPRecurse)
         {
            return;
         }
         this.stopUMPRecurse = true;
         var _loc2_:Object = GWizMachSettings.lookupMachine(GWizMachSettings.currMachine);
         if(param1)
         {
            if(!_loc2_.hasOwnProperty("sessions") || isNaN(_loc2_.sessions))
            {
               _loc2_.sessions = 0;
            }
            ++_loc2_.sessions;
         }
         this.rpmLimit = _loc2_.rpmLimit;
         this.rpmTempSlider.maximum = this.rpmLimit;
         this.rpmMinLimit = _loc2_.rpmMinLimit;
         this.rpmTempSlider.minimum = this.rpmMinLimit;
         this.feedLimit = _loc2_.feedLimit;
         this.feedTempSlider.maximum = this.feedLimit;
         this.IPM.UnitLabel = String(_loc2_.feedSecMode).toLowerCase() == "true" ? "ips" : "ipm";
         this.hpLimit = GWizSpindleCurve.calcHP(this.RPM.getVal(),0,this.fsm.toolParms.toolType.indexOf("Drill") < 0);
         this.updateSFMIPTAdjust(_loc2_);
         this.TSC.enabled = String(_loc2_.tsc) == "true";
         if(!this.TSC.enabled)
         {
            this.TSC.selected = false;
         }
         this.fsm.hpc = String(_loc2_.hpc) == "true";
         this.PCN.enabled = String(_loc2_.pcn) == "true";
         if(!this.PCN.enabled)
         {
            this.PCN.selected = false;
         }
         this.stopUMPRecurse = false;
      }
      
      private function allowUpdateMachineParms() : void
      {
      }
      
      private function selectMachineCC(param1:Object = null) : Boolean
      {
         this.selectMachine();
         return true;
      }
      
      private function selectMachine() : void
      {
         GWizUtils.LogErrorContext = "GWizFeedsSpeeds2.selectMachine";
         if(this.stopSMRecursion)
         {
            return;
         }
         this.stopSMRecursion = true;
         setFunctionsRecurse = true;
         this.stopRecalc = true;
         if(GWizMachSettings.currMachine == this.oldMachine)
         {
            this.updateMachineParms();
            this.stopSMRecursion = false;
            setFunctionsRecurse = false;
            this.stopRecalc = false;
            return;
         }
         this.oldMachine = GWizMachSettings.currMachine;
         if(GWizMachSettings.MachinesList.length > 0)
         {
            this.updateMachineParms(true);
         }
         else
         {
            log.debug("No such machine!");
         }
         this.resetNonLimits();
         setFunctionsRecurse = false;
         this.stopRecalc = false;
         this.setFunctions();
         this.stopSMRecursion = false;
      }
      
      public function getToolType() : String
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc1_:String = this.Tool.selectedLabel;
         if(!this.gotTool)
         {
            this.Tool.selectedIndex = GWizSettings.toolSelection;
            _loc1_ = this.Tool.selectedLabel;
            this.cribTbl.selectedIndex = GWizSettings.cribSelection;
         }
         if(this.cribTbl.selectedItem && GWizToolCribData.isCrib(this.cribTbl.selectedItem.tabname))
         {
            if(GWizSettings.theCrib)
            {
               _loc1_ = GWizToolCribData.ToolCrib.getCribToolTypeGUID(this.Tool.currGUID,_loc1_);
            }
            else
            {
               this.cribTbl.selectedIndex = 0;
            }
         }
         if(this.lastAliasToolType == _loc1_)
         {
            _loc1_ = this.lastToolAlias;
         }
         else
         {
            this.lastAliasToolType = _loc1_;
            _loc2_ = 0;
            while(_loc2_ < GWizConfigData.ToolAlias.length)
            {
               _loc3_ = "";
               if(GWizMachSettings.currMachType == "Lathe")
               {
                  _loc3_ = GWizConfigData.ToolAlias[_loc2_].lathe;
               }
               else
               {
                  _loc3_ = GWizConfigData.ToolAlias[_loc2_].mill;
               }
               if(_loc1_ == _loc3_)
               {
                  _loc1_ = GWizConfigData.ToolAlias[_loc2_].table;
                  if(_loc1_ == "")
                  {
                     _loc1_ = GWizConfigData.ToolAlias[_loc2_].calculate;
                  }
               }
               _loc2_++;
            }
            this.lastToolAlias = _loc1_;
         }
         if(!_loc1_ || _loc1_ == "")
         {
            _loc1_ = "HSS Twist Drill";
         }
         return _loc1_;
      }
      
      private function getToolDataProvider() : Array
      {
         var _loc1_:Object = GWizMachSettings.lookupMachine(GWizMachSettings.currMachine);
         var _loc2_:Array = null;
         if(this.cribTbl.selectedItem && GWizToolCribData.isCrib(this.cribTbl.selectedItem.tabname) && this.cribTbl.selectedItem.tabname != "")
         {
            _loc2_ = GWizSettings.cribData.currToolList(this.cribTbl.selectedItem.tabname);
            GWizToolDef.lockForToolCrib = !GWizToolCribData.ToolCrib.getCribGenericGUID(this.Tool.currGUID);
         }
         if(!_loc2_)
         {
            _loc2_ = GWizToolData.MillToolsList;
            GWizToolDef.lockForToolCrib = false;
         }
         return _loc2_;
      }
      
      private function doCribTbl() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:GWizToolCribArray = null;
         var _loc4_:GWizToolCribEntry = null;
         if(!this.td || !this.cribTbl.selectedItem)
         {
            return;
         }
         this.stopRecalc = true;
         this.stopSMRecursion = true;
         setFunctionsRecurse = true;
         setFunctionsRecurse = false;
         if(this.cribTbl.selectedIndex <= 0)
         {
            _loc1_ = this.td.toolParms.toolType;
            _loc2_ = this.td.toolParms.geometry;
            _loc1_ = GWizToolMenu.toHybridLabel(_loc1_,_loc2_);
            this.setToolDataProvider();
            this.Tool.selectedLabel = _loc1_;
         }
         else
         {
            this.Tool.selectedIndex = this.Tool.selectedIndex;
            this.setToolDataProvider();
            _loc3_ = GWizSettings.cribData.currCrib(this.cribTbl.selectedItem.tabname);
            _loc4_ = _loc3_.getCribEntryAt(this.Tool.selectedIndex);
            this.Tool.setMenuPick(this.Tool.selectedLabel,this.Tool.selectedIndex,_loc4_.guid);
         }
         this.stopSMRecursion = false;
         if(this.cribTbl.selectedIndex > 0)
         {
            GATracker.logPageView("Feeds/Speeds/CribSelected","Feeds/Speeds/CribSelected");
         }
         GWizSettings.cribSelection = this.cribTbl.selectedIndex;
         this.stopRecalc = false;
      }
      
      public function onCribTblVC() : void
      {
         this.stopRecalc = true;
         if(!this.cribTbl.selectedItem)
         {
            this.cribTbl.selectedIndex = 0;
         }
         if(this.cribTbl.selectedItem == undefined)
         {
            return;
         }
         if(this.cribTbl.selectedItem.tabname == GWizCribList.NO_CRIB && this.Tool.isCribDataProvider() && this.td)
         {
            this.setToolDataProvider();
         }
         this.setFunctions();
         this.Tool.syncPopUp();
         this.callLater(this.justASecRecalc);
      }
      
      private function justASecRecalc() : void
      {
         this.stopRecalc = false;
         this.recalc();
      }
      
      private function setToolDataProvider() : void
      {
         this.Tool.dataProvider = this.getToolDataProvider();
         this.Tool.selectedIndex = this.Tool.selectedIndex;
         this.Tool.labelField = "description";
      }
      
      private function checkRedlineLabOvr(param1:GWizLabText, param2:GWizNumStepOvr, param3:Boolean = false) : void
      {
         if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
         {
            if(Math.abs(param1.getVal() - param2.getVal()) < 0.05 || param3)
            {
               param1.setStyle("color",ALERT_TEXT_COLOR);
               param2.stepper.setStyle("color",ALERT_TEXT_COLOR);
               GWizSettings.showAdvanced = true;
               this.doAdvanced();
            }
            else
            {
               param1.setStyle("color",GWizStylePalette.textColor);
               param2.stepper.setStyle("color","#010101");
            }
         }
      }
      
      private function checkRedlineOvrOvr(param1:GWizNumStepOvr, param2:Number, param3:String = "", param4:Boolean = true) : void
      {
         if(GWizUtils.debug)
         {
            GWizUtils.assert(param3 != "" || this.FEEDRATE_MAXED_OUT);
         }
         var _loc5_:Number;
         if((_loc5_ = Math.abs(param1.getVal() - param2)) < 0.005 * param2 || param4 && param1.getVal() > param2 || !param4 && param1.getVal() < param2)
         {
            if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
            {
               param1.stepper.setAlertTextColor(true);
               GWizSettings.showAdvanced = true;
               this.doAdvanced();
            }
            if(param3 != "")
            {
               if(param1.getVal() != 0)
               {
                  this.errHint = param3;
               }
               this.cuttingError = param3;
            }
         }
         else if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
         {
            param1.stepper.setAlertTextColor(false);
         }
      }
      
      private function toolCribVerify() : void
      {
         if(!GWizToolCribData.isCrib(this.cribTbl.selectedItem))
         {
            this.cribTbl.selectedIndex = 0;
         }
         this.doCribTbl();
      }
      
      private function doAdvanced() : void
      {
      }
      
      private function checkIntegrity(param1:String) : void
      {
      }
      
      private function showHSM(param1:Boolean) : void
      {
         GWizUtils.LogErrorContext = "GWizFeedsSpeeds2.showHSM";
         this.showHSMFeedsSpeeds.visible = param1;
         this.hsmEligible = param1;
      }
      
      public function setTEA(param1:Number, param2:Number) : void
      {
         this.cutWidth.setVal(param2);
         this.recalc();
      }
      
      public function slot() : void
      {
         this.cutWidth.setVal(this.td.toolParms.toolDiam);
      }
      
      public function saveHistory(param1:String, param2:String, param3:String, param4:GWizToolDef, param5:Number, param6:Number, param7:String, param8:Number, param9:Number) : void
      {
      }
      
      private function doFilterCutKB() : void
      {
         GATracker.logPageView("Feeds/Speeds/SearchKB","Feeds/Speeds/SearchKB");
         var _loc1_:GWizCutKB = this.setCutKB();
         GWizCutKBSQL.activeRec = _loc1_;
         var _loc2_:GWizCutKBSearch = GWizCutKBSearch(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizCutKBSearch,true));
      }
      
      private function setCutKB() : GWizCutKB
      {
         this.recalcAuxForCutKB();
         var _loc1_:GWizCutKB = new GWizCutKB();
         _loc1_.mrr = this.MRR.getVal();
         _loc1_.mrrPct = this.mrrPct;
         _loc1_.rpm = this.RPM.getVal();
         _loc1_.rpmPct = this.rpmPct;
         _loc1_.ipm = this.IPM.getVal();
         _loc1_.ipmPct = this.ipmPct;
         _loc1_.sfm = this.SFM.getVal();
         _loc1_.sfmPct = this.sfmPct;
         _loc1_.ipt = this.IPT.getVal();
         _loc1_.iptPct = this.iptPct;
         _loc1_.machine = GWizMachSettings.currMachine;
         _loc1_.tool = this.Tool.selectedLabel;
         _loc1_.crib = this.cribTbl.selectedItem.tabname;
         _loc1_.toolDia = this.td.toolParms.toolDiam;
         _loc1_.flutes = this.td.toolParms.flutes;
         _loc1_.geometry = this.td.geometryLabel();
         _loc1_.leadAng = this.td.toolParms.leadAngle;
         _loc1_.stickout = this.td.toolParms.stickout;
         _loc1_.noseRad = this.td.toolParms.noseRad;
         _loc1_.cutDepth = this.cutDepth.getVal();
         _loc1_.cutWidth = this.cutWidth.getVal();
         _loc1_.material = this.mms.MatChooser.MaterialSelectedIndex;
         var _loc2_:Number = 0;
         if(GWizSettings.materialHardness != -1)
         {
            _loc2_ = GWizSettings.materialHardness;
         }
         else if(this.fsm.minBHN > 0)
         {
            _loc2_ = (this.fsm.minBHN + this.fsm.maxBHN) / 2;
         }
         _loc1_.hardness = _loc2_;
         return _loc1_;
      }
      
      private function doAddCutKB() : void
      {
         var _loc2_:GWizCutKB = null;
         GATracker.logPageView("Feeds/Speeds/AddCutKB","Feeds/Speeds/AddCutKB");
         var _loc1_:GWizCutKBEditAR = GWizCutKBEditAR(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizCutKBEditAR,true));
         if(_loc1_)
         {
            _loc2_ = this.setCutKB();
            _loc1_.inputsReady(_loc2_,this.MRR.labTxt + ": ","RPM: ",this.IPM.titleTxt + ": ",this.SFM.titleTxt + ": ",this.IPT.titleTxt + ": ",this.currMaterial());
         }
      }
      
      public function grabCutKBActiveRec() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         GWizMachSettings.currMachine = GWizCutKBSQL.activeRec.machine;
         if(GWizMachSettings.currMachine != GWizCutKBSQL.activeRec.machine)
         {
            GWizPopUpManager.Show("Machine \'" + GWizCutKBSQL.activeRec.machine + "\' does not exist.","Error: Missing Machine",GWizPopUpManager.ERROR);
         }
         this.mms.MatChooser.MaterialSelectedIndex = GWizCutKBSQL.activeRec.material;
         this.fsm.minBHN = GWizCutKBSQL.activeRec.hardness;
         _loc1_ = 0;
         while(_loc1_ < GWizCribList.cribListPlus.length)
         {
            _loc2_ = GWizCribList.cribListPlus.getItemAt(_loc1_);
            if(_loc2_.tabname == GWizCutKBSQL.activeRec.crib)
            {
               this.cribTbl.selectedIndex = _loc1_;
               break;
            }
            _loc1_++;
         }
         if(this.cribTbl.selectedItem.tabname != GWizCutKBSQL.activeRec.crib)
         {
            GWizPopUpManager.Show("Tool Crib \'" + GWizCutKBSQL.activeRec.crib + "\' does not exist.","Error: Missing Tool Crib",GWizPopUpManager.ERROR);
         }
         this.Tool.selectedLabel = GWizCutKBSQL.activeRec.tool;
         if(this.Tool.selectedLabel != GWizCutKBSQL.activeRec.tool)
         {
            GWizPopUpManager.Show("Tool \'" + GWizCutKBSQL.activeRec.tool + "\' does not exist.","Error: Missing Tool",GWizPopUpManager.ERROR);
         }
         this.td._toolDiameter.setVal(GWizCutKBSQL.activeRec.toolDia);
         this.td._flutes.value = GWizCutKBSQL.activeRec.flutes;
         this.td.setGeometry(GWizCutKBSQL.activeRec.geometry);
         this.td._LeadAngle.value = GWizCutKBSQL.activeRec.leadAng;
         this.td._stickout.setVal(GWizCutKBSQL.activeRec.stickout);
         this.td.toolParms.noseRad = GWizCutKBSQL.activeRec.noseRad;
         this.cutDepth.setVal(GWizCutKBSQL.activeRec.cutDepth);
         this.cutWidth.setVal(GWizCutKBSQL.activeRec.cutWidth);
         this.RPM.setVal(GWizCutKBSQL.activeRec.rpm);
         this.IPM.setVal(GWizCutKBSQL.activeRec.ipm);
         this.SFM.setVal(GWizCutKBSQL.activeRec.sfm);
         this.IPT.setVal(GWizCutKBSQL.activeRec.ipt);
      }
      
      private function toolDefDesc() : String
      {
         return GWizToolDef.toolDefDescArgs(this.td.toolParms.toolDiam,this.td.toolParms.flutes,this.td.toolParms.leadAngle,this.td.geometryLabel(),this.Tool.selectedLabel,this.td.toolParms.stickout,this.td.toolParms.noseRad);
      }
      
      private function doExport() : void
      {
         var stream:FileStream = null;
         var outputString:String = "";
         switch(exportBtnDataFormat)
         {
            case GWizClipUtils.XML_FORMAT:
               outputString = this.feedsToXMLStr();
               break;
            case GWizClipUtils.JSON_FORMAT:
               outputString = this.feedsToJSONStr();
               break;
            case GWizClipUtils.CSV_FORMAT:
               outputString = this.feedsToCSVStr(",");
               break;
            case GWizClipUtils.TSV_FORMAT:
               outputString = this.feedsToCSVStr("\t");
               break;
            default:
               GWizUtils.assert(false);
         }
         if(exportBtnFileMode)
         {
            try
            {
               this.fsFile = GWizSettings.getPrefsFile("LastFeedSpeed.xml");
               stream = new FileStream();
               stream.open(this.fsFile,FileMode.WRITE);
               stream.writeUTFBytes(outputString);
               stream.close();
            }
            catch(e:Error)
            {
               GWizUtils.LogError("Error doing Feed Speed export for integration.");
               GWizPopUpManager.Show("Error writing export file.","Error: Write Failure",GWizPopUpManager.ERROR);
            }
         }
         else
         {
            GWizClipUtils.loadClipboard(exportBtnDataFormat,outputString);
         }
      }
      
      private function feedsToXMLStr() : String
      {
         var _loc1_:XML = null;
         _loc1_ = <feedsspeeds/>;
         _loc1_.apiVersion = "GWizard FeedsSpeedsExport 1.1";
         _loc1_.units = GWizUtils.Units;
         _loc1_.rpm = this.RPM.getValCurrUnits();
         _loc1_.ipm = this.IPM.getValCurrUnits();
         _loc1_.toolDia = this.td._toolDiameter.getValCurrUnits();
         _loc1_.cutWidth = this.cutWidth.getValCurrUnits();
         _loc1_.cutDepth = this.cutDepth.getValCurrUnits();
         _loc1_.plunge = this.PlungeRate.getValCurrUnits();
         var _loc2_:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
         _loc2_ += _loc1_.toXMLString();
         return _loc2_.replace(/\n/g,File.lineEnding);
      }
      
      private function feedsToObject() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.apiVersion = "GWizard FeedsSpeedsExport 1.1";
         _loc1_.units = GWizUtils.Units;
         _loc1_.rpm = this.RPM.getValCurrUnits();
         _loc1_.ipm = this.IPM.getValCurrUnits();
         _loc1_.toolDia = this.td._toolDiameter.getValCurrUnits();
         _loc1_.cutWidth = this.cutWidth.getValCurrUnits();
         _loc1_.cutDepth = this.cutDepth.getValCurrUnits();
         _loc1_.plunge = this.PlungeRate.getValCurrUnits();
         _loc1_.ballnose = this.td.toolParms.isBallnoseDB();
         _loc1_.vbit = this.td.toolParms.getVBitAngle();
         _loc1_.downcut = this.td.toolParms.isDowncut();
         _loc1_.compression = this.td.toolParms.isCompression();
         _loc1_.straightFlute = this.td.toolParms.isStraightFlute();
         _loc1_.dovetail = this.td.toolParms.getDovetailAngle();
         return _loc1_;
      }
      
      private function feedsToJSONStr() : String
      {
         var _loc1_:Object = this.feedsToObject();
         return JSON.stringify(_loc1_);
      }
      
      private function feedsToCSVStr(param1:String) : String
      {
         var _loc2_:ArrayCollection = new ArrayCollection();
         var _loc3_:Object = this.feedsToObject();
         _loc2_.addItem(_loc3_);
         return GWizCSVUtils.arrayColToCSV(_loc2_,param1,null);
      }
      
      private function set cribGeneration(param1:int) : void
      {
         this.cribTbl.dataProvider = GWizCribList.cribListPlus;
      }
      
      public function deflectErr(param1:Boolean) : Boolean
      {
         var _loc2_:Number = GWizDeflectMath.defaultDefAllowance(this.td.toolParms.toolDiam,param1);
         this.defPct = 100 * (this.Deflect.getVal() / _loc2_);
         this.deflectTempSlider.value = this.defPct;
         return this.Deflect.visible && this.Deflect.getVal() > _loc2_;
      }
      
      public function onResize(param1:Event = null) : void
      {
      }
      
      private function handleResize() : void
      {
         if(GWizUtils.debug)
         {
            log.debug("handleResize()");
         }
         if(this.width < (GWizSettings.fontManager.fontSize <= 12 ? 875 : 900))
         {
            this.mmsDefault.hideLabel = true;
            this.td.hideLabel = true;
            this.calcPanel.hideLabel = true;
            this.cutPanel.hideLabel = true;
            this.feedsPanel.hideLabel = true;
            this.tipsTitlePanel.hideLabel = true;
            this.cutkbPanel.hideLabel = true;
         }
         else
         {
            this.mmsDefault.hideLabel = false;
            this.td.hideLabel = false;
            this.calcPanel.hideLabel = false;
            this.cutPanel.hideLabel = false;
            this.feedsPanel.hideLabel = false;
            this.tipsTitlePanel.hideLabel = false;
            this.cutkbPanel.hideLabel = false;
         }
         if(this.height < 740)
         {
            this.gapSizes = 5;
         }
         else
         {
            this.gapSizes = 10;
         }
         this.callLater(this.resizeDone);
      }
      
      private function resizeDone() : void
      {
         this.resizeExecuting = false;
      }
      
      private function clearTips() : void
      {
         if(!GWizAbstractPrefs.isOEM)
         {
            this.tipList.removeAll();
            this.hint.text = "0 Tips: ";
            this.warnOn = false;
            this.hint.setStyle("color",GWizStylePalette.textColor);
         }
      }
      
      public function addTip(param1:String, param2:Boolean = false, param3:Boolean = false) : void
      {
         var _loc4_:Object = null;
         if(!GWizAbstractPrefs.isOEM || param3)
         {
            (_loc4_ = new Object()).label = param1;
            this.tipList.addItem(_loc4_);
            this.warnOn = this.warnOn || param2;
            if(!GWizCadCam.recalcEngine || !GWizCadCam.recalcEngine.gaRunning)
            {
               if(this.warnOn)
               {
                  this.hint.setStyle("color",ALERT_TEXT_COLOR);
               }
               else
               {
                  this.hint.setStyle("color",GWizStylePalette.textColor);
               }
            }
            this.hint.text = this.tipList.length + " Tips: ";
            this.hintDropdown.selectedIndex = 0;
         }
      }
      
      private function toolVCHandler() : void
      {
         if(this.mfgSpecs)
         {
            this.mfgSpecs.clearLocks();
         }
         this.setFunctions();
         this.resetNonLimits();
      }
      
      private function toolPopupSetFunctions(param1:GWizToolData) : void
      {
         this.td.toolParms = param1;
         this.Tool.selectedLabel = param1.toolType;
         this.toolVCHandler();
         ++this.toolMenuSaves;
         this.callLater(this.tryToolCribTip);
      }
      
      private function getPlungeRate() : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Object = null;
         var _loc5_:Number = NaN;
         var _loc1_:Number = this.fsm.plungeRate;
         var _loc2_:String = "Plunge";
         if(this.plungeModeX.selectedIndex >= 0)
         {
            _loc2_ = this.plungeModeX.selectedItem.label;
         }
         switch(_loc2_)
         {
            case "Helix":
               _loc3_ = GWizMachSettings.lookupMachine(GWizMachSettings.currMachine).accel;
               if(!_loc3_)
               {
                  _loc3_ = 0.1;
               }
               _loc1_ = (_loc4_ = GWizInterpMC.helixFeedrate(this.td.toolParms.toolDiam * 1.5,this.td.toolParms.toolDiam,this.td.toolParms.flutes,this.IPM.getVal(),_loc3_,this.cutDepth.getVal(),true,true,true,false)).feedAccel;
               break;
            case "Ramp":
               _loc1_ = _loc5_ = GWizRampMC.rampFeedrate(this.cutDepth.getVal(),this.td.toolParms.toolDiam * 1.5 * Math.PI,this.IPM.getVal(),this.td.toolParms.flutes);
               break;
            case "Plunge":
         }
         return Number(Math.min(this.IPM.getVal(),_loc1_));
      }
      
      protected function onTipsClick(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
      }
      
      private function tryToolCribTip() : void
      {
         if(GWizSettings.loginBar.trialDaysLeft() > 0)
         {
            if(GWizSettings.cribToolsCreated <= 0)
            {
               ++GWizSettings.cribToolsCreated;
               GATracker.logPageView("FeedsSpeeds/OfferCribTip","FeedsSpeeds/OfferCribTip");
               GWizPopUpManager.Show("Will you ever use that tool again? Can I show you an easy way to add it to your Tool Crib and save time?","Tool Crib Tip",GWizPopUpManager.YES | GWizPopUpManager.NO,null,this.yesOnCribTip);
            }
         }
      }
      
      private function yesOnCribTip(param1:Event) : void
      {
         GATracker.logPageView("FeedsSpeeds/CribTipYes","FeedsSpeeds/CribTipYes");
         GWizUtils.doWebPage("https://www.cnccookbook.com/quick-start-using-g-wizards-tool-crib/");
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         if(GWizSettings.prefs.powerUser != this.powerUserState)
         {
            if(GWizSettings.prefs.powerUser)
            {
               this.addElementAt(this.calcPanel,7);
               this.addElementAt(this.cutkbPanel,8);
               GWizUtils.setElementVisible(Group(this.HSMPanel.getElementAt(0)),true);
               GWizOptimizeBtn.showOptimizeButtons = true;
            }
            else
            {
               this.removeElement(this.calcPanel);
               this.removeElement(this.cutkbPanel);
               if(GWizAbstractPrefs.isOEM)
               {
                  GWizUtils.setElementVisible(Group(this.coolantOptions),false);
               }
               else
               {
                  GWizUtils.setElementVisible(Group(this.HSMPanel.getElementAt(0)),false);
               }
               GWizOptimizeBtn.showOptimizeButtons = false;
            }
            this.powerUserState = GWizSettings.prefs.powerUser;
         }
         return true;
      }
      
      private function formatHPLabel(param1:Number, param2:Number) : String
      {
         return "";
      }
      
      private function pageView(param1:String) : void
      {
         GATracker.logPageView("MiniCalc/" + param1,"MiniCalc: " + param1);
      }
      
      private function setHSMGasPedal() : void
      {
         this.recalc();
      }
      
      private function onCribTableChange() : void
      {
         this.gotTool = true;
         this.doCribTbl();
      }
      
      private function _GWizFeedsSpeeds2_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.gap = 1;
         _loc1_.verticalAlign = "baseline";
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_GWizFSMachineMaterialSelector1_i(),this._GWizFeedsSpeeds2_GWizForePanel1_i()];
         _loc1_.id = "machPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machPanel = _loc1_;
         BindingManager.executeBindings(this,"machPanel",this.machPanel);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizFSMachineMaterialSelector1_i() : GWizFSMachineMaterialSelector
      {
         var _loc1_:GWizFSMachineMaterialSelector = new GWizFSMachineMaterialSelector();
         _loc1_.title = "Machine";
         _loc1_.onChangeFcn = this.onMatChange;
         _loc1_.theOwner = "GWizFeedsSpeeds2";
         _loc1_.id = "mmsDefault";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mmsDefault = _loc1_;
         BindingManager.executeBindings(this,"mmsDefault",this.mmsDefault);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array3_c);
         _loc1_.id = "ToolFP";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolFP = _loc1_;
         BindingManager.executeBindings(this,"ToolFP",this.ToolFP);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array3_c() : Array
      {
         return [this._GWizFeedsSpeeds2_VGroup2_i()];
      }
      
      private function _GWizFeedsSpeeds2_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_HGroup2_c(),this._GWizFeedsSpeeds2_HGroup3_c()];
         _loc1_.id = "ToolGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolGrp = _loc1_;
         BindingManager.executeBindings(this,"ToolGrp",this.ToolGrp);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_Label1_i(),this._GWizFeedsSpeeds2_GWizToolMenu1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tool";
         _loc1_.id = "_GWizFeedsSpeeds2_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFeedsSpeeds2_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFeedsSpeeds2_Label1",this._GWizFeedsSpeeds2_Label1);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizToolMenu1_i() : GWizToolMenu
      {
         var _loc1_:GWizToolMenu = new GWizToolMenu();
         _loc1_.toolTip = "Select which cutter \ror operation you\'re running";
         _loc1_.percentWidth = 100;
         _loc1_.inFeedsSpeedsApp = true;
         _loc1_.addEventListener("valueCommit",this.__Tool_valueCommit);
         _loc1_.id = "Tool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Tool = _loc1_;
         BindingManager.executeBindings(this,"Tool",this.Tool);
         return _loc1_;
      }
      
      public function __Tool_valueCommit(param1:FlexEvent) : void
      {
         this.toolVCHandler();
      }
      
      private function _GWizFeedsSpeeds2_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_Label2_i(),this._GWizFeedsSpeeds2_GWizGWCToolCribSelector1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Crib";
         _loc1_.id = "_GWizFeedsSpeeds2_Label2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFeedsSpeeds2_Label2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFeedsSpeeds2_Label2",this._GWizFeedsSpeeds2_Label2);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizGWCToolCribSelector1_i() : GWizGWCToolCribSelector
      {
         var _loc1_:GWizGWCToolCribSelector = new GWizGWCToolCribSelector();
         _loc1_.changeFcn = this.onCribTableChange;
         _loc1_.valueCommitFcn = this.onCribTblVC;
         _loc1_.toolTip = "Select which tool crib to use for your tool list.";
         _loc1_.id = "cribTbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cribTbl = _loc1_;
         BindingManager.executeBindings(this,"cribTbl",this.cribTbl);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizToolDef1_i() : GWizToolDef
      {
         var _loc1_:GWizToolDef = new GWizToolDef();
         _loc1_.percentWidth = 100;
         _loc1_.id = "td";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.td = _loc1_;
         BindingManager.executeBindings(this,"td",this.td);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizMfgCutterSpecs1_i() : GWizMfgCutterSpecs
      {
         var _loc1_:GWizMfgCutterSpecs = new GWizMfgCutterSpecs();
         _loc1_.percentWidth = 100;
         _loc1_.id = "mfgSpecs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mfgSpecs = _loc1_;
         BindingManager.executeBindings(this,"mfgSpecs",this.mfgSpecs);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_HGroup4_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.gap = 1;
         _loc1_.verticalAlign = "baseline";
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_GWizForePanel2_i(),this._GWizFeedsSpeeds2_GWizForePanel3_i(),this._GWizFeedsSpeeds2_GWizForePanel4_i()];
         _loc1_.id = "cutGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutGrp = _loc1_;
         BindingManager.executeBindings(this,"cutGrp",this.cutGrp);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Cut";
         _loc1_.layout = this._GWizFeedsSpeeds2_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array8_c);
         _loc1_.id = "cutPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutPanel = _loc1_;
         BindingManager.executeBindings(this,"cutPanel",this.cutPanel);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "left";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array8_c() : Array
      {
         return [this._GWizFeedsSpeeds2_HGroup5_c(),this._GWizFeedsSpeeds2_Label4_i()];
      }
      
      private function _GWizFeedsSpeeds2_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_Label3_i(),this._GWizFeedsSpeeds2_GWizNumStep1_i(),this._GWizFeedsSpeeds2_GWizOptimizeBtn1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cut Depth";
         _loc1_.addEventListener("click",this.__cutDepthLabel_click);
         _loc1_.id = "cutDepthLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutDepthLabel = _loc1_;
         BindingManager.executeBindings(this,"cutDepthLabel",this.cutDepthLabel);
         return _loc1_;
      }
      
      public function __cutDepthLabel_click(param1:MouseEvent) : void
      {
         this.optDepth.optimize();
      }
      
      private function _GWizFeedsSpeeds2_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 60000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Depth of cut (ap)";
         _loc1_.fatSpacer = false;
         _loc1_.UnitLabel = "in";
         _loc1_.redZone = true;
         _loc1_.redMax = 0.0001;
         _loc1_.addEventListener("valueCommit",this.__cutDepth_valueCommit);
         _loc1_.id = "cutDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutDepth = _loc1_;
         BindingManager.executeBindings(this,"cutDepth",this.cutDepth);
         return _loc1_;
      }
      
      public function __cutDepth_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizFeedsSpeeds2_GWizOptimizeBtn1_i() : GWizOptimizeBtn
      {
         var _loc1_:GWizOptimizeBtn = new GWizOptimizeBtn();
         _loc1_.mode = "depth";
         _loc1_.logContext = "Feeds/Speeds/OptimizeDepth";
         _loc1_.toolTip = "Optimize Depth while leaving Wdith alone";
         _loc1_.id = "optDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.optDepth = _loc1_;
         BindingManager.executeBindings(this,"optDepth",this.optDepth);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Axial: 999.9%";
         _loc1_.percentWidth = 50;
         _loc1_.id = "AxialEngagement";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AxialEngagement = _loc1_;
         BindingManager.executeBindings(this,"AxialEngagement",this.AxialEngagement);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.layout = this._GWizFeedsSpeeds2_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array10_c);
         _loc1_.id = "_GWizFeedsSpeeds2_GWizForePanel3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFeedsSpeeds2_GWizForePanel3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFeedsSpeeds2_GWizForePanel3",this._GWizFeedsSpeeds2_GWizForePanel3);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_VerticalLayout2_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "left";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array10_c() : Array
      {
         return [this._GWizFeedsSpeeds2_HGroup6_c(),this._GWizFeedsSpeeds2_Label6_i()];
      }
      
      private function _GWizFeedsSpeeds2_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_Label5_i(),this._GWizFeedsSpeeds2_GWizNumStep2_i(),this._GWizFeedsSpeeds2_GWizOptimizeBtn2_i(),this._GWizFeedsSpeeds2_Button1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cut Width";
         _loc1_.addEventListener("click",this.__cutWidthLabel_click);
         _loc1_.id = "cutWidthLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutWidthLabel = _loc1_;
         BindingManager.executeBindings(this,"cutWidthLabel",this.cutWidthLabel);
         return _loc1_;
      }
      
      public function __cutWidthLabel_click(param1:MouseEvent) : void
      {
         this.optWidth.optimize();
      }
      
      private function _GWizFeedsSpeeds2_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 400;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Width of cut (ae) or Stepover";
         _loc1_.fatSpacer = false;
         _loc1_.UnitLabel = "in";
         _loc1_.redZone = true;
         _loc1_.redMax = 0.0001;
         _loc1_.addEventListener("valueCommit",this.__cutWidth_valueCommit);
         _loc1_.id = "cutWidth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutWidth = _loc1_;
         BindingManager.executeBindings(this,"cutWidth",this.cutWidth);
         return _loc1_;
      }
      
      public function __cutWidth_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizFeedsSpeeds2_GWizOptimizeBtn2_i() : GWizOptimizeBtn
      {
         var _loc1_:GWizOptimizeBtn = new GWizOptimizeBtn();
         _loc1_.mode = "width";
         _loc1_.logContext = "Feeds/Speeds/OptimizeWidth";
         _loc1_.toolTip = "Optimize Width while leaving Depth alone";
         _loc1_.id = "optWidth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.optWidth = _loc1_;
         BindingManager.executeBindings(this,"optWidth",this.optWidth);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.width = 60;
         _loc1_.label = "Slot";
         _loc1_.toolTip = "Set Width for Full Width Slot";
         _loc1_.addEventListener("click",this.__SlotBtn_click);
         _loc1_.id = "SlotBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SlotBtn = _loc1_;
         BindingManager.executeBindings(this,"SlotBtn",this.SlotBtn);
         return _loc1_;
      }
      
      public function __SlotBtn_click(param1:MouseEvent) : void
      {
         this.slot();
      }
      
      private function _GWizFeedsSpeeds2_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Radial: 999.9%";
         _loc1_.percentWidth = 50;
         _loc1_.id = "RadialEngagement";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RadialEngagement = _loc1_;
         BindingManager.executeBindings(this,"RadialEngagement",this.RadialEngagement);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel4_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array12_c);
         _loc1_.id = "HSMPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HSMPanel = _loc1_;
         BindingManager.executeBindings(this,"HSMPanel",this.HSMPanel);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array12_c() : Array
      {
         return [this._GWizFeedsSpeeds2_VGroup3_i()];
      }
      
      private function _GWizFeedsSpeeds2_VGroup3_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_CheckBox1_i(),this._GWizFeedsSpeeds2_HGroup7_i()];
         _loc1_.id = "HSM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HSM = _loc1_;
         BindingManager.executeBindings(this,"HSM",this.HSM);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Use HSM";
         _loc1_.toolTip = "Adjust feeds and speeds for constant TEA (HSM, Trochoidal, Adaptive Clearing, etc.) toolpaths.";
         _loc1_.addEventListener("change",this.__showHSMFeedsSpeeds_change);
         _loc1_.id = "showHSMFeedsSpeeds";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.showHSMFeedsSpeeds = _loc1_;
         BindingManager.executeBindings(this,"showHSMFeedsSpeeds",this.showHSMFeedsSpeeds);
         return _loc1_;
      }
      
      public function __showHSMFeedsSpeeds_change(param1:Event) : void
      {
         this.setHSMGasPedal();
      }
      
      private function _GWizFeedsSpeeds2_HGroup7_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.horizontalAlign = "left";
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_Label7_c(),this._GWizFeedsSpeeds2_CheckBox2_i(),this._GWizFeedsSpeeds2_CheckBox3_i()];
         _loc1_.id = "coolantOptions";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.coolantOptions = _loc1_;
         BindingManager.executeBindings(this,"coolantOptions",this.coolantOptions);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Coolant:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "TSC";
         _loc1_.toolTip = "Through Spindle Coolant";
         _loc1_.addEventListener("change",this.__TSC_change);
         _loc1_.id = "TSC";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TSC = _loc1_;
         BindingManager.executeBindings(this,"TSC",this.TSC);
         return _loc1_;
      }
      
      public function __TSC_change(param1:Event) : void
      {
         GWizSettings.FeedsSpeedsApp.recalc();
         this.pageView("TSC");
      }
      
      private function _GWizFeedsSpeeds2_CheckBox3_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "PCN";
         _loc1_.toolTip = "Programmable Coolant Nozzle";
         _loc1_.addEventListener("change",this.__PCN_change);
         _loc1_.id = "PCN";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PCN = _loc1_;
         BindingManager.executeBindings(this,"PCN",this.PCN);
         return _loc1_;
      }
      
      public function __PCN_change(param1:Event) : void
      {
         GWizSettings.FeedsSpeedsApp.recalc();
         this.pageView("PCN");
      }
      
      private function _GWizFeedsSpeeds2_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.gap = 1;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_GWizForePanel5_i(),this._GWizFeedsSpeeds2_GWizForePanel6_i(),this._GWizFeedsSpeeds2_GWizForePanel7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel5_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 33;
         _loc1_.title = "Results";
         _loc1_.layout = this._GWizFeedsSpeeds2_VerticalLayout3_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array16_c);
         _loc1_.id = "feedsPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.feedsPanel = _loc1_;
         BindingManager.executeBindings(this,"feedsPanel",this.feedsPanel);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_VerticalLayout3_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "left";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array16_c() : Array
      {
         return [this._GWizFeedsSpeeds2_GWizNumStepOvr1_i(),this._GWizFeedsSpeeds2_GWizTempSlider1_i()];
      }
      
      private function _GWizFeedsSpeeds2_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "RPM";
         _loc1_.min = 0;
         _loc1_.steps = 1;
         _loc1_.stepByPercent = true;
         _loc1_.usesMetric = false;
         _loc1_.titleClickCopy = true;
         _loc1_.toolTip = "Spindle RPM. Click title to copy to clipboard.";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.fatSpacer = false;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("change",this.__RPM_change);
         _loc1_.id = "RPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RPM = _loc1_;
         BindingManager.executeBindings(this,"RPM",this.RPM);
         return _loc1_;
      }
      
      public function __RPM_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizFeedsSpeeds2_GWizTempSlider1_i() : GWizTempSlider
      {
         var _loc1_:GWizTempSlider = new GWizTempSlider();
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("change",this.__rpmTempSlider_change);
         _loc1_.id = "rpmTempSlider";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rpmTempSlider = _loc1_;
         BindingManager.executeBindings(this,"rpmTempSlider",this.rpmTempSlider);
         return _loc1_;
      }
      
      public function __rpmTempSlider_change(param1:Event) : void
      {
         this.rpmTempSlider.value = this.RPM.getVal();
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel6_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 34;
         _loc1_.layout = this._GWizFeedsSpeeds2_VerticalLayout4_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array17_c);
         _loc1_.id = "secondCol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.secondCol = _loc1_;
         BindingManager.executeBindings(this,"secondCol",this.secondCol);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_VerticalLayout4_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "left";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array17_c() : Array
      {
         return [this._GWizFeedsSpeeds2_HGroup9_c(),this._GWizFeedsSpeeds2_GWizTempSlider2_i()];
      }
      
      private function _GWizFeedsSpeeds2_HGroup9_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "left";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_GWizNumStepOvr2_i(),this._GWizFeedsSpeeds2_GWizLabText1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Feedrate";
         _loc1_.min = 0;
         _loc1_.steps = 0.001;
         _loc1_.stepByPercent = true;
         _loc1_.titleClickCopy = true;
         _loc1_.UnitLabel = "ipm";
         _loc1_.toolTip = "Feedrate in inches \ror mm per minute. Click title to copy to clipboard.";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.fatSpacer = false;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("change",this.__IPM_change);
         _loc1_.id = "IPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.IPM = _loc1_;
         BindingManager.executeBindings(this,"IPM",this.IPM);
         return _loc1_;
      }
      
      public function __IPM_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizFeedsSpeeds2_GWizLabText1_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labTxt = "IPR";
         _loc1_.toolTip = "Chipload per rotation, all teeth. On lathes, feedrate per revolution.";
         _loc1_.UnitLabel = "in";
         _loc1_.id = "IPR";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.IPR = _loc1_;
         BindingManager.executeBindings(this,"IPR",this.IPR);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizTempSlider2_i() : GWizTempSlider
      {
         var _loc1_:GWizTempSlider = new GWizTempSlider();
         _loc1_.minimum = 0;
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("change",this.__feedTempSlider_change);
         _loc1_.id = "feedTempSlider";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.feedTempSlider = _loc1_;
         BindingManager.executeBindings(this,"feedTempSlider",this.feedTempSlider);
         return _loc1_;
      }
      
      public function __feedTempSlider_change(param1:Event) : void
      {
         this.feedTempSlider.value = this.IPM.getVal();
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel7_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 33;
         _loc1_.layout = this._GWizFeedsSpeeds2_HorizontalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array19_c);
         _loc1_.id = "thirdCol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.thirdCol = _loc1_;
         BindingManager.executeBindings(this,"thirdCol",this.thirdCol);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_HorizontalLayout1_c() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = new HorizontalLayout();
         _loc1_.horizontalAlign = "left";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array19_c() : Array
      {
         return [this._GWizFeedsSpeeds2_Label8_i(),this._GWizFeedsSpeeds2_DropDownList1_i(),this._GWizFeedsSpeeds2_GWizLabText2_i()];
      }
      
      private function _GWizFeedsSpeeds2_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Entry:";
         _loc1_.toolTip = "Method of entry to cut.";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizFeedsSpeeds2_Label8";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFeedsSpeeds2_Label8 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFeedsSpeeds2_Label8",this._GWizFeedsSpeeds2_Label8);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "label";
         _loc1_.selectedIndex = 0;
         _loc1_.toolTip = "Method of entry to cut.";
         _loc1_.addEventListener("change",this.__plungeModeX_change);
         _loc1_.id = "plungeModeX";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.plungeModeX = _loc1_;
         BindingManager.executeBindings(this,"plungeModeX",this.plungeModeX);
         return _loc1_;
      }
      
      public function __plungeModeX_change(param1:IndexChangeEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizFeedsSpeeds2_GWizLabText2_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labWidth = 0;
         _loc1_.toolTip = "Feedrate for entry rate";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.UnitLabel = "ipm";
         _loc1_.id = "PlungeRate";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PlungeRate = _loc1_;
         BindingManager.executeBindings(this,"PlungeRate",this.PlungeRate);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_HGroup10_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_GWizForePanel8_i(),this._GWizFeedsSpeeds2_GWizForePanel9_c()];
         _loc1_.id = "tipsPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tipsPanel = _loc1_;
         BindingManager.executeBindings(this,"tipsPanel",this.tipsPanel);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel8_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = null;
         _loc1_ = new GWizForePanel();
         _loc1_.title = "Tips";
         _loc1_.percentWidth = 50;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array21_c);
         _loc1_.id = "tipsTitlePanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tipsTitlePanel = _loc1_;
         BindingManager.executeBindings(this,"tipsTitlePanel",this.tipsTitlePanel);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array21_c() : Array
      {
         var _loc1_:Array = null;
         return [this._GWizFeedsSpeeds2_HGroup11_i()];
      }
      
      private function _GWizFeedsSpeeds2_HGroup11_i() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_Label9_i(),this._GWizFeedsSpeeds2_List1_i()];
         _loc1_.id = "TipsHGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TipsHGroup = _loc1_;
         BindingManager.executeBindings(this,"TipsHGroup",this.TipsHGroup);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Label9_i() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "Tips: ";
         _loc1_.percentHeight = 100;
         _loc1_.setStyle("verticalAlign","middle");
         _loc1_.id = "hint";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.hint = _loc1_;
         BindingManager.executeBindings(this,"hint",this.hint);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_List1_i() : List
      {
         var _loc1_:List = null;
         _loc1_ = new List();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.__hintDropdown_click);
         _loc1_.id = "hintDropdown";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.hintDropdown = _loc1_;
         BindingManager.executeBindings(this,"hintDropdown",this.hintDropdown);
         return _loc1_;
      }
      
      public function __hintDropdown_click(param1:MouseEvent) : void
      {
         this.onTipsClick(param1);
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel9_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = null;
         _loc1_ = new GWizForePanel();
         _loc1_.percentWidth = 50;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizFeedsSpeeds2_VerticalLayout5_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array23_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_VerticalLayout5_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = null;
         _loc1_ = new VerticalLayout();
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array23_c() : Array
      {
         var _loc1_:Array = null;
         return [this._GWizFeedsSpeeds2_GWizTortHare1_i(),this._GWizFeedsSpeeds2_HGroup12_c()];
      }
      
      private function _GWizFeedsSpeeds2_GWizTortHare1_i() : GWizTortHare
      {
         var _loc1_:GWizTortHare = null;
         _loc1_ = new GWizTortHare();
         _loc1_.addEventListener("creationComplete",this.__GasPedal_creationComplete);
         _loc1_.id = "GasPedal";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GasPedal = _loc1_;
         BindingManager.executeBindings(this,"GasPedal",this.GasPedal);
         return _loc1_;
      }
      
      public function __GasPedal_creationComplete(param1:FlexEvent) : void
      {
         this.GasPedal.vcFcn = this.recalc;
         this.GasPedal.changeFcn = this.recalc;
      }
      
      private function _GWizFeedsSpeeds2_HGroup12_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_Button2_i(),this._GWizFeedsSpeeds2_GWizOptimizeBtn3_i(),this._GWizFeedsSpeeds2_Spacer1_c(),this._GWizFeedsSpeeds2_Button3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Button2_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Cheat Sheet";
         _loc1_.toolTip = "Show a popup list of tips to help you get the Feeds and Speeds you want from G-Wizard";
         _loc1_.addEventListener("click",this.___GWizFeedsSpeeds2_Button2_click);
         _loc1_.id = "_GWizFeedsSpeeds2_Button2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFeedsSpeeds2_Button2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFeedsSpeeds2_Button2",this._GWizFeedsSpeeds2_Button2);
         return _loc1_;
      }
      
      public function ___GWizFeedsSpeeds2_Button2_click(param1:MouseEvent) : void
      {
         GWizFSCheatSheet.doCheatSheet();
      }
      
      private function _GWizFeedsSpeeds2_GWizOptimizeBtn3_i() : GWizOptimizeBtn
      {
         var _loc1_:GWizOptimizeBtn = null;
         _loc1_ = new GWizOptimizeBtn();
         _loc1_.mode = "slider";
         _loc1_.logContext = "Feeds/Speeds/OptimizeSlider";
         _loc1_.toolTip = "Optimize Tort/Hare slider to fix deflection errors.";
         _loc1_.id = "optSlider";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.optSlider = _loc1_;
         BindingManager.executeBindings(this,"optSlider",this.optSlider);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Button3_c() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Reset to Defaults";
         _loc1_.height = 24;
         _loc1_.width = 140;
         _loc1_.toolTip = "Reset fields to default values.";
         _loc1_.addEventListener("click",this.___GWizFeedsSpeeds2_Button3_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizFeedsSpeeds2_Button3_click(param1:MouseEvent) : void
      {
         this.resetAll();
      }
      
      private function _GWizFeedsSpeeds2_HGroup13_i() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_GWizForePanel10_i(),this._GWizFeedsSpeeds2_GWizForePanel11_i()];
         _loc1_.id = "advHBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.advHBox = _loc1_;
         BindingManager.executeBindings(this,"advHBox",this.advHBox);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel10_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = null;
         _loc1_ = new GWizForePanel();
         _loc1_.title = "Info";
         _loc1_.percentWidth = 50;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizFeedsSpeeds2_VerticalLayout6_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array26_c);
         _loc1_.id = "_GWizFeedsSpeeds2_GWizForePanel10";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFeedsSpeeds2_GWizForePanel10 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFeedsSpeeds2_GWizForePanel10",this._GWizFeedsSpeeds2_GWizForePanel10);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_VerticalLayout6_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = null;
         return new VerticalLayout();
      }
      
      private function _GWizFeedsSpeeds2_Array26_c() : Array
      {
         var _loc1_:Array = null;
         return [this._GWizFeedsSpeeds2_GWizNumStepOvr3_i(),this._GWizFeedsSpeeds2_GWizNumStepOvr4_i(),this._GWizFeedsSpeeds2_GWizLabText3_i(),this._GWizFeedsSpeeds2_GWizLabText4_i()];
      }
      
      private function _GWizFeedsSpeeds2_GWizNumStepOvr3_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = null;
         _loc1_ = new GWizNumStepOvr();
         _loc1_.titleTxt = "Surface Speed (SFM)";
         _loc1_.percentWidth = 100;
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 1;
         _loc1_.stepByPercent = true;
         _loc1_.UnitLabel = "sfm";
         _loc1_.toolTip = "Surface speed in feet per minute \ror meters per minute for this feed and speed. Orange = custom tool data.";
         _loc1_.addEventListener("change",this.__SFM_change);
         _loc1_.id = "SFM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SFM = _loc1_;
         BindingManager.executeBindings(this,"SFM",this.SFM);
         return _loc1_;
      }
      
      public function __SFM_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizFeedsSpeeds2_GWizNumStepOvr4_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = null;
         _loc1_ = new GWizNumStepOvr();
         _loc1_.titleTxt = "IPT";
         _loc1_.percentWidth = 100;
         _loc1_.min = 0;
         _loc1_.max = 2;
         _loc1_.stepByPercent = true;
         _loc1_.UnitLabel = "ipt";
         _loc1_.toolTip = "Actual chipload at this speed with \rallowance for chip thinning. Orange = custom tool data.";
         _loc1_.addEventListener("change",this.__IPT_change);
         _loc1_.id = "IPT";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.IPT = _loc1_;
         BindingManager.executeBindings(this,"IPT",this.IPT);
         return _loc1_;
      }
      
      public function __IPT_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizFeedsSpeeds2_GWizLabText3_i() : GWizLabText
      {
         var _loc1_:GWizLabText = null;
         _loc1_ = new GWizLabText();
         _loc1_.labTxt = "Adj. Chipload";
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Chipload in inches \ror mm per tooth for this feed and speed.";
         _loc1_.UnitLabel = "ipt";
         _loc1_.id = "AFPT";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AFPT = _loc1_;
         BindingManager.executeBindings(this,"AFPT",this.AFPT);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizLabText4_i() : GWizLabText
      {
         var _loc1_:GWizLabText = null;
         _loc1_ = new GWizLabText();
         _loc1_.labTxt = "Eff. Diam.";
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Effective tool diameter";
         _loc1_.UnitLabel = "in";
         _loc1_.id = "EffDiam";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EffDiam = _loc1_;
         BindingManager.executeBindings(this,"EffDiam",this.EffDiam);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel11_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = null;
         _loc1_ = new GWizForePanel();
         _loc1_.percentWidth = 50;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizFeedsSpeeds2_VerticalLayout7_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array27_c);
         _loc1_.id = "_GWizFeedsSpeeds2_GWizForePanel11";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFeedsSpeeds2_GWizForePanel11 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFeedsSpeeds2_GWizForePanel11",this._GWizFeedsSpeeds2_GWizForePanel11);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_VerticalLayout7_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = null;
         return new VerticalLayout();
      }
      
      private function _GWizFeedsSpeeds2_Array27_c() : Array
      {
         var _loc1_:Array = null;
         return [this._GWizFeedsSpeeds2_HGroup14_c(),this._GWizFeedsSpeeds2_HGroup15_c(),this._GWizFeedsSpeeds2_GWizLabText7_i(),this._GWizFeedsSpeeds2_GWizNumStepOvr5_i()];
      }
      
      private function _GWizFeedsSpeeds2_HGroup14_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_GWizLabText5_i(),this._GWizFeedsSpeeds2_Label10_i(),this._GWizFeedsSpeeds2_Spacer2_c(),this._GWizFeedsSpeeds2_GWizTempSlider3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizLabText5_i() : GWizLabText
      {
         var _loc1_:GWizLabText = null;
         _loc1_ = new GWizLabText();
         _loc1_.labTxt = "Power";
         _loc1_.UnitLabel = "hp";
         _loc1_.fatSpacer = false;
         _loc1_.id = "HP";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HP = _loc1_;
         BindingManager.executeBindings(this,"HP",this.HP);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Label10_i() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.id = "_GWizFeedsSpeeds2_Label10";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFeedsSpeeds2_Label10 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFeedsSpeeds2_Label10",this._GWizFeedsSpeeds2_Label10);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.width = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizTempSlider3_i() : GWizTempSlider
      {
         var _loc1_:GWizTempSlider = null;
         _loc1_ = new GWizTempSlider();
         _loc1_.minimum = 0;
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "% of maximum spindle HP or KW used.";
         _loc1_.addEventListener("change",this.__hpTempSlider_change);
         _loc1_.id = "hpTempSlider";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.hpTempSlider = _loc1_;
         BindingManager.executeBindings(this,"hpTempSlider",this.hpTempSlider);
         return _loc1_;
      }
      
      public function __hpTempSlider_change(param1:Event) : void
      {
         this.hpTempSlider.value = this.HP.value;
      }
      
      private function _GWizFeedsSpeeds2_HGroup15_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizFeedsSpeeds2_GWizLabText6_i(),this._GWizFeedsSpeeds2_Label11_i(),this._GWizFeedsSpeeds2_Spacer3_c(),this._GWizFeedsSpeeds2_GWizTempSlider4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizLabText6_i() : GWizLabText
      {
         var _loc1_:GWizLabText = null;
         _loc1_ = new GWizLabText();
         _loc1_.labTxt = "Deflection";
         _loc1_.decPlaces = 6;
         _loc1_.toolTip = "Tool deflection. Red text is a warning. Deflection limit is lower on finish cuts.";
         _loc1_.UnitLabel = "in";
         _loc1_.fatSpacer = false;
         _loc1_.id = "Deflect";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Deflect = _loc1_;
         BindingManager.executeBindings(this,"Deflect",this.Deflect);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Label11_i() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.id = "_GWizFeedsSpeeds2_Label11";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFeedsSpeeds2_Label11 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFeedsSpeeds2_Label11",this._GWizFeedsSpeeds2_Label11);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.width = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizTempSlider4_i() : GWizTempSlider
      {
         var _loc1_:GWizTempSlider = null;
         _loc1_ = new GWizTempSlider();
         _loc1_.minimum = 0;
         _loc1_.maximum = 100;
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "% of deflection limit used.";
         _loc1_.addEventListener("change",this.__deflectTempSlider_change);
         _loc1_.id = "deflectTempSlider";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.deflectTempSlider = _loc1_;
         BindingManager.executeBindings(this,"deflectTempSlider",this.deflectTempSlider);
         return _loc1_;
      }
      
      public function __deflectTempSlider_change(param1:Event) : void
      {
         this.deflectTempSlider.value = this.defPct;
      }
      
      private function _GWizFeedsSpeeds2_GWizLabText7_i() : GWizLabText
      {
         var _loc1_:GWizLabText = null;
         _loc1_ = new GWizLabText();
         _loc1_.labTxt = "MRR";
         _loc1_.toolTip = "Material removal rate in cubic inches \ror cc\'s per minute";
         _loc1_.usesMetric = true;
         _loc1_.UnitLabel = "in";
         _loc1_.id = "MRR";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MRR = _loc1_;
         BindingManager.executeBindings(this,"MRR",this.MRR);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizNumStepOvr5_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = null;
         _loc1_ = new GWizNumStepOvr();
         _loc1_.titleTxt = "Tool Torque";
         _loc1_.toolTip = "Tool torque in oz-in or N-m for metric.";
         _loc1_.min = 0;
         _loc1_.max = 100000;
         _loc1_.steps = 0.01;
         _loc1_.UnitLabel = "oz-in";
         _loc1_.id = "Torque";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Torque = _loc1_;
         BindingManager.executeBindings(this,"Torque",this.Torque);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel12_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = null;
         _loc1_ = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Mini Calcs";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array30_c);
         _loc1_.id = "calcPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.calcPanel = _loc1_;
         BindingManager.executeBindings(this,"calcPanel",this.calcPanel);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array30_c() : Array
      {
         var _loc1_:Array = null;
         return [this._GWizFeedsSpeeds2_GWizFSMiniCalcs1_i()];
      }
      
      private function _GWizFeedsSpeeds2_GWizFSMiniCalcs1_i() : GWizFSMiniCalcs
      {
         var _loc1_:GWizFSMiniCalcs = null;
         _loc1_ = new GWizFSMiniCalcs();
         _loc1_.id = "MiniCalcs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MiniCalcs = _loc1_;
         BindingManager.executeBindings(this,"MiniCalcs",this.MiniCalcs);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizForePanel13_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = null;
         _loc1_ = new GWizForePanel();
         _loc1_.title = "Cut KB";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizFeedsSpeeds2_HorizontalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFeedsSpeeds2_Array31_c);
         _loc1_.id = "cutkbPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutkbPanel = _loc1_;
         BindingManager.executeBindings(this,"cutkbPanel",this.cutkbPanel);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_HorizontalLayout2_c() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = null;
         _loc1_ = new HorizontalLayout();
         _loc1_.horizontalAlign = "center";
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Array31_c() : Array
      {
         var _loc1_:Array = null;
         return [this._GWizFeedsSpeeds2_Button4_c(),this._GWizFeedsSpeeds2_Spacer4_c(),this._GWizFeedsSpeeds2_Button5_c(),this._GWizFeedsSpeeds2_Spacer5_c(),this._GWizFeedsSpeeds2_GWizFSCruncherBtn1_c(),this._GWizFeedsSpeeds2_Spacer6_i(),this._GWizFeedsSpeeds2_Button6_i(),this._GWizFeedsSpeeds2_Spacer7_c()];
      }
      
      private function _GWizFeedsSpeeds2_Button4_c() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Search Cut KB";
         _loc1_.height = 24;
         _loc1_.width = 140;
         _loc1_.toolTip = "Search Cut KB for cuts that match these conditions.";
         _loc1_.addEventListener("click",this.___GWizFeedsSpeeds2_Button4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizFeedsSpeeds2_Button4_click(param1:MouseEvent) : void
      {
         this.doFilterCutKB();
      }
      
      private function _GWizFeedsSpeeds2_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.width = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Button5_c() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Add to Cut KB";
         _loc1_.height = 24;
         _loc1_.width = 140;
         _loc1_.toolTip = "Add this cut to the Cut KB.";
         _loc1_.addEventListener("click",this.___GWizFeedsSpeeds2_Button5_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizFeedsSpeeds2_Button5_click(param1:MouseEvent) : void
      {
         this.doAddCutKB();
      }
      
      private function _GWizFeedsSpeeds2_Spacer5_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.width = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_GWizFSCruncherBtn1_c() : GWizFSCruncherBtn
      {
         var _loc1_:GWizFSCruncherBtn = null;
         _loc1_ = new GWizFSCruncherBtn();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Spacer6_i() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.width = 5;
         _loc1_.id = "_GWizFeedsSpeeds2_Spacer6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFeedsSpeeds2_Spacer6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFeedsSpeeds2_Spacer6",this._GWizFeedsSpeeds2_Spacer6);
         return _loc1_;
      }
      
      private function _GWizFeedsSpeeds2_Button6_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.height = 24;
         _loc1_.toolTip = "For transferring cut parameters to other programs.";
         _loc1_.addEventListener("click",this.__ExportBtn_click);
         _loc1_.id = "ExportBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ExportBtn = _loc1_;
         BindingManager.executeBindings(this,"ExportBtn",this.ExportBtn);
         return _loc1_;
      }
      
      public function __ExportBtn_click(param1:MouseEvent) : void
      {
         this.doExport();
      }
      
      private function _GWizFeedsSpeeds2_Spacer7_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.width = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizFeedsSpeeds2_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCreationComplete();
      }
      
      public function ___GWizFeedsSpeeds2_VGroup1_initialize(param1:FlexEvent) : void
      {
         this.onInit();
      }
      
      public function ___GWizFeedsSpeeds2_VGroup1_keyUp(param1:KeyboardEvent) : void
      {
         this.callLater(this.recalc);
      }
      
      public function ___GWizFeedsSpeeds2_VGroup1_click(param1:MouseEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizFeedsSpeeds2_bindingsSetup() : Array
      {
         var result:Array = null;
         result = [];
         result[0] = new Binding(this,function():*
         {
            return GWizSettings.cribGeneration;
         },function(param1:*):void
         {
            cribGeneration = param1;
         },"cribGeneration");
         result[1] = new Binding(this,function():int
         {
            return feedsPanel.width;
         },null,"mmsDefault.firstColWd");
         result[2] = new Binding(this,function():int
         {
            return secondCol.width - 1;
         },null,"mmsDefault.secondColWd");
         result[3] = new Binding(this,function():Number
         {
            return ToolFP.height;
         },null,"mmsDefault.height");
         result[4] = new Binding(this,function():Number
         {
            return feedsPanel.width + secondCol.width;
         },null,"mmsDefault.width");
         result[5] = new Binding(this,null,null,"mmsDefault.labelWidth","labelWidths");
         result[6] = new Binding(this,null,null,"mmsDefault.gapSize","gapSizes");
         result[7] = new Binding(this,function():Number
         {
            return thirdCol.width;
         },null,"ToolFP.width");
         result[8] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"ToolFP.labelBackgroundColor");
         result[9] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"ToolFP.labelColor");
         result[10] = new Binding(this,null,null,"ToolFP.gapSize","gapSizes");
         result[11] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            _GWizFeedsSpeeds2_Label1.setStyle("color",param1);
         },"_GWizFeedsSpeeds2_Label1.color");
         result[12] = new Binding(this,function():Array
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizToolData.MillToolsList;
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },null,"Tool.dataProvider");
         result[13] = new Binding(this,null,null,"Tool.cribTbl","cribTbl");
         result[14] = new Binding(this,null,null,"Tool.toolDef","td");
         result[15] = new Binding(this,function():Function
         {
            return toolPopupSetFunctions;
         },null,"Tool.vcHandler");
         result[16] = new Binding(this,function():Function
         {
            return onToolChange;
         },null,"Tool.changeHandler");
         result[17] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            _GWizFeedsSpeeds2_Label2.setStyle("color",param1);
         },"_GWizFeedsSpeeds2_Label2.color");
         result[18] = new Binding(this,function():IList
         {
            return GWizCribList.cribListPlus;
         },null,"cribTbl.dataProvider");
         result[19] = new Binding(this,function():int
         {
            return feedsPanel.width;
         },null,"td.firstColWd");
         result[20] = new Binding(this,function():int
         {
            return secondCol.width;
         },null,"td.secondColWd");
         result[21] = new Binding(this,function():int
         {
            return thirdCol.width;
         },null,"td.thirdColWd");
         result[22] = new Binding(this,function():Function
         {
            return td.optStick.optimize;
         },null,"td.optStickFcn");
         result[23] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            td.setStyle("color",param1);
         },"td.color");
         result[24] = new Binding(this,null,null,"td.labelWidth","labelWidths");
         result[25] = new Binding(this,null,null,"td.gapSize","gapSizes");
         result[26] = new Binding(this,function():Function
         {
            return recalc;
         },null,"mfgSpecs.recalcFcn");
         result[27] = new Binding(this,function():int
         {
            return feedsPanel.width;
         },null,"mfgSpecs.firstColWd");
         result[28] = new Binding(this,function():int
         {
            return secondCol.width;
         },null,"mfgSpecs.secondColWd");
         result[29] = new Binding(this,function():int
         {
            return thirdCol.width;
         },null,"mfgSpecs.thirdColWd");
         result[30] = new Binding(this,function():int
         {
            return this.labelWidths;
         },null,"mfgSpecs.labelWidths");
         result[31] = new Binding(this,function():int
         {
            return this.gapSizes;
         },null,"mfgSpecs.gapSizes");
         result[32] = new Binding(this,function():Number
         {
            return feedsPanel.width;
         },null,"cutPanel.width");
         result[33] = new Binding(this,function():Number
         {
            return HSMPanel.height;
         },null,"cutPanel.height");
         result[34] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"cutPanel.labelBackgroundColor");
         result[35] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"cutPanel.labelColor");
         result[36] = new Binding(this,null,null,"cutPanel.labelWidth","labelWidths");
         result[37] = new Binding(this,null,null,"cutPanel.gapSize","gapSizes");
         result[38] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            cutDepthLabel.setStyle("color",param1);
         },"cutDepthLabel.color");
         result[39] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            cutDepth.setStyle("color",param1);
         },"cutDepth.color");
         result[40] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            AxialEngagement.setStyle("color",param1);
         },"AxialEngagement.color");
         result[41] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"AxialEngagement.visible");
         result[42] = new Binding(this,function():Number
         {
            return secondCol.width;
         },null,"_GWizFeedsSpeeds2_GWizForePanel3.width");
         result[43] = new Binding(this,function():Number
         {
            return HSMPanel.height;
         },null,"_GWizFeedsSpeeds2_GWizForePanel3.height");
         result[44] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizFeedsSpeeds2_GWizForePanel3.labelBackgroundColor");
         result[45] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizFeedsSpeeds2_GWizForePanel3.labelColor");
         result[46] = new Binding(this,null,null,"_GWizFeedsSpeeds2_GWizForePanel3.labelWidth","labelWidths");
         result[47] = new Binding(this,null,null,"_GWizFeedsSpeeds2_GWizForePanel3.gapSize","gapSizes");
         result[48] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            cutWidthLabel.setStyle("color",param1);
         },"cutWidthLabel.color");
         result[49] = new Binding(this,function():Boolean
         {
            return cutWidth.visible;
         },null,"cutWidthLabel.visible");
         result[50] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            cutWidth.setStyle("color",param1);
         },"cutWidth.color");
         result[51] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"SlotBtn.visible");
         result[52] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            RadialEngagement.setStyle("color",param1);
         },"RadialEngagement.color");
         result[53] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"RadialEngagement.visible");
         result[54] = new Binding(this,function():Number
         {
            return thirdCol.width;
         },null,"HSMPanel.width");
         result[55] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"HSMPanel.labelBackgroundColor");
         result[56] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"HSMPanel.labelColor");
         result[57] = new Binding(this,null,null,"HSMPanel.labelWidth","labelWidths");
         result[58] = new Binding(this,null,null,"HSMPanel.gapSize","gapSizes");
         result[59] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            showHSMFeedsSpeeds.setStyle("color",param1);
         },"showHSMFeedsSpeeds.color");
         result[60] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"feedsPanel.labelBackgroundColor");
         result[61] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"feedsPanel.labelColor");
         result[62] = new Binding(this,null,null,"feedsPanel.labelWidth","labelWidths");
         result[63] = new Binding(this,null,null,"feedsPanel.gapSize","gapSizes");
         result[64] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_RPM;
         },null,"RPM.max");
         result[65] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            RPM.setStyle("color",param1);
         },"RPM.color");
         result[66] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = " (" + GWizUtils.roundBigTenths(String(rpmTempSlider.percent * 100),false) + "%)";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"RPM.suffix");
         result[67] = new Binding(this,function():Number
         {
            return feedsPanel.height;
         },null,"secondCol.height");
         result[68] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"secondCol.labelBackgroundColor");
         result[69] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"secondCol.labelColor");
         result[70] = new Binding(this,null,null,"secondCol.labelWidth","labelWidths");
         result[71] = new Binding(this,null,null,"secondCol.gapSize","gapSizes");
         result[72] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_FEEDRATE;
         },null,"IPM.max");
         result[73] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            IPM.setStyle("color",param1);
         },"IPM.color");
         result[74] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = " (" + GWizUtils.roundBigTenths(String(feedTempSlider.percent * 100),false) + "%)";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"IPM.suffix");
         result[75] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            IPR.setStyle("color",param1);
         },"IPR.color");
         result[76] = new Binding(this,function():Number
         {
            return feedsPanel.height;
         },null,"thirdCol.height");
         result[77] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"thirdCol.labelBackgroundColor");
         result[78] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"thirdCol.labelColor");
         result[79] = new Binding(this,null,null,"thirdCol.labelWidth","labelWidths");
         result[80] = new Binding(this,null,null,"thirdCol.gapSize","gapSizes");
         result[81] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(PlungeRate.visible,!GWizAbstractPrefs.isOEM);
         },null,"_GWizFeedsSpeeds2_Label8.visible");
         result[82] = new Binding(this,function():IList
         {
            return PlungeModes;
         },null,"plungeModeX.dataProvider");
         result[83] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(PlungeRate.visible,!GWizAbstractPrefs.isOEM);
         },null,"plungeModeX.visible");
         result[84] = new Binding(this,function():Number
         {
            return 1;
         },null,"PlungeRate.decPlaces");
         result[85] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            PlungeRate.setStyle("color",param1);
         },"PlungeRate.color");
         result[86] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(PlungeRate.visible,!GWizAbstractPrefs.isOEM);
         },null,"PlungeRate.visible");
         result[87] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"tipsTitlePanel.labelBackgroundColor");
         result[88] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"tipsTitlePanel.labelColor");
         result[89] = new Binding(this,null,null,"tipsTitlePanel.labelWidth","labelWidths");
         result[90] = new Binding(this,null,null,"tipsTitlePanel.gapSize","gapSizes");
         result[91] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            hint.setStyle("color",param1);
         },"hint.color");
         result[92] = new Binding(this,null,null,"hintDropdown.dataProvider","tipList");
         result[93] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"_GWizFeedsSpeeds2_Button2.visible");
         result[94] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizFeedsSpeeds2_GWizForePanel10.labelBackgroundColor");
         result[95] = new Binding(this,null,null,"_GWizFeedsSpeeds2_GWizForePanel10.labelWidth","labelWidths");
         result[96] = new Binding(this,null,null,"_GWizFeedsSpeeds2_GWizForePanel10.gapSize","gapSizes");
         result[97] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizFeedsSpeeds2_GWizForePanel10.labelColor");
         result[98] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.FEET_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"SFM.impUnits");
         result[99] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.M_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"SFM.metUnits");
         result[100] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            AFPT.setStyle("color",param1);
         },"AFPT.color");
         result[101] = new Binding(this,function():Number
         {
            return SFM.height;
         },null,"AFPT.height");
         result[102] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            EffDiam.setStyle("color",param1);
         },"EffDiam.color");
         result[103] = new Binding(this,function():Number
         {
            return SFM.height;
         },null,"EffDiam.height");
         result[104] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizFeedsSpeeds2_GWizForePanel11.labelBackgroundColor");
         result[105] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizFeedsSpeeds2_GWizForePanel11.labelColor");
         result[106] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.KW_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"HP.metUnits");
         result[107] = new Binding(this,function():Number
         {
            return NaN;
         },null,"HP.width");
         result[108] = new Binding(this,function():Number
         {
            return SFM.height;
         },null,"HP.height");
         result[109] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = " (" + GWizUtils.roundBigTenths(String(hpTempSlider.percent * 100),false) + "%)";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizFeedsSpeeds2_Label10.text");
         result[110] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = " (" + GWizUtils.roundBigTenths(String(deflectTempSlider.percent * 100),false) + "%)";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizFeedsSpeeds2_Label11.text");
         result[111] = new Binding(this,function():Boolean
         {
            return Deflect.visible;
         },null,"_GWizFeedsSpeeds2_Label11.visible");
         result[112] = new Binding(this,function():Boolean
         {
            return Deflect.visible;
         },null,"deflectTempSlider.visible");
         result[113] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.CC_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"MRR.metUnits");
         result[114] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            MRR.setStyle("color",param1);
         },"MRR.color");
         result[115] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(optWidth.visible,this.powerUserState);
         },null,"Torque.visible");
         result[116] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.NM_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"Torque.metUnits");
         result[117] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.OZIN_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"Torque.impUnits");
         result[118] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"calcPanel.labelBackgroundColor");
         result[119] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"calcPanel.labelColor");
         result[120] = new Binding(this,null,null,"calcPanel.labelWidth","labelWidths");
         result[121] = new Binding(this,null,null,"calcPanel.gapSize","gapSizes");
         result[122] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"cutkbPanel.labelBackgroundColor");
         result[123] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"cutkbPanel.labelColor");
         result[124] = new Binding(this,null,null,"cutkbPanel.labelWidth","labelWidths");
         result[125] = new Binding(this,null,null,"cutkbPanel.gapSize","gapSizes");
         result[126] = new Binding(this,function():Boolean
         {
            return GWizUtils.debug;
         },null,"_GWizFeedsSpeeds2_Spacer6.visible");
         result[127] = new Binding(this,function():Boolean
         {
            return GWizUtils.debug;
         },null,"_GWizFeedsSpeeds2_Spacer6.includeInLayout");
         result[128] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = exportBtnLabel;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"ExportBtn.label");
         result[129] = new Binding(this,function():Boolean
         {
            return GWizFeedsSpeeds2.showExport;
         },null,"ExportBtn.visible");
         return result;
      }
      
      private function _GWizFeedsSpeeds2_bindingExprs() : void
      {
         var _loc1_:* = undefined;
         this.cribGeneration = GWizSettings.cribGeneration;
      }
      
      [Bindable(event="propertyChange")]
      public function get AFPT() : GWizLabText
      {
         return this._2006249AFPT;
      }
      
      public function set AFPT(param1:GWizLabText) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2006249AFPT;
         if(_loc2_ !== param1)
         {
            this._2006249AFPT = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AFPT",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get AxialEngagement() : Label
      {
         return this._1489202876AxialEngagement;
      }
      
      public function set AxialEngagement(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1489202876AxialEngagement;
         if(_loc2_ !== param1)
         {
            this._1489202876AxialEngagement = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AxialEngagement",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Deflect() : GWizLabText
      {
         return this._1085198065Deflect;
      }
      
      public function set Deflect(param1:GWizLabText) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1085198065Deflect;
         if(_loc2_ !== param1)
         {
            this._1085198065Deflect = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Deflect",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EffDiam() : GWizLabText
      {
         return this._170253098EffDiam;
      }
      
      public function set EffDiam(param1:GWizLabText) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._170253098EffDiam;
         if(_loc2_ !== param1)
         {
            this._170253098EffDiam = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EffDiam",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ExportBtn() : Button
      {
         return this._1868626456ExportBtn;
      }
      
      public function set ExportBtn(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1868626456ExportBtn;
         if(_loc2_ !== param1)
         {
            this._1868626456ExportBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ExportBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GasPedal() : GWizTortHare
      {
         return this._1551631807GasPedal;
      }
      
      public function set GasPedal(param1:GWizTortHare) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1551631807GasPedal;
         if(_loc2_ !== param1)
         {
            this._1551631807GasPedal = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GasPedal",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HP() : GWizLabText
      {
         return this._2312HP;
      }
      
      public function set HP(param1:GWizLabText) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2312HP;
         if(_loc2_ !== param1)
         {
            this._2312HP = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HP",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HSM() : VGroup
      {
         return this._71842HSM;
      }
      
      public function set HSM(param1:VGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._71842HSM;
         if(_loc2_ !== param1)
         {
            this._71842HSM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HSM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HSMPanel() : GWizForePanel
      {
         return this._436988286HSMPanel;
      }
      
      public function set HSMPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._436988286HSMPanel;
         if(_loc2_ !== param1)
         {
            this._436988286HSMPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HSMPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get IPM() : GWizNumStepOvr
      {
         return this._72710IPM;
      }
      
      public function set IPM(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._72710IPM;
         if(_loc2_ !== param1)
         {
            this._72710IPM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IPM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get IPR() : GWizLabText
      {
         return this._72715IPR;
      }
      
      public function set IPR(param1:GWizLabText) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._72715IPR;
         if(_loc2_ !== param1)
         {
            this._72715IPR = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IPR",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get IPT() : GWizNumStepOvr
      {
         return this._72717IPT;
      }
      
      public function set IPT(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._72717IPT;
         if(_loc2_ !== param1)
         {
            this._72717IPT = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IPT",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MRR() : GWizLabText
      {
         return this._76621MRR;
      }
      
      public function set MRR(param1:GWizLabText) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._76621MRR;
         if(_loc2_ !== param1)
         {
            this._76621MRR = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MRR",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MiniCalcs() : GWizFSMiniCalcs
      {
         return this._1511458169MiniCalcs;
      }
      
      public function set MiniCalcs(param1:GWizFSMiniCalcs) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1511458169MiniCalcs;
         if(_loc2_ !== param1)
         {
            this._1511458169MiniCalcs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MiniCalcs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PCN() : CheckBox
      {
         return this._79035PCN;
      }
      
      public function set PCN(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._79035PCN;
         if(_loc2_ !== param1)
         {
            this._79035PCN = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PCN",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PlungeRate() : GWizLabText
      {
         return this._836610861PlungeRate;
      }
      
      public function set PlungeRate(param1:GWizLabText) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._836610861PlungeRate;
         if(_loc2_ !== param1)
         {
            this._836610861PlungeRate = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PlungeRate",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RPM() : GWizNumStepOvr
      {
         return this._81359RPM;
      }
      
      public function set RPM(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._81359RPM;
         if(_loc2_ !== param1)
         {
            this._81359RPM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RPM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RadialEngagement() : Label
      {
         return this._798361566RadialEngagement;
      }
      
      public function set RadialEngagement(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._798361566RadialEngagement;
         if(_loc2_ !== param1)
         {
            this._798361566RadialEngagement = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RadialEngagement",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SFM() : GWizNumStepOvr
      {
         return this._82010SFM;
      }
      
      public function set SFM(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._82010SFM;
         if(_loc2_ !== param1)
         {
            this._82010SFM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SFM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SlotBtn() : Button
      {
         return this._448623778SlotBtn;
      }
      
      public function set SlotBtn(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._448623778SlotBtn;
         if(_loc2_ !== param1)
         {
            this._448623778SlotBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SlotBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TSC() : CheckBox
      {
         return this._83364TSC;
      }
      
      public function set TSC(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._83364TSC;
         if(_loc2_ !== param1)
         {
            this._83364TSC = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TSC",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TipsHGroup() : HGroup
      {
         return this._1391077265TipsHGroup;
      }
      
      public function set TipsHGroup(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1391077265TipsHGroup;
         if(_loc2_ !== param1)
         {
            this._1391077265TipsHGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TipsHGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Tool() : GWizToolMenu
      {
         return this._2612664Tool;
      }
      
      public function set Tool(param1:GWizToolMenu) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2612664Tool;
         if(_loc2_ !== param1)
         {
            this._2612664Tool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Tool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolFP() : GWizForePanel
      {
         return this._1784194942ToolFP;
      }
      
      public function set ToolFP(param1:GWizForePanel) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1784194942ToolFP;
         if(_loc2_ !== param1)
         {
            this._1784194942ToolFP = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolFP",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolGrp() : VGroup
      {
         return this._524533773ToolGrp;
      }
      
      public function set ToolGrp(param1:VGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._524533773ToolGrp;
         if(_loc2_ !== param1)
         {
            this._524533773ToolGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Torque() : GWizNumStepOvr
      {
         return this._1784099286Torque;
      }
      
      public function set Torque(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1784099286Torque;
         if(_loc2_ !== param1)
         {
            this._1784099286Torque = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Torque",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get advHBox() : HGroup
      {
         return this._1132353642advHBox;
      }
      
      public function set advHBox(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1132353642advHBox;
         if(_loc2_ !== param1)
         {
            this._1132353642advHBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"advHBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get calcPanel() : GWizForePanel
      {
         return this._1318138705calcPanel;
      }
      
      public function set calcPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1318138705calcPanel;
         if(_loc2_ !== param1)
         {
            this._1318138705calcPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"calcPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get coolantOptions() : HGroup
      {
         return this._1511647936coolantOptions;
      }
      
      public function set coolantOptions(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1511647936coolantOptions;
         if(_loc2_ !== param1)
         {
            this._1511647936coolantOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"coolantOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cribTbl() : GWizGWCToolCribSelector
      {
         return this._1032247510cribTbl;
      }
      
      public function set cribTbl(param1:GWizGWCToolCribSelector) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1032247510cribTbl;
         if(_loc2_ !== param1)
         {
            this._1032247510cribTbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cribTbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutDepth() : GWizNumStep
      {
         return this._590180769cutDepth;
      }
      
      public function set cutDepth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._590180769cutDepth;
         if(_loc2_ !== param1)
         {
            this._590180769cutDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutDepthLabel() : Label
      {
         return this._1146488365cutDepthLabel;
      }
      
      public function set cutDepthLabel(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1146488365cutDepthLabel;
         if(_loc2_ !== param1)
         {
            this._1146488365cutDepthLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutDepthLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutGrp() : HGroup
      {
         return this._1349101757cutGrp;
      }
      
      public function set cutGrp(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1349101757cutGrp;
         if(_loc2_ !== param1)
         {
            this._1349101757cutGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutPanel() : GWizForePanel
      {
         return this._601141474cutPanel;
      }
      
      public function set cutPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._601141474cutPanel;
         if(_loc2_ !== param1)
         {
            this._601141474cutPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutWidth() : GWizNumStep
      {
         return this._607835300cutWidth;
      }
      
      public function set cutWidth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._607835300cutWidth;
         if(_loc2_ !== param1)
         {
            this._607835300cutWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutWidthLabel() : Label
      {
         return this._1335951536cutWidthLabel;
      }
      
      public function set cutWidthLabel(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1335951536cutWidthLabel;
         if(_loc2_ !== param1)
         {
            this._1335951536cutWidthLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutWidthLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutkbPanel() : GWizForePanel
      {
         return this._364943979cutkbPanel;
      }
      
      public function set cutkbPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._364943979cutkbPanel;
         if(_loc2_ !== param1)
         {
            this._364943979cutkbPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutkbPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get deflectTempSlider() : GWizTempSlider
      {
         return this._1117618076deflectTempSlider;
      }
      
      public function set deflectTempSlider(param1:GWizTempSlider) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1117618076deflectTempSlider;
         if(_loc2_ !== param1)
         {
            this._1117618076deflectTempSlider = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"deflectTempSlider",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get feedTempSlider() : GWizTempSlider
      {
         return this._453751277feedTempSlider;
      }
      
      public function set feedTempSlider(param1:GWizTempSlider) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._453751277feedTempSlider;
         if(_loc2_ !== param1)
         {
            this._453751277feedTempSlider = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"feedTempSlider",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get feedsPanel() : GWizForePanel
      {
         return this._1121656943feedsPanel;
      }
      
      public function set feedsPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1121656943feedsPanel;
         if(_loc2_ !== param1)
         {
            this._1121656943feedsPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"feedsPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hint() : Label
      {
         return this._3202695hint;
      }
      
      public function set hint(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._3202695hint;
         if(_loc2_ !== param1)
         {
            this._3202695hint = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hint",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hintDropdown() : List
      {
         return this._1117982648hintDropdown;
      }
      
      public function set hintDropdown(param1:List) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1117982648hintDropdown;
         if(_loc2_ !== param1)
         {
            this._1117982648hintDropdown = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hintDropdown",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hpTempSlider() : GWizTempSlider
      {
         return this._558778115hpTempSlider;
      }
      
      public function set hpTempSlider(param1:GWizTempSlider) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._558778115hpTempSlider;
         if(_loc2_ !== param1)
         {
            this._558778115hpTempSlider = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hpTempSlider",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machPanel() : HGroup
      {
         return this._1467266933machPanel;
      }
      
      public function set machPanel(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1467266933machPanel;
         if(_loc2_ !== param1)
         {
            this._1467266933machPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mfgSpecs() : GWizMfgCutterSpecs
      {
         return this._52752074mfgSpecs;
      }
      
      public function set mfgSpecs(param1:GWizMfgCutterSpecs) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._52752074mfgSpecs;
         if(_loc2_ !== param1)
         {
            this._52752074mfgSpecs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mfgSpecs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mmsDefault() : GWizFSMachineMaterialSelector
      {
         return this._1914960914mmsDefault;
      }
      
      public function set mmsDefault(param1:GWizFSMachineMaterialSelector) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1914960914mmsDefault;
         if(_loc2_ !== param1)
         {
            this._1914960914mmsDefault = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mmsDefault",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get optDepth() : GWizOptimizeBtn
      {
         return this._113482800optDepth;
      }
      
      public function set optDepth(param1:GWizOptimizeBtn) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._113482800optDepth;
         if(_loc2_ !== param1)
         {
            this._113482800optDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"optDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get optSlider() : GWizOptimizeBtn
      {
         return this._1212678516optSlider;
      }
      
      public function set optSlider(param1:GWizOptimizeBtn) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1212678516optSlider;
         if(_loc2_ !== param1)
         {
            this._1212678516optSlider = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"optSlider",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get optWidth() : GWizOptimizeBtn
      {
         return this._95828269optWidth;
      }
      
      public function set optWidth(param1:GWizOptimizeBtn) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._95828269optWidth;
         if(_loc2_ !== param1)
         {
            this._95828269optWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"optWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get plungeModeX() : DropDownList
      {
         return this._1837217374plungeModeX;
      }
      
      public function set plungeModeX(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1837217374plungeModeX;
         if(_loc2_ !== param1)
         {
            this._1837217374plungeModeX = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"plungeModeX",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rpmTempSlider() : GWizTempSlider
      {
         return this._1813401308rpmTempSlider;
      }
      
      public function set rpmTempSlider(param1:GWizTempSlider) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1813401308rpmTempSlider;
         if(_loc2_ !== param1)
         {
            this._1813401308rpmTempSlider = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rpmTempSlider",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get secondCol() : GWizForePanel
      {
         return this._817627028secondCol;
      }
      
      public function set secondCol(param1:GWizForePanel) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._817627028secondCol;
         if(_loc2_ !== param1)
         {
            this._817627028secondCol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"secondCol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get showHSMFeedsSpeeds() : CheckBox
      {
         return this._1391678012showHSMFeedsSpeeds;
      }
      
      public function set showHSMFeedsSpeeds(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1391678012showHSMFeedsSpeeds;
         if(_loc2_ !== param1)
         {
            this._1391678012showHSMFeedsSpeeds = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"showHSMFeedsSpeeds",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get td() : GWizToolDef
      {
         return this._3696td;
      }
      
      public function set td(param1:GWizToolDef) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._3696td;
         if(_loc2_ !== param1)
         {
            this._3696td = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"td",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get thirdCol() : GWizForePanel
      {
         return this._1228027545thirdCol;
      }
      
      public function set thirdCol(param1:GWizForePanel) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1228027545thirdCol;
         if(_loc2_ !== param1)
         {
            this._1228027545thirdCol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"thirdCol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tipsPanel() : HGroup
      {
         return this._1209398868tipsPanel;
      }
      
      public function set tipsPanel(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1209398868tipsPanel;
         if(_loc2_ !== param1)
         {
            this._1209398868tipsPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tipsPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tipsTitlePanel() : GWizForePanel
      {
         return this._2029271012tipsTitlePanel;
      }
      
      public function set tipsTitlePanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2029271012tipsTitlePanel;
         if(_loc2_ !== param1)
         {
            this._2029271012tipsTitlePanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tipsTitlePanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tipList() : ArrayCollection
      {
         return this._1311891495tipList;
      }
      
      public function set tipList(param1:ArrayCollection) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1311891495tipList;
         if(_loc2_ !== param1)
         {
            this._1311891495tipList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tipList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelWidths() : int
      {
         return this._166064001labelWidths;
      }
      
      public function set labelWidths(param1:int) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._166064001labelWidths;
         if(_loc2_ !== param1)
         {
            this._166064001labelWidths = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelWidths",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gapSizes() : int
      {
         return this._1699252388gapSizes;
      }
      
      public function set gapSizes(param1:int) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1699252388gapSizes;
         if(_loc2_ !== param1)
         {
            this._1699252388gapSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gapSizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get powerUserState() : Boolean
      {
         return this._513770495powerUserState;
      }
      
      private function set powerUserState(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._513770495powerUserState;
         if(_loc2_ !== param1)
         {
            this._513770495powerUserState = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"powerUserState",_loc2_,param1));
            }
         }
      }
   }
}
