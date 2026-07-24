package feedsspeeds
{
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizGeomUtils;
   import utils.GWizUtils;
   
   public class GWizPlungeMC extends GWizPopUp
   {
      
      private static const log:ILogger = Log.getLogger("GWizPlungeMC");
       
      
      private var _521191109AdjFeed:Label;
      
      private var _168560467Diameter:Label;
      
      private var _1644997178RawFeed:Label;
      
      private var _1493983680Stepover:GWizNumStep;
      
      private var _1808499065Stepup:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var feed:Number = 0;
      
      private var _embed_mxml__assets_PlungeRough_jpg_736734826:Class;
      
      public function GWizPlungeMC()
      {
         this._embed_mxml__assets_PlungeRough_jpg_736734826 = GWizPlungeMC__embed_mxml__assets_PlungeRough_jpg_736734826;
         super();
         mx_internal::_document = this;
         this.title = "Plunge Roughing Mini-Calc";
         this.width = 500;
         this.height = 300;
         this.okLabel = "Adjust Feedrate";
         this.mxmlContent = [this._GWizPlungeMC_HGroup1_c()];
         this.addEventListener("creationComplete",this.___GWizPlungeMC_GWizPopUp1_creationComplete);
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
      
      private function recalc() : void
      {
         this.Diameter.text = "Cutter Diameter: " + GWizUtils.roundThousandths(GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam,true);
         this.feed = GWizSettings.FeedsSpeedsApp.IPM.getVal();
         this.RawFeed.text = "Raw feedrate: " + GWizUtils.roundThousandths(this.feed,true);
         var _loc1_:Number = GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam / 2;
         var _loc2_:Number = this.Stepover.getVal();
         if(_loc2_ == 0)
         {
            this.Stepover.setVal(_loc1_);
         }
         else if(this.Stepup.getVal() == 0)
         {
            this.Stepup.setVal(_loc1_);
         }
         _loc2_ = Math.min(this.Stepup.getVal(),this.Stepup.getVal());
         log.debug("stepover = " + _loc2_);
         var _loc3_:Number = GWizGeomUtils.equalCircleOverlapArea(_loc1_,_loc2_);
         var _loc4_:Number = GWizGeomUtils.circleArea(_loc1_);
         log.debug("Overlap: " + _loc3_ + ", Cutter: " + _loc4_ + ", pct: " + _loc3_ / _loc4_);
         var _loc5_:Number = Math.min(Math.max((_loc4_ - _loc3_) / _loc4_,0),1);
         log.debug("Pct Teeth: " + _loc5_);
         var _loc6_:Number = GWizSettings.FeedsSpeedsApp.fsm.plungeRate;
         var _loc7_:Number = 1;
         if(_loc5_ <= 0.8)
         {
            _loc6_ = GWizSettings.FeedsSpeedsApp.IPM.getVal() * 0.8;
            _loc7_ = GWizSettings.FeedsSpeedsApp.fsm.axialFeedAdjust;
            _loc7_ = (_loc7_ = 1 - _loc7_) * _loc5_;
            _loc7_ = 1 - _loc7_;
            _loc7_ = Math.min(1,Math.max(0,_loc7_));
            _loc7_ = !!isNaN(_loc7_) ? Number(1) : Number(_loc7_);
            _loc6_ = (_loc6_ /= _loc7_) / (GWizSettings.FeedsSpeedsApp.td.toolParms.flutes * _loc5_);
         }
         this.AdjFeed.text = "Adjusted feedrate: " + GWizUtils.roundThousandths(_loc6_,true);
         this.feed = _loc6_;
      }
      
      private function doAdjust(param1:Boolean) : void
      {
         if(param1)
         {
            GWizSettings.FeedsSpeedsApp.IPM.setValOverride(this.feed);
         }
         super.close();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doAdjust(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doAdjust(false);
      }
      
      private function _GWizPlungeMC_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizPlungeMC_VGroup1_c(),this._GWizPlungeMC_Group1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPlungeMC_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 50;
         _loc1_.mxmlContent = [this._GWizPlungeMC_Label1_i(),this._GWizPlungeMC_Label2_i(),this._GWizPlungeMC_Label3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPlungeMC_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cutter Diameter ";
         _loc1_.id = "Diameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Diameter = _loc1_;
         BindingManager.executeBindings(this,"Diameter",this.Diameter);
         return _loc1_;
      }
      
      private function _GWizPlungeMC_Label2_i() : Label
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
      
      private function _GWizPlungeMC_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Adjusted Feedrate";
         _loc1_.id = "AdjFeed";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AdjFeed = _loc1_;
         BindingManager.executeBindings(this,"AdjFeed",this.AdjFeed);
         return _loc1_;
      }
      
      private function _GWizPlungeMC_Group1_c() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.mxmlContent = [this._GWizPlungeMC_Image1_c(),this._GWizPlungeMC_GWizNumStep1_i(),this._GWizPlungeMC_GWizNumStep2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPlungeMC_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.x = 0;
         _loc1_.y = 0;
         _loc1_.source = this._embed_mxml__assets_PlungeRough_jpg_736734826;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPlungeMC_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.x = 140;
         _loc1_.y = 168;
         _loc1_.fatSpacer = false;
         _loc1_.max = 400;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.titleTxt = "Step Over";
         _loc1_.toolTip = "Distance between plunge centers in a pass";
         _loc1_.addEventListener("valueCommit",this.__Stepover_valueCommit);
         _loc1_.id = "Stepover";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Stepover = _loc1_;
         BindingManager.executeBindings(this,"Stepover",this.Stepover);
         return _loc1_;
      }
      
      public function __Stepover_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizPlungeMC_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.x = 0;
         _loc1_.y = 58;
         _loc1_.fatSpacer = false;
         _loc1_.max = 400;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.titleTxt = "Step Up";
         _loc1_.toolTip = "Distance between passes";
         _loc1_.addEventListener("valueCommit",this.__Stepup_valueCommit);
         _loc1_.id = "Stepup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Stepup = _loc1_;
         BindingManager.executeBindings(this,"Stepup",this.Stepup);
         return _loc1_;
      }
      
      public function __Stepup_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function ___GWizPlungeMC_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      [Bindable(event="propertyChange")]
      public function get AdjFeed() : Label
      {
         return this._521191109AdjFeed;
      }
      
      public function set AdjFeed(param1:Label) : void
      {
         var _loc2_:Object = this._521191109AdjFeed;
         if(_loc2_ !== param1)
         {
            this._521191109AdjFeed = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AdjFeed",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Diameter() : Label
      {
         return this._168560467Diameter;
      }
      
      public function set Diameter(param1:Label) : void
      {
         var _loc2_:Object = this._168560467Diameter;
         if(_loc2_ !== param1)
         {
            this._168560467Diameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Diameter",_loc2_,param1));
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
      public function get Stepover() : GWizNumStep
      {
         return this._1493983680Stepover;
      }
      
      public function set Stepover(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1493983680Stepover;
         if(_loc2_ !== param1)
         {
            this._1493983680Stepover = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Stepover",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Stepup() : GWizNumStep
      {
         return this._1808499065Stepup;
      }
      
      public function set Stepup(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1808499065Stepup;
         if(_loc2_ !== param1)
         {
            this._1808499065Stepup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Stepup",_loc2_,param1));
            }
         }
      }
   }
}
