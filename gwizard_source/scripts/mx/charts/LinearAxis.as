package mx.charts
{
   import flash.events.Event;
   import mx.charts.chartClasses.AxisLabelSet;
   import mx.charts.chartClasses.NumericAxis;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class LinearAxis extends NumericAxis
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _actualAssignedMaximum:Number;
      
      private var _actualAssignedMinimum:Number;
      
      private var _alignLabelsToInterval:Boolean = true;
      
      private var _userInterval:Number;
      
      private var _maximumLabelPrecision:Number;
      
      private var _minorInterval:Number;
      
      private var _userMinorInterval:Number;
      
      public function LinearAxis()
      {
         super();
      }
      
      override public function set direction(param1:String) : void
      {
         if(param1 == "inverted")
         {
            if(!isNaN(this._actualAssignedMaximum))
            {
               computedMinimum = -this._actualAssignedMaximum;
               assignedMinimum = -this._actualAssignedMaximum;
            }
            if(!isNaN(this._actualAssignedMinimum))
            {
               computedMaximum = -this._actualAssignedMinimum;
               assignedMaximum = -this._actualAssignedMinimum;
            }
         }
         else
         {
            if(!isNaN(this._actualAssignedMaximum))
            {
               computedMaximum = this._actualAssignedMaximum;
               assignedMaximum = this._actualAssignedMaximum;
            }
            if(!isNaN(this._actualAssignedMinimum))
            {
               computedMinimum = this._actualAssignedMinimum;
               assignedMinimum = this._actualAssignedMinimum;
            }
         }
         super.direction = param1;
      }
      
      public function get alignLabelsToInterval() : Boolean
      {
         return this._alignLabelsToInterval;
      }
      
      public function set alignLabelsToInterval(param1:Boolean) : void
      {
         if(param1 != this._alignLabelsToInterval)
         {
            this._alignLabelsToInterval = param1;
            invalidateCache();
            dispatchEvent(new Event("mappingChange"));
            dispatchEvent(new Event("axisChange"));
         }
      }
      
      public function get interval() : Number
      {
         return computedInterval;
      }
      
      public function set interval(param1:Number) : void
      {
         if(param1 <= 0)
         {
            param1 = NaN;
         }
         this._userInterval = param1;
         computedInterval = param1;
         invalidateCache();
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get maximum() : Number
      {
         if(direction == "inverted")
         {
            return -computedMinimum;
         }
         return computedMaximum;
      }
      
      public function set maximum(param1:Number) : void
      {
         if(direction == "inverted")
         {
            assignedMinimum = -param1;
            computedMinimum = -param1;
         }
         else
         {
            assignedMaximum = param1;
            computedMaximum = param1;
         }
         this._actualAssignedMaximum = param1;
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get maximumLabelPrecision() : Number
      {
         return this._maximumLabelPrecision;
      }
      
      public function set maximumLabelPrecision(param1:Number) : void
      {
         this._maximumLabelPrecision = param1;
         invalidateCache();
      }
      
      public function get minimum() : Number
      {
         if(direction == "inverted")
         {
            return -computedMaximum;
         }
         return computedMinimum;
      }
      
      public function set minimum(param1:Number) : void
      {
         if(direction == "inverted")
         {
            assignedMaximum = -param1;
            computedMaximum = -param1;
         }
         else
         {
            assignedMinimum = param1;
            computedMinimum = param1;
         }
         this._actualAssignedMinimum = param1;
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get minorInterval() : Number
      {
         return this._minorInterval;
      }
      
      public function set minorInterval(param1:Number) : void
      {
         if(param1 <= 0)
         {
            param1 = NaN;
         }
         this._userMinorInterval = param1;
         this._minorInterval = param1;
         invalidateCache();
         dispatchEvent(new Event("axisChange"));
      }
      
      override protected function buildLabelCache() : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         if(labelCache)
         {
            return false;
         }
         labelCache = [];
         var _loc1_:Number = computedMaximum - computedMinimum;
         var _loc2_:Number = labelMinimum - Math.floor((labelMinimum - computedMinimum) / computedInterval) * computedInterval;
         if(this._alignLabelsToInterval)
         {
            _loc2_ = Math.ceil(_loc2_ / computedInterval) * computedInterval;
         }
         var _loc3_:Number = computedMaximum;
         var _loc5_:Number = this._maximumLabelPrecision;
         if(isNaN(_loc5_))
         {
            _loc5_ = (_loc9_ = Number(Math.abs(computedInterval) - Math.floor(Math.abs(computedInterval)))) == 0 ? Number(1) : Number(-Math.floor(Math.log(_loc9_) / Math.LN10));
            _loc9_ = Math.abs(computedMinimum) - Math.floor(Math.abs(computedMinimum));
            _loc5_ = Math.max(_loc5_,_loc9_ == 0 ? Number(1) : Number(-Math.floor(Math.log(_loc9_) / Math.LN10)));
         }
         var _loc6_:Number = Math.pow(10,_loc5_);
         var _loc7_:Function;
         if((_loc7_ = this.labelFunction) != null)
         {
            _loc10_ = NaN;
            _loc4_ = _loc2_;
            while(_loc4_ <= _loc3_)
            {
               _loc8_ = Math.round(_loc4_ * _loc6_) / _loc6_;
               if(direction == "inverted")
               {
                  _loc8_ = -_loc8_;
               }
               labelCache.push(new AxisLabel((_loc4_ - computedMinimum) / _loc1_,_loc4_,_loc7_(_loc8_,_loc10_,this)));
               _loc10_ = _loc8_;
               _loc4_ += computedInterval;
            }
         }
         else
         {
            _loc4_ = _loc2_;
            while(_loc4_ <= _loc3_)
            {
               _loc8_ = Math.round(_loc4_ * _loc6_) / _loc6_;
               if(direction == "inverted")
               {
                  _loc8_ = -_loc8_;
               }
               labelCache.push(new AxisLabel((_loc4_ - computedMinimum) / _loc1_,_loc4_,_loc8_.toString()));
               _loc4_ += computedInterval;
            }
         }
         return true;
      }
      
      override public function reduceLabels(param1:AxisLabel, param2:AxisLabel) : AxisLabelSet
      {
         var _loc3_:Number = Math.round((Number(param2.value) - Number(param1.value)) / computedInterval) + 1;
         var _loc4_:Number = _loc3_ * this._minorInterval;
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         var _loc8_:int = labelCache.length;
         var _loc9_:int = 0;
         while(_loc9_ < _loc8_)
         {
            _loc5_.push(labelCache[_loc9_]);
            _loc7_.push(labelCache[_loc9_].position);
            _loc9_ += _loc3_;
         }
         var _loc10_:Number = computedMaximum - computedMinimum;
         var _loc11_:Number = labelMinimum - Math.floor((labelMinimum - computedMinimum) / _loc4_) * _loc4_;
         if(this._alignLabelsToInterval)
         {
            _loc11_ = Math.ceil(_loc11_ / _loc4_) * _loc4_;
         }
         var _loc12_:Number = computedMaximum + 0.000001;
         var _loc13_:Number = _loc11_;
         while(_loc13_ <= _loc12_)
         {
            _loc6_.push((_loc13_ - computedMinimum) / _loc10_);
            _loc13_ += _loc4_;
         }
         var _loc14_:AxisLabelSet;
         (_loc14_ = new AxisLabelSet()).labels = _loc5_;
         _loc14_.minorTicks = _loc6_;
         _loc14_.ticks = _loc7_;
         _loc14_.accurate = true;
         return _loc14_;
      }
      
      override protected function buildMinorTickCache() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:Number = computedMaximum - computedMinimum;
         var _loc3_:Number = labelMinimum - Math.floor((labelMinimum - computedMinimum) / this._minorInterval) * this._minorInterval;
         if(this._alignLabelsToInterval)
         {
            _loc3_ = Math.ceil(_loc3_ / this._minorInterval) * this._minorInterval;
         }
         var _loc4_:Number = computedMaximum;
         var _loc5_:Number = _loc3_;
         while(_loc5_ <= _loc4_)
         {
            _loc1_.push((_loc5_ - computedMinimum) / _loc2_);
            _loc5_ += this._minorInterval;
         }
         return _loc1_;
      }
      
      override protected function adjustMinMax(param1:Number, param2:Number) : void
      {
         var _loc7_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc3_:Number = this._userInterval;
         if(autoAdjust == false && !isNaN(this._userInterval) && !isNaN(this._userMinorInterval))
         {
            return;
         }
         if(param2 == 0 && param1 == 0)
         {
            param2 = 100;
         }
         var _loc4_:Number = Math.floor(Math.log(Math.abs(param2)) / Math.LN10);
         var _loc5_:Number = Math.floor(Math.log(Math.abs(param1)) / Math.LN10);
         var _loc6_:Number = Math.floor(Math.log(Math.abs(param2 - param1)) / Math.LN10);
         if(isNaN(this._userInterval))
         {
            _loc7_ = Math.pow(10,_loc6_);
            if(Math.abs(param2 - param1) / _loc7_ < 4)
            {
               _loc6_--;
               _loc7_ = _loc7_ * 2 / 10;
            }
         }
         else
         {
            _loc7_ = this._userInterval;
         }
         var _loc8_:Number = Math.round(param2 / _loc7_) * _loc7_ == param2 ? Number(param2) : Number((Math.floor(param2 / _loc7_) + 1) * _loc7_);
         if(isFinite(param1))
         {
            _loc9_ = 0;
         }
         if(param1 < 0 || baseAtZero == false)
         {
            _loc9_ = Math.floor(param1 / _loc7_) * _loc7_;
            if(param2 < 0 && baseAtZero)
            {
               _loc8_ = 0;
            }
         }
         else
         {
            _loc9_ = 0;
         }
         if(isNaN(this._userInterval))
         {
            computedInterval = _loc7_;
         }
         if(isNaN(this._userMinorInterval))
         {
            this._minorInterval = computedInterval / 2;
         }
         if(autoAdjust)
         {
            if(isNaN(assignedMinimum))
            {
               computedMinimum = _loc9_;
            }
            if(isNaN(assignedMaximum))
            {
               computedMaximum = _loc8_;
            }
         }
      }
   }
}
