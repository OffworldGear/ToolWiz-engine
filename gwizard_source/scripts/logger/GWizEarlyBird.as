package logger
{
   import mx.managers.ISystemManager;
   
   public class GWizEarlyBird
   {
       
      
      public function GWizEarlyBird()
      {
         super();
      }
      
      public static function init(param1:ISystemManager) : void
      {
         GWizLogger.setupLogging();
      }
   }
}
