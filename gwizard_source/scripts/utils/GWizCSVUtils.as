package utils
{
   import comps.GWizFileBrowser;
   import comps.GWizPopUpManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizCSVUtils implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizCSVUtils");
      
      public static var fieldList:Array = null;
      
      public static const MM_SUFFIX:String = "-mm";
      
      public static const MPM_SUFFIX:String = "-mpm";
      
      private static const MAX_FIELDS:int = 150;
      
      public static var CSVToArrayColMsg:String = "";
      
      private static var buffer:String = "";
      
      private static var parseErr:Boolean = false;
      
      private static var parseMsg:String = "";
      
      private static var EOL:Boolean = false;
      
      private static const MAX_TOKEN_LENGTH:int = 1024;
      
      private static var downloadCSVCallback:Function = null;
      
      private static var currCSVDownloading:String = "";
      
      private static var csvDownloadQueue:Array = [];
       
      
      private var exportResults:ArrayCollection = null;
      
      private var exportFieldList:Array = null;
      
      private var _208553304importDir:String;
      
      private var importFcn:Function = null;
      
      private var showMsg:Boolean = true;
      
      private var allowAngleBrackets:Boolean = false;
      
      private var forceFields:Array = null;
      
      private var delimeter:String = ",";
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizCSVUtils()
      {
         this._208553304importDir = GWizFileUtils.nativePathToDir(File.documentsDirectory.nativePath);
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      public static function arrayColToCSV(param1:ArrayCollection, param2:String, param3:Array, param4:Boolean = false) : String
      {
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:* = null;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc15_:Object = null;
         var _loc16_:String = null;
         var _loc5_:* = "";
         if(param1.length > 0)
         {
            _loc6_ = param1.getItemAt(0);
            _loc7_ = [];
            if(!param3 || param3.length == 0)
            {
               for(_loc10_ in _loc6_)
               {
                  _loc7_.push(_loc10_);
                  _loc5_ += _loc10_ + param2;
               }
            }
            else
            {
               _loc11_ = 0;
               while(_loc11_ < param3.length)
               {
                  _loc12_ = param3[_loc11_];
                  _loc7_.push(_loc12_);
                  _loc5_ += _loc12_ + param2;
                  _loc11_++;
               }
            }
            _loc8_ = 0;
            while(_loc8_ < _loc7_.length)
            {
               if(_loc7_[_loc8_] == "")
               {
                  if(GWizUtils.debug)
                  {
                     GWizUtils.assert(false);
                  }
                  return "";
               }
               _loc8_++;
            }
            if(_loc5_.length > param2.length)
            {
               _loc5_ = _loc5_.substr(0,_loc5_.length - param2.length);
            }
            _loc5_ += "\n";
            if(param4)
            {
               _loc5_ += "***";
            }
            _loc9_ = 0;
            while(_loc9_ < param1.length)
            {
               _loc6_ = param1.getItemAt(_loc9_);
               _loc13_ = 0;
               while(_loc13_ < _loc7_.length)
               {
                  _loc14_ = _loc7_[_loc13_];
                  if((_loc15_ = _loc6_[_loc14_]) != null)
                  {
                     if(_loc15_ is String)
                     {
                        _loc16_ = _loc15_ as String;
                        if(false && GWizUtils.debug && _loc7_[_loc13_] == "description")
                        {
                           log.debug("description = " + _loc16_);
                        }
                        _loc5_ += handleSpecialChars(_loc16_);
                     }
                     else
                     {
                        _loc5_ += _loc15_;
                        if(GWizUtils.debug)
                        {
                           if(_loc14_ == "quantity" && Number(_loc15_) > 0)
                           {
                              log.debug("columnValue = \'" + _loc15_ + "\'");
                           }
                        }
                     }
                  }
                  else
                  {
                     _loc5_ += " ";
                  }
                  if(_loc13_ < _loc7_.length - 1)
                  {
                     _loc5_ += param2;
                  }
                  _loc13_++;
               }
               _loc5_ += "\n";
               if(param4)
               {
                  _loc5_ += "***";
               }
               _loc9_++;
            }
         }
         return _loc5_;
      }
      
      private static function handleSpecialCharsOriginalFlava(param1:String) : String
      {
         var _loc2_:String = "";
         var _loc3_:int = 0;
         while(param1 != _loc2_ && _loc3_ < 100)
         {
            _loc2_ = param1;
            param1 = param1.replace(","," ");
            param1 = param1.replace("\'"," ");
            param1 = param1.replace("\""," ");
            param1 = param1.replace("\n"," ");
         }
         return param1;
      }
      
      private static function handleSpecialChars(param1:String) : String
      {
         var _loc6_:* = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc2_:* = param1.indexOf("\"") >= 0;
         var _loc3_:* = param1.indexOf(",") >= 0;
         var _loc4_:Boolean = param1.indexOf("\n") >= 0 || param1.indexOf("\r") >= 0;
         if(_loc2_)
         {
            _loc6_ = "";
            _loc7_ = 0;
            while(_loc7_ < param1.length)
            {
               _loc8_ = param1.charAt(_loc7_);
               _loc6_ += param1.charAt(_loc7_);
               if(_loc8_ == "\"")
               {
                  _loc6_ += "\"";
               }
               _loc7_++;
            }
            param1 = _loc6_;
         }
         if(_loc2_ || _loc3_)
         {
            param1 = "\"" + param1 + "\"";
         }
         if(_loc4_)
         {
            _loc9_ = "";
            _loc10_ = 0;
            while(param1 != _loc9_ && _loc10_ < 100 && param1.length > 0)
            {
               _loc9_ = param1;
               param1 = param1.replace("\n"," ");
               param1 = param1.replace("\r"," ");
            }
         }
         var _loc5_:String = "";
         while(_loc5_ != param1 && param1 != "")
         {
            _loc5_ = param1;
            param1 = param1.replace("<p>","");
            param1 = param1.replace("</p>","");
            param1 = param1.replace("<font color=","");
            param1 = param1.replace("ff0000","");
            param1 = param1.replace("</font>","");
         }
         return param1;
      }
      
      public static function CSVToArrayCol(param1:String, param2:String, param3:Boolean = true, param4:Boolean = false, param5:Array = null) : ArrayCollection
      {
         var _loc14_:int = 0;
         var _loc15_:String = null;
         var _loc16_:Boolean = false;
         var _loc17_:int = 0;
         var _loc18_:Object = null;
         var _loc19_:String = null;
         var _loc20_:String = null;
         var _loc21_:Number = NaN;
         buffer = param1;
         CSVToArrayColMsg = "";
         var _loc6_:ArrayCollection = new ArrayCollection();
         var _loc7_:Boolean = false;
         var _loc8_:String = "";
         fieldList = [];
         parseErr = false;
         if(param5)
         {
            _loc14_ = 0;
            _loc15_ = param5[_loc14_];
            _loc16_ = false;
            while(!_loc7_)
            {
               _loc8_ = getToken(param2);
               _loc16_ = false;
               if(EOL || buffer.length <= 0)
               {
                  _loc7_ = true;
               }
               if(_loc8_.length > 0 && _loc8_ == _loc15_)
               {
                  fieldList.push(_loc8_);
                  if(fieldList.length > MAX_FIELDS)
                  {
                     _loc7_ = true;
                     return null;
                  }
                  _loc14_++;
                  _loc15_ = param5[_loc14_];
               }
               else
               {
                  _loc14_ = 0;
                  _loc15_ = param5[_loc14_];
                  _loc16_ = true;
               }
               if(_loc16_ || _loc14_ == param5.length)
               {
                  _loc17_ = 0;
                  while(!EOL && _loc17_ <= MAX_FIELDS)
                  {
                     _loc8_ = getToken(param2);
                     _loc17_++;
                  }
                  if(_loc17_ > MAX_FIELDS)
                  {
                     _loc7_ = true;
                     return null;
                  }
               }
               if(_loc14_ == param5.length)
               {
                  _loc7_ = true;
               }
            }
         }
         else
         {
            while(!_loc7_)
            {
               _loc8_ = getToken(param2);
               if(EOL || buffer.length <= 0)
               {
                  _loc7_ = true;
               }
               if(_loc8_.length > 0)
               {
                  fieldList.push(_loc8_);
                  if(fieldList.length > MAX_FIELDS)
                  {
                     _loc7_ = true;
                     return null;
                  }
               }
            }
         }
         _loc7_ = buffer.length <= 0 || fieldList.length > MAX_FIELDS;
         var _loc9_:int = 0;
         var _loc10_:Object = new Object();
         var _loc11_:Boolean = false;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         while(!_loc7_)
         {
            _loc8_ = getToken(param2,param4);
            if(buffer.length <= 0 || parseErr)
            {
               _loc7_ = true;
               if(parseErr)
               {
                  if(parseMsg.length > 0)
                  {
                     parseMsg += " Error on row " + String(2 + _loc13_) + ", ";
                  }
                  return null;
               }
            }
            if(_loc8_.toLowerCase() == "false")
            {
               _loc18_ = "false";
            }
            else if(_loc8_.toLowerCase() == "true")
            {
               _loc18_ = "true";
            }
            else
            {
               _loc18_ = _loc8_;
            }
            if(_loc8_.length > 0)
            {
               _loc11_ = true;
            }
            if(_loc9_ < fieldList.length)
            {
               _loc20_ = (_loc19_ = fieldList[_loc9_] as String).substr(Math.max(_loc19_.length - 3,0));
               if(_loc19_.indexOf(MM_SUFFIX) != -1)
               {
                  _loc20_ = _loc19_.substr(MM_SUFFIX.length);
               }
               else if(_loc19_.indexOf(MPM_SUFFIX) != -1)
               {
                  _loc20_ = _loc19_.substr(MPM_SUFFIX.length);
               }
               else
               {
                  _loc20_ = "";
               }
               if(param3 && _loc20_.length > 0)
               {
                  _loc21_ = Number(_loc18_ as String);
                  if(_loc20_ == MM_SUFFIX)
                  {
                     _loc21_ /= 25.4;
                  }
                  else if(_loc20_ == MPM_SUFFIX)
                  {
                     _loc21_ /= 12 * 25.4 / 1000;
                  }
                  if(!isNaN(_loc21_))
                  {
                     _loc18_ = _loc21_;
                  }
                  _loc19_ = _loc19_.substr(0,_loc19_.length - _loc20_.length);
               }
               _loc10_[_loc19_] = _loc18_;
            }
            else if(_loc8_.length > 0)
            {
               log.debug("Ignored extra column in row " + _loc13_ + " token = \'" + _loc8_ + "\'");
            }
            if(EOL)
            {
               if(_loc11_)
               {
                  _loc6_.addItem(_loc10_);
                  _loc13_++;
               }
               _loc10_ = new Object();
               _loc9_ = 0;
               _loc11_ = false;
            }
            else
            {
               _loc9_++;
            }
            _loc12_++;
         }
         return _loc6_;
      }
      
      private static function getToken(param1:String, param2:Boolean = false, param3:Boolean = false) : String
      {
         var _loc8_:* = false;
         var _loc9_:* = false;
         if(parseErr)
         {
            return "";
         }
         parseMsg = "";
         EOL = false;
         var _loc4_:String = "";
         var _loc5_:* = false;
         var _loc6_:int = 0;
         while(_loc6_ < buffer.length)
         {
            _loc8_ = false;
            switch(buffer.charAt(_loc6_))
            {
               case param1:
               case GWizStringUtils.CR:
               case GWizStringUtils.LF:
                  _loc8_ = !_loc5_;
                  break;
               case "\"":
                  if(param1 == ",")
                  {
                     if(_loc6_ == buffer.length - 1)
                     {
                        _loc5_ = !_loc5_;
                     }
                     else if(buffer.charAt(_loc6_ + 1) != "\"")
                     {
                        _loc5_ = !_loc5_;
                     }
                     else
                     {
                        _loc6_++;
                     }
                  }
                  break;
               case "<":
                  if(!param2 && !_loc5_)
                  {
                     _loc5_ = true;
                  }
                  break;
               case ">":
                  if(!param2 && _loc5_)
                  {
                     _loc5_ = false;
                  }
            }
            _loc9_ = _loc6_ == buffer.length - 1;
            if(_loc8_ || _loc9_)
            {
               _loc4_ = buffer.substr(0,_loc6_);
               if(_loc9_)
               {
                  EOL = true;
               }
               else if(buffer.length > _loc6_)
               {
                  if(buffer.charAt(_loc6_) == GWizStringUtils.CR || buffer.charAt(_loc6_) == GWizStringUtils.LF)
                  {
                     EOL = true;
                     if(buffer.length > _loc6_ + 1)
                     {
                        if(buffer.charAt(_loc6_ + 1) == GWizStringUtils.CR || buffer.charAt(_loc6_ + 1) == GWizStringUtils.LF)
                        {
                           _loc6_++;
                        }
                     }
                  }
               }
               else
               {
                  EOL = false;
               }
               buffer = buffer.substr(_loc6_ + 1,buffer.length - _loc6_ - 1);
               if(!param2 && _loc4_.charAt(0) == "<" || _loc4_.charAt(0) == "\"")
               {
                  _loc4_ = _loc4_.substr(1,_loc4_.length - 1);
               }
               if(!param2 && _loc4_.charAt(_loc4_.length - 1) == ">" || _loc4_.charAt(0) == "\"")
               {
                  _loc4_ = _loc4_.substr(0,_loc4_.length - 1);
               }
               break;
            }
            _loc6_++;
         }
         if(!(_loc4_.length == 0 && buffer.length <= 0))
         {
            if(_loc4_.length > MAX_TOKEN_LENGTH)
            {
               parseErr = true;
               parseMsg = "Exceeded MAX_TOKEN_LENGTH on csv import.";
               log.debug(parseMsg);
            }
         }
         if(_loc4_.length > 1 && _loc4_.charAt(_loc4_.length - 1) == "\"" && _loc4_.charAt(_loc4_.length - 2) != "\"")
         {
            _loc4_ = _loc4_.substr(0,_loc4_.length - 1);
         }
         var _loc7_:int = _loc4_.length;
         _loc4_ = _loc4_.replace("\"\"","\"");
         while(_loc7_ != _loc4_.length)
         {
            _loc7_ = _loc4_.length;
            _loc4_ = _loc4_.replace("\"\"","\"");
         }
         return _loc4_;
      }
      
      public static function loadCSV(param1:String) : ArrayCollection
      {
         return loadCSVFile(new File(param1));
      }
      
      public static function downloadCSV(param1:String, param2:Function) : void
      {
         GWizUtils.assert(param2 != null);
         var _loc3_:Object = new Object();
         _loc3_.callback = param2;
         _loc3_.url = param1;
         csvDownloadQueue.push(_loc3_);
         downloader();
      }
      
      private static function downloader() : void
      {
         var _loc1_:Object = null;
         var _loc2_:GWizURLLoader = null;
         if(csvDownloadQueue.length > 0 && downloadCSVCallback == null)
         {
            _loc1_ = csvDownloadQueue.pop();
            downloadCSVCallback = _loc1_.callback;
            currCSVDownloading = _loc1_.url;
            _loc2_ = new GWizURLLoader();
            _loc2_.loadURL(currCSVDownloading,csvLoaded,true);
         }
      }
      
      private static function csvLoaded(param1:String, param2:String) : void
      {
         var _loc3_:ArrayCollection = null;
         if(param1)
         {
            _loc3_ = GWizCSVUtils.CSVToArrayCol(param1,",");
         }
         if(downloadCSVCallback != null)
         {
            downloadCSVCallback(_loc3_);
            currCSVDownloading = "";
            downloadCSVCallback = null;
         }
         downloader();
      }
      
      public static function loadCSVFile(param1:File, param2:Boolean = true, param3:Boolean = false, param4:Array = null, param5:String = "", param6:String = ",", param7:String = ".csv", param8:Function = null) : ArrayCollection
      {
         var fname:String = null;
         var stream:FileStream = null;
         var buffer:String = null;
         var newPath:String = null;
         var newFile:File = null;
         var file:File = param1;
         var showMsg:Boolean = param2;
         var allowAngleBrackets:Boolean = param3;
         var forceFields:Array = param4;
         var extraMsg:String = param5;
         var delimeter:String = param6;
         var extension:String = param7;
         var prepFcn:Function = param8;
         var retval:ArrayCollection = null;
         fname = file.name;
         var msg:String = "";
         if(fname.substr(fname.length - extension.length) != extension)
         {
            GWizPopUpManager.Show("File needs to be a " + extension + " type.","Error: Invalid File Type",GWizPopUpManager.ERROR);
         }
         else
         {
            try
            {
               stream = new FileStream();
               if(file.exists)
               {
                  stream.open(file,FileMode.READ);
                  buffer = stream.readUTFBytes(stream.bytesAvailable);
                  stream.close();
                  if(prepFcn != null)
                  {
                     buffer = prepFcn(buffer);
                  }
                  retval = CSVToArrayCol(buffer,delimeter,true,allowAngleBrackets,forceFields);
               }
            }
            catch(e:Error)
            {
               GWizUtils.LogError("Error loading a file " + fname + fname + ", error = " + e.message);
               msg = ", error = " + e.message;
            }
         }
         if(!retval || retval.length <= 0 || msg.length > 0)
         {
            if(showMsg)
            {
               if(msg.length <= 0)
               {
                  msg = ", error = " + parseMsg;
               }
               GWizPopUpManager.Show("Couldn\'t load file " + fname + msg + " file copied to " + fname + "error." + "\n\n" + extraMsg,"Error: Load Failure",GWizPopUpManager.ERROR);
               newPath = file.nativePath + "error";
               newFile = new File(newPath);
               file.copyTo(newFile,true);
            }
            retval = null;
         }
         return retval;
      }
      
      public static function loadCSVFileURL(param1:String, param2:String, param3:Boolean = true) : ArrayCollection
      {
         var data:ArrayCollection = null;
         var url:String = param1;
         var errmsg:String = param2;
         var create:Boolean = param3;
         try
         {
            data = GWizCSVUtils.loadCSV(url);
         }
         catch(e:Error)
         {
            if(errmsg != "")
            {
               GWizPopUpManager.Show(errmsg,"Error: Load Failure",GWizPopUpManager.ERROR);
            }
         }
         if(!data && create)
         {
            data = new ArrayCollection();
         }
         return data;
      }
      
      public static function backupCSVFile(param1:String, param2:ArrayCollection, param3:Array) : void
      {
         var _loc4_:String = GWizUtils.simpleDateStr(new Date());
         _loc4_ = GWizStringUtils.replaceAll(_loc4_,"/","");
         var _loc5_:int = param1.length;
         while(_loc5_ > 0)
         {
            if(param1.charAt(_loc5_) == ".")
            {
               break;
            }
            _loc5_--;
         }
         if(_loc5_ > 0)
         {
            param1 = param1.substr(0,_loc5_);
         }
         param1 = param1 + _loc4_ + ".csv";
         saveCSVFileURL(param1,param2,param3);
      }
      
      public static function saveCSVFileURL(param1:String, param2:ArrayCollection, param3:Array) : void
      {
         var file:File = null;
         var url:String = param1;
         var data:ArrayCollection = param2;
         var fieldList:Array = param3;
         try
         {
            file = new File(url);
            saveCSVFile(file,data,fieldList);
         }
         catch(e:Error)
         {
            log.debug("Error writing CSV file: " + url + ", Error: " + e.message);
            GWizUtils.LogError("Error writing CSV file: " + url + ", Error: " + e.message);
            GWizUtils.assert(false);
         }
      }
      
      public static function saveCSVFile(param1:File, param2:ArrayCollection, param3:Array) : void
      {
         var outputString:String = null;
         var stream:FileStream = null;
         var f:File = param1;
         var data:ArrayCollection = param2;
         var fieldList:Array = param3;
         if(!data || data.length <= 0)
         {
            return;
         }
         try
         {
            outputString = arrayColToCSV(data,",",fieldList);
            stream = new FileStream();
            stream.open(f,FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error writing CSV file: " + f.url + ", Error: " + e.message);
            GWizUtils.assert(false);
         }
      }
      
      private function fileSelectedForExport(param1:File) : void
      {
         var s:String = null;
         var f:File = param1;
         if(f.extension == null)
         {
            f.url += ".csv";
         }
         var stream:FileStream = new FileStream();
         try
         {
            stream.open(f,FileMode.WRITE);
            s = GWizCSVUtils.arrayColToCSV(this.exportResults,",",this.exportFieldList);
            stream.writeUTFBytes(s);
            stream.close();
         }
         catch(e:Error)
         {
            GWizPopUpManager.Show("Error exporting file: " + e.message,"Error: Export Failed",GWizPopUpManager.ERROR);
         }
      }
      
      public function exportCSVData(param1:ArrayCollection, param2:Array, param3:GWizFileBrowser) : void
      {
         log.debug("exportCSVData");
         if(param1)
         {
            this.exportResults = param1;
            this.exportFieldList = param2;
            param3.doFileSaveAs(this.fileSelectedForExport,"Export");
         }
      }
      
      public function importCSVData(param1:Function, param2:GWizFileBrowser, param3:Boolean = true, param4:Boolean = false, param5:Array = null, param6:String = ",") : void
      {
         this.importFcn = param1;
         this.showMsg = param3;
         this.allowAngleBrackets = param4;
         this.forceFields = param5;
         this.delimeter = param6;
         var _loc7_:File = new File(this.importDir);
         param2.doFileOpen(this.importSelected,"Import");
      }
      
      private function importSelected(param1:File) : void
      {
         var _loc2_:ArrayCollection = GWizCSVUtils.loadCSVFile(param1,this.showMsg,this.allowAngleBrackets,this.forceFields);
         if(this.importFcn != null)
         {
            this.importFcn(_loc2_,param1.name);
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get importDir() : String
      {
         return this._208553304importDir;
      }
      
      private function set importDir(param1:String) : void
      {
         var _loc2_:Object = this._208553304importDir;
         if(_loc2_ !== param1)
         {
            this._208553304importDir = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"importDir",_loc2_,param1));
            }
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._bindingEventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.willTrigger(param1);
      }
   }
}
