package cadcamwiz
{
   import comps.GWizEstOpPickerAPI;
   import comps.GWizForePanel;
   import comps.GWizNumStepOvr;
   import comps.ProgressBar;
   import configinfo.GWizSettings;
   import feedsspeeds.GWizFeedSpeedPopup;
   import feedsspeeds.GWizFeedsSpeeds2;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IVisualElement;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.HGroup;
   import spark.components.HSlider;
   import spark.components.Label;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import tools.GWizToolChooser;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   import utils.SequencedArrayCollection;
   
   use namespace mx_internal;
   
   public class GWizCCWGenericWizard extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizGenericCCWizard");
      
      private static var fsParmsKeeper:Object = null;
      
      private static var tunerQueue:Array = [];
      
      private static var tunerPop:Array = [];
      
      public static var Instance:GWizCCWGenericWizard;
      
      private static var currTuner:Object;
      
      private static var runningTuner:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _67595DFM:TextArea;
      
      private var _2013789632DFMBox:GWizForePanel;
      
      private var _1924643324EstInput:GWizCCWEstimatorInput;
      
      private var _126380266FeedsBox:GWizCCWResultsGrid;
      
      private var _583151870InputsBox:HGroup;
      
      private var _927043987OptionsBox:HGroup;
      
      private var _1898379620TimeFactor:GWizNumStepOvr;
      
      private var _2011835195TimesBox:GWizForePanel;
      
      private var _2011819820TimesRow:VGroup;
      
      private var _826032983TortHare:GWizCCWTortHare;
      
      public var _GWizCCWGenericWizard_Label3:Label;
      
      private var _1449321101estTime:Label;
      
      private var _1011090354opTime:Label;
      
      private var _405269690opTimeLabel:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var inputs:Object;
      
      public var options:Object;
      
      private var _97483395theLabelWidth:int = 90;
      
      public var opPickerAPI:GWizEstOpPickerAPI;
      
      private var optionsElement:IVisualElement = null;
      
      private var howLongToWait:int = 5;
      
      public var start:Date;
      
      public var useHSM:Boolean = false;
      
      public var useLarge:Boolean = false;
      
      public var useCorncob:Boolean = false;
      
      public var useIndexable:Boolean = false;
      
      public var useFacemill:Boolean = false;
      
      private var use3DPerimeter:Boolean = false;
      
      private var currCribToolGUID:String = "";
      
      private const ROUGHING_RESULT:int = 0;
      
      private const FINISH_RESULT:int = 1;
      
      private var _1097546742results:SequencedArrayCollection;
      
      public var feedsDialog:GWizFeedSpeedPopup = null;
      
      public var dfmNum:int = 1;
      
      private var ranGeneticAlgorithm:Boolean = false;
      
      private var originalLabel:String = "";
      
      public var progress:ProgressBar;
      
      public var GasPedal:HSlider;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWGenericWizard()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.opPickerAPI = new GWizEstOpPickerAPI(this.UIToOp,this.OpToUI);
         this._1097546742results = new SequencedArrayCollection();
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWGenericWizard_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWGenericWizardWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWGenericWizard[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.gap = 1;
         this.paddingLeft = 0;
         this.paddingRight = 0;
         this.paddingTop = 0;
         this.paddingBottom = 0;
         this.mxmlContent = [this._GWizCCWGenericWizard_HGroup1_i(),this._GWizCCWGenericWizard_HGroup2_i(),this._GWizCCWGenericWizard_GWizCCWResultsGrid1_i(),this._GWizCCWGenericWizard_GWizForePanel1_i(),this._GWizCCWGenericWizard_GWizForePanel2_i()];
         this.addEventListener("creationComplete",this.___GWizCCWGenericWizard_VGroup1_creationComplete);
         this.addEventListener("hide",this.___GWizCCWGenericWizard_VGroup1_hide);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function estRecToFeedsSpeedsApp(param1:GWizCCWEstRecord, param2:String, param3:String, param4:Number, param5:Boolean) : void
      {
         var _loc6_:GWizJustASec = null;
         if(param1 && GWizSettings.FeedsSpeedsApp != null)
         {
            fsParmsKeeper = new Object();
            fsParmsKeeper.entry = param1;
            fsParmsKeeper.machine = param2;
            fsParmsKeeper.material = param3;
            fsParmsKeeper.slider = param4;
            fsParmsKeeper.usePremiumCoolant = param5;
            _loc6_ = new GWizJustASec(estRecToFSAppAux,-1);
         }
      }
      
      public static function estRecToFSAppAux() : void
      {
         var _loc1_:String = fsParmsKeeper.entry.tool;
         var _loc2_:* = _loc1_.toLowerCase().indexOf("ballnose") >= 0;
         GWizSettings.FeedsSpeedsApp.api.SetupUIGeometry(fsParmsKeeper.machine,fsParmsKeeper.material,fsParmsKeeper.entry.guid,fsParmsKeeper.entry.tool,fsParmsKeeper.entry.toolDia,fsParmsKeeper.entry.flutes,fsParmsKeeper.entry.stickout,fsParmsKeeper.entry.height,fsParmsKeeper.entry.width,fsParmsKeeper.entry.roughingTrue(),fsParmsKeeper.entry.hsmTrue(),fsParmsKeeper.entry.corncobTrue(),_loc2_,fsParmsKeeper.slider,fsParmsKeeper.entry.toolOther,0,90,GWizFeedsSpeeds2.plungeModeToIdx(fsParmsKeeper.entry.entryMode),fsParmsKeeper.usePremiumCoolant);
         if(GWizSettings.FeedsSpeedsApp.estInput)
         {
            GWizSettings.FeedsSpeedsApp.estInput.EstDesc.text = fsParmsKeeper.entry.desc;
         }
      }
      
      private static function genRandTuner() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.MaxTests = int(GWizUtils.randLimitsNum(100,4000));
         _loc1_.PopSize = int(GWizUtils.randLimitsNum(100,Math.min(_loc1_.MaxTests,400)));
         _loc1_.FirstPaired = int(GWizUtils.randLimitsNum(0,_loc1_.PopSize));
         _loc1_.FirstRandom = int(GWizUtils.randLimitsNum(_loc1_.FirstPaired,_loc1_.PopSize));
         _loc1_.bestMRR = 0;
         _loc1_.worstMRR = 1000000;
         return _loc1_;
      }
      
      private static function genTestQueue() : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         tunerQueue = [];
         tunerPop = [];
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < 100)
         {
            _loc3_ = genRandTuner();
            tunerPop[_loc2_] = _loc3_;
            _loc4_ = 0;
            while(_loc4_ < 5)
            {
               var _loc5_:*;
               tunerQueue[_loc5_ = _loc1_++] = _loc3_;
               _loc4_++;
            }
            _loc2_++;
         }
      }
      
      private static function runQueue() : void
      {
         if(tunerQueue.length > 0)
         {
            testTuner(tunerQueue.pop());
         }
         else
         {
            analyzeTuners();
         }
      }
      
      private static function testTuner(param1:Object) : void
      {
         currTuner = param1;
         GWizCCWRecalc.MaxTests = param1.MaxTests;
         GWizCCWRecalc.PopSize = param1.PopSize;
         GWizCCWRecalc.FirstPaired = param1.FirstPaired;
         GWizCCWRecalc.FirstRandom = param1.FirstRandom;
         Instance.recalcAux();
      }
      
      private static function analyzeTuners() : void
      {
         var _loc2_:Object = null;
         log.debug("Trial, Best, Worst, Depth, Scenarios, MaxTests, PopSize, FirstPaired, FirstRandom");
         var _loc1_:int = 0;
         while(_loc1_ < 100)
         {
            _loc2_ = tunerPop[_loc1_];
            log.debug(_loc1_ + ", " + _loc2_.bestMRR + ", " + _loc2_.worstMRR + ", " + _loc2_.height + ", " + _loc2_.scenarios + ", " + _loc2_.MaxTests + ", " + _loc2_.PopSize + ", " + _loc2_.FirstPaired + ", " + _loc2_.FirstRandom);
            _loc1_++;
         }
      }
      
      public static function tunerTest() : void
      {
         runningTuner = true;
         genTestQueue();
         runQueue();
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWGenericWizard._watcherSetupUtil = param1;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      public function onCC() : void
      {
         this.inputs = new GWizCCPocketInputs();
         this.inputs.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installInputs(this.inputs);
         this.options = new GWizCCPocketOptions();
         this.options.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installOptions(this.options);
         this.GasPedal = this.TortHare.GasPedalSlider;
         if(!Instance)
         {
            Instance = this;
         }
         GWizCadCam.CADCAMWiz.requestRecalc();
      }
      
      public function opType() : String
      {
         GWizUtils.assert(false);
         return GWizCCWEstRecord.MACHINING_TYPE;
      }
      
      public function hasOptions() : Boolean
      {
         return true;
      }
      
      protected function getPocketOptions() : GWizCCPocketOptions
      {
         return new GWizCCPocketOptions();
      }
      
      protected function installInputs(param1:Object) : void
      {
         var _loc2_:int = this.removeInputs();
         this.addElementAt(IVisualElement(param1),_loc2_);
         (param1 as GWizForePanel).labelWidth = this.theLabelWidth;
         this.progress = param1.ProgBar;
      }
      
      protected function removeInputs() : int
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.numChildren)
         {
            _loc2_ = this.getChildAt(_loc1_);
            if(_loc2_.hasOwnProperty("id") && _loc2_.id == "InputsBox")
            {
               this.removeElementAt(_loc1_);
               return _loc1_;
            }
            _loc1_++;
         }
         return -1;
      }
      
      protected function installOptions(param1:Object) : void
      {
         var _loc2_:int = this.removeOptions();
         this.addElementAt(IVisualElement(param1),_loc2_);
         if(param1.hasOwnProperty("labelWidth"))
         {
            param1.labelWidth = this.theLabelWidth;
         }
         this.optionsElement = IVisualElement(param1);
         if(param1.hasOwnProperty("visible"))
         {
            param1.visible = false;
            param1.includeInLayout = false;
         }
      }
      
      protected function removeOptions() : int
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.numChildren)
         {
            _loc2_ = this.getChildAt(_loc1_);
            if(_loc2_.hasOwnProperty("id") && _loc2_.id == "OptionsBox")
            {
               this.removeElementAt(_loc1_);
               this.optionsElement = null;
               return _loc1_;
            }
            _loc1_++;
         }
         return -1;
      }
      
      public function toggleOptions() : void
      {
         var _loc1_:* = false;
         if(this.optionsElement)
         {
            _loc1_ = !this.optionsElement.visible;
            this.optionsElement.visible = _loc1_;
            this.optionsElement.includeInLayout = _loc1_;
         }
         else
         {
            --this.howLongToWait;
            if(this.howLongToWait > 0)
            {
               this.callLater(this.toggleOptions);
            }
         }
      }
      
      public function showMe() : void
      {
         if(!GWizCadCam.CADCAMWiz || !GWizCadCam.CADCAMWiz.ccwOptions || !GWizCadCam.CADCAMWiz.ccwOptions.GasPedal || !this.GasPedal)
         {
            this.callLater(this.showMe);
            return;
         }
         GWizCadCam.CADCAMWiz.showing = true;
         this.GasPedal.value = GWizCadCam.CADCAMWiz.ccwOptions.GasPedal.value;
         this.EstInput.setHourlyRate();
         GWizCadCam.CADCAMWiz.requestRecalc();
      }
      
      public function hideMe() : void
      {
         GWizCadCam.CADCAMWiz.showing = false;
         this.endRecalc();
      }
      
      public function checkUnitsOptions() : void
      {
         if(this.options)
         {
            this.options.ToolDia.checkUnits();
            this.options.Stickout.checkUnits();
            this.inputs.finishPassGrp.FinishPass.checkUnits();
         }
      }
      
      public function initStrategies(param1:Object) : void
      {
         var _loc2_:String = !!param1.roughStrat.selectedItem ? param1.roughStrat.selectedItem.name.toUpperCase() : "";
         this.useHSM = _loc2_.indexOf("HSM") >= 0;
         this.useLarge = _loc2_.indexOf("LARGE") >= 0;
         this.useCorncob = _loc2_.indexOf("CORNCOB") >= 0;
         this.useIndexable = _loc2_.indexOf("INDEXABLE") >= 0;
         this.useFacemill = false;
      }
      
      public function isProfile() : Boolean
      {
         return false;
      }
      
      public function recalcPrefix(param1:String) : Boolean
      {
         if(!GWizCadCam.CADCAMWiz || !GWizCadCam.CADCAMWiz.showing || !this.options && this.hasOptions() || GWizCadCam.recalcEngine.gaRunning)
         {
            return true;
         }
         this.beginDFMHints();
         if(GWizSettings.FeedsSpeedsApp == null || GWizCadCam.CADCAMWiz == null || GWizCadCam.recalcEngine == null || this.inputs == null || this.progress == null)
         {
            this.callLater(this.recalcAux);
            return true;
         }
         var _loc2_:String = GWizMachSettings.currMachType == "Router" ? "Mill" : GWizMachSettings.currMachType;
         if(_loc2_ != param1 && param1 != "")
         {
            this.endRecalc();
            return true;
         }
         this.start = new Date();
         this.disableOutputs();
         this.results.removeAll();
         return false;
      }
      
      public function recalcSuffix(param1:Number) : void
      {
         this.opTime.text = GWizUtils.formatMinToHMS(param1);
         this.estTime.text = GWizUtils.formatMinToHMS(param1 * this.TimeFactor.getVal() / 100);
         if(isNaN(param1))
         {
            this.opTime.text = "Errors";
            this.estTime.text = "Errors";
         }
         this.endDFMHints();
         this.FeedsBox.Results.requestedRowCount = 1;
         this.FeedsBox.Results.height = NaN;
         this.results.refresh();
         this.invalidateDisplayList();
         this.enableOutputs();
         GWizCadCam.needRecalc = false;
         if(GWizUtils.debug)
         {
            GWizUtils.assert(this.checkResult());
         }
      }
      
      public function recalcAux(param1:Boolean = false, param2:Number = 100.0, param3:Boolean = false) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc12_:Number = NaN;
         if(this.recalcPrefix("Mill"))
         {
            return;
         }
         this.currCribToolGUID = "";
         this.use3DPerimeter = param3;
         var _loc4_:Boolean = true;
         if(this.isProfile())
         {
            _loc4_ = this.inputs.InsideCorners.selected;
         }
         if(!this.useFacemill)
         {
            this.options.Flutes.setVal(GWizToolChooser.calcFlutes());
            _loc5_ = this.options.Flutes.getVal();
         }
         else
         {
            _loc5_ = GWizCadCam.CADCAMWiz.ccwOptions.FaceMillFlutes.getVal();
         }
         if(!this.useFacemill)
         {
            GWizToolChooser.setToolStr(this.options.Carbide.selected,this.options.HSS.selected,this.options.HSSHP.selected,this.options.CarbideHP.selected,this.options.CarbideTiAlN.selected,this.options.roughStrat.selectedItem && this.options.roughStrat.selectedItem.name.toUpperCase().indexOf("INDEXABLE") >= 0,param1);
         }
         else
         {
            GWizToolChooser.setToolStr(false,false,false,false,false,true,false);
         }
         if(!this.useFacemill)
         {
            _loc12_ = 0.25;
            if(this.inputs.hasOwnProperty("MinCorner"))
            {
               _loc12_ = this.inputs.MinCorner.getVal();
            }
            else if(this.inputs.hasOwnProperty("MaxToolDia"))
            {
               _loc12_ = this.inputs.MaxToolDia.getVal() / 2;
            }
            else
            {
               GWizUtils.assert(false);
            }
            this.options.ToolDia.setVal(GWizToolChooser.calcToolDia(GWizToolChooser.toolStr,_loc12_,_loc5_,this.inputs.XExtent.getVal(),this.inputs.YExtent.getVal(),this.options.ToolDia,_loc4_,true,param3));
            this.currCribToolGUID = GWizCCWMillOptions.cribToolGUID;
            this.options.Stickout.setVal(this.inputs.Depth.getVal() + this.options.ToolDia.getVal());
         }
         var _loc7_:Number = NaN;
         var _loc8_:Number = 0.001;
         if(!this.inputs.hasOwnProperty("XYExtent") || this.inputs.XYExtent.selected)
         {
            if(this.inputs.hasOwnProperty("XYExtent"))
            {
               this.inputs.XExtent.enabled = true;
               this.inputs.YExtent.enabled = true;
            }
            this.inputs.Volume.enabled = false;
            if(this.inputs.Volume.hasOwnProperty("resetOverride"))
            {
               this.inputs.Volume.resetOverride();
            }
            if(!this.useFacemill && this.inputs.hasOwnProperty("Perimeter"))
            {
               this.inputs.Perimeter.enabled = false;
               this.inputs.Perimeter.resetOverride();
            }
            _loc6_ = 2 * this.inputs.XExtent.getVal() + 2 * this.inputs.YExtent.getVal();
            if(this.isProfile())
            {
               _loc7_ = this.inputs.stockAllow.getVal();
               if(this.inputs.PartCutout.selected == true)
               {
                  _loc8_ = _loc7_ = this.options.ToolDia.getVal();
               }
               this.inputs.Volume.setVal(_loc6_ * this.inputs.Depth.getVal() * _loc7_ * (param2 / 100));
            }
            else
            {
               this.inputs.Volume.setVal(this.inputs.XExtent.getVal() * this.inputs.YExtent.getVal() * this.inputs.Depth.getVal() * (param2 / 100));
            }
         }
         else
         {
            this.inputs.XExtent.enabled = false;
            this.inputs.YExtent.enabled = false;
            this.inputs.Volume.enabled = true;
            if(!this.useFacemill)
            {
               this.inputs.Perimeter.enabled = true;
            }
            if(!this.useFacemill)
            {
               _loc6_ = GWizCadCam.recalcEngine.perimeterFromVolume(this.inputs.Volume.getVal(),this.inputs.Depth.getVal());
            }
         }
         if(!this.useFacemill)
         {
            this.inputs.Perimeter.setVal(_loc6_);
         }
         this.initStrategies(this.options);
         if(!this.useFacemill)
         {
            _loc9_ = this.options.ToolDia.getVal();
            if(this.options.ToolDia.isOverridden())
            {
               this.currCribToolGUID = "";
            }
         }
         else
         {
            _loc9_ = GWizCadCam.CADCAMWiz.ccwOptions.MaxFaceToolDia.getVal();
         }
         if(!this.useFacemill)
         {
            _loc10_ = this.options.Stickout.getVal();
         }
         else
         {
            _loc10_ = GWizCadCam.CADCAMWiz.ccwOptions.MaxFaceToolDia.getVal();
         }
         var _loc11_:Number = this.inputs.Depth.getVal();
         if(!this.isProfile())
         {
            if(this.inputs && this.inputs.hasOwnProperty("finishPassGrp") && this.inputs.finishPassGrp.useFinish.selected)
            {
               _loc11_ -= this.inputs.finishPassGrp.FinishPass.getVal();
            }
         }
         if(_loc11_ > 0)
         {
            GWizCadCam.recalcEngine.initRecalc(_loc9_,_loc11_,_loc5_,_loc10_,_loc7_,_loc8_,this.useHSM,this.useLarge,this.useCorncob,this.useIndexable,this.useFacemill,GWizCCWMillOptions.usePremiumCoolantOptions);
            this.ranGeneticAlgorithm = false;
            if(_loc9_ >= 0.001)
            {
               this.startProgress(0,GWizCCWRecalc.MaxTests,"Recalc:");
               GWizCadCam.recalcEngine.progBar = this.setProgress;
               GWizCadCam.recalcEngine.recalcRoughingPasses(this.pocketFinish,this.currCribToolGUID);
               this.ranGeneticAlgorithm = true;
            }
            else
            {
               this.stopProgress();
            }
         }
         else
         {
            this.addDFMHint("Error: Finish pass is deeper than max depth.\n");
            this.pocketFinish(null,false,param1);
         }
      }
      
      private function pocketFinish(param1:GWizCCWEstRecord, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:GWizCCWEstRecord = null;
         var _loc7_:GWizCCWEstRecord = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:GWizCCWEstRecord = null;
         var _loc11_:Number = NaN;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         var _loc14_:Boolean = false;
         var _loc15_:Boolean = false;
         var _loc16_:Boolean = false;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:int = 0;
         var _loc20_:Number = NaN;
         var _loc21_:Boolean = false;
         var _loc22_:Number = NaN;
         if(!GWizCadCam.CADCAMWiz.showing)
         {
            this.endRecalc();
            return;
         }
         if(param1)
         {
            _loc7_ = null;
            _loc8_ = param1.passes * param1.height;
            _loc9_ = this.inputs && this.inputs.hasOwnProperty("finishPassGrp") && this.inputs.finishPassGrp && this.inputs.finishPassGrp.useFinish && this.inputs.finishPassGrp.useFinish.selected ? Number(this.inputs.finishPassGrp.FinishPass.getVal()) : Number(0);
            if(this.isProfile())
            {
               _loc9_ = 0;
            }
            if((this.useLarge || this.useIndexable) && !this.useFacemill && !param2 || _loc8_ < this.inputs.Depth.getVal() - _loc9_)
            {
               _loc12_ = false;
               _loc13_ = false;
               _loc14_ = false;
               _loc15_ = false;
               _loc16_ = false;
               if(this.options)
               {
                  _loc12_ = this.options.Carbide.selected;
                  _loc13_ = this.options.HSS.selected;
                  _loc14_ = this.options.HSSHP.selected;
                  _loc15_ = this.options.CarbideHP.selected;
                  _loc16_ = this.options.CarbideTiAlN.selected;
                  _loc17_ = this.options.ToolDia.getVal();
                  _loc18_ = this.inputs.finishPassGrp.FinishPass.getVal();
                  _loc19_ = this.options.Flutes.getVal();
                  _loc20_ = this.options.Stickout.getVal();
                  _loc21_ = this.inputs && this.inputs.finishPassGrp && this.inputs.finishPassGrp.useFinish.selected;
                  _loc4_ = this.inputs.Perimeter.getVal();
                  if(this.use3DPerimeter)
                  {
                     _loc4_ = GWizCCW3DSurface.finishPathLen(this.inputs.XExtent.value,this.inputs.YExtent.value,this.inputs.Depth.value,this.options.ToolDia.getVal(),0.001);
                  }
               }
               else if(this.useFacemill)
               {
                  _loc16_ = true;
                  _loc17_ = GWizCadCam.CADCAMWiz.ccwOptions.MaxFaceToolDia.getVal();
                  _loc18_ = 0;
                  _loc19_ = GWizCadCam.CADCAMWiz.ccwOptions.FaceMillFlutes.getVal();
                  _loc20_ = GWizCadCam.CADCAMWiz.ccwOptions.MaxFaceToolDia.getVal();
                  _loc21_ = false;
                  _loc4_ = 0;
               }
               GWizToolChooser.setToolStr(_loc12_,_loc13_,_loc14_,_loc15_,_loc16_,this.useFacemill,param3);
            }
            if(!this.useFacemill && this.inputs && this.inputs.finishPassGrp && this.inputs.finishPassGrp.useFinish.selected && !param2)
            {
               GWizToolChooser.setToolStr(this.options.Carbide.selected,this.options.HSS.selected,this.options.HSSHP.selected,this.options.CarbideHP.selected,this.options.CarbideTiAlN.selected,false,param3);
               if(_loc10_ = GWizCadCam.recalcEngine.recalcProfilePass(GWizCCWEstRecord.CCE_MILL_POCKET,this.inputs.finishPassGrp.FinishPass.getVal(),this.inputs.Depth.getVal(),this.inputs.Perimeter.getVal(),this.options.ToolDia.getVal(),this.options.Flutes.getVal(),this.options.Stickout.getVal(),this.inputs.finishPassGrp.useFinish.selected,false,param3,false))
               {
                  _loc10_.perimeter = this.inputs.Perimeter.getVal();
                  _loc4_ = _loc10_.perimeter;
               }
            }
            _loc11_ = this.inputs.Volume.getVal() / this.inputs.Depth.getVal();
            if(_loc10_)
            {
               _loc10_.op = this.opType();
               _loc10_.volume = _loc10_.perimeter * _loc10_.width * this.inputs.Depth.getVal();
               _loc10_.volume += _loc11_ * _loc10_.width;
               _loc10_.opTime = _loc10_.timeByType();
               _loc10_.var1 = this.TimeFactor.value;
            }
            if(_loc7_)
            {
               _loc7_.op = this.opType();
               _loc22_ = Math.max(0,_loc7_.passes * _loc7_.height - _loc8_);
               _loc7_.volume = _loc11_ * _loc22_;
               _loc7_.opTime = _loc7_.timeByType();
               _loc7_.var1 = this.TimeFactor.value;
            }
            if(param1)
            {
               param1.op = this.opType();
               if(param1.op == GWizCCWEstRecord.CCE_MILL_3DSURFACE)
               {
                  param1.op = GWizCCWEstRecord.CCE_MILL_POCKET;
               }
               param1.volume = this.inputs.Volume.getVal();
               param1.opTime = param1.timeByType();
               param1.var1 = this.TimeFactor.value;
               if(this.inputs && this.inputs.hasOwnProperty("Perimeter"))
               {
                  param1.perimeter = this.inputs.Perimeter.getVal();
               }
               else
               {
                  param1.perimeter = NaN;
               }
            }
         }
         if(this.inputs && this.inputs.hasOwnProperty("chamferInputs") && this.inputs.chamferInputs && this.inputs.chamferInputs.Chamfer.selected)
         {
            (_loc5_ = GWizCadCam.recalcEngine.spotDrill(this.opType(),GWizCadCam.CADCAMWiz.ccwOptions.ChamferToolDia.getVal(),this.inputs.chamferInputs.ChamferSize.getVal(),_loc4_,GWizCadCam.CADCAMWiz.ccwOptions.ChamferToolCarbide.selected,this.TimeFactor.value,GWizCadCam.CADCAMWiz.ccwOptions.ChamferMill.selected)).op = GWizCCWEstRecord.CCE_CHAMFER;
            this.results.addItem(_loc5_);
         }
         this.postResults(param1,_loc7_,_loc10_,_loc5_);
         var _loc6_:Date = new Date();
         this.dfmHints(param1,_loc7_,_loc10_,this.start,_loc6_);
         this.endRecalc();
      }
      
      public function endRecalc() : void
      {
         var _loc1_:GWizCCWEstRecord = null;
         this.stopProgress();
         this.enableOutputs();
         GWizCadCam.recalcEngine.gaRunning = false;
         if(GWizUtils.debug)
         {
            GWizUtils.assert(this.checkResult());
         }
         if(GWizUtils.debug && runningTuner && this.results.length > 0)
         {
            _loc1_ = this.results.getItemAt(0) as GWizCCWEstRecord;
            if(_loc1_)
            {
               currTuner.mrr = _loc1_.mrr;
               if(currTuner.bestMRR < currTuner.mrr)
               {
                  currTuner.bestMRR = _loc1_.mrr;
               }
               if(currTuner.worstMRR > currTuner.mrr)
               {
                  currTuner.worstMRR = _loc1_.mrr;
               }
               currTuner.height = _loc1_.height;
               currTuner.scenarios = GWizCadCam.recalcEngine.gaTests;
            }
            log.debug("Tuner Run: Best = " + currTuner.bestMRR + ", Worst = " + currTuner.worstMRR + ", Depth = " + currTuner.height + ", Scenarios = " + currTuner.scenarios + ", MaxTests = " + currTuner.MaxTests + ", PopSize = " + currTuner.PopSize + ", FirstPaired = " + currTuner.FirstPaired + ", FirstRandom = " + currTuner.FirstRandom);
            Instance.callLater(runQueue);
         }
      }
      
      private function postResults(param1:GWizCCWEstRecord, param2:GWizCCWEstRecord, param3:GWizCCWEstRecord, param4:GWizCCWEstRecord = null) : void
      {
         var _loc7_:GWizCCWEstRecord = null;
         this.results.removeAll();
         if(param1)
         {
            if(this.useFacemill)
            {
               param1.op = GWizCCWEstRecord.CCE_MILL_FACEMILL;
            }
            else
            {
               param1.op = "Rough";
            }
            this.results.addItem(param1);
         }
         if(param2)
         {
            param2.op = "Semi-Finish";
            this.results.addItem(param2);
         }
         if(param3)
         {
            param3.op = "Finish";
            this.results.addItem(param3);
         }
         if(param4)
         {
            param4.op = GWizCCWEstRecord.CCE_CHAMFER;
            this.results.addItem(param4);
         }
         this.FeedsBox.Results.requestedRowCount = 1;
         this.FeedsBox.Results.height = NaN;
         var _loc5_:Number = 0;
         var _loc6_:int = 0;
         while(_loc6_ < this.results.length)
         {
            if((_loc7_ = this.results.getItemAt(_loc6_) as GWizCCWEstRecord) && _loc7_.hasOwnProperty("opTime"))
            {
               _loc5_ += _loc7_.opTime;
            }
            _loc6_++;
         }
         this.opTime.text = GWizUtils.formatMinToHMS(_loc5_);
         this.estTime.text = GWizUtils.formatMinToHMS(_loc5_ * this.TimeFactor.getVal() / 100);
         if(isNaN(_loc5_))
         {
            this.opTime.text = "Errors";
            this.estTime.text = "Errors";
         }
         this.results.refresh();
         this.invalidateDisplayList();
      }
      
      private function syncPedal() : void
      {
         if(GWizCadCam.CADCAMWiz && GWizCadCam.CADCAMWiz.ccwOptions && GWizCadCam.CADCAMWiz.ccwOptions.GasPedal && this.TortHare.GasPedalSlider)
         {
            GWizCadCam.CADCAMWiz.ccwOptions.GasPedal.value = this.TortHare.GasPedalSlider.value;
            GWizCCWMillOptions.GasPedalSlider = this.TortHare.GasPedalSlider.value;
            GWizCCWMillOptions.StepoverSlider = this.TortHare.GasPedalSlider.value;
            this.callLater(GWizCadCam.CADCAMWiz.requestRecalc);
         }
         else
         {
            this.callLater(this.syncPedal);
         }
         GWizCadCam._needRecalc = true;
      }
      
      public function doDoubleClick() : void
      {
         if(this.FeedsBox.Results.selectedItem == null && this.results.length > 0)
         {
            this.FeedsBox.Results.selectedIndex = 0;
         }
         if(this.FeedsBox.Results.selectedItem != null)
         {
            if(GWizSettings.TabToFSCalculator != null)
            {
               GWizSettings.TabToFSCalculator();
            }
            this.callLater(this.doDoubleClickAux0);
         }
      }
      
      private function doDoubleClickAux0() : void
      {
         this.callLater(this.doDoubleClickAux);
      }
      
      private function doDoubleClickAux() : void
      {
         var _loc1_:GWizCCWEstRecord = this.FeedsBox.Results.selectedItem as GWizCCWEstRecord;
         if(_loc1_ && GWizSettings.FeedsSpeedsApp != null)
         {
            estRecToFeedsSpeedsApp(_loc1_,GWizCadCam.CADCAMWiz.Machine.dropDown.selectedItem.name,GWizCadCam.CADCAMWiz.MatChooser.Selection,GWizCCWMillOptions.GasPedalSlider,GWizCCWMillOptions.usePremiumCoolantOptions);
         }
      }
      
      public function editRecordAtCursor(param1:GWizFeedsSpeeds2) : void
      {
         var _loc2_:GWizCCWEstRecord = this.FeedsBox.Results.selectedItem as GWizCCWEstRecord;
         GWizUtils.assert(this.feedsDialog.fsCalc != null);
         _loc2_.fromFeedsSpeeds(this.feedsDialog.fsCalc);
         this.results.refresh();
      }
      
      public function beginDFMHints() : void
      {
         this.DFM.text = "DFM Hints:\n";
         this.dfmNum = 1;
      }
      
      public function addDFMHint(param1:String, param2:String = "") : void
      {
         if(param1.length > 0)
         {
            this.DFM.text += this.dfmNum + ". ";
            this.DFM.text += param2 + param1;
            ++this.dfmNum;
         }
      }
      
      public function endDFMHints() : void
      {
         var _loc1_:ArrayCollection = null;
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         if(this.dfmNum == 1)
         {
            _loc1_ = this.FeedsBox.results;
            if(_loc1_)
            {
               _loc2_ = false;
               _loc3_ = false;
               _loc4_ = 0;
               while(_loc4_ < _loc1_.length)
               {
                  if((_loc5_ = _loc1_.getItemAt(_loc4_)).hasOwnProperty("hints"))
                  {
                     _loc6_ = _loc5_.hints;
                     _loc2_ = _loc2_ || _loc6_.toLowerCase().indexOf("error") >= 0;
                     _loc3_ = _loc3_ || _loc6_.toLowerCase().indexOf("warning") >= 0;
                  }
                  _loc4_++;
               }
               if(_loc2_)
               {
                  this.addDFMHint("Errors in results.  See Hints column.");
               }
               if(_loc3_)
               {
                  this.addDFMHint("Warnings in results.  See Hints column.");
               }
            }
            if(this.dfmNum == 1)
            {
               this.DFM.text = "DFM Hints:  \n\nNo suggestions: design looks good!\n";
            }
         }
      }
      
      private function nonCribToolWarning() : String
      {
         var _loc3_:int = 0;
         var _loc4_:GWizCCWEstRecord = null;
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = this.options && this.options.hasOwnProperty("ToolDia") && this.options.ToolDia.isOverridden();
         if(!_loc2_ && GWizCCWMillOptions.useCribForSolidEndmills() && this.results && this.results.length > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < this.results.length)
            {
               if((_loc4_ = GWizCCWEstRecord(this.results.getItemAt(_loc3_))).guid == "" && _loc4_.tool.indexOf("Endmill") >= 0)
               {
                  return "Couldn\'t find one or more tools in crib. Ideal tool used in results.\n";
               }
               _loc3_++;
            }
         }
         return "";
      }
      
      public function addDFMRunTime(param1:Date, param2:Date) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Number = (param2.time - param1.time) / 1000;
         this.DFM.text += "\nCalculation Time: " + int(_loc3_) + " seconds. ";
         _loc4_ = GWizCadCam.recalcEngine.tests;
         if(this.ranGeneticAlgorithm)
         {
            _loc4_ = GWizCadCam.recalcEngine.gaTests;
            this.ranGeneticAlgorithm = false;
         }
         this.DFM.text += _loc4_ + " scenarios tested.";
      }
      
      public function dfmHints(param1:GWizCCWEstRecord, param2:GWizCCWEstRecord, param3:GWizCCWEstRecord, param4:Date, param5:Date) : void
      {
         try
         {
            if(!this.useFacemill && this.options.ToolDia.getVal() * 12 < this.inputs.Depth.getVal())
            {
               this.addDFMHint("Keep corner radii greater than 1/6 of pocket depth for best tool rigidity.\n");
            }
         }
         catch(e:Error)
         {
         }
         if(!param1 && !param2 && !param3)
         {
            this.addDFMHint("Error: No viable feeds and speeds for these parameters.\n");
            this.addNoViableMsgs();
         }
         else if(param1 && param1.hasOwnProperty("dfm"))
         {
            this.addDFMHint(param1.dfm);
         }
         if(param2 && param2.hasOwnProperty("dfm"))
         {
            this.addDFMHint(param2.dfm);
         }
         if(param3 && param3.hasOwnProperty("dfm"))
         {
            this.addDFMHint(param3.dfm);
         }
         this.addDFMHint(this.nonCribToolWarning());
         this.endDFMHints();
         this.addDFMRunTime(param4,param5);
      }
      
      private function addNoViableMsgs() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(this.results && GWizCCWRecalc.notViableErrors)
         {
            _loc1_ = 0;
            while(_loc1_ < GWizCCWRecalc.notViableErrors.length)
            {
               _loc2_ = GWizCCWRecalc.notViableErrors.getItemAt(_loc1_);
               _loc3_ = "[Strength " + _loc2_.count + "] " + _loc2_.error;
               this.addDFMHint(_loc3_);
               _loc1_++;
            }
         }
      }
      
      private function startProgress(param1:Number, param2:Number, param3:String, param4:Boolean = false) : void
      {
         if(this.progress)
         {
            this.progress.visible = true;
            this.progress.minimum = param1;
            this.progress.maximum = param2;
            this.progress.value = 0;
            this.originalLabel = param3;
            this.progress.visible = true;
         }
      }
      
      private function setProgress(param1:Number, param2:Number) : void
      {
         if(this.progress)
         {
            this.progress.maximum = param2;
            this.progress.value = param1;
         }
      }
      
      private function stopProgress() : void
      {
         if(this.progress)
         {
            this.progress.visible = false;
         }
         this.enableOutputs();
      }
      
      public function disableOutputs() : void
      {
         this.OptionsBox.enabled = false;
         this.FeedsBox.enabled = false;
         this.TimesBox.enabled = false;
         this.DFMBox.enabled = false;
      }
      
      public function enableOutputs() : void
      {
         this.OptionsBox.enabled = true;
         this.FeedsBox.enabled = true;
         this.TimesBox.enabled = true;
         this.DFMBox.enabled = true;
      }
      
      public function inchesToDispUnits(param1:Number) : String
      {
         return GWizUtils.formatPlaces(param1,3,true);
      }
      
      public function UIToOp(param1:GWizCCWEstRecord) : void
      {
         param1.type = GWizCCWEstRecord.MACHINING_TYPE;
      }
      
      public function OpToUI(param1:GWizCCWEstRecord) : void
      {
      }
      
      public function checkResult() : Boolean
      {
         return true;
      }
      
      public function testcase(param1:String, param2:Boolean) : void
      {
         log.debug(param1);
         if(!param2)
         {
            GWizUtils.assert(false);
         }
      }
      
      private function _GWizCCWGenericWizard_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.id = "InputsBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.InputsBox = _loc1_;
         BindingManager.executeBindings(this,"InputsBox",this.InputsBox);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_HGroup2_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.id = "OptionsBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.OptionsBox = _loc1_;
         BindingManager.executeBindings(this,"OptionsBox",this.OptionsBox);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_GWizCCWResultsGrid1_i() : GWizCCWResultsGrid
      {
         var _loc1_:GWizCCWResultsGrid = new GWizCCWResultsGrid();
         _loc1_.percentHeight = 100;
         _loc1_.title = "Feeds";
         _loc1_.doubleClickFcn = this.doDoubleClick;
         _loc1_.id = "FeedsBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FeedsBox = _loc1_;
         BindingManager.executeBindings(this,"FeedsBox",this.FeedsBox);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWGenericWizard_Array2_c);
         _loc1_.id = "TimesBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TimesBox = _loc1_;
         BindingManager.executeBindings(this,"TimesBox",this.TimesBox);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_Array2_c() : Array
      {
         return [this._GWizCCWGenericWizard_VGroup2_i(),this._GWizCCWGenericWizard_GWizCCWTortHare1_i()];
      }
      
      private function _GWizCCWGenericWizard_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 50;
         _loc1_.mxmlContent = [this._GWizCCWGenericWizard_HGroup3_c(),this._GWizCCWGenericWizard_HGroup4_c()];
         _loc1_.id = "TimesRow";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TimesRow = _loc1_;
         BindingManager.executeBindings(this,"TimesRow",this.TimesRow);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWGenericWizard_Label1_i(),this._GWizCCWGenericWizard_Label2_i(),this._GWizCCWGenericWizard_GWizNumStepOvr1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Operation Time:";
         _loc1_.id = "opTimeLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.opTimeLabel = _loc1_;
         BindingManager.executeBindings(this,"opTimeLabel",this.opTimeLabel);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0:0.0";
         _loc1_.width = 80;
         _loc1_.id = "opTime";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.opTime = _loc1_;
         BindingManager.executeBindings(this,"opTime",this.opTime);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Op Time Factor (%):  ";
         _loc1_.min = 100;
         _loc1_.max = 5000;
         _loc1_.steps = 1;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__TimeFactor_initialize);
         _loc1_.addEventListener("valueCommit",this.__TimeFactor_valueCommit);
         _loc1_.id = "TimeFactor";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TimeFactor = _loc1_;
         BindingManager.executeBindings(this,"TimeFactor",this.TimeFactor);
         return _loc1_;
      }
      
      public function __TimeFactor_initialize(param1:FlexEvent) : void
      {
         this.TimeFactor.setVal(120);
      }
      
      public function __TimeFactor_valueCommit(param1:FlexEvent) : void
      {
         GWizCadCam.CADCAMWiz.requestRecalc();
      }
      
      private function _GWizCCWGenericWizard_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWGenericWizard_Label3_i(),this._GWizCCWGenericWizard_Label4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Estimate Time:";
         _loc1_.id = "_GWizCCWGenericWizard_Label3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWGenericWizard_Label3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWGenericWizard_Label3",this._GWizCCWGenericWizard_Label3);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0:0.0";
         _loc1_.width = 80;
         _loc1_.id = "estTime";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.estTime = _loc1_;
         BindingManager.executeBindings(this,"estTime",this.estTime);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_GWizCCWTortHare1_i() : GWizCCWTortHare
      {
         var _loc1_:GWizCCWTortHare = new GWizCCWTortHare();
         _loc1_.percentWidth = 50;
         _loc1_.id = "TortHare";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TortHare = _loc1_;
         BindingManager.executeBindings(this,"TortHare",this.TortHare);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.maxHeight = 300;
         _loc1_.title = "DFM";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWGenericWizard_Array6_c);
         _loc1_.id = "DFMBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DFMBox = _loc1_;
         BindingManager.executeBindings(this,"DFMBox",this.DFMBox);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_Array6_c() : Array
      {
         return [this._GWizCCWGenericWizard_TextArea1_i(),this._GWizCCWGenericWizard_GWizCCWEstimatorInput1_i()];
      }
      
      private function _GWizCCWGenericWizard_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "DFM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DFM = _loc1_;
         BindingManager.executeBindings(this,"DFM",this.DFM);
         return _loc1_;
      }
      
      private function _GWizCCWGenericWizard_GWizCCWEstimatorInput1_i() : GWizCCWEstimatorInput
      {
         var _loc1_:GWizCCWEstimatorInput = new GWizCCWEstimatorInput();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "EstInput";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EstInput = _loc1_;
         BindingManager.executeBindings(this,"EstInput",this.EstInput);
         return _loc1_;
      }
      
      public function ___GWizCCWGenericWizard_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizCCWGenericWizard_VGroup1_hide(param1:FlexEvent) : void
      {
         this.hideMe();
      }
      
      private function _GWizCCWGenericWizard_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():ArrayCollection
         {
            return this.results;
         },null,"FeedsBox.results");
         result[1] = new Binding(this,null,null,"FeedsBox.labelWidth","theLabelWidth");
         result[2] = new Binding(this,function():String
         {
            var _loc1_:* = GWizCCWEstimatorInput.addEstimatorItem != null ? "Times" : "Tuning";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"TimesBox.title");
         result[3] = new Binding(this,null,null,"TimesBox.labelWidth","theLabelWidth");
         result[4] = new Binding(this,function():Boolean
         {
            return GWizCCWEstimatorInput.addEstimatorItem != null;
         },null,"TimesRow.visible");
         result[5] = new Binding(this,function():Boolean
         {
            return TimesRow.visible;
         },null,"TimesRow.includeInLayout");
         result[6] = new Binding(this,function():Number
         {
            return opTimeLabel.width;
         },null,"_GWizCCWGenericWizard_Label3.width");
         result[7] = new Binding(this,function():Function
         {
            return syncPedal;
         },null,"TortHare.syncPedalFcn");
         result[8] = new Binding(this,null,null,"DFMBox.labelWidth","theLabelWidth");
         result[9] = new Binding(this,function():GWizCCWGenericWizard
         {
            return this;
         },null,"EstInput.wizard");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get DFM() : TextArea
      {
         return this._67595DFM;
      }
      
      public function set DFM(param1:TextArea) : void
      {
         var _loc2_:Object = this._67595DFM;
         if(_loc2_ !== param1)
         {
            this._67595DFM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DFM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DFMBox() : GWizForePanel
      {
         return this._2013789632DFMBox;
      }
      
      public function set DFMBox(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._2013789632DFMBox;
         if(_loc2_ !== param1)
         {
            this._2013789632DFMBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DFMBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EstInput() : GWizCCWEstimatorInput
      {
         return this._1924643324EstInput;
      }
      
      public function set EstInput(param1:GWizCCWEstimatorInput) : void
      {
         var _loc2_:Object = this._1924643324EstInput;
         if(_loc2_ !== param1)
         {
            this._1924643324EstInput = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EstInput",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FeedsBox() : GWizCCWResultsGrid
      {
         return this._126380266FeedsBox;
      }
      
      public function set FeedsBox(param1:GWizCCWResultsGrid) : void
      {
         var _loc2_:Object = this._126380266FeedsBox;
         if(_loc2_ !== param1)
         {
            this._126380266FeedsBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FeedsBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get InputsBox() : HGroup
      {
         return this._583151870InputsBox;
      }
      
      public function set InputsBox(param1:HGroup) : void
      {
         var _loc2_:Object = this._583151870InputsBox;
         if(_loc2_ !== param1)
         {
            this._583151870InputsBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"InputsBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get OptionsBox() : HGroup
      {
         return this._927043987OptionsBox;
      }
      
      public function set OptionsBox(param1:HGroup) : void
      {
         var _loc2_:Object = this._927043987OptionsBox;
         if(_loc2_ !== param1)
         {
            this._927043987OptionsBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"OptionsBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TimeFactor() : GWizNumStepOvr
      {
         return this._1898379620TimeFactor;
      }
      
      public function set TimeFactor(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1898379620TimeFactor;
         if(_loc2_ !== param1)
         {
            this._1898379620TimeFactor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TimeFactor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TimesBox() : GWizForePanel
      {
         return this._2011835195TimesBox;
      }
      
      public function set TimesBox(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._2011835195TimesBox;
         if(_loc2_ !== param1)
         {
            this._2011835195TimesBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TimesBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TimesRow() : VGroup
      {
         return this._2011819820TimesRow;
      }
      
      public function set TimesRow(param1:VGroup) : void
      {
         var _loc2_:Object = this._2011819820TimesRow;
         if(_loc2_ !== param1)
         {
            this._2011819820TimesRow = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TimesRow",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TortHare() : GWizCCWTortHare
      {
         return this._826032983TortHare;
      }
      
      public function set TortHare(param1:GWizCCWTortHare) : void
      {
         var _loc2_:Object = this._826032983TortHare;
         if(_loc2_ !== param1)
         {
            this._826032983TortHare = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TortHare",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get estTime() : Label
      {
         return this._1449321101estTime;
      }
      
      public function set estTime(param1:Label) : void
      {
         var _loc2_:Object = this._1449321101estTime;
         if(_loc2_ !== param1)
         {
            this._1449321101estTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"estTime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get opTime() : Label
      {
         return this._1011090354opTime;
      }
      
      public function set opTime(param1:Label) : void
      {
         var _loc2_:Object = this._1011090354opTime;
         if(_loc2_ !== param1)
         {
            this._1011090354opTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"opTime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get opTimeLabel() : Label
      {
         return this._405269690opTimeLabel;
      }
      
      public function set opTimeLabel(param1:Label) : void
      {
         var _loc2_:Object = this._405269690opTimeLabel;
         if(_loc2_ !== param1)
         {
            this._405269690opTimeLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"opTimeLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theLabelWidth() : int
      {
         return this._97483395theLabelWidth;
      }
      
      public function set theLabelWidth(param1:int) : void
      {
         var _loc2_:Object = this._97483395theLabelWidth;
         if(_loc2_ !== param1)
         {
            this._97483395theLabelWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theLabelWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get results() : SequencedArrayCollection
      {
         return this._1097546742results;
      }
      
      public function set results(param1:SequencedArrayCollection) : void
      {
         var _loc2_:Object = this._1097546742results;
         if(_loc2_ !== param1)
         {
            this._1097546742results = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"results",_loc2_,param1));
            }
         }
      }
   }
}
