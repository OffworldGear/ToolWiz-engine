package mx.charts.chartClasses
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   
   public interface IDataCanvas
   {
       
      
      function set dataChildren(param1:Array) : void;
      
      function get dataChildren() : Array;
      
      function addDataChild(param1:DisplayObject, param2:* = undefined, param3:* = undefined, param4:* = undefined, param5:* = undefined, param6:* = undefined, param7:* = undefined) : void;
      
      function removeAllChildren() : void;
      
      function updateDataChild(param1:DisplayObject, param2:* = undefined, param3:* = undefined, param4:* = undefined, param5:* = undefined, param6:* = undefined, param7:* = undefined) : void;
      
      function clear() : void;
      
      function beginFill(param1:uint, param2:Number = 1) : void;
      
      function beginBitmapFill(param1:BitmapData, param2:* = undefined, param3:* = undefined, param4:Matrix = null, param5:Boolean = true, param6:Boolean = true) : void;
      
      function curveTo(param1:*, param2:*, param3:*, param4:*) : void;
      
      function drawCircle(param1:*, param2:*, param3:Number) : void;
      
      function drawEllipse(param1:*, param2:*, param3:*, param4:*) : void;
      
      function drawRect(param1:*, param2:*, param3:*, param4:*) : void;
      
      function drawRoundedRect(param1:*, param2:*, param3:*, param4:*, param5:Number) : void;
      
      function endFill() : void;
      
      function lineStyle(param1:Number, param2:uint = 0, param3:Number = 1.0, param4:Boolean = false, param5:String = "normal", param6:String = null, param7:String = null, param8:Number = 3) : void;
      
      function lineTo(param1:*, param2:*) : void;
      
      function moveTo(param1:*, param2:*) : void;
   }
}
