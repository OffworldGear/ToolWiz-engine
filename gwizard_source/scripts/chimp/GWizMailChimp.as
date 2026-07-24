package chimp
{
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizMailChimp
   {
      
      private static const log:ILogger = Log.getLogger("GWizMailChimp");
      
      public static var gotCheckinResult:Function = null;
      
      private static const MC_API_KEY:String = "a3efff557e1ddb3cbb7159748870c840-us5";
      
      private static const MC_DATA_CENTER:String = "us5";
      
      private static const MC_TRIAL_SUBSCRIPTION_LIST:String = "14cf766383";
      
      private static var theApp:String;
      
      private static var url:String;
      
      private static var lastEmail:String = "";
      
      private static const CHIMP_SUBSCRIBED_RESULT:String = "subscribed";
      
      public static var chimpSuccess:Function = defChimpSuccess;
      
      public static var chimpFailure:Function = defChimpFailure;
      
      public static var mailChimpTrialResult:Function = defMailChimpTrialResult;
      
      public static const LOGIN_EVENT:int = 1;
      
      public static const CONFIG_EVENT:int = 2;
      
      public static const LOGIN_7_EVENT:int = 3;
      
      public static const LOGIN_30_EVENT:int = 4;
      
      public static const TRIAL_EXPIRE:int = 5;
      
      public static const SUBSCRIPTION_EXPIRE:int = 6;
       
      
      public function GWizMailChimp()
      {
         super();
      }
      
      public static function tryLogin(param1:String, param2:String, param3:String) : void
      {
         theApp = param3;
         GWizUtils.assert(param3 != "");
         listMemberInfo(MC_API_KEY,param2,param1);
      }
      
      private static function listMemberInfo(param1:String, param2:String, param3:String, param4:Boolean = false) : void
      {
         var apikey:String = param1;
         var listID:String = param2;
         var emailAddress:String = param3;
         var force:Boolean = param4;
         lastEmail = emailAddress;
         if(lastEmail == "Guest")
         {
            chimpFailure("Guests can\'t subscribe");
            return;
         }
         if(!lastEmail || lastEmail == "")
         {
            chimpFailure("Missing email address");
            return;
         }
         url = "method=listMemberInfo&output=xml&apikey=" + apikey + "&id=" + listID + "&email_address=" + emailAddress;
         var variables:URLVariables = new URLVariables(url);
         var request:URLRequest = new URLRequest();
         request.url = "http://" + MC_DATA_CENTER + ".api.mailchimp.com/1.2/?method=listMemberInfo";
         request.method = URLRequestMethod.POST;
         request.data = variables;
         var loader:URLLoader = new URLLoader();
         loader.dataFormat = URLLoaderDataFormat.TEXT;
         configureListeners(loader);
         try
         {
            log.debug("connectingToAPI");
            loader.load(request);
         }
         catch(error:Error)
         {
            ++GWizSettings.connectionFails;
            chimpFailure("connectionError");
         }
      }
      
      private static function openHandler(param1:Event) : void
      {
         log.debug("openHandler: " + param1);
      }
      
      private static function progressHandler(param1:ProgressEvent) : void
      {
         log.debug("progressHandler loaded:" + param1.bytesLoaded + " total: " + param1.bytesTotal);
      }
      
      private static function securityErrorHandler(param1:SecurityErrorEvent) : void
      {
         log.debug("securityErrorHandler: " + param1);
      }
      
      private static function httpStatusHandler(param1:HTTPStatusEvent) : void
      {
         log.debug("httpStatusHandler: " + param1);
      }
      
      private static function ioErrorHandler(param1:IOErrorEvent) : void
      {
         log.debug("ioErrorHandler: " + param1);
      }
      
      private static function configureListeners(param1:IEventDispatcher) : void
      {
         param1.addEventListener(Event.COMPLETE,completeHandler);
         param1.addEventListener(Event.OPEN,openHandler);
         param1.addEventListener(ProgressEvent.PROGRESS,progressHandler);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
         param1.addEventListener(HTTPStatusEvent.HTTP_STATUS,httpStatusHandler);
         param1.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
      }
      
      private static function completeHandler(param1:Event) : void
      {
         var _loc2_:String = unescape(param1.target.data);
         var _loc3_:XMLList = new XMLList(_loc2_);
         log.debug(_loc3_.@type);
         if(_loc3_.@type == "array")
         {
            log.debug("listMemberInfo Return Value: " + _loc3_.toString());
            if(_loc3_.hasOwnProperty("error"))
            {
               chimpFailure(_loc3_.error);
            }
            else
            {
               chimpSuccess(_loc3_.status,_loc3_.timestamp);
            }
         }
         else if(_loc3_.@type == "boolean")
         {
            log.debug(_loc3_.value);
         }
         else
         {
            log.debug(_loc3_.error);
            chimpFailure(_loc3_.error);
         }
      }
      
      private static function defChimpSuccess(param1:String, param2:String) : void
      {
         var _loc3_:Date = null;
         log.debug("Member status = " + param1);
         log.debug("Timestamp = " + param2);
         if(param1 && param1 == CHIMP_SUBSCRIBED_RESULT && param2 && param2 != "" && mailChimpTrialResult != null)
         {
            _loc3_ = newDateFromMailChimp(param2);
            mailChimpTrialResult(true,_loc3_,"Valid MailChimp trial subscription",theApp);
         }
         else
         {
            defChimpFailure("No Joy");
         }
      }
      
      private static function defChimpFailure(param1:String) : void
      {
         mailChimpTrialResult(false,null,param1,theApp);
      }
      
      private static function newDateFromMailChimp(param1:String) : Date
      {
         var _loc2_:String = param1.substr(0,param1.indexOf(" "));
         var _loc3_:String = _loc2_.substr(0,_loc2_.indexOf("-"));
         _loc2_ = _loc2_.substr(_loc3_.length + 1);
         var _loc4_:String = _loc2_.substr(0,_loc2_.indexOf("-"));
         _loc2_ = _loc2_.substr(_loc4_.length + 1);
         var _loc5_:String = _loc2_;
         var _loc6_:Date = new Date(int(_loc3_),int(_loc4_) - 1,int(_loc5_),0,0,0,0);
         log.debug("d = " + _loc6_);
         return _loc6_;
      }
      
      private static function defMailChimpTrialResult(param1:Boolean, param2:Date, param3:String) : void
      {
         log.debug("MailChimp Trial:  Subscribed = " + param1 + ", Trial Start = " + param2 + ", msg = " + param3);
      }
      
      public static function registerForTrial(param1:String, param2:String, param3:String, param4:String) : void
      {
         listSubscribe(MC_API_KEY,param4,param1,param2,param3);
      }
      
      private static function listSubscribe(param1:String, param2:String, param3:String, param4:String, param5:String) : void
      {
         var apikey:String = param1;
         var listID:String = param2;
         var emailAddress:String = param3;
         var firstName:String = param4;
         var lastName:String = param5;
         url = "method=listSubscribe&output=xml&apikey=" + apikey + "&id=" + listID + "&email_address=" + emailAddress;
         url += "&merge_vars[FNAME]=" + firstName;
         url += "&merge_vars[LNAME]=" + lastName;
         var variables:URLVariables = new URLVariables(url);
         var request:URLRequest = new URLRequest();
         request.url = "http://" + MC_DATA_CENTER + ".api.mailchimp.com/1.2/?method=listSubscribe";
         request.method = URLRequestMethod.POST;
         request.data = variables;
         var loader:URLLoader = new URLLoader();
         loader.dataFormat = URLLoaderDataFormat.TEXT;
         configureListeners(loader);
         try
         {
            log.debug("connectingToAPI");
            loader.load(request);
         }
         catch(error:Error)
         {
            ++GWizSettings.connectionFails;
            chimpFailure("connectionError");
         }
      }
      
      public static function addSegment(param1:String, param2:String, param3:int) : void
      {
      }
      
      public static function delSegment(param1:String, param2:String, param3:int) : void
      {
      }
   }
}
