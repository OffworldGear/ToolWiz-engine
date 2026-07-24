package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizGraphicToolMenu;
   import tools.GWizToolData;
   
   public class _tools_GWizGraphicToolMenuWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizGraphicToolMenuWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizGraphicToolMenu.watcherSetupUtil = new _tools_GWizGraphicToolMenuWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[11] = new PropertyWatcher("ToolDia",{"propertyChange":true},[param4[11],param4[12]],param2);
         param5[13] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[12]],null);
         param5[12] = new PropertyWatcher("width",{"widthChanged":true},[param4[11]],null);
         param5[4] = new PropertyWatcher("Coating",{"propertyChange":true},[param4[4],param4[8]],param2);
         param5[5] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[4]],null);
         param5[7] = new PropertyWatcher("width",{"widthChanged":true},[param4[8]],null);
         param5[6] = new StaticPropertyWatcher("toolCoatingData",{"propertyChange":true},[param4[6]],null);
         param5[9] = new PropertyWatcher("toolHolderTxt",{"propertyChange":true},[param4[10]],param2);
         param5[10] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[10]],null);
         param5[3] = new StaticPropertyWatcher("toolMaterialData",{"propertyChange":true},[param4[3]],null);
         param5[1] = new PropertyWatcher("Material",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[1]],null);
         param5[8] = new PropertyWatcher("showGeometry",{"propertyChange":true},[param4[9]],param2);
         param5[14] = new PropertyWatcher("HelixAngle",{"propertyChange":true},[param4[13]],param2);
         param5[15] = new PropertyWatcher("visible",{
            "hide":true,
            "show":true
         },[param4[13]],null);
         param5[0] = new PropertyWatcher("toolListData",{"propertyChange":true},[param4[0]],param2);
         param5[11].updateParent(param1);
         param5[11].addChild(param5[13]);
         param5[11].addChild(param5[12]);
         param5[4].updateParent(param1);
         param5[4].addChild(param5[5]);
         param5[4].addChild(param5[7]);
         param5[6].updateParent(GWizToolData);
         param5[9].updateParent(param1);
         param5[9].addChild(param5[10]);
         param5[3].updateParent(GWizToolData);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
         param5[8].updateParent(param1);
         param5[14].updateParent(param1);
         param5[14].addChild(param5[15]);
         param5[0].updateParent(param1);
      }
   }
}
