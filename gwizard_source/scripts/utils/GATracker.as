package utils
{
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.crypto.generateRandomBytes;
   import flash.display.Loader;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.events.UncaughtErrorEvent;
   import flash.net.SharedObject;
   import flash.net.SharedObjectFlushStatus;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import login.GWizEmailTracker;
   import login.GWizLoginBar;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GATracker
   {
      
      private static const log:ILogger = Log.getLogger("GATracker");
      
      private static const LOGGING:Boolean = false;
      
      private static const SMOOTHSPAN_GA_ID:String = "UA-1060932-3";
      
      public static var tracker:GATracker = new GATracker(SMOOTHSPAN_GA_ID);
      
      private static var pageViewQuota:int = 1000;
      
      private static var lastPageViewed:String = "";
      
      private static var loggedMac:Boolean = false;
      
      public static var appParm:String = "";
      
      private static var _os:String = "";
       
      
      private var _so:SharedObject;
      
      private var _loader:Loader;
      
      public var trackingID:String;
      
      public var clientID:String;
      
      public function GATracker(param1:String)
      {
         super();
         if(LOGGING)
         {
            log.debug("GATracker starts");
         }
         this.trackingID = param1;
         if(LOGGING)
         {
            log.debug("trackingID = " + param1);
         }
         if(LOGGING)
         {
            log.debug("obtain the Client ID");
         }
         this.clientID = this._getClientID();
         if(LOGGING)
         {
            log.debug("clientID = " + this.clientID);
         }
      }
      
      public static function logPageView(param1:String, param2:String = "") : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param2 == "")
         {
            param2 = param1;
         }
         if(pageViewQuota < 0 || param1 == lastPageViewed)
         {
            return;
         }
         --pageViewQuota;
         lastPageViewed = param1;
         if(tracker && GWizSettings.loginBar)
         {
            _loc3_ = "";
            if(param1 == "SessionStarted" && !loggedMac && OS() == "Mac/")
            {
               loggedMac = true;
               _loc3_ = "/?Mac=" + GWizEmailTracker.encode(GWizLoginBar.LoginParm);
            }
            else if(param1 == "EmailLogin")
            {
               _loc3_ = "/?login=" + GWizEmailTracker.encode(GWizLoginBar.LoginParm);
            }
            _loc4_ = GWizSettings.loginBar.appProvParm;
            if(GWizAbstractPrefs.isOEM)
            {
               _loc4_ += "OEM" + GWizAbstractPrefs.oemStr;
            }
            if(appParm != "")
            {
               _loc4_ = appParm;
            }
            param1 = "/" + _loc4_ + "/" + OS() + param1 + _loc3_;
            tracker.sendPageview(param1,param2);
         }
      }
      
      private static function OS() : String
      {
         if(_os == "")
         {
            if(Capabilities.os.indexOf("Windows") == -1)
            {
               _os = "Mac/";
            }
            else
            {
               _os = "Win/";
            }
         }
         return _os;
      }
      
      private function onFlushStatus(param1:NetStatusEvent) : void
      {
         this._so.removeEventListener(NetStatusEvent.NET_STATUS,this.onFlushStatus);
         if(LOGGING)
         {
            log.debug("User closed permission dialog...");
         }
         switch(param1.info.code)
         {
            case "SharedObject.Flush.Success":
               if(LOGGING)
               {
                  log.debug("User granted permission, value saved");
               }
               break;
            case "SharedObject.Flush.Failed":
               if(LOGGING)
               {
                  log.debug("User denied permission, value not saved");
               }
         }
      }
      
      private function onLoaderUncaughtError(param1:UncaughtErrorEvent) : void
      {
         var _loc2_:Error = null;
         var _loc3_:ErrorEvent = null;
         if(LOGGING)
         {
            log.debug("onLoaderUncaughtError()");
         }
         if(param1.error is Error)
         {
            _loc2_ = param1.error as Error;
            if(LOGGING)
            {
               log.debug("Error: " + _loc2_);
            }
         }
         else if(param1.error is ErrorEvent)
         {
            _loc3_ = param1.error as ErrorEvent;
            if(LOGGING)
            {
               log.debug("ErrorEvent: " + _loc3_);
            }
         }
         else if(LOGGING)
         {
            log.debug("a non-Error, non-ErrorEvent type was thrown and uncaught");
         }
         this._removeLoaderEventsHook();
      }
      
      private function onLoaderHTTPStatus(param1:HTTPStatusEvent) : void
      {
         if(LOGGING)
         {
            log.debug("onLoaderHTTPStatus()");
         }
         if(LOGGING)
         {
            log.debug("status: " + param1.status);
         }
         if(param1.status == 200)
         {
            if(LOGGING)
            {
               log.debug("the request was accepted");
            }
         }
         else if(LOGGING)
         {
            log.debug("the request was not accepted");
         }
      }
      
      private function onLoaderIOError(param1:IOErrorEvent) : void
      {
         if(LOGGING)
         {
            log.debug("onLoaderIOError()");
         }
         this._removeLoaderEventsHook();
      }
      
      private function onLoaderComplete(param1:Event) : void
      {
         if(LOGGING)
         {
            log.debug("onLoaderComplete()");
         }
         if(LOGGING)
         {
            log.debug("done");
         }
         this._removeLoaderEventsHook();
      }
      
      private function _removeLoaderEventsHook() : void
      {
         this._loader.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.onLoaderUncaughtError);
         this._loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.onLoaderHTTPStatus);
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoaderComplete);
         this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoaderIOError);
      }
      
      private function _generateUUID() : String
      {
         var i:uint = 0;
         var byte:uint = 0;
         var randomBytes:ByteArray = generateRandomBytes(16);
         randomBytes[6] &= 15;
         randomBytes[6] |= 64;
         randomBytes[8] &= 63;
         randomBytes[8] |= 128;
         var toHex:Function = function(param1:uint):String
         {
            var _loc2_:String = param1.toString(16);
            return _loc2_.length > 1 ? _loc2_ : "0" + _loc2_;
         };
         var str:String = "";
         var l:uint = randomBytes.length;
         randomBytes.position = 0;
         i = 0;
         while(i < l)
         {
            byte = randomBytes[i];
            str += toHex(byte);
            i++;
         }
         var uuid:String = "";
         uuid += str.substr(0,8);
         uuid += "-";
         uuid += str.substr(8,4);
         uuid += "-";
         uuid += str.substr(12,4);
         uuid += "-";
         uuid += str.substr(16,4);
         uuid += "-";
         uuid += str.substr(20,12);
         return uuid;
      }
      
      private function _getClientID() : String
      {
         var cid:String = null;
         var flushStatus:String = null;
         if(LOGGING)
         {
            log.debug("Load the SharedObject \'_ga\'");
         }
         this._so = SharedObject.getLocal("_ga");
         if(!this._so.data.clientid)
         {
            if(LOGGING)
            {
               log.debug("CID not found, generate Client ID");
            }
            cid = this._generateUUID();
            if(LOGGING)
            {
               log.debug("Save CID into SharedObject");
            }
            this._so.data.clientid = cid;
            flushStatus = null;
            try
            {
               flushStatus = this._so.flush(1024);
            }
            catch(e:Error)
            {
               if(LOGGING)
               {
                  log.debug("Could not write SharedObject to disk: " + e.message);
               }
            }
            if(flushStatus != null)
            {
               switch(flushStatus)
               {
                  case SharedObjectFlushStatus.PENDING:
                     if(LOGGING)
                     {
                        log.debug("Requesting permission to save object...");
                     }
                     this._so.addEventListener(NetStatusEvent.NET_STATUS,this.onFlushStatus);
                     break;
                  case SharedObjectFlushStatus.FLUSHED:
                     if(LOGGING)
                     {
                        log.debug("Value flushed to disk");
                     }
               }
            }
         }
         else
         {
            if(LOGGING)
            {
               log.debug("CID found, restore from SharedObject");
            }
            cid = this._so.data.clientid;
         }
         return cid;
      }
      
      public function sendPageview(param1:String, param2:String = "") : void
      {
         var page:String = param1;
         var title:String = param2;
         if(LOGGING)
         {
            log.debug("sendPageview()");
         }
         var payload:Array = [];
         payload.push("v=1");
         payload.push("tid=" + this.trackingID);
         payload.push("cid=" + this.clientID);
         payload.push("t=pageview");
         payload.push("dp=" + encodeURIComponent(page));
         if(title && title.length > 0)
         {
            payload.push("dt=" + encodeURIComponent(title));
         }
         var url:String = "";
         url += "http://www.google-analytics.com/collect";
         var request:URLRequest = new URLRequest();
         request.method = URLRequestMethod.GET;
         request.url = url;
         request.data = payload.join("&");
         if(LOGGING)
         {
            log.debug("request is: " + request.url + "?" + request.data);
         }
         this._loader = new Loader();
         this._loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.onLoaderUncaughtError);
         this._loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.onLoaderHTTPStatus);
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaderComplete);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoaderIOError);
         try
         {
            if(LOGGING)
            {
               log.debug("Loader send request");
            }
            this._loader.load(request);
         }
         catch(e:Error)
         {
            if(LOGGING)
            {
               log.debug("unable to load requested page: " + e.message);
            }
            _removeLoaderEventsHook();
         }
      }
   }
}
