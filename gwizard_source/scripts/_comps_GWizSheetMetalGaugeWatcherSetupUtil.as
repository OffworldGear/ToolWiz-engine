package
{
   import comps.GWizSheetMetalGauge;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizSheetMetalGaugeWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizSheetMetalGaugeWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizSheetMetalGauge.watcherSetupUtil = new _comps_GWizSheetMetalGaugeWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("SheetMetalGauges",{"propertyChange":true},[param4[0]],param3);
         param5[0].updateParent(GWizSheetMetalGauge);
      }
   }
}
