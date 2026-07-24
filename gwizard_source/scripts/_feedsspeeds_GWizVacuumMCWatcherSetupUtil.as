package
{
   import feedsspeeds.GWizVacuumMC;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizVacuumMCWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizVacuumMCWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizVacuumMC.watcherSetupUtil = new _feedsspeeds_GWizVacuumMCWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("vacuum",{"propertyChange":true},[param4[0],param4[1],param4[2],param4[7],param4[8],param4[9],param4[10],param4[11],param4[12]],param2);
         param5[1] = new PropertyWatcher("height",{"heightChanged":true},[param4[0],param4[1],param4[2],param4[7],param4[8],param4[9],param4[10],param4[11],param4[12]],null);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
      }
   }
}
