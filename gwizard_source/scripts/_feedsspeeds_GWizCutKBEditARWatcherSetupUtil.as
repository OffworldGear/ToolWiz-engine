package
{
   import configinfo.GWizConfigData;
   import feedsspeeds.GWizCutKBEditAR;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizCutKBEditARWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizCutKBEditARWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCutKBEditAR.watcherSetupUtil = new _feedsspeeds_GWizCutKBEditARWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("ToolWear",{"propertyChange":true},[param4[0]],null);
         param5[2] = new StaticPropertyWatcher("CoolantTypes",{"propertyChange":true},[param4[2]],null);
         param5[1] = new StaticPropertyWatcher("HolderTypes",{"propertyChange":true},[param4[1]],null);
         param5[0].updateParent(GWizConfigData);
         param5[2].updateParent(GWizConfigData);
         param5[1].updateParent(GWizConfigData);
      }
   }
}
