package
{
   import comps.GWizTaperPicker;
   import configinfo.GWizConfigData;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizTaperPickerWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizTaperPickerWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizTaperPicker.watcherSetupUtil = new _comps_GWizTaperPickerWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("StandardTaperList",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(GWizConfigData);
      }
   }
}
