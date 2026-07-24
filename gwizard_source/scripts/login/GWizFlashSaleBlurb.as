package login
{
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.BorderContainer;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   public class GWizFlashSaleBlurb extends GWizPopUp
   {
       
      
      private var _88844982outerDocument:GWizOfferBtn;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizFlashSaleBlurb()
      {
         super();
         mx_internal::_document = this;
         this.title = "Trial User Special Offer";
         this.okLabel = "Show Me!";
         this.cancelLabel = "No Thanks";
         this.width = 500;
         this.height = 200;
         this.horizontalAlign = "center";
         this.verticalAlign = "middle";
         this.mxmlContent = [this._GWizFlashSaleBlurb_BorderContainer1_c()];
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
         GWizUtils.doWebPage(GWizOfferBtn.saleURL);
         super.close();
      }
      
      private function _GWizFlashSaleBlurb_BorderContainer1_c() : BorderContainer
      {
         var _loc1_:BorderContainer = new BorderContainer();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFlashSaleBlurb_Array2_c);
         _loc1_.setStyle("backgroundColor",0);
         _loc1_.setStyle("borderVisible",false);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFlashSaleBlurb_Array2_c() : Array
      {
         return [this._GWizFlashSaleBlurb_VGroup1_c()];
      }
      
      private function _GWizFlashSaleBlurb_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.paddingTop = 5;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFlashSaleBlurb_Label1_c(),this._GWizFlashSaleBlurb_Label2_c(),this._GWizFlashSaleBlurb_Label3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFlashSaleBlurb_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Special limited time offer for trial users.";
         _loc1_.setStyle("fontSize",21);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         _loc1_.setStyle("backgroundColor",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFlashSaleBlurb_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "We appreciate your taking time to look at G-Wizard.";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         _loc1_.setStyle("backgroundColor",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFlashSaleBlurb_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Click \'Show Me\' to check out the offer, you don\'t want to miss this.";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         _loc1_.setStyle("backgroundColor",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizOfferBtn
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizOfferBtn) : void
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
