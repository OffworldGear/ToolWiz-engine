package mx.controls
{
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.ui.Keyboard;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.core.EdgeMetrics;
   import mx.core.IFlexDisplayObject;
   import mx.core.ILayoutDirectionElement;
   import mx.core.IRectangularBorder;
   import mx.core.IUIComponent;
   import mx.core.UIComponent;
   import mx.core.UIComponentGlobals;
   import mx.core.mx_internal;
   import mx.effects.Tween;
   import mx.events.DropdownEvent;
   import mx.events.FlexMouseEvent;
   import mx.events.ListEvent;
   import mx.events.MenuEvent;
   import mx.events.SandboxMouseEvent;
   import mx.managers.IFocusManagerComponent;
   import mx.managers.ISystemManager;
   import mx.managers.PopUpManager;
   import mx.styles.ISimpleStyleClient;
   
   use namespace mx_internal;
   
   public class PopUpButton extends Button
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var inTween:Boolean = false;
      
      private var showingPopUp:Boolean = false;
      
      private var tween:Tween = null;
      
      private var arrowButtonsWidth:Number = 0;
      
      private var arrowButtonsHeight:Number = 0;
      
      private var popUpIconChanged:Boolean = false;
      
      private var popUpChanged:Boolean = false;
      
      private var _closeOnActivity:Boolean = true;
      
      private var _openAlways:Boolean = false;
      
      private var _popUp:IUIComponent = null;
      
      public function PopUpButton()
      {
         super();
         addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
      }
      
      override public function set showInAutomationHierarchy(param1:Boolean) : void
      {
      }
      
      override public function set toggle(param1:Boolean) : void
      {
      }
      
      public function get closeOnActivity() : Boolean
      {
         return this._closeOnActivity;
      }
      
      public function set closeOnActivity(param1:Boolean) : void
      {
         this._closeOnActivity = param1;
      }
      
      public function get openAlways() : Boolean
      {
         return this._openAlways;
      }
      
      public function set openAlways(param1:Boolean) : void
      {
         this._openAlways = param1;
      }
      
      [Bindable(event="popUpChanged")]
      public function get popUp() : IUIComponent
      {
         return this._popUp;
      }
      
      public function set popUp(param1:IUIComponent) : void
      {
         this._popUp = param1;
         this.popUpChanged = true;
         invalidateProperties();
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:ISystemManager = null;
         super.commitProperties();
         if(this.popUpChanged)
         {
            if(this._popUp is IFocusManagerComponent)
            {
               IFocusManagerComponent(this._popUp).focusEnabled = false;
            }
            this._popUp.cacheAsBitmap = true;
            this._popUp.scrollRect = new Rectangle(0,0,0,0);
            if(this._popUp is Menu)
            {
               this._popUp.addEventListener(MenuEvent.MENU_HIDE,this.menuHideHandler);
            }
            if(this._popUp is IListItemRenderer)
            {
               this._popUp.addEventListener(ListEvent.ITEM_CLICK,this.popUpItemClickHandler);
            }
            this._popUp.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,this.popMouseDownOutsideHandler);
            this._popUp.addEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE,this.popMouseDownOutsideHandler);
            this._popUp.addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,this.popMouseDownOutsideHandler);
            this._popUp.addEventListener(SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE,this.popMouseDownOutsideHandler);
            _loc1_ = systemManager.topLevelSystemManager;
            _loc1_.getSandboxRoot().addEventListener(Event.RESIZE,this.stage_resizeHandler,false,0,true);
            this._popUp.owner = this;
            if(this._popUp is ISimpleStyleClient)
            {
               ISimpleStyleClient(this._popUp).styleName = getStyle("popUpStyleName");
            }
            this.popUpChanged = false;
         }
         if(this.showingPopUp && !enabled)
         {
            this.close();
         }
      }
      
      override protected function measure() : void
      {
         super.measure();
         this.calcArrowButtonSize();
         measuredWidth += this.arrowButtonsWidth;
         measuredHeight = this.arrowButtonsHeight;
      }
      
      override public function styleChanged(param1:String) : void
      {
         if(param1 == null || param1 == "styleName" || param1.toLowerCase().indexOf("popupicon") != -1)
         {
            this.popUpIconChanged = true;
            changeSkins();
         }
         if(param1 == "arrowButtonWidth")
         {
            invalidateSize();
         }
         else if(param1 == "popUpStyleName" && this._popUp && this._popUp is ISimpleStyleClient)
         {
            ISimpleStyleClient(this._popUp).styleName = getStyle("popUpStyleName");
         }
         super.styleChanged(param1);
      }
      
      override mx_internal function layoutContents(param1:Number, param2:Number, param3:Boolean) : void
      {
         if(!isNaN(explicitWidth) && !isNaN(explicitHeight) || this.popUpIconChanged)
         {
            this.calcArrowButtonSize();
            this.popUpIconChanged = false;
         }
         param1 -= this.arrowButtonsWidth;
         super.layoutContents(param1,param2,param3);
         param1 += this.arrowButtonsWidth;
      }
      
      override mx_internal function viewSkin() : void
      {
         var _loc1_:* = null;
         var _loc2_:String = null;
         if(!enabled)
         {
            _loc1_ = "disabledSkin";
         }
         else if(mx_internal::phase == "arrowOver")
         {
            _loc1_ = "popUpOverSkin";
         }
         else if(mx_internal::phase == "arrowDown")
         {
            _loc1_ = "popUpDownSkin";
         }
         else
         {
            _loc1_ = mx_internal::phase + "Skin";
         }
         viewSkinForPhase(_loc1_,this.getCurrentButtonState());
      }
      
      override mx_internal function getCurrentIconName() : String
      {
         var _loc1_:* = super.getCurrentIconName();
         if(_loc1_)
         {
            return _loc1_;
         }
         if(mx_internal::phase == "arrowOver")
         {
            _loc1_ = !!selected ? mx_internal::selectedOverIconName : mx_internal::overIconName;
         }
         else if(mx_internal::phase == "arrowDown")
         {
            _loc1_ = !!selected ? mx_internal::selectedDownIconName : mx_internal::downIconName;
         }
         else
         {
            _loc1_ = mx_internal::phase + "Icon";
         }
         return _loc1_;
      }
      
      override mx_internal function viewIcon() : void
      {
         var _loc1_:* = null;
         if(!enabled)
         {
            _loc1_ = "disabledIcon";
         }
         else if(mx_internal::phase == "arrowOver")
         {
            _loc1_ = !!selected ? mx_internal::selectedOverIconName : mx_internal::overIconName;
         }
         else if(mx_internal::phase == "arrowDown")
         {
            _loc1_ = !!selected ? mx_internal::selectedDownIconName : mx_internal::downIconName;
         }
         else
         {
            _loc1_ = mx_internal::phase + "Icon";
         }
         viewIconForPhase(_loc1_);
      }
      
      override mx_internal function getCurrentButtonState() : String
      {
         _currentButtonState = "";
         if(!enabled)
         {
            _currentButtonState = "disabled";
         }
         else if(mx_internal::phase == "arrowOver")
         {
            _currentButtonState = "popUpOver";
         }
         else if(mx_internal::phase == "arrowDown")
         {
            _currentButtonState = "popUpDown";
         }
         else
         {
            _currentButtonState = mx_internal::phase;
         }
         return _currentButtonState;
      }
      
      mx_internal function getPopUp() : IUIComponent
      {
         return !!this._popUp ? this._popUp : null;
      }
      
      public function open() : void
      {
         this.openWithEvent(null);
      }
      
      private function openWithEvent(param1:Event = null) : void
      {
         var _loc2_:DropdownEvent = null;
         if(!this.showingPopUp && enabled)
         {
            this.displayPopUp(true);
            _loc2_ = new DropdownEvent(DropdownEvent.OPEN);
            _loc2_.triggerEvent = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function close() : void
      {
         this.closeWithEvent(null);
      }
      
      private function closeWithEvent(param1:Event = null) : void
      {
         var _loc2_:DropdownEvent = null;
         if(this.showingPopUp)
         {
            this.displayPopUp(false);
            _loc2_ = new DropdownEvent(DropdownEvent.CLOSE);
            _loc2_.triggerEvent = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      private function displayPopUp(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Function = null;
         var _loc5_:Number = NaN;
         if(!initialized || param1 == this.showingPopUp)
         {
            return;
         }
         if(this.getPopUp() == null)
         {
            return;
         }
         if(this._popUp is ILayoutDirectionElement)
         {
            ILayoutDirectionElement(this._popUp).layoutDirection = layoutDirection;
         }
         var _loc6_:ISystemManager;
         var _loc7_:Rectangle = (_loc6_ = systemManager.topLevelSystemManager).getVisibleApplicationRect(null,true);
         if(param1)
         {
            if(this._popUp.parent == null)
            {
               PopUpManager.addPopUp(this._popUp,this,false);
               this._popUp.owner = this;
            }
            else
            {
               PopUpManager.bringToFront(this._popUp);
            }
         }
         var _loc8_:Number = getStyle("popUpGap");
         var _loc9_:Point = new Point(layoutDirection == "rtl" ? Number(this._popUp.getExplicitOrMeasuredWidth()) : Number(0),unscaledHeight + _loc8_);
         _loc9_ = localToGlobal(_loc9_);
         if(param1)
         {
            if(_loc9_.y + this._popUp.height > _loc7_.bottom && _loc9_.y > _loc7_.top + height + this._popUp.height)
            {
               _loc9_.y -= unscaledHeight + this._popUp.height + 2 * _loc8_;
               _loc2_ = -this._popUp.height;
            }
            else
            {
               _loc2_ = this._popUp.height;
            }
            _loc9_.x = Math.min(_loc9_.x,_loc7_.right - this._popUp.getExplicitOrMeasuredWidth());
            _loc9_.x = Math.max(_loc9_.x,0);
            _loc9_ = this._popUp.parent.globalToLocal(_loc9_);
            if(this._popUp.x != _loc9_.x || this._popUp.y != _loc9_.y)
            {
               this._popUp.move(_loc9_.x,_loc9_.y);
            }
            this._popUp.scrollRect = new Rectangle(0,_loc2_,this._popUp.width,this._popUp.height);
            if(!this._popUp.visible)
            {
               this._popUp.visible = true;
            }
            _loc3_ = 0;
            this.showingPopUp = param1;
            _loc5_ = getStyle("openDuration");
            _loc4_ = getStyle("openEasingFunction") as Function;
         }
         else
         {
            this.showingPopUp = param1;
            if(this._popUp.parent == null)
            {
               return;
            }
            _loc3_ = (_loc9_ = this._popUp.parent.globalToLocal(_loc9_)).y + this._popUp.height > _loc7_.bottom && _loc9_.y > _loc7_.top + height + this._popUp.height ? Number(-this._popUp.height - 2) : Number(this._popUp.height + 2);
            _loc2_ = 0;
            _loc5_ = getStyle("closeDuration");
            _loc4_ = getStyle("closeEasingFunction") as Function;
         }
         this.inTween = true;
         UIComponentGlobals.layoutManager.validateNow();
         UIComponent.suspendBackgroundProcessing();
         this.tween = new Tween(this,_loc2_,_loc3_,_loc5_);
         if(_loc4_ != null)
         {
            this.tween.easingFunction = _loc4_;
         }
      }
      
      private function calcArrowButtonSize() : void
      {
         var _loc1_:EdgeMetrics = null;
         var _loc3_:Class = null;
         if(mx_internal::currentSkin is IRectangularBorder)
         {
            _loc1_ = IRectangularBorder(mx_internal::currentSkin).borderMetrics;
         }
         else
         {
            _loc1_ = new EdgeMetrics(3,3,3,3);
         }
         var _loc2_:IFlexDisplayObject = IFlexDisplayObject(getChildByName("popUpIcon"));
         if(!_loc2_)
         {
            _loc3_ = Class(getStyle("popUpIcon"));
            _loc2_ = new _loc3_();
         }
         this.arrowButtonsWidth = Math.max(getStyle("arrowButtonWidth"),_loc2_.width + _loc1_.right + 1);
         this.arrowButtonsHeight = Math.max(measuredHeight,_loc2_.height + _loc1_.top + _loc1_.bottom);
      }
      
      mx_internal function overArrowButton(param1:MouseEvent) : Boolean
      {
         return param1.localX >= unscaledWidth - this.arrowButtonsWidth;
      }
      
      mx_internal function onTweenUpdate(param1:Number) : void
      {
         this._popUp.scrollRect = new Rectangle(0,param1,this._popUp.width,this._popUp.height);
      }
      
      mx_internal function onTweenEnd(param1:Number) : void
      {
         this._popUp.scrollRect = new Rectangle(0,param1,this._popUp.width,this._popUp.height);
         this.inTween = false;
         UIComponent.resumeBackgroundProcessing();
         if(!this.showingPopUp)
         {
            this._popUp.visible = false;
            this._popUp.scrollRect = null;
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         super.keyDownHandler(param1);
         if(param1.ctrlKey && param1.keyCode == Keyboard.DOWN)
         {
            this.openWithEvent(param1);
            param1.stopPropagation();
         }
         else if(param1.ctrlKey && param1.keyCode == Keyboard.UP || param1.keyCode == Keyboard.ESCAPE)
         {
            this.closeWithEvent(param1);
            param1.stopPropagation();
         }
         else if(param1.keyCode == Keyboard.ENTER && this.showingPopUp)
         {
            this._popUp.dispatchEvent(param1);
            this.closeWithEvent(param1);
            param1.stopPropagation();
         }
         else if(this.showingPopUp && (param1.keyCode == Keyboard.UP || param1.keyCode == Keyboard.DOWN || param1.keyCode == Keyboard.LEFT || param1.keyCode == Keyboard.RIGHT || param1.keyCode == Keyboard.PAGE_UP || param1.keyCode == Keyboard.PAGE_DOWN))
         {
            this._popUp.dispatchEvent(param1);
            param1.stopPropagation();
         }
      }
      
      override protected function focusOutHandler(param1:FocusEvent) : void
      {
         var _loc2_:Menu = null;
         if(this.showingPopUp && this._popUp && param1.target == this)
         {
            if(!param1.relatedObject)
            {
               this.close();
            }
            else if(param1.relatedObject is Menu)
            {
               _loc2_ = Menu(param1.relatedObject);
               while(_loc2_.parentMenu)
               {
                  _loc2_ = _loc2_.parentMenu;
               }
               if(this._popUp is DisplayObjectContainer && !DisplayObjectContainer(this._popUp).contains(_loc2_))
               {
                  this.close();
               }
            }
            else if(this._popUp is DisplayObjectContainer && !DisplayObjectContainer(this._popUp).contains(param1.relatedObject))
            {
               this.close();
            }
         }
         super.focusOutHandler(param1);
      }
      
      override protected function rollOverHandler(param1:MouseEvent) : void
      {
         if(this.overArrowButton(param1))
         {
            phase = "arrowOver";
            this.viewSkin();
            return;
         }
         super.rollOverHandler(param1);
      }
      
      override protected function rollOutHandler(param1:MouseEvent) : void
      {
         if(this.overArrowButton(param1))
         {
            phase = "up";
            this.viewSkin();
            return;
         }
         super.rollOutHandler(param1);
      }
      
      override protected function mouseDownHandler(param1:MouseEvent) : void
      {
         if(this.overArrowButton(param1))
         {
            phase = "arrowDown";
            this.viewSkin();
            return;
         }
         super.mouseDownHandler(param1);
      }
      
      override protected function mouseUpHandler(param1:MouseEvent) : void
      {
         if(this.overArrowButton(param1))
         {
            phase = "arrowOver";
            this.viewSkin();
            return;
         }
         super.mouseUpHandler(param1);
      }
      
      override protected function clickHandler(param1:MouseEvent) : void
      {
         if(this.overArrowButton(param1))
         {
            if(this.showingPopUp)
            {
               this.closeWithEvent(param1);
            }
            else
            {
               this.openWithEvent(param1);
            }
            param1.stopImmediatePropagation();
         }
         else
         {
            super.clickHandler(param1);
            if(this.openAlways)
            {
               if(this.showingPopUp)
               {
                  this.closeWithEvent(param1);
               }
               else
               {
                  this.openWithEvent(param1);
               }
            }
         }
      }
      
      private function mouseMoveHandler(param1:MouseEvent) : void
      {
         if(mx_internal::phase == "over" || mx_internal::phase == "arrowOver")
         {
            phase = !!this.overArrowButton(param1) ? "arrowOver" : "over";
            this.viewSkin();
         }
      }
      
      private function popUpItemClickHandler(param1:Event) : void
      {
         if(this._closeOnActivity)
         {
            this.close();
         }
      }
      
      private function menuHideHandler(param1:MenuEvent) : void
      {
         if(param1.menu != Menu(this._popUp).getRootMenu())
         {
            return;
         }
         this.showingPopUp = true;
         this._popUp.visible = true;
         this.displayPopUp(false);
      }
      
      private function popMouseDownOutsideHandler(param1:Event) : void
      {
         var _loc2_:MouseEvent = null;
         var _loc3_:Point = null;
         if(param1 is MouseEvent)
         {
            _loc2_ = MouseEvent(param1);
            _loc3_ = param1.target.localToGlobal(new Point(_loc2_.localX,_loc2_.localY));
            if(!hitTestPoint(_loc3_.x,_loc3_.y,true))
            {
               this.close();
            }
         }
         else if(param1 is SandboxMouseEvent)
         {
            this.close();
         }
      }
      
      private function removedFromStageHandler(param1:Event) : void
      {
         if(this._popUp)
         {
            PopUpManager.removePopUp(this._popUp);
            this.showingPopUp = false;
         }
      }
      
      private function stage_resizeHandler(param1:Event) : void
      {
         this._popUp.visible = false;
         this.close();
      }
      
      mx_internal function get isShowingPopUp() : Boolean
      {
         return this.showingPopUp;
      }
      
      mx_internal function getArrowButtonsWidth() : Number
      {
         return this.arrowButtonsWidth;
      }
   }
}
