package
{
   import apps.GWizCNCSpecialOffer;
   import apps.GWizCalculator;
   import apps.GWizGWCTipWindow;
   import apps.GWizGeometry;
   import apps.GWizQuickReference;
   import apps.GWizSetupApp;
   import bubbletip.GWizGettingStarted;
   import bubbletip.GWizStartWizard;
   import cadcamwizp.GWizCadCamD;
   import comps.GWizAbout;
   import comps.GWizNumStep;
   import comps.GWizPopUpManager;
   import comps.GWizToDo;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import feedsspeeds.GWizFeedSpeedUnitTest;
   import feedsspeeds.GWizFeedsSpeeds2;
   import feedsspeeds.GWizOEMRepPopUp;
   import flash.desktop.NativeApplication;
   import flash.display.DisplayObject;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.NativeWindowDisplayStateEvent;
   import flash.globalization.LocaleID;
   import flash.system.Capabilities;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.utils.Proxy;
   import flash.utils.getDefinitionByName;
   import gwapi.GWizCalcAPIServer;
   import login.GWizAppVersion;
   import login.GWizCredentials;
   import login.GWizEvalPopUp;
   import login.GWizHelpButton;
   import login.GWizLoginBar;
   import login.GWizLoginMgr;
   import login.GWizLoginSplash;
   import login.GWizOfferBtn;
   import login.GWizProvisions;
   import loginp.GWizSplash;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.utils.ChangeWatcher;
   import mx.collections.ArrayCollection;
   import mx.containers.ViewStack;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.FlexGlobals;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.core.UIComponent;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.printing.FlexPrintJob;
   import mx.printing.FlexPrintJobScaleType;
   import mx.skins.ProgrammaticSkin;
   import mx.states.State;
   import mx.styles.CSSCondition;
   import mx.styles.CSSSelector;
   import mx.styles.CSSStyleDeclaration;
   import post.GWizPostVars;
   import skins.AppButtonBarSkin;
   import skins.GWizAccordionHeaderSkin;
   import skins.GWizStylePalette;
   import spark.components.ButtonBar;
   import spark.components.NavigatorContent;
   import spark.components.VGroup;
   import spark.components.WindowedApplication;
   import spark.layouts.TileLayout;
   import spark.layouts.VerticalLayout;
   import threads2.GWizThreadReference2;
   import tools.GWizOEMOfferPopup;
   import tools.GWizToolCrib;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizAppUpdater;
   import utils.GWizJustASec;
   import utils.GWizUncaughtErrors;
   import utils.GWizUtils;
   import utils.StylesheetMixin;
   
   use namespace mx_internal;
   
   public class GWizard extends WindowedApplication implements IBindingClient, IStateClient2
   {
      
      private static const log:ILogger = Log.getLogger("GWizard");
      
      private static const logoImg:Class = GWizard_logoImg;
      
      private static var thisInstance:WindowedApplication;
      
      private static var _1733121540appDownloadDir:String = "https://www.cnccookbook.com/download-g-wizard-calculator-manual/";
      
      private static var familyList:Array = [];
      
      private static var familyIndex:int = 0;
      
      public static var currDefaultFont:String = "Default";
      
      private static var gettingStartedDBGWC:ArrayCollection = new ArrayCollection([{
         "stepName":"Setup the Machine Profile",
         "stepTip":"Setup the Machine Profile so G-Wizard knows your machine\'s capabilities.",
         "stepDone":false,
         "stepPage":"https://www.cnccookbook.com/gwc-video-u/g-wizard-calculator-basic-setup/"
      },{
         "stepName":"Feeds and Speeds Tutorial",
         "stepTip":"Learn to Calculate Feeds and Speeds.",
         "stepDone":false,
         "stepPage":"https://www.cnccookbook.com/gwc-video-u/getting-started-with-feeds-and-speeds/"
      },{
         "stepName":"Ultimate Feeds/Speeds Cheat Sheet",
         "stepTip":"Learn to make G-Wizard do exactly what you want.",
         "stepDone":false,
         "stepPage":"https://www.cnccookbook.com/gwc-video-u/getting-started-with-feeds-and-speeds-part-2-cheat-sheet/"
      },{
         "stepName":"Feeds and Speeds for CNC Routers",
         "stepTip":"Feeds and Speeds for CNC Routers.",
         "stepDone":false,
         "stepPage":"https://www.cnccookbook.com/gwc-video-u/cnc-router-feeds-and-speeds-training/"
      },{
         "stepName":"CNC Like a Boss!",
         "stepTip":"Release more power with these options.",
         "stepDone":false,
         "stepPage":"https://www.cnccookbook.com/gwc-video-u/g-wizard-calculator-advanced-setup/"
      },{
         "stepName":"Materials Database",
         "stepTip":"Find the material you need to cut in the Material DB.",
         "stepDone":false,
         "stepPage":"https://www.cnccookbook.com/gwc-video-u/materials-database/"
      },{
         "stepName":"Manufacturer\'s Data",
         "stepTip":"See how to use Manufacturer\'s tool data in G-Wizard.",
         "stepDone":false,
         "stepPage":"https://www.cnccookbook.com/gwc-video-u/g-wizard-manufacturers-data/"
      },{
         "stepName":"Tool Crib",
         "stepTip":"Learn to organize Tools in the Tool Crib.",
         "stepDone":false,
         "stepPage":"https://www.cnccookbook.com/quick-start-using-g-wizards-tool-crib/"
      },{
         "stepName":"Tool Deflection",
         "stepTip":"Learn how G-Wizard can control tool deflection.",
         "stepDone":false,
         "stepPage":"http://www.cnccookbook.com/Slides/FineTuning/GWFineTuningCutOptimizer.html"
      },{
         "stepName":"High Speed Machining",
         "stepTip":"High Speed Machining and Trochoidal Milling.",
         "stepDone":false,
         "stepPage":"http://www.cnccookbook.com/Slides/FineTuning/GWFineTuningHSM.html"
      },{
         "stepName":"Chatter",
         "stepTip":"Learn how G-Wizard can control chatter.",
         "stepDone":false,
         "stepPage":"https://www.cnccookbook.com/chatter-in-machining-milling-lathe-vibration/"
      }]);
      
      public static const CADCAM_TAB:String = "CADCAM";
      
      public static const FEEDS_SPEEDS_TAB:String = "Feeds/Speeds";
      
      public static const TODO_TAB:String = "ToDo";
      
      public static const CALCULATOR_TAB:String = "Calculator";
      
      public static const GEOMETRY_TAB:String = "Geometry";
      
      public static const THREADS_TAB:String = "Threads";
      
      public static const QUICK_REF_TAB:String = "Quick Ref";
      
      public static const TOOL_CRIB_TAB:String = "Tool Crib";
      
      public static const SPECIAL_OFFER_TAB:String = "Special Offer";
      
      public static const SETUP_TAB:String = "Setup";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1980274249CADCAM:NavigatorContent;
      
      private var _2029254341CADCAMPanel:GWizCadCamD;
      
      private var _514227584FeedsSpeedsApp:GWizFeedsSpeeds2;
      
      private var _794467971FeedsSpeedsAppNav:NavigatorContent;
      
      private var _2147112089GWThreads:NavigatorContent;
      
      private var _1910664338Geometry:NavigatorContent;
      
      private var _2087375882LoginBar:GWizLoginBar;
      
      private var _2066718773QuickReferences:NavigatorContent;
      
      private var _79776349Setup:NavigatorContent;
      
      private var _1115436733SpecialOffer:GWizCNCSpecialOffer;
      
      private var _186340178SpecialOfferTab:NavigatorContent;
      
      public var _GWizard_StylesheetMixin1:StylesheetMixin;
      
      private var _119783385appAccordion:ViewStack;
      
      private var _1810499005appButtonLayout:TileLayout;
      
      private var _1373857312appButtons:ButtonBar;
      
      private var _338599810calcNavigator:NavigatorContent;
      
      private var _1318138705calcPanel:GWizCalculator;
      
      private var _151306980cribPanel:GWizToolCrib;
      
      private var _1310987056loginSplash:GWizLoginSplash;
      
      private var _159531819quickRefView:GWizQuickReference;
      
      private var _1435720292setupApp:GWizSetupApp;
      
      private var _1350419066theVBox:VGroup;
      
      private var _3565638todo:GWizToDo;
      
      private var _585420977todoNavigator:NavigatorContent;
      
      private var _984085632toolCrib:NavigatorContent;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private const APP_VERSION_PARM:String = "5.51";
      
      private var settings:GWizSettings = null;
      
      private var calcPanelRef:NavigatorContent = null;
      
      private var finishedInit:Boolean = false;
      
      private const NO_TIPS:Boolean = false;
      
      private var donePoppinTips:Boolean = false;
      
      private var uncaughtHandler:GWizUncaughtErrors;
      
      private var widthWatch:ChangeWatcher;
      
      private var heightWatch:ChangeWatcher;
      
      private var currSelection:NavigatorContent = null;
      
      private var oldIndex:int = -1;
      
      private var allowTabbing:Boolean = false;
      
      private var gotFirstUserTabSelection:Boolean = false;
      
      private var resizeExecuting:Boolean = false;
      
      private const TOOL_CRIB_IDX:int = 7;
      
      private var appSelectedCallback:Function;
      
      private const FORCE_LOGIN_SPLASH:Boolean = false;
      
      private var splashRemoved:Boolean = false;
      
      private var powerUserState:Boolean = true;
      
      mx_internal var _GWizard_StylesInit_done:Boolean = false;
      
      private var _embed_mxml_assets_toolcribicon_png_1073979020:Class;
      
      private var _embed_mxml_assets_ToDo_png_704726930:Class;
      
      private var _embed_mxml_assets_CADCAM_png_75089612:Class;
      
      private var _embed_mxml_assets_Threads_png_1602044862:Class;
      
      private var _embed_mxml_assets_Setup_png_947861090:Class;
      
      private var _embed_mxml_assets_QuickRef_png_1730674962:Class;
      
      private var _embed_mxml_assets_Geometry_png_382223122:Class;
      
      private var _embed_mxml_assets_Calculator_png_728424914:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizard()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.uncaughtHandler = new GWizUncaughtErrors();
         this._embed_mxml_assets_toolcribicon_png_1073979020 = GWizard__embed_mxml_assets_toolcribicon_png_1073979020;
         this._embed_mxml_assets_ToDo_png_704726930 = GWizard__embed_mxml_assets_ToDo_png_704726930;
         this._embed_mxml_assets_CADCAM_png_75089612 = GWizard__embed_mxml_assets_CADCAM_png_75089612;
         this._embed_mxml_assets_Threads_png_1602044862 = GWizard__embed_mxml_assets_Threads_png_1602044862;
         this._embed_mxml_assets_Setup_png_947861090 = GWizard__embed_mxml_assets_Setup_png_947861090;
         this._embed_mxml_assets_QuickRef_png_1730674962 = GWizard__embed_mxml_assets_QuickRef_png_1730674962;
         this._embed_mxml_assets_Geometry_png_382223122 = GWizard__embed_mxml_assets_Geometry_png_382223122;
         this._embed_mxml_assets_Calculator_png_728424914 = GWizard__embed_mxml_assets_Calculator_png_728424914;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizard_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_GWizardWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizard[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "GWizard: Machinist\'s Calculator";
         this.visible = false;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizard_Array2_c);
         this.currentState = "portrait";
         this._GWizard_StylesheetMixin1_i();
         this.addEventListener("initialize",this.___GWizard_WindowedApplication1_initialize);
         this.addEventListener("creationComplete",this.___GWizard_WindowedApplication1_creationComplete);
         this.addEventListener("applicationComplete",this.___GWizard_WindowedApplication1_applicationComplete);
         this.addEventListener("displayStateChange",this.___GWizard_WindowedApplication1_displayStateChange);
         states = [new State({
            "name":"portrait",
            "overrides":[]
         }),new State({
            "name":"landscape",
            "overrides":[]
         })];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      private static function setDefaultFont(param1:String) : void
      {
         var _loc2_:CSSStyleDeclaration = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         if(param1 && param1 != currDefaultFont)
         {
            _loc2_ = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("global");
            _loc2_.setStyle("fontFamily",param1);
            FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("global",_loc2_,true);
            currDefaultFont = param1;
            familyIndex = -1;
            _loc3_ = 0;
            while(_loc3_ < familyList.length)
            {
               if((_loc4_ = familyList[_loc3_]) == param1)
               {
                  familyIndex = _loc3_;
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      private static function setDefaultFontByIndex(param1:int) : void
      {
         setDefaultFont(familyList[param1]);
      }
      
      public static function tryNextFont() : void
      {
         setDefaultFontByIndex(familyIndex++ % familyList.length);
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizard._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get appDownloadDir() : String
      {
         return GWizard._1733121540appDownloadDir;
      }
      
      private static function set appDownloadDir(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizard._1733121540appDownloadDir;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizard,"appDownloadDir",_loc2_,param1));
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
         mx_internal::_GWizard_StylesInit();
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function enumFonts() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(GWizAbstractPrefs.isOEM)
         {
            _loc1_ = "Bahnschrift SemiBold SemiCondensed";
            _loc2_ = "Segoe UI Seminole";
            setDefaultFont(_loc2_);
         }
      }
      
      private function init() : void
      {
         if(this.finishedInit)
         {
            return;
         }
         if(GWizUtils.debug && GWizAbstractPrefs.isOEM)
         {
            GWizHelpButton.HelpBtnAuxFcn = GWizard.tryNextFont;
            GWizHelpButton.HelpBtnAuxFcn = GWizOEMRepPopUp.ContactRep;
         }
         thisInstance = this;
         if(GWizAbstractPrefs.isOEM)
         {
            appDownloadDir = GWizAbstractPrefs.oemInfo(GWizAbstractPrefs.APP_DOWNLOAD_DIR);
         }
         GWizPostVars.noLoad = true;
         GWizUtils.LogErrorContext = "GWizard.init";
         this.settings = new GWizSettings();
         GWizSettings.prefs = new GWizardCPrefs();
         GWizSettings.loginBar = this.LoginBar;
         GWizSettings.prefs.loadPreferences(this.LoginBar);
         GWizSettings.docWindow = this;
         var _loc1_:GWizSplash = new GWizSplash();
         _loc1_.open();
         GWizEvalPopUp.registerURL = "http://www.cnccookbook.com/GWSignup.html";
         GWizEvalPopUp.purchaseURL = GWizEvalPopUp.registerURL;
         this.finishedInit = true;
      }
      
      private function popTipWin(param1:Boolean) : void
      {
         if(!param1)
         {
            if(!GWizSettings.gotPreferences)
            {
               this.callLater(this.popTipWin);
               return;
            }
            if(true || this.donePoppinTips || !GWizSettings.prefs.showTips || GWizOfferBtn.didOfferPop || !GWizSettings.prefs.eulaWasAccepted())
            {
               return;
            }
         }
         var _loc2_:GWizGWCTipWindow = GWizGWCTipWindow(GWizPopUpManager.createPopUp(this,GWizGWCTipWindow,true));
         if(_loc2_)
         {
            _loc2_.setTipInfo();
            this.donePoppinTips = true;
         }
      }
      
      private function onCreationComplete() : void
      {
         var _loc1_:GWizJustASec = null;
         GWizOfferBtn.gotoSpecialOfferTab = this.selectSpecialOfferTab;
         this.enumFonts();
         GWizGettingStarted.gettingStartedURL = "https://www.cnccookbook.com/g-wizard-calculator-user-guide/";
         GWizGettingStarted.gettingStartedDB = gettingStartedDBGWC;
         GWizGettingStarted.gettingStartedGlossary = "https://www.cnccookbook.com/beginners-glossary-of-feeds-and-speeds-terminology/";
         GWizGettingStarted.gettingStartedUserGuide = "https://www.cnccookbook.com/g-wizard-calculator-user-guide/";
         GWizGettingStarted.gettingStartedVideoTours = "https://www.cnccookbook.com/gwc-video-u/";
         GWizGettingStarted.gettingStartedBeginnerExamples = "https://www.cnccookbook.com/beginner-feeds-speeds-examples/";
         GWizGettingStarted.gettingStartedProExamples = "http://www.cnccookbook.com/GWCalcProFeedsSpeedsExamples.htm";
         GWizGettingStarted.gettingStartedRouterExamples = "";
         this.setStyle("locale",flash.globalization.LocaleID.DEFAULT);
         this.setUnitsIndicator();
         GWizSettings.docWindow.nativeWindow.x = (Capabilities.screenResolutionX - GWizSettings.docWindow.width) / 2;
         GWizSettings.docWindow.nativeWindow.y = (Capabilities.screenResolutionY - GWizSettings.docWindow.height) / 2;
         GWizAbstractPrefs.powerUserCC.addFunction("GWizard",this.powerUserChanged,false);
         this.powerUserChanged();
         GWizSettings.appSelector = this.appSelector;
         this.callLater(this.firstSecurityCheck);
         if(GWizAbstractPrefs.isOEM)
         {
            GWizUtils.currApp = "Feeds/Speeds";
            this.title = GWizAbstractPrefs.oemInfo(GWizAbstractPrefs.WIN_TITLE);
         }
         this.addItemToContextMenu();
         GWizOfferBtn.testFcn = this.testFcn;
         this.Setup.createDeferredContent();
         if(!GWizAbstractPrefs.isOEM && false)
         {
            _loc1_ = new GWizJustASec(this.setupAPIServer,3);
            GWizCalcAPIServer.selectTabFcn = this.appSelector;
         }
         GWizStartWizard.launchStartWizard(null);
         GWizSettings._TabToFSCalculator = this.selectFSCalculator;
         GWizSettings._TabToToolCrib = this.selectToolCrib;
         if(GWizAbstractPrefs.isOEM)
         {
            GWizStylePalette.currTheme = GWizStylePalette.LIGHTEN_UP;
         }
         GWizStylePalette.onThemeChange();
         if(true || GWizLoginSplash.SHOW_MODAL_SETUP)
         {
            this.showLoginSplash();
         }
         else
         {
            this.removeLoginSplash();
         }
      }
      
      private function setupAPIServer() : void
      {
         GWizCalcAPIServer.apiServer = new GWizCalcAPIServer();
      }
      
      private function firstSecurityCheck() : void
      {
         if(!GWizSettings.gotPreferences)
         {
            this.callLater(this.firstSecurityCheck);
         }
         else
         {
            this.firstApp();
         }
      }
      
      private function firstApp() : void
      {
         var _loc3_:GWizJustASec = null;
         if(!this.SpecialOffer || !GWizOfferBtn.offersChecked)
         {
            _loc3_ = new GWizJustASec(this.firstApp);
            return;
         }
         var _loc1_:int = GWizLoginMgr.checkLogin();
         if(this.SpecialOffer.noSpecialOffer())
         {
            this.appAccordion.removeChild(this.SpecialOfferTab);
         }
         if(this.gotFirstUserTabSelection)
         {
            return;
         }
         if(!GWizAbstractPrefs.isOEM)
         {
            if(_loc1_ == GWizLoginMgr.LITE_ACCESS || _loc1_ == GWizLoginMgr.FULL_ACCESS)
            {
               GWizUtils.currApp = "CADCAM";
            }
            else
            {
               GWizUtils.currApp = "Setup";
            }
         }
         var _loc2_:DisplayObject = this.appAccordion.getChildByName(GWizUtils.currApp);
         if(_loc2_ != null)
         {
            this.appAccordion.selectedChild = _loc2_ as NavigatorContent;
         }
         else
         {
            this.appAccordion.selectedIndex = this.getTabIndexByName(SETUP_TAB);
         }
         this.doTabSelection(null);
      }
      
      private function testFcn() : void
      {
         var _loc1_:GWizFeedSpeedUnitTest = new GWizFeedSpeedUnitTest();
      }
      
      private function appInit() : void
      {
         if(loaderInfo.hasOwnProperty("uncaughtErrorEvents"))
         {
            IEventDispatcher(loaderInfo["uncaughtErrorEvents"]).addEventListener("uncaughtError",this.uncaughtHandler.uncaughtErrorHandler);
         }
         this.callLater(GWizSettings.loginBar.InitSecurity);
         stage.nativeWindow.addEventListener(Event.CLOSING,this.doExit);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false);
         GWizNumStep.checkUnitsCC.addFunction("GWizard",this.setUnitsIndicator);
         this.widthWatch = ChangeWatcher.watch(this,"width",this.onResize);
         this.heightWatch = ChangeWatcher.watch(this,"height",this.onResize);
         GWizSettings.appInitCompleted = true;
      }
      
      private function doTabSelection(param1:Event) : void
      {
         this.doTabSelectionAux(param1);
      }
      
      private function doTabSelectionAux(param1:Event, param2:int = -1) : void
      {
         var _loc4_:int = 0;
         var _loc5_:GWizJustASec = null;
         if(param1 && !(param1.currentTarget is ButtonBar))
         {
            return;
         }
         if(param1)
         {
            param2 = param1.currentTarget.selectedIndex;
            this.gotFirstUserTabSelection = true;
         }
         if(param2 < 0)
         {
            param2 = this.appAccordion.selectedIndex;
            if(param2 < 0)
            {
               return;
            }
         }
         var _loc3_:NavigatorContent = this.appAccordion.getChildAt(param2) as NavigatorContent;
         this.allowTabbing = false;
         if(_loc3_.label != "CADCAM" && _loc3_.label != "Feeds/Speeds" && _loc3_.label != "Threads")
         {
            this.allowTabbing = true;
         }
         if(!this.allowTabbing)
         {
            if((_loc4_ = GWizLoginMgr.checkLogin()) == GWizLoginMgr.LITE_ACCESS || _loc4_ == GWizLoginMgr.FULL_ACCESS || _loc4_ == GWizLoginMgr.TRIAL_ACCESS)
            {
               this.allowTabbing = true;
            }
            else
            {
               this.allowTabbing = false;
            }
         }
         this.allowTabbing = this.allowTabbing && !GWizAppVersion.mandatoryMsg;
         if(_loc3_.label == "CADCAM" && GWizAbstractPrefs.isOEM)
         {
            this.allowTabbing = false;
            this.callLater(GWizOEMOfferPopup.OEMOfferPopup);
         }
         if(this.allowTabbing)
         {
            if(_loc3_.label != "")
            {
               GATracker.logPageView(_loc3_.label,"Tabbed to " + _loc3_.label);
            }
            this.currSelection = this.appAccordion.getChildAt(param2) as NavigatorContent;
            this.hideTab(NavigatorContent(this.appAccordion.selectedChild));
            this.selectTab(this.currSelection);
         }
         else
         {
            if(param1)
            {
               param1.stopImmediatePropagation();
               param1.preventDefault();
            }
            _loc5_ = new GWizJustASec(this.shutErDown);
            GATracker.logPageView("TabLockout","TabLockout");
         }
         if(this.currSelection)
         {
            GWizUtils.currApp = this.currSelection.name;
         }
         this.setUnitsIndicator();
         this.setAboutAppMsg();
         this.oldIndex = Math.min(this.oldIndex,this.appAccordion.numChildren - 1);
         if(this.oldIndex >= 0)
         {
            _loc3_ = this.appAccordion.getChildAt(this.oldIndex) as NavigatorContent;
            if(_loc3_.label.indexOf("Feeds") >= 0)
            {
               GWizFeedsSpeeds2.logFeedsSpeeds();
            }
         }
         this.oldIndex = this.appAccordion.selectedIndex;
      }
      
      private function setUnitsIndicator(param1:Object = null) : Boolean
      {
         var _loc2_:String = null;
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            _loc2_ = "          Inches";
         }
         else
         {
            _loc2_ = "          Metric";
         }
         this.status = _loc2_ + "          " + GWizCredentials.getConnectStatus();
         if(GWizSettings.docWindow)
         {
            this.status += "    WizSize: " + GWizSettings.docWindow.width + "x" + GWizSettings.docWindow.height;
         }
         if(GWizAbstractPrefs.isOEM)
         {
            this.status += "    Powered by CNCCookbook\'s G-Wizard Calculator.";
         }
         return true;
      }
      
      private function onResize(param1:Event = null) : void
      {
         if(!this.resizeExecuting)
         {
            this.callLater(this.handleResize);
         }
         this.resizeExecuting = true;
         GWizSettings.FeedsSpeedsApp.onResize(param1);
      }
      
      private function handleResize() : void
      {
         this.setUnitsIndicator();
         GWizSettings.FeedsSpeedsApp.width = this.width;
         GWizSettings.FeedsSpeedsApp.height = this.height;
         if(this.width >= this.appButtonLayout.columnCount * this.appButtonLayout.columnWidth)
         {
            this.appButtonLayout.requestedRowCount = 1;
            this.appButtonLayout.columnAlign = "justifyUsingWidth";
            this.appButtonLayout.columnWidth = NaN;
            GWizSettings.prefs.phoneMode = false;
         }
         else
         {
            this.appButtonLayout.requestedRowCount = this.appAccordion.numElements;
            this.appButtonLayout.columnAlign = "left";
            this.appButtonLayout.columnWidth = this.width;
            GWizSettings.prefs.phoneMode = true;
         }
         this.resizeExecuting = false;
      }
      
      private function hideTab(param1:NavigatorContent) : void
      {
         if(this.setupApp && param1.label == this.setupApp.SETUP_APP_NAME)
         {
            this.setupApp.hideMe(null);
         }
         if(param1.label == "Tool Crib" && this.cribPanel)
         {
            this.cribPanel.onHide();
         }
      }
      
      private function selectTab(param1:NavigatorContent) : void
      {
         if(param1.label == "CADCAM Wizard")
         {
            ++GWizSettings.ccwWizardTab;
         }
         else if(param1.label == GWizFeedsSpeeds2.APP_NAME)
         {
            ++GWizSettings.ccwFeedsSpeeds;
         }
         else if(param1.label == this.setupApp.SETUP_APP_NAME)
         {
            this.setupApp.showMe(null);
         }
         if(param1.label == "Quick Refs")
         {
            if(this.quickRefView)
            {
               this.quickRefView.showMe();
            }
         }
         else if(this.quickRefView)
         {
            this.quickRefView.hideMe();
         }
         if(param1.label == "Tool Crib" && this.cribPanel)
         {
            this.cribPanel.onShow();
         }
      }
      
      private function set credCheck(param1:int) : void
      {
         var _loc2_:GWizJustASec = null;
         if(param1 == GWizCredentials.CRED_NO_GRACE || param1 == GWizCredentials.CRED_UNPAID_NOTRIAL)
         {
            this.LoginBar.securityMsg();
            _loc2_ = new GWizJustASec(this.shutErDown);
         }
         else
         {
            this.LoginBar.CheckSecurity();
         }
         this.setUnitsIndicator();
      }
      
      private function shutErDown() : void
      {
         if(!this.allowTabbing || !this.LoginBar.isRegistered())
         {
            this.appAccordion.selectedIndex = this.appAccordion.length - 1;
         }
      }
      
      private function selectFSCalculator() : void
      {
         this.appAccordion.selectedIndex = this.getFSCalculatorIndex();
      }
      
      private function getFSCalculatorIndex() : int
      {
         return this.getTabIndexByName(FEEDS_SPEEDS_TAB);
      }
      
      private function getTabIndexByName(param1:String) : int
      {
         var _loc5_:NavigatorContent = null;
         var _loc2_:int = 1;
         var _loc3_:int = _loc2_;
         var _loc4_:int = 0;
         while(_loc4_ < this.appAccordion.numChildren)
         {
            if((_loc5_ = this.appAccordion.getChildAt(_loc4_) as NavigatorContent).label == param1)
            {
               return _loc4_;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function selectToolCrib() : void
      {
         this.appAccordion.selectedIndex = this.getTabIndexByName(TOOL_CRIB_TAB);
      }
      
      private function selectSpecialOfferTab() : void
      {
         this.gotFirstUserTabSelection = true;
         if(this.SpecialOffer)
         {
            this.appAccordion.selectedIndex = this.getTabIndexByName(SPECIAL_OFFER_TAB);
         }
         else
         {
            this.callLater(this.selectSpecialOfferTab);
         }
      }
      
      protected function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 67;
         var _loc3_:int = 68;
         var _loc4_:int = 87;
         var _loc5_:int = 70;
         var _loc6_:int = 71;
         var _loc7_:int = 84;
         var _loc8_:int = 81;
         var _loc9_:int = 83;
         var _loc10_:int = 80;
         var _loc11_:int = -1;
         if(param1.altKey == true)
         {
            switch(param1.keyCode)
            {
               case _loc2_:
               case _loc3_:
                  _loc11_ = this.getTabIndexByName(CALCULATOR_TAB);
                  break;
               case _loc4_:
                  _loc11_ = this.getTabIndexByName(CADCAM_TAB);
                  break;
               case _loc5_:
                  _loc11_ = this.getFSCalculatorIndex();
                  break;
               case _loc6_:
                  _loc11_ = this.getTabIndexByName(GEOMETRY_TAB);
                  break;
               case _loc7_:
                  _loc11_ = this.getTabIndexByName(THREADS_TAB);
                  break;
               case _loc8_:
                  _loc11_ = this.getTabIndexByName(QUICK_REF_TAB);
                  break;
               case _loc9_:
                  _loc11_ = this.getTabIndexByName(SETUP_TAB);
                  break;
               case _loc10_:
                  this.doPrint(null);
            }
         }
         if(_loc11_ != -1 && param1.altKey)
         {
            this.doTabSelectionAux(param1,_loc11_);
         }
      }
      
      private function setAboutAppMsg() : void
      {
         var _loc1_:String = null;
         var _loc2_:Number = NaN;
         var _loc3_:String = null;
         if(GWizProvisions.provisionsLoaded)
         {
            _loc1_ = "G-Wizard Lite Mode. Feeds/Speeds shows the limit.";
            _loc2_ = 0;
            _loc3_ = GWizProvisions.provisionValue(GWizProvisions.GWCALC_LITE_HP);
            if(_loc3_)
            {
               _loc2_ = Number(_loc3_);
               if(!isNaN(_loc2_))
               {
                  if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
                  {
                     _loc2_ *= GWizUtils.KW_PER_HP;
                  }
                  GWizAbout.appMessage = _loc1_;
               }
            }
         }
      }
      
      private function appSelector(param1:String, param2:Function = null) : void
      {
         var _loc7_:Object = null;
         GATracker.logPageView(param1,"Tabbed to " + param1);
         var _loc3_:Object = this.appAccordion.selectedChild;
         var _loc4_:Object = _loc3_;
         var _loc5_:int = 0;
         while(_loc5_ < this.appAccordion.numChildren)
         {
            if((_loc7_ = this.appAccordion.getChildAt(_loc5_)).hasOwnProperty("label") && _loc7_.label == param1)
            {
               _loc3_ = _loc7_;
               break;
            }
            _loc5_++;
         }
         var _loc6_:NavigatorContent = _loc3_ as NavigatorContent;
         this.appAccordion.selectedChild = _loc6_;
         if(param2 != null)
         {
            this.appSelectedCallback = param2;
            this.waitForAppSelection();
         }
      }
      
      private function waitForAppSelection() : void
      {
         var _loc1_:Object = this.appAccordion.selectedChild;
         var _loc2_:NavigatorContent = _loc1_ as NavigatorContent;
         if(_loc2_.numElements > 0)
         {
            this.appSelectedCallback(_loc2_.getElementAt(0) as Object);
         }
         else
         {
            this.callLater(this.waitForAppSelection);
         }
      }
      
      public function detachCalculator() : GWizCalculator
      {
         this.calcPanelRef = this.appAccordion.removeChildAt(0) as NavigatorContent;
         return this.calcPanelRef.getElementAt(0) as GWizCalculator;
      }
      
      public function attachCalculator(param1:UIComponent) : void
      {
         this.calcPanelRef.addElement(param1);
         var _loc2_:int = this.appAccordion.selectedIndex;
         this.appAccordion.addChildAt(this.calcPanelRef,0);
         this.appAccordion.selectedIndex = _loc2_ + 1;
      }
      
      private function addItemToContextMenu() : void
      {
         var _loc1_:ContextMenu = null;
         var _loc2_:ContextMenuItem = null;
         _loc2_ = new ContextMenuItem("Print...");
         _loc2_.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.doPrint);
         _loc1_ = FlexGlobals.topLevelApplication.contextMenu;
         _loc1_.hideBuiltInItems();
         _loc1_.customItems.push(_loc2_);
      }
      
      private function doPrint(param1:ContextMenuEvent) : void
      {
         var _loc2_:FlexPrintJob = new FlexPrintJob();
         _loc2_.printAsBitmap = false;
         if(_loc2_.start())
         {
            _loc2_.addObject(this.appAccordion.selectedChild,FlexPrintJobScaleType.SHOW_ALL);
            _loc2_.send();
         }
      }
      
      private function doExit(param1:Event) : void
      {
         var temp:int = 0;
         var url:String = null;
         var evt:Event = param1;
         try
         {
            GWizUtils.LogError("GWizard.doExit()\n");
            evt.preventDefault();
            temp = GWizCredentials.credStatus;
            GWizCredentials.credStatus = temp;
            if(!GWizLoginMgr.currentOrPastSubscriber() && !GWizAbstractPrefs.isOEM)
            {
               if(GWizOfferBtn.exitToFlashSale)
               {
                  url = "https://www.cnccookbook.com/g-wizard-calculator-pricing-trial-flash/";
               }
               else
               {
                  url = "https://www.cnccookbook.com/g-wizard-calculator-pricing-trial/";
               }
               GWizGettingStarted.doExitPage(url);
               GATracker.logPageView("TrialLogout","TrialLogout");
            }
            GWizSettings.prefs.appClosing();
            GWizUtils.LogError("GWizCalcAPIServer.apiServer.shutdown()\n");
            if(GWizCalcAPIServer.apiServer)
            {
               GWizCalcAPIServer.apiServer.shutdown();
            }
            if(!GWizSettings.prefs.powerUser)
            {
               GATracker.logPageView("EasyModeSessionEnded","EasyModeSessionEnded");
            }
            GATracker.logPageView("SessionEnded","SessionEnded");
            GWizUtils.LogError("GWizAppUpdater.runNewVersion()\n");
            GWizAppUpdater.runNewVersion();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("GWizard.doExit(): Threw an exception.\n" + e.message);
         }
         NativeApplication.nativeApplication.exit();
      }
      
      private function showCADCAMAux() : void
      {
         var _loc1_:GWizJustASec = null;
         if(this.CADCAMPanel)
         {
            this.CADCAMPanel.showMe();
         }
         else
         {
            _loc1_ = new GWizJustASec(this.showCADCAMAux);
         }
      }
      
      private function hideCADCAMAux() : void
      {
         var _loc1_:GWizJustASec = null;
         if(this.CADCAMPanel)
         {
            this.CADCAMPanel.hideMe();
         }
         else
         {
            _loc1_ = new GWizJustASec(this.showCADCAMAux);
         }
      }
      
      private function timerEnded() : void
      {
         var _loc1_:int = 2;
         this.nativeWindow.activate();
         this.appAccordion.selectedIndex = this.getTabIndexByName(TODO_TAB);
      }
      
      private function showLoginSplash() : void
      {
         if(this.splashRemoved || GWizLoginSplash.modalSetupStage >= GWizLoginSplash.SETUP_DONE_TAB)
         {
            return;
         }
         this.appAccordion.includeInLayout = false;
         this.appAccordion.enabled = false;
         this.appAccordion.visible = false;
         this.appButtons.includeInLayout = false;
         this.appButtons.enabled = false;
         this.appButtons.visible = false;
         GWizUtils.LogError("showLoginSplash()");
      }
      
      private function removeLoginSplash(param1:Boolean = false) : void
      {
         if(this.splashRemoved)
         {
            GWizUtils.LogError("removeLoginSplash( splash already removed )");
            return;
         }
         if(this.theVBox && this.loginSplash && this.theVBox.getElementIndex(this.loginSplash) >= 0 && this.appAccordion && this.appButtons)
         {
            this.theVBox.removeElement(this.loginSplash);
            this.splashRemoved = true;
            this.appAccordion.includeInLayout = true;
            this.appAccordion.enabled = true;
            this.appAccordion.visible = true;
            this.appButtons.includeInLayout = true;
            this.appButtons.enabled = true;
            this.appButtons.visible = true;
            return;
         }
         GWizUtils.LogError("removeLoginSplash( retry later )");
         this.callLater(this.removeLoginSplash);
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         if(GWizSettings.prefs.powerUser != this.powerUserState)
         {
            if(GWizSettings.prefs.powerUser)
            {
               if(GWizAbstractPrefs.isOEM)
               {
                  this.appAccordion.addElementAt(this.CADCAM,1);
               }
               this.appAccordion.addElementAt(this.todoNavigator,2);
               this.appAccordion.addElementAt(this.calcNavigator,3);
               this.appAccordion.addElementAt(this.Geometry,4);
               this.appAccordion.addElementAt(this.GWThreads,5);
               this.appAccordion.addElementAt(this.QuickReferences,6);
               this.oldIndex = 7;
            }
            else
            {
               if(GWizAbstractPrefs.isOEM)
               {
                  this.appAccordion.removeElement(this.CADCAM);
               }
               this.appAccordion.removeElement(this.todoNavigator);
               this.appAccordion.removeElement(this.calcNavigator);
               this.appAccordion.removeElement(this.Geometry);
               this.appAccordion.removeElement(this.GWThreads);
               this.appAccordion.removeElement(this.QuickReferences);
               this.oldIndex = 3;
            }
            this.powerUserState = GWizSettings.prefs.powerUser;
         }
         return true;
      }
      
      private function _GWizard_StylesheetMixin1_i() : StylesheetMixin
      {
         var _loc1_:StylesheetMixin = new StylesheetMixin();
         _loc1_.initialized(this,"_GWizard_StylesheetMixin1");
         this._GWizard_StylesheetMixin1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizard_StylesheetMixin1",this._GWizard_StylesheetMixin1);
         return _loc1_;
      }
      
      private function _GWizard_Array2_c() : Array
      {
         return [this._GWizard_VGroup1_i()];
      }
      
      private function _GWizard_VGroup1_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizard_GWizLoginBar1_i(),this._GWizard_ButtonBar1_i(),this._GWizard_GWizLoginSplash1_i(),this._GWizard_ViewStack1_i()];
         _loc1_.id = "theVBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theVBox = _loc1_;
         BindingManager.executeBindings(this,"theVBox",this.theVBox);
         return _loc1_;
      }
      
      private function _GWizard_GWizLoginBar1_i() : GWizLoginBar
      {
         var _loc1_:GWizLoginBar = new GWizLoginBar();
         _loc1_.percentWidth = 100;
         _loc1_.appNameParm = "GWizard";
         _loc1_.appLongNameParm = "G-Wizard Machinist\'s Calculator";
         _loc1_.appProvParm = "GWC";
         _loc1_.earliestTrial = "9/1/2015";
         _loc1_.popTipWin = this.popTipWin;
         _loc1_.id = "LoginBar";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LoginBar = _loc1_;
         BindingManager.executeBindings(this,"LoginBar",this.LoginBar);
         return _loc1_;
      }
      
      private function _GWizard_ButtonBar1_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.percentWidth = 100;
         _loc1_.requireSelection = true;
         _loc1_.horizontalCenter = 0;
         _loc1_.verticalCenter = 0;
         _loc1_.iconField = "icon";
         _loc1_.layout = this._GWizard_TileLayout1_i();
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("skinClass",AppButtonBarSkin);
         _loc1_.addEventListener("click",this.__appButtons_click);
         _loc1_.id = "appButtons";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.appButtons = _loc1_;
         BindingManager.executeBindings(this,"appButtons",this.appButtons);
         return _loc1_;
      }
      
      private function _GWizard_TileLayout1_i() : TileLayout
      {
         var _loc1_:TileLayout = new TileLayout();
         _loc1_.requestedRowCount = 1;
         _loc1_.columnAlign = "justifyUsingWidth";
         _loc1_.paddingLeft = 0;
         _loc1_.paddingRight = 0;
         _loc1_.horizontalGap = 0;
         _loc1_.verticalGap = 0;
         this.appButtonLayout = _loc1_;
         BindingManager.executeBindings(this,"appButtonLayout",this.appButtonLayout);
         return _loc1_;
      }
      
      public function __appButtons_click(param1:MouseEvent) : void
      {
         this.doTabSelection(param1);
      }
      
      private function _GWizard_GWizLoginSplash1_i() : GWizLoginSplash
      {
         var _loc1_:GWizLoginSplash = new GWizLoginSplash();
         _loc1_.id = "loginSplash";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.loginSplash = _loc1_;
         BindingManager.executeBindings(this,"loginSplash",this.loginSplash);
         return _loc1_;
      }
      
      private function _GWizard_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.addEventListener("valueCommit",this.__appAccordion_valueCommit);
         temp.id = "appAccordion";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"appAccordion",
            "events":{"valueCommit":"__appAccordion_valueCommit"},
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"CADCAM",
                  "events":{
                     "show":"__CADCAM_show",
                     "hide":"__CADCAM_hide"
                  },
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"CADCAM",
                        "name":"CADCAM",
                        "icon":_embed_mxml_assets_CADCAM_png_75089612,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizard_Array4_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"FeedsSpeedsAppNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Feeds/Speeds",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizard_Array5_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"todoNavigator",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"ToDo",
                        "name":"ToDo",
                        "icon":_embed_mxml_assets_ToDo_png_704726930,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizard_Array6_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"calcNavigator",
                  "events":{"show":"__calcNavigator_show"},
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Calculator",
                        "name":"Calculator",
                        "icon":_embed_mxml_assets_Calculator_png_728424914,
                        "layout":_GWizard_VerticalLayout1_c(),
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizard_Array7_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Geometry",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Geometry",
                        "name":"Geometry",
                        "icon":_embed_mxml_assets_Geometry_png_382223122,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizard_Array8_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"GWThreads",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "name":"GWThreads",
                        "label":"Threads",
                        "icon":_embed_mxml_assets_Threads_png_1602044862,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizard_Array9_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"QuickReferences",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "name":"Quick References",
                        "label":"Quick Ref",
                        "icon":_embed_mxml_assets_QuickRef_png_1730674962,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizard_Array10_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"toolCrib",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "name":"ToolCrib",
                        "label":"Tool Crib",
                        "icon":_embed_mxml_assets_toolcribicon_png_1073979020,
                        "creationPolicy":"all",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizard_Array11_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"SpecialOfferTab",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "name":"SpecialOffer",
                        "label":"Special Offer",
                        "creationPolicy":"all",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizard_Array12_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Setup",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "name":"Setup",
                        "label":"Setup",
                        "icon":_embed_mxml_assets_Setup_png_947861090,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizard_Array13_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.appAccordion = temp;
         BindingManager.executeBindings(this,"appAccordion",this.appAccordion);
         return temp;
      }
      
      public function __appAccordion_valueCommit(param1:FlexEvent) : void
      {
         this.doTabSelection(param1);
      }
      
      private function _GWizard_Array4_c() : Array
      {
         return [this._GWizard_GWizCadCamD1_i()];
      }
      
      private function _GWizard_GWizCadCamD1_i() : GWizCadCamD
      {
         var _loc1_:GWizCadCamD = new GWizCadCamD();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "CADCAMPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CADCAMPanel = _loc1_;
         BindingManager.executeBindings(this,"CADCAMPanel",this.CADCAMPanel);
         return _loc1_;
      }
      
      public function __CADCAM_show(param1:FlexEvent) : void
      {
         this.showCADCAMAux();
      }
      
      public function __CADCAM_hide(param1:FlexEvent) : void
      {
         this.hideCADCAMAux();
      }
      
      private function _GWizard_Array5_c() : Array
      {
         return [this._GWizard_GWizFeedsSpeeds21_i()];
      }
      
      private function _GWizard_GWizFeedsSpeeds21_i() : GWizFeedsSpeeds2
      {
         var _loc1_:GWizFeedsSpeeds2 = new GWizFeedsSpeeds2();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "FeedsSpeedsApp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FeedsSpeedsApp = _loc1_;
         BindingManager.executeBindings(this,"FeedsSpeedsApp",this.FeedsSpeedsApp);
         return _loc1_;
      }
      
      private function _GWizard_Array6_c() : Array
      {
         return [this._GWizard_GWizToDo1_i()];
      }
      
      private function _GWizard_GWizToDo1_i() : GWizToDo
      {
         var _loc1_:GWizToDo = new GWizToDo();
         _loc1_.id = "todo";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.todo = _loc1_;
         BindingManager.executeBindings(this,"todo",this.todo);
         return _loc1_;
      }
      
      private function _GWizard_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizard_Array7_c() : Array
      {
         return [this._GWizard_GWizCalculator1_i()];
      }
      
      private function _GWizard_GWizCalculator1_i() : GWizCalculator
      {
         var _loc1_:GWizCalculator = new GWizCalculator();
         _loc1_.name = "Calculator";
         _loc1_.id = "calcPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.calcPanel = _loc1_;
         BindingManager.executeBindings(this,"calcPanel",this.calcPanel);
         return _loc1_;
      }
      
      public function __calcNavigator_show(param1:FlexEvent) : void
      {
         this.calcPanel.restoreFocus();
      }
      
      private function _GWizard_Array8_c() : Array
      {
         return [this._GWizard_GWizGeometry1_c()];
      }
      
      private function _GWizard_GWizGeometry1_c() : GWizGeometry
      {
         var _loc1_:GWizGeometry = new GWizGeometry();
         _loc1_.name = "Geometry";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizard_Array9_c() : Array
      {
         return [this._GWizard_GWizThreadReference21_c()];
      }
      
      private function _GWizard_GWizThreadReference21_c() : GWizThreadReference2
      {
         var _loc1_:GWizThreadReference2 = new GWizThreadReference2();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizard_Array10_c() : Array
      {
         return [this._GWizard_GWizQuickReference1_i()];
      }
      
      private function _GWizard_GWizQuickReference1_i() : GWizQuickReference
      {
         var _loc1_:GWizQuickReference = new GWizQuickReference();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "quickRefView";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.quickRefView = _loc1_;
         BindingManager.executeBindings(this,"quickRefView",this.quickRefView);
         return _loc1_;
      }
      
      private function _GWizard_Array11_c() : Array
      {
         return [this._GWizard_GWizToolCrib1_i()];
      }
      
      private function _GWizard_GWizToolCrib1_i() : GWizToolCrib
      {
         var _loc1_:GWizToolCrib = new GWizToolCrib();
         _loc1_.id = "cribPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cribPanel = _loc1_;
         BindingManager.executeBindings(this,"cribPanel",this.cribPanel);
         return _loc1_;
      }
      
      private function _GWizard_Array12_c() : Array
      {
         return [this._GWizard_GWizCNCSpecialOffer1_i()];
      }
      
      private function _GWizard_GWizCNCSpecialOffer1_i() : GWizCNCSpecialOffer
      {
         var _loc1_:GWizCNCSpecialOffer = new GWizCNCSpecialOffer();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "SpecialOffer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SpecialOffer = _loc1_;
         BindingManager.executeBindings(this,"SpecialOffer",this.SpecialOffer);
         return _loc1_;
      }
      
      private function _GWizard_Array13_c() : Array
      {
         return [this._GWizard_GWizSetupApp1_i()];
      }
      
      private function _GWizard_GWizSetupApp1_i() : GWizSetupApp
      {
         var _loc1_:GWizSetupApp = new GWizSetupApp();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "setupApp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.setupApp = _loc1_;
         BindingManager.executeBindings(this,"setupApp",this.setupApp);
         return _loc1_;
      }
      
      public function ___GWizard_WindowedApplication1_initialize(param1:FlexEvent) : void
      {
         this.init();
      }
      
      public function ___GWizard_WindowedApplication1_creationComplete(param1:FlexEvent) : void
      {
         this.onCreationComplete();
      }
      
      public function ___GWizard_WindowedApplication1_applicationComplete(param1:FlexEvent) : void
      {
         this.appInit();
      }
      
      public function ___GWizard_WindowedApplication1_displayStateChange(param1:NativeWindowDisplayStateEvent) : void
      {
         this.callLater(this.onResize);
      }
      
      private function _GWizard_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Array
         {
            var _loc1_:* = [ColorPalette];
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },null,"_GWizard_StylesheetMixin1.palettes");
         result[1] = new Binding(this,function():*
         {
            return GWizCredentials.credStatus;
         },function(param1:*):void
         {
            credCheck = param1;
         },"credCheck");
         result[2] = new Binding(this,function():String
         {
            var _loc1_:* = APP_VERSION_PARM;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"LoginBar.appVersionParm");
         result[3] = new Binding(this,function():String
         {
            var _loc1_:* = appDownloadDir;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"LoginBar.appInstallURL");
         result[4] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"LoginBar.ShowSupport");
         result[5] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"LoginBar.ShowTips");
         result[6] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"LoginBar.ShowGettingStarted");
         result[7] = new Binding(this,function():String
         {
            var _loc1_:* = GWizCredentials.GWC_LIST;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"LoginBar.appTrialSubscList");
         result[8] = new Binding(this,null,null,"appButtons.dataProvider","appAccordion");
         result[9] = new Binding(this,function():uint
         {
            return ColorPalette.primary4;
         },function(param1:uint):void
         {
            appButtons.setStyle("chromeColor",param1);
         },"appButtons.chromeColor");
         result[10] = new Binding(this,function():Function
         {
            return removeLoginSplash;
         },null,"loginSplash.doClose");
         result[11] = new Binding(this,function():String
         {
            var _loc1_:* = GWizFeedsSpeeds2.APP_NAME;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"FeedsSpeedsAppNav.name");
         result[12] = new Binding(this,function():uint
         {
            return ColorPalette.primary1;
         },function(param1:uint):void
         {
            FeedsSpeedsAppNav.setStyle("backgroundColor",param1);
         },"FeedsSpeedsAppNav.backgroundColor");
         result[13] = new Binding(this,function():String
         {
            var _loc1_:* = GWizFeedsSpeeds2.APP_NAME;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"FeedsSpeedsApp.name");
         result[14] = new Binding(this,function():Function
         {
            return timerEnded;
         },null,"todo.timerEnded");
         result[15] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            toolCrib.setStyle("backgroundColor",param1);
         },"toolCrib.backgroundColor");
         result[16] = new Binding(this,function():Class
         {
            return logoImg;
         },null,"setupApp.logoImg");
         return result;
      }
      
      private function _GWizard_bindingExprs() : void
      {
         var _loc1_:* = undefined;
         this.credCheck = GWizCredentials.credStatus;
      }
      
      mx_internal function _GWizard_StylesInit() : void
      {
         var style:CSSStyleDeclaration = null;
         var effects:Array = null;
         var conditions:Array = null;
         var condition:CSSCondition = null;
         var selector:CSSSelector = null;
         if(mx_internal::_GWizard_StylesInit_done)
         {
            return;
         }
         mx_internal::_GWizard_StylesInit_done = true;
         selector = null;
         conditions = null;
         conditions = null;
         selector = new CSSSelector("global",conditions,selector);
         style = styleManager.getStyleDeclaration("global");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.fontSize = 12;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcNumButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcNumButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 734012;
               this.chromeColor = 13421772;
               this.fontSize = 18;
               this.fillAlphas = [1,1,1,1];
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcOperatorButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcOperatorButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 734012;
               this.chromeColor = "primary4";
               this.fontSize = 18;
               this.fillAlphas = [1,1,1,1];
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcEqualButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcEqualButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 734012;
               this.chromeColor = "complement4";
               this.fontSize = 18;
               this.fillAlphas = [1,1,1,1];
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcFnButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcFnButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.paddingTop = 0;
               this.color = 734012;
               this.fillColors = [9934743,9934743,39270,39270];
               this.fontSize = 10;
               this.fillAlphas = [1,1,1,1];
               this.paddingBottom = 0;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcCategoryButtons");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcCategoryButtons");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.buttonStyleName = "calcCategoryButton";
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcCategoryButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcCategoryButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.cornerRadius = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = null;
         selector = new CSSSelector("*",conditions,selector);
         style = styleManager.getStyleDeclaration("*");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.cornerRadius = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","geoTabBar");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".geoTabBar");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 15658734;
               this.backgroundColor = 0;
               this.chromeColor = 2904884;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","threadTabBar");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".threadTabBar");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 15658734;
               this.backgroundColor = "secondarya3";
               this.chromeColor = "secondarya4";
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcCategoryPanel");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcCategoryPanel");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 2236962;
               this.backgroundAlpha = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","geoView");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".geoView");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.backgroundColor = 15398372;
               this.backgroundAlpha = 1;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcTextEdit");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcTextEdit");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.borderStyle = "none";
               this.fontSize = 12;
               this.disabledColor = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","resistorBand");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".resistorBand");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.fillColors = [16255241,16255241];
               this.fillAlphas = [1,1];
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcTitleBar");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcTitleBar");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.contentBackgroundAlpha = 1;
               this.color = 15658734;
               this.chromeColor = 8947848;
               this.contentBackgroundColor = 8947848;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","detachButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".detachButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.skin = ProgrammaticSkin;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","radDegToggleButtonBar");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".radDegToggleButtonBar");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.fontSize = 7;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","radDegToggleButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".radDegToggleButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 1184274;
               this.fontSize = 7;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","radDegFirstToggleButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".radDegFirstToggleButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 1184274;
               this.fontSize = 7;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","radDegLastToggleButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".radDegLastToggleButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 1184274;
               this.fontSize = 7;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","radDegSelectedToggleButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".radDegSelectedToggleButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 1118549;
               this.fontSize = 7;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","customAccordionHead");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".customAccordionHead");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.fontWeight = "bold";
               this.color = "primary3";
               this.textRollOverColor = 16777215;
               this.fontSize = 12;
               this.textSelectedColor = "complement5";
               this.skin = GWizAccordionHeaderSkin;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","tabHeader");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".tabHeader");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.fontWeight = "normal";
               this.fontSizeDelta = -2;
               this.fillAlphas = [0.6,0.7,0.75,0.65];
            };
         }
         selector = null;
         conditions = null;
         conditions = null;
         selector = new CSSSelector("comps.GWizPopUp",conditions,selector);
         conditions = null;
         selector = new CSSSelector("spark.components.TextArea",conditions,selector);
         style = styleManager.getStyleDeclaration("comps.GWizPopUp spark.components.TextArea");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = null;
         selector = new CSSSelector("comps.GWizPopUp",conditions,selector);
         conditions = null;
         selector = new CSSSelector("spark.components.DataGrid",conditions,selector);
         style = styleManager.getStyleDeclaration("comps.GWizPopUp spark.components.DataGrid");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = null;
         selector = new CSSSelector("comps.GWizPopUp",conditions,selector);
         conditions = null;
         selector = new CSSSelector("spark.components.Button",conditions,selector);
         style = styleManager.getStyleDeclaration("comps.GWizPopUp spark.components.Button");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = null;
         selector = new CSSSelector("comps.GWizPopUp",conditions,selector);
         conditions = null;
         selector = new CSSSelector("spark.components.NumericStepper",conditions,selector);
         style = styleManager.getStyleDeclaration("comps.GWizPopUp spark.components.NumericStepper");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = null;
         selector = new CSSSelector("comps.GWizPopUp",conditions,selector);
         conditions = null;
         selector = new CSSSelector("spark.components.TextInput",conditions,selector);
         style = styleManager.getStyleDeclaration("comps.GWizPopUp spark.components.TextInput");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = null;
         selector = new CSSSelector("comps.GWizPopUp",conditions,selector);
         conditions = null;
         selector = new CSSSelector("spark.components.List",conditions,selector);
         style = styleManager.getStyleDeclaration("comps.GWizPopUp spark.components.List");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 0;
            };
         }
         styleManager.initProtoChainRoots();
      }
      
      [Bindable(event="propertyChange")]
      public function get CADCAM() : NavigatorContent
      {
         return this._1980274249CADCAM;
      }
      
      public function set CADCAM(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1980274249CADCAM;
         if(_loc2_ !== param1)
         {
            this._1980274249CADCAM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CADCAM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CADCAMPanel() : GWizCadCamD
      {
         return this._2029254341CADCAMPanel;
      }
      
      public function set CADCAMPanel(param1:GWizCadCamD) : void
      {
         var _loc2_:Object = this._2029254341CADCAMPanel;
         if(_loc2_ !== param1)
         {
            this._2029254341CADCAMPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CADCAMPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FeedsSpeedsApp() : GWizFeedsSpeeds2
      {
         return this._514227584FeedsSpeedsApp;
      }
      
      public function set FeedsSpeedsApp(param1:GWizFeedsSpeeds2) : void
      {
         var _loc2_:Object = this._514227584FeedsSpeedsApp;
         if(_loc2_ !== param1)
         {
            this._514227584FeedsSpeedsApp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FeedsSpeedsApp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FeedsSpeedsAppNav() : NavigatorContent
      {
         return this._794467971FeedsSpeedsAppNav;
      }
      
      public function set FeedsSpeedsAppNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._794467971FeedsSpeedsAppNav;
         if(_loc2_ !== param1)
         {
            this._794467971FeedsSpeedsAppNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FeedsSpeedsAppNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GWThreads() : NavigatorContent
      {
         return this._2147112089GWThreads;
      }
      
      public function set GWThreads(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._2147112089GWThreads;
         if(_loc2_ !== param1)
         {
            this._2147112089GWThreads = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GWThreads",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Geometry() : NavigatorContent
      {
         return this._1910664338Geometry;
      }
      
      public function set Geometry(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1910664338Geometry;
         if(_loc2_ !== param1)
         {
            this._1910664338Geometry = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Geometry",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LoginBar() : GWizLoginBar
      {
         return this._2087375882LoginBar;
      }
      
      public function set LoginBar(param1:GWizLoginBar) : void
      {
         var _loc2_:Object = this._2087375882LoginBar;
         if(_loc2_ !== param1)
         {
            this._2087375882LoginBar = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LoginBar",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get QuickReferences() : NavigatorContent
      {
         return this._2066718773QuickReferences;
      }
      
      public function set QuickReferences(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._2066718773QuickReferences;
         if(_loc2_ !== param1)
         {
            this._2066718773QuickReferences = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"QuickReferences",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Setup() : NavigatorContent
      {
         return this._79776349Setup;
      }
      
      public function set Setup(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._79776349Setup;
         if(_loc2_ !== param1)
         {
            this._79776349Setup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Setup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SpecialOffer() : GWizCNCSpecialOffer
      {
         return this._1115436733SpecialOffer;
      }
      
      public function set SpecialOffer(param1:GWizCNCSpecialOffer) : void
      {
         var _loc2_:Object = this._1115436733SpecialOffer;
         if(_loc2_ !== param1)
         {
            this._1115436733SpecialOffer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SpecialOffer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SpecialOfferTab() : NavigatorContent
      {
         return this._186340178SpecialOfferTab;
      }
      
      public function set SpecialOfferTab(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._186340178SpecialOfferTab;
         if(_loc2_ !== param1)
         {
            this._186340178SpecialOfferTab = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SpecialOfferTab",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get appAccordion() : ViewStack
      {
         return this._119783385appAccordion;
      }
      
      public function set appAccordion(param1:ViewStack) : void
      {
         var _loc2_:Object = this._119783385appAccordion;
         if(_loc2_ !== param1)
         {
            this._119783385appAccordion = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"appAccordion",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get appButtonLayout() : TileLayout
      {
         return this._1810499005appButtonLayout;
      }
      
      public function set appButtonLayout(param1:TileLayout) : void
      {
         var _loc2_:Object = this._1810499005appButtonLayout;
         if(_loc2_ !== param1)
         {
            this._1810499005appButtonLayout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"appButtonLayout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get appButtons() : ButtonBar
      {
         return this._1373857312appButtons;
      }
      
      public function set appButtons(param1:ButtonBar) : void
      {
         var _loc2_:Object = this._1373857312appButtons;
         if(_loc2_ !== param1)
         {
            this._1373857312appButtons = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"appButtons",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get calcNavigator() : NavigatorContent
      {
         return this._338599810calcNavigator;
      }
      
      public function set calcNavigator(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._338599810calcNavigator;
         if(_loc2_ !== param1)
         {
            this._338599810calcNavigator = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"calcNavigator",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get calcPanel() : GWizCalculator
      {
         return this._1318138705calcPanel;
      }
      
      public function set calcPanel(param1:GWizCalculator) : void
      {
         var _loc2_:Object = this._1318138705calcPanel;
         if(_loc2_ !== param1)
         {
            this._1318138705calcPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"calcPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cribPanel() : GWizToolCrib
      {
         return this._151306980cribPanel;
      }
      
      public function set cribPanel(param1:GWizToolCrib) : void
      {
         var _loc2_:Object = this._151306980cribPanel;
         if(_loc2_ !== param1)
         {
            this._151306980cribPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cribPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get loginSplash() : GWizLoginSplash
      {
         return this._1310987056loginSplash;
      }
      
      public function set loginSplash(param1:GWizLoginSplash) : void
      {
         var _loc2_:Object = this._1310987056loginSplash;
         if(_loc2_ !== param1)
         {
            this._1310987056loginSplash = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"loginSplash",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get quickRefView() : GWizQuickReference
      {
         return this._159531819quickRefView;
      }
      
      public function set quickRefView(param1:GWizQuickReference) : void
      {
         var _loc2_:Object = this._159531819quickRefView;
         if(_loc2_ !== param1)
         {
            this._159531819quickRefView = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"quickRefView",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get setupApp() : GWizSetupApp
      {
         return this._1435720292setupApp;
      }
      
      public function set setupApp(param1:GWizSetupApp) : void
      {
         var _loc2_:Object = this._1435720292setupApp;
         if(_loc2_ !== param1)
         {
            this._1435720292setupApp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"setupApp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theVBox() : VGroup
      {
         return this._1350419066theVBox;
      }
      
      public function set theVBox(param1:VGroup) : void
      {
         var _loc2_:Object = this._1350419066theVBox;
         if(_loc2_ !== param1)
         {
            this._1350419066theVBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theVBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get todo() : GWizToDo
      {
         return this._3565638todo;
      }
      
      public function set todo(param1:GWizToDo) : void
      {
         var _loc2_:Object = this._3565638todo;
         if(_loc2_ !== param1)
         {
            this._3565638todo = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"todo",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get todoNavigator() : NavigatorContent
      {
         return this._585420977todoNavigator;
      }
      
      public function set todoNavigator(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._585420977todoNavigator;
         if(_loc2_ !== param1)
         {
            this._585420977todoNavigator = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"todoNavigator",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolCrib() : NavigatorContent
      {
         return this._984085632toolCrib;
      }
      
      public function set toolCrib(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._984085632toolCrib;
         if(_loc2_ !== param1)
         {
            this._984085632toolCrib = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolCrib",_loc2_,param1));
            }
         }
      }
   }
}
