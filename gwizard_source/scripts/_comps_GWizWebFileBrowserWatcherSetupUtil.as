package
{
   import comps.GWizWebFileBrowser;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizWebFileBrowserWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizWebFileBrowserWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizWebFileBrowser.watcherSetupUtil = new _comps_GWizWebFileBrowserWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("localFiles",{"propertyChange":true},[param4[0]],param2);
         param5[0].updateParent(param1);
      }
   }
}
