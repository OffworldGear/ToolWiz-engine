package spark.skins.spark
{
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.events.PropertyChangeEvent;
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.components.Button;
   import spark.components.Spinner;
   import spark.skins.SparkSkin;
   
   public class SpinnerSkin extends SparkSkin implements IStateClient2
   {
      
      private static const exclusions:Array = ["decrementButton","incrementButton"];
       
      
      private var _853009829decrementButton:Button;
      
      private var _454226047incrementButton:Button;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var cornerRadiusChanged:Boolean;
      
      private var _213507019hostComponent:Spinner;
      
      public function SpinnerSkin()
      {
         super();
         mx_internal::_document = this;
         this.minHeight = 23;
         this.minWidth = 12;
         this.mxmlContent = [this._SpinnerSkin_Button1_i(),this._SpinnerSkin_Button2_i()];
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
      }
      
      private function _SpinnerSkin_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.percentHeight = 50;
         _loc1_.tabEnabled = false;
         _loc1_.setStyle("skinClass",SpinnerIncrementButtonSkin);
         _loc1_.id = "incrementButton";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.incrementButton = _loc1_;
         BindingManager.executeBindings(this,"incrementButton",this.incrementButton);
         return _loc1_;
      }
      
      private function _SpinnerSkin_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.percentHeight = 50;
         _loc1_.tabEnabled = false;
         _loc1_.setStyle("skinClass",SpinnerDecrementButtonSkin);
         _loc1_.id = "decrementButton";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.decrementButton = _loc1_;
         BindingManager.executeBindings(this,"decrementButton",this.decrementButton);
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
      public function get hostComponent() : Spinner
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:Spinner) : void
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
