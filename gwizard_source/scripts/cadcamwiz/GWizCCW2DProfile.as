package cadcamwiz
{
   import mx.core.IFlexModuleFactory;
   
   public class GWizCCW2DProfile extends GWizCCWGenericWizard
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizCCW2DProfile()
      {
         super();
         mx_internal::_document = this;
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
      
      override public function onCC() : void
      {
         inputs = new GWizCCW2DProfileInputs();
         inputs.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         installInputs(inputs);
         options = getPocketOptions();
         options.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         installOptions(options);
         FeedsBox.showEntry = true;
      }
      
      override public function isProfile() : Boolean
      {
         return true;
      }
      
      override public function opType() : String
      {
         return GWizCCWEstRecord.CCE_MILL_2DProfile;
      }
      
      override public function checkResult() : Boolean
      {
         var roughDepth:Number = NaN;
         var semiFinishDepth:Number = NaN;
         var i:int = 0;
         var row:Object = null;
         var finishDepth:Number = NaN;
         var retval:Boolean = true;
         try
         {
            testcase("No results",results.length > 0);
            i = 0;
            while(i < results.length && retval)
            {
               row = results.getItemAt(i);
               finishDepth = !!inputs.finishPassGrp.useFinish.selected ? Number(inputs.finishPassGrp.FinishPass.getVal()) : Number(0);
               if(i == 0)
               {
                  testcase("No Roughing Pass",row.op == "Rough");
                  roughDepth = row.passes * row.height;
                  testcase("Roughing pass total too deep",roughDepth <= inputs.Depth.getVal());
                  testcase("Roughing pass has zero or bad time",row.opTime >= 0);
               }
               else if(row.op == "Finish")
               {
                  if(!isNaN(semiFinishDepth))
                  {
                     roughDepth = semiFinishDepth;
                  }
                  testcase("Showing Finish pass when none requested",inputs.finishPassGrp.useFinish.selected);
                  testcase("Rough not deep enough",inputs.Depth.getVal() - roughDepth - 0.0001 <= 0);
                  testcase("Rough depth is too deep",row.passes * row.height - inputs.Depth.getVal() <= 0.0002);
                  testcase("Finish pass has zero or bad time",row.opTime >= 0);
               }
               else if(row.op == "Semi-Finish")
               {
                  testcase("Should be no Semi-Finish passes any more!",false);
               }
               else if(row.op != GWizCCWEstRecord.CCE_CHAMFER)
               {
                  testcase("Unknown pass type = " + row.op,false);
               }
               i++;
            }
         }
         catch(error:Error)
         {
            retval = false;
         }
         return retval || GWizCadCam._needRecalc;
      }
   }
}
