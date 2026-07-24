package cadcamwiz
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import feedsspeeds.GWizTortHare;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColor;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.DropDownList;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.HSlider;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.List;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import spark.primitives.Rect;
   import tools.GWizCribList;
   import tools.GWizToolCribArray;
   import tools.GWizToolCribEntry;
   
   use namespace mx_internal;
   
   public class GWizCCWMillOptions extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizCCWMillOptions");
      
      private static var creationComplete:Boolean = false;
      
      private static var _StepoverSlider:Number = 1;
      
      private static var _439920479_GasPedalSlider:Number = GWizTortHare.GAS_PEDAL_MAX;
      
      private static var _maxToolDiameter:Number;
      
      public static var cribTool:int = -1;
      
      public static var cribToolGUID:String = "";
      
      public static var gasPedalFactors:ArrayCollection = new ArrayCollection([{
         "stepover":0.7,
         "pedal":1
      },{
         "stepover":0.8,
         "pedal":2
      },{
         "stepover":0.9,
         "pedal":3
      },{
         "stepover":1,
         "pedal":4
      }]);
      
      private static var _236467632usePremiumCoolantOptions:Boolean = true;
      
      public static var SolidCribName:String = null;
      
      private static var prefsSolidCribName:String = "";
      
      private static var theSolidCribDropdown:DropDownList;
      
      private static var _33813952maxToolDia:Number = 0.75;
      
      public static const MAX_SOLID_TOOL_DOC_MULT_DEFAULT:Number = 3;
      
      public static const MAX_SOLID_TOOL_STEPOVER_DEFAULT:Number = 100;
      
      private static var _1897072727maxSolidToolDOCMult:Number = MAX_SOLID_TOOL_DOC_MULT_DEFAULT;
      
      private static var _1176081567maxSolidToolStepover:Number = MAX_SOLID_TOOL_STEPOVER_DEFAULT;
      
      private static var _1254650959maxRoughToolDia:Number = 0.75;
      
      private static var _1281443364maxIdxRoughToolDia:Number = 1;
      
      private static var _1853292433idxRoughFlutes:Number = 3;
      
      private static var _877947969maxIdxDOC:Number = 0.25;
      
      private static var _565713245maxFaceToolDia:Number = 3;
      
      private static var _30791372faceMillFlutes:Number = 6;
      
      private static var _81564567maxFaceDOC:Number = 0.25;
      
      private static var _448489434impSizes:Boolean = true;
      
      private static var _1154131666mmSizes:Boolean = true;
      
      private static var _1960055573roughStrat:int = 0;
      
      public static var cadcamRecalcs:Number = 0;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _821762436AnyTool:Label;
      
      private var _1694435774ChamferMill:RadioButton;
      
      private var _2126633540ChamferOptions:RadioButtonGroup;
      
      private var _2092478441ChamferSpotDrill:RadioButton;
      
      private var _556323774ChamferToolCarbide:CheckBox;
      
      private var _2017281310ChamferToolDia:GWizNumStep;
      
      private var _1584361171ChamferToolFlutes:GWizNumStep;
      
      private var _971201812FaceMillFlutes:GWizNumStep;
      
      private var _1149965683FinishType:RadioButtonGroup;
      
      private var _1551631807GasPedal:HSlider;
      
      private var _1439681679IdxRoughFlutes:GWizNumStep;
      
      private var _383845306ImpSizes:CheckBox;
      
      private var _1902652114MMSizes:CheckBox;
      
      private var _2075029431MaxFaceDOC:GWizNumStep;
      
      private var _1567706429MaxFaceToolDia:GWizNumStep;
      
      private var _1126019999MaxIdxDOC:GWizNumStep;
      
      private var _1171979708MaxIdxRoughToolDia:GWizNumStep;
      
      private var _257633327MaxRoughToolDia:GWizNumStep;
      
      private var _643776631MaxSolidToolDOCMult:GWizNumStep;
      
      private var _1373554879MaxSolidToolStepover:GWizNumStep;
      
      private var _2027278816MaxToolDia:GWizNumStep;
      
      private var _1694867030RecalcOptions:RadioButtonGroup;
      
      private var _33409291RoughStrat:DropDownList;
      
      private var _650225395SolidCrib:DropDownList;
      
      public var _GWizCCWMillOptions_Image1:Image;
      
      public var _GWizCCWMillOptions_Image2:Image;
      
      private var _502514790cribListUI:List;
      
      private var _1117124949nonCribToolSpecs:VGroup;
      
      private var _6516163roughLbl:Label;
      
      private var _308992412useCribs:CheckBox;
      
      private var _240493677usePremCoolant:CheckBox;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWMillOptions()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWMillOptions_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWMillOptionsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWMillOptions[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.gap = 1;
         this.mxmlContent = [this._GWizCCWMillOptions_HGroup1_c(),this._GWizCCWMillOptions_GWizForePanel3_c(),this._GWizCCWMillOptions_GWizForePanel4_c(),this._GWizCCWMillOptions_GWizForePanel5_c(),this._GWizCCWMillOptions_GWizForePanel6_c(),this._GWizCCWMillOptions_VGroup9_c()];
         this._GWizCCWMillOptions_RadioButtonGroup3_i();
         this._GWizCCWMillOptions_RadioButtonGroup1_i();
         this._GWizCCWMillOptions_RadioButtonGroup2_i();
         this.addEventListener("creationComplete",this.___GWizCCWMillOptions_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function get StepoverSlider() : Number
      {
         return _StepoverSlider;
      }
      
      public static function set StepoverSlider(param1:Number) : void
      {
         _StepoverSlider = param1;
      }
      
      public static function set GasPedalSlider(param1:Number) : void
      {
         _GasPedalSlider = param1;
      }
      
      public static function get GasPedalSlider() : Number
      {
         return _GasPedalSlider;
      }
      
      public static function maxToolDiameter(param1:int, param2:Boolean, param3:Boolean) : Number
      {
         var _loc4_:Number = 0;
         if(useCribForSolidEndmills())
         {
            _loc4_ = maxEndmillDiaInCCWCribList(NaN,param1,param2,param3);
         }
         if(_loc4_ <= 0)
         {
            if(param2)
            {
               _loc4_ = GWizCCWMillOptions.maxRoughToolDia;
            }
            else
            {
               _loc4_ = _maxToolDiameter;
            }
            if(isNaN(_loc4_))
            {
               _loc4_ = 0.75;
            }
         }
         return _loc4_;
      }
      
      public static function useCribForSolidEndmills() : Boolean
      {
         return GWizCCWSettings.toolCribToolSelection && GWizCribList.ccwCribList && GWizCribList.ccwCribList.length > 0;
      }
      
      public static function maxEndmillDiaInCCWCribList(param1:Number, param2:int, param3:Boolean, param4:Boolean) : Number
      {
         var _loc8_:Object = null;
         GWizToolCribArray.cribTool = -1;
         var _loc5_:Number = 0;
         var _loc6_:int;
         var _loc7_:* = (_loc6_ = 0) >= GWizCribList.ccwCribList.length;
         while(!_loc7_)
         {
            _loc8_ = GWizCribList.ccwCribList.getItemAt(_loc6_);
            SolidCribName = _loc8_.tabname;
            _loc5_ = GWizCribList.maxEndmillDiaInCrib(SolidCribName,param1,param2,param3,param4);
            _loc6_++;
            if(_loc6_ >= GWizCribList.ccwCribList.length)
            {
               _loc7_ = true;
            }
            else if(false && isNaN(param1))
            {
               _loc7_ = true;
            }
            else if(GWizToolCribArray.cribToolGUID != "")
            {
               _loc7_ = true;
            }
         }
         cribTool = GWizToolCribArray.cribTool;
         cribToolGUID = GWizToolCribArray.cribToolGUID;
         return _loc5_;
      }
      
      public static function toolCribEntry(param1:int) : GWizToolCribEntry
      {
         return GWizCribList.getCribEntryAt(SolidCribName,param1);
      }
      
      public static function processCCWXMLData(param1:XML) : XML
      {
         prefsSolidCribName = GWizCribList.NO_CRIB;
         if(param1.hasOwnProperty("SolidCribName"))
         {
            prefsSolidCribName = param1.SolidCribName;
         }
         if(param1.hasOwnProperty("MaxToolDia"))
         {
            _maxToolDiameter = param1.MaxToolDia;
         }
         if(param1.hasOwnProperty("MaxSolidToolDOCMult"))
         {
            maxSolidToolDOCMult = param1.MaxSolidToolDOCMult;
         }
         if(param1.hasOwnProperty("MaxSolidToolStepover"))
         {
            maxSolidToolStepover = param1.MaxSolidToolStepover;
         }
         if(param1.hasOwnProperty("MaxRoughToolDia"))
         {
            maxRoughToolDia = param1.MaxRoughToolDia;
         }
         if(param1.hasOwnProperty("MaxIdxRoughToolDia"))
         {
            maxIdxRoughToolDia = param1.MaxIdxRoughToolDia;
         }
         if(param1.hasOwnProperty("idxRoughFlutes"))
         {
            idxRoughFlutes = param1.idxRoughFlutes;
         }
         if(param1.hasOwnProperty("MaxIdxDOC"))
         {
            maxIdxDOC = param1.MaxIdxDOC;
         }
         if(param1.hasOwnProperty("MaxFaceToolDia"))
         {
            maxFaceToolDia = param1.MaxFaceToolDia;
         }
         if(param1.hasOwnProperty("faceMillFlutes"))
         {
            faceMillFlutes = param1.faceMillFlutes;
         }
         if(param1.hasOwnProperty("MaxFaceDOC"))
         {
            maxFaceDOC = param1.MaxFaceDOC;
         }
         if(param1.hasOwnProperty("GasPedal"))
         {
            GasPedalSlider = param1.GasPedal;
         }
         if(param1.hasOwnProperty("ImpSizes"))
         {
            impSizes = param1.ImpSizes == "true";
         }
         if(param1.hasOwnProperty("MMSizes"))
         {
            mmSizes = param1.MMSizes == "true";
         }
         if(param1.hasOwnProperty("usePremiumCoolantOptions"))
         {
            usePremiumCoolantOptions = param1.usePremiumCoolantOptions == "true";
         }
         if(param1.hasOwnProperty("cadcamRecalcs"))
         {
            cadcamRecalcs = param1.cadcamRecalcs;
         }
         if(param1.hasOwnProperty("roughStrat"))
         {
            roughStrat = param1.roughStrat;
         }
         if(param1.hasOwnProperty("useCribsCCW"))
         {
            GWizCCWSettings.toolCribToolSelection = param1.useCribsCCW == "true";
         }
         else
         {
            GWizCCWSettings.toolCribToolSelection = false;
         }
         return param1;
      }
      
      public static function createCCWXMLData(param1:XML) : XML
      {
         param1.SolidCribName = SolidCribName;
         param1.MaxToolDiameter = maxToolDia;
         param1.MaxSolidToolDOCMult = maxSolidToolDOCMult;
         param1.MaxSolidToolStepover = maxSolidToolStepover;
         param1.MaxRoughToolDia = maxRoughToolDia;
         param1.MaxIdxRoughToolDia = maxIdxRoughToolDia;
         param1.idxRoughFlutes = idxRoughFlutes;
         param1.MaxIdxDOC = maxIdxDOC;
         param1.MaxFaceToolDia = maxFaceToolDia;
         param1.faceMillFlutes = faceMillFlutes;
         param1.MaxFaceDOC = maxFaceDOC;
         param1.GasPedal = GasPedalSlider;
         param1.ImpSizes = impSizes;
         param1.MMSizes = mmSizes;
         param1.usePremiumCoolantOptions = usePremiumCoolantOptions;
         param1.cadcamRecalcs = cadcamRecalcs;
         param1.roughStrat = roughStrat;
         param1.useCribsCCW = GWizCCWSettings.toolCribToolSelection;
         return param1;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWMillOptions._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get _GasPedalSlider() : Number
      {
         return GWizCCWMillOptions._439920479_GasPedalSlider;
      }
      
      private static function set _GasPedalSlider(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._439920479_GasPedalSlider;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"_GasPedalSlider",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get usePremiumCoolantOptions() : Boolean
      {
         return GWizCCWMillOptions._236467632usePremiumCoolantOptions;
      }
      
      public static function set usePremiumCoolantOptions(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._236467632usePremiumCoolantOptions;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"usePremiumCoolantOptions",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get maxToolDia() : Number
      {
         return GWizCCWMillOptions._33813952maxToolDia;
      }
      
      private static function set maxToolDia(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._33813952maxToolDia;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"maxToolDia",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get maxSolidToolDOCMult() : Number
      {
         return GWizCCWMillOptions._1897072727maxSolidToolDOCMult;
      }
      
      public static function set maxSolidToolDOCMult(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._1897072727maxSolidToolDOCMult;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"maxSolidToolDOCMult",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get maxSolidToolStepover() : Number
      {
         return GWizCCWMillOptions._1176081567maxSolidToolStepover;
      }
      
      public static function set maxSolidToolStepover(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._1176081567maxSolidToolStepover;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"maxSolidToolStepover",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get maxRoughToolDia() : Number
      {
         return GWizCCWMillOptions._1254650959maxRoughToolDia;
      }
      
      private static function set maxRoughToolDia(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._1254650959maxRoughToolDia;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"maxRoughToolDia",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get maxIdxRoughToolDia() : Number
      {
         return GWizCCWMillOptions._1281443364maxIdxRoughToolDia;
      }
      
      private static function set maxIdxRoughToolDia(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._1281443364maxIdxRoughToolDia;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"maxIdxRoughToolDia",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get idxRoughFlutes() : Number
      {
         return GWizCCWMillOptions._1853292433idxRoughFlutes;
      }
      
      private static function set idxRoughFlutes(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._1853292433idxRoughFlutes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"idxRoughFlutes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get maxIdxDOC() : Number
      {
         return GWizCCWMillOptions._877947969maxIdxDOC;
      }
      
      private static function set maxIdxDOC(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._877947969maxIdxDOC;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"maxIdxDOC",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get maxFaceToolDia() : Number
      {
         return GWizCCWMillOptions._565713245maxFaceToolDia;
      }
      
      private static function set maxFaceToolDia(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._565713245maxFaceToolDia;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"maxFaceToolDia",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get faceMillFlutes() : Number
      {
         return GWizCCWMillOptions._30791372faceMillFlutes;
      }
      
      private static function set faceMillFlutes(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._30791372faceMillFlutes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"faceMillFlutes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get maxFaceDOC() : Number
      {
         return GWizCCWMillOptions._81564567maxFaceDOC;
      }
      
      private static function set maxFaceDOC(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._81564567maxFaceDOC;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"maxFaceDOC",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get impSizes() : Boolean
      {
         return GWizCCWMillOptions._448489434impSizes;
      }
      
      private static function set impSizes(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._448489434impSizes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"impSizes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get mmSizes() : Boolean
      {
         return GWizCCWMillOptions._1154131666mmSizes;
      }
      
      private static function set mmSizes(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._1154131666mmSizes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"mmSizes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get roughStrat() : int
      {
         return GWizCCWMillOptions._1960055573roughStrat;
      }
      
      public static function set roughStrat(param1:int) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWMillOptions._1960055573roughStrat;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWMillOptions,"roughStrat",_loc2_,param1));
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
      
      private function onCC() : void
      {
         theSolidCribDropdown = this.SolidCrib;
         this.callLater(this.recalc);
         this.useCribs.selected = GWizCCWSettings.toolCribToolSelection;
         creationComplete = true;
      }
      
      private function recalc() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(creationComplete && this.MaxToolDia)
         {
            this.nonCribToolSpecs.enabled = true;
            if(GWizCribList.ccwCribList)
            {
               this.nonCribToolSpecs.enabled = !this.useCribs.selected || GWizCribList.ccwCribList.length <= 0;
            }
            _maxToolDiameter = this.MaxToolDia.getVal();
            maxSolidToolDOCMult = this.MaxSolidToolDOCMult.getVal();
            maxRoughToolDia = this.MaxRoughToolDia.getVal();
            maxIdxRoughToolDia = this.MaxIdxRoughToolDia.getVal();
            maxIdxDOC = this.MaxIdxDOC.getVal();
            idxRoughFlutes = this.IdxRoughFlutes.getVal();
            maxFaceToolDia = this.MaxFaceToolDia.getVal();
            faceMillFlutes = this.FaceMillFlutes.getVal();
            maxFaceDOC = this.MaxFaceDOC.getVal();
            impSizes = this.ImpSizes.selected;
            mmSizes = this.MMSizes.selected;
            StepoverSlider = Math.max(Number(this.GasPedal.value) / 100,0.5);
            GasPedalSlider = this.GasPedal.value;
            GWizCCWSettings.toolCribToolSelection = this.useCribs.selected;
            if(prefsSolidCribName && prefsSolidCribName != "" && this.SolidCrib && this.SolidCrib.dataProvider)
            {
               _loc1_ = 0;
               while(_loc1_ < this.SolidCrib.dataProvider.length)
               {
                  _loc2_ = this.SolidCrib.dataProvider.getItemAt(_loc1_);
                  if(_loc2_.tabname == prefsSolidCribName)
                  {
                     this.SolidCrib.selectedIndex = _loc1_;
                     SolidCribName = prefsSolidCribName;
                     prefsSolidCribName = null;
                     break;
                  }
                  _loc1_++;
               }
            }
            if(this.SolidCrib && this.SolidCrib.selectedItem)
            {
               SolidCribName = this.SolidCrib.selectedItem.tabname;
            }
            else
            {
               SolidCribName = GWizCribList.NO_CRIB;
            }
         }
         else
         {
            this.callLater(this.recalc);
         }
      }
      
      private function changeRoughing() : void
      {
         roughStrat = this.RoughStrat.selectedIndex;
      }
      
      public function getMaxSolidToolStepover() : Number
      {
         var _loc1_:Number = this.MaxSolidToolStepover.getVal() / 100;
         if(GWizMachSettings.currMachineSafeMode())
         {
            _loc1_ = Math.min(_loc1_,0.4);
         }
         return _loc1_;
      }
      
      private function addCCWCrib() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(this.SolidCrib && this.SolidCrib.selectedIndex > 0)
         {
            _loc1_ = 0;
            if(this.cribListUI && this.cribListUI.selectedIndex >= 0)
            {
               _loc1_ = this.cribListUI.selectedIndex + 1;
            }
            _loc2_ = this.SolidCrib.selectedItem;
            GWizCribList.ccwCribListAdd(_loc2_,_loc1_);
         }
         this.recalc();
      }
      
      private function delCCWCrib() : void
      {
         if(this.cribListUI && this.cribListUI.selectedIndex >= 0)
         {
            GWizCribList.ccwCribListDel(this.cribListUI.selectedIndex);
         }
      }
      
      private function upCCWCrib() : void
      {
         if(this.cribListUI && this.cribListUI.selectedIndex >= 0)
         {
            GWizCribList.ccwCribListUp(this.cribListUI.selectedIndex);
         }
      }
      
      private function downCCWCrib() : void
      {
         if(this.cribListUI && this.cribListUI.selectedIndex >= 0)
         {
            GWizCribList.ccwCribListDown(this.cribListUI.selectedIndex);
         }
      }
      
      public function showMe() : void
      {
         var _loc1_:Boolean = GWizAbstractPrefs.lockSharedFiles(true);
         if(_loc1_)
         {
            this.enabled = false;
         }
      }
      
      public function hideMe() : void
      {
         GWizAbstractPrefs.lockSharedFiles(false);
         this.enabled = true;
      }
      
      private function _GWizCCWMillOptions_RadioButtonGroup3_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"ChamferOptions");
         this.ChamferOptions = _loc1_;
         BindingManager.executeBindings(this,"ChamferOptions",this.ChamferOptions);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"FinishType");
         this.FinishType = _loc1_;
         BindingManager.executeBindings(this,"FinishType",this.FinishType);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_RadioButtonGroup2_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"RecalcOptions");
         this.RecalcOptions = _loc1_;
         BindingManager.executeBindings(this,"RecalcOptions",this.RecalcOptions);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_GWizForePanel1_c(),this._GWizCCWMillOptions_GWizForePanel2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 50;
         _loc1_.percentHeight = 100;
         _loc1_.title = "Solid Tools";
         _loc1_.labelWidth = 120;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWMillOptions_Array3_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Array3_c() : Array
      {
         return [this._GWizCCWMillOptions_VGroup2_c()];
      }
      
      private function _GWizCCWMillOptions_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_HGroup2_c(),this._GWizCCWMillOptions_Label2_i(),this._GWizCCWMillOptions_VGroup3_i(),this._GWizCCWMillOptions_GWizNumStep3_i(),this._GWizCCWMillOptions_GWizNumStep4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_Label1_i(),this._GWizCCWMillOptions_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Default Roughing:";
         _loc1_.toolTip = "Roughing Strategy allows toolchanges and better toolpaths to improve roughing performance.";
         _loc1_.id = "roughLbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.roughLbl = _loc1_;
         BindingManager.executeBindings(this,"roughLbl",this.roughLbl);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "name";
         _loc1_.typicalItem = "Large Corncob Rougher + HSM";
         _loc1_.toolTip = "Roughing Strategy allows toolchanges and better toolpaths to improve roughing performance.";
         _loc1_.addEventListener("change",this.__RoughStrat_change);
         _loc1_.id = "RoughStrat";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RoughStrat = _loc1_;
         BindingManager.executeBindings(this,"RoughStrat",this.RoughStrat);
         return _loc1_;
      }
      
      public function __RoughStrat_change(param1:IndexChangeEvent) : void
      {
         this.changeRoughing();
      }
      
      private function _GWizCCWMillOptions_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "No Crib Tools:";
         _loc1_.id = "AnyTool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AnyTool = _loc1_;
         BindingManager.executeBindings(this,"AnyTool",this.AnyTool);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_VGroup3_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_HGroup3_c(),this._GWizCCWMillOptions_GWizNumStep2_i()];
         _loc1_.id = "nonCribToolSpecs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.nonCribToolSpecs = _loc1_;
         BindingManager.executeBindings(this,"nonCribToolSpecs",this.nonCribToolSpecs);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_GWizNumStep1_i(),this._GWizCCWMillOptions_CheckBox1_i(),this._GWizCCWMillOptions_CheckBox2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "    Max Roughing Tool Dia.:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.toolTip = "Max Rougher diameter when Larger rougher is chosen from Roughing Strategy.";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__MaxRoughToolDia_valueCommit);
         _loc1_.id = "MaxRoughToolDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MaxRoughToolDia = _loc1_;
         BindingManager.executeBindings(this,"MaxRoughToolDia",this.MaxRoughToolDia);
         return _loc1_;
      }
      
      public function __MaxRoughToolDia_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Imperial Sizes";
         _loc1_.addEventListener("valueCommit",this.__ImpSizes_valueCommit);
         _loc1_.id = "ImpSizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ImpSizes = _loc1_;
         BindingManager.executeBindings(this,"ImpSizes",this.ImpSizes);
         return _loc1_;
      }
      
      public function __ImpSizes_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Metric Sizes";
         _loc1_.addEventListener("valueCommit",this.__MMSizes_valueCommit);
         _loc1_.id = "MMSizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MMSizes = _loc1_;
         BindingManager.executeBindings(this,"MMSizes",this.MMSizes);
         return _loc1_;
      }
      
      public function __MMSizes_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "    Max Finishing Tool Dia.:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__MaxToolDia_valueCommit);
         _loc1_.id = "MaxToolDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MaxToolDia = _loc1_;
         BindingManager.executeBindings(this,"MaxToolDia",this.MaxToolDia);
         return _loc1_;
      }
      
      public function __MaxToolDia_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Max Solid Endmill Depth of Cut (Diameters):";
         _loc1_.min = 1;
         _loc1_.max = 10;
         _loc1_.steps = 1;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__MaxSolidToolDOCMult_valueCommit);
         _loc1_.id = "MaxSolidToolDOCMult";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MaxSolidToolDOCMult = _loc1_;
         BindingManager.executeBindings(this,"MaxSolidToolDOCMult",this.MaxSolidToolDOCMult);
         return _loc1_;
      }
      
      public function __MaxSolidToolDOCMult_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Max Solid Endmill Stepover (% of Diameter):";
         _loc1_.min = 1;
         _loc1_.max = 100;
         _loc1_.steps = 1;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__MaxSolidToolStepover_valueCommit);
         _loc1_.id = "MaxSolidToolStepover";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MaxSolidToolStepover = _loc1_;
         BindingManager.executeBindings(this,"MaxSolidToolStepover",this.MaxSolidToolStepover);
         return _loc1_;
      }
      
      public function __MaxSolidToolStepover_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_GWizForePanel2_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 50;
         _loc1_.percentHeight = 100;
         _loc1_.title = "Tool Crib";
         _loc1_.labelWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWMillOptions_Array8_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Array8_c() : Array
      {
         return [this._GWizCCWMillOptions_VGroup4_c()];
      }
      
      private function _GWizCCWMillOptions_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_List1_i(),this._GWizCCWMillOptions_HGroup4_c(),this._GWizCCWMillOptions_HGroup5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_List1_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.labelField = "tabname";
         _loc1_.toolTip = "CADCAM Wizards can choose tools from these cribs.  First tool that works from cribs in order listed is used.";
         _loc1_.id = "cribListUI";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cribListUI = _loc1_;
         BindingManager.executeBindings(this,"cribListUI",this.cribListUI);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_CheckBox3_i(),this._GWizCCWMillOptions_Button1_c(),this._GWizCCWMillOptions_Button2_c(),this._GWizCCWMillOptions_Spacer1_c(),this._GWizCCWMillOptions_Button3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_CheckBox3_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Use Cribs:";
         _loc1_.addEventListener("valueCommit",this.__useCribs_valueCommit);
         _loc1_.id = "useCribs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.useCribs = _loc1_;
         BindingManager.executeBindings(this,"useCribs",this.useCribs);
         return _loc1_;
      }
      
      public function __useCribs_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Up";
         _loc1_.toolTip = "Move crib up one row on the list.";
         _loc1_.addEventListener("click",this.___GWizCCWMillOptions_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCCWMillOptions_Button1_click(param1:MouseEvent) : void
      {
         this.upCCWCrib();
      }
      
      private function _GWizCCWMillOptions_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Down";
         _loc1_.toolTip = "Move crib down one row on the list.";
         _loc1_.addEventListener("click",this.___GWizCCWMillOptions_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCCWMillOptions_Button2_click(param1:MouseEvent) : void
      {
         this.downCCWCrib();
      }
      
      private function _GWizCCWMillOptions_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Button3_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Del Crib";
         _loc1_.toolTip = "Take crib off the list.";
         _loc1_.addEventListener("click",this.___GWizCCWMillOptions_Button3_click);
         _loc1_.addEventListener("valueCommit",this.___GWizCCWMillOptions_Button3_valueCommit);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCCWMillOptions_Button3_click(param1:MouseEvent) : void
      {
         this.delCCWCrib();
      }
      
      public function ___GWizCCWMillOptions_Button3_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_DropDownList2_i(),this._GWizCCWMillOptions_Button4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.percentWidth = 100;
         _loc1_.labelField = "tabname";
         _loc1_.toolTip = "Roughing and Finishing solid endmills will be chosen from this crib.";
         _loc1_.selectedIndex = 0;
         _loc1_.addEventListener("valueCommit",this.__SolidCrib_valueCommit);
         _loc1_.id = "SolidCrib";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SolidCrib = _loc1_;
         BindingManager.executeBindings(this,"SolidCrib",this.SolidCrib);
         return _loc1_;
      }
      
      public function __SolidCrib_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_Button4_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Add Crib";
         _loc1_.toolTip = "Add a crib to the list.";
         _loc1_.addEventListener("click",this.___GWizCCWMillOptions_Button4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCCWMillOptions_Button4_click(param1:MouseEvent) : void
      {
         this.addCCWCrib();
      }
      
      private function _GWizCCWMillOptions_GWizForePanel3_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Indexable Rough";
         _loc1_.labelWidth = 120;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWMillOptions_Array12_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Array12_c() : Array
      {
         return [this._GWizCCWMillOptions_VGroup5_c()];
      }
      
      private function _GWizCCWMillOptions_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_HGroup6_c(),this._GWizCCWMillOptions_GWizNumStep7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_GWizNumStep5_i(),this._GWizCCWMillOptions_GWizNumStep6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Indexable Tool Dia.:";
         _loc1_.UnitLabel = "in";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__MaxIdxRoughToolDia_valueCommit);
         _loc1_.id = "MaxIdxRoughToolDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MaxIdxRoughToolDia = _loc1_;
         BindingManager.executeBindings(this,"MaxIdxRoughToolDia",this.MaxIdxRoughToolDia);
         return _loc1_;
      }
      
      public function __MaxIdxRoughToolDia_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_GWizNumStep6_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Indexable Tool Flutes:";
         _loc1_.min = 1;
         _loc1_.max = 50;
         _loc1_.steps = 1;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__IdxRoughFlutes_valueCommit);
         _loc1_.id = "IdxRoughFlutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.IdxRoughFlutes = _loc1_;
         BindingManager.executeBindings(this,"IdxRoughFlutes",this.IdxRoughFlutes);
         return _loc1_;
      }
      
      public function __IdxRoughFlutes_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_GWizNumStep7_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Max Indexable Tool Depth of Cut:";
         _loc1_.UnitLabel = "in";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__MaxIdxDOC_valueCommit);
         _loc1_.id = "MaxIdxDOC";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MaxIdxDOC = _loc1_;
         BindingManager.executeBindings(this,"MaxIdxDOC",this.MaxIdxDOC);
         return _loc1_;
      }
      
      public function __MaxIdxDOC_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_GWizForePanel4_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Face Milling";
         _loc1_.labelWidth = 120;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWMillOptions_Array15_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Array15_c() : Array
      {
         return [this._GWizCCWMillOptions_VGroup6_c()];
      }
      
      private function _GWizCCWMillOptions_VGroup6_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_HGroup7_c(),this._GWizCCWMillOptions_GWizNumStep10_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_GWizNumStep8_i(),this._GWizCCWMillOptions_GWizNumStep9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_GWizNumStep8_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Face Mill Dia.:";
         _loc1_.UnitLabel = "in";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__MaxFaceToolDia_valueCommit);
         _loc1_.id = "MaxFaceToolDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MaxFaceToolDia = _loc1_;
         BindingManager.executeBindings(this,"MaxFaceToolDia",this.MaxFaceToolDia);
         return _loc1_;
      }
      
      public function __MaxFaceToolDia_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_GWizNumStep9_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Face Mill Tool Flutes:";
         _loc1_.min = 1;
         _loc1_.max = 50;
         _loc1_.steps = 1;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__FaceMillFlutes_valueCommit);
         _loc1_.id = "FaceMillFlutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FaceMillFlutes = _loc1_;
         BindingManager.executeBindings(this,"FaceMillFlutes",this.FaceMillFlutes);
         return _loc1_;
      }
      
      public function __FaceMillFlutes_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_GWizNumStep10_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Max Face Mill Depth of Cut:";
         _loc1_.UnitLabel = "in";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__MaxFaceDOC_valueCommit);
         _loc1_.id = "MaxFaceDOC";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MaxFaceDOC = _loc1_;
         BindingManager.executeBindings(this,"MaxFaceDOC",this.MaxFaceDOC);
         return _loc1_;
      }
      
      public function __MaxFaceDOC_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_GWizForePanel5_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Chamfer Tool";
         _loc1_.labelWidth = 120;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWMillOptions_Array18_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Array18_c() : Array
      {
         return [this._GWizCCWMillOptions_VGroup7_c()];
      }
      
      private function _GWizCCWMillOptions_VGroup7_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_HGroup8_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "baseline";
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_Label3_c(),this._GWizCCWMillOptions_RadioButton1_i(),this._GWizCCWMillOptions_RadioButton2_i(),this._GWizCCWMillOptions_GWizNumStep11_i(),this._GWizCCWMillOptions_GWizNumStep12_i(),this._GWizCCWMillOptions_CheckBox4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Chamfer Tool:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Chamfer Mill";
         _loc1_.selected = true;
         _loc1_.toolTip = "Use a Chamfer mill on chamfer operations.";
         _loc1_.id = "ChamferMill";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ChamferMill = _loc1_;
         BindingManager.executeBindings(this,"ChamferMill",this.ChamferMill);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Spot Drill";
         _loc1_.toolTip = "Use a Spot drill on chamfer operations. Holes always use Spot Drill.";
         _loc1_.id = "ChamferSpotDrill";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ChamferSpotDrill = _loc1_;
         BindingManager.executeBindings(this,"ChamferSpotDrill",this.ChamferSpotDrill);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_GWizNumStep11_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Chamfer Tool Dia.:";
         _loc1_.UnitLabel = "in";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__ChamferToolDia_valueCommit);
         _loc1_.addEventListener("initialize",this.__ChamferToolDia_initialize);
         _loc1_.id = "ChamferToolDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ChamferToolDia = _loc1_;
         BindingManager.executeBindings(this,"ChamferToolDia",this.ChamferToolDia);
         return _loc1_;
      }
      
      public function __ChamferToolDia_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function __ChamferToolDia_initialize(param1:FlexEvent) : void
      {
         this.ChamferToolDia.setVal(0.375);
      }
      
      private function _GWizCCWMillOptions_GWizNumStep12_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Chamfer Tool Flutes:";
         _loc1_.min = 1;
         _loc1_.max = 50;
         _loc1_.steps = 1;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__ChamferToolFlutes_valueCommit);
         _loc1_.addEventListener("initialize",this.__ChamferToolFlutes_initialize);
         _loc1_.id = "ChamferToolFlutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ChamferToolFlutes = _loc1_;
         BindingManager.executeBindings(this,"ChamferToolFlutes",this.ChamferToolFlutes);
         return _loc1_;
      }
      
      public function __ChamferToolFlutes_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function __ChamferToolFlutes_initialize(param1:FlexEvent) : void
      {
         this.ChamferToolFlutes.setVal(4);
      }
      
      private function _GWizCCWMillOptions_CheckBox4_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Carbide";
         _loc1_.selected = true;
         _loc1_.toolTip = "Uncheck if chamfer tool is HSS.";
         _loc1_.id = "ChamferToolCarbide";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ChamferToolCarbide = _loc1_;
         BindingManager.executeBindings(this,"ChamferToolCarbide",this.ChamferToolCarbide);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_GWizForePanel6_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Other";
         _loc1_.labelWidth = 120;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWMillOptions_Array21_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Array21_c() : Array
      {
         return [this._GWizCCWMillOptions_VGroup8_c()];
      }
      
      private function _GWizCCWMillOptions_VGroup8_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_HGroup9_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_HGroup9_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "baseline";
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_CheckBox5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_CheckBox5_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Use Premium Coolant Options";
         _loc1_.addEventListener("valueCommit",this.__usePremCoolant_valueCommit);
         _loc1_.id = "usePremCoolant";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.usePremCoolant = _loc1_;
         BindingManager.executeBindings(this,"usePremCoolant",this.usePremCoolant);
         return _loc1_;
      }
      
      public function __usePremCoolant_valueCommit(param1:FlexEvent) : void
      {
         usePremiumCoolantOptions = this.usePremCoolant.selected;
      }
      
      private function _GWizCCWMillOptions_VGroup9_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_Group1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Group1_c() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_Rect1_c(),this._GWizCCWMillOptions_HGroup10_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.radiusX = 3;
         _loc1_.fill = this._GWizCCWMillOptions_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_HGroup10_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingBottom = 6;
         _loc1_.paddingTop = 6;
         _loc1_.paddingLeft = 6;
         _loc1_.paddingRight = 6;
         _loc1_.mxmlContent = [this._GWizCCWMillOptions_Label4_c(),this._GWizCCWMillOptions_Image1_i(),this._GWizCCWMillOptions_HSlider1_i(),this._GWizCCWMillOptions_Image2_i(),this._GWizCCWMillOptions_Label5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWMillOptions_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Conservative";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.toolTip = "Emphasize tool life and surface finish";
         _loc1_.setStyle("color",16777215);
         _loc1_.addEventListener("click",this.___GWizCCWMillOptions_Label4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCCWMillOptions_Label4_click(param1:MouseEvent) : void
      {
         this.GasPedal.value = 1;
      }
      
      private function _GWizCCWMillOptions_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.toolTip = "Emphasize tool life and surface finish";
         _loc1_.addEventListener("click",this.___GWizCCWMillOptions_Image1_click);
         _loc1_.id = "_GWizCCWMillOptions_Image1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWMillOptions_Image1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWMillOptions_Image1",this._GWizCCWMillOptions_Image1);
         return _loc1_;
      }
      
      public function ___GWizCCWMillOptions_Image1_click(param1:MouseEvent) : void
      {
         this.GasPedal.value = 1;
      }
      
      private function _GWizCCWMillOptions_HSlider1_i() : HSlider
      {
         var _loc1_:HSlider = new HSlider();
         _loc1_.snapInterval = 1;
         _loc1_.minimum = 1;
         _loc1_.setStyle("liveDragging",false);
         _loc1_.addEventListener("change",this.__GasPedal_change);
         _loc1_.id = "GasPedal";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GasPedal = _loc1_;
         BindingManager.executeBindings(this,"GasPedal",this.GasPedal);
         return _loc1_;
      }
      
      public function __GasPedal_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWMillOptions_Image2_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.toolTip = "Maximize MRR";
         _loc1_.addEventListener("click",this.___GWizCCWMillOptions_Image2_click);
         _loc1_.id = "_GWizCCWMillOptions_Image2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWMillOptions_Image2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWMillOptions_Image2",this._GWizCCWMillOptions_Image2);
         return _loc1_;
      }
      
      public function ___GWizCCWMillOptions_Image2_click(param1:MouseEvent) : void
      {
         this.GasPedal.value = GWizTortHare.GAS_PEDAL_MAX;
      }
      
      private function _GWizCCWMillOptions_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Aggressive";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.toolTip = "Maximize MRR";
         _loc1_.setStyle("color",16777215);
         _loc1_.addEventListener("click",this.___GWizCCWMillOptions_Label5_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCCWMillOptions_Label5_click(param1:MouseEvent) : void
      {
         this.GasPedal.value = GWizTortHare.GAS_PEDAL_MAX;
      }
      
      public function ___GWizCCWMillOptions_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCCWMillOptions_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizCCWRecalc.roughingStrategies;
         },null,"RoughStrat.dataProvider");
         result[1] = new Binding(this,function():int
         {
            return roughStrat;
         },null,"RoughStrat.selectedIndex");
         result[2] = new Binding(this,function():Number
         {
            return maxRoughToolDia;
         },null,"MaxRoughToolDia.value");
         result[3] = new Binding(this,function():Boolean
         {
            return impSizes;
         },null,"ImpSizes.selected");
         result[4] = new Binding(this,function():Boolean
         {
            return mmSizes;
         },null,"MMSizes.selected");
         result[5] = new Binding(this,function():Number
         {
            return maxToolDia;
         },null,"MaxToolDia.value");
         result[6] = new Binding(this,function():Number
         {
            return maxSolidToolDOCMult;
         },null,"MaxSolidToolDOCMult.value");
         result[7] = new Binding(this,function():Number
         {
            return maxSolidToolStepover;
         },null,"MaxSolidToolStepover.value");
         result[8] = new Binding(this,function():Boolean
         {
            return GWizCCWSettings.toolCribToolSelection;
         },null,"cribListUI.enabled");
         result[9] = new Binding(this,function():IList
         {
            return GWizCribList.ccwCribList;
         },null,"cribListUI.dataProvider");
         result[10] = new Binding(this,function():Boolean
         {
            return GWizCCWSettings.toolCribToolSelection;
         },null,"useCribs.selected");
         result[11] = new Binding(this,function():IList
         {
            return GWizCribList.cribListPlus;
         },null,"SolidCrib.dataProvider");
         result[12] = new Binding(this,function():Number
         {
            return maxIdxRoughToolDia;
         },null,"MaxIdxRoughToolDia.value");
         result[13] = new Binding(this,function():Number
         {
            return idxRoughFlutes;
         },null,"IdxRoughFlutes.value");
         result[14] = new Binding(this,function():Number
         {
            return maxIdxDOC;
         },null,"MaxIdxDOC.value");
         result[15] = new Binding(this,function():Number
         {
            return maxFaceToolDia;
         },null,"MaxFaceToolDia.value");
         result[16] = new Binding(this,function():Number
         {
            return faceMillFlutes;
         },null,"FaceMillFlutes.value");
         result[17] = new Binding(this,function():Number
         {
            return maxFaceDOC;
         },null,"MaxFaceDOC.value");
         result[18] = new Binding(this,null,null,"ChamferMill.group","ChamferOptions");
         result[19] = new Binding(this,null,null,"ChamferSpotDrill.group","ChamferOptions");
         result[20] = new Binding(this,function():Boolean
         {
            return usePremiumCoolantOptions;
         },null,"usePremCoolant.selected");
         result[21] = new Binding(this,function():Object
         {
            return GWizSettings.TortoiseImg;
         },null,"_GWizCCWMillOptions_Image1.source");
         result[22] = new Binding(this,function():Number
         {
            return GWizTortHare.GAS_PEDAL_MAX;
         },null,"GasPedal.maximum");
         result[23] = new Binding(this,function():Number
         {
            return _GasPedalSlider;
         },null,"GasPedal.value");
         result[24] = new Binding(this,function():Object
         {
            return GWizSettings.HareImg;
         },null,"_GWizCCWMillOptions_Image2.source");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get AnyTool() : Label
      {
         return this._821762436AnyTool;
      }
      
      public function set AnyTool(param1:Label) : void
      {
         var _loc2_:Object = this._821762436AnyTool;
         if(_loc2_ !== param1)
         {
            this._821762436AnyTool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AnyTool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ChamferMill() : RadioButton
      {
         return this._1694435774ChamferMill;
      }
      
      public function set ChamferMill(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1694435774ChamferMill;
         if(_loc2_ !== param1)
         {
            this._1694435774ChamferMill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ChamferMill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ChamferOptions() : RadioButtonGroup
      {
         return this._2126633540ChamferOptions;
      }
      
      public function set ChamferOptions(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._2126633540ChamferOptions;
         if(_loc2_ !== param1)
         {
            this._2126633540ChamferOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ChamferOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ChamferSpotDrill() : RadioButton
      {
         return this._2092478441ChamferSpotDrill;
      }
      
      public function set ChamferSpotDrill(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2092478441ChamferSpotDrill;
         if(_loc2_ !== param1)
         {
            this._2092478441ChamferSpotDrill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ChamferSpotDrill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ChamferToolCarbide() : CheckBox
      {
         return this._556323774ChamferToolCarbide;
      }
      
      public function set ChamferToolCarbide(param1:CheckBox) : void
      {
         var _loc2_:Object = this._556323774ChamferToolCarbide;
         if(_loc2_ !== param1)
         {
            this._556323774ChamferToolCarbide = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ChamferToolCarbide",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ChamferToolDia() : GWizNumStep
      {
         return this._2017281310ChamferToolDia;
      }
      
      public function set ChamferToolDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2017281310ChamferToolDia;
         if(_loc2_ !== param1)
         {
            this._2017281310ChamferToolDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ChamferToolDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ChamferToolFlutes() : GWizNumStep
      {
         return this._1584361171ChamferToolFlutes;
      }
      
      public function set ChamferToolFlutes(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1584361171ChamferToolFlutes;
         if(_loc2_ !== param1)
         {
            this._1584361171ChamferToolFlutes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ChamferToolFlutes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FaceMillFlutes() : GWizNumStep
      {
         return this._971201812FaceMillFlutes;
      }
      
      public function set FaceMillFlutes(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._971201812FaceMillFlutes;
         if(_loc2_ !== param1)
         {
            this._971201812FaceMillFlutes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FaceMillFlutes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FinishType() : RadioButtonGroup
      {
         return this._1149965683FinishType;
      }
      
      public function set FinishType(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1149965683FinishType;
         if(_loc2_ !== param1)
         {
            this._1149965683FinishType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FinishType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GasPedal() : HSlider
      {
         return this._1551631807GasPedal;
      }
      
      public function set GasPedal(param1:HSlider) : void
      {
         var _loc2_:Object = this._1551631807GasPedal;
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
      public function get IdxRoughFlutes() : GWizNumStep
      {
         return this._1439681679IdxRoughFlutes;
      }
      
      public function set IdxRoughFlutes(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1439681679IdxRoughFlutes;
         if(_loc2_ !== param1)
         {
            this._1439681679IdxRoughFlutes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IdxRoughFlutes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ImpSizes() : CheckBox
      {
         return this._383845306ImpSizes;
      }
      
      public function set ImpSizes(param1:CheckBox) : void
      {
         var _loc2_:Object = this._383845306ImpSizes;
         if(_loc2_ !== param1)
         {
            this._383845306ImpSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ImpSizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MMSizes() : CheckBox
      {
         return this._1902652114MMSizes;
      }
      
      public function set MMSizes(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1902652114MMSizes;
         if(_loc2_ !== param1)
         {
            this._1902652114MMSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MMSizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MaxFaceDOC() : GWizNumStep
      {
         return this._2075029431MaxFaceDOC;
      }
      
      public function set MaxFaceDOC(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2075029431MaxFaceDOC;
         if(_loc2_ !== param1)
         {
            this._2075029431MaxFaceDOC = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MaxFaceDOC",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MaxFaceToolDia() : GWizNumStep
      {
         return this._1567706429MaxFaceToolDia;
      }
      
      public function set MaxFaceToolDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1567706429MaxFaceToolDia;
         if(_loc2_ !== param1)
         {
            this._1567706429MaxFaceToolDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MaxFaceToolDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MaxIdxDOC() : GWizNumStep
      {
         return this._1126019999MaxIdxDOC;
      }
      
      public function set MaxIdxDOC(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1126019999MaxIdxDOC;
         if(_loc2_ !== param1)
         {
            this._1126019999MaxIdxDOC = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MaxIdxDOC",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MaxIdxRoughToolDia() : GWizNumStep
      {
         return this._1171979708MaxIdxRoughToolDia;
      }
      
      public function set MaxIdxRoughToolDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1171979708MaxIdxRoughToolDia;
         if(_loc2_ !== param1)
         {
            this._1171979708MaxIdxRoughToolDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MaxIdxRoughToolDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MaxRoughToolDia() : GWizNumStep
      {
         return this._257633327MaxRoughToolDia;
      }
      
      public function set MaxRoughToolDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._257633327MaxRoughToolDia;
         if(_loc2_ !== param1)
         {
            this._257633327MaxRoughToolDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MaxRoughToolDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MaxSolidToolDOCMult() : GWizNumStep
      {
         return this._643776631MaxSolidToolDOCMult;
      }
      
      public function set MaxSolidToolDOCMult(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._643776631MaxSolidToolDOCMult;
         if(_loc2_ !== param1)
         {
            this._643776631MaxSolidToolDOCMult = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MaxSolidToolDOCMult",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MaxSolidToolStepover() : GWizNumStep
      {
         return this._1373554879MaxSolidToolStepover;
      }
      
      public function set MaxSolidToolStepover(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1373554879MaxSolidToolStepover;
         if(_loc2_ !== param1)
         {
            this._1373554879MaxSolidToolStepover = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MaxSolidToolStepover",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MaxToolDia() : GWizNumStep
      {
         return this._2027278816MaxToolDia;
      }
      
      public function set MaxToolDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2027278816MaxToolDia;
         if(_loc2_ !== param1)
         {
            this._2027278816MaxToolDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MaxToolDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RecalcOptions() : RadioButtonGroup
      {
         return this._1694867030RecalcOptions;
      }
      
      public function set RecalcOptions(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1694867030RecalcOptions;
         if(_loc2_ !== param1)
         {
            this._1694867030RecalcOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RecalcOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RoughStrat() : DropDownList
      {
         return this._33409291RoughStrat;
      }
      
      public function set RoughStrat(param1:DropDownList) : void
      {
         var _loc2_:Object = this._33409291RoughStrat;
         if(_loc2_ !== param1)
         {
            this._33409291RoughStrat = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RoughStrat",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SolidCrib() : DropDownList
      {
         return this._650225395SolidCrib;
      }
      
      public function set SolidCrib(param1:DropDownList) : void
      {
         var _loc2_:Object = this._650225395SolidCrib;
         if(_loc2_ !== param1)
         {
            this._650225395SolidCrib = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SolidCrib",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cribListUI() : List
      {
         return this._502514790cribListUI;
      }
      
      public function set cribListUI(param1:List) : void
      {
         var _loc2_:Object = this._502514790cribListUI;
         if(_loc2_ !== param1)
         {
            this._502514790cribListUI = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cribListUI",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get nonCribToolSpecs() : VGroup
      {
         return this._1117124949nonCribToolSpecs;
      }
      
      public function set nonCribToolSpecs(param1:VGroup) : void
      {
         var _loc2_:Object = this._1117124949nonCribToolSpecs;
         if(_loc2_ !== param1)
         {
            this._1117124949nonCribToolSpecs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"nonCribToolSpecs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get roughLbl() : Label
      {
         return this._6516163roughLbl;
      }
      
      public function set roughLbl(param1:Label) : void
      {
         var _loc2_:Object = this._6516163roughLbl;
         if(_loc2_ !== param1)
         {
            this._6516163roughLbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"roughLbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get useCribs() : CheckBox
      {
         return this._308992412useCribs;
      }
      
      public function set useCribs(param1:CheckBox) : void
      {
         var _loc2_:Object = this._308992412useCribs;
         if(_loc2_ !== param1)
         {
            this._308992412useCribs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"useCribs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get usePremCoolant() : CheckBox
      {
         return this._240493677usePremCoolant;
      }
      
      public function set usePremCoolant(param1:CheckBox) : void
      {
         var _loc2_:Object = this._240493677usePremCoolant;
         if(_loc2_ !== param1)
         {
            this._240493677usePremCoolant = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"usePremCoolant",_loc2_,param1));
            }
         }
      }
   }
}
