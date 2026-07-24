package login
{
   import comps.GWizImperialMetric;
   import comps.GWizNumStep;
   import comps.GWizPanel;
   import comps.GWizPopUpManager;
   import comps.skins.PanelSkin;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachProfile;
   import machines.GWizMachSelector2;
   import machines.GWizMachSettings;
   import machines.GWizMachTypeSelector;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.containers.ViewStack;
   import mx.controls.Spacer;
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
   import spark.components.TextInput;
   import spark.components.VGroup;
   import utils.GATracker;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizLoginSplash extends GWizPanel implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizLoginSplash");
      
      public static const SHOW_MODAL_SETUP:Boolean = false;
      
      public static const WELCOME_TAB:int = 0;
      
      public static const LOGIN_TAB:int = 1;
      
      public static const SETUP_TAB:int = 2;
      
      public static const CUSTOM_SETUP1_TAB:int = 3;
      
      public static const CUSTOM_SETUP2_TAB:int = 4;
      
      public static const SETUP_DONE_TAB:int = 5;
      
      public static const EXIT_TAB:int = 6;
      
      public static var modalSetupStage:int = GWizLoginSplash.WELCOME_TAB;
      
      private static var meMyselfAndI:GWizLoginSplash;
      
      private static var timingLogin:Boolean = false;
      
      private static var loginConfirmedReason:String = "";
      
      private static var loginConfirmedUseReason:Boolean = false;
      
      public static var loginMsgShowing:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1133140075GetStarted:Label;
      
      private var _2390542Make:TextInput;
      
      private var _74517257Model:TextInput;
      
      private var _81880911Units:GWizImperialMetric;
      
      private var _1424415872YesMachine:Button;
      
      public var _GWizLoginSplash_Button1:Button;
      
      public var _GWizLoginSplash_Button3:Button;
      
      private var _1291578119customSetupTA:Label;
      
      private var _1384215975customSetupTA2:Label;
      
      private var _1384215974customSetupTA3:Label;
      
      private var _2138398728getStartedTA:Label;
      
      private var _1865851078getStartedTA2:Label;
      
      private var _342344598loginTA:Label;
      
      private var _2022747996loginTA2:Label;
      
      private var _186172873machFeed:GWizNumStep;
      
      private var _1081756735machHP:GWizNumStep;
      
      private var _1680846998machMinRPM:GWizNumStep;
      
      private var _185938140machName:TextInput;
      
      private var _825289270machRPM:GWizNumStep;
      
      private var _185736237machType:GWizMachTypeSelector;
      
      private var _260429100selectedMachine:GWizMachSelector2;
      
      private var _1951077812setupDoneTA:Label;
      
      private var _1584105757viewStack:ViewStack;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var doClose:Function;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizLoginSplash()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizLoginSplash_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_login_GWizLoginSplashWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizLoginSplash[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.darkBack = true;
         this.backgroundAlpha = 1;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizLoginSplash_Array1_c);
         this.addEventListener("creationComplete",this.___GWizLoginSplash_GWizPanel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function setMode(param1:int = 0) : void
      {
         var _loc2_:GWizJustASec = null;
         GWizUtils.LogError("setMode( " + param1 + ")");
         if(GWizUtils.debug && param1 == LOGIN_TAB)
         {
            log.debug("setMode( LOGIN_TAB )");
         }
         if(WELCOME_TAB <= param1 && param1 < EXIT_TAB && meMyselfAndI)
         {
            meMyselfAndI.viewStack.selectedIndex = param1;
            if(!GWizLoginSplash.SHOW_MODAL_SETUP && param1 > LOGIN_TAB)
            {
               meMyselfAndI.doCloseAux();
            }
            if(!timingLogin && param1 == LOGIN_TAB && !GWizSettings.loginBar.guestLogin() && SHOW_MODAL_SETUP)
            {
               _loc2_ = new GWizJustASec(LoginTimeout,10);
               timingLogin = true;
            }
            else
            {
               timingLogin = false;
            }
         }
         else if(meMyselfAndI)
         {
            meMyselfAndI.doCloseAux();
         }
         modalSetupStage = param1;
      }
      
      private static function LoginTimeout() : void
      {
         if(timingLogin)
         {
            GWizUtils.LogError("Calling setMode via LoginTimeout");
            setMode(WELCOME_TAB);
            GWizPopUpManager.Show("Could not access the CNCCookbook Cloud. Please try logging in again.","Login Problem",GWizPopUpManager.WARN);
         }
      }
      
      public static function loginConfirmed(param1:String = "", param2:Boolean = false) : void
      {
         loginConfirmedReason = param1;
         loginConfirmedUseReason = param2;
         loginConfirmedAux();
      }
      
      private static function loginConfirmedAux() : void
      {
         var _loc1_:GWizJustASec = null;
         if(!GWizSettings.gotPreferences)
         {
            GWizUtils.LogError("loginConfirmedAux( No prefs yet, callLater )");
            _loc1_ = new GWizJustASec(loginConfirmedAux);
            return;
         }
         if(loginConfirmedUseReason)
         {
            if(GWizLoginBar.LoginParm != GWizLoginBar.GUEST_NAME)
            {
               loginMsgShowing = true;
               GWizPopUpManager.Show(loginConfirmedReason,"Login Problem",GWizPopUpManager.WARN,null,endLoginMsg);
            }
            setMode(LOGIN_TAB);
         }
      }
      
      private static function endLoginMsg(param1:Event) : void
      {
         loginMsgShowing = false;
         if(loginConfirmedReason.search("has expired") < 0)
         {
            GWizLoginFB.showLoginFB();
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizLoginSplash._watcherSetupUtil = param1;
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
            this.skinClass = PanelSkin;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function doCloseAux() : void
      {
         if(this.doClose != null)
         {
            this.doClose(true);
            timingLogin = false;
            return;
         }
         this.callLater(this.doCloseAux);
      }
      
      private function onCC() : void
      {
         GWizCredentials.loginConfirmed = loginConfirmed;
         meMyselfAndI = this;
         this.loginTA.text = "Glad you got G-Wizard downloaded and running.\n\n";
         this.loginTA2.text = "First thing to do is login.\n\n";
         this.loginTA2.text += "Just click the Login button at top left and give it the email you used to register or subscribe to G-Wizard.\n\n";
         this.loginTA2.text += "What\'s that?  You never registered or subscribed?.  No worries.  Click the Register button at top left.\n\n";
         this.getStartedTA.text = "\nHey there, let\'s get G-Wizard set up so you can start using it!\n\n";
         this.getStartedTA.text += "Our first step is to choose what units G-Wizard will use. Click the button below to choose:\n\n";
         this.getStartedTA2.text += "Next, you will tell G-Wizard about your CNC machine so it can adjust Feeds and Speeds to fit your machine\'s capabilities.\n\n";
         this.getStartedTA2.text += "Click the button below to see a list of pre-defined machines.  If you don\'t see your machine on the list, just pick one of the generic choices or a machine you know is similar.\n\n";
         this.customSetupTA.text = "No worries.  We just need to know a few things and you\'ll have a custom-tailored profile for your CNC machine.\n\n";
         this.customSetupTA.text += "First, tell us the name you want to use for this machine profile (e.g. Bob\'s Haas VF-1), the Make (e.g. Haas made the machine), and the Model (e.g. VF-1).\n\n";
         this.customSetupTA.text += "It doesn\'t matter to G-Wizard what you put for each of these, just make sure they make sense to you so you recognize them when choosing your machine from the menus.\n\n";
         this.customSetupTA2.text = "Next, we\'ll need you to tell us what kind of CNC machine it is:\n\n";
         this.customSetupTA3.text = "Now G-Wizard needs some basic specs on your CNC machine.  You can find these on the web site or owner\'s manual for your machine.  Just 4 questions and you\'re done.\n\n";
         this.setupDoneTA.text = "Congratulations!  You\'re done setting up and ready to start getting great Feeds and Speeds.\n\n";
         this.setupDoneTA.text += "When you click the \'Turn me loose\' button, two things will happen:\n\n";
         this.setupDoneTA.text += "1. This setup wizard goes away and you\'ll see the normal tabbed UI for G-Wizard.\n\n";
         this.setupDoneTA.text += "2. We\'ll pop up a web page with some worked examples.  Go through those, they\'re an excellent intro.\n\n";
         this.setupDoneTA.text += "For quick guided tours of G-Wizard\'s many features, click the Getting Started button above any time.\n\n";
         this.setupDoneTA.text += "Remember, anything you did here can be done on the Setup tab if you want to change it later.";
         this.closeIfNotNeeded();
      }
      
      private function closeIfNotNeeded() : void
      {
         if(GWizSettings.gotPreferences)
         {
            if(modalSetupStage >= SETUP_DONE_TAB || !GWizLoginSplash.SHOW_MODAL_SETUP)
            {
               this.doCloseAux();
            }
         }
         else
         {
            this.callLater(this.closeIfNotNeeded);
         }
      }
      
      private function doNext() : void
      {
         var _loc1_:int = this.viewStack.selectedIndex + 1;
         if(_loc1_ >= EXIT_TAB)
         {
            _loc1_ = WELCOME_TAB;
         }
         GWizUtils.LogError("Calling setMode via doNext");
         setMode(_loc1_);
      }
      
      private function getExamples() : void
      {
         var _loc1_:String = "https://www.cnccookbook.com/beginner-feeds-speeds-examples/";
         if(GWizSettings.prefs.noSetupReqd)
         {
            _loc1_ = "https://www.cnccookbook.com/beginner-feeds-speeds-examples-nosetup/";
            GATracker.logPageView("TrialExamplesNoSetup","TrialExamplesNoSetup");
         }
         else
         {
            GATracker.logPageView("TrialExamplesSetup","TrialExamplesSetup");
         }
         GWizUtils.doWebPage(_loc1_);
      }
      
      private function registerFreeTrial() : void
      {
         GWizUtils.doWebPage("https://www.cnccookbook.com/g-wizard-calculator-free-trial-signup/");
      }
      
      private function saveModalMachineProfile() : void
      {
         GWizUtils.LogError("saveModalMachineProfile()");
         if(GWizMachProfile.currMachProfile)
         {
         }
         if(!GWizMachProfile.currMachProfile.modalSetupAddMachine(this.machName.text,this.Make.text,this.Model.text,this.machType.selectedIndex,this.machRPM.value,this.machMinRPM.value,this.machHP.value,this.machFeed.value))
         {
            setMode(SETUP_TAB);
         }
         else
         {
            this.doNext();
         }
      }
      
      private function _GWizLoginSplash_Array1_c() : Array
      {
         return [this._GWizLoginSplash_VGroup1_c()];
      }
      
      private function _GWizLoginSplash_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizLoginSplash_ViewStack1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.creationPolicy = "all";
         temp.setStyle("paddingTop",20);
         temp.id = "viewStack";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"viewStack",
            "stylesFactory":function():void
            {
               this.paddingTop = 20;
            },
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginSplash_Array3_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginSplash_Array5_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginSplash_Array7_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginSplash_Array10_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginSplash_Array16_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizLoginSplash_Array22_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.viewStack = temp;
         BindingManager.executeBindings(this,"viewStack",this.viewStack);
         return temp;
      }
      
      private function _GWizLoginSplash_Array3_c() : Array
      {
         return [this._GWizLoginSplash_VGroup2_c()];
      }
      
      private function _GWizLoginSplash_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label1_c(),this._GWizLoginSplash_Label2_c(),this._GWizLoginSplash_Label3_i(),this._GWizLoginSplash_Label4_c(),this._GWizLoginSplash_Label5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Welcome!";
         _loc1_.setStyle("fontSize",30);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "loginTA";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.loginTA = _loc1_;
         BindingManager.executeBindings(this,"loginTA",this.loginTA);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "loginTA2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.loginTA2 = _loc1_;
         BindingManager.executeBindings(this,"loginTA2",this.loginTA2);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Array5_c() : Array
      {
         return [this._GWizLoginSplash_VGroup3_c()];
      }
      
      private function _GWizLoginSplash_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Logging In...";
         _loc1_.setStyle("fontSize",30);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Array7_c() : Array
      {
         return [this._GWizLoginSplash_VGroup4_c()];
      }
      
      private function _GWizLoginSplash_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label7_i(),this._GWizLoginSplash_Label8_i(),this._GWizLoginSplash_GWizImperialMetric1_i(),this._GWizLoginSplash_Label9_c(),this._GWizLoginSplash_Label10_c(),this._GWizLoginSplash_Label11_c(),this._GWizLoginSplash_Button1_i(),this._GWizLoginSplash_Label12_c(),this._GWizLoginSplash_Label13_i(),this._GWizLoginSplash_GWizMachSelector21_i(),this._GWizLoginSplash_Label14_c(),this._GWizLoginSplash_Label15_c(),this._GWizLoginSplash_Label16_c(),this._GWizLoginSplash_HGroup1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Let\'s Get Started!";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",30);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "GetStarted";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GetStarted = _loc1_;
         BindingManager.executeBindings(this,"GetStarted",this.GetStarted);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "getStartedTA";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.getStartedTA = _loc1_;
         BindingManager.executeBindings(this,"getStartedTA",this.getStartedTA);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_GWizImperialMetric1_i() : GWizImperialMetric
      {
         var _loc1_:GWizImperialMetric = new GWizImperialMetric();
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "Units";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Units = _loc1_;
         BindingManager.executeBindings(this,"Units",this.Units);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "You can change units any time via the Setup tab.";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label11_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Skip setup, I want to play!";
         _loc1_.addEventListener("click",this.___GWizLoginSplash_Button1_click);
         _loc1_.id = "_GWizLoginSplash_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginSplash_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginSplash_Button1",this._GWizLoginSplash_Button1);
         return _loc1_;
      }
      
      public function ___GWizLoginSplash_Button1_click(param1:MouseEvent) : void
      {
         setMode(SETUP_DONE_TAB);
         GWizSettings.prefs.noSetupReqd = true;
      }
      
      private function _GWizLoginSplash_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label13_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "getStartedTA2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.getStartedTA2 = _loc1_;
         BindingManager.executeBindings(this,"getStartedTA2",this.getStartedTA2);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_GWizMachSelector21_i() : GWizMachSelector2
      {
         var _loc1_:GWizMachSelector2 = new GWizMachSelector2();
         _loc1_.horizontalAlign = "center";
         _loc1_.id = "selectedMachine";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.selectedMachine = _loc1_;
         BindingManager.executeBindings(this,"selectedMachine",this.selectedMachine);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label14_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label15_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Was your machine on the list?";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label16_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "baseline";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Button2_i(),this._GWizLoginSplash_Button3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Yes, my machine was there.";
         _loc1_.addEventListener("click",this.__YesMachine_click);
         _loc1_.id = "YesMachine";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.YesMachine = _loc1_;
         BindingManager.executeBindings(this,"YesMachine",this.YesMachine);
         return _loc1_;
      }
      
      public function __YesMachine_click(param1:MouseEvent) : void
      {
         setMode(SETUP_DONE_TAB);
         GWizSettings.prefs.noSetupReqd = true;
      }
      
      private function _GWizLoginSplash_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "No, I picked a Generic or similar machine";
         _loc1_.addEventListener("click",this.___GWizLoginSplash_Button3_click);
         _loc1_.id = "_GWizLoginSplash_Button3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginSplash_Button3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginSplash_Button3",this._GWizLoginSplash_Button3);
         return _loc1_;
      }
      
      public function ___GWizLoginSplash_Button3_click(param1:MouseEvent) : void
      {
         setMode(CUSTOM_SETUP1_TAB);
         GWizSettings.prefs.noSetupReqd = false;
      }
      
      private function _GWizLoginSplash_Array10_c() : Array
      {
         return [this._GWizLoginSplash_VGroup5_c()];
      }
      
      private function _GWizLoginSplash_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label17_c(),this._GWizLoginSplash_Label18_c(),this._GWizLoginSplash_Label19_i(),this._GWizLoginSplash_HGroup2_c(),this._GWizLoginSplash_HGroup3_c(),this._GWizLoginSplash_HGroup4_c(),this._GWizLoginSplash_Label23_c(),this._GWizLoginSplash_Label24_i(),this._GWizLoginSplash_HGroup5_c(),this._GWizLoginSplash_Label26_c(),this._GWizLoginSplash_Label27_c(),this._GWizLoginSplash_Button4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label17_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Custom Setup";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",30);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label18_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label19_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "customSetupTA";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.customSetupTA = _loc1_;
         BindingManager.executeBindings(this,"customSetupTA",this.customSetupTA);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 70;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label20_c(),this._GWizLoginSplash_Spacer1_c(),this._GWizLoginSplash_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label20_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Name";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = true;
         _loc1_.toolTip = "Name of this machine profile.";
         _loc1_.width = 200;
         _loc1_.id = "machName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machName = _loc1_;
         BindingManager.executeBindings(this,"machName",this.machName);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 70;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label21_c(),this._GWizLoginSplash_Spacer2_c(),this._GWizLoginSplash_TextInput2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label21_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Make";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "Make";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Make = _loc1_;
         BindingManager.executeBindings(this,"Make",this.Make);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 70;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label22_c(),this._GWizLoginSplash_Spacer3_c(),this._GWizLoginSplash_TextInput3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label22_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Model";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "Model";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Model = _loc1_;
         BindingManager.executeBindings(this,"Model",this.Model);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label23_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label24_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "customSetupTA2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.customSetupTA2 = _loc1_;
         BindingManager.executeBindings(this,"customSetupTA2",this.customSetupTA2);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 70;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label25_c(),this._GWizLoginSplash_Spacer4_c(),this._GWizLoginSplash_GWizMachTypeSelector1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label25_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Type";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_GWizMachTypeSelector1_i() : GWizMachTypeSelector
      {
         var _loc1_:GWizMachTypeSelector = new GWizMachTypeSelector();
         _loc1_.id = "machType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machType = _loc1_;
         BindingManager.executeBindings(this,"machType",this.machType);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label26_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label27_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "You\'re crushing it!  Just a couple more questions and we\'re done.";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Button4_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Next!";
         _loc1_.addEventListener("click",this.___GWizLoginSplash_Button4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizLoginSplash_Button4_click(param1:MouseEvent) : void
      {
         this.doNext();
      }
      
      private function _GWizLoginSplash_Array16_c() : Array
      {
         return [this._GWizLoginSplash_VGroup6_c()];
      }
      
      private function _GWizLoginSplash_VGroup6_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label28_c(),this._GWizLoginSplash_Label29_c(),this._GWizLoginSplash_Label30_i(),this._GWizLoginSplash_HGroup6_c(),this._GWizLoginSplash_HGroup7_c(),this._GWizLoginSplash_HGroup8_c(),this._GWizLoginSplash_HGroup9_c(),this._GWizLoginSplash_Label35_c(),this._GWizLoginSplash_Label36_c(),this._GWizLoginSplash_Button5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label28_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Custom Setup, Part 2";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",30);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label29_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label30_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "customSetupTA3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.customSetupTA3 = _loc1_;
         BindingManager.executeBindings(this,"customSetupTA3",this.customSetupTA3);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 70;
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label31_c(),this._GWizLoginSplash_Spacer5_c(),this._GWizLoginSplash_GWizNumStep1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label31_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max Spindle RPM";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Spacer5_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.toolTip = "Maximum rpm the spindle is capable of.";
         _loc1_.min = 0;
         _loc1_.steps = 10;
         _loc1_.stepWidth = 70;
         _loc1_.usesMetric = false;
         _loc1_.id = "machRPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machRPM = _loc1_;
         BindingManager.executeBindings(this,"machRPM",this.machRPM);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 70;
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label32_c(),this._GWizLoginSplash_Spacer6_c(),this._GWizLoginSplash_GWizNumStep2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label32_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Min Spindle RPM";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Spacer6_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.toolTip = "Minimum rpm the spindle is capable of.";
         _loc1_.min = 0;
         _loc1_.steps = 10;
         _loc1_.stepWidth = 70;
         _loc1_.usesMetric = false;
         _loc1_.id = "machMinRPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machMinRPM = _loc1_;
         BindingManager.executeBindings(this,"machMinRPM",this.machMinRPM);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 70;
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label33_c(),this._GWizLoginSplash_Spacer7_c(),this._GWizLoginSplash_GWizNumStep3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label33_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Spindle Power";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Spacer7_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 0.01;
         _loc1_.stepWidth = 70;
         _loc1_.toolTip = "Rated spindle power";
         _loc1_.id = "machHP";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machHP = _loc1_;
         BindingManager.executeBindings(this,"machHP",this.machHP);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_HGroup9_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 70;
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label34_c(),this._GWizLoginSplash_Spacer8_c(),this._GWizLoginSplash_GWizNumStep4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label34_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max Feedrate (ipm or mm/min in metric)";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Spacer8_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 1;
         _loc1_.stepWidth = 65;
         _loc1_.UnitLabel = "ipm";
         _loc1_.toolTip = "Machine\'s maximum cutting feedrate.";
         _loc1_.id = "machFeed";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machFeed = _loc1_;
         BindingManager.executeBindings(this,"machFeed",this.machFeed);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label35_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label36_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "All the numbers good?  Great, you\'re done!";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Button5_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Done";
         _loc1_.addEventListener("click",this.___GWizLoginSplash_Button5_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizLoginSplash_Button5_click(param1:MouseEvent) : void
      {
         this.saveModalMachineProfile();
      }
      
      private function _GWizLoginSplash_Array22_c() : Array
      {
         return [this._GWizLoginSplash_VGroup7_c()];
      }
      
      private function _GWizLoginSplash_VGroup7_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizLoginSplash_Label37_c(),this._GWizLoginSplash_Label38_c(),this._GWizLoginSplash_Label39_i(),this._GWizLoginSplash_Label40_c(),this._GWizLoginSplash_Button6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label37_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "You Are Ready!";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",30);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label38_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label39_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "setupDoneTA";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.setupDoneTA = _loc1_;
         BindingManager.executeBindings(this,"setupDoneTA",this.setupDoneTA);
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Label40_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.percentWidth = 80;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginSplash_Button6_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Turn me loose to go try G-Wizard now!";
         _loc1_.addEventListener("click",this.___GWizLoginSplash_Button6_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizLoginSplash_Button6_click(param1:MouseEvent) : void
      {
         this.getExamples();
         this.doCloseAux();
      }
      
      public function ___GWizLoginSplash_GWizPanel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizLoginSplash_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return GetStarted.height;
         },null,"_GWizLoginSplash_Button1.height");
         result[1] = new Binding(this,function():Number
         {
            return GetStarted.height;
         },null,"selectedMachine.height");
         result[2] = new Binding(this,function():Number
         {
            return GetStarted.height;
         },null,"YesMachine.height");
         result[3] = new Binding(this,function():Number
         {
            return GetStarted.height;
         },null,"_GWizLoginSplash_Button3.height");
         result[4] = new Binding(this,function():Number
         {
            return machName.width;
         },null,"Make.width");
         result[5] = new Binding(this,function():Number
         {
            return machName.width;
         },null,"Model.width");
         result[6] = new Binding(this,function():Number
         {
            return machName.width;
         },null,"machType.width");
         result[7] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_RPM;
         },null,"machRPM.max");
         result[8] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_RPM;
         },null,"machMinRPM.max");
         result[9] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.HP_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"machHP.impUnits");
         result[10] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.KW_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"machHP.metUnits");
         result[11] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_FEEDRATE;
         },null,"machFeed.max");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get GetStarted() : Label
      {
         return this._1133140075GetStarted;
      }
      
      public function set GetStarted(param1:Label) : void
      {
         var _loc2_:Object = this._1133140075GetStarted;
         if(_loc2_ !== param1)
         {
            this._1133140075GetStarted = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GetStarted",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Make() : TextInput
      {
         return this._2390542Make;
      }
      
      public function set Make(param1:TextInput) : void
      {
         var _loc2_:Object = this._2390542Make;
         if(_loc2_ !== param1)
         {
            this._2390542Make = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Make",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Model() : TextInput
      {
         return this._74517257Model;
      }
      
      public function set Model(param1:TextInput) : void
      {
         var _loc2_:Object = this._74517257Model;
         if(_loc2_ !== param1)
         {
            this._74517257Model = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Model",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Units() : GWizImperialMetric
      {
         return this._81880911Units;
      }
      
      public function set Units(param1:GWizImperialMetric) : void
      {
         var _loc2_:Object = this._81880911Units;
         if(_loc2_ !== param1)
         {
            this._81880911Units = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Units",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get YesMachine() : Button
      {
         return this._1424415872YesMachine;
      }
      
      public function set YesMachine(param1:Button) : void
      {
         var _loc2_:Object = this._1424415872YesMachine;
         if(_loc2_ !== param1)
         {
            this._1424415872YesMachine = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"YesMachine",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get customSetupTA() : Label
      {
         return this._1291578119customSetupTA;
      }
      
      public function set customSetupTA(param1:Label) : void
      {
         var _loc2_:Object = this._1291578119customSetupTA;
         if(_loc2_ !== param1)
         {
            this._1291578119customSetupTA = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"customSetupTA",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get customSetupTA2() : Label
      {
         return this._1384215975customSetupTA2;
      }
      
      public function set customSetupTA2(param1:Label) : void
      {
         var _loc2_:Object = this._1384215975customSetupTA2;
         if(_loc2_ !== param1)
         {
            this._1384215975customSetupTA2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"customSetupTA2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get customSetupTA3() : Label
      {
         return this._1384215974customSetupTA3;
      }
      
      public function set customSetupTA3(param1:Label) : void
      {
         var _loc2_:Object = this._1384215974customSetupTA3;
         if(_loc2_ !== param1)
         {
            this._1384215974customSetupTA3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"customSetupTA3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get getStartedTA() : Label
      {
         return this._2138398728getStartedTA;
      }
      
      public function set getStartedTA(param1:Label) : void
      {
         var _loc2_:Object = this._2138398728getStartedTA;
         if(_loc2_ !== param1)
         {
            this._2138398728getStartedTA = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"getStartedTA",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get getStartedTA2() : Label
      {
         return this._1865851078getStartedTA2;
      }
      
      public function set getStartedTA2(param1:Label) : void
      {
         var _loc2_:Object = this._1865851078getStartedTA2;
         if(_loc2_ !== param1)
         {
            this._1865851078getStartedTA2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"getStartedTA2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get loginTA() : Label
      {
         return this._342344598loginTA;
      }
      
      public function set loginTA(param1:Label) : void
      {
         var _loc2_:Object = this._342344598loginTA;
         if(_loc2_ !== param1)
         {
            this._342344598loginTA = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"loginTA",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get loginTA2() : Label
      {
         return this._2022747996loginTA2;
      }
      
      public function set loginTA2(param1:Label) : void
      {
         var _loc2_:Object = this._2022747996loginTA2;
         if(_loc2_ !== param1)
         {
            this._2022747996loginTA2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"loginTA2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machFeed() : GWizNumStep
      {
         return this._186172873machFeed;
      }
      
      public function set machFeed(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._186172873machFeed;
         if(_loc2_ !== param1)
         {
            this._186172873machFeed = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machFeed",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machHP() : GWizNumStep
      {
         return this._1081756735machHP;
      }
      
      public function set machHP(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1081756735machHP;
         if(_loc2_ !== param1)
         {
            this._1081756735machHP = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machHP",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machMinRPM() : GWizNumStep
      {
         return this._1680846998machMinRPM;
      }
      
      public function set machMinRPM(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1680846998machMinRPM;
         if(_loc2_ !== param1)
         {
            this._1680846998machMinRPM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machMinRPM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machName() : TextInput
      {
         return this._185938140machName;
      }
      
      public function set machName(param1:TextInput) : void
      {
         var _loc2_:Object = this._185938140machName;
         if(_loc2_ !== param1)
         {
            this._185938140machName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machRPM() : GWizNumStep
      {
         return this._825289270machRPM;
      }
      
      public function set machRPM(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._825289270machRPM;
         if(_loc2_ !== param1)
         {
            this._825289270machRPM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machRPM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machType() : GWizMachTypeSelector
      {
         return this._185736237machType;
      }
      
      public function set machType(param1:GWizMachTypeSelector) : void
      {
         var _loc2_:Object = this._185736237machType;
         if(_loc2_ !== param1)
         {
            this._185736237machType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get selectedMachine() : GWizMachSelector2
      {
         return this._260429100selectedMachine;
      }
      
      public function set selectedMachine(param1:GWizMachSelector2) : void
      {
         var _loc2_:Object = this._260429100selectedMachine;
         if(_loc2_ !== param1)
         {
            this._260429100selectedMachine = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"selectedMachine",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get setupDoneTA() : Label
      {
         return this._1951077812setupDoneTA;
      }
      
      public function set setupDoneTA(param1:Label) : void
      {
         var _loc2_:Object = this._1951077812setupDoneTA;
         if(_loc2_ !== param1)
         {
            this._1951077812setupDoneTA = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"setupDoneTA",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get viewStack() : ViewStack
      {
         return this._1584105757viewStack;
      }
      
      public function set viewStack(param1:ViewStack) : void
      {
         var _loc2_:Object = this._1584105757viewStack;
         if(_loc2_ !== param1)
         {
            this._1584105757viewStack = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"viewStack",_loc2_,param1));
            }
         }
      }
   }
}
