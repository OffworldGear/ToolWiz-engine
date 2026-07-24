package spark.accessibility
{
   import flash.accessibility.Accessibility;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import mx.accessibility.AccConst;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import spark.components.ComboBox;
   import spark.components.TextInput;
   import spark.events.IndexChangeEvent;
   import spark.events.SkinPartEvent;
   
   use namespace mx_internal;
   
   public class ComboBoxAccImpl extends DropDownListBaseAccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function ComboBoxAccImpl(param1:UIComponent)
      {
         super(param1);
         var _loc2_:TextInput = ComboBox(param1).textInput;
         if(_loc2_)
         {
            _loc2_.addEventListener(Event.CHANGE,this.textInputChangeHandler);
         }
      }
      
      public static function enableAccessibility() : void
      {
         ComboBox.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new ComboBoxAccImpl(param1);
      }
      
      override protected function get eventsToHandle() : Array
      {
         return super.eventsToHandle.concat([FocusEvent.FOCUS_IN,SkinPartEvent.PART_ADDED,SkinPartEvent.PART_REMOVED]);
      }
      
      override public function get_accName(param1:uint) : String
      {
         if(param1 <= 1)
         {
            return super.get_accName(0);
         }
         return super.get_accName(param1 - 1);
      }
      
      override public function get_accRole(param1:uint) : uint
      {
         if(param1 == 1)
         {
            return AccConst.ROLE_SYSTEM_TEXT;
         }
         if(param1 == 0)
         {
            return super.get_accRole(0);
         }
         return super.get_accRole(param1 - 1);
      }
      
      override public function get_accState(param1:uint) : uint
      {
         if(param1 > 1)
         {
            return super.get_accState(param1 - 1);
         }
         var _loc2_:uint = super.get_accState(0);
         if(master.getFocus() && master.owns(master.getFocus()))
         {
            _loc2_ |= AccConst.STATE_SYSTEM_FOCUSED;
         }
         if(param1 == 1)
         {
            _loc2_ &= ~AccConst.STATE_SYSTEM_COLLAPSED;
         }
         return _loc2_;
      }
      
      override public function get_accDefaultAction(param1:uint) : String
      {
         if(param1 <= 1)
         {
            return null;
         }
         return super.get_accDefaultAction(param1 - 1);
      }
      
      override public function accDoDefaultAction(param1:uint) : void
      {
         if(param1 > 1)
         {
            super.accDoDefaultAction(param1 - 1);
         }
      }
      
      override public function getChildIDArray() : Array
      {
         var _loc1_:Array = super.getChildIDArray();
         _loc1_[_loc1_.length] = _loc1_.length + 1;
         return _loc1_;
      }
      
      override public function get_accFocus() : uint
      {
         var _loc1_:uint = super.get_accFocus();
         if(ComboBox(master).isDropDownOpen)
         {
            return _loc1_ > 0 ? uint(_loc1_ + 1) : uint(0);
         }
         if(master.getFocus() && master.owns(master.getFocus()))
         {
            return 1;
         }
         return 0;
      }
      
      override public function accLocation(param1:uint) : *
      {
         if(param1 == 0)
         {
            return super.accLocation(0);
         }
         if(param1 == 1)
         {
            return ComboBox(master).textInput;
         }
         return super.accLocation(param1 - 1);
      }
      
      override public function accSelect(param1:uint, param2:uint) : void
      {
         if(param2 > 1)
         {
            super.accSelect(param1,param2 - 1);
         }
         else if(param2 <= 1 && ComboBox(master).textInput)
         {
            ComboBox(master).setFocus();
         }
      }
      
      override public function get_accValue(param1:uint) : String
      {
         var _loc2_:ComboBox = ComboBox(master);
         if(param1 <= 1)
         {
            return _loc2_.selectedIndex == -1 ? _loc2_.textInput.text : _loc2_.selectedItem;
         }
         return null;
      }
      
      override protected function eventHandler(param1:Event) : void
      {
         var _loc2_:TextInput = null;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         switch(param1.type)
         {
            case "open":
               Accessibility.sendEvent(master,0,AccConst.EVENT_OBJECT_STATECHANGE);
               _loc3_ = ComboBox(master).selectedIndex;
               if(_loc3_ >= 0)
               {
                  Accessibility.sendEvent(master,_loc3_ + 2,AccConst.EVENT_OBJECT_FOCUS);
               }
               break;
            case "focusIn":
               Accessibility.sendEvent(master,0,AccConst.EVENT_OBJECT_FOCUS);
               if(master.getFocus() == master && ComboBox(master).textInput)
               {
                  ComboBox(master).textInput.setFocus();
               }
               break;
            case "caretChange":
               _loc5_ = (_loc4_ = IndexChangeEvent(param1).newIndex) + 2;
               Accessibility.sendEvent(master,0,AccConst.EVENT_OBJECT_VALUECHANGE);
               Accessibility.sendEvent(master,1,AccConst.EVENT_OBJECT_VALUECHANGE);
               if(ComboBox(master).isDropDownOpen && _loc4_ >= 0 && _loc4_ < ComboBox(master).dataProvider.length)
               {
                  Accessibility.sendEvent(master,_loc5_,AccConst.EVENT_OBJECT_FOCUS);
               }
               break;
            case "change":
               if((_loc4_ = IndexChangeEvent(param1).newIndex) >= 0 && ComboBox(master).isDropDownOpen)
               {
                  _loc5_ = _loc4_ + 2;
                  Accessibility.sendEvent(master,_loc5_,AccConst.EVENT_OBJECT_SELECTION);
               }
               break;
            case "close":
               if(master.getFocus() && master.owns(master.getFocus()) && ComboBox(master).textInput)
               {
                  ComboBox(master).textInput.textDisplay.setFocus();
                  ComboBox(master).textInput.selectRange(0,0);
                  Accessibility.sendEvent(master,1,AccConst.EVENT_OBJECT_FOCUS);
               }
               break;
            case SkinPartEvent.PART_ADDED:
               _loc2_ = ComboBox(master).textInput;
               if(SkinPartEvent(param1).instance == _loc2_)
               {
                  _loc2_.addEventListener(Event.CHANGE,this.textInputChangeHandler);
               }
               break;
            case SkinPartEvent.PART_REMOVED:
               _loc2_ = ComboBox(master).textInput;
               if(SkinPartEvent(param1).instance == _loc2_)
               {
                  _loc2_.removeEventListener(Event.CHANGE,this.textInputChangeHandler);
               }
               break;
            default:
               super.eventHandler(param1);
         }
      }
      
      private function textInputChangeHandler(param1:Event) : void
      {
         Accessibility.sendEvent(master,0,AccConst.EVENT_OBJECT_VALUECHANGE);
      }
   }
}
