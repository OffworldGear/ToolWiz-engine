package
{
   import configinfo.GWizSettings;
   import feedsspeeds.GWizTortHare;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizTortHareWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizTortHareWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizTortHare.watcherSetupUtil = new _feedsspeeds_GWizTortHareWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[4] = new PropertyWatcher("typeVisible",{"propertyChange":true},[param4[5]],param2);
         param5[0] = new StaticPropertyWatcher("TortoiseImg",{"propertyChange":true},[param4[0]],null);
         param5[3] = new StaticPropertyWatcher("HareImg",{"propertyChange":true},[param4[4]],null);
         param5[4].updateParent(param1);
         param5[0].updateParent(GWizSettings);
         param5[3].updateParent(GWizSettings);
      }
   }
}
