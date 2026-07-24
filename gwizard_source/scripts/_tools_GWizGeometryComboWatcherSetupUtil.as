package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizGeometryCombo;
   import tools.GWizToolData;
   
   public class _tools_GWizGeometryComboWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizGeometryComboWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizGeometryCombo.watcherSetupUtil = new _tools_GWizGeometryComboWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("geometryTypes",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(GWizToolData);
      }
   }
}
