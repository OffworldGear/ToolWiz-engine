package mx.managers
{
   public interface IHistoryManager
   {
       
      
      function register(param1:IHistoryManagerClient) : void;
      
      function unregister(param1:IHistoryManagerClient) : void;
      
      function save() : void;
   }
}
