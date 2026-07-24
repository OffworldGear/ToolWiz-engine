package feedsspeeds
{
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   
   public class GWizOEMRepPopUp
   {
       
      
      public function GWizOEMRepPopUp()
      {
         super();
      }
      
      public static function ContactRep() : void
      {
         GWizPopUpManager.Show(GWizAbstractPrefs.oemInfo(GWizAbstractPrefs.REP_MSG),GWizAbstractPrefs.oemInfo(GWizAbstractPrefs.REP_POPUP_TITLE));
      }
   }
}
