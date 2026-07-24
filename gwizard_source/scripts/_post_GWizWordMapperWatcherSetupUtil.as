package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import post.GWizWordMapper;
   
   public class _post_GWizWordMapperWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _post_GWizWordMapperWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizWordMapper.watcherSetupUtil = new _post_GWizWordMapperWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("mapList",{"propertyChange":true},[param4[0]],param3);
         param5[0].updateParent(GWizWordMapper);
      }
   }
}
