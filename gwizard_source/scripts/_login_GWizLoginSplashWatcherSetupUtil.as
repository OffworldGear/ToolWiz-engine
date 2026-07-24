package
{
   import login.GWizLoginSplash;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _login_GWizLoginSplashWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _login_GWizLoginSplashWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizLoginSplash.watcherSetupUtil = new _login_GWizLoginSplashWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("GetStarted",{"propertyChange":true},[param4[0],param4[1],param4[2],param4[3]],param2);
         param5[1] = new PropertyWatcher("height",{"heightChanged":true},[param4[0],param4[1],param4[2],param4[3]],null);
         param5[2] = new PropertyWatcher("machName",{"propertyChange":true},[param4[4],param4[5],param4[6]],param2);
         param5[3] = new PropertyWatcher("width",{"widthChanged":true},[param4[4],param4[5],param4[6]],null);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
      }
   }
}
