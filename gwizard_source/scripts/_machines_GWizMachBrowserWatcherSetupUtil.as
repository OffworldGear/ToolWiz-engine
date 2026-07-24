package
{
   import machines.GWizMachBrowser;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _machines_GWizMachBrowserWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _machines_GWizMachBrowserWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizMachBrowser.watcherSetupUtil = new _machines_GWizMachBrowserWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[3] = new PropertyWatcher("myShopProvider",{"propertyChange":true},[param4[3]],param2);
         param5[5] = new PropertyWatcher("makes",{"propertyChange":true},[param4[7]],param2);
         param5[0] = new PropertyWatcher("modeSelector",{"propertyChange":true},[param4[0]],param2);
         param5[2] = new StaticPropertyWatcher("primary1",{"propertyChange":true},[param4[2],param4[6]],null);
         param5[4] = new PropertyWatcher("lockSafe",{"propertyChange":true},[param4[4],param4[5],param4[9]],param2);
         param5[1] = new StaticPropertyWatcher("primary4",{"propertyChange":true},[param4[1]],null);
         param5[6] = new PropertyWatcher("machProvider",{"propertyChange":true},[param4[8]],param2);
         param5[3].updateParent(param1);
         param5[5].updateParent(param1);
         param5[0].updateParent(param1);
         param5[2].updateParent(ColorPalette);
         param5[4].updateParent(param1);
         param5[1].updateParent(ColorPalette);
         param5[6].updateParent(param1);
      }
   }
}
