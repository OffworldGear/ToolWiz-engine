package mx.charts.chartClasses
{
   import flash.utils.Dictionary;
   
   public interface IStackable
   {
       
      
      function get stacker() : StackedSeries;
      
      function set stacker(param1:StackedSeries) : void;
      
      function set stackTotals(param1:Dictionary) : void;
      
      function stack(param1:Dictionary, param2:IStackable) : Number;
   }
}
