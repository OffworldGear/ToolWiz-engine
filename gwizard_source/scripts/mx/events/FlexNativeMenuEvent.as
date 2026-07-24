package mx.events
{
   import flash.display.NativeMenu;
   import flash.display.NativeMenuItem;
   import flash.events.Event;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class FlexNativeMenuEvent extends Event
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const ITEM_CLICK:String = "itemClick";
      
      public static const MENU_SHOW:String = "menuShow";
       
      
      public var index:int;
      
      public var item:Object;
      
      public var label:String;
      
      public var nativeMenu:NativeMenu;
      
      public var nativeMenuItem:NativeMenuItem;
      
      public function FlexNativeMenuEvent(param1:String, param2:Boolean = false, param3:Boolean = true, param4:NativeMenu = null, param5:NativeMenuItem = null, param6:Object = null, param7:String = null, param8:int = -1)
      {
         super(param1,param2,param3);
         this.nativeMenu = param4;
         this.nativeMenuItem = param5;
         this.item = param6;
         this.label = param7;
         this.index = param8;
      }
      
      override public function clone() : Event
      {
         return new FlexNativeMenuEvent(type,bubbles,cancelable,this.nativeMenu,this.nativeMenuItem);
      }
   }
}
