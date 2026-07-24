package
{
   import bubbletip.GWizGettingStarted;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _bubbletip_GWizGettingStartedWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _bubbletip_GWizGettingStartedWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizGettingStarted.watcherSetupUtil = new _bubbletip_GWizGettingStartedWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[2] = new PropertyWatcher("Yup",{"propertyChange":true},[param4[8]],param2);
         param5[3] = new PropertyWatcher("width",{"widthChanged":true},[param4[8]],null);
         param5[4] = new PropertyWatcher("vidsBtn",{"propertyChange":true},[param4[10],param4[13]],param2);
         param5[5] = new PropertyWatcher("width",{"widthChanged":true},[param4[10],param4[13]],null);
         param5[6] = new PropertyWatcher("beginnerBtn",{"propertyChange":true},[param4[11],param4[12]],param2);
         param5[7] = new PropertyWatcher("width",{"widthChanged":true},[param4[11],param4[12]],null);
         param5[0] = new PropertyWatcher("labelBackgroundColor",{"propertyChange":true},[param4[0]],param2);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
         param5[4].updateParent(param1);
         param5[4].addChild(param5[5]);
         param5[6].updateParent(param1);
         param5[6].addChild(param5[7]);
         param5[0].updateParent(param1);
      }
   }
}
