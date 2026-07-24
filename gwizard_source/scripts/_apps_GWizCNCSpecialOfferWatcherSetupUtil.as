package
{
   import apps.GWizCNCSpecialOffer;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _apps_GWizCNCSpecialOfferWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizCNCSpecialOfferWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCNCSpecialOffer.watcherSetupUtil = new _apps_GWizCNCSpecialOfferWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[3] = new PropertyWatcher("usedBy2",{"propertyChange":true},[param4[3],param4[5]],param2);
         param5[4] = new PropertyWatcher("width",{"widthChanged":true},[param4[3],param4[5]],null);
         param5[0] = new StaticPropertyWatcher("url",{"propertyChange":true},[param4[0],param4[2],param4[4]],param3);
         param5[1] = new PropertyWatcher("usedBy",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new PropertyWatcher("width",{"widthChanged":true},[param4[1]],null);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[4]);
         param5[0].updateParent(GWizCNCSpecialOffer);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
      }
   }
}
