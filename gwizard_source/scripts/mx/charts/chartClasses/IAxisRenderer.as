package mx.charts.chartClasses
{
   import flash.geom.Rectangle;
   import mx.core.IUIComponent;
   
   public interface IAxisRenderer extends IUIComponent
   {
       
      
      function get axis() : IAxis;
      
      function set axis(param1:IAxis) : void;
      
      function get gutters() : Rectangle;
      
      function set gutters(param1:Rectangle) : void;
      
      function set heightLimit(param1:Number) : void;
      
      function get heightLimit() : Number;
      
      function get horizontal() : Boolean;
      
      function set horizontal(param1:Boolean) : void;
      
      function get minorTicks() : Array;
      
      function set otherAxes(param1:Array) : void;
      
      function get placement() : String;
      
      function set placement(param1:String) : void;
      
      function get ticks() : Array;
      
      function adjustGutters(param1:Rectangle, param2:Object) : Rectangle;
      
      function chartStateChanged(param1:uint, param2:uint) : void;
   }
}
