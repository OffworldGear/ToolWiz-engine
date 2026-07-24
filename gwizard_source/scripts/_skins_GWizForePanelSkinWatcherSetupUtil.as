package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.GWizForePanelSkin;
   
   public class _skins_GWizForePanelSkinWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _skins_GWizForePanelSkinWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizForePanelSkin.watcherSetupUtil = new _skins_GWizForePanelSkinWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("hostComponent",{"propertyChange":true},[param4[0],param4[1],param4[2],param4[3],param4[4],param4[5],param4[6],param4[7],param4[8],param4[9],param4[10],param4[11],param4[12],param4[13],param4[14]],param2);
         param5[3] = new PropertyWatcher("labelWidth",{"propertyChange":true},[param4[0],param4[2],param4[6],param4[10]],null);
         param5[1] = new PropertyWatcher("title",{"propertyChange":true},[param4[0],param4[2],param4[5],param4[8],param4[10]],null);
         param5[9] = new PropertyWatcher("gapSize",{"propertyChange":true},[param4[10],param4[11],param4[12],param4[13],param4[14]],null);
         param5[8] = new PropertyWatcher("labelColor",{"propertyChange":true},[param4[9]],null);
         param5[4] = new PropertyWatcher("contentBackgroundTexture",{"propertyChange":true},[param4[1]],null);
         param5[6] = new PropertyWatcher("contentFillAlpha",{"propertyChange":true},[param4[4]],null);
         param5[7] = new PropertyWatcher("labelBackgroundColor",{"propertyChange":true},[param4[7]],null);
         param5[5] = new PropertyWatcher("contentBackgroundColor",{"propertyChange":true},[param4[3]],null);
         param5[2] = new PropertyWatcher("hideLabel",{"propertyChange":true},[param4[0],param4[2],param4[5],param4[10]],null);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[3]);
         param5[0].addChild(param5[1]);
         param5[0].addChild(param5[9]);
         param5[0].addChild(param5[8]);
         param5[0].addChild(param5[4]);
         param5[0].addChild(param5[6]);
         param5[0].addChild(param5[7]);
         param5[0].addChild(param5[5]);
         param5[0].addChild(param5[2]);
      }
   }
}
