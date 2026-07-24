package
{
   import cadcamwiz.GWizCCWEstimatorInput;
   import cadcamwiz.GWizCCWGenericWizard;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCWGenericWizardWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWGenericWizardWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWGenericWizard.watcherSetupUtil = new _cadcamwiz_GWizCCWGenericWizardWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[5] = new PropertyWatcher("opTimeLabel",{"propertyChange":true},[param4[6]],param2);
         param5[6] = new PropertyWatcher("width",{"widthChanged":true},[param4[6]],null);
         param5[0] = new PropertyWatcher("results",{"propertyChange":true},[param4[0]],param2);
         param5[3] = new PropertyWatcher("TimesRow",{"propertyChange":true},[param4[5]],param2);
         param5[4] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[5]],null);
         param5[1] = new PropertyWatcher("theLabelWidth",{"propertyChange":true},[param4[1],param4[3],param4[8]],param2);
         param5[2] = new StaticPropertyWatcher("addEstimatorItem",{"propertyChange":true},[param4[2],param4[4]],null);
         param5[5].updateParent(param1);
         param5[5].addChild(param5[6]);
         param5[0].updateParent(param1);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[4]);
         param5[1].updateParent(param1);
         param5[2].updateParent(GWizCCWEstimatorInput);
      }
   }
}
