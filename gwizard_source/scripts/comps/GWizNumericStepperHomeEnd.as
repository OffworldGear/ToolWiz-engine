package comps
{
   import configinfo.GWizConfigData;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.NumericStepper;
   import utils.ColorPalette;
   
   public class GWizNumericStepperHomeEnd extends NumericStepper
   {
      
      private static const log:ILogger = Log.getLogger("GWizNumericStepperHomeEnd");
      
      private static const ALERT_TEXT_COLOR:uint = ColorPalette.secondaryb1;
       
      
      public var stepBySizes:Boolean = false;
      
      public var stepByPct:Boolean = false;
      
      private var _redZone:Boolean = false;
      
      private var _redMax:Number = 1.0E-4;
      
      private var lastCheckVal:Number;
      
      public function GWizNumericStepperHomeEnd()
      {
         super();
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode != Keyboard.HOME)
         {
            if(param1.keyCode != Keyboard.END)
            {
               super.keyDownHandler(param1);
            }
         }
      }
      
      override public function changeValueByStep(param1:Boolean = true) : void
      {
         var _loc2_:ArrayCollection = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:Boolean = false;
         var _loc8_:Number = NaN;
         if(this.stepBySizes)
         {
            _loc2_ = GWizConfigData.DrillData;
            _loc3_ = this.value;
            _loc5_ = 0;
            while(_loc5_ < _loc2_.length)
            {
               _loc6_ = _loc2_.getItemAt(_loc5_);
               if(param1)
               {
                  if(_loc6_.inch > _loc3_ && Math.abs(_loc6_.inch - _loc3_) > 0.001)
                  {
                     _loc4_ = _loc6_.inch;
                     break;
                  }
               }
               else if(_loc6_.inch >= _loc3_)
               {
                  _loc5_--;
                  _loc7_ = false;
                  while(_loc5_ >= 0)
                  {
                     if((_loc6_ = _loc2_.getItemAt(_loc5_)).inch < _loc3_ && Math.abs(_loc6_.inch - _loc3_) > 0.003)
                     {
                        _loc4_ = _loc6_.inch;
                        break;
                     }
                     _loc5_--;
                  }
                  if(_loc5_ >= 0)
                  {
                     if((_loc6_ = _loc2_.getItemAt(_loc5_)).inch < _loc3_ && Math.abs(_loc6_.inch - _loc3_) > 0.003)
                     {
                        _loc4_ = _loc6_.inch;
                        break;
                     }
                     return;
                  }
                  return;
               }
               _loc5_++;
            }
            if(!isNaN(_loc4_))
            {
               this.value = _loc4_;
            }
         }
         else if(this.stepByPct)
         {
            _loc8_ = Math.max(this.value * 0.05,this.stepSize);
            if(param1)
            {
               this.value += _loc8_;
            }
            else
            {
               this.value -= _loc8_;
            }
         }
         else
         {
            super.changeValueByStep(param1);
         }
         this.checkRedZone();
      }
      
      public function set redZone(param1:Boolean) : void
      {
         this._redZone = param1;
         this.checkRedZone();
      }
      
      public function set redMax(param1:Number) : void
      {
         this._redMax = param1;
         this.checkRedZone();
      }
      
      public function checkRedZone() : void
      {
         if(this._redZone && this.value != this.lastCheckVal)
         {
            if(this.value < this._redMax)
            {
               this.setAlertTextColor(true);
            }
            else
            {
               this.setAlertTextColor(false);
            }
            this.lastCheckVal = this.value;
         }
      }
      
      public function setAlertTextColor(param1:Boolean) : void
      {
         if(param1)
         {
            this.setStyle("color",ALERT_TEXT_COLOR);
         }
         else
         {
            this.setStyle("color",0);
         }
      }
   }
}
