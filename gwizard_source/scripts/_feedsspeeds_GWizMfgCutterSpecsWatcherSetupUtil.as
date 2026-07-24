package
{
   import feedsspeeds.GWizMfgCutterSpecs;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.GWizStylePalette;
   import tools.GWizCribToolEditor;
   import utils.ColorPalette;
   
   public class _feedsspeeds_GWizMfgCutterSpecsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizMfgCutterSpecsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizMfgCutterSpecs.watcherSetupUtil = new _feedsspeeds_GWizMfgCutterSpecsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[11] = new PropertyWatcher("secondColWd",{"propertyChange":true},[param4[10]],param2);
         param5[1] = new StaticPropertyWatcher("chiploadExamples",{"propertyChange":true},[param4[1]],param3);
         param5[4] = new StaticPropertyWatcher("primary5",{"propertyChange":true},[param4[4],param4[12],param4[17]],null);
         param5[10] = new StaticPropertyWatcher("ignoreLockForToolCrib",{"propertyChange":true},[param4[9],param4[14],param4[19]],null);
         param5[13] = new StaticPropertyWatcher("textColor",{"propertyChange":true},[param4[20]],null);
         param5[0] = new StaticPropertyWatcher("sfmExamples",{"propertyChange":true},[param4[0]],param3);
         param5[2] = new PropertyWatcher("firstColWd",{"propertyChange":true},[param4[2]],param2);
         param5[6] = new PropertyWatcher("gapSizes",{"propertyChange":true},[param4[6],param4[13],param4[18]],param2);
         param5[5] = new PropertyWatcher("labelWidths",{"propertyChange":true},[param4[5]],param2);
         param5[12] = new PropertyWatcher("thirdColWd",{"propertyChange":true},[param4[15]],param2);
         param5[9] = new StaticPropertyWatcher("lockForToolCrib",{"propertyChange":true},[param4[9],param4[14],param4[19]],param3);
         param5[3] = new StaticPropertyWatcher("primary3",{"propertyChange":true},[param4[3],param4[11],param4[16]],null);
         param5[11].updateParent(param1);
         param5[1].updateParent(GWizMfgCutterSpecs);
         param5[4].updateParent(ColorPalette);
         param5[10].updateParent(GWizCribToolEditor);
         param5[13].updateParent(GWizStylePalette);
         param5[0].updateParent(GWizMfgCutterSpecs);
         param5[2].updateParent(param1);
         param5[6].updateParent(param1);
         param5[5].updateParent(param1);
         param5[12].updateParent(param1);
         param5[9].updateParent(GWizMfgCutterSpecs);
         param5[3].updateParent(ColorPalette);
      }
   }
}
