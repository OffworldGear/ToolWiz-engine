package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import views.GWizTrigCalcOblique;
   
   public class _views_GWizTrigCalcObliqueWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizTrigCalcObliqueWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizTrigCalcOblique.watcherSetupUtil = new _views_GWizTrigCalcObliqueWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[3] = new PropertyWatcher("gridArea",{"propertyChange":true},[param4[1],param4[2],param4[3],param4[4],param4[5],param4[7],param4[9],param4[12],param4[14]],param2);
         param5[33] = new PropertyWatcher("xOrigin",{"propertyChange":true},[param4[14]],null);
         param5[7] = new PropertyWatcher("yOrigin",{"propertyChange":true},[param4[2],param4[4],param4[12]],null);
         param5[4] = new PropertyWatcher("width",{"widthChanged":true},[param4[1],param4[3],param4[5],param4[7],param4[9]],null);
         param5[17] = new PropertyWatcher("sy3",{"propertyChange":true},[param4[6],param4[8],param4[10]],param2);
         param5[26] = new PropertyWatcher("sy2",{"propertyChange":true},[param4[10]],param2);
         param5[32] = new PropertyWatcher("drawDefault",{"propertyChange":true},[param4[13]],param2);
         param5[24] = new PropertyWatcher("cSideLabel",{"propertyChange":true},[param4[9]],param2);
         param5[25] = new PropertyWatcher("width",{"widthChanged":true},[param4[9]],null);
         param5[18] = new PropertyWatcher("CAngle",{"propertyChange":true},[param4[6]],param2);
         param5[5] = new PropertyWatcher("AAngleLabel",{"propertyChange":true},[param4[1]],param2);
         param5[6] = new PropertyWatcher("width",{"widthChanged":true},[param4[1]],null);
         param5[16] = new PropertyWatcher("sy1",{"propertyChange":true},[param4[6]],param2);
         param5[27] = new PropertyWatcher("AAngle",{"propertyChange":true},[param4[10]],param2);
         param5[21] = new PropertyWatcher("BAngleLabel",{"propertyChange":true},[param4[7]],param2);
         param5[22] = new PropertyWatcher("width",{"widthChanged":true},[param4[7]],null);
         param5[13] = new PropertyWatcher("aSideLabel",{"propertyChange":true},[param4[5]],param2);
         param5[14] = new PropertyWatcher("width",{"widthChanged":true},[param4[5]],null);
         param5[11] = new PropertyWatcher("sx1",{"propertyChange":true},[param4[3],param4[5],param4[11]],param2);
         param5[2] = new PropertyWatcher("sx2",{"propertyChange":true},[param4[1],param4[3],param4[9]],param2);
         param5[15] = new PropertyWatcher("sx3",{"propertyChange":true},[param4[5],param4[7],param4[9]],param2);
         param5[30] = new PropertyWatcher("CAngleLabel",{"propertyChange":true},[param4[11]],param2);
         param5[31] = new PropertyWatcher("width",{"widthChanged":true},[param4[11]],null);
         param5[9] = new PropertyWatcher("bSideLabel",{"propertyChange":true},[param4[3]],param2);
         param5[10] = new PropertyWatcher("width",{"widthChanged":true},[param4[3]],null);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[33]);
         param5[3].addChild(param5[7]);
         param5[3].addChild(param5[4]);
         param5[17].updateParent(param1);
         param5[26].updateParent(param1);
         param5[32].updateParent(param1);
         param5[24].updateParent(param1);
         param5[24].addChild(param5[25]);
         param5[18].updateParent(param1);
         param5[5].updateParent(param1);
         param5[5].addChild(param5[6]);
         param5[16].updateParent(param1);
         param5[27].updateParent(param1);
         param5[21].updateParent(param1);
         param5[21].addChild(param5[22]);
         param5[13].updateParent(param1);
         param5[13].addChild(param5[14]);
         param5[11].updateParent(param1);
         param5[2].updateParent(param1);
         param5[15].updateParent(param1);
         param5[30].updateParent(param1);
         param5[30].addChild(param5[31]);
         param5[9].updateParent(param1);
         param5[9].addChild(param5[10]);
      }
   }
}
