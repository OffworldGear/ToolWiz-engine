package threads2
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizAbstractTaperThreadEngine implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizAbstractTaperThread");
      
      public static var PremiumThreadFamily:Object = new Object();
      
      private static var _2070338505TaperThreadImg:Class;
      
      private static var NPTThreadImg:Class = GWizAbstractTaperThreadEngine_NPTThreadImg;
      
      public static var Family:String;
      
      public static var Size:String;
      
      public static var Reference:String = "None";
      
      public static var Designation:String;
      
      public static var NomSize:Number;
      
      public static var Pitch:Number;
      
      public static var TPI:Number;
      
      public static var ThreadAngle:Number = 60;
      
      public static var Height:Number;
      
      public static var MinHeight:Number;
      
      public static var SharpVHeight:Number;
      
      public static var MinFlatAtCrest:Number;
      
      public static var MaxFlatAtCrest:Number;
      
      public static var MinTruncation:Number;
      
      public static var MaxTruncation:Number;
      
      public static var DiaChangePerTurn:Number;
      
      public static var TaperPerInch:Number;
      
      public static var TaperAngle:String;
      
      public static var L1:Number;
      
      public static var L2:Number;
      
      public static var L3:Number;
      
      public static var L4:Number;
      
      public static var L5:Number;
      
      public static var E0:Number;
      
      public static var E1:Number;
      
      public static var E2:Number;
      
      public static var E3:Number;
      
      public static var E5:Number;
      
      public static var MajorDiaPipeFace:Number;
      
      public static var MinorDiaPipeFace:Number;
      
      public static var MajorDiaGageNotch:Number;
      
      public static var MinorDiaGageNotch:Number;
      
      public static var TapDrill:Number;
      
      public static var TapDepth:Number;
      
      public static var PreferredThreads:ArrayCollection;
      
      private static var threadData:ArrayCollection;
      
      public static const L1_LABEL:String = "L1 (Handtight Len.)";
      
      public static const L2_LABEL:String = "L2 (Eff. Len.)";
      
      public static const L3_LABEL:String = "L3 (Wrench Make Up)";
      
      public static const L4_LABEL:String = "L4 (Overall Len)";
      
      public static const L5_LABEL:String = "L5 (Nom. Perf.)";
      
      private static var dataHash:Object;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizAbstractTaperThreadEngine()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         PreferredThreads = GWizThreadDB.PipeThreadList;
      }
      
      public static function isPremiumFamily(param1:String) : Boolean
      {
         return PremiumThreadFamily.hasOwnProperty(param1);
      }
      
      public static function get pitchMM() : Number
      {
         return GWizUtils.roundThousandths(Pitch * 25.4);
      }
      
      public static function get MeanHeight() : Number
      {
         return (Height + MinHeight) / 2;
      }
      
      public static function get MeanFlatAtCrest() : Number
      {
         return (MinFlatAtCrest + MaxFlatAtCrest) / 2;
      }
      
      public static function newThreadData(param1:String, param2:Object, param3:Boolean = false, param4:Boolean = false) : String
      {
         var _loc6_:String = null;
         var _loc8_:Number = NaN;
         var _loc9_:GWizThreadDataItem = null;
         if(false && GWizUtils.debug && param1 == "Family")
         {
            log.debug("gotcha");
         }
         var _loc5_:GWizThreadDataItem;
         (_loc5_ = new GWizThreadDataItem()).label = param1;
         _loc5_.value = String(param2);
         if(param3)
         {
            _loc5_.value = String(GWizUtils.roundTenths(Number(param2)));
         }
         if(param4)
         {
            _loc8_ = Number(param2) * 25.4;
            _loc5_.mmvalue = String(GWizUtils.roundThousandths(_loc8_));
         }
         else
         {
            _loc5_.mmvalue = String(param2);
         }
         var _loc7_:Boolean;
         if(!(_loc7_ = dataHash.hasOwnProperty(param1)))
         {
            threadData.addItem(_loc5_);
         }
         else
         {
            _loc9_ = GWizThreadDataItem(dataHash[param1]);
            if(GWizUtils.debug && _loc9_.label != param1)
            {
               log.debug("Labels don\'t match. dataHash[label] = " + dataHash[param1]);
            }
            _loc9_.value = _loc5_.value;
            _loc9_.mmvalue = _loc5_.value;
            _loc9_.checkUnits = param4;
         }
         _loc5_.checkUnits = param4;
         dataHash[param1] = _loc5_;
         if(GWizUtils.Units == GWizUtils.MM_UNITS)
         {
            _loc6_ = _loc5_.mmvalue;
         }
         else
         {
            _loc6_ = _loc5_.value;
         }
         return _loc6_;
      }
      
      public static function removeThreadData(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:Boolean = dataHash.hasOwnProperty(param1);
         if(_loc2_)
         {
            _loc3_ = 0;
            while(_loc3_ < threadData.length)
            {
               if((_loc4_ = threadData.getItemAt(_loc3_)).label == param1)
               {
                  threadData.removeItemAt(_loc3_);
                  break;
               }
               _loc3_++;
            }
            dataHash[param1] = null;
         }
      }
      
      public static function threadInfo(param1:String, param2:Boolean = false, param3:Boolean = false) : String
      {
         var _loc5_:String = null;
         if(GWizUtils.debug && param1 == "Family")
         {
            log.debug("gotcha");
         }
         var _loc4_:GWizThreadDataItem;
         if(!(_loc4_ = dataHash[param1]))
         {
            if(false && GWizUtils.debug)
            {
               log.debug("Missing thread info " + param1 + " on Family " + Family + " Size " + Size + " NomSize " + NomSize);
               GWizUtils.assert(false);
            }
            if(param3)
            {
               _loc5_ = "";
            }
            else
            {
               _loc5_ = "N/A";
            }
            return _loc5_;
         }
         _loc5_ = _loc4_.value;
         if(_loc4_.checkUnits && GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            _loc5_ = _loc4_.mmvalue;
         }
         if(_loc5_ == "NaN")
         {
            if(param3)
            {
               _loc5_ = "";
            }
            else
            {
               _loc5_ = "N/A";
            }
         }
         if(param2)
         {
            _loc5_ = param1 + " " + _loc5_;
         }
         return _loc5_;
      }
      
      [Bindable(event="propertyChange")]
      public static function get TaperThreadImg() : Class
      {
         return GWizAbstractTaperThreadEngine._2070338505TaperThreadImg;
      }
      
      public static function set TaperThreadImg(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractTaperThreadEngine._2070338505TaperThreadImg;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractTaperThreadEngine,"TaperThreadImg",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function selectThread(param1:String, param2:String) : Boolean
      {
         var _loc4_:Object = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         TaperThreadImg = NPTThreadImg;
         Family = param1;
         Size = param2;
         var _loc3_:String = param2.substr(param2.indexOf("-") + 1);
         TPI = Number(GWizUtils.roundBigTenths(_loc3_));
         if(isNaN(TPI))
         {
            _loc3_ = _loc3_.substr(_loc3_.indexOf("-") + 1);
            TPI = Number(GWizUtils.roundBigTenths(_loc3_));
         }
         Pitch = 1 / TPI;
         TaperPerInch = 0.0625;
         TaperAngle = "1.7899°";
         Designation = Family + " " + Size;
         Reference = "ASME B1.20.1 - 2013, SAE AS71051";
         GWizThreadDB.PipeThreadList.filterFunction = this.filterPipeList;
         GWizThreadDB.PipeThreadList.refresh();
         if(GWizThreadDB.PipeThreadList.length > 0)
         {
            _loc4_ = GWizThreadDB.PipeThreadList.getItemAt(0);
            NomSize = GWizUtils.roundTenths(_loc4_.D);
            if(GWizUtils.debug)
            {
               _loc6_ = Math.abs(_loc4_.Pitch - Pitch);
               if(isNaN(_loc6_) || _loc6_ > 0.0001)
               {
                  log.debug("Pitch Error = " + _loc6_ + ", db value = " + _loc4_.Pitch + ", calculated = " + Pitch);
                  GWizUtils.assert(false);
               }
            }
            SharpVHeight = 0.8660254 * Pitch;
            Height = 0.8 * Pitch;
            if(false && GWizUtils.debug)
            {
               _loc7_ = Math.abs(_loc4_.H - Height);
               if(isNaN(_loc7_) || _loc7_ > 0.0001)
               {
                  log.debug("Height Error = " + _loc6_ + ", db value = " + _loc4_.H + ", calculated = " + Pitch);
                  GWizUtils.assert(false);
               }
            }
            MinFlatAtCrest = GWizUtils.roundTenths(this.minFlatWidth(TPI));
            MaxFlatAtCrest = GWizUtils.roundTenths(this.maxFlatWidth(TPI));
            MinTruncation = GWizUtils.roundTenths(this.minTruncation(TPI));
            MaxTruncation = GWizUtils.roundTenths(this.maxTruncation(TPI));
            MinHeight = Height - 2 * (MaxTruncation - MinTruncation);
            L1 = GWizUtils.roundTenths(_loc4_.L1);
            L2 = (0.8 * NomSize + 6.8) * Pitch;
            if(false && GWizUtils.debug)
            {
               _loc8_ = Math.abs(_loc4_.L2 - L2);
               if(isNaN(_loc8_) || _loc8_ > 0.0001)
               {
                  log.debug("L2 Error = " + _loc8_ + ", db value = " + _loc4_.L2 + ", calculated = " + L2);
                  GWizUtils.assert(false);
               }
            }
            if(NomSize < 2.875)
            {
               L3 = 3 * Pitch;
            }
            else
            {
               L3 = 2 * Pitch;
            }
            if(false && GWizUtils.debug)
            {
               _loc9_ = Math.abs(_loc4_.L3 - L3);
               if(isNaN(_loc9_) || _loc8_ > 0.0001)
               {
                  log.debug("L3 Error = " + _loc9_ + ", db value = " + _loc4_.L3 + ", calculated = " + L3);
                  GWizUtils.assert(false);
               }
            }
            _loc5_ = 3.47 * Pitch;
            L4 = L2 + _loc5_;
            if(false && GWizUtils.debug)
            {
               _loc10_ = Math.abs(_loc4_.L4 - L4);
               if(isNaN(_loc10_) || _loc10_ > 0.0001)
               {
                  log.debug("L4 Error = " + _loc10_ + ", db value = " + _loc4_.L4 + ", calculated = " + L4);
                  GWizUtils.assert(false);
               }
            }
            L5 = L2 - 2 * Pitch;
            if(false && GWizUtils.debug)
            {
               _loc11_ = Math.abs(_loc4_.L5 - L5);
               if(isNaN(_loc11_) || _loc11_ > 0.0001)
               {
                  log.debug("L5 Error = " + _loc11_ + ", db value = " + _loc4_.L5 + ", calculated = " + L5);
                  GWizUtils.assert(false);
               }
            }
            E0 = NomSize - (0.05 * NomSize + 1.1) * Pitch;
            if(false && GWizUtils.debug)
            {
               _loc12_ = Math.abs(_loc4_.E0 - E0);
               if(isNaN(_loc12_) || _loc12_ > 0.0001)
               {
                  log.debug("E0 Error = " + _loc12_ + ", db value = " + _loc4_.E0 + ", calculated = " + E0);
                  GWizUtils.assert(false);
               }
            }
            E1 = E0 + TaperPerInch * L1;
            if(false && GWizUtils.debug)
            {
               _loc13_ = Math.abs(_loc4_.E1 - E1);
               if(isNaN(_loc13_) || _loc13_ > 0.0001)
               {
                  log.debug("E1 Error = " + _loc13_ + ", db value = " + _loc4_.E1 + ", calculated = " + E1);
                  GWizUtils.assert(false);
               }
            }
            E5 = E0 + TaperPerInch * L5;
            if(false && GWizUtils.debug)
            {
               _loc14_ = Math.abs(_loc4_.E5 - E5);
               if(isNaN(_loc14_) || _loc14_ > 0.0001)
               {
                  log.debug("E5 Error = " + _loc14_ + ", db value = " + _loc4_.E5 + ", calculated = " + E5);
                  GWizUtils.assert(false);
               }
            }
            E3 = E0 - TaperPerInch * L3;
            if(false && GWizUtils.debug)
            {
               _loc15_ = Math.abs(_loc4_.E3 - E3);
               if(isNaN(_loc15_) || _loc15_ > 0.0001)
               {
                  log.debug("E3 Error = " + _loc15_ + ", db value = " + _loc4_.E3 + ", calculated = " + E3);
                  GWizUtils.assert(false);
               }
            }
            E2 = _loc4_.E2;
            E2 = E0 + TaperPerInch * L2;
            if(false && GWizUtils.debug)
            {
               _loc16_ = Math.abs(_loc4_.E2 - E2);
               if(isNaN(_loc16_) || _loc16_ > 0.0001)
               {
                  log.debug("E2 Error = " + _loc16_ + ", db value = " + _loc4_.E2 + ", calculated = " + E2);
                  GWizUtils.assert(false);
               }
            }
            MajorDiaPipeFace = E0 + MeanHeight;
            MinorDiaPipeFace = E0 - MeanHeight;
            MajorDiaGageNotch = E1 + MeanHeight;
            MinorDiaGageNotch = E1 - MeanHeight;
            if(_loc4_.TapDrill != 0)
            {
               TapDrill = _loc4_.TapDrill;
            }
            else
            {
               TapDrill = NaN;
            }
            TapDepth = GWizUtils.roundTenths(12 * Pitch);
         }
         GWizThreadDB.PipeThreadList.filterFunction = null;
         GWizThreadDB.PipeThreadList.refresh();
         return true;
      }
      
      public function addlThreadData() : void
      {
      }
      
      public function getThreadData() : ArrayCollection
      {
         threadData = new ArrayCollection();
         dataHash = new Object();
         var _loc1_:String = newThreadData("Family",Family);
         if(!_loc1_)
         {
            return null;
         }
         newThreadData("Size",Size);
         newThreadData("Pipe Dia.",NomSize,true,true);
         newThreadData("TPI",TPI,true);
         newThreadData("Reference",Reference);
         newThreadData("Designation",Designation);
         newThreadData("Thread Angle",ThreadAngle);
         newThreadData("Pitch",Pitch,true,true);
         newThreadData("Lead",Pitch,true,true);
         newThreadData("Height",Height,true,true);
         newThreadData("Min Height",MinHeight,true,true);
         newThreadData("Mean Height",MeanHeight,true,true);
         newThreadData("Sharp-V Height",SharpVHeight,true,true);
         newThreadData("Min Flat at Crest",MinFlatAtCrest,true,true);
         newThreadData("Max Flat at Crest",MaxFlatAtCrest,true,true);
         newThreadData("Mean Flat at Crest",MeanFlatAtCrest,true,true);
         newThreadData("Min Truncation",MinTruncation,true,true);
         newThreadData("Max Truncation",MaxTruncation,true,true);
         newThreadData("Taper Angle",TaperAngle);
         newThreadData("Taper (Dia change per unit)",TaperPerInch,true,true);
         newThreadData(L1_LABEL,L1,true,true);
         newThreadData("L1 (threads)",Number(GWizUtils.roundBigTenths(String(L1 / Pitch))),true,true);
         newThreadData(L2_LABEL,L2,true,true);
         newThreadData("L2 (threads)",Number(GWizUtils.roundBigTenths(String(L2 / Pitch))),true,true);
         newThreadData(L3_LABEL,L3,true,true);
         newThreadData("L3 (threads)",Number(GWizUtils.roundBigTenths(String(L3 / Pitch))),true,true);
         newThreadData(L4_LABEL,L4,true,true);
         newThreadData("L4 (threads)",Number(GWizUtils.roundBigTenths(String(L4 / Pitch))),true,true);
         newThreadData(L5_LABEL,L5,true,true);
         newThreadData("L5 (threads)",Number(GWizUtils.roundBigTenths(String(L5 / Pitch))),true,true);
         newThreadData("E0",E0,true,true);
         newThreadData("E1",E1,true,true);
         newThreadData("E2",E2,true,true);
         newThreadData("E3",E3,true,true);
         newThreadData("E5",E5,true,true);
         newThreadData("Major Dia Pipe Face (E0)",MajorDiaPipeFace,true,true);
         newThreadData("Minor Dia Pipe Face (E0)",MinorDiaPipeFace,true,true);
         newThreadData("Major Dia Gage Notch (E1)",MajorDiaGageNotch,true,true);
         newThreadData("Minor Dia Gage Notch (E1)",MinorDiaGageNotch,true,true);
         newThreadData("Tap Drill",TapDrill,true,true);
         newThreadData("Tap Depth",TapDepth,true,true);
         this.addlThreadData();
         return threadData;
      }
      
      private function filterPipeList(param1:Object) : Boolean
      {
         var _loc2_:Boolean = true;
         if(Family.length > 0)
         {
            _loc2_ = _loc2_ && param1.Family == Family;
         }
         if(Size.length > 0)
         {
            _loc2_ = _loc2_ && param1.Size == Size;
         }
         return _loc2_;
      }
      
      private function minTruncation(param1:int) : Number
      {
         return 0.033 * Pitch;
      }
      
      private function maxTruncation(param1:int) : Number
      {
         if(param1 > 18)
         {
            return 0.096 * Pitch;
         }
         if(param1 > 14)
         {
            return 0.088 * Pitch;
         }
         if(param1 > 11.5)
         {
            return 0.078 * Pitch;
         }
         if(param1 > 8)
         {
            return 0.073 * Pitch;
         }
         return 0.062 * Pitch;
      }
      
      private function minFlatWidth(param1:int) : Number
      {
         return 0.038 * Pitch;
      }
      
      private function maxFlatWidth(param1:int) : Number
      {
         if(param1 > 18)
         {
            return 0.111 * Pitch;
         }
         if(param1 > 14)
         {
            return 0.102 * Pitch;
         }
         if(param1 > 11.5)
         {
            return 0.09 * Pitch;
         }
         if(param1 > 8)
         {
            return 0.084 * Pitch;
         }
         return 0.072 * Pitch;
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
