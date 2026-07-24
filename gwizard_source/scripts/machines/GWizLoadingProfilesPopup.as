package machines
{
   import comps.GWizPopUp;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.components.TextArea;
   
   public class GWizLoadingProfilesPopup extends GWizPopUp
   {
       
      
      private var _189781824LineLabel:Label;
      
      private var _3361042msgs:TextArea;
      
      private var _88844982outerDocument:GWizMachProfile;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizLoadingProfilesPopup()
      {
         super();
         mx_internal::_document = this;
         this.title = "Loading...";
         this.width = 300;
         this.cancelLabel = "";
         this.mxmlContent = [this._GWizLoadingProfilesPopup_Label1_i(),this._GWizLoadingProfilesPopup_TextArea1_i(),this._GWizLoadingProfilesPopup_Spacer1_c()];
         this.addEventListener("creationComplete",this.___GWizLoadingProfilesPopup_GWizPopUp1_creationComplete);
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
         this.okEnabled = false;
         this.showCloseButton = false;
      }
      
      public function enableOK() : void
      {
         this.okEnabled = true;
      }
      
      override public function close() : void
      {
         GWizMachProfile.loadMsg = null;
         GWizMachProfile.downloading = false;
         super.close();
      }
      
      private function _GWizLoadingProfilesPopup_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Downloading latest controller profiles...";
         _loc1_.styleName = "fontSizeDelta";
         _loc1_.id = "LineLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LineLabel = _loc1_;
         BindingManager.executeBindings(this,"LineLabel",this.LineLabel);
         return _loc1_;
      }
      
      private function _GWizLoadingProfilesPopup_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.height = 400;
         _loc1_.id = "msgs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msgs = _loc1_;
         BindingManager.executeBindings(this,"msgs",this.msgs);
         return _loc1_;
      }
      
      private function _GWizLoadingProfilesPopup_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizLoadingProfilesPopup_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
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
      public function get msgs() : TextArea
      {
         return this._3361042msgs;
      }
      
      public function set msgs(param1:TextArea) : void
      {
         var _loc2_:Object = this._3361042msgs;
         if(_loc2_ !== param1)
         {
            this._3361042msgs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"msgs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizMachProfile
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizMachProfile) : void
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
