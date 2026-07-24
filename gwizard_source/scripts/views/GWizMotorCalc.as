package views
{
   import comps.GWizForePanel;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.VGroup;
   import spark.layouts.VerticalLayout;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizMotorCalc extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizMotorCalc_GWizForePanel1:GWizForePanel;
      
      public var _GWizMotorCalc_GWizForePanel2:GWizForePanel;
      
      public var _GWizMotorCalc_Label1:Label;
      
      private var _565128353driveRatio:NumericStepper;
      
      private var _1537071848faultDist:Label;
      
      private var _1256750245fullStepRes:Label;
      
      private var _255478524leadTurnsInch:Label;
      
      private var _2011694604leadscrewLead:NumericStepper;
      
      private var _733074736microStepRes:Label;
      
      private var _1374039779microsteps:NumericStepper;
      
      private var _1677538081peakTorqueMotion:Label;
      
      private var _1927885233pulseFreq:Label;
      
      private var _1362214929stepsInch:Label;
      
      private var _1429424124stepsRev:NumericStepper;
      
      private var _226669760stepsToFault:NumericStepper;
      
      private var _1681240585torquePeak:NumericStepper;
      
      private var _135102765turnsRev:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizMotorCalc()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizMotorCalc_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizMotorCalcWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizMotorCalc[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.gap = 1;
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.mxmlContent = [this._GWizMotorCalc_Label1_i(),this._GWizMotorCalc_GWizForePanel1_i(),this._GWizMotorCalc_GWizForePanel2_i()];
         this.addEventListener("creationComplete",this.___GWizMotorCalc_VGroup1_creationComplete);
         this.addEventListener("show",this.___GWizMotorCalc_VGroup1_show);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizMotorCalc._watcherSetupUtil = param1;
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
      
      private function recalc() : void
      {
         var _loc1_:String = "inches";
         var _loc2_:String = "inch";
         if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            _loc1_ = "mm\'s";
            _loc2_ = "mm";
         }
         this.leadTurnsInch.text = _loc1_ + " per revolution, " + GWizUtils.roundThousandths(1 / this.leadscrewLead.value) + " turns for 1 " + _loc2_ + " of motion";
         var _loc3_:Number = this.driveRatio.value / this.leadscrewLead.value;
         this.turnsRev.text = "Motor turns per " + _loc2_ + " of motion: " + GWizUtils.roundBigTenths2Str(_loc3_);
         this.peakTorqueMotion.text = "Peak torque axis speed: " + GWizUtils.roundBigTenths2Str(this.torquePeak.value / _loc3_) + " " + _loc1_ + " per minute";
         this.fullStepRes.text = GWizUtils.roundPlaces(1 / (this.stepsRev.value * _loc3_),6) + " Full step resolution in " + _loc1_;
         this.microStepRes.text = GWizUtils.roundPlaces(1 / (this.stepsRev.value * _loc3_) / this.microsteps.value,6) + " Micro step resolution in " + _loc1_;
         var _loc4_:Number = 1 / (1 / (this.stepsRev.value * _loc3_) / this.microsteps.value);
         this.stepsInch.text = GWizUtils.roundTenths(_loc4_) + " Steps per " + _loc2_;
         this.pulseFreq.text = GWizUtils.roundBigTenths2Str(this.torquePeak.value / _loc3_ * _loc4_ / 60) + " steps per second at max torque speed";
         this.faultDist.text = GWizUtils.roundTenths(this.stepsToFault.value / _loc4_) + " " + _loc1_ + " of error results in a servo fault";
      }
      
      private function _GWizMotorCalc_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "CNC Servo/Stepper Motor Calculations";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("paddingBottom",5);
         _loc1_.setStyle("paddingTop",5);
         _loc1_.setStyle("paddingLeft",5);
         _loc1_.setStyle("fontSize",16);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMotorCalc_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMotorCalc_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMotorCalc_Label1",this._GWizMotorCalc_Label1);
         return _loc1_;
      }
      
      private function _GWizMotorCalc_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Peak Torque";
         _loc1_.labelWidth = 120;
         _loc1_.layout = this._GWizMotorCalc_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMotorCalc_Array2_c);
         _loc1_.id = "_GWizMotorCalc_GWizForePanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMotorCalc_GWizForePanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMotorCalc_GWizForePanel1",this._GWizMotorCalc_GWizForePanel1);
         return _loc1_;
      }
      
      private function _GWizMotorCalc_VerticalLayout1_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizMotorCalc_Array2_c() : Array
      {
         return [this._GWizMotorCalc_HGroup1_c(),this._GWizMotorCalc_HGroup2_c(),this._GWizMotorCalc_HGroup3_c(),this._GWizMotorCalc_Spacer1_c(),this._GWizMotorCalc_Label8_i(),this._GWizMotorCalc_Label9_i()];
      }
      
      private function _GWizMotorCalc_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMotorCalc_Label2_c(),this._GWizMotorCalc_NumericStepper1_i(),this._GWizMotorCalc_Label3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Motor Torque Peak";
         _loc1_.width = 150;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.maximum = 10000;
         _loc1_.minimum = 0;
         _loc1_.stepSize = 1;
         _loc1_.value = 2000;
         _loc1_.width = 100;
         _loc1_.addEventListener("change",this.__torquePeak_change);
         _loc1_.id = "torquePeak";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.torquePeak = _loc1_;
         BindingManager.executeBindings(this,"torquePeak",this.torquePeak);
         return _loc1_;
      }
      
      public function __torquePeak_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMotorCalc_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "rpm (Try 2000 for steppers, 3000 for servos)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMotorCalc_Label4_c(),this._GWizMotorCalc_NumericStepper2_i(),this._GWizMotorCalc_Label5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Motor Drive Pulley Ratio";
         _loc1_.width = 150;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.maximum = 100;
         _loc1_.minimum = 0;
         _loc1_.stepSize = 0.001;
         _loc1_.value = 2;
         _loc1_.width = 100;
         _loc1_.addEventListener("change",this.__driveRatio_change);
         _loc1_.id = "driveRatio";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.driveRatio = _loc1_;
         BindingManager.executeBindings(this,"driveRatio",this.driveRatio);
         return _loc1_;
      }
      
      public function __driveRatio_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMotorCalc_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = ":1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMotorCalc_Label6_c(),this._GWizMotorCalc_NumericStepper3_i(),this._GWizMotorCalc_Label7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Leadscrew Lead";
         _loc1_.width = 150;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_NumericStepper3_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.maximum = 100;
         _loc1_.minimum = 0;
         _loc1_.stepSize = 0.0001;
         _loc1_.value = 0.2;
         _loc1_.width = 100;
         _loc1_.addEventListener("change",this.__leadscrewLead_change);
         _loc1_.id = "leadscrewLead";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.leadscrewLead = _loc1_;
         BindingManager.executeBindings(this,"leadscrewLead",this.leadscrewLead);
         return _loc1_;
      }
      
      public function __leadscrewLead_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMotorCalc_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "inches per revolution";
         _loc1_.id = "leadTurnsInch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.leadTurnsInch = _loc1_;
         BindingManager.executeBindings(this,"leadTurnsInch",this.leadTurnsInch);
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 40;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "X turns per revolution";
         _loc1_.id = "turnsRev";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.turnsRev = _loc1_;
         BindingManager.executeBindings(this,"turnsRev",this.turnsRev);
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.styleName = "fontSizeDelta4";
         _loc1_.text = "Peak torque axis speed";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "peakTorqueMotion";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.peakTorqueMotion = _loc1_;
         BindingManager.executeBindings(this,"peakTorqueMotion",this.peakTorqueMotion);
         return _loc1_;
      }
      
      private function _GWizMotorCalc_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Resolution";
         _loc1_.labelWidth = 120;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizMotorCalc_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMotorCalc_Array6_c);
         _loc1_.id = "_GWizMotorCalc_GWizForePanel2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMotorCalc_GWizForePanel2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMotorCalc_GWizForePanel2",this._GWizMotorCalc_GWizForePanel2);
         return _loc1_;
      }
      
      private function _GWizMotorCalc_VerticalLayout2_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizMotorCalc_Array6_c() : Array
      {
         return [this._GWizMotorCalc_HGroup4_c(),this._GWizMotorCalc_HGroup5_c(),this._GWizMotorCalc_Spacer2_c(),this._GWizMotorCalc_Label14_i(),this._GWizMotorCalc_Label15_i(),this._GWizMotorCalc_Label16_i(),this._GWizMotorCalc_Label17_i(),this._GWizMotorCalc_Spacer3_c(),this._GWizMotorCalc_HGroup6_c()];
      }
      
      private function _GWizMotorCalc_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMotorCalc_Label10_c(),this._GWizMotorCalc_NumericStepper4_i(),this._GWizMotorCalc_Label11_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Steps/Rev";
         _loc1_.width = 80;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_NumericStepper4_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 1;
         _loc1_.maximum = 10000;
         _loc1_.stepSize = 1;
         _loc1_.value = 200;
         _loc1_.addEventListener("change",this.__stepsRev_change);
         _loc1_.id = "stepsRev";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stepsRev = _loc1_;
         BindingManager.executeBindings(this,"stepsRev",this.stepsRev);
         return _loc1_;
      }
      
      public function __stepsRev_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMotorCalc_Label11_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "(Use 200 for steppers and the encoder count for servos)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMotorCalc_Label12_c(),this._GWizMotorCalc_NumericStepper5_i(),this._GWizMotorCalc_Label13_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Microsteps";
         _loc1_.width = 80;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_NumericStepper5_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 1;
         _loc1_.maximum = 10000;
         _loc1_.stepSize = 1;
         _loc1_.value = 4;
         _loc1_.addEventListener("change",this.__microsteps_change);
         _loc1_.id = "microsteps";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.microsteps = _loc1_;
         BindingManager.executeBindings(this,"microsteps",this.microsteps);
         return _loc1_;
      }
      
      public function __microsteps_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMotorCalc_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "(Use microstep count for steppers and 4 for servos with quadrature encoders)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 50;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label14_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "fullStepRes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fullStepRes = _loc1_;
         BindingManager.executeBindings(this,"fullStepRes",this.fullStepRes);
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "microStepRes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.microStepRes = _loc1_;
         BindingManager.executeBindings(this,"microStepRes",this.microStepRes);
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label16_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "stepsInch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stepsInch = _loc1_;
         BindingManager.executeBindings(this,"stepsInch",this.stepsInch);
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label17_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "pulseFreq";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pulseFreq = _loc1_;
         BindingManager.executeBindings(this,"pulseFreq",this.pulseFreq);
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 50;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMotorCalc_Label18_c(),this._GWizMotorCalc_NumericStepper6_i(),this._GWizMotorCalc_Label19_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_Label18_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Steps to fault";
         _loc1_.width = 80;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMotorCalc_NumericStepper6_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 1;
         _loc1_.maximum = 10000;
         _loc1_.stepSize = 1;
         _loc1_.value = 128;
         _loc1_.addEventListener("change",this.__stepsToFault_change);
         _loc1_.id = "stepsToFault";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stepsToFault = _loc1_;
         BindingManager.executeBindings(this,"stepsToFault",this.stepsToFault);
         return _loc1_;
      }
      
      public function __stepsToFault_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMotorCalc_Label19_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "faultDist";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.faultDist = _loc1_;
         BindingManager.executeBindings(this,"faultDist",this.faultDist);
         return _loc1_;
      }
      
      public function ___GWizMotorCalc_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function ___GWizMotorCalc_VGroup1_show(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizMotorCalc_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            _GWizMotorCalc_Label1.setStyle("color",param1);
         },"_GWizMotorCalc_Label1.color");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },function(param1:uint):void
         {
            _GWizMotorCalc_Label1.setStyle("backgroundColor",param1);
         },"_GWizMotorCalc_Label1.backgroundColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizMotorCalc_GWizForePanel1.labelBackgroundColor");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizMotorCalc_GWizForePanel1.labelColor");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizMotorCalc_GWizForePanel2.labelBackgroundColor");
         result[5] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizMotorCalc_GWizForePanel2.labelColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get driveRatio() : NumericStepper
      {
         return this._565128353driveRatio;
      }
      
      public function set driveRatio(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._565128353driveRatio;
         if(_loc2_ !== param1)
         {
            this._565128353driveRatio = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"driveRatio",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get faultDist() : Label
      {
         return this._1537071848faultDist;
      }
      
      public function set faultDist(param1:Label) : void
      {
         var _loc2_:Object = this._1537071848faultDist;
         if(_loc2_ !== param1)
         {
            this._1537071848faultDist = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"faultDist",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fullStepRes() : Label
      {
         return this._1256750245fullStepRes;
      }
      
      public function set fullStepRes(param1:Label) : void
      {
         var _loc2_:Object = this._1256750245fullStepRes;
         if(_loc2_ !== param1)
         {
            this._1256750245fullStepRes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fullStepRes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get leadTurnsInch() : Label
      {
         return this._255478524leadTurnsInch;
      }
      
      public function set leadTurnsInch(param1:Label) : void
      {
         var _loc2_:Object = this._255478524leadTurnsInch;
         if(_loc2_ !== param1)
         {
            this._255478524leadTurnsInch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"leadTurnsInch",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get leadscrewLead() : NumericStepper
      {
         return this._2011694604leadscrewLead;
      }
      
      public function set leadscrewLead(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._2011694604leadscrewLead;
         if(_loc2_ !== param1)
         {
            this._2011694604leadscrewLead = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"leadscrewLead",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get microStepRes() : Label
      {
         return this._733074736microStepRes;
      }
      
      public function set microStepRes(param1:Label) : void
      {
         var _loc2_:Object = this._733074736microStepRes;
         if(_loc2_ !== param1)
         {
            this._733074736microStepRes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"microStepRes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get microsteps() : NumericStepper
      {
         return this._1374039779microsteps;
      }
      
      public function set microsteps(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1374039779microsteps;
         if(_loc2_ !== param1)
         {
            this._1374039779microsteps = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"microsteps",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get peakTorqueMotion() : Label
      {
         return this._1677538081peakTorqueMotion;
      }
      
      public function set peakTorqueMotion(param1:Label) : void
      {
         var _loc2_:Object = this._1677538081peakTorqueMotion;
         if(_loc2_ !== param1)
         {
            this._1677538081peakTorqueMotion = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"peakTorqueMotion",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pulseFreq() : Label
      {
         return this._1927885233pulseFreq;
      }
      
      public function set pulseFreq(param1:Label) : void
      {
         var _loc2_:Object = this._1927885233pulseFreq;
         if(_loc2_ !== param1)
         {
            this._1927885233pulseFreq = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pulseFreq",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepsInch() : Label
      {
         return this._1362214929stepsInch;
      }
      
      public function set stepsInch(param1:Label) : void
      {
         var _loc2_:Object = this._1362214929stepsInch;
         if(_loc2_ !== param1)
         {
            this._1362214929stepsInch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepsInch",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepsRev() : NumericStepper
      {
         return this._1429424124stepsRev;
      }
      
      public function set stepsRev(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1429424124stepsRev;
         if(_loc2_ !== param1)
         {
            this._1429424124stepsRev = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepsRev",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepsToFault() : NumericStepper
      {
         return this._226669760stepsToFault;
      }
      
      public function set stepsToFault(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._226669760stepsToFault;
         if(_loc2_ !== param1)
         {
            this._226669760stepsToFault = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepsToFault",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get torquePeak() : NumericStepper
      {
         return this._1681240585torquePeak;
      }
      
      public function set torquePeak(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1681240585torquePeak;
         if(_loc2_ !== param1)
         {
            this._1681240585torquePeak = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"torquePeak",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get turnsRev() : Label
      {
         return this._135102765turnsRev;
      }
      
      public function set turnsRev(param1:Label) : void
      {
         var _loc2_:Object = this._135102765turnsRev;
         if(_loc2_ !== param1)
         {
            this._135102765turnsRev = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"turnsRev",_loc2_,param1));
            }
         }
      }
   }
}
