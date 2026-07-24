package mx.accessibility
{
   import flash.accessibility.Accessibility;
   import flash.events.Event;
   import mx.controls.TabBar;
   import mx.controls.tabBarClasses.Tab;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class TabBarAccImpl extends AccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function TabBarAccImpl(param1:UIComponent)
      {
         super(param1);
         role = AccConst.ROLE_SYSTEM_PAGETABLIST;
      }
      
      public static function enableAccessibility() : void
      {
         TabBar.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new TabBarAccImpl(param1);
      }
      
      override protected function get eventsToHandle() : Array
      {
         return super.eventsToHandle.concat(["itemClick","focusDraw"]);
      }
      
      override public function get_accRole(param1:uint) : uint
      {
         return param1 == 0 ? uint(role) : uint(AccConst.ROLE_SYSTEM_PAGETAB);
      }
      
      override public function get_accState(param1:uint) : uint
      {
         var _loc4_:int = 0;
         var _loc2_:uint = getState(param1);
         var _loc3_:TabBar = TabBar(master);
         if(param1 > 0)
         {
            _loc2_ = AccConst.STATE_SYSTEM_SELECTABLE | AccConst.STATE_SYSTEM_FOCUSABLE;
            if((_loc4_ = param1 - 1) == _loc3_.selectedIndex)
            {
               _loc2_ |= AccConst.STATE_SYSTEM_SELECTED;
            }
            if(_loc4_ == _loc3_.focusedIndex)
            {
               _loc2_ |= AccConst.STATE_SYSTEM_FOCUSED;
            }
         }
         return _loc2_;
      }
      
      override public function get_accDefaultAction(param1:uint) : String
      {
         return "Switch";
      }
      
      override public function accDoDefaultAction(param1:uint) : void
      {
         if(param1 > 0)
         {
            TabBar(master).selectButton(param1 - 1,true);
         }
      }
      
      override public function getChildIDArray() : Array
      {
         var _loc1_:int = TabBar(master).numChildren;
         return createChildIDArray(_loc1_);
      }
      
      override public function accLocation(param1:uint) : *
      {
         return TabBar(master).getChildAt(param1 - 1);
      }
      
      override public function get_accFocus() : uint
      {
         var _loc1_:int = TabBar(master).focusedIndex;
         return _loc1_ >= 0 ? uint(_loc1_ + 1) : uint(0);
      }
      
      override protected function getName(param1:uint) : String
      {
         if(param1 == 0)
         {
            return "";
         }
         var _loc2_:TabBar = TabBar(master);
         var _loc3_:int = param1 - 1;
         if(_loc3_ > _loc2_.numChildren || _loc3_ < 0)
         {
            _loc3_ = _loc2_.numChildren - 1;
         }
         var _loc4_:Tab;
         return (_loc4_ = Tab(_loc2_.getChildAt(_loc3_))).label;
      }
      
      override protected function eventHandler(param1:Event) : void
      {
         var _loc2_:int = 0;
         $eventHandler(param1);
         switch(param1.type)
         {
            case "focusDraw":
               _loc2_ = TabBar(master).focusedIndex;
               if(_loc2_ >= 0)
               {
                  Accessibility.sendEvent(master,_loc2_ + 1,AccConst.EVENT_OBJECT_FOCUS);
               }
               break;
            case "itemClick":
               _loc2_ = TabBar(master).selectedIndex;
               if(_loc2_ >= 0)
               {
                  Accessibility.sendEvent(master,_loc2_ + 1,AccConst.EVENT_OBJECT_SELECTION);
                  Accessibility.sendEvent(master,_loc2_ + 1,AccConst.EVENT_OBJECT_FOCUS);
               }
         }
      }
   }
}
