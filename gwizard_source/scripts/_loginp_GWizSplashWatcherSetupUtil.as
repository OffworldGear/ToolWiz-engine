package
{
   import configinfo.GWizAbstractPrefs;
   import loginp.GWizSplash;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _loginp_GWizSplashWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _loginp_GWizSplashWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizSplash.watcherSetupUtil = new _loginp_GWizSplashWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("madeByStr",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(GWizAbstractPrefs);
      }
   }
}
