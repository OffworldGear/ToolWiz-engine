package
{
   import configinfo.GWizSettings;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.GWizStylePalette;
   import tools.GWizOpPopUp;
   
   public class _tools_GWizOpPopUpWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizOpPopUpWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizOpPopUp.watcherSetupUtil = new _tools_GWizOpPopUpWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[5] = new StaticPropertyWatcher("textColor",{"propertyChange":true},[param4[2]],null);
         param5[0] = new StaticPropertyWatcher("prefs",null,[param4[0]],null);
         param5[1] = new PropertyWatcher("powerUser",{"propertyChange":true},[param4[0]],null);
         param5[6] = new PropertyWatcher("MatChooser",{"propertyChange":true},[param4[3]],param2);
         param5[7] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[3]],null);
         param5[3] = new PropertyWatcher("filterGrp",{"propertyChange":true},[param4[1]],param2);
         param5[4] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[1]],null);
         param5[5].updateParent(GWizStylePalette);
         param5[0].updateParent(GWizSettings);
         param5[0].addChild(param5[1]);
         param5[6].updateParent(param1);
         param5[6].addChild(param5[7]);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[4]);
      }
   }
}
