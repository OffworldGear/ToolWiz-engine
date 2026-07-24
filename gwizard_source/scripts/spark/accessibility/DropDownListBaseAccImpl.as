package spark.accessibility
{
   import flash.accessibility.Accessibility;
   import flash.events.Event;
   import mx.accessibility.AccConst;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import spark.components.supportClasses.DropDownListBase;
   import spark.components.supportClasses.ListBase;
   
   use namespace mx_internal;
   
   public class DropDownListBaseAccImpl extends ListBaseAccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function DropDownListBaseAccImpl(param1:UIComponent)
      {
         super(param1);
         role = AccConst.ROLE_SYSTEM_COMBOBOX;
      }
      
      public static function enableAccessibility() : void
      {
         DropDownListBase.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new DropDownListBaseAccImpl(param1);
      }
      
      override protected function get eventsToHandle() : Array
      {
         return super.eventsToHandle.concat(["open","close"]);
      }
      
      override public function get_accValue(param1:uint) : String
      {
         if(param1 == 0)
         {
            return getName(DropDownListBase(master).selectedIndex + 1);
         }
         return null;
      }
      
      override public function get_accState(param1:uint) : uint
      {
         var _loc2_:uint = super.get_accState(param1);
         if(param1 == 0)
         {
            if(DropDownListBase(master).isDropDownOpen)
            {
               _loc2_ |= AccConst.STATE_SYSTEM_EXPANDED;
            }
            else
            {
               _loc2_ |= AccConst.STATE_SYSTEM_COLLAPSED;
            }
         }
         else if(!DropDownListBase(master).isDropDownOpen)
         {
            if(param1 - 1 == ListBase(master).caretIndex)
            {
               _loc2_ |= AccConst.STATE_SYSTEM_SELECTED;
            }
            _loc2_ = AccConst.STATE_SYSTEM_INVISIBLE;
         }
         return _loc2_;
      }
      
      override protected function eventHandler(param1:Event) : void
      {
         var _loc2_:uint = 0;
         switch(param1.type)
         {
            case "open":
               Accessibility.sendEvent(master,0,AccConst.EVENT_OBJECT_STATECHANGE);
               _loc2_ = DropDownListBase(master).selectedIndex;
               if(_loc2_ >= 0)
               {
                  Accessibility.sendEvent(master,_loc2_ + 1,AccConst.EVENT_OBJECT_FOCUS);
               }
               break;
            case "close":
               Accessibility.sendEvent(master,0,AccConst.EVENT_OBJECT_STATECHANGE);
               Accessibility.sendEvent(master,0,AccConst.EVENT_OBJECT_FOCUS);
               break;
            case "change":
               if(!DropDownListBase(master).isDropDownOpen)
               {
                  Accessibility.sendEvent(master,0,AccConst.EVENT_OBJECT_VALUECHANGE,true);
                  break;
               }
            case "caretChange":
               if(!DropDownListBase(master).isDropDownOpen)
               {
                  break;
               }
            default:
               super.eventHandler(param1);
         }
      }
   }
}
