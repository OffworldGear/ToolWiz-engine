package login
{
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.components.TextArea;
   
   public class GWizRegConfirmMsg extends GWizPopUp
   {
       
      
      private var _1343177646msgArea:TextArea;
      
      private var _88844982outerDocument:GWizEvalPopUp;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizRegConfirmMsg()
      {
         super();
         mx_internal::_document = this;
         this.title = "Thanks!";
         this.height = 400;
         this.width = 400;
         this.mxmlContent = [this._GWizRegConfirmMsg_Label1_c(),this._GWizRegConfirmMsg_Spacer1_c(),this._GWizRegConfirmMsg_TextArea1_i(),this._GWizRegConfirmMsg_Spacer2_c()];
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
         GWizEvalPopUp.trialPopShowing = false;
         super.close();
      }
      
      override public function onCancel(param1:Event) : void
      {
         GWizEvalPopUp.trialPopShowing = false;
         super.close();
      }
      
      private function _GWizRegConfirmMsg_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Thanks for registering!";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegConfirmMsg_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRegConfirmMsg_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.editable = false;
         _loc1_.id = "msgArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msgArea = _loc1_;
         BindingManager.executeBindings(this,"msgArea",this.msgArea);
         return _loc1_;
      }
      
      private function _GWizRegConfirmMsg_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
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
