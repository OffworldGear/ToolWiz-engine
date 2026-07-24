package
{
   import comps.GWizDataGridSettingsInnerClass1;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizDataGridSettingsInnerClass1WatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizDataGridSettingsInnerClass1WatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizDataGridSettingsInnerClass1.watcherSetupUtil = new _comps_GWizDataGridSettingsInnerClass1WatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("data",{"dataChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("headerText",null,[param4[0]],null);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
      }
   }
}
