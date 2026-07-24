package
{
   import apps.GWizRigidity;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _apps_GWizRigidityWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizRigidityWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizRigidity.watcherSetupUtil = new _apps_GWizRigidityWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[7] = new PropertyWatcher("rDia",{"propertyChange":true},[param4[6]],param2);
         param5[8] = new PropertyWatcher("width",{"widthChanged":true},[param4[6]],null);
         param5[2] = new PropertyWatcher("rLen",{"propertyChange":true},[param4[4],param4[5],param4[7]],param2);
         param5[3] = new PropertyWatcher("theLabel",{"propertyChange":true},[param4[4],param4[5],param4[7]],null);
         param5[4] = new PropertyWatcher("width",{"widthChanged":true},[param4[4],param4[5],param4[7]],null);
         param5[5] = new PropertyWatcher("rButtons",{"propertyChange":true},[param4[5]],param2);
         param5[6] = new PropertyWatcher("width",{"widthChanged":true},[param4[5]],null);
         param5[10] = new PropertyWatcher("tLen",{"propertyChange":true},[param4[12],param4[13],param4[15]],param2);
         param5[11] = new PropertyWatcher("theLabel",{"propertyChange":true},[param4[12],param4[13],param4[15]],null);
         param5[12] = new PropertyWatcher("width",{"widthChanged":true},[param4[12],param4[13],param4[15]],null);
         param5[1] = new StaticPropertyWatcher("alternateb3",{"propertyChange":true},[param4[1],param4[2],param4[10]],null);
         param5[0] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[0],param4[3],param4[11]],null);
         param5[13] = new PropertyWatcher("tButtons",{"propertyChange":true},[param4[13]],param2);
         param5[14] = new PropertyWatcher("width",{"widthChanged":true},[param4[13]],null);
         param5[15] = new PropertyWatcher("tDia",{"propertyChange":true},[param4[14]],param2);
         param5[16] = new PropertyWatcher("width",{"widthChanged":true},[param4[14]],null);
         param5[9] = new PropertyWatcher("refGroup",{"propertyChange":true},[param4[8],param4[9]],param2);
         param5[17] = new PropertyWatcher("targetGroup",{"propertyChange":true},[param4[16],param4[17]],param2);
         param5[7].updateParent(param1);
         param5[7].addChild(param5[8]);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
         param5[3].addChild(param5[4]);
         param5[5].updateParent(param1);
         param5[5].addChild(param5[6]);
         param5[10].updateParent(param1);
         param5[10].addChild(param5[11]);
         param5[11].addChild(param5[12]);
         param5[1].updateParent(ColorPalette);
         param5[0].updateParent(ColorPalette);
         param5[13].updateParent(param1);
         param5[13].addChild(param5[14]);
         param5[15].updateParent(param1);
         param5[15].addChild(param5[16]);
         param5[9].updateParent(param1);
         param5[17].updateParent(param1);
      }
   }
}
