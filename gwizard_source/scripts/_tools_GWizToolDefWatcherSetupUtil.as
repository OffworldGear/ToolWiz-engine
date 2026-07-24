package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizCribToolEditor;
   import tools.GWizToolDef;
   import utils.ColorPalette;
   
   public class _tools_GWizToolDefWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizToolDefWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizToolDef.watcherSetupUtil = new _tools_GWizToolDefWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[10] = new PropertyWatcher("secondColWd",{"propertyChange":true},[param4[9]],param2);
         param5[12] = new PropertyWatcher("optStick",{"propertyChange":true},[param4[20]],param2);
         param5[13] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[20]],null);
         param5[3] = new PropertyWatcher("labelWidth",{"propertyChange":true},[param4[3],param4[12],param4[18]],param2);
         param5[4] = new PropertyWatcher("gapSize",{"propertyChange":true},[param4[4],param4[13],param4[19]],param2);
         param5[14] = new PropertyWatcher("hideToCrib",{"propertyChange":true},[param4[22]],param2);
         param5[2] = new StaticPropertyWatcher("primary5",{"propertyChange":true},[param4[2],param4[11],param4[17]],null);
         param5[7] = new StaticPropertyWatcher("ignoreLockForToolCrib",{"propertyChange":true},[param4[6],param4[7],param4[14],param4[21]],null);
         param5[8] = new PropertyWatcher("SizesBtn",{"propertyChange":true},[param4[8]],param2);
         param5[9] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[8]],null);
         param5[0] = new PropertyWatcher("firstColWd",{"propertyChange":true},[param4[0]],param2);
         param5[16] = new PropertyWatcher("toCrib",{"propertyChange":true},[param4[23]],param2);
         param5[17] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[23]],null);
         param5[11] = new PropertyWatcher("thirdColWd",{"propertyChange":true},[param4[15]],param2);
         param5[1] = new StaticPropertyWatcher("primary3",{"propertyChange":true},[param4[1],param4[10],param4[16]],null);
         param5[6] = new StaticPropertyWatcher("_lockForToolCrib",{"propertyChange":true},[param4[6],param4[7],param4[14],param4[21],param4[22]],param3);
         param5[10].updateParent(param1);
         param5[12].updateParent(param1);
         param5[12].addChild(param5[13]);
         param5[3].updateParent(param1);
         param5[4].updateParent(param1);
         param5[14].updateParent(param1);
         param5[2].updateParent(ColorPalette);
         param5[7].updateParent(GWizCribToolEditor);
         param5[8].updateParent(param1);
         param5[8].addChild(param5[9]);
         param5[0].updateParent(param1);
         param5[16].updateParent(param1);
         param5[16].addChild(param5[17]);
         param5[11].updateParent(param1);
         param5[1].updateParent(ColorPalette);
         param5[6].updateParent(GWizToolDef);
      }
   }
}
