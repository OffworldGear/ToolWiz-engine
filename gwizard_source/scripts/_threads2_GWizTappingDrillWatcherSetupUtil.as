package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import threads2.GWizAbstractThreadEngine;
   import threads2.GWizTappingDrill;
   
   public class _threads2_GWizTappingDrillWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _threads2_GWizTappingDrillWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizTappingDrill.watcherSetupUtil = new _threads2_GWizTappingDrillWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[0],param4[1]],param2);
         param5[1] = new StaticPropertyWatcher("tapDrillList",{"propertyChange":true},[param4[2]],null);
         param5[2] = new PropertyWatcher("threadPctGrid",{"propertyChange":true},[param4[3]],param2);
         param5[3] = new PropertyWatcher("width",{"widthChanged":true},[param4[3]],null);
         param5[0].updateParent(param1);
         param5[1].updateParent(GWizAbstractThreadEngine);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
      }
   }
}
