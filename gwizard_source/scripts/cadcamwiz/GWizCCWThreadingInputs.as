package cadcamwiz
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.ProgressBar;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.VGroup;
   
   public class GWizCCWThreadingInputs extends GWizForePanel
   {
       
      
      private var _1355219513ProgBar:ProgressBar;
      
      private var _1703458182stockDia:GWizNumStep;
      
      private var _1905656537threadDepth:GWizNumStep;
      
      private var _1562253397threadLen:GWizNumStep;
      
      private var _1916861270threadPitch:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var recalc:Function = null;
      
      private var _embed_mxml__assets_Threading128_jpg_886255982:Class;
      
      public function GWizCCWThreadingInputs()
      {
         this._embed_mxml__assets_Threading128_jpg_886255982 = GWizCCWThreadingInputs__embed_mxml__assets_Threading128_jpg_886255982;
         super();
         mx_internal::_document = this;
         this.title = "Inputs";
         this.percentWidth = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWThreadingInputs_Array1_c);
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
      
      private function _GWizCCWThreadingInputs_Array1_c() : Array
      {
         return [this._GWizCCWThreadingInputs_VGroup1_c(),this._GWizCCWThreadingInputs_VGroup2_c()];
      }
      
      private function _GWizCCWThreadingInputs_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWThreadingInputs_HGroup1_c(),this._GWizCCWThreadingInputs_ProgressBar1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWThreadingInputs_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWThreadingInputs_GWizNumStep1_i(),this._GWizCCWThreadingInputs_GWizNumStep2_i(),this._GWizCCWThreadingInputs_GWizNumStep3_i(),this._GWizCCWThreadingInputs_GWizNumStep4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWThreadingInputs_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Thread Depth:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Depth of the V-Groove of the thread.";
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__threadDepth_initialize);
         _loc1_.addEventListener("change",this.__threadDepth_change);
         _loc1_.id = "threadDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.threadDepth = _loc1_;
         BindingManager.executeBindings(this,"threadDepth",this.threadDepth);
         return _loc1_;
      }
      
      public function __threadDepth_initialize(param1:FlexEvent) : void
      {
         this.threadDepth.setVal(0.043);
      }
      
      public function __threadDepth_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWThreadingInputs_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Thread Pitch:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__threadPitch_initialize);
         _loc1_.addEventListener("change",this.__threadPitch_change);
         _loc1_.id = "threadPitch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.threadPitch = _loc1_;
         BindingManager.executeBindings(this,"threadPitch",this.threadPitch);
         return _loc1_;
      }
      
      public function __threadPitch_initialize(param1:FlexEvent) : void
      {
         this.threadPitch.setVal(0.05);
      }
      
      public function __threadPitch_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWThreadingInputs_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Dia Before Threading:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__stockDia_initialize);
         _loc1_.addEventListener("change",this.__stockDia_change);
         _loc1_.id = "stockDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stockDia = _loc1_;
         BindingManager.executeBindings(this,"stockDia",this.stockDia);
         return _loc1_;
      }
      
      public function __stockDia_initialize(param1:FlexEvent) : void
      {
         this.stockDia.setVal(0.5);
      }
      
      public function __stockDia_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWThreadingInputs_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Thread Length:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Length of cylinder that is threaded.";
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__threadLen_initialize);
         _loc1_.addEventListener("change",this.__threadLen_change);
         _loc1_.id = "threadLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.threadLen = _loc1_;
         BindingManager.executeBindings(this,"threadLen",this.threadLen);
         return _loc1_;
      }
      
      public function __threadLen_initialize(param1:FlexEvent) : void
      {
         this.threadLen.setVal(0.821);
      }
      
      public function __threadLen_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWThreadingInputs_ProgressBar1_i() : ProgressBar
      {
         var _loc1_:ProgressBar = new ProgressBar();
         _loc1_.visible = false;
         _loc1_.label = "Progress";
         _loc1_.id = "ProgBar";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ProgBar = _loc1_;
         BindingManager.executeBindings(this,"ProgBar",this.ProgBar);
         return _loc1_;
      }
      
      private function _GWizCCWThreadingInputs_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWThreadingInputs_Image1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWThreadingInputs_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_Threading128_jpg_886255982;
         _loc1_.setStyle("backgroundColor",15658734);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get ProgBar() : ProgressBar
      {
         return this._1355219513ProgBar;
      }
      
      public function set ProgBar(param1:ProgressBar) : void
      {
         var _loc2_:Object = this._1355219513ProgBar;
         if(_loc2_ !== param1)
         {
            this._1355219513ProgBar = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ProgBar",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stockDia() : GWizNumStep
      {
         return this._1703458182stockDia;
      }
      
      public function set stockDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1703458182stockDia;
         if(_loc2_ !== param1)
         {
            this._1703458182stockDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stockDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get threadDepth() : GWizNumStep
      {
         return this._1905656537threadDepth;
      }
      
      public function set threadDepth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1905656537threadDepth;
         if(_loc2_ !== param1)
         {
            this._1905656537threadDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"threadDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get threadLen() : GWizNumStep
      {
         return this._1562253397threadLen;
      }
      
      public function set threadLen(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1562253397threadLen;
         if(_loc2_ !== param1)
         {
            this._1562253397threadLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"threadLen",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get threadPitch() : GWizNumStep
      {
         return this._1916861270threadPitch;
      }
      
      public function set threadPitch(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1916861270threadPitch;
         if(_loc2_ !== param1)
         {
            this._1916861270threadPitch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"threadPitch",_loc2_,param1));
            }
         }
      }
   }
}
