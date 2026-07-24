package spark.components
{
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.globalization.LocaleID;
   import flash.globalization.NumberFormatter;
   import mx.core.IIMESupport;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.managers.IFocusManagerComponent;
   
   use namespace mx_internal;
   
   public class NumericStepper extends Spinner implements IFocusManagerComponent, IIMESupport
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      mx_internal static var createAccessibilityImplementation:Function;
       
      
      [SkinPart(required="true")]
      public var textDisplay:TextInput;
      
      private var dataFormatter:NumberFormatter;
      
      private var maxChanged:Boolean = false;
      
      private var stepSizeChanged:Boolean = false;
      
      private var _maxChars:int = 0;
      
      private var maxCharsChanged:Boolean = false;
      
      private var _valueFormatFunction:Function;
      
      private var valueFormatFunctionChanged:Boolean;
      
      private var _valueParseFunction:Function;
      
      private var valueParseFunctionChanged:Boolean;
      
      private var _imeMode:String = null;
      
      private var imeModeChanged:Boolean = false;
      
      public function NumericStepper()
      {
         super();
         this.maximum = 10;
      }
      
      override public function get baselinePosition() : Number
      {
         return getBaselinePositionForPart(this.textDisplay);
      }
      
      override public function set maximum(param1:Number) : void
      {
         this.maxChanged = true;
         super.maximum = param1;
      }
      
      override public function set stepSize(param1:Number) : void
      {
         this.stepSizeChanged = true;
         super.stepSize = param1;
      }
      
      public function get enableIME() : Boolean
      {
         if(this.textDisplay && this.textDisplay.textDisplay)
         {
            return this.textDisplay.textDisplay.editable;
         }
         return true;
      }
      
      public function get maxChars() : int
      {
         return this._maxChars;
      }
      
      public function set maxChars(param1:int) : void
      {
         if(param1 == this._maxChars)
         {
            return;
         }
         this._maxChars = param1;
         this.maxCharsChanged = true;
         invalidateProperties();
      }
      
      public function get valueFormatFunction() : Function
      {
         return this._valueFormatFunction;
      }
      
      public function set valueFormatFunction(param1:Function) : void
      {
         this._valueFormatFunction = param1;
         this.valueFormatFunctionChanged = true;
         invalidateProperties();
      }
      
      public function get valueParseFunction() : Function
      {
         return this._valueParseFunction;
      }
      
      public function set valueParseFunction(param1:Function) : void
      {
         this._valueParseFunction = param1;
         this.valueParseFunctionChanged = true;
         invalidateProperties();
      }
      
      public function get imeMode() : String
      {
         return this._imeMode;
      }
      
      public function set imeMode(param1:String) : void
      {
         this._imeMode = param1;
         this.imeModeChanged = true;
         invalidateProperties();
      }
      
      override protected function initializeAccessibility() : void
      {
         if(NumericStepper.createAccessibilityImplementation != null)
         {
            NumericStepper.createAccessibilityImplementation(this);
         }
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(this.maxChanged || this.stepSizeChanged || this.valueFormatFunctionChanged)
         {
            this.textDisplay.widthInChars = this.calculateWidestValue();
            this.maxChanged = false;
            this.stepSizeChanged = false;
            if(this.valueFormatFunctionChanged)
            {
               this.applyDisplayFormatFunction();
               this.valueFormatFunctionChanged = false;
            }
         }
         if(this.valueParseFunctionChanged)
         {
            this.commitTextInput(false);
            this.valueParseFunctionChanged = false;
         }
         if(this.maxCharsChanged)
         {
            this.textDisplay.maxChars = this._maxChars;
            this.maxCharsChanged = false;
         }
         if(this.imeModeChanged)
         {
            this.textDisplay.imeMode = this._imeMode;
            this.imeModeChanged = false;
         }
      }
      
      override protected function partAdded(param1:String, param2:Object) : void
      {
         super.partAdded(param1,param2);
         if(param2 == this.textDisplay)
         {
            this.textDisplay.addEventListener(FlexEvent.ENTER,this.textDisplay_enterHandler);
            this.textDisplay.addEventListener(FocusEvent.FOCUS_OUT,this.textDisplay_focusOutHandler);
            this.textDisplay.focusEnabled = false;
            this.textDisplay.maxChars = this._maxChars;
            this.textDisplay.restrict = "0-9\\-\\.\\,";
            this.textDisplay.text = value.toString();
            this.textDisplay.widthInChars = this.calculateWidestValue();
         }
      }
      
      override protected function partRemoved(param1:String, param2:Object) : void
      {
         super.partRemoved(param1,param2);
         if(param2 == this.textDisplay)
         {
            this.textDisplay.removeEventListener(FlexEvent.ENTER,this.textDisplay_enterHandler);
         }
      }
      
      override public function setFocus() : void
      {
         if(stage)
         {
            stage.focus = this.textDisplay.textDisplay as InteractiveObject;
            if(this.textDisplay.textDisplay && (this.textDisplay.textDisplay.editable || this.textDisplay.textDisplay.selectable))
            {
               this.textDisplay.textDisplay.selectAll();
            }
         }
      }
      
      override protected function isOurFocus(param1:DisplayObject) : Boolean
      {
         return param1 == this.textDisplay.textDisplay;
      }
      
      override protected function setValue(param1:Number) : void
      {
         super.setValue(param1);
         this.applyDisplayFormatFunction();
      }
      
      override public function changeValueByStep(param1:Boolean = true) : void
      {
         this.commitTextInput();
         super.changeValueByStep(param1);
      }
      
      private function commitTextInput(param1:Boolean = false) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = value;
         if(this.valueParseFunction != null)
         {
            _loc2_ = this.valueParseFunction(this.textDisplay.text);
         }
         else
         {
            if(this.dataFormatter == null)
            {
               this.dataFormatter = new NumberFormatter(LocaleID.DEFAULT);
            }
            _loc2_ = this.dataFormatter.parseNumber(this.textDisplay.text);
         }
         if(this.textDisplay.text && this.textDisplay.text.length != value.toString().length || this.textDisplay.text == "" || _loc2_ != value && (Math.abs(_loc2_ - value) >= 0.000001 || isNaN(_loc2_)))
         {
            this.setValue(nearestValidValue(_loc2_,snapInterval));
            if(value == _loc3_ && _loc2_ != _loc3_)
            {
               dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
         }
         if(param1)
         {
            if(value != _loc3_)
            {
               dispatchEvent(new Event(Event.CHANGE));
            }
         }
      }
      
      private function calculateWidestValue() : Number
      {
         var _loc1_:Number = minimum.toString().length > maximum.toString().length ? Number(minimum) : Number(maximum);
         _loc1_ += stepSize;
         if(this.valueFormatFunction != null)
         {
            return this.valueFormatFunction(_loc1_).length;
         }
         return _loc1_.toString().length;
      }
      
      private function applyDisplayFormatFunction() : void
      {
         if(this.valueFormatFunction != null)
         {
            this.textDisplay.text = this.valueFormatFunction(value);
         }
         else
         {
            this.textDisplay.text = value.toString();
         }
      }
      
      override protected function focusInHandler(param1:FocusEvent) : void
      {
         super.focusInHandler(param1);
         addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler,true);
      }
      
      override protected function focusOutHandler(param1:FocusEvent) : void
      {
         super.focusOutHandler(param1);
         removeEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler,true);
      }
      
      private function textDisplay_enterHandler(param1:Event) : void
      {
         this.commitTextInput(true);
      }
      
      private function textDisplay_focusOutHandler(param1:Event) : void
      {
         this.commitTextInput(true);
      }
   }
}
