package mx.charts
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class AxisLabel
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public var position:Number;
      
      public var text:String;
      
      public var value:Object;
      
      public function AxisLabel(param1:Number = 0, param2:Object = null, param3:String = null)
      {
         super();
         this.position = param1;
         this.value = param2;
         this.text = param3;
      }
   }
}
