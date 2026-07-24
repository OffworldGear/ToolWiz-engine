package
{
   import configinfo.GWizSettings;
   import feedsspeeds.GWizFSCruncher;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizFSCruncherWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizFSCruncherWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizFSCruncher.watcherSetupUtil = new _feedsspeeds_GWizFSCruncherWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new StaticPropertyWatcher("FeedsSpeedsApp",null,[param4[1],param4[2]],null);
         param5[5] = new PropertyWatcher("Tool",{"propertyChange":true},[param4[2]],null);
         param5[6] = new PropertyWatcher("selectedLabel",null,[param4[2]],null);
         param5[2] = new PropertyWatcher("mms",null,[param4[1]],null);
         param5[3] = new PropertyWatcher("MatChooser",null,[param4[1]],null);
         param5[8] = new PropertyWatcher("totalScenarios",{"propertyChange":true},[param4[10]],param2);
         param5[1].updateParent(GWizSettings);
         param5[1].addChild(param5[5]);
         param5[5].addChild(param5[6]);
         param5[1].addChild(param5[2]);
         param5[2].addChild(param5[3]);
         param5[8].updateParent(param1);
      }
   }
}
