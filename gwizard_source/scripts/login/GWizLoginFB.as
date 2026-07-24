package login
{
   import com.adobe.protocols.oauth2.OAuth2;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.media.StageWebView;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.HRule;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import utils.GATracker;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizLoginFB extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizLoginFB");
      
      private static var _3599307user:GWizUserData;
      
      public static var loginDoneCallback:Function;
      
      public static var loginMgrLoginDoneCallback:Function;
      
      private static var lastLoginShown:Date = null;
      
      private static var loginsTried:int = 0;
      
      private static const FONT_SZ:int = 16;
      
      private static const OBJ_HT:int = 45;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _67066748Email:TextInput;
      
      public var _GWizLoginFB_Button1:Button;
      
      public var _GWizLoginFB_Button2:Button;
      
      public var _GWizLoginFB_Button3:Button;
      
      private var _625841193newUserLabel:Label;
      
      private var _667896966theVGroup:VGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _stageWebView:StageWebView;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizLoginFB()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizLoginFB_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_login_GWizLoginFBWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizLoginFB[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.width = 400;
         this.height = 480;
         this.backgroundColor = "0xffffff";
         this.horizontalAlign = "center";
         this.verticalAlign = "middle";
         this.title = "G-Wizard Login";
         this.okLabel = "";
         this.cancelLabel = "";
         this.mxmlContent = [this._GWizLoginFB_VGroup1_i()];
         this.addEventListener("creationComplete",this.___GWizLoginFB_GWizPopUp1_creationComplete);
         this.addEventListener("keyUp",this.___GWizLoginFB_GWizPopUp1_keyUp);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function showLoginFB() : GWizLoginFB
      {
         var _loc2_:Date = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc1_:Boolean = false;
         if(lastLoginShown)
         {
            _loc2_ = new Date();
            _loc3_ = _loc2_.valueOf() - lastLoginShown.valueOf();
            _loc4_ = 5 * 1000;
            _loc1_ = _loc3_ < _loc4_ && loginsTried > 2;
         }
         if(GWizLoginSplash.loginMsgShowing)
         {
            return null;
         }
         if(GWizSessionSvc.checkinPending || _loc1_)
         {
            GWizPopUpManager.Show("Hangon, already waiting for a login response from Cloud.","Can\'t Login",GWizPopUpManager.WARN);
            return null;
         }
         lastLoginShown = new Date();
         ++loginsTried;
         return GWizPopUpManager.createPopUp(null,GWizLoginFB,true,true) as GWizLoginFB;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizLoginFB._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get user() : GWizUserData
      {
         return GWizLoginFB._3599307user;
      }
      
      public static function set user(param1:GWizUserData) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizLoginFB._3599307user;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizLoginFB,"user",_loc2_,param1));
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
            this.color = 0;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onCC() : void
      {
         title = GWizSettings.loginBar.appLongNameParm + " Login";
         user = GWizUserData.instance();
         this.showCloseButton = false;
         OAuth2.oAuthCompleteFcn = this.oAuthCompleteHandler;
         if(user.email != "" && user.email != GWizLoginBar.GUEST_NAME)
         {
            this.Email.text = user.email;
         }
         GATracker.logPageView("Login/GetEmail","Login/GetEmail");
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.charCode == GWizStringUtils.CR.charCodeAt(0))
         {
            this.doLoginBtn();
         }
      }
      
      private function initStageWebView() : void
      {
         this._stageWebView = new StageWebView();
         this._stageWebView.stage = this.stage;
         this._stageWebView.assignFocus();
         this._stageWebView.viewPort = new Rectangle(0,0,this.stage.stageWidth,this.stage.stageHeight);
      }
      
      private function oAuthCompleteHandler(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.onOk(null);
         }
      }
      
      override public function onOk(param1:Event) : void
      {
         super.close();
         if(this._stageWebView)
         {
            this._stageWebView.stage = null;
            this._stageWebView = null;
         }
         GWizLoginBar.LoginParm = this.Email.text;
         if(loginDoneCallback != null)
         {
            loginDoneCallback();
         }
         if(loginMgrLoginDoneCallback != null && GWizUtils.debug)
         {
            loginMgrLoginDoneCallback();
         }
      }
      
      override public function onCancel(param1:Event) : void
      {
      }
      
      override public function close() : void
      {
      }
      
      private function onGoogleBtnTriggered() : void
      {
         log.debug("Google Login");
         user.provider = "Google";
         this.initStageWebView();
         var _loc1_:GWizLoginGoogle = new GWizLoginGoogle(this._stageWebView,user,this.loginCallback);
         GWizLoginGoogle.login();
      }
      
      private function onFacebookBtnTriggered() : void
      {
         log.debug("Facebook Login");
         user.provider = "Facebook";
         this.initStageWebView();
         var _loc1_:GWizLoginFacebook = new GWizLoginFacebook(this._stageWebView,user,this.loginCallback);
         GWizLoginFacebook.login();
      }
      
      private function onAuth0BtnTriggered(param1:String = "") : void
      {
         log.debug("Auth0 Login");
         user.provider = "Auth0";
         GATracker.logPageView("SocialLogin/" + param1,"SocialLogin: " + param1);
         this.initStageWebView();
         var _loc2_:GWizLoginAuth0 = new GWizLoginAuth0(this._stageWebView,user,this.loginCallback);
         GWizLoginAuth0.login(param1);
      }
      
      private function loginCallback() : void
      {
         log.debug("Email: " + user.email);
         log.debug("Display Name: " + user.name);
         log.debug("Access Token: " + user.token);
         log.debug("Provider: " + user.provider);
         this.onOk(null);
      }
      
      private function doLoginBtn() : void
      {
         if(this.Email.text == "")
         {
            return;
         }
         GATracker.logPageView("EmailLogin","EmailLogin");
         user.email = this.Email.text;
         user.token = "";
         user.name = this.Email.text;
         user.provider = "Email";
         this.onOk(null);
      }
      
      private function doLogout() : void
      {
         GWizLoginFacebook.logout(user.token);
         user.token = "";
      }
      
      private function doRegisterBtn() : void
      {
         GWizUtils.doWebPage(GWizEvalPopUp.registerURL);
      }
      
      private function doHelp() : void
      {
         GWizUtils.doWebPage("https://www.cnccookbook.com/g-wizard-troubleshooting/");
      }
      
      private function _GWizLoginFB_VGroup1_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.gap = 15;
         _loc1_.mxmlContent = [this._GWizLoginFB_HGroup1_c(),this._GWizLoginFB_TextInput1_i(),this._GWizLoginFB_Button2_i(),this._GWizLoginFB_Label2_c(),this._GWizLoginFB_HRule1_c(),this._GWizLoginFB_Label3_i(),this._GWizLoginFB_Button3_i()];
         _loc1_.id = "theVGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theVGroup = _loc1_;
         BindingManager.executeBindings(this,"theVGroup",this.theVGroup);
         return _loc1_;
      }
      
      private function _GWizLoginFB_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizLoginFB_Label1_c(),this._GWizLoginFB_Spacer1_c(),this._GWizLoginFB_Button1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginFB_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Log in";
         _loc1_.setStyle("fontSize",24);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginFB_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginFB_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "?";
         _loc1_.setStyle("color",16777215);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("chromeColor",14694453);
         _loc1_.addEventListener("click",this.___GWizLoginFB_Button1_click);
         _loc1_.id = "_GWizLoginFB_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginFB_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginFB_Button1",this._GWizLoginFB_Button1);
         return _loc1_;
      }
      
      public function ___GWizLoginFB_Button1_click(param1:MouseEvent) : void
      {
         this.doHelp();
      }
      
      private function _GWizLoginFB_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.prompt = "Email you registered with";
         _loc1_.percentWidth = 100;
         _loc1_.selectable = true;
         _loc1_.id = "Email";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Email = _loc1_;
         BindingManager.executeBindings(this,"Email",this.Email);
         return _loc1_;
      }
      
      private function _GWizLoginFB_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Log in";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("chromeColor",3889560);
         _loc1_.setStyle("color",16777215);
         _loc1_.addEventListener("click",this.___GWizLoginFB_Button2_click);
         _loc1_.id = "_GWizLoginFB_Button2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginFB_Button2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginFB_Button2",this._GWizLoginFB_Button2);
         return _loc1_;
      }
      
      public function ___GWizLoginFB_Button2_click(param1:MouseEvent) : void
      {
         this.doLoginBtn();
      }
      
      private function _GWizLoginFB_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoginFB_HRule1_c() : HRule
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
      
      private function _GWizLoginFB_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "New user? Register to get your login going:";
         _loc1_.id = "newUserLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.newUserLabel = _loc1_;
         BindingManager.executeBindings(this,"newUserLabel",this.newUserLabel);
         return _loc1_;
      }
      
      private function _GWizLoginFB_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Register";
         _loc1_.percentWidth = 40;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("click",this.___GWizLoginFB_Button3_click);
         _loc1_.id = "_GWizLoginFB_Button3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizLoginFB_Button3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizLoginFB_Button3",this._GWizLoginFB_Button3);
         return _loc1_;
      }
      
      public function ___GWizLoginFB_Button3_click(param1:MouseEvent) : void
      {
         this.doRegisterBtn();
      }
      
      public function ___GWizLoginFB_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizLoginFB_GWizPopUp1_keyUp(param1:KeyboardEvent) : void
      {
         this.onKeyUp(param1);
      }
      
      private function _GWizLoginFB_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return FONT_SZ;
         },function(param1:Number):void
         {
            _GWizLoginFB_Button1.setStyle("fontSize",param1);
         },"_GWizLoginFB_Button1.fontSize");
         result[1] = new Binding(this,function():Number
         {
            return OBJ_HT;
         },null,"_GWizLoginFB_Button1.width");
         result[2] = new Binding(this,function():Number
         {
            return OBJ_HT;
         },null,"_GWizLoginFB_Button1.height");
         result[3] = new Binding(this,function():Number
         {
            return OBJ_HT / 2;
         },function(param1:Number):void
         {
            _GWizLoginFB_Button1.setStyle("cornerRadius",param1);
         },"_GWizLoginFB_Button1.cornerRadius");
         result[4] = new Binding(this,function():Number
         {
            return FONT_SZ;
         },function(param1:Number):void
         {
            Email.setStyle("fontSize",param1);
         },"Email.fontSize");
         result[5] = new Binding(this,function():Number
         {
            return OBJ_HT;
         },null,"Email.height");
         result[6] = new Binding(this,function():Number
         {
            return FONT_SZ;
         },function(param1:Number):void
         {
            _GWizLoginFB_Button2.setStyle("fontSize",param1);
         },"_GWizLoginFB_Button2.fontSize");
         result[7] = new Binding(this,function():Number
         {
            return OBJ_HT;
         },null,"_GWizLoginFB_Button2.height");
         result[8] = new Binding(this,function():Number
         {
            return FONT_SZ;
         },function(param1:Number):void
         {
            _GWizLoginFB_Button3.setStyle("fontSize",param1);
         },"_GWizLoginFB_Button3.fontSize");
         result[9] = new Binding(this,function():Number
         {
            return OBJ_HT;
         },null,"_GWizLoginFB_Button3.height");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Email() : TextInput
      {
         return this._67066748Email;
      }
      
      public function set Email(param1:TextInput) : void
      {
         var _loc2_:Object = this._67066748Email;
         if(_loc2_ !== param1)
         {
            this._67066748Email = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Email",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get newUserLabel() : Label
      {
         return this._625841193newUserLabel;
      }
      
      public function set newUserLabel(param1:Label) : void
      {
         var _loc2_:Object = this._625841193newUserLabel;
         if(_loc2_ !== param1)
         {
            this._625841193newUserLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"newUserLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theVGroup() : VGroup
      {
         return this._667896966theVGroup;
      }
      
      public function set theVGroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._667896966theVGroup;
         if(_loc2_ !== param1)
         {
            this._667896966theVGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theVGroup",_loc2_,param1));
            }
         }
      }
   }
}
