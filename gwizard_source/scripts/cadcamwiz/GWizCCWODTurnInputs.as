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
   import utils.GWizUtils;
   
   public class GWizCCWODTurnInputs extends GWizForePanel
   {
       
      
      private var _1355219513ProgBar:ProgressBar;
      
      private var _591797239_odTurnGrid:GWizCCWODTurnGrid;
      
      private var _473512492_stockOD:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var recalc:Function = null;
      
      private var _embed_mxml__assets_ODTurning128_jpg_2141257522:Class;
      
      public function GWizCCWODTurnInputs()
      {
         this._embed_mxml__assets_ODTurning128_jpg_2141257522 = GWizCCWODTurnInputs__embed_mxml__assets_ODTurning128_jpg_2141257522;
         super();
         mx_internal::_document = this;
         this.title = "Inputs";
         this.percentWidth = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWODTurnInputs_Array1_c);
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
      
      public function stockOD() : Number
      {
         return this._stockOD.getVal();
      }
      
      public function numODs() : int
      {
         return this._odTurnGrid.turningPlan.length;
      }
      
      private function dispUnitsToInches(param1:String, param2:Boolean = true) : Number
      {
         var _loc3_:Number = Number(param1);
         if(param2 && GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            _loc3_ = Number(param1) / 25.4;
         }
         return _loc3_;
      }
      
      public function diam(param1:int, param2:Boolean = true) : Number
      {
         var _loc3_:Object = this._odTurnGrid.turningPlan.getItemAt(param1);
         return this.dispUnitsToInches(_loc3_.dia,param2);
      }
      
      public function len(param1:int, param2:Boolean = true) : Number
      {
         var _loc3_:Object = this._odTurnGrid.turningPlan.getItemAt(param1);
         return this.dispUnitsToInches(_loc3_.len,param2);
      }
      
      public function face(param1:int) : String
      {
         var _loc2_:Object = this._odTurnGrid.turningPlan.getItemAt(param1);
         return _loc2_.face;
      }
      
      public function chamRound(param1:int) : String
      {
         var _loc2_:Object = this._odTurnGrid.turningPlan.getItemAt(param1);
         return _loc2_.chamRound;
      }
      
      public function radius(param1:int) : String
      {
         var _loc2_:Object = this._odTurnGrid.turningPlan.getItemAt(param1);
         return _loc2_.radius;
      }
      
      private function _GWizCCWODTurnInputs_Array1_c() : Array
      {
         return [this._GWizCCWODTurnInputs_VGroup1_c(),this._GWizCCWODTurnInputs_VGroup2_c()];
      }
      
      private function _GWizCCWODTurnInputs_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWODTurnInputs_HGroup1_c(),this._GWizCCWODTurnInputs_GWizCCWODTurnGrid1_i(),this._GWizCCWODTurnInputs_ProgressBar1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnInputs_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWODTurnInputs_GWizNumStep1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnInputs_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Rough Stock OD:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.___stockOD_initialize);
         _loc1_.addEventListener("change",this.___stockOD_change);
         _loc1_.id = "_stockOD";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._stockOD = _loc1_;
         BindingManager.executeBindings(this,"_stockOD",this._stockOD);
         return _loc1_;
      }
      
      public function ___stockOD_initialize(param1:FlexEvent) : void
      {
         this._stockOD.setVal(3.125);
      }
      
      public function ___stockOD_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWODTurnInputs_GWizCCWODTurnGrid1_i() : GWizCCWODTurnGrid
      {
         var _loc1_:GWizCCWODTurnGrid = new GWizCCWODTurnGrid();
         _loc1_.percentWidth = 100;
         _loc1_.visibleRows = 3;
         _loc1_.id = "_odTurnGrid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._odTurnGrid = _loc1_;
         BindingManager.executeBindings(this,"_odTurnGrid",this._odTurnGrid);
         return _loc1_;
      }
      
      private function _GWizCCWODTurnInputs_ProgressBar1_i() : ProgressBar
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
      
      private function _GWizCCWODTurnInputs_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWODTurnInputs_Image1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnInputs_Image1_c() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml__assets_ODTurning128_jpg_2141257522;
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
      public function get _odTurnGrid() : GWizCCWODTurnGrid
      {
         return this._591797239_odTurnGrid;
      }
      
      public function set _odTurnGrid(param1:GWizCCWODTurnGrid) : void
      {
         var _loc2_:Object = this._591797239_odTurnGrid;
         if(_loc2_ !== param1)
         {
            this._591797239_odTurnGrid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_odTurnGrid",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _stockOD() : GWizNumStep
      {
         return this._473512492_stockOD;
      }
      
      public function set _stockOD(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._473512492_stockOD;
         if(_loc2_ !== param1)
         {
            this._473512492_stockOD = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_stockOD",_loc2_,param1));
            }
         }
      }
   }
}
