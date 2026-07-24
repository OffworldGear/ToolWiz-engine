package mx.charts.chartClasses
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import mx.charts.ChartItem;
   import mx.charts.HitData;
   import mx.charts.events.ChartEvent;
   import mx.charts.events.ChartItemEvent;
   import mx.charts.styles.HaloDefaults;
   import mx.collections.ArrayCollection;
   import mx.collections.ICollectionView;
   import mx.collections.IList;
   import mx.collections.ListCollectionView;
   import mx.collections.XMLListCollection;
   import mx.core.DragSource;
   import mx.core.EventPriority;
   import mx.core.FlexGlobals;
   import mx.core.FlexShape;
   import mx.core.IDataRenderer;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IUIComponent;
   import mx.core.LayoutDirection;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.effects.Parallel;
   import mx.effects.effectClasses.ParallelInstance;
   import mx.events.DragEvent;
   import mx.events.EffectEvent;
   import mx.graphics.IFill;
   import mx.graphics.IStroke;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import mx.managers.DragManager;
   import mx.managers.IFocusManagerComponent;
   import mx.managers.ILayoutManagerClient;
   import mx.styles.CSSStyleDeclaration;
   
   use namespace mx_internal;
   
   public class ChartBase extends UIComponent implements IFocusManagerComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const TOOLTIP_TARGET_INNER_RADIUS:Number = 1.5;
      
      private static const TOOLTIP_TARGET_RADIUS:Number = 4.5;
      
      public static const HORIZONTAL:String = "horizontal";
      
      public static const VERTICAL:String = "vertical";
      
      mx_internal static const DRAG_THRESHOLD:int = 4;
      
      private static var ITEM_EVENTS:Object = {
         "chartClick":true,
         "chartDoubleClick":true,
         "itemClick":true,
         "itemDoubleClick":true,
         "itemMouseDown":true,
         "itemMouseUp":true,
         "itemMouseMove":true,
         "itemRollOver":true,
         "itemRollOut":true
      };
       
      
      private var _moduleFactoryInitialized:Boolean = false;
      
      private var _allTipCache:InstanceCache;
      
      private var _tipCache:InstanceCache;
      
      private var _dataTipOverlay:Shape;
      
      private var _allDataTipOverlay:Shape;
      
      private var _commitPropertiesCalled:Boolean = false;
      
      private var _seriesMask:Shape;
      
      private var _backgroundElementMask:Shape;
      
      private var _annotationElementMask:Shape;
      
      private var _bSeriesDirty:Boolean = false;
      
      private var _bDataDirty:Boolean = false;
      
      private var _childOrderDirty:Boolean = false;
      
      private var _userSeries:Array;
      
      private var _backgroundElements:Array;
      
      private var _annotationElements:Array;
      
      private var _description:String = "";
      
      private var _dataProvider:ICollectionView;
      
      protected var _seriesHolder:UIComponent;
      
      protected var _seriesFilterer:UIComponent;
      
      protected var _backgroundElementHolder:UIComponent;
      
      protected var _annotationElementHolder:UIComponent;
      
      protected var allElements:Array;
      
      protected var labelElements:Array;
      
      private var _clipContent:Boolean = true;
      
      protected var _transforms:Array;
      
      private var _showAllDataTips:Boolean = false;
      
      private var _showDataTips:Boolean = false;
      
      private var _dataTipMode:String = "multiple";
      
      private var _currentHitSet:Array;
      
      private var _mouseEventsInitialzed:Boolean = false;
      
      private var _rangeEventsInitialzed:Boolean = false;
      
      private var _transitionState:uint = 0;
      
      private var _transitionEffect:ParallelInstance;
      
      private var _seriesStylesDirty:Boolean = true;
      
      protected var _selectedSeries:Series = null;
      
      private var _selectionMode:String = "none";
      
      private var _mouseDown:Boolean = false;
      
      private var _mouseDownPoint:Point = null;
      
      private var _mouseDownItem:ChartItem = null;
      
      protected var _caretItem:ChartItem = null;
      
      protected var _anchorItem:ChartItem = null;
      
      private var dLeft:Number = 0;
      
      private var dTop:Number = 0;
      
      private var dRight:Number = 0;
      
      private var dBottom:Number = 0;
      
      private var tX:Number;
      
      private var tY:Number;
      
      private var rangeItemRenderer:RangeSelector = null;
      
      private var dataRegionForRange:Rectangle = null;
      
      public var dataTipItemsSet:Boolean = false;
      
      public var dataTipFunction:Function;
      
      private var _dragEnabled:Boolean = false;
      
      private var _dragMoveEnabled:Boolean = false;
      
      private var _dropEnabled:Boolean = false;
      
      public var mouseSensitivity:Number = 5;
      
      public function ChartBase()
      {
         var _loc1_:Graphics = null;
         this._userSeries = [];
         this._backgroundElements = [];
         this._annotationElements = [];
         this.allElements = [];
         this.labelElements = [];
         super();
         this.addEventListener(DragEvent.DRAG_START,this.dragStartHandler);
         tabEnabled = false;
         this._seriesHolder = new UIComponent();
         this._seriesFilterer = new UIComponent();
         this._seriesHolder.addChild(this._seriesFilterer);
         addChild(this._seriesHolder);
         this._backgroundElementHolder = new UIComponent();
         addChild(this._backgroundElementHolder);
         this._annotationElementHolder = new UIComponent();
         addChild(this._annotationElementHolder);
         this._dataTipOverlay = new FlexShape();
         this._dataTipOverlay.name = "dataTipOverlay";
         addChild(this._dataTipOverlay);
         this._allDataTipOverlay = new FlexShape();
         this._allDataTipOverlay.name = "allDataTipOverlay";
         addChild(this._allDataTipOverlay);
         this._seriesMask = new FlexShape();
         this._seriesMask.name = "seriesMask";
         _loc1_ = this._seriesMask.graphics;
         _loc1_.clear();
         _loc1_.beginFill(0,100);
         _loc1_.drawRect(0,0,10,10);
         _loc1_.endFill();
         this._seriesMask.visible = false;
         this._backgroundElementMask = new FlexShape();
         this._backgroundElementMask.name = "backgroundElementMask";
         _loc1_ = this._backgroundElementMask.graphics;
         _loc1_.clear();
         _loc1_.beginFill(0,100);
         _loc1_.drawRect(0,0,10,10);
         _loc1_.endFill();
         this._backgroundElementMask.visible = false;
         this._annotationElementMask = new FlexShape();
         this._annotationElementMask.name = "annotationElementMask";
         _loc1_ = this._annotationElementMask.graphics;
         _loc1_.clear();
         _loc1_.beginFill(0,100);
         _loc1_.drawRect(0,0,10,10);
         _loc1_.endFill();
         this._annotationElementMask.visible = false;
         this._seriesHolder.addChild(this._seriesMask);
         this._seriesHolder.mask = this._seriesMask;
         this._backgroundElementHolder.addChild(this._backgroundElementMask);
         this._backgroundElementHolder.mask = this._backgroundElementMask;
         this._annotationElementHolder.addChild(this._annotationElementMask);
         this._annotationElementHolder.mask = this._annotationElementMask;
         this._currentHitSet = [];
         this.invalidateChildOrder();
      }
      
      override public function set showInAutomationHierarchy(param1:Boolean) : void
      {
      }
      
      public function get annotationElements() : Array
      {
         return this._annotationElements;
      }
      
      public function set annotationElements(param1:Array) : void
      {
         this._annotationElements = param1;
         this.invalidateSeries();
      }
      
      public function get backgroundElements() : Array
      {
         return this._backgroundElements;
      }
      
      public function set backgroundElements(param1:Array) : void
      {
         this._backgroundElements = param1;
         this.invalidateSeries();
      }
      
      public function get chartState() : uint
      {
         return this._transitionState;
      }
      
      protected function setChartState(param1:uint) : void
      {
         var _loc5_:IChartElement = null;
         if(this._transitionState == param1)
         {
            return;
         }
         var _loc2_:uint = this._transitionState;
         this._transitionState = param1;
         var _loc3_:int = this.allElements.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc5_ = this.allElements[_loc4_] as IChartElement)
            {
               _loc5_.chartStateChanged(_loc2_,param1);
            }
            _loc4_++;
         }
         invalidateDisplayList();
      }
      
      public function get clipContent() : Boolean
      {
         return this._clipContent;
      }
      
      public function set clipContent(param1:Boolean) : void
      {
         if(this._clipContent == param1)
         {
            return;
         }
         this._clipContent = param1;
         this._seriesHolder.mask = !!this._clipContent ? this._seriesMask : null;
         this._backgroundElementHolder.mask = !!this._clipContent ? this._backgroundElementMask : null;
         this._annotationElementHolder.mask = !!this._clipContent ? this._annotationElementMask : null;
      }
      
      public function get dataProvider() : Object
      {
         return this._dataProvider;
      }
      
      public function set dataProvider(param1:Object) : void
      {
         if(param1 is Array)
         {
            param1 = new ArrayCollection(param1 as Array);
         }
         else if(!(param1 is ICollectionView))
         {
            if(param1 is IList)
            {
               param1 = new ListCollectionView(param1 as IList);
            }
            else if(param1 is XMLList)
            {
               param1 = new XMLListCollection(XMLList(param1));
            }
            else if(param1 != null)
            {
               param1 = new ArrayCollection([param1]);
            }
            else
            {
               param1 = new ArrayCollection();
            }
         }
         this._dataProvider = ICollectionView(param1);
         this.invalidateData();
      }
      
      protected function get dataRegion() : Rectangle
      {
         return null;
      }
      
      protected function get dataTipLayerIndex() : int
      {
         return getChildIndex(this._dataTipOverlay);
      }
      
      public function get dataTipMode() : String
      {
         return this._dataTipMode;
      }
      
      public function set dataTipMode(param1:String) : void
      {
         this._dataTipMode = param1;
         this.updateDataTips();
      }
      
      public function get description() : String
      {
         return this._description;
      }
      
      public function set description(param1:String) : void
      {
         this.setDescription(param1);
         tabEnabled = true;
      }
      
      mx_internal function setDescription(param1:String) : void
      {
         this._description = param1;
      }
      
      public function get dragEnabled() : Boolean
      {
         return this._dragEnabled;
      }
      
      public function set dragEnabled(param1:Boolean) : void
      {
         if(this._dragEnabled && !param1)
         {
            removeEventListener(DragEvent.DRAG_COMPLETE,this.dragCompleteHandler,false);
         }
         this._dragEnabled = param1;
         if(param1)
         {
            this.addEventListener(DragEvent.DRAG_COMPLETE,this.dragCompleteHandler,false,EventPriority.DEFAULT_HANDLER);
         }
      }
      
      protected function get dragImage() : IUIComponent
      {
         var _loc1_:ChartItemDragProxy = new ChartItemDragProxy();
         _loc1_.owner = this;
         return _loc1_;
      }
      
      public function get dragMoveEnabled() : Boolean
      {
         return this._dragMoveEnabled;
      }
      
      public function set dragMoveEnabled(param1:Boolean) : void
      {
         this._dragMoveEnabled = param1;
      }
      
      public function get dropEnabled() : Boolean
      {
         return this._dropEnabled;
      }
      
      public function set dropEnabled(param1:Boolean) : void
      {
         if(this._dropEnabled && !param1)
         {
            removeEventListener(DragEvent.DRAG_ENTER,this.dragEnterHandler,false);
            removeEventListener(DragEvent.DRAG_EXIT,this.dragExitHandler,false);
            removeEventListener(DragEvent.DRAG_OVER,this.dragOverHandler,false);
            removeEventListener(DragEvent.DRAG_DROP,this.dragDropHandler,false);
         }
         this._dropEnabled = param1;
         if(param1)
         {
            this.addEventListener(DragEvent.DRAG_ENTER,this.dragEnterHandler,false,EventPriority.DEFAULT_HANDLER);
            this.addEventListener(DragEvent.DRAG_EXIT,this.dragExitHandler,false,EventPriority.DEFAULT_HANDLER);
            this.addEventListener(DragEvent.DRAG_OVER,this.dragOverHandler,false,EventPriority.DEFAULT_HANDLER);
            this.addEventListener(DragEvent.DRAG_DROP,this.dragDropHandler,false,EventPriority.DEFAULT_HANDLER);
         }
      }
      
      [Bindable("legendDataChanged")]
      public function get legendData() : Array
      {
         var _loc4_:Series = null;
         var _loc1_:Array = [];
         var _loc2_:int = this.allElements.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_loc4_ = this.allElements[_loc3_] as Series)
            {
               _loc1_ = _loc1_.concat(_loc4_.legendData);
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function get selectedChartItem() : ChartItem
      {
         if(this._selectedSeries)
         {
            return this._selectedSeries.selectedItem;
         }
         return null;
      }
      
      public function get selectedChartItems() : Array
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:Array = [];
         var _loc2_:int = this.series.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this.series[_loc3_].selectedItems.length;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc1_.push(this.series[_loc3_].selectedItems[_loc5_]);
               _loc5_++;
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function get selectionMode() : String
      {
         return this._selectionMode;
      }
      
      public function set selectionMode(param1:String) : void
      {
         if(this._selectionMode == param1)
         {
            return;
         }
         this._selectionMode = param1;
         invalidateProperties();
      }
      
      public function get series() : Array
      {
         return this._userSeries;
      }
      
      public function set series(param1:Array) : void
      {
         param1 = param1 == null ? [] : param1;
         this._userSeries = param1;
         var _loc2_:int = param1.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(param1[_loc3_] is Series)
            {
               (param1[_loc3_] as Series).owner = this;
            }
            _loc3_++;
         }
         this.invalidateSeries();
         this.invalidateData();
         this.legendDataChanged();
      }
      
      public function get seriesFilters() : Array
      {
         return this._seriesFilterer.filters;
      }
      
      public function set seriesFilters(param1:Array) : void
      {
         this._seriesFilterer.filters = param1;
      }
      
      public function get showAllDataTips() : Boolean
      {
         return this._showAllDataTips;
      }
      
      public function set showAllDataTips(param1:Boolean) : void
      {
         if(this._showAllDataTips == param1)
         {
            return;
         }
         this._showAllDataTips = param1;
         this.updateAllDataTips();
      }
      
      public function get showDataTips() : Boolean
      {
         return this._showDataTips;
      }
      
      public function set showDataTips(param1:Boolean) : void
      {
         if(this._showDataTips == param1)
         {
            return;
         }
         this._showDataTips = param1;
         if(this._showDataTips)
         {
            if(this._mouseEventsInitialzed == false)
            {
               this.setupMouseDispatching();
            }
         }
         this.updateDataTips();
      }
      
      mx_internal function get allElementsArray() : Array
      {
         return this.allElements;
      }
      
      mx_internal function get labelElementsArray() : Array
      {
         return this.labelElements;
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         if(this._mouseEventsInitialzed == false && ITEM_EVENTS[param1] == true)
         {
            this.setupMouseDispatching();
         }
         super.addEventListener(param1,param2,param3,param4,param5);
      }
      
      private function initStyles() : Boolean
      {
         HaloDefaults.init(styleManager);
         var _loc1_:CSSStyleDeclaration = styleManager.getStyleDeclaration("mx.charts.chartClasses.ChartBase");
         _loc1_.setStyle("chartSeriesStyles",HaloDefaults.chartBaseChartSeriesStyles);
         _loc1_.setStyle("fill",new SolidColor(16777215,0));
         _loc1_.setStyle("calloutStroke",new SolidColorStroke(8947848,2));
         return true;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this._moduleFactoryInitialized)
         {
            return;
         }
         this._moduleFactoryInitialized = true;
         this.initStyles();
      }
      
      override public function invalidateSize() : void
      {
         this.cancelEffect();
         super.invalidateSize();
      }
      
      override protected function commitProperties() : void
      {
         this._commitPropertiesCalled = true;
         super.commitProperties();
         if(this._bSeriesDirty)
         {
            this.updateSeries();
            this._selectedSeries = null;
            this._bSeriesDirty = false;
         }
         this.updateSeriesStyles();
         if(this._bDataDirty)
         {
            this.updateData();
            this._bDataDirty = false;
         }
         if(this._childOrderDirty)
         {
            this.updateChildOrder();
            this._childOrderDirty = false;
         }
         if(this._selectionMode != "none")
         {
            if(this._mouseEventsInitialzed == false)
            {
               this.setupMouseDispatching();
            }
            if(this._rangeEventsInitialzed == false)
            {
               this.setupRangeDispatching();
            }
            tabEnabled = true;
         }
         else
         {
            tabEnabled = false;
            this.dragEnabled = false;
         }
      }
      
      override protected function measure() : void
      {
         super.measure();
         measuredWidth = 400;
         measuredHeight = 400;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         if(this._commitPropertiesCalled == false)
         {
            this.commitProperties();
         }
         graphics.clear();
         graphics.lineStyle(0,0,0);
         var _loc3_:IFill = GraphicsUtilities.fillFromStyle(getStyle("fill"));
         GraphicsUtilities.fillRect(graphics,0,0,param1,param2,_loc3_);
      }
      
      override public function setActualSize(param1:Number, param2:Number) : void
      {
         if(param1 != this.width || param2 != this.height)
         {
            this.cancelEffect();
         }
         super.setActualSize(param1,param2);
      }
      
      override public function styleChanged(param1:String) : void
      {
         if(param1 == null || param1 == "chartSeriesStyles")
         {
            this.invalidateSeries();
         }
         super.styleChanged(param1);
      }
      
      public function findDataPoints(param1:Number, param2:Number) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:IChartElement = null;
         var _loc7_:Array = null;
         var _loc3_:Array = [];
         if(this.dataRegion.contains(param1,param2) == false)
         {
            return _loc3_;
         }
         _loc5_ = (_loc4_ = this.allElements.length) - 1;
         while(_loc5_ >= 0)
         {
            if(!(!(_loc6_ = this.allElements[_loc5_] as IChartElement) || _loc6_.visible == false))
            {
               if((_loc7_ = _loc6_.findDataPoints(param1 - this._seriesHolder.x,param2 - this._seriesHolder.y,this.mouseSensitivity)).length != 0)
               {
                  _loc3_ = _loc3_.concat(_loc7_);
               }
            }
            _loc5_--;
         }
         _loc4_ = _loc3_.length;
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_[_loc5_].x += this._seriesHolder.x;
            _loc3_[_loc5_].y += this._seriesHolder.y;
            _loc5_++;
         }
         return _loc3_;
      }
      
      public function getAllDataPoints() : Array
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:IChartElement2 = null;
         var _loc5_:Array = null;
         var _loc1_:Array = [];
         _loc2_ = this.allElements.length;
         _loc3_ = _loc2_ - 1;
         while(_loc3_ >= 0)
         {
            if(!(!(_loc4_ = this.allElements[_loc3_] as IChartElement2) || _loc4_.visible == false))
            {
               if((_loc5_ = _loc4_.getAllDataPoints()).length != 0)
               {
                  _loc1_ = _loc1_.concat(_loc5_);
               }
            }
            _loc3_--;
         }
         _loc2_ = _loc1_.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_[_loc3_].x += this._seriesHolder.x;
            _loc1_[_loc3_].y += this._seriesHolder.y;
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function getItemsInRegion(param1:Rectangle) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:Array = [];
         if(this._transforms)
         {
            _loc3_ = this._transforms.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc2_ = _loc2_.concat(this.findItemsInRegionFromElements(this._transforms[_loc4_],param1));
               _loc4_++;
            }
         }
         return _loc2_;
      }
      
      public function getNextItem(param1:String) : ChartItem
      {
         return null;
      }
      
      public function getPreviousItem(param1:String) : ChartItem
      {
         return null;
      }
      
      public function getFirstItem(param1:String) : ChartItem
      {
         return null;
      }
      
      public function getLastItem(param1:String) : ChartItem
      {
         return null;
      }
      
      public function legendDataChanged() : void
      {
         dispatchEvent(new Event("legendDataChanged"));
      }
      
      public function hideData() : void
      {
         if(this._transitionEffect)
         {
            this.setChartState(ChartState.NONE);
            this._transitionEffect.end();
            this._transitionEffect = null;
         }
         this.setChartState(ChartState.PREPARING_TO_HIDE_DATA);
      }
      
      public function invalidateSeriesStyles() : void
      {
         if(!this._seriesStylesDirty)
         {
            this._seriesStylesDirty = true;
            invalidateProperties();
         }
      }
      
      protected function invalidateSeries() : void
      {
         if(this._bSeriesDirty == false)
         {
            this._bSeriesDirty = true;
            invalidateProperties();
            invalidateDisplayList();
         }
      }
      
      protected function invalidateChildOrder() : void
      {
         if(this._childOrderDirty == false)
         {
            this._childOrderDirty = true;
            invalidateProperties();
         }
      }
      
      private function cancelEffect() : void
      {
         if(this._transitionEffect)
         {
            this._transitionEffect.end();
            this._transitionEffect = null;
         }
         this.setChartState(ChartState.NONE);
      }
      
      protected function advanceEffectState() : void
      {
         var _loc1_:Parallel = null;
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._transitionState == ChartState.PREPARING_TO_HIDE_DATA)
         {
            _loc2_ = this.collectTransitions();
            if(_loc2_.length == 0)
            {
               this.setChartState(ChartState.PREPARING_TO_SHOW_DATA);
            }
            else
            {
               this.setChartState(ChartState.HIDING_DATA);
               _loc1_ = new Parallel();
               this._transitionEffect = ParallelInstance(_loc1_.createInstance());
               _loc4_ = _loc2_.length;
               _loc3_ = 0;
               while(_loc3_ < _loc4_)
               {
                  this._transitionEffect.addChildSet([_loc2_[_loc3_]]);
                  _loc3_++;
               }
               this._transitionEffect.addEventListener(EffectEvent.EFFECT_END,this.dataEffectEndHandler);
               this._transitionEffect.play();
            }
         }
         if(this._transitionState == ChartState.PREPARING_TO_SHOW_DATA)
         {
            _loc2_ = this.collectTransitions();
            if(_loc2_.length == 0)
            {
               this.setChartState(ChartState.NONE);
            }
            else
            {
               this.setChartState(ChartState.SHOWING_DATA);
               _loc1_ = new Parallel();
               this._transitionEffect = ParallelInstance(_loc1_.createInstance());
               _loc4_ = _loc2_.length;
               _loc3_ = 0;
               while(_loc3_ < _loc4_)
               {
                  this._transitionEffect.addChildSet([_loc2_[_loc3_]]);
                  _loc3_++;
               }
               this._transitionEffect.addEventListener(EffectEvent.EFFECT_END,this.dataEffectEndHandler);
               this._transitionEffect.play();
            }
         }
         invalidateDisplayList();
      }
      
      private function setupMouseDispatching() : void
      {
         this._mouseEventsInitialzed = true;
         super.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         super.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
         super.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         super.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         super.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         super.addEventListener(MouseEvent.CLICK,this.mouseClickHandler);
         super.addEventListener(MouseEvent.DOUBLE_CLICK,this.mouseDoubleClickHandler);
      }
      
      private function setupRangeDispatching() : void
      {
         this._rangeEventsInitialzed = true;
         this.addEventListener(RangeEvent.REGION_CHANGE,this.regionChangeHandler);
      }
      
      private function processRollEvents(param1:Array, param2:MouseEvent) : void
      {
         var _loc12_:Series = null;
         var _loc13_:Point = null;
         var _loc14_:DragEvent = null;
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc6_:int = param1.length;
         var _loc7_:int = this._currentHitSet.length;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Point = null;
         if(param1.length == 0 && this._currentHitSet.length == 0)
         {
            if(this._selectionMode == "single" && param2.type == MouseEvent.MOUSE_DOWN)
            {
               this.clearSelection();
               return;
            }
            if(this._selectionMode == "multiple" && param2.type == MouseEvent.MOUSE_DOWN)
            {
               this.startTracking(param2);
               return;
            }
            return;
         }
         var _loc11_:Array = param1.concat();
         if(_loc6_ > 1)
         {
            _loc11_.sortOn("id",Array.NUMERIC);
         }
         while(_loc8_ < _loc7_ || _loc9_ < _loc6_)
         {
            if(_loc9_ == _loc6_ || _loc8_ < _loc7_ && this._currentHitSet[_loc8_].id < _loc11_[_loc9_].id)
            {
               _loc3_.push(this._currentHitSet[_loc8_]);
               _loc8_++;
            }
            else if(_loc8_ == _loc7_ || _loc9_ < _loc6_ && this._currentHitSet[_loc8_].id > _loc11_[_loc9_].id)
            {
               _loc4_.push(_loc11_[_loc9_]);
               _loc9_++;
            }
            else
            {
               _loc5_.push(_loc11_[_loc9_]);
               _loc9_++;
               _loc8_++;
            }
         }
         if(_loc3_.length > 0)
         {
            dispatchEvent(new ChartItemEvent(ChartItemEvent.ITEM_ROLL_OUT,_loc3_,param2,this));
         }
         if(_loc4_.length > 0)
         {
            dispatchEvent(new ChartItemEvent(ChartItemEvent.ITEM_ROLL_OVER,_loc4_,param2,this));
         }
         if(_loc5_.length > 0)
         {
            dispatchEvent(new ChartItemEvent(ChartItemEvent.ITEM_MOUSE_MOVE,_loc5_,param2,this));
         }
         if(param2.type == MouseEvent.MOUSE_DOWN)
         {
            if(this._dragEnabled && !DragManager.isDragging)
            {
               this._mouseDown = true;
               _loc10_ = new Point(param2.localX,param2.localY);
               _loc10_ = DisplayObject(param2.target).localToGlobal(_loc10_);
               this._mouseDownPoint = globalToLocal(_loc10_);
               this._mouseDownItem = param1[0].chartItem;
            }
            else if(param1.length > 0)
            {
               this.selectItem(param1[0].chartItem,param2);
            }
         }
         if(param2.type == MouseEvent.MOUSE_UP)
         {
            if(this._dragEnabled && this._mouseDown && !DragManager.isDragging)
            {
               this.selectItem(this._mouseDownItem,param2);
            }
            this._mouseDown = false;
            this._mouseDownPoint = null;
            this._mouseDownItem = null;
         }
         if(param2.type != MouseEvent.MOUSE_DOWN && param2.type != MouseEvent.MOUSE_UP)
         {
            if(!DragManager.isDragging)
            {
               this.rollOverItem(param1,_loc3_);
            }
         }
         if(param2.type == MouseEvent.MOUSE_MOVE)
         {
            _loc10_ = new Point(param2.localX,param2.localY);
            _loc10_ = DisplayObject(param2.target).localToGlobal(_loc10_);
            _loc10_ = globalToLocal(_loc10_);
            if(this._dragEnabled && this._mouseDown && !DragManager.isDragging && (Math.abs(this._mouseDownPoint.x - _loc10_.x) > mx_internal::DRAG_THRESHOLD || Math.abs(this._mouseDownPoint.y - _loc10_.y) > mx_internal::DRAG_THRESHOLD))
            {
               if((_loc12_ = Series(this._mouseDownItem.element)).selectedItems.indexOf(this._mouseDownItem) == -1)
               {
                  this.selectItem(this._mouseDownItem,param2);
               }
               if(this._selectedSeries)
               {
                  _loc13_ = localToGlobal(this._mouseDownPoint);
                  _loc13_ = this._selectedSeries.globalToLocal(_loc13_);
                  (_loc14_ = new DragEvent(DragEvent.DRAG_START)).dragInitiator = this;
                  _loc14_.localX = _loc13_.x;
                  _loc14_.localY = _loc13_.y;
                  _loc14_.buttonDown = true;
                  this._selectedSeries.dispatchEvent(_loc14_);
               }
            }
         }
         this._currentHitSet = param1;
         if(this._dragEnabled && this._mouseDown && DragManager.isDragging)
         {
            this.updateDataTipToMatchHitSet([]);
         }
         else
         {
            this.updateDataTipToMatchHitSet(this._currentHitSet);
         }
      }
      
      mx_internal function rollOverItem(param1:Array, param2:Array) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:HitData = null;
         var _loc4_:Series = null;
         var _loc5_:int = 0;
         if(param1.length > 0)
         {
            _loc3_ = param1[0];
            if(this._selectionMode != "none" && Series(_loc3_.chartItem.element).selectable)
            {
               _loc3_.chartItem.currentState = ChartItem.ROLLOVER;
            }
         }
         if(param2.length > 0)
         {
            _loc6_ = param2.length;
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc3_ = param2[_loc7_];
               if((_loc4_ = Series(_loc3_.chartItem.element)).selectable)
               {
                  if((_loc5_ = _loc4_.selectedItems.indexOf(_loc3_.chartItem)) == -1)
                  {
                     if(!this._selectedSeries)
                     {
                        _loc3_.chartItem.currentState = ChartItem.NONE;
                     }
                     else
                     {
                        _loc3_.chartItem.currentState = ChartItem.DISABLED;
                     }
                  }
                  else
                  {
                     _loc3_.chartItem.currentState = ChartItem.SELECTED;
                  }
               }
               _loc7_++;
            }
         }
      }
      
      mx_internal function selectItem(param1:ChartItem, param2:MouseEvent) : void
      {
         var _loc7_:int = 0;
         var _loc8_:Series = null;
         var _loc3_:Series = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:int = -1;
         _loc3_ = Series(param1.element);
         if(this._selectionMode == "multiple" && param2.shiftKey && this._anchorItem)
         {
            this.handleShift(param1);
            _loc4_ = true;
            if(_loc3_.selectedItems.length > 1)
            {
               _loc7_ = _loc3_.selectedItems.indexOf(param1);
               _loc3_.selectedItems.splice(_loc7_,1);
               _loc3_.selectedItems.push(param1);
               this._selectedSeries = _loc3_;
            }
         }
         else if(this._selectionMode != "none" && _loc3_.selectable)
         {
            if(_loc3_.selectedItems.indexOf(param1) == -1)
            {
               _loc5_ = true;
            }
            if(_loc5_)
            {
               if(!this._selectedSeries)
               {
                  this.setChartItemsToDisabled();
               }
               else if(this._selectionMode == "single")
               {
                  if(this.selectedChartItems.length > 1)
                  {
                     this.clearSelection();
                     this.setChartItemsToDisabled();
                  }
                  else
                  {
                     this._selectedSeries.removeItemfromSelection(this._selectedSeries.selectedItem);
                  }
               }
               else if(!param2.ctrlKey)
               {
                  this.clearSelection();
                  this.setChartItemsToDisabled();
               }
               _loc3_.addItemtoSelection(param1);
               this._selectedSeries = _loc3_;
               _loc4_ = true;
            }
            else if(this._selectionMode == "multiple")
            {
               if(param2.ctrlKey)
               {
                  _loc3_.removeItemfromSelection(param1);
                  if(this._selectedSeries.selectedItems.length == 0)
                  {
                     _loc8_ = _loc3_;
                     if(!(_loc8_ = this.getSelectedSeries(_loc3_)))
                     {
                        this.clearSelection();
                     }
                     else
                     {
                        this._selectedSeries = _loc8_;
                     }
                  }
                  _loc4_ = true;
               }
               else if(_loc3_ == this._selectedSeries && !this.getSelectedSeries(_loc3_) && this._selectedSeries.selectedItems.length == 1)
               {
                  _loc4_ = false;
               }
               else
               {
                  this.clearSelection();
                  this.setChartItemsToDisabled();
                  _loc3_.addItemtoSelection(param1);
                  this._selectedSeries = _loc3_;
                  _loc4_ = true;
               }
               param1.currentState = ChartItem.ROLLOVER;
            }
            else
            {
               if(this.selectedChartItems.length > 1)
               {
                  this.clearSelection();
                  _loc3_.addItemtoSelection(param1);
               }
               this._selectedSeries = _loc3_;
            }
         }
         if(_loc4_)
         {
            if(this._selectedSeries)
            {
               if(this._caretItem)
               {
                  if(Series(this._caretItem.element).selectedItems.indexOf(this._caretItem) != -1)
                  {
                     this._caretItem.currentState = ChartItem.SELECTED;
                  }
                  else
                  {
                     this._caretItem.currentState = ChartItem.DISABLED;
                  }
               }
               this._caretItem = this._selectedSeries.selectedItem;
               this._caretItem.currentState = ChartItem.FOCUSEDSELECTED;
               if(!this._anchorItem || !param2.shiftKey)
               {
                  this._anchorItem = this._caretItem;
               }
            }
            dispatchEvent(new ChartItemEvent(ChartItemEvent.CHANGE,null,param2,this));
         }
      }
      
      mx_internal function getSelectedSeries(param1:Series) : Series
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = this._transforms.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this._transforms[_loc3_].elements.length;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               if(this._transforms[_loc3_].elements[_loc5_] is Series && this._transforms[_loc3_].elements[_loc5_] != param1 && this._transforms[_loc3_].elements[_loc5_].selectedItems.length != 0)
               {
                  return this._transforms[_loc3_].elements[_loc5_];
               }
               _loc5_++;
            }
            _loc3_++;
         }
         return null;
      }
      
      mx_internal function setChartItemsToDisabled() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:int = this._transforms.length;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this._transforms[_loc2_].elements.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(this._transforms[_loc2_].elements[_loc4_] is Series)
               {
                  this._transforms[_loc2_].elements[_loc4_].clearSeriesItemsState(false,ChartItem.DISABLED);
               }
               _loc4_++;
            }
            _loc2_++;
         }
      }
      
      public function clearSelection() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._selectedSeries)
         {
            _loc1_ = this._transforms.length;
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               _loc3_ = this._transforms[_loc2_].elements.length;
               _loc4_ = 0;
               while(_loc4_ < _loc3_)
               {
                  if(this._transforms[_loc2_].elements[_loc4_] is Series)
                  {
                     this._transforms[_loc2_].elements[_loc4_].clearSeriesItemsState(true);
                  }
                  _loc4_++;
               }
               _loc2_++;
            }
            this._selectedSeries = null;
            this._caretItem = null;
            this._anchorItem = null;
         }
      }
      
      mx_internal function selectSpecificChartItems(param1:Array) : void
      {
         var _loc2_:Series = null;
         var _loc3_:ChartItem = null;
         var _loc4_:int = -1;
         var _loc5_:Boolean = false;
         this.clearSelection();
         var _loc6_:int = param1.length;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc2_ = Series(param1[_loc7_].element);
            if(_loc2_.selectable)
            {
               if(!_loc5_)
               {
                  _loc5_ = true;
                  this.setChartItemsToDisabled();
               }
               if(this._selectionMode == "single" && this._selectedSeries)
               {
                  this._selectedSeries.removeItemfromSelection(this._selectedSeries.selectedItem);
               }
               if(_loc2_.selectedItems.indexOf(param1[_loc7_]) == -1)
               {
                  _loc2_.addItemtoSelection(param1[_loc7_]);
               }
               this._selectedSeries = _loc2_;
            }
            _loc7_++;
         }
         if(this._selectedSeries)
         {
            this._caretItem = this._selectedSeries.selectedItem;
            this._caretItem.currentState = ChartItem.FOCUSEDSELECTED;
            this._anchorItem = this._caretItem;
         }
      }
      
      mx_internal function seriesSelectionChanged(param1:Series, param2:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Series = null;
         if(this._selectionMode == "none")
         {
            return;
         }
         if(!this._selectedSeries)
         {
            this.setChartItemsToDisabled();
         }
         else
         {
            param1.clearSeriesItemsState(true,ChartItem.DISABLED);
         }
         if(param2.length == 0)
         {
            _loc3_ = this.getSelectedSeries(param1);
            if(!_loc3_)
            {
               this.clearSelection();
            }
            else
            {
               this._selectedSeries = _loc3_;
            }
         }
         else
         {
            if(this._selectionMode == "single")
            {
               if(this._selectedSeries && this._selectedSeries != param1)
               {
                  this._selectedSeries.removeItemfromSelection(this._selectedSeries.selectedItem);
               }
               param1.addItemtoSelection(param2[param2.length - 1]);
            }
            else
            {
               _loc4_ = param2.length;
               _loc5_ = 0;
               while(_loc5_ < _loc4_)
               {
                  param1.addItemtoSelection(param2[_loc5_]);
                  _loc5_++;
               }
            }
            this._selectedSeries = param1;
         }
         if(this._selectedSeries)
         {
            this._caretItem = this._selectedSeries.selectedItem;
            this._caretItem.currentState = ChartItem.FOCUSEDSELECTED;
            this._anchorItem = this._caretItem;
         }
      }
      
      mx_internal function handleSpace(param1:KeyboardEvent) : void
      {
         var _loc2_:Series = null;
         var _loc6_:Series = null;
         var _loc7_:ChartItem = null;
         if(!this._caretItem)
         {
            return;
         }
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         if(param1.ctrlKey)
         {
            _loc4_ = true;
         }
         if(param1.shiftKey)
         {
            _loc5_ = true;
            _loc4_ = false;
         }
         _loc2_ = Series(this._caretItem.element);
         if(_loc2_.selectable)
         {
            if(_loc2_.selectedItems.indexOf(this._caretItem) != -1)
            {
               if(_loc4_)
               {
                  _loc2_.removeItemfromSelection(this._caretItem);
                  this._caretItem.currentState = ChartItem.FOCUSED;
                  if(this.selectionMode == "single")
                  {
                     this.clearSelection();
                  }
                  else if(this._selectedSeries.selectedItems.length == 0)
                  {
                     _loc6_ = _loc2_;
                     if(!(_loc6_ = this.getSelectedSeries(_loc2_)))
                     {
                        this.clearSelection();
                     }
                     else
                     {
                        this._selectedSeries = _loc6_;
                     }
                  }
                  _loc3_ = true;
               }
            }
            else
            {
               if(this._selectionMode == "single" || this._selectionMode == "multiple" && !_loc4_)
               {
                  _loc7_ = this._caretItem;
                  this.clearSelection();
                  this._caretItem = _loc7_;
                  this._anchorItem = _loc7_;
               }
               if(!this._selectedSeries)
               {
                  this.setChartItemsToDisabled();
               }
               this._selectedSeries = _loc2_;
               this._selectedSeries.addItemtoSelection(this._caretItem);
               this._caretItem.currentState = ChartItem.FOCUSEDSELECTED;
               _loc3_ = true;
            }
         }
         if(_loc3_)
         {
            if(this._selectedSeries && (!_loc5_ || !this._anchorItem))
            {
               this._anchorItem = this._selectedSeries.selectedItem;
            }
            dispatchEvent(new ChartItemEvent(ChartItemEvent.CHANGE,null,null,this));
         }
      }
      
      mx_internal function handleNavigation(param1:ChartItem, param2:KeyboardEvent) : void
      {
         var _loc3_:Series = null;
         var _loc4_:Series = null;
         var _loc8_:Series = null;
         var _loc9_:ChartItem = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         _loc3_ = Series(param1.element);
         if(param2.ctrlKey)
         {
            _loc6_ = true;
         }
         if(param2.shiftKey)
         {
            _loc7_ = true;
            _loc6_ = false;
         }
         if(_loc6_)
         {
            if(this._caretItem)
            {
               if((_loc8_ = Series(this._caretItem.element)).selectable)
               {
                  if(_loc8_.selectedItems.indexOf(this._caretItem) != -1)
                  {
                     this._caretItem.currentState = ChartItem.SELECTED;
                  }
                  else if(this._selectedSeries)
                  {
                     this._caretItem.currentState = ChartItem.DISABLED;
                  }
                  else
                  {
                     this._caretItem.currentState = ChartItem.NONE;
                  }
               }
            }
            param1.currentState = ChartItem.FOCUSED;
         }
         else
         {
            if(!_loc7_ || !this._anchorItem)
            {
               if(!this._selectedSeries)
               {
                  this.setChartItemsToDisabled();
               }
               else if(this.selectionMode == "single")
               {
                  this._selectedSeries.removeItemfromSelection(this._selectedSeries.selectedItem);
               }
               else
               {
                  this.clearSelection();
                  this.setChartItemsToDisabled();
               }
               _loc3_.addItemtoSelection(param1);
               this._selectedSeries = _loc3_;
               param1.currentState = ChartItem.FOCUSEDSELECTED;
            }
            else
            {
               if(this.selectionMode == "single")
               {
                  this._selectedSeries.removeItemfromSelection(this._selectedSeries.selectedItem);
                  _loc3_.addItemtoSelection(param1);
               }
               else
               {
                  _loc9_ = this._anchorItem;
                  _loc10_ = Series(this._anchorItem.element).items.indexOf(this._anchorItem);
                  _loc11_ = _loc3_.items.indexOf(param1);
                  this.clearSelection();
                  this.setChartItemsToDisabled();
                  this._anchorItem = _loc9_;
                  if(Series(this._anchorItem.element) == _loc3_)
                  {
                     if(_loc10_ > _loc11_)
                     {
                        _loc12_ = _loc10_;
                        _loc10_ = _loc11_;
                        _loc11_ = _loc12_;
                     }
                     _loc12_ = _loc10_;
                     while(_loc12_ <= _loc11_)
                     {
                        _loc3_.addItemtoSelection(_loc3_.items[_loc12_]);
                        _loc12_++;
                     }
                  }
                  else
                  {
                     Series(this._anchorItem.element).addItemtoSelection(this._anchorItem);
                     _loc3_.addItemtoSelection(param1);
                  }
               }
               this._selectedSeries = _loc3_;
               param1.currentState = ChartItem.FOCUSEDSELECTED;
            }
            _loc5_ = true;
         }
         this._caretItem = param1;
         if(_loc5_ && this._selectedSeries)
         {
            if(!_loc7_ || this._selectedSeries && !this._anchorItem)
            {
               this._anchorItem = this._selectedSeries.selectedItem;
            }
            dispatchEvent(new ChartItemEvent(ChartItemEvent.CHANGE,null,null,this));
         }
      }
      
      mx_internal function handleShift(param1:ChartItem) : void
      {
         var _loc7_:Array = null;
         var _loc8_:Point = null;
         var _loc2_:ChartItem = this._anchorItem;
         var _loc3_:ChartItem = this._caretItem;
         if(!this._anchorItem.itemRenderer || !param1.itemRenderer)
         {
            return;
         }
         var _loc4_:Rectangle = new Rectangle();
         var _loc5_:Point = new Point(this._anchorItem.itemRenderer.x,this._anchorItem.itemRenderer.y);
         var _loc6_:Point = new Point(param1.itemRenderer.x,param1.itemRenderer.y);
         _loc5_ = Series(this._anchorItem.element).localToGlobal(_loc5_);
         _loc6_ = Series(param1.element).localToGlobal(_loc6_);
         _loc4_.left = Math.min(_loc5_.x,_loc6_.x,_loc5_.x + this._anchorItem.itemRenderer.width,_loc6_.x + param1.itemRenderer.width);
         _loc4_.top = Math.min(_loc5_.y,_loc6_.y,_loc5_.y + this._anchorItem.itemRenderer.height,_loc6_.y + param1.itemRenderer.height);
         _loc4_.right = Math.max(_loc5_.x,_loc6_.x,_loc5_.x + this._anchorItem.itemRenderer.width,_loc6_.x + param1.itemRenderer.width);
         _loc4_.bottom = Math.max(_loc5_.y,_loc6_.y,_loc5_.y + this._anchorItem.itemRenderer.height,_loc6_.y + param1.itemRenderer.height);
         _loc4_.left += 2;
         _loc4_.top += 2;
         _loc4_.right -= 2;
         _loc4_.bottom -= 2;
         this.selectRectangleRegion(_loc4_);
         this._anchorItem = _loc2_;
         this._caretItem = _loc3_;
      }
      
      private function selectRectangleRegion(param1:Rectangle, param2:Boolean = false) : void
      {
         var _loc3_:Array = this.getItemsInRegion(param1);
         if(param2)
         {
            _loc3_ = _loc3_.concat(this.selectedChartItems);
         }
         this.selectSpecificChartItems(_loc3_);
      }
      
      mx_internal function getSeriesTransformState(param1:Object) : Boolean
      {
         return param1.getTransformState();
      }
      
      private function findItemsInRegionFromElements(param1:DataTransform, param2:Rectangle) : Array
      {
         var _loc3_:Array = param1.elements;
         var _loc4_:Array = [];
         var _loc5_:int = _loc3_.length;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            if(_loc3_[_loc6_] is Series && _loc3_[_loc6_].selectable && _loc3_[_loc6_].visible)
            {
               _loc4_ = _loc4_.concat(_loc3_[_loc6_].getItemsInRegion(param2));
            }
            _loc6_++;
         }
         return _loc4_;
      }
      
      private function updateDataTips() : void
      {
         var _loc1_:Array = this.findDataPoints(mouseX,mouseY);
         this._currentHitSet = _loc1_;
         this.updateDataTipToMatchHitSet(this._currentHitSet);
      }
      
      public function updateAllDataTips() : void
      {
         var _loc1_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:* = undefined;
         var _loc5_:HitData = null;
         var _loc6_:IFlexDisplayObject = null;
         if(!this.showAllDataTips && !this.dataTipItemsSet)
         {
            _loc1_ = [];
         }
         else
         {
            _loc1_ = this.getAllDataPoints();
         }
         var _loc2_:Number = _loc1_.length;
         if(_loc2_ == 0)
         {
            if(this._allTipCache)
            {
               this._allTipCache.count = 0;
            }
         }
         else
         {
            if(!this._allTipCache)
            {
               _loc4_ = getStyle("dataTipRenderer");
               this._allTipCache = new InstanceCache(_loc4_,this,-1,moduleFactory);
               this._allTipCache.discard = true;
               this._allTipCache.remove = true;
            }
            this._allTipCache.count = _loc2_;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc5_ = _loc1_[_loc3_];
               _loc6_ = this._allTipCache.instances[_loc3_];
               if(this.dataTipFunction != null)
               {
                  _loc5_.dataTipFunction = this.invokeDTFunction;
               }
               if(_loc6_ is IDataRenderer)
               {
                  (_loc6_ as IDataRenderer).data = _loc5_;
               }
               _loc3_++;
            }
         }
         this.positionAllDataTips(_loc1_);
      }
      
      private function updateDataTipToMatchHitSet(param1:Array) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:* = undefined;
         var _loc5_:HitData = null;
         var _loc6_:IFlexDisplayObject = null;
         if(this._showDataTips == false)
         {
            _loc2_ = 0;
         }
         else if(this._dataTipMode == "multiple")
         {
            _loc2_ = getStyle("maximumDataTipCount");
            if(isNaN(_loc2_))
            {
               _loc2_ = param1.length;
            }
            else
            {
               _loc2_ = Math.min(_loc2_,param1.length);
            }
         }
         else
         {
            _loc2_ = Math.min(param1.length,1);
         }
         if(_loc2_ == 0)
         {
            if(this._tipCache)
            {
               this._tipCache.count = 0;
            }
         }
         else
         {
            if(!this._tipCache)
            {
               _loc4_ = getStyle("dataTipRenderer");
               this._tipCache = new InstanceCache(_loc4_,systemManager.toolTipChildren,-1,moduleFactory);
               this._tipCache.discard = true;
               this._tipCache.remove = true;
               this._tipCache.creationCallback = this.tipCreated;
            }
            this._tipCache.count = _loc2_;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc5_ = param1[_loc3_];
               _loc6_ = this._tipCache.instances[_loc3_];
               if(this.dataTipFunction != null)
               {
                  _loc5_.dataTipFunction = this.invokeDTFunction;
               }
               if(_loc6_ is IDataRenderer)
               {
                  (_loc6_ as IDataRenderer).data = _loc5_;
               }
               _loc3_++;
            }
         }
         this.positionDataTips();
      }
      
      private function tipCreated(param1:IEventDispatcher, param2:InstanceCache) : void
      {
         param1.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         param1.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         param1.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
      }
      
      private function invokeDTFunction(param1:HitData) : String
      {
         return this.dataTipFunction(param1);
      }
      
      protected function positionAllDataTips(param1:Array) : void
      {
         var _loc5_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:TipPositionData = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:Array = null;
         var _loc15_:TipStack = null;
         var _loc28_:HitData = null;
         var _loc29_:IFlexDisplayObject = null;
         var _loc30_:Point = null;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Point = null;
         var _loc34_:Point = null;
         var _loc35_:int = 0;
         var _loc36_:TipPositionData = null;
         var _loc37_:Boolean = false;
         var _loc38_:Boolean = false;
         var _loc39_:int = 0;
         var _loc40_:uint = 0;
         var _loc2_:int = !!this._allTipCache ? int(this._allTipCache.count) : 0;
         var _loc3_:Rectangle = this.dataRegion;
         var _loc4_:Graphics = this._allDataTipOverlay.graphics;
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         var _loc8_:Array = [];
         var _loc16_:IStroke = getStyle("calloutStroke");
         var _loc17_:Number = getStyle("horizontalDataTipOffset");
         var _loc18_:Number = getStyle("horizontalDataTipOffset");
         if(isNaN(_loc17_))
         {
            _loc17_ = 6;
         }
         if(isNaN(_loc18_))
         {
            _loc18_ = 6;
         }
         _loc4_.clear();
         if(_loc2_ == 0)
         {
            return;
         }
         var _loc19_:Object;
         var _loc20_:Boolean = (_loc19_ = getStyle("showDataTipTargets")) != false && _loc19_ != "false";
         _loc5_ = this._allTipCache.instances.slice(0,_loc2_);
         var _loc21_:Point = new Point();
         _loc9_ = 0;
         while(_loc9_ < _loc2_)
         {
            _loc28_ = param1[_loc9_];
            _loc29_ = _loc5_[_loc9_];
            _loc21_.x = Math.max(_loc3_.left,Math.min(_loc28_.x,_loc3_.right));
            _loc21_.y = Math.max(_loc3_.top,Math.min(_loc28_.y,_loc3_.bottom));
            _loc30_ = localToGlobal(_loc21_);
            if(_loc29_ is ILayoutManagerClient)
            {
               ILayoutManagerClient(_loc29_).validateSize();
            }
            if((_loc10_ = new TipPositionData(_loc29_,_loc28_,_loc21_.x,_loc21_.y,_loc30_.x,_loc30_.y)).gy - _loc18_ - _loc29_.measuredHeight > 0)
            {
               _loc10_.py = _loc10_.gy - _loc18_ - _loc29_.measuredHeight;
            }
            else
            {
               _loc10_.py = _loc10_.gy + _loc18_;
            }
            _loc8_.push(_loc10_);
            _loc5_[_loc9_] = _loc10_;
            _loc9_++;
         }
         if(_loc8_.length > 0)
         {
            _loc8_.sortOn("gx",Array.NUMERIC);
            _loc11_ = _loc8_[0].gx;
            _loc12_ = _loc8_[_loc8_.length - 1].gx;
            _loc33_ = new Point(4,4);
            _loc34_ = new Point(screen.width - 4,screen.height - 4);
            _loc9_ = 0;
            _loc35_ = Math.floor(_loc8_.length / 2);
            if(_loc6_.length > _loc7_.length)
            {
               _loc35_ = Math.max(0,_loc35_ - (_loc6_.length - _loc7_.length));
            }
            else if(_loc7_.length > _loc6_.length)
            {
               _loc35_ = Math.min(_loc8_.length,_loc35_ + (_loc7_.length - _loc6_.length));
            }
            _loc6_ = _loc6_.concat(_loc8_.slice(0,_loc35_));
            _loc7_ = _loc7_.concat(_loc8_.slice(_loc35_,_loc8_.length));
         }
         _loc7_.sortOn("gy");
         _loc13_ = _loc7_.length;
         _loc14_ = [];
         _loc15_ = null;
         _loc9_ = 0;
         while(_loc9_ < _loc13_)
         {
            (_loc10_ = _loc7_[_loc9_]).isRight = true;
            _loc10_.px = _loc10_.gx + _loc17_;
            if(_loc15_)
            {
               if(_loc10_.py < _loc15_.gy + _loc15_.height)
               {
                  _loc15_.addTip(_loc10_,screen.height);
               }
               else
               {
                  this.reduceStacks(_loc14_,_loc15_);
                  (_loc15_ = new TipStack()).addTip(_loc10_,screen.height);
               }
            }
            else
            {
               (_loc15_ = new TipStack()).addTip(_loc10_,screen.height);
            }
            _loc9_++;
         }
         if(_loc15_)
         {
            this.reduceStacks(_loc14_,_loc15_);
         }
         var _loc22_:Number = 0;
         var _loc23_:Number = 0;
         _loc13_ = _loc14_.length;
         _loc9_ = 0;
         while(_loc9_ < _loc13_)
         {
            _loc14_[_loc9_].positionY();
            _loc9_++;
         }
         _loc6_.sortOn("gy");
         _loc13_ = _loc6_.length;
         _loc14_ = [];
         _loc15_ = null;
         _loc9_ = 0;
         while(_loc9_ < _loc13_)
         {
            (_loc10_ = _loc6_[_loc9_]).isRight = false;
            _loc10_.px = _loc10_.gx - _loc10_.width - _loc17_;
            if(_loc15_)
            {
               if(_loc10_.py < _loc15_.gy + _loc15_.height)
               {
                  _loc15_.addTip(_loc10_,screen.height);
               }
               else
               {
                  this.reduceStacks(_loc14_,_loc15_);
                  (_loc15_ = new TipStack()).addTip(_loc10_,screen.height);
               }
            }
            else
            {
               (_loc15_ = new TipStack()).addTip(_loc10_,screen.height);
            }
            _loc9_++;
         }
         if(_loc15_)
         {
            this.reduceStacks(_loc14_,_loc15_);
         }
         _loc13_ = _loc14_.length;
         _loc9_ = 0;
         while(_loc9_ < _loc13_)
         {
            _loc14_[_loc9_].positionY();
            _loc9_++;
         }
         _loc5_.sortOn("py");
         _loc13_ = _loc5_.length;
         _loc12_ = -Infinity;
         _loc11_ = Infinity;
         var _loc24_:Number = -Infinity;
         var _loc25_:Number = Infinity;
         var _loc26_:Boolean = true;
         var _loc27_:Number = 0;
         while(_loc26_ && _loc27_ <= 2)
         {
            _loc26_ = false;
            _loc27_++;
            _loc9_ = 0;
            while(_loc9_ < _loc13_)
            {
               _loc36_ = _loc5_[_loc9_];
               _loc37_ = false;
               _loc38_ = false;
               while(_loc22_ < _loc5_.length && _loc5_[_loc22_].gy + TOOLTIP_TARGET_RADIUS < _loc36_.py)
               {
                  if(_loc5_[_loc22_].gx >= _loc12_)
                  {
                     _loc37_ = true;
                  }
                  if(_loc5_[_loc22_].gx <= _loc11_)
                  {
                     _loc38_ = true;
                  }
                  _loc22_++;
               }
               _loc23_ = Math.max(_loc23_,_loc22_);
               while(_loc23_ < _loc5_.length && _loc5_[_loc23_].gy - TOOLTIP_TARGET_RADIUS < _loc36_.py + _loc36_.height)
               {
                  if(_loc5_[_loc23_].gx >= _loc12_)
                  {
                     _loc37_ = false;
                     _loc12_ = _loc5_[_loc23_].gx;
                  }
                  if(_loc5_[_loc23_].gx <= _loc11_)
                  {
                     _loc38_ = false;
                     _loc11_ = _loc5_[_loc23_].gx;
                  }
                  _loc23_++;
               }
               if(_loc37_ || _loc38_)
               {
                  _loc12_ = -Infinity;
                  _loc11_ = Infinity;
                  _loc39_ = _loc22_;
                  while(_loc39_ < _loc23_)
                  {
                     _loc12_ = Math.max(_loc12_,_loc5_[_loc39_].gx);
                     _loc11_ = Math.min(_loc11_,_loc5_[_loc39_].gx);
                     _loc39_++;
                  }
               }
               if(_loc36_.isRight)
               {
                  _loc36_.px = Math.max(_loc36_.px,_loc12_ + TOOLTIP_TARGET_RADIUS);
                  _loc36_.px = Math.max(_loc24_,_loc36_.px);
                  if(_loc36_.px > _loc34_.x - _loc36_.width)
                  {
                     _loc36_.px = _loc34_.x - _loc36_.width;
                     if(_loc25_ > _loc36_.px)
                     {
                        _loc25_ = _loc36_.px;
                        _loc26_ = true;
                     }
                  }
               }
               else
               {
                  _loc36_.px = Math.min(_loc36_.px,_loc11_ - TOOLTIP_TARGET_RADIUS - _loc36_.width);
                  _loc36_.px = Math.min(_loc25_ - _loc36_.width,_loc36_.px);
                  if(_loc36_.px < _loc33_.x)
                  {
                     _loc36_.px = _loc33_.x;
                     if(_loc36_.px + _loc36_.width > _loc24_)
                     {
                        _loc24_ = _loc36_.px + _loc36_.width;
                        _loc26_ = true;
                     }
                  }
               }
               _loc30_.x = _loc36_.px;
               _loc30_.y = _loc36_.py;
               _loc21_ = globalToLocal(_loc30_);
               if(layoutDirection == LayoutDirection.RTL)
               {
                  _loc36_.tip.move(_loc21_.x - _loc36_.width,_loc21_.y);
               }
               else
               {
                  _loc36_.tip.move(_loc21_.x,_loc21_.y);
               }
               if(_loc20_)
               {
                  if(_loc13_ > 1)
                  {
                     if(_loc16_)
                     {
                        _loc16_.apply(_loc4_,null,null);
                        if(_loc36_.isRight)
                        {
                           _loc4_.moveTo(_loc21_.x,_loc21_.y + _loc36_.height / 2);
                           _loc4_.lineTo(_loc36_.x,_loc21_.y + _loc36_.height / 2);
                           _loc4_.lineTo(_loc36_.x,_loc36_.y);
                        }
                        else
                        {
                           if(layoutDirection == LayoutDirection.RTL)
                           {
                              _loc4_.moveTo(_loc21_.x - _loc36_.width,_loc21_.y + _loc36_.height / 2);
                           }
                           else
                           {
                              _loc4_.moveTo(_loc21_.x + _loc36_.width,_loc21_.y + _loc36_.height / 2);
                           }
                           _loc4_.lineTo(_loc36_.x,_loc21_.y + _loc36_.height / 2);
                           _loc4_.lineTo(_loc36_.x,_loc36_.y);
                        }
                     }
                  }
                  _loc40_ = _loc36_.hd.contextColor;
                  _loc4_.lineStyle(1,_loc40_,100);
                  _loc4_.moveTo(_loc36_.x,_loc36_.y);
                  _loc4_.beginFill(16777215,1);
                  _loc4_.drawCircle(_loc36_.x,_loc36_.y,TOOLTIP_TARGET_RADIUS);
                  _loc4_.endFill();
                  _loc4_.beginFill(_loc40_,1);
                  _loc4_.drawCircle(_loc36_.x,_loc36_.y,TOOLTIP_TARGET_INNER_RADIUS);
                  _loc4_.endFill();
               }
               _loc9_++;
            }
         }
      }
      
      protected function positionDataTips() : void
      {
         var _loc4_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:TipPositionData = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:Array = null;
         var _loc14_:TipStack = null;
         var _loc27_:HitData = null;
         var _loc28_:IFlexDisplayObject = null;
         var _loc29_:Point = null;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Point = null;
         var _loc33_:Point = null;
         var _loc34_:Point = null;
         var _loc35_:int = 0;
         var _loc36_:TipPositionData = null;
         var _loc37_:Boolean = false;
         var _loc38_:Boolean = false;
         var _loc39_:Point = null;
         var _loc40_:int = 0;
         var _loc41_:uint = 0;
         var _loc1_:int = !!this._tipCache ? int(this._tipCache.count) : 0;
         var _loc2_:Rectangle = this.dataRegion;
         var _loc3_:Graphics = this._dataTipOverlay.graphics;
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         var _loc15_:IStroke = getStyle("calloutStroke");
         var _loc16_:Number = getStyle("horizontalDataTipOffset");
         var _loc17_:Number = getStyle("horizontalDataTipOffset");
         if(isNaN(_loc16_))
         {
            _loc16_ = 6;
         }
         if(isNaN(_loc17_))
         {
            _loc17_ = 6;
         }
         _loc3_.clear();
         if(_loc1_ == 0)
         {
            return;
         }
         var _loc18_:Object;
         var _loc19_:Boolean = (_loc18_ = getStyle("showDataTipTargets")) != false && _loc18_ != "false";
         _loc4_ = this._tipCache.instances.slice(0,_loc1_);
         var _loc20_:Point = new Point();
         _loc8_ = 0;
         while(_loc8_ < _loc1_)
         {
            _loc27_ = this._currentHitSet[_loc8_];
            _loc28_ = _loc4_[_loc8_];
            _loc20_.x = Math.max(_loc2_.left,Math.min(_loc27_.x,_loc2_.right));
            _loc20_.y = Math.max(_loc2_.top,Math.min(_loc27_.y,_loc2_.bottom));
            _loc29_ = localToGlobal(_loc20_);
            if(_loc28_ is ILayoutManagerClient)
            {
               ILayoutManagerClient(_loc28_).validateSize();
            }
            if(systemManager != systemManager.topLevelSystemManager.getSandboxRoot())
            {
               _loc32_ = FlexGlobals.topLevelApplication.localToGlobal(new Point(0,0));
               _loc9_ = new TipPositionData(_loc28_,_loc27_,_loc20_.x,_loc20_.y,_loc29_.x - _loc32_.x,_loc29_.y - _loc32_.y);
            }
            else
            {
               _loc9_ = new TipPositionData(_loc28_,_loc27_,_loc20_.x,_loc20_.y,_loc29_.x,_loc29_.y);
            }
            if(_loc9_.gy - _loc17_ - _loc28_.measuredHeight > 0)
            {
               _loc9_.py = _loc9_.gy - _loc17_ - _loc28_.measuredHeight;
            }
            else
            {
               _loc9_.py = _loc9_.gy + _loc17_;
            }
            _loc7_.push(_loc9_);
            _loc4_[_loc8_] = _loc9_;
            _loc8_++;
         }
         if(_loc7_.length > 0)
         {
            _loc7_.sortOn("gx",Array.NUMERIC);
            _loc10_ = _loc7_[0].gx;
            _loc11_ = _loc7_[_loc7_.length - 1].gx;
            _loc33_ = new Point(4,4);
            _loc34_ = new Point(screen.width - 4,screen.height - 4);
            _loc8_ = 0;
            _loc35_ = Math.floor(_loc7_.length / 2);
            if(_loc5_.length > _loc6_.length)
            {
               _loc35_ = Math.max(0,_loc35_ - (_loc5_.length - _loc6_.length));
            }
            else if(_loc6_.length > _loc5_.length)
            {
               _loc35_ = Math.min(_loc7_.length,_loc35_ + (_loc6_.length - _loc5_.length));
            }
            if(_loc7_.length == 1 && layoutDirection == LayoutDirection.RTL)
            {
               _loc6_ = _loc6_.concat(_loc7_.slice(0,_loc35_));
               _loc5_ = _loc5_.concat(_loc7_.slice(_loc35_,_loc7_.length));
            }
            else
            {
               _loc5_ = _loc5_.concat(_loc7_.slice(0,_loc35_));
               _loc6_ = _loc6_.concat(_loc7_.slice(_loc35_,_loc7_.length));
            }
         }
         _loc6_.sortOn("gy");
         _loc12_ = _loc6_.length;
         _loc13_ = [];
         _loc14_ = null;
         _loc8_ = 0;
         while(_loc8_ < _loc12_)
         {
            (_loc9_ = _loc6_[_loc8_]).isRight = true;
            _loc9_.px = _loc9_.gx + _loc16_;
            if(_loc14_)
            {
               if(_loc9_.py < _loc14_.gy + _loc14_.height)
               {
                  _loc14_.addTip(_loc9_,screen.height);
               }
               else
               {
                  this.reduceStacks(_loc13_,_loc14_);
                  (_loc14_ = new TipStack()).addTip(_loc9_,screen.height);
               }
            }
            else
            {
               (_loc14_ = new TipStack()).addTip(_loc9_,screen.height);
            }
            _loc8_++;
         }
         if(_loc14_)
         {
            this.reduceStacks(_loc13_,_loc14_);
         }
         var _loc21_:Number = 0;
         var _loc22_:Number = 0;
         _loc12_ = _loc13_.length;
         _loc8_ = 0;
         while(_loc8_ < _loc12_)
         {
            _loc13_[_loc8_].positionY();
            _loc8_++;
         }
         _loc5_.sortOn("gy");
         _loc12_ = _loc5_.length;
         _loc13_ = [];
         _loc14_ = null;
         _loc8_ = 0;
         while(_loc8_ < _loc12_)
         {
            (_loc9_ = _loc5_[_loc8_]).isRight = false;
            _loc9_.px = _loc9_.gx - _loc9_.width - _loc16_;
            if(_loc14_)
            {
               if(_loc9_.py < _loc14_.gy + _loc14_.height)
               {
                  _loc14_.addTip(_loc9_,screen.height);
               }
               else
               {
                  this.reduceStacks(_loc13_,_loc14_);
                  (_loc14_ = new TipStack()).addTip(_loc9_,screen.height);
               }
            }
            else
            {
               (_loc14_ = new TipStack()).addTip(_loc9_,screen.height);
            }
            _loc8_++;
         }
         if(_loc14_)
         {
            this.reduceStacks(_loc13_,_loc14_);
         }
         _loc12_ = _loc13_.length;
         _loc8_ = 0;
         while(_loc8_ < _loc12_)
         {
            _loc13_[_loc8_].positionY();
            _loc8_++;
         }
         _loc4_.sortOn("py");
         _loc12_ = _loc4_.length;
         _loc11_ = -Infinity;
         _loc10_ = Infinity;
         var _loc23_:Number = -Infinity;
         var _loc24_:Number = Infinity;
         var _loc25_:Boolean = true;
         var _loc26_:Number = 0;
         while(_loc25_ && _loc26_ <= 2)
         {
            _loc25_ = false;
            _loc26_++;
            _loc8_ = 0;
            while(_loc8_ < _loc12_)
            {
               _loc36_ = _loc4_[_loc8_];
               _loc37_ = false;
               _loc38_ = false;
               while(_loc21_ < _loc4_.length && _loc4_[_loc21_].gy + TOOLTIP_TARGET_RADIUS < _loc36_.py)
               {
                  if(_loc4_[_loc21_].gx >= _loc11_)
                  {
                     _loc37_ = true;
                  }
                  if(_loc4_[_loc21_].gx <= _loc10_)
                  {
                     _loc38_ = true;
                  }
                  _loc21_++;
               }
               _loc22_ = Math.max(_loc22_,_loc21_);
               while(_loc22_ < _loc4_.length && _loc4_[_loc22_].gy - TOOLTIP_TARGET_RADIUS < _loc36_.py + _loc36_.height)
               {
                  if(_loc4_[_loc22_].gx >= _loc11_)
                  {
                     _loc37_ = false;
                     _loc11_ = _loc4_[_loc22_].gx;
                  }
                  if(_loc4_[_loc22_].gx <= _loc10_)
                  {
                     _loc38_ = false;
                     _loc10_ = _loc4_[_loc22_].gx;
                  }
                  _loc22_++;
               }
               if(_loc37_ || _loc38_)
               {
                  _loc11_ = -Infinity;
                  _loc10_ = Infinity;
                  _loc40_ = _loc21_;
                  while(_loc40_ < _loc22_)
                  {
                     _loc11_ = Math.max(_loc11_,_loc4_[_loc40_].gx);
                     _loc10_ = Math.min(_loc10_,_loc4_[_loc40_].gx);
                     _loc40_++;
                  }
               }
               if(_loc36_.isRight)
               {
                  _loc36_.px = Math.max(_loc36_.px,_loc11_ + TOOLTIP_TARGET_RADIUS);
                  _loc36_.px = Math.max(_loc23_,_loc36_.px);
                  if(_loc36_.px > _loc34_.x - _loc36_.width)
                  {
                     _loc36_.px = _loc34_.x - _loc36_.width;
                     if(_loc24_ > _loc36_.px)
                     {
                        _loc24_ = _loc36_.px;
                        _loc25_ = true;
                     }
                  }
               }
               else
               {
                  _loc36_.px = Math.min(_loc36_.px,_loc10_ - TOOLTIP_TARGET_RADIUS - _loc36_.width);
                  _loc36_.px = Math.min(_loc24_ - _loc36_.width,_loc36_.px);
                  if(_loc36_.px < _loc33_.x)
                  {
                     _loc36_.px = _loc33_.x;
                     if(_loc36_.px + _loc36_.width > _loc23_)
                     {
                        _loc23_ = _loc36_.px + _loc36_.width;
                        _loc25_ = true;
                     }
                  }
               }
               _loc29_.x = _loc36_.px;
               _loc29_.y = _loc36_.py;
               _loc20_ = this.parentApplication.systemManager.getSandboxRoot().globalToLocal(_loc29_);
               _loc39_ = globalToLocal(_loc29_);
               _loc36_.tip.move(_loc20_.x,_loc20_.y);
               if(_loc19_)
               {
                  if(_loc12_ > 1)
                  {
                     if(_loc15_)
                     {
                        _loc15_.apply(_loc3_,null,null);
                        if(_loc36_.isRight)
                        {
                           _loc3_.moveTo(_loc39_.x,_loc39_.y + _loc36_.height / 2);
                           _loc3_.lineTo(_loc36_.x,_loc39_.y + _loc36_.height / 2);
                           _loc3_.lineTo(_loc36_.x,_loc36_.y);
                        }
                        else
                        {
                           if(layoutDirection == LayoutDirection.RTL)
                           {
                              _loc3_.moveTo(_loc39_.x - _loc36_.width,_loc39_.y + _loc36_.height / 2);
                           }
                           else
                           {
                              _loc3_.moveTo(_loc39_.x + _loc36_.width,_loc39_.y + _loc36_.height / 2);
                           }
                           _loc3_.lineTo(_loc36_.x,_loc39_.y + _loc36_.height / 2);
                           _loc3_.lineTo(_loc36_.x,_loc36_.y);
                        }
                     }
                  }
                  _loc41_ = _loc36_.hd.contextColor;
                  _loc3_.lineStyle(1,_loc41_,100);
                  _loc3_.moveTo(_loc36_.x,_loc36_.y);
                  _loc3_.beginFill(16777215,1);
                  _loc3_.drawCircle(_loc36_.x,_loc36_.y,TOOLTIP_TARGET_RADIUS);
                  _loc3_.endFill();
                  _loc3_.beginFill(_loc41_,1);
                  _loc3_.drawCircle(_loc36_.x,_loc36_.y,TOOLTIP_TARGET_INNER_RADIUS);
                  _loc3_.endFill();
               }
               _loc8_++;
            }
         }
      }
      
      private function reduceStacks(param1:Array, param2:TipStack) : void
      {
         var _loc3_:TipStack = null;
         while(param1.length > 0)
         {
            _loc3_ = param1[param1.length - 1];
            if(_loc3_.gy + _loc3_.height < param2.gy)
            {
               break;
            }
            _loc3_.merge(param2,screen.height);
            param2 = param1.pop();
         }
         param1.push(param2);
      }
      
      protected function customizeSeries(param1:Series, param2:uint) : void
      {
      }
      
      protected function invalidateData() : void
      {
         this._bDataDirty = true;
         invalidateProperties();
      }
      
      protected function applySeriesSet(param1:Array, param2:DataTransform) : Array
      {
         var _loc5_:IChartElement = null;
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if((_loc5_ = param1[_loc4_]) is Series)
            {
               this.customizeSeries(Series(param1[_loc4_]),_loc4_);
            }
            _loc4_++;
         }
         return param1;
      }
      
      mx_internal function updateChildOrder() : void
      {
         var _loc1_:int = 0;
         setChildIndex(this._backgroundElementHolder,_loc1_++);
         _loc1_ = this.updateAxisOrder(_loc1_);
         setChildIndex(this._seriesHolder,_loc1_++);
         setChildIndex(this._annotationElementHolder,_loc1_++);
         setChildIndex(this._allDataTipOverlay,_loc1_++);
         setChildIndex(this._dataTipOverlay,_loc1_++);
      }
      
      mx_internal function updateAxisOrder(param1:int) : int
      {
         return param1;
      }
      
      mx_internal function updateSeries() : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:IChartElement = null;
         var _loc5_:UIComponent = null;
         var _loc1_:Array = this.applySeriesSet(this._userSeries,this._transforms[0]);
         var _loc2_:int = !!_loc1_ ? int(_loc1_.length) : 0;
         _loc2_ = this.labelElements.numChildren;
         this.removeElements(this._backgroundElementHolder,true);
         this.removeElements(this._seriesFilterer,false);
         this.removeElements(this._annotationElementHolder,true);
         this.addElements(this._backgroundElements,this._transforms[0],this._backgroundElementHolder);
         this.allElements = this._backgroundElements.concat();
         this.addElements(_loc1_,this._transforms[0],this._seriesFilterer);
         this.allElements = this.allElements.concat(_loc1_);
         this.labelElements = [];
         var _loc6_:int = _loc1_.length;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            if(_loc4_ = _loc1_[_loc7_] as IChartElement)
            {
               Series(_loc4_).invalidateProperties();
               if(_loc5_ = UIComponent(_loc4_.labelContainer))
               {
                  this.labelElements.push(_loc5_);
               }
            }
            _loc7_++;
         }
         this.addElements(this.labelElements,this._transforms[0],this._annotationElementHolder);
         this.allElements = this.allElements.concat(this.labelElements);
         this.addElements(this._annotationElements,this._transforms[0],this._annotationElementHolder);
         this.allElements = this.allElements.concat(this._annotationElements);
         this._transforms[0].elements = this._annotationElements.concat(_loc1_).concat(this._backgroundElements);
         this._bDataDirty = true;
         this.invalidateSeriesStyles();
      }
      
      mx_internal function addElements(param1:Array, param2:DataTransform, param3:UIComponent) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc5_:IChartElement = null;
         var _loc6_:int = param1.length;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            if((_loc5_ = (_loc4_ = param1[_loc7_]) as IChartElement) && !(_loc5_ is Series) && !(_loc5_ is IDataCanvas))
            {
               _loc5_.dataTransform = param2;
            }
            param3.addChild(_loc4_);
            _loc7_++;
         }
      }
      
      mx_internal function removeElements(param1:UIComponent, param2:Boolean) : void
      {
         var _loc6_:DisplayObject = null;
         var _loc7_:IChartElement = null;
         var _loc3_:int = param1.numChildren;
         var _loc4_:int = !!param2 ? 1 : 0;
         var _loc5_:int = _loc3_ - 1;
         while(_loc5_ >= _loc4_)
         {
            if(_loc7_ = (_loc6_ = param1.removeChildAt(_loc5_)) as IChartElement)
            {
               _loc7_.dataTransform = null;
            }
            _loc5_--;
         }
      }
      
      mx_internal function updateSeriesStyles() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:IChartElement = null;
         if(this._seriesStylesDirty)
         {
            this._seriesStylesDirty = false;
            _loc1_ = 0;
            _loc2_ = getStyle("chartSeriesStyles");
            if(_loc2_)
            {
               _loc3_ = this.allElements.length;
               _loc4_ = 0;
               while(_loc4_ < _loc3_)
               {
                  if(_loc5_ = this.allElements[_loc4_] as IChartElement)
                  {
                     _loc1_ = _loc5_.claimStyles(_loc2_,_loc1_);
                  }
                  _loc4_++;
               }
            }
         }
      }
      
      mx_internal function applyDataProvider(param1:ICollectionView, param2:DataTransform) : void
      {
         var _loc4_:* = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:Object = param2.axes;
         for(_loc4_ in _loc3_)
         {
            _loc3_[_loc4_].chartDataProvider = param1;
         }
         _loc6_ = (_loc5_ = param2.elements).length;
         _loc7_ = 0;
         while(_loc7_ < _loc6_)
         {
            if(_loc5_[_loc7_] is Series)
            {
               _loc5_[_loc7_].chartDataProvider = param1;
            }
            _loc7_++;
         }
         this.clearSelection();
      }
      
      mx_internal function updateData() : void
      {
         if(this._dataProvider != null)
         {
            this.applyDataProvider(this._dataProvider,this._transforms[0]);
         }
         var _loc1_:uint = this.series.length;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            this.applyDataProvider(ICollectionView(this.dataProvider),this.series[_loc2_].dataTransform);
            _loc2_++;
         }
      }
      
      private function collectTransitions() : Array
      {
         var _loc4_:IChartElement = null;
         var _loc1_:Array = [];
         var _loc2_:int = this.allElements.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_loc4_ = this.allElements[_loc3_] as IChartElement)
            {
               _loc4_.collectTransitions(this._transitionState,_loc1_);
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      mx_internal function updateKeyboardCache() : void
      {
      }
      
      mx_internal function getNextSeries(param1:Array) : ChartItem
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         if(!this._caretItem)
         {
            _loc3_ = -1;
         }
         else
         {
            _loc3_ = param1.indexOf(Series(this._caretItem.element));
         }
         while(!_loc2_ && _loc3_ < param1.length - 1)
         {
            _loc3_++;
            if(param1[_loc3_].selectable && param1[_loc3_].visible && param1[_loc3_].items.length > 0)
            {
               _loc2_ = true;
            }
         }
         if(_loc2_)
         {
            return param1[_loc3_].items[0];
         }
         return null;
      }
      
      mx_internal function getPreviousSeries(param1:Array) : ChartItem
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         if(!this._caretItem)
         {
            _loc3_ = param1.length;
         }
         else
         {
            _loc3_ = param1.indexOf(Series(this._caretItem.element));
         }
         while(!_loc2_ && _loc3_ > 0)
         {
            _loc3_--;
            if(param1[_loc3_].selectable && param1[_loc3_].visible && param1[_loc3_].items.length > 0)
            {
               _loc2_ = true;
            }
         }
         if(_loc2_)
         {
            return param1[_loc3_].items[0];
         }
         return null;
      }
      
      mx_internal function getNextSeriesItem(param1:Array) : ChartItem
      {
         var _loc3_:Series = null;
         var _loc2_:int = 0;
         if(!this._caretItem)
         {
            return this.getNextSeries(param1);
         }
         _loc3_ = Series(this._caretItem.element);
         _loc2_ = _loc3_.items.indexOf(this._caretItem);
         if(_loc2_ == _loc3_.items.length - 1)
         {
            return null;
         }
         return _loc3_.items[++_loc2_];
      }
      
      mx_internal function getPreviousSeriesItem(param1:Array) : ChartItem
      {
         var _loc3_:Series = null;
         var _loc2_:int = 0;
         if(!this._caretItem)
         {
            return this.getPreviousSeries(param1);
         }
         _loc3_ = Series(this._caretItem.element);
         _loc2_ = _loc3_.items.indexOf(this._caretItem);
         if(_loc2_ == 0)
         {
            return null;
         }
         return _loc3_.items[--_loc2_];
      }
      
      protected function addDragData(param1:Object) : void
      {
         param1.addData(this.selectedChartItems,"chartitems");
      }
      
      public function showDropFeedback(param1:DragEvent) : void
      {
         drawFocus(true);
      }
      
      public function hideDropFeedback(param1:DragEvent) : void
      {
         drawFocus(false);
      }
      
      private function startTracking(param1:MouseEvent) : void
      {
         var _loc2_:Array = null;
         if(this.dataRegion.contains(mouseX,mouseY) == false)
         {
            return;
         }
         if(this.rangeItemRenderer)
         {
            this.rangeItemRenderer.clear();
            removeChild(this.rangeItemRenderer);
         }
         this.rangeItemRenderer = new RangeSelector();
         addChild(this.rangeItemRenderer);
         this.dataRegionForRange = this.dataRegion;
         systemManager.getSandboxRoot().addEventListener("mouseUp",this.endTracking,true);
         systemManager.getSandboxRoot().addEventListener("mouseMove",this.track,true);
         this.tX = mouseX;
         this.tY = mouseY;
         _loc2_ = [this.tX,this.tY];
         this.updateTrackBounds(_loc2_);
      }
      
      private function track(param1:MouseEvent) : void
      {
         if(param1.buttonDown == false)
         {
            this.endTracking(param1);
            return;
         }
         this.updateTrackBounds([mouseX,mouseY]);
         this.dispatchRegionChange(param1);
         param1.stopPropagation();
      }
      
      private function dispatchRegionChange(param1:MouseEvent) : void
      {
         var _loc2_:Point = new Point(this.dLeft,this.dTop);
         var _loc3_:Point = new Point(this.dRight,this.dBottom);
         _loc2_ = localToGlobal(_loc2_);
         _loc3_ = localToGlobal(_loc3_);
         var _loc4_:Rectangle = new Rectangle(_loc2_.x,_loc2_.y,_loc3_.x - _loc2_.x,_loc3_.y - _loc2_.y);
         dispatchEvent(new RangeEvent(RangeEvent.REGION_CHANGE,_loc4_,param1));
      }
      
      private function endTracking(param1:MouseEvent) : void
      {
         systemManager.getSandboxRoot().removeEventListener("mouseUp",this.endTracking,true);
         systemManager.getSandboxRoot().removeEventListener("mouseMove",this.track,true);
         this.rangeItemRenderer.clear();
         removeChild(this.rangeItemRenderer);
         this.rangeItemRenderer = null;
         this.dispatchRegionChange(param1);
      }
      
      private function updateTrackBounds(param1:Array) : void
      {
         this.dRight = Math.max(this.tX,param1[0]);
         this.dLeft = Math.min(this.tX,param1[0]);
         this.dTop = Math.min(this.tY,param1[1]);
         this.dBottom = Math.max(this.tY,param1[1]);
         this.dLeft = Math.max(this.dLeft,this.dataRegionForRange.left);
         this.dTop = Math.max(this.dTop,this.dataRegionForRange.y);
         this.dRight = Math.min(this.dRight,this.dataRegionForRange.x + this.dataRegionForRange.width);
         this.dBottom = Math.min(this.dBottom,this.dataRegionForRange.y + this.dataRegionForRange.height);
         this.rangeItemRenderer.move(this.dLeft,this.dTop);
         this.rangeItemRenderer.setActualSize(this.dRight - this.dLeft,this.dBottom - this.dTop);
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:IFlexDisplayObject = null;
         var _loc5_:Point = null;
         var _loc6_:Array = null;
         if(this._tipCache)
         {
            _loc2_ = this._tipCache.count;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = this._tipCache.instances[_loc3_];
               if(param1.target == _loc4_ || _loc4_ is DisplayObjectContainer && (_loc4_ as DisplayObjectContainer).contains(param1.target as DisplayObject))
               {
                  return;
               }
               if(param1.relatedObject && (_loc4_ == param1.relatedObject || _loc4_ is DisplayObjectContainer && (_loc4_ as DisplayObjectContainer).contains(param1.relatedObject)))
               {
                  return;
               }
               _loc3_++;
            }
         }
         if(!param1.relatedObject || param1.relatedObject != this && !contains(param1.relatedObject))
         {
            _loc5_ = new Point(param1.localX,param1.localY);
            _loc5_ = globalToLocal(DisplayObject(param1.target).localToGlobal(_loc5_));
            _loc6_ = this.findDataPoints(_loc5_.x,_loc5_.y);
            this.processRollEvents(_loc6_,param1);
         }
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:IFlexDisplayObject = null;
         if(this._tipCache)
         {
            _loc2_ = this._tipCache.count;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = this._tipCache.instances[_loc3_];
               if(param1.target == _loc4_ || _loc4_ is DisplayObjectContainer && (_loc4_ as DisplayObjectContainer).contains(param1.target as DisplayObject))
               {
                  return;
               }
               if(param1.relatedObject && (_loc4_ == param1.relatedObject || _loc4_ is DisplayObjectContainer && (_loc4_ as DisplayObjectContainer).contains(param1.relatedObject)))
               {
                  return;
               }
               _loc3_++;
            }
         }
         if(!param1.relatedObject || param1.relatedObject != this && !contains(param1.relatedObject))
         {
            this.processRollEvents([],param1);
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Point = new Point(param1.localX,param1.localY);
         _loc2_ = globalToLocal(DisplayObject(param1.target).localToGlobal(_loc2_));
         var _loc3_:Array = this.findDataPoints(_loc2_.x,_loc2_.y);
         setFocus();
         this.processRollEvents(_loc3_,param1);
         if(this._currentHitSet)
         {
            dispatchEvent(new ChartItemEvent(ChartItemEvent.ITEM_MOUSE_DOWN,this._currentHitSet,param1,this));
         }
      }
      
      private function mouseMoveHandler(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:IFlexDisplayObject = null;
         if(this._tipCache)
         {
            _loc4_ = this._tipCache.count;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc6_ = this._tipCache.instances[_loc5_];
               if(param1.target == _loc6_ || _loc6_ is DisplayObjectContainer && (_loc6_ as DisplayObjectContainer).contains(param1.target as DisplayObject))
               {
                  return;
               }
               _loc5_++;
            }
         }
         var _loc2_:Point = new Point(param1.localX,param1.localY);
         _loc2_ = globalToLocal(DisplayObject(param1.target).localToGlobal(_loc2_));
         var _loc3_:Array = this.findDataPoints(_loc2_.x,_loc2_.y);
         this.processRollEvents(_loc3_,param1);
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         var _loc2_:Point = new Point(param1.localX,param1.localY);
         _loc2_ = globalToLocal(DisplayObject(param1.target).localToGlobal(_loc2_));
         var _loc3_:Array = this.findDataPoints(_loc2_.x,_loc2_.y);
         this.processRollEvents(_loc3_,param1);
         if(this._currentHitSet)
         {
            dispatchEvent(new ChartItemEvent(ChartItemEvent.ITEM_MOUSE_UP,this._currentHitSet,param1,this));
         }
      }
      
      private function mouseClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:Point = new Point(param1.localX,param1.localY);
         _loc2_ = globalToLocal(DisplayObject(param1.target).localToGlobal(_loc2_));
         var _loc3_:Array = this.findDataPoints(_loc2_.x,_loc2_.y);
         this.processRollEvents(_loc3_,param1);
         if(this._currentHitSet && this._currentHitSet.length > 0)
         {
            dispatchEvent(new ChartItemEvent(ChartItemEvent.ITEM_CLICK,this._currentHitSet,param1,this));
         }
         else
         {
            dispatchEvent(new ChartEvent(ChartEvent.CHART_CLICK,param1,this));
         }
      }
      
      private function mouseDoubleClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:Point = new Point(param1.localX,param1.localY);
         _loc2_ = globalToLocal(DisplayObject(param1.target).localToGlobal(_loc2_));
         var _loc3_:Array = this.findDataPoints(_loc2_.x,_loc2_.y);
         this.processRollEvents(_loc3_,param1);
         if(this._currentHitSet && this._currentHitSet.length > 0)
         {
            dispatchEvent(new ChartItemEvent(ChartItemEvent.ITEM_DOUBLE_CLICK,this._currentHitSet,param1,this));
         }
         else
         {
            dispatchEvent(new ChartEvent(ChartEvent.CHART_DOUBLE_CLICK,param1,this));
         }
      }
      
      private function dataEffectEndHandler(param1:EffectEvent) : void
      {
         param1.target.removeEventListener(EffectEvent.EFFECT_END,this.dataEffectEndHandler);
         if(this.chartState == ChartState.HIDING_DATA)
         {
            this.setChartState(ChartState.PREPARING_TO_SHOW_DATA);
         }
         else
         {
            this.setChartState(ChartState.NONE);
         }
         this._transitionEffect = null;
         invalidateDisplayList();
      }
      
      private function regionChangeHandler(param1:RangeEvent) : void
      {
         var _loc2_:Boolean = true;
         if(!this._selectedSeries)
         {
            _loc2_ = false;
         }
         this.selectRectangleRegion(param1.regionSelected,param1.mouseEvent.ctrlKey || param1.mouseEvent.shiftKey);
         if((_loc2_ || this._selectedSeries) && !param1.mouseEvent.buttonDown)
         {
            dispatchEvent(new ChartItemEvent(ChartItemEvent.CHANGE,null,param1.mouseEvent,this));
         }
      }
      
      public function dragStartHandler(param1:DragEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         var _loc2_:DragSource = new DragSource();
         this.addDragData(_loc2_);
         var _loc3_:Point = param1.target.localToGlobal(new Point(param1.localX,param1.localY));
         _loc3_ = globalToLocal(_loc3_);
         var _loc4_:Number = -(_loc3_.x - param1.localX);
         var _loc5_:Number = -(_loc3_.y - param1.localY);
         DragManager.doDrag(this,_loc2_,param1,this.dragImage,_loc4_,_loc5_,0.5,this.dragMoveEnabled);
      }
      
      protected function dragEnterHandler(param1:DragEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         if(param1.dragSource.hasFormat("chartitems"))
         {
            DragManager.acceptDragDrop(this);
            DragManager.showFeedback(!!param1.ctrlKey ? DragManager.COPY : DragManager.MOVE);
            this.showDropFeedback(param1);
            return;
         }
         this.hideDropFeedback(param1);
         DragManager.showFeedback(DragManager.NONE);
      }
      
      protected function dragOverHandler(param1:DragEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         if(param1.dragSource.hasFormat("chartitems"))
         {
            DragManager.showFeedback(!!param1.ctrlKey ? DragManager.COPY : DragManager.MOVE);
            this.showDropFeedback(param1);
            return;
         }
         this.hideDropFeedback(param1);
         DragManager.showFeedback(DragManager.NONE);
      }
      
      protected function dragExitHandler(param1:DragEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         this.hideDropFeedback(param1);
         DragManager.showFeedback(DragManager.NONE);
      }
      
      protected function dragDropHandler(param1:DragEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         this.hideDropFeedback(param1);
      }
      
      protected function dragCompleteHandler(param1:DragEvent) : void
      {
         this._mouseDown = false;
         this._mouseDownItem = null;
         this._mouseDownPoint = null;
         if(param1.isDefaultPrevented())
         {
            return;
         }
      }
   }
}

class TipStack
{
    
   
   public var tips:Array;
   
   public var height:Number;
   
   public var gy:Number;
   
   function TipStack()
   {
      this.tips = [];
      super();
   }
   
   public function merge(param1:TipStack, param2:Number) : void
   {
      this.tips = this.tips.concat(param1.tips);
      var _loc3_:Number = param1.gy + param1.height - this.gy;
      this.gy = Math.max(0,this.gy - (this.gy + this.height - param1.gy) / 2);
      if(this.gy + _loc3_ > param2)
      {
         this.gy = Math.max(0,param2 - _loc3_);
      }
      this.height = _loc3_;
   }
   
   public function addTip(param1:TipPositionData, param2:Number) : void
   {
      this.tips.push(param1);
      if(this.tips.length == 1)
      {
         this.gy = param1.py;
         this.height = param1.height;
      }
      else if(this.tips.length == 2)
      {
         this.height += param1.height;
         this.gy = Math.min(param2 - this.height,Math.max(0,(this.tips[0].gy + this.tips[1].gy) / 2) - this.height / 2);
      }
      else
      {
         this.height += param1.height;
         this.gy = Math.min(param2 - this.height,Math.max(0,((this.gy + this.height / 2) * (this.tips.length - 1) + param1.gy) / this.tips.length - this.height / 2));
      }
   }
   
   public function positionY() : void
   {
      var _loc4_:TipPositionData = null;
      var _loc1_:Number = this.gy;
      var _loc2_:int = this.tips.length;
      var _loc3_:int = 0;
      while(_loc3_ < _loc2_)
      {
         (_loc4_ = this.tips[_loc3_]).py = _loc1_;
         _loc1_ += _loc4_.height;
         _loc3_++;
      }
   }
}

import mx.charts.HitData;
import mx.core.IFlexDisplayObject;

class TipPositionData
{
    
   
   public var tip:IFlexDisplayObject;
   
   public var hd:HitData;
   
   public var x:Number;
   
   public var y:Number;
   
   public var gx:Number;
   
   public var gy:Number;
   
   public var px:Number;
   
   public var py:Number;
   
   public var width:Number;
   
   public var height:Number;
   
   public var isRight:Boolean;
   
   function TipPositionData(param1:IFlexDisplayObject, param2:HitData, param3:Number, param4:Number, param5:Number, param6:Number)
   {
      super();
      this.tip = param1;
      this.hd = param2;
      this.x = param3;
      this.y = param4;
      this.gx = param5;
      this.gy = param6;
      this.width = param1.measuredWidth;
      this.height = param1.measuredHeight + 4;
   }
}

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import mx.core.mx_internal;

use namespace mx_internal;

class RangeEvent extends Event
{
   
   mx_internal static const VERSION:String = "4.6.0.23201";
   
   public static const REGION_CHANGE:String = "regionChange";
    
   
   public var regionSelected:Rectangle;
   
   public var mouseEvent:MouseEvent;
   
   function RangeEvent(param1:String, param2:Rectangle, param3:MouseEvent)
   {
      super(param1);
      this.regionSelected = param2;
      this.mouseEvent = param3;
   }
   
   override public function clone() : Event
   {
      return new RangeEvent(type,this.regionSelected,this.mouseEvent);
   }
}

import flash.display.Graphics;
import mx.skins.ProgrammaticSkin;

class RangeSelector extends ProgrammaticSkin
{
    
   
   function RangeSelector()
   {
      super();
   }
   
   public function clear() : void
   {
      var _loc1_:Graphics = graphics;
      _loc1_.clear();
   }
   
   override protected function updateDisplayList(param1:Number, param2:Number) : void
   {
      super.updateDisplayList(param1,param2);
      var _loc3_:Graphics = graphics;
      _loc3_.clear();
      _loc3_.moveTo(0,0);
      _loc3_.beginFill(14348799,0.5);
      _loc3_.lineStyle(1,40447);
      _loc3_.drawRect(0,0,width,height);
      _loc3_.endFill();
   }
}
