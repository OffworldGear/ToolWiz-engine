package views
{
   import comps.GWizNumStep;
   import comps.GridComponent;
   import flash.events.MouseEvent;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import skins.GridSkin;
   import spark.components.Button;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   public class GWizTruePosition extends Group
   {
       
      
      private var _65193517Clear:Button;
      
      private var _317504755gridArea:GridComponent;
      
      private var _1871634594tp2Label:Label;
      
      private var _1144115752tpLabel:Label;
      
      private var _3660681xVal:GWizNumStep;
      
      private var _3690472yVal:GWizNumStep;
      
      private var _3720263zVal:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizTruePosition()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizTruePosition_GridComponent1_i()];
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         var factory:IFlexModuleFactory = param1;
         super.moduleFactory = factory;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
         if(!this.styleDeclaration)
         {
            this.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
         }
         this.styleDeclaration.defaultFactory = function():void
         {
            this.fontSize = 14;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function recalc() : void
      {
         var _loc1_:Number = NaN;
         _loc1_ = Math.sqrt(this.xVal.value * this.xVal.value + this.yVal.value * this.yVal.value + this.zVal.value * this.zVal.value);
         this.tpLabel.text = GWizUtils.sroundTenths(String(_loc1_));
         this.tp2Label.text = GWizUtils.sroundTenths(String(2 * _loc1_));
      }
      
      private function clear() : void
      {
         this.xVal.setVal(0);
         this.yVal.setVal(0);
         this.zVal.setVal(0);
         this.recalc();
      }
      
      private function _GWizTruePosition_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.showXAxis = false;
         _loc1_.showYAxis = false;
         _loc1_.top = 10;
         _loc1_.bottom = 10;
         _loc1_.left = 10;
         _loc1_.right = 10;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizTruePosition_Array2_c);
         _loc1_.setStyle("skinClass",GridSkin);
         _loc1_.id = "gridArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridArea = _loc1_;
         BindingManager.executeBindings(this,"gridArea",this.gridArea);
         return _loc1_;
      }
      
      private function _GWizTruePosition_Array2_c() : Array
      {
         return [this._GWizTruePosition_VGroup1_c(),this._GWizTruePosition_Button1_i()];
      }
      
      private function _GWizTruePosition_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingBottom = 20;
         _loc1_.paddingLeft = 20;
         _loc1_.paddingRight = 20;
         _loc1_.paddingTop = 20;
         _loc1_.gap = 20;
         _loc1_.mxmlContent = [this._GWizTruePosition_GWizNumStep1_i(),this._GWizTruePosition_GWizNumStep2_i(),this._GWizTruePosition_GWizNumStep3_i(),this._GWizTruePosition_Spacer1_c(),this._GWizTruePosition_HGroup1_c(),this._GWizTruePosition_HGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTruePosition_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Tolerance X";
         _loc1_.labelWidth = 80;
         _loc1_.steps = 0.0001;
         _loc1_.min = -1000;
         _loc1_.max = 1000;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__xVal_valueCommit);
         _loc1_.id = "xVal";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xVal = _loc1_;
         BindingManager.executeBindings(this,"xVal",this.xVal);
         return _loc1_;
      }
      
      public function __xVal_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTruePosition_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Tolerance Y";
         _loc1_.labelWidth = 80;
         _loc1_.steps = 0.0001;
         _loc1_.min = -1000;
         _loc1_.max = 1000;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__yVal_valueCommit);
         _loc1_.id = "yVal";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.yVal = _loc1_;
         BindingManager.executeBindings(this,"yVal",this.yVal);
         return _loc1_;
      }
      
      public function __yVal_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTruePosition_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Tolerance Z";
         _loc1_.labelWidth = 80;
         _loc1_.steps = 0.0001;
         _loc1_.min = -1000;
         _loc1_.max = 1000;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__zVal_valueCommit);
         _loc1_.id = "zVal";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.zVal = _loc1_;
         BindingManager.executeBindings(this,"zVal",this.zVal);
         return _loc1_;
      }
      
      public function __zVal_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTruePosition_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 30;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTruePosition_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.gap = 10;
         _loc1_.mxmlContent = [this._GWizTruePosition_Label1_c(),this._GWizTruePosition_Label2_i(),this._GWizTruePosition_Label3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTruePosition_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "TruePosition";
         _loc1_.width = 80;
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTruePosition_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0000";
         _loc1_.id = "tp2Label";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tp2Label = _loc1_;
         BindingManager.executeBindings(this,"tp2Label",this.tp2Label);
         return _loc1_;
      }
      
      private function _GWizTruePosition_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " (Diametral = Most commonly used)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTruePosition_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.gap = 10;
         _loc1_.mxmlContent = [this._GWizTruePosition_Label4_c(),this._GWizTruePosition_Label5_i(),this._GWizTruePosition_Label6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTruePosition_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 80;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTruePosition_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0000";
         _loc1_.id = "tpLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tpLabel = _loc1_;
         BindingManager.executeBindings(this,"tpLabel",this.tpLabel);
         return _loc1_;
      }
      
      private function _GWizTruePosition_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " (Radial True Position)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTruePosition_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.top = 10;
         _loc1_.right = 10;
         _loc1_.label = "Clear";
         _loc1_.addEventListener("click",this.__Clear_click);
         _loc1_.id = "Clear";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Clear = _loc1_;
         BindingManager.executeBindings(this,"Clear",this.Clear);
         return _loc1_;
      }
      
      public function __Clear_click(param1:MouseEvent) : void
      {
         this.clear();
      }
      
      [Bindable(event="propertyChange")]
      public function get Clear() : Button
      {
         return this._65193517Clear;
      }
      
      public function set Clear(param1:Button) : void
      {
         var _loc2_:Object = this._65193517Clear;
         if(_loc2_ !== param1)
         {
            this._65193517Clear = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Clear",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gridArea() : GridComponent
      {
         return this._317504755gridArea;
      }
      
      public function set gridArea(param1:GridComponent) : void
      {
         var _loc2_:Object = this._317504755gridArea;
         if(_loc2_ !== param1)
         {
            this._317504755gridArea = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gridArea",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tp2Label() : Label
      {
         return this._1871634594tp2Label;
      }
      
      public function set tp2Label(param1:Label) : void
      {
         var _loc2_:Object = this._1871634594tp2Label;
         if(_loc2_ !== param1)
         {
            this._1871634594tp2Label = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tp2Label",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tpLabel() : Label
      {
         return this._1144115752tpLabel;
      }
      
      public function set tpLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1144115752tpLabel;
         if(_loc2_ !== param1)
         {
            this._1144115752tpLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tpLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xVal() : GWizNumStep
      {
         return this._3660681xVal;
      }
      
      public function set xVal(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._3660681xVal;
         if(_loc2_ !== param1)
         {
            this._3660681xVal = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xVal",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yVal() : GWizNumStep
      {
         return this._3690472yVal;
      }
      
      public function set yVal(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._3690472yVal;
         if(_loc2_ !== param1)
         {
            this._3690472yVal = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yVal",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get zVal() : GWizNumStep
      {
         return this._3720263zVal;
      }
      
      public function set zVal(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._3720263zVal;
         if(_loc2_ !== param1)
         {
            this._3720263zVal = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"zVal",_loc2_,param1));
            }
         }
      }
   }
}
