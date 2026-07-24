package mx.charts.chartClasses
{
   import flash.geom.Point;
   
   public interface IChartElement2 extends IChartElement
   {
       
      
      function dataToLocal(... rest) : Point;
      
      function localToData(param1:Point) : Array;
      
      function getAllDataPoints() : Array;
   }
}
