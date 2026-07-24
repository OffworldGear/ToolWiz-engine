package spark.skins.spark.windowChrome
{
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.GradientEntry;
   import mx.graphics.LinearGradient;
   import mx.states.State;
   import spark.components.Button;
   import spark.components.Group;
   import spark.components.Label;
   import spark.components.windowClasses.TitleBar;
   import spark.layouts.HorizontalLayout;
   import spark.primitives.BitmapImage;
   import spark.primitives.Rect;
   import spark.skins.SparkSkin;
   
   public class MacTitleBarSkin extends SparkSkin implements IStateClient2
   {
      
      private static const exclusions:Array = ["titleIconImage","titleText"];
       
      
      private var _1332194002background:Rect;
      
      private var _1391998104bgFill:LinearGradient;
      
      private var _312699062closeButton:Button;
      
      private var _488002274maximizeButton:Button;
      
      private var _168913776minimizeButton:Button;
      
      private var _896192468spacer:Spacer;
      
      private var _41320214titleIconImage:BitmapImage;
      
      private var _2135756891titleText:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _213507019hostComponent:TitleBar;
      
      public function MacTitleBarSkin()
      {
         super();
         mx_internal::_document = this;
         this.minHeight = 24;
         this.mxmlContent = [this._MacTitleBarSkin_Rect1_i(),this._MacTitleBarSkin_Group1_c()];
         this.currentState = "normal";
         states = [new State({
            "name":"normal",
            "overrides":[]
         }),new State({
            "name":"disabled",
            "overrides":[]
         }),new State({
            "name":"normalAndMaximized",
            "stateGroups":["maximizedGroup"],
            "overrides":[]
         }),new State({
            "name":"disabledAndMaximized",
            "stateGroups":["maximizedGroup"],
            "overrides":[]
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
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         this.spacer.width = Math.max(0,(this.hostComponent.width - this.titleText.getPreferredBoundsWidth() - this.titleIconImage.getPreferredBoundsWidth() - 4 - 5) / 2 - 58);
      }
      
      private function _MacTitleBarSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.radiusX = 2;
         _loc1_.radiusY = 2;
         _loc1_.fill = this._MacTitleBarSkin_LinearGradient1_i();
         _loc1_.initialized(this,"background");
         this.background = _loc1_;
         BindingManager.executeBindings(this,"background",this.background);
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_LinearGradient1_i() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._MacTitleBarSkin_GradientEntry1_c(),this._MacTitleBarSkin_GradientEntry2_c()];
         this.bgFill = _loc1_;
         BindingManager.executeBindings(this,"bgFill",this.bgFill);
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_GradientEntry1_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_GradientEntry2_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 12237498;
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_Group1_c() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.minHeight = 24;
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.left = 2;
         _loc1_.right = 2;
         _loc1_.layout = this._MacTitleBarSkin_HorizontalLayout1_c();
         _loc1_.mxmlContent = [this._MacTitleBarSkin_Button1_i(),this._MacTitleBarSkin_Button2_i(),this._MacTitleBarSkin_Button3_i(),this._MacTitleBarSkin_Spacer1_i(),this._MacTitleBarSkin_BitmapImage1_i(),this._MacTitleBarSkin_Label1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_HorizontalLayout1_c() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = new HorizontalLayout();
         _loc1_.verticalAlign = "middle";
         _loc1_.gap = 5;
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.verticalCenter = 0;
         _loc1_.setStyle("skinClass",MacCloseButtonSkin);
         _loc1_.id = "closeButton";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.closeButton = _loc1_;
         BindingManager.executeBindings(this,"closeButton",this.closeButton);
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.verticalCenter = 0;
         _loc1_.setStyle("skinClass",MacMinimizeButtonSkin);
         _loc1_.id = "minimizeButton";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.minimizeButton = _loc1_;
         BindingManager.executeBindings(this,"minimizeButton",this.minimizeButton);
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.verticalCenter = 0;
         _loc1_.setStyle("skinClass",MacMaximizeButtonSkin);
         _loc1_.id = "maximizeButton";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.maximizeButton = _loc1_;
         BindingManager.executeBindings(this,"maximizeButton",this.maximizeButton);
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_Spacer1_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.minWidth = 0;
         _loc1_.id = "spacer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.spacer = _loc1_;
         BindingManager.executeBindings(this,"spacer",this.spacer);
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_BitmapImage1_i() : BitmapImage
      {
         var _loc1_:BitmapImage = new BitmapImage();
         _loc1_.minWidth = 0;
         _loc1_.fillMode = "clip";
         _loc1_.initialized(this,"titleIconImage");
         this.titleIconImage = _loc1_;
         BindingManager.executeBindings(this,"titleIconImage",this.titleIconImage);
         return _loc1_;
      }
      
      private function _MacTitleBarSkin_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.minWidth = 0;
         _loc1_.maxDisplayedLines = 1;
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("fontSize",9);
         _loc1_.setStyle("color",5789784);
         _loc1_.id = "titleText";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.titleText = _loc1_;
         BindingManager.executeBindings(this,"titleText",this.titleText);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get background() : Rect
      {
         return this._1332194002background;
      }
      
      public function set background(param1:Rect) : void
      {
         var _loc2_:Object = this._1332194002background;
         if(_loc2_ !== param1)
         {
            this._1332194002background = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"background",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get bgFill() : LinearGradient
      {
         return this._1391998104bgFill;
      }
      
      public function set bgFill(param1:LinearGradient) : void
      {
         var _loc2_:Object = this._1391998104bgFill;
         if(_loc2_ !== param1)
         {
            this._1391998104bgFill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bgFill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get closeButton() : Button
      {
         return this._312699062closeButton;
      }
      
      public function set closeButton(param1:Button) : void
      {
         var _loc2_:Object = this._312699062closeButton;
         if(_loc2_ !== param1)
         {
            this._312699062closeButton = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"closeButton",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get maximizeButton() : Button
      {
         return this._488002274maximizeButton;
      }
      
      public function set maximizeButton(param1:Button) : void
      {
         var _loc2_:Object = this._488002274maximizeButton;
         if(_loc2_ !== param1)
         {
            this._488002274maximizeButton = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"maximizeButton",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get minimizeButton() : Button
      {
         return this._168913776minimizeButton;
      }
      
      public function set minimizeButton(param1:Button) : void
      {
         var _loc2_:Object = this._168913776minimizeButton;
         if(_loc2_ !== param1)
         {
            this._168913776minimizeButton = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"minimizeButton",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get spacer() : Spacer
      {
         return this._896192468spacer;
      }
      
      public function set spacer(param1:Spacer) : void
      {
         var _loc2_:Object = this._896192468spacer;
         if(_loc2_ !== param1)
         {
            this._896192468spacer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"spacer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get titleIconImage() : BitmapImage
      {
         return this._41320214titleIconImage;
      }
      
      public function set titleIconImage(param1:BitmapImage) : void
      {
         var _loc2_:Object = this._41320214titleIconImage;
         if(_loc2_ !== param1)
         {
            this._41320214titleIconImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"titleIconImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get titleText() : Label
      {
         return this._2135756891titleText;
      }
      
      public function set titleText(param1:Label) : void
      {
         var _loc2_:Object = this._2135756891titleText;
         if(_loc2_ !== param1)
         {
            this._2135756891titleText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"titleText",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : TitleBar
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:TitleBar) : void
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
