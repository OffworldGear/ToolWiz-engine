package
{
   import comps.GWizTaperCalc;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizTaperCalcWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizTaperCalcWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizTaperCalc.watcherSetupUtil = new _comps_GWizTaperCalcWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("gridArea",{"propertyChange":true},[param4[0],param4[2],param4[3],param4[4],param4[5],param4[6],param4[7],param4[8],param4[9],param4[10],param4[11],param4[12],param4[13]],param2);
         param5[8] = new PropertyWatcher("height",{"heightChanged":true},[param4[7],param4[9],param4[11]],null);
         param5[3] = new PropertyWatcher("yOrigin",{"propertyChange":true},[param4[2],param4[3]],null);
         param5[1] = new PropertyWatcher("xOrigin",{"propertyChange":true},[param4[0],param4[4],param4[5],param4[6],param4[8],param4[10]],null);
         param5[9] = new PropertyWatcher("width",{"widthChanged":true},[param4[12],param4[13]],null);
         param5[2] = new PropertyWatcher("drawDefault",{"propertyChange":true},[param4[1]],param2);
         param5[6] = new PropertyWatcher("BigEnd",{"propertyChange":true},[param4[3]],param2);
         param5[7] = new PropertyWatcher("height",{"heightChanged":true},[param4[3]],null);
         param5[10] = new PropertyWatcher("taperLength",{"propertyChange":true},[param4[12]],param2);
         param5[11] = new PropertyWatcher("width",{"widthChanged":true},[param4[12]],null);
         param5[4] = new PropertyWatcher("SmallEnd",{"propertyChange":true},[param4[2]],param2);
         param5[5] = new PropertyWatcher("height",{"heightChanged":true},[param4[2]],null);
         param5[12] = new PropertyWatcher("BigSmall",{"propertyChange":true},[param4[13]],param2);
         param5[13] = new PropertyWatcher("width",{"widthChanged":true},[param4[13]],null);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[8]);
         param5[0].addChild(param5[3]);
         param5[0].addChild(param5[1]);
         param5[0].addChild(param5[9]);
         param5[2].updateParent(param1);
         param5[6].updateParent(param1);
         param5[6].addChild(param5[7]);
         param5[10].updateParent(param1);
         param5[10].addChild(param5[11]);
         param5[4].updateParent(param1);
         param5[4].addChild(param5[5]);
         param5[12].updateParent(param1);
         param5[12].addChild(param5[13]);
      }
   }
}
