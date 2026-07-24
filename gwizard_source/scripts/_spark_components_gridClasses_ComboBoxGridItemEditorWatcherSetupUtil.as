package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import spark.components.gridClasses.ComboBoxGridItemEditor;
   
   public class _spark_components_gridClasses_ComboBoxGridItemEditorWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _spark_components_gridClasses_ComboBoxGridItemEditorWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         ComboBoxGridItemEditor.watcherSetupUtil = new _spark_components_gridClasses_ComboBoxGridItemEditorWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("dataProvider",{"comboBoxGridItemEditorDataProviderChanged":true},[param4[0]],param2);
         param5[0].updateParent(param1);
      }
   }
}
