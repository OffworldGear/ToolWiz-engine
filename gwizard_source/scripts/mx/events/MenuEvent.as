package mx.events
{
   import flash.events.Event;
   import mx.controls.Menu;
   import mx.controls.MenuBar;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class MenuEvent extends ListEvent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const CHANGE:String = "change";
      
      public static const ITEM_CLICK:String = "itemClick";
      
      public static const MENU_HIDE:String = "menuHide";
      
      public static const ITEM_ROLL_OUT:String = "itemRollOut";
      
      public static const ITEM_ROLL_OVER:String = "itemRollOver";
      
      public static const MENU_SHOW:String = "menuShow";
       
      
      public var index:int;
      
      public var item:Object;
      
      public var label:String;
      
      public var menu:Menu;
      
      public var menuBar:MenuBar;
      
      public function MenuEvent(param1:String, param2:Boolean = false, param3:Boolean = true, param4:MenuBar = null, param5:Menu = null, param6:Object = null, param7:IListItemRenderer = null, param8:String = null, param9:int = -1)
      {
         super(param1,param2,param3);
         this.menuBar = param4;
         this.menu = param5;
         this.item = param6;
         this.itemRenderer = param7;
         this.label = param8;
         this.index = param9;
      }
      
      override public function clone() : Event
      {
         return new MenuEvent(type,bubbles,cancelable,this.menuBar,this.menu,this.item,itemRenderer,this.label,this.index);
      }
   }
}
