package
{
   import comps.GWizDataGridSettingsInnerClass2;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizDataGridSettingsInnerClass2WatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizDataGridSettingsInnerClass2WatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizDataGridSettingsInnerClass2.watcherSetupUtil = new _comps_GWizDataGridSettingsInnerClass2WatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("data",{"dataChange":true},[param4[0],param4[1]],param2);
         param5[2] = new PropertyWatcher("sortDescending",null,[param4[0],param4[1]],null);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
      }
   }
}
