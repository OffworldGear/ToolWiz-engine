package tools
{
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.DataGrid;
   import spark.components.gridClasses.GridColumn;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizPropertyList extends DataGrid implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizPropertyList");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _864743405propertyList:ArrayCollection;
      
      private var _unitFields:Array;
      
      private var unitFieldHash:Object;
      
      private var _data:Object;
      
      public var fieldList:Array = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizPropertyList()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._864743405propertyList = new ArrayCollection();
         this._unitFields = [];
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         var bindings:Array = this._GWizPropertyList_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizPropertyListWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizPropertyList[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.editable = false;
         this.columns = this._GWizPropertyList_ArrayList1_c();
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizPropertyList._watcherSetupUtil = param1;
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
      
      public function set unitFields(param1:Array) : void
      {
         this._unitFields = param1;
         this.buildUnitFieldHash();
      }
      
      private function buildUnitFieldHash() : void
      {
         this.unitFieldHash = new Object();
         var _loc1_:int = 0;
         while(_loc1_ < this._unitFields.length)
         {
            this.unitFieldHash[GWizStringUtils.camelToProperCase(this._unitFields[_loc1_])] = true;
            _loc1_++;
         }
      }
      
      public function refresh() : void
      {
         this.data = this._data;
      }
      
      public function set data(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:XML = null;
         var _loc6_:int = 0;
         if(param1)
         {
            this._data = param1;
            this.propertyList.removeAll();
            if(!this.fieldList || this.fieldList.length == 0)
            {
               _loc3_ = describeType(param1);
               _loc4_ = _loc3_..variable;
               for each(_loc5_ in _loc4_)
               {
                  _loc2_ = new Object();
                  _loc2_.name = String(_loc5_.@name);
                  _loc2_.value = String(param1[_loc2_.name]);
                  _loc2_.value = this.unitConvert(_loc2_.name,_loc2_.value);
                  this.propertyList.addItem(_loc2_);
               }
            }
            else
            {
               _loc6_ = 0;
               while(_loc6_ < this.fieldList.length)
               {
                  _loc2_ = new Object();
                  if(GWizUtils.debug && this.fieldList[_loc6_] == null)
                  {
                     log.debug("gotcha");
                  }
                  _loc2_.name = GWizStringUtils.camelToProperCase(this.fieldList[_loc6_]);
                  _loc2_.value = String(param1[this.fieldList[_loc6_]]);
                  _loc2_.value = this.unitConvert(_loc2_.name,_loc2_.value);
                  this.propertyList.addItem(_loc2_);
                  _loc6_++;
               }
            }
            this.propertyList.refresh();
         }
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      private function unitConvert(param1:String, param2:Object) : Object
      {
         var _loc3_:Number = NaN;
         if(!this.unitFieldHash)
         {
            this.buildUnitFieldHash();
         }
         if(this.unitFieldHash.hasOwnProperty(param1))
         {
            _loc3_ = Number(param2);
            if(!isNaN(_loc3_))
            {
               _loc3_ = Number(GWizUtils.formatPlaces(_loc3_,4,true,GWizUtils.MM_UNITS));
               param2 = _loc3_;
            }
         }
         return param2;
      }
      
      private function _GWizPropertyList_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizPropertyList_GridColumn1_c(),this._GWizPropertyList_GridColumn2_c()];
         return _loc1_;
      }
      
      private function _GWizPropertyList_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Property";
         _loc1_.dataField = "name";
         return _loc1_;
      }
      
      private function _GWizPropertyList_GridColumn2_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Value";
         _loc1_.dataField = "value";
         return _loc1_;
      }
      
      private function _GWizPropertyList_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return propertyList;
         },null,"this.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      private function get propertyList() : ArrayCollection
      {
         return this._864743405propertyList;
      }
      
      private function set propertyList(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._864743405propertyList;
         if(_loc2_ !== param1)
         {
            this._864743405propertyList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"propertyList",_loc2_,param1));
            }
         }
      }
   }
}
