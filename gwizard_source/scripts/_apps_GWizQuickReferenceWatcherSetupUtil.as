package
{
   import apps.GWizQuickReference;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _apps_GWizQuickReferenceWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizQuickReferenceWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizQuickReference.watcherSetupUtil = new _apps_GWizQuickReferenceWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[4] = new PropertyWatcher("tabNav",{"propertyChange":true},[param4[14]],param2);
         param5[2] = new StaticPropertyWatcher("alternateb1",{"propertyChange":true},[param4[1],param4[3],param4[4],param4[5],param4[6],param4[7],param4[8],param4[9],param4[10],param4[11],param4[12],param4[13],param4[15]],null);
         param5[3] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[2],param4[16]],null);
         param5[0] = new PropertyWatcher("tabs",{"propertyChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("height",{"heightChanged":true},[param4[0]],null);
         param5[4].updateParent(param1);
         param5[2].updateParent(ColorPalette);
         param5[3].updateParent(ColorPalette);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
      }
   }
}
