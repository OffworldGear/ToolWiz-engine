package
{
   import configinfo.GWizAbstractPrefs;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import threads2.GWizAbstractTaperThreadEngine;
   import threads2.GWizAbstractThreadEngine;
   import threads2.GWizThreadReference2;
   import utils.ColorPalette;
   
   public class _threads2_GWizThreadReference2WatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _threads2_GWizThreadReference2WatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizThreadReference2.watcherSetupUtil = new _threads2_GWizThreadReference2WatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[39] = new StaticPropertyWatcher("TaperThreadImg",{"propertyChange":true},[param4[115]],null);
         param5[26] = new PropertyWatcher("designation",{"propertyChange":true},[param4[27],param4[104],param4[114],param4[137]],param2);
         param5[21] = new PropertyWatcher("TypeVal",{"propertyChange":true},[param4[22]],param2);
         param5[27] = new PropertyWatcher("DRAWING_TEXT_COLOR",{"propertyChange":true},[param4[28],param4[34],param4[37],param4[40],param4[43],param4[46],param4[49],param4[52],param4[55],param4[58],param4[61],param4[62],param4[63],param4[69],param4[72],param4[75],param4[78],param4[81],param4[84],param4[87],param4[90],param4[93],param4[96],param4[99],param4[116],param4[117],param4[118],param4[119],param4[120],param4[121],param4[122],param4[123],param4[124],param4[125],param4[126],param4[127],param4[128],param4[129],param4[130],param4[131],param4[132],param4[133],param4[134]],param2);
         param5[14] = new StaticPropertyWatcher("ClassList",{"propertyChange":true},[param4[16]],null);
         param5[19] = new PropertyWatcher("custTPI",{"propertyChange":true},[param4[21]],param2);
         param5[20] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[21]],null);
         param5[11] = new PropertyWatcher("customTPI",{"propertyChange":true},[param4[10]],param2);
         param5[3] = new StaticPropertyWatcher("alternatea1",{"propertyChange":true},[param4[2],param4[15],param4[107],param4[140]],null);
         param5[10] = new PropertyWatcher("nominalSize",{"propertyChange":true},[param4[8]],param2);
         param5[4] = new PropertyWatcher("FamilyList",{"propertyChange":true},[param4[3],param4[110]],param2);
         param5[33] = new PropertyWatcher("ReportNav",{"propertyChange":true},[param4[101],param4[102]],param2);
         param5[34] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[101],param4[102]],null);
         param5[5] = new PropertyWatcher("ThreadStartGrp",{"propertyChange":true},[param4[4],param4[6],param4[9],param4[11],param4[17]],param2);
         param5[6] = new PropertyWatcher("width",{"widthChanged":true},[param4[4],param4[6],param4[9],param4[11],param4[17]],null);
         param5[35] = new PropertyWatcher("StdThreadCt",{"propertyChange":true},[param4[105],param4[138]],param2);
         param5[16] = new PropertyWatcher("classDigit1",{"propertyChange":true},[param4[19],param4[20]],param2);
         param5[18] = new PropertyWatcher("height",{"heightChanged":true},[param4[20]],null);
         param5[17] = new PropertyWatcher("width",{"widthChanged":true},[param4[19]],null);
         param5[25] = new PropertyWatcher("intExtTitleBinder",{"propertyChange":true},[param4[26],param4[103],param4[136]],param2);
         param5[36] = new PropertyWatcher("ManualLathe",{"propertyChange":true},[param4[106]],param2);
         param5[37] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[106]],null);
         param5[41] = new StaticPropertyWatcher("alternatea5",{"propertyChange":true},[param4[141]],null);
         param5[0] = new StaticPropertyWatcher("ThreadCalcEnabled",{"propertyChange":true},[param4[0]],null);
         param5[13] = new StaticPropertyWatcher("showTolClass",{"propertyChange":true},[param4[13],param4[14]],null);
         param5[32] = new PropertyWatcher("threadReference",{"propertyChange":true},[param4[100],param4[135]],param2);
         param5[8] = new PropertyWatcher("NomSize",{"propertyChange":true},[param4[7]],param2);
         param5[9] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[7]],null);
         param5[38] = new PropertyWatcher("showPipeThreads",{"propertyChange":true},[param4[108],param4[109]],param2);
         param5[28] = new StaticPropertyWatcher("IntThreadImg",{"propertyChange":true},[param4[29]],null);
         param5[40] = new PropertyWatcher("TabNav",{"propertyChange":true},[param4[139]],param2);
         param5[31] = new StaticPropertyWatcher("ExtThreadImg",{"propertyChange":true},[param4[64]],null);
         param5[15] = new StaticPropertyWatcher("gray1",{"propertyChange":true},[param4[18]],null);
         param5[12] = new PropertyWatcher("tpiToolTip",{"propertyChange":true},[param4[12]],param2);
         param5[7] = new PropertyWatcher("SizeList",{"propertyChange":true},[param4[5],param4[111]],param2);
         param5[1] = new PropertyWatcher("tabs",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new PropertyWatcher("height",{"heightChanged":true},[param4[1]],null);
         param5[39].updateParent(GWizAbstractTaperThreadEngine);
         param5[26].updateParent(param1);
         param5[21].updateParent(param1);
         param5[27].updateParent(param1);
         param5[14].updateParent(GWizAbstractThreadEngine);
         param5[19].updateParent(param1);
         param5[19].addChild(param5[20]);
         param5[11].updateParent(param1);
         param5[3].updateParent(ColorPalette);
         param5[10].updateParent(param1);
         param5[4].updateParent(param1);
         param5[33].updateParent(param1);
         param5[33].addChild(param5[34]);
         param5[5].updateParent(param1);
         param5[5].addChild(param5[6]);
         param5[35].updateParent(param1);
         param5[16].updateParent(param1);
         param5[16].addChild(param5[18]);
         param5[16].addChild(param5[17]);
         param5[25].updateParent(param1);
         param5[36].updateParent(param1);
         param5[36].addChild(param5[37]);
         param5[41].updateParent(ColorPalette);
         param5[0].updateParent(GWizAbstractPrefs);
         param5[13].updateParent(GWizAbstractThreadEngine);
         param5[32].updateParent(param1);
         param5[8].updateParent(param1);
         param5[8].addChild(param5[9]);
         param5[38].updateParent(param1);
         param5[28].updateParent(GWizAbstractThreadEngine);
         param5[40].updateParent(param1);
         param5[31].updateParent(GWizAbstractThreadEngine);
         param5[15].updateParent(ColorPalette);
         param5[12].updateParent(param1);
         param5[7].updateParent(param1);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
      }
   }
}
