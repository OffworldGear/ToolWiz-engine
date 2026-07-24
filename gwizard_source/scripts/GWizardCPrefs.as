package
{
   import configinfo.GWizAbstractPrefs;
   import login.GWizLoginSplash;
   import machines.GWizMachProfile;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizardCPrefs extends GWizAbstractPrefs
   {
      
      private static const log:ILogger = Log.getLogger("GWizardCPrefs");
       
      
      public function GWizardCPrefs()
      {
         super();
      }
      
      override public function processAppSpecificXMLData(param1:XML) : XML
      {
         GWizUtils.currApp = param1.CurrApp;
         if(param1.hasOwnProperty("setupLocked"))
         {
            GWizMachProfile.setupLocked = param1.setupLocked == "true";
         }
         else
         {
            GWizMachProfile.setupLocked = false;
         }
         if(param1.hasOwnProperty("modalSetupStage"))
         {
            GWizLoginSplash.modalSetupStage = param1.modalSetupStage;
         }
         else
         {
            GWizLoginSplash.modalSetupStage = GWizLoginSplash.SETUP_DONE_TAB;
         }
         return param1;
      }
      
      override public function createAppSpecificXMLData(param1:XML) : XML
      {
         param1.CurrApp = GWizUtils.currApp;
         param1.setupLocked = GWizMachProfile.setupLocked;
         param1.modalSetupStage = GWizLoginSplash.modalSetupStage;
         return param1;
      }
   }
}
