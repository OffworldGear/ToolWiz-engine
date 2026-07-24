package mx.charts.series
{
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import mx.charts.DateTimeAxis;
   import mx.charts.HitData;
   import mx.charts.chartClasses.BoundedValue;
   import mx.charts.chartClasses.CartesianChart;
   import mx.charts.chartClasses.CartesianTransform;
   import mx.charts.chartClasses.DataDescription;
   import mx.charts.chartClasses.GraphicsUtilities;
   import mx.charts.chartClasses.IAxis;
   import mx.charts.chartClasses.InstanceCache;
   import mx.charts.chartClasses.LegendData;
   import mx.charts.chartClasses.NumericAxis;
   import mx.charts.chartClasses.Series;
   import mx.charts.renderers.LineRenderer;
   import mx.charts.series.items.LineSeriesItem;
   import mx.charts.series.items.LineSeriesSegment;
   import mx.charts.series.renderData.LineSeriesRenderData;
   import mx.charts.styles.HaloDefaults;
   import mx.collections.CursorBookmark;
   import mx.core.ClassFactory;
   import mx.core.IDataRenderer;
   import mx.core.IFactory;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.IFill;
   import mx.graphics.IStroke;
   import mx.graphics.LinearGradientStroke;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import mx.styles.CSSStyleDeclaration;
   import mx.styles.ISimpleStyleClient;
   
   use namespace mx_internal;
   
   public class LineSeries extends Series
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _moduleFactoryInitialized:Boolean = false;
      
      private var _pointInstanceCache:InstanceCache;
      
      private var _renderData:LineSeriesRenderData;
      
      private var _segmentInstanceCache:InstanceCache;
      
      private var _localFills:Array;
      
      private var _fillCount:int;
      
      private var _bAxesDirty:Boolean = false;
      
      private var _1757871014_fillFunction:Function;
      
      private var _horizontalAxis:IAxis;
      
      private var _interpolateValues:Boolean = false;
      
      private var _sortOnXField:Boolean = true;
      
      private var _verticalAxis:IAxis;
      
      private var _xField:String = "";
      
      private var _yField:String = "";
      
      public function LineSeries()
      {
         this._1757871014_fillFunction = this.defaultFillFunction;
         super();
         this._pointInstanceCache = new InstanceCache(null,this,1000);
         this._pointInstanceCache.creationCallback = this.applyItemRendererProperties;
         this._segmentInstanceCache = new InstanceCache(null,this,0);
         this._segmentInstanceCache.properties = {"styleName":this};
         dataTransform = new CartesianTransform();
      }
      
      override public function get legendData() : Array
      {
         var _loc3_:Number = NaN;
         var _loc5_:IFlexDisplayObject = null;
         var _loc8_:Array = null;
         if(this.fillFunction != this.defaultFillFunction || this._fillCount != 0)
         {
            return [];
         }
         var _loc1_:Number = getStyle("radius");
         var _loc2_:IFactory = getStyle("itemRenderer");
         var _loc4_:int = 0;
         var _loc6_:LegendData;
         (_loc6_ = new LegendData()).element = this;
         _loc6_.label = displayName;
         var _loc7_:IFactory;
         if(_loc7_ = getStyle("legendMarkerRenderer"))
         {
            if((_loc5_ = _loc7_.newInstance()) is ISimpleStyleClient)
            {
               (_loc5_ as ISimpleStyleClient).styleName = this;
            }
            _loc6_.aspectRatio = 1;
         }
         else if(!_loc2_ || _loc1_ == 0 || isNaN(_loc1_))
         {
            _loc5_ = new LineSeriesLegendMarker(this);
         }
         else
         {
            _loc5_ = (_loc7_ = getStyle("itemRenderer")).newInstance();
            _loc6_.aspectRatio = 1;
            if(_loc5_ as ISimpleStyleClient)
            {
               (_loc5_ as ISimpleStyleClient).styleName = this;
            }
         }
         _loc6_.marker = _loc5_;
         return [_loc6_];
      }
      
      override protected function get renderData() : Object
      {
         var _loc1_:Class = null;
         var _loc2_:LineSeriesRenderData = null;
         if(!this._renderData || !this._renderData.cache || this._renderData.cache.length == 0)
         {
            _loc1_ = this.renderDataType;
            _loc2_ = new _loc1_();
            _loc2_.cache = _loc2_.filteredCache = [];
            _loc2_.segments = [];
            _loc2_.radius = 0;
            return _loc2_;
         }
         this._renderData.radius = getStyle("radius");
         return this._renderData;
      }
      
      public function get fillFunction() : Function
      {
         return this._fillFunction;
      }
      
      public function set fillFunction(param1:Function) : void
      {
         if(param1 == this._fillFunction)
         {
            return;
         }
         if(param1 != null)
         {
            this._fillFunction = param1;
         }
         else
         {
            this._fillFunction = this.defaultFillFunction;
         }
         invalidateDisplayList();
         legendDataChanged();
      }
      
      public function get horizontalAxis() : IAxis
      {
         return this._horizontalAxis;
      }
      
      public function set horizontalAxis(param1:IAxis) : void
      {
         this._horizontalAxis = param1;
         this._bAxesDirty = true;
         invalidateData();
         invalidateProperties();
      }
      
      public function get interpolateValues() : Boolean
      {
         return this._interpolateValues;
      }
      
      public function set interpolateValues(param1:Boolean) : void
      {
         if(this._interpolateValues != param1)
         {
            this._interpolateValues = param1;
            invalidateData();
         }
      }
      
      override public function get items() : Array
      {
         return !!this._renderData ? this._renderData.filteredCache : null;
      }
      
      protected function get itemType() : Class
      {
         return LineSeriesItem;
      }
      
      protected function get lineSegmentType() : Class
      {
         return LineSeriesSegment;
      }
      
      public function get radius() : Number
      {
         return getStyle("radius");
      }
      
      public function set radius(param1:Number) : void
      {
         setStyle("radius",param1);
      }
      
      protected function get renderDataType() : Class
      {
         return LineSeriesRenderData;
      }
      
      public function get sortOnXField() : Boolean
      {
         return this._sortOnXField;
      }
      
      public function set sortOnXField(param1:Boolean) : void
      {
         if(this._sortOnXField == param1)
         {
            return;
         }
         this._sortOnXField = param1;
         invalidateMapping();
      }
      
      public function get verticalAxis() : IAxis
      {
         return this._verticalAxis;
      }
      
      public function set verticalAxis(param1:IAxis) : void
      {
         this._verticalAxis = param1;
         this._bAxesDirty = true;
         invalidateData();
         invalidateProperties();
      }
      
      public function get xField() : String
      {
         return this._xField;
      }
      
      public function set xField(param1:String) : void
      {
         this._xField = param1;
         dataChanged();
      }
      
      public function get yField() : String
      {
         return this._yField;
      }
      
      public function set yField(param1:String) : void
      {
         this._yField = param1;
         dataChanged();
      }
      
      private function initStyles() : Boolean
      {
         HaloDefaults.init(styleManager);
         var _loc1_:CSSStyleDeclaration = styleManager.getStyleDeclaration("mx.charts.series.LineSeries");
         _loc1_.setStyle("lineSegmentRenderer",new ClassFactory(LineRenderer));
         _loc1_.setStyle("fill",new SolidColor(16777215));
         _loc1_.setStyle("fills",[]);
         _loc1_.setStyle("lineStroke",new SolidColorStroke(0,3));
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
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(dataTransform)
         {
            if(this._horizontalAxis)
            {
               this._horizontalAxis.chartDataProvider = dataProvider;
               CartesianTransform(dataTransform).setAxis(CartesianTransform.HORIZONTAL_AXIS,this._horizontalAxis);
            }
            if(this._verticalAxis)
            {
               this._verticalAxis.chartDataProvider = dataProvider;
               CartesianTransform(dataTransform).setAxis(CartesianTransform.VERTICAL_AXIS,this._verticalAxis);
            }
         }
         var _loc1_:CartesianChart = CartesianChart(chart);
         if(_loc1_)
         {
            if(!this._horizontalAxis)
            {
               if(dataTransform.axes[CartesianTransform.HORIZONTAL_AXIS] != _loc1_.horizontalAxis)
               {
                  CartesianTransform(dataTransform).setAxis(CartesianTransform.HORIZONTAL_AXIS,_loc1_.horizontalAxis);
               }
            }
            if(!this._verticalAxis)
            {
               if(dataTransform.axes[CartesianTransform.VERTICAL_AXIS] != _loc1_.verticalAxis)
               {
                  CartesianTransform(dataTransform).setAxis(CartesianTransform.VERTICAL_AXIS,_loc1_.verticalAxis);
               }
            }
         }
         dataTransform.elements = [this];
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc7_:int = 0;
         var _loc9_:Array = null;
         var _loc11_:LineSeriesItem = null;
         var _loc12_:Array = null;
         var _loc13_:Object = null;
         var _loc14_:LineSeriesItem = null;
         var _loc15_:IFlexDisplayObject = null;
         var _loc16_:int = 0;
         var _loc17_:Boolean = false;
         var _loc18_:Rectangle = null;
         var _loc19_:IFlexDisplayObject = null;
         var _loc20_:Object = null;
         super.updateDisplayList(param1,param2);
         var _loc3_:LineSeriesRenderData = !!transitionRenderData ? LineSeriesRenderData(transitionRenderData) : this._renderData;
         if(!_loc3_ || !_loc3_.filteredCache)
         {
            return;
         }
         var _loc4_:Graphics;
         (_loc4_ = graphics).clear();
         var _loc5_:Number = getStyle("radius");
         var _loc6_:int = _loc3_.filteredCache.length;
         var _loc8_:int = _loc3_.segments.length;
         if(_loc3_ == transitionRenderData && _loc3_.elementBounds)
         {
            _loc6_ = (_loc12_ = _loc3_.elementBounds).length;
            _loc9_ = _loc3_.filteredCache;
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc13_ = _loc12_[_loc7_];
               (_loc14_ = _loc9_[_loc7_]).x = (_loc13_.left + _loc13_.right) / 2;
               _loc14_.y = (_loc13_.bottom + _loc13_.top) / 2;
               _loc7_++;
            }
         }
         else
         {
            _loc9_ = _loc3_.filteredCache;
         }
         this._segmentInstanceCache.factory = getStyle("lineSegmentRenderer");
         this._segmentInstanceCache.count = _loc8_;
         var _loc10_:Array = this._segmentInstanceCache.instances;
         _loc7_ = 0;
         while(_loc7_ < _loc8_)
         {
            if((_loc15_ = _loc10_[_loc7_]) is IDataRenderer)
            {
               IDataRenderer(_loc15_).data = _loc3_.segments[_loc7_];
            }
            _loc15_.setActualSize(param1,param2);
            _loc7_++;
         }
         if(_loc5_ > 0)
         {
            this._pointInstanceCache.factory = getStyle("itemRenderer");
            this._pointInstanceCache.count = _loc3_.validPoints;
            _loc10_ = this._pointInstanceCache.instances;
            _loc16_ = 0;
            _loc17_ = _loc6_ > 0 && _loc10_[0] is IDataRenderer;
            if(_loc3_ == transitionRenderData && _loc3_.elementBounds)
            {
               _loc7_ = 0;
               while(_loc7_ < _loc6_)
               {
                  _loc11_ = _loc9_[_loc7_];
                  _loc19_ = _loc10_[_loc16_++];
                  _loc11_.itemRenderer = _loc19_;
                  _loc11_.fill = this.fillFunction(_loc11_,_loc7_);
                  if(!_loc11_.fill)
                  {
                     _loc11_.fill = this.defaultFillFunction(_loc11_,_loc7_);
                  }
                  if(_loc11_.itemRenderer && (_loc11_.itemRenderer as Object).hasOwnProperty("invalidateDisplayList"))
                  {
                     (_loc11_.itemRenderer as Object).invalidateDisplayList();
                  }
                  if(_loc19_)
                  {
                     if(_loc17_)
                     {
                        IDataRenderer(_loc19_).data = _loc11_;
                     }
                     _loc18_ = _loc12_[_loc7_];
                     _loc19_.move(_loc18_.left,_loc18_.top);
                     _loc19_.setActualSize(_loc18_.width,_loc18_.height);
                  }
                  _loc7_++;
               }
            }
            else
            {
               _loc7_ = 0;
               while(_loc7_ < _loc6_)
               {
                  _loc11_ = _loc9_[_loc7_];
                  _loc20_ = _loc3_.filteredCache[_loc7_];
                  if(!(filterFunction == this.defaultFilterFunction && (filterDataValues == "outsideRange" && (isNaN(_loc20_.xFilter) || isNaN(_loc20_.yFilter)) || filterDataValues == "nulls" && (isNaN(_loc20_.xNumber) || isNaN(_loc20_.yNumber)))))
                  {
                     _loc19_ = _loc10_[_loc16_++];
                     _loc11_.itemRenderer = _loc19_;
                     _loc11_.fill = this.fillFunction(_loc11_,_loc7_);
                     if(!_loc11_.fill)
                     {
                        _loc11_.fill = this.defaultFillFunction(_loc11_,_loc7_);
                     }
                     if(_loc11_.itemRenderer && (_loc11_.itemRenderer as Object).hasOwnProperty("invalidateDisplayList"))
                     {
                        (_loc11_.itemRenderer as Object).invalidateDisplayList();
                     }
                     if(_loc19_)
                     {
                        if(_loc17_)
                        {
                           IDataRenderer(_loc19_).data = _loc11_;
                        }
                        _loc19_.move(_loc11_.x - _loc5_,_loc11_.y - _loc5_);
                        _loc19_.setActualSize(2 * _loc5_,2 * _loc5_);
                     }
                  }
                  _loc7_++;
               }
               if(chart && allSeriesTransform && chart.chartState == 0)
               {
                  chart.updateAllDataTips();
               }
            }
         }
      }
      
      override public function stylesInitialized() : void
      {
         this._localFills = getStyle("fills");
         if(this._localFills != null)
         {
            this._fillCount = this._localFills.length;
         }
         else
         {
            this._fillCount = 0;
         }
         super.stylesInitialized();
      }
      
      override public function styleChanged(param1:String) : void
      {
         super.styleChanged(param1);
         var _loc2_:String = "fills";
         if(_loc2_.indexOf(param1) != -1)
         {
            this._localFills = getStyle("fills");
            if(this._localFills != null)
            {
               this._fillCount = this._localFills.length;
            }
            else
            {
               this._fillCount = 0;
            }
         }
         if(param1 == "itemRenderer")
         {
            this._pointInstanceCache.remove = true;
            this._pointInstanceCache.discard = true;
            this._pointInstanceCache.count = 0;
            this._pointInstanceCache.discard = false;
            this._pointInstanceCache.remove = false;
         }
         if(param1 == "lineSegmentRenderer")
         {
            this._segmentInstanceCache.remove = true;
            this._segmentInstanceCache.discard = true;
            this._segmentInstanceCache.count = 0;
            this._segmentInstanceCache.discard = false;
            this._segmentInstanceCache.remove = false;
         }
         invalidateDisplayList();
         legendDataChanged();
      }
      
      override protected function updateData() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Class = null;
         var _loc1_:Class = this.renderDataType;
         this._renderData = new _loc1_();
         this._renderData.cache = [];
         if(dataProvider)
         {
            cursor.seek(CursorBookmark.FIRST);
            _loc2_ = 0;
            _loc3_ = this.itemType;
            while(!cursor.afterLast)
            {
               this._renderData.cache[_loc2_] = new _loc3_(this,cursor.current,_loc2_);
               _loc2_++;
               cursor.moveNext();
            }
            cacheDefaultValues(this._yField,this._renderData.cache,"yValue");
            cacheIndexValues(this._xField,this._renderData.cache,"xValue");
         }
         if(dataTransform && dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS) is NumericAxis && !(dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS) is DateTimeAxis) && (dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS) as NumericAxis).direction == "inverted")
         {
            this._renderData.cache = this.reverseYValues(this._renderData.cache);
         }
         if(dataTransform && dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS) is NumericAxis && !(dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS) is DateTimeAxis) && (dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS) as NumericAxis).direction == "inverted")
         {
            this._renderData.cache = this.reverseXValues(this._renderData.cache);
         }
         this._renderData.validPoints = this._renderData.cache.length;
         super.updateData();
      }
      
      override protected function updateMapping() : void
      {
         dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).mapCache(this._renderData.cache,"xValue","xNumber",this._xField == "");
         dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).mapCache(this._renderData.cache,"yValue","yNumber");
         if(this._xField != "" && this._sortOnXField)
         {
            this._renderData.cache.sortOn("xNumber",Array.NUMERIC);
         }
         super.updateMapping();
      }
      
      override protected function updateFilter() : void
      {
         this._renderData.segments = [];
         var _loc1_:Class = this.lineSegmentType;
         this._renderData.filteredCache = filterFunction(this._renderData.cache);
         if(filterFunction != this.defaultFilterFunction)
         {
            this.createLineSegments(this._renderData.filteredCache);
         }
         super.updateFilter();
      }
      
      override protected function updateTransform() : void
      {
         var _loc1_:CartesianChart = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         dataTransform.transformCache(this._renderData.filteredCache,"xNumber","x","yNumber","y");
         super.updateTransform();
         allSeriesTransform = true;
         if(chart && chart is CartesianChart)
         {
            _loc1_ = CartesianChart(chart);
            _loc2_ = _loc1_.series.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(_loc1_.getSeriesTransformState(_loc1_.series[_loc3_]))
               {
                  allSeriesTransform = false;
               }
               _loc3_++;
            }
            if(allSeriesTransform)
            {
               _loc1_.measureLabels();
            }
         }
      }
      
      override public function describeData(param1:String, param2:uint) : Array
      {
         var _loc4_:Number = NaN;
         var _loc5_:IStroke = null;
         var _loc6_:Number = NaN;
         var _loc7_:Object = null;
         var _loc8_:Array = null;
         validateData();
         if(this._renderData.cache.length == 0)
         {
            return [];
         }
         var _loc3_:DataDescription = new DataDescription();
         _loc3_.boundedValues = null;
         if(param1 == CartesianTransform.VERTICAL_AXIS)
         {
            extractMinMax(this._renderData.cache,"yNumber",_loc3_);
            if((param2 & DataDescription.REQUIRED_BOUNDED_VALUES) != 0)
            {
               _loc4_ = 0;
               if(_loc5_ = getStyle("lineStroke"))
               {
                  _loc4_ = _loc5_.weight / 2;
               }
               _loc6_ = getStyle("radius");
               _loc7_ = getStyle("itemRenderer");
               if(_loc6_ > 0 && _loc7_)
               {
                  if(_loc5_ = getStyle("stroke"))
                  {
                     _loc6_ += _loc5_.weight / 2;
                  }
                  _loc4_ = Math.max(_loc6_,_loc4_);
               }
               if(_loc4_ > 0)
               {
                  _loc3_.boundedValues = [];
                  _loc3_.boundedValues.push(new BoundedValue(_loc3_.max,0,_loc4_));
                  _loc3_.boundedValues.push(new BoundedValue(_loc3_.min,_loc4_,0));
               }
            }
         }
         else
         {
            if(param1 != CartesianTransform.HORIZONTAL_AXIS)
            {
               return [];
            }
            if(this._xField != "")
            {
               if((param2 & DataDescription.REQUIRED_MIN_INTERVAL) != 0)
               {
                  _loc8_ = this._renderData.cache;
                  if(this._sortOnXField == false)
                  {
                     (_loc8_ = this._renderData.cache.concat()).sortOn("xNumber",Array.NUMERIC);
                  }
                  extractMinMax(_loc8_,"xNumber",_loc3_,0 != (param2 & DataDescription.REQUIRED_MIN_INTERVAL));
               }
               else
               {
                  extractMinMax(this._renderData.cache,"xNumber",_loc3_,(param2 & DataDescription.REQUIRED_MIN_INTERVAL) != 0);
               }
            }
            else
            {
               _loc3_.min = this._renderData.cache[0].xNumber;
               _loc3_.max = this._renderData.cache[this._renderData.cache.length - 1].xNumber;
               if((param2 & DataDescription.REQUIRED_MIN_INTERVAL) != 0)
               {
                  extractMinInterval(this._renderData.cache,"xNumber",_loc3_);
               }
            }
            if((param2 & DataDescription.REQUIRED_BOUNDED_VALUES) != 0)
            {
               _loc4_ = 0;
               if(_loc5_ = getStyle("lineStroke"))
               {
                  _loc4_ = _loc5_.weight / 2;
               }
               _loc6_ = getStyle("radius");
               _loc7_ = getStyle("itemRenderer");
               if(_loc6_ > 0 && _loc7_)
               {
                  if(_loc5_ = getStyle("stroke"))
                  {
                     _loc6_ += _loc5_.weight / 2;
                  }
                  _loc4_ = Math.max(_loc6_,_loc4_);
               }
               if(_loc4_ > 0)
               {
                  _loc3_.boundedValues = [];
                  _loc3_.boundedValues.push(new BoundedValue(_loc3_.max,0,_loc4_));
                  _loc3_.boundedValues.push(new BoundedValue(_loc3_.min,_loc4_,0));
               }
            }
         }
         return [_loc3_];
      }
      
      override public function getAllDataPoints() : Array
      {
         var _loc3_:uint = 0;
         var _loc5_:LineSeriesItem = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:HitData = null;
         var _loc10_:IStroke = null;
         var _loc11_:LinearGradientStroke = null;
         if(!this._renderData)
         {
            return [];
         }
         if(!this._renderData.filteredCache)
         {
            return [];
         }
         var _loc1_:Array = [];
         if(chart && chart.dataTipItemsSet && dataTipItems)
         {
            _loc1_ = dataTipItems;
         }
         else if(chart && chart.showAllDataTips && this._renderData.filteredCache)
         {
            _loc1_ = this._renderData.filteredCache;
         }
         else
         {
            _loc1_ = [];
         }
         var _loc2_:uint = _loc1_.length;
         var _loc4_:Array = [];
         _loc3_ = 0;
         for(; _loc3_ < _loc2_; _loc3_++)
         {
            _loc5_ = _loc1_[_loc3_];
            if(this._renderData.filteredCache.indexOf(_loc5_) == -1)
            {
               _loc6_ = false;
               _loc7_ = this._renderData.filteredCache.length;
               _loc8_ = 0;
               while(_loc8_ < _loc7_)
               {
                  if(_loc5_.item == this._renderData.filteredCache[_loc8_].item)
                  {
                     _loc5_ = this._renderData.filteredCache[_loc8_];
                     _loc6_ = true;
                     break;
                  }
                  _loc8_++;
               }
               if(!_loc6_)
               {
                  continue;
               }
            }
            if(_loc5_)
            {
               _loc9_ = new HitData(createDataID(_loc5_.index),Math.sqrt(0),_loc5_.x,_loc5_.y,_loc5_);
               if((_loc10_ = getStyle("lineStroke")) is SolidColorStroke)
               {
                  _loc9_.contextColor = SolidColorStroke(_loc10_).color;
               }
               else if(_loc10_ is LinearGradientStroke)
               {
                  if((_loc11_ = LinearGradientStroke(_loc10_)).entries.length > 0)
                  {
                     _loc9_.contextColor = _loc11_.entries[0].color;
                  }
               }
               _loc9_.dataTipFunction = this.formatDataTip;
               _loc4_.push(_loc9_);
            }
         }
         return _loc4_;
      }
      
      override public function findDataPoints(param1:Number, param2:Number, param3:Number) : Array
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Boolean = false;
         var _loc13_:LineSeriesItem = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:uint = 0;
         var _loc18_:HitData = null;
         var _loc19_:IStroke = null;
         var _loc20_:LinearGradientStroke = null;
         if(interactive == false || !this._renderData)
         {
            return [];
         }
         var _loc4_:Number;
         var _loc5_:Number = (_loc4_ = getStyle("radius")) + param3;
         _loc5_ *= _loc5_;
         var _loc6_:LineSeriesItem = null;
         var _loc7_:Number = _loc4_ * _loc4_;
         var _loc8_:int;
         if((_loc8_ = this._renderData.filteredCache.length) == 0)
         {
            return [];
         }
         if(this.sortOnXField == true)
         {
            _loc9_ = 0;
            _loc10_ = _loc8_;
            _loc11_ = Math.floor((_loc9_ + _loc10_) / 2);
            _loc12_ = isNaN(this._renderData.filteredCache[0]);
            while(true)
            {
               _loc13_ = this._renderData.filteredCache[_loc11_];
               if(!isNaN(_loc13_.yNumber) && !isNaN(_loc13_.xNumber))
               {
                  if((_loc16_ = (_loc13_.x - param1) * (_loc13_.x - param1) + (_loc13_.y - param2) * (_loc13_.y - param2)) <= _loc5_)
                  {
                     _loc5_ = _loc16_;
                     _loc6_ = _loc13_;
                  }
               }
               if(dataTransform && dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS) is NumericAxis && (dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS) as NumericAxis).direction == "inverted")
               {
                  _loc14_ = param1;
                  _loc15_ = _loc13_.x;
               }
               else
               {
                  _loc14_ = _loc13_.x;
                  _loc15_ = param1;
               }
               if(_loc14_ < _loc15_ || isNaN(_loc13_.x) && _loc12_)
               {
                  _loc9_ = _loc11_;
                  if((_loc11_ = Math.floor((_loc9_ + _loc10_) / 2)) == _loc9_)
                  {
                     break;
                  }
               }
               else
               {
                  _loc10_ = _loc11_;
                  if((_loc11_ = Math.floor((_loc9_ + _loc10_) / 2)) == _loc10_)
                  {
                     break;
                  }
               }
            }
         }
         else
         {
            _loc17_ = 0;
            while(_loc17_ < _loc8_)
            {
               _loc13_ = this._renderData.filteredCache[_loc17_];
               if(!isNaN(_loc13_.yNumber) && !isNaN(_loc13_.xNumber))
               {
                  if((_loc16_ = (_loc13_.x - param1) * (_loc13_.x - param1) + (_loc13_.y - param2) * (_loc13_.y - param2)) <= _loc5_)
                  {
                     _loc5_ = _loc16_;
                     _loc6_ = _loc13_;
                  }
               }
               _loc17_++;
            }
         }
         if(_loc6_)
         {
            _loc18_ = new HitData(createDataID(_loc6_.index),Math.sqrt(_loc5_),_loc6_.x,_loc6_.y,_loc6_);
            if((_loc19_ = getStyle("lineStroke")) is SolidColorStroke)
            {
               _loc18_.contextColor = SolidColorStroke(_loc19_).color;
            }
            else if(_loc19_ is LinearGradientStroke)
            {
               if((_loc20_ = LinearGradientStroke(_loc19_)).entries.length > 0)
               {
                  _loc18_.contextColor = _loc20_.entries[0].color;
               }
            }
            _loc18_.dataTipFunction = this.formatDataTip;
            return [_loc18_];
         }
         return [];
      }
      
      override public function getElementBounds(param1:Object) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc10_:Rectangle = null;
         var _loc11_:int = 0;
         var _loc12_:Object = null;
         var _loc13_:Object = null;
         var _loc14_:Rectangle = null;
         var _loc15_:Rectangle = null;
         var _loc2_:Array = param1.cache;
         var _loc3_:Array = param1.segments;
         var _loc4_:Array = [];
         var _loc5_:int;
         if((_loc5_ = _loc2_.length) == 0)
         {
            _loc10_ = new Rectangle();
         }
         else
         {
            if((_loc6_ = param1.radius) == 0 || isNaN(_loc6_))
            {
               _loc6_ = 1;
            }
            if(_loc7_ = _loc3_.length)
            {
               _loc9_ = _loc2_[param1.segments[0].start];
               _loc10_ = new Rectangle(_loc9_.x,_loc9_.y,0,0);
            }
            _loc8_ = 0;
            while(_loc8_ < _loc7_)
            {
               _loc12_ = param1.segments[_loc8_];
               if(_loc8_ > 0)
               {
                  _loc13_ = param1.segments[_loc8_ - 1];
                  if(_loc12_.start > _loc13_.end + 1)
                  {
                     _loc11_ = _loc13_.end + 1;
                     while(_loc11_ < _loc12_.start)
                     {
                        _loc14_ = new Rectangle(0,0,0,0);
                        _loc4_[_loc11_] = _loc14_;
                        _loc11_++;
                     }
                  }
               }
               _loc11_ = _loc12_.start;
               while(_loc11_ <= _loc12_.end)
               {
                  _loc9_ = _loc2_[_loc11_];
                  _loc15_ = new Rectangle(_loc9_.x - _loc6_,_loc9_.y - _loc6_,2 * _loc6_,2 * _loc6_);
                  _loc10_.left = Math.min(_loc10_.left,_loc15_.left);
                  _loc10_.top = Math.min(_loc10_.top,_loc15_.top);
                  _loc10_.right = Math.max(_loc10_.right,_loc15_.right);
                  _loc10_.bottom = Math.max(_loc10_.bottom,_loc15_.bottom);
                  _loc4_[_loc11_] = _loc15_;
                  _loc11_++;
               }
               _loc8_++;
            }
         }
         param1.elementBounds = _loc4_;
         param1.bounds = _loc10_;
      }
      
      override public function beginInterpolation(param1:Object, param2:Object) : Object
      {
         var _loc3_:Object = initializeInterpolationData(param1.cache,param2.cache,{
            "x":true,
            "y":true
         },this.itemType,{
            "sourceRenderData":param1,
            "destRenderData":param2
         });
         var _loc4_:LineSeriesRenderData;
         (_loc4_ = LineSeriesRenderData(param2.clone())).cache = _loc3_.cache;
         _loc4_.filteredCache = _loc3_.cache;
         var _loc5_:Array;
         var _loc6_:int = (_loc5_ = _loc4_.segments).length;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc5_[_loc7_].items = _loc3_.cache;
            _loc7_++;
         }
         transitionRenderData = _loc4_;
         return _loc3_;
      }
      
      override protected function getMissingInterpolationValues(param1:Object, param2:Array, param3:Object, param4:Array, param5:Number, param6:Object) : void
      {
         var _loc9_:* = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc7_:Array = param6.sourceRenderData.cache;
         var _loc8_:Array = param6.destRenderData.cache;
         for(_loc9_ in param1)
         {
            _loc10_ = param1[_loc9_];
            _loc11_ = param3[_loc9_];
            _loc12_ = param5;
            if(isNaN(_loc10_))
            {
               if(_loc7_.length == 0)
               {
                  _loc10_ = _loc9_ == "x" ? Number(_loc8_[param5].x) : Number(unscaledHeight);
               }
               else
               {
                  if(_loc12_ >= _loc7_.length)
                  {
                     _loc12_ = _loc7_.length - 1;
                  }
                  while(_loc12_ >= 0 && isNaN(_loc7_[_loc12_][_loc9_]))
                  {
                     _loc12_--;
                  }
                  if(_loc12_ >= 0)
                  {
                     _loc10_ = _loc7_[_loc12_][_loc9_] + 0.01 * (_loc12_ - param5);
                  }
                  if(isNaN(_loc10_))
                  {
                     _loc12_ = param5 + 1;
                     _loc13_ = _loc7_.length;
                     while(_loc12_ < _loc13_ && isNaN(_loc7_[_loc12_][_loc9_]))
                     {
                        _loc12_++;
                     }
                     if(_loc12_ < _loc13_)
                     {
                        _loc10_ = _loc7_[_loc12_][_loc9_] + 0.01 * (_loc12_ - param5);
                     }
                  }
               }
            }
            param1[_loc9_] = _loc10_;
            param3[_loc9_] = _loc11_;
         }
      }
      
      override public function dataToLocal(... rest) : Point
      {
         var _loc2_:Object = {};
         var _loc3_:Array = [_loc2_];
         var _loc4_:int;
         if((_loc4_ = rest.length) > 0)
         {
            _loc2_["d0"] = rest[0];
            dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).mapCache(_loc3_,"d0","v0");
         }
         if(_loc4_ > 1)
         {
            _loc2_["d1"] = rest[1];
            dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).mapCache(_loc3_,"d1","v1");
         }
         dataTransform.transformCache(_loc3_,"v0","s0","v1","s1");
         return new Point(_loc2_.s0 + this.x,_loc2_.s1 + this.y);
      }
      
      override public function localToData(param1:Point) : Array
      {
         return dataTransform.invertTransform(param1.x - this.x,param1.y - this.y);
      }
      
      override public function getItemsInRegion(param1:Rectangle) : Array
      {
         var _loc7_:LineSeriesItem = null;
         if(interactive == false || !this._renderData)
         {
            return [];
         }
         var _loc2_:Array = [];
         var _loc3_:Rectangle = new Rectangle();
         var _loc4_:Rectangle = new Rectangle();
         var _loc5_:uint = this._renderData.filteredCache.length;
         _loc4_.topLeft = globalToLocal(param1.topLeft);
         _loc4_.bottomRight = globalToLocal(param1.bottomRight);
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = this._renderData.filteredCache[_loc6_];
            if(_loc4_.contains(_loc7_.x,_loc7_.y))
            {
               _loc2_.push(_loc7_);
            }
            _loc6_++;
         }
         return _loc2_;
      }
      
      override protected function defaultFilterFunction(param1:Array) : Array
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:LineSeriesItem = null;
         var _loc2_:Array = [];
         var _loc4_:int = -1;
         if(filterDataValues == "outsideRange")
         {
            _loc2_ = param1.concat();
            dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).filterCache(_loc2_,"xNumber","xFilter");
            dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).filterCache(_loc2_,"yNumber","yFilter");
            if(this.xField != "" && this.sortOnXField)
            {
               stripNaNs(_loc2_,"xFilter");
            }
            this._renderData.validPoints = _loc2_.length;
            if(this._interpolateValues == false)
            {
               _loc5_ = _loc2_.length;
               while(_loc4_ < _loc5_)
               {
                  _loc6_ = _loc4_ + 1;
                  while(_loc6_ < _loc5_)
                  {
                     _loc7_ = LineSeriesItem(_loc2_[_loc6_]);
                     if(!isNaN(_loc7_.xFilter) && !isNaN(_loc7_.yFilter))
                     {
                        break;
                     }
                     --this._renderData.validPoints;
                     _loc6_++;
                  }
                  if(_loc6_ == _loc5_)
                  {
                     break;
                  }
                  _loc3_ = _loc6_;
                  _loc6_ = _loc3_ + 1;
                  while(_loc6_ < _loc5_)
                  {
                     _loc7_ = LineSeriesItem(_loc2_[_loc6_]);
                     if(isNaN(_loc7_.xFilter) || isNaN(_loc7_.yFilter))
                     {
                        break;
                     }
                     _loc6_++;
                  }
                  if((_loc4_ = _loc6_ - 1) != _loc3_)
                  {
                     this._renderData.segments.push(new this.lineSegmentType(this,this._renderData.segments.length,_loc2_,_loc3_,_loc4_));
                  }
               }
            }
            else
            {
               stripNaNs(_loc2_,"yFilter");
               this._renderData.validPoints = _loc2_.length;
               if(_loc2_.length > 1)
               {
                  this._renderData.segments.push(new this.lineSegmentType(this,0,_loc2_,_loc3_,_loc2_.length - 1));
               }
            }
         }
         else if(filterDataValues == "nulls")
         {
            _loc2_ = param1.concat();
            if(this.xField != "" && this.sortOnXField)
            {
               stripNaNs(_loc2_,"xNumber");
            }
            this._renderData.validPoints = _loc2_.length;
            if(this._interpolateValues == false)
            {
               _loc5_ = _loc2_.length;
               while(_loc4_ < _loc5_)
               {
                  _loc6_ = _loc4_ + 1;
                  while(_loc6_ < _loc5_)
                  {
                     _loc7_ = LineSeriesItem(_loc2_[_loc6_]);
                     if(!isNaN(_loc7_.xNumber) && !isNaN(_loc7_.yNumber))
                     {
                        break;
                     }
                     --this._renderData.validPoints;
                     _loc6_++;
                  }
                  if(_loc6_ == _loc5_)
                  {
                     break;
                  }
                  _loc3_ = _loc6_;
                  _loc6_ = _loc3_ + 1;
                  while(_loc6_ < _loc5_)
                  {
                     _loc7_ = LineSeriesItem(_loc2_[_loc6_]);
                     if(isNaN(_loc7_.xNumber) || isNaN(_loc7_.yNumber))
                     {
                        break;
                     }
                     _loc6_++;
                  }
                  if((_loc4_ = _loc6_ - 1) != _loc3_)
                  {
                     this._renderData.segments.push(new this.lineSegmentType(this,this._renderData.segments.length,_loc2_,_loc3_,_loc4_));
                  }
               }
            }
            else
            {
               stripNaNs(_loc2_,"yNumber");
               this._renderData.validPoints = _loc2_.length;
               if(_loc2_.length > 1)
               {
                  this._renderData.segments.push(new this.lineSegmentType(this,0,_loc2_,_loc3_,_loc2_.length - 1));
               }
            }
         }
         else if(filterDataValues == "none")
         {
            _loc2_ = param1;
            this._renderData.segments.push(new this.lineSegmentType(this,0,_loc2_,_loc3_,_loc2_.length - 1));
         }
         return _loc2_;
      }
      
      private function createLineSegments(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:LineSeriesItem = null;
         this._renderData.validPoints = param1.length;
         if(this._interpolateValues == false)
         {
            _loc3_ = -1;
            _loc4_ = param1.length;
            while(_loc3_ < _loc4_)
            {
               _loc5_ = _loc3_ + 1;
               while(_loc5_ < _loc4_)
               {
                  _loc6_ = LineSeriesItem(param1[_loc5_]);
                  if(!isNaN(_loc6_.xNumber) && !isNaN(_loc6_.yNumber))
                  {
                     break;
                  }
                  --this._renderData.validPoints;
                  _loc5_++;
               }
               if(_loc5_ == _loc4_)
               {
                  break;
               }
               _loc2_ = _loc5_;
               _loc5_ = _loc2_ + 1;
               while(_loc5_ < _loc4_)
               {
                  _loc6_ = LineSeriesItem(param1[_loc5_]);
                  if(isNaN(_loc6_.xNumber) || isNaN(_loc6_.yNumber))
                  {
                     break;
                  }
                  _loc5_++;
               }
               _loc3_ = _loc5_ - 1;
               if(_loc3_ != _loc2_)
               {
                  this._renderData.segments.push(new this.lineSegmentType(this,this._renderData.segments.length,param1,_loc2_,_loc3_));
               }
            }
         }
         else
         {
            this._renderData.validPoints = param1.length;
            if(param1.length > 1)
            {
               this._renderData.segments.push(new this.lineSegmentType(this,0,param1,_loc2_,param1.length - 1));
            }
         }
      }
      
      protected function applyItemRendererProperties(param1:DisplayObject, param2:InstanceCache) : void
      {
         if(param1 is ISimpleStyleClient)
         {
            ISimpleStyleClient(param1).styleName = this;
         }
      }
      
      private function formatDataTip(param1:HitData) : String
      {
         var _loc2_:String = "";
         var _loc3_:String = displayName;
         if(_loc3_ && _loc3_ != "")
         {
            _loc2_ += "<b>" + _loc3_ + "</b><BR/>";
         }
         var _loc4_:String;
         if((_loc4_ = dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).displayName) != "")
         {
            _loc2_ += "<i>" + _loc4_ + ":</i> ";
         }
         _loc2_ += dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).formatForScreen(LineSeriesItem(param1.chartItem).xValue) + "\n";
         var _loc5_:String;
         if((_loc5_ = dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).displayName) != "")
         {
            _loc2_ += "<i>" + _loc5_ + ":</i> ";
         }
         return _loc2_ + (dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).formatForScreen(LineSeriesItem(param1.chartItem).yValue) + "\n");
      }
      
      private function defaultFillFunction(param1:LineSeriesItem, param2:Number) : IFill
      {
         if(this._fillCount != 0)
         {
            return GraphicsUtilities.fillFromStyle(this._localFills[param2 % this._fillCount]);
         }
         return GraphicsUtilities.fillFromStyle(getStyle("fill"));
      }
      
      private function reverseYValues(param1:Array) : Array
      {
         var _loc2_:int = 0;
         var _loc3_:int = param1.length;
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            param1[_loc2_]["yValue"] = -param1[_loc2_]["yValue"];
            _loc2_++;
         }
         return param1;
      }
      
      private function reverseXValues(param1:Array) : Array
      {
         var _loc2_:int = 0;
         var _loc3_:int = param1.length;
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            param1[_loc2_]["xValue"] = -param1[_loc2_]["xValue"];
            _loc2_++;
         }
         return param1;
      }
      
      [Bindable(event="propertyChange")]
      private function get _fillFunction() : Function
      {
         return this._1757871014_fillFunction;
      }
      
      private function set _fillFunction(param1:Function) : void
      {
         var _loc2_:Object = this._1757871014_fillFunction;
         if(_loc2_ !== param1)
         {
            this._1757871014_fillFunction = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_fillFunction",_loc2_,param1));
            }
         }
      }
   }
}

import flash.display.Graphics;
import mx.charts.series.LineSeries;
import mx.graphics.IStroke;
import mx.graphics.LinearGradientStroke;
import mx.graphics.SolidColorStroke;
import mx.skins.ProgrammaticSkin;

class LineSeriesLegendMarker extends ProgrammaticSkin
{
    
   
   private var _element:LineSeries;
   
   function LineSeriesLegendMarker(param1:LineSeries)
   {
      super();
      this._element = param1;
      styleName = this._element;
   }
   
   override protected function updateDisplayList(param1:Number, param2:Number) : void
   {
      var _loc4_:Number = NaN;
      var _loc6_:LinearGradientStroke = null;
      super.updateDisplayList(param1,param2);
      var _loc3_:IStroke = getStyle("lineStroke");
      if(_loc3_ is SolidColorStroke)
      {
         _loc4_ = SolidColorStroke(_loc3_).color;
      }
      else if(_loc3_ is LinearGradientStroke)
      {
         if((_loc6_ = LinearGradientStroke(_loc3_)).entries.length > 0)
         {
            _loc4_ = _loc6_.entries[0].color;
         }
      }
      var _loc5_:Graphics;
      (_loc5_ = graphics).clear();
      _loc5_.moveTo(0,0);
      _loc5_.lineStyle(0,0,0);
      _loc5_.beginFill(_loc4_);
      _loc5_.lineTo(width,0);
      _loc5_.lineTo(width,height);
      _loc5_.lineTo(0,height);
      _loc5_.lineTo(0,0);
      _loc5_.endFill();
   }
}
