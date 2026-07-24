package utils
{
   public class ArrowStyle
   {
       
      
      public var headWidth:Number = -1;
      
      public var headLength:Number = 10;
      
      public var shaftThickness:Number = 1;
      
      public var shaftPosition:Number = 0.15;
      
      public var shaftControlPosition:Number = 0.6;
      
      public var shaftControlSize:Number = 0.25;
      
      public var edgeControlPosition:Number = 0.6;
      
      public var edgeControlSize:Number = 0.25;
      
      public function ArrowStyle(param1:Object = null)
      {
         var _loc2_:* = null;
         super();
         if(param1 != null)
         {
            for(_loc2_ in param1)
            {
               this[_loc2_] = param1[_loc2_];
            }
         }
      }
   }
}
