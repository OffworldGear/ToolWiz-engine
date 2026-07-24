package mx.managers
{
   import flash.events.IEventDispatcher;
   
   public interface IBrowserManager extends IEventDispatcher
   {
       
      
      function get base() : String;
      
      function get fragment() : String;
      
      function get title() : String;
      
      function get url() : String;
      
      function setFragment(param1:String) : void;
      
      function setTitle(param1:String) : void;
      
      function init(param1:String = null, param2:String = null) : void;
      
      function initForHistoryManager() : void;
   }
}
