package mx.skins.spark
{
   import flash.geom.Rectangle;
   import mx.binding.BindingManager;
   import mx.core.EdgeMetrics;
   import mx.core.IFlexModuleFactory;
   import mx.core.IRectangularBorder;
   import mx.core.IUIComponent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.RectangularDropShadow;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import spark.primitives.Rect;
   
   public class BorderSkin extends SparkSkinForHalo implements IRectangularBorder
   {
      
      private static const exclusions:Array = ["background"];
      
      private static const contentFill:Array = ["bgFill"];
      
      private static const borderItem:Array = ["borderStroke"];
      
      private static const metrics:EdgeMetrics = new EdgeMetrics(1,1,1,1);
       
      
      private var _1332194002background:Rect;
      
      private var _1391998104bgFill:SolidColor;
      
      private var _1383304148border:Rect;
      
      private var _1395787140borderStroke:SolidColorStroke;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _583595847cornerRadius:Number = 0;
      
      private var dropShadow:RectangularDropShadow;
      
      public function BorderSkin()
      {
         super();
         mx_internal::_document = this;
         this.mouseEnabled = false;
         this.mouseChildren = false;
         this.mxmlContent = [this._BorderSkin_Rect1_i(),this._BorderSkin_Rect2_i()];
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
      
      override public function get contentItems() : Array
      {
         return contentFill;
      }
      
      override protected function get borderItems() : Array
      {
         return borderItem;
      }
      
      override protected function get defaultBorderItemColor() : uint
      {
         return getStyle("borderColor");
      }
      
      override protected function get defaultBorderAlpha() : Number
      {
         return getStyle("borderAlpha");
      }
      
      public function get borderMetrics() : EdgeMetrics
      {
         if(getStyle("borderVisible") == false || getStyle("borderStyle") == "none")
         {
            return EdgeMetrics.EMPTY;
         }
         return metrics;
      }
      
      public function get backgroundImageBounds() : Rectangle
      {
         return null;
      }
      
      public function set backgroundImageBounds(param1:Rectangle) : void
      {
      }
      
      public function get hasBackgroundImage() : Boolean
      {
         return false;
      }
      
      public function layoutBackgroundImage() : void
      {
      }
      
      override protected function initializationComplete() : void
      {
         useChromeColor = true;
         super.initializationComplete();
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         redrawRequested = true;
         if(getStyle("borderVisible") == false || getStyle("borderStyle") == "none")
         {
            this.border.visible = false;
            this.background.left = this.background.top = this.background.right = this.background.bottom = 0;
         }
         else
         {
            this.border.visible = true;
            this.background.left = this.background.top = this.background.right = this.background.bottom = 1;
         }
         this.border.radiusX = this.cornerRadius;
         this.background.radiusX = this.cornerRadius;
         super.updateDisplayList(param1,param2);
         if(parent && parent is IUIComponent && !IUIComponent(parent).enabled)
         {
            alpha = 0.5;
         }
         else
         {
            alpha = 1;
         }
         if(getStyle("dropShadowVisible") == false || width == 0 || height == 0)
         {
            return;
         }
         if(!this.dropShadow)
         {
            this.dropShadow = new RectangularDropShadow();
         }
         this.dropShadow.distance = 5;
         this.dropShadow.angle = 90;
         this.dropShadow.color = 0;
         this.dropShadow.alpha = 0.8;
         this.dropShadow.blurX = 20;
         this.dropShadow.blurY = 20;
         graphics.lineStyle();
         this.dropShadow.drawShadow(graphics,0,0,width,height);
      }
      
      private function getDropShadowAngle(param1:Number, param2:String) : Number
      {
         if(param2 == "left")
         {
            return param1 >= 0 ? Number(135) : Number(225);
         }
         if(param2 == "right")
         {
            return param1 >= 0 ? Number(45) : Number(315);
         }
         return param1 >= 0 ? Number(90) : Number(270);
      }
      
      private function _BorderSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.radiusX = 0;
         _loc1_.stroke = this._BorderSkin_SolidColorStroke1_i();
         _loc1_.initialized(this,"border");
         this.border = _loc1_;
         BindingManager.executeBindings(this,"border",this.border);
         return _loc1_;
      }
      
      private function _BorderSkin_SolidColorStroke1_i() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         this.borderStroke = _loc1_;
         BindingManager.executeBindings(this,"borderStroke",this.borderStroke);
         return _loc1_;
      }
      
      private function _BorderSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.radiusX = 0;
         _loc1_.fill = this._BorderSkin_SolidColor1_i();
         _loc1_.initialized(this,"background");
         this.background = _loc1_;
         BindingManager.executeBindings(this,"background",this.background);
         return _loc1_;
      }
      
      private function _BorderSkin_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         this.bgFill = _loc1_;
         BindingManager.executeBindings(this,"bgFill",this.bgFill);
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
      public function get bgFill() : SolidColor
      {
         return this._1391998104bgFill;
      }
      
      public function set bgFill(param1:SolidColor) : void
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
      public function get border() : Rect
      {
         return this._1383304148border;
      }
      
      public function set border(param1:Rect) : void
      {
         var _loc2_:Object = this._1383304148border;
         if(_loc2_ !== param1)
         {
            this._1383304148border = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"border",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get borderStroke() : SolidColorStroke
      {
         return this._1395787140borderStroke;
      }
      
      public function set borderStroke(param1:SolidColorStroke) : void
      {
         var _loc2_:Object = this._1395787140borderStroke;
         if(_loc2_ !== param1)
         {
            this._1395787140borderStroke = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"borderStroke",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cornerRadius() : Number
      {
         return this._583595847cornerRadius;
      }
      
      public function set cornerRadius(param1:Number) : void
      {
         var _loc2_:Object = this._583595847cornerRadius;
         if(_loc2_ !== param1)
         {
            this._583595847cornerRadius = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cornerRadius",_loc2_,param1));
            }
         }
      }
   }
}
