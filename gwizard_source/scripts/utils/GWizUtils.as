package utils
{
   import chimp.GWizMandrill;
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.xml.XMLDocument;
   import flash.xml.XMLNode;
   import logger.GWizEarlyBird;
   import login.GWizCredentials;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.core.IVisualElement;
   import mx.events.PropertyChangeEvent;
   import mx.formatters.NumberBase;
   import mx.formatters.NumberBaseRoundType;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.rpc.xml.SimpleXMLDecoder;
   import mx.rpc.xml.SimpleXMLEncoder;
   import spark.collections.Sort;
   import spark.collections.SortField;
   import spark.components.Group;
   import spark.components.gridClasses.GridColumn;
   
   public class GWizUtils implements IEventDispatcher
   {
      
      private static var eb:GWizEarlyBird = new GWizEarlyBird();
      
      private static const log:ILogger = Log.getLogger("GWizUtils");
      
      public static const ERROR_COLOR:String = "0xDD2222";
      
      public static const MESSAGE_COLOR:String = "0X2222BB";
      
      public static const SHIFT:int = 16;
      
      public static const CTRL:int = 17;
      
      public static const ALT:int = 18;
      
      public static const UP_ARROW:int = 38;
      
      public static const DN_ARROW:int = 40;
      
      public static const PG_UP:int = 33;
      
      public static const PG_DN:int = 34;
      
      public static const F1:int = 112;
      
      public static const F2:int = 113;
      
      public static const F3:int = 114;
      
      public static const F4:int = 115;
      
      public static const F5:int = 116;
      
      public static const F6:int = 117;
      
      public static const F7:int = 118;
      
      public static const F8:int = 119;
      
      public static const F9:int = 120;
      
      public static const F10:int = 121;
      
      public static const INCHES_UNITS:String = "Inches";
      
      public static const FEET_UNITS:String = "Feet";
      
      public static const HP_UNITS:String = "HP";
      
      public static const MM_UNITS:String = "MM";
      
      public static const M_UNITS:String = "Meters";
      
      public static const KW_UNITS:String = "KW";
      
      public static const CC_UNITS:String = "CC";
      
      public static const CI_UNITS:String = "CI";
      
      public static const LB_UNITS:String = "Lb";
      
      public static const KG_UNITS:String = "Kg";
      
      public static const OZIN_UNITS:String = "oz-in";
      
      public static const NM_UNITS:String = "N-m";
      
      public static const INHG_UNITS:String = "in-Hg";
      
      public static const MBAR_UNITS:String = "mbar";
      
      public static const SQIN_UNITS:String = "sq in";
      
      public static const SQCM_UNITS:String = "sq cm";
      
      public static const KW_PER_HP:Number = 0.745699872;
      
      public static const SIXTEENTH:Number = 1 / 16;
      
      public static const TENTH_MM:Number = 0.1;
      
      public static const MILLI_PER_DAY:Number = 24 * 60 * 60 * 1000;
      
      public static const MILLI_PER_MINUTE:Number = 60 * 1000;
      
      public static var MonthNames3:Array = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
      
      public static var MonthNames:Array = ["January","February","March","April","May","June","July","August","September","October","November","December"];
      
      private static var _81880911Units:String = INCHES_UNITS;
      
      private static const CCS_PER_CUBIC_INCH:Number = 16.387064;
      
      private static var _currApp:String = "Setup";
      
      private static const APPSTR_DELIMETER:String = ":";
      
      private static var _95458899debug:Boolean = true;
      
      private static const SHIPPING:Boolean = false;
      
      private static var _1396096028errorLog:String = "";
      
      public static var nLogs:int = 0;
      
      public static var LogErrorToFile:Boolean = false;
      
      public static const LOG_CONTEXTS:Boolean = true;
      
      private static var _logContext:String = "none";
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizUtils()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      public static function checkProp(param1:Object, param2:String, param3:String) : Boolean
      {
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc4_:* = true;
         if(!param1.hasOwnProperty(param2))
         {
            _loc4_ = false;
         }
         else
         {
            switch(param3)
            {
               case "Number":
                  _loc5_ = param1[param2];
                  _loc4_ = !isNaN(_loc5_);
                  break;
               case "Boolean":
                  _loc4_ = Boolean((_loc6_ = (_loc6_ = param1[param2].toString()).toLowerCase()) == "true" || _loc6_ == "false");
                  break;
               default:
                  _loc4_ = (_loc7_ = param1[param2]) != null;
            }
         }
         return _loc4_;
      }
      
      public static function getKeynameFromCode(param1:int) : String
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case F1:
               _loc2_ = "F1";
               break;
            case F2:
               _loc2_ = "F2";
               break;
            case F3:
               _loc2_ = "F3";
               break;
            case F4:
               _loc2_ = "F4";
               break;
            case F5:
               _loc2_ = "F5";
               break;
            case F6:
               _loc2_ = "F6";
               break;
            case F7:
               _loc2_ = "F7";
               break;
            case F8:
               _loc2_ = "F8";
               break;
            case F9:
               _loc2_ = "F9";
               break;
            case F10:
               _loc2_ = "F10";
         }
         return _loc2_;
      }
      
      public static function dateToXLSerNum(param1:Date) : Number
      {
         var _loc2_:Number = param1.valueOf() / MILLI_PER_DAY;
         return Number(_loc2_ + 25568);
      }
      
      public static function dateValToXLSerNum(param1:Number) : Number
      {
         var _loc2_:Number = param1 / MILLI_PER_DAY;
         return Number(_loc2_ + 25568);
      }
      
      public static function XLSerNumToDate(param1:Number) : Date
      {
         param1 -= 25568;
         param1 *= MILLI_PER_DAY;
         var _loc2_:Date = new Date();
         _loc2_.setTime(param1);
         return _loc2_;
      }
      
      public static function XLSerNumToDaysLeft(param1:Number) : int
      {
         var _loc2_:Date = XLSerNumToDate(param1);
         var _loc3_:Date = new Date();
         var _loc4_:Number = (_loc4_ = _loc2_.valueOf() - _loc3_.valueOf()) / MILLI_PER_DAY;
         return int(_loc4_);
      }
      
      public static function addDays(param1:Date, param2:Number) : Date
      {
         var _loc3_:Date = new Date(param1);
         param2 *= MILLI_PER_DAY;
         _loc3_.time += param2;
         return _loc3_;
      }
      
      public static function simpleDateStr(param1:Date) : String
      {
         return String(param1.month + 1) + "/" + String(param1.date) + "/" + String(param1.fullYear);
      }
      
      public static function dateFromSimpleDateStr(param1:String) : Date
      {
         var _loc2_:Date = new Date();
         _loc2_.time = Date.parse(param1);
         return _loc2_;
      }
      
      public static function inchToMM(param1:Number) : Number
      {
         return param1 * 25.4;
      }
      
      public static function mmToInch(param1:Number) : Number
      {
         return param1 / 25.4;
      }
      
      public static function ciToCC(param1:Number) : Number
      {
         return param1 * GWizUtils.CCS_PER_CUBIC_INCH;
      }
      
      public static function consDate(param1:Date) : String
      {
         return String(param1.month + 1 + "/" + param1.date + "/" + param1.fullYear);
      }
      
      public static function inOrMM() : String
      {
         if(Units == INCHES_UNITS)
         {
            return "in";
         }
         return "mm";
      }
      
      public static function formatMinToHMS(param1:Number) : String
      {
         var _loc2_:Number = Math.floor(param1 / 60);
         _loc2_ = !isNaN(_loc2_) ? Number(_loc2_) : Number(0);
         param1 -= _loc2_ * 60;
         param1 = !isNaN(param1) ? Number(param1) : Number(0);
         var _loc3_:Number = (param1 - Math.floor(param1)) * 60;
         _loc3_ = !isNaN(_loc3_) ? Number(_loc3_) : Number(0);
         param1 = Math.floor(param1);
         var _loc4_:String = padDigits(_loc2_) + ":" + padDigits(param1) + ":" + roundBigTenths(String(_loc3_));
         GWizUtils.assert(_loc4_.indexOf("-") < 0);
         return _loc4_;
      }
      
      public static function padDigits(param1:Number, param2:int = 2) : String
      {
         var _loc3_:String = String(int(param1));
         while(_loc3_.length < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
      
      public static function extractDigitFromInt(param1:int, param2:int, param3:int) : int
      {
         var _loc4_:String = String(param1);
         while(_loc4_.length < param2)
         {
            _loc4_ = "0" + _loc4_;
         }
         return int(_loc4_.substr(param3,1));
      }
      
      public static function lastDigit(param1:Number) : Number
      {
         var _loc5_:String = null;
         var _loc2_:String = String(param1);
         var _loc3_:* = "";
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length - 1)
         {
            if((_loc5_ = _loc2_.charAt(_loc4_)) == "0" || _loc5_ == ".")
            {
               _loc3_ += _loc5_;
            }
            else
            {
               _loc3_ += "0";
            }
            _loc4_++;
         }
         _loc3_ += _loc2_.charAt(_loc2_.length - 1);
         return Number(_loc3_);
      }
      
      public static function set currApp(param1:String) : void
      {
         _currApp = param1;
      }
      
      public static function get currApp() : String
      {
         return _currApp;
      }
      
      public static function pushApp(param1:String) : void
      {
         param1.replace(APPSTR_DELIMETER,"");
         currApp = param1 + APPSTR_DELIMETER + currApp;
      }
      
      public static function popApp() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < currApp.length)
         {
            if(currApp.charAt(_loc1_) == APPSTR_DELIMETER)
            {
               currApp = currApp.substr(_loc1_ + 1,currApp.length - _loc1_);
               return;
            }
            _loc1_++;
         }
      }
      
      public static function isMAC() : Boolean
      {
         return Capabilities.version.substr(0,3) == "MAC";
      }
      
      public static function clone(param1:Object) : *
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         return _loc2_.readObject();
      }
      
      public static function clonePrivate(param1:Object) : *
      {
         var _loc2_:Object = null;
         if(param1)
         {
            _loc2_ = newSibling(param1);
            if(_loc2_)
            {
               copyData(param1,_loc2_);
            }
         }
         return _loc2_;
      }
      
      private static function newSibling(param1:Object) : *
      {
         var _loc2_:* = undefined;
         var _loc3_:Class = null;
         if(param1)
         {
            try
            {
               _loc3_ = getDefinitionByName(getQualifiedClassName(param1)) as Class;
               _loc2_ = new _loc3_();
            }
            catch(e:Object)
            {
            }
            return _loc2_;
         }
         return null;
      }
      
      private static function copyData(param1:Object, param2:Object) : void
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         if(param1 && param2)
         {
            try
            {
               _loc3_ = describeType(param1);
               for each(_loc4_ in _loc3_.variable)
               {
                  if(param2.hasOwnProperty(_loc4_.@name))
                  {
                     param2[_loc4_.@name] = param1[_loc4_.@name];
                  }
               }
               for each(_loc4_ in _loc3_.accessor)
               {
                  if(_loc4_.@access == "readwrite")
                  {
                     if(param2.hasOwnProperty(_loc4_.@name))
                     {
                        param2[_loc4_.@name] = param1[_loc4_.@name];
                     }
                  }
               }
            }
            catch(err:Object)
            {
            }
         }
      }
      
      public static function get DoNotShip() : Boolean
      {
         return !GWizUtils.debug || !SHIPPING;
      }
      
      public static function assert(param1:Boolean) : void
      {
         if(debug)
         {
            if(!param1)
            {
               throw new Error("Assertion failed!");
            }
         }
      }
      
      public static function nyi(param1:String) : void
      {
         log.debug(param1);
         assert(false);
      }
      
      public static function arrayCollectionSort(param1:ArrayCollection, param2:String, param3:Boolean) : void
      {
         var _loc4_:SortField;
         (_loc4_ = new SortField()).name = param2;
         _loc4_.numeric = param3;
         var _loc5_:Sort;
         (_loc5_ = new Sort()).fields = [_loc4_];
         param1.sort = _loc5_;
         param1.refresh();
      }
      
      public static function mergeArrays(param1:ArrayCollection, param2:ArrayCollection) : ArrayCollection
      {
         var _loc3_:Object = null;
         for each(_loc3_ in param2)
         {
            param1.addItem(_loc3_);
         }
         return param1;
      }
      
      public static function deDupeAC(param1:ArrayCollection, param2:Array) : ArrayCollection
      {
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc3_:ArrayCollection = new ArrayCollection();
         var _loc4_:Object = new Object();
         var _loc5_:int = 0;
         while(_loc5_ < param1.length)
         {
            _loc6_ = param1.getItemAt(_loc5_);
            _loc7_ = "";
            _loc8_ = 0;
            while(_loc8_ < param2.length)
            {
               if((_loc9_ = param2[_loc8_]) != "changeDate")
               {
                  _loc7_ += _loc6_[_loc9_];
               }
               _loc8_++;
            }
            if(!_loc4_.hasOwnProperty(_loc7_))
            {
               _loc4_[_loc7_] = true;
               _loc3_.addItem(_loc6_);
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      public static function radians(param1:Number) : Number
      {
         return param1 * Math.PI / 180;
      }
      
      public static function degrees(param1:Number) : Number
      {
         return param1 * 180 / Math.PI;
      }
      
      public static function square(param1:Number) : Number
      {
         return param1 * param1;
      }
      
      public static function cubeRoot(param1:Number) : Number
      {
         return Math.pow(param1,1 / 3);
      }
      
      public static function secant(param1:Number) : Number
      {
         return 1 / Math.cos(param1);
      }
      
      public static function sroundTenths(param1:String, param2:Boolean = false, param3:Boolean = false) : String
      {
         var _loc4_:Number = 4;
         var _loc5_:Number = 3;
         var _loc6_:NumberBase = new NumberBase();
         var _loc7_:Number = _loc4_;
         if(param2 && Units != INCHES_UNITS)
         {
            param1 = String(Number(param1) * 25.4);
            _loc7_ = _loc5_;
         }
         var _loc8_:String = _loc6_.formatRoundingWithPrecision(param1,NumberBaseRoundType.NEAREST,_loc7_);
         if(param3)
         {
            _loc8_ = _loc6_.formatPrecision(_loc8_,_loc4_);
         }
         return _loc8_;
      }
      
      public static function roundTenths2Str(param1:Number, param2:Boolean = false) : String
      {
         var _loc3_:Number = 4;
         var _loc4_:Number = 3;
         var _loc5_:NumberBase = new NumberBase();
         var _loc6_:int = _loc3_;
         if(param2 && Units != INCHES_UNITS)
         {
            param1 *= 25.4;
            _loc6_ = _loc4_;
            param1 *= 1000;
         }
         else
         {
            param1 *= 10000;
         }
         var _loc8_:int = (_loc7_ = int(Math.ceil(param1))) >= 0 ? 1 : -1;
         var _loc9_:String;
         if((_loc9_ = String(Math.abs(_loc7_))).length <= _loc6_)
         {
            var _loc7_:int = _loc9_.length;
            while(_loc7_ <= _loc6_)
            {
               _loc9_ = "0" + _loc9_;
               _loc7_++;
            }
         }
         if(_loc8_ < 0)
         {
            _loc9_ = "-" + _loc9_;
         }
         return _loc9_.substr(0,_loc9_.length - _loc6_) + "." + _loc9_.substr(_loc9_.length - _loc6_);
      }
      
      public static function roundTenths(param1:Number, param2:Boolean = false) : Number
      {
         var _loc3_:Number = 4;
         var _loc4_:Number = 3;
         var _loc5_:NumberBase = new NumberBase();
         var _loc6_:Number = _loc3_;
         if(param2 && Units != INCHES_UNITS)
         {
            param1 *= 25.4;
            _loc6_ = _loc4_;
         }
         return Number(_loc5_.formatRoundingWithPrecision(String(param1),NumberBaseRoundType.NEAREST,_loc6_));
      }
      
      public static function roundHundredThousandths(param1:Number, param2:Boolean = false) : Number
      {
         var _loc3_:Number = 5;
         var _loc4_:Number = 4;
         var _loc5_:NumberBase = new NumberBase();
         var _loc6_:Number = _loc3_;
         if(param2 && Units != INCHES_UNITS)
         {
            param1 *= 25.4;
            _loc6_ = _loc4_;
         }
         return Number(_loc5_.formatRoundingWithPrecision(String(param1),NumberBaseRoundType.NEAREST,_loc6_));
      }
      
      public static function sroundThousandths(param1:String, param2:Boolean = false) : String
      {
         var _loc3_:Number = 3;
         var _loc4_:Number = 2;
         var _loc5_:NumberBase = new NumberBase();
         var _loc6_:Number = _loc3_;
         if(param2 && Units != INCHES_UNITS)
         {
            param1 = String(Number(param1) * 25.4);
            _loc6_ = _loc4_;
         }
         return _loc5_.formatRoundingWithPrecision(param1,NumberBaseRoundType.NEAREST,_loc6_);
      }
      
      public static function roundThousandths(param1:Number, param2:Boolean = false) : Number
      {
         var _loc3_:Number = 3;
         var _loc4_:Number = 2;
         var _loc5_:NumberBase = new NumberBase();
         var _loc6_:Number = _loc3_;
         if(param2 && Units != INCHES_UNITS)
         {
            param1 *= 25.4;
            _loc6_ = _loc4_;
         }
         return Number(_loc5_.formatRoundingWithPrecision(String(param1),NumberBaseRoundType.NEAREST,_loc6_));
      }
      
      public static function sroundHundredths(param1:String) : String
      {
         var _loc2_:NumberBase = new NumberBase();
         return _loc2_.formatRoundingWithPrecision(param1,NumberBaseRoundType.NEAREST,2);
      }
      
      public static function roundHundredths(param1:Number) : Number
      {
         var _loc2_:NumberBase = new NumberBase();
         return Number(_loc2_.formatRoundingWithPrecision(String(param1),NumberBaseRoundType.NEAREST,2));
      }
      
      public static function formatTime(param1:Number) : String
      {
         var _loc2_:int = param1 * 1000;
         param1 = _loc2_ / 1000;
         var _loc3_:int = param1 / 60;
         param1 -= _loc3_ * 60;
         var _loc4_:int = _loc3_ / 60;
         _loc3_ -= _loc4_ * 60;
         var _loc5_:* = "";
         if(_loc4_ > 0)
         {
            _loc5_ += _loc4_ + ":";
            if(_loc3_ > 0 && _loc3_ < 10)
            {
               _loc5_ += "0";
            }
         }
         if(_loc3_ > 0)
         {
            _loc5_ += _loc3_ + ":";
         }
         if(1 <= param1 && param1 < 10)
         {
            _loc5_ += "0";
         }
         return _loc5_ + (roundBigTenths(String(param1)) + "");
      }
      
      public static function roundBigTenths(param1:String, param2:Boolean = false) : String
      {
         var _loc3_:NumberBase = new NumberBase();
         if(param2 && Units != INCHES_UNITS)
         {
            param1 = String(Number(param1) * 25.4);
         }
         return _loc3_.formatRoundingWithPrecision(param1,NumberBaseRoundType.NEAREST,1);
      }
      
      public static function roundBigTenths2Str(param1:Number, param2:Boolean = false) : String
      {
         if(param2 && Units != INCHES_UNITS)
         {
            param1 *= 25.4;
         }
         param1 *= 10;
         var _loc3_:int = Math.ceil(param1);
         var _loc4_:String;
         return (_loc4_ = String(_loc3_)).substr(0,_loc4_.length - 1) + "." + _loc4_.substr(_loc4_.length - 1);
      }
      
      public static function roundPlaces(param1:Number, param2:Number) : Number
      {
         var _loc3_:NumberBase = new NumberBase();
         return Number(_loc3_.formatRoundingWithPrecision(String(param1),NumberBaseRoundType.NEAREST,param2));
      }
      
      public static function formatPlaces(param1:Number, param2:int = 4, param3:Boolean = false, param4:String = "MM") : String
      {
         var _loc5_:NumberBase = new NumberBase();
         var _loc6_:Number = param1;
         if(Units != INCHES_UNITS && param3)
         {
            if(param4 == MM_UNITS)
            {
               _loc6_ = param1 * 25.4;
            }
            else if(param4 == CC_UNITS)
            {
               _loc6_ = ciToCC(param1);
            }
            else if(param4 == M_UNITS)
            {
               _loc6_ = param1 * 0.3048;
            }
            else if(param4 == GWizUtils.KW_UNITS)
            {
               _loc6_ = param1 * KW_PER_HP;
            }
         }
         return _loc5_.formatRoundingWithPrecision(String(_loc6_),NumberBaseRoundType.NEAREST,param2);
      }
      
      public static function sroundPlaces(param1:String, param2:Number) : String
      {
         var _loc3_:NumberBase = new NumberBase();
         return _loc3_.formatRoundingWithPrecision(param1,NumberBaseRoundType.NEAREST,param2);
      }
      
      public static function dec2Fraction(param1:Number, param2:Number) : String
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:String = "";
         if(param1 < 100 && param1 >= -100)
         {
            _loc5_ = (_loc4_ = (_loc4_ = param1 - Math.floor(param1)) * 64) - Math.floor(_loc4_);
            _loc4_ = Math.floor(_loc4_);
            if(_loc5_ >= 0.5)
            {
               _loc4_ += 1;
            }
            if(1 - _loc5_ <= param2 || _loc5_ <= param2)
            {
               switch(_loc4_)
               {
                  case 2:
                     _loc3_ = "1/32";
                     break;
                  case 4:
                     _loc3_ = "1/16";
                     break;
                  case 6:
                     _loc3_ = "3/32";
                     break;
                  case 8:
                     _loc3_ = "1/8";
                     break;
                  case 10:
                     _loc3_ = "5/32";
                     break;
                  case 12:
                     _loc3_ = "3/16";
                     break;
                  case 14:
                     _loc3_ = "7/32";
                     break;
                  case 16:
                     _loc3_ = "1/4";
                     break;
                  case 18:
                     _loc3_ = "9/32";
                     break;
                  case 20:
                     _loc3_ = "5/16";
                     break;
                  case 22:
                     _loc3_ = "11/32";
                     break;
                  case 24:
                     _loc3_ = "3/8";
                     break;
                  case 26:
                     _loc3_ = "13/32";
                     break;
                  case 28:
                     _loc3_ = "7/16";
                     break;
                  case 30:
                     _loc3_ = "15/32";
                     break;
                  case 32:
                     _loc3_ = "1/2";
                     break;
                  case 34:
                     _loc3_ = "17/32";
                     break;
                  case 36:
                     _loc3_ = "9/16";
                     break;
                  case 38:
                     _loc3_ = "19/32";
                     break;
                  case 40:
                     _loc3_ = "5/8";
                     break;
                  case 42:
                     _loc3_ = "21/32";
                     break;
                  case 44:
                     _loc3_ = "11/16";
                     break;
                  case 46:
                     _loc3_ = "23/32";
                     break;
                  case 48:
                     _loc3_ = "3/4";
                     break;
                  case 50:
                     _loc3_ = "25/32";
                     break;
                  case 52:
                     _loc3_ = "13/16";
                     break;
                  case 54:
                     _loc3_ = "27/32";
                     break;
                  case 56:
                     _loc3_ = "7/8";
                     break;
                  case 58:
                     _loc3_ = "29/32";
                     break;
                  case 60:
                     _loc3_ = "15/16";
                     break;
                  case 62:
                     _loc3_ = "31/32";
               }
            }
         }
         return _loc3_;
      }
      
      public static function average(param1:Number, param2:Number) : Number
      {
         return (param1 + param2) / 2;
      }
      
      public static function safeAcos(param1:Number) : Number
      {
         if(1 < param1 && param1 < 1.001)
         {
            param1 = 1;
         }
         else if(-1.001 < param1 && param1 < -1)
         {
            param1 = -1;
         }
         return Math.acos(param1);
      }
      
      public static function safeAsin(param1:Number) : Number
      {
         if(1 < param1 < 1.001)
         {
            param1 = 1;
         }
         else if(-1.001 < param1 < -1)
         {
            param1 = -1;
         }
         return Math.asin(param1);
      }
      
      public static function maxNaN(param1:Number, param2:Number) : Number
      {
         if(isNaN(param1))
         {
            return param2;
         }
         if(isNaN(param2))
         {
            return param1;
         }
         if(param1 > param2)
         {
            return param1;
         }
         return param2;
      }
      
      public static function minNaN(param1:Number, param2:Number) : Number
      {
         if(isNaN(param1))
         {
            return param2;
         }
         if(isNaN(param2))
         {
            return param1;
         }
         if(param1 < param2)
         {
            return param1;
         }
         return param2;
      }
      
      public static function isNotNaNValue(param1:Number) : String
      {
         var _loc2_:String = null;
         if(!isNaN(param1))
         {
            _loc2_ = String(roundTenths(param1,false));
         }
         else
         {
            _loc2_ = "";
         }
         return _loc2_;
      }
      
      public static function zeroNaN(param1:Number) : Number
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         return param1;
      }
      
      public static function interpolate(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Number
      {
         var _loc6_:Number = NaN;
         if(param3 < param1 || param1 == param4)
         {
            _loc6_ = param2;
         }
         else if(param3 > param4)
         {
            _loc6_ = param5;
         }
         else
         {
            GWizUtils.assert(param4 != param1);
            _loc6_ = (_loc6_ = (param3 - param1) / (param4 - param1) * (param5 - param2)) + param2;
         }
         return _loc6_;
      }
      
      public static function newDate2000(param1:String) : Date
      {
         var _loc2_:Date = new Date(param1);
         if(param1 && param1 != "")
         {
            if(_loc2_.getFullYear() < 2000)
            {
               _loc2_ = new Date(_loc2_.getFullYear() + 100,_loc2_.getMonth(),_loc2_.getDate());
            }
         }
         return _loc2_;
      }
      
      public static function pctDiff(param1:Number, param2:Number) : Number
      {
         return Math.abs(param1 - param2) / Math.abs(param1);
      }
      
      public static function removeXMLNodes(param1:XMLList, param2:Array) : void
      {
         var _loc3_:int = 0;
         if(param1.length() > 0)
         {
            _loc3_ = param1.children().length() - 1;
            while(_loc3_ >= 0)
            {
               if(param2.indexOf(param1.children()[_loc3_].toString()) != -1)
               {
                  delete param1.children()[_loc3_];
               }
               else if(param1.children()[_loc3_].children())
               {
                  removeXMLNodes(param1.children()[_loc3_].children(),param2);
               }
               _loc3_--;
            }
         }
      }
      
      public static function objectToXML(param1:Object) : XML
      {
         var _loc2_:QName = new QName("root");
         var _loc3_:XMLDocument = new XMLDocument();
         var _loc4_:SimpleXMLEncoder;
         var _loc5_:XMLNode = (_loc4_ = new SimpleXMLEncoder(_loc3_)).encodeValue(param1,_loc2_,_loc3_);
         return new XML(_loc3_.toString());
      }
      
      public static function XMLToObject(param1:XML) : Object
      {
         var _loc2_:String = param1.toString();
         var _loc3_:XMLDocument = new XMLDocument(_loc2_);
         var _loc4_:SimpleXMLDecoder;
         return (_loc4_ = new SimpleXMLDecoder(true)).decodeXML(_loc3_);
      }
      
      public static function XMLToArrayCollection(param1:XML, param2:ArrayCollection = null) : ArrayCollection
      {
         var _loc4_:XML = null;
         var _loc3_:ArrayCollection = param2 == null ? new ArrayCollection() : param2;
         _loc3_.removeAll();
         for each(_loc4_ in param1.item)
         {
            _loc3_.addItem(XMLToObject(_loc4_).item);
         }
         return _loc3_;
      }
      
      public static function addPctLabelFcn(param1:Object, param2:GridColumn = null) : String
      {
         var _loc3_:String = null;
         if(param2)
         {
            param1 = param1[param2.dataField];
         }
         if(!param1)
         {
            return "";
         }
         if(param1)
         {
            _loc3_ = param1.toString();
         }
         else
         {
            _loc3_ = "0";
         }
         return _loc3_ + "%";
      }
      
      public static function NaNToNALabelFcn(param1:Object, param2:GridColumn = null) : String
      {
         if(param2)
         {
            param1 = param1[param2.dataField];
         }
         if(!param1)
         {
            return "N/A";
         }
         var _loc3_:String = String(param1);
         if(_loc3_ == "NaN")
         {
            _loc3_ = "N/A";
         }
         if(GWizUtils.debug && _loc3_ == "0.0125")
         {
            log.debug("gotcha");
         }
         return _loc3_;
      }
      
      public static function convUnitsInMMLabelFcn(param1:Object, param2:GridColumn = null) : String
      {
         if(param2)
         {
            param1 = param1[param2.dataField];
         }
         if(!param1)
         {
            return "0";
         }
         var _loc3_:Number = 0;
         if(param1)
         {
            _loc3_ = Number(param1.toString());
         }
         return GWizUtils.formatPlaces(_loc3_,4,true,MM_UNITS);
      }
      
      public static function convUnitsInKWLabelFcn(param1:Object, param2:GridColumn = null) : String
      {
         if(param2)
         {
            param1 = param1[param2.dataField];
         }
         if(!param1)
         {
            return "0";
         }
         var _loc3_:Number = 0;
         if(param1)
         {
            _loc3_ = Number(param1.toString());
         }
         return GWizUtils.formatPlaces(_loc3_,3,true,GWizUtils.KW_UNITS);
      }
      
      public static function convUnitsFtMLabelFcn(param1:Object, param2:GridColumn = null) : String
      {
         if(param2)
         {
            param1 = param1[param2.dataField];
         }
         if(!param1)
         {
            return "0";
         }
         var _loc3_:Number = 0;
         if(param1)
         {
            _loc3_ = Number(param1.toString());
         }
         return GWizUtils.formatPlaces(_loc3_,0,true,M_UNITS);
      }
      
      public static function convUnitsCCLabelFcn(param1:Object, param2:GridColumn = null) : String
      {
         if(param2)
         {
            param1 = param1[param2.dataField];
         }
         if(!param1)
         {
            return "0";
         }
         var _loc3_:Number = Number(param1.toString());
         return GWizUtils.formatPlaces(_loc3_,2,true,CC_UNITS);
      }
      
      public static function roundTenthsLabelFcn(param1:Object, param2:GridColumn = null) : String
      {
         if(param2)
         {
            param1 = param1[param2.dataField];
         }
         if(param1 == null)
         {
            return "";
         }
         var _loc3_:Number = Number(param1.toString());
         return GWizUtils.formatPlaces(_loc3_,4);
      }
      
      public static function roundHundredthsLabelFcn(param1:Object, param2:GridColumn = null) : String
      {
         if(param2)
         {
            param1 = param1[param2.dataField];
         }
         if(!param1)
         {
            return "";
         }
         var _loc3_:Number = Number(param1.toString());
         return GWizUtils.formatPlaces(_loc3_,2);
      }
      
      public static function roundBigTenthsLabelFcn(param1:Object, param2:GridColumn = null) : String
      {
         if(param2)
         {
            param1 = param1[param2.dataField];
         }
         if(!param1)
         {
            return "";
         }
         var _loc3_:Number = Number(param1.toString());
         return GWizUtils.formatPlaces(_loc3_,1);
      }
      
      public static function dateLabelFcn(param1:Object, param2:GridColumn = null) : String
      {
         if(param2)
         {
            param1 = param1[param2.dataField];
         }
         var _loc3_:String = String(param1);
         var _loc4_:Date = new Date(_loc3_);
         if(isNaN(_loc4_.valueOf()))
         {
            _loc4_ = null;
         }
         if(_loc4_)
         {
            _loc3_ = _loc4_.month + 1 + "/" + _loc4_.date + "/" + _loc4_.fullYear;
         }
         else
         {
            _loc3_ = "";
         }
         return _loc3_;
      }
      
      public static function zapKey(param1:KeyboardEvent) : void
      {
         param1.preventDefault();
         param1.stopImmediatePropagation();
      }
      
      public static function arrayValueToIndex(param1:Array, param2:Object, param3:String) : int
      {
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc4_:int = 0;
         if(param1)
         {
            _loc5_ = 0;
            while(_loc5_ < param1.length)
            {
               if((_loc6_ = param1[_loc5_])[param3] == param2)
               {
                  _loc4_ = _loc5_;
                  break;
               }
               _loc5_++;
            }
         }
         return _loc4_;
      }
      
      public static function AND(param1:Boolean, param2:Boolean, param3:Boolean = true) : Boolean
      {
         return param1 && param2 && param3;
      }
      
      public static function set LogErrorContext(param1:String) : void
      {
         var logFile:File = null;
         var stream:FileStream = null;
         var now:Date = null;
         var value:String = param1;
         _logContext = value;
         if(LOG_CONTEXTS && LogErrorToFile)
         {
            try
            {
               logFile = GWizSettings.getPrefsFile("Logfile.txt");
               stream = new FileStream();
               stream.open(logFile,FileMode.APPEND);
               now = new Date();
               stream.writeUTFBytes(now + ": context: " + _logContext + "\n");
               stream.close();
            }
            catch(e:Error)
            {
               GWizPopUpManager.Show("Error saving log file: " + e.message + ", " + e.name + ", " + e.errorID,"Error: Save Log Failure",GWizPopUpManager.ERROR);
            }
         }
      }
      
      public static function get LogErrorContext() : String
      {
         return _logContext;
      }
      
      public static function LogError(param1:String, param2:Boolean = false) : void
      {
         var logFile:File = null;
         var stream:FileStream = null;
         var now:Date = null;
         var msg:String = param1;
         var showContext:Boolean = param2;
         if(showContext)
         {
            msg = msg + ", context = " + LogErrorContext;
         }
         errorLog += msg + "\n";
         ++nLogs;
         log.debug("Log Error: " + msg);
         if(GWizUtils.debug && msg.indexOf("HTTP") >= 0)
         {
            log.debug("Possible HTTP Request error");
         }
         if(!GWizSettings.appInitCompleted || LogErrorToFile)
         {
            try
            {
               logFile = GWizSettings.getPrefsFile("Logfile.txt");
               stream = new FileStream();
               stream.open(logFile,FileMode.APPEND);
               now = new Date();
               stream.writeUTFBytes(now + ":" + msg);
               stream.close();
            }
            catch(e:Error)
            {
               log.debug("Can\'t save log file");
               GWizPopUpManager.Show("Error saving log file: " + e.message + ", " + e.name + ", " + e.errorID,"Error: Save Log Failure",GWizPopUpManager.ERROR);
            }
            if(false && !GWizSettings.appInitCompleted)
            {
               GWizPopUpManager.Show("Error: " + msg,"Error: Save Log Failure",GWizPopUpManager.ERROR);
            }
         }
      }
      
      public static function logXYZ(param1:ILogger, param2:String, param3:Number, param4:Number, param5:Number) : void
      {
         param2 += " X" + roundThousandths(param3) + " Y" + roundThousandths(param4) + " Z" + roundThousandths(param5);
         param1.debug(param2);
      }
      
      public static function doWebPage(param1:String, param2:String = "") : Boolean
      {
         var msg:String = null;
         var url:String = param1;
         var campaign:String = param2;
         if(!url || url == "" || GWizCredentials.badConnection)
         {
            return true;
         }
         var ok:Boolean = true;
         try
         {
            navigateToURL(new URLRequest(url + campaign),"_blank");
         }
         catch(e:Error)
         {
            msg = "Sorry, a popup blocker of some kind blocked the browser opening.  Copy this link to your browser: " + url;
            GWizPopUpManager.Show(msg,"Browser Failed",GWizPopUpManager.WARN);
            GWizMandrill.msg("doWebPage FAIL","Popup Blocker");
            ok = false;
         }
         return ok;
      }
      
      public static function randLimits(param1:Number, param2:Number) : Number
      {
         return Math.floor(Math.random() * (1 + param2 - param1)) + param1;
      }
      
      public static function randLimitsNum(param1:Number, param2:Number) : Number
      {
         return Math.random() * (param2 - param1) + param1;
      }
      
      public static function randDateLimits(param1:Date, param2:int, param3:int) : Date
      {
         var _loc4_:int = randLimitsNum(param2,param3);
         param1.time += _loc4_ * GWizUtils.MILLI_PER_DAY;
         return param1;
      }
      
      public static function interval(param1:Number, param2:Number, param3:Number) : Number
      {
         return param1 / param2 * param3;
      }
      
      public static function cookbookSearch(param1:String) : void
      {
         googleSearch(param1,"cnccookbook.com");
      }
      
      public static function googleSearch(param1:String, param2:String = null) : void
      {
         var _loc3_:String = "http://www.google.com/search?q=";
         param1.replace(" ","+");
         _loc3_ += param1;
         if(param2 && param2 != "")
         {
            _loc3_ += "+site:" + param2;
         }
         GWizUtils.doWebPage(_loc3_);
      }
      
      public static function requiredFields(param1:Object, param2:Array) : String
      {
         var _loc4_:String = null;
         var _loc3_:int = 0;
         while(_loc3_ < param2.length)
         {
            _loc4_ = param2.pop();
            if(!param1.hasOwnProperty(_loc4_))
            {
               return _loc4_;
            }
            _loc3_++;
         }
         return "";
      }
      
      public static function isEmptyCollection(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return true;
         }
         if(param1 is Array)
         {
            return (param1 as Array).length == 0;
         }
         if(param1 is ArrayCollection)
         {
            return (param1 as ArrayCollection).length == 0;
         }
         if(param1 is IList)
         {
            return (param1 as IList).length == 0;
         }
         if(param1 is GWizMap)
         {
            return (param1 as GWizMap).length == 0;
         }
         GWizUtils.assert(false);
         return true;
      }
      
      public static function setElementVisible(param1:Group, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:IVisualElement = null;
         if(param1)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.numChildren)
            {
               (_loc4_ = param1.getElementAt(_loc3_)).visible = param2;
               _loc3_++;
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get Units() : String
      {
         return GWizUtils._81880911Units;
      }
      
      public static function set Units(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizUtils._81880911Units;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizUtils,"Units",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get debug() : Boolean
      {
         return GWizUtils._95458899debug;
      }
      
      public static function set debug(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizUtils._95458899debug;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizUtils,"debug",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get errorLog() : String
      {
         return GWizUtils._1396096028errorLog;
      }
      
      public static function set errorLog(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizUtils._1396096028errorLog;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizUtils,"errorLog",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
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
