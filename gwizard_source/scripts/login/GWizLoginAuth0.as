package login
{
   import com.adobe.protocols.oauth2.OAuth2;
   import com.adobe.protocols.oauth2.event.GetAccessTokenEvent;
   import com.adobe.protocols.oauth2.grant.AuthorizationCodeGrant;
   import com.adobe.protocols.oauth2.grant.IGrantType;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.media.StageWebView;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizLoginAuth0
   {
      
      private static const log:ILogger = Log.getLogger("GWizLoginAuth0");
      
      private static var _stageWebView:StageWebView;
      
      private static var _user:GWizUserData;
      
      private static var _loginCallback:Function;
      
      private static const CLIENT_ID:String = "xwFBLCakihSU8zA671vYlOdptNcH516n";
      
      private static const CLIENT_SECRET:String = "pGhrxZMBptlTqwp7HEBgSuPWe3A6GE0w0rjZg_SvB50qFZu2XAbS6C8fcBrnoMTW";
      
      public static const FACEBOOK_CONNECTION:String = "facebook";
      
      public static const GOOGLE_CONNECTION:String = "google-oauth2";
      
      public static const LINKEDIN_CONNECTION:String = "linkedin";
       
      
      public function GWizLoginAuth0(param1:StageWebView, param2:GWizUserData, param3:Function)
      {
         super();
         _stageWebView = param1;
         _user = param2;
         _loginCallback = param3;
      }
      
      public static function login(param1:String = "") : void
      {
         var _loc2_:OAuth2 = new OAuth2("https://cnccookbook.auth0.com/authorize","https://cnccookbook.auth0.com/oauth/token");
         var _loc3_:Object = new Object();
         if(param1 != "")
         {
            _loc3_.connection = param1;
         }
         var _loc4_:IGrantType = new AuthorizationCodeGrant(_stageWebView,CLIENT_ID,CLIENT_SECRET,"https://gwizardcore.firebaseapp.com/__/auth/handler","openid email",null,_loc3_);
         _loc2_.addEventListener(GetAccessTokenEvent.TYPE,GWizLoginAuth0.onGetAccessTokenFromAuth0);
         _loc2_.getAccessToken(_loc4_);
      }
      
      public static function logout(param1:String) : void
      {
         if(param1 == "")
         {
            return;
         }
         var _loc2_:URLRequest = new URLRequest("https://accounts.google.com/o/oauth2/revoke?token=" + param1);
         _loc2_.method = URLRequestMethod.GET;
         var _loc3_:URLLoader = new URLLoader();
         _loc3_.load(_loc2_);
      }
      
      public static function onGetAccessTokenFromAuth0(param1:GetAccessTokenEvent) : void
      {
         var _loc2_:URLRequest = null;
         var _loc3_:URLLoader = null;
         if(param1.errorCode == null && param1.errorMessage == null)
         {
            _user.token = param1.accessToken;
            log.debug("Your access token value is: " + _user.token);
            _loc2_ = new URLRequest("https://cnccookbook.auth0.com/userinfo/?access_token=" + param1.accessToken);
            _loc2_.method = URLRequestMethod.GET;
            _loc3_ = new URLLoader();
            _loc3_.addEventListener(Event.COMPLETE,httpRequestComplete);
            _loc3_.addEventListener(IOErrorEvent.IO_ERROR,httpRequestError);
            _loc3_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,httpRequestError);
            _loc3_.load(_loc2_);
         }
         else
         {
            log.debug("getAccessToken has failed");
            log.debug("Details: Code = " + param1.errorCode + ", message = " + param1.errorMessage);
         }
         _stageWebView.stage = null;
         _stageWebView = null;
      }
      
      private static function httpRequestError(param1:ErrorEvent) : void
      {
         log.debug("An error occured: " + param1.text);
      }
      
      private static function httpRequestComplete(param1:Event) : void
      {
         log.debug("httpRequestComplete");
         log.debug(param1.target.data);
         var _loc2_:Object = JSON.parse(param1.target.data);
         _user.email = _loc2_.email;
         _user.name = _loc2_.name;
         _user.provider = _loc2_.identities[0].provider;
         if(_loginCallback != null)
         {
            _loginCallback();
         }
      }
   }
}
