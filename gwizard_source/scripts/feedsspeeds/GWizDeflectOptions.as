package feedsspeeds
{
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizDeflectOptions extends VGroup implements IBindingClient
   {
      
      private static var _2047659091bestFinishAux:Boolean = false;
      
      private static var _87092822limitChatterAux:Boolean = true;
      
      private static var runoutVsToolLife:ArrayCollection = new ArrayCollection([{
         "runout":0,
         "life":1
      },{
         "runout":0.04,
         "life":0.97
      },{
         "runout":0.1,
         "life":0.96
      },{
         "runout":0.2,
         "life":0.92
      },{
         "runout":0.3,
         "life":0.86
      },{
         "runout":0.4,
         "life":0.76
      },{
         "runout":0.5,
         "life":0.61
      },{
         "runout":0.6,
         "life":0.46
      },{
         "runout":0.7,
         "life":0.24
      },{
         "runout":0.8,
         "life":0
      }]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _916637358DeflectPct:NumericStepper;
      
      public var _GWizDeflectOptions_HGroup1:HGroup;
      
      private var _587568023bestFinish:CheckBox;
      
      private var _1405722877deflectToolLife:Label;
      
      private var _983236210limitChatter:CheckBox;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizDeflectOptions()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizDeflectOptions_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizDeflectOptionsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizDeflectOptions[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.verticalAlign = "middle";
         this.paddingLeft = 5;
         this.mxmlContent = [this._GWizDeflectOptions_CheckBox1_i(),this._GWizDeflectOptions_HGroup1_i(),this._GWizDeflectOptions_CheckBox2_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizDeflectOptions._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get bestFinishAux() : Boolean
      {
         return GWizDeflectOptions._2047659091bestFinishAux;
      }
      
      public static function set bestFinishAux(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizDeflectOptions._2047659091bestFinishAux;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizDeflectOptions,"bestFinishAux",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get limitChatterAux() : Boolean
      {
         return GWizDeflectOptions._87092822limitChatterAux;
      }
      
      public static function set limitChatterAux(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizDeflectOptions._87092822limitChatterAux;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizDeflectOptions,"limitChatterAux",_loc2_,param1));
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
      
      private function updateToolLife() : void
      {
         var _loc3_:Object = null;
         var _loc1_:Number = this.DeflectPct.value / 100;
         var _loc2_:int = 0;
         while(_loc2_ < runoutVsToolLife.length)
         {
            _loc3_ = runoutVsToolLife.getItemAt(_loc2_);
            if(_loc3_.runout > _loc1_)
            {
               _loc3_ = runoutVsToolLife.getItemAt(_loc2_ - 1);
               this.deflectToolLife.text = _loc3_.life * 100 + "%";
               this.recalc();
               return;
            }
            _loc2_++;
         }
      }
      
      private function recalc() : void
      {
         GWizSettings.FeedsSpeedsApp.recalcAux();
      }
      
      private function _GWizDeflectOptions_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Limit Chatter";
         _loc1_.toolTip = "Lower deflection limit to minimize chatter.";
         _loc1_.addEventListener("valueCommit",this.__limitChatter_valueCommit);
         _loc1_.id = "limitChatter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.limitChatter = _loc1_;
         BindingManager.executeBindings(this,"limitChatter",this.limitChatter);
         return _loc1_;
      }
      
      public function __limitChatter_valueCommit(param1:FlexEvent) : void
      {
         limitChatterAux = this.limitChatter.selected;
         this.recalc();
      }
      
      private function _GWizDeflectOptions_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizDeflectOptions_Label1_c(),this._GWizDeflectOptions_NumericStepper1_i(),this._GWizDeflectOptions_Label2_c(),this._GWizDeflectOptions_Label3_i()];
         _loc1_.id = "_GWizDeflectOptions_HGroup1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizDeflectOptions_HGroup1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizDeflectOptions_HGroup1",this._GWizDeflectOptions_HGroup1);
         return _loc1_;
      }
      
      private function _GWizDeflectOptions_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Deflection Limit ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDeflectOptions_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 1;
         _loc1_.maximum = 79;
         _loc1_.stepSize = 1;
         _loc1_.addEventListener("change",this.__DeflectPct_change);
         _loc1_.addEventListener("valueCommit",this.__DeflectPct_valueCommit);
         _loc1_.id = "DeflectPct";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DeflectPct = _loc1_;
         BindingManager.executeBindings(this,"DeflectPct",this.DeflectPct);
         return _loc1_;
      }
      
      public function __DeflectPct_change(param1:Event) : void
      {
         GWizSettings.deflectPct = this.DeflectPct.value;
      }
      
      public function __DeflectPct_valueCommit(param1:FlexEvent) : void
      {
         this.updateToolLife();
      }
      
      private function _GWizDeflectOptions_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "% of max chipload for cutter.  Tool Life = ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDeflectOptions_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "100%";
         _loc1_.id = "deflectToolLife";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.deflectToolLife = _loc1_;
         BindingManager.executeBindings(this,"deflectToolLife",this.deflectToolLife);
         return _loc1_;
      }
      
      private function _GWizDeflectOptions_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Best Finish";
         _loc1_.toolTip = "Lower deflection limit on finish cuts to improve finish.";
         _loc1_.addEventListener("valueCommit",this.__bestFinish_valueCommit);
         _loc1_.id = "bestFinish";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.bestFinish = _loc1_;
         BindingManager.executeBindings(this,"bestFinish",this.bestFinish);
         return _loc1_;
      }
      
      public function __bestFinish_valueCommit(param1:FlexEvent) : void
      {
         bestFinishAux = this.bestFinish.selected;
         this.recalc();
      }
      
      private function _GWizDeflectOptions_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return limitChatterAux;
         },null,"limitChatter.selected");
         result[1] = new Binding(this,function():Boolean
         {
            return !limitChatter.selected;
         },null,"_GWizDeflectOptions_HGroup1.enabled");
         result[2] = new Binding(this,function():Number
         {
            return GWizSettings.deflectPct;
         },null,"DeflectPct.value");
         result[3] = new Binding(this,function():Boolean
         {
            return bestFinishAux;
         },null,"bestFinish.selected");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get DeflectPct() : NumericStepper
      {
         return this._916637358DeflectPct;
      }
      
      public function set DeflectPct(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._916637358DeflectPct;
         if(_loc2_ !== param1)
         {
            this._916637358DeflectPct = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DeflectPct",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get bestFinish() : CheckBox
      {
         return this._587568023bestFinish;
      }
      
      public function set bestFinish(param1:CheckBox) : void
      {
         var _loc2_:Object = this._587568023bestFinish;
         if(_loc2_ !== param1)
         {
            this._587568023bestFinish = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bestFinish",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get deflectToolLife() : Label
      {
         return this._1405722877deflectToolLife;
      }
      
      public function set deflectToolLife(param1:Label) : void
      {
         var _loc2_:Object = this._1405722877deflectToolLife;
         if(_loc2_ !== param1)
         {
            this._1405722877deflectToolLife = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"deflectToolLife",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get limitChatter() : CheckBox
      {
         return this._983236210limitChatter;
      }
      
      public function set limitChatter(param1:CheckBox) : void
      {
         var _loc2_:Object = this._983236210limitChatter;
         if(_loc2_ !== param1)
         {
            this._983236210limitChatter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"limitChatter",_loc2_,param1));
            }
         }
      }
   }
}
