package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import notebook.GWizNBNewPage;
   
   public class _notebook_GWizNBNewPageWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _notebook_GWizNBNewPageWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizNBNewPage.watcherSetupUtil = new _notebook_GWizNBNewPageWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[4] = new PropertyWatcher("NotepadType",{"propertyChange":true},[param4[3],param4[4]],param2);
         param5[5] = new PropertyWatcher("selected",{"propertyChange":true},[param4[3],param4[4]],null);
         param5[2] = new PropertyWatcher("CSVType",{"propertyChange":true},[param4[1],param4[2]],param2);
         param5[3] = new PropertyWatcher("selected",{"propertyChange":true},[param4[1],param4[2]],null);
         param5[0] = new PropertyWatcher("webURLType",{"propertyChange":true},[param4[0]],param2);
         param5[1] = new PropertyWatcher("selected",{"propertyChange":true},[param4[0]],null);
         param5[4].updateParent(param1);
         param5[4].addChild(param5[5]);
         param5[2].updateParent(param1);
         param5[2].addChild(param5[3]);
         param5[0].updateParent(param1);
         param5[0].addChild(param5[1]);
      }
   }
}
