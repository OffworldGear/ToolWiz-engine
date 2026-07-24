package threads2
{
   import utils.GWizUtils;
   
   public class GWizReynardR40
   {
      
      public static var R40:Array = [1,1.06,1.12,1.18,1.25,1.32,1.4,1.5,1.6,1.7,1.8,1.9,2,2.12,2.24,2.36,2.5,2.65,2.8,3,3.15,3.35,3.55,3.75,4,4.25,4.5,4.75,5,5.3,5.6,6,6.3,6.7,7.1,7.5,8,8.5,9,9.5,10];
       
      
      public function GWizReynardR40()
      {
         super();
      }
      
      public static function roundR40(param1:Number) : Number
      {
         var _loc4_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc2_:Number = param1 >= 0 ? Number(1) : Number(-1);
         param1 *= _loc2_;
         var _loc3_:Number = 1;
         if(param1 > 10)
         {
            while(param1 > 10)
            {
               param1 /= 10;
               _loc3_ /= 10;
            }
         }
         else if(param1 < 1)
         {
            while(param1 < 1)
            {
               param1 *= 10;
               _loc3_ *= 10;
            }
         }
         var _loc5_:int = 0;
         while(_loc5_ < R40.length)
         {
            if(R40[_loc5_] <= param1 && param1 <= R40[_loc5_ + 1])
            {
               _loc6_ = Math.abs(param1 - R40[_loc5_]);
               _loc7_ = Math.abs(param1 - R40[_loc5_ + 1]);
               if(_loc6_ < _loc7_)
               {
                  _loc4_ = R40[_loc5_];
               }
               else
               {
                  _loc4_ = R40[_loc5_ + 1];
               }
               break;
            }
            _loc5_++;
         }
         if(isNaN(_loc4_))
         {
            GWizUtils.assert(false);
         }
         param1 = _loc4_ / _loc3_;
         return Number(param1 * _loc2_);
      }
   }
}
