package
{
   import configinfo.GWizConfigData;
   import machines.GWizMachProfile;
   import machines.GWizSpindleCurve;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import post.GWizPostVars;
   import utils.ColorPalette;
   
   public class _machines_GWizMachProfileWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _machines_GWizMachProfileWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizMachProfile.watcherSetupUtil = new _machines_GWizMachProfileWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[22] = new PropertyWatcher("Model",{"propertyChange":true},[param4[38]],param2);
         param5[19] = new PropertyWatcher("spindleRPMGrp",{"propertyChange":true},[param4[34],param4[39],param4[46],param4[51],param4[53],param4[54]],param2);
         param5[20] = new PropertyWatcher("width",{"widthChanged":true},[param4[34],param4[39],param4[46],param4[51],param4[53],param4[54]],null);
         param5[5] = new StaticPropertyWatcher("primary5",{"propertyChange":true},[param4[8],param4[15],param4[25]],null);
         param5[23] = new StaticPropertyWatcher("millTapers",{"propertyChange":true},[param4[40]],null);
         param5[26] = new StaticPropertyWatcher("millTaperSizes",{"propertyChange":true},[param4[42]],null);
         param5[27] = new PropertyWatcher("stSizeLabel",{"propertyChange":true},[param4[45],param4[50]],param2);
         param5[28] = new PropertyWatcher("width",{"widthChanged":true},[param4[45],param4[50]],null);
         param5[3] = new PropertyWatcher("powerUserState",{"propertyChange":true},[param4[4],param4[5]],param2);
         param5[8] = new PropertyWatcher("machType",{"propertyChange":true},[param4[10],param4[36]],param2);
         param5[9] = new PropertyWatcher("height",{"heightChanged":true},[param4[10]],null);
         param5[29] = new StaticPropertyWatcher("adjustMsg",{"propertyChange":true},[param4[52]],null);
         param5[24] = new PropertyWatcher("taperSize",{"propertyChange":true},[param4[41],param4[49]],param2);
         param5[25] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[41],param4[49]],null);
         param5[37] = new PropertyWatcher("browseBtn",{"propertyChange":true},[param4[71]],param2);
         param5[38] = new PropertyWatcher("width",{"widthChanged":true},[param4[71]],null);
         param5[34] = new StaticPropertyWatcher("downloading",{"propertyChange":true},[param4[68]],param3);
         param5[11] = new PropertyWatcher("machRPMSimple",{"propertyChange":true},[param4[16],param4[17],param4[18]],param2);
         param5[12] = new PropertyWatcher("height",{"heightChanged":true},[param4[16],param4[17],param4[18]],null);
         param5[35] = new PropertyWatcher("Controller",{"propertyChange":true},[param4[70]],param2);
         param5[36] = new PropertyWatcher("width",{"widthChanged":true},[param4[70]],null);
         param5[33] = new PropertyWatcher("toolMaterial",{"propertyChange":true},[param4[63]],param2);
         param5[6] = new PropertyWatcher("machName",{"propertyChange":true},[param4[9],param4[11],param4[12],param4[13],param4[35]],param2);
         param5[7] = new PropertyWatcher("height",{"heightChanged":true},[param4[9],param4[11],param4[12]],null);
         param5[10] = new PropertyWatcher("width",{"widthChanged":true},[param4[13]],null);
         param5[1] = new StaticPropertyWatcher("gray5",{"propertyChange":true},[param4[1]],null);
         param5[30] = new StaticPropertyWatcher("noLoad",{"propertyChange":true},[param4[55],param4[60],param4[61],param4[62],param4[64],param4[65],param4[66],param4[69]],null);
         param5[4] = new StaticPropertyWatcher("primary3",{"propertyChange":true},[param4[7],param4[14],param4[24]],null);
         param5[2] = new StaticPropertyWatcher("gray1",{"propertyChange":true},[param4[2],param4[6],param4[33]],null);
         param5[0] = new StaticPropertyWatcher("gray3",{"propertyChange":true},[param4[0]],null);
         param5[21] = new PropertyWatcher("Make",{"propertyChange":true},[param4[37]],param2);
         param5[22].updateParent(param1);
         param5[19].updateParent(param1);
         param5[19].addChild(param5[20]);
         param5[5].updateParent(ColorPalette);
         param5[23].updateParent(GWizConfigData);
         param5[26].updateParent(GWizConfigData);
         param5[27].updateParent(param1);
         param5[27].addChild(param5[28]);
         param5[3].updateParent(param1);
         param5[8].updateParent(param1);
         param5[8].addChild(param5[9]);
         param5[29].updateParent(GWizSpindleCurve);
         param5[24].updateParent(param1);
         param5[24].addChild(param5[25]);
         param5[37].updateParent(param1);
         param5[37].addChild(param5[38]);
         param5[34].updateParent(GWizMachProfile);
         param5[11].updateParent(param1);
         param5[11].addChild(param5[12]);
         param5[35].updateParent(param1);
         param5[35].addChild(param5[36]);
         param5[33].updateParent(param1);
         param5[6].updateParent(param1);
         param5[6].addChild(param5[7]);
         param5[6].addChild(param5[10]);
         param5[1].updateParent(ColorPalette);
         param5[30].updateParent(GWizPostVars);
         param5[4].updateParent(ColorPalette);
         param5[2].updateParent(ColorPalette);
         param5[0].updateParent(ColorPalette);
         param5[21].updateParent(param1);
      }
   }
}
