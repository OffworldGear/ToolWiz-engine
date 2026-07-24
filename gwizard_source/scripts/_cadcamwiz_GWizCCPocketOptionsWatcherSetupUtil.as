package
{
   import cadcamwiz.GWizCCPocketOptions;
   import cadcamwiz.GWizCCWMillOptions;
   import cadcamwiz.GWizCCWRecalc;
   import feedsspeeds.GWizFeedsSpeeds2;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCPocketOptionsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCPocketOptionsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCPocketOptions.watcherSetupUtil = new _cadcamwiz_GWizCCPocketOptionsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("roughingStrategies",{"propertyChange":true},[param4[0]],null);
         param5[3] = new StaticPropertyWatcher("PlungeModes",{"propertyChange":true},[param4[3]],null);
         param5[1] = new StaticPropertyWatcher("roughStrat",{"propertyChange":true},[param4[1]],null);
         param5[2] = new StaticPropertyWatcher("showEntry",{"propertyChange":true},[param4[2],param4[4]],param3);
         param5[0].updateParent(GWizCCWRecalc);
         param5[3].updateParent(GWizFeedsSpeeds2);
         param5[1].updateParent(GWizCCWMillOptions);
         param5[2].updateParent(GWizCCPocketOptions);
      }
   }
}
