package
{
   import comps.skins.ProgressBarSkin;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _comps_skins_ProgressBarSkinWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_skins_ProgressBarSkinWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         ProgressBarSkin.watcherSetupUtil = new _comps_skins_ProgressBarSkinWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("track",{"propertyChange":true},[param4[1],param4[2]],param2);
         param5[6] = new PropertyWatcher("height",{"propertyChange":true},[param4[2]],null);
         param5[2] = new PropertyWatcher("width",{"propertyChange":true},[param4[1]],null);
         param5[0] = new StaticPropertyWatcher("gray5",{"propertyChange":true},[param4[0]],null);
         param5[3] = new PropertyWatcher("hostComponent",{"propertyChange":true},[param4[1],param4[3],param4[4],param4[5]],param2);
         param5[8] = new PropertyWatcher("progressColorHilight",{"propertyChange":true},[param4[4]],null);
         param5[7] = new PropertyWatcher("progressColor",{"propertyChange":true},[param4[3]],null);
         param5[5] = new PropertyWatcher("maximum",{"propertyChange":true},[param4[1]],null);
         param5[4] = new PropertyWatcher("value",{"propertyChange":true},[param4[1]],null);
         param5[9] = new PropertyWatcher("label",{"propertyChange":true},[param4[5]],null);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[6]);
         param5[1].addChild(param5[2]);
         param5[0].updateParent(ColorPalette);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[8]);
         param5[3].addChild(param5[7]);
         param5[3].addChild(param5[5]);
         param5[3].addChild(param5[4]);
         param5[3].addChild(param5[9]);
      }
   }
}
