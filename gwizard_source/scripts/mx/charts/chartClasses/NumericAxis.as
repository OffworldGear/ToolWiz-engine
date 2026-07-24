package mx.charts.chartClasses
{
   import flash.events.Event;
   import mx.charts.AxisLabel;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class NumericAxis extends AxisBase implements IAxis
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _labelSet:AxisLabelSet;
      
      private var _cachedDataDescriptions:Array;
      
      private var _cachedValuesHaveBounds:Boolean;
      
      private var _regenerateAutoValues:Boolean = true;
      
      protected var assignedMaximum:Number;
      
      protected var assignedMinimum:Number;
      
      private var _autoAdjust:Boolean = true;
      
      private var _baseAtZero:Boolean = true;
      
      protected var computedInterval:Number;
      
      public var computedMaximum:Number;
      
      public var computedMinimum:Number;
      
      private var _direction:String = "normal";
      
      protected var labelCache:Array;
      
      private var _labelFunction:Function = null;
      
      protected var labelMaximum:Number;
      
      protected var labelMinimum:Number;
      
      protected var minorTickCache:Array;
      
      private var _padding:Number;
      
      private var _parseFunction:Function = null;
      
      public function NumericAxis()
      {
         super();
      }
      
      public function get autoAdjust() : Boolean
      {
         return this._autoAdjust;
      }
      
      public function set autoAdjust(param1:Boolean) : void
      {
         this._autoAdjust = param1;
         this.dataChanged();
      }
      
      public function get baseAtZero() : Boolean
      {
         return this._baseAtZero;
      }
      
      public function set baseAtZero(param1:Boolean) : void
      {
         this._baseAtZero = param1;
         this.dataChanged();
      }
      
      public function get direction() : String
      {
         return this._direction;
      }
      
      public function set direction(param1:String) : void
      {
         if(this._direction != param1)
         {
            this._direction = param1;
            this.invalidateCache();
            this.dataChanged();
         }
      }
      
      public function get labelFunction() : Function
      {
         return this._labelFunction;
      }
      
      public function set labelFunction(param1:Function) : void
      {
         this._labelFunction = param1;
         this.invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get baseline() : Number
      {
         var _loc1_:Number = NaN;
         if(this.computedMinimum >= 0)
         {
            _loc1_ = this.computedMinimum;
         }
         else if(this.computedMaximum <= 0)
         {
            _loc1_ = this.computedMaximum;
         }
         else
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function get minorTicks() : Array
      {
         if(!this.minorTickCache)
         {
            this.minorTickCache = this.buildMinorTickCache();
         }
         return this.minorTickCache;
      }
      
      public function get padding() : Number
      {
         return this._padding;
      }
      
      public function set padding(param1:Number) : void
      {
         this._padding = param1;
         this.invalidateCache();
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get parseFunction() : Function
      {
         return this._parseFunction;
      }
      
      public function set parseFunction(param1:Function) : void
      {
         this._parseFunction = param1;
         this.invalidateCache();
         this._cachedDataDescriptions = null;
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      protected function get requiredDescribedFields() : uint
      {
         return DataDescription.REQUIRED_MIN_MAX | DataDescription.REQUIRED_BOUNDED_VALUES;
      }
      
      protected function get ticks() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:int = this.labelCache.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_.push(this.labelCache[_loc3_].position);
            _loc3_++;
         }
         return _loc1_;
      }
      
      mx_internal function get zeroValue() : Number
      {
         return 0;
      }
      
      override public function dataChanged() : void
      {
         this.minorTickCache = null;
         this._cachedDataDescriptions = null;
         this._regenerateAutoValues = true;
         dispatchEvent(new Event("mappingChange"));
         if(isNaN(this.assignedMinimum) || isNaN(this.assignedMaximum))
         {
            dispatchEvent(new Event("axisChange"));
         }
      }
      
      public function mapCache(param1:Array, param2:String, param3:String, param4:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc5_:int = param1.length;
         if(this._parseFunction != null)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               (_loc7_ = param1[_loc6_])[param3] = this._parseFunction(_loc7_[param2]);
               _loc6_++;
            }
         }
         else
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_ && param1[_loc6_][param2] == null)
            {
               _loc6_++;
            }
            if(_loc6_ == _loc5_)
            {
               return;
            }
            if(param1[_loc6_][param2] is String)
            {
               while(_loc6_ < _loc5_)
               {
                  (_loc7_ = param1[_loc6_])[param3] = Number(_loc7_[param2]);
                  _loc6_++;
               }
            }
            else if(param1[_loc6_][param2] is XML || param1[_loc6_][param2] is XMLList)
            {
               while(_loc6_ < _loc5_)
               {
                  (_loc7_ = param1[_loc6_])[param3] = parseFloat(_loc7_[param2].toString());
                  _loc6_++;
               }
            }
            else if(param1[_loc6_][param2] is Number || param1[_loc6_][param2] is int || param1[_loc6_][param2] is uint)
            {
               while(_loc6_ < _loc5_)
               {
                  if((_loc7_ = param1[_loc6_])[param2] == null || _loc7_[param2].toString() == "")
                  {
                     _loc7_[param3] = NaN;
                  }
                  else
                  {
                     _loc7_[param3] = _loc7_[param2];
                  }
                  _loc6_++;
               }
            }
            else
            {
               while(_loc6_ < _loc5_)
               {
                  (_loc7_ = param1[_loc6_])[param3] = parseFloat(_loc7_[param2]);
                  _loc6_++;
               }
            }
         }
      }
      
      public function filterCache(param1:Array, param2:String, param3:String) : void
      {
         var _loc8_:Object = null;
         this.update();
         var _loc4_:Number = this.computedMaximum + 0.00001;
         var _loc5_:Number = this.computedMinimum - 0.00001;
         var _loc6_:int = param1.length;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = param1[_loc7_][param2];
            param1[_loc7_][param3] = _loc8_ >= _loc5_ && _loc8_ <= _loc4_ ? _loc8_ : NaN;
            _loc7_++;
         }
      }
      
      public function transformCache(param1:Array, param2:String, param3:String) : void
      {
         this.update();
         var _loc4_:Number = this.computedMaximum - this.computedMinimum;
         var _loc5_:int = param1.length;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            param1[_loc6_][param3] = (param1[_loc6_][param2] - this.computedMinimum) / _loc4_;
            _loc6_++;
         }
      }
      
      public function invertTransform(param1:Number) : Object
      {
         this.update();
         return param1 * (this.computedMaximum - this.computedMinimum) + this.computedMinimum;
      }
      
      public function formatForScreen(param1:Object) : String
      {
         if(this.direction == "inverted")
         {
            param1 = -Number(param1) as Object;
         }
         else
         {
            param1 = Number(param1) as Object;
         }
         return param1.toString();
      }
      
      public function getLabelEstimate() : AxisLabelSet
      {
         this.update();
         var _loc1_:Boolean = this.buildLabelCache();
         if(_loc1_)
         {
            this._labelSet = new AxisLabelSet();
            this._labelSet.labels = this.labelCache;
            this._labelSet.accurate = this._cachedValuesHaveBounds == false;
            this._labelSet.minorTicks = this.minorTicks;
            this._labelSet.ticks = this.ticks;
         }
         return this._labelSet;
      }
      
      public function preferDropLabels() : Boolean
      {
         return true;
      }
      
      public function getLabels(param1:Number) : AxisLabelSet
      {
         var _loc2_:Boolean = false;
         if(this._cachedValuesHaveBounds || !this.labelCache)
         {
            this._regenerateAutoValues = true;
            this.updateCache(true,param1);
            _loc2_ = this.buildLabelCache();
         }
         else
         {
            _loc2_ = false;
         }
         if(_loc2_)
         {
            this._labelSet = new AxisLabelSet();
            this._labelSet.labels = this.labelCache;
            this._labelSet.minorTicks = this.minorTicks;
            this._labelSet.ticks = this.ticks;
         }
         return this._labelSet;
      }
      
      public function reduceLabels(param1:AxisLabel, param2:AxisLabel) : AxisLabelSet
      {
         return this._labelSet;
      }
      
      protected function buildLabelCache() : Boolean
      {
         return false;
      }
      
      protected function buildMinorTickCache() : Array
      {
         return [];
      }
      
      private function updateCache(param1:Boolean, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Boolean = false;
         var _loc7_:Number = NaN;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:DataDescription = null;
         var _loc12_:Number = NaN;
         if(this._regenerateAutoValues)
         {
            _loc3_ = this.computedMinimum;
            _loc4_ = this.computedMaximum;
            _loc5_ = this.computedInterval;
            if(!isNaN(this.assignedMinimum))
            {
               this.computedMinimum = this.assignedMinimum;
            }
            if(!isNaN(this.assignedMaximum))
            {
               this.computedMaximum = this.assignedMaximum;
            }
            if(_loc6_ = isNaN(this.assignedMinimum) || isNaN(this.assignedMaximum))
            {
               this.autoGenerate(param1,param2);
            }
            this.adjustMinMax(this.computedMinimum,this.computedMaximum);
            this.labelMinimum = this.computedMinimum;
            this.labelMaximum = this.computedMaximum;
            if((this.autoAdjust || _loc6_) && param1 && this._cachedValuesHaveBounds)
            {
               this.adjustForMargins(param2);
            }
            _loc7_ = unitSize;
            if(!isNaN(this._padding))
            {
               if(this.labelMinimum - this.computedMinimum < this._padding * _loc7_)
               {
                  this.computedMinimum = this.labelMinimum - this._padding * _loc7_;
               }
               if(this.computedMaximum - this.labelMaximum < this._padding * _loc7_)
               {
                  this.computedMaximum = this.labelMaximum + this._padding * _loc7_;
               }
            }
            _loc9_ = (_loc8_ = this.dataDescriptions).length;
            _loc10_ = 0;
            while(_loc10_ < _loc9_)
            {
               _loc11_ = _loc8_[_loc10_];
               if(!isNaN(_loc11_.padding))
               {
                  if(isNaN(this.assignedMinimum) && _loc11_.min - this.computedMinimum < _loc11_.padding * _loc7_)
                  {
                     this.computedMinimum = _loc11_.min - _loc11_.padding * _loc7_;
                  }
                  if(isNaN(this.assignedMaximum) && this.computedMaximum - _loc11_.max < _loc11_.padding * _loc7_)
                  {
                     this.computedMaximum = _loc11_.max + _loc11_.padding * _loc7_;
                  }
               }
               _loc10_++;
            }
            if(this.computedMinimum == this.computedMaximum)
            {
               _loc12_ = unitSize / 2;
               this.computedMinimum -= _loc12_;
               this.computedMaximum += _loc12_;
            }
            if(_loc3_ != this.computedMinimum || _loc4_ != this.computedMaximum || _loc5_ != this.computedInterval)
            {
               this.labelCache = null;
               this.minorTickCache = null;
            }
            this._regenerateAutoValues = false;
         }
      }
      
      protected function invalidateCache() : void
      {
         this.minorTickCache = null;
         this._regenerateAutoValues = true;
         this.labelCache = null;
      }
      
      public function update() : void
      {
         this.updateCache(true,0);
      }
      
      private function adjustForMargins(param1:Number) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:Boolean = false;
         var _loc14_:Number = NaN;
         var _loc15_:BoundedValue = null;
         var _loc16_:Number = NaN;
         var _loc17_:BoundedValue = null;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:BoundedValue = null;
         var _loc24_:Number = NaN;
         var _loc2_:Number = this.computedMinimum;
         var _loc3_:Number = this.computedMaximum;
         var _loc6_:Array = [];
         var _loc7_:Array = this.dataDescriptions;
         var _loc8_:Boolean = true;
         _loc4_ = _loc7_.length;
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if(_loc7_[_loc5_].boundedValues)
            {
               _loc6_ = _loc6_.concat(_loc7_[_loc5_].boundedValues);
            }
            _loc5_++;
         }
         _loc4_ = _loc6_.length;
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if(!(_loc6_[_loc5_].lowerMargin < param1 && _loc6_[_loc5_].upperMargin < param1))
            {
               _loc8_ = false;
            }
            _loc5_++;
         }
         if(_loc6_.length > 0 && param1 > 0 && _loc8_)
         {
            if(isNaN(_loc2_))
            {
               _loc2_ = _loc6_[0].value;
            }
            if(isNaN(_loc3_))
            {
               _loc3_ = _loc6_[0].value;
            }
            _loc10_ = param1;
            _loc11_ = _loc3_ - _loc2_;
            _loc12_ = 0;
            _loc4_ = _loc6_.length;
            _loc13_ = true;
            while(_loc13_)
            {
               _loc14_ = param1;
               _loc16_ = 0;
               _loc18_ = _loc3_;
               _loc19_ = 0;
               _loc20_ = _loc2_;
               _loc21_ = 0;
               _loc5_ = 0;
               while(_loc5_ < _loc4_)
               {
                  _loc24_ = ((_loc23_ = _loc6_[_loc5_]).value - _loc2_) / _loc11_ * param1;
                  if(!isNaN(_loc23_.lowerMargin) && _loc24_ - _loc23_.lowerMargin < _loc14_)
                  {
                     _loc14_ = _loc24_ - _loc23_.lowerMargin;
                     _loc15_ = _loc23_;
                  }
                  if(!isNaN(_loc23_.upperMargin) && _loc24_ + _loc23_.upperMargin > _loc16_)
                  {
                     _loc16_ = _loc24_ + _loc23_.upperMargin;
                     _loc17_ = _loc23_;
                  }
                  _loc5_++;
               }
               if(_loc14_ > -0.0001 && _loc16_ < param1 + 0.0001)
               {
                  break;
               }
               if(_loc16_ > param1)
               {
                  _loc18_ = _loc17_.value;
                  _loc19_ = _loc17_.upperMargin;
               }
               else
               {
                  _loc13_ = false;
               }
               if(_loc14_ < 0)
               {
                  _loc20_ = _loc15_.value;
                  _loc21_ = _loc15_.lowerMargin;
               }
               else
               {
                  _loc13_ = false;
               }
               _loc2_ = ((_loc22_ = param1 - _loc19_) * _loc20_ - _loc21_ * _loc18_) / Math.abs(_loc22_ - _loc21_);
               _loc3_ = param1 * (_loc18_ - _loc2_) / (param1 - _loc19_) + _loc2_;
               _loc11_ = _loc3_ - _loc2_;
               if(_loc12_++ == 3)
               {
                  break;
               }
            }
         }
         var _loc9_:Array;
         if(_loc9_ = this.guardMinMax(_loc2_,_loc3_))
         {
            _loc2_ = _loc9_[0];
            _loc3_ = _loc9_[1];
         }
         if(isNaN(this.assignedMinimum))
         {
            this.computedMinimum = _loc2_;
         }
         if(isNaN(this.assignedMaximum))
         {
            this.computedMaximum = _loc3_;
         }
      }
      
      protected function get dataDescriptions() : Array
      {
         if(!this._cachedDataDescriptions)
         {
            this._cachedDataDescriptions = describeData(this.requiredDescribedFields);
            this._cachedValuesHaveBounds = false;
         }
         return this._cachedDataDescriptions;
      }
      
      private function autoGenerate(param1:Boolean, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Object = null;
         var _loc8_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:DataDescription = null;
         var _loc6_:Array = this.dataDescriptions;
         if(this.autoAdjust && this.baseAtZero)
         {
            if(this.direction == "inverted")
            {
               _loc4_ = this.zeroValue;
            }
            else
            {
               _loc3_ = this.zeroValue;
            }
         }
         var _loc7_:int;
         if((_loc7_ = _loc6_.length) > 0)
         {
            if(this.direction == "inverted")
            {
               _loc3_ = _loc6_[0].min;
               if(!isNaN(_loc4_) && _loc3_ > _loc4_)
               {
                  _loc10_ = _loc4_;
                  _loc4_ = _loc3_;
                  _loc3_ = _loc10_;
               }
               if(isNaN(_loc4_))
               {
                  _loc4_ = _loc6_[0].max;
               }
               else if(!isNaN(_loc6_[0].max))
               {
                  _loc4_ = Math.max(_loc4_,_loc6_[0].max);
               }
            }
            else
            {
               _loc4_ = _loc6_[0].max;
               if(!isNaN(_loc3_) && _loc3_ > _loc4_)
               {
                  _loc10_ = _loc4_;
                  _loc4_ = _loc3_;
                  _loc3_ = _loc10_;
               }
               if(isNaN(_loc3_))
               {
                  _loc3_ = _loc6_[0].min;
               }
               else if(!isNaN(_loc6_[0].min))
               {
                  _loc3_ = Math.min(_loc3_,_loc6_[0].min);
               }
            }
            _loc11_ = 0;
            while(_loc11_ < _loc7_)
            {
               _loc12_ = _loc6_[_loc11_];
               if(isNaN(_loc3_))
               {
                  _loc3_ = _loc12_.min;
               }
               else if(!isNaN(_loc12_.min))
               {
                  _loc3_ = Math.min(_loc3_,_loc12_.min);
               }
               if(isNaN(_loc4_))
               {
                  _loc4_ = _loc12_.max;
               }
               else if(!isNaN(_loc12_.max))
               {
                  _loc4_ = Math.max(_loc4_,_loc12_.max);
               }
               this._cachedValuesHaveBounds = this._cachedValuesHaveBounds || _loc12_.boundedValues && _loc12_.boundedValues.length > 0;
               _loc11_++;
            }
         }
         var _loc9_:Array;
         if(_loc9_ = this.guardMinMax(_loc3_,_loc4_))
         {
            _loc3_ = _loc9_[0];
            _loc4_ = _loc9_[1];
         }
         if(isNaN(this.assignedMinimum))
         {
            this.computedMinimum = _loc3_;
         }
         if(isNaN(this.assignedMaximum))
         {
            this.computedMaximum = _loc4_;
         }
      }
      
      protected function adjustMinMax(param1:Number, param2:Number) : void
      {
      }
      
      protected function guardMinMax(param1:Number, param2:Number) : Array
      {
         if(isNaN(param1) || !isFinite(param1))
         {
            return [0,100];
         }
         if(isNaN(param2) || !isFinite(param2) || param1 == param2)
         {
            return [param1,param1 + 100];
         }
         return null;
      }
      
      mx_internal function getSortOrder() : Boolean
      {
         return this.computedMinimum < this.computedMaximum;
      }
   }
}
