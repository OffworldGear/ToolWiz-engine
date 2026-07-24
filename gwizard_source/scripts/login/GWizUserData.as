package login
{
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizUserData
   {
      
      private static const log:ILogger = Log.getLogger("GWizUserData");
      
      private static var _instance:GWizUserData;
       
      
      private var _provider:String = "";
      
      private var _token:String = "";
      
      private var _email:String = "";
      
      public var name:String = "";
      
      public function GWizUserData()
      {
         super();
         if(this.email == "" && GWizLoginBar.LoginParm != "Guest")
         {
            this.email = GWizLoginBar.LoginParm;
         }
      }
      
      public static function instance() : GWizUserData
      {
         if(_instance == null)
         {
            _instance = new GWizUserData();
         }
         return _instance;
      }
      
      public function get provider() : String
      {
         return this._provider;
      }
      
      public function set provider(param1:String) : void
      {
         log.debug("SET provider : " + param1);
         this._provider = param1;
      }
      
      public function get token() : String
      {
         return this._token;
      }
      
      public function set token(param1:String) : void
      {
         log.debug("SET token : " + param1);
         this._token = param1;
      }
      
      public function set email(param1:String) : void
      {
      }
      
      public function get email() : String
      {
         return GWizLoginBar.LoginParm;
      }
   }
}
