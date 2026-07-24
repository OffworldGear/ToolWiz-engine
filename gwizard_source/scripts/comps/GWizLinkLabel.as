package comps
{
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   
   public class GWizLinkLabel extends GWizEditableLabel
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizLinkLabel()
      {
         super();
         this.addEventListener("creationComplete",this.___GWizLinkLabel_GWizEditableLabel1_creationComplete);
         this.addEventListener("mouseOver",this.___GWizLinkLabel_GWizEditableLabel1_mouseOver);
         this.addEventListener("mouseOut",this.___GWizLinkLabel_GWizEditableLabel1_mouseOut);
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
         isLinkLabel(true);
      }
      
      private function onMouseOver() : void
      {
         if(text && text.length > 0)
         {
            Mouse.cursor = MouseCursor.BUTTON;
         }
      }
      
      private function onMouseOut() : void
      {
         Mouse.cursor = MouseCursor.ARROW;
      }
      
      public function ___GWizLinkLabel_GWizEditableLabel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizLinkLabel_GWizEditableLabel1_mouseOver(param1:MouseEvent) : void
      {
         this.onMouseOver();
      }
      
      public function ___GWizLinkLabel_GWizEditableLabel1_mouseOut(param1:MouseEvent) : void
      {
         this.onMouseOut();
      }
   }
}
