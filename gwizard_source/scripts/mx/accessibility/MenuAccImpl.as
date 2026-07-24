package mx.accessibility
{
   import flash.accessibility.Accessibility;
   import flash.events.Event;
   import mx.controls.Menu;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.MenuEvent;
   
   use namespace mx_internal;
   
   public class MenuAccImpl extends ListBaseAccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function MenuAccImpl(param1:UIComponent)
      {
         super(param1);
         role = AccConst.ROLE_SYSTEM_MENUPOPUP;
      }
      
      public static function enableAccessibility() : void
      {
         Menu.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new MenuAccImpl(param1);
      }
      
      override protected function get eventsToHandle() : Array
      {
         return super.eventsToHandle.concat(["itemRollOver","menuShow","menuHide"]);
      }
      
      override public function get_accRole(param1:uint) : uint
      {
         return param1 == 0 ? uint(role) : uint(AccConst.ROLE_SYSTEM_MENUITEM);
      }
      
      override public function get_accState(param1:uint) : uint
      {
         var _loc3_:Object = null;
         var _loc2_:uint = getState(param1);
         if(param1 > 0 && param1 < 100000)
         {
            _loc3_ = Menu(master).dataProvider[param1 - 1];
            if(!Menu(master).dataDescriptor.isEnabled(_loc3_))
            {
               return uint(_loc2_ | AccConst.STATE_SYSTEM_UNAVAILABLE);
            }
            _loc2_ |= AccConst.STATE_SYSTEM_HOTTRACKED | AccConst.STATE_SYSTEM_FOCUSED;
            if(Menu(master).dataDescriptor.isToggled(_loc3_))
            {
               _loc2_ |= AccConst.STATE_SYSTEM_CHECKED;
            }
            if(Menu(master).dataDescriptor.isBranch(_loc3_))
            {
               _loc2_ |= AccConst.STATE_SYSTEM_HASPOPUP;
            }
         }
         return _loc2_;
      }
      
      override public function get_accDefaultAction(param1:uint) : String
      {
         if(param1 == 0)
         {
            return null;
         }
         var _loc2_:Object = Menu(master).dataProvider[param1 - 1];
         return !!Menu(master).dataDescriptor.isBranch(_loc2_) ? "Open" : "Execute";
      }
      
      override protected function getName(param1:uint) : String
      {
         if(param1 == 0)
         {
            return "";
         }
         var _loc2_:Menu = Menu(master);
         var _loc3_:Object = _loc2_.dataProvider[param1 - 1];
         return _loc2_.itemToLabel(_loc3_);
      }
      
      override protected function eventHandler(param1:Event) : void
      {
         var _loc3_:uint = 0;
         $eventHandler(param1);
         var _loc2_:int = 0;
         switch(param1.type)
         {
            case MenuEvent.ITEM_ROLL_OVER:
               _loc2_ = MenuEvent(param1).index;
               if(_loc2_ >= 0)
               {
                  _loc3_ = _loc2_ + 1;
                  Accessibility.sendEvent(MenuEvent(param1).menu,_loc3_,AccConst.EVENT_OBJECT_FOCUS);
                  Accessibility.sendEvent(MenuEvent(param1).menu,_loc3_,AccConst.EVENT_OBJECT_SELECTION);
               }
               break;
            case MenuEvent.ITEM_CLICK:
               _loc2_ = MenuEvent(param1).menu.selectedIndex;
               if(_loc2_ >= 0)
               {
                  _loc3_ = _loc2_ + 1;
                  Accessibility.sendEvent(MenuEvent(param1).menu,_loc3_,AccConst.EVENT_OBJECT_FOCUS);
                  Accessibility.sendEvent(MenuEvent(param1).menu,_loc3_,AccConst.EVENT_OBJECT_SELECTION);
               }
               break;
            case MenuEvent.MENU_SHOW:
               Accessibility.sendEvent(MenuEvent(param1).menu,0,AccConst.EVENT_SYSTEM_MENUPOPUPSTART);
               break;
            case MenuEvent.MENU_HIDE:
               Accessibility.sendEvent(MenuEvent(param1).menu,0,AccConst.EVENT_SYSTEM_MENUPOPUPEND);
         }
      }
   }
}
