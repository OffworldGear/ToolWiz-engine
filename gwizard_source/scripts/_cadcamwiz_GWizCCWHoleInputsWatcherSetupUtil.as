package
{
   import cadcamwiz.GWizCCWHoleInputs;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCWHoleInputsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWHoleInputsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWHoleInputs.watcherSetupUtil = new _cadcamwiz_GWizCCWHoleInputsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[3] = new PropertyWatcher("Threading",{"propertyChange":true},[param4[2],param4[4],param4[6],param4[9]],param2);
         param5[4] = new PropertyWatcher("selected",{"propertyChange":true},[param4[2],param4[4],param4[6],param4[9]],null);
         param5[2] = new PropertyWatcher("ThreadTool",{"propertyChange":true},[param4[1],param4[3],param4[5]],param2);
         param5[6] = new PropertyWatcher("millHoleImg",{"propertyChange":true},[param4[10]],param2);
         param5[5] = new PropertyWatcher("ThreadToolMaterial",{"propertyChange":true},[param4[7],param4[8]],param2);
         param5[0] = new PropertyWatcher("Interpolate",{"propertyChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("selected",{"propertyChange":true},[param4[0]],null);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[4]);
         param5[2].updateParent(param1);
         param5[6].updateParent(param1);
         param5[5].updateParent(param1);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
      }
   }
}
