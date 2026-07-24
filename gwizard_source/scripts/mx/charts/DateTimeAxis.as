package mx.charts
{
   import flash.events.Event;
   import mx.charts.chartClasses.AxisLabelSet;
   import mx.charts.chartClasses.DataDescription;
   import mx.charts.chartClasses.DateRangeUtilities;
   import mx.charts.chartClasses.NumericAxis;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class DateTimeAxis extends NumericAxis
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const MILLISECONDS_IN_MINUTE:Number = 1000 * 60;
      
      private static const MILLISECONDS_IN_HOUR:Number = 1000 * 60 * 60;
      
      private static const MILLISECONDS_IN_DAY:Number = 1000 * 60 * 60 * 24;
      
      private static const MILLISECONDS_IN_WEEK:Number = 1000 * 60 * 60 * 24 * 7;
      
      private static const MILLISECONDS_IN_MONTH:Number = 1000 * 60 * 60 * 24 * 30;
      
      private static const MILLISECONDS_IN_YEAR:Number = 1000 * 60 * 60 * 24 * 365;
      
      private static const MINIMUM_LABEL_COUNT:Number = 2;
      
      private static var tmpDate:Date = new Date();
       
      
      private var UNIT_PROGRESSION:Object;
      
      private var millisecondsP:String;
      
      private var secondsP:String;
      
      private var minutesP:String;
      
      private var hoursP:String;
      
      private var dateP:String;
      
      private var dayP:String;
      
      private var monthP:String;
      
      private var fullYearP:String;
      
      private var dateRangeUtilities:DateRangeUtilities;
      
      private var _unitSize:Number = 8.64E7;
      
      private var _alignLabelsToUnits:Boolean = true;
      
      private var _dataInterval:Number = 1;
      
      private var _userDataInterval:Number;
      
      private var _dataUnits:String = null;
      
      private var _userDataUnits:String = null;
      
      private var _disabledDays:Array;
      
      private var _disabledRanges:Array;
      
      private var _displayLocalTime:Boolean = false;
      
      private var _interval:Number;
      
      private var _labelUnits:String;
      
      private var _userLabelUnits:String = null;
      
      private var _minorTickInterval:Number;
      
      private var _userMinorTickInterval:Number;
      
      private var _minorTickUnits:String;
      
      private var _userMinorTickUnits:String = null;
      
      public function DateTimeAxis()
      {
         this.UNIT_PROGRESSION = {
            "milliseconds":null,
            "seconds":"milliseconds",
            "minutes":"seconds",
            "hours":"minutes",
            "days":"hours",
            "weeks":"days",
            "months":"weeks",
            "years":"months"
         };
         this.dateRangeUtilities = new DateRangeUtilities();
         super();
         baseAtZero = false;
         autoAdjust = false;
         this.updatePropertyAccessors();
      }
      
      override public function set parseFunction(param1:Function) : void
      {
         super.parseFunction = param1;
      }
      
      override protected function get requiredDescribedFields() : uint
      {
         var _loc1_:uint = DataDescription.REQUIRED_MIN_MAX | DataDescription.REQUIRED_BOUNDED_VALUES;
         if(this._userDataUnits == null)
         {
            _loc1_ |= DataDescription.REQUIRED_MIN_INTERVAL;
         }
         return _loc1_;
      }
      
      override public function get unitSize() : Number
      {
         return this._unitSize;
      }
      
      public function get alignLabelsToUnits() : Boolean
      {
         return this._alignLabelsToUnits;
      }
      
      public function set alignLabelsToUnits(param1:Boolean) : void
      {
         if(param1 != this._alignLabelsToUnits)
         {
            this._alignLabelsToUnits = param1;
            invalidateCache();
            dispatchEvent(new Event("mappingChange"));
            dispatchEvent(new Event("axisChange"));
         }
      }
      
      public function set dataInterval(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 1;
         }
         this._dataInterval = this._userDataInterval = param1;
         if(this._userDataUnits != null)
         {
            this._unitSize = this.toMilli(this._dataInterval,this._userDataUnits);
         }
         else
         {
            this._unitSize = MILLISECONDS_IN_DAY;
         }
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get dataUnits() : String
      {
         return this._dataUnits;
      }
      
      public function set dataUnits(param1:String) : void
      {
         this._dataUnits = this._userDataUnits = param1;
         if(this._dataUnits != null)
         {
            this._unitSize = this.toMilli(this._dataInterval,this._dataUnits);
         }
         else
         {
            this._unitSize = MILLISECONDS_IN_DAY;
         }
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get disabledDays() : Array
      {
         return this._disabledDays;
      }
      
      public function set disabledDays(param1:Array) : void
      {
         this._disabledDays = param1;
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get disabledRanges() : Array
      {
         return this._disabledRanges;
      }
      
      public function set disabledRanges(param1:Array) : void
      {
         this._disabledRanges = param1;
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get displayLocalTime() : Boolean
      {
         return this._displayLocalTime;
      }
      
      public function set displayLocalTime(param1:Boolean) : void
      {
         this._displayLocalTime = param1;
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
         this.updatePropertyAccessors();
      }
      
      public function get interval() : Number
      {
         return this._interval;
      }
      
      public function set interval(param1:Number) : void
      {
         this._interval = Math.max(1,param1);
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get labelUnits() : String
      {
         return this._labelUnits;
      }
      
      public function set labelUnits(param1:String) : void
      {
         this._userLabelUnits = this._labelUnits = param1;
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get maximum() : Date
      {
         return new Date(computedMaximum);
      }
      
      public function set maximum(param1:Date) : void
      {
         if(param1 != null)
         {
            assignedMaximum = param1.getTime();
         }
         else
         {
            assignedMaximum = NaN;
         }
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get minimum() : Date
      {
         return new Date(computedMinimum);
      }
      
      public function set minimum(param1:Date) : void
      {
         if(param1 != null)
         {
            assignedMinimum = param1.getTime();
         }
         else
         {
            assignedMinimum = NaN;
         }
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get minorTickInterval() : Number
      {
         return this._userMinorTickInterval;
      }
      
      public function set minorTickInterval(param1:Number) : void
      {
         this._userMinorTickInterval = param1;
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get minorTickUnits() : String
      {
         return this._minorTickUnits;
      }
      
      public function set minorTickUnits(param1:String) : void
      {
         this._minorTickUnits = this._userMinorTickUnits = param1;
         invalidateCache();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      override public function transformCache(param1:Array, param2:String, param3:String) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         update();
         var _loc4_:Number = computedMaximum - computedMinimum - this.dateRangeUtilities.calculateDisabledRange(computedMinimum,computedMaximum);
         var _loc5_:int = param1.length;
         if(this.disabledRanges || this.disabledDays)
         {
            _loc7_ = 0;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc7_ = this.dateRangeUtilities.calculateDisabledRange(computedMinimum,param1[_loc6_][param2]);
               if(direction == "inverted")
               {
                  param1[_loc6_][param3] = 1 - (param1[_loc6_][param2] - _loc7_ - computedMinimum) / _loc4_;
               }
               else
               {
                  param1[_loc6_][param3] = (param1[_loc6_][param2] - _loc7_ - computedMinimum) / _loc4_;
               }
               _loc6_++;
            }
         }
         else
         {
            _loc8_ = computedMaximum - computedMinimum;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(direction == "inverted")
               {
                  param1[_loc6_][param3] = 1 - (param1[_loc6_][param2] - computedMinimum) / _loc8_;
               }
               else
               {
                  param1[_loc6_][param3] = (param1[_loc6_][param2] - computedMinimum) / _loc8_;
               }
               _loc6_++;
            }
         }
      }
      
      override protected function adjustMinMax(param1:Number, param2:Number) : void
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc19_:Array = null;
         var _loc20_:Number = NaN;
         var _loc3_:Number = this._interval;
         var _loc4_:Boolean = autoAdjust && isNaN(assignedMinimum);
         var _loc5_:Boolean = autoAdjust && isNaN(assignedMaximum);
         var _loc6_:Number = param1 - param2;
         var _loc7_:Boolean = false;
         var _loc10_:Number = !!isNaN(this._interval) ? Number(1) : Number(this._interval);
         if(this._userDataUnits == null)
         {
            _loc11_ = "years";
            this._dataInterval = 1;
            if(this._userLabelUnits != null && this._userLabelUnits != "")
            {
               _loc11_ = this._userLabelUnits;
            }
            _loc19_ = dataDescriptions;
            _loc20_ = Infinity;
            _loc13_ = _loc19_.length;
            _loc12_ = 0;
            while(_loc12_ < _loc13_)
            {
               _loc3_ = _loc19_[_loc12_].minInterval;
               if(!isNaN(_loc3_))
               {
                  _loc20_ = Math.min(_loc3_,_loc20_);
               }
               _loc12_++;
            }
            if(_loc20_ == Infinity || _loc20_ == 0)
            {
               this._unitSize = MILLISECONDS_IN_DAY;
               this._dataUnits = "days";
            }
            else
            {
               while(_loc11_ != null)
               {
                  this._unitSize = this.toMilli(1,_loc11_);
                  if(this._unitSize <= _loc20_)
                  {
                     break;
                  }
                  _loc11_ = this.UNIT_PROGRESSION[_loc11_];
               }
               if(_loc11_ == null)
               {
                  this._unitSize = MILLISECONDS_IN_DAY;
               }
               else
               {
                  this._dataUnits = _loc11_;
               }
            }
         }
         else
         {
            this._dataUnits = this._userDataUnits;
            this._dataInterval = !!isNaN(this._userDataInterval) ? Number(1) : Number(this._userDataInterval);
         }
         _loc11_ = "years";
         if(this._userLabelUnits != null && this._userLabelUnits != "")
         {
            _loc11_ = this._userLabelUnits;
         }
         var _loc14_:String = _loc11_;
         var _loc15_:Date = new Date(param1);
         var _loc16_:Date = new Date(param2);
         var _loc17_:Number = param1;
         var _loc18_:Number = param2;
         while(_loc11_ != null)
         {
            _loc14_ = _loc11_;
            if(_loc11_ == this._dataUnits)
            {
               _loc10_ = Math.max(_loc10_,this._dataInterval);
            }
            if(_loc4_)
            {
               _loc15_.setTime(param1);
               this.roundDateDown(_loc15_,_loc11_);
               _loc17_ = _loc15_.getTime();
            }
            if(_loc5_)
            {
               _loc16_.setTime(param2);
               this.roundDateUp(_loc16_,_loc11_);
               _loc18_ = _loc16_.getTime();
            }
            switch(_loc11_)
            {
               case "milliseconds":
                  _loc17_ = param1;
                  _loc18_ = param2;
                  break;
               case "seconds":
               case "hours":
               case "days":
               case "minutes":
               case "years":
                  _loc8_ = this.fromMilli(_loc15_.getTime(),_loc11_);
                  if((_loc9_ = this.fromMilli(_loc16_.getTime(),_loc11_)) - _loc8_ >= MINIMUM_LABEL_COUNT * _loc10_)
                  {
                     _loc7_ = true;
                  }
                  break;
               case "weeks":
                  if(this.fromMilli(_loc18_ - _loc17_,"weeks") >= MINIMUM_LABEL_COUNT * _loc10_)
                  {
                     _loc7_ = true;
                  }
                  break;
               case "months":
                  _loc8_ = _loc15_[this.monthP] + _loc15_[this.fullYearP] * 12;
                  if((_loc9_ = _loc16_[this.monthP] + _loc16_[this.fullYearP] * 12) - _loc8_ >= MINIMUM_LABEL_COUNT * _loc10_)
                  {
                     _loc7_ = true;
                  }
            }
            if(_loc7_)
            {
               break;
            }
            if(_loc11_ == this._userLabelUnits || this.UNIT_PROGRESSION[_loc11_] == null)
            {
               break;
            }
            if(_loc11_ == this._dataUnits)
            {
               if(_loc10_ <= this._dataInterval)
               {
                  break;
               }
               _loc10_ = this._dataInterval;
            }
            else
            {
               _loc11_ = this.UNIT_PROGRESSION[_loc11_];
            }
         }
         this._labelUnits = _loc14_;
         if(this._userMinorTickUnits != null && this._userMinorTickUnits != "")
         {
            this._minorTickInterval = !!isNaN(this._userMinorTickInterval) ? Number(1) : Number(this._userMinorTickInterval);
            this._minorTickUnits = this._userMinorTickUnits;
         }
         else if(_loc10_ == 1)
         {
            this._minorTickInterval = 1;
            this._minorTickUnits = this._labelUnits;
         }
         else
         {
            this._minorTickUnits = this._labelUnits;
            _loc12_ = 2;
            while(_loc12_ <= _loc10_)
            {
               if(_loc10_ % _loc12_ == 0)
               {
                  this._minorTickInterval = _loc10_ / _loc12_;
                  break;
               }
               _loc12_++;
            }
         }
         invalidateCache();
         if(_loc4_)
         {
            computedMinimum = _loc17_;
         }
         if(_loc5_)
         {
            computedMaximum = _loc18_;
         }
         computedInterval = _loc10_;
      }
      
      override protected function guardMinMax(param1:Number, param2:Number) : Array
      {
         if(isNaN(param1) || !isFinite(param1))
         {
            return [0,100];
         }
         if(isNaN(param2) || !isFinite(param2))
         {
            return [param1,param1 + 1];
         }
         if(param1 == param2)
         {
            return [param1,param1 + 1];
         }
         return null;
      }
      
      override public function filterCache(param1:Array, param2:String, param3:String) : void
      {
         var _loc4_:int = 0;
         super.filterCache(param1,param2,param3);
         var _loc5_:int = param1.length;
         if(this.disabledRanges || this.disabledDays)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc5_)
            {
               param1[_loc4_][param3] = !!this.dateRangeUtilities.isDisabled(param1[_loc4_][param2]) ? NaN : param1[_loc4_][param2];
               _loc4_++;
            }
         }
      }
      
      override public function mapCache(param1:Array, param2:String, param3:String, param4:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Number = NaN;
         var _loc10_:Date = null;
         var _loc5_:int = param1.length;
         var _loc9_:Function;
         if((_loc9_ = this.parseFunction) != null)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc7_ = param1[_loc6_];
               if((_loc10_ = _loc9_(_loc7_[param2])) != null)
               {
                  _loc7_[param3] = _loc10_.getTime();
               }
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
                  if((_loc7_ = param1[_loc6_])[param2])
                  {
                     _loc7_[param3] = Date.parse(_loc7_[param2]);
                  }
                  _loc6_++;
               }
            }
            else if(param1[_loc6_][param2] is XML || param1[_loc6_][param2] is XMLList)
            {
               _loc7_ = param1[_loc6_];
               if(isNaN(Number(_loc7_[param2].toString())))
               {
                  while(_loc6_ < _loc5_)
                  {
                     if((_loc7_ = param1[_loc6_])[param2])
                     {
                        _loc7_[param3] = Date.parse(_loc7_[param2].toString());
                     }
                     _loc6_++;
                  }
               }
               else
               {
                  while(_loc6_ < _loc5_)
                  {
                     if((_loc7_ = param1[_loc6_])[param2])
                     {
                        _loc7_[param3] = Number(_loc7_[param2].toString());
                     }
                     _loc6_++;
                  }
               }
            }
            else if(param1[_loc6_][param2] is Date)
            {
               while(_loc6_ < _loc5_)
               {
                  if((_loc7_ = param1[_loc6_])[param2])
                  {
                     _loc7_[param3] = _loc7_[param2].getTime();
                  }
                  _loc6_++;
               }
            }
            else
            {
               while(_loc6_ < _loc5_)
               {
                  if((_loc7_ = param1[_loc6_])[param2])
                  {
                     _loc7_[param3] = _loc7_[param2];
                  }
                  _loc6_++;
               }
            }
         }
      }
      
      override public function formatForScreen(param1:Object) : String
      {
         var _loc2_:Date = tmpDate;
         if(parseFunction != null)
         {
            _loc2_ = parseFunction(param1);
         }
         else if(param1 is String)
         {
            _loc2_.setTime(Date.parse(param1));
         }
         else if(param1 is Date)
         {
            _loc2_ = param1 as Date;
         }
         else
         {
            _loc2_.setTime(param1);
         }
         var _loc3_:Function = this.chooseLabelFunction();
         return _loc3_(_loc2_,null,this);
      }
      
      override protected function buildLabelCache() : Boolean
      {
         var _loc1_:int = 0;
         var _loc9_:Date = null;
         var _loc10_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Date = null;
         this.dateRangeUtilities.createDisabledRangeSet(this.disabledDays,this.disabledRanges,computedMinimum,computedMaximum);
         var _loc2_:Function = this.chooseLabelFunction();
         if(labelCache)
         {
            return false;
         }
         var _loc3_:Date = new Date();
         labelCache = [];
         var _loc4_:Number = computedMaximum - computedMinimum - this.dateRangeUtilities.calculateDisabledRange(computedMinimum,computedMaximum);
         var _loc5_:Number = this.toMilli(computedInterval,this._labelUnits);
         var _loc6_:Number = labelMinimum;
         var _loc7_:Number = labelMaximum + 0.000001;
         var _loc8_:Date = null;
         var _loc11_:Number = 0;
         var _loc12_:Number = 0;
         var _loc13_:Boolean = false;
         _loc9_ = new Date(_loc6_);
         if(this._alignLabelsToUnits)
         {
            this.roundDateUp(_loc9_,this._labelUnits);
         }
         _loc6_ = _loc9_.getTime();
         switch(this._labelUnits)
         {
            case "months":
               _loc14_ = _loc9_[this.monthP];
               while(_loc9_.getTime() <= _loc7_)
               {
                  _loc10_ = _loc9_.getTime();
                  if(this.disabledDays || this.disabledRanges)
                  {
                     if(_loc8_ != null)
                     {
                        _loc11_ = this.dateRangeUtilities.getDisabledRange(_loc8_.getTime() + 1,_loc10_,this._labelUnits);
                     }
                     else
                     {
                        _loc11_ = this.dateRangeUtilities.getDisabledRange(computedMinimum,_loc10_,this._labelUnits);
                     }
                     if(!this.dateRangeUtilities.isDisabled(_loc10_))
                     {
                        if(direction == "inverted")
                        {
                           labelCache.push(new AxisLabel(1 - (_loc10_ - computedMinimum - _loc11_) / _loc4_,new Date(_loc10_),_loc2_(_loc9_,_loc8_,this)));
                        }
                        else
                        {
                           labelCache.push(new AxisLabel((_loc10_ - computedMinimum - _loc11_) / _loc4_,new Date(_loc10_),_loc2_(_loc9_,_loc8_,this)));
                        }
                     }
                  }
                  else if(direction == "inverted")
                  {
                     labelCache.push(new AxisLabel(1 - (_loc10_ - computedMinimum) / _loc4_,new Date(_loc10_),_loc2_(_loc9_,_loc8_,this)));
                  }
                  else
                  {
                     labelCache.push(new AxisLabel((_loc10_ - computedMinimum) / _loc4_,new Date(_loc10_),_loc2_(_loc9_,_loc8_,this)));
                  }
                  if(_loc8_ == null)
                  {
                     _loc8_ = new Date(_loc10_);
                  }
                  else
                  {
                     _loc8_.setTime(_loc10_);
                  }
                  _loc14_ += computedInterval;
                  _loc9_.setTime(_loc6_);
                  _loc9_[this.monthP] = _loc14_;
                  if(_loc9_[this.monthP] != _loc14_ % 12)
                  {
                     _loc9_[this.dateP] = 0;
                  }
               }
               break;
            case "years":
               _loc15_ = _loc9_[this.fullYearP];
               while(_loc9_.getTime() <= _loc7_)
               {
                  _loc10_ = _loc9_.getTime();
                  if(this.disabledDays || this.disabledRanges)
                  {
                     if(_loc8_ != null)
                     {
                        _loc11_ = this.dateRangeUtilities.getDisabledRange(_loc8_.getTime() + 1,_loc10_,this._labelUnits);
                     }
                     else
                     {
                        _loc11_ = this.dateRangeUtilities.getDisabledRange(computedMinimum,_loc10_,this._labelUnits);
                     }
                     if(!this.dateRangeUtilities.isDisabled(_loc10_))
                     {
                        if(direction == "inverted")
                        {
                           labelCache.push(new AxisLabel(1 - (_loc10_ - computedMinimum - _loc11_) / _loc4_,new Date(_loc10_),_loc2_(_loc9_,_loc8_,this)));
                        }
                        else
                        {
                           labelCache.push(new AxisLabel((_loc10_ - computedMinimum - _loc11_) / _loc4_,new Date(_loc10_),_loc2_(_loc9_,_loc8_,this)));
                        }
                     }
                  }
                  else if(direction == "inverted")
                  {
                     labelCache.push(new AxisLabel(1 - (_loc10_ - computedMinimum) / _loc4_,new Date(_loc10_),_loc2_(_loc9_,_loc8_,this)));
                  }
                  else
                  {
                     labelCache.push(new AxisLabel((_loc10_ - computedMinimum) / _loc4_,new Date(_loc10_),_loc2_(_loc9_,_loc8_,this)));
                  }
                  if(_loc8_ == null)
                  {
                     _loc8_ = new Date(_loc10_);
                  }
                  else
                  {
                     _loc8_.setTime(_loc10_);
                  }
                  _loc15_ += computedInterval;
                  _loc9_.setTime(_loc6_);
                  _loc9_[this.fullYearP] = _loc15_;
                  if(_loc9_[this.fullYearP] != _loc15_)
                  {
                     _loc9_[this.dateP] = 0;
                  }
               }
               break;
            default:
               _loc16_ = _loc6_;
               while(_loc16_ <= _loc7_)
               {
                  _loc3_ = new Date(_loc16_);
                  if(this.disabledDays || this.disabledRanges)
                  {
                     if(_loc8_ != null)
                     {
                        _loc11_ = this.dateRangeUtilities.getDisabledRange(_loc8_.getTime() + 1,_loc16_,this._labelUnits);
                     }
                     else
                     {
                        _loc11_ = this.dateRangeUtilities.getDisabledRange(computedMinimum,_loc16_,this._labelUnits);
                     }
                     if(!this.dateRangeUtilities.isDisabled(_loc16_))
                     {
                        if(direction == "inverted")
                        {
                           labelCache.push(new AxisLabel(1 - (_loc16_ - computedMinimum - _loc11_) / _loc4_,_loc3_,_loc2_(_loc3_,_loc8_,this)));
                        }
                        else
                        {
                           labelCache.push(new AxisLabel((_loc16_ - computedMinimum - _loc11_) / _loc4_,_loc3_,_loc2_(_loc3_,_loc8_,this)));
                        }
                        if(!_loc13_)
                        {
                           _loc13_ = true;
                        }
                     }
                     _loc8_ = _loc3_;
                     if(!_loc13_)
                     {
                        _loc16_ += MILLISECONDS_IN_DAY;
                     }
                     else
                     {
                        _loc17_ = new Date(_loc16_);
                        if(this._labelUnits == "weeks")
                        {
                           _loc17_.dateUTC += 7 * computedInterval;
                           _loc16_ = _loc17_.time;
                        }
                        else if(this._labelUnits == "hours")
                        {
                           _loc17_.hoursUTC += computedInterval;
                           _loc16_ = _loc17_.time;
                        }
                        else if(this._labelUnits == "minutes")
                        {
                           _loc17_.minutesUTC += computedInterval;
                           _loc16_ = _loc17_.time;
                        }
                        else if(this._labelUnits == "seconds")
                        {
                           _loc17_.secondsUTC += computedInterval;
                           _loc16_ = _loc17_.time;
                        }
                        else if(this._labelUnits == "milliseconds")
                        {
                           _loc17_.millisecondsUTC += computedInterval;
                           _loc16_ = _loc17_.time;
                        }
                        else
                        {
                           _loc17_.dateUTC += computedInterval;
                           _loc16_ = _loc17_.time;
                        }
                     }
                  }
                  else
                  {
                     if(direction == "inverted")
                     {
                        labelCache.push(new AxisLabel(1 - (_loc16_ - computedMinimum) / _loc4_,_loc3_,_loc2_(_loc3_,_loc8_,this)));
                     }
                     else
                     {
                        labelCache.push(new AxisLabel((_loc16_ - computedMinimum) / _loc4_,_loc3_,_loc2_(_loc3_,_loc8_,this)));
                     }
                     _loc8_ = _loc3_;
                     _loc17_ = new Date(_loc16_);
                     if(this._labelUnits == "weeks")
                     {
                        _loc17_.dateUTC += 7 * computedInterval;
                        _loc16_ = _loc17_.time;
                     }
                     else if(this._labelUnits == "hours")
                     {
                        _loc17_.hoursUTC += computedInterval;
                        _loc16_ = _loc17_.time;
                     }
                     else if(this._labelUnits == "minutes")
                     {
                        _loc17_.minutesUTC += computedInterval;
                        _loc16_ = _loc17_.time;
                     }
                     else if(this._labelUnits == "seconds")
                     {
                        _loc17_.secondsUTC += computedInterval;
                        _loc16_ = _loc17_.time;
                     }
                     else if(this._labelUnits == "milliseconds")
                     {
                        _loc17_.millisecondsUTC += computedInterval;
                        _loc16_ = _loc17_.time;
                     }
                     else
                     {
                        _loc17_.dateUTC += computedInterval;
                        _loc16_ = _loc17_.time;
                     }
                  }
               }
         }
         return true;
      }
      
      override public function reduceLabels(param1:AxisLabel, param2:AxisLabel) : AxisLabelSet
      {
         var _loc7_:int = 0;
         var _loc10_:Number = NaN;
         var _loc3_:int = 0;
         switch(this._labelUnits)
         {
            case "months":
               _loc3_ = Math.floor((param2.value[this.fullYearP] * 12 + param2.value[this.monthP] - (param1.value[this.fullYearP] * 12 + param1.value[this.monthP])) / computedInterval) + 1;
               break;
            case "years":
               _loc3_ = Math.floor((param2.value[this.fullYearP] - param1.value[this.fullYearP]) / computedInterval) + 1;
               break;
            default:
               _loc10_ = this.toMilli(computedInterval,this._labelUnits);
               _loc3_ = Math.floor((param2.value.getTime() - param1.value.getTime()) / _loc10_) + 1;
         }
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc8_:int = labelCache.length;
         _loc7_ = 0;
         while(_loc7_ < _loc8_)
         {
            _loc4_.push(labelCache[_loc7_]);
            _loc5_.push(labelCache[_loc7_].position);
            _loc7_ += _loc3_;
         }
         if(computedInterval == this._minorTickInterval && _loc3_ > 1)
         {
            _loc7_ = _loc3_ - 1;
            while(_loc7_ >= 1)
            {
               if(_loc3_ % _loc7_ == 0)
               {
                  _loc3_ = _loc7_;
                  break;
               }
               _loc7_--;
            }
         }
         _loc8_ = minorTickCache.length;
         _loc7_ = 0;
         while(_loc7_ < _loc8_)
         {
            _loc6_.push(minorTickCache[_loc7_]);
            _loc7_ += _loc3_;
         }
         var _loc9_:AxisLabelSet;
         (_loc9_ = new AxisLabelSet()).labels = _loc4_;
         _loc9_.minorTicks = _loc6_;
         _loc9_.ticks = _loc5_;
         _loc9_.accurate = true;
         return _loc9_;
      }
      
      override protected function buildMinorTickCache() : Array
      {
         var _loc8_:Date = null;
         var _loc9_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Date = null;
         var _loc1_:Array = [];
         var _loc2_:Date = new Date();
         var _loc3_:Number = computedMaximum - computedMinimum - this.dateRangeUtilities.calculateDisabledRange(computedMinimum,computedMaximum);
         var _loc4_:Number = this.toMilli(this._minorTickInterval,this._minorTickUnits);
         var _loc5_:Number = labelMinimum;
         var _loc6_:Number = labelMaximum + 0.000001;
         var _loc7_:Date = null;
         var _loc10_:Number = 0;
         var _loc11_:Boolean = false;
         var _loc12_:Number = 0;
         _loc8_ = new Date(_loc5_);
         if(this._alignLabelsToUnits)
         {
            this.roundDateUp(_loc8_,this._minorTickUnits);
         }
         _loc5_ = _loc8_.getTime();
         switch(this._minorTickUnits)
         {
            case "months":
               _loc14_ = _loc8_[this.monthP];
               while(_loc8_.getTime() <= _loc6_)
               {
                  _loc9_ = _loc8_.getTime();
                  if(this.disabledDays || this.disabledRanges)
                  {
                     if(_loc7_ != null)
                     {
                        _loc12_ = this.dateRangeUtilities.getDisabledRange(_loc7_.getTime() + 1,_loc9_,this._minorTickUnits);
                     }
                     else
                     {
                        _loc12_ = this.dateRangeUtilities.getDisabledRange(computedMinimum,_loc9_,this._minorTickUnits);
                     }
                     if(!this.dateRangeUtilities.isDisabled(_loc9_))
                     {
                        _loc1_.push((_loc9_ - computedMinimum - _loc12_) / _loc3_);
                     }
                  }
                  else
                  {
                     _loc1_.push((_loc9_ - computedMinimum) / _loc3_);
                  }
                  if(_loc7_ == null)
                  {
                     _loc7_ = new Date(_loc9_);
                  }
                  else
                  {
                     _loc7_.setTime(_loc9_);
                  }
                  _loc14_ += this._minorTickInterval;
                  _loc8_.setTime(_loc5_);
                  _loc8_[this.monthP] = _loc14_;
                  if(_loc8_[this.monthP] != _loc14_ % 12)
                  {
                     _loc8_[this.dateP] = 0;
                  }
               }
               break;
            case "years":
               _loc15_ = _loc8_[this.fullYearP];
               while(_loc8_.getTime() <= _loc6_)
               {
                  _loc9_ = _loc8_.getTime();
                  if(this.disabledDays || this.disabledRanges)
                  {
                     if(_loc7_ != null)
                     {
                        _loc12_ = this.dateRangeUtilities.getDisabledRange(_loc7_.getTime() + 1,_loc9_,this._minorTickUnits);
                     }
                     else
                     {
                        _loc12_ = this.dateRangeUtilities.getDisabledRange(computedMinimum,_loc9_,this._minorTickUnits);
                     }
                     if(!this.dateRangeUtilities.isDisabled(_loc9_))
                     {
                        _loc1_.push((_loc9_ - computedMinimum - _loc12_) / _loc3_);
                     }
                  }
                  else
                  {
                     _loc1_.push((_loc9_ - computedMinimum) / _loc3_);
                  }
                  if(_loc7_ == null)
                  {
                     _loc7_ = new Date(_loc9_);
                  }
                  else
                  {
                     _loc7_.setTime(_loc9_);
                  }
                  _loc15_ += this._minorTickInterval;
                  _loc8_.setTime(_loc5_);
                  _loc8_[this.fullYearP] = _loc15_;
                  if(_loc8_[this.fullYearP] != _loc15_)
                  {
                     _loc8_[this.dateP] = 0;
                  }
               }
               break;
            default:
               _loc16_ = _loc5_;
               while(_loc16_ <= _loc6_)
               {
                  _loc2_ = new Date(_loc16_);
                  if(this.disabledDays || this.disabledRanges)
                  {
                     if(_loc7_ != null)
                     {
                        _loc12_ = this.dateRangeUtilities.getDisabledRange(_loc7_.getTime() + 1,_loc16_,this._minorTickUnits);
                     }
                     else
                     {
                        _loc12_ = this.dateRangeUtilities.getDisabledRange(computedMinimum,_loc16_,this._minorTickUnits);
                     }
                     if(!this.dateRangeUtilities.isDisabled(_loc16_))
                     {
                        _loc1_.push((_loc16_ - computedMinimum - _loc12_) / _loc3_);
                     }
                  }
                  else
                  {
                     _loc1_.push((_loc16_ - computedMinimum) / _loc3_);
                  }
                  _loc7_ = _loc2_;
                  _loc17_ = new Date(_loc16_);
                  if(this._minorTickUnits == "weeks")
                  {
                     _loc17_.dateUTC += 7 * this._minorTickInterval;
                     _loc16_ = _loc17_.time;
                  }
                  else if(this._minorTickUnits == "hours")
                  {
                     _loc17_.hoursUTC += this._minorTickInterval;
                     _loc16_ = _loc17_.time;
                  }
                  else if(this._minorTickUnits == "minutes")
                  {
                     _loc17_.minutesUTC += this._minorTickInterval;
                     _loc16_ = _loc17_.time;
                  }
                  else if(this._minorTickUnits == "seconds")
                  {
                     _loc17_.secondsUTC += this._minorTickInterval;
                     _loc16_ = _loc17_.time;
                  }
                  else if(this._minorTickUnits == "milliseconds")
                  {
                     _loc17_.millisecondsUTC += this._minorTickInterval;
                     _loc16_ = _loc17_.time;
                  }
                  else
                  {
                     _loc17_.dateUTC += this._minorTickInterval;
                     _loc16_ = _loc17_.time;
                  }
               }
         }
         return _loc1_;
      }
      
      private function roundDateUp(param1:Date, param2:String) : void
      {
         switch(param2)
         {
            case "seconds":
               if(param1[this.millisecondsP] > 0)
               {
                  param1[this.secondsP] += 1;
                  param1[this.millisecondsP] = 0;
               }
               break;
            case "minutes":
               if(param1[this.secondsP] > 0 || param1[this.millisecondsP] > 0)
               {
                  param1[this.minutesP] += 1;
                  param1[this.secondsP] = 0;
                  param1[this.millisecondsP] = 0;
               }
               break;
            case "hours":
               if(param1[this.minutesP] > 0 || param1[this.secondsP] > 0 || param1[this.millisecondsP] > 0)
               {
                  param1[this.hoursP] += 1;
                  param1[this.minutesP] = 0;
                  param1[this.secondsP] = 0;
                  param1[this.millisecondsP] = 0;
               }
               break;
            case "days":
               if(param1[this.hoursP] > 0 || param1[this.minutesP] > 0 || param1[this.secondsP] > 0 || param1[this.millisecondsP] > 0)
               {
                  param1[this.hoursP] = 0;
                  param1[this.minutesP] = 0;
                  param1[this.secondsP] = 0;
                  param1[this.millisecondsP] = 0;
                  param1[this.dateP] += 1;
               }
               break;
            case "weeks":
               param1[this.hoursP] = 0;
               param1[this.minutesP] = 0;
               param1[this.secondsP] = 0;
               param1[this.millisecondsP] = 0;
               if(param1[this.dayP] != 0)
               {
                  param1[this.dateP] += 7 - param1[this.dayP];
               }
               break;
            case "months":
               if(param1[this.dateP] > 1 || param1[this.hoursP] > 0 || param1[this.minutesP] > 0 || param1[this.secondsP] > 0 || param1[this.millisecondsP] > 0)
               {
                  param1[this.hoursP] = 0;
                  param1[this.minutesP] = 0;
                  param1[this.secondsP] = 0;
                  param1[this.millisecondsP] = 0;
                  param1[this.dateP] = 1;
                  param1[this.monthP] += 1;
               }
               break;
            case "years":
               if(param1[this.monthP] > 0 || param1[this.dateP] > 1 || param1[this.hoursP] > 0 || param1[this.minutesP] > 0 || param1[this.secondsP] > 0 || param1[this.millisecondsP] > 0)
               {
                  param1[this.hoursP] = 0;
                  param1[this.minutesP] = 0;
                  param1[this.secondsP] = 0;
                  param1[this.millisecondsP] = 0;
                  param1[this.dateP] = 1;
                  param1[this.monthP] = 0;
                  param1[this.fullYearP] += 1;
               }
         }
      }
      
      private function roundDateDown(param1:Date, param2:String) : void
      {
         switch(param2)
         {
            case "seconds":
               param1[this.secondsP] = 0;
               break;
            case "minutes":
               param1[this.secondsP] = 0;
               param1[this.millisecondsP] = 0;
               break;
            case "hours":
               param1[this.minutesP] = 0;
               param1[this.secondsP] = 0;
               param1[this.millisecondsP] = 0;
               break;
            case "days":
               param1[this.hoursP] = 0;
               param1[this.minutesP] = 0;
               param1[this.secondsP] = 0;
               param1[this.millisecondsP] = 0;
               break;
            case "weeks":
               param1[this.hoursP] = 0;
               param1[this.minutesP] = 0;
               param1[this.secondsP] = 0;
               param1[this.millisecondsP] = 0;
               if(param1[this.dayP] != 0)
               {
                  param1[this.dateP] -= param1[this.dayP];
               }
               break;
            case "months":
               param1[this.hoursP] = 0;
               param1[this.minutesP] = 0;
               param1[this.secondsP] = 0;
               param1[this.millisecondsP] = 0;
               param1[this.dateP] = 1;
               break;
            case "years":
               param1[this.hoursP] = 0;
               param1[this.minutesP] = 0;
               param1[this.secondsP] = 0;
               param1[this.millisecondsP] = 0;
               param1[this.dateP] = 1;
               param1[this.monthP] = 0;
         }
      }
      
      protected function formatYears(param1:Date, param2:Date, param3:DateTimeAxis) : String
      {
         var _loc4_:Number;
         return (_loc4_ = param1[this.fullYearP]).toString();
      }
      
      protected function formatMonths(param1:Date, param2:Date, param3:DateTimeAxis) : String
      {
         var _loc4_:Number = param1[this.fullYearP];
         return param1[this.monthP] + 1 + "/" + (_loc4_ % 100 < 10 ? "0" + _loc4_ % 100 : _loc4_ % 100);
      }
      
      protected function formatDays(param1:Date, param2:Date, param3:DateTimeAxis) : String
      {
         var _loc4_:Number = param1[this.fullYearP];
         return param1[this.monthP] + 1 + "/" + param1[this.dateP] + "/" + (_loc4_ % 100 < 10 ? "0" + _loc4_ % 100 : _loc4_ % 100);
      }
      
      protected function formatMinutes(param1:Date, param2:Date, param3:DateTimeAxis) : String
      {
         return param1[this.hoursP] + ":" + (param1[this.minutesP] < 10 ? "0" + param1[this.minutesP] : param1[this.minutesP]);
      }
      
      protected function formatSeconds(param1:Date, param2:Date, param3:DateTimeAxis) : String
      {
         return param1[this.hoursP] + ":" + (param1[this.minutesP] < 10 ? "0" + param1[this.minutesP] : param1[this.minutesP]) + ":" + (param1[this.secondsP] < 10 ? "0" + param1[this.secondsP] : param1[this.secondsP]);
      }
      
      protected function formatMilliseconds(param1:Date, param2:Date, param3:DateTimeAxis) : String
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:String = param1[this.hoursP] + ":" + (param1[this.minutesP] < 10 ? "0" + param1[this.minutesP] : param1[this.minutesP]) + ":" + (param1[this.secondsP] < 10 ? "0" + param1[this.secondsP] : param1[this.secondsP]);
         var _loc5_:String;
         if((_loc5_ = param1[this.millisecondsP].toString()).length < 4)
         {
            _loc7_ = _loc6_ = _loc5_.length;
            while(_loc7_ < 4)
            {
               _loc5_ = "0" + _loc5_;
               _loc7_++;
            }
         }
         return _loc4_ + _loc5_;
      }
      
      private function chooseLabelFunction() : Function
      {
         if(labelFunction != null)
         {
            return labelFunction;
         }
         switch(this._labelUnits)
         {
            case "years":
               return this.formatYears;
            case "months":
               return this.formatMonths;
            case "days":
            case "weeks":
               return this.formatDays;
            case "hours":
            case "minutes":
               return this.formatMinutes;
            case "seconds":
               return this.formatSeconds;
            case "milliseconds":
               return this.formatMilliseconds;
            default:
               return this.formatDays;
         }
      }
      
      private function toMilli(param1:Number, param2:String) : Number
      {
         switch(param2)
         {
            case "milliseconds":
               return param1;
            case "seconds":
               return param1 * 1000;
            case "minutes":
               return param1 * MILLISECONDS_IN_MINUTE;
            case "hours":
               return param1 * MILLISECONDS_IN_HOUR;
            case "weeks":
               return param1 * MILLISECONDS_IN_WEEK;
            case "months":
               return param1 * MILLISECONDS_IN_MONTH;
            case "years":
               return param1 * MILLISECONDS_IN_YEAR;
            case "days":
         }
         return param1 * MILLISECONDS_IN_DAY;
      }
      
      private function fromMilli(param1:Number, param2:String) : Number
      {
         switch(param2)
         {
            case "milliseconds":
               return param1;
            case "seconds":
               return param1 / 1000;
            case "minutes":
               return param1 / MILLISECONDS_IN_MINUTE;
            case "hours":
               return param1 / MILLISECONDS_IN_HOUR;
            case "days":
               return param1 / MILLISECONDS_IN_DAY;
            case "weeks":
               return param1 / MILLISECONDS_IN_WEEK;
            case "months":
               return param1 / MILLISECONDS_IN_MONTH;
            case "years":
               return param1 / MILLISECONDS_IN_YEAR;
            default:
               return NaN;
         }
      }
      
      private function updatePropertyAccessors() : void
      {
         if(this._displayLocalTime)
         {
            this.millisecondsP = "milliseconds";
            this.secondsP = "seconds";
            this.minutesP = "minutes";
            this.hoursP = "hours";
            this.dateP = "date";
            this.dayP = "day";
            this.monthP = "month";
            this.fullYearP = "fullYear";
         }
         else
         {
            this.millisecondsP = "millisecondsUTC";
            this.secondsP = "secondsUTC";
            this.minutesP = "minutesUTC";
            this.hoursP = "hoursUTC";
            this.dateP = "dateUTC";
            this.dayP = "dayUTC";
            this.monthP = "monthUTC";
            this.fullYearP = "fullYearUTC";
         }
      }
   }
}
