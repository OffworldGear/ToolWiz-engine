package bubbletip
{
   import comps.GWizLinkLabel;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.utils.getDefinitionByName;
   import login.GWizLoginMgr;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.containers.ViewStack;
   import mx.controls.HRule;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.BorderContainer;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.NavigatorContent;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import spark.components.Window;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizCSVUtils;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizGettingStarted extends Window implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizLoginWizard");
      
      public static var dbFields:Array = ["stepName","stepTip","stepDone","stepPage"];
      
      public static var gettingStartedDB:ArrayCollection;
      
      public static var gettingStartedDBRevision:String = "";
      
      public static var gettingStartedURL:String = "http://www.cnccookbook.com/GWEOverview.html";
      
      private static var _947281371gettingStartedGlossary:String = "";
      
      public static var gettingStarted:GWizGettingStarted;
      
      public static var gettingStartedUserGuide:String = "http://www.cnccookbook.com/GWCalcGettingStarted.htm";
      
      public static var gettingStartedVideoTours:String = "http://www.cnccookbook.com/GWCUIntro.html";
      
      public static var gettingStartedBeginnerExamples:String = "";
      
      public static var gettingStartedProExamples:String = "";
      
      public static var gettingStartedRouterExamples:String = "";
      
      private static var stateLoaded:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _656922629DoneSetup:NavigatorContent;
      
      private var _79776349Setup:NavigatorContent;
      
      private var _1797539474TabNav:ViewStack;
      
      private var _1397214398Welcome:NavigatorContent;
      
      private var _89268Yup:Button;
      
      public var _GWizGettingStarted_BorderContainer1:BorderContainer;
      
      public var _GWizGettingStarted_BorderContainer2:BorderContainer;
      
      public var _GWizGettingStarted_Button3:Button;
      
      public var _GWizGettingStarted_Button5:Button;
      
      public var _GWizGettingStarted_Button9:Button;
      
      private var _533776554beginnerBtn:Button;
      
      private var _1838563028doneLbl:Label;
      
      private var _1329185816doneSetupText:TextArea;
      
      private var _525448674glossary:GWizLinkLabel;
      
      private var _979847057proBtn:Button;
      
      private var _168509011routerBtn:Button;
      
      private var _3529469show:CheckBox;
      
      private var _1140116759topLine:HGroup;
      
      private var _110551323tours:VGroup;
      
      private var _818098231vgroup:VGroup;
      
      private var _453158010vidsBtn:Button;
      
      private var _3929843welcomeName:Label;
      
      private var _3746897welcomeText:TextArea;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _209262271labelBackgroundColor:uint;
      
      private const WELCOME_BKGD_COLOR:uint = 16579048;
      
      private var _embed_mxml__assets_StopwatchSetup_jpg_1836622064:Class;
      
      private var _embed_mxml__assets_ThumbsUpCoffee_jpg_771235952:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizGettingStarted()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._209262271labelBackgroundColor = ColorPalette.gray4;
         this._embed_mxml__assets_StopwatchSetup_jpg_1836622064 = GWizGettingStarted__embed_mxml__assets_StopwatchSetup_jpg_1836622064;
         this._embed_mxml__assets_ThumbsUpCoffee_jpg_771235952 = GWizGettingStarted__embed_mxml__assets_ThumbsUpCoffee_jpg_771235952;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizGettingStarted_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_bubbletip_GWizGettingStartedWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizGettingStarted[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Getting Started...";
         this.width = 640;
         this.height = 550;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGettingStarted_Array1_c);
         this.addEventListener("creationComplete",this.___GWizGettingStarted_Window1_creationComplete);
         this.addEventListener("close",this.___GWizGettingStarted_Window1_close);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function newGettingStarted() : void
      {
         var _loc1_:GWizJustASec = null;
         if(GWizAbstractPrefs.isOEM)
         {
            return;
         }
         if(GWizLoginMgr.checkLogin() <= GWizLoginMgr.NO_ACCESS || !gettingStartedDB)
         {
            _loc1_ = new GWizJustASec(newGettingStarted);
            return;
         }
         if(!gettingStarted)
         {
            if(!gettingStartedDB)
            {
               return;
            }
            gettingStarted = new GWizGettingStarted();
            gettingStarted.open();
            GATracker.logPageView("Login/GettingStarted","Login: GettingStarted");
         }
         gettingStarted.alwaysInFront = true;
      }
      
      public static function doneAllGettingStarted() : Boolean
      {
         var _loc2_:GWizGettingStartedAction = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         loadGettingStartedState();
         var _loc1_:Boolean = true;
         if(GWizSettings.gotPreferences && gettingStartedDB)
         {
            _loc3_ = 0;
            while(_loc3_ < gettingStartedDB.length && _loc1_)
            {
               _loc4_ = gettingStartedDB.getItemAt(_loc3_);
               _loc1_ = _loc1_ && _loc4_.stepDone;
               _loc3_++;
            }
         }
         else
         {
            _loc1_ = false;
         }
         return _loc1_;
      }
      
      public static function doExitPage(param1:String) : void
      {
         GWizUtils.LogError("GWizGettingStarted.doExitPage(\'" + param1 + "\'\n");
         GWizUtils.doWebPage(param1);
      }
      
      private static function loadGettingStartedState() : void
      {
         var file:File = null;
         var justASec:GWizJustASec = null;
         var gettingStartedDB2:ArrayCollection = null;
         var j:int = 0;
         var entry:Object = null;
         var k:int = 0;
         var dbEntry:Object = null;
         if(stateLoaded)
         {
            return;
         }
         if(!gettingStartedDB)
         {
            justASec = new GWizJustASec(loadGettingStartedState,1);
            return;
         }
         stateLoaded = true;
         var gettingStartedDBFname:String = GWizSettings.loginBar.appProvParm + gettingStartedDBRevision + "GettingStarted.csv";
         if(gettingStartedDBFname != "")
         {
            file = GWizSettings.getPrefsFile(gettingStartedDBFname);
            try
            {
               if(file.exists)
               {
                  gettingStartedDB2 = GWizCSVUtils.loadCSVFile(file);
                  j = 0;
                  while(j < gettingStartedDB2.length)
                  {
                     entry = gettingStartedDB2.getItemAt(j);
                     entry.stepDone = String(entry.stepDone) == "true";
                     k = 0;
                     while(k < gettingStartedDB.length)
                     {
                        dbEntry = gettingStartedDB.getItemAt(k);
                        if(entry.stepName == dbEntry.stepName)
                        {
                           dbEntry.stepDone = entry.stepDone;
                        }
                        k++;
                     }
                     j++;
                  }
               }
            }
            catch(e:Error)
            {
               GWizUtils.LogError("Error loading Getting Started catalog." + e.message);
               log.debug(e.getStackTrace());
               GWizUtils.assert(false);
            }
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizGettingStarted._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get gettingStartedGlossary() : String
      {
         return GWizGettingStarted._947281371gettingStartedGlossary;
      }
      
      public static function set gettingStartedGlossary(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizGettingStarted._947281371gettingStartedGlossary;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizGettingStarted,"gettingStartedGlossary",_loc2_,param1));
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
            this.backgroundAlpha = 0.3;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onCC() : void
      {
         var _loc1_:GWizGettingStartedAction = null;
         var _loc4_:Object = null;
         this.show.visible = false;
         this.welcomeName.text = GWizSettings.loginBar.Welcome.text;
         this.welcomeText.text = "We\'re glad you\'ve gotten G-Wizard installed!\n\n";
         this.welcomeText.text += "The next step is to walk you through a quick machine setup\n";
         this.welcomeText.text += "so G-Wizard understands what your machine is capable of.\n\n";
         this.welcomeText.text += "That will enable it to do a much better job optimizing your.\n";
         this.welcomeText.text += "Feeds and Speeds.\n\n";
         this.doneSetupText.text = "Don\'t skip setting up for your machine.  G-Wizard needs to know your machine\'s capabilities to create good feeds and speeds.\n";
         this.doneSetupText.text += "To go back into Setup at a later time, you can either go directly to the Setup Tab or click the Setup options on the Getting Started popup.";
         if(gettingStartedGlossary == "")
         {
            this.topLine.removeElement(this.glossary);
         }
         if(gettingStartedBeginnerExamples == "")
         {
            this.beginnerBtn.visible = false;
            this.beginnerBtn.includeInLayout = false;
         }
         if(gettingStartedProExamples == "")
         {
            this.proBtn.visible = false;
            this.proBtn.includeInLayout = false;
         }
         if(gettingStartedRouterExamples == "")
         {
            this.routerBtn.visible = false;
            this.routerBtn.includeInLayout = false;
         }
         loadGettingStartedState();
         var _loc2_:int = 0;
         while(_loc2_ < gettingStartedDB.length)
         {
            _loc1_ = new GWizGettingStartedAction();
            _loc4_ = gettingStartedDB.getItemAt(_loc2_);
            _loc1_.stepNo = _loc2_ + 1;
            _loc1_.stepName = _loc4_.stepName;
            _loc1_.stepTip = _loc4_.stepTip;
            _loc1_.stepDone = _loc4_.stepDone;
            _loc1_.stepPage = _loc4_.stepPage;
            this.tours.addElement(_loc1_);
            _loc2_++;
         }
         var _loc3_:Object = gettingStartedDB.getItemAt(0);
         if(!_loc3_.stepDone)
         {
            this.nonSetupActionStatus(false);
         }
         else
         {
            this.TabNav.selectedIndex = 2;
         }
      }
      
      private function nonSetupActionStatus(param1:Boolean) : void
      {
         var _loc2_:GWizGettingStartedAction = null;
         var _loc3_:int = 1;
         while(_loc3_ < gettingStartedDB.length)
         {
            _loc2_ = this.tours.getElementAt(_loc3_) as GWizGettingStartedAction;
            _loc2_.enabled = param1;
            _loc3_++;
         }
      }
      
      private function onClose() : void
      {
         var file:File = null;
         var gettingStartedDBFname:String = GWizSettings.loginBar.appProvParm + "GettingStarted.csv";
         if(gettingStartedDBFname != "")
         {
            try
            {
               file = GWizSettings.getPrefsFile(gettingStartedDBFname);
               GWizCSVUtils.saveCSVFile(file,gettingStartedDB,dbFields);
            }
            catch(e:Error)
            {
               GWizUtils.LogError("Error saving Getting Started catalog." + e.message);
               log.debug(e.getStackTrace());
               GWizUtils.assert(false);
            }
         }
         gettingStarted = null;
      }
      
      private function onTourClick() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc1_:int = 0;
         while(_loc1_ < gettingStartedDB.length)
         {
            _loc2_ = gettingStartedDB.getItemAt(_loc1_);
            _loc3_ = this.tours.getElementAt(_loc1_);
            _loc2_.stepDone = _loc3_.stepDone;
            if(_loc1_ == 0)
            {
               this.nonSetupActionStatus(true);
            }
            _loc1_++;
         }
      }
      
      private function setShow() : void
      {
         if(!this.show.selected)
         {
            GATracker.logPageView("GettingStarted/QuitShowing","GettingStarted/QuitShowing");
         }
      }
      
      private function showSetupStep(param1:int) : void
      {
         var _loc2_:GWizGettingStartedAction = GWizGettingStartedAction(this.tours.getElementAt(0));
         if(param1 <= 1)
         {
            GWizUtils.doWebPage(_loc2_.stepPage);
         }
         else if(param1 <= 3)
         {
            GWizUtils.doWebPage("https://www.cnccookbook.com/g-wizard-videos/congrats-machine/");
            GATracker.logPageView("FirstLoginSetup","FirstLoginSetup");
         }
         this.TabNav.selectedIndex = param1;
         if(_loc2_ && param1 > 1)
         {
            _loc2_.stepDone = true;
            this.onTourClick();
         }
      }
      
      private function _GWizGettingStarted_Array1_c() : Array
      {
         return [this._GWizGettingStarted_ViewStack1_i()];
      }
      
      private function _GWizGettingStarted_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.bottom = 0;
         temp.right = 0;
         temp.left = 0;
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.creationPolicy = "all";
         temp.id = "TabNav";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"TabNav",
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Welcome",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGettingStarted_Array2_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"DoneSetup",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGettingStarted_Array8_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Setup",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGettingStarted_Array13_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.TabNav = temp;
         BindingManager.executeBindings(this,"TabNav",this.TabNav);
         return temp;
      }
      
      private function _GWizGettingStarted_Array2_c() : Array
      {
         return [this._GWizGettingStarted_VGroup1_c()];
      }
      
      private function _GWizGettingStarted_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 20;
         _loc1_.paddingRight = 20;
         _loc1_.paddingTop = 10;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGettingStarted_BorderContainer1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_BorderContainer1_i() : BorderContainer
      {
         var _loc1_:BorderContainer = new BorderContainer();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGettingStarted_Array4_c);
         _loc1_.id = "_GWizGettingStarted_BorderContainer1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGettingStarted_BorderContainer1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGettingStarted_BorderContainer1",this._GWizGettingStarted_BorderContainer1);
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Array4_c() : Array
      {
         return [this._GWizGettingStarted_HGroup1_c()];
      }
      
      private function _GWizGettingStarted_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizGettingStarted_VGroup2_c(),this._GWizGettingStarted_VGroup3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGettingStarted_Image1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_StopwatchSetup_jpg_1836622064;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGettingStarted_Label1_i(),this._GWizGettingStarted_TextArea1_i(),this._GWizGettingStarted_Button1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "welcomeName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.welcomeName = _loc1_;
         BindingManager.executeBindings(this,"welcomeName",this.welcomeName);
         return _loc1_;
      }
      
      private function _GWizGettingStarted_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("borderVisible",false);
         _loc1_.id = "welcomeText";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.welcomeText = _loc1_;
         BindingManager.executeBindings(this,"welcomeText",this.welcomeText);
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Let\'s go!";
         _loc1_.addEventListener("click",this.___GWizGettingStarted_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizGettingStarted_Button1_click(param1:MouseEvent) : void
      {
         this.showSetupStep(1);
      }
      
      private function _GWizGettingStarted_Array8_c() : Array
      {
         return [this._GWizGettingStarted_VGroup4_c()];
      }
      
      private function _GWizGettingStarted_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 20;
         _loc1_.paddingRight = 20;
         _loc1_.paddingTop = 10;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGettingStarted_BorderContainer2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_BorderContainer2_i() : BorderContainer
      {
         var _loc1_:BorderContainer = new BorderContainer();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGettingStarted_Array10_c);
         _loc1_.id = "_GWizGettingStarted_BorderContainer2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGettingStarted_BorderContainer2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGettingStarted_BorderContainer2",this._GWizGettingStarted_BorderContainer2);
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Array10_c() : Array
      {
         return [this._GWizGettingStarted_HGroup2_c()];
      }
      
      private function _GWizGettingStarted_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizGettingStarted_Image2_c(),this._GWizGettingStarted_VGroup5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Image2_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_ThumbsUpCoffee_jpg_771235952;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizGettingStarted_Spacer1_c(),this._GWizGettingStarted_Label2_i(),this._GWizGettingStarted_TextArea2_i(),this._GWizGettingStarted_Button2_i(),this._GWizGettingStarted_Button3_i(),this._GWizGettingStarted_Spacer2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 15;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Did You Setup G-Wizard For Your Machine?";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "doneLbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.doneLbl = _loc1_;
         BindingManager.executeBindings(this,"doneLbl",this.doneLbl);
         return _loc1_;
      }
      
      private function _GWizGettingStarted_TextArea2_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 70;
         _loc1_.setStyle("borderVisible",false);
         _loc1_.id = "doneSetupText";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.doneSetupText = _loc1_;
         BindingManager.executeBindings(this,"doneSetupText",this.doneSetupText);
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Yes, I\'m all Setup!";
         _loc1_.addEventListener("click",this.__Yup_click);
         _loc1_.id = "Yup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Yup = _loc1_;
         BindingManager.executeBindings(this,"Yup",this.Yup);
         return _loc1_;
      }
      
      public function __Yup_click(param1:MouseEvent) : void
      {
         this.showSetupStep(2);
      }
      
      private function _GWizGettingStarted_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Skip for now";
         _loc1_.addEventListener("click",this.___GWizGettingStarted_Button3_click);
         _loc1_.id = "_GWizGettingStarted_Button3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGettingStarted_Button3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGettingStarted_Button3",this._GWizGettingStarted_Button3);
         return _loc1_;
      }
      
      public function ___GWizGettingStarted_Button3_click(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function _GWizGettingStarted_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 15;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Array13_c() : Array
      {
         return [this._GWizGettingStarted_VGroup6_i()];
      }
      
      private function _GWizGettingStarted_VGroup6_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 10;
         _loc1_.mxmlContent = [this._GWizGettingStarted_HGroup3_i(),this._GWizGettingStarted_HRule1_c(),this._GWizGettingStarted_Label4_c(),this._GWizGettingStarted_HRule2_c(),this._GWizGettingStarted_VGroup7_i(),this._GWizGettingStarted_HGroup4_c()];
         _loc1_.id = "vgroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.vgroup = _loc1_;
         BindingManager.executeBindings(this,"vgroup",this.vgroup);
         return _loc1_;
      }
      
      private function _GWizGettingStarted_HGroup3_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGettingStarted_Label3_c(),this._GWizGettingStarted_Spacer3_c(),this._GWizGettingStarted_GWizLinkLabel1_i()];
         _loc1_.id = "topLine";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.topLine = _loc1_;
         BindingManager.executeBindings(this,"topLine",this.topLine);
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Let\'s get started!";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_GWizLinkLabel1_i() : GWizLinkLabel
      {
         var _loc1_:GWizLinkLabel = new GWizLinkLabel();
         _loc1_.text = "Glossary of Terms";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("click",this.__glossary_click);
         _loc1_.id = "glossary";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.glossary = _loc1_;
         BindingManager.executeBindings(this,"glossary",this.glossary);
         return _loc1_;
      }
      
      public function __glossary_click(param1:MouseEvent) : void
      {
         GWizUtils.doWebPage(gettingStartedGlossary);
      }
      
      private function _GWizGettingStarted_HRule1_c() : HRule
      {
         var _loc1_:HRule = new HRule();
         _loc1_.alpha = 0.7;
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Here are some quick tours to will help you get the most out of this software:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_HRule2_c() : HRule
      {
         var _loc1_:HRule = new HRule();
         _loc1_.alpha = 0.7;
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_VGroup7_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.__tours_click);
         _loc1_.id = "tours";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tours = _loc1_;
         BindingManager.executeBindings(this,"tours",this.tours);
         return _loc1_;
      }
      
      public function __tours_click(param1:MouseEvent) : void
      {
         this.onTourClick();
      }
      
      private function _GWizGettingStarted_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGettingStarted_VGroup8_c(),this._GWizGettingStarted_VGroup9_c(),this._GWizGettingStarted_VGroup10_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_VGroup8_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizGettingStarted_Button4_i(),this._GWizGettingStarted_Button5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Button4_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Video University";
         _loc1_.addEventListener("click",this.__vidsBtn_click);
         _loc1_.id = "vidsBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.vidsBtn = _loc1_;
         BindingManager.executeBindings(this,"vidsBtn",this.vidsBtn);
         return _loc1_;
      }
      
      public function __vidsBtn_click(param1:MouseEvent) : void
      {
         GWizUtils.doWebPage(gettingStartedVideoTours);
         GATracker.logPageView("GettingStarted/TrainingVids","GettingStarted/TrainingVids");
      }
      
      private function _GWizGettingStarted_Button5_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "User Guide";
         _loc1_.addEventListener("click",this.___GWizGettingStarted_Button5_click);
         _loc1_.id = "_GWizGettingStarted_Button5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGettingStarted_Button5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGettingStarted_Button5",this._GWizGettingStarted_Button5);
         return _loc1_;
      }
      
      public function ___GWizGettingStarted_Button5_click(param1:MouseEvent) : void
      {
         GWizUtils.doWebPage(gettingStartedUserGuide);
         GATracker.logPageView("GettingStarted/UserGuide","GettingStarted/UserGuide");
      }
      
      private function _GWizGettingStarted_VGroup9_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizGettingStarted_Button6_i(),this._GWizGettingStarted_Button7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Button6_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Beginner Examples";
         _loc1_.addEventListener("click",this.__beginnerBtn_click);
         _loc1_.id = "beginnerBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.beginnerBtn = _loc1_;
         BindingManager.executeBindings(this,"beginnerBtn",this.beginnerBtn);
         return _loc1_;
      }
      
      public function __beginnerBtn_click(param1:MouseEvent) : void
      {
         GWizUtils.doWebPage(gettingStartedBeginnerExamples);
         GATracker.logPageView("GettingStarted/BeginnerExamples","GettingStarted/BeginnerExamples");
      }
      
      private function _GWizGettingStarted_Button7_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Pro Examples";
         _loc1_.addEventListener("click",this.__proBtn_click);
         _loc1_.id = "proBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.proBtn = _loc1_;
         BindingManager.executeBindings(this,"proBtn",this.proBtn);
         return _loc1_;
      }
      
      public function __proBtn_click(param1:MouseEvent) : void
      {
         GWizUtils.doWebPage(gettingStartedProExamples);
         GATracker.logPageView("GettingStarted/ProExamples","GettingStarted/ProExamples");
      }
      
      private function _GWizGettingStarted_VGroup10_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizGettingStarted_Button8_i(),this._GWizGettingStarted_Button9_i(),this._GWizGettingStarted_Spacer4_c(),this._GWizGettingStarted_HGroup5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Button8_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Router Examples";
         _loc1_.addEventListener("click",this.__routerBtn_click);
         _loc1_.id = "routerBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.routerBtn = _loc1_;
         BindingManager.executeBindings(this,"routerBtn",this.routerBtn);
         return _loc1_;
      }
      
      public function __routerBtn_click(param1:MouseEvent) : void
      {
         GWizUtils.doWebPage(gettingStartedRouterExamples);
         GATracker.logPageView("GettingStarted/RouterExamples","GettingStarted/RouterExamples");
      }
      
      private function _GWizGettingStarted_Button9_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Help Desk";
         _loc1_.addEventListener("click",this.___GWizGettingStarted_Button9_click);
         _loc1_.id = "_GWizGettingStarted_Button9";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGettingStarted_Button9 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGettingStarted_Button9",this._GWizGettingStarted_Button9);
         return _loc1_;
      }
      
      public function ___GWizGettingStarted_Button9_click(param1:MouseEvent) : void
      {
         GWizUtils.doWebPage("http://www.cnccookbook.com/CCHelpDesk.html");
         GATracker.logPageView("GettingStarted/HelpDesk","GettingStarted/HelpDesk");
      }
      
      private function _GWizGettingStarted_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGettingStarted_Spacer5_c(),this._GWizGettingStarted_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_Spacer5_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStarted_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Show at Startup";
         _loc1_.addEventListener("change",this.__show_change);
         _loc1_.id = "show";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.show = _loc1_;
         BindingManager.executeBindings(this,"show",this.show);
         return _loc1_;
      }
      
      public function __show_change(param1:Event) : void
      {
         this.setShow();
      }
      
      public function ___GWizGettingStarted_Window1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizGettingStarted_Window1_close(param1:Event) : void
      {
         this.onClose();
      }
      
      private function _GWizGettingStarted_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,function(param1:uint):void
         {
            this.setStyle("backgroundColor",param1);
         },"this.backgroundColor","labelBackgroundColor");
         result[1] = new Binding(this,function():uint
         {
            return WELCOME_BKGD_COLOR;
         },function(param1:uint):void
         {
            TabNav.setStyle("backgroundColor",param1);
         },"TabNav.backgroundColor");
         result[2] = new Binding(this,function():uint
         {
            return WELCOME_BKGD_COLOR;
         },function(param1:uint):void
         {
            Welcome.setStyle("backgroundColor",param1);
         },"Welcome.backgroundColor");
         result[3] = new Binding(this,function():uint
         {
            return WELCOME_BKGD_COLOR;
         },function(param1:uint):void
         {
            _GWizGettingStarted_BorderContainer1.setStyle("backgroundColor",param1);
         },"_GWizGettingStarted_BorderContainer1.backgroundColor");
         result[4] = new Binding(this,function():uint
         {
            return WELCOME_BKGD_COLOR;
         },function(param1:uint):void
         {
            welcomeText.setStyle("contentBackgroundColor",param1);
         },"welcomeText.contentBackgroundColor");
         result[5] = new Binding(this,function():uint
         {
            return WELCOME_BKGD_COLOR;
         },function(param1:uint):void
         {
            DoneSetup.setStyle("backgroundColor",param1);
         },"DoneSetup.backgroundColor");
         result[6] = new Binding(this,function():uint
         {
            return WELCOME_BKGD_COLOR;
         },function(param1:uint):void
         {
            _GWizGettingStarted_BorderContainer2.setStyle("backgroundColor",param1);
         },"_GWizGettingStarted_BorderContainer2.backgroundColor");
         result[7] = new Binding(this,function():uint
         {
            return WELCOME_BKGD_COLOR;
         },function(param1:uint):void
         {
            doneSetupText.setStyle("contentBackgroundColor",param1);
         },"doneSetupText.contentBackgroundColor");
         result[8] = new Binding(this,function():Number
         {
            return Yup.width;
         },null,"_GWizGettingStarted_Button3.width");
         result[9] = new Binding(this,function():uint
         {
            return WELCOME_BKGD_COLOR;
         },function(param1:uint):void
         {
            Setup.setStyle("backgroundColor",param1);
         },"Setup.backgroundColor");
         result[10] = new Binding(this,function():Number
         {
            return vidsBtn.width;
         },null,"_GWizGettingStarted_Button5.width");
         result[11] = new Binding(this,function():Number
         {
            return beginnerBtn.width;
         },null,"proBtn.width");
         result[12] = new Binding(this,function():Number
         {
            return beginnerBtn.width;
         },null,"routerBtn.width");
         result[13] = new Binding(this,function():Number
         {
            return vidsBtn.width;
         },null,"_GWizGettingStarted_Button9.width");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get DoneSetup() : NavigatorContent
      {
         return this._656922629DoneSetup;
      }
      
      public function set DoneSetup(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._656922629DoneSetup;
         if(_loc2_ !== param1)
         {
            this._656922629DoneSetup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DoneSetup",_loc2_,param1));
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
      public function get TabNav() : ViewStack
      {
         return this._1797539474TabNav;
      }
      
      public function set TabNav(param1:ViewStack) : void
      {
         var _loc2_:Object = this._1797539474TabNav;
         if(_loc2_ !== param1)
         {
            this._1797539474TabNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TabNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Welcome() : NavigatorContent
      {
         return this._1397214398Welcome;
      }
      
      public function set Welcome(param1:NavigatorContent) : void
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
      public function get Yup() : Button
      {
         return this._89268Yup;
      }
      
      public function set Yup(param1:Button) : void
      {
         var _loc2_:Object = this._89268Yup;
         if(_loc2_ !== param1)
         {
            this._89268Yup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Yup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get beginnerBtn() : Button
      {
         return this._533776554beginnerBtn;
      }
      
      public function set beginnerBtn(param1:Button) : void
      {
         var _loc2_:Object = this._533776554beginnerBtn;
         if(_loc2_ !== param1)
         {
            this._533776554beginnerBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"beginnerBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get doneLbl() : Label
      {
         return this._1838563028doneLbl;
      }
      
      public function set doneLbl(param1:Label) : void
      {
         var _loc2_:Object = this._1838563028doneLbl;
         if(_loc2_ !== param1)
         {
            this._1838563028doneLbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"doneLbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get doneSetupText() : TextArea
      {
         return this._1329185816doneSetupText;
      }
      
      public function set doneSetupText(param1:TextArea) : void
      {
         var _loc2_:Object = this._1329185816doneSetupText;
         if(_loc2_ !== param1)
         {
            this._1329185816doneSetupText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"doneSetupText",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get glossary() : GWizLinkLabel
      {
         return this._525448674glossary;
      }
      
      public function set glossary(param1:GWizLinkLabel) : void
      {
         var _loc2_:Object = this._525448674glossary;
         if(_loc2_ !== param1)
         {
            this._525448674glossary = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"glossary",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get proBtn() : Button
      {
         return this._979847057proBtn;
      }
      
      public function set proBtn(param1:Button) : void
      {
         var _loc2_:Object = this._979847057proBtn;
         if(_loc2_ !== param1)
         {
            this._979847057proBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"proBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get routerBtn() : Button
      {
         return this._168509011routerBtn;
      }
      
      public function set routerBtn(param1:Button) : void
      {
         var _loc2_:Object = this._168509011routerBtn;
         if(_loc2_ !== param1)
         {
            this._168509011routerBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"routerBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get show() : CheckBox
      {
         return this._3529469show;
      }
      
      public function set show(param1:CheckBox) : void
      {
         var _loc2_:Object = this._3529469show;
         if(_loc2_ !== param1)
         {
            this._3529469show = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"show",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get topLine() : HGroup
      {
         return this._1140116759topLine;
      }
      
      public function set topLine(param1:HGroup) : void
      {
         var _loc2_:Object = this._1140116759topLine;
         if(_loc2_ !== param1)
         {
            this._1140116759topLine = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"topLine",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tours() : VGroup
      {
         return this._110551323tours;
      }
      
      public function set tours(param1:VGroup) : void
      {
         var _loc2_:Object = this._110551323tours;
         if(_loc2_ !== param1)
         {
            this._110551323tours = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tours",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get vgroup() : VGroup
      {
         return this._818098231vgroup;
      }
      
      public function set vgroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._818098231vgroup;
         if(_loc2_ !== param1)
         {
            this._818098231vgroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"vgroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get vidsBtn() : Button
      {
         return this._453158010vidsBtn;
      }
      
      public function set vidsBtn(param1:Button) : void
      {
         var _loc2_:Object = this._453158010vidsBtn;
         if(_loc2_ !== param1)
         {
            this._453158010vidsBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"vidsBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get welcomeName() : Label
      {
         return this._3929843welcomeName;
      }
      
      public function set welcomeName(param1:Label) : void
      {
         var _loc2_:Object = this._3929843welcomeName;
         if(_loc2_ !== param1)
         {
            this._3929843welcomeName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"welcomeName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get welcomeText() : TextArea
      {
         return this._3746897welcomeText;
      }
      
      public function set welcomeText(param1:TextArea) : void
      {
         var _loc2_:Object = this._3746897welcomeText;
         if(_loc2_ !== param1)
         {
            this._3746897welcomeText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"welcomeText",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelBackgroundColor() : uint
      {
         return this._209262271labelBackgroundColor;
      }
      
      public function set labelBackgroundColor(param1:uint) : void
      {
         var _loc2_:Object = this._209262271labelBackgroundColor;
         if(_loc2_ !== param1)
         {
            this._209262271labelBackgroundColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelBackgroundColor",_loc2_,param1));
            }
         }
      }
   }
}
