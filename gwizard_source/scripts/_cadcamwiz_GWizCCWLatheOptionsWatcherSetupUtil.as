package
{
   import cadcamwiz.GWizCCWLatheOptions;
   import cadcamwiz.GWizCCWSettings;
   import configinfo.GWizLatheTools;
   import configinfo.GWizSettings;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCWLatheOptionsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWLatheOptionsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWLatheOptions.watcherSetupUtil = new _cadcamwiz_GWizCCWLatheOptionsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[2] = new StaticPropertyWatcher("partingToolCarbide",{"propertyChange":true},[param4[4]],null);
         param5[1] = new StaticPropertyWatcher("insSizes",{"propertyChange":true},[param4[1],param4[3]],null);
         param5[3] = new StaticPropertyWatcher("TortoiseImg",{"propertyChange":true},[param4[5]],null);
         param5[0] = new StaticPropertyWatcher("insTypes",{"propertyChange":true},[param4[0],param4[2]],null);
         param5[5] = new StaticPropertyWatcher("HareImg",{"propertyChange":true},[param4[8]],null);
         param5[2].updateParent(GWizCCWSettings);
         param5[1].updateParent(GWizLatheTools);
         param5[3].updateParent(GWizSettings);
         param5[0].updateParent(GWizLatheTools);
         param5[5].updateParent(GWizSettings);
      }
   }
}
