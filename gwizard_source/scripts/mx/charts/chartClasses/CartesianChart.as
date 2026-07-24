package mx.charts.chartClasses
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import flash.ui.Keyboard;
   import mx.charts.AxisRenderer;
   import mx.charts.ChartItem;
   import mx.charts.GridLines;
   import mx.charts.LinearAxis;
   import mx.charts.events.ChartItemEvent;
   import mx.charts.styles.HaloDefaults;
   import mx.collections.ICollectionView;
   import mx.core.IFlexModuleFactory;
   import mx.core.IUIComponent;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import mx.styles.CSSStyleDeclaration;
   
   use namespace mx_internal;
   
   public class CartesianChart extends ChartBase
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _moduleFactoryInitialized:Boolean = false;
      
      private var _transformBounds:Rectangle;
      
      private var _computedGutters:Rectangle;
      
      private var _bAxisLayoutDirty:Boolean = true;
      
      private var _bgridLinesStyleNameDirty:Boolean = true;
      
      private var _defaultGridLines:GridLines;
      
      private var _bAxisStylesDirty:Boolean = true;
      
      private var _bAxesRenderersDirty:Boolean = false;
      
      private var _bDualMode:Boolean = false;
      
      private var _labelElements2:Array;
      
      private var _allSeries:Array;
      
      private var _leftRenderers:Array;
      
      private var _rightRenderers:Array;
      
      private var _topRenderers:Array;
      
      private var _bottomRenderers:Array;
      
      private var _horizontalAxis:IAxis;
      
      public var horizontalAxisRatio:Number = 0.33;
      
      private var _horizontalAxisRenderer:IAxisRenderer;
      
      private var _horizontalAxisRenderers:Array;
      
      private var _verticalAxis:IAxis;
      
      public var verticalAxisRatio:Number = 0.33;
      
      private var _verticalAxisRenderer:IAxisRenderer;
      
      private var _verticalAxisRenderers:Array;
      
      public function CartesianChart()
      {
         this._transformBounds = new Rectangle();
         this._computedGutters = new Rectangle();
         this._allSeries = [];
         this._leftRenderers = [];
         this._rightRenderers = [];
         this._topRenderers = [];
         this._bottomRenderers = [];
         this._horizontalAxisRenderers = [];
         this._verticalAxisRenderers = [];
         super();
         this.horizontalAxis = new LinearAxis();
         this.verticalAxis = new LinearAxis();
         _transforms = [new CartesianTransform()];
         var _loc1_:GridLines = new GridLines();
         this.backgroundElements = [_loc1_];
         this._defaultGridLines = _loc1_;
         addEventListener("axisPlacementChange",this.axisPlacementChangeHandler);
      }
      
      override public function set backgroundElements(param1:Array) : void
      {
         super.backgroundElements = param1;
         this._defaultGridLines = null;
      }
      
      override protected function setChartState(param1:uint) : void
      {
         if(chartState == param1)
         {
            return;
         }
         var _loc2_:uint = chartState;
         super.setChartState(param1);
         if(this._horizontalAxisRenderer)
         {
            this._horizontalAxisRenderer.chartStateChanged(_loc2_,param1);
         }
         if(this._verticalAxisRenderer)
         {
            this._verticalAxisRenderer.chartStateChanged(_loc2_,param1);
         }
         var _loc3_:uint = this._horizontalAxisRenderers.length;
         var _loc4_:uint = 0;
         while(_loc4_ < _loc3_)
         {
            this._horizontalAxisRenderers[_loc4_].chartStateChanged(_loc2_,param1);
            _loc4_++;
         }
         _loc3_ = this._verticalAxisRenderers.length;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            this._verticalAxisRenderers[_loc4_].chartStateChanged(_loc2_,param1);
            _loc4_++;
         }
      }
      
      override protected function get dataRegion() : Rectangle
      {
         return this._transformBounds;
      }
      
      override public function get selectedChartItems() : Array
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:Array = [];
         var _loc2_:int = this._allSeries.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this._allSeries[_loc3_].selectedItems.length;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc1_.push(this._allSeries[_loc3_].selectedItems[_loc5_]);
               _loc5_++;
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function get computedGutters() : Rectangle
      {
         return this._computedGutters;
      }
      
      public function get horizontalAxis() : IAxis
      {
         return this._horizontalAxis;
      }
      
      public function set horizontalAxis(param1:IAxis) : void
      {
         this._horizontalAxis = param1;
         this._bAxesRenderersDirty = true;
         invalidateData();
         invalidateProperties();
      }
      
      mx_internal function get horizontalAxisRenderer() : IAxisRenderer
      {
         return this._horizontalAxisRenderer;
      }
      
      mx_internal function set horizontalAxisRenderer(param1:IAxisRenderer) : void
      {
         if(this._horizontalAxisRenderer)
         {
            if(DisplayObject(this._horizontalAxisRenderer).parent == this)
            {
               removeChild(DisplayObject(this._horizontalAxisRenderer));
            }
            this._horizontalAxisRenderer.otherAxes = null;
         }
         this._horizontalAxisRenderer = param1;
         if(this._horizontalAxisRenderer.axis)
         {
            this.horizontalAxis = this._horizontalAxisRenderer.axis;
         }
         this._horizontalAxisRenderer.horizontal = true;
         this._bAxesRenderersDirty = true;
         this._bAxisStylesDirty = true;
         invalidateChildOrder();
         invalidateProperties();
      }
      
      public function get horizontalAxisRenderers() : Array
      {
         return this._horizontalAxisRenderers;
      }
      
      public function set horizontalAxisRenderers(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this._horizontalAxisRenderers)
         {
            _loc2_ = this._horizontalAxisRenderers.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(DisplayObject(this._horizontalAxisRenderers[_loc3_]).parent == this)
               {
                  removeChild(DisplayObject(this._horizontalAxisRenderers[_loc3_]));
               }
               this._horizontalAxisRenderers[_loc3_].otherAxes = null;
               _loc3_++;
            }
         }
         this._horizontalAxisRenderers = param1;
         _loc2_ = param1.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            this._horizontalAxisRenderers[_loc3_].horizontal = true;
            _loc3_++;
         }
         invalidateProperties();
         this._bAxesRenderersDirty = true;
         this._bAxisStylesDirty = true;
         invalidateChildOrder();
         invalidateProperties();
      }
      
      public function get verticalAxis() : IAxis
      {
         return this._verticalAxis;
      }
      
      public function set verticalAxis(param1:IAxis) : void
      {
         this._verticalAxis = param1;
         this._bAxesRenderersDirty = true;
         invalidateData();
         invalidateChildOrder();
         invalidateProperties();
      }
      
      mx_internal function get verticalAxisRenderer() : IAxisRenderer
      {
         return this._verticalAxisRenderer;
      }
      
      mx_internal function set verticalAxisRenderer(param1:IAxisRenderer) : void
      {
         if(this._verticalAxisRenderer)
         {
            if(DisplayObject(this._verticalAxisRenderer).parent == this)
            {
               removeChild(DisplayObject(this._verticalAxisRenderer));
            }
         }
         this._verticalAxisRenderer = param1;
         if(this._verticalAxisRenderer.axis)
         {
            this.verticalAxis = this._verticalAxisRenderer.axis;
         }
         this._verticalAxisRenderer.horizontal = false;
         this._bAxisStylesDirty = true;
         this._bAxesRenderersDirty = true;
         invalidateChildOrder();
         invalidateProperties();
      }
      
      public function get verticalAxisRenderers() : Array
      {
         return this._verticalAxisRenderers;
      }
      
      public function set verticalAxisRenderers(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this._verticalAxisRenderers)
         {
            _loc2_ = this._verticalAxisRenderers.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(DisplayObject(this._verticalAxisRenderers[_loc3_]).parent == this)
               {
                  removeChild(DisplayObject(this._verticalAxisRenderers[_loc3_]));
               }
               _loc3_++;
            }
         }
         this._verticalAxisRenderers = param1;
         _loc2_ = param1.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            this._verticalAxisRenderers[_loc3_].horizontal = false;
            _loc3_++;
         }
         invalidateProperties();
         this._bAxisStylesDirty = true;
         this._bAxesRenderersDirty = true;
         invalidateProperties();
      }
      
      private function initStyles() : Boolean
      {
         HaloDefaults.init(styleManager);
         var _loc1_:CSSStyleDeclaration = styleManager.getStyleDeclaration("mx.charts.chartClasses.CartesianChart");
         _loc1_.setStyle("chartSeriesStyles",HaloDefaults.chartBaseChartSeriesStyles);
         _loc1_.setStyle("fill",new SolidColor(16777215,0));
         _loc1_.setStyle("calloutStroke",new SolidColorStroke(8947848,2));
         _loc1_.setStyle("horizontalAxisStyleNames",["blockCategoryAxis"]);
         _loc1_.setStyle("verticalAxisStyleNames",["blockNumericAxis"]);
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
         styleManager.registerInheritingStyle("axisTitleStyleName");
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Series = null;
         var _loc5_:Object = null;
         if(this._horizontalAxisRenderers.length == 0 && !this._horizontalAxisRenderer)
         {
            this.horizontalAxisRenderer = new AxisRenderer();
         }
         if(this._verticalAxisRenderers.length == 0 && !this._verticalAxisRenderer)
         {
            this.verticalAxisRenderer = new AxisRenderer();
         }
         if(this._bAxesRenderersDirty)
         {
            _loc1_ = dataTipLayerIndex - 1;
            if(this._horizontalAxisRenderer)
            {
               addChild(DisplayObject(this._horizontalAxisRenderer));
            }
            if(this._verticalAxisRenderer)
            {
               addChild(DisplayObject(this._verticalAxisRenderer));
            }
            invalidateDisplayList();
            if(_transforms)
            {
               CartesianTransform(_transforms[0]).setAxis(CartesianTransform.HORIZONTAL_AXIS,this._horizontalAxis);
               CartesianTransform(_transforms[0]).setAxis(CartesianTransform.VERTICAL_AXIS,this._verticalAxis);
            }
            if(this._horizontalAxisRenderer)
            {
               this._horizontalAxisRenderer.axis = this._horizontalAxis;
            }
            if(this._verticalAxisRenderer)
            {
               this._verticalAxisRenderer.axis = this._verticalAxis;
            }
            this.updateMultipleAxesRenderers();
            _loc2_ = series.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(_loc4_ = series[_loc3_])
               {
                  _loc4_.invalidateProperties();
               }
               _loc3_++;
            }
            _loc2_ = annotationElements.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(_loc5_ = annotationElements[_loc3_])
               {
                  if(_loc5_ is IDataCanvas)
                  {
                     _loc5_.invalidateProperties();
                  }
               }
               _loc3_++;
            }
            _loc2_ = backgroundElements.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(_loc5_ = backgroundElements[_loc3_])
               {
                  if(_loc5_ is IDataCanvas)
                  {
                     _loc5_.invalidateProperties();
                  }
               }
               _loc3_++;
            }
            this._bAxesRenderersDirty = false;
         }
         if(this._bAxisStylesDirty)
         {
            if(this._horizontalAxisRenderer && this._horizontalAxisRenderer is DualStyleObject)
            {
               DualStyleObject(this._horizontalAxisRenderer).internalStyleName = getStyle("horizontalAxisStyleNames")[0];
            }
            if(this._verticalAxisRenderer && this._verticalAxisRenderer is DualStyleObject)
            {
               DualStyleObject(this._verticalAxisRenderer).internalStyleName = getStyle("verticalAxisStyleNames")[0];
            }
            this.updateMultipleAxesStyles();
            this._bAxisStylesDirty = false;
         }
         if(this._bgridLinesStyleNameDirty)
         {
            if(this._defaultGridLines)
            {
               this._defaultGridLines.internalStyleName = getStyle("gridLinesStyleName");
            }
            this._bgridLinesStyleNameDirty = false;
         }
         super.commitProperties();
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         this.updateAxisLayout(param1,param2);
         advanceEffectState();
      }
      
      override public function styleChanged(param1:String) : void
      {
         if(this._defaultGridLines && param1 == "gridLinesStyleName")
         {
            this._bgridLinesStyleNameDirty = true;
            this._defaultGridLines.internalStyleName = getStyle("gridLinesStyleName");
            invalidateDisplayList();
         }
         if(param1 == null || param1.indexOf("gutter") == 0)
         {
            this._bAxisLayoutDirty = true;
            invalidateDisplayList();
         }
         if(param1 == null || this._horizontalAxisRenderers.length > 0 && param1 == "horizontalAxisStyleNames")
         {
            this._bAxisStylesDirty = true;
            invalidateDisplayList();
         }
         if(param1 == null || this._verticalAxisRenderers.length > 0 && param1 == "verticalAxisStyleNames")
         {
            this._bAxisStylesDirty = true;
            invalidateDisplayList();
         }
         super.styleChanged(param1);
      }
      
      override mx_internal function updateData() : void
      {
         if(dataProvider != null)
         {
            applyDataProvider(ICollectionView(dataProvider),_transforms[0]);
         }
      }
      
      override mx_internal function updateSeries() : void
      {
         var _loc2_:int = 0;
         var _loc4_:DisplayObject = null;
         var _loc5_:IChartElement = null;
         var _loc6_:UIComponent = null;
         var _loc1_:Array = applySeriesSet(series,_transforms[0]);
         var _loc3_:int = !!_loc1_ ? int(_loc1_.length) : 0;
         removeElements(_backgroundElementHolder,true);
         removeElements(_seriesFilterer,false);
         removeElements(_annotationElementHolder,true);
         addElements(backgroundElements,_transforms[0],_backgroundElementHolder);
         allElements = backgroundElements.concat();
         addElements(_loc1_,_transforms[0],_seriesFilterer);
         allElements = allElements.concat(_loc1_);
         labelElements = [];
         var _loc7_:int = _loc1_.length;
         _loc2_ = 0;
         while(_loc2_ < _loc7_)
         {
            if(_loc5_ = _loc1_[_loc2_] as IChartElement)
            {
               Series(_loc5_).dataTransform = new CartesianTransform();
               Series(_loc5_).invalidateProperties();
               if(_loc6_ = UIComponent(_loc5_.labelContainer))
               {
                  labelElements.push(_loc6_);
               }
            }
            _loc2_++;
         }
         addElements(labelElements,_transforms[0],_annotationElementHolder);
         allElements = allElements.concat(labelElements);
         addElements(annotationElements,_transforms[0],_annotationElementHolder);
         allElements = allElements.concat(annotationElements);
         _transforms[0].elements = annotationElements.concat(_loc1_).concat(backgroundElements);
         this._allSeries = this.findSeriesObjects(series);
         invalidateData();
         invalidateSeriesStyles();
      }
      
      override mx_internal function updateAxisOrder(param1:int) : int
      {
         if(this._horizontalAxisRenderer)
         {
            setChildIndex(DisplayObject(this._horizontalAxisRenderer),param1++);
         }
         if(this._verticalAxisRenderer)
         {
            setChildIndex(DisplayObject(this._verticalAxisRenderer),param1++);
         }
         var _loc2_:int = this._horizontalAxisRenderers.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            setChildIndex(DisplayObject(this._horizontalAxisRenderers[_loc3_]),param1++);
            _loc3_++;
         }
         _loc2_ = this._verticalAxisRenderers.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            setChildIndex(DisplayObject(this._verticalAxisRenderers[_loc3_]),param1++);
            _loc3_++;
         }
         return param1;
      }
      
      override public function getLastItem(param1:String) : ChartItem
      {
         var _loc2_:ChartItem = null;
         if(_caretItem)
         {
            _loc2_ = Series(_caretItem.element).items[Series(_caretItem.element).items.length - 1];
         }
         else
         {
            _loc2_ = getPreviousSeriesItem(this._allSeries);
         }
         return _loc2_;
      }
      
      override public function getFirstItem(param1:String) : ChartItem
      {
         var _loc2_:ChartItem = null;
         if(_caretItem)
         {
            _loc2_ = Series(_caretItem.element).items[0];
         }
         else
         {
            _loc2_ = getNextSeriesItem(this._allSeries);
         }
         return _loc2_;
      }
      
      override public function getNextItem(param1:String) : ChartItem
      {
         if(param1 == ChartBase.HORIZONTAL)
         {
            return getNextSeriesItem(this._allSeries);
         }
         if(param1 == ChartBase.VERTICAL)
         {
            return getNextSeries(this._allSeries);
         }
         return null;
      }
      
      override public function getPreviousItem(param1:String) : ChartItem
      {
         if(param1 == ChartBase.HORIZONTAL)
         {
            return getPreviousSeriesItem(this._allSeries);
         }
         if(param1 == ChartBase.VERTICAL)
         {
            return getPreviousSeries(this._allSeries);
         }
         return null;
      }
      
      override mx_internal function getSeriesTransformState(param1:Object) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param1 is StackedSeries)
         {
            _loc3_ = (param1 as StackedSeries).series.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc2_ = this.getSeriesTransformState((param1 as StackedSeries).series[_loc4_]);
               if(_loc2_)
               {
                  return true;
               }
               _loc4_++;
            }
            return false;
         }
         return param1.getTransformState();
      }
      
      override mx_internal function updateKeyboardCache() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc1_:int = _transforms.length;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc4_ = _transforms[_loc2_].elements.length;
            _loc3_ = 0;
            while(_loc3_ < _loc4_)
            {
               if(_transforms[_loc2_].elements[_loc3_] is Series && this.getSeriesTransformState(_transforms[_loc2_].elements[_loc3_]) == true)
               {
                  return;
               }
               _loc3_++;
            }
            _loc2_++;
         }
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc9_:Boolean = false;
         var _loc10_:int = 0;
         _loc1_ = this._allSeries.length;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if((_loc7_ = this._allSeries[_loc2_].items) && this._allSeries[_loc2_].selectedItems.length > 0)
            {
               _loc9_ = true;
               _loc4_ = _loc7_.length;
               _loc3_ = 0;
               while(_loc3_ < _loc4_)
               {
                  _loc5_.push(_loc7_[_loc3_].item);
                  _loc3_++;
               }
               _loc10_ += this._allSeries[_loc2_].selectedItems.length;
               _loc4_ = this._allSeries[_loc2_].selectedItems.length;
               _loc3_ = 0;
               while(_loc3_ < _loc4_)
               {
                  if((_loc8_ = _loc5_.indexOf(this._allSeries[_loc2_].selectedItems[_loc3_].item)) != -1)
                  {
                     _loc6_.push(this._allSeries[_loc2_].items[_loc8_]);
                  }
                  _loc3_++;
               }
               _loc5_ = [];
               this._allSeries[_loc2_].emptySelectedItems();
            }
            _loc2_++;
         }
         if(_loc9_)
         {
            selectSpecificChartItems(_loc6_);
            if(_loc10_ != _loc6_.length)
            {
               dispatchEvent(new ChartItemEvent(ChartItemEvent.CHANGE,null,null,this));
            }
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(selectionMode == "none")
         {
            return;
         }
         var _loc2_:ChartItem = null;
         var _loc3_:Boolean = false;
         switch(param1.keyCode)
         {
            case Keyboard.UP:
               _loc2_ = this.getNextItem(ChartBase.VERTICAL);
               break;
            case Keyboard.DOWN:
               _loc2_ = this.getPreviousItem(ChartBase.VERTICAL);
               break;
            case Keyboard.LEFT:
               _loc2_ = this.getPreviousItem(ChartBase.HORIZONTAL);
               break;
            case Keyboard.RIGHT:
               _loc2_ = this.getNextItem(ChartBase.HORIZONTAL);
               break;
            case Keyboard.END:
            case Keyboard.PAGE_DOWN:
               _loc2_ = this.getLastItem(ChartBase.HORIZONTAL);
               break;
            case Keyboard.HOME:
            case Keyboard.PAGE_UP:
               _loc2_ = this.getFirstItem(ChartBase.HORIZONTAL);
               break;
            case Keyboard.SPACE:
               handleSpace(param1);
               param1.stopPropagation();
               return;
         }
         if(_loc2_)
         {
            param1.stopImmediatePropagation();
            handleNavigation(_loc2_,param1);
         }
      }
      
      override protected function measure() : void
      {
         super.measure();
         if(this._horizontalAxisRenderer)
         {
            measuredMinHeight = this._horizontalAxisRenderer.minHeight + 40;
         }
         if(this._verticalAxisRenderer)
         {
            measuredMinWidth = this._verticalAxisRenderer.minWidth + 40;
         }
         var _loc1_:int = this._horizontalAxisRenderers.length;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            measuredMinHeight += this._horizontalAxisRenderers[_loc2_].minHeight + 40;
            _loc2_++;
         }
         _loc1_ = this._verticalAxisRenderers.length;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            measuredMinWidth += this._verticalAxisRenderers[_loc2_].minWidth + 40;
            _loc2_++;
         }
      }
      
      protected function updateAxisLayout(param1:Number, param2:Number) : void
      {
         var _loc21_:Array = null;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Array = null;
         var _loc29_:Rectangle = null;
         var _loc30_:DisplayObject = null;
         var _loc3_:Number = getStyle("paddingLeft");
         var _loc4_:Number = getStyle("paddingRight");
         var _loc5_:Number = getStyle("paddingTop");
         var _loc6_:Number = getStyle("paddingBottom");
         var _loc7_:Object = getStyle("gutterLeft");
         var _loc8_:Object = getStyle("gutterRight");
         var _loc9_:Object = getStyle("gutterTop");
         var _loc10_:Object = getStyle("gutterBottom");
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:uint = this._horizontalAxisRenderers.length;
         var _loc14_:uint = this._verticalAxisRenderers.length;
         var _loc15_:uint = this._leftRenderers.length;
         var _loc16_:uint = this._rightRenderers.length;
         var _loc17_:uint = this._bottomRenderers.length;
         var _loc18_:uint = this._topRenderers.length;
         var _loc19_:Object = {};
         var _loc20_:Object = {
            "left":0,
            "top":0,
            "right":0,
            "bottom":0
         };
         if(!isNaN(this.horizontalAxisRatio))
         {
            if(this._horizontalAxisRenderer)
            {
               this._horizontalAxisRenderer.heightLimit = this.horizontalAxisRatio * param2;
            }
            _loc11_ = 0;
            while(_loc11_ < _loc13_)
            {
               this._horizontalAxisRenderers[_loc11_].heightLimit = this.horizontalAxisRatio * param2;
               _loc11_++;
            }
         }
         if(!isNaN(this.verticalAxisRatio))
         {
            if(this._verticalAxisRenderer)
            {
               this._verticalAxisRenderer.heightLimit = this.verticalAxisRatio * param1;
            }
            _loc11_ = 0;
            while(_loc11_ < _loc14_)
            {
               this._verticalAxisRenderers[_loc11_].heightLimit = this.verticalAxisRatio * param1;
               _loc11_++;
            }
         }
         if(this._horizontalAxisRenderer)
         {
            this._horizontalAxisRenderer.setActualSize(param1 - _loc3_ - _loc4_,param2 - _loc5_ - _loc6_);
            this._horizontalAxisRenderer.move(_loc3_,_loc5_);
         }
         _loc11_ = 0;
         while(_loc11_ < _loc13_)
         {
            this._horizontalAxisRenderers[_loc11_].setActualSize(param1 - _loc3_ - _loc4_,param2 - _loc5_ - _loc6_);
            this._horizontalAxisRenderers[_loc11_].move(_loc3_,_loc5_);
            _loc11_++;
         }
         if(this._verticalAxisRenderer)
         {
            this._verticalAxisRenderer.setActualSize(param1 - _loc3_ - _loc4_,param2 - _loc5_ - _loc6_);
            this._verticalAxisRenderer.move(_loc3_,_loc5_);
         }
         _loc11_ = 0;
         while(_loc11_ < _loc14_)
         {
            this._verticalAxisRenderers[_loc11_].setActualSize(param1 - _loc3_ - _loc4_,param2 - _loc5_ - _loc6_);
            this._verticalAxisRenderers[_loc11_].move(_loc3_,_loc5_);
            _loc11_++;
         }
         if(_loc14_ == 0 && _loc13_ == 0)
         {
            if(this._horizontalAxisRenderer.placement == "")
            {
               this._horizontalAxisRenderer.placement = "bottom";
            }
            if(this._verticalAxisRenderer.placement == "")
            {
               this._verticalAxisRenderer.placement = "left";
            }
            this._computedGutters = new Rectangle();
            if(_loc7_ != null)
            {
               this._computedGutters.left = Number(_loc7_);
               _loc19_.left = false;
            }
            if(_loc8_ != null)
            {
               this._computedGutters.right = Number(_loc8_);
               _loc19_.right = false;
            }
            if(_loc9_ != null)
            {
               this._computedGutters.top = Number(_loc9_);
               _loc19_.top = false;
            }
            if(_loc10_ != null)
            {
               this._computedGutters.bottom = Number(_loc10_);
               _loc19_.bottom = false;
            }
            (_loc21_ = []).push(this._verticalAxisRenderer);
            this._horizontalAxisRenderer.otherAxes = _loc21_;
            this._computedGutters = this._verticalAxisRenderer.adjustGutters(this._computedGutters,_loc19_);
            this._computedGutters = this._horizontalAxisRenderer.adjustGutters(this._computedGutters,_loc19_);
            this._verticalAxisRenderer.gutters = this._computedGutters;
         }
         else
         {
            this._computedGutters = new Rectangle();
            if(_loc7_ != null)
            {
               _loc20_.left = Number(_loc7_) / _loc15_;
               _loc19_.left = false;
            }
            if(_loc8_ != null)
            {
               _loc20_.right = Number(_loc8_) / _loc16_;
               _loc19_.right = false;
            }
            if(_loc9_ != null)
            {
               _loc20_.top = Number(_loc9_) / _loc18_;
               _loc19_.top = false;
            }
            if(_loc10_ != null)
            {
               _loc20_.bottom = Number(_loc10_) / _loc17_;
               _loc19_.bottom = false;
            }
            _loc22_ = 0;
            _loc23_ = 0;
            _loc24_ = 0;
            _loc25_ = 0;
            _loc26_ = 0;
            _loc27_ = 0;
            _loc11_ = 0;
            while(_loc11_ < _loc15_)
            {
               if(_loc20_.left == 0)
               {
                  this._computedGutters.left = 0;
               }
               else
               {
                  this._computedGutters.left = _loc20_.left * (_loc11_ + 1);
               }
               this._computedGutters = this._leftRenderers[_loc11_].adjustGutters(this._computedGutters,_loc19_);
               if((_loc29_ = this._computedGutters.clone()).top > _loc26_)
               {
                  _loc26_ = _loc29_.top;
               }
               if(_loc29_.bottom > _loc27_)
               {
                  _loc27_ = _loc29_.bottom;
               }
               if(_loc20_.left == 0)
               {
                  _loc29_.left += _loc22_;
               }
               if(_loc29_.left > param1)
               {
                  _loc29_.left = param1;
               }
               this._leftRenderers[_loc11_].gutters = _loc29_;
               if(_loc20_.left == 0)
               {
                  _loc22_ += this._computedGutters.left;
               }
               _loc11_++;
            }
            if(_loc22_ > param1)
            {
               _loc22_ = param1;
            }
            if(_loc20_.left == 0)
            {
               this._computedGutters.left = _loc22_;
            }
            else
            {
               this._computedGutters.left = Number(_loc7_);
            }
            _loc11_ = 0;
            while(_loc11_ < _loc16_)
            {
               if(_loc20_.right == 0)
               {
                  this._computedGutters.right = 0;
               }
               else
               {
                  this._computedGutters.right = _loc20_.right * (_loc11_ + 1);
               }
               this._computedGutters = this._rightRenderers[_loc11_].adjustGutters(this._computedGutters,_loc19_);
               if((_loc29_ = this._computedGutters.clone()).top > _loc26_)
               {
                  _loc26_ = _loc29_.top;
               }
               if(_loc29_.bottom > _loc27_)
               {
                  _loc27_ = _loc29_.bottom;
               }
               if(_loc20_.right == 0)
               {
                  _loc29_.right += _loc23_;
               }
               if(_loc29_.right > param1)
               {
                  _loc29_.right = param1;
               }
               this._rightRenderers[_loc11_].gutters = _loc29_;
               if(_loc20_.right == 0)
               {
                  _loc23_ += this._computedGutters.right;
               }
               _loc11_++;
            }
            if(_loc23_ > param1)
            {
               _loc23_ = param1;
            }
            if(_loc20_.right == 0)
            {
               this._computedGutters.right = _loc23_;
            }
            else
            {
               this._computedGutters.right = Number(_loc8_);
            }
            _loc28_ = [];
            if(_loc15_ > 0)
            {
               _loc28_.push(this._leftRenderers[_loc15_ - 1]);
            }
            if(_loc16_ > 0)
            {
               _loc28_.push(this._rightRenderers[_loc16_ - 1]);
            }
            _loc11_ = 0;
            while(_loc11_ < _loc17_)
            {
               if(_loc20_.bottom == 0)
               {
                  this._computedGutters.bottom = 0;
               }
               else
               {
                  this._computedGutters.bottom = _loc20_.bottom * (_loc11_ + 1);
               }
               this._bottomRenderers[_loc11_].otherAxes = _loc28_;
               this._computedGutters = this._bottomRenderers[_loc11_].adjustGutters(this._computedGutters,_loc19_);
               _loc29_ = this._computedGutters.clone();
               if(_loc20_.bottom == 0)
               {
                  _loc29_.bottom += _loc24_;
               }
               if(_loc29_.bottom > param2)
               {
                  _loc29_.bottom = param2;
               }
               this._bottomRenderers[_loc11_].gutters = _loc29_;
               if(_loc20_.bottom == 0)
               {
                  _loc24_ += this._computedGutters.bottom;
               }
               _loc11_++;
            }
            if(_loc24_ > param2)
            {
               _loc24_ = param2;
            }
            _loc11_ = 0;
            while(_loc11_ < _loc18_)
            {
               if(_loc20_.top == 0)
               {
                  this._computedGutters.top = 0;
               }
               else
               {
                  this._computedGutters.top = _loc20_.top * (_loc11_ + 1);
               }
               this._topRenderers[_loc11_].otherAxes = _loc28_;
               this._computedGutters = this._topRenderers[_loc11_].adjustGutters(this._computedGutters,_loc19_);
               _loc29_ = this._computedGutters.clone();
               if(_loc20_.top == 0)
               {
                  _loc29_.top += _loc25_;
               }
               if(_loc29_.top > param2)
               {
                  _loc29_.top = param2;
               }
               this._topRenderers[_loc11_].gutters = _loc29_;
               if(_loc20_.top == 0)
               {
                  _loc25_ += this._computedGutters.top;
               }
               _loc11_++;
            }
            if(_loc25_ > param2)
            {
               _loc25_ = param2;
            }
            if(_loc20_.bottom == 0)
            {
               this._computedGutters.bottom = _loc24_;
            }
            else
            {
               this._computedGutters.bottom = Number(_loc10_);
            }
            if(_loc20_.top == 0)
            {
               this._computedGutters.top = _loc25_;
            }
            else
            {
               this._computedGutters.top = Number(_loc9_);
            }
            if(_loc18_ == 0)
            {
               this._computedGutters.top += _loc26_;
            }
            if(_loc17_ == 0)
            {
               this._computedGutters.bottom += _loc27_;
            }
            _loc11_ = 0;
            while(_loc11_ < _loc15_)
            {
               (_loc29_ = this._leftRenderers[_loc11_].gutters).top = this._computedGutters.top;
               _loc29_.bottom = this._computedGutters.bottom;
               this._leftRenderers[_loc11_].gutters = _loc29_;
               _loc11_++;
            }
            _loc11_ = 0;
            while(_loc11_ < _loc16_)
            {
               (_loc29_ = this._rightRenderers[_loc11_].gutters).top = this._computedGutters.top;
               _loc29_.bottom = this._computedGutters.bottom;
               this._rightRenderers[_loc11_].gutters = _loc29_;
               _loc11_++;
            }
         }
         this._transformBounds = new Rectangle(this._computedGutters.left + _loc3_,this._computedGutters.top + _loc5_,param1 - this._computedGutters.right - _loc4_ - (this._computedGutters.left + _loc3_),param2 - this._computedGutters.bottom - _loc6_ - (this._computedGutters.top + _loc5_));
         if(_transforms)
         {
            _loc12_ = _transforms.length;
            _loc11_ = 0;
            while(_loc11_ < _loc12_)
            {
               _transforms[_loc11_].pixelWidth = this._transformBounds.width;
               _transforms[_loc11_].pixelHeight = this._transformBounds.height;
               _loc11_++;
            }
         }
         _loc12_ = allElements.length;
         _loc11_ = 0;
         while(_loc11_ < _loc12_)
         {
            if((_loc30_ = allElements[_loc11_]) is IUIComponent)
            {
               (_loc30_ as IUIComponent).setActualSize(this._transformBounds.width,this._transformBounds.height);
            }
            else
            {
               _loc30_.width = this._transformBounds.width;
               _loc30_.height = this._transformBounds.height;
            }
            if(_loc30_ is Series && Series(_loc30_).dataTransform)
            {
               CartesianTransform(Series(_loc30_).dataTransform).pixelWidth = this._transformBounds.width;
               CartesianTransform(Series(_loc30_).dataTransform).pixelHeight = this._transformBounds.height;
            }
            if(_loc30_ is IDataCanvas && (_loc30_ as Object).dataTransform)
            {
               CartesianTransform((_loc30_ as Object).dataTransform).pixelWidth = this._transformBounds.width;
               CartesianTransform((_loc30_ as Object).dataTransform).pixelHeight = this._transformBounds.height;
            }
            _loc11_++;
         }
         if(_seriesHolder.mask)
         {
            _seriesHolder.mask.width = this._transformBounds.width;
            _seriesHolder.mask.height = this._transformBounds.height;
         }
         if(_backgroundElementHolder.mask)
         {
            _backgroundElementHolder.mask.width = this._transformBounds.width;
            _backgroundElementHolder.mask.height = this._transformBounds.height;
         }
         if(_annotationElementHolder.mask)
         {
            _annotationElementHolder.mask.width = this._transformBounds.width;
            _annotationElementHolder.mask.height = this._transformBounds.height;
         }
         _seriesHolder.x = this._transformBounds.left;
         _seriesHolder.y = this._transformBounds.top;
         _backgroundElementHolder.move(this._transformBounds.left,this._transformBounds.top);
         _annotationElementHolder.move(this._transformBounds.left,this._transformBounds.top);
         this._bAxisLayoutDirty = false;
      }
      
      private function findSeriesObjects(param1:Array) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(param1[_loc4_] is StackedSeries)
            {
               _loc2_ = _loc2_.concat(this.findSeriesObjects(param1[_loc4_].series));
            }
            else
            {
               _loc2_.push(param1[_loc4_]);
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      mx_internal function adjustAxesPlacements() : void
      {
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         var _loc1_:Array = [];
         var _loc2_:Array = [];
         this._leftRenderers = [];
         this._rightRenderers = [];
         this._bottomRenderers = [];
         this._topRenderers = [];
         var _loc3_:uint = this._horizontalAxisRenderers.length;
         var _loc4_:uint = this._verticalAxisRenderers.length;
         var _loc11_:int = 0;
         while(_loc11_ < _loc3_)
         {
            if(this._horizontalAxisRenderers[_loc11_].placement == "bottom")
            {
               this._bottomRenderers.push(this._horizontalAxisRenderers[_loc11_]);
            }
            else if(this._horizontalAxisRenderers[_loc11_].placement == "top")
            {
               this._topRenderers.push(this._horizontalAxisRenderers[_loc11_]);
            }
            else
            {
               _loc1_.push(this._horizontalAxisRenderers[_loc11_]);
            }
            _loc11_++;
         }
         _loc11_ = 0;
         while(_loc11_ < _loc4_)
         {
            if(this._verticalAxisRenderers[_loc11_].placement == "left")
            {
               this._leftRenderers.push(this._verticalAxisRenderers[_loc11_]);
            }
            else if(this._verticalAxisRenderers[_loc11_].placement == "right")
            {
               this._rightRenderers.push(this._verticalAxisRenderers[_loc11_]);
            }
            else
            {
               _loc2_.push(this._verticalAxisRenderers[_loc11_]);
            }
            _loc11_++;
         }
         if(this._horizontalAxisRenderer)
         {
            if(this._horizontalAxisRenderer.placement == "bottom")
            {
               this._bottomRenderers.push(this._horizontalAxisRenderer);
            }
            else if(this._horizontalAxisRenderer.placement == "top")
            {
               this._topRenderers.push(this._horizontalAxisRenderer);
            }
            else
            {
               _loc1_.push(this._horizontalAxisRenderer);
            }
         }
         if(this._verticalAxisRenderer)
         {
            if(this._verticalAxisRenderer.placement == "left")
            {
               this._leftRenderers.push(this._verticalAxisRenderer);
            }
            else if(this._verticalAxisRenderer.placement == "right")
            {
               this._rightRenderers.push(this._verticalAxisRenderer);
            }
            else
            {
               _loc2_.push(this._verticalAxisRenderer);
            }
         }
         _loc5_ = this._leftRenderers.length;
         _loc6_ = this._rightRenderers.length;
         _loc7_ = this._topRenderers.length;
         _loc8_ = this._bottomRenderers.length;
         _loc9_ = _loc1_.length;
         _loc10_ = _loc2_.length;
         var _loc12_:uint = 0;
         if(_loc5_ > _loc6_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc5_ - _loc6_ && _loc12_ < _loc10_)
            {
               this._rightRenderers.push(_loc2_[_loc12_]);
               _loc2_[_loc12_].placement = "right";
               _loc12_++;
            }
         }
         else if(_loc5_ < _loc6_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc6_ - _loc5_ && _loc12_ < _loc10_)
            {
               this._leftRenderers.push(_loc2_[_loc12_]);
               _loc2_[_loc12_].placement = "left";
               _loc12_++;
            }
         }
         _loc11_ = _loc12_;
         while(_loc11_ < _loc10_)
         {
            if(_loc11_ % 2 == 0)
            {
               this._leftRenderers.push(_loc2_[_loc11_]);
               _loc2_[_loc11_].placement = "left";
            }
            else
            {
               this._rightRenderers.push(_loc2_[_loc11_]);
               _loc2_[_loc11_].placement = "right";
            }
            _loc11_++;
         }
         if(_loc8_ > _loc7_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc8_ - _loc7_ && _loc12_ < _loc9_)
            {
               this._topRenderers.push(_loc1_[_loc12_]);
               _loc1_[_loc12_].placement = "top";
               _loc12_++;
            }
         }
         else if(_loc7_ < _loc8_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc7_ - _loc8_ && _loc12_ < _loc9_)
            {
               this._bottomRenderers.push(_loc1_[_loc12_]);
               _loc1_[_loc12_].placement = "bottom";
               _loc12_++;
            }
         }
         _loc11_ = _loc12_;
         while(_loc11_ < _loc9_)
         {
            if(_loc11_ % 2 == 0)
            {
               this._bottomRenderers.push(_loc1_[_loc11_]);
               _loc1_[_loc11_].placement = "bottom";
            }
            else
            {
               this._topRenderers.push(_loc1_[_loc11_]);
               _loc1_[_loc11_].placement = "top";
            }
            _loc11_++;
         }
      }
      
      private function updateMultipleAxesStyles() : void
      {
         var _loc1_:Array = getStyle("horizontalAxisStyleNames");
         var _loc2_:Array = getStyle("verticalAxisStyleNames");
         var _loc3_:uint = this._horizontalAxisRenderers.length;
         var _loc4_:uint = _loc1_.length;
         var _loc5_:uint = _loc2_.length;
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_)
         {
            if(this._horizontalAxisRenderers[_loc6_] is DualStyleObject)
            {
               DualStyleObject(this._horizontalAxisRenderers[_loc6_]).internalStyleName = _loc1_[_loc6_ % _loc4_];
            }
            _loc6_++;
         }
         _loc3_ = this._verticalAxisRenderers.length;
         _loc6_ = 0;
         while(_loc6_ < _loc3_)
         {
            if(this._verticalAxisRenderers[_loc6_] is DualStyleObject)
            {
               DualStyleObject(this._verticalAxisRenderers[_loc6_]).internalStyleName = _loc2_[_loc6_ % _loc5_];
            }
            _loc6_++;
         }
      }
      
      private function updateMultipleAxesRenderers() : void
      {
         var _loc1_:uint = this._horizontalAxisRenderers.length;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            addChild(DisplayObject(this._horizontalAxisRenderers[_loc2_]));
            _loc2_++;
         }
         _loc1_ = this._verticalAxisRenderers.length;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            addChild(DisplayObject(this._verticalAxisRenderers[_loc2_]));
            _loc2_++;
         }
         this.adjustAxesPlacements();
         invalidateDisplayList();
      }
      
      private function axisPlacementChangeHandler(param1:Event) : void
      {
         this.adjustAxesPlacements();
         invalidateDisplayList();
      }
      
      mx_internal function measureLabels() : Object
      {
         return null;
      }
      
      mx_internal function getLeftMostRenderer() : IAxisRenderer
      {
         var _loc1_:int = this._leftRenderers.length;
         if(_loc1_ > 0)
         {
            return this._leftRenderers[_loc1_ - 1];
         }
         return null;
      }
      
      mx_internal function getRightMostRenderer() : IAxisRenderer
      {
         var _loc1_:int = this._rightRenderers.length;
         if(_loc1_ > 0)
         {
            return this._rightRenderers[_loc1_ - 1];
         }
         return null;
      }
      
      mx_internal function getTopMostRenderer() : IAxisRenderer
      {
         var _loc1_:int = this._topRenderers.length;
         if(_loc1_ > 0)
         {
            return this._topRenderers[_loc1_ - 1];
         }
         return null;
      }
      
      mx_internal function getBottomMostRenderer() : IAxisRenderer
      {
         var _loc1_:int = this._bottomRenderers.length;
         if(_loc1_ > 0)
         {
            return this._bottomRenderers[_loc1_ - 1];
         }
         return null;
      }
   }
}
