package threads2
{
   import comps.GWizForePanel;
   import comps.GWizLabText;
   import comps.GWizNumStep;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.layouts.VerticalLayout;
   
   use namespace mx_internal;
   
   public class GWizMOWData extends GWizForePanel implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _528838311actualMOW:GWizNumStep;
      
      private var _217671023bestMOW:GWizLabText;
      
      private var _1081156847maxMOW:GWizLabText;
      
      private var _223222343measurementMOW:GWizNumStep;
      
      private var _1074066589minMOW:GWizLabText;
      
      private var _1253205380mowMOWMax:GWizLabText;
      
      private var _1253205618mowMOWMin:GWizLabText;
      
      private var _17949743mowMeasuredPD:GWizLabText;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizMOWData()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizMOWData_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_threads2_GWizMOWDataWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizMOWData[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentHeight = 100;
         this.layout = this._GWizMOWData_VerticalLayout1_c();
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMOWData_Array1_c);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizMOWData._watcherSetupUtil = param1;
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
      
      public function recalcMOWLimits(param1:Number) : void
      {
         GWizThreadReference2.straightThreadEngine.RecalcMOWLimits(param1);
         this.mowMOWMin.value = GWizAbstractThreadEngine.MinMeasureMOW;
         this.mowMOWMax.value = GWizAbstractThreadEngine.MaxMeasureMOW;
      }
      
      public function recalcMOWPitchDia(param1:Number, param2:Number) : void
      {
         this.mowMeasuredPD.value = GWizThreadReference2.straightThreadEngine.RecalcMOWPitchDia(param1,param2);
      }
      
      private function _GWizMOWData_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingRight = 15;
         return _loc1_;
      }
      
      private function _GWizMOWData_Array1_c() : Array
      {
         return [this._GWizMOWData_Label1_c(),this._GWizMOWData_Label2_c(),this._GWizMOWData_Label3_c(),this._GWizMOWData_GWizLabText1_i(),this._GWizMOWData_GWizLabText2_i(),this._GWizMOWData_GWizLabText3_i(),this._GWizMOWData_Label4_c(),this._GWizMOWData_GWizNumStep1_i(),this._GWizMOWData_Label5_c(),this._GWizMOWData_GWizLabText4_i(),this._GWizMOWData_GWizLabText5_i(),this._GWizMOWData_Label6_c(),this._GWizMOWData_GWizNumStep2_i(),this._GWizMOWData_Label7_c(),this._GWizMOWData_GWizLabText6_i()];
      }
      
      private function _GWizMOWData_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Measurement Over Wires (3 Wire)";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMOWData_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMOWData_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Wires";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMOWData_GWizLabText1_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labTxt = "Best: ";
         _loc1_.value = 0.02878;
         _loc1_.id = "bestMOW";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.bestMOW = _loc1_;
         BindingManager.executeBindings(this,"bestMOW",this.bestMOW);
         return _loc1_;
      }
      
      private function _GWizMOWData_GWizLabText2_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labTxt = "Min: ";
         _loc1_.value = 0.02526;
         _loc1_.id = "minMOW";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.minMOW = _loc1_;
         BindingManager.executeBindings(this,"minMOW",this.minMOW);
         return _loc1_;
      }
      
      private function _GWizMOWData_GWizLabText3_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labTxt = "Max: ";
         _loc1_.value = 0.05052;
         _loc1_.id = "maxMOW";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.maxMOW = _loc1_;
         BindingManager.executeBindings(this,"maxMOW",this.maxMOW);
         return _loc1_;
      }
      
      private function _GWizMOWData_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMOWData_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Actual Wire Size:";
         _loc1_.value = 0.04319;
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Actual diameter of wires used.";
         _loc1_.UnitLabel = "in";
         _loc1_.addEventListener("change",this.__actualMOW_change);
         _loc1_.id = "actualMOW";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.actualMOW = _loc1_;
         BindingManager.executeBindings(this,"actualMOW",this.actualMOW);
         return _loc1_;
      }
      
      public function __actualMOW_change(param1:Event) : void
      {
         this.recalcMOWLimits(this.actualMOW.value);
      }
      
      private function _GWizMOWData_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMOWData_GWizLabText4_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labTxt = "MOW Min: ";
         _loc1_.value = 0.04319;
         _loc1_.toolTip = "Minimum measurement over wires for min pitch diameter.";
         _loc1_.id = "mowMOWMin";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mowMOWMin = _loc1_;
         BindingManager.executeBindings(this,"mowMOWMin",this.mowMOWMin);
         return _loc1_;
      }
      
      private function _GWizMOWData_GWizLabText5_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labTxt = "MOW Max: ";
         _loc1_.value = 0.04319;
         _loc1_.toolTip = "Maximum measurement over wires for max pitch diameter.";
         _loc1_.id = "mowMOWMax";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mowMOWMax = _loc1_;
         BindingManager.executeBindings(this,"mowMOWMax",this.mowMOWMax);
         return _loc1_;
      }
      
      private function _GWizMOWData_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMOWData_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Size Over Wires:";
         _loc1_.value = 0;
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Actual diameter measured over wires.";
         _loc1_.UnitLabel = "in";
         _loc1_.addEventListener("change",this.__measurementMOW_change);
         _loc1_.id = "measurementMOW";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.measurementMOW = _loc1_;
         BindingManager.executeBindings(this,"measurementMOW",this.measurementMOW);
         return _loc1_;
      }
      
      public function __measurementMOW_change(param1:Event) : void
      {
         this.recalcMOWPitchDia(this.actualMOW.value,this.measurementMOW.value);
      }
      
      private function _GWizMOWData_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMOWData_GWizLabText6_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labTxt = "Measured Pitch Dia: ";
         _loc1_.value = 0.04319;
         _loc1_.toolTip = "Calculated Pitch Diameter from 3 wire measurement.";
         _loc1_.id = "mowMeasuredPD";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mowMeasuredPD = _loc1_;
         BindingManager.executeBindings(this,"mowMeasuredPD",this.mowMeasuredPD);
         return _loc1_;
      }
      
      private function _GWizMOWData_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return this.enabled;
         },null,"this.visible");
         result[1] = new Binding(this,function():Boolean
         {
            return this.enabled;
         },null,"this.includeInLayout");
         result[2] = new Binding(this,function():Number
         {
            return actualMOW.width;
         },null,"bestMOW.width");
         result[3] = new Binding(this,function():Number
         {
            return actualMOW.width;
         },null,"minMOW.width");
         result[4] = new Binding(this,function():Number
         {
            return actualMOW.width;
         },null,"maxMOW.width");
         result[5] = new Binding(this,function():Number
         {
            return mowMOWMax.width;
         },null,"actualMOW.width");
         result[6] = new Binding(this,function():Number
         {
            return mowMOWMax.width;
         },null,"measurementMOW.width");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get actualMOW() : GWizNumStep
      {
         return this._528838311actualMOW;
      }
      
      public function set actualMOW(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._528838311actualMOW;
         if(_loc2_ !== param1)
         {
            this._528838311actualMOW = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"actualMOW",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get bestMOW() : GWizLabText
      {
         return this._217671023bestMOW;
      }
      
      public function set bestMOW(param1:GWizLabText) : void
      {
         var _loc2_:Object = this._217671023bestMOW;
         if(_loc2_ !== param1)
         {
            this._217671023bestMOW = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bestMOW",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get maxMOW() : GWizLabText
      {
         return this._1081156847maxMOW;
      }
      
      public function set maxMOW(param1:GWizLabText) : void
      {
         var _loc2_:Object = this._1081156847maxMOW;
         if(_loc2_ !== param1)
         {
            this._1081156847maxMOW = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"maxMOW",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get measurementMOW() : GWizNumStep
      {
         return this._223222343measurementMOW;
      }
      
      public function set measurementMOW(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._223222343measurementMOW;
         if(_loc2_ !== param1)
         {
            this._223222343measurementMOW = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"measurementMOW",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get minMOW() : GWizLabText
      {
         return this._1074066589minMOW;
      }
      
      public function set minMOW(param1:GWizLabText) : void
      {
         var _loc2_:Object = this._1074066589minMOW;
         if(_loc2_ !== param1)
         {
            this._1074066589minMOW = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"minMOW",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mowMOWMax() : GWizLabText
      {
         return this._1253205380mowMOWMax;
      }
      
      public function set mowMOWMax(param1:GWizLabText) : void
      {
         var _loc2_:Object = this._1253205380mowMOWMax;
         if(_loc2_ !== param1)
         {
            this._1253205380mowMOWMax = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mowMOWMax",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mowMOWMin() : GWizLabText
      {
         return this._1253205618mowMOWMin;
      }
      
      public function set mowMOWMin(param1:GWizLabText) : void
      {
         var _loc2_:Object = this._1253205618mowMOWMin;
         if(_loc2_ !== param1)
         {
            this._1253205618mowMOWMin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mowMOWMin",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mowMeasuredPD() : GWizLabText
      {
         return this._17949743mowMeasuredPD;
      }
      
      public function set mowMeasuredPD(param1:GWizLabText) : void
      {
         var _loc2_:Object = this._17949743mowMeasuredPD;
         if(_loc2_ !== param1)
         {
            this._17949743mowMeasuredPD = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mowMeasuredPD",_loc2_,param1));
            }
         }
      }
   }
}
