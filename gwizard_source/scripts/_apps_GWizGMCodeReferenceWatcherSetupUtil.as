package
{
   import apps.GWizGMCodeReference;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import post.GWizGCParseData;
   import utils.ColorPalette;
   
   public class _apps_GWizGMCodeReferenceWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizGMCodeReferenceWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizGMCodeReference.watcherSetupUtil = new _apps_GWizGMCodeReferenceWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[0],param4[3]],null);
         param5[2] = new StaticPropertyWatcher("alternateb4",{"propertyChange":true},[param4[2]],null);
         param5[1] = new StaticPropertyWatcher("OtherCodes",{"propertyChange":true},[param4[1]],null);
         param5[0].updateParent(ColorPalette);
         param5[2].updateParent(ColorPalette);
         param5[1].updateParent(GWizGCParseData);
      }
   }
}
