package comps
{
   import flash.events.Event;
   import flash.events.MouseEvent;
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
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.gridClasses.GridItemRenderer;
   
   use namespace mx_internal;
   
   public class GWizDataGridSettingsInnerClass2 extends GridItemRenderer implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizDataGridSettings");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizDataGridSettingsInnerClass2_Button1:Button;
      
      private var _88844982outerDocument:GWizDataGridSettings;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private const sortIncreaseImage:Class = GWizDataGridSettingsInnerClass2_sortIncreaseImage;
      
      private const sortDecreaseImage:Class = GWizDataGridSettingsInnerClass2_sortDecreaseImage;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizDataGridSettingsInnerClass2()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizDataGridSettingsInnerClass2_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizDataGridSettingsInnerClass2WatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizDataGridSettingsInnerClass2[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._GWizDataGridSettingsInnerClass2_HGroup1_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizDataGridSettingsInnerClass2._watcherSetupUtil = param1;
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
      
      private function onClick(param1:Event, param2:Object) : void
      {
         var _loc3_:GWizGridColumn = null;
         var _loc4_:GWizDataGrid = null;
         var _loc7_:GWizGridColumn = null;
         _loc3_ = param2 as GWizGridColumn;
         var _loc6_:int = (_loc5_ = (_loc4_ = _loc3_.grid.dataGrid as GWizDataGrid).columnHeaderGroup.visibleSortIndicatorIndices) != null && _loc5_.length > 0 ? int(_loc5_[0]) : -1;
         log.debug("This log statement is here to circumvent flex bug ASC-2993, which is supposedly fixed in 4.6.1.23860: " + _loc3_.columnIndex);
         _loc4_.rotateSortDirection(_loc3_.columnIndex);
         _loc3_.sortDescending = !_loc3_.sortDescending;
         _loc3_.sortDescending = !_loc3_.sortDescending;
         if(_loc6_ != -1 && _loc6_ != _loc3_.columnIndex)
         {
            _loc7_ = _loc4_.columns.getItemAt(_loc6_) as GWizGridColumn;
            _loc7_.sortDescending = !_loc7_.sortDescending;
            _loc7_.sortDescending = !_loc7_.sortDescending;
         }
      }
      
      private function sortIndicator(param1:Object, param2:Boolean) : Object
      {
         var _loc3_:GWizGridColumn = null;
         _loc3_ = param1 as GWizGridColumn;
         var _loc4_:GWizDataGrid;
         var _loc5_:Vector.<int> = (_loc4_ = _loc3_.grid.dataGrid as GWizDataGrid).columnHeaderGroup.visibleSortIndicatorIndices;
         var _loc6_:Object = null;
         if(_loc5_ != null && _loc5_.length > 0 && _loc3_.columnIndex == _loc5_[0])
         {
            _loc6_ = !!_loc3_.sortDescending ? this.sortDecreaseImage : this.sortIncreaseImage;
         }
         return _loc6_;
      }
      
      private function sortToolTip(param1:Object, param2:Boolean) : Object
      {
         var _loc3_:GWizGridColumn = null;
         _loc3_ = param1 as GWizGridColumn;
         var _loc4_:GWizDataGrid;
         var _loc5_:Vector.<int> = (_loc4_ = _loc3_.grid.dataGrid as GWizDataGrid).columnHeaderGroup.visibleSortIndicatorIndices;
         var _loc6_:Object = "Sort in ascending order";
         if(_loc5_ != null && _loc5_.length > 0 && _loc3_.columnIndex == _loc5_[0])
         {
            _loc6_ = !!_loc3_.sortDescending ? "Remove sorting" : "Sort in descending order";
         }
         return _loc6_;
      }
      
      private function _GWizDataGridSettingsInnerClass2_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 2;
         _loc1_.paddingBottom = 2;
         _loc1_.paddingLeft = 1;
         _loc1_.paddingRight = 1;
         _loc1_.mxmlContent = [this._GWizDataGridSettingsInnerClass2_Button1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDataGridSettingsInnerClass2_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.width = 22;
         _loc1_.height = 22;
         _loc1_.setStyle("cornerRadius",2);
         _loc1_.addEventListener("click",this.___GWizDataGridSettingsInnerClass2_Button1_click);
         _loc1_.id = "_GWizDataGridSettingsInnerClass2_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizDataGridSettingsInnerClass2_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizDataGridSettingsInnerClass2_Button1",this._GWizDataGridSettingsInnerClass2_Button1);
         return _loc1_;
      }
      
      public function ___GWizDataGridSettingsInnerClass2_Button1_click(param1:MouseEvent) : void
      {
         this.onClick(param1,data);
      }
      
      private function _GWizDataGridSettingsInnerClass2_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Object
         {
            return sortIndicator(data,data.sortDescending);
         },function(param1:Object):void
         {
            _GWizDataGridSettingsInnerClass2_Button1.setStyle("icon",param1);
         },"_GWizDataGridSettingsInnerClass2_Button1.icon");
         result[1] = new Binding(this,function():String
         {
            var _loc1_:* = sortToolTip(data,data.sortDescending);
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizDataGridSettingsInnerClass2_Button1.toolTip");
         return result;
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
