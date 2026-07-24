package login
{
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import flash.events.MouseEvent;
   import mx.core.IFlexModuleFactory;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Group;
   import spark.components.Image;
   import utils.GATracker;
   import utils.GWizUtils;
   
   public class GWizHelpButton extends Group
   {
      
      private static const log:ILogger = Log.getLogger("GWizHelpButton");
      
      public static var HelpBtnAuxFcn:Function = null;
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _embed_mxml__assets_HelpBtn_png_849981940:Class;
      
      public function GWizHelpButton()
      {
         this._embed_mxml__assets_HelpBtn_png_849981940 = GWizHelpButton__embed_mxml__assets_HelpBtn_png_849981940;
         super();
         mx_internal::_document = this;
         this.mxmlContent = [this._GWizHelpButton_Image1_c()];
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
      
      public function GetHelp() : void
      {
         if(GWizAbstractPrefs.isOEM && HelpBtnAuxFcn != null)
         {
            HelpBtnAuxFcn();
            return;
         }
         var _loc1_:String = "https://support.cnccookbook.com/";
         GATracker.logPageView("Login/Help/" + GWizUtils.currApp,"Login Help: " + GWizUtils.currApp);
         switch(GWizUtils.currApp)
         {
            case "Calculator":
               _loc1_ = "http://www.cnccookbook.com/GWCalculator.htm";
               break;
            case "Feeds/Speeds":
               _loc1_ = "https://www.cnccookbook.com/g-wizard-cnc-feed-speed-calculator/";
               break;
            case "Geometry":
               _loc1_ = "http://www.cnccookbook.com/GWCalcGeometry.htm";
               break;
            case "Threads":
               _loc1_ = "http://www.cnccookbook.com/GWCalcThreads.htm";
               break;
            case "Quick Refs":
               _loc1_ = "http://www.cnccookbook.com/GWCalcQuickRef.htm";
               break;
            case "Setup":
               _loc1_ = "https://www.cnccookbook.com/g-wizard-calculator-setup/";
               break;
            case "Editor":
               _loc1_ = "http://www.cnccookbook.com/GWEOverview.html";
               break;
            case "SetupEditor":
               _loc1_ = "http://www.cnccookbook.com/GWESetup.html";
               break;
            case "Revisions":
               _loc1_ = "http://www.cnccookbook.com/GWERevisions.html";
               break;
            case "Simulator":
               _loc1_ = "http://www.cnccookbook.com/GWECNCSimulator.html";
               break;
            case "CADCAM":
               _loc1_ = "https://www.cnccookbook.com/cadcam-wizards-user-guide/";
               break;
            case "GWThreads":
               _loc1_ = "https://www.cnccookbook.com/getting-started-g-wizard-thread-calculator/";
               break;
            default:
               if(GWizUtils.debug)
               {
                  log.debug("Bad app name, no help context: " + GWizUtils.currApp);
                  GWizPopUpManager.Show("Ouch, I got no help for you!","Error: Missing Help",GWizPopUpManager.ERROR);
                  GATracker.logPageView("Login/Help/NoHelp","Login Help: NoHelp");
               }
         }
         GWizUtils.doWebPage(_loc1_);
      }
      
      private function _GWizHelpButton_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_HelpBtn_png_849981940;
         _loc1_.scaleX = 0.5;
         _loc1_.scaleY = 0.5;
         _loc1_.toolTip = "Help";
         _loc1_.addEventListener("click",this.___GWizHelpButton_Image1_click);
         _loc1_.addEventListener("rollOut",this.___GWizHelpButton_Image1_rollOut);
         _loc1_.addEventListener("rollOver",this.___GWizHelpButton_Image1_rollOver);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizHelpButton_Image1_click(param1:MouseEvent) : void
      {
         this.GetHelp();
      }
      
      public function ___GWizHelpButton_Image1_rollOut(param1:MouseEvent) : void
      {
         GWizLoginBar.checkTransform(param1);
      }
      
      public function ___GWizHelpButton_Image1_rollOver(param1:MouseEvent) : void
      {
         GWizLoginBar.checkTransform(param1);
      }
   }
}
