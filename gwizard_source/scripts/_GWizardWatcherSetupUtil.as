package
{
   import feedsspeeds.GWizFeedsSpeeds2;
   import login.GWizCredentials;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _GWizardWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _GWizardWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizard.watcherSetupUtil = new _GWizardWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("credStatus",{"propertyChange":true},[param4[1]],null);
         param5[2] = new StaticPropertyWatcher("appDownloadDir",{"propertyChange":true},[param4[3]],param3);
         param5[8] = new StaticPropertyWatcher("APP_NAME",{"propertyChange":true},[param4[11],param4[13]],null);
         param5[5] = new PropertyWatcher("appAccordion",{"propertyChange":true},[param4[8]],param2);
         param5[9] = new StaticPropertyWatcher("primary1",{"propertyChange":true},[param4[12]],null);
         param5[6] = new StaticPropertyWatcher("primary4",{"propertyChange":true},[param4[9]],null);
         param5[11] = new StaticPropertyWatcher("gray1",{"propertyChange":true},[param4[15]],null);
         param5[0].updateParent(GWizCredentials);
         param5[2].updateParent(GWizard);
         param5[8].updateParent(GWizFeedsSpeeds2);
         param5[5].updateParent(param1);
         param5[9].updateParent(ColorPalette);
         param5[6].updateParent(ColorPalette);
         param5[11].updateParent(ColorPalette);
      }
   }
}
