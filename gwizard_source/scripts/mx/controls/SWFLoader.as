package mx.controls
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.HTTPStatusEvent;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.ByteArray;
   import mx.core.FlexGlobals;
   import mx.core.FlexLoader;
   import mx.core.FlexVersion;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.ILayoutDirectionElement;
   import mx.core.ISWFLoader;
   import mx.core.IUIComponent;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.InterManagerRequest;
   import mx.events.InvalidateRequestData;
   import mx.events.Request;
   import mx.events.SWFBridgeEvent;
   import mx.events.SWFBridgeRequest;
   import mx.managers.CursorManager;
   import mx.managers.IMarshalSystemManager;
   import mx.managers.ISystemManager;
   import mx.managers.SystemManagerGlobals;
   import mx.styles.ISimpleStyleClient;
   import mx.utils.LoaderUtil;
   
   use namespace mx_internal;
   
   public class SWFLoader extends UIComponent implements ISWFLoader
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      mx_internal var contentHolder:DisplayObject;
      
      private var contentChanged:Boolean = false;
      
      private var scaleContentChanged:Boolean = false;
      
      private var smoothBitmapContentChanged:Boolean = false;
      
      private var isContentLoaded:Boolean = false;
      
      private var brokenImage:Boolean = false;
      
      private var resizableContent:Boolean = false;
      
      private var flexContent:Boolean = false;
      
      private var contentRequestID:String = null;
      
      private var attemptingChildAppDomain:Boolean = false;
      
      private var requestedURL:URLRequest;
      
      private var brokenImageBorder:IFlexDisplayObject;
      
      private var explicitLoaderContext:Boolean = false;
      
      private var mouseShield:Sprite;
      
      private var useUnloadAndStop:Boolean;
      
      private var unloadAndStopGC:Boolean;
      
      private var _autoLoad:Boolean = true;
      
      private var _loadForCompatibility:Boolean = false;
      
      private var _bytesLoaded:Number = NaN;
      
      private var _bytesTotal:Number = NaN;
      
      private var _loaderContext:LoaderContext;
      
      private var _maintainAspectRatio:Boolean = true;
      
      private var _swfBridge:IEventDispatcher;
      
      private var _scaleContent:Boolean = true;
      
      private var _showBusyCursor:Boolean = false;
      
      private var _smoothBitmapContent:Boolean = false;
      
      private var _source:Object;
      
      private var _trustContent:Boolean = false;
      
      public function SWFLoader()
      {
         super();
         tabEnabled = false;
         tabFocusEnabled = false;
         addEventListener(FlexEvent.INITIALIZE,this.initializeHandler);
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         addEventListener(MouseEvent.CLICK,this.clickHandler);
         showInAutomationHierarchy = false;
      }
      
      [Bindable("autoLoadChanged")]
      public function get autoLoad() : Boolean
      {
         return this._autoLoad;
      }
      
      public function set autoLoad(param1:Boolean) : void
      {
         if(this._autoLoad != param1)
         {
            this._autoLoad = param1;
            this.contentChanged = true;
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
            dispatchEvent(new Event("autoLoadChanged"));
         }
      }
      
      [Bindable("loadForCompatibilityChanged")]
      public function get loadForCompatibility() : Boolean
      {
         return this._loadForCompatibility;
      }
      
      public function set loadForCompatibility(param1:Boolean) : void
      {
         if(this._loadForCompatibility != param1)
         {
            this._loadForCompatibility = param1;
            this.contentChanged = true;
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
            dispatchEvent(new Event("loadForCompatibilityChanged"));
         }
      }
      
      [Bindable("progress")]
      public function get bytesLoaded() : Number
      {
         return this._bytesLoaded;
      }
      
      [Bindable("complete")]
      public function get bytesTotal() : Number
      {
         return this._bytesTotal;
      }
      
      public function get content() : DisplayObject
      {
         if(this.contentHolder is Loader)
         {
            return Loader(this.contentHolder).content;
         }
         return this.contentHolder;
      }
      
      public function get contentHeight() : Number
      {
         return !!this.contentHolder ? Number(this.contentHolder.height) : Number(NaN);
      }
      
      private function get contentHolderHeight() : Number
      {
         var loaderInfo:LoaderInfo = null;
         var mp:IMarshalSystemManager = null;
         var content:IFlexDisplayObject = null;
         var bridge:IEventDispatcher = null;
         var request:SWFBridgeRequest = null;
         var testContent:DisplayObject = null;
         if(this.contentHolder is Loader)
         {
            loaderInfo = Loader(this.contentHolder).contentLoaderInfo;
         }
         if(loaderInfo)
         {
            if(loaderInfo.contentType == "application/x-shockwave-flash")
            {
               try
               {
                  mp = IMarshalSystemManager(systemManager.getImplementation("mx.managers::IMarshalSystemManager"));
                  if(mp && mp.swfBridgeGroup)
                  {
                     bridge = this.swfBridge;
                     if(bridge)
                     {
                        request = new SWFBridgeRequest(SWFBridgeRequest.GET_SIZE_REQUEST);
                        bridge.dispatchEvent(request);
                        return request.data.height;
                     }
                  }
                  content = Loader(this.contentHolder).content as IFlexDisplayObject;
                  if(content)
                  {
                     return content.measuredHeight;
                  }
               }
               catch(error:Error)
               {
                  return mx_internal::contentHolder.height;
               }
            }
            else
            {
               try
               {
                  testContent = Loader(this.contentHolder).content;
               }
               catch(error:Error)
               {
                  return mx_internal::contentHolder.height;
               }
            }
            return loaderInfo.height;
         }
         if(this.contentHolder is IUIComponent)
         {
            return IUIComponent(this.contentHolder).getExplicitOrMeasuredHeight();
         }
         if(this.contentHolder is IFlexDisplayObject)
         {
            return IFlexDisplayObject(this.contentHolder).measuredHeight;
         }
         return this.contentHolder.height;
      }
      
      private function get contentHolderWidth() : Number
      {
         var loaderInfo:LoaderInfo = null;
         var content:IFlexDisplayObject = null;
         var request:SWFBridgeRequest = null;
         var testContent:DisplayObject = null;
         if(this.contentHolder is Loader)
         {
            loaderInfo = Loader(this.contentHolder).contentLoaderInfo;
         }
         if(loaderInfo)
         {
            if(loaderInfo.contentType == "application/x-shockwave-flash")
            {
               try
               {
                  if(this.swfBridge)
                  {
                     request = new SWFBridgeRequest(SWFBridgeRequest.GET_SIZE_REQUEST);
                     this.swfBridge.dispatchEvent(request);
                     return request.data.width;
                  }
                  content = Loader(this.contentHolder).content as IFlexDisplayObject;
                  if(content)
                  {
                     return content.measuredWidth;
                  }
               }
               catch(error:Error)
               {
                  return mx_internal::contentHolder.width;
               }
            }
            else
            {
               try
               {
                  testContent = Loader(this.contentHolder).content;
               }
               catch(error:Error)
               {
                  return mx_internal::contentHolder.width;
               }
            }
            return loaderInfo.width;
         }
         if(this.contentHolder is IUIComponent)
         {
            return IUIComponent(this.contentHolder).getExplicitOrMeasuredWidth();
         }
         if(this.contentHolder is IFlexDisplayObject)
         {
            return IFlexDisplayObject(this.contentHolder).measuredWidth;
         }
         return this.contentHolder.width;
      }
      
      public function get contentWidth() : Number
      {
         return !!this.contentHolder ? Number(this.contentHolder.width) : Number(NaN);
      }
      
      [Bindable("loaderContextChanged")]
      public function get loaderContext() : LoaderContext
      {
         return this._loaderContext;
      }
      
      public function set loaderContext(param1:LoaderContext) : void
      {
         this._loaderContext = param1;
         this.explicitLoaderContext = true;
         dispatchEvent(new Event("loaderContextChanged"));
      }
      
      [Bindable("maintainAspectRatioChanged")]
      public function get maintainAspectRatio() : Boolean
      {
         return this._maintainAspectRatio;
      }
      
      public function set maintainAspectRatio(param1:Boolean) : void
      {
         this._maintainAspectRatio = param1;
         dispatchEvent(new Event("maintainAspectRatioChanged"));
      }
      
      [Bindable("progress")]
      public function get percentLoaded() : Number
      {
         var _loc1_:Number = isNaN(this._bytesTotal) || this._bytesTotal == 0 ? Number(0) : Number(100 * (this._bytesLoaded / this._bytesTotal));
         if(isNaN(_loc1_))
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      [Bindable("scaleContentChanged")]
      public function get scaleContent() : Boolean
      {
         return this._scaleContent;
      }
      
      public function set scaleContent(param1:Boolean) : void
      {
         if(this._scaleContent != param1)
         {
            this._scaleContent = param1;
            this.scaleContentChanged = true;
            invalidateDisplayList();
         }
         dispatchEvent(new Event("scaleContentChanged"));
      }
      
      public function get showBusyCursor() : Boolean
      {
         return this._showBusyCursor;
      }
      
      public function set showBusyCursor(param1:Boolean) : void
      {
         if(this._showBusyCursor != param1)
         {
            this._showBusyCursor = param1;
            if(this._showBusyCursor)
            {
               CursorManager.registerToUseBusyCursor(this);
            }
            else
            {
               CursorManager.unRegisterToUseBusyCursor(this);
            }
         }
      }
      
      [Bindable("smoothBitmapContentChanged")]
      public function get smoothBitmapContent() : Boolean
      {
         return this._smoothBitmapContent;
      }
      
      public function set smoothBitmapContent(param1:Boolean) : void
      {
         if(this._smoothBitmapContent != param1)
         {
            this._smoothBitmapContent = param1;
            this.smoothBitmapContentChanged = true;
            invalidateDisplayList();
         }
         dispatchEvent(new Event("smoothBitmapContentChanged"));
      }
      
      [Bindable("sourceChanged")]
      public function get source() : Object
      {
         return this._source;
      }
      
      public function set source(param1:Object) : void
      {
         if(this._source != param1)
         {
            this._source = param1;
            this.contentChanged = true;
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
            dispatchEvent(new Event("sourceChanged"));
         }
      }
      
      [Bindable("trustContentChanged")]
      public function get trustContent() : Boolean
      {
         return this._trustContent;
      }
      
      public function set trustContent(param1:Boolean) : void
      {
         if(this._trustContent != param1)
         {
            this._trustContent = param1;
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
            dispatchEvent(new Event("trustContentChanged"));
         }
      }
      
      public function get swfBridge() : IEventDispatcher
      {
         return this._swfBridge;
      }
      
      public function get childAllowsParent() : Boolean
      {
         if(!this.isContentLoaded)
         {
            return false;
         }
         try
         {
            if(this.contentHolder is Loader)
            {
               return Loader(this.contentHolder).contentLoaderInfo.childAllowsParent;
            }
         }
         catch(error:Error)
         {
            return false;
         }
         return true;
      }
      
      public function get parentAllowsChild() : Boolean
      {
         if(!this.isContentLoaded)
         {
            return false;
         }
         try
         {
            if(this.contentHolder is Loader)
            {
               return Loader(this.contentHolder).contentLoaderInfo.parentAllowsChild;
            }
         }
         catch(error:Error)
         {
            return false;
         }
         return true;
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(this.contentChanged)
         {
            this.contentChanged = false;
            if(this._autoLoad)
            {
               this.load(this._source);
            }
         }
      }
      
      override protected function measure() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         super.measure();
         if(this.isContentLoaded)
         {
            _loc1_ = this.contentHolder.scaleX;
            _loc2_ = this.contentHolder.scaleY;
            this.contentHolder.scaleX = 1;
            this.contentHolder.scaleY = 1;
            measuredWidth = this.contentHolderWidth;
            measuredHeight = this.contentHolderHeight;
            this.contentHolder.scaleX = _loc1_;
            this.contentHolder.scaleY = _loc2_;
         }
         else if(!this._source || this._source == "")
         {
            measuredWidth = 0;
            measuredHeight = 0;
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:Class = null;
         super.updateDisplayList(param1,param2);
         if(this.contentChanged)
         {
            this.contentChanged = false;
            if(this._autoLoad)
            {
               this.load(this._source);
            }
         }
         if(this.isContentLoaded)
         {
            if(this._scaleContent && !this.brokenImage)
            {
               this.doScaleContent();
            }
            else
            {
               this.doScaleLoader();
            }
            this.scaleContentChanged = false;
            if(this.smoothBitmapContentChanged)
            {
               this.doSmoothBitmapContent();
               this.smoothBitmapContentChanged = false;
            }
         }
         if(this.brokenImage && !this.brokenImageBorder)
         {
            _loc3_ = getStyle("brokenImageBorderSkin");
            if(_loc3_)
            {
               this.brokenImageBorder = IFlexDisplayObject(new _loc3_());
               if(this.brokenImageBorder is ISimpleStyleClient)
               {
                  ISimpleStyleClient(this.brokenImageBorder).styleName = this;
               }
               addChild(DisplayObject(this.brokenImageBorder));
            }
         }
         else if(!this.brokenImage && this.brokenImageBorder)
         {
            removeChild(DisplayObject(this.brokenImageBorder));
            this.brokenImageBorder = null;
         }
         if(this.brokenImageBorder)
         {
            this.brokenImageBorder.setActualSize(param1,param2);
         }
         this.sizeShield();
      }
      
      public function load(param1:Object = null) : void
      {
         if(param1)
         {
            this._source = param1;
         }
         this.unloadContent();
         this.isContentLoaded = false;
         this.brokenImage = false;
         this.useUnloadAndStop = false;
         this.contentChanged = false;
         if(!this._source || this._source == "")
         {
            return;
         }
         this.loadContent(this._source);
      }
      
      public function unloadAndStop(param1:Boolean = true) : void
      {
         this.useUnloadAndStop = true;
         this.unloadAndStopGC = param1;
         this.source = null;
         if(!this.autoLoad)
         {
            this.load(null);
         }
      }
      
      public function getVisibleApplicationRect(param1:Boolean = false) : Rectangle
      {
         var _loc2_:Rectangle = getVisibleRect();
         if(param1)
         {
            _loc2_ = systemManager.getVisibleApplicationRect(_loc2_);
         }
         return _loc2_;
      }
      
      private function unloadContent() : void
      {
         var imageData:Bitmap = null;
         var contentLoader:Loader = null;
         var request:SWFBridgeEvent = null;
         if(this.contentHolder)
         {
            if(this.isContentLoaded)
            {
               if(this.contentHolder is Loader)
               {
                  contentLoader = Loader(this.contentHolder);
                  try
                  {
                     if(contentLoader.content is Bitmap)
                     {
                        imageData = Bitmap(contentLoader.content);
                        if(imageData.bitmapData)
                        {
                           imageData.bitmapData = null;
                        }
                     }
                  }
                  catch(error:Error)
                  {
                  }
                  if(this._swfBridge)
                  {
                     request = new SWFBridgeEvent(SWFBridgeEvent.BRIDGE_APPLICATION_UNLOADING,false,false,this._swfBridge);
                     this._swfBridge.dispatchEvent(request);
                  }
                  if(contentLoader.contentLoaderInfo.contentType == "application/x-shockwave-flash" && contentLoader.contentLoaderInfo.parentAllowsChild && contentLoader.contentLoaderInfo.childAllowsParent && contentLoader.content)
                  {
                     contentLoader.content.removeEventListener(Request.GET_PARENT_FLEX_MODULE_FACTORY_REQUEST,this.contentHolder_getFlexModuleFactoryRequestHandler);
                  }
                  this.contentHolder.removeEventListener(Event.ADDED,this.contentHolder_addedHandler);
                  this.removeInitSystemManagerCompleteListener(contentLoader.contentLoaderInfo);
                  if(this.useUnloadAndStop)
                  {
                     contentLoader.unloadAndStop(this.unloadAndStopGC);
                  }
                  else
                  {
                     contentLoader.unload();
                  }
                  if(!this.explicitLoaderContext)
                  {
                     this._loaderContext = null;
                  }
               }
               else if(this.contentHolder is Bitmap)
               {
                  imageData = Bitmap(this.contentHolder);
                  if(imageData.bitmapData)
                  {
                     imageData.bitmapData = null;
                  }
               }
            }
            else if(this.contentHolder is Loader)
            {
               try
               {
                  Loader(this.contentHolder).close();
               }
               catch(error:Error)
               {
               }
            }
            try
            {
               if(this.contentHolder.parent == this)
               {
                  removeChild(this.contentHolder);
               }
            }
            catch(error:Error)
            {
               try
               {
                  removeChild(mx_internal::contentHolder);
               }
               catch(error1:Error)
               {
               }
            }
            this.contentHolder = null;
         }
      }
      
      private function loadContent(param1:Object) : void
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:Class = null;
         var _loc4_:String = null;
         var _loc5_:ByteArray = null;
         var _loc6_:Loader = null;
         var _loc7_:LoaderContext = null;
         var _loc8_:String = null;
         var _loc9_:ApplicationDomain = null;
         var _loc10_:ApplicationDomain = null;
         var _loc11_:ApplicationDomain = null;
         var _loc12_:String = null;
         if(param1 is Class)
         {
            _loc3_ = Class(param1);
         }
         else if(param1 is String)
         {
            try
            {
               _loc3_ = Class(systemManager.getDefinitionByName(String(param1)));
            }
            catch(e:Error)
            {
            }
            _loc4_ = String(param1);
         }
         else if(param1 is ByteArray)
         {
            _loc5_ = ByteArray(param1);
         }
         else
         {
            _loc4_ = param1.toString();
         }
         if(_loc3_)
         {
            this.contentHolder = _loc2_ = new _loc3_();
            this.contentHolder.addEventListener(Event.ADDED,this.contentHolder_addedHandler,false,0,true);
            addChild(_loc2_);
            this.contentLoaded();
         }
         else if(param1 is DisplayObject)
         {
            addChild(this.contentHolder = DisplayObject(param1));
            this.contentLoaded();
            this.contentHolder.addEventListener(Request.GET_PARENT_FLEX_MODULE_FACTORY_REQUEST,this.contentHolder_getFlexModuleFactoryRequestHandler);
         }
         else if(_loc5_)
         {
            _loc6_ = new FlexLoader();
            addChild(this.contentHolder = _loc6_);
            _loc6_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.contentLoaderInfo_completeEventHandler);
            _loc6_.contentLoaderInfo.addEventListener(Event.INIT,this.contentLoaderInfo_initEventHandler);
            _loc6_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.contentLoaderInfo_ioErrorEventHandler);
            _loc6_.contentLoaderInfo.addEventListener(Event.UNLOAD,this.contentLoaderInfo_unloadEventHandler);
            _loc6_.loadBytes(_loc5_,this.loaderContext);
         }
         else
         {
            if(!_loc4_)
            {
               _loc12_ = resourceManager.getString("controls","notLoadable",[this.source]);
               throw new Error(_loc12_);
            }
            _loc6_ = new FlexLoader();
            this.contentHolder = _loc2_ = _loc6_;
            addChild(_loc6_);
            _loc6_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.contentLoaderInfo_completeEventHandler);
            _loc6_.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.contentLoaderInfo_httpStatusEventHandler);
            _loc6_.contentLoaderInfo.addEventListener(Event.INIT,this.contentLoaderInfo_initEventHandler);
            _loc6_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.contentLoaderInfo_ioErrorEventHandler);
            _loc6_.contentLoaderInfo.addEventListener(Event.OPEN,this.contentLoaderInfo_openEventHandler);
            _loc6_.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.contentLoaderInfo_progressEventHandler);
            _loc6_.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.contentLoaderInfo_securityErrorEventHandler);
            _loc6_.contentLoaderInfo.addEventListener(Event.UNLOAD,this.contentLoaderInfo_unloadEventHandler);
            if(Capabilities.isDebugger == true && _loc4_.indexOf(".jpg") == -1 && LoaderUtil.normalizeURL(FlexGlobals.topLevelApplication.systemManager.loaderInfo).indexOf("debug=true") > -1)
            {
               _loc4_ += _loc4_.indexOf("?") > -1 ? "&debug=true" : "?debug=true";
            }
            if(!(_loc4_.indexOf(":") > -1 || _loc4_.indexOf("/") == 0 || _loc4_.indexOf("\\") == 0))
            {
               if(SystemManagerGlobals.bootstrapLoaderInfoURL != null && SystemManagerGlobals.bootstrapLoaderInfoURL != "")
               {
                  _loc8_ = SystemManagerGlobals.bootstrapLoaderInfoURL;
               }
               else if(root)
               {
                  _loc8_ = LoaderUtil.normalizeURL(root.loaderInfo);
               }
               else if(systemManager)
               {
                  _loc8_ = LoaderUtil.normalizeURL(DisplayObject(systemManager).loaderInfo);
               }
               _loc4_ = LoaderUtil.OSToPlayerURI(_loc4_,LoaderUtil.isLocal(!!_loc8_ ? _loc8_ : _loc4_));
               if(_loc8_)
               {
                  _loc4_ = LoaderUtil.createAbsoluteURL(_loc8_,_loc4_);
               }
            }
            else
            {
               _loc4_ = LoaderUtil.OSToPlayerURI(_loc4_,LoaderUtil.isLocal(_loc4_));
            }
            this.requestedURL = new URLRequest(_loc4_);
            if(!(_loc7_ = this.loaderContext))
            {
               _loc7_ = new LoaderContext();
               this._loaderContext = _loc7_;
               if(moduleFactory && FlexVersion.compatibilityVersion >= FlexVersion.VERSION_4_0)
               {
                  _loc9_ = moduleFactory.info()["currentDomain"];
               }
               else
               {
                  _loc9_ = ApplicationDomain.currentDomain;
               }
               if(this.loadForCompatibility)
               {
                  _loc10_ = _loc9_.parentDomain;
                  _loc11_ = null;
                  while(_loc10_)
                  {
                     _loc11_ = _loc10_;
                     _loc10_ = _loc10_.parentDomain;
                  }
                  _loc7_.applicationDomain = new ApplicationDomain(_loc11_);
               }
               if(this.trustContent)
               {
                  _loc7_.securityDomain = SecurityDomain.currentDomain;
               }
               else if(!this.loadForCompatibility)
               {
                  this.attemptingChildAppDomain = true;
                  _loc7_.applicationDomain = new ApplicationDomain(_loc9_);
               }
            }
            _loc6_.load(this.requestedURL,_loc7_);
         }
         if(this.contentHolder && this.contentHolder is ILayoutDirectionElement)
         {
            ILayoutDirectionElement(this.contentHolder).layoutDirection = null;
         }
         invalidateDisplayList();
      }
      
      protected function contentLoaded() : void
      {
         var loaderInfo:LoaderInfo = null;
         this.isContentLoaded = true;
         if(this.contentHolder is Loader)
         {
            loaderInfo = Loader(this.contentHolder).contentLoaderInfo;
         }
         this.resizableContent = false;
         if(loaderInfo)
         {
            if(loaderInfo.contentType == "application/x-shockwave-flash")
            {
               this.resizableContent = true;
            }
            if(this.resizableContent)
            {
               try
               {
                  if(Loader(this.contentHolder).content is IFlexDisplayObject)
                  {
                     this.flexContent = true;
                  }
                  else
                  {
                     this.flexContent = this.swfBridge != null;
                  }
               }
               catch(e:Error)
               {
                  flexContent = swfBridge != null;
               }
            }
         }
         try
         {
            if(tabChildren && this.contentHolder is Loader && (loaderInfo.contentType == "application/x-shockwave-flash" || Loader(this.contentHolder).content is DisplayObjectContainer))
            {
               Loader(this.contentHolder).tabChildren = true;
               DisplayObjectContainer(Loader(this.contentHolder).content).tabChildren = true;
            }
         }
         catch(e:Error)
         {
         }
         invalidateSize();
         invalidateDisplayList();
      }
      
      private function doScaleContent() : void
      {
         var interiorWidth:Number = NaN;
         var interiorHeight:Number = NaN;
         var contentWidth:Number = NaN;
         var contentHeight:Number = NaN;
         var x:Number = NaN;
         var y:Number = NaN;
         var newXScale:Number = NaN;
         var newYScale:Number = NaN;
         var scale:Number = NaN;
         var w:Number = NaN;
         var h:Number = NaN;
         var holder:Loader = null;
         var sizeSet:Boolean = false;
         var lInfo:LoaderInfo = null;
         if(!this.isContentLoaded)
         {
            return;
         }
         if(!this.resizableContent || this.maintainAspectRatio && !this.flexContent)
         {
            this.unScaleContent();
            interiorWidth = unscaledWidth;
            interiorHeight = unscaledHeight;
            contentWidth = this.contentHolderWidth;
            contentHeight = this.contentHolderHeight;
            x = 0;
            y = 0;
            newXScale = contentWidth == 0 ? Number(1) : Number(interiorWidth / contentWidth);
            newYScale = contentHeight == 0 ? Number(1) : Number(interiorHeight / contentHeight);
            if(this._maintainAspectRatio)
            {
               if(newXScale > newYScale)
               {
                  x = Math.floor((interiorWidth - contentWidth * newYScale) * this.getHorizontalAlignValue());
                  scale = newYScale;
               }
               else
               {
                  y = Math.floor((interiorHeight - contentHeight * newXScale) * this.getVerticalAlignValue());
                  scale = newXScale;
               }
               this.contentHolder.scaleX = scale;
               this.contentHolder.scaleY = scale;
            }
            else
            {
               this.contentHolder.scaleX = newXScale;
               this.contentHolder.scaleY = newYScale;
            }
            this.contentHolder.x = x;
            this.contentHolder.y = y;
         }
         else
         {
            this.contentHolder.x = 0;
            this.contentHolder.y = 0;
            w = unscaledWidth;
            h = unscaledHeight;
            if(this.contentHolder is Loader)
            {
               holder = Loader(this.contentHolder);
               try
               {
                  if(this.getContentSize().x > 0)
                  {
                     sizeSet = false;
                     if(holder.contentLoaderInfo.contentType == "application/x-shockwave-flash")
                     {
                        if(this.childAllowsParent)
                        {
                           if(holder.content is IFlexDisplayObject)
                           {
                              IFlexDisplayObject(holder.content).setActualSize(w,h);
                              sizeSet = true;
                           }
                        }
                        if(!sizeSet && this.swfBridge)
                        {
                           this.swfBridge.dispatchEvent(new SWFBridgeRequest(SWFBridgeRequest.SET_ACTUAL_SIZE_REQUEST,false,false,null,{
                              "width":w,
                              "height":h
                           }));
                           sizeSet = true;
                        }
                     }
                     if(!sizeSet)
                     {
                        lInfo = holder.contentLoaderInfo;
                        if(lInfo)
                        {
                           this.contentHolder.scaleX = w / lInfo.width;
                           this.contentHolder.scaleY = h / lInfo.height;
                        }
                        else
                        {
                           this.contentHolder.width = w;
                           this.contentHolder.height = h;
                        }
                     }
                  }
                  else if(this.childAllowsParent && !(holder.content is IFlexDisplayObject))
                  {
                     this.contentHolder.width = w;
                     this.contentHolder.height = h;
                  }
               }
               catch(error:Error)
               {
                  mx_internal::contentHolder.width = w;
                  mx_internal::contentHolder.height = h;
               }
               if(!this.parentAllowsChild)
               {
                  this.contentHolder.scrollRect = new Rectangle(0,0,w / this.contentHolder.scaleX,h / this.contentHolder.scaleY);
               }
            }
            else
            {
               this.contentHolder.width = w;
               this.contentHolder.height = h;
            }
         }
      }
      
      private function doScaleLoader() : void
      {
         if(!this.isContentLoaded)
         {
            return;
         }
         this.unScaleContent();
         var _loc1_:Number = unscaledWidth;
         var _loc2_:Number = unscaledHeight;
         if(this.contentHolderWidth > _loc1_ || this.contentHolderHeight > _loc2_ || !this.parentAllowsChild)
         {
            this.contentHolder.scrollRect = new Rectangle(0,0,_loc1_,_loc2_);
         }
         else
         {
            this.contentHolder.scrollRect = null;
         }
         this.contentHolder.x = (_loc1_ - this.contentHolderWidth) * this.getHorizontalAlignValue();
         this.contentHolder.y = (_loc2_ - this.contentHolderHeight) * this.getVerticalAlignValue();
      }
      
      private function doSmoothBitmapContent() : void
      {
         if(this.content is Bitmap)
         {
            (this.content as Bitmap).smoothing = this._smoothBitmapContent;
         }
      }
      
      private function unScaleContent() : void
      {
         this.contentHolder.scaleX = 1;
         this.contentHolder.scaleY = 1;
         this.contentHolder.x = 0;
         this.contentHolder.y = 0;
      }
      
      private function getHorizontalAlignValue() : Number
      {
         var _loc1_:String = getStyle("horizontalAlign");
         if(_loc1_ == "left")
         {
            return 0;
         }
         if(_loc1_ == "right")
         {
            return 1;
         }
         return 0.5;
      }
      
      private function getVerticalAlignValue() : Number
      {
         var _loc1_:String = getStyle("verticalAlign");
         if(_loc1_ == "top")
         {
            return 0;
         }
         if(_loc1_ == "bottom")
         {
            return 1;
         }
         return 0.5;
      }
      
      private function dispatchInvalidateRequest(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:ISystemManager = systemManager;
         var _loc5_:IMarshalSystemManager;
         if(!(_loc5_ = IMarshalSystemManager(systemManager.getImplementation("mx.managers::IMarshalSystemManager"))) || !_loc5_.useSWFBridge())
         {
            return;
         }
         var _loc6_:IEventDispatcher = _loc5_.swfBridgeGroup.parentBridge;
         var _loc7_:uint = 0;
         if(param1)
         {
            _loc7_ |= InvalidateRequestData.PROPERTIES;
         }
         if(param2)
         {
            _loc7_ |= InvalidateRequestData.SIZE;
         }
         if(param3)
         {
            _loc7_ |= InvalidateRequestData.DISPLAY_LIST;
         }
         var _loc8_:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.INVALIDATE_REQUEST,false,false,_loc6_,_loc7_);
         _loc6_.dispatchEvent(_loc8_);
      }
      
      private function initializeHandler(param1:FlexEvent) : void
      {
         if(this.contentChanged)
         {
            this.contentChanged = false;
            if(this._autoLoad)
            {
               this.load(this._source);
            }
         }
      }
      
      private function addedToStageHandler(param1:Event) : void
      {
         systemManager.getSandboxRoot().addEventListener(InterManagerRequest.DRAG_MANAGER_REQUEST,this.mouseShieldHandler,false,0,true);
      }
      
      mx_internal function contentLoaderInfo_completeEventHandler(param1:Event) : void
      {
         if(LoaderInfo(param1.target).loader != this.contentHolder)
         {
            return;
         }
         dispatchEvent(param1);
         this.contentLoaded();
      }
      
      private function contentLoaderInfo_httpStatusEventHandler(param1:HTTPStatusEvent) : void
      {
         dispatchEvent(param1);
      }
      
      private function contentLoaderInfo_initEventHandler(param1:Event) : void
      {
         dispatchEvent(param1);
         var _loc2_:LoaderInfo = LoaderInfo(param1.target);
         this.addInitSystemManagerCompleteListener(_loc2_.loader.contentLoaderInfo);
         if(_loc2_.contentType == "application/x-shockwave-flash" && _loc2_.parentAllowsChild && _loc2_.childAllowsParent && _loc2_.content)
         {
            _loc2_.content.addEventListener(Request.GET_PARENT_FLEX_MODULE_FACTORY_REQUEST,this.contentHolder_getFlexModuleFactoryRequestHandler);
         }
      }
      
      private function addInitSystemManagerCompleteListener(param1:LoaderInfo) : void
      {
         var _loc2_:EventDispatcher = null;
         if(param1.contentType == "application/x-shockwave-flash")
         {
            _loc2_ = param1.sharedEvents;
            _loc2_.addEventListener(SWFBridgeEvent.BRIDGE_NEW_APPLICATION,this.initSystemManagerCompleteEventHandler);
         }
      }
      
      private function removeInitSystemManagerCompleteListener(param1:LoaderInfo) : void
      {
         var _loc2_:EventDispatcher = null;
         if(param1.contentType == "application/x-shockwave-flash")
         {
            _loc2_ = param1.sharedEvents;
            _loc2_.removeEventListener(SWFBridgeEvent.BRIDGE_NEW_APPLICATION,this.initSystemManagerCompleteEventHandler);
         }
      }
      
      private function contentLoaderInfo_ioErrorEventHandler(param1:IOErrorEvent) : void
      {
         this.source = getStyle("brokenImageSkin");
         this.load();
         this.contentChanged = false;
         this.brokenImage = true;
         if(hasEventListener(param1.type))
         {
            dispatchEvent(param1);
         }
         if(this.contentHolder is Loader)
         {
            this.removeInitSystemManagerCompleteListener(Loader(this.contentHolder).contentLoaderInfo);
         }
      }
      
      private function contentLoaderInfo_openEventHandler(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      private function contentLoaderInfo_progressEventHandler(param1:ProgressEvent) : void
      {
         this._bytesTotal = param1.bytesTotal;
         this._bytesLoaded = param1.bytesLoaded;
         dispatchEvent(param1);
      }
      
      private function contentLoaderInfo_securityErrorEventHandler(param1:SecurityErrorEvent) : void
      {
         var _loc2_:LoaderContext = null;
         if(this.attemptingChildAppDomain)
         {
            this.attemptingChildAppDomain = false;
            _loc2_ = new LoaderContext();
            this._loaderContext = _loc2_;
            callLater(this.load);
            return;
         }
         dispatchEvent(param1);
         if(this.contentHolder is Loader)
         {
            this.removeInitSystemManagerCompleteListener(Loader(this.contentHolder).contentLoaderInfo);
         }
      }
      
      private function contentLoaderInfo_unloadEventHandler(param1:Event) : void
      {
         var _loc2_:ISystemManager = null;
         var _loc3_:IMarshalSystemManager = null;
         this.isContentLoaded = false;
         dispatchEvent(param1);
         if(this._swfBridge)
         {
            this._swfBridge.removeEventListener(SWFBridgeRequest.INVALIDATE_REQUEST,this.invalidateRequestHandler);
            _loc2_ = systemManager;
            _loc3_ = IMarshalSystemManager(systemManager.getImplementation("mx.managers::IMarshalSystemManager"));
            _loc3_.removeChildBridge(this._swfBridge);
            this._swfBridge = null;
         }
      }
      
      private function contentHolder_getFlexModuleFactoryRequestHandler(param1:Event) : void
      {
         if("value" in param1)
         {
            param1["value"] = moduleFactory;
         }
      }
      
      private function contentHolder_addedHandler(param1:Event) : void
      {
         if(param1.target == this.contentHolder)
         {
            return;
         }
         if(param1.target is IFlexModuleFactory)
         {
            param1.target.addEventListener(Request.GET_PARENT_FLEX_MODULE_FACTORY_REQUEST,this.contentHolder_getFlexModuleFactoryRequestHandler);
         }
         this.contentHolder.removeEventListener(Event.ADDED,this.contentHolder_addedHandler);
      }
      
      private function initSystemManagerCompleteEventHandler(param1:Event) : void
      {
         var _loc3_:ISystemManager = null;
         var _loc2_:Object = Object(param1);
         if(this.contentHolder is Loader && _loc2_.data == Loader(this.contentHolder).contentLoaderInfo.sharedEvents)
         {
            this._swfBridge = Loader(this.contentHolder).contentLoaderInfo.sharedEvents;
            this.flexContent = true;
            this.unScaleContent();
            _loc3_ = systemManager;
            IMarshalSystemManager(_loc3_.getImplementation("mx.managers::IMarshalSystemManager")).addChildBridge(this._swfBridge,this);
            this.removeInitSystemManagerCompleteListener(Loader(this.contentHolder).contentLoaderInfo);
            this._swfBridge.addEventListener(SWFBridgeRequest.INVALIDATE_REQUEST,this.invalidateRequestHandler);
         }
      }
      
      private function invalidateRequestHandler(param1:Event) : void
      {
         if(param1 is SWFBridgeRequest)
         {
            return;
         }
         var _loc2_:SWFBridgeRequest = SWFBridgeRequest.marshal(param1);
         var _loc3_:uint = uint(_loc2_.data);
         if(_loc3_ & InvalidateRequestData.PROPERTIES)
         {
            invalidateProperties();
         }
         if(_loc3_ & InvalidateRequestData.SIZE)
         {
            invalidateSize();
         }
         if(_loc3_ & InvalidateRequestData.DISPLAY_LIST)
         {
            invalidateDisplayList();
         }
         this.dispatchInvalidateRequest((_loc3_ & InvalidateRequestData.PROPERTIES) != 0,(_loc3_ & InvalidateRequestData.SIZE) != 0,(_loc3_ & InvalidateRequestData.DISPLAY_LIST) != 0);
      }
      
      private function mouseShieldHandler(param1:Event) : void
      {
         if(param1["name"] != "mouseShield")
         {
            return;
         }
         if(!this.isContentLoaded || this.parentAllowsChild)
         {
            return;
         }
         if(param1["value"])
         {
            if(!this.mouseShield)
            {
               this.mouseShield = new Sprite();
               this.mouseShield.graphics.beginFill(0,0);
               this.mouseShield.graphics.drawRect(0,0,100,100);
               this.mouseShield.graphics.endFill();
            }
            if(!this.mouseShield.parent)
            {
               addChild(this.mouseShield);
            }
            this.sizeShield();
         }
         else if(this.mouseShield && this.mouseShield.parent)
         {
            removeChild(this.mouseShield);
         }
      }
      
      private function sizeShield() : void
      {
         if(this.mouseShield && this.mouseShield.parent)
         {
            this.mouseShield.width = unscaledWidth;
            this.mouseShield.height = unscaledHeight;
         }
      }
      
      override public function regenerateStyleCache(param1:Boolean) : void
      {
         var _loc2_:ISystemManager = null;
         var _loc3_:Object = null;
         super.regenerateStyleCache(param1);
         try
         {
            _loc2_ = this.content as ISystemManager;
            if(_loc2_ != null)
            {
               _loc3_ = _loc2_.getImplementation("mx.managers::ISystemManagerChildManager");
               Object(_loc3_).regenerateStyleCache(param1);
            }
         }
         catch(error:Error)
         {
         }
      }
      
      override public function notifyStyleChangeInChildren(param1:String, param2:Boolean) : void
      {
         var _loc3_:ISystemManager = null;
         var _loc4_:Object = null;
         super.notifyStyleChangeInChildren(param1,param2);
         try
         {
            _loc3_ = this.content as ISystemManager;
            if(_loc3_ != null)
            {
               _loc4_ = _loc3_.getImplementation("mx.managers::ISystemManagerChildManager");
               Object(_loc4_).notifyStyleChangeInChildren(param1,param2);
            }
         }
         catch(error:Error)
         {
         }
      }
      
      private function getContentSize() : Point
      {
         var _loc3_:IEventDispatcher = null;
         var _loc4_:SWFBridgeRequest = null;
         var _loc1_:Point = new Point();
         if(!this.contentHolder is Loader)
         {
            return _loc1_;
         }
         var _loc2_:Loader = Loader(this.contentHolder);
         if(_loc2_.contentLoaderInfo.childAllowsParent)
         {
            _loc1_.x = _loc2_.content.width;
            _loc1_.y = _loc2_.content.height;
         }
         else
         {
            _loc3_ = this.swfBridge;
            if(_loc3_)
            {
               _loc4_ = new SWFBridgeRequest(SWFBridgeRequest.GET_SIZE_REQUEST);
               _loc3_.dispatchEvent(_loc4_);
               _loc1_.x = _loc4_.data.width;
               _loc1_.y = _loc4_.data.height;
            }
         }
         if(_loc1_.x == 0)
         {
            _loc1_.x = _loc2_.contentLoaderInfo.width;
         }
         if(_loc1_.y == 0)
         {
            _loc1_.y = _loc2_.contentLoaderInfo.height;
         }
         return _loc1_;
      }
      
      protected function clickHandler(param1:MouseEvent) : void
      {
         if(!enabled)
         {
            param1.stopImmediatePropagation();
            return;
         }
      }
   }
}
