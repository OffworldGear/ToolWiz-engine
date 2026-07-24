package
{
   import comps.GWizDataGridSettingsInnerClass0;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizDataGridSettingsInnerClass0WatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizDataGridSettingsInnerClass0WatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizDataGridSettingsInnerClass0.watcherSetupUtil = new _comps_GWizDataGridSettingsInnerClass0WatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("data",{"dataChange":true},[param4[0],param4[1]],param2);
         param5[1] = new PropertyWatcher("visible",null,[param4[0],param4[1]],null);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
      }
   }
}
