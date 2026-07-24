package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizCribToolEditor;
   import tools.GWizToolCrib;
   import tools.GWizToolData;
   import utils.ColorPalette;
   
   public class _tools_GWizCribToolEditorWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizCribToolEditorWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCribToolEditor.watcherSetupUtil = new _tools_GWizCribToolEditorWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[21] = new StaticPropertyWatcher("field4Name",{"propertyChange":true},[param4[51]],null);
         param5[6] = new StaticPropertyWatcher("MillToolsList",{"propertyChange":true},[param4[7]],null);
         param5[8] = new PropertyWatcher("Tool",{"propertyChange":true},[param4[10]],param2);
         param5[12] = new PropertyWatcher("secondCol",{"propertyChange":true},[param4[12],param4[15]],param2);
         param5[13] = new PropertyWatcher("width",{"widthChanged":true},[param4[12],param4[15]],null);
         param5[16] = new PropertyWatcher("mfgSpecs",{"propertyChange":true},[param4[17],param4[20],param4[21],param4[25],param4[26],param4[30],param4[31],param4[35],param4[36],param4[40],param4[41],param4[45],param4[46]],param2);
         param5[17] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[17],param4[20],param4[21],param4[25],param4[26],param4[30],param4[31],param4[35],param4[36],param4[40],param4[41],param4[45],param4[46]],null);
         param5[18] = new StaticPropertyWatcher("field1Name",{"propertyChange":true},[param4[48]],null);
         param5[3] = new StaticPropertyWatcher("primary5",{"propertyChange":true},[param4[2],param4[6],param4[22],param4[27],param4[32],param4[37],param4[42],param4[47],param4[54]],null);
         param5[0] = new PropertyWatcher("width",{"widthChanged":true},[param4[0],param4[4],param4[9],param4[18],param4[23],param4[28],param4[33],param4[38],param4[43],param4[52]],param2);
         param5[7] = new PropertyWatcher("td",{"propertyChange":true},[param4[8]],param2);
         param5[10] = new PropertyWatcher("firstCol",{"propertyChange":true},[param4[11],param4[14]],param2);
         param5[11] = new PropertyWatcher("width",{"widthChanged":true},[param4[11],param4[14]],null);
         param5[4] = new PropertyWatcher("DescLabel",{"propertyChange":true},[param4[3]],param2);
         param5[5] = new PropertyWatcher("width",{"widthChanged":true},[param4[3]],null);
         param5[19] = new StaticPropertyWatcher("field2Name",{"propertyChange":true},[param4[49]],null);
         param5[14] = new PropertyWatcher("thirdCol",{"propertyChange":true},[param4[13],param4[16]],param2);
         param5[15] = new PropertyWatcher("width",{"widthChanged":true},[param4[13],param4[16]],null);
         param5[20] = new StaticPropertyWatcher("field3Name",{"propertyChange":true},[param4[50]],null);
         param5[2] = new StaticPropertyWatcher("primary3",{"propertyChange":true},[param4[1],param4[5],param4[19],param4[24],param4[29],param4[34],param4[39],param4[44],param4[53]],null);
         param5[21].updateParent(GWizToolCrib);
         param5[6].updateParent(GWizToolData);
         param5[8].updateParent(param1);
         param5[12].updateParent(param1);
         param5[12].addChild(param5[13]);
         param5[16].updateParent(param1);
         param5[16].addChild(param5[17]);
         param5[18].updateParent(GWizToolCrib);
         param5[3].updateParent(ColorPalette);
         param5[0].updateParent(param1);
         param5[7].updateParent(param1);
         param5[10].updateParent(param1);
         param5[10].addChild(param5[11]);
         param5[4].updateParent(param1);
         param5[4].addChild(param5[5]);
         param5[19].updateParent(GWizToolCrib);
         param5[14].updateParent(param1);
         param5[14].addChild(param5[15]);
         param5[20].updateParent(GWizToolCrib);
         param5[2].updateParent(ColorPalette);
      }
   }
}
