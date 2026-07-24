package com.adobe.protocols.oauth2.event
{
   public interface IOAuth2Event
   {
       
      
      function get errorCode() : String;
      
      function set errorCode(param1:String) : void;
      
      function get errorMessage() : String;
      
      function set errorMessage(param1:String) : void;
   }
}
