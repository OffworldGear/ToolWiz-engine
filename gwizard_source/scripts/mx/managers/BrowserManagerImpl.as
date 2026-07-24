package mx.managers
{
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import mx.core.FlexGlobals;
   import mx.core.mx_internal;
   import mx.events.BrowserChangeEvent;
   
   use namespace mx_internal;
   
   public class BrowserManagerImpl extends EventDispatcher implements IBrowserManager
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static var instance:IBrowserManager;
       
      
      private var _defaultFragment:String = "";
      
      private var _browserUserAgent:String;
      
      private var _browserPlatform:String;
      
      private var _isFirefoxMac:Boolean;
      
      private var browserMode:Boolean = true;
      
      private var _base:String;
      
      private var _fragment:String;
      
      private var _title:String;
      
      private var _url:String;
      
      public function BrowserManagerImpl()
      {
         var sandboxRoot:Object = null;
         var parent:Object = null;
         super();
         var systemManager:Object = SystemManagerGlobals.topLevelSystemManagers;
         if(systemManager)
         {
            systemManager = systemManager[0];
         }
         if(systemManager)
         {
            sandboxRoot = systemManager.getSandboxRoot();
            if(!sandboxRoot.dispatchEvent(new Event("mx.managers::BrowserManager",false,true)))
            {
               this.browserMode = false;
               return;
            }
            try
            {
               parent = sandboxRoot.parent;
               while(parent)
               {
                  if(sandboxRoot.parent is Stage)
                  {
                     break;
                  }
                  parent = parent.parent;
               }
            }
            catch(e:Error)
            {
               browserMode = false;
               return;
            }
            sandboxRoot.addEventListener("mx.managers::BrowserManager",this.sandboxBrowserManagerHandler,false,0,true);
         }
         try
         {
            ExternalInterface.addCallback("browserURLChange",this.browserURLChangeBrowser);
            ExternalInterface.addCallback("debugTrace",this.debugTrace);
         }
         catch(e:Error)
         {
            browserMode = false;
         }
      }
      
      public static function getInstance() : IBrowserManager
      {
         if(!instance)
         {
            instance = new BrowserManagerImpl();
         }
         return instance;
      }
      
      [Bindable("urlChange")]
      public function get base() : String
      {
         return this._base;
      }
      
      [Bindable("urlChange")]
      public function get fragment() : String
      {
         if(this._fragment && this._fragment.length)
         {
            return this._fragment;
         }
         return this._defaultFragment;
      }
      
      [Bindable("urlChange")]
      public function get title() : String
      {
         return this._title;
      }
      
      [Bindable("urlChange")]
      public function get url() : String
      {
         return this._url;
      }
      
      public function init(param1:String = "", param2:String = "") : void
      {
         if("historyManagementEnabled" in FlexGlobals.topLevelApplication)
         {
            FlexGlobals.topLevelApplication.historyManagementEnabled = false;
         }
         this.setup(param1,param2);
      }
      
      public function initForHistoryManager() : void
      {
         this.setup("","");
      }
      
      private function setup(param1:String, param2:String) : void
      {
         if(!this.browserMode)
         {
            return;
         }
         this._defaultFragment = param1;
         this._url = ExternalInterface.call("BrowserHistory.getURL");
         if(!this._url)
         {
            this.browserMode = false;
            return;
         }
         this._browserUserAgent = ExternalInterface.call("BrowserHistory.getUserAgent");
         this._browserPlatform = ExternalInterface.call("BrowserHistory.getPlatform");
         this._isFirefoxMac = this._browserUserAgent && this._browserPlatform && this._browserUserAgent.indexOf("Firefox") > -1 && this._browserPlatform.indexOf("Mac") > -1;
         var _loc3_:int = this._url.indexOf("#");
         if(_loc3_ == -1 || _loc3_ == this._url.length - 1)
         {
            this._base = this._url;
            this._fragment = "";
            this._title = param2;
            ExternalInterface.call("BrowserHistory.setDefaultURL",param1);
            this.setTitle(param2);
         }
         else
         {
            this._base = this._url.substring(0,_loc3_);
            this._fragment = this._url.substring(_loc3_ + 1);
            this._title = ExternalInterface.call("BrowserHistory.getTitle");
            ExternalInterface.call("BrowserHistory.setDefaultURL",this._fragment);
            if(this._fragment != this._defaultFragment)
            {
               this.browserURLChange(this._fragment,true);
            }
         }
      }
      
      public function setFragment(param1:String) : void
      {
         var _loc4_:URLRequest = null;
         if(!this.browserMode)
         {
            return;
         }
         var _loc2_:String = this._url;
         var _loc3_:String = this._fragment;
         this._url = this.base + "#" + param1;
         this._fragment = param1;
         if(dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.APPLICATION_URL_CHANGE,false,true,this._url,_loc2_)))
         {
            if(!this._isFirefoxMac)
            {
               ExternalInterface.call("BrowserHistory.setBrowserURL",param1,ExternalInterface.objectID);
            }
            else
            {
               _loc4_ = new URLRequest("javascript:BrowserHistory.setBrowserURL(\'" + param1 + "\',\'" + ExternalInterface.objectID + "\');");
               navigateToURL(_loc4_,"_self");
            }
            dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.URL_CHANGE,false,false,this._url,_loc2_));
         }
         else
         {
            this._fragment = _loc3_;
            this._url = _loc2_;
         }
      }
      
      public function setTitle(param1:String) : void
      {
         if(!this.browserMode)
         {
            return;
         }
         ExternalInterface.call("BrowserHistory.setTitle",param1);
         this._title = ExternalInterface.call("BrowserHistory.getTitle");
      }
      
      private function browserURLChangeBrowser(param1:String) : void
      {
         this.browserURLChange(param1,false);
      }
      
      private function browserURLChange(param1:String, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         if(param1 != null && decodeURI(this._fragment) != decodeURI(param1) || param2)
         {
            this._fragment = param1;
            _loc3_ = this.url;
            this._url = this._base + "#" + param1;
            dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.BROWSER_URL_CHANGE,false,false,this.url,_loc3_));
            dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.URL_CHANGE,false,false,this.url,_loc3_));
         }
      }
      
      private function sandboxBrowserManagerHandler(param1:Event) : void
      {
         param1.preventDefault();
      }
      
      private function debugTrace(param1:String) : void
      {
         trace(param1);
      }
   }
}
