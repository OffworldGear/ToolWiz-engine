package mx.managers
{
   public interface IHistoryManagerClient
   {
       
      
      function saveState() : Object;
      
      function loadState(param1:Object) : void;
      
      function toString() : String;
   }
}
