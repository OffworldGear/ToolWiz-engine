package material
{
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.supportClasses.ItemRenderer;
   
   public class GWizMatBrowser2InnerClass0 extends ItemRenderer
   {
       
      
      private var _418797495isoFamily:Label;
      
      private var _221944604matFamily:Label;
      
      private var _88844982outerDocument:GWizMatBrowser2;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizMatBrowser2InnerClass0()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.mxmlContent = [this._GWizMatBrowser2InnerClass0_HGroup1_c()];
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
      
      override public function set data(param1:Object) : void
      {
         var _loc2_:String = String(param1);
         this.isoFamily.text = GWizMaterialsDB.familyToISOCode(_loc2_);
         this.isoFamily.setStyle("backgroundColor",GWizMaterialsDB.familyToISOColor(_loc2_));
         this.matFamily.text = _loc2_;
      }
      
      private function _GWizMatBrowser2InnerClass0_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMatBrowser2InnerClass0_HGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMatBrowser2InnerClass0_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMatBrowser2InnerClass0_Label1_i(),this._GWizMatBrowser2InnerClass0_Label2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMatBrowser2InnerClass0_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 60;
         _loc1_.toolTip = "ISO Material Family";
         _loc1_.setStyle("paddingRight",5);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "isoFamily";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.isoFamily = _loc1_;
         BindingManager.executeBindings(this,"isoFamily",this.isoFamily);
         return _loc1_;
      }
      
      private function _GWizMatBrowser2InnerClass0_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "G-Wizard Material Family";
         _loc1_.setStyle("paddingRight",5);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "matFamily";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.matFamily = _loc1_;
         BindingManager.executeBindings(this,"matFamily",this.matFamily);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get isoFamily() : Label
      {
         return this._418797495isoFamily;
      }
      
      public function set isoFamily(param1:Label) : void
      {
         var _loc2_:Object = this._418797495isoFamily;
         if(_loc2_ !== param1)
         {
            this._418797495isoFamily = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"isoFamily",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get matFamily() : Label
      {
         return this._221944604matFamily;
      }
      
      public function set matFamily(param1:Label) : void
      {
         var _loc2_:Object = this._221944604matFamily;
         if(_loc2_ !== param1)
         {
            this._221944604matFamily = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"matFamily",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizMatBrowser2
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizMatBrowser2) : void
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
