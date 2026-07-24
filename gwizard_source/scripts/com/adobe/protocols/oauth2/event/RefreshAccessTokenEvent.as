package com.adobe.protocols.oauth2.event
{
   import flash.events.Event;
   
   public class RefreshAccessTokenEvent extends Event implements IOAuth2Event
   {
      
      public static const TYPE:String = "refreshAccessToken";
       
      
      private var _errorCode:String;
      
      private var _errorMessage:String;
      
      private var _accessToken:String;
      
      private var _tokenType:String;
      
      private var _expiresIn:int;
      
      private var _refreshToken:String;
      
      private var _scope:String;
      
      private var _state:String;
      
      private var _response:Object;
      
      public function RefreshAccessTokenEvent(param1:Boolean = false, param2:Boolean = false)
      {
         super(TYPE,param1,param2);
      }
      
      public function parseAccessTokenResponse(param1:Object) : void
      {
         this._accessToken = param1.access_token;
         this._tokenType = param1.token_type;
         this._expiresIn = int(param1.expires_in);
         this._refreshToken = param1.refresh_token;
         this._scope = param1.scope;
         this._state = param1.state;
         this._response = param1;
      }
      
      override public function clone() : Event
      {
         return new GetAccessTokenEvent();
      }
      
      public function get errorCode() : String
      {
         return this._errorCode;
      }
      
      public function set errorCode(param1:String) : void
      {
         this._errorCode = param1;
      }
      
      public function get errorMessage() : String
      {
         return this._errorMessage;
      }
      
      public function set errorMessage(param1:String) : void
      {
         this._errorMessage = param1;
      }
      
      public function get accessToken() : String
      {
         return this._accessToken;
      }
      
      public function get tokenType() : String
      {
         return this._tokenType;
      }
      
      public function get expiresIn() : int
      {
         return this._expiresIn;
      }
      
      public function get refreshToken() : String
      {
         return this._refreshToken;
      }
      
      public function get scope() : String
      {
         return this._scope;
      }
      
      public function get state() : String
      {
         return this._state;
      }
      
      public function get response() : Object
      {
         return this._response;
      }
   }
}
