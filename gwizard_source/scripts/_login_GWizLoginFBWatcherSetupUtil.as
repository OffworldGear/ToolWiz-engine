package
{
   import login.GWizLoginFB;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   
   public class _login_GWizLoginFBWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _login_GWizLoginFBWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizLoginFB.watcherSetupUtil = new _login_GWizLoginFBWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
      }
   }
}
