package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import views.GWizFitsTolerances;
   
   public class _views_GWizFitsTolerancesWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizFitsTolerancesWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizFitsTolerances.watcherSetupUtil = new _views_GWizFitsTolerancesWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[2] = new StaticPropertyWatcher("shaftClasses",{"propertyChange":true},[param4[2]],param3);
         param5[1] = new StaticPropertyWatcher("holeClasses",{"propertyChange":true},[param4[1]],param3);
         param5[0] = new StaticPropertyWatcher("fitTypes",{"propertyChange":true},[param4[0]],param3);
         param5[2].updateParent(GWizFitsTolerances);
         param5[1].updateParent(GWizFitsTolerances);
         param5[0].updateParent(GWizFitsTolerances);
      }
   }
}
