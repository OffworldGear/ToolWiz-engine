package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import rtwp.ResizableTitleWindowSkin;
   
   public class _rtwp_ResizableTitleWindowSkinWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _rtwp_ResizableTitleWindowSkinWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         ResizableTitleWindowSkin.watcherSetupUtil = new _rtwp_ResizableTitleWindowSkinWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("bottomGroupMask",{"propertyChange":true},[param4[1]],param2);
         param5[0] = new PropertyWatcher("topGroupMask",{"propertyChange":true},[param4[0]],param2);
         param5[1].updateParent(param1);
         param5[0].updateParent(param1);
      }
   }
}
