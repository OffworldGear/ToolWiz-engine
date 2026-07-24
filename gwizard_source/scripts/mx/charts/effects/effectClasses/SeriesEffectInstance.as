package mx.charts.effects.effectClasses
{
   import mx.charts.chartClasses.Series;
   import mx.core.mx_internal;
   import mx.effects.Tween;
   import mx.effects.effectClasses.TweenEffectInstance;
   import mx.events.TweenEvent;
   
   use namespace mx_internal;
   
   public class SeriesEffectInstance extends TweenEffectInstance
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var easingFunctionHolder:Function;
      
      private var _elementDuration:Number;
      
      private var _elementCount:Number;
      
      private var _playHeads:Array;
      
      private var _forward:Boolean = true;
      
      protected var targetSeries:Series;
      
      protected var interpolationValues:Array;
      
      public var elementOffset:Number = 20;
      
      public var minimumElementDuration:Number = 0;
      
      public var offset:Number = 0;
      
      public var type:String = "show";
      
      public function SeriesEffectInstance(param1:Object = null)
      {
         this.targetSeries = Series(param1);
         super(param1);
      }
      
      private static function LinearEase(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param2 + param3 * param1 / param4;
      }
      
      private static function sinEase(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param2 + param3 * (1 - Math.cos(Math.PI * param1 / param4)) / 2;
      }
      
      override public function onTweenUpdate(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc2_:Number = Number(param1);
         var _loc3_:int = this._elementCount;
         if(this._forward)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(this._playHeads[_loc4_] != 1)
               {
                  if((_loc5_ = (_loc2_ - this.offset - _loc4_ * this.elementOffset) / this._elementDuration) > 1)
                  {
                     this.interpolationValues[_loc4_] = 1;
                  }
                  else if(_loc5_ >= 0)
                  {
                     this.interpolationValues[_loc4_] = this.easingFunctionHolder(_loc5_,0,1,1);
                  }
                  else
                  {
                     this.interpolationValues[_loc4_] = 0;
                  }
                  this._playHeads[_loc4_] = _loc5_;
               }
               _loc4_++;
            }
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(this._playHeads[_loc4_] != 1)
               {
                  if((_loc5_ = (_loc2_ - this.offset - (_loc3_ - 1 - _loc4_) * this.elementOffset) / this._elementDuration) > 1)
                  {
                     this.interpolationValues[_loc4_] = 1;
                  }
                  else if(_loc5_ >= 0)
                  {
                     this.interpolationValues[_loc4_] = this.easingFunctionHolder(_loc5_,0,1,1);
                  }
                  else
                  {
                     this.interpolationValues[_loc4_] = 0;
                  }
                  this._playHeads[_loc4_] = _loc5_;
               }
               _loc4_++;
            }
         }
      }
      
      protected function beginTween(param1:int) : void
      {
         this.easingFunctionHolder = this.findEasingEquation(target,easingFunction);
         this._elementCount = param1;
         if(this.elementOffset < 0)
         {
            this._forward = false;
            this.elementOffset *= -1;
         }
         if(param1 > 0)
         {
            if(!isNaN(duration))
            {
               this._elementDuration = duration - Math.abs(this.elementOffset) * (param1 - 1);
            }
            if(isNaN(duration) || this._elementDuration < this.minimumElementDuration)
            {
               this._elementDuration = this.minimumElementDuration;
               duration = Math.abs(this.elementOffset) * (param1 - 1) + this._elementDuration;
            }
            duration += this.offset;
         }
         this.elementOffset /= duration;
         this._elementDuration /= duration;
         this.offset /= duration;
         this.interpolationValues = [];
         this._playHeads = [];
         tween = new Tween(this,0,1,duration);
         tween.addEventListener(TweenEvent.TWEEN_START,this.tweenEventHandler);
         tween.addEventListener(TweenEvent.TWEEN_UPDATE,this.tweenEventHandler);
         tween.addEventListener(TweenEvent.TWEEN_END,this.tweenEventHandler);
         tween.easingFunction = LinearEase;
      }
      
      private function findEasingEquation(param1:Object, param2:Object) : Function
      {
         var _loc3_:Object = null;
         if(param2 == null)
         {
            return sinEase;
         }
         if(param2 is Function)
         {
            return param2 as Function;
         }
         while(param1 != null)
         {
            _loc3_ = param1[param2];
            if(_loc3_ != null && _loc3_ is Function)
            {
               return _loc3_ as Function;
            }
            param1 = param1.parent;
         }
         return sinEase;
      }
      
      private function tweenEventHandler(param1:TweenEvent) : void
      {
         dispatchEvent(param1);
      }
   }
}
