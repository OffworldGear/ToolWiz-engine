package feedsspeeds
{
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import machines.GWizMachSettings;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   public class GWizInterpMC extends GWizPopUp
   {
      
      private static var feed:Number;
       
      
      private var _102979424Acceleration:Label;
      
      private var _2076557Boss:RadioButton;
      
      private var _2018617584Circle:RadioButton;
      
      private var _331974090FeedAccel:Label;
      
      private var _2135118368GeoAdjust:Label;
      
      private var _69609566Helix:RadioButton;
      
      private var _2255072Hole:RadioButton;
      
      private var _1116735978IgnoreAccel:CheckBox;
      
      private var _1653015480RampAng:Label;
      
      private var _1644997178RawFeed:Label;
      
      private var _80027744TPDia:Label;
      
      private var _919444249ToolComp:CheckBox;
      
      private var _782945390circgrp:RadioButtonGroup;
      
      private var _1091755932holeDia:GWizNumStep;
      
      private var _379884004maxAccel:GWizNumStep;
      
      private var _853082261typegrp:RadioButtonGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _embed_mxml__assets_Interp_jpg_1363150000:Class;
      
      public function GWizInterpMC()
      {
         this._embed_mxml__assets_Interp_jpg_1363150000 = GWizInterpMC__embed_mxml__assets_Interp_jpg_1363150000;
         super();
         mx_internal::_document = this;
         this.width = 500;
         this.height = 468;
         this.title = "Helical and Circular Interpolation Mini-Calc";
         this.okLabel = "Adjust Feedrate";
         this.mxmlContent = [this._GWizInterpMC_HGroup1_c(),this._GWizInterpMC_HGroup2_c(),this._GWizInterpMC_HGroup3_c(),this._GWizInterpMC_Label6_i(),this._GWizInterpMC_HGroup5_c(),this._GWizInterpMC_Label8_i(),this._GWizInterpMC_Label9_c(),this._GWizInterpMC_Label10_c()];
         this._GWizInterpMC_RadioButtonGroup2_i();
         this._GWizInterpMC_RadioButtonGroup1_i();
         this.addEventListener("creationComplete",this.___GWizInterpMC_GWizPopUp1_creationComplete);
      }
      
      public static function helixFeedrate(param1:Number, param2:Number, param3:int, param4:Number, param5:Number, param6:Number, param7:Boolean, param8:Boolean, param9:Boolean, param10:Boolean) : Object
      {
         var _loc14_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc11_:Object = new Object();
         var _loc12_:Number = param1;
         var _loc13_:Number = 0;
         if(param7)
         {
            _loc14_ = (_loc12_ -= param2) / param1;
            if(param8)
            {
               _loc12_ += param2 / 2;
            }
         }
         else
         {
            _loc14_ = (_loc12_ += param2) / param1;
            if(param8)
            {
               _loc12_ -= param2 / 2;
            }
         }
         _loc12_ = Math.abs(_loc12_);
         _loc14_ = Math.abs(_loc14_);
         if(param8)
         {
            _loc14_ = 1;
         }
         _loc11_.TPDia = _loc12_;
         feed = param4;
         _loc11_.rawFeed = feed;
         feed *= Math.min(1,_loc14_);
         var _loc15_:Number = Math.abs(_loc12_ * Math.PI);
         var _loc16_:Number = 0;
         if(param9)
         {
            _loc19_ = param6;
            if(_loc15_ > 0)
            {
               _loc16_ = GWizUtils.degrees(Math.atan(_loc19_ / _loc15_));
            }
         }
         _loc11_.rampAngle = _loc16_;
         var _loc17_:Number = Math.min(1,Number(_loc16_) / 90);
         feed = (1 - _loc17_) * feed + _loc17_ * (feed / GWizSettings.FeedsSpeedsApp.td.toolParms.flutes);
         feed = Math.abs(feed);
         _loc11_.geoAdjust = feed;
         _loc12_ /= 2;
         var _loc18_:Number = (_loc13_ = GWizUtils.square(feed) / _loc12_) / 1389918.9;
         if(GWizUtils.Units == GWizUtils.MM_UNITS)
         {
            _loc13_ = _loc18_ * 9.807;
         }
         _loc18_ = Math.abs(_loc18_);
         _loc11_.a = _loc13_;
         _loc11_.g = _loc18_;
         if(param10)
         {
            _loc11_.feedAccel = feed;
         }
         else
         {
            _loc20_ = Math.min(param5 / _loc18_,1);
            feed *= _loc20_;
            _loc11_.feedAccel = feed;
         }
         return _loc11_;
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
         var _loc1_:Number = GWizMachSettings.lookupMachine(GWizMachSettings.currMachine).accel;
         if(!_loc1_)
         {
            _loc1_ = 0.1;
         }
         this.maxAccel.setVal(_loc1_);
         this.holeDia.value = GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam * 1.5;
      }
      
      private function recalcOld() : void
      {
         var _loc3_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc1_:Number = this.holeDia.getVal();
         var _loc2_:Number = 0;
         if(this.Hole.selected)
         {
            _loc1_ -= GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam;
            _loc3_ = _loc1_ / this.holeDia.getVal();
            if(this.ToolComp.selected)
            {
               _loc1_ += GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam / 2;
            }
         }
         else
         {
            _loc1_ += GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam;
            _loc3_ = _loc1_ / this.holeDia.getVal();
            if(this.ToolComp.selected)
            {
               _loc1_ -= GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam / 2;
            }
         }
         _loc1_ = Math.abs(_loc1_);
         _loc3_ = Math.abs(_loc3_);
         if(this.ToolComp.selected)
         {
            _loc3_ = 1;
         }
         this.TPDia.text = "Toolpath diameter: " + GWizUtils.roundThousandths(_loc1_,true);
         feed = GWizSettings.FeedsSpeedsApp.IPM.getVal();
         this.RawFeed.text = "Raw unadjusted feedrate: " + GWizUtils.roundThousandths(feed,true);
         feed *= Math.min(1,_loc3_);
         var _loc4_:Number = Math.abs(_loc1_ * Math.PI);
         var _loc5_:Number = 0;
         if(this.Helix.selected)
         {
            _loc9_ = GWizSettings.FeedsSpeedsApp.cutDepth.getVal();
            if(_loc4_ > 0)
            {
               _loc5_ = GWizUtils.degrees(Math.atan(_loc9_ / _loc4_));
            }
         }
         this.RampAng.text = "Calculated Ramp: " + GWizUtils.roundBigTenths(String(_loc5_)) + " deg";
         var _loc6_:Number = Math.min(1,Number(_loc5_) / 90);
         feed = (1 - _loc6_) * feed + _loc6_ * (feed / GWizSettings.FeedsSpeedsApp.td.toolParms.flutes);
         feed = Math.abs(feed);
         this.GeoAdjust.text = "Geometry adjusted feedrate: " + GWizUtils.roundThousandths(feed,true);
         _loc1_ /= 2;
         _loc2_ = GWizUtils.square(feed) / _loc1_;
         var _loc7_:Number = _loc2_ / 1389918.9;
         var _loc8_:String = " inches/min^2 = ";
         if(GWizUtils.Units == GWizUtils.MM_UNITS)
         {
            _loc8_ = " M/sec^2 = ";
            _loc2_ = _loc7_ * 9.807;
         }
         _loc7_ = Math.abs(_loc7_);
         this.Acceleration.text = "Req\'d acceleration for adj feedrate: " + GWizUtils.roundThousandths(_loc2_) + _loc8_ + GWizUtils.roundThousandths(_loc7_) + " g\'s";
         if(this.IgnoreAccel.selected)
         {
            this.FeedAccel.text = "Final Adjusted Feedrate: " + GWizUtils.roundThousandths(feed,true);
         }
         else
         {
            _loc10_ = Math.min(this.maxAccel.getVal() / _loc7_,1);
            feed *= _loc10_;
            this.FeedAccel.text = "Feedrate adjusted to limit acceleration: " + GWizUtils.roundThousandths(feed,true);
         }
      }
      
      private function recalc() : void
      {
         var _loc1_:Object = helixFeedrate(this.holeDia.getVal(),GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam,GWizSettings.FeedsSpeedsApp.td.toolParms.flutes,GWizSettings.FeedsSpeedsApp.IPM.getVal(),this.maxAccel.getVal(),GWizSettings.FeedsSpeedsApp.cutDepth.getVal(),this.Hole.selected,this.ToolComp.selected,this.Helix.selected,this.IgnoreAccel.selected);
         this.TPDia.text = "Toolpath diameter: " + GWizUtils.roundThousandths(_loc1_.TPDia,true);
         this.RawFeed.text = "Raw unadjusted feedrate: " + GWizUtils.roundThousandths(GWizSettings.FeedsSpeedsApp.IPM.getVal(),true);
         this.RampAng.text = "Calculated Ramp: " + GWizUtils.roundBigTenths(String(_loc1_.rampAngle)) + " deg";
         this.GeoAdjust.text = "Geometry adjusted feedrate: " + GWizUtils.roundThousandths(_loc1_.geoAdjust,true);
         var _loc2_:String = " inches/min^2 = ";
         if(GWizUtils.Units == GWizUtils.MM_UNITS)
         {
            _loc2_ = " M/sec^2 = ";
         }
         this.Acceleration.text = "Req\'d acceleration for adj feedrate: " + GWizUtils.roundThousandths(_loc1_.a) + _loc2_ + GWizUtils.roundThousandths(_loc1_.g) + " g\'s";
         if(this.IgnoreAccel.selected)
         {
            this.FeedAccel.text = "Final Adjusted Feedrate: " + GWizUtils.roundThousandths(_loc1_.feedAccel,true);
         }
         else
         {
            this.FeedAccel.text = "Feedrate adjusted to limit acceleration: " + GWizUtils.roundThousandths(_loc1_.feedAccel,true);
         }
      }
      
      private function doAdjust(param1:Boolean) : void
      {
         if(param1)
         {
            GWizSettings.FeedsSpeedsApp.IPM.setValOverride(feed);
         }
         super.close();
      }
      
      private function changeType() : void
      {
         if(this.Hole.selected)
         {
            this.holeDia.titleTxt = "Hole Diameter";
         }
         else
         {
            this.holeDia.titleTxt = "Boss Diameter";
         }
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
      
      private function _GWizInterpMC_RadioButtonGroup2_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.addEventListener("change",this.__circgrp_change);
         _loc1_.initialized(this,"circgrp");
         this.circgrp = _loc1_;
         BindingManager.executeBindings(this,"circgrp",this.circgrp);
         return _loc1_;
      }
      
      public function __circgrp_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizInterpMC_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.addEventListener("change",this.__typegrp_change);
         _loc1_.initialized(this,"typegrp");
         this.typegrp = _loc1_;
         BindingManager.executeBindings(this,"typegrp",this.typegrp);
         return _loc1_;
      }
      
      public function __typegrp_change(param1:Event) : void
      {
         this.changeType();
      }
      
      private function _GWizInterpMC_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizInterpMC_RadioButton1_i(),this._GWizInterpMC_RadioButton2_i(),this._GWizInterpMC_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Hole";
         _loc1_.groupName = "typegrp";
         _loc1_.selected = true;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Hole";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Hole = _loc1_;
         BindingManager.executeBindings(this,"Hole",this.Hole);
         return _loc1_;
      }
      
      private function _GWizInterpMC_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Boss";
         _loc1_.groupName = "typegrp";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Boss";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Boss = _loc1_;
         BindingManager.executeBindings(this,"Boss",this.Boss);
         return _loc1_;
      }
      
      private function _GWizInterpMC_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Tool Comp. (Edge Programming)";
         _loc1_.toolTip = "If checked, tool radius comp results in toolpath being cutter edge.  Otherwise its center of cutter.";
         _loc1_.selected = true;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("valueCommit",this.__ToolComp_valueCommit);
         _loc1_.id = "ToolComp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolComp = _loc1_;
         BindingManager.executeBindings(this,"ToolComp",this.ToolComp);
         return _loc1_;
      }
      
      public function __ToolComp_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizInterpMC_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizInterpMC_RadioButton3_i(),this._GWizInterpMC_RadioButton4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Helical";
         _loc1_.groupName = "circgrp";
         _loc1_.selected = true;
         _loc1_.toolTip = "Helical interpolation--ramps down by DOC each revolution";
         _loc1_.id = "Helix";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Helix = _loc1_;
         BindingManager.executeBindings(this,"Helix",this.Helix);
         return _loc1_;
      }
      
      private function _GWizInterpMC_RadioButton4_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Circular";
         _loc1_.groupName = "circgrp";
         _loc1_.toolTip = "Circular interpolation--no ramp down";
         _loc1_.id = "Circle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Circle = _loc1_;
         BindingManager.executeBindings(this,"Circle",this.Circle);
         return _loc1_;
      }
      
      private function _GWizInterpMC_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizInterpMC_VGroup1_c(),this._GWizInterpMC_Image1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizInterpMC_HGroup4_c(),this._GWizInterpMC_Label2_i(),this._GWizInterpMC_Label3_i(),this._GWizInterpMC_Label4_i(),this._GWizInterpMC_Label5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizInterpMC_Label1_c(),this._GWizInterpMC_GWizNumStep1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Feature diameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 3000;
         _loc1_.steps = 0.001;
         _loc1_.titleColor = 16777215;
         _loc1_.addEventListener("valueCommit",this.__holeDia_valueCommit);
         _loc1_.id = "holeDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.holeDia = _loc1_;
         BindingManager.executeBindings(this,"holeDia",this.holeDia);
         return _loc1_;
      }
      
      public function __holeDia_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizInterpMC_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Toolpath diameter";
         _loc1_.id = "TPDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TPDia = _loc1_;
         BindingManager.executeBindings(this,"TPDia",this.TPDia);
         return _loc1_;
      }
      
      private function _GWizInterpMC_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Raw unadjusted feedrate";
         _loc1_.toolTip = "Raw feedrate from Feeds and Speeds";
         _loc1_.id = "RawFeed";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RawFeed = _loc1_;
         BindingManager.executeBindings(this,"RawFeed",this.RawFeed);
         return _loc1_;
      }
      
      private function _GWizInterpMC_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Calculated Ramp 0 deg";
         _loc1_.id = "RampAng";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RampAng = _loc1_;
         BindingManager.executeBindings(this,"RampAng",this.RampAng);
         return _loc1_;
      }
      
      private function _GWizInterpMC_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Geometry adjusted feedrate";
         _loc1_.toolTip = "Feedrate adjusted for the effect of the distance from tool center to cutting edge";
         _loc1_.id = "GeoAdjust";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GeoAdjust = _loc1_;
         BindingManager.executeBindings(this,"GeoAdjust",this.GeoAdjust);
         return _loc1_;
      }
      
      private function _GWizInterpMC_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_Interp_jpg_1363150000;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Req\'d acceleration for adj feedrate";
         _loc1_.id = "Acceleration";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Acceleration = _loc1_;
         BindingManager.executeBindings(this,"Acceleration",this.Acceleration);
         return _loc1_;
      }
      
      private function _GWizInterpMC_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizInterpMC_HGroup6_c(),this._GWizInterpMC_CheckBox2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizInterpMC_Label7_c(),this._GWizInterpMC_GWizNumStep2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max. Acceleration (g)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 20;
         _loc1_.steps = 0.05;
         _loc1_.toolTip = "Maximum acceleration of your machine maintaining accuracy.";
         _loc1_.usesMetric = false;
         _loc1_.titleColor = 16777215;
         _loc1_.addEventListener("valueCommit",this.__maxAccel_valueCommit);
         _loc1_.id = "maxAccel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.maxAccel = _loc1_;
         BindingManager.executeBindings(this,"maxAccel",this.maxAccel);
         return _loc1_;
      }
      
      public function __maxAccel_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizInterpMC_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Ignore acceleration";
         _loc1_.addEventListener("valueCommit",this.__IgnoreAccel_valueCommit);
         _loc1_.id = "IgnoreAccel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.IgnoreAccel = _loc1_;
         BindingManager.executeBindings(this,"IgnoreAccel",this.IgnoreAccel);
         return _loc1_;
      }
      
      public function __IgnoreAccel_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizInterpMC_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Feedrate adjusted to limit acceleration";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.id = "FeedAccel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FeedAccel = _loc1_;
         BindingManager.executeBindings(this,"FeedAccel",this.FeedAccel);
         return _loc1_;
      }
      
      private function _GWizInterpMC_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Helix angle is determined by Cut Depth,";
         _loc1_.styleName = "fontSizeDelta2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizInterpMC_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "which is depth per revolution of helix.";
         _loc1_.styleName = "fontSizeDelta2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizInterpMC_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get Acceleration() : Label
      {
         return this._102979424Acceleration;
      }
      
      public function set Acceleration(param1:Label) : void
      {
         var _loc2_:Object = this._102979424Acceleration;
         if(_loc2_ !== param1)
         {
            this._102979424Acceleration = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Acceleration",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Boss() : RadioButton
      {
         return this._2076557Boss;
      }
      
      public function set Boss(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2076557Boss;
         if(_loc2_ !== param1)
         {
            this._2076557Boss = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Boss",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Circle() : RadioButton
      {
         return this._2018617584Circle;
      }
      
      public function set Circle(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2018617584Circle;
         if(_loc2_ !== param1)
         {
            this._2018617584Circle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Circle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FeedAccel() : Label
      {
         return this._331974090FeedAccel;
      }
      
      public function set FeedAccel(param1:Label) : void
      {
         var _loc2_:Object = this._331974090FeedAccel;
         if(_loc2_ !== param1)
         {
            this._331974090FeedAccel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FeedAccel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GeoAdjust() : Label
      {
         return this._2135118368GeoAdjust;
      }
      
      public function set GeoAdjust(param1:Label) : void
      {
         var _loc2_:Object = this._2135118368GeoAdjust;
         if(_loc2_ !== param1)
         {
            this._2135118368GeoAdjust = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GeoAdjust",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Helix() : RadioButton
      {
         return this._69609566Helix;
      }
      
      public function set Helix(param1:RadioButton) : void
      {
         var _loc2_:Object = this._69609566Helix;
         if(_loc2_ !== param1)
         {
            this._69609566Helix = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Helix",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Hole() : RadioButton
      {
         return this._2255072Hole;
      }
      
      public function set Hole(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2255072Hole;
         if(_loc2_ !== param1)
         {
            this._2255072Hole = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Hole",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get IgnoreAccel() : CheckBox
      {
         return this._1116735978IgnoreAccel;
      }
      
      public function set IgnoreAccel(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1116735978IgnoreAccel;
         if(_loc2_ !== param1)
         {
            this._1116735978IgnoreAccel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IgnoreAccel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RampAng() : Label
      {
         return this._1653015480RampAng;
      }
      
      public function set RampAng(param1:Label) : void
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
      public function get TPDia() : Label
      {
         return this._80027744TPDia;
      }
      
      public function set TPDia(param1:Label) : void
      {
         var _loc2_:Object = this._80027744TPDia;
         if(_loc2_ !== param1)
         {
            this._80027744TPDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TPDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolComp() : CheckBox
      {
         return this._919444249ToolComp;
      }
      
      public function set ToolComp(param1:CheckBox) : void
      {
         var _loc2_:Object = this._919444249ToolComp;
         if(_loc2_ !== param1)
         {
            this._919444249ToolComp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolComp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get circgrp() : RadioButtonGroup
      {
         return this._782945390circgrp;
      }
      
      public function set circgrp(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._782945390circgrp;
         if(_loc2_ !== param1)
         {
            this._782945390circgrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"circgrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get holeDia() : GWizNumStep
      {
         return this._1091755932holeDia;
      }
      
      public function set holeDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1091755932holeDia;
         if(_loc2_ !== param1)
         {
            this._1091755932holeDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"holeDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get maxAccel() : GWizNumStep
      {
         return this._379884004maxAccel;
      }
      
      public function set maxAccel(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._379884004maxAccel;
         if(_loc2_ !== param1)
         {
            this._379884004maxAccel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"maxAccel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get typegrp() : RadioButtonGroup
      {
         return this._853082261typegrp;
      }
      
      public function set typegrp(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._853082261typegrp;
         if(_loc2_ !== param1)
         {
            this._853082261typegrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"typegrp",_loc2_,param1));
            }
         }
      }
   }
}
