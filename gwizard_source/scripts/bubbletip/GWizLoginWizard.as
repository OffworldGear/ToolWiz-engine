package bubbletip
{
   import chimp.GWizMandrill;
   import comps.BusyIndicator;
   import comps.GWizPanel;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import comps.skins.PanelSkin;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.getDefinitionByName;
   import flashx.textLayout.conversion.TextConverter;
   import login.GWizAppVersion;
   import login.GWizCredentials;
   import login.GWizEvalPopUp;
   import login.GWizLoginBar;
   import login.GWizLoginFB;
   import login.GWizUserData;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.containers.ViewStack;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NavigatorContent;
   import spark.components.TextArea;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import spark.layouts.VerticalLayout;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizLoginWizard extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizLoginWizard");
      
      public static const EMAIL_STATE:String = "Email";
      
      private static const LOGIN_STATE:String = "Login";
      
      private static const LOGIN_FAIL_STATE:String = "LoginFail";
      
      private static const MANDATORY_STATE:String = "Mandatory";
      
      private static const EULA_STATE:String = "EULA";
      
      private static var wizTries:int = 60;
      
      public static var loginWizardActive:Boolean = false;
      
      public static var theWiz:GWizLoginWizard = null;
      
      private static var launchState:String = "Email";
      
      private static var stopRecursion:Boolean = false;
      
      private static var createState:String;
      
      private static var stateParm:String = LOGIN_STATE;
      
      private static var allowLaunchLoginWizardAux:Boolean = true;
      
      private static var calledLoginDone:Boolean = false;
      
      public static var appDoExit:Function;
      
      private static var didCredCheck:Boolean = false;
      
      private static var theEULA:String = "";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _265563294EulaNav:NavigatorContent;
      
      private var _1229315684LoginFailNav:NavigatorContent;
      
      private var _2087387418LoginNav:NavigatorContent;
      
      private var _1242701654MandatoryNav:NavigatorContent;
      
      private var _1500376454SetupNav:NavigatorContent;
      
      private var _2117796519acceptMsg:Label;
      
      private var _119783385appAccordion:ViewStack;
      
      private var _1399083509eulaTxt:TextArea;
      
      private var _97193171fail1:Label;
      
      private var _97193172fail2:Label;
      
      private var _97193173fail3:Label;
      
      private var _97193174fail4:Label;
      
      private var _1393646923loginFailBtn:Button;
      
      private var _737656245loginFailEmail:Label;
      
      private var _498783941loginHelpURL:TextInput;
      
      private var _1847046761nextBtn:Button;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var stopLoginDoneAuxRecursion:Boolean = false;
      
      private var exitOK:Boolean = false;
      
      private var inNextStep:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizLoginWizard()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizLoginWizard_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_bubbletip_GWizLoginWizardWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizLoginWizard[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Login Wizard";
         this.width = 640;
         this.height = 480;
         this.okLabel = "";
         this.cancelLabel = "";
         this.mxmlContent = [this._GWizLoginWizard_VGroup1_c()];
         this.addEventListener("creationComplete",this.___GWizLoginWizard_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function launchLoginWizard(param1:String, param2:Boolean = false) : void
      {
         var _loc3_:GWizLoginFB = null;
         if(stopRecursion)
         {
            return;
         }
         stopRecursion = true;
         createState = param1;
         if(GWizLoginBar.LoginParm != "Guest" && param1 != "Email")
         {
            createLoginWizard();
         }
         else
         {
            GWizLoginFB.loginDoneCallback = loginDone;
            if(param2)
            {
               _loc3_ = GWizLoginFB.showLoginFB();
            }
         }
         stopRecursion = false;
      }
      
      public static function revalidateLogin() : void
      {
         didCredCheck = false;
         launchLoginWizard(GWizLoginWizard.EMAIL_STATE);
      }
      
      public static function centerPopUp() : void
      {
         createLoginWizard();
      }
      
      private static function createLoginWizard() : void
      {
         var _loc1_:GWizJustASec = null;
         launchState = createState;
         if(GWizSettings.gotPreferences && GWizSettings.splashDone && createState != "Email")
         {
            if(!loginWizardActive || !theWiz)
            {
               theWiz = GWizLoginWizard(GWizPopUpManager.createPopUp(null,GWizLoginWizard,false));
               loginWizardActive = theWiz != null;
            }
            else
            {
               theWiz.visible = true;
               theWiz.onCC();
            }
            return;
         }
         if(wizTries > 0 && allowLaunchLoginWizardAux)
         {
            stateParm = launchState;
            allowLaunchLoginWizardAux = false;
            _loc1_ = new GWizJustASec(launchLoginWizardAux);
            --wizTries;
         }
      }
      
      private static function launchLoginWizardAux() : void
      {
         launchLoginWizard(stateParm);
         allowLaunchLoginWizardAux = true;
      }
      
      private static function loginDone() : void
      {
         calledLoginDone = true;
         createLoginWizard();
         GWizSettings.loginBar.CheckSecurity();
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizLoginWizard._watcherSetupUtil = param1;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         var factory:IFlexModuleFactory = param1;
         super.moduleFactory = factory;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
         if(!this.styleDeclaration)
         {
            this.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
         }
         this.styleDeclaration.defaultFactory = function():void
         {
            this.color = 0;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onCC() : void
      {
         GWizUtils.assert(appDoExit != null);
         title = "Login Wizard for " + GWizSettings.appLongName;
         GWizLoginFB.user = GWizUserData.instance();
         this.loginDoneAux();
         this.loadEULA();
         this.showCloseButton = false;
      }
      
      private function loginDoneAux() : void
      {
         if(this.stopLoginDoneAuxRecursion)
         {
            return;
         }
         this.stopLoginDoneAuxRecursion = true;
         this.setScreenByName(EULA_STATE,false);
         this.loginFailEmail.text = GWizLoginFB.user.email;
         didCredCheck = false;
         this.visible = true;
         GWizLoginBar.LoginParm = GWizLoginFB.user.email;
         revalidateLogin();
         calledLoginDone = false;
         this.centerPopUp();
         this.stopLoginDoneAuxRecursion = false;
      }
      
      private function doLogout() : void
      {
         GWizSettings.loginBar.changeLoginName(GWizLoginBar.GUEST_NAME);
         appDoExit();
      }
      
      private function doExit() : void
      {
         this.exitOK = true;
         this.close();
         GATracker.logPageView("LoginWizard/Exit","LoginWizard/Exit");
      }
      
      override public function close() : void
      {
         loginWizardActive = false;
         theWiz = null;
         super.close();
      }
      
      protected function closingHandler(param1:Event) : void
      {
         if(!this.exitOK)
         {
            param1.preventDefault();
            GATracker.logPageView("LoginWizard/CloseBox","LoginWizard/CloseBox");
         }
      }
      
      private function nextStep(param1:Boolean = false) : void
      {
         var _loc3_:GWizJustASec = null;
         var _loc2_:String = (this.appAccordion.selectedChild as NavigatorContent).label;
         this.inNextStep = true;
         switch(_loc2_)
         {
            case "Email":
               this.changeEmail();
               break;
            case EULA_STATE:
               if(GWizSettings.prefs.eulaWasAccepted())
               {
                  this.setScreenByName(MANDATORY_STATE);
               }
               else if(!this.eulaTxt)
               {
                  this.callLater(this.nextStep);
               }
               else if(this.eulaTxt.text.length == 0)
               {
                  this.loadEULA();
               }
               break;
            case MANDATORY_STATE:
               if(!GWizAppVersion.mandatoryMsg)
               {
                  this.setScreenByName(LOGIN_STATE);
               }
               break;
            case LOGIN_STATE:
               this.setScreenByName("Setup");
               if(didCredCheck)
               {
                  if(!GWizSettings.loginBar.CheckSecurity(false))
                  {
                     this.setScreenByName("LoginFail");
                  }
               }
               else
               {
                  this.waitForLogin();
                  _loc3_ = new GWizJustASec(this.isLoginDone,15);
               }
               break;
            case LOGIN_FAIL_STATE:
               this.loginFailEmail.text = GWizLoginFB.user.email;
               if(GWizLoginFB.user.email == "" || GWizLoginFB.user.email == "Guest")
               {
                  this.setScreenByName("Email",false);
               }
               else
               {
                  theWiz = this;
                  theWiz.visible = true;
                  GATracker.logPageView("LoginWizard/LoginFail","LoginWizard/LoginFail");
                  if(GWizCredentials.credStatus == GWizCredentials.CRED_NO_GRACE || GWizCredentials.credStatus == GWizCredentials.CRED_NO_INTERNET)
                  {
                     if(GWizCredentials.internetConnectRequired)
                     {
                        this.fail1.text = "G-Wizard must connect to CNCCookbook via the Internet.";
                        this.fail2.text = "It can only be disconnected for 28 days (21 for Trials).";
                        this.fail3.text = "Please be sure the Internet connection is good.";
                        this.fail4.text = " ";
                        GATracker.logPageView("LoginWizard/NeedConnection","LoginWizard/NeedConnection");
                     }
                  }
                  else if(GWizCredentials.credStatus == GWizCredentials.CRED_UNPAID_NOTRIAL)
                  {
                     this.fail1.text = "Your free trial has ended. We appreciate your taking a look at it.  If you never got a";
                     this.fail2.text = "chance to try G-Wizard, drop us an email requesting a new trial.  If you\'d like to";
                     this.fail3.text = "purchase, click the Product button.  The free applets will continue to function for";
                     this.fail4.text = "you if you just push this Login Wizard aside and click their tabs.";
                     this.loginFailBtn.label = "Product";
                     this.loginFailBtn.visible = true;
                     GATracker.logPageView("LoginWizard/TrialEnded","LoginWizard/TrialEnded");
                  }
                  if(param1)
                  {
                     this.setScreenByName("Email",false);
                  }
                  if(GWizCredentials.credStatus == GWizCredentials.CRED_OK)
                  {
                     this.doExit();
                  }
               }
               break;
            case "Setup":
               if(true || didCredCheck)
               {
                  this.doExit();
               }
               break;
            default:
               log.debug("Got a bad screen name in Login Wizard");
         }
         this.inNextStep = false;
      }
      
      private function setScreenByName(param1:String, param2:Boolean = true) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(false && param1 == "LoginFail")
         {
            log.debug("gotcha!");
         }
         if(param1 == "Setup")
         {
            GATracker.logPageView("LoginWizard/Setup","LoginWizard/Setup");
         }
         if(param1 == "EULA")
         {
            if(GWizSettings.prefs.eulaAccepted)
            {
               this.onEULAAccept(null);
               return;
            }
            log.debug("EULA not accepted.");
         }
         if(param1 == "Email")
         {
            this.changeEmail();
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < this.appAccordion.length)
            {
               if((_loc4_ = this.appAccordion.getElementAt(_loc3_)).label == param1)
               {
                  this.appAccordion.selectedIndex = _loc3_;
                  if(param2)
                  {
                     this.nextStep();
                  }
                  return;
               }
               _loc3_++;
            }
         }
      }
      
      private function set credCheck(param1:int) : void
      {
         if(param1 != GWizCredentials.CRED_NO_INTERNET)
         {
            didCredCheck = true;
         }
         if(this.appAccordion.selectedChild.label != "Email" && !didCredCheck)
         {
            revalidateLogin();
         }
      }
      
      private function waitForLogin() : void
      {
         if(GWizSettings.loginBar.CheckSecurity(false))
         {
            this.setScreenByName("Setup");
         }
         else
         {
            this.setScreenByName(LOGIN_FAIL_STATE);
         }
      }
      
      private function isLoginDone() : void
      {
      }
      
      private function loadEULA() : void
      {
         var request:URLRequest = null;
         var loader:URLLoader = null;
         if(theEULA == "")
         {
            request = new URLRequest("http://www.cnccookbook.com/GWizard/EULA.htm");
            loader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.TEXT;
            loader.addEventListener(Event.COMPLETE,this.completeHandler);
            try
            {
               loader.load(request);
            }
            catch(error:Error)
            {
               log.debug("Unable to load URL: " + error);
               eulaTxt.text = "EULA is online at http://www.cnccookbook.com/GWizard/EULA.htm";
            }
         }
         else
         {
            this.completeHandler(null);
         }
      }
      
      private function completeHandler(param1:Event) : void
      {
         var _loc2_:URLLoader = null;
         if(param1)
         {
            _loc2_ = URLLoader(param1.target);
            theEULA = _loc2_.data;
         }
         this.eulaTxt.textFlow = TextConverter.importToFlow(theEULA,TextConverter.TEXT_FIELD_HTML_FORMAT);
      }
      
      private function onEULAAccept(param1:Event) : void
      {
         GWizSettings.prefs.eulaAccepted = true;
         GWizSettings.prefs.savePreferences(GWizLoginBar.LoginParm);
         this.nextStep();
         GATracker.logPageView("LoginWizard/EULAAccept","LoginWizard/EULAAccept");
      }
      
      private function onEULADecline(param1:Event) : void
      {
         GWizSettings.prefs.eulaAccepted = false;
         GATracker.logPageView("LoginWizard/EULADecline","LoginWizard/EULADecline");
      }
      
      private function doInstall() : void
      {
         if(!GWizUtils.doWebPage(GWizSettings.loginBar.appInstallURL))
         {
            GWizMandrill.msg("Install Failure","Popup Blocker");
         }
      }
      
      private function goToProductPage() : void
      {
         GWizUtils.doWebPage(GWizEvalPopUp.registerURL);
      }
      
      private function doLoginHelp() : void
      {
         if(this.loginFailBtn.label == "Product")
         {
            this.goToProductPage();
            this.loginFailBtn.visible = false;
         }
         else
         {
            GWizUtils.doWebPage("http://www.cnccookbook.com/GWLoginHelp.html");
            GATracker.logPageView("LoginWizard/LoginHelp","LoginWizard/LoginHelp");
         }
      }
      
      private function changeEmail() : void
      {
         this.visible = false;
         GWizLoginFB.loginDoneCallback = loginDone;
         GWizLoginFB.showLoginFB();
         GWizSettings.prefs.newUserClearEULA();
      }
      
      private function panelChange() : void
      {
         if(this.appAccordion.selectedIndex == 0)
         {
            this.nextBtn.visible = false;
         }
         else
         {
            this.nextBtn.visible = true;
         }
      }
      
      private function _GWizLoginWizard_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizLoginWizard_ViewStack1_i(),this._GWizLoginWizard_HGroup3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.creationPolicy = "all";
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
                  "id":"EulaNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"EULA",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginWizard_Array3_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"MandatoryNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Mandatory",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginWizard_Array6_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"LoginNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginWizard_Array9_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"LoginFailNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginWizard_Array11_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"SetupNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Setup",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginWizard_Array13_c)
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
         this.panelChange();
      }
      
      private function _GWizLoginWizard_Array3_c() : Array
      {
         return [this._GWizLoginWizard_GWizPanel1_c()];
      }
      
      private function _GWizLoginWizard_GWizPanel1_c() : GWizPanel
      {
         var _loc1_:GWizPanel = new GWizPanel();
         _loc1_.title = "End User License Agreement";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.darkBack = false;
         _loc1_.backgroundColor = 16777215;
         _loc1_.layout = this._GWizLoginWizard_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizLoginWizard_Array4_c);
         _loc1_.setStyle("skinClass",PanelSkin);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Array4_c() : Array
      {
         return [this._GWizLoginWizard_TextArea1_i(),this._GWizLoginWizard_HGroup1_c()];
      }
      
      private function _GWizLoginWizard_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.editable = false;
         _loc1_.setStyle("verticalScrollPolicy","on");
         _loc1_.id = "eulaTxt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.eulaTxt = _loc1_;
         BindingManager.executeBindings(this,"eulaTxt",this.eulaTxt);
         return _loc1_;
      }
      
      private function _GWizLoginWizard_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizLoginWizard_Button1_c(),this._GWizLoginWizard_Button2_c(),this._GWizLoginWizard_Label1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Accept";
         _loc1_.addEventListener("click",this.___GWizLoginWizard_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizLoginWizard_Button1_click(param1:MouseEvent) : void
      {
         this.onEULAAccept(param1);
      }
      
      private function _GWizLoginWizard_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Reject";
         _loc1_.addEventListener("click",this.___GWizLoginWizard_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizLoginWizard_Button2_click(param1:MouseEvent) : void
      {
         this.onEULADecline(param1);
         this.acceptMsg.visible = true;
      }
      
      private function _GWizLoginWizard_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Sorry, we can\'t go further unless you accept.";
         _loc1_.visible = false;
         _loc1_.id = "acceptMsg";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.acceptMsg = _loc1_;
         BindingManager.executeBindings(this,"acceptMsg",this.acceptMsg);
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Array6_c() : Array
      {
         return [this._GWizLoginWizard_GWizPanel2_c()];
      }
      
      private function _GWizLoginWizard_GWizPanel2_c() : GWizPanel
      {
         var _loc1_:GWizPanel = new GWizPanel();
         _loc1_.title = "Updates";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.darkBack = false;
         _loc1_.backgroundColor = 16777215;
         _loc1_.layout = this._GWizLoginWizard_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizLoginWizard_Array7_c);
         _loc1_.setStyle("skinClass",PanelSkin);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_VerticalLayout2_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Array7_c() : Array
      {
         return [this._GWizLoginWizard_Label2_c(),this._GWizLoginWizard_Label3_c(),this._GWizLoginWizard_Label4_c(),this._GWizLoginWizard_Label5_c(),this._GWizLoginWizard_Label6_c(),this._GWizLoginWizard_Label7_c(),this._GWizLoginWizard_Label8_c(),this._GWizLoginWizard_Label9_c(),this._GWizLoginWizard_HGroup2_c(),this._GWizLoginWizard_Label11_c(),this._GWizLoginWizard_Label12_c()];
      }
      
      private function _GWizLoginWizard_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Mandatory Update Required";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Periodically, we release mandatory updates to our software.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "The version you have is too old and must be updated.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "You can find the download links on our Help page.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Just click the Help menu at the top of any CNCCookbook web page.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizLoginWizard_Label10_c(),this._GWizLoginWizard_Button3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Or click to open the install page:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Button3_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Install";
         _loc1_.addEventListener("click",this.___GWizLoginWizard_Button3_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizLoginWizard_Button3_click(param1:MouseEvent) : void
      {
         this.doInstall();
      }
      
      private function _GWizLoginWizard_Label11_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Note: Popup blockers may keep the button from working.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Array9_c() : Array
      {
         return [this._GWizLoginWizard_GWizPanel3_c()];
      }
      
      private function _GWizLoginWizard_GWizPanel3_c() : GWizPanel
      {
         var _loc1_:GWizPanel = new GWizPanel();
         _loc1_.title = "Logging In";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.darkBack = false;
         _loc1_.backgroundColor = 16777215;
         _loc1_.layout = this._GWizLoginWizard_VerticalLayout3_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizLoginWizard_Array10_c);
         _loc1_.setStyle("skinClass",PanelSkin);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_VerticalLayout3_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Array10_c() : Array
      {
         return [this._GWizLoginWizard_BusyIndicator1_c()];
      }
      
      private function _GWizLoginWizard_BusyIndicator1_c() : BusyIndicator
      {
         var _loc1_:BusyIndicator = new BusyIndicator();
         _loc1_.width = 200;
         _loc1_.height = 200;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Array11_c() : Array
      {
         return [this._GWizLoginWizard_GWizPanel4_c()];
      }
      
      private function _GWizLoginWizard_GWizPanel4_c() : GWizPanel
      {
         var _loc1_:GWizPanel = new GWizPanel();
         _loc1_.title = "Login Not Accepted";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.darkBack = false;
         _loc1_.backgroundColor = 16777215;
         _loc1_.layout = this._GWizLoginWizard_VerticalLayout4_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizLoginWizard_Array12_c);
         _loc1_.setStyle("skinClass",PanelSkin);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_VerticalLayout4_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Array12_c() : Array
      {
         return [this._GWizLoginWizard_Label13_c(),this._GWizLoginWizard_Label14_c(),this._GWizLoginWizard_Label15_c(),this._GWizLoginWizard_Label16_i(),this._GWizLoginWizard_Label17_c(),this._GWizLoginWizard_Label18_c(),this._GWizLoginWizard_Label19_c(),this._GWizLoginWizard_Label20_c(),this._GWizLoginWizard_Label21_i(),this._GWizLoginWizard_Label22_i(),this._GWizLoginWizard_Label23_i(),this._GWizLoginWizard_Label24_i(),this._GWizLoginWizard_Label25_c(),this._GWizLoginWizard_TextInput1_i(),this._GWizLoginWizard_Button4_i()];
      }
      
      private function _GWizLoginWizard_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label14_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Login Not Accepted for:";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label15_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label16_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "loginFailEmail";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.loginFailEmail = _loc1_;
         BindingManager.executeBindings(this,"loginFailEmail",this.loginFailEmail);
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label17_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label18_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "We\'re sorry.  The Email you\'ve given was not accepted for login.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label19_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label20_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label21_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Click \'Email\' to try a different email,";
         _loc1_.id = "fail1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fail1 = _loc1_;
         BindingManager.executeBindings(this,"fail1",this.fail1);
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label22_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "otherwise let\'s figure this out.  Click the Login Help";
         _loc1_.id = "fail2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fail2 = _loc1_;
         BindingManager.executeBindings(this,"fail2",this.fail2);
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label23_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "button below or go to the link above it.";
         _loc1_.id = "fail3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fail3 = _loc1_;
         BindingManager.executeBindings(this,"fail3",this.fail3);
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label24_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "You will need an Internet connection to login.";
         _loc1_.id = "fail4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fail4 = _loc1_;
         BindingManager.executeBindings(this,"fail4",this.fail4);
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label25_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.text = "http://www.cnccookbook.com/GWLoginHelp.html";
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("borderVisible",false);
         _loc1_.id = "loginHelpURL";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.loginHelpURL = _loc1_;
         BindingManager.executeBindings(this,"loginHelpURL",this.loginHelpURL);
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Button4_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Login Help";
         _loc1_.visible = true;
         _loc1_.addEventListener("click",this.__loginFailBtn_click);
         _loc1_.id = "loginFailBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.loginFailBtn = _loc1_;
         BindingManager.executeBindings(this,"loginFailBtn",this.loginFailBtn);
         return _loc1_;
      }
      
      public function __loginFailBtn_click(param1:MouseEvent) : void
      {
         this.doLoginHelp();
      }
      
      private function _GWizLoginWizard_Array13_c() : Array
      {
         return [this._GWizLoginWizard_GWizPanel5_c()];
      }
      
      private function _GWizLoginWizard_GWizPanel5_c() : GWizPanel
      {
         var _loc1_:GWizPanel = new GWizPanel();
         _loc1_.title = "Setup";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.darkBack = false;
         _loc1_.backgroundColor = 16777215;
         _loc1_.layout = this._GWizLoginWizard_VerticalLayout5_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizLoginWizard_Array14_c);
         _loc1_.setStyle("skinClass",PanelSkin);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_VerticalLayout5_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Array14_c() : Array
      {
         return [this._GWizLoginWizard_Label26_c(),this._GWizLoginWizard_Label27_c(),this._GWizLoginWizard_Label28_c(),this._GWizLoginWizard_Label29_c(),this._GWizLoginWizard_Label30_c(),this._GWizLoginWizard_Label31_c(),this._GWizLoginWizard_Label32_c(),this._GWizLoginWizard_Label33_c(),this._GWizLoginWizard_Label34_c(),this._GWizLoginWizard_Label35_c(),this._GWizLoginWizard_Label36_c(),this._GWizLoginWizard_Label37_c()];
      }
      
      private function _GWizLoginWizard_Label26_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label27_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Machine Setup";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label28_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label29_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Congratulations, you\'ve logged in successfully!";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label30_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label31_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "If you ever need to get the Login Wizard back, just click the \'Login\' button";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label32_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "near the top left corner of G-Wizard.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label33_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label34_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Your next step is to tell G-Wizard a little bit about your CNC Machine.  We\'ll";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label35_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "help you through that too.  Right now, go ahead and click the Exit button to";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label36_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "get started:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Label37_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "right";
         _loc1_.paddingLeft = 3;
         _loc1_.paddingRight = 3;
         _loc1_.paddingTop = 3;
         _loc1_.paddingBottom = 3;
         _loc1_.mxmlContent = [this._GWizLoginWizard_Button5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginWizard_Button5_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Email";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("click",this.__nextBtn_click);
         _loc1_.id = "nextBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.nextBtn = _loc1_;
         BindingManager.executeBindings(this,"nextBtn",this.nextBtn);
         return _loc1_;
      }
      
      public function __nextBtn_click(param1:MouseEvent) : void
      {
         this.nextStep(true);
      }
      
      public function ___GWizLoginWizard_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizLoginWizard_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():*
         {
            return GWizCredentials.credStatus;
         },function(param1:*):void
         {
            credCheck = param1;
         },"credCheck");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            EulaNav.setStyle("backgroundColor",param1);
         },"EulaNav.backgroundColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            MandatoryNav.setStyle("backgroundColor",param1);
         },"MandatoryNav.backgroundColor");
         result[3] = new Binding(this,function():String
         {
            var _loc1_:* = LOGIN_STATE;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"LoginNav.label");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            LoginNav.setStyle("backgroundColor",param1);
         },"LoginNav.backgroundColor");
         result[5] = new Binding(this,function():String
         {
            var _loc1_:* = LOGIN_FAIL_STATE;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"LoginFailNav.label");
         result[6] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            LoginFailNav.setStyle("backgroundColor",param1);
         },"LoginFailNav.backgroundColor");
         result[7] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            SetupNav.setStyle("backgroundColor",param1);
         },"SetupNav.backgroundColor");
         return result;
      }
      
      private function _GWizLoginWizard_bindingExprs() : void
      {
         var _loc1_:* = undefined;
         this.credCheck = GWizCredentials.credStatus;
      }
      
      [Bindable(event="propertyChange")]
      public function get EulaNav() : NavigatorContent
      {
         return this._265563294EulaNav;
      }
      
      public function set EulaNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._265563294EulaNav;
         if(_loc2_ !== param1)
         {
            this._265563294EulaNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EulaNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LoginFailNav() : NavigatorContent
      {
         return this._1229315684LoginFailNav;
      }
      
      public function set LoginFailNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1229315684LoginFailNav;
         if(_loc2_ !== param1)
         {
            this._1229315684LoginFailNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LoginFailNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LoginNav() : NavigatorContent
      {
         return this._2087387418LoginNav;
      }
      
      public function set LoginNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._2087387418LoginNav;
         if(_loc2_ !== param1)
         {
            this._2087387418LoginNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LoginNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MandatoryNav() : NavigatorContent
      {
         return this._1242701654MandatoryNav;
      }
      
      public function set MandatoryNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1242701654MandatoryNav;
         if(_loc2_ !== param1)
         {
            this._1242701654MandatoryNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MandatoryNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SetupNav() : NavigatorContent
      {
         return this._1500376454SetupNav;
      }
      
      public function set SetupNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1500376454SetupNav;
         if(_loc2_ !== param1)
         {
            this._1500376454SetupNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SetupNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get acceptMsg() : Label
      {
         return this._2117796519acceptMsg;
      }
      
      public function set acceptMsg(param1:Label) : void
      {
         var _loc2_:Object = this._2117796519acceptMsg;
         if(_loc2_ !== param1)
         {
            this._2117796519acceptMsg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"acceptMsg",_loc2_,param1));
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
      public function get eulaTxt() : TextArea
      {
         return this._1399083509eulaTxt;
      }
      
      public function set eulaTxt(param1:TextArea) : void
      {
         var _loc2_:Object = this._1399083509eulaTxt;
         if(_loc2_ !== param1)
         {
            this._1399083509eulaTxt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"eulaTxt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fail1() : Label
      {
         return this._97193171fail1;
      }
      
      public function set fail1(param1:Label) : void
      {
         var _loc2_:Object = this._97193171fail1;
         if(_loc2_ !== param1)
         {
            this._97193171fail1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fail1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fail2() : Label
      {
         return this._97193172fail2;
      }
      
      public function set fail2(param1:Label) : void
      {
         var _loc2_:Object = this._97193172fail2;
         if(_loc2_ !== param1)
         {
            this._97193172fail2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fail2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fail3() : Label
      {
         return this._97193173fail3;
      }
      
      public function set fail3(param1:Label) : void
      {
         var _loc2_:Object = this._97193173fail3;
         if(_loc2_ !== param1)
         {
            this._97193173fail3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fail3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fail4() : Label
      {
         return this._97193174fail4;
      }
      
      public function set fail4(param1:Label) : void
      {
         var _loc2_:Object = this._97193174fail4;
         if(_loc2_ !== param1)
         {
            this._97193174fail4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fail4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get loginFailBtn() : Button
      {
         return this._1393646923loginFailBtn;
      }
      
      public function set loginFailBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1393646923loginFailBtn;
         if(_loc2_ !== param1)
         {
            this._1393646923loginFailBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"loginFailBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get loginFailEmail() : Label
      {
         return this._737656245loginFailEmail;
      }
      
      public function set loginFailEmail(param1:Label) : void
      {
         var _loc2_:Object = this._737656245loginFailEmail;
         if(_loc2_ !== param1)
         {
            this._737656245loginFailEmail = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"loginFailEmail",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get loginHelpURL() : TextInput
      {
         return this._498783941loginHelpURL;
      }
      
      public function set loginHelpURL(param1:TextInput) : void
      {
         var _loc2_:Object = this._498783941loginHelpURL;
         if(_loc2_ !== param1)
         {
            this._498783941loginHelpURL = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"loginHelpURL",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get nextBtn() : Button
      {
         return this._1847046761nextBtn;
      }
      
      public function set nextBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1847046761nextBtn;
         if(_loc2_ !== param1)
         {
            this._1847046761nextBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"nextBtn",_loc2_,param1));
            }
         }
      }
   }
}
