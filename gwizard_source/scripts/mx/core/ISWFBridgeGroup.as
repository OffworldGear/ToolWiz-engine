package mx.core
{
   import flash.events.IEventDispatcher;
   
   public interface ISWFBridgeGroup extends IEventDispatcher
   {
       
      
      function get parentBridge() : IEventDispatcher;
      
      function set parentBridge(param1:IEventDispatcher) : void;
      
      function addChildBridge(param1:IEventDispatcher, param2:ISWFBridgeProvider) : void;
      
      function removeChildBridge(param1:IEventDispatcher) : void;
      
      function getChildBridgeProvider(param1:IEventDispatcher) : ISWFBridgeProvider;
      
      function getChildBridges() : Array;
      
      function containsBridge(param1:IEventDispatcher) : Boolean;
   }
}
