package
{
   import apps.GWizSetupApp;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _apps_GWizSetupAppWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizSetupAppWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizSetupApp.watcherSetupUtil = new _apps_GWizSetupAppWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[4] = new PropertyWatcher("tabNav",{"propertyChange":true},[param4[7]],param2);
         param5[5] = new StaticPropertyWatcher("gray5",{"propertyChange":true},[param4[9]],null);
         param5[2] = new StaticPropertyWatcher("gray1",{"propertyChange":true},[param4[1],param4[2],param4[3],param4[4],param4[5],param4[8]],null);
         param5[3] = new PropertyWatcher("logoImg",{"propertyChange":true},[param4[6]],param2);
         param5[0] = new PropertyWatcher("tabs",{"propertyChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("height",{"heightChanged":true},[param4[0]],null);
         param5[4].updateParent(param1);
         param5[5].updateParent(ColorPalette);
         param5[2].updateParent(ColorPalette);
         param5[3].updateParent(param1);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
      }
   }
}
