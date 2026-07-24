package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizPropertyList;
   
   public class _tools_GWizPropertyListWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizPropertyListWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizPropertyList.watcherSetupUtil = new _tools_GWizPropertyListWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("propertyList",{"propertyChange":true},[param4[0]],param2);
         param5[0].updateParent(param1);
      }
   }
}
