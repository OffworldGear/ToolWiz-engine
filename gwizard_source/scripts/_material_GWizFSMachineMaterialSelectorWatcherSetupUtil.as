package
{
   import material.GWizFSMachineMaterialSelector;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.GWizStylePalette;
   import utils.ColorPalette;
   
   public class _material_GWizFSMachineMaterialSelectorWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _material_GWizFSMachineMaterialSelectorWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizFSMachineMaterialSelector.watcherSetupUtil = new _material_GWizFSMachineMaterialSelectorWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[9] = new PropertyWatcher("secondColWd",{"propertyChange":true},[param4[11]],param2);
         param5[8] = new StaticPropertyWatcher("textColor",{"propertyChange":true},[param4[8],param4[9],param4[10],param4[19]],null);
         param5[5] = new PropertyWatcher("labelWidth",{"propertyChange":true},[param4[5],param4[15]],param2);
         param5[2] = new PropertyWatcher("title",{"propertyChange":true},[param4[2]],param2);
         param5[1] = new PropertyWatcher("height",{"heightChanged":true},[param4[1],param4[12]],param2);
         param5[0] = new PropertyWatcher("firstColWd",{"propertyChange":true},[param4[0]],param2);
         param5[6] = new PropertyWatcher("gapSize",{"propertyChange":true},[param4[6],param4[16]],param2);
         param5[12] = new PropertyWatcher("onChangeFcn",{"propertyChange":true},[param4[18]],param2);
         param5[4] = new StaticPropertyWatcher("primary5",{"propertyChange":true},[param4[4],param4[14]],null);
         param5[7] = new PropertyWatcher("nativeWin",{"propertyChange":true},[param4[7]],param2);
         param5[3] = new StaticPropertyWatcher("primary3",{"propertyChange":true},[param4[3],param4[13]],null);
         param5[10] = new PropertyWatcher("matPanel",{"propertyChange":true},[param4[17]],param2);
         param5[11] = new PropertyWatcher("width",{"widthChanged":true},[param4[17]],null);
         param5[9].updateParent(param1);
         param5[8].updateParent(GWizStylePalette);
         param5[5].updateParent(param1);
         param5[2].updateParent(param1);
         param5[1].updateParent(param1);
         param5[0].updateParent(param1);
         param5[6].updateParent(param1);
         param5[12].updateParent(param1);
         param5[4].updateParent(ColorPalette);
         param5[7].updateParent(param1);
         param5[3].updateParent(ColorPalette);
         param5[10].updateParent(param1);
         param5[10].addChild(param5[11]);
      }
   }
}
