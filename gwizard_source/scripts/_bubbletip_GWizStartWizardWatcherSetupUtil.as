package
{
   import bubbletip.GWizStartWizard;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   
   public class _bubbletip_GWizStartWizardWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _bubbletip_GWizStartWizardWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizStartWizard.watcherSetupUtil = new _bubbletip_GWizStartWizardWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
      }
   }
}
