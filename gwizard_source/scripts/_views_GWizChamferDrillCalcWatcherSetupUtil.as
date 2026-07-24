package
{
   import configinfo.GWizConfigData;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   import views.GWizChamferDrillCalc;
   
   public class _views_GWizChamferDrillCalcWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizChamferDrillCalcWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizChamferDrillCalc.watcherSetupUtil = new _views_GWizChamferDrillCalcWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[30] = new PropertyWatcher("tdDia",{"propertyChange":true},[param4[30],param4[31]],param2);
         param5[32] = new PropertyWatcher("stepperGroup",{"propertyChange":true},[param4[30]],null);
         param5[33] = new PropertyWatcher("x",{"xChanged":true},[param4[30]],null);
         param5[34] = new PropertyWatcher("y",{"yChanged":true},[param4[31]],null);
         param5[31] = new PropertyWatcher("x",{"xChanged":true},[param4[30]],null);
         param5[44] = new PropertyWatcher("csDia",{"propertyChange":true},[param4[38],param4[39]],param2);
         param5[46] = new PropertyWatcher("y",{"yChanged":true},[param4[39]],null);
         param5[45] = new PropertyWatcher("x",{"xChanged":true},[param4[38]],null);
         param5[24] = new PropertyWatcher("sdDepthLabel",{"propertyChange":true},[param4[22],param4[23]],param2);
         param5[26] = new PropertyWatcher("y",{"yChanged":true},[param4[23]],null);
         param5[25] = new PropertyWatcher("x",{"xChanged":true},[param4[22]],null);
         param5[15] = new PropertyWatcher("sdDrillDia",{"propertyChange":true},[param4[16],param4[17]],param2);
         param5[17] = new PropertyWatcher("y",{"yChanged":true},[param4[17]],null);
         param5[16] = new PropertyWatcher("x",{"xChanged":true},[param4[16]],null);
         param5[35] = new PropertyWatcher("tdHoleDepth",{"propertyChange":true},[param4[32],param4[33]],param2);
         param5[37] = new PropertyWatcher("y",{"yChanged":true},[param4[33]],null);
         param5[36] = new PropertyWatcher("x",{"xChanged":true},[param4[32]],null);
         param5[47] = new PropertyWatcher("csDepthLabel",{"propertyChange":true},[param4[40],param4[41]],param2);
         param5[49] = new PropertyWatcher("width",{"widthChanged":true},[param4[40]],null);
         param5[50] = new PropertyWatcher("y",{"yChanged":true},[param4[41]],null);
         param5[48] = new PropertyWatcher("x",{"xChanged":true},[param4[40]],null);
         param5[4] = new StaticPropertyWatcher("CenterDrillList",{"propertyChange":true},[param4[3]],null);
         param5[8] = new PropertyWatcher("depthLabel",{"propertyChange":true},[param4[6],param4[7]],param2);
         param5[10] = new PropertyWatcher("width",{"widthChanged":true},[param4[6]],null);
         param5[11] = new PropertyWatcher("y",{"yChanged":true},[param4[7]],null);
         param5[9] = new PropertyWatcher("x",{"xChanged":true},[param4[6]],null);
         param5[12] = new PropertyWatcher("chamDiaLabel",{"propertyChange":true},[param4[8],param4[9],param4[10],param4[11],param4[12],param4[13],param4[14],param4[15]],param2);
         param5[14] = new PropertyWatcher("y",{"yChanged":true},[param4[9],param4[11],param4[13],param4[15]],null);
         param5[13] = new PropertyWatcher("x",{"xChanged":true},[param4[8],param4[10],param4[12],param4[14]],null);
         param5[0] = new PropertyWatcher("tabNav",{"propertyChange":true},[param4[0]],param2);
         param5[18] = new PropertyWatcher("sdIncludedAngle",{"propertyChange":true},[param4[18],param4[19]],param2);
         param5[20] = new PropertyWatcher("y",{"yChanged":true},[param4[19]],null);
         param5[19] = new PropertyWatcher("x",{"xChanged":true},[param4[18]],null);
         param5[51] = new PropertyWatcher("csTipDiaLabel",{"propertyChange":true},[param4[42],param4[43]],param2);
         param5[53] = new PropertyWatcher("y",{"yChanged":true},[param4[43]],null);
         param5[52] = new PropertyWatcher("x",{"xChanged":true},[param4[42]],null);
         param5[38] = new PropertyWatcher("tdDrillDepthLabel",{"propertyChange":true},[param4[34],param4[35]],param2);
         param5[40] = new PropertyWatcher("y",{"yChanged":true},[param4[35]],null);
         param5[39] = new PropertyWatcher("x",{"xChanged":true},[param4[34]],null);
         param5[21] = new PropertyWatcher("sdChamferDia",{"propertyChange":true},[param4[20],param4[21]],param2);
         param5[23] = new PropertyWatcher("y",{"yChanged":true},[param4[21]],null);
         param5[22] = new PropertyWatcher("x",{"xChanged":true},[param4[20]],null);
         param5[5] = new PropertyWatcher("cdChamferDia",{"propertyChange":true},[param4[4],param4[5]],param2);
         param5[7] = new PropertyWatcher("y",{"yChanged":true},[param4[5]],null);
         param5[6] = new PropertyWatcher("x",{"xChanged":true},[param4[4]],null);
         param5[41] = new PropertyWatcher("csAngle",{"propertyChange":true},[param4[36],param4[37]],param2);
         param5[43] = new PropertyWatcher("y",{"yChanged":true},[param4[37]],null);
         param5[42] = new PropertyWatcher("x",{"xChanged":true},[param4[36]],null);
         param5[3] = new StaticPropertyWatcher("gray4",{"propertyChange":true},[param4[2]],null);
         param5[27] = new PropertyWatcher("sdMaxChamfer",{"propertyChange":true},[param4[24],param4[25],param4[26],param4[27],param4[28],param4[29]],param2);
         param5[29] = new PropertyWatcher("y",{"yChanged":true},[param4[25],param4[27],param4[29]],null);
         param5[28] = new PropertyWatcher("x",{"xChanged":true},[param4[24],param4[26],param4[28]],null);
         param5[1] = new PropertyWatcher("tabs",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new PropertyWatcher("height",{"heightChanged":true},[param4[1]],null);
         param5[30].updateParent(param1);
         param5[30].addChild(param5[32]);
         param5[32].addChild(param5[33]);
         param5[30].addChild(param5[34]);
         param5[30].addChild(param5[31]);
         param5[44].updateParent(param1);
         param5[44].addChild(param5[46]);
         param5[44].addChild(param5[45]);
         param5[24].updateParent(param1);
         param5[24].addChild(param5[26]);
         param5[24].addChild(param5[25]);
         param5[15].updateParent(param1);
         param5[15].addChild(param5[17]);
         param5[15].addChild(param5[16]);
         param5[35].updateParent(param1);
         param5[35].addChild(param5[37]);
         param5[35].addChild(param5[36]);
         param5[47].updateParent(param1);
         param5[47].addChild(param5[49]);
         param5[47].addChild(param5[50]);
         param5[47].addChild(param5[48]);
         param5[4].updateParent(GWizConfigData);
         param5[8].updateParent(param1);
         param5[8].addChild(param5[10]);
         param5[8].addChild(param5[11]);
         param5[8].addChild(param5[9]);
         param5[12].updateParent(param1);
         param5[12].addChild(param5[14]);
         param5[12].addChild(param5[13]);
         param5[0].updateParent(param1);
         param5[18].updateParent(param1);
         param5[18].addChild(param5[20]);
         param5[18].addChild(param5[19]);
         param5[51].updateParent(param1);
         param5[51].addChild(param5[53]);
         param5[51].addChild(param5[52]);
         param5[38].updateParent(param1);
         param5[38].addChild(param5[40]);
         param5[38].addChild(param5[39]);
         param5[21].updateParent(param1);
         param5[21].addChild(param5[23]);
         param5[21].addChild(param5[22]);
         param5[5].updateParent(param1);
         param5[5].addChild(param5[7]);
         param5[5].addChild(param5[6]);
         param5[41].updateParent(param1);
         param5[41].addChild(param5[43]);
         param5[41].addChild(param5[42]);
         param5[3].updateParent(ColorPalette);
         param5[27].updateParent(param1);
         param5[27].addChild(param5[29]);
         param5[27].addChild(param5[28]);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
      }
   }
}
