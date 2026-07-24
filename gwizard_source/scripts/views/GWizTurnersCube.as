package views
{
   import comps.GridComponent;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import skins.GridSkin;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   public class GWizTurnersCube extends Group
   {
       
      
      private var _442094161face1Depth:Label;
      
      private var _495628904face1Dia:Label;
      
      private var _413465010face2Depth:Label;
      
      private var _495658695face2Dia:Label;
      
      private var _384835859face3Depth:Label;
      
      private var _495688486face3Dia:Label;
      
      private var _356206708face4Depth:Label;
      
      private var _495718277face4Dia:Label;
      
      private var _1779181207faceWidth:NumericStepper;
      
      private var _317504755gridArea:GridComponent;
      
      private var _1091287993overlap:NumericStepper;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var faceWidthIdeal:Number = 4;
      
      private var face1DiaIdeal:Number = 0.571;
      
      private var face2DiaIdeal:Number = 1.572;
      
      private var face3DiaIdeal:Number = 2.64;
      
      private var face4DiaIdeal:Number = 3.63;
      
      private var face1DepthIdeal:Number = 2;
      
      private var face2DepthIdeal:Number = 1.5;
      
      private var face3DepthIdeal:Number = 1;
      
      private var face4DepthIdeal:Number = 0.5;
      
      private var _embed_mxml_assets_CubeThumb_jpg_1791119838:Class;
      
      public function GWizTurnersCube()
      {
         this._embed_mxml_assets_CubeThumb_jpg_1791119838 = GWizTurnersCube__embed_mxml_assets_CubeThumb_jpg_1791119838;
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizTurnersCube_GridComponent1_i()];
         this.addEventListener("creationComplete",this.___GWizTurnersCube_Group1_creationComplete);
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
      
      private function holeDepth(param1:Number, param2:Number) : Number
      {
         param1 /= 2;
         param1 *= param2 / 100 + 1;
         param1 *= Math.cos(GWizUtils.radians(45));
         return Number(this.faceWidth.value / 2 - param1);
      }
      
      private function recalc() : void
      {
         var _loc1_:Number = this.faceWidth.value / this.faceWidthIdeal;
         this.face1Dia.text = String(GWizUtils.roundThousandths(this.face1DiaIdeal * _loc1_));
         this.face2Dia.text = String(GWizUtils.roundThousandths(this.face2DiaIdeal * _loc1_));
         this.face3Dia.text = String(GWizUtils.roundThousandths(this.face3DiaIdeal * _loc1_));
         this.face4Dia.text = String(GWizUtils.roundThousandths(this.face4DiaIdeal * _loc1_));
         this.face1Depth.text = String(GWizUtils.roundThousandths(this.holeDepth(Number(this.face1Dia.text),this.overlap.value)));
         this.face2Depth.text = String(GWizUtils.roundThousandths(this.holeDepth(Number(this.face2Dia.text),this.overlap.value)));
         this.face3Depth.text = String(GWizUtils.roundThousandths(this.holeDepth(Number(this.face3Dia.text),this.overlap.value)));
         this.face4Depth.text = String(GWizUtils.roundThousandths(this.holeDepth(Number(this.face4Dia.text),this.overlap.value)));
      }
      
      private function _GWizTurnersCube_GridComponent1_i() : GridComponent
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
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizTurnersCube_Array2_c);
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
      
      private function _GWizTurnersCube_Array2_c() : Array
      {
         return [this._GWizTurnersCube_VGroup1_c(),this._GWizTurnersCube_Image1_c()];
      }
      
      private function _GWizTurnersCube_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.x = 10;
         _loc1_.y = 10;
         _loc1_.mxmlContent = [this._GWizTurnersCube_Label1_c(),this._GWizTurnersCube_HGroup1_c(),this._GWizTurnersCube_HGroup2_c(),this._GWizTurnersCube_HGroup3_c(),this._GWizTurnersCube_HGroup4_c(),this._GWizTurnersCube_HGroup5_c(),this._GWizTurnersCube_HGroup6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Turner\'s Cube Designer";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTurnersCube_Label2_c(),this._GWizTurnersCube_NumericStepper1_i(),this._GWizTurnersCube_Spacer1_c(),this._GWizTurnersCube_Label3_c(),this._GWizTurnersCube_NumericStepper2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Face Width:";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.value = 4;
         _loc1_.maximum = 100;
         _loc1_.minimum = 0.1;
         _loc1_.stepSize = 0.1;
         _loc1_.setStyle("fontSize",12);
         _loc1_.addEventListener("valueCommit",this.__faceWidth_valueCommit);
         _loc1_.id = "faceWidth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.faceWidth = _loc1_;
         BindingManager.executeBindings(this,"faceWidth",this.faceWidth);
         return _loc1_;
      }
      
      public function __faceWidth_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTurnersCube_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 40;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Overlap (%):";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",12);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.value = 10;
         _loc1_.minimum = 5;
         _loc1_.maximum = 30;
         _loc1_.toolTip = "% of cube corner embedded in wall.";
         _loc1_.addEventListener("valueCommit",this.__overlap_valueCommit);
         _loc1_.id = "overlap";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.overlap = _loc1_;
         BindingManager.executeBindings(this,"overlap",this.overlap);
         return _loc1_;
      }
      
      public function __overlap_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTurnersCube_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizTurnersCube_Label4_c(),this._GWizTurnersCube_Label5_c(),this._GWizTurnersCube_Label6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "Face";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "Diameter";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "Depth";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizTurnersCube_Label7_c(),this._GWizTurnersCube_Label8_i(),this._GWizTurnersCube_Label9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "1 (Smallest)";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "0";
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "face1Dia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.face1Dia = _loc1_;
         BindingManager.executeBindings(this,"face1Dia",this.face1Dia);
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "0";
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "face1Depth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.face1Depth = _loc1_;
         BindingManager.executeBindings(this,"face1Depth",this.face1Depth);
         return _loc1_;
      }
      
      private function _GWizTurnersCube_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizTurnersCube_Label10_c(),this._GWizTurnersCube_Label11_i(),this._GWizTurnersCube_Label12_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "2";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "0";
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "face2Dia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.face2Dia = _loc1_;
         BindingManager.executeBindings(this,"face2Dia",this.face2Dia);
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label12_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "0";
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "face2Depth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.face2Depth = _loc1_;
         BindingManager.executeBindings(this,"face2Depth",this.face2Depth);
         return _loc1_;
      }
      
      private function _GWizTurnersCube_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizTurnersCube_Label13_c(),this._GWizTurnersCube_Label14_i(),this._GWizTurnersCube_Label15_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "3";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label14_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "0";
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "face3Dia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.face3Dia = _loc1_;
         BindingManager.executeBindings(this,"face3Dia",this.face3Dia);
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "0";
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "face3Depth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.face3Depth = _loc1_;
         BindingManager.executeBindings(this,"face3Depth",this.face3Depth);
         return _loc1_;
      }
      
      private function _GWizTurnersCube_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizTurnersCube_Label16_c(),this._GWizTurnersCube_Label17_i(),this._GWizTurnersCube_Label18_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label16_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "4 (Largest)";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label17_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "0";
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "face4Dia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.face4Dia = _loc1_;
         BindingManager.executeBindings(this,"face4Dia",this.face4Dia);
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Label18_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 33;
         _loc1_.text = "0";
         _loc1_.setStyle("fontSize",12);
         _loc1_.id = "face4Depth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.face4Depth = _loc1_;
         BindingManager.executeBindings(this,"face4Depth",this.face4Depth);
         return _loc1_;
      }
      
      private function _GWizTurnersCube_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.top = 10;
         _loc1_.right = 10;
         _loc1_.source = this._embed_mxml_assets_CubeThumb_jpg_1791119838;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizTurnersCube_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      [Bindable(event="propertyChange")]
      public function get face1Depth() : Label
      {
         return this._442094161face1Depth;
      }
      
      public function set face1Depth(param1:Label) : void
      {
         var _loc2_:Object = this._442094161face1Depth;
         if(_loc2_ !== param1)
         {
            this._442094161face1Depth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"face1Depth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get face1Dia() : Label
      {
         return this._495628904face1Dia;
      }
      
      public function set face1Dia(param1:Label) : void
      {
         var _loc2_:Object = this._495628904face1Dia;
         if(_loc2_ !== param1)
         {
            this._495628904face1Dia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"face1Dia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get face2Depth() : Label
      {
         return this._413465010face2Depth;
      }
      
      public function set face2Depth(param1:Label) : void
      {
         var _loc2_:Object = this._413465010face2Depth;
         if(_loc2_ !== param1)
         {
            this._413465010face2Depth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"face2Depth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get face2Dia() : Label
      {
         return this._495658695face2Dia;
      }
      
      public function set face2Dia(param1:Label) : void
      {
         var _loc2_:Object = this._495658695face2Dia;
         if(_loc2_ !== param1)
         {
            this._495658695face2Dia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"face2Dia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get face3Depth() : Label
      {
         return this._384835859face3Depth;
      }
      
      public function set face3Depth(param1:Label) : void
      {
         var _loc2_:Object = this._384835859face3Depth;
         if(_loc2_ !== param1)
         {
            this._384835859face3Depth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"face3Depth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get face3Dia() : Label
      {
         return this._495688486face3Dia;
      }
      
      public function set face3Dia(param1:Label) : void
      {
         var _loc2_:Object = this._495688486face3Dia;
         if(_loc2_ !== param1)
         {
            this._495688486face3Dia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"face3Dia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get face4Depth() : Label
      {
         return this._356206708face4Depth;
      }
      
      public function set face4Depth(param1:Label) : void
      {
         var _loc2_:Object = this._356206708face4Depth;
         if(_loc2_ !== param1)
         {
            this._356206708face4Depth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"face4Depth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get face4Dia() : Label
      {
         return this._495718277face4Dia;
      }
      
      public function set face4Dia(param1:Label) : void
      {
         var _loc2_:Object = this._495718277face4Dia;
         if(_loc2_ !== param1)
         {
            this._495718277face4Dia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"face4Dia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get faceWidth() : NumericStepper
      {
         return this._1779181207faceWidth;
      }
      
      public function set faceWidth(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1779181207faceWidth;
         if(_loc2_ !== param1)
         {
            this._1779181207faceWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"faceWidth",_loc2_,param1));
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
      public function get overlap() : NumericStepper
      {
         return this._1091287993overlap;
      }
      
      public function set overlap(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1091287993overlap;
         if(_loc2_ !== param1)
         {
            this._1091287993overlap = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"overlap",_loc2_,param1));
            }
         }
      }
   }
}
