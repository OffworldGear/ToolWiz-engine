package session
{
   import mx.rpc.http.HTTPService;
   import utils.GWizCrypto;
   
   public class CheckoutService
   {
       
      
      private var service:HTTPService;
      
      public function CheckoutService(param1:Function, param2:Function)
      {
         super();
         if(Session.isEnabled())
         {
            this.service = Session.createHttpService("checkout",param1,param2);
         }
      }
      
      public function invoke(param1:String, param2:String, param3:String, param4:String) : void
      {
         var _loc5_:XML = null;
         param1 = GWizCrypto.hash(param1,Session.sessionPassword,Session.sessionStrlen);
         if(Session.isEnabled() && param1 != null)
         {
            _loc5_ = <checkoutRequest>
						<userId>{param1}</userId>
						<appName>{param2}</appName> 
						<appVersion>{param3}</appVersion>
						<location>{param4}</location>
					</checkoutRequest>;
            this.service.send(_loc5_.toString());
         }
      }
   }
}
