package mx.containers
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.ui.Keyboard;
   import mx.automation.IAutomationObject;
   import mx.containers.accordionClasses.AccordionHeader;
   import mx.controls.Button;
   import mx.core.ClassFactory;
   import mx.core.ComponentDescriptor;
   import mx.core.Container;
   import mx.core.ContainerCreationPolicy;
   import mx.core.EdgeMetrics;
   import mx.core.IDataRenderer;
   import mx.core.IDeferredContentOwner;
   import mx.core.IFactory;
   import mx.core.IInvalidating;
   import mx.core.INavigatorContent;
   import mx.core.IUIComponent;
   import mx.core.ScrollPolicy;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.effects.Effect;
   import mx.effects.Tween;
   import mx.events.ChildExistenceChangedEvent;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.geom.RoundedRectangle;
   import mx.managers.HistoryManager;
   import mx.managers.IFocusManagerComponent;
   import mx.managers.IHistoryManagerClient;
   
   use namespace mx_internal;
   
   public class Accordion extends Container implements IHistoryManagerClient, IFocusManagerComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const HEADER_NAME_BASE:String = "_header";
       
      
      private var bSliding:Boolean = false;
      
      private var initialSelectedIndex:int = -1;
      
      private var bSaveState:Boolean = false;
      
      private var bInLoadState:Boolean = false;
      
      private var firstTime:Boolean = true;
      
      private var showFocusIndicator:Boolean = false;
      
      private var tweenViewMetrics:EdgeMetrics;
      
      private var tweenContentWidth:Number;
      
      private var tweenContentHeight:Number;
      
      private var tweenOldSelectedIndex:int;
      
      private var tweenNewSelectedIndex:int;
      
      private var tween:Tween;
      
      private var accMinWidth:Number;
      
      private var accMinHeight:Number;
      
      private var accPreferredWidth:Number;
      
      private var accPreferredHeight:Number;
      
      private var childAddedOrRemoved:Boolean = false;
      
      private var overlayChild:IUIComponent;
      
      private var overlayTargetArea:RoundedRectangle;
      
      private var layoutStyleChanged:Boolean = false;
      
      private var currentDissolveEffect:Effect;
      
      private var _focusedIndex:int = -1;
      
      private var _headerRenderer:IFactory;
      
      private var _historyManagementEnabled:Boolean = true;
      
      private var historyManagementEnabledChanged:Boolean = false;
      
      private var _resizeToContent:Boolean = false;
      
      private var _selectedIndex:int = -1;
      
      private var proposedSelectedIndex:int = -1;
      
      public function Accordion()
      {
         super();
         this.headerRenderer = new ClassFactory(AccordionHeader);
         tabEnabled = true;
         tabFocusEnabled = true;
         hasFocusableChildren = true;
         super.clipContent = false;
         addEventListener(ChildExistenceChangedEvent.CHILD_ADD,this.childAddHandler);
         addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE,this.childRemoveHandler);
         showInAutomationHierarchy = true;
      }
      
      override public function get autoLayout() : Boolean
      {
         return true;
      }
      
      override public function set autoLayout(param1:Boolean) : void
      {
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
         var _loc2_:Button = this.getHeaderAt(0);
         var _loc3_:Number = _loc2_.y + _loc2_.baselinePosition;
         if(_loc1_)
         {
            removeChildAt(0);
            validateNow();
         }
         return _loc3_;
      }
      
      override public function get clipContent() : Boolean
      {
         return true;
      }
      
      override public function set clipContent(param1:Boolean) : void
      {
      }
      
      override public function get horizontalScrollPolicy() : String
      {
         return ScrollPolicy.OFF;
      }
      
      override public function set horizontalScrollPolicy(param1:String) : void
      {
      }
      
      override public function get verticalScrollPolicy() : String
      {
         return ScrollPolicy.OFF;
      }
      
      override public function set verticalScrollPolicy(param1:String) : void
      {
      }
      
      mx_internal function get focusedIndex() : int
      {
         return this._focusedIndex;
      }
      
      protected function get contentHeight() : Number
      {
         var _loc1_:Number = unscaledHeight;
         var _loc2_:EdgeMetrics = viewMetricsAndPadding;
         _loc1_ -= _loc2_.top + _loc2_.bottom;
         var _loc3_:Number = getStyle("verticalGap");
         var _loc4_:int = numChildren;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc1_ -= this.getHeaderAt(_loc5_).height;
            if(_loc5_ > 0)
            {
               _loc1_ -= _loc3_;
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      protected function get contentWidth() : Number
      {
         var _loc1_:Number = unscaledWidth;
         var _loc2_:EdgeMetrics = viewMetricsAndPadding;
         _loc1_ -= _loc2_.left + _loc2_.right;
         return Number(_loc1_ - (getStyle("paddingLeft") + getStyle("paddingRight")));
      }
      
      [Bindable("headerRendererChanged")]
      public function get headerRenderer() : IFactory
      {
         return this._headerRenderer;
      }
      
      public function set headerRenderer(param1:IFactory) : void
      {
         this._headerRenderer = param1;
         dispatchEvent(new Event("headerRendererChanged"));
      }
      
      public function get historyManagementEnabled() : Boolean
      {
         return this._historyManagementEnabled;
      }
      
      public function set historyManagementEnabled(param1:Boolean) : void
      {
         if(param1 != this._historyManagementEnabled)
         {
            this._historyManagementEnabled = param1;
            this.historyManagementEnabledChanged = true;
            invalidateProperties();
         }
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
      
      [Bindable("valueCommit")]
      public function get selectedChild() : INavigatorContent
      {
         if(this.selectedIndex == -1)
         {
            return null;
         }
         return INavigatorContent(getChildAt(this.selectedIndex));
      }
      
      public function set selectedChild(param1:INavigatorContent) : void
      {
         var _loc2_:int = getChildIndex(DisplayObject(param1));
         if(_loc2_ >= 0 && _loc2_ < numChildren)
         {
            this.selectedIndex = _loc2_;
         }
      }
      
      [Bindable("valueCommit")]
      public function get selectedIndex() : int
      {
         if(this.proposedSelectedIndex != -1)
         {
            return this.proposedSelectedIndex;
         }
         return this._selectedIndex;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(param1 == -1)
         {
            return;
         }
         if(param1 == this._selectedIndex)
         {
            return;
         }
         this.proposedSelectedIndex = param1;
         invalidateProperties();
         if(this.historyManagementEnabled && this._selectedIndex != -1 && !this.bInLoadState)
         {
            this.bSaveState = true;
         }
         dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
      
      override public function createComponentsFromDescriptors(param1:Boolean = true) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:ComponentDescriptor = null;
         if(actualCreationPolicy == ContainerCreationPolicy.ALL)
         {
            super.createComponentsFromDescriptors();
            return;
         }
         var _loc2_:int = numChildren;
         if(childDescriptors)
         {
            _loc3_ = childDescriptors.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = ComponentDescriptor(childDescriptors[_loc4_]);
               createComponentFromDescriptor(_loc5_,false);
               _loc4_++;
            }
         }
         numChildrenCreated = numChildren - _loc2_;
         processedDescriptors = true;
      }
      
      override public function setChildIndex(param1:DisplayObject, param2:int) : void
      {
         var _loc3_:int = getChildIndex(param1);
         if(_loc3_ == -1 || param2 < 0)
         {
            return;
         }
         var _loc4_:int = numChildren;
         if(param2 >= _loc4_)
         {
            param2 = _loc4_ - 1;
         }
         if(param2 == _loc3_)
         {
            return;
         }
         var _loc5_:Button;
         if(_loc5_ = this.getHeaderAt(this.selectedIndex))
         {
            _loc5_.selected = false;
            this.drawHeaderFocus(this._focusedIndex,false);
         }
         super.setChildIndex(param1,param2);
         this.shuffleHeaders(_loc3_,param2);
         var _loc6_:Button;
         if(_loc6_ = this.getHeaderAt(this.selectedIndex))
         {
            _loc6_.selected = true;
            this.drawHeaderFocus(this._focusedIndex,this.showFocusIndicator);
         }
         this.instantiateChild(this.selectedChild);
      }
      
      private function shuffleHeaders(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Button = this.getHeaderAt(param1);
         if(param2 < param1)
         {
            _loc3_ = param1;
            while(_loc3_ > param2)
            {
               this.getHeaderAt(_loc3_ - 1).name = HEADER_NAME_BASE + _loc3_;
               _loc3_--;
            }
         }
         else
         {
            _loc3_ = param1;
            while(_loc3_ < param2)
            {
               this.getHeaderAt(_loc3_ + 1).name = HEADER_NAME_BASE + _loc3_;
               _loc3_++;
            }
         }
         _loc4_.name = HEADER_NAME_BASE + param2;
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(this.historyManagementEnabledChanged)
         {
            if(this.historyManagementEnabled)
            {
               HistoryManager.register(this);
            }
            else
            {
               HistoryManager.unregister(this);
            }
            this.historyManagementEnabledChanged = false;
         }
         this.commitSelectedIndex();
         if(this.firstTime)
         {
            this.firstTime = false;
            addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler,false,0,true);
            addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler,false,0,true);
         }
      }
      
      override protected function measure() : void
      {
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc13_:Button = null;
         var _loc14_:IUIComponent = null;
         super.measure();
         var _loc1_:Number = 0;
         _loc2_ = 0;
         var _loc3_:Number = 0;
         _loc4_ = 0;
         var _loc5_:Number = getStyle("paddingLeft");
         var _loc6_:Number = getStyle("paddingRight");
         var _loc7_:Number = this.getHeaderHeight();
         if(this.accPreferredWidth && !this._resizeToContent && !this.layoutStyleChanged && !this.childAddedOrRemoved)
         {
            measuredMinWidth = this.accMinWidth;
            measuredMinHeight = this.accMinHeight;
            measuredWidth = this.accPreferredWidth;
            measuredHeight = this.accPreferredHeight;
            return;
         }
         this.layoutStyleChanged = false;
         this.childAddedOrRemoved = false;
         var _loc8_:int = numChildren;
         var _loc9_:int = 0;
         while(_loc9_ < _loc8_)
         {
            _loc13_ = this.getHeaderAt(_loc9_);
            _loc14_ = getLayoutChildAt(_loc9_);
            _loc1_ = Math.max(_loc1_,_loc13_.minWidth);
            _loc2_ += _loc7_;
            _loc3_ = Math.max(_loc3_,_loc1_);
            _loc4_ += _loc7_;
            if(_loc9_ == this.selectedIndex)
            {
               _loc3_ = Math.max(_loc3_,_loc14_.getExplicitOrMeasuredWidth());
               _loc4_ += _loc14_.getExplicitOrMeasuredHeight();
               _loc1_ = Math.max(_loc1_,_loc14_.minWidth);
               _loc2_ += _loc14_.minHeight;
            }
            _loc9_++;
         }
         var _loc10_:EdgeMetrics;
         var _loc11_:Number = (_loc10_ = viewMetricsAndPadding).left + _loc10_.right;
         var _loc12_:Number = _loc10_.top + _loc10_.bottom;
         if(_loc5_ < 0)
         {
            _loc11_ -= _loc5_;
         }
         if(_loc6_ < 0)
         {
            _loc11_ -= _loc6_;
         }
         _loc1_ += _loc11_;
         _loc3_ += _loc11_;
         _loc2_ += _loc12_;
         _loc4_ += _loc12_;
         measuredMinWidth = _loc1_;
         measuredMinHeight = _loc2_;
         measuredWidth = _loc3_;
         measuredHeight = _loc4_;
         if(this.selectedChild && INavigatorContent(this.selectedChild).deferredContentCreated == false)
         {
            return;
         }
         if(numChildren == 0)
         {
            return;
         }
         this.accMinWidth = _loc1_;
         this.accMinHeight = _loc2_;
         this.accPreferredWidth = _loc3_;
         this.accPreferredHeight = _loc4_;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc17_:Button = null;
         var _loc18_:IUIComponent = null;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         super.updateDisplayList(param1,param2);
         if(this.tween)
         {
            return;
         }
         var _loc3_:EdgeMetrics = borderMetrics;
         var _loc4_:Number = getStyle("paddingLeft");
         var _loc5_:Number = getStyle("paddingRight");
         var _loc6_:Number = getStyle("paddingTop");
         var _loc7_:Number = getStyle("verticalGap");
         var _loc8_:Number = this.calcContentWidth();
         var _loc9_:Number = this.calcContentHeight();
         var _loc10_:Number = _loc3_.left + _loc4_;
         var _loc11_:Number = _loc3_.top + _loc6_;
         var _loc12_:Number = _loc10_;
         var _loc13_:Number = _loc8_;
         var _loc14_:Number = this.getHeaderHeight();
         if(_loc4_ < 0)
         {
            _loc12_ -= _loc4_;
            _loc13_ += _loc4_;
         }
         if(_loc5_ < 0)
         {
            _loc13_ += _loc5_;
         }
         var _loc15_:int = numChildren;
         var _loc16_:int = 0;
         while(_loc16_ < _loc15_)
         {
            _loc17_ = this.getHeaderAt(_loc16_);
            _loc18_ = getLayoutChildAt(_loc16_);
            _loc17_.move(_loc10_,_loc11_);
            _loc17_.setActualSize(_loc8_,_loc14_);
            _loc11_ += _loc14_;
            if(_loc16_ == this.selectedIndex)
            {
               _loc18_.move(_loc12_,_loc11_);
               _loc18_.visible = true;
               _loc19_ = _loc13_;
               _loc20_ = _loc9_;
               if(!isNaN(_loc18_.percentWidth))
               {
                  if(_loc19_ > _loc18_.maxWidth)
                  {
                     _loc19_ = _loc18_.maxWidth;
                  }
               }
               else if(_loc19_ > _loc18_.getExplicitOrMeasuredWidth())
               {
                  _loc19_ = _loc18_.getExplicitOrMeasuredWidth();
               }
               if(!isNaN(_loc18_.percentHeight))
               {
                  if(_loc20_ > _loc18_.maxHeight)
                  {
                     _loc20_ = _loc18_.maxHeight;
                  }
               }
               else if(_loc20_ > _loc18_.getExplicitOrMeasuredHeight())
               {
                  _loc20_ = _loc18_.getExplicitOrMeasuredHeight();
               }
               if(_loc18_.width != _loc19_ || _loc18_.height != _loc20_)
               {
                  _loc18_.setActualSize(_loc19_,_loc20_);
               }
               _loc11_ += _loc9_;
            }
            else
            {
               _loc18_.move(_loc12_,_loc16_ < this.selectedIndex ? Number(_loc11_) : Number(_loc11_ - _loc9_));
               _loc18_.visible = false;
            }
            _loc11_ += _loc7_;
            _loc16_++;
         }
         if(mx_internal::blocker)
         {
            rawChildren.setChildIndex(mx_internal::blocker,numChildren - 1);
         }
         this.drawHeaderFocus(this._focusedIndex,this.showFocusIndicator);
      }
      
      override mx_internal function setActualCreationPolicies(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         super.setActualCreationPolicies(param1);
         if(param1 == ContainerCreationPolicy.ALL && numChildren > 0)
         {
            _loc2_ = numChildren;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               IDeferredContentOwner(getChildAt(_loc3_)).createDeferredContent();
               _loc3_++;
            }
         }
      }
      
      override protected function focusInHandler(param1:FocusEvent) : void
      {
         super.focusInHandler(param1);
         this.showFocusIndicator = focusManager.showFocusIndicator;
         if(param1.target == this)
         {
            focusManager.defaultButtonEnabled = false;
         }
      }
      
      override protected function focusOutHandler(param1:FocusEvent) : void
      {
         super.focusOutHandler(param1);
         this.showFocusIndicator = false;
         if(focusManager && param1.target == this)
         {
            focusManager.defaultButtonEnabled = true;
         }
      }
      
      override public function drawFocus(param1:Boolean) : void
      {
         this.drawHeaderFocus(this._focusedIndex,param1);
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Button = null;
         var _loc4_:int = 0;
         super.styleChanged(param1);
         if(!param1 || param1 == "headerStyleName" || param1 == "styleName")
         {
            _loc2_ = getStyle("headerStyleName");
            if(_loc2_)
            {
               _loc4_ = 0;
               while(_loc4_ < numChildren)
               {
                  _loc3_ = this.getHeaderAt(_loc4_);
                  if(_loc3_)
                  {
                     _loc3_.styleName = _loc2_;
                  }
                  _loc4_++;
               }
            }
         }
         else if(styleManager.isSizeInvalidatingStyle(param1))
         {
            this.layoutStyleChanged = true;
         }
      }
      
      override mx_internal function addOverlay(param1:uint, param2:RoundedRectangle = null) : void
      {
         if(this.overlayChild)
         {
            this.removeOverlay();
         }
         this.overlayChild = this.selectedChild as IUIComponent;
         if(!this.overlayChild)
         {
            return;
         }
         effectOverlayColor = param1;
         this.overlayTargetArea = param2;
         if(this.selectedChild && this.selectedChild.deferredContentCreated == false)
         {
            this.selectedChild.addEventListener(FlexEvent.INITIALIZE,this.initializeHandler);
         }
         else
         {
            this.initializeHandler(null);
         }
      }
      
      private function initializeHandler(param1:FlexEvent) : void
      {
         UIComponent(this.overlayChild).addOverlay(mx_internal::effectOverlayColor,this.overlayTargetArea);
      }
      
      override mx_internal function removeOverlay() : void
      {
         if(this.overlayChild)
         {
            UIComponent(this.overlayChild).removeOverlay();
            this.overlayChild = null;
         }
      }
      
      public function saveState() : Object
      {
         var _loc1_:int = this._selectedIndex == -1 ? 0 : int(this._selectedIndex);
         return {"selectedIndex":_loc1_};
      }
      
      public function loadState(param1:Object) : void
      {
         var _loc2_:int = !!param1 ? int(int(param1.selectedIndex)) : 0;
         if(_loc2_ == -1)
         {
            _loc2_ = this.initialSelectedIndex;
         }
         if(_loc2_ == -1)
         {
            _loc2_ = 0;
         }
         if(_loc2_ != this._selectedIndex)
         {
            this.bInLoadState = true;
            this.selectedIndex = _loc2_;
            this.bInLoadState = false;
         }
      }
      
      public function getHeaderAt(param1:int) : Button
      {
         return Button(rawChildren.getChildByName(HEADER_NAME_BASE + param1));
      }
      
      private function getHeaderHeight() : Number
      {
         var _loc1_:Number = getStyle("headerHeight");
         if(isNaN(_loc1_))
         {
            _loc1_ = 0;
            if(numChildren > 0)
            {
               _loc1_ = this.getHeaderAt(0).measuredHeight;
            }
         }
         return _loc1_;
      }
      
      private function createHeader(param1:DisplayObject, param2:int) : void
      {
         var _loc5_:INavigatorContent = null;
         var _loc6_:String = null;
         if(this.selectedIndex != -1 && this.getHeaderAt(this.selectedIndex))
         {
            this.getHeaderAt(this.selectedIndex).selected = false;
         }
         var _loc3_:Button = Button(this.headerRenderer.newInstance());
         _loc3_.name = HEADER_NAME_BASE + (numChildren - 1);
         var _loc4_:String;
         if(_loc4_ = getStyle("headerStyleName"))
         {
            _loc3_.styleName = _loc4_;
         }
         _loc3_.addEventListener(MouseEvent.CLICK,this.headerClickHandler);
         IDataRenderer(_loc3_).data = param1;
         if(param1 is INavigatorContent)
         {
            _loc5_ = INavigatorContent(param1);
            _loc3_.label = _loc5_.label;
            if(_loc5_.icon)
            {
               _loc3_.setStyle("icon",_loc5_.icon);
            }
            if((_loc6_ = (_loc5_ as UIComponent).toolTip) && _loc6_ != "")
            {
               _loc3_.toolTip = _loc6_;
               (_loc5_ as UIComponent).toolTip = null;
            }
         }
         rawChildren.addChild(_loc3_);
         if(param2 != numChildren - 1)
         {
            this.shuffleHeaders(numChildren - 1,param2);
         }
         if(this.selectedIndex != -1 && this.getHeaderAt(this.selectedIndex))
         {
            this.getHeaderAt(this.selectedIndex).selected = true;
         }
      }
      
      private function calcContentWidth() : Number
      {
         var _loc1_:Number = unscaledWidth;
         var _loc2_:EdgeMetrics = viewMetricsAndPadding;
         return Number(_loc1_ - (_loc2_.left + _loc2_.right));
      }
      
      private function calcContentHeight() : Number
      {
         var _loc1_:Number = unscaledHeight;
         var _loc2_:EdgeMetrics = viewMetricsAndPadding;
         _loc1_ -= _loc2_.top + _loc2_.bottom;
         var _loc3_:Number = getStyle("verticalGap");
         var _loc4_:Number = this.getHeaderHeight();
         var _loc5_:int = numChildren;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc1_ -= _loc4_;
            if(_loc6_ > 0)
            {
               _loc1_ -= _loc3_;
            }
            _loc6_++;
         }
         return _loc1_;
      }
      
      private function drawHeaderFocus(param1:int, param2:Boolean) : void
      {
         if(param1 != -1)
         {
            this.getHeaderAt(param1).drawFocus(param2);
         }
      }
      
      private function headerClickHandler(param1:Event) : void
      {
         var _loc2_:Button = Button(param1.currentTarget);
         var _loc3_:int = this.selectedIndex;
         this.selectedChild = INavigatorContent(IDataRenderer(_loc2_).data);
         var _loc4_:int = this.selectedIndex;
         if(_loc3_ != _loc4_)
         {
            this.dispatchChangeEvent(_loc3_,_loc4_,param1);
         }
      }
      
      private function commitSelectedIndex() : void
      {
         var _loc3_:Class = null;
         var _loc4_:int = 0;
         if(this.proposedSelectedIndex == -1)
         {
            return;
         }
         var _loc1_:int = this.proposedSelectedIndex;
         this.proposedSelectedIndex = -1;
         if(numChildren == 0)
         {
            this._selectedIndex = -1;
            return;
         }
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         else if(_loc1_ > numChildren - 1)
         {
            _loc1_ = numChildren - 1;
         }
         var _loc2_:int = this._selectedIndex;
         if(_loc1_ == _loc2_)
         {
            return;
         }
         this.currentDissolveEffect = null;
         if(mx_internal::isEffectStarted)
         {
            _loc3_ = Class(systemManager.getDefinitionByName("mx.effects.effectClasses.DissolveInstance"));
            _loc4_ = 0;
            while(_loc4_ < mx_internal::_effectsStarted.length)
            {
               if(_loc3_ && mx_internal::_effectsStarted[_loc4_] is _loc3_)
               {
                  this.currentDissolveEffect = mx_internal::_effectsStarted[_loc4_].effect;
                  mx_internal::_effectsStarted[_loc4_].end();
                  break;
               }
               _loc4_++;
            }
         }
         if(this._focusedIndex != _loc1_)
         {
            this.drawHeaderFocus(this._focusedIndex,false);
         }
         if(_loc2_ != -1)
         {
            this.getHeaderAt(_loc2_).selected = false;
         }
         this._selectedIndex = _loc1_;
         if(this.initialSelectedIndex == -1)
         {
            this.initialSelectedIndex = this._selectedIndex;
         }
         this.getHeaderAt(_loc1_).selected = true;
         if(this._focusedIndex != _loc1_)
         {
            this._focusedIndex = _loc1_;
            this.drawHeaderFocus(this._focusedIndex,this.showFocusIndicator);
         }
         if(this.bSaveState)
         {
            HistoryManager.save();
            this.bSaveState = false;
         }
         if(getStyle("openDuration") == 0 || _loc2_ == -1)
         {
            IUIComponent(getChildAt(_loc1_)).setVisible(true);
            IUIComponent(getChildAt(_loc1_)).setVisible(false,true);
            if(_loc2_ != -1)
            {
               IUIComponent(getChildAt(_loc2_)).setVisible(false);
            }
            this.instantiateChild(this.selectedChild);
         }
         else
         {
            if(this.tween)
            {
               this.tween.endTween();
            }
            this.startTween(_loc2_,_loc1_);
         }
      }
      
      private function instantiateChild(param1:INavigatorContent) : void
      {
         if(!param1)
         {
            return;
         }
         if(param1 && param1.deferredContentCreated == false)
         {
            param1.createDeferredContent();
         }
         invalidateSize();
         invalidateDisplayList();
         if(param1 is IInvalidating)
         {
            IInvalidating(param1).invalidateSize();
         }
      }
      
      private function dispatchChangeEvent(param1:int, param2:int, param3:Event = null) : void
      {
         var _loc4_:IndexChangedEvent;
         (_loc4_ = new IndexChangedEvent(IndexChangedEvent.CHANGE)).oldIndex = param1;
         _loc4_.newIndex = param2;
         _loc4_.relatedObject = getChildAt(param2);
         _loc4_.triggerEvent = param3;
         dispatchEvent(_loc4_);
      }
      
      private function startTween(param1:int, param2:int) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         this.bSliding = true;
         this.tweenViewMetrics = viewMetricsAndPadding;
         this.tweenContentWidth = this.calcContentWidth();
         this.tweenContentHeight = this.calcContentHeight();
         this.tweenOldSelectedIndex = param1;
         this.tweenNewSelectedIndex = param2;
         var _loc3_:Number = getStyle("openDuration");
         this.tween = new Tween(this,0,this.tweenContentHeight,_loc3_);
         var _loc4_:Function;
         if((_loc4_ = getStyle("openEasingFunction") as Function) != null)
         {
            this.tween.easingFunction = _loc4_;
         }
         if(param1 != -1)
         {
            IUIComponent(getChildAt(param1)).tweeningProperties = ["x","y","width","height"];
         }
         IUIComponent(getChildAt(param2)).tweeningProperties = ["x","y","width","height"];
         var _loc5_:IDeferredContentOwner;
         if((_loc5_ = IDeferredContentOwner(getChildAt(param2))).deferredContentCreated == false)
         {
            _loc6_ = getStyle("paddingLeft");
            _loc7_ = borderMetrics.left + (_loc6_ > 0 ? _loc6_ : 0);
            _loc5_.move(_loc7_,_loc5_.y);
            _loc5_.setActualSize(this.tweenContentWidth,this.tweenContentHeight);
         }
         UIComponent.suspendBackgroundProcessing();
      }
      
      mx_internal function onTweenUpdate(param1:Number) : void
      {
         var _loc15_:Button = null;
         var _loc16_:UIComponent = null;
         var _loc2_:EdgeMetrics = this.tweenViewMetrics;
         var _loc3_:Number = this.tweenContentWidth;
         var _loc4_:Number = this.tweenContentHeight;
         var _loc5_:int = this.tweenOldSelectedIndex;
         var _loc6_:int = this.tweenNewSelectedIndex;
         var _loc7_:Number = param1;
         var _loc8_:Number = _loc4_ - param1;
         var _loc9_:Number = _loc5_ < _loc6_ ? Number(-_loc7_) : Number(_loc7_);
         var _loc10_:Number = _loc6_ > _loc5_ ? Number(_loc8_) : Number(-_loc8_);
         var _loc11_:Number = _loc2_.top;
         var _loc12_:Number = getStyle("verticalGap");
         var _loc13_:int = numChildren;
         var _loc14_:int = 0;
         while(_loc14_ < _loc13_)
         {
            _loc15_ = this.getHeaderAt(_loc14_);
            _loc16_ = UIComponent(getChildAt(_loc14_));
            _loc15_.$y = _loc11_;
            _loc11_ += _loc15_.height;
            if(_loc14_ == _loc5_)
            {
               _loc16_.cacheAsBitmap = true;
               _loc16_.scrollRect = new Rectangle(0,-_loc9_,_loc3_,_loc4_);
               _loc16_.visible = true;
               _loc11_ += _loc8_;
            }
            else if(_loc14_ == _loc6_)
            {
               _loc16_.cacheAsBitmap = true;
               _loc16_.scrollRect = new Rectangle(0,-_loc10_,_loc3_,_loc4_);
               _loc16_.visible = true;
               _loc11_ += _loc7_;
            }
            _loc11_ += _loc12_;
            _loc14_++;
         }
      }
      
      mx_internal function onTweenEnd(param1:Number) : void
      {
         var _loc9_:UIComponent = null;
         var _loc12_:Button = null;
         this.bSliding = false;
         var _loc2_:int = this.tweenOldSelectedIndex;
         var _loc3_:EdgeMetrics = this.tweenViewMetrics;
         var _loc4_:Number = getStyle("verticalGap");
         var _loc5_:Number = this.getHeaderHeight();
         var _loc6_:Number = this.calcContentWidth();
         var _loc7_:Number = this.calcContentHeight();
         var _loc8_:Number = _loc3_.top;
         var _loc10_:int = numChildren;
         var _loc11_:int = 0;
         while(_loc11_ < _loc10_)
         {
            (_loc12_ = this.getHeaderAt(_loc11_)).$y = _loc8_;
            _loc8_ += _loc5_;
            if(_loc11_ == this.selectedIndex)
            {
               (_loc9_ = UIComponent(getChildAt(_loc11_))).cacheAsBitmap = false;
               _loc9_.scrollRect = null;
               _loc9_.visible = true;
               _loc8_ += _loc7_;
            }
            _loc8_ += _loc4_;
            _loc11_++;
         }
         if(_loc2_ != -1)
         {
            (_loc9_ = UIComponent(getChildAt(_loc2_))).cacheAsBitmap = false;
            _loc9_.scrollRect = null;
            _loc9_.visible = false;
            _loc9_.tweeningProperties = null;
         }
         this.tweenViewMetrics = null;
         this.tweenContentWidth = NaN;
         this.tweenContentHeight = NaN;
         this.tweenOldSelectedIndex = 0;
         this.tweenNewSelectedIndex = 0;
         this.tween = null;
         UIComponent.resumeBackgroundProcessing();
         UIComponent(getChildAt(this.selectedIndex)).tweeningProperties = null;
         if(this.currentDissolveEffect)
         {
            if(this.currentDissolveEffect.target != null)
            {
               this.currentDissolveEffect.play();
            }
            else
            {
               this.currentDissolveEffect.play([this]);
            }
         }
         callLater(this.instantiateChild,[this.selectedChild]);
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.target != this)
         {
            return;
         }
         var _loc2_:int = this.selectedIndex;
         var _loc3_:uint = mapKeycodeForLayoutDirection(param1);
         switch(_loc3_)
         {
            case Keyboard.PAGE_DOWN:
               this.drawHeaderFocus(this._focusedIndex,false);
               this._focusedIndex = this.selectedIndex = this.selectedIndex < numChildren - 1 ? int(this.selectedIndex + 1) : 0;
               this.drawHeaderFocus(this._focusedIndex,true);
               param1.stopPropagation();
               this.dispatchChangeEvent(_loc2_,this.selectedIndex,param1);
               break;
            case Keyboard.PAGE_UP:
               this.drawHeaderFocus(this._focusedIndex,false);
               this._focusedIndex = this.selectedIndex = this.selectedIndex > 0 ? int(this.selectedIndex - 1) : int(numChildren - 1);
               this.drawHeaderFocus(this._focusedIndex,true);
               param1.stopPropagation();
               this.dispatchChangeEvent(_loc2_,this.selectedIndex,param1);
               break;
            case Keyboard.HOME:
               this.drawHeaderFocus(this._focusedIndex,false);
               this._focusedIndex = this.selectedIndex = 0;
               this.drawHeaderFocus(this._focusedIndex,true);
               param1.stopPropagation();
               this.dispatchChangeEvent(_loc2_,this.selectedIndex,param1);
               break;
            case Keyboard.END:
               this.drawHeaderFocus(this._focusedIndex,false);
               this._focusedIndex = this.selectedIndex = numChildren - 1;
               this.drawHeaderFocus(this._focusedIndex,true);
               param1.stopPropagation();
               this.dispatchChangeEvent(_loc2_,this.selectedIndex,param1);
               break;
            case Keyboard.DOWN:
            case Keyboard.RIGHT:
               this.drawHeaderFocus(this._focusedIndex,false);
               this._focusedIndex = this._focusedIndex < numChildren - 1 ? int(this._focusedIndex + 1) : 0;
               this.drawHeaderFocus(this._focusedIndex,true);
               param1.stopPropagation();
               break;
            case Keyboard.UP:
            case Keyboard.LEFT:
               this.drawHeaderFocus(this._focusedIndex,false);
               this._focusedIndex = this._focusedIndex > 0 ? int(this._focusedIndex - 1) : int(numChildren - 1);
               this.drawHeaderFocus(this._focusedIndex,true);
               param1.stopPropagation();
               break;
            case Keyboard.SPACE:
            case Keyboard.ENTER:
               param1.stopPropagation();
               if(this._focusedIndex != this.selectedIndex)
               {
                  this.selectedIndex = this._focusedIndex;
                  this.dispatchChangeEvent(_loc2_,this.selectedIndex,param1);
               }
         }
      }
      
      private function addedToStageHandler(param1:Event) : void
      {
         if(this.historyManagementEnabled)
         {
            HistoryManager.register(this);
         }
      }
      
      private function removedFromStageHandler(param1:Event) : void
      {
         HistoryManager.unregister(this);
      }
      
      private function childAddHandler(param1:ChildExistenceChangedEvent) : void
      {
         var _loc3_:Button = null;
         this.childAddedOrRemoved = true;
         var _loc2_:DisplayObject = param1.relatedObject;
         _loc2_.visible = false;
         this.createHeader(_loc2_,getChildIndex(_loc2_));
         _loc2_.addEventListener("labelChanged",this.labelChangedHandler,false,0,true);
         _loc2_.addEventListener("iconChanged",this.iconChangedHandler,false,0,true);
         if(numChildren == 1 && this.proposedSelectedIndex == -1)
         {
            this.selectedIndex = 0;
            _loc3_ = this.getHeaderAt(0);
            _loc3_.selected = true;
            this._focusedIndex = 0;
            this.drawHeaderFocus(this._focusedIndex,this.showFocusIndicator);
         }
         if(_loc2_ as IAutomationObject)
         {
            IAutomationObject(_loc2_).showInAutomationHierarchy = true;
         }
      }
      
      private function childRemoveHandler(param1:ChildExistenceChangedEvent) : void
      {
         var _loc4_:int = 0;
         var _loc8_:Button = null;
         this.childAddedOrRemoved = true;
         if(numChildren == 0)
         {
            return;
         }
         var _loc2_:DisplayObject = param1.relatedObject;
         var _loc3_:int = this.selectedIndex;
         var _loc5_:int = getChildIndex(_loc2_);
         _loc2_.removeEventListener("labelChanged",this.labelChangedHandler);
         _loc2_.removeEventListener("iconChanged",this.iconChangedHandler);
         var _loc6_:int = numChildren - 1;
         rawChildren.removeChild(this.getHeaderAt(_loc5_));
         var _loc7_:int = _loc5_;
         while(_loc7_ < _loc6_)
         {
            this.getHeaderAt(_loc7_ + 1).name = HEADER_NAME_BASE + _loc7_;
            _loc7_++;
         }
         if(_loc6_ == 0)
         {
            _loc4_ = this._focusedIndex = -1;
         }
         else
         {
            if(_loc5_ > this.selectedIndex)
            {
               return;
            }
            if(_loc5_ < this.selectedIndex)
            {
               _loc4_ = _loc3_ - 1;
            }
            else if(_loc5_ == this.selectedIndex)
            {
               if(_loc5_ == _loc6_)
               {
                  if((_loc4_ = _loc3_ - 1) != -1)
                  {
                     this.instantiateChild(INavigatorContent(getChildAt(_loc4_)));
                  }
               }
               else
               {
                  _loc4_ = _loc3_;
                  this.instantiateChild(INavigatorContent(getChildAt(_loc4_ + 1)));
               }
               (_loc8_ = this.getHeaderAt(_loc4_)).selected = true;
            }
         }
         if(this._focusedIndex > _loc5_)
         {
            --this._focusedIndex;
            this.drawHeaderFocus(this._focusedIndex,this.showFocusIndicator);
         }
         else if(this._focusedIndex == _loc5_)
         {
            if(_loc5_ == _loc6_)
            {
               --this._focusedIndex;
            }
            this.drawHeaderFocus(this._focusedIndex,this.showFocusIndicator);
         }
         this._selectedIndex = _loc4_;
         dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
      
      private function labelChangedHandler(param1:Event) : void
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         var _loc3_:int = getChildIndex(_loc2_);
         var _loc4_:Button;
         (_loc4_ = this.getHeaderAt(_loc3_)).label = INavigatorContent(param1.target).label;
      }
      
      private function iconChangedHandler(param1:Event) : void
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         var _loc3_:int = getChildIndex(_loc2_);
         var _loc4_:Button;
         (_loc4_ = this.getHeaderAt(_loc3_)).setStyle("icon",INavigatorContent(param1.target).icon);
      }
   }
}
