package utils
{
   public class GWizCrypto
   {
      
      public static const HASH_LEN:int = 20;
       
      
      public function GWizCrypto()
      {
         super();
      }
      
      public static function hash(param1:String, param2:String, param3:int) : String
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc4_:* = "";
         if(!param1 || param1 == "")
         {
            return _loc4_;
         }
         param1 = param1.substr(0,param3);
         param1 = param1.toLowerCase();
         param2 = param2.toLowerCase();
         _loc5_ = 0;
         while(_loc5_ < param1.length && _loc5_ < param3)
         {
            _loc6_ = param1.charCodeAt(_loc5_);
            _loc7_ = param2.charCodeAt(_loc5_);
            _loc8_ = String.fromCharCode((_loc6_ + _loc7_) % 26 + 65);
            _loc4_ += _loc8_;
            _loc5_++;
         }
         if(_loc5_ < param3)
         {
            while(_loc5_ < param3)
            {
               _loc4_ += "1";
               _loc5_++;
            }
         }
         return _loc4_;
      }
   }
}
