package mx.managers
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import mx.core.ISWFBridgeGroup;
   
   public interface IMarshalSystemManager
   {
       
      
      function get swfBridgeGroup() : ISWFBridgeGroup;
      
      function set swfBridgeGroup(param1:ISWFBridgeGroup) : void;
      
      function addChildBridge(param1:IEventDispatcher, param2:DisplayObject) : void;
      
      function removeChildBridge(param1:IEventDispatcher) : void;
      
      function dispatchEventFromSWFBridges(param1:Event, param2:IEventDispatcher = null, param3:Boolean = false, param4:Boolean = false) : void;
      
      function useSWFBridge() : Boolean;
      
      function addChildToSandboxRoot(param1:String, param2:DisplayObject) : void;
      
      function removeChildFromSandboxRoot(param1:String, param2:DisplayObject) : void;
      
      function isDisplayObjectInABridgedApplication(param1:DisplayObject) : Boolean;
      
      function dispatchActivatedWindowEvent(param1:DisplayObject) : void;
   }
}
