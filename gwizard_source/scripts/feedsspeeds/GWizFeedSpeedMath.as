package feedsspeeds
{
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import machines.GWizMachSettings;
   import machines.GWizSpindleCurve;
   import material.GWizMatBrowser2;
   import material.GWizMaterialsDB;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import tools.GWizGarrOEMToolData;
   import tools.GWizToolData;
   import utils.GWizGeomUtils;
   import utils.GWizNumericOverride;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizFeedSpeedMath
   {
      
      private static const log:ILogger = Log.getLogger("GWizFeedSpeedMath");
      
      private static var drillHints:String = "";
      
      private static const EMASTERCAM_SFM_ADJUST:Number = 1.46;
      
      private static const EMASTERCAM_IPT_ADJUST:Number = 1.15;
       
      
      private var oemToolData:GWizGarrOEMToolData;
      
      public var stopRecalc:Boolean = true;
      
      public var materialName:String = "";
      
      public var materialIndex:int = 0;
      
      public var adjHardness:Number = -1;
      
      public var maxBHN:Number = 0;
      
      private var _minBHN:Number = 0;
      
      public var toolParms:GWizToolData;
      
      public var cutDepth:Number = 0;
      
      public var cutWidth:Number = 0;
      
      public var scallopHt:Number = 0;
      
      public var rpmLimit:GWizNumericOverride;
      
      public var rpmMinLimit:GWizNumericOverride;
      
      public var minRPMError:Boolean = false;
      
      public var tooHighDia:Number;
      
      public var feedLimit:GWizNumericOverride;
      
      public var hpLimit:GWizNumericOverride;
      
      public var hpLimitHit:Boolean = false;
      
      public var msfmAdjust:Number = 100;
      
      public var miptAdjust:Number = 100;
      
      public var effDiam:Number = 0;
      
      public var stepOver:Number = 0;
      
      public var finish:Number = 0;
      
      public var axialEngagement:Number = 0;
      
      public var radialEngagement:Number = 0;
      
      public var sfm:GWizNumericOverride;
      
      public var mfgSFM:GWizNumericOverride;
      
      public var sfmRange:Number = 0;
      
      public var rpm:GWizNumericOverride;
      
      public var ipt:GWizNumericOverride;
      
      public var mfgIPT:GWizNumericOverride;
      
      public var ipr:Number = 0;
      
      public var ipm:GWizNumericOverride;
      
      public var rigidity:String = "Normal";
      
      public var plungeRate:Number = 0;
      
      public var hp:Number = 0;
      
      public var mrr:Number = 0;
      
      public var cea:GWizNumericOverride;
      
      public var cornerAdjust:Number = 100;
      
      public var hsmAdjust:Number = 100;
      
      public var hsmFeedsSpeedsAdj:Boolean = false;
      
      public var hsmIPMFactor:Number = 1.0;
      
      public var hsmRPMFactor:Number = 1.0;
      
      public var gasPedal:Number = 100;
      
      public var axialSFMAdjust:Number = 1.0;
      
      public var axialFeedAdjust:Number = 1.0;
      
      public var tsc:Boolean = false;
      
      public var hpc:Boolean = false;
      
      public var pcn:Boolean = false;
      
      public const ENGAGEMENT_THRESHOLD:Number = 0.65;
      
      private const PENALTY_INTERVAL:Number = 0.35;
      
      private const MAX_PENALTY:Number = 0.05;
      
      private const MAX_AXIAL_ENGAGEMENT:Number = 700;
      
      public var engagementThreshold:Number = 0.65;
      
      public var adjustSFMForLength:Boolean = false;
      
      private var lastToolListType:String = "";
      
      private var lastToolListEntry:Object = null;
      
      private var IPTData:Object = null;
      
      private var bestTeeth:Number = 0;
      
      private var familyInPlay:Boolean = false;
      
      private const RIGIDITY_UPGRADE:Number = 1.23;
      
      private var iptCacheToolType:String = "";
      
      private var iptCacheMaterial:String = "";
      
      private var iptCacheDiameter:Number;
      
      private var iptTableCache:Number;
      
      private const USE_IPT_CACHE:Boolean = false;
      
      private const MIN_TABLE_DIAMETER:Number = 0.0625;
      
      private var notEnoughPowerErr:Boolean = false;
      
      private var rctf:Number = 1.0;
      
      private var IGNORE_CHIP_THINNING:Boolean = false;
      
      private var stopGasPedalRecursion:Boolean = false;
      
      public const MICRO_MILL_MAX_DIA:Number = 0.125;
      
      public function GWizFeedSpeedMath()
      {
         this.toolParms = new GWizToolData();
         this.rpmLimit = new GWizNumericOverride();
         this.rpmMinLimit = new GWizNumericOverride();
         this.feedLimit = new GWizNumericOverride();
         this.hpLimit = new GWizNumericOverride();
         this.sfm = new GWizNumericOverride();
         this.mfgSFM = new GWizNumericOverride();
         this.rpm = new GWizNumericOverride();
         this.ipt = new GWizNumericOverride();
         this.mfgIPT = new GWizNumericOverride();
         this.ipm = new GWizNumericOverride();
         this.cea = new GWizNumericOverride();
         super();
         if(GWizAbstractPrefs.isOEM && !this.oemToolData)
         {
            this.oemToolData = new GWizGarrOEMToolData();
         }
         this.ipt.name = "ipt";
         this.rpm.name = "fsm.rpm";
         this.runUnitTests();
      }
      
      public static function peckDepth(param1:Number, param2:Number, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false) : Number
      {
         var _loc6_:Number = param2 / param1;
         var _loc7_:Number = 0;
         if(param3)
         {
            if(_loc6_ > 5)
            {
               _loc7_ = 2 * param1;
               if(_loc6_ > 10)
               {
                  _loc6_ = 1.5 * param1;
               }
            }
         }
         else if(_loc6_ > 3)
         {
            _loc7_ = param1;
            if(_loc6_ > 10)
            {
               _loc7_ = 0.75 * param1;
               if(_loc6_ > 15)
               {
                  _loc7_ = 0.5 * param1;
               }
            }
         }
         if(param5)
         {
            if(_loc6_ > 6)
            {
               _loc7_ = param2 / 2;
               if(_loc6_ > 10)
               {
                  _loc7_ = param2 / 4;
               }
            }
         }
         if(param4)
         {
            _loc7_ = 0;
         }
         if(param1 < 0.125)
         {
            _loc7_ = Math.max(_loc7_,param1);
         }
         return _loc7_;
      }
      
      public function set minBHN(param1:Number) : void
      {
         this._minBHN = param1;
      }
      
      public function get minBHN() : Number
      {
         return this._minBHN;
      }
      
      public function getSafeHPLimit() : Number
      {
         if(GWizMachSettings.currMachineSafeMode())
         {
            return Math.min(1,this.hpLimit.value * 0.8);
         }
         return this.hpLimit.value;
      }
      
      public function get afpt() : Number
      {
         var _loc1_:Number = this.ipt.value * this.rctf;
         if(this.useHSMFeedsSpeedsAdj())
         {
            _loc1_ *= this.hsmIPMFactor;
         }
         if(this.toolParms.isTapping())
         {
            _loc1_ = this.cutWidth;
         }
         return _loc1_;
      }
      
      private function getToolsListEntry(param1:String) : Object
      {
         var _loc5_:Object = null;
         if(this.lastToolListEntry && this.lastToolListType == param1)
         {
            return this.lastToolListEntry;
         }
         var _loc2_:String = "";
         if(param1.indexOf("Carbide") >= 0)
         {
            _loc2_ = "Carbide ";
            param1 = param1.replace("Carbide ","");
         }
         else if(param1.indexOf("HSS") >= 0)
         {
            _loc2_ = "HSS ";
            param1 = param1.replace("HSS ","");
         }
         var _loc3_:String = "";
         if(param1.indexOf("HP") >= 0)
         {
            _loc3_ = "HP ";
            param1 = param1.replace("HP ","");
         }
         else if(param1.indexOf("TiAlN") >= 0)
         {
            _loc3_ = "TiAlN ";
            param1 = param1.replace("TiAlN ","");
         }
         else if(param1.indexOf("TiCrN") >= 0)
         {
            _loc3_ = "TiCrN ";
            param1 = param1.replace("TiCrN ","");
         }
         switch(param1)
         {
            case "Turning":
            case "Parting":
            case "Grooving":
            case "Threading":
               _loc2_ = _loc2_.replace(" ","");
               param1 = "Turning: " + _loc2_;
               break;
            case "Boring Bar":
               param1 = _loc2_ + "Boring";
               break;
            case "Indexable End Or Face Mill":
               break;
            default:
               param1 = _loc3_ + _loc2_ + param1;
         }
         var _loc4_:int = 0;
         while(_loc4_ < GWizConfigData.ToolsList.length)
         {
            if((_loc5_ = GWizConfigData.ToolsList.getItemAt(_loc4_)).label == param1)
            {
               this.lastToolListType = param1;
               this.lastToolListEntry = _loc5_;
               return _loc5_;
            }
            _loc4_++;
         }
         return null;
      }
      
      private function isCarbide() : Boolean
      {
         var _loc1_:Object = this.getToolsListEntry(this.toolParms.toolType);
         if(_loc1_)
         {
            return _loc1_.carbide == "yes";
         }
         return false;
      }
      
      private function adjSFMForHardness(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Number
      {
         if(isNaN(param5) || param5 <= 0)
         {
            return param1;
         }
         param2 *= 0.7;
         param2 = Math.min(0.4 * param1,param2);
         param5 = Math.min(param5,param4);
         param5 = Math.max(param5,param3);
         var _loc6_:Number = param4 - param3;
         param5 = (param5 -= param3) / _loc6_;
         var _loc7_:Number = (param5 = 0.5 - param5) * param2;
         return param1 + _loc7_;
      }
      
      public function lookupBaseSFM() : Number
      {
         var _loc1_:Number = NaN;
         var _loc2_:String = null;
         if(this.mfgSFM.isOverridden())
         {
            _loc1_ = this.mfgSFM.value;
         }
         else
         {
            _loc1_ = this.lookupBaseSFMAux(this.materialName,this.toolParms.toolType,this.toolParms.isFormTap());
            _loc1_ = GWizMfgCutterSpecs.familySFM(_loc1_,this.materialName);
            if(GWizAbstractPrefs.isOEM)
            {
               _loc2_ = this.toolParms.cribProduct;
               _loc1_ = GWizGarrOEMToolData.lookupSFM(this.materialName,this.adjHardness,_loc2_,_loc1_,this.cutDepth / this.toolParms.toolDiam,this.cutWidth / this.toolParms.toolDiam);
            }
            this.mfgSFM.value = _loc1_;
         }
         return _loc1_;
      }
      
      private function filterSFM(param1:Object) : Boolean
      {
         var _loc2_:String = this.toolParms.toolType;
         switch(_loc2_)
         {
            case "HSS Reamer":
               _loc2_ = "HSS Twist Drill";
               break;
            case "Carbide Reamer":
               _loc2_ = "Carbide Twist Drill";
               break;
            case "Carbide Spot Drill":
               _loc2_ = "Carbide Twist Drill";
               break;
            case "Carbide Spade Drill":
               _loc2_ = "Carbide Twist Drill";
               break;
            case "HSS Center Drill":
               _loc2_ = "HSS Twist Drill";
               break;
            case "Carbide Center Drill":
               _loc2_ = "Carbide Twist Drill";
         }
         return param1.material == this.materialName && param1.tool == _loc2_;
      }
      
      public function lookupBaseSFMAux(param1:String, param2:String, param3:Boolean) : Number
      {
         var _loc10_:Number = NaN;
         var _loc11_:String = null;
         var _loc12_:Number = NaN;
         GWizUtils.LogErrorContext = "GWizFeedSpeedMath.lookupBaseSFM";
         if(param1 == null || param1.length == 0 || param2 == null || param2.length == 0)
         {
            return 500;
         }
         var _loc4_:String = param2;
         param2 = GWizStringUtils.lowerToProperCase(param2).replace("Hss","HSS");
         param2 = param2.replace("Hp","HP");
         param2 = param2.replace("Tialn","TiAlN");
         param2 = param2.replace("Altin","AlTiN");
         param2 = param2.replace("Pcd","PCD");
         switch(param2)
         {
            case "Carbide Saws & Woodruff Cutters":
               param2 = "Carbide Endmill";
               break;
            case "HSS Saws & Woodruff Cutters":
               param2 = "HSS Endmill";
               break;
            case "Carbide Turning":
            case "Carbide Parting/Grooving":
            case "Carbide Parting":
            case "Carbide Grooving":
            case "Carbide Threading":
            case "Carbide Boring Bar":
               param2 = "Turning: Carbide";
               break;
            case "HSS Turning":
            case "HSS Parting/Grooving":
            case "HSS Parting":
            case "HSS Grooving":
            case "Parting/Grooving":
            case "Parting":
            case "Grooving":
            case "HSS Threading":
            case "Threading":
            case "HSS Boring Bar":
            case "Boring Bar":
               param2 = "Turning: HSS";
               break;
            case "Carbide Tapping":
               param2 = "Tapping";
               break;
            case "HSS Tapping":
               param2 = "Tapping";
               break;
            case "HSS Reamer":
               param2 = "HSS Twist Drill";
               break;
            case "Carbide Reamer":
               param2 = "Carbide Twist Drill";
               break;
            case "HSS Center Drill":
               param2 = "HSS Twist Drill";
               break;
            case "Carbide Center Drill":
               param2 = "Carbide Twist Drill";
               break;
            case "Carbide Spot Drill":
               param2 = "Carbide Twist Drill";
               break;
            case "Carbide Spade Drill":
               param2 = "Carbide Twist Drill";
         }
         var _loc5_:String = param2;
         if(this.toolParms && this.toolParms.coating && this.toolParms.coating.indexOf("PCD") >= 0)
         {
            if(param2.indexOf("Endmill") >= 0)
            {
               param2 = "PCD Endmill";
            }
            else if(param2.indexOf("Twist Drill") >= 0)
            {
               param2 = "PCD Twist Drill";
            }
         }
         switch(this.toolParms.coating)
         {
            case "TiAlN":
            case "AlTiN":
            case "AlCrN":
               if(param2.indexOf("TiAlN") < 0 && this.toolParms.toolmaterial != "HSS" && param2.indexOf("Endmill") >= 0)
               {
                  param2 = "TiAlN " + param2;
                  param2 = param2.replace("HP","");
               }
         }
         var _loc6_:Object = GWizConfigData.lookupSFMData(param1,param2);
         param2 = _loc5_;
         if(!_loc6_)
         {
            (_loc6_ = new Object()).sfm = 0;
         }
         var _loc7_:Number = _loc6_.sfm;
         param2 = _loc4_;
         if(param2.search("Saws & Woodruff Cutters") != -1 || param2.search("Parting") != -1 || param2.search("Grooving") != -1)
         {
            _loc7_ *= 0.75;
         }
         else if(param2.search("Threading") != -1)
         {
            _loc7_ *= 0.6;
         }
         else if(param2.indexOf("Tapping") >= 0)
         {
            if(param2 == "Carbide Tapping")
            {
               if(param3)
               {
                  _loc10_ = _loc6_.CarbideForm;
               }
               else
               {
                  _loc10_ = _loc6_.CarbideCut;
               }
            }
            else if(param3)
            {
               _loc10_ = _loc6_.HSSForm;
            }
            if(isNaN(_loc10_))
            {
               _loc10_ = 1;
            }
            _loc7_ *= _loc10_;
         }
         var _loc8_:String;
         if((_loc8_ = this.toolParms.coating) && _loc8_.toLowerCase().search("hardlube") >= 0)
         {
            if((_loc11_ = param1.toLowerCase()).search("aluminum") >= 0)
            {
               if(_loc11_.search("cast") >= 0)
               {
                  _loc7_ *= 1.63;
               }
               else
               {
                  _loc7_ *= 1.07;
               }
            }
            else if(_loc11_.search("magnesium") >= 0)
            {
               _loc7_ *= 1.17;
            }
            else if(_loc11_.search("brass") >= 0)
            {
               _loc7_ *= 1.33;
            }
            else if(_loc11_.search("copper") >= 0)
            {
               _loc7_ *= 1.33;
            }
         }
         var _loc9_:Number;
         if((_loc9_ = this.lookupMaxHardness()) == 0)
         {
            this.engagementThreshold = 1;
         }
         else if(this.sfmRange > 0)
         {
            _loc7_ = this.adjSFMForHardness(_loc7_,this.sfmRange,this.minBHN,_loc9_,this.adjHardness);
            this.engagementThreshold = this.ENGAGEMENT_THRESHOLD;
         }
         _loc7_ *= GWizMatBrowser2.alloySFMTweak;
         if(_loc6_.hasOwnProperty("tsc") && this.hpc)
         {
            _loc12_ = _loc6_.tsc;
            if(this.tsc)
            {
               _loc7_ *= _loc12_;
            }
         }
         return _loc7_;
      }
      
      private function lookupSFM() : Number
      {
         var _loc3_:Number = NaN;
         GWizUtils.LogErrorContext = "GWizFeedSpeedMath.lookupSFM";
         var _loc1_:Number = this.lookupBaseSFM();
         var _loc2_:Number = 1;
         if(this.isPartialDiameterCutter())
         {
            _loc3_ = this.cutWidth / this.toolParms.toolDiam;
            _loc2_ = _loc3_ - this.engagementThreshold;
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            _loc2_ /= this.PENALTY_INTERVAL;
            _loc2_ *= this.MAX_PENALTY;
            _loc2_ = 1 - _loc2_;
         }
         this.axialSFMAdjust = 1;
         if(this.adjustSFMForLength)
         {
            if(this.toolParms.isParabolic())
            {
               if(this.axialEngagement >= 2000)
               {
                  _loc2_ = 0;
               }
               else if(this.axialEngagement >= 1700)
               {
                  _loc2_ *= GWizUtils.interpolate(1700,0.7,this.axialEngagement,2000,0.5);
               }
               else if(this.axialEngagement >= 1400)
               {
                  _loc2_ *= GWizUtils.interpolate(1400,0.6,this.axialEngagement,1700,0.6);
               }
               else if(this.axialEngagement >= 1100)
               {
                  _loc2_ *= GWizUtils.interpolate(1100,0.8,this.axialEngagement,1400,0.7);
               }
               else if(this.axialEngagement >= 800)
               {
                  _loc2_ *= GWizUtils.interpolate(800,0.9,this.axialEngagement,1100,0.8);
               }
               else if(this.axialEngagement >= 600)
               {
                  _loc2_ *= GWizUtils.interpolate(600,0.95,this.axialEngagement,800,0.9);
               }
               else if(this.axialEngagement >= 500)
               {
                  _loc2_ *= GWizUtils.interpolate(500,1,this.axialEngagement,600,0.95);
               }
               this.axialSFMAdjust = _loc2_;
            }
            else if(this.toolParms.isTwistDrill())
            {
               if(this.axialEngagement >= this.MAX_AXIAL_ENGAGEMENT)
               {
                  _loc2_ = 0;
               }
               else if(this.axialEngagement >= 600)
               {
                  _loc2_ *= GWizUtils.interpolate(600,0.7,this.axialEngagement,700,0.6);
               }
               else if(this.axialEngagement >= 500)
               {
                  _loc2_ *= GWizUtils.interpolate(500,0.8,this.axialEngagement,600,0.7);
               }
               else if(this.axialEngagement >= 400)
               {
                  _loc2_ *= GWizUtils.interpolate(400,0.9,this.axialEngagement,500,0.8);
               }
               else if(this.axialEngagement >= 300)
               {
                  _loc2_ *= GWizUtils.interpolate(300,1,this.axialEngagement,400,0.9);
               }
               this.axialSFMAdjust = _loc2_;
            }
            else if(!(this.toolParms.toolType == "Carbide Tapping" || this.toolParms.toolType == "HSS Tapping" || this.toolParms.toolType == "Tapping"))
            {
               if(this.axialEngagement >= 300)
               {
                  this.axialSFMAdjust = 0.3;
               }
               else if(this.axialEngagement >= 200)
               {
                  this.axialSFMAdjust = GWizUtils.interpolate(200,0.66,this.axialEngagement,300,0.5);
               }
               else if(this.axialEngagement >= 100)
               {
                  this.axialSFMAdjust = GWizUtils.interpolate(100,0.83,this.axialEngagement,200,0.66);
               }
               else if(this.axialEngagement >= 50)
               {
                  this.axialSFMAdjust = GWizUtils.interpolate(50,0.88,this.axialEngagement,100,0.83);
               }
               else if(this.axialEngagement >= 25)
               {
                  this.axialSFMAdjust = GWizUtils.interpolate(25,1,this.axialEngagement,50,0.88);
               }
               if(_loc3_ <= 0.2 && !this.hsmFeedsSpeedsAdj)
               {
                  this.axialSFMAdjust = 1 - this.axialSFMAdjust;
                  this.axialSFMAdjust = 0.2 * this.axialSFMAdjust;
                  this.axialSFMAdjust = 1 - this.axialSFMAdjust;
               }
               _loc2_ *= this.axialSFMAdjust;
            }
         }
         _loc1_ = this.gasPedalSFMAdjust(_loc1_);
         _loc2_ *= this.msfmAdjust / 100;
         return Number(_loc1_ * _loc2_);
      }
      
      private function calcMRR(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Number
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc6_:Number = 0;
         switch(this.toolParms.toolType)
         {
            case "Annular Cutter (Rotabroach®)":
               _loc6_ = Math.PI * param5 * param5 / 4 * param3;
               _loc9_ = 0;
               while(_loc9_ < GWizConfigData.annularCutterAreaFactors.length)
               {
                  if((_loc10_ = GWizConfigData.annularCutterAreaFactors.getItemAt(_loc9_)).dia >= this.toolParms.toolDiam)
                  {
                     _loc6_ = (_loc11_ = _loc10_.af) * param3;
                     break;
                  }
                  _loc9_++;
               }
               break;
            case "HSS Spot Drill":
            case "Carbide Spot Drill":
            case "HSS Twist Drill":
            case "Carbide Twist Drill":
            case "HSS Spade Drill":
            case "Carbide Spade Drill":
            case "Gun Drill":
            case "Cobalt Twist Drill":
            case "HP HSS Twist Drill":
            case "HP Carbide Twist Drill":
            case "Indexable Drill":
               _loc6_ = Math.PI * param5 * param5 / 4 * param3;
               break;
            case "HSS Reamer":
            case "Carbide Reamer":
            case "Tapping":
            case "Carbide Tapping":
            case "HSS Tapping":
               _loc7_ = 0.008;
               if(this.toolParms.toolType == "Tapping" || this.toolParms.toolType == "Carbide Tapping" || this.toolParms.toolType == "HSS Tapping")
               {
                  _loc7_ = param5 * 0.1;
               }
               _loc6_ = Math.PI * param5 * param5 * param3 / 4 - Math.PI * (param5 - _loc7_) * (param5 - _loc7_) * param3 / 4;
               break;
            case "Turning: HSS":
            case "Turning: Carbide":
            case "HSS Turning":
            case "Carbide Turning":
            case "HSS Boring Bar":
            case "Carbide Boring Bar":
            case "HSS Parting":
            case "Carbide Parting":
            case "HSS Grooving":
            case "Carbide Grooving":
            case "HSS Threading":
            case "Carbide Threading":
            case "HSS Boring":
            case "Carbide Boring":
               _loc6_ = 12 * param1 * (param3 / param2) * param4;
               break;
            default:
               _loc8_ = param4;
               if(this.toolParms.isLollipop())
               {
                  _loc8_ = Math.min(param4,this.toolParms.toolDiam);
               }
               _loc6_ = param3 * _loc8_ * param5;
               if(this.toolParms.isBallnose())
               {
                  _loc12_ = this.toolParms.toolDiam / 2;
                  if(_loc8_ > _loc12_)
                  {
                     _loc13_ = _loc12_;
                  }
                  else
                  {
                     _loc13_ = _loc8_;
                  }
                  _loc14_ = _loc12_ - _loc13_;
                  _loc15_ = _loc12_ * _loc12_ * Math.acos((_loc12_ - _loc13_) / _loc12_) - (_loc12_ - _loc13_) * Math.sqrt(2 * _loc12_ * _loc13_ - _loc13_ * _loc13_);
                  _loc16_ = param5 / this.toolParms.toolDiam;
                  _loc15_ *= _loc16_;
                  if(_loc8_ > _loc12_)
                  {
                     _loc15_ += (_loc8_ - _loc12_) * param5;
                  }
                  _loc6_ = param3 * _loc15_;
               }
         }
         return _loc6_;
      }
      
      private function isPartialDiameterCutter() : Boolean
      {
         return this.toolParms.toolType.toLowerCase().indexOf("mill") >= 0;
      }
      
      private function isChipThinnable() : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc1_:* = false;
         var _loc2_:Object = this.getToolsListEntry(this.toolParms.toolType);
         if(_loc2_ && _loc2_.label == this.toolParms.toolType)
         {
            _loc1_ = _loc2_.chipThin == "yes";
            _loc3_ = 0;
            while(_loc3_ < GWizToolData.geometryTypes.length)
            {
               if((_loc4_ = GWizToolData.geometryTypes.getItemAt(_loc3_)).label == this.toolParms.geometry)
               {
                  if(_loc4_.chipThin != true)
                  {
                     _loc1_ = false;
                     break;
                  }
               }
               _loc3_++;
            }
         }
         return _loc1_;
      }
      
      private function initIPTData() : void
      {
         this.IPTData = new Array();
         var _loc1_:int = 0;
         var _loc2_:* = _loc1_++;
         this.IPTData[_loc2_] = ["Material","Tool",0.0625,0.125,0.1875,0.25,0.375,0.5,0.75,1,1.5,2,3,4,5];
         var _loc3_:* = _loc1_++;
         this.IPTData[_loc3_] = ["Aluminum - Cast","HSS Spot Drill",0.00025,0.00075,0.001,0.0015,0.002,0.0025,0.003,0.004,0.005,0.00625,0.00625,0.00625,0.00625];
         var _loc4_:*;
         this.IPTData[_loc4_ = _loc1_++] = ["Aluminum - Cast","HSS Twist Drill",0.0005,0.0015,0.002,0.003,0.004,0.005,0.006,0.008,0.01,0.0125,0.0125,0.0125,0.0125];
         var _loc5_:*;
         this.IPTData[_loc5_ = _loc1_++] = ["Aluminum - Cast","Carbide Twist Drill",0.0005,0.0015,0.002,0.003,0.004,0.005,0.006,0.008,0.01,0.0125,0.0125,0.0125,0.0125];
         var _loc6_:*;
         this.IPTData[_loc6_ = _loc1_++] = ["Aluminum - Cast","HSS Spade Drill",0.001,0.003,0.004,0.006,0.008,0.013,0.016,0.019,0.022,0.025,0.03,0.037,0.042];
         var _loc7_:*;
         this.IPTData[_loc7_ = _loc1_++] = ["Aluminum - Cast","Gun Drill",0.0002,0.0002,0.0002,0.0002,0.0003,0.0005,0.0008,0.0012,0.0012,0.0015,0.0015,0.0015,0.0015];
         var _loc8_:*;
         this.IPTData[_loc8_ = _loc1_++] = ["Aluminum - Cast","HSS Endmill",0.0006,0.0012,0.0018,0.0024,0.0036,0.0049,0.0073,0.009,0.009,0.009,0.009,0.009,0.009];
         var _loc9_:*;
         this.IPTData[_loc9_ = _loc1_++] = ["Aluminum - Cast","Carbide Endmill",0.0005,0.001,0.0015,0.002,0.003,0.004,0.006,0.0075,0.0075,0.0075,0.0075,0.0075,0.0075];
         var _loc10_:*;
         this.IPTData[_loc10_ = _loc1_++] = ["Aluminum - Cast","HSS Reamer",0.0005,0.002,0.004,0.0047,0.006,0.0073,0.01,0.0125,0.0165,0.02,0.02,0.02,0.02];
         var _loc11_:*;
         this.IPTData[_loc11_ = _loc1_++] = ["Aluminum - Cast","Indexable Drill",0.0005,0.0005,0.0005,0.001,0.001,0.002,0.0025,0.0059,0.0077,0.0085,0.0096,0.0101,0.0101];
         var _loc12_:*;
         this.IPTData[_loc12_ = _loc1_++] = ["Aluminum - Cast","Cobalt Twist Drill",0.0005,0.0015,0.002,0.003,0.004,0.005,0.006,0.008,0.01,0.0125,0.0125,0.0125,0.0125];
         var _loc13_:*;
         this.IPTData[_loc13_ = _loc1_++] = ["Aluminum - Cast","HP HSS Endmill",0.00066,0.00132,0.00198,0.00264,0.00396,0.00539,0.00803,0.0099,0.0099,0.0099,0.0099,0.0099,0.0099];
         var _loc14_:*;
         this.IPTData[_loc14_ = _loc1_++] = ["Aluminum - Cast","HP HSS Twist Drill",0.00055,0.00165,0.0022,0.0033,0.0044,0.0055,0.0066,0.0088,0.011,0.01375,0.01375,0.01375,0.01375];
         var _loc15_:*;
         this.IPTData[_loc15_ = _loc1_++] = ["Aluminum - Cast","HP Carbide Endmill",0.00072,0.00144,0.00216,0.00288,0.00432,0.00588,0.00876,0.0108,0.0108,0.0108,0.0108,0.0108,0.0108];
         var _loc16_:*;
         this.IPTData[_loc16_ = _loc1_++] = ["Aluminum - Cast","TiAlN Carbide Endmill",0.00072,0.00144,0.00216,0.00288,0.00432,0.00588,0.00876,0.0108,0.0108,0.0108,0.0108,0.0108,0.0108];
         var _loc17_:*;
         this.IPTData[_loc17_ = _loc1_++] = ["Aluminum - Cast","HP Carbide Twist Drill",0.00055,0.00165,0.0022,0.0033,0.0044,0.0055,0.0066,0.0088,0.011,0.01375,0.01375,0.01375,0.01375];
         var _loc18_:*;
         this.IPTData[_loc18_ = _loc1_++] = ["Aluminum - Cast","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.007,0.007,0.007,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc19_:*;
         this.IPTData[_loc19_ = _loc1_++] = ["Aluminum - Cast","Turning: HSS",0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018];
         var _loc20_:*;
         this.IPTData[_loc20_ = _loc1_++] = ["Aluminum - Cast","Turning: Carbide",0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018];
         var _loc21_:*;
         this.IPTData[_loc21_ = _loc1_++] = ["Aluminum - Wrought (6061)","HSS Spot Drill",0.00025,0.00075,0.001,0.0015,0.002,0.0025,0.003,0.004,0.005,0.00625,0.00625,0.00625,0.00625];
         var _loc22_:*;
         this.IPTData[_loc22_ = _loc1_++] = ["Aluminum - Wrought (6061)","HSS Twist Drill",0.0005,0.0015,0.002,0.003,0.004,0.005,0.006,0.008,0.01,0.0125,0.0125,0.0125,0.0125];
         var _loc23_:*;
         this.IPTData[_loc23_ = _loc1_++] = ["Aluminum - Wrought (6061)","Carbide Twist Drill",0.0005,0.0015,0.002,0.003,0.004,0.005,0.006,0.008,0.01,0.0125,0.0125,0.0125,0.0125];
         var _loc24_:*;
         this.IPTData[_loc24_ = _loc1_++] = ["Aluminum - Wrought (6061)","HSS Spade Drill",0.001,0.003,0.004,0.006,0.008,0.013,0.016,0.019,0.022,0.025,0.03,0.037,0.042];
         var _loc25_:*;
         this.IPTData[_loc25_ = _loc1_++] = ["Aluminum - Wrought (6061)","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0009,0.0013,0.0025,0.0035,0.0038,0.004,0.004,0.004,0.004];
         var _loc26_:*;
         this.IPTData[_loc26_ = _loc1_++] = ["Aluminum - Wrought (6061)","HSS Endmill",0.0006,0.0012,0.0018,0.0024,0.0036,0.0049,0.0073,0.009,0.009,0.009,0.009,0.009,0.009];
         var _loc27_:*;
         this.IPTData[_loc27_ = _loc1_++] = ["Aluminum - Wrought (6061)","Carbide Endmill",0.0005,0.001,0.0015,0.002,0.003,0.004,0.006,0.0075,0.0075,0.0075,0.0075,0.0075,0.0075];
         var _loc28_:*;
         this.IPTData[_loc28_ = _loc1_++] = ["Aluminum - Wrought (6061)","HSS Reamer",0.0005,0.002,0.004,0.0047,0.006,0.0073,0.01,0.0125,0.0165,0.02,0.02,0.02,0.02];
         var _loc29_:*;
         this.IPTData[_loc29_ = _loc1_++] = ["Aluminum - Wrought (6061)","Indexable Drill",0.00025,0.00025,0.00025,0.0005,0.0005,0.001,0.00125,0.0059,0.0077,0.0085,0.0096,0.0101,0.0101];
         var _loc30_:*;
         this.IPTData[_loc30_ = _loc1_++] = ["Aluminum - Wrought (6061)","Cobalt Twist Drill",0.0005,0.0015,0.002,0.003,0.004,0.005,0.006,0.008,0.01,0.0125,0.0125,0.0125,0.0125];
         var _loc31_:*;
         this.IPTData[_loc31_ = _loc1_++] = ["Aluminum - Wrought (6061)","HP HSS Endmill",0.00066,0.00132,0.00198,0.00264,0.00396,0.00539,0.00803,0.0099,0.0099,0.0099,0.0099,0.0099,0.0099];
         var _loc32_:*;
         this.IPTData[_loc32_ = _loc1_++] = ["Aluminum - Wrought (6061)","HP HSS Twist Drill",0.00055,0.00165,0.0022,0.0033,0.0044,0.0055,0.0066,0.0088,0.011,0.01375,0.01375,0.01375,0.01375];
         var _loc33_:*;
         this.IPTData[_loc33_ = _loc1_++] = ["Aluminum - Wrought (6061)","HP Carbide Endmill",0.00072,0.00144,0.00216,0.00288,0.00432,0.00588,0.00876,0.0108,0.0108,0.0108,0.0108,0.0108,0.0108];
         var _loc34_:*;
         this.IPTData[_loc34_ = _loc1_++] = ["Aluminum - Wrought (6061)","TiAlN Carbide Endmill",0.00072,0.00144,0.00216,0.00288,0.00432,0.00588,0.00876,0.0108,0.0108,0.0108,0.0108,0.0108,0.0108];
         var _loc35_:*;
         this.IPTData[_loc35_ = _loc1_++] = ["Aluminum - Wrought (6061)","HP Carbide Twist Drill",0.00055,0.00165,0.0022,0.0033,0.0044,0.0055,0.0066,0.0088,0.011,0.01375,0.01375,0.01375,0.01375];
         var _loc36_:*;
         this.IPTData[_loc36_ = _loc1_++] = ["Aluminum - Wrought (6061)","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc37_:*;
         this.IPTData[_loc37_ = _loc1_++] = ["Aluminum - Wrought (6061)","Turning: HSS",0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018];
         var _loc38_:*;
         this.IPTData[_loc38_ = _loc1_++] = ["Aluminum - Wrought (6061)","Turning: Carbide",0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018];
         var _loc39_:*;
         this.IPTData[_loc39_ = _loc1_++] = ["Brass","HSS Spot Drill",0.00025,0.00075,0.001,0.0015,0.002,0.0025,0.003,0.004,0.005,0.00625,0.00625,0.00625,0.00625];
         var _loc40_:*;
         this.IPTData[_loc40_ = _loc1_++] = ["Brass","HSS Twist Drill",0.0005,0.0015,0.002,0.003,0.004,0.005,0.006,0.008,0.01,0.0125,0.0125,0.0125,0.0125];
         var _loc41_:*;
         this.IPTData[_loc41_ = _loc1_++] = ["Brass","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc42_:*;
         this.IPTData[_loc42_ = _loc1_++] = ["Brass","HSS Spade Drill",0.0006225,0.0018675,0.00249,0.003735,0.00498,0.006225,0.00747,0.01,0.0115,0.013,0.017,0.023,0.03];
         var _loc43_:*;
         this.IPTData[_loc43_ = _loc1_++] = ["Brass","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0006,0.0008,0.0015,0.0022,0.0026,0.003,0.003,0.003,0.003];
         var _loc44_:*;
         this.IPTData[_loc44_ = _loc1_++] = ["Brass","HSS Endmill",0.0005,0.0011,0.0017,0.0024,0.0028,0.0036,0.0048,0.0055,0.0055,0.0055,0.0055,0.0055,0.0055];
         var _loc45_:*;
         this.IPTData[_loc45_ = _loc1_++] = ["Brass","Carbide Endmill",0.0005,0.001,0.0015,0.002,0.0025,0.003,0.004,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc46_:*;
         this.IPTData[_loc46_ = _loc1_++] = ["Brass","HSS Reamer",0.000375,0.0015,0.003,0.0037,0.005,0.006,0.008,0.01,0.0135,0.018,0.018,0.018,0.018];
         var _loc47_:*;
         this.IPTData[_loc47_ = _loc1_++] = ["Brass","Indexable Drill",0.000125,0.000125,0.000125,0.00025,0.00025,0.0005,0.000625,0.0059,0.0077,0.0085,0.0096,0.0101,0.0101];
         var _loc48_:*;
         this.IPTData[_loc48_ = _loc1_++] = ["Brass","Cobalt Twist Drill",0.0005,0.0015,0.002,0.003,0.004,0.005,0.006,0.008,0.01,0.0125,0.0125,0.0125,0.0125];
         var _loc49_:*;
         this.IPTData[_loc49_ = _loc1_++] = ["Brass","HP HSS Endmill",0.00055,0.00121,0.00187,0.00264,0.00308,0.00396,0.00528,0.00605,0.00605,0.00605,0.00605,0.00605,0.00605];
         var _loc50_:*;
         this.IPTData[_loc50_ = _loc1_++] = ["Brass","HP HSS Twist Drill",0.00055,0.00165,0.0022,0.0033,0.0044,0.0055,0.0066,0.0088,0.011,0.01375,0.01375,0.01375,0.01375];
         var _loc51_:*;
         this.IPTData[_loc51_ = _loc1_++] = ["Brass","HP Carbide Endmill",0.0006,0.00132,0.00204,0.00288,0.00336,0.00432,0.00576,0.0066,0.0066,0.0066,0.0066,0.0066,0.0066];
         var _loc52_:*;
         this.IPTData[_loc52_ = _loc1_++] = ["Brass","TiAlN Carbide Endmill",0.0006,0.00132,0.00204,0.00288,0.00336,0.00432,0.00576,0.0066,0.0066,0.0066,0.0066,0.0066,0.0066];
         var _loc53_:*;
         this.IPTData[_loc53_ = _loc1_++] = ["Brass","HP Carbide Twist Drill",0.00055,0.00165,0.0022,0.0033,0.0044,0.0055,0.0066,0.0088,0.011,0.01375,0.01375,0.01375,0.01375];
         var _loc54_:*;
         this.IPTData[_loc54_ = _loc1_++] = ["Brass","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.007,0.007,0.007,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc55_:*;
         this.IPTData[_loc55_ = _loc1_++] = ["Brass","Turning: HSS",0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01];
         var _loc56_:*;
         this.IPTData[_loc56_ = _loc1_++] = ["Brass","Turning: Carbide",0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01];
         var _loc57_:*;
         this.IPTData[_loc57_ = _loc1_++] = ["Cast Iron - Ductile","HSS Spot Drill",0.00025,0.00075,0.001,0.00125,0.00175,0.00225,0.0025,0.0035,0.0045,0.00525,0.00525,0.00525,0.00525];
         var _loc58_:*;
         this.IPTData[_loc58_ = _loc1_++] = ["Cast Iron - Ductile","HSS Twist Drill",0.0005,0.0015,0.002,0.0025,0.0035,0.0045,0.005,0.007,0.009,0.0105,0.0105,0.0105,0.0105];
         var _loc59_:*;
         this.IPTData[_loc59_ = _loc1_++] = ["Cast Iron - Ductile","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc60_:*;
         this.IPTData[_loc60_ = _loc1_++] = ["Cast Iron - Ductile","HSS Spade Drill",0.0005,0.0005,0.0005,0.001,0.001,0.001,0.005,0.01,0.0125,0.015,0.02,0.025,0.03];
         var _loc61_:*;
         this.IPTData[_loc61_ = _loc1_++] = ["Cast Iron - Ductile","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0007,0.001,0.002,0.0027,0.0031,0.0035,0.0035,0.0035,0.0035];
         var _loc62_:*;
         this.IPTData[_loc62_ = _loc1_++] = ["Cast Iron - Ductile","HSS Endmill",0.0002,0.0004,0.0006,0.001,0.0014,0.0016,0.0032,0.0048,0.0048,0.0048,0.0048,0.0048,0.0048];
         var _loc63_:*;
         this.IPTData[_loc63_ = _loc1_++] = ["Cast Iron - Ductile","Carbide Endmill",0.0003,0.0005,0.0008,0.0012,0.0017,0.002,0.004,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc64_:*;
         this.IPTData[_loc64_ = _loc1_++] = ["Cast Iron - Ductile","HSS Reamer",0.001,0.002,0.005,0.0065,0.008,0.01,0.012,0.016,0.0225,0.03,0.03,0.03,0.03];
         var _loc65_:*;
         this.IPTData[_loc65_ = _loc1_++] = ["Cast Iron - Ductile","Indexable Drill",0.0000625,0.0000625,0.0000625,0.0005,0.001,0.002,0.003,0.0053,0.0073,0.008,0.0094,0.0101,0.0101];
         var _loc66_:*;
         this.IPTData[_loc66_ = _loc1_++] = ["Cast Iron - Ductile","Cobalt Twist Drill",0.0005,0.0015,0.002,0.0025,0.0035,0.0045,0.005,0.007,0.009,0.0105,0.0105,0.0105,0.0105];
         var _loc67_:*;
         this.IPTData[_loc67_ = _loc1_++] = ["Cast Iron - Ductile","HP HSS Endmill",0.00022,0.00044,0.00066,0.0011,0.00154,0.00176,0.00352,0.00528,0.00528,0.00528,0.00528,0.00528,0.00528];
         var _loc68_:*;
         this.IPTData[_loc68_ = _loc1_++] = ["Cast Iron - Ductile","HP HSS Twist Drill",0.00055,0.00165,0.0022,0.00275,0.00385,0.00495,0.0055,0.0077,0.0099,0.01155,0.01155,0.01155,0.01155];
         var _loc69_:*;
         this.IPTData[_loc69_ = _loc1_++] = ["Cast Iron - Ductile","HP Carbide Endmill",0.00024,0.00048,0.00072,0.0012,0.00168,0.00192,0.00384,0.00576,0.00576,0.00576,0.00576,0.00576,0.00576];
         var _loc70_:*;
         this.IPTData[_loc70_ = _loc1_++] = ["Cast Iron - Ductile","TiAlN Carbide Endmill",0.00024,0.00048,0.00072,0.0012,0.00168,0.00192,0.00384,0.00576,0.00576,0.00576,0.00576,0.00576,0.00576];
         var _loc71_:*;
         this.IPTData[_loc71_ = _loc1_++] = ["Cast Iron - Ductile","HP Carbide Twist Drill",0.00055,0.00165,0.0022,0.00275,0.00385,0.00495,0.0055,0.0077,0.0099,0.01155,0.01155,0.01155,0.01155];
         var _loc72_:*;
         this.IPTData[_loc72_ = _loc1_++] = ["Cast Iron - Ductile","Indexable End Or Face Mill",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.007,0.007,0.007,0.007,0.007,0.007];
         var _loc73_:*;
         this.IPTData[_loc73_ = _loc1_++] = ["Cast Iron - Ductile","Turning: HSS",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc74_:*;
         this.IPTData[_loc74_ = _loc1_++] = ["Cast Iron - Ductile","Turning: Carbide",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc75_:*;
         this.IPTData[_loc75_ = _loc1_++] = ["Cast Iron - Gray","HSS Spot Drill",0.00025,0.00075,0.001,0.00125,0.002,0.00275,0.003,0.00425,0.0055,0.00625,0.00625,0.00625,0.00625];
         var _loc76_:*;
         this.IPTData[_loc76_ = _loc1_++] = ["Cast Iron - Gray","HSS Twist Drill",0.0005,0.0015,0.002,0.0025,0.004,0.0055,0.006,0.0085,0.011,0.0125,0.0125,0.0125,0.0125];
         var _loc77_:*;
         this.IPTData[_loc77_ = _loc1_++] = ["Cast Iron - Gray","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.0035275,0.004565,0.0051875,0.0051875,0.0051875,0.0051875];
         var _loc78_:*;
         this.IPTData[_loc78_ = _loc1_++] = ["Cast Iron - Gray","HSS Spade Drill",0.000195,0.00078,0.00117,0.00156,0.0046,0.006,0.007,0.02,0.025,0.025,0.025,0.028,0.033];
         var _loc79_:*;
         this.IPTData[_loc79_ = _loc1_++] = ["Cast Iron - Gray","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0008,0.0012,0.0025,0.0035,0.0038,0.004,0.004,0.004,0.004];
         var _loc80_:*;
         this.IPTData[_loc80_ = _loc1_++] = ["Cast Iron - Gray","HSS Endmill",0.0002,0.0004,0.0006,0.001,0.0014,0.0016,0.0032,0.0048,0.0048,0.0048,0.0048,0.0048,0.0048];
         var _loc81_:*;
         this.IPTData[_loc81_ = _loc1_++] = ["Cast Iron - Gray","Carbide Endmill",0.0003,0.0007,0.0012,0.002,0.0027,0.0035,0.0055,0.007,0.007,0.007,0.007,0.007,0.007];
         var _loc82_:*;
         this.IPTData[_loc82_ = _loc1_++] = ["Cast Iron - Gray","HSS Reamer",0.0005,0.002,0.006,0.008,0.01,0.0125,0.015,0.02,0.0275,0.035,0.035,0.035,0.035];
         var _loc83_:*;
         this.IPTData[_loc83_ = _loc1_++] = ["Cast Iron - Gray","Indexable Drill",0.000125,0.0005,0.0015,0.002,0.0025,0.003125,0.00375,0.0053,0.0073,0.0083,0.0095,0.0101,0.0101];
         var _loc84_:*;
         this.IPTData[_loc84_ = _loc1_++] = ["Cast Iron - Gray","Cobalt Twist Drill",0.0005,0.0015,0.002,0.0025,0.004,0.0055,0.006,0.0085,0.011,0.0125,0.0125,0.0125,0.0125];
         var _loc85_:*;
         this.IPTData[_loc85_ = _loc1_++] = ["Cast Iron - Gray","HP HSS Endmill",0.00022,0.00044,0.00066,0.0011,0.00154,0.00176,0.00352,0.00528,0.00528,0.00528,0.00528,0.00528,0.00528];
         var _loc86_:*;
         this.IPTData[_loc86_ = _loc1_++] = ["Cast Iron - Gray","HP HSS Twist Drill",0.00055,0.00165,0.0022,0.00275,0.0044,0.00605,0.0066,0.00935,0.0121,0.01375,0.01375,0.01375,0.01375];
         var _loc87_:*;
         this.IPTData[_loc87_ = _loc1_++] = ["Cast Iron - Gray","HP Carbide Endmill",0.00024,0.00048,0.00072,0.0012,0.00168,0.00192,0.00384,0.00576,0.00576,0.00576,0.00576,0.00576,0.00576];
         var _loc88_:*;
         this.IPTData[_loc88_ = _loc1_++] = ["Cast Iron - Gray","TiAlN Carbide Endmill",0.00024,0.00048,0.00072,0.0012,0.00168,0.00192,0.00384,0.00576,0.00576,0.00576,0.00576,0.00576,0.00576];
         var _loc89_:*;
         this.IPTData[_loc89_ = _loc1_++] = ["Cast Iron - Gray","HP Carbide Twist Drill",0.00055,0.00165,0.0022,0.00275,0.0044,0.00605,0.0066,0.00935,0.0121,0.01375,0.01375,0.01375,0.01375];
         var _loc90_:*;
         this.IPTData[_loc90_ = _loc1_++] = ["Cast Iron - Gray","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.007,0.007,0.007,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc91_:*;
         this.IPTData[_loc91_ = _loc1_++] = ["Cast Iron - Gray","Turning: HSS",0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015];
         var _loc92_:*;
         this.IPTData[_loc92_ = _loc1_++] = ["Cast Iron - Gray","Turning: Carbide",0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015];
         var _loc93_:*;
         this.IPTData[_loc93_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","HSS Spot Drill",0.00025,0.0005,0.00075,0.001,0.001375,0.00175,0.0025,0.003,0.00375,0.0045,0.0045,0.0045,0.0045];
         var _loc94_:*;
         this.IPTData[_loc94_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","HSS Twist Drill",0.0005,0.001,0.0015,0.002,0.00275,0.0035,0.005,0.006,0.0075,0.009,0.009,0.009,0.009];
         var _loc95_:*;
         this.IPTData[_loc95_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","Carbide Twist Drill",0.00025,0.0005,0.00075,0.001,0.001375,0.00175,0.0025,0.003,0.00375,0.0045,0.0045,0.0045,0.0045];
         var _loc96_:*;
         this.IPTData[_loc96_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.003,0.004,0.005,0.01,0.015,0.02,0.025,0.03,0.035];
         var _loc97_:*;
         this.IPTData[_loc97_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0005,0.0006,0.0009,0.0012,0.0013,0.0015,0.0015,0.0015,0.0015];
         var _loc98_:*;
         this.IPTData[_loc98_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","HSS Endmill",0.000375,0.0006,0.000675,0.00075,0.001125,0.0015,0.003,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc99_:*;
         this.IPTData[_loc99_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","Carbide Endmill",0.0005,0.0008,0.0009,0.001,0.0015,0.002,0.004,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc100_:*;
         this.IPTData[_loc100_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","HSS Reamer",0.0005,0.002,0.004,0.004,0.004,0.005,0.006,0.0068,0.0084,0.01,0.01,0.01,0.01];
         var _loc101_:*;
         this.IPTData[_loc101_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","Indexable Drill",0.0001,0.0001,0.0001,0.0005,0.001,0.002,0.003,0.004,0.005,0.0065,0.007,0.008,0.008];
         var _loc102_:*;
         this.IPTData[_loc102_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","Cobalt Twist Drill",0.0005,0.001,0.0015,0.002,0.00275,0.0035,0.005,0.006,0.0075,0.009,0.009,0.009,0.009];
         var _loc103_:*;
         this.IPTData[_loc103_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","HP HSS Endmill",0.0004125,0.00066,0.0007425,0.000825,0.0012375,0.00165,0.0033,0.00495,0.00495,0.00495,0.00495,0.00495,0.00495];
         var _loc104_:*;
         this.IPTData[_loc104_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","HP HSS Twist Drill",0.00055,0.0011,0.00165,0.0022,0.003025,0.00385,0.0055,0.0066,0.00825,0.0099,0.0099,0.0099,0.0099];
         var _loc105_:*;
         this.IPTData[_loc105_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","HP Carbide Endmill",0.00045,0.00072,0.00081,0.0009,0.00135,0.0018,0.0036,0.0054,0.0054,0.0054,0.0054,0.0054,0.0054];
         var _loc106_:*;
         this.IPTData[_loc106_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","TiAlN Carbide Endmill",0.00045,0.00072,0.00081,0.0009,0.00135,0.0018,0.0036,0.0054,0.0054,0.0054,0.0054,0.0054,0.0054];
         var _loc107_:*;
         this.IPTData[_loc107_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","HP Carbide Twist Drill",0.00055,0.0011,0.00165,0.0022,0.003025,0.00385,0.0055,0.0066,0.00825,0.0099,0.0099,0.0099,0.0099];
         var _loc108_:*;
         this.IPTData[_loc108_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.007,0.007,0.007,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc109_:*;
         this.IPTData[_loc109_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","Turning: HSS",0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014];
         var _loc110_:*;
         this.IPTData[_loc110_ = _loc1_++] = ["Cobalt Chrome (CoCr ASTM F75)","Turning: Carbide",0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014];
         var _loc111_:*;
         this.IPTData[_loc111_ = _loc1_++] = ["Composite: Fiberglass/PC Board","HSS Spot Drill",0.0006,0.00276428571428571,0.002875,0.0040625,0.00525,0.007375,0.0081875,0.009,0.009,0.009,0.009,0.009,0.009];
         var _loc112_:*;
         this.IPTData[_loc112_ = _loc1_++] = ["Composite: Fiberglass/PC Board","HSS Twist Drill",0.0012,0.00552857142857143,0.00575,0.008125,0.0105,0.01475,0.016375,0.018,0.018,0.018,0.018,0.018,0.018];
         var _loc113_:*;
         this.IPTData[_loc113_ = _loc1_++] = ["Composite: Fiberglass/PC Board","Carbide Twist Drill",0.0012,0.00552857142857143,0.00575,0.008125,0.0105,0.01475,0.016375,0.018,0.018,0.018,0.018,0.018,0.018];
         var _loc114_:*;
         this.IPTData[_loc114_ = _loc1_++] = ["Composite: Fiberglass/PC Board","HSS Spade Drill",0.0024,0.0110571428571429,0.0115,0.01625,0.021,0.0295,0.03275,0.036,0.036,0.036,0.036,0.036,0.036];
         var _loc115_:*;
         this.IPTData[_loc115_ = _loc1_++] = ["Composite: Fiberglass/PC Board","Gun Drill",0.00008,0.000368571428571429,0.000383333333333333,0.000541666666666667,0.0007,0.000983333333333333,0.00109166666666667,0.0012,0.0012,0.0012,0.0012,0.0012,0.0012];
         var _loc116_:*;
         this.IPTData[_loc116_ = _loc1_++] = ["Composite: Fiberglass/PC Board","HSS Endmill",0.00096,0.00442285714285714,0.0046,0.0065,0.0084,0.0118,0.0131,0.0144,0.0144,0.0144,0.0144,0.0144,0.0144];
         var _loc117_:*;
         this.IPTData[_loc117_ = _loc1_++] = ["Composite: Fiberglass/PC Board","Carbide Endmill",0.0008,0.00368571428571429,0.00383333333333333,0.00541666666666667,0.007,0.00983333333333333,0.0109166666666667,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc118_:*;
         this.IPTData[_loc118_ = _loc1_++] = ["Composite: Fiberglass/PC Board","HSS Reamer",0.00188,0.00866142857142857,0.00900833333333333,0.0127291666666667,0.01645,0.0231083333333333,0.0256541666666667,0.0282,0.0282,0.0282,0.0282,0.0282,0.0282];
         var _loc119_:*;
         this.IPTData[_loc119_ = _loc1_++] = ["Composite: Fiberglass/PC Board","Indexable Drill",0.0004,0.00184285714285714,0.00191666666666667,0.00270833333333333,0.0035,0.00491666666666667,0.00545833333333333,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc120_:*;
         this.IPTData[_loc120_ = _loc1_++] = ["Composite: Fiberglass/PC Board","Cobalt Twist Drill",0.0012,0.00552857142857143,0.00575,0.008125,0.0105,0.01475,0.016375,0.018,0.018,0.018,0.018,0.018,0.018];
         var _loc121_:*;
         this.IPTData[_loc121_ = _loc1_++] = ["Composite: Fiberglass/PC Board","HP HSS Endmill",0.001056,0.00486514285714286,0.00506,0.00715,0.00924,0.01298,0.01441,0.01584,0.01584,0.01584,0.01584,0.01584,0.01584];
         var _loc122_:*;
         this.IPTData[_loc122_ = _loc1_++] = ["Composite: Fiberglass/PC Board","HP HSS Twist Drill",0.00132,0.00608142857142857,0.006325,0.0089375,0.01155,0.016225,0.0180125,0.0198,0.0198,0.0198,0.0198,0.0198,0.0198];
         var _loc123_:*;
         this.IPTData[_loc123_ = _loc1_++] = ["Composite: Fiberglass/PC Board","HP Carbide Endmill",0.001152,0.00530742857142857,0.00552,0.0078,0.01008,0.01416,0.01572,0.01728,0.01728,0.01728,0.01728,0.01728,0.01728];
         var _loc124_:*;
         this.IPTData[_loc124_ = _loc1_++] = ["Composite: Fiberglass/PC Board","TiAlN Carbide Endmill",0.001152,0.00530742857142857,0.00552,0.0078,0.01008,0.01416,0.01572,0.01728,0.01728,0.01728,0.01728,0.01728,0.01728];
         var _loc125_:*;
         this.IPTData[_loc125_ = _loc1_++] = ["Composite: Fiberglass/PC Board","HP Carbide Twist Drill",0.00132,0.00608142857142857,0.006325,0.0089375,0.01155,0.016225,0.0180125,0.0198,0.0198,0.0198,0.0198,0.0198,0.0198];
         var _loc126_:*;
         this.IPTData[_loc126_ = _loc1_++] = ["Composite: Fiberglass/PC Board","Indexable End Or Face Mill",0.0028,0.0129,0.0134166666666667,0.0189583333333333,0.0245,0.0344166666666667,0.0382083333333333,0.042,0.042,0.042,0.042,0.042,0.042];
         var _loc127_:*;
         this.IPTData[_loc127_ = _loc1_++] = ["Composite: Fiberglass/PC Board","Turning: HSS",0.0072,0.0331714285714286,0.0345,0.04875,0.063,0.0885,0.09825,0.108,0.108,0.108,0.108,0.108,0.108];
         var _loc128_:*;
         this.IPTData[_loc128_ = _loc1_++] = ["Composite: Fiberglass/PC Board","Turning: Carbide",0.0072,0.0331714285714286,0.0345,0.04875,0.063,0.0885,0.09825,0.108,0.108,0.108,0.108,0.108,0.108];
         var _loc129_:*;
         this.IPTData[_loc129_ = _loc1_++] = ["Copper Alloy - Wrought","HSS Spot Drill",0.00025,0.00075,0.001,0.00125,0.00175,0.00225,0.0025,0.0035,0.0045,0.00525,0.00525,0.00525,0.00525];
         var _loc130_:*;
         this.IPTData[_loc130_ = _loc1_++] = ["Copper Alloy - Wrought","HSS Twist Drill",0.0005,0.0015,0.002,0.0025,0.0035,0.0045,0.005,0.007,0.009,0.0105,0.0105,0.0105,0.0105];
         var _loc131_:*;
         this.IPTData[_loc131_ = _loc1_++] = ["Copper Alloy - Wrought","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc132_:*;
         this.IPTData[_loc132_ = _loc1_++] = ["Copper Alloy - Wrought","HSS Spade Drill",0.0005,0.002,0.003,0.004,0.006,0.008,0.01,0.01,0.0115,0.013,0.018,0.024,0.03];
         var _loc133_:*;
         this.IPTData[_loc133_ = _loc1_++] = ["Copper Alloy - Wrought","Gun Drill",0.0001,0.0001,0.0002,0.0003,0.0004,0.0005,0.0009,0.0012,0.00145,0.0017,0.0017,0.0017,0.0017];
         var _loc134_:*;
         this.IPTData[_loc134_ = _loc1_++] = ["Copper Alloy - Wrought","HSS Endmill",0.0005,0.001,0.0015,0.002,0.0025,0.003,0.004,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc135_:*;
         this.IPTData[_loc135_ = _loc1_++] = ["Copper Alloy - Wrought","Carbide Endmill",0.0005,0.001,0.0015,0.002,0.0025,0.003,0.004,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc136_:*;
         this.IPTData[_loc136_ = _loc1_++] = ["Copper Alloy - Wrought","HSS Reamer",0.001,0.002,0.006,0.007,0.008,0.0103,0.015,0.0175,0.0225,0.03,0.03,0.03,0.03];
         var _loc137_:*;
         this.IPTData[_loc137_ = _loc1_++] = ["Copper Alloy - Wrought","Indexable Drill",0.00027,0.00054,0.00162,0.00189,0.00216,0.002781,0.00405,0.0047,0.0063,0.0069,0.007,0.0078,0.0078];
         var _loc138_:*;
         this.IPTData[_loc138_ = _loc1_++] = ["Copper Alloy - Wrought","Cobalt Twist Drill",0.0005,0.0015,0.002,0.0025,0.0035,0.0045,0.005,0.007,0.009,0.0105,0.0105,0.0105,0.0105];
         var _loc139_:*;
         this.IPTData[_loc139_ = _loc1_++] = ["Copper Alloy - Wrought","HP HSS Endmill",0.00055,0.0011,0.00165,0.0022,0.00275,0.0033,0.0044,0.0055,0.0055,0.0055,0.0055,0.0055,0.0055];
         var _loc140_:*;
         this.IPTData[_loc140_ = _loc1_++] = ["Copper Alloy - Wrought","HP HSS Twist Drill",0.00055,0.00165,0.0022,0.00275,0.00385,0.00495,0.0055,0.0077,0.0099,0.01155,0.01155,0.01155,0.01155];
         var _loc141_:*;
         this.IPTData[_loc141_ = _loc1_++] = ["Copper Alloy - Wrought","HP Carbide Endmill",0.0006,0.0012,0.0018,0.0024,0.003,0.0036,0.0048,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc142_:*;
         this.IPTData[_loc142_ = _loc1_++] = ["Copper Alloy - Wrought","TiAlN Carbide Endmill",0.0006,0.0012,0.0018,0.0024,0.003,0.0036,0.0048,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc143_:*;
         this.IPTData[_loc143_ = _loc1_++] = ["Copper Alloy - Wrought","HP Carbide Twist Drill",0.00055,0.00165,0.0022,0.00275,0.00385,0.00495,0.0055,0.0077,0.0099,0.01155,0.01155,0.01155,0.01155];
         var _loc144_:*;
         this.IPTData[_loc144_ = _loc1_++] = ["Copper Alloy - Wrought","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.007,0.007,0.007,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc145_:*;
         this.IPTData[_loc145_ = _loc1_++] = ["Copper Alloy - Wrought","Turning: Carbide HSS",0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01];
         var _loc146_:*;
         this.IPTData[_loc146_ = _loc1_++] = ["Copper Alloy - Wrought","Turning: Carbide",0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01];
         var _loc147_:*;
         this.IPTData[_loc147_ = _loc1_++] = ["Graphite","HSS Spot Drill",0.00045,0.0015,0.00225,0.00375,0.00426,0.005,0.00594,0.0076,0.0095,0.011875,0.011875,0.011875,0.011875];
         var _loc148_:*;
         this.IPTData[_loc148_ = _loc1_++] = ["Graphite","HSS Twist Drill",0.0009,0.003,0.0045,0.0075,0.00852,0.01,0.01188,0.0152,0.019,0.02375,0.02375,0.02375,0.02375];
         var _loc149_:*;
         this.IPTData[_loc149_ = _loc1_++] = ["Graphite","Carbide Twist Drill",0.0009,0.003,0.0045,0.0075,0.00852,0.01,0.01188,0.0152,0.019,0.02375,0.02375,0.02375,0.02375];
         var _loc150_:*;
         this.IPTData[_loc150_ = _loc1_++] = ["Graphite","HSS Spade Drill",0.0018,0.006,0.009,0.015,0.01704,0.026,0.03168,0.0361,0.0418,0.0475,0.057,0.0703,0.0798];
         var _loc151_:*;
         this.IPTData[_loc151_ = _loc1_++] = ["Graphite","Gun Drill",0.00018,0.0004,0.000675,0.001,0.001917,0.0026,0.00495,0.00665,0.00722,0.0076,0.0076,0.0076,0.0076];
         var _loc152_:*;
         this.IPTData[_loc152_ = _loc1_++] = ["Graphite","HSS Endmill",0.00108,0.0024,0.00405,0.006,0.007668,0.0098,0.014454,0.0171,0.0171,0.0171,0.0171,0.0171,0.0171];
         var _loc153_:*;
         this.IPTData[_loc153_ = _loc1_++] = ["Graphite","Carbide Endmill",0.0009,0.002,0.003375,0.005,0.00639,0.008,0.01188,0.01425,0.01425,0.01425,0.01425,0.01425,0.01425];
         var _loc154_:*;
         this.IPTData[_loc154_ = _loc1_++] = ["Graphite","HSS Reamer",0.0009,0.004,0.009,0.01175,0.01278,0.0146,0.0198,0.02375,0.03135,0.038,0.038,0.038,0.038];
         var _loc155_:*;
         this.IPTData[_loc155_ = _loc1_++] = ["Graphite","Indexable Drill",0.00045,0.0005,0.0005625,0.00125,0.001065,0.002,0.002475,0.01121,0.01463,0.01615,0.01824,0.01919,0.01919];
         var _loc156_:*;
         this.IPTData[_loc156_ = _loc1_++] = ["Graphite","Cobalt Twist Drill",0.0009,0.003,0.0045,0.0075,0.00852,0.01,0.01188,0.0152,0.019,0.02375,0.02375,0.02375,0.02375];
         var _loc157_:*;
         this.IPTData[_loc157_ = _loc1_++] = ["Graphite","HP HSS Endmill",0.001188,0.00264,0.004455,0.0066,0.0084348,0.01078,0.0158994,0.01881,0.01881,0.01881,0.01881,0.01881,0.01881];
         var _loc158_:*;
         this.IPTData[_loc158_ = _loc1_++] = ["Graphite","HP HSS Twist Drill",0.00099,0.0033,0.00495,0.00825,0.009372,0.011,0.013068,0.01672,0.0209,0.026125,0.026125,0.026125,0.026125];
         var _loc159_:*;
         this.IPTData[_loc159_ = _loc1_++] = ["Graphite","HP Carbide Endmill",0.001296,0.00288,0.00486,0.0072,0.0092016,0.01176,0.0173448,0.02052,0.02052,0.02052,0.02052,0.02052,0.02052];
         var _loc160_:*;
         this.IPTData[_loc160_ = _loc1_++] = ["Graphite","TiAlN Carbide Endmill",0.001296,0.00288,0.00486,0.0072,0.0092016,0.01176,0.0173448,0.02052,0.02052,0.02052,0.02052,0.02052,0.02052];
         var _loc161_:*;
         this.IPTData[_loc161_ = _loc1_++] = ["Graphite","HP Carbide Twist Drill",0.00099,0.0033,0.00495,0.00825,0.009372,0.011,0.013068,0.01672,0.0209,0.026125,0.026125,0.026125,0.026125];
         var _loc162_:*;
         this.IPTData[_loc162_ = _loc1_++] = ["Graphite","Indexable End Or Face Mill",0.0126,0.014,0.01575,0.0175,0.01491,0.014,0.01386,0.0152,0.0152,0.0152,0.0152,0.0152,0.0152];
         var _loc163_:*;
         this.IPTData[_loc163_ = _loc1_++] = ["Graphite","Turning: HSS",0.0324,0.036,0.0405,0.045,0.03834,0.036,0.03564,0.0342,0.0342,0.0342,0.0342,0.0342,0.0342];
         var _loc164_:*;
         this.IPTData[_loc164_ = _loc1_++] = ["Graphite","Turning: Carbide",0.0324,0.036,0.0405,0.045,0.03834,0.036,0.03564,0.0342,0.0342,0.0342,0.0342,0.0342,0.0342];
         var _loc165_:*;
         this.IPTData[_loc165_ = _loc1_++] = ["High Temp Nickel Alloy","HSS Spot Drill",0.00025,0.00075,0.001,0.00125,0.00175,0.00225,0.003,0.0035,0.0045,0.00525,0.00525,0.00525,0.00525];
         var _loc166_:*;
         this.IPTData[_loc166_ = _loc1_++] = ["High Temp Nickel Alloy","HSS Twist Drill",0.0005,0.0015,0.002,0.0025,0.0035,0.0045,0.006,0.007,0.009,0.0105,0.0105,0.0105,0.0105];
         var _loc167_:*;
         this.IPTData[_loc167_ = _loc1_++] = ["High Temp Nickel Alloy","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.002905,0.003735,0.0043575,0.0043575,0.0043575,0.0043575];
         var _loc168_:*;
         this.IPTData[_loc168_ = _loc1_++] = ["High Temp Nickel Alloy","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.0015,0.0025,0.006,0.008,0.01,0.015,0.018,0.022,0.025];
         var _loc169_:*;
         this.IPTData[_loc169_ = _loc1_++] = ["High Temp Nickel Alloy","Gun Drill",0.0001,0.0001,0.0002,0.0003,0.0004,0.0005,0.0007,0.0009,0.001,0.0012,0.0012,0.0012,0.0012];
         var _loc170_:*;
         this.IPTData[_loc170_ = _loc1_++] = ["High Temp Nickel Alloy","HSS Endmill",0.0003,0.0005,0.0007,0.001,0.0015,0.002,0.003,0.004,0.004,0.004,0.004,0.004,0.004];
         var _loc171_:*;
         this.IPTData[_loc171_ = _loc1_++] = ["High Temp Nickel Alloy","Carbide Endmill",0.0003,0.0005,0.0007,0.001,0.0015,0.002,0.003,0.004,0.004,0.004,0.004,0.004,0.004];
         var _loc172_:*;
         this.IPTData[_loc172_ = _loc1_++] = ["High Temp Nickel Alloy","HSS Reamer",0.0012,0.002,0.006,0.007,0.008,0.009,0.01,0.0125,0.0165,0.02,0.02,0.02,0.02];
         var _loc173_:*;
         this.IPTData[_loc173_ = _loc1_++] = ["High Temp Nickel Alloy","Indexable Drill",0.002,0.002,0.002,0.002,0.002,0.002,0.002,0.002,0.0052,0.0064,0.0075,0.008,0.008];
         var _loc174_:*;
         this.IPTData[_loc174_ = _loc1_++] = ["High Temp Nickel Alloy","Cobalt Twist Drill",0.0005,0.0015,0.002,0.0025,0.0035,0.0045,0.006,0.007,0.009,0.0105,0.0105,0.0105,0.0105];
         var _loc175_:*;
         this.IPTData[_loc175_ = _loc1_++] = ["High Temp Nickel Alloy","HP HSS Endmill",0.00033,0.00055,0.00077,0.0011,0.00165,0.0022,0.0033,0.0044,0.0044,0.0044,0.0044,0.0044,0.0044];
         var _loc176_:*;
         this.IPTData[_loc176_ = _loc1_++] = ["High Temp Nickel Alloy","HP HSS Twist Drill",0.00055,0.00165,0.0022,0.00275,0.00385,0.00495,0.0066,0.0077,0.0099,0.01155,0.01155,0.01155,0.01155];
         var _loc177_:*;
         this.IPTData[_loc177_ = _loc1_++] = ["High Temp Nickel Alloy","HP Carbide Endmill",0.00036,0.0006,0.00084,0.0012,0.0018,0.0024,0.0036,0.0048,0.0048,0.0048,0.0048,0.0048,0.0048];
         var _loc178_:*;
         this.IPTData[_loc178_ = _loc1_++] = ["High Temp Nickel Alloy","TiAlN Carbide Endmill",0.00036,0.0006,0.00084,0.0012,0.0018,0.0024,0.0036,0.0048,0.0048,0.0048,0.0048,0.0048,0.0048];
         var _loc179_:*;
         this.IPTData[_loc179_ = _loc1_++] = ["High Temp Nickel Alloy","HP Carbide Twist Drill",0.00055,0.00165,0.0022,0.00275,0.00385,0.00495,0.0066,0.0077,0.0099,0.01155,0.01155,0.01155,0.01155];
         var _loc180_:*;
         this.IPTData[_loc180_ = _loc1_++] = ["High Temp Nickel Alloy","Indexable End Or Face Mill",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.007,0.007,0.007,0.007,0.007,0.007];
         var _loc181_:*;
         this.IPTData[_loc181_ = _loc1_++] = ["High Temp Nickel Alloy","Turning: HSS",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc182_:*;
         this.IPTData[_loc182_ = _loc1_++] = ["High Temp Nickel Alloy","Turning: Carbide",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc183_:*;
         this.IPTData[_loc183_ = _loc1_++] = ["Magnesium Alloy","HSS Spot Drill",0.00025,0.00075,0.001,0.0015,0.002,0.0025,0.003,0.004,0.005,0.00625,0.00625,0.00625,0.00625];
         var _loc184_:*;
         this.IPTData[_loc184_ = _loc1_++] = ["Magnesium Alloy","HSS Twist Drill",0.0005,0.0015,0.002,0.003,0.004,0.005,0.006,0.008,0.01,0.0125,0.0125,0.0125,0.0125];
         var _loc185_:*;
         this.IPTData[_loc185_ = _loc1_++] = ["Magnesium Alloy","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc186_:*;
         this.IPTData[_loc186_ = _loc1_++] = ["Magnesium Alloy","HSS Spade Drill",0.001,0.003,0.004,0.006,0.008,0.01,0.011,0.016,0.0195,0.023,0.033,0.042,0.05];
         var _loc187_:*;
         this.IPTData[_loc187_ = _loc1_++] = ["Magnesium Alloy","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0008,0.0012,0.0025,0.0035,0.004,0.0045,0.0045,0.0045,0.0045];
         var _loc188_:*;
         this.IPTData[_loc188_ = _loc1_++] = ["Magnesium Alloy","HSS Endmill",0.0006,0.0012,0.0018,0.0025,0.0037,0.0049,0.0086,0.0117,0.0117,0.0117,0.0117,0.0117,0.0117];
         var _loc189_:*;
         this.IPTData[_loc189_ = _loc1_++] = ["Magnesium Alloy","Carbide Endmill",0.0005,0.001,0.0015,0.002,0.003,0.004,0.007,0.0095,0.0095,0.0095,0.0095,0.0095,0.0095];
         var _loc190_:*;
         this.IPTData[_loc190_ = _loc1_++] = ["Magnesium Alloy","HSS Reamer",0.001,0.002,0.005,0.0057,0.007,0.0085,0.01,0.0125,0.0175,0.025,0.025,0.025,0.025];
         var _loc191_:*;
         this.IPTData[_loc191_ = _loc1_++] = ["Magnesium Alloy","Indexable Drill",0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.0059,0.0077,0.0087,0.0102,0.011,0.011];
         var _loc192_:*;
         this.IPTData[_loc192_ = _loc1_++] = ["Magnesium Alloy","Cobalt Twist Drill",0.0005,0.0015,0.002,0.003,0.004,0.005,0.006,0.008,0.01,0.0125,0.0125,0.0125,0.0125];
         var _loc193_:*;
         this.IPTData[_loc193_ = _loc1_++] = ["Magnesium Alloy","HP HSS Endmill",0.00066,0.00132,0.00198,0.00275,0.00407,0.00539,0.00946,0.01287,0.01287,0.01287,0.01287,0.01287,0.01287];
         var _loc194_:*;
         this.IPTData[_loc194_ = _loc1_++] = ["Magnesium Alloy","HP HSS Twist Drill",0.00055,0.00165,0.0022,0.0033,0.0044,0.0055,0.0066,0.0088,0.011,0.01375,0.01375,0.01375,0.01375];
         var _loc195_:*;
         this.IPTData[_loc195_ = _loc1_++] = ["Magnesium Alloy","HP Carbide Endmill",0.00072,0.00144,0.00216,0.003,0.00444,0.00588,0.01032,0.01404,0.01404,0.01404,0.01404,0.01404,0.01404];
         var _loc196_:*;
         this.IPTData[_loc196_ = _loc1_++] = ["Magnesium Alloy","TiAlN Carbide Endmill",0.00072,0.00144,0.00216,0.003,0.00444,0.00588,0.01032,0.01404,0.01404,0.01404,0.01404,0.01404,0.01404];
         var _loc197_:*;
         this.IPTData[_loc197_ = _loc1_++] = ["Magnesium Alloy","HP Carbide Twist Drill",0.00055,0.00165,0.0022,0.0033,0.0044,0.0055,0.0066,0.0088,0.011,0.01375,0.01375,0.01375,0.01375];
         var _loc198_:*;
         this.IPTData[_loc198_ = _loc1_++] = ["Magnesium Alloy","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.007,0.007,0.007,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc199_:*;
         this.IPTData[_loc199_ = _loc1_++] = ["Magnesium Alloy","Turning: HSS",0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018];
         var _loc200_:*;
         this.IPTData[_loc200_ = _loc1_++] = ["Magnesium Alloy","Turning: Carbide",0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018,0.018];
         var _loc201_:*;
         this.IPTData[_loc201_ = _loc1_++] = ["Nickel Alloy","HSS Spot Drill",0.00025,0.00075,0.001,0.00125,0.00175,0.00225,0.003,0.0035,0.0045,0.00525,0.00525,0.00525,0.00525];
         var _loc202_:*;
         this.IPTData[_loc202_ = _loc1_++] = ["Nickel Alloy","HSS Twist Drill",0.0005,0.0015,0.002,0.0025,0.0035,0.0045,0.006,0.007,0.009,0.0105,0.0105,0.0105,0.0105];
         var _loc203_:*;
         this.IPTData[_loc203_ = _loc1_++] = ["Nickel Alloy","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.002905,0.003735,0.0043575,0.0043575,0.0043575,0.0043575];
         var _loc204_:*;
         this.IPTData[_loc204_ = _loc1_++] = ["Nickel Alloy","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.0015,0.002,0.0025,0.006,0.008,0.01,0.016,0.02,0.025];
         var _loc205_:*;
         this.IPTData[_loc205_ = _loc1_++] = ["Nickel Alloy","Gun Drill",0.0001,0.0001,0.0002,0.0003,0.0004,0.0005,0.0007,0.0009,0.001,0.0012,0.0012,0.0012,0.0012];
         var _loc206_:*;
         this.IPTData[_loc206_ = _loc1_++] = ["Nickel Alloy","HSS Endmill",0.0003,0.0005,0.0007,0.001,0.0015,0.002,0.003,0.004,0.004,0.004,0.004,0.004,0.004];
         var _loc207_:*;
         this.IPTData[_loc207_ = _loc1_++] = ["Nickel Alloy","Carbide Endmill",0.0003,0.0005,0.0007,0.001,0.0015,0.002,0.003,0.004,0.004,0.004,0.004,0.004,0.004];
         var _loc208_:*;
         this.IPTData[_loc208_ = _loc1_++] = ["Nickel Alloy","HSS Reamer",0.001,0.002,0.006,0.007,0.008,0.009,0.01,0.0125,0.0165,0.02,0.02,0.02,0.02];
         var _loc209_:*;
         this.IPTData[_loc209_ = _loc1_++] = ["Nickel Alloy","Indexable Drill",0.0001,0.0001,0.0001,0.0002,0.0005,0.001,0.0015,0.002,0.0025,0.003,0.003,0.004,0.004];
         var _loc210_:*;
         this.IPTData[_loc210_ = _loc1_++] = ["Nickel Alloy","Cobalt Twist Drill",0.0005,0.0015,0.002,0.0025,0.0035,0.0045,0.006,0.007,0.009,0.0105,0.0105,0.0105,0.0105];
         var _loc211_:*;
         this.IPTData[_loc211_ = _loc1_++] = ["Nickel Alloy","HP HSS Endmill",0.00033,0.00055,0.00077,0.0011,0.00165,0.0022,0.0033,0.0044,0.0044,0.0044,0.0044,0.0044,0.0044];
         var _loc212_:*;
         this.IPTData[_loc212_ = _loc1_++] = ["Nickel Alloy","HP HSS Twist Drill",0.00055,0.00165,0.0022,0.00275,0.00385,0.00495,0.0066,0.0077,0.0099,0.01155,0.01155,0.01155,0.01155];
         var _loc213_:*;
         this.IPTData[_loc213_ = _loc1_++] = ["Nickel Alloy","HP Carbide Endmill",0.00036,0.0006,0.00084,0.0012,0.0018,0.0024,0.0036,0.0048,0.0048,0.0048,0.0048,0.0048,0.0048];
         var _loc214_:*;
         this.IPTData[_loc214_ = _loc1_++] = ["Nickel Alloy","TiAlN Carbide Endmill",0.00036,0.0006,0.00084,0.0012,0.0018,0.0024,0.0036,0.0048,0.0048,0.0048,0.0048,0.0048,0.0048];
         var _loc215_:*;
         this.IPTData[_loc215_ = _loc1_++] = ["Nickel Alloy","HP Carbide Twist Drill",0.00055,0.00165,0.0022,0.00275,0.00385,0.00495,0.0066,0.0077,0.0099,0.01155,0.01155,0.01155,0.01155];
         var _loc216_:*;
         this.IPTData[_loc216_ = _loc1_++] = ["Nickel Alloy","Indexable End Or Face Mill",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.007,0.007,0.007,0.007,0.007,0.007];
         var _loc217_:*;
         this.IPTData[_loc217_ = _loc1_++] = ["Nickel Alloy","Turning: HSS",0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc218_:*;
         this.IPTData[_loc218_ = _loc1_++] = ["Nickel Alloy","Turning: Carbide",0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc219_:*;
         this.IPTData[_loc219_ = _loc1_++] = ["Plastics","HSS Spot Drill",0.0004625,0.0013875,0.00185,0.002775,0.0037,0.004625,0.00555,0.0074,0.00925,0.0115625,0.0115625,0.0115625,0.0115625];
         var _loc220_:*;
         this.IPTData[_loc220_ = _loc1_++] = ["Plastics","HSS Twist Drill",0.000925,0.002775,0.0037,0.00555,0.0074,0.00925,0.0111,0.0148,0.0185,0.023125,0.023125,0.023125,0.023125];
         var _loc221_:*;
         this.IPTData[_loc221_ = _loc1_++] = ["Plastics","Carbide Twist Drill",0.000925,0.002775,0.0037,0.00555,0.0074,0.00925,0.0111,0.0148,0.0185,0.023125,0.023125,0.023125,0.023125];
         var _loc222_:*;
         this.IPTData[_loc222_ = _loc1_++] = ["Plastics","HSS Spade Drill",0.00185,0.00555,0.0074,0.0111,0.0148,0.0185,0.02035,0.0222,0.0296,0.037,0.0555,0.06845,0.0777];
         var _loc223_:*;
         this.IPTData[_loc223_ = _loc1_++] = ["Plastics","Gun Drill",0.00037,0.00037,0.00037,0.00037,0.000555,0.000925,0.00148,0.00222,0.00222,0.002775,0.002775,0.002775,0.002775];
         var _loc224_:*;
         this.IPTData[_loc224_ = _loc1_++] = ["Plastics","HSS Endmill",0.00111,0.00222,0.00333,0.00444,0.00666,0.009065,0.013505,0.01665,0.01665,0.01665,0.01665,0.01665,0.01665];
         var _loc225_:*;
         this.IPTData[_loc225_ = _loc1_++] = ["Plastics","Carbide Endmill",0.000925,0.00185,0.002775,0.0037,0.00555,0.0074,0.0111,0.013875,0.013875,0.013875,0.013875,0.013875,0.013875];
         var _loc226_:*;
         this.IPTData[_loc226_ = _loc1_++] = ["Plastics","HSS Reamer",0.000925,0.0037,0.0074,0.008695,0.0111,0.013505,0.0185,0.023125,0.030525,0.037,0.037,0.037,0.037];
         var _loc227_:*;
         this.IPTData[_loc227_ = _loc1_++] = ["Plastics","Indexable Drill",0.000925,0.000925,0.000925,0.00185,0.00185,0.0037,0.004625,0.010915,0.014245,0.015725,0.01776,0.018685,0.018685];
         var _loc228_:*;
         this.IPTData[_loc228_ = _loc1_++] = ["Plastics","Cobalt Twist Drill",0.000925,0.002775,0.0037,0.00555,0.0074,0.00925,0.0111,0.0148,0.0185,0.023125,0.023125,0.023125,0.023125];
         var _loc229_:*;
         this.IPTData[_loc229_ = _loc1_++] = ["Plastics","HP HSS Endmill",0.001221,0.002442,0.003663,0.004884,0.007326,0.0099715,0.0148555,0.018315,0.018315,0.018315,0.018315,0.018315,0.018315];
         var _loc230_:*;
         this.IPTData[_loc230_ = _loc1_++] = ["Plastics","HP HSS Twist Drill",0.0010175,0.0030525,0.00407,0.006105,0.00814,0.010175,0.01221,0.01628,0.02035,0.0254375,0.0254375,0.0254375,0.0254375];
         var _loc231_:*;
         this.IPTData[_loc231_ = _loc1_++] = ["Plastics","HP Carbide Endmill",0.001332,0.002664,0.003996,0.005328,0.007992,0.010878,0.016206,0.01998,0.01998,0.01998,0.01998,0.01998,0.01998];
         var _loc232_:*;
         this.IPTData[_loc232_ = _loc1_++] = ["Plastics","TiAlN Carbide Endmill",0.001332,0.002664,0.003996,0.005328,0.007992,0.010878,0.016206,0.01998,0.01998,0.01998,0.01998,0.01998,0.01998];
         var _loc233_:*;
         this.IPTData[_loc233_ = _loc1_++] = ["Plastics","HP Carbide Twist Drill",0.0010175,0.0030525,0.00407,0.006105,0.00814,0.010175,0.01221,0.01628,0.02035,0.0254375,0.0254375,0.0254375,0.0254375];
         var _loc234_:*;
         this.IPTData[_loc234_ = _loc1_++] = ["Plastics","Indexable End Or Face Mill",0.01295,0.01295,0.01295,0.01295,0.01295,0.01295,0.01295,0.01295,0.01295,0.01295,0.01295,0.01295,0.01295];
         var _loc235_:*;
         this.IPTData[_loc235_ = _loc1_++] = ["Plastics","Turning: HSS",0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333];
         var _loc236_:*;
         this.IPTData[_loc236_ = _loc1_++] = ["Plastics","Turning: Carbide",0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333,0.0333];
         var _loc237_:*;
         this.IPTData[_loc237_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"HSS Spot Drill",0.0009375,0.00189642857142857,0.00271875,0.0033,0.0049375,0.0065,0.00675,0.0121875,0.0225,0.03,0.045,0.06,0.075];
         var _loc238_:*;
         this.IPTData[_loc238_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"HSS Twist Drill",0.001875,0.00379285714285714,0.0054375,0.0066,0.009875,0.013,0.0135,0.024375,0.045,0.06,0.09,0.12,0.15];
         var _loc239_:*;
         this.IPTData[_loc239_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"Carbide Twist Drill",0.001875,0.00379285714285714,0.0054375,0.0066,0.009875,0.013,0.0135,0.024375,0.045,0.06,0.09,0.12,0.15];
         var _loc240_:*;
         this.IPTData[_loc240_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"HSS Spade Drill",0.00375,0.00758571428571429,0.010875,0.0132,0.01975,0.026,0.027,0.04875,0.09,0.12,0.18,0.24,0.3];
         var _loc241_:*;
         this.IPTData[_loc241_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"Gun Drill",0.000125,0.000252857142857143,0.0003625,0.00044,0.000658333333333333,0.000866666666666666,0.0009,0.001625,0.003,0.004,0.006,0.008,0.01];
         var _loc242_:*;
         this.IPTData[_loc242_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"HSS Endmill",0.0015,0.00303428571428571,0.00435,0.00528,0.0079,0.0104,0.0108,0.0195,0.036,0.048,0.072,0.096,0.12];
         var _loc243_:*;
         this.IPTData[_loc243_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"Carbide Endmill",0.00125,0.00252857142857143,0.003625,0.0044,0.00658333333333333,0.00866666666666666,0.009,0.01625,0.03,0.04,0.06,0.08,0.1];
         var _loc244_:*;
         this.IPTData[_loc244_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"HSS Reamer",0.0029375,0.00594214285714286,0.00851875,0.01034,0.0154708333333333,0.0203666666666667,0.02115,0.0381875,0.0705,0.094,0.141,0.188,0.235];
         var _loc245_:*;
         this.IPTData[_loc245_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"Indexable Drill",0.000625,0.00126428571428571,0.0018125,0.0022,0.00329166666666667,0.00433333333333333,0.0045,0.008125,0.015,0.02,0.03,0.04,0.05];
         var _loc246_:*;
         this.IPTData[_loc246_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"Cobalt Twist Drill",0.001875,0.00379285714285714,0.0054375,0.0066,0.009875,0.013,0.0135,0.024375,0.045,0.06,0.09,0.12,0.15];
         var _loc247_:*;
         this.IPTData[_loc247_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"HP HSS Endmill",0.00165,0.00333771428571429,0.004785,0.005808,0.00869,0.01144,0.01188,0.02145,0.0396,0.0528,0.0792,0.1056,0.132];
         var _loc248_:*;
         this.IPTData[_loc248_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"HP HSS Twist Drill",0.0020625,0.00417214285714286,0.00598125,0.00726,0.0108625,0.0143,0.01485,0.0268125,0.0495,0.066,0.099,0.132,0.165];
         var _loc249_:*;
         this.IPTData[_loc249_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"HP Carbide Endmill",0.0018,0.00364114285714286,0.00522,0.006336,0.00948,0.01248,0.01296,0.0234,0.0432,0.0576,0.0864,0.1152,0.144];
         var _loc250_:*;
         this.IPTData[_loc250_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"TiAlN Carbide Endmill",0.0018,0.00364114285714286,0.00522,0.006336,0.00948,0.01248,0.01296,0.0234,0.0432,0.0576,0.0864,0.1152,0.144];
         var _loc251_:*;
         this.IPTData[_loc251_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"HP Carbide Twist Drill",0.0020625,0.00417214285714286,0.00598125,0.00726,0.0108625,0.0143,0.01485,0.0268125,0.0495,0.066,0.099,0.132,0.165];
         var _loc252_:*;
         this.IPTData[_loc252_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"Indexable End Or Face Mill",0.004375,0.00885,0.0126875,0.0154,0.0230416666666667,0.0303333333333333,0.0315,0.056875,0.105,0.14,0.21,0.28,0.35];
         var _loc253_:*;
         this.IPTData[_loc253_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"Turning: HSS",0.01125,0.0227571428571429,0.032625,0.0396,0.05925,0.078,0.081,0.14625,0.27,0.36,0.54,0.72,0.9];
         var _loc254_:*;
         this.IPTData[_loc254_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_HARD,"Turning: Carbide",0.01125,0.0227571428571429,0.032625,0.0396,0.05925,0.078,0.081,0.14625,0.27,0.36,0.54,0.72,0.9];
         var _loc255_:*;
         this.IPTData[_loc255_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"HSS Spot Drill",0.001875,0.0039,0.0054375,0.0075,0.00975,0.012375,0.0225,0.03,0.045,0.06,0.09,0.12,0.15];
         var _loc256_:*;
         this.IPTData[_loc256_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"HSS Twist Drill",0.00375,0.0078,0.010875,0.015,0.0195,0.02475,0.045,0.06,0.09,0.12,0.18,0.24,0.3];
         var _loc257_:*;
         this.IPTData[_loc257_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"Carbide Twist Drill",0.00375,0.0078,0.010875,0.015,0.0195,0.02475,0.045,0.06,0.09,0.12,0.18,0.24,0.3];
         var _loc258_:*;
         this.IPTData[_loc258_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"HSS Spade Drill",0.0075,0.0156,0.02175,0.03,0.039,0.0495,0.09,0.12,0.18,0.24,0.36,0.48,0.6];
         var _loc259_:*;
         this.IPTData[_loc259_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"Gun Drill",0.00025,0.00052,0.000725,0.001,0.0013,0.00165,0.003,0.004,0.006,0.008,0.012,0.016,0.02];
         var _loc260_:*;
         this.IPTData[_loc260_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"HSS Endmill",0.003,0.00624,0.0087,0.012,0.0156,0.0198,0.036,0.048,0.072,0.096,0.144,0.192,0.24];
         var _loc261_:*;
         this.IPTData[_loc261_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"Carbide Endmill",0.0025,0.0052,0.00725,0.01,0.013,0.0165,0.03,0.04,0.06,0.08,0.12,0.16,0.2];
         var _loc262_:*;
         this.IPTData[_loc262_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"HSS Reamer",0.005875,0.01222,0.0170375,0.0235,0.03055,0.038775,0.0705,0.094,0.141,0.188,0.282,0.376,0.47];
         var _loc263_:*;
         this.IPTData[_loc263_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"Indexable Drill",0.00125,0.0026,0.003625,0.005,0.0065,0.00825,0.015,0.02,0.03,0.04,0.06,0.08,0.1];
         var _loc264_:*;
         this.IPTData[_loc264_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"Cobalt Twist Drill",0.00375,0.0078,0.010875,0.015,0.0195,0.02475,0.045,0.06,0.09,0.12,0.18,0.24,0.3];
         var _loc265_:*;
         this.IPTData[_loc265_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"HP HSS Endmill",0.0033,0.006864,0.00957,0.0132,0.01716,0.02178,0.0396,0.0528,0.0792,0.1056,0.1584,0.2112,0.264];
         var _loc266_:*;
         this.IPTData[_loc266_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"HP HSS Twist Drill",0.004125,0.00858,0.0119625,0.0165,0.02145,0.027225,0.0495,0.066,0.099,0.132,0.198,0.264,0.33];
         var _loc267_:*;
         this.IPTData[_loc267_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"HP Carbide Endmill",0.0036,0.007488,0.01044,0.0144,0.01872,0.02376,0.0432,0.0576,0.0864,0.1152,0.1728,0.2304,0.288];
         var _loc268_:*;
         this.IPTData[_loc268_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"TiAlN Carbide Endmill",0.0036,0.007488,0.01044,0.0144,0.01872,0.02376,0.0432,0.0576,0.0864,0.1152,0.1728,0.2304,0.288];
         var _loc269_:*;
         this.IPTData[_loc269_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"HP Carbide Twist Drill",0.004125,0.00858,0.0119625,0.0165,0.02145,0.027225,0.0495,0.066,0.099,0.132,0.198,0.264,0.33];
         var _loc270_:*;
         this.IPTData[_loc270_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"Indexable End Or Face Mill",0.00875,0.0182,0.025375,0.035,0.0455,0.05775,0.105,0.14,0.21,0.28,0.42,0.56,0.7];
         var _loc271_:*;
         this.IPTData[_loc271_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"Turning: HSS",0.0225,0.0468,0.06525,0.09,0.117,0.1485,0.27,0.36,0.54,0.72,1.08,1.44,1.8];
         var _loc272_:*;
         this.IPTData[_loc272_ = _loc1_++] = [GWizMaterialsDB.PLASTICS_SOFT,"Turning: Carbide",0.0225,0.0468,0.06525,0.09,0.117,0.1485,0.27,0.36,0.54,0.72,1.08,1.44,1.8];
         var _loc273_:*;
         this.IPTData[_loc273_ = _loc1_++] = ["Stainless - 300 Series (316)","HSS Spot Drill",0.00025,0.0005,0.00075,0.001,0.00125,0.0015,0.002,0.0025,0.003,0.0035,0.0035,0.0035,0.0035];
         var _loc274_:*;
         this.IPTData[_loc274_ = _loc1_++] = ["Stainless - 300 Series (316)","HSS Twist Drill",0.0005,0.001,0.0015,0.002,0.0025,0.003,0.004,0.005,0.006,0.007,0.007,0.007,0.007];
         var _loc275_:*;
         this.IPTData[_loc275_ = _loc1_++] = ["Stainless - 300 Series (316)","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc276_:*;
         this.IPTData[_loc276_ = _loc1_++] = ["Stainless - 300 Series (316)","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.003,0.004,0.005,0.01,0.015,0.02,0.025,0.03,0.035];
         var _loc277_:*;
         this.IPTData[_loc277_ = _loc1_++] = ["Stainless - 300 Series (316)","Gun Drill",0.0001,0.0001,0.0002,0.0003,0.0004,0.0005,0.0007,0.0009,0.001,0.0012,0.0012,0.0012,0.0012];
         var _loc278_:*;
         this.IPTData[_loc278_ = _loc1_++] = ["Stainless - 300 Series (316)","HSS Endmill",0.0004,0.0006,0.000675,0.00075,0.001125,0.0015,0.003,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc279_:*;
         this.IPTData[_loc279_ = _loc1_++] = ["Stainless - 300 Series (316)","Carbide Endmill",0.00055,0.0008,0.0009,0.001,0.0015,0.002,0.004,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc280_:*;
         this.IPTData[_loc280_ = _loc1_++] = ["Stainless - 300 Series (316)","HSS Reamer",0.001,0.002,0.003,0.003,0.003,0.0035,0.004,0.005,0.006,0.008,0.008,0.008,0.008];
         var _loc281_:*;
         this.IPTData[_loc281_ = _loc1_++] = ["Stainless - 300 Series (316)","Indexable Drill",0.0001,0.0001,0.0001,0.0005,0.001,0.002,0.003,0.004,0.005,0.0065,0.007,0.008,0.008];
         var _loc282_:*;
         this.IPTData[_loc282_ = _loc1_++] = ["Stainless - 300 Series (316)","Cobalt Twist Drill",0.0005,0.001,0.0015,0.002,0.0025,0.003,0.004,0.005,0.006,0.007,0.007,0.007,0.007];
         var _loc283_:*;
         this.IPTData[_loc283_ = _loc1_++] = ["Stainless - 300 Series (316)","HP HSS Endmill",0.0004125,0.00066,0.0007425,0.000825,0.0012375,0.00165,0.0033,0.00495,0.00495,0.00495,0.00495,0.00495,0.00495];
         var _loc284_:*;
         this.IPTData[_loc284_ = _loc1_++] = ["Stainless - 300 Series (316)","HP HSS Twist Drill",0.00055,0.0011,0.00165,0.0022,0.00275,0.0033,0.0044,0.0055,0.0066,0.0077,0.0077,0.0077,0.0077];
         var _loc285_:*;
         this.IPTData[_loc285_ = _loc1_++] = ["Stainless - 300 Series (316)","HP Carbide Endmill",0.00045,0.00072,0.00081,0.0009,0.00135,0.0018,0.0036,0.0054,0.0054,0.0054,0.0054,0.0054,0.0054];
         var _loc286_:*;
         this.IPTData[_loc286_ = _loc1_++] = ["Stainless - 300 Series (316)","TiAlN Carbide Endmill",0.00045,0.00072,0.00081,0.0009,0.00135,0.0018,0.0036,0.0054,0.0054,0.0054,0.0054,0.0054,0.0054];
         var _loc287_:*;
         this.IPTData[_loc287_ = _loc1_++] = ["Stainless - 300 Series (316)","HP Carbide Twist Drill",0.00055,0.0011,0.00165,0.0022,0.00275,0.0033,0.0044,0.0055,0.0066,0.0077,0.0077,0.0077,0.0077];
         var _loc288_:*;
         this.IPTData[_loc288_ = _loc1_++] = ["Stainless - 300 Series (316)","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.007,0.007,0.007,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc289_:*;
         this.IPTData[_loc289_ = _loc1_++] = ["Stainless - 300 Series (316)","Turning: Carbide HSS",0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014];
         var _loc290_:*;
         this.IPTData[_loc290_ = _loc1_++] = ["Stainless - 300 Series (316)","Turning: Carbide",0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014];
         var _loc291_:*;
         this.IPTData[_loc291_ = _loc1_++] = ["Stainless - 400 Series (420)","HSS Spot Drill",0.00025,0.0005,0.00075,0.001,0.001375,0.00175,0.0025,0.003,0.00375,0.0045,0.0045,0.0045,0.0045];
         var _loc292_:*;
         this.IPTData[_loc292_ = _loc1_++] = ["Stainless - 400 Series (420)","HSS Twist Drill",0.0005,0.001,0.0015,0.002,0.00275,0.0035,0.005,0.006,0.0075,0.009,0.009,0.009,0.009];
         var _loc293_:*;
         this.IPTData[_loc293_ = _loc1_++] = ["Stainless - 400 Series (420)","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc294_:*;
         this.IPTData[_loc294_ = _loc1_++] = ["Stainless - 400 Series (420)","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.003,0.004,0.005,0.01,0.015,0.02,0.025,0.03,0.035];
         var _loc295_:*;
         this.IPTData[_loc295_ = _loc1_++] = ["Stainless - 400 Series (420)","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0005,0.0006,0.0009,0.0012,0.0013,0.0015,0.0015,0.0015,0.0015];
         var _loc296_:*;
         this.IPTData[_loc296_ = _loc1_++] = ["Stainless - 400 Series (420)","HSS Endmill",0.000375,0.0006,0.000675,0.00075,0.001125,0.0015,0.003,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc297_:*;
         this.IPTData[_loc297_ = _loc1_++] = ["Stainless - 400 Series (420)","Carbide Endmill",0.0005,0.0008,0.0009,0.001,0.0015,0.002,0.004,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc298_:*;
         this.IPTData[_loc298_ = _loc1_++] = ["Stainless - 400 Series (420)","HSS Reamer",0.0005,0.002,0.004,0.004,0.004,0.005,0.006,0.0068,0.0084,0.01,0.01,0.01,0.01];
         var _loc299_:*;
         this.IPTData[_loc299_ = _loc1_++] = ["Stainless - 400 Series (420)","Indexable Drill",0.0001,0.0001,0.0001,0.0005,0.001,0.002,0.003,0.004,0.005,0.0065,0.007,0.008,0.008];
         var _loc300_:*;
         this.IPTData[_loc300_ = _loc1_++] = ["Stainless - 400 Series (420)","Cobalt Twist Drill",0.0005,0.001,0.0015,0.002,0.00275,0.0035,0.005,0.006,0.0075,0.009,0.009,0.009,0.009];
         var _loc301_:*;
         this.IPTData[_loc301_ = _loc1_++] = ["Stainless - 400 Series (420)","HP HSS Endmill",0.0004125,0.00066,0.0007425,0.000825,0.0012375,0.00165,0.0033,0.00495,0.00495,0.00495,0.00495,0.00495,0.00495];
         var _loc302_:*;
         this.IPTData[_loc302_ = _loc1_++] = ["Stainless - 400 Series (420)","HP HSS Twist Drill",0.00055,0.0011,0.00165,0.0022,0.003025,0.00385,0.0055,0.0066,0.00825,0.0099,0.0099,0.0099,0.0099];
         var _loc303_:*;
         this.IPTData[_loc303_ = _loc1_++] = ["Stainless - 400 Series (420)","HP Carbide Endmill",0.00045,0.00072,0.00081,0.0009,0.00135,0.0018,0.0036,0.0054,0.0054,0.0054,0.0054,0.0054,0.0054];
         var _loc304_:*;
         this.IPTData[_loc304_ = _loc1_++] = ["Stainless - 400 Series (420)","TiAlN Carbide Endmill",0.00045,0.00072,0.00081,0.0009,0.00135,0.0018,0.0036,0.0054,0.0054,0.0054,0.0054,0.0054,0.0054];
         var _loc305_:*;
         this.IPTData[_loc305_ = _loc1_++] = ["Stainless - 400 Series (420)","HP Carbide Twist Drill",0.00055,0.0011,0.00165,0.0022,0.003025,0.00385,0.0055,0.0066,0.00825,0.0099,0.0099,0.0099,0.0099];
         var _loc306_:*;
         this.IPTData[_loc306_ = _loc1_++] = ["Stainless - 400 Series (420)","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.007,0.007,0.007,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc307_:*;
         this.IPTData[_loc307_ = _loc1_++] = ["Stainless - 400 Series (420)","Turning: HSS",0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015];
         var _loc308_:*;
         this.IPTData[_loc308_ = _loc1_++] = ["Stainless - 400 Series (420)","Turning: Carbide",0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015];
         var _loc309_:*;
         this.IPTData[_loc309_ = _loc1_++] = ["Stainless - PH Series (17-4)","HSS Spot Drill",0.00025,0.0005,0.00075,0.001,0.001375,0.00175,0.0025,0.003,0.00375,0.0045,0.0045,0.0045,0.0045];
         var _loc310_:*;
         this.IPTData[_loc310_ = _loc1_++] = ["Stainless - PH Series (17-4)","HSS Twist Drill",0.0005,0.001,0.0015,0.002,0.00275,0.0035,0.005,0.006,0.0075,0.009,0.009,0.009,0.009];
         var _loc311_:*;
         this.IPTData[_loc311_ = _loc1_++] = ["Stainless - PH Series (17-4)","Carbide Twist Drill",0.00025,0.0005,0.00075,0.001,0.001375,0.00175,0.0025,0.003,0.00375,0.0045,0.0045,0.0045,0.0045];
         var _loc312_:*;
         this.IPTData[_loc312_ = _loc1_++] = ["Stainless - PH Series (17-4)","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.003,0.004,0.005,0.01,0.015,0.02,0.025,0.03,0.035];
         var _loc313_:*;
         this.IPTData[_loc313_ = _loc1_++] = ["Stainless - PH Series (17-4)","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0005,0.0006,0.0009,0.0012,0.0013,0.0015,0.0015,0.0015,0.0015];
         var _loc314_:*;
         this.IPTData[_loc314_ = _loc1_++] = ["Stainless - PH Series (17-4)","HSS Endmill",0.000375,0.0006,0.000675,0.00075,0.001125,0.0015,0.003,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc315_:*;
         this.IPTData[_loc315_ = _loc1_++] = ["Stainless - PH Series (17-4)","Carbide Endmill",0.0005,0.0008,0.0009,0.001,0.0015,0.002,0.004,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc316_:*;
         this.IPTData[_loc316_ = _loc1_++] = ["Stainless - PH Series (17-4)","HSS Reamer",0.0005,0.002,0.004,0.004,0.004,0.005,0.006,0.0068,0.0084,0.01,0.01,0.01,0.01];
         var _loc317_:*;
         this.IPTData[_loc317_ = _loc1_++] = ["Stainless - PH Series (17-4)","Indexable Drill",0.0001,0.0001,0.0001,0.0005,0.001,0.002,0.003,0.004,0.005,0.0065,0.007,0.008,0.008];
         var _loc318_:*;
         this.IPTData[_loc318_ = _loc1_++] = ["Stainless - PH Series (17-4)","Cobalt Twist Drill",0.0005,0.001,0.0015,0.002,0.00275,0.0035,0.005,0.006,0.0075,0.009,0.009,0.009,0.009];
         var _loc319_:*;
         this.IPTData[_loc319_ = _loc1_++] = ["Stainless - PH Series (17-4)","HP HSS Endmill",0.0004125,0.00066,0.0007425,0.000825,0.0012375,0.00165,0.0033,0.00495,0.00495,0.00495,0.00495,0.00495,0.00495];
         var _loc320_:*;
         this.IPTData[_loc320_ = _loc1_++] = ["Stainless - PH Series (17-4)","HP HSS Twist Drill",0.00055,0.0011,0.00165,0.0022,0.003025,0.00385,0.0055,0.0066,0.00825,0.0099,0.0099,0.0099,0.0099];
         var _loc321_:*;
         this.IPTData[_loc321_ = _loc1_++] = ["Stainless - PH Series (17-4)","HP Carbide Endmill",0.00045,0.00072,0.00081,0.0009,0.00135,0.0018,0.0036,0.0054,0.0054,0.0054,0.0054,0.0054,0.0054];
         var _loc322_:*;
         this.IPTData[_loc322_ = _loc1_++] = ["Stainless - PH Series (17-4)","TiAlN Carbide Endmill",0.00045,0.00072,0.00081,0.0009,0.00135,0.0018,0.0036,0.0054,0.0054,0.0054,0.0054,0.0054,0.0054];
         var _loc323_:*;
         this.IPTData[_loc323_ = _loc1_++] = ["Stainless - PH Series (17-4)","HP Carbide Twist Drill",0.00055,0.0011,0.00165,0.0022,0.003025,0.00385,0.0055,0.0066,0.00825,0.0099,0.0099,0.0099,0.0099];
         var _loc324_:*;
         this.IPTData[_loc324_ = _loc1_++] = ["Stainless - PH Series (17-4)","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.007,0.007,0.007,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc325_:*;
         this.IPTData[_loc325_ = _loc1_++] = ["Stainless - PH Series (17-4)","Turning: HSS",0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014];
         var _loc326_:*;
         this.IPTData[_loc326_ = _loc1_++] = ["Stainless - PH Series (17-4)","Turning: Carbide",0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014];
         var _loc327_:*;
         this.IPTData[_loc327_ = _loc1_++] = ["Steel - Low Carbon (1020)","HSS Spot Drill",0.00025,0.00075,0.00105,0.001375,0.0018,0.00225,0.00325,0.0045,0.0055,0.00625,0.00625,0.00625,0.00625];
         var _loc328_:*;
         this.IPTData[_loc328_ = _loc1_++] = ["Steel - Low Carbon (1020)","HSS Twist Drill",0.0005,0.0015,0.0021,0.00275,0.0036,0.0045,0.0065,0.009,0.011,0.0125,0.0125,0.0125,0.0125];
         var _loc329_:*;
         this.IPTData[_loc329_ = _loc1_++] = ["Steel - Low Carbon (1020)","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.006,0.0075,0.009,0.009,0.009,0.009];
         var _loc330_:*;
         this.IPTData[_loc330_ = _loc1_++] = ["Steel - Low Carbon (1020)","HSS Spade Drill",0.000495,0.000792,0.000891,0.00099,0.003,0.003,0.008,0.015,0.02,0.025,0.03,0.04,0.055];
         var _loc331_:*;
         this.IPTData[_loc331_ = _loc1_++] = ["Steel - Low Carbon (1020)","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0005,0.0006,0.0011,0.0015,0.0017,0.002,0.002,0.002,0.002];
         var _loc332_:*;
         this.IPTData[_loc332_ = _loc1_++] = ["Steel - Low Carbon (1020)","HSS Endmill",0.0003,0.000375,0.0006,0.000975,0.0015,0.00225,0.00375,0.004875,0.004875,0.004875,0.004875,0.004875,0.004875];
         var _loc333_:*;
         this.IPTData[_loc333_ = _loc1_++] = ["Steel - Low Carbon (1020)","Carbide Endmill",0.0004,0.0005,0.0008,0.0013,0.002,0.003,0.005,0.0065,0.0065,0.0065,0.0065,0.0065,0.0065];
         var _loc334_:*;
         this.IPTData[_loc334_ = _loc1_++] = ["Steel - Low Carbon (1020)","HSS Reamer",0.001,0.002,0.006,0.008,0.01,0.0125,0.015,0.019,0.027,0.035,0.035,0.035,0.035];
         var _loc335_:*;
         this.IPTData[_loc335_ = _loc1_++] = ["Steel - Low Carbon (1020)","Indexable Drill",0.00009,0.00009,0.00009,0.00045,0.0009,0.0018,0.0027,0.0036,0.0045,0.00585,0.0063,0.0072,0.0072];
         var _loc336_:*;
         this.IPTData[_loc336_ = _loc1_++] = ["Steel - Low Carbon (1020)","Cobalt Twist Drill",0.0005,0.0015,0.0021,0.00275,0.0036,0.0045,0.0065,0.009,0.011,0.0125,0.0125,0.0125,0.0125];
         var _loc337_:*;
         this.IPTData[_loc337_ = _loc1_++] = ["Steel - Low Carbon (1020)","HP HSS Endmill",0.00033,0.0004125,0.00066,0.0010725,0.00165,0.002475,0.004125,0.0053625,0.0053625,0.0053625,0.0053625,0.0053625,0.0053625];
         var _loc338_:*;
         this.IPTData[_loc338_ = _loc1_++] = ["Steel - Low Carbon (1020)","HP HSS Twist Drill",0.00055,0.00165,0.00231,0.003025,0.00396,0.00495,0.00715,0.0099,0.0121,0.01375,0.01375,0.01375,0.01375];
         var _loc339_:*;
         this.IPTData[_loc339_ = _loc1_++] = ["Steel - Low Carbon (1020)","HP Carbide Endmill",0.00036,0.00045,0.00072,0.00117,0.0018,0.0027,0.0045,0.00585,0.00585,0.00585,0.00585,0.00585,0.00585];
         var _loc340_:*;
         this.IPTData[_loc340_ = _loc1_++] = ["Steel - Low Carbon (1020)","TiAlN Carbide Endmill",0.00036,0.00045,0.00072,0.00117,0.0018,0.0027,0.0045,0.00585,0.00585,0.00585,0.00585,0.00585,0.00585];
         var _loc341_:*;
         this.IPTData[_loc341_ = _loc1_++] = ["Steel - Low Carbon (1020)","HP Carbide Twist Drill",0.00055,0.00165,0.00231,0.003025,0.00396,0.00495,0.00715,0.0099,0.0121,0.01375,0.01375,0.01375,0.01375];
         var _loc342_:*;
         this.IPTData[_loc342_ = _loc1_++] = ["Steel - Low Carbon (1020)","Indexable End Or Face Mill",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc343_:*;
         this.IPTData[_loc343_ = _loc1_++] = ["Steel - Low Carbon (1020)","Turning: HSS",0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014];
         var _loc344_:*;
         this.IPTData[_loc344_ = _loc1_++] = ["Steel - Low Carbon (1020)","Turning: Carbide",0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014,0.014];
         var _loc345_:*;
         this.IPTData[_loc345_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","HSS Spot Drill",0.00025,0.00075,0.0010625,0.001375,0.0018125,0.00225,0.003,0.00375,0.0045,0.0055,0.0055,0.0055,0.0055];
         var _loc346_:*;
         this.IPTData[_loc346_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","HSS Twist Drill",0.0005,0.0015,0.002125,0.00275,0.003625,0.0045,0.006,0.0075,0.009,0.011,0.011,0.011,0.011];
         var _loc347_:*;
         this.IPTData[_loc347_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.0031125,0.003735,0.004565,0.004565,0.004565,0.004565];
         var _loc348_:*;
         this.IPTData[_loc348_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","HSS Spade Drill",0.000495,0.000792,0.000891,0.00099,0.003,0.003,0.008,0.015,0.02,0.025,0.03,0.04,0.055];
         var _loc349_:*;
         this.IPTData[_loc349_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","Gun Drill",0.0001,0.0001,0.0002,0.0004,0.0005,0.0006,0.0009,0.0012,0.00135,0.0015,0.0015,0.0015,0.0015];
         var _loc350_:*;
         this.IPTData[_loc350_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","HSS Endmill",0.0003,0.000375,0.0006,0.000975,0.0015,0.00225,0.00375,0.004875,0.004875,0.004875,0.004875,0.004875,0.004875];
         var _loc351_:*;
         this.IPTData[_loc351_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","Carbide Endmill",0.0004,0.0005,0.0008,0.0013,0.002,0.003,0.005,0.0065,0.0065,0.0065,0.0065,0.0065,0.0065];
         var _loc352_:*;
         this.IPTData[_loc352_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","HSS Reamer",0.001,0.002,0.006,0.008,0.01,0.0125,0.015,0.019,0.027,0.035,0.035,0.035,0.035];
         var _loc353_:*;
         this.IPTData[_loc353_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","Indexable Drill",0.00015,0.0003,0.0009,0.0012,0.0015,0.0019,0.0027,0.0043,0.0061,0.0087,0.0095,0.0095,0.0095];
         var _loc354_:*;
         this.IPTData[_loc354_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","Cobalt Twist Drill",0.0005,0.0015,0.002125,0.00275,0.003625,0.0045,0.006,0.0075,0.009,0.011,0.011,0.011,0.011];
         var _loc355_:*;
         this.IPTData[_loc355_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","HP HSS Endmill",0.00033,0.0004125,0.00066,0.0010725,0.00165,0.002475,0.004125,0.0053625,0.0053625,0.0053625,0.0053625,0.0053625,0.0053625];
         var _loc356_:*;
         this.IPTData[_loc356_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","HP HSS Twist Drill",0.00055,0.00165,0.0023375,0.003025,0.0039875,0.00495,0.0066,0.00825,0.0099,0.0121,0.0121,0.0121,0.0121];
         var _loc357_:*;
         this.IPTData[_loc357_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","HP Carbide Endmill",0.00036,0.00045,0.00072,0.00117,0.0018,0.0027,0.0045,0.00585,0.00585,0.00585,0.00585,0.00585,0.00585];
         var _loc358_:*;
         this.IPTData[_loc358_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","TiAlN Carbide Endmill",0.00036,0.00045,0.00072,0.00117,0.0018,0.0027,0.0045,0.00585,0.00585,0.00585,0.00585,0.00585,0.00585];
         var _loc359_:*;
         this.IPTData[_loc359_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","HP Carbide Twist Drill",0.00055,0.00165,0.0023375,0.003025,0.0039875,0.00495,0.0066,0.00825,0.0099,0.0121,0.0121,0.0121,0.0121];
         var _loc360_:*;
         this.IPTData[_loc360_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","Indexable End Or Face Mill",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.007,0.007,0.007,0.007,0.007,0.007];
         var _loc361_:*;
         this.IPTData[_loc361_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","Turning: HSS",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc362_:*;
         this.IPTData[_loc362_ = _loc1_++] = ["Steel - Low Carbon Alloy (8620)","Turning: Carbide",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc363_:*;
         this.IPTData[_loc363_ = _loc1_++] = ["Steel - Medium Carbon (1045)","HSS Spot Drill",0.00025,0.00075,0.0010625,0.001375,0.0018125,0.00225,0.003,0.00375,0.0045,0.0055,0.0055,0.0055,0.0055];
         var _loc364_:*;
         this.IPTData[_loc364_ = _loc1_++] = ["Steel - Medium Carbon (1045)","HSS Twist Drill",0.0005,0.0015,0.002125,0.00275,0.003625,0.0045,0.006,0.0075,0.009,0.011,0.011,0.011,0.011];
         var _loc365_:*;
         this.IPTData[_loc365_ = _loc1_++] = ["Steel - Medium Carbon (1045)","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.0031125,0.003735,0.004565,0.004565,0.004565,0.004565];
         var _loc366_:*;
         this.IPTData[_loc366_ = _loc1_++] = ["Steel - Medium Carbon (1045)","HSS Spade Drill",0.00015,0.0006,0.0009,0.0012,0.0018,0.0048,0.006,0.016,0.02,0.023,0.03,0.044,0.062];
         var _loc367_:*;
         this.IPTData[_loc367_ = _loc1_++] = ["Steel - Medium Carbon (1045)","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0005,0.0006,0.0011,0.0015,0.0017,0.002,0.002,0.002,0.002];
         var _loc368_:*;
         this.IPTData[_loc368_ = _loc1_++] = ["Steel - Medium Carbon (1045)","HSS Endmill",0.0003,0.00045,0.00075,0.000975,0.001275,0.00165,0.003,0.00375,0.00375,0.00375,0.00375,0.00375,0.00375];
         var _loc369_:*;
         this.IPTData[_loc369_ = _loc1_++] = ["Steel - Medium Carbon (1045)","Carbide Endmill",0.0004,0.0006,0.001,0.0013,0.0017,0.0022,0.004,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc370_:*;
         this.IPTData[_loc370_ = _loc1_++] = ["Steel - Medium Carbon (1045)","HSS Reamer",0.001,0.002,0.006,0.008,0.01,0.0125,0.015,0.019,0.027,0.035,0.035,0.035,0.035];
         var _loc371_:*;
         this.IPTData[_loc371_ = _loc1_++] = ["Steel - Medium Carbon (1045)","Indexable Drill",0.000135,0.00027,0.00081,0.00108,0.00135,0.00171,0.00243,0.0036,0.00549,0.00783,0.00855,0.00855,0.00855];
         var _loc372_:*;
         this.IPTData[_loc372_ = _loc1_++] = ["Steel - Medium Carbon (1045)","Cobalt Twist Drill",0.0005,0.0015,0.002125,0.00275,0.003625,0.0045,0.006,0.0075,0.009,0.011,0.011,0.011,0.011];
         var _loc373_:*;
         this.IPTData[_loc373_ = _loc1_++] = ["Steel - Medium Carbon (1045)","HP HSS Endmill",0.00033,0.000495,0.000825,0.0010725,0.0014025,0.001815,0.0033,0.004125,0.004125,0.004125,0.004125,0.004125,0.004125];
         var _loc374_:*;
         this.IPTData[_loc374_ = _loc1_++] = ["Steel - Medium Carbon (1045)","HP HSS Twist Drill",0.00055,0.00165,0.0023375,0.003025,0.0039875,0.00495,0.0066,0.00825,0.0099,0.0121,0.0121,0.0121,0.0121];
         var _loc375_:*;
         this.IPTData[_loc375_ = _loc1_++] = ["Steel - Medium Carbon (1045)","HP Carbide Endmill",0.00036,0.00054,0.0009,0.00117,0.00153,0.00198,0.0036,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc376_:*;
         this.IPTData[_loc376_ = _loc1_++] = ["Steel - Medium Carbon (1045)","TiAlN Carbide Endmill",0.00036,0.00054,0.0009,0.00117,0.00153,0.00198,0.0036,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc377_:*;
         this.IPTData[_loc377_ = _loc1_++] = ["Steel - Medium Carbon (1045)","HP Carbide Twist Drill",0.00055,0.00165,0.0023375,0.003025,0.0039875,0.00495,0.0066,0.00825,0.0099,0.0121,0.0121,0.0121,0.0121];
         var _loc378_:*;
         this.IPTData[_loc378_ = _loc1_++] = ["Steel - Medium Carbon (1045)","Indexable End Or Face Mill",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.007,0.007,0.007,0.007,0.007,0.007];
         var _loc379_:*;
         this.IPTData[_loc379_ = _loc1_++] = ["Steel - Medium Carbon (1045)","Turning: HSS",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc380_:*;
         this.IPTData[_loc380_ = _loc1_++] = ["Steel - Medium Carbon (1045)","Turning: Carbide",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc381_:*;
         this.IPTData[_loc381_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","HSS Spot Drill",0.00025,0.00075,0.0010625,0.001375,0.0018125,0.00225,0.003,0.00375,0.0045,0.0055,0.0055,0.0055,0.0055];
         var _loc382_:*;
         this.IPTData[_loc382_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","HSS Twist Drill",0.0005,0.0015,0.002125,0.00275,0.003625,0.0045,0.006,0.0075,0.009,0.011,0.011,0.011,0.011];
         var _loc383_:*;
         this.IPTData[_loc383_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.003,0.0036,0.0044,0.0044,0.0044,0.0044];
         var _loc384_:*;
         this.IPTData[_loc384_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.0015,0.004,0.005,0.012,0.018,0.022,0.03,0.04,0.05];
         var _loc385_:*;
         this.IPTData[_loc385_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","Gun Drill",0.0001,0.0001,0.0002,0.0004,0.0005,0.0006,0.0009,0.0012,0.00135,0.0015,0.0015,0.0015,0.0015];
         var _loc386_:*;
         this.IPTData[_loc386_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","HSS Endmill",0.0003,0.000375,0.0006,0.000975,0.0015,0.00225,0.00375,0.004875,0.004875,0.004875,0.004875,0.004875,0.004875];
         var _loc387_:*;
         this.IPTData[_loc387_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","Carbide Endmill",0.0004,0.0005,0.0008,0.0013,0.002,0.003,0.005,0.0065,0.0065,0.0065,0.0065,0.0065,0.0065];
         var _loc388_:*;
         this.IPTData[_loc388_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","HSS Reamer",0.001,0.002,0.006,0.008,0.01,0.0125,0.015,0.019,0.027,0.035,0.035,0.035,0.035];
         var _loc389_:*;
         this.IPTData[_loc389_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","Indexable Drill",0.0001215,0.000243,0.000729,0.000972,0.001215,0.001539,0.002187,0.0036,0.004941,0.007047,0.007695,0.007695,0.007695];
         var _loc390_:*;
         this.IPTData[_loc390_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","Cobalt Twist Drill",0.0005,0.0015,0.002125,0.00275,0.003625,0.0045,0.006,0.0075,0.009,0.011,0.011,0.011,0.011];
         var _loc391_:*;
         this.IPTData[_loc391_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","HP HSS Endmill",0.00033,0.0004125,0.00066,0.0010725,0.00165,0.002475,0.004125,0.0053625,0.0053625,0.0053625,0.0053625,0.0053625,0.0053625];
         var _loc392_:*;
         this.IPTData[_loc392_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","HP HSS Twist Drill",0.00055,0.00165,0.0023375,0.003025,0.0039875,0.00495,0.0066,0.00825,0.0099,0.0121,0.0121,0.0121,0.0121];
         var _loc393_:*;
         this.IPTData[_loc393_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","HP Carbide Endmill",0.00036,0.00045,0.00072,0.00117,0.0018,0.0027,0.0045,0.00585,0.00585,0.00585,0.00585,0.00585,0.00585];
         var _loc394_:*;
         this.IPTData[_loc394_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","TiAlN Carbide Endmill",0.00036,0.00045,0.00072,0.00117,0.0018,0.0027,0.0045,0.00585,0.00585,0.00585,0.00585,0.00585,0.00585];
         var _loc395_:*;
         this.IPTData[_loc395_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","HP Carbide Twist Drill",0.00055,0.00165,0.0023375,0.003025,0.0039875,0.00495,0.0066,0.00825,0.0099,0.0121,0.0121,0.0121,0.0121];
         var _loc396_:*;
         this.IPTData[_loc396_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","Indexable End Or Face Mill",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.007,0.007,0.007,0.007,0.007,0.007];
         var _loc397_:*;
         this.IPTData[_loc397_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","Turning: HSS",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc398_:*;
         this.IPTData[_loc398_ = _loc1_++] = ["Steel - Medium Carbon Alloy (4130)","Turning: Carbide",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc399_:*;
         this.IPTData[_loc399_ = _loc1_++] = ["Steel - High Carbon (1090)","HSS Spot Drill",0.00025,0.00075,0.0010625,0.001375,0.0018125,0.00225,0.003,0.00375,0.0045,0.0055,0.0055,0.0055,0.0055];
         var _loc400_:*;
         this.IPTData[_loc400_ = _loc1_++] = ["Steel - High Carbon (1090)","HSS Twist Drill",0.0005,0.0015,0.002125,0.00275,0.003625,0.0045,0.006,0.0075,0.009,0.011,0.011,0.011,0.011];
         var _loc401_:*;
         this.IPTData[_loc401_ = _loc1_++] = ["Steel - High Carbon (1090)","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.003,0.0036,0.0044,0.0044,0.0044,0.0044];
         var _loc402_:*;
         this.IPTData[_loc402_ = _loc1_++] = ["Steel - High Carbon (1090)","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.0015,0.004,0.005,0.012,0.018,0.022,0.032,0.04,0.05];
         var _loc403_:*;
         this.IPTData[_loc403_ = _loc1_++] = ["Steel - High Carbon (1090)","Gun Drill",0.0001,0.0001,0.0002,0.0004,0.0005,0.0006,0.0009,0.0012,0.00135,0.0015,0.0015,0.0015,0.0015];
         var _loc404_:*;
         this.IPTData[_loc404_ = _loc1_++] = ["Steel - High Carbon (1090)","HSS Endmill",0.0003,0.00045,0.00075,0.0009,0.001275,0.00165,0.003,0.00375,0.00375,0.00375,0.00375,0.00375,0.00375];
         var _loc405_:*;
         this.IPTData[_loc405_ = _loc1_++] = ["Steel - High Carbon (1090)","Carbide Endmill",0.0004,0.0006,0.001,0.0012,0.0017,0.0022,0.004,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc406_:*;
         this.IPTData[_loc406_ = _loc1_++] = ["Steel - High Carbon (1090)","HSS Reamer",0.0005,0.002,0.005,0.0065,0.008,0.01,0.012,0.0156,0.0228,0.03,0.03,0.03,0.03];
         var _loc407_:*;
         this.IPTData[_loc407_ = _loc1_++] = ["Steel - High Carbon (1090)","Indexable Drill",0.00010935,0.0002187,0.0006561,0.0008748,0.0010935,0.0013851,0.0019683,0.0036,0.0044469,0.0063423,0.0069255,0.0069255,0.0069255];
         var _loc408_:*;
         this.IPTData[_loc408_ = _loc1_++] = ["Steel - High Carbon (1090)","Cobalt Twist Drill",0.0005,0.0015,0.002125,0.00275,0.003625,0.0045,0.006,0.0075,0.009,0.011,0.011,0.011,0.011];
         var _loc409_:*;
         this.IPTData[_loc409_ = _loc1_++] = ["Steel - High Carbon (1090)","HP HSS Endmill",0.00033,0.000495,0.000825,0.00099,0.0014025,0.001815,0.0033,0.004125,0.004125,0.004125,0.004125,0.004125,0.004125];
         var _loc410_:*;
         this.IPTData[_loc410_ = _loc1_++] = ["Steel - High Carbon (1090)","HP HSS Twist Drill",0.00055,0.00165,0.0023375,0.003025,0.0039875,0.00495,0.0066,0.00825,0.0099,0.0121,0.0121,0.0121,0.0121];
         var _loc411_:*;
         this.IPTData[_loc411_ = _loc1_++] = ["Steel - High Carbon (1090)","HP Carbide Endmill",0.00036,0.00054,0.0009,0.00108,0.00153,0.00198,0.0036,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc412_:*;
         this.IPTData[_loc412_ = _loc1_++] = ["Steel - High Carbon (1090)","TiAlN Carbide Endmill",0.00036,0.00054,0.0009,0.00108,0.00153,0.00198,0.0036,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc413_:*;
         this.IPTData[_loc413_ = _loc1_++] = ["Steel - High Carbon (1090)","HP Carbide Twist Drill",0.00055,0.00165,0.0023375,0.003025,0.0039875,0.00495,0.0066,0.00825,0.0099,0.0121,0.0121,0.0121,0.0121];
         var _loc414_:*;
         this.IPTData[_loc414_ = _loc1_++] = ["Steel - High Carbon (1090)","Indexable End Or Face Mill",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.007,0.007,0.007,0.007,0.007,0.007];
         var _loc415_:*;
         this.IPTData[_loc415_ = _loc1_++] = ["Steel - High Carbon (1090)","Turning: HSS",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc416_:*;
         this.IPTData[_loc416_ = _loc1_++] = ["Steel - High Carbon (1090)","Turning: Carbide",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc417_:*;
         this.IPTData[_loc417_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","HSS Spot Drill",0.00025,0.00075,0.0010625,0.001375,0.0018125,0.00225,0.003,0.00375,0.0045,0.0055,0.0055,0.0055,0.0055];
         var _loc418_:*;
         this.IPTData[_loc418_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","HSS Twist Drill",0.0005,0.0015,0.002125,0.00275,0.003625,0.0045,0.006,0.0075,0.009,0.011,0.011,0.011,0.011];
         var _loc419_:*;
         this.IPTData[_loc419_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.003,0.0036,0.0044,0.0044,0.0044,0.0044];
         var _loc420_:*;
         this.IPTData[_loc420_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.0015,0.004,0.005,0.012,0.018,0.022,0.032,0.04,0.05];
         var _loc421_:*;
         this.IPTData[_loc421_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","Gun Drill",0.0001,0.0001,0.0002,0.0004,0.0005,0.0006,0.0009,0.0012,0.00135,0.0015,0.0015,0.0015,0.0015];
         var _loc422_:*;
         this.IPTData[_loc422_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","HSS Endmill",0.0003,0.000525,0.000825,0.00105,0.001425,0.00165,0.002475,0.00375,0.00375,0.00375,0.00375,0.00375,0.00375];
         var _loc423_:*;
         this.IPTData[_loc423_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","Carbide Endmill",0.0004,0.0006,0.001,0.0013,0.0017,0.002,0.003,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc424_:*;
         this.IPTData[_loc424_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","HSS Reamer",0.001,0.002,0.005,0.0065,0.008,0.01,0.012,0.0156,0.0228,0.03,0.03,0.03,0.03];
         var _loc425_:*;
         this.IPTData[_loc425_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","Indexable Drill",0.000098415,0.00019683,0.00059049,0.00078732,0.00098415,0.00124659,0.00177147,0.0036,0.00400221,0.00570807,0.00623295,0.00623295,0.00623295];
         var _loc426_:*;
         this.IPTData[_loc426_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","Cobalt Twist Drill",0.0005,0.0015,0.002125,0.00275,0.003625,0.0045,0.006,0.0075,0.009,0.011,0.011,0.011,0.011];
         var _loc427_:*;
         this.IPTData[_loc427_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","HP HSS Endmill",0.00033,0.0005775,0.0009075,0.001155,0.0015675,0.001815,0.0027225,0.004125,0.004125,0.004125,0.004125,0.004125,0.004125];
         var _loc428_:*;
         this.IPTData[_loc428_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","HP HSS Twist Drill",0.00055,0.00165,0.0023375,0.003025,0.0039875,0.00495,0.0066,0.00825,0.0099,0.0121,0.0121,0.0121,0.0121];
         var _loc429_:*;
         this.IPTData[_loc429_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","HP Carbide Endmill",0.00036,0.00063,0.00099,0.00126,0.00171,0.00198,0.00297,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc430_:*;
         this.IPTData[_loc430_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","TiAlN Carbide Endmill",0.00036,0.00063,0.00099,0.00126,0.00171,0.00198,0.00297,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc431_:*;
         this.IPTData[_loc431_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","HP Carbide Twist Drill",0.00055,0.00165,0.0023375,0.003025,0.0039875,0.00495,0.0066,0.00825,0.0099,0.0121,0.0121,0.0121,0.0121];
         var _loc432_:*;
         this.IPTData[_loc432_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","Indexable End Or Face Mill",0.005,0.005,0.005,0.005,0.005,0.005,0.005,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc433_:*;
         this.IPTData[_loc433_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","Turning: HSS",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc434_:*;
         this.IPTData[_loc434_ = _loc1_++] = ["Steel - High Carbon Alloy (52100)","Turning: Carbide",0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012];
         var _loc435_:*;
         this.IPTData[_loc435_ = _loc1_++] = ["Steel - Tool (H13)","HSS Spot Drill",0.00025,0.0005,0.000625,0.00075,0.001,0.00125,0.00175,0.00225,0.00275,0.00325,0.00325,0.00325,0.00325];
         var _loc436_:*;
         this.IPTData[_loc436_ = _loc1_++] = ["Steel - Tool (H13)","HSS Twist Drill",0.0005,0.001,0.00125,0.0015,0.002,0.0025,0.0035,0.0045,0.0055,0.0065,0.0065,0.0065,0.0065];
         var _loc437_:*;
         this.IPTData[_loc437_ = _loc1_++] = ["Steel - Tool (H13)","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.0018,0.0022,0.0026,0.0026,0.0026,0.0026];
         var _loc438_:*;
         this.IPTData[_loc438_ = _loc1_++] = ["Steel - Tool (H13)","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.0015,0.004,0.005,0.01,0.014,0.018,0.025,0.03,0.04];
         var _loc439_:*;
         this.IPTData[_loc439_ = _loc1_++] = ["Steel - Tool (H13)","Gun Drill",0.0001,0.0001,0.0002,0.0004,0.0005,0.0006,0.0009,0.0012,0.00135,0.0015,0.0015,0.0015,0.0015];
         var _loc440_:*;
         this.IPTData[_loc440_ = _loc1_++] = ["Steel - Tool (H13)","HSS Endmill",0.0003,0.000525,0.000825,0.00105,0.001425,0.00165,0.002475,0.00375,0.00375,0.00375,0.00375,0.00375,0.00375];
         var _loc441_:*;
         this.IPTData[_loc441_ = _loc1_++] = ["Steel - Tool (H13)","Carbide Endmill",0.0004,0.0006,0.001,0.0013,0.0017,0.002,0.003,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc442_:*;
         this.IPTData[_loc442_ = _loc1_++] = ["Steel - Tool (H13)","HSS Reamer",0.001,0.002,0.005,0.0065,0.008,0.01,0.012,0.0156,0.0228,0.03,0.03,0.03,0.03];
         var _loc443_:*;
         this.IPTData[_loc443_ = _loc1_++] = ["Steel - Tool (H13)","Indexable Drill",0.0001,0.0001,0.0001,0.0005,0.001,0.002,0.003,0.004,0.005,0.0065,0.007,0.008,0.008];
         var _loc444_:*;
         this.IPTData[_loc444_ = _loc1_++] = ["Steel - Tool (H13)","Cobalt Twist Drill",0.0005,0.001,0.00125,0.0015,0.002,0.0025,0.0035,0.0045,0.0055,0.0065,0.0065,0.0065,0.0065];
         var _loc445_:*;
         this.IPTData[_loc445_ = _loc1_++] = ["Steel - Tool (H13)","HP HSS Endmill",0.00033,0.0005775,0.0009075,0.001155,0.0015675,0.001815,0.0027225,0.004125,0.004125,0.004125,0.004125,0.004125,0.004125];
         var _loc446_:*;
         this.IPTData[_loc446_ = _loc1_++] = ["Steel - Tool (H13)","HP HSS Twist Drill",0.00055,0.0011,0.001375,0.00165,0.0022,0.00275,0.00385,0.00495,0.00605,0.00715,0.00715,0.00715,0.00715];
         var _loc447_:*;
         this.IPTData[_loc447_ = _loc1_++] = ["Steel - Tool (H13)","HP Carbide Endmill",0.00036,0.00063,0.00099,0.00126,0.00171,0.00198,0.00297,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc448_:*;
         this.IPTData[_loc448_ = _loc1_++] = ["Steel - Tool (H13)","TiAlN Carbide Endmill",0.00036,0.00063,0.00099,0.00126,0.00171,0.00198,0.00297,0.0045,0.0045,0.0045,0.0045,0.0045,0.0045];
         var _loc449_:*;
         this.IPTData[_loc449_ = _loc1_++] = ["Steel - Tool (H13)","HP Carbide Twist Drill",0.00055,0.0011,0.001375,0.00165,0.0022,0.00275,0.00385,0.00495,0.00605,0.00715,0.00715,0.00715,0.00715];
         var _loc450_:*;
         this.IPTData[_loc450_ = _loc1_++] = ["Steel - Tool (H13)","Indexable End Or Face Mill",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc451_:*;
         this.IPTData[_loc451_ = _loc1_++] = ["Steel - Tool (H13)","Turning: HSS",0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01];
         var _loc452_:*;
         this.IPTData[_loc452_ = _loc1_++] = ["Steel - Tool (H13)","Turning: Carbide",0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01];
         var _loc453_:*;
         this.IPTData[_loc453_ = _loc1_++] = ["Titanium Alloy","HSS Spot Drill",0.00025,0.0005,0.000875,0.00125,0.0015625,0.001875,0.002375,0.003,0.00375,0.00425,0.00425,0.00425,0.00425];
         var _loc454_:*;
         this.IPTData[_loc454_ = _loc1_++] = ["Titanium Alloy","HSS Twist Drill",0.0005,0.001,0.00175,0.0025,0.003125,0.00375,0.00475,0.006,0.0075,0.0085,0.0085,0.0085,0.0085];
         var _loc455_:*;
         this.IPTData[_loc455_ = _loc1_++] = ["Titanium Alloy","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.003,0.00375,0.00425,0.00425,0.00425,0.00425];
         var _loc456_:*;
         this.IPTData[_loc456_ = _loc1_++] = ["Titanium Alloy","HSS Spade Drill",0.000125,0.0005,0.00075,0.001,0.003,0.004,0.005,0.01,0.014,0.018,0.025,0.03,0.04];
         var _loc457_:*;
         this.IPTData[_loc457_ = _loc1_++] = ["Titanium Alloy","Gun Drill",0.0001,0.0001,0.0002,0.0003,0.0004,0.0005,0.0007,0.0009,0.001,0.0012,0.0012,0.0012,0.0012];
         var _loc458_:*;
         this.IPTData[_loc458_ = _loc1_++] = ["Titanium Alloy","HSS Endmill",0.0003,0.0004,0.0006,0.0007,0.001,0.0014,0.0028,0.0057,0.0057,0.0057,0.0057,0.0057,0.0057];
         var _loc459_:*;
         this.IPTData[_loc459_ = _loc1_++] = ["Titanium Alloy","Carbide Endmill",0.0002,0.0003,0.0004,0.0005,0.0007,0.001,0.002,0.004,0.004,0.004,0.004,0.004,0.004];
         var _loc460_:*;
         this.IPTData[_loc460_ = _loc1_++] = ["Titanium Alloy","HSS Reamer",0.0005,0.001,0.003,0.004,0.005,0.0065,0.008,0.0092,0.0116,0.014,0.014,0.014,0.014];
         var _loc461_:*;
         this.IPTData[_loc461_ = _loc1_++] = ["Titanium Alloy","Indexable Drill",0.0001,0.0001,0.0001,0.0002,0.0005,0.002,0.002,0.0025,0.003,0.004,0.004,0.004,0.004];
         var _loc462_:*;
         this.IPTData[_loc462_ = _loc1_++] = ["Titanium Alloy","Cobalt Twist Drill",0.0005,0.001,0.00175,0.0025,0.003125,0.00375,0.00475,0.006,0.0075,0.0085,0.0085,0.0085,0.0085];
         var _loc463_:*;
         this.IPTData[_loc463_ = _loc1_++] = ["Titanium Alloy","HP HSS Endmill",0.00033,0.00044,0.00066,0.00077,0.0011,0.00154,0.00308,0.00627,0.00627,0.00627,0.00627,0.00627,0.00627];
         var _loc464_:*;
         this.IPTData[_loc464_ = _loc1_++] = ["Titanium Alloy","HP HSS Twist Drill",0.00055,0.0011,0.001925,0.00275,0.0034375,0.004125,0.005225,0.0066,0.00825,0.00935,0.00935,0.00935,0.00935];
         var _loc465_:*;
         this.IPTData[_loc465_ = _loc1_++] = ["Titanium Alloy","HP Carbide Endmill",0.00036,0.00048,0.00072,0.00084,0.0012,0.00168,0.00336,0.00684,0.00684,0.00684,0.00684,0.00684,0.00684];
         var _loc466_:*;
         this.IPTData[_loc466_ = _loc1_++] = ["Titanium Alloy","TiAlN Carbide Endmill",0.00036,0.00048,0.00072,0.00084,0.0012,0.00168,0.00336,0.00684,0.00684,0.00684,0.00684,0.00684,0.00684];
         var _loc467_:*;
         this.IPTData[_loc467_ = _loc1_++] = ["Titanium Alloy","HP Carbide Twist Drill",0.00055,0.0011,0.001925,0.00275,0.0034375,0.004125,0.005225,0.0066,0.00825,0.00935,0.00935,0.00935,0.00935];
         var _loc468_:*;
         this.IPTData[_loc468_ = _loc1_++] = ["Titanium Alloy","Indexable End Or Face Mill",0.005,0.005,0.005,0.005,0.005,0.005,0.005,0.005,0.005,0.005,0.005,0.005,0.005];
         var _loc469_:*;
         this.IPTData[_loc469_ = _loc1_++] = ["Titanium Alloy","Turning: HSS",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc470_:*;
         this.IPTData[_loc470_ = _loc1_++] = ["Titanium Alloy","Turning: Carbide",0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006,0.006];
         var _loc471_:*;
         this.IPTData[_loc471_ = _loc1_++] = ["Tungsten","HSS Spot Drill",0.00025,0.00075,0.001,0.00125,0.002,0.00275,0.003,0.00425,0.0055,0.00625,0.00625,0.00625,0.00625];
         var _loc472_:*;
         this.IPTData[_loc472_ = _loc1_++] = ["Tungsten","HSS Twist Drill",0.0005,0.0015,0.002,0.0025,0.004,0.0055,0.006,0.0085,0.011,0.0125,0.0125,0.0125,0.0125];
         var _loc473_:*;
         this.IPTData[_loc473_ = _loc1_++] = ["Tungsten","Carbide Twist Drill",0.00025,0.001,0.0015,0.002,0.003,0.004,0.005,0.0035275,0.004565,0.0051875,0.0051875,0.0051875,0.0051875];
         var _loc474_:*;
         this.IPTData[_loc474_ = _loc1_++] = ["Tungsten","HSS Spade Drill",0.000195,0.00078,0.00117,0.00156,0.0046,0.006,0.007,0.02,0.025,0.025,0.025,0.028,0.033];
         var _loc475_:*;
         this.IPTData[_loc475_ = _loc1_++] = ["Tungsten","Gun Drill",0.0001,0.0002,0.0003,0.0004,0.0008,0.0012,0.0025,0.0035,0.0038,0.004,0.004,0.004,0.004];
         var _loc476_:*;
         this.IPTData[_loc476_ = _loc1_++] = ["Tungsten","HSS Endmill",0.0002,0.0004,0.0006,0.001,0.0014,0.0016,0.0032,0.0048,0.0048,0.0048,0.0048,0.0048,0.0048];
         var _loc477_:*;
         this.IPTData[_loc477_ = _loc1_++] = ["Tungsten","Carbide Endmill",0.0003,0.0007,0.0012,0.002,0.0027,0.0035,0.0055,0.007,0.007,0.007,0.007,0.007,0.007];
         var _loc478_:*;
         this.IPTData[_loc478_ = _loc1_++] = ["Tungsten","HSS Reamer",0.0005,0.002,0.006,0.008,0.01,0.0125,0.015,0.02,0.0275,0.035,0.035,0.035,0.035];
         var _loc479_:*;
         this.IPTData[_loc479_ = _loc1_++] = ["Tungsten","Indexable Drill",0.000125,0.0005,0.0015,0.002,0.0025,0.003125,0.00375,0.0053,0.0073,0.0083,0.0095,0.0101,0.0101];
         var _loc480_:*;
         this.IPTData[_loc480_ = _loc1_++] = ["Tungsten","Cobalt Twist Drill",0.0005,0.0015,0.002,0.0025,0.004,0.0055,0.006,0.0085,0.011,0.0125,0.0125,0.0125,0.0125];
         var _loc481_:*;
         this.IPTData[_loc481_ = _loc1_++] = ["Tungsten","HP HSS Endmill",0.00022,0.00044,0.00066,0.0011,0.00154,0.00176,0.00352,0.00528,0.00528,0.00528,0.00528,0.00528,0.00528];
         var _loc482_:*;
         this.IPTData[_loc482_ = _loc1_++] = ["Tungsten","HP HSS Twist Drill",0.00055,0.00165,0.0022,0.00275,0.0044,0.00605,0.0066,0.00935,0.0121,0.01375,0.01375,0.01375,0.01375];
         var _loc483_:*;
         this.IPTData[_loc483_ = _loc1_++] = ["Tungsten","HP Carbide Endmill",0.00024,0.00048,0.00072,0.0012,0.00168,0.00192,0.00384,0.00576,0.00576,0.00576,0.00576,0.00576,0.00576];
         var _loc484_:*;
         this.IPTData[_loc484_ = _loc1_++] = ["Tungsten","TiAlN Carbide Endmill",0.00024,0.00048,0.00072,0.0012,0.00168,0.00192,0.00384,0.00576,0.00576,0.00576,0.00576,0.00576,0.00576];
         var _loc485_:*;
         this.IPTData[_loc485_ = _loc1_++] = ["Tungsten","HP Carbide Twist Drill",0.00055,0.00165,0.0022,0.00275,0.0044,0.00605,0.0066,0.00935,0.0121,0.01375,0.01375,0.01375,0.01375];
         var _loc486_:*;
         this.IPTData[_loc486_ = _loc1_++] = ["Tungsten","Indexable End Or Face Mill",0.007,0.007,0.007,0.007,0.007,0.007,0.007,0.008,0.008,0.008,0.008,0.008,0.008];
         var _loc487_:*;
         this.IPTData[_loc487_ = _loc1_++] = ["Tungsten","Turning: HSS",0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015];
         var _loc488_:*;
         this.IPTData[_loc488_ = _loc1_++] = ["Tungsten","Turning: Carbide",0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015,0.015];
         var _loc489_:*;
         this.IPTData[_loc489_ = _loc1_++] = ["Wax","HSS Spot Drill",0.0004275,0.0023085,0.00286425,0.00342,0.0041895,0.004959,0.006498,0.00684,0.01026,0.01368,0.02052,0.02736,0.0342];
         var _loc490_:*;
         this.IPTData[_loc490_ = _loc1_++] = ["Wax","HSS Twist Drill",0.000855,0.004617,0.0057285,0.00684,0.008379,0.009918,0.012996,0.01368,0.02052,0.02736,0.04104,0.05472,0.0684];
         var _loc491_:*;
         this.IPTData[_loc491_ = _loc1_++] = ["Wax","Carbide Twist Drill",0.000855,0.004617,0.0057285,0.00684,0.008379,0.009918,0.012996,0.01368,0.02052,0.02736,0.04104,0.05472,0.0684];
         var _loc492_:*;
         this.IPTData[_loc492_ = _loc1_++] = ["Wax","HSS Spade Drill",0.00171,0.009234,0.011457,0.01368,0.016758,0.019836,0.025992,0.02736,0.04104,0.05472,0.08208,0.10944,0.1368];
         var _loc493_:*;
         this.IPTData[_loc493_ = _loc1_++] = ["Wax","Gun Drill",0.000057,0.0003078,0.0003819,0.000456,0.0005586,0.0006612,0.0008664,0.000912,0.001368,0.001824,0.002736,0.003648,0.00456];
         var _loc494_:*;
         this.IPTData[_loc494_ = _loc1_++] = ["Wax","HSS Endmill",0.000684,0.0036936,0.0045828,0.005472,0.0067032,0.0079344,0.0103968,0.010944,0.016416,0.021888,0.032832,0.043776,0.05472];
         var _loc495_:*;
         this.IPTData[_loc495_ = _loc1_++] = ["Wax","Carbide Endmill",0.00057,0.003078,0.003819,0.00456,0.005586,0.006612,0.008664,0.00912,0.01368,0.01824,0.02736,0.03648,0.0456];
         var _loc496_:*;
         this.IPTData[_loc496_ = _loc1_++] = ["Wax","HSS Reamer",0.0013395,0.0072333,0.00897465,0.010716,0.0131271,0.0155382,0.0203604,0.021432,0.032148,0.042864,0.064296,0.085728,0.10716];
         var _loc497_:*;
         this.IPTData[_loc497_ = _loc1_++] = ["Wax","Indexable Drill",0.000285,0.001539,0.0019095,0.00228,0.002793,0.003306,0.004332,0.00456,0.00684,0.00912,0.01368,0.01824,0.0228];
         var _loc498_:*;
         this.IPTData[_loc498_ = _loc1_++] = ["Wax","Cobalt Twist Drill",0.000855,0.004617,0.0057285,0.00684,0.008379,0.009918,0.012996,0.01368,0.02052,0.02736,0.04104,0.05472,0.0684];
         var _loc499_:*;
         this.IPTData[_loc499_ = _loc1_++] = ["Wax","HP HSS Endmill",0.0007524,0.00406296,0.00504108,0.0060192,0.00737352,0.00872784,0.01143648,0.0120384,0.0180576,0.0240768,0.0361152,0.0481536,0.060192];
         var _loc500_:*;
         this.IPTData[_loc500_ = _loc1_++] = ["Wax","HP HSS Twist Drill",0.0009405,0.0050787,0.00630135,0.007524,0.0092169,0.0109098,0.0142956,0.015048,0.022572,0.030096,0.045144,0.060192,0.07524];
         var _loc501_:*;
         this.IPTData[_loc501_ = _loc1_++] = ["Wax","HP Carbide Endmill",0.0008208,0.00443232,0.00549936,0.0065664,0.00804384,0.00952128,0.01247616,0.0131328,0.0196992,0.0262656,0.0393984,0.0525312,0.065664];
         var _loc502_:*;
         this.IPTData[_loc502_ = _loc1_++] = ["Wax","TiAlN Carbide Endmill",0.0008208,0.00443232,0.00549936,0.0065664,0.00804384,0.00952128,0.01247616,0.0131328,0.0196992,0.0262656,0.0393984,0.0525312,0.065664];
         var _loc503_:*;
         this.IPTData[_loc503_ = _loc1_++] = ["Wax","HP Carbide Twist Drill",0.0009405,0.0050787,0.00630135,0.007524,0.0092169,0.0109098,0.0142956,0.015048,0.022572,0.030096,0.045144,0.060192,0.07524];
         var _loc504_:*;
         this.IPTData[_loc504_ = _loc1_++] = ["Wax","Indexable End Or Face Mill",0.001995,0.010773,0.0133665,0.01596,0.019551,0.023142,0.030324,0.03192,0.04788,0.06384,0.09576,0.12768,0.1596];
         var _loc505_:*;
         this.IPTData[_loc505_ = _loc1_++] = ["Wax","Turning: HSS",0.00513,0.027702,0.034371,0.04104,0.050274,0.059508,0.077976,0.08208,0.12312,0.16416,0.24624,0.32832,0.4104];
         var _loc506_:*;
         this.IPTData[_loc506_ = _loc1_++] = ["Wax","Turning: Carbide",0.00513,0.027702,0.034371,0.04104,0.050274,0.059508,0.077976,0.08208,0.12312,0.16416,0.24624,0.32832,0.4104];
         var _loc507_:*;
         this.IPTData[_loc507_ = _loc1_++] = ["Wood: Hardwood","HSS Spot Drill",0.0009375,0.0050625,0.00628125,0.0075,0.0091875,0.010875,0.01425,0.015,0.0225,0.03,0.045,0.06,0.075];
         var _loc508_:*;
         this.IPTData[_loc508_ = _loc1_++] = ["Wood: Hardwood","HSS Twist Drill",0.001875,0.010125,0.0125625,0.015,0.018375,0.02175,0.0285,0.03,0.045,0.06,0.09,0.12,0.15];
         var _loc509_:*;
         this.IPTData[_loc509_ = _loc1_++] = ["Wood: Hardwood","Carbide Twist Drill",0.001875,0.010125,0.0125625,0.015,0.018375,0.02175,0.0285,0.03,0.045,0.06,0.09,0.12,0.15];
         var _loc510_:*;
         this.IPTData[_loc510_ = _loc1_++] = ["Wood: Hardwood","HSS Spade Drill",0.00375,0.02025,0.025125,0.03,0.03675,0.0435,0.057,0.06,0.09,0.12,0.18,0.24,0.3];
         var _loc511_:*;
         this.IPTData[_loc511_ = _loc1_++] = ["Wood: Hardwood","Gun Drill",0.000125,0.000675,0.0008375,0.001,0.001225,0.00145,0.0019,0.002,0.003,0.004,0.006,0.008,0.01];
         var _loc512_:*;
         this.IPTData[_loc512_ = _loc1_++] = ["Wood: Hardwood","HSS Endmill",0.0015,0.0081,0.01005,0.012,0.0147,0.0174,0.0228,0.024,0.036,0.048,0.072,0.096,0.12];
         var _loc513_:*;
         this.IPTData[_loc513_ = _loc1_++] = ["Wood: Hardwood","Carbide Endmill",0.00125,0.00675,0.008375,0.01,0.01225,0.0145,0.019,0.02,0.03,0.04,0.06,0.08,0.1];
         var _loc514_:*;
         this.IPTData[_loc514_ = _loc1_++] = ["Wood: Hardwood","HSS Reamer",0.0029375,0.0158625,0.01968125,0.0235,0.0287875,0.034075,0.04465,0.047,0.0705,0.094,0.141,0.188,0.235];
         var _loc515_:*;
         this.IPTData[_loc515_ = _loc1_++] = ["Wood: Hardwood","Indexable Drill",0.000625,0.003375,0.0041875,0.005,0.006125,0.00725,0.0095,0.01,0.015,0.02,0.03,0.04,0.05];
         var _loc516_:*;
         this.IPTData[_loc516_ = _loc1_++] = ["Wood: Hardwood","Cobalt Twist Drill",0.001875,0.010125,0.0125625,0.015,0.018375,0.02175,0.0285,0.03,0.045,0.06,0.09,0.12,0.15];
         var _loc517_:*;
         this.IPTData[_loc517_ = _loc1_++] = ["Wood: Hardwood","HP HSS Endmill",0.00165,0.00891,0.011055,0.0132,0.01617,0.01914,0.02508,0.0264,0.0396,0.0528,0.0792,0.1056,0.132];
         var _loc518_:*;
         this.IPTData[_loc518_ = _loc1_++] = ["Wood: Hardwood","HP HSS Twist Drill",0.0020625,0.0111375,0.01381875,0.0165,0.0202125,0.023925,0.03135,0.033,0.0495,0.066,0.099,0.132,0.165];
         var _loc519_:*;
         this.IPTData[_loc519_ = _loc1_++] = ["Wood: Hardwood","HP Carbide Endmill",0.0018,0.00972,0.01206,0.0144,0.01764,0.02088,0.02736,0.0288,0.0432,0.0576,0.0864,0.1152,0.144];
         var _loc520_:*;
         this.IPTData[_loc520_ = _loc1_++] = ["Wood: Hardwood","TiAlN Carbide Endmill",0.0018,0.00972,0.01206,0.0144,0.01764,0.02088,0.02736,0.0288,0.0432,0.0576,0.0864,0.1152,0.144];
         var _loc521_:*;
         this.IPTData[_loc521_ = _loc1_++] = ["Wood: Hardwood","HP Carbide Twist Drill",0.0020625,0.0111375,0.01381875,0.0165,0.0202125,0.023925,0.03135,0.033,0.0495,0.066,0.099,0.132,0.165];
         var _loc522_:*;
         this.IPTData[_loc522_ = _loc1_++] = ["Wood: Hardwood","Indexable End Or Face Mill",0.004375,0.023625,0.0293125,0.035,0.042875,0.05075,0.0665,0.07,0.105,0.14,0.21,0.28,0.35];
         var _loc523_:*;
         this.IPTData[_loc523_ = _loc1_++] = ["Wood: Hardwood","Turning: HSS",0.01125,0.06075,0.075375,0.09,0.11025,0.1305,0.171,0.18,0.27,0.36,0.54,0.72,0.9];
         var _loc524_:*;
         this.IPTData[_loc524_ = _loc1_++] = ["Wood: Hardwood","Turning: Carbide",0.01125,0.06075,0.075375,0.09,0.11025,0.1305,0.171,0.18,0.27,0.36,0.54,0.72,0.9];
         var _loc525_:*;
         this.IPTData[_loc525_ = _loc1_++] = ["Wood: MDF","HSS Spot Drill",0.0035375,0.007075,0.007325,0.008325,0.008825,0.009825,0.011325,0.011325,0.011325,0.011325,0.011325,0.011325,0.011325];
         var _loc526_:*;
         this.IPTData[_loc526_ = _loc1_++] = ["Wood: MDF","HSS Twist Drill",0.007075,0.01415,0.01465,0.01665,0.01765,0.01965,0.02265,0.02265,0.02265,0.02265,0.02265,0.02265,0.02265];
         var _loc527_:*;
         this.IPTData[_loc527_ = _loc1_++] = ["Wood: MDF","Carbide Twist Drill",0.007075,0.01415,0.01465,0.01665,0.01765,0.01965,0.02265,0.02265,0.02265,0.02265,0.02265,0.02265,0.02265];
         var _loc528_:*;
         this.IPTData[_loc528_ = _loc1_++] = ["Wood: MDF","HSS Spade Drill",0.01415,0.0283,0.0293,0.0333,0.0353,0.0393,0.0453,0.0453,0.0453,0.0453,0.0453,0.0453,0.0453];
         var _loc529_:*;
         this.IPTData[_loc529_ = _loc1_++] = ["Wood: MDF","Gun Drill",0.000471666666666667,0.000943333333333333,0.000976666666666666,0.00111,0.00117666666666667,0.00131,0.00151,0.00151,0.00151,0.00151,0.00151,0.00151,0.00151];
         var _loc530_:*;
         this.IPTData[_loc530_ = _loc1_++] = ["Wood: MDF","HSS Endmill",0.00566,0.01132,0.01172,0.01332,0.01412,0.01572,0.01812,0.01812,0.01812,0.01812,0.01812,0.01812,0.01812];
         var _loc531_:*;
         this.IPTData[_loc531_ = _loc1_++] = ["Wood: MDF","Carbide Endmill",0.00471666666666667,0.00943333333333333,0.00976666666666667,0.0111,0.0117666666666667,0.0131,0.0151,0.0151,0.0151,0.0151,0.0151,0.0151,0.0151];
         var _loc532_:*;
         this.IPTData[_loc532_ = _loc1_++] = ["Wood: MDF","HSS Reamer",0.0110841666666667,0.0221683333333333,0.0229516666666667,0.026085,0.0276516666666667,0.030785,0.035485,0.035485,0.035485,0.035485,0.035485,0.035485,0.035485];
         var _loc533_:*;
         this.IPTData[_loc533_ = _loc1_++] = ["Wood: MDF","Indexable Drill",0.00235833333333333,0.00471666666666667,0.00488333333333333,0.00555,0.00588333333333333,0.00655,0.00755,0.00755,0.00755,0.00755,0.00755,0.00755,0.00755];
         var _loc534_:*;
         this.IPTData[_loc534_ = _loc1_++] = ["Wood: MDF","Cobalt Twist Drill",0.007075,0.01415,0.01465,0.01665,0.01765,0.01965,0.02265,0.02265,0.02265,0.02265,0.02265,0.02265,0.02265];
         var _loc535_:*;
         this.IPTData[_loc535_ = _loc1_++] = ["Wood: MDF","HP HSS Endmill",0.006226,0.012452,0.012892,0.014652,0.015532,0.017292,0.019932,0.019932,0.019932,0.019932,0.019932,0.019932,0.019932];
         var _loc536_:*;
         this.IPTData[_loc536_ = _loc1_++] = ["Wood: MDF","HP HSS Twist Drill",0.0077825,0.015565,0.016115,0.018315,0.019415,0.021615,0.024915,0.024915,0.024915,0.024915,0.024915,0.024915,0.024915];
         var _loc537_:*;
         this.IPTData[_loc537_ = _loc1_++] = ["Wood: MDF","HP Carbide Endmill",0.006792,0.013584,0.014064,0.015984,0.016944,0.018864,0.021744,0.021744,0.021744,0.021744,0.021744,0.021744,0.021744];
         var _loc538_:*;
         this.IPTData[_loc538_ = _loc1_++] = ["Wood: MDF","TiAlN Carbide Endmill",0.006792,0.013584,0.014064,0.015984,0.016944,0.018864,0.021744,0.021744,0.021744,0.021744,0.021744,0.021744,0.021744];
         var _loc539_:*;
         this.IPTData[_loc539_ = _loc1_++] = ["Wood: MDF","HP Carbide Twist Drill",0.0077825,0.015565,0.016115,0.018315,0.019415,0.021615,0.024915,0.024915,0.024915,0.024915,0.024915,0.024915,0.024915];
         var _loc540_:*;
         this.IPTData[_loc540_ = _loc1_++] = ["Wood: MDF","Indexable End Or Face Mill",0.0165083333333333,0.0330166666666667,0.0341833333333333,0.03885,0.0411833333333333,0.04585,0.05285,0.05285,0.05285,0.05285,0.05285,0.05285,0.05285];
         var _loc541_:*;
         this.IPTData[_loc541_ = _loc1_++] = ["Wood: MDF","Turning: HSS",0.04245,0.0849,0.0879,0.0999,0.1059,0.1179,0.1359,0.1359,0.1359,0.1359,0.1359,0.1359,0.1359];
         var _loc542_:*;
         this.IPTData[_loc542_ = _loc1_++] = ["Wood: MDF","Turning: Carbide",0.04245,0.0849,0.0879,0.0999,0.1059,0.1179,0.1359,0.1359,0.1359,0.1359,0.1359,0.1359,0.1359];
         var _loc543_:*;
         this.IPTData[_loc543_ = _loc1_++] = ["Wood: Plywood","HSS Spot Drill",0.0043275,0.008655,0.008955,0.009255,0.009855,0.010755,0.012405,0.012405,0.012405,0.012405,0.012405,0.012405,0.012405];
         var _loc544_:*;
         this.IPTData[_loc544_ = _loc1_++] = ["Wood: Plywood","HSS Twist Drill",0.008655,0.01731,0.01791,0.01851,0.01971,0.02151,0.02481,0.02481,0.02481,0.02481,0.02481,0.02481,0.02481];
         var _loc545_:*;
         this.IPTData[_loc545_ = _loc1_++] = ["Wood: Plywood","Carbide Twist Drill",0.008655,0.01731,0.01791,0.01851,0.01971,0.02151,0.02481,0.02481,0.02481,0.02481,0.02481,0.02481,0.02481];
         var _loc546_:*;
         this.IPTData[_loc546_ = _loc1_++] = ["Wood: Plywood","HSS Spade Drill",0.01731,0.03462,0.03582,0.03702,0.03942,0.04302,0.04962,0.04962,0.04962,0.04962,0.04962,0.04962,0.04962];
         var _loc547_:*;
         this.IPTData[_loc547_ = _loc1_++] = ["Wood: Plywood","Gun Drill",0.000577,0.001154,0.001194,0.001234,0.001314,0.001434,0.001654,0.001654,0.001654,0.001654,0.001654,0.001654,0.001654];
         var _loc548_:*;
         this.IPTData[_loc548_ = _loc1_++] = ["Wood: Plywood","HSS Endmill",0.006924,0.013848,0.014328,0.014808,0.015768,0.017208,0.019848,0.019848,0.019848,0.019848,0.019848,0.019848,0.019848];
         var _loc549_:*;
         this.IPTData[_loc549_ = _loc1_++] = ["Wood: Plywood","Carbide Endmill",0.00577,0.01154,0.01194,0.01234,0.01314,0.01434,0.01654,0.01654,0.01654,0.01654,0.01654,0.01654,0.01654];
         var _loc550_:*;
         this.IPTData[_loc550_ = _loc1_++] = ["Wood: Plywood","HSS Reamer",0.0135595,0.027119,0.028059,0.028999,0.030879,0.033699,0.038869,0.038869,0.038869,0.038869,0.038869,0.038869,0.038869];
         var _loc551_:*;
         this.IPTData[_loc551_ = _loc1_++] = ["Wood: Plywood","Indexable Drill",0.002885,0.00577,0.00597,0.00617,0.00657,0.00717,0.00827,0.00827,0.00827,0.00827,0.00827,0.00827,0.00827];
         var _loc552_:*;
         this.IPTData[_loc552_ = _loc1_++] = ["Wood: Plywood","Cobalt Twist Drill",0.008655,0.01731,0.01791,0.01851,0.01971,0.02151,0.02481,0.02481,0.02481,0.02481,0.02481,0.02481,0.02481];
         var _loc553_:*;
         this.IPTData[_loc553_ = _loc1_++] = ["Wood: Plywood","HP HSS Endmill",0.0076164,0.0152328,0.0157608,0.0162888,0.0173448,0.0189288,0.0218328,0.0218328,0.0218328,0.0218328,0.0218328,0.0218328,0.0218328];
         var _loc554_:*;
         this.IPTData[_loc554_ = _loc1_++] = ["Wood: Plywood","HP HSS Twist Drill",0.0095205,0.019041,0.019701,0.020361,0.021681,0.023661,0.027291,0.027291,0.027291,0.027291,0.027291,0.027291,0.027291];
         var _loc555_:*;
         this.IPTData[_loc555_ = _loc1_++] = ["Wood: Plywood","HP Carbide Endmill",0.0083088,0.0166176,0.0171936,0.0177696,0.0189216,0.0206496,0.0238176,0.0238176,0.0238176,0.0238176,0.0238176,0.0238176,0.0238176];
         var _loc556_:*;
         this.IPTData[_loc556_ = _loc1_++] = ["Wood: Plywood","TiAlN Carbide Endmill",0.0083088,0.0166176,0.0171936,0.0177696,0.0189216,0.0206496,0.0238176,0.0238176,0.0238176,0.0238176,0.0238176,0.0238176,0.0238176];
         var _loc557_:*;
         this.IPTData[_loc557_ = _loc1_++] = ["Wood: Plywood","HP Carbide Twist Drill",0.0095205,0.019041,0.019701,0.020361,0.021681,0.023661,0.027291,0.027291,0.027291,0.027291,0.027291,0.027291,0.027291];
         var _loc558_:*;
         this.IPTData[_loc558_ = _loc1_++] = ["Wood: Plywood","Indexable End Or Face Mill",0.020195,0.04039,0.04179,0.04319,0.04599,0.05019,0.05789,0.05789,0.05789,0.05789,0.05789,0.05789,0.05789];
         var _loc559_:*;
         this.IPTData[_loc559_ = _loc1_++] = ["Wood: Plywood","Turning: HSS",0.05193,0.10386,0.10746,0.11106,0.11826,0.12906,0.14886,0.14886,0.14886,0.14886,0.14886,0.14886,0.14886];
         var _loc560_:*;
         this.IPTData[_loc560_ = _loc1_++] = ["Wood: Plywood","Turning: Carbide",0.05193,0.10386,0.10746,0.11106,0.11826,0.12906,0.14886,0.14886,0.14886,0.14886,0.14886,0.14886,0.14886];
         var _loc561_:*;
         this.IPTData[_loc561_ = _loc1_++] = ["Wood: Softwood","HSS Spot Drill",0.001875,0.00565,0.006775,0.0079,0.00965,0.0114,0.0149,0.0171,0.0246,0.0321,0.0471,0.0621,0.0771];
         var _loc562_:*;
         this.IPTData[_loc562_ = _loc1_++] = ["Wood: Softwood","HSS Twist Drill",0.00375,0.0113,0.01355,0.0158,0.0193,0.0228,0.0298,0.0342,0.0492,0.0642,0.0942,0.1242,0.1542];
         var _loc563_:*;
         this.IPTData[_loc563_ = _loc1_++] = ["Wood: Softwood","Carbide Twist Drill",0.00375,0.0113,0.01355,0.0158,0.0193,0.0228,0.0298,0.0342,0.0492,0.0642,0.0942,0.1242,0.1542];
         var _loc564_:*;
         this.IPTData[_loc564_ = _loc1_++] = ["Wood: Softwood","HSS Spade Drill",0.0075,0.0226,0.0271,0.0316,0.0386,0.0456,0.0596,0.0684,0.0984,0.1284,0.1884,0.2484,0.3084];
         var _loc565_:*;
         this.IPTData[_loc565_ = _loc1_++] = ["Wood: Softwood","Gun Drill",0.00025,0.000753333333333333,0.000903333333333333,0.00105333333333333,0.00128666666666667,0.00152,0.00198666666666667,0.00228,0.00328,0.00428,0.00628,0.00828,0.01028];
         var _loc566_:*;
         this.IPTData[_loc566_ = _loc1_++] = ["Wood: Softwood","HSS Endmill",0.003,0.00904,0.01084,0.01264,0.01544,0.01824,0.02384,0.02736,0.03936,0.05136,0.07536,0.09936,0.12336];
         var _loc567_:*;
         this.IPTData[_loc567_ = _loc1_++] = ["Wood: Softwood","Carbide Endmill",0.0025,0.00753333333333333,0.00903333333333333,0.0105333333333333,0.0128666666666667,0.0152,0.0198666666666667,0.0228,0.0328,0.0428,0.0628,0.0828,0.1028];
         var _loc568_:*;
         this.IPTData[_loc568_ = _loc1_++] = ["Wood: Softwood","HSS Reamer",0.005875,0.0177033333333333,0.0212283333333333,0.0247533333333333,0.0302366666666667,0.03572,0.0466866666666667,0.05358,0.07708,0.10058,0.14758,0.19458,0.24158];
         var _loc569_:*;
         this.IPTData[_loc569_ = _loc1_++] = ["Wood: Softwood","Indexable Drill",0.00125,0.00376666666666667,0.00451666666666667,0.00526666666666667,0.00643333333333333,0.0076,0.00993333333333333,0.0114,0.0164,0.0214,0.0314,0.0414,0.0514];
         var _loc570_:*;
         this.IPTData[_loc570_ = _loc1_++] = ["Wood: Softwood","Cobalt Twist Drill",0.00375,0.0113,0.01355,0.0158,0.0193,0.0228,0.0298,0.0342,0.0492,0.0642,0.0942,0.1242,0.1542];
         var _loc571_:*;
         this.IPTData[_loc571_ = _loc1_++] = ["Wood: Softwood","HP HSS Endmill",0.0033,0.009944,0.011924,0.013904,0.016984,0.020064,0.026224,0.030096,0.043296,0.056496,0.082896,0.109296,0.135696];
         var _loc572_:*;
         this.IPTData[_loc572_ = _loc1_++] = ["Wood: Softwood","HP HSS Twist Drill",0.004125,0.01243,0.014905,0.01738,0.02123,0.02508,0.03278,0.03762,0.05412,0.07062,0.10362,0.13662,0.16962];
         var _loc573_:*;
         this.IPTData[_loc573_ = _loc1_++] = ["Wood: Softwood","HP Carbide Endmill",0.0036,0.010848,0.013008,0.015168,0.018528,0.021888,0.028608,0.032832,0.047232,0.061632,0.090432,0.119232,0.148032];
         var _loc574_:*;
         this.IPTData[_loc574_ = _loc1_++] = ["Wood: Softwood","TiAlN Carbide Endmill",0.0036,0.010848,0.013008,0.015168,0.018528,0.021888,0.028608,0.032832,0.047232,0.061632,0.090432,0.119232,0.148032];
         var _loc575_:*;
         this.IPTData[_loc575_ = _loc1_++] = ["Wood: Softwood","HP Carbide Twist Drill",0.004125,0.01243,0.014905,0.01738,0.02123,0.02508,0.03278,0.03762,0.05412,0.07062,0.10362,0.13662,0.16962];
         var _loc576_:*;
         this.IPTData[_loc576_ = _loc1_++] = ["Wood: Softwood","Indexable End Or Face Mill",0.00875,0.0263666666666667,0.0316166666666667,0.0368666666666667,0.0450333333333333,0.0532,0.0695333333333333,0.0798,0.1148,0.1498,0.2198,0.2898,0.3598];
         var _loc577_:*;
         this.IPTData[_loc577_ = _loc1_++] = ["Wood: Softwood","Turning: HSS",0.0225,0.0678,0.0813,0.0948,0.1158,0.1368,0.1788,0.2052,0.2952,0.3852,0.5652,0.7452,0.9252];
         var _loc578_:*;
         this.IPTData[_loc578_ = _loc1_++] = ["Wood: Softwood","Turning: Carbide",0.0225,0.0678,0.0813,0.0948,0.1158,0.1368,0.1788,0.2052,0.2952,0.3852,0.5652,0.7452,0.9252];
      }
      
      private function scanIPTTable(param1:String) : Number
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         GWizUtils.LogErrorContext = "GWizFeedSpeedMath.scanIPTTable";
         this.familyInPlay = false;
         if(this.mfgIPT.isOverridden())
         {
            _loc2_ = this.mfgIPT.value;
         }
         else
         {
            _loc2_ = this.scanIPTTableAux(param1,this.materialName,this.toolParms.toolDiam);
            if(GWizSettings.jankaHardness > 0)
            {
               _loc2_ *= GWizMaterialsDB.woodFeedrateFactor(GWizSettings.jankaHardness);
            }
            _loc3_ = _loc2_;
            _loc2_ = GWizMfgCutterSpecs.familyIPT(_loc2_,this.materialName,this.toolParms.toolDiam);
            this.familyInPlay = _loc2_ != _loc3_;
            if(GWizAbstractPrefs.isOEM)
            {
               _loc4_ = this.toolParms.cribProduct;
               if((_loc5_ = GWizGarrOEMToolData.lookupIPT(this.materialName,this.adjHardness,_loc4_,this.toolParms.toolDiam,_loc2_,this.cutDepth,this.cutWidth)) != _loc2_)
               {
                  _loc2_ = _loc5_;
                  this.familyInPlay = true;
               }
            }
            this.mfgIPT.value = _loc2_;
         }
         _loc2_ *= GWizMatBrowser2.alloyIPTTweak;
         if(param1.search("Saws & Woodruff Cutters") != -1)
         {
            _loc2_ = this.sawTPIAdjust(_loc2_);
         }
         else if(!this.familyInPlay && this.toolParms.cornerRadius > 0.03 && !this.toolParms.isBallnose() && !this.mfgIPT.isOverridden() && param1.search("Indexable End Or Face Mill") != -1)
         {
            _loc2_ *= 1.25;
         }
         return _loc2_;
      }
      
      private function calculatedToolTypes(param1:String) : String
      {
         switch(param1)
         {
            case "HSS Reamer":
               param1 = "HSS Twist Drill";
               break;
            case "Carbide Reamer":
               param1 = "Carbide Twist Drill";
               break;
            case "Carbide Spot Drill":
               param1 = "HSS Spot Drill";
               break;
            case "HSS Center Drill":
               param1 = "HSS Twist Drill";
               break;
            case "Carbide Center Drill":
               param1 = "Carbide Twist Drill";
               break;
            case "Carbide Spade Drill":
               param1 = "HSS Spade Drill";
               break;
            case "Carbide Saws & Woodruff Cutters":
               param1 = "Carbide Endmill";
               break;
            case "HSS Saws & Woodruff Cutters":
               param1 = "HSS Endmill";
               break;
            case "Carbide Thread Mill":
               param1 = "Carbide Endmill";
               break;
            case "Carbide Parting/Grooving":
            case "Carbide Parting":
            case "Carbide Grooving":
            case "Carbide Boring Bar":
            case "Carbide Threading":
            case "Carbide Turning":
               param1 = "Turning: Carbide";
               break;
            case "HSS Parting/Grooving":
            case "HSS Parting":
            case "HSS Grooving":
            case "HSS Boring Bar":
            case "HSS Threading":
            case "HSS Turning":
               param1 = "Turning: HSS";
         }
         return param1;
      }
      
      public function scanIPTTableAux(param1:String, param2:String, param3:Number) : Number
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         GWizUtils.LogErrorContext = "GWizFeedSpeedMath.scanIPTTableAux";
         var _loc4_:Number = 0.00001;
         var _loc5_:String = param1;
         if(this.IPTData == null)
         {
            this.initIPTData();
         }
         param1 = this.calculatedToolTypes(param1);
         if(this.USE_IPT_CACHE && this.iptCacheToolType == param1 && this.iptCacheMaterial == param2 && this.iptCacheDiameter == param3)
         {
            _loc4_ = this.iptTableCache;
         }
         else if(param1.toLowerCase().indexOf("rotabroach") >= 0)
         {
            if(this.toolParms.toolDiam <= 1)
            {
               _loc4_ = 0.003;
            }
            else if(this.toolParms.toolDiam <= 2.5)
            {
               _loc4_ = 0.004;
            }
            else
            {
               _loc4_ = 0.005;
            }
         }
         else
         {
            _loc6_ = 0;
            while(_loc6_ < this.IPTData.length && this.IPTData[_loc6_][GWizConfigData.IPTData_Material] != param2)
            {
               _loc6_++;
            }
            if(_loc6_ < this.IPTData.length && this.IPTData[_loc6_][GWizConfigData.IPTData_Material] == param2)
            {
               while(_loc6_ < this.IPTData.length && this.IPTData[_loc6_][GWizConfigData.IPTData_Tool] != param1)
               {
                  _loc6_++;
               }
               if(_loc6_ < this.IPTData.length && this.IPTData[_loc6_][GWizConfigData.IPTData_Tool] == param1)
               {
                  _loc7_ = GWizConfigData.IPTData_FirstDiameter;
                  _loc8_ = GWizConfigData.IPTData_FirstDiameter;
                  _loc9_ = GWizConfigData.IPTData_FirstDiameter;
                  _loc7_ = GWizConfigData.IPTData_FirstDiameter;
                  while(_loc7_ <= GWizConfigData.IPTData_LasttoolDiameter)
                  {
                     if(this.IPTData[0][_loc7_] <= param3)
                     {
                        _loc8_ = _loc7_;
                     }
                     if(this.IPTData[0][_loc7_] >= param3 || param1.indexOf("Turning") >= 0)
                     {
                        break;
                     }
                     _loc7_++;
                  }
                  if(_loc7_ <= GWizConfigData.IPTData_LasttoolDiameter)
                  {
                     _loc9_ = _loc7_;
                  }
                  else
                  {
                     _loc7_ = GWizConfigData.IPTData_LasttoolDiameter;
                  }
                  if(this.IPTData[0][_loc8_] == param3)
                  {
                     _loc4_ = this.IPTData[_loc6_][_loc8_];
                  }
                  else if(this.IPTData[0][_loc9_] == param3)
                  {
                     _loc4_ = this.IPTData[_loc6_][_loc9_];
                  }
                  else
                  {
                     _loc4_ = GWizUtils.interpolate(this.IPTData[0][_loc8_],this.IPTData[_loc6_][_loc8_],param3,this.IPTData[0][_loc9_],this.IPTData[_loc6_][_loc9_]);
                  }
               }
            }
            if(this.toolParms.isEndmill())
            {
               if(this.toolParms.flutes > 4)
               {
                  if(this.toolParms.flutes > 5)
                  {
                     if(this.toolParms.flutes > 6)
                     {
                        _loc4_ *= 0.7;
                     }
                     else
                     {
                        _loc4_ *= 0.75;
                     }
                  }
                  else
                  {
                     _loc4_ *= 0.85;
                  }
               }
            }
            this.iptCacheToolType = param1;
            this.iptCacheMaterial = param2;
            this.iptCacheDiameter = param3;
            this.iptTableCache = _loc4_;
         }
         switch(_loc5_)
         {
            case "Carbide Saws & Woodruff Cutters":
               _loc4_ = (0.0002 + 0.0015) / 2;
               break;
            case "HSS Saws & Woodruff Cutters":
               _loc4_ = 0.0012;
               break;
            case "Carbide Parting/Grooving":
            case "Carbide Parting":
            case "Carbide Grooving":
            case "HSS Parting/Grooving":
            case "HSS Parting":
            case "HSS Grooving":
            case "Carbide Threading":
            case "HSS Threading":
               _loc4_ *= 0.35;
               break;
            case "Carbide Thread Mill":
               _loc4_ *= this.lookupThreadMillIPTAdjust();
               break;
            case "Carbide Spot Drill":
            case "HSS Spot Drill":
               _loc4_ *= 2;
               break;
            case "Probe":
            case "Other":
            case "Empty Toolholder":
            case GWizToolData.EMPTY_SLOT:
               _loc4_ = 0;
         }
         return _loc4_;
      }
      
      private function sawTPIAdjust(param1:Number) : Number
      {
         var _loc2_:Number = 0;
         if(this.cutWidth < 0.5)
         {
            _loc2_ = 10;
         }
         else if(this.cutWidth < 0.7)
         {
            _loc2_ = 8;
         }
         else if(this.cutWidth < 1)
         {
            _loc2_ = 6;
         }
         else if(this.cutWidth < 1.34)
         {
            _loc2_ = 5;
         }
         else if(this.cutWidth < 1.85)
         {
            _loc2_ = 4;
         }
         else if(this.cutWidth < 3.15)
         {
            _loc2_ = 3;
         }
         else if(this.cutWidth < 4.92)
         {
            _loc2_ = 2;
         }
         if(this.maxBHN <= 150)
         {
            _loc2_ *= 1.2;
         }
         var _loc3_:Number = this.toolParms.toolDiam * Math.PI;
         this.bestTeeth = _loc3_ * _loc2_;
         var _loc4_:Number = Math.min(this.bestTeeth / Number(this.toolParms.flutes),1.5);
         param1 *= _loc4_;
         param1 = Math.max(param1,0.0001);
         param1 *= 0.0004 / 0.0013;
         if(this.cutDepth < 0.031)
         {
            param1 *= 0.5;
         }
         return param1;
      }
      
      private function lookupIPT() : Number
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Object = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         GWizUtils.LogErrorContext = "GWizFeedSpeedMath.lookupIPT";
         var _loc1_:Number = 0.00001;
         if(this.materialName == "" || this.toolParms.toolType == "" || this.toolParms.toolType == "Tapping" || this.toolParms.toolType == "Carbide Tapping" || this.toolParms.toolType == "HSS Tapping")
         {
            return _loc1_;
         }
         var _loc2_:Number = this.lookupMaxHardness();
         var _loc3_:String = this.toolParms.toolType;
         if(this.toolParms.isPCD())
         {
            this.toolParms.toolType = "TiAlN Carbide Endmill";
         }
         if(this.toolParms.toolDiam >= this.MIN_TABLE_DIAMETER)
         {
            _loc1_ = this.scanIPTTable(this.toolParms.toolType);
         }
         else
         {
            if(_loc2_ > 561)
            {
               _loc1_ = 0.0134 * this.toolParms.toolDiam;
            }
            else
            {
               _loc1_ = 0.0201 * this.toolParms.toolDiam;
            }
            _loc5_ = this.scanIPTTable(this.toolParms.toolType) / this.scanIPTTable("Carbide Endmill");
            _loc1_ *= _loc5_;
            _loc6_ = this.scanIPTTable(this.toolParms.toolType);
            _loc1_ = Math.min(_loc1_,_loc6_);
         }
         this.toolParms.toolType = _loc3_;
         if(this.toolParms.isPCD())
         {
            if((_loc7_ = GWizConfigData.findMaterialMF(this.materialName)) && _loc7_.hasOwnProperty("pcdEM"))
            {
               _loc8_ = _loc7_.pcdEM;
               if(this.toolParms.isTwistDrill())
               {
                  if(_loc8_ > 1)
                  {
                     _loc8_ /= 2;
                  }
                  else
                  {
                     _loc8_ *= 0.84;
                  }
               }
               _loc1_ *= _loc8_;
            }
         }
         if(this.toolParms.isRougher())
         {
            _loc1_ *= 1.38;
         }
         _loc1_ = this.toolParms.delicateBitIPT(_loc1_);
         this.axialFeedAdjust = 1;
         if(this.toolParms.isTwistDrill())
         {
            if(!this.toolParms.isParabolic())
            {
               if(this.axialEngagement >= 700)
               {
                  this.axialFeedAdjust = GWizUtils.interpolate(700,0.8,this.axialEngagement,1500,0.1);
               }
               else if(this.axialEngagement >= 500)
               {
                  this.axialFeedAdjust = GWizUtils.interpolate(500,0.9,this.axialEngagement,700,0.8);
               }
               else if(this.axialEngagement >= 300)
               {
                  this.axialFeedAdjust = GWizUtils.interpolate(300,1,this.axialEngagement,500,0.9);
               }
               _loc1_ *= this.axialFeedAdjust;
            }
         }
         else
         {
            _loc9_ = 1;
            if(_loc2_ <= 0)
            {
               _loc9_ = 1.4;
            }
            if((_loc10_ = this.cutWidth / this.toolParms.toolDiam * 100) >= 20)
            {
               if(this.axialEngagement > 700)
               {
                  this.axialFeedAdjust = 0;
               }
               else if(this.axialEngagement >= 400)
               {
                  this.axialFeedAdjust = GWizUtils.interpolate(400,0.3,this.axialEngagement,700,0.2) * _loc9_;
               }
               else if(this.axialEngagement >= 300)
               {
                  this.axialFeedAdjust = GWizUtils.interpolate(300,0.4,this.axialEngagement,400,0.3) * _loc9_;
               }
               else if(this.axialEngagement >= 200)
               {
                  this.axialFeedAdjust = GWizUtils.interpolate(200,0.5,this.axialEngagement,300,0.4) * _loc9_;
               }
               else if(this.axialEngagement >= 100)
               {
                  this.axialFeedAdjust = Math.min(GWizUtils.interpolate(100,0.9,this.axialEngagement,200,0.5) * _loc9_,GWizUtils.interpolate(100,1,this.axialEngagement,200,0.9));
               }
               else if(this.axialEngagement >= 50)
               {
                  this.axialFeedAdjust = GWizUtils.interpolate(50,1,this.axialEngagement,100,0.9);
               }
            }
            _loc1_ *= this.axialFeedAdjust;
         }
         if(this.rigidity == "Rigid" && this.isChipThinnable())
         {
            if(this.toolParms.rigidityUpgrade())
            {
               _loc1_ *= this.RIGIDITY_UPGRADE;
            }
            else
            {
               _loc1_ *= 1 + (this.RIGIDITY_UPGRADE - 1) / 2;
            }
         }
         _loc1_ = this.gasPedalIPTAdjust(_loc1_);
         var _loc4_:Number = this.bestFinishChipload(this.effDiam,this.mfgIPT.value);
         return Math.max(_loc4_,_loc1_ * (this.miptAdjust / 100));
      }
      
      private function filterMF(param1:Object) : Boolean
      {
         return param1.material == this.materialName;
      }
      
      private function lookupMF() : Number
      {
         var _loc3_:Number = NaN;
         if(this.materialName == null || this.materialName.length == 0)
         {
            return 0.21;
         }
         var _loc1_:Object = GWizConfigData.findMaterialMF(this.materialName);
         var _loc2_:Number = 2.9;
         drillHints = "";
         if(_loc1_)
         {
            if(_loc1_.drillStyle)
            {
               drillHints += "Drill Style: " + _loc1_.drillStyle + " ";
            }
            if(_loc1_.pointStyle)
            {
               drillHints += "Point Style: " + _loc1_.pointStyle + " ";
            }
            if(_loc1_.pointAngle)
            {
               drillHints += "Point Angle: " + _loc1_.pointAngle + " ";
            }
            _loc2_ = _loc1_.mf;
         }
         if(this.toolParms.isEndmill() || this.toolParms.isIndexableMillTool())
         {
            if(this.cutDepth > 0)
            {
               _loc3_ = this.cutWidth / this.toolParms.toolDiam;
               if(_loc3_ > 0.66)
               {
                  _loc2_ *= 1.11;
               }
               else if(_loc3_ >= 1)
               {
                  _loc2_ *= 1.21;
               }
            }
            if(this.toolParms.toolType == "TiAlN Carbide Endmill")
            {
               _loc2_ *= 0.9;
            }
            if(this.toolParms.isRougher())
            {
               _loc2_ *= 0.9;
            }
            _loc2_ *= 0.6;
         }
         else if(this.toolParms.isTwistDrill())
         {
            if(this.materialName.toLocaleLowerCase().indexOf("iron") >= 0)
            {
               _loc2_ *= 1.4;
            }
            else
            {
               _loc2_ *= 0.88;
            }
         }
         return _loc2_;
      }
      
      private function lookupMaxHardness() : Number
      {
         if(this.materialName == null || this.materialName.length == 0)
         {
            return 410;
         }
         var _loc1_:Object = GWizConfigData.findMaterialMF(this.materialName);
         if(_loc1_)
         {
            this.maxBHN = _loc1_.maxBHN;
            this.minBHN = _loc1_.minBHN;
            if(this.isCarbide())
            {
               this.sfmRange = _loc1_.sfmrange;
            }
            else
            {
               this.sfmRange = _loc1_.sfmrangehss;
            }
         }
         else
         {
            this.maxBHN = 410;
         }
         return this.maxBHN;
      }
      
      private function lookupThreadMillIPTAdjust() : Number
      {
         if(this.materialName == null || this.materialName.length == 0)
         {
            return 0.8 * 0.6;
         }
         var _loc1_:Object = GWizConfigData.findMaterialMF(this.materialName);
         if(!_loc1_)
         {
            return 0.8 * 0.6;
         }
         return _loc1_.threadMill * 0.6;
      }
      
      public function axialEngagementHint(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(this.toolParms.isEndmill() && this.radialEngagement < 0.001)
         {
            GWizSettings.FeedsSpeedsApp.addTip("Warning: Need non-zero Cut Depth for Feeds & Speeds",true);
         }
         if(this.notEnoughPowerErr)
         {
            GWizSettings.FeedsSpeedsApp.addTip("Error: Not enough spindle power available.");
         }
         if(this.toolParms.isSpotDrill() && param1 > 150)
         {
            GWizSettings.FeedsSpeedsApp.addTip("Warning: Hole Too Deep: Not Recommended!",true);
         }
         if(this.sfm.value == 0 && this.toolParms.isPCD())
         {
            GWizSettings.FeedsSpeedsApp.addTip("Warning: Material is not compatible with PCD tooling.");
         }
         if(this.toolParms.isTwistDrill())
         {
            if(!this.toolParms.isParabolic())
            {
               if(param1 > 700)
               {
                  GWizSettings.FeedsSpeedsApp.addTip("Warning: Hole Too Deep: Need Parabolic Flute Drill.");
               }
               else if(param1 > 300 && !this.tsc)
               {
                  GWizSettings.FeedsSpeedsApp.addTip(this.peckDepthMsg(this.toolParms.toolDiam,this.cutDepth,this.toolParms.isHP(),this.toolParms.isCarbide(),this.tsc));
               }
            }
            else if(param1 > 2000)
            {
               GWizSettings.FeedsSpeedsApp.addTip("Warning: Hole Too Deep: Not Recommended.",true);
            }
            else
            {
               if(param1 > 700)
               {
                  GWizSettings.FeedsSpeedsApp.addTip("Drill a pilot hole 2xD deep.");
               }
               if(param1 > 300)
               {
                  GWizSettings.FeedsSpeedsApp.addTip(this.peckDepthMsg(this.toolParms.toolDiam,this.cutDepth,this.toolParms.isHP(),this.toolParms.isCarbide(),this.tsc));
               }
            }
            if(drillHints.length > 0)
            {
               GWizSettings.FeedsSpeedsApp.addTip(drillHints);
            }
         }
         else if((this.toolParms.toolType == "Tapping" || this.toolParms.toolType == "Carbide Tapping" || this.toolParms.toolType == "HSS Tapping") && this.sfm.value <= 0)
         {
            GWizSettings.FeedsSpeedsApp.addTip("Warning: Not Recommended. Material too hard to form tap.",true);
         }
         else if(this.toolParms.toolType.indexOf("Grooving") >= 0)
         {
            GWizSettings.FeedsSpeedsApp.addTip("Increase feeds up to 15% for OD grooving");
         }
         else if(param1 >= this.MAX_AXIAL_ENGAGEMENT && this.toolParms.toolType.indexOf("Gun Drill") < 0)
         {
            GWizSettings.FeedsSpeedsApp.addTip("Warning: Not Recommended. Too Much Axial Engagement",true);
         }
         else if(this.toolParms.toolType.indexOf("Saw") >= 0)
         {
            if(this.cutWidth > 4 * this.cutDepth)
            {
               GWizSettings.FeedsSpeedsApp.addTip("Warning: Can\'t cut deeper than 4x saw thickness.",true);
            }
         }
         else
         {
            _loc2_ = this.toolParms.stickout / Math.max(this.toolParms.toolDiam,this.toolParms.shankSize);
            if(this.toolParms.toolmaterial == "HSS" && _loc2_ > 4 || _loc2_ > 7)
            {
               GWizSettings.FeedsSpeedsApp.addTip("Warning: Excessive stickout. Try to keep it less than 4 diameters with HSS tooling, \n7 diameters for carbide.",true);
            }
         }
      }
      
      private function peckDepthMsg(param1:Number, param2:Number, param3:Boolean, param4:Boolean, param5:Boolean) : String
      {
         var _loc7_:* = null;
         var _loc6_:Number = GWizFeedSpeedMath.peckDepth(param1,param2,param3,param4,param5);
         if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            _loc7_ = String(Number(_loc6_) * 25.4);
            _loc7_ = GWizUtils.roundBigTenths(_loc7_) + "mm";
         }
         else
         {
            _loc7_ = GWizUtils.roundHundredths(_loc6_) + "in";
         }
         return "Use Peck Depth = " + _loc7_;
      }
      
      public function radialEngagementHint(param1:Number) : void
      {
         switch(this.toolParms.toolType)
         {
            case "HSS Spot Drill":
            case "Carbide Spot Drill":
            case "HSS Twist Drill":
            case "Carbide Twist Drill":
            case "HSS Spade Drill":
            case "Carbide Spade Drill":
            case "Gun Drill":
            case "Cobalt Twist Drill":
            case "HP HSS Twist Drill":
            case "HP Carbide Twist Drill":
            case "Indexable Drill":
            case "Tapping":
            case "Carbide Tapping":
            case "HSS Tapping":
               break;
            case "HSS Reamer":
            case "Carbide Reamer":
               if(this.toolParms.toolDiam < 1)
               {
                  GWizSettings.FeedsSpeedsApp.addTip(this.drillSizes(this.toolParms.toolDiam - 0.02 * this.toolParms.toolDiam));
               }
               break;
            case "Turning: HSS":
            case "HSS Turning":
            case "Turning: Carbide":
            case "Carbide Turning":
            case "Carbide Parting/Grooving":
            case "Carbide Parting":
            case "Carbide Grooving":
            case "HSS Parting/Grooving":
            case "HSS Parting":
            case "HSS Grooving":
            case "Carbide Threading":
            case "HSS Threading":
            case "HSS Boring":
            case "Carbide Boring":
               break;
            case "Carbide Saws & Woodruff Cutters":
            case "HSS Saws & Woodruff Cutters":
               if(this.toolParms.flutes > this.bestTeeth)
               {
                  GWizSettings.FeedsSpeedsApp.addTip("Recommend " + Math.floor(this.bestTeeth) + " teeth for chip clearance");
               }
               break;
            case "Annular Cutter (Rotabroach®)":
               GWizSettings.FeedsSpeedsApp.addTip("Reduce Tortoise/Hare to 50% on thin-walled workpieces");
               break;
            default:
               if(param1 < 0.001)
               {
                  GWizSettings.FeedsSpeedsApp.addTip("Warning: Need non-zero Cut Width for Feeds & Speeds",true);
               }
               if(param1 > 75 || this.toolParms.toolDiam < this.MICRO_MILL_MAX_DIA)
               {
                  GWizSettings.FeedsSpeedsApp.addTip(" Use Conventional Milling");
               }
               else if(param1 <= 50)
               {
                  GWizSettings.FeedsSpeedsApp.addTip(" Use Climb Milling");
               }
               if(49.1 <= param1 && param1 <= 50.9)
               {
                  GWizSettings.FeedsSpeedsApp.addTip(" Avoid the centerline of your cutter by using more or less cut width");
               }
         }
         var _loc2_:Object = this.getToolsListEntry(this.toolParms.toolType);
         if(_loc2_ && _loc2_.hasOwnProperty("coating") && _loc2_.coating == "yes" && this.materialIndex >= 0)
         {
            GWizSettings.FeedsSpeedsApp.addTip("Coatings: " + GWizConfigData.MachinabilityFactors[this.materialIndex].coating);
         }
         if(this.materialName && GWizMaterialsDB.isNonFerrous(this.materialName))
         {
            if(!this.toolParms.isIndexableMillTool() && this.toolParms.isEndmill() && this.toolParms.flutes > 3 && !this.toolParms.isThreadMill())
            {
               GWizSettings.FeedsSpeedsApp.addTip("Warning: Use fewer than 4 flutes in non-ferrous metals",true);
            }
            if(this.materialName.toLowerCase().indexOf("aluminum") >= 0)
            {
               GWizSettings.FeedsSpeedsApp.addTip("Coolant, Mist, or Lubricant Recommended for Aluminum");
            }
         }
      }
      
      private function useHSMFeedsSpeedsAdj() : Boolean
      {
         var _loc1_:Number = this.toolParms.toolDiam * (GWizSettings.hsmWidthPct / 100);
         return this.hsmFeedsSpeedsAdj && this.isChipThinnable() && this.cutWidth <= _loc1_;
      }
      
      private function calcRPM_IPM_Plunge(param1:Boolean = true) : void
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         GWizUtils.LogErrorContext = "GWizFeedSpeedMath.calcRPM_IPM_Plunge";
         this.rpm.value = this.sfm.value * 3.82 / this.effDiam;
         var _loc2_:Number = Math.max(1,this.hsmAdjust);
         _loc2_ = Math.sqrt(_loc2_ / 1.5);
         this.hsmRPMFactor = _loc2_ * EMASTERCAM_SFM_ADJUST;
         if(isNaN(this.hsmRPMFactor))
         {
            this.hsmRPMFactor = 1;
         }
         var _loc3_:Object = GWizConfigData.findMaterialMF(this.materialName);
         if(_loc3_ && _loc3_.hasOwnProperty("maxHSMRPMFactor"))
         {
            _loc8_ = _loc3_.maxHSMRPMFactor;
            this.hsmRPMFactor = Math.min(this.hsmRPMFactor,_loc8_);
         }
         if(param1 && this.useHSMFeedsSpeedsAdj())
         {
            this.rpm.value *= this.hsmRPMFactor;
         }
         var _loc4_:Boolean = false;
         if(this.rpm.value > this.rpmLimit.value)
         {
            this.rpm.value = this.rpmLimit.value + 0.2;
            _loc4_ = true;
         }
         this.minRPMError = false;
         var _loc5_:Number = this.rpm.value;
         var _loc6_:Number = this.rpmMinLimit.value - 1;
         this.tooHighDia = NaN;
         if(_loc5_ < _loc6_)
         {
            _loc4_ = true;
            this.minRPMError = true;
            this.tooHighDia = this.minRPMDiaAdjust(this.toolParms.toolDiam,_loc5_,_loc6_);
         }
         if(this.rpm.isOverridden() || _loc4_ || this.useHSMFeedsSpeedsAdj())
         {
            this.sfm.value = Math.PI * this.effDiam * this.rpm.value / 12;
         }
         var _loc7_:Number = Math.max(1,this.hsmAdjust);
         _loc7_ = Math.sqrt(_loc7_ / 1.5);
         this.hsmIPMFactor = _loc7_ * 1.3 * EMASTERCAM_IPT_ADJUST;
         if(isNaN(this.hsmIPMFactor))
         {
            this.hsmIPMFactor = 1;
         }
         if(_loc3_ && _loc3_.hasOwnProperty("maxHSMIPMFactor"))
         {
            _loc9_ = _loc3_.maxHSMIPMFactor;
            this.hsmIPMFactor = Math.min(this.hsmIPMFactor,_loc9_);
         }
         this.ipm.value = this.rpm.value * this.afpt * this.toolParms.flutes;
         if(!this.isChipThinnable())
         {
            this.ipm.value = this.rpm.value * this.ipt.value * this.toolParms.flutes;
         }
         if(this.ipm.value > this.feedLimit.value)
         {
            this.ipm.setOverVal(this.feedLimit.value,true);
         }
         if(this.ipm.isOverridden())
         {
            this.ipt.value = this.ipm.value / (this.rpm.value * this.toolParms.flutes);
            this.ipt.value /= this.rctf;
         }
         this.ipr = this.ipt.value * this.toolParms.flutes;
         if(this.toolParms.toolType == "Tapping" || this.toolParms.toolType == "Carbide Tapping" || this.toolParms.toolType == "HSS Tapping")
         {
            this.ipr = this.cutWidth;
            this.ipt.value = this.cutWidth;
            this.ipm.value = this.ipr * this.rpm.value;
            if(this.ipm.value > this.feedLimit.value)
            {
               this.ipm.value = 0;
            }
         }
         this.plungeRate = Math.min(this.feedLimit.value,this.rpm.value * this.ipt.value);
      }
      
      public function minRPMDiaAdjust(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:Number = param2 / (param3 + 100) * param1;
         if(this.cutDepth <= 0 || this.cutWidth <= 0)
         {
            _loc4_ = param1;
         }
         return _loc4_;
      }
      
      public function recalc() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:Boolean = false;
         var _loc14_:Number = NaN;
         GWizUtils.LogErrorContext = "GWizFeedSpeedMath.recalc";
         if(this.stopRecalc)
         {
            return;
         }
         this.stopRecalc = true;
         if(this.rpmMinLimit.value > this.rpmLimit.value)
         {
            this.rpmMinLimit.setOverVal(this.rpmLimit.value,true);
         }
         this.rpm.lowerLimit = this.rpmMinLimit.value;
         if(!GWizToolData.isTurningTool(this.toolParms.toolType) && this.cutDepth > this.toolParms.stickout)
         {
            GWizSettings.FeedsSpeedsApp.addTip("Error: Cut Depth must be less than Stickout.");
         }
         this.effDiam = this.toolParms.calcEffDiam(this.toolParms.toolDiam,this.cutDepth);
         if(this.toolParms.isBallnose())
         {
            this.stepOver = GWizSurfaceFinishMill.stepover(this.toolParms.toolDiam,this.scallopHt);
            this.finish = GWizSurfaceFinishMill.finish(this.scallopHt);
         }
         if(!GWizToolData.isTurningTool(this.toolParms.toolType) && this.cutWidth > this.effDiam)
         {
            this.cutWidth = this.effDiam;
         }
         this.axialEngagement = this.cutDepth / this.effDiam * 1000;
         _loc1_ = this.axialEngagement;
         this.axialEngagement = _loc1_ / 10;
         if(this.cutWidth > this.effDiam)
         {
            this.radialEngagement = 1000;
         }
         else
         {
            this.radialEngagement = this.cutWidth / this.effDiam * 1000;
         }
         _loc1_ = this.radialEngagement;
         this.radialEngagement = _loc1_ / 10;
         if(this.toolParms.isTapping())
         {
            if(this.cutWidth > 0)
            {
               this.radialEngagement = GWizUtils.roundThousandths(1 / this.cutWidth);
            }
            else
            {
               this.radialEngagement = 0;
            }
         }
         this.sfm.value = this.lookupSFM();
         this.ipt.value = this.lookupIPT();
         switch(this.toolParms.toolType)
         {
            case "Carbide Spot Drill":
               _loc2_ = this.scanIPTTable("HSS Twist Drill");
               _loc3_ = this.scanIPTTable("Carbide Twist Drill");
               this.ipt.value *= _loc3_ / _loc2_;
               break;
            case "Carbide Spade Drill":
               _loc2_ = this.scanIPTTable("HSS Twist Drill");
               _loc3_ = this.scanIPTTable("Carbide Twist Drill");
               this.ipt.value *= _loc3_ / _loc2_;
               break;
            case "HSS Reamer":
            case "Carbide Reamer":
               this.ipt.value *= 2;
               this.sfm.value /= 2;
               break;
            case "HSS Center Drill":
            case "Carbide Center Drill":
               this.ipt.value /= 1.7;
               this.sfm.value *= 0.8;
         }
         this.rctf = 1;
         if(this.cutWidth < this.effDiam / 2 && this.cutWidth > 0)
         {
            this.rctf = Math.sqrt((this.effDiam - this.cutWidth) * this.cutWidth) / (this.effDiam / 2);
            this.rctf = 1 / this.rctf;
         }
         if(this.isChipThinnable())
         {
            if(this.toolParms.cornerRadius > 0 || this.toolParms.isBallnose())
            {
               _loc7_ = this.toolParms.cornerRadius;
               if(this.toolParms.isBallnose())
               {
                  _loc7_ = this.effDiam / 2;
               }
               if(this.cutDepth <= _loc7_ && this.cutDepth > 0)
               {
                  _loc8_ = _loc7_ / Math.sqrt(2 * _loc7_ * this.cutDepth - GWizUtils.square(this.cutDepth));
                  if(isNaN(_loc8_))
                  {
                     _loc8_ = 1;
                  }
                  this.rctf = Math.max(_loc8_,this.rctf);
               }
            }
         }
         if(this.toolParms.leadAngle < 90 && this.isChipThinnable() && !this.familyInPlay)
         {
            _loc9_ = 1;
            if(this.toolParms.leadAngle > 0)
            {
               _loc9_ = 1 / Math.sin(GWizUtils.radians(this.toolParms.leadAngle));
               this.rctf *= _loc9_;
            }
         }
         if(GWizUtils.debug && this.IGNORE_CHIP_THINNING)
         {
            this.rctf = 1;
         }
         if(!this.cea.isOverridden())
         {
            this.cea.setOverVal(GWizGeomUtils.recalcCEA(this.toolParms.toolDiam,this.cutWidth,180),false);
         }
         this.cornerAdjust = GWizGeomUtils.recalcCEA(this.effDiam,this.cutWidth,180) / GWizGeomUtils.recalcCEA(this.effDiam,this.cutWidth,90);
         this.hsmAdjust = Math.min(GWizGeomUtils.recalcCEA(this.effDiam,this.cutWidth,90) / this.cea.value,5);
         this.calcRPM_IPM_Plunge();
         if(this.toolParms.isTapping())
         {
            this.ipr = this.cutWidth;
            this.ipt.value = this.cutWidth;
         }
         this.mrr = this.calcMRR(this.sfm.value,this.rpm.value,this.ipm.value,this.cutDepth,this.cutWidth);
         var _loc4_:Number = this.lookupMF();
         this.notEnoughPowerErr = false;
         var _loc5_:Number = this.getSafeHPLimit();
         var _loc6_:* = this.toolParms.toolType.indexOf("Drill") >= 0;
         if(_loc5_ > 0.001)
         {
            _loc10_ = 100;
            if(!this.rpm.isOverridden())
            {
               _loc12_ = 6;
               _loc13_ = this.minRPMError;
               _loc14_ = !!this.hpLimit.isOverridden() ? Number(this.hpLimit.value) : Number(0);
               while(this.mrr * _loc4_ >= _loc5_ && _loc10_ > 0 && _loc12_ > 0 && !this.minRPMError)
               {
                  this.sfm.setOverVal(this.sfm.value * 0.95,true);
                  this.calcRPM_IPM_Plunge(false);
                  this.mrr = this.calcMRR(this.sfm.value,this.rpm.value,this.ipm.value,this.cutDepth,this.cutWidth);
                  _loc10_--;
                  _loc12_--;
                  _loc5_ = Math.min(GWizSpindleCurve.calcHP(this.rpm.value,_loc14_,_loc6_),this.getSafeHPLimit());
               }
               if(this.minRPMError)
               {
                  if(!_loc13_)
                  {
                     this.rpm.value = this.rpmMinLimit.value + 2;
                  }
                  this.calcRPM_IPM_Plunge(false);
                  this.mrr = this.calcMRR(this.sfm.value,this.rpm.value,this.ipm.value,this.cutDepth,this.cutWidth);
                  _loc5_ = Math.min(GWizSpindleCurve.calcHP(this.rpm.value,_loc14_,_loc6_),this.getSafeHPLimit());
               }
            }
            _loc11_ = this.bestFinishChipload(this.effDiam,this.mfgIPT.value);
            while(this.mrr * _loc4_ >= _loc5_ && this.afpt > _loc11_ && _loc10_ > 0)
            {
               this.ipm.value *= 0.95;
               this.ipm.setOverVal(this.ipm.value * 0.95,true);
               this.calcRPM_IPM_Plunge(false);
               this.mrr = this.calcMRR(this.sfm.value,this.rpm.value,this.ipm.value,this.cutDepth,this.cutWidth);
               _loc10_--;
            }
            if(this.mrr * _loc4_ >= _loc5_)
            {
               this.hpLimitHit = true;
               if(!this.rpm.isOverridden())
               {
                  while(this.mrr * _loc4_ >= _loc5_ && _loc10_ > 0)
                  {
                     this.sfm.setOverVal(this.sfm.value * 0.9,true);
                     this.calcRPM_IPM_Plunge();
                     this.mrr = this.calcMRR(this.sfm.value,this.rpm.value,this.ipm.value,this.cutDepth,this.cutWidth);
                     _loc10_--;
                  }
               }
               if(this.mrr * _loc4_ >= _loc5_)
               {
                  this.sfm.setOverVal(0,true);
                  this.rpm.setOverVal(0,true);
                  this.notEnoughPowerErr = true;
                  this.calcRPM_IPM_Plunge();
                  this.mrr = this.calcMRR(this.sfm.value,this.rpm.value,this.ipm.value,this.cutDepth,this.cutWidth);
               }
            }
         }
         this.hp = this.mrr * _loc4_;
         if(this.hpLimitHit || Math.abs(this.hp - _loc5_) < 0.05)
         {
            if(false && !this.useHSMFeedsSpeedsAdj())
            {
               this.ipt.value = this.gasPedalIPTAdjust(this.afpt);
               this.ipm.setOverVal(this.ipm.value,false);
               this.calcRPM_IPM_Plunge();
               this.mrr = this.calcMRR(this.sfm.value,this.rpm.value,this.ipm.value,this.cutDepth,this.cutWidth);
               this.hp = this.mrr * _loc4_;
            }
         }
         this.stopRecalc = false;
      }
      
      private function gasPedalIPTAdjust(param1:Number) : Number
      {
         var _loc6_:String = null;
         if(this.stopGasPedalRecursion)
         {
            return param1;
         }
         this.stopGasPedalRecursion = true;
         var _loc2_:Number = this.bestFinishChipload(this.effDiam,this.mfgIPT.value);
         if(GWizAbstractPrefs.isGarr())
         {
            _loc6_ = this.toolParms.cribProduct;
            _loc2_ = GWizGarrOEMToolData.lookupIPT(this.materialName,this.adjHardness,_loc6_,this.toolParms.toolDiam,_loc2_,this.cutDepth,this.cutWidth,false);
         }
         var _loc3_:Number = Math.max(_loc2_,param1);
         var _loc4_:Number = _loc3_ - _loc2_;
         var _loc5_:Number;
         param1 = _loc5_ = GWizUtils.interpolate(GWizTortHare.GAS_PEDAL_MIN,_loc2_,this.gasPedal,GWizTortHare.GAS_PEDAL_MAX,_loc3_);
         if(this.tsc && this.toolParms.tscTool())
         {
            param1 *= 1.15;
         }
         if(this.pcn)
         {
            param1 *= 1.05;
         }
         this.stopGasPedalRecursion = false;
         return param1;
      }
      
      private function gasPedalSFMAdjust(param1:Number) : Number
      {
         var _loc2_:Number = 1;
         if(this.gasPedal < GWizTortHare.GAS_PEDAL_MAX)
         {
            _loc2_ = 0.9;
         }
         return Number(param1 * _loc2_);
      }
      
      private function drillSizes(param1:Number) : String
      {
         var _loc3_:Object = null;
         var _loc4_:Number = NaN;
         var _loc5_:* = null;
         var _loc2_:int = 0;
         while(_loc2_ < GWizConfigData.DrillData.length)
         {
            _loc3_ = GWizConfigData.DrillData.getItemAt(_loc2_);
            if((_loc4_ = _loc3_.inch) > param1)
            {
               _loc2_--;
               if(_loc2_ >= 0)
               {
                  _loc3_ = GWizConfigData.DrillData.getItemAt(_loc2_);
                  if((_loc5_ = _loc3_.designation) == "")
                  {
                     _loc5_ = _loc3_.metric;
                  }
                  if(_loc5_.length > 0)
                  {
                     _loc5_ = "Use " + _loc5_ + " twist drill.";
                  }
                  return _loc5_;
               }
            }
            _loc2_++;
         }
         return "";
      }
      
      public function rubChipload(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = param1 >= this.MICRO_MILL_MAX_DIA ? Number(5) : Number(3);
         var _loc4_:Number;
         if((_loc4_ = this.lookupMaxHardness()) == 0)
         {
            _loc3_ = 40;
         }
         _loc3_ = param2 / _loc3_;
         return Number(Math.min(_loc3_,0.001));
      }
      
      public function bestFinishChipload(param1:Number, param2:Number) : Number
      {
         return this.rubChipload(param1,param2) * 1.1;
      }
      
      public function addUnitTest() : void
      {
         if(!GWizUtils.debug)
         {
         }
      }
      
      private function runUnitTests() : void
      {
         if(!GWizUtils.debug)
         {
         }
      }
   }
}
