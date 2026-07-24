package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import tools.GWizCribFormat;
   
   public class _tools_GWizCribFormatWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizCribFormatWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCribFormat.watcherSetupUtil = new _tools_GWizCribFormatWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("source",{"propertyChange":true},[param4[0]],param2);
         param5[0].updateParent(param1);
      }
   }
}
