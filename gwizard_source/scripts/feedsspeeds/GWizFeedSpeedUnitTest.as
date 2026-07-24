package feedsspeeds
{
   import configinfo.GWizSettings;
   import flash.filesystem.File;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizCSVUtils;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizFeedSpeedUnitTest
   {
      
      private static const log:ILogger = Log.getLogger("GWizFeedsSpeedsUnitTest");
       
      
      private var passed:int = 0;
      
      private var failed:int = 0;
      
      private var resultFields:Array;
      
      public function GWizFeedSpeedUnitTest()
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         this.resultFields = ["machine","material","tool","toolDia","flutes","stickout","cutDepth","cutWidth","roughing","hsm","corncob","gasPedal","geometry","cornerrad","taperangle","effdia","MRR","RPM","Feed","deflectErr","cuttingErr","hint","Passed","Note"];
         super();
         var _loc1_:ArrayCollection = new ArrayCollection([]);
         var _loc2_:ArrayCollection = new ArrayCollection([]);
         _loc1_ = this.LoadTestCases();
         if(_loc1_)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc1_.length)
            {
               _loc4_ = this.UnitTest(_loc1_.getItemAt(_loc3_),_loc3_ + 2);
               _loc2_.addItem(_loc4_);
               _loc3_++;
            }
            this.SaveTestCases(_loc2_);
            log.debug("Passed: " + this.passed + ", Failed: " + this.failed);
         }
         else
         {
            GWizUtils.assert(false);
         }
      }
      
      private function UnitTest(param1:Object, param2:int) : Object
      {
         var _loc4_:Number = NaN;
         if(param2 >= 50)
         {
            log.debug("gotcha");
         }
         GWizSettings.FeedsSpeedsApp.api.SetupUIGeometry(param1.machine,param1.material,"",param1.tool,param1.toolDia,param1.flutes,param1.stickout,param1.cutDepth,param1.cutWidth,param1.roughing == "true",param1.hsm == "true",param1.corncob == "true",false,param1.gasPedal,param1.geometry,param1.cornerrad,param1.taperangle,0,false);
         var _loc3_:Boolean = true;
         param1.Passed = "";
         if(param1.hasOwnProperty("effdia") && Math.abs(param1.effdia - GWizSettings.FeedsSpeedsApp.api.getEffDia()) > 0.005)
         {
            param1.Passed += "effdia";
            _loc3_ = false;
         }
         param1.effdia = GWizSettings.FeedsSpeedsApp.api.getEffDia();
         if((_loc4_ = GWizUtils.pctDiff(param1.MRR,GWizSettings.FeedsSpeedsApp.api.getMRR())) > 10)
         {
            param1.Passed += "MRR";
            log.debug("testcase MRR = " + param1.MRR);
            log.debug("Calculated MRR = " + GWizSettings.FeedsSpeedsApp.api.getMRR());
            log.debug("Pct diff = " + _loc4_);
            _loc3_ = false;
         }
         param1.MRR = GWizSettings.FeedsSpeedsApp.api.getMRR();
         if(Math.abs(param1.RPM - GWizSettings.FeedsSpeedsApp.api.getRPM()) > 5)
         {
            param1.Passed += " RPM";
            _loc3_ = false;
         }
         param1.RPM = GWizSettings.FeedsSpeedsApp.api.getRPM();
         if(Math.abs(param1.Feed - GWizSettings.FeedsSpeedsApp.api.getFeed()) > 0.1)
         {
            param1.Passed += " Feed: test = " + param1.Feed + "; actual = " + GWizSettings.FeedsSpeedsApp.api.getFeed();
            _loc3_ = false;
         }
         param1.Feed = GWizSettings.FeedsSpeedsApp.api.getFeed();
         if(param1.deflectErr == "true" != GWizSettings.FeedsSpeedsApp.api.deflectErr(true))
         {
            log.debug("testcase.deflectErr = " + param1.deflectErr);
            log.debug("api.deflectErr = " + GWizSettings.FeedsSpeedsApp.api.deflectErr(true));
            param1.Passed += " deflectErr";
            _loc3_ = false;
         }
         param1.deflectErr = String(GWizSettings.FeedsSpeedsApp.api.deflectErr(true));
         if(param1.cuttingErr == "true" && GWizSettings.FeedsSpeedsApp.api.cuttingErr().length <= 0)
         {
            param1.Passed += " cuttingErr";
            log.debug("cuttingErr = \'" + GWizSettings.FeedsSpeedsApp.api.cuttingErr() + "\'");
            _loc3_ = false;
         }
         else if(param1.cuttingErr != "true" && GWizSettings.FeedsSpeedsApp.api.cuttingErr().length > 0)
         {
            param1.Passed += " cuttingErr";
            log.debug("Erroneous cuttingErr reported");
            _loc3_ = false;
         }
         param1.cuttingErr = String(GWizSettings.FeedsSpeedsApp.api.cuttingErr());
         var _loc5_:String = (_loc5_ = (_loc5_ = GWizSettings.FeedsSpeedsApp.hint.text).replace(","," ")).replace("\n"," ");
         if(GWizStringUtils.zapWhiteSpace(_loc5_).length <= 0)
         {
            _loc5_ = "";
         }
         if(!(param1.hint == _loc5_ || int(param1.hint) == 0 && int(_loc5_) == 0))
         {
            param1.Passed += " hint";
            _loc3_ = false;
         }
         param1.hint = _loc5_;
         if(_loc3_)
         {
            param1.Passed = "Y";
            ++this.passed;
         }
         else
         {
            ++this.failed;
         }
         return param1;
      }
      
      private function LoadTestCases() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection([]);
         var _loc2_:File = this.getLoadFile();
         return GWizCSVUtils.loadCSVFile(_loc2_);
      }
      
      private function SaveTestCases(param1:ArrayCollection) : void
      {
         if(!param1 || param1.length <= 0)
         {
            return;
         }
         var _loc2_:File = this.getSaveFile();
         GWizCSVUtils.saveCSVFileURL(_loc2_.url,param1,this.resultFields);
      }
      
      private function getSaveFile() : File
      {
         return GWizSettings.getPrefsFile("FeedsSpeedsUnitTestsResults.csv");
      }
      
      private function getLoadFile() : File
      {
         return GWizSettings.getPrefsFile("FeedsSpeedsUnitTests.csv");
      }
   }
}
