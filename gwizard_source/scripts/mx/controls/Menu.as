package mx.controls
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.ui.Keyboard;
   import flash.utils.clearInterval;
   import flash.utils.setTimeout;
   import flash.xml.XMLNode;
   import mx.collections.ArrayCollection;
   import mx.collections.CursorBookmark;
   import mx.collections.ICollectionView;
   import mx.collections.XMLListCollection;
   import mx.controls.listClasses.BaseListData;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.controls.menuClasses.IMenuBarItemRenderer;
   import mx.controls.menuClasses.IMenuDataDescriptor;
   import mx.controls.menuClasses.IMenuItemRenderer;
   import mx.controls.menuClasses.MenuItemRenderer;
   import mx.controls.menuClasses.MenuListData;
   import mx.controls.treeClasses.DefaultDataDescriptor;
   import mx.core.ClassFactory;
   import mx.core.EdgeMetrics;
   import mx.core.EventPriority;
   import mx.core.FlexGlobals;
   import mx.core.IFlexDisplayObject;
   import mx.core.LayoutDirection;
   import mx.core.ScrollPolicy;
   import mx.core.UIComponent;
   import mx.core.UIComponentGlobals;
   import mx.core.mx_internal;
   import mx.effects.Tween;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.FlexEvent;
   import mx.events.ListEvent;
   import mx.events.MenuEvent;
   import mx.events.SandboxMouseEvent;
   import mx.managers.IActiveWindowManager;
   import mx.managers.IFocusManagerContainer;
   import mx.managers.ISystemManager;
   import mx.managers.PopUpManager;
   
   use namespace mx_internal;
   
   public class Menu extends List implements IFocusManagerContainer
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      mx_internal static var createAccessibilityImplementation:Function;
       
      
      private var hiddenItem:IListItemRenderer;
      
      private var maxMeasuredIconWidth:Number = 0;
      
      private var maxMeasuredTypeIconWidth:Number = 0;
      
      private var maxMeasuredBranchIconWidth:Number = 0;
      
      private var useTwoColumns:Boolean = false;
      
      mx_internal var sourceMenuBar:MenuBar;
      
      mx_internal var sourceMenuBarItem:IMenuBarItemRenderer;
      
      mx_internal var parentDisplayObject:DisplayObject;
      
      private var isDirectionLeft:Boolean = false;
      
      private var anchorRow:IListItemRenderer;
      
      private var subMenu:Menu;
      
      mx_internal var popupTween:Tween;
      
      mx_internal var supposedToLoseFocus:Boolean = false;
      
      mx_internal var openSubMenuTimer:int = 0;
      
      mx_internal var closeTimer:int = 0;
      
      mx_internal var _rootModel:ICollectionView;
      
      mx_internal var _listDataProvider:ICollectionView;
      
      mx_internal var _parentMenu:Menu;
      
      mx_internal var _dataDescriptor:IMenuDataDescriptor;
      
      mx_internal var dataProviderChanged:Boolean = false;
      
      mx_internal var _showRoot:Boolean = true;
      
      mx_internal var showRootChanged:Boolean = false;
      
      mx_internal var _hasRoot:Boolean = false;
      
      public function Menu()
      {
         this._dataDescriptor = new DefaultDataDescriptor();
         super();
         itemRenderer = new ClassFactory(MenuItemRenderer);
         setRowHeight(19);
         iconField = "icon";
         visible = false;
      }
      
      public static function createMenu(param1:DisplayObjectContainer, param2:Object, param3:Boolean = true) : Menu
      {
         var _loc4_:Menu = null;
         (_loc4_ = new Menu()).tabEnabled = false;
         _loc4_.tabFocusEnabled = false;
         _loc4_.owner = DisplayObjectContainer(FlexGlobals.topLevelApplication);
         _loc4_.showRoot = param3;
         popUpMenu(_loc4_,param1,param2);
         return _loc4_;
      }
      
      public static function popUpMenu(param1:Menu, param2:DisplayObjectContainer, param3:Object) : void
      {
         param1.parentDisplayObject = !!param2 ? param2 : DisplayObject(FlexGlobals.topLevelApplication);
         if(!param3)
         {
            param3 = new XML();
         }
         param1.supposedToLoseFocus = true;
         param1.dataProvider = param3;
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
      
      public function get parentMenu() : Menu
      {
         return this._parentMenu;
      }
      
      public function set parentMenu(param1:Menu) : void
      {
         this._parentMenu = param1;
         param1.addEventListener(FlexEvent.HIDE,this.parentHideHandler,false,0,true);
         param1.addEventListener("rowHeightChanged",this.parentRowHeightHandler,false,0,true);
         param1.addEventListener("iconFieldChanged",this.parentIconFieldHandler,false,0,true);
         param1.addEventListener("iconFunctionChanged",this.parentIconFunctionHandler,false,0,true);
         param1.addEventListener("labelFieldChanged",this.parentLabelFieldHandler,false,0,true);
         param1.addEventListener("labelFunctionChanged",this.parentLabelFunctionHandler,false,0,true);
         param1.addEventListener("itemRendererChanged",this.parentItemRendererHandler,false,0,true);
      }
      
      public function get dataDescriptor() : IMenuDataDescriptor
      {
         return IMenuDataDescriptor(this._dataDescriptor);
      }
      
      public function set dataDescriptor(param1:IMenuDataDescriptor) : void
      {
         this._dataDescriptor = param1;
      }
      
      override public function set dataProvider(param1:Object) : void
      {
         var _loc2_:XMLList = null;
         var _loc3_:Array = null;
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
            _loc2_ = new XMLList();
            _loc2_ += param1;
            this._rootModel = new XMLListCollection(_loc2_);
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
            _loc3_ = [];
            _loc3_.push(param1);
            this._rootModel = new ArrayCollection(_loc3_);
         }
         else
         {
            this._rootModel = new ArrayCollection();
         }
         this.dataProviderChanged = true;
         invalidateProperties();
      }
      
      override public function get dataProvider() : Object
      {
         var _loc1_:* = super.dataProvider;
         if(_loc1_ == null)
         {
            if(this._rootModel != null)
            {
               return this._rootModel;
            }
            return null;
         }
         return _loc1_;
      }
      
      public function get showRoot() : Boolean
      {
         return this._showRoot;
      }
      
      public function set showRoot(param1:Boolean) : void
      {
         if(this._showRoot != param1)
         {
            this._showRoot = param1;
            this.showRootChanged = true;
            invalidateProperties();
         }
      }
      
      public function get hasRoot() : Boolean
      {
         return this._hasRoot;
      }
      
      public function get defaultButton() : IFlexDisplayObject
      {
         return null;
      }
      
      public function set defaultButton(param1:IFlexDisplayObject) : void
      {
      }
      
      private function parentHideHandler(param1:FlexEvent) : void
      {
         visible = false;
      }
      
      private function parentRowHeightHandler(param1:Event) : void
      {
         rowHeight = this.parentMenu.rowHeight;
      }
      
      private function parentIconFieldHandler(param1:Event) : void
      {
         iconField = this.parentMenu.iconField;
      }
      
      private function parentIconFunctionHandler(param1:Event) : void
      {
         iconFunction = this.parentMenu.iconFunction;
      }
      
      private function parentLabelFieldHandler(param1:Event) : void
      {
         labelField = this.parentMenu.labelField;
      }
      
      private function parentLabelFunctionHandler(param1:Event) : void
      {
         labelFunction = this.parentMenu.labelFunction;
      }
      
      private function parentItemRendererHandler(param1:Event) : void
      {
         itemRenderer = this.parentMenu.itemRenderer;
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
      
      override protected function initializeAccessibility() : void
      {
         if(mx_internal::createAccessibilityImplementation != null)
         {
            createAccessibilityImplementation(this);
         }
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:ICollectionView = null;
         var _loc2_:* = undefined;
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
               _loc2_ = this._rootModel.createCursor().current;
               if(_loc2_ != null && this._dataDescriptor.isBranch(_loc2_,this._rootModel) && this._dataDescriptor.hasChildren(_loc2_,this._rootModel))
               {
                  _loc1_ = this._dataDescriptor.getChildren(_loc2_,this._rootModel);
               }
            }
            if(this._listDataProvider)
            {
               this._listDataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false);
            }
            if(this._rootModel)
            {
               if(!_loc1_)
               {
                  _loc1_ = this._rootModel;
               }
               this._listDataProvider = _loc1_;
               super.dataProvider = _loc1_;
               this._listDataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,EventPriority.DEFAULT_HANDLER,true);
            }
            else
            {
               this._listDataProvider = null;
               super.dataProvider = null;
            }
         }
         super.commitProperties();
      }
      
      override protected function measure() : void
      {
         var _loc1_:EdgeMetrics = null;
         var _loc2_:int = 0;
         super.measure();
         if(!this.dataProvider || this.dataProvider.length == 0)
         {
            measuredWidth = 0;
            measuredHeight = 0;
         }
         else
         {
            _loc1_ = viewMetrics;
            measuredMinWidth = measuredWidth = this.measureWidthOfItems(0,this.dataProvider.length);
            if(variableRowHeight)
            {
               _loc2_ = measureHeightOfItems(0,this.dataProvider.length);
            }
            else
            {
               _loc2_ = this.dataProvider.length * rowHeight;
            }
            measuredMinHeight = measuredHeight = _loc2_ + _loc1_.top + _loc1_.bottom;
         }
      }
      
      override public function measureWidthOfItems(param1:int = -1, param2:int = 0) : Number
      {
         var _loc6_:CursorBookmark = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:Object = null;
         var _loc11_:MenuListData = null;
         var _loc12_:IListItemRenderer = null;
         var _loc13_:IMenuItemRenderer = null;
         var _loc3_:Number = 0;
         var _loc4_:Number = getStyle("leftIconGap");
         var _loc5_:Number = getStyle("rightIconGap");
         this.maxMeasuredIconWidth = 0;
         this.maxMeasuredTypeIconWidth = 0;
         this.maxMeasuredBranchIconWidth = 0;
         this.useTwoColumns = false;
         if(collection && collection.length)
         {
            _loc6_ = iterator.bookmark;
            _loc7_ = param2;
            _loc8_ = 0;
            while(_loc8_ < 2)
            {
               iterator.seek(CursorBookmark.FIRST,param1);
               param2 = _loc7_;
               _loc9_ = false;
               while(param2)
               {
                  _loc10_ = iterator.current;
                  (_loc12_ = this.hiddenItem = getMeasuringRenderer(_loc10_)).explicitWidth = NaN;
                  setupRendererFromData(_loc12_,_loc10_);
                  _loc3_ = Math.max(_loc12_.getExplicitOrMeasuredWidth(),_loc3_);
                  if(_loc12_ is IMenuItemRenderer)
                  {
                     if((_loc13_ = IMenuItemRenderer(_loc12_)).measuredIconWidth > this.maxMeasuredIconWidth)
                     {
                        this.maxMeasuredIconWidth = _loc13_.measuredIconWidth;
                        _loc9_ = true;
                     }
                     if(_loc13_.measuredTypeIconWidth > this.maxMeasuredTypeIconWidth)
                     {
                        this.maxMeasuredTypeIconWidth = _loc13_.measuredTypeIconWidth;
                        _loc9_ = true;
                     }
                     if(_loc13_.measuredBranchIconWidth > this.maxMeasuredBranchIconWidth)
                     {
                        this.maxMeasuredBranchIconWidth = _loc13_.measuredBranchIconWidth;
                        _loc9_ = true;
                     }
                     if(_loc13_.measuredIconWidth > 0 && _loc13_.measuredTypeIconWidth)
                     {
                        this.useTwoColumns = true;
                        _loc9_ = true;
                     }
                  }
                  param2--;
                  if(!iterator.moveNext())
                  {
                     break;
                  }
               }
               if(_loc8_ == 0)
               {
                  if(!(_loc9_ && (this.maxMeasuredIconWidth + this.maxMeasuredTypeIconWidth > _loc4_ || this.maxMeasuredBranchIconWidth > _loc5_)))
                  {
                     break;
                  }
               }
               _loc8_++;
            }
            iterator.seek(_loc6_,0);
         }
         if(!_loc3_)
         {
            _loc3_ = 200;
         }
         return Number(_loc3_ + (getStyle("paddingLeft") + getStyle("paddingRight")));
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         border.move(0,0);
         border.visible = this.dataProvider != null && this.dataProvider.length > 0;
         if(this.hiddenItem)
         {
            this.hiddenItem.setActualSize(param1,this.hiddenItem.getExplicitOrMeasuredHeight());
         }
      }
      
      override public function styleChanged(param1:String) : void
      {
         super.styleChanged(param1);
         this.deleteDependentSubMenus();
      }
      
      override protected function drawItem(param1:IListItemRenderer, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false) : void
      {
         if(!getStyle("useRollOver"))
         {
            super.drawItem(param1,param2,false,false,param5);
         }
         else
         {
            super.drawItem(param1,param2,param3,param4,param5);
         }
      }
      
      override protected function configureScrollBars() : void
      {
      }
      
      override mx_internal function clearHighlight(param1:IListItemRenderer) : void
      {
         var _loc4_:MenuEvent = null;
         var _loc2_:String = itemToUID(param1.data);
         this.drawItem(visibleData[_loc2_],isItemSelected(param1.data),false,_loc2_ == caretUID);
         var _loc3_:Point = itemRendererToIndices(param1);
         if(_loc3_)
         {
            (_loc4_ = new MenuEvent(MenuEvent.ITEM_ROLL_OUT)).menu = this;
            _loc4_.index = this.getRowIndex(param1);
            _loc4_.menuBar = this.sourceMenuBar;
            _loc4_.label = itemToLabel(param1.data);
            _loc4_.item = param1.data;
            _loc4_.itemRenderer = param1;
            this.getRootMenu().dispatchEvent(_loc4_);
         }
      }
      
      override protected function mouseEventToItemRenderer(param1:MouseEvent) : IListItemRenderer
      {
         var _loc2_:IListItemRenderer = super.mouseEventToItemRenderer(param1);
         if(_loc2_ && _loc2_.data && this._dataDescriptor.getType(_loc2_.data) == "separator")
         {
            return null;
         }
         return _loc2_;
      }
      
      override public function setFocus() : void
      {
         super.setFocus();
      }
      
      override protected function focusOutHandler(param1:FocusEvent) : void
      {
         super.focusOutHandler(param1);
         if(!this.supposedToLoseFocus)
         {
            this.hideAllMenus();
         }
         this.supposedToLoseFocus = false;
      }
      
      override public function dispatchEvent(param1:Event) : Boolean
      {
         var _loc2_:MenuEvent = null;
         if(!(param1 is MenuEvent) && param1 is ListEvent && (param1.type == ListEvent.ITEM_ROLL_OUT || param1.type == ListEvent.ITEM_ROLL_OVER || param1.type == ListEvent.CHANGE))
         {
            param1.stopImmediatePropagation();
         }
         if(!(param1 is MenuEvent) && param1 is ListEvent && param1.type == ListEvent.ITEM_CLICK)
         {
            _loc2_ = new MenuEvent(param1.type,param1.bubbles,param1.cancelable);
            _loc2_.item = ListEvent(param1).itemRenderer.data;
            _loc2_.label = itemToLabel(ListEvent(param1).itemRenderer);
            return super.dispatchEvent(_loc2_);
         }
         return super.dispatchEvent(param1);
      }
      
      protected function setMenuItemToggled(param1:Object, param2:Boolean) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:IListItemRenderer = null;
         var _loc6_:Object = null;
         itemsSizeChanged = true;
         invalidateDisplayList();
         if(this._dataDescriptor.getType(param1) == "radio")
         {
            _loc3_ = this._dataDescriptor.getGroupName(param1);
            _loc4_ = 0;
            while(_loc4_ < listItems.length)
            {
               _loc6_ = (_loc5_ = listItems[_loc4_][0]).data;
               if(this._dataDescriptor.getType(_loc6_) == "radio" && this._dataDescriptor.getGroupName(_loc6_) == _loc3_)
               {
                  this._dataDescriptor.setToggled(_loc6_,_loc6_ == param1);
               }
               _loc4_++;
            }
         }
         if(param2 != this._dataDescriptor.isToggled(param1))
         {
            this._dataDescriptor.setToggled(param1,param2);
         }
      }
      
      override protected function makeListData(param1:Object, param2:String, param3:int) : BaseListData
      {
         var _loc4_:MenuListData;
         (_loc4_ = new MenuListData(itemToLabel(param1),itemToIcon(param1),labelField,param2,this,param3)).maxMeasuredIconWidth = this.maxMeasuredIconWidth;
         _loc4_.maxMeasuredTypeIconWidth = this.maxMeasuredTypeIconWidth;
         _loc4_.maxMeasuredBranchIconWidth = this.maxMeasuredBranchIconWidth;
         _loc4_.useTwoColumns = this.useTwoColumns;
         return _loc4_;
      }
      
      public function show(param1:Object = null, param2:Object = null) : void
      {
         var _loc8_:Rectangle = null;
         var _loc9_:Point = null;
         var _loc10_:Number = NaN;
         if(collection && collection.length == 0)
         {
            return;
         }
         if(this.parentMenu && !this.parentMenu.visible)
         {
            return;
         }
         if(visible)
         {
            return;
         }
         if(this.parentDisplayObject && (!parent || !parent.contains(this.parentDisplayObject)))
         {
            PopUpManager.addPopUp(this,this.parentDisplayObject,false);
            addEventListener(MenuEvent.MENU_HIDE,menuHideHandler,false,EventPriority.DEFAULT_HANDLER);
         }
         var _loc3_:MenuEvent = new MenuEvent(MenuEvent.MENU_SHOW);
         _loc3_.menu = this;
         _loc3_.menuBar = this.sourceMenuBar;
         this.getRootMenu().dispatchEvent(_loc3_);
         var _loc4_:IActiveWindowManager;
         (_loc4_ = IActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"))).activate(this);
         if(param1 !== null && !isNaN(Number(param1)))
         {
            x = Number(param1);
         }
         if(param2 !== null && !isNaN(Number(param2)))
         {
            y = Number(param2);
         }
         var _loc5_:ISystemManager;
         var _loc6_:DisplayObject = (_loc5_ = systemManager.topLevelSystemManager).getSandboxRoot();
         if(this != this.getRootMenu())
         {
            _loc9_ = new Point(x,y);
            _loc9_ = _loc6_.localToGlobal(_loc9_);
            _loc8_ = _loc5_.getVisibleApplicationRect(null,true);
            if((_loc10_ = _loc9_.x + width - _loc8_.right) > 0)
            {
               x = Math.max(x - _loc10_,0);
            }
            if((_loc10_ = _loc9_.y + height - _loc8_.bottom) > 0)
            {
               y = Math.max(y - _loc10_,0);
            }
         }
         UIComponentGlobals.layoutManager.validateClient(this,true);
         setActualSize(getExplicitOrMeasuredWidth(),getExplicitOrMeasuredHeight());
         cacheAsBitmap = true;
         var _loc7_:Number;
         if((_loc7_ = getStyle("openDuration")) != 0)
         {
            scrollRect = new Rectangle(0,0,unscaledWidth,0);
            visible = true;
            UIComponentGlobals.layoutManager.validateNow();
            UIComponent.suspendBackgroundProcessing();
            this.popupTween = new Tween(this,[0,0],[unscaledWidth,unscaledHeight],_loc7_);
         }
         else
         {
            UIComponentGlobals.layoutManager.validateNow();
            visible = true;
         }
         focusManager.setFocus(this);
         this.supposedToLoseFocus = true;
         _loc6_.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownOutsideHandler,false,0,true);
         addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,this.mouseDownOutsideHandler,false,0,true);
      }
      
      mx_internal function onTweenUpdate(param1:Object) : void
      {
         scrollRect = new Rectangle(0,0,param1[0],param1[1]);
      }
      
      mx_internal function onTweenEnd(param1:Object) : void
      {
         UIComponent.resumeBackgroundProcessing();
         scrollRect = null;
         this.popupTween = null;
      }
      
      public function hide() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:MenuEvent = null;
         if(visible)
         {
            if(this.popupTween)
            {
               this.popupTween.endTween();
            }
            clearSelected();
            if(this.anchorRow)
            {
               this.drawItem(this.anchorRow,false,false);
               this.anchorRow = null;
            }
            visible = false;
            _loc1_ = systemManager.getSandboxRoot();
            _loc1_.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownOutsideHandler);
            removeEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,this.mouseDownOutsideHandler);
            _loc2_ = new MenuEvent(MenuEvent.MENU_HIDE);
            _loc2_.menu = this;
            _loc2_.menuBar = this.sourceMenuBar;
            this.getRootMenu().dispatchEvent(_loc2_);
         }
      }
      
      override protected function collectionChangeHandler(param1:Event) : void
      {
         var _loc2_:CollectionEvent = null;
         if(param1 is CollectionEvent)
         {
            _loc2_ = CollectionEvent(param1);
            if(_loc2_.kind == CollectionEventKind.ADD)
            {
               super.collectionChangeHandler(param1);
               this.dataProviderChanged = true;
               invalidateProperties();
               invalidateSize();
               UIComponentGlobals.layoutManager.validateClient(this);
               setActualSize(getExplicitOrMeasuredWidth(),getExplicitOrMeasuredHeight());
            }
            else if(_loc2_.kind == CollectionEventKind.REMOVE)
            {
               super.collectionChangeHandler(param1);
               this.dataProviderChanged = true;
               invalidateProperties();
               invalidateSize();
               UIComponentGlobals.layoutManager.validateClient(this);
               setActualSize(getExplicitOrMeasuredWidth(),getExplicitOrMeasuredHeight());
            }
            else if(_loc2_.kind == CollectionEventKind.REFRESH)
            {
               this.dataProviderChanged = true;
               invalidateProperties();
               invalidateSize();
            }
            else if(_loc2_.kind == CollectionEventKind.RESET)
            {
               this.dataProviderChanged = true;
               invalidateProperties();
               invalidateSize();
            }
         }
         itemsSizeChanged = true;
         invalidateDisplayList();
      }
      
      private function mouseDownOutsideHandler(param1:Event) : void
      {
         var _loc2_:MouseEvent = null;
         if(param1 is MouseEvent)
         {
            _loc2_ = MouseEvent(param1);
            if(!this.isMouseOverMenu(_loc2_) && !this.isMouseOverMenuBarItem(_loc2_))
            {
               this.hideAllMenus();
            }
         }
         else if(param1 is SandboxMouseEvent)
         {
            this.hideAllMenus();
         }
      }
      
      override protected function mouseUpHandler(param1:MouseEvent) : void
      {
         var _loc2_:MenuEvent = null;
         var _loc4_:Object = null;
         var _loc5_:Boolean = false;
         if(!enabled || !selectable || !visible)
         {
            return;
         }
         super.mouseUpHandler(param1);
         var _loc3_:IListItemRenderer = this.mouseEventToItemRenderer(param1);
         if(_loc3_ && _loc3_.data)
         {
            _loc4_ = _loc3_.data;
         }
         if(_loc4_ != null && this._dataDescriptor.isEnabled(_loc4_) && !this._dataDescriptor.isBranch(_loc4_))
         {
            if(_loc5_ = this._dataDescriptor.getType(_loc4_) != "radio" || !this._dataDescriptor.isToggled(_loc4_))
            {
               this.setMenuItemToggled(_loc4_,!this._dataDescriptor.isToggled(_loc4_));
            }
            _loc2_ = new MenuEvent(MenuEvent.ITEM_CLICK);
            _loc2_.menu = this;
            _loc2_.index = this.selectedIndex;
            _loc2_.menuBar = this.sourceMenuBar;
            _loc2_.label = itemToLabel(_loc4_);
            _loc2_.item = _loc4_;
            _loc2_.itemRenderer = _loc3_;
            this.getRootMenu().dispatchEvent(_loc2_);
            if(_loc5_)
            {
               _loc2_ = new MenuEvent(MenuEvent.CHANGE);
               _loc2_.menu = this;
               _loc2_.index = this.selectedIndex;
               _loc2_.menuBar = this.sourceMenuBar;
               _loc2_.label = itemToLabel(_loc4_);
               _loc2_.item = _loc4_;
               _loc2_.itemRenderer = _loc3_;
               this.getRootMenu().dispatchEvent(_loc2_);
            }
            this.hideAllMenus();
         }
      }
      
      override protected function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc2_:IListItemRenderer = this.mouseEventToItemRenderer(param1);
         if(_loc2_ && _loc2_.data)
         {
            _loc3_ = _loc2_.data;
         }
         if(_loc3_ && this._dataDescriptor.isEnabled(_loc3_) && !this._dataDescriptor.isBranch(_loc3_))
         {
            super.mouseDownHandler(param1);
         }
      }
      
      override protected function mouseOutHandler(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         if(!enabled || !selectable || !visible)
         {
            return;
         }
         systemManager.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true);
         var _loc2_:IListItemRenderer = this.mouseEventToItemRenderer(param1);
         if(!_loc2_)
         {
            return;
         }
         if(_loc2_ && _loc2_.data)
         {
            _loc3_ = _loc2_.data;
         }
         if(this.openSubMenuTimer)
         {
            clearInterval(this.openSubMenuTimer);
            this.openSubMenuTimer = 0;
         }
         if(itemRendererContains(_loc2_,param1.relatedObject) || itemRendererContains(_loc2_,DisplayObject(param1.target)) || param1.relatedObject == highlightIndicator || param1.relatedObject == listContent || !highlightItemRenderer)
         {
            return;
         }
         if(getStyle("useRollOver") && _loc3_)
         {
            this.clearHighlight(_loc2_);
         }
      }
      
      override protected function mouseOverHandler(param1:MouseEvent) : void
      {
         var item:Object = null;
         var menuEvent:MenuEvent = null;
         var event:MouseEvent = param1;
         if(!enabled || !selectable || !visible)
         {
            return;
         }
         systemManager.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true,0,true);
         var row:IListItemRenderer = this.mouseEventToItemRenderer(event);
         if(!row)
         {
            return;
         }
         if(row && row.data)
         {
            item = row.data;
         }
         isPressed = event.buttonDown;
         if(row && row != this.anchorRow)
         {
            if(this.anchorRow)
            {
               this.drawItem(this.anchorRow,false,false);
            }
            if(this.subMenu)
            {
               this.subMenu.supposedToLoseFocus = true;
               this.subMenu.closeTimer = setTimeout(this.closeSubMenu,250,this.subMenu);
            }
            this.subMenu = null;
            this.anchorRow = null;
         }
         else if(this.subMenu && this.subMenu.subMenu)
         {
            this.subMenu.subMenu.hide();
         }
         if(this._dataDescriptor.isBranch(item) && this._dataDescriptor.isEnabled(item))
         {
            this.anchorRow = row;
            if(this.subMenu && this.subMenu.closeTimer)
            {
               clearInterval(this.subMenu.closeTimer);
               this.subMenu.closeTimer = 0;
            }
            if(!this.subMenu || !this.subMenu.visible)
            {
               if(this.openSubMenuTimer)
               {
                  clearInterval(this.openSubMenuTimer);
               }
               this.openSubMenuTimer = setTimeout(function(param1:IListItemRenderer):void
               {
                  openSubMenu(param1);
               },250,row);
            }
         }
         if(item && this._dataDescriptor.isEnabled(item))
         {
            if(event.relatedObject)
            {
               if(itemRendererContains(row,event.relatedObject) || row == mx_internal::lastHighlightItemRenderer || event.relatedObject == highlightIndicator)
               {
                  return;
               }
            }
         }
         if(row)
         {
            this.drawItem(row,false,Boolean(item && this._dataDescriptor.isEnabled(item)));
            if(mx_internal::isPressed)
            {
               if(item && this._dataDescriptor.isEnabled(item))
               {
                  if(!this._dataDescriptor.isBranch(item))
                  {
                     selectItem(row,event.shiftKey,event.ctrlKey);
                  }
                  else
                  {
                     clearSelected();
                  }
               }
            }
            if(item && this._dataDescriptor.isEnabled(item))
            {
               menuEvent = new MenuEvent(MenuEvent.ITEM_ROLL_OVER);
               menuEvent.menu = this;
               menuEvent.index = this.getRowIndex(row);
               menuEvent.menuBar = this.sourceMenuBar;
               menuEvent.label = itemToLabel(item);
               menuEvent.item = item;
               menuEvent.itemRenderer = row;
               this.getRootMenu().dispatchEvent(menuEvent);
            }
         }
      }
      
      override protected function mouseClickHandler(param1:MouseEvent) : void
      {
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc5_:MenuEvent = null;
         var _loc2_:IListItemRenderer = selectedIndex == -1 ? null : listItems[selectedIndex - verticalScrollPosition][0];
         var _loc3_:Object = !!_loc2_ ? _loc2_.data : null;
         var _loc4_:Menu = !!_loc2_ ? IMenuItemRenderer(_loc2_).menu : null;
         var _loc6_:uint;
         if((_loc6_ = mapKeycodeForLayoutDirection(param1)) == Keyboard.UP)
         {
            if(_loc3_ && this._dataDescriptor.isBranch(_loc3_) && _loc4_ && _loc4_.visible)
            {
               this.supposedToLoseFocus = true;
               _loc4_.setFocus();
               _loc4_.moveSelBy(_loc4_.dataProvider.length,-1);
            }
            else
            {
               this.moveSelBy(selectedIndex,-1);
            }
            param1.stopPropagation();
         }
         else if(_loc6_ == Keyboard.DOWN)
         {
            if(_loc3_ && this._dataDescriptor.isBranch(_loc3_) && _loc4_ && _loc4_.visible)
            {
               this.supposedToLoseFocus = true;
               _loc4_.setFocus();
               _loc4_.moveSelBy(-1,1);
            }
            else
            {
               this.moveSelBy(selectedIndex,1);
            }
            param1.stopPropagation();
         }
         else if(_loc6_ == Keyboard.RIGHT)
         {
            if(_loc3_ && this._dataDescriptor.isBranch(_loc3_))
            {
               this.openSubMenu(_loc2_);
               _loc4_ = IMenuItemRenderer(_loc2_).menu;
               this.supposedToLoseFocus = true;
               _loc4_.setFocus();
               _loc4_.moveSelBy(-1,1);
            }
            else if(this.sourceMenuBar)
            {
               this.supposedToLoseFocus = true;
               this.sourceMenuBar.setFocus();
               this.sourceMenuBar.dispatchEvent(param1);
            }
            param1.stopPropagation();
         }
         else if(_loc6_ == Keyboard.LEFT)
         {
            if(this._parentMenu)
            {
               this.supposedToLoseFocus = true;
               this.hide();
               this._parentMenu.setFocus();
            }
            else if(this.sourceMenuBar)
            {
               this.supposedToLoseFocus = true;
               this.sourceMenuBar.setFocus();
               this.sourceMenuBar.dispatchEvent(param1);
            }
            param1.stopPropagation();
         }
         else if(_loc6_ == Keyboard.ENTER || _loc6_ == Keyboard.SPACE)
         {
            if(_loc3_ && this._dataDescriptor.isBranch(_loc3_))
            {
               this.openSubMenu(_loc2_);
               _loc4_ = IMenuItemRenderer(_loc2_).menu;
               this.supposedToLoseFocus = true;
               _loc4_.setFocus();
               _loc4_.moveSelBy(-1,1);
            }
            else if(_loc3_)
            {
               this.setMenuItemToggled(_loc3_,!this._dataDescriptor.isToggled(_loc3_));
               (_loc5_ = new MenuEvent(MenuEvent.ITEM_CLICK)).menu = this;
               _loc5_.index = this.selectedIndex;
               _loc5_.menuBar = this.sourceMenuBar;
               _loc5_.label = itemToLabel(_loc3_);
               _loc5_.item = _loc3_;
               _loc5_.itemRenderer = _loc2_;
               this.getRootMenu().dispatchEvent(_loc5_);
               (_loc5_ = new MenuEvent(MenuEvent.CHANGE)).menu = this;
               _loc5_.index = this.selectedIndex;
               _loc5_.menuBar = this.sourceMenuBar;
               _loc5_.label = itemToLabel(_loc3_);
               _loc5_.item = _loc3_;
               _loc5_.itemRenderer = _loc2_;
               this.getRootMenu().dispatchEvent(_loc5_);
               this.hideAllMenus();
            }
            param1.stopPropagation();
         }
         else if(_loc6_ == Keyboard.TAB)
         {
            (_loc5_ = new MenuEvent(MenuEvent.MENU_HIDE)).menu = this.getRootMenu();
            _loc5_.menuBar = this.sourceMenuBar;
            this.getRootMenu().dispatchEvent(_loc5_);
            this.hideAllMenus();
            param1.stopPropagation();
         }
         else if(_loc6_ == Keyboard.ESCAPE)
         {
            if(this._parentMenu)
            {
               this.supposedToLoseFocus = true;
               this.hide();
               this._parentMenu.setFocus();
            }
            else
            {
               (_loc5_ = new MenuEvent(MenuEvent.MENU_HIDE)).menu = this.getRootMenu();
               _loc5_.menuBar = this.sourceMenuBar;
               this.getRootMenu().dispatchEvent(_loc5_);
               this.hideAllMenus();
               param1.stopPropagation();
            }
         }
      }
      
      private function moveSelBy(param1:Number, param2:Number) : void
      {
         var _loc6_:Object = null;
         var _loc8_:MenuEvent = null;
         var _loc9_:Object = null;
         var _loc3_:Number = param1;
         if(isNaN(_loc3_))
         {
            _loc3_ = -1;
         }
         var _loc4_:Number = Math.max(0,Math.min(rowCount,collection.length) - 1);
         var _loc5_:Number = _loc3_;
         var _loc7_:int = 0;
         while(true)
         {
            _loc5_ += param2;
            if(_loc7_ > _loc4_)
            {
               break;
            }
            _loc7_++;
            if(_loc5_ > _loc4_)
            {
               _loc5_ = 0;
            }
            else if(_loc5_ < 0)
            {
               _loc5_ = _loc4_;
            }
            if(!((_loc6_ = listItems[_loc5_][0]).data && (this._dataDescriptor.getType(_loc6_.data) == "separator" || !this._dataDescriptor.isEnabled(_loc6_.data))))
            {
               if(selectedIndex != -1)
               {
                  _loc9_ = listItems[selectedIndex][0];
                  (_loc8_ = new MenuEvent(MenuEvent.ITEM_ROLL_OUT)).menu = this;
                  _loc8_.index = this.selectedIndex;
                  _loc8_.menuBar = this.sourceMenuBar;
                  _loc8_.label = itemToLabel(_loc9_.data);
                  _loc8_.item = _loc9_.data;
                  _loc8_.itemRenderer = IListItemRenderer(_loc9_);
                  this.getRootMenu().dispatchEvent(_loc8_);
               }
               if(_loc6_.data)
               {
                  selectItem(listItems[_loc5_ - verticalScrollPosition][0],false,false);
                  (_loc8_ = new MenuEvent(MenuEvent.ITEM_ROLL_OVER)).menu = this;
                  _loc8_.index = this.selectedIndex;
                  _loc8_.menuBar = this.sourceMenuBar;
                  _loc8_.label = itemToLabel(_loc6_.data);
                  _loc8_.item = _loc6_.data;
                  _loc8_.itemRenderer = IListItemRenderer(_loc6_);
                  this.getRootMenu().dispatchEvent(_loc8_);
               }
               return;
            }
         }
      }
      
      mx_internal function openSubMenu(param1:IListItemRenderer) : void
      {
         var _loc3_:Menu = null;
         var _loc10_:Number = NaN;
         var _loc15_:Number = NaN;
         this.supposedToLoseFocus = true;
         var _loc2_:Menu = this.getRootMenu();
         if(!IMenuItemRenderer(param1).menu)
         {
            _loc3_ = new Menu();
            _loc3_.parentMenu = this;
            _loc3_.owner = this;
            _loc3_.showRoot = this.showRoot;
            _loc3_.dataDescriptor = _loc2_.dataDescriptor;
            _loc3_.styleName = _loc2_;
            _loc3_.labelField = _loc2_.labelField;
            _loc3_.labelFunction = _loc2_.labelFunction;
            _loc3_.iconField = _loc2_.iconField;
            _loc3_.iconFunction = _loc2_.iconFunction;
            _loc3_.itemRenderer = _loc2_.itemRenderer;
            _loc3_.rowHeight = _loc2_.rowHeight;
            _loc3_.scaleY = _loc2_.scaleY;
            _loc3_.scaleX = _loc2_.scaleX;
            if(param1.data && this._dataDescriptor.isBranch(param1.data) && this._dataDescriptor.hasChildren(param1.data))
            {
               _loc3_.dataProvider = this._dataDescriptor.getChildren(param1.data);
            }
            _loc3_.sourceMenuBar = this.sourceMenuBar;
            _loc3_.sourceMenuBarItem = this.sourceMenuBarItem;
            IMenuItemRenderer(param1).menu = _loc3_;
            PopUpManager.addPopUp(_loc3_,_loc2_,false);
         }
         else
         {
            _loc3_ = IMenuItemRenderer(param1).menu;
         }
         var _loc4_:DisplayObject = DisplayObject(param1);
         var _loc5_:Point = new Point(0,0);
         _loc5_ = _loc4_.localToGlobal(_loc5_);
         if(_loc4_.root)
         {
            _loc5_ = _loc4_.root.globalToLocal(_loc5_);
         }
         var _loc6_:* = layoutDirection == LayoutDirection.RTL;
         var _loc7_:Number = _loc3_.getExplicitOrMeasuredWidth();
         var _loc8_:Number = param1.width;
         var _loc9_:Number = _loc5_.y;
         if(!this.isDirectionLeft)
         {
            _loc10_ = _loc5_.x + (!!_loc6_ ? -_loc8_ : Number(_loc8_));
         }
         else
         {
            _loc10_ = _loc5_.x + (!!_loc6_ ? Number(_loc7_) : -_loc7_);
         }
         if(_loc6_)
         {
            _loc10_ -= _loc7_;
         }
         var _loc11_:Rectangle = systemManager.getVisibleApplicationRect(null,true);
         var _loc14_:Number;
         var _loc13_:Point;
         var _loc12_:DisplayObject;
         if((_loc14_ = (_loc13_ = (_loc12_ = systemManager.getSandboxRoot()).localToGlobal(new Point(_loc10_,_loc9_))).x + _loc7_ - _loc11_.right) > 0 || _loc13_.x < _loc11_.x)
         {
            _loc15_ = getExplicitOrMeasuredWidth() + _loc3_.getExplicitOrMeasuredWidth();
            if(this.isDirectionLeft)
            {
               _loc15_ *= -1;
            }
            _loc10_ = Math.max(_loc10_ - _loc15_,0);
            _loc13_ = new Point(_loc10_,_loc9_);
            _loc13_ = _loc12_.localToGlobal(_loc13_);
            _loc14_ = Math.max(0,_loc13_.x + width - _loc11_.right);
            _loc10_ = Math.max(_loc10_ - _loc14_,0);
         }
         _loc3_.isDirectionLeft = !!_loc6_ ? this.x <= _loc10_ : this.x > _loc10_;
         if((_loc14_ = _loc13_.y + _loc3_.getExplicitOrMeasuredHeight() - _loc11_.bottom) > 0 || _loc13_.y < _loc11_.y)
         {
            _loc9_ = Math.max(_loc9_ - _loc14_,0);
         }
         _loc3_.show(_loc10_,_loc9_);
         this.subMenu = _loc3_;
         clearInterval(this.openSubMenuTimer);
         this.openSubMenuTimer = 0;
      }
      
      private function closeSubMenu(param1:Menu) : void
      {
         param1.hide();
         clearInterval(param1.closeTimer);
         param1.closeTimer = 0;
      }
      
      mx_internal function deleteDependentSubMenus() : void
      {
         var _loc3_:Menu = null;
         var _loc1_:int = listItems.length;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(listItems[_loc2_][0])
            {
               _loc3_ = IMenuItemRenderer(listItems[_loc2_][0]).menu;
               if(_loc3_)
               {
                  _loc3_.deleteDependentSubMenus();
                  PopUpManager.removePopUp(_loc3_);
                  IMenuItemRenderer(listItems[_loc2_][0]).menu = null;
               }
            }
            _loc2_++;
         }
      }
      
      mx_internal function hideAllMenus() : void
      {
         this.getRootMenu().hide();
         this.getRootMenu().deleteDependentSubMenus();
      }
      
      private function isMouseOverMenu(param1:MouseEvent) : Boolean
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         while(_loc2_)
         {
            if(_loc2_ is Menu)
            {
               return true;
            }
            _loc2_ = _loc2_.parent;
         }
         return false;
      }
      
      private function isMouseOverMenuBarItem(param1:MouseEvent) : Boolean
      {
         if(!this.sourceMenuBarItem)
         {
            return false;
         }
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         while(_loc2_)
         {
            if(_loc2_ == this.sourceMenuBarItem)
            {
               return true;
            }
            _loc2_ = _loc2_.parent;
         }
         return false;
      }
      
      mx_internal function getRootMenu() : Menu
      {
         var _loc1_:Menu = this;
         while(_loc1_.parentMenu)
         {
            _loc1_ = _loc1_.parentMenu;
         }
         return _loc1_;
      }
      
      private function getRowIndex(param1:IListItemRenderer) : int
      {
         var _loc3_:IListItemRenderer = null;
         var _loc2_:int = 0;
         while(_loc2_ < listItems.length)
         {
            _loc3_ = listItems[_loc2_][0];
            if(_loc3_ && _loc3_.data && this._dataDescriptor.getType(_loc3_.data) != "separator")
            {
               if(_loc3_ == param1)
               {
                  return _loc2_;
               }
            }
            _loc2_++;
         }
         return -1;
      }
      
      mx_internal function get subMenus() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < listItems.length)
         {
            _loc1_.push(listItems[_loc2_][0].menu);
            _loc2_++;
         }
         return _loc1_;
      }
   }
}
