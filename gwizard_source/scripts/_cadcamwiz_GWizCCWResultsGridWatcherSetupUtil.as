package
{
   import cadcamwiz.GWizCCWResultsGrid;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCWResultsGridWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWResultsGridWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWResultsGrid.watcherSetupUtil = new _cadcamwiz_GWizCCWResultsGridWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("results",{"propertyChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("showEntry",{"propertyChange":true},[param4[1],param4[2]],param2);
         param5[0].updateParent(param1);
         param5[1].updateParent(param1);
      }
   }
}
