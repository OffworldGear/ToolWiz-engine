package bubbletip
{
   import comps.GWizPopUp;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.StageWebView;
   import login.GWizOfferBtn;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.MoveEvent;
   import mx.events.PropertyChangeEvent;
   import mx.events.ResizeEvent;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.VGroup;
   import spark.primitives.Line;
   import spark.primitives.Rect;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   public class GWizAbstractTipWindow extends GWizPopUp
   {
       
      
      private var _14372992Optional:Button;
      
      private var _1779458682StopTips:CheckBox;
      
      private var _1343177646msgArea:Group;
      
      private var _2099746085tipParent:VGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      protected var webView:StageWebView;
      
      public var tipJar:Array;
      
      public var BeginnerEnd:int = 0;
      
      private var ccDone:Boolean = false;
      
      private var _embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486:Class;
      
      private var _embed_mxml__assets_Tip128Hi_jpg_1024017774:Class;
      
      public function GWizAbstractTipWindow()
      {
         this.webView = new StageWebView();
         this.tipJar = [];
         this._embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486 = GWizAbstractTipWindow__embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486;
         this._embed_mxml__assets_Tip128Hi_jpg_1024017774 = GWizAbstractTipWindow__embed_mxml__assets_Tip128Hi_jpg_1024017774;
         super();
         mx_internal::_document = this;
         this.width = 500;
         this.height = 480;
         this.title = "Welcome!";
         this.cancelLabel = "Continue";
         this.okLabel = "Random Tip";
         this.mxmlContent = [this._GWizAbstractTipWindow_HGroup1_c()];
         this.addEventListener("creationComplete",this.___GWizAbstractTipWindow_GWizPopUp1_creationComplete);
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
      
      public function setTipInfo() : void
      {
         var _loc1_:GWizJustASec = null;
         if(this.ccDone)
         {
            this.doTip();
         }
         else
         {
            _loc1_ = new GWizJustASec(this.setTipInfo);
         }
      }
      
      public function doCC() : void
      {
         var _loc1_:GWizJustASec = null;
         if(stage && GWizSettings.splashDone)
         {
            if(GWizStartWizard.startWizardActive || GWizOfferBtn.didOfferPop || GWizLoginWizard.theWiz)
            {
               this.doCancel();
               this.ccDone = true;
               return;
            }
            this.msgArea.setStyle("backgroundColor","0xFFFFFF");
            this.owner.addEventListener(MoveEvent.MOVE,this.resizeWebView);
            this.resizeWebView();
            this.ccDone = true;
         }
         else
         {
            _loc1_ = new GWizJustASec(this.doCC);
         }
      }
      
      private function doRandomTip(param1:Boolean) : void
      {
         this.Optional.visible = false;
         var _loc2_:int = this.tipJar.length;
         if(param1)
         {
            _loc2_ = this.BeginnerEnd;
         }
         this.loadTip(this.tipJar[int(Math.random() * _loc2_)]);
      }
      
      private function doTip() : void
      {
         var _loc1_:Number = Math.random();
         if(GWizSettings.prefs.logins <= 10)
         {
            switch(int(Math.round(_loc1_ * 4)))
            {
               case 0:
                  this.doTutorialVid();
                  break;
               case 1:
                  this.doRelNotes();
                  break;
               case 2:
                  this.doRandomTip(true);
                  break;
               default:
                  this.doRandomTip(false);
            }
         }
         else
         {
            switch(int(Math.round(_loc1_ * 10)))
            {
               case 0:
                  this.doTutorialVid();
                  break;
               case 1:
                  this.doRelNotes();
                  break;
               default:
                  if(!GWizSettings.prefs.showedReleaseNotes && int(Math.round(_loc1_ * 10)) % 2)
                  {
                     this.doRelNotes();
                  }
                  else
                  {
                     this.doRandomTip(false);
                  }
            }
         }
      }
      
      private function doCancel() : void
      {
         this.removeWebView();
         this.owner.removeEventListener(MoveEvent.MOVE,this.resizeWebView);
         super.close();
      }
      
      private function doRelNotes() : void
      {
         var _loc1_:* = null;
         _loc1_ = "<p></p>";
         _loc1_ += "<p><b>Would you like to see what\'s new in the G-Wizard release you are running?</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>You can bring up the release notes by clicking the button below. They\'ll tell you what\'s new about the release you\'re currently running.</p>";
         this.loadTip(_loc1_);
         this.Optional.label = "Release Notes";
         this.Optional.visible = true;
      }
      
      private function doTutorialVid() : void
      {
         var _loc1_:* = null;
         _loc1_ = "<p></p>";
         _loc1_ += "<p><b>Would you like to see a short video tour of G-Wizard to help get you started?</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>You can bring up the tour by clicking the button below.</p>";
         this.loadTip(_loc1_);
         this.Optional.label = "Watch Tour";
         this.Optional.visible = true;
      }
      
      public function getChangeLogURL() : String
      {
         return "http://www.cnccookbook.com/CCGWizardChangeLog.htm";
      }
      
      public function getTourURL() : String
      {
         return "http://www.cnccookbook.com/CCGWizardv6.html";
      }
      
      private function doOptional() : void
      {
         switch(this.Optional.label)
         {
            case "Release Notes":
               GWizUtils.doWebPage(this.getChangeLogURL());
               GWizSettings.prefs.showedReleaseNotes = true;
               break;
            case "Watch Tour":
               GWizUtils.doWebPage(this.getTourURL());
               GWizSettings.prefs.showedReleaseNotes = true;
         }
         this.doCancel();
      }
      
      protected function resizeWebView(param1:Event = null) : void
      {
         var _loc2_:Point = null;
         if(!stage.nativeWindow)
         {
            width = stage.fullScreenWidth;
            height = stage.fullScreenHeight;
         }
         if(this.webView)
         {
            _loc2_ = new Point(this.msgArea.x + 5,this.msgArea.y + 5);
            _loc2_ = this.tipParent.localToGlobal(_loc2_);
            this.webView.viewPort = new Rectangle(_loc2_.x + 5,_loc2_.y + 5,this.msgArea.width - 10,this.msgArea.height - 10);
         }
      }
      
      private function removeWebView() : void
      {
         this.webView.viewPort = null;
         this.webView.dispose();
         this.webView = null;
      }
      
      private function doStopTips() : void
      {
         GWizSettings.prefs.showTips = !this.StopTips.selected;
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doCancel();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doTip();
      }
      
      private function loadTip(param1:String) : void
      {
         if(this.webView)
         {
            this.webView.stage = stage;
            this.resizeWebView();
            this.webView.loadString(param1);
         }
      }
      
      private function _GWizAbstractTipWindow_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizAbstractTipWindow_VGroup1_c(),this._GWizAbstractTipWindow_Line1_c(),this._GWizAbstractTipWindow_VGroup2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizAbstractTipWindow_Image1_c(),this._GWizAbstractTipWindow_Image2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_Tip128Hi_jpg_1024017774;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_Image2_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_Line1_c() : Line
      {
         var _loc1_:Line = new Line();
         _loc1_.percentHeight = 100;
         _loc1_.stroke = this._GWizAbstractTipWindow_SolidColorStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_SolidColorStroke1_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 16777215;
         _loc1_.weight = 2;
         _loc1_.caps = "square";
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "left";
         _loc1_.mxmlContent = [this._GWizAbstractTipWindow_Group1_i(),this._GWizAbstractTipWindow_Spacer1_c(),this._GWizAbstractTipWindow_CheckBox1_i(),this._GWizAbstractTipWindow_HGroup2_c(),this._GWizAbstractTipWindow_Spacer2_c()];
         _loc1_.id = "tipParent";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tipParent = _loc1_;
         BindingManager.executeBindings(this,"tipParent",this.tipParent);
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizAbstractTipWindow_Rect1_c()];
         _loc1_.addEventListener("resize",this.__msgArea_resize);
         _loc1_.id = "msgArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msgArea = _loc1_;
         BindingManager.executeBindings(this,"msgArea",this.msgArea);
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.fill = this._GWizAbstractTipWindow_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         return _loc1_;
      }
      
      public function __msgArea_resize(param1:ResizeEvent) : void
      {
         this.resizeWebView(param1);
      }
      
      private function _GWizAbstractTipWindow_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Stop showing me these tips!";
         _loc1_.selected = false;
         _loc1_.toolTip = "Turn off tips.  You can turn them back on the Setup About tab.";
         _loc1_.setStyle("color",16777215);
         _loc1_.addEventListener("valueCommit",this.__StopTips_valueCommit);
         _loc1_.id = "StopTips";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.StopTips = _loc1_;
         BindingManager.executeBindings(this,"StopTips",this.StopTips);
         return _loc1_;
      }
      
      public function __StopTips_valueCommit(param1:FlexEvent) : void
      {
         this.doStopTips();
      }
      
      private function _GWizAbstractTipWindow_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 15;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizAbstractTipWindow_Button1_i()];
         _loc1_.setStyle("color",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbstractTipWindow_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Optional";
         _loc1_.visible = false;
         _loc1_.addEventListener("click",this.__Optional_click);
         _loc1_.id = "Optional";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Optional = _loc1_;
         BindingManager.executeBindings(this,"Optional",this.Optional);
         return _loc1_;
      }
      
      public function __Optional_click(param1:MouseEvent) : void
      {
         this.doOptional();
      }
      
      private function _GWizAbstractTipWindow_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizAbstractTipWindow_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.doCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get Optional() : Button
      {
         return this._14372992Optional;
      }
      
      public function set Optional(param1:Button) : void
      {
         var _loc2_:Object = this._14372992Optional;
         if(_loc2_ !== param1)
         {
            this._14372992Optional = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Optional",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get StopTips() : CheckBox
      {
         return this._1779458682StopTips;
      }
      
      public function set StopTips(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1779458682StopTips;
         if(_loc2_ !== param1)
         {
            this._1779458682StopTips = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"StopTips",_loc2_,param1));
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
   }
}
