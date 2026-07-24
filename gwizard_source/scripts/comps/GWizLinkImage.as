package comps
{
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import mx.core.IFlexModuleFactory;
   import spark.components.Image;
   import utils.GWizUtils;
   
   public class GWizLinkImage extends Image
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var url:String = "";
      
      public function GWizLinkImage()
      {
         super();
         this.addEventListener("click",this.___GWizLinkImage_Image1_click);
         this.addEventListener("mouseOver",this.___GWizLinkImage_Image1_mouseOver);
         this.addEventListener("mouseOut",this.___GWizLinkImage_Image1_mouseOut);
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
         GWizUtils.assert(this.url != "");
         GWizUtils.doWebPage(this.url);
      }
      
      private function onMouseOver() : void
      {
         Mouse.cursor = MouseCursor.BUTTON;
      }
      
      private function onMouseOut() : void
      {
         Mouse.cursor = MouseCursor.ARROW;
      }
      
      public function ___GWizLinkImage_Image1_click(param1:MouseEvent) : void
      {
         this.onClick();
      }
      
      public function ___GWizLinkImage_Image1_mouseOver(param1:MouseEvent) : void
      {
         this.onMouseOver();
      }
      
      public function ___GWizLinkImage_Image1_mouseOut(param1:MouseEvent) : void
      {
         this.onMouseOut();
      }
   }
}
