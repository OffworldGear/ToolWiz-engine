package mx.containers
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import mx.automation.IAutomationObject;
   import mx.core.Container;
   import mx.core.ContainerCreationPolicy;
   import mx.core.EdgeMetrics;
   import mx.core.IInvalidating;
   import mx.core.INavigatorContent;
   import mx.core.ISelectableList;
   import mx.core.IUIComponent;
   import mx.core.ScrollPolicy;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.effects.Effect;
   import mx.effects.EffectManager;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.EffectEvent;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.events.PropertyChangeEvent;
   import mx.geom.RoundedRectangle;
   import mx.managers.HistoryManager;
   import mx.managers.IHistoryManagerClient;
   
   use namespace mx_internal;
   
   public class ViewStack extends Container implements IHistoryManagerClient, ISelectableList
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var needToInstantiateSelectedChild:Boolean = false;
      
      private var bSaveState:Boolean = false;
      
      private var bInLoadState:Boolean = false;
      
      private var firstTime:Boolean = true;
      
      mx_internal var vsMinWidth:Number;
      
      mx_internal var vsMinHeight:Number;
      
      mx_internal var vsPreferredWidth:Number;
      
      mx_internal var vsPreferredHeight:Number;
      
      private var effectOverlayChild:UIComponent;
      
      private var effectOverlayTargetArea:RoundedRectangle;
      
      private var lastIndex:int = -1;
      
      private var dispatchChangeEventPending:Boolean = false;
      
      private var addingChildren:Boolean = false;
      
      mx_internal var _historyManagementEnabled:Boolean = false;
      
      private var historyManagementEnabledChanged:Boolean = false;
      
      private var _resizeToContent:Boolean = false;
      
      private var _selectedIndex:int = -1;
      
      private var proposedSelectedIndex:int = -1;
      
      private var initialSelectedIndex:int = -1;
      
      public function ViewStack()
      {
         super();
      }
      
      override public function get autoLayout() : Boolean
      {
         return true;
      }
      
      override public function set autoLayout(param1:Boolean) : void
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
      
      protected function get contentHeight() : Number
      {
         var _loc1_:EdgeMetrics = viewMetricsAndPadding;
         return unscaledHeight - _loc1_.top - _loc1_.bottom;
      }
      
      protected function get contentWidth() : Number
      {
         var _loc1_:EdgeMetrics = viewMetricsAndPadding;
         return unscaledWidth - _loc1_.left - _loc1_.right;
      }
      
      protected function get contentX() : Number
      {
         return getStyle("paddingLeft");
      }
      
      protected function get contentY() : Number
      {
         return getStyle("paddingTop");
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
      
      [Bindable("creationComplete")]
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
      
      [Bindable("creationComplete")]
      [Bindable("valueCommit")]
      [Bindable("change")]
      public function get selectedIndex() : int
      {
         return this.proposedSelectedIndex == -1 ? int(this._selectedIndex) : int(this.proposedSelectedIndex);
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(param1 == this.selectedIndex)
         {
            return;
         }
         if(this.addingChildren)
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
         if(this.proposedSelectedIndex != -1)
         {
            this.commitSelectedIndex(this.proposedSelectedIndex);
            this.proposedSelectedIndex = -1;
         }
         if(this.needToInstantiateSelectedChild)
         {
            this.instantiateSelectedChild();
            this.needToInstantiateSelectedChild = false;
         }
         if(this.dispatchChangeEventPending)
         {
            this.dispatchChangeEvent(this.lastIndex,this.selectedIndex);
            this.dispatchChangeEventPending = false;
         }
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
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc8_:UIComponent = null;
         super.measure();
         var _loc1_:Number = 0;
         _loc2_ = 0;
         _loc3_ = 0;
         _loc4_ = 0;
         if(this.vsPreferredWidth && !this._resizeToContent)
         {
            measuredMinWidth = this.vsMinWidth;
            measuredMinHeight = this.vsMinHeight;
            measuredWidth = this.vsPreferredWidth;
            measuredHeight = this.vsPreferredHeight;
            return;
         }
         if(numChildren > 0 && this.selectedIndex != -1)
         {
            _loc1_ = (_loc8_ = UIComponent(getChildAt(this.selectedIndex))).minWidth;
            _loc3_ = _loc8_.getExplicitOrMeasuredWidth();
            _loc2_ = _loc8_.minHeight;
            _loc4_ = _loc8_.getExplicitOrMeasuredHeight();
         }
         var _loc5_:EdgeMetrics;
         var _loc6_:Number = (_loc5_ = viewMetricsAndPadding).left + _loc5_.right;
         _loc1_ += _loc6_;
         _loc3_ += _loc6_;
         var _loc7_:Number = _loc5_.top + _loc5_.bottom;
         _loc2_ += _loc7_;
         _loc4_ += _loc7_;
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
         this.vsMinWidth = _loc1_;
         this.vsMinHeight = _loc2_;
         this.vsPreferredWidth = _loc3_;
         this.vsPreferredHeight = _loc4_;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc8_:UIComponent = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         super.updateDisplayList(param1,param2);
         var _loc3_:int = numChildren;
         var _loc4_:Number = this.contentWidth;
         var _loc5_:Number = this.contentHeight;
         var _loc6_:Number = this.contentX;
         var _loc7_:Number = this.contentY;
         if(this.selectedIndex != -1)
         {
            _loc8_ = UIComponent(getChildAt(this.selectedIndex));
            _loc9_ = _loc4_;
            _loc10_ = _loc5_;
            if(!isNaN(_loc8_.percentWidth))
            {
               if(_loc9_ > _loc8_.maxWidth)
               {
                  _loc9_ = _loc8_.maxWidth;
               }
            }
            else if(_loc9_ > _loc8_.explicitWidth)
            {
               _loc9_ = _loc8_.explicitWidth;
            }
            if(!isNaN(_loc8_.percentHeight))
            {
               if(_loc10_ > _loc8_.maxHeight)
               {
                  _loc10_ = _loc8_.maxHeight;
               }
            }
            else if(_loc10_ > _loc8_.explicitHeight)
            {
               _loc10_ = _loc8_.explicitHeight;
            }
            if(_loc8_.width != _loc9_ || _loc8_.height != _loc10_)
            {
               _loc8_.setActualSize(_loc9_,_loc10_);
            }
            if(_loc8_.x != _loc6_ || _loc8_.y != _loc7_)
            {
               _loc8_.move(_loc6_,_loc7_);
            }
            _loc8_.visible = true;
         }
      }
      
      override mx_internal function addOverlay(param1:uint, param2:RoundedRectangle = null) : void
      {
         if(this.effectOverlayChild)
         {
            this.removeOverlay();
         }
         this.effectOverlayChild = this.selectedChild as UIComponent;
         if(!this.effectOverlayChild)
         {
            return;
         }
         effectOverlayColor = param1;
         this.effectOverlayTargetArea = param2;
         if(this.selectedChild && this.selectedChild.deferredContentCreated == false)
         {
            this.selectedChild.addEventListener(FlexEvent.INITIALIZE,this.initializeHandler);
         }
         else
         {
            this.initializeHandler(null);
         }
      }
      
      override mx_internal function removeOverlay() : void
      {
         if(this.effectOverlayChild)
         {
            UIComponent(this.effectOverlayChild).removeOverlay();
            this.effectOverlayChild = null;
         }
      }
      
      override mx_internal function setActualCreationPolicies(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:INavigatorContent = null;
         super.setActualCreationPolicies(param1);
         if(param1 == ContainerCreationPolicy.ALL && numChildren > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < numChildren)
            {
               _loc3_ = getChildAt(_loc2_) as INavigatorContent;
               if(_loc3_ && _loc3_.deferredContentCreated == false)
               {
                  _loc3_.createDeferredContent();
               }
               _loc2_++;
            }
         }
      }
      
      override public function createComponentsFromDescriptors(param1:Boolean = true) : void
      {
         if(actualCreationPolicy == ContainerCreationPolicy.ALL)
         {
            super.createComponentsFromDescriptors();
            return;
         }
         var _loc2_:int = numChildren;
         var _loc3_:int = !!childDescriptors ? int(childDescriptors.length) : 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            createComponentFromDescriptor(childDescriptors[_loc4_],false);
            _loc4_++;
         }
         numChildrenCreated = numChildren - _loc2_;
         processedDescriptors = true;
         dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
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
      
      protected function commitSelectedIndex(param1:int) : void
      {
         var _loc3_:UIComponent = null;
         var _loc4_:Effect = null;
         if(numChildren == 0)
         {
            this._selectedIndex = -1;
            return;
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > numChildren - 1)
         {
            param1 = numChildren - 1;
         }
         if(this.lastIndex != -1 && this.lastIndex < numChildren)
         {
            UIComponent(getChildAt(this.lastIndex)).endEffectsStarted();
         }
         if(this._selectedIndex != -1)
         {
            (this.selectedChild as UIComponent).endEffectsStarted();
         }
         this.lastIndex = this._selectedIndex;
         if(param1 == this.lastIndex)
         {
            return;
         }
         this._selectedIndex = param1;
         if(this.initialSelectedIndex == -1)
         {
            this.initialSelectedIndex = this._selectedIndex;
         }
         if(this.lastIndex != -1 && param1 != -1)
         {
            this.dispatchChangeEventPending = true;
         }
         var _loc2_:Boolean = false;
         if(this.lastIndex != -1 && this.lastIndex < numChildren)
         {
            _loc3_ = UIComponent(getChildAt(this.lastIndex));
            _loc3_.setVisible(false);
            if(_loc3_.getStyle("hideEffect"))
            {
               if(_loc4_ = EffectManager.lastEffectCreated)
               {
                  _loc4_.addEventListener(EffectEvent.EFFECT_END,this.hideEffectEndHandler);
                  _loc2_ = true;
               }
            }
         }
         if(!_loc2_)
         {
            this.hideEffectEndHandler(null);
         }
      }
      
      private function hideEffectEndHandler(param1:EffectEvent) : void
      {
         if(param1)
         {
            param1.currentTarget.removeEventListener(EffectEvent.EFFECT_END,this.hideEffectEndHandler);
         }
         this.needToInstantiateSelectedChild = true;
         invalidateProperties();
         if(this.bSaveState)
         {
            HistoryManager.save();
            this.bSaveState = false;
         }
      }
      
      private function instantiateSelectedChild() : void
      {
         if(!this.selectedChild)
         {
            return;
         }
         if(this.selectedChild && this.selectedChild.deferredContentCreated == false)
         {
            if(initialized)
            {
               this.selectedChild.addEventListener(FlexEvent.CREATION_COMPLETE,this.childCreationCompleteHandler);
            }
            this.selectedChild.createDeferredContent();
         }
         if(this.selectedChild is IInvalidating)
         {
            IInvalidating(this.selectedChild).invalidateSize();
         }
         invalidateSize();
         invalidateDisplayList();
      }
      
      private function dispatchChangeEvent(param1:int, param2:int) : void
      {
         var _loc3_:IndexChangedEvent = new IndexChangedEvent(IndexChangedEvent.CHANGE);
         _loc3_.oldIndex = param1;
         _loc3_.newIndex = param2;
         _loc3_.relatedObject = getChildAt(param2);
         dispatchEvent(_loc3_);
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
      
      private function initializeHandler(param1:FlexEvent) : void
      {
         this.effectOverlayChild.removeEventListener(FlexEvent.INITIALIZE,this.initializeHandler);
         UIComponent(this.effectOverlayChild).addOverlay(mx_internal::effectOverlayColor,this.effectOverlayTargetArea);
      }
      
      private function childCreationCompleteHandler(param1:FlexEvent) : void
      {
         param1.target.removeEventListener(FlexEvent.CREATION_COMPLETE,this.childCreationCompleteHandler);
         param1.target.dispatchEvent(new FlexEvent(FlexEvent.SHOW));
      }
      
      private function childAddHandler(param1:DisplayObject) : void
      {
         var _loc3_:IUIComponent = null;
         var _loc2_:int = getChildIndex(param1);
         if(param1 is IUIComponent)
         {
            _loc3_ = IUIComponent(param1);
            _loc3_.visible = false;
         }
         if(param1 is INavigatorContent)
         {
            param1.addEventListener("labelChanged",this.navigatorChildChangedHandler);
            param1.addEventListener("iconChanged",this.navigatorChildChangedHandler);
         }
         if(numChildren == 1 && this.proposedSelectedIndex == -1)
         {
            this._selectedIndex = 0;
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            this.needToInstantiateSelectedChild = true;
            invalidateProperties();
         }
         else if(_loc2_ <= this.selectedIndex && numChildren > 1 && this.proposedSelectedIndex == -1)
         {
            ++this._selectedIndex;
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
         }
         if(param1 is IAutomationObject)
         {
            IAutomationObject(param1).showInAutomationHierarchy = true;
         }
      }
      
      private function childRemoveHandler(param1:DisplayObject, param2:int) : void
      {
         if(param1 is INavigatorContent)
         {
            param1.removeEventListener("labelChanged",this.navigatorChildChangedHandler);
            param1.removeEventListener("iconChanged",this.navigatorChildChangedHandler);
         }
         if(param2 > this.selectedIndex)
         {
            return;
         }
         var _loc3_:int = this.selectedIndex;
         if(param2 < _loc3_ || _loc3_ == numChildren)
         {
            if(_loc3_ == 0)
            {
               this._selectedIndex = -1;
               dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
            else
            {
               --this._selectedIndex;
               dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
         }
         else if(param2 == _loc3_)
         {
            this.needToInstantiateSelectedChild = true;
            invalidateProperties();
         }
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         this.addingChildren = true;
         var _loc3_:DisplayObject = super.addChildAt(param1,param2);
         this.internalDispatchEvent(CollectionEventKind.ADD,_loc3_,param2);
         this.childAddHandler(param1);
         this.addingChildren = false;
         return _loc3_;
      }
      
      override public function removeChild(param1:DisplayObject) : DisplayObject
      {
         var _loc2_:int = getChildIndex(param1);
         var _loc3_:DisplayObject = super.removeChild(param1);
         this.internalDispatchEvent(CollectionEventKind.REMOVE,_loc3_,_loc2_);
         this.childRemoveHandler(param1,_loc2_);
         return _loc3_;
      }
      
      override public function removeAllChildren() : void
      {
         super.removeAllChildren();
         this.internalDispatchEvent(CollectionEventKind.RESET);
      }
      
      private function navigatorChildChangedHandler(param1:Event) : void
      {
         var _loc2_:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
         _loc2_.source = param1.target;
         _loc2_.property = param1.type == "labelChanged" ? "label" : "icon";
         this.internalDispatchEvent(CollectionEventKind.UPDATE,_loc2_,getChildIndex(param1.target as DisplayObject));
      }
      
      private function internalDispatchEvent(param1:String, param2:Object = null, param3:int = -1) : void
      {
         var _loc4_:CollectionEvent = null;
         var _loc5_:PropertyChangeEvent = null;
         if(hasEventListener(CollectionEvent.COLLECTION_CHANGE))
         {
            (_loc4_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE)).kind = param1;
            _loc4_.items.push(param2);
            _loc4_.location = param3;
            dispatchEvent(_loc4_);
         }
         if(hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE) && (param1 == CollectionEventKind.ADD || param1 == CollectionEventKind.REMOVE))
         {
            (_loc5_ = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE)).property = param3;
            if(param1 == CollectionEventKind.ADD)
            {
               _loc5_.newValue = param2;
            }
            else
            {
               _loc5_.oldValue = param2;
            }
            dispatchEvent(_loc5_);
         }
      }
      
      public function get length() : int
      {
         return numChildren;
      }
      
      public function addItem(param1:Object) : void
      {
         addChild(param1 as DisplayObject);
      }
      
      public function addItemAt(param1:Object, param2:int) : void
      {
         this.addChildAt(param1 as DisplayObject,param2);
      }
      
      public function getItemAt(param1:int, param2:int = 0) : Object
      {
         return getChildAt(param1);
      }
      
      public function getItemIndex(param1:Object) : int
      {
         return getChildIndex(param1 as DisplayObject);
      }
      
      public function itemUpdated(param1:Object, param2:Object = null, param3:Object = null, param4:Object = null) : void
      {
      }
      
      public function removeAll() : void
      {
         this.removeAllChildren();
      }
      
      public function removeItemAt(param1:int) : Object
      {
         return removeChildAt(param1);
      }
      
      public function setItemAt(param1:Object, param2:int) : Object
      {
         var _loc3_:Object = removeChildAt(param2);
         this.addChildAt(param1 as DisplayObject,param2);
         return _loc3_;
      }
      
      public function toArray() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < numChildren)
         {
            _loc1_.push(getChildAt(_loc2_));
            _loc2_++;
         }
         return _loc1_;
      }
   }
}
