package mx.containers
{
   import flash.display.DisplayObject;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import mx.controls.Button;
   import mx.controls.TabBar;
   import mx.core.Container;
   import mx.core.EdgeMetrics;
   import mx.core.IFlexDisplayObject;
   import mx.core.IInvalidating;
   import mx.core.IProgrammaticSkin;
   import mx.core.IUIComponent;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.managers.IFocusManagerComponent;
   import mx.styles.StyleProxy;
   
   use namespace mx_internal;
   
   public class TabNavigator extends ViewStack implements IFocusManagerComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const MIN_TAB_WIDTH:Number = 30;
      
      private static var _tabBarStyleFilters:Object = {
         "firstTabStyleName":"firstTabStyleName",
         "horizontalAlign":"horizontalAlign",
         "horizontalGap":"horizontalGap",
         "lastTabStyleName":"lastTabStyleName",
         "selectedTabTextStyleName":"selectedTabTextStyleName",
         "tabStyleName":"tabStyleName",
         "tabWidth":"tabWidth",
         "verticalAlign":"verticalAlign",
         "verticalGap":"verticalGap"
      };
       
      
      protected var tabBar:TabBar;
      
      public function TabNavigator()
      {
         super();
         tabEnabled = true;
         tabFocusEnabled = true;
         hasFocusableChildren = true;
         historyManagementEnabled = true;
      }
      
      override public function get baselinePosition() : Number
      {
         var _loc4_:Container = null;
         if(!validateBaselinePosition())
         {
            return NaN;
         }
         var _loc1_:* = numChildren == 0;
         if(_loc1_)
         {
            _loc4_ = new Container();
            addChild(_loc4_);
            validateNow();
         }
         var _loc2_:Button = this.getTabAt(0);
         var _loc3_:Number = this.tabBar.y + _loc2_.y + _loc2_.baselinePosition;
         if(_loc1_)
         {
            removeChildAt(0);
            validateNow();
         }
         return _loc3_;
      }
      
      override protected function get contentHeight() : Number
      {
         var _loc1_:EdgeMetrics = viewMetricsAndPadding;
         var _loc2_:Number = _loc1_.top;
         var _loc3_:Number = _loc1_.bottom;
         if(isNaN(_loc2_))
         {
            _loc2_ = 0;
         }
         if(isNaN(_loc3_))
         {
            _loc3_ = 0;
         }
         return unscaledHeight - this.tabBarHeight - _loc2_ - _loc3_;
      }
      
      override protected function get contentY() : Number
      {
         var _loc1_:Number = getStyle("paddingTop");
         if(isNaN(_loc1_))
         {
            _loc1_ = 0;
         }
         return this.tabBarHeight + _loc1_;
      }
      
      private function get tabBarHeight() : Number
      {
         var _loc1_:Number = getStyle("tabHeight");
         if(isNaN(_loc1_))
         {
            _loc1_ = this.tabBar.getExplicitOrMeasuredHeight();
         }
         return _loc1_ - borderMetrics.top;
      }
      
      protected function get tabBarStyleFilters() : Object
      {
         return _tabBarStyleFilters;
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         if(!this.tabBar)
         {
            this.tabBar = new TabBar();
            this.tabBar.name = "tabBar";
            this.tabBar.focusEnabled = false;
            this.tabBar.styleName = new StyleProxy(this,this.tabBarStyleFilters);
            rawChildren.addChild(this.tabBar);
         }
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(this.tabBar && this.tabBar.dataProvider != this && numChildren > 0 && getChildAt(0))
         {
            this.tabBar.dataProvider = this;
         }
      }
      
      override protected function measure() : void
      {
         var _loc1_:Number = NaN;
         if(mx_internal::vsPreferredWidth && !resizeToContent)
         {
            measuredMinWidth = mx_internal::vsMinWidth;
            measuredMinHeight = mx_internal::vsMinHeight;
            measuredWidth = mx_internal::vsPreferredWidth;
            measuredHeight = mx_internal::vsPreferredHeight;
            return;
         }
         super.measure();
         _loc1_ = this.tabBarHeight;
         measuredMinHeight += _loc1_;
         measuredHeight += _loc1_;
         var _loc2_:Number = getStyle("tabWidth");
         if(isNaN(_loc2_))
         {
            _loc2_ = 0;
         }
         var _loc3_:Number = numChildren * Math.max(_loc2_,MIN_TAB_WIDTH);
         var _loc4_:EdgeMetrics = viewMetrics;
         _loc3_ += _loc4_.left + _loc4_.right;
         if(numChildren > 1)
         {
            _loc3_ += getStyle("horizontalGap") * (numChildren - 1);
         }
         if(measuredWidth < _loc3_)
         {
            measuredWidth = _loc3_;
         }
         if(selectedChild && selectedChild.deferredContentCreated == false)
         {
            return;
         }
         if(numChildren == 0)
         {
            return;
         }
         vsMinWidth = measuredMinWidth;
         vsMinHeight = measuredMinHeight;
         vsPreferredWidth = measuredWidth;
         vsPreferredHeight = measuredHeight;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         var _loc3_:EdgeMetrics = borderMetrics;
         var _loc4_:EdgeMetrics = viewMetrics;
         var _loc5_:Number = param1 - _loc4_.left - _loc4_.right;
         var _loc6_:Number = this.tabBarHeight + _loc3_.top;
         var _loc7_:Number = this.tabBar.getExplicitOrMeasuredWidth();
         this.tabBar.setActualSize(Math.min(_loc5_,_loc7_),_loc6_);
         var _loc8_:Number = getStyle("tabOffset");
         switch(getStyle("horizontalAlign"))
         {
            case "left":
               this.tabBar.move(0 + _loc8_,this.tabBar.y);
               break;
            case "right":
               this.tabBar.move(param1 - this.tabBar.width + _loc8_,this.tabBar.y);
               break;
            case "center":
               this.tabBar.move((param1 - this.tabBar.width) / 2 + _loc8_,this.tabBar.y);
         }
      }
      
      override public function drawFocus(param1:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         super.drawFocus(param1);
         if(!parent)
         {
            return;
         }
         var _loc2_:DisplayObject = IUIComponent(parent).focusPane;
         if(param1 && !mx_internal::isEffectStarted)
         {
            if(_loc2_)
            {
               if(parent is Container)
               {
                  _loc3_ = Container(parent).rawChildren.numChildren;
                  _loc4_ = Container(parent).firstChildIndex;
                  Container(parent).rawChildren.setChildIndex(_loc2_,Math.max(0,_loc4_ == _loc3_ ? Number(_loc3_ - 1) : Number(_loc4_)));
               }
               else if(parent is UIComponent)
               {
                  UIComponent(parent).$setChildIndex(_loc2_,0);
               }
               else
               {
                  parent.setChildIndex(_loc2_,0);
               }
            }
         }
         else if(_loc2_)
         {
            if(parent is Container)
            {
               Container(parent).rawChildren.setChildIndex(_loc2_,Container(parent).rawChildren.numChildren - 1);
            }
            else if(parent is UIComponent)
            {
               UIComponent(parent).$setChildIndex(_loc2_,parent.numChildren - 1);
            }
            else
            {
               parent.setChildIndex(_loc2_,parent.numChildren - 1);
            }
         }
         this.tabBar.drawFocus(param1);
      }
      
      override protected function adjustFocusRect(param1:DisplayObject = null) : void
      {
         super.adjustFocusRect(param1);
         var _loc2_:IFlexDisplayObject = IFlexDisplayObject(getFocusObject());
         if(_loc2_)
         {
            _loc2_.setActualSize(_loc2_.width,_loc2_.height - this.tabBarHeight);
            _loc2_.move(_loc2_.x,_loc2_.y + this.tabBarHeight);
            if(_loc2_ is IInvalidating)
            {
               IInvalidating(_loc2_).validateNow();
            }
            else if(_loc2_ is IProgrammaticSkin)
            {
               IProgrammaticSkin(_loc2_).validateNow();
            }
         }
      }
      
      override protected function layoutChrome(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         super.layoutChrome(param1,param2);
         if(mx_internal::border)
         {
            _loc3_ = this.tabBarHeight;
            mx_internal::border.setActualSize(param1,param2 - _loc3_);
            mx_internal::border.move(0,_loc3_);
         }
      }
      
      public function getTabAt(param1:int) : Button
      {
         return Button(this.tabBar.getChildAt(param1));
      }
      
      override protected function focusInHandler(param1:FocusEvent) : void
      {
         super.focusInHandler(param1);
         if(param1.target == this)
         {
            focusManager.defaultButtonEnabled = false;
         }
      }
      
      override protected function focusOutHandler(param1:FocusEvent) : void
      {
         super.focusOutHandler(param1);
         if(focusManager && param1.target == this)
         {
            focusManager.defaultButtonEnabled = true;
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(focusManager.getFocus() == this)
         {
            this.tabBar.dispatchEvent(param1);
         }
      }
      
      mx_internal function getTabBar() : TabBar
      {
         return this.tabBar;
      }
   }
}
