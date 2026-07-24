package
{
   import configinfo.GWizSharedPrefs;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _configinfo_GWizSharedPrefsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _configinfo_GWizSharedPrefsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizSharedPrefs.watcherSetupUtil = new _configinfo_GWizSharedPrefsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("labelWidth",{"propertyChange":true},[param4[1]],param2);
         param5[0] = new PropertyWatcher("showSharing",{"propertyChange":true},[param4[0]],param2);
         param5[1].updateParent(param1);
         param5[0].updateParent(param1);
      }
   }
}
