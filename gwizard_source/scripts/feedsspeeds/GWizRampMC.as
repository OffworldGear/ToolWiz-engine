package feedsspeeds
{
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   public class GWizRampMC extends GWizPopUp
   {
       
      
      private var _1653015787RampAdj:Label;
      
      private var _1653015480RampAng:NumericStepper;
      
      private var _1644997178RawFeed:Label;
      
      private var _1505867908Warning:Label;
      
      private var _1700880644fromCutBtn:Button;
      
      private var _792068028passLen:GWizNumStep;
      
      private var _51778217passLenLab:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var feed:Number = 0;
      
      private var fromCut:Boolean = false;
      
      private var _embed_mxml__assets_Ramp_jpg_1576773004:Class;
      
      public function GWizRampMC()
      {
         this._embed_mxml__assets_Ramp_jpg_1576773004 = GWizRampMC__embed_mxml__assets_Ramp_jpg_1576773004;
         super();
         mx_internal::_document = this;
         this.width = 500;
         this.height = 284;
         this.title = "Ramping Mini-Calc";
         this.okLabel = "Adjust Feedrate";
         this.gap = 10;
         this.mxmlContent = [this._GWizRampMC_HGroup1_c(),this._GWizRampMC_HGroup2_c()];
         this.addEventListener("creationComplete",this.___GWizRampMC_GWizPopUp1_creationComplete);
      }
      
      public static function rampFeedrate(param1:Number, param2:Number, param3:Number, param4:int) : Number
      {
         var _loc5_:Number = 0;
         var _loc6_:Number = param1;
         if(param2 > 0)
         {
            _loc5_ = Math.atan(_loc6_ / param2) * 180 / Math.PI;
         }
         var _loc7_:Number = Math.min(1,_loc5_ / 90);
         return Number((1 - _loc7_) * param3 + _loc7_ * (param3 / param4));
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
         this.recalc();
      }
      
      private function recalc() : void
      {
         var _loc3_:Number = NaN;
         this.feed = GWizSettings.FeedsSpeedsApp.IPM.getVal();
         this.RawFeed.text = "Raw feedrate: " + GWizUtils.roundThousandths(this.feed,true);
         var _loc1_:Number = 0;
         if(this.passLen.visible)
         {
            _loc3_ = GWizSettings.FeedsSpeedsApp.cutDepth.getVal();
            if(this.passLen.value > 0)
            {
               _loc1_ = Math.atan(_loc3_ / this.passLen.value) * 180 / Math.PI;
            }
            this.RampAng.value = _loc1_;
         }
         _loc1_ = this.RampAng.value;
         var _loc2_:Number = Math.min(1,_loc1_ / 90);
         this.feed = (1 - _loc2_) * this.feed + _loc2_ * (this.feed / GWizSettings.FeedsSpeedsApp.td.toolParms.flutes);
         this.RampAdj.text = "Geometry adjusted feedrate: " + GWizUtils.roundThousandths(this.feed,true);
         this.Warning.text = "Warning:\n";
         this.Warning.text += "Check manufacturer\'s recommended\n";
         this.Warning.text += "ramp angle to avoid rubbing.\n";
      }
      
      private function doAdjust(param1:Boolean) : void
      {
         if(param1)
         {
            GWizSettings.FeedsSpeedsApp.IPM.setValOverride(this.feed);
         }
         super.close();
      }
      
      private function doFromCut() : void
      {
         this.fromCut = !this.fromCut;
         this.passLenLab.visible = this.fromCut;
         this.passLen.visible = this.fromCut;
         this.recalc();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doAdjust(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doAdjust(false);
      }
      
      private function _GWizRampMC_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizRampMC_Label1_c(),this._GWizRampMC_NumericStepper1_i(),this._GWizRampMC_Button1_i(),this._GWizRampMC_Label2_i(),this._GWizRampMC_GWizNumStep1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRampMC_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Ramp Angle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRampMC_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.maximum = 90;
         _loc1_.stepSize = 0.1;
         _loc1_.addEventListener("valueCommit",this.__RampAng_valueCommit);
         _loc1_.id = "RampAng";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RampAng = _loc1_;
         BindingManager.executeBindings(this,"RampAng",this.RampAng);
         return _loc1_;
      }
      
      public function __RampAng_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizRampMC_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "From Cut Depth";
         _loc1_.setStyle("color",131586);
         _loc1_.addEventListener("click",this.__fromCutBtn_click);
         _loc1_.id = "fromCutBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fromCutBtn = _loc1_;
         BindingManager.executeBindings(this,"fromCutBtn",this.fromCutBtn);
         return _loc1_;
      }
      
      public function __fromCutBtn_click(param1:MouseEvent) : void
      {
         this.doFromCut();
      }
      
      private function _GWizRampMC_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Pass Length";
         _loc1_.visible = false;
         _loc1_.id = "passLenLab";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.passLenLab = _loc1_;
         BindingManager.executeBindings(this,"passLenLab",this.passLenLab);
         return _loc1_;
      }
      
      private function _GWizRampMC_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.visible = false;
         _loc1_.min = 0;
         _loc1_.max = 100;
         _loc1_.steps = 0.001;
         _loc1_.addEventListener("valueCommit",this.__passLen_valueCommit);
         _loc1_.id = "passLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.passLen = _loc1_;
         BindingManager.executeBindings(this,"passLen",this.passLen);
         return _loc1_;
      }
      
      public function __passLen_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizRampMC_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizRampMC_VGroup1_c(),this._GWizRampMC_Image1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRampMC_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.gap = 5;
         _loc1_.mxmlContent = [this._GWizRampMC_Label3_i(),this._GWizRampMC_Label4_i(),this._GWizRampMC_Label5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizRampMC_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Raw Feedrate";
         _loc1_.id = "RawFeed";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RawFeed = _loc1_;
         BindingManager.executeBindings(this,"RawFeed",this.RawFeed);
         return _loc1_;
      }
      
      private function _GWizRampMC_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Ramp Adjusted Feed";
         _loc1_.id = "RampAdj";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RampAdj = _loc1_;
         BindingManager.executeBindings(this,"RampAdj",this.RampAdj);
         return _loc1_;
      }
      
      private function _GWizRampMC_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Warning";
         _loc1_.id = "Warning";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Warning = _loc1_;
         BindingManager.executeBindings(this,"Warning",this.Warning);
         return _loc1_;
      }
      
      private function _GWizRampMC_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_Ramp_jpg_1576773004;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizRampMC_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get RampAdj() : Label
      {
         return this._1653015787RampAdj;
      }
      
      public function set RampAdj(param1:Label) : void
      {
         var _loc2_:Object = this._1653015787RampAdj;
         if(_loc2_ !== param1)
         {
            this._1653015787RampAdj = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RampAdj",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RampAng() : NumericStepper
      {
         return this._1653015480RampAng;
      }
      
      public function set RampAng(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1653015480RampAng;
         if(_loc2_ !== param1)
         {
            this._1653015480RampAng = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RampAng",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RawFeed() : Label
      {
         return this._1644997178RawFeed;
      }
      
      public function set RawFeed(param1:Label) : void
      {
         var _loc2_:Object = this._1644997178RawFeed;
         if(_loc2_ !== param1)
         {
            this._1644997178RawFeed = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RawFeed",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Warning() : Label
      {
         return this._1505867908Warning;
      }
      
      public function set Warning(param1:Label) : void
      {
         var _loc2_:Object = this._1505867908Warning;
         if(_loc2_ !== param1)
         {
            this._1505867908Warning = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Warning",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fromCutBtn() : Button
      {
         return this._1700880644fromCutBtn;
      }
      
      public function set fromCutBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1700880644fromCutBtn;
         if(_loc2_ !== param1)
         {
            this._1700880644fromCutBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fromCutBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get passLen() : GWizNumStep
      {
         return this._792068028passLen;
      }
      
      public function set passLen(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._792068028passLen;
         if(_loc2_ !== param1)
         {
            this._792068028passLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"passLen",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get passLenLab() : Label
      {
         return this._51778217passLenLab;
      }
      
      public function set passLenLab(param1:Label) : void
      {
         var _loc2_:Object = this._51778217passLenLab;
         if(_loc2_ !== param1)
         {
            this._51778217passLenLab = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"passLenLab",_loc2_,param1));
            }
         }
      }
   }
}
