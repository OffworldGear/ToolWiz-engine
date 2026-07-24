package
{
   import cadcamwiz.GWizCadCam;
   import cadcamwizp.GWizCadCamD;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _cadcamwizp_GWizCadCamDWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwizp_GWizCadCamDWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCadCamD.watcherSetupUtil = new _cadcamwizp_GWizCadCamDWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[2] = new PropertyWatcher("mmsCCW",{"propertyChange":true},[param4[4],param4[5]],param2);
         param5[3] = new PropertyWatcher("height",{"heightChanged":true},[param4[4],param4[5]],null);
         param5[0] = new PropertyWatcher("width",{"widthChanged":true},[param4[0],param4[1],param4[2]],param2);
         param5[10] = new StaticPropertyWatcher("secondarya2",{"propertyChange":true},[param4[9],param4[11]],null);
         param5[9] = new PropertyWatcher("tabNav",{"propertyChange":true},[param4[8]],param2);
         param5[11] = new StaticPropertyWatcher("secondarya4",{"propertyChange":true},[param4[10]],null);
         param5[6] = new StaticPropertyWatcher("_needRecalc",{"propertyChange":true},[param4[7]],null);
         param5[1] = new PropertyWatcher("nativeWin",{"propertyChange":true},[param4[3]],param2);
         param5[4] = new PropertyWatcher("OptionsBtn",{"propertyChange":true},[param4[6]],param2);
         param5[5] = new PropertyWatcher("width",{"widthChanged":true},[param4[6]],null);
         param5[12] = new PropertyWatcher("tabs",{"propertyChange":true},[param4[12]],param2);
         param5[13] = new PropertyWatcher("height",{"heightChanged":true},[param4[12]],null);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
         param5[0].updateParent(param1);
         param5[10].updateParent(ColorPalette);
         param5[9].updateParent(param1);
         param5[11].updateParent(ColorPalette);
         param5[6].updateParent(GWizCadCam);
         param5[1].updateParent(param1);
         param5[4].updateParent(param1);
         param5[4].addChild(param5[5]);
         param5[12].updateParent(param1);
         param5[12].addChild(param5[13]);
      }
   }
}
