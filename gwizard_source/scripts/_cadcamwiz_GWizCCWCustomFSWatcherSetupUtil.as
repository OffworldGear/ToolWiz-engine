package
{
   import cadcamwiz.GWizCCWCustomFS;
   import feedsspeeds.GWizFeedsSpeeds2;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _cadcamwiz_GWizCCWCustomFSWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWCustomFSWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWCustomFS.watcherSetupUtil = new _cadcamwiz_GWizCCWCustomFSWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[4] = new PropertyWatcher("opTime",{"propertyChange":true},[param4[3]],param2);
         param5[0] = new PropertyWatcher("height",{"heightChanged":true},[param4[0]],param2);
         param5[6] = new PropertyWatcher("estTime",{"propertyChange":true},[param4[4]],param2);
         param5[7] = new StaticPropertyWatcher("APP_NAME",{"propertyChange":true},[param4[5]],null);
         param5[2] = new StaticPropertyWatcher("primary5",{"propertyChange":true},[param4[2]],null);
         param5[1] = new StaticPropertyWatcher("primary3",{"propertyChange":true},[param4[1]],null);
         param5[4].updateParent(param1);
         param5[0].updateParent(param1);
         param5[6].updateParent(param1);
         param5[7].updateParent(GWizFeedsSpeeds2);
         param5[2].updateParent(ColorPalette);
         param5[1].updateParent(ColorPalette);
      }
   }
}
