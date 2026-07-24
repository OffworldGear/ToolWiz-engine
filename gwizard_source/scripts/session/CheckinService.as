package session
{
   import auth.AuthTest;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.rpc.http.HTTPService;
   
   public class CheckinService
   {
      
      private static const log:ILogger = Log.getLogger("CheckinService");
      
      public static var authTest:AuthTest = new AuthTest();
       
      
      private var service:HTTPService;
      
      public function CheckinService(param1:Function, param2:Function)
      {
         super();
         if(Session.isEnabled())
         {
            this.service = Session.createHttpService("checkin",param1,param2);
            this.service.requestTimeout = 0;
         }
      }
      
      public function invoke(param1:String, param2:String, param3:String, param4:String, param5:int) : void
      {
         var _loc6_:Object = null;
         var _loc7_:XML = null;
         var _loc8_:String = null;
         if(Session.isEnabled() && param1 != null)
         {
            if(false && Session.v4API)
            {
               (_loc6_ = new Object())["userId"] = param1;
               _loc6_["appName"] = param2;
               _loc6_["appVersion"] = param3;
               _loc6_["location"] = param4;
            }
            else
            {
               log.debug("********** Checkin Service Payload **********");
               log.debug("userId: \'" + param1 + "\'");
               log.debug("appName: \'" + param2 + "\'");
               log.debug("appVersion: \'" + param3 + "\'");
               log.debug("macAddr: \'" + param4 + "\'");
               log.debug("cookiesAuth: \'" + param5 + "\'");
               log.debug("*********************************************");
               _loc8_ = (_loc7_ = <checkinRequest> 
							<userId>{param1}</userId> 
							<appName>{param2}</appName> 
							<appVersion>{param3}</appVersion>
							<location>{param4}</location>
							<cookiesAuth>{param5}</cookiesAuth>
						</checkinRequest>).toString();
               log.debug(_loc8_);
               log.debug("*********************************************");
               this.service.send(_loc8_);
            }
         }
      }
   }
}
