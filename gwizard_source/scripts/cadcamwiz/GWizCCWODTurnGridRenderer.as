package cadcamwiz
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import spark.components.DropDownList;
   import spark.components.gridClasses.GridItemRenderer;
   import spark.events.IndexChangeEvent;
   import spark.layouts.VerticalLayout;
   
   use namespace mx_internal;
   
   public class GWizCCWODTurnGridRenderer extends GridItemRenderer implements IBindingClient
   {
      
      private static var _214501564edgeTypes:ArrayCollection = new ArrayCollection([{"label":"None"},{"label":"Radius"},{"label":"Chamfer"}]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _3322014list:DropDownList;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWODTurnGridRenderer()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWODTurnGridRenderer_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWODTurnGridRendererWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWODTurnGridRenderer[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.layout = this._GWizCCWODTurnGridRenderer_VerticalLayout1_c();
         this.mxmlContent = [this._GWizCCWODTurnGridRenderer_DropDownList1_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWODTurnGridRenderer._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get edgeTypes() : ArrayCollection
      {
         return GWizCCWODTurnGridRenderer._214501564edgeTypes;
      }
      
      public static function set edgeTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWODTurnGridRenderer._214501564edgeTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWODTurnGridRenderer,"edgeTypes",_loc2_,param1));
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
      
      private function cornerIndexOf(param1:String) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < edgeTypes.length)
         {
            if(edgeTypes.getItemAt(_loc2_).label == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return 0;
      }
      
      protected function onDdChange(param1:IndexChangeEvent) : void
      {
         var _loc2_:String = edgeTypes.getItemAt((param1.currentTarget as DropDownList).selectedIndex).label;
         data.corner = _loc2_;
         if(GWizCCWODTurnGrid.recalc != null)
         {
            GWizCCWODTurnGrid.recalc();
         }
      }
      
      private function _GWizCCWODTurnGridRenderer_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizCCWODTurnGridRenderer_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 88;
         _loc1_.labelField = "label";
         _loc1_.addEventListener("change",this.__list_change);
         _loc1_.id = "list";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.list = _loc1_;
         BindingManager.executeBindings(this,"list",this.list);
         return _loc1_;
      }
      
      public function __list_change(param1:IndexChangeEvent) : void
      {
         this.onDdChange(param1);
      }
      
      private function _GWizCCWODTurnGridRenderer_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():int
         {
            return cornerIndexOf(data.corner);
         },null,"list.selectedIndex");
         result[1] = new Binding(this,function():IList
         {
            return edgeTypes;
         },null,"list.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get list() : DropDownList
      {
         return this._3322014list;
      }
      
      public function set list(param1:DropDownList) : void
      {
         var _loc2_:Object = this._3322014list;
         if(_loc2_ !== param1)
         {
            this._3322014list = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"list",_loc2_,param1));
            }
         }
      }
   }
}
