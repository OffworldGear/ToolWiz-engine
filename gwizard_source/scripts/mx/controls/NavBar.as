package mx.controls
{
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.containers.Box;
   import mx.containers.BoxDirection;
   import mx.containers.ViewStack;
   import mx.core.ClassFactory;
   import mx.core.IFactory;
   import mx.core.IFlexDisplayObject;
   import mx.core.INavigatorContent;
   import mx.core.ScrollPolicy;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.ChildExistenceChangedEvent;
   import mx.events.CollectionEvent;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.events.ItemClickEvent;
   import mx.styles.StyleProtoChain;
   
   use namespace mx_internal;
   
   public class NavBar extends Box
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      mx_internal var targetStack:ViewStack;
      
      private var pendingTargetStack:Object;
      
      mx_internal var navItemFactory:IFactory;
      
      private var lastToolTip:String = null;
      
      private var measurementHasBeenCalled:Boolean = false;
      
      private var _dataProvider:IList;
      
      private var dataProviderChanged:Boolean = false;
      
      private var _iconField:String = "icon";
      
      private var _labelField:String = "label";
      
      private var _labelFunction:Function;
      
      private var _selectedIndex:int = -1;
      
      private var _toolTipField:String = "toolTip";
      
      public function NavBar()
      {
         this.navItemFactory = new ClassFactory(Button);
         super();
         direction = BoxDirection.HORIZONTAL;
         showInAutomationHierarchy = true;
      }
      
      override public function get baselinePosition() : Number
      {
         if(!validateBaselinePosition())
         {
            return NaN;
         }
         if(numChildren == 0)
         {
            return super.baselinePosition;
         }
         var _loc1_:Button = Button(getChildAt(0));
         validateNow();
         return _loc1_.y + _loc1_.baselinePosition;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 != enabled)
         {
            super.enabled = param1;
            _loc2_ = numChildren;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(this.targetStack)
               {
                  Button(getChildAt(_loc3_)).enabled = param1 && UIComponent(this.targetStack.getChildAt(_loc3_)).enabled;
               }
               else
               {
                  Button(getChildAt(_loc3_)).enabled = param1;
               }
               _loc3_++;
            }
         }
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
      
      [Bindable("collectionChange")]
      public function get dataProvider() : Object
      {
         return !!this.targetStack ? this.targetStack : this._dataProvider;
      }
      
      public function set dataProvider(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(param1 && !(param1 is String) && !(param1 is ViewStack) && !(param1 is Array) && !(param1 is IList))
         {
            _loc2_ = resourceManager.getString("controls","errWrongContainer",[id]);
            throw new Error(_loc2_);
         }
         if(this._dataProvider)
         {
            this._dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler);
         }
         if(param1 is String && (document && document[param1]))
         {
            param1 = document[param1];
         }
         if(param1 is String || param1 is ViewStack)
         {
            this.setTargetViewStack(param1);
            return;
         }
         if(param1 is IList && IList(param1).length > 0 && IList(param1).getItemAt(0) is DisplayObject || param1 is Array && (param1 as Array).length > 0 && param1[0] is DisplayObject)
         {
            _loc3_ = !!id ? className + " \'" + id + "\'" : "a " + className;
            _loc2_ = resourceManager.getString("controls","errWrongType",[_loc3_]);
            throw new Error(_loc2_);
         }
         this.setTargetViewStack(null);
         removeAllChildren();
         if(param1 is IList)
         {
            this._dataProvider = IList(param1);
         }
         else if(param1 is Array)
         {
            this._dataProvider = new ArrayCollection(param1 as Array);
         }
         else
         {
            this._dataProvider = null;
         }
         this.dataProviderChanged = true;
         invalidateProperties();
         if(this._dataProvider)
         {
            this._dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,0,true);
         }
         if(inheritingStyles == StyleProtoChain.STYLE_UNINITIALIZED)
         {
            return;
         }
         dispatchEvent(new Event("collectionChange"));
      }
      
      [Bindable("iconFieldChanged")]
      public function get iconField() : String
      {
         return this._iconField;
      }
      
      public function set iconField(param1:String) : void
      {
         this._iconField = param1;
         if(this._dataProvider)
         {
            this.dataProvider = this._dataProvider;
         }
         dispatchEvent(new Event("iconFieldChanged"));
      }
      
      [Bindable("labelFieldChanged")]
      public function get labelField() : String
      {
         return this._labelField;
      }
      
      public function set labelField(param1:String) : void
      {
         this._labelField = param1;
         if(this._dataProvider)
         {
            this.dataProvider = this._dataProvider;
         }
         dispatchEvent(new Event("labelFieldChanged"));
      }
      
      [Bindable("labelFunctionChanged")]
      public function get labelFunction() : Function
      {
         return this._labelFunction;
      }
      
      public function set labelFunction(param1:Function) : void
      {
         this._labelFunction = param1;
         if(this._dataProvider)
         {
            this.dataProvider = this._dataProvider;
         }
         dispatchEvent(new Event("labelFunctionChanged"));
      }
      
      [Bindable("valueCommit")]
      [Bindable("itemClick")]
      public function get selectedIndex() : int
      {
         return this._selectedIndex;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         this._selectedIndex = param1;
         if(this.targetStack)
         {
            this.targetStack.selectedIndex = param1;
         }
         dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
      
      [Bindable("toolTipFieldChanged")]
      public function get toolTipField() : String
      {
         return this._toolTipField;
      }
      
      public function set toolTipField(param1:String) : void
      {
         this._toolTipField = param1;
         if(this._dataProvider)
         {
            this.dataProvider = this._dataProvider;
         }
         dispatchEvent(new Event("toolTipFieldChanged"));
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         if(this.dataProviderChanged)
         {
            this.createNavChildren();
            this.dataProviderChanged = false;
         }
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(!this.measurementHasBeenCalled)
         {
            this.checkPendingTargetStack();
            this.measurementHasBeenCalled = true;
         }
         if(this.dataProviderChanged)
         {
            this.dataProviderChanged = false;
            this.createNavChildren();
         }
         if(mx_internal::blocker)
         {
            mx_internal::blocker.visible = false;
         }
      }
      
      override public function notifyStyleChangeInChildren(param1:String, param2:Boolean) : void
      {
         super.notifyStyleChangeInChildren(param1,true);
      }
      
      public function itemToLabel(param1:Object) : String
      {
         if(param1 == null)
         {
            return "";
         }
         if(this.labelFunction != null)
         {
            return this.labelFunction(param1);
         }
         if(param1 is XML)
         {
            try
            {
               if(param1[this.labelField].length() != 0)
               {
                  param1 = param1[this.labelField];
               }
            }
            catch(e:Error)
            {
            }
         }
         else if(param1 is Object)
         {
            try
            {
               if(param1[this.labelField] != null)
               {
                  param1 = param1[this.labelField];
               }
            }
            catch(e:Error)
            {
            }
         }
         if(param1 is String)
         {
            return String(param1);
         }
         if(param1 is Number)
         {
            return param1.toString();
         }
         return "";
      }
      
      protected function createNavItem(param1:String, param2:Class = null) : IFlexDisplayObject
      {
         return null;
      }
      
      protected function hiliteSelectedNavItem(param1:int) : void
      {
      }
      
      protected function resetNavItems() : void
      {
      }
      
      protected function updateNavItemLabel(param1:int, param2:String) : void
      {
         var _loc3_:Button = Button(getChildAt(param1));
         _loc3_.label = param2;
      }
      
      protected function updateNavItemIcon(param1:int, param2:Class) : void
      {
         var _loc3_:Button = Button(getChildAt(param1));
         _loc3_.setStyle("icon",param2);
      }
      
      private function createNavChildren() : void
      {
         var _loc3_:Object = null;
         var _loc4_:Button = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:Class = null;
         if(!this._dataProvider)
         {
            return;
         }
         var _loc1_:int = this._dataProvider.length;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this._dataProvider.getItemAt(_loc2_);
            if(_loc3_ is String && this.labelFunction == null)
            {
               _loc4_ = Button(this.createNavItem(String(_loc3_)));
            }
            else
            {
               _loc5_ = this.itemToLabel(_loc3_);
               if(this.iconField)
               {
                  _loc6_ = null;
                  try
                  {
                     _loc6_ = _loc3_[this.iconField];
                  }
                  catch(e:Error)
                  {
                  }
                  _loc7_ = _loc6_ is String ? Class(systemManager.getDefinitionByName(String(_loc6_))) : Class(_loc6_);
                  _loc4_ = Button(this.createNavItem(_loc5_,_loc7_));
               }
               else
               {
                  _loc4_ = Button(this.createNavItem(_loc5_,null));
               }
               if(this.toolTipField)
               {
                  try
                  {
                     _loc4_.toolTip = _loc3_[this.toolTipField] === undefined ? null : _loc3_[this.toolTipField];
                  }
                  catch(e:Error)
                  {
                  }
               }
            }
            _loc4_.enabled = enabled;
            _loc2_++;
         }
         this.resetNavItems();
      }
      
      private function setTargetViewStack(param1:Object) : void
      {
         if(!this.measurementHasBeenCalled && param1)
         {
            this.pendingTargetStack = param1;
            invalidateProperties();
         }
         else
         {
            this._setTargetViewStack(param1);
         }
      }
      
      private function _setTargetViewStack(param1:Object) : void
      {
         var _loc2_:ViewStack = null;
         var _loc4_:int = 0;
         var _loc5_:INavigatorContent = null;
         var _loc6_:int = 0;
         var _loc7_:Button = null;
         if(param1 is ViewStack)
         {
            _loc2_ = ViewStack(param1);
         }
         else if(param1)
         {
            _loc2_ = parentDocument[param1];
         }
         else
         {
            _loc2_ = null;
         }
         if(this.targetStack)
         {
            this.targetStack.removeEventListener(ChildExistenceChangedEvent.CHILD_ADD,this.childAddHandler);
            this.targetStack.removeEventListener(ChildExistenceChangedEvent.CHILD_REMOVE,this.childRemoveHandler);
            this.targetStack.removeEventListener(Event.CHANGE,this.changeHandler);
            this.targetStack.removeEventListener(FlexEvent.VALUE_COMMIT,this.changeHandler);
            this.targetStack.removeEventListener(IndexChangedEvent.CHILD_INDEX_CHANGE,this.childIndexChangeHandler);
            _loc4_ = this.targetStack.numChildren;
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               (_loc5_ = INavigatorContent(this.targetStack.getChildAt(_loc6_))).removeEventListener("labelChanged",this.labelChangedHandler);
               _loc5_.removeEventListener("iconChanged",this.iconChangedHandler);
               _loc5_.removeEventListener("enabledChanged",this.enabledChangedHandler);
               _loc5_.removeEventListener("toolTipChanged",this.toolTipChangedHandler);
               _loc6_++;
            }
         }
         removeAllChildren();
         this._selectedIndex = -1;
         this.targetStack = _loc2_;
         if(!this.targetStack)
         {
            return;
         }
         this.targetStack.addEventListener(ChildExistenceChangedEvent.CHILD_ADD,this.childAddHandler);
         this.targetStack.addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE,this.childRemoveHandler);
         this.targetStack.addEventListener(Event.CHANGE,this.changeHandler);
         this.targetStack.addEventListener(FlexEvent.VALUE_COMMIT,this.changeHandler);
         this.targetStack.addEventListener(IndexChangedEvent.CHILD_INDEX_CHANGE,this.childIndexChangeHandler);
         _loc4_ = this.targetStack.numChildren;
         _loc6_ = 0;
         while(_loc6_ < _loc4_)
         {
            _loc5_ = INavigatorContent(this.targetStack.getChildAt(_loc6_));
            _loc7_ = Button(this.createNavItem(this.itemToLabel(_loc5_),_loc5_.icon));
            if(_loc5_.toolTip)
            {
               _loc7_.toolTip = _loc5_.toolTip;
               _loc5_.toolTip = null;
            }
            _loc5_.addEventListener("labelChanged",this.labelChangedHandler);
            _loc5_.addEventListener("iconChanged",this.iconChangedHandler);
            _loc5_.addEventListener("enabledChanged",this.enabledChangedHandler);
            _loc5_.addEventListener("toolTipChanged",this.toolTipChangedHandler);
            _loc7_.enabled = enabled && _loc5_.enabled;
            _loc6_++;
         }
         var _loc3_:int = this.targetStack.selectedIndex;
         if(_loc3_ == -1 && this.targetStack.numChildren > 0)
         {
            _loc3_ = 0;
         }
         if(_loc3_ != -1)
         {
            this.hiliteSelectedNavItem(_loc3_);
         }
         this.resetNavItems();
         invalidateDisplayList();
      }
      
      private function checkPendingTargetStack() : void
      {
         if(this.pendingTargetStack)
         {
            this._setTargetViewStack(this.pendingTargetStack);
            this.pendingTargetStack = null;
         }
      }
      
      private function collectionChangeHandler(param1:Event) : void
      {
         this.dataProvider = this.dataProvider;
      }
      
      private function childAddHandler(param1:ChildExistenceChangedEvent) : void
      {
         if(param1.target == this)
         {
            return;
         }
         if(param1.relatedObject.parent != this.targetStack)
         {
            return;
         }
         var _loc2_:INavigatorContent = INavigatorContent(param1.relatedObject);
         var _loc3_:Button = Button(this.createNavItem(this.itemToLabel(_loc2_),_loc2_.icon));
         var _loc4_:int = _loc2_.parent.getChildIndex(DisplayObject(_loc2_));
         setChildIndex(_loc3_,_loc4_);
         if(_loc2_.toolTip)
         {
            _loc3_.toolTip = _loc2_.toolTip;
            _loc2_.toolTip = null;
         }
         _loc2_.addEventListener("labelChanged",this.labelChangedHandler);
         _loc2_.addEventListener("iconChanged",this.iconChangedHandler);
         _loc2_.addEventListener("enabledChanged",this.enabledChangedHandler);
         _loc2_.addEventListener("toolTipChanged",this.toolTipChangedHandler);
         _loc3_.enabled = enabled && _loc2_.enabled;
         callLater(this.resetNavItems);
      }
      
      private function childRemoveHandler(param1:ChildExistenceChangedEvent) : void
      {
         if(param1.target == this)
         {
            return;
         }
         param1.relatedObject.removeEventListener("labelChanged",this.labelChangedHandler);
         param1.relatedObject.removeEventListener("iconChanged",this.iconChangedHandler);
         param1.relatedObject.removeEventListener("enabledChanged",this.enabledChangedHandler);
         param1.relatedObject.removeEventListener("toolTipChanged",this.toolTipChangedHandler);
         var _loc2_:ViewStack = ViewStack(param1.target);
         removeChildAt(_loc2_.getChildIndex(param1.relatedObject));
         callLater(this.resetNavItems);
      }
      
      private function changeHandler(param1:Event) : void
      {
         if(param1.target == this.dataProvider)
         {
            this.hiliteSelectedNavItem(Object(param1.target).selectedIndex);
         }
      }
      
      private function childIndexChangeHandler(param1:IndexChangedEvent) : void
      {
         if(param1.target == this)
         {
            return;
         }
         setChildIndex(getChildAt(param1.oldIndex),param1.newIndex);
         this.resetNavItems();
      }
      
      private function labelChangedHandler(param1:Event) : void
      {
         var _loc2_:int = this.targetStack.getChildIndex(DisplayObject(param1.target));
         this.updateNavItemLabel(_loc2_,INavigatorContent(param1.target).label);
      }
      
      private function iconChangedHandler(param1:Event) : void
      {
         var _loc2_:int = this.targetStack.getChildIndex(DisplayObject(param1.target));
         this.updateNavItemIcon(_loc2_,INavigatorContent(param1.target).icon);
      }
      
      private function toolTipChangedHandler(param1:Event) : void
      {
         var _loc2_:int = this.targetStack.getChildIndex(DisplayObject(param1.target));
         var _loc3_:UIComponent = UIComponent(getChildAt(_loc2_));
         if(UIComponent(param1.target).toolTip)
         {
            _loc3_.toolTip = UIComponent(param1.target).toolTip;
            this.lastToolTip = UIComponent(param1.target).toolTip;
            UIComponent(param1.target).toolTip = null;
         }
         else if(!this.lastToolTip)
         {
            _loc3_.toolTip = UIComponent(param1.target).toolTip;
            this.lastToolTip = "placeholder";
            UIComponent(param1.target).toolTip = null;
         }
         else
         {
            this.lastToolTip = null;
         }
      }
      
      private function enabledChangedHandler(param1:Event) : void
      {
         var _loc2_:int = this.targetStack.getChildIndex(DisplayObject(param1.target));
         Button(getChildAt(_loc2_)).enabled = enabled && param1.target.enabled;
      }
      
      protected function clickHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = getChildIndex(DisplayObject(param1.currentTarget));
         if(this.targetStack)
         {
            this.targetStack.selectedIndex = _loc2_;
         }
         this._selectedIndex = _loc2_;
         var _loc3_:ItemClickEvent = new ItemClickEvent(ItemClickEvent.ITEM_CLICK);
         _loc3_.label = Button(param1.currentTarget).label;
         _loc3_.index = _loc2_;
         _loc3_.relatedObject = InteractiveObject(param1.currentTarget);
         _loc3_.item = !!this._dataProvider ? this._dataProvider.getItemAt(_loc2_) : null;
         dispatchEvent(_loc3_);
         param1.stopImmediatePropagation();
      }
   }
}
