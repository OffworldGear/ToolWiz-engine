package
{
   import configinfo.GWizSettings;
   import feedsspeeds.GWizDeflectOptions;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _feedsspeeds_GWizDeflectOptionsWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _feedsspeeds_GWizDeflectOptionsWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizDeflectOptions.watcherSetupUtil = new _feedsspeeds_GWizDeflectOptionsWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[3] = new StaticPropertyWatcher("deflectPct",{"propertyChange":true},[param4[2]],null);
         param5[0] = new StaticPropertyWatcher("limitChatterAux",{"propertyChange":true},[param4[0]],param3);
         param5[4] = new StaticPropertyWatcher("bestFinishAux",{"propertyChange":true},[param4[3]],param3);
         param5[1] = new PropertyWatcher("limitChatter",{"propertyChange":true},[param4[1]],param2);
         param5[2] = new PropertyWatcher("selected",{"propertyChange":true},[param4[1]],null);
         param5[3].updateParent(GWizSettings);
         param5[0].updateParent(GWizDeflectOptions);
         param5[4].updateParent(GWizDeflectOptions);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
      }
   }
}
