package tools
{
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   
   public class GWizDrillPicker extends GWizPopUp
   {
       
      
      private var _3199dc:GWizDrillChart;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var diameter:GWizNumStep;
      
      public function GWizDrillPicker()
      {
         super();
         mx_internal::_document = this;
         this.width = 650;
         this.height = 300;
         this.okLabel = "Save";
         this.title = "Drill Index";
         this.mxmlContent = [this._GWizDrillPicker_GWizDrillChart1_i()];
         this.addEventListener("creationComplete",this.___GWizDrillPicker_GWizPopUp1_creationComplete);
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
      
      public function setDefault() : void
      {
         if(this.diameter != null && this.diameter.getVal() > 0)
         {
            this.dc.toolDiameter.setVal(this.diameter.getVal());
         }
      }
      
      private function selectDrill() : void
      {
         if(this.dc.drills.selectedItem != null)
         {
            this.diameter.setVal(this.dc.drills.selectedItem.inch);
         }
         super.close();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.selectDrill();
      }
      
      private function _GWizDrillPicker_GWizDrillChart1_i() : GWizDrillChart
      {
         var _loc1_:GWizDrillChart = new GWizDrillChart();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.selectDrillFcn = this.selectDrill;
         _loc1_.topLineColor = 16777215;
         _loc1_.id = "dc";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.dc = _loc1_;
         BindingManager.executeBindings(this,"dc",this.dc);
         return _loc1_;
      }
      
      public function ___GWizDrillPicker_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.setDefault();
      }
      
      [Bindable(event="propertyChange")]
      public function get dc() : GWizDrillChart
      {
         return this._3199dc;
      }
      
      public function set dc(param1:GWizDrillChart) : void
      {
         var _loc2_:Object = this._3199dc;
         if(_loc2_ !== param1)
         {
            this._3199dc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dc",_loc2_,param1));
            }
         }
      }
   }
}
