package
{
   import cadcamwiz.GWizCCWODTurnGridRenderer;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _cadcamwiz_GWizCCWODTurnGridRendererWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _cadcamwiz_GWizCCWODTurnGridRendererWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizCCWODTurnGridRenderer.watcherSetupUtil = new _cadcamwiz_GWizCCWODTurnGridRendererWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[3] = new StaticPropertyWatcher("edgeTypes",{"propertyChange":true},[param4[1]],param3);
         param5[1] = new PropertyWatcher("data",{"dataChange":true},[param4[0]],param2);
         param5[2] = new PropertyWatcher("corner",null,[param4[0]],null);
         param5[3].updateParent(GWizCCWODTurnGridRenderer);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
      }
   }
}
