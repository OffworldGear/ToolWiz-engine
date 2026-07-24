package
{
   import comps.skins.PanelSkin;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_skins_PanelSkinWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_skins_PanelSkinWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         PanelSkin.watcherSetupUtil = new _comps_skins_PanelSkinWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("hostComponent",{"propertyChange":true},[param4[0],param4[1],param4[2],param4[3],param4[4],param4[5],param4[6],param4[7],param4[8],param4[9],param4[10],param4[11],param4[12]],param2);
         param5[2] = new PropertyWatcher("darkBack",{"propertyChange":true},[param4[1],param4[2],param4[3],param4[4]],null);
         param5[1] = new PropertyWatcher("title",{"propertyChange":true},[param4[0],param4[5],param4[6],param4[7],param4[12]],null);
         param5[3] = new PropertyWatcher("borderColor",{"propertyChange":true},[param4[8]],null);
         param5[5] = new PropertyWatcher("backgroundColor",{"propertyChange":true},[param4[10]],null);
         param5[4] = new PropertyWatcher("borderAlpha",{"propertyChange":true},[param4[9]],null);
         param5[6] = new PropertyWatcher("backgroundAlpha",{"propertyChange":true},[param4[11]],null);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[2]);
         param5[0].addChild(param5[1]);
         param5[0].addChild(param5[3]);
         param5[0].addChild(param5[5]);
         param5[0].addChild(param5[4]);
         param5[0].addChild(param5[6]);
      }
   }
}
