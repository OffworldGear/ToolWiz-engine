package cadcamwiz
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IVisualElement;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.Group;
   import spark.components.VGroup;
   
   public class GWizCCWGroovePartOptions extends Group
   {
       
      
      private var _1257622852grooveOptions:GWizForePanel;
      
      private var _25894830isCarbide:CheckBox;
      
      private var _423685362toolWidth:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var recalc:Function = null;
      
      public function GWizCCWGroovePartOptions()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this._GWizCCWGroovePartOptions_GWizForePanel1_i();
         this.addEventListener("creationComplete",this.___GWizCCWGroovePartOptions_Group1_creationComplete);
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
         this.selectedChild = this.grooveOptions;
         if(this.toolWidth && GWizCadCam.CADCAMWiz && GWizCadCam.CADCAMWiz.ccwLatheOptions && GWizCadCam.CADCAMWiz.ccwLatheOptions.toolWidth)
         {
            this.toolWidth.setVal(GWizCadCam.CADCAMWiz.ccwLatheOptions.toolWidth.getVal());
            this.isCarbide.selected = GWizCadCam.CADCAMWiz.ccwLatheOptions.isCarbide.selected;
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
      
      private function _GWizCCWGroovePartOptions_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Options";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWGroovePartOptions_Array1_c);
         _loc1_.id = "grooveOptions";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.grooveOptions = _loc1_;
         BindingManager.executeBindings(this,"grooveOptions",this.grooveOptions);
         return _loc1_;
      }
      
      private function _GWizCCWGroovePartOptions_Array1_c() : Array
      {
         return [this._GWizCCWGroovePartOptions_VGroup1_c()];
      }
      
      private function _GWizCCWGroovePartOptions_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWGroovePartOptions_GWizNumStep1_i(),this._GWizCCWGroovePartOptions_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWGroovePartOptions_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Tool Width";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__toolWidth_initialize);
         _loc1_.addEventListener("change",this.__toolWidth_change);
         _loc1_.id = "toolWidth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolWidth = _loc1_;
         BindingManager.executeBindings(this,"toolWidth",this.toolWidth);
         return _loc1_;
      }
      
      public function __toolWidth_initialize(param1:FlexEvent) : void
      {
         this.toolWidth.setVal(0.015);
      }
      
      public function __toolWidth_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWGroovePartOptions_CheckBox1_i() : CheckBox
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
      
      public function ___GWizCCWGroovePartOptions_Group1_creationComplete(param1:FlexEvent) : void
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
      
      [Bindable(event="propertyChange")]
      public function get toolWidth() : GWizNumStep
      {
         return this._423685362toolWidth;
      }
      
      public function set toolWidth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._423685362toolWidth;
         if(_loc2_ !== param1)
         {
            this._423685362toolWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolWidth",_loc2_,param1));
            }
         }
      }
   }
}
