package
{
   import feedsspeeds.GWizMfgCutterSpecs;
   import feedsspeeds.GWizMfgFamilyPopup;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _feedsspeeds_GWizMfgFamilyPopupWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizMfgFamilyPopupWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizMfgFamilyPopup.watcherSetupUtil = new _feedsspeeds_GWizMfgFamilyPopupWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[5] = new StaticPropertyWatcher("chiploadExamples",{"propertyChange":true},[param4[8]],null);
         param5[1] = new PropertyWatcher("familyList",{"propertyChange":true},[param4[1],param4[2],param4[3],param4[4]],param2);
         param5[2] = new PropertyWatcher("width",{"widthChanged":true},[param4[1],param4[2],param4[3],param4[4]],null);
         param5[4] = new StaticPropertyWatcher("sfmExamples",{"propertyChange":true},[param4[6]],null);
         param5[0] = new StaticPropertyWatcher("familyListData",{"propertyChange":true},[param4[0]],null);
         param5[3] = new StaticPropertyWatcher("secondaryb1",{"propertyChange":true},[param4[5],param4[7]],null);
         param5[5].updateParent(GWizMfgCutterSpecs);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
         param5[4].updateParent(GWizMfgCutterSpecs);
         param5[0].updateParent(GWizMfgCutterSpecs);
         param5[3].updateParent(ColorPalette);
      }
   }
}
