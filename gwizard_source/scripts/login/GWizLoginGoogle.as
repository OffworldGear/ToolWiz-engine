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
   
   public class GWizLoginGoogle
   {
      
      private static const log:ILogger = Log.getLogger("GWizLoginGoogle");
      
      private static var _stageWebView:StageWebView;
      
      private static var _user:GWizUserData;
      
      private static var _loginCallback:Function;
      
      private static const CLIENT_ID:String = "184826275623-3f5bsh9e8kisvpaln5nb6a1f6qdgg95a.apps.googleusercontent.com";
      
      private static const CLIENT_SECRET:String = "wT4C0rDqcHEybxvwr0fDdtYK";
       
      
      public function GWizLoginGoogle(param1:StageWebView, param2:GWizUserData, param3:Function)
      {
         super();
         _stageWebView = param1;
         _user = param2;
         _loginCallback = param3;
      }
      
      public static function login() : void
      {
         var _loc1_:OAuth2 = new OAuth2("https://accounts.google.com/o/oauth2/auth","https://accounts.google.com/o/oauth2/token");
         var _loc2_:IGrantType = new AuthorizationCodeGrant(_stageWebView,CLIENT_ID,CLIENT_SECRET,"https://gwizardcore.firebaseapp.com/__/auth/handler","https://www.googleapis.com/auth/userinfo.email");
         _loc1_.addEventListener(GetAccessTokenEvent.TYPE,GWizLoginGoogle.onGetAccessTokenFromGoogle);
         _loc1_.getAccessToken(_loc2_);
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
      
      public static function onGetAccessTokenFromGoogle(param1:GetAccessTokenEvent) : void
      {
         var _loc2_:URLRequest = null;
         var _loc3_:URLLoader = null;
         if(param1.errorCode == null && param1.errorMessage == null)
         {
            _user.token = param1.accessToken;
            log.debug("Your access token value is: " + _user.token);
            _loc2_ = new URLRequest("https://www.googleapis.com/plus/v1/people/me?access_token=" + param1.accessToken);
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
         var _loc3_:Object = _loc2_.emails[0];
         _user.email = _loc3_.value;
         _user.name = _loc2_.displayName;
         if(_loginCallback != null)
         {
            _loginCallback();
         }
      }
   }
}
