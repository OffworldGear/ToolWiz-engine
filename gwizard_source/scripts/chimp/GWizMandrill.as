package chimp
{
   import configinfo.GWizSettings;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import mx.rpc.http.HTTPService;
   
   public class GWizMandrill
   {
      
      private static const log:ILogger = Log.getLogger("GWizMandrill");
      
      private static const HOME_OFFICE:String = "bob@cnccookbook.com";
      
      private static var msgPerSession:int = 0;
      
      public static var msgBody:String = "";
       
      
      public function GWizMandrill()
      {
         super();
      }
      
      public static function msg(param1:String, param2:String = "") : void
      {
         var _loc10_:Array = null;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:int = 0;
      }
      
      private static function httpResult(param1:ResultEvent) : void
      {
         log.debug("message: " + param1.message);
         log.debug("messageId: " + param1.messageId);
         log.debug("statusCode: " + param1.statusCode);
         log.debug("result: " + param1.result);
         GWizSettings.longTermConnectFails = 0;
      }
      
      private static function httpFault(param1:FaultEvent) : void
      {
         log.debug("messageId: " + param1.messageId);
         log.debug("message: " + param1.message);
      }
   }
}
