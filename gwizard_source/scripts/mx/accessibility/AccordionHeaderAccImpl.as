package mx.accessibility
{
   import flash.accessibility.Accessibility;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import mx.containers.Accordion;
   import mx.containers.accordionClasses.AccordionHeader;
   import mx.controls.Button;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class AccordionHeaderAccImpl extends AccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function AccordionHeaderAccImpl(param1:UIComponent)
      {
         super(param1);
         role = AccConst.ROLE_SYSTEM_PAGETAB;
         param1.parent.addEventListener("change",this.eventHandler);
         param1.addEventListener("removed",this.removedHandler);
      }
      
      public static function enableAccessibility() : void
      {
         AccordionHeader.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new AccordionHeaderAccImpl(param1);
      }
      
      override protected function get eventsToHandle() : Array
      {
         return super.eventsToHandle.concat(["focusDraw"]);
      }
      
      override public function get_accState(param1:uint) : uint
      {
         var _loc4_:int = 0;
         var _loc2_:uint = getState(param1);
         var _loc3_:Accordion = Accordion(master.parent);
         if(_loc3_.enabled)
         {
            _loc2_ |= AccConst.STATE_SYSTEM_SELECTABLE;
            if(Button(master).selected)
            {
               _loc2_ |= AccConst.STATE_SYSTEM_SELECTED;
            }
            if((_loc4_ = _loc3_.focusedIndex) >= 0 && master == _loc3_.getHeaderAt(_loc4_))
            {
               _loc2_ |= AccConst.STATE_SYSTEM_FOCUSED;
            }
         }
         else
         {
            _loc2_ |= AccConst.STATE_SYSTEM_UNAVAILABLE;
         }
         return _loc2_;
      }
      
      override public function get_accDefaultAction(param1:uint) : String
      {
         return "Switch";
      }
      
      override protected function getName(param1:uint) : String
      {
         var _loc3_:Accordion = null;
         var _loc2_:Button = Button(master);
         if(param1 > 0)
         {
            _loc3_ = Accordion(master.parent);
            _loc2_ = _loc3_.getHeaderAt(_loc3_.focusedIndex);
         }
         return _loc2_.label;
      }
      
      override protected function eventHandler(param1:Event) : void
      {
         var _loc2_:int = 0;
         $eventHandler(param1);
         switch(param1.type)
         {
            case "focusDraw":
               _loc2_ = Accordion(param1.currentTarget.parent).focusedIndex;
               if(_loc2_ >= 0 && master == Accordion(param1.currentTarget.parent).getHeaderAt(_loc2_))
               {
                  Accessibility.sendEvent(DisplayObject(param1.currentTarget),_loc2_ + 1,AccConst.EVENT_OBJECT_FOCUS,true);
               }
               break;
            case "change":
               _loc2_ = Accordion(param1.currentTarget).selectedIndex;
               if(_loc2_ >= 0 && master == Accordion(param1.currentTarget).getHeaderAt(_loc2_))
               {
                  Accessibility.sendEvent(master,_loc2_ + 1,AccConst.EVENT_OBJECT_SELECTION,true);
               }
         }
      }
      
      protected function removedHandler(param1:Event) : void
      {
         master.parent.removeEventListener("change",this.eventHandler);
         master.removeEventListener("removed",this.removedHandler);
      }
   }
}
