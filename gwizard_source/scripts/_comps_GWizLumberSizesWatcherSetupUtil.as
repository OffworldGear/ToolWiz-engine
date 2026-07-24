package
{
   import comps.GWizLumberSizes;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizLumberSizesWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizLumberSizesWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizLumberSizes.watcherSetupUtil = new _comps_GWizLumberSizesWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("LumberSizes",{"propertyChange":true},[param4[0]],param3);
         param5[0].updateParent(GWizLumberSizes);
      }
   }
}
