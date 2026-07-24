package mx.charts.chartClasses
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class DataDescription
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const REQUIRED_BOUNDED_VALUES:uint = 2;
      
      public static const REQUIRED_MIN_INTERVAL:uint = 1;
      
      public static const REQUIRED_MIN_MAX:uint = 4;
      
      public static const REQUIRED_PADDING:uint = 8;
       
      
      public var boundedValues:Array;
      
      public var max:Number;
      
      public var min:Number;
      
      public var minInterval:Number;
      
      public var padding:Number;
      
      public function DataDescription()
      {
         super();
      }
   }
}
