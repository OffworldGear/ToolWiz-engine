package
{
   import cadcamwiz.GWizCCW2DProfileInputs;
   import cadcamwiz.GWizCCWEstimatorInput;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCW2DProfileInputsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCW2DProfileInputsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCW2DProfileInputs.watcherSetupUtil = new _cadcamwiz_GWizCCW2DProfileInputsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[2] = new PropertyWatcher("EstimatorInputs",{"propertyChange":true},[param4[2],param4[3]],param2);
         param5[3] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[2],param4[3]],null);
         param5[1] = new StaticPropertyWatcher("addEstimatorItem",{"propertyChange":true},[param4[1]],null);
         param5[0] = new PropertyWatcher("recalc",{"propertyChange":true},[param4[0]],param2);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
         param5[1].updateParent(GWizCCWEstimatorInput);
         param5[0].updateParent(param1);
      }
   }
}
