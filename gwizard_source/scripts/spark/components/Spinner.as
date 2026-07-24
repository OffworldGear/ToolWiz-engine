package spark.components
{
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.managers.IFocusManagerComponent;
   import spark.components.supportClasses.Range;
   
   use namespace mx_internal;
   
   public class Spinner extends Range implements IFocusManagerComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      mx_internal static var createAccessibilityImplementation:Function;
       
      
      [SkinPart(required="false")]
      public var decrementButton:Button;
      
      [SkinPart(required="false")]
      public var incrementButton:Button;
      
      private var _allowValueWrap:Boolean = false;
      
      public function Spinner()
      {
         super();
      }
      
      public function get allowValueWrap() : Boolean
      {
         return this._allowValueWrap;
      }
      
      public function set allowValueWrap(param1:Boolean) : void
      {
         this._allowValueWrap = param1;
      }
      
      override protected function initializeAccessibility() : void
      {
         if(Spinner.createAccessibilityImplementation != null)
         {
            Spinner.createAccessibilityImplementation(this);
         }
      }
      
      override protected function partAdded(param1:String, param2:Object) : void
      {
         super.partAdded(param1,param2);
         if(param2 == this.incrementButton)
         {
            this.incrementButton.focusEnabled = false;
            this.incrementButton.addEventListener(FlexEvent.BUTTON_DOWN,this.incrementButton_buttonDownHandler);
            this.incrementButton.autoRepeat = true;
         }
         else if(param2 == this.decrementButton)
         {
            this.decrementButton.focusEnabled = false;
            this.decrementButton.addEventListener(FlexEvent.BUTTON_DOWN,this.decrementButton_buttonDownHandler);
            this.decrementButton.autoRepeat = true;
         }
      }
      
      override protected function partRemoved(param1:String, param2:Object) : void
      {
         super.partRemoved(param1,param2);
         if(param2 == this.incrementButton)
         {
            this.incrementButton.removeEventListener(FlexEvent.BUTTON_DOWN,this.incrementButton_buttonDownHandler);
         }
         else if(param2 == this.decrementButton)
         {
            this.decrementButton.removeEventListener(FlexEvent.BUTTON_DOWN,this.decrementButton_buttonDownHandler);
         }
      }
      
      override protected function getCurrentSkinState() : String
      {
         return !!enabled ? "normal" : "disabled";
      }
      
      override public function changeValueByStep(param1:Boolean = true) : void
      {
         if(this.allowValueWrap)
         {
            if(param1 && value == maximum)
            {
               value = minimum;
            }
            else if(!param1 && value == minimum)
            {
               value = maximum;
            }
            else
            {
               super.changeValueByStep(param1);
            }
         }
         else
         {
            super.changeValueByStep(param1);
         }
      }
      
      protected function incrementButton_buttonDownHandler(param1:Event) : void
      {
         var _loc2_:Number = this.value;
         this.changeValueByStep(true);
         if(value != _loc2_)
         {
            dispatchEvent(new Event("change"));
         }
      }
      
      protected function decrementButton_buttonDownHandler(param1:Event) : void
      {
         var _loc2_:Number = this.value;
         this.changeValueByStep(false);
         if(value != _loc2_)
         {
            dispatchEvent(new Event("change"));
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         var _loc2_:Number = this.value;
         switch(param1.keyCode)
         {
            case Keyboard.DOWN:
               this.changeValueByStep(false);
               param1.preventDefault();
               break;
            case Keyboard.UP:
               this.changeValueByStep(true);
               param1.preventDefault();
               break;
            case Keyboard.HOME:
               value = minimum;
               param1.preventDefault();
               break;
            case Keyboard.END:
               value = maximum;
               param1.preventDefault();
               break;
            default:
               super.keyDownHandler(param1);
         }
         if(value != _loc2_)
         {
            dispatchEvent(new Event("change"));
         }
      }
      
      override protected function focusInHandler(param1:FocusEvent) : void
      {
         super.focusInHandler(param1);
         systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_WHEEL,this.system_mouseWheelHandler,true);
      }
      
      override protected function focusOutHandler(param1:FocusEvent) : void
      {
         super.focusOutHandler(param1);
         systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_WHEEL,this.system_mouseWheelHandler,true);
      }
      
      protected function system_mouseWheelHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         if(!param1.isDefaultPrevented())
         {
            _loc2_ = nearestValidValue(value + param1.delta * stepSize,stepSize);
            setValue(_loc2_);
            dispatchEvent(new Event(Event.CHANGE));
            param1.preventDefault();
         }
      }
   }
}
