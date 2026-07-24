package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizCribOptions;
   import utils.ColorPalette;
   
   public class _tools_GWizCribOptionsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizCribOptionsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCribOptions.watcherSetupUtil = new _tools_GWizCribOptionsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new StaticPropertyWatcher("primary5",{"propertyChange":true},[param4[1]],null);
         param5[2] = new StaticPropertyWatcher("TableTypes",{"propertyChange":true},[param4[2]],param3);
         param5[0] = new StaticPropertyWatcher("primary3",{"propertyChange":true},[param4[0]],null);
         param5[1].updateParent(ColorPalette);
         param5[2].updateParent(GWizCribOptions);
         param5[0].updateParent(ColorPalette);
      }
   }
}
