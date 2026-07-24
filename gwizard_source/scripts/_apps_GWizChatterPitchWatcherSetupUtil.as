package
{
   import apps.GWizChatterPitch;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import utils.ColorPalette;
   
   public class _apps_GWizChatterPitchWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _apps_GWizChatterPitchWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizChatterPitch.watcherSetupUtil = new _apps_GWizChatterPitchWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new StaticPropertyWatcher("alternateb3",{"propertyChange":true},[param4[1],param4[2],param4[10]],null);
         param5[0] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[0],param4[3],param4[11]],null);
         param5[4] = new PropertyWatcher("MarkSep",{"propertyChange":true},[param4[6],param4[7],param4[8],param4[9]],param2);
         param5[8] = new PropertyWatcher("stepper",{"propertyChange":true},[param4[9]],null);
         param5[9] = new PropertyWatcher("width",{"widthChanged":true},[param4[9]],null);
         param5[7] = new PropertyWatcher("width",{"widthChanged":true},[param4[7]],null);
         param5[5] = new PropertyWatcher("theLabel",{"propertyChange":true},[param4[6],param4[8]],null);
         param5[6] = new PropertyWatcher("width",{"widthChanged":true},[param4[6],param4[8]],null);
         param5[1].updateParent(ColorPalette);
         param5[0].updateParent(ColorPalette);
         param5[4].updateParent(param1);
         param5[4].addChild(param5[8]);
         param5[8].addChild(param5[9]);
         param5[4].addChild(param5[7]);
         param5[4].addChild(param5[5]);
         param5[5].addChild(param5[6]);
      }
   }
}
