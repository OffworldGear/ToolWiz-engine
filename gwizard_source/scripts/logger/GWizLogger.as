package logger
{
   import flash.system.Capabilities;
   import mx.logging.Log;
   import mx.logging.LogEventLevel;
   import mx.logging.targets.LineFormattedTarget;
   import mx.logging.targets.TraceTarget;
   
   public class GWizLogger extends LineFormattedTarget
   {
      
      private static var loggingSetup:Boolean = false;
       
      
      public function GWizLogger()
      {
         super();
      }
      
      public static function setupLogging() : void
      {
         var _loc1_:TraceTarget = null;
         if(Capabilities.isDebugger && !loggingSetup)
         {
            _loc1_ = new TraceTarget();
            _loc1_.level = LogEventLevel.DEBUG;
            _loc1_.includeCategory = true;
            _loc1_.includeDate = false;
            _loc1_.includeLevel = true;
            _loc1_.includeTime = false;
            Log.addTarget(_loc1_);
            loggingSetup = true;
         }
      }
   }
}
