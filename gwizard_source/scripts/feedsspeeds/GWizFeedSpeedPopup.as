package feedsspeeds
{
   import comps.GWizPopUp;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import spark.components.Group;
   import utils.GWizUtils;
   
   public class GWizFeedSpeedPopup extends GWizPopUp
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var okFunction:Function = null;
      
      public var fsCalc:GWizFeedsSpeeds2;
      
      private var fsParent:Group;
      
      public function GWizFeedSpeedPopup()
      {
         super();
         mx_internal::_document = this;
         this.fullScreen = true;
         this.title = "Feeds and Speeds...";
         this.okLabel = "Insert";
         this.addEventListener("creationComplete",this.___GWizFeedSpeedPopup_GWizPopUp1_creationComplete);
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
      
      protected function onCC() : void
      {
         this.fsCalc = GWizSettings.FeedsSpeedsApp;
         this.fsParent = this.fsCalc.parent as Group;
         if(this.fsParent)
         {
            this.fsParent.removeElement(this.fsCalc);
         }
         this.addElement(this.fsCalc);
         GWizUtils.currApp = GWizFeedsSpeeds2.APP_NAME;
         this.fsCalc.cribTbl.enabled = false;
         this.height = Math.min(this.height,GWizSettings.docWindow.height) - 5;
         this.width = Math.min(this.width,GWizSettings.docWindow.width) - 5;
         if(this.height < 768)
         {
            this.fsCalc.setStyle("fontSize",10);
         }
      }
      
      override public function onOk(param1:Event) : void
      {
         super.close();
         if(this.okFunction != null)
         {
            this.okFunction(this.fsCalc);
         }
         this.restoreChild();
      }
      
      override public function onCancel(param1:Event) : void
      {
         super.onCancel(param1);
         this.restoreChild();
      }
      
      private function restoreChild() : void
      {
         this.fsCalc.cribTbl.enabled = true;
         this.removeElement(this.fsCalc);
         this.fsParent.addElement(this.fsCalc);
      }
      
      protected function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 13;
         var _loc3_:int = 27;
         switch(param1.charCode)
         {
            case _loc2_:
               GWizUtils.zapKey(param1);
               super.close();
               break;
            case _loc3_:
               GWizUtils.zapKey(param1);
               super.close();
         }
      }
      
      public function ___GWizFeedSpeedPopup_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
   }
}
