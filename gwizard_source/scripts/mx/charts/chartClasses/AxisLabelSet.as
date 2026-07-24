package mx.charts.chartClasses
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class AxisLabelSet
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public var accurate:Boolean;
      
      public var labels:Array;
      
      public var minorTicks:Array;
      
      public var ticks:Array;
      
      public function AxisLabelSet()
      {
         super();
      }
   }
}
