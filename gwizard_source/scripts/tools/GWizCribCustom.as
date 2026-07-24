package tools
{
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.TextInput;
   
   public class GWizCribCustom extends GWizPopUp
   {
       
      
      private var _533223842field1Name:TextInput;
      
      private var _534147363field2Name:TextInput;
      
      private var _535070884field3Name:TextInput;
      
      private var _535994405field4Name:TextInput;
      
      private var _88844982outerDocument:GWizToolCrib;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var toolCrib:GWizToolCrib;
      
      public function GWizCribCustom()
      {
         super();
         mx_internal::_document = this;
         this.title = "Customize tool cribs";
         this.okLabel = "Save";
         this.mxmlContent = [this._GWizCribCustom_Label1_c(),this._GWizCribCustom_HGroup1_c(),this._GWizCribCustom_HGroup2_c(),this._GWizCribCustom_HGroup3_c(),this._GWizCribCustom_HGroup4_c()];
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
         this.toolCrib.onCustomOK(param1);
         super.close();
      }
      
      private function _GWizCribCustom_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Custom Fields";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribCustom_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribCustom_Label2_c(),this._GWizCribCustom_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribCustom_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Field 1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribCustom_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "field1Name";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.field1Name = _loc1_;
         BindingManager.executeBindings(this,"field1Name",this.field1Name);
         return _loc1_;
      }
      
      private function _GWizCribCustom_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribCustom_Label3_c(),this._GWizCribCustom_TextInput2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribCustom_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Field 2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribCustom_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "field2Name";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.field2Name = _loc1_;
         BindingManager.executeBindings(this,"field2Name",this.field2Name);
         return _loc1_;
      }
      
      private function _GWizCribCustom_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribCustom_Label4_c(),this._GWizCribCustom_TextInput3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribCustom_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Field 3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribCustom_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "field3Name";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.field3Name = _loc1_;
         BindingManager.executeBindings(this,"field3Name",this.field3Name);
         return _loc1_;
      }
      
      private function _GWizCribCustom_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribCustom_Label5_c(),this._GWizCribCustom_TextInput4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribCustom_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Field 4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribCustom_TextInput4_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "field4Name";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.field4Name = _loc1_;
         BindingManager.executeBindings(this,"field4Name",this.field4Name);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get field1Name() : TextInput
      {
         return this._533223842field1Name;
      }
      
      public function set field1Name(param1:TextInput) : void
      {
         var _loc2_:Object = this._533223842field1Name;
         if(_loc2_ !== param1)
         {
            this._533223842field1Name = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"field1Name",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get field2Name() : TextInput
      {
         return this._534147363field2Name;
      }
      
      public function set field2Name(param1:TextInput) : void
      {
         var _loc2_:Object = this._534147363field2Name;
         if(_loc2_ !== param1)
         {
            this._534147363field2Name = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"field2Name",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get field3Name() : TextInput
      {
         return this._535070884field3Name;
      }
      
      public function set field3Name(param1:TextInput) : void
      {
         var _loc2_:Object = this._535070884field3Name;
         if(_loc2_ !== param1)
         {
            this._535070884field3Name = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"field3Name",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get field4Name() : TextInput
      {
         return this._535994405field4Name;
      }
      
      public function set field4Name(param1:TextInput) : void
      {
         var _loc2_:Object = this._535994405field4Name;
         if(_loc2_ !== param1)
         {
            this._535994405field4Name = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"field4Name",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizToolCrib
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizToolCrib) : void
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
