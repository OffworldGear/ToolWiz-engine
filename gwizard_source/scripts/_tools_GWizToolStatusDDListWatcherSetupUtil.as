package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizToolCribEntry;
   import tools.GWizToolStatusDDList;
   
   public class _tools_GWizToolStatusDDListWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizToolStatusDDListWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizToolStatusDDList.watcherSetupUtil = new _tools_GWizToolStatusDDListWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("toolStatusValues",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(GWizToolCribEntry);
      }
   }
}
