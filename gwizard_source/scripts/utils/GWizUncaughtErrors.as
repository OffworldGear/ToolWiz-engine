package utils
{
   import comps.GWizPopUpManager;
   import flash.events.ErrorEvent;
   import flash.events.UncaughtErrorEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizUncaughtErrors
   {
      
      private static const log:ILogger = Log.getLogger("GWizUncaughtErrors");
      
      public static var uncaughtErrorCC:GWizCallChain = new GWizCallChain();
       
      
      public function GWizUncaughtErrors()
      {
         super();
      }
      
      public function uncaughtErrorHandler(param1:UncaughtErrorEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Error = null;
         var _loc4_:ErrorEvent = null;
         param1.preventDefault();
         if(param1.error is Error)
         {
            _loc3_ = param1.error as Error;
            _loc2_ = "An Error was thrown and uncaught. id = " + _loc3_.errorID + ", msg = " + _loc3_.message + ", name = " + _loc3_.name + ", stack = " + _loc3_.getStackTrace();
         }
         else if(param1.error is ErrorEvent)
         {
            _loc4_ = param1.error as ErrorEvent;
            _loc2_ = "An ErrorEvent type was thrown and uncaught. type = " + _loc4_.type + ", text = " + _loc4_.text;
         }
         else
         {
            _loc2_ = "A non-Error, non-ErrorEvent type was thrown and uncaught";
         }
         GWizUtils.LogError(_loc2_);
         log.debug(_loc2_);
         uncaughtErrorCC.callChain(null);
         GWizPopUpManager.Show(_loc2_,"Error",GWizPopUpManager.ERROR);
         try
         {
            GATracker.logPageView("UncaughtError/" + _loc2_,"UncaughtError");
         }
         catch(error:Error)
         {
         }
      }
   }
}
