package spark.components
{
   import flash.desktop.NativeApplication;
   import flash.display.DisplayObject;
   import flash.display.NativeWindow;
   import flash.display.NativeWindowDisplayState;
   import flash.display.NativeWindowInitOptions;
   import flash.display.NativeWindowResize;
   import flash.display.NativeWindowSystemChrome;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.NativeWindowBoundsEvent;
   import flash.events.NativeWindowDisplayStateEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import mx.controls.FlexNativeMenu;
   import mx.core.FlexGlobals;
   import mx.core.IVisualElement;
   import mx.core.IWindow;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.AIREvent;
   import mx.events.EffectEvent;
   import mx.events.FlexEvent;
   import mx.events.FlexNativeWindowBoundsEvent;
   import mx.events.WindowExistenceEvent;
   import mx.managers.CursorManagerImpl;
   import mx.managers.FocusManager;
   import mx.managers.IActiveWindowManager;
   import mx.managers.ICursorManager;
   import mx.managers.ISystemManager;
   import mx.managers.SystemManagerGlobals;
   import mx.managers.WindowedSystemManager;
   import spark.components.supportClasses.TextBase;
   import spark.components.windowClasses.TitleBar;
   
   use namespace mx_internal;
   
   public class Window extends SkinnableContainer implements IWindow
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const DEFAULT_WINDOW_HEIGHT:Number = 100;
      
      private static const DEFAULT_WINDOW_WIDTH:Number = 100;
       
      
      private var _nativeWindow:NativeWindow;
      
      private var _nativeWindowVisible:Boolean = true;
      
      private var maximized:Boolean = false;
      
      private var _cursorManager:ICursorManager;
      
      private var toMax:Boolean = false;
      
      private var frameCounter:int = 0;
      
      private var flagForOpen:Boolean = false;
      
      private var openActive:Boolean = true;
      
      private var oldX:Number;
      
      private var oldY:Number;
      
      private var prevX:Number;
      
      private var prevY:Number;
      
      private var resizeWidth:Boolean = true;
      
      private var resizeHeight:Boolean = true;
      
      [SkinPart(required="false")]
      public var gripper:Button;
      
      [SkinPart(required="false")]
      public var statusBar:IVisualElement;
      
      [SkinPart(required="false")]
      public var statusText:TextBase;
      
      [SkinPart(required="false")]
      public var titleBar:TitleBar;
      
      private var _maxHeight:Number = 2880;
      
      private var maxHeightChanged:Boolean = false;
      
      private var _maxWidth:Number = 2880;
      
      private var maxWidthChanged:Boolean = false;
      
      private var _minHeight:Number = 0;
      
      private var minHeightChanged:Boolean = false;
      
      private var _minWidth:Number = 0;
      
      private var minWidthChanged:Boolean = false;
      
      private var _alwaysInFront:Boolean = false;
      
      private var _bounds:Rectangle;
      
      private var boundsChanged:Boolean = false;
      
      private var _maximizable:Boolean = true;
      
      private var _menu:FlexNativeMenu;
      
      private var menuChanged:Boolean = false;
      
      private var _minimizable:Boolean = true;
      
      private var _renderMode:String = "auto";
      
      private var _resizable:Boolean = true;
      
      private var _showStatusBar:Boolean = true;
      
      private var showStatusBarChanged:Boolean = true;
      
      private var _status:String = "";
      
      private var statusChanged:Boolean = false;
      
      private var _systemChrome:String = "standard";
      
      private var _title:String = "";
      
      private var titleChanged:Boolean = false;
      
      private var _titleIcon:Class;
      
      private var titleIconChanged:Boolean = false;
      
      private var _transparent:Boolean = false;
      
      private var _type:String = "normal";
      
      public function Window()
      {
         this._bounds = new Rectangle(0,0,DEFAULT_WINDOW_WIDTH,DEFAULT_WINDOW_HEIGHT);
         super();
         addEventListener(FlexEvent.CREATION_COMPLETE,this.creationCompleteHandler);
         addEventListener(FlexEvent.PREINITIALIZE,this.preinitializeHandler);
         invalidateProperties();
      }
      
      private static function weakDependency() : void
      {
      }
      
      public static function getWindow(param1:UIComponent) : IWindow
      {
         if(param1.systemManager is WindowedSystemManager)
         {
            return WindowedSystemManager(param1.systemManager).window;
         }
         return null;
      }
      
      [Bindable("heightChanged")]
      override public function get height() : Number
      {
         return this._bounds.height;
      }
      
      override public function set height(param1:Number) : void
      {
         if(param1 < this.minHeight)
         {
            param1 = this.minHeight;
         }
         else if(param1 > this.maxHeight)
         {
            param1 = this.maxHeight;
         }
         this._bounds.height = param1;
         this.boundsChanged = true;
         invalidateProperties();
         invalidateSize();
         dispatchEvent(new Event("heightChanged"));
      }
      
      [Bindable("windowComplete")]
      [Bindable("maxHeightChanged")]
      override public function get maxHeight() : Number
      {
         if(this.nativeWindow && !this.maxHeightChanged)
         {
            return this.nativeWindow.maxSize.y - this.chromeHeight();
         }
         return this._maxHeight;
      }
      
      override public function set maxHeight(param1:Number) : void
      {
         this._maxHeight = param1;
         this.maxHeightChanged = true;
         invalidateProperties();
      }
      
      [Bindable("windowComplete")]
      [Bindable("maxWidthChanged")]
      override public function get maxWidth() : Number
      {
         if(this.nativeWindow && !this.maxWidthChanged)
         {
            return this.nativeWindow.maxSize.x - this.chromeWidth();
         }
         return this._maxWidth;
      }
      
      override public function set maxWidth(param1:Number) : void
      {
         this._maxWidth = param1;
         this.maxWidthChanged = true;
         invalidateProperties();
      }
      
      [Bindable("windowComplete")]
      [Bindable("minHeightChanged")]
      override public function get minHeight() : Number
      {
         if(this.nativeWindow && !this.minHeightChanged)
         {
            return this.nativeWindow.minSize.y - this.chromeHeight();
         }
         return this._minHeight;
      }
      
      override public function set minHeight(param1:Number) : void
      {
         this._minHeight = param1;
         this.minHeightChanged = true;
         invalidateProperties();
      }
      
      [Bindable("windowComplete")]
      [Bindable("minWidthChanged")]
      override public function get minWidth() : Number
      {
         if(this.nativeWindow && !this.minWidthChanged)
         {
            return this.nativeWindow.minSize.x - this.chromeWidth();
         }
         return this._minWidth;
      }
      
      override public function set minWidth(param1:Number) : void
      {
         this._minWidth = param1;
         this.minWidthChanged = true;
         invalidateProperties();
      }
      
      [Bindable("windowComplete")]
      [Bindable("show")]
      [Bindable("hide")]
      override public function get visible() : Boolean
      {
         if(this.nativeWindow && this.nativeWindow.closed)
         {
            return false;
         }
         if(this.nativeWindow)
         {
            return this.nativeWindow.visible;
         }
         return this._nativeWindowVisible;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         this.setVisible(param1);
      }
      
      override public function setVisible(param1:Boolean, param2:Boolean = false) : void
      {
         if(!this._nativeWindow)
         {
            this._nativeWindowVisible = param1;
            invalidateProperties();
         }
         else if(!this._nativeWindow.closed)
         {
            if(param1)
            {
               this._nativeWindow.visible = param1;
            }
            else if(getStyle("hideEffect") && initialized && mx_internal::$visible != param1)
            {
               addEventListener(EffectEvent.EFFECT_END,this.hideEffectEndHandler);
            }
            else
            {
               this._nativeWindow.visible = param1;
            }
         }
         super.setVisible(param1,param2);
      }
      
      [Bindable("widthChanged")]
      override public function get width() : Number
      {
         return this._bounds.width;
      }
      
      override public function set width(param1:Number) : void
      {
         if(param1 < this.minWidth)
         {
            param1 = this.minWidth;
         }
         else if(param1 > this.maxWidth)
         {
            param1 = this.maxWidth;
         }
         this._bounds.width = param1;
         this.boundsChanged = true;
         invalidateProperties();
         invalidateSize();
         dispatchEvent(new Event("widthChanged"));
      }
      
      public function get alwaysInFront() : Boolean
      {
         if(this._nativeWindow && !this._nativeWindow.closed)
         {
            return this.nativeWindow.alwaysInFront;
         }
         return this._alwaysInFront;
      }
      
      public function set alwaysInFront(param1:Boolean) : void
      {
         this._alwaysInFront = param1;
         if(this._nativeWindow && !this._nativeWindow.closed)
         {
            this.nativeWindow.alwaysInFront = param1;
         }
      }
      
      protected function get bounds() : Rectangle
      {
         return this._bounds;
      }
      
      protected function set bounds(param1:Rectangle) : void
      {
         this._bounds = param1;
         this.boundsChanged = true;
         invalidateProperties();
         invalidateSize();
      }
      
      public function get closed() : Boolean
      {
         return this.nativeWindow.closed;
      }
      
      public function get colorCorrection() : String
      {
         var _loc1_:ISystemManager = null;
         try
         {
            _loc1_ = systemManager;
            if(_loc1_ && _loc1_.stage)
            {
               return _loc1_.stage.colorCorrection;
            }
         }
         catch(e:SecurityError)
         {
         }
         return null;
      }
      
      public function set colorCorrection(param1:String) : void
      {
         var _loc2_:ISystemManager = systemManager;
         if(_loc2_ && _loc2_.stage && _loc2_.isTopLevelRoot())
         {
            _loc2_.stage.colorCorrection = param1;
         }
      }
      
      public function get maximizable() : Boolean
      {
         return this._maximizable;
      }
      
      public function set maximizable(param1:Boolean) : void
      {
         if(!this._nativeWindow)
         {
            this._maximizable = param1;
            invalidateProperties();
         }
      }
      
      override public function get cursorManager() : ICursorManager
      {
         return this._cursorManager;
      }
      
      public function get menu() : FlexNativeMenu
      {
         return this._menu;
      }
      
      public function set menu(param1:FlexNativeMenu) : void
      {
         if(this._menu)
         {
            this._menu.automationParent = null;
            this._menu.automationOwner = null;
         }
         this._menu = param1;
         this.menuChanged = true;
         if(this._menu)
         {
            this.menu.automationParent = this;
            this.menu.automationOwner = this;
         }
      }
      
      public function get minimizable() : Boolean
      {
         return this._minimizable;
      }
      
      public function set minimizable(param1:Boolean) : void
      {
         if(!this._nativeWindow)
         {
            this._minimizable = param1;
            invalidateProperties();
         }
      }
      
      public function get nativeWindow() : NativeWindow
      {
         if(systemManager && systemManager.stage)
         {
            return systemManager.stage.nativeWindow;
         }
         return null;
      }
      
      public function get renderMode() : String
      {
         return this._renderMode;
      }
      
      public function set renderMode(param1:String) : void
      {
         if(!this._nativeWindow)
         {
            this._renderMode = param1;
            invalidateProperties();
         }
      }
      
      public function get resizable() : Boolean
      {
         return this._resizable;
      }
      
      public function set resizable(param1:Boolean) : void
      {
         if(!this._nativeWindow)
         {
            this._resizable = param1;
            invalidateProperties();
         }
      }
      
      public function get showStatusBar() : Boolean
      {
         return this._showStatusBar;
      }
      
      public function set showStatusBar(param1:Boolean) : void
      {
         if(this._showStatusBar == param1)
         {
            return;
         }
         this._showStatusBar = param1;
         this.showStatusBarChanged = true;
         invalidateProperties();
         invalidateDisplayList();
      }
      
      [Bindable("statusChanged")]
      public function get status() : String
      {
         return this._status;
      }
      
      public function set status(param1:String) : void
      {
         this._status = param1;
         this.statusChanged = true;
         invalidateProperties();
         invalidateSize();
         dispatchEvent(new Event("statusChanged"));
      }
      
      public function get systemChrome() : String
      {
         return this._systemChrome;
      }
      
      public function set systemChrome(param1:String) : void
      {
         if(!this._nativeWindow)
         {
            this._systemChrome = param1;
            invalidateProperties();
         }
      }
      
      [Bindable("titleChanged")]
      public function get title() : String
      {
         return this._title;
      }
      
      public function set title(param1:String) : void
      {
         this.titleChanged = true;
         this._title = param1;
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
         dispatchEvent(new Event("titleChanged"));
      }
      
      [Bindable("titleIconChanged")]
      public function get titleIcon() : Class
      {
         return this._titleIcon;
      }
      
      public function set titleIcon(param1:Class) : void
      {
         this._titleIcon = param1;
         this.titleIconChanged = true;
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
         dispatchEvent(new Event("titleIconChanged"));
      }
      
      public function get transparent() : Boolean
      {
         return this._transparent;
      }
      
      public function set transparent(param1:Boolean) : void
      {
         if(!this._nativeWindow)
         {
            this._transparent = param1;
            invalidateProperties();
         }
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function set type(param1:String) : void
      {
         if(!this._nativeWindow)
         {
            this._type = param1;
            invalidateProperties();
         }
      }
      
      override protected function createChildren() : void
      {
         this.width = this._bounds.width;
         this.height = this._bounds.height;
         super.createChildren();
      }
      
      protected function setupWindowInitOptions() : NativeWindowInitOptions
      {
         var _loc1_:NativeWindowInitOptions = new NativeWindowInitOptions();
         _loc1_.maximizable = this._maximizable;
         _loc1_.minimizable = this._minimizable;
         _loc1_.resizable = this._resizable;
         _loc1_.type = this._type;
         _loc1_.systemChrome = this._systemChrome;
         _loc1_.transparent = this._transparent;
         _loc1_.renderMode = this._renderMode;
         return _loc1_;
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:NativeWindowInitOptions = null;
         var _loc2_:WindowedSystemManager = null;
         var _loc3_:NativeApplication = null;
         var _loc4_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(this.flagForOpen && !this._nativeWindow)
         {
            this.flagForOpen = false;
            if(moduleFactory == null)
            {
               moduleFactory = SystemManagerGlobals.topLevelSystemManagers[0];
            }
            _loc1_ = this.setupWindowInitOptions();
            this._nativeWindow = new NativeWindow(_loc1_);
            _loc2_ = new WindowedSystemManager(this);
            this._nativeWindow.stage.addChild(_loc2_);
            systemManager = _loc2_;
            _loc2_.window = this;
            this._nativeWindow.alwaysInFront = this._alwaysInFront;
            this.initManagers(_loc2_);
            addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            _loc3_ = NativeApplication.nativeApplication;
            _loc3_.addEventListener(Event.ACTIVATE,this.nativeApplication_activateHandler,false,0,true);
            _loc3_.addEventListener(Event.DEACTIVATE,this.nativeApplication_deactivateHandler,false,0,true);
            _loc3_.addEventListener(Event.NETWORK_CHANGE,dispatchEvent,false,0,true);
            this._nativeWindow.addEventListener(Event.ACTIVATE,this.nativeWindow_activateHandler,false,0,true);
            this._nativeWindow.addEventListener(Event.DEACTIVATE,this.nativeWindow_deactivateHandler,false,0,true);
            addEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
            _loc2_.addWindow(this);
         }
         super.commitProperties();
         if(this.minWidthChanged || this.minHeightChanged || this.maxWidthChanged || this.maxHeightChanged)
         {
            _loc4_ = this.nativeWindow.minSize;
            _loc5_ = this.nativeWindow.maxSize;
            _loc6_ = !!this.minWidthChanged ? Number(this._minWidth + this.chromeWidth()) : Number(_loc4_.x);
            _loc7_ = !!this.minHeightChanged ? Number(this._minHeight + this.chromeHeight()) : Number(_loc4_.y);
            _loc8_ = !!this.maxWidthChanged ? Number(this._maxWidth + this.chromeWidth()) : Number(_loc5_.x);
            _loc9_ = !!this.maxHeightChanged ? Number(this._maxHeight + this.chromeHeight()) : Number(_loc5_.y);
            if(this.minWidthChanged || this.minHeightChanged)
            {
               if(this.maxWidthChanged && _loc6_ > _loc4_.x || this.maxHeightChanged && _loc7_ > _loc4_.y)
               {
                  this.nativeWindow.maxSize = new Point(_loc8_,_loc9_);
               }
               this.nativeWindow.minSize = new Point(_loc6_,_loc7_);
            }
            if(_loc8_ != _loc5_.x || _loc9_ != _loc5_.y)
            {
               this.nativeWindow.maxSize = new Point(_loc8_,_loc9_);
            }
         }
         if(this.minWidthChanged || this.minHeightChanged)
         {
            if(this.minWidthChanged)
            {
               this.minWidthChanged = false;
               if(this.width < this.minWidth)
               {
                  this.width = this.minWidth;
               }
               dispatchEvent(new Event("minWidthChanged"));
            }
            if(this.minHeightChanged)
            {
               this.minHeightChanged = false;
               if(this.height < this.minHeight)
               {
                  this.height = this.minHeight;
               }
               dispatchEvent(new Event("minHeightChanged"));
            }
         }
         if(this.maxWidthChanged || this.maxHeightChanged)
         {
            if(this.maxWidthChanged)
            {
               this.maxWidthChanged = false;
               if(this.width > this.maxWidth)
               {
                  this.width = this.maxWidth;
               }
               dispatchEvent(new Event("maxWidthChanged"));
            }
            if(this.maxHeightChanged)
            {
               this.maxHeightChanged = false;
               if(this.height > this.maxHeight)
               {
                  this.height = this.maxHeight;
               }
               dispatchEvent(new Event("maxHeightChanged"));
            }
         }
         if(this.boundsChanged)
         {
            if(this._bounds.height == 0 && this.nativeWindow.displayState != NativeWindowDisplayState.MINIMIZED && this.systemChrome == NativeWindowSystemChrome.STANDARD)
            {
               this.nativeWindow.height = this.chromeHeight() + this._bounds.height;
            }
            setActualSize(this._bounds.width,this._bounds.height);
            _loc10_ = this._bounds.width;
            _loc11_ = this._bounds.height;
            systemManager.stage.stageWidth = _loc10_;
            systemManager.stage.stageHeight = _loc11_;
            this.boundsChanged = false;
         }
         if(this.menuChanged && !this.nativeWindow.closed)
         {
            this.menuChanged = false;
            if(this.menu == null)
            {
               if(NativeWindow.supportsMenu)
               {
                  this.nativeWindow.menu = null;
               }
            }
            else if(this.menu.nativeMenu)
            {
               if(NativeWindow.supportsMenu)
               {
                  this.nativeWindow.menu = this.menu.nativeMenu;
               }
            }
            dispatchEvent(new Event("menuChanged"));
         }
         if(this.titleIconChanged)
         {
            if(this.titleBar)
            {
               this.titleBar.titleIcon = this._titleIcon;
            }
            this.titleIconChanged = false;
         }
         if(this.titleChanged)
         {
            if(!this.nativeWindow.closed)
            {
               systemManager.stage.nativeWindow.title = this._title;
            }
            if(this.titleBar)
            {
               this.titleBar.title = this._title;
            }
            this.titleChanged = false;
         }
         if(this.showStatusBarChanged)
         {
            if(this.statusBar)
            {
               this.statusBar.visible = this._showStatusBar;
            }
            this.showStatusBarChanged = false;
         }
         if(this.statusChanged)
         {
            if(this.statusText)
            {
               this.statusText.text = this._status;
            }
            this.statusChanged = false;
         }
         if(this.toMax)
         {
            this.toMax = false;
            if(!this.nativeWindow.closed)
            {
               this.nativeWindow.maximize();
            }
         }
      }
      
      override public function move(param1:Number, param2:Number) : void
      {
         var _loc3_:Rectangle = null;
         if(this.nativeWindow && !this.nativeWindow.closed)
         {
            _loc3_ = this.nativeWindow.bounds;
            _loc3_.x = param1;
            _loc3_.y = param2;
            this.nativeWindow.bounds = _loc3_;
         }
      }
      
      override protected function partAdded(param1:String, param2:Object) : void
      {
         super.partAdded(param1,param2);
         if(param2 == this.statusBar)
         {
            this.statusBar.visible = this._showStatusBar;
            this.statusBar.includeInLayout = this._showStatusBar;
            this.showStatusBarChanged = false;
         }
         else if(param2 == this.titleBar)
         {
            if(!this.nativeWindow.closed)
            {
               if(this._title == "" && systemManager.stage.nativeWindow.title != null)
               {
                  this._title = systemManager.stage.nativeWindow.title;
               }
               else
               {
                  systemManager.stage.nativeWindow.title = this._title;
               }
            }
            this.titleBar.title = this._title;
            this.titleChanged = false;
         }
         else if(param2 == this.statusText)
         {
            this.statusText.text = this.status;
            this.statusChanged = false;
         }
         else if(param2 == this.gripper)
         {
            this.gripper.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         }
      }
      
      override protected function partRemoved(param1:String, param2:Object) : void
      {
         super.partRemoved(param1,param2);
         if(param2 == this.gripper)
         {
            this.gripper.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         }
      }
      
      public function close() : void
      {
         var _loc1_:Event = null;
         if(this._nativeWindow && !this.nativeWindow.closed)
         {
            _loc1_ = new Event("closing",false,true);
            stage.nativeWindow.dispatchEvent(_loc1_);
            if(!_loc1_.isDefaultPrevented())
            {
               removeEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
               stage.nativeWindow.close();
               this._nativeWindow = null;
               systemManager.removeChild(this);
            }
         }
      }
      
      private function initManagers(param1:ISystemManager) : void
      {
         var _loc2_:IActiveWindowManager = null;
         if(param1.isTopLevel())
         {
            focusManager = new FocusManager(this);
            _loc2_ = IActiveWindowManager(param1.getImplementation("mx.managers::IActiveWindowManager"));
            if(_loc2_)
            {
               _loc2_.activate(this);
            }
            else
            {
               focusManager.activate();
            }
            this._cursorManager = new CursorManagerImpl(param1);
         }
      }
      
      public function maximize() : void
      {
         var _loc1_:NativeWindowDisplayStateEvent = null;
         if(!this.nativeWindow || !this.nativeWindow.maximizable || this.nativeWindow.closed)
         {
            return;
         }
         if(stage.nativeWindow.displayState != NativeWindowDisplayState.MAXIMIZED)
         {
            _loc1_ = new NativeWindowDisplayStateEvent(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,false,true,stage.nativeWindow.displayState,NativeWindowDisplayState.MAXIMIZED);
            stage.nativeWindow.dispatchEvent(_loc1_);
            if(!_loc1_.isDefaultPrevented())
            {
               this.toMax = true;
               invalidateProperties();
            }
         }
      }
      
      public function minimize() : void
      {
         var _loc1_:NativeWindowDisplayStateEvent = null;
         if(!this.minimizable)
         {
            return;
         }
         if(!this.nativeWindow.closed)
         {
            _loc1_ = new NativeWindowDisplayStateEvent(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,false,true,this.nativeWindow.displayState,NativeWindowDisplayState.MINIMIZED);
            stage.nativeWindow.dispatchEvent(_loc1_);
            if(!_loc1_.isDefaultPrevented())
            {
               stage.nativeWindow.minimize();
            }
         }
      }
      
      public function restore() : void
      {
         var _loc1_:NativeWindowDisplayStateEvent = null;
         if(!this.nativeWindow.closed)
         {
            if(stage.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
            {
               _loc1_ = new NativeWindowDisplayStateEvent(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,false,true,NativeWindowDisplayState.MAXIMIZED,NativeWindowDisplayState.NORMAL);
               stage.nativeWindow.dispatchEvent(_loc1_);
               if(!_loc1_.isDefaultPrevented())
               {
                  this.nativeWindow.restore();
               }
            }
            else if(stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED)
            {
               _loc1_ = new NativeWindowDisplayStateEvent(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,false,true,NativeWindowDisplayState.MINIMIZED,NativeWindowDisplayState.NORMAL);
               stage.nativeWindow.dispatchEvent(_loc1_);
               if(!_loc1_.isDefaultPrevented())
               {
                  this.nativeWindow.restore();
               }
            }
         }
      }
      
      public function activate() : void
      {
         if(!this.nativeWindow.closed)
         {
            this._nativeWindow.activate();
            this.visible = true;
         }
      }
      
      public function open(param1:Boolean = true) : void
      {
         if(FlexGlobals.topLevelApplication)
         {
            FlexGlobals.topLevelApplication.dispatchEvent(new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CREATING,false,false,this));
         }
         this.flagForOpen = true;
         this.openActive = param1;
         this.commitProperties();
      }
      
      public function orderInBackOf(param1:IWindow) : Boolean
      {
         if(this.nativeWindow && !this.nativeWindow.closed)
         {
            return this.nativeWindow.orderInBackOf(param1.nativeWindow);
         }
         return false;
      }
      
      public function orderInFrontOf(param1:IWindow) : Boolean
      {
         if(this.nativeWindow && !this.nativeWindow.closed)
         {
            return this.nativeWindow.orderInFrontOf(param1.nativeWindow);
         }
         return false;
      }
      
      public function orderToBack() : Boolean
      {
         if(this.nativeWindow && !this.nativeWindow.closed)
         {
            return this.nativeWindow.orderToBack();
         }
         return false;
      }
      
      public function orderToFront() : Boolean
      {
         if(this.nativeWindow && !this.nativeWindow.closed)
         {
            return this.nativeWindow.orderToFront();
         }
         return false;
      }
      
      override protected function getCurrentSkinState() : String
      {
         if(this.nativeWindow.closed)
         {
            return "disabled";
         }
         if(this.nativeWindow.active)
         {
            return !!enabled ? "normal" : "disabled";
         }
         return !!enabled ? "normalAndInactive" : "disabledAndInactive";
      }
      
      private function chromeWidth() : Number
      {
         return this.nativeWindow.width - systemManager.stage.stageWidth;
      }
      
      private function chromeHeight() : Number
      {
         return this.nativeWindow.height - systemManager.stage.stageHeight;
      }
      
      private function startResize(param1:String) : void
      {
         if(this.resizable && !this.nativeWindow.closed)
         {
            stage.nativeWindow.startResize(param1);
         }
      }
      
      private function enterFrameHandler(param1:Event) : void
      {
         if(this.frameCounter == 2)
         {
            removeEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
            this._nativeWindow.visible = this._nativeWindowVisible;
            dispatchEvent(new AIREvent(AIREvent.WINDOW_COMPLETE));
            if(FlexGlobals.topLevelApplication)
            {
               FlexGlobals.topLevelApplication.dispatchEvent(new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CREATE,false,false,this));
            }
            if(this._nativeWindow.visible)
            {
               if(this.openActive)
               {
                  this._nativeWindow.activate();
               }
            }
         }
         ++this.frameCounter;
      }
      
      private function hideEffectEndHandler(param1:Event) : void
      {
         if(!this._nativeWindow.closed)
         {
            this._nativeWindow.visible = false;
         }
         removeEventListener(EffectEvent.EFFECT_END,this.hideEffectEndHandler);
      }
      
      private function windowMinimizeHandler(param1:Event) : void
      {
         if(!this.nativeWindow.closed)
         {
            stage.nativeWindow.minimize();
         }
         removeEventListener(EffectEvent.EFFECT_END,this.windowMinimizeHandler);
      }
      
      private function windowUnminimizeHandler(param1:Event) : void
      {
         removeEventListener(EffectEvent.EFFECT_END,this.windowUnminimizeHandler);
      }
      
      private function window_moveHandler(param1:NativeWindowBoundsEvent) : void
      {
         var _loc2_:FlexNativeWindowBoundsEvent = new FlexNativeWindowBoundsEvent(FlexNativeWindowBoundsEvent.WINDOW_MOVE,param1.bubbles,param1.cancelable,param1.beforeBounds,param1.afterBounds);
         dispatchEvent(_loc2_);
      }
      
      private function window_displayStateChangeHandler(param1:NativeWindowDisplayStateEvent) : void
      {
         dispatchEvent(param1);
         this.height = stage.stageHeight;
         this.width = stage.stageWidth;
         if(param1.beforeDisplayState == NativeWindowDisplayState.MINIMIZED)
         {
            addEventListener(EffectEvent.EFFECT_END,this.windowUnminimizeHandler);
            dispatchEvent(new Event("windowUnminimize"));
         }
         if(param1.afterDisplayState == NativeWindowDisplayState.MAXIMIZED || param1.afterDisplayState == NativeWindowDisplayState.NORMAL)
         {
            invalidateSize();
            invalidateDisplayList();
         }
      }
      
      private function window_displayStateChangingHandler(param1:NativeWindowDisplayStateEvent) : void
      {
         dispatchEvent(param1);
         if(param1.isDefaultPrevented())
         {
            return;
         }
         if(param1.afterDisplayState == NativeWindowDisplayState.MINIMIZED)
         {
            if(getStyle("minimizeEffect"))
            {
               param1.preventDefault();
               addEventListener(EffectEvent.EFFECT_END,this.windowMinimizeHandler);
               dispatchEvent(new Event("windowMinimize"));
            }
         }
      }
      
      protected function mouseDownHandler(param1:MouseEvent) : void
      {
         if(param1.target == this.gripper)
         {
            this.startResize(layoutDirection == "rtl" ? NativeWindowResize.BOTTOM_LEFT : NativeWindowResize.BOTTOM_RIGHT);
            param1.stopPropagation();
            return;
         }
         if(systemManager.stage.nativeWindow.systemChrome != "none")
         {
            return;
         }
         var _loc2_:String = this.hitTestResizeEdge(param1);
         if(_loc2_ != NativeWindowResize.NONE)
         {
            this.startResize(_loc2_);
            param1.stopPropagation();
         }
      }
      
      mx_internal function hitTestResizeEdge(param1:MouseEvent) : String
      {
         var _loc6_:DisplayObject = null;
         if(param1.target is DisplayObject && param1.target != contentGroup)
         {
            _loc6_ = DisplayObject(param1.target);
            while(_loc6_ && _loc6_ != contentGroup && _loc6_ != this)
            {
               _loc6_ = _loc6_.parent;
            }
            if(_loc6_ == null || _loc6_ == contentGroup)
            {
               return NativeWindowResize.NONE;
            }
         }
         var _loc2_:String = NativeWindowResize.NONE;
         var _loc3_:Number = getStyle("resizeAffordanceWidth");
         var _loc4_:int = _loc3_;
         var _loc5_:int = _loc3_ * 2;
         if(param1.stageY < _loc4_)
         {
            if(param1.stageX < _loc5_)
            {
               _loc2_ = NativeWindowResize.TOP_LEFT;
            }
            else if(param1.stageX > this.width - _loc5_)
            {
               _loc2_ = NativeWindowResize.TOP_RIGHT;
            }
            else
            {
               _loc2_ = NativeWindowResize.TOP;
            }
         }
         else if(param1.stageY > this.height - _loc4_)
         {
            if(param1.stageX < _loc5_)
            {
               _loc2_ = NativeWindowResize.BOTTOM_LEFT;
            }
            else if(param1.stageX > this.width - _loc5_)
            {
               _loc2_ = NativeWindowResize.BOTTOM_RIGHT;
            }
            else
            {
               _loc2_ = NativeWindowResize.BOTTOM;
            }
         }
         else if(param1.stageX < _loc4_)
         {
            if(param1.stageY < _loc5_)
            {
               _loc2_ = NativeWindowResize.TOP_LEFT;
            }
            else if(param1.stageY > this.height - _loc5_)
            {
               _loc2_ = NativeWindowResize.BOTTOM_LEFT;
            }
            else
            {
               _loc2_ = NativeWindowResize.LEFT;
            }
         }
         else if(param1.stageX > this.width - _loc4_)
         {
            if(param1.stageY < _loc5_)
            {
               _loc2_ = NativeWindowResize.TOP_RIGHT;
            }
            else if(param1.stageY > this.height - _loc5_)
            {
               _loc2_ = NativeWindowResize.BOTTOM_RIGHT;
            }
            else
            {
               _loc2_ = NativeWindowResize.RIGHT;
            }
         }
         return _loc2_;
      }
      
      private function creationCompleteHandler(param1:Event = null) : void
      {
         systemManager.stage.nativeWindow.addEventListener("closing",this.window_closingHandler);
         systemManager.stage.nativeWindow.addEventListener("close",this.window_closeHandler,false,0,true);
         systemManager.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVING,this.window_boundsHandler);
         systemManager.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE,this.window_moveHandler);
         systemManager.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZING,this.window_boundsHandler);
         systemManager.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE,this.window_resizeHandler);
      }
      
      private function preinitializeHandler(param1:FlexEvent) : void
      {
         systemManager.stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,this.window_displayStateChangingHandler);
         systemManager.stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,this.window_displayStateChangeHandler);
      }
      
      private function window_boundsHandler(param1:NativeWindowBoundsEvent) : void
      {
         var _loc3_:Rectangle = null;
         var _loc4_:Boolean = false;
         var _loc2_:Rectangle = param1.afterBounds;
         if(param1.type == NativeWindowBoundsEvent.MOVING)
         {
            dispatchEvent(param1);
            if(param1.isDefaultPrevented())
            {
               return;
            }
         }
         else
         {
            dispatchEvent(param1);
            if(param1.isDefaultPrevented())
            {
               return;
            }
            _loc4_ = false;
            if(_loc2_.width < this.nativeWindow.minSize.x)
            {
               _loc4_ = true;
               if(_loc2_.x != param1.beforeBounds.x && !isNaN(this.oldX))
               {
                  _loc2_.x = this.oldX;
               }
               _loc2_.width = this.nativeWindow.minSize.x;
            }
            else if(_loc2_.width > this.nativeWindow.maxSize.x)
            {
               _loc4_ = true;
               if(_loc2_.x != param1.beforeBounds.x && !isNaN(this.oldX))
               {
                  _loc2_.x = this.oldX;
               }
               _loc2_.width = this.nativeWindow.maxSize.x;
            }
            if(_loc2_.height < this.nativeWindow.minSize.y)
            {
               _loc4_ = true;
               if(param1.afterBounds.y != param1.beforeBounds.y && !isNaN(this.oldY))
               {
                  _loc2_.y = this.oldY;
               }
               _loc2_.height = this.nativeWindow.minSize.y;
            }
            else if(_loc2_.height > this.nativeWindow.maxSize.y)
            {
               _loc4_ = true;
               if(param1.afterBounds.y != param1.beforeBounds.y && !isNaN(this.oldY))
               {
                  _loc2_.y = this.oldY;
               }
               _loc2_.height = this.nativeWindow.maxSize.y;
            }
            if(_loc4_)
            {
               param1.preventDefault();
               stage.nativeWindow.bounds = _loc2_;
            }
         }
         this.oldX = _loc2_.x;
         this.oldY = _loc2_.y;
      }
      
      private function window_closeEffectEndHandler(param1:Event) : void
      {
         removeEventListener(EffectEvent.EFFECT_END,this.window_closeEffectEndHandler);
         if(!this.nativeWindow.closed)
         {
            stage.nativeWindow.close();
         }
      }
      
      private function window_closingHandler(param1:Event) : void
      {
         var _loc2_:Event = new Event("closing",true,true);
         dispatchEvent(_loc2_);
         if(_loc2_.isDefaultPrevented())
         {
            param1.preventDefault();
         }
         else if(getStyle("closeEffect") && stage.nativeWindow.transparent == true)
         {
            addEventListener(EffectEvent.EFFECT_END,this.window_closeEffectEndHandler);
            dispatchEvent(new Event("windowClose"));
            param1.preventDefault();
         }
      }
      
      private function window_closeHandler(param1:Event) : void
      {
         dispatchEvent(new Event("close"));
         if(FlexGlobals.topLevelApplication)
         {
            FlexGlobals.topLevelApplication.dispatchEvent(new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CLOSE,false,false,this));
         }
      }
      
      private function window_resizeHandler(param1:NativeWindowBoundsEvent) : void
      {
         if(stage == null)
         {
            return;
         }
         invalidateDisplayList();
         var _loc2_:* = this.bounds.width != stage.stageWidth;
         var _loc3_:* = this.bounds.height != stage.stageHeight;
         this.bounds.x = stage.x;
         this.bounds.y = stage.y;
         this.bounds.width = stage.stageWidth;
         this.bounds.height = stage.stageHeight;
         setActualSize(this._bounds.width,this._bounds.height);
         validateNow();
         var _loc4_:FlexNativeWindowBoundsEvent = new FlexNativeWindowBoundsEvent(FlexNativeWindowBoundsEvent.WINDOW_RESIZE,param1.bubbles,param1.cancelable,param1.beforeBounds,param1.afterBounds);
         dispatchEvent(_loc4_);
         if(_loc2_)
         {
            dispatchEvent(new Event("widthChanged"));
         }
         if(_loc3_)
         {
            dispatchEvent(new Event("heightChanged"));
         }
      }
      
      private function nativeApplication_activateHandler(param1:Event) : void
      {
         dispatchEvent(new AIREvent(AIREvent.APPLICATION_ACTIVATE));
      }
      
      private function nativeApplication_deactivateHandler(param1:Event) : void
      {
         dispatchEvent(new AIREvent(AIREvent.APPLICATION_DEACTIVATE));
      }
      
      private function nativeWindow_activateHandler(param1:Event) : void
      {
         dispatchEvent(new AIREvent(AIREvent.WINDOW_ACTIVATE));
         invalidateSkinState();
      }
      
      private function nativeWindow_deactivateHandler(param1:Event) : void
      {
         dispatchEvent(new AIREvent(AIREvent.WINDOW_DEACTIVATE));
         invalidateSkinState();
      }
   }
}
