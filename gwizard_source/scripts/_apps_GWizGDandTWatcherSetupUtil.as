package
{
   import apps.GWizGDandT;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _apps_GWizGDandTWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizGDandTWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizGDandT.watcherSetupUtil = new _apps_GWizGDandTWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[8] = new PropertyWatcher("FlatnessVGroup",{"propertyChange":true},[param4[12]],param2);
         param5[9] = new PropertyWatcher("height",{"heightChanged":true},[param4[12]],null);
         param5[16] = new PropertyWatcher("RunoutVGroup",{"propertyChange":true},[param4[53]],param2);
         param5[17] = new PropertyWatcher("height",{"heightChanged":true},[param4[53]],null);
         param5[6] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[5],param4[20],param4[33],param4[46],param4[55]],null);
         param5[3] = new PropertyWatcher("Col2Widest",{"propertyChange":true},[param4[3],param4[6],param4[9],param4[15],param4[21],param4[24],param4[27],param4[34],param4[37],param4[40],param4[47],param4[50],param4[56],param4[59]],param2);
         param5[4] = new PropertyWatcher("width",{"widthChanged":true},[param4[3],param4[6],param4[9],param4[15],param4[21],param4[24],param4[27],param4[34],param4[37],param4[40],param4[47],param4[50],param4[56],param4[59]],null);
         param5[10] = new PropertyWatcher("CircularityVGroup",{"propertyChange":true},[param4[18]],param2);
         param5[11] = new PropertyWatcher("height",{"heightChanged":true},[param4[18]],null);
         param5[18] = new PropertyWatcher("ConcentricityVGroup",{"propertyChange":true},[param4[62]],param2);
         param5[19] = new PropertyWatcher("height",{"heightChanged":true},[param4[62]],null);
         param5[2] = new PropertyWatcher("height",{"heightChanged":true},[param4[2]],param2);
         param5[14] = new PropertyWatcher("PositionVGroup",{"propertyChange":true},[param4[44]],param2);
         param5[15] = new PropertyWatcher("height",{"heightChanged":true},[param4[44]],null);
         param5[5] = new StaticPropertyWatcher("alternateb3",{"propertyChange":true},[param4[4],param4[19],param4[32],param4[45],param4[54]],null);
         param5[12] = new PropertyWatcher("PerpendicularityVGroup",{"propertyChange":true},[param4[31]],param2);
         param5[13] = new PropertyWatcher("height",{"heightChanged":true},[param4[31]],null);
         param5[0] = new StaticPropertyWatcher("gray5",{"propertyChange":true},[param4[0]],null);
         param5[1] = new StaticPropertyWatcher("gray3",{"propertyChange":true},[param4[1]],null);
         param5[8].updateParent(param1);
         param5[8].addChild(param5[9]);
         param5[16].updateParent(param1);
         param5[16].addChild(param5[17]);
         param5[6].updateParent(ColorPalette);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[4]);
         param5[10].updateParent(param1);
         param5[10].addChild(param5[11]);
         param5[18].updateParent(param1);
         param5[18].addChild(param5[19]);
         param5[2].updateParent(param1);
         param5[14].updateParent(param1);
         param5[14].addChild(param5[15]);
         param5[5].updateParent(ColorPalette);
         param5[12].updateParent(param1);
         param5[12].addChild(param5[13]);
         param5[0].updateParent(ColorPalette);
         param5[1].updateParent(ColorPalette);
      }
   }
}
