package
{
   import configinfo.GWizSettings;
   import feedsspeeds.GWizFeedsSpeeds2;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.GWizStylePalette;
   import tools.GWizCribList;
   import tools.GWizToolData;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   public class _feedsspeeds_GWizFeedsSpeeds2WatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizFeedsSpeeds2WatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizFeedsSpeeds2.watcherSetupUtil = new _feedsspeeds_GWizFeedsSpeeds2WatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[5] = new PropertyWatcher("ToolFP",{"propertyChange":true},[param4[3]],param2);
         param5[6] = new PropertyWatcher("height",{"heightChanged":true},[param4[3]],null);
         param5[12] = new StaticPropertyWatcher("primary5",{"propertyChange":true},[param4[9],param4[35],param4[45],param4[56],param4[61],param4[69],param4[78],param4[88],param4[97],param4[105],param4[119],param4[123]],null);
         param5[56] = new PropertyWatcher("Deflect",{"propertyChange":true},[param4[111],param4[112]],param2);
         param5[57] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[111],param4[112]],null);
         param5[16] = new PropertyWatcher("td",{"propertyChange":true},[param4[14],param4[22]],param2);
         param5[20] = new PropertyWatcher("optStick",{"propertyChange":true},[param4[22]],null);
         param5[25] = new PropertyWatcher("powerUserState",{"propertyChange":true},[param4[41],param4[51],param4[53],param4[115]],param2);
         param5[3] = new PropertyWatcher("secondCol",{"propertyChange":true},[param4[2],param4[4],param4[20],param4[28],param4[42]],param2);
         param5[4] = new PropertyWatcher("width",{"widthChanged":true},[param4[2],param4[4],param4[20],param4[28],param4[42]],null);
         param5[65] = new StaticPropertyWatcher("exportBtnLabel",{"propertyChange":true},[param4[128]],param3);
         param5[26] = new PropertyWatcher("cutWidth",{"propertyChange":true},[param4[49]],param2);
         param5[27] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[49]],null);
         param5[19] = new StaticPropertyWatcher("cribListPlus",{"propertyChange":true},[param4[18]],null);
         param5[44] = new PropertyWatcher("tipList",{"propertyChange":true},[param4[92]],param2);
         param5[7] = new PropertyWatcher("labelWidths",{"propertyChange":true},[param4[5],param4[24],param4[30],param4[36],param4[46],param4[57],param4[62],param4[70],param4[79],param4[89],param4[95],param4[120],param4[124]],param2);
         param5[11] = new StaticPropertyWatcher("primary3",{"propertyChange":true},[param4[8],param4[34],param4[44],param4[55],param4[60],param4[68],param4[77],param4[87],param4[94],param4[104],param4[118],param4[122]],null);
         param5[38] = new PropertyWatcher("PlungeRate",{"propertyChange":true},[param4[81],param4[83],param4[86]],param2);
         param5[39] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[81],param4[83],param4[86]],null);
         param5[64] = new StaticPropertyWatcher("debug",{"propertyChange":true},[param4[126],param4[127]],null);
         param5[47] = new PropertyWatcher("SFM",{"propertyChange":true},[param4[101],param4[103],param4[108]],param2);
         param5[48] = new PropertyWatcher("height",{"heightChanged":true},[param4[101],param4[103],param4[108]],null);
         param5[51] = new PropertyWatcher("hpTempSlider",{"propertyChange":true},[param4[109]],param2);
         param5[52] = new PropertyWatcher("percent",{"propertyChange":true},[param4[109]],null);
         param5[15] = new PropertyWatcher("cribTbl",{"propertyChange":true},[param4[13]],param2);
         param5[66] = new StaticPropertyWatcher("showExport",{"propertyChange":true},[param4[129]],param3);
         param5[30] = new PropertyWatcher("rpmTempSlider",{"propertyChange":true},[param4[66]],param2);
         param5[31] = new PropertyWatcher("percent",{"propertyChange":true},[param4[66]],null);
         param5[14] = new StaticPropertyWatcher("MillToolsList",{"propertyChange":true},[param4[12]],null);
         param5[23] = new PropertyWatcher("HSMPanel",{"propertyChange":true},[param4[33],param4[43]],param2);
         param5[24] = new PropertyWatcher("height",{"heightChanged":true},[param4[33],param4[43]],null);
         param5[60] = new PropertyWatcher("optWidth",{"propertyChange":true},[param4[115]],param2);
         param5[61] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[115]],null);
         param5[13] = new StaticPropertyWatcher("textColor",{"propertyChange":true},[param4[11],param4[17],param4[23],param4[38],param4[39],param4[40],param4[48],param4[50],param4[52],param4[59],param4[65],param4[73],param4[75],param4[85],param4[91],param4[100],param4[102],param4[114]],null);
         param5[8] = new PropertyWatcher("gapSizes",{"propertyChange":true},[param4[6],param4[10],param4[25],param4[31],param4[37],param4[47],param4[58],param4[63],param4[71],param4[80],param4[90],param4[96],param4[121],param4[125]],param2);
         param5[41] = new StaticPropertyWatcher("PlungeModes",{"propertyChange":true},[param4[82]],param3);
         param5[35] = new PropertyWatcher("feedTempSlider",{"propertyChange":true},[param4[74]],param2);
         param5[36] = new PropertyWatcher("percent",{"propertyChange":true},[param4[74]],null);
         param5[54] = new PropertyWatcher("deflectTempSlider",{"propertyChange":true},[param4[110]],param2);
         param5[55] = new PropertyWatcher("percent",{"propertyChange":true},[param4[110]],null);
         param5[9] = new PropertyWatcher("thirdCol",{"propertyChange":true},[param4[7],param4[21],param4[29],param4[54]],param2);
         param5[10] = new PropertyWatcher("width",{"widthChanged":true},[param4[7],param4[21],param4[29],param4[54]],null);
         param5[0] = new StaticPropertyWatcher("cribGeneration",{"propertyChange":true},[param4[0]],null);
         param5[1] = new PropertyWatcher("feedsPanel",{"propertyChange":true},[param4[1],param4[4],param4[19],param4[27],param4[32],param4[67],param4[76]],param2);
         param5[32] = new PropertyWatcher("height",{"heightChanged":true},[param4[67],param4[76]],null);
         param5[2] = new PropertyWatcher("width",{"widthChanged":true},[param4[1],param4[4],param4[19],param4[27],param4[32]],null);
         param5[5].updateParent(param1);
         param5[5].addChild(param5[6]);
         param5[12].updateParent(ColorPalette);
         param5[56].updateParent(param1);
         param5[56].addChild(param5[57]);
         param5[16].updateParent(param1);
         param5[16].addChild(param5[20]);
         param5[25].updateParent(param1);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[4]);
         param5[65].updateParent(GWizFeedsSpeeds2);
         param5[26].updateParent(param1);
         param5[26].addChild(param5[27]);
         param5[19].updateParent(GWizCribList);
         param5[44].updateParent(param1);
         param5[7].updateParent(param1);
         param5[11].updateParent(ColorPalette);
         param5[38].updateParent(param1);
         param5[38].addChild(param5[39]);
         param5[64].updateParent(GWizUtils);
         param5[47].updateParent(param1);
         param5[47].addChild(param5[48]);
         param5[51].updateParent(param1);
         param5[51].addChild(param5[52]);
         param5[15].updateParent(param1);
         param5[66].updateParent(GWizFeedsSpeeds2);
         param5[30].updateParent(param1);
         param5[30].addChild(param5[31]);
         param5[14].updateParent(GWizToolData);
         param5[23].updateParent(param1);
         param5[23].addChild(param5[24]);
         param5[60].updateParent(param1);
         param5[60].addChild(param5[61]);
         param5[13].updateParent(GWizStylePalette);
         param5[8].updateParent(param1);
         param5[41].updateParent(GWizFeedsSpeeds2);
         param5[35].updateParent(param1);
         param5[35].addChild(param5[36]);
         param5[54].updateParent(param1);
         param5[54].addChild(param5[55]);
         param5[9].updateParent(param1);
         param5[9].addChild(param5[10]);
         param5[0].updateParent(GWizSettings);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[32]);
         param5[1].addChild(param5[2]);
      }
   }
}
