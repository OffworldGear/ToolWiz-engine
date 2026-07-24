package utils
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class GWizJustASec
   {
       
      
      private var timerFunction:Function;
      
      public function GWizJustASec(param1:Function, param2:int = 1)
      {
         var _loc3_:Timer = null;
         super();
         this.timerFunction = param1;
         if(param1 != null)
         {
            param2 = Math.max(100,param2 * 1000);
            _loc3_ = new Timer(param2,1);
            _loc3_.addEventListener("timer",this.waitTimerHandler);
            _loc3_.start();
         }
      }
      
      private function waitTimerHandler(param1:TimerEvent) : void
      {
         this.timerFunction();
      }
   }
}
