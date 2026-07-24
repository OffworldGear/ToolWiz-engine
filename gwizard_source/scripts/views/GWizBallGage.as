package views
{
   import comps.GWizNumStep;
   import comps.GridComponent;
   import mx.binding.BindingManager;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GridSkin;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   public class GWizBallGage extends Group
   {
      
      private static const log:ILogger = Log.getLogger("GWizBallGage");
       
      
      private var _225640097EdgeDia:Label;
      
      private var _1595091635EdgeDia2:Label;
      
      private var _92960979angle:GWizNumStep;
      
      private var _338898435ballDia:GWizNumStep;
      
      private var _1915916843ballDia2:GWizNumStep;
      
      private var _1938875964ballGageImage:Image;
      
      private var _2004760692gageBlocksInput:RadioButtonGroup;
      
      private var _317504755gridArea:GridComponent;
      
      private var _580981137measHeight:GWizNumStep;
      
      private var _830546113measHeight2:GWizNumStep;
      
      private var _89187654sbSizeInput:RadioButtonGroup;
      
      private var _865050057ssSizeInput:RadioButtonGroup;
      
      private var _954445307stackSzInput:RadioButtonGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _embed_mxml_assets_BallGage_jpg_1727561984:Class;
      
      public function GWizBallGage()
      {
         this._embed_mxml_assets_BallGage_jpg_1727561984 = GWizBallGage__embed_mxml_assets_BallGage_jpg_1727561984;
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizBallGage_GridComponent1_i()];
         this._GWizBallGage_RadioButtonGroup2_i();
         this._GWizBallGage_RadioButtonGroup3_i();
         this._GWizBallGage_RadioButtonGroup4_i();
         this._GWizBallGage_RadioButtonGroup1_i();
         this.addEventListener("creationComplete",this.___GWizBallGage_Group1_creationComplete);
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
      }
      
      private function recalc() : void
      {
         var _loc5_:Number = NaN;
         var _loc1_:Number = Math.sqrt((this.ballDia.value - this.measHeight.value) * this.measHeight.value) * 2;
         this.EdgeDia.text = "  Edge Diameter: " + String(_loc1_);
         var _loc2_:Number = this.measHeight2.value;
         var _loc3_:Number = this.ballDia2.value / 2;
         var _loc4_:Number = GWizUtils.radians(this.angle.value);
         if(_loc2_ <= _loc3_ + _loc3_ * Math.sin(_loc4_ / 2))
         {
            _loc5_ = 2 * (_loc3_ + _loc3_ / Math.sin(_loc4_ / 2) - _loc2_) * Math.tan(_loc4_ / 2);
         }
         else
         {
            _loc5_ = 2 * _loc3_ * Math.sin(Math.acos((_loc2_ - _loc3_) / _loc3_));
         }
         this.EdgeDia2.text = "  Edge Diameter: " + String(_loc5_);
      }
      
      private function _GWizBallGage_RadioButtonGroup2_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"gageBlocksInput");
         this.gageBlocksInput = _loc1_;
         BindingManager.executeBindings(this,"gageBlocksInput",this.gageBlocksInput);
         return _loc1_;
      }
      
      private function _GWizBallGage_RadioButtonGroup3_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"sbSizeInput");
         this.sbSizeInput = _loc1_;
         BindingManager.executeBindings(this,"sbSizeInput",this.sbSizeInput);
         return _loc1_;
      }
      
      private function _GWizBallGage_RadioButtonGroup4_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"ssSizeInput");
         this.ssSizeInput = _loc1_;
         BindingManager.executeBindings(this,"ssSizeInput",this.ssSizeInput);
         return _loc1_;
      }
      
      private function _GWizBallGage_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"stackSzInput");
         this.stackSzInput = _loc1_;
         BindingManager.executeBindings(this,"stackSzInput",this.stackSzInput);
         return _loc1_;
      }
      
      private function _GWizBallGage_GridComponent1_i() : GridComponent
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
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizBallGage_Array2_c);
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
      
      private function _GWizBallGage_Array2_c() : Array
      {
         return [this._GWizBallGage_HGroup1_c()];
      }
      
      private function _GWizBallGage_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.x = 10;
         _loc1_.y = 10;
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizBallGage_VGroup1_c(),this._GWizBallGage_Image1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 50;
         _loc1_.mxmlContent = [this._GWizBallGage_Label1_c(),this._GWizBallGage_Label2_c(),this._GWizBallGage_GWizNumStep1_i(),this._GWizBallGage_GWizNumStep2_i(),this._GWizBallGage_Label3_i(),this._GWizBallGage_Label4_c(),this._GWizBallGage_Label5_c(),this._GWizBallGage_Label6_c(),this._GWizBallGage_Label7_c(),this._GWizBallGage_Label8_c(),this._GWizBallGage_Label9_c(),this._GWizBallGage_Label10_c(),this._GWizBallGage_Label11_c(),this._GWizBallGage_Label12_c(),this._GWizBallGage_GWizNumStep3_i(),this._GWizBallGage_GWizNumStep4_i(),this._GWizBallGage_GWizNumStep5_i(),this._GWizBallGage_Label13_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole Diameter";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "  Ball Dia. (B): ";
         _loc1_.min = 0.01;
         _loc1_.max = 50;
         _loc1_.steps = 0.0001;
         _loc1_.value = 0;
         _loc1_.addEventListener("valueCommit",this.__ballDia_valueCommit);
         _loc1_.id = "ballDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ballDia = _loc1_;
         BindingManager.executeBindings(this,"ballDia",this.ballDia);
         return _loc1_;
      }
      
      public function __ballDia_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizBallGage_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "  Measured Height (H): ";
         _loc1_.min = 0;
         _loc1_.max = 50;
         _loc1_.steps = 0.0001;
         _loc1_.value = 0;
         _loc1_.addEventListener("valueCommit",this.__measHeight_valueCommit);
         _loc1_.id = "measHeight";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.measHeight = _loc1_;
         BindingManager.executeBindings(this,"measHeight",this.measHeight);
         return _loc1_;
      }
      
      public function __measHeight_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizBallGage_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "  Edge Diameter: ";
         _loc1_.id = "EdgeDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EdgeDia = _loc1_;
         BindingManager.executeBindings(this,"EdgeDia",this.EdgeDia);
         return _loc1_;
      }
      
      private function _GWizBallGage_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_Label11_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Countersink Diameter";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBallGage_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "  Ball Dia. (B): ";
         _loc1_.min = 0.01;
         _loc1_.max = 50;
         _loc1_.steps = 0.0001;
         _loc1_.value = 0;
         _loc1_.addEventListener("valueCommit",this.__ballDia2_valueCommit);
         _loc1_.id = "ballDia2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ballDia2 = _loc1_;
         BindingManager.executeBindings(this,"ballDia2",this.ballDia2);
         return _loc1_;
      }
      
      public function __ballDia2_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizBallGage_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "  Measured Height (H): ";
         _loc1_.min = 0.01;
         _loc1_.max = 50;
         _loc1_.steps = 0.0001;
         _loc1_.value = 0;
         _loc1_.addEventListener("valueCommit",this.__measHeight2_valueCommit);
         _loc1_.id = "measHeight2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.measHeight2 = _loc1_;
         BindingManager.executeBindings(this,"measHeight2",this.measHeight2);
         return _loc1_;
      }
      
      public function __measHeight2_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizBallGage_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "  Countersink Angle (Degrees): ";
         _loc1_.min = 0;
         _loc1_.max = 360;
         _loc1_.steps = 0.0001;
         _loc1_.value = 0;
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
      
      private function _GWizBallGage_Label13_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "  Edge Diameter: ";
         _loc1_.id = "EdgeDia2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EdgeDia2 = _loc1_;
         BindingManager.executeBindings(this,"EdgeDia2",this.EdgeDia2);
         return _loc1_;
      }
      
      private function _GWizBallGage_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml_assets_BallGage_jpg_1727561984;
         _loc1_.top = 20;
         _loc1_.bottom = 20;
         _loc1_.left = 20;
         _loc1_.right = 20;
         _loc1_.smooth = true;
         _loc1_.x = 50;
         _loc1_.id = "ballGageImage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ballGageImage = _loc1_;
         BindingManager.executeBindings(this,"ballGageImage",this.ballGageImage);
         return _loc1_;
      }
      
      public function ___GWizBallGage_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get EdgeDia() : Label
      {
         return this._225640097EdgeDia;
      }
      
      public function set EdgeDia(param1:Label) : void
      {
         var _loc2_:Object = this._225640097EdgeDia;
         if(_loc2_ !== param1)
         {
            this._225640097EdgeDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EdgeDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EdgeDia2() : Label
      {
         return this._1595091635EdgeDia2;
      }
      
      public function set EdgeDia2(param1:Label) : void
      {
         var _loc2_:Object = this._1595091635EdgeDia2;
         if(_loc2_ !== param1)
         {
            this._1595091635EdgeDia2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EdgeDia2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get angle() : GWizNumStep
      {
         return this._92960979angle;
      }
      
      public function set angle(param1:GWizNumStep) : void
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
      public function get ballDia() : GWizNumStep
      {
         return this._338898435ballDia;
      }
      
      public function set ballDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._338898435ballDia;
         if(_loc2_ !== param1)
         {
            this._338898435ballDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ballDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ballDia2() : GWizNumStep
      {
         return this._1915916843ballDia2;
      }
      
      public function set ballDia2(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1915916843ballDia2;
         if(_loc2_ !== param1)
         {
            this._1915916843ballDia2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ballDia2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ballGageImage() : Image
      {
         return this._1938875964ballGageImage;
      }
      
      public function set ballGageImage(param1:Image) : void
      {
         var _loc2_:Object = this._1938875964ballGageImage;
         if(_loc2_ !== param1)
         {
            this._1938875964ballGageImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ballGageImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gageBlocksInput() : RadioButtonGroup
      {
         return this._2004760692gageBlocksInput;
      }
      
      public function set gageBlocksInput(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._2004760692gageBlocksInput;
         if(_loc2_ !== param1)
         {
            this._2004760692gageBlocksInput = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gageBlocksInput",_loc2_,param1));
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
      public function get measHeight() : GWizNumStep
      {
         return this._580981137measHeight;
      }
      
      public function set measHeight(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._580981137measHeight;
         if(_loc2_ !== param1)
         {
            this._580981137measHeight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"measHeight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get measHeight2() : GWizNumStep
      {
         return this._830546113measHeight2;
      }
      
      public function set measHeight2(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._830546113measHeight2;
         if(_loc2_ !== param1)
         {
            this._830546113measHeight2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"measHeight2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sbSizeInput() : RadioButtonGroup
      {
         return this._89187654sbSizeInput;
      }
      
      public function set sbSizeInput(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._89187654sbSizeInput;
         if(_loc2_ !== param1)
         {
            this._89187654sbSizeInput = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sbSizeInput",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ssSizeInput() : RadioButtonGroup
      {
         return this._865050057ssSizeInput;
      }
      
      public function set ssSizeInput(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._865050057ssSizeInput;
         if(_loc2_ !== param1)
         {
            this._865050057ssSizeInput = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ssSizeInput",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stackSzInput() : RadioButtonGroup
      {
         return this._954445307stackSzInput;
      }
      
      public function set stackSzInput(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._954445307stackSzInput;
         if(_loc2_ !== param1)
         {
            this._954445307stackSzInput = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stackSzInput",_loc2_,param1));
            }
         }
      }
   }
}
