package
{
   import cadcamwiz.GWizCCWEstimatorInput;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCWEstimatorInputWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWEstimatorInputWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWEstimatorInput.watcherSetupUtil = new _cadcamwiz_GWizCCWEstimatorInputWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("Qty",{"propertyChange":true},[param4[2]],param2);
         param5[2] = new PropertyWatcher("height",{"heightChanged":true},[param4[2]],null);
         param5[0] = new StaticPropertyWatcher("addEstimatorItem",{"propertyChange":true},[param4[0],param4[1]],param3);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
         param5[0].updateParent(GWizCCWEstimatorInput);
      }
   }
}
