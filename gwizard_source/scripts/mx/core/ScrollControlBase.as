package mx.core
{
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import mx.controls.HScrollBar;
   import mx.controls.VScrollBar;
   import mx.controls.scrollClasses.ScrollBar;
   import mx.events.ScrollEvent;
   import mx.events.ScrollEventDetail;
   import mx.events.ScrollEventDirection;
   import mx.managers.ToolTipManager;
   import mx.styles.ISimpleStyleClient;
   
   use namespace mx_internal;
   
   public class ScrollControlBase extends UIComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      protected var border:IFlexDisplayObject;
      
      private var _viewMetrics:EdgeMetrics;
      
      protected var maskShape:Shape;
      
      protected var horizontalScrollBar:ScrollBar;
      
      protected var verticalScrollBar:ScrollBar;
      
      private var numberOfCols:Number = 0;
      
      private var numberOfRows:Number = 0;
      
      mx_internal var _maxVerticalScrollPosition:Number;
      
      mx_internal var _maxHorizontalScrollPosition:Number;
      
      private var viewableRows:Number;
      
      private var viewableColumns:Number;
      
      private var propsInited:Boolean;
      
      protected var scrollAreaChanged:Boolean;
      
      private var invLayout:Boolean;
      
      private var scrollTip:IToolTip;
      
      private var scrollThumbMidPoint:Number;
      
      private var oldTTMEnabled:Boolean;
      
      mx_internal var _horizontalScrollPosition:Number = 0;
      
      mx_internal var _horizontalScrollPolicy:String = "off";
      
      public var liveScrolling:Boolean = true;
      
      private var _scrollTipFunction:Function;
      
      public var showScrollTips:Boolean = false;
      
      mx_internal var _verticalScrollPosition:Number = 0;
      
      mx_internal var _verticalScrollPolicy:String = "auto";
      
      public function ScrollControlBase()
      {
         super();
         this._viewMetrics = EdgeMetrics.EMPTY;
         addEventListener(MouseEvent.MOUSE_WHEEL,this.mouseWheelHandler);
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         if(this.horizontalScrollBar)
         {
            this.horizontalScrollBar.enabled = param1;
         }
         if(this.verticalScrollBar)
         {
            this.verticalScrollBar.enabled = param1;
         }
      }
      
      public function get borderMetrics() : EdgeMetrics
      {
         return this.border && this.border is IRectangularBorder ? IRectangularBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
      }
      
      [Bindable("viewChanged")]
      [Bindable("scroll")]
      public function get horizontalScrollPosition() : Number
      {
         return this._horizontalScrollPosition;
      }
      
      public function set horizontalScrollPosition(param1:Number) : void
      {
         this._horizontalScrollPosition = param1;
         if(this.horizontalScrollBar)
         {
            this.horizontalScrollBar.scrollPosition = param1;
         }
         dispatchEvent(new Event("viewChanged"));
      }
      
      [Bindable("horizontalScrollPolicyChanged")]
      public function get horizontalScrollPolicy() : String
      {
         return this._horizontalScrollPolicy;
      }
      
      public function set horizontalScrollPolicy(param1:String) : void
      {
         var _loc2_:String = param1.toLowerCase();
         if(this._horizontalScrollPolicy != _loc2_)
         {
            this._horizontalScrollPolicy = _loc2_;
            invalidateDisplayList();
            dispatchEvent(new Event("horizontalScrollPolicyChanged"));
         }
      }
      
      [Bindable("maxHorizontalScrollPositionChanged")]
      public function get maxHorizontalScrollPosition() : Number
      {
         if(!isNaN(this._maxHorizontalScrollPosition))
         {
            return this._maxHorizontalScrollPosition;
         }
         return Number(!!this.horizontalScrollBar ? Number(this.horizontalScrollBar.maxScrollPosition) : Number(0));
      }
      
      public function set maxHorizontalScrollPosition(param1:Number) : void
      {
         this._maxHorizontalScrollPosition = param1;
         dispatchEvent(new Event("maxHorizontalScrollPositionChanged"));
      }
      
      [Bindable("maxVerticalScrollPositionChanged")]
      public function get maxVerticalScrollPosition() : Number
      {
         if(!isNaN(this._maxVerticalScrollPosition))
         {
            return this._maxVerticalScrollPosition;
         }
         return Number(!!this.verticalScrollBar ? Number(this.verticalScrollBar.maxScrollPosition) : Number(0));
      }
      
      public function set maxVerticalScrollPosition(param1:Number) : void
      {
         this._maxVerticalScrollPosition = param1;
         dispatchEvent(new Event("maxVerticalScrollPositionChanged"));
      }
      
      [Bindable("scrollTipFunctionChanged")]
      public function get scrollTipFunction() : Function
      {
         return this._scrollTipFunction;
      }
      
      public function set scrollTipFunction(param1:Function) : void
      {
         this._scrollTipFunction = param1;
         dispatchEvent(new Event("scrollTipFunctionChanged"));
      }
      
      public function get viewMetrics() : EdgeMetrics
      {
         this._viewMetrics = this.borderMetrics.clone();
         if(!this.horizontalScrollBar && this.horizontalScrollPolicy == ScrollPolicy.ON)
         {
            this.createHScrollBar(true);
            this.horizontalScrollBar.addEventListener(ScrollEvent.SCROLL,this.scrollHandler);
            this.horizontalScrollBar.addEventListener(ScrollEvent.SCROLL,this.scrollTipHandler);
            this.horizontalScrollBar.scrollPosition = this._horizontalScrollPosition;
            invalidateDisplayList();
         }
         if(!this.verticalScrollBar && this.verticalScrollPolicy == ScrollPolicy.ON)
         {
            this.createVScrollBar(true);
            this.verticalScrollBar.addEventListener(ScrollEvent.SCROLL,this.scrollHandler);
            this.verticalScrollBar.addEventListener(ScrollEvent.SCROLL,this.scrollTipHandler);
            this.verticalScrollBar.scrollPosition = this._verticalScrollPosition;
            invalidateDisplayList();
         }
         if(this.verticalScrollBar && this.verticalScrollBar.visible)
         {
            this._viewMetrics.right += this.verticalScrollBar.minWidth;
         }
         if(this.horizontalScrollBar && this.horizontalScrollBar.visible)
         {
            this._viewMetrics.bottom += this.horizontalScrollBar.minHeight;
         }
         return this._viewMetrics;
      }
      
      [Bindable("viewChanged")]
      [Bindable("scroll")]
      public function get verticalScrollPosition() : Number
      {
         return this._verticalScrollPosition;
      }
      
      public function set verticalScrollPosition(param1:Number) : void
      {
         this._verticalScrollPosition = param1;
         if(this.verticalScrollBar)
         {
            this.verticalScrollBar.scrollPosition = param1;
         }
         dispatchEvent(new Event("viewChanged"));
      }
      
      [Bindable("verticalScrollPolicyChanged")]
      public function get verticalScrollPolicy() : String
      {
         return this._verticalScrollPolicy;
      }
      
      public function set verticalScrollPolicy(param1:String) : void
      {
         var _loc2_:String = param1.toLowerCase();
         if(this._verticalScrollPolicy != _loc2_)
         {
            this._verticalScrollPolicy = _loc2_;
            invalidateDisplayList();
            dispatchEvent(new Event("verticalScrollPolicyChanged"));
         }
      }
      
      override protected function createChildren() : void
      {
         var _loc1_:Graphics = null;
         super.createChildren();
         this.createBorder();
         if(!this.maskShape)
         {
            this.maskShape = new FlexShape();
            this.maskShape.name = "mask";
            _loc1_ = this.maskShape.graphics;
            _loc1_.beginFill(16777215);
            _loc1_.drawRect(0,0,10,10);
            _loc1_.endFill();
            addChild(this.maskShape);
         }
         this.maskShape.visible = false;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         this.layoutChrome(param1,param2);
         var _loc3_:Number = param1;
         var _loc4_:Number = param2;
         this.invLayout = false;
         var _loc5_:EdgeMetrics = this._viewMetrics = this.viewMetrics;
         if(this.horizontalScrollBar && this.horizontalScrollBar.visible)
         {
            this.horizontalScrollBar.setActualSize(_loc3_ - _loc5_.left - _loc5_.right,this.horizontalScrollBar.minHeight);
            this.horizontalScrollBar.move(_loc5_.left,_loc4_ - _loc5_.bottom);
            this.horizontalScrollBar.enabled = enabled;
         }
         if(this.verticalScrollBar && this.verticalScrollBar.visible)
         {
            this.verticalScrollBar.setActualSize(this.verticalScrollBar.minWidth,_loc4_ - _loc5_.top - _loc5_.bottom);
            this.verticalScrollBar.move(_loc3_ - _loc5_.right,_loc5_.top);
            this.verticalScrollBar.enabled = enabled;
         }
         var _loc6_:DisplayObject = this.maskShape;
         var _loc7_:Number = _loc3_ - _loc5_.left - _loc5_.right;
         var _loc8_:Number = _loc4_ - _loc5_.top - _loc5_.bottom;
         _loc6_.width = _loc7_ < 0 ? Number(0) : Number(_loc7_);
         _loc6_.height = _loc8_ < 0 ? Number(0) : Number(_loc8_);
         _loc6_.x = _loc5_.left;
         _loc6_.y = _loc5_.top;
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:Boolean = param1 == null || param1 == "styleName";
         super.styleChanged(param1);
         if(_loc2_ || param1 == "horizontalScrollBarStyleName")
         {
            if(this.horizontalScrollBar)
            {
               _loc3_ = getStyle("horizontalScrollBarStyleName");
               this.horizontalScrollBar.styleName = _loc3_;
            }
         }
         if(_loc2_ || param1 == "verticalScrollBarStyleName")
         {
            if(this.verticalScrollBar)
            {
               _loc4_ = getStyle("verticalScrollBarStyleName");
               this.verticalScrollBar.styleName = _loc4_;
            }
         }
         if(_loc2_ || param1 == "borderSkin")
         {
            if(this.border)
            {
               removeChild(DisplayObject(this.border));
               this.border = null;
               this.createBorder();
            }
         }
      }
      
      protected function layoutChrome(param1:Number, param2:Number) : void
      {
         if(this.border)
         {
            this.border.move(0,0);
            this.border.setActualSize(param1,param2);
         }
      }
      
      protected function createBorder() : void
      {
         var _loc1_:Class = null;
         if(!this.border && this.isBorderNeeded())
         {
            _loc1_ = getStyle("borderSkin");
            if(_loc1_ != null)
            {
               this.border = new _loc1_();
               if(FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
               {
                  if(this.border is IUIComponent)
                  {
                     IUIComponent(this.border).enabled = enabled;
                  }
               }
               if(this.border is ISimpleStyleClient)
               {
                  ISimpleStyleClient(this.border).styleName = this;
               }
               addChildAt(DisplayObject(this.border),0);
               invalidateDisplayList();
            }
         }
      }
      
      private function isBorderNeeded() : Boolean
      {
         var _loc1_:Object = getStyle("borderStyle");
         if(_loc1_)
         {
            if(_loc1_ != "none" || _loc1_ == "none" && getStyle("mouseShield"))
            {
               return true;
            }
         }
         _loc1_ = getStyle("backgroundColor");
         if(_loc1_ !== null && _loc1_ !== "")
         {
            return true;
         }
         _loc1_ = getStyle("backgroundImage");
         return _loc1_ != null && _loc1_ != "";
      }
      
      protected function setScrollBarProperties(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc7_:Boolean = false;
         var _loc5_:String = this.horizontalScrollPolicy;
         var _loc6_:String = this.verticalScrollPolicy;
         this.scrollAreaChanged = false;
         if(_loc5_ == ScrollPolicy.ON || param2 < param1 && param1 > 0 && _loc5_ == ScrollPolicy.AUTO)
         {
            if(!this.horizontalScrollBar)
            {
               this.createHScrollBar(false);
               this.horizontalScrollBar.addEventListener(ScrollEvent.SCROLL,this.scrollHandler);
               this.horizontalScrollBar.addEventListener(ScrollEvent.SCROLL,this.scrollTipHandler);
               this.horizontalScrollBar.scrollPosition = this._horizontalScrollPosition;
            }
            if((_loc7_ = this.roomForScrollBar(this.horizontalScrollBar,unscaledWidth,unscaledHeight)) != this.horizontalScrollBar.visible)
            {
               this.horizontalScrollBar.visible = _loc7_;
               this.scrollAreaChanged = true;
            }
            if(this.horizontalScrollBar && this.horizontalScrollBar.visible && (this.numberOfCols != param1 || this.viewableColumns != param2 || this.scrollAreaChanged))
            {
               this.horizontalScrollBar.setScrollProperties(param2,0,param1 - param2);
               if(this.horizontalScrollBar.scrollPosition != this._horizontalScrollPosition)
               {
                  this.horizontalScrollBar.scrollPosition = this._horizontalScrollPosition;
               }
               this.viewableColumns = param2;
               this.numberOfCols = param1;
            }
         }
         else if((_loc5_ == ScrollPolicy.AUTO || _loc5_ == ScrollPolicy.OFF) && this.horizontalScrollBar && this.horizontalScrollBar.visible)
         {
            this.horizontalScrollPosition = 0;
            this.horizontalScrollBar.setScrollProperties(param2,0,0);
            this.horizontalScrollBar.visible = false;
            this.viewableColumns = NaN;
            this.scrollAreaChanged = true;
         }
         if(_loc6_ == ScrollPolicy.ON || param4 < param3 && param3 > 0 && _loc6_ == ScrollPolicy.AUTO)
         {
            if(!this.verticalScrollBar)
            {
               this.createVScrollBar(false);
               this.verticalScrollBar.addEventListener(ScrollEvent.SCROLL,this.scrollHandler);
               this.verticalScrollBar.addEventListener(ScrollEvent.SCROLL,this.scrollTipHandler);
               this.verticalScrollBar.scrollPosition = this._verticalScrollPosition;
            }
            if((_loc7_ = this.roomForScrollBar(this.verticalScrollBar,unscaledWidth,unscaledHeight)) != this.verticalScrollBar.visible)
            {
               this.verticalScrollBar.visible = _loc7_;
               this.scrollAreaChanged = true;
            }
            if(this.verticalScrollBar && this.verticalScrollBar.visible && (this.numberOfRows != param3 || this.viewableRows != param4 || this.scrollAreaChanged))
            {
               this.verticalScrollBar.setScrollProperties(param4,0,param3 - param4);
               if(this.verticalScrollBar.scrollPosition != this._verticalScrollPosition)
               {
                  this.verticalScrollBar.scrollPosition = this._verticalScrollPosition;
               }
               this.viewableRows = param4;
               this.numberOfRows = param3;
            }
         }
         else if((_loc6_ == ScrollPolicy.AUTO || _loc6_ == ScrollPolicy.OFF) && this.verticalScrollBar && this.verticalScrollBar.visible)
         {
            this.verticalScrollPosition = 0;
            this.verticalScrollBar.setScrollProperties(param4,0,0);
            this.verticalScrollBar.visible = false;
            this.viewableRows = NaN;
            this.scrollAreaChanged = true;
         }
         if(this.scrollAreaChanged)
         {
            this.updateDisplayList(unscaledWidth,unscaledHeight);
         }
      }
      
      private function createHScrollBar(param1:Boolean) : ScrollBar
      {
         this.horizontalScrollBar = new HScrollBar();
         this.horizontalScrollBar.visible = param1;
         this.horizontalScrollBar.enabled = enabled;
         var _loc2_:String = getStyle("horizontalScrollBarStyleName");
         this.horizontalScrollBar.styleName = _loc2_;
         addChild(this.horizontalScrollBar);
         this.horizontalScrollBar.validateNow();
         return this.horizontalScrollBar;
      }
      
      private function createVScrollBar(param1:Boolean) : ScrollBar
      {
         this.verticalScrollBar = new VScrollBar();
         this.verticalScrollBar.visible = param1;
         this.verticalScrollBar.enabled = enabled;
         var _loc2_:String = getStyle("verticalScrollBarStyleName");
         this.verticalScrollBar.styleName = _loc2_;
         addChild(this.verticalScrollBar);
         UIComponentGlobals.layoutManager.validateClient(this.verticalScrollBar,true);
         return this.verticalScrollBar;
      }
      
      protected function roomForScrollBar(param1:ScrollBar, param2:Number, param3:Number) : Boolean
      {
         var _loc4_:EdgeMetrics = this.borderMetrics;
         return param2 >= param1.minWidth + _loc4_.left + _loc4_.right && param3 >= param1.minHeight + _loc4_.top + _loc4_.bottom;
      }
      
      protected function scrollHandler(param1:Event) : void
      {
         var _loc2_:ScrollBar = null;
         var _loc3_:Number = NaN;
         var _loc4_:QName = null;
         if(param1 is ScrollEvent)
         {
            _loc2_ = ScrollBar(param1.target);
            _loc3_ = _loc2_.scrollPosition;
            if(_loc2_ == this.verticalScrollBar)
            {
               _loc4_ = new QName(mx_internal,"_verticalScrollPosition");
            }
            else if(_loc2_ == this.horizontalScrollBar)
            {
               _loc4_ = new QName(mx_internal,"_horizontalScrollPosition");
            }
            dispatchEvent(param1);
            if(_loc4_)
            {
               this[_loc4_] = _loc3_;
            }
         }
      }
      
      private function scrollTipHandler(param1:Event) : void
      {
         var _loc2_:ScrollBar = null;
         var _loc3_:* = false;
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         var _loc7_:Point = null;
         if(param1 is ScrollEvent)
         {
            if(!this.showScrollTips)
            {
               return;
            }
            if(ScrollEvent(param1).detail == ScrollEventDetail.THUMB_POSITION)
            {
               if(this.scrollTip)
               {
                  ToolTipManager.destroyToolTip(this.scrollTip);
                  this.scrollTip = null;
                  ToolTipManager.enabled = this.oldTTMEnabled;
               }
            }
            else if(ScrollEvent(param1).detail == ScrollEventDetail.THUMB_TRACK)
            {
               _loc2_ = ScrollBar(param1.target);
               _loc3_ = _loc2_ == this.verticalScrollBar;
               _loc4_ = !!_loc3_ ? "vertical" : "horizontal";
               _loc5_ = _loc2_.scrollPosition;
               if(!this.scrollTip)
               {
                  this.scrollTip = ToolTipManager.createToolTip("",0,0,null,this);
                  this.scrollThumbMidPoint = _loc2_.scrollThumb.height / 2;
                  this.oldTTMEnabled = ToolTipManager.enabled;
                  ToolTipManager.enabled = false;
               }
               _loc6_ = _loc5_.toString();
               if(this._scrollTipFunction != null)
               {
                  _loc6_ = this._scrollTipFunction(_loc4_,_loc5_);
               }
               if(_loc6_ == "")
               {
                  this.scrollTip.visible = false;
               }
               else
               {
                  this.scrollTip.text = _loc6_;
                  ToolTipManager.sizeTip(this.scrollTip);
                  _loc7_ = new Point();
                  if(_loc3_)
                  {
                     _loc7_.x = -3 - this.scrollTip.width;
                     _loc7_.y = _loc2_.scrollThumb.y + this.scrollThumbMidPoint - this.scrollTip.height / 2;
                  }
                  else
                  {
                     _loc7_.x = -3 - this.scrollTip.height;
                     _loc7_.y = _loc2_.scrollThumb.y + this.scrollThumbMidPoint - this.scrollTip.width / 2;
                  }
                  _loc7_ = _loc2_.localToGlobal(_loc7_);
                  this.scrollTip.move(_loc7_.x,_loc7_.y);
                  this.scrollTip.visible = true;
               }
            }
         }
      }
      
      protected function mouseWheelHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:ScrollEvent = null;
         if(this.verticalScrollBar && this.verticalScrollBar.visible && !param1.isDefaultPrevented())
         {
            _loc2_ = param1.delta <= 0 ? 1 : -1;
            _loc3_ = Math.max(Math.abs(param1.delta),this.verticalScrollBar.lineScrollSize);
            _loc4_ = this.verticalScrollPosition;
            this.verticalScrollPosition += 3 * _loc3_ * _loc2_;
            (_loc5_ = new ScrollEvent(ScrollEvent.SCROLL)).direction = ScrollEventDirection.VERTICAL;
            _loc5_.position = this.verticalScrollPosition;
            _loc5_.delta = this.verticalScrollPosition - _loc4_;
            dispatchEvent(_loc5_);
            param1.preventDefault();
         }
      }
      
      mx_internal function get scroll_verticalScrollBar() : ScrollBar
      {
         return this.verticalScrollBar;
      }
      
      mx_internal function get scroll_horizontalScrollBar() : ScrollBar
      {
         return this.horizontalScrollBar;
      }
   }
}
