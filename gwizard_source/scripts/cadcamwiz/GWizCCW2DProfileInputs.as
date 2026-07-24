package cadcamwiz
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizNumStepOvr;
   import comps.ProgressBar;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
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
   
   public class GWizCCW2DProfileInputs extends GWizForePanel implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _65919651Depth:GWizNumStep;
      
      private var _708093801EstimatorInputs:HGroup;
      
      private var _381346558InsideCorners:CheckBox;
      
      private var _1736744743MinCorner:GWizNumStep;
      
      private var _947263423PartCutout:CheckBox;
      
      private var _1726198787Perimeter:GWizNumStepOvr;
      
      private var _1355219513ProgBar:ProgressBar;
      
      private var _1727016134Volume:GWizNumStepOvr;
      
      private var _1414264414XExtent:GWizNumStep;
      
      private var _1778273909XYExtent:RadioButton;
      
      private var _526760733YExtent:GWizNumStep;
      
      public var _GWizCCW2DProfileInputs_Label1:Label;
      
      private var _348555477chamferInputs:GWizCCWChamferInputs;
      
      private var _1588608769finishPassGrp:GWizCCWFinishPassGrp;
      
      private var _164873549radiogroup1:RadioButtonGroup;
      
      private var _638106067stockAllow:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _934922488recalc:Function = null;
      
      private var _embed_mxml__assets_Boss128_jpg_984989138:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCW2DProfileInputs()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._embed_mxml__assets_Boss128_jpg_984989138 = GWizCCW2DProfileInputs__embed_mxml__assets_Boss128_jpg_984989138;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCW2DProfileInputs_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCW2DProfileInputsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCW2DProfileInputs[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Inputs";
         this.percentWidth = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCW2DProfileInputs_Array1_c);
         this._GWizCCW2DProfileInputs_RadioButtonGroup1_i();
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCW2DProfileInputs._watcherSetupUtil = param1;
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
      
      private function radioChange() : void
      {
         if(this.XYExtent.selected)
         {
            this.XExtent.enabled = true;
            this.YExtent.enabled = true;
            this.Volume.enabled = false;
            this.Perimeter.enabled = false;
         }
         else
         {
            this.XExtent.enabled = false;
            this.YExtent.enabled = false;
            this.Volume.enabled = true;
            this.Perimeter.enabled = true;
         }
         this.recalc();
      }
      
      private function _GWizCCW2DProfileInputs_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.addEventListener("valueCommit",this.__radiogroup1_valueCommit);
         _loc1_.initialized(this,"radiogroup1");
         this.radiogroup1 = _loc1_;
         BindingManager.executeBindings(this,"radiogroup1",this.radiogroup1);
         return _loc1_;
      }
      
      public function __radiogroup1_valueCommit(param1:FlexEvent) : void
      {
         this.radioChange();
      }
      
      private function _GWizCCW2DProfileInputs_Array1_c() : Array
      {
         return [this._GWizCCW2DProfileInputs_VGroup1_c(),this._GWizCCW2DProfileInputs_VGroup6_c()];
      }
      
      private function _GWizCCW2DProfileInputs_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCW2DProfileInputs_VGroup2_c(),this._GWizCCW2DProfileInputs_HGroup3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCW2DProfileInputs_HGroup1_c(),this._GWizCCW2DProfileInputs_HGroup2_c(),this._GWizCCW2DProfileInputs_GWizCCWFinishPassGrp1_i(),this._GWizCCW2DProfileInputs_GWizCCWChamferInputs1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCW2DProfileInputs_GWizNumStep1_i(),this._GWizCCW2DProfileInputs_GWizNumStep2_i(),this._GWizCCW2DProfileInputs_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.titleTxt = "Depth:";
         _loc1_.labelWidth = 100;
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
      
      private function _GWizCCW2DProfileInputs_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.titleTxt = "Min Inside Corner Radius:";
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__MinCorner_initialize);
         _loc1_.addEventListener("change",this.__MinCorner_change);
         _loc1_.id = "MinCorner";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MinCorner = _loc1_;
         BindingManager.executeBindings(this,"MinCorner",this.MinCorner);
         return _loc1_;
      }
      
      public function __MinCorner_initialize(param1:FlexEvent) : void
      {
         this.MinCorner.setVal(0.125);
      }
      
      public function __MinCorner_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCW2DProfileInputs_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Inside corners";
         _loc1_.selected = false;
         _loc1_.addEventListener("change",this.__InsideCorners_change);
         _loc1_.id = "InsideCorners";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.InsideCorners = _loc1_;
         BindingManager.executeBindings(this,"InsideCorners",this.InsideCorners);
         return _loc1_;
      }
      
      public function __InsideCorners_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCW2DProfileInputs_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCW2DProfileInputs_GWizNumStep3_i(),this._GWizCCW2DProfileInputs_CheckBox2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Stock Allowance:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.labelWidth = 100;
         _loc1_.UnitLabel = "in";
         _loc1_.toolTip = "Max distance from stock edge to profile edge";
         _loc1_.addEventListener("initialize",this.__stockAllow_initialize);
         _loc1_.addEventListener("change",this.__stockAllow_change);
         _loc1_.id = "stockAllow";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stockAllow = _loc1_;
         BindingManager.executeBindings(this,"stockAllow",this.stockAllow);
         return _loc1_;
      }
      
      public function __stockAllow_initialize(param1:FlexEvent) : void
      {
         this.stockAllow.setVal(0.1);
      }
      
      public function __stockAllow_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCW2DProfileInputs_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Part Cutout";
         _loc1_.selected = false;
         _loc1_.toolTip = "Forces full slotting to cut part outlines out.";
         _loc1_.addEventListener("change",this.__PartCutout_change);
         _loc1_.id = "PartCutout";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PartCutout = _loc1_;
         BindingManager.executeBindings(this,"PartCutout",this.PartCutout);
         return _loc1_;
      }
      
      public function __PartCutout_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCW2DProfileInputs_GWizCCWFinishPassGrp1_i() : GWizCCWFinishPassGrp
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
      
      private function _GWizCCW2DProfileInputs_GWizCCWChamferInputs1_i() : GWizCCWChamferInputs
      {
         var _loc1_:GWizCCWChamferInputs = new GWizCCWChamferInputs();
         _loc1_.id = "chamferInputs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.chamferInputs = _loc1_;
         BindingManager.executeBindings(this,"chamferInputs",this.chamferInputs);
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCW2DProfileInputs_HGroup4_i(),this._GWizCCW2DProfileInputs_VGroup5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_HGroup4_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCW2DProfileInputs_VGroup3_c(),this._GWizCCW2DProfileInputs_VGroup4_c()];
         _loc1_.id = "EstimatorInputs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EstimatorInputs = _loc1_;
         BindingManager.executeBindings(this,"EstimatorInputs",this.EstimatorInputs);
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCCW2DProfileInputs_RadioButton1_i(),this._GWizCCW2DProfileInputs_GWizNumStep4_i(),this._GWizCCW2DProfileInputs_GWizNumStep5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "XY Extent";
         _loc1_.groupName = "radiogroup1";
         _loc1_.selected = true;
         _loc1_.id = "XYExtent";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.XYExtent = _loc1_;
         BindingManager.executeBindings(this,"XYExtent",this.XYExtent);
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "X:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__XExtent_initialize);
         _loc1_.addEventListener("change",this.__XExtent_change);
         _loc1_.id = "XExtent";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.XExtent = _loc1_;
         BindingManager.executeBindings(this,"XExtent",this.XExtent);
         return _loc1_;
      }
      
      public function __XExtent_initialize(param1:FlexEvent) : void
      {
         this.XExtent.setVal(2);
      }
      
      public function __XExtent_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCW2DProfileInputs_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Y:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__YExtent_initialize);
         _loc1_.addEventListener("change",this.__YExtent_change);
         _loc1_.id = "YExtent";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.YExtent = _loc1_;
         BindingManager.executeBindings(this,"YExtent",this.YExtent);
         return _loc1_;
      }
      
      public function __YExtent_initialize(param1:FlexEvent) : void
      {
         this.YExtent.setVal(3);
      }
      
      public function __YExtent_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCW2DProfileInputs_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCCW2DProfileInputs_RadioButton2_c(),this._GWizCCW2DProfileInputs_GWizNumStepOvr1_i(),this._GWizCCW2DProfileInputs_GWizNumStepOvr2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_RadioButton2_c() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Volume";
         _loc1_.groupName = "radiogroup1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Volume:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Volume to be removed by profile operation.";
         _loc1_.labelWidth = 100;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("change",this.__Volume_change);
         _loc1_.id = "Volume";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Volume = _loc1_;
         BindingManager.executeBindings(this,"Volume",this.Volume);
         return _loc1_;
      }
      
      public function __Volume_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCW2DProfileInputs_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Perimeter:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.usesMetric = false;
         _loc1_.labelWidth = 100;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("change",this.__Perimeter_change);
         _loc1_.id = "Perimeter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Perimeter = _loc1_;
         BindingManager.executeBindings(this,"Perimeter",this.Perimeter);
         return _loc1_;
      }
      
      public function __Perimeter_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCW2DProfileInputs_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCW2DProfileInputs_Label1_i(),this._GWizCCW2DProfileInputs_ProgressBar1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Note: XY Extents and Volume are only for estimating cycle time, not feeds and speeds.";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("lineBreak","toFit");
         _loc1_.id = "_GWizCCW2DProfileInputs_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCW2DProfileInputs_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCW2DProfileInputs_Label1",this._GWizCCW2DProfileInputs_Label1);
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_ProgressBar1_i() : ProgressBar
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
      
      private function _GWizCCW2DProfileInputs_VGroup6_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCW2DProfileInputs_Image1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_Boss128_jpg_984989138;
         _loc1_.setStyle("backgroundColor",15658734);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCW2DProfileInputs_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"chamferInputs.recalc","recalc");
         result[1] = new Binding(this,function():Boolean
         {
            return GWizCCWEstimatorInput.addEstimatorItem != null;
         },null,"EstimatorInputs.visible");
         result[2] = new Binding(this,function():Boolean
         {
            return EstimatorInputs.visible;
         },null,"EstimatorInputs.includeInLayout");
         result[3] = new Binding(this,function():Boolean
         {
            return EstimatorInputs.visible;
         },null,"_GWizCCW2DProfileInputs_Label1.visible");
         return result;
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
      public function get EstimatorInputs() : HGroup
      {
         return this._708093801EstimatorInputs;
      }
      
      public function set EstimatorInputs(param1:HGroup) : void
      {
         var _loc2_:Object = this._708093801EstimatorInputs;
         if(_loc2_ !== param1)
         {
            this._708093801EstimatorInputs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EstimatorInputs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get InsideCorners() : CheckBox
      {
         return this._381346558InsideCorners;
      }
      
      public function set InsideCorners(param1:CheckBox) : void
      {
         var _loc2_:Object = this._381346558InsideCorners;
         if(_loc2_ !== param1)
         {
            this._381346558InsideCorners = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"InsideCorners",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MinCorner() : GWizNumStep
      {
         return this._1736744743MinCorner;
      }
      
      public function set MinCorner(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1736744743MinCorner;
         if(_loc2_ !== param1)
         {
            this._1736744743MinCorner = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MinCorner",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PartCutout() : CheckBox
      {
         return this._947263423PartCutout;
      }
      
      public function set PartCutout(param1:CheckBox) : void
      {
         var _loc2_:Object = this._947263423PartCutout;
         if(_loc2_ !== param1)
         {
            this._947263423PartCutout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PartCutout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Perimeter() : GWizNumStepOvr
      {
         return this._1726198787Perimeter;
      }
      
      public function set Perimeter(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1726198787Perimeter;
         if(_loc2_ !== param1)
         {
            this._1726198787Perimeter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Perimeter",_loc2_,param1));
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
      public function get Volume() : GWizNumStepOvr
      {
         return this._1727016134Volume;
      }
      
      public function set Volume(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1727016134Volume;
         if(_loc2_ !== param1)
         {
            this._1727016134Volume = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Volume",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get XExtent() : GWizNumStep
      {
         return this._1414264414XExtent;
      }
      
      public function set XExtent(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1414264414XExtent;
         if(_loc2_ !== param1)
         {
            this._1414264414XExtent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"XExtent",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get XYExtent() : RadioButton
      {
         return this._1778273909XYExtent;
      }
      
      public function set XYExtent(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1778273909XYExtent;
         if(_loc2_ !== param1)
         {
            this._1778273909XYExtent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"XYExtent",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get YExtent() : GWizNumStep
      {
         return this._526760733YExtent;
      }
      
      public function set YExtent(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._526760733YExtent;
         if(_loc2_ !== param1)
         {
            this._526760733YExtent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"YExtent",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get chamferInputs() : GWizCCWChamferInputs
      {
         return this._348555477chamferInputs;
      }
      
      public function set chamferInputs(param1:GWizCCWChamferInputs) : void
      {
         var _loc2_:Object = this._348555477chamferInputs;
         if(_loc2_ !== param1)
         {
            this._348555477chamferInputs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"chamferInputs",_loc2_,param1));
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
      public function get radiogroup1() : RadioButtonGroup
      {
         return this._164873549radiogroup1;
      }
      
      public function set radiogroup1(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._164873549radiogroup1;
         if(_loc2_ !== param1)
         {
            this._164873549radiogroup1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radiogroup1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stockAllow() : GWizNumStep
      {
         return this._638106067stockAllow;
      }
      
      public function set stockAllow(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._638106067stockAllow;
         if(_loc2_ !== param1)
         {
            this._638106067stockAllow = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stockAllow",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get recalc() : Function
      {
         return this._934922488recalc;
      }
      
      public function set recalc(param1:Function) : void
      {
         var _loc2_:Object = this._934922488recalc;
         if(_loc2_ !== param1)
         {
            this._934922488recalc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"recalc",_loc2_,param1));
            }
         }
      }
   }
}
