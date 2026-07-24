package comps
{
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.Timer;
   import mx.core.FlexGlobals;
   import mx.events.CloseEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Application;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizDataGridConfigs extends EventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizDataGridConfigs");
      
      public static const gridConfigs:GWizDataGridConfigs = new GWizDataGridConfigs();
      
      private static var singleton:GWizDataGridConfigs = null;
       
      
      private const configs:Object = new Object();
      
      private const factoryConfigs:Object = new Object();
      
      private var persistTimer:Timer;
      
      public function GWizDataGridConfigs()
      {
         super();
      }
      
      public static function getInstance() : GWizDataGridConfigs
      {
         var _loc1_:Application = null;
         if(singleton == null)
         {
            singleton = new GWizDataGridConfigs();
            singleton.persistTimer = new Timer(1000);
            singleton.persistTimer.addEventListener(TimerEvent.TIMER,singleton.handleTimer);
            _loc1_ = FlexGlobals.topLevelApplication as Application;
            _loc1_.addEventListener(CloseEvent.CLOSE,singleton.handleAppClose);
         }
         return singleton;
      }
      
      private function handleAppClose(param1:Event) : void
      {
         this.flushUpdates();
      }
      
      private function handleTimer(param1:TimerEvent) : void
      {
         this.flushUpdates();
      }
      
      private function flushUpdates() : void
      {
         var _loc1_:* = null;
         var _loc2_:GWizDataGridConfig = null;
         this.persistTimer.stop();
         for(_loc1_ in this.configs)
         {
            _loc2_ = this.configs[_loc1_] as GWizDataGridConfig;
            if(_loc2_.dirty)
            {
               this.writeConfigToFile(_loc1_,_loc2_.configStr);
               _loc2_.dirty = false;
               dispatchEvent(new GWizDataGridEvent(GWizDataGridEvent.CONFIG_CHANGED,_loc1_,_loc2_));
            }
         }
      }
      
      public function register(param1:GWizDataGrid) : GWizDataGridConfig
      {
         var _loc3_:GWizDataGridConfig = null;
         var _loc4_:String = null;
         var _loc2_:String = param1.configId;
         if(GWizStringUtils.isBlank(_loc2_))
         {
            return null;
         }
         if(this.configs.hasOwnProperty(_loc2_))
         {
            return this.configs[_loc2_];
         }
         this.factoryConfigs[_loc2_] = GWizDataGridConfig.fromGrid(param1);
         try
         {
            if((_loc4_ = this.readConfigFromFile(_loc2_)) != null)
            {
               _loc3_ = GWizDataGridConfig.fromConfigStr(_loc4_);
            }
         }
         catch(ignore:Error)
         {
         }
         if(_loc3_ == null)
         {
            _loc3_ = GWizDataGridConfig.fromGrid(param1);
         }
         this.configs[_loc2_] = _loc3_;
         return _loc3_;
      }
      
      private function readConfigFromFile(param1:String) : String
      {
         var configFile:File = null;
         var stream:FileStream = null;
         var configId:String = param1;
         var config:String = null;
         configFile = GWizSettings.getPrefsFile("GWizDataGrid_" + configId + ".csv");
         if(configFile.exists)
         {
            try
            {
               stream = new FileStream();
               stream.open(configFile,FileMode.READ);
               config = stream.readUTFBytes(configFile.size);
               stream.close();
            }
            catch(ignore:Error)
            {
               GWizUtils.LogError("Error loading GWizDataGrid config: " + configFile.nativePath);
            }
         }
         return config;
      }
      
      private function writeConfigToFile(param1:String, param2:String) : void
      {
         var stream:FileStream = null;
         var configId:String = param1;
         var configStr:String = param2;
         var configFile:File = GWizSettings.getPrefsFile("GWizDataGrid_" + configId + ".csv");
         try
         {
            stream = new FileStream();
            stream.open(configFile,FileMode.WRITE);
            stream.writeUTFBytes(configStr);
            stream.close();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error saving GWizDataGrid config for configId: " + configId);
         }
      }
      
      private function deleteConfigFile(param1:String) : void
      {
         var configFile:File = null;
         var configId:String = param1;
         var config:String = null;
         configFile = GWizSettings.getPrefsFile("GWizDataGrid_" + configId + ".csv");
         if(configFile.exists)
         {
            try
            {
               configFile.deleteFile();
            }
            catch(ignore:Error)
            {
               GWizUtils.LogError("Error deleting GWizDataGrid config: " + configFile.nativePath);
            }
         }
      }
      
      public function updateConfig(param1:GWizDataGrid) : void
      {
         if(param1.handleUpdates == false)
         {
            return;
         }
         var _loc2_:String = param1.configId;
         if(GWizStringUtils.isBlank(_loc2_))
         {
            return;
         }
         var _loc3_:GWizDataGridConfig = this.configs[_loc2_];
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_.updateFromGrid(param1))
         {
            this.persistTimer.reset();
            this.persistTimer.start();
         }
      }
      
      public function resetConfig(param1:GWizDataGrid) : void
      {
         var _loc2_:String = param1.configId;
         if(GWizStringUtils.isBlank(_loc2_))
         {
            return;
         }
         if(this.configs.hasOwnProperty(_loc2_))
         {
            this.deleteConfigFile(_loc2_);
            this.configs[_loc2_] = GWizDataGridConfig.fromConfigStr(this.factoryConfigs[_loc2_].configStr);
            param1.configure();
         }
      }
   }
}
