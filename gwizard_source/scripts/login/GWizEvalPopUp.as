package login
{
   import chimp.GWizMailChimp;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColorStroke;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import spark.primitives.Line;
   import utils.GWizUtils;
   
   public class GWizEvalPopUp extends GWizPopUp
   {
      
      public static var trialPopShowing:Boolean = false;
      
      public static var purchaseURL:String = "http://www.cnccookbook.com/GWSignup.html";
      
      public static var registerURL:String = "http://www.cnccookbook.com/GWSignup.html";
      
      public static const IN_APP_REGISTRATION:Boolean = true;
       
      
      public var _GWizEvalPopUp_ClassFactory1:ClassFactory;
      
      public var _GWizEvalPopUp_ClassFactory2:ClassFactory;
      
      private var _1948582142daysLeft:Label;
      
      private var _1343177646msgArea:TextArea;
      
      private var _758945874progressGroup:HGroup;
      
      private var _763044039progressLabel:Label;
      
      private var _1233099618welcome:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var doPurchaseURL:String;
      
      private var regPopup:GWizRegisterPopup;
      
      private var msgPopup:GWizRegConfirmMsg;
      
      private var _embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486:Class;
      
      public function GWizEvalPopUp()
      {
         this.doPurchaseURL = purchaseURL;
         this._embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486 = GWizEvalPopUp__embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486;
         super();
         mx_internal::_document = this;
         this.okLabel = "Purchase";
         this.cancelLabel = "Continue";
         this.width = 550;
         this.height = 500;
         this.title = "Welcome!";
         this.mxmlContent = [this._GWizEvalPopUp_HGroup1_c()];
         this._GWizEvalPopUp_ClassFactory1_i();
         this._GWizEvalPopUp_ClassFactory2_i();
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
      
      public function setInTrial(param1:int, param2:int, param3:Boolean, param4:Boolean, param5:String) : void
      {
         this.welcome.text = "Welcome!";
         var _loc6_:* = (_loc6_ = "") + ("Thanks for trying " + GWizSettings.appLongName + ",\n\n");
         okLabel = "Purchase";
         this.doPurchaseURL = purchaseURL;
         this.daysLeft.text = String(param1);
         if(!param3)
         {
            _loc6_ = (_loc6_ = (_loc6_ = (_loc6_ = (_loc6_ = (_loc6_ = (_loc6_ += "We don\'t show your login, \'" + param5 + "\', as a registered user.\n\n") + "If you\'ve entered the wrong login, press Continue and login again.\n\n") + "If you haven\'t registered, press the Register button below to register now ") + ("or visit \n" + registerURL + "\n\n")) + "Newly registered users, be sure you\'ve clicked the confirmation link on the return email. After opt-in, it can take a little while for the server to activate your account.\n\n") + "Note that each product requires its own registration and activation link to be clicked.\n\n") + "For more assistance, send email to \'sales@cnccookbook.com\'";
            okLabel = "Register";
            this.doPurchaseURL = registerURL;
            this.progressGroup.visible = false;
         }
         else if(param1 >= 0)
         {
            if(!param4)
            {
               _loc6_ = (_loc6_ = (_loc6_ = (_loc6_ = (_loc6_ += "Thanks for trying G-Wizard, \'" + param5 + "\'.  \n\n") + "The bar above tells how many days are left in your trial.  \n\n") + "The \'Purchase\' button will open a browser page that takes you to the CNCCookbook purchase area. \n\n") + "You will need to purchase G-Wizard to continue using it once the trial ends. \n\n") + "You\'ll receive full credit for the remainder of your trial period if you pay early.";
               this.progressGroup.visible = true;
               this.daysLeft.text = String(param1);
               this.progressLabel.text = " days Left in Your Trial";
               this.close();
               return;
            }
            _loc6_ = (_loc6_ = (_loc6_ = (_loc6_ += "\'" + param5 + "\', your subscription will expire soon! \n\n") + "The bar above tells how many days are left.  \n\n") + "The \'Purchase\' button will open a browser page that takes you to the CNCCookbook purchase area. \n\n") + "You will need to purchase an additional G-Wizard subscription to continue using it once your subscription ends.";
            this.progressGroup.visible = true;
            this.daysLeft.text = String(param1);
            this.progressLabel.text = " days Left in Your Subscription";
         }
         else
         {
            if(param4)
            {
               _loc6_ = (_loc6_ = (_loc6_ = (_loc6_ += "\'" + param5 + "\', your subscription has expired.  \n\n") + "You will need to purchase a new G-Wizard subscription to to get the full capabilities from it.  \n\n") + "You may use G-Wizard Lite with a spindle power limit without a new subscription.  \n\n") + "The \'Purchase\' button will open a browser page that takes you to the CNCCookbook purchase area. \n\n";
            }
            else if(0 < param2 && param2 <= 2)
            {
               _loc6_ = (_loc6_ = (_loc6_ += "\'" + param5 + "\', your trial hasn\'t been fully activated yet.  \n\n") + "You get an activation link by return email whenever you register.  Please open that email and click the activation link.  \n\n") + "Once fully activated your 30-day trial can continue.  \n\n";
            }
            else
            {
               _loc6_ = (_loc6_ = (_loc6_ += "\'" + param5 + "\', your trial period has expired.  \n\n") + "You will need to purchase a G-Wizard subscription to continue using it.  \n\n") + "The \'Purchase\' button will open a browser page that takes you to the CNCCookbook purchase area. \n\n";
            }
            this.progressGroup.visible = false;
         }
         _loc6_ += "\n" + GWizCredentials.getConnectStatus();
         this.msgArea.text = _loc6_;
         trialPopShowing = true;
      }
      
      override public function onOk(param1:Event) : void
      {
         if(IN_APP_REGISTRATION && okLabel != "Purchase")
         {
            this.doRegistration();
         }
         else
         {
            GWizUtils.doWebPage(this.doPurchaseURL);
            trialPopShowing = false;
         }
         super.close();
      }
      
      override public function onCancel(param1:Event) : void
      {
         super.close();
         trialPopShowing = false;
      }
      
      private function doRegistration() : void
      {
         this.regPopup = GWizRegisterPopup(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizRegisterPopup,true));
         this.regPopup.regFunc = this.onRegOK;
         this.regPopup.okLabel = this.okLabel;
      }
      
      public function onRegOK(param1:Event) : void
      {
         GWizMailChimp.registerForTrial(this.regPopup.Email.text,this.regPopup.FirstName.text,this.regPopup.LastName.text,GWizCredentials.appTrialSubscList);
         this.msgPopup = GWizRegConfirmMsg(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizRegConfirmMsg,true));
         if(this.msgPopup)
         {
            this.msgPopup.msgArea.text = "You\'re almost done, just one more step:\n\n";
            this.msgPopup.msgArea.text += "You will receive an email from CNCCookbook containing\n";
            this.msgPopup.msgArea.text += "a confirmation link.\n\n";
            this.msgPopup.msgArea.text += "Once you\'ve clicked the link to confirm your working email, \nyour trial will start.\n\n";
            this.msgPopup.msgArea.text += "We\'ll send a new confirm email each time you register.\n";
            this.msgPopup.msgArea.text += "Check your spam folder if you can\'t find the confirm email.\n";
            this.msgPopup.msgArea.text += "\nIf you unsubscribe from our email, the trial ends.\n";
         }
      }
      
      private function _GWizEvalPopUp_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizRegisterPopup;
         _loc1_.properties = {"outerDocument":this};
         this._GWizEvalPopUp_ClassFactory1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizEvalPopUp_ClassFactory1",this._GWizEvalPopUp_ClassFactory1);
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_ClassFactory2_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizRegConfirmMsg;
         _loc1_.properties = {"outerDocument":this};
         this._GWizEvalPopUp_ClassFactory2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizEvalPopUp_ClassFactory2",this._GWizEvalPopUp_ClassFactory2);
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizEvalPopUp_Image1_c(),this._GWizEvalPopUp_Line1_c(),this._GWizEvalPopUp_VGroup1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_LogoVertColorBlkBG_jpg_312989486;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_Line1_c() : Line
      {
         var _loc1_:Line = new Line();
         _loc1_.percentHeight = 100;
         _loc1_.stroke = this._GWizEvalPopUp_SolidColorStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_SolidColorStroke1_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 16777215;
         _loc1_.weight = 2;
         _loc1_.caps = "square";
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "left";
         _loc1_.mxmlContent = [this._GWizEvalPopUp_Label1_i(),this._GWizEvalPopUp_HGroup2_i(),this._GWizEvalPopUp_TextArea1_i()];
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontSize",20);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "welcome";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.welcome = _loc1_;
         BindingManager.executeBindings(this,"welcome",this.welcome);
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_HGroup2_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.mxmlContent = [this._GWizEvalPopUp_Label2_i(),this._GWizEvalPopUp_Label3_i()];
         _loc1_.id = "progressGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.progressGroup = _loc1_;
         BindingManager.executeBindings(this,"progressGroup",this.progressGroup);
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "daysLeft";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.daysLeft = _loc1_;
         BindingManager.executeBindings(this,"daysLeft",this.daysLeft);
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "progressLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.progressLabel = _loc1_;
         BindingManager.executeBindings(this,"progressLabel",this.progressLabel);
         return _loc1_;
      }
      
      private function _GWizEvalPopUp_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.text = "Thank you for trying G-Wizard.";
         _loc1_.editable = false;
         _loc1_.setStyle("lineBreak","toFit");
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("color",0);
         _loc1_.id = "msgArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msgArea = _loc1_;
         BindingManager.executeBindings(this,"msgArea",this.msgArea);
         return _loc1_;
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
      public function get msgArea() : TextArea
      {
         return this._1343177646msgArea;
      }
      
      public function set msgArea(param1:TextArea) : void
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
      public function get progressGroup() : HGroup
      {
         return this._758945874progressGroup;
      }
      
      public function set progressGroup(param1:HGroup) : void
      {
         var _loc2_:Object = this._758945874progressGroup;
         if(_loc2_ !== param1)
         {
            this._758945874progressGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"progressGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get progressLabel() : Label
      {
         return this._763044039progressLabel;
      }
      
      public function set progressLabel(param1:Label) : void
      {
         var _loc2_:Object = this._763044039progressLabel;
         if(_loc2_ !== param1)
         {
            this._763044039progressLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"progressLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get welcome() : Label
      {
         return this._1233099618welcome;
      }
      
      public function set welcome(param1:Label) : void
      {
         var _loc2_:Object = this._1233099618welcome;
         if(_loc2_ !== param1)
         {
            this._1233099618welcome = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"welcome",_loc2_,param1));
            }
         }
      }
   }
}
