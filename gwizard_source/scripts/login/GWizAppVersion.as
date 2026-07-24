package login
{
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.filesystem.File;
   import flash.system.Capabilities;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import mx.rpc.http.HTTPService;
   import utils.GWizAppUpdater;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   public class GWizAppVersion
   {
      
      private static const log:ILogger = Log.getLogger("GWizAppVersion");
      
      public static var gotVersion:Boolean = false;
      
      public static var versionNum:Number;
      
      public static var mandatoryNum:Number;
      
      public static var featherDate:Date;
      
      private static var _mandatoryMsg:Boolean = false;
      
      private static const INSTALL_BTN_WIDTH:int = 80;
       
      
      private var feather:Boolean = true;
      
      private var checkVersion:Boolean = true;
      
      public var airFileCreated:Date = null;
      
      public function GWizAppVersion(param1:String, param2:Boolean, param3:Boolean)
      {
         var event:FaultEvent = null;
         var versionRPC:HTTPService = null;
         var appName:String = param1;
         var doFeathering:Boolean = param2;
         var doVersionChecking:Boolean = param3;
         super();
         this.feather = doFeathering;
         this.checkVersion = doVersionChecking;
         try
         {
            versionRPC = new HTTPService();
            versionRPC.url = "http://www.cnccookbook.com/GWizard/" + appName + "version2.xml";
            versionRPC.addEventListener("result",this.versionRPCResult);
            versionRPC.addEventListener("fault",noVersionConnection);
            versionRPC.requestTimeout = 0;
            versionRPC.send();
         }
         catch(e:Error)
         {
            log.debug("Can\'t get version file. Error e = " + e);
            log.debug("Version file = \'" + versionRPC.url);
            noVersionConnection(event);
         }
      }
      
      private static function noVersionConnection(param1:FaultEvent) : void
      {
         log.debug("Version failed:" + param1.message);
         GWizCredentials.noConnection(param1);
      }
      
      public static function get mandatoryMsg() : Boolean
      {
         var _loc1_:Boolean = false;
         return _mandatoryMsg || _loc1_;
      }
      
      public static function set mandatoryMsg(param1:Boolean) : void
      {
         _mandatoryMsg = param1;
      }
      
      public static function showMandatoryMsg(param1:Boolean = true) : Boolean
      {
         if(mandatoryMsg && param1)
         {
            GWizPopUpManager.Show("Sorry, your version of G-Wizard must be updated as soon as possible. Please upgrade to the latest version. We will open the web page with download links when you close this popup.","Mandatory Upgrade!",GWizPopUpManager.OK | GWizPopUpManager.ERROR,GWizSettings.docWindow,mandatoryClose);
         }
         return mandatoryMsg;
      }
      
      private static function mandatoryClose(param1:Event) : void
      {
         GWizUtils.doWebPage("https://support.cnccookbook.com/");
      }
      
      private function versionRPCResult(param1:ResultEvent) : void
      {
         var _loc2_:Object = null;
         if(param1.result.hasOwnProperty("version"))
         {
            _loc2_ = param1.result.version;
            if(Capabilities.os.indexOf("Mac") >= 0)
            {
               if(param1.result.hasOwnProperty("versionMac"))
               {
                  _loc2_ = param1.result.versionMac;
               }
            }
            if(_loc2_.hasOwnProperty("versionNum") && _loc2_.hasOwnProperty("mandatoryNum"))
            {
               versionNum = _loc2_.versionNum;
               mandatoryNum = _loc2_.mandatoryNum;
               if(_loc2_.hasOwnProperty("featherDate"))
               {
                  featherDate = new Date(String(_loc2_.featherDate));
               }
               gotVersion = true;
               this.checkGWizardUpdates();
            }
            else
            {
               log.debug("Bad version RPC result");
               log.debug("versionNum = " + _loc2_.versionNum);
               log.debug("mandatoryNum = " + _loc2_.mandatoryNum);
            }
         }
      }
      
      private function forceUpgrade() : void
      {
         versionNum = 1000000;
         mandatoryNum = 1000000;
         gotVersion = true;
         this.checkGWizardUpdates();
      }
      
      public function checkGWizardUpdates() : void
      {
         var _loc1_:File = null;
         var _loc6_:GWizJustASec = null;
         if(!GWizSettings.loginBar)
         {
            _loc6_ = new GWizJustASec(this.checkGWizardUpdates);
            return;
         }
         _loc1_ = File.applicationDirectory;
         GWizSettings.exeDir = _loc1_.nativePath;
         var _loc2_:int = GWizLoginBar.LoginParm.charCodeAt(0) % 7;
         var _loc3_:Date = new Date();
         var _loc4_:Boolean = false;
         GWizUtils.assert(GWizSettings.loginBar != null);
         var _loc5_:Number = Number(GWizSettings.loginBar.appVersionParm);
         if(!isNaN(mandatoryNum) && this.checkVersion)
         {
            if(!isNaN(_loc5_) && _loc5_ < mandatoryNum)
            {
               mandatoryMsg = true;
               mandatoryMsg = showMandatoryMsg();
               _loc4_ = true;
               GWizAppUpdater.downloadNewVersion = true;
            }
         }
         if(!isNaN(versionNum) && _loc5_ < versionNum)
         {
            if(!(_loc4_ = _loc4_ || !this.feather || GWizSettings.updatePref == GWizSettings.UPDATE_NOW || _loc3_.day >= _loc2_) && featherDate && featherDate.time < _loc3_.time + 7 * 24 * 60 * 60 * 1000)
            {
               _loc4_ = true;
            }
         }
         if(GWizCredentials.badConnection)
         {
            GWizSettings.loginBar.Status.text = "No Internet connection.";
            GWizSettings.loginBar.Status.setStyle("color","#F1AC55");
            GWizSettings.loginBar.installLink.visible = false;
         }
         else if(!_loc4_ || !this.checkVersion)
         {
            GWizSettings.loginBar.Status.text = " v" + GWizSettings.loginBar.appVersionParm + " is current";
            GWizSettings.loginBar.Status.setStyle("color","#DDDDDD");
            GWizSettings.loginBar.installLink.label = "Feedback";
            GWizSettings.loginBar.installLink.visible = false;
            GWizSettings.loginBar.installLink.toolTip = "Give us feedback about this software";
            GWizSettings.loginBar.installLink.setStyle("chromeColor","#4EDE6E");
         }
         else if(_loc4_)
         {
            GWizAppUpdater.downloadNewVersion = true;
            GWizAppUpdater.setupForInstall();
         }
         if(GWizAppUpdater.downloadNewVersion)
         {
            GWizAppUpdater.newVersionDownload(Math.max(mandatoryNum,versionNum));
         }
      }
   }
}
