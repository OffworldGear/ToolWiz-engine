package mx.charts.series.items
{
   import mx.charts.series.LineSeries;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class LineSeriesSegment
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public var element:LineSeries;
      
      public var end:uint;
      
      public var index:uint;
      
      public var items:Array;
      
      public var start:uint;
      
      public function LineSeriesSegment(param1:LineSeries, param2:uint, param3:Array, param4:uint, param5:uint)
      {
         super();
         this.element = param1;
         this.items = param3;
         this.index = param2;
         this.start = param4;
         this.end = param5;
      }
      
      public function clone() : LineSeriesSegment
      {
         return new LineSeriesSegment(this.element,this.index,this.items,this.start,this.end);
      }
   }
}
