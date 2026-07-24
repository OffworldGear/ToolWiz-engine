package
{
   import comps.GWizImperialMetric;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.GWizUtils;
   
   public class _comps_GWizImperialMetricWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizImperialMetricWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizImperialMetric.watcherSetupUtil = new _comps_GWizImperialMetricWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("Units",{"propertyChange":true},[param4[1],param4[2]],null);
         param5[2] = new PropertyWatcher("unitsText",{"propertyChange":true},[param4[3]],param2);
         param5[0].updateParent(GWizUtils);
         param5[2].updateParent(param1);
      }
   }
}
