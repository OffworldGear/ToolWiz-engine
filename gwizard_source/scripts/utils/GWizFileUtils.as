package utils
{
   import comps.GWizPopUpManager;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizFileUtils
   {
      
      private static const log:ILogger = Log.getLogger("GWizFileUtils");
      
      private static var crlfRegex:RegExp = new RegExp(GWizStringUtils.CRLF,"g");
      
      private static var lfRegex:RegExp = new RegExp(GWizStringUtils.LF,"g");
      
      private static var nonprintableRegex:RegExp = /[[^:printable:|\t|\r]])/g;
       
      
      public function GWizFileUtils()
      {
         super();
      }
      
      public static function normalizeLineBreaks(param1:String, param2:Boolean = true) : String
      {
         var _loc3_:int = 0;
         param1 = param1.replace(crlfRegex,GWizStringUtils.CR);
         param1 = param1.replace(lfRegex,GWizStringUtils.CR);
         if(param2)
         {
            if(GWizUtils.debug)
            {
               _loc3_ = param1.search(nonprintableRegex);
               if(_loc3_ >= 0)
               {
                  log.debug("Nonprintable char index: " + _loc3_ + ", code = " + int(param1.charCodeAt(_loc3_)));
               }
            }
            param1 = param1.replace(nonprintableRegex,"");
         }
         return param1;
      }
      
      public static function lineCount(param1:String) : int
      {
         var _loc2_:Array = param1.split(GWizStringUtils.CR);
         return _loc2_.length;
      }
      
      public static function denormalizeLineBreaks(param1:String) : String
      {
         var _loc2_:RegExp = new RegExp(GWizStringUtils.CR,"g");
         return param1.replace(_loc2_,GWizStringUtils.CRLF);
      }
      
      public static function validFilenameChar(param1:String) : Boolean
      {
         var _loc2_:* = true;
         switch(param1.charAt(0))
         {
            case "*":
            case "\"":
            case ":":
            case ">":
            case "<":
            case "?":
            case "|":
            case "|":
               _loc2_ = false;
               break;
            default:
               _loc2_ = !(0 <= param1.charCodeAt(0) && param1.charCodeAt(0) <= 31);
         }
         return _loc2_;
      }
      
      public static function fixInvalidFilename(param1:String, param2:String) : String
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(!validFilenameChar(param1.charAt(_loc3_)))
            {
               _loc4_ = param1.substr(0,_loc3_);
               _loc5_ = param1.substr(_loc3_ + 1,param1.length);
               param1 = _loc4_ + _loc5_;
               _loc3_--;
            }
            _loc3_++;
         }
         return param1;
      }
      
      public static function nativePathToDir(param1:String) : String
      {
         var _loc2_:int = 0;
         _loc2_ = param1.length - 1;
         while(_loc2_ > 0)
         {
            if(param1.charAt(_loc2_) == File.separator)
            {
               break;
            }
            _loc2_--;
         }
         return param1.substr(0,_loc2_ + 1);
      }
      
      public static function fname83(param1:String, param2:String = "") : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:int = 0;
         var _loc14_:Boolean = false;
         var _loc15_:File = null;
         var _loc6_:Boolean = false;
         _loc3_ = param1.indexOf(".");
         if(_loc3_ != -1)
         {
            _loc4_ = param1.substr(0,_loc3_);
         }
         else
         {
            _loc4_ = param1;
         }
         if(_loc4_.length <= 8 && _loc4_.indexOf(" ") != -1)
         {
            _loc6_ = true;
         }
         var _loc7_:String = "\"/\\[]:;= ";
         var _loc8_:String = "";
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc10_ = param1.charAt(_loc3_).toUpperCase();
            if(_loc7_.indexOf(_loc10_) == -1)
            {
               _loc8_ += _loc10_;
            }
            _loc3_++;
         }
         if(_loc8_.charAt(_loc8_.length - 1) == ".")
         {
            _loc8_ = _loc8_.substr(0,_loc8_.length - 1);
         }
         var _loc9_:Boolean = true;
         while(_loc9_)
         {
            _loc9_ = false;
            _loc3_ = _loc8_.indexOf(".");
            if(_loc3_ == -1)
            {
               break;
            }
            if((_loc11_ = _loc8_.substr(_loc3_ + 1)).indexOf(".") != -1)
            {
               _loc9_ = true;
               _loc8_ = _loc8_.substr(0,_loc3_) + _loc11_;
            }
         }
         _loc3_ = _loc8_.indexOf(".");
         if(_loc3_ != -1)
         {
            _loc4_ = _loc8_.substr(0,_loc3_);
            _loc5_ = _loc8_.substr(_loc3_);
         }
         else
         {
            _loc4_ = _loc8_;
            _loc5_ = "";
         }
         if((_loc5_ = _loc5_.substr(0,4)).length == 1)
         {
            _loc5_ = "";
         }
         if(_loc4_.length > 8 || _loc6_)
         {
            _loc12_ = _loc4_.substr(0,6);
            _loc13_ = 0;
            _loc14_ = true;
            while(_loc14_)
            {
               _loc13_++;
               _loc4_ = _loc12_ + "~" + _loc13_ + _loc5_;
               if(param2.length == 0 || _loc13_ >= 9)
               {
                  _loc14_ = false;
               }
               else
               {
                  _loc14_ = (_loc15_ = (_loc15_ = new File(param2)).resolvePath(_loc4_)).exists;
                  _loc15_ = null;
               }
            }
         }
         else
         {
            _loc4_ = _loc4_.substr(0,8) + _loc5_;
         }
         return _loc4_;
      }
      
      public static function removeExtension(param1:String) : String
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 && param1.indexOf(".") >= 0)
         {
            _loc2_ = 0;
            _loc3_ = param1.length - 1;
            while(_loc3_ >= 0)
            {
               if(param1.charAt(_loc3_) == ".")
               {
                  param1 = param1.substr(0,param1.length - _loc2_ - 1);
                  break;
               }
               _loc2_++;
               _loc3_--;
            }
         }
         return param1;
      }
      
      public static function getExtension(param1:String) : String
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(param1 && param1.indexOf(".") >= 0)
         {
            _loc2_ = "";
            _loc3_ = param1.length - 1;
            while(_loc3_ >= 0)
            {
               if(param1.charAt(_loc3_) == ".")
               {
                  break;
               }
               _loc2_ = param1.charAt(_loc3_) + _loc2_;
               _loc3_--;
            }
         }
         return _loc2_;
      }
      
      public static function loadFileAsString(param1:File, param2:Boolean = true, param3:String = "") : String
      {
         var stream:FileStream = null;
         var len:int = 0;
         var f:File = param1;
         var normalize:Boolean = param2;
         var errmsg:String = param3;
         var s:String = "";
         try
         {
            stream = new FileStream();
            stream.open(f,FileMode.READ);
            log.debug("fname = " + f.nativePath);
            len = stream.bytesAvailable;
            if(len > 0)
            {
               s = stream.readUTFBytes(len);
               stream.close();
               if(normalize)
               {
                  s = GWizFileUtils.normalizeLineBreaks(s);
               }
            }
         }
         catch(e:Error)
         {
            if(errmsg != "")
            {
               GWizPopUpManager.Show("Sorry, can\'t open file.","Error: Open Error",GWizPopUpManager.ERROR);
            }
         }
         return s;
      }
      
      public static function fnameFromPath(param1:String) : String
      {
         if(param1.length == 0)
         {
            return "";
         }
         var _loc2_:Array = splitPath(param1);
         return _loc2_[_loc2_.length - 1];
      }
      
      public static function splitPath(param1:String) : Array
      {
         return param1.split(File.separator);
      }
      
      public static function validFolder(param1:String) : Boolean
      {
         var _loc2_:File = new File(param1);
         return _loc2_.exists && _loc2_.isDirectory;
      }
      
      public static function unitTest() : void
      {
         test("This is a really long filename.123.456.789.txtme ");
         test("This is a really long filename.123.456.789.");
         test("A file.doc");
         test("A_file.doc");
         test("");
         log.debug("removeExtension should return BOZON: \'" + removeExtension("A.BOZON.TXT"));
      }
      
      public static function test(param1:String) : void
      {
         log.debug("long = \'" + param1 + "\'");
         log.debug("short = \'" + fname83(param1) + "\'");
      }
   }
}
