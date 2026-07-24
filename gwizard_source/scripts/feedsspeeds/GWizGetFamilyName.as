package feedsspeeds
{
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.components.TextInput;
   
   public class GWizGetFamilyName extends GWizPopUp
   {
       
      
      private var _88844982outerDocument:GWizMfgFamilyPopup;
      
      private var _1350627684theName:TextInput;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var okFunc:Function = null;
      
      public function GWizGetFamilyName()
      {
         super();
         mx_internal::_document = this;
         this.title = "Family Name";
         this.width = 600;
         this.mxmlContent = [this._GWizGetFamilyName_Label1_c(),this._GWizGetFamilyName_TextInput1_i()];
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
         if(this.okFunc != null)
         {
            this.okFunc(this.theName.text);
         }
         super.close();
      }
      
      private function _GWizGetFamilyName_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Family Name:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGetFamilyName_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.prompt = "Family Name";
         _loc1_.percentWidth = 100;
         _loc1_.id = "theName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theName = _loc1_;
         BindingManager.executeBindings(this,"theName",this.theName);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizMfgFamilyPopup
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizMfgFamilyPopup) : void
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
      
      [Bindable(event="propertyChange")]
      public function get theName() : TextInput
      {
         return this._1350627684theName;
      }
      
      public function set theName(param1:TextInput) : void
      {
         var _loc2_:Object = this._1350627684theName;
         if(_loc2_ !== param1)
         {
            this._1350627684theName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theName",_loc2_,param1));
            }
         }
      }
   }
}
