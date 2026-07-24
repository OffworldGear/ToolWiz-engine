package mx.controls
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.ui.Keyboard;
   import flash.xml.XMLNode;
   import mx.collections.ArrayCollection;
   import mx.collections.ICollectionView;
   import mx.collections.IViewCursor;
   import mx.collections.XMLListCollection;
   import mx.collections.errors.ItemPendingError;
   import mx.containers.ApplicationControlBar;
   import mx.controls.menuClasses.IMenuBarItemRenderer;
   import mx.controls.menuClasses.IMenuDataDescriptor;
   import mx.controls.menuClasses.MenuBarItem;
   import mx.controls.treeClasses.DefaultDataDescriptor;
   import mx.core.ClassFactory;
   import mx.core.EventPriority;
   import mx.core.IFactory;
   import mx.core.IFlexDisplayObject;
   import mx.core.IUIComponent;
   import mx.core.LayoutDirection;
   import mx.core.UIComponent;
   import mx.core.UIComponentGlobals;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.FlexEvent;
   import mx.events.MenuEvent;
   import mx.managers.IFocusManagerComponent;
   import mx.managers.ISystemManager;
   import mx.managers.PopUpManager;
   import mx.styles.ISimpleStyleClient;
   import mx.styles.StyleProxy;
   
   use namespace mx_internal;
   
   public class MenuBar extends UIComponent implements IFocusManagerComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const MARGIN_WIDTH:int = 10;
      
      mx_internal static var createAccessibilityImplementation:Function;
      
      private static var _menuBarItemStyleFilters:Object = null;
       
      
      mx_internal var _rootModel:ICollectionView;
      
      private var isDown:Boolean;
      
      private var inKeyDown:Boolean = false;
      
      private var background:IFlexDisplayObject;
      
      private var isInsideACB:Boolean = false;
      
      private var supposedToLoseFocus:Boolean = false;
      
      private var dataProviderChanged:Boolean = false;
      
      private var iconFieldChanged:Boolean = false;
      
      private var menuBarItemRendererChanged:Boolean = false;
      
      mx_internal var _dataDescriptor:IMenuDataDescriptor;
      
      mx_internal var _hasRoot:Boolean = false;
      
      private var _iconField:String = "icon";
      
      private var _labelField:String = "label";
      
      public var labelFunction:Function;
      
      private var _menuBarItemRenderer:IFactory;
      
      public var menuBarItems:Array;
      
      public var menus:Array;
      
      private var openMenuIndex:int = -1;
      
      mx_internal var _showRoot:Boolean = true;
      
      mx_internal var showRootChanged:Boolean = false;
      
      public function MenuBar()
      {
         this._dataDescriptor = new DefaultDataDescriptor();
         this.menuBarItems = [];
         this.menus = [];
         super();
         this.menuBarItemRenderer = new ClassFactory(MenuBarItem);
         tabChildren = false;
      }
      
      private static function menuHideHandler(param1:MenuEvent) : void
      {
         var _loc2_:Menu = Menu(param1.target);
         if(!param1.isDefaultPrevented() && param1.menu == _loc2_)
         {
            _loc2_.supposedToLoseFocus = true;
            PopUpManager.removePopUp(_loc2_);
            _loc2_.removeEventListener(MenuEvent.MENU_HIDE,menuHideHandler);
         }
      }
      
      override public function get baselinePosition() : Number
      {
         if(!validateBaselinePosition())
         {
            return NaN;
         }
         if(this.menuBarItems.length == 0)
         {
            return super.baselinePosition;
         }
         var _loc1_:IUIComponent = this.menuBarItems[0] as IUIComponent;
         if(!_loc1_)
         {
            return super.baselinePosition;
         }
         validateNow();
         return _loc1_.y + _loc1_.baselinePosition;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         super.enabled = param1;
         if(this.menuBarItems)
         {
            _loc2_ = this.menuBarItems.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               this.menuBarItems[_loc3_].enabled = param1;
               _loc3_++;
            }
         }
      }
      
      override public function set showInAutomationHierarchy(param1:Boolean) : void
      {
      }
      
      public function get dataDescriptor() : IMenuDataDescriptor
      {
         return IMenuDataDescriptor(this._dataDescriptor);
      }
      
      public function set dataDescriptor(param1:IMenuDataDescriptor) : void
      {
         this._dataDescriptor = param1;
         this.menus = [];
      }
      
      [Bindable("collectionChange")]
      public function get dataProvider() : Object
      {
         if(this._rootModel)
         {
            return this._rootModel;
         }
         return null;
      }
      
      public function set dataProvider(param1:Object) : void
      {
         var _loc3_:XMLList = null;
         var _loc4_:Array = null;
         if(this._rootModel)
         {
            this._rootModel.removeEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler);
         }
         if(typeof param1 == "string")
         {
            param1 = new XML(param1);
         }
         else if(param1 is XMLNode)
         {
            param1 = new XML(XMLNode(param1).toString());
         }
         else if(param1 is XMLList)
         {
            param1 = new XMLListCollection(param1 as XMLList);
         }
         if(param1 is XML)
         {
            this._hasRoot = true;
            _loc3_ = new XMLList();
            _loc3_ += param1;
            this._rootModel = new XMLListCollection(_loc3_);
         }
         else if(param1 is ICollectionView)
         {
            this._rootModel = ICollectionView(param1);
            if(this._rootModel.length == 1)
            {
               this._hasRoot = true;
            }
         }
         else if(param1 is Array)
         {
            this._rootModel = new ArrayCollection(param1 as Array);
         }
         else if(param1 is Object)
         {
            this._hasRoot = true;
            (_loc4_ = []).push(param1);
            this._rootModel = new ArrayCollection(_loc4_);
         }
         else
         {
            this._rootModel = new ArrayCollection();
         }
         this._rootModel.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,0,true);
         this.dataProviderChanged = true;
         invalidateProperties();
         var _loc2_:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
         _loc2_.kind = CollectionEventKind.RESET;
         this.collectionChangeHandler(_loc2_);
         dispatchEvent(_loc2_);
      }
      
      public function get hasRoot() : Boolean
      {
         return this._hasRoot;
      }
      
      [Bindable("iconFieldChanged")]
      public function get iconField() : String
      {
         return this._iconField;
      }
      
      public function set iconField(param1:String) : void
      {
         if(this._iconField != param1)
         {
            this.iconFieldChanged = true;
            this._iconField = param1;
            invalidateProperties();
            dispatchEvent(new Event("iconFieldChanged"));
         }
      }
      
      [Bindable("labelFieldChanged")]
      public function get labelField() : String
      {
         return this._labelField;
      }
      
      public function set labelField(param1:String) : void
      {
         if(this._labelField != param1)
         {
            this._labelField = param1;
            dispatchEvent(new Event("labelFieldChanged"));
         }
      }
      
      [Bindable("menuBarItemRendererChanged")]
      public function get menuBarItemRenderer() : IFactory
      {
         return this._menuBarItemRenderer;
      }
      
      public function set menuBarItemRenderer(param1:IFactory) : void
      {
         if(this._menuBarItemRenderer != param1)
         {
            this._menuBarItemRenderer = param1;
            this.menuBarItemRendererChanged = true;
            invalidateProperties();
            dispatchEvent(new Event("menuBarItemRendererChanged"));
         }
      }
      
      protected function get menuBarItemStyleFilters() : Object
      {
         return _menuBarItemStyleFilters;
      }
      
      [Bindable("valueCommit")]
      public function get selectedIndex() : int
      {
         return this.openMenuIndex;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         this.openMenuIndex = param1;
         dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
      
      public function get showRoot() : Boolean
      {
         return this._showRoot;
      }
      
      public function set showRoot(param1:Boolean) : void
      {
         if(this._showRoot != param1)
         {
            this.showRootChanged = true;
            this._showRoot = param1;
            invalidateProperties();
         }
      }
      
      override protected function initializeAccessibility() : void
      {
         if(MenuBar.createAccessibilityImplementation != null)
         {
            MenuBar.createAccessibilityImplementation(this);
         }
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         var _loc1_:Object = parent;
         while(_loc1_)
         {
            if(_loc1_ is ApplicationControlBar)
            {
               this.isInsideACB = true;
               break;
            }
            _loc1_ = _loc1_.parent;
         }
         this.updateBackground();
      }
      
      protected function updateBackground() : void
      {
         var _loc1_:Class = null;
         if(this.isInsideACB)
         {
            setStyle("translucent",true);
         }
         else
         {
            if(this.background)
            {
               removeChild(DisplayObject(this.background));
               this.background = null;
            }
            _loc1_ = getStyle("backgroundSkin");
            if(_loc1_)
            {
               this.background = new _loc1_();
               if(this.background is ISimpleStyleClient)
               {
                  ISimpleStyleClient(this.background).styleName = this;
               }
               addChildAt(DisplayObject(this.background),0);
            }
         }
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IViewCursor = null;
         var _loc3_:ICollectionView = null;
         var _loc4_:* = undefined;
         if(this.showRootChanged)
         {
            if(!this._hasRoot)
            {
               this.showRootChanged = false;
            }
         }
         if(this.dataProviderChanged || this.showRootChanged)
         {
            this.dataProviderChanged = false;
            this.showRootChanged = false;
            if(this._rootModel && !this._showRoot && this._hasRoot)
            {
               if((_loc4_ = this._rootModel.createCursor().current) != null && this._dataDescriptor.isBranch(_loc4_,this._rootModel) && this._dataDescriptor.hasChildren(_loc4_,this._rootModel))
               {
                  _loc3_ = this._dataDescriptor.getChildren(_loc4_,this._rootModel);
               }
            }
            this.removeAll();
            if(this._rootModel)
            {
               if(!_loc3_)
               {
                  _loc3_ = this._rootModel;
               }
               _loc3_.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,EventPriority.DEFAULT_HANDLER,true);
               if(_loc3_.length > 0)
               {
                  _loc2_ = _loc3_.createCursor();
                  _loc1_ = 0;
                  while(!_loc2_.afterLast)
                  {
                     try
                     {
                        this.insertMenuBarItem(_loc1_,_loc2_.current);
                     }
                     catch(e:ItemPendingError)
                     {
                     }
                     _loc2_.moveNext();
                     _loc1_++;
                  }
               }
            }
         }
         if(this.iconFieldChanged || this.menuBarItemRendererChanged)
         {
            this.iconFieldChanged = false;
            this.menuBarItemRendererChanged = false;
            this.removeAll();
            if(this._rootModel)
            {
               if(!_loc3_)
               {
                  _loc3_ = this._rootModel;
               }
               if(_loc3_.length > 0)
               {
                  _loc2_ = _loc3_.createCursor();
                  _loc1_ = 0;
                  while(!_loc2_.afterLast)
                  {
                     try
                     {
                        this.insertMenuBarItem(_loc1_,_loc2_.current);
                     }
                     catch(e:ItemPendingError)
                     {
                     }
                     _loc2_.moveNext();
                     _loc1_++;
                  }
               }
            }
         }
         super.commitProperties();
      }
      
      override protected function measure() : void
      {
         super.measure();
         var _loc1_:int = this.menuBarItems.length;
         measuredWidth = 0;
         measuredHeight = DEFAULT_MEASURED_MIN_HEIGHT;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            measuredWidth += this.menuBarItems[_loc2_].getExplicitOrMeasuredWidth();
            measuredHeight = Math.max(measuredHeight,this.menuBarItems[_loc2_].getExplicitOrMeasuredHeight());
            _loc2_++;
         }
         if(_loc1_ > 0)
         {
            measuredWidth += 2 * MARGIN_WIDTH;
         }
         else
         {
            measuredWidth = DEFAULT_MEASURED_MIN_WIDTH;
         }
         measuredMinWidth = measuredWidth;
         measuredMinHeight = measuredHeight;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc9_:IMenuBarItemRenderer = null;
         super.updateDisplayList(param1,param2);
         var _loc3_:Number = MARGIN_WIDTH;
         var _loc4_:Number = 0;
         var _loc5_:int = this.menuBarItems.length;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = param1 == 0 || param2 == 0;
         var _loc8_:int = 0;
         while(_loc8_ < _loc5_)
         {
            _loc9_ = this.menuBarItems[_loc8_];
            _loc9_.setActualSize(_loc9_.getExplicitOrMeasuredWidth(),param2);
            _loc9_.visible = !_loc7_;
            _loc3_ = _loc9_.x = _loc3_ + _loc4_;
            _loc4_ = _loc9_.width;
            if(!_loc7_ && (_loc9_.getExplicitOrMeasuredHeight() > param2 || _loc3_ + _loc4_ > param1))
            {
               _loc6_ = true;
            }
            _loc8_++;
         }
         if(this.background)
         {
            this.background.setActualSize(param1,param2);
            this.background.visible = !_loc7_;
         }
         scrollRect = !!_loc6_ ? new Rectangle(0,0,param1,param2) : null;
      }
      
      override protected function focusInHandler(param1:FocusEvent) : void
      {
         super.focusInHandler(param1);
      }
      
      override protected function focusOutHandler(param1:FocusEvent) : void
      {
         super.focusOutHandler(param1);
         if(this.supposedToLoseFocus)
         {
            this.getMenuAt(this.openMenuIndex).hide();
         }
         this.supposedToLoseFocus = false;
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc4_:String = null;
         var _loc5_:Menu = null;
         super.styleChanged(param1);
         var _loc3_:int = this.menuBarItems.length;
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this.getMenuAt(_loc2_).styleChanged(param1);
            _loc2_++;
         }
         if(!param1 || param1 == "" || param1 == "backgroundSkin")
         {
            this.updateBackground();
         }
         if(param1 == null || param1 == "styleName" || param1 == "menuStyleName")
         {
            if(_loc4_ = getStyle("menuStyleName"))
            {
               _loc2_ = 0;
               while(_loc2_ < this.menus.length)
               {
                  (_loc5_ = this.menus[_loc2_]).styleName = _loc4_;
                  _loc2_++;
               }
            }
         }
      }
      
      override public function notifyStyleChangeInChildren(param1:String, param2:Boolean) : void
      {
         super.notifyStyleChangeInChildren(param1,param2);
         var _loc3_:int = this.menuBarItems.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            this.getMenuAt(_loc4_).notifyStyleChangeInChildren(param1,param2);
            _loc4_++;
         }
      }
      
      private function collectionChangeHandler(param1:Event) : void
      {
         var _loc2_:CollectionEvent = null;
         if(param1 is CollectionEvent)
         {
            _loc2_ = CollectionEvent(param1);
            if(_loc2_.kind == CollectionEventKind.ADD)
            {
               this.dataProviderChanged = true;
               invalidateProperties();
            }
            else if(_loc2_.kind == CollectionEventKind.REMOVE)
            {
               this.dataProviderChanged = true;
               invalidateProperties();
            }
            else if(_loc2_.kind == CollectionEventKind.REFRESH)
            {
               this.dataProviderChanged = true;
               this.dataProvider = this.dataProvider;
               invalidateProperties();
               invalidateSize();
            }
            else if(_loc2_.kind == CollectionEventKind.RESET)
            {
               this.dataProviderChanged = true;
               invalidateProperties();
               invalidateSize();
            }
            else if(_loc2_.kind == CollectionEventKind.UPDATE)
            {
               if(this.openMenuIndex == -1)
               {
                  this.dataProviderChanged = true;
                  invalidateProperties();
               }
            }
         }
         invalidateDisplayList();
      }
      
      private function eventHandler(param1:Event) : void
      {
         var _loc2_:String = null;
         if(param1 is MenuEvent)
         {
            _loc2_ = param1.type;
            if(param1.type == MenuEvent.MENU_HIDE && MenuEvent(param1).menu == this.menus[this.openMenuIndex])
            {
               this.menuBarItems[this.openMenuIndex].menuBarItemState = "itemUpSkin";
               this.openMenuIndex = -1;
               dispatchEvent(param1 as MenuEvent);
            }
            else
            {
               dispatchEvent(param1);
            }
         }
      }
      
      private function addMenuAt(param1:int, param2:Object, param3:Object = null) : void
      {
         var _loc4_:Menu = null;
         var _loc5_:Object = null;
         if(!this.dataProvider)
         {
            this.dataProvider = {};
         }
         var _loc6_:Object = param2;
         this.insertMenuBarItem(param1,_loc5_);
      }
      
      public function itemToLabel(param1:Object) : String
      {
         if(param1 == null)
         {
            return " ";
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
         else if(param1 is String)
         {
            return String(param1);
         }
         try
         {
            return param1.toString();
         }
         catch(e:Error)
         {
            return " ";
         }
      }
      
      public function itemToIcon(param1:Object) : Class
      {
         var _loc2_:Class = null;
         var _loc3_:* = undefined;
         if(param1 == null)
         {
            return null;
         }
         if(param1 is XML)
         {
            try
            {
               if(param1[this.iconField].length() != 0)
               {
                  _loc3_ = String(param1[this.iconField]);
                  if(_loc3_ != null)
                  {
                     _loc2_ = Class(systemManager.getDefinitionByName(_loc3_));
                     if(_loc2_)
                     {
                        return _loc2_;
                     }
                     return document[_loc3_];
                  }
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
               if(param1[this.iconField] != null)
               {
                  if(param1[this.iconField] is Class)
                  {
                     return param1[this.iconField];
                  }
                  if(param1[this.iconField] is String)
                  {
                     _loc2_ = Class(systemManager.getDefinitionByName(param1[this.iconField]));
                     if(_loc2_)
                     {
                        return _loc2_;
                     }
                     return document[param1[this.iconField]];
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
         return null;
      }
      
      private function insertMenuBarItem(param1:int, param2:Object) : void
      {
         if(this.dataProviderChanged)
         {
            this.commitProperties();
            return;
         }
         var _loc3_:IMenuBarItemRenderer = this.menuBarItemRenderer.newInstance();
         _loc3_.styleName = new StyleProxy(this,this.menuBarItemStyleFilters);
         _loc3_.visible = false;
         _loc3_.enabled = enabled && this._dataDescriptor.isEnabled(param2) != false;
         _loc3_.data = param2;
         _loc3_.menuBar = this;
         _loc3_.menuBarItemIndex = param1;
         addChild(DisplayObject(_loc3_));
         this.menuBarItems.splice(param1,0,_loc3_);
         invalidateSize();
         invalidateDisplayList();
         _loc3_.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         _loc3_.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         _loc3_.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
         _loc3_.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
      }
      
      public function getMenuAt(param1:int) : Menu
      {
         var _loc5_:Object = null;
         if(this.dataProviderChanged)
         {
            this.commitProperties();
         }
         var _loc2_:IMenuBarItemRenderer = this.menuBarItems[param1];
         var _loc3_:Object = _loc2_.data;
         var _loc4_:Menu;
         if((_loc4_ = this.menus[param1]) == null)
         {
            (_loc4_ = new Menu()).showRoot = false;
            if(_loc5_ = getStyle("menuStyleName"))
            {
               _loc4_.styleName = _loc5_;
            }
            _loc4_.sourceMenuBar = this;
            _loc4_.owner = this;
            _loc4_.addEventListener("menuHide",this.eventHandler);
            _loc4_.addEventListener("itemRollOver",this.eventHandler);
            _loc4_.addEventListener("itemRollOut",this.eventHandler);
            _loc4_.addEventListener("menuShow",this.eventHandler);
            _loc4_.addEventListener("itemClick",this.eventHandler);
            _loc4_.addEventListener("change",this.eventHandler);
            _loc4_.iconField = this._iconField;
            _loc4_.labelField = this._labelField;
            _loc4_.labelFunction = this.labelFunction;
            _loc4_.dataDescriptor = this._dataDescriptor;
            _loc4_.invalidateSize();
            this.menus[param1] = _loc4_;
            _loc4_.sourceMenuBarItem = _loc2_;
            Menu.popUpMenu(_loc4_,this,_loc3_);
         }
         return _loc4_;
      }
      
      private function showMenu(param1:Number) : void
      {
         this.selectedIndex = param1;
         var _loc2_:IMenuBarItemRenderer = this.menuBarItems[param1];
         var _loc3_:Menu = this.getMenuAt(param1);
         var _loc4_:ISystemManager;
         var _loc5_:Rectangle = (_loc4_ = systemManager.topLevelSystemManager).getVisibleApplicationRect(null,true);
         if(_loc3_.parentDisplayObject && (!_loc3_.parent || !_loc3_.parent.contains(_loc3_.parentDisplayObject)))
         {
            PopUpManager.addPopUp(_loc3_,this,false);
            _loc3_.addEventListener(MenuEvent.MENU_HIDE,menuHideHandler,false,EventPriority.DEFAULT_HANDLER);
         }
         if(_loc3_.parentDisplayObject && (!_loc3_.parent || !_loc3_.parent.contains(_loc3_.parentDisplayObject)))
         {
            PopUpManager.addPopUp(_loc3_,this,false);
            _loc3_.addEventListener(MenuEvent.MENU_HIDE,menuHideHandler,false,EventPriority.DEFAULT_HANDLER);
         }
         UIComponentGlobals.layoutManager.validateClient(_loc3_,true);
         var _loc6_:Point = new Point(0,0);
         _loc6_ = DisplayObject(_loc2_).localToGlobal(_loc6_);
         if(layoutDirection == LayoutDirection.RTL)
         {
            _loc6_.x -= _loc3_.getExplicitOrMeasuredWidth();
         }
         if(_loc6_.y + _loc2_.height + 1 + _loc3_.getExplicitOrMeasuredHeight() > _loc5_.height + _loc5_.y)
         {
            _loc6_.y -= _loc3_.getExplicitOrMeasuredHeight();
         }
         else
         {
            _loc6_.y += _loc2_.height + 1;
         }
         if(_loc6_.x + _loc3_.getExplicitOrMeasuredWidth() > _loc5_.width + _loc5_.x)
         {
            _loc6_.x = _loc5_.x + _loc5_.width - _loc3_.getExplicitOrMeasuredWidth();
         }
         _loc6_.x = Math.max(_loc5_.x,_loc6_.x);
         _loc6_ = _loc4_.getSandboxRoot().globalToLocal(_loc6_);
         if(this.isInsideACB)
         {
            _loc6_.y += 2;
         }
         _loc3_.show(_loc6_.x,_loc6_.y);
      }
      
      private function removeMenuBarItemAt(param1:int) : void
      {
         if(this.dataProviderChanged)
         {
            this.commitProperties();
         }
         var _loc2_:IMenuBarItemRenderer = this.menuBarItems[param1];
         if(_loc2_)
         {
            removeChild(DisplayObject(_loc2_));
            this.menuBarItems.splice(param1,1);
            invalidateSize();
            invalidateDisplayList();
         }
      }
      
      private function removeAll() : void
      {
         var _loc1_:IMenuBarItemRenderer = null;
         if(this.dataProviderChanged)
         {
            this.commitProperties();
         }
         while(this.menuBarItems.length > 0)
         {
            _loc1_ = this.menuBarItems[0];
            removeChild(DisplayObject(_loc1_));
            this.menuBarItems.splice(0,1);
         }
         this.menus = [];
         invalidateSize();
         invalidateDisplayList();
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         var _loc6_:MenuEvent = null;
         var _loc7_:Number = NaN;
         var _loc8_:ICollectionView = null;
         var _loc9_:IMenuBarItemRenderer = null;
         var _loc10_:Menu = null;
         var _loc2_:IMenuBarItemRenderer = IMenuBarItemRenderer(param1.target);
         var _loc3_:int = _loc2_.menuBarItemIndex;
         var _loc4_:Boolean = false;
         var _loc5_:Menu = this.getMenuAt(_loc3_);
         if(_loc2_.enabled)
         {
            if(this.openMenuIndex != -1 || this.inKeyDown)
            {
               if((_loc7_ = this.openMenuIndex) != _loc3_)
               {
                  this.isDown = false;
                  if(_loc7_ != -1)
                  {
                     (_loc9_ = this.menuBarItems[_loc7_]).dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
                     _loc9_.menuBarItemState = "itemUpSkin";
                     (_loc6_ = new MenuEvent(MenuEvent.ITEM_ROLL_OUT)).menuBar = this;
                     _loc6_.index = _loc7_;
                     _loc6_.label = this.itemToLabel(_loc9_.data);
                     _loc6_.item = _loc9_.data;
                     _loc6_.itemRenderer = _loc9_;
                     dispatchEvent(_loc6_);
                  }
                  _loc2_.menuBarItemState = "itemDownSkin";
                  _loc8_ = ICollectionView(_loc5_.dataProvider);
                  if(_loc5_.dataDescriptor.isBranch(_loc2_.data,_loc2_.data) && _loc5_.dataDescriptor.hasChildren(_loc2_.data,_loc2_.data))
                  {
                     this.showMenu(_loc3_);
                  }
                  else if(_loc5_)
                  {
                     this.selectedIndex = _loc3_;
                     (_loc6_ = new MenuEvent(MenuEvent.MENU_SHOW)).menuBar = this;
                     _loc6_.menu = _loc5_;
                     dispatchEvent(_loc6_);
                     _loc2_.menuBarItemState = "itemOverSkin";
                  }
                  this.isDown = true;
                  if(_loc5_.dataDescriptor.getType(_loc2_.data) != "separator")
                  {
                     _loc4_ = true;
                     (_loc6_ = new MenuEvent(MenuEvent.CHANGE)).index = _loc3_;
                     _loc6_.menuBar = this;
                     _loc6_.label = this.itemToLabel(_loc2_.data);
                     _loc6_.item = _loc2_.data;
                     _loc6_.itemRenderer = _loc2_;
                     dispatchEvent(_loc6_);
                  }
               }
               else
               {
                  (_loc10_ = this.getMenuAt(_loc3_)).deleteDependentSubMenus();
                  _loc10_.setFocus();
               }
            }
            else
            {
               _loc2_.menuBarItemState = "itemOverSkin";
               this.isDown = false;
               if(_loc5_.dataDescriptor.getType(_loc2_.data) != "separator")
               {
                  _loc4_ = true;
               }
            }
            this.inKeyDown = false;
            if(_loc4_)
            {
               (_loc6_ = new MenuEvent(MenuEvent.ITEM_ROLL_OVER)).index = _loc3_;
               _loc6_.menuBar = this;
               _loc6_.label = this.itemToLabel(_loc2_.data);
               _loc6_.item = _loc2_.data;
               _loc6_.itemRenderer = _loc2_;
               dispatchEvent(_loc6_);
            }
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc5_:ICollectionView = null;
         var _loc6_:MenuEvent = null;
         var _loc7_:MenuEvent = null;
         var _loc2_:IMenuBarItemRenderer = IMenuBarItemRenderer(param1.target);
         var _loc3_:int = _loc2_.menuBarItemIndex;
         var _loc4_:Menu = this.getMenuAt(_loc3_);
         if(_loc2_.enabled)
         {
            _loc2_.menuBarItemState = "itemDownSkin";
            if(!this.isDown)
            {
               _loc4_.supposedToLoseFocus = true;
               _loc5_ = ICollectionView(_loc4_.dataProvider);
               if(_loc4_.dataDescriptor.isBranch(_loc2_.data,_loc2_.data) && _loc4_.dataDescriptor.hasChildren(_loc2_.data,_loc2_.data))
               {
                  this.showMenu(_loc3_);
               }
               else if(_loc4_)
               {
                  this.selectedIndex = _loc3_;
                  (_loc6_ = new MenuEvent(MenuEvent.MENU_SHOW)).menuBar = this;
                  _loc6_.menu = _loc4_;
                  dispatchEvent(_loc6_);
               }
               this.isDown = true;
            }
            else
            {
               this.isDown = false;
            }
            if(_loc4_.dataDescriptor.getType(_loc2_.data) != "separator")
            {
               (_loc7_ = new MenuEvent(MenuEvent.CHANGE)).index = _loc3_;
               _loc7_.menuBar = this;
               _loc7_.label = this.itemToLabel(_loc2_.data);
               _loc7_.item = _loc2_.data;
               _loc7_.itemRenderer = _loc2_;
               dispatchEvent(_loc7_);
            }
         }
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         var _loc2_:IMenuBarItemRenderer = IMenuBarItemRenderer(param1.target);
         var _loc3_:int = _loc2_.menuBarItemIndex;
         if(_loc2_.enabled && !this.isDown)
         {
            this.getMenuAt(_loc3_).hideAllMenus();
            _loc2_.menuBarItemState = "itemOverSkin";
         }
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         var _loc5_:MenuEvent = null;
         var _loc2_:IMenuBarItemRenderer = IMenuBarItemRenderer(param1.target);
         var _loc3_:int = _loc2_.menuBarItemIndex;
         var _loc4_:Menu = this.getMenuAt(_loc3_);
         if(_loc2_.enabled && this.openMenuIndex != _loc3_)
         {
            this.menuBarItems[_loc3_].menuBarItemState = "itemUpSkin";
         }
         if(_loc2_.data && _loc4_.dataDescriptor.getType(_loc2_.data) != "separator")
         {
            (_loc5_ = new MenuEvent(MenuEvent.ITEM_ROLL_OUT)).index = _loc3_;
            _loc5_.menuBar = this;
            _loc5_.label = this.itemToLabel(_loc2_.data);
            _loc5_.item = _loc2_.data;
            _loc5_.itemRenderer = _loc2_;
            dispatchEvent(_loc5_);
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:uint = 0;
         var _loc7_:Menu = null;
         var _loc8_:ICollectionView = null;
         var _loc9_:IMenuBarItemRenderer = null;
         var _loc2_:int = this.menuBarItems.length;
         if(param1.keyCode == Keyboard.RIGHT || param1.keyCode == Keyboard.LEFT)
         {
            this.inKeyDown = true;
            _loc3_ = this.openMenuIndex;
            _loc4_ = false;
            _loc5_ = 0;
            _loc6_ = mapKeycodeForLayoutDirection(param1);
            while(!_loc4_ && _loc5_ < _loc2_)
            {
               _loc5_++;
               _loc3_ = _loc6_ == Keyboard.RIGHT ? int(_loc3_ + 1) : int(_loc3_ - 1);
               if(_loc3_ >= _loc2_)
               {
                  _loc3_ = 0;
               }
               else if(_loc3_ < 0)
               {
                  _loc3_ = _loc2_ - 1;
               }
               if(this.menuBarItems[_loc3_].enabled)
               {
                  _loc4_ = true;
               }
            }
            if(_loc5_ <= _loc2_ && _loc4_)
            {
               this.menuBarItems[_loc3_].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
            }
            param1.stopPropagation();
         }
         if(_loc6_ == Keyboard.DOWN)
         {
            if(this.openMenuIndex != -1)
            {
               (_loc7_ = this.getMenuAt(this.openMenuIndex)).selectedIndex = 0;
               this.supposedToLoseFocus = true;
               _loc8_ = ICollectionView(_loc7_.dataProvider);
               _loc9_ = _loc7_.sourceMenuBarItem;
               if(_loc7_.dataDescriptor.isBranch(_loc9_.data,_loc9_.data) && _loc7_.dataDescriptor.hasChildren(_loc9_.data,_loc9_.data))
               {
                  _loc7_.setFocus();
               }
            }
            param1.stopPropagation();
         }
         if(_loc6_ == Keyboard.ENTER || _loc6_ == Keyboard.ESCAPE)
         {
            if(this.openMenuIndex != -1)
            {
               this.getMenuAt(this.openMenuIndex).hide();
            }
            param1.stopPropagation();
         }
      }
   }
}
