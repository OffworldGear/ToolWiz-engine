package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizToolCribEntry;
   import tools.GWizToolHolderDDList;
   
   public class _tools_GWizToolHolderDDListWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizToolHolderDDListWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizToolHolderDDList.watcherSetupUtil = new _tools_GWizToolHolderDDListWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("toolHolderTypes",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(GWizToolCribEntry);
      }
   }
}
