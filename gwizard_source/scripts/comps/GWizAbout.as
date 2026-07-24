package comps
{
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.BitmapFilterQuality;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.utils.getDefinitionByName;
   import flashx.textLayout.elements.LinkElement;
   import flashx.textLayout.elements.ParagraphElement;
   import flashx.textLayout.elements.TextFlow;
   import flashx.textLayout.formats.TextLayoutFormat;
   import login.GWizProvisions;
   import loginp.GWizSplash;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.GradientEntry;
   import mx.graphics.LinearGradient;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.RadioButtonGroup;
   import spark.components.RichEditableText;
   import spark.components.VGroup;
   import spark.effects.AnimateFilter;
   import spark.effects.animation.MotionPath;
   import spark.effects.animation.SimpleMotionPath;
   import spark.filters.GlowFilter;
   import spark.primitives.Rect;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class GWizAbout extends Group implements IBindingClient
   {
      
      private static var _2087429798appMessage:String = "";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _214072634AppMessage:Label;
      
      private var _1052621525GWTCLabel:Label;
      
      private var _2606936Tips:CheckBox;
      
      private var _54746940UpdateGrp:RadioButtonGroup;
      
      private var _2016261304Version:Label;
      
      public var _GWizAbout_Button1:Button;
      
      public var _GWizAbout_Button2:Button;
      
      public var _GWizAbout_ClassFactory1:ClassFactory;
      
      public var _GWizAbout_GradientEntry1:GradientEntry;
      
      public var _GWizAbout_GradientEntry4:GradientEntry;
      
      public var _GWizAbout_Label11:Label;
      
      public var _GWizAbout_Label7:Label;
      
      public var _GWizAbout_Label9:Label;
      
      private var _1598455225animateFilter:AnimateFilter;
      
      private var _1948582142daysLeft:Label;
      
      private var _158731345greenNeonFilter:GlowFilter;
      
      private var _1995610739lastLogin:Label;
      
      private var _342488600logoImg:Image;
      
      private var _887365688sysMem:Label;
      
      private var _974302729whiteNeonFilter:GlowFilter;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1580939664logoImage:Class;
      
      private var oneShot:Boolean = false;
      
      private var inRecursion:Boolean = false;
      
      private var _1079312431imgGWizLogo:Class;
      
      private var updateOptions:GWizUpdateOptPopup;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizAbout()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1079312431imgGWizLogo = GWizAbout_imgGWizLogo;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizAbout_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizAboutWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizAbout[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizAbout_Rect1_c(),this._GWizAbout_VGroup1_c()];
         this._GWizAbout_RadioButtonGroup1_i();
         this._GWizAbout_ClassFactory1_i();
         this._GWizAbout_AnimateFilter1_i();
         this._GWizAbout_GlowFilter1_i();
         this._GWizAbout_GlowFilter2_i();
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizAbout._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get appMessage() : String
      {
         return GWizAbout._2087429798appMessage;
      }
      
      public static function set appMessage(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbout._2087429798appMessage;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbout,"appMessage",_loc2_,param1));
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
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      public function onShow() : void
      {
         var _loc1_:Date = new Date(GWizSettings.prefs.authenticateDate);
         this.logoImage = GWizSplash.masterLogo;
         this.lastLogin.text = "Last Internet connect: " + _loc1_;
         this.setDaysLeft();
         this.showSysMem();
         this.Tips.selected = GWizSettings.prefs.showTips;
         this.Version.text = "Version: " + GWizSettings.appVersion;
      }
      
      private function setDaysLeft() : void
      {
         var _loc1_:int = GWizProvisions.provisionDaysLeft(GWizProvisions.appSubscProvision());
         var _loc2_:String = GWizProvisions.provisionValue("GWCL");
         if(_loc1_ > 0)
         {
            if(_loc1_ > 6 * 365)
            {
               this.daysLeft.text = "Gold Lifetime Member: Thank you for your support!";
            }
            else
            {
               this.daysLeft.text = GWizProvisions.provisionDaysLeft(GWizProvisions.appSubscProvision()).toFixed() + " days left in your subscription.";
            }
         }
         else if(GWizProvisions.provisionDaysLeft(GWizSettings.loginBar.appProvParm) > 0 && _loc2_.length <= 0)
         {
            this.daysLeft.text = GWizProvisions.provisionDaysLeft(GWizSettings.loginBar.appProvParm).toFixed() + " days left in your trial.";
         }
         var _loc3_:String = GWizProvisions.provisionValue("GWTC");
         if(_loc3_ == "1000")
         {
            this.GWTCLabel.text = "GW Thread Calc Lifetime";
         }
         else
         {
            this.GWTCLabel.text = "";
         }
      }
      
      public function showSysMem() : void
      {
         var _loc1_:int = int(System.totalMemory / 1024);
         this.sysMem.text = "Memory used: " + _loc1_.toString() + " KB";
      }
      
      private function doUpdateOptions() : void
      {
         this.updateOptions = GWizUpdateOptPopup(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizUpdateOptPopup,true));
      }
      
      private function doTips() : void
      {
         GWizSettings.prefs.showTips = this.Tips.selected;
      }
      
      private function _GWizAbout_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"UpdateGrp");
         this.UpdateGrp = _loc1_;
         BindingManager.executeBindings(this,"UpdateGrp",this.UpdateGrp);
         return _loc1_;
      }
      
      private function _GWizAbout_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizUpdateOptPopup;
         _loc1_.properties = {"outerDocument":this};
         this._GWizAbout_ClassFactory1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAbout_ClassFactory1",this._GWizAbout_ClassFactory1);
         return _loc1_;
      }
      
      private function _GWizAbout_AnimateFilter1_i() : AnimateFilter
      {
         var _loc1_:AnimateFilter = new AnimateFilter();
         _loc1_.repeatCount = 0;
         _loc1_.duration = 1800;
         _loc1_.repeatBehavior = "reverse";
         _loc1_.motionPaths = new <MotionPath>[this._GWizAbout_SimpleMotionPath1_c(),this._GWizAbout_SimpleMotionPath2_c()];
         this.animateFilter = _loc1_;
         BindingManager.executeBindings(this,"animateFilter",this.animateFilter);
         return _loc1_;
      }
      
      private function _GWizAbout_SimpleMotionPath1_c() : SimpleMotionPath
      {
         var _loc1_:SimpleMotionPath = new SimpleMotionPath();
         _loc1_.property = "blurX";
         _loc1_.valueFrom = 4;
         _loc1_.valueTo = 16;
         _loc1_.valueBy = 2;
         return _loc1_;
      }
      
      private function _GWizAbout_SimpleMotionPath2_c() : SimpleMotionPath
      {
         var _loc1_:SimpleMotionPath = new SimpleMotionPath();
         _loc1_.property = "blurY";
         _loc1_.valueFrom = 4;
         _loc1_.valueTo = 16;
         _loc1_.valueBy = 2;
         return _loc1_;
      }
      
      private function _GWizAbout_GlowFilter1_i() : GlowFilter
      {
         var _loc1_:GlowFilter = new GlowFilter();
         _loc1_.color = 12054405;
         _loc1_.alpha = 1;
         _loc1_.knockout = false;
         _loc1_.blurX = 4;
         _loc1_.blurY = 4;
         this.greenNeonFilter = _loc1_;
         BindingManager.executeBindings(this,"greenNeonFilter",this.greenNeonFilter);
         return _loc1_;
      }
      
      private function _GWizAbout_GlowFilter2_i() : GlowFilter
      {
         var _loc1_:GlowFilter = new GlowFilter();
         _loc1_.color = 16777215;
         _loc1_.alpha = 1;
         _loc1_.knockout = false;
         _loc1_.blurX = 8;
         _loc1_.blurY = 8;
         this.whiteNeonFilter = _loc1_;
         BindingManager.executeBindings(this,"whiteNeonFilter",this.whiteNeonFilter);
         return _loc1_;
      }
      
      private function _GWizAbout_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.fill = this._GWizAbout_LinearGradient1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizAbout_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._GWizAbout_GradientEntry1_i(),this._GWizAbout_GradientEntry2_c(),this._GWizAbout_GradientEntry3_c(),this._GWizAbout_GradientEntry4_i()];
         return _loc1_;
      }
      
      private function _GWizAbout_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.ratio = 0;
         this._GWizAbout_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAbout_GradientEntry1",this._GWizAbout_GradientEntry1);
         return _loc1_;
      }
      
      private function _GWizAbout_GradientEntry2_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.1;
         return _loc1_;
      }
      
      private function _GWizAbout_GradientEntry3_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.9;
         return _loc1_;
      }
      
      private function _GWizAbout_GradientEntry4_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.ratio = 1;
         this._GWizAbout_GradientEntry4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAbout_GradientEntry4",this._GWizAbout_GradientEntry4);
         return _loc1_;
      }
      
      private function _GWizAbout_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.paddingTop = 10;
         _loc1_.mxmlContent = [this._GWizAbout_Group2_c(),this._GWizAbout_Spacer6_c(),this._GWizAbout_HGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_Group2_c() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.mxmlContent = [this._GWizAbout_VGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "top";
         _loc1_.width = 600;
         _loc1_.paddingBottom = 20;
         _loc1_.paddingLeft = 20;
         _loc1_.paddingRight = 20;
         _loc1_.paddingTop = 20;
         _loc1_.mxmlContent = [this._GWizAbout_Image1_i(),this._GWizAbout_Label1_i(),this._GWizAbout_Spacer1_c(),this._GWizAbout_Label2_i(),this._GWizAbout_Label3_i(),this._GWizAbout_Label4_i(),this._GWizAbout_Label5_i(),this._GWizAbout_Spacer2_c(),this._GWizAbout_HGroup1_c(),this._GWizAbout_Label10_i(),this._GWizAbout_Spacer3_c(),this._GWizAbout_Label11_i(),this._GWizAbout_Label12_c(),this._GWizAbout_Spacer4_c(),this._GWizAbout_RichEditableText1_c(),this._GWizAbout_Spacer5_c()];
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.percentWidth = 100;
         _loc1_.fillMode = "scale";
         _loc1_.addEventListener("creationComplete",this.__logoImg_creationComplete);
         _loc1_.addEventListener("click",this.__logoImg_click);
         _loc1_.id = "logoImg";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.logoImg = _loc1_;
         BindingManager.executeBindings(this,"logoImg",this.logoImg);
         return _loc1_;
      }
      
      public function __logoImg_creationComplete(param1:FlexEvent) : void
      {
         this.animateFilter.end();
         this.animateFilter.play();
      }
      
      public function __logoImg_click(param1:MouseEvent) : void
      {
         this.animateFilter.end();
      }
      
      private function _GWizAbout_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Version: ?";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("click",this.__Version_click);
         _loc1_.id = "Version";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Version = _loc1_;
         BindingManager.executeBindings(this,"Version",this.Version);
         return _loc1_;
      }
      
      public function __Version_click(param1:MouseEvent) : void
      {
         GWizSettings.loginBar.popupVerDetails();
      }
      
      private function _GWizAbout_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "daysLeft";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.daysLeft = _loc1_;
         BindingManager.executeBindings(this,"daysLeft",this.daysLeft);
         return _loc1_;
      }
      
      private function _GWizAbout_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "GWTCLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GWTCLabel = _loc1_;
         BindingManager.executeBindings(this,"GWTCLabel",this.GWTCLabel);
         return _loc1_;
      }
      
      private function _GWizAbout_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "lastLogin";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.lastLogin = _loc1_;
         BindingManager.executeBindings(this,"lastLogin",this.lastLogin);
         return _loc1_;
      }
      
      private function _GWizAbout_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "AppMessage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AppMessage = _loc1_;
         BindingManager.executeBindings(this,"AppMessage",this.AppMessage);
         return _loc1_;
      }
      
      private function _GWizAbout_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizAbout_Label6_c(),this._GWizAbout_Label7_i(),this._GWizAbout_Label8_c(),this._GWizAbout_Label9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Screen Resolution: ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizAbout_Label7";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizAbout_Label7 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAbout_Label7",this._GWizAbout_Label7);
         return _loc1_;
      }
      
      private function _GWizAbout_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "x";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizAbout_Label9";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizAbout_Label9 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAbout_Label9",this._GWizAbout_Label9);
         return _loc1_;
      }
      
      private function _GWizAbout_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "sysMem";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sysMem = _loc1_;
         BindingManager.executeBindings(this,"sysMem",this.sysMem);
         return _loc1_;
      }
      
      private function _GWizAbout_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizAbout_Label11";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizAbout_Label11 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAbout_Label11",this._GWizAbout_Label11);
         return _loc1_;
      }
      
      private function _GWizAbout_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Copyright 2021 by CNCCookbook, Inc.";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_RichEditableText1_c() : RichEditableText
      {
         var _loc1_:RichEditableText = new RichEditableText();
         _loc1_.editable = false;
         _loc1_.focusEnabled = false;
         _loc1_.textFlow = this._GWizAbout_TextFlow1_c();
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_TextFlow1_c() : TextFlow
      {
         var _loc1_:TextFlow = new TextFlow();
         _loc1_.mxmlChildren = ["\n\t\t\t\t\t\t",this._GWizAbout_ParagraphElement1_c(),"\n\t\t\t\t\t"];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizAbout_ParagraphElement1_c() : ParagraphElement
      {
         var _loc1_:ParagraphElement = new ParagraphElement();
         _loc1_.linkHoverFormat = this._GWizAbout_TextLayoutFormat1_c();
         _loc1_.linkNormalFormat = this._GWizAbout_TextLayoutFormat2_c();
         _loc1_.mxmlChildren = ["\n\t\t\t\t\t\t\tQuestion? Email us at ",this._GWizAbout_LinkElement1_c()];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizAbout_TextLayoutFormat1_c() : TextLayoutFormat
      {
         var _loc1_:TextLayoutFormat = new TextLayoutFormat();
         _loc1_.color = 16616804;
         _loc1_.textDecoration = "underline";
         return _loc1_;
      }
      
      private function _GWizAbout_TextLayoutFormat2_c() : TextLayoutFormat
      {
         var _loc1_:TextLayoutFormat = new TextLayoutFormat();
         _loc1_.color = 16616804;
         return _loc1_;
      }
      
      private function _GWizAbout_LinkElement1_c() : LinkElement
      {
         var _loc1_:LinkElement = new LinkElement();
         _loc1_.href = "mailto:sales@cnccookbook.com";
         _loc1_.mxmlChildren = ["sales@cnccookbook.com"];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizAbout_Spacer5_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_Spacer6_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizAbout_Button1_i(),this._GWizAbout_Button2_i(),this._GWizAbout_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAbout_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Update Options";
         _loc1_.addEventListener("click",this.___GWizAbout_Button1_click);
         _loc1_.id = "_GWizAbout_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizAbout_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAbout_Button1",this._GWizAbout_Button1);
         return _loc1_;
      }
      
      public function ___GWizAbout_Button1_click(param1:MouseEvent) : void
      {
         this.doUpdateOptions();
      }
      
      private function _GWizAbout_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Log";
         _loc1_.addEventListener("click",this.___GWizAbout_Button2_click);
         _loc1_.id = "_GWizAbout_Button2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizAbout_Button2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAbout_Button2",this._GWizAbout_Button2);
         return _loc1_;
      }
      
      public function ___GWizAbout_Button2_click(param1:MouseEvent) : void
      {
         GWizDebugLogReader.newDebugLogReader();
      }
      
      private function _GWizAbout_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Show tips at startup";
         _loc1_.setStyle("color",16777215);
         _loc1_.addEventListener("valueCommit",this.__Tips_valueCommit);
         _loc1_.id = "Tips";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Tips = _loc1_;
         BindingManager.executeBindings(this,"Tips",this.Tips);
         return _loc1_;
      }
      
      public function __Tips_valueCommit(param1:FlexEvent) : void
      {
         this.doTips();
      }
      
      private function _GWizAbout_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():int
         {
            return BitmapFilterQuality.HIGH;
         },null,"greenNeonFilter.quality");
         result[1] = new Binding(this,function():int
         {
            return BitmapFilterQuality.HIGH;
         },null,"whiteNeonFilter.quality");
         result[2] = new Binding(this,null,null,"animateFilter.target","logoImg");
         result[3] = new Binding(this,null,null,"animateFilter.bitmapFilter","greenNeonFilter");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },null,"_GWizAbout_GradientEntry1.color");
         result[5] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },null,"_GWizAbout_GradientEntry4.color");
         result[6] = new Binding(this,null,null,"logoImg.source","logoImage");
         result[7] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"daysLeft.visible");
         result[8] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"GWTCLabel.visible");
         result[9] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"lastLogin.visible");
         result[10] = new Binding(this,function():String
         {
            var _loc1_:* = appMessage;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"AppMessage.text");
         result[11] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"AppMessage.visible");
         result[12] = new Binding(this,function():String
         {
            var _loc1_:* = Capabilities.screenResolutionX;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizAbout_Label7.text");
         result[13] = new Binding(this,function():String
         {
            var _loc1_:* = Capabilities.screenResolutionY;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizAbout_Label9.text");
         result[14] = new Binding(this,function():String
         {
            var _loc1_:* = "Made by " + GWizAbstractPrefs.madeByStr + " in America";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizAbout_Label11.text");
         result[15] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"_GWizAbout_Button1.visible");
         result[16] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"_GWizAbout_Button2.visible");
         result[17] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"Tips.visible");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get AppMessage() : Label
      {
         return this._214072634AppMessage;
      }
      
      public function set AppMessage(param1:Label) : void
      {
         var _loc2_:Object = this._214072634AppMessage;
         if(_loc2_ !== param1)
         {
            this._214072634AppMessage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AppMessage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GWTCLabel() : Label
      {
         return this._1052621525GWTCLabel;
      }
      
      public function set GWTCLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1052621525GWTCLabel;
         if(_loc2_ !== param1)
         {
            this._1052621525GWTCLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GWTCLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Tips() : CheckBox
      {
         return this._2606936Tips;
      }
      
      public function set Tips(param1:CheckBox) : void
      {
         var _loc2_:Object = this._2606936Tips;
         if(_loc2_ !== param1)
         {
            this._2606936Tips = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Tips",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get UpdateGrp() : RadioButtonGroup
      {
         return this._54746940UpdateGrp;
      }
      
      public function set UpdateGrp(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._54746940UpdateGrp;
         if(_loc2_ !== param1)
         {
            this._54746940UpdateGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"UpdateGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Version() : Label
      {
         return this._2016261304Version;
      }
      
      public function set Version(param1:Label) : void
      {
         var _loc2_:Object = this._2016261304Version;
         if(_loc2_ !== param1)
         {
            this._2016261304Version = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Version",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get animateFilter() : AnimateFilter
      {
         return this._1598455225animateFilter;
      }
      
      public function set animateFilter(param1:AnimateFilter) : void
      {
         var _loc2_:Object = this._1598455225animateFilter;
         if(_loc2_ !== param1)
         {
            this._1598455225animateFilter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"animateFilter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get daysLeft() : Label
      {
         return this._1948582142daysLeft;
      }
      
      public function set daysLeft(param1:Label) : void
      {
         var _loc2_:Object = this._1948582142daysLeft;
         if(_loc2_ !== param1)
         {
            this._1948582142daysLeft = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"daysLeft",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get greenNeonFilter() : GlowFilter
      {
         return this._158731345greenNeonFilter;
      }
      
      public function set greenNeonFilter(param1:GlowFilter) : void
      {
         var _loc2_:Object = this._158731345greenNeonFilter;
         if(_loc2_ !== param1)
         {
            this._158731345greenNeonFilter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"greenNeonFilter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get lastLogin() : Label
      {
         return this._1995610739lastLogin;
      }
      
      public function set lastLogin(param1:Label) : void
      {
         var _loc2_:Object = this._1995610739lastLogin;
         if(_loc2_ !== param1)
         {
            this._1995610739lastLogin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"lastLogin",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get logoImg() : Image
      {
         return this._342488600logoImg;
      }
      
      public function set logoImg(param1:Image) : void
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
      public function get sysMem() : Label
      {
         return this._887365688sysMem;
      }
      
      public function set sysMem(param1:Label) : void
      {
         var _loc2_:Object = this._887365688sysMem;
         if(_loc2_ !== param1)
         {
            this._887365688sysMem = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sysMem",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get whiteNeonFilter() : GlowFilter
      {
         return this._974302729whiteNeonFilter;
      }
      
      public function set whiteNeonFilter(param1:GlowFilter) : void
      {
         var _loc2_:Object = this._974302729whiteNeonFilter;
         if(_loc2_ !== param1)
         {
            this._974302729whiteNeonFilter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"whiteNeonFilter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get logoImage() : Class
      {
         return this._1580939664logoImage;
      }
      
      public function set logoImage(param1:Class) : void
      {
         var _loc2_:Object = this._1580939664logoImage;
         if(_loc2_ !== param1)
         {
            this._1580939664logoImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"logoImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get imgGWizLogo() : Class
      {
         return this._1079312431imgGWizLogo;
      }
      
      public function set imgGWizLogo(param1:Class) : void
      {
         var _loc2_:Object = this._1079312431imgGWizLogo;
         if(_loc2_ !== param1)
         {
            this._1079312431imgGWizLogo = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"imgGWizLogo",_loc2_,param1));
            }
         }
      }
   }
}
