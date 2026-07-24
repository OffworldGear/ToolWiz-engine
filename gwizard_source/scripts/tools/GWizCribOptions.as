package tools
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.DropDownList;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class GWizCribOptions extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizCribOptions");
      
      public static var _479017323TableTypes:ArrayCollection = new ArrayCollection([{"label":"Catalog: Just a collection of tools for my own purposes."},{"label":"Job: Tools needed for a particular job or part program."},{"label":"Machine: Tools located with a machine in toolchanger or spindle."},{"label":"Storage: Tools located in holders in storage."},{"label":"Bin: Loose tools without holders."},{"label":"Cart: Tools located on a cart."}]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      public var _GWizCribOptions_DropDownList1:DropDownList;
      
      private var _844083586maxSlot:GWizNumStep;
      
      private var _1982855674optionsPanel:GWizForePanel;
      
      private var _853113013typeGrp:RadioButtonGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCribOptions()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCribOptions_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizCribOptionsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCribOptions[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Tool Table Options...";
         this.width = 700;
         this.okLabel = "Save";
         this.cancelLabel = "";
         this.mxmlContent = [this._GWizCribOptions_VGroup1_c()];
         this._GWizCribOptions_RadioButtonGroup1_i();
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCribOptions._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get TableTypes() : ArrayCollection
      {
         return GWizCribOptions._479017323TableTypes;
      }
      
      public static function set TableTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCribOptions._479017323TableTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCribOptions,"TableTypes",_loc2_,param1));
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
      
      override public function onOk(param1:Event) : void
      {
         super.close();
      }
      
      private function _GWizCribOptions_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"typeGrp");
         this.typeGrp = _loc1_;
         BindingManager.executeBindings(this,"typeGrp",this.typeGrp);
         return _loc1_;
      }
      
      private function _GWizCribOptions_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCribOptions_GWizForePanel1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribOptions_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.title = "Options";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribOptions_Array3_c);
         _loc1_.id = "optionsPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.optionsPanel = _loc1_;
         BindingManager.executeBindings(this,"optionsPanel",this.optionsPanel);
         return _loc1_;
      }
      
      private function _GWizCribOptions_Array3_c() : Array
      {
         return [this._GWizCribOptions_VGroup2_c()];
      }
      
      private function _GWizCribOptions_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCribOptions_DropDownList1_i(),this._GWizCribOptions_GWizNumStep1_i()];
         _loc1_.setStyle("color",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribOptions_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.percentWidth = 100;
         _loc1_.id = "_GWizCribOptions_DropDownList1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribOptions_DropDownList1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribOptions_DropDownList1",this._GWizCribOptions_DropDownList1);
         return _loc1_;
      }
      
      private function _GWizCribOptions_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "# of Slots (0 = unlimited):";
         _loc1_.min = 1;
         _loc1_.max = 5000;
         _loc1_.steps = 1;
         _loc1_.value = 0;
         _loc1_.noUnits = true;
         _loc1_.id = "maxSlot";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.maxSlot = _loc1_;
         BindingManager.executeBindings(this,"maxSlot",this.maxSlot);
         return _loc1_;
      }
      
      private function _GWizCribOptions_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"optionsPanel.labelBackgroundColor");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"optionsPanel.labelColor");
         result[2] = new Binding(this,function():IList
         {
            return TableTypes;
         },null,"_GWizCribOptions_DropDownList1.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get maxSlot() : GWizNumStep
      {
         return this._844083586maxSlot;
      }
      
      public function set maxSlot(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._844083586maxSlot;
         if(_loc2_ !== param1)
         {
            this._844083586maxSlot = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"maxSlot",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get optionsPanel() : GWizForePanel
      {
         return this._1982855674optionsPanel;
      }
      
      public function set optionsPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1982855674optionsPanel;
         if(_loc2_ !== param1)
         {
            this._1982855674optionsPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"optionsPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get typeGrp() : RadioButtonGroup
      {
         return this._853113013typeGrp;
      }
      
      public function set typeGrp(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._853113013typeGrp;
         if(_loc2_ !== param1)
         {
            this._853113013typeGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"typeGrp",_loc2_,param1));
            }
         }
      }
   }
}
