package mx.charts.chartClasses
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class BoundedValue
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public var lowerMargin:Number;
      
      public var upperMargin:Number;
      
      public var value:Number;
      
      public function BoundedValue(param1:Number, param2:Number = 0, param3:Number = 0)
      {
         super();
         this.value = param1;
         this.lowerMargin = param2;
         this.upperMargin = param3;
      }
   }
}
