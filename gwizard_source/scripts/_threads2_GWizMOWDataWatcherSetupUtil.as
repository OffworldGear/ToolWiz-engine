package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import threads2.GWizMOWData;
   
   public class _threads2_GWizMOWDataWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _threads2_GWizMOWDataWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizMOWData.watcherSetupUtil = new _threads2_GWizMOWDataWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("enabled",{"enabledChanged":true},[param4[0],param4[1]],param2);
         param5[1] = new PropertyWatcher("actualMOW",{"propertyChange":true},[param4[2],param4[3],param4[4]],param2);
         param5[2] = new PropertyWatcher("width",{"widthChanged":true},[param4[2],param4[3],param4[4]],null);
         param5[3] = new PropertyWatcher("mowMOWMax",{"propertyChange":true},[param4[5],param4[6]],param2);
         param5[4] = new PropertyWatcher("width",{"widthChanged":true},[param4[5],param4[6]],null);
         param5[0].updateParent(param1);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[4]);
      }
   }
}
