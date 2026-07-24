package
{
   import feedsspeeds.GWizCutType;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizCutTypeWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizCutTypeWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCutType.watcherSetupUtil = new _feedsspeeds_GWizCutTypeWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("CutTypes",{"propertyChange":true},[param4[0]],param3);
         param5[1] = new StaticPropertyWatcher("finishTypes",{"propertyChange":true},[param4[1]],param3);
         param5[0].updateParent(GWizCutType);
         param5[1].updateParent(GWizCutType);
      }
   }
}
