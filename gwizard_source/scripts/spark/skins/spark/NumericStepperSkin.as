package spark.skins.spark
{
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.events.PropertyChangeEvent;
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.components.Button;
   import spark.components.NumericStepper;
   import spark.components.TextInput;
   import spark.skins.SparkSkin;
   
   public class NumericStepperSkin extends SparkSkin implements IStateClient2
   {
      
      private static const exclusions:Array = ["textDisplay","decrementButton","incrementButton"];
       
      
      private var _853009829decrementButton:Button;
      
      private var _454226047incrementButton:Button;
      
      private var _831827669textDisplay:TextInput;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var cornerRadiusChanged:Boolean;
      
      private var borderStylesChanged:Boolean;
      
      private var _213507019hostComponent:NumericStepper;
      
      public function NumericStepperSkin()
      {
         super();
         mx_internal::_document = this;
         this.minHeight = 23;
         this.minWidth = 40;
         this.mxmlContent = [this._NumericStepperSkin_Button1_i(),this._NumericStepperSkin_Button2_i(),this._NumericStepperSkin_TextInput1_i()];
         this.currentState = "normal";
         states = [new State({
            "name":"normal",
            "overrides":[]
         }),new State({
            "name":"disabled",
            "overrides":[new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         })];
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      override public function get colorizeExclusions() : Array
      {
         return exclusions;
      }
      
      override protected function initializationComplete() : void
      {
         useChromeColor = true;
         super.initializationComplete();
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:Number = NaN;
         super.commitProperties();
         if(this.cornerRadiusChanged)
         {
            _loc1_ = getStyle("cornerRadius");
            if(this.incrementButton)
            {
               this.incrementButton.setStyle("cornerRadius",_loc1_);
            }
            if(this.decrementButton)
            {
               this.decrementButton.setStyle("cornerRadius",_loc1_);
            }
            this.cornerRadiusChanged = false;
         }
         if(this.borderStylesChanged)
         {
            this.textDisplay.setStyle("borderAlpha",getStyle("borderAlpha"));
            this.textDisplay.setStyle("borderColor",getStyle("borderColor"));
            this.textDisplay.setStyle("borderVisible",getStyle("borderVisible"));
            this.borderStylesChanged = false;
         }
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc2_:Boolean = !param1 || param1 == "styleName";
         super.styleChanged(param1);
         if(_loc2_ || param1 == "cornerRadius")
         {
            this.cornerRadiusChanged = true;
            invalidateProperties();
         }
         if(_loc2_ || param1.indexOf("border") == 0)
         {
            this.borderStylesChanged = true;
            invalidateProperties();
         }
      }
      
      private function _NumericStepperSkin_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.percentHeight = 50;
         _loc1_.tabEnabled = false;
         _loc1_.setStyle("skinClass",NumericStepperIncrementButtonSkin);
         _loc1_.id = "incrementButton";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.incrementButton = _loc1_;
         BindingManager.executeBindings(this,"incrementButton",this.incrementButton);
         return _loc1_;
      }
      
      private function _NumericStepperSkin_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.percentHeight = 50;
         _loc1_.tabEnabled = false;
         _loc1_.setStyle("skinClass",NumericStepperDecrementButtonSkin);
         _loc1_.id = "decrementButton";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.decrementButton = _loc1_;
         BindingManager.executeBindings(this,"decrementButton",this.decrementButton);
         return _loc1_;
      }
      
      private function _NumericStepperSkin_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.left = 0;
         _loc1_.top = 0;
         _loc1_.right = 18;
         _loc1_.bottom = 0;
         _loc1_.setStyle("skinClass",NumericStepperTextInputSkin);
         _loc1_.id = "textDisplay";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.textDisplay = _loc1_;
         BindingManager.executeBindings(this,"textDisplay",this.textDisplay);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get decrementButton() : Button
      {
         return this._853009829decrementButton;
      }
      
      public function set decrementButton(param1:Button) : void
      {
         var _loc2_:Object = this._853009829decrementButton;
         if(_loc2_ !== param1)
         {
            this._853009829decrementButton = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"decrementButton",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get incrementButton() : Button
      {
         return this._454226047incrementButton;
      }
      
      public function set incrementButton(param1:Button) : void
      {
         var _loc2_:Object = this._454226047incrementButton;
         if(_loc2_ !== param1)
         {
            this._454226047incrementButton = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"incrementButton",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get textDisplay() : TextInput
      {
         return this._831827669textDisplay;
      }
      
      public function set textDisplay(param1:TextInput) : void
      {
         var _loc2_:Object = this._831827669textDisplay;
         if(_loc2_ !== param1)
         {
            this._831827669textDisplay = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"textDisplay",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : NumericStepper
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._213507019hostComponent;
         if(_loc2_ !== param1)
         {
            this._213507019hostComponent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hostComponent",_loc2_,param1));
            }
         }
      }
   }
}
