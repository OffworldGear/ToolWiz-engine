package com.adobe.protocols.oauth2.grant
{
   public class ResourceOwnerCredentialsGrant implements IGrantType
   {
       
      
      private var _clientId:String;
      
      private var _clientSecret:String;
      
      private var _username:String;
      
      private var _password:String;
      
      private var _scope:String;
      
      public function ResourceOwnerCredentialsGrant(param1:String, param2:String, param3:String, param4:String, param5:String = null)
      {
         super();
         this._clientId = param1;
         this._clientSecret = param2;
         this._username = param3;
         this._password = param4;
         this._scope = param5;
      }
      
      public function get clientId() : String
      {
         return this._clientId;
      }
      
      public function get clientSecret() : String
      {
         return this._clientSecret;
      }
      
      public function get username() : String
      {
         return this._username;
      }
      
      public function get password() : String
      {
         return this._password;
      }
      
      public function get scope() : String
      {
         return this._scope;
      }
   }
}
