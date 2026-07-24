package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import views.GWizElectricalCalc;
   
   public class _views_GWizElectricalCalcWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizElectricalCalcWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizElectricalCalc.watcherSetupUtil = new _views_GWizElectricalCalcWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[3] = new PropertyWatcher("digitBandNames",{"propertyChange":true},[param4[5],param4[8],param4[11]],param2);
         param5[4] = new PropertyWatcher("colorEntryRenderer",{"propertyChange":true},[param4[6],param4[9],param4[12],param4[15],param4[18],param4[21]],param2);
         param5[8] = new PropertyWatcher("tolBandNames",{"propertyChange":true},[param4[17]],param2);
         param5[6] = new PropertyWatcher("multBandNames",{"propertyChange":true},[param4[14]],param2);
         param5[5] = new PropertyWatcher("multBandColors",{"propertyChange":true},[param4[13]],param2);
         param5[10] = new PropertyWatcher("tempBandNames",{"propertyChange":true},[param4[20]],param2);
         param5[9] = new PropertyWatcher("tempBandColors",{"propertyChange":true},[param4[19]],param2);
         param5[2] = new PropertyWatcher("digitBandColors",{"propertyChange":true},[param4[4],param4[7],param4[10]],param2);
         param5[0] = new PropertyWatcher("electricalViews",{"propertyChange":true},[param4[0]],param2);
         param5[7] = new PropertyWatcher("tolBandColors",{"propertyChange":true},[param4[16]],param2);
         param5[3].updateParent(param1);
         param5[4].updateParent(param1);
         param5[8].updateParent(param1);
         param5[6].updateParent(param1);
         param5[5].updateParent(param1);
         param5[10].updateParent(param1);
         param5[9].updateParent(param1);
         param5[2].updateParent(param1);
         param5[0].updateParent(param1);
         param5[7].updateParent(param1);
      }
   }
}
