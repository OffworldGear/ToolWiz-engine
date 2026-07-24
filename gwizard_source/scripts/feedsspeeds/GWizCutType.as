package feedsspeeds
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizCutType extends HGroup implements IBindingClient
   {
      
      private static var _1337900966finishTypes:ArrayCollection = new ArrayCollection(["Finish","Rough"]);
      
      private static var _670196599CutTypes:ArrayCollection = new ArrayCollection([{
         "cat":"Mill",
         "op":"Peripheral",
         "engage":true
      },{
         "cat":"Mill",
         "op":"Pocket",
         "engage":true
      },{
         "cat":"Mill",
         "op":"Slot",
         "engage":true
      },{
         "cat":"Mill",
         "op":"Helical",
         "engage":true
      },{
         "cat":"Mill",
         "op":"Facing",
         "engage":true
      },{
         "cat":"Mill",
         "op":"3D Profile",
         "engage":true
      },{
         "cat":"Mill",
         "op":"Plunge",
         "engage":true
      },{
         "cat":"Mill",
         "op":"Facing",
         "engage":true
      },{
         "cat":"Mill",
         "op":"Ramp"
      },{
         "cat":"Mill",
         "op":"Drilling"
      },{
         "cat":"Mill",
         "op":"Other"
      },{
         "cat":"Lathe",
         "op":"Turning"
      },{
         "cat":"Lathe",
         "op":"Facing"
      },{
         "cat":"Lathe",
         "op":"Parting/Grooving"
      },{
         "cat":"Lathe",
         "op":"Threading"
      },{
         "cat":"Lathe",
         "op":"Boring"
      },{
         "cat":"Lathe",
         "op":"Drilling"
      },{
         "cat":"Lathe",
         "op":"Other"
      }]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1502401412CutType:DropDownList;
      
      private var _653238924RoughFinish:DropDownList;
      
      private var _82928TEA:Label;
      
      private var _590180769cutDepth:Label;
      
      private var _607835300cutWidth:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var diameter:Number = 0.5;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCutType()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCutType_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizCutTypeWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCutType[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.verticalAlign = "middle";
         this.mxmlContent = [this._GWizCutType_Label1_c(),this._GWizCutType_Label2_i(),this._GWizCutType_Label3_c(),this._GWizCutType_Label4_i(),this._GWizCutType_Label5_c(),this._GWizCutType_DropDownList1_i(),this._GWizCutType_DropDownList2_i(),this._GWizCutType_Label6_c(),this._GWizCutType_Label7_i()];
         this.addEventListener("creationComplete",this.___GWizCutType_HGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function CutTypesLabelFcn(param1:Object) : String
      {
         var _loc2_:Number = Number(param1.toString());
         return CutTypeToString(_loc2_);
      }
      
      public static function CutTypeToString(param1:int) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(param1 < 0)
         {
            _loc2_ = "Lathe";
         }
         else
         {
            _loc2_ = "Mill";
         }
         CutTypes.refresh();
         param1 = Math.abs(param1);
         if(0 <= param1 && param1 <= CutTypes.length)
         {
            _loc3_ = CutTypes[param1].op;
         }
         else
         {
            _loc3_ = "Unknown Cut";
         }
         CutTypes.refresh();
         return _loc3_;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCutType._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get finishTypes() : ArrayCollection
      {
         return GWizCutType._1337900966finishTypes;
      }
      
      private static function set finishTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCutType._1337900966finishTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCutType,"finishTypes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get CutTypes() : ArrayCollection
      {
         return GWizCutType._670196599CutTypes;
      }
      
      public static function set CutTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCutType._670196599CutTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCutType,"CutTypes",_loc2_,param1));
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
         var _loc1_:Object = GWizMachSettings.lookupMachine(GWizMachSettings.currMachine);
         CutTypes.filterFunction = this.cutTypeFilter;
         CutTypes.refresh();
      }
      
      private function cutTypeFilter(param1:Object) : Boolean
      {
         var _loc2_:String = GWizMachSettings.currMachType;
         if(_loc2_ != "Lathe" && _loc2_ != "Mill")
         {
            _loc2_ = "Mill";
         }
         return param1.cat == _loc2_;
      }
      
      private function setTEA(param1:Number, param2:Number) : void
      {
         this.TEA.text = String(param1);
         this.cutWidth.text = String(GWizUtils.roundTenths(param2));
      }
      
      private function _GWizCutType_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cut Depth ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutType_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "cutDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutDepth = _loc1_;
         BindingManager.executeBindings(this,"cutDepth",this.cutDepth);
         return _loc1_;
      }
      
      private function _GWizCutType_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cut Width ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutType_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "cutWidth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutWidth = _loc1_;
         BindingManager.executeBindings(this,"cutWidth",this.cutWidth);
         return _loc1_;
      }
      
      private function _GWizCutType_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cut Type";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutType_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "op";
         _loc1_.setStyle("color",0);
         _loc1_.id = "CutType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CutType = _loc1_;
         BindingManager.executeBindings(this,"CutType",this.CutType);
         return _loc1_;
      }
      
      private function _GWizCutType_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.setStyle("color",0);
         _loc1_.id = "RoughFinish";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RoughFinish = _loc1_;
         BindingManager.executeBindings(this,"RoughFinish",this.RoughFinish);
         return _loc1_;
      }
      
      private function _GWizCutType_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "TEA: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutType_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "TEA";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TEA = _loc1_;
         BindingManager.executeBindings(this,"TEA",this.TEA);
         return _loc1_;
      }
      
      public function ___GWizCutType_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCutType_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return CutTypes;
         },null,"CutType.dataProvider");
         result[1] = new Binding(this,function():IList
         {
            return finishTypes;
         },null,"RoughFinish.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CutType() : DropDownList
      {
         return this._1502401412CutType;
      }
      
      public function set CutType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1502401412CutType;
         if(_loc2_ !== param1)
         {
            this._1502401412CutType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CutType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RoughFinish() : DropDownList
      {
         return this._653238924RoughFinish;
      }
      
      public function set RoughFinish(param1:DropDownList) : void
      {
         var _loc2_:Object = this._653238924RoughFinish;
         if(_loc2_ !== param1)
         {
            this._653238924RoughFinish = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RoughFinish",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TEA() : Label
      {
         return this._82928TEA;
      }
      
      public function set TEA(param1:Label) : void
      {
         var _loc2_:Object = this._82928TEA;
         if(_loc2_ !== param1)
         {
            this._82928TEA = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TEA",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutDepth() : Label
      {
         return this._590180769cutDepth;
      }
      
      public function set cutDepth(param1:Label) : void
      {
         var _loc2_:Object = this._590180769cutDepth;
         if(_loc2_ !== param1)
         {
            this._590180769cutDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutWidth() : Label
      {
         return this._607835300cutWidth;
      }
      
      public function set cutWidth(param1:Label) : void
      {
         var _loc2_:Object = this._607835300cutWidth;
         if(_loc2_ !== param1)
         {
            this._607835300cutWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutWidth",_loc2_,param1));
            }
         }
      }
   }
}
