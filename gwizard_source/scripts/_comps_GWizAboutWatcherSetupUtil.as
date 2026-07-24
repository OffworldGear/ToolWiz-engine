package
{
   import comps.GWizAbout;
   import configinfo.GWizAbstractPrefs;
   import flash.system.Capabilities;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _comps_GWizAboutWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizAboutWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizAbout.watcherSetupUtil = new _comps_GWizAboutWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[4] = new PropertyWatcher("logoImage",{"propertyChange":true},[param4[6]],param2);
         param5[9] = new StaticPropertyWatcher("madeByStr",{"propertyChange":true},[param4[14]],null);
         param5[6] = new StaticPropertyWatcher("appMessage",{"propertyChange":true},[param4[10]],param3);
         param5[8] = new StaticPropertyWatcher("screenResolutionY",null,[param4[13]],null);
         param5[7] = new StaticPropertyWatcher("screenResolutionX",null,[param4[12]],null);
         param5[2] = new PropertyWatcher("greenNeonFilter",{"propertyChange":true},[param4[3]],param2);
         param5[3] = new StaticPropertyWatcher("gray1",{"propertyChange":true},[param4[4],param4[5]],null);
         param5[1] = new PropertyWatcher("logoImg",{"propertyChange":true},[param4[2]],param2);
         param5[4].updateParent(param1);
         param5[9].updateParent(GWizAbstractPrefs);
         param5[6].updateParent(GWizAbout);
         param5[8].updateParent(Capabilities);
         param5[7].updateParent(Capabilities);
         param5[2].updateParent(param1);
         param5[3].updateParent(ColorPalette);
         param5[1].updateParent(param1);
      }
   }
}
