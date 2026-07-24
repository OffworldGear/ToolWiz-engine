package
{
   import machines.GWizMachSelector;
   import machines.GWizMachSettings;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _machines_GWizMachSelectorWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _machines_GWizMachSelectorWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizMachSelector.watcherSetupUtil = new _machines_GWizMachSelectorWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("MachinesList",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(GWizMachSettings);
      }
   }
}
