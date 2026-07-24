package apps
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import configinfo.GWizConfigData;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import spark.layouts.VerticalLayout;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizThermalExp extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1966947682Celsius:RadioButton;
      
      private var _65283033Coeff:NumericStepper;
      
      private var _65290606Combo:DropDownList;
      
      private var _1855715958Fahrenheit:RadioButton;
      
      private var _2022496506Length:GWizNumStep;
      
      private var _1378137514LengthChange:Label;
      
      private var _1854711630Radius:GWizNumStep;
      
      private var _740127998RadiusChange:Label;
      
      private var _1545763097RefTemp:NumericStepper;
      
      private var _1814899419TargetTemp:NumericStepper;
      
      public var _GWizThermalExp_GWizForePanel1:GWizForePanel;
      
      public var _GWizThermalExp_GWizForePanel2:GWizForePanel;
      
      public var _GWizThermalExp_GWizForePanel3:GWizForePanel;
      
      public var _GWizThermalExp_GWizForePanel4:GWizForePanel;
      
      public var _GWizThermalExp_Label1:Label;
      
      public var _GWizThermalExp_Label10:Label;
      
      public var _GWizThermalExp_Label11:Label;
      
      private var _1428108143tempgrp:RadioButtonGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _embed_mxml_assets_thermometerSm_jpg_1953213972:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizThermalExp()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._embed_mxml_assets_thermometerSm_jpg_1953213972 = GWizThermalExp__embed_mxml_assets_thermometerSm_jpg_1953213972;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizThermalExp_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizThermalExpWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizThermalExp[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.gap = 1;
         this.mxmlContent = [this._GWizThermalExp_Label1_i(),this._GWizThermalExp_HGroup1_c()];
         this._GWizThermalExp_RadioButtonGroup1_i();
         this.addEventListener("show",this.___GWizThermalExp_VGroup1_show);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizThermalExp._watcherSetupUtil = param1;
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
      
      private function checkUnits() : void
      {
         this.Length.titleTxt = "Object Length (" + this.sayUnits() + ")";
         this.Radius.titleTxt = "Ring Radius (" + this.sayUnits() + ")";
         this.doCalc();
      }
      
      private function doCalc() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = this.Length.getVal();
         var _loc3_:Number = this.Coeff.value;
         var _loc4_:Number = this.toFahrenheit(this.RefTemp.value);
         var _loc5_:Number = this.toFahrenheit(this.TargetTemp.value);
         _loc1_ = _loc2_ * _loc3_ * (_loc5_ - _loc4_);
         this.LengthChange.text = "Change in Length = " + GWizUtils.roundTenths(_loc1_ / 1000000,true) + " " + this.sayUnits() + ".";
         var _loc6_:Number;
         _loc1_ = (_loc6_ = this.Radius.getVal()) * _loc3_ * (_loc5_ - _loc4_);
         this.RadiusChange.text = "Change in Radius of Thin Circular Ring = " + GWizUtils.roundTenths(_loc1_ / 1000000,true) + " " + this.sayUnits() + ".";
      }
      
      private function sayUnits() : String
      {
         var _loc1_:String = "";
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            _loc1_ = "inches";
         }
         else if(GWizUtils.Units == GWizUtils.MM_UNITS)
         {
            _loc1_ = "mm";
         }
         return _loc1_;
      }
      
      private function doRefTemp() : void
      {
         if(this.Celsius.selected)
         {
            this.RefTemp.value = 20;
         }
         else
         {
            this.RefTemp.value = 68;
         }
      }
      
      private function doCombo() : void
      {
         var _loc1_:Object = this.Combo.selectedItem;
         if(_loc1_ && _loc1_.cexp)
         {
            this.Coeff.value = _loc1_.cexp;
         }
      }
      
      private function toFahrenheit(param1:Number) : Number
      {
         if(this.Celsius.selected)
         {
            param1 = param1 * (180 / 100) + 32;
         }
         return param1;
      }
      
      private function doTempUnits() : void
      {
         if(this.Celsius.selected)
         {
            this.RefTemp.value = (this.RefTemp.value - 32) * (100 / 180);
            this.TargetTemp.value = (this.TargetTemp.value - 32) * (100 / 180);
         }
         else
         {
            this.RefTemp.value = this.RefTemp.value * (180 / 100) + 32;
            this.TargetTemp.value = this.TargetTemp.value * (180 / 100) + 32;
         }
      }
      
      private function _GWizThermalExp_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.addEventListener("change",this.__tempgrp_change);
         _loc1_.initialized(this,"tempgrp");
         this.tempgrp = _loc1_;
         BindingManager.executeBindings(this,"tempgrp",this.tempgrp);
         return _loc1_;
      }
      
      public function __tempgrp_change(param1:Event) : void
      {
         this.doTempUnits();
      }
      
      private function _GWizThermalExp_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Thermal Expansion Calculator";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("paddingBottom",5);
         _loc1_.setStyle("paddingTop",5);
         _loc1_.setStyle("paddingLeft",5);
         _loc1_.setStyle("fontSize",16);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizThermalExp_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThermalExp_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThermalExp_Label1",this._GWizThermalExp_Label1);
         return _loc1_;
      }
      
      private function _GWizThermalExp_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizThermalExp_VGroup2_c(),this._GWizThermalExp_GWizForePanel5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizThermalExp_GWizForePanel1_i(),this._GWizThermalExp_GWizForePanel2_i(),this._GWizThermalExp_GWizForePanel3_i(),this._GWizThermalExp_GWizForePanel4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Material";
         _loc1_.layout = this._GWizThermalExp_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThermalExp_Array4_c);
         _loc1_.id = "_GWizThermalExp_GWizForePanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThermalExp_GWizForePanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThermalExp_GWizForePanel1",this._GWizThermalExp_GWizForePanel1);
         return _loc1_;
      }
      
      private function _GWizThermalExp_VerticalLayout1_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizThermalExp_Array4_c() : Array
      {
         return [this._GWizThermalExp_HGroup2_c(),this._GWizThermalExp_HGroup3_c()];
      }
      
      private function _GWizThermalExp_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThermalExp_Label2_c(),this._GWizThermalExp_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Material";
         _loc1_.width = 120;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "material";
         _loc1_.toolTip = "Select a material for average Coefficient of Thermal Expansion";
         _loc1_.width = 250;
         _loc1_.addEventListener("valueCommit",this.__Combo_valueCommit);
         _loc1_.id = "Combo";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Combo = _loc1_;
         BindingManager.executeBindings(this,"Combo",this.Combo);
         return _loc1_;
      }
      
      public function __Combo_valueCommit(param1:FlexEvent) : void
      {
         this.doCombo();
      }
      
      private function _GWizThermalExp_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThermalExp_Label3_c(),this._GWizThermalExp_NumericStepper1_i(),this._GWizThermalExp_Label4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Coeff of Expansion";
         _loc1_.width = 120;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 100;
         _loc1_.stepSize = 0.1;
         _loc1_.toolTip = "Coefficient of thermal expansion in micro-in/in/F";
         _loc1_.addEventListener("valueCommit",this.__Coeff_valueCommit);
         _loc1_.id = "Coeff";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Coeff = _loc1_;
         BindingManager.executeBindings(this,"Coeff",this.Coeff);
         return _loc1_;
      }
      
      public function __Coeff_valueCommit(param1:FlexEvent) : void
      {
         this.doCalc();
      }
      
      private function _GWizThermalExp_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "micro-in/in/F";
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Temp";
         _loc1_.layout = this._GWizThermalExp_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThermalExp_Array7_c);
         _loc1_.id = "_GWizThermalExp_GWizForePanel2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThermalExp_GWizForePanel2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThermalExp_GWizForePanel2",this._GWizThermalExp_GWizForePanel2);
         return _loc1_;
      }
      
      private function _GWizThermalExp_VerticalLayout2_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizThermalExp_Array7_c() : Array
      {
         return [this._GWizThermalExp_HGroup4_c(),this._GWizThermalExp_HGroup5_c(),this._GWizThermalExp_HGroup6_c()];
      }
      
      private function _GWizThermalExp_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.width = 330;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThermalExp_Label5_c(),this._GWizThermalExp_RadioButton1_i(),this._GWizThermalExp_RadioButton2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Units";
         _loc1_.width = 120;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Fahrenheit";
         _loc1_.groupName = "tempgrp";
         _loc1_.selected = true;
         _loc1_.id = "Fahrenheit";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Fahrenheit = _loc1_;
         BindingManager.executeBindings(this,"Fahrenheit",this.Fahrenheit);
         return _loc1_;
      }
      
      private function _GWizThermalExp_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Celsius";
         _loc1_.groupName = "tempgrp";
         _loc1_.id = "Celsius";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Celsius = _loc1_;
         BindingManager.executeBindings(this,"Celsius",this.Celsius);
         return _loc1_;
      }
      
      private function _GWizThermalExp_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "left";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThermalExp_Label6_c(),this._GWizThermalExp_NumericStepper2_i(),this._GWizThermalExp_Spacer1_c(),this._GWizThermalExp_Button1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Reference Temp";
         _loc1_.width = 120;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = -500;
         _loc1_.maximum = 10000;
         _loc1_.stepSize = 1;
         _loc1_.toolTip = "The temperature at which there is no expansion.";
         _loc1_.addEventListener("valueCommit",this.__RefTemp_valueCommit);
         _loc1_.id = "RefTemp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RefTemp = _loc1_;
         BindingManager.executeBindings(this,"RefTemp",this.RefTemp);
         return _loc1_;
      }
      
      public function __RefTemp_valueCommit(param1:FlexEvent) : void
      {
         this.doCalc();
      }
      
      private function _GWizThermalExp_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Std. Ref. Temp.";
         _loc1_.toolTip = "Standard reference temperature is 20C or 68F.";
         _loc1_.addEventListener("click",this.___GWizThermalExp_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizThermalExp_Button1_click(param1:MouseEvent) : void
      {
         this.doRefTemp();
      }
      
      private function _GWizThermalExp_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThermalExp_Label7_c(),this._GWizThermalExp_NumericStepper3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Target Temp";
         _loc1_.width = 120;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_NumericStepper3_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = -500;
         _loc1_.maximum = 10000;
         _loc1_.stepSize = 1;
         _loc1_.toolTip = "The temperature for which we want to determine how much expansion there will be versus the reference.";
         _loc1_.addEventListener("change",this.__TargetTemp_change);
         _loc1_.id = "TargetTemp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TargetTemp = _loc1_;
         BindingManager.executeBindings(this,"TargetTemp",this.TargetTemp);
         return _loc1_;
      }
      
      public function __TargetTemp_change(param1:Event) : void
      {
         this.doCalc();
      }
      
      private function _GWizThermalExp_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Object";
         _loc1_.layout = this._GWizThermalExp_VerticalLayout3_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThermalExp_Array11_c);
         _loc1_.id = "_GWizThermalExp_GWizForePanel3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThermalExp_GWizForePanel3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThermalExp_GWizForePanel3",this._GWizThermalExp_GWizForePanel3);
         return _loc1_;
      }
      
      private function _GWizThermalExp_VerticalLayout3_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizThermalExp_Array11_c() : Array
      {
         return [this._GWizThermalExp_GWizNumStep1_i(),this._GWizThermalExp_GWizNumStep2_i()];
      }
      
      private function _GWizThermalExp_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.0001;
         _loc1_.max = 1000000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Length of the object.";
         _loc1_.labelWidth = 120;
         _loc1_.addEventListener("change",this.__Length_change);
         _loc1_.id = "Length";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Length = _loc1_;
         BindingManager.executeBindings(this,"Length",this.Length);
         return _loc1_;
      }
      
      public function __Length_change(param1:Event) : void
      {
         this.doCalc();
      }
      
      private function _GWizThermalExp_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.0001;
         _loc1_.max = 1000000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Radius of the ring.";
         _loc1_.labelWidth = 120;
         _loc1_.addEventListener("change",this.__Radius_change);
         _loc1_.id = "Radius";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Radius = _loc1_;
         BindingManager.executeBindings(this,"Radius",this.Radius);
         return _loc1_;
      }
      
      public function __Radius_change(param1:Event) : void
      {
         this.doCalc();
      }
      
      private function _GWizThermalExp_GWizForePanel4_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.title = "Results";
         _loc1_.layout = this._GWizThermalExp_VerticalLayout4_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThermalExp_Array12_c);
         _loc1_.id = "_GWizThermalExp_GWizForePanel4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThermalExp_GWizForePanel4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThermalExp_GWizForePanel4",this._GWizThermalExp_GWizForePanel4);
         return _loc1_;
      }
      
      private function _GWizThermalExp_VerticalLayout4_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizThermalExp_Array12_c() : Array
      {
         return [this._GWizThermalExp_Label8_i(),this._GWizThermalExp_Spacer2_c(),this._GWizThermalExp_Label9_i(),this._GWizThermalExp_Spacer3_c(),this._GWizThermalExp_Label10_i(),this._GWizThermalExp_Label11_i()];
      }
      
      private function _GWizThermalExp_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Change in Length";
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "LengthChange";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LengthChange = _loc1_;
         BindingManager.executeBindings(this,"LengthChange",this.LengthChange);
         return _loc1_;
      }
      
      private function _GWizThermalExp_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Change in Radius of Thin Circular Ring";
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "RadiusChange";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RadiusChange = _loc1_;
         BindingManager.executeBindings(this,"RadiusChange",this.RadiusChange);
         return _loc1_;
      }
      
      private function _GWizThermalExp_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Note: Exact thermal expansion coefficients vary from alloy to alloy.";
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "_GWizThermalExp_Label10";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThermalExp_Label10 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThermalExp_Label10",this._GWizThermalExp_Label10);
         return _loc1_;
      }
      
      private function _GWizThermalExp_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "For maximum precision, look up the exact value for your material!";
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "_GWizThermalExp_Label11";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThermalExp_Label11 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThermalExp_Label11",this._GWizThermalExp_Label11);
         return _loc1_;
      }
      
      private function _GWizThermalExp_GWizForePanel5_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizThermalExp_VerticalLayout5_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThermalExp_Array13_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThermalExp_VerticalLayout5_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizThermalExp_Array13_c() : Array
      {
         return [this._GWizThermalExp_Image1_c()];
      }
      
      private function _GWizThermalExp_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml_assets_thermometerSm_jpg_1953213972;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizThermalExp_VGroup1_show(param1:FlexEvent) : void
      {
         this.checkUnits();
      }
      
      private function _GWizThermalExp_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            _GWizThermalExp_Label1.setStyle("color",param1);
         },"_GWizThermalExp_Label1.color");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },function(param1:uint):void
         {
            _GWizThermalExp_Label1.setStyle("backgroundColor",param1);
         },"_GWizThermalExp_Label1.backgroundColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizThermalExp_GWizForePanel1.labelBackgroundColor");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizThermalExp_GWizForePanel1.labelColor");
         result[4] = new Binding(this,function():IList
         {
            return GWizConfigData.MachinabilityFactors;
         },null,"Combo.dataProvider");
         result[5] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb4;
         },function(param1:uint):void
         {
            Combo.setStyle("selectionColor",param1);
         },"Combo.selectionColor");
         result[6] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            Combo.setStyle("rollOverColor",param1);
         },"Combo.rollOverColor");
         result[7] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizThermalExp_GWizForePanel2.labelBackgroundColor");
         result[8] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizThermalExp_GWizForePanel2.labelColor");
         result[9] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizThermalExp_GWizForePanel3.labelBackgroundColor");
         result[10] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizThermalExp_GWizForePanel3.labelColor");
         result[11] = new Binding(this,function():String
         {
            var _loc1_:* = "Length (" + sayUnits() + ")";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"Length.titleTxt");
         result[12] = new Binding(this,function():String
         {
            var _loc1_:* = "Ring Radius (" + sayUnits() + ")";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"Radius.titleTxt");
         result[13] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizThermalExp_GWizForePanel4.labelBackgroundColor");
         result[14] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizThermalExp_GWizForePanel4.labelColor");
         result[15] = new Binding(this,function():uint
         {
            return ColorPalette.secondaryb1;
         },function(param1:uint):void
         {
            _GWizThermalExp_Label10.setStyle("color",param1);
         },"_GWizThermalExp_Label10.color");
         result[16] = new Binding(this,function():uint
         {
            return ColorPalette.secondaryb1;
         },function(param1:uint):void
         {
            _GWizThermalExp_Label11.setStyle("color",param1);
         },"_GWizThermalExp_Label11.color");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Celsius() : RadioButton
      {
         return this._1966947682Celsius;
      }
      
      public function set Celsius(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1966947682Celsius;
         if(_loc2_ !== param1)
         {
            this._1966947682Celsius = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Celsius",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Coeff() : NumericStepper
      {
         return this._65283033Coeff;
      }
      
      public function set Coeff(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._65283033Coeff;
         if(_loc2_ !== param1)
         {
            this._65283033Coeff = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Coeff",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Combo() : DropDownList
      {
         return this._65290606Combo;
      }
      
      public function set Combo(param1:DropDownList) : void
      {
         var _loc2_:Object = this._65290606Combo;
         if(_loc2_ !== param1)
         {
            this._65290606Combo = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Combo",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Fahrenheit() : RadioButton
      {
         return this._1855715958Fahrenheit;
      }
      
      public function set Fahrenheit(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1855715958Fahrenheit;
         if(_loc2_ !== param1)
         {
            this._1855715958Fahrenheit = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Fahrenheit",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Length() : GWizNumStep
      {
         return this._2022496506Length;
      }
      
      public function set Length(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2022496506Length;
         if(_loc2_ !== param1)
         {
            this._2022496506Length = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Length",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LengthChange() : Label
      {
         return this._1378137514LengthChange;
      }
      
      public function set LengthChange(param1:Label) : void
      {
         var _loc2_:Object = this._1378137514LengthChange;
         if(_loc2_ !== param1)
         {
            this._1378137514LengthChange = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LengthChange",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Radius() : GWizNumStep
      {
         return this._1854711630Radius;
      }
      
      public function set Radius(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1854711630Radius;
         if(_loc2_ !== param1)
         {
            this._1854711630Radius = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Radius",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RadiusChange() : Label
      {
         return this._740127998RadiusChange;
      }
      
      public function set RadiusChange(param1:Label) : void
      {
         var _loc2_:Object = this._740127998RadiusChange;
         if(_loc2_ !== param1)
         {
            this._740127998RadiusChange = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RadiusChange",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RefTemp() : NumericStepper
      {
         return this._1545763097RefTemp;
      }
      
      public function set RefTemp(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1545763097RefTemp;
         if(_loc2_ !== param1)
         {
            this._1545763097RefTemp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RefTemp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TargetTemp() : NumericStepper
      {
         return this._1814899419TargetTemp;
      }
      
      public function set TargetTemp(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1814899419TargetTemp;
         if(_loc2_ !== param1)
         {
            this._1814899419TargetTemp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TargetTemp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tempgrp() : RadioButtonGroup
      {
         return this._1428108143tempgrp;
      }
      
      public function set tempgrp(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1428108143tempgrp;
         if(_loc2_ !== param1)
         {
            this._1428108143tempgrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tempgrp",_loc2_,param1));
            }
         }
      }
   }
}
