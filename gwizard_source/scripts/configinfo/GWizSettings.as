package configinfo
{
   import bubbletip.GWizAbstractBubbleMsgs;
   import cadcamwiz.GWizCCWThreading;
   import feedsspeeds.GWizFeedsSpeeds2;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.filesystem.File;
   import flash.system.Capabilities;
   import localdb.GWizCustIPTSQL;
   import localdb.GWizCutKBSQL;
   import localdb.GWizLocalSQL;
   import login.GWizLoginBar;
   import login.GWizLoginMgr;
   import loginp.GWizSplash;
   import material.GWizMaterialsDB;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import notebook.GWizNotebook;
   import post.GWizPostSettings;
   import spark.components.WindowedApplication;
   import tools.GWizToolCrib;
   import tools.GWizToolCribData;
   import utils.FontSizeManager;
   import utils.GWizCallChain;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   public class GWizSettings implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizSettings");
      
      public static const DEBUG_SHARING:Boolean = false;
      
      private static var _1687620514fontManager:FontSizeManager = new FontSizeManager();
      
      public static var prefs:GWizAbstractPrefs = null;
      
      public static var loginMgr:GWizLoginMgr = new GWizLoginMgr();
      
      public static var splash:GWizSplash = null;
      
      public static var splashDone:Boolean = false;
      
      public static var timeLastRun:String;
      
      private static var _connectionFails:int = 0;
      
      public static var connectionSuccess:int = 0;
      
      public static var longTermConnectFails:int = 0;
      
      public static const TIMEIT_TRACE:Boolean = false;
      
      public static var appInitCompleted:Boolean = false;
      
      public static const WINDOW_WIDTH:Number = 1280;
      
      public static const WINDOW_HEIGHT:Number = 800;
      
      public static var docWindow:WindowedApplication = null;
      
      public static var FilePath:String = "";
      
      public static var FileName:String = "";
      
      public static var selectToolCC:GWizCallChain = new GWizCallChain();
      
      public static var matchToolCC:GWizCallChain = new GWizCallChain();
      
      public static var selectCribCC:GWizCallChain = new GWizCallChain();
      
      public static var matchCribCC:GWizCallChain = new GWizCallChain();
      
      private static var _toolSelection:int;
      
      private static var _cribSelection:int;
      
      public static var selectMaterialCC:GWizCallChain = new GWizCallChain();
      
      public static var matchMaterialCC:GWizCallChain = new GWizCallChain();
      
      public static var selectMaterialHardnessCC:GWizCallChain = new GWizCallChain();
      
      public static var matchMaterialHardnessCC:GWizCallChain = new GWizCallChain();
      
      public static var selectMaterialSelectionCC:GWizCallChain = new GWizCallChain();
      
      public static var matchMaterialSelectionCC:GWizCallChain = new GWizCallChain();
      
      private static var _materialChoice:Number = 0;
      
      private static var _materialHardness:Number = -1;
      
      private static var _jankaHardness:Number = -1;
      
      private static var _materialSelection:String = "";
      
      public static var showAdvanced:Boolean = false;
      
      private static var _FeedsSpeedsApp:GWizFeedsSpeeds2 = null;
      
      public static var cacheToolGUIDS:Boolean = false;
      
      public static var _TabToFSCalculator:Function = null;
      
      public static var _TabToToolCrib:Function = null;
      
      public static var threadingCCW:GWizCCWThreading;
      
      public static var minorDia:Number;
      
      public static var majorDia:Number;
      
      public static var threadPitch:Number;
      
      public static var threadDepth:Number;
      
      public static var appSelector:Function = null;
      
      private static var _1384865074deflectPct:Number = 20;
      
      private static var _204866589hsmWidthPct:Number = 80;
      
      private static var _1350939175theCrib:GWizToolCrib = null;
      
      private static var _1934424466cribData:GWizToolCribData = new GWizToolCribData();
      
      private static var _1066509568cribGeneration:int = 0;
      
      public static var cribToolsCreated:int = 0;
      
      public static var startupTime:Date = new Date();
      
      private static var _1288295491prefsDir:String = File.applicationStorageDirectory.nativePath;
      
      public static const PREFS_NAME:String = "preferences.xml";
      
      public static const MACHINES_NAME:String = "machines.xml";
      
      public static const IPT_NAME:String = "ipt.xml";
      
      public static var savePrefs:Boolean = true;
      
      public static var saveMachines:Boolean = true;
      
      public static var saveToolCrib:Boolean = true;
      
      public static var saveCodes:Boolean = true;
      
      public static var saveGCVars:Boolean = true;
      
      public static var savePost:Boolean = true;
      
      private static var _100936469_gotPreferences:Boolean = false;
      
      private static var forceRunnin:Boolean = false;
      
      public static var startWizardRun:Boolean = false;
      
      public static var bubbleMsgs:GWizAbstractBubbleMsgs;
      
      private static var _1289522917exeDir:String = "";
      
      private static var _794136500appName:String = "";
      
      private static var _1326693272appLongName:String = "";
      
      private static var _appVersion:String;
      
      public static var priorVersion:String;
      
      public static var appVersionChanged:Boolean = false;
      
      public static const UPDATE_NOW:int = 0;
      
      public static const UPDATE_WEEK:int = 1;
      
      public static const UPDATE_URGENT:int = 2;
      
      private static var _296041844updatePref:int = UPDATE_WEEK;
      
      public static var loginBar:GWizLoginBar = null;
      
      private static var _323879260gcodeFileExtensions:String = "*.ncc;*.nc;*.ngc;*.txt;*.cnc;*.tap;*.prg;*.pgm;*.m;*.ecs;*.ncf;*.fan;*.fnc;*.dnc;*.fgc;*.din;*.hnc;*.gcd;*.rol;*.ncd;*.sbp";
      
      public static var db:GWizLocalSQL = null;
      
      public static var cutKBSQL:GWizCutKBSQL = null;
      
      private static var _1998022214TortoiseImg:Class = GWizSettings_TortoiseImg;
      
      private static var _1933820137HareImg:Class = GWizSettings_HareImg;
      
      public static var refNotebook:GWizNotebook = null;
      
      public static var post:GWizPostSettings = new GWizPostSettings();
      
      public static const DEFAULT_BKGD_COLOR_3D:Number = 10526880;
      
      public static var bkgdColor3D:Number = DEFAULT_BKGD_COLOR_3D;
      
      public static var ccwFeedsSpeeds:int = 0;
      
      public static var ccwWizardTab:int = 0;
      
      public static var ccwEstimatorTab:int = 0;
      
      public static var ccwAddEst:int = 0;
      
      public static var versionBeingDownloaded:Number = NaN;
      
      private static var _34839934workTime:Number = 25;
      
      private static var _2028032663shortTime:Number = 5;
      
      private static var _2074415255longTime:Number = 10;
      
      public static const DEFAULT_SHOP_RATE:String = "Default Shop Rate";
      
      public static const MATERIAL_MARKUP:String = "Material, Markup";
      
      public static var lookupCost:Function = null;
      
      public static var mdb:GWizMaterialsDB = new GWizMaterialsDB();
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizSettings()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         GWizUtils.LogErrorContext = "GWizSettings.GWizSettings";
         GWizUtils.debug = Capabilities.isDebugger;
         db = new GWizLocalSQL();
         cutKBSQL = new GWizCutKBSQL(db);
         GWizFeedsSpeeds2.custIPTSQL = new GWizCustIPTSQL(db);
      }
      
      public static function set connectionFails(param1:int) : void
      {
         _connectionFails = param1;
      }
      
      public static function get connectionFails() : int
      {
         return _connectionFails;
      }
      
      public static function set toolSelection(param1:int) : void
      {
         _toolSelection = param1;
      }
      
      public static function get toolSelection() : int
      {
         return _toolSelection;
      }
      
      public static function set cribSelection(param1:int) : void
      {
         _cribSelection = param1;
      }
      
      public static function get cribSelection() : int
      {
         return _cribSelection;
      }
      
      public static function get materialChoice() : Number
      {
         return _materialChoice;
      }
      
      public static function set materialChoice(param1:Number) : void
      {
         _materialChoice = param1;
         matchMaterialCC.callChain(param1);
         selectMaterialCC.callChain(param1);
      }
      
      public static function get materialHardness() : Number
      {
         return _materialHardness;
      }
      
      public static function set materialHardness(param1:Number) : void
      {
         _materialHardness = param1;
         matchMaterialHardnessCC.callChain(param1);
         selectMaterialHardnessCC.callChain(param1);
      }
      
      public static function set jankaHardness(param1:Number) : void
      {
         _jankaHardness = param1;
      }
      
      public static function get jankaHardness() : Number
      {
         return _jankaHardness;
      }
      
      public static function get materialSelection() : String
      {
         return _materialSelection;
      }
      
      public static function set materialSelection(param1:String) : void
      {
         _materialSelection = param1;
         matchMaterialSelectionCC.callChain(param1);
         selectMaterialSelectionCC.callChain(param1);
      }
      
      public static function set FeedsSpeedsApp(param1:GWizFeedsSpeeds2) : void
      {
         _FeedsSpeedsApp = param1;
      }
      
      public static function get FeedsSpeedsApp() : GWizFeedsSpeeds2
      {
         return _FeedsSpeedsApp;
      }
      
      public static function TabToFSCalculator() : void
      {
         if(_TabToFSCalculator != null)
         {
            _TabToFSCalculator();
         }
      }
      
      public static function TabToToolCrib() : void
      {
         if(_TabToFSCalculator != null)
         {
            _TabToToolCrib();
         }
      }
      
      public static function set gotPreferences(param1:Boolean) : void
      {
         _gotPreferences = param1;
         if(param1)
         {
            if(!forceRunnin)
            {
               forceLoginMgr();
            }
         }
      }
      
      public static function get gotPreferences() : Boolean
      {
         return _gotPreferences;
      }
      
      private static function forceLoginMgr() : void
      {
         var _loc1_:GWizJustASec = null;
         forceRunnin = true;
         if(loginMgr)
         {
            GWizSettings.loginMgr.waitForPrefs();
         }
         else
         {
            _loc1_ = new GWizJustASec(forceLoginMgr);
         }
      }
      
      public static function get appVersion() : String
      {
         return _appVersion;
      }
      
      public static function set appVersion(param1:String) : void
      {
         appVersionChanged = _appVersion && _appVersion != param1;
         _appVersion = param1;
      }
      
      public static function getPrefsDir() : File
      {
         prefsDir = File.applicationStorageDirectory.nativePath;
         return File.applicationStorageDirectory;
      }
      
      public static function getPrefsFile(param1:String = "") : File
      {
         var _loc2_:File = null;
         if(param1 != "")
         {
            _loc2_ = getPrefsDir().resolvePath(param1);
         }
         else
         {
            _loc2_ = getPrefsDir();
         }
         return _loc2_;
      }
      
      [Bindable(event="propertyChange")]
      public static function get fontManager() : FontSizeManager
      {
         return GWizSettings._1687620514fontManager;
      }
      
      public static function set fontManager(param1:FontSizeManager) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._1687620514fontManager;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"fontManager",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get deflectPct() : Number
      {
         return GWizSettings._1384865074deflectPct;
      }
      
      public static function set deflectPct(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._1384865074deflectPct;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"deflectPct",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get hsmWidthPct() : Number
      {
         return GWizSettings._204866589hsmWidthPct;
      }
      
      public static function set hsmWidthPct(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._204866589hsmWidthPct;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"hsmWidthPct",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get theCrib() : GWizToolCrib
      {
         return GWizSettings._1350939175theCrib;
      }
      
      public static function set theCrib(param1:GWizToolCrib) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._1350939175theCrib;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"theCrib",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get cribData() : GWizToolCribData
      {
         return GWizSettings._1934424466cribData;
      }
      
      public static function set cribData(param1:GWizToolCribData) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._1934424466cribData;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"cribData",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get cribGeneration() : int
      {
         return GWizSettings._1066509568cribGeneration;
      }
      
      public static function set cribGeneration(param1:int) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._1066509568cribGeneration;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"cribGeneration",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get prefsDir() : String
      {
         return GWizSettings._1288295491prefsDir;
      }
      
      public static function set prefsDir(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._1288295491prefsDir;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"prefsDir",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get _gotPreferences() : Boolean
      {
         return GWizSettings._100936469_gotPreferences;
      }
      
      public static function set _gotPreferences(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._100936469_gotPreferences;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"_gotPreferences",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get exeDir() : String
      {
         return GWizSettings._1289522917exeDir;
      }
      
      public static function set exeDir(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._1289522917exeDir;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"exeDir",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get appName() : String
      {
         return GWizSettings._794136500appName;
      }
      
      public static function set appName(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._794136500appName;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"appName",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get appLongName() : String
      {
         return GWizSettings._1326693272appLongName;
      }
      
      public static function set appLongName(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._1326693272appLongName;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"appLongName",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get updatePref() : int
      {
         return GWizSettings._296041844updatePref;
      }
      
      public static function set updatePref(param1:int) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._296041844updatePref;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"updatePref",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get gcodeFileExtensions() : String
      {
         return GWizSettings._323879260gcodeFileExtensions;
      }
      
      public static function set gcodeFileExtensions(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._323879260gcodeFileExtensions;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"gcodeFileExtensions",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get TortoiseImg() : Class
      {
         return GWizSettings._1998022214TortoiseImg;
      }
      
      public static function set TortoiseImg(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._1998022214TortoiseImg;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"TortoiseImg",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get HareImg() : Class
      {
         return GWizSettings._1933820137HareImg;
      }
      
      public static function set HareImg(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._1933820137HareImg;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"HareImg",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get workTime() : Number
      {
         return GWizSettings._34839934workTime;
      }
      
      public static function set workTime(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._34839934workTime;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"workTime",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get shortTime() : Number
      {
         return GWizSettings._2028032663shortTime;
      }
      
      public static function set shortTime(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._2028032663shortTime;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"shortTime",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get longTime() : Number
      {
         return GWizSettings._2074415255longTime;
      }
      
      public static function set longTime(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSettings._2074415255longTime;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSettings,"longTime",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
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
