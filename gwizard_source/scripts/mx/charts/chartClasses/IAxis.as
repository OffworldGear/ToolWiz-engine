package mx.charts.chartClasses
{
   import flash.events.IEventDispatcher;
   import mx.charts.AxisLabel;
   
   public interface IAxis extends IEventDispatcher
   {
       
      
      function get baseline() : Number;
      
      function set chartDataProvider(param1:Object) : void;
      
      function get displayName() : String;
      
      function get title() : String;
      
      function get unitSize() : Number;
      
      function mapCache(param1:Array, param2:String, param3:String, param4:Boolean = false) : void;
      
      function filterCache(param1:Array, param2:String, param3:String) : void;
      
      function transformCache(param1:Array, param2:String, param3:String) : void;
      
      function invertTransform(param1:Number) : Object;
      
      function formatForScreen(param1:Object) : String;
      
      function getLabelEstimate() : AxisLabelSet;
      
      function preferDropLabels() : Boolean;
      
      function getLabels(param1:Number) : AxisLabelSet;
      
      function reduceLabels(param1:AxisLabel, param2:AxisLabel) : AxisLabelSet;
      
      function registerDataTransform(param1:DataTransform, param2:String) : void;
      
      function unregisterDataTransform(param1:DataTransform) : void;
      
      function dataChanged() : void;
      
      function update() : void;
   }
}
