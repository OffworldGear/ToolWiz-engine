package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import skins.AppButtonBarSkinInnerClass2;
   
   public class _skins_AppButtonBarSkinInnerClass2WatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _skins_AppButtonBarSkinInnerClass2WatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         AppButtonBarSkinInnerClass2.watcherSetupUtil = new _skins_AppButtonBarSkinInnerClass2WatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("data",{"dataChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("toolTip",null,[param4[0]],null);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
      }
   }
}
