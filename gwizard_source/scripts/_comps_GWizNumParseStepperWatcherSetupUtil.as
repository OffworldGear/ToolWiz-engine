package
{
   import comps.GWizNumParseStepper;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizNumParseStepperWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizNumParseStepperWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizNumParseStepper.watcherSetupUtil = new _comps_GWizNumParseStepperWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("min",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new PropertyWatcher("max",{"propertyChange":true},[param4[2]],param2);
         param5[0] = new PropertyWatcher("titleTxt",{"propertyChange":true},[param4[0]],param2);
         param5[3] = new PropertyWatcher("steps",{"propertyChange":true},[param4[3]],param2);
         param5[1].updateParent(param1);
         param5[2].updateParent(param1);
         param5[0].updateParent(param1);
         param5[3].updateParent(param1);
      }
   }
}
