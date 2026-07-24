package
{
   import cadcamwiz.GWizCCWEstimatorInput;
   import cadcamwiz.GWizCCWIDTurnInputs;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCWIDTurnInputsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWIDTurnInputsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWIDTurnInputs.watcherSetupUtil = new _cadcamwiz_GWizCCWIDTurnInputsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("EstimatorInputs",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[1]],null);
         param5[0] = new StaticPropertyWatcher("addEstimatorItem",{"propertyChange":true},[param4[0]],null);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
         param5[0].updateParent(GWizCCWEstimatorInput);
      }
   }
}
