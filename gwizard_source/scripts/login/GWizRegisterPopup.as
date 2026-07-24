package login
{
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.TextInput;
   
   public class GWizRegisterPopup extends GWizPopUp
   {
       
      
      private var _67066748Email:TextInput;
      
      private var _2136803643FirstName:TextInput;
      
      private var _1394955679LastName:TextInput;
      
      private var _88844982outerDocument:GWizEvalPopUp;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var regFunc:Function = null;
      
      public function GWizRegisterPopup()
      {
         super();
         mx_internal::_document = this;
         this.title = "Trial Registration";
         this.width = 400;
         this.okLabel = "Save";
         this.mxmlContent = [this._GWizRegisterPopup_Label1_c(),this._GWizRegisterPopup_HGroup1_c(),this._GWizRegisterPopup_HGroup2_c(),this._GWizRegisterPopup_HGroup3_c(),this._GWizRegisterPopup_HGroup4_c()];
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
      
      override public function onOk(param1:Event) : void
      {
         super.close();
         if(this.regFunc != null)
         {
            this.regFunc(param1);
         }
      }
      
      override public function onCancel(param1:Event) : void
      {
         GWizEvalPopUp.trialPopShowing = false;
         super.close();
      }
      
      private function _GWizRegisterPopup_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Please enter your registration info:";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.mxmlContent = [this._GWizRegisterPopup_Label2_c(),this._GWizRegisterPopup_Spacer1_c(),this._GWizRegisterPopup_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Email";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.width = 200;
         _loc1_.setStyle("color",0);
         _loc1_.id = "Email";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Email = _loc1_;
         BindingManager.executeBindings(this,"Email",this.Email);
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.mxmlContent = [this._GWizRegisterPopup_Label3_c(),this._GWizRegisterPopup_Spacer2_c(),this._GWizRegisterPopup_TextInput2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "First Name";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.width = 200;
         _loc1_.setStyle("color",0);
         _loc1_.id = "FirstName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FirstName = _loc1_;
         BindingManager.executeBindings(this,"FirstName",this.FirstName);
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.mxmlContent = [this._GWizRegisterPopup_Label4_c(),this._GWizRegisterPopup_Spacer3_c(),this._GWizRegisterPopup_TextInput3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Last Name";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.width = 200;
         _loc1_.setStyle("color",0);
         _loc1_.id = "LastName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LastName = _loc1_;
         BindingManager.executeBindings(this,"LastName",this.LastName);
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.mxmlContent = [this._GWizRegisterPopup_Label5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegisterPopup_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "100% Privacy: We will never Spam you!";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontStyle","italic");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
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
      public function get FirstName() : TextInput
      {
         return this._2136803643FirstName;
      }
      
      public function set FirstName(param1:TextInput) : void
      {
         var _loc2_:Object = this._2136803643FirstName;
         if(_loc2_ !== param1)
         {
            this._2136803643FirstName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FirstName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LastName() : TextInput
      {
         return this._1394955679LastName;
      }
      
      public function set LastName(param1:TextInput) : void
      {
         var _loc2_:Object = this._1394955679LastName;
         if(_loc2_ !== param1)
         {
            this._1394955679LastName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LastName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizEvalPopUp
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizEvalPopUp) : void
      {
         var _loc2_:Object = this._88844982outerDocument;
         if(_loc2_ !== param1)
         {
            this._88844982outerDocument = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outerDocument",_loc2_,param1));
            }
         }
      }
   }
}
