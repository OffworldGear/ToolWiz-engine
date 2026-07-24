package cadcamwiz
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.ProgressBar;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizCCWIDTurnInputs extends GWizForePanel implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _708093801EstimatorInputs:HGroup;
      
      private var _1355219513ProgBar:ProgressBar;
      
      private var _3644739xEnd:GWizNumStep;
      
      private var _779264310xStart:GWizNumStep;
      
      private var _3704321zEnd:GWizNumStep;
      
      private var _722006008zStart:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var recalc:Function = null;
      
      private var _embed_mxml__assets_IDTurn128_jpg_1244462020:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWIDTurnInputs()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._embed_mxml__assets_IDTurn128_jpg_1244462020 = GWizCCWIDTurnInputs__embed_mxml__assets_IDTurn128_jpg_1244462020;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWIDTurnInputs_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWIDTurnInputsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWIDTurnInputs[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Inputs";
         this.percentWidth = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWIDTurnInputs_Array1_c);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWIDTurnInputs._watcherSetupUtil = param1;
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
      
      private function _GWizCCWIDTurnInputs_Array1_c() : Array
      {
         return [this._GWizCCWIDTurnInputs_VGroup1_c(),this._GWizCCWIDTurnInputs_VGroup2_c()];
      }
      
      private function _GWizCCWIDTurnInputs_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWIDTurnInputs_HGroup1_c(),this._GWizCCWIDTurnInputs_HGroup2_i(),this._GWizCCWIDTurnInputs_ProgressBar1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWIDTurnInputs_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWIDTurnInputs_GWizNumStep1_i(),this._GWizCCWIDTurnInputs_GWizNumStep2_i(),this._GWizCCWIDTurnInputs_Label1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWIDTurnInputs_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Bore OD:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__xStart_initialize);
         _loc1_.addEventListener("change",this.__xStart_change);
         _loc1_.id = "xStart";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xStart = _loc1_;
         BindingManager.executeBindings(this,"xStart",this.xStart);
         return _loc1_;
      }
      
      public function __xStart_initialize(param1:FlexEvent) : void
      {
         this.xStart.setVal(3);
      }
      
      public function __xStart_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWIDTurnInputs_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "ID:";
         _loc1_.min = 0;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__xEnd_initialize);
         _loc1_.addEventListener("change",this.__xEnd_change);
         _loc1_.id = "xEnd";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xEnd = _loc1_;
         BindingManager.executeBindings(this,"xEnd",this.xEnd);
         return _loc1_;
      }
      
      public function __xEnd_initialize(param1:FlexEvent) : void
      {
         this.xEnd.setVal(0);
      }
      
      public function __xEnd_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWIDTurnInputs_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "(Boring bar dia is 80% of ID)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWIDTurnInputs_HGroup2_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWIDTurnInputs_Label2_c(),this._GWizCCWIDTurnInputs_Spacer1_c(),this._GWizCCWIDTurnInputs_GWizNumStep3_i(),this._GWizCCWIDTurnInputs_Spacer2_c(),this._GWizCCWIDTurnInputs_GWizNumStep4_i()];
         _loc1_.id = "EstimatorInputs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EstimatorInputs = _loc1_;
         BindingManager.executeBindings(this,"EstimatorInputs",this.EstimatorInputs);
         return _loc1_;
      }
      
      private function _GWizCCWIDTurnInputs_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Z Start:";
         _loc1_.setStyle("color",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWIDTurnInputs_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 0;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWIDTurnInputs_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = -5000;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Far right / beginning of bore.";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__zStart_initialize);
         _loc1_.addEventListener("change",this.__zStart_change);
         _loc1_.id = "zStart";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.zStart = _loc1_;
         BindingManager.executeBindings(this,"zStart",this.zStart);
         return _loc1_;
      }
      
      public function __zStart_initialize(param1:FlexEvent) : void
      {
         this.zStart.setVal(0);
      }
      
      public function __zStart_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWIDTurnInputs_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 8;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWIDTurnInputs_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Z End:";
         _loc1_.min = -5000;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Finished Z position of bore.";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__zEnd_initialize);
         _loc1_.addEventListener("change",this.__zEnd_change);
         _loc1_.id = "zEnd";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.zEnd = _loc1_;
         BindingManager.executeBindings(this,"zEnd",this.zEnd);
         return _loc1_;
      }
      
      public function __zEnd_initialize(param1:FlexEvent) : void
      {
         this.zEnd.setVal(-0.5);
      }
      
      public function __zEnd_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWIDTurnInputs_ProgressBar1_i() : ProgressBar
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
      
      private function _GWizCCWIDTurnInputs_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWIDTurnInputs_Image1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWIDTurnInputs_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_IDTurn128_jpg_1244462020;
         _loc1_.setStyle("backgroundColor",15658734);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWIDTurnInputs_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return GWizCCWEstimatorInput.addEstimatorItem != null;
         },null,"EstimatorInputs.visible");
         result[1] = new Binding(this,function():Boolean
         {
            return EstimatorInputs.visible;
         },null,"EstimatorInputs.includeInLayout");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get EstimatorInputs() : HGroup
      {
         return this._708093801EstimatorInputs;
      }
      
      public function set EstimatorInputs(param1:HGroup) : void
      {
         var _loc2_:Object = this._708093801EstimatorInputs;
         if(_loc2_ !== param1)
         {
            this._708093801EstimatorInputs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EstimatorInputs",_loc2_,param1));
            }
         }
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
      public function get xEnd() : GWizNumStep
      {
         return this._3644739xEnd;
      }
      
      public function set xEnd(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._3644739xEnd;
         if(_loc2_ !== param1)
         {
            this._3644739xEnd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xEnd",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xStart() : GWizNumStep
      {
         return this._779264310xStart;
      }
      
      public function set xStart(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._779264310xStart;
         if(_loc2_ !== param1)
         {
            this._779264310xStart = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xStart",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get zEnd() : GWizNumStep
      {
         return this._3704321zEnd;
      }
      
      public function set zEnd(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._3704321zEnd;
         if(_loc2_ !== param1)
         {
            this._3704321zEnd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"zEnd",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get zStart() : GWizNumStep
      {
         return this._722006008zStart;
      }
      
      public function set zStart(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._722006008zStart;
         if(_loc2_ !== param1)
         {
            this._722006008zStart = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"zStart",_loc2_,param1));
            }
         }
      }
   }
}
