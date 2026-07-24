package auth
{
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class AuthProvList extends ArrayCollection
   {
      
      private static const log:ILogger = Log.getLogger("AuthProvList");
       
      
      public function AuthProvList()
      {
         super();
      }
      
      public static function parse(param1:String) : AuthProvList
      {
         var _loc2_:AuthProvList = null;
         var _loc3_:ArrayCollection = null;
         var _loc4_:Array = null;
         var _loc5_:* = false;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:Boolean = false;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:Object = null;
         var _loc17_:Object = null;
         var _loc18_:String = null;
         if(param1 != "" && param1 != null)
         {
            _loc3_ = new ArrayCollection();
            _loc4_ = [];
            _loc5_ = false;
            _loc7_ = "";
            _loc8_ = 0;
            while(_loc8_ < param1.length)
            {
               _loc12_ = param1.charAt(_loc8_);
               _loc13_ = false;
               switch(_loc12_)
               {
                  case "{":
                     _loc6_ = new Object();
                     break;
                  case "}":
                     break;
                  case "\"":
                     if(!(_loc5_ = !_loc5_) && _loc7_.length > 0)
                     {
                        _loc13_ = true;
                     }
                     break;
                  case ":":
                     if(!_loc5_ && _loc7_.length > 0)
                     {
                        _loc13_ = true;
                     }
                     break;
                  case "[":
                     break;
                  case "]":
                     _loc13_ = true;
                     break;
                  case " ":
                     if(_loc5_)
                     {
                        _loc7_ += _loc12_;
                     }
                     break;
                  case ",":
                     if(!_loc5_ && _loc7_.length > 0)
                     {
                        _loc13_ = true;
                     }
                     else
                     {
                        _loc7_ += _loc12_;
                     }
                     break;
                  default:
                     _loc7_ += _loc12_;
                     break;
               }
               if(_loc13_)
               {
                  _loc4_.push(_loc7_);
                  _loc7_ = "";
                  if(_loc4_.length >= 2)
                  {
                     _loc14_ = _loc4_.pop();
                     _loc15_ = _loc4_.pop();
                     _loc4_ = [];
                     log.debug("Provision: " + _loc15_ + ":" + _loc14_);
                     (_loc16_ = new Object()).provValue = _loc14_;
                     _loc16_.provName = _loc15_;
                     _loc3_.addItem(_loc16_);
                  }
               }
               _loc8_++;
            }
            _loc2_ = new AuthProvList();
            _loc9_ = new Object();
            _loc10_ = 0;
            while(_loc10_ < _loc3_.length)
            {
               if((_loc18_ = (_loc17_ = _loc3_.getItemAt(_loc10_)).provName).indexOf("Start") >= 0)
               {
                  _loc18_ = _loc18_.substr(0,_loc18_.length - "Start".length);
                  if(_loc9_.hasOwnProperty("name") && _loc9_.name != _loc18_)
                  {
                     _loc2_.addItem(_loc9_);
                     (_loc9_ = new Object()).name = _loc18_;
                  }
                  else
                  {
                     _loc9_.name = _loc18_;
                  }
                  _loc9_.startDate = _loc17_.provValue;
               }
               else if(_loc18_.indexOf("End") >= 0)
               {
                  _loc18_ = _loc18_.substr(0,_loc18_.length - "End".length);
                  if(_loc9_.hasOwnProperty("name") && _loc9_.name != _loc18_)
                  {
                     _loc2_.addItem(_loc9_);
                     (_loc9_ = new Object()).name = _loc18_;
                  }
                  else
                  {
                     _loc9_.name = _loc18_;
                  }
                  _loc9_.endDate = _loc17_.provValue;
               }
               _loc10_++;
            }
            if(_loc9_.hasOwnProperty("name"))
            {
               _loc2_.addItem(_loc9_);
            }
            _loc11_ = 0;
            while(_loc11_ < _loc2_.length)
            {
               _loc9_ = _loc2_.getItemAt(_loc11_);
               log.debug("prov[" + _loc11_ + "]\n" + "    name = " + _loc9_.name + ", startDate = " + _loc9_.startDate + ", endDate = " + _loc9_.endDate);
               _loc11_++;
            }
         }
         return _loc2_;
      }
   }
}
