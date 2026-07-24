package mx.managers
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.InteractiveObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.Font;
   import flash.text.TextFormat;
   import flash.ui.ContextMenu;
   import flash.utils.Dictionary;
   import mx.core.FlexSprite;
   import mx.core.IChildList;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModule;
   import mx.core.IUIComponent;
   import mx.core.IWindow;
   import mx.core.RSLData;
   import mx.core.Singleton;
   import mx.core.mx_internal;
   import mx.events.DynamicEvent;
   import mx.events.FlexEvent;
   import mx.events.Request;
   import mx.events.SandboxMouseEvent;
   import mx.managers.systemClasses.ChildManager;
   import mx.styles.ISimpleStyleClient;
   import mx.styles.IStyleClient;
   
   use namespace mx_internal;
   
   public class WindowedSystemManager extends MovieClip implements ISystemManager
   {
       
      
      mx_internal var topLevel:Boolean = true;
      
      private var initialized:Boolean = false;
      
      mx_internal var topLevelWindow:IUIComponent;
      
      private var myWindow:IWindow;
      
      private var _topLevelSystemManager:ISystemManager;
      
      mx_internal var childManager:ISystemManagerChildManager;
      
      private var isStageRoot:Boolean = true;
      
      mx_internal var idleCounter:int = 0;
      
      private var isBootstrapRoot:Boolean = false;
      
      mx_internal var nestLevel:int = 0;
      
      private var mouseCatcher:Sprite;
      
      private var _applicationIndex:int = 1;
      
      private var _allowDomainsInNewRSLs:Boolean = true;
      
      private var _allowInsecureDomainsInNewRSLs:Boolean = true;
      
      private var _cursorChildren:WindowedSystemChildrenList;
      
      private var _cursorIndex:int = 0;
      
      private var _document:Object;
      
      private var _fontList:Object = null;
      
      private var _focusPane:Sprite;
      
      private var _numModalWindows:int = 0;
      
      private var _popUpChildren:WindowedSystemChildrenList;
      
      private var _noTopMostIndex:int = 0;
      
      private var _rawChildren:WindowedSystemRawChildrenList;
      
      mx_internal var _screen:Rectangle;
      
      private var _toolTipChildren:WindowedSystemChildrenList;
      
      private var _toolTipIndex:int = 0;
      
      private var _topMostIndex:int = 0;
      
      private var _width:Number;
      
      private var _window:IWindow = null;
      
      private var _height:Number;
      
      private var implMap:Object;
      
      private var isDispatchingResizeEvent:Boolean;
      
      mx_internal var _mouseX;
      
      mx_internal var _mouseY;
      
      public function WindowedSystemManager(param1:IUIComponent)
      {
         this.implMap = {};
         super();
         this._topLevelSystemManager = this;
         this.topLevelWindow = param1;
         SystemManagerGlobals.topLevelSystemManagers.push(this);
         this.childManager = new ChildManager(this);
         this.addEventListener(Event.ADDED,this.docFrameHandler);
      }
      
      private static function getChildListIndex(param1:IChildList, param2:Object) : int
      {
         var _loc3_:int = -1;
         try
         {
            _loc3_ = param1.getChildIndex(DisplayObject(param2));
         }
         catch(e:ArgumentError)
         {
         }
         return _loc3_;
      }
      
      mx_internal function get applicationIndex() : int
      {
         return this._applicationIndex;
      }
      
      mx_internal function set applicationIndex(param1:int) : void
      {
         this._applicationIndex = param1;
      }
      
      public function get allowDomainsInNewRSLs() : Boolean
      {
         return this._allowDomainsInNewRSLs;
      }
      
      public function set allowDomainsInNewRSLs(param1:Boolean) : void
      {
         this._allowDomainsInNewRSLs = param1;
      }
      
      public function get allowInsecureDomainsInNewRSLs() : Boolean
      {
         return this._allowInsecureDomainsInNewRSLs;
      }
      
      public function set allowInsecureDomainsInNewRSLs(param1:Boolean) : void
      {
         this._allowInsecureDomainsInNewRSLs = param1;
      }
      
      public function get cursorChildren() : IChildList
      {
         if(!this.topLevel)
         {
            return this._topLevelSystemManager.cursorChildren;
         }
         if(!this._cursorChildren)
         {
            this._cursorChildren = new WindowedSystemChildrenList(this,new QName(mx_internal,"toolTipIndex"),new QName(mx_internal,"cursorIndex"));
         }
         return this._cursorChildren;
      }
      
      mx_internal function get cursorIndex() : int
      {
         return this._cursorIndex;
      }
      
      mx_internal function set cursorIndex(param1:int) : void
      {
         var _loc2_:int = param1 - this._cursorIndex;
         this._cursorIndex = param1;
      }
      
      public function get document() : Object
      {
         return this._document;
      }
      
      public function set document(param1:Object) : void
      {
         this._document = param1;
      }
      
      public function get embeddedFontList() : Object
      {
         var _loc1_:Object = null;
         var _loc2_:* = null;
         var _loc3_:Object = null;
         if(this._fontList == null)
         {
            this._fontList = {};
            _loc1_ = this.info()["fonts"];
            for(_loc2_ in _loc1_)
            {
               this._fontList[_loc2_] = _loc1_[_loc2_];
            }
            if(!this.topLevel && this._topLevelSystemManager)
            {
               _loc3_ = this._topLevelSystemManager.embeddedFontList;
               for(_loc2_ in _loc3_)
               {
                  this._fontList[_loc2_] = _loc3_[_loc2_];
               }
            }
         }
         return this._fontList;
      }
      
      public function get focusPane() : Sprite
      {
         return this._focusPane;
      }
      
      public function set focusPane(param1:Sprite) : void
      {
         if(param1)
         {
            this.addChild(param1);
            param1.x = 0;
            param1.y = 0;
            param1.scrollRect = null;
            this._focusPane = param1;
         }
         else
         {
            this.removeChild(this._focusPane);
            this._focusPane = null;
         }
      }
      
      public function get isProxy() : Boolean
      {
         return false;
      }
      
      mx_internal final function get $numChildren() : int
      {
         return super.numChildren;
      }
      
      public function get numModalWindows() : int
      {
         return this._numModalWindows;
      }
      
      public function set numModalWindows(param1:int) : void
      {
         this._numModalWindows = param1;
      }
      
      public function get preloadedRSLs() : Dictionary
      {
         return null;
      }
      
      public function get popUpChildren() : IChildList
      {
         if(!this.topLevel)
         {
            return this._topLevelSystemManager.popUpChildren;
         }
         if(!this._popUpChildren)
         {
            this._popUpChildren = new WindowedSystemChildrenList(this,new QName(mx_internal,"noTopMostIndex"),new QName(mx_internal,"topMostIndex"));
         }
         return this._popUpChildren;
      }
      
      mx_internal function get noTopMostIndex() : int
      {
         return this._noTopMostIndex;
      }
      
      mx_internal function set noTopMostIndex(param1:int) : void
      {
         var _loc2_:int = param1 - this._noTopMostIndex;
         this._noTopMostIndex = param1;
         this.topMostIndex += _loc2_;
      }
      
      public function get rawChildren() : IChildList
      {
         if(!this.topLevel)
         {
            return this._topLevelSystemManager.rawChildren;
         }
         if(!this._rawChildren)
         {
            this._rawChildren = new WindowedSystemRawChildrenList(this);
         }
         return this._rawChildren;
      }
      
      public function get screen() : Rectangle
      {
         if(!this._screen)
         {
            this._screen = new Rectangle();
         }
         this._screen.x = 0;
         this._screen.y = 0;
         this._screen.width = stage.stageWidth;
         this._screen.height = stage.stageHeight;
         return this._screen;
      }
      
      public function get toolTipChildren() : IChildList
      {
         if(!this.topLevel)
         {
            return this._topLevelSystemManager.toolTipChildren;
         }
         if(!this._toolTipChildren)
         {
            this._toolTipChildren = new WindowedSystemChildrenList(this,new QName(mx_internal,"topMostIndex"),new QName(mx_internal,"toolTipIndex"));
         }
         return this._toolTipChildren;
      }
      
      mx_internal function get toolTipIndex() : int
      {
         return this._toolTipIndex;
      }
      
      mx_internal function set toolTipIndex(param1:int) : void
      {
         var _loc2_:int = param1 - this._toolTipIndex;
         this._toolTipIndex = param1;
         this.cursorIndex += _loc2_;
      }
      
      public function get topLevelSystemManager() : ISystemManager
      {
         if(this.topLevel)
         {
            return this;
         }
         return this._topLevelSystemManager;
      }
      
      mx_internal function get topMostIndex() : int
      {
         return this._topMostIndex;
      }
      
      mx_internal function set topMostIndex(param1:int) : void
      {
         var _loc2_:int = param1 - this._topMostIndex;
         this._topMostIndex = param1;
         this.toolTipIndex += _loc2_;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      mx_internal function get window() : IWindow
      {
         return this._window;
      }
      
      mx_internal function set window(param1:IWindow) : void
      {
         this._window = param1;
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      public function get childAllowsParent() : Boolean
      {
         try
         {
            return loaderInfo.childAllowsParent;
         }
         catch(error:Error)
         {
            return false;
         }
      }
      
      public function get parentAllowsChild() : Boolean
      {
         try
         {
            return loaderInfo.parentAllowsChild;
         }
         catch(error:Error)
         {
            return false;
         }
      }
      
      mx_internal final function $addChild(param1:DisplayObject) : DisplayObject
      {
         return super.addChild(param1);
      }
      
      mx_internal final function $addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         return super.addChildAt(param1,param2);
      }
      
      mx_internal final function $removeChild(param1:DisplayObject) : DisplayObject
      {
         return super.removeChild(param1);
      }
      
      mx_internal final function $removeChildAt(param1:int) : DisplayObject
      {
         return super.removeChildAt(param1);
      }
      
      public function callInContext(param1:Function, param2:Object, param3:Array, param4:Boolean = true) : *
      {
         if(param4)
         {
            return param1.apply(param2,param3);
         }
         param1.apply(param2,param3);
      }
      
      public function create(... rest) : Object
      {
         var _loc2_:String = String(rest[0]);
         var _loc3_:Class = Class(this.getDefinitionByName(_loc2_));
         if(!_loc3_)
         {
            throw new Error("Class \'" + _loc2_ + "\' not found.");
         }
         var _loc4_:Object;
         if((_loc4_ = new _loc3_()) is IFlexModule)
         {
            IFlexModule(_loc4_).moduleFactory = this;
         }
         return _loc4_;
      }
      
      protected function docFrameHandler(param1:Event = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Class = null;
         this.removeEventListener(Event.ADDED,this.docFrameHandler);
         if(stage)
         {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
         }
         var _loc2_:Array = this.info()["mixins"];
         if(_loc2_ && _loc2_.length > 0)
         {
            _loc3_ = _loc2_.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               (_loc5_ = Class(this.getDefinitionByName(_loc2_[_loc4_])))["init"](this);
               _loc4_++;
            }
         }
         if(_loc5_ = Singleton.getClass("mx.managers::IActiveWindowManager"))
         {
            this.registerImplementation("mx.managers::IActiveWindowManager",new _loc5_(this));
         }
         if(_loc5_ = Singleton.getClass("mx.managers::IMarshalSystemManager"))
         {
            this.registerImplementation("mx.managers::IMarshalSystemManager",new _loc5_(this));
         }
         this.initializeTopLevelWindow(null);
         if(Singleton.getClass("mx.managers::IDragManager").getInstance() is NativeDragManagerImpl)
         {
            NativeDragManagerImpl(Singleton.getClass("mx.managers::IDragManager").getInstance()).registerSystemManager(this);
         }
      }
      
      protected function initializeTopLevelWindow(param1:Event) : void
      {
         var _loc2_:IUIComponent = null;
         var _loc3_:DisplayObjectContainer = null;
         this.initialized = true;
         if(this.getSandboxRoot() == this)
         {
            this.addEventListener(MouseEvent.MOUSE_WHEEL,this.mouseEventHandler,true,1000);
            this.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseEventHandler,true,1000);
         }
         if(this.isTopLevelRoot() && stage)
         {
            stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.mouseEventHandler,false,1000);
            stage.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseEventHandler,false,1000);
         }
         if(!parent)
         {
            return;
         }
         this.initContextMenu();
         if(!this.topLevel)
         {
            if(!parent)
            {
               return;
            }
            _loc3_ = parent.parent;
            if(!_loc3_)
            {
               return;
            }
            while(_loc3_)
            {
               if(_loc3_ is IUIComponent)
               {
                  this._topLevelSystemManager = IUIComponent(_loc3_).systemManager;
                  break;
               }
               _loc3_ = _loc3_.parent;
            }
         }
         stage.addEventListener(Event.RESIZE,this.Stage_resizeHandler,false,0,true);
         this.document = _loc2_ = this.topLevelWindow;
         if(this.document)
         {
            if(this.topLevel && stage)
            {
               this._width = stage.stageWidth;
               this._height = stage.stageHeight;
               IFlexDisplayObject(_loc2_).setActualSize(stage.stageWidth,stage.stageHeight);
            }
            else
            {
               IFlexDisplayObject(_loc2_).setActualSize(loaderInfo.width,loaderInfo.height);
            }
            this.addingChild(DisplayObject(_loc2_));
            this.childAdded(DisplayObject(_loc2_));
         }
         else
         {
            this.document = this;
         }
         this.addChildAndMouseCatcher();
      }
      
      private function addChildAndMouseCatcher() : void
      {
         var _loc1_:IUIComponent = this.topLevelWindow;
         this.mouseCatcher = new FlexSprite();
         this.mouseCatcher.name = "mouseCatcher";
         ++this.noTopMostIndex;
         super.addChildAt(this.mouseCatcher,0);
         this.resizeMouseCatcher();
         if(!this.topLevel)
         {
            this.mouseCatcher.visible = false;
            mask = this.mouseCatcher;
         }
         ++this.noTopMostIndex;
         super.addChild(DisplayObject(_loc1_));
      }
      
      public function info() : Object
      {
         return {"currentDomain":ApplicationDomain.currentDomain};
      }
      
      private function initContextMenu() : void
      {
         var _loc1_:ContextMenu = new ContextMenu();
         _loc1_.hideBuiltInItems();
         _loc1_.builtInItems.print = true;
         contextMenu = _loc1_;
      }
      
      public function isTopLevelRoot() : Boolean
      {
         return this.isStageRoot || this.isBootstrapRoot;
      }
      
      public function getTopLevelRoot() : DisplayObject
      {
         var _loc1_:ISystemManager = null;
         var _loc2_:DisplayObject = null;
         var _loc3_:DisplayObject = null;
         try
         {
            _loc1_ = this;
            if(_loc1_.topLevelSystemManager)
            {
               _loc1_ = ISystemManager(_loc1_.topLevelSystemManager);
            }
            _loc2_ = DisplayObject(_loc1_).parent;
            _loc3_ = DisplayObject(_loc1_);
            while(_loc2_)
            {
               if(_loc2_ is Stage)
               {
                  return _loc3_;
               }
               _loc3_ = _loc2_;
               _loc2_ = _loc2_.parent;
            }
         }
         catch(error:SecurityError)
         {
         }
         return null;
      }
      
      public function getSandboxRoot() : DisplayObject
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:DisplayObject = null;
         var _loc4_:Loader = null;
         var _loc5_:LoaderInfo = null;
         var _loc1_:ISystemManager = this;
         try
         {
            if(_loc1_.topLevelSystemManager)
            {
               _loc1_ = ISystemManager(_loc1_.topLevelSystemManager);
            }
            _loc2_ = DisplayObject(_loc1_).parent;
            if(_loc2_ is Stage)
            {
               return DisplayObject(_loc1_);
            }
            if(_loc2_ && !_loc2_.dispatchEvent(new Event("mx.managers.SystemManager.isBootstrapRoot",false,true)))
            {
               return this;
            }
            _loc3_ = this;
            while(_loc2_)
            {
               if(_loc2_ is Stage)
               {
                  return _loc3_;
               }
               if(!_loc2_.dispatchEvent(new Event("mx.managers.SystemManager.isBootstrapRoot",false,true)))
               {
                  return _loc3_;
               }
               if(_loc2_ is Loader)
               {
                  if(!(_loc5_ = (_loc4_ = Loader(_loc2_)).contentLoaderInfo).childAllowsParent)
                  {
                     return _loc5_.content;
                  }
               }
               if(_loc2_.hasEventListener("systemManagerRequest"))
               {
                  _loc3_ = _loc2_;
               }
               _loc2_ = _loc2_.parent;
            }
         }
         catch(error:Error)
         {
         }
         return _loc3_ != null ? _loc3_ : DisplayObject(_loc1_);
      }
      
      public function registerImplementation(param1:String, param2:Object) : void
      {
         var _loc3_:Object = this.implMap[param1];
         if(!_loc3_)
         {
            this.implMap[param1] = param2;
         }
      }
      
      public function getImplementation(param1:String) : Object
      {
         return this.implMap[param1];
      }
      
      public function getVisibleApplicationRect(param1:Rectangle = null, param2:Boolean = false) : Rectangle
      {
         var _loc4_:Rectangle = null;
         var _loc5_:Point = null;
         var _loc6_:DisplayObjectContainer = null;
         var _loc7_:Rectangle = null;
         var _loc3_:Request = new Request("getVisibleApplicationRect",false,true);
         if(!dispatchEvent(_loc3_))
         {
            return Rectangle(_loc3_.value);
         }
         if(param2 && !this.topLevel)
         {
            return this.topLevelSystemManager.getVisibleApplicationRect(param1,param2);
         }
         if(!param1)
         {
            param1 = getBounds(DisplayObject(this));
            _loc4_ = this.screen;
            _loc5_ = new Point(Math.max(0,param1.x),Math.max(0,param1.y));
            _loc5_ = localToGlobal(_loc5_);
            param1.x = _loc5_.x;
            param1.y = _loc5_.y;
            param1.width = _loc4_.width;
            param1.height = _loc4_.height;
         }
         if(!this.topLevel)
         {
            _loc6_ = parent.parent;
            if("getVisibleApplicationRect" in _loc6_)
            {
               _loc7_ = _loc6_["getVisibleApplicationRect"](true);
               param1 = param1.intersection(_loc7_);
            }
         }
         return param1;
      }
      
      public function deployMouseShields(param1:Boolean) : void
      {
         var _loc2_:DynamicEvent = new DynamicEvent("deployMouseShields");
         _loc2_.deploy = param1;
         dispatchEvent(_loc2_);
      }
      
      public function addPreloadedRSL(param1:LoaderInfo, param2:Vector.<RSLData>) : void
      {
      }
      
      public function allowDomain(... rest) : void
      {
      }
      
      public function allowInsecureDomain(... rest) : void
      {
      }
      
      public function isTopLevelWindow(param1:DisplayObject) : Boolean
      {
         return param1 is IUIComponent && IUIComponent(param1) == this.topLevelWindow;
      }
      
      public function getDefinitionByName(param1:String) : Object
      {
         var _loc3_:Object = null;
         var _loc2_:ApplicationDomain = ApplicationDomain.currentDomain;
         if(!this.topLevel && parent is Loader)
         {
            Loader(parent).contentLoaderInfo.applicationDomain;
         }
         else
         {
            this.info()["currentDomain"] as ApplicationDomain;
         }
         if(_loc2_.hasDefinition(param1))
         {
            _loc3_ = _loc2_.getDefinition(param1);
         }
         return _loc3_;
      }
      
      public function isTopLevel() : Boolean
      {
         return this.topLevel;
      }
      
      public function isFontFaceEmbedded(param1:TextFormat) : Boolean
      {
         var _loc6_:Font = null;
         var _loc7_:String = null;
         var _loc2_:String = param1.font;
         var _loc3_:Array = Font.enumerateFonts();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            if((_loc6_ = Font(_loc3_[_loc4_])).fontName == _loc2_)
            {
               _loc7_ = "regular";
               if(param1.bold && param1.italic)
               {
                  _loc7_ = "boldItalic";
               }
               else if(param1.bold)
               {
                  _loc7_ = "bold";
               }
               else if(param1.italic)
               {
                  _loc7_ = "italic";
               }
               if(_loc6_.fontStyle == _loc7_)
               {
                  return true;
               }
            }
            _loc4_++;
         }
         if(!_loc2_ || !this.embeddedFontList || !this.embeddedFontList[_loc2_])
         {
            return false;
         }
         var _loc5_:Object = this.embeddedFontList[_loc2_];
         return !(param1.bold && !_loc5_.bold || param1.italic && !_loc5_.italic || !param1.bold && !param1.italic && !_loc5_.regular);
      }
      
      private function Stage_resizeHandler(param1:Event = null) : void
      {
         var _loc2_:Number = stage.stageWidth;
         var _loc3_:Number = stage.stageHeight;
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         if(!this._screen)
         {
            this._screen = new Rectangle();
         }
         this._screen.x = _loc5_;
         this._screen.y = _loc4_;
         this._screen.width = _loc2_;
         this._screen.height = _loc3_;
         this._width = stage.stageWidth;
         this._height = stage.stageHeight;
         if(param1)
         {
            this.resizeMouseCatcher();
            dispatchEvent(param1);
         }
      }
      
      private function resizeMouseCatcher() : void
      {
         var _loc1_:Graphics = null;
         if(this.mouseCatcher)
         {
            _loc1_ = this.mouseCatcher.graphics;
            _loc1_.clear();
            _loc1_.beginFill(0,0);
            _loc1_.drawRect(0,0,stage.stageWidth,stage.stageHeight);
            _loc1_.endFill();
         }
      }
      
      mx_internal final function $addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         super.addEventListener(param1,param2,param3,param4,param5);
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         var request:DynamicEvent = null;
         var type:String = param1;
         var listener:Function = param2;
         var useCapture:Boolean = param3;
         var priority:int = param4;
         var useWeakReference:Boolean = param5;
         if(type == MouseEvent.MOUSE_MOVE || type == MouseEvent.MOUSE_UP || type == MouseEvent.MOUSE_DOWN || type == Event.ACTIVATE || type == Event.DEACTIVATE)
         {
            try
            {
               if(stage)
               {
                  stage.addEventListener(type,this.stageEventHandler,false,0,true);
               }
            }
            catch(error:SecurityError)
            {
            }
         }
         if(hasEventListener("addEventListener"))
         {
            request = new DynamicEvent("addEventListener",false,true);
            request.eventType = type;
            request.listener = listener;
            request.useCapture = useCapture;
            request.priority = priority;
            request.useWeakReference = useWeakReference;
            if(!dispatchEvent(request))
            {
               return;
            }
         }
         if(type == SandboxMouseEvent.MOUSE_UP_SOMEWHERE)
         {
            try
            {
               if(stage)
               {
                  stage.addEventListener(Event.MOUSE_LEAVE,this.mouseLeaveHandler,false,0,true);
               }
               else
               {
                  super.addEventListener(Event.MOUSE_LEAVE,this.mouseLeaveHandler,false,0,true);
               }
            }
            catch(error:SecurityError)
            {
               super.addEventListener(Event.MOUSE_LEAVE,mouseLeaveHandler,false,0,true);
            }
         }
         if(type == FlexEvent.RENDER || type == FlexEvent.ENTER_FRAME)
         {
            if(type == FlexEvent.RENDER)
            {
               type = Event.RENDER;
            }
            else
            {
               type = Event.ENTER_FRAME;
            }
            try
            {
               if(stage)
               {
                  stage.addEventListener(type,listener,useCapture,priority,useWeakReference);
               }
               else
               {
                  super.addEventListener(type,listener,useCapture,priority,useWeakReference);
               }
            }
            catch(error:SecurityError)
            {
               super.addEventListener(type,listener,useCapture,priority,useWeakReference);
            }
            if(stage && type == Event.RENDER)
            {
               stage.invalidate();
            }
            return;
         }
         super.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      mx_internal final function $removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         super.removeEventListener(param1,param2,param3);
      }
      
      override public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         var _loc4_:DynamicEvent = null;
         if(hasEventListener("removeEventListener"))
         {
            (_loc4_ = new DynamicEvent("removeEventListener",false,true)).eventType = param1;
            _loc4_.listener = param2;
            _loc4_.useCapture = param3;
            if(!dispatchEvent(_loc4_))
            {
               return;
            }
         }
         if(param1 == FlexEvent.RENDER || param1 == FlexEvent.ENTER_FRAME)
         {
            if(param1 == FlexEvent.RENDER)
            {
               param1 = Event.RENDER;
            }
            else
            {
               param1 = Event.ENTER_FRAME;
            }
            try
            {
               if(stage)
               {
                  stage.removeEventListener(param1,param2,param3);
               }
            }
            catch(error:SecurityError)
            {
            }
            super.removeEventListener(param1,param2,param3);
            return;
         }
         super.removeEventListener(param1,param2,param3);
         if(param1 == MouseEvent.MOUSE_MOVE || param1 == MouseEvent.MOUSE_UP || param1 == MouseEvent.MOUSE_DOWN || param1 == Event.ACTIVATE || param1 == Event.DEACTIVATE)
         {
            if(!hasEventListener(param1))
            {
               try
               {
                  if(stage)
                  {
                     stage.removeEventListener(param1,this.stageEventHandler,false);
                  }
               }
               catch(error:SecurityError)
               {
               }
            }
         }
         if(param1 == SandboxMouseEvent.MOUSE_UP_SOMEWHERE)
         {
            if(!hasEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE))
            {
               try
               {
                  if(stage)
                  {
                     stage.removeEventListener(Event.MOUSE_LEAVE,this.mouseLeaveHandler);
                  }
               }
               catch(error:SecurityError)
               {
               }
               super.removeEventListener(Event.MOUSE_LEAVE,this.mouseLeaveHandler);
            }
         }
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         ++this.noTopMostIndex;
         return this.rawChildren_addChildAt(param1,this.noTopMostIndex - 1);
      }
      
      override public function get numChildren() : int
      {
         return this.noTopMostIndex - this.applicationIndex;
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         ++this.noTopMostIndex;
         return this.rawChildren_addChildAt(param1,this.applicationIndex + param2);
      }
      
      override public function removeChild(param1:DisplayObject) : DisplayObject
      {
         --this.noTopMostIndex;
         return this.rawChildren_removeChild(param1);
      }
      
      override public function removeChildAt(param1:int) : DisplayObject
      {
         --this.noTopMostIndex;
         return this.rawChildren_removeChildAt(this.applicationIndex + param1);
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         return super.getChildAt(this.applicationIndex + param1);
      }
      
      override public function getChildByName(param1:String) : DisplayObject
      {
         return super.getChildByName(param1);
      }
      
      override public function getChildIndex(param1:DisplayObject) : int
      {
         return super.getChildIndex(param1) - this.applicationIndex;
      }
      
      override public function setChildIndex(param1:DisplayObject, param2:int) : void
      {
         super.setChildIndex(param1,this.applicationIndex + param2);
      }
      
      override public function getObjectsUnderPoint(param1:Point) : Array
      {
         var _loc5_:DisplayObject = null;
         var _loc6_:Array = null;
         var _loc2_:Array = [];
         var _loc3_:int = this.topMostIndex;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if((_loc5_ = super.getChildAt(_loc4_)) is DisplayObjectContainer)
            {
               if(_loc6_ = DisplayObjectContainer(_loc5_).getObjectsUnderPoint(param1))
               {
                  _loc2_ = _loc2_.concat(_loc6_);
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      mx_internal function addingChild(param1:DisplayObject) : void
      {
         var _loc4_:DisplayObjectContainer = null;
         var _loc2_:int = 1;
         if(!this.topLevel)
         {
            _loc4_ = parent.parent;
            while(_loc4_)
            {
               if(_loc4_ is ILayoutManagerClient)
               {
                  _loc2_ = ILayoutManagerClient(_loc4_).nestLevel + 1;
                  break;
               }
               _loc4_ = _loc4_.parent;
            }
         }
         this.nestLevel = _loc2_;
         if(param1 is IUIComponent)
         {
            IUIComponent(param1).systemManager = this;
         }
         var _loc3_:Class = Class(this.getDefinitionByName("mx.core.UIComponent"));
         if(param1 is IUIComponent && !IUIComponent(param1).document)
         {
            IUIComponent(param1).document = this.document;
         }
         if(param1 is ILayoutManagerClient)
         {
            ILayoutManagerClient(param1).nestLevel = this.nestLevel + 1;
         }
         if(param1 is InteractiveObject)
         {
            if(doubleClickEnabled)
            {
               InteractiveObject(param1).doubleClickEnabled = true;
            }
         }
         if(param1 is IUIComponent)
         {
            IUIComponent(param1).parentChanged(this);
         }
         if(param1 is IStyleClient)
         {
            IStyleClient(param1).regenerateStyleCache(true);
         }
         if(param1 is ISimpleStyleClient)
         {
            ISimpleStyleClient(param1).styleChanged(null);
         }
         if(param1 is IStyleClient)
         {
            IStyleClient(param1).notifyStyleChangeInChildren(null,true);
         }
         if(_loc3_ && param1 is _loc3_)
         {
            _loc3_(param1).initThemeColor();
         }
         if(_loc3_ && param1 is _loc3_)
         {
            _loc3_(param1).stylesInitialized();
         }
      }
      
      mx_internal function childAdded(param1:DisplayObject) : void
      {
         if(param1.hasEventListener(FlexEvent.ADD))
         {
            param1.dispatchEvent(new FlexEvent(FlexEvent.ADD));
         }
         if(param1 is IUIComponent)
         {
            IUIComponent(param1).initialize();
         }
      }
      
      mx_internal function removingChild(param1:DisplayObject) : void
      {
         if(param1.hasEventListener(FlexEvent.REMOVE))
         {
            param1.dispatchEvent(new FlexEvent(FlexEvent.REMOVE));
         }
      }
      
      mx_internal function childRemoved(param1:DisplayObject) : void
      {
         if(param1 is IUIComponent)
         {
            IUIComponent(param1).parentChanged(null);
         }
      }
      
      mx_internal function rawChildren_addChild(param1:DisplayObject) : DisplayObject
      {
         this.childManager.addingChild(param1);
         super.addChild(param1);
         this.childManager.childAdded(param1);
         return param1;
      }
      
      mx_internal function rawChildren_addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         if(this.childManager)
         {
            this.childManager.addingChild(param1);
         }
         super.addChildAt(param1,param2);
         if(this.childManager)
         {
            this.childManager.childAdded(param1);
         }
         return param1;
      }
      
      mx_internal function rawChildren_removeChild(param1:DisplayObject) : DisplayObject
      {
         this.childManager.removingChild(param1);
         super.removeChild(param1);
         this.childManager.childRemoved(param1);
         return param1;
      }
      
      mx_internal function rawChildren_removeChildAt(param1:int) : DisplayObject
      {
         var _loc2_:DisplayObject = super.getChildAt(param1);
         this.childManager.removingChild(_loc2_);
         super.removeChildAt(param1);
         this.childManager.childRemoved(_loc2_);
         return _loc2_;
      }
      
      mx_internal function rawChildren_getChildAt(param1:int) : DisplayObject
      {
         return super.getChildAt(param1);
      }
      
      mx_internal function rawChildren_getChildByName(param1:String) : DisplayObject
      {
         return super.getChildByName(param1);
      }
      
      mx_internal function rawChildren_getChildIndex(param1:DisplayObject) : int
      {
         return super.getChildIndex(param1);
      }
      
      mx_internal function rawChildren_setChildIndex(param1:DisplayObject, param2:int) : void
      {
         super.setChildIndex(param1,param2);
      }
      
      mx_internal function rawChildren_getObjectsUnderPoint(param1:Point) : Array
      {
         return super.getObjectsUnderPoint(param1);
      }
      
      mx_internal function rawChildren_contains(param1:DisplayObject) : Boolean
      {
         return super.contains(param1);
      }
      
      override public function get mouseX() : Number
      {
         if(this._mouseX === undefined)
         {
            return super.mouseX;
         }
         return this._mouseX;
      }
      
      override public function get mouseY() : Number
      {
         if(this._mouseY === undefined)
         {
            return super.mouseY;
         }
         return this._mouseY;
      }
      
      public function getFocus() : InteractiveObject
      {
         try
         {
            return stage.focus;
         }
         catch(e:SecurityError)
         {
            return null;
         }
      }
      
      mx_internal function cleanup(param1:Event) : void
      {
         if(Singleton.getClass("mx.managers::IDragManager").getInstance() is NativeDragManagerImpl)
         {
            NativeDragManagerImpl(Singleton.getClass("mx.managers::IDragManager").getInstance()).unregisterSystemManager(this);
         }
         SystemManagerGlobals.topLevelSystemManagers.splice(SystemManagerGlobals.topLevelSystemManagers.indexOf(this),1);
         this.myWindow.nativeWindow.removeEventListener(Event.CLOSE,this.cleanup);
         this.myWindow = null;
      }
      
      mx_internal function addWindow(param1:IWindow) : void
      {
         this.myWindow = param1;
         this.myWindow.nativeWindow.addEventListener(Event.CLOSE,this.cleanup);
      }
      
      private function stageEventHandler(param1:Event) : void
      {
         if(param1.target is Stage)
         {
            dispatchEvent(param1);
         }
      }
      
      private function mouseLeaveHandler(param1:Event) : void
      {
         dispatchEvent(new SandboxMouseEvent(SandboxMouseEvent.MOUSE_UP_SOMEWHERE));
      }
      
      public function invalidateParentSizeAndDisplayList() : void
      {
      }
      
      private function mouseEventHandler(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = null;
         if(!param1.cancelable)
         {
            param1.stopImmediatePropagation();
            _loc2_ = new MouseEvent(param1.type,param1.bubbles,true,param1.localX,param1.localY,param1.relatedObject,param1.ctrlKey,param1.altKey,param1.shiftKey,param1.buttonDown,param1.delta,param1.commandKey,param1.controlKey,param1.clickCount);
            param1.target.dispatchEvent(_loc2_);
         }
      }
   }
}
