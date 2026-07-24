package cadcamwiz
{
   import comps.GWizDataGrid;
   import comps.GWizForePanel;
   import comps.GWizGridColumn;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import gwapi.GWizCalcAPIServer;
   import login.GWizLoginBar;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.events.ResizeEvent;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizCCWResultsGrid extends GWizForePanel implements IBindingClient
   {
      
      private static var MAX_ROWS:int = 5;
      
      private static var _795868523appIsEstimator:Boolean;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1532767274Results:GWizDataGrid;
      
      private var _1094211428WidthColumn:GWizGridColumn;
      
      public var _GWizCCWResultsGrid_GWizGridColumn11:GWizGridColumn;
      
      public var _GWizCCWResultsGrid_GWizGridColumn12:GWizGridColumn;
      
      private var _948495934colList:ArrayList;
      
      private var _1313953933timeCol:GWizGridColumn;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _results:ArrayCollection;
      
      private var _1927507083showEntry:Boolean = false;
      
      public var doubleClickFcn:Function;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWResultsGrid()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWResultsGrid_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWResultsGridWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWResultsGrid[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWResultsGrid_Array1_c);
         this.addEventListener("creationComplete",this.___GWizCCWResultsGrid_GWizForePanel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWResultsGrid._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get appIsEstimator() : Boolean
      {
         return GWizCCWResultsGrid._795868523appIsEstimator;
      }
      
      private static function set appIsEstimator(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWResultsGrid._795868523appIsEstimator;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWResultsGrid,"appIsEstimator",_loc2_,param1));
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
         appIsEstimator = GWizLoginBar.isGWEstimator();
         if(!appIsEstimator)
         {
            this.timeCol.visible = false;
            this.colList.removeItem(this.timeCol);
         }
      }
      
      private function set _1097546742results(param1:ArrayCollection) : void
      {
         if(this._results)
         {
            this._results.removeEventListener(CollectionEvent.COLLECTION_CHANGE,this.setAPIFcn);
         }
         this._results = param1;
         if(this._results)
         {
            this._results.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.setAPIFcn);
            this.setAPIFcn(null);
         }
      }
      
      public function get results() : ArrayCollection
      {
         return this._results;
      }
      
      private function setAPIFcn(param1:Event) : void
      {
         GWizCalcAPIServer.getCCField = this.getCADCAMField;
      }
      
      private function doDoubleClick() : void
      {
         if(this.doubleClickFcn != null)
         {
            this.doubleClickFcn();
         }
      }
      
      private function checkScroll(param1:Event) : void
      {
      }
      
      private function getCADCAMField(param1:String) : String
      {
         var _loc3_:GWizCCWEstRecord = null;
         var _loc4_:Number = NaN;
         var _loc2_:* = "";
         if(param1 && param1.toLowerCase() == "test")
         {
            return this.results && this.results.length > 0 ? "Go!" : "";
         }
         if(this.results && this.results.length > 0)
         {
            _loc3_ = this.results.getItemAt(0) as GWizCCWEstRecord;
            switch(param1)
            {
               case GWizCalcAPIServer.FIELD_TOOLDIA:
                  _loc2_ = String(GWizUtils.roundThousandths(_loc3_.toolDia,false));
                  break;
               case GWizCalcAPIServer.FIELD_CUTWIDTH:
                  _loc2_ = String(GWizUtils.roundThousandths(_loc3_.width,false));
                  break;
               case GWizCalcAPIServer.FIELD_CUTDEPTH:
                  _loc2_ = String(GWizUtils.roundThousandths(_loc3_.height,false));
                  break;
               case GWizCalcAPIServer.FIELD_RPM:
                  _loc2_ = String(GWizUtils.roundThousandths(_loc3_.rpm,false));
                  break;
               case GWizCalcAPIServer.FIELD_FEEDRATE:
                  _loc2_ = String(GWizUtils.roundThousandths(_loc3_.feedrate,false));
                  break;
               case GWizCalcAPIServer.FIELD_PLUNGE:
                  _loc4_ = _loc3_.feedrate / _loc3_.flutes;
                  _loc2_ = String(GWizUtils.roundThousandths(_loc4_,false));
                  break;
               default:
                  _loc2_ = param1 + " is unknown.";
            }
         }
         return _loc2_;
      }
      
      private function _GWizCCWResultsGrid_Array1_c() : Array
      {
         return [this._GWizCCWResultsGrid_VGroup1_c()];
      }
      
      private function _GWizCCWResultsGrid_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCCWResultsGrid_GWizDataGrid1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizDataGrid1_i() : GWizDataGrid
      {
         var _loc1_:GWizDataGrid = null;
         _loc1_ = new GWizDataGrid();
         _loc1_.configId = "results";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.styleName = "fontSizeDelta-2";
         _loc1_.requestedRowCount = 2;
         _loc1_.minHeight = 40;
         _loc1_.minWidth = 300;
         _loc1_.variableRowHeight = true;
         _loc1_.doubleClickEnabled = true;
         _loc1_.columns = this._GWizCCWResultsGrid_ArrayList1_i();
         _loc1_.setStyle("verticalScrollPolicy","on");
         _loc1_.setStyle("horizontalScrollPolicy","auto");
         _loc1_.addEventListener("creationComplete",this.__Results_creationComplete);
         _loc1_.addEventListener("resize",this.__Results_resize);
         _loc1_.addEventListener("doubleClick",this.__Results_doubleClick);
         _loc1_.id = "Results";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Results = _loc1_;
         BindingManager.executeBindings(this,"Results",this.Results);
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_ArrayList1_i() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizCCWResultsGrid_GWizGridColumn1_c(),this._GWizCCWResultsGrid_GWizGridColumn2_c(),this._GWizCCWResultsGrid_GWizGridColumn3_c(),this._GWizCCWResultsGrid_GWizGridColumn4_c(),this._GWizCCWResultsGrid_GWizGridColumn5_i(),this._GWizCCWResultsGrid_GWizGridColumn6_c(),this._GWizCCWResultsGrid_GWizGridColumn7_c(),this._GWizCCWResultsGrid_GWizGridColumn8_c(),this._GWizCCWResultsGrid_GWizGridColumn9_c(),this._GWizCCWResultsGrid_GWizGridColumn10_c(),this._GWizCCWResultsGrid_GWizGridColumn11_i(),this._GWizCCWResultsGrid_GWizGridColumn12_i(),this._GWizCCWResultsGrid_GWizGridColumn13_c(),this._GWizCCWResultsGrid_GWizGridColumn14_i(),this._GWizCCWResultsGrid_GWizGridColumn15_c(),this._GWizCCWResultsGrid_GWizGridColumn16_c()];
         this.colList = _loc1_;
         BindingManager.executeBindings(this,"colList",this.colList);
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn1_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colOp";
         _loc1_.headerText = "Op";
         _loc1_.dataField = "op";
         _loc1_.width = 180;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn2_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colTool";
         _loc1_.headerText = "Tool";
         _loc1_.dataField = "tool";
         _loc1_.width = 60;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn3_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colPasses";
         _loc1_.headerText = "Passes";
         _loc1_.dataField = "passes";
         _loc1_.width = 60;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn4_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colCutDepth";
         _loc1_.headerText = "Cut Depth";
         _loc1_.dataField = "height";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 60;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn5_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colCutWidth";
         _loc1_.headerText = "Cut Width";
         _loc1_.dataField = "width";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 60;
         this.WidthColumn = _loc1_;
         BindingManager.executeBindings(this,"WidthColumn",this.WidthColumn);
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn6_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colRPM";
         _loc1_.headerText = "RPM";
         _loc1_.dataField = "rpm";
         _loc1_.width = 70;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn7_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colSFM";
         _loc1_.headerText = "SFM";
         _loc1_.dataField = "sfm";
         _loc1_.width = 70;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn8_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colFeedRate";
         _loc1_.headerText = "Feedrate";
         _loc1_.dataField = "feedrate";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 60;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn9_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colIPR";
         _loc1_.headerText = "IPR";
         _loc1_.dataField = "ipr";
         _loc1_.width = 70;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn10_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colStickout";
         _loc1_.headerText = "Stickout";
         _loc1_.dataField = "stickout";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 60;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn11_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colEntryMode";
         _loc1_.headerText = "Entry";
         _loc1_.dataField = "entryMode";
         _loc1_.width = 60;
         this._GWizCCWResultsGrid_GWizGridColumn11 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWResultsGrid_GWizGridColumn11",this._GWizCCWResultsGrid_GWizGridColumn11);
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn12_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colEntryFeed";
         _loc1_.headerText = "Entry Feed";
         _loc1_.dataField = "entryFeedrate";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 60;
         this._GWizCCWResultsGrid_GWizGridColumn12 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWResultsGrid_GWizGridColumn12",this._GWizCCWResultsGrid_GWizGridColumn12);
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn13_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colMRR";
         _loc1_.headerText = "MRR";
         _loc1_.dataField = "mrr";
         _loc1_.labelFunction = GWizUtils.convUnitsCCLabelFcn;
         _loc1_.width = 60;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn14_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colTime";
         _loc1_.headerText = "Time";
         _loc1_.dataField = "time";
         _loc1_.width = 60;
         this.timeCol = _loc1_;
         BindingManager.executeBindings(this,"timeCol",this.timeCol);
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn15_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colHints";
         _loc1_.headerText = "Hints";
         _loc1_.dataField = "hints";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizCCWResultsGrid_GWizGridColumn16_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colOther";
         _loc1_.headerText = "Other";
         _loc1_.dataField = "toolOther";
         _loc1_.width = 60;
         return _loc1_;
      }
      
      public function __Results_creationComplete(param1:FlexEvent) : void
      {
         this.Results.scroller.verticalScrollBar.addEventListener(FlexEvent.SHOW,this.checkScroll);
      }
      
      public function __Results_resize(param1:ResizeEvent) : void
      {
         this.checkScroll(param1);
      }
      
      public function __Results_doubleClick(param1:MouseEvent) : void
      {
         this.doDoubleClick();
      }
      
      public function ___GWizCCWResultsGrid_GWizForePanel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCCWResultsGrid_bindingsSetup() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new Binding(this,null,null,"Results.dataProvider","results");
         _loc1_[1] = new Binding(this,null,null,"_GWizCCWResultsGrid_GWizGridColumn11.visible","showEntry");
         _loc1_[2] = new Binding(this,null,null,"_GWizCCWResultsGrid_GWizGridColumn12.visible","showEntry");
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get Results() : GWizDataGrid
      {
         return this._1532767274Results;
      }
      
      public function set Results(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = this._1532767274Results;
         if(_loc2_ !== param1)
         {
            this._1532767274Results = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Results",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get WidthColumn() : GWizGridColumn
      {
         return this._1094211428WidthColumn;
      }
      
      public function set WidthColumn(param1:GWizGridColumn) : void
      {
         var _loc2_:Object = this._1094211428WidthColumn;
         if(_loc2_ !== param1)
         {
            this._1094211428WidthColumn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"WidthColumn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get colList() : ArrayList
      {
         return this._948495934colList;
      }
      
      public function set colList(param1:ArrayList) : void
      {
         var _loc2_:Object = this._948495934colList;
         if(_loc2_ !== param1)
         {
            this._948495934colList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"colList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get timeCol() : GWizGridColumn
      {
         return this._1313953933timeCol;
      }
      
      public function set timeCol(param1:GWizGridColumn) : void
      {
         var _loc2_:Object = this._1313953933timeCol;
         if(_loc2_ !== param1)
         {
            this._1313953933timeCol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"timeCol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get showEntry() : Boolean
      {
         return this._1927507083showEntry;
      }
      
      public function set showEntry(param1:Boolean) : void
      {
         var _loc2_:Object = this._1927507083showEntry;
         if(_loc2_ !== param1)
         {
            this._1927507083showEntry = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"showEntry",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function set results(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this.results;
         if(_loc2_ !== param1)
         {
            this._1097546742results = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"results",_loc2_,param1));
            }
         }
      }
   }
}
