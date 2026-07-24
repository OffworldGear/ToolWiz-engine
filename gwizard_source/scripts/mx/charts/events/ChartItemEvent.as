package mx.charts.events
{
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import mx.charts.HitData;
   import mx.charts.chartClasses.ChartBase;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ChartItemEvent extends MouseEvent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const ITEM_CLICK:String = "itemClick";
      
      public static const ITEM_DOUBLE_CLICK:String = "itemDoubleClick";
      
      public static const ITEM_MOUSE_DOWN:String = "itemMouseDown";
      
      public static const ITEM_MOUSE_MOVE:String = "itemMouseMove";
      
      public static const ITEM_ROLL_OUT:String = "itemRollOut";
      
      public static const ITEM_ROLL_OVER:String = "itemRollOver";
      
      public static const ITEM_MOUSE_UP:String = "itemMouseUp";
      
      public static const CHANGE:String = "change";
       
      
      public var hitSet:Array;
      
      public function ChartItemEvent(param1:String, param2:Array = null, param3:MouseEvent = null, param4:ChartBase = null)
      {
         var _loc5_:Point = null;
         if(param3 && param3.target)
         {
            _loc5_ = param4.globalToLocal(param3.target.localToGlobal(new Point(param3.localX,param3.localY)));
         }
         else if(param4)
         {
            _loc5_ = new Point(param4.mouseX,param4.mouseY);
         }
         else
         {
            _loc5_ = new Point(0,0);
         }
         var _loc6_:Boolean = true;
         var _loc7_:Boolean = false;
         var _loc8_:InteractiveObject = null;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc13_:int = 0;
         if(param3)
         {
            _loc6_ = param3.bubbles;
            _loc7_ = param3.cancelable;
            _loc8_ = param3.relatedObject;
            _loc9_ = param3.ctrlKey;
            _loc11_ = param3.altKey;
            _loc10_ = param3.shiftKey;
            _loc12_ = param3.buttonDown;
            _loc13_ = param3.delta;
         }
         super(param1,_loc6_,_loc7_,_loc5_.x,_loc5_.y,_loc8_,_loc9_,_loc11_,_loc10_,_loc12_,_loc13_);
         this.hitSet = param2;
      }
      
      public function get hitData() : HitData
      {
         return this.hitSet && this.hitSet.length > 0 ? this.hitSet[0] : null;
      }
      
      override public function clone() : Event
      {
         return new ChartItemEvent(type,this.hitSet,this,ChartBase(this.target));
      }
   }
}
