package
{
   import comps.GWizDebugLogReader;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.GWizUtils;
   
   public class _comps_GWizDebugLogReaderWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizDebugLogReaderWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizDebugLogReader.watcherSetupUtil = new _comps_GWizDebugLogReaderWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("errorLog",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(GWizUtils);
      }
   }
}
