package post
{
   import configinfo.GWizSettings;
   import mx.formatters.NumberBase;
   import mx.formatters.NumberBaseRoundType;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizNumParser
   {
      
      private static const log:ILogger = Log.getLogger("GWizNumParser");
      
      public static const DEC_REQUIRED:int = 0;
      
      public static const DEC_OPTIONAL:int = 1;
      
      public static const NO_DECIMAL:int = 2;
       
      
      private var savedPattern:String = "";
      
      public var plusReqd:Boolean = false;
      
      public var negAllowed:Boolean = false;
      
      public var uptoPre:Boolean = false;
      
      public var preMax:int = 0;
      
      public var decMode:int = 1;
      
      public var uptoPost:Boolean = false;
      
      public var postMax:int = 0;
      
      public var divisor:Number = 1;
      
      public var hasLimits:Boolean = false;
      
      public var loLimit:Number = NaN;
      
      public var hiLimit:Number = NaN;
      
      public var errmsg:String = "";
      
      public function GWizNumParser()
      {
         super();
      }
      
      public function setup(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         this.savedPattern = param1;
         if(!param1 || param1 == "")
         {
            return;
         }
         var _loc2_:int = 0;
         this.plusReqd = false;
         if(param1.charAt(_loc2_) == "+")
         {
            this.plusReqd = true;
            _loc2_++;
         }
         this.negAllowed = false;
         if(param1.charAt(_loc2_) == "-")
         {
            this.negAllowed = true;
            _loc2_++;
         }
         this.uptoPre = false;
         if(param1.charAt(_loc2_) == ">")
         {
            this.uptoPre = true;
            _loc2_++;
         }
         this.preMax = int(param1.charAt(_loc2_++));
         GWizUtils.assert(!isNaN(this.preMax));
         if(_loc2_ >= param1.length)
         {
            this.decMode = NO_DECIMAL;
         }
         else
         {
            switch(param1.charAt(_loc2_++))
            {
               case ".":
                  this.decMode = DEC_REQUIRED;
                  break;
               case "[":
                  this.decMode = DEC_OPTIONAL;
                  _loc2_ += 2;
                  break;
               case " ":
                  this.decMode = NO_DECIMAL;
            }
         }
         this.uptoPost = false;
         if(param1.charAt(_loc2_) == ">")
         {
            this.uptoPost = true;
            _loc2_++;
         }
         this.postMax = int(param1.charAt(_loc2_++));
         GWizUtils.assert(!isNaN(this.postMax));
         this.divisor = 1;
         if(param1.charAt(_loc2_) == "/")
         {
            _loc3_ = "";
            _loc2_++;
            while(_loc2_ < param1.length && "0" <= param1.charAt(_loc2_) && param1.charAt(_loc2_) <= "9")
            {
               _loc3_ += param1.charAt(_loc2_++);
            }
            this.divisor = Number(_loc3_);
         }
         this.hasLimits = false;
         while(_loc2_ < param1.length && param1.charAt(_loc2_) == " ")
         {
            _loc2_++;
         }
         if(_loc2_ < param1.length && param1.substr(_loc2_,"range".length).toLowerCase() == "range")
         {
            _loc2_ += "range".length;
            while(_loc2_ < param1.length && param1.charAt(_loc2_) == " ")
            {
               _loc2_++;
            }
            _loc4_ = "";
            while(_loc2_ < param1.length && param1.charAt(_loc2_) != " ")
            {
               _loc4_ += param1.charAt(_loc2_);
               _loc2_++;
            }
            while(_loc2_ < param1.length && param1.charAt(_loc2_) == " ")
            {
               _loc2_++;
            }
            _loc5_ = "";
            while(_loc2_ < param1.length && param1.charAt(_loc2_) != " ")
            {
               _loc5_ += param1.charAt(_loc2_);
               _loc2_++;
            }
            this.loLimit = Number(_loc4_);
            this.hiLimit = Number(_loc5_);
            this.hasLimits = !isNaN(this.loLimit) && !isNaN(this.hiLimit);
         }
         if(!this.hasLimits)
         {
            this.loLimit = NaN;
            this.hiLimit = NaN;
         }
      }
      
      public function getPattern() : String
      {
         var _loc1_:* = "";
         if(this.plusReqd)
         {
            _loc1_ += "+";
         }
         if(this.negAllowed)
         {
            _loc1_ += "-";
         }
         if(this.uptoPre)
         {
            _loc1_ += ">";
         }
         _loc1_ += this.preMax;
         switch(this.decMode)
         {
            case DEC_REQUIRED:
               _loc1_ += ".";
               break;
            case DEC_OPTIONAL:
               _loc1_ += "[.]";
               break;
            case NO_DECIMAL:
               _loc1_ += " ";
         }
         if(this.uptoPost)
         {
            _loc1_ += ">";
         }
         _loc1_ += this.postMax;
         if(this.divisor != 1)
         {
            _loc1_ += "/" + this.divisor;
         }
         if(this.hasLimits)
         {
            _loc1_ += " range " + this.loLimit + " " + this.hiLimit;
         }
         return _loc1_;
      }
      
      public function parseNum(param1:String) : Number
      {
         var _loc2_:Number = NaN;
         var _loc7_:String = null;
         var _loc8_:Boolean = false;
         var _loc9_:String = null;
         var _loc10_:Boolean = false;
         var _loc11_:String = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         this.errmsg = "";
         param1 = param1.replace(/\s/g,"");
         if(GWizSettings.post.anyNumber)
         {
            _loc2_ = Number(param1);
            if(isNaN(_loc2_))
            {
               this.errmsg += "Invalid number";
            }
         }
         else
         {
            if(param1.charAt(_loc3_) == "+")
            {
               _loc5_ = true;
               _loc3_++;
            }
            if(param1.charAt(_loc3_) == "-")
            {
               _loc6_ = true;
               _loc3_++;
            }
            if(_loc6_ && _loc5_)
            {
               this.errmsg += " can\'t be both positive and negative. ";
            }
            else if(!_loc6_)
            {
               if(this.plusReqd && !_loc5_)
               {
                  this.errmsg += " \'+\' required for positive numbers. ";
               }
            }
            else if(_loc6_ && !this.negAllowed)
            {
               this.errmsg += " must be positive. ";
            }
            _loc7_ = "";
            _loc8_ = false;
            _loc9_ = "";
            while(_loc3_ < param1.length && !_loc8_)
            {
               _loc9_ = param1.charAt(_loc3_++);
               if("0" <= _loc9_.charAt(0) && _loc9_.charAt(0) <= "9")
               {
                  _loc7_ += _loc9_;
               }
               else
               {
                  _loc8_ = true;
                  _loc3_--;
               }
            }
            _loc10_ = false;
            if(_loc3_ < param1.length && param1.charAt(_loc3_) == ".")
            {
               _loc10_ = true;
               _loc3_++;
               switch(this.decMode)
               {
                  case DEC_REQUIRED:
                     break;
                  case DEC_OPTIONAL:
                     break;
                  case NO_DECIMAL:
                     this.errmsg += " decimal not allowed here. ";
               }
            }
            else if(this.decMode == DEC_REQUIRED)
            {
               this.errmsg += " decimal point required. ";
            }
            if(_loc7_.length > this.preMax)
            {
               this.errmsg += " too many digits left of decimal point. ";
            }
            if(!this.uptoPre && _loc7_.length < this.preMax)
            {
               this.errmsg = " must have exactly " + this.preMax + " digits";
               if(_loc10_)
               {
                  this.errmsg += " left of the decimal. ";
               }
               else
               {
                  this.errmsg += ". ";
               }
            }
            if(_loc3_ < param1.length && param1.charAt(_loc3_) == ".")
            {
               this.errmsg = " extra decimal point.";
               _loc3_++;
            }
            _loc11_ = "";
            _loc8_ = false;
            while(_loc3_ < param1.length && !_loc8_)
            {
               _loc9_ = param1.charAt(_loc3_++);
               if("0" <= _loc9_.charAt(0) && _loc9_.charAt(0) <= "9")
               {
                  _loc11_ += _loc9_;
               }
               else
               {
                  _loc8_ = true;
                  _loc3_--;
               }
            }
            if(_loc11_.length > this.postMax)
            {
               this.errmsg += " too many digits right of decimal point. ";
            }
            if(!this.uptoPost && _loc11_.length < this.postMax)
            {
               this.errmsg = " must have exactly " + this.postMax + " digits";
               if(_loc10_)
               {
                  this.errmsg += " right of the decimal. ";
               }
               else
               {
                  this.errmsg += ". ";
               }
            }
            _loc2_ = Number(_loc7_ + "." + _loc11_);
            if(_loc6_)
            {
               _loc2_ = -_loc2_;
            }
            if(!_loc10_)
            {
               _loc2_ /= this.divisor;
            }
            if(this.hasLimits)
            {
               if(_loc2_ < this.loLimit)
               {
                  this.errmsg += " must be greater than " + this.loLimit + ". ";
               }
               if(_loc2_ > this.hiLimit)
               {
                  this.errmsg += " must be less than " + this.hiLimit + ". ";
               }
            }
            if(_loc3_ < param1.length)
            {
               this.errmsg += " extra characters in number: \'" + param1.substr(_loc3_) + "\'";
            }
         }
         return _loc2_;
      }
      
      public function formatNum(param1:Number, param2:Boolean = true) : String
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:NumberBase = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc3_:* = "";
         this.errmsg = "";
         if(GWizSettings.post.anyNumber && param2)
         {
            _loc3_ = String(param1);
            if(isNaN(param1))
            {
               this.errmsg += "Invalid number";
            }
         }
         else
         {
            _loc4_ = 1;
            if(param1 >= 0)
            {
               if(this.plusReqd)
               {
                  _loc3_ += "+";
               }
            }
            else
            {
               _loc4_ = -1;
               param1 = Math.abs(param1);
               if(!this.negAllowed)
               {
                  this.errmsg += "Negative numbers are not allowed. ";
               }
            }
            _loc5_ = Math.floor(Math.abs(param1));
            _loc6_ = param1 - _loc5_;
            if((_loc7_ = String(_loc6_)).length > this.postMax)
            {
               _loc7_ = (_loc11_ = new NumberBase()).formatRoundingWithPrecision(_loc7_,NumberBaseRoundType.NEAREST,this.postMax);
            }
            if(_loc7_ == "1")
            {
               _loc5_ += 1;
               _loc6_ = 0;
               _loc7_ = "0.0";
            }
            if(!this.uptoPost)
            {
               _loc7_ = _loc11_.formatPrecision(_loc7_,this.postMax);
            }
            _loc8_ = String(_loc5_);
            if(_loc4_ < 0)
            {
               _loc8_ = "-" + _loc8_;
            }
            if(this.preMax < _loc8_.length)
            {
               this.errmsg += "Too many digits left of decimal. ";
            }
            if(!this.uptoPre && _loc8_.length < this.preMax)
            {
               while(_loc8_.length < this.preMax)
               {
                  _loc8_ = "0" + _loc8_;
               }
            }
            if(_loc7_.length > 0 && _loc7_.indexOf(".") != -1)
            {
               _loc7_ = _loc7_.substr(_loc7_.indexOf(".") + 1,_loc7_.length);
            }
            _loc9_ = false;
            _loc10_ = true;
            switch(this.decMode)
            {
               case DEC_REQUIRED:
                  _loc9_ = true;
                  _loc12_ = 0;
                  while(_loc12_ < _loc7_.length)
                  {
                     if(_loc7_.charAt(_loc12_) != "0")
                     {
                        _loc10_ = false;
                        break;
                     }
                     _loc12_++;
                  }
                  _loc3_ = _loc8_ + ".";
                  if(!_loc10_)
                  {
                     _loc3_ += _loc7_;
                  }
                  break;
               case DEC_OPTIONAL:
                  if(_loc9_ = _loc7_.length > 0 && _loc6_ > 0)
                  {
                     _loc3_ = _loc8_ + "." + _loc7_;
                  }
                  else
                  {
                     _loc3_ = _loc8_;
                  }
                  break;
               case NO_DECIMAL:
                  _loc9_ = false;
                  _loc13_ = 0;
                  while(_loc12_ < _loc7_.length)
                  {
                     if(_loc7_.charAt(_loc13_) != "0")
                     {
                        _loc10_ = false;
                        break;
                     }
                     _loc12_++;
                  }
                  if(!_loc10_)
                  {
                     this.errmsg += "No digits allowed right of decimal. ";
                  }
                  _loc3_ = _loc8_;
                  break;
               default:
                  GWizUtils.assert(false);
            }
         }
         return _loc3_;
      }
      
      public function maxValue() : Number
      {
         var _loc1_:Number = 1;
         var _loc2_:int = 1;
         while(_loc2_ < this.preMax)
         {
            _loc1_ *= 10;
            _loc2_++;
         }
         return _loc1_ * 10 - 1;
      }
   }
}
