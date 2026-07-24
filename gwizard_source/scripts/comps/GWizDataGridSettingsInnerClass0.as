package comps
{
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.CheckBox;
   import spark.components.gridClasses.GridColumn;
   import spark.components.gridClasses.GridItemRenderer;
   
   use namespace mx_internal;
   
   public class GWizDataGridSettingsInnerClass0 extends GridItemRenderer implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizDataGridSettings");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _3167cb:CheckBox;
      
      private var _88844982outerDocument:GWizDataGridSettings;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizDataGridSettingsInnerClass0()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizDataGridSettingsInnerClass0_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizDataGridSettingsInnerClass0WatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizDataGridSettingsInnerClass0[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._GWizDataGridSettingsInnerClass0_CheckBox1_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizDataGridSettingsInnerClass0._watcherSetupUtil = param1;
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
      
      override public function prepare(param1:Boolean) : void
      {
         this.cb.enabled = !!data ? Boolean(this.shouldBeEnabled(data.visible)) : true;
      }
      
      protected function shouldBeEnabled(param1:Boolean) : Boolean
      {
         return this.visibleColumnCount() == 1 ? !param1 : true;
      }
      
      private function visibleColumnCount() : int
      {
         var _loc3_:GridColumn = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < grid.dataProvider.length)
         {
            _loc3_ = grid.dataProvider.getItemAt(_loc2_) as GridColumn;
            if(_loc3_.visible)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      protected function onCheckBoxChange(param1:Event, param2:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:GWizGridColumn = null;
         param2.visible = param1.target.selected;
         var _loc3_:int = this.visibleColumnCount();
         if(_loc3_ == 1 || _loc3_ == 2 && param2.visible)
         {
            _loc4_ = 0;
            while(_loc4_ < this.outerDocument.columnGrid.dataProviderLength)
            {
               _loc5_ = this.outerDocument.columnGrid.dataProvider.getItemAt(_loc4_) as GWizGridColumn;
               grid.dataProvider.itemUpdated(_loc5_);
               _loc4_++;
            }
         }
      }
      
      private function _GWizDataGridSettingsInnerClass0_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.verticalCenter = 0;
         _loc1_.horizontalCenter = 0;
         _loc1_.buttonMode = true;
         _loc1_.addEventListener("change",this.__cb_change);
         _loc1_.id = "cb";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cb = _loc1_;
         BindingManager.executeBindings(this,"cb",this.cb);
         return _loc1_;
      }
      
      public function __cb_change(param1:Event) : void
      {
         this.onCheckBoxChange(param1,data);
      }
      
      private function _GWizDataGridSettingsInnerClass0_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return data.visible;
         },null,"cb.selected");
         result[1] = new Binding(this,function():String
         {
            var _loc1_:* = !!data.visible ? "Hide column" : "Show column";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"cb.toolTip");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get cb() : CheckBox
      {
         return this._3167cb;
      }
      
      public function set cb(param1:CheckBox) : void
      {
         var _loc2_:Object = this._3167cb;
         if(_loc2_ !== param1)
         {
            this._3167cb = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cb",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizDataGridSettings
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizDataGridSettings) : void
      {
         var _loc2_:Object = this._88844982outerDocument;
         if(_loc2_ !== param1)
         {
            this._88844982outerDocument = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outerDocument",_loc2_,param1));
            }
         }
      }
   }
}
