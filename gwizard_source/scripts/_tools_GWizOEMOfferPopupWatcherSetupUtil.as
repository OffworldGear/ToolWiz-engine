package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import tools.GWizOEMOfferPopup;
   
   public class _tools_GWizOEMOfferPopupWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _tools_GWizOEMOfferPopupWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizOEMOfferPopup.watcherSetupUtil = new _tools_GWizOEMOfferPopupWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
      }
   }
}
