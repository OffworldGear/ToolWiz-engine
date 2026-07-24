package com.adobe.protocols.oauth2.grant
{
   import com.adobe.protocols.oauth2.OAuth2Const;
   import flash.media.StageWebView;
   
   public class AuthorizationCodeGrant implements IGrantType
   {
       
      
      private var _stageWebView:StageWebView;
      
      private var _clientId:String;
      
      private var _clientSecret:String;
      
      private var _redirectUri:String;
      
      private var _scope:String;
      
      private var _state:Object;
      
      private var _queryParams:Object;
      
      public function AuthorizationCodeGrant(param1:StageWebView, param2:String, param3:String, param4:String, param5:String = null, param6:Object = null, param7:Object = null)
      {
         super();
         this._stageWebView = param1;
         this._clientId = param2;
         this._clientSecret = param3;
         this._redirectUri = param4;
         this._scope = param5;
         this._state = param6;
         this._queryParams = param7;
      }
      
      public function get stageWebView() : StageWebView
      {
         return this._stageWebView;
      }
      
      public function get clientId() : String
      {
         return this._clientId;
      }
      
      public function get clientSecret() : String
      {
         return this._clientSecret;
      }
      
      public function get redirectUri() : String
      {
         return this._redirectUri;
      }
      
      public function get scope() : String
      {
         return this._scope;
      }
      
      public function get state() : Object
      {
         return this._state;
      }
      
      public function get queryParams() : Object
      {
         return this._queryParams;
      }
      
      public function getFullAuthUrl(param1:String) : String
      {
         var _loc3_:* = null;
         var _loc2_:String = param1 + "?response_type=" + OAuth2Const.RESPONSE_TYPE_AUTHORIZATION_CODE + "&client_id=" + this.clientId + "&redirect_uri=" + this.redirectUri;
         if(this.scope != null && this.scope.length > 0)
         {
            _loc2_ += "&scope=" + this.scope;
         }
         if(this.state != null)
         {
            _loc2_ += "&state=" + this.state;
         }
         if(this.queryParams != null)
         {
            for(_loc3_ in this.queryParams)
            {
               _loc2_ += "&" + _loc3_ + "=" + this.queryParams[_loc3_];
            }
         }
         return _loc2_;
      }
   }
}
