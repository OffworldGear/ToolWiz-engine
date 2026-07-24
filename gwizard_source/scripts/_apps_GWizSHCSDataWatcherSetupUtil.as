package
{
   import apps.GWizSHCSData;
   import configinfo.GWizFastenerData;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _apps_GWizSHCSDataWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizSHCSDataWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizSHCSData.watcherSetupUtil = new _apps_GWizSHCSDataWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[2] = new StaticPropertyWatcher("SHCSData",{"propertyChange":true},[param4[2]],null);
         param5[1] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[1],param4[4]],null);
         param5[0] = new StaticPropertyWatcher("alternateb3",{"propertyChange":true},[param4[0]],null);
         param5[3] = new StaticPropertyWatcher("alternateb4",{"propertyChange":true},[param4[3]],null);
         param5[2].updateParent(GWizFastenerData);
         param5[1].updateParent(ColorPalette);
         param5[0].updateParent(ColorPalette);
         param5[3].updateParent(ColorPalette);
      }
   }
}
