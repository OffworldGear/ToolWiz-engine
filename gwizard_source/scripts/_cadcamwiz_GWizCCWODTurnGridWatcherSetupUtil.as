package
{
   import cadcamwiz.GWizCCWODTurnGrid;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _cadcamwiz_GWizCCWODTurnGridWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWODTurnGridWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWODTurnGrid.watcherSetupUtil = new _cadcamwiz_GWizCCWODTurnGridWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("turningPlan",{"propertyChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("visibleRows",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new StaticPropertyWatcher("secondaryb1",{"propertyChange":true},[param4[2]],null);
         param5[0].updateParent(param1);
         param5[1].updateParent(param1);
         param5[2].updateParent(ColorPalette);
      }
   }
}
