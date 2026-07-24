package
{
   import configinfo.GWizAbstractPrefs;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import threads2.GWizAbstractThreadEngine;
   import threads2.GWizThreadCalcBanner;
   
   public class _threads2_GWizThreadCalcBannerWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _threads2_GWizThreadCalcBannerWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizThreadCalcBanner.watcherSetupUtil = new _threads2_GWizThreadCalcBannerWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("hasExternalThreads",{"propertyChange":true},[param4[0]],null);
         param5[1] = new PropertyWatcher("threadSelector",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new StaticPropertyWatcher("ThreadCalcEnabled",{"propertyChange":true},[param4[2]],null);
         param5[0].updateParent(GWizAbstractThreadEngine);
         param5[1].updateParent(param1);
         param5[2].updateParent(GWizAbstractPrefs);
      }
   }
}
