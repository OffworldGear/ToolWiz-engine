package
{
   import cadcamwiz.GWizCCWODTurnOptions;
   import configinfo.GWizLatheTools;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCWODTurnOptionsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWODTurnOptionsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWODTurnOptions.watcherSetupUtil = new _cadcamwiz_GWizCCWODTurnOptionsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[2] = new PropertyWatcher("doFinishPass",{"propertyChange":true},[param4[2],param4[3],param4[5],param4[6],param4[8]],param2);
         param5[3] = new PropertyWatcher("selected",{"propertyChange":true},[param4[2],param4[3],param4[5],param4[6],param4[8]],null);
         param5[1] = new StaticPropertyWatcher("insSizes",{"propertyChange":true},[param4[1],param4[7]],null);
         param5[0] = new StaticPropertyWatcher("insTypes",{"propertyChange":true},[param4[0],param4[4]],null);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
         param5[1].updateParent(GWizLatheTools);
         param5[0].updateParent(GWizLatheTools);
      }
   }
}
