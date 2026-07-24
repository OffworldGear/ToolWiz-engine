package cadcamwiz
{
   import comps.GWizForePanel;
   import mx.binding.BindingManager;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IVisualElement;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.Group;
   import spark.components.VGroup;
   
   public class GWizCCWThreadingOptions extends Group
   {
       
      
      private var _1257622852grooveOptions:GWizForePanel;
      
      private var _25894830isCarbide:CheckBox;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var recalc:Function = null;
      
      public function GWizCCWThreadingOptions()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this._GWizCCWThreadingOptions_GWizForePanel1_i();
         this.addEventListener("creationComplete",this.___GWizCCWThreadingOptions_Group1_creationComplete);
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
      
      public function onCC() : void
      {
         var _loc1_:GWizCCWLatheOptions = null;
         this.selectedChild = this.grooveOptions;
         if(this.isCarbide && GWizCadCam.CADCAMWiz && GWizCadCam.CADCAMWiz.ccwLatheOptions && GWizCadCam.CADCAMWiz.ccwLatheOptions.toolWidth)
         {
            _loc1_ = GWizCadCam.CADCAMWiz.ccwLatheOptions;
            this.isCarbide.selected = _loc1_.isCarbide.selected;
         }
         else
         {
            this.callLater(this.onCC);
         }
      }
      
      public function set selectedChild(param1:IVisualElement) : void
      {
         this.removeAllElements();
         this.addElement(param1);
      }
      
      private function _GWizCCWThreadingOptions_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Options";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWThreadingOptions_Array1_c);
         _loc1_.id = "grooveOptions";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.grooveOptions = _loc1_;
         BindingManager.executeBindings(this,"grooveOptions",this.grooveOptions);
         return _loc1_;
      }
      
      private function _GWizCCWThreadingOptions_Array1_c() : Array
      {
         return [this._GWizCCWThreadingOptions_VGroup1_c()];
      }
      
      private function _GWizCCWThreadingOptions_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWThreadingOptions_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWThreadingOptions_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Carbide";
         _loc1_.selected = true;
         _loc1_.id = "isCarbide";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.isCarbide = _loc1_;
         BindingManager.executeBindings(this,"isCarbide",this.isCarbide);
         return _loc1_;
      }
      
      public function ___GWizCCWThreadingOptions_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get grooveOptions() : GWizForePanel
      {
         return this._1257622852grooveOptions;
      }
      
      public function set grooveOptions(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1257622852grooveOptions;
         if(_loc2_ !== param1)
         {
            this._1257622852grooveOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"grooveOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get isCarbide() : CheckBox
      {
         return this._25894830isCarbide;
      }
      
      public function set isCarbide(param1:CheckBox) : void
      {
         var _loc2_:Object = this._25894830isCarbide;
         if(_loc2_ !== param1)
         {
            this._25894830isCarbide = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"isCarbide",_loc2_,param1));
            }
         }
      }
   }
}
