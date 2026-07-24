package
{
   import comps.GWizGMCodePanel;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizGMCodePanelWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizGMCodePanelWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizGMCodePanel.watcherSetupUtil = new _comps_GWizGMCodePanelWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("textColor",{"propertyChange":true},[param4[0],param4[6]],param2);
         param5[5] = new PropertyWatcher("selectColor",{"propertyChange":true},[param4[4]],param2);
         param5[6] = new PropertyWatcher("rollOverColor",{"propertyChange":true},[param4[5]],param2);
         param5[1] = new PropertyWatcher("gCodes",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new PropertyWatcher("selected",{"propertyChange":true},[param4[1]],null);
         param5[4] = new PropertyWatcher("prunedList",{"propertyChange":true},[param4[3]],param2);
         param5[0].updateParent(param1);
         param5[5].updateParent(param1);
         param5[6].updateParent(param1);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
         param5[4].updateParent(param1);
      }
   }
}
