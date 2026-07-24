package
{
   import apps.GWizCalculator;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _apps_GWizCalculatorWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizCalculatorWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCalculator.watcherSetupUtil = new _apps_GWizCalculatorWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[5] = new PropertyWatcher("clearLabel",{"propertyChange":true},[param4[5]],param2);
         param5[6] = new PropertyWatcher("featureStack",{"propertyChange":true},[param4[6]],param2);
         param5[7] = new PropertyWatcher("c1",{"propertyChange":true},[param4[7]],param2);
         param5[2] = new PropertyWatcher("cfDisplay",{"propertyChange":true},[param4[1]],param2);
         param5[0] = new PropertyWatcher("CalcDisplay",{"propertyChange":true},[param4[0],param4[4],param4[12]],param2);
         param5[1] = new PropertyWatcher("text",{
            "change":true,
            "textChanged":true
         },[param4[0]],null);
         param5[8] = new PropertyWatcher("c2",{"propertyChange":true},[param4[8]],param2);
         param5[3] = new PropertyWatcher("detachImg",{"propertyChange":true},[param4[2]],param2);
         param5[4] = new PropertyWatcher("cfQueuedOp",{"propertyChange":true},[param4[3]],param2);
         param5[9] = new PropertyWatcher("m1",{"propertyChange":true},[param4[9]],param2);
         param5[10] = new PropertyWatcher("m2",{"propertyChange":true},[param4[10]],param2);
         param5[5].updateParent(param1);
         param5[6].updateParent(param1);
         param5[7].updateParent(param1);
         param5[2].updateParent(param1);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
         param5[8].updateParent(param1);
         param5[3].updateParent(param1);
         param5[4].updateParent(param1);
         param5[9].updateParent(param1);
         param5[10].updateParent(param1);
      }
   }
}
