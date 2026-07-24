package mx.events
{
   import flash.events.Event;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ListEvent extends Event
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const CHANGE:String = "change";
      
      public static const ITEM_EDIT_BEGIN:String = "itemEditBegin";
      
      public static const ITEM_EDIT_END:String = "itemEditEnd";
      
      public static const ITEM_FOCUS_IN:String = "itemFocusIn";
      
      public static const ITEM_FOCUS_OUT:String = "itemFocusOut";
      
      public static const ITEM_EDIT_BEGINNING:String = "itemEditBeginning";
      
      public static const ITEM_CLICK:String = "itemClick";
      
      public static const ITEM_DOUBLE_CLICK:String = "itemDoubleClick";
      
      public static const ITEM_ROLL_OUT:String = "itemRollOut";
      
      public static const ITEM_ROLL_OVER:String = "itemRollOver";
       
      
      public var columnIndex:int;
      
      public var itemRenderer:IListItemRenderer;
      
      public var reason:String;
      
      public var rowIndex:int;
      
      public function ListEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:int = -1, param5:int = -1, param6:String = null, param7:IListItemRenderer = null)
      {
         super(param1,param2,param3);
         this.columnIndex = param4;
         this.rowIndex = param5;
         this.reason = param6;
         this.itemRenderer = param7;
      }
      
      override public function clone() : Event
      {
         return new ListEvent(type,bubbles,cancelable,this.columnIndex,this.rowIndex,this.reason,this.itemRenderer);
      }
   }
}
