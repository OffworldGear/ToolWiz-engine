package loginp
{
   import comps.GWizLogo;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.display.Screen;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.system.Capabilities;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.managers.PopUpManager;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.VGroup;
   import spark.components.Window;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizSplash extends Window implements IBindingClient
   {
      
      public static var masterLogo:Class;
      
      private static var _1079312431imgGWizLogo:Class = GWizSplash_imgGWizLogo;
      
      private static var _859728225imgCriticalMassLogo:Class = GWizSplash_imgCriticalMassLogo;
      
      private static var _209796312imgTormachLogo:Class = GWizSplash_imgTormachLogo;
      
      private static var _528976181imgPMLogo:Class = GWizSplash_imgPMLogo;
      
      private static var _821662727imgMariLogo:Class = GWizSplash_imgMariLogo;
      
      private static var _1227776863imgIHCNCLogo:Class = GWizSplash_imgIHCNCLogo;
      
      private static var _1534143693imgGrizzlyLogo:Class = GWizSplash_imgGrizzlyLogo;
      
      private static var _1390362070imgGMTLogo:Class = GWizSplash_imgGMTLogo;
      
      private static var _578153856imgGarrToolLogo:Class = GWizSplash_imgGarrToolLogo;
      
      private static var _785606112imgAcmeToolLogo:Class = GWizSplash_imgAcmeToolLogo;
      
      private static var _1070810209imgFullertonLogo:Class = GWizSplash_imgFullertonLogo;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _2084971668GWizLogo:Image;
      
      private var _1081729972madeBy:Label;
      
      private var _2008465223special:GWizLogo;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var myTimer:Timer;
      
      public var showMain:Function = null;
      
      private var hasClosed:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizSplash()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizSplash_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_loginp_GWizSplashWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizSplash[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.width = 512;
         this.height = 512;
         this.visible = false;
         this.systemChrome = "none";
         this.showStatusBar = false;
         this.alwaysInFront = true;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizSplash_Array1_c);
         this.addEventListener("initialize",this.___GWizSplash_Window1_initialize);
         this.addEventListener("click",this.___GWizSplash_Window1_click);
         this.addEventListener("creationComplete",this.___GWizSplash_Window1_creationComplete);
         this.addEventListener("close",this.___GWizSplash_Window1_close);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizSplash._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgGWizLogo() : Class
      {
         return GWizSplash._1079312431imgGWizLogo;
      }
      
      public static function set imgGWizLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._1079312431imgGWizLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgGWizLogo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgCriticalMassLogo() : Class
      {
         return GWizSplash._859728225imgCriticalMassLogo;
      }
      
      public static function set imgCriticalMassLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._859728225imgCriticalMassLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgCriticalMassLogo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgTormachLogo() : Class
      {
         return GWizSplash._209796312imgTormachLogo;
      }
      
      public static function set imgTormachLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._209796312imgTormachLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgTormachLogo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgPMLogo() : Class
      {
         return GWizSplash._528976181imgPMLogo;
      }
      
      public static function set imgPMLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._528976181imgPMLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgPMLogo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgMariLogo() : Class
      {
         return GWizSplash._821662727imgMariLogo;
      }
      
      public static function set imgMariLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._821662727imgMariLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgMariLogo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgIHCNCLogo() : Class
      {
         return GWizSplash._1227776863imgIHCNCLogo;
      }
      
      public static function set imgIHCNCLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._1227776863imgIHCNCLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgIHCNCLogo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgGrizzlyLogo() : Class
      {
         return GWizSplash._1534143693imgGrizzlyLogo;
      }
      
      public static function set imgGrizzlyLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._1534143693imgGrizzlyLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgGrizzlyLogo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgGMTLogo() : Class
      {
         return GWizSplash._1390362070imgGMTLogo;
      }
      
      public static function set imgGMTLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._1390362070imgGMTLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgGMTLogo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgGarrToolLogo() : Class
      {
         return GWizSplash._578153856imgGarrToolLogo;
      }
      
      public static function set imgGarrToolLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._578153856imgGarrToolLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgGarrToolLogo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgAcmeToolLogo() : Class
      {
         return GWizSplash._785606112imgAcmeToolLogo;
      }
      
      public static function set imgAcmeToolLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._785606112imgAcmeToolLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgAcmeToolLogo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get imgFullertonLogo() : Class
      {
         return GWizSplash._1070810209imgFullertonLogo;
      }
      
      public static function set imgFullertonLogo(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSplash._1070810209imgFullertonLogo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSplash,"imgFullertonLogo",_loc2_,param1));
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
            this.backgroundColor = 0;
            this.backgroundAlpha = 1;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function init() : void
      {
         nativeWindow.x = (Capabilities.screenResolutionX - this.width) / 2;
         nativeWindow.y = (Capabilities.screenResolutionY - this.height) / 2;
      }
      
      private function showSplash() : void
      {
         this.setStyle("backgroundAlpha",1);
         this.visible = true;
         this.callLater(this.restOfSplash);
      }
      
      private function restOfSplash() : void
      {
         var _loc1_:String = "";
         if(GWizAbstractPrefs.logoStr)
         {
            _loc1_ = GWizAbstractPrefs.logoStr.toLowerCase();
         }
         if(GWizAbstractPrefs.isOEM)
         {
            _loc1_ = GWizAbstractPrefs.oemStr;
         }
         switch(_loc1_)
         {
            case "tormach":
               masterLogo = imgTormachLogo;
               break;
            case "pm":
               masterLogo = imgPMLogo;
               break;
            case "maritool":
               masterLogo = imgMariLogo;
               break;
            case "ihcnc":
               masterLogo = imgIHCNCLogo;
               break;
            case "grizzly":
               masterLogo = imgGrizzlyLogo;
               break;
            case "glacern":
               masterLogo = imgGMTLogo;
               break;
            case "critical mass":
               masterLogo = imgCriticalMassLogo;
               break;
            case GWizAbstractPrefs.GARR_OEM_STR:
               masterLogo = imgGarrToolLogo;
               break;
            case GWizAbstractPrefs.ACME_OEM_STR:
               masterLogo = imgAcmeToolLogo;
               break;
            case GWizAbstractPrefs.FULLERTON_OEM_STR:
               masterLogo = imgFullertonLogo;
               break;
            case "gwizard":
            case "":
               masterLogo = imgGWizLogo;
               break;
            default:
               masterLogo = imgGWizLogo;
         }
         this.GWizLogo.source = masterLogo;
         this.GWizLogo.visible = true;
         this.callLater(this.timeSplash);
      }
      
      private function timerHandler(param1:TimerEvent) : void
      {
         this.closeSplash();
      }
      
      private function timeSplash() : void
      {
         this.myTimer = new Timer(3000,1);
         this.myTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerHandler);
         this.myTimer.reset();
         this.myTimer.start();
      }
      
      private function closeSplash() : void
      {
         var _loc1_:Screen = null;
         if(this.showMain != null)
         {
            this.showMain();
         }
         if(this.hasClosed)
         {
            return;
         }
         this.hasClosed = true;
         if(false && GWizSettings.docWindow)
         {
            PopUpManager.addPopUp(GWizSettings.docWindow,GWizSettings.docWindow);
         }
         if(this.myTimer)
         {
            this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timerHandler);
         }
         nativeWindow.close();
         if(GWizSettings.docWindow)
         {
            _loc1_ = Screen.mainScreen;
            if(GWizSettings.prefs.docWinWidth > _loc1_.visibleBounds.width)
            {
               GWizSettings.prefs.docWinWidth = _loc1_.visibleBounds.width;
               GWizSettings.prefs.docWinMaximized = true;
            }
            if(GWizSettings.prefs.docWinHeight > _loc1_.visibleBounds.height)
            {
               GWizSettings.prefs.docWinHeight = _loc1_.visibleBounds.height;
               GWizSettings.prefs.docWinMaximized = true;
            }
            GWizSettings.docWindow.width = GWizSettings.prefs.docWinWidth;
            GWizSettings.docWindow.height = GWizSettings.prefs.docWinHeight;
            if(GWizSettings.prefs.docWinMaximized)
            {
               GWizSettings.docWindow.maximize();
            }
            GWizSettings.docWindow.nativeWindow.x = (Capabilities.screenResolutionX - GWizSettings.docWindow.width) / 2;
            GWizSettings.docWindow.nativeWindow.y = (Capabilities.screenResolutionY - GWizSettings.docWindow.height) / 2;
            GWizSettings.docWindow.visible = true;
         }
         GWizSettings.splashDone = true;
         GWizUtils.LogErrorContext = "GWizSplash.closeSplash";
      }
      
      private function _GWizSplash_Array1_c() : Array
      {
         return [this._GWizSplash_VGroup1_c()];
      }
      
      private function _GWizSplash_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizSplash_Image1_i(),this._GWizSplash_GWizLogo1_i(),this._GWizSplash_Spacer1_c(),this._GWizSplash_Label1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSplash_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.visible = false;
         _loc1_.addEventListener("click",this.__GWizLogo_click);
         _loc1_.id = "GWizLogo";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GWizLogo = _loc1_;
         BindingManager.executeBindings(this,"GWizLogo",this.GWizLogo);
         return _loc1_;
      }
      
      public function __GWizLogo_click(param1:MouseEvent) : void
      {
         this.closeSplash();
      }
      
      private function _GWizSplash_GWizLogo1_i() : GWizLogo
      {
         var _loc1_:GWizLogo = new GWizLogo();
         _loc1_.visible = false;
         _loc1_.width = 0;
         _loc1_.height = 0;
         _loc1_.addEventListener("click",this.__special_click);
         _loc1_.id = "special";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.special = _loc1_;
         BindingManager.executeBindings(this,"special",this.special);
         return _loc1_;
      }
      
      public function __special_click(param1:MouseEvent) : void
      {
         this.closeSplash();
      }
      
      private function _GWizSplash_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSplash_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "madeBy";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.madeBy = _loc1_;
         BindingManager.executeBindings(this,"madeBy",this.madeBy);
         return _loc1_;
      }
      
      public function ___GWizSplash_Window1_initialize(param1:FlexEvent) : void
      {
         this.init();
      }
      
      public function ___GWizSplash_Window1_click(param1:MouseEvent) : void
      {
         this.closeSplash();
      }
      
      public function ___GWizSplash_Window1_creationComplete(param1:FlexEvent) : void
      {
         this.showSplash();
      }
      
      public function ___GWizSplash_Window1_close(param1:Event) : void
      {
         this.closeSplash();
      }
      
      private function _GWizSplash_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():String
         {
            var _loc1_:* = "Made by " + GWizAbstractPrefs.madeByStr + " in America";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"madeBy.text");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get GWizLogo() : Image
      {
         return this._2084971668GWizLogo;
      }
      
      public function set GWizLogo(param1:Image) : void
      {
         var _loc2_:Object = this._2084971668GWizLogo;
         if(_loc2_ !== param1)
         {
            this._2084971668GWizLogo = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GWizLogo",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get madeBy() : Label
      {
         return this._1081729972madeBy;
      }
      
      public function set madeBy(param1:Label) : void
      {
         var _loc2_:Object = this._1081729972madeBy;
         if(_loc2_ !== param1)
         {
            this._1081729972madeBy = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"madeBy",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get special() : GWizLogo
      {
         return this._2008465223special;
      }
      
      public function set special(param1:GWizLogo) : void
      {
         var _loc2_:Object = this._2008465223special;
         if(_loc2_ !== param1)
         {
            this._2008465223special = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"special",_loc2_,param1));
            }
         }
      }
   }
}
