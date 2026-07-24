package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizOpSelector;
   
   public class _tools_GWizOpSelectorWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizOpSelectorWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizOpSelector.watcherSetupUtil = new _tools_GWizOpSelectorWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("filtered",{"propertyChange":true},[param4[1]],param3);
         param5[0].updateParent(GWizOpSelector);
      }
   }
}
