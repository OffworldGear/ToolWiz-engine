package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import views.GWizTrigCalc;
   
   public class _views_GWizTrigCalcWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizTrigCalcWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizTrigCalc.watcherSetupUtil = new _views_GWizTrigCalcWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[4] = new PropertyWatcher("yTop",{"propertyChange":true},[param4[2],param4[4],param4[10]],param2);
         param5[1] = new PropertyWatcher("gridArea",{"propertyChange":true},[param4[1],param4[2],param4[3],param4[4],param4[5],param4[6],param4[7],param4[8],param4[9],param4[10],param4[12]],param2);
         param5[5] = new PropertyWatcher("yOrigin",{"propertyChange":true},[param4[2],param4[4],param4[6],param4[8],param4[10]],null);
         param5[2] = new PropertyWatcher("xOrigin",{"propertyChange":true},[param4[1],param4[3],param4[5],param4[9],param4[12]],null);
         param5[9] = new PropertyWatcher("width",{"widthChanged":true},[param4[7]],null);
         param5[12] = new PropertyWatcher("drawDefault",{"propertyChange":true},[param4[11]],param2);
         param5[10] = new PropertyWatcher("xAngleLabel",{"propertyChange":true},[param4[7]],param2);
         param5[11] = new PropertyWatcher("width",{"widthChanged":true},[param4[7]],null);
         param5[7] = new PropertyWatcher("xRight",{"propertyChange":true},[param4[5],param4[7],param4[9]],param2);
         param5[4].updateParent(param1);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[5]);
         param5[1].addChild(param5[2]);
         param5[1].addChild(param5[9]);
         param5[12].updateParent(param1);
         param5[10].updateParent(param1);
         param5[10].addChild(param5[11]);
         param5[7].updateParent(param1);
      }
   }
}
