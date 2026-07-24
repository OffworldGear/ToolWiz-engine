package
{
   import cadcamwiz.GWizCCWTortHare;
   import configinfo.GWizSettings;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCWTortHareWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWTortHareWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWTortHare.watcherSetupUtil = new _cadcamwiz_GWizCCWTortHareWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("TortoiseImg",{"propertyChange":true},[param4[0]],null);
         param5[2] = new StaticPropertyWatcher("HareImg",{"propertyChange":true},[param4[3]],null);
         param5[0].updateParent(GWizSettings);
         param5[2].updateParent(GWizSettings);
      }
   }
}
