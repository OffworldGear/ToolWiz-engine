package comps
{
   import bubbletip.GWizBubbleTip;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizImperialMetric extends HGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _2100399464Inches:RadioButton;
      
      public var _GWizImperialMetric_GWizBubbleTip1:GWizBubbleTip;
      
      private var _3488mm:RadioButton;
      
      private var _291770990unitsMsg:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _454770372unitsText:String = "";
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizImperialMetric()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizImperialMetric_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizImperialMetricWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizImperialMetric[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.verticalAlign = "baseline";
         this.mxmlContent = [this._GWizImperialMetric_Label1_c(),this._GWizImperialMetric_GWizBubbleTip1_i(),this._GWizImperialMetric_RadioButton2_i(),this._GWizImperialMetric_Label2_i()];
         this.addEventListener("creationComplete",this.___GWizImperialMetric_HGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizImperialMetric._watcherSetupUtil = param1;
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
         if(GWizSettings.gotPreferences)
         {
            if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
            {
               this.Inches.selected = true;
            }
            else
            {
               this.mm.selected = true;
            }
            this.unitsMsg.text = this.unitsText;
         }
         else
         {
            this.callLater(this.onCC);
         }
      }
      
      private function setUnitsAux() : void
      {
         if(this.Inches.selected)
         {
            GWizUtils.Units = GWizUtils.INCHES_UNITS;
         }
         else
         {
            GWizUtils.Units = GWizUtils.MM_UNITS;
         }
         GWizNumStep.checkUnitsCC.callChain(null);
      }
      
      private function _GWizImperialMetric_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Units";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizImperialMetric_GWizBubbleTip1_i() : GWizBubbleTip
      {
         var _loc1_:GWizBubbleTip = new GWizBubbleTip();
         _loc1_.bubbleID = "SettingUnits";
         _loc1_.mxmlContent = [this._GWizImperialMetric_RadioButton1_i()];
         _loc1_.id = "_GWizImperialMetric_GWizBubbleTip1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizImperialMetric_GWizBubbleTip1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizImperialMetric_GWizBubbleTip1",this._GWizImperialMetric_GWizBubbleTip1);
         return _loc1_;
      }
      
      private function _GWizImperialMetric_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Inches";
         _loc1_.addEventListener("click",this.__Inches_click);
         _loc1_.id = "Inches";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Inches = _loc1_;
         BindingManager.executeBindings(this,"Inches",this.Inches);
         return _loc1_;
      }
      
      public function __Inches_click(param1:MouseEvent) : void
      {
         this.setUnitsAux();
      }
      
      private function _GWizImperialMetric_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "mm";
         _loc1_.addEventListener("click",this.__mm_click);
         _loc1_.id = "mm";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mm = _loc1_;
         BindingManager.executeBindings(this,"mm",this.mm);
         return _loc1_;
      }
      
      public function __mm_click(param1:MouseEvent) : void
      {
         this.setUnitsAux();
      }
      
      private function _GWizImperialMetric_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 100;
         _loc1_.id = "unitsMsg";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.unitsMsg = _loc1_;
         BindingManager.executeBindings(this,"unitsMsg",this.unitsMsg);
         return _loc1_;
      }
      
      public function ___GWizImperialMetric_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizImperialMetric_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"_GWizImperialMetric_GWizBubbleTip1.myWindow");
         result[1] = new Binding(this,function():Boolean
         {
            return GWizUtils.Units == GWizUtils.INCHES_UNITS;
         },null,"Inches.selected");
         result[2] = new Binding(this,function():Boolean
         {
            return GWizUtils.Units != GWizUtils.INCHES_UNITS;
         },null,"mm.selected");
         result[3] = new Binding(this,null,null,"unitsMsg.text","unitsText");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Inches() : RadioButton
      {
         return this._2100399464Inches;
      }
      
      public function set Inches(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2100399464Inches;
         if(_loc2_ !== param1)
         {
            this._2100399464Inches = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Inches",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mm() : RadioButton
      {
         return this._3488mm;
      }
      
      public function set mm(param1:RadioButton) : void
      {
         var _loc2_:Object = this._3488mm;
         if(_loc2_ !== param1)
         {
            this._3488mm = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mm",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get unitsMsg() : Label
      {
         return this._291770990unitsMsg;
      }
      
      public function set unitsMsg(param1:Label) : void
      {
         var _loc2_:Object = this._291770990unitsMsg;
         if(_loc2_ !== param1)
         {
            this._291770990unitsMsg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"unitsMsg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get unitsText() : String
      {
         return this._454770372unitsText;
      }
      
      public function set unitsText(param1:String) : void
      {
         var _loc2_:Object = this._454770372unitsText;
         if(_loc2_ !== param1)
         {
            this._454770372unitsText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"unitsText",_loc2_,param1));
            }
         }
      }
   }
}
