package
{
   import apps.GWizHardness;
   import material.GWizMaterialsDB;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _apps_GWizHardnessWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizHardnessWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizHardness.watcherSetupUtil = new _apps_GWizHardnessWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[1]],null);
         param5[0] = new StaticPropertyWatcher("alternateb4",{"propertyChange":true},[param4[0]],null);
         param5[2] = new StaticPropertyWatcher("HardnessConv",{"propertyChange":true},[param4[2]],null);
         param5[1].updateParent(ColorPalette);
         param5[0].updateParent(ColorPalette);
         param5[2].updateParent(GWizMaterialsDB);
      }
   }
}
