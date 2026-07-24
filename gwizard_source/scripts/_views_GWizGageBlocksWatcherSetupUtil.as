package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   import utils.GWizUtils;
   import views.GWizGageBlocks;
   
   public class _views_GWizGageBlocksWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizGageBlocksWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizGageBlocks.watcherSetupUtil = new _views_GWizGageBlocksWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[8] = new PropertyWatcher("sbSizeInput",{"propertyChange":true},[param4[10],param4[11],param4[13]],param2);
         param5[9] = new PropertyWatcher("ssSizeInput",{"propertyChange":true},[param4[12]],param2);
         param5[3] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[5]],null);
         param5[7] = new StaticPropertyWatcher("debug",{"propertyChange":true},[param4[9]],null);
         param5[4] = new StaticPropertyWatcher("GageBlockStack",{"propertyChange":true},[param4[6]],param3);
         param5[2] = new StaticPropertyWatcher("alternateb4",{"propertyChange":true},[param4[4]],null);
         param5[1] = new PropertyWatcher("gageBlocksInput",{"propertyChange":true},[param4[2],param4[3]],param2);
         param5[0] = new PropertyWatcher("stackSzInput",{"propertyChange":true},[param4[0],param4[1]],param2);
         param5[5] = new StaticPropertyWatcher("sumOfBlockSzs",{"propertyChange":true},[param4[7]],param3);
         param5[6] = new StaticPropertyWatcher("cantDoItVisible",{"propertyChange":true},[param4[8]],param3);
         param5[8].updateParent(param1);
         param5[9].updateParent(param1);
         param5[3].updateParent(ColorPalette);
         param5[7].updateParent(GWizUtils);
         param5[4].updateParent(GWizGageBlocks);
         param5[2].updateParent(ColorPalette);
         param5[1].updateParent(param1);
         param5[0].updateParent(param1);
         param5[5].updateParent(GWizGageBlocks);
         param5[6].updateParent(GWizGageBlocks);
      }
   }
}
