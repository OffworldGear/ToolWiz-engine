package threads2
{
   import comps.GWizDataGrid;
   import comps.GWizFileBrowser;
   import comps.GWizGridColumn;
   import flash.filesystem.File;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import utils.GWizCSVUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizThreadDataGrid extends GWizDataGrid implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1184942436Variable:GWizGridColumn;
      
      public var _GWizThreadDataGrid_GWizGridColumn2:GWizGridColumn;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1165691407isTaperedThread:Boolean = false;
      
      private var _1185456940threadData:ArrayCollection = null;
      
      private var _386794640dataField:String = "value";
      
      public var threadFiles:GWizFileBrowser;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizThreadDataGrid()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         var bindings:Array = this._GWizThreadDataGrid_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_threads2_GWizThreadDataGridWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizThreadDataGrid[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.configId = "ThreadDataGrid";
         this.editable = false;
         this.sortableColumns = true;
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.columns = this._GWizThreadDataGrid_ArrayList1_c();
         this.addEventListener("creationComplete",this.___GWizThreadDataGrid_GWizDataGrid1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizThreadDataGrid._watcherSetupUtil = param1;
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
            this.horizontalScrollPolicy = "auto";
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      public function refresh() : void
      {
         this.threadData = null;
         if(this.isTaperedThread)
         {
            if(GWizThreadReference2.taperThreadEngine)
            {
               this.threadData = GWizThreadReference2.taperThreadEngine.getThreadData();
            }
         }
         else if(GWizThreadReference2.straightThreadEngine)
         {
            this.threadData = GWizThreadReference2.straightThreadEngine.getThreadData();
         }
         if(this.threadData)
         {
            if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
            {
               this.dataField = "value";
            }
            else
            {
               this.dataField = "mmvalue";
            }
            this.dataProvider = this.threadData;
            this.threadData.refresh();
         }
         else
         {
            this.callLater(this.refresh);
         }
      }
      
      public function doSave() : void
      {
         this.threadFiles = new GWizFileBrowser("ThreadInfo","ThreadInfo","*.csv");
         this.threadFiles.doFileSaveAs(this.exportThread,"Save","ThreadInfo.csv");
      }
      
      public function exportThread(param1:File) : void
      {
         var _loc2_:Array = ["label",this.dataField];
         GWizCSVUtils.saveCSVFile(param1,this.threadData,_loc2_);
      }
      
      private function _GWizThreadDataGrid_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizThreadDataGrid_GWizGridColumn1_i(),this._GWizThreadDataGrid_GWizGridColumn2_i()];
         return _loc1_;
      }
      
      private function _GWizThreadDataGrid_GWizGridColumn1_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colVar";
         _loc1_.headerText = "Variable";
         _loc1_.dataField = "label";
         this.Variable = _loc1_;
         BindingManager.executeBindings(this,"Variable",this.Variable);
         return _loc1_;
      }
      
      private function _GWizThreadDataGrid_GWizGridColumn2_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colValue";
         _loc1_.headerText = "Value";
         _loc1_.labelFunction = GWizUtils.NaNToNALabelFcn;
         this._GWizThreadDataGrid_GWizGridColumn2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadDataGrid_GWizGridColumn2",this._GWizThreadDataGrid_GWizGridColumn2);
         return _loc1_;
      }
      
      public function ___GWizThreadDataGrid_GWizDataGrid1_creationComplete(param1:FlexEvent) : void
      {
         this.refresh();
      }
      
      private function _GWizThreadDataGrid_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():String
         {
            var _loc1_:* = this.dataField;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizThreadDataGrid_GWizGridColumn2.dataField");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Variable() : GWizGridColumn
      {
         return this._1184942436Variable;
      }
      
      public function set Variable(param1:GWizGridColumn) : void
      {
         var _loc2_:Object = this._1184942436Variable;
         if(_loc2_ !== param1)
         {
            this._1184942436Variable = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Variable",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get isTaperedThread() : Boolean
      {
         return this._1165691407isTaperedThread;
      }
      
      public function set isTaperedThread(param1:Boolean) : void
      {
         var _loc2_:Object = this._1165691407isTaperedThread;
         if(_loc2_ !== param1)
         {
            this._1165691407isTaperedThread = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"isTaperedThread",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get threadData() : ArrayCollection
      {
         return this._1185456940threadData;
      }
      
      public function set threadData(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._1185456940threadData;
         if(_loc2_ !== param1)
         {
            this._1185456940threadData = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"threadData",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get dataField() : String
      {
         return this._386794640dataField;
      }
      
      private function set dataField(param1:String) : void
      {
         var _loc2_:Object = this._386794640dataField;
         if(_loc2_ !== param1)
         {
            this._386794640dataField = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dataField",_loc2_,param1));
            }
         }
      }
   }
}
