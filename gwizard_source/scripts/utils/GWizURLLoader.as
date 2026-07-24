package utils
{
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizURLLoader
   {
      
      private static const log:ILogger = Log.getLogger("GWizURLLoader");
       
      
      public var errMsgs:String = "";
      
      private var loadedFcn:Function = null;
      
      private var url:String = "";
      
      public function GWizURLLoader()
      {
         super();
      }
      
      public static function URLToFilename(param1:String) : String
      {
         var _loc2_:int = param1.length;
         var _loc3_:int = _loc2_;
         while(_loc3_ > 0)
         {
            if(param1.charAt(_loc3_) == "/")
            {
               _loc3_ = Math.min(_loc3_ + 1,param1.length);
               break;
            }
            _loc3_--;
         }
         return param1.substr(_loc3_);
      }
      
      private function completeHandler(param1:Event) : void
      {
         if(this.url.indexOf("M998") >= 0)
         {
            log.debug("gotcha");
         }
         var _loc2_:URLLoader = URLLoader(param1.target);
         var _loc3_:ByteArray = ByteArray(_loc2_.data);
         this.loaded(_loc3_,this.url);
      }
      
      private function openHandler(param1:Event) : void
      {
      }
      
      private function progressHandler(param1:ProgressEvent) : void
      {
      }
      
      private function securityErrorHandler(param1:SecurityErrorEvent) : void
      {
         log.debug("securityErrorHandler: " + param1);
      }
      
      private function httpStatusHandler(param1:HTTPStatusEvent) : void
      {
         log.debug("httpStatusHandler: " + param1);
      }
      
      private function ioErrorHandler(param1:IOErrorEvent) : void
      {
         log.debug("ioErrorHandler: errorID = " + param1.errorID);
         this.loaded(null,this.url);
      }
      
      private function configureListeners(param1:IEventDispatcher) : void
      {
         param1.addEventListener(Event.COMPLETE,this.completeHandler);
         param1.addEventListener(Event.OPEN,this.openHandler);
         param1.addEventListener(ProgressEvent.PROGRESS,this.progressHandler);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityErrorHandler);
         param1.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler);
         param1.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
      }
      
      private function loaded(param1:ByteArray, param2:String) : void
      {
         if(this.loadedFcn != null)
         {
            this.loadedFcn(param1,param2);
         }
      }
      
      public function loadURL(param1:String, param2:Function, param3:Boolean = false) : void
      {
         var url:String = param1;
         var loadedFcn:Function = param2;
         var nocache:Boolean = param3;
         this.errMsgs = "";
         if(nocache && url.indexOf("?") < 0)
         {
            url = url + "?nocache=" + Math.random();
         }
         this.url = url;
         this.loadedFcn = loadedFcn;
         var loader:URLLoader = new URLLoader();
         loader.dataFormat = URLLoaderDataFormat.BINARY;
         this.configureListeners(loader);
         var request:URLRequest = new URLRequest(url);
         if(nocache)
         {
            request.cacheResponse = false;
            request.useCache = false;
         }
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            loaded(null,url);
         }
      }
   }
}
