package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.GWizTabBarButtonSkin;
   import utils.ColorPalette;
   
   public class _skins_GWizTabBarButtonSkinWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _skins_GWizTabBarButtonSkinWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizTabBarButtonSkin.watcherSetupUtil = new _skins_GWizTabBarButtonSkinWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new StaticPropertyWatcher("complement5",{"propertyChange":true},[param4[1],param4[2],param4[3],param4[4]],null);
         param5[0] = new PropertyWatcher("backColor",{"propertyChange":true},[param4[0]],param2);
         param5[1].updateParent(ColorPalette);
         param5[0].updateParent(param1);
      }
   }
}
