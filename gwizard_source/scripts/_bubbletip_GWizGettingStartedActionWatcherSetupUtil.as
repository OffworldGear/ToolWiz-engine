package
{
   import bubbletip.GWizGettingStartedAction;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _bubbletip_GWizGettingStartedActionWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _bubbletip_GWizGettingStartedActionWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizGettingStartedAction.watcherSetupUtil = new _bubbletip_GWizGettingStartedActionWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[4] = new StaticPropertyWatcher("secondarya4",{"propertyChange":true},[param4[3]],null);
         param5[2] = new PropertyWatcher("numberBtn",{"propertyChange":true},[param4[2]],param2);
         param5[3] = new PropertyWatcher("height",{"heightChanged":true},[param4[2]],null);
         param5[6] = new PropertyWatcher("status",{"propertyChange":true},[param4[5]],param2);
         param5[7] = new PropertyWatcher("selected",{"propertyChange":true},[param4[5]],null);
         param5[0] = new PropertyWatcher("stepTip",{"propertyChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("stepNo",{"propertyChange":true},[param4[1]],param2);
         param5[8] = new PropertyWatcher("stepDone",{"propertyChange":true},[param4[6],param4[7]],param2);
         param5[5] = new PropertyWatcher("stepName",{"propertyChange":true},[param4[4]],param2);
         param5[4].updateParent(ColorPalette);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
         param5[6].updateParent(param1);
         param5[6].addChild(param5[7]);
         param5[0].updateParent(param1);
         param5[1].updateParent(param1);
         param5[8].updateParent(param1);
         param5[5].updateParent(param1);
      }
   }
}
