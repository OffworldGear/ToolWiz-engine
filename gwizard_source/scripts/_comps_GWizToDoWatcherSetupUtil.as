package
{
   import comps.GWizToDo;
   import configinfo.GWizSettings;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _comps_GWizToDoWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizToDoWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizToDo.watcherSetupUtil = new _comps_GWizToDoWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[5] = new StaticPropertyWatcher("longTime",{"propertyChange":true},[param4[7]],null);
         param5[4] = new StaticPropertyWatcher("shortTime",{"propertyChange":true},[param4[6]],null);
         param5[3] = new StaticPropertyWatcher("workTime",{"propertyChange":true},[param4[5]],null);
         param5[0] = new StaticPropertyWatcher("gray4",{"propertyChange":true},[param4[0]],null);
         param5[1] = new PropertyWatcher("shortBreakBtn",{"propertyChange":true},[param4[1],param4[2],param4[3],param4[4]],param2);
         param5[2] = new PropertyWatcher("width",{"widthChanged":true},[param4[1],param4[2],param4[3],param4[4]],null);
         param5[5].updateParent(GWizSettings);
         param5[4].updateParent(GWizSettings);
         param5[3].updateParent(GWizSettings);
         param5[0].updateParent(ColorPalette);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
      }
   }
}
