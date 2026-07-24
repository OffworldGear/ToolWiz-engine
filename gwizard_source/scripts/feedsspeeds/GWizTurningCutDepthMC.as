package feedsspeeds
{
   import comps.GWizNumStepOvr;
   import comps.GWizPopUp;
   import configinfo.GWizLatheTools;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizTurningCutDepthMC extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizTurningCutDepthMC");
      
      private static var _insType:int = 0;
      
      private static var _insSize:int = 0;
      
      private static var _cutType:int = 0;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1127912604cutType:DropDownList;
      
      private var _99464dim:GWizNumStepOvr;
      
      private var _1665199923dimName:Label;
      
      private var _1827411885docCalc:Label;
      
      private var _1956594959insSize:DropDownList;
      
      private var _1956639816insType:DropDownList;
      
      private var _1113465559leadAngle:NumericStepper;
      
      private var _1081165516maxDOC:Label;
      
      private var _869216569maxInfeed:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var doc:Number;
      
      private var recurse:Boolean = false;
      
      private var _embed_mxml__assets_LeadAngle_jpg_1258027860:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizTurningCutDepthMC()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._embed_mxml__assets_LeadAngle_jpg_1258027860 = GWizTurningCutDepthMC__embed_mxml__assets_LeadAngle_jpg_1258027860;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizTurningCutDepthMC_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizTurningCutDepthMCWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizTurningCutDepthMC[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.width = 550;
         this.height = 300;
         this.title = "Turning Cut Depth";
         this.okLabel = "Adjust Cut Depth";
         this.mxmlContent = [this._GWizTurningCutDepthMC_HGroup1_c(),this._GWizTurningCutDepthMC_Spacer9_c()];
         this.addEventListener("creationComplete",this.___GWizTurningCutDepthMC_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizTurningCutDepthMC._watcherSetupUtil = param1;
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
      
      private function recalc() : void
      {
         var _loc1_:Object = null;
         if(this.recurse)
         {
            return;
         }
         this.recurse = true;
         this.doc = NaN;
         if(this.dimName && this.maxDOC)
         {
            if(this.insType.selectedIndex < 0)
            {
               this.insType.selectedIndex = _insType;
            }
            if(this.insSize.selectedIndex < 0)
            {
               this.insSize.selectedIndex = _insSize;
            }
            if(this.cutType.selectedIndex < 0)
            {
               this.cutType.selectedIndex = _cutType;
            }
            _loc1_ = GWizLatheTools.turningCutDepth(GWizLatheTools.insTypes.getItemAt(this.insType.selectedIndex),this.insSize.selectedIndex,this.cutType.selectedIndex,this.leadAngle.value);
            this.dimName.text = _loc1_.dimName;
            this.dim.setVal(_loc1_.dim);
            this.maxDOC.text = String(GWizUtils.roundThousandths(_loc1_.doc,true));
            this.maxInfeed.text = String(GWizUtils.roundThousandths(_loc1_.infeed,true));
            this.doc = _loc1_.doc;
            this.doc *= Math.cos(GWizUtils.radians(this.leadAngle.value));
            this.docCalc.text = String(GWizUtils.roundThousandths(this.doc,true));
         }
         this.recurse = false;
      }
      
      private function doAdjust(param1:Boolean) : void
      {
         if(param1)
         {
            log.debug("leadAngle = " + this.leadAngle.value);
            log.debug("cos(leadAngle) = " + Math.cos(GWizUtils.radians(this.leadAngle.value)));
            log.debug("doc = " + this.doc);
            log.debug("cutDepth = " + this.doc);
            GWizSettings.FeedsSpeedsApp.cutDepth.setVal(this.doc);
            _insType = this.insType.selectedIndex;
            _insSize = this.insSize.selectedIndex;
            _cutType = this.cutType.selectedIndex;
         }
         super.close();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doAdjust(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doAdjust(false);
      }
      
      private function _GWizTurningCutDepthMC_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTurningCutDepthMC_VGroup1_c(),this._GWizTurningCutDepthMC_Image1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 60;
         _loc1_.mxmlContent = [this._GWizTurningCutDepthMC_HGroup2_c(),this._GWizTurningCutDepthMC_HGroup3_c(),this._GWizTurningCutDepthMC_HGroup4_c(),this._GWizTurningCutDepthMC_HGroup5_c(),this._GWizTurningCutDepthMC_HGroup6_c(),this._GWizTurningCutDepthMC_HGroup7_c(),this._GWizTurningCutDepthMC_HGroup8_c(),this._GWizTurningCutDepthMC_HGroup9_c()];
         _loc1_.setStyle("color",6986440);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTurningCutDepthMC_Label1_c(),this._GWizTurningCutDepthMC_Spacer1_c(),this._GWizTurningCutDepthMC_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Insert Type";
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__insType_valueCommit);
         _loc1_.id = "insType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.insType = _loc1_;
         BindingManager.executeBindings(this,"insType",this.insType);
         return _loc1_;
      }
      
      public function __insType_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTurningCutDepthMC_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTurningCutDepthMC_Label2_c(),this._GWizTurningCutDepthMC_Spacer2_c(),this._GWizTurningCutDepthMC_DropDownList2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Insert Size";
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__insSize_valueCommit);
         _loc1_.id = "insSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.insSize = _loc1_;
         BindingManager.executeBindings(this,"insSize",this.insSize);
         return _loc1_;
      }
      
      public function __insSize_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTurningCutDepthMC_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTurningCutDepthMC_Label3_i(),this._GWizTurningCutDepthMC_Spacer3_c(),this._GWizTurningCutDepthMC_GWizNumStepOvr1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Dimension";
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "dimName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.dimName = _loc1_;
         BindingManager.executeBindings(this,"dimName",this.dimName);
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.min = 0;
         _loc1_.max = 3;
         _loc1_.steps = 0.001;
         _loc1_.width = 100;
         _loc1_.addEventListener("valueCommit",this.__dim_valueCommit);
         _loc1_.id = "dim";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.dim = _loc1_;
         BindingManager.executeBindings(this,"dim",this.dim);
         return _loc1_;
      }
      
      public function __dim_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTurningCutDepthMC_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTurningCutDepthMC_Label4_c(),this._GWizTurningCutDepthMC_Spacer4_c(),this._GWizTurningCutDepthMC_DropDownList3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cut Type";
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_DropDownList3_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 100;
         _loc1_.addEventListener("valueCommit",this.__cutType_valueCommit);
         _loc1_.id = "cutType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutType = _loc1_;
         BindingManager.executeBindings(this,"cutType",this.cutType);
         return _loc1_;
      }
      
      public function __cutType_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTurningCutDepthMC_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTurningCutDepthMC_Label5_c(),this._GWizTurningCutDepthMC_Spacer5_c(),this._GWizTurningCutDepthMC_Label6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max. Cut Depth ";
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Spacer5_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.toolTip = "Maximum recommended DOC for this insert without shortening tool life.";
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "maxDOC";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.maxDOC = _loc1_;
         BindingManager.executeBindings(this,"maxDOC",this.maxDOC);
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTurningCutDepthMC_Label7_c(),this._GWizTurningCutDepthMC_Spacer6_c(),this._GWizTurningCutDepthMC_NumericStepper1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Lead Angle";
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Spacer6_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 90;
         _loc1_.stepSize = 1;
         _loc1_.width = 100;
         _loc1_.toolTip = "Angle of the cutting edge of insert to the workpiece. 0 degrees means the cut is straight in.";
         _loc1_.addEventListener("valueCommit",this.__leadAngle_valueCommit);
         _loc1_.id = "leadAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.leadAngle = _loc1_;
         BindingManager.executeBindings(this,"leadAngle",this.leadAngle);
         return _loc1_;
      }
      
      public function __leadAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTurningCutDepthMC_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTurningCutDepthMC_Label8_c(),this._GWizTurningCutDepthMC_Spacer7_c(),this._GWizTurningCutDepthMC_Label9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max. Infeed ";
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Spacer7_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.toolTip = "Amount of infeed parallel to axis to achieve max DOC with this lead angle.";
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "maxInfeed";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.maxInfeed = _loc1_;
         BindingManager.executeBindings(this,"maxInfeed",this.maxInfeed);
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_HGroup9_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTurningCutDepthMC_Label10_c(),this._GWizTurningCutDepthMC_Spacer8_c(),this._GWizTurningCutDepthMC_Label11_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Depth of Cut ";
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Spacer8_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.toolTip = "Depth of cut based on max DOC with this lead angle.";
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "docCalc";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.docCalc = _loc1_;
         BindingManager.executeBindings(this,"docCalc",this.docCalc);
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_LeadAngle_jpg_1258027860;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurningCutDepthMC_Spacer9_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizTurningCutDepthMC_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTurningCutDepthMC_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizLatheTools.insTypes;
         },null,"insType.dataProvider");
         result[1] = new Binding(this,function():IList
         {
            return GWizLatheTools.insSizes;
         },null,"insSize.dataProvider");
         result[2] = new Binding(this,function():IList
         {
            return GWizLatheTools.cutTypes;
         },null,"cutType.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get cutType() : DropDownList
      {
         return this._1127912604cutType;
      }
      
      public function set cutType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1127912604cutType;
         if(_loc2_ !== param1)
         {
            this._1127912604cutType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get dim() : GWizNumStepOvr
      {
         return this._99464dim;
      }
      
      public function set dim(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._99464dim;
         if(_loc2_ !== param1)
         {
            this._99464dim = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dim",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get dimName() : Label
      {
         return this._1665199923dimName;
      }
      
      public function set dimName(param1:Label) : void
      {
         var _loc2_:Object = this._1665199923dimName;
         if(_loc2_ !== param1)
         {
            this._1665199923dimName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dimName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get docCalc() : Label
      {
         return this._1827411885docCalc;
      }
      
      public function set docCalc(param1:Label) : void
      {
         var _loc2_:Object = this._1827411885docCalc;
         if(_loc2_ !== param1)
         {
            this._1827411885docCalc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"docCalc",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get insSize() : DropDownList
      {
         return this._1956594959insSize;
      }
      
      public function set insSize(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1956594959insSize;
         if(_loc2_ !== param1)
         {
            this._1956594959insSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"insSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get insType() : DropDownList
      {
         return this._1956639816insType;
      }
      
      public function set insType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1956639816insType;
         if(_loc2_ !== param1)
         {
            this._1956639816insType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"insType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get leadAngle() : NumericStepper
      {
         return this._1113465559leadAngle;
      }
      
      public function set leadAngle(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1113465559leadAngle;
         if(_loc2_ !== param1)
         {
            this._1113465559leadAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"leadAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get maxDOC() : Label
      {
         return this._1081165516maxDOC;
      }
      
      public function set maxDOC(param1:Label) : void
      {
         var _loc2_:Object = this._1081165516maxDOC;
         if(_loc2_ !== param1)
         {
            this._1081165516maxDOC = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"maxDOC",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get maxInfeed() : Label
      {
         return this._869216569maxInfeed;
      }
      
      public function set maxInfeed(param1:Label) : void
      {
         var _loc2_:Object = this._869216569maxInfeed;
         if(_loc2_ !== param1)
         {
            this._869216569maxInfeed = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"maxInfeed",_loc2_,param1));
            }
         }
      }
   }
}
