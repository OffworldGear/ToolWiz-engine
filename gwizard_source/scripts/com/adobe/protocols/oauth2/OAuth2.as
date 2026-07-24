package com.adobe.protocols.oauth2
{
   import com.adobe.protocols.oauth2.event.GetAccessTokenEvent;
   import com.adobe.protocols.oauth2.event.RefreshAccessTokenEvent;
   import com.adobe.protocols.oauth2.grant.AuthorizationCodeGrant;
   import com.adobe.protocols.oauth2.grant.IGrantType;
   import com.adobe.protocols.oauth2.grant.ImplicitGrant;
   import com.adobe.protocols.oauth2.grant.ResourceOwnerCredentialsGrant;
   import com.adobe.serialization.json.JSON;
   import com.adobe.serialization.json.JSONParseError;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.LocationChangeEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class OAuth2 extends EventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("OAuth2");
      
      public static var oAuthCompleteFcn:Function;
       
      
      private var grantType:IGrantType;
      
      private var authEndpoint:String;
      
      private var tokenEndpoint:String;
      
      public function OAuth2(param1:String, param2:String, param3:Object = null)
      {
         super();
         this.authEndpoint = param1;
         this.tokenEndpoint = param2;
      }
      
      public function getAccessToken(param1:IGrantType) : void
      {
         if(param1 is AuthorizationCodeGrant)
         {
            log.info("Initiating getAccessToken() with authorization code grant type workflow");
            this.getAccessTokenWithAuthorizationCodeGrant(param1 as AuthorizationCodeGrant);
         }
         else if(param1 is ImplicitGrant)
         {
            log.info("Initiating getAccessToken() with implicit grant type workflow");
            this.getAccessTokenWithImplicitGrant(param1 as ImplicitGrant);
         }
         else if(param1 is ResourceOwnerCredentialsGrant)
         {
            log.info("Initiating getAccessToken() with resource owner credentials grant type workflow");
            this.getAccessTokenWithResourceOwnerCredentialsGrant(param1 as ResourceOwnerCredentialsGrant);
         }
      }
      
      public function refreshAccessToken(param1:String, param2:String, param3:String, param4:String = null) : void
      {
         var refreshAccessTokenEvent:RefreshAccessTokenEvent = null;
         var onRefreshAccessTokenResult:Function = null;
         var onRefreshAccessTokenError:Function = null;
         var refreshToken:String = param1;
         var clientId:String = param2;
         var clientSecret:String = param3;
         var scope:String = param4;
         onRefreshAccessTokenResult = function(param1:Event):void
         {
            var response:Object = null;
            var event:Event = param1;
            try
            {
               response = JSON.decode(event.target.data);
               log.debug("Access token: " + response.access_token);
               refreshAccessTokenEvent.parseAccessTokenResponse(response);
            }
            catch(error:JSONParseError)
            {
               refreshAccessTokenEvent.errorCode = "com.adobe.serialization.json.JSONParseError";
               refreshAccessTokenEvent.errorMessage = "Error parsing output from refresh access token response";
            }
            dispatchEvent(refreshAccessTokenEvent);
         };
         onRefreshAccessTokenError = function(param1:Event):void
         {
            var error:Object = null;
            var event:Event = param1;
            log.error("Error encountered during refresh access token request: " + event);
            try
            {
               error = JSON.decode(event.target.data);
               refreshAccessTokenEvent.errorCode = error.error;
               refreshAccessTokenEvent.errorMessage = error.error_description;
            }
            catch(error:JSONParseError)
            {
               refreshAccessTokenEvent.errorCode = "Unknown";
               refreshAccessTokenEvent.errorMessage = "Error encountered during refresh access token request.  Unable to parse error message.";
            }
            dispatchEvent(refreshAccessTokenEvent);
         };
         refreshAccessTokenEvent = new RefreshAccessTokenEvent();
         var urlRequest:URLRequest = new URLRequest(this.tokenEndpoint);
         var urlLoader:URLLoader = new URLLoader();
         urlRequest.method = URLRequestMethod.POST;
         var urlVariables:URLVariables = new URLVariables();
         urlVariables.grant_type = OAuth2Const.GRANT_TYPE_REFRESH_TOKEN;
         urlVariables.client_id = clientId;
         urlVariables.client_secret = clientSecret;
         urlVariables.refresh_token = refreshToken;
         if(scope !== null)
         {
            urlVariables.scope = scope;
         }
         urlRequest.data = urlVariables;
         urlLoader.addEventListener(Event.COMPLETE,onRefreshAccessTokenResult);
         urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onRefreshAccessTokenError);
         urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onRefreshAccessTokenError);
         try
         {
            urlLoader.load(urlRequest);
         }
         catch(error:Error)
         {
            log.error("Error loading token endpoint \"" + tokenEndpoint + "\"");
         }
      }
      
      public function setLogLevel(param1:Object) : void
      {
      }
      
      private function getAccessTokenWithAuthorizationCodeGrant(param1:AuthorizationCodeGrant) : void
      {
         var getAccessTokenEvent:GetAccessTokenEvent = null;
         var startTime:Number = NaN;
         var onLocationChanging:Function = null;
         var onStageWebViewComplete:Function = null;
         var onStageWebViewError:Function = null;
         var authorizationCodeGrant:AuthorizationCodeGrant = param1;
         onLocationChanging = function(param1:LocationChangeEvent):void
         {
            var _loc3_:Object = null;
            var _loc4_:String = null;
            log.info("getAccessTokenWithAuthCode.onLocationChanging: Loading URL: " + param1.location);
            var _loc2_:* = param1.location.indexOf("error=") >= 0;
            if(!_loc2_ && param1.location.indexOf(authorizationCodeGrant.redirectUri) == 0 && param1.location.indexOf(OAuth2Const.RESPONSE_PROPERTY_AUTHORIZATION_CODE) > 0)
            {
               log.info("Redirect URI encountered (" + authorizationCodeGrant.redirectUri + ").  Extracting values from path.");
               param1.preventDefault();
               _loc3_ = extractQueryParams(param1.location);
               if((_loc4_ = _loc3_.code) != null)
               {
                  log.debug("Authorization code: " + _loc4_);
                  getAccessTokenWithAuthCode(_loc4_);
               }
               else
               {
                  log.error("Error encountered during authorization request");
                  getAccessTokenEvent.errorCode = _loc3_.error;
                  getAccessTokenEvent.errorMessage = _loc3_.error_description;
                  dispatchEvent(getAccessTokenEvent);
               }
            }
            else if(_loc2_)
            {
               if(oAuthCompleteFcn != null)
               {
                  oAuthCompleteFcn(true);
               }
            }
         };
         var getAccessTokenWithAuthCode:Function = function(param1:String):void
         {
            var onGetAccessTokenResult:Function = null;
            var onGetAccessTokenError:Function = null;
            var code:String = param1;
            onGetAccessTokenResult = function(param1:Event):void
            {
               var response:Object = null;
               var event:Event = param1;
               try
               {
                  response = JSON.decode(event.target.data);
                  log.debug("Access token: " + response.access_token);
                  getAccessTokenEvent.parseAccessTokenResponse(response);
               }
               catch(error:JSONParseError)
               {
                  getAccessTokenEvent.errorCode = "com.adobe.serialization.json.JSONParseError";
                  getAccessTokenEvent.errorMessage = "Error parsing output from access token response";
               }
               dispatchEvent(getAccessTokenEvent);
            };
            onGetAccessTokenError = function(param1:Event):void
            {
               var error:Object = null;
               var event:Event = param1;
               log.debug("Error encountered during access token request (getAccessTokenWithAuthCode.onGetAccessTokenError): " + event);
               try
               {
                  error = JSON.decode(event.target.data);
                  getAccessTokenEvent.errorCode = error.error;
                  getAccessTokenEvent.errorMessage = error.error_description;
               }
               catch(error:JSONParseError)
               {
                  getAccessTokenEvent.errorCode = "Unknown";
                  getAccessTokenEvent.errorMessage = "Error encountered during access token request.  Unable to parse error message.";
               }
               dispatchEvent(getAccessTokenEvent);
            };
            var urlRequest:URLRequest = new URLRequest(tokenEndpoint);
            var urlLoader:URLLoader = new URLLoader();
            urlRequest.method = URLRequestMethod.POST;
            var urlVariables:URLVariables = new URLVariables();
            urlVariables.grant_type = OAuth2Const.GRANT_TYPE_AUTHORIZATION_CODE;
            urlVariables.code = code;
            urlVariables.redirect_uri = authorizationCodeGrant.redirectUri;
            urlVariables.client_id = authorizationCodeGrant.clientId;
            urlVariables.client_secret = authorizationCodeGrant.clientSecret;
            urlRequest.data = urlVariables;
            urlLoader.addEventListener(Event.COMPLETE,onGetAccessTokenResult);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onGetAccessTokenError);
            urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onGetAccessTokenError);
            try
            {
               urlLoader.load(urlRequest);
            }
            catch(error:Error)
            {
               log.error("Error loading token endpoint \"" + tokenEndpoint + "\"");
            }
         };
         onStageWebViewComplete = function(param1:Event):void
         {
            var _loc2_:String = null;
            var _loc3_:String = null;
            if(authorizationCodeGrant.redirectUri == OAuth2Const.GOOGLE_INSTALLED_APPLICATION_REDIRECT_URI && param1.currentTarget.title.indexOf(OAuth2Const.RESPONSE_TYPE_AUTHORIZATION_CODE) > 0)
            {
               _loc2_ = param1.currentTarget.title.substring(param1.currentTarget.title.indexOf(OAuth2Const.RESPONSE_TYPE_AUTHORIZATION_CODE));
               _loc3_ = _loc2_.split("=")[1];
               log.debug("Authorization code extracted from page title: " + _loc3_);
               getAccessTokenWithAuthCode(_loc3_);
            }
            else
            {
               log.info("Auth URL loading complete after " + (new Date().time - startTime) + "ms");
               if(oAuthCompleteFcn != null)
               {
                  oAuthCompleteFcn();
               }
            }
         };
         onStageWebViewError = function(param1:ErrorEvent):void
         {
            log.error("Error occurred with StageWebView: " + param1);
            getAccessTokenEvent.errorCode = "STAGE_WEB_VIEW_ERROR";
            getAccessTokenEvent.errorMessage = "Error occurred with StageWebView";
            dispatchEvent(getAccessTokenEvent);
         };
         getAccessTokenEvent = new GetAccessTokenEvent();
         authorizationCodeGrant.stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGING,onLocationChanging);
         authorizationCodeGrant.stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGE,onLocationChanging);
         authorizationCodeGrant.stageWebView.addEventListener(Event.COMPLETE,onStageWebViewComplete);
         authorizationCodeGrant.stageWebView.addEventListener(ErrorEvent.ERROR,onStageWebViewError);
         startTime = new Date().time;
         log.info("Loading auth URL: " + authorizationCodeGrant.getFullAuthUrl(this.authEndpoint));
         authorizationCodeGrant.stageWebView.loadURL(authorizationCodeGrant.getFullAuthUrl(this.authEndpoint));
      }
      
      private function getAccessTokenWithImplicitGrant(param1:ImplicitGrant) : void
      {
         var getAccessTokenEvent:GetAccessTokenEvent = null;
         var onLocationChange:Function = null;
         var onStageWebViewError:Function = null;
         var implicitGrant:ImplicitGrant = param1;
         onLocationChange = function(param1:LocationChangeEvent):void
         {
            var _loc2_:Object = null;
            var _loc3_:String = null;
            log.info("Loading URL: " + param1.location);
            if(param1.location.indexOf(implicitGrant.redirectUri) == 0 && param1.location.indexOf(OAuth2Const.RESPONSE_PROPERTY_ACCESS_TOKEN) > 0)
            {
               log.info("Redirect URI encountered (" + implicitGrant.redirectUri + ").  Extracting values from path.");
               param1.preventDefault();
               _loc2_ = extractQueryParams(param1.location);
               _loc3_ = _loc2_.access_token;
               if(_loc3_ != null)
               {
                  log.debug("Access token: " + _loc3_);
                  getAccessTokenEvent.parseAccessTokenResponse(_loc2_);
                  dispatchEvent(getAccessTokenEvent);
               }
               else
               {
                  log.error("Error encountered during access token request");
                  getAccessTokenEvent.errorCode = _loc2_.error;
                  getAccessTokenEvent.errorMessage = _loc2_.error_description;
                  dispatchEvent(getAccessTokenEvent);
               }
            }
         };
         onStageWebViewError = function(param1:ErrorEvent):void
         {
            log.error("Error occurred with StageWebView: " + param1);
            getAccessTokenEvent.errorCode = "STAGE_WEB_VIEW_ERROR";
            getAccessTokenEvent.errorMessage = "Error occurred with StageWebView";
            dispatchEvent(getAccessTokenEvent);
         };
         getAccessTokenEvent = new GetAccessTokenEvent();
         implicitGrant.stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGING,onLocationChange);
         implicitGrant.stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGE,onLocationChange);
         implicitGrant.stageWebView.addEventListener(ErrorEvent.ERROR,onStageWebViewError);
         log.info("Loading auth URL: " + implicitGrant.getFullAuthUrl(this.authEndpoint));
         implicitGrant.stageWebView.loadURL(implicitGrant.getFullAuthUrl(this.authEndpoint));
      }
      
      private function getAccessTokenWithResourceOwnerCredentialsGrant(param1:ResourceOwnerCredentialsGrant) : void
      {
         var getAccessTokenEvent:GetAccessTokenEvent = null;
         var onGetAccessTokenResult:Function = null;
         var onGetAccessTokenError:Function = null;
         var resourceOwnerCredentialsGrant:ResourceOwnerCredentialsGrant = param1;
         onGetAccessTokenResult = function(param1:Event):void
         {
            var response:Object = null;
            var event:Event = param1;
            try
            {
               response = JSON.decode(event.target.data);
               log.debug("Access token: " + response.access_token);
               getAccessTokenEvent.parseAccessTokenResponse(response);
            }
            catch(error:JSONParseError)
            {
               getAccessTokenEvent.errorCode = "com.adobe.serialization.json.JSONParseError";
               getAccessTokenEvent.errorMessage = "Error parsing output from access token response";
            }
            dispatchEvent(getAccessTokenEvent);
         };
         onGetAccessTokenError = function(param1:Event):void
         {
            var error:Object = null;
            var event:Event = param1;
            log.error("Error encountered during access token request: " + event);
            try
            {
               error = JSON.decode(event.target.data);
               getAccessTokenEvent.errorCode = error.error;
               getAccessTokenEvent.errorMessage = error.error_description;
            }
            catch(error:JSONParseError)
            {
               getAccessTokenEvent.errorCode = "Unknown";
               getAccessTokenEvent.errorMessage = "Error encountered during access token request.  Unable to parse error message.";
            }
            dispatchEvent(getAccessTokenEvent);
         };
         getAccessTokenEvent = new GetAccessTokenEvent();
         var urlRequest:URLRequest = new URLRequest(this.tokenEndpoint);
         var urlLoader:URLLoader = new URLLoader();
         urlRequest.method = URLRequestMethod.POST;
         var urlVariables:URLVariables = new URLVariables();
         urlVariables.grant_type = OAuth2Const.GRANT_TYPE_RESOURCE_OWNER_CREDENTIALS;
         urlVariables.client_id = resourceOwnerCredentialsGrant.clientId;
         urlVariables.client_secret = resourceOwnerCredentialsGrant.clientSecret;
         urlVariables.username = resourceOwnerCredentialsGrant.username;
         urlVariables.password = resourceOwnerCredentialsGrant.password;
         if(resourceOwnerCredentialsGrant.scope !== null)
         {
            urlVariables.scope = resourceOwnerCredentialsGrant.scope;
         }
         urlRequest.data = urlVariables;
         urlLoader.addEventListener(Event.COMPLETE,onGetAccessTokenResult);
         urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onGetAccessTokenError);
         urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onGetAccessTokenError);
         try
         {
            urlLoader.load(urlRequest);
         }
         catch(error:Error)
         {
            log.error("Error loading token endpoint \"" + tokenEndpoint + "\"");
         }
      }
      
      private function extractQueryParams(param1:String) : Object
      {
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc2_:String = param1.indexOf("?") > 0 ? "?" : "#";
         var _loc3_:String = param1.split(_loc2_)[1];
         var _loc4_:Array = _loc3_.split("&");
         var _loc5_:Object = new Object();
         for each(_loc6_ in _loc4_)
         {
            _loc7_ = _loc6_.split("=");
            _loc5_[_loc7_[0]] = _loc7_[1];
         }
         return _loc5_;
      }
   }
}
