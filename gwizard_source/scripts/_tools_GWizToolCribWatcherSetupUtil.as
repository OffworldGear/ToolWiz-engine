package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizCribList;
   import tools.GWizToolCrib;
   import tools.GWizToolCribData;
   import tools.GWizToolCribEntry;
   
   public class _tools_GWizToolCribWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizToolCribWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizToolCrib.watcherSetupUtil = new _tools_GWizToolCribWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[19] = new PropertyWatcher("delTableBtn",{"propertyChange":true},[param4[13],param4[46]],param2);
         param5[20] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[13]],null);
         param5[29] = new PropertyWatcher("width",{"widthChanged":true},[param4[46]],null);
         param5[10] = new StaticPropertyWatcher("lockToolCrib",{"propertyChange":true},[param4[5],param4[8],param4[11],param4[16],param4[27],param4[29],param4[35],param4[38],param4[40],param4[43],param4[44]],param3);
         param5[24] = new StaticPropertyWatcher("TableTypes",{"propertyChange":true},[param4[22]],null);
         param5[16] = new PropertyWatcher("renameTable",{"propertyChange":true},[param4[10]],param2);
         param5[17] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[10]],null);
         param5[28] = new PropertyWatcher("taskPopupFcn",{"propertyChange":true},[param4[39]],param2);
         param5[37] = new PropertyWatcher("allowDoubleClick",{"propertyChange":true},[param4[85],param4[89]],param2);
         param5[40] = new PropertyWatcher("listSize",{"propertyChange":true},[param4[88]],param2);
         param5[34] = new StaticPropertyWatcher("field3Name",{"propertyChange":true},[param4[80]],param3);
         param5[38] = new StaticPropertyWatcher("toolCribUnitFieldList",{"propertyChange":true},[param4[86]],null);
         param5[4] = new StaticPropertyWatcher("cribList",{"propertyChange":true},[param4[2]],null);
         param5[7] = new PropertyWatcher("powerUserState",{"propertyChange":true},[param4[3],param4[17],param4[31],param4[41],param4[42],param4[45],param4[50],param4[51],param4[52],param4[53],param4[54],param4[55],param4[56],param4[57],param4[58],param4[59],param4[60],param4[61],param4[62],param4[63],param4[64],param4[65],param4[66],param4[67],param4[68],param4[69],param4[70],param4[71],param4[72],param4[73],param4[74],param4[75],param4[77],param4[79],param4[81],param4[83]],param2);
         param5[39] = new PropertyWatcher("productLink",{"propertyChange":true},[param4[87]],param2);
         param5[8] = new PropertyWatcher("allTables",{"propertyChange":true},[param4[4],param4[23],param4[24]],param2);
         param5[25] = new PropertyWatcher("selected",{"propertyChange":true},[param4[23],param4[24]],null);
         param5[9] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[4]],null);
         param5[32] = new StaticPropertyWatcher("field1Name",{"propertyChange":true},[param4[76]],param3);
         param5[35] = new StaticPropertyWatcher("field4Name",{"propertyChange":true},[param4[82]],param3);
         param5[36] = new PropertyWatcher("fieldList",{"propertyChange":true},[param4[84]],param2);
         param5[6] = new PropertyWatcher("isTabbed",{"propertyChange":true},[param4[3],param4[6],param4[9],param4[12],param4[17],param4[20],param4[25],param4[26],param4[32],param4[33]],param2);
         param5[31] = new StaticPropertyWatcher("ToolCrib",{"propertyChange":true},[param4[49]],null);
         param5[2] = new PropertyWatcher("DescLab",{"propertyChange":true},[param4[1],param4[21],param4[28],param4[34]],param2);
         param5[3] = new PropertyWatcher("width",{"widthChanged":true},[param4[1],param4[21],param4[28],param4[34]],null);
         param5[33] = new StaticPropertyWatcher("field2Name",{"propertyChange":true},[param4[78]],param3);
         param5[0] = new PropertyWatcher("firstGrp",{"propertyChange":true},[param4[0],param4[15],param4[19]],param2);
         param5[1] = new PropertyWatcher("height",{"heightChanged":true},[param4[0],param4[15],param4[19]],null);
         param5[22] = new PropertyWatcher("optionsRow",{"propertyChange":true},[param4[18]],param2);
         param5[23] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[18]],null);
         param5[13] = new PropertyWatcher("newTable",{"propertyChange":true},[param4[7]],param2);
         param5[14] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[7]],null);
         param5[19].updateParent(param1);
         param5[19].addChild(param5[20]);
         param5[19].addChild(param5[29]);
         param5[10].updateParent(GWizToolCrib);
         param5[24].updateParent(GWizCribList);
         param5[16].updateParent(param1);
         param5[16].addChild(param5[17]);
         param5[28].updateParent(param1);
         param5[37].updateParent(param1);
         param5[40].updateParent(param1);
         param5[34].updateParent(GWizToolCrib);
         param5[38].updateParent(GWizToolCribEntry);
         param5[4].updateParent(GWizCribList);
         param5[7].updateParent(param1);
         param5[39].updateParent(param1);
         param5[8].updateParent(param1);
         param5[8].addChild(param5[25]);
         param5[8].addChild(param5[9]);
         param5[32].updateParent(GWizToolCrib);
         param5[35].updateParent(GWizToolCrib);
         param5[36].updateParent(param1);
         param5[6].updateParent(param1);
         param5[31].updateParent(GWizToolCribData);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
         param5[33].updateParent(GWizToolCrib);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
         param5[22].updateParent(param1);
         param5[22].addChild(param5[23]);
         param5[13].updateParent(param1);
         param5[13].addChild(param5[14]);
      }
   }
}
