package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   import views.GWizMotorCalc;
   
   public class _views_GWizMotorCalcWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizMotorCalcWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizMotorCalc.watcherSetupUtil = new _views_GWizMotorCalcWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new StaticPropertyWatcher("alternateb3",{"propertyChange":true},[param4[1],param4[2],param4[4]],null);
         param5[0] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[0],param4[3],param4[5]],null);
         param5[1].updateParent(ColorPalette);
         param5[0].updateParent(ColorPalette);
      }
   }
}
