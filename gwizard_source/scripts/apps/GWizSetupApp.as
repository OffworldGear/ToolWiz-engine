package apps
{
   import comps.GWizAbout;
   import comps.GWizForePanel;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import configinfo.GWizSetupFiles;
   import feedsspeeds.GWizDeflectOptions;
   import feedsspeeds.GWizHSMOptions;
   import flash.events.Event;
   import flash.filesystem.File;
   import flash.system.Capabilities;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachProfile;
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
   import mx.events.IndexChangedEvent;
   import mx.events.PropertyChangeEvent;
   import skins.GWizTabBarSkin;
   import spark.components.Group;
   import spark.components.NavigatorContent;
   import spark.components.TabBar;
   import spark.components.VGroup;
   import utils.ColorPalette;
   import utils.GATracker;
   
   use namespace mx_internal;
   
   public class GWizSetupApp extends Group implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizSetupApp_NavigatorContent1:NavigatorContent;
      
      public var _GWizSetupApp_NavigatorContent4:NavigatorContent;
      
      private var _1416177271aboutPanel:GWizAbout;
      
      private var _399483503deflectOptions:GWizDeflectOptions;
      
      private var _741542780hsmOptions:GWizHSMOptions;
      
      private var _899979202machineProfilePanel:GWizMachProfile;
      
      private var _1171149211otherTab:NavigatorContent;
      
      private var _1047107066setupFiles:NavigatorContent;
      
      private var _881406642tabNav:ViewStack;
      
      private var _3552126tabs:TabBar;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _342488600logoImg:Class;
      
      public const SETUP_APP_NAME:String = "Setup";
      
      private var _1266399255fsFile:File;
      
      private var powerUserState:Boolean = true;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizSetupApp()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizSetupApp_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizSetupAppWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizSetupApp[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizSetupApp_ViewStack1_i(),this._GWizSetupApp_TabBar1_i()];
         this.addEventListener("show",this.___GWizSetupApp_Group1_show);
         this.addEventListener("hide",this.___GWizSetupApp_Group1_hide);
         this.addEventListener("creationComplete",this.___GWizSetupApp_Group1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizSetupApp._watcherSetupUtil = param1;
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
      
      private function onCC() : void
      {
         this.fsFile = GWizSettings.getPrefsFile("LastFeedSpeed.xml");
         GWizAbstractPrefs.powerUserCC.addFunction("GWizSetupApp",this.powerUserChanged,false);
         this.powerUserChanged();
         if(Capabilities.os.indexOf("Windows") == -1)
         {
         }
         GWizMachProfile.setupLockCC.addFunction("GWizSetupApp",this.setupLock);
      }
      
      private function setupLock(param1:Object) : Boolean
      {
         this.setupFiles.enabled = !GWizMachProfile.setupLocked;
         return true;
      }
      
      public function showMe(param1:Event) : void
      {
         if(param1)
         {
            this.tabNav.selectedChild.dispatchEvent(param1);
         }
         var _loc2_:Boolean = GWizAbstractPrefs.lockSharedFiles(true);
         if(_loc2_)
         {
            this.enabled = false;
         }
      }
      
      public function hideMe(param1:Event) : void
      {
         if(param1)
         {
            this.tabNav.selectedChild.dispatchEvent(param1);
         }
         GWizAbstractPrefs.lockSharedFiles(false);
         this.enabled = true;
      }
      
      private function onSetupChange(param1:String) : void
      {
         GATracker.logPageView("Setup/" + param1,"Tabbed to Setup " + param1);
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         if(GWizSettings.prefs.powerUser != this.powerUserState)
         {
            if(GWizSettings.prefs.powerUser)
            {
               this.tabNav.addElementAt(this.otherTab,3);
            }
            else
            {
               this.tabNav.removeElement(this.otherTab);
            }
            this.powerUserState = GWizSettings.prefs.powerUser;
         }
         return true;
      }
      
      private function _GWizSetupApp_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.bottom = 0;
         temp.right = 0;
         temp.left = 0;
         temp.creationPolicy = "all";
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.setStyle("paddingBottom",0);
         temp.setStyle("paddingLeft",0);
         temp.setStyle("paddingRight",0);
         temp.setStyle("paddingTop",10);
         temp.addEventListener("change",this.__tabNav_change);
         temp.id = "tabNav";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"tabNav",
            "events":{"change":"__tabNav_change"},
            "stylesFactory":function():void
            {
               this.paddingBottom = 0;
               this.paddingLeft = 0;
               this.paddingRight = 0;
               this.paddingTop = 10;
            },
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizSetupApp_NavigatorContent1",
                  "events":{"show":"___GWizSetupApp_NavigatorContent1_show"},
                  "propertiesFactory":function():Object
                  {
                     return {
                        "name":"Basics",
                        "label":"Basics",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizSetupApp_Array2_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"setupFiles",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "name":"Files",
                        "label":"Files",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizSetupApp_Array3_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"otherTab",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "name":"Other",
                        "label":"Other",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizSetupApp_Array4_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizSetupApp_NavigatorContent4",
                  "events":{"show":"___GWizSetupApp_NavigatorContent4_show"},
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "name":"About",
                        "label":"About",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizSetupApp_Array8_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.tabNav = temp;
         BindingManager.executeBindings(this,"tabNav",this.tabNav);
         return temp;
      }
      
      public function __tabNav_change(param1:IndexChangedEvent) : void
      {
         this.onSetupChange(this.tabNav.selectedChild.label);
      }
      
      private function _GWizSetupApp_Array2_c() : Array
      {
         return [this._GWizSetupApp_GWizMachProfile1_i()];
      }
      
      private function _GWizSetupApp_GWizMachProfile1_i() : GWizMachProfile
      {
         var _loc1_:GWizMachProfile = new GWizMachProfile();
         _loc1_.id = "machineProfilePanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machineProfilePanel = _loc1_;
         BindingManager.executeBindings(this,"machineProfilePanel",this.machineProfilePanel);
         return _loc1_;
      }
      
      public function ___GWizSetupApp_NavigatorContent1_show(param1:FlexEvent) : void
      {
         this.machineProfilePanel.showMe();
      }
      
      private function _GWizSetupApp_Array3_c() : Array
      {
         return [this._GWizSetupApp_GWizSetupFiles1_c()];
      }
      
      private function _GWizSetupApp_GWizSetupFiles1_c() : GWizSetupFiles
      {
         var _loc1_:GWizSetupFiles = new GWizSetupFiles();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupApp_Array4_c() : Array
      {
         return [this._GWizSetupApp_VGroup1_c()];
      }
      
      private function _GWizSetupApp_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 10;
         _loc1_.mxmlContent = [this._GWizSetupApp_GWizForePanel1_c(),this._GWizSetupApp_GWizForePanel2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupApp_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Deflection";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizSetupApp_Array6_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupApp_Array6_c() : Array
      {
         return [this._GWizSetupApp_GWizDeflectOptions1_i()];
      }
      
      private function _GWizSetupApp_GWizDeflectOptions1_i() : GWizDeflectOptions
      {
         var _loc1_:GWizDeflectOptions = new GWizDeflectOptions();
         _loc1_.id = "deflectOptions";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.deflectOptions = _loc1_;
         BindingManager.executeBindings(this,"deflectOptions",this.deflectOptions);
         return _loc1_;
      }
      
      private function _GWizSetupApp_GWizForePanel2_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "HSM";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizSetupApp_Array7_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupApp_Array7_c() : Array
      {
         return [this._GWizSetupApp_GWizHSMOptions1_i()];
      }
      
      private function _GWizSetupApp_GWizHSMOptions1_i() : GWizHSMOptions
      {
         var _loc1_:GWizHSMOptions = new GWizHSMOptions();
         _loc1_.id = "hsmOptions";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.hsmOptions = _loc1_;
         BindingManager.executeBindings(this,"hsmOptions",this.hsmOptions);
         return _loc1_;
      }
      
      private function _GWizSetupApp_Array8_c() : Array
      {
         return [this._GWizSetupApp_GWizAbout1_i()];
      }
      
      private function _GWizSetupApp_GWizAbout1_i() : GWizAbout
      {
         var _loc1_:GWizAbout = new GWizAbout();
         _loc1_.id = "aboutPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.aboutPanel = _loc1_;
         BindingManager.executeBindings(this,"aboutPanel",this.aboutPanel);
         return _loc1_;
      }
      
      public function ___GWizSetupApp_NavigatorContent4_show(param1:FlexEvent) : void
      {
         this.aboutPanel.onShow();
      }
      
      private function _GWizSetupApp_TabBar1_i() : TabBar
      {
         var _loc1_:TabBar = new TabBar();
         _loc1_.styleName = "tabHeader";
         _loc1_.top = 9;
         _loc1_.setStyle("skinClass",GWizTabBarSkin);
         _loc1_.id = "tabs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tabs = _loc1_;
         BindingManager.executeBindings(this,"tabs",this.tabs);
         return _loc1_;
      }
      
      public function ___GWizSetupApp_Group1_show(param1:FlexEvent) : void
      {
         this.showMe(param1);
      }
      
      public function ___GWizSetupApp_Group1_hide(param1:FlexEvent) : void
      {
         this.hideMe(param1);
      }
      
      public function ___GWizSetupApp_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizSetupApp_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Object
         {
            return tabs.height + 8;
         },null,"tabNav.top");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            tabNav.setStyle("backgroundColor",param1);
         },"tabNav.backgroundColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            _GWizSetupApp_NavigatorContent1.setStyle("backgroundColor",param1);
         },"_GWizSetupApp_NavigatorContent1.backgroundColor");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            setupFiles.setStyle("backgroundColor",param1);
         },"setupFiles.backgroundColor");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            otherTab.setStyle("backgroundColor",param1);
         },"otherTab.backgroundColor");
         result[5] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            _GWizSetupApp_NavigatorContent4.setStyle("backgroundColor",param1);
         },"_GWizSetupApp_NavigatorContent4.backgroundColor");
         result[6] = new Binding(this,null,null,"aboutPanel.logoImage","logoImg");
         result[7] = new Binding(this,null,null,"tabs.dataProvider","tabNav");
         result[8] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            tabs.setStyle("chromeColor",param1);
         },"tabs.chromeColor");
         result[9] = new Binding(this,function():uint
         {
            return ColorPalette.gray5;
         },function(param1:uint):void
         {
            tabs.setStyle("color",param1);
         },"tabs.color");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get aboutPanel() : GWizAbout
      {
         return this._1416177271aboutPanel;
      }
      
      public function set aboutPanel(param1:GWizAbout) : void
      {
         var _loc2_:Object = this._1416177271aboutPanel;
         if(_loc2_ !== param1)
         {
            this._1416177271aboutPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"aboutPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get deflectOptions() : GWizDeflectOptions
      {
         return this._399483503deflectOptions;
      }
      
      public function set deflectOptions(param1:GWizDeflectOptions) : void
      {
         var _loc2_:Object = this._399483503deflectOptions;
         if(_loc2_ !== param1)
         {
            this._399483503deflectOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"deflectOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hsmOptions() : GWizHSMOptions
      {
         return this._741542780hsmOptions;
      }
      
      public function set hsmOptions(param1:GWizHSMOptions) : void
      {
         var _loc2_:Object = this._741542780hsmOptions;
         if(_loc2_ !== param1)
         {
            this._741542780hsmOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hsmOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machineProfilePanel() : GWizMachProfile
      {
         return this._899979202machineProfilePanel;
      }
      
      public function set machineProfilePanel(param1:GWizMachProfile) : void
      {
         var _loc2_:Object = this._899979202machineProfilePanel;
         if(_loc2_ !== param1)
         {
            this._899979202machineProfilePanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machineProfilePanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get otherTab() : NavigatorContent
      {
         return this._1171149211otherTab;
      }
      
      public function set otherTab(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1171149211otherTab;
         if(_loc2_ !== param1)
         {
            this._1171149211otherTab = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"otherTab",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get setupFiles() : NavigatorContent
      {
         return this._1047107066setupFiles;
      }
      
      public function set setupFiles(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1047107066setupFiles;
         if(_loc2_ !== param1)
         {
            this._1047107066setupFiles = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"setupFiles",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tabNav() : ViewStack
      {
         return this._881406642tabNav;
      }
      
      public function set tabNav(param1:ViewStack) : void
      {
         var _loc2_:Object = this._881406642tabNav;
         if(_loc2_ !== param1)
         {
            this._881406642tabNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tabNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tabs() : TabBar
      {
         return this._3552126tabs;
      }
      
      public function set tabs(param1:TabBar) : void
      {
         var _loc2_:Object = this._3552126tabs;
         if(_loc2_ !== param1)
         {
            this._3552126tabs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tabs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get logoImg() : Class
      {
         return this._342488600logoImg;
      }
      
      public function set logoImg(param1:Class) : void
      {
         var _loc2_:Object = this._342488600logoImg;
         if(_loc2_ !== param1)
         {
            this._342488600logoImg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"logoImg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get fsFile() : File
      {
         return this._1266399255fsFile;
      }
      
      private function set fsFile(param1:File) : void
      {
         var _loc2_:Object = this._1266399255fsFile;
         if(_loc2_ !== param1)
         {
            this._1266399255fsFile = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fsFile",_loc2_,param1));
            }
         }
      }
   }
}
