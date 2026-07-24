package feedsspeeds
{
   import comps.GWizFileBrowser;
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import utils.GWizCSVUtils;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizFSCruncher extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizFSCruncher");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1112857018EndMillsInch:CheckBox;
      
      private var _1011212676EndMillsMM:CheckBox;
      
      private var _1446716767TwistDrills:CheckBox;
      
      public var _GWizFSCruncher_Label15:Label;
      
      public var _GWizFSCruncher_Label4:Label;
      
      public var _GWizFSCruncher_Label6:Label;
      
      public var _GWizFSCruncher_Label8:Label;
      
      public var _GWizFSCruncher_Spacer1:Spacer;
      
      public var _GWizFSCruncher_Spacer3:Spacer;
      
      public var _GWizFSCruncher_Spacer4:Spacer;
      
      public var _GWizFSCruncher_Spacer5:Spacer;
      
      public var _GWizFSCruncher_Spacer6:Spacer;
      
      public var _GWizFSCruncher_Spacer7:Spacer;
      
      public var _GWizFSCruncher_Spacer8:Spacer;
      
      private var _199415820depthCount:GWizNumStep;
      
      private var _1967056182depthFinish:GWizNumStep;
      
      private var _214322015depthStart:GWizNumStep;
      
      private var _247574575diaFinish:GWizNumStep;
      
      private var _256787130diaStart:GWizNumStep;
      
      private var _3361042msgs:TextArea;
      
      private var _1613111575widthCount:GWizNumStep;
      
      private var _1613281785widthFinish:GWizNumStep;
      
      private var _1598205380widthStart:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var cruncherFiles:GWizFileBrowser;
      
      private var FSCruncherReqdFields:Array;
      
      private var scenarioFile:File;
      
      private var nextScenario:int;
      
      private var scenarios:ArrayCollection;
      
      private var scenarioErrors:int;
      
      private var startTime:Date;
      
      private const SPACER_WD:int = 100;
      
      private var toolDias:ArrayCollection;
      
      private var machine:String;
      
      private var material:String;
      
      private var tool:String;
      
      private var flutes:int;
      
      private var widthIncr:Number;
      
      private var depthIncr:Number;
      
      private var todoList:Array;
      
      public var fileBrowser:GWizFileBrowser;
      
      private var _1748193281totalScenarios:Number = 0;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizFSCruncher()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.FSCruncherReqdFields = ["Material","Alloy","Machine","Tool","Slider","ToolDia","Flutes","CutDepth","CutWidth","HSM","Error","RPM","Feedrate","HP","MRR","DeflectPct","SFM","IPT","Notes"];
         this.toolDias = new ArrayCollection();
         this.todoList = [];
         this.fileBrowser = new GWizFileBrowser("Scenarios","CSV","*.csv");
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizFSCruncher_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizFSCruncherWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizFSCruncher[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Feeds / Speeds Cruncher";
         this.fullScreen = true;
         this.okLabel = "Quit";
         this.cancelLabel = "";
         this.mxmlContent = [this._GWizFSCruncher_VGroup1_c()];
         this.addEventListener("click",this.___GWizFSCruncher_GWizPopUp1_click);
         this.addEventListener("keyUp",this.___GWizFSCruncher_GWizPopUp1_keyUp);
         this.addEventListener("creationComplete",this.___GWizFSCruncher_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function newFSCruncher() : GWizFSCruncher
      {
         var _loc1_:GWizFSCruncher = null;
         if(GWizUtils.debug)
         {
            _loc1_ = GWizFSCruncher(GWizPopUpManager.createPopUp(null,GWizFSCruncher,true));
         }
         return _loc1_;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizFSCruncher._watcherSetupUtil = param1;
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
      
      private function onCC() : void
      {
         this.cruncherFiles = new GWizFileBrowser("FS Library","FS Library","*.csv");
         this.recalc();
      }
      
      private function doBrowse() : void
      {
         this.cruncherFiles.doFileOpen(this.importScenarios,"Import Scenarios");
      }
      
      private function importScenarios(param1:File) : void
      {
         var ac:ArrayCollection = null;
         var f:File = param1;
         try
         {
            ac = GWizCSVUtils.loadCSVFile(f,true,true,this.FSCruncherReqdFields);
            this.crunchScenarios(ac,f);
         }
         catch(e:Error)
         {
            log.debug("Error loading Feeds/Speeds scenarios: " + e.errorID + ", msg = " + e.message);
         }
      }
      
      private function crunchScenarios(param1:ArrayCollection, param2:File) : void
      {
         this.scenarioFile = param2;
         this.nextScenario = 0;
         this.scenarios = param1;
         this.scenarioErrors = 0;
         this.msgs.text = "";
         this.startTime = new Date();
         this.msgs.text = this.scenarios.length + " scenarios to process.\n\n";
         var _loc3_:GWizJustASec = new GWizJustASec(this.crunchScenariosAux,-1);
      }
      
      private function crunchScenariosAux() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:GWizJustASec = null;
         var _loc4_:Object = null;
         if(this.scenarios)
         {
            if(this.nextScenario >= this.scenarios.length)
            {
               this.writeResults(this.scenarios,this.scenarioFile);
            }
            else
            {
               this.msgs.text += "Beginning scenario #" + this.nextScenario + "\n";
               this.msgs.scrollToRange(this.msgs.text.length - 1,this.msgs.text.length - 1);
               _loc1_ = 200;
               _loc2_ = 0;
               while(this.nextScenario < this.scenarios.length && _loc2_ < _loc1_)
               {
                  _loc4_ = this.scenarios.getItemAt(this.nextScenario);
                  this.doScenario(_loc4_);
                  _loc2_++;
                  ++this.nextScenario;
               }
               _loc3_ = new GWizJustASec(this.crunchScenariosAux,-1);
            }
         }
      }
      
      private function doScenario(param1:Object) : void
      {
         var _loc2_:Number = param1.CutDepth + param1.ToolDia;
         GWizSettings.FeedsSpeedsApp.api.SetupUI(param1.Machine,param1.Material,"",param1.Tool,param1.ToolDia,param1.Flutes,_loc2_,param1.CutDepth,param1.CutWidth,true,param1.HSM,false,false,param1.Slider,false);
         param1.Error = 0;
         if(param1.Error != 0)
         {
            ++this.scenarioErrors;
         }
         param1.Notes = GWizSettings.FeedsSpeedsApp.api.cuttingErr();
         param1.RPM = GWizSettings.FeedsSpeedsApp.api.getRPM();
         param1.Feedrate = GWizSettings.FeedsSpeedsApp.api.getFeed();
         param1.HP = GWizSettings.FeedsSpeedsApp.fsm.hp;
         param1.MRR = GWizSettings.FeedsSpeedsApp.fsm.mrr;
         param1.DeflectPct = GWizSettings.FeedsSpeedsApp.deflectTempSlider.value;
         param1.SFM = GWizSettings.FeedsSpeedsApp.SFM.value;
         param1.IPT = GWizSettings.FeedsSpeedsApp.IPT.value;
      }
      
      private function writeResults(param1:ArrayCollection, param2:File) : void
      {
         var _loc3_:Date = new Date();
         var _loc4_:Number = (_loc3_.valueOf() - this.startTime.valueOf()) / 1000;
         if(!param1 || param1.length == 0)
         {
            this.msgs.text += "\n\nError: No scenarios were processed.";
         }
         else
         {
            GWizUtils.assert(param2 != null);
            this.msgs.text += "\n\n" + param1.length + " scenarios processed. " + this.scenarioErrors + " errors.";
            this.msgs.text += "Elapsed time " + _loc4_ + " = " + param1.length / _loc4_ + " scenarios/second.\n";
            GWizCSVUtils.saveCSVFile(param2,param1,this.FSCruncherReqdFields);
         }
      }
      
      private function createScenariosAux() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         if(this.todoList.length > 0)
         {
            _loc1_ = this.todoList.pop();
            this.widthIncr = Math.max(this.widthIncr,0.0001);
            this.depthIncr = Math.max(this.widthIncr,0.0001);
            _loc2_ = this.widthStart.value;
            while(_loc2_ <= this.widthFinish.value)
            {
               _loc3_ = this.depthStart.value;
               while(_loc3_ <= this.depthFinish.value)
               {
                  _loc4_ = 0;
                  while(_loc4_ < 2)
                  {
                     (_loc5_ = new Object()).Material = this.material;
                     _loc5_.Alloy = "";
                     _loc5_.Machine = this.machine;
                     _loc5_.Tool = this.tool;
                     _loc5_.Slider = 100;
                     _loc5_.ToolDia = _loc1_;
                     _loc5_.Flutes = this.flutes;
                     _loc5_.CutDepth = _loc3_ * _loc1_;
                     _loc5_.CutWidth = _loc2_ * _loc1_;
                     _loc5_.HSM = _loc4_ > 0;
                     _loc5_.Error = 0;
                     _loc5_.RPM = 0;
                     _loc5_.Feedrate = 0;
                     _loc5_.Notes = "";
                     this.scenarios.addItem(_loc5_);
                     _loc4_++;
                  }
                  _loc3_ += this.depthIncr;
               }
               _loc2_ += this.widthIncr;
            }
            this.msgs.text += ".";
            this.callLater(this.createScenariosAux);
         }
         else
         {
            this.msgs.text += "\n\n";
            this.crunchScenarios(this.scenarios,this.scenarioFile);
         }
      }
      
      private function createScenariosFileSelected(param1:File) : void
      {
         var _loc3_:Number = NaN;
         this.scenarioFile = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this.toolDias.length)
         {
            _loc3_ = this.toolDias.getItemAt(_loc2_).diameter;
            this.todoList.push(_loc3_);
            _loc2_++;
         }
         this.createScenariosAux();
      }
      
      private function createScenarios() : void
      {
         this.machine = GWizMachSettings.currMachine;
         this.material = GWizSettings.FeedsSpeedsApp.mms.MatChooser.getMaterialLabel();
         this.tool = GWizSettings.FeedsSpeedsApp.Tool.selectedLabel;
         this.flutes = GWizSettings.FeedsSpeedsApp.td.toolParms.flutes;
         this.widthIncr = (this.widthFinish.value - this.widthStart.value) / this.widthCount.value;
         this.depthIncr = (this.depthFinish.value - this.depthStart.value) / this.depthCount.value;
         this.toolDias = this.genToolDiameters(this.diaStart.value,this.diaFinish.value,this.TwistDrills.selected,this.EndMillsInch.selected,this.EndMillsMM.selected);
         this.scenarios = new ArrayCollection();
         this.todoList = [];
         this.msgs.text = "Generating scenarios: ";
         this.fileBrowser.doFileSaveAs(this.createScenariosFileSelected,"Save","FSCruncher");
      }
      
      private function scenarioGenerator() : void
      {
         this.createScenarios();
      }
      
      private function recalc() : void
      {
         this.toolDias = this.genToolDiameters(this.diaStart.value,this.diaFinish.value,this.TwistDrills.selected,this.EndMillsInch.selected,this.EndMillsMM.selected);
         this.totalScenarios = this.toolDias.length * this.depthCount.value * this.widthCount.value * 2;
      }
      
      private function genToolDiameters(param1:Number, param2:Number, param3:Boolean, param4:Boolean, param5:Boolean) : ArrayCollection
      {
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         this.toolDias.removeAll();
         var _loc6_:int = 0;
         while(_loc6_ < GWizConfigData.DrillData.length)
         {
            if((_loc7_ = GWizConfigData.DrillData.getItemAt(_loc6_)).inch >= param1 && _loc7_.inch <= param2)
            {
               if(param3 && _loc7_.td > 0 || param4 && _loc7_.eminch > 0 || param5 && _loc7_.emmm > 0)
               {
                  (_loc8_ = new Object()).diameter = _loc7_.inch;
                  this.toolDias.addItem(_loc8_);
               }
            }
            _loc6_++;
         }
         return this.toolDias;
      }
      
      private function _GWizFSCruncher_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizFSCruncher_GWizForePanel1_c(),this._GWizFSCruncher_GWizForePanel2_c(),this._GWizFSCruncher_GWizForePanel3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Scenario File";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFSCruncher_Array3_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Array3_c() : Array
      {
         return [this._GWizFSCruncher_VGroup2_c()];
      }
      
      private function _GWizFSCruncher_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizFSCruncher_HGroup1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFSCruncher_Label1_c(),this._GWizFSCruncher_Button1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Browse for a file containing scenarios to run and run them:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Browse...";
         _loc1_.addEventListener("click",this.___GWizFSCruncher_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizFSCruncher_Button1_click(param1:MouseEvent) : void
      {
         this.doBrowse();
      }
      
      private function _GWizFSCruncher_GWizForePanel2_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Scenario Generator";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFSCruncher_Array6_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Array6_c() : Array
      {
         return [this._GWizFSCruncher_VGroup3_c()];
      }
      
      private function _GWizFSCruncher_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizFSCruncher_Label2_c(),this._GWizFSCruncher_HGroup2_c(),this._GWizFSCruncher_Label9_c(),this._GWizFSCruncher_Label10_c(),this._GWizFSCruncher_HGroup6_c(),this._GWizFSCruncher_HGroup7_c(),this._GWizFSCruncher_Label12_c(),this._GWizFSCruncher_HGroup8_c(),this._GWizFSCruncher_HGroup9_c(),this._GWizFSCruncher_Label13_c(),this._GWizFSCruncher_Label14_c(),this._GWizFSCruncher_Label15_i(),this._GWizFSCruncher_Label16_c(),this._GWizFSCruncher_Button2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Set these parameters from Feeds / Speeds tab:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFSCruncher_HGroup3_c(),this._GWizFSCruncher_HGroup4_c(),this._GWizFSCruncher_HGroup5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 33;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFSCruncher_Label3_c(),this._GWizFSCruncher_Label4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Machine: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizFSCruncher_Label4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Label4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Label4",this._GWizFSCruncher_Label4);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 33;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFSCruncher_Label5_c(),this._GWizFSCruncher_Label6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Material:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizFSCruncher_Label6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Label6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Label6",this._GWizFSCruncher_Label6);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 33;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFSCruncher_Label7_c(),this._GWizFSCruncher_Label8_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tool:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizFSCruncher_Label8";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Label8 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Label8",this._GWizFSCruncher_Label8);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Scenario Variables:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFSCruncher_GWizNumStep1_i(),this._GWizFSCruncher_Spacer1_i(),this._GWizFSCruncher_GWizNumStep2_i(),this._GWizFSCruncher_Spacer2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Tool Dia - Start:";
         _loc1_.min = 0.001;
         _loc1_.max = 6;
         _loc1_.steps = 0.001;
         _loc1_.percentWidth = 33;
         _loc1_.value = 0.125;
         _loc1_.id = "diaStart";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.diaStart = _loc1_;
         BindingManager.executeBindings(this,"diaStart",this.diaStart);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Spacer1_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizFSCruncher_Spacer1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Spacer1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Spacer1",this._GWizFSCruncher_Spacer1);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Finish:";
         _loc1_.percentWidth = 33;
         _loc1_.min = 0.001;
         _loc1_.max = 6;
         _loc1_.steps = 0.001;
         _loc1_.value = 0.125;
         _loc1_.id = "diaFinish";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.diaFinish = _loc1_;
         BindingManager.executeBindings(this,"diaFinish",this.diaFinish);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFSCruncher_Label11_c(),this._GWizFSCruncher_CheckBox1_i(),this._GWizFSCruncher_CheckBox2_i(),this._GWizFSCruncher_CheckBox3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label11_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "    Std Sizes for: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Twist Drills";
         _loc1_.selected = false;
         _loc1_.id = "TwistDrills";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TwistDrills = _loc1_;
         BindingManager.executeBindings(this,"TwistDrills",this.TwistDrills);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "End Mills (Imperial)";
         _loc1_.selected = true;
         _loc1_.id = "EndMillsInch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EndMillsInch = _loc1_;
         BindingManager.executeBindings(this,"EndMillsInch",this.EndMillsInch);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_CheckBox3_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "End Mills (Metric)";
         _loc1_.selected = false;
         _loc1_.id = "EndMillsMM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EndMillsMM = _loc1_;
         BindingManager.executeBindings(this,"EndMillsMM",this.EndMillsMM);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFSCruncher_GWizNumStep3_i(),this._GWizFSCruncher_Spacer3_i(),this._GWizFSCruncher_GWizNumStep4_i(),this._GWizFSCruncher_Spacer4_i(),this._GWizFSCruncher_GWizNumStep5_i(),this._GWizFSCruncher_Spacer5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Cut Depth - Start:";
         _loc1_.max = 10;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 33;
         _loc1_.value = 0.05;
         _loc1_.id = "depthStart";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.depthStart = _loc1_;
         BindingManager.executeBindings(this,"depthStart",this.depthStart);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Spacer3_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizFSCruncher_Spacer3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Spacer3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Spacer3",this._GWizFSCruncher_Spacer3);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Finish:";
         _loc1_.max = 10;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 33;
         _loc1_.value = 2;
         _loc1_.id = "depthFinish";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.depthFinish = _loc1_;
         BindingManager.executeBindings(this,"depthFinish",this.depthFinish);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Spacer4_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizFSCruncher_Spacer4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Spacer4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Spacer4",this._GWizFSCruncher_Spacer4);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Count:";
         _loc1_.percentWidth = 33;
         _loc1_.usesMetric = false;
         _loc1_.value = 40;
         _loc1_.id = "depthCount";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.depthCount = _loc1_;
         BindingManager.executeBindings(this,"depthCount",this.depthCount);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Spacer5_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizFSCruncher_Spacer5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Spacer5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Spacer5",this._GWizFSCruncher_Spacer5);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_HGroup9_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFSCruncher_GWizNumStep6_i(),this._GWizFSCruncher_Spacer6_i(),this._GWizFSCruncher_GWizNumStep7_i(),this._GWizFSCruncher_Spacer7_i(),this._GWizFSCruncher_GWizNumStep8_i(),this._GWizFSCruncher_Spacer8_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_GWizNumStep6_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Cut Width - Start:";
         _loc1_.max = 1;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 33;
         _loc1_.value = 0.05;
         _loc1_.id = "widthStart";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.widthStart = _loc1_;
         BindingManager.executeBindings(this,"widthStart",this.widthStart);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Spacer6_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizFSCruncher_Spacer6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Spacer6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Spacer6",this._GWizFSCruncher_Spacer6);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_GWizNumStep7_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Finish:";
         _loc1_.max = 1;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 33;
         _loc1_.value = 1;
         _loc1_.id = "widthFinish";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.widthFinish = _loc1_;
         BindingManager.executeBindings(this,"widthFinish",this.widthFinish);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Spacer7_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizFSCruncher_Spacer7";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Spacer7 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Spacer7",this._GWizFSCruncher_Spacer7);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_GWizNumStep8_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Count:";
         _loc1_.percentWidth = 33;
         _loc1_.usesMetric = false;
         _loc1_.value = 20;
         _loc1_.id = "widthCount";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.widthCount = _loc1_;
         BindingManager.executeBindings(this,"widthCount",this.widthCount);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Spacer8_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizFSCruncher_Spacer8";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Spacer8 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Spacer8",this._GWizFSCruncher_Spacer8);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cut Depth and Cut Width are in tool diameters.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label14_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizFSCruncher_Label15";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSCruncher_Label15 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSCruncher_Label15",this._GWizFSCruncher_Label15);
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Label16_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Create File...";
         _loc1_.toolTip = "Create and run a scenario file.  You will be prompted for the file name and folder.";
         _loc1_.addEventListener("click",this.___GWizFSCruncher_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizFSCruncher_Button2_click(param1:MouseEvent) : void
      {
         this.scenarioGenerator();
      }
      
      private function _GWizFSCruncher_GWizForePanel3_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Status";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFSCruncher_Array16_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSCruncher_Array16_c() : Array
      {
         return [this._GWizFSCruncher_TextArea1_i()];
      }
      
      private function _GWizFSCruncher_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "msgs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msgs = _loc1_;
         BindingManager.executeBindings(this,"msgs",this.msgs);
         return _loc1_;
      }
      
      public function ___GWizFSCruncher_GWizPopUp1_click(param1:MouseEvent) : void
      {
         this.recalc();
      }
      
      public function ___GWizFSCruncher_GWizPopUp1_keyUp(param1:KeyboardEvent) : void
      {
         this.recalc();
      }
      
      public function ___GWizFSCruncher_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizFSCruncher_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():String
         {
            var _loc1_:* = GWizMachSettings.currMachine;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizFSCruncher_Label4.text");
         result[1] = new Binding(this,function():String
         {
            var _loc1_:* = GWizSettings.FeedsSpeedsApp.mms.MatChooser.getMaterialLabel();
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizFSCruncher_Label6.text");
         result[2] = new Binding(this,function():String
         {
            var _loc1_:* = GWizSettings.FeedsSpeedsApp.Tool.selectedLabel;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizFSCruncher_Label8.text");
         result[3] = new Binding(this,function():Number
         {
            return SPACER_WD;
         },null,"_GWizFSCruncher_Spacer1.width");
         result[4] = new Binding(this,function():Number
         {
            return SPACER_WD;
         },null,"_GWizFSCruncher_Spacer3.width");
         result[5] = new Binding(this,function():Number
         {
            return SPACER_WD;
         },null,"_GWizFSCruncher_Spacer4.width");
         result[6] = new Binding(this,function():Number
         {
            return SPACER_WD;
         },null,"_GWizFSCruncher_Spacer5.width");
         result[7] = new Binding(this,function():Number
         {
            return SPACER_WD;
         },null,"_GWizFSCruncher_Spacer6.width");
         result[8] = new Binding(this,function():Number
         {
            return SPACER_WD;
         },null,"_GWizFSCruncher_Spacer7.width");
         result[9] = new Binding(this,function():Number
         {
            return SPACER_WD;
         },null,"_GWizFSCruncher_Spacer8.width");
         result[10] = new Binding(this,function():String
         {
            var _loc1_:* = totalScenarios + " total scenarios.";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizFSCruncher_Label15.text");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get EndMillsInch() : CheckBox
      {
         return this._1112857018EndMillsInch;
      }
      
      public function set EndMillsInch(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1112857018EndMillsInch;
         if(_loc2_ !== param1)
         {
            this._1112857018EndMillsInch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EndMillsInch",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EndMillsMM() : CheckBox
      {
         return this._1011212676EndMillsMM;
      }
      
      public function set EndMillsMM(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1011212676EndMillsMM;
         if(_loc2_ !== param1)
         {
            this._1011212676EndMillsMM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EndMillsMM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TwistDrills() : CheckBox
      {
         return this._1446716767TwistDrills;
      }
      
      public function set TwistDrills(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1446716767TwistDrills;
         if(_loc2_ !== param1)
         {
            this._1446716767TwistDrills = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TwistDrills",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get depthCount() : GWizNumStep
      {
         return this._199415820depthCount;
      }
      
      public function set depthCount(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._199415820depthCount;
         if(_loc2_ !== param1)
         {
            this._199415820depthCount = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"depthCount",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get depthFinish() : GWizNumStep
      {
         return this._1967056182depthFinish;
      }
      
      public function set depthFinish(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1967056182depthFinish;
         if(_loc2_ !== param1)
         {
            this._1967056182depthFinish = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"depthFinish",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get depthStart() : GWizNumStep
      {
         return this._214322015depthStart;
      }
      
      public function set depthStart(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._214322015depthStart;
         if(_loc2_ !== param1)
         {
            this._214322015depthStart = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"depthStart",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get diaFinish() : GWizNumStep
      {
         return this._247574575diaFinish;
      }
      
      public function set diaFinish(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._247574575diaFinish;
         if(_loc2_ !== param1)
         {
            this._247574575diaFinish = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"diaFinish",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get diaStart() : GWizNumStep
      {
         return this._256787130diaStart;
      }
      
      public function set diaStart(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._256787130diaStart;
         if(_loc2_ !== param1)
         {
            this._256787130diaStart = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"diaStart",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get msgs() : TextArea
      {
         return this._3361042msgs;
      }
      
      public function set msgs(param1:TextArea) : void
      {
         var _loc2_:Object = this._3361042msgs;
         if(_loc2_ !== param1)
         {
            this._3361042msgs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"msgs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get widthCount() : GWizNumStep
      {
         return this._1613111575widthCount;
      }
      
      public function set widthCount(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1613111575widthCount;
         if(_loc2_ !== param1)
         {
            this._1613111575widthCount = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"widthCount",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get widthFinish() : GWizNumStep
      {
         return this._1613281785widthFinish;
      }
      
      public function set widthFinish(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1613281785widthFinish;
         if(_loc2_ !== param1)
         {
            this._1613281785widthFinish = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"widthFinish",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get widthStart() : GWizNumStep
      {
         return this._1598205380widthStart;
      }
      
      public function set widthStart(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1598205380widthStart;
         if(_loc2_ !== param1)
         {
            this._1598205380widthStart = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"widthStart",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get totalScenarios() : Number
      {
         return this._1748193281totalScenarios;
      }
      
      private function set totalScenarios(param1:Number) : void
      {
         var _loc2_:Object = this._1748193281totalScenarios;
         if(_loc2_ !== param1)
         {
            this._1748193281totalScenarios = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"totalScenarios",_loc2_,param1));
            }
         }
      }
   }
}
