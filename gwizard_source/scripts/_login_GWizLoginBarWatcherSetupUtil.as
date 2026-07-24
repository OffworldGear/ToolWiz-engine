package
{
   import login.GWizCredentials;
   import login.GWizLoginBar;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _login_GWizLoginBarWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _login_GWizLoginBarWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizLoginBar.watcherSetupUtil = new _login_GWizLoginBarWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[10] = new PropertyWatcher("ShowHelp",{"propertyChange":true},[param4[20]],param2);
         param5[9] = new PropertyWatcher("ShowTips",{"propertyChange":true},[param4[19]],param2);
         param5[1] = new PropertyWatcher("borderColor",{"propertyChange":true},[param4[1]],param2);
         param5[0] = new StaticPropertyWatcher("credStatus",{"propertyChange":true},[param4[0]],null);
         param5[6] = new PropertyWatcher("ShowGettingStarted",{"propertyChange":true},[param4[15]],param2);
         param5[3] = new PropertyWatcher("labelColor",{"propertyChange":true},[param4[3],param4[9]],param2);
         param5[2] = new PropertyWatcher("backgroundColor",{"propertyChange":true},[param4[2]],param2);
         param5[7] = new PropertyWatcher("versionColor",{"propertyChange":true},[param4[17]],param2);
         param5[4] = new StaticPropertyWatcher("LoginRequired",{"propertyChange":true},[param4[4],param4[5],param4[7],param4[8],param4[10],param4[11]],param3);
         param5[5] = new PropertyWatcher("controlBar",{"propertyChange":true},[param4[13]],param2);
         param5[8] = new PropertyWatcher("ShowSupport",{"propertyChange":true},[param4[18]],param2);
         param5[10].updateParent(param1);
         param5[9].updateParent(param1);
         param5[1].updateParent(param1);
         param5[0].updateParent(GWizCredentials);
         param5[6].updateParent(param1);
         param5[3].updateParent(param1);
         param5[2].updateParent(param1);
         param5[7].updateParent(param1);
         param5[4].updateParent(GWizLoginBar);
         param5[5].updateParent(param1);
         param5[8].updateParent(param1);
      }
   }
}
