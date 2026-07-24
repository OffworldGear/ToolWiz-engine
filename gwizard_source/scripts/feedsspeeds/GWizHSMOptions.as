package feedsspeeds
{
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizHSMOptions extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _2107251069CutWidthPct:NumericStepper;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizHSMOptions()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizHSMOptions_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizHSMOptionsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizHSMOptions[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.verticalAlign = "middle";
         this.paddingLeft = 5;
         this.mxmlContent = [this._GWizHSMOptions_HGroup1_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizHSMOptions._watcherSetupUtil = param1;
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
      
      private function _GWizHSMOptions_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizHSMOptions_Label1_c(),this._GWizHSMOptions_NumericStepper1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizHSMOptions_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max Cut Width for HSM (% of Diameter) ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizHSMOptions_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 1;
         _loc1_.maximum = 100;
         _loc1_.stepSize = 1;
         _loc1_.addEventListener("change",this.__CutWidthPct_change);
         _loc1_.id = "CutWidthPct";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CutWidthPct = _loc1_;
         BindingManager.executeBindings(this,"CutWidthPct",this.CutWidthPct);
         return _loc1_;
      }
      
      public function __CutWidthPct_change(param1:Event) : void
      {
         GWizSettings.hsmWidthPct = this.CutWidthPct.value;
      }
      
      private function _GWizHSMOptions_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return GWizSettings.hsmWidthPct;
         },null,"CutWidthPct.value");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CutWidthPct() : NumericStepper
      {
         return this._2107251069CutWidthPct;
      }
      
      public function set CutWidthPct(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._2107251069CutWidthPct;
         if(_loc2_ !== param1)
         {
            this._2107251069CutWidthPct = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CutWidthPct",_loc2_,param1));
            }
         }
      }
   }
}
