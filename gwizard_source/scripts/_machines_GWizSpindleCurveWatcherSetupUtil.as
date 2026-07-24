package
{
   import machines.GWizSpindleCurve;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   public class _machines_GWizSpindleCurveWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _machines_GWizSpindleCurveWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizSpindleCurve.watcherSetupUtil = new _machines_GWizSpindleCurveWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[8] = new StaticPropertyWatcher("Units",{"propertyChange":true},[param4[10]],null);
         param5[1] = new PropertyWatcher("CurveAdjust",{"propertyChange":true},[param4[2],param4[5],param4[13]],param2);
         param5[2] = new PropertyWatcher("selected",{"propertyChange":true},[param4[2],param4[5],param4[13]],null);
         param5[10] = new PropertyWatcher("s1",{"propertyChange":true},[param4[11]],param2);
         param5[7] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[8]],null);
         param5[6] = new StaticPropertyWatcher("alternateb4",{"propertyChange":true},[param4[7]],null);
         param5[11] = new PropertyWatcher("linechart",{"propertyChange":true},[param4[12]],param2);
         param5[0] = new StaticPropertyWatcher("_vmcRigidity",{"propertyChange":true},[param4[0],param4[1]],param3);
         param5[5] = new StaticPropertyWatcher("powerAC",{"propertyChange":true},[param4[6],param4[9]],param3);
         param5[8].updateParent(GWizUtils);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
         param5[10].updateParent(param1);
         param5[7].updateParent(ColorPalette);
         param5[6].updateParent(ColorPalette);
         param5[11].updateParent(param1);
         param5[0].updateParent(GWizSpindleCurve);
         param5[5].updateParent(GWizSpindleCurve);
      }
   }
}
