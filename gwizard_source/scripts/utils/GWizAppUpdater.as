package utils
{
   import chimp.GWizMandrill;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.desktop.NativeApplication;
   import flash.desktop.NativeProcess;
   import flash.desktop.NativeProcessStartupInfo;
   import flash.events.StorageVolumeChangeEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.filesystem.StorageVolumeInfo;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizAppUpdater
   {
      
      private static const log:ILogger = Log.getLogger("GWizAppUpdater");
      
      public static var downloadNewVersion:Boolean = false;
      
      private static var downloadVersion:Number;
      
      public static const ALLOW_NEW_VERSION_DOWNLOAD:Boolean = false;
       
      
      public function GWizAppUpdater()
      {
         super();
      }
      
      public static function newVersionDownload(param1:Number) : void
      {
         setupForInstall();
         GWizSettings.versionBeingDownloaded = NaN;
         downloadVersion = param1;
         downloadNewVersionFile();
      }
      
      public static function setupForInstall() : void
      {
         GWizSettings.loginBar.Status.text = "A newer version of the software is available:";
         GWizSettings.loginBar.Status.setStyle("color","#F1AC55");
         GWizSettings.loginBar.installLink.label = "Install";
         GWizSettings.loginBar.installLink.visible = true;
         GWizSettings.loginBar.installLink.toolTip = "Pop up a browser and go to the install page.";
         GWizSettings.loginBar.installLink.setStyle("chromeColor","#F1AC55");
      }
      
      public static function runNewVersion() : void
      {
         var _loc1_:File = null;
         if(GWizAppUpdater.ALLOW_NEW_VERSION_DOWNLOAD && downloadNewVersion && Capabilities.os.indexOf("Windows") >= 0)
         {
            _loc1_ = getExeDownloadFile();
            if(_loc1_ && _loc1_.exists)
            {
               if(Capabilities.os.indexOf("Mac") >= 0)
               {
                  StorageVolumeInfo.storageVolumeInfo.addEventListener(StorageVolumeChangeEvent.STORAGE_VOLUME_MOUNT,onStorageVolumeMount);
                  _loc1_.openWithDefaultApplication();
               }
               else
               {
                  installFromFile(_loc1_);
               }
            }
         }
         else
         {
            NativeApplication.nativeApplication.exit();
         }
      }
      
      private static function installFromFile(param1:File) : void
      {
         var _loc2_:NativeProcessStartupInfo = new NativeProcessStartupInfo();
         _loc2_.executable = param1;
         log.debug("New update file about to be run from: " + param1.nativePath);
         var _loc3_:NativeProcess = new NativeProcess();
         _loc3_.start(_loc2_);
      }
      
      private static function onStorageVolumeMount(param1:StorageVolumeChangeEvent) : void
      {
         StorageVolumeInfo.storageVolumeInfo.removeEventListener(StorageVolumeChangeEvent.STORAGE_VOLUME_MOUNT,onStorageVolumeMount);
         var _loc2_:File = getExeDownloadFile();
         installFromFile(_loc2_);
      }
      
      private static function getExeDownloadFile() : File
      {
         var _loc1_:File = File.applicationStorageDirectory;
         return _loc1_.resolvePath(getExeName());
      }
      
      private static function getExeName() : String
      {
         var _loc1_:* = GWizSettings.loginBar.appNameParm;
         if(_loc1_ == "GWizard" && GWizAbstractPrefs.isOEM)
         {
            _loc1_ = GWizAbstractPrefs.oemStr + "Calc";
         }
         if(Capabilities.os.indexOf("Mac") >= 0)
         {
            _loc1_ += ".dmg";
         }
         else
         {
            _loc1_ += ".exe";
         }
         return _loc1_;
      }
      
      private static function downloadNewVersionFile() : void
      {
         var _loc1_:String = null;
         var _loc2_:GWizURLLoader = null;
         if(GWizAppUpdater.ALLOW_NEW_VERSION_DOWNLOAD)
         {
            GWizSettings.versionBeingDownloaded = NaN;
            _loc1_ = "https://www.cnccookbook.com/GWizard/" + getExeName();
            log.debug("Download url = \'" + _loc1_ + "\'");
            _loc2_ = new GWizURLLoader();
            _loc2_.loadURL(_loc1_,loadedFcn);
         }
      }
      
      private static function loadedFcn(param1:ByteArray, param2:String) : void
      {
         var stream:FileStream = null;
         var exeFile:File = null;
         var exeBits:ByteArray = param1;
         var url:String = param2;
         if(exeBits && exeBits.length > 0)
         {
            try
            {
               stream = new FileStream();
               exeFile = getExeDownloadFile();
               if(exeFile.exists)
               {
                  exeFile.deleteFile();
               }
               log.debug("EXE file Download destination: " + exeFile.nativePath);
               stream.open(exeFile,FileMode.WRITE);
               stream.writeBytes(exeBits);
               stream.close();
               GWizSettings.versionBeingDownloaded = downloadVersion;
               return;
            }
            catch(e:Error)
            {
               GWizUtils.LogError("Error with new version download: " + e.message);
               GWizMandrill.msg("Install Failure","Couldn\'t write new version EXE file.");
            }
         }
         else
         {
            GWizMandrill.msg("Install Failure","Couldn\'t download new version EXE file.");
         }
         setupForInstall();
      }
   }
}
