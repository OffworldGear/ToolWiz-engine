package login
{
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   public class GWizLoginMgr
   {
      
      private static const log:ILogger = Log.getLogger("GWizLoginMgr");
      
      public static const NO_ACCESS:int = 0;
      
      public static const FREMIUM_ACCESS:int = 1;
      
      public static const TRIAL_ACCESS:int = 2;
      
      public static const LITE_ACCESS:int = 3;
      
      public static const FULL_ACCESS:int = 4;
       
      
      public function GWizLoginMgr()
      {
         super();
         GWizCredentials.gotCheckinResult = this.loginMgrGotCheckinResult;
      }
      
      private static function acceptEULA() : void
      {
         var _loc1_:GWizEULADialog = null;
         if(!GWizSettings.prefs.eulaWasAccepted() && (GWizLoginBar.LoginParm != GWizLoginBar.GUEST_NAME || GWizAbstractPrefs.isOEM))
         {
            GWizEULADialog.eulaAccepted = handleEULAResult;
            _loc1_ = GWizEULADialog(GWizPopUpManager.createPopUp(null,GWizEULADialog,true));
         }
      }
      
      private static function handleEULAResult(param1:Boolean) : void
      {
         GWizSettings.prefs.eulaAccepted = param1;
         if(!param1)
         {
            acceptEULA();
         }
      }
      
      public static function checkLogin() : int
      {
         var _loc1_:int = NO_ACCESS;
         acceptEULA();
         if(GWizSettings.prefs.eulaWasAccepted())
         {
            if(!GWizAppVersion.showMandatoryMsg())
            {
               if(GWizSettings.loginBar.isRegistered())
               {
                  _loc1_ = FREMIUM_ACCESS;
                  if(GWizSettings.loginBar.trialDaysLeft() > 0)
                  {
                     _loc1_ = TRIAL_ACCESS;
                  }
                  if(GWizSettings.loginBar.subscDaysLeft() > 0)
                  {
                     _loc1_ = FULL_ACCESS;
                  }
                  else if(GWizCredentials.isGWLite())
                  {
                     _loc1_ = LITE_ACCESS;
                  }
               }
            }
         }
         if(!GWizSettings.loginBar.credentials.needInternet())
         {
            _loc1_ = Math.max(_loc1_,GWizSettings.prefs.authenticateType);
         }
         GWizSettings.prefs.authenticateType = _loc1_;
         if(GWizAbstractPrefs.isOEM)
         {
            _loc1_ = TRIAL_ACCESS;
         }
         if(GWizUtils.debug)
         {
            log.debug("checkLogin = " + _loc1_);
         }
         return _loc1_;
      }
      
      public static function currentOrPastSubscriber() : Boolean
      {
         var _loc1_:int = NO_ACCESS;
         var _loc2_:String = GWizProvisions.appSubscProvision();
         if(GWizCredentials.badConnection && !GWizSettings.loginBar.credentials.needInternet())
         {
            _loc1_ = GWizSettings.prefs.authenticateType;
         }
         else if(GWizProvisions.provisionStartDate(_loc2_) != null)
         {
            _loc1_ = FULL_ACCESS;
         }
         return _loc1_ == FULL_ACCESS || _loc1_ == LITE_ACCESS;
      }
      
      public function waitForPrefs() : void
      {
         var _loc1_:GWizJustASec = null;
         if(!GWizSettings.gotPreferences || !GWizLoginBar.CCComplete)
         {
            _loc1_ = new GWizJustASec(this.waitForPrefs,-1);
         }
         else if(GWizLoginBar.LoginRequired)
         {
            log.debug("GWizLoginBar.CCComplete = " + GWizLoginBar.CCComplete + ", GWizLoginBar.LoginRequired = " + GWizLoginBar.LoginRequired);
            if(GWizLoginBar.LoginParm != GWizLoginBar.GUEST_NAME)
            {
               this.gotLoginEmail();
            }
            else
            {
               this.popLogin();
            }
         }
      }
      
      private function authenticateLogin() : void
      {
         var _loc1_:GWizJustASec = null;
         if(!GWizSettings.loginBar)
         {
            _loc1_ = new GWizJustASec(this.authenticateLogin,-1);
            return;
         }
         if(GWizSettings.loginBar && GWizSettings.loginBar.credentials && GWizSettings.loginBar.credentials.needInternet())
         {
         }
      }
      
      private function popLogin() : void
      {
         GWizLoginFB.loginMgrLoginDoneCallback = this.gotLoginEmail;
         GWizLoginFB.showLoginFB();
      }
      
      private function gotLoginEmail() : void
      {
         acceptEULA();
         this.authenticateLogin();
      }
      
      private function loginMgrGotCheckinResult() : void
      {
         log.debug("Got a checkin result.");
         acceptEULA();
         GWizSettings.loginBar.CheckSecurity();
      }
   }
}
