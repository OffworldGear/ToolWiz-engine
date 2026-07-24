package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.GWizAccordionHeaderSkin;
   import utils.ColorPalette;
   
   public class _skins_GWizAccordionHeaderSkinWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _skins_GWizAccordionHeaderSkinWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizAccordionHeaderSkin.watcherSetupUtil = new _skins_GWizAccordionHeaderSkinWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("primary5",{"propertyChange":true},[param4[0]],null);
         param5[2] = new StaticPropertyWatcher("primary2",{"propertyChange":true},[param4[9],param4[10],param4[11],param4[12]],null);
         param5[3] = new StaticPropertyWatcher("primary1",{"propertyChange":true},[param4[13],param4[14],param4[15],param4[16]],null);
         param5[1] = new StaticPropertyWatcher("primary3",{"propertyChange":true},[param4[1],param4[2],param4[3],param4[4],param4[5],param4[6],param4[7],param4[8]],null);
         param5[0].updateParent(ColorPalette);
         param5[2].updateParent(ColorPalette);
         param5[3].updateParent(ColorPalette);
         param5[1].updateParent(ColorPalette);
      }
   }
}
