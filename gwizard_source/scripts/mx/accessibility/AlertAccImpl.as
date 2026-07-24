package mx.accessibility
{
   import flash.accessibility.Accessibility;
   import flash.events.Event;
   import mx.controls.Alert;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.managers.ISystemManager;
   
   use namespace mx_internal;
   
   public class AlertAccImpl extends TitleWindowAccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function AlertAccImpl(param1:UIComponent)
      {
         super(param1);
         role = AccConst.ROLE_SYSTEM_ALERT;
      }
      
      public static function enableAccessibility() : void
      {
         Alert.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         var _loc2_:UIComponent = Alert(param1).getTitleBar();
         var _loc3_:AlertAccImpl = new AlertAccImpl(param1);
         _loc2_.accessibilityImplementation = _loc3_;
      }
      
      override protected function get eventsToHandle() : Array
      {
         return super.eventsToHandle.concat(["close","creationComplete"]);
      }
      
      override protected function getName(param1:uint) : String
      {
         return Alert(master).title + ", " + Alert(master).text;
      }
      
      override protected function eventHandler(param1:Event) : void
      {
         var _loc3_:UIComponent = null;
         $eventHandler(param1);
         var _loc2_:ISystemManager = ISystemManager(master.parent);
         switch(param1.type)
         {
            case "close":
               _loc3_ = Alert(master).getTitleBar();
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_SYSTEM_DIALOGEND);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_REORDER);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_DESTROY);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_LOCATIONCHANGE);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_PARENTCHANGE);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_HIDE);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_SYSTEM_FOREGROUND);
               if(_loc2_.stage.focus)
               {
                  Accessibility.sendEvent(_loc2_.stage.focus,0,AccConst.EVENT_OBJECT_FOCUS);
               }
               break;
            case "creationComplete":
               master.$visible = true;
               _loc3_ = Alert(master).getTitleBar();
               _loc3_.tabIndex = 0;
               Alert(master).alertForm.textField.tabIndex = 0;
               UIComponent(_loc3_).$visible = true;
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_SYSTEM_DIALOGSTART);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_REORDER);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_CREATE);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_LOCATIONCHANGE);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_PARENTCHANGE);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_SHOW);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_SYSTEM_FOREGROUND);
               Accessibility.sendEvent(_loc3_,0,AccConst.EVENT_OBJECT_FOCUS);
               Accessibility.sendEvent(Alert(master).alertForm.defaultButton,0,AccConst.EVENT_OBJECT_FOCUS);
         }
      }
   }
}
