package post
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.DataGrid;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import spark.components.gridClasses.GridColumn;
   import utils.GWizStringUtils;
   
   use namespace mx_internal;
   
   public class GWizWordMapper extends VGroup implements IBindingClient
   {
      
      private static var _836484122mapList:ArrayCollection = new ArrayCollection([]);
      
      private static var mapListHP:ArrayCollection = new ArrayCollection([]);
      
      public static var mappedHint:String = "";
      
      public static var doMapping:Boolean = true;
      
      public static var addSETVNFcn:Function = null;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _3202695hint:Label;
      
      private var _3322014list:DataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizWordMapper()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizWordMapper_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_post_GWizWordMapperWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizWordMapper[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentHeight = 100;
         this.percentWidth = 100;
         this.mxmlContent = [this._GWizWordMapper_HGroup1_c(),this._GWizWordMapper_DataGrid1_i(),this._GWizWordMapper_Label2_c(),this._GWizWordMapper_Label3_c(),this._GWizWordMapper_Label4_c()];
         this.addEventListener("creationComplete",this.___GWizWordMapper_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function clearMappings() : void
      {
         mapList.removeAll();
         doMapping = true;
      }
      
      public static function mapGCode(param1:String) : String
      {
         doMapping = mapList.length > 0 || mapListHP.length > 0;
         mappedHint = "";
         if(doMapping)
         {
            param1 = mapStr(param1,mapListHP);
            param1 = mapStr(param1,mapList);
         }
         return param1;
      }
      
      private static function mapStr(param1:String, param2:ArrayCollection) : String
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         param1 = param1.toUpperCase();
         param1 = GWizStringUtils.zapWhiteSpace(param1);
         var _loc3_:int = 0;
         while(_loc3_ < param2.length)
         {
            _loc5_ = (_loc4_ = param2.getItemAt(_loc3_)).search;
            _loc6_ = _loc4_.replace;
            _loc5_ = _loc5_.toUpperCase();
            _loc5_ = GWizStringUtils.zapWhiteSpace(_loc5_);
            _loc7_ = param1.replace(_loc5_,_loc6_);
            if(param1 != _loc7_)
            {
               if((_loc8_ = _loc4_.hint) && _loc8_.length > 0)
               {
                  mappedHint += _loc4_.hint + "\n";
               }
               param1 = _loc7_;
            }
            _loc3_++;
         }
         return param1;
      }
      
      public static function addTempMap(param1:String, param2:String, param3:String, param4:Boolean) : void
      {
         var _loc5_:int;
         if((_loc5_ = findMap(param1)) >= 0)
         {
            mapList.removeItemAt(_loc5_);
         }
         param3 += " " + param1 + " replaced with " + param2;
         var _loc6_:Object = {
            "search":param1,
            "replace":param2,
            "hint":param3,
            "temp":"true",
            "gwesetvn":param4
         };
         mapList.addItem(_loc6_);
         doMapping = true;
      }
      
      public static function addTempMapHP(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:int;
         if((_loc4_ = findMap(param1)) >= 0)
         {
            mapList.removeItemAt(_loc4_);
         }
         if(param3 != "")
         {
            param3 += " " + param1 + " replaced with " + param2;
         }
         var _loc5_:Object = {
            "search":param1,
            "replace":param2,
            "hint":param3,
            "temp":"true"
         };
         mapListHP.addItem(_loc5_);
         doMapping = true;
      }
      
      public static function addSETVN(param1:int, param2:Array, param3:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param2.length)
         {
            _loc5_ = param1 + _loc4_;
            addTempMap(param2[_loc4_],String(_loc5_),"SETVN variable name",param3);
            if(addSETVNFcn != null)
            {
               addSETVNFcn(param2[_loc4_],_loc5_);
            }
            _loc4_++;
         }
      }
      
      public static function clearTempMaps(param1:Boolean = false) : void
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < mapList.length)
         {
            _loc3_ = mapList.getItemAt(_loc2_);
            if(_loc3_.hasOwnProperty("temp") && _loc3_.temp == "true")
            {
               if(_loc3_.hasOwnProperty("gwesetvn") && _loc3_.gwesetvn == param1)
               {
                  mapList.removeItemAt(_loc2_);
                  _loc2_--;
               }
            }
            _loc2_++;
         }
      }
      
      private static function findMap(param1:String) : int
      {
         var _loc4_:Object = null;
         var _loc2_:int = -1;
         var _loc3_:int = 0;
         while(_loc3_ < mapList.length)
         {
            if((_loc4_ = mapList.getItemAt(_loc3_)).search == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function mapToPSTFile() : String
      {
         var _loc3_:Object = null;
         var _loc1_:String = "";
         var _loc2_:int = 0;
         while(_loc2_ < mapList.length)
         {
            _loc3_ = mapList.getItemAt(_loc2_);
            if(!_loc3_.hasOwnProperty("temp") || _loc3_.temp == "false")
            {
               _loc1_ += "Mapper.Entry" + _loc2_ + ".Search = " + _loc3_.search + ";\n";
               _loc1_ += "Mapper.Entry" + _loc2_ + ".Replace = " + _loc3_.replace + ";\n";
               _loc1_ += "Mapper.Entry" + _loc2_ + ".Hint = " + _loc3_.hint + ";\n";
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function savePSTCode(param1:String, param2:String) : Boolean
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc3_:int = param1.indexOf("Mapper.Entry");
         var _loc4_:Boolean = false;
         if(_loc3_ >= 0)
         {
            param1 = param1.substr(_loc3_ + "Mapper.Entry".length);
            _loc3_ = param1.indexOf(".");
            _loc5_ = param1.substr(0,_loc3_);
            if(!isNaN(Number(_loc5_)))
            {
               if((_loc6_ = int(_loc5_)) < mapList.length)
               {
                  _loc7_ = mapList.getItemAt(_loc6_);
               }
               else
               {
                  _loc7_ = new Object();
                  mapList.addItemAt(_loc7_,_loc6_);
                  doMapping = true;
               }
               if(param1.indexOf("Search") >= 0)
               {
                  _loc7_.search = param2;
                  _loc4_ = true;
               }
               else if(param1.indexOf("Replace") >= 0)
               {
                  _loc7_.replace = param2;
                  _loc4_ = true;
               }
               else if(param1.indexOf("Hint") >= 0)
               {
                  _loc7_.hint = param2;
                  _loc4_ = true;
               }
            }
         }
         return _loc4_;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizWordMapper._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get mapList() : ArrayCollection
      {
         return GWizWordMapper._836484122mapList;
      }
      
      private static function set mapList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizWordMapper._836484122mapList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizWordMapper,"mapList",_loc2_,param1));
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
         if(this.list)
         {
            this.list.selectedIndex = 0;
            this.setHint();
         }
      }
      
      private function setHint() : void
      {
         var _loc1_:Object = null;
         if(this.list && this.list.selectedItem)
         {
            _loc1_ = this.list.selectedItem;
            this.hint.text = "Hint: If block contains \'" + _loc1_.search + "\', replace it with \'" + _loc1_.replace + "\'";
            doMapping = true;
         }
      }
      
      private function doAdd() : void
      {
         var _loc1_:Object = {
            "search":"enter search string",
            "replace":"enter replace string",
            "hint":"enter hint string",
            "temp":"false"
         };
         mapList.addItem(_loc1_);
         doMapping = true;
      }
      
      private function doDelete() : void
      {
         if(this.list.selectedIndex >= 0)
         {
            mapList.removeItemAt(this.list.selectedIndex);
            doMapping = true;
         }
      }
      
      private function doDeleteAll() : void
      {
         clearMappings();
      }
      
      private function _GWizWordMapper_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizWordMapper_Button1_c(),this._GWizWordMapper_Spacer1_c(),this._GWizWordMapper_Button2_c(),this._GWizWordMapper_Button3_c(),this._GWizWordMapper_Label1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWordMapper_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Add";
         _loc1_.addEventListener("click",this.___GWizWordMapper_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizWordMapper_Button1_click(param1:MouseEvent) : void
      {
         this.doAdd();
      }
      
      private function _GWizWordMapper_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 40;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWordMapper_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Delete";
         _loc1_.addEventListener("click",this.___GWizWordMapper_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizWordMapper_Button2_click(param1:MouseEvent) : void
      {
         this.doDelete();
      }
      
      private function _GWizWordMapper_Button3_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Delete All";
         _loc1_.addEventListener("click",this.___GWizWordMapper_Button3_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizWordMapper_Button3_click(param1:MouseEvent) : void
      {
         this.doDeleteAll();
      }
      
      private function _GWizWordMapper_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hint:";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "hint";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.hint = _loc1_;
         BindingManager.executeBindings(this,"hint",this.hint);
         return _loc1_;
      }
      
      private function _GWizWordMapper_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.editable = true;
         _loc1_.columns = this._GWizWordMapper_ArrayList1_c();
         _loc1_.addEventListener("valueCommit",this.__list_valueCommit);
         _loc1_.addEventListener("click",this.__list_click);
         _loc1_.id = "list";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.list = _loc1_;
         BindingManager.executeBindings(this,"list",this.list);
         return _loc1_;
      }
      
      private function _GWizWordMapper_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizWordMapper_GridColumn1_c(),this._GWizWordMapper_GridColumn2_c(),this._GWizWordMapper_GridColumn3_c()];
         return _loc1_;
      }
      
      private function _GWizWordMapper_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Search";
         _loc1_.dataField = "search";
         _loc1_.width = 100;
         _loc1_.editable = true;
         return _loc1_;
      }
      
      private function _GWizWordMapper_GridColumn2_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Replace";
         _loc1_.dataField = "replace";
         _loc1_.width = 100;
         _loc1_.editable = true;
         return _loc1_;
      }
      
      private function _GWizWordMapper_GridColumn3_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Hint";
         _loc1_.dataField = "hint";
         _loc1_.editable = true;
         return _loc1_;
      }
      
      public function __list_valueCommit(param1:FlexEvent) : void
      {
         this.setHint();
      }
      
      public function __list_click(param1:MouseEvent) : void
      {
         this.setHint();
      }
      
      private function _GWizWordMapper_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Note: Mapping rules are applied top to bottom, first come, first served.";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWordMapper_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Click to edit in place. Use \'Add\' to get a new blank entry.";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWordMapper_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "All rules are case insensitive.";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizWordMapper_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizWordMapper_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return mapList;
         },null,"list.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get hint() : Label
      {
         return this._3202695hint;
      }
      
      public function set hint(param1:Label) : void
      {
         var _loc2_:Object = this._3202695hint;
         if(_loc2_ !== param1)
         {
            this._3202695hint = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hint",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get list() : DataGrid
      {
         return this._3322014list;
      }
      
      public function set list(param1:DataGrid) : void
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
