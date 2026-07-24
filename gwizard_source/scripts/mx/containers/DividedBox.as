package mx.containers
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import mx.containers.dividedBoxClasses.BoxDivider;
   import mx.core.EdgeMetrics;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IInvalidating;
   import mx.core.IUIComponent;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.ChildExistenceChangedEvent;
   import mx.events.DividerEvent;
   import mx.managers.CursorManager;
   import mx.managers.CursorManagerPriority;
   
   use namespace mx_internal;
   
   public class DividedBox extends Box
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const PROXY_DIVIDER_INDEX:int = 999;
       
      
      private var dividerLayer:UIComponent = null;
      
      mx_internal var activeDivider:BoxDivider;
      
      private var activeDividerIndex:int = -1;
      
      private var activeDividerStartPosition:Number;
      
      private var dragStartPosition:Number;
      
      private var dragDelta:Number;
      
      private var oldChildSizes:Array;
      
      private var minDelta:Number;
      
      private var maxDelta:Number;
      
      private var dontCoalesceDividers:Boolean;
      
      private var cursorID:int = 0;
      
      private var dbMinWidth:Number;
      
      private var dbMinHeight:Number;
      
      private var dbPreferredWidth:Number;
      
      private var dbPreferredHeight:Number;
      
      private var layoutStyleChanged:Boolean = false;
      
      private var _resizeToContent:Boolean = false;
      
      private var numLayoutChildren:int = 0;
      
      protected var dividerClass:Class;
      
      public var liveDragging:Boolean = false;
      
      private var postLayoutChanges:Array;
      
      public function DividedBox()
      {
         this.dividerClass = BoxDivider;
         super();
         addEventListener(ChildExistenceChangedEvent.CHILD_ADD,this.childAddHandler);
         addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE,this.childRemoveHandler);
         showInAutomationHierarchy = true;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         styleManager.registerSizeInvalidatingStyle("dividerAffordance");
         styleManager.registerSizeInvalidatingStyle("dividerThickness");
      }
      
      override public function set direction(param1:String) : void
      {
         var _loc2_:int = 0;
         if(super.direction != param1)
         {
            super.direction = param1;
            if(this.dividerLayer)
            {
               _loc2_ = 0;
               while(_loc2_ < this.dividerLayer.numChildren)
               {
                  this.getDividerAt(_loc2_).invalidateDisplayList();
                  _loc2_++;
               }
            }
         }
      }
      
      public function get numDividers() : int
      {
         if(this.dividerLayer)
         {
            if(!this.liveDragging && this.activeDivider)
            {
               return this.dividerLayer.numChildren - 1;
            }
            return this.dividerLayer.numChildren;
         }
         return 0;
      }
      
      public function get resizeToContent() : Boolean
      {
         return this._resizeToContent;
      }
      
      public function set resizeToContent(param1:Boolean) : void
      {
         if(param1 != this._resizeToContent)
         {
            this._resizeToContent = param1;
            if(param1)
            {
               invalidateSize();
            }
         }
      }
      
      override protected function measure() : void
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:IUIComponent = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:* = false;
         var _loc16_:* = false;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         super.measure();
         if(!isNaN(this.dbPreferredWidth) && !this._resizeToContent && !this.layoutStyleChanged)
         {
            measuredMinWidth = this.dbMinWidth;
            measuredMinHeight = this.dbMinHeight;
            measuredWidth = this.dbPreferredWidth;
            measuredHeight = this.dbPreferredHeight;
            return;
         }
         this.layoutStyleChanged = false;
         var _loc1_:Boolean = this.isVertical();
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         var _loc6_:int = numChildren;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            if((_loc10_ = getLayoutChildAt(_loc7_)).includeInLayout)
            {
               _loc11_ = _loc10_.getExplicitOrMeasuredWidth();
               _loc12_ = _loc10_.getExplicitOrMeasuredHeight();
               _loc13_ = _loc10_.minWidth;
               _loc14_ = _loc10_.minHeight;
               _loc15_ = !isNaN(_loc10_.percentWidth);
               _loc16_ = !isNaN(_loc10_.percentHeight);
               _loc17_ = Math.min(_loc11_,_loc13_);
               _loc18_ = Math.min(_loc12_,_loc14_);
               if(_loc1_)
               {
                  _loc2_ = Math.max(!!_loc15_ ? Number(_loc13_) : Number(_loc11_),_loc2_);
                  _loc4_ = Math.max(_loc11_,_loc4_);
                  _loc3_ += !!_loc16_ ? _loc18_ : _loc12_;
                  _loc5_ += _loc12_;
               }
               else
               {
                  _loc2_ += !!_loc15_ ? _loc17_ : _loc11_;
                  _loc4_ += _loc11_;
                  _loc3_ = Math.max(!!_loc16_ ? Number(_loc14_) : Number(_loc12_),_loc3_);
                  _loc5_ = Math.max(_loc12_,_loc5_);
               }
            }
            _loc7_++;
         }
         _loc8_ = mx_internal::layoutObject.widthPadding(this.numLayoutChildren);
         _loc9_ = mx_internal::layoutObject.heightPadding(this.numLayoutChildren);
         measuredMinWidth = this.dbMinWidth = _loc2_ + _loc8_;
         measuredMinHeight = this.dbMinHeight = _loc3_ + _loc9_;
         measuredWidth = this.dbPreferredWidth = _loc4_ + _loc8_;
         measuredHeight = this.dbPreferredHeight = _loc5_ + _loc9_;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:IUIComponent = null;
         if(!this.liveDragging && this.activeDivider)
         {
            _loc3_ = numChildren;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if((_loc8_ = getLayoutChildAt(_loc4_)).includeInLayout)
               {
                  _loc8_.measuredMinWidth = 0;
                  _loc8_.measuredMinHeight = 0;
               }
               _loc4_++;
            }
            return;
         }
         this.preLayoutAdjustment();
         super.updateDisplayList(param1,param2);
         this.postLayoutAdjustment();
         if(!this.dividerLayer)
         {
            return;
         }
         var _loc5_:EdgeMetrics = viewMetrics;
         this.dividerLayer.x = _loc5_.left;
         this.dividerLayer.y = _loc5_.top;
         var _loc6_:IUIComponent = null;
         var _loc7_:int = 0;
         _loc3_ = numChildren;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            if((_loc8_ = UIComponent(getChildAt(_loc4_))).includeInLayout)
            {
               if(_loc6_)
               {
                  this.layoutDivider(_loc7_,param1,param2,_loc6_,_loc8_);
                  _loc7_++;
               }
               _loc6_ = _loc8_;
            }
            _loc4_++;
         }
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         super.styleChanged(param1);
         if(this.dividerLayer)
         {
            _loc2_ = this.dividerLayer.numChildren;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               this.getDividerAt(_loc3_).styleChanged(param1);
               _loc3_++;
            }
         }
         if(styleManager.isSizeInvalidatingStyle(param1))
         {
            this.layoutStyleChanged = true;
         }
      }
      
      override protected function scrollChildren() : void
      {
         super.scrollChildren();
         if(mx_internal::contentPane && this.dividerLayer)
         {
            this.dividerLayer.scrollRect = mx_internal::contentPane.scrollRect;
         }
      }
      
      public function getDividerAt(param1:int) : BoxDivider
      {
         return BoxDivider(this.dividerLayer.getChildAt(param1));
      }
      
      public function moveDivider(param1:int, param2:Number) : void
      {
         if(param1 < 0 || param1 >= this.numDividers)
         {
            return;
         }
         if(this.activeDividerIndex >= 0)
         {
            return;
         }
         this.activeDividerIndex = param1;
         this.cacheChildSizes();
         this.computeMinAndMaxDelta();
         this.dragDelta = this.limitDelta(param2);
         this.adjustChildSizes();
         invalidateSize();
         invalidateDisplayList();
         this.resetDividerTracking();
      }
      
      private function createDivider(param1:int) : BoxDivider
      {
         if(!this.dividerLayer)
         {
            this.dividerLayer = UIComponent(rawChildren.addChild(new UIComponent()));
         }
         var _loc2_:BoxDivider = BoxDivider(new this.dividerClass());
         this.dividerLayer.addChild(_loc2_);
         if(param1 == PROXY_DIVIDER_INDEX)
         {
            rawChildren.setChildIndex(this.dividerLayer,rawChildren.numChildren - 1);
         }
         var _loc3_:IFlexDisplayObject = param1 == PROXY_DIVIDER_INDEX ? this.getDividerAt(this.activeDividerIndex) : this;
         _loc2_.styleName = _loc3_;
         _loc2_.owner = this;
         return _loc2_;
      }
      
      private function layoutDivider(param1:int, param2:Number, param3:Number, param4:IUIComponent, param5:IUIComponent) : void
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc6_:BoxDivider = BoxDivider(this.getDividerAt(param1));
         var _loc7_:EdgeMetrics = viewMetrics;
         var _loc8_:Number = getStyle("verticalGap");
         var _loc9_:Number = getStyle("horizontalGap");
         var _loc10_:Number = _loc6_.getStyle("dividerThickness");
         var _loc11_:Number = _loc6_.getStyle("dividerAffordance");
         if(isVertical())
         {
            if((_loc12_ = _loc11_) < _loc10_)
            {
               _loc12_ = _loc10_;
            }
            if(_loc12_ > _loc8_)
            {
               _loc12_ = _loc8_;
            }
            _loc6_.setActualSize(param2 - _loc7_.left - _loc7_.right,_loc12_);
            _loc6_.move(_loc7_.left,Math.round((param4.y + param4.height + param5.y - _loc12_) / 2));
         }
         else
         {
            if((_loc13_ = _loc11_) < _loc10_)
            {
               _loc13_ = _loc10_;
            }
            if(_loc13_ > _loc9_)
            {
               _loc13_ = _loc9_;
            }
            _loc6_.setActualSize(_loc13_,param3 - _loc7_.top - _loc7_.bottom);
            _loc6_.move(Math.round((param4.x + param4.width + param5.x - _loc13_) / 2),_loc7_.top);
         }
         _loc6_.invalidateDisplayList();
      }
      
      mx_internal function changeCursor(param1:BoxDivider) : void
      {
         var _loc2_:Class = null;
         if(this.cursorID == CursorManager.NO_CURSOR)
         {
            _loc2_ = !!isVertical() ? getStyle("verticalDividerCursor") as Class : getStyle("horizontalDividerCursor") as Class;
            this.cursorID = cursorManager.setCursor(_loc2_,CursorManagerPriority.HIGH,0,0);
         }
      }
      
      mx_internal function restoreCursor() : void
      {
         if(this.cursorID != CursorManager.NO_CURSOR)
         {
            cursorManager.removeCursor(this.cursorID);
            this.cursorID = CursorManager.NO_CURSOR;
         }
      }
      
      mx_internal function getDividerIndex(param1:BoxDivider) : int
      {
         var _loc2_:int = numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_ - 1)
         {
            if(this.getDividerAt(_loc3_) == param1)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      private function getMousePosition(param1:MouseEvent) : Number
      {
         var _loc2_:Point = new Point(param1.stageX,param1.stageY);
         _loc2_ = globalToLocal(_loc2_);
         return !!isVertical() ? Number(_loc2_.y) : Number(_loc2_.x);
      }
      
      mx_internal function startDividerDrag(param1:BoxDivider, param2:MouseEvent) : void
      {
         if(this.activeDividerIndex >= 0)
         {
            return;
         }
         this.activeDividerIndex = this.getDividerIndex(param1);
         var _loc3_:DividerEvent = new DividerEvent(DividerEvent.DIVIDER_PRESS);
         _loc3_.dividerIndex = this.activeDividerIndex;
         dispatchEvent(_loc3_);
         if(this.liveDragging)
         {
            this.activeDivider = param1;
         }
         else
         {
            this.activeDivider = this.createDivider(PROXY_DIVIDER_INDEX);
            this.activeDivider.visible = false;
            this.activeDivider.state = DividerState.DOWN;
            this.activeDivider.setActualSize(param1.width,param1.height);
            this.activeDivider.move(param1.x,param1.y);
            this.activeDivider.visible = true;
            param1.state = DividerState.UP;
         }
         if(isVertical())
         {
            this.activeDividerStartPosition = this.activeDivider.y;
         }
         else
         {
            this.activeDividerStartPosition = this.activeDivider.x;
         }
         this.dragStartPosition = this.getMousePosition(param2);
         this.dragDelta = 0;
         this.cacheChildSizes();
         this.adjustChildSizes();
         this.computeMinAndMaxDelta();
         systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler,true);
         systemManager.deployMouseShields(true);
      }
      
      private function cacheSizes() : void
      {
         var _loc5_:IUIComponent = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         this.oldChildSizes = [];
         var _loc1_:Boolean = isVertical();
         var _loc2_:Number = Number.MAX_VALUE;
         var _loc3_:int = numChildren;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if((_loc5_ = getLayoutChildAt(_loc4_)).includeInLayout)
            {
               _loc6_ = !!_loc1_ ? Number(_loc5_.height) : Number(_loc5_.width);
               _loc7_ = !!_loc1_ ? Number(_loc5_.maxHeight) : Number(_loc5_.maxWidth);
               _loc8_ = !!_loc1_ ? Number(_loc5_.explicitMinHeight) : Number(_loc5_.explicitMinWidth);
               _loc9_ = !!isNaN(_loc8_) ? Number(0) : Number(_loc8_);
               _loc10_ = Math.max(0,_loc6_ - _loc9_);
               _loc11_ = Math.max(0,_loc7_ - _loc6_);
               if(_loc6_ > 0 && _loc6_ < _loc2_)
               {
                  _loc2_ = _loc6_;
               }
               this.oldChildSizes.push(new ChildSizeInfo(_loc6_,_loc9_,_loc7_,_loc10_,_loc11_));
            }
            _loc4_++;
         }
         this.oldChildSizes.push(new ChildSizeInfo(_loc2_ == Number.MAX_VALUE ? Number(1) : Number(_loc2_)));
      }
      
      private function cacheChildSizes() : void
      {
         this.oldChildSizes = [];
         this.cacheSizes();
      }
      
      private function mouseMoveHandler(param1:MouseEvent) : void
      {
         this.dragDelta = this.limitDelta(this.getMousePosition(param1) - this.dragStartPosition);
         var _loc2_:DividerEvent = new DividerEvent(DividerEvent.DIVIDER_DRAG);
         _loc2_.dividerIndex = this.activeDividerIndex;
         _loc2_.delta = this.dragDelta;
         dispatchEvent(_loc2_);
         if(this.liveDragging)
         {
            this.adjustChildSizes();
            invalidateDisplayList();
            this.updateDisplayList(unscaledWidth,unscaledHeight);
         }
         else if(isVertical())
         {
            this.activeDivider.move(0,this.activeDividerStartPosition + this.dragDelta);
         }
         else
         {
            this.activeDivider.move(this.activeDividerStartPosition + this.dragDelta,0);
         }
      }
      
      mx_internal function stopDividerDrag(param1:BoxDivider, param2:MouseEvent) : void
      {
         if(param2)
         {
            this.dragDelta = this.limitDelta(this.getMousePosition(param2) - this.dragStartPosition);
         }
         var _loc3_:DividerEvent = new DividerEvent(DividerEvent.DIVIDER_RELEASE);
         _loc3_.dividerIndex = this.activeDividerIndex;
         _loc3_.delta = this.dragDelta;
         dispatchEvent(_loc3_);
         if(!this.liveDragging)
         {
            if(this.dragDelta == 0)
            {
               this.getDividerAt(this.activeDividerIndex).state = DividerState.OVER;
            }
            if(this.activeDivider)
            {
               this.dividerLayer.removeChild(this.activeDivider);
            }
            this.activeDivider = null;
            this.adjustChildSizes();
            invalidateSize();
            invalidateDisplayList();
         }
         this.resetDividerTracking();
         systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler,true);
         systemManager.deployMouseShields(false);
      }
      
      private function resetDividerTracking() : void
      {
         this.activeDivider = null;
         this.activeDividerIndex = -1;
         this.activeDividerStartPosition = NaN;
         this.dragStartPosition = NaN;
         this.dragDelta = NaN;
         this.oldChildSizes = null;
         this.minDelta = NaN;
         this.maxDelta = NaN;
      }
      
      private function computeAllowableMovement(param1:int) : void
      {
         var _loc7_:int = 0;
         var _loc8_:ChildSizeInfo = null;
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         var _loc6_:int = this.numLayoutChildren;
         if(param1 < 0)
         {
            return;
         }
         _loc7_ = param1;
         while(_loc7_ >= 0)
         {
            _loc8_ = ChildSizeInfo(this.oldChildSizes[_loc7_]);
            _loc2_ += this.dontCoalesceDividers && _loc2_ ? 0 : _loc8_.deltaMin;
            _loc3_ += this.dontCoalesceDividers && _loc3_ ? 0 : _loc8_.deltaMax;
            _loc7_--;
         }
         _loc7_ = param1 + 1;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = ChildSizeInfo(this.oldChildSizes[_loc7_]);
            _loc4_ += this.dontCoalesceDividers && _loc4_ ? 0 : _loc8_.deltaMin;
            _loc5_ += this.dontCoalesceDividers && _loc5_ ? 0 : _loc8_.deltaMax;
            _loc7_++;
         }
         var _loc9_:Number = Math.min(_loc2_,_loc5_);
         var _loc10_:Number = Math.min(_loc4_,_loc3_);
         this.minDelta = -_loc9_;
         this.maxDelta = _loc10_;
      }
      
      private function computeMinAndMaxDelta() : void
      {
         this.computeAllowableMovement(this.activeDividerIndex);
      }
      
      private function limitDelta(param1:Number) : Number
      {
         if(param1 < this.minDelta)
         {
            param1 = this.minDelta;
         }
         else if(param1 > this.maxDelta)
         {
            param1 = this.maxDelta;
         }
         return Number(Math.round(param1));
      }
      
      private function distributeDelta() : void
      {
         var _loc5_:int = 0;
         var _loc6_:ChildSizeInfo = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:IUIComponent = null;
         var _loc10_:Number = NaN;
         if(!this.dragDelta)
         {
            return;
         }
         var _loc1_:Boolean = isVertical();
         var _loc2_:int = this.numLayoutChildren;
         var _loc3_:int = this.activeDividerIndex;
         var _loc4_:Number;
         if((_loc4_ = this.oldChildSizes[_loc2_].size - Math.abs(this.dragDelta)) <= 0 || isNaN(_loc4_))
         {
            _loc4_ = 1;
         }
         var _loc11_:int = -1;
         var _loc12_:int = -1;
         while(_loc12_ < this.activeDividerIndex)
         {
            if(UIComponent(getChildAt(++_loc11_)).includeInLayout)
            {
               _loc12_++;
            }
         }
         var _loc13_:int = _loc11_;
         var _loc14_:Number = this.dragDelta;
         _loc5_ = _loc3_;
         while(_loc5_ >= 0)
         {
            _loc6_ = ChildSizeInfo(this.oldChildSizes[_loc5_]);
            _loc7_ = _loc14_ < 0 ? Number(-Math.min(-_loc14_,_loc6_.deltaMin)) : Number(Math.min(_loc14_,_loc6_.deltaMax));
            _loc8_ = _loc6_.size + _loc7_;
            _loc14_ -= _loc7_;
            while(!(_loc9_ = IUIComponent(getChildAt(_loc13_--))).includeInLayout)
            {
            }
            _loc10_ = _loc8_ / _loc4_ * 100;
            if(_loc1_)
            {
               _loc9_.percentHeight = _loc10_;
            }
            else
            {
               _loc9_.percentWidth = _loc10_;
            }
            if(_loc9_ is IInvalidating)
            {
               IInvalidating(_loc9_).invalidateSize();
            }
            _loc5_--;
         }
         _loc13_ = _loc11_ + 1;
         _loc14_ = this.dragDelta;
         _loc5_ = _loc3_ + 1;
         while(_loc5_ < _loc2_)
         {
            _loc6_ = ChildSizeInfo(this.oldChildSizes[_loc5_]);
            _loc7_ = _loc14_ < 0 ? Number(Math.min(-_loc14_,_loc6_.deltaMax)) : Number(-Math.min(_loc14_,_loc6_.deltaMin));
            _loc8_ = _loc6_.size + _loc7_;
            _loc14_ += _loc7_;
            while(!(_loc9_ = IUIComponent(getChildAt(_loc13_++))).includeInLayout)
            {
            }
            _loc10_ = _loc8_ / _loc4_ * 100;
            if(_loc1_)
            {
               _loc9_.percentHeight = _loc10_;
            }
            else
            {
               _loc9_.percentWidth = _loc10_;
            }
            if(_loc9_ is IInvalidating)
            {
               IInvalidating(_loc9_).invalidateSize();
            }
            _loc5_++;
         }
      }
      
      private function adjustChildSizes() : void
      {
         this.distributeDelta();
      }
      
      private function preLayoutAdjustment() : void
      {
         var _loc5_:int = 0;
         var _loc6_:IUIComponent = null;
         var _loc7_:Number = NaN;
         var _loc8_:Object = null;
         var _loc9_:Number = NaN;
         var _loc1_:Boolean = isVertical();
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:int = numChildren;
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if((_loc6_ = getLayoutChildAt(_loc5_)).includeInLayout)
            {
               _loc6_.measuredMinWidth = 0;
               _loc6_.measuredMinHeight = 0;
               _loc7_ = !!_loc1_ ? Number(_loc6_.percentHeight) : Number(_loc6_.percentWidth);
               if(!isNaN(_loc7_))
               {
                  _loc2_ += _loc7_;
                  _loc3_++;
               }
            }
            _loc5_++;
         }
         this.postLayoutChanges = [];
         if(_loc2_ == 0 && _loc3_ == 0)
         {
            _loc5_ = _loc4_ - 1;
            while(_loc5_ >= 0)
            {
               if((_loc6_ = UIComponent(getChildAt(_loc5_))).includeInLayout)
               {
                  _loc8_ = {"child":_loc6_};
                  if(_loc1_)
                  {
                     if(_loc6_.explicitHeight)
                     {
                        _loc8_.explicitHeight = _loc6_.explicitHeight;
                     }
                     else
                     {
                        _loc8_.percentHeight = NaN;
                     }
                     _loc6_.percentHeight = 100;
                  }
                  else
                  {
                     if(_loc6_.explicitWidth)
                     {
                        _loc8_.explicitWidth = _loc6_.explicitWidth;
                     }
                     else if(_loc6_.percentWidth)
                     {
                        _loc8_.percentWidth = NaN;
                     }
                     _loc6_.percentWidth = 100;
                  }
                  this.postLayoutChanges.push(_loc8_);
                  break;
               }
               _loc5_--;
            }
         }
         else if(_loc2_ < 100)
         {
            _loc9_ = Math.ceil((100 - _loc2_) / _loc3_);
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               if((_loc6_ = getLayoutChildAt(_loc5_)).includeInLayout)
               {
                  _loc8_ = {"child":_loc6_};
                  if(_loc1_)
                  {
                     _loc7_ = _loc6_.percentHeight;
                     if(!isNaN(_loc7_))
                     {
                        _loc8_.percentHeight = _loc6_.percentHeight;
                        this.postLayoutChanges.push(_loc8_);
                        _loc6_.percentHeight = (_loc7_ + _loc9_) * unscaledHeight;
                     }
                  }
                  else
                  {
                     _loc7_ = _loc6_.percentWidth;
                     if(!isNaN(_loc7_))
                     {
                        _loc8_.percentWidth = _loc6_.percentWidth;
                        this.postLayoutChanges.push(_loc8_);
                        _loc6_.percentWidth = (_loc7_ + _loc9_) * unscaledWidth;
                     }
                  }
               }
               _loc5_++;
            }
         }
      }
      
      private function postLayoutAdjustment() : void
      {
         var _loc3_:Object = null;
         var _loc1_:int = this.postLayoutChanges.length;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this.postLayoutChanges[_loc2_];
            if(_loc3_.percentWidth !== undefined)
            {
               _loc3_.child.percentWidth = _loc3_.percentWidth;
            }
            if(_loc3_.percentHeight !== undefined)
            {
               _loc3_.child.percentHeight = _loc3_.percentHeight;
            }
            if(_loc3_.explicitWidth !== undefined)
            {
               _loc3_.child.explicitWidth = _loc3_.explicitWidth;
            }
            if(_loc3_.explicitHeight !== undefined)
            {
               _loc3_.child.explicitHeight = _loc3_.explicitHeight;
            }
            _loc2_++;
         }
         this.postLayoutChanges = null;
      }
      
      private function childAddHandler(param1:ChildExistenceChangedEvent) : void
      {
         var _loc2_:DisplayObject = param1.relatedObject;
         _loc2_.addEventListener("includeInLayoutChanged",this.child_includeInLayoutChangedHandler);
         if(!IUIComponent(_loc2_).includeInLayout)
         {
            return;
         }
         ++this.numLayoutChildren;
         if(this.numLayoutChildren > 1)
         {
            this.createDivider(this.numLayoutChildren - 2);
         }
         this.dbMinWidth = NaN;
         this.dbMinHeight = NaN;
         this.dbPreferredWidth = NaN;
         this.dbPreferredHeight = NaN;
      }
      
      private function childRemoveHandler(param1:ChildExistenceChangedEvent) : void
      {
         var _loc2_:DisplayObject = param1.relatedObject;
         _loc2_.removeEventListener("includeInLayoutChanged",this.child_includeInLayoutChangedHandler);
         if(!IUIComponent(_loc2_).includeInLayout)
         {
            return;
         }
         --this.numLayoutChildren;
         if(this.numLayoutChildren > 0)
         {
            this.dividerLayer.removeChild(this.getDividerAt(this.numLayoutChildren - 1));
         }
         this.dbMinWidth = NaN;
         this.dbMinHeight = NaN;
         this.dbPreferredWidth = NaN;
         this.dbPreferredHeight = NaN;
         invalidateSize();
      }
      
      private function child_includeInLayoutChangedHandler(param1:Event) : void
      {
         var _loc2_:UIComponent = UIComponent(param1.target);
         if(_loc2_.includeInLayout && ++this.numLayoutChildren > 1)
         {
            this.createDivider(this.numLayoutChildren - 2);
         }
         else if(!_loc2_.includeInLayout && --this.numLayoutChildren > 0)
         {
            this.dividerLayer.removeChild(this.getDividerAt(this.numLayoutChildren - 1));
         }
         this.dbMinWidth = NaN;
         this.dbMinHeight = NaN;
         this.dbPreferredWidth = NaN;
         this.dbPreferredHeight = NaN;
         invalidateSize();
      }
   }
}

class ChildSizeInfo
{
    
   
   public var deltaMin:Number;
   
   public var deltaMax:Number;
   
   public var min:Number;
   
   public var max:Number;
   
   public var size:Number;
   
   function ChildSizeInfo(param1:Number, param2:Number = 0, param3:Number = 0, param4:Number = 0, param5:Number = 0)
   {
      super();
      this.size = param1;
      this.min = param2;
      this.max = param3;
      this.deltaMin = param4;
      this.deltaMax = param5;
   }
}
