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
   
   public class GWizCribRename extends GWizPopUp
   {
       
      
      private var _1845020747newName:TextInput;
      
      private var _88844982outerDocument:GWizToolCrib;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var renameFunc:Function = null;
      
      public function GWizCribRename()
      {
         super();
         mx_internal::_document = this;
         this.title = "Rename crib";
         this.okLabel = "Rename Crib";
         this.width = 400;
         this.mxmlContent = [this._GWizCribRename_HGroup1_c()];
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
         var _loc2_:String = this.newName.text;
         if(this.renameFunc != null)
         {
            this.renameFunc(_loc2_);
         }
         super.close();
      }
      
      private function _GWizCribRename_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizCribRename_Label1_c(),this._GWizCribRename_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribRename_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "New Name";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribRename_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "newName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.newName = _loc1_;
         BindingManager.executeBindings(this,"newName",this.newName);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get newName() : TextInput
      {
         return this._1845020747newName;
      }
      
      public function set newName(param1:TextInput) : void
      {
         var _loc2_:Object = this._1845020747newName;
         if(_loc2_ !== param1)
         {
            this._1845020747newName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"newName",_loc2_,param1));
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
