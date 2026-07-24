package utils
{
   import mx.utils.StringUtil;
   
   public class GWizStringUtils
   {
      
      public static const CRLF:String = String.fromCharCode(13,10);
      
      public static const CR:String = String.fromCharCode(13);
      
      public static const LF:String = String.fromCharCode(10);
      
      public static const TAB:String = String.fromCharCode(9);
      
      public static const DEL:String = String.fromCharCode(127);
      
      public static const BS:String = String.fromCharCode(8);
      
      public static const BLOCK_DELETE:String = "/";
      
      public static const BEGIN_COMMENT:String = "(";
      
      public static const END_COMMENT:String = ")";
      
      public static const TAPE_BEGIN:String = "%";
      
      public static const DIGITS:String = "0123456789";
      
      public static const NUMCHARS:String = DIGITS + ".+-";
      
      public static const LETTERS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      
      public static const HTML_LESSTHAN:String = "&lt;";
      
      public static const HTML_GREATERTHAN:String = "&gt;";
       
      
      public function GWizStringUtils()
      {
         super();
      }
      
      public static function left(param1:String, param2:int) : String
      {
         if(param1 == null || param2 < 0)
         {
            return null;
         }
         return param1.substring(0,param2);
      }
      
      public static function right(param1:String, param2:int) : String
      {
         if(param1 == null || param2 < 0)
         {
            return null;
         }
         var _loc3_:int = Math.max(param1.length - param2,0);
         return param1.substring(_loc3_,param2);
      }
      
      public static function leftUntil(param1:String, param2:String) : String
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc3_:int = param1.indexOf(param2);
         if(_loc3_ == -1)
         {
            return param1;
         }
         return param1.substring(0,_loc3_);
      }
      
      public static function rightUntil(param1:String, param2:String) : String
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc3_:int = param1.lastIndexOf(param2);
         if(_loc3_ == -1)
         {
            return param1;
         }
         return param1.substring(_loc3_ + param2.length);
      }
      
      public static function beginsWith(param1:String, param2:String) : Boolean
      {
         if(param1 == null || param2 == null || param1.length == 0 || param2.length == 0)
         {
            return false;
         }
         var _loc3_:String = left(param1,param2.length);
         return _loc3_ == param2;
      }
      
      public static function endsWith(param1:String, param2:String) : Boolean
      {
         if(param1 == null || param2 == null || param1.length == 0 || param2.length == 0)
         {
            return false;
         }
         var _loc3_:String = right(param1,param2.length);
         return _loc3_ == param2;
      }
      
      public static function contains(param1:String, param2:String) : Boolean
      {
         if(param1 == null || param2 == null || param2.length == 0)
         {
            return false;
         }
         return param1.indexOf(param2) >= 0;
      }
      
      public static function isEmpty(param1:String) : Boolean
      {
         if(param1 == null || param1.length == 0)
         {
            return true;
         }
         var _loc2_:int = 0;
         while(StringUtil.isWhitespace(param1.charAt(_loc2_)))
         {
            _loc2_++;
         }
         return _loc2_ == param1.length;
      }
      
      public static function isNotEmpty(param1:String) : Boolean
      {
         return !isEmpty(param1);
      }
      
      public static function zapWhiteSpace(param1:String) : String
      {
         var _loc2_:RegExp = null;
         if(param1)
         {
            _loc2_ = /\s+/g;
            return param1.replace(_loc2_,"");
         }
         return "";
      }
      
      public static function zapLeadingWhiteSpace(param1:String) : String
      {
         while(param1 != "" && (param1.charAt(0) == "\t" || param1.charAt(0) == " "))
         {
            param1 = param1.substr(1);
         }
         return param1;
      }
      
      public static function zapInvalidFileNameChars(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc2_:String = "";
         if(param1 && param1 != "")
         {
            param1 = param1.toLowerCase();
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               if((_loc4_ = param1.charAt(_loc3_)) == " ")
               {
                  _loc4_ = "-";
               }
               if("0" <= _loc4_ && _loc4_ <= "9" || "a" <= _loc4_ && _loc4_ <= "z" || _loc4_ == "-")
               {
                  _loc2_ += _loc4_;
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public static function isBlank(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         if(param1 != null)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               _loc3_ = param1.charAt(_loc2_);
               if(_loc3_ != " " && _loc3_ != "\t" && _loc3_ != "\n" && _loc3_ != "\r")
               {
                  return false;
               }
               _loc2_++;
            }
         }
         return true;
      }
      
      public static function isLetter(param1:String) : Boolean
      {
         return "A" <= param1.charAt(0).toUpperCase() && param1.charAt(0).toUpperCase() <= "Z";
      }
      
      public static function isDigit(param1:String) : Boolean
      {
         return "0" <= param1.charAt(0) && param1.charAt(0) <= "9";
      }
      
      public static function replaceAll(param1:String, param2:String, param3:String) : String
      {
         if(param1)
         {
            if(param3.indexOf(param2) >= 0)
            {
               return param1;
            }
            while(param1.indexOf(param2) >= 0)
            {
               param1 = param1.replace(param2,param3);
            }
         }
         return param1;
      }
      
      public static function isXMLCSVTrue(param1:Object) : Boolean
      {
         return String(param1).toLowerCase() == "true";
      }
      
      public static function fixHTMLGreaterLessSigns(param1:String) : String
      {
         param1 = replaceAll(param1,"<",HTML_LESSTHAN);
         return replaceAll(param1,">",HTML_GREATERTHAN);
      }
      
      public static function lowerToProperCase(param1:String) : String
      {
         var _loc5_:String = null;
         var _loc2_:String = "";
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1.charAt(_loc4_).toLowerCase();
            if(_loc4_ == 0 || _loc3_ < "a" || _loc3_ > "z")
            {
               _loc2_ += _loc5_.toUpperCase();
            }
            else
            {
               _loc2_ += _loc5_;
            }
            _loc3_ = _loc5_;
            _loc4_++;
         }
         return _loc2_;
      }
      
      public static function camelToProperCase(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc2_:String = "";
         if(param1)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               _loc4_ = param1.charAt(_loc3_);
               if(_loc3_ == 0)
               {
                  _loc2_ += _loc4_.toUpperCase();
               }
               else if(_loc4_ == _loc4_.toUpperCase())
               {
                  _loc2_ += " " + _loc4_;
               }
               else
               {
                  _loc2_ += _loc4_;
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
   }
}
