package tools
{
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.RadioButton;
   import spark.components.VGroup;
   
   public class GWizG10Export extends GWizPopUp
   {
       
      
      private var _1787968698allTools:RadioButton;
      
      private var _1633793610currToolOnly:RadioButton;
      
      private var _2140059250doToolComp:CheckBox;
      
      private var _443943543doToolLength:CheckBox;
      
      private var _1244688184fromSlot:NumericStepper;
      
      private var _88844982outerDocument:GWizToolCrib;
      
      private var _868894951toSlot:NumericStepper;
      
      private var _428532091toolRange:RadioButton;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var toolCrib:GWizToolCrib;
      
      public function GWizG10Export()
      {
         super();
         mx_internal::_document = this;
         this.title = "Export Tool Table as G10 Program";
         this.okLabel = "Custom";
         this.mxmlContent = [this._GWizG10Export_VGroup1_c()];
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
      
      override public function onOk(param1:Event) : void
      {
         this.toolCrib.onG10OK(param1);
         super.close();
      }
      
      private function _GWizG10Export_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizG10Export_Label1_c(),this._GWizG10Export_HGroup1_c(),this._GWizG10Export_HGroup2_c(),this._GWizG10Export_HGroup3_c(),this._GWizG10Export_Spacer4_c(),this._GWizG10Export_CheckBox1_i(),this._GWizG10Export_CheckBox2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Export Style:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizG10Export_Spacer1_c(),this._GWizG10Export_RadioButton1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 30;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "All Tools";
         _loc1_.groupName = "g10style";
         _loc1_.selected = true;
         _loc1_.id = "allTools";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.allTools = _loc1_;
         BindingManager.executeBindings(this,"allTools",this.allTools);
         return _loc1_;
      }
      
      private function _GWizG10Export_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizG10Export_Spacer2_c(),this._GWizG10Export_RadioButton2_i(),this._GWizG10Export_Label2_c(),this._GWizG10Export_NumericStepper1_i(),this._GWizG10Export_Label3_c(),this._GWizG10Export_NumericStepper2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 30;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Slot Range";
         _loc1_.groupName = "g10style";
         _loc1_.id = "toolRange";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolRange = _loc1_;
         BindingManager.executeBindings(this,"toolRange",this.toolRange);
         return _loc1_;
      }
      
      private function _GWizG10Export_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "From slot ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 10000;
         _loc1_.stepSize = 1;
         _loc1_.id = "fromSlot";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fromSlot = _loc1_;
         BindingManager.executeBindings(this,"fromSlot",this.fromSlot);
         return _loc1_;
      }
      
      private function _GWizG10Export_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "To slot ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 10000;
         _loc1_.stepSize = 1;
         _loc1_.id = "toSlot";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toSlot = _loc1_;
         BindingManager.executeBindings(this,"toSlot",this.toSlot);
         return _loc1_;
      }
      
      private function _GWizG10Export_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizG10Export_Spacer3_c(),this._GWizG10Export_RadioButton3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 30;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Current Tool Only";
         _loc1_.groupName = "g10style";
         _loc1_.id = "currToolOnly";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.currToolOnly = _loc1_;
         BindingManager.executeBindings(this,"currToolOnly",this.currToolOnly);
         return _loc1_;
      }
      
      private function _GWizG10Export_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 30;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizG10Export_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Tool Length";
         _loc1_.selected = true;
         _loc1_.id = "doToolLength";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.doToolLength = _loc1_;
         BindingManager.executeBindings(this,"doToolLength",this.doToolLength);
         return _loc1_;
      }
      
      private function _GWizG10Export_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Tool Comp";
         _loc1_.id = "doToolComp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.doToolComp = _loc1_;
         BindingManager.executeBindings(this,"doToolComp",this.doToolComp);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get allTools() : RadioButton
      {
         return this._1787968698allTools;
      }
      
      public function set allTools(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1787968698allTools;
         if(_loc2_ !== param1)
         {
            this._1787968698allTools = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"allTools",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get currToolOnly() : RadioButton
      {
         return this._1633793610currToolOnly;
      }
      
      public function set currToolOnly(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1633793610currToolOnly;
         if(_loc2_ !== param1)
         {
            this._1633793610currToolOnly = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"currToolOnly",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get doToolComp() : CheckBox
      {
         return this._2140059250doToolComp;
      }
      
      public function set doToolComp(param1:CheckBox) : void
      {
         var _loc2_:Object = this._2140059250doToolComp;
         if(_loc2_ !== param1)
         {
            this._2140059250doToolComp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"doToolComp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get doToolLength() : CheckBox
      {
         return this._443943543doToolLength;
      }
      
      public function set doToolLength(param1:CheckBox) : void
      {
         var _loc2_:Object = this._443943543doToolLength;
         if(_loc2_ !== param1)
         {
            this._443943543doToolLength = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"doToolLength",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fromSlot() : NumericStepper
      {
         return this._1244688184fromSlot;
      }
      
      public function set fromSlot(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1244688184fromSlot;
         if(_loc2_ !== param1)
         {
            this._1244688184fromSlot = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fromSlot",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizToolCrib
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizToolCrib) : void
      {
         var _loc2_:Object = this._88844982outerDocument;
         if(_loc2_ !== param1)
         {
            this._88844982outerDocument = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outerDocument",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toSlot() : NumericStepper
      {
         return this._868894951toSlot;
      }
      
      public function set toSlot(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._868894951toSlot;
         if(_loc2_ !== param1)
         {
            this._868894951toSlot = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toSlot",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolRange() : RadioButton
      {
         return this._428532091toolRange;
      }
      
      public function set toolRange(param1:RadioButton) : void
      {
         var _loc2_:Object = this._428532091toolRange;
         if(_loc2_ !== param1)
         {
            this._428532091toolRange = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolRange",_loc2_,param1));
            }
         }
      }
   }
}
