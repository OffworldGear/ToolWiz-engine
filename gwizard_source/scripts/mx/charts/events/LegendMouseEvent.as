package mx.charts.events
{
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mx.charts.LegendItem;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class LegendMouseEvent extends MouseEvent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const ITEM_MOUSE_DOWN:String = "itemMouseDown";
      
      public static const ITEM_MOUSE_UP:String = "itemMouseUp";
      
      public static const ITEM_MOUSE_OUT:String = "itemMouseOut";
      
      public static const ITEM_MOUSE_OVER:String = "itemMouseOver";
      
      public static const ITEM_CLICK:String = "itemClick";
       
      
      public var item:LegendItem;
      
      public function LegendMouseEvent(param1:String, param2:MouseEvent = null, param3:LegendItem = null)
      {
         var _loc4_:String = convertType(param1);
         var _loc5_:Boolean = true;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:InteractiveObject = null;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         var _loc14_:int = 0;
         if(param2)
         {
            _loc5_ = param2.bubbles;
            _loc6_ = param2.cancelable;
            _loc7_ = param2.localX;
            _loc8_ = param2.localY;
            _loc9_ = param2.relatedObject;
            _loc10_ = param2.ctrlKey;
            _loc12_ = param2.altKey;
            _loc11_ = param2.shiftKey;
            _loc13_ = param2.buttonDown;
            _loc14_ = param2.delta;
         }
         super(_loc4_,_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,_loc10_,_loc12_,_loc11_,_loc13_,_loc14_);
         this.item = param3;
      }
      
      private static function convertType(param1:String) : String
      {
         switch(param1)
         {
            case MouseEvent.CLICK:
               return ITEM_CLICK;
            case MouseEvent.MOUSE_DOWN:
               return ITEM_MOUSE_DOWN;
            case MouseEvent.MOUSE_UP:
               return ITEM_MOUSE_UP;
            case MouseEvent.MOUSE_OVER:
               return ITEM_MOUSE_OVER;
            case MouseEvent.MOUSE_OUT:
               return ITEM_MOUSE_OUT;
            default:
               return param1;
         }
      }
      
      override public function clone() : Event
      {
         return new LegendMouseEvent(type,this,this.item);
      }
   }
}
