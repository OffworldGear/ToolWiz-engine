package login
{
   import auth.AuthTest;
   import bubbletip.GWizBubbleTip;
   import bubbletip.GWizGettingStarted;
   import bubbletip.GWizLoginWizard;
   import chimp.GWizMandrill;
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.system.Capabilities;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.primitives.Rect;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizLoginBar extends Group implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizLoginBar");
      
      private static var _LoginParm:String = "";
      
      public static const GW_ESTIMATOR_NAMEPARM:String = "GWEstimator";
      
      private static var _521980408LoginRequired:Boolean = true;
      
      public static var setLogins:Boolean = false;
      
      public static const GUEST_NAME:String = "Guest";
      
      private static var gaveSessionStarted:Boolean = false;
      
      public static var daysLeftOverride:String = "";
      
      public static var popUpgrade:Boolean = true;
      
      public static var CCComplete:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1469606077GettingStarted:Button;
      
      private var _73596745Login:Button;
      
      private var _703929728OfferBtn:GWizOfferBtn;
      
      private var _1808614382Status:Label;
      
      private var _190113873Support:Image;
      
      private var _1397214398Welcome:Label;
      
      public var _GWizLoginBar_ClassFactory1:ClassFactory;
      
      public var _GWizLoginBar_GWizBubbleTip1:GWizBubbleTip;
      
      public var _GWizLoginBar_GWizBubbleTip2:GWizBubbleTip;
      
      public var _GWizLoginBar_GWizBubbleTip3:GWizBubbleTip;
      
      public var _GWizLoginBar_GWizBubbleTip4:GWizBubbleTip;
      
      public var _GWizLoginBar_GWizHelpButton1:GWizHelpButton;
      
      public var _GWizLoginBar_Image2:Image;
      
      public var _GWizLoginBar_SolidColor1:SolidColor;
      
      public var _GWizLoginBar_SolidColorStroke1:SolidColorStroke;
      
      private var _637388150controlBar:HGroup;
      
      private var _1948582142daysLeft:Label;
      
      private var _177720108daysLeftAction:Button;
      
      private var _2143290421installLink:Button;
      
      private var _716438531theSpacer:Spacer;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1287124693backgroundColor:uint = 0;
      
      private var _1675495217labelColor:uint = 16777215;
      
      private var _722830999borderColor:uint;
      
      private var _128489109versionColor:uint = 11184810;
      
      public var appNameParm:String = "";
      
      public var appLongNameParm:String = "";
      
      public var appVersionParm:String = "";
      
      private var _appProvParm:String = "";
      
      public var appInstallURL:String = "";
      
      public var appTrialSubscList:String = "14cf766383";
      
      private var _authType:String = "Unknown";
      
      private var oldAuthType:String = "Unknown";
      
      public var feather:Boolean = true;
      
      public var checkVersion:Boolean = true;
      
      public var checkSecurityFails:Boolean = true;
      
      public var isBeta:Boolean = false;
      
      public var earliestTrial:String = "1/1/2010";
      
      private var _288957180credentials:GWizCredentials = null;
      
      private var _1797554458ShowGettingStarted:Boolean = true;
      
      private var _201260530ShowSupport:Boolean = true;
      
      private var _274186251ShowTips:Boolean = true;
      
      private var _274547714ShowHelp:Boolean = true;
      
      private var checkN:int = 0;
      
      private var _registered:Boolean = false;
      
      private var didGetStarted:Boolean = false;
      
      private var verDetails:GWizVerDetails = null;
      
      private var versionChecker:GWizAppVersion;
      
      private const guestLoginRegister:String = "Login";
      
      private const nonGuestLogout:String = "New Login";
      
      private var _embed_mxml__assets_Support_png_187022828:Class;
      
      private var _embed_mxml__assets_TipBtn_jpg_1455544182:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizLoginBar()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._722830999borderColor = ColorPalette.gray1;
         this._embed_mxml__assets_Support_png_187022828 = GWizLoginBar__embed_mxml__assets_Support_png_187022828;
         this._embed_mxml__assets_TipBtn_jpg_1455544182 = GWizLoginBar__embed_mxml__assets_TipBtn_jpg_1455544182;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizLoginBar_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_login_GWizLoginBarWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizLoginBar[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.height = 40;
         this.mxmlContent = [this._GWizLoginBar_Rect1_c(),this._GWizLoginBar_HGroup1_i()];
         this._GWizLoginBar_ClassFactory1_i();
         this.addEventListener("creationComplete",this.___GWizLoginBar_Group1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set LoginParm(param1:String) : void
      {
         var _loc3_:GWizUserData = null;
         var _loc2_:String = _LoginParm;
         if(!param1)
         {
            param1 = "";
         }
         _LoginParm = GWizStringUtils.zapWhiteSpace(param1);
         _LoginParm = GWizSpamEmail.convertSpamEmail(param1,GUEST_NAME);
         if(_LoginParm.length == 0 || _LoginParm == "")
         {
            _LoginParm = GUEST_NAME;
         }
         GWizCredentials.badConnection = false;
         GWizCredentials.checkinComplete = false;
         if(_LoginParm == GUEST_NAME)
         {
            GWizCredentials.checkinComplete = true;
         }
         if(!GWizCredentials.checkinComplete)
         {
            _loc3_ = GWizUserData.instance();
            if(_loc3_)
            {
               _loc3_.email = _LoginParm;
            }
            GWizCredentials.checkinComplete = false;
            if(GWizSettings.gotPreferences)
            {
               if(GWizSettings.appVersion)
               {
                  GWizSettings.loginBar.authenticateLogin(_LoginParm);
               }
               if(_LoginParm != _loc2_)
               {
                  GWCredentialMsgs.trialPopShown = false;
                  GWizSettings.prefs.authenticateDate = "";
                  GWizSettings.prefs.authenticateType = 0;
                  GWizSettings.prefs.logins = 0;
                  GWizSettings.prefs.trialLogins = 0;
                  GWizSettings.loginBar.resetLoginBar();
               }
            }
            if(GWizSettings.loginBar.guestLogin())
            {
               GWizSettings.loginBar.callLater(GWizSettings.loginBar.doLogin);
            }
         }
      }
      
      public static function get LoginParm() : String
      {
         return _LoginParm;
      }
      
      public static function isGWEstimator() : Boolean
      {
         return GWizSettings.loginBar.appNameParm == GW_ESTIMATOR_NAMEPARM;
      }
      
      public static function checkTransform(param1:Event) : void
      {
         var _loc2_:Image = param1.target as Image;
         if(param1.type == MouseEvent.ROLL_OVER)
         {
            _loc2_.transform.colorTransform = new ColorTransform(1,1,1,0.6);
         }
         else
         {
            _loc2_.transform.colorTransform = new ColorTransform(1,1,1,1);
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizLoginBar._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get LoginRequired() : Boolean
      {
         return GWizLoginBar._521980408LoginRequired;
      }
      
      public static function set LoginRequired(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizLoginBar._521980408LoginRequired;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizLoginBar,"LoginRequired",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      public function get appProvParm() : String
      {
         var _loc1_:String = this._appProvParm;
         if(this.appNameParm == "GWEstimator")
         {
            _loc1_ = "GWC";
         }
         return _loc1_;
      }
      
      public function set appProvParm(param1:String) : void
      {
         this._appProvParm = param1;
      }
      
      public function get authType() : String
      {
         return this._authType;
      }
      
      public function set authType(param1:String) : void
      {
         if(param1 != this.oldAuthType)
         {
            this._authType = param1;
            this.oldAuthType = param1;
         }
      }
      
      private function set registered(param1:Boolean) : void
      {
         this._registered = param1;
      }
      
      private function get registered() : Boolean
      {
         return this._registered;
      }
      
      public function CheckSecurity(param1:Boolean = true) : Boolean
      {
         if(!LoginRequired)
         {
            return true;
         }
         var _loc2_:Boolean = true;
         this.registered = true;
         if(this.checkSecurityFails)
         {
            if(!this.checkCredentials())
            {
               _loc2_ = false;
               this.registered = this.credentials.isRegisteredUser();
            }
         }
         this.updateTrialSubscLeft();
         if(_loc2_ && this.trialDaysLeft() <= 0 && this.subscDaysLeft() <= 0 && GWizCredentials.credStatus != GWizCredentials.CRED_OK_GRACE)
         {
            _loc2_ = false;
         }
         var _loc3_:Boolean = false;
         if(this.trialDaysLeft() > 0)
         {
            this.authType = "Trial";
            _loc3_ = true;
         }
         else if(this.subscDaysLeft() > 0)
         {
            this.authType = "Subscribed";
            _loc3_ = true;
         }
         if(_loc3_ && !this.didGetStarted)
         {
            this.didGetStarted = true;
            this.showGettingStartedAux();
         }
         _loc2_ = _loc2_ && GWizCredentials.timeCheckOK;
         _loc2_ = _loc2_ || !this.checkSecurityFails;
         if(!_loc2_ && !this.registered && GWizSettings.gotPreferences)
         {
            if(LoginParm != GUEST_NAME)
            {
               if(GWizCredentials.checkinComplete)
               {
                  GWizLoginSplash.loginConfirmed("Email \'" + LoginParm + "\' is not registered or you need to connect to Internet.",true);
               }
               else
               {
                  this.callLater(this.CheckSecurity);
               }
            }
            else
            {
               GWizLoginFB.showLoginFB();
            }
         }
         return _loc2_;
      }
      
      private function showGettingStartedAux() : void
      {
         var _loc1_:int = GWizSettings.loginBar.trialDaysLeft();
         if(GWizSettings.gotPreferences && _loc1_ != 0)
         {
            if(_loc1_ > 0 && !GWizLoginMgr.currentOrPastSubscriber() && !GWizGettingStarted.doneAllGettingStarted())
            {
               GWizSettings.prefs.showGettingStarted = true;
            }
            if(GWizSettings.prefs.showGettingStarted && !GWizLoginSplash.SHOW_MODAL_SETUP)
            {
               GWizGettingStarted.newGettingStarted();
            }
         }
         else
         {
            this.callLater(this.showGettingStartedAux);
         }
      }
      
      public function isRegistered() : Boolean
      {
         return this.registered || GWizCredentials.credStatus == GWizCredentials.CRED_UNPAID_NOTRIAL;
      }
      
      public function securityMsg() : void
      {
         var _loc1_:Boolean = false;
         if(!this.registered)
         {
            _loc1_ = true;
         }
         else if(this.trialDaysLeft() <= 0 && this.subscDaysLeft() <= 0 && GWizCredentials.credStatus != GWizCredentials.CRED_OK_GRACE)
         {
            _loc1_ = true;
         }
         if(_loc1_)
         {
            GWizLoginWizard.revalidateLogin();
         }
      }
      
      public function guestLogin() : Boolean
      {
         return LoginParm == GUEST_NAME;
      }
      
      public function set popTipWin(param1:Function) : void
      {
         this.ensureCredentials();
         GWCredentialMsgs.popTipWin = param1;
      }
      
      private function checkCredentials() : Boolean
      {
         this.ensureCredentials();
         return this.credentials.checkCredentials();
      }
      
      private function ensureCredentials() : void
      {
         var _loc1_:String = null;
         if(!this.credentials)
         {
            this.credentials = new GWizCredentials();
         }
         if(!this.versionChecker && this.appNameParm != "")
         {
            _loc1_ = this.appNameParm;
            if(GWizAbstractPrefs.isOEM)
            {
               _loc1_ = GWizAbstractPrefs.oemStr;
            }
            this.versionChecker = new GWizAppVersion(_loc1_,this.feather,this.checkVersion);
            GWizCredentials.checkGWizardUpdates = this.versionChecker.checkGWizardUpdates;
         }
         if(LoginParm)
         {
            GWizCredentials.LoginParm = LoginParm;
         }
         this.credentials.checkSecurityFails = this.checkSecurityFails;
         GWizCredentials.isBeta = this.isBeta;
         GWizCredentials.appTrialSubscList = this.appTrialSubscList;
         if(this.Status && this.Status.text == "")
         {
            this.Status.text = "Running " + this.appNameParm + " v" + this.appVersionParm;
         }
      }
      
      public function popupVerDetails() : void
      {
         this.verDetails = GWizVerDetails(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizVerDetails,true));
         if(this.verDetails)
         {
            this.verDetails.fileDate.text = "App file creation date: " + this.versionChecker.airFileCreated;
            this.verDetails.optVer.text = "Optional upgrade version: " + GWizAppVersion.versionNum;
            this.verDetails.manVer.text = "Mandatory upgrade version: " + GWizAppVersion.mandatoryNum;
         }
      }
      
      public function InitSecurity() : void
      {
         GWizSettings.appLongName = this.appLongNameParm;
         GWizUtils.assert(this.appNameParm.length > 0);
         GWizUtils.assert(this.appLongNameParm.length > 0);
         if(GWizSettings.gotPreferences)
         {
            GWizSettings.appVersion = this.appVersionParm;
            if(!setLogins)
            {
               setLogins = true;
            }
         }
         else
         {
            LoginParm = GUEST_NAME;
         }
         this.authenticateLogin(LoginParm);
         if(!this.versionChecker && !GWizAppVersion.gotVersion && this.checkVersion)
         {
            this.versionChecker = new GWizAppVersion(this.appNameParm,this.feather,this.checkVersion);
         }
         this.InitSecurity2();
      }
      
      private function authenticateLogin(param1:String) : void
      {
         this.ensureCredentials();
         this.credentials.tryLogin(param1);
      }
      
      private function InitSecurity2() : void
      {
         if(GWizSettings.loginBar.appNameParm == "")
         {
            GWizUtils.assert(false);
         }
         GWizSettings.docWindow.nativeWindow.addEventListener(Event.CLOSING,this.windowClosingHandler);
         GWizSettings.docWindow.width = Math.min(GWizSettings.docWindow.width,Capabilities.screenResolutionX - 50);
         GWizSettings.docWindow.height = Math.min(GWizSettings.docWindow.height,Capabilities.screenResolutionY - 50);
         this.resetLoginBar();
      }
      
      public function resetLoginBar() : void
      {
         var _loc1_:String = GUEST_NAME;
         if(LoginParm != GUEST_NAME && LoginParm.length > 0)
         {
            _loc1_ = LoginParm.substr(0,LoginParm.search("@"));
         }
         else
         {
            LoginParm = GUEST_NAME;
         }
         this.Welcome.text = "Howdy, " + _loc1_ + "!";
         if(!LoginRequired)
         {
            this.Welcome.text = "Howdy!";
         }
         if(!gaveSessionStarted)
         {
            GATracker.logPageView("SessionStarted","SessionStarted");
            gaveSessionStarted = true;
         }
      }
      
      public function changeLoginName(param1:String) : void
      {
         LoginParm = param1;
      }
      
      private function doLogin() : void
      {
         if(GWizLoginSplash.loginMsgShowing)
         {
            this.callLater(this.doLogin);
            return;
         }
         GWizUtils.LogError("Calling setMode from GWizLoginBar.doLogin");
         GWizLoginSplash.setMode(GWizLoginSplash.LOGIN_TAB);
         GWizSettings.prefs.newUserClearEULA();
         if(!GWizLoginSplash.loginMsgShowing)
         {
            GWizLoginWizard.launchLoginWizard(GWizLoginWizard.EMAIL_STATE,true);
         }
      }
      
      private function firstTimeForNewVersion() : Boolean
      {
         return GWizSettings.gotPreferences && GWizSettings.appVersion != GWizSettings.priorVersion;
      }
      
      private function windowClosingHandler(param1:Event) : void
      {
         GWizSettings.prefs.saveTimerExpired = true;
         if(this.firstTimeForNewVersion())
         {
            GWizSettings.prefs.showedReleaseNotes = false;
         }
         GWizSettings.appVersion = this.appVersionParm;
         if(LoginParm.length == 0)
         {
            LoginParm = GUEST_NAME;
         }
         this.ensureCredentials();
         this.credentials.logout();
         GWizSettings.appVersion = this.appVersionParm;
         GWizSettings.prefs.savePreferences(LoginParm);
         if(GWizSettings.db && GWizSettings.db.conn)
         {
            GWizSettings.db.conn.close();
         }
      }
      
      private function doInstallClick() : void
      {
         var _loc1_:GWizInstallPopUp = null;
         if(true || this.installLink.label == "Install")
         {
            _loc1_ = GWizInstallPopUp(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizInstallPopUp,true));
            _loc1_.browserFcn = this.browseToInstall;
            GATracker.logPageView("Login/Install","Login: Install");
         }
      }
      
      private function browseToInstall() : void
      {
         var _loc1_:String = null;
         if(!GWizUtils.doWebPage(this.appInstallURL))
         {
            _loc1_ = "Sorry, a popup blocker of some kind blocked the browser opening.  Copy this link to your browser: " + this.appInstallURL;
            GWizPopUpManager.Show(_loc1_,"Browser Failed",GWizPopUpManager.WARN);
            GWizMandrill.msg("Install Failure","Popup Blocker");
         }
      }
      
      private function updateTrialSubscLeft() : void
      {
         if(GWizAbstractPrefs.isOEM)
         {
            return;
         }
         this.daysLeft.text = "";
         this.daysLeft.visible = false;
         this.daysLeftAction.visible = false;
         var _loc1_:String = GWizProvisions.provisionValue("GWCL");
         if(0 < this.subscDaysLeft() && this.subscDaysLeft() <= 14)
         {
            this.daysLeft.visible = true;
            this.daysLeft.text = this.subscDaysLeft().toFixed() + " days left in your subscription.";
            this.daysLeftAction.label = "Renew";
            this.daysLeftAction.visible = true;
         }
         else if(this.trialDaysLeft() > 0 && this.subscDaysLeft() <= 0 && _loc1_.length <= 0)
         {
            this.daysLeft.visible = true;
            this.daysLeft.text = this.trialDaysLeft().toFixed() + " days left in your trial.";
            this.daysLeftAction.label = "View Pricing";
            this.daysLeftAction.visible = true;
         }
         else if(this.checkSecurityFails && !this.checkCredentials())
         {
            this.daysLeftAction.visible = true;
            if(this.isRegistered())
            {
               this.daysLeft.visible = true;
               this.daysLeft.text = "Trial Expired.";
               this.daysLeftAction.label = "View Pricing";
            }
            else
            {
               this.daysLeftAction.label = "Register";
            }
         }
         if(GWizSettings.prefs.liteMode && this.subscDaysLeft() <= 0 && GWizLoginMgr.currentOrPastSubscriber())
         {
            if(this.appProvParm == "GWC")
            {
               this.daysLeft.visible = true;
               this.daysLeft.text = "GWizLite Power Limit, renew for full power.";
               this.daysLeftAction.label = "Renew";
               this.daysLeftAction.visible = true;
            }
            else if(this.appProvParm == "GWE")
            {
               this.daysLeft.visible = true;
               this.daysLeft.text = "GWE Lite Features Limited, renew for full power.";
               this.daysLeftAction.label = "Renew";
               this.daysLeftAction.visible = true;
            }
         }
         if(daysLeftOverride.length > 0)
         {
            this.daysLeft.visible = true;
            this.daysLeft.text = daysLeftOverride;
            this.daysLeftAction.label = "Renew";
            this.daysLeftAction.visible = true;
         }
      }
      
      private function set credCheck(param1:int) : void
      {
         if(GWizSettings.gotPreferences)
         {
            this.updateTrialSubscLeft();
         }
      }
      
      public function trialDaysLeft() : Number
      {
         return GWizProvisions.provisionDaysLeft(GWizSettings.loginBar.appProvParm);
      }
      
      public function subscDaysLeft() : Number
      {
         return GWizProvisions.provisionDaysLeft(GWizProvisions.appSubscProvision());
      }
      
      private function daysLeftButtonClick() : void
      {
         var _loc1_:String = null;
         switch(this.daysLeftAction.label)
         {
            case "Special Offer":
            case "Upgrade":
               _loc1_ = GWizEvalPopUp.purchaseURL;
               if(this.appProvParm == "GWC")
               {
                  if(GWizAbstractPrefs.GDTBasics)
                  {
                     _loc1_ = "http://www.cnccookbook.com/GWSignupGDTBasics.html";
                  }
               }
               if(GWizUtils.doWebPage(_loc1_))
               {
               }
               break;
            default:
               if(GWizUtils.doWebPage(GWizEvalPopUp.registerURL))
               {
               }
               GATracker.logPageView("Login/DaysLeftBtn","Login: DaysLeftBtn");
         }
      }
      
      public function doClubClick() : void
      {
         GWizUtils.doWebPage("http://blog.cnccookbook.com/questions/");
         GATracker.logPageView("Login/QuestionX","Login: QuestionX");
      }
      
      private function doGettingStarted() : void
      {
         GWizGettingStarted.newGettingStarted();
      }
      
      public function doSupport() : void
      {
         if(!GWizUtils.debug)
         {
            GWizUtils.doWebPage("http://www.cnccookbook.com/CCHelpDesk.html");
            GATracker.logPageView("Login/HelpDesk","Login: HelpDesk");
         }
         else
         {
            AuthTest.doTests();
         }
      }
      
      private function onCC() : void
      {
         setStyle("backgroundColor","black");
         setStyle("backgroundAlpha","1.0");
         if(GWizAbstractPrefs.isOEM)
         {
            LoginRequired = false;
            this.checkSecurityFails = false;
         }
         GWizSettings.loginBar = this;
         CCComplete = true;
      }
      
      private function _GWizLoginBar_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizVerDetails;
         _loc1_.properties = {"outerDocument":this};
         this._GWizLoginBar_ClassFactory1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginBar_ClassFactory1",this._GWizLoginBar_ClassFactory1);
         return _loc1_;
      }
      
      private function _GWizLoginBar_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.stroke = this._GWizLoginBar_SolidColorStroke1_i();
         _loc1_.fill = this._GWizLoginBar_SolidColor1_i();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizLoginBar_SolidColorStroke1_i() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.weight = 1;
         this._GWizLoginBar_SolidColorStroke1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginBar_SolidColorStroke1",this._GWizLoginBar_SolidColorStroke1);
         return _loc1_;
      }
      
      private function _GWizLoginBar_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         this._GWizLoginBar_SolidColor1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginBar_SolidColor1",this._GWizLoginBar_SolidColor1);
         return _loc1_;
      }
      
      private function _GWizLoginBar_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizLoginBar_Label1_i(),this._GWizLoginBar_GWizBubbleTip1_i(),this._GWizLoginBar_Label2_i(),this._GWizLoginBar_GWizBubbleTip2_i(),this._GWizLoginBar_GWizOfferBtn1_i(),this._GWizLoginBar_Spacer1_i(),this._GWizLoginBar_GWizBubbleTip3_i(),this._GWizLoginBar_GWizBubbleTip4_i(),this._GWizLoginBar_Button4_i(),this._GWizLoginBar_Image1_i(),this._GWizLoginBar_Image2_i(),this._GWizLoginBar_GWizHelpButton1_i()];
         _loc1_.id = "controlBar";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.controlBar = _loc1_;
         BindingManager.executeBindings(this,"controlBar",this.controlBar);
         return _loc1_;
      }
      
      private function _GWizLoginBar_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "Welcome";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Welcome = _loc1_;
         BindingManager.executeBindings(this,"Welcome",this.Welcome);
         return _loc1_;
      }
      
      private function _GWizLoginBar_GWizBubbleTip1_i() : GWizBubbleTip
      {
         var _loc1_:GWizBubbleTip = new GWizBubbleTip();
         _loc1_.bubbleID = "LoginButton";
         _loc1_.mxmlContent = [this._GWizLoginBar_Button1_i()];
         _loc1_.id = "_GWizLoginBar_GWizBubbleTip1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginBar_GWizBubbleTip1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginBar_GWizBubbleTip1",this._GWizLoginBar_GWizBubbleTip1);
         return _loc1_;
      }
      
      private function _GWizLoginBar_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Login";
         _loc1_.toolTip = "Activate the Login Wizard to change your Login.";
         _loc1_.addEventListener("click",this.__Login_click);
         _loc1_.id = "Login";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Login = _loc1_;
         BindingManager.executeBindings(this,"Login",this.Login);
         return _loc1_;
      }
      
      public function __Login_click(param1:MouseEvent) : void
      {
         this.doLogin();
      }
      
      private function _GWizLoginBar_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "daysLeft";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.daysLeft = _loc1_;
         BindingManager.executeBindings(this,"daysLeft",this.daysLeft);
         return _loc1_;
      }
      
      private function _GWizLoginBar_GWizBubbleTip2_i() : GWizBubbleTip
      {
         var _loc1_:GWizBubbleTip = new GWizBubbleTip();
         _loc1_.bubbleID = "RegisterButton";
         _loc1_.mxmlContent = [this._GWizLoginBar_Button2_i()];
         _loc1_.id = "_GWizLoginBar_GWizBubbleTip2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginBar_GWizBubbleTip2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginBar_GWizBubbleTip2",this._GWizLoginBar_GWizBubbleTip2);
         return _loc1_;
      }
      
      private function _GWizLoginBar_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.visible = false;
         _loc1_.addEventListener("click",this.__daysLeftAction_click);
         _loc1_.id = "daysLeftAction";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.daysLeftAction = _loc1_;
         BindingManager.executeBindings(this,"daysLeftAction",this.daysLeftAction);
         return _loc1_;
      }
      
      public function __daysLeftAction_click(param1:MouseEvent) : void
      {
         this.daysLeftButtonClick();
      }
      
      private function _GWizLoginBar_GWizOfferBtn1_i() : GWizOfferBtn
      {
         var _loc1_:GWizOfferBtn = new GWizOfferBtn();
         _loc1_.id = "OfferBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.OfferBtn = _loc1_;
         BindingManager.executeBindings(this,"OfferBtn",this.OfferBtn);
         return _loc1_;
      }
      
      private function _GWizLoginBar_Spacer1_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         _loc1_.id = "theSpacer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theSpacer = _loc1_;
         BindingManager.executeBindings(this,"theSpacer",this.theSpacer);
         return _loc1_;
      }
      
      private function _GWizLoginBar_GWizBubbleTip3_i() : GWizBubbleTip
      {
         var _loc1_:GWizBubbleTip = new GWizBubbleTip();
         _loc1_.bubbleID = "GettingStarted";
         _loc1_.mxmlContent = [this._GWizLoginBar_Button3_i()];
         _loc1_.id = "_GWizLoginBar_GWizBubbleTip3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginBar_GWizBubbleTip3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginBar_GWizBubbleTip3",this._GWizLoginBar_GWizBubbleTip3);
         return _loc1_;
      }
      
      private function _GWizLoginBar_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Getting Started";
         _loc1_.setStyle("chromeColor",5168750);
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("click",this.__GettingStarted_click);
         _loc1_.id = "GettingStarted";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GettingStarted = _loc1_;
         BindingManager.executeBindings(this,"GettingStarted",this.GettingStarted);
         return _loc1_;
      }
      
      public function __GettingStarted_click(param1:MouseEvent) : void
      {
         this.doGettingStarted();
      }
      
      private function _GWizLoginBar_GWizBubbleTip4_i() : GWizBubbleTip
      {
         var _loc1_:GWizBubbleTip = new GWizBubbleTip();
         _loc1_.bubbleID = "VsnLabel";
         _loc1_.mxmlContent = [this._GWizLoginBar_Label3_i()];
         _loc1_.id = "_GWizLoginBar_GWizBubbleTip4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginBar_GWizBubbleTip4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginBar_GWizBubbleTip4",this._GWizLoginBar_GWizBubbleTip4);
         return _loc1_;
      }
      
      private function _GWizLoginBar_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Status";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Status = _loc1_;
         BindingManager.executeBindings(this,"Status",this.Status);
         return _loc1_;
      }
      
      private function _GWizLoginBar_Button4_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Install";
         _loc1_.setStyle("chromeColor",5168750);
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("click",this.__installLink_click);
         _loc1_.id = "installLink";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.installLink = _loc1_;
         BindingManager.executeBindings(this,"installLink",this.installLink);
         return _loc1_;
      }
      
      public function __installLink_click(param1:MouseEvent) : void
      {
         this.doInstallClick();
      }
      
      private function _GWizLoginBar_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_Support_png_187022828;
         _loc1_.scaleX = 0.5;
         _loc1_.scaleY = 0.5;
         _loc1_.toolTip = "Help Desk";
         _loc1_.addEventListener("click",this.__Support_click);
         _loc1_.addEventListener("rollOut",this.__Support_rollOut);
         _loc1_.addEventListener("rollOver",this.__Support_rollOver);
         _loc1_.id = "Support";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Support = _loc1_;
         BindingManager.executeBindings(this,"Support",this.Support);
         return _loc1_;
      }
      
      public function __Support_click(param1:MouseEvent) : void
      {
         this.doSupport();
      }
      
      public function __Support_rollOut(param1:MouseEvent) : void
      {
         checkTransform(param1);
      }
      
      public function __Support_rollOver(param1:MouseEvent) : void
      {
         checkTransform(param1);
      }
      
      private function _GWizLoginBar_Image2_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_TipBtn_jpg_1455544182;
         _loc1_.toolTip = "Tips";
         _loc1_.addEventListener("click",this.___GWizLoginBar_Image2_click);
         _loc1_.addEventListener("rollOut",this.___GWizLoginBar_Image2_rollOut);
         _loc1_.addEventListener("rollOver",this.___GWizLoginBar_Image2_rollOver);
         _loc1_.id = "_GWizLoginBar_Image2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginBar_Image2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginBar_Image2",this._GWizLoginBar_Image2);
         return _loc1_;
      }
      
      public function ___GWizLoginBar_Image2_click(param1:MouseEvent) : void
      {
         GWCredentialMsgs.popTipWin(true);
      }
      
      public function ___GWizLoginBar_Image2_rollOut(param1:MouseEvent) : void
      {
         checkTransform(param1);
      }
      
      public function ___GWizLoginBar_Image2_rollOver(param1:MouseEvent) : void
      {
         checkTransform(param1);
      }
      
      private function _GWizLoginBar_GWizHelpButton1_i() : GWizHelpButton
      {
         var _loc1_:GWizHelpButton = new GWizHelpButton();
         _loc1_.id = "_GWizLoginBar_GWizHelpButton1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginBar_GWizHelpButton1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginBar_GWizHelpButton1",this._GWizLoginBar_GWizHelpButton1);
         return _loc1_;
      }
      
      public function ___GWizLoginBar_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizLoginBar_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():*
         {
            return GWizCredentials.credStatus;
         },function(param1:*):void
         {
            credCheck = param1;
         },"credCheck");
         result[1] = new Binding(this,null,null,"_GWizLoginBar_SolidColorStroke1.color","borderColor");
         result[2] = new Binding(this,null,null,"_GWizLoginBar_SolidColor1.color","backgroundColor");
         result[3] = new Binding(this,null,function(param1:uint):void
         {
            Welcome.setStyle("color",param1);
         },"Welcome.color","labelColor");
         result[4] = new Binding(this,function():Boolean
         {
            return LoginRequired;
         },null,"Welcome.visible");
         result[5] = new Binding(this,function():Boolean
         {
            return LoginRequired;
         },null,"Welcome.includeInLayout");
         result[6] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"_GWizLoginBar_GWizBubbleTip1.myWindow");
         result[7] = new Binding(this,function():Boolean
         {
            return LoginRequired;
         },null,"Login.visible");
         result[8] = new Binding(this,function():Boolean
         {
            return LoginRequired;
         },null,"Login.includeInLayout");
         result[9] = new Binding(this,null,function(param1:uint):void
         {
            daysLeft.setStyle("color",param1);
         },"daysLeft.color","labelColor");
         result[10] = new Binding(this,function():Boolean
         {
            return LoginRequired;
         },null,"daysLeft.visible");
         result[11] = new Binding(this,function():Boolean
         {
            return LoginRequired;
         },null,"daysLeft.includeInLayout");
         result[12] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"_GWizLoginBar_GWizBubbleTip2.myWindow");
         result[13] = new Binding(this,null,null,"OfferBtn.myBar","controlBar");
         result[14] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"_GWizLoginBar_GWizBubbleTip3.myWindow");
         result[15] = new Binding(this,null,null,"GettingStarted.visible","ShowGettingStarted");
         result[16] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"_GWizLoginBar_GWizBubbleTip4.myWindow");
         result[17] = new Binding(this,null,function(param1:uint):void
         {
            Status.setStyle("color",param1);
         },"Status.color","versionColor");
         result[18] = new Binding(this,null,null,"Support.visible","ShowSupport");
         result[19] = new Binding(this,null,null,"_GWizLoginBar_Image2.visible","ShowTips");
         result[20] = new Binding(this,null,null,"_GWizLoginBar_GWizHelpButton1.visible","ShowHelp");
         return result;
      }
      
      private function _GWizLoginBar_bindingExprs() : void
      {
         var _loc1_:* = undefined;
         this.credCheck = GWizCredentials.credStatus;
      }
      
      [Bindable(event="propertyChange")]
      public function get GettingStarted() : Button
      {
         return this._1469606077GettingStarted;
      }
      
      public function set GettingStarted(param1:Button) : void
      {
         var _loc2_:Object = this._1469606077GettingStarted;
         if(_loc2_ !== param1)
         {
            this._1469606077GettingStarted = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GettingStarted",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Login() : Button
      {
         return this._73596745Login;
      }
      
      public function set Login(param1:Button) : void
      {
         var _loc2_:Object = this._73596745Login;
         if(_loc2_ !== param1)
         {
            this._73596745Login = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Login",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get OfferBtn() : GWizOfferBtn
      {
         return this._703929728OfferBtn;
      }
      
      public function set OfferBtn(param1:GWizOfferBtn) : void
      {
         var _loc2_:Object = this._703929728OfferBtn;
         if(_loc2_ !== param1)
         {
            this._703929728OfferBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"OfferBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Status() : Label
      {
         return this._1808614382Status;
      }
      
      public function set Status(param1:Label) : void
      {
         var _loc2_:Object = this._1808614382Status;
         if(_loc2_ !== param1)
         {
            this._1808614382Status = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Status",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Support() : Image
      {
         return this._190113873Support;
      }
      
      public function set Support(param1:Image) : void
      {
         var _loc2_:Object = this._190113873Support;
         if(_loc2_ !== param1)
         {
            this._190113873Support = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Support",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Welcome() : Label
      {
         return this._1397214398Welcome;
      }
      
      public function set Welcome(param1:Label) : void
      {
         var _loc2_:Object = this._1397214398Welcome;
         if(_loc2_ !== param1)
         {
            this._1397214398Welcome = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Welcome",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get controlBar() : HGroup
      {
         return this._637388150controlBar;
      }
      
      public function set controlBar(param1:HGroup) : void
      {
         var _loc2_:Object = this._637388150controlBar;
         if(_loc2_ !== param1)
         {
            this._637388150controlBar = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"controlBar",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get daysLeft() : Label
      {
         return this._1948582142daysLeft;
      }
      
      public function set daysLeft(param1:Label) : void
      {
         var _loc2_:Object = this._1948582142daysLeft;
         if(_loc2_ !== param1)
         {
            this._1948582142daysLeft = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"daysLeft",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get daysLeftAction() : Button
      {
         return this._177720108daysLeftAction;
      }
      
      public function set daysLeftAction(param1:Button) : void
      {
         var _loc2_:Object = this._177720108daysLeftAction;
         if(_loc2_ !== param1)
         {
            this._177720108daysLeftAction = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"daysLeftAction",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get installLink() : Button
      {
         return this._2143290421installLink;
      }
      
      public function set installLink(param1:Button) : void
      {
         var _loc2_:Object = this._2143290421installLink;
         if(_loc2_ !== param1)
         {
            this._2143290421installLink = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"installLink",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theSpacer() : Spacer
      {
         return this._716438531theSpacer;
      }
      
      public function set theSpacer(param1:Spacer) : void
      {
         var _loc2_:Object = this._716438531theSpacer;
         if(_loc2_ !== param1)
         {
            this._716438531theSpacer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theSpacer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backgroundColor() : uint
      {
         return this._1287124693backgroundColor;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         var _loc2_:Object = this._1287124693backgroundColor;
         if(_loc2_ !== param1)
         {
            this._1287124693backgroundColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backgroundColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelColor() : uint
      {
         return this._1675495217labelColor;
      }
      
      public function set labelColor(param1:uint) : void
      {
         var _loc2_:Object = this._1675495217labelColor;
         if(_loc2_ !== param1)
         {
            this._1675495217labelColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get borderColor() : uint
      {
         return this._722830999borderColor;
      }
      
      public function set borderColor(param1:uint) : void
      {
         var _loc2_:Object = this._722830999borderColor;
         if(_loc2_ !== param1)
         {
            this._722830999borderColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"borderColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get versionColor() : uint
      {
         return this._128489109versionColor;
      }
      
      public function set versionColor(param1:uint) : void
      {
         var _loc2_:Object = this._128489109versionColor;
         if(_loc2_ !== param1)
         {
            this._128489109versionColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"versionColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get credentials() : GWizCredentials
      {
         return this._288957180credentials;
      }
      
      public function set credentials(param1:GWizCredentials) : void
      {
         var _loc2_:Object = this._288957180credentials;
         if(_loc2_ !== param1)
         {
            this._288957180credentials = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"credentials",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShowGettingStarted() : Boolean
      {
         return this._1797554458ShowGettingStarted;
      }
      
      public function set ShowGettingStarted(param1:Boolean) : void
      {
         var _loc2_:Object = this._1797554458ShowGettingStarted;
         if(_loc2_ !== param1)
         {
            this._1797554458ShowGettingStarted = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShowGettingStarted",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShowSupport() : Boolean
      {
         return this._201260530ShowSupport;
      }
      
      public function set ShowSupport(param1:Boolean) : void
      {
         var _loc2_:Object = this._201260530ShowSupport;
         if(_loc2_ !== param1)
         {
            this._201260530ShowSupport = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShowSupport",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShowTips() : Boolean
      {
         return this._274186251ShowTips;
      }
      
      public function set ShowTips(param1:Boolean) : void
      {
         var _loc2_:Object = this._274186251ShowTips;
         if(_loc2_ !== param1)
         {
            this._274186251ShowTips = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShowTips",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShowHelp() : Boolean
      {
         return this._274547714ShowHelp;
      }
      
      public function set ShowHelp(param1:Boolean) : void
      {
         var _loc2_:Object = this._274547714ShowHelp;
         if(_loc2_ !== param1)
         {
            this._274547714ShowHelp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShowHelp",_loc2_,param1));
            }
         }
      }
   }
}
