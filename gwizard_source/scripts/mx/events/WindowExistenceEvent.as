package mx.events
{
   import flash.events.Event;
   import mx.core.IWindow;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class WindowExistenceEvent extends Event
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const WINDOW_CREATE:String = "globalNotifyWindowCreate";
      
      public static const WINDOW_CREATING:String = "globalNotifyWindowCreating";
      
      public static const WINDOW_CLOSE:String = "globalNotifyWindowClose";
       
      
      public var window:IWindow;
      
      public function WindowExistenceEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:IWindow = null)
      {
         super(param1,param2,param3);
         this.window = param4;
      }
      
      override public function clone() : Event
      {
         return new WindowExistenceEvent(type,bubbles,cancelable,this.window);
      }
   }
}
