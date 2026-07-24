package mx.charts.chartClasses
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public final class ChartState
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const NONE:uint = 0;
      
      public static const PREPARING_TO_HIDE_DATA:uint = 1;
      
      public static const HIDING_DATA:uint = 2;
      
      public static const PREPARING_TO_SHOW_DATA:uint = 3;
      
      public static const SHOWING_DATA:uint = 4;
       
      
      public function ChartState()
      {
         super();
      }
   }
}
