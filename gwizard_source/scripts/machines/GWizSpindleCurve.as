package machines
{
   import comps.GWizDataGrid;
   import comps.GWizGridColumn;
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.charts.Legend;
   import mx.charts.LineChart;
   import mx.charts.series.LineSeries;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.IStroke;
   import mx.graphics.SolidColorStroke;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.TileGroup;
   import spark.components.VGroup;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizSpindleCurve extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizSpindleCurve");
      
      private static var powerACSaver:ArrayCollection = new ArrayCollection();
      
      public static const NO_ADJUST:int = 0;
      
      public static const WEIGHT_ADJUST:int = 1;
      
      public static const CURVE_ADJUST:int = 2;
      
      private static var _adjustMode:int = NO_ADJUST;
      
      private static var _2074386032_vmcRigidity:Boolean = true;
      
      private static var _2003409266adjustMsg:String = "No Adjustment";
      
      public static var machHP:Number = 0;
      
      public static var machWeight:Number = 0;
      
      public static var xTravel:Number = 0;
      
      public static var yTravel:Number = 0;
      
      public static var zTravel:Number = 0;
      
      public static const SPINDLE_CURVE:String = "SpindleCurve";
      
      private static var _387947545powerAC:ArrayCollection = new ArrayCollection();
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _652010178CurveAdjust:RadioButton;
      
      private var _67232232Error:Label;
      
      private var _185434320NoAdjust:RadioButton;
      
      private var _402739664RouterWeightAdjust:RadioButton;
      
      private var _1633880755VMCWeightAdjust:RadioButton;
      
      private var _710082489WeightAdjust:RadioButton;
      
      public var _GWizSpindleCurve_Legend1:Legend;
      
      public var _GWizSpindleCurve_LineSeries1:LineSeries;
      
      private var _92659049addHP:GWizNumStep;
      
      private var _1422527090addRPM:NumericStepper;
      
      private var _92664815adjHP:Label;
      
      private var _1792737174linechart:LineChart;
      
      private var _982754077points:GWizDataGrid;
      
      private var _164873549radiogroup1:RadioButtonGroup;
      
      private var _164873550radiogroup2:RadioButtonGroup;
      
      private var _3614s1:SolidColorStroke;
      
      private var _1497681657trialRPM:NumericStepper;
      
      private var _1334614739trialResult:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var adjustModeSaver:int;
      
      private var saveToMachine:Function = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizSpindleCurve()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.adjustModeSaver = adjustMode;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizSpindleCurve_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_machines_GWizSpindleCurveWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizSpindleCurve[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Spindle Power Curve";
         this.okLabel = "Save";
         this.mxmlContent = [this._GWizSpindleCurve_RadioButton1_i(),this._GWizSpindleCurve_HGroup1_c(),this._GWizSpindleCurve_RadioButton5_i(),this._GWizSpindleCurve_HGroup2_c()];
         this._GWizSpindleCurve_RadioButtonGroup1_i();
         this._GWizSpindleCurve_RadioButtonGroup2_i();
         this._GWizSpindleCurve_SolidColorStroke1_i();
         this.addEventListener("creationComplete",this.___GWizSpindleCurve_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set adjustMode(param1:int) : void
      {
         _adjustMode = param1;
         adjustMsg = adjustType();
      }
      
      public static function get adjustMode() : int
      {
         return _adjustMode;
      }
      
      public static function set vmcRigidity(param1:Boolean) : void
      {
         _vmcRigidity = param1;
      }
      
      public static function get vmcRigidity() : Boolean
      {
         return _vmcRigidity;
      }
      
      private static function adjustType() : String
      {
         var _loc1_:String = "";
         switch(adjustMode)
         {
            case NO_ADJUST:
               _loc1_ = "No Adjustment";
               break;
            case WEIGHT_ADJUST:
               _loc1_ = "Weight Adjusted";
               break;
            case CURVE_ADJUST:
               _loc1_ = "Power Curve Adjusted";
         }
         return _loc1_;
      }
      
      public static function calcHP(param1:Number, param2:Number, param3:Boolean) : Number
      {
         var _loc4_:Number = 0;
         var _loc5_:Object = GWizMachSettings.lookupMachine(GWizMachSettings.currMachine);
         var _loc6_:Number = GWizSettings.prefs.lastGWLiteHP;
         if(GWizMachSettings.currMachType == "Lathe" && _loc6_ < 2)
         {
            _loc6_ *= 2;
         }
         param2 = Math.min(param2,_loc6_);
         if(adjustMode != CURVE_ADJUST || powerAC.length < 2)
         {
            _loc4_ = weightAdjHP(_loc5_.hpLimit,_loc5_.weight,_loc5_.xTravel,_loc5_.yTravel,param3,adjustMode == WEIGHT_ADJUST);
            GWizSettings.prefs.liteMode = _loc4_ > _loc6_;
            _loc4_ = Math.min(_loc4_,_loc6_);
            return Number(Math.max(_loc4_,param2));
         }
         if(param1 > 0)
         {
            _loc4_ = interpolateHPFromPoints(param1,_loc5_.hpLimit);
         }
         else
         {
            _loc4_ = _loc5_.hpLimit;
         }
         GWizSettings.prefs.liteMode = _loc4_ > _loc6_;
         _loc4_ = Math.min(_loc4_,_loc6_);
         return Number(Math.max(_loc4_,param2));
      }
      
      private static function weightAdjHP(param1:Number, param2:Number, param3:Number, param4:Number, param5:Boolean, param6:Boolean = true) : Number
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc7_:Number = 486;
         var _loc8_:Number = 1.6;
         machHP = param1;
         machWeight = param2;
         GWizSpindleCurve.xTravel = param3;
         GWizSpindleCurve.yTravel = param4;
         var _loc9_:Number = param1;
         if(param6 && param5 && param1 != 0 && param2 != 0 && param3 != 0 && param4 != 0)
         {
            if((_loc10_ = param2) < 3000)
            {
               _loc16_ = GWizUtils.interpolate(500,0.4,_loc10_,3900,1);
               _loc10_ *= _loc16_;
            }
            _loc11_ = _loc10_ / param1;
            _loc12_ = param3 * param4;
            _loc15_ = (_loc14_ = (_loc13_ = _loc8_ * _loc10_) / _loc12_) * _loc11_;
            _loc9_ = Math.min(param1,param1 * (_loc15_ / _loc7_));
            if(!isNaN(_loc9_))
            {
               _loc9_ = Number(GWizUtils.roundHundredths(_loc9_));
            }
            else
            {
               _loc9_ = param1;
            }
            if(!_vmcRigidity)
            {
               _loc9_ *= 12;
               _loc9_ = Math.min(_loc9_,param1);
            }
         }
         return _loc9_;
      }
      
      private static function setLoPeakHi(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         powerAC.removeAll();
         var _loc7_:Object;
         (_loc7_ = new Object()).RPM = param1;
         _loc7_.HP = param2;
         powerAC.addItem(_loc7_);
         var _loc8_:Object;
         (_loc8_ = new Object()).RPM = param3;
         _loc8_.HP = param4;
         powerAC.addItem(_loc8_);
         var _loc9_:Object;
         (_loc9_ = new Object()).RPM = param5;
         _loc9_.HP = param6;
         powerAC.addItem(_loc9_);
         GWizUtils.arrayCollectionSort(powerAC,"RPM",true);
      }
      
      public static function setSpindleCurve(param1:Object) : void
      {
         var _loc2_:* = false;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:ArrayCollection = null;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Object = null;
         if(param1.hasOwnProperty(SPINDLE_CURVE + "0" + "RPM"))
         {
            _loc2_ = false;
            _loc3_ = 0;
            powerAC.removeAll();
            _loc2_ = !param1.hasOwnProperty(SPINDLE_CURVE + _loc3_ + "RPM");
            while(!_loc2_)
            {
               _loc2_ = !param1.hasOwnProperty(SPINDLE_CURVE + _loc3_ + "RPM");
               _loc7_ = new Object();
               _loc8_ = param1[SPINDLE_CURVE + _loc3_ + "RPM"];
               _loc9_ = param1[SPINDLE_CURVE + _loc3_ + "HP"];
               _loc7_.RPM = _loc8_;
               _loc7_.HP = _loc9_;
               _loc7_.KW = _loc9_ * GWizUtils.KW_PER_HP;
               if(!isNaN(_loc8_) && !isNaN(_loc9_) && _loc4_ != _loc8_)
               {
                  powerAC.addItem(_loc7_);
               }
               _loc3_++;
               _loc4_ = _loc8_;
               _loc2_ = !param1.hasOwnProperty(SPINDLE_CURVE + _loc3_ + "RPM");
               _loc2_ = Boolean(_loc2_ && _loc3_ < 100);
            }
            GWizUtils.arrayCollectionSort(powerAC,"RPM",true);
            _loc4_ = NaN;
            _loc5_ = new ArrayCollection();
            _loc6_ = 0;
            while(_loc6_ < powerAC.length)
            {
               if((_loc10_ = powerAC.getItemAt(_loc6_)).RPM != _loc4_)
               {
                  _loc5_.addItem(_loc10_);
                  _loc4_ = _loc10_.RPM;
               }
               _loc6_++;
            }
            powerAC = _loc5_;
         }
         else if(param1.hasOwnProperty("loRPM"))
         {
            setLoPeakHi(param1.loRPM,param1.loHP,param1.peakRPM,param1.peakHP,param1.hiRPM,param1.hiHP);
         }
      }
      
      public static function getSpindleCurve(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         _loc2_ = 0;
         while(_loc2_ < powerAC.length)
         {
            _loc3_ = powerAC.getItemAt(_loc2_);
            param1[SPINDLE_CURVE + _loc2_ + "RPM"] = _loc3_.RPM;
            param1[SPINDLE_CURVE + _loc2_ + "HP"] = _loc3_.HP;
            _loc2_++;
         }
      }
      
      private static function interpolateHPFromPoints(param1:Number, param2:Number) : Number
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc3_:Number = 0;
         if(powerAC.length >= 2)
         {
            GWizUtils.arrayCollectionSort(powerAC,"RPM",true);
            _loc4_ = false;
            _loc5_ = 1;
            while(_loc5_ < powerAC.length)
            {
               _loc6_ = powerAC.getItemAt(_loc5_ - 1);
               _loc7_ = powerAC.getItemAt(_loc5_);
               if(_loc6_.RPM <= param1 && param1 <= _loc7_.RPM)
               {
                  _loc3_ = GWizUtils.interpolate(_loc6_.RPM,_loc6_.HP,param1,_loc7_.RPM,_loc7_.HP);
                  _loc4_ = true;
                  break;
               }
               _loc5_++;
            }
         }
         else
         {
            _loc3_ = param2;
         }
         return _loc3_;
      }
      
      private static function unitTest() : void
      {
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizSpindleCurve._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get _vmcRigidity() : Boolean
      {
         return GWizSpindleCurve._2074386032_vmcRigidity;
      }
      
      private static function set _vmcRigidity(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSpindleCurve._2074386032_vmcRigidity;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSpindleCurve,"_vmcRigidity",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get adjustMsg() : String
      {
         return GWizSpindleCurve._2003409266adjustMsg;
      }
      
      public static function set adjustMsg(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSpindleCurve._2003409266adjustMsg;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSpindleCurve,"adjustMsg",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get powerAC() : ArrayCollection
      {
         return GWizSpindleCurve._387947545powerAC;
      }
      
      private static function set powerAC(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSpindleCurve._387947545powerAC;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSpindleCurve,"powerAC",_loc2_,param1));
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
      }
      
      public function saveDefaults() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         this.adjustModeSaver = adjustMode;
         powerACSaver.removeAll();
         var _loc1_:int = 0;
         while(_loc1_ < powerAC.length)
         {
            _loc2_ = new Object();
            _loc3_ = powerAC.getItemAt(_loc1_);
            _loc2_.HP = _loc3_.HP;
            _loc2_.RPM = _loc3_.RPM;
            powerACSaver.addItem(_loc2_);
            _loc1_++;
         }
         switch(adjustMode)
         {
            case NO_ADJUST:
               this.NoAdjust.selected = true;
               break;
            case WEIGHT_ADJUST:
               this.WeightAdjust.selected = true;
               break;
            case CURVE_ADJUST:
               this.CurveAdjust.selected = true;
         }
         this.recalc();
      }
      
      private function doSave(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(param1)
         {
            if(this.saveToMachine != null)
            {
               this.saveToMachine();
            }
         }
         else
         {
            adjustMode = this.adjustModeSaver;
            powerAC.removeAll();
            _loc2_ = 0;
            while(_loc2_ < powerACSaver.length)
            {
               _loc3_ = new Object();
               _loc4_ = powerACSaver.getItemAt(_loc2_);
               _loc3_.HP = _loc4_.HP;
               _loc3_.RPM = _loc4_.RPM;
               powerAC.addItem(_loc3_);
               _loc2_++;
            }
         }
      }
      
      private function onModeChange() : void
      {
         _vmcRigidity = this.VMCWeightAdjust.selected;
         if(this.CurveAdjust.selected)
         {
            adjustMode = CURVE_ADJUST;
            GATracker.logPageView("Setup/PowerCurve","Setup/PowerCurve");
         }
         else if(this.WeightAdjust.selected)
         {
            adjustMode = WEIGHT_ADJUST;
            GATracker.logPageView("Setup/WeightAdjust","Setup/WeightAdjust");
         }
         else
         {
            adjustMode = NO_ADJUST;
            GATracker.logPageView("Setup/NoSpindleAdjust","Setup/NoSpindleAdjust");
         }
         this.recalc();
      }
      
      private function recalc() : void
      {
         var _loc1_:Number = NaN;
         if(this.Error.text == "")
         {
            _loc1_ = calcHP(this.trialRPM.value,0,true);
            if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
            {
               this.trialResult.text = GWizUtils.roundBigTenths(String(_loc1_),false) + " HP";
            }
            else
            {
               this.trialResult.text = GWizUtils.roundBigTenths(String(_loc1_ * GWizUtils.KW_PER_HP),false) + " KW";
            }
         }
         else
         {
            this.trialResult.text = "Error";
         }
         this.doWeightHP();
      }
      
      private function doWeightHP() : void
      {
         this.adjHP.text = "";
         var _loc1_:Number = weightAdjHP(machHP,machWeight,xTravel,yTravel,true);
         if(this.RouterWeightAdjust.selected)
         {
            _loc1_ *= 12;
            _loc1_ = Math.min(_loc1_,machHP);
         }
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            this.adjHP.text = GWizUtils.roundHundredths(_loc1_) + " HP";
         }
         else
         {
            this.adjHP.text = GWizUtils.roundHundredths(_loc1_ * GWizUtils.KW_PER_HP) + " KW";
         }
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doSave(true);
         super.onOk(param1);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doSave(false);
         super.onCancel(param1);
      }
      
      private function doClearTable() : void
      {
         powerAC.removeAll();
         powerAC.refresh();
      }
      
      private function doAdd() : void
      {
         var _loc5_:Object = null;
         var _loc1_:Number = this.addRPM.value;
         var _loc2_:Number = this.addHP.value;
         var _loc3_:int = 0;
         while(_loc3_ < powerAC.length)
         {
            if((_loc5_ = powerAC.getItemAt(_loc3_)).HP == _loc2_ && _loc5_.RPM == _loc1_)
            {
               return;
            }
            _loc3_++;
         }
         var _loc4_:Object;
         (_loc4_ = new Object()).HP = _loc2_;
         _loc4_.RPM = _loc1_;
         _loc4_.KW = _loc2_ * GWizUtils.KW_PER_HP;
         powerAC.addItem(_loc4_);
         GWizUtils.arrayCollectionSort(powerAC,"RPM",true);
         powerAC.refresh();
      }
      
      private function _GWizSpindleCurve_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.addEventListener("change",this.__radiogroup1_change);
         _loc1_.initialized(this,"radiogroup1");
         this.radiogroup1 = _loc1_;
         BindingManager.executeBindings(this,"radiogroup1",this.radiogroup1);
         return _loc1_;
      }
      
      public function __radiogroup1_change(param1:Event) : void
      {
         this.onModeChange();
      }
      
      private function _GWizSpindleCurve_RadioButtonGroup2_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.addEventListener("change",this.__radiogroup2_change);
         _loc1_.addEventListener("valueCommit",this.__radiogroup2_valueCommit);
         _loc1_.initialized(this,"radiogroup2");
         this.radiogroup2 = _loc1_;
         BindingManager.executeBindings(this,"radiogroup2",this.radiogroup2);
         return _loc1_;
      }
      
      public function __radiogroup2_change(param1:Event) : void
      {
         this.onModeChange();
      }
      
      public function __radiogroup2_valueCommit(param1:FlexEvent) : void
      {
         _vmcRigidity = this.VMCWeightAdjust.selected;
      }
      
      private function _GWizSpindleCurve_SolidColorStroke1_i() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 16711680;
         _loc1_.weight = 2;
         this.s1 = _loc1_;
         BindingManager.executeBindings(this,"s1",this.s1);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Don\'t Adjust";
         _loc1_.groupName = "radiogroup1";
         _loc1_.selected = true;
         _loc1_.id = "NoAdjust";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.NoAdjust = _loc1_;
         BindingManager.executeBindings(this,"NoAdjust",this.NoAdjust);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizSpindleCurve_RadioButton2_i(),this._GWizSpindleCurve_Label1_i(),this._GWizSpindleCurve_RadioButton3_i(),this._GWizSpindleCurve_RadioButton4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Weight Adjusted HP (for small hobby machines)";
         _loc1_.groupName = "radiogroup1";
         _loc1_.toolTip = "De-rate spindle power for less rigid machines.";
         _loc1_.id = "WeightAdjust";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.WeightAdjust = _loc1_;
         BindingManager.executeBindings(this,"WeightAdjust",this.WeightAdjust);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.toolTip = "De-rated spindle power to compensate for lightweight lower rigidity machines.";
         _loc1_.id = "adjHP";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.adjHP = _loc1_;
         BindingManager.executeBindings(this,"adjHP",this.adjHP);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Adjust to VMC Rigidity";
         _loc1_.groupName = "radiogroup2";
         _loc1_.toolTip = "De-rate spindle power for less rigid machines.";
         _loc1_.id = "VMCWeightAdjust";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.VMCWeightAdjust = _loc1_;
         BindingManager.executeBindings(this,"VMCWeightAdjust",this.VMCWeightAdjust);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_RadioButton4_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Adjust to CNC Router Rigidity";
         _loc1_.groupName = "radiogroup2";
         _loc1_.toolTip = "De-rate spindle power for less rigid machines.";
         _loc1_.id = "RouterWeightAdjust";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RouterWeightAdjust = _loc1_;
         BindingManager.executeBindings(this,"RouterWeightAdjust",this.RouterWeightAdjust);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_RadioButton5_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Curve Compensate";
         _loc1_.groupName = "radiogroup1";
         _loc1_.id = "CurveAdjust";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CurveAdjust = _loc1_;
         BindingManager.executeBindings(this,"CurveAdjust",this.CurveAdjust);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizSpindleCurve_Spacer1_c(),this._GWizSpindleCurve_VGroup1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizSpindleCurve_HGroup3_c(),this._GWizSpindleCurve_Label5_i(),this._GWizSpindleCurve_Label6_c(),this._GWizSpindleCurve_HGroup4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizSpindleCurve_VGroup2_c(),this._GWizSpindleCurve_LineChart1_i(),this._GWizSpindleCurve_Legend1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizSpindleCurve_TileGroup1_c(),this._GWizSpindleCurve_GWizDataGrid1_i(),this._GWizSpindleCurve_Label4_c(),this._GWizSpindleCurve_Button2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_TileGroup1_c() : TileGroup
      {
         var _loc1_:TileGroup = new TileGroup();
         _loc1_.requestedColumnCount = 3;
         _loc1_.mxmlContent = [this._GWizSpindleCurve_Spacer2_c(),this._GWizSpindleCurve_Label2_c(),this._GWizSpindleCurve_Label3_c(),this._GWizSpindleCurve_Button1_c(),this._GWizSpindleCurve_NumericStepper1_i(),this._GWizSpindleCurve_GWizNumStep1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "RPM";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Power";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Add";
         _loc1_.addEventListener("click",this.___GWizSpindleCurve_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizSpindleCurve_Button1_click(param1:MouseEvent) : void
      {
         this.doAdd();
      }
      
      private function _GWizSpindleCurve_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 100000;
         _loc1_.stepSize = 1;
         _loc1_.id = "addRPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.addRPM = _loc1_;
         BindingManager.executeBindings(this,"addRPM",this.addRPM);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 100;
         _loc1_.steps = 0.001;
         _loc1_.id = "addHP";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.addHP = _loc1_;
         BindingManager.executeBindings(this,"addHP",this.addHP);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_GWizDataGrid1_i() : GWizDataGrid
      {
         var _loc1_:GWizDataGrid = new GWizDataGrid();
         _loc1_.configId = "spindleCurve";
         _loc1_.percentHeight = 100;
         _loc1_.columns = this._GWizSpindleCurve_ArrayList1_c();
         _loc1_.addEventListener("valueCommit",this.__points_valueCommit);
         _loc1_.id = "points";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.points = _loc1_;
         BindingManager.executeBindings(this,"points",this.points);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizSpindleCurve_GWizGridColumn1_c(),this._GWizSpindleCurve_GWizGridColumn2_c()];
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_GWizGridColumn1_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colRPM";
         _loc1_.headerText = "RPM";
         _loc1_.dataField = "RPM";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_GWizGridColumn2_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colHP";
         _loc1_.headerText = "Power";
         _loc1_.dataField = "HP";
         _loc1_.width = 100;
         _loc1_.labelFunction = GWizUtils.convUnitsInKWLabelFcn;
         return _loc1_;
      }
      
      public function __points_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizSpindleCurve_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Power Curve needs at least 2 points";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Clear Table";
         _loc1_.addEventListener("click",this.___GWizSpindleCurve_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizSpindleCurve_Button2_click(param1:MouseEvent) : void
      {
         this.doClearTable();
      }
      
      private function _GWizSpindleCurve_LineChart1_i() : LineChart
      {
         var _loc1_:LineChart = new LineChart();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.showDataTips = true;
         _loc1_.series = [this._GWizSpindleCurve_LineSeries1_i()];
         _loc1_.setStyle("paddingLeft",5);
         _loc1_.setStyle("paddingRight",5);
         _loc1_.id = "linechart";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.linechart = _loc1_;
         BindingManager.executeBindings(this,"linechart",this.linechart);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_LineSeries1_i() : LineSeries
      {
         var _loc1_:LineSeries = new LineSeries();
         _loc1_.xField = "RPM";
         _loc1_.displayName = "Power";
         _loc1_.setStyle("form","segment");
         _loc1_.id = "_GWizSpindleCurve_LineSeries1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSpindleCurve_LineSeries1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSpindleCurve_LineSeries1",this._GWizSpindleCurve_LineSeries1);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Legend1_i() : Legend
      {
         var _loc1_:Legend = new Legend();
         _loc1_.id = "_GWizSpindleCurve_Legend1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSpindleCurve_Legend1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSpindleCurve_Legend1",this._GWizSpindleCurve_Legend1);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.setStyle("color",16711680);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Error";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Error = _loc1_;
         BindingManager.executeBindings(this,"Error",this.Error);
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Find Power at RPM:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizSpindleCurve_Label7_c(),this._GWizSpindleCurve_NumericStepper2_i(),this._GWizSpindleCurve_Label8_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "RPM:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSpindleCurve_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 100000;
         _loc1_.stepSize = 1;
         _loc1_.addEventListener("change",this.__trialRPM_change);
         _loc1_.id = "trialRPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.trialRPM = _loc1_;
         BindingManager.executeBindings(this,"trialRPM",this.trialRPM);
         return _loc1_;
      }
      
      public function __trialRPM_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizSpindleCurve_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0 HP";
         _loc1_.id = "trialResult";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.trialResult = _loc1_;
         BindingManager.executeBindings(this,"trialResult",this.trialResult);
         return _loc1_;
      }
      
      public function ___GWizSpindleCurve_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizSpindleCurve_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return _vmcRigidity;
         },null,"VMCWeightAdjust.selected");
         result[1] = new Binding(this,function():Boolean
         {
            return !_vmcRigidity;
         },null,"RouterWeightAdjust.selected");
         result[2] = new Binding(this,function():Boolean
         {
            return CurveAdjust.selected;
         },null,"addRPM.enabled");
         result[3] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.HP_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"addHP.impUnits");
         result[4] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.KW_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"addHP.metUnits");
         result[5] = new Binding(this,function():Boolean
         {
            return CurveAdjust.selected;
         },null,"addHP.enabled");
         result[6] = new Binding(this,function():IList
         {
            return powerAC;
         },null,"points.dataProvider");
         result[7] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb4;
         },function(param1:uint):void
         {
            points.setStyle("selectionColor",param1);
         },"points.selectionColor");
         result[8] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            points.setStyle("rollOverColor",param1);
         },"points.rollOverColor");
         result[9] = new Binding(this,function():Object
         {
            return powerAC;
         },null,"linechart.dataProvider");
         result[10] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.Units != GWizUtils.INCHES_UNITS ? "KW" : "HP";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizSpindleCurve_LineSeries1.yField");
         result[11] = new Binding(this,null,function(param1:IStroke):void
         {
            _GWizSpindleCurve_LineSeries1.setStyle("lineStroke",param1);
         },"_GWizSpindleCurve_LineSeries1.lineStroke","s1");
         result[12] = new Binding(this,null,null,"_GWizSpindleCurve_Legend1.dataProvider","linechart");
         result[13] = new Binding(this,function():Boolean
         {
            return CurveAdjust.selected;
         },null,"trialRPM.enabled");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CurveAdjust() : RadioButton
      {
         return this._652010178CurveAdjust;
      }
      
      public function set CurveAdjust(param1:RadioButton) : void
      {
         var _loc2_:Object = this._652010178CurveAdjust;
         if(_loc2_ !== param1)
         {
            this._652010178CurveAdjust = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CurveAdjust",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Error() : Label
      {
         return this._67232232Error;
      }
      
      public function set Error(param1:Label) : void
      {
         var _loc2_:Object = this._67232232Error;
         if(_loc2_ !== param1)
         {
            this._67232232Error = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Error",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get NoAdjust() : RadioButton
      {
         return this._185434320NoAdjust;
      }
      
      public function set NoAdjust(param1:RadioButton) : void
      {
         var _loc2_:Object = this._185434320NoAdjust;
         if(_loc2_ !== param1)
         {
            this._185434320NoAdjust = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"NoAdjust",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RouterWeightAdjust() : RadioButton
      {
         return this._402739664RouterWeightAdjust;
      }
      
      public function set RouterWeightAdjust(param1:RadioButton) : void
      {
         var _loc2_:Object = this._402739664RouterWeightAdjust;
         if(_loc2_ !== param1)
         {
            this._402739664RouterWeightAdjust = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RouterWeightAdjust",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get VMCWeightAdjust() : RadioButton
      {
         return this._1633880755VMCWeightAdjust;
      }
      
      public function set VMCWeightAdjust(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1633880755VMCWeightAdjust;
         if(_loc2_ !== param1)
         {
            this._1633880755VMCWeightAdjust = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"VMCWeightAdjust",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get WeightAdjust() : RadioButton
      {
         return this._710082489WeightAdjust;
      }
      
      public function set WeightAdjust(param1:RadioButton) : void
      {
         var _loc2_:Object = this._710082489WeightAdjust;
         if(_loc2_ !== param1)
         {
            this._710082489WeightAdjust = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"WeightAdjust",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get addHP() : GWizNumStep
      {
         return this._92659049addHP;
      }
      
      public function set addHP(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._92659049addHP;
         if(_loc2_ !== param1)
         {
            this._92659049addHP = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"addHP",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get addRPM() : NumericStepper
      {
         return this._1422527090addRPM;
      }
      
      public function set addRPM(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1422527090addRPM;
         if(_loc2_ !== param1)
         {
            this._1422527090addRPM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"addRPM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get adjHP() : Label
      {
         return this._92664815adjHP;
      }
      
      public function set adjHP(param1:Label) : void
      {
         var _loc2_:Object = this._92664815adjHP;
         if(_loc2_ !== param1)
         {
            this._92664815adjHP = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"adjHP",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get linechart() : LineChart
      {
         return this._1792737174linechart;
      }
      
      public function set linechart(param1:LineChart) : void
      {
         var _loc2_:Object = this._1792737174linechart;
         if(_loc2_ !== param1)
         {
            this._1792737174linechart = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"linechart",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get points() : GWizDataGrid
      {
         return this._982754077points;
      }
      
      public function set points(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = this._982754077points;
         if(_loc2_ !== param1)
         {
            this._982754077points = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"points",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get radiogroup1() : RadioButtonGroup
      {
         return this._164873549radiogroup1;
      }
      
      public function set radiogroup1(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._164873549radiogroup1;
         if(_loc2_ !== param1)
         {
            this._164873549radiogroup1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radiogroup1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get radiogroup2() : RadioButtonGroup
      {
         return this._164873550radiogroup2;
      }
      
      public function set radiogroup2(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._164873550radiogroup2;
         if(_loc2_ !== param1)
         {
            this._164873550radiogroup2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radiogroup2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get s1() : SolidColorStroke
      {
         return this._3614s1;
      }
      
      public function set s1(param1:SolidColorStroke) : void
      {
         var _loc2_:Object = this._3614s1;
         if(_loc2_ !== param1)
         {
            this._3614s1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"s1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get trialRPM() : NumericStepper
      {
         return this._1497681657trialRPM;
      }
      
      public function set trialRPM(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1497681657trialRPM;
         if(_loc2_ !== param1)
         {
            this._1497681657trialRPM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"trialRPM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get trialResult() : Label
      {
         return this._1334614739trialResult;
      }
      
      public function set trialResult(param1:Label) : void
      {
         var _loc2_:Object = this._1334614739trialResult;
         if(_loc2_ !== param1)
         {
            this._1334614739trialResult = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"trialResult",_loc2_,param1));
            }
         }
      }
   }
}
