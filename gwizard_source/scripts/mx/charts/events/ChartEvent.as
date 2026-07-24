package mx.charts.events
{
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import mx.charts.chartClasses.ChartBase;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ChartEvent extends MouseEvent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const CHART_CLICK:String = "chartClick";
      
      public static const CHART_DOUBLE_CLICK:String = "chartDoubleClick";
       
      
      public function ChartEvent(param1:String, param2:MouseEvent = null, param3:ChartBase = null)
      {
         var _loc4_:Point = null;
         if(param2 && param2.target)
         {
            _loc4_ = param3.globalToLocal(param2.target.localToGlobal(new Point(param2.localX,param2.localY)));
         }
         else if(param3)
         {
            _loc4_ = new Point(param3.mouseX,param3.mouseY);
         }
         else
         {
            _loc4_ = new Point(0,0);
         }
         var _loc5_:Boolean = true;
         var _loc6_:Boolean = false;
         var _loc7_:InteractiveObject = null;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:int = 0;
         if(param2)
         {
            _loc5_ = param2.bubbles;
            _loc6_ = param2.cancelable;
            _loc7_ = param2.relatedObject;
            _loc8_ = param2.ctrlKey;
            _loc10_ = param2.altKey;
            _loc9_ = param2.shiftKey;
            _loc11_ = param2.buttonDown;
            _loc12_ = param2.delta;
         }
         super(param1,_loc5_,_loc6_,_loc4_.x,_loc4_.y,_loc7_,_loc8_,_loc10_,_loc9_,_loc11_,_loc12_);
      }
      
      override public function clone() : Event
      {
         return new ChartEvent(type,this,ChartBase(this.target));
      }
   }
}
