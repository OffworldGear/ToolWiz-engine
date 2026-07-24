package threads2
{
   import configinfo.GWizAbstractPrefs;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizBSPTThreadEngine extends GWizAbstractTaperThreadEngine
   {
      
      private static const log:ILogger = Log.getLogger("GWizBSPTThreadEngine");
      
      public static var BSPTPipeThreadList:ArrayCollection = new ArrayCollection([{
         "Family":"BSPT",
         "Size":"1/16 - 28",
         "TPI":28,
         "Pitch":0.0357,
         "PipeDia":"0.3125",
         "D":0.3041,
         "GaugeLen":0.1563,
         "GaugeLenTol":1,
         "UsefuleExtThreadLen":0.255905511811024,
         "TapDrill":"N/A"
      },{
         "Family":"BSPT",
         "Size":"1/8 - 28",
         "TPI":28,
         "Pitch":0.0357,
         "PipeDia":"0.4",
         "D":0.383,
         "GaugeLen":0.1563,
         "GaugeLenTol":1,
         "UsefuleExtThreadLen":0.255905511811024,
         "TapDrill":0.328125
      },{
         "Family":"BSPT",
         "Size":"1/4 - 19",
         "TPI":19,
         "Pitch":0.0526,
         "PipeDia":"0.53",
         "D":0.518,
         "GaugeLen":0.2367,
         "GaugeLenTol":1,
         "UsefuleExtThreadLen":0.381889763779528,
         "TapDrill":0.4375
      },{
         "Family":"BSPT",
         "Size":"3/8 - 19",
         "TPI":19,
         "Pitch":0.0526,
         "PipeDia":"0.68",
         "D":0.656,
         "GaugeLen":0.25,
         "GaugeLenTol":1,
         "UsefuleExtThreadLen":0.397637795275591,
         "TapDrill":0.59375
      },{
         "Family":"BSPT",
         "Size":"1/2 - 14",
         "TPI":14,
         "Pitch":0.0714,
         "PipeDia":"0.84",
         "D":0.825,
         "GaugeLen":0.3214,
         "GaugeLenTol":1,
         "UsefuleExtThreadLen":0.519685039370079,
         "TapDrill":0.71875
      },{
         "Family":"BSPT",
         "Size":"3/4 - 14",
         "TPI":14,
         "Pitch":0.0714,
         "PipeDia":"1.06",
         "D":1.041,
         "GaugeLen":0.375,
         "GaugeLenTol":1,
         "UsefuleExtThreadLen":0.570866141732283,
         "TapDrill":0.9375
      },{
         "Family":"BSPT",
         "Size":"1 - 11",
         "TPI":11,
         "Pitch":0.0909,
         "PipeDia":"1.33",
         "D":1.309,
         "GaugeLen":0.4091,
         "GaugeLenTol":1,
         "UsefuleExtThreadLen":0.661417322834646,
         "TapDrill":1.171875
      },{
         "Family":"BSPT",
         "Size":"1-1/4 - 11",
         "TPI":11,
         "Pitch":0.0909,
         "PipeDia":"1.67",
         "D":1.65,
         "GaugeLen":0.5,
         "GaugeLenTol":1,
         "UsefuleExtThreadLen":0.751968503937008,
         "TapDrill":1.515625
      },{
         "Family":"BSPT",
         "Size":"1-1/2 - 11",
         "TPI":11,
         "Pitch":0.0909,
         "PipeDia":"1.9",
         "D":1.882,
         "GaugeLen":0.5,
         "GaugeLenTol":1,
         "UsefuleExtThreadLen":0.751968503937008,
         "TapDrill":1.75
      },{
         "Family":"BSPT",
         "Size":"2 - 11",
         "TPI":11,
         "Pitch":0.0909,
         "PipeDia":"2.37",
         "D":2.347,
         "GaugeLen":0.625,
         "GaugeLenTol":1,
         "UsefuleExtThreadLen":0.921259842519685,
         "TapDrill":2.1875
      },{
         "Family":"BSPT",
         "Size":"2-1/2 - 11",
         "TPI":11,
         "Pitch":0.0909,
         "PipeDia":"3",
         "D":2.96,
         "GaugeLen":0.6875,
         "GaugeLenTol":1.5,
         "UsefuleExtThreadLen":1.0511811023622,
         "TapDrill":"N/A"
      },{
         "Family":"BSPT",
         "Size":"3 - 11",
         "TPI":11,
         "Pitch":0.0909,
         "PipeDia":"3.5",
         "D":3.46,
         "GaugeLen":0.8125,
         "GaugeLenTol":1.5,
         "UsefuleExtThreadLen":1.17322834645669,
         "TapDrill":"N/A"
      },{
         "Family":"BSPT",
         "Size":"4 - 11",
         "TPI":11,
         "Pitch":0.0909,
         "PipeDia":"4.5",
         "D":4.45,
         "GaugeLen":1,
         "GaugeLenTol":1.5,
         "UsefuleExtThreadLen":1.40944881889764,
         "TapDrill":"N/A"
      },{
         "Family":"BSPT",
         "Size":"5 - 11",
         "TPI":11,
         "Pitch":0.0909,
         "PipeDia":"5.5",
         "D":5.45,
         "GaugeLen":1.125,
         "GaugeLenTol":1.5,
         "UsefuleExtThreadLen":1.57874015748032,
         "TapDrill":"N/A"
      },{
         "Family":"BSPT",
         "Size":"6 - 11",
         "TPI":11,
         "Pitch":0.0909,
         "PipeDia":"6.5",
         "D":6.45,
         "GaugeLen":1.125,
         "GaugeLenTol":1.5,
         "UsefuleExtThreadLen":1.57874015748032,
         "TapDrill":"N/A"
      }]);
      
      public static var BSPTThreadImg:Class = GWizBSPTThreadEngine_BSPTThreadImg;
      
      public static var BSPTStdSizes:ArrayCollection;
       
      
      public function GWizBSPTThreadEngine()
      {
         this.initPreferredThreads();
         PremiumThreadFamily["BSPT"] = true;
         super();
      }
      
      public function initPreferredThreads() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(GWizAbstractPrefs.ThreadCalcEnabled)
         {
            if(!BSPTStdSizes)
            {
               BSPTStdSizes = new ArrayCollection();
               _loc1_ = 0;
               while(_loc1_ < BSPTPipeThreadList.length)
               {
                  _loc2_ = BSPTPipeThreadList.getItemAt(_loc1_);
                  _loc2_ = GWizUtils.clone(_loc2_);
                  if(_loc2_.Family == "BSPT")
                  {
                  }
                  BSPTStdSizes.addItem(_loc2_);
                  _loc1_++;
               }
            }
            if(!PreferredThreads)
            {
               PreferredThreads = BSPTStdSizes;
            }
            else
            {
               PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,BSPTStdSizes);
            }
         }
      }
      
      override public function selectThread(param1:String, param2:String) : Boolean
      {
         var _loc4_:Object = null;
         var _loc3_:Boolean = super.selectThread(param1,param2);
         TaperThreadImg = BSPTThreadImg;
         var _loc5_:int = 0;
         while(_loc5_ < BSPTPipeThreadList.length)
         {
            if((_loc4_ = BSPTPipeThreadList.getItemAt(_loc5_)).Family == "BSPT" && _loc4_.Size == Size)
            {
               NomSize = _loc4_.PipeDia;
               break;
            }
            _loc5_++;
         }
         Reference = "EN 10226-1, EN 10226-2";
         SharpVHeight = 0.960237 * Pitch;
         Height = 0.640327 * Pitch;
         ThreadAngle = 55;
         return true;
      }
      
      override public function addlThreadData() : void
      {
         var _loc2_:Object = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc1_:Number = 0.137329 * Pitch;
         removeThreadData("Mean Height");
         removeThreadData("Min Height");
         removeThreadData("Tap Depth");
         removeThreadData("Mean Flat at Crest");
         removeThreadData("Max Flat at Crest");
         removeThreadData("Min Flat at Crest");
         removeThreadData("Major Dia Pipe Face (E0)");
         removeThreadData("Minor Dia Pipe Face (E0)");
         removeThreadData("Major Dia Gage Notch (E1)");
         removeThreadData("Minor Dia Gage Notch (E1)");
         var _loc3_:int = 0;
         while(_loc3_ < BSPTPipeThreadList.length)
         {
            _loc2_ = BSPTPipeThreadList.getItemAt(_loc3_);
            if(_loc2_.Family == "BSPT" && _loc2_.Size == Size)
            {
               newThreadData("Tap Drill",_loc2_.TapDrill,true,true);
               newThreadData("Pipe Dia.",NomSize,true,true);
               newThreadData("Major Dia (external at gauge plane)",_loc2_.D,true,true);
               newThreadData("Pitch Dia (external & internal at gauge plane)",_loc2_.D - 0.640327 * Pitch,true,true);
               newThreadData("Minor Dia (external & internal at gauge plane)",_loc2_.D - 1.280654 * Pitch,true,true);
               _loc4_ = _loc2_.GaugeLen * TaperPerInch;
               newThreadData("Major Dia (external at pipe face)",_loc2_.D - _loc4_,true,true);
               newThreadData("Pitch Dia (external at pipe face)",_loc2_.D - 0.640327 * Pitch - _loc4_,true,true);
               break;
            }
            _loc3_++;
         }
         removeThreadData(GWizAbstractTaperThreadEngine.L1_LABEL);
         removeThreadData("L1 (threads)");
         removeThreadData(GWizAbstractTaperThreadEngine.L2_LABEL);
         removeThreadData("L2 (threads)");
         removeThreadData(GWizAbstractTaperThreadEngine.L3_LABEL);
         removeThreadData("L3 (threads)");
         removeThreadData(GWizAbstractTaperThreadEngine.L4_LABEL);
         removeThreadData("L4 (threads)");
         removeThreadData(GWizAbstractTaperThreadEngine.L5_LABEL);
         removeThreadData("L5 (threads)");
         removeThreadData("E0");
         removeThreadData("E1");
         removeThreadData("E2");
         removeThreadData("E3");
         removeThreadData("E5");
         if(_loc3_ < BSPTPipeThreadList.length)
         {
            newThreadData("Gauge Length (external thread)",_loc2_.GaugeLen,true,true);
            _loc5_ = _loc2_.GaugeLenTol * _loc2_.Pitch;
            newThreadData("Gauge Length Max (external thread)",_loc2_.GaugeLen + _loc5_,true,true);
            newThreadData("Gauge Length Min (external thread)",_loc2_.GaugeLen - _loc5_,true,true);
            newThreadData("Gauge Length Tolerance (external thread)",_loc5_,true,true);
            newThreadData("Gauge Length (internal thread)",Number(_loc2_.Pitch) * 0.5,true,true);
            newThreadData("Fitting Allowance",Number(_loc2_.Pitch) * 2.75,true,true);
            newThreadData("Fitting Allowance (threads)",2.75,true,true);
            newThreadData("Wrenching Allowance",Number(_loc2_.Pitch) * 1.5,true,true);
            newThreadData("Wrenching Allowance (threads)",1.5,true,true);
            newThreadData("Useful Ext. Thread Len",Number(_loc2_.UsefulExtThreadLen),true,true);
            newThreadData("Useful Ext. Thread Len (max)",Number(_loc2_.UsefulExtThreadLen) + _loc5_,true,true);
            newThreadData("Useful Ext. Thread Len (min)",Number(_loc2_.UsefulExtThreadLen) - _loc5_,true,true);
         }
         removeThreadData("Min Truncation");
         removeThreadData("Max Truncation");
         newThreadData("Crest Radius",_loc1_,true,true);
         newThreadData("Root Radius",_loc1_,true,true);
      }
   }
}
