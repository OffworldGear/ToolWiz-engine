package comps
{
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.net.FileFilter;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizFileUtils;
   import utils.GWizUtils;
   
   public class GWizFileBrowser
   {
      
      private static const log:ILogger = Log.getLogger("GWizCSVUtils");
      
      public static var directories:ArrayCollection = new ArrayCollection();
      
      private static var dirFile:File;
      
      private static var dirXML:XML;
       
      
      private var dirName:String;
      
      private var SpecificFilter:FileFilter;
      
      private var AllFilter:FileFilter;
      
      private var fileOpenFcn:Function;
      
      private var fileSaveFcn:Function;
      
      private const ONE_DIR:Boolean = true;
      
      private var saveExtension:String;
      
      public function GWizFileBrowser(param1:String, param2:String, param3:String)
      {
         super();
         this.dirName = param1;
         this.SpecificFilter = new FileFilter(param2,param3);
         this.AllFilter = new FileFilter("All Files","*.*");
      }
      
      public static function loadDirs() : void
      {
         var stream:FileStream = null;
         dirFile = GWizSettings.getPrefsFile("fileDirs.xml");
         try
         {
            stream = new FileStream();
            if(dirFile.exists)
            {
               stream.open(dirFile,FileMode.READ);
               dirXML = XML(stream.readUTFBytes(stream.bytesAvailable));
               stream.close();
               GWizUtils.XMLToArrayCollection(dirXML,directories);
            }
            else
            {
               saveDirs();
            }
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error saving directory preferences.");
         }
      }
      
      public static function saveDirs() : void
      {
         saveDirsAux(directories,dirFile);
      }
      
      public static function saveDirsAux(param1:ArrayCollection, param2:File) : void
      {
         var _loc6_:Object = null;
         var _loc3_:* = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
         _loc3_ += "<root>\n";
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc6_ = param1.getItemAt(_loc4_);
            _loc3_ += "  <item>\n";
            _loc3_ += "    <name>" + _loc6_.name + "</name>\n";
            _loc3_ += "    <url>" + _loc6_.url + "</url>\n";
            _loc3_ += "  </item>\n";
            _loc4_++;
         }
         _loc3_ += "</root>\n";
         _loc3_ = _loc3_.replace(/\n/g,File.lineEnding);
         var _loc5_:FileStream;
         (_loc5_ = new FileStream()).open(param2,FileMode.WRITE);
         _loc5_.writeUTFBytes(_loc3_);
         _loc5_.close();
      }
      
      private function set dirURL(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < directories.length)
         {
            _loc2_ = directories.getItemAt(_loc3_);
            if(this.ONE_DIR || _loc2_.name == this.dirName)
            {
               _loc2_.url = param1;
               break;
            }
            _loc3_++;
         }
         if(_loc3_ >= directories.length)
         {
            _loc2_ = new Object();
            _loc2_.name = this.dirName;
            _loc2_.url = param1;
            directories.addItem(_loc2_);
         }
      }
      
      private function get dirURL() : String
      {
         var _loc3_:Object = null;
         var _loc1_:String = "";
         var _loc2_:int = 0;
         while(_loc2_ < directories.length)
         {
            _loc3_ = directories.getItemAt(_loc2_);
            if(this.ONE_DIR || _loc3_.name == this.dirName && _loc3_.hasOwnProperty("url") && _loc3_.url.toString() != "undefined" && _loc3_.url && String(_loc3_.url).length > 0)
            {
               _loc1_ = _loc3_.url;
               break;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function doFileOpen(param1:Function, param2:String = "Open") : void
      {
         var file:File = null;
         var fileSelectedForOpen:Function = param1;
         var msg:String = param2;
         if(this.dirURL != "")
         {
            file = new File(this.dirURL);
         }
         else
         {
            file = new File();
         }
         this.fileOpenFcn = fileSelectedForOpen;
         try
         {
            file.addEventListener(Event.SELECT,this.fileSelectedForOpenAux,false,0,true);
            file.browseForOpen(msg,[this.SpecificFilter,this.AllFilter]);
         }
         catch(e:Error)
         {
            log.debug("Error in browseForOpen: " + e.errorID + ", msg = " + e.message);
         }
      }
      
      public function doFileSaveAs(param1:Function, param2:String = "Save", param3:String = "") : void
      {
         var file:File = null;
         var fileSelectedForSave:Function = param1;
         var msg:String = param2;
         var defName:String = param3;
         this.saveExtension = "";
         if(this.dirURL != "")
         {
            file = new File(this.dirURL);
         }
         else if(defName && defName != "")
         {
            file = File.desktopDirectory.resolvePath(defName);
            if(defName && defName != "")
            {
               this.saveExtension = file.extension;
            }
         }
         else
         {
            file = new File(File.documentsDirectory.url);
         }
         this.fileSaveFcn = fileSelectedForSave;
         file.addEventListener(Event.SELECT,this.fileSelectedForSaveAux,false,0,true);
         try
         {
            file.browseForSave(msg);
         }
         catch(e:Error)
         {
            log.debug("Error in file.browseForSave called by GWizFileBrowser.doFileSaveAs");
         }
      }
      
      private function fileSelectedForOpenAux(param1:Event) : void
      {
         var _loc2_:File = File(param1.target);
         this.dirURL = GWizFileUtils.nativePathToDir(_loc2_.nativePath);
         if(this.fileOpenFcn != null)
         {
            this.fileOpenFcn(_loc2_);
         }
      }
      
      private function fileSelectedForSaveAux(param1:Event) : void
      {
         var _loc3_:String = null;
         log.debug("fileSelectedForSaveAux");
         var _loc2_:File = File(param1.target);
         if(this.saveExtension && this.saveExtension != "" && _loc2_.extension != this.saveExtension)
         {
            _loc3_ = _loc2_.url;
            _loc3_ = _loc3_.substr(0,_loc3_.length - _loc2_.extension.length) + this.saveExtension;
            _loc2_ = new File(_loc3_);
         }
         this.dirURL = GWizFileUtils.nativePathToDir(_loc2_.nativePath);
         if(this.fileSaveFcn != null)
         {
            this.fileSaveFcn(File(param1.target));
         }
      }
   }
}
