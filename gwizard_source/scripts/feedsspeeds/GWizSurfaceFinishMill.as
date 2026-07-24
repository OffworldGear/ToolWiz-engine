package feedsspeeds
{
   import comps.GWizLabText;
   import comps.GWizNumStepOvr;
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColorStroke;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.primitives.Line;
   import utils.GWizUtils;
   
   public class GWizSurfaceFinishMill extends GWizPopUp
   {
       
      
      private var _170253098EffDiam:GWizLabText;
      
      private var _2607RA:Label;
      
      private var _81272RMS:Label;
      
      private var _133315454ScallopHt:GWizNumStepOvr;
      
      private var _228932385StepOvr:GWizNumStepOvr;
      
      private var _734775783pctTool:GWizLabText;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var fsRecalc:Function = null;
      
      private var fsm:GWizFeedSpeedMath = null;
      
      private var saver:Function = null;
      
      public function GWizSurfaceFinishMill()
      {
         super();
         mx_internal::_document = this;
         this.verticalAlign = "middle";
         this.title = "Ballnose Surface Finish";
         this.horizontalAlign = "center";
         this.okLabel = "Save Stepover";
         this.cancelLabel = "Exit";
         this.width = 500;
         this.mxmlContent = [this._GWizSurfaceFinishMill_GWizLabText1_i(),this._GWizSurfaceFinishMill_GWizNumStepOvr1_i(),this._GWizSurfaceFinishMill_HGroup1_c(),this._GWizSurfaceFinishMill_GWizNumStepOvr2_i(),this._GWizSurfaceFinishMill_GWizLabText2_i(),this._GWizSurfaceFinishMill_Line1_c()];
      }
      
      public static function finish(param1:Number) : Number
      {
         return param1 * 1000000;
      }
      
      public static function stepover(param1:Number, param2:Number) : Number
      {
         var _loc4_:Number = NaN;
         var _loc3_:Number = param1 / 2;
         _loc4_ = _loc3_ * _loc3_ - (_loc3_ - param2) * (_loc3_ - param2);
         return Number(2 * Math.sqrt(_loc4_));
      }
      
      public static function scallopht(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = param1 / 2;
         param2 /= 2;
         return _loc3_ - Math.sqrt(_loc3_ * _loc3_ - param2 * param2);
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
      
      public function init(param1:Function, param2:GWizFeedSpeedMath, param3:Function) : void
      {
         this.ScallopHt.customArrowInterval(0.0001,0.002);
         this.fsRecalc = param1;
         this.fsm = param2;
         this.saver = param3;
         this.recalc();
      }
      
      private function recalc() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         if(this.fsRecalc != null && this.fsm)
         {
            this.fsm.scallopHt = this.ScallopHt.getVal();
            this.fsRecalc();
            this.EffDiam.setVal(this.fsm.effDiam);
            this.EffDiam.checkUnits();
            this.pctTool.checkUnits();
            if(this.StepOvr.isOverridden())
            {
               _loc1_ = this.StepOvr.getVal();
               this.ScallopHt.setVal(scallopht(this.fsm.toolParms.toolDiam,_loc1_));
            }
            else
            {
               _loc1_ = stepover(this.fsm.toolParms.toolDiam,this.ScallopHt.getVal());
            }
            _loc2_ = finish(this.ScallopHt.getVal());
            this.StepOvr.setVal(_loc1_);
            this.pctTool.setVal(100 * _loc1_ / this.fsm.toolParms.toolDiam);
            if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
            {
               this.RA.text = "RA Finish (µ inches) " + GWizUtils.roundHundredths(_loc2_);
               this.RMS.text = "RMS Finish (µ inches) " + GWizUtils.roundHundredths(_loc2_ * 1.11);
            }
            else
            {
               this.RA.text = "RA Finish (microns) " + GWizUtils.roundHundredths(_loc2_ / 39.37);
               this.RMS.text = "RMS Finish (microns) " + GWizUtils.roundHundredths(_loc2_ / 39.37 * 1.11);
            }
         }
      }
      
      private function exit(param1:Boolean) : void
      {
         if(param1 && this.saver != null)
         {
            this.saver(this.StepOvr.getVal());
         }
         super.close();
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.exit(false);
      }
      
      override public function onOk(param1:Event) : void
      {
         this.exit(true);
      }
      
      private function _GWizSurfaceFinishMill_GWizLabText1_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labTxt = "Effective Diameter";
         _loc1_.toolTip = "Ballnose effective diameter based on depth of cut";
         _loc1_.width = 350;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "EffDiam";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EffDiam = _loc1_;
         BindingManager.executeBindings(this,"EffDiam",this.EffDiam);
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishMill_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.width = 350;
         _loc1_.titleTxt = "Scallop Height";
         _loc1_.min = 0;
         _loc1_.max = 1;
         _loc1_.steps = 0.00001;
         _loc1_.toolTip = "Height of scallop edge";
         _loc1_.titleColor = 16777215;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.UnitLabel = "in";
         _loc1_.addEventListener("valueCommit",this.__ScallopHt_valueCommit);
         _loc1_.addEventListener("creationComplete",this.__ScallopHt_creationComplete);
         _loc1_.id = "ScallopHt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ScallopHt = _loc1_;
         BindingManager.executeBindings(this,"ScallopHt",this.ScallopHt);
         return _loc1_;
      }
      
      public function __ScallopHt_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function __ScallopHt_creationComplete(param1:FlexEvent) : void
      {
         this.ScallopHt.setVal(0.0001);
      }
      
      private function _GWizSurfaceFinishMill_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.width = 350;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizSurfaceFinishMill_Label1_i(),this._GWizSurfaceFinishMill_Spacer1_c(),this._GWizSurfaceFinishMill_Label2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishMill_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "RA Finish (µ inches) ";
         _loc1_.toolTip = "RA finish";
         _loc1_.id = "RA";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RA = _loc1_;
         BindingManager.executeBindings(this,"RA",this.RA);
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishMill_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishMill_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "RMS Finish (µ inches) ";
         _loc1_.toolTip = "RMS finish";
         _loc1_.id = "RMS";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RMS = _loc1_;
         BindingManager.executeBindings(this,"RMS",this.RMS);
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishMill_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Stepover";
         _loc1_.width = 350;
         _loc1_.toolTip = "Stepover distance between scallop centers";
         _loc1_.min = 0;
         _loc1_.max = 1;
         _loc1_.steps = 0.00001;
         _loc1_.titleColor = 16777215;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.UnitLabel = "in";
         _loc1_.addEventListener("valueCommit",this.__StepOvr_valueCommit);
         _loc1_.id = "StepOvr";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.StepOvr = _loc1_;
         BindingManager.executeBindings(this,"StepOvr",this.StepOvr);
         return _loc1_;
      }
      
      public function __StepOvr_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizSurfaceFinishMill_GWizLabText2_i() : GWizLabText
      {
         var _loc1_:GWizLabText = new GWizLabText();
         _loc1_.labTxt = "Pct of Tool Dia.";
         _loc1_.usesMetric = false;
         _loc1_.toolTip = "Stepover as a % of tool diameter";
         _loc1_.width = 350;
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "pctTool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pctTool = _loc1_;
         BindingManager.executeBindings(this,"pctTool",this.pctTool);
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishMill_Line1_c() : Line
      {
         var _loc1_:Line = new Line();
         _loc1_.percentWidth = 100;
         _loc1_.stroke = this._GWizSurfaceFinishMill_SolidColorStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishMill_SolidColorStroke1_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 16777215;
         _loc1_.weight = 2;
         _loc1_.caps = "square";
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get EffDiam() : GWizLabText
      {
         return this._170253098EffDiam;
      }
      
      public function set EffDiam(param1:GWizLabText) : void
      {
         var _loc2_:Object = this._170253098EffDiam;
         if(_loc2_ !== param1)
         {
            this._170253098EffDiam = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EffDiam",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RA() : Label
      {
         return this._2607RA;
      }
      
      public function set RA(param1:Label) : void
      {
         var _loc2_:Object = this._2607RA;
         if(_loc2_ !== param1)
         {
            this._2607RA = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RA",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RMS() : Label
      {
         return this._81272RMS;
      }
      
      public function set RMS(param1:Label) : void
      {
         var _loc2_:Object = this._81272RMS;
         if(_loc2_ !== param1)
         {
            this._81272RMS = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RMS",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ScallopHt() : GWizNumStepOvr
      {
         return this._133315454ScallopHt;
      }
      
      public function set ScallopHt(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._133315454ScallopHt;
         if(_loc2_ !== param1)
         {
            this._133315454ScallopHt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ScallopHt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get StepOvr() : GWizNumStepOvr
      {
         return this._228932385StepOvr;
      }
      
      public function set StepOvr(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._228932385StepOvr;
         if(_loc2_ !== param1)
         {
            this._228932385StepOvr = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"StepOvr",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pctTool() : GWizLabText
      {
         return this._734775783pctTool;
      }
      
      public function set pctTool(param1:GWizLabText) : void
      {
         var _loc2_:Object = this._734775783pctTool;
         if(_loc2_ !== param1)
         {
            this._734775783pctTool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pctTool",_loc2_,param1));
            }
         }
      }
   }
}
