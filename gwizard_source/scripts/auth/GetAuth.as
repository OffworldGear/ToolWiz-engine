package auth
{
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import mx.rpc.http.HTTPService;
   import session.Session;
   import utils.GWizCrypto;
   
   public class GetAuth
   {
      
      private static const log:ILogger = Log.getLogger("GetAuth");
       
      
      public function GetAuth()
      {
         super();
      }
      
      public static function invoke(param1:String, param2:String = "auth/") : void
      {
         var _loc3_:String = null;
         var _loc4_:HTTPService = null;
         if(AuthSession.isEnabled() && param1 != null)
         {
            _loc3_ = GWizCrypto.hash(param1,Session.sessionPassword,Session.sessionStrlen);
            (_loc4_ = AuthSession.createHttpService(param2 + _loc3_,getResult,getFault,"GET")).requestTimeout = 0;
            _loc4_.send(null);
         }
         else
         {
            log.debug("Error recovery needed in GetAuth");
         }
      }
      
      private static function getResult(param1:ResultEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:AuthProvList = null;
         log.debug("GetAuth result");
         log.debug("Result status code: " + param1.statusCode);
         if(param1.statusCode == 200)
         {
            _loc2_ = String(param1.result);
            log.debug("GetAuth resultStr = \'" + _loc2_ + "\'");
            _loc3_ = AuthProvList.parse(_loc2_);
         }
      }
      
      private static function getFault(param1:FaultEvent) : void
      {
         log.debug("GetAuth fault");
         log.debug("faultCode = " + param1.fault.faultCode + ", faultString =  " + param1.fault.faultString + ", faultDetail = " + param1.fault.faultDetail);
      }
   }
}
