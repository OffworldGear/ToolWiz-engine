package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizCribWiz;
   import utils.ColorPalette;
   
   public class _tools_GWizCribWizWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizCribWizWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCribWiz.watcherSetupUtil = new _tools_GWizCribWizWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[3] = new StaticPropertyWatcher("TwistDrillTypes",{"propertyChange":true},[param4[5]],param3);
         param5[1] = new StaticPropertyWatcher("primary5",{"propertyChange":true},[param4[1],param4[4],param4[7]],null);
         param5[0] = new StaticPropertyWatcher("primary3",{"propertyChange":true},[param4[0],param4[3],param4[6]],null);
         param5[2] = new StaticPropertyWatcher("EndMillTypes",{"propertyChange":true},[param4[2]],param3);
         param5[3].updateParent(GWizCribWiz);
         param5[1].updateParent(ColorPalette);
         param5[0].updateParent(ColorPalette);
         param5[2].updateParent(GWizCribWiz);
      }
   }
}
