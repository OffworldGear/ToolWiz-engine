package
{
   import material.GWizMatBrowser2;
   import material.GWizMaterialsDB;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _material_GWizMatBrowser2WatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _material_GWizMatBrowser2WatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizMatBrowser2.watcherSetupUtil = new _material_GWizMatBrowser2WatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("MaterialsListAC",{"propertyChange":true},[param4[0]],null);
         param5[2] = new StaticPropertyWatcher("MaterialHistory",{"propertyChange":true},[param4[2]],param3);
         param5[1] = new StaticPropertyWatcher("AlloyConditionList",{"propertyChange":true},[param4[1]],null);
         param5[0].updateParent(GWizMaterialsDB);
         param5[2].updateParent(GWizMatBrowser2);
         param5[1].updateParent(GWizMaterialsDB);
      }
   }
}
