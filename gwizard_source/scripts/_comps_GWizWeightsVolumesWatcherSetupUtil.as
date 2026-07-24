package
{
   import comps.GWizWeightsVolumes;
   import material.GWizMaterialsDB;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _comps_GWizWeightsVolumesWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizWeightsVolumesWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizWeightsVolumes.watcherSetupUtil = new _comps_GWizWeightsVolumesWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[1],param4[4],param4[7]],null);
         param5[4] = new PropertyWatcher("wFeet",{"propertyChange":true},[param4[8]],param2);
         param5[5] = new PropertyWatcher("width",{"widthChanged":true},[param4[8]],null);
         param5[0] = new StaticPropertyWatcher("alternateb4",{"propertyChange":true},[param4[0],param4[3],param4[6]],null);
         param5[7] = new PropertyWatcher("DescEdit",{"propertyChange":true},[param4[11]],param2);
         param5[8] = new PropertyWatcher("selected",{"propertyChange":true},[param4[11]],null);
         param5[6] = new StaticPropertyWatcher("appIsEstimator",{"propertyChange":true},[param4[9],param4[10],param4[12],param4[13]],param3);
         param5[3] = new StaticPropertyWatcher("FabricationsList",{"propertyChange":true},[param4[5]],null);
         param5[2] = new StaticPropertyWatcher("gray2",{"propertyChange":true},[param4[2]],null);
         param5[1].updateParent(ColorPalette);
         param5[4].updateParent(param1);
         param5[4].addChild(param5[5]);
         param5[0].updateParent(ColorPalette);
         param5[7].updateParent(param1);
         param5[7].addChild(param5[8]);
         param5[6].updateParent(GWizWeightsVolumes);
         param5[3].updateParent(GWizMaterialsDB);
         param5[2].updateParent(ColorPalette);
      }
   }
}
