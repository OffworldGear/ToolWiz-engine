package comps
{
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
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
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizTaperPicker extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _880966941tapers:GWizDataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var LargeEnd:Number;
      
      public var SmallEnd:Number;
      
      public var Length:Number;
      
      public var Angle:Number;
      
      public var TaperName:String;
      
      private var metricStandardTaperList:ArrayCollection;
      
      public var commitFunction:Function = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizTaperPicker()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizTaperPicker_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizTaperPickerWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizTaperPicker[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Select Taper";
         this.fullScreen = true;
         this.mxmlContent = [this._GWizTaperPicker_GWizDataGrid1_i()];
         this.addEventListener("initialize",this.___GWizTaperPicker_GWizPopUp1_initialize);
         this.addEventListener("creationComplete",this.___GWizTaperPicker_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function selectTaper(param1:Function) : GWizTaperPicker
      {
         var _loc2_:GWizTaperPicker = GWizPopUpManager.createPopUp(DisplayObject(GWizSettings.docWindow),GWizTaperPicker,true) as GWizTaperPicker;
         if(_loc2_)
         {
            _loc2_.commitFunction = param1;
         }
         return _loc2_;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizTaperPicker._watcherSetupUtil = param1;
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
      
      private function init() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         if(!this.metricStandardTaperList)
         {
            this.metricStandardTaperList = new ArrayCollection();
            _loc1_ = 0;
            while(_loc1_ < GWizConfigData.StandardTaperList.length)
            {
               _loc2_ = GWizConfigData.StandardTaperList.getItemAt(_loc1_);
               _loc3_ = new Object();
               _loc3_.name = _loc2_.name;
               _loc3_.angle = _loc2_.angle;
               _loc3_.largeEnd = GWizUtils.roundThousandths(_loc2_.largeEnd * 25.4);
               _loc3_.smallEnd = GWizUtils.roundThousandths(_loc2_.smallEnd * 25.4);
               _loc3_.length = GWizUtils.roundThousandths(_loc2_.length * 25.4);
               this.metricStandardTaperList.addItemAt(_loc3_,_loc1_);
               _loc1_++;
            }
         }
      }
      
      private function checkUnits() : void
      {
         this.init();
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS && this.tapers.dataProvider != GWizConfigData.StandardTaperList)
         {
            this.tapers.dataProvider = GWizConfigData.StandardTaperList;
         }
         else if(GWizUtils.Units == GWizUtils.MM_UNITS && this.tapers.dataProvider != this.metricStandardTaperList)
         {
            this.tapers.dataProvider = this.metricStandardTaperList;
         }
         GWizConfigData.StandardTaperList.refresh();
      }
      
      private function selectTaper(param1:Boolean = false) : void
      {
         var _loc2_:Number = NaN;
         if(this.tapers.selectedItem != null)
         {
            _loc2_ = 1;
            if(GWizUtils.Units == GWizUtils.MM_UNITS)
            {
               _loc2_ = 25.4;
            }
            this.LargeEnd = this.tapers.selectedItem.largeEnd / _loc2_;
            this.SmallEnd = this.tapers.selectedItem.smallEnd / _loc2_;
            this.Length = this.tapers.selectedItem.length / _loc2_;
            this.Angle = this.tapers.selectedItem.angle;
            this.TaperName = this.tapers.selectedItem.name;
         }
      }
      
      override public function onOk(param1:Event) : void
      {
         if(this.commitFunction != null)
         {
            this.commitFunction();
         }
         super.close();
      }
      
      private function _GWizTaperPicker_GWizDataGrid1_i() : GWizDataGrid
      {
         var _loc1_:GWizDataGrid = new GWizDataGrid();
         _loc1_.configId = "tapers";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.doubleClickEnabled = true;
         _loc1_.variableRowHeight = true;
         _loc1_.columns = this._GWizTaperPicker_ArrayCollection1_c();
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__tapers_valueCommit);
         _loc1_.addEventListener("doubleClick",this.__tapers_doubleClick);
         _loc1_.id = "tapers";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tapers = _loc1_;
         BindingManager.executeBindings(this,"tapers",this.tapers);
         return _loc1_;
      }
      
      private function _GWizTaperPicker_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = [this._GWizTaperPicker_GWizGridColumn1_c(),this._GWizTaperPicker_GWizGridColumn2_c(),this._GWizTaperPicker_GWizGridColumn3_c(),this._GWizTaperPicker_GWizGridColumn4_c(),this._GWizTaperPicker_GWizGridColumn5_c()];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizTaperPicker_GWizGridColumn1_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colTaper";
         _loc1_.headerText = "Taper";
         _loc1_.dataField = "name";
         _loc1_.width = 120;
         return _loc1_;
      }
      
      private function _GWizTaperPicker_GWizGridColumn2_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colLargeEnd";
         _loc1_.headerText = "Large End";
         _loc1_.dataField = "largeEnd";
         _loc1_.width = 90;
         return _loc1_;
      }
      
      private function _GWizTaperPicker_GWizGridColumn3_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colSmallEnd";
         _loc1_.headerText = "Small End";
         _loc1_.dataField = "smallEnd";
         _loc1_.width = 90;
         return _loc1_;
      }
      
      private function _GWizTaperPicker_GWizGridColumn4_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colLength";
         _loc1_.headerText = "Length";
         _loc1_.dataField = "length";
         return _loc1_;
      }
      
      private function _GWizTaperPicker_GWizGridColumn5_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colAngle";
         _loc1_.headerText = "Angle";
         _loc1_.dataField = "angle";
         return _loc1_;
      }
      
      public function __tapers_valueCommit(param1:FlexEvent) : void
      {
         this.selectTaper();
      }
      
      public function __tapers_doubleClick(param1:MouseEvent) : void
      {
         this.onOk(null);
      }
      
      public function ___GWizTaperPicker_GWizPopUp1_initialize(param1:FlexEvent) : void
      {
         this.init();
      }
      
      public function ___GWizTaperPicker_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.checkUnits();
      }
      
      private function _GWizTaperPicker_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizConfigData.StandardTaperList;
         },null,"tapers.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get tapers() : GWizDataGrid
      {
         return this._880966941tapers;
      }
      
      public function set tapers(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = this._880966941tapers;
         if(_loc2_ !== param1)
         {
            this._880966941tapers = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tapers",_loc2_,param1));
            }
         }
      }
   }
}
