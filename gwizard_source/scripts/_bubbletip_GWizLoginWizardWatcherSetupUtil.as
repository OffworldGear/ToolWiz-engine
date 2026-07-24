package
{
   import bubbletip.GWizLoginWizard;
   import login.GWizCredentials;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _bubbletip_GWizLoginWizardWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _bubbletip_GWizLoginWizardWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizLoginWizard.watcherSetupUtil = new _bubbletip_GWizLoginWizardWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("credStatus",{"propertyChange":true},[param4[0]],null);
         param5[1] = new StaticPropertyWatcher("gray1",{"propertyChange":true},[param4[1],param4[2],param4[4],param4[6],param4[7]],null);
         param5[0].updateParent(GWizCredentials);
         param5[1].updateParent(ColorPalette);
      }
   }
}
