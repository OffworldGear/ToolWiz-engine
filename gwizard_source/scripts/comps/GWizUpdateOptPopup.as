package comps
{
   import configinfo.GWizSettings;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   
   public class GWizUpdateOptPopup extends GWizPopUp
   {
       
      
      private var _1571084386Feathered:RadioButton;
      
      private var _1166616687Immediate:RadioButton;
      
      private var _189781824LineLabel:Label;
      
      private var _1753039007Urgent:RadioButton;
      
      private var _88844982outerDocument:GWizAbout;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizUpdateOptPopup()
      {
         super();
         mx_internal::_document = this;
         this.title = "Update Options";
         this.okLabel = "Save";
         this.mxmlContent = [this._GWizUpdateOptPopup_Label1_i(),this._GWizUpdateOptPopup_HGroup1_c(),this._GWizUpdateOptPopup_Spacer1_c()];
         this.addEventListener("creationComplete",this.___GWizUpdateOptPopup_GWizPopUp1_creationComplete);
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
            this.color = 16777215;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function initOptions() : void
      {
         switch(GWizSettings.updatePref)
         {
            case GWizSettings.UPDATE_NOW:
               this.Immediate.selected = true;
               break;
            case GWizSettings.UPDATE_WEEK:
               this.Feathered.selected = true;
               break;
            case GWizSettings.UPDATE_URGENT:
               this.Urgent.selected = true;
         }
      }
      
      override public function onOk(param1:Event) : void
      {
         if(this.Immediate.selected)
         {
            GWizSettings.updatePref = GWizSettings.UPDATE_NOW;
         }
         else if(this.Feathered.selected)
         {
            GWizSettings.updatePref = GWizSettings.UPDATE_WEEK;
         }
         else
         {
            GWizSettings.updatePref = GWizSettings.UPDATE_URGENT;
         }
         super.close();
      }
      
      override public function onCancel(param1:Event) : void
      {
         super.close();
      }
      
      private function _GWizUpdateOptPopup_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "G-Wizard Update Notification Options";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "LineLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LineLabel = _loc1_;
         BindingManager.executeBindings(this,"LineLabel",this.LineLabel);
         return _loc1_;
      }
      
      private function _GWizUpdateOptPopup_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizUpdateOptPopup_RadioButton1_i(),this._GWizUpdateOptPopup_RadioButton2_i(),this._GWizUpdateOptPopup_RadioButton3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizUpdateOptPopup_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Display update as soon as available";
         _loc1_.selected = false;
         _loc1_.groupName = "UpdateGrp";
         _loc1_.id = "Immediate";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Immediate = _loc1_;
         BindingManager.executeBindings(this,"Immediate",this.Immediate);
         return _loc1_;
      }
      
      private function _GWizUpdateOptPopup_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Display update in 1-7 days";
         _loc1_.selected = true;
         _loc1_.groupName = "UpdateGrp";
         _loc1_.id = "Feathered";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Feathered = _loc1_;
         BindingManager.executeBindings(this,"Feathered",this.Feathered);
         return _loc1_;
      }
      
      private function _GWizUpdateOptPopup_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Only display critical update notices";
         _loc1_.selected = false;
         _loc1_.groupName = "UpdateGrp";
         _loc1_.id = "Urgent";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Urgent = _loc1_;
         BindingManager.executeBindings(this,"Urgent",this.Urgent);
         return _loc1_;
      }
      
      private function _GWizUpdateOptPopup_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizUpdateOptPopup_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.initOptions();
      }
      
      [Bindable(event="propertyChange")]
      public function get Feathered() : RadioButton
      {
         return this._1571084386Feathered;
      }
      
      public function set Feathered(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1571084386Feathered;
         if(_loc2_ !== param1)
         {
            this._1571084386Feathered = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Feathered",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Immediate() : RadioButton
      {
         return this._1166616687Immediate;
      }
      
      public function set Immediate(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1166616687Immediate;
         if(_loc2_ !== param1)
         {
            this._1166616687Immediate = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Immediate",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LineLabel() : Label
      {
         return this._189781824LineLabel;
      }
      
      public function set LineLabel(param1:Label) : void
      {
         var _loc2_:Object = this._189781824LineLabel;
         if(_loc2_ !== param1)
         {
            this._189781824LineLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LineLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Urgent() : RadioButton
      {
         return this._1753039007Urgent;
      }
      
      public function set Urgent(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1753039007Urgent;
         if(_loc2_ !== param1)
         {
            this._1753039007Urgent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Urgent",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizAbout
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizAbout) : void
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
