package mx.charts.chartClasses
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class CartesianTransform extends DataTransform
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const HORIZONTAL_AXIS:String = "h";
      
      public static const VERTICAL_AXIS:String = "v";
       
      
      private var _pixelWidth:Number = 0;
      
      private var _pixelHeight:Number = 0;
      
      public function CartesianTransform()
      {
         super();
      }
      
      public function set pixelWidth(param1:Number) : void
      {
         this._pixelWidth = param1;
      }
      
      public function set pixelHeight(param1:Number) : void
      {
         this._pixelHeight = param1;
      }
      
      override public function invertTransform(... rest) : Array
      {
         var _loc2_:Number = rest[0] / this._pixelWidth;
         var _loc3_:Number = 1 - rest[1] / this._pixelHeight;
         var _loc4_:Object = axes[HORIZONTAL_AXIS].invertTransform(_loc2_);
         var _loc5_:Object = axes[VERTICAL_AXIS].invertTransform(_loc3_);
         return [_loc4_,_loc5_];
      }
      
      override public function transformCache(param1:Array, param2:String, param3:String, param4:String, param5:String) : void
      {
         var _loc8_:Object = null;
         var _loc6_:Number = this._pixelWidth;
         var _loc7_:Number = this._pixelHeight;
         var _loc9_:uint;
         if((_loc9_ = param1.length) == 0)
         {
            return;
         }
         if(param2 && param2 != "")
         {
            axes[HORIZONTAL_AXIS].transformCache(param1,param2,param3);
         }
         if(param4 && param4 != "")
         {
            axes[VERTICAL_AXIS].transformCache(param1,param4,param5);
         }
         var _loc10_:int = _loc9_ - 1;
         if(param3 && param3.length && param5 && param5.length)
         {
            do
            {
               (_loc8_ = param1[_loc10_])[param3] = _loc8_[param3] * _loc6_;
               _loc8_[param5] = (1 - _loc8_[param5]) * _loc7_;
            }
            while(--_loc10_ >= 0);
            
         }
         else if(param3 && param3.length)
         {
            do
            {
               (_loc8_ = param1[_loc10_])[param3] = _loc8_[param3] * _loc6_;
            }
            while(--_loc10_ >= 0);
            
         }
         else
         {
            do
            {
               (_loc8_ = param1[_loc10_])[param5] = (1 - _loc8_[param5]) * _loc7_;
            }
            while(--_loc10_ >= 0);
            
         }
      }
   }
}
