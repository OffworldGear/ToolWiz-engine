package threads2
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizNumStepOvr;
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.containers.Accordion;
   import mx.containers.ViewStack;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.CloseEvent;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GWizTabBarSkin;
   import spark.components.BorderContainer;
   import spark.components.Button;
   import spark.components.DropDownList;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.NavigatorContent;
   import spark.components.NumericStepper;
   import spark.components.RadioButtonGroup;
   import spark.components.TabBar;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import spark.layouts.VerticalLayout;
   import tools.GWizDrillPicker;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizThreadReference2 extends Group implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizThreadReference2");
      
      public static var taperThreadEngine:GWizAbstractTaperThreadEngine;
      
      public static var straightThreadEngine:GWizAbstractThreadEngine;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _951875779ClassChooser:DropDownList;
      
      private var _757061803ClassNav:ViewStack;
      
      private var _976222655DiaMean:Label;
      
      private var _981393828EDiaMean:Label;
      
      private var _65915230EFlat:Label;
      
      private var _2043372180EFlat2:Label;
      
      private var _1028950580EHeight:Label;
      
      private var _285068338EHeightF2F:Label;
      
      private var _73687192EMajorDia:Label;
      
      private var _1449075732EMinorDia:Label;
      
      private var _2052535803EPitch:Label;
      
      private var _355217279EPitchDia:Label;
      
      private var _2138856ETPI:Label;
      
      private var _232825685EThreadAng:Label;
      
      private var _336720ExtThreadImage:Image;
      
      private var _1756117013External:NavigatorContent;
      
      private var _2096973700Family:DropDownList;
      
      private var _2192281Flat:Label;
      
      private var _2137162425Height:Label;
      
      private var _389461619HeightF2F:Label;
      
      private var _1605888001ISOClasses:NavigatorContent;
      
      private var _585669756ISOThreads:NavigatorContent;
      
      private var _911458850IntThreadImage:Image;
      
      private var _635054813Internal:NavigatorContent;
      
      private var _1962478655MOWData:GWizMOWData;
      
      private var _86619171MajorDia:Label;
      
      private var _1339260566ManualLathe:GWizManualLatheThread;
      
      private var _1288769369MinorDia:Label;
      
      private var _508079923NomSize:GWizNumStepOvr;
      
      private var _1323744904PTFamily:DropDownList;
      
      private var _1291631177PTNomSize:Label;
      
      private var _1924482011PTSize:DropDownList;
      
      private var _76467401PTTPI:Label;
      
      private var _1495805445PipeThreads:NavigatorContent;
      
      private var _77124384Pitch:Label;
      
      private var _194910916PitchDia:Label;
      
      private var _1650622255ReportNav:NavigatorContent;
      
      private var _370317597ReportNav2:NavigatorContent;
      
      private var _2577441Size:DropDownList;
      
      private var _83277TPI:Label;
      
      private var _1797539474TabNav:ViewStack;
      
      private var _466891520TapDepth:Label;
      
      private var _466511208TapDrill:Label;
      
      private var _1190938138TappingDrill:GWizTappingDrill;
      
      private var _441704272ThreadAng:Label;
      
      private var _96668307ThreadStartGrp:HGroup;
      
      private var _447027429ThreadStarts:NumericStepper;
      
      private var _2003720013UNClasses:NavigatorContent;
      
      public var _GWizThreadReference2_BorderContainer1:BorderContainer;
      
      public var _GWizThreadReference2_BorderContainer2:BorderContainer;
      
      public var _GWizThreadReference2_ClassFactory1:ClassFactory;
      
      public var _GWizThreadReference2_GWizForePanel2:GWizForePanel;
      
      public var _GWizThreadReference2_Label29:Label;
      
      public var _GWizThreadReference2_Label3:Label;
      
      public var _GWizThreadReference2_Label30:Label;
      
      public var _GWizThreadReference2_Label31:Label;
      
      public var _GWizThreadReference2_Label32:Label;
      
      public var _GWizThreadReference2_Label4:Label;
      
      public var _GWizThreadReference2_Label40:Label;
      
      public var _GWizThreadReference2_Label60:Label;
      
      public var _GWizThreadReference2_Label61:Label;
      
      public var _GWizThreadReference2_Label62:Label;
      
      public var _GWizThreadReference2_Label63:Label;
      
      private var _1830107832accordion:ViewStack;
      
      private var _1192212420classDigit1:NumericStepper;
      
      private var _1192212419classDigit2:NumericStepper;
      
      private var _1127905818custTPI:GWizNumStepOvr;
      
      private var _130763615designationTitle:Label;
      
      private var _826379834intExtTitle:Label;
      
      private var _1053536456isoLetters:DropDownList;
      
      private var _3313731lab0:Label;
      
      private var _102725803lab2P:Label;
      
      private var _102726360labE0:Label;
      
      private var _102726361labE1:Label;
      
      private var _102726362labE2:Label;
      
      private var _102726363labE3:Label;
      
      private var _102726365labE5:Label;
      
      private var _64125274labFlat:Label;
      
      private var _904486110labFlatMax:Label;
      
      private var _1443823340labHeight:Label;
      
      private var _102726578labL1:Label;
      
      private var _102726579labL2:Label;
      
      private var _102726580labL3:Label;
      
      private var _102726581labL4:Label;
      
      private var _102726582labL5:Label;
      
      private var _1117098401labPipeDia:Label;
      
      private var _1978719821labPitch:Label;
      
      private var _1110434656labTPI:Label;
      
      private var _1975267837labTaper:Label;
      
      private var _1332586867manualLatheNav:NavigatorContent;
      
      private var _164873550radiogroup2:RadioButtonGroup;
      
      private var _984627147reportSaveBtn:Button;
      
      private var _458670535reportSaveBtn2:Button;
      
      private var _3552126tabs:TabBar;
      
      private var _258707946taperThreadDataGrid:GWizThreadDataGrid;
      
      private var _1222635607taperThreadImg:Image;
      
      private var _135791448taperTitle:Label;
      
      private var _46421381tcBanner:GWizThreadCalcBanner;
      
      private var _1439062761tcBanner2:GWizThreadCalcBanner;
      
      private var _1377227322threadDataGrid:GWizThreadDataGrid;
      
      private var _2052278853toolDiameter:GWizNumStep;
      
      private var _1862063139viewAccordion:Accordion;
      
      private var _1889382511viewAccordion2:Accordion;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private const UNISO_INDEX:int = 0;
      
      private const PIPE_INDEX:int = 1;
      
      private const X_SCALE:Number = 1.2;
      
      private const Y_SCALE:Number = 1.2;
      
      private var _991549730showPipeThreads:Boolean = true;
      
      private var StdThreads:ArrayCollection = null;
      
      private var UNISOEngine:GWizAbstractThreadEngine;
      
      private var WitworthThreadEngine:GWizWhitworthThreadEngine;
      
      private var ACMEEngine:GWizAbstractThreadEngine;
      
      private var _1037611838StdThreadCt:int = 0;
      
      private var TaperThreads:ArrayCollection = null;
      
      private var NPTEngine:GWizAbstractTaperThreadEngine;
      
      private var NPTFEngine:GWizAbstractTaperThreadEngine;
      
      private var BSPTEngine:GWizBSPTThreadEngine;
      
      private var _343879595TaperThreadCt:int = 0;
      
      private var lastTabNavSelection:int = -1;
      
      private var _1502999998FamilyList:ArrayCollection;
      
      private var BasicFamilyList:ArrayCollection;
      
      private var PremiumFamilyList:ArrayCollection;
      
      private var filterFamItem:String;
      
      private var _911376479SizeList:ArrayCollection;
      
      private var _FamilyVal:String = "UNF";
      
      private var SizeVal:String = "0-80";
      
      private var _811554151TypeVal:String = "Internal";
      
      private var inRecalc:Boolean = false;
      
      private var _1238837686tpiToolTip:String = "";
      
      private var ptTapDrillSize:Number = 0;
      
      private var savedIndex:int = 99999;
      
      private var _696306834DRAWING_TEXT_COLOR:uint = 16777215;
      
      private var _795181983threadReference:String = "None";
      
      private var _153636605nominalSize:Number = 0.0;
      
      private var _1611544636customTPI:Number = 0.0;
      
      private var _900931593designation:String = "";
      
      private var _1225950992intExtTitleBinder:String = "";
      
      private var _301688624bestSizeMOW:Number;
      
      private var _1456492706minSizeMOW:Number;
      
      private var _1015506608maxSizeMOW:Number;
      
      private var isoExtThreadLetters:ArrayCollection;
      
      private var isoIntThreadLetters:ArrayCollection;
      
      private var eltsAdded:Boolean = true;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizThreadReference2()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.UNISOEngine = new GWizUNISOThreadEngine();
         this.WitworthThreadEngine = new GWizWhitworthThreadEngine();
         this.ACMEEngine = new GWizACMEThreadEngine();
         this.NPTEngine = new GWizAbstractTaperThreadEngine();
         this.NPTFEngine = new GWizNPTFThreadEngine();
         this.BSPTEngine = new GWizBSPTThreadEngine();
         this._1502999998FamilyList = new ArrayCollection();
         this.BasicFamilyList = new ArrayCollection();
         this.PremiumFamilyList = new ArrayCollection();
         this._911376479SizeList = new ArrayCollection();
         this.isoExtThreadLetters = new ArrayCollection([{"label":"e"},{"label":"f"},{"label":"g"},{"label":"h"}]);
         this.isoIntThreadLetters = new ArrayCollection([{"label":"G"},{"label":"H"}]);
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizThreadReference2_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_threads2_GWizThreadReference2WatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizThreadReference2[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizThreadReference2_ViewStack1_i(),this._GWizThreadReference2_TabBar1_i()];
         this._GWizThreadReference2_ClassFactory1_i();
         this._GWizThreadReference2_RadioButtonGroup1_i();
         this.addEventListener("creationComplete",this.___GWizThreadReference2_Group1_creationComplete);
         this.addEventListener("show",this.___GWizThreadReference2_Group1_show);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizThreadReference2._watcherSetupUtil = param1;
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
      
      public function setTypes(param1:Boolean, param2:Boolean) : void
      {
         this.showPipeThreads = param2;
         if(!param2)
         {
            this.TabNav.removeChild(this.PipeThreads);
         }
      }
      
      public function minDia() : Number
      {
         var _loc1_:Number = 0;
         var _loc2_:Object = this.getSelectedEntry();
         if(_loc2_)
         {
            _loc1_ = (Number(_loc2_.MaxMinorDia) + Number(_loc2_.MinMinorDia)) / 2;
         }
         return this.getThreadInfoAux("Max Minor Dia","Min Minor Dia");
      }
      
      public function majDia() : Number
      {
         return this.getThreadInfoAux("Max Major Dia","Min Major Dia");
      }
      
      public function pitch() : Number
      {
         return this.getThreadInfoAux("Pitch","");
      }
      
      private function getThreadInfoAux(param1:String, param2:String) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(GWizAbstractThreadEngine.threadInfo(param1) != "N/A")
         {
            _loc4_ = Number(GWizAbstractThreadEngine.threadInfo(param1));
         }
         if(GWizAbstractThreadEngine.threadInfo(param2) != "N/A")
         {
            _loc5_ = Number(GWizAbstractThreadEngine.threadInfo(param2));
         }
         if(param2 != "")
         {
            _loc3_ = (_loc4_ + _loc5_) / 2;
         }
         else
         {
            _loc3_ = _loc4_;
         }
         if(GWizUtils.debug && isNaN(_loc3_))
         {
            log.debug("gotcha");
         }
         return _loc3_;
      }
      
      private function checkUnits(param1:Object = null) : Boolean
      {
         this.recalc();
         this.Flat.setStyle("color",16777215);
         return true;
      }
      
      private function init(param1:Boolean = false) : void
      {
         if(!param1)
         {
            if(straightThreadEngine && this.TabNav.selectedIndex == this.lastTabNavSelection)
            {
               return;
            }
         }
         straightThreadEngine = this.UNISOEngine;
         this.StdThreads = GWizAbstractThreadEngine.PreferredThreads;
         this.StdThreadCt = this.StdThreads.length;
         taperThreadEngine = this.NPTEngine;
         this.TaperThreads = GWizAbstractTaperThreadEngine.PreferredThreads;
         this.TaperThreadCt = this.TaperThreads.length;
         this.initFamilyList();
         this.custTPI.theLabel.setStyle("fontWeight","bold");
         GWizNumStep.checkUnitsCC.addFunction("GWizThreadReference2",this.checkUnits,false);
         this.checkUnits();
         this.lastTabNavSelection = this.TabNav.selectedIndex;
         if(!param1)
         {
            this.basicPremiumChange = GWizAbstractPrefs.ThreadCalcEnabled;
         }
         if(this.tcBanner2)
         {
            this.tcBanner2.intExtType.visible = false;
            this.tcBanner2.CADCAMBtn.visible = false;
         }
      }
      
      private function filterFamilyList(param1:Object) : Boolean
      {
         return param1 == this.filterFamItem;
      }
      
      private function initFamilyList() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         var _loc1_:Function = this.StdThreads.filterFunction;
         this.StdThreads.filterFunction = null;
         this.StdThreads.refresh();
         if(this.TabNav == null || this.StdThreads.length <= 0)
         {
            this.callLater(this.initFamilyList);
            this.StdThreads.filterFunction = _loc1_;
            return;
         }
         this.FamilyList.removeAll();
         if(this.TabNav.selectedIndex == this.UNISO_INDEX)
         {
            _loc2_ = 0;
            while(_loc2_ < this.StdThreads.length)
            {
               this.filterFamItem = this.StdThreads[_loc2_].Family;
               _loc3_ = GWizAbstractThreadEngine.PremiumThreadFamily[this.filterFamItem];
               this.FamilyList.filterFunction = this.filterFamilyList;
               this.FamilyList.refresh();
               if(this.FamilyList.length == 0)
               {
                  if(!_loc3_ || GWizAbstractPrefs.ThreadCalcEnabled)
                  {
                     this.FamilyList.addItem(this.filterFamItem);
                  }
               }
               _loc2_++;
            }
         }
         else if(this.TabNav.selectedIndex == this.PIPE_INDEX)
         {
            _loc2_ = 0;
            while(_loc2_ < this.TaperThreads.length)
            {
               this.filterFamItem = this.TaperThreads[_loc2_].Family;
               _loc3_ = GWizAbstractThreadEngine.PremiumThreadFamily[this.filterFamItem];
               this.FamilyList.filterFunction = this.filterFamilyList;
               this.FamilyList.refresh();
               if(this.FamilyList.length == 0)
               {
                  if(!_loc3_ || GWizAbstractPrefs.ThreadCalcEnabled)
                  {
                     this.FamilyList.addItem(this.filterFamItem);
                  }
               }
               _loc2_++;
            }
         }
         else
         {
            GWizUtils.assert(false);
         }
         this.FamilyList.filterFunction = null;
         this.FamilyList.refresh();
         this.FamilyVal = String(this.FamilyList.getItemAt(0));
         this.Family.selectedIndex = 0;
         if(this.PTFamily)
         {
            this.PTFamily.selectedIndex = 0;
         }
         this.initSizeList();
         this.initClassList();
         this.recalc();
      }
      
      private function initSizeList() : void
      {
         var _loc1_:ArrayCollection = null;
         if(this.TabNav == null || this.TabNav.selectedIndex == this.UNISO_INDEX)
         {
            _loc1_ = this.StdThreads;
         }
         else if(this.TabNav.selectedIndex == this.PIPE_INDEX)
         {
            _loc1_ = this.TaperThreads;
         }
         else
         {
            GWizUtils.assert(false);
         }
         _loc1_.filterFunction = null;
         _loc1_.refresh();
         this.SizeList.removeAll();
         var _loc2_:Boolean = this.TabNav != null && this.TabNav.selectedIndex == this.PIPE_INDEX;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.length)
         {
            if(_loc1_[_loc3_].Family == this.FamilyVal)
            {
               this.filterFamItem = _loc1_[_loc3_].Size;
               this.SizeList.filterFunction = this.filterFamilyList;
               this.SizeList.refresh();
               if(this.SizeList.length == 0)
               {
                  this.SizeList.addItem(this.filterFamItem);
               }
            }
            _loc3_++;
         }
         this.SizeList.filterFunction = null;
         this.SizeList.refresh();
         this.SizeVal = String(this.SizeList.getItemAt(0));
         if(this.PTSize != null)
         {
            this.PTSize.selectedIndex = 0;
         }
         if(this.Size != null)
         {
            this.Size.selectedIndex = 0;
         }
         if(GWizUtils.debug)
         {
            log.debug(this.SizeList.length + " preferred thread sizes in family.");
         }
      }
      
      private function initClassList() : void
      {
         if(this.TabNav != null && this.TabNav.selectedIndex == this.PIPE_INDEX)
         {
            return;
         }
         if(true || GWizAbstractThreadEngine.showTolClass)
         {
            straightThreadEngine.initClassList(this.TypeVal == "External");
         }
         this.ClassChooser.selectedIndex = GWizAbstractThreadEngine.DefaultClassChoice;
         var _loc1_:int = 0;
         var _loc2_:int = 1;
         if(this.ClassNav.selectedIndex == _loc1_)
         {
            if(this.FamilyVal.indexOf("ISO") >= 0)
            {
               this.ClassNav.selectedIndex = _loc2_;
               if(this.TypeVal == "Internal")
               {
                  this.classDigit1.minimum = 4;
                  this.classDigit1.maximum = 8;
                  this.classDigit1.stepSize = 1;
                  this.classDigit2.minimum = 4;
                  this.classDigit2.maximum = 8;
                  this.classDigit2.stepSize = 1;
                  this.classDigit1.value = 6;
                  this.classDigit2.value = 6;
               }
               else
               {
                  this.classDigit1.minimum = 4;
                  this.classDigit1.maximum = 8;
                  this.classDigit1.stepSize = 1;
                  this.classDigit2.minimum = 4;
                  this.classDigit2.maximum = 8;
                  this.classDigit2.stepSize = 2;
                  this.classDigit1.value = 6;
                  this.classDigit2.value = 6;
               }
               if(this.FamilyVal == GWizACMEThreadEngine.ISO_METRIC_TRAPEZOIDAL)
               {
                  this.classDigit1.minimum = 7;
                  this.classDigit1.maximum = 9;
                  this.classDigit2.minimum = 4;
                  this.classDigit2.maximum = 4;
                  this.classDigit1.value = 7;
                  this.classDigit2.value = 4;
               }
            }
         }
         else if(this.FamilyVal.indexOf("ISO") < 0)
         {
            this.ClassNav.selectedIndex = _loc1_;
         }
         if(this.FamilyVal.indexOf("ISO") >= 0)
         {
            if(this.TypeVal == "Internal")
            {
               this.classDigit2.stepSize = 1;
               this.isoLetters.dataProvider = this.isoIntThreadLetters;
               if(!this.isoLetters.selectedItem)
               {
                  this.isoLetters.selectedIndex = 1;
               }
            }
            else
            {
               this.classDigit2.stepSize = 2;
               this.isoLetters.dataProvider = this.isoExtThreadLetters;
               if(!this.isoLetters.selectedItem)
               {
                  this.isoLetters.selectedIndex = 2;
               }
            }
            if(this.FamilyVal == GWizACMEThreadEngine.ISO_METRIC_TRAPEZOIDAL)
            {
               this.classDigit2.stepSize = 1;
               if(this.TypeVal == "Internal")
               {
                  this.isoLetters.dataProvider = GWizACMEThreadEngine.isoMetricTrapIntClasses;
               }
               else
               {
                  this.isoLetters.dataProvider = GWizACMEThreadEngine.isoMetricTrapExtClasses;
               }
            }
         }
      }
      
      private function setFamily() : void
      {
         var _loc2_:Boolean = false;
         if(this.TabNav == null || this.TabNav.selectedIndex == this.UNISO_INDEX)
         {
            this.FamilyVal = this.Family.selectedItem;
         }
         else if(this.TabNav.selectedIndex == this.PIPE_INDEX)
         {
            this.FamilyVal = this.PTFamily.selectedItem;
         }
         else
         {
            GWizUtils.assert(false);
         }
         var _loc1_:Boolean = false;
         if(!GWizAbstractPrefs.ThreadCalcEnabled)
         {
            if(this.TabNav == null || this.TabNav.selectedIndex == this.UNISO_INDEX)
            {
               _loc2_ = GWizAbstractThreadEngine.isPremiumFamily(this.FamilyVal);
            }
            else if(this.TabNav.selectedIndex == this.PIPE_INDEX)
            {
               _loc2_ = GWizAbstractTaperThreadEngine.isPremiumFamily(this.FamilyVal);
            }
            if(_loc2_)
            {
               log.debug("Premium thread + !ThreadCalc");
               GATracker.logPageView("PremiumThread","PremiumThread");
               GWizPopUpManager.Show("Premium thread requires Thread Calculator. Learn more?","Thread Calculator",GWizPopUpManager.YES,null,this.learnMoreListener);
               if(this.TabNav == null || this.TabNav.selectedIndex == this.UNISO_INDEX)
               {
                  this.Family.selectedIndex = 0;
                  this.FamilyVal = this.Family.selectedItem;
                  _loc1_ = true;
               }
               else if(this.TabNav.selectedIndex == this.PIPE_INDEX)
               {
                  this.PTFamily.selectedIndex = 0;
                  this.FamilyVal = this.PTFamily.selectedItem;
                  _loc1_ = true;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
         }
         if(this.TabNav == null || this.TabNav.selectedIndex == this.UNISO_INDEX)
         {
            GWizAbstractThreadEngine.Family = this.FamilyVal;
         }
         else if(this.TabNav.selectedIndex == this.PIPE_INDEX)
         {
            GWizAbstractTaperThreadEngine.Family = this.FamilyVal;
         }
         if(!_loc1_)
         {
            this.initSizeList();
            this.initClassList();
            this.recalc();
         }
         else if(this.TabNav == null || this.TabNav.selectedIndex == this.UNISO_INDEX)
         {
            this.Family.validateNow();
         }
         else if(this.TabNav.selectedIndex == this.PIPE_INDEX)
         {
            this.PTFamily.validateNow();
         }
      }
      
      private function learnMoreListener(param1:CloseEvent) : void
      {
         if(param1.detail == GWizPopUpManager.YES)
         {
            GWizUtils.doWebPage("https://www.cnccookbook.com/g-wizard-thread-calculator-awesome-software-free-advanced/");
         }
      }
      
      private function setSize() : void
      {
         if(this.TabNav == null || this.TabNav.selectedIndex == this.UNISO_INDEX)
         {
            this.SizeVal = this.Size.selectedItem;
         }
         else if(this.TabNav.selectedIndex == this.PIPE_INDEX)
         {
            this.SizeVal = this.PTSize.selectedItem;
         }
         else
         {
            GWizUtils.assert(false);
         }
         this.recalc();
      }
      
      private function setClass() : void
      {
         this.recalc();
      }
      
      private function setCuttingForm() : void
      {
         this.recalc();
      }
      
      private function setType() : void
      {
         this.TypeVal = this.accordion.selectedChild.label;
         this.initClassList();
         var _loc1_:int = this.Size.selectedIndex;
         this.initSizeList();
         this.Size.selectedIndex = _loc1_;
         this.setSize();
         this.setAuxPaneViz();
      }
      
      private function set FamilyVal(param1:String) : void
      {
         this._FamilyVal = param1;
         this.chooseThreadEngine();
      }
      
      private function get FamilyVal() : String
      {
         return this._FamilyVal;
      }
      
      private function chooseThreadEngine() : void
      {
         switch(this.FamilyVal)
         {
            case "BSW":
            case "BSPP":
            case "BA":
               straightThreadEngine = this.WitworthThreadEngine;
               break;
            case "ACME 29°":
            case GWizACMEThreadEngine.ISO_METRIC_TRAPEZOIDAL:
               straightThreadEngine = this.ACMEEngine;
               break;
            default:
               straightThreadEngine = this.UNISOEngine;
         }
      }
      
      private function get ClassVal() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = "";
         if(this.ClassNav.selectedIndex == 0)
         {
            _loc1_ = this.ClassChooser.selectedItem.Class;
         }
         else
         {
            if(!this.isoLetters.selectedItem)
            {
               this.isoLetters.selectedIndex = 0;
               _loc2_ = this.isoLetters.dataProvider.getItemAt(0).Class;
            }
            else
            {
               _loc2_ = this.isoLetters.selectedItem.label;
            }
            _loc1_ = String(this.classDigit1.value) + String(this.classDigit2.value) + _loc2_;
         }
         return _loc1_;
      }
      
      private function filterUNISOList(param1:Object) : Boolean
      {
         var _loc2_:Boolean = true;
         if(this.FamilyVal.length > 0)
         {
            _loc2_ = _loc2_ && param1.Family == this.FamilyVal;
         }
         if(this.SizeVal.length > 0)
         {
            _loc2_ = _loc2_ && param1.Size == this.SizeVal;
         }
         return _loc2_;
      }
      
      private function filterPipeList(param1:Object) : Boolean
      {
         var _loc2_:Boolean = true;
         if(this.FamilyVal.length > 0)
         {
            _loc2_ = _loc2_ && param1.Family == this.FamilyVal;
         }
         if(this.SizeVal.length > 0)
         {
            _loc2_ = _loc2_ && param1.Size == this.SizeVal;
         }
         return _loc2_;
      }
      
      private function recalc() : void
      {
         this.invalidateProperties();
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         this.recalcAux();
      }
      
      private function recalcAux() : void
      {
         if(this.inRecalc)
         {
            return;
         }
         this.inRecalc = true;
         if(this.TabNav == null || this.TabNav.selectedIndex == this.UNISO_INDEX)
         {
            this.recalcUNISO();
         }
         else if(this.TabNav.selectedIndex == this.PIPE_INDEX)
         {
            this.recalcPipeThreads();
         }
         else
         {
            GWizUtils.assert(false);
         }
         this.inRecalc = false;
      }
      
      private function recalcUNISO() : void
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         var _loc1_:Boolean = true;
         if(!this.Pitch || !this.StdThreads)
         {
            return;
         }
         if(this.TabNav != null && this.TabNav.selectedIndex == this.PIPE_INDEX)
         {
            return;
         }
         this.StdThreads.filterFunction = this.filterUNISOList;
         this.StdThreads.refresh();
         if(this.StdThreads.length > 0)
         {
            this.setStraightThread();
            this.Pitch.text = GWizAbstractThreadEngine.threadInfo("Pitch",true);
            this.EPitch.text = this.Pitch.text;
            this.ThreadAng.text = GWizAbstractThreadEngine.ThreadAngle + "°";
            this.EThreadAng.text = this.ThreadAng.text;
            if(GWizAbstractThreadEngine.TPISelect)
            {
               _loc2_ = "TPI";
               this.tpiToolTip = "TPI = Threads per inch.  A padlock shows you\'ve overridden the value from the Size dropdown";
               this.custTPI.usesMetric = false;
               this.custTPI.UnitLabel = "";
            }
            else
            {
               _loc2_ = "Pitch";
               this.tpiToolTip = "Change pitch for custom thread sizes.  A padlock shows you\'ve overridden the value from the Size dropdown";
               this.custTPI.usesMetric = true;
               this.custTPI.UnitLabel = "in";
            }
            this.custTPI.titleTxt = _loc2_;
            _loc2_ = " TPI";
            this.TPI.text = GWizAbstractThreadEngine.threadInfo("TPI") + _loc2_;
            this.ETPI.text = this.TPI.text;
            this.MinorDia.text = "Minor Dia. " + GWizAbstractThreadEngine.threadInfo("Min Minor Dia") + "-" + GWizAbstractThreadEngine.threadInfo("Max Minor Dia");
            this.EMinorDia.text = this.MinorDia.text;
            _loc3_ = Number(GWizUtils.roundTenths(GWizAbstractThreadEngine.MinMajorDia,_loc1_));
            this.MajorDia.text = "Major Dia. " + GWizAbstractThreadEngine.threadInfo("Min Major Dia") + "-" + GWizAbstractThreadEngine.threadInfo("Max Major Dia");
            this.EMajorDia.text = this.MajorDia.text;
            this.PitchDia.text = "Pitch Dia. " + GWizAbstractThreadEngine.threadInfo("Min Pitch Dia") + "-" + GWizAbstractThreadEngine.threadInfo("Max Pitch Dia");
            this.EPitchDia.text = this.PitchDia.text;
            this.DiaMean.text = "Mean " + GWizAbstractThreadEngine.threadInfo("Mean Minor Dia");
            this.EDiaMean.text = "Mean " + GWizAbstractThreadEngine.threadInfo("Mean Major Dia");
            this.Height.text = GWizAbstractThreadEngine.threadInfo("Sharp-V Height",true);
            this.HeightF2F.text = "Flats Ht " + GWizAbstractThreadEngine.threadInfo("Flats Height");
            this.EHeight.text = this.Height.text;
            this.EHeightF2F.text = this.HeightF2F.text;
            this.Flat.text = GWizAbstractThreadEngine.threadInfo("Flat",true);
            this.EFlat.text = this.Flat.text;
            this.MOWData.bestMOW.value = GWizAbstractThreadEngine.BestSizeMOW;
            this.MOWData.minMOW.value = GWizAbstractThreadEngine.MinSizeMOW;
            this.MOWData.maxMOW.value = GWizAbstractThreadEngine.MaxSizeMOW;
         }
         if(!isNaN(GWizAbstractThreadEngine.MinMajorDia))
         {
            this.recalcTapInfo(GWizAbstractThreadEngine.MinMajorDia,GWizAbstractThreadEngine.TPI);
         }
         else
         {
            this.recalcTapInfo(GWizAbstractThreadEngine.MaxMajorDia,GWizAbstractThreadEngine.TPI);
         }
      }
      
      private function getSelectedEntry() : Object
      {
         var _loc1_:Object = null;
         this.StdThreads.filterFunction = this.filterUNISOList;
         this.StdThreads.refresh();
         if(this.StdThreads.length > 0)
         {
            _loc1_ = this.StdThreads.getItemAt(0);
         }
         this.StdThreads.filterFunction = null;
         this.StdThreads.refresh();
         return _loc1_;
      }
      
      private function recalcPipeThreads() : void
      {
         var _loc1_:Boolean = true;
         if(this.Pitch == null || !this.PTFamily.selectedItem || !this.PTSize.selectedItem)
         {
            return;
         }
         GWizUtils.assert(this.NPTEngine != null);
         var _loc2_:String = this.PTFamily.selectedItem;
         var _loc3_:String = this.PTSize.selectedItem;
         taperThreadEngine = this.NPTEngine;
         if(_loc2_ == "NPTF")
         {
            taperThreadEngine = this.NPTFEngine;
         }
         else if(_loc2_ == "BSPT")
         {
            taperThreadEngine = this.BSPTEngine;
         }
         var _loc4_:Boolean = taperThreadEngine.selectThread(_loc2_,_loc3_);
         if(this.taperThreadDataGrid)
         {
            this.taperThreadDataGrid.refresh();
         }
         this.taperThreadImg.source = GWizAbstractTaperThreadEngine.TaperThreadImg;
         this.designation = GWizAbstractTaperThreadEngine.Designation;
         this.threadReference = GWizAbstractTaperThreadEngine.Reference;
         this.threadReference += " (Beta Test: Check Values Carefully!)";
         if(_loc4_)
         {
            this.PTNomSize.text = GWizAbstractTaperThreadEngine.threadInfo("Pipe Dia.",true);
            if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
            {
               this.PTTPI.text = "Pitch " + GWizAbstractTaperThreadEngine.threadInfo("TPI");
            }
            else
            {
               this.PTTPI.text = GWizAbstractTaperThreadEngine.threadInfo("TPI",true);
            }
            this.labPipeDia.text = "Pipe Dia. " + GWizAbstractTaperThreadEngine.threadInfo("Pipe Dia.");
            this.labPitch.text = GWizAbstractTaperThreadEngine.threadInfo("Pitch",true);
            this.labTPI.text = GWizAbstractTaperThreadEngine.threadInfo("TPI",true);
            this.lab2P.text = GWizUtils.sroundTenths(String(2 * GWizAbstractTaperThreadEngine.Pitch));
            this.labHeight.text = GWizAbstractTaperThreadEngine.threadInfo("Height",true);
            this.labFlat.text = GWizAbstractTaperThreadEngine.threadInfo("Min Flat at Crest",true);
            this.labFlatMax.text = GWizAbstractTaperThreadEngine.threadInfo("Max Flat at Crest",true);
            this.labL1.text = "Handtight (L1) " + GWizAbstractTaperThreadEngine.threadInfo(GWizAbstractTaperThreadEngine.L1_LABEL);
            this.labL2.text = "Eff. Len. (L2) " + GWizAbstractTaperThreadEngine.threadInfo(GWizAbstractTaperThreadEngine.L2_LABEL);
            this.labL3.text = "L3 " + GWizAbstractTaperThreadEngine.threadInfo(GWizAbstractTaperThreadEngine.L3_LABEL);
            this.labL4.text = "Overall Len. (L4) " + GWizAbstractTaperThreadEngine.threadInfo(GWizAbstractTaperThreadEngine.L4_LABEL);
            this.labL5.text = "Nom. Perf. (L5) " + GWizAbstractTaperThreadEngine.threadInfo(GWizAbstractTaperThreadEngine.L5_LABEL);
            this.labE0.text = "E0 Pitch Dia. " + GWizAbstractTaperThreadEngine.threadInfo("E0");
            this.labE1.text = "E1 Pitch Dia. " + GWizAbstractTaperThreadEngine.threadInfo("E1");
            this.labE2.text = "E2 Pitch Dia. " + GWizAbstractTaperThreadEngine.threadInfo("E2");
            this.labE3.text = "E3 Pitch Dia. " + GWizAbstractTaperThreadEngine.threadInfo("E3");
            this.labE5.text = "E5 Pitch Dia. " + GWizAbstractTaperThreadEngine.threadInfo("E5");
            this.labTaper.text = GWizAbstractTaperThreadEngine.threadInfo("Taper Angle");
            if(!isNaN(GWizAbstractTaperThreadEngine.TapDrill))
            {
               this.ptTapDrillSize = GWizAbstractTaperThreadEngine.TapDrill;
               this.TapDrill.text = "Tap Drill " + GWizUtils.sroundTenths(String(this.ptTapDrillSize));
            }
            else
            {
               this.TapDrill.text = "Tap Drill N/A";
            }
            this.TapDepth.text = GWizAbstractTaperThreadEngine.threadInfo("Tap Depth",true,true);
            if(this.taperThreadImg.source == GWizBSPTThreadEngine.BSPTThreadImg)
            {
               log.debug("gotcha");
               this.labFlat.text = GWizAbstractTaperThreadEngine.threadInfo("Crest Radius",true);
               this.labFlatMax.text = GWizAbstractTaperThreadEngine.threadInfo("Root Radius",true);
               this.labL2.text = GWizAbstractTaperThreadEngine.threadInfo("Gauge Length (external thread)",true);
               this.labL4.text = GWizAbstractTaperThreadEngine.threadInfo("Gauge Length (internal thread)",true);
               this.labE2.text = GWizAbstractTaperThreadEngine.threadInfo("Pitch Dia (external & internal at gauge plane)",true);
               this.labL1.visible = false;
               this.labL2.x -= 15;
               this.labL2.y -= 15;
               this.labL3.visible = false;
               this.labL4.x += 50;
               this.labL5.visible = false;
               this.labE0.visible = false;
               this.labE1.visible = false;
               this.labE2.x = 300;
               this.labE2.y = 408;
               this.labE3.visible = false;
               this.labE5.visible = false;
            }
         }
      }
      
      private function showDrillPicker() : void
      {
         var _loc1_:GWizDrillPicker = GWizDrillPicker(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizDrillPicker,true));
         if(_loc1_)
         {
            _loc1_.dc.setFilter(true,false,false);
            this.toolDiameter.setVal(this.ptTapDrillSize);
            _loc1_.diameter = this.toolDiameter;
            _loc1_.setDefault();
         }
      }
      
      private function onIntExtTypeClick(param1:IndexChangeEvent) : void
      {
         if(param1.newIndex != this.savedIndex)
         {
            this.savedIndex = param1.newIndex;
            this.accordion.selectedIndex = param1.newIndex;
            this.basicPremiumChange = GWizAbstractPrefs.ThreadCalcEnabled;
            this.initClassList();
         }
      }
      
      private function doCCW() : void
      {
         GWizSettings.minorDia = this.getThreadInfoAux("Min Minor Dia","Max Minor Dia");
         GWizSettings.majorDia = this.getThreadInfoAux("Min Major Dia","Max Major Dia");
         GWizSettings.threadPitch = this.getThreadInfoAux("Pitch","Pitch");
         GWizSettings.threadDepth = GWizAbstractThreadEngine.ThreadDepthExt;
         this.doCCWAux();
      }
      
      private function doCCWAux() : void
      {
         var _loc1_:Number = NaN;
         if(!GWizSettings.threadingCCW)
         {
            this.callLater(this.doCCWAux);
         }
         else
         {
            if(this.TypeVal == "Internal")
            {
               _loc1_ = GWizSettings.minorDia;
            }
            else
            {
               _loc1_ = GWizSettings.majorDia;
            }
            GWizSettings.threadingCCW.tInputs.stockDia.setVal(_loc1_);
            GWizSettings.threadingCCW.tInputs.threadPitch.setVal(GWizSettings.threadPitch);
            GWizSettings.threadingCCW.tInputs.threadDepth.setVal(GWizSettings.threadDepth);
         }
      }
      
      private function setStraightThread() : void
      {
         var _loc2_:String = null;
         var _loc1_:Object = this.StdThreads.getItemAt(0);
         if(_loc1_)
         {
            _loc2_ = _loc1_.Size;
            if(this.NomSize.isOverridden())
            {
               _loc2_ = "Custom";
               this.nominalSize = this.NomSize.value;
            }
            else
            {
               this.nominalSize = straightThreadEngine.nomDiaFromFamSize(_loc1_.Family,_loc1_.Size);
            }
            if(this.custTPI.isOverridden())
            {
               _loc2_ = "Custom";
               this.customTPI = this.custTPI.value;
            }
            else
            {
               this.customTPI = straightThreadEngine.lookupTPI(_loc1_.Family,_loc1_.Size);
            }
            straightThreadEngine.selectThread(_loc1_.Family,_loc2_,this.nominalSize,this.customTPI,this.ClassVal,this.ThreadStarts.value,this.TypeVal != "Internal");
            if(!GWizAbstractThreadEngine.hasExternalThreads)
            {
               this.tcBanner.intExtType.selectedIndex = 0;
               this.accordion.selectedIndex = 0;
            }
            if(this.threadDataGrid)
            {
               this.threadDataGrid.refresh();
            }
            if(this.ManualLathe)
            {
               this.ManualLathe.recalc();
            }
            this.intExtTitleBinder = "Internal Thread";
            if(this.TypeVal != "Internal")
            {
               this.intExtTitleBinder = "External Thread";
            }
            this.designation = GWizAbstractThreadEngine.Designation;
            this.threadReference = GWizAbstractThreadEngine.Reference;
            this.threadReference += " (Beta Test: Check Values Carefully!)";
            this.nominalSize = GWizAbstractThreadEngine.NomSize;
            if(GWizAbstractThreadEngine.TPISelect)
            {
               this.customTPI = GWizAbstractThreadEngine.TPI;
            }
            else
            {
               this.customTPI = GWizAbstractThreadEngine.Pitch;
            }
            this.bestSizeMOW = GWizAbstractThreadEngine.BestSizeMOW;
            this.minSizeMOW = GWizAbstractThreadEngine.MinSizeMOW;
            this.maxSizeMOW = GWizAbstractThreadEngine.MaxSizeMOW;
            this.MOWData.actualMOW.value = this.bestSizeMOW;
            this.MOWData.recalcMOWLimits(this.MOWData.actualMOW.value);
            this.MOWData.recalcMOWPitchDia(this.MOWData.actualMOW.value,this.MOWData.measurementMOW.value);
            this.custTPI.enabled = GWizAbstractThreadEngine.allowCustomSizeTPI && GWizAbstractPrefs.ThreadCalcEnabled;
            this.NomSize.enabled = GWizAbstractThreadEngine.allowCustomSizeTPI && GWizAbstractPrefs.ThreadCalcEnabled;
         }
      }
      
      private function recalcTapInfo(param1:Number, param2:Number) : void
      {
         if(this.TabNav != null && this.TabNav.selectedIndex == this.PIPE_INDEX)
         {
            return;
         }
         if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            this.TappingDrill.itDiaCol.dataField = "metric";
         }
         else
         {
            this.TappingDrill.itDiaCol.dataField = "inch";
         }
         straightThreadEngine.recalcTapInfo(param1,param2,this.TappingDrill.Cutting.selected,this.TypeVal == "Internal");
      }
      
      private function genThreadDB() : void
      {
         var _loc1_:Function = null;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:* = null;
         if(GWizUtils.debug && false)
         {
            _loc1_ = this.StdThreads.filterFunction;
            this.StdThreads.filterFunction = null;
            this.StdThreads.refresh();
            _loc2_ = 0;
            while(_loc2_ < this.StdThreads.length)
            {
               _loc3_ = this.StdThreads.getItemAt(_loc2_);
               _loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = "{ Family:\"" + _loc3_.Family + "\", ") + ("Size: \"" + _loc3_.Size + "\", ")) + ("Class: \"" + _loc3_.Class + "\", ")) + ("NominalSize: \"" + straightThreadEngine.nomDiaFromFamSize(_loc3_.Family,_loc3_.Size) + "\", ")) + ("TPI: \"" + 1 / Number(_loc3_.Pitch) + "\"}, ");
               log.debug(_loc4_);
               _loc2_++;
            }
            this.StdThreads.filterFunction = _loc1_;
            log.debug("***");
         }
      }
      
      private function threadStartsVC() : void
      {
         this.setAuxPaneViz();
         this.recalc();
      }
      
      private function setAuxPaneViz() : void
      {
         if(this.TypeVal == "Internal")
         {
            this.TappingDrill.enabled = true;
         }
         else
         {
            this.TappingDrill.enabled = false;
         }
         this.MOWData.enabled = !this.TappingDrill.enabled && this.ThreadStarts.value <= 1 && GWizAbstractPrefs.ThreadCalcEnabled;
      }
      
      private function set basicPremiumChange(param1:Boolean) : void
      {
         this.NomSize.enabled = GWizAbstractPrefs.ThreadCalcEnabled;
         this.custTPI.enabled = GWizAbstractThreadEngine.allowCustomSizeTPI && GWizAbstractPrefs.ThreadCalcEnabled;
         this.reportSaveBtn.enabled = GWizAbstractPrefs.ThreadCalcEnabled;
         this.reportSaveBtn2.enabled = GWizAbstractPrefs.ThreadCalcEnabled;
         if(GWizAbstractPrefs.ThreadCalcEnabled)
         {
            if(!this.eltsAdded)
            {
               this.viewAccordion.addElement(this.ReportNav);
               this.viewAccordion.addElement(this.manualLatheNav);
               this.viewAccordion2.addElement(this.ReportNav2);
               this.eltsAdded = true;
            }
         }
         else if(this.eltsAdded)
         {
            this.viewAccordion.removeElement(this.ReportNav);
            this.viewAccordion.removeElement(this.manualLatheNav);
            this.viewAccordion2.removeElement(this.ReportNav2);
            this.eltsAdded = false;
         }
         this.ManualLathe.enabled = GWizAbstractPrefs.ThreadCalcEnabled;
         this.ReportNav.enabled = GWizAbstractPrefs.ThreadCalcEnabled;
         this.init(true);
      }
      
      private function _GWizThreadReference2_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = BlindHoleClearancePopup;
         _loc1_.properties = {"outerDocument":this};
         this._GWizThreadReference2_ClassFactory1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_ClassFactory1",this._GWizThreadReference2_ClassFactory1);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"radiogroup2");
         this.radiogroup2 = _loc1_;
         BindingManager.executeBindings(this,"radiogroup2",this.radiogroup2);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.bottom = 0;
         temp.right = 0;
         temp.left = 0;
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.creationPolicy = "all";
         temp.addEventListener("change",this.__TabNav_change);
         temp.id = "TabNav";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"TabNav",
            "events":{"change":"__TabNav_change"},
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"ISOThreads",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Straight",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array2_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"PipeThreads",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Tapered",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array27_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.TabNav = temp;
         BindingManager.executeBindings(this,"TabNav",this.TabNav);
         return temp;
      }
      
      public function __TabNav_change(param1:IndexChangedEvent) : void
      {
         this.init();
      }
      
      private function _GWizThreadReference2_Array2_c() : Array
      {
         return [this._GWizThreadReference2_HGroup1_c()];
      }
      
      private function _GWizThreadReference2_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.gap = 1;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.mxmlContent = [this._GWizThreadReference2_VGroup1_c(),this._GWizThreadReference2_VGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizThreadReference2_GWizForePanel1_c(),this._GWizThreadReference2_GWizTappingDrill1_i(),this._GWizThreadReference2_GWizMOWData1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.layout = this._GWizThreadReference2_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array5_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 3;
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array5_c() : Array
      {
         return [this._GWizThreadReference2_Label1_c(),this._GWizThreadReference2_DropDownList1_i(),this._GWizThreadReference2_Label2_c(),this._GWizThreadReference2_DropDownList2_i(),this._GWizThreadReference2_Label3_i(),this._GWizThreadReference2_GWizNumStepOvr1_i(),this._GWizThreadReference2_GWizNumStepOvr2_i(),this._GWizThreadReference2_Label4_i(),this._GWizThreadReference2_GWizForePanel2_i(),this._GWizThreadReference2_HGroup3_i()];
      }
      
      private function _GWizThreadReference2_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Family";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "Family";
         _loc1_.addEventListener("change",this.__Family_change);
         _loc1_.id = "Family";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Family = _loc1_;
         BindingManager.executeBindings(this,"Family",this.Family);
         return _loc1_;
      }
      
      public function __Family_change(param1:IndexChangeEvent) : void
      {
         this.setFamily();
      }
      
      private function _GWizThreadReference2_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Size";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "Size";
         _loc1_.addEventListener("change",this.__Size_change);
         _loc1_.id = "Size";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Size = _loc1_;
         BindingManager.executeBindings(this,"Size",this.Size);
         return _loc1_;
      }
      
      public function __Size_change(param1:IndexChangeEvent) : void
      {
         this.setSize();
      }
      
      private function _GWizThreadReference2_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Nom. Size";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizThreadReference2_Label3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label3",this._GWizThreadReference2_Label3);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Nominal Thread Size. If you see a padlock, you\'ve overridden the size from the Size dropdown for a custom size.";
         _loc1_.UnitLabel = "in";
         _loc1_.metricOneLessDigit = true;
         _loc1_.addEventListener("change",this.__NomSize_change);
         _loc1_.id = "NomSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.NomSize = _loc1_;
         BindingManager.executeBindings(this,"NomSize",this.NomSize);
         return _loc1_;
      }
      
      public function __NomSize_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizThreadReference2_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "TPI";
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.0001;
         _loc1_.metricOneLessDigit = true;
         _loc1_.addEventListener("valueCommit",this.__custTPI_valueCommit);
         _loc1_.id = "custTPI";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.custTPI = _loc1_;
         BindingManager.executeBindings(this,"custTPI",this.custTPI);
         return _loc1_;
      }
      
      public function __custTPI_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizThreadReference2_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Class";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizThreadReference2_Label4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label4",this._GWizThreadReference2_Label4);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array6_c);
         _loc1_.id = "_GWizThreadReference2_GWizForePanel2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_GWizForePanel2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_GWizForePanel2",this._GWizThreadReference2_GWizForePanel2);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array6_c() : Array
      {
         return [this._GWizThreadReference2_ViewStack2_i()];
      }
      
      private function _GWizThreadReference2_ViewStack2_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.id = "ClassNav";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"ClassNav",
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"UNClasses",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array7_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"ISOClasses",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array8_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.ClassNav = temp;
         BindingManager.executeBindings(this,"ClassNav",this.ClassNav);
         return temp;
      }
      
      private function _GWizThreadReference2_Array7_c() : Array
      {
         return [this._GWizThreadReference2_DropDownList3_i()];
      }
      
      private function _GWizThreadReference2_DropDownList3_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "Class";
         _loc1_.addEventListener("change",this.__ClassChooser_change);
         _loc1_.id = "ClassChooser";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ClassChooser = _loc1_;
         BindingManager.executeBindings(this,"ClassChooser",this.ClassChooser);
         return _loc1_;
      }
      
      public function __ClassChooser_change(param1:IndexChangeEvent) : void
      {
         this.setClass();
      }
      
      private function _GWizThreadReference2_Array8_c() : Array
      {
         return [this._GWizThreadReference2_HGroup2_c()];
      }
      
      private function _GWizThreadReference2_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizThreadReference2_NumericStepper1_i(),this._GWizThreadReference2_NumericStepper2_i(),this._GWizThreadReference2_DropDownList4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.toolTip = "Pitch diamater tolerance.";
         _loc1_.addEventListener("valueCommit",this.__classDigit1_valueCommit);
         _loc1_.id = "classDigit1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.classDigit1 = _loc1_;
         BindingManager.executeBindings(this,"classDigit1",this.classDigit1);
         return _loc1_;
      }
      
      public function __classDigit1_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizThreadReference2_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.toolTip = "Minor (Internal) or Major (External) diamater tolerance.";
         _loc1_.addEventListener("valueCommit",this.__classDigit2_valueCommit);
         _loc1_.id = "classDigit2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.classDigit2 = _loc1_;
         BindingManager.executeBindings(this,"classDigit2",this.classDigit2);
         return _loc1_;
      }
      
      public function __classDigit2_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizThreadReference2_DropDownList4_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "label";
         _loc1_.toolTip = "Position";
         _loc1_.addEventListener("valueCommit",this.__isoLetters_valueCommit);
         _loc1_.id = "isoLetters";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.isoLetters = _loc1_;
         BindingManager.executeBindings(this,"isoLetters",this.isoLetters);
         return _loc1_;
      }
      
      public function __isoLetters_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizThreadReference2_HGroup3_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label5_c(),this._GWizThreadReference2_NumericStepper3_i()];
         _loc1_.id = "ThreadStartGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ThreadStartGrp = _loc1_;
         BindingManager.executeBindings(this,"ThreadStartGrp",this.ThreadStartGrp);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Thread Starts:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_NumericStepper3_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.value = 1;
         _loc1_.minimum = 1;
         _loc1_.maximum = 12;
         _loc1_.stepSize = 1;
         _loc1_.addEventListener("valueCommit",this.__ThreadStarts_valueCommit);
         _loc1_.id = "ThreadStarts";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ThreadStarts = _loc1_;
         BindingManager.executeBindings(this,"ThreadStarts",this.ThreadStarts);
         return _loc1_;
      }
      
      public function __ThreadStarts_valueCommit(param1:FlexEvent) : void
      {
         this.threadStartsVC();
      }
      
      private function _GWizThreadReference2_GWizTappingDrill1_i() : GWizTappingDrill
      {
         var _loc1_:GWizTappingDrill = new GWizTappingDrill();
         _loc1_.id = "TappingDrill";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TappingDrill = _loc1_;
         BindingManager.executeBindings(this,"TappingDrill",this.TappingDrill);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizMOWData1_i() : GWizMOWData
      {
         var _loc1_:GWizMOWData = new GWizMOWData();
         _loc1_.enabled = false;
         _loc1_.id = "MOWData";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MOWData = _loc1_;
         BindingManager.executeBindings(this,"MOWData",this.MOWData);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizThreadReference2_GWizThreadCalcBanner1_i(),this._GWizThreadReference2_Accordion1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizThreadCalcBanner1_i() : GWizThreadCalcBanner
      {
         var _loc1_:GWizThreadCalcBanner = new GWizThreadCalcBanner();
         _loc1_.id = "tcBanner";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tcBanner = _loc1_;
         BindingManager.executeBindings(this,"tcBanner",this.tcBanner);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Accordion1_i() : Accordion
      {
         var temp:Accordion = new Accordion();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.id = "viewAccordion";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":Accordion,
            "id":"viewAccordion",
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Graphics",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array12_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"ReportNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Report",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array22_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"manualLatheNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Manual Lathe",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array26_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.viewAccordion = temp;
         BindingManager.executeBindings(this,"viewAccordion",this.viewAccordion);
         return temp;
      }
      
      private function _GWizThreadReference2_Array12_c() : Array
      {
         return [this._GWizThreadReference2_GWizForePanel3_c()];
      }
      
      private function _GWizThreadReference2_GWizForePanel3_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.trackThemeStyles = false;
         _loc1_.layout = this._GWizThreadReference2_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array13_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VerticalLayout2_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "left";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array13_c() : Array
      {
         return [this._GWizThreadReference2_VGroup3_c(),this._GWizThreadReference2_HGroup4_c()];
      }
      
      private function _GWizThreadReference2_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label6_i(),this._GWizThreadReference2_Label7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "intExtTitle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.intExtTitle = _loc1_;
         BindingManager.executeBindings(this,"intExtTitle",this.intExtTitle);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "designationTitle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.designationTitle = _loc1_;
         BindingManager.executeBindings(this,"designationTitle",this.designationTitle);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizThreadReference2_VGroup4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThreadReference2_ViewStack3_i(),this._GWizThreadReference2_HGroup5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_ViewStack3_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.label = "Graphics";
         temp.creationPolicy = "all";
         temp.setStyle("backgroundColor",12895428);
         temp.addEventListener("change",this.__accordion_change);
         temp.id = "accordion";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"accordion",
            "events":{"change":"__accordion_change"},
            "stylesFactory":function():void
            {
               this.backgroundColor = 12895428;
            },
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Internal",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 13421772;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Internal",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array17_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"External",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 13421772;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"External",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array19_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.accordion = temp;
         BindingManager.executeBindings(this,"accordion",this.accordion);
         return temp;
      }
      
      public function __accordion_change(param1:IndexChangedEvent) : void
      {
         this.setType();
      }
      
      private function _GWizThreadReference2_Array17_c() : Array
      {
         return [this._GWizThreadReference2_BorderContainer1_i()];
      }
      
      private function _GWizThreadReference2_BorderContainer1_i() : BorderContainer
      {
         var _loc1_:BorderContainer = new BorderContainer();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array18_c);
         _loc1_.setStyle("borderAlpha",1);
         _loc1_.setStyle("borderStyle","inset");
         _loc1_.setStyle("borderVisible",true);
         _loc1_.addEventListener("creationComplete",this.___GWizThreadReference2_BorderContainer1_creationComplete);
         _loc1_.id = "_GWizThreadReference2_BorderContainer1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_BorderContainer1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_BorderContainer1",this._GWizThreadReference2_BorderContainer1);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array18_c() : Array
      {
         return [this._GWizThreadReference2_Image1_i(),this._GWizThreadReference2_Label8_i(),this._GWizThreadReference2_Label9_i(),this._GWizThreadReference2_Label10_i(),this._GWizThreadReference2_Label11_i(),this._GWizThreadReference2_Label12_i(),this._GWizThreadReference2_Label13_i(),this._GWizThreadReference2_Label14_i(),this._GWizThreadReference2_Label15_i(),this._GWizThreadReference2_Label16_i(),this._GWizThreadReference2_Label17_i()];
      }
      
      private function _GWizThreadReference2_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.x = 0;
         _loc1_.y = 0;
         _loc1_.id = "IntThreadImage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.IntThreadImage = _loc1_;
         BindingManager.executeBindings(this,"IntThreadImage",this.IntThreadImage);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "MinorDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MinorDia = _loc1_;
         BindingManager.executeBindings(this,"MinorDia",this.MinorDia);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "DiaMean";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DiaMean = _loc1_;
         BindingManager.executeBindings(this,"DiaMean",this.DiaMean);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "PitchDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PitchDia = _loc1_;
         BindingManager.executeBindings(this,"PitchDia",this.PitchDia);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "MajorDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MajorDia = _loc1_;
         BindingManager.executeBindings(this,"MajorDia",this.MajorDia);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label12_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "Height";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Height = _loc1_;
         BindingManager.executeBindings(this,"Height",this.Height);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label13_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "HeightF2F";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HeightF2F = _loc1_;
         BindingManager.executeBindings(this,"HeightF2F",this.HeightF2F);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label14_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "Flat";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Flat = _loc1_;
         BindingManager.executeBindings(this,"Flat",this.Flat);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "Pitch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Pitch = _loc1_;
         BindingManager.executeBindings(this,"Pitch",this.Pitch);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label16_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "ThreadAng";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ThreadAng = _loc1_;
         BindingManager.executeBindings(this,"ThreadAng",this.ThreadAng);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label17_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "TPI";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TPI = _loc1_;
         BindingManager.executeBindings(this,"TPI",this.TPI);
         return _loc1_;
      }
      
      public function ___GWizThreadReference2_BorderContainer1_creationComplete(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizThreadReference2_Array19_c() : Array
      {
         return [this._GWizThreadReference2_BorderContainer2_i()];
      }
      
      private function _GWizThreadReference2_BorderContainer2_i() : BorderContainer
      {
         var _loc1_:BorderContainer = new BorderContainer();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array20_c);
         _loc1_.setStyle("borderAlpha",1);
         _loc1_.setStyle("borderStyle","inset");
         _loc1_.setStyle("borderVisible",true);
         _loc1_.id = "_GWizThreadReference2_BorderContainer2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_BorderContainer2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_BorderContainer2",this._GWizThreadReference2_BorderContainer2);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array20_c() : Array
      {
         return [this._GWizThreadReference2_Image2_i(),this._GWizThreadReference2_Label18_i(),this._GWizThreadReference2_Label19_i(),this._GWizThreadReference2_Label20_i(),this._GWizThreadReference2_Label21_i(),this._GWizThreadReference2_Label22_i(),this._GWizThreadReference2_Label23_i(),this._GWizThreadReference2_Label24_i(),this._GWizThreadReference2_Label25_i(),this._GWizThreadReference2_Label26_i(),this._GWizThreadReference2_Label27_i(),this._GWizThreadReference2_Label28_i()];
      }
      
      private function _GWizThreadReference2_Image2_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.x = 0;
         _loc1_.y = 0;
         _loc1_.id = "ExtThreadImage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ExtThreadImage = _loc1_;
         BindingManager.executeBindings(this,"ExtThreadImage",this.ExtThreadImage);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label18_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "EMinorDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EMinorDia = _loc1_;
         BindingManager.executeBindings(this,"EMinorDia",this.EMinorDia);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label19_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "EDiaMean";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EDiaMean = _loc1_;
         BindingManager.executeBindings(this,"EDiaMean",this.EDiaMean);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label20_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "EPitchDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EPitchDia = _loc1_;
         BindingManager.executeBindings(this,"EPitchDia",this.EPitchDia);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label21_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "EMajorDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EMajorDia = _loc1_;
         BindingManager.executeBindings(this,"EMajorDia",this.EMajorDia);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label22_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "EThreadAng";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EThreadAng = _loc1_;
         BindingManager.executeBindings(this,"EThreadAng",this.EThreadAng);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label23_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "EHeight";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EHeight = _loc1_;
         BindingManager.executeBindings(this,"EHeight",this.EHeight);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label24_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "EHeightF2F";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EHeightF2F = _loc1_;
         BindingManager.executeBindings(this,"EHeightF2F",this.EHeightF2F);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label25_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "EFlat";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EFlat = _loc1_;
         BindingManager.executeBindings(this,"EFlat",this.EFlat);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label26_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "EPitch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EPitch = _loc1_;
         BindingManager.executeBindings(this,"EPitch",this.EPitch);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label27_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "ETPI";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ETPI = _loc1_;
         BindingManager.executeBindings(this,"ETPI",this.ETPI);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label28_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "EFlat2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EFlat2 = _loc1_;
         BindingManager.executeBindings(this,"EFlat2",this.EFlat2);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label29_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label29_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizThreadReference2_Label29";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label29 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label29",this._GWizThreadReference2_Label29);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array22_c() : Array
      {
         return [this._GWizThreadReference2_GWizForePanel4_c()];
      }
      
      private function _GWizThreadReference2_GWizForePanel4_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array23_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array23_c() : Array
      {
         return [this._GWizThreadReference2_VGroup5_c()];
      }
      
      private function _GWizThreadReference2_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label30_i(),this._GWizThreadReference2_Label31_i(),this._GWizThreadReference2_GWizThreadDataGrid1_i(),this._GWizThreadReference2_HGroup6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label30_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "_GWizThreadReference2_Label30";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label30 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label30",this._GWizThreadReference2_Label30);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label31_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "_GWizThreadReference2_Label31";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label31 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label31",this._GWizThreadReference2_Label31);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizThreadDataGrid1_i() : GWizThreadDataGrid
      {
         var _loc1_:GWizThreadDataGrid = new GWizThreadDataGrid();
         _loc1_.id = "threadDataGrid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.threadDataGrid = _loc1_;
         BindingManager.executeBindings(this,"threadDataGrid",this.threadDataGrid);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label32_i(),this._GWizThreadReference2_Spacer1_c(),this._GWizThreadReference2_Button1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label32_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizThreadReference2_Label32";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label32 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label32",this._GWizThreadReference2_Label32);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Save...";
         _loc1_.toolTip = "Save report data in CSV file.";
         _loc1_.addEventListener("click",this.__reportSaveBtn_click);
         _loc1_.id = "reportSaveBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.reportSaveBtn = _loc1_;
         BindingManager.executeBindings(this,"reportSaveBtn",this.reportSaveBtn);
         return _loc1_;
      }
      
      public function __reportSaveBtn_click(param1:MouseEvent) : void
      {
         this.threadDataGrid.doSave();
      }
      
      private function _GWizThreadReference2_Array26_c() : Array
      {
         return [this._GWizThreadReference2_GWizManualLatheThread1_i()];
      }
      
      private function _GWizThreadReference2_GWizManualLatheThread1_i() : GWizManualLatheThread
      {
         var _loc1_:GWizManualLatheThread = new GWizManualLatheThread();
         _loc1_.id = "ManualLathe";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ManualLathe = _loc1_;
         BindingManager.executeBindings(this,"ManualLathe",this.ManualLathe);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array27_c() : Array
      {
         return [this._GWizThreadReference2_HGroup7_c()];
      }
      
      private function _GWizThreadReference2_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.gap = 1;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.mxmlContent = [this._GWizThreadReference2_VGroup6_c(),this._GWizThreadReference2_VGroup7_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VGroup6_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizThreadReference2_GWizForePanel5_c(),this._GWizThreadReference2_GWizForePanel6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizForePanel5_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.layout = this._GWizThreadReference2_VerticalLayout3_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array30_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VerticalLayout3_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 3;
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array30_c() : Array
      {
         return [this._GWizThreadReference2_Label33_c(),this._GWizThreadReference2_DropDownList5_i(),this._GWizThreadReference2_Label34_c(),this._GWizThreadReference2_DropDownList6_i(),this._GWizThreadReference2_Label35_i(),this._GWizThreadReference2_Label36_i()];
      }
      
      private function _GWizThreadReference2_Label33_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Family";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_DropDownList5_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 154;
         _loc1_.labelField = "Family";
         _loc1_.addEventListener("change",this.__PTFamily_change);
         _loc1_.id = "PTFamily";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PTFamily = _loc1_;
         BindingManager.executeBindings(this,"PTFamily",this.PTFamily);
         return _loc1_;
      }
      
      public function __PTFamily_change(param1:IndexChangeEvent) : void
      {
         this.setFamily();
      }
      
      private function _GWizThreadReference2_Label34_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Size";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_DropDownList6_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 154;
         _loc1_.labelField = "Size";
         _loc1_.addEventListener("change",this.__PTSize_change);
         _loc1_.id = "PTSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PTSize = _loc1_;
         BindingManager.executeBindings(this,"PTSize",this.PTSize);
         return _loc1_;
      }
      
      public function __PTSize_change(param1:IndexChangeEvent) : void
      {
         this.setSize();
      }
      
      private function _GWizThreadReference2_Label35_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Pipe Dia.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "PTNomSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PTNomSize = _loc1_;
         BindingManager.executeBindings(this,"PTNomSize",this.PTNomSize);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label36_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "TPI";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "PTTPI";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PTTPI = _loc1_;
         BindingManager.executeBindings(this,"PTTPI",this.PTTPI);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizForePanel6_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizThreadReference2_VerticalLayout4_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array31_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VerticalLayout4_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 3;
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array31_c() : Array
      {
         return [this._GWizThreadReference2_HGroup8_c(),this._GWizThreadReference2_HGroup9_c()];
      }
      
      private function _GWizThreadReference2_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label37_i(),this._GWizThreadReference2_Button2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label37_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tap Drill ???";
         _loc1_.width = 100;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "TapDrill";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TapDrill = _loc1_;
         BindingManager.executeBindings(this,"TapDrill",this.TapDrill);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Drill Chart";
         _loc1_.addEventListener("click",this.___GWizThreadReference2_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizThreadReference2_Button2_click(param1:MouseEvent) : void
      {
         this.showDrillPicker();
      }
      
      private function _GWizThreadReference2_HGroup9_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label38_i(),this._GWizThreadReference2_GWizNumStep1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label38_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tap Depth ???";
         _loc1_.width = 100;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "TapDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TapDepth = _loc1_;
         BindingManager.executeBindings(this,"TapDepth",this.TapDepth);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.visible = false;
         _loc1_.id = "toolDiameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolDiameter = _loc1_;
         BindingManager.executeBindings(this,"toolDiameter",this.toolDiameter);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VGroup7_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizThreadReference2_GWizThreadCalcBanner2_i(),this._GWizThreadReference2_Accordion2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizThreadCalcBanner2_i() : GWizThreadCalcBanner
      {
         var _loc1_:GWizThreadCalcBanner = new GWizThreadCalcBanner();
         _loc1_.id = "tcBanner2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tcBanner2 = _loc1_;
         BindingManager.executeBindings(this,"tcBanner2",this.tcBanner2);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Accordion2_i() : Accordion
      {
         var temp:Accordion = new Accordion();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.id = "viewAccordion2";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":Accordion,
            "id":"viewAccordion2",
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Graphics",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array35_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"ReportNav2",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Report",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizThreadReference2_Array41_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.viewAccordion2 = temp;
         BindingManager.executeBindings(this,"viewAccordion2",this.viewAccordion2);
         return temp;
      }
      
      private function _GWizThreadReference2_Array35_c() : Array
      {
         return [this._GWizThreadReference2_GWizForePanel7_c()];
      }
      
      private function _GWizThreadReference2_GWizForePanel7_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.trackThemeStyles = false;
         _loc1_.layout = this._GWizThreadReference2_VerticalLayout5_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array36_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VerticalLayout5_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "left";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array36_c() : Array
      {
         return [this._GWizThreadReference2_VGroup8_c()];
      }
      
      private function _GWizThreadReference2_VGroup8_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label39_i(),this._GWizThreadReference2_Label40_i(),this._GWizThreadReference2_GWizForePanel8_c(),this._GWizThreadReference2_HGroup10_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label39_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tapered Thread";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "taperTitle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.taperTitle = _loc1_;
         BindingManager.executeBindings(this,"taperTitle",this.taperTitle);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label40_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "_GWizThreadReference2_Label40";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label40 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label40",this._GWizThreadReference2_Label40);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizForePanel8_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.trackThemeStyles = false;
         _loc1_.layout = this._GWizThreadReference2_VerticalLayout6_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array38_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_VerticalLayout6_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array38_c() : Array
      {
         return [this._GWizThreadReference2_BorderContainer3_c()];
      }
      
      private function _GWizThreadReference2_BorderContainer3_c() : BorderContainer
      {
         var _loc1_:BorderContainer = new BorderContainer();
         _loc1_.x = 221;
         _loc1_.y = 10;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array39_c);
         _loc1_.setStyle("borderAlpha",1);
         _loc1_.setStyle("borderStyle","inset");
         _loc1_.setStyle("borderVisible",true);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array39_c() : Array
      {
         return [this._GWizThreadReference2_Image3_i(),this._GWizThreadReference2_Label41_i(),this._GWizThreadReference2_Label42_i(),this._GWizThreadReference2_Label43_i(),this._GWizThreadReference2_Label44_i(),this._GWizThreadReference2_Label45_i(),this._GWizThreadReference2_Label46_i(),this._GWizThreadReference2_Label47_i(),this._GWizThreadReference2_Label48_i(),this._GWizThreadReference2_Label49_i(),this._GWizThreadReference2_Label50_i(),this._GWizThreadReference2_Label51_i(),this._GWizThreadReference2_Label52_i(),this._GWizThreadReference2_Label53_i(),this._GWizThreadReference2_Label54_i(),this._GWizThreadReference2_Label55_i(),this._GWizThreadReference2_Label56_i(),this._GWizThreadReference2_Label57_i(),this._GWizThreadReference2_Label58_i(),this._GWizThreadReference2_Label59_i()];
      }
      
      private function _GWizThreadReference2_Image3_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.x = 0;
         _loc1_.y = 0;
         _loc1_.id = "taperThreadImg";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.taperThreadImg = _loc1_;
         BindingManager.executeBindings(this,"taperThreadImg",this.taperThreadImg);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label41_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 185;
         _loc1_.y = 23;
         _loc1_.text = "Overall Len. (L4) ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labL4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labL4 = _loc1_;
         BindingManager.executeBindings(this,"labL4",this.labL4);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label42_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 54;
         _loc1_.y = 380;
         _loc1_.text = "Pitch";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labPitch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labPitch = _loc1_;
         BindingManager.executeBindings(this,"labPitch",this.labPitch);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label43_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 174;
         _loc1_.y = 408;
         _loc1_.text = "Flat at Crest";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labFlat";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labFlat = _loc1_;
         BindingManager.executeBindings(this,"labFlat",this.labFlat);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label44_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 174;
         _loc1_.y = 436;
         _loc1_.text = "Flat at Crest";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labFlatMax";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labFlatMax = _loc1_;
         BindingManager.executeBindings(this,"labFlatMax",this.labFlatMax);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label45_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 54;
         _loc1_.y = 408;
         _loc1_.text = "TPI";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labTPI";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labTPI = _loc1_;
         BindingManager.executeBindings(this,"labTPI",this.labTPI);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label46_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 54;
         _loc1_.y = 436;
         _loc1_.text = "Height";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labHeight";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labHeight = _loc1_;
         BindingManager.executeBindings(this,"labHeight",this.labHeight);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label47_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 395;
         _loc1_.y = 165;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "lab2P";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.lab2P = _loc1_;
         BindingManager.executeBindings(this,"lab2P",this.lab2P);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label48_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 401;
         _loc1_.y = 133;
         _loc1_.text = "2P";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "lab0";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.lab0 = _loc1_;
         BindingManager.executeBindings(this,"lab0",this.lab0);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label49_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 185;
         _loc1_.y = 79;
         _loc1_.text = "Eff. Len. (L2) ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labL2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labL2 = _loc1_;
         BindingManager.executeBindings(this,"labL2",this.labL2);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label50_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 185;
         _loc1_.y = 138;
         _loc1_.text = "Nom. Perf. (L5) ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labL5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labL5 = _loc1_;
         BindingManager.executeBindings(this,"labL5",this.labL5);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label51_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 174;
         _loc1_.y = 176;
         _loc1_.text = "Handtight (L1) ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labL1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labL1 = _loc1_;
         BindingManager.executeBindings(this,"labL1",this.labL1);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label52_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 146;
         _loc1_.y = 324;
         _loc1_.text = "E0 Pitch Dia.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labE0";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labE0 = _loc1_;
         BindingManager.executeBindings(this,"labE0",this.labE0);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label53_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 457;
         _loc1_.y = 324;
         _loc1_.text = "Pipe Dia.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labPipeDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labPipeDia = _loc1_;
         BindingManager.executeBindings(this,"labPipeDia",this.labPipeDia);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label54_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 432;
         _loc1_.y = 383;
         _loc1_.text = "E5 Pitch Dia.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labE5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labE5 = _loc1_;
         BindingManager.executeBindings(this,"labE5",this.labE5);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label55_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 432;
         _loc1_.y = 352;
         _loc1_.text = "E2 Pitch Dia.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labE2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labE2 = _loc1_;
         BindingManager.executeBindings(this,"labE2",this.labE2);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label56_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 432;
         _loc1_.y = 411;
         _loc1_.text = "E1 Pitch Dia.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labE1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labE1 = _loc1_;
         BindingManager.executeBindings(this,"labE1",this.labE1);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label57_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 54;
         _loc1_.y = 352;
         _loc1_.text = "E3 Pitch Dia.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labE3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labE3 = _loc1_;
         BindingManager.executeBindings(this,"labE3",this.labE3);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label58_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 70;
         _loc1_.y = 176;
         _loc1_.text = "L3";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labL3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labL3 = _loc1_;
         BindingManager.executeBindings(this,"labL3",this.labL3);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label59_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 523;
         _loc1_.y = 190;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "labTaper";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labTaper = _loc1_;
         BindingManager.executeBindings(this,"labTaper",this.labTaper);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_HGroup10_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label60_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label60_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizThreadReference2_Label60";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label60 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label60",this._GWizThreadReference2_Label60);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array41_c() : Array
      {
         var _loc1_:Array = null;
         return [this._GWizThreadReference2_GWizForePanel9_c()];
      }
      
      private function _GWizThreadReference2_GWizForePanel9_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = null;
         _loc1_ = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadReference2_Array42_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Array42_c() : Array
      {
         var _loc1_:Array = null;
         return [this._GWizThreadReference2_VGroup9_c()];
      }
      
      private function _GWizThreadReference2_VGroup9_c() : VGroup
      {
         var _loc1_:VGroup = null;
         _loc1_ = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label61_i(),this._GWizThreadReference2_Label62_i(),this._GWizThreadReference2_GWizThreadDataGrid2_i(),this._GWizThreadReference2_HGroup11_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label61_i() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "_GWizThreadReference2_Label61";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label61 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label61",this._GWizThreadReference2_Label61);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label62_i() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "_GWizThreadReference2_Label62";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label62 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label62",this._GWizThreadReference2_Label62);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_GWizThreadDataGrid2_i() : GWizThreadDataGrid
      {
         var _loc1_:GWizThreadDataGrid = null;
         _loc1_ = new GWizThreadDataGrid();
         _loc1_.isTaperedThread = true;
         _loc1_.id = "taperThreadDataGrid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.taperThreadDataGrid = _loc1_;
         BindingManager.executeBindings(this,"taperThreadDataGrid",this.taperThreadDataGrid);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_HGroup11_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizThreadReference2_Label63_i(),this._GWizThreadReference2_Spacer2_c(),this._GWizThreadReference2_Button3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Label63_i() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.id = "_GWizThreadReference2_Label63";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadReference2_Label63 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadReference2_Label63",this._GWizThreadReference2_Label63);
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadReference2_Button3_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Save...";
         _loc1_.toolTip = "Save report data in CSV file.";
         _loc1_.addEventListener("click",this.__reportSaveBtn2_click);
         _loc1_.id = "reportSaveBtn2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.reportSaveBtn2 = _loc1_;
         BindingManager.executeBindings(this,"reportSaveBtn2",this.reportSaveBtn2);
         return _loc1_;
      }
      
      public function __reportSaveBtn2_click(param1:MouseEvent) : void
      {
         this.taperThreadDataGrid.doSave();
      }
      
      private function _GWizThreadReference2_TabBar1_i() : TabBar
      {
         var _loc1_:TabBar = null;
         _loc1_ = new TabBar();
         _loc1_.styleName = "tabHeader";
         _loc1_.top = 9;
         _loc1_.setStyle("skinClass",GWizTabBarSkin);
         _loc1_.id = "tabs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tabs = _loc1_;
         BindingManager.executeBindings(this,"tabs",this.tabs);
         return _loc1_;
      }
      
      public function ___GWizThreadReference2_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.init();
      }
      
      public function ___GWizThreadReference2_Group1_show(param1:FlexEvent) : void
      {
         this.checkUnits();
      }
      
      private function _GWizThreadReference2_bindingsSetup() : Array
      {
         var result:Array = null;
         result = [];
         result[0] = new Binding(this,function():*
         {
            return GWizAbstractPrefs.ThreadCalcEnabled;
         },function(param1:*):void
         {
            basicPremiumChange = param1;
         },"basicPremiumChange");
         result[1] = new Binding(this,function():Object
         {
            return tabs.height + 8;
         },null,"TabNav.top");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.alternatea1;
         },function(param1:uint):void
         {
            ISOThreads.setStyle("backgroundColor",param1);
         },"ISOThreads.backgroundColor");
         result[3] = new Binding(this,function():IList
         {
            return FamilyList;
         },null,"Family.dataProvider");
         result[4] = new Binding(this,function():Number
         {
            return ThreadStartGrp.width;
         },null,"Family.width");
         result[5] = new Binding(this,function():IList
         {
            return SizeList;
         },null,"Size.dataProvider");
         result[6] = new Binding(this,function():Number
         {
            return ThreadStartGrp.width;
         },null,"Size.width");
         result[7] = new Binding(this,function():Boolean
         {
            return NomSize.enabled;
         },null,"_GWizThreadReference2_Label3.enabled");
         result[8] = new Binding(this,function():Number
         {
            return nominalSize;
         },null,"NomSize.value");
         result[9] = new Binding(this,function():Number
         {
            return ThreadStartGrp.width;
         },null,"NomSize.width");
         result[10] = new Binding(this,function():Number
         {
            return customTPI;
         },null,"custTPI.value");
         result[11] = new Binding(this,function():Number
         {
            return ThreadStartGrp.width;
         },null,"custTPI.width");
         result[12] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = tpiToolTip;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"custTPI.toolTip");
         result[13] = new Binding(this,function():Boolean
         {
            return GWizAbstractThreadEngine.showTolClass;
         },null,"_GWizThreadReference2_Label4.visible");
         result[14] = new Binding(this,function():Boolean
         {
            return GWizAbstractThreadEngine.showTolClass;
         },null,"_GWizThreadReference2_GWizForePanel2.visible");
         result[15] = new Binding(this,function():uint
         {
            return ColorPalette.alternatea1;
         },function(param1:uint):void
         {
            UNClasses.setStyle("backgroundColor",param1);
         },"UNClasses.backgroundColor");
         result[16] = new Binding(this,function():IList
         {
            return GWizAbstractThreadEngine.ClassList;
         },null,"ClassChooser.dataProvider");
         result[17] = new Binding(this,function():Number
         {
            return ThreadStartGrp.width;
         },null,"ClassChooser.width");
         result[18] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            ISOClasses.setStyle("backgroundColor",param1);
         },"ISOClasses.backgroundColor");
         result[19] = new Binding(this,function():Number
         {
            return classDigit1.width * 1.5;
         },null,"isoLetters.width");
         result[20] = new Binding(this,function():Number
         {
            return classDigit1.height;
         },null,"isoLetters.height");
         result[21] = new Binding(this,function():Boolean
         {
            return custTPI.enabled;
         },null,"ThreadStarts.enabled");
         result[22] = new Binding(this,function():Boolean
         {
            return TypeVal == "Internal";
         },null,"TappingDrill.enabled");
         result[23] = new Binding(this,function():Function
         {
            return recalc;
         },null,"TappingDrill.recalcFcn");
         result[24] = new Binding(this,function():Function
         {
            return onIntExtTypeClick;
         },null,"tcBanner.onIntExtTypeClickFcn");
         result[25] = new Binding(this,function():Function
         {
            return doCCW;
         },null,"tcBanner.doCCWFcn");
         result[26] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = intExtTitleBinder;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"intExtTitle.text");
         result[27] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = designation;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"designationTitle.text");
         result[28] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            _GWizThreadReference2_BorderContainer1.setStyle("color",param1);
         },"_GWizThreadReference2_BorderContainer1.color");
         result[29] = new Binding(this,function():Object
         {
            return GWizAbstractThreadEngine.IntThreadImg;
         },null,"IntThreadImage.source");
         result[30] = new Binding(this,function():Number
         {
            return X_SCALE;
         },null,"IntThreadImage.scaleX");
         result[31] = new Binding(this,function():Number
         {
            return Y_SCALE;
         },null,"IntThreadImage.scaleY");
         result[32] = new Binding(this,function():Number
         {
            return 336 * X_SCALE;
         },null,"MinorDia.x");
         result[33] = new Binding(this,function():Number
         {
            return 183 * Y_SCALE;
         },null,"MinorDia.y");
         result[34] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            MinorDia.setStyle("color",param1);
         },"MinorDia.color");
         result[35] = new Binding(this,function():Number
         {
            return 374 * X_SCALE;
         },null,"DiaMean.x");
         result[36] = new Binding(this,function():Number
         {
            return 203 * Y_SCALE;
         },null,"DiaMean.y");
         result[37] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            DiaMean.setStyle("color",param1);
         },"DiaMean.color");
         result[38] = new Binding(this,function():Number
         {
            return 190 * X_SCALE;
         },null,"PitchDia.x");
         result[39] = new Binding(this,function():Number
         {
            return 223 * Y_SCALE;
         },null,"PitchDia.y");
         result[40] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            PitchDia.setStyle("color",param1);
         },"PitchDia.color");
         result[41] = new Binding(this,function():Number
         {
            return 22 * X_SCALE;
         },null,"MajorDia.x");
         result[42] = new Binding(this,function():Number
         {
            return 183 * Y_SCALE;
         },null,"MajorDia.y");
         result[43] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            MajorDia.setStyle("color",param1);
         },"MajorDia.color");
         result[44] = new Binding(this,function():Number
         {
            return 374 * X_SCALE;
         },null,"Height.x");
         result[45] = new Binding(this,function():Number
         {
            return 80 * Y_SCALE;
         },null,"Height.y");
         result[46] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            Height.setStyle("color",param1);
         },"Height.color");
         result[47] = new Binding(this,function():Number
         {
            return 300 * X_SCALE;
         },null,"HeightF2F.x");
         result[48] = new Binding(this,function():Number
         {
            return 98 * Y_SCALE;
         },null,"HeightF2F.y");
         result[49] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            HeightF2F.setStyle("color",param1);
         },"HeightF2F.color");
         result[50] = new Binding(this,function():Number
         {
            return 122 * X_SCALE;
         },null,"Flat.x");
         result[51] = new Binding(this,function():Number
         {
            return 285 * Y_SCALE;
         },null,"Flat.y");
         result[52] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            Flat.setStyle("color",param1);
         },"Flat.color");
         result[53] = new Binding(this,function():Number
         {
            return 190 * X_SCALE;
         },null,"Pitch.x");
         result[54] = new Binding(this,function():Number
         {
            return 163 * Y_SCALE;
         },null,"Pitch.y");
         result[55] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            Pitch.setStyle("color",param1);
         },"Pitch.color");
         result[56] = new Binding(this,function():Number
         {
            return 228 * X_SCALE;
         },null,"ThreadAng.x");
         result[57] = new Binding(this,function():Number
         {
            return 93 * Y_SCALE;
         },null,"ThreadAng.y");
         result[58] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            ThreadAng.setStyle("color",param1);
         },"ThreadAng.color");
         result[59] = new Binding(this,function():Number
         {
            return 190 * X_SCALE;
         },null,"TPI.x");
         result[60] = new Binding(this,function():Number
         {
            return 183 * Y_SCALE;
         },null,"TPI.y");
         result[61] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            TPI.setStyle("color",param1);
         },"TPI.color");
         result[62] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            External.setStyle("color",param1);
         },"External.color");
         result[63] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            _GWizThreadReference2_BorderContainer2.setStyle("color",param1);
         },"_GWizThreadReference2_BorderContainer2.color");
         result[64] = new Binding(this,function():Object
         {
            return GWizAbstractThreadEngine.ExtThreadImg;
         },null,"ExtThreadImage.source");
         result[65] = new Binding(this,function():Number
         {
            return X_SCALE;
         },null,"ExtThreadImage.scaleX");
         result[66] = new Binding(this,function():Number
         {
            return Y_SCALE;
         },null,"ExtThreadImage.scaleY");
         result[67] = new Binding(this,function():Number
         {
            return 337 * X_SCALE;
         },null,"EMinorDia.x");
         result[68] = new Binding(this,function():Number
         {
            return 188 * Y_SCALE;
         },null,"EMinorDia.y");
         result[69] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            EMinorDia.setStyle("color",param1);
         },"EMinorDia.color");
         result[70] = new Binding(this,function():Number
         {
            return 314 * X_SCALE;
         },null,"EDiaMean.x");
         result[71] = new Binding(this,function():Number
         {
            return 71 * Y_SCALE;
         },null,"EDiaMean.y");
         result[72] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            EDiaMean.setStyle("color",param1);
         },"EDiaMean.color");
         result[73] = new Binding(this,function():Number
         {
            return 182 * X_SCALE;
         },null,"EPitchDia.x");
         result[74] = new Binding(this,function():Number
         {
            return 162 * Y_SCALE;
         },null,"EPitchDia.y");
         result[75] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            EPitchDia.setStyle("color",param1);
         },"EPitchDia.color");
         result[76] = new Binding(this,function():Number
         {
            return 314 * X_SCALE;
         },null,"EMajorDia.x");
         result[77] = new Binding(this,function():Number
         {
            return 48 * Y_SCALE;
         },null,"EMajorDia.y");
         result[78] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            EMajorDia.setStyle("color",param1);
         },"EMajorDia.color");
         result[79] = new Binding(this,function():Number
         {
            return 230 * X_SCALE;
         },null,"EThreadAng.x");
         result[80] = new Binding(this,function():Number
         {
            return 290 * Y_SCALE;
         },null,"EThreadAng.y");
         result[81] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            EThreadAng.setStyle("color",param1);
         },"EThreadAng.color");
         result[82] = new Binding(this,function():Number
         {
            return 50 * X_SCALE;
         },null,"EHeight.x");
         result[83] = new Binding(this,function():Number
         {
            return 314 * Y_SCALE;
         },null,"EHeight.y");
         result[84] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            EHeight.setStyle("color",param1);
         },"EHeight.color");
         result[85] = new Binding(this,function():Number
         {
            return 314 * X_SCALE;
         },null,"EHeightF2F.x");
         result[86] = new Binding(this,function():Number
         {
            return 310 * Y_SCALE;
         },null,"EHeightF2F.y");
         result[87] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            EHeightF2F.setStyle("color",param1);
         },"EHeightF2F.color");
         result[88] = new Binding(this,function():Number
         {
            return 137 * X_SCALE;
         },null,"EFlat.x");
         result[89] = new Binding(this,function():Number
         {
            return 93 * Y_SCALE;
         },null,"EFlat.y");
         result[90] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            EFlat.setStyle("color",param1);
         },"EFlat.color");
         result[91] = new Binding(this,function():Number
         {
            return 209 * X_SCALE;
         },null,"EPitch.x");
         result[92] = new Binding(this,function():Number
         {
            return 224 * Y_SCALE;
         },null,"EPitch.y");
         result[93] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            EPitch.setStyle("color",param1);
         },"EPitch.color");
         result[94] = new Binding(this,function():Number
         {
            return 209 * X_SCALE;
         },null,"ETPI.x");
         result[95] = new Binding(this,function():Number
         {
            return 240 * Y_SCALE;
         },null,"ETPI.y");
         result[96] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            ETPI.setStyle("color",param1);
         },"ETPI.color");
         result[97] = new Binding(this,function():Number
         {
            return 284 * X_SCALE;
         },null,"EFlat2.x");
         result[98] = new Binding(this,function():Number
         {
            return 17 * Y_SCALE;
         },null,"EFlat2.y");
         result[99] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            EFlat2.setStyle("color",param1);
         },"EFlat2.color");
         result[100] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = "Reference: " + threadReference;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizThreadReference2_Label29.text");
         result[101] = new Binding(this,function():Boolean
         {
            return ReportNav.enabled;
         },null,"ReportNav.visible");
         result[102] = new Binding(this,function():Boolean
         {
            return ReportNav.enabled;
         },null,"ReportNav.includeInLayout");
         result[103] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = intExtTitleBinder;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizThreadReference2_Label30.text");
         result[104] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = designation;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizThreadReference2_Label31.text");
         result[105] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = StdThreadCt + " standard straight threads in database.";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizThreadReference2_Label32.text");
         result[106] = new Binding(this,function():Boolean
         {
            return ManualLathe.enabled;
         },null,"manualLatheNav.visible");
         result[107] = new Binding(this,function():uint
         {
            return ColorPalette.alternatea1;
         },function(param1:uint):void
         {
            PipeThreads.setStyle("backgroundColor",param1);
         },"PipeThreads.backgroundColor");
         result[108] = new Binding(this,null,null,"PipeThreads.enabled","showPipeThreads");
         result[109] = new Binding(this,null,null,"PipeThreads.includeInLayout","showPipeThreads");
         result[110] = new Binding(this,function():IList
         {
            return FamilyList;
         },null,"PTFamily.dataProvider");
         result[111] = new Binding(this,function():IList
         {
            return SizeList;
         },null,"PTSize.dataProvider");
         result[112] = new Binding(this,function():Function
         {
            return onIntExtTypeClick;
         },null,"tcBanner2.onIntExtTypeClickFcn");
         result[113] = new Binding(this,function():Function
         {
            return doCCW;
         },null,"tcBanner2.doCCWFcn");
         result[114] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = designation;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizThreadReference2_Label40.text");
         result[115] = new Binding(this,function():Object
         {
            return GWizAbstractTaperThreadEngine.TaperThreadImg + "\')";
         },null,"taperThreadImg.source");
         result[116] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labL4.setStyle("color",param1);
         },"labL4.color");
         result[117] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labPitch.setStyle("color",param1);
         },"labPitch.color");
         result[118] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labFlat.setStyle("color",param1);
         },"labFlat.color");
         result[119] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labFlatMax.setStyle("color",param1);
         },"labFlatMax.color");
         result[120] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labTPI.setStyle("color",param1);
         },"labTPI.color");
         result[121] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labHeight.setStyle("color",param1);
         },"labHeight.color");
         result[122] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            lab2P.setStyle("color",param1);
         },"lab2P.color");
         result[123] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            lab0.setStyle("color",param1);
         },"lab0.color");
         result[124] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labL2.setStyle("color",param1);
         },"labL2.color");
         result[125] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labL5.setStyle("color",param1);
         },"labL5.color");
         result[126] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labL1.setStyle("color",param1);
         },"labL1.color");
         result[127] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labE0.setStyle("color",param1);
         },"labE0.color");
         result[128] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labPipeDia.setStyle("color",param1);
         },"labPipeDia.color");
         result[129] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labE5.setStyle("color",param1);
         },"labE5.color");
         result[130] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labE2.setStyle("color",param1);
         },"labE2.color");
         result[131] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labE1.setStyle("color",param1);
         },"labE1.color");
         result[132] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labE3.setStyle("color",param1);
         },"labE3.color");
         result[133] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labL3.setStyle("color",param1);
         },"labL3.color");
         result[134] = new Binding(this,function():uint
         {
            return DRAWING_TEXT_COLOR;
         },function(param1:uint):void
         {
            labTaper.setStyle("color",param1);
         },"labTaper.color");
         result[135] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = "Reference: " + threadReference;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizThreadReference2_Label60.text");
         result[136] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = intExtTitleBinder;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizThreadReference2_Label61.text");
         result[137] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = designation;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizThreadReference2_Label62.text");
         result[138] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = StdThreadCt + " standard straight threads in database.";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizThreadReference2_Label63.text");
         result[139] = new Binding(this,null,null,"tabs.dataProvider","TabNav");
         result[140] = new Binding(this,function():uint
         {
            return ColorPalette.alternatea1;
         },function(param1:uint):void
         {
            tabs.setStyle("chromeColor",param1);
         },"tabs.chromeColor");
         result[141] = new Binding(this,function():uint
         {
            return ColorPalette.alternatea5;
         },function(param1:uint):void
         {
            tabs.setStyle("color",param1);
         },"tabs.color");
         return result;
      }
      
      private function _GWizThreadReference2_bindingExprs() : void
      {
         var _loc1_:* = undefined;
         this.basicPremiumChange = GWizAbstractPrefs.ThreadCalcEnabled;
      }
      
      [Bindable(event="propertyChange")]
      public function get ClassChooser() : DropDownList
      {
         return this._951875779ClassChooser;
      }
      
      public function set ClassChooser(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._951875779ClassChooser;
         if(_loc2_ !== param1)
         {
            this._951875779ClassChooser = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ClassChooser",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ClassNav() : ViewStack
      {
         return this._757061803ClassNav;
      }
      
      public function set ClassNav(param1:ViewStack) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._757061803ClassNav;
         if(_loc2_ !== param1)
         {
            this._757061803ClassNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ClassNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DiaMean() : Label
      {
         return this._976222655DiaMean;
      }
      
      public function set DiaMean(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._976222655DiaMean;
         if(_loc2_ !== param1)
         {
            this._976222655DiaMean = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DiaMean",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EDiaMean() : Label
      {
         return this._981393828EDiaMean;
      }
      
      public function set EDiaMean(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._981393828EDiaMean;
         if(_loc2_ !== param1)
         {
            this._981393828EDiaMean = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EDiaMean",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EFlat() : Label
      {
         return this._65915230EFlat;
      }
      
      public function set EFlat(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._65915230EFlat;
         if(_loc2_ !== param1)
         {
            this._65915230EFlat = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EFlat",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EFlat2() : Label
      {
         return this._2043372180EFlat2;
      }
      
      public function set EFlat2(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2043372180EFlat2;
         if(_loc2_ !== param1)
         {
            this._2043372180EFlat2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EFlat2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EHeight() : Label
      {
         return this._1028950580EHeight;
      }
      
      public function set EHeight(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1028950580EHeight;
         if(_loc2_ !== param1)
         {
            this._1028950580EHeight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EHeight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EHeightF2F() : Label
      {
         return this._285068338EHeightF2F;
      }
      
      public function set EHeightF2F(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._285068338EHeightF2F;
         if(_loc2_ !== param1)
         {
            this._285068338EHeightF2F = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EHeightF2F",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EMajorDia() : Label
      {
         return this._73687192EMajorDia;
      }
      
      public function set EMajorDia(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._73687192EMajorDia;
         if(_loc2_ !== param1)
         {
            this._73687192EMajorDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EMajorDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EMinorDia() : Label
      {
         return this._1449075732EMinorDia;
      }
      
      public function set EMinorDia(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1449075732EMinorDia;
         if(_loc2_ !== param1)
         {
            this._1449075732EMinorDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EMinorDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EPitch() : Label
      {
         return this._2052535803EPitch;
      }
      
      public function set EPitch(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2052535803EPitch;
         if(_loc2_ !== param1)
         {
            this._2052535803EPitch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EPitch",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EPitchDia() : Label
      {
         return this._355217279EPitchDia;
      }
      
      public function set EPitchDia(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._355217279EPitchDia;
         if(_loc2_ !== param1)
         {
            this._355217279EPitchDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EPitchDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ETPI() : Label
      {
         return this._2138856ETPI;
      }
      
      public function set ETPI(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2138856ETPI;
         if(_loc2_ !== param1)
         {
            this._2138856ETPI = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ETPI",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EThreadAng() : Label
      {
         return this._232825685EThreadAng;
      }
      
      public function set EThreadAng(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._232825685EThreadAng;
         if(_loc2_ !== param1)
         {
            this._232825685EThreadAng = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EThreadAng",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ExtThreadImage() : Image
      {
         return this._336720ExtThreadImage;
      }
      
      public function set ExtThreadImage(param1:Image) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._336720ExtThreadImage;
         if(_loc2_ !== param1)
         {
            this._336720ExtThreadImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ExtThreadImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get External() : NavigatorContent
      {
         return this._1756117013External;
      }
      
      public function set External(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1756117013External;
         if(_loc2_ !== param1)
         {
            this._1756117013External = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"External",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Family() : DropDownList
      {
         return this._2096973700Family;
      }
      
      public function set Family(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2096973700Family;
         if(_loc2_ !== param1)
         {
            this._2096973700Family = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Family",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Flat() : Label
      {
         return this._2192281Flat;
      }
      
      public function set Flat(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2192281Flat;
         if(_loc2_ !== param1)
         {
            this._2192281Flat = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Flat",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Height() : Label
      {
         return this._2137162425Height;
      }
      
      public function set Height(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2137162425Height;
         if(_loc2_ !== param1)
         {
            this._2137162425Height = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Height",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HeightF2F() : Label
      {
         return this._389461619HeightF2F;
      }
      
      public function set HeightF2F(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._389461619HeightF2F;
         if(_loc2_ !== param1)
         {
            this._389461619HeightF2F = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HeightF2F",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ISOClasses() : NavigatorContent
      {
         return this._1605888001ISOClasses;
      }
      
      public function set ISOClasses(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1605888001ISOClasses;
         if(_loc2_ !== param1)
         {
            this._1605888001ISOClasses = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ISOClasses",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ISOThreads() : NavigatorContent
      {
         return this._585669756ISOThreads;
      }
      
      public function set ISOThreads(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._585669756ISOThreads;
         if(_loc2_ !== param1)
         {
            this._585669756ISOThreads = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ISOThreads",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get IntThreadImage() : Image
      {
         return this._911458850IntThreadImage;
      }
      
      public function set IntThreadImage(param1:Image) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._911458850IntThreadImage;
         if(_loc2_ !== param1)
         {
            this._911458850IntThreadImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IntThreadImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Internal() : NavigatorContent
      {
         return this._635054813Internal;
      }
      
      public function set Internal(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._635054813Internal;
         if(_loc2_ !== param1)
         {
            this._635054813Internal = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Internal",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MOWData() : GWizMOWData
      {
         return this._1962478655MOWData;
      }
      
      public function set MOWData(param1:GWizMOWData) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1962478655MOWData;
         if(_loc2_ !== param1)
         {
            this._1962478655MOWData = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MOWData",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MajorDia() : Label
      {
         return this._86619171MajorDia;
      }
      
      public function set MajorDia(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._86619171MajorDia;
         if(_loc2_ !== param1)
         {
            this._86619171MajorDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MajorDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ManualLathe() : GWizManualLatheThread
      {
         return this._1339260566ManualLathe;
      }
      
      public function set ManualLathe(param1:GWizManualLatheThread) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1339260566ManualLathe;
         if(_loc2_ !== param1)
         {
            this._1339260566ManualLathe = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ManualLathe",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MinorDia() : Label
      {
         return this._1288769369MinorDia;
      }
      
      public function set MinorDia(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1288769369MinorDia;
         if(_loc2_ !== param1)
         {
            this._1288769369MinorDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MinorDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get NomSize() : GWizNumStepOvr
      {
         return this._508079923NomSize;
      }
      
      public function set NomSize(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._508079923NomSize;
         if(_loc2_ !== param1)
         {
            this._508079923NomSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"NomSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PTFamily() : DropDownList
      {
         return this._1323744904PTFamily;
      }
      
      public function set PTFamily(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1323744904PTFamily;
         if(_loc2_ !== param1)
         {
            this._1323744904PTFamily = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PTFamily",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PTNomSize() : Label
      {
         return this._1291631177PTNomSize;
      }
      
      public function set PTNomSize(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1291631177PTNomSize;
         if(_loc2_ !== param1)
         {
            this._1291631177PTNomSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PTNomSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PTSize() : DropDownList
      {
         return this._1924482011PTSize;
      }
      
      public function set PTSize(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1924482011PTSize;
         if(_loc2_ !== param1)
         {
            this._1924482011PTSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PTSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PTTPI() : Label
      {
         return this._76467401PTTPI;
      }
      
      public function set PTTPI(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._76467401PTTPI;
         if(_loc2_ !== param1)
         {
            this._76467401PTTPI = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PTTPI",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PipeThreads() : NavigatorContent
      {
         return this._1495805445PipeThreads;
      }
      
      public function set PipeThreads(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1495805445PipeThreads;
         if(_loc2_ !== param1)
         {
            this._1495805445PipeThreads = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PipeThreads",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Pitch() : Label
      {
         return this._77124384Pitch;
      }
      
      public function set Pitch(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._77124384Pitch;
         if(_loc2_ !== param1)
         {
            this._77124384Pitch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Pitch",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PitchDia() : Label
      {
         return this._194910916PitchDia;
      }
      
      public function set PitchDia(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._194910916PitchDia;
         if(_loc2_ !== param1)
         {
            this._194910916PitchDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PitchDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ReportNav() : NavigatorContent
      {
         return this._1650622255ReportNav;
      }
      
      public function set ReportNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1650622255ReportNav;
         if(_loc2_ !== param1)
         {
            this._1650622255ReportNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ReportNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ReportNav2() : NavigatorContent
      {
         return this._370317597ReportNav2;
      }
      
      public function set ReportNav2(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._370317597ReportNav2;
         if(_loc2_ !== param1)
         {
            this._370317597ReportNav2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ReportNav2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Size() : DropDownList
      {
         return this._2577441Size;
      }
      
      public function set Size(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2577441Size;
         if(_loc2_ !== param1)
         {
            this._2577441Size = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Size",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TPI() : Label
      {
         return this._83277TPI;
      }
      
      public function set TPI(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._83277TPI;
         if(_loc2_ !== param1)
         {
            this._83277TPI = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TPI",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TabNav() : ViewStack
      {
         return this._1797539474TabNav;
      }
      
      public function set TabNav(param1:ViewStack) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1797539474TabNav;
         if(_loc2_ !== param1)
         {
            this._1797539474TabNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TabNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TapDepth() : Label
      {
         return this._466891520TapDepth;
      }
      
      public function set TapDepth(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._466891520TapDepth;
         if(_loc2_ !== param1)
         {
            this._466891520TapDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TapDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TapDrill() : Label
      {
         return this._466511208TapDrill;
      }
      
      public function set TapDrill(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._466511208TapDrill;
         if(_loc2_ !== param1)
         {
            this._466511208TapDrill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TapDrill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TappingDrill() : GWizTappingDrill
      {
         return this._1190938138TappingDrill;
      }
      
      public function set TappingDrill(param1:GWizTappingDrill) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1190938138TappingDrill;
         if(_loc2_ !== param1)
         {
            this._1190938138TappingDrill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TappingDrill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThreadAng() : Label
      {
         return this._441704272ThreadAng;
      }
      
      public function set ThreadAng(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._441704272ThreadAng;
         if(_loc2_ !== param1)
         {
            this._441704272ThreadAng = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThreadAng",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThreadStartGrp() : HGroup
      {
         return this._96668307ThreadStartGrp;
      }
      
      public function set ThreadStartGrp(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._96668307ThreadStartGrp;
         if(_loc2_ !== param1)
         {
            this._96668307ThreadStartGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThreadStartGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThreadStarts() : NumericStepper
      {
         return this._447027429ThreadStarts;
      }
      
      public function set ThreadStarts(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._447027429ThreadStarts;
         if(_loc2_ !== param1)
         {
            this._447027429ThreadStarts = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThreadStarts",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get UNClasses() : NavigatorContent
      {
         return this._2003720013UNClasses;
      }
      
      public function set UNClasses(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2003720013UNClasses;
         if(_loc2_ !== param1)
         {
            this._2003720013UNClasses = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"UNClasses",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get accordion() : ViewStack
      {
         return this._1830107832accordion;
      }
      
      public function set accordion(param1:ViewStack) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1830107832accordion;
         if(_loc2_ !== param1)
         {
            this._1830107832accordion = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"accordion",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get classDigit1() : NumericStepper
      {
         return this._1192212420classDigit1;
      }
      
      public function set classDigit1(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1192212420classDigit1;
         if(_loc2_ !== param1)
         {
            this._1192212420classDigit1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"classDigit1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get classDigit2() : NumericStepper
      {
         return this._1192212419classDigit2;
      }
      
      public function set classDigit2(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1192212419classDigit2;
         if(_loc2_ !== param1)
         {
            this._1192212419classDigit2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"classDigit2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get custTPI() : GWizNumStepOvr
      {
         return this._1127905818custTPI;
      }
      
      public function set custTPI(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1127905818custTPI;
         if(_loc2_ !== param1)
         {
            this._1127905818custTPI = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"custTPI",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get designationTitle() : Label
      {
         return this._130763615designationTitle;
      }
      
      public function set designationTitle(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._130763615designationTitle;
         if(_loc2_ !== param1)
         {
            this._130763615designationTitle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"designationTitle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get intExtTitle() : Label
      {
         return this._826379834intExtTitle;
      }
      
      public function set intExtTitle(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._826379834intExtTitle;
         if(_loc2_ !== param1)
         {
            this._826379834intExtTitle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"intExtTitle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get isoLetters() : DropDownList
      {
         return this._1053536456isoLetters;
      }
      
      public function set isoLetters(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1053536456isoLetters;
         if(_loc2_ !== param1)
         {
            this._1053536456isoLetters = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"isoLetters",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get lab0() : Label
      {
         return this._3313731lab0;
      }
      
      public function set lab0(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._3313731lab0;
         if(_loc2_ !== param1)
         {
            this._3313731lab0 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"lab0",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get lab2P() : Label
      {
         return this._102725803lab2P;
      }
      
      public function set lab2P(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102725803lab2P;
         if(_loc2_ !== param1)
         {
            this._102725803lab2P = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"lab2P",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labE0() : Label
      {
         return this._102726360labE0;
      }
      
      public function set labE0(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102726360labE0;
         if(_loc2_ !== param1)
         {
            this._102726360labE0 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labE0",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labE1() : Label
      {
         return this._102726361labE1;
      }
      
      public function set labE1(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102726361labE1;
         if(_loc2_ !== param1)
         {
            this._102726361labE1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labE1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labE2() : Label
      {
         return this._102726362labE2;
      }
      
      public function set labE2(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102726362labE2;
         if(_loc2_ !== param1)
         {
            this._102726362labE2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labE2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labE3() : Label
      {
         return this._102726363labE3;
      }
      
      public function set labE3(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102726363labE3;
         if(_loc2_ !== param1)
         {
            this._102726363labE3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labE3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labE5() : Label
      {
         return this._102726365labE5;
      }
      
      public function set labE5(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102726365labE5;
         if(_loc2_ !== param1)
         {
            this._102726365labE5 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labE5",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labFlat() : Label
      {
         return this._64125274labFlat;
      }
      
      public function set labFlat(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._64125274labFlat;
         if(_loc2_ !== param1)
         {
            this._64125274labFlat = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labFlat",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labFlatMax() : Label
      {
         return this._904486110labFlatMax;
      }
      
      public function set labFlatMax(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._904486110labFlatMax;
         if(_loc2_ !== param1)
         {
            this._904486110labFlatMax = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labFlatMax",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labHeight() : Label
      {
         return this._1443823340labHeight;
      }
      
      public function set labHeight(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1443823340labHeight;
         if(_loc2_ !== param1)
         {
            this._1443823340labHeight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labHeight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labL1() : Label
      {
         return this._102726578labL1;
      }
      
      public function set labL1(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102726578labL1;
         if(_loc2_ !== param1)
         {
            this._102726578labL1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labL1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labL2() : Label
      {
         return this._102726579labL2;
      }
      
      public function set labL2(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102726579labL2;
         if(_loc2_ !== param1)
         {
            this._102726579labL2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labL2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labL3() : Label
      {
         return this._102726580labL3;
      }
      
      public function set labL3(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102726580labL3;
         if(_loc2_ !== param1)
         {
            this._102726580labL3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labL3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labL4() : Label
      {
         return this._102726581labL4;
      }
      
      public function set labL4(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102726581labL4;
         if(_loc2_ !== param1)
         {
            this._102726581labL4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labL4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labL5() : Label
      {
         return this._102726582labL5;
      }
      
      public function set labL5(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._102726582labL5;
         if(_loc2_ !== param1)
         {
            this._102726582labL5 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labL5",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labPipeDia() : Label
      {
         return this._1117098401labPipeDia;
      }
      
      public function set labPipeDia(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1117098401labPipeDia;
         if(_loc2_ !== param1)
         {
            this._1117098401labPipeDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labPipeDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labPitch() : Label
      {
         return this._1978719821labPitch;
      }
      
      public function set labPitch(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1978719821labPitch;
         if(_loc2_ !== param1)
         {
            this._1978719821labPitch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labPitch",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labTPI() : Label
      {
         return this._1110434656labTPI;
      }
      
      public function set labTPI(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1110434656labTPI;
         if(_loc2_ !== param1)
         {
            this._1110434656labTPI = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labTPI",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labTaper() : Label
      {
         return this._1975267837labTaper;
      }
      
      public function set labTaper(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1975267837labTaper;
         if(_loc2_ !== param1)
         {
            this._1975267837labTaper = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labTaper",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get manualLatheNav() : NavigatorContent
      {
         return this._1332586867manualLatheNav;
      }
      
      public function set manualLatheNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1332586867manualLatheNav;
         if(_loc2_ !== param1)
         {
            this._1332586867manualLatheNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"manualLatheNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get radiogroup2() : RadioButtonGroup
      {
         return this._164873550radiogroup2;
      }
      
      public function set radiogroup2(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._164873550radiogroup2;
         if(_loc2_ !== param1)
         {
            this._164873550radiogroup2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radiogroup2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get reportSaveBtn() : Button
      {
         return this._984627147reportSaveBtn;
      }
      
      public function set reportSaveBtn(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._984627147reportSaveBtn;
         if(_loc2_ !== param1)
         {
            this._984627147reportSaveBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"reportSaveBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get reportSaveBtn2() : Button
      {
         return this._458670535reportSaveBtn2;
      }
      
      public function set reportSaveBtn2(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._458670535reportSaveBtn2;
         if(_loc2_ !== param1)
         {
            this._458670535reportSaveBtn2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"reportSaveBtn2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tabs() : TabBar
      {
         return this._3552126tabs;
      }
      
      public function set tabs(param1:TabBar) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._3552126tabs;
         if(_loc2_ !== param1)
         {
            this._3552126tabs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tabs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get taperThreadDataGrid() : GWizThreadDataGrid
      {
         return this._258707946taperThreadDataGrid;
      }
      
      public function set taperThreadDataGrid(param1:GWizThreadDataGrid) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._258707946taperThreadDataGrid;
         if(_loc2_ !== param1)
         {
            this._258707946taperThreadDataGrid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"taperThreadDataGrid",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get taperThreadImg() : Image
      {
         return this._1222635607taperThreadImg;
      }
      
      public function set taperThreadImg(param1:Image) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1222635607taperThreadImg;
         if(_loc2_ !== param1)
         {
            this._1222635607taperThreadImg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"taperThreadImg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get taperTitle() : Label
      {
         return this._135791448taperTitle;
      }
      
      public function set taperTitle(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._135791448taperTitle;
         if(_loc2_ !== param1)
         {
            this._135791448taperTitle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"taperTitle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tcBanner() : GWizThreadCalcBanner
      {
         return this._46421381tcBanner;
      }
      
      public function set tcBanner(param1:GWizThreadCalcBanner) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._46421381tcBanner;
         if(_loc2_ !== param1)
         {
            this._46421381tcBanner = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tcBanner",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tcBanner2() : GWizThreadCalcBanner
      {
         return this._1439062761tcBanner2;
      }
      
      public function set tcBanner2(param1:GWizThreadCalcBanner) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1439062761tcBanner2;
         if(_loc2_ !== param1)
         {
            this._1439062761tcBanner2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tcBanner2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get threadDataGrid() : GWizThreadDataGrid
      {
         return this._1377227322threadDataGrid;
      }
      
      public function set threadDataGrid(param1:GWizThreadDataGrid) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1377227322threadDataGrid;
         if(_loc2_ !== param1)
         {
            this._1377227322threadDataGrid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"threadDataGrid",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolDiameter() : GWizNumStep
      {
         return this._2052278853toolDiameter;
      }
      
      public function set toolDiameter(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2052278853toolDiameter;
         if(_loc2_ !== param1)
         {
            this._2052278853toolDiameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolDiameter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get viewAccordion() : Accordion
      {
         return this._1862063139viewAccordion;
      }
      
      public function set viewAccordion(param1:Accordion) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1862063139viewAccordion;
         if(_loc2_ !== param1)
         {
            this._1862063139viewAccordion = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"viewAccordion",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get viewAccordion2() : Accordion
      {
         return this._1889382511viewAccordion2;
      }
      
      public function set viewAccordion2(param1:Accordion) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1889382511viewAccordion2;
         if(_loc2_ !== param1)
         {
            this._1889382511viewAccordion2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"viewAccordion2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get showPipeThreads() : Boolean
      {
         return this._991549730showPipeThreads;
      }
      
      public function set showPipeThreads(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._991549730showPipeThreads;
         if(_loc2_ !== param1)
         {
            this._991549730showPipeThreads = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"showPipeThreads",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get StdThreadCt() : int
      {
         return this._1037611838StdThreadCt;
      }
      
      private function set StdThreadCt(param1:int) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1037611838StdThreadCt;
         if(_loc2_ !== param1)
         {
            this._1037611838StdThreadCt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"StdThreadCt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get TaperThreadCt() : int
      {
         return this._343879595TaperThreadCt;
      }
      
      private function set TaperThreadCt(param1:int) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._343879595TaperThreadCt;
         if(_loc2_ !== param1)
         {
            this._343879595TaperThreadCt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TaperThreadCt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get FamilyList() : ArrayCollection
      {
         return this._1502999998FamilyList;
      }
      
      private function set FamilyList(param1:ArrayCollection) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1502999998FamilyList;
         if(_loc2_ !== param1)
         {
            this._1502999998FamilyList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FamilyList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get SizeList() : ArrayCollection
      {
         return this._911376479SizeList;
      }
      
      private function set SizeList(param1:ArrayCollection) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._911376479SizeList;
         if(_loc2_ !== param1)
         {
            this._911376479SizeList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SizeList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get TypeVal() : String
      {
         return this._811554151TypeVal;
      }
      
      private function set TypeVal(param1:String) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._811554151TypeVal;
         if(_loc2_ !== param1)
         {
            this._811554151TypeVal = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TypeVal",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get tpiToolTip() : String
      {
         return this._1238837686tpiToolTip;
      }
      
      private function set tpiToolTip(param1:String) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1238837686tpiToolTip;
         if(_loc2_ !== param1)
         {
            this._1238837686tpiToolTip = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tpiToolTip",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get DRAWING_TEXT_COLOR() : uint
      {
         return this._696306834DRAWING_TEXT_COLOR;
      }
      
      private function set DRAWING_TEXT_COLOR(param1:uint) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._696306834DRAWING_TEXT_COLOR;
         if(_loc2_ !== param1)
         {
            this._696306834DRAWING_TEXT_COLOR = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DRAWING_TEXT_COLOR",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get threadReference() : String
      {
         return this._795181983threadReference;
      }
      
      private function set threadReference(param1:String) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._795181983threadReference;
         if(_loc2_ !== param1)
         {
            this._795181983threadReference = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"threadReference",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get nominalSize() : Number
      {
         return this._153636605nominalSize;
      }
      
      private function set nominalSize(param1:Number) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._153636605nominalSize;
         if(_loc2_ !== param1)
         {
            this._153636605nominalSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"nominalSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get customTPI() : Number
      {
         return this._1611544636customTPI;
      }
      
      private function set customTPI(param1:Number) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1611544636customTPI;
         if(_loc2_ !== param1)
         {
            this._1611544636customTPI = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"customTPI",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get designation() : String
      {
         return this._900931593designation;
      }
      
      private function set designation(param1:String) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._900931593designation;
         if(_loc2_ !== param1)
         {
            this._900931593designation = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"designation",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get intExtTitleBinder() : String
      {
         return this._1225950992intExtTitleBinder;
      }
      
      private function set intExtTitleBinder(param1:String) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1225950992intExtTitleBinder;
         if(_loc2_ !== param1)
         {
            this._1225950992intExtTitleBinder = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"intExtTitleBinder",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get bestSizeMOW() : Number
      {
         return this._301688624bestSizeMOW;
      }
      
      private function set bestSizeMOW(param1:Number) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._301688624bestSizeMOW;
         if(_loc2_ !== param1)
         {
            this._301688624bestSizeMOW = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bestSizeMOW",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get minSizeMOW() : Number
      {
         return this._1456492706minSizeMOW;
      }
      
      private function set minSizeMOW(param1:Number) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1456492706minSizeMOW;
         if(_loc2_ !== param1)
         {
            this._1456492706minSizeMOW = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"minSizeMOW",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get maxSizeMOW() : Number
      {
         return this._1015506608maxSizeMOW;
      }
      
      private function set maxSizeMOW(param1:Number) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1015506608maxSizeMOW;
         if(_loc2_ !== param1)
         {
            this._1015506608maxSizeMOW = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"maxSizeMOW",_loc2_,param1));
            }
         }
      }
   }
}
