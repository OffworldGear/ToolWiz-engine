package cadcamwiz
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import configinfo.GWizLatheTools;
   import configinfo.GWizSettings;
   import feedsspeeds.GWizTortHare;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColor;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.CheckBox;
   import spark.components.DropDownList;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.HSlider;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import spark.primitives.Rect;
   
   use namespace mx_internal;
   
   public class GWizCCWLatheOptions extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizCCWLatheOptions");
      
      public static var StepoverSlider:Number = 1;
      
      public static var GasPedalSlider:Number = GWizTortHare.GAS_PEDAL_MAX;
      
      public static var gasPedalFactors:ArrayCollection = new ArrayCollection([{
         "stepover":0.7,
         "pedal":1
      },{
         "stepover":0.8,
         "pedal":2
      },{
         "stepover":0.9,
         "pedal":3
      },{
         "stepover":1,
         "pedal":4
      }]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1149965683FinishType:RadioButtonGroup;
      
      private var _1551631807GasPedal:HSlider;
      
      private var _1694867030RecalcOptions:RadioButtonGroup;
      
      public var _GWizCCWLatheOptions_Image1:Image;
      
      public var _GWizCCWLatheOptions_Image2:Image;
      
      private var _416625568finishingInsSize:DropDownList;
      
      private var _416670425finishingInsType:DropDownList;
      
      private var _25894830isCarbide:CheckBox;
      
      private var _354148422roughingInsSize:DropDownList;
      
      private var _354193279roughingInsType:DropDownList;
      
      private var _423685362toolWidth:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var ccDone:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWLatheOptions()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWLatheOptions_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWLatheOptionsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWLatheOptions[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.gap = 1;
         this.mxmlContent = [this._GWizCCWLatheOptions_GWizForePanel1_c(),this._GWizCCWLatheOptions_GWizForePanel2_c(),this._GWizCCWLatheOptions_VGroup4_c()];
         this._GWizCCWLatheOptions_RadioButtonGroup1_i();
         this._GWizCCWLatheOptions_RadioButtonGroup2_i();
         this.addEventListener("creationComplete",this.___GWizCCWLatheOptions_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWLatheOptions._watcherSetupUtil = param1;
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
         this.roughingInsType.selectedIndex = GWizCCWSettings.roughingInsType;
         this.roughingInsSize.selectedIndex = GWizCCWSettings.roughingInsSize;
         this.finishingInsType.selectedIndex = GWizCCWSettings.finishingInsType;
         this.finishingInsSize.selectedIndex = GWizCCWSettings.finishingInsSize;
         this.validateNow();
         this.ccDone = true;
      }
      
      private function recalc() : void
      {
         StepoverSlider = Math.max(Number(this.GasPedal.value) / 100,0.5);
         GasPedalSlider = this.GasPedal.value;
         if(this.ccDone)
         {
            GWizCCWSettings.roughingInsType = this.roughingInsType.selectedIndex;
            GWizCCWSettings.roughingInsSize = this.roughingInsSize.selectedIndex;
            GWizCCWSettings.finishingInsType = this.finishingInsType.selectedIndex;
            GWizCCWSettings.finishingInsSize = this.finishingInsSize.selectedIndex;
            GWizCCWSettings.partingToolCarbide = this.isCarbide.selected;
            GWizCCWSettings.partingToolWidth = this.toolWidth.value;
         }
      }
      
      private function _GWizCCWLatheOptions_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"FinishType");
         this.FinishType = _loc1_;
         BindingManager.executeBindings(this,"FinishType",this.FinishType);
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_RadioButtonGroup2_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"RecalcOptions");
         this.RecalcOptions = _loc1_;
         BindingManager.executeBindings(this,"RecalcOptions",this.RecalcOptions);
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "OD Turn";
         _loc1_.labelWidth = 120;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWLatheOptions_Array2_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Array2_c() : Array
      {
         return [this._GWizCCWLatheOptions_VGroup2_c()];
      }
      
      private function _GWizCCWLatheOptions_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWLatheOptions_HGroup1_c(),this._GWizCCWLatheOptions_HGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizCCWLatheOptions_Label1_c(),this._GWizCCWLatheOptions_Label2_c(),this._GWizCCWLatheOptions_DropDownList1_i(),this._GWizCCWLatheOptions_Label3_c(),this._GWizCCWLatheOptions_Spacer1_c(),this._GWizCCWLatheOptions_DropDownList2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Roughing: ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Insert Type: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__roughingInsType_valueCommit);
         _loc1_.id = "roughingInsType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.roughingInsType = _loc1_;
         BindingManager.executeBindings(this,"roughingInsType",this.roughingInsType);
         return _loc1_;
      }
      
      public function __roughingInsType_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWLatheOptions_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Insert Size: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__roughingInsSize_valueCommit);
         _loc1_.id = "roughingInsSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.roughingInsSize = _loc1_;
         BindingManager.executeBindings(this,"roughingInsSize",this.roughingInsSize);
         return _loc1_;
      }
      
      public function __roughingInsSize_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWLatheOptions_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizCCWLatheOptions_Label4_c(),this._GWizCCWLatheOptions_Label5_c(),this._GWizCCWLatheOptions_DropDownList3_i(),this._GWizCCWLatheOptions_Label6_c(),this._GWizCCWLatheOptions_Spacer2_c(),this._GWizCCWLatheOptions_DropDownList4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Finishing:  ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " Insert Type: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_DropDownList3_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__finishingInsType_valueCommit);
         _loc1_.id = "finishingInsType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.finishingInsType = _loc1_;
         BindingManager.executeBindings(this,"finishingInsType",this.finishingInsType);
         return _loc1_;
      }
      
      public function __finishingInsType_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWLatheOptions_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Insert Size: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_DropDownList4_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__finishingInsSize_valueCommit);
         _loc1_.id = "finishingInsSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.finishingInsSize = _loc1_;
         BindingManager.executeBindings(this,"finishingInsSize",this.finishingInsSize);
         return _loc1_;
      }
      
      public function __finishingInsSize_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWLatheOptions_GWizForePanel2_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Grooving/Parting";
         _loc1_.labelWidth = 120;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWLatheOptions_Array6_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Array6_c() : Array
      {
         return [this._GWizCCWLatheOptions_VGroup3_c()];
      }
      
      private function _GWizCCWLatheOptions_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWLatheOptions_GWizNumStep1_i(),this._GWizCCWLatheOptions_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Tool Width";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__toolWidth_initialize);
         _loc1_.addEventListener("change",this.__toolWidth_change);
         _loc1_.id = "toolWidth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolWidth = _loc1_;
         BindingManager.executeBindings(this,"toolWidth",this.toolWidth);
         return _loc1_;
      }
      
      public function __toolWidth_initialize(param1:FlexEvent) : void
      {
         this.toolWidth.setVal(GWizCCWSettings.partingToolWidth);
      }
      
      public function __toolWidth_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWLatheOptions_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Carbide";
         _loc1_.id = "isCarbide";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.isCarbide = _loc1_;
         BindingManager.executeBindings(this,"isCarbide",this.isCarbide);
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWLatheOptions_Group1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Group1_c() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.mxmlContent = [this._GWizCCWLatheOptions_Rect1_c(),this._GWizCCWLatheOptions_HGroup3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.radiusX = 3;
         _loc1_.fill = this._GWizCCWLatheOptions_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingBottom = 6;
         _loc1_.paddingTop = 6;
         _loc1_.paddingLeft = 6;
         _loc1_.paddingRight = 6;
         _loc1_.mxmlContent = [this._GWizCCWLatheOptions_Label7_c(),this._GWizCCWLatheOptions_Image1_i(),this._GWizCCWLatheOptions_HSlider1_i(),this._GWizCCWLatheOptions_Image2_i(),this._GWizCCWLatheOptions_Label8_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWLatheOptions_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Conservative";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.toolTip = "Emphasize tool life and surface finish";
         _loc1_.setStyle("color",16777215);
         _loc1_.addEventListener("click",this.___GWizCCWLatheOptions_Label7_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCCWLatheOptions_Label7_click(param1:MouseEvent) : void
      {
         this.GasPedal.value = 1;
      }
      
      private function _GWizCCWLatheOptions_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.toolTip = "Emphasize tool life and surface finish";
         _loc1_.addEventListener("click",this.___GWizCCWLatheOptions_Image1_click);
         _loc1_.id = "_GWizCCWLatheOptions_Image1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWLatheOptions_Image1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWLatheOptions_Image1",this._GWizCCWLatheOptions_Image1);
         return _loc1_;
      }
      
      public function ___GWizCCWLatheOptions_Image1_click(param1:MouseEvent) : void
      {
         this.GasPedal.value = 1;
      }
      
      private function _GWizCCWLatheOptions_HSlider1_i() : HSlider
      {
         var _loc1_:HSlider = new HSlider();
         _loc1_.snapInterval = 1;
         _loc1_.minimum = 1;
         _loc1_.setStyle("liveDragging",false);
         _loc1_.addEventListener("valueCommit",this.__GasPedal_valueCommit);
         _loc1_.addEventListener("change",this.__GasPedal_change);
         _loc1_.id = "GasPedal";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GasPedal = _loc1_;
         BindingManager.executeBindings(this,"GasPedal",this.GasPedal);
         return _loc1_;
      }
      
      public function __GasPedal_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function __GasPedal_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWLatheOptions_Image2_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.toolTip = "Maximize MRR";
         _loc1_.addEventListener("click",this.___GWizCCWLatheOptions_Image2_click);
         _loc1_.id = "_GWizCCWLatheOptions_Image2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWLatheOptions_Image2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWLatheOptions_Image2",this._GWizCCWLatheOptions_Image2);
         return _loc1_;
      }
      
      public function ___GWizCCWLatheOptions_Image2_click(param1:MouseEvent) : void
      {
         this.GasPedal.value = GWizTortHare.GAS_PEDAL_MAX;
      }
      
      private function _GWizCCWLatheOptions_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Aggressive";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.toolTip = "Maximize MRR";
         _loc1_.setStyle("color",16777215);
         _loc1_.addEventListener("click",this.___GWizCCWLatheOptions_Label8_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCCWLatheOptions_Label8_click(param1:MouseEvent) : void
      {
         this.GasPedal.value = GWizTortHare.GAS_PEDAL_MAX;
      }
      
      public function ___GWizCCWLatheOptions_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCCWLatheOptions_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizLatheTools.insTypes;
         },null,"roughingInsType.dataProvider");
         result[1] = new Binding(this,function():IList
         {
            return GWizLatheTools.insSizes;
         },null,"roughingInsSize.dataProvider");
         result[2] = new Binding(this,function():IList
         {
            return GWizLatheTools.insTypes;
         },null,"finishingInsType.dataProvider");
         result[3] = new Binding(this,function():IList
         {
            return GWizLatheTools.insSizes;
         },null,"finishingInsSize.dataProvider");
         result[4] = new Binding(this,function():Boolean
         {
            return GWizCCWSettings.partingToolCarbide;
         },null,"isCarbide.selected");
         result[5] = new Binding(this,function():Object
         {
            return GWizSettings.TortoiseImg;
         },null,"_GWizCCWLatheOptions_Image1.source");
         result[6] = new Binding(this,function():Number
         {
            return GWizTortHare.GAS_PEDAL_MAX;
         },null,"GasPedal.maximum");
         result[7] = new Binding(this,function():Number
         {
            return GWizTortHare.GAS_PEDAL_MAX;
         },null,"GasPedal.value");
         result[8] = new Binding(this,function():Object
         {
            return GWizSettings.HareImg;
         },null,"_GWizCCWLatheOptions_Image2.source");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get FinishType() : RadioButtonGroup
      {
         return this._1149965683FinishType;
      }
      
      public function set FinishType(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1149965683FinishType;
         if(_loc2_ !== param1)
         {
            this._1149965683FinishType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FinishType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GasPedal() : HSlider
      {
         return this._1551631807GasPedal;
      }
      
      public function set GasPedal(param1:HSlider) : void
      {
         var _loc2_:Object = this._1551631807GasPedal;
         if(_loc2_ !== param1)
         {
            this._1551631807GasPedal = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GasPedal",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RecalcOptions() : RadioButtonGroup
      {
         return this._1694867030RecalcOptions;
      }
      
      public function set RecalcOptions(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1694867030RecalcOptions;
         if(_loc2_ !== param1)
         {
            this._1694867030RecalcOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RecalcOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get finishingInsSize() : DropDownList
      {
         return this._416625568finishingInsSize;
      }
      
      public function set finishingInsSize(param1:DropDownList) : void
      {
         var _loc2_:Object = this._416625568finishingInsSize;
         if(_loc2_ !== param1)
         {
            this._416625568finishingInsSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"finishingInsSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get finishingInsType() : DropDownList
      {
         return this._416670425finishingInsType;
      }
      
      public function set finishingInsType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._416670425finishingInsType;
         if(_loc2_ !== param1)
         {
            this._416670425finishingInsType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"finishingInsType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get isCarbide() : CheckBox
      {
         return this._25894830isCarbide;
      }
      
      public function set isCarbide(param1:CheckBox) : void
      {
         var _loc2_:Object = this._25894830isCarbide;
         if(_loc2_ !== param1)
         {
            this._25894830isCarbide = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"isCarbide",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get roughingInsSize() : DropDownList
      {
         return this._354148422roughingInsSize;
      }
      
      public function set roughingInsSize(param1:DropDownList) : void
      {
         var _loc2_:Object = this._354148422roughingInsSize;
         if(_loc2_ !== param1)
         {
            this._354148422roughingInsSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"roughingInsSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get roughingInsType() : DropDownList
      {
         return this._354193279roughingInsType;
      }
      
      public function set roughingInsType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._354193279roughingInsType;
         if(_loc2_ !== param1)
         {
            this._354193279roughingInsType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"roughingInsType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolWidth() : GWizNumStep
      {
         return this._423685362toolWidth;
      }
      
      public function set toolWidth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._423685362toolWidth;
         if(_loc2_ !== param1)
         {
            this._423685362toolWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolWidth",_loc2_,param1));
            }
         }
      }
   }
}
