package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.AppButtonBarLastButtonSkin;
   import utils.ColorPalette;
   
   public class _skins_AppButtonBarLastButtonSkinWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _skins_AppButtonBarLastButtonSkinWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         AppButtonBarLastButtonSkin.watcherSetupUtil = new _skins_AppButtonBarLastButtonSkinWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("complement5",{"propertyChange":true},[param4[0],param4[1]],null);
         param5[0].updateParent(ColorPalette);
      }
   }
}
