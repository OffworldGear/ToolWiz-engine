package mx.charts.series.items
{
   import mx.charts.ChartItem;
   import mx.charts.series.LineSeries;
   import mx.core.mx_internal;
   import mx.graphics.IFill;
   
   use namespace mx_internal;
   
   public class LineSeriesItem extends ChartItem
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public var fill:IFill;
      
      public var x:Number;
      
      public var xFilter:Number;
      
      public var xNumber:Number;
      
      public var xValue:Object;
      
      public var y:Number;
      
      public var yFilter:Number;
      
      public var yNumber:Number;
      
      public var yValue:Object;
      
      public function LineSeriesItem(param1:LineSeries = null, param2:Object = null, param3:uint = 0)
      {
         super(param1,param2,param3);
      }
      
      override public function clone() : ChartItem
      {
         var _loc1_:LineSeriesItem = new LineSeriesItem(LineSeries(element),item,index);
         _loc1_.itemRenderer = itemRenderer;
         return _loc1_;
      }
   }
}
