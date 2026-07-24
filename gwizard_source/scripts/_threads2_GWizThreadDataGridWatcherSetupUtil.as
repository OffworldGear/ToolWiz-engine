package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import threads2.GWizThreadDataGrid;
   
   public class _threads2_GWizThreadDataGridWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _threads2_GWizThreadDataGridWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizThreadDataGrid.watcherSetupUtil = new _threads2_GWizThreadDataGridWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("dataField",{"propertyChange":true},[param4[0]],param2);
         param5[0].updateParent(param1);
      }
   }
}
