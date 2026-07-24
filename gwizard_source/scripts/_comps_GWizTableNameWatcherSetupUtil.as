package
{
   import comps.GWizTableName;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizTableNameWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizTableNameWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizTableName.watcherSetupUtil = new _comps_GWizTableNameWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("str",{"propertyChange":true},[param4[1]],param2);
         param5[0] = new PropertyWatcher("prompt",{"propertyChange":true},[param4[0]],param2);
         param5[1].updateParent(param1);
         param5[0].updateParent(param1);
      }
   }
}
