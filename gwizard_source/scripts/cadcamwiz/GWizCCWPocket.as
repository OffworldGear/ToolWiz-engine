package cadcamwiz
{
   public class GWizCCWPocket extends GWizCCWGenericWizard
   {
       
      
      public function GWizCCWPocket()
      {
         super();
         FeedsBox.showEntry = true;
      }
      
      override public function opType() : String
      {
         return GWizCCWEstRecord.CCE_MILL_POCKET;
      }
   }
}
