package threads2
{
   import configinfo.GWizConfigData;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizAbstractThreadEngine implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizAbstractThread");
      
      public static var PremiumThreadFamily:Object = new Object();
      
      private static var _1448043432ExtThreadImg:Class = GWizAbstractThreadEngine_ExtThreadImg;
      
      private static var _142068150IntThreadImg:Class = GWizAbstractThreadEngine_IntThreadImg;
      
      public static var Reference:String = "None";
      
      public static var _Family:String;
      
      public static var Size:String;
      
      public static var NomSize:Number;
      
      public static var TPI:Number;
      
      private static var _1971765198allowCustomSizeTPI:Boolean = true;
      
      private static var _1958603580showTolClass:Boolean = true;
      
      public static var TolClass:String;
      
      private static var _Designation:String;
      
      public static var ThreadStarts:int = 1;
      
      public static var Pitch:Number;
      
      public static var ThreadAngle:Number = 60;
      
      public static var External:Boolean;
      
      private static var _1317239652hasExternalThreads:Boolean = true;
      
      public static var EngagementLength:Number;
      
      public static var MinMajorDia:Number;
      
      private static var _MaxMajorDia:Number;
      
      public static var MinMinorDia:Number;
      
      public static var MaxMinorDia:Number;
      
      public static var MinPitchDia:Number;
      
      public static var MaxPitchDia:Number;
      
      public static var FltsHeight:Number;
      
      public static var Flat:Number;
      
      public static var Flat2:Number;
      
      public static var MinRootRadius:Number;
      
      public static var MaxRootRadius:Number;
      
      public static var SharpDepthExt:Number;
      
      public static var ThreadDepthExt:Number;
      
      public static var Allowance:Number;
      
      public static var MajorDiaTol:Number;
      
      public static var PitchDiaTol:Number;
      
      public static var MinorDiaTol:Number;
      
      public static var BestSizeMOW:Number;
      
      public static var MinSizeMOW:Number;
      
      public static var MaxSizeMOW:Number;
      
      public static var MinMeasureMOW:Number;
      
      public static var MaxMeasureMOW:Number;
      
      public static var MinCountersinkDia:Number;
      
      public static var MaxCountersinkDia:Number;
      
      public static var PreferredThreads:ArrayCollection;
      
      private static var _594845898tapDrillList:ArrayCollection = new ArrayCollection();
      
      private static var _516163946tapTypes:ArrayCollection = new ArrayCollection([{
         "label":"Bottom Tap",
         "lead":2
      },{
         "label":"Semi Bottom Tap",
         "lead":3
      },{
         "label":"Modified Bottom Tap",
         "lead":4
      },{
         "label":"Plug Tap",
         "lead":5
      },{
         "label":"Modified Plug Tap",
         "lead":7
      },{
         "label":"Roll Form",
         "lead":2.5
      }]);
      
      public static var blindHoleClearance:Number = 0;
      
      public static var TPISelect:Boolean = true;
      
      private static var _1994027542ClassList:ArrayCollection = new ArrayCollection();
      
      private static var _DefaultClassChoice:int = 0;
      
      private static var threadData:ArrayCollection;
      
      private static var dataHash:Object;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizAbstractThreadEngine()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      public static function isPremiumFamily(param1:String) : Boolean
      {
         return PremiumThreadFamily.hasOwnProperty(param1);
      }
      
      public static function get Family() : String
      {
         return _Family;
      }
      
      public static function set Family(param1:String) : void
      {
         _Family = param1;
         if(param1 == "0.0125")
         {
            log.debug("gotcha");
         }
      }
      
      public static function set Designation(param1:String) : void
      {
         if(ThreadStarts > 1)
         {
            param1 += " (" + ThreadStarts + " starts)";
         }
         _Designation = param1;
      }
      
      public static function get Designation() : String
      {
         return _Designation;
      }
      
      public static function get pitchMM() : Number
      {
         return GWizUtils.roundThousandths(Pitch * 25.4);
      }
      
      public static function get LeadAngle() : Number
      {
         var _loc1_:Number = ThreadStarts * Pitch / (Math.PI * MinPitchDia);
         _loc1_ = Math.atan(_loc1_);
         _loc1_ = GWizUtils.degrees(_loc1_);
         return GWizUtils.roundThousandths(_loc1_);
      }
      
      public static function engagementLenThreads() : Number
      {
         return EngagementLength / Pitch;
      }
      
      public static function set MaxMajorDia(param1:Number) : void
      {
         _MaxMajorDia = param1;
      }
      
      public static function get MaxMajorDia() : Number
      {
         return _MaxMajorDia;
      }
      
      public static function get MeanMajorDia() : Number
      {
         if(isNaN(MaxMajorDia))
         {
            MaxMajorDia = MinMajorDia;
         }
         return (MinMajorDia + MaxMajorDia) / 2;
      }
      
      public static function get MeanMinorDia() : Number
      {
         return (MaxMinorDia + MinMinorDia) / 2;
      }
      
      public static function get MeanPitchDia() : Number
      {
         return (MaxPitchDia + MinPitchDia) / 2;
      }
      
      public static function get Height() : Number
      {
         return Math.cos(GWizUtils.radians(ThreadAngle / 2)) * Pitch;
      }
      
      public static function bhClearanceRecalc(param1:int) : String
      {
         var _loc3_:Number = NaN;
         var _loc2_:String = "";
         if(param1 >= 0)
         {
            _loc3_ = tapTypes.getItemAt(param1).lead;
            blindHoleClearance = (_loc3_ + 1) * Pitch + 1 / 25.4;
            _loc2_ = String(blindHoleClearance);
         }
         return _loc2_;
      }
      
      public static function set DefaultClassChoice(param1:int) : void
      {
         _DefaultClassChoice = param1;
      }
      
      public static function get DefaultClassChoice() : int
      {
         return _DefaultClassChoice;
      }
      
      public static function newThreadData(param1:String, param2:Object, param3:Boolean = false, param4:Boolean = false) : String
      {
         var _loc6_:String = null;
         var _loc8_:Number = NaN;
         var _loc9_:GWizThreadDataItem = null;
         if(GWizUtils.debug && param1 == "Family")
         {
            log.debug("gotcha");
         }
         if(!dataHash)
         {
            return "";
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
            (_loc9_ = GWizThreadDataItem(dataHash[param1])).value = _loc5_.value;
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
         if(GWizUtils.debug && param1 == "Family")
         {
            log.debug("retval = " + _loc6_ + ", row.value = " + _loc5_.value);
         }
         return _loc6_;
      }
      
      public static function threadInfo(param1:String, param2:Boolean = false) : String
      {
         if(!dataHash)
         {
            return "";
         }
         var _loc3_:GWizThreadDataItem = GWizThreadDataItem(dataHash[param1]);
         if(!_loc3_)
         {
            if(GWizUtils.debug)
            {
               log.debug("Missing thread info " + param1 + " on Family " + Family + " Size " + Size + " NomSize " + NomSize);
               GWizUtils.assert(false);
            }
            return "";
         }
         var _loc4_:String = _loc3_.value;
         if(_loc3_.checkUnits && GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            _loc4_ = _loc3_.mmvalue;
         }
         if(_loc4_ == "NaN")
         {
            _loc4_ = "N/A";
         }
         if(param2)
         {
            _loc4_ = param1 + " " + _loc4_;
         }
         return _loc4_;
      }
      
      [Bindable(event="propertyChange")]
      public static function get ExtThreadImg() : Class
      {
         return GWizAbstractThreadEngine._1448043432ExtThreadImg;
      }
      
      public static function set ExtThreadImg(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractThreadEngine._1448043432ExtThreadImg;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractThreadEngine,"ExtThreadImg",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get IntThreadImg() : Class
      {
         return GWizAbstractThreadEngine._142068150IntThreadImg;
      }
      
      public static function set IntThreadImg(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractThreadEngine._142068150IntThreadImg;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractThreadEngine,"IntThreadImg",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get allowCustomSizeTPI() : Boolean
      {
         return GWizAbstractThreadEngine._1971765198allowCustomSizeTPI;
      }
      
      public static function set allowCustomSizeTPI(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractThreadEngine._1971765198allowCustomSizeTPI;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractThreadEngine,"allowCustomSizeTPI",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get showTolClass() : Boolean
      {
         return GWizAbstractThreadEngine._1958603580showTolClass;
      }
      
      public static function set showTolClass(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractThreadEngine._1958603580showTolClass;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractThreadEngine,"showTolClass",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get hasExternalThreads() : Boolean
      {
         return GWizAbstractThreadEngine._1317239652hasExternalThreads;
      }
      
      public static function set hasExternalThreads(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractThreadEngine._1317239652hasExternalThreads;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractThreadEngine,"hasExternalThreads",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get tapDrillList() : ArrayCollection
      {
         return GWizAbstractThreadEngine._594845898tapDrillList;
      }
      
      public static function set tapDrillList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractThreadEngine._594845898tapDrillList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractThreadEngine,"tapDrillList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get tapTypes() : ArrayCollection
      {
         return GWizAbstractThreadEngine._516163946tapTypes;
      }
      
      public static function set tapTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractThreadEngine._516163946tapTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractThreadEngine,"tapTypes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get ClassList() : ArrayCollection
      {
         return GWizAbstractThreadEngine._1994027542ClassList;
      }
      
      public static function set ClassList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizAbstractThreadEngine._1994027542ClassList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizAbstractThreadEngine,"ClassList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function selectThread(param1:String, param2:String, param3:Number, param4:Number, param5:String, param6:int, param7:Boolean) : Boolean
      {
         Family = param1;
         Size = param2;
         NomSize = param3;
         TPI = param4;
         Pitch = 1 / TPI;
         ThreadStarts = param6;
         External = param7;
         hasExternalThreads = true;
         EngagementLength = NomSize;
         Allowance = NaN;
         MajorDiaTol = NaN;
         PitchDiaTol = NaN;
         MinorDiaTol = NaN;
         MinCountersinkDia = NaN;
         MaxCountersinkDia = NaN;
         Flat = NaN;
         MinRootRadius = NaN;
         MaxRootRadius = NaN;
         return true;
      }
      
      public function lookupTPI(param1:String, param2:String) : Number
      {
         GWizUtils.assert(false);
         return NaN;
      }
      
      public function nomDiaFromFamSize(param1:String, param2:String) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Object = this.lookupFamilySize(param1,param2);
         _loc3_ = Number(_loc4_.NominalSize);
         GWizUtils.assert(!isNaN(_loc3_));
         return _loc3_;
      }
      
      public function lookupFamilySize(param1:String, param2:String) : Object
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         while(_loc4_ < PreferredThreads.length)
         {
            _loc3_ = PreferredThreads.getItemAt(_loc4_);
            if(_loc3_.Family == param1 && _loc3_.Size == param2)
            {
               break;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function recalcTapInfo(param1:Number, param2:Number, param3:Boolean, param4:Boolean) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Object = null;
         var _loc10_:Boolean = false;
         GWizAbstractThreadEngine.tapDrillList.removeAll();
         var _loc7_:Number = 1;
         if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            _loc7_ = 25.4;
         }
         if(param3)
         {
            _loc6_ = 0.013;
         }
         else
         {
            _loc6_ = 0.0068;
         }
         _loc5_ = param1 - _loc6_ * (100 / param2);
         _loc8_ = 0;
         while(_loc8_ < GWizConfigData.DrillData.length)
         {
            _loc9_ = GWizConfigData.DrillData.getItemAt(_loc8_);
            _loc10_ = false;
            if(_loc9_.inch >= _loc5_)
            {
               _loc9_.pct = int((param1 - _loc9_.inch) / _loc6_ * param2);
               if(_loc9_.pct < -13)
               {
                  if(!(false && _loc9_.pct < 0 && _loc9_.pct > -25))
                  {
                     break;
                  }
                  tapDrillList.addItem(_loc9_);
               }
               else if(param4)
               {
                  tapDrillList.addItem(_loc9_);
               }
            }
            _loc8_++;
         }
      }
      
      public function initClassList(param1:Boolean = true) : void
      {
         GWizUtils.assert(false);
      }
      
      public function RecalcMOWLimits(param1:Number) : void
      {
         GWizUtils.assert(false);
      }
      
      public function RecalcMOWPitchDia(param1:Number, param2:Number) : Number
      {
         GWizUtils.assert(false);
         return NaN;
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
         newThreadData("Nominal Size",NomSize,true,true);
         newThreadData("TPI",TPI,true);
         newThreadData("Reference",Reference);
         if(showTolClass)
         {
            newThreadData("ToleranceClass",TolClass);
         }
         newThreadData("Designation",Designation);
         newThreadData("Thread Angle",ThreadAngle);
         newThreadData("Thread Starts",ThreadStarts,true);
         newThreadData("Pitch",Pitch,true,true);
         newThreadData("Lead",ThreadStarts * Pitch,true,true);
         newThreadData("Lead Angle",LeadAngle,true,false);
         newThreadData("Length of Engagement",EngagementLength,true,true);
         newThreadData("Length of Engagement (threads)",engagementLenThreads(),true,true);
         newThreadData("Min Major Dia",MinMajorDia,true,true);
         newThreadData("Max Major Dia",MaxMajorDia,true,true);
         newThreadData("Mean Major Dia",MeanMajorDia,true,true);
         newThreadData("Min Minor Dia",MinMinorDia,true,true);
         newThreadData("Max Minor Dia",MaxMinorDia,true,true);
         newThreadData("Mean Minor Dia",MeanMinorDia,true,true);
         newThreadData("Min Pitch Dia",MinPitchDia,true,true);
         newThreadData("Max Pitch Dia",MaxPitchDia,true,true);
         newThreadData("Mean Pitch Dia",MeanPitchDia,true,true);
         newThreadData("Sharp-V Height",Height,true,true);
         newThreadData("Flats Height",FltsHeight,true,true);
         newThreadData("Flat",Flat,true,true);
         if(!isNaN(MinRootRadius))
         {
            newThreadData("Min Root Radius",MinRootRadius,true,true);
         }
         if(!isNaN(MaxRootRadius))
         {
            newThreadData("Max Root Radius",MaxRootRadius,true,true);
         }
         newThreadData("Allowance",Allowance,true,true);
         newThreadData("Major Dia Tol",MajorDiaTol,true,true);
         newThreadData("Pitch Dia Tol",PitchDiaTol,true,true);
         newThreadData("Minor Dia Tol",MinorDiaTol,true,true);
         if(External)
         {
            newThreadData("MOW Best Wire",BestSizeMOW,true,true);
            newThreadData("MOW Min Wire",MinSizeMOW,true,true);
            newThreadData("MOW Max Wire",MaxSizeMOW,true,true);
         }
         this.addlThreadData();
         return threadData;
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
