package
{
   import configinfo.GWizSettings;
   import configinfo.GWizSetupFiles;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _configinfo_GWizSetupFilesWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _configinfo_GWizSetupFilesWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizSetupFiles.watcherSetupUtil = new _configinfo_GWizSetupFilesWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[3] = new StaticPropertyWatcher("exeDir",{"propertyChange":true},[param4[2]],null);
         param5[0] = new StaticPropertyWatcher("prefsDir",{"propertyChange":true},[param4[0]],null);
         param5[1] = new PropertyWatcher("longestLabel",{"propertyChange":true},[param4[1],param4[4],param4[6],param4[8],param4[10]],param2);
         param5[2] = new PropertyWatcher("width",{"widthChanged":true},[param4[1],param4[4],param4[6],param4[8],param4[10]],null);
         param5[8] = new StaticPropertyWatcher("serverURL",{"propertyChange":true},[param4[9]],param3);
         param5[7] = new StaticPropertyWatcher("fileURL",{"propertyChange":true},[param4[7]],param3);
         param5[4] = new PropertyWatcher("showSharing",{"propertyChange":true},[param4[3]],param2);
         param5[5] = new StaticPropertyWatcher("prefs",null,[param4[5]],null);
         param5[6] = new PropertyWatcher("backupDir",{"propertyChange":true},[param4[5]],null);
         param5[3].updateParent(GWizSettings);
         param5[0].updateParent(GWizSettings);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[2]);
         param5[8].updateParent(GWizSetupFiles);
         param5[7].updateParent(GWizSetupFiles);
         param5[4].updateParent(param1);
         param5[5].updateParent(GWizSettings);
         param5[5].addChild(param5[6]);
      }
   }
}
