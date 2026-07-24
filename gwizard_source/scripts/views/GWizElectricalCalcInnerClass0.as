package views
{
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.components.supportClasses.ItemRenderer;
   
   public class GWizElectricalCalcInnerClass0 extends ItemRenderer
   {
       
      
      private var _1959266596labelTxt:Label;
      
      private var _88844982outerDocument:GWizElectricalCalc;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizElectricalCalcInnerClass0()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.mxmlContent = [this._GWizElectricalCalcInnerClass0_Label1_i()];
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
         this.labelTxt.text = param1.label;
      }
      
      private function _GWizElectricalCalcInnerClass0_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("paddingTop",2);
         _loc1_.setStyle("paddingBottom",1);
         _loc1_.setStyle("paddingLeft",1);
         _loc1_.setStyle("paddingRight",1);
         _loc1_.setStyle("textAlign","center");
         _loc1_.id = "labelTxt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labelTxt = _loc1_;
         BindingManager.executeBindings(this,"labelTxt",this.labelTxt);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get labelTxt() : Label
      {
         return this._1959266596labelTxt;
      }
      
      public function set labelTxt(param1:Label) : void
      {
         var _loc2_:Object = this._1959266596labelTxt;
         if(_loc2_ !== param1)
         {
            this._1959266596labelTxt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelTxt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizElectricalCalc
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizElectricalCalc) : void
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
