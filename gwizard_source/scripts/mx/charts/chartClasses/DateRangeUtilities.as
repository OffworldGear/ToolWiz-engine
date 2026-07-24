package mx.charts.chartClasses
{
   import mx.collections.ArrayCollection;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class DateRangeUtilities
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const DAYS_IN_WEEK:Number = 7;
      
      private static const MILLISECONDS_IN_MINUTE:Number = 1000 * 60;
      
      private static const MILLISECONDS_IN_HOUR:Number = 1000 * 60 * 60;
      
      private static const MILLISECONDS_IN_DAY:Number = 1000 * 60 * 60 * 24;
      
      private static const MILLISECONDS_IN_WEEK:Number = 1000 * 60 * 60 * 24 * 7;
      
      private static const MILLISECONDS_IN_MONTH:Number = 1000 * 60 * 60 * 24 * 30;
      
      private static const MILLISECONDS_IN_YEAR:Number = 1000 * 60 * 60 * 24 * 365;
      
      private static var disabledDayDifference:Number = 0;
       
      
      private var disabledRangeSet:Array;
      
      private var disabledDaySet:Array;
      
      private var minimum:Number;
      
      private var begin:Boolean = true;
      
      public function DateRangeUtilities()
      {
         this.disabledRangeSet = [];
         this.disabledDaySet = [];
         super();
      }
      
      mx_internal function createDisabledRangeSet(param1:Array, param2:Array, param3:Number, param4:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         this.disabledRangeSet = [];
         this.disabledDaySet = [];
         this.minimum = param3;
         if(param1)
         {
            _loc8_ = param1.length;
            _loc7_ = 0;
            while(_loc7_ < _loc8_)
            {
               if(this.disabledDaySet.indexOf(param1[_loc7_]) == -1 && param1[_loc7_] >= 0 && param1[_loc7_] <= 6)
               {
                  this.disabledDaySet.push(param1[_loc7_]);
               }
               _loc7_++;
            }
         }
         if(param2)
         {
            _loc8_ = param2.length;
            _loc7_ = 0;
            while(_loc7_ < _loc8_)
            {
               if(param2[_loc7_] is Date)
               {
                  _loc11_ = Date.parse(param2[_loc7_]);
                  _loc5_ = Math.max(param3,_loc11_);
                  _loc6_ = Math.min(param4,_loc11_ + MILLISECONDS_IN_DAY - 1);
                  if(_loc5_ < _loc6_)
                  {
                     this.disabledRangeSet.push(new Range(_loc5_,_loc6_));
                  }
               }
               else if(param2[_loc7_] is Object)
               {
                  if(!param2[_loc7_].rangeStart && param2[_loc7_].rangeEnd)
                  {
                     _loc5_ = param3;
                     if(param2[_loc7_].rangeEnd.getHours() == 0 && param2[_loc7_].rangeEnd.getMinutes() == 0 && param2[_loc7_].rangeEnd.getSeconds() == 0 && param2[_loc7_].rangeEnd.getMilliseconds() == 0)
                     {
                        _loc6_ = Math.min(param4,Date.parse(param2[_loc7_].rangeEnd) + MILLISECONDS_IN_DAY - 1);
                     }
                     else
                     {
                        _loc6_ = Math.min(param4,Date.parse(param2[_loc7_].rangeEnd) - 1);
                     }
                     if(_loc5_ < _loc6_)
                     {
                        this.disabledRangeSet.push(new Range(_loc5_,_loc6_));
                     }
                  }
                  else if(param2[_loc7_].rangeStart && !param2[_loc7_].rangeEnd)
                  {
                     _loc6_ = param4;
                     if((_loc5_ = Math.max(param3,Date.parse(param2[_loc7_].rangeStart))) < _loc6_)
                     {
                        this.disabledRangeSet.push(new Range(_loc5_,_loc6_));
                     }
                  }
                  else if(param2[_loc7_].rangeStart && param2[_loc7_].rangeEnd)
                  {
                     if(param2[_loc7_].rangeEnd.getHours() == 0 && param2[_loc7_].rangeEnd.getMinutes() == 0 && param2[_loc7_].rangeEnd.getSeconds() == 0 && param2[_loc7_].rangeEnd.getMilliseconds() == 0)
                     {
                        _loc6_ = Math.min(param4,Date.parse(param2[_loc7_].rangeEnd) + MILLISECONDS_IN_DAY - 1);
                     }
                     else
                     {
                        _loc6_ = Math.min(param4,Date.parse(param2[_loc7_].rangeEnd) - 1);
                     }
                     if((_loc5_ = Math.max(param3,Date.parse(param2[_loc7_].rangeStart))) < _loc6_)
                     {
                        this.disabledRangeSet.push(new Range(_loc5_,_loc6_));
                     }
                  }
               }
               _loc7_++;
            }
         }
         var _loc9_:Boolean = true;
         var _loc10_:ArrayCollection = new ArrayCollection(this.disabledRangeSet);
         _loc8_ = this.disabledRangeSet.length;
         _loc7_ = 0;
         while(_loc7_ < _loc8_)
         {
            _loc12_ = _loc10_.length;
            _loc13_ = 0;
            while(_loc13_ < _loc12_)
            {
               _loc9_ = false;
               if(_loc10_[_loc13_].rangeStart >= this.disabledRangeSet[_loc7_].rangeStart && _loc10_[_loc13_].rangeEnd <= this.disabledRangeSet[_loc7_].rangeEnd && _loc7_ != _loc13_)
               {
                  _loc10_[_loc13_].rangeStart = param3 - 1;
                  _loc9_ = true;
               }
               else if(_loc10_[_loc13_].rangeStart >= this.disabledRangeSet[_loc7_].rangeStart && _loc10_[_loc13_].rangeStart <= this.disabledRangeSet[_loc7_].rangeEnd && _loc10_[_loc13_].rangeEnd >= this.disabledRangeSet[_loc7_].rangeEnd && _loc7_ != _loc13_)
               {
                  _loc10_[_loc7_].rangeEnd = _loc10_[_loc13_].rangeEnd;
                  _loc10_[_loc13_].rangeStart = param3 - 1;
                  _loc9_ = true;
               }
               else if(_loc10_[_loc13_].rangeStart <= this.disabledRangeSet[_loc7_].rangeStart && _loc10_[_loc13_].rangeEnd >= this.disabledRangeSet[_loc7_].rangeStart && _loc10_[_loc13_].rangeEnd <= this.disabledRangeSet[_loc7_].rangeEnd && _loc7_ != _loc13_)
               {
                  _loc10_[_loc7_].rangeStart = _loc10_[_loc13_].rangeStart;
                  _loc10_[_loc13_].rangeStart = param3 - 1;
                  _loc9_ = true;
               }
               if(_loc9_)
               {
                  _loc14_ = _loc10_.length;
                  _loc15_ = 0;
                  while(_loc15_ < _loc14_)
                  {
                     if(_loc10_[_loc15_].rangeStart < param3)
                     {
                        _loc10_.removeItemAt(_loc15_);
                        _loc12_ = _loc14_ = _loc10_.length;
                     }
                     else
                     {
                        _loc15_++;
                     }
                  }
                  this.disabledRangeSet = [];
                  _loc14_ = _loc10_.length;
                  _loc15_ = 0;
                  while(_loc15_ < _loc14_)
                  {
                     this.disabledRangeSet.push(_loc10_.getItemAt(_loc15_));
                     _loc15_++;
                  }
                  _loc13_ = 0;
               }
               else
               {
                  _loc13_++;
               }
            }
            if(_loc9_)
            {
               _loc7_ = 0;
            }
            else
            {
               _loc7_++;
            }
            _loc8_ = this.disabledRangeSet.length;
         }
         this.disabledRangeSet.sortOn(["rangeStart","rangeEnd"],[Array.NUMERIC]);
      }
      
      mx_internal function calculateDisabledRange(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = NaN;
         var _loc5_:Range = null;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc4_:Number = 0;
         var _loc6_:Date;
         (_loc6_ = new Date(param1)).setHours(0,0,0,0);
         _loc3_ = _loc6_.getTime();
         _loc3_ += MILLISECONDS_IN_DAY;
         var _loc7_:int = 0;
         if(this.disabledDaySet.length > 0)
         {
            if(this.disabledDaySet.indexOf(_loc6_.day) != -1)
            {
               _loc5_ = new Range(param1,_loc3_ - 1);
               _loc4_ = this.calculateActualDisabledRange(_loc5_,_loc4_);
            }
            _loc9_ = _loc3_;
            _loc8_ = this.disabledDaySet.length;
            _loc7_ = 0;
            while(_loc7_ < _loc8_)
            {
               _loc10_ = this.disabledDaySet[_loc7_];
               _loc3_ = _loc9_;
               while(_loc3_ < param2)
               {
                  if((_loc11_ = (_loc6_ = new Date(_loc3_)).day) == _loc10_)
                  {
                     _loc5_ = new Range(_loc3_,_loc3_ + MILLISECONDS_IN_DAY - 1);
                     _loc4_ = this.calculateActualDisabledRange(_loc5_,_loc4_);
                     _loc3_ += MILLISECONDS_IN_WEEK;
                  }
                  else if(_loc11_ < _loc10_)
                  {
                     _loc12_ = _loc10_ - _loc11_;
                     _loc3_ += _loc12_ * MILLISECONDS_IN_DAY;
                     if(_loc3_ < param2)
                     {
                        _loc5_ = new Range(_loc3_,_loc3_ + MILLISECONDS_IN_DAY - 1);
                        _loc4_ = this.calculateActualDisabledRange(_loc5_,_loc4_);
                     }
                     _loc3_ += MILLISECONDS_IN_WEEK;
                  }
                  else
                  {
                     _loc12_ = DAYS_IN_WEEK - _loc11_;
                     _loc3_ += (_loc12_ + _loc10_) * MILLISECONDS_IN_DAY;
                     if(_loc3_ < param2)
                     {
                        _loc5_ = new Range(_loc3_,_loc3_ + MILLISECONDS_IN_DAY - 1);
                        _loc4_ = this.calculateActualDisabledRange(_loc5_,_loc4_);
                     }
                     _loc3_ += MILLISECONDS_IN_WEEK;
                  }
               }
               if(_loc3_ == param2)
               {
                  if((_loc11_ = (_loc6_ = new Date(_loc3_)).day) == _loc10_)
                  {
                     _loc5_ = new Range(_loc3_,_loc3_ + MILLISECONDS_IN_DAY - 1);
                     _loc4_ = this.calculateActualDisabledRange(_loc5_,_loc4_);
                  }
               }
               _loc7_++;
            }
         }
         _loc8_ = this.disabledRangeSet.length;
         _loc7_ = 0;
         while(_loc7_ < _loc8_)
         {
            if(param2 <= this.disabledRangeSet[_loc7_].rangeStart)
            {
               break;
            }
            _loc4_ += this.disabledRangeSet[_loc7_].rangeEnd - this.disabledRangeSet[_loc7_].rangeStart;
            _loc7_++;
         }
         return _loc4_;
      }
      
      private function calculateActualDisabledRange(param1:Range, param2:Number) : Number
      {
         var _loc5_:int = 0;
         var _loc3_:Boolean = false;
         var _loc4_:int;
         if((_loc4_ = this.disabledRangeSet.length) != 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               if(param1.rangeStart >= this.disabledRangeSet[_loc5_].rangeStart && param1.rangeEnd <= this.disabledRangeSet[_loc5_].rangeEnd)
               {
                  _loc3_ = true;
                  break;
               }
               if(param1.rangeStart >= this.disabledRangeSet[_loc5_].rangeStart && param1.rangeStart < this.disabledRangeSet[_loc5_].rangeEnd && param1.rangeEnd > this.disabledRangeSet[_loc5_].rangeEnd)
               {
                  param1.rangeStart = this.disabledRangeSet[_loc5_].rangeEnd;
                  _loc5_ = 0;
               }
               else if(param1.rangeStart <= this.disabledRangeSet[_loc5_].rangeStart && param1.rangeEnd > this.disabledRangeSet[_loc5_].rangeStart && param1.rangeEnd < this.disabledRangeSet[_loc5_].rangeEnd)
               {
                  param1.rangeEnd = this.disabledRangeSet[_loc5_].rangeStart;
                  _loc5_ = 0;
               }
               else
               {
                  _loc5_++;
               }
            }
         }
         if(!_loc3_)
         {
            param2 += param1.rangeEnd - param1.rangeStart;
         }
         _loc3_ = false;
         return param2;
      }
      
      mx_internal function getDisabledRange(param1:Number, param2:Number, param3:String) : Number
      {
         var _loc4_:Number = NaN;
         var _loc7_:Date = null;
         var _loc8_:Number = NaN;
         var _loc10_:Object = null;
         var _loc12_:Range = null;
         var _loc5_:Number = 0;
         var _loc6_:Boolean = false;
         _loc4_ = param1;
         switch(param3)
         {
            case "years":
               _loc8_ = MILLISECONDS_IN_YEAR;
               break;
            case "months":
               _loc8_ = MILLISECONDS_IN_MONTH;
               break;
            default:
               _loc8_ = MILLISECONDS_IN_DAY;
         }
         if(this.begin)
         {
            if(Math.abs(param1 - this.minimum) < _loc8_)
            {
               disabledDayDifference = 0;
               this.begin = false;
            }
         }
         else
         {
            this.begin = true;
         }
         if(this.disabledDaySet)
         {
            while(_loc4_ < param2)
            {
               _loc7_ = new Date(_loc4_);
               if(this.disabledDaySet.indexOf(_loc7_.day) != -1)
               {
                  _loc12_ = new Range(_loc4_,Math.min(_loc4_ + MILLISECONDS_IN_DAY - 1,param2));
                  disabledDayDifference = this.calculateActualDisabledRange(_loc12_,disabledDayDifference);
               }
               _loc4_ += MILLISECONDS_IN_DAY;
            }
         }
         _loc5_ = disabledDayDifference;
         var _loc9_:int = this.disabledRangeSet.length;
         var _loc11_:int = 0;
         while(_loc11_ < _loc9_)
         {
            if(param2 <= this.disabledRangeSet[_loc11_].rangeStart)
            {
               break;
            }
            _loc5_ += this.disabledRangeSet[_loc11_].rangeEnd - this.disabledRangeSet[_loc11_].rangeStart;
            _loc11_++;
         }
         return _loc5_;
      }
      
      mx_internal function isDisabled(param1:Number) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = this.disabledRangeSet.length;
         var _loc4_:Date = new Date(param1);
         if(this.disabledDaySet)
         {
            if(this.disabledDaySet.indexOf(_loc4_.day) != -1)
            {
               return true;
            }
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            if(param1 >= this.disabledRangeSet[_loc5_].rangeStart && param1 <= this.disabledRangeSet[_loc5_].rangeEnd)
            {
               _loc2_ = true;
               break;
            }
            if(param1 < this.disabledRangeSet[_loc5_].rangeStart)
            {
               break;
            }
            _loc5_++;
         }
         return _loc2_;
      }
   }
}

import mx.core.mx_internal;

use namespace mx_internal;

class Range
{
   
   mx_internal static const VERSION:String = "4.6.0.23201";
    
   
   public var rangeStart:Number;
   
   public var rangeEnd:Number;
   
   function Range(param1:Number, param2:Number)
   {
      super();
      this.rangeStart = param1;
      this.rangeEnd = param2;
   }
}
