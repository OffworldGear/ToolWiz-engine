package
{
   import cadcamwiz.GWizCCPocketInputs;
   import cadcamwiz.GWizCCWEstimatorInput;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCPocketInputsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCPocketInputsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCPocketInputs.watcherSetupUtil = new _cadcamwiz_GWizCCPocketInputsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[4] = new PropertyWatcher("Perimeter",{"propertyChange":true},[param4[4]],param2);
         param5[5] = new PropertyWatcher("theLabel",{"propertyChange":true},[param4[4]],null);
         param5[6] = new PropertyWatcher("width",{"widthChanged":true},[param4[4]],null);
         param5[2] = new PropertyWatcher("EstimatorInputs",{"propertyChange":true},[param4[3],param4[5]],param2);
         param5[3] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[3],param4[5]],null);
         param5[1] = new StaticPropertyWatcher("addEstimatorItem",{"propertyChange":true},[param4[2]],null);
         param5[0] = new PropertyWatcher("recalc",{"propertyChange":true},[param4[0],param4[1]],param2);
         param5[4].updateParent(param1);
         param5[4].addChild(param5[5]);
         param5[5].addChild(param5[6]);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
         param5[1].updateParent(GWizCCWEstimatorInput);
         param5[0].updateParent(param1);
      }
   }
}
