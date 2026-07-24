package
{
   import feedsspeeds.GWizFSMiniCalcs;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.GWizStylePalette;
   
   public class _feedsspeeds_GWizFSMiniCalcsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizFSMiniCalcsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizFSMiniCalcs.watcherSetupUtil = new _feedsspeeds_GWizFSMiniCalcsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("textColor",{"propertyChange":true},[param4[0]],null);
         param5[5] = new PropertyWatcher("Plunge",{"propertyChange":true},[param4[3]],param2);
         param5[6] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[3]],null);
         param5[1] = new PropertyWatcher("Interpolate",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[1]],null);
         param5[3] = new PropertyWatcher("Ramp",{"propertyChange":true},[param4[2]],param2);
         param5[4] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[2]],null);
         param5[0].updateParent(GWizStylePalette);
         param5[5].updateParent(param1);
         param5[5].addChild(param5[6]);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[4]);
      }
   }
}
