package tools
{
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import spark.components.Label;
   import spark.components.VGroup;
   
   public class GWizLoadingOEMCribPopup extends GWizPopUp
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizLoadingOEMCribPopup()
      {
         super();
         mx_internal::_document = this;
         this.title = "Downloading Tool Data...";
         this.width = 400;
         this.height = 300;
         this.cancelLabel = "";
         this.okEnabled = false;
         this.mxmlContent = [this._GWizLoadingOEMCribPopup_VGroup1_c()];
         this.addEventListener("creationComplete",this.___GWizLoadingOEMCribPopup_GWizPopUp1_creationComplete);
      }
      
      public static function loadingOEMCribPopup() : GWizLoadingOEMCribPopup
      {
         return GWizLoadingOEMCribPopup(GWizPopUpManager.createPopUp(null,GWizLoadingOEMCribPopup,true));
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
      }
      
      private function _GWizLoadingOEMCribPopup_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizLoadingOEMCribPopup_Label1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLoadingOEMCribPopup_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Please Wait: Downloading Tool Data...";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",20);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizLoadingOEMCribPopup_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
   }
}
