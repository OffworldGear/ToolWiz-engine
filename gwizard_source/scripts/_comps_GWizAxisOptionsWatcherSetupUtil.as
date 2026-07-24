package
{
   import comps.GWizAxisOptions;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizAxisOptionsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizAxisOptionsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizAxisOptions.watcherSetupUtil = new _comps_GWizAxisOptionsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("fourthAxes",{"propertyChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("parallelAxes",{"propertyChange":true},[param4[1]],param2);
         param5[0].updateParent(param1);
         param5[1].updateParent(param1);
      }
   }
}
