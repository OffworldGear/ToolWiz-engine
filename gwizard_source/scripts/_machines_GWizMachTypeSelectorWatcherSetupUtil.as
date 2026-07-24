package
{
   import machines.GWizMachTypeSelector;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _machines_GWizMachTypeSelectorWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _machines_GWizMachTypeSelectorWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizMachTypeSelector.watcherSetupUtil = new _machines_GWizMachTypeSelectorWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("MachineTypes",{"propertyChange":true},[param4[0]],param3);
         param5[0].updateParent(GWizMachTypeSelector);
      }
   }
}
