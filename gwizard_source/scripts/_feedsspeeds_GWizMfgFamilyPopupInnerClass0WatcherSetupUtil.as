package
{
   import feedsspeeds.GWizMfgFamilyPopupInnerClass0;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizMfgFamilyPopupInnerClass0WatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizMfgFamilyPopupInnerClass0WatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizMfgFamilyPopupInnerClass0.watcherSetupUtil = new _feedsspeeds_GWizMfgFamilyPopupInnerClass0WatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("outerDocument",{"propertyChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("matList",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
      }
   }
}
