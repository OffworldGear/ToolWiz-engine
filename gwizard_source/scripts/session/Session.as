package session
{
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.rpc.http.HTTPService;
   import utils.GWizUtils;
   
   public class Session
   {
      
      private static const log:ILogger = Log.getLogger("Session");
      
      private static const oldAPI:Boolean = false;
      
      private static const symbolicURL:Boolean = false;
      
      private static const v3API:Boolean = true;
      
      public static const v4API:Boolean = false;
      
      public static const v2Hash:String = "smoothbozonjetmonies";
      
      private static const v3Hash:String = "alloftheworldisastageandwearemerelyjammingonguitar";
      
      public static const sessionPassword:String = v3Hash;
      
      public static const sessionStrlen:int = 50;
      
      private static const apiV3ContentType:String = "text/xml; charset=utf-8";
      
      private static const apiV4ContentType:String = "text/plain; charset=utf-8";
       
      
      public function Session()
      {
         super();
      }
      
      public static function isEnabled() : Boolean
      {
         return true;
      }
      
      public static function getBaseUrl() : String
      {
         if(GWizUtils.debug && v4API)
         {
            return "http://localhost:8888";
         }
         if(v3API)
         {
            return "http://api.cnccookbook.com/api/v3";
         }
         if(symbolicURL && oldAPI)
         {
            return "http://api.cnccookbook.com/api/v2";
         }
         if(oldAPI)
         {
            return "http://184.72.62.67/api/v2";
         }
         return "http://50.18.57.101/api/v2";
      }
      
      public static function createHttpService(param1:String, param2:Function, param3:Function, param4:String = "POST") : HTTPService
      {
         var _loc5_:HTTPService;
         (_loc5_ = new HTTPService()).useProxy = false;
         _loc5_.method = param4;
         _loc5_.url = Session.getBaseUrl() + "/" + param1;
         log.debug("createHttpService.url = \'" + _loc5_.url);
         _loc5_.addEventListener("result",param2);
         _loc5_.addEventListener("fault",param3);
         _loc5_.resultFormat = "e4x";
         if(v4API)
         {
            _loc5_.contentType = apiV4ContentType;
         }
         else
         {
            _loc5_.contentType = apiV3ContentType;
         }
         return _loc5_;
      }
   }
}
