package comps
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizLumberSizes extends GWizPopUp implements IBindingClient
   {
      
      public static var _1693269287LumberSizes:ArrayCollection = new ArrayCollection([{
         "NominalSz":"1 X 3",
         "Height":0.75,
         "Width":2.5
      },{
         "NominalSz":"1 X 4",
         "Height":0.75,
         "Width":3.5
      },{
         "NominalSz":"1 X 6",
         "Height":0.75,
         "Width":5.5
      },{
         "NominalSz":"1 X 8",
         "Height":0.75,
         "Width":7.25
      },{
         "NominalSz":"1 X 10",
         "Height":0.75,
         "Width":9.25
      },{
         "NominalSz":"1 X 12",
         "Height":0.75,
         "Width":11.25
      },{
         "NominalSz":"2 X 3",
         "Height":1.5,
         "Width":2.5
      },{
         "NominalSz":"2 X 4",
         "Height":1.5,
         "Width":3.5
      },{
         "NominalSz":"2 X 6",
         "Height":1.5,
         "Width":5.5
      },{
         "NominalSz":"2 X 8",
         "Height":1.5,
         "Width":7.25
      },{
         "NominalSz":"2 X 10",
         "Height":1.5,
         "Width":9.25
      },{
         "NominalSz":"2 X 12",
         "Height":1.5,
         "Width":11.25
      },{
         "NominalSz":"2 X 14",
         "Height":1.5,
         "Width":13.25
      },{
         "NominalSz":"3 X 3",
         "Height":2.5,
         "Width":2.5
      },{
         "NominalSz":"3 X 4",
         "Height":2.5,
         "Width":3.5
      },{
         "NominalSz":"3 X 6",
         "Height":2.5,
         "Width":5.5
      },{
         "NominalSz":"3 X 8",
         "Height":2.5,
         "Width":7.25
      },{
         "NominalSz":"3 X 10",
         "Height":2.5,
         "Width":9.25
      },{
         "NominalSz":"3 X 12",
         "Height":2.5,
         "Width":11.25
      },{
         "NominalSz":"3 X 14",
         "Height":2.5,
         "Width":13.25
      },{
         "NominalSz":"3 X 16",
         "Height":2.5,
         "Width":15.25
      },{
         "NominalSz":"4 X 4",
         "Height":3.5,
         "Width":3.5
      },{
         "NominalSz":"4 X 6",
         "Height":3.5,
         "Width":5.5
      },{
         "NominalSz":"4 X 8",
         "Height":3.5,
         "Width":7.25
      },{
         "NominalSz":"4 X 10",
         "Height":3.5,
         "Width":9.25
      },{
         "NominalSz":"4 X 12",
         "Height":3.5,
         "Width":11.25
      },{
         "NominalSz":"4 X 14",
         "Height":3.5,
         "Width":13.25
      },{
         "NominalSz":"4 X 16",
         "Height":3.5,
         "Width":15.25
      },{
         "NominalSz":"6 X 6",
         "Height":5.5,
         "Width":5.5
      },{
         "NominalSz":"6 X 8",
         "Height":5.5,
         "Width":7.5
      },{
         "NominalSz":"6 X 10",
         "Height":5.5,
         "Width":9.5
      },{
         "NominalSz":"6 X 12",
         "Height":5.5,
         "Width":11.5
      },{
         "NominalSz":"6 X 14",
         "Height":5.5,
         "Width":13.5
      },{
         "NominalSz":"6 X 16",
         "Height":5.5,
         "Width":15.5
      },{
         "NominalSz":"6 X 18",
         "Height":5.5,
         "Width":17.5
      },{
         "NominalSz":"8 X 8",
         "Height":7.5,
         "Width":7.5
      },{
         "NominalSz":"8 X 10",
         "Height":7.5,
         "Width":9.5
      },{
         "NominalSz":"8 X 12",
         "Height":7.5,
         "Width":11.5
      },{
         "NominalSz":"8 X 14",
         "Height":7.5,
         "Width":13.5
      },{
         "NominalSz":"8 X 16",
         "Height":7.5,
         "Width":15.5
      },{
         "NominalSz":"8 X 18",
         "Height":7.5,
         "Width":17.5
      },{
         "NominalSz":"10 X 10",
         "Height":9.5,
         "Width":9.5
      },{
         "NominalSz":"10 X 12",
         "Height":9.5,
         "Width":11.5
      },{
         "NominalSz":"10 X 14",
         "Height":9.5,
         "Width":13.5
      },{
         "NominalSz":"10 X 16",
         "Height":9.5,
         "Width":15.5
      },{
         "NominalSz":"10 X 18",
         "Height":9.5,
         "Width":17.5
      },{
         "NominalSz":"12 X 12",
         "Height":11.5,
         "Width":11.5
      },{
         "NominalSz":"12 X 14",
         "Height":11.5,
         "Width":13.5
      },{
         "NominalSz":"12 X 16",
         "Height":11.5,
         "Width":15.5
      }]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _79900786Sizes:GWizDataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var okFunction:Function = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizLumberSizes()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizLumberSizes_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizLumberSizesWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizLumberSizes[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Lumber Sizes";
         this.width = 500;
         this.mxmlContent = [this._GWizLumberSizes_VGroup1_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizLumberSizes._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get LumberSizes() : ArrayCollection
      {
         return GWizLumberSizes._1693269287LumberSizes;
      }
      
      public static function set LumberSizes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizLumberSizes._1693269287LumberSizes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizLumberSizes,"LumberSizes",_loc2_,param1));
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
         var factory:IFlexModuleFactory = param1;
         super.moduleFactory = factory;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
         if(!this.styleDeclaration)
         {
            this.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
         }
         this.styleDeclaration.defaultFactory = function():void
         {
            this.color = 16777215;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onOK(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         if(param1 && this.okFunction != null)
         {
            _loc2_ = this.Sizes.selectedItem;
            if(_loc2_)
            {
               this.okFunction(_loc2_.Height,_loc2_.Width);
            }
         }
         super.close();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.onOK(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.onOK(false);
      }
      
      private function _GWizLumberSizes_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizLumberSizes_GWizDataGrid1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLumberSizes_GWizDataGrid1_i() : GWizDataGrid
      {
         var _loc1_:GWizDataGrid = new GWizDataGrid();
         _loc1_.configId = "lumberSizes";
         _loc1_.percentWidth = 85;
         _loc1_.percentHeight = 100;
         _loc1_.columns = this._GWizLumberSizes_ArrayList1_c();
         _loc1_.setStyle("color",0);
         _loc1_.id = "Sizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Sizes = _loc1_;
         BindingManager.executeBindings(this,"Sizes",this.Sizes);
         return _loc1_;
      }
      
      private function _GWizLumberSizes_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizLumberSizes_GWizGridColumn1_c(),this._GWizLumberSizes_GWizGridColumn2_c(),this._GWizLumberSizes_GWizGridColumn3_c()];
         return _loc1_;
      }
      
      private function _GWizLumberSizes_GWizGridColumn1_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "nomSizes";
         _loc1_.dataField = "NominalSz";
         return _loc1_;
      }
      
      private function _GWizLumberSizes_GWizGridColumn2_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "height";
         _loc1_.dataField = "Height";
         return _loc1_;
      }
      
      private function _GWizLumberSizes_GWizGridColumn3_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "width";
         _loc1_.dataField = "Width";
         return _loc1_;
      }
      
      private function _GWizLumberSizes_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return LumberSizes;
         },null,"Sizes.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Sizes() : GWizDataGrid
      {
         return this._79900786Sizes;
      }
      
      public function set Sizes(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = this._79900786Sizes;
         if(_loc2_ !== param1)
         {
            this._79900786Sizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Sizes",_loc2_,param1));
            }
         }
      }
   }
}
