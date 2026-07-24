package comps
{
   import flash.events.MouseEvent;
   import mx.core.IFlexModuleFactory;
   import utils.GWizUtils;
   
   public class GWizLinkLabelURL extends GWizLinkLabel
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var url:String = "";
      
      public function GWizLinkLabelURL()
      {
         super();
         this.addEventListener("click",this.___GWizLinkLabelURL_GWizLinkLabel1_click);
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
      
      private function onClick() : void
      {
         GWizUtils.assert(this.url && this.url != "");
         GWizUtils.doWebPage(this.url);
      }
      
      public function ___GWizLinkLabelURL_GWizLinkLabel1_click(param1:MouseEvent) : void
      {
         this.onClick();
      }
   }
}
