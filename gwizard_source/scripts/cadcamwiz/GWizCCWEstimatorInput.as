package cadcamwiz
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.TextArea;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizCCWEstimatorInput extends GWizForePanel implements IBindingClient
   {
      
      private static var _1847014802addEstimatorItem:Function;
      
      private static var _1228399174tabNavLabel:String = "";
      
      public static const FIXED_COST_LABEL:String = "Fixed Costs (One Time)";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _214851863EstDesc:TextArea;
      
      private var _2089667258Expand:CheckBox;
      
      private var _975235311HourlyRate:GWizNumStep;
      
      private var _81558Qty:GWizNumStep;
      
      private var _3587215vGrp:VGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var wizard:GWizCCWGenericWizard;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWEstimatorInput()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWEstimatorInput_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWEstimatorInputWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWEstimatorInput[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWEstimatorInput_Array1_c);
         this.addEventListener("creationComplete",this.___GWizCCWEstimatorInput_GWizForePanel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function isFixedCost() : Boolean
      {
         return tabNavLabel == FIXED_COST_LABEL;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWEstimatorInput._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get addEstimatorItem() : Function
      {
         return GWizCCWEstimatorInput._1847014802addEstimatorItem;
      }
      
      public static function set addEstimatorItem(param1:Function) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWEstimatorInput._1847014802addEstimatorItem;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWEstimatorInput,"addEstimatorItem",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get tabNavLabel() : String
      {
         return GWizCCWEstimatorInput._1228399174tabNavLabel;
      }
      
      public static function set tabNavLabel(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWEstimatorInput._1228399174tabNavLabel;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWEstimatorInput,"tabNavLabel",_loc2_,param1));
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
         if(!this.wizard)
         {
            this.callLater(this.onCC);
         }
         else
         {
            this.setHourlyRate();
         }
      }
      
      public function setHourlyRate() : void
      {
         var _loc1_:Object = GWizMachSettings.lookupMachine(GWizMachSettings.currMachine);
         if(!isNaN(_loc1_.hourly) && _loc1_.hourly != this.HourlyRate.getVal())
         {
            this.HourlyRate.setVal(_loc1_.hourly);
         }
      }
      
      public function addToEstimate() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:GWizCCWEstRecord = null;
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         if(!GWizCadCam.CADCAMWiz || addEstimatorItem == null)
         {
            return;
         }
         if(GWizCadCam._needRecalc)
         {
            GWizPopUpManager.Show("Please Recalc before Add to Estimate.","Error: Need to Recalc",GWizPopUpManager.ERROR);
            return;
         }
         if(this.wizard && this.wizard.results && GWizCadCam.CADCAMWiz)
         {
            this.setHourlyRate();
            _loc1_ = 0;
            while(_loc1_ < this.Qty.getVal())
            {
               _loc2_ = 0;
               while(_loc2_ < this.wizard.results.length)
               {
                  _loc3_ = GWizCCWEstRecord(this.wizard.results.getItemAt(_loc2_)).clone();
                  _loc3_.material = GWizSettings.FeedsSpeedsApp.mmsDefault.MatChooser.Selection;
                  if(this.EstDesc.text == "")
                  {
                     this.EstDesc.text = GWizCadCam.currWizard;
                  }
                  _loc3_.desc = this.EstDesc.text;
                  _loc4_ = false;
                  if(_loc3_.desc != "Hole")
                  {
                     _loc4_ = true;
                  }
                  else if(_loc3_.op == "Rough" || _loc3_.op == "Finish")
                  {
                     _loc4_ = true;
                     _loc3_.desc = "Pocket";
                     _loc3_.op += "-Hole";
                  }
                  if(_loc4_)
                  {
                     _loc5_ = _loc3_.desc;
                     _loc3_.desc = _loc3_.op;
                     _loc3_.op = _loc5_;
                  }
                  if(this.Qty.getVal() > 1 && this.Expand.selected)
                  {
                     _loc3_.desc += " #" + String(_loc1_ + 1);
                  }
                  _loc3_.perimeter = _loc3_.pathLenByType();
                  _loc3_.opTime += GWizMachSettings.getToolChangeTime();
                  if(!this.Expand.selected)
                  {
                     _loc3_.qty = this.Qty.getVal();
                     _loc3_.opTime *= this.Qty.getVal();
                     _loc1_ = this.Qty.getVal();
                  }
                  else
                  {
                     _loc3_.qty = 1;
                  }
                  if(_loc3_.hasOwnProperty("opTime"))
                  {
                     _loc3_.oprate = this.HourlyRate.getVal() * (_loc3_.opTime / 60);
                  }
                  addEstimatorItem(_loc3_,isFixedCost());
                  _loc2_++;
               }
               _loc1_++;
            }
            this.Qty.setVal(1);
         }
      }
      
      private function _GWizCCWEstimatorInput_Array1_c() : Array
      {
         return [this._GWizCCWEstimatorInput_VGroup1_i()];
      }
      
      private function _GWizCCWEstimatorInput_VGroup1_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCCWEstimatorInput_HGroup1_c(),this._GWizCCWEstimatorInput_TextArea1_i()];
         _loc1_.id = "vGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.vGrp = _loc1_;
         BindingManager.executeBindings(this,"vGrp",this.vGrp);
         return _loc1_;
      }
      
      private function _GWizCCWEstimatorInput_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWEstimatorInput_GWizNumStep1_i(),this._GWizCCWEstimatorInput_CheckBox1_i(),this._GWizCCWEstimatorInput_GWizNumStep2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWEstimatorInput_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Qty";
         _loc1_.min = 1;
         _loc1_.max = 1000;
         _loc1_.steps = 1;
         _loc1_.value = 1;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.id = "Qty";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Qty = _loc1_;
         BindingManager.executeBindings(this,"Qty",this.Qty);
         return _loc1_;
      }
      
      private function _GWizCCWEstimatorInput_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Expand";
         _loc1_.toolTip = "If checked, expand Qty to multiple line items.";
         _loc1_.selected = false;
         _loc1_.id = "Expand";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Expand = _loc1_;
         BindingManager.executeBindings(this,"Expand",this.Expand);
         return _loc1_;
      }
      
      private function _GWizCCWEstimatorInput_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "$/Hour";
         _loc1_.min = 0;
         _loc1_.max = 100000;
         _loc1_.steps = 0.01;
         _loc1_.value = 0;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.id = "HourlyRate";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HourlyRate = _loc1_;
         BindingManager.executeBindings(this,"HourlyRate",this.HourlyRate);
         return _loc1_;
      }
      
      private function _GWizCCWEstimatorInput_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.prompt = "Enter description";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("color",0);
         _loc1_.id = "EstDesc";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EstDesc = _loc1_;
         BindingManager.executeBindings(this,"EstDesc",this.EstDesc);
         return _loc1_;
      }
      
      public function ___GWizCCWEstimatorInput_GWizForePanel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCCWEstimatorInput_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return addEstimatorItem != null;
         },null,"this.visible");
         result[1] = new Binding(this,function():Boolean
         {
            return addEstimatorItem != null;
         },null,"this.includeInLayout");
         result[2] = new Binding(this,function():Number
         {
            return Qty.height;
         },null,"EstDesc.height");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get EstDesc() : TextArea
      {
         return this._214851863EstDesc;
      }
      
      public function set EstDesc(param1:TextArea) : void
      {
         var _loc2_:Object = this._214851863EstDesc;
         if(_loc2_ !== param1)
         {
            this._214851863EstDesc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EstDesc",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Expand() : CheckBox
      {
         return this._2089667258Expand;
      }
      
      public function set Expand(param1:CheckBox) : void
      {
         var _loc2_:Object = this._2089667258Expand;
         if(_loc2_ !== param1)
         {
            this._2089667258Expand = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Expand",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HourlyRate() : GWizNumStep
      {
         return this._975235311HourlyRate;
      }
      
      public function set HourlyRate(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._975235311HourlyRate;
         if(_loc2_ !== param1)
         {
            this._975235311HourlyRate = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HourlyRate",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Qty() : GWizNumStep
      {
         return this._81558Qty;
      }
      
      public function set Qty(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._81558Qty;
         if(_loc2_ !== param1)
         {
            this._81558Qty = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Qty",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get vGrp() : VGroup
      {
         return this._3587215vGrp;
      }
      
      public function set vGrp(param1:VGroup) : void
      {
         var _loc2_:Object = this._3587215vGrp;
         if(_loc2_ !== param1)
         {
            this._3587215vGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"vGrp",_loc2_,param1));
            }
         }
      }
   }
}
