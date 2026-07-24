package auth
{
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import mx.rpc.http.HTTPService;
   import session.Session;
   import utils.GWizCrypto;
   
   public class PostOrders
   {
      
      private static const log:ILogger = Log.getLogger("PostOrders");
       
      
      public function PostOrders()
      {
         super();
      }
      
      public static function invoke(param1:String, param2:ArrayCollection, param3:String = "auth/") : void
      {
         var _loc4_:String = null;
         var _loc5_:HTTPService = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         if(AuthSession.isEnabled() && param1 != null)
         {
            _loc4_ = GWizCrypto.hash(param1,Session.sessionPassword,Session.sessionStrlen);
            (_loc5_ = AuthSession.createHttpService(param3 + _loc4_,getResult,getFault,"POST")).requestTimeout = 0;
            _loc6_ = {
               "hash":"gjohnson@transenterix.com",
               "GWCSStart":"1/12/2018",
               "GWCSEnd":"5/15/3017",
               "GWCSTime":1000,
               "GWESStart":"1/12/2018",
               "GWESEnd":"5/15/3017",
               "GWESTime":1000,
               "OEM":""
            };
            _loc7_ = JSON.stringify(_loc6_);
            log.debug("jsonData = \'" + _loc7_ + "\'");
            _loc5_.send(_loc7_);
         }
         else
         {
            log.debug("Error recovery needed in PostOrders");
         }
      }
      
      private static function getResult(param1:ResultEvent) : void
      {
         var _loc2_:String = null;
         log.debug("PostOrders result");
         log.debug("Result status code: " + param1.statusCode);
         if(param1.statusCode == 200)
         {
            _loc2_ = String(param1.result);
            log.debug("resultStr = " + _loc2_);
         }
      }
      
      private static function getFault(param1:FaultEvent) : void
      {
         log.debug("PostOrders fault");
         log.debug("faultCode = " + param1.fault.faultCode + ", faultString =  " + param1.fault.faultString + ", faultDetail = " + param1.fault.faultDetail);
      }
   }
}
