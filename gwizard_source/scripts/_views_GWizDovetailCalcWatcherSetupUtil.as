package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import views.GWizDovetailCalc;
   
   public class _views_GWizDovetailCalcWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizDovetailCalcWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizDovetailCalc.watcherSetupUtil = new _views_GWizDovetailCalcWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("gridArea",{"propertyChange":true},[param4[1],param4[2],param4[3],param4[4],param4[5],param4[6],param4[7]],param2);
         param5[7] = new PropertyWatcher("xOrigin",{"propertyChange":true},[param4[3],param4[5],param4[6]],null);
         param5[5] = new PropertyWatcher("yOrigin",{"propertyChange":true},[param4[2],param4[4],param4[7]],null);
         param5[2] = new PropertyWatcher("width",{"widthChanged":true},[param4[1]],null);
         param5[9] = new PropertyWatcher("inner",{"propertyChange":true},[param4[3]],param2);
         param5[10] = new PropertyWatcher("width",{"widthChanged":true},[param4[3]],null);
         param5[14] = new PropertyWatcher("scaledPlatformCenter2",{"propertyChange":true},[param4[9],param4[11],param4[15]],param2);
         param5[22] = new PropertyWatcher("dia2",{"propertyChange":true},[param4[13]],param2);
         param5[23] = new PropertyWatcher("width",{"widthChanged":true},[param4[13]],null);
         param5[6] = new PropertyWatcher("scaledPlatformHeight1",{"propertyChange":true},[param4[2],param4[4],param4[7]],param2);
         param5[24] = new PropertyWatcher("innerRoll",{"propertyChange":true},[param4[15]],param2);
         param5[25] = new PropertyWatcher("width",{"widthChanged":true},[param4[15]],null);
         param5[3] = new PropertyWatcher("angle1",{"propertyChange":true},[param4[1]],param2);
         param5[4] = new PropertyWatcher("width",{"widthChanged":true},[param4[1]],null);
         param5[18] = new PropertyWatcher("outer",{"propertyChange":true},[param4[11]],param2);
         param5[19] = new PropertyWatcher("width",{"widthChanged":true},[param4[11]],null);
         param5[11] = new PropertyWatcher("outerRoll",{"propertyChange":true},[param4[6]],param2);
         param5[12] = new PropertyWatcher("width",{"widthChanged":true},[param4[6]],null);
         param5[20] = new PropertyWatcher("scaledDoveHeight2",{"propertyChange":true},[param4[12],param4[16]],param2);
         param5[8] = new PropertyWatcher("scaledPlatformCenter1",{"propertyChange":true},[param4[3],param4[6]],param2);
         param5[15] = new PropertyWatcher("gridArea2",{"propertyChange":true},[param4[10],param4[11],param4[12],param4[13],param4[14],param4[15],param4[16]],param2);
         param5[17] = new PropertyWatcher("xOrigin",{"propertyChange":true},[param4[11],param4[15]],null);
         param5[16] = new PropertyWatcher("yOrigin",{"propertyChange":true},[param4[10],param4[12],param4[14],param4[16]],null);
         param5[21] = new PropertyWatcher("width",{"widthChanged":true},[param4[13]],null);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[7]);
         param5[1].addChild(param5[5]);
         param5[1].addChild(param5[2]);
         param5[9].updateParent(param1);
         param5[9].addChild(param5[10]);
         param5[14].updateParent(param1);
         param5[22].updateParent(param1);
         param5[22].addChild(param5[23]);
         param5[6].updateParent(param1);
         param5[24].updateParent(param1);
         param5[24].addChild(param5[25]);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[4]);
         param5[18].updateParent(param1);
         param5[18].addChild(param5[19]);
         param5[11].updateParent(param1);
         param5[11].addChild(param5[12]);
         param5[20].updateParent(param1);
         param5[8].updateParent(param1);
         param5[15].updateParent(param1);
         param5[15].addChild(param5[17]);
         param5[15].addChild(param5[16]);
         param5[15].addChild(param5[21]);
      }
   }
}
