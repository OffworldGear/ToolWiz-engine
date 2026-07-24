package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizDrillChart;
   
   public class _tools_GWizDrillChartWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizDrillChartWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizDrillChart.watcherSetupUtil = new _tools_GWizDrillChartWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("drillData",{"propertyChange":true},[param4[4]],param2);
         param5[0] = new PropertyWatcher("topLineColor",{"propertyChange":true},[param4[0],param4[1],param4[2],param4[3]],param2);
         param5[1].updateParent(param1);
         param5[0].updateParent(param1);
      }
   }
}
