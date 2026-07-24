package views
{
   import configinfo.GWizConfigData;
   import flash.utils.getDefinitionByName;
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
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizUnitChooser extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizUnitChooser");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _2075240901FromUnits:DropDownList;
      
      private var _500614548ToUnits:DropDownList;
      
      private var _228008194UnitType:DropDownList;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var doConversion:Function;
      
      public var c1Ref:Label;
      
      public var c2Ref:Label;
      
      public var m1Ref:Label;
      
      public var m2Ref:Label;
      
      private var _1155661668unitTypeList:Array;
      
      private var _1724002036unitFromList:Array;
      
      private var _2076307363unitToList:Array;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizUnitChooser()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1155661668unitTypeList = new Array();
         this._1724002036unitFromList = new Array();
         this._2076307363unitToList = new Array();
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizUnitChooser_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizUnitChooserWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizUnitChooser[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.verticalAlign = "middle";
         this.mxmlContent = [this._GWizUnitChooser_HGroup1_c(),this._GWizUnitChooser_HGroup2_c(),this._GWizUnitChooser_HGroup3_c()];
         this.addEventListener("creationComplete",this.___GWizUnitChooser_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizUnitChooser._watcherSetupUtil = param1;
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
      
      private function filterUnitsForFrom(param1:Object) : Boolean
      {
         return param1.type == this.UnitType.selectedItem && param1.from == this.FromUnits.selectedItem;
      }
      
      private function filterUnitsForTo(param1:Object) : Boolean
      {
         return param1.type == this.UnitType.selectedItem && param1.from == this.ToUnits.selectedItem;
      }
      
      private function returnUnits() : void
      {
         GWizConfigData.BaseUnitList.filterFunction = this.filterUnitsForFrom;
         GWizConfigData.BaseUnitList.refresh();
         if(GWizConfigData.BaseUnitList.length > 0)
         {
            this.m1Ref.text = GWizConfigData.BaseUnitList.getItemAt(0).factor;
            this.c1Ref.text = GWizConfigData.BaseUnitList.getItemAt(0).constant;
            GWizConfigData.BaseUnitList.filterFunction = this.filterUnitsForTo;
            GWizConfigData.BaseUnitList.refresh();
            if(GWizConfigData.BaseUnitList.length > 0)
            {
               this.m2Ref.text = GWizConfigData.BaseUnitList.getItemAt(0).factor;
               this.c2Ref.text = GWizConfigData.BaseUnitList.getItemAt(0).constant;
            }
            else
            {
               GWizUtils.assert(false);
            }
            this.doConversion(null);
            return;
         }
      }
      
      private function setFromToUnits() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 1;
         this.unitFromList = new Array();
         this.unitToList = new Array();
         GWizConfigData.BaseUnitList.source.forEach(this.makeUnitFromToList);
         _loc2_ = this.unitToList.length;
         this.ToUnits.selectedIndex = 0;
         _loc2_ = this.unitFromList.length;
         this.FromUnits.selectedIndex = 0;
         this.doConversion(null);
      }
      
      private function makeUnitTypes(param1:Object, param2:int, param3:Array) : void
      {
         if(this.unitTypeList.length != 0)
         {
            if(this.unitTypeList.indexOf(param1.type) == -1)
            {
               this.unitTypeList.push(param1.type);
            }
         }
         else
         {
            this.unitTypeList.push(param1.type);
         }
      }
      
      private function makeUnitFromToList(param1:Object, param2:int, param3:Array) : void
      {
         if(param1.type == this.UnitType.selectedItem)
         {
            if(this.unitFromList.length > 0)
            {
               if(this.unitFromList.indexOf(param1.from) == -1)
               {
                  this.unitFromList.push(param1.from);
                  this.unitToList.push(param1.from);
               }
            }
            else
            {
               this.unitFromList.push(param1.from);
               this.unitToList.push(param1.from);
            }
         }
      }
      
      private function initCalc() : void
      {
         GWizConfigData.BaseUnitList.source.forEach(this.makeUnitTypes);
         this.UnitType.selectedIndex = 1;
         this.setFromToUnits();
         this.FromUnits.selectedIndex = 9;
         this.ToUnits.selectedIndex = 7;
         this.returnUnits();
      }
      
      public function swapUnits() : void
      {
         var _loc1_:int = this.FromUnits.selectedIndex;
         this.FromUnits.selectedIndex = this.ToUnits.selectedIndex;
         this.ToUnits.selectedIndex = _loc1_;
      }
      
      private function _GWizUnitChooser_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizUnitChooser_Label1_c(),this._GWizUnitChooser_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizUnitChooser_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Type";
         _loc1_.width = 50;
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizUnitChooser_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "type";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.setStyle("color",734012);
         _loc1_.addEventListener("change",this.__UnitType_change);
         _loc1_.id = "UnitType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.UnitType = _loc1_;
         BindingManager.executeBindings(this,"UnitType",this.UnitType);
         return _loc1_;
      }
      
      public function __UnitType_change(param1:IndexChangeEvent) : void
      {
         this.setFromToUnits();
      }
      
      private function _GWizUnitChooser_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizUnitChooser_Label2_c(),this._GWizUnitChooser_DropDownList2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizUnitChooser_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "From";
         _loc1_.width = 50;
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizUnitChooser_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "from";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.setStyle("color",734012);
         _loc1_.addEventListener("valueCommit",this.__FromUnits_valueCommit);
         _loc1_.id = "FromUnits";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FromUnits = _loc1_;
         BindingManager.executeBindings(this,"FromUnits",this.FromUnits);
         return _loc1_;
      }
      
      public function __FromUnits_valueCommit(param1:FlexEvent) : void
      {
         this.returnUnits();
      }
      
      private function _GWizUnitChooser_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizUnitChooser_Label3_c(),this._GWizUnitChooser_DropDownList3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizUnitChooser_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "To";
         _loc1_.width = 50;
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizUnitChooser_DropDownList3_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "from";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.setStyle("color",734012);
         _loc1_.addEventListener("valueCommit",this.__ToUnits_valueCommit);
         _loc1_.id = "ToUnits";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToUnits = _loc1_;
         BindingManager.executeBindings(this,"ToUnits",this.ToUnits);
         return _loc1_;
      }
      
      public function __ToUnits_valueCommit(param1:FlexEvent) : void
      {
         this.returnUnits();
      }
      
      public function ___GWizUnitChooser_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.initCalc();
      }
      
      private function _GWizUnitChooser_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return new ArrayCollection(unitTypeList);
         },null,"UnitType.dataProvider");
         result[1] = new Binding(this,function():IList
         {
            return new ArrayCollection(unitFromList);
         },null,"FromUnits.dataProvider");
         result[2] = new Binding(this,function():IList
         {
            return new ArrayCollection(unitToList);
         },null,"ToUnits.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get FromUnits() : DropDownList
      {
         return this._2075240901FromUnits;
      }
      
      public function set FromUnits(param1:DropDownList) : void
      {
         var _loc2_:Object = this._2075240901FromUnits;
         if(_loc2_ !== param1)
         {
            this._2075240901FromUnits = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FromUnits",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToUnits() : DropDownList
      {
         return this._500614548ToUnits;
      }
      
      public function set ToUnits(param1:DropDownList) : void
      {
         var _loc2_:Object = this._500614548ToUnits;
         if(_loc2_ !== param1)
         {
            this._500614548ToUnits = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToUnits",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get UnitType() : DropDownList
      {
         return this._228008194UnitType;
      }
      
      public function set UnitType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._228008194UnitType;
         if(_loc2_ !== param1)
         {
            this._228008194UnitType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"UnitType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get unitTypeList() : Array
      {
         return this._1155661668unitTypeList;
      }
      
      private function set unitTypeList(param1:Array) : void
      {
         var _loc2_:Object = this._1155661668unitTypeList;
         if(_loc2_ !== param1)
         {
            this._1155661668unitTypeList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"unitTypeList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get unitFromList() : Array
      {
         return this._1724002036unitFromList;
      }
      
      private function set unitFromList(param1:Array) : void
      {
         var _loc2_:Object = this._1724002036unitFromList;
         if(_loc2_ !== param1)
         {
            this._1724002036unitFromList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"unitFromList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get unitToList() : Array
      {
         return this._2076307363unitToList;
      }
      
      private function set unitToList(param1:Array) : void
      {
         var _loc2_:Object = this._2076307363unitToList;
         if(_loc2_ !== param1)
         {
            this._2076307363unitToList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"unitToList",_loc2_,param1));
            }
         }
      }
   }
}
