package cadcamwiz
{
   import comps.GWizNumStep;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   
   public class GWizCCWChamferInputs extends HGroup
   {
       
      
      private var _1891401086Chamfer:CheckBox;
      
      private var _1694614947ChamferSize:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var recalc:Function;
      
      public function GWizCCWChamferInputs()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.verticalAlign = "baseline";
         this.mxmlContent = [this._GWizCCWChamferInputs_CheckBox1_i(),this._GWizCCWChamferInputs_GWizNumStep1_i()];
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
      
      private function _GWizCCWChamferInputs_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Chamfer";
         _loc1_.toolTip = "Select to chamfer top edge.  Specify chamfer tool in Options.";
         _loc1_.addEventListener("change",this.__Chamfer_change);
         _loc1_.id = "Chamfer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Chamfer = _loc1_;
         BindingManager.executeBindings(this,"Chamfer",this.Chamfer);
         return _loc1_;
      }
      
      public function __Chamfer_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWChamferInputs_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Chaf. Sz:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.toolTip = "Width of chamfer, XY plane";
         _loc1_.addEventListener("initialize",this.__ChamferSize_initialize);
         _loc1_.addEventListener("change",this.__ChamferSize_change);
         _loc1_.id = "ChamferSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ChamferSize = _loc1_;
         BindingManager.executeBindings(this,"ChamferSize",this.ChamferSize);
         return _loc1_;
      }
      
      public function __ChamferSize_initialize(param1:FlexEvent) : void
      {
         this.ChamferSize.setVal(0.01);
      }
      
      public function __ChamferSize_change(param1:Event) : void
      {
         this.recalc();
      }
      
      [Bindable(event="propertyChange")]
      public function get Chamfer() : CheckBox
      {
         return this._1891401086Chamfer;
      }
      
      public function set Chamfer(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1891401086Chamfer;
         if(_loc2_ !== param1)
         {
            this._1891401086Chamfer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Chamfer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ChamferSize() : GWizNumStep
      {
         return this._1694614947ChamferSize;
      }
      
      public function set ChamferSize(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1694614947ChamferSize;
         if(_loc2_ !== param1)
         {
            this._1694614947ChamferSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ChamferSize",_loc2_,param1));
            }
         }
      }
   }
}
