package feedsspeeds
{
   import flash.events.MouseEvent;
   import login.GWizLoginBar;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import spark.components.Button;
   
   public class GWizFSCruncherBtn extends Button
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizFSCruncherBtn()
      {
         super();
         this.label = "F/S Cruncher";
         this.height = 24;
         this.width = 140;
         this.toolTip = "Run Feeds/Speeds cruncher.";
         this.addEventListener("creationComplete",this.___GWizFSCruncherBtn_Button1_creationComplete);
         this.addEventListener("click",this.___GWizFSCruncherBtn_Button1_click);
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
         var _loc1_:String = GWizLoginBar.LoginParm;
         if(_loc1_ != "bob@cnccookbook4868.com")
         {
            this.visible = false;
            this.includeInLayout = false;
         }
      }
      
      private function doFSCruncher() : void
      {
         var _loc1_:GWizFSCruncher = GWizFSCruncher.newFSCruncher();
      }
      
      public function ___GWizFSCruncherBtn_Button1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizFSCruncherBtn_Button1_click(param1:MouseEvent) : void
      {
         this.doFSCruncher();
      }
   }
}
