package
{
   import apps.GWizThermalExp;
   import configinfo.GWizConfigData;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _apps_GWizThermalExpWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizThermalExpWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizThermalExp.watcherSetupUtil = new _apps_GWizThermalExpWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new StaticPropertyWatcher("alternateb3",{"propertyChange":true},[param4[1],param4[2],param4[7],param4[9],param4[13]],null);
         param5[0] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[0],param4[3],param4[6],param4[8],param4[10],param4[14]],null);
         param5[3] = new StaticPropertyWatcher("alternateb4",{"propertyChange":true},[param4[5]],null);
         param5[6] = new StaticPropertyWatcher("secondaryb1",{"propertyChange":true},[param4[15],param4[16]],null);
         param5[2] = new StaticPropertyWatcher("MachinabilityFactors",{"propertyChange":true},[param4[4]],null);
         param5[1].updateParent(ColorPalette);
         param5[0].updateParent(ColorPalette);
         param5[3].updateParent(ColorPalette);
         param5[6].updateParent(ColorPalette);
         param5[2].updateParent(GWizConfigData);
      }
   }
}
