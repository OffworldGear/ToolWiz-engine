package threads2
{
   import configinfo.GWizAbstractPrefs;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizUNISOThreadEngine extends GWizAbstractThreadEngine
   {
      
      private static const log:ILogger = Log.getLogger("GWizUNISOThreadEngine");
      
      private static var UNExtThreadImg:Class = GWizUNISOThreadEngine_UNExtThreadImg;
      
      private static var UNIntThreadImg:Class = GWizUNISOThreadEngine_UNIntThreadImg;
      
      public static var extClasses:ArrayCollection = new ArrayCollection([{
         "Class":"1A",
         "UN":"1A",
         "ISO":"8g"
      },{
         "Class":"2A",
         "UN":"2A",
         "ISO":"6g"
      },{
         "Class":"3A",
         "UN":"3A",
         "ISO":"4g"
      }]);
      
      public static var intClasses:ArrayCollection = new ArrayCollection([{
         "Class":"1B",
         "UN":"1B",
         "ISO":"7h"
      },{
         "Class":"2B",
         "UN":"2B",
         "ISO":"6h"
      },{
         "Class":"3B",
         "UN":"3B",
         "ISO":"5h"
      }]);
       
      
      public function GWizUNISOThreadEngine()
      {
         this.initPreferredThreads();
         PremiumThreadFamily["UNC STI (Helicoil)"] = true;
         PremiumThreadFamily["UNF STI (Helicoil)"] = true;
         PremiumThreadFamily["ISO Coarse STI (Helicoil)"] = true;
         PremiumThreadFamily["ISO Fine STI (Helicoil)"] = true;
         PremiumThreadFamily["Pg Conduit Thread"] = true;
         PremiumThreadFamily["UNEF"] = true;
         PremiumThreadFamily["UNJC"] = true;
         PremiumThreadFamily["UNJF"] = true;
         PremiumThreadFamily["UNJEF"] = true;
         PremiumThreadFamily["UNM"] = true;
         PremiumThreadFamily["ISO MJ"] = true;
         PremiumThreadFamily["NPSM"] = true;
         PremiumThreadFamily["NPSL"] = true;
         super();
      }
      
      private static function basicMOW(param1:Number, param2:Number, param3:Number) : Number
      {
         return param1 - 0.866025 * param2 + 3 * param3;
      }
      
      public function initPreferredThreads() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(!PreferredThreads)
         {
            PreferredThreads = GWizUNISOThreadData.UNISOStdSizes;
         }
         else
         {
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,GWizUNISOThreadData.UNISOStdSizes);
         }
         if(GWizAbstractPrefs.ThreadCalcEnabled)
         {
            _loc1_ = 0;
            while(_loc1_ < GWizUNISOThreadData.ISOMJSizes.length)
            {
               _loc2_ = GWizUNISOThreadData.ISOMJSizes.getItemAt(_loc1_);
               _loc2_.Size = "M" + _loc2_.Size + "-" + GWizUtils.roundHundredths(1 / _loc2_.TPI * 25.4);
               _loc1_++;
            }
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,GWizUNISOThreadData.UNMSizes);
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,GWizUNISOThreadData.UNISOSTISizes);
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,GWizUNISOThreadData.PgSizes);
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,GWizUNISOThreadData.UNJSizes);
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,GWizUNISOThreadData.ISOMJSizes);
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,GWizUNISOThreadData.NPSMSizes);
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,GWizUNISOThreadData.NPSLSizes);
            if(!GWizUtils.debug)
            {
            }
         }
      }
      
      override public function selectThread(param1:String, param2:String, param3:Number, param4:Number, param5:String, param6:int, param7:Boolean) : Boolean
      {
         var _loc8_:Boolean = false;
         var _loc9_:Number = NaN;
         var _loc11_:Object = null;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         _loc8_ = super.selectThread(param1,param2,param3,param4,param5,param6,param7);
         ExtThreadImg = UNExtThreadImg;
         IntThreadImg = UNIntThreadImg;
         Reference = "ASME B1.1-2003";
         if(this.isISO())
         {
            Reference = "ASME B1.13M-2005";
            if(this.isISOMJ())
            {
               Reference = "B1.21M-1997";
            }
         }
         else if(this.isUNM())
         {
            Reference = "ASME B1.10";
         }
         else if(this.isSTI())
         {
            Reference = "ASME B18.29.1-2010";
         }
         else if(this.isPg())
         {
            Reference = "DIN 40430";
         }
         else if(this.isUNJ())
         {
            Reference = "SAE AS8879-D";
         }
         else if(this.isNPSM() || this.isNPSL())
         {
            Reference = "ASME B1.20.1-2013";
         }
         TPISelect = true;
         if(this.isISO())
         {
            TPISelect = false;
            Pitch = param4;
            TPI = 1 / Pitch;
         }
         allowCustomSizeTPI = !this.isTableThread();
         TolClass = param5;
         showTolClass = true;
         if(this.isUNM() || this.isPg() || this.isNPSM() || this.isNPSL())
         {
            showTolClass = false;
         }
         Designation = this.getDesignation();
         if(this.isSTI())
         {
            hasExternalThreads = false;
         }
         ThreadAngle = 60;
         if(this.isPg())
         {
            ThreadAngle = 80;
         }
         if(this.isUNS() || this.isUNJ9Pitch() || this.isISOMJ() || this.isUNEF() || this.isUN1216202832())
         {
            EngagementLength = 9 * Pitch;
         }
         FltsHeight = Height * 0.625;
         Flat = Pitch / 4;
         Flat2 = Pitch / 8;
         SharpDepthExt = Pitch * 0.86603;
         ThreadDepthExt = Pitch * 0.54127;
         _loc9_ = 0.64951905 * Pitch;
         var _loc10_:Number = NomSize - _loc9_;
         if(this.isISO())
         {
            _loc10_ = NomSize - 2 * 3 / 8 * SharpDepthExt;
         }
         if(!this.isPg())
         {
            if(param7)
            {
               this.recalcExternalAllowTol(NomSize,Pitch,EngagementLength,TolClass);
               MaxMajorDia = NomSize - Allowance;
               MinMajorDia = MaxMajorDia - MajorDiaTol;
               MaxPitchDia = MaxMajorDia - _loc9_;
               MinPitchDia = MaxPitchDia - PitchDiaTol;
               MaxMinorDia = NomSize - 1.08253175 * Pitch;
               MaxMinorDia -= Allowance;
               MinMinorDia = MinPitchDia - 0.64951905 * Pitch;
               this.recalcMOW();
               if(this.isISO())
               {
                  MinMinorDia = MinPitchDia * 25.4 - 0.6160254 * (Pitch * 25.4);
                  MinMinorDia /= 25.4;
                  MinRootRadius = 0.125 * Pitch;
               }
               if(this.isUNJ() || this.isISOMJ())
               {
                  MinMinorDia = MinPitchDia - 0.5658 * Pitch;
                  MaxMinorDia = MaxPitchDia - 0.50518 * Pitch;
                  MaxPitchDia = NomSize - 0.64951 * Pitch;
                  MinPitchDia = MaxPitchDia - PitchDiaTol;
                  MinRootRadius = 0.15011 * Pitch;
                  MaxRootRadius = 0.18042 * Pitch;
                  FltsHeight = Height - 0.18042 * Pitch;
                  Flat = NaN;
               }
               if(this.isISOMJ())
               {
                  _loc12_ = 0.18 * GWizUtils.cubeRoot(pitchMM * pitchMM) - 0.00315 * (1 / Math.sqrt(pitchMM));
                  MinMajorDia = MaxMajorDia - _loc12_ / 25.4;
                  FltsHeight = (MaxMajorDia - MaxMinorDia) / 2;
               }
               if(this.isNPSM())
               {
                  _loc13_ = 0;
                  while(_loc13_ < GWizUNISOThreadData.NPSMSizes.length)
                  {
                     if((_loc11_ = GWizUNISOThreadData.NPSMSizes.getItemAt(_loc13_)).Family == param1 && _loc11_.Size == param2)
                     {
                        break;
                     }
                     _loc13_++;
                  }
                  if(_loc11_.Family == param1 && _loc11_.Size == param2)
                  {
                     EngagementLength = NaN;
                     ThreadDepthExt = FltsHeight = 0.64952 * Pitch;
                     SharpDepthExt = Pitch * 0.86603;
                     MaxMajorDia = _loc11_.MaxMajorExt;
                     MinMajorDia = _loc11_.MinMajorExt;
                     MajorDiaTol = MaxMajorDia - MinMajorDia;
                     MinPitchDia = _loc11_.MinPitchExt;
                     MaxPitchDia = _loc11_.MaxPitchExt;
                     PitchDiaTol = MaxPitchDia - MinPitchDia;
                     MinMinorDia = NaN;
                     MaxMinorDia = NaN;
                     MinorDiaTol = NaN;
                     NomSize = _loc11_.PipeDia;
                     Allowance = _loc11_.Allowance;
                  }
               }
               if(this.isNPSL())
               {
                  _loc13_ = 0;
                  while(_loc13_ < GWizUNISOThreadData.NPSLSizes.length)
                  {
                     if((_loc11_ = GWizUNISOThreadData.NPSLSizes.getItemAt(_loc13_)).Family == param1 && _loc11_.Size == param2)
                     {
                        break;
                     }
                     _loc13_++;
                  }
                  if(_loc11_.Family == param1 && _loc11_.Size == param2)
                  {
                     EngagementLength = NaN;
                     ThreadDepthExt = FltsHeight = 0.64952 * Pitch;
                     SharpDepthExt = Pitch * 0.86603;
                     MaxMajorDia = _loc11_.MaxMajExt;
                     MinMajorDia = NaN;
                     MajorDiaTol = NaN;
                     MinPitchDia = _loc11_.MinPitchDiaExt;
                     MaxPitchDia = _loc11_.MaxPitchDiaExt;
                     PitchDiaTol = MaxPitchDia - MinPitchDia;
                     MinMinorDia = NaN;
                     MaxMinorDia = NaN;
                     MinorDiaTol = NaN;
                     NomSize = _loc11_.PipeDia;
                     Allowance = NaN;
                  }
               }
            }
            else
            {
               this.recalcInternalAllowTol(NomSize,Pitch,EngagementLength,TolClass,TPI);
               log.debug("Allowance = " + Allowance);
               _loc14_ = 1.08253175 * Pitch;
               MaxMajorDia = NaN;
               MinMajorDia = NomSize;
               MinPitchDia = _loc10_;
               MaxPitchDia = MinPitchDia + PitchDiaTol;
               MinMinorDia = NomSize - _loc14_;
               MaxMinorDia = MinMinorDia + MinorDiaTol;
               BestSizeMOW = 0;
               MinSizeMOW = 0;
               MaxSizeMOW = 0;
               if(this.isISO())
               {
                  MaxMajorDia = MaxPitchDia + 0.7938566 * Pitch;
                  MajorDiaTol = MaxMajorDia - MinMajorDia;
               }
               if(this.isUNJ())
               {
                  MinMinorDia = NomSize - 0.97428 * Pitch;
                  _loc15_ = (_loc15_ = 0.05 * GWizUtils.cubeRoot(Pitch * Pitch) + 0.03 * (Pitch / NomSize)) - 0.002;
                  if(TPI <= 12)
                  {
                     _loc15_ = 0.12 * Pitch;
                  }
                  else
                  {
                     _loc15_ = Math.min(_loc15_,0.259809 * Pitch);
                     _loc15_ = Math.max(_loc15_,0.135315 * Pitch);
                  }
                  MaxMinorDia = MinMinorDia + _loc15_;
                  Flat = Pitch * 5 / 16;
               }
               else if(this.isISOMJ())
               {
                  MinPitchDia = NomSize - 0.6495191 * Pitch;
                  MinMinorDia = NomSize - 0.9742786 * Pitch;
                  _loc16_ = 0.433 * pitchMM - 0.19 * Math.pow(pitchMM,1.22);
                  if(pitchMM > 0.8)
                  {
                     _loc16_ = 0.23 * Math.pow(pitchMM,0.7);
                  }
                  MaxMinorDia = MinMinorDia + _loc16_ / 25.4;
                  if(TolClass == "45H" || TolClass == "45G" || TolClass == "46G")
                  {
                     _loc17_ = 0.8 * (0.433 * pitchMM - 0.19 * Math.pow(pitchMM,1.22));
                     if(pitchMM > 0.8)
                     {
                        _loc17_ = 0.8 * (0.23 * Math.pow(pitchMM,0.7));
                     }
                     MaxMinorDia = MinMinorDia + _loc17_ / 25.4;
                  }
                  else if(TolClass.substr(2,1) == "H")
                  {
                     _loc16_ = 0.433 * Math.pow(pitchMM,1.22);
                     if(pitchMM > 0.7)
                     {
                        _loc16_ = 0.23 * Math.pow(pitchMM,0.7);
                     }
                     MaxMinorDia = MinMinorDia + _loc16_ / 25.4;
                  }
                  FltsHeight = (MinMajorDia - MinMinorDia) / 2;
               }
               else if(this.isSTI())
               {
                  _loc11_ = lookupFamilySize(param1,param2);
                  MinCountersinkDia = _loc11_.MinCountersinkDia;
                  MaxCountersinkDia = _loc11_.MaxCountersinkDia;
                  MinPitchDia = _loc11_.MinPitchDia;
                  if(TolClass == "3B")
                  {
                     MaxPitchDia = _loc11_.MaxPitchDia3B;
                  }
                  else
                  {
                     MaxPitchDia = _loc11_.MaxPitchDia2B;
                  }
                  MinMajorDia = NaN;
                  MaxMajorDia = _loc11_.MaxTapMajorDia;
                  MinMinorDia = _loc11_.MinMinorDia;
                  MaxMinorDia = _loc11_.MaxMinorDia;
                  Allowance = NaN;
                  MajorDiaTol = NaN;
                  PitchDiaTol = MaxPitchDia - MinPitchDia;
                  MinorDiaTol = MaxMinorDia - MinMinorDia;
               }
               else if(this.isNPSM())
               {
                  _loc13_ = 0;
                  while(_loc13_ < GWizUNISOThreadData.NPSMSizes.length)
                  {
                     if((_loc11_ = GWizUNISOThreadData.NPSMSizes.getItemAt(_loc13_)).Family == param1 && _loc11_.Size == param2)
                     {
                        break;
                     }
                     _loc13_++;
                  }
                  if(_loc11_.Family == param1 && _loc11_.Size == param2)
                  {
                     EngagementLength = NaN;
                     ThreadDepthExt = FltsHeight = 0.54126 * Pitch;
                     SharpDepthExt = Pitch * 0.86603;
                     MaxMajorDia = NaN;
                     MinMajorDia = NaN;
                     MajorDiaTol = NaN;
                     MinPitchDia = _loc11_.MinPitchInt;
                     MaxPitchDia = _loc11_.MaxPitchInt;
                     PitchDiaTol = MaxPitchDia - MinPitchDia;
                     MinMinorDia = _loc11_.MinMinorInt;
                     MaxMinorDia = _loc11_.MaxMinorInt;
                     MinorDiaTol = MaxMinorDia - MinMinorDia;
                     NomSize = _loc11_.PipeDia;
                     Allowance = _loc11_.Allowance;
                  }
               }
               else if(this.isNPSL())
               {
                  _loc13_ = 0;
                  while(_loc13_ < GWizUNISOThreadData.NPSLSizes.length)
                  {
                     if((_loc11_ = GWizUNISOThreadData.NPSLSizes.getItemAt(_loc13_)).Family == param1 && _loc11_.Size == param2)
                     {
                        break;
                     }
                     _loc13_++;
                  }
                  if(_loc11_.Family == param1 && _loc11_.Size == param2)
                  {
                     EngagementLength = NaN;
                     ThreadDepthExt = FltsHeight = NaN;
                     SharpDepthExt = NaN;
                     MaxMajorDia = NaN;
                     MinMajorDia = NaN;
                     MajorDiaTol = NaN;
                     MinPitchDia = _loc11_.MinPitchDiaInt;
                     MaxPitchDia = _loc11_.MaxPitchDiaInt;
                     PitchDiaTol = MaxPitchDia - MinPitchDia;
                     MinMinorDia = _loc11_.MinMinorDiaInt;
                     MaxMinorDia = NaN;
                     MinorDiaTol = NaN;
                     NomSize = _loc11_.PipeDia;
                     Allowance = NaN;
                  }
               }
               else
               {
                  MinCountersinkDia = NaN;
                  MaxCountersinkDia = NaN;
               }
            }
         }
         else
         {
            _loc11_ = lookupFamilySize(param1,param2);
            Allowance = NaN;
            MajorDiaTol = NaN;
            PitchDiaTol = NaN;
            MinorDiaTol = NaN;
            MinCountersinkDia = NaN;
            MaxCountersinkDia = NaN;
            EngagementLength = NaN;
            Flat = NaN;
            if(param7)
            {
               MinMajorDia = _loc11_.ExtMinMajDia;
               MaxMajorDia = _loc11_.ExtMaxMajDia;
               MinMinorDia = _loc11_.ExtMinMinorDia;
               MaxMinorDia = _loc11_.ExtMaxMinorDia;
               MinPitchDia = _loc11_.ExtMinPitchDia;
               MaxPitchDia = _loc11_.ExtMaxPitchDia;
               MaxRootRadius = 0.107 * pitchMM / 25.4;
               this.recalcMOW();
            }
            else
            {
               MinMajorDia = _loc11_.IntMinMajDia;
               MaxMajorDia = _loc11_.IntMaxMajDia;
               MinMinorDia = _loc11_.IntMinMinorDia;
               MaxMinorDia = _loc11_.IntMaxMinorDia;
               MinPitchDia = _loc11_.IntMinPitchDia;
               MaxPitchDia = _loc11_.IntMaxPitchDia;
            }
            FltsHeight = 0.8 * Height;
         }
         return _loc8_;
      }
      
      override public function addlThreadData() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         if(this.isSTI())
         {
            newThreadData("Min Countersink Dia",MinCountersinkDia,true,true);
            newThreadData("Max Countersink Dia",MaxCountersinkDia,true,true);
         }
         else if(this.isNPSM())
         {
            _loc2_ = 0;
            while(_loc2_ < GWizUNISOThreadData.NPSMSizes.length)
            {
               _loc1_ = GWizUNISOThreadData.NPSMSizes.getItemAt(_loc2_);
               if(_loc1_.Family == Family && _loc1_.Size == Size)
               {
                  newThreadData("Pipe Dia.",_loc1_.PipeDia,true,true);
                  break;
               }
               _loc2_++;
            }
         }
         else if(this.isNPSL())
         {
            _loc2_ = 0;
            while(_loc2_ < GWizUNISOThreadData.NPSLSizes.length)
            {
               _loc1_ = GWizUNISOThreadData.NPSLSizes.getItemAt(_loc2_);
               if(_loc1_.Family == Family && _loc1_.Size == Size)
               {
                  newThreadData("Pipe Dia.",_loc1_.PipeDia,true,true);
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      private function recalcMOW() : void
      {
         BestSizeMOW = GWizUtils.secant(GWizUtils.radians(ThreadAngle)) / (2 * TPI);
         var _loc1_:Number = Pitch / (2 * Math.cos(GWizUtils.radians(ThreadAngle) / 2));
         MaxSizeMOW = 1.01036 * Pitch;
         MinSizeMOW = 0.50518 * Pitch;
         if(!(MinSizeMOW <= BestSizeMOW && BestSizeMOW <= MaxSizeMOW))
         {
            BestSizeMOW = _loc1_;
         }
      }
      
      private function isISO() : Boolean
      {
         return Family && Family.indexOf("ISO") >= 0;
      }
      
      private function isISOMJ() : Boolean
      {
         return Family && Family.indexOf("ISO MJ") >= 0;
      }
      
      private function isUNJ() : Boolean
      {
         return Family && Family.indexOf("UNJ") >= 0;
      }
      
      private function isUNJ9Pitch() : Boolean
      {
         var _loc1_:Boolean = false;
         if(Family)
         {
            _loc1_ = Family.indexOf("UNJEF") >= 0 || Family.indexOf("12UNJ") >= 0 || Family.indexOf("16UNJ") >= 0;
         }
         return _loc1_;
      }
      
      private function isUNM() : Boolean
      {
         return Family && Family.indexOf("UNM") >= 0;
      }
      
      private function isUNS() : Boolean
      {
         return Family && Family.indexOf("UNS") >= 0;
      }
      
      private function isUNEF() : Boolean
      {
         return Family && Family.indexOf("UNEF") >= 0;
      }
      
      private function isUN1216202832() : Boolean
      {
         var _loc1_:Boolean = TPI == 12 || TPI == 16 || TPI == 20 || TPI == 28 || TPI == 32;
         return Family && Family == "UN" && _loc1_;
      }
      
      private function isSTI() : Boolean
      {
         return Family && Family.indexOf("STI") >= 0;
      }
      
      private function isPg() : Boolean
      {
         return Family && Family.indexOf("Pg") >= 0;
      }
      
      private function isNPSM() : Boolean
      {
         return Family && Family.indexOf("NPSM") >= 0;
      }
      
      private function isNPSL() : Boolean
      {
         return Family && Family.indexOf("NPSL") >= 0;
      }
      
      private function isTableThread() : Boolean
      {
         return this.isPg() || this.isSTI() || this.isNPSM() || this.isNPSL();
      }
      
      override public function lookupTPI(param1:String, param2:String) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Object = lookupFamilySize(param1,param2);
         _loc3_ = Number(_loc4_.TPI);
         if(this.isISO())
         {
            _loc3_ = 1 / _loc3_;
         }
         GWizUtils.assert(!isNaN(_loc3_));
         return _loc3_;
      }
      
      override public function initClassList(param1:Boolean = true) : void
      {
         var _loc3_:Object = null;
         DefaultClassChoice = 1;
         if(param1)
         {
            ClassList = extClasses;
         }
         else
         {
            ClassList = intClasses;
         }
         var _loc2_:int = 0;
         while(_loc2_ < ClassList.length)
         {
            _loc3_ = ClassList.getItemAt(_loc2_);
            if(!Family || !this.isISO())
            {
               _loc3_.Class = _loc3_.UN;
            }
            else
            {
               _loc3_.Class = _loc3_.ISO;
            }
            _loc2_++;
         }
         ClassList.refresh();
      }
      
      override public function RecalcMOWLimits(param1:Number) : void
      {
         MinMeasureMOW = basicMOW(MinPitchDia,Pitch,param1);
         MaxMeasureMOW = basicMOW(MaxPitchDia,Pitch,param1);
      }
      
      override public function RecalcMOWPitchDia(param1:Number, param2:Number) : Number
      {
         return param2 + 0.866025 * Pitch - 3 * param1;
      }
      
      private function getISOTD2() : Number
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NomSize * 25.4;
         if(_loc3_ < 2.8)
         {
            _loc1_ = 1.5;
            _loc2_ = 2.8;
         }
         else if(_loc3_ < 5.6)
         {
            _loc1_ = 2.8;
            _loc2_ = 5.6;
         }
         else if(_loc3_ < 11.2)
         {
            _loc1_ = 5.6;
            _loc2_ = 11.2;
         }
         else if(_loc3_ < 22.4)
         {
            _loc1_ = 11.2;
            _loc2_ = 22.4;
         }
         else if(_loc3_ < 45)
         {
            _loc1_ = 22.4;
            _loc2_ = 45;
         }
         else if(_loc3_ < 90)
         {
            _loc1_ = 45;
            _loc2_ = 90;
         }
         else if(_loc3_ < 180)
         {
            _loc1_ = 90;
            _loc2_ = 180;
         }
         else
         {
            _loc1_ = 180;
            _loc2_ = 355;
         }
         var _loc4_:Number = Math.sqrt(_loc1_ * _loc2_);
         return 0.09 * Math.pow(pitchMM,0.4) * Math.pow(_loc4_,0.1);
      }
      
      private function recalcExternalAllowTol(param1:Number, param2:Number, param3:Number, param4:String) : void
      {
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         if(isNaN(param3) || param3 < 0)
         {
            param3 = param1;
         }
         var _loc5_:Number = 0.0015 * GWizUtils.cubeRoot(param1) + 0.0015 * Math.sqrt(param3) + 0.015 * GWizUtils.cubeRoot(param2 * param2);
         var _loc6_:Number = 1.5 * _loc5_;
         var _loc7_:Number = 0.75 * _loc5_;
         var _loc8_:Number = 0.09 * GWizUtils.cubeRoot(param2 * param2);
         var _loc9_:Number;
         var _loc10_:Number = _loc9_ = 0.06 * GWizUtils.cubeRoot(param2 * param2);
         var _loc11_:Number;
         var _loc12_:Number = _loc11_ = 0.3 * _loc5_;
         var _loc13_:Number = 0;
         MinorDiaTol = NaN;
         switch(param4)
         {
            case "1A":
               Allowance = _loc11_;
               MajorDiaTol = _loc8_;
               PitchDiaTol = _loc6_;
               break;
            case "2A":
               Allowance = _loc12_;
               MajorDiaTol = _loc9_;
               PitchDiaTol = _loc5_;
               break;
            case "3A":
            default:
               Allowance = _loc13_;
               MajorDiaTol = _loc10_;
               PitchDiaTol = _loc7_;
         }
         if(this.isISO())
         {
            _loc14_ = 0.18 * GWizUtils.cubeRoot(pitchMM * pitchMM) - 0.00315 / Math.sqrt(pitchMM);
            _loc15_ = this.getISOTD2();
            if((_loc19_ = NomSize * 25.4) < 2.8)
            {
               _loc17_ = 2.8;
               _loc18_ = 5.6;
            }
            else if(_loc19_ < 5.6)
            {
               _loc17_ = 5.6;
               _loc18_ = 11.2;
            }
            else if(_loc19_ < 11.2)
            {
               _loc17_ = 11.2;
               _loc18_ = 22.4;
            }
            else if(_loc19_ < 22.4)
            {
               _loc17_ = 22.4;
               _loc18_ = 45;
            }
            else if(_loc19_ < 45)
            {
               _loc17_ = 45;
               _loc18_ = 90;
            }
            else if(_loc19_ < 90)
            {
               _loc17_ = 90;
               _loc18_ = 180;
            }
            else if(_loc19_ < 180)
            {
               _loc17_ = 180;
               _loc18_ = 355;
            }
            switch(param4.substr(0,1))
            {
               case "9":
                  PitchDiaTol = 2 * _loc15_;
                  break;
               case "8":
                  PitchDiaTol = 1.6 * _loc15_;
                  break;
               case "7":
                  PitchDiaTol = 1.25 * _loc15_;
                  break;
               case "6":
                  PitchDiaTol = _loc15_;
                  break;
               case "5":
                  PitchDiaTol = 0.8 * _loc15_;
                  break;
               case "4":
                  PitchDiaTol = 0.63 * _loc15_;
                  break;
               default:
                  PitchDiaTol = 0.5 * _loc15_;
            }
            switch(param4.substr(2,1))
            {
               case "8":
                  _loc14_ = 1.6 * _loc14_;
                  break;
               case "6":
                  break;
               case "4":
               default:
                  _loc14_ = 0.63 * _loc14_;
            }
            _loc20_ = this.getISOTD1(pitchMM,param4);
            MajorDiaTol = GWizReynardR40.roundR40(_loc14_) / 25.4;
            PitchDiaTol = GWizReynardR40.roundR40(PitchDiaTol) / 25.4;
            MinorDiaTol = GWizReynardR40.roundR40(_loc20_) / 25.4;
         }
      }
      
      private function getISOTD1(param1:Number, param2:String) : Number
      {
         var _loc3_:Number = 0.433 * param1 - 0.19 * Math.pow(param1,1.22);
         if(param1 >= 1)
         {
            _loc3_ = 0.23 * Math.pow(param1,0.7);
         }
         switch(param2.charAt(0))
         {
            case "5":
               _loc3_ *= 0.63;
               break;
            case "6":
               break;
            case "7":
               _loc3_ *= 1.25;
               break;
            case "8":
               _loc3_ *= 1.6;
               break;
            case "4":
            default:
               _loc3_ *= 0.63;
         }
         return _loc3_;
      }
      
      private function recalcInternalAllowTol(param1:Number, param2:Number, param3:Number, param4:String, param5:Number) : void
      {
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         GWizUtils.assert(param4.indexOf("A") < 0);
         var _loc6_:Number = 0.0015 * GWizUtils.cubeRoot(param1);
         var _loc7_:Number = 0.0015 * Math.sqrt(param3);
         var _loc8_:Number = 0.015 * GWizUtils.cubeRoot(param2 * param2);
         var _loc9_:Number = 0.0015 * GWizUtils.cubeRoot(param1) + 0.0015 * Math.sqrt(param3) + 0.015 * GWizUtils.cubeRoot(param2 * param2);
         var _loc10_:Number = 1.95 * _loc9_;
         var _loc11_:Number = 1.3 * _loc9_;
         var _loc12_:Number = 0.975 * _loc9_;
         switch(param4)
         {
            case "1B":
            case "7h":
               PitchDiaTol = _loc10_;
               break;
            case "2B":
            case "6h":
               PitchDiaTol = _loc11_;
               break;
            case "3B":
            case "5h":
            default:
               PitchDiaTol = _loc12_;
         }
         var _loc14_:Number;
         var _loc15_:Number = _loc14_ = Number(0.14433757 * param2 + PitchDiaTol);
         switch(param4)
         {
            case "1B":
            case "7h":
               MajorDiaTol = _loc13_;
               break;
            case "2B":
            case "6h":
               MajorDiaTol = _loc14_;
               break;
            case "3B":
            case "5h":
            default:
               MajorDiaTol = _loc15_;
         }
         Allowance = 0;
         MinorDiaTol = NaN;
         if(param4 == "3B" || param4 == "5h")
         {
            MinorDiaTol = 0.05 * GWizUtils.cubeRoot(param2 * param2) + 0.03 * (param2 / param1) - 0.002;
            MinorDiaTol = Math.min(MinorDiaTol,0.384 * param2);
            if(param5 <= 12)
            {
               MinorDiaTol = Math.max(0.12 * param2);
            }
            else if(12 < param5 && param5 <= 80)
            {
               MinorDiaTol = Math.max(0.23 * param2 - 1.5 * param2 * param2);
            }
         }
         else if(param1 < 0.25)
         {
            MinorDiaTol = 0.05 * GWizUtils.cubeRoot(param2 * param2) + 0.03 * (param2 / param1) - 0.002;
            MinorDiaTol = Math.min(MinorDiaTol,0.394 * param2);
            MinorDiaTol = Math.max(MinorDiaTol,0.25 * param2 - 0.4 * param2 * param2);
         }
         else if(param5 < 4)
         {
            MinorDiaTol = 0.15 * param2;
         }
         else if(4 <= param5 && param5 <= 80)
         {
            MinorDiaTol = 0.25 * param2 - 0.4 * param2 * param2;
         }
         if(this.isISO())
         {
            _loc16_ = this.getISOTD1(pitchMM,param4);
            MinorDiaTol = GWizReynardR40.roundR40(_loc16_) / 25.4;
            _loc17_ = this.getISOTD2();
            switch(param4.charAt(0))
            {
               case "5":
                  _loc17_ *= 1.06;
                  break;
               case "6":
                  _loc17_ *= 1.32;
                  break;
               case "7":
                  _loc17_ *= 1.7;
                  break;
               case "8":
                  _loc17_ *= 2.12;
                  break;
               case "4":
               default:
                  _loc17_ *= 0.85;
            }
            PitchDiaTol = GWizReynardR40.roundR40(_loc17_) / 25.4;
         }
      }
      
      private function pitchDiaTolerance(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = 0.0015 * GWizUtils.cubeRoot(param1) + 0.0015 * Math.sqrt(param2) + 0.015 * GWizUtils.cubeRoot(param3 * param3);
         var _loc5_:Number = 1.5 * _loc4_;
         var _loc6_:Number = 0.75 * _loc4_;
         var _loc7_:Number;
         var _loc8_:Number = _loc7_ = 0.3 * _loc4_;
         var _loc9_:Number = 0;
         switch(Class)
         {
            case "1A":
            case "1B":
               Allowance = _loc7_;
               PitchDiaTol = _loc5_;
               break;
            case "2A":
            case "2B":
               Allowance = _loc8_;
               PitchDiaTol = _loc4_;
               break;
            case "3A":
            case "3B":
            default:
               Allowance = _loc9_;
               PitchDiaTol = _loc6_;
         }
      }
      
      private function getDesignation() : String
      {
         var _loc1_:String = "";
         if(Size != "")
         {
            _loc1_ += Size;
         }
         else
         {
            _loc1_ += String(NomSize);
            _loc1_ += "-" + TPI;
         }
         if(!this.isISO())
         {
            _loc1_ += " " + Family;
         }
         else if(this.isISOMJ())
         {
            _loc1_ = "MJ" + _loc1_.substr(1);
         }
         if(showTolClass)
         {
            _loc1_ += "-" + TolClass;
         }
         return _loc1_;
      }
   }
}
