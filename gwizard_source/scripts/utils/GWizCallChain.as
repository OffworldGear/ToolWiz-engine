package utils
{
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizCallChain
   {
      
      private static const log:ILogger = Log.getLogger("GWizCallChain");
       
      
      private var funcList:ArrayCollection;
      
      private var finalFunctionName:String = "";
      
      private var finalFunction:Function = null;
      
      public function GWizCallChain()
      {
         this.funcList = new ArrayCollection();
         super();
      }
      
      private function findFunction(param1:String) : int
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.funcList.length)
         {
            _loc2_ = this.funcList.getItemAt(_loc3_);
            if(_loc2_.name == param1)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      public function addFunction(param1:String, param2:Function, param3:Boolean = true) : void
      {
         var _loc4_:Object = null;
         var _loc5_:int;
         if((_loc5_ = this.findFunction(param1)) != -1 && param3)
         {
            (_loc4_ = this.funcList.getItemAt(_loc5_)).f = param2;
            this.funcList.removeItemAt(_loc5_);
         }
         else
         {
            (_loc4_ = new Object()).name = param1;
            _loc4_.f = param2;
         }
         this.funcList.addItem(_loc4_);
      }
      
      public function addFinalFunction(param1:String, param2:Function) : void
      {
         this.finalFunction = param2;
         this.finalFunctionName = param1;
      }
      
      public function removeFunction(param1:String) : void
      {
         var _loc2_:int = this.findFunction(param1);
         if(_loc2_ != -1)
         {
            this.funcList.removeItemAt(_loc2_);
         }
      }
      
      public function callChain(param1:Object) : Boolean
      {
         var _loc5_:Function = null;
         var _loc2_:Object = null;
         var _loc3_:Boolean = true;
         var _loc4_:int = 0;
         while(_loc3_ && _loc4_ < this.funcList.length)
         {
            _loc2_ = this.funcList.getItemAt(_loc4_);
            _loc5_ = _loc2_.f as Function;
            _loc3_ = _loc3_ && _loc5_(param1);
            _loc4_++;
         }
         if(this.finalFunction != null)
         {
            _loc3_ = this.finalFunction(param1,_loc3_);
         }
         return _loc3_;
      }
   }
}
