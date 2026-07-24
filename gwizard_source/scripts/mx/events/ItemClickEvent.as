package mx.events
{
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ItemClickEvent extends Event
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const ITEM_CLICK:String = "itemClick";
       
      
      public var index:int;
      
      public var item:Object;
      
      public var label:String;
      
      public var relatedObject:InteractiveObject;
      
      public function ItemClickEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:String = null, param5:int = -1, param6:InteractiveObject = null, param7:Object = null)
      {
         super(param1,param2,param3);
         this.label = param4;
         this.index = param5;
         this.relatedObject = param6;
         this.item = param7;
      }
      
      override public function clone() : Event
      {
         return new ItemClickEvent(type,bubbles,cancelable,this.label,this.index,this.relatedObject,this.item);
      }
   }
}
