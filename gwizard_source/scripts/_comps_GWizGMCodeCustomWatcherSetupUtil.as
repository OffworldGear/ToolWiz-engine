package
{
   import comps.GWizGMCodeCustom;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import post.GWizGCParseData;
   
   public class _comps_GWizGMCodeCustomWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizGMCodeCustomWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizGMCodeCustom.watcherSetupUtil = new _comps_GWizGMCodeCustomWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("CodeTypes",{"propertyChange":true},[param4[0]],null);
         param5[1] = new PropertyWatcher("Macro",{"propertyChange":true},[param4[1],param4[2]],param2);
         param5[2] = new PropertyWatcher("selected",{"propertyChange":true},[param4[1],param4[2]],null);
         param5[0].updateParent(GWizGCParseData);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
      }
   }
}
