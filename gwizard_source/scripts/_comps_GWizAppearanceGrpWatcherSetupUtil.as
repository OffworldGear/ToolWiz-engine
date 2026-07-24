package
{
   import comps.GWizAppearanceGrp;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _comps_GWizAppearanceGrpWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizAppearanceGrpWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizAppearanceGrp.watcherSetupUtil = new _comps_GWizAppearanceGrpWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new StaticPropertyWatcher("gray5",{"propertyChange":true},[param4[1]],null);
         param5[3] = new PropertyWatcher("powerUserState",{"propertyChange":true},[param4[3]],param2);
         param5[4] = new PropertyWatcher("ThemeGrp",{"propertyChange":true},[param4[4],param4[5],param4[6]],param2);
         param5[0] = new StaticPropertyWatcher("gray3",{"propertyChange":true},[param4[0]],null);
         param5[2] = new PropertyWatcher("unitsText",{"propertyChange":true},[param4[2]],param2);
         param5[1].updateParent(ColorPalette);
         param5[3].updateParent(param1);
         param5[4].updateParent(param1);
         param5[0].updateParent(ColorPalette);
         param5[2].updateParent(param1);
      }
   }
}
