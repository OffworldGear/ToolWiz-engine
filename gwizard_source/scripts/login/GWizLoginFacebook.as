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
   
   public class GWizLoginFacebook
   {
      
      private static const log:ILogger = Log.getLogger("GWizLoginFacebook");
      
      private static var _stageWebView:StageWebView;
      
      private static var _user:GWizUserData;
      
      private static var _loginCallback:Function;
      
      private static const CLIENT_ID:String = "329301134069361";
      
      private static const CLIENT_SECRET:String = "cae6d69c363796e8de499b50006de461";
       
      
      public function GWizLoginFacebook(param1:StageWebView, param2:GWizUserData, param3:Function)
      {
         super();
         _stageWebView = param1;
         _user = param2;
         _loginCallback = param3;
      }
      
      public static function login() : void
      {
         var _loc1_:OAuth2 = new OAuth2("https://www.facebook.com/dialog/oauth","https://graph.facebook.com/v2.7/oauth/access_token");
         var _loc2_:IGrantType = new AuthorizationCodeGrant(_stageWebView,CLIENT_ID,CLIENT_SECRET,"https://gwizardcore.firebaseapp.com/__/auth/handler","public_profile,email");
         _loc1_.addEventListener(GetAccessTokenEvent.TYPE,GWizLoginFacebook.onGetAccessTokenFromFacebook);
         _loc1_.getAccessToken(_loc2_);
      }
      
      public static function logout(param1:String) : void
      {
         var httpRequestComplete:Function = null;
         var httpRequestError:Function = null;
         var accessToken:String = param1;
         httpRequestComplete = function(param1:Event):void
         {
            log.debug("Logout successful");
         };
         httpRequestError = function(param1:ErrorEvent):void
         {
            log.debug("A Logout error occured: " + param1.text);
         };
         if(accessToken == "")
         {
            return;
         }
         var request:URLRequest = new URLRequest("https://www.facebook.com/logout.php?next=https://gwizardcore.firebaseapp.com/__/auth/handler&access_token=" + accessToken);
         request.method = URLRequestMethod.POST;
         log.debug("logout URL = " + "https://www.facebook.com/logout.php?next=https://gwizardcore.firebaseapp.com/__/auth/handler&access_token=" + accessToken);
         var requestor:URLLoader = new URLLoader();
         requestor.addEventListener(Event.COMPLETE,httpRequestComplete);
         requestor.addEventListener(IOErrorEvent.IO_ERROR,httpRequestError);
         requestor.addEventListener(SecurityErrorEvent.SECURITY_ERROR,httpRequestError);
         requestor.load(request);
      }
      
      public static function onGetAccessTokenFromFacebook(param1:GetAccessTokenEvent) : void
      {
         var _loc2_:URLRequest = null;
         var _loc3_:URLLoader = null;
         if(param1.errorCode == null && param1.errorMessage == null)
         {
            _user.token = param1.accessToken;
            log.debug("Your access token value is: " + _user.token);
            _loc2_ = new URLRequest("https://graph.facebook.com/me?fields=email,id,name&redirect=false&access_token=" + param1.accessToken);
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
         if(_loginCallback != null)
         {
            _loginCallback();
         }
      }
   }
}
