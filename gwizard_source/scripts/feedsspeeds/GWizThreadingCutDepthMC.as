package feedsspeeds
{
   import comps.GWizNumStepOvr;
   import comps.GWizPopUp;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   public class GWizThreadingCutDepthMC extends GWizPopUp
   {
      
      private static const log:ILogger = Log.getLogger("GWizTurningCutDepthMC");
       
      
      private var _871211284firstPassLab:Label;
      
      private var _944687986passesLab:Label;
      
      private var _106677056pitch:GWizNumStepOvr;
      
      private var _1071102162theDepth:GWizNumStepOvr;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var doc:Number;
      
      private var recurse:Boolean = false;
      
      public function GWizThreadingCutDepthMC()
      {
         super();
         mx_internal::_document = this;
         this.width = 550;
         this.height = 300;
         this.title = "Threading Pass Depth";
         this.okLabel = "Adjust Cut Depth";
         this.mxmlContent = [this._GWizThreadingCutDepthMC_VGroup1_c(),this._GWizThreadingCutDepthMC_Spacer3_c()];
         this.addEventListener("creationComplete",this.___GWizThreadingCutDepthMC_GWizPopUp1_creationComplete);
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
         if(this.recurse)
         {
            return;
         }
         this.recurse = true;
         var _loc1_:Number = int(GWizConfigData.threadPasses(this.pitch.value));
         this.doc = GWizConfigData.firstThreadPass(this.theDepth.value,_loc1_);
         this.firstPassLab.text = "First pass cut depth: " + GWizUtils.roundThousandths(this.doc,true);
         this.passesLab.text = "Passes: " + _loc1_;
         this.recurse = false;
      }
      
      private function doAdjust(param1:Boolean) : void
      {
         if(param1)
         {
            GWizSettings.FeedsSpeedsApp.cutDepth.setVal(this.doc);
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
      
      private function _GWizThreadingCutDepthMC_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizThreadingCutDepthMC_HGroup1_c(),this._GWizThreadingCutDepthMC_HGroup2_c(),this._GWizThreadingCutDepthMC_Label3_i(),this._GWizThreadingCutDepthMC_Label4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadingCutDepthMC_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThreadingCutDepthMC_Label1_c(),this._GWizThreadingCutDepthMC_Spacer1_c(),this._GWizThreadingCutDepthMC_GWizNumStepOvr1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadingCutDepthMC_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Thread Pitch";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadingCutDepthMC_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadingCutDepthMC_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.min = 0;
         _loc1_.max = 10;
         _loc1_.steps = 0.001;
         _loc1_.width = 100;
         _loc1_.toolTip = "Thread pitch in inches or mm.";
         _loc1_.addEventListener("valueCommit",this.__pitch_valueCommit);
         _loc1_.id = "pitch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pitch = _loc1_;
         BindingManager.executeBindings(this,"pitch",this.pitch);
         return _loc1_;
      }
      
      public function __pitch_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizThreadingCutDepthMC_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThreadingCutDepthMC_Label2_c(),this._GWizThreadingCutDepthMC_Spacer2_c(),this._GWizThreadingCutDepthMC_GWizNumStepOvr2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadingCutDepthMC_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Thread Depth";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadingCutDepthMC_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadingCutDepthMC_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.min = 0;
         _loc1_.max = 10;
         _loc1_.steps = 0.001;
         _loc1_.width = 100;
         _loc1_.toolTip = "Thread depth in inches or mm.";
         _loc1_.addEventListener("valueCommit",this.__theDepth_valueCommit);
         _loc1_.id = "theDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theDepth = _loc1_;
         BindingManager.executeBindings(this,"theDepth",this.theDepth);
         return _loc1_;
      }
      
      public function __theDepth_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizThreadingCutDepthMC_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "First pass cut depth: ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "firstPassLab";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.firstPassLab = _loc1_;
         BindingManager.executeBindings(this,"firstPassLab",this.firstPassLab);
         return _loc1_;
      }
      
      private function _GWizThreadingCutDepthMC_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Passes: ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "passesLab";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.passesLab = _loc1_;
         BindingManager.executeBindings(this,"passesLab",this.passesLab);
         return _loc1_;
      }
      
      private function _GWizThreadingCutDepthMC_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizThreadingCutDepthMC_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      [Bindable(event="propertyChange")]
      public function get firstPassLab() : Label
      {
         return this._871211284firstPassLab;
      }
      
      public function set firstPassLab(param1:Label) : void
      {
         var _loc2_:Object = this._871211284firstPassLab;
         if(_loc2_ !== param1)
         {
            this._871211284firstPassLab = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"firstPassLab",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get passesLab() : Label
      {
         return this._944687986passesLab;
      }
      
      public function set passesLab(param1:Label) : void
      {
         var _loc2_:Object = this._944687986passesLab;
         if(_loc2_ !== param1)
         {
            this._944687986passesLab = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"passesLab",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pitch() : GWizNumStepOvr
      {
         return this._106677056pitch;
      }
      
      public function set pitch(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._106677056pitch;
         if(_loc2_ !== param1)
         {
            this._106677056pitch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pitch",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theDepth() : GWizNumStepOvr
      {
         return this._1071102162theDepth;
      }
      
      public function set theDepth(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1071102162theDepth;
         if(_loc2_ !== param1)
         {
            this._1071102162theDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theDepth",_loc2_,param1));
            }
         }
      }
   }
}
