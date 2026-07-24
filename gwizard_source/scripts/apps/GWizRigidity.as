package apps
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import flash.utils.getDefinitionByName;
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
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import spark.layouts.VerticalLayout;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizRigidity extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1966025694Answer:Label;
      
      public var _GWizRigidity_GWizForePanel1:GWizForePanel;
      
      public var _GWizRigidity_GWizForePanel2:GWizForePanel;
      
      public var _GWizRigidity_Label1:Label;
      
      public var _GWizRigidity_Label10:Label;
      
      public var _GWizRigidity_Label4:Label;
      
      private var _1654107084diaMult:Label;
      
      private var _61691109lenMult:Label;
      
      private var _840219312matMult:Label;
      
      private var _1277078865rButtons:HGroup;
      
      private var _964547574rCarbide:RadioButton;
      
      private var _3464874rDia:GWizNumStep;
      
      private var _3468022rHSS:RadioButton;
      
      private var _3472451rLen:GWizNumStep;
      
      private var _750276180refGroup:RadioButtonGroup;
      
      private var _2086425491tButtons:HGroup;
      
      private var _1773894200tCarbide:RadioButton;
      
      private var _3524456tDia:GWizNumStep;
      
      private var _3527604tHSS:RadioButton;
      
      private var _3532033tLen:GWizNumStep;
      
      private var _2106792082targetGroup:RadioButtonGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizRigidity()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizRigidity_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizRigidityWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizRigidity[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.gap = 1;
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.mxmlContent = [this._GWizRigidity_Label1_i(),this._GWizRigidity_GWizForePanel1_i(),this._GWizRigidity_GWizForePanel2_i()];
         this._GWizRigidity_RadioButtonGroup1_i();
         this._GWizRigidity_RadioButtonGroup2_i();
         this.addEventListener("creationComplete",this.___GWizRigidity_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizRigidity._watcherSetupUtil = param1;
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
         this.rDia.setVal(0.5);
         this.rLen.setVal(1.25);
         this.tDia.setVal(0.25);
         this.tLen.setVal(1.25);
      }
      
      private function recalc() : void
      {
         this.diaMult.text = String(GWizUtils.roundThousandths(Math.pow(this.tDia.getVal() / this.rDia.getVal(),4)));
         this.lenMult.text = String(GWizUtils.roundThousandths(Math.pow(1 / (this.tLen.getVal() / this.rLen.getVal()),3)));
         var _loc1_:Number = !!this.rCarbide.selected ? Number(3) : Number(1);
         var _loc2_:Number = !!this.tCarbide.selected ? Number(3) : Number(1);
         this.matMult.text = String(GWizUtils.roundThousandths(_loc2_ / _loc1_));
         var _loc3_:Number = GWizUtils.roundThousandths(Number(this.diaMult.text) * Number(this.lenMult.text) * Number(this.matMult.text));
         var _loc4_:String = "Target Tool is 1x as Rigid as Reference Tool";
         if(_loc3_ < 1)
         {
            this.Answer.text = _loc4_.replace("1x",String(GWizUtils.roundThousandths(1 / _loc3_)) + "x less");
         }
         else
         {
            this.Answer.text = _loc4_.replace("1x",String(_loc3_) + "x more");
         }
      }
      
      private function _GWizRigidity_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"refGroup");
         this.refGroup = _loc1_;
         BindingManager.executeBindings(this,"refGroup",this.refGroup);
         return _loc1_;
      }
      
      private function _GWizRigidity_RadioButtonGroup2_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"targetGroup");
         this.targetGroup = _loc1_;
         BindingManager.executeBindings(this,"targetGroup",this.targetGroup);
         return _loc1_;
      }
      
      private function _GWizRigidity_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Endmill, Twist Drill, and Boring Bar Rigidity Calculator";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("paddingBottom",5);
         _loc1_.setStyle("paddingTop",5);
         _loc1_.setStyle("paddingLeft",5);
         _loc1_.setStyle("fontSize",16);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizRigidity_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizRigidity_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizRigidity_Label1",this._GWizRigidity_Label1);
         return _loc1_;
      }
      
      private function _GWizRigidity_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Reference Tool";
         _loc1_.labelWidth = 140;
         _loc1_.layout = this._GWizRigidity_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizRigidity_Array2_c);
         _loc1_.id = "_GWizRigidity_GWizForePanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizRigidity_GWizForePanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizRigidity_GWizForePanel1",this._GWizRigidity_GWizForePanel1);
         return _loc1_;
      }
      
      private function _GWizRigidity_VerticalLayout1_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizRigidity_Array2_c() : Array
      {
         return [this._GWizRigidity_HGroup1_c(),this._GWizRigidity_HGroup2_c(),this._GWizRigidity_HGroup3_c()];
      }
      
      private function _GWizRigidity_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizRigidity_GWizNumStep1_i(),this._GWizRigidity_Label2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.01;
         _loc1_.max = 100;
         _loc1_.steps = 0.001;
         _loc1_.titleTxt = "Diameter";
         _loc1_.fatSpacer = false;
         _loc1_.addEventListener("valueCommit",this.__rDia_valueCommit);
         _loc1_.id = "rDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rDia = _loc1_;
         BindingManager.executeBindings(this,"rDia",this.rDia);
         return _loc1_;
      }
      
      public function __rDia_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizRigidity_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Rigidity increases as the 4th power of diameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizRigidity_GWizNumStep2_i(),this._GWizRigidity_Label3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.01;
         _loc1_.max = 500;
         _loc1_.steps = 0.001;
         _loc1_.titleTxt = "Length (Holder to Tip)";
         _loc1_.fatSpacer = false;
         _loc1_.addEventListener("valueCommit",this.__rLen_valueCommit);
         _loc1_.id = "rLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rLen = _loc1_;
         BindingManager.executeBindings(this,"rLen",this.rLen);
         return _loc1_;
      }
      
      public function __rLen_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizRigidity_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Rigidity decreases as the 3rd power of length";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizRigidity_Label4_i(),this._GWizRigidity_HGroup4_i(),this._GWizRigidity_Label5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Material";
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "_GWizRigidity_Label4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizRigidity_Label4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizRigidity_Label4",this._GWizRigidity_Label4);
         return _loc1_;
      }
      
      private function _GWizRigidity_HGroup4_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.paddingRight = 10;
         _loc1_.mxmlContent = [this._GWizRigidity_RadioButton1_i(),this._GWizRigidity_RadioButton2_i()];
         _loc1_.id = "rButtons";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rButtons = _loc1_;
         BindingManager.executeBindings(this,"rButtons",this.rButtons);
         return _loc1_;
      }
      
      private function _GWizRigidity_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "HSS";
         _loc1_.addEventListener("valueCommit",this.__rHSS_valueCommit);
         _loc1_.id = "rHSS";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rHSS = _loc1_;
         BindingManager.executeBindings(this,"rHSS",this.rHSS);
         return _loc1_;
      }
      
      public function __rHSS_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizRigidity_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Carbide";
         _loc1_.selected = true;
         _loc1_.addEventListener("valueCommit",this.__rCarbide_valueCommit);
         _loc1_.id = "rCarbide";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rCarbide = _loc1_;
         BindingManager.executeBindings(this,"rCarbide",this.rCarbide);
         return _loc1_;
      }
      
      public function __rCarbide_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizRigidity_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Carbide is 3x as rigid as HSS";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Target Tool";
         _loc1_.labelWidth = 140;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizRigidity_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizRigidity_Array7_c);
         _loc1_.id = "_GWizRigidity_GWizForePanel2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizRigidity_GWizForePanel2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizRigidity_GWizForePanel2",this._GWizRigidity_GWizForePanel2);
         return _loc1_;
      }
      
      private function _GWizRigidity_VerticalLayout2_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizRigidity_Array7_c() : Array
      {
         return [this._GWizRigidity_HGroup5_c(),this._GWizRigidity_HGroup6_c(),this._GWizRigidity_HGroup7_c(),this._GWizRigidity_Spacer1_c(),this._GWizRigidity_Label13_i()];
      }
      
      private function _GWizRigidity_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizRigidity_GWizNumStep3_i(),this._GWizRigidity_Label6_i(),this._GWizRigidity_Label7_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.01;
         _loc1_.max = 100;
         _loc1_.steps = 0.001;
         _loc1_.titleTxt = "Diameter";
         _loc1_.fatSpacer = false;
         _loc1_.addEventListener("valueCommit",this.__tDia_valueCommit);
         _loc1_.id = "tDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tDia = _loc1_;
         BindingManager.executeBindings(this,"tDia",this.tDia);
         return _loc1_;
      }
      
      public function __tDia_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizRigidity_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.000";
         _loc1_.width = 70;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "diaMult";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.diaMult = _loc1_;
         BindingManager.executeBindings(this,"diaMult",this.diaMult);
         return _loc1_;
      }
      
      private function _GWizRigidity_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " as rigid due to diameter difference";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizRigidity_GWizNumStep4_i(),this._GWizRigidity_Label8_i(),this._GWizRigidity_Label9_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.01;
         _loc1_.max = 500;
         _loc1_.steps = 0.001;
         _loc1_.titleTxt = "Length (Holder to Tip)";
         _loc1_.fatSpacer = false;
         _loc1_.addEventListener("valueCommit",this.__tLen_valueCommit);
         _loc1_.id = "tLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tLen = _loc1_;
         BindingManager.executeBindings(this,"tLen",this.tLen);
         return _loc1_;
      }
      
      public function __tLen_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizRigidity_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.000";
         _loc1_.width = 70;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "lenMult";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.lenMult = _loc1_;
         BindingManager.executeBindings(this,"lenMult",this.lenMult);
         return _loc1_;
      }
      
      private function _GWizRigidity_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " as rigid due to length difference";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizRigidity_Label10_i(),this._GWizRigidity_HGroup8_i(),this._GWizRigidity_Label11_i(),this._GWizRigidity_Label12_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Material";
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "_GWizRigidity_Label10";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizRigidity_Label10 = _loc1_;
         BindingManager.executeBindings(this,"_GWizRigidity_Label10",this._GWizRigidity_Label10);
         return _loc1_;
      }
      
      private function _GWizRigidity_HGroup8_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizRigidity_RadioButton3_i(),this._GWizRigidity_RadioButton4_i()];
         _loc1_.id = "tButtons";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tButtons = _loc1_;
         BindingManager.executeBindings(this,"tButtons",this.tButtons);
         return _loc1_;
      }
      
      private function _GWizRigidity_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "HSS";
         _loc1_.selected = true;
         _loc1_.addEventListener("valueCommit",this.__tHSS_valueCommit);
         _loc1_.id = "tHSS";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tHSS = _loc1_;
         BindingManager.executeBindings(this,"tHSS",this.tHSS);
         return _loc1_;
      }
      
      public function __tHSS_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizRigidity_RadioButton4_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Carbide";
         _loc1_.selected = false;
         _loc1_.addEventListener("valueCommit",this.__tCarbide_valueCommit);
         _loc1_.id = "tCarbide";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tCarbide = _loc1_;
         BindingManager.executeBindings(this,"tCarbide",this.tCarbide);
         return _loc1_;
      }
      
      public function __tCarbide_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizRigidity_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.000";
         _loc1_.width = 70;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "matMult";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.matMult = _loc1_;
         BindingManager.executeBindings(this,"matMult",this.matMult);
         return _loc1_;
      }
      
      private function _GWizRigidity_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " as rigid due to material difference";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 40;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRigidity_Label13_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Target Tool is 1x Rigid as the Reference Tool";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Answer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Answer = _loc1_;
         BindingManager.executeBindings(this,"Answer",this.Answer);
         return _loc1_;
      }
      
      public function ___GWizRigidity_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizRigidity_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            _GWizRigidity_Label1.setStyle("color",param1);
         },"_GWizRigidity_Label1.color");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },function(param1:uint):void
         {
            _GWizRigidity_Label1.setStyle("backgroundColor",param1);
         },"_GWizRigidity_Label1.backgroundColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizRigidity_GWizForePanel1.labelBackgroundColor");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizRigidity_GWizForePanel1.labelColor");
         result[4] = new Binding(this,function():Number
         {
            return rLen.theLabel.width;
         },null,"rDia.labelWidth");
         result[5] = new Binding(this,function():Number
         {
            return rButtons.width + rLen.theLabel.width + 7;
         },null,"rDia.width");
         result[6] = new Binding(this,function():Number
         {
            return rDia.width;
         },null,"rLen.width");
         result[7] = new Binding(this,function():Number
         {
            return rLen.theLabel.width;
         },null,"_GWizRigidity_Label4.width");
         result[8] = new Binding(this,null,null,"rHSS.group","refGroup");
         result[9] = new Binding(this,null,null,"rCarbide.group","refGroup");
         result[10] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizRigidity_GWizForePanel2.labelBackgroundColor");
         result[11] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizRigidity_GWizForePanel2.labelColor");
         result[12] = new Binding(this,function():Number
         {
            return tLen.theLabel.width;
         },null,"tDia.labelWidth");
         result[13] = new Binding(this,function():Number
         {
            return tLen.theLabel.width + tButtons.width + 7;
         },null,"tDia.width");
         result[14] = new Binding(this,function():Number
         {
            return tDia.width;
         },null,"tLen.width");
         result[15] = new Binding(this,function():Number
         {
            return tLen.theLabel.width;
         },null,"_GWizRigidity_Label10.width");
         result[16] = new Binding(this,null,null,"tHSS.group","targetGroup");
         result[17] = new Binding(this,null,null,"tCarbide.group","targetGroup");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Answer() : Label
      {
         return this._1966025694Answer;
      }
      
      public function set Answer(param1:Label) : void
      {
         var _loc2_:Object = this._1966025694Answer;
         if(_loc2_ !== param1)
         {
            this._1966025694Answer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Answer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get diaMult() : Label
      {
         return this._1654107084diaMult;
      }
      
      public function set diaMult(param1:Label) : void
      {
         var _loc2_:Object = this._1654107084diaMult;
         if(_loc2_ !== param1)
         {
            this._1654107084diaMult = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"diaMult",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get lenMult() : Label
      {
         return this._61691109lenMult;
      }
      
      public function set lenMult(param1:Label) : void
      {
         var _loc2_:Object = this._61691109lenMult;
         if(_loc2_ !== param1)
         {
            this._61691109lenMult = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"lenMult",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get matMult() : Label
      {
         return this._840219312matMult;
      }
      
      public function set matMult(param1:Label) : void
      {
         var _loc2_:Object = this._840219312matMult;
         if(_loc2_ !== param1)
         {
            this._840219312matMult = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"matMult",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rButtons() : HGroup
      {
         return this._1277078865rButtons;
      }
      
      public function set rButtons(param1:HGroup) : void
      {
         var _loc2_:Object = this._1277078865rButtons;
         if(_loc2_ !== param1)
         {
            this._1277078865rButtons = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rButtons",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rCarbide() : RadioButton
      {
         return this._964547574rCarbide;
      }
      
      public function set rCarbide(param1:RadioButton) : void
      {
         var _loc2_:Object = this._964547574rCarbide;
         if(_loc2_ !== param1)
         {
            this._964547574rCarbide = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rCarbide",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rDia() : GWizNumStep
      {
         return this._3464874rDia;
      }
      
      public function set rDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._3464874rDia;
         if(_loc2_ !== param1)
         {
            this._3464874rDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rHSS() : RadioButton
      {
         return this._3468022rHSS;
      }
      
      public function set rHSS(param1:RadioButton) : void
      {
         var _loc2_:Object = this._3468022rHSS;
         if(_loc2_ !== param1)
         {
            this._3468022rHSS = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rHSS",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rLen() : GWizNumStep
      {
         return this._3472451rLen;
      }
      
      public function set rLen(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._3472451rLen;
         if(_loc2_ !== param1)
         {
            this._3472451rLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rLen",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get refGroup() : RadioButtonGroup
      {
         return this._750276180refGroup;
      }
      
      public function set refGroup(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._750276180refGroup;
         if(_loc2_ !== param1)
         {
            this._750276180refGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"refGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tButtons() : HGroup
      {
         return this._2086425491tButtons;
      }
      
      public function set tButtons(param1:HGroup) : void
      {
         var _loc2_:Object = this._2086425491tButtons;
         if(_loc2_ !== param1)
         {
            this._2086425491tButtons = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tButtons",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tCarbide() : RadioButton
      {
         return this._1773894200tCarbide;
      }
      
      public function set tCarbide(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1773894200tCarbide;
         if(_loc2_ !== param1)
         {
            this._1773894200tCarbide = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tCarbide",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tDia() : GWizNumStep
      {
         return this._3524456tDia;
      }
      
      public function set tDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._3524456tDia;
         if(_loc2_ !== param1)
         {
            this._3524456tDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tHSS() : RadioButton
      {
         return this._3527604tHSS;
      }
      
      public function set tHSS(param1:RadioButton) : void
      {
         var _loc2_:Object = this._3527604tHSS;
         if(_loc2_ !== param1)
         {
            this._3527604tHSS = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tHSS",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tLen() : GWizNumStep
      {
         return this._3532033tLen;
      }
      
      public function set tLen(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._3532033tLen;
         if(_loc2_ !== param1)
         {
            this._3532033tLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tLen",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get targetGroup() : RadioButtonGroup
      {
         return this._2106792082targetGroup;
      }
      
      public function set targetGroup(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._2106792082targetGroup;
         if(_loc2_ !== param1)
         {
            this._2106792082targetGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"targetGroup",_loc2_,param1));
            }
         }
      }
   }
}
