package views
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import spark.events.TextOperationEvent;
   import utils.GWizUtils;
   
   public class GWizAngleChooser extends VGroup
   {
       
      
      private var _407925066DecimalDegrees:TextInput;
      
      private var _1084095737Degrees:NumericStepper;
      
      private var _1565412161Minutes:NumericStepper;
      
      private var _1661504942Radians:TextInput;
      
      private var _660217249Seconds:NumericStepper;
      
      private var _83274TPF:TextInput;
      
      private var _83277TPI:TextInput;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var textInpRef:TextInput;
      
      private var stopRecursion:Boolean = false;
      
      public function GWizAngleChooser()
      {
         super();
         mx_internal::_document = this;
         this.paddingBottom = 5;
         this.paddingLeft = 5;
         this.paddingRight = 5;
         this.paddingTop = 5;
         this.gap = 3;
         this.mxmlContent = [this._GWizAngleChooser_HGroup1_c(),this._GWizAngleChooser_HGroup2_c(),this._GWizAngleChooser_HGroup3_c(),this._GWizAngleChooser_HGroup4_c(),this._GWizAngleChooser_HGroup5_c()];
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
            this.fontSize = 9;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function chooseAngle(param1:String) : void
      {
         this.textInpRef.text = param1;
      }
      
      private function DegreesToDMSDeg(param1:String) : Number
      {
         return Math.floor(Number(param1));
      }
      
      private function DegreesToDMSMin(param1:String) : Number
      {
         var _loc2_:Number = Number(param1);
         return Math.floor((_loc2_ - Math.floor(_loc2_)) * 60);
      }
      
      private function DegreesToDMSSec(param1:String) : Number
      {
         var _loc2_:Number = Number(param1);
         var _loc3_:Number = _loc2_ - Math.floor(_loc2_) - Number(this.DegreesToDMSMin(param1)) / 60;
         return _loc3_ * 3600;
      }
      
      private function DMSToDegrees(param1:Number, param2:Number, param3:Number) : String
      {
         return String(param1 + param2 / 60 + param3 / 3600);
      }
      
      private function recalc(param1:String) : void
      {
         if(this.stopRecursion)
         {
            return;
         }
         this.stopRecursion = true;
         switch(param1)
         {
            case "DecimalAngle":
               this.Radians.text = String(GWizUtils.radians(Number(this.DecimalDegrees.text)));
               this.Degrees.value = this.DegreesToDMSDeg(this.DecimalDegrees.text);
               this.Minutes.value = this.DegreesToDMSMin(this.DecimalDegrees.text);
               this.Seconds.value = this.DegreesToDMSSec(this.DecimalDegrees.text);
               this.TPF.text = String(24 * Math.tan(Number(this.Radians.text) / 2));
               this.TPI.text = String(Number(this.TPF.text) / 12);
               break;
            case "DMSAngle":
               this.DecimalDegrees.text = this.DMSToDegrees(this.Degrees.value,this.Minutes.value,this.Seconds.value);
               this.Radians.text = String(GWizUtils.radians(Number(this.DecimalDegrees.text)));
               this.TPF.text = String(24 * Math.tan(Number(this.Radians.text) / 2));
               this.TPI.text = String(Number(this.TPF.text) / 12);
               break;
            case "RadianAngle":
               this.DecimalDegrees.text = String(GWizUtils.degrees(Number(this.Radians.text)));
               this.Degrees.value = this.DegreesToDMSDeg(this.DecimalDegrees.text);
               this.Minutes.value = this.DegreesToDMSMin(this.DecimalDegrees.text);
               this.Seconds.value = this.DegreesToDMSSec(this.DecimalDegrees.text);
               this.TPF.text = String(24 * Math.tan(Number(this.Radians.text) / 2));
               this.TPI.text = String(Number(this.TPF.text) / 12);
               break;
            case "TPFAngle":
               this.Radians.text = String(2 * Math.atan(Number(this.TPF.text) / 24));
               this.DecimalDegrees.text = String(GWizUtils.degrees(Number(this.Radians.text)));
               this.Degrees.value = this.DegreesToDMSDeg(this.DecimalDegrees.text);
               this.Minutes.value = this.DegreesToDMSMin(this.DecimalDegrees.text);
               this.Seconds.value = this.DegreesToDMSSec(this.DecimalDegrees.text);
               this.TPI.text = String(Number(this.TPF.text) / 12);
               break;
            case "TPIAngle":
               this.TPF.text = String(Number(this.TPI.text) * 12);
               this.DecimalDegrees.text = String(GWizUtils.degrees(Number(this.Radians.text)));
               this.Degrees.value = this.DegreesToDMSDeg(this.DecimalDegrees.text);
               this.Minutes.value = this.DegreesToDMSMin(this.DecimalDegrees.text);
               this.Seconds.value = this.DegreesToDMSSec(this.DecimalDegrees.text);
         }
         this.stopRecursion = false;
      }
      
      private function _GWizAngleChooser_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizAngleChooser_Label1_c(),this._GWizAngleChooser_NumericStepper1_i(),this._GWizAngleChooser_Label2_c(),this._GWizAngleChooser_NumericStepper2_i(),this._GWizAngleChooser_Label3_c(),this._GWizAngleChooser_NumericStepper3_i()];
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 60;
         _loc1_.text = "D:M:S";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",15658734);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.maximum = 999;
         _loc1_.stepSize = 1;
         _loc1_.width = 45;
         _loc1_.height = 18;
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.addEventListener("change",this.__Degrees_change);
         _loc1_.id = "Degrees";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Degrees = _loc1_;
         BindingManager.executeBindings(this,"Degrees",this.Degrees);
         return _loc1_;
      }
      
      public function __Degrees_change(param1:Event) : void
      {
         this.recalc("DMSAngle");
      }
      
      private function _GWizAngleChooser_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = ":";
         _loc1_.width = 10;
         _loc1_.percentHeight = 100;
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.setStyle("verticalAlign","middle");
         _loc1_.setStyle("color",15658734);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 60;
         _loc1_.stepSize = 1;
         _loc1_.width = 45;
         _loc1_.height = 18;
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.addEventListener("change",this.__Minutes_change);
         _loc1_.id = "Minutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Minutes = _loc1_;
         BindingManager.executeBindings(this,"Minutes",this.Minutes);
         return _loc1_;
      }
      
      public function __Minutes_change(param1:Event) : void
      {
         this.recalc("DMSAngle");
      }
      
      private function _GWizAngleChooser_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = ":";
         _loc1_.width = 10;
         _loc1_.percentHeight = 100;
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.setStyle("verticalAlign","middle");
         _loc1_.setStyle("color",15658734);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_NumericStepper3_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 60.999;
         _loc1_.stepSize = 0.001;
         _loc1_.width = 60;
         _loc1_.height = 18;
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.addEventListener("change",this.__Seconds_change);
         _loc1_.id = "Seconds";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Seconds = _loc1_;
         BindingManager.executeBindings(this,"Seconds",this.Seconds);
         return _loc1_;
      }
      
      public function __Seconds_change(param1:Event) : void
      {
         this.recalc("DMSAngle");
      }
      
      private function _GWizAngleChooser_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizAngleChooser_Label4_c(),this._GWizAngleChooser_TextInput1_i(),this._GWizAngleChooser_Button1_c()];
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 60;
         _loc1_.text = "Degrees";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",15658734);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.restrict = "0123456789.";
         _loc1_.height = 18;
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.addEventListener("change",this.__DecimalDegrees_change);
         _loc1_.id = "DecimalDegrees";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DecimalDegrees = _loc1_;
         BindingManager.executeBindings(this,"DecimalDegrees",this.DecimalDegrees);
         return _loc1_;
      }
      
      public function __DecimalDegrees_change(param1:TextOperationEvent) : void
      {
         this.recalc("DecimalAngle");
      }
      
      private function _GWizAngleChooser_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Use";
         _loc1_.width = 50;
         _loc1_.height = 18;
         _loc1_.setStyle("color",734012);
         _loc1_.addEventListener("click",this.___GWizAngleChooser_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizAngleChooser_Button1_click(param1:MouseEvent) : void
      {
         this.chooseAngle(this.DecimalDegrees.text);
      }
      
      private function _GWizAngleChooser_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizAngleChooser_Label5_c(),this._GWizAngleChooser_TextInput2_i(),this._GWizAngleChooser_Button2_c()];
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 60;
         _loc1_.text = "Radians";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",15658734);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.restrict = "0123456789.";
         _loc1_.height = 18;
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.addEventListener("change",this.__Radians_change);
         _loc1_.id = "Radians";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Radians = _loc1_;
         BindingManager.executeBindings(this,"Radians",this.Radians);
         return _loc1_;
      }
      
      public function __Radians_change(param1:TextOperationEvent) : void
      {
         this.recalc("RadianAngle");
      }
      
      private function _GWizAngleChooser_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Use";
         _loc1_.width = 50;
         _loc1_.height = 18;
         _loc1_.setStyle("color",734012);
         _loc1_.addEventListener("click",this.___GWizAngleChooser_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizAngleChooser_Button2_click(param1:MouseEvent) : void
      {
         this.chooseAngle(this.Radians.text);
      }
      
      private function _GWizAngleChooser_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizAngleChooser_Label6_c(),this._GWizAngleChooser_TextInput3_i(),this._GWizAngleChooser_Button3_c()];
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 60;
         _loc1_.text = "Taper/Foot";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",15658734);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.restrict = "0123456789.";
         _loc1_.height = 18;
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.addEventListener("change",this.__TPF_change);
         _loc1_.id = "TPF";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TPF = _loc1_;
         BindingManager.executeBindings(this,"TPF",this.TPF);
         return _loc1_;
      }
      
      public function __TPF_change(param1:TextOperationEvent) : void
      {
         this.recalc("TPFAngle");
      }
      
      private function _GWizAngleChooser_Button3_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Use";
         _loc1_.width = 50;
         _loc1_.height = 18;
         _loc1_.setStyle("color",734012);
         _loc1_.addEventListener("click",this.___GWizAngleChooser_Button3_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizAngleChooser_Button3_click(param1:MouseEvent) : void
      {
         this.chooseAngle(this.TPF.text);
      }
      
      private function _GWizAngleChooser_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizAngleChooser_Label7_c(),this._GWizAngleChooser_TextInput4_i(),this._GWizAngleChooser_Button4_c()];
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 60;
         _loc1_.text = "Taper/Inch";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",15658734);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAngleChooser_TextInput4_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.restrict = "0123456789.";
         _loc1_.height = 18;
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("fontWeight","normal");
         _loc1_.addEventListener("change",this.__TPI_change);
         _loc1_.id = "TPI";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TPI = _loc1_;
         BindingManager.executeBindings(this,"TPI",this.TPI);
         return _loc1_;
      }
      
      public function __TPI_change(param1:TextOperationEvent) : void
      {
         this.recalc("TPIAngle");
      }
      
      private function _GWizAngleChooser_Button4_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Use";
         _loc1_.width = 50;
         _loc1_.height = 18;
         _loc1_.setStyle("color",734012);
         _loc1_.addEventListener("click",this.___GWizAngleChooser_Button4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizAngleChooser_Button4_click(param1:MouseEvent) : void
      {
         this.chooseAngle(this.TPI.text);
      }
      
      [Bindable(event="propertyChange")]
      public function get DecimalDegrees() : TextInput
      {
         return this._407925066DecimalDegrees;
      }
      
      public function set DecimalDegrees(param1:TextInput) : void
      {
         var _loc2_:Object = this._407925066DecimalDegrees;
         if(_loc2_ !== param1)
         {
            this._407925066DecimalDegrees = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DecimalDegrees",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Degrees() : NumericStepper
      {
         return this._1084095737Degrees;
      }
      
      public function set Degrees(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1084095737Degrees;
         if(_loc2_ !== param1)
         {
            this._1084095737Degrees = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Degrees",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Minutes() : NumericStepper
      {
         return this._1565412161Minutes;
      }
      
      public function set Minutes(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1565412161Minutes;
         if(_loc2_ !== param1)
         {
            this._1565412161Minutes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Minutes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Radians() : TextInput
      {
         return this._1661504942Radians;
      }
      
      public function set Radians(param1:TextInput) : void
      {
         var _loc2_:Object = this._1661504942Radians;
         if(_loc2_ !== param1)
         {
            this._1661504942Radians = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Radians",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Seconds() : NumericStepper
      {
         return this._660217249Seconds;
      }
      
      public function set Seconds(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._660217249Seconds;
         if(_loc2_ !== param1)
         {
            this._660217249Seconds = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Seconds",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TPF() : TextInput
      {
         return this._83274TPF;
      }
      
      public function set TPF(param1:TextInput) : void
      {
         var _loc2_:Object = this._83274TPF;
         if(_loc2_ !== param1)
         {
            this._83274TPF = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TPF",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TPI() : TextInput
      {
         return this._83277TPI;
      }
      
      public function set TPI(param1:TextInput) : void
      {
         var _loc2_:Object = this._83277TPI;
         if(_loc2_ !== param1)
         {
            this._83277TPI = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TPI",_loc2_,param1));
            }
         }
      }
   }
}
