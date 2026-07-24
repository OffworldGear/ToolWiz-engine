package utils
{
   import mx.collections.ArrayCollection;
   
   public class GWizGeomUtils
   {
      
      public static var taperAlpha:Number;
      
      public static var taperAlpha2:Number;
      
      public static var taperSmallEnd:Number;
      
      public static var taperBigEnd:Number;
      
      public static var taperL:Number;
      
      public static var specAngles:int = 0;
      
      public static var specLens:int = 0;
       
      
      public function GWizGeomUtils()
      {
         super();
      }
      
      public static function euclideanDistance(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : Number
      {
         return Math.sqrt(GWizUtils.square(param1 - param4) + GWizUtils.square(param2 - param5) + GWizUtils.square(param3 - param6));
      }
      
      public static function equalCircleOverlapArea(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = Math.acos(param2 * param2 / (2 * param1 * param2));
         var _loc4_:Number = 2 * _loc3_;
         return Number(2 * (0.5 * _loc4_ * param1 * param1 - 0.5 * param1 * param1 * Math.sin(_loc4_)));
      }
      
      public static function circleArea(param1:Number) : Number
      {
         return Math.PI * param1 * param1;
      }
      
      public static function cylinderVolume(param1:Number, param2:Number) : Number
      {
         return Math.PI * param1 * param1 * param2;
      }
      
      public static function boltCircleCenters(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Boolean = true) : ArrayCollection
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc12_:Object = null;
         var _loc11_:ArrayCollection = new ArrayCollection();
         param3 = GWizUtils.radians(param3);
         _loc8_ = GWizUtils.radians(360 / param2);
         _loc7_ = 1;
         while(_loc7_ <= param2)
         {
            _loc12_ = {
               "angle":0,
               "x":0,
               "y":0
            };
            _loc9_ = param1 * Math.cos(param3) + param4;
            _loc10_ = param1 * Math.sin(param3) + param5;
            _loc9_ = GWizUtils.roundTenths(_loc9_,param6);
            _loc10_ = GWizUtils.roundTenths(_loc10_,param6);
            _loc12_.angle = GWizUtils.degrees(param3);
            _loc12_.x = _loc9_;
            _loc12_.y = _loc10_;
            _loc11_.addItem(_loc12_);
            param3 += _loc8_;
            _loc7_++;
         }
         return _loc11_;
      }
      
      public static function boltArcCenters(param1:Number, param2:int, param3:Number, param4:Number, param5:Number, param6:Number) : ArrayCollection
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Object = null;
         var _loc7_:ArrayCollection = new ArrayCollection();
         var _loc8_:Number = param3;
         var _loc9_:int = 0;
         while(_loc9_ < param2)
         {
            _loc10_ = param5 + param1 * Math.cos(GWizUtils.radians(_loc8_));
            _loc11_ = param6 + param1 * Math.sin(GWizUtils.radians(_loc8_));
            _loc12_ = {
               "x":_loc10_,
               "y":_loc11_
            };
            _loc7_.addItem(_loc12_);
            _loc8_ += param4;
            _loc9_++;
         }
         return _loc7_;
      }
      
      public static function boltHoleLine(param1:Number, param2:int, param3:Number, param4:Number, param5:Number) : ArrayCollection
      {
         var _loc12_:Object = null;
         var _loc6_:ArrayCollection = new ArrayCollection();
         var _loc7_:Number = param4;
         var _loc8_:Number = param5;
         var _loc9_:Number = param1 * Math.cos(GWizUtils.radians(param3));
         var _loc10_:Number = param1 * Math.sin(GWizUtils.radians(param3));
         var _loc11_:int = 0;
         while(_loc11_ < param2)
         {
            _loc12_ = {
               "x":_loc7_,
               "y":_loc8_
            };
            _loc6_.addItem(_loc12_);
            _loc7_ += _loc9_;
            _loc8_ += _loc10_;
            _loc11_++;
         }
         return _loc6_;
      }
      
      public static function coneDiameter(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = 0;
         param1 = GWizUtils.radians(param1);
         return Number(2 * param2 * Math.tan(param1 / 2));
      }
      
      public static function cornerRoundDiameter(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc5_:Number = NaN;
         var _loc4_:Number = param2;
         if(param3 < param1)
         {
            _loc5_ = coneDiameter(45,param3);
            _loc4_ = coneDiameter(45,param3) + (param2 - _loc5_) / 2;
         }
         return _loc4_;
      }
      
      public static function helixLength(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:Number = Math.PI * param1;
         var _loc5_:Number = param3 / param2;
         var _loc6_:Number = Math.sqrt(_loc4_ * _loc4_ + param2 * param2);
         return _loc5_ * _loc6_;
      }
      
      public static function sphere2X(param1:Number, param2:Number, param3:Number) : Number
      {
         return param3 * Math.sin(param2) * Math.cos(param1);
      }
      
      public static function sphere2Y(param1:Number, param2:Number, param3:Number) : Number
      {
         return param3 * Math.sin(param2) * Math.sin(param1);
      }
      
      public static function sphere2Z(param1:Number, param2:Number, param3:Number) : Number
      {
         return param3 * Math.cos(param2);
      }
      
      public static function cart2Azi(param1:Number, param2:Number, param3:Number) : Number
      {
         return Math.atan2(param2,param1);
      }
      
      public static function cart2Ele(param1:Number, param2:Number, param3:Number) : Number
      {
         return Math.acos(param3 / cart2R(param1,param2,param3));
      }
      
      public static function cart2R(param1:Number, param2:Number, param3:Number) : Number
      {
         return euclideanDistance(param1,param2,param3,0,0,0);
      }
      
      public static function recalcCEA(param1:Number, param2:Number, param3:Number = 180) : Number
      {
         var _loc4_:Number = 2 * Math.acos((param1 / 2 - param2) / (param1 / 2));
         _loc4_ = GWizUtils.degrees(_loc4_) / 2;
         _loc4_ = 180 - param3 + _loc4_;
         return Number(Math.floor(Math.min(180,_loc4_)));
      }
      
      public static function leadAngleToLead(param1:Number, param2:Number) : Number
      {
         param1 = GWizUtils.radians(90 - param1);
         return Math.PI * param2 / Math.tan(param1);
      }
      
      public static function calcRampLen(param1:Number, param2:Number) : Number
      {
         param1 = GWizUtils.radians(param1);
         var _loc3_:Number = param2 / Math.sin(param1);
         return _loc3_ * Math.cos(param1);
      }
      
      public static function calcRampDepth(param1:Number, param2:Number) : Number
      {
         param1 = GWizUtils.radians(param1);
         var _loc3_:Number = param2 / Math.cos(param1);
         return _loc3_ * Math.sin(param1);
      }
      
      public static function taperCalc() : void
      {
         var _loc1_:Number = NaN;
         specAngles = 0;
         specLens = 0;
         if(taperAlpha == taperAlpha)
         {
            ++specAngles;
            taperAlpha2 = taperAlpha / 2;
         }
         if(taperAlpha2 == taperAlpha2)
         {
            ++specAngles;
            taperAlpha = taperAlpha2 * 2;
         }
         if(taperSmallEnd == taperSmallEnd)
         {
            ++specLens;
         }
         if(taperBigEnd == taperBigEnd)
         {
            ++specLens;
         }
         if(taperL == taperL)
         {
            ++specLens;
         }
         if(specAngles <= 2 && specLens + specAngles >= 3)
         {
            if(taperSmallEnd > taperBigEnd && taperBigEnd == taperBigEnd)
            {
               _loc1_ = taperBigEnd;
               taperBigEnd = taperSmallEnd;
               taperSmallEnd = _loc1_;
            }
            if(taperL == taperL && taperSmallEnd == taperSmallEnd && taperBigEnd == taperBigEnd)
            {
               taperAlpha = GWizUtils.degrees(2 * Math.atan((taperBigEnd - taperSmallEnd) / 2 / taperL));
            }
            else if((taperAlpha == taperAlpha || taperAlpha2 == taperAlpha2) && taperL == taperL && (taperSmallEnd == taperSmallEnd || taperBigEnd == taperBigEnd))
            {
               if(taperSmallEnd == taperSmallEnd)
               {
                  taperBigEnd = Math.tan(GWizUtils.radians(taperAlpha2)) * taperL * 2 + taperSmallEnd;
               }
               else
               {
                  taperSmallEnd = taperBigEnd - Math.tan(GWizUtils.radians(taperAlpha2)) * taperL * 2;
               }
            }
            else
            {
               taperL = (taperBigEnd - taperSmallEnd) / 2 / Math.tan(GWizUtils.radians(taperAlpha2));
            }
            taperAlpha2 = taperAlpha / 2;
         }
      }
   }
}
