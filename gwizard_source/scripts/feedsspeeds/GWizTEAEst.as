package feedsspeeds
{
   import comps.GWizLabText;
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import utils.GWizGeomUtils;
   
   public class GWizTEAEst extends GWizPopUp
   {
       
      
      private var _798361566RadialEngagement:Label;
      
      private var _92960979angle:NumericStepper;
      
      private var _607835300cutWidth:GWizNumStep;
      
      private var _1654878419diagram:GWizTEADiagram;
      
      private var _114704tea:Label;
      
      private var _1140122684toolDia:GWizLabText;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _diameter:Number = 0.5;
      
      private var _cutWidth:Number = 0.25;
      
      private var _setTEA:Function = null;
      
      private var _tea:Number = 180.0;
      
      public function GWizTEAEst()
      {
         super();
         mx_internal::_document = this;
         this.width = 520;
         this.height = 400;
         this.title = "Tool Engagement Angle Estimator";
         this.okLabel = "Select TEA";
         this.gap = 15;
         this.horizontalAlign = "center";
         this.verticalAlign = "middle";
         this.mxmlContent = [this._GWizTEAEst_HGroup1_c(),this._GWizTEAEst_HGroup2_c(),this._GWizTEAEst_Label3_c(),this._GWizTEAEst_GWizTEADiagram1_i(),this._GWizTEAEst_Label4_i(),this._GWizTEAEst_Label5_c()];
         this.addEventListener("creationComplete",this.___GWizTEAEst_GWizPopUp1_creationComplete);
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
      
      public function setVars(param1:Number, param2:Number, param3:Function) : void
      {
         this._diameter = param1;
         this._cutWidth = param2;
         this._setTEA = param3;
         this.cutWidth.setVal(this._cutWidth);
         this.recalc();
      }
      
      private function recalc() : void
      {
         this._cutWidth = this.cutWidth.getVal();
         if(this._cutWidth > this._diameter)
         {
            this.cutWidth.setVal(this._diameter);
            this._cutWidth = this._diameter;
         }
         this.diagram.drawDiagram(this.angle.value,this._diameter,this._cutWidth);
         this._tea = GWizGeomUtils.recalcCEA(this._diameter,this._cutWidth,this.angle.value);
         this.tea.text = "Tool Enagement Angle: " + this._tea + " degrees";
         this.toolDia.setVal(this._diameter);
         this.RadialEngagement.text = "Radial Engage.: " + String(int(this._cutWidth / this._diameter * 100)) + "%";
      }
      
      private function checkUnits() : void
      {
         this.toolDia.checkUnits();
      }
      
      private function doOK(param1:Boolean) : void
      {
         if(param1 && this._setTEA != null)
         {
            this._setTEA(this._tea,this._cutWidth);
         }
         super.close();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doOK(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doOK(false);
      }
      
      private function _GWizTEAEst_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTEAEst_GWizLabText1_i(),this._GWizTEAEst_GWizNumStep1_i(),this._GWizTEAEst_Label1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTEAEst_GWizLabText1_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labTxt = "Tool Diameter: ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "toolDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolDia = _loc1_;
         BindingManager.executeBindings(this,"toolDia",this.toolDia);
         return _loc1_;
      }
      
      private function _GWizTEAEst_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Cut Width";
         _loc1_.min = 0;
         _loc1_.max = 400;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Width of cut";
         _loc1_.fatSpacer = false;
         _loc1_.addEventListener("valueCommit",this.__cutWidth_valueCommit);
         _loc1_.id = "cutWidth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutWidth = _loc1_;
         BindingManager.executeBindings(this,"cutWidth",this.cutWidth);
         return _loc1_;
      }
      
      public function __cutWidth_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTEAEst_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Radial Engage.: 999.9%";
         _loc1_.width = 175;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "RadialEngagement";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RadialEngagement = _loc1_;
         BindingManager.executeBindings(this,"RadialEngagement",this.RadialEngagement);
         return _loc1_;
      }
      
      private function _GWizTEAEst_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTEAEst_Label2_c(),this._GWizTEAEst_NumericStepper1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTEAEst_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Sharpest corner in toolpath: ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTEAEst_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 180;
         _loc1_.stepSize = 1;
         _loc1_.value = 90;
         _loc1_.addEventListener("valueCommit",this.__angle_valueCommit);
         _loc1_.id = "angle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.angle = _loc1_;
         BindingManager.executeBindings(this,"angle",this.angle);
         return _loc1_;
      }
      
      public function __angle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTEAEst_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "No corners = 180 degrees";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTEAEst_GWizTEADiagram1_i() : GWizTEADiagram
      {
         var _loc1_:GWizTEADiagram = new GWizTEADiagram();
         _loc1_.width = 320;
         _loc1_.height = 160;
         _loc1_.id = "diagram";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.diagram = _loc1_;
         BindingManager.executeBindings(this,"diagram",this.diagram);
         return _loc1_;
      }
      
      private function _GWizTEAEst_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "tea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tea = _loc1_;
         BindingManager.executeBindings(this,"tea",this.tea);
         return _loc1_;
      }
      
      private function _GWizTEAEst_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "(180 degree TEA is Full Slotting)";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizTEAEst_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.checkUnits();
      }
      
      [Bindable(event="propertyChange")]
      public function get RadialEngagement() : Label
      {
         return this._798361566RadialEngagement;
      }
      
      public function set RadialEngagement(param1:Label) : void
      {
         var _loc2_:Object = this._798361566RadialEngagement;
         if(_loc2_ !== param1)
         {
            this._798361566RadialEngagement = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RadialEngagement",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get angle() : NumericStepper
      {
         return this._92960979angle;
      }
      
      public function set angle(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._92960979angle;
         if(_loc2_ !== param1)
         {
            this._92960979angle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"angle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutWidth() : GWizNumStep
      {
         return this._607835300cutWidth;
      }
      
      public function set cutWidth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._607835300cutWidth;
         if(_loc2_ !== param1)
         {
            this._607835300cutWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get diagram() : GWizTEADiagram
      {
         return this._1654878419diagram;
      }
      
      public function set diagram(param1:GWizTEADiagram) : void
      {
         var _loc2_:Object = this._1654878419diagram;
         if(_loc2_ !== param1)
         {
            this._1654878419diagram = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"diagram",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tea() : Label
      {
         return this._114704tea;
      }
      
      public function set tea(param1:Label) : void
      {
         var _loc2_:Object = this._114704tea;
         if(_loc2_ !== param1)
         {
            this._114704tea = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tea",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolDia() : GWizLabText
      {
         return this._1140122684toolDia;
      }
      
      public function set toolDia(param1:GWizLabText) : void
      {
         var _loc2_:Object = this._1140122684toolDia;
         if(_loc2_ !== param1)
         {
            this._1140122684toolDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolDia",_loc2_,param1));
            }
         }
      }
   }
}
