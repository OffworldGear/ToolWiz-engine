package configinfo
{
   import cadcamwiz.GWizCCWMillOptions;
   import comps.AlertPopup;
   import comps.GWizFileBrowser;
   import comps.GWizPopUpManager;
   import feedsspeeds.GWizFeedsSpeeds2;
   import flash.display.NativeWindowDisplayState;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.TimerEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.system.Capabilities;
   import flash.utils.Timer;
   import integratep.GWizMecSoftSetup;
   import login.GWizEmailTracker;
   import login.GWizLoginBar;
   import login.GWizLoginMgr;
   import login.GWizLoginSplash;
   import login.GWizProvisions;
   import machines.GWizMachProfile;
   import machines.GWizMachSettings;
   import material.GWizMatBrowser2;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.managers.PopUpManager;
   import skins.GWizStylePalette;
   import tools.GWizToolCrib;
   import utils.GATracker;
   import utils.GWizCallChain;
   import utils.GWizCrypto;
   import utils.GWizFileUtils;
   import utils.GWizJustASec;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizAbstractPrefs implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizAbstractPrefs");
      
      private static var _534192478ThreadCalcEnabled:Boolean = false;
      
      public static var usesMachinesPrefs:Boolean = true;
      
      public static var auxPrefsSet:Boolean = false;
      
      public static const NO_LOGO:String = "nologo";
      
      public static var logoStr:String = NO_LOGO;
      
      private static var _677890491madeByStr:String = "CNCCookbook";
      
      public static var GDTBasics:Boolean = false;
      
      public static const isOEM:Boolean = false;
      
      public static const GARR_OEM_STR:String = "garrtool";
      
      public static const ACME_OEM_STR:String = "ACME";
      
      public static const FULLERTON_OEM_STR:String = "fullerton";
      
      private static var _1020525222oemStr:String = FULLERTON_OEM_STR;
      
      public static var oemSettings:ArrayCollection = new ArrayCollection([{
         "name":"ACME",
         "winTitle":"ACME TOOL Machinist\'s Calculator",
         "repMsg":"For best application practices, contact your local ACME TOOL Regional Sales Manger or contact ACME TOOL direct at 800.867.5309.",
         "repPopUpTitle":"Contact ACME TOOL",
         "tip1":"For best application practices, contact your",
         "tip2":"local ACME TOOL Regional Sales Manger or",
         "tip3":"contact ACME TOOL direct at",
         "tip4":"800.867.5309.",
         "specialOfferURL":"https://www.cnccookbook.com/acme-special-offer/",
         "appDownloadDir":"https://www.cnccookbook.com/download-acmecalc-manual/"
      },{
         "name":FULLERTON_OEM_STR,
         "winTitle":"Fullerton Tool Machinist\'s Calculator",
         "repMsg":"For best application practices, contact your local Fullerton Tool Regional Sales Manger or contact Fullerton Tool direct at 800.248.8315.",
         "repPopUpTitle":"Contact GARR TOOL",
         "tip1":"For best application practices, contact your",
         "tip2":"local Fullerton Tool Regional Sales Manger or",
         "tip3":"contact Fullerton Tool direct at",
         "tip4":"800.248.8315.",
         "specialOfferURL":"https://www.cnccookbook.com",
         "appDownloadDir":"https://www.cnccookbook.com"
      },{
         "name":GARR_OEM_STR,
         "winTitle":"GARR TOOL Machinist\'s Calculator",
         "repMsg":"For best application practices, contact your local GARR TOOL Regional Sales Manger or contact GARR TOOL direct at 800.248.9003.",
         "repPopUpTitle":"Contact GARR TOOL",
         "tip1":"For best application practices, contact your",
         "tip2":"local GARR TOOL Regional Sales Manger or",
         "tip3":"contact GARR TOOL direct at",
         "tip4":"800.248.9003.",
         "specialOfferURL":"https://www.cnccookbook.com/gartool-special-offer/",
         "appDownloadDir":"https://www.cnccookbook.com/download-garrcalc-manual/"
      }]);
      
      public static const WIN_TITLE:String = "winTitle";
      
      public static const REP_MSG:String = "repMsg";
      
      public static const REP_POPUP_TITLE:String = "repPopUpTitle";
      
      public static const TIP1:String = "tip1";
      
      public static const TIP2:String = "tip2";
      
      public static const TIP3:String = "tip3";
      
      public static const TIP4:String = "tip4";
      
      public static const SPECIAL_OFFER:String = "specialOfferURL";
      
      public static const APP_DOWNLOAD_DIR:String = "appDownloadDir";
      
      public static var powerUserCC:GWizCallChain = new GWizCallChain();
      
      public static const TEST_SMALL_SCREENS:Boolean = false;
      
      public static const TEST_1280_800:Boolean = false;
      
      public static var getShareableWasShared:Boolean = false;
      
      private static const LOCK_FILE_NAME:String = "LockFile.csv";
      
      private static var lockStream:FileStream = null;
      
      public static var appSpecificLock:Function = null;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var prefsFile:File;
      
      private var _1288277177prefsXML:XML = null;
      
      private var prefsStream:FileStream;
      
      public var createDate:String;
      
      public var xlo:Number = 0.1;
      
      public var showedReleaseNotes:Boolean = false;
      
      public var showTips:Boolean = true;
      
      public var eulaAccepted:Boolean = false;
      
      public var saveTimerExpired:Boolean = false;
      
      private var saveTimer:Timer = null;
      
      private var _authenticateDate:String;
      
      public var authenticateDateAux:String;
      
      private var _authenticateType:int;
      
      private var _1360222065liteMode:Boolean = false;
      
      public var _lastGWLiteHP:Number = NaN;
      
      public const AUTHENTICATE_HASH_CODE:String = "youbetternotbecheating";
      
      public var tbincs:String;
      
      public var tbincsAux:String;
      
      public var logins:int = 0;
      
      public var trialLogins:int = 0;
      
      public var noSetupReqd:Boolean = false;
      
      private var _1355327339backupDir:String;
      
      private var _1660019183sharingDir:String;
      
      private var _1801882095sharePrefs:Boolean = false;
      
      public var showGettingStarted:Boolean;
      
      public var bigSalePop:String = null;
      
      public var upsellPop:String = null;
      
      public var crossSellPop:String = null;
      
      public var trialDiscountPop:String = null;
      
      public var renewalDiscountPop:String = null;
      
      public var flashSaleShown:Boolean = false;
      
      private var savePrefsQueued:Boolean = false;
      
      private var theOwner:GWizLoginBar = null;
      
      public var docWinWidth:int;
      
      public var docWinHeight:int;
      
      public var docWinMaximized:Boolean = false;
      
      public var docWinStayOnTop:Boolean = false;
      
      public var phoneMode:Boolean = false;
      
      private var _845209200powerUser:Boolean = true;
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizAbstractPrefs()
      {
         this._authenticateType = GWizLoginMgr.NO_ACCESS;
         this._1355327339backupDir = GWizFileUtils.nativePathToDir(File.documentsDirectory.nativePath) + "CNCCookbook" + File.separator + "Backup" + File.separator;
         this._1660019183sharingDir = GWizFileUtils.nativePathToDir(File.documentsDirectory.nativePath) + "CNCCookbook" + File.separator;
         this.showGettingStarted = !GWizLoginSplash.SHOW_MODAL_SETUP;
         this.docWinWidth = GWizSettings.WINDOW_WIDTH;
         this.docWinHeight = GWizSettings.WINDOW_HEIGHT;
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      public static function getOEMSettings(param1:String) : Object
      {
         var _loc3_:Object = null;
         if(!param1 || param1 == "")
         {
            param1 = oemStr;
         }
         var _loc2_:int = 0;
         while(_loc2_ < oemSettings.length)
         {
            _loc3_ = oemSettings.getItemAt(_loc2_);
            if(_loc3_.name == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public static function oemInfo(param1:String) : String
      {
         var _loc2_:Object = getOEMSettings(oemStr);
         return _loc2_[param1];
      }
      
      public static function isGarr() : Boolean
      {
         return isOEM && oemStr == GARR_OEM_STR;
      }
      
      public static function getShareablePrefsFile(param1:String, param2:Boolean = false) : File
      {
         if(GWizUtils.debug && false)
         {
            GWizUtils.assert(GWizSettings.prefs != null);
         }
         var _loc3_:File = null;
         getShareableWasShared = false;
         if(GWizSettings.prefs && GWizSettings.prefs.sharePrefs)
         {
            _loc3_ = new File(GWizSettings.prefs.sharingDir);
            _loc3_ = _loc3_.resolvePath(param1);
            getShareableWasShared = true;
         }
         var _loc4_:* = !_loc3_;
         if(param2 && _loc3_ && !_loc3_.exists)
         {
            _loc4_ = true;
         }
         if(_loc4_)
         {
            _loc3_ = GWizSettings.getPrefsFile(param1);
         }
         return _loc3_;
      }
      
      public static function gotLock() : Boolean
      {
         return lockStream != null || !GWizSettings.prefs.sharePrefs;
      }
      
      public static function lockSharedFiles(param1:Boolean) : Boolean
      {
         var f:File = null;
         var justASec:GWizJustASec = null;
         var lock:Boolean = param1;
         var error:Boolean = false;
         if(lock && !gotLock())
         {
            if(GWizSettings.prefs.sharePrefs)
            {
               try
               {
                  f = new File(GWizSettings.prefs.sharingDir);
                  f = f.resolvePath(LOCK_FILE_NAME);
                  lockStream = new FileStream();
                  lockStream.open(f,FileMode.UPDATE);
                  lockStream.position = 0;
                  lockStream.writeUTF("LOCK FILE");
                  if(appSpecificLock != null)
                  {
                     appSpecificLock(false);
                  }
                  loadSharedFiles();
               }
               catch(e:Error)
               {
                  log.debug("Error: " + e.message);
                  lockStream.close();
                  lockStream = null;
                  lockUnlock(true);
                  justASec = new GWizJustASec(popupToTop,2);
                  error = true;
               }
            }
         }
         else if(!lock)
         {
            if(lockStream || !GWizSettings.prefs.sharePrefs)
            {
               saveSharedFiles();
               if(lockStream)
               {
                  lockStream.close();
                  lockStream = null;
               }
            }
            lockUnlock(false);
         }
         return error;
      }
      
      private static function loadSharedFiles() : void
      {
         GWizSettings.cribData.loadToolCrib();
         GWizMachSettings.loadMachines();
         GWizSettings.post.loadSelectedMachinesPost();
      }
      
      private static function saveSharedFiles() : void
      {
         if(gotLock())
         {
            GWizSettings.cribData.saveToolCrib();
            GWizMachSettings.saveMachinesAux();
            GWizSettings.post.forceSavePost();
         }
      }
      
      private static function lockUnlock(param1:Boolean) : void
      {
         GWizMachProfile.lockMachineProfiles(param1);
         GWizToolCrib.lockToolCrib = param1;
         if(appSpecificLock != null)
         {
            appSpecificLock(param1);
         }
      }
      
      private static function popupToTop() : void
      {
         var _loc1_:AlertPopup = GWizPopUpManager.Show("Sorry, shared preferences are locked by another user or app. To edit, wait for them to finish then re-enter this tab.","Shared Preferences Locked...",GWizPopUpManager.WARN);
         PopUpManager.bringToFront(_loc1_);
      }
      
      [Bindable(event="propertyChange")]
      public static function get ThreadCalcEnabled() : Boolean
      {
         return GWizAbstractPrefs._534192478ThreadCalcEnabled;
      }
      
      public static function set ThreadCalcEnabled(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractPrefs._534192478ThreadCalcEnabled;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractPrefs,"ThreadCalcEnabled",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get madeByStr() : String
      {
         return GWizAbstractPrefs._677890491madeByStr;
      }
      
      public static function set madeByStr(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractPrefs._677890491madeByStr;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractPrefs,"madeByStr",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get oemStr() : String
      {
         return GWizAbstractPrefs._1020525222oemStr;
      }
      
      public static function set oemStr(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractPrefs._1020525222oemStr;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractPrefs,"oemStr",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function set authenticateDate(param1:String) : void
      {
         this._authenticateDate = param1;
      }
      
      public function get authenticateDate() : String
      {
         return this._authenticateDate;
      }
      
      public function get authenticateType() : int
      {
         return this._authenticateType;
      }
      
      public function set authenticateType(param1:int) : void
      {
         log.debug("authenticateType = " + param1);
         if(this._authenticateType > 0 && param1 <= 0)
         {
            log.debug("gotcha");
         }
         this._authenticateType = param1;
      }
      
      public function set lastGWLiteHP(param1:Number) : void
      {
         this._lastGWLiteHP = param1;
         if(param1 < 3)
         {
            log.debug("gotcha");
         }
      }
      
      public function get lastGWLiteHP() : Number
      {
         return this._lastGWLiteHP;
      }
      
      public function loadPreferences(param1:GWizLoginBar) : void
      {
         GWizUtils.LogErrorContext = "GWizAbstractPrefs.loadPreferences";
         GWizEmailTracker.loadEmails();
         this.theOwner = param1;
         this.prefsFile = GWizSettings.getPrefsFile(GWizSettings.PREFS_NAME);
         param1.callLater(this.loadPrefsFromFileAux);
      }
      
      private function loadPrefsFromFileAux() : void
      {
         this.loadPreferencesFromFile(this.prefsFile);
         if(usesMachinesPrefs)
         {
            GWizMachSettings.loadMachines();
         }
         this.theOwner.resetLoginBar();
         GWizSettings.gotPreferences = true;
         GWizFileBrowser.loadDirs();
         if(!this.saveTimerExpired)
         {
            this.saveTimer = new Timer(5000,1);
            this.saveTimer.addEventListener("timer",this.saveTimerHandler);
            this.saveTimer.start();
         }
      }
      
      private function saveTimerHandler(param1:TimerEvent) : void
      {
         this.saveTimerExpired = true;
         this.saveTimer = null;
         if(this.savePrefsQueued)
         {
            this.savePreferences(GWizLoginBar.LoginParm);
         }
      }
      
      public function savePreferences(param1:String) : void
      {
         var loginParm:String = param1;
         if(GWizSettings.savePrefs)
         {
            if(this.saveTimerExpired)
            {
               try
               {
                  GWizFileBrowser.saveDirs();
                  this.prefsXML = this.createXMLData(loginParm);
                  this.prefsXML = this.createAppSpecificXMLData(this.prefsXML);
                  this.writeXMLData(this.prefsXML,this.prefsFile);
                  GWizSettings.cribData.saveToolCrib();
                  this.savePrefsQueued = false;
               }
               catch(e:Error)
               {
                  GWizUtils.LogError("Error saving GWizAbstractPrefs. msg = " + e.message);
                  GWizUtils.assert(false);
               }
            }
            else
            {
               this.savePrefsQueued = true;
            }
         }
      }
      
      public function newUserClearEULA() : void
      {
         this.eulaAccepted = false;
      }
      
      public function eulaWasAccepted() : Boolean
      {
         return this.eulaAccepted == true;
      }
      
      public function appClosing() : void
      {
         GWizUtils.LogError("GWizAbstractPrefs.appClosing()\n");
         lockSharedFiles(false);
      }
      
      private function loadPreferencesFromFile(param1:File) : void
      {
         var stream:FileStream = null;
         var file:File = param1;
         try
         {
            stream = new FileStream();
            if(file.exists)
            {
               stream.open(file,FileMode.READ);
               this.prefsXML = XML(stream.readUTFBytes(stream.bytesAvailable));
               try
               {
                  this.prefsXML = this.processXMLData(this.prefsXML);
               }
               catch(e:Error)
               {
                  GWizUtils.LogError("Error loading generic XML prefs. msg = " + e.message);
                  log.debug(e.getStackTrace());
                  GWizUtils.assert(false);
               }
               try
               {
                  this.prefsXML = this.processAppSpecificXMLData(this.prefsXML);
               }
               catch(e:Error)
               {
                  GWizUtils.LogError("Error loading app specific XML prefs. msg = " + e.message);
                  log.debug(e.getStackTrace());
                  GWizUtils.assert(false);
               }
            }
            else
            {
               GWizSettings.appVersion = "0.0";
            }
            stream.close();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error loading GWizAbstractPrefs. msg = " + e.message);
            log.debug(e.getStackTrace());
            GWizUtils.assert(false);
         }
         this.windowPrefs();
      }
      
      private function windowPrefs() : void
      {
         if(this.prefsXML && this.prefsXML.windowState.@width > 0 && this.prefsXML.windowState.@height > 0)
         {
            this.docWinWidth = this.prefsXML.windowState.@width;
            this.docWinHeight = this.prefsXML.windowState.@height;
            this.docWinMaximized = this.prefsXML.docWinMaximized == "true";
            this.docWinStayOnTop = this.prefsXML.docWinStayOnTop == "true";
            this.powerUser = this.prefsXML.powerUser != "false";
         }
         else
         {
            this.docWinWidth = GWizSettings.WINDOW_WIDTH;
            this.docWinHeight = GWizSettings.WINDOW_HEIGHT;
            this.docWinMaximized = false;
            this.powerUser = true;
         }
         if(TEST_SMALL_SCREENS && GWizUtils.debug)
         {
            this.docWinWidth = 1024;
            this.docWinHeight = 768;
            this.docWinMaximized = false;
         }
         else if(TEST_1280_800 && GWizUtils.debug)
         {
            this.docWinWidth = 1280;
            this.docWinHeight = 800;
            this.docWinMaximized = false;
         }
         if(Capabilities.screenResolutionX <= this.docWinWidth || Capabilities.screenResolutionY <= this.docWinHeight)
         {
            this.docWinWidth = Capabilities.screenResolutionX - 5;
            this.docWinHeight = Capabilities.screenResolutionY - 5;
            this.docWinMaximized = true;
            GATracker.logPageView("SmallScreen/" + String(Capabilities.screenResolutionX) + "x" + String(Capabilities.screenResolutionX),"SmallScreen: " + String(Capabilities.screenResolutionX) + "x" + String(Capabilities.screenResolutionX));
         }
         if(GWizSettings.docWindow)
         {
            GWizSettings.docWindow.alwaysInFront = this.docWinStayOnTop;
         }
      }
      
      private function processXMLData(param1:XML) : XML
      {
         var _loc5_:String = null;
         var _loc6_:Object = null;
         GWizLoginBar.LoginParm = param1.loginName;
         if(param1.hasOwnProperty("fontSize"))
         {
            GWizSettings.fontManager.fontSize = param1.fontSize;
         }
         if(param1.hasOwnProperty("bkgdColor3D"))
         {
            GWizSettings.bkgdColor3D = param1.bkgdColor3D;
         }
         this.eulaAccepted = param1.eulaAccepted == "Yes" || param1.eulaAccepted == "true";
         GWizUtils.Units = param1.units;
         this.createDate = param1.createDate;
         if(this.createDate == "")
         {
            this.createDate = new Date().toString();
         }
         this.authenticateDate = param1.authenticateDate;
         this.authenticateDateAux = param1.authenticateDateAux;
         this.tbincs = param1.tbincs;
         this.tbincsAux = param1.tbincsAux;
         if(GWizCrypto.hash(this.authenticateDate,this.AUTHENTICATE_HASH_CODE,GWizCrypto.HASH_LEN) != this.tbincs)
         {
            this.authenticateDate = "";
         }
         if(GWizCrypto.hash(this.authenticateDateAux,this.AUTHENTICATE_HASH_CODE,GWizCrypto.HASH_LEN) != this.tbincsAux)
         {
            this.authenticateDateAux = "";
         }
         if(param1.hasOwnProperty("AT"))
         {
            this.authenticateType = param1.AT;
         }
         if(param1.hasOwnProperty("LGWL"))
         {
            this.lastGWLiteHP = param1.LGWL;
         }
         else
         {
            this.lastGWLiteHP = NaN;
         }
         this.logins = param1.loginsv2;
         if(param1.hasOwnProperty("trialLoginsv2"))
         {
            this.trialLogins = param1.trialLoginsv2;
         }
         else
         {
            this.trialLogins = 0;
         }
         if(param1.hasOwnProperty("noSetupReqd"))
         {
            this.noSetupReqd = param1.noSetupReqd;
         }
         else
         {
            this.noSetupReqd = false;
         }
         if(param1.hasOwnProperty("bigSalePop"))
         {
            this.bigSalePop = param1.bigSalePop;
            this.upsellPop = param1.upsellPop;
            this.crossSellPop = param1.crossSellPop;
            this.trialDiscountPop = param1.trialDiscountPop;
            this.renewalDiscountPop = param1.renewalDiscountPop;
         }
         if(param1.hasOwnProperty("backupDir"))
         {
            this.backupDir = param1.backupDir;
         }
         if(param1.hasOwnProperty("sharingDir"))
         {
            this.sharingDir = param1.sharingDir;
         }
         if(param1.hasOwnProperty("sharePrefs"))
         {
            this.sharePrefs = param1.sharePrefs == "true";
         }
         if(param1.hasOwnProperty("cribToolsCreated"))
         {
            GWizSettings.cribToolsCreated = param1.cribToolsCreated;
         }
         else
         {
            GWizSettings.cribToolsCreated = 0;
         }
         if(GWizUtils.Units.length == 0)
         {
            GWizUtils.Units = GWizUtils.INCHES_UNITS;
         }
         GWizMachSettings.currMachine = param1.currMachine;
         var _loc2_:String = param1.logo;
         if(_loc2_)
         {
            logoStr = _loc2_.length > 0 ? _loc2_ : logoStr;
         }
         var _loc3_:String = param1.gdtbasics;
         if(_loc3_ != "")
         {
            GDTBasics = true;
         }
         param1 = GWizFeedsSpeeds2.processXMLData(param1);
         this.showTips = param1.showTips != "false";
         this.xlo = param1.xlo;
         this.showedReleaseNotes = param1.showedReleaseNotes == "true";
         GWizMecSoftSetup.didMecSoftIntegration = param1.didMecSoftIntegration == "true";
         if(param1.hasOwnProperty("toolCribField1"))
         {
            GWizToolCrib.field1Name = param1.toolCribField1;
         }
         if(param1.hasOwnProperty("toolCribField2"))
         {
            GWizToolCrib.field2Name = param1.toolCribField2;
         }
         if(param1.hasOwnProperty("toolCribField3"))
         {
            GWizToolCrib.field3Name = param1.toolCribField3;
         }
         if(param1.hasOwnProperty("toolCribField4"))
         {
            GWizToolCrib.field4Name = param1.toolCribField4;
         }
         GWizSettings.priorVersion = param1.appVersion;
         GWizSettings.timeLastRun = param1.saveDate;
         GWizSettings.longTermConnectFails = param1.longTermConnectFails;
         GWizSettings.ccwFeedsSpeeds = param1.ccwFeedsSpeeds;
         GWizSettings.ccwWizardTab = param1.ccwWizardTab;
         GWizSettings.ccwEstimatorTab = param1.ccwEstimatorTab;
         GWizSettings.ccwAddEst = param1.ccwAddEst;
         param1 = GWizCCWMillOptions.processCCWXMLData(param1);
         var _loc4_:int = 0;
         while(_loc4_ < GWizMatBrowser2.MAX_HISTORY)
         {
            _loc5_ = "materialHist" + _loc4_;
            if(param1.hasOwnProperty(_loc5_ + "Name"))
            {
               (_loc6_ = new Object()).name = param1[_loc5_ + "Name"];
               _loc6_.name = this.xmlClean(_loc6_.name);
               if(GWizStringUtils.zapWhiteSpace(_loc6_.name).length > 0)
               {
                  _loc6_.family = param1[_loc5_ + "Family"];
                  _loc6_.family = this.xmlClean(_loc6_.family);
                  _loc6_.hardness = param1[_loc5_ + "Hardness"];
                  _loc6_.hardness = this.xmlClean(_loc6_.hardness);
                  GWizMatBrowser2.MaterialHistory.addItem(_loc6_);
               }
            }
            _loc4_++;
         }
         GWizSettings.versionBeingDownloaded = param1.versionBeingDownloaded;
         if(param1.hasOwnProperty("startWizardRun"))
         {
            GWizSettings.startWizardRun = param1.startWizardRun == "true";
         }
         else
         {
            GWizSettings.startWizardRun = false;
         }
         if(param1.hasOwnProperty("workTime"))
         {
            GWizSettings.workTime = param1.workTime;
            GWizSettings.shortTime = param1.shortTime;
            GWizSettings.longTime = param1.longTime;
         }
         if(param1.hasOwnProperty("showGettingStarted"))
         {
            this.showGettingStarted = param1.showGettingStarted == "true";
         }
         else
         {
            this.showGettingStarted = this.logins < 20;
         }
         if(param1.hasOwnProperty("currTheme"))
         {
            GWizStylePalette.currTheme = param1.currTheme;
         }
         if(param1.hasOwnProperty("flashSaleShown"))
         {
            this.flashSaleShown = true;
         }
         return param1;
      }
      
      private function xmlClean(param1:String) : String
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(param1.indexOf(GWizStringUtils.CR) >= 0)
         {
            param1 = param1.substr(0,param1.indexOf(GWizStringUtils.CR));
         }
         var _loc2_:String = "";
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            if(param1.charAt(_loc4_) == "<")
            {
               _loc3_ = true;
            }
            else if(param1.charAt(_loc4_) == ">")
            {
               _loc3_ = false;
            }
            else if(!_loc3_)
            {
               _loc2_ += param1.charAt(_loc4_);
            }
            _loc4_++;
         }
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         while(!_loc5_ && _loc6_ < 100)
         {
            if((_loc7_ = _loc2_.indexOf("&lt;")) >= 0)
            {
               if((_loc8_ = _loc2_.indexOf("&gt;")) >= _loc7_)
               {
                  _loc2_ = _loc2_.substr(0,_loc7_) + _loc2_.substr(_loc8_ + "&gt;".length);
               }
               else
               {
                  _loc5_ = true;
               }
            }
            else
            {
               _loc5_ = true;
            }
         }
         return _loc2_;
      }
      
      public function processAppSpecificXMLData(param1:XML) : XML
      {
         return param1;
      }
      
      private function createXMLData(param1:String) : XML
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc2_:XML = null;
         _loc2_ = <preferences/>;
         if(GWizSettings.docWindow)
         {
            _loc2_.windowState.@width = GWizSettings.docWindow.width;
            _loc2_.windowState.@height = GWizSettings.docWindow.height;
            _loc2_.docWinMaximized = GWizSettings.docWindow.stage.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED;
            _loc2_.docWinStayOnTop = this.docWinStayOnTop;
         }
         _loc2_.powerUser = this.powerUser;
         _loc2_.screenRes.@width = Capabilities.screenResolutionX;
         _loc2_.screenRes.@height = Capabilities.screenResolutionY;
         _loc2_.fontSize = GWizSettings.fontManager.fontSize;
         _loc2_.appVersion = GWizSettings.appVersion;
         if(this.createDate == "")
         {
            _loc2_.createDate = new Date().toString();
         }
         else
         {
            _loc2_.createDate = this.createDate;
         }
         if(this.authenticateDate != "")
         {
            _loc2_.authenticateDate = this.authenticateDate;
         }
         if(this.authenticateDateAux != "")
         {
            _loc2_.authenticateDateAux = this.authenticateDateAux;
         }
         this.authenticateType = GWizLoginMgr.checkLogin();
         _loc2_.AT = this.authenticateType;
         _loc2_.LGWL = this.lastGWLiteHP;
         _loc2_.longTermConnectFails = GWizSettings.longTermConnectFails;
         _loc2_.tbincs = GWizCrypto.hash(this.authenticateDate,this.AUTHENTICATE_HASH_CODE,GWizCrypto.HASH_LEN);
         _loc2_.tbincsAux = GWizCrypto.hash(this.authenticateDateAux,this.AUTHENTICATE_HASH_CODE,GWizCrypto.HASH_LEN);
         _loc2_.loginsv2 = this.logins;
         _loc2_.trialLoginsv2 = this.trialLogins;
         _loc2_.noSetupReqd = this.noSetupReqd;
         _loc2_.saveDate = new Date().toString();
         _loc2_.loginName = param1;
         _loc2_.eulaAccepted = this.eulaAccepted;
         _loc2_.units = GWizUtils.Units;
         _loc2_.currMachine = GWizMachSettings.currMachine;
         _loc2_.logo = GWizProvisions.provisionValue("logo");
         _loc2_.gdtbasics = GWizAbstractPrefs.GDTBasics;
         _loc2_ = GWizFeedsSpeeds2.createXMLData(_loc2_);
         _loc2_.showTips = this.showTips;
         _loc2_.xlo = this.xlo;
         _loc2_.showedReleaseNotes = this.showedReleaseNotes;
         _loc2_.didMecSoftIntegration = GWizMecSoftSetup.didMecSoftIntegration;
         _loc2_.toolCribField1 = GWizToolCrib.field1Name;
         _loc2_.toolCribField2 = GWizToolCrib.field2Name;
         _loc2_.toolCribField3 = GWizToolCrib.field3Name;
         _loc2_.toolCribField4 = GWizToolCrib.field4Name;
         _loc2_.ccwFeedsSpeeds = GWizSettings.ccwFeedsSpeeds;
         _loc2_.ccwWizardTab = GWizSettings.ccwWizardTab;
         _loc2_.ccwEstimatorTab = GWizSettings.ccwEstimatorTab;
         _loc2_.ccwAddEst = GWizSettings.ccwAddEst;
         _loc2_ = GWizCCWMillOptions.createCCWXMLData(_loc2_);
         var _loc3_:int = 0;
         while(_loc3_ < GWizMatBrowser2.MaterialHistory.length)
         {
            _loc4_ = "materialHist" + _loc3_;
            _loc5_ = GWizMatBrowser2.MaterialHistory.getItemAt(_loc3_);
            _loc2_[_loc4_ + "Name"] = _loc5_.name;
            _loc2_[_loc4_ + "Family"] = _loc5_.family;
            _loc2_[_loc4_ + "Hardness"] = _loc5_.hardness;
            _loc3_++;
         }
         _loc2_.versionBeingDownloaded = GWizSettings.versionBeingDownloaded;
         _loc2_.startWizardRun = GWizSettings.startWizardRun;
         _loc2_.backupDir = this.backupDir;
         _loc2_.sharingDir = this.sharingDir;
         _loc2_.sharePrefs = this.sharePrefs;
         _loc2_.bigSalePop = this.bigSalePop;
         _loc2_.upsellPop = this.upsellPop;
         _loc2_.crossSellPop = this.crossSellPop;
         _loc2_.trialDiscountPop = this.trialDiscountPop;
         _loc2_.renewalDiscountPop = this.renewalDiscountPop;
         _loc2_.workTime = GWizSettings.workTime;
         _loc2_.shortTime = GWizSettings.shortTime;
         _loc2_.longTime = GWizSettings.longTime;
         if(GWizLoginMgr.checkLogin() > GWizLoginMgr.TRIAL_ACCESS)
         {
            this.showGettingStarted = false;
         }
         _loc2_.showGettingStarted = this.showGettingStarted;
         _loc2_.currTheme = GWizStylePalette.currTheme;
         _loc2_.bkgdColor3D = GWizSettings.bkgdColor3D;
         _loc2_.cribToolsCreated = GWizSettings.cribToolsCreated;
         if(this.flashSaleShown)
         {
            _loc2_.flashSaleShown = true;
         }
         return _loc2_;
      }
      
      public function createAppSpecificXMLData(param1:XML) : XML
      {
         return param1;
      }
      
      private function writeXMLData(param1:XML, param2:File) : void
      {
         var outputString:String = null;
         var stream:FileStream = null;
         var xml:XML = param1;
         var file:File = param2;
         try
         {
            outputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
            outputString += xml.toXMLString();
            outputString = outputString.replace(/\n/g,File.lineEnding);
            stream = new FileStream();
            stream.open(file,FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error writing GWizAbstractPrefs: " + e.message);
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get prefsXML() : XML
      {
         return this._1288277177prefsXML;
      }
      
      private function set prefsXML(param1:XML) : void
      {
         var _loc2_:Object = this._1288277177prefsXML;
         if(_loc2_ !== param1)
         {
            this._1288277177prefsXML = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"prefsXML",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get liteMode() : Boolean
      {
         return this._1360222065liteMode;
      }
      
      public function set liteMode(param1:Boolean) : void
      {
         var _loc2_:Object = this._1360222065liteMode;
         if(_loc2_ !== param1)
         {
            this._1360222065liteMode = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"liteMode",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backupDir() : String
      {
         return this._1355327339backupDir;
      }
      
      public function set backupDir(param1:String) : void
      {
         var _loc2_:Object = this._1355327339backupDir;
         if(_loc2_ !== param1)
         {
            this._1355327339backupDir = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backupDir",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sharingDir() : String
      {
         return this._1660019183sharingDir;
      }
      
      public function set sharingDir(param1:String) : void
      {
         var _loc2_:Object = this._1660019183sharingDir;
         if(_loc2_ !== param1)
         {
            this._1660019183sharingDir = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sharingDir",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sharePrefs() : Boolean
      {
         return this._1801882095sharePrefs;
      }
      
      public function set sharePrefs(param1:Boolean) : void
      {
         var _loc2_:Object = this._1801882095sharePrefs;
         if(_loc2_ !== param1)
         {
            this._1801882095sharePrefs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sharePrefs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get powerUser() : Boolean
      {
         return this._845209200powerUser;
      }
      
      public function set powerUser(param1:Boolean) : void
      {
         var _loc2_:Object = this._845209200powerUser;
         if(_loc2_ !== param1)
         {
            this._845209200powerUser = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"powerUser",_loc2_,param1));
            }
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
