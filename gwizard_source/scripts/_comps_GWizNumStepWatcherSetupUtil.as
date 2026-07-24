package
{
   import comps.GWizNumStep;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizNumStepWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizNumStepWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizNumStep.watcherSetupUtil = new _comps_GWizNumStepWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[4] = new PropertyWatcher("stepBySizes",{"propertyChange":true},[param4[4]],param2);
         param5[2] = new PropertyWatcher("min",{"propertyChange":true},[param4[2]],param2);
         param5[3] = new PropertyWatcher("max",{"propertyChange":true},[param4[3]],param2);
         param5[5] = new PropertyWatcher("stepByPercent",{"propertyChange":true},[param4[5]],param2);
         param5[1] = new PropertyWatcher("titleColor",{"propertyChange":true},[param4[1],param4[7]],param2);
         param5[0] = new PropertyWatcher("titleTxt",{"propertyChange":true},[param4[0]],param2);
         param5[6] = new PropertyWatcher("suffix",{"propertyChange":true},[param4[6]],param2);
         param5[4].updateParent(param1);
         param5[2].updateParent(param1);
         param5[3].updateParent(param1);
         param5[5].updateParent(param1);
         param5[1].updateParent(param1);
         param5[0].updateParent(param1);
         param5[6].updateParent(param1);
      }
   }
}
