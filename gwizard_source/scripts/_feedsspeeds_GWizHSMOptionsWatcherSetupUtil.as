package
{
   import configinfo.GWizSettings;
   import feedsspeeds.GWizHSMOptions;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizHSMOptionsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizHSMOptionsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizHSMOptions.watcherSetupUtil = new _feedsspeeds_GWizHSMOptionsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("hsmWidthPct",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(GWizSettings);
      }
   }
}
