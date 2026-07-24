package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import views.GWizUnitChooser;
   
   public class _views_GWizUnitChooserWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizUnitChooserWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizUnitChooser.watcherSetupUtil = new _views_GWizUnitChooserWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("unitFromList",{"propertyChange":true},[param4[1]],param2);
         param5[0] = new PropertyWatcher("unitTypeList",{"propertyChange":true},[param4[0]],param2);
         param5[2] = new PropertyWatcher("unitToList",{"propertyChange":true},[param4[2]],param2);
         param5[1].updateParent(param1);
         param5[0].updateParent(param1);
         param5[2].updateParent(param1);
      }
   }
}
