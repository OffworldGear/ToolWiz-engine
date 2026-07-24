package mx.charts.chartClasses
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import mx.charts.HitData;
   import mx.core.IUIComponent;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class StackedSeries extends Series
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _seriesDirty:Boolean = true;
      
      protected var posTotalsByPrimaryAxis:Dictionary;
      
      protected var negTotalsByPrimaryAxis:Dictionary;
      
      protected var stackedMaximum:Number;
      
      protected var stackedMinimum:Number;
      
      private var stackingDirty:Boolean = true;
      
      private var _bAxesDirty:Boolean = false;
      
      private var _allowNegativeForStacked:Boolean = false;
      
      private var _horizontalAxis:IAxis;
      
      private var _series:Array;
      
      private var _type:String;
      
      private var _verticalAxis:IAxis;
      
      public function StackedSeries()
      {
         this._series = [];
         super();
         dataTransform = new CartesianTransform();
         invalidateProperties();
      }
      
      override protected function processNewDataProvider(param1:Object) : void
      {
         super.processNewDataProvider(param1);
         var _loc2_:int = this._series.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            IChartElement(this._series[_loc3_]).chartDataProvider = dataProvider;
            _loc3_++;
         }
      }
      
      public function get allowNegativeForStacked() : Boolean
      {
         return this._allowNegativeForStacked;
      }
      
      public function set allowNegativeForStacked(param1:Boolean) : void
      {
         this.invalidateStacking();
         this.invalidateSeries();
         this._allowNegativeForStacked = param1;
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
      
      public function get series() : Array
      {
         return this._series;
      }
      
      public function set series(param1:Array) : void
      {
         this._series = param1 == null ? [] : param1;
         this.invalidateSeries();
         var _loc2_:ChartBase = chart;
         if(_loc2_)
         {
            _loc2_.invalidateSeriesStyles();
         }
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function set type(param1:String) : void
      {
         this.invalidateStacking();
         this.invalidateSeries();
         this._type = param1;
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
      
      override protected function commitProperties() : void
      {
         var _loc2_:CartesianChart = null;
         super.commitProperties();
         this.updateStacking();
         if(this._seriesDirty)
         {
            this._seriesDirty = false;
            this.buildSubSeries();
         }
         if(this._bAxesDirty)
         {
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
            this._bAxesDirty = false;
         }
         var _loc1_:Object = chart;
         if(_loc1_ && _loc1_ is CartesianChart)
         {
            _loc2_ = CartesianChart(_loc1_);
            if(!this._horizontalAxis)
            {
               if(dataTransform.axes[CartesianTransform.HORIZONTAL_AXIS] != _loc2_.horizontalAxis)
               {
                  CartesianTransform(dataTransform).setAxis(CartesianTransform.HORIZONTAL_AXIS,_loc2_.horizontalAxis);
               }
            }
            if(!this._verticalAxis)
            {
               if(dataTransform.axes[CartesianTransform.VERTICAL_AXIS] != _loc2_.verticalAxis)
               {
                  CartesianTransform(dataTransform).setAxis(CartesianTransform.VERTICAL_AXIS,_loc2_.verticalAxis);
               }
            }
         }
         dataTransform.elements = [this];
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
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         var _loc3_:int = numChildren;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            IUIComponent(getChildAt(_loc4_)).setActualSize(param1,param2);
            _loc4_++;
         }
      }
      
      override public function describeData(param1:String, param2:uint) : Array
      {
         var _loc3_:DataDescription = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         this.updateStacking();
         validateData();
         var _loc4_:Array = [];
         if(this.type == "100%")
         {
            if(param1 == CartesianTransform.VERTICAL_AXIS)
            {
               _loc3_ = new DataDescription();
               _loc3_.min = 0;
               _loc3_.max = 100;
               _loc4_ = [_loc3_];
            }
            else
            {
               _loc5_ = this.series.length;
               _loc6_ = 0;
               while(_loc6_ < _loc5_)
               {
                  _loc4_ = _loc4_.concat(this.series[_loc6_].describeData(param1,param2));
                  _loc6_++;
               }
            }
         }
         else if(this.type == "stacked")
         {
            if(param1 == CartesianTransform.VERTICAL_AXIS)
            {
               _loc7_ = [{"value":this.stackedMinimum},{"value":this.stackedMaximum}];
               dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).mapCache(_loc7_,"value","number");
               _loc3_ = new DataDescription();
               _loc3_.min = _loc7_[0].number;
               _loc3_.max = _loc7_[1].number;
               _loc4_ = [_loc3_];
            }
            else
            {
               _loc5_ = this.series.length;
               _loc6_ = 0;
               while(_loc6_ < _loc5_)
               {
                  _loc4_ = _loc4_.concat(this.series[_loc6_].describeData(param1,param2));
                  _loc6_++;
               }
            }
         }
         else
         {
            _loc5_ = this.series.length;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc4_ = _loc4_.concat(this.series[_loc6_].describeData(param1,param2));
               _loc6_++;
            }
         }
         return _loc4_;
      }
      
      override public function findDataPoints(param1:Number, param2:Number, param3:Number) : Array
      {
         var _loc6_:int = 0;
         var _loc5_:int;
         var _loc4_:Array;
         if((_loc5_ = (_loc4_ = super.findDataPoints(param1,param2,param3)).length) > 0 && (this._type == "stacked" || this._type == "100%"))
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc4_[_loc6_].dataTipFunction = this.formatDataTip;
               _loc6_++;
            }
         }
         return _loc4_;
      }
      
      override public function getAllDataPoints() : Array
      {
         var _loc3_:int = 0;
         var _loc1_:Array = super.getAllDataPoints();
         var _loc2_:int = _loc1_.length;
         if(_loc2_ > 0 && (this._type == "stacked" || this._type == "100%"))
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc1_[_loc3_].dataTipFunction = this.formatDataTip;
               _loc3_++;
            }
         }
         return _loc1_;
      }
      
      override public function chartStateChanged(param1:uint, param2:uint) : void
      {
         updateData();
         super.chartStateChanged(param1,param2);
      }
      
      override public function mappingChanged() : void
      {
         var _loc3_:IChartElement = null;
         var _loc1_:int = numChildren;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = getChildAt(_loc2_) as IChartElement;
            if(_loc3_)
            {
               _loc3_.mappingChanged();
            }
            _loc2_++;
         }
         super.mappingChanged();
      }
      
      override public function claimStyles(param1:Array, param2:uint) : uint
      {
         var _loc5_:IChartElement = null;
         var _loc3_:int = this._series.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            param2 = (_loc5_ = this._series[_loc4_]).claimStyles(param1,param2);
            _loc4_++;
         }
         return param2;
      }
      
      override mx_internal function clearSeriesItemsState(param1:Boolean, param2:String = "none") : void
      {
         var _loc3_:Series = null;
         var _loc4_:int = 0;
         super.clearSeriesItemsState(param1,param2);
         _loc4_ = 0;
         while(_loc4_ < this.series.length)
         {
            _loc3_ = this.series[_loc4_];
            _loc3_.clearSeriesItemsState(param1,param2);
            _loc4_++;
         }
      }
      
      override public function get legendData() : Array
      {
         var _loc4_:Object = null;
         var _loc1_:Array = [];
         var _loc2_:int = this._series.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_loc4_ = this._series[_loc3_].legendData)
            {
               _loc1_ = _loc1_.concat(_loc4_);
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      override public function getItemsInRegion(param1:Rectangle) : Array
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc5_:Series = null;
         var _loc4_:Array = [];
         _loc2_ = 0;
         while(_loc2_ < this.series.length)
         {
            _loc3_ = (_loc5_ = this.series[_loc2_]).getItemsInRegion(param1);
            _loc4_ = _loc4_.concat(_loc3_);
            _loc2_++;
         }
         return _loc4_;
      }
      
      protected function invalidateSeries() : void
      {
         if(this._seriesDirty == false)
         {
            this._seriesDirty = true;
            invalidateProperties();
         }
      }
      
      public function invalidateStacking() : void
      {
         if(this.stackingDirty == false)
         {
            this.stackingDirty = true;
            invalidateProperties();
         }
      }
      
      protected function customizeSeries(param1:IChartElement, param2:uint) : void
      {
         param1.chartDataProvider = dataProvider;
      }
      
      protected function buildSubSeries() : void
      {
         var _loc3_:IChartElement = null;
         while(numChildren > 0)
         {
            removeChildAt(0);
         }
         var _loc1_:int = this._series.length - 1;
         while(_loc1_ >= 0)
         {
            _loc3_ = IChartElement(this._series[_loc1_]);
            this.customizeSeries(_loc3_,_loc1_);
            addChild(_loc3_ as DisplayObject);
            _loc1_--;
         }
         var _loc2_:ChartBase = chart;
         if(_loc2_)
         {
            _loc2_.invalidateSeriesStyles();
         }
      }
      
      protected function updateStacking() : void
      {
         if(this.stackingDirty == false)
         {
            return;
         }
         var _loc1_:StackedSeries = null;
         if(!this._series)
         {
            return;
         }
         if(this._type == "stacked" || this._type == "100%")
         {
            _loc1_ = this;
         }
         var _loc2_:int = this._series.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._series[_loc3_] is IStackable)
            {
               this._series[_loc3_].stacker = _loc1_;
            }
            _loc3_++;
         }
         if(this._type == "stacked" || this._type == "100%")
         {
            this.stack();
         }
         this.stackingDirty = false;
      }
      
      public function stack() : void
      {
         var _loc2_:int = 0;
         var _loc3_:IStackable2 = null;
         var _loc4_:Object = null;
         var _loc7_:Array = null;
         var _loc1_:int = this._series.length;
         this.posTotalsByPrimaryAxis = new Dictionary(false);
         this.negTotalsByPrimaryAxis = new Dictionary(false);
         this.stackedMaximum = 0;
         var _loc5_:IStackable2 = null;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this._series[_loc2_];
            if(this._type == "stacked" && this._allowNegativeForStacked)
            {
               _loc4_ = _loc3_.stackAll(this.posTotalsByPrimaryAxis,this.negTotalsByPrimaryAxis,_loc5_);
               this.stackedMaximum = Math.max(this.stackedMaximum,_loc4_.maxValue);
               this.stackedMinimum = !!isNaN(this.stackedMinimum) ? Number(_loc4_.minValue) : Number(Math.min(this.stackedMinimum,_loc4_.minValue));
            }
            else
            {
               this.stackedMaximum = Math.max(this.stackedMaximum,_loc3_.stack(this.posTotalsByPrimaryAxis,_loc5_));
               if(this._type == "100%")
               {
                  this.stackedMinimum = 0;
               }
               else if((_loc7_ = Series(_loc3_).describeData(CartesianTransform.VERTICAL_AXIS,DataDescription.REQUIRED_MIN_MAX | DataDescription.REQUIRED_BOUNDED_VALUES)).length)
               {
                  this.stackedMinimum = !!isNaN(this.stackedMinimum) ? Number(_loc7_[0].min) : Number(Math.min(this.stackedMinimum,_loc7_[0].min));
               }
            }
            _loc5_ = _loc3_;
            _loc2_++;
         }
         var _loc6_:Dictionary = this._type == "100%" ? this.posTotalsByPrimaryAxis : null;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this._series[_loc2_];
            _loc3_.stackTotals = _loc6_;
            _loc2_++;
         }
      }
      
      protected function formatDataTip(param1:HitData) : String
      {
         return "";
      }
   }
}
