package cadcamwiz
{
   import configinfo.GWizSettings;
   import feedsspeeds.GWizFeedsSpeeds2;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import machines.GWizMachSettings;
   import mx.collections.ArrayCollection;
   import mx.collections.Sort;
   import mx.collections.SortField;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import tools.GWizToolChooser;
   import tools.GWizToolCrib;
   import tools.GWizToolCribData;
   import tools.GWizToolCribEntry;
   import utils.GWizDebugUtils;
   import utils.GWizUncaughtErrors;
   import utils.GWizUtils;
   
   public class GWizCCWRecalc implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizCCWRecalc");
      
      public static var notViableErrors:ArrayCollection = new ArrayCollection();
      
      public static const PASS_LIMIT:int = 40;
      
      public static var MaxTests:int = 8000;
      
      public static var PopSize:int = 150;
      
      public static var FirstPaired:int = 50;
      
      public static var FirstRandom:int = 131;
      
      private static const MAX_NO_BETTER:int = 5;
      
      private static const CROSSOVER_MUTATE_PCT:Number = 0.5;
      
      public static var rerunBestGA:Boolean = false;
      
      private static var _164030650roughingStrategies:ArrayCollection = new ArrayCollection([{"name":"Same cutter"},{"name":"Same cutter + HSM"},{"name":"Corncob Rougher"},{"name":"Corncob Rougher + HSM"},{"name":"Large Rougher"},{"name":"Large Rougher + HSM"},{"name":"Large Corncob Rougher"},{"name":"Large Corncob Rougher + HSM"},{"name":"Indexable Rougher"},{"name":"Indexable Rougher + HSM"}]);
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      public var flutes:int = 2;
      
      private var _maxWidth:Number;
      
      private var maxDepth:Number;
      
      private var stickout:Number;
      
      private var hsm:Boolean;
      
      private var largeRougher:Boolean;
      
      private var usePremCoolant:Boolean;
      
      private var profileWidth:Number;
      
      private var minWidth:Number;
      
      public var tests:int = 0;
      
      private var depthLimitMax:Number = NaN;
      
      private var depthLimitMin:Number = NaN;
      
      private var notViableHash:Object;
      
      private var tiLastGUID:String = "";
      
      private var tiLastCribGen:int = -1;
      
      private var tiLastEntry:GWizToolCribEntry;
      
      private const QUICKIE:Boolean = true;
      
      private var _gaRunning:Boolean = false;
      
      public var gaTests:int = 0;
      
      private var cribToolGUID:String = "";
      
      private var samples:ArrayCollection;
      
      private var dataSortField:SortField;
      
      private var dataSort:Sort;
      
      private var done:Boolean = false;
      
      private var priorMRR:Number;
      
      private var bestMRR:Number;
      
      private var noBetter:int = 0;
      
      public var roughingError:String = "";
      
      private const USE_ONLY_MRR:Boolean = false;
      
      private const PER_PASS_MRR_PENALTY:Number = 0.02;
      
      private var finishFcn:Function = null;
      
      public var progBar:Function = null;
      
      private var genCt:int = 0;
      
      public var stopGA:Boolean = false;
      
      public var drillDFM:String;
      
      private var fsUI:Object = null;
      
      private var fsUILvl:int = 0;
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizCCWRecalc()
      {
         this.notViableHash = new Object();
         this.dataSortField = new SortField();
         this.dataSort = new Sort();
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         if(GWizUncaughtErrors.uncaughtErrorCC)
         {
            GWizUncaughtErrors.uncaughtErrorCC.addFunction("GWizCCWRecalc",this.uncaughtErrorHandler);
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get roughingStrategies() : ArrayCollection
      {
         return GWizCCWRecalc._164030650roughingStrategies;
      }
      
      public static function set roughingStrategies(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWRecalc._164030650roughingStrategies;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWRecalc,"roughingStrategies",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      private function uncaughtErrorHandler() : void
      {
         this.stopGA = true;
      }
      
      private function get maxWidth() : Number
      {
         return this._maxWidth;
      }
      
      private function set maxWidth(param1:Number) : void
      {
         this._maxWidth = param1;
      }
      
      private function showTests(param1:String) : void
      {
         if(GWizUtils.debug)
         {
            log.debug(param1 + " tests = " + this.tests);
         }
      }
      
      public function initRecalc(param1:Number, param2:Number, param3:int, param4:Number, param5:Number, param6:Number, param7:Boolean, param8:Boolean, param9:Boolean, param10:Boolean, param11:Boolean, param12:Boolean) : void
      {
         var _loc13_:Number = 0.001;
         var _loc14_:Number = 0.001;
         this.depthLimitMax = NaN;
         this.depthLimitMin = NaN;
         this.maxWidth = Math.max(param1,_loc13_);
         this.maxDepth = Math.max(param2,_loc14_);
         this.flutes = Math.max(param3,1);
         this.stickout = param4;
         this.hsm = param7;
         this.largeRougher = param8;
         GWizToolChooser.corncob = param9;
         GWizToolChooser.indexable = param10;
         this.profileWidth = param5;
         this.minWidth = param6;
         this.usePremCoolant = param12;
         if(this.largeRougher)
         {
            this.maxWidth = GWizCadCam.CADCAMWiz.ccwOptions.MaxRoughToolDia.getVal();
            this.stickout = this.maxDepth + Math.min(this.maxWidth,0.5);
         }
         GWizToolChooser.facemill = param11;
         if(GWizToolChooser.facemill)
         {
            this.maxWidth = GWizCadCam.CADCAMWiz.ccwOptions.MaxFaceToolDia.getVal();
            this.flutes = GWizCadCam.CADCAMWiz.ccwOptions.FaceMillFlutes.getVal();
            this.stickout = this.maxDepth + Math.min(this.maxWidth,0.5);
         }
         else if(GWizToolChooser.indexable)
         {
            this.maxWidth = GWizCadCam.CADCAMWiz.ccwOptions.MaxIdxRoughToolDia.getVal();
            this.flutes = GWizCadCam.CADCAMWiz.ccwOptions.IdxRoughFlutes.getVal();
            this.stickout = this.maxDepth + Math.min(this.maxWidth,0.5);
         }
         notViableErrors.removeAll();
         this.notViableHash = new Object();
      }
      
      private function addNotViableError(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         if(this.notViableHash.hasOwnProperty(param1))
         {
            _loc3_ = this.notViableHash[param1];
            if(0 <= _loc3_ && _loc3_ < notViableErrors.length)
            {
               _loc2_ = notViableErrors.getItemAt(this.notViableHash[param1]);
               ++_loc2_.count;
            }
         }
         else
         {
            _loc2_ = new Object();
            _loc2_.error = param1;
            _loc2_.count = 1;
            notViableErrors.addItem(_loc2_);
            this.notViableHash[param1] = notViableErrors.length - 1;
         }
      }
      
      private function toolInfoFromGUID(param1:GWizCCWEstRecord, param2:String, param3:String, param4:Number, param5:int, param6:Number, param7:String, param8:String, param9:String) : GWizCCWEstRecord
      {
         var _loc10_:GWizToolCribEntry = null;
         param1.guid = this.cribToolGUID;
         if(param2 != "")
         {
            if(GWizSettings.cacheToolGUIDS && this.tiLastGUID == param2 && this.tiLastCribGen == GWizToolCrib.showGeneration && this.tiLastEntry)
            {
               _loc10_ = this.tiLastEntry;
            }
            else
            {
               _loc10_ = GWizToolCribData.ToolCrib.getCribEntryByGUID(param2);
               this.tiLastEntry = _loc10_;
               this.tiLastCribGen = GWizToolCrib.showGeneration;
               this.tiLastGUID = param2;
            }
            param1.tool = GWizToolChooser.toolDiaToStr(_loc10_.diameter) + " " + _loc10_.tool;
            param1.toolDia = _loc10_.diameter;
            param1.flutes = _loc10_.flutes;
            param1.stickout = _loc10_.stickout;
            param1.hsm = String(param7);
            param1.corncob = String(_loc10_.isCorncob());
         }
         else
         {
            param1.tool = GWizToolChooser.toolDiaToStr(this.maxWidth) + " " + GWizToolChooser.getToolStr();
            param1.toolDia = param4;
            param1.flutes = param5;
            param1.stickout = param6;
            param1.hsm = String(param7);
            param1.corncob = String(GWizToolChooser.corncob);
         }
         param1.roughing = String(true);
         return param1;
      }
      
      public function cutMRR(param1:String, param2:Number, param3:Number, param4:Boolean, param5:Boolean, param6:Boolean, param7:int) : GWizCCWEstRecord
      {
         ++this.tests;
         var _loc8_:GWizCCWEstRecord = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,param1);
         var _loc9_:Number = GWizCadCam.CADCAMWiz.ccwOptions.getMaxSolidToolStepover();
         if(param2 > this.maxWidth)
         {
            param2 = this.maxWidth;
         }
         if(!GWizToolChooser.indexable && GWizToolChooser.getToolStr().toLowerCase().indexOf("endmill") >= 0)
         {
            param2 = Math.min(this.maxWidth * _loc9_,param2);
         }
         if(param3 > this.maxDepth)
         {
            param3 = this.maxDepth;
         }
         _loc8_.width = GWizUtils.roundThousandths(param2 * GWizCCWMillOptions.StepoverSlider);
         _loc8_.height = GWizUtils.roundThousandths(param3);
         if(!isNaN(this.profileWidth))
         {
            _loc8_.width = Math.min(_loc8_.width,this.profileWidth);
         }
         if(!isNaN(this.minWidth))
         {
            _loc8_.width = Math.max(_loc8_.width,this.minWidth);
         }
         if(!isNaN(this.maxWidth))
         {
            _loc8_.width = Math.min(_loc8_.width,this.maxWidth);
         }
         _loc8_ = this.toolInfoFromGUID(_loc8_,this.cribToolGUID,GWizToolChooser.toolDiaToStr(this.maxWidth) + " " + GWizToolChooser.getToolStr(),this.maxWidth,this.flutes,this.stickout,String(this.hsm),String(GWizToolChooser.corncob),String(true));
         if(isNaN(param2) || isNaN(param3))
         {
            if(GWizUtils.debug)
            {
               GWizUtils.assert(false);
            }
            _loc8_.mrr = NaN;
            GWizDebugUtils.timeIt("End cutMRR:");
            return _loc8_;
         }
         this.saveUI();
         if(false && param5)
         {
            GWizSettings.FeedsSpeedsApp.api.SetupUIQuickly(_loc8_.height,_loc8_.width);
         }
         else
         {
            GWizSettings.FeedsSpeedsApp.api.SetupUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,this.cribToolGUID,GWizToolChooser.getToolStr(),this.maxWidth,this.flutes,this.stickout,_loc8_.height,_loc8_.width,param4,param4 && this.hsm,param4 && GWizToolChooser.corncob,param6,GWizCCWMillOptions.GasPedalSlider,this.usePremCoolant,param7);
         }
         _loc8_ = this.addStdResultFields(_loc8_);
         if(param7 < 0)
         {
            param7 = GWizFeedsSpeeds2.PLUNGE_HELIX;
         }
         _loc8_.entryMode = GWizFeedsSpeeds2.PlungeModes.getItemAt(param7).label;
         _loc8_.entryFeedrate = GWizSettings.FeedsSpeedsApp.api.getEntryFeedrate();
         var _loc10_:String;
         if((_loc10_ = GWizSettings.FeedsSpeedsApp.api.cuttingErr()) != "" && _loc10_.indexOf("RPM maxed out") < 0)
         {
            _loc8_.mrr = NaN;
            _loc8_.dfm = _loc10_;
            this.addNotViableError(_loc10_);
         }
         this.restoreUI();
         if(!isNaN(_loc8_.mrr))
         {
            if(isNaN(this.depthLimitMin))
            {
               this.depthLimitMin = _loc8_.height;
            }
            else
            {
               this.depthLimitMin = Math.min(this.depthLimitMin,_loc8_.height);
            }
            if(isNaN(this.depthLimitMax))
            {
               this.depthLimitMax = _loc8_.height;
            }
            else
            {
               this.depthLimitMax = Math.max(this.depthLimitMax,_loc8_.height);
            }
         }
         return _loc8_;
      }
      
      private function addStdResultFields(param1:GWizCCWEstRecord) : GWizCCWEstRecord
      {
         param1.mrr = GWizSettings.FeedsSpeedsApp.api.getMRR();
         var _loc2_:Number = GWizSettings.FeedsSpeedsApp.api.getEffDia();
         if(!(GWizUtils.debug && _loc2_ <= 0.001))
         {
            param1.width = Math.min(param1.width,GWizSettings.FeedsSpeedsApp.api.getEffDia());
         }
         param1.rpm = GWizSettings.FeedsSpeedsApp.api.getRPM();
         param1.sfm = GWizSettings.FeedsSpeedsApp.api.getSFM();
         param1.feedrate = GWizSettings.FeedsSpeedsApp.api.getFeed();
         param1.ipr = GWizSettings.FeedsSpeedsApp.api.getIPR();
         param1.workcenter = GWizMachSettings.currMachine;
         param1.hourly = GWizCadCam.CADCAMWiz.getHourly();
         param1.addHints(GWizSettings.FeedsSpeedsApp);
         return param1;
      }
      
      private function findCutDepth(param1:String, param2:Number, param3:Number, param4:Boolean, param5:Number = 0.0) : Number
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc11_:int = 0;
         var _loc12_:Object = null;
         var _loc13_:Number = NaN;
         var _loc14_:String = null;
         var _loc9_:int = 0;
         GWizSettings.cacheToolGUIDS = true;
         _loc6_ = param3;
         var _loc10_:int = 1;
         while(_loc10_ <= 10 && _loc9_ < 5)
         {
            _loc11_ = GWizFeedsSpeeds2.PLUNGE_RAMP;
            if(param4)
            {
               _loc11_ = GWizFeedsSpeeds2.PLUNGE_HELIX;
            }
            _loc13_ = (_loc12_ = this.cutMRR(param1,param2,_loc6_,param4,!this.QUICKIE,GWizToolChooser.useBallnose,_loc11_)).mrr;
            if((_loc14_ = GWizSettings.FeedsSpeedsApp.api.cuttingErr()) != "" && _loc14_.search("RPM maxed out") < 0)
            {
               _loc13_ = NaN;
            }
            if(!isNaN(_loc13_))
            {
               if(isNaN(_loc7_) || _loc13_ >= _loc7_)
               {
                  _loc7_ = _loc13_;
                  _loc8_ = _loc6_;
                  _loc9_ = 0;
               }
               else
               {
                  _loc9_++;
               }
            }
            _loc6_ = Math.max(_loc6_ * 0.6,param5);
            _loc10_++;
         }
         if(isNaN(_loc8_))
         {
            _loc8_ = param5;
         }
         GWizSettings.cacheToolGUIDS = false;
         return _loc8_;
      }
      
      private function findCutWidth(param1:String, param2:Number, param3:Number, param4:Boolean) : Number
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:Number = NaN;
         var _loc8_:int = 0;
         GWizSettings.cacheToolGUIDS = true;
         var _loc9_:int = 1;
         while(_loc9_ <= 20 && _loc8_ < 5)
         {
            _loc5_ = GWizUtils.interval(_loc9_,20,param3);
            _loc10_ = GWizFeedsSpeeds2.PLUNGE_HELIX;
            if(!param4)
            {
               _loc10_ = GWizFeedsSpeeds2.PLUNGE_RAMP;
            }
            _loc12_ = (_loc11_ = this.cutMRR(param1,_loc5_,param2,param4,_loc9_ > 1,GWizToolChooser.useBallnose,_loc10_)).mrr;
            if(GWizSettings.FeedsSpeedsApp.api.cuttingErr() != "")
            {
               _loc12_ = NaN;
            }
            if(!isNaN(_loc12_))
            {
               if(isNaN(_loc6_) || _loc12_ > _loc6_)
               {
                  _loc6_ = _loc12_;
                  _loc7_ = _loc5_;
                  _loc8_ = 0;
               }
               else
               {
                  _loc8_++;
               }
            }
            _loc9_++;
         }
         GWizSettings.cacheToolGUIDS = false;
         return _loc7_;
      }
      
      public function recalcProfilePass(param1:String, param2:Number, param3:Number, param4:Number, param5:Number, param6:int, param7:Number, param8:Boolean, param9:Boolean, param10:Boolean, param11:Boolean) : GWizCCWEstRecord
      {
         this.tests = 0;
         if(param8 && this.cribToolGUID != "")
         {
            param5 = GWizToolChooser.calcToolDia(GWizToolChooser.toolStr,param5 / 2,param6,1000,1000,null,true,false,param10);
         }
         GWizCadCam.recalcEngine.initRecalc(param5,param3,param6,param7,param2,param2,false,false,false,false,false,param11);
         var _loc12_:Number = this.findCutDepth(param1,param2,param3,param9,param5 / 8);
         var _loc13_:int = 0;
         while(isNaN(_loc12_) && _loc13_ < 10)
         {
            param2 *= 0.8;
            _loc12_ = this.findCutDepth(param1,param2,param3,param9,param5 / 8);
            _loc13_++;
         }
         var _loc14_:int = int(param3 / _loc12_);
         if(_loc12_ < param3 / _loc14_)
         {
            _loc14_++;
         }
         _loc12_ = param3 / _loc14_;
         var _loc15_:GWizCCWEstRecord = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,param1);
         if(isNaN(_loc12_))
         {
            _loc15_.dfm = "ERROR: Too much tool deflection due to stickout and cut depth vs tool diameter.\n";
         }
         _loc15_.width = GWizUtils.roundThousandths(param2);
         _loc15_.height = GWizUtils.roundThousandths(_loc12_);
         _loc15_.passes = _loc14_;
         _loc15_.perimeter = param4;
         _loc15_.volume = _loc15_.perimeter * param2 * param3;
         if((_loc15_ = this.toolInfoFromGUID(_loc15_,this.cribToolGUID,GWizToolChooser.getToolStr(),param5,param6,param7,String(param9 && this.hsm),String(param9 && GWizToolChooser.corncob),String(param9))).width > _loc15_.toolDia)
         {
            _loc15_.dfm = "ERROR: Cut width is larger than tool diameter.  Probably need a smaller rougher.\n";
         }
         this.saveUI();
         GWizSettings.FeedsSpeedsApp.api.SetupUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,this.cribToolGUID,GWizToolChooser.getToolStr(),param5,param6,param7,_loc12_,_loc15_.width,param9,param9 && this.hsm,param9 && GWizToolChooser.corncob,param10,GWizCCWMillOptions.GasPedalSlider,param11,GWizFeedsSpeeds2.PLUNGE_RAMP);
         (_loc15_ = this.addStdResultFields(_loc15_)).entryMode = GWizFeedsSpeeds2.PlungeModes.getItemAt(GWizFeedsSpeeds2.PLUNGE_RAMP).label;
         _loc15_.entryFeedrate = GWizSettings.FeedsSpeedsApp.api.getEntryFeedrate();
         this.restoreUI();
         if(!param8)
         {
            _loc15_.volume = 0;
         }
         _loc15_.tests = this.tests;
         _loc15_.tool = GWizToolChooser.getToolDesc(false,false,this.maxWidth,param6);
         return _loc15_;
      }
      
      public function semiFinishWallThickness(param1:Number) : Number
      {
         var _loc2_:Number = 0.5 * (param1 * Math.SQRT2 - param1);
         return _loc2_ * Math.cos(GWizUtils.radians(45));
      }
      
      public function perimeterFromVolume(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = param1 / param2;
         var _loc5_:Number;
         return (_loc5_ = Math.sqrt(_loc4_)) * 4;
      }
      
      private function maxToolDOC(param1:Boolean) : Number
      {
         var _loc2_:Number = GWizCadCam.CADCAMWiz.ccwOptions.MaxSolidToolDOCMult.getVal();
         if(GWizMachSettings.currMachType == GWizMachSettings.MACH_TYPE_ROUTER && GWizCadCam.CADCAMWiz.MatChooser.currSelHardness() > GWizCadCam.CADCAMWiz.MatChooser.METALISH_HARDNESS)
         {
            _loc2_ = Math.min(1,_loc2_);
         }
         if(GWizMachSettings.currMachineSafeMode())
         {
            _loc2_ = Math.min(1,_loc2_);
         }
         _loc2_ *= this.maxWidth;
         if(param1)
         {
            if(GWizToolChooser.indexable)
            {
               _loc2_ = GWizCadCam.CADCAMWiz.ccwOptions.MaxIdxDOC.getVal();
            }
            else if(GWizToolChooser.facemill)
            {
               _loc2_ = GWizCadCam.CADCAMWiz.ccwOptions.MaxFaceDOC.getVal();
            }
         }
         return _loc2_;
      }
      
      public function get gaRunning() : Boolean
      {
         return this._gaRunning;
      }
      
      public function set gaRunning(param1:Boolean) : void
      {
         if(param1)
         {
            GWizSettings.cacheToolGUIDS = true;
         }
         else
         {
            GWizSettings.cacheToolGUIDS = false;
         }
         this._gaRunning = param1;
      }
      
      public function recalcRoughingPasses(param1:Function, param2:String) : void
      {
         if(this.gaRunning)
         {
            return;
         }
         this.showTests("Begin recalcRoughingPasses:");
         this.gaRunning = true;
         this.cribToolGUID = param2;
         this.saveUI();
         this.priorMRR = NaN;
         this.noBetter = 0;
         this.roughingError = "";
         this.finishFcn = param1;
         this.tests = 0;
         this.samples = null;
         this.samples = new ArrayCollection();
         this.dataSort.fields = [new SortField("value")];
         this.dataSort.compareFunction = this.gaCompare;
         this.samples.sort = this.dataSort;
         this.seedPopGrid();
         this.showTests("After seedPopGrid:");
         this.done = this.samples.length <= 0;
         if(!this.done)
         {
            this.genCt = 0;
            this.stopGA = false;
            GWizCadCam.CADCAMWiz.callLater(this.nextGeneration);
         }
         else if(this.finishFcn != null)
         {
            this.finishFcn(null,true,GWizToolChooser.useBallnose);
            this.restoreUI();
         }
         GWizDebugUtils.timeIt("End recalcRoughingPasses:");
      }
      
      private function randomOrg() : GWizCCWEstRecord
      {
         var _loc5_:int = 0;
         var _loc1_:Number = GWizUtils.randLimitsNum(0.001,this.maxWidth);
         var _loc2_:Number = this.maxToolDOC(true);
         var _loc3_:Number = GWizUtils.randLimitsNum(this.maxDepth / PASS_LIMIT,Math.min(this.maxDepth,_loc2_));
         _loc3_ = this.maxDepth / Number(int(this.maxDepth / _loc3_));
         if(_loc3_ > _loc2_)
         {
            _loc5_ = int(this.maxDepth / _loc3_) + 1;
            _loc3_ = Number(int(this.maxDepth / _loc5_));
         }
         return this.cutMRR(GWizCCWEstRecord.CCE_MILL_POCKET,_loc1_,_loc3_,true,this.tests > 0,GWizToolChooser.useBallnose,GWizFeedsSpeeds2.PLUNGE_HELIX);
      }
      
      private function selectParent(param1:Number) : GWizCCWEstRecord
      {
         var _loc5_:GWizCCWEstRecord = null;
         var _loc2_:Number = GWizUtils.randLimitsNum(0,param1);
         var _loc3_:Number = 0;
         var _loc4_:int = 0;
         while(_loc4_ < this.samples.length)
         {
            if((_loc5_ = this.samples.getItemAt(_loc4_) as GWizCCWEstRecord).hasOwnProperty("mrr") && !isNaN(_loc5_.mrr))
            {
               _loc3_ += _loc5_.mrr;
            }
            if(_loc3_ >= _loc2_ && _loc5_.hasOwnProperty("mrr") && !isNaN(_loc5_.mrr))
            {
               return _loc5_;
            }
            _loc4_++;
         }
         return this.samples.getItemAt(0) as GWizCCWEstRecord;
      }
      
      private function numToFixedStr(param1:Number, param2:int, param3:int) : String
      {
         var _loc4_:String = String(int(param1 * 10000));
         while(_loc4_.length < param2)
         {
            _loc4_ = "0" + _loc4_;
         }
         return _loc4_;
      }
      
      private function pairedOrg(param1:Number) : GWizCCWEstRecord
      {
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc2_:GWizCCWEstRecord = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_MILL_POCKET);
         var _loc3_:GWizCCWEstRecord = this.selectParent(param1);
         var _loc4_:GWizCCWEstRecord = this.selectParent(param1);
         var _loc5_:String = this.numToFixedStr(_loc3_.height,8,10000);
         var _loc6_:String = this.numToFixedStr(_loc3_.width,8,10000);
         var _loc7_:String = this.numToFixedStr(_loc4_.height,8,10000);
         var _loc8_:String = this.numToFixedStr(_loc4_.width,8,10000);
         var _loc9_:String = _loc5_ + _loc6_;
         var _loc10_:String = _loc7_ + _loc8_;
         GWizUtils.assert(_loc9_.length == 16);
         GWizUtils.assert(_loc10_.length == 16);
         var _loc11_:String = "";
         var _loc12_:int = 0;
         while(_loc12_ < 16)
         {
            if(GWizUtils.randLimitsNum(0,1) <= 0.5)
            {
               _loc11_ += _loc9_.charAt(_loc12_);
            }
            else
            {
               _loc11_ += _loc10_.charAt(_loc12_);
            }
            _loc12_++;
         }
         _loc2_.width = Number(_loc11_.substr(8,8)) / 10000;
         _loc2_.width = Math.min(_loc2_.width,this.maxWidth);
         _loc2_.height = Number(_loc11_.substr(0,8)) / 10000;
         _loc2_.height = Math.max(this.maxDepth / PASS_LIMIT,_loc2_.height);
         _loc2_.height = Math.min(_loc2_.height,Math.min(this.maxDepth,this.maxToolDOC(true)));
         _loc2_.height = this.maxDepth / int(this.maxDepth / _loc2_.height);
         if(false && GWizUtils.debug)
         {
            _loc13_ = this.maxDepth / _loc2_.height;
            _loc14_ = int(this.maxDepth / _loc2_.height);
            if(_loc13_ - _loc14_ > 0.001)
            {
               GWizUtils.assert(false);
            }
         }
         return this.cutMRR(GWizCCWEstRecord.CCE_MILL_POCKET,_loc2_.width,_loc2_.height,true,this.tests > 0,GWizToolChooser.useBallnose,GWizFeedsSpeeds2.PLUNGE_HELIX);
      }
      
      private function pairedOrg2(param1:Number) : GWizCCWEstRecord
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:GWizCCWEstRecord = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_MILL_POCKET);
         var _loc3_:GWizCCWEstRecord = this.selectParent(param1);
         var _loc4_:GWizCCWEstRecord = this.selectParent(param1);
         if(GWizUtils.randLimitsNum(0,1) <= 0.5)
         {
            _loc2_.width = _loc3_.width;
         }
         else
         {
            _loc2_.width = _loc4_.width;
         }
         if(GWizUtils.randLimitsNum(0,1) <= CROSSOVER_MUTATE_PCT)
         {
            _loc5_ = _loc2_.width * GWizUtils.randLimitsNum(0,0.2);
            if(GWizUtils.randLimitsNum(0,1) <= 0.5)
            {
               _loc5_ = -_loc5_;
            }
            _loc2_.width += _loc5_;
         }
         if(GWizUtils.randLimitsNum(0,1) <= 0.5)
         {
            _loc2_.height = _loc3_.height;
         }
         else
         {
            _loc2_.height = _loc4_.height;
         }
         if(GWizUtils.randLimitsNum(0,1) <= CROSSOVER_MUTATE_PCT)
         {
            _loc6_ = _loc2_.height * GWizUtils.randLimitsNum(0,0.2);
            if(GWizUtils.randLimitsNum(0,1) <= 0.5)
            {
               _loc6_ = -_loc6_;
            }
            _loc2_.height += _loc6_;
         }
         _loc2_.height = Math.max(this.maxDepth / PASS_LIMIT,_loc2_.height);
         _loc2_.height = Math.min(_loc2_.height,Math.min(this.maxDepth,this.maxToolDOC(true)));
         _loc2_.height = this.maxDepth / int(this.maxDepth / _loc2_.height);
         return this.cutMRR(GWizCCWEstRecord.CCE_MILL_POCKET,_loc2_.width,_loc2_.height,true,this.tests > 0,GWizToolChooser.useBallnose,GWizFeedsSpeeds2.PLUNGE_HELIX);
      }
      
      private function seedPopGrid() : void
      {
         var _loc1_:GWizCCWEstRecord = null;
         var _loc4_:int = 0;
         var _loc2_:int = Math.min(MaxTests / 4,PopSize * 2);
         var _loc3_:int = 0;
         while(_loc3_ < PopSize && this.tests < _loc2_)
         {
            _loc1_ = this.randomOrg();
            while(isNaN(_loc1_.mrr) && this.tests < _loc2_)
            {
               _loc1_ = this.randomOrg();
            }
            if(!isNaN(_loc1_.mrr))
            {
               this.samples.addItemAt(_loc1_,_loc3_);
            }
            _loc3_++;
         }
         if(this.samples.length > 0)
         {
            while(this.samples.length < PopSize)
            {
               _loc4_ = GWizUtils.randLimitsNum(0,this.samples.length);
               _loc1_ = this.samples.getItemAt(_loc4_) as GWizCCWEstRecord;
               this.samples.addItem(_loc1_);
            }
         }
      }
      
      private function firstSampleNaNMRR() : int
      {
         var _loc1_:int = -1;
         var _loc2_:int = 0;
         while(_loc2_ < this.samples.length)
         {
            if(isNaN(this.samples.getItemAt(_loc2_).mrr))
            {
               _loc1_ = _loc2_;
               break;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      private function gaCompare(param1:GWizCCWEstRecord, param2:GWizCCWEstRecord, param3:Array = null) : int
      {
         var _loc4_:Number = this.fitness(param1);
         param1.fitness = _loc4_;
         var _loc5_:Number = this.fitness(param2);
         param2.fitness = _loc5_;
         var _loc6_:int = 0;
         if(_loc4_ > _loc5_ || isNaN(_loc5_) && !isNaN(_loc4_))
         {
            _loc6_ = -1;
         }
         else if(_loc4_ < _loc5_ || isNaN(_loc4_) && !isNaN(_loc5_))
         {
            _loc6_ = 1;
         }
         return _loc6_;
      }
      
      private function fitness(param1:GWizCCWEstRecord) : Number
      {
         var _loc2_:Number = param1.mrr;
         var _loc3_:int = int(this.maxDepth / param1.height);
         return Number(_loc2_ * (1 - _loc3_ * this.PER_PASS_MRR_PENALTY));
      }
      
      private function nextGeneration() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:GWizCCWEstRecord = null;
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc6_:GWizCCWEstRecord = null;
         var _loc7_:GWizCCWEstRecord = null;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         this.showTests("Begin nextGeneration:");
         rerunBestGA = false;
         if(!GWizCadCam.CADCAMWiz || !GWizCadCam.CADCAMWiz.showing || this.samples.length <= 0 || this.stopGA)
         {
            this.restoreUI();
            this.gaRunning = false;
            return;
         }
         this.samples.refresh();
         ++this.genCt;
         this.bestMRR = this.samples.getItemAt(0).fitness;
         if(GWizUtils.debug)
         {
            log.debug("bestMRR = " + this.bestMRR + ", Width = " + this.samples.getItemAt(0).width + ", value = " + this.samples.getItemAt(0).fitness);
            log.debug("Hints: " + this.samples.getItemAt(0).hints);
         }
         if(isNaN(this.priorMRR))
         {
            this.priorMRR = this.bestMRR;
         }
         else
         {
            _loc1_ = (this.bestMRR - this.priorMRR) / this.priorMRR;
            if(_loc1_ < 0.01 || isNaN(_loc1_))
            {
               ++this.noBetter;
            }
            else
            {
               this.noBetter = 0;
               this.priorMRR = this.bestMRR;
            }
            if(this.noBetter >= MAX_NO_BETTER)
            {
               this.done = true;
               if(false && GWizUtils.debug)
               {
                  log.debug("Best GA ID=" + this.samples.getItemAt(0).createID);
                  log.debug("Min Cut Depth: " + this.depthLimitMin);
                  log.debug("Max Cut Depth: " + this.depthLimitMax);
               }
            }
         }
         if(this.tests >= MaxTests)
         {
            this.done = true;
         }
         if(!this.done)
         {
            _loc2_ = 0;
            _loc4_ = new Array();
            _loc5_ = 0;
            _loc2_ = 0;
            while(_loc2_ < this.samples.length)
            {
               _loc6_ = this.samples.getItemAt(_loc2_) as GWizCCWEstRecord;
               if(_loc2_ < FirstPaired)
               {
                  _loc4_[_loc4_.length] = _loc6_;
               }
               if(_loc6_.hasOwnProperty("mrr") && !isNaN(_loc6_.mrr))
               {
                  _loc5_ += _loc6_.mrr;
               }
               _loc2_++;
            }
            while(_loc4_.length < FirstRandom && this.tests <= MaxTests)
            {
               _loc3_ = this.pairedOrg(_loc5_);
               if(!isNaN(_loc3_.mrr))
               {
                  _loc4_[_loc4_.length] = _loc3_;
               }
            }
            while(_loc4_.length < GWizCCWRecalc.PopSize && this.tests <= MaxTests)
            {
               _loc3_ = this.randomOrg();
               if(!isNaN(_loc3_.mrr))
               {
                  _loc4_[_loc4_.length] = _loc3_;
               }
            }
            this.samples = null;
            this.samples = new ArrayCollection();
            _loc2_ = 0;
            while(_loc2_ < _loc4_.length)
            {
               _loc3_ = _loc4_[_loc2_] as GWizCCWEstRecord;
               if(!isNaN(_loc3_.mrr))
               {
                  this.samples.addItem(_loc3_);
               }
               _loc2_++;
            }
            if(false && GWizUtils.debug)
            {
               GWizUtils.assert(this.firstSampleNaNMRR() == -1);
            }
         }
         if(!this.done)
         {
            GWizCadCam.CADCAMWiz.callLater(this.nextGeneration);
            if(this.progBar != null)
            {
               this.progBar(this.tests,GWizCCWRecalc.MaxTests);
            }
         }
         else
         {
            this.stopGA = true;
            if(false && GWizUtils.debug)
            {
               GWizUtils.assert(this.firstSampleNaNMRR() == -1);
            }
            _loc8_ = true;
            if(!isNaN(this.bestMRR) && this.samples.length > 0)
            {
               _loc7_ = this.cutMRR(GWizCCWEstRecord.CCE_MILL_POCKET,this.samples.getItemAt(0).width,this.samples.getItemAt(0).height,true,!this.QUICKIE,GWizToolChooser.useBallnose,GWizFeedsSpeeds2.PLUNGE_HELIX);
               _loc9_ = int(this.maxDepth / _loc7_.height);
               if(_loc7_.height * _loc9_ < this.maxDepth - 0.001)
               {
                  _loc9_++;
               }
               _loc7_.passes = _loc9_;
               _loc7_.tests = this.tests;
               _loc7_.tool = GWizToolChooser.getToolDesc(true,this.largeRougher,this.maxWidth,this.flutes);
               if(false && GWizUtils.debug)
               {
                  if(isNaN(_loc7_.mrr))
                  {
                     log.debug("samples.getItemAt(0).mrr = " + this.samples.getItemAt(0).mrr);
                  }
               }
               _loc8_ = false;
            }
            this.gaTests = this.tests;
            if(this.finishFcn != null)
            {
               this.finishFcn(_loc7_,_loc8_,GWizToolChooser.useBallnose);
            }
            this.restoreUI();
            this.gaRunning = false;
         }
         if(false && GWizUtils.debug)
         {
            GWizUtils.assert(this.firstSampleNaNMRR() == -1);
         }
         this.showTests("End nextGeneration:");
      }
      
      public function drillMRR(param1:String, param2:Number, param3:Number, param4:Boolean, param5:Number, param6:Boolean) : GWizCCWEstRecord
      {
         var _loc7_:GWizCCWEstRecord = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_DRILL);
         this.drillDFM = "";
         (_loc7_ = this.toolInfoFromGUID(_loc7_,this.cribToolGUID,GWizToolChooser.getToolStr(),param2,2,param3 + 2 * param2,String(false),String(false),String(false))).width = param5;
         _loc7_.height = param3;
         _loc7_.holeDepth = param3;
         _loc7_.peck = param5;
         if(isNaN(param2) || isNaN(param3))
         {
            GWizUtils.assert(false);
            _loc7_.mrr = NaN;
            return _loc7_;
         }
         this.saveUI();
         _loc7_.op = GWizCCWEstRecord.CCE_DRILL;
         GWizSettings.FeedsSpeedsApp.api.SetupDrillUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,GWizToolChooser.getToolStr(),param4,param2,_loc7_.height,GWizCCWMillOptions.GasPedalSlider,param6);
         _loc7_.tool = GWizToolChooser.getDrillName(GWizToolChooser.toolStr,param2,param4);
         _loc7_.passes = 1;
         _loc7_ = this.addStdResultFields(_loc7_);
         _loc7_.opTime = _loc7_.timeByType();
         this.drillDFM = GWizSettings.FeedsSpeedsApp.api.cuttingErr();
         if(this.drillDFM != "")
         {
            _loc7_.mrr = NaN;
         }
         else if(_loc7_.rpm == 0)
         {
            this.drillDFM = "Error: No viable feeds and speeds for these parameters.\n";
            this.drillDFM += GWizSettings.FeedsSpeedsApp.hint.text;
         }
         if(this.drillDFM == "")
         {
            this.drillDFM = GWizToolChooser.drillDFM;
         }
         this.restoreUI();
         return _loc7_;
      }
      
      public function reamMRR(param1:Number, param2:Number) : GWizCCWEstRecord
      {
         var _loc3_:GWizCCWEstRecord = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_REAM);
         if(isNaN(param1) || isNaN(param2))
         {
            GWizUtils.assert(false);
            _loc3_.mrr = NaN;
            return _loc3_;
         }
         this.saveUI();
         _loc3_.op = GWizCCWEstRecord.CCE_REAM;
         _loc3_.tool = "HSS Reamer";
         _loc3_.height = param2;
         _loc3_.stickout = param2 + 2 * param1;
         _loc3_.holeDepth = param2;
         _loc3_.peck = 0;
         GWizSettings.FeedsSpeedsApp.api.SetupDrillUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,"HSS Reamer",false,param1,_loc3_.height,GWizCCWMillOptions.GasPedalSlider,false);
         _loc3_.toolDia = param1;
         _loc3_.tool = GWizUtils.roundThousandths(param1,true) + GWizUtils.inOrMM() + " HSS Reamer";
         _loc3_.passes = 1;
         _loc3_ = this.addStdResultFields(_loc3_);
         this.drillDFM = GWizSettings.FeedsSpeedsApp.api.cuttingErr();
         if(this.drillDFM != "")
         {
            _loc3_.mrr = NaN;
         }
         _loc3_.opTime = _loc3_.timeByType();
         this.restoreUI();
         return _loc3_;
      }
      
      public function tappingMRR(param1:Boolean, param2:Boolean, param3:Number, param4:Number, param5:Number) : GWizCCWEstRecord
      {
         var _loc6_:GWizCCWEstRecord = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_MILL_HOLE);
         if(isNaN(param3) || isNaN(param4) || isNaN(param5))
         {
            GWizUtils.assert(false);
            _loc6_.mrr = NaN;
            return _loc6_;
         }
         this.saveUI();
         _loc6_.op = GWizCCWEstRecord.CCE_TAP;
         if(param2)
         {
            _loc6_.tool = "Carbide Tapping";
         }
         else
         {
            _loc6_.tool = "HSS Tapping";
         }
         _loc6_.height = param5;
         _loc6_.stickout = param5 + 0.1 * param3;
         _loc6_.holeDepth = param5;
         _loc6_.peck = 0;
         GWizSettings.FeedsSpeedsApp.api.SetupDrillUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,_loc6_.tool,!param1,param3,_loc6_.height,GWizCCWMillOptions.GasPedalSlider,false,param4);
         _loc6_.toolDia = param3;
         _loc6_.width = param4;
         _loc6_.passes = 1;
         _loc6_ = this.addStdResultFields(_loc6_);
         this.drillDFM = GWizSettings.FeedsSpeedsApp.api.cuttingErr();
         if(this.drillDFM != "")
         {
            _loc6_.mrr = NaN;
         }
         _loc6_.opTime = _loc6_.timeByType();
         this.restoreUI();
         return _loc6_;
      }
      
      public function threadMillMRR(param1:Number, param2:Number, param3:Number) : GWizCCWEstRecord
      {
         var _loc4_:GWizCCWEstRecord = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_MILL_POCKET);
         if(isNaN(param1) || isNaN(param2) || isNaN(param3))
         {
            GWizUtils.assert(false);
            _loc4_.mrr = NaN;
            return _loc4_;
         }
         this.saveUI();
         _loc4_.op = "Thread Mill";
         _loc4_.tool = "Carbide Thread Mill";
         _loc4_.height = param3;
         _loc4_.stickout = param3 + 0.1 * param1;
         _loc4_.holeDepth = param3;
         _loc4_.peck = 0;
         GWizSettings.FeedsSpeedsApp.api.SetupDrillUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,_loc4_.tool,false,param1,_loc4_.height,GWizCCWMillOptions.GasPedalSlider,false,param2);
         _loc4_.toolDia = param1;
         _loc4_.volume = Math.PI * (param1 / 2) * (param1 / 2) * param3;
         _loc4_.passes = 1;
         _loc4_ = this.addStdResultFields(_loc4_);
         this.drillDFM = GWizSettings.FeedsSpeedsApp.api.cuttingErr();
         if(this.drillDFM.indexOf("Error") >= 0)
         {
            _loc4_.mrr = NaN;
         }
         _loc4_.opTime = _loc4_.timeByType();
         this.restoreUI();
         return _loc4_;
      }
      
      public function chamferMill(param1:String, param2:Number, param3:Number, param4:Number, param5:Boolean, param6:Number) : GWizCCWEstRecord
      {
         return this.spotDrill(param1,param2,param3,param4,param5,param6,true);
      }
      
      public function spotDrill(param1:String, param2:Number, param3:Number, param4:Number, param5:Boolean, param6:Number, param7:Boolean) : GWizCCWEstRecord
      {
         var _loc8_:Number = param2 / 2;
         if(param3 > 0)
         {
            _loc8_ = (2 * param3 + param2) / 2;
         }
         var _loc9_:GWizCCWEstRecord = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,param1);
         this.drillDFM = "";
         if(isNaN(param2) || isNaN(_loc8_))
         {
            GWizUtils.assert(false);
            _loc9_.mrr = NaN;
            return _loc9_;
         }
         this.saveUI();
         _loc9_.op = param3 > 0 ? GWizCCWEstRecord.CCE_CHAMFER : GWizCCWEstRecord.CCE_SPOT_DRILL;
         if(param5)
         {
            _loc9_.tool = "Carbide";
         }
         else
         {
            _loc9_.tool = "HSS";
         }
         if(param7)
         {
            _loc9_.tool += " Chamfer Endmill";
         }
         else
         {
            _loc9_.tool += " Spot Drill";
         }
         _loc9_.width = 0;
         _loc9_.height = _loc8_;
         _loc9_.stickout = 6 * param2;
         _loc9_.holeDepth = _loc8_;
         _loc9_.peck = 0;
         GWizSettings.FeedsSpeedsApp.api.SetupDrillUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,_loc9_.tool,false,param2,_loc9_.height,GWizCCWMillOptions.GasPedalSlider,false);
         _loc9_.toolDia = param2;
         if(!param7)
         {
            _loc9_.tool = GWizToolChooser.getSpotDrillName(param2,param5);
         }
         else
         {
            _loc9_.tool = String(GWizCadCam.CADCAMWiz.ccwOptions.ChamferToolDia.getVal()) + " " + _loc9_.tool;
         }
         _loc9_.passes = 1;
         _loc9_.var1 = param6;
         _loc9_ = this.addStdResultFields(_loc9_);
         this.drillDFM = GWizSettings.FeedsSpeedsApp.api.cuttingErr();
         if(this.drillDFM != "")
         {
            _loc9_.mrr = NaN;
         }
         var _loc10_:Number = param4 / _loc9_.feedrate;
         _loc9_.opTime = _loc9_.timeByType() + _loc10_;
         this.restoreUI();
         return _loc9_;
      }
      
      private function saveUI() : void
      {
         if(!this.fsUI)
         {
            this.fsUI = GWizSettings.FeedsSpeedsApp.api.saveUI();
            GWizSettings.FeedsSpeedsApp.runningAutomation = true;
         }
         ++this.fsUILvl;
      }
      
      private function restoreUI() : void
      {
         --this.fsUILvl;
         if(this.fsUILvl <= 0)
         {
            GWizSettings.FeedsSpeedsApp.api.restoreUI(this.fsUI);
            this.fsUI = null;
            this.fsUILvl = 0;
            GWizSettings.FeedsSpeedsApp.runningAutomation = false;
         }
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
