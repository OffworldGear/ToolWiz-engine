package spark.accessibility
{
   import flash.accessibility.Accessibility;
   import flash.events.Event;
   import mx.accessibility.AccConst;
   import mx.accessibility.AccImpl;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import spark.components.Spinner;
   
   use namespace mx_internal;
   
   public class SpinnerAccImpl extends AccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function SpinnerAccImpl(param1:UIComponent)
      {
         super(param1);
         role = AccConst.ROLE_SYSTEM_SPINBUTTON;
      }
      
      public static function enableAccessibility() : void
      {
         Spinner.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new SpinnerAccImpl(param1);
      }
      
      override protected function get eventsToHandle() : Array
      {
         return super.eventsToHandle.concat([Event.CHANGE]);
      }
      
      override public function get_accRole(param1:uint) : uint
      {
         return param1 == 0 ? uint(role) : uint(AccConst.ROLE_SYSTEM_PUSHBUTTON);
      }
      
      override public function getChildIDArray() : Array
      {
         return createChildIDArray(2);
      }
      
      override public function accLocation(param1:uint) : *
      {
         switch(param1)
         {
            case 0:
               return master;
            case 1:
               return Spinner(master).incrementButton;
            case 2:
               return Spinner(master).decrementButton;
            default:
               return;
         }
      }
      
      override public function get_accState(param1:uint) : uint
      {
         var _loc2_:uint = 0;
         switch(param1)
         {
            case 0:
               _loc2_ = getState(param1);
               break;
            case 1:
               if(!Spinner(master).enabled)
               {
                  _loc2_ = AccConst.STATE_SYSTEM_UNAVAILABLE;
               }
               break;
            case 2:
               if(!Spinner(master).enabled)
               {
                  _loc2_ = AccConst.STATE_SYSTEM_UNAVAILABLE;
               }
         }
         return _loc2_;
      }
      
      override public function get_accValue(param1:uint) : String
      {
         if(param1 > 0)
         {
            return null;
         }
         return Spinner(master).value.toString();
      }
      
      override public function get_accDefaultAction(param1:uint) : String
      {
         return param1 == 0 ? "" : "Press";
      }
      
      override public function accDoDefaultAction(param1:uint) : void
      {
         var _loc2_:Number = Spinner(master).value;
         switch(param1)
         {
            case 1:
               if(Spinner(master).enabled)
               {
                  Spinner(master).changeValueByStep(true);
               }
               break;
            case 2:
               if(Spinner(master).enabled)
               {
                  Spinner(master).changeValueByStep(false);
               }
         }
         if(Spinner(master).value != _loc2_)
         {
            master.dispatchEvent(new Event(Event.CHANGE));
            master.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
         }
      }
      
      override protected function getName(param1:uint) : String
      {
         var _loc2_:IResourceManager = ResourceManager.getInstance();
         if(param1 == 1)
         {
            return _loc2_.getString("components","spinnerMoreAccName");
         }
         if(param1 == 2)
         {
            return _loc2_.getString("components","spinnerLessAccName");
         }
         return "";
      }
      
      override protected function eventHandler(param1:Event) : void
      {
         $eventHandler(param1);
         switch(param1.type)
         {
            case Event.CHANGE:
               Accessibility.sendEvent(master,0,AccConst.EVENT_OBJECT_VALUECHANGE,true);
               Accessibility.sendEvent(master,0,AccConst.EVENT_OBJECT_STATECHANGE,true);
         }
      }
   }
}
