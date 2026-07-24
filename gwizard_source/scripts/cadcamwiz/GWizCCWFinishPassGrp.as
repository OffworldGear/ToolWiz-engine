package cadcamwiz
{
   import comps.GWizNumStep;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   
   use namespace mx_internal;
   
   public class GWizCCWFinishPassGrp extends HGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1150107804FinishPass:GWizNumStep;
      
      private var _911098630useFinish:CheckBox;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _934922488recalc:Function;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWFinishPassGrp()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWFinishPassGrp_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWFinishPassGrpWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWFinishPassGrp[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.height = 30;
         this.mxmlContent = [this._GWizCCWFinishPassGrp_CheckBox1_i(),this._GWizCCWFinishPassGrp_GWizNumStep1_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWFinishPassGrp._watcherSetupUtil = param1;
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
      
      private function _GWizCCWFinishPassGrp_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Finish Pass:";
         _loc1_.selected = true;
         _loc1_.addEventListener("change",this.__useFinish_change);
         _loc1_.id = "useFinish";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.useFinish = _loc1_;
         BindingManager.executeBindings(this,"useFinish",this.useFinish);
         return _loc1_;
      }
      
      public function __useFinish_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWFinishPassGrp_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__FinishPass_initialize);
         _loc1_.addEventListener("change",this.__FinishPass_change);
         _loc1_.id = "FinishPass";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FinishPass = _loc1_;
         BindingManager.executeBindings(this,"FinishPass",this.FinishPass);
         return _loc1_;
      }
      
      public function __FinishPass_initialize(param1:FlexEvent) : void
      {
         this.FinishPass.setVal(0.015);
      }
      
      public function __FinishPass_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWFinishPassGrp_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return useFinish.selected;
         },null,"FinishPass.enabled");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get FinishPass() : GWizNumStep
      {
         return this._1150107804FinishPass;
      }
      
      public function set FinishPass(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1150107804FinishPass;
         if(_loc2_ !== param1)
         {
            this._1150107804FinishPass = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FinishPass",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get useFinish() : CheckBox
      {
         return this._911098630useFinish;
      }
      
      public function set useFinish(param1:CheckBox) : void
      {
         var _loc2_:Object = this._911098630useFinish;
         if(_loc2_ !== param1)
         {
            this._911098630useFinish = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"useFinish",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get recalc() : Function
      {
         return this._934922488recalc;
      }
      
      public function set recalc(param1:Function) : void
      {
         var _loc2_:Object = this._934922488recalc;
         if(_loc2_ !== param1)
         {
            this._934922488recalc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"recalc",_loc2_,param1));
            }
         }
      }
   }
}
