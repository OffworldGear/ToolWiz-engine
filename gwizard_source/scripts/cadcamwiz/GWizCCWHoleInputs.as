package cadcamwiz
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.ProgressBar;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizCCWHoleInputs extends GWizForePanel implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1255845772CarbideTool:RadioButton;
      
      private var _1891401086Chamfer:CheckBox;
      
      private var _1694614947ChamferSize:GWizNumStep;
      
      private var _2029744673CutTap:RadioButton;
      
      private var _65919651Depth:GWizNumStep;
      
      private var _987196447FormTap:RadioButton;
      
      private var _1931240032HSSTool:RadioButton;
      
      private var _1538558084HoleDia:GWizNumStep;
      
      private var _1029095891HoleOpsGrp:HGroup;
      
      private var _342720287Interpolate:CheckBox;
      
      private var _1355219513ProgBar:ProgressBar;
      
      private var _2543039Ream:CheckBox;
      
      private var _1047339097SpotDrill:CheckBox;
      
      private var _808283494ThreadMill:RadioButton;
      
      private var _710237386ThreadPitch:GWizNumStep;
      
      private var _808497890ThreadTool:RadioButtonGroup;
      
      private var _1888060887ThreadToolMaterial:RadioButtonGroup;
      
      private var _441742712Threading:CheckBox;
      
      private var _1588608769finishPassGrp:GWizCCWFinishPassGrp;
      
      private var _1350774646theIcon:Image;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var recalc:Function = null;
      
      public var interpOptionsFcn:Function = null;
      
      private var _1683435737millHoleImg:Class;
      
      private var _919607399latheHoleImg:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWHoleInputs()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1683435737millHoleImg = GWizCCWHoleInputs_millHoleImg;
         this._919607399latheHoleImg = GWizCCWHoleInputs_latheHoleImg;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWHoleInputs_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWHoleInputsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWHoleInputs[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Inputs";
         this.percentWidth = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWHoleInputs_Array1_c);
         this._GWizCCWHoleInputs_RadioButtonGroup1_i();
         this._GWizCCWHoleInputs_RadioButtonGroup2_i();
         this.addEventListener("creationComplete",this.___GWizCCWHoleInputs_GWizForePanel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWHoleInputs._watcherSetupUtil = param1;
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
         if(GWizMachSettings.currMachType == "Lathe")
         {
            this.Interpolate.visible = false;
            this.Interpolate.includeInLayout = false;
            this.Interpolate.selected = false;
            this.theIcon.source = this.latheHoleImg;
         }
      }
      
      private function threadingChange() : void
      {
         if(this.ThreadMill.selected)
         {
            this.CarbideTool.selected = true;
            this.ThreadPitch.titleTxt = "Thread Depth";
            this.ThreadPitch.toolTip = "Thread Depth is the difference between Major and Minor Diameter.";
         }
         else
         {
            this.ThreadPitch.titleTxt = "Thread Pitch";
            this.ThreadPitch.toolTip = "Thread Pitch can be looked up on the Threads tab, or do the math here by entering 1 / TPI <Enter>.";
         }
         this.CarbideTool.enabled = this.Threading.selected && !this.ThreadMill.selected;
         this.HSSTool.enabled = this.CarbideTool.enabled;
      }
      
      private function _GWizCCWHoleInputs_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"ThreadTool");
         this.ThreadTool = _loc1_;
         BindingManager.executeBindings(this,"ThreadTool",this.ThreadTool);
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_RadioButtonGroup2_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"ThreadToolMaterial");
         this.ThreadToolMaterial = _loc1_;
         BindingManager.executeBindings(this,"ThreadToolMaterial",this.ThreadToolMaterial);
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_Array1_c() : Array
      {
         return [this._GWizCCWHoleInputs_VGroup1_c(),this._GWizCCWHoleInputs_VGroup2_c()];
      }
      
      private function _GWizCCWHoleInputs_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWHoleInputs_HGroup1_c(),this._GWizCCWHoleInputs_HGroup2_i(),this._GWizCCWHoleInputs_HGroup3_c(),this._GWizCCWHoleInputs_HGroup4_c(),this._GWizCCWHoleInputs_ProgressBar1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWHoleInputs_Label1_c(),this._GWizCCWHoleInputs_GWizNumStep1_i(),this._GWizCCWHoleInputs_Label2_c(),this._GWizCCWHoleInputs_GWizNumStep2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole Diameter:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.stepBySizes = true;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__HoleDia_initialize);
         _loc1_.addEventListener("change",this.__HoleDia_change);
         _loc1_.id = "HoleDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HoleDia = _loc1_;
         BindingManager.executeBindings(this,"HoleDia",this.HoleDia);
         return _loc1_;
      }
      
      public function __HoleDia_initialize(param1:FlexEvent) : void
      {
         this.HoleDia.setVal(0.125);
      }
      
      public function __HoleDia_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Depth:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__Depth_initialize);
         _loc1_.addEventListener("change",this.__Depth_change);
         _loc1_.id = "Depth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Depth = _loc1_;
         BindingManager.executeBindings(this,"Depth",this.Depth);
         return _loc1_;
      }
      
      public function __Depth_initialize(param1:FlexEvent) : void
      {
         this.Depth.setVal(0.25);
      }
      
      public function __Depth_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_HGroup2_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWHoleInputs_Label3_c(),this._GWizCCWHoleInputs_CheckBox1_i(),this._GWizCCWHoleInputs_CheckBox2_i(),this._GWizCCWHoleInputs_GWizNumStep3_i(),this._GWizCCWHoleInputs_CheckBox3_i()];
         _loc1_.id = "HoleOpsGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HoleOpsGrp = _loc1_;
         BindingManager.executeBindings(this,"HoleOpsGrp",this.HoleOpsGrp);
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole Ops: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Spot Drill  ";
         _loc1_.addEventListener("change",this.__SpotDrill_change);
         _loc1_.id = "SpotDrill";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SpotDrill = _loc1_;
         BindingManager.executeBindings(this,"SpotDrill",this.SpotDrill);
         return _loc1_;
      }
      
      public function __SpotDrill_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Chamfer (w/ Spot Drill)";
         _loc1_.addEventListener("change",this.__Chamfer_change);
         _loc1_.id = "Chamfer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Chamfer = _loc1_;
         BindingManager.executeBindings(this,"Chamfer",this.Chamfer);
         return _loc1_;
      }
      
      public function __Chamfer_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Chaf. Sz:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.addEventListener("initialize",this.__ChamferSize_initialize);
         _loc1_.addEventListener("change",this.__ChamferSize_change);
         _loc1_.id = "ChamferSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ChamferSize = _loc1_;
         BindingManager.executeBindings(this,"ChamferSize",this.ChamferSize);
         return _loc1_;
      }
      
      public function __ChamferSize_initialize(param1:FlexEvent) : void
      {
         this.ChamferSize.setVal(0.01);
      }
      
      public function __ChamferSize_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_CheckBox3_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Ream (Use Reamer\'s diameter)";
         _loc1_.toolTip = "Ream the hole. Enter Reamer\'s diameter for hole diameter and let the Wizard choose the drill size.";
         _loc1_.addEventListener("change",this.__Ream_change);
         _loc1_.id = "Ream";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Ream = _loc1_;
         BindingManager.executeBindings(this,"Ream",this.Ream);
         return _loc1_;
      }
      
      public function __Ream_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "baseline";
         _loc1_.mxmlContent = [this._GWizCCWHoleInputs_CheckBox4_i(),this._GWizCCWHoleInputs_GWizCCWFinishPassGrp1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_CheckBox4_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Interpolate";
         _loc1_.toolTip = "Interpolate the hole with an endmill.";
         _loc1_.addEventListener("change",this.__Interpolate_change);
         _loc1_.id = "Interpolate";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Interpolate = _loc1_;
         BindingManager.executeBindings(this,"Interpolate",this.Interpolate);
         return _loc1_;
      }
      
      public function __Interpolate_change(param1:Event) : void
      {
         this.interpOptionsFcn();
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_GWizCCWFinishPassGrp1_i() : GWizCCWFinishPassGrp
      {
         var _loc1_:GWizCCWFinishPassGrp = new GWizCCWFinishPassGrp();
         _loc1_.recalc = this.recalc;
         _loc1_.id = "finishPassGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.finishPassGrp = _loc1_;
         BindingManager.executeBindings(this,"finishPassGrp",this.finishPassGrp);
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWHoleInputs_CheckBox5_i(),this._GWizCCWHoleInputs_RadioButton1_i(),this._GWizCCWHoleInputs_RadioButton2_i(),this._GWizCCWHoleInputs_RadioButton3_i(),this._GWizCCWHoleInputs_Spacer1_c(),this._GWizCCWHoleInputs_RadioButton4_i(),this._GWizCCWHoleInputs_RadioButton5_i(),this._GWizCCWHoleInputs_Spacer2_c(),this._GWizCCWHoleInputs_GWizNumStep4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_CheckBox5_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Threading";
         _loc1_.toolTip = "Thread with tap or thread mill.";
         _loc1_.addEventListener("change",this.__Threading_change);
         _loc1_.addEventListener("valueCommit",this.__Threading_valueCommit);
         _loc1_.id = "Threading";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Threading = _loc1_;
         BindingManager.executeBindings(this,"Threading",this.Threading);
         return _loc1_;
      }
      
      public function __Threading_change(param1:Event) : void
      {
         this.recalc();
      }
      
      public function __Threading_valueCommit(param1:FlexEvent) : void
      {
         this.threadingChange();
      }
      
      private function _GWizCCWHoleInputs_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Cut Tap";
         _loc1_.selected = true;
         _loc1_.addEventListener("valueCommit",this.__CutTap_valueCommit);
         _loc1_.addEventListener("change",this.__CutTap_change);
         _loc1_.id = "CutTap";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CutTap = _loc1_;
         BindingManager.executeBindings(this,"CutTap",this.CutTap);
         return _loc1_;
      }
      
      public function __CutTap_valueCommit(param1:FlexEvent) : void
      {
         this.threadingChange();
      }
      
      public function __CutTap_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Form Tap";
         _loc1_.addEventListener("valueCommit",this.__FormTap_valueCommit);
         _loc1_.addEventListener("change",this.__FormTap_change);
         _loc1_.id = "FormTap";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FormTap = _loc1_;
         BindingManager.executeBindings(this,"FormTap",this.FormTap);
         return _loc1_;
      }
      
      public function __FormTap_valueCommit(param1:FlexEvent) : void
      {
         this.threadingChange();
      }
      
      public function __FormTap_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Thread Mill";
         _loc1_.addEventListener("valueCommit",this.__ThreadMill_valueCommit);
         _loc1_.addEventListener("change",this.__ThreadMill_change);
         _loc1_.id = "ThreadMill";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ThreadMill = _loc1_;
         BindingManager.executeBindings(this,"ThreadMill",this.ThreadMill);
         return _loc1_;
      }
      
      public function __ThreadMill_valueCommit(param1:FlexEvent) : void
      {
         this.threadingChange();
      }
      
      public function __ThreadMill_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_RadioButton4_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Carbide";
         _loc1_.addEventListener("valueCommit",this.__CarbideTool_valueCommit);
         _loc1_.addEventListener("change",this.__CarbideTool_change);
         _loc1_.id = "CarbideTool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CarbideTool = _loc1_;
         BindingManager.executeBindings(this,"CarbideTool",this.CarbideTool);
         return _loc1_;
      }
      
      public function __CarbideTool_valueCommit(param1:FlexEvent) : void
      {
         this.threadingChange();
      }
      
      public function __CarbideTool_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_RadioButton5_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "HSS";
         _loc1_.selected = true;
         _loc1_.addEventListener("valueCommit",this.__HSSTool_valueCommit);
         _loc1_.addEventListener("change",this.__HSSTool_change);
         _loc1_.id = "HSSTool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HSSTool = _loc1_;
         BindingManager.executeBindings(this,"HSSTool",this.HSSTool);
         return _loc1_;
      }
      
      public function __HSSTool_valueCommit(param1:FlexEvent) : void
      {
         this.threadingChange();
      }
      
      public function __HSSTool_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Thread Pitch";
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.001;
         _loc1_.value = 0.05;
         _loc1_.UnitLabel = "in";
         _loc1_.addEventListener("valueCommit",this.__ThreadPitch_valueCommit);
         _loc1_.addEventListener("change",this.__ThreadPitch_change);
         _loc1_.id = "ThreadPitch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ThreadPitch = _loc1_;
         BindingManager.executeBindings(this,"ThreadPitch",this.ThreadPitch);
         return _loc1_;
      }
      
      public function __ThreadPitch_valueCommit(param1:FlexEvent) : void
      {
         this.threadingChange();
      }
      
      public function __ThreadPitch_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWHoleInputs_ProgressBar1_i() : ProgressBar
      {
         var _loc1_:ProgressBar = new ProgressBar();
         _loc1_.visible = false;
         _loc1_.label = "Progress";
         _loc1_.id = "ProgBar";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ProgBar = _loc1_;
         BindingManager.executeBindings(this,"ProgBar",this.ProgBar);
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWHoleInputs_Image1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleInputs_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.setStyle("backgroundColor",15658734);
         _loc1_.id = "theIcon";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theIcon = _loc1_;
         BindingManager.executeBindings(this,"theIcon",this.theIcon);
         return _loc1_;
      }
      
      public function ___GWizCCWHoleInputs_GWizForePanel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCCWHoleInputs_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return Interpolate.selected;
         },null,"finishPassGrp.enabled");
         result[1] = new Binding(this,null,null,"CutTap.group","ThreadTool");
         result[2] = new Binding(this,function():Boolean
         {
            return Threading.selected;
         },null,"CutTap.enabled");
         result[3] = new Binding(this,null,null,"FormTap.group","ThreadTool");
         result[4] = new Binding(this,function():Boolean
         {
            return Threading.selected;
         },null,"FormTap.enabled");
         result[5] = new Binding(this,null,null,"ThreadMill.group","ThreadTool");
         result[6] = new Binding(this,function():Boolean
         {
            return Threading.selected;
         },null,"ThreadMill.enabled");
         result[7] = new Binding(this,null,null,"CarbideTool.group","ThreadToolMaterial");
         result[8] = new Binding(this,null,null,"HSSTool.group","ThreadToolMaterial");
         result[9] = new Binding(this,function():Boolean
         {
            return Threading.selected;
         },null,"ThreadPitch.enabled");
         result[10] = new Binding(this,function():Object
         {
            return millHoleImg;
         },null,"theIcon.source");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CarbideTool() : RadioButton
      {
         return this._1255845772CarbideTool;
      }
      
      public function set CarbideTool(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1255845772CarbideTool;
         if(_loc2_ !== param1)
         {
            this._1255845772CarbideTool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CarbideTool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Chamfer() : CheckBox
      {
         return this._1891401086Chamfer;
      }
      
      public function set Chamfer(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1891401086Chamfer;
         if(_loc2_ !== param1)
         {
            this._1891401086Chamfer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Chamfer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ChamferSize() : GWizNumStep
      {
         return this._1694614947ChamferSize;
      }
      
      public function set ChamferSize(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1694614947ChamferSize;
         if(_loc2_ !== param1)
         {
            this._1694614947ChamferSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ChamferSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CutTap() : RadioButton
      {
         return this._2029744673CutTap;
      }
      
      public function set CutTap(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2029744673CutTap;
         if(_loc2_ !== param1)
         {
            this._2029744673CutTap = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CutTap",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Depth() : GWizNumStep
      {
         return this._65919651Depth;
      }
      
      public function set Depth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._65919651Depth;
         if(_loc2_ !== param1)
         {
            this._65919651Depth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Depth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FormTap() : RadioButton
      {
         return this._987196447FormTap;
      }
      
      public function set FormTap(param1:RadioButton) : void
      {
         var _loc2_:Object = this._987196447FormTap;
         if(_loc2_ !== param1)
         {
            this._987196447FormTap = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FormTap",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HSSTool() : RadioButton
      {
         return this._1931240032HSSTool;
      }
      
      public function set HSSTool(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1931240032HSSTool;
         if(_loc2_ !== param1)
         {
            this._1931240032HSSTool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HSSTool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HoleDia() : GWizNumStep
      {
         return this._1538558084HoleDia;
      }
      
      public function set HoleDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1538558084HoleDia;
         if(_loc2_ !== param1)
         {
            this._1538558084HoleDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HoleDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HoleOpsGrp() : HGroup
      {
         return this._1029095891HoleOpsGrp;
      }
      
      public function set HoleOpsGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._1029095891HoleOpsGrp;
         if(_loc2_ !== param1)
         {
            this._1029095891HoleOpsGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HoleOpsGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Interpolate() : CheckBox
      {
         return this._342720287Interpolate;
      }
      
      public function set Interpolate(param1:CheckBox) : void
      {
         var _loc2_:Object = this._342720287Interpolate;
         if(_loc2_ !== param1)
         {
            this._342720287Interpolate = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Interpolate",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ProgBar() : ProgressBar
      {
         return this._1355219513ProgBar;
      }
      
      public function set ProgBar(param1:ProgressBar) : void
      {
         var _loc2_:Object = this._1355219513ProgBar;
         if(_loc2_ !== param1)
         {
            this._1355219513ProgBar = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ProgBar",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Ream() : CheckBox
      {
         return this._2543039Ream;
      }
      
      public function set Ream(param1:CheckBox) : void
      {
         var _loc2_:Object = this._2543039Ream;
         if(_loc2_ !== param1)
         {
            this._2543039Ream = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Ream",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SpotDrill() : CheckBox
      {
         return this._1047339097SpotDrill;
      }
      
      public function set SpotDrill(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1047339097SpotDrill;
         if(_loc2_ !== param1)
         {
            this._1047339097SpotDrill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SpotDrill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThreadMill() : RadioButton
      {
         return this._808283494ThreadMill;
      }
      
      public function set ThreadMill(param1:RadioButton) : void
      {
         var _loc2_:Object = this._808283494ThreadMill;
         if(_loc2_ !== param1)
         {
            this._808283494ThreadMill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThreadMill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThreadPitch() : GWizNumStep
      {
         return this._710237386ThreadPitch;
      }
      
      public function set ThreadPitch(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._710237386ThreadPitch;
         if(_loc2_ !== param1)
         {
            this._710237386ThreadPitch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThreadPitch",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThreadTool() : RadioButtonGroup
      {
         return this._808497890ThreadTool;
      }
      
      public function set ThreadTool(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._808497890ThreadTool;
         if(_loc2_ !== param1)
         {
            this._808497890ThreadTool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThreadTool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThreadToolMaterial() : RadioButtonGroup
      {
         return this._1888060887ThreadToolMaterial;
      }
      
      public function set ThreadToolMaterial(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1888060887ThreadToolMaterial;
         if(_loc2_ !== param1)
         {
            this._1888060887ThreadToolMaterial = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThreadToolMaterial",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Threading() : CheckBox
      {
         return this._441742712Threading;
      }
      
      public function set Threading(param1:CheckBox) : void
      {
         var _loc2_:Object = this._441742712Threading;
         if(_loc2_ !== param1)
         {
            this._441742712Threading = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Threading",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get finishPassGrp() : GWizCCWFinishPassGrp
      {
         return this._1588608769finishPassGrp;
      }
      
      public function set finishPassGrp(param1:GWizCCWFinishPassGrp) : void
      {
         var _loc2_:Object = this._1588608769finishPassGrp;
         if(_loc2_ !== param1)
         {
            this._1588608769finishPassGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"finishPassGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theIcon() : Image
      {
         return this._1350774646theIcon;
      }
      
      public function set theIcon(param1:Image) : void
      {
         var _loc2_:Object = this._1350774646theIcon;
         if(_loc2_ !== param1)
         {
            this._1350774646theIcon = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theIcon",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get millHoleImg() : Class
      {
         return this._1683435737millHoleImg;
      }
      
      private function set millHoleImg(param1:Class) : void
      {
         var _loc2_:Object = this._1683435737millHoleImg;
         if(_loc2_ !== param1)
         {
            this._1683435737millHoleImg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"millHoleImg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get latheHoleImg() : Class
      {
         return this._919607399latheHoleImg;
      }
      
      private function set latheHoleImg(param1:Class) : void
      {
         var _loc2_:Object = this._919607399latheHoleImg;
         if(_loc2_ !== param1)
         {
            this._919607399latheHoleImg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"latheHoleImg",_loc2_,param1));
            }
         }
      }
   }
}
