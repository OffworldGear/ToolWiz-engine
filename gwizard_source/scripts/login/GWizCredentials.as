package login
{
   import bubbletip.GWizLoginWizard;
   import chimp.GWizMailChimp;
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import configinfo.GWizSetupFiles;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import session.CheckoutService;
   import session.Session;
   import utils.GATracker;
   import utils.GWizCrypto;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   public class GWizCredentials implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizCredentials");
      
      private static var sessionRPC:GWizSessionSvc = null;
      
      public static const GWC_LIST:String = "e7792a0a08";
      
      public static const GWE_LIST:String = "14cf766383";
      
      public static const GWSF_LIST:String = "d309bbfaa3";
      
      public static const CRITICAL_MASS_LIST:String = "24cb528360";
      
      public static var LoginParm:String = null;
      
      public static var appTrialSubscList:String = GWE_LIST;
      
      public static var checkGWizardUpdates:Function = null;
      
      public static var forceUpgrade:Function = null;
      
      public static var isBeta:Boolean = false;
      
      public static const AUTHENTICATE_PERIOD:Number = 28 * 24 * 60 * 60 * 1000;
      
      public static const CONNECT_WARN_PERIOD:Number = 25 * 24 * 60 * 60 * 1000;
      
      public static const REG_GRACE_PERIOD:Number = 1 * 24 * 60 * 60 * 1000;
      
      public static const CRED_NOT_CHECKED:int = 0;
      
      public static const CRED_NO_COOKIES:int = 1;
      
      public static const CRED_NO_INTERNET:int = 2;
      
      public static const CRED_NO_GRACE:int = 3;
      
      public static const CRED_UNPAID_NOTRIAL:int = 4;
      
      public static const CRED_OK_GRACE:int = 5;
      
      public static const CRED_OK:int = 6;
      
      public static const MAX_TRIAL_LOGINS:int = 100;
      
      private static var _1193753888credStatus:int = CRED_NOT_CHECKED;
      
      public static var loginConfirmed:Function;
      
      private static var _824145376macAddr:String = "XXX UNKNOWN XXX";
      
      private static var timeRunningOutAlert:Boolean = false;
      
      private static var internetMsgShown:Boolean = false;
      
      public static var ForceConnectTimeout:Boolean = false;
      
      public static var internetConnectRequired:Boolean = false;
      
      private static var startupTime:Date = new Date();
      
      private static var _checkinComplete:Boolean = false;
      
      public static var gotCheckinResult:Function = null;
      
      public static var checkinResultMsg:String = "";
      
      public static var timeCheckOK:Boolean = true;
      
      private static var clockErrorShown:Boolean = false;
      
      public static var badConnection:Boolean = false;
      
      public static const LOGIN_PAD_LEN:int = 50;
      
      private static var lastGWLiteTime:Date = null;
      
      private static var lastGWLite:Boolean = false;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      public var checkSecurityFails:Boolean = true;
      
      private var credSets:int = 0;
      
      private const USE_DYNAMO_LOGIN:Boolean = false;
      
      private var reportedTrialLoginsThisSession:Boolean = false;
      
      private var trialDuration:int = 0;
      
      private const TRY_MAILCHIMP:Boolean = false;
      
      private var sessionResult:Boolean = false;
      
      private var sessionProvisions:ArrayCollection = null;
      
      private var sessionTrialDaysLeft:Number = NaN;
      
      private var sessionSubscDaysLeft:Number = NaN;
      
      private var lastCheckedCredentials:String = null;
      
      private var lastCheckedResult:Boolean = false;
      
      private const NOT_REGISTERED:Boolean = false;
      
      private const REGISTERED:Boolean = true;
      
      private var subscriber:Boolean = false;
      
      public var tcMsg:String = "";
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizCredentials()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         GWizSessionSvc.gotCheckinResult = this.defGotCheckinResult;
         sessionRPC = new GWizSessionSvc();
      }
      
      private static function setLoginConfirmed(param1:String, param2:Boolean = false) : void
      {
         if(loginConfirmed != null && param1 != "No Internet Grace Period")
         {
            loginConfirmed(param1,param2);
         }
      }
      
      public static function timeSinceAuth(param1:Boolean = false) : Number
      {
         var _loc4_:Date = null;
         var _loc5_:Number = NaN;
         var _loc2_:Date = new Date();
         var _loc3_:String = GWizSettings.prefs.authenticateDate;
         if(_loc3_ == "")
         {
            param1 = true;
         }
         else
         {
            _loc4_ = new Date(_loc3_);
            _loc5_ = _loc2_.valueOf() - _loc4_.valueOf();
         }
         if(param1)
         {
            _loc5_ = AUTHENTICATE_PERIOD + 1;
         }
         return _loc5_;
      }
      
      public static function set checkinComplete(param1:Boolean) : void
      {
         _checkinComplete = param1;
      }
      
      public static function get checkinComplete() : Boolean
      {
         return _checkinComplete;
      }
      
      public static function noConnection(param1:FaultEvent) : void
      {
         ++GWizSettings.connectionFails;
         if(!badConnection)
         {
            GWizUtils.LogError("Internet connection error: \'" + param1.fault.faultString + "\'");
            if(GWizSessionSvc.checkinFailed || GWizCredentials.checkinResultMsg == "HTTP request error")
            {
               badConnection = true;
               checkGWizardUpdates();
            }
         }
      }
      
      public static function hashedLogin() : String
      {
         return GWizCrypto.hash(GWizCredentials.LoginParm,Session.sessionPassword,Session.sessionStrlen);
      }
      
      private static function adjustEarliestTrial(param1:Number) : Number
      {
         var _loc2_:Date = new Date(GWizSettings.loginBar.earliestTrial);
         var _loc3_:Date = new Date();
         var _loc4_:Number = 0;
         if(_loc3_.valueOf() < _loc2_.valueOf())
         {
            _loc4_ = 30;
         }
         else
         {
            _loc4_ = (_loc4_ = _loc2_.valueOf() - _loc3_.valueOf()) / GWizUtils.MILLI_PER_DAY;
            _loc4_ = 30 + _loc4_;
            _loc4_ = Math.max(0,_loc4_);
         }
         param1 = Math.max(param1,_loc4_);
         if(_loc4_ > 0)
         {
            _loc3_.setTime(_loc3_.valueOf() + param1 * GWizUtils.MILLI_PER_DAY);
            GWizProvisions.setProvisionEndDate(GWizSettings.loginBar.appProvParm,_loc3_);
         }
         var _loc5_:String;
         if((_loc5_ = GWizProvisions.provisionValue("GWCL")).length > 0 && GWizSettings.loginBar.appProvParm == "GWC")
         {
            param1 = 0;
         }
         return param1;
      }
      
      public static function isPITA() : Boolean
      {
         var _loc2_:String = null;
         var _loc1_:Boolean = false;
         if(GWizProvisions.provisionsLoaded)
         {
            _loc2_ = GWizProvisions.provisionValue(GWizProvisions.GW_PITA);
            if(_loc2_)
            {
               _loc1_ = true;
            }
         }
         return _loc1_;
      }
      
      public static function isPayingCustomer(param1:Boolean = true) : Boolean
      {
         return GWizProvisions.provisionDaysLeft(GWizProvisions.appSubscProvision()) > 0 || param1 && isGWLite();
      }
      
      public static function isGWLite() : Boolean
      {
         var _loc3_:String = null;
         var _loc1_:Date = new Date();
         var _loc2_:String = GWizProvisions.provisionValue("GWCL");
         if(_loc2_.length > 0 || GWizSettings.prefs.authenticateType == GWizLoginMgr.LITE_ACCESS)
         {
            if(lastGWLite || !lastGWLiteTime || isNaN(GWizSettings.prefs.lastGWLiteHP) || _loc1_.valueOf() - lastGWLiteTime.valueOf() > 2000)
            {
               if(GWizSettings.loginBar && GWizSettings.loginBar.CheckSecurity(false) && GWizSettings.prefs.authenticateType != GWizLoginMgr.LITE_ACCESS)
               {
                  GWizSettings.prefs.lastGWLiteHP = 999;
               }
               else
               {
                  if(_loc2_ == "" && !isNaN(GWizSettings.prefs.lastGWLiteHP))
                  {
                     _loc2_ = String(GWizSettings.prefs.lastGWLiteHP);
                  }
                  else if(GWizSettings.prefs.authenticateType == GWizLoginMgr.LITE_ACCESS)
                  {
                     _loc2_ = "2";
                  }
                  _loc3_ = GWizProvisions.provisionValue("GWCL");
                  if(_loc3_ != "")
                  {
                     _loc2_ = _loc3_;
                  }
                  GWizSettings.prefs.lastGWLiteHP = Number(_loc2_);
                  if(GWizSettings.prefs.lastGWLiteHP > 100)
                  {
                     GWizSettings.prefs.lastGWLiteHP = 999;
                  }
                  else if(1 <= GWizSettings.prefs.lastGWLiteHP && GWizSettings.prefs.lastGWLiteHP < 3)
                  {
                     GWizSettings.prefs.lastGWLiteHP = 2;
                  }
                  else
                  {
                     GWizSettings.prefs.lastGWLiteHP = 5;
                  }
                  GWizSettings.loginBar.authType = "Lite";
               }
               lastGWLiteTime = _loc1_;
            }
         }
         else if(GWizSettings.prefs.authenticateType == GWizLoginMgr.FULL_ACCESS || GWizSettings.prefs.authenticateType == GWizLoginMgr.TRIAL_ACCESS)
         {
            GWizSettings.prefs.lastGWLiteHP = 1000;
            _loc2_ = "1000";
         }
         else if(GWizSettings.prefs.authenticateType == GWizLoginMgr.LITE_ACCESS)
         {
         }
         lastGWLite = _loc2_.length > 0 && 0 < GWizSettings.prefs.lastGWLiteHP && GWizSettings.prefs.lastGWLiteHP < 999;
         GWizSettings.prefs.liteMode = lastGWLite;
         return lastGWLite;
      }
      
      public static function getConnectStatus() : String
      {
         var _loc1_:Number = timeSinceAuth();
         var _loc2_:Number = GWizSettings.connectionFails;
         return "Last Connect: " + int(_loc1_ / GWizUtils.MILLI_PER_DAY) + " days / " + _loc2_ + " fails";
      }
      
      [Bindable(event="propertyChange")]
      public static function get credStatus() : int
      {
         return GWizCredentials._1193753888credStatus;
      }
      
      public static function set credStatus(param1:int) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCredentials._1193753888credStatus;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCredentials,"credStatus",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get macAddr() : String
      {
         return GWizCredentials._824145376macAddr;
      }
      
      public static function set macAddr(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCredentials._824145376macAddr;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCredentials,"macAddr",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      private function setCredStatus(param1:int) : void
      {
         log.debug("setCredStatus = " + param1);
         if(param1 < 6)
         {
            log.debug("gotcha");
         }
         credStatus = param1;
         if(credStatus == CRED_OK)
         {
            if(!GWizLoginMgr.currentOrPastSubscriber())
            {
               GWizEmailTracker.trackLoginEmail();
            }
         }
         lastGWLiteTime = null;
         ++this.credSets;
      }
      
      public function isRegisteredUser() : Boolean
      {
         var _loc1_:* = false;
         if(checkinComplete && GWizSettings.gotPreferences)
         {
            if(!badConnection)
            {
               _loc1_ = Boolean(GWizProvisions.provisionEndDate(GWizSettings.loginBar.appProvParm) != null || GWizProvisions.provisionEndDate(GWizSettings.loginBar.appProvParm + "S") != null);
            }
            else
            {
               log.debug("In prefs, authenticateType == " + GWizSettings.prefs.authenticateType);
               _loc1_ = GWizSettings.prefs.authenticateType != GWizLoginMgr.NO_ACCESS;
            }
         }
         return _loc1_;
      }
      
      public function checkCredentials() : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:String = null;
         var _loc6_:String = null;
         LoginParm = GWizSpamEmail.convertSpamEmail(LoginParm,"Guest");
         if(this.lastCheckedCredentials == LoginParm && credStatus < CRED_OK_GRACE)
         {
            return this.lastCheckedResult && LoginParm != "Guest";
         }
         var _loc1_:Boolean = false;
         var _loc2_:Date = new Date();
         GWizSetupFiles.serverURL = Session.getBaseUrl();
         if(checkinComplete && GWizSettings.gotPreferences)
         {
            _loc1_ = this.isRegisteredUser();
            if(_loc1_ && !GWizCredentials.badConnection)
            {
               _loc3_ = this.trialLeft(this.REGISTERED,checkinComplete);
               if(GWCredentialMsgs.popTrial(this.REGISTERED,this.subscriber,_loc3_,this.trialDuration,this.checkSecurityFails))
               {
                  if(GWizSettings.gotPreferences && !GWizSettings.prefs.authenticateDate || GWizSettings.prefs.authenticateDate == "")
                  {
                     if(GWizSettings.loginBar.appProvParm != "GWC")
                     {
                        if(GWizSettings.loginBar.appProvParm != "GWE")
                        {
                           if(GWizSettings.loginBar.appProvParm == "CM")
                           {
                           }
                        }
                     }
                     GATracker.logPageView("FirstLogin","FirstLogin");
                  }
                  if((_loc4_ = (_loc4_ = (_loc4_ = timeSinceAuth() / 1000) / 3600) / 24) > 1)
                  {
                     GATracker.logPageView("TimeSinceAuth/" + String(int(_loc4_)),"TimeSinceAuth/" + String(int(_loc4_)));
                  }
                  GWizSettings.prefs.authenticateDate = new Date().toString();
                  if(!this.reportedTrialLoginsThisSession)
                  {
                     ++GWizSettings.prefs.logins;
                     if(GWizSettings.prefs.trialLogins >= 0)
                     {
                        if(!GWizLoginMgr.currentOrPastSubscriber())
                        {
                           ++GWizSettings.prefs.trialLogins;
                           if(GWizSettings.prefs.trialLogins % 5 == 0 || GWizSettings.prefs.trialLogins < 5)
                           {
                              GATracker.logPageView("TrialLoginCount" + String(GWizSettings.prefs.trialLogins),"TrialLoginCt" + String(GWizSettings.prefs.trialLogins));
                           }
                           if(GWizSettings.prefs.trialLogins > MAX_TRIAL_LOGINS)
                           {
                              _loc1_ = false;
                           }
                        }
                        else if(GWizSettings.prefs.trialLogins >= 0)
                        {
                           GATracker.logPageView("TotalTrialLoginsCt" + String(GWizSettings.prefs.trialLogins),"TotalTrialLogins" + String(GWizSettings.prefs.trialLogins));
                           GWizSettings.prefs.trialLogins = -1;
                        }
                     }
                     this.reportedTrialLoginsThisSession = true;
                  }
                  this.setCredStatus(CRED_OK);
                  setLoginConfirmed("Session server vouched.");
               }
               else
               {
                  _loc1_ = false;
               }
               if(!_loc1_)
               {
                  GWizSettings.prefs.authenticateDate = "";
                  _loc1_ = false;
                  this.setCredStatus(CRED_UNPAID_NOTRIAL);
                  _loc5_ = "Sorry, your free trial has expired.  You can email CNCCookbook for a new trial via sales@cnccookbook.com.";
                  if(GWizSettings.loginBar.appNameParm == "GWizard")
                  {
                     _loc5_ = "Sorry, your free trial has expired.  You can still use non Feeds/Speeds tabs or email CNCCookbook for a new trial via sales@cnccookbook.com.";
                  }
                  if(GWizSettings.prefs.trialLogins > MAX_TRIAL_LOGINS)
                  {
                     _loc5_ = "Sorry, login failed.  Too many logins.  You can purchase via www.cnccookbook.com.";
                     GATracker.logPageView("TooManyTrialLogins","TooManyTrialLogins");
                  }
                  setLoginConfirmed(_loc5_,true);
                  if(GWizSettings.loginBar.appNameParm != "GWizard")
                  {
                     GWizSettings.loginBar.changeLoginName(GWizLoginBar.GUEST_NAME);
                  }
               }
            }
            else if(badConnection && !this.needInternet())
            {
               _loc1_ = true;
               this.setCredStatus(CRED_OK_GRACE);
            }
            else
            {
               this.setCredStatus(CRED_NO_GRACE);
               GWizLoginWizard.revalidateLogin();
               _loc6_ = "Sorry, login failed. No record of this ID. Make sure your Internet connection is good and try the Register button if you aren\'t registered.";
               if(badConnection)
               {
                  _loc6_ = "Couldn\'t connect for login. Make sure your Internet connection is good and try logging in again.";
               }
               setLoginConfirmed(_loc6_,true);
            }
            this.lastCheckedCredentials = LoginParm;
         }
         else if(LoginParm != "Guest" && !GWizSettings.gotPreferences)
         {
            _loc1_ = true;
            if(ForceConnectTimeout)
            {
               GWizSettings.connectionFails = 1;
            }
            if(this.needInternet())
            {
               _loc1_ = false;
               this.setCredStatus(CRED_NO_INTERNET);
            }
            else
            {
               this.setCredStatus(CRED_OK_GRACE);
               setLoginConfirmed("No Internet Grace Period");
               if(timeSinceAuth(ForceConnectTimeout) >= CONNECT_WARN_PERIOD && !timeRunningOutAlert && !GWizPopUpManager.popupShowing() && GWizSettings.prefs.authenticateDate && GWizSettings.prefs.authenticateDate != "")
               {
                  if(!internetMsgShown)
                  {
                     GWizPopUpManager.Show("G-Wizard needs to connect to the Internet sometime soon!","Warning: Connection Required Soon",GWizPopUpManager.WARN);
                     internetMsgShown = true;
                  }
                  timeRunningOutAlert = true;
               }
            }
         }
         this.lastCheckedResult = _loc1_;
         if(!_loc1_)
         {
         }
         return _loc1_;
      }
      
      public function needInternet() : Boolean
      {
         internetConnectRequired = false;
         if(GWizSettings.gotPreferences && GWizSettings.connectionFails >= 1)
         {
            switch(GWizSettings.prefs.authenticateType)
            {
               case GWizLoginMgr.FULL_ACCESS:
               case GWizLoginMgr.LITE_ACCESS:
               case GWizLoginMgr.TRIAL_ACCESS:
                  internetConnectRequired = timeSinceAuth() > AUTHENTICATE_PERIOD;
                  break;
               default:
                  internetConnectRequired = true;
                  log.debug("authenticateType = " + GWizSettings.prefs.authenticateType);
            }
            this.setCredStatus(CRED_NO_GRACE);
            if(internetConnectRequired)
            {
               if(!internetMsgShown)
               {
                  GWizPopUpManager.Show("G-Wizard needs to connect to the Internet.","Error: Internet Connection Required",GWizPopUpManager.ERROR);
                  internetMsgShown = true;
               }
               ++GWizSettings.longTermConnectFails;
            }
         }
         return internetConnectRequired;
      }
      
      private function defGotCheckinResult(param1:String, param2:Boolean, param3:String, param4:int, param5:ArrayCollection, param6:Number, param7:Number, param8:Number, param9:String) : void
      {
         var _loc10_:FaultEvent = null;
         var _loc11_:GWizJustASec = null;
         checkinResultMsg = param3;
         if(checkinResultMsg == "HTTP request error")
         {
            badConnection = true;
         }
         else
         {
            badConnection = false;
         }
         param6 = adjustEarliestTrial(param6);
         this.trialDuration = param8;
         this.sessionResult = param2;
         this.sessionProvisions = param5;
         this.sessionTrialDaysLeft = param6;
         this.sessionSubscDaysLeft = param7;
         if(this.TRY_MAILCHIMP && (!param2 || !param5))
         {
            GWizMailChimp.mailChimpTrialResult = this.mailChimpReprieve;
            GWizMailChimp.tryLogin(param1,appTrialSubscList,param9);
         }
         else
         {
            GWizProvisions.setProvisionsAsAC(param5);
            GWizProvisions.setOtherGlobals(Math.max(0,param6),Math.max(0,param7),param9);
            checkinComplete = true;
            _loc11_ = new GWizJustASec(this.waitForTimeCheck);
         }
         if(gotCheckinResult != null)
         {
            gotCheckinResult();
         }
      }
      
      private function waitForTimeCheck() : void
      {
         var _loc1_:GWizJustASec = null;
         switch(GWizSysTimeCheck.timeCheckResult)
         {
            case GWizSysTimeCheck.NOT_TESTED:
               _loc1_ = new GWizJustASec(this.waitForTimeCheck);
               break;
            case GWizSysTimeCheck.TIME_BAD:
               timeCheckOK = false;
               if(!clockErrorShown)
               {
                  GWizPopUpManager.Show("Your system clock is off by more than 24 hours. Please set it.","Warning: System Clock",GWizPopUpManager.WARN);
                  clockErrorShown = true;
               }
               break;
            case GWizSysTimeCheck.TIME_ERROR:
               log.debug("System clock time check fails");
               break;
            case GWizSysTimeCheck.TIME_OK:
               break;
            default:
               GWizUtils.assert(false);
         }
      }
      
      private function mailChimpReprieve(param1:Boolean, param2:Date, param3:String, param4:String) : void
      {
         var _loc6_:Date = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Date = null;
         var _loc12_:Date = null;
         var _loc13_:Object = null;
         var _loc5_:Boolean = false;
         if(!param1 || GWizSessionSvc.checkinFailed)
         {
            if(this.sessionResult)
            {
               _loc5_ = false;
            }
         }
         else
         {
            _loc7_ = (_loc6_ = new Date()).getTimezoneOffset() * 60 * 1000;
            _loc6_.setTime(_loc6_.getTime() + _loc7_ + 1 * 60 * 60 * 1000);
            _loc8_ = _loc6_.valueOf();
            _loc10_ = ((_loc9_ = param2.valueOf() + 30 * GWizUtils.MILLI_PER_DAY) - _loc8_) / GWizUtils.MILLI_PER_DAY;
            _loc10_ = adjustEarliestTrial(_loc10_);
            if(isBeta)
            {
               _loc10_ = 30;
            }
            _loc11_ = GWizUtils.addDays(new Date(),-(30 - _loc10_));
            (_loc12_ = new Date()).time = _loc9_;
            if(_loc10_ > 0)
            {
               _loc5_ = true;
               (_loc13_ = new Object()).name = param4;
               _loc13_.startDate = String(_loc11_);
               _loc13_.endDate = String(_loc12_);
               _loc13_.value = 1;
               this.sessionProvisions.addItem(_loc13_);
               GWizProvisions.setProvisionsAsAC(this.sessionProvisions);
               GWizProvisions.setOtherGlobals(_loc10_,0,param4);
               checkinComplete = true;
            }
         }
         if(!_loc5_)
         {
            GWizProvisions.setProvisionsAsAC(this.sessionProvisions);
            GWizProvisions.setOtherGlobals(Math.max(0,this.sessionTrialDaysLeft),Math.max(0,this.sessionSubscDaysLeft));
            checkinComplete = true;
            this.checkCredentials();
         }
      }
      
      private function trialLeft(param1:Boolean, param2:Boolean) : Number
      {
         var _loc3_:Number = NaN;
         var _loc6_:String = null;
         this.subscriber = false;
         if(hashedLogin() == "FMBTHGPCZOJWETIHKDBF")
         {
            GWizUtils.debug = true;
         }
         var _loc4_:Number = GWizProvisions.provisionDaysLeft(GWizSettings.loginBar.appProvParm);
         _loc4_ = adjustEarliestTrial(_loc4_);
         var _loc5_:Number;
         if((_loc5_ = GWizProvisions.provisionDaysLeft(GWizProvisions.appSubscProvision())) <= 0)
         {
            if((_loc6_ = GWizProvisions.provisionValue(GWizSettings.loginBar.appProvParm + "L")) && _loc6_ != "")
            {
               _loc5_ = 30;
            }
         }
         _loc3_ = Math.max(0,_loc4_) + _loc5_;
         if(_loc5_ != 0)
         {
            this.subscriber = true;
         }
         if(isPITA())
         {
            _loc3_ = 0;
         }
         else if(isBeta && GWizProvisions.provisionEndDate(GWizSettings.loginBar.appProvParm))
         {
            _loc3_ = 30;
         }
         return _loc3_;
      }
      
      private function checkoutResult(param1:ResultEvent) : void
      {
         var _loc2_:int = param1.statusCode;
         var _loc3_:XML = param1.result as XML;
      }
      
      private function checkoutFault(param1:FaultEvent) : void
      {
         var _loc2_:int = param1.statusCode;
         var _loc3_:String = param1.fault.faultString;
      }
      
      public function logout() : void
      {
         var _loc1_:CheckoutService = new CheckoutService(this.checkoutResult,this.checkoutFault);
         _loc1_.invoke(GWizCredentials.LoginParm,GWizSettings.loginBar.appNameParm,GWizSettings.appVersion,GWizCredentials.macAddr);
      }
      
      public function tryLogin(param1:String) : void
      {
         checkinComplete = false;
         if(param1 && param1 != "" && param1 != "Guest")
         {
            sessionRPC.tryLogin(param1);
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._bindingEventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.willTrigger(param1);
      }
   }
}
