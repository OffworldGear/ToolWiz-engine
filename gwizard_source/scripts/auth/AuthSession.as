package auth
{
   import mx.rpc.http.HTTPService;
   import utils.GWizUtils;
   
   public class AuthSession
   {
      
      public static const apiVersion:String = "v4/";
      
      public static const v2Hash:String = "smoothbozonjetmonies";
      
      private static const v3Hash:String = "alloftheworldisastageandwearemerelyjammingonguitar";
      
      public static const sessionPassword:String = v3Hash;
      
      public static const sessionStrlen:int = 50;
       
      
      public function AuthSession()
      {
         super();
      }
      
      public static function isEnabled() : Boolean
      {
         return false && GWizUtils.debug;
      }
      
      public static function getBaseUrl() : String
      {
         return "http://localhost:8888";
      }
      
      public static function createHttpService(param1:String, param2:Function, param3:Function, param4:String) : HTTPService
      {
         var _loc5_:HTTPService;
         (_loc5_ = new HTTPService()).useProxy = false;
         _loc5_.method = param4;
         _loc5_.url = AuthSession.getBaseUrl() + "/" + AuthSession.apiVersion + param1;
         _loc5_.addEventListener("result",param2);
         _loc5_.addEventListener("fault",param3);
         _loc5_.resultFormat = "object";
         _loc5_.contentType = "application/json";
         _loc5_.headers = {"Accept":"application/json"};
         return _loc5_;
      }
   }
}
