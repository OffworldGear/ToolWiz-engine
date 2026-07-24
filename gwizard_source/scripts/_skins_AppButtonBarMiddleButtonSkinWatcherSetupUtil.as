package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.AppButtonBarMiddleButtonSkin;
   import utils.ColorPalette;
   
   public class _skins_AppButtonBarMiddleButtonSkinWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _skins_AppButtonBarMiddleButtonSkinWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         AppButtonBarMiddleButtonSkin.watcherSetupUtil = new _skins_AppButtonBarMiddleButtonSkinWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("complement5",{"propertyChange":true},[param4[0],param4[1]],null);
         param5[0].updateParent(ColorPalette);
      }
   }
}
