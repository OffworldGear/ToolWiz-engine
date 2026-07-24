package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import post.GWizPostFileBrowser;
   
   public class _post_GWizPostFileBrowserWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _post_GWizPostFileBrowserWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizPostFileBrowser.watcherSetupUtil = new _post_GWizPostFileBrowserWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("posts",{"propertyChange":true},[param4[1]],param3);
         param5[0].updateParent(GWizPostFileBrowser);
      }
   }
}
