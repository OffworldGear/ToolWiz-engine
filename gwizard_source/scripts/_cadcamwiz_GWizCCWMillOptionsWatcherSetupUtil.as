package
{
   import cadcamwiz.GWizCCWMillOptions;
   import cadcamwiz.GWizCCWRecalc;
   import cadcamwiz.GWizCCWSettings;
   import configinfo.GWizSettings;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizCribList;
   
   public class _cadcamwiz_GWizCCWMillOptionsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWMillOptionsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWMillOptions.watcherSetupUtil = new _cadcamwiz_GWizCCWMillOptionsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[9] = new StaticPropertyWatcher("ccwCribList",{"propertyChange":true},[param4[9]],null);
         param5[15] = new StaticPropertyWatcher("faceMillFlutes",{"propertyChange":true},[param4[16]],param3);
         param5[1] = new StaticPropertyWatcher("roughStrat",{"propertyChange":true},[param4[1]],param3);
         param5[19] = new StaticPropertyWatcher("TortoiseImg",{"propertyChange":true},[param4[21]],null);
         param5[5] = new StaticPropertyWatcher("maxToolDia",{"propertyChange":true},[param4[5]],param3);
         param5[8] = new StaticPropertyWatcher("toolCribToolSelection",{"propertyChange":true},[param4[8],param4[10]],null);
         param5[4] = new StaticPropertyWatcher("mmSizes",{"propertyChange":true},[param4[4]],param3);
         param5[13] = new StaticPropertyWatcher("maxIdxDOC",{"propertyChange":true},[param4[14]],param3);
         param5[16] = new StaticPropertyWatcher("maxFaceDOC",{"propertyChange":true},[param4[17]],param3);
         param5[11] = new StaticPropertyWatcher("maxIdxRoughToolDia",{"propertyChange":true},[param4[12]],param3);
         param5[0] = new StaticPropertyWatcher("roughingStrategies",{"propertyChange":true},[param4[0]],null);
         param5[6] = new StaticPropertyWatcher("maxSolidToolDOCMult",{"propertyChange":true},[param4[6]],param3);
         param5[7] = new StaticPropertyWatcher("maxSolidToolStepover",{"propertyChange":true},[param4[7]],param3);
         param5[14] = new StaticPropertyWatcher("maxFaceToolDia",{"propertyChange":true},[param4[15]],param3);
         param5[21] = new StaticPropertyWatcher("_GasPedalSlider",{"propertyChange":true},[param4[23]],param3);
         param5[17] = new PropertyWatcher("ChamferOptions",{"propertyChange":true},[param4[18],param4[19]],param2);
         param5[10] = new StaticPropertyWatcher("cribListPlus",{"propertyChange":true},[param4[11]],null);
         param5[18] = new StaticPropertyWatcher("usePremiumCoolantOptions",{"propertyChange":true},[param4[20]],param3);
         param5[2] = new StaticPropertyWatcher("maxRoughToolDia",{"propertyChange":true},[param4[2]],param3);
         param5[12] = new StaticPropertyWatcher("idxRoughFlutes",{"propertyChange":true},[param4[13]],param3);
         param5[3] = new StaticPropertyWatcher("impSizes",{"propertyChange":true},[param4[3]],param3);
         param5[22] = new StaticPropertyWatcher("HareImg",{"propertyChange":true},[param4[24]],null);
         param5[9].updateParent(GWizCribList);
         param5[15].updateParent(GWizCCWMillOptions);
         param5[1].updateParent(GWizCCWMillOptions);
         param5[19].updateParent(GWizSettings);
         param5[5].updateParent(GWizCCWMillOptions);
         param5[8].updateParent(GWizCCWSettings);
         param5[4].updateParent(GWizCCWMillOptions);
         param5[13].updateParent(GWizCCWMillOptions);
         param5[16].updateParent(GWizCCWMillOptions);
         param5[11].updateParent(GWizCCWMillOptions);
         param5[0].updateParent(GWizCCWRecalc);
         param5[6].updateParent(GWizCCWMillOptions);
         param5[7].updateParent(GWizCCWMillOptions);
         param5[14].updateParent(GWizCCWMillOptions);
         param5[21].updateParent(GWizCCWMillOptions);
         param5[17].updateParent(param1);
         param5[10].updateParent(GWizCribList);
         param5[18].updateParent(GWizCCWMillOptions);
         param5[2].updateParent(GWizCCWMillOptions);
         param5[12].updateParent(GWizCCWMillOptions);
         param5[3].updateParent(GWizCCWMillOptions);
         param5[22].updateParent(GWizSettings);
      }
   }
}
