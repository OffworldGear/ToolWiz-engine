package
{
   import feedsspeeds.GWizFSCheatSheet;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizFSCheatSheetWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizFSCheatSheetWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizFSCheatSheet.watcherSetupUtil = new _feedsspeeds_GWizFSCheatSheetWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new StaticPropertyWatcher("Cheats",{"propertyChange":true},[param4[1]],param3);
         param5[0] = new PropertyWatcher("labelBackgroundColor",{"propertyChange":true},[param4[0]],param2);
         param5[1].updateParent(GWizFSCheatSheet);
         param5[0].updateParent(param1);
      }
   }
}
