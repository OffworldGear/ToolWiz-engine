package
{
   import configinfo.GWizLatheTools;
   import feedsspeeds.GWizTurningCutDepthMC;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizTurningCutDepthMCWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizTurningCutDepthMCWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizTurningCutDepthMC.watcherSetupUtil = new _feedsspeeds_GWizTurningCutDepthMCWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[2] = new StaticPropertyWatcher("cutTypes",{"propertyChange":true},[param4[2]],null);
         param5[1] = new StaticPropertyWatcher("insSizes",{"propertyChange":true},[param4[1]],null);
         param5[0] = new StaticPropertyWatcher("insTypes",{"propertyChange":true},[param4[0]],null);
         param5[2].updateParent(GWizLatheTools);
         param5[1].updateParent(GWizLatheTools);
         param5[0].updateParent(GWizLatheTools);
      }
   }
}
