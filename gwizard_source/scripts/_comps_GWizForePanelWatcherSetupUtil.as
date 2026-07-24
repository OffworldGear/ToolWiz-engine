package
{
   import comps.GWizForePanel;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.GWizStylePalette;
   
   public class _comps_GWizForePanelWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizForePanelWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizForePanel.watcherSetupUtil = new _comps_GWizForePanelWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("borderColor",{"propertyChange":true},[param4[0]],null);
         param5[0].updateParent(GWizStylePalette);
      }
   }
}
