package mx.accessibility
{
   import flash.accessibility.Accessibility;
   import flash.events.Event;
   import mx.controls.MenuBar;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.MenuEvent;
   
   use namespace mx_internal;
   
   public class MenuBarAccImpl extends AccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function MenuBarAccImpl(param1:UIComponent)
      {
         super(param1);
         role = AccConst.ROLE_SYSTEM_MENUBAR;
      }
      
      public static function enableAccessibility() : void
      {
         MenuBar.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new MenuBarAccImpl(param1);
      }
      
      override protected function get eventsToHandle() : Array
      {
         return super.eventsToHandle.concat(["menuShow","menuHide","focusIn","focusOut"]);
      }
      
      override public function get_accRole(param1:uint) : uint
      {
         return param1 == 0 ? uint(role) : uint(AccConst.ROLE_SYSTEM_MENUITEM);
      }
      
      override public function get_accState(param1:uint) : uint
      {
         var _loc3_:MenuBar = null;
         var _loc4_:int = 0;
         var _loc2_:uint = getState(param1);
         if(param1 > 0)
         {
            _loc3_ = MenuBar(master);
            _loc4_ = param1 - 1;
            if(!_loc3_.menuBarItems[_loc4_] || !_loc3_.menuBarItems[_loc4_].enabled)
            {
               _loc2_ |= AccConst.STATE_SYSTEM_UNAVAILABLE;
            }
            else
            {
               _loc2_ |= AccConst.STATE_SYSTEM_SELECTABLE | AccConst.STATE_SYSTEM_FOCUSABLE;
               _loc2_ |= AccConst.STATE_SYSTEM_HASPOPUP;
               if(_loc4_ == _loc3_.selectedIndex)
               {
                  _loc2_ |= AccConst.STATE_SYSTEM_HOTTRACKED | AccConst.STATE_SYSTEM_FOCUSED;
               }
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
         return param1 - 1 == MenuBar(master).selectedIndex ? "Close" : "Open";
      }
      
      override public function accDoDefaultAction(param1:uint) : void
      {
         var _loc2_:int = 0;
         if(param1 > 0)
         {
            _loc2_ = param1 - 1;
         }
      }
      
      override public function getChildIDArray() : Array
      {
         var _loc1_:int = !!MenuBar(master).menuBarItems ? int(MenuBar(master).menuBarItems.length) : 0;
         return createChildIDArray(_loc1_);
      }
      
      override public function accLocation(param1:uint) : *
      {
         return MenuBar(master).menuBarItems[param1 - 1];
      }
      
      override public function get_accFocus() : uint
      {
         var _loc1_:int = MenuBar(master).selectedIndex;
         return _loc1_ >= 0 ? uint(_loc1_ + 1) : uint(0);
      }
      
      override protected function getName(param1:uint) : String
      {
         if(param1 == 0)
         {
            return "";
         }
         var _loc2_:MenuBar = MenuBar(master);
         var _loc3_:int = param1 - 1;
         if(_loc2_.menuBarItems && _loc2_.menuBarItems.length > _loc3_)
         {
            if(_loc2_.menuBarItems[_loc3_] && _loc2_.menuBarItems[_loc3_].data)
            {
               return _loc2_.itemToLabel(_loc2_.menuBarItems[_loc3_].data);
            }
         }
         return "";
      }
      
      override protected function eventHandler(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:uint = 0;
         $eventHandler(param1);
         switch(param1.type)
         {
            case "menuShow":
               _loc2_ = MenuBar(master).selectedIndex;
               if(_loc2_ >= 0 && !MenuEvent(param1).menu.parentMenu)
               {
                  _loc3_ = _loc2_ + 1;
                  Accessibility.sendEvent(master,_loc3_,AccConst.EVENT_OBJECT_FOCUS);
                  Accessibility.sendEvent(master,_loc3_,AccConst.EVENT_OBJECT_SELECTION);
               }
               break;
            case "menuHide":
               if(!MenuEvent(param1).menu.parentMenu)
               {
                  Accessibility.sendEvent(master,0,AccConst.EVENT_SYSTEM_MENUEND);
               }
               break;
            case "focusIn":
               Accessibility.sendEvent(master,0,AccConst.EVENT_SYSTEM_MENUSTART);
               break;
            case "focusOut":
               if(MenuBar(master).selectedIndex == -1)
               {
                  Accessibility.sendEvent(master,0,AccConst.EVENT_SYSTEM_MENUEND);
               }
         }
      }
   }
}
