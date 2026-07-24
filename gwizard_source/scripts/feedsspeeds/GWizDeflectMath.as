package feedsspeeds
{
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizDeflectMath
   {
      
      private static const log:ILogger = Log.getLogger("GWizDeflectMath");
      
      private static const ROUGH_DEF_ALLOW_IMP:Number = 0.001;
      
      private static const ROUGH_DEF_ALLOW_MM:Number = 0.02 / 25.4;
      
      private static const FINISH_DEF_ALLOW_IMP:Number = 0.0002;
      
      private static const FINISH_DEF_ALLOW_MM:Number = 0.005 / 25.4;
       
      
      public var initCutDepth:Number = -1;
      
      public var initCutWidth:Number = -1;
      
      public var initTipLen:Number = -1;
      
      public var initRPM:Number = -1;
      
      public var initIPM:Number = -1;
      
      public var initSlider:Number = -1;
      
      public var tDia:Number;
      
      public var cutDepth:Number;
      
      public var cutWidth:Number;
      
      public var chipload:Number;
      
      public var power:Number;
      
      public var removalRate:Number;
      
      public var ipm:Number;
      
      public var stickout:Number;
      
      public var rpm:Number;
      
      public var deflection:Number;
      
      public var slider:Number;
      
      public var feedrate:Number = -1;
      
      private var iter:Number = 0;
      
      private const SAFETY_MARGIN:Number = 6.0E-6;
      
      private const SAFETY_MARGIN_K:Number = 0.006;
      
      public function GWizDeflectMath()
      {
         super();
      }
      
      public static function defaultDefAllowance(param1:Number, param2:Boolean) : Number
      {
         var _loc3_:Number = GWizSettings.FeedsSpeedsApp.mfgSpecs.mfgIPT.value;
         if(!param2)
         {
            param2 = !GWizDeflectOptions.bestFinishAux;
         }
         var _loc4_:Number = 0;
         if(param2)
         {
            if(GWizDeflectOptions.limitChatterAux)
            {
               _loc4_ = ROUGH_DEF_ALLOW_IMP;
               _loc4_ = Math.min(_loc4_,0.01 * param1);
            }
            else
            {
               _loc4_ = _loc3_ * (GWizSettings.deflectPct / 100);
               if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
               {
                  _loc4_ /= 25.4;
               }
            }
         }
         else
         {
            _loc4_ = FINISH_DEF_ALLOW_IMP;
            _loc4_ = Math.min(_loc4_,0.002 * param1);
         }
         return _loc4_;
      }
      
      public static function torque(param1:Number, param2:Number) : Number
      {
         if(param2 <= 0)
         {
            return 0;
         }
         return 63030 * param1 / param2;
      }
      
      public function optimizeMode(param1:String, param2:Number, param3:Number) : void
      {
         this.tDia = param3;
         this.grabValues();
         this.initTipLen = param2;
         this.deflection = 0;
         var _loc4_:Boolean = this.doOptimize(param1);
         this.recalc(false);
         this.returnValues();
      }
      
      public function doOptimize(param1:String) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc2_:* = false;
         var _loc3_:Number = -1;
         this.feedrate = -1;
         if(param1 == "")
         {
            return false;
         }
         this.iter = 0;
         if(param1 == "feed")
         {
            this.restoreValues();
            this.feedsSpeedsRecalc();
            _loc2_ = Boolean(this.ipmBisector());
            this.feedrate = this.ipm;
         }
         else if(param1 == "stick")
         {
            _loc2_ = Boolean(this.stickoutBisector());
         }
         else if(param1 == "slider")
         {
            _loc2_ = Boolean(this.sliderBisector());
         }
         else
         {
            _loc2_ = Boolean(this.bisector(param1 == "width"));
         }
         if(_loc2_)
         {
            _loc2_ = (_loc4_ = this.iteration(this.cutDepth,this.cutWidth,this.feedrate,this.rpm,true,true,this.stickout,this.slider)) <= this.SAFETY_MARGIN;
         }
         return _loc2_;
      }
      
      public function restoreValues() : void
      {
         GWizSettings.FeedsSpeedsApp.cutDepth.setVal(this.initCutDepth);
         GWizSettings.FeedsSpeedsApp.cutWidth.setVal(this.initCutWidth);
         GWizSettings.FeedsSpeedsApp.td._stickout.setVal(this.initTipLen);
         if(this.initIPM != -1)
         {
            GWizSettings.FeedsSpeedsApp.IPM.resetOverride();
         }
         if(this.initRPM != -1)
         {
            GWizSettings.FeedsSpeedsApp.RPM.resetOverride();
         }
         if(this.initSlider != -1)
         {
            GWizSettings.FeedsSpeedsApp.GasPedal.value = this.initSlider;
         }
      }
      
      public function recalc(param1:Boolean) : void
      {
         if(GWizSettings.FeedsSpeedsApp == null)
         {
            return;
         }
         this.deflection = this.toolDeflection(this.cutDepth,this.ipm,this.rpm,this.stickout,param1,GWizSettings.FeedsSpeedsApp.td.toolParms.flutes,GWizSettings.FeedsSpeedsApp.td.toolParms.helixAngle);
         this.grabValues();
      }
      
      public function grabValues() : void
      {
         this.tDia = GWizSettings.FeedsSpeedsApp.td.toolParms.shankSize;
         this.cutDepth = GWizSettings.FeedsSpeedsApp.cutDepth.getVal();
         this.cutWidth = GWizSettings.FeedsSpeedsApp.cutWidth.getVal();
         this.chipload = GWizSettings.FeedsSpeedsApp.AFPT.getVal();
         this.power = GWizSettings.FeedsSpeedsApp.HP.getValCurrUnits();
         this.removalRate = GWizSettings.FeedsSpeedsApp.MRR.getValCurrUnits();
         this.ipm = GWizSettings.FeedsSpeedsApp.IPM.getVal();
         this.rpm = GWizSettings.FeedsSpeedsApp.RPM.getVal();
         this.stickout = GWizSettings.FeedsSpeedsApp.td._stickout.getVal();
         this.slider = GWizSettings.FeedsSpeedsApp.GasPedal.value;
         log.debug("grabValues rpm = " + this.rpm);
         if(this.initCutDepth == -1)
         {
            this.initCutDepth = this.cutDepth;
            this.initCutWidth = this.cutWidth;
            this.initIPM = this.ipm;
            this.initRPM = this.rpm;
            this.initTipLen = GWizSettings.FeedsSpeedsApp.td._stickout.getVal();
            this.initSlider = GWizSettings.FeedsSpeedsApp.GasPedal.value;
         }
      }
      
      public function returnValues() : void
      {
         GWizSettings.FeedsSpeedsApp.cutDepth.setVal(this.cutDepth);
         GWizSettings.FeedsSpeedsApp.cutWidth.setVal(this.cutWidth);
         GWizSettings.FeedsSpeedsApp.IPM.setVal(this.ipm);
         GWizSettings.FeedsSpeedsApp.RPM.setVal(this.rpm);
         GWizSettings.FeedsSpeedsApp.td._stickout.setVal(this.stickout);
         GWizSettings.FeedsSpeedsApp.GasPedal.value = this.slider;
      }
      
      private function bisector(param1:Boolean) : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         _loc5_ = 0.0001 / 10;
         var _loc6_:int = 200;
         var _loc7_:int = 0.00001;
         var _loc8_:int = _loc5_;
         if(param1)
         {
            _loc10_ = this.tDia;
            if(GWizSettings.FeedsSpeedsApp.useHSM())
            {
               _loc10_ *= GWizSettings.hsmWidthPct / 100;
            }
            if(this.iteration(this.cutDepth,_loc7_) <= 0)
            {
               _loc2_ = _loc7_;
               _loc3_ = _loc10_;
            }
            else
            {
               _loc2_ = _loc10_;
               _loc3_ = _loc7_;
            }
            if(!this.safeDeflection())
            {
               GWizPopUpManager.Show("Optimizer Failed: Cut untenable even at minimum width","Error: Optimization Failed",GWizPopUpManager.ERROR);
               return false;
            }
            _loc4_ = _loc2_ + (_loc3_ - _loc2_) / 2;
            this.iteration(this.cutDepth,_loc4_);
            while(Math.abs(_loc4_ - _loc2_) > _loc5_ && Math.abs(_loc4_ - _loc3_) > _loc5_ && this.iter < _loc6_)
            {
               if(this.iteration(this.cutDepth,_loc4_,-1,-1,true,false) <= 0)
               {
                  _loc2_ = _loc4_;
               }
               else
               {
                  _loc3_ = _loc4_;
               }
               _loc9_ = _loc4_;
               _loc4_ = _loc2_ + (_loc3_ - _loc2_) / 2;
               if(Math.abs(_loc4_ - _loc9_) <= _loc8_)
               {
                  break;
               }
            }
            if(Math.abs(this.rpm) <= 0.1)
            {
               this.cutWidth = _loc2_ * 0.9;
               this.iteration(this.cutDepth,this.cutWidth);
            }
         }
         else
         {
            if(this.iteration(_loc7_,this.cutWidth) <= 0)
            {
               _loc2_ = _loc7_;
               _loc3_ = GWizSettings.FeedsSpeedsApp.td.toolParms.cutLength;
            }
            else
            {
               _loc2_ = GWizSettings.FeedsSpeedsApp.td.toolParms.cutLength;
               _loc3_ = _loc7_;
            }
            if(!this.safeDeflection())
            {
               GWizPopUpManager.Show("Optimizer Failed: Cut untenable even at minimum depth","Error: Optimization Failed",GWizPopUpManager.ERROR);
               return false;
            }
            _loc4_ = _loc2_ + (_loc3_ - _loc2_) / 2;
            if(GWizUtils.debug)
            {
               log.debug("left = " + _loc2_ + ", midpoint = " + _loc4_ + ", right = " + _loc3_ + ", rpm = " + this.rpm);
            }
            this.iteration(_loc4_,this.cutWidth);
            while(Math.abs(_loc4_ - _loc2_) > _loc5_ && Math.abs(_loc4_ - _loc3_) > _loc5_ && this.iter < _loc6_)
            {
               if(this.iteration(_loc4_,this.cutWidth,-1,-1,false,true) <= 0)
               {
                  _loc2_ = _loc4_;
               }
               else
               {
                  _loc3_ = _loc4_;
               }
               if(GWizUtils.debug)
               {
                  log.debug("left = " + _loc2_ + ", midpoint = " + _loc4_ + ", right = " + _loc3_ + ", rpm = " + this.rpm);
               }
               _loc9_ = _loc4_;
               _loc4_ = _loc2_ + (_loc3_ - _loc2_) / 2;
               if(Math.abs(_loc4_ - _loc9_) <= _loc8_)
               {
                  break;
               }
            }
            if(Math.abs(this.rpm) <= 0.1)
            {
               this.cutDepth = _loc2_ * 0.9;
               this.iteration(this.cutDepth,this.cutWidth);
            }
         }
         return this.iter < _loc6_;
      }
      
      private function ipmBisector() : Boolean
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = 0.0001 / 2;
         var _loc5_:int = 200;
         var _loc6_:Number = 4;
         this.initIPM = this.ipm;
         _loc1_ = this.ipm / _loc6_;
         _loc2_ = this.ipm;
         _loc3_ = _loc1_ + (_loc2_ - _loc1_) / 2;
         while(_loc3_ != _loc1_ && _loc3_ != _loc2_ && this.iter < _loc5_)
         {
            if(this.iteration(this.cutDepth,this.cutWidth,_loc3_) <= 0)
            {
               _loc1_ = _loc3_;
            }
            else
            {
               _loc2_ = _loc3_;
            }
            _loc3_ = GWizUtils.roundTenths(_loc1_ + (_loc2_ - _loc1_) / 2,false);
         }
         return this.iter < _loc5_;
      }
      
      private function rpmBisector() : Boolean
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = 0.0001 / 2;
         var _loc5_:int = 200;
         var _loc6_:Number = 3;
         this.initRPM = this.rpm;
         _loc1_ = this.rpm / _loc6_;
         _loc2_ = this.rpm;
         _loc3_ = _loc1_ + (_loc2_ - _loc1_) / 2;
         while(_loc3_ != _loc1_ && _loc3_ != _loc2_ && this.iter < _loc5_)
         {
            if(this.iteration(this.cutDepth,this.cutWidth,-1,_loc3_) <= 0)
            {
               _loc1_ = _loc3_;
            }
            else
            {
               _loc2_ = _loc3_;
            }
            _loc3_ = GWizUtils.roundTenths(_loc1_ + (_loc2_ - _loc1_) / 2,false);
         }
         return this.iter < _loc5_;
      }
      
      private function stickoutBisector() : Boolean
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = 0.0001 / 2;
         var _loc5_:int = 200;
         this.initTipLen = GWizSettings.FeedsSpeedsApp.td._stickout.getVal();
         _loc1_ = this.tDia * 2;
         _loc2_ = Math.max(this.initTipLen,GWizSettings.FeedsSpeedsApp.td.toolParms.cutLength);
         _loc3_ = _loc1_ + (_loc2_ - _loc1_) / 2;
         while(_loc3_ != _loc1_ && _loc3_ != _loc2_ && this.iter < _loc5_)
         {
            if(this.iteration(this.cutDepth,this.cutWidth,-1,-1,true,true,_loc3_) <= 0)
            {
               _loc1_ = _loc3_;
            }
            else
            {
               _loc2_ = _loc3_;
            }
            _loc3_ = GWizUtils.roundTenths(_loc1_ + (_loc2_ - _loc1_) / 2,false);
         }
         return this.iter < _loc5_;
      }
      
      private function sliderBisector() : Boolean
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = 0.0001 / 2;
         var _loc5_:int = 200;
         this.slider = GWizSettings.FeedsSpeedsApp.GasPedal.value;
         _loc1_ = 1;
         _loc2_ = 100;
         _loc3_ = _loc1_ + (_loc2_ - _loc1_) / 2;
         while(_loc3_ != _loc1_ && _loc3_ != _loc2_ && this.iter < _loc5_)
         {
            if(this.iteration(this.cutDepth,this.cutWidth,-1,-1,true,true,-1,_loc3_) <= 0)
            {
               _loc1_ = _loc3_;
            }
            else
            {
               _loc2_ = _loc3_;
            }
            _loc3_ = int(_loc1_ + (_loc2_ - _loc1_) / 2);
         }
         return this.iter < _loc5_;
      }
      
      private function iteration(param1:Number, param2:Number, param3:Number = -1, param4:Number = -1, param5:Boolean = true, param6:Boolean = true, param7:Number = -1, param8:Number = -1) : Number
      {
         this.cutDepth = param1;
         this.cutWidth = param2;
         if(param5)
         {
            GWizSettings.FeedsSpeedsApp.cutWidth.setVal(this.cutWidth);
         }
         if(param6)
         {
            GWizSettings.FeedsSpeedsApp.cutDepth.setVal(this.cutDepth);
         }
         if(param3 != -1)
         {
            this.ipm = param3;
            GWizSettings.FeedsSpeedsApp.IPM.setValOverride(this.ipm);
         }
         else if(param4 >= 0)
         {
            this.rpm = param4;
            GWizSettings.FeedsSpeedsApp.RPM.setVal(this.rpm);
         }
         else if(param7 >= 0)
         {
            this.stickout = param7;
            GWizSettings.FeedsSpeedsApp.td._stickout.setVal(param7);
         }
         else if(param8 >= 0)
         {
            this.slider = param8;
            GWizSettings.FeedsSpeedsApp.GasPedal.value = param8;
         }
         this.feedsSpeedsRecalc();
         this.recalc(false);
         ++this.iter;
         var _loc9_:Number = this.deflection - (GWizDeflectMath.defaultDefAllowance(this.tDia,GWizSettings.FeedsSpeedsApp.GasPedal.value >= GWizTortHare.GAS_PEDAL_FINISH) - Math.min(this.SAFETY_MARGIN,this.tDia * this.SAFETY_MARGIN_K));
         if(Math.abs(this.rpm) < 0.1)
         {
            _loc9_ = this.deflection;
         }
         return _loc9_;
      }
      
      private function cFactor(param1:int) : Number
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = 1.5;
         switch(param1)
         {
            case 0:
            case 1:
            case 2:
               _loc3_ = 7.93;
               break;
            case 3:
               _loc3_ = 8.3;
               break;
            default:
               _loc3_ = 9.05;
         }
         return _loc3_ * _loc2_;
      }
      
      private function nFactor(param1:int) : Number
      {
         var _loc2_:Number = NaN;
         switch(param1)
         {
            case 1:
            case 2:
               _loc2_ = 0.974;
               break;
            case 3:
               _loc2_ = 0.965;
               break;
            default:
               _loc2_ = 0.95;
         }
         return _loc2_;
      }
      
      public function toolDeflection(param1:Number, param2:Number, param3:Number, param4:Number, param5:Boolean, param6:int, param7:Number = 0.0, param8:Number = 0.001) : Number
      {
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Boolean = false;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         GWizUtils.LogErrorContext = "GWizDeflectMath.toolDeflection";
         var _loc9_:Number = 0;
         if(GWizSettings.FeedsSpeedsApp == null)
         {
            return _loc9_;
         }
         var _loc10_:Number = GWizSettings.FeedsSpeedsApp.HP.getVal();
         var _loc11_:Number = torque(_loc10_,param3);
         var _loc12_:Number = GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam;
         var _loc13_:Number = GWizSettings.FeedsSpeedsApp.td.toolParms.shankSize;
         _loc12_ = Math.min(_loc12_,_loc13_);
         var _loc14_:Number = _loc11_ / (GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam / 2);
         if(_loc12_ < 0.125)
         {
            _loc14_ *= 2;
         }
         var _loc15_:Number = 1;
         if(GWizSettings.FeedsSpeedsApp.getToolType().toLowerCase().indexOf("carbide") >= 0)
         {
            _loc15_ = 90000000;
         }
         else
         {
            _loc15_ = 30000000;
            if(GWizSettings.FeedsSpeedsApp.td.toolParms.isPCD())
            {
               if(GWizUtils.debug)
               {
                  GWizUtils.assert(false);
               }
               _loc15_ = 90000000;
            }
         }
         if(param5)
         {
            _loc16_ = Math.pow(GWizSettings.FeedsSpeedsApp.td.toolParms.shankSize,4) / 12;
            _loc9_ = _loc14_ * Math.pow(param4,3) / (3 * _loc15_ * _loc16_);
         }
         else
         {
            _loc17_ = this.cFactor(param6) * _loc14_ / _loc15_;
            _loc18_ = param4 - param1;
            _loc19_ = Math.pow(_loc18_,3) / Math.pow(_loc12_,4);
            _loc20_ = (Math.pow(param4,3) - Math.pow(_loc18_,3)) / Math.pow(_loc12_,4);
            _loc16_ = Math.pow(_loc19_ + _loc20_,this.nFactor(param6));
            _loc9_ = _loc17_ * _loc16_;
            if(_loc21_ = false)
            {
               log.debug("firstTerm = " + _loc19_ + ", secondTerm = " + _loc20_ + ", sum = " + (_loc19_ + _loc20_) + ", nFactor = " + this.nFactor(param6));
               log.debug("Classic Deflection: " + _loc9_);
            }
            _loc22_ = GWizSettings.FeedsSpeedsApp.td.toolParms.cutLength;
            _loc19_ = Math.pow(_loc18_ = Number(Math.min(_loc22_,param4)),3) / Math.pow(_loc12_,4);
            _loc18_ = param4 - _loc18_;
            _loc18_ = Math.max(_loc18_,0);
            _loc20_ = Math.pow(_loc18_,3) / Math.pow(_loc13_,4);
            _loc16_ = Math.pow(_loc19_ + _loc20_,this.nFactor(param6));
            _loc23_ = _loc17_ * _loc16_;
            if(_loc21_)
            {
               log.debug("firstTerm = " + _loc19_ + ", secondTerm = " + _loc20_ + ", sum = " + (_loc19_ + _loc20_) + ", nFactor = " + this.nFactor(param6));
               log.debug("Updated Deflection: " + _loc23_ + ", old and new differ by " + Math.abs(_loc23_ - _loc9_) / _loc9_ * 100 + "%");
            }
            _loc9_ = _loc23_;
            _loc24_ = this.cFactor(0) * _loc14_ / _loc15_;
            _loc19_ = _loc17_ * Math.pow(_loc19_,this.nFactor(param6));
            _loc20_ = _loc24_ * Math.pow(_loc20_,this.nFactor(0));
            _loc9_ = _loc23_ = _loc19_ + _loc20_;
            if(!GWizUtils.debug && param7 > 0)
            {
               _loc9_ *= this.helixAdjust(param7);
            }
            if(_loc21_)
            {
               log.debug("firstTerm = " + _loc19_ + ", secondTerm = " + _loc20_ + ", sum = " + (_loc19_ + _loc20_) + ", nFactor = " + this.nFactor(param6) + "cFOverE = " + _loc17_ + ", cFoverENoFlutes = " + _loc24_);
               log.debug("Updated Deflection: " + _loc23_ + ", old and new differ by " + Math.abs(_loc23_ - _loc9_) / _loc9_ * 100 + "%\n\n");
            }
            if(false && param2 <= 0.0001)
            {
               _loc9_ = param8 + 1;
            }
         }
         return _loc9_;
      }
      
      private function helixAdjust(param1:Number) : Number
      {
         var _loc2_:Number = -2.88;
         var _loc3_:Number = 215.2;
         var _loc4_:Number;
         return Number((_loc4_ = _loc2_ * param1 + _loc3_) / 100);
      }
      
      public function feedsSpeedsRecalc() : void
      {
         GWizSettings.FeedsSpeedsApp.recalc();
         GWizSettings.FeedsSpeedsApp.validateProperties();
         this.grabValues();
      }
      
      private function safeDeflection() : Boolean
      {
         return this.deflection < GWizDeflectMath.defaultDefAllowance(this.tDia,GWizSettings.FeedsSpeedsApp.GasPedal.value >= GWizTortHare.GAS_PEDAL_FINISH) - Math.min(this.SAFETY_MARGIN,this.tDia * this.SAFETY_MARGIN_K);
      }
   }
}
