package
{
   import configinfo.GWizConfigData;
   import feedsspeeds.GWizSurfaceFinishLathe;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizSurfaceFinishLatheWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizSurfaceFinishLatheWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizSurfaceFinishLathe.watcherSetupUtil = new _feedsspeeds_GWizSurfaceFinishLatheWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("InsertNoseRadiusList",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(GWizConfigData);
      }
   }
}
