package bubbletip
{
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import login.GWizOfferBtn;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
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
   import spark.components.VGroup;
   import spark.components.Window;
   import spark.primitives.Line;
   import spark.primitives.Rect;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizStartWizard extends Window implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizStartWizard");
      
      private static var theWiz:GWizStartWizard = null;
      
      private static var startWizTries:int = 0;
      
      public static var startWizardActive:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizStartWizard_GWizBubbleTip1:GWizBubbleTip;
      
      private var _1953597123bubbleTarget:Label;
      
      private var _1343177646msgArea:Group;
      
      private var _2099746085tipParent:VGroup;
      
      private var _415513332welcomeLbl:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var exitRecurse:Boolean = false;
      
      private var _embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizStartWizard()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486 = GWizStartWizard__embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizStartWizard_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_bubbletip_GWizStartWizardWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizStartWizard[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.width = 640;
         this.height = 480;
         this.title = "Startup Wizard";
         this.showStatusBar = false;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizStartWizard_Array1_c);
         this.addEventListener("closing",this.___GWizStartWizard_Window1_closing);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function launchStartWizard(param1:GWizAbstractBubbleMsgs) : void
      {
         var _loc2_:GWizJustASec = null;
         if(!GWizSettings.bubbleMsgs)
         {
            GWizSettings.bubbleMsgs = param1;
         }
         if(GWizSettings.gotPreferences && GWizSettings.splashDone)
         {
            launchStartWizardAux();
         }
         else if(startWizTries < 15)
         {
            _loc2_ = new GWizJustASec(launchStartWizardAux);
            ++startWizTries;
         }
         else
         {
            GWizUtils.assert(false);
         }
         GWizOfferBtn.getOffers();
      }
      
      private static function launchStartWizardAux() : void
      {
         var _loc1_:GWizJustASec = null;
         if(GWizSettings.gotPreferences)
         {
            if(GWizSettings.loginBar.guestLogin())
            {
               GWizLoginWizard.launchLoginWizard(GWizLoginWizard.EMAIL_STATE);
            }
         }
         else
         {
            _loc1_ = new GWizJustASec(launchStartWizardAux);
         }
      }
      
      public static function userOnboard() : Boolean
      {
         var _loc1_:Date = new Date(GWizSettings.prefs.authenticateDate);
         return _loc1_ != null && GWizSettings.prefs.authenticateDate && GWizSettings.prefs.authenticateDate != "";
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizStartWizard._watcherSetupUtil = param1;
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
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function doExit() : void
      {
         if(this.exitRecurse)
         {
            return;
         }
         this.exitRecurse = true;
         GWizSettings.startWizardRun = true;
         this.close();
         if(GWizSettings.bubbleMsgs)
         {
            GWizSettings.bubbleMsgs.finishedBubble("StartWizard",true);
         }
         startWizardActive = false;
         GWizOfferBtn.getOffers();
      }
      
      private function _GWizStartWizard_Array1_c() : Array
      {
         return [this._GWizStartWizard_HGroup1_c()];
      }
      
      private function _GWizStartWizard_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizStartWizard_VGroup1_c(),this._GWizStartWizard_Line1_c(),this._GWizStartWizard_VGroup2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizStartWizard_Image1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_Line1_c() : Line
      {
         var _loc1_:Line = new Line();
         _loc1_.percentHeight = 100;
         _loc1_.stroke = this._GWizStartWizard_SolidColorStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizStartWizard_SolidColorStroke1_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 16777215;
         _loc1_.weight = 2;
         _loc1_.caps = "square";
         return _loc1_;
      }
      
      private function _GWizStartWizard_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "left";
         _loc1_.paddingTop = 5;
         _loc1_.paddingRight = 5;
         _loc1_.mxmlContent = [this._GWizStartWizard_Group1_i(),this._GWizStartWizard_Spacer1_c(),this._GWizStartWizard_HGroup2_c(),this._GWizStartWizard_Spacer3_c()];
         _loc1_.id = "tipParent";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tipParent = _loc1_;
         BindingManager.executeBindings(this,"tipParent",this.tipParent);
         return _loc1_;
      }
      
      private function _GWizStartWizard_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizStartWizard_Rect1_c(),this._GWizStartWizard_VGroup3_c()];
         _loc1_.id = "msgArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msgArea = _loc1_;
         BindingManager.executeBindings(this,"msgArea",this.msgArea);
         return _loc1_;
      }
      
      private function _GWizStartWizard_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.fill = this._GWizStartWizard_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizStartWizard_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         return _loc1_;
      }
      
      private function _GWizStartWizard_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingTop = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizStartWizard_Label1_i(),this._GWizStartWizard_Label2_c(),this._GWizStartWizard_Label3_c(),this._GWizStartWizard_Label4_c(),this._GWizStartWizard_Label5_c(),this._GWizStartWizard_GWizBubbleTip1_i(),this._GWizStartWizard_Label7_c(),this._GWizStartWizard_Label8_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "{\'Welcome to \' + GWizSettings.loginBar.appLongNameParm + \'!\'";
         _loc1_.setStyle("fontSize",21);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "welcomeLbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.welcomeLbl = _loc1_;
         BindingManager.executeBindings(this,"welcomeLbl",this.welcomeLbl);
         return _loc1_;
      }
      
      private function _GWizStartWizard_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "As you move around in GWSF, you\'ll notice we\'ve scattered some \'Bubble Tips\' around.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "They look like this:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_GWizBubbleTip1_i() : GWizBubbleTip
      {
         var _loc1_:GWizBubbleTip = new GWizBubbleTip();
         _loc1_.bubbleID = "StartWizard";
         _loc1_.mxmlContent = [this._GWizStartWizard_Label6_i()];
         _loc1_.id = "_GWizStartWizard_GWizBubbleTip1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizStartWizard_GWizBubbleTip1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizStartWizard_GWizBubbleTip1",this._GWizStartWizard_GWizBubbleTip1);
         return _loc1_;
      }
      
      private function _GWizStartWizard_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "See the Bubble to the left?";
         _loc1_.id = "bubbleTarget";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.bubbleTarget = _loc1_;
         BindingManager.executeBindings(this,"bubbleTarget",this.bubbleTarget);
         return _loc1_;
      }
      
      private function _GWizStartWizard_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Go ahead and click on the Bubble.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizStartWizard_Spacer2_c(),this._GWizStartWizard_Button1_c()];
         _loc1_.setStyle("color",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizStartWizard_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Got It!";
         _loc1_.addEventListener("click",this.___GWizStartWizard_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizStartWizard_Button1_click(param1:MouseEvent) : void
      {
         this.doExit();
      }
      
      private function _GWizStartWizard_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizStartWizard_Window1_closing(param1:Event) : void
      {
         this.doExit();
      }
      
      private function _GWizStartWizard_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"_GWizStartWizard_GWizBubbleTip1.myWindow");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get bubbleTarget() : Label
      {
         return this._1953597123bubbleTarget;
      }
      
      public function set bubbleTarget(param1:Label) : void
      {
         var _loc2_:Object = this._1953597123bubbleTarget;
         if(_loc2_ !== param1)
         {
            this._1953597123bubbleTarget = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bubbleTarget",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get msgArea() : Group
      {
         return this._1343177646msgArea;
      }
      
      public function set msgArea(param1:Group) : void
      {
         var _loc2_:Object = this._1343177646msgArea;
         if(_loc2_ !== param1)
         {
            this._1343177646msgArea = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"msgArea",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tipParent() : VGroup
      {
         return this._2099746085tipParent;
      }
      
      public function set tipParent(param1:VGroup) : void
      {
         var _loc2_:Object = this._2099746085tipParent;
         if(_loc2_ !== param1)
         {
            this._2099746085tipParent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tipParent",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get welcomeLbl() : Label
      {
         return this._415513332welcomeLbl;
      }
      
      public function set welcomeLbl(param1:Label) : void
      {
         var _loc2_:Object = this._415513332welcomeLbl;
         if(_loc2_ !== param1)
         {
            this._415513332welcomeLbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"welcomeLbl",_loc2_,param1));
            }
         }
      }
   }
}
