package spark.skins.spark
{
   import mx.binding.BindingManager;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.GradientEntry;
   import mx.graphics.LinearGradient;
   import mx.graphics.LinearGradientStroke;
   import mx.graphics.SolidColor;
   import mx.states.AddItems;
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.components.Group;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.primitives.Ellipse;
   import spark.primitives.Path;
   import spark.primitives.Rect;
   import spark.skins.SparkSkin;
   
   public class RadioButtonSkin extends SparkSkin implements IStateClient2
   {
      
      private static const exclusions:Array = ["labelDisplay","dot"];
      
      private static const symbols:Array = ["dotFill"];
      
      private static const focusExclusions:Array = ["labelDisplay"];
       
      
      public var _RadioButtonSkin_Ellipse4:Ellipse;
      
      private var _1125779357_RadioButtonSkin_GradientEntry1:GradientEntry;
      
      private var _1125779356_RadioButtonSkin_GradientEntry2:GradientEntry;
      
      private var _1125779355_RadioButtonSkin_GradientEntry3:GradientEntry;
      
      private var _1125779354_RadioButtonSkin_GradientEntry4:GradientEntry;
      
      private var _1125779353_RadioButtonSkin_GradientEntry5:GradientEntry;
      
      private var _1125779352_RadioButtonSkin_GradientEntry6:GradientEntry;
      
      private var _399597734_RadioButtonSkin_Group1:Group;
      
      public var _RadioButtonSkin_Path3:Path;
      
      private var _1007364390_RadioButtonSkin_SolidColor2:SolidColor;
      
      private var _99657dot:Path;
      
      private var _1843208812dotFill:SolidColor;
      
      private var _1184053038labelDisplay:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _213507019hostComponent:RadioButton;
      
      public function RadioButtonSkin()
      {
         var _loc1_:DeferredInstanceFromFunction = null;
         super();
         mx_internal::_document = this;
         this.mxmlContent = [this._RadioButtonSkin_Group1_i(),this._RadioButtonSkin_Label1_i()];
         this.currentState = "up";
         _loc1_ = new DeferredInstanceFromFunction(this._RadioButtonSkin_Path2_i);
         var _loc2_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._RadioButtonSkin_Path3_i);
         states = [new State({
            "name":"up",
            "overrides":[]
         }),new State({
            "name":"over",
            "stateGroups":["overStates"],
            "overrides":[new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry3",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry4",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry5",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_SolidColor2",
               "name":"alpha",
               "value":0.22
            })]
         }),new State({
            "name":"down",
            "stateGroups":["downStates"],
            "overrides":[new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry1",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry2",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry2",
               "name":"alpha",
               "value":0.57
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry3",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry4",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry5",
               "name":"color",
               "value":9671571
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry6",
               "name":"color",
               "value":11645361
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_SolidColor2",
               "name":"color",
               "value":9671571
            })]
         }),new State({
            "name":"disabled",
            "stateGroups":["disabledStates"],
            "overrides":[new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"upAndSelected",
            "stateGroups":["selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":"_RadioButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_RadioButtonSkin_Ellipse4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":"_RadioButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_RadioButtonSkin_Ellipse4"]
            })]
         }),new State({
            "name":"overAndSelected",
            "stateGroups":["overStates","selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":"_RadioButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_RadioButtonSkin_Ellipse4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":"_RadioButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_RadioButtonSkin_Ellipse4"]
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry3",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry4",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry5",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_SolidColor2",
               "name":"alpha",
               "value":0.22
            })]
         }),new State({
            "name":"downAndSelected",
            "stateGroups":["downStates","selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":"_RadioButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_RadioButtonSkin_Ellipse4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":"_RadioButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_RadioButtonSkin_Ellipse4"]
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry1",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry2",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry2",
               "name":"alpha",
               "value":0.57
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry3",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry4",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry5",
               "name":"color",
               "value":9671571
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_GradientEntry6",
               "name":"color",
               "value":11645361
            }),new SetProperty().initializeFromObject({
               "target":"_RadioButtonSkin_SolidColor2",
               "name":"color",
               "value":9671571
            })]
         }),new State({
            "name":"disabledAndSelected",
            "stateGroups":["disabledStates","selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":"_RadioButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_RadioButtonSkin_Ellipse4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":"_RadioButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_RadioButtonSkin_Ellipse4"]
            }),new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         })];
         _loc1_.getInstance();
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
      
      override public function get colorizeExclusions() : Array
      {
         return exclusions;
      }
      
      override public function get symbolItems() : Array
      {
         return symbols;
      }
      
      override protected function initializationComplete() : void
      {
         useChromeColor = true;
         super.initializationComplete();
      }
      
      override public function get focusSkinExclusions() : Array
      {
         return focusExclusions;
      }
      
      private function _RadioButtonSkin_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.verticalCenter = 0;
         _loc1_.width = 13;
         _loc1_.height = 13;
         _loc1_.mxmlContent = [this._RadioButtonSkin_Ellipse1_c(),this._RadioButtonSkin_Ellipse2_c(),this._RadioButtonSkin_Path1_c(),this._RadioButtonSkin_Ellipse3_c(),this._RadioButtonSkin_Rect1_c(),this._RadioButtonSkin_Ellipse4_i()];
         _loc1_.id = "_RadioButtonSkin_Group1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._RadioButtonSkin_Group1 = _loc1_;
         BindingManager.executeBindings(this,"_RadioButtonSkin_Group1",this._RadioButtonSkin_Group1);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_Ellipse1_c() : Ellipse
      {
         var _loc1_:Ellipse = new Ellipse();
         _loc1_.left = -1;
         _loc1_.top = -1;
         _loc1_.right = -1;
         _loc1_.bottom = -1;
         _loc1_.stroke = this._RadioButtonSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._RadioButtonSkin_GradientEntry1_i(),this._RadioButtonSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.011;
         this._RadioButtonSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_RadioButtonSkin_GradientEntry1",this._RadioButtonSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.121;
         this._RadioButtonSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_RadioButtonSkin_GradientEntry2",this._RadioButtonSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_Ellipse2_c() : Ellipse
      {
         var _loc1_:Ellipse = new Ellipse();
         _loc1_.left = 1;
         _loc1_.top = 1;
         _loc1_.right = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._RadioButtonSkin_LinearGradient1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._RadioButtonSkin_GradientEntry3_i(),this._RadioButtonSkin_GradientEntry4_i()];
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry3_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.85;
         this._RadioButtonSkin_GradientEntry3 = _loc1_;
         BindingManager.executeBindings(this,"_RadioButtonSkin_GradientEntry3",this._RadioButtonSkin_GradientEntry3);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry4_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         _loc1_.alpha = 0.85;
         this._RadioButtonSkin_GradientEntry4 = _loc1_;
         BindingManager.executeBindings(this,"_RadioButtonSkin_GradientEntry4",this._RadioButtonSkin_GradientEntry4);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_Path1_c() : Path
      {
         var _loc1_:Path = new Path();
         _loc1_.data = "M 1 6 Q 2 2 6 1 Q 11 2 12 6 h -9";
         _loc1_.fill = this._RadioButtonSkin_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.33;
         return _loc1_;
      }
      
      private function _RadioButtonSkin_Ellipse3_c() : Ellipse
      {
         var _loc1_:Ellipse = new Ellipse();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.stroke = this._RadioButtonSkin_LinearGradientStroke2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_LinearGradientStroke2_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._RadioButtonSkin_GradientEntry5_i(),this._RadioButtonSkin_GradientEntry6_i()];
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry5_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         this._RadioButtonSkin_GradientEntry5 = _loc1_;
         BindingManager.executeBindings(this,"_RadioButtonSkin_GradientEntry5",this._RadioButtonSkin_GradientEntry5);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry6_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         this._RadioButtonSkin_GradientEntry6 = _loc1_;
         BindingManager.executeBindings(this,"_RadioButtonSkin_GradientEntry6",this._RadioButtonSkin_GradientEntry6);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 5;
         _loc1_.top = 1;
         _loc1_.right = 5;
         _loc1_.height = 1;
         _loc1_.fill = this._RadioButtonSkin_SolidColor2_i();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_SolidColor2_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         this._RadioButtonSkin_SolidColor2 = _loc1_;
         BindingManager.executeBindings(this,"_RadioButtonSkin_SolidColor2",this._RadioButtonSkin_SolidColor2);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_Ellipse4_i() : Ellipse
      {
         var _loc1_:Ellipse = new Ellipse();
         _loc1_.left = 0;
         _loc1_.top = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.stroke = this._RadioButtonSkin_LinearGradientStroke3_c();
         _loc1_.initialized(this,"_RadioButtonSkin_Ellipse4");
         this._RadioButtonSkin_Ellipse4 = _loc1_;
         BindingManager.executeBindings(this,"_RadioButtonSkin_Ellipse4",this._RadioButtonSkin_Ellipse4);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_LinearGradientStroke3_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._RadioButtonSkin_GradientEntry7_c(),this._RadioButtonSkin_GradientEntry8_c()];
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry7_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.7;
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry8_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.8;
         return _loc1_;
      }
      
      private function _RadioButtonSkin_Path2_i() : Path
      {
         var _loc1_:Path = new Path();
         _loc1_.left = 4;
         _loc1_.top = 4;
         _loc1_.data = "M 2.5 0 Q 4.5 0.5 5 2.5 Q 4.5 4.5 2.5 5 Q 0.5 4.5 0 2.5 Q 0.5 0.5 2.5 0";
         _loc1_.fill = this._RadioButtonSkin_SolidColor3_i();
         _loc1_.initialized(this,"dot");
         this.dot = _loc1_;
         BindingManager.executeBindings(this,"dot",this.dot);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_SolidColor3_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.9;
         this.dotFill = _loc1_;
         BindingManager.executeBindings(this,"dotFill",this.dotFill);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_Path3_i() : Path
      {
         var _loc1_:Path = new Path();
         _loc1_.left = 4;
         _loc1_.top = 7;
         _loc1_.data = "M 0 0 Q 0.5 2 2.5 2.0 Q 3.5 2.0 4 0";
         _loc1_.stroke = this._RadioButtonSkin_LinearGradientStroke4_c();
         _loc1_.initialized(this,"_RadioButtonSkin_Path3");
         this._RadioButtonSkin_Path3 = _loc1_;
         BindingManager.executeBindings(this,"_RadioButtonSkin_Path3",this._RadioButtonSkin_Path3);
         return _loc1_;
      }
      
      private function _RadioButtonSkin_LinearGradientStroke4_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.entries = [this._RadioButtonSkin_GradientEntry9_c(),this._RadioButtonSkin_GradientEntry10_c(),this._RadioButtonSkin_GradientEntry11_c()];
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry9_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.3;
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry10_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.7;
         return _loc1_;
      }
      
      private function _RadioButtonSkin_GradientEntry11_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.3;
         return _loc1_;
      }
      
      private function _RadioButtonSkin_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.maxDisplayedLines = 1;
         _loc1_.left = 18;
         _loc1_.right = 0;
         _loc1_.top = 3;
         _loc1_.bottom = 3;
         _loc1_.verticalCenter = 2;
         _loc1_.setStyle("textAlign","start");
         _loc1_.setStyle("verticalAlign","middle");
         _loc1_.id = "labelDisplay";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labelDisplay = _loc1_;
         BindingManager.executeBindings(this,"labelDisplay",this.labelDisplay);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get _RadioButtonSkin_GradientEntry1() : GradientEntry
      {
         return this._1125779357_RadioButtonSkin_GradientEntry1;
      }
      
      public function set _RadioButtonSkin_GradientEntry1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1125779357_RadioButtonSkin_GradientEntry1;
         if(_loc2_ !== param1)
         {
            this._1125779357_RadioButtonSkin_GradientEntry1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_RadioButtonSkin_GradientEntry1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _RadioButtonSkin_GradientEntry2() : GradientEntry
      {
         return this._1125779356_RadioButtonSkin_GradientEntry2;
      }
      
      public function set _RadioButtonSkin_GradientEntry2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1125779356_RadioButtonSkin_GradientEntry2;
         if(_loc2_ !== param1)
         {
            this._1125779356_RadioButtonSkin_GradientEntry2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_RadioButtonSkin_GradientEntry2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _RadioButtonSkin_GradientEntry3() : GradientEntry
      {
         return this._1125779355_RadioButtonSkin_GradientEntry3;
      }
      
      public function set _RadioButtonSkin_GradientEntry3(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1125779355_RadioButtonSkin_GradientEntry3;
         if(_loc2_ !== param1)
         {
            this._1125779355_RadioButtonSkin_GradientEntry3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_RadioButtonSkin_GradientEntry3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _RadioButtonSkin_GradientEntry4() : GradientEntry
      {
         return this._1125779354_RadioButtonSkin_GradientEntry4;
      }
      
      public function set _RadioButtonSkin_GradientEntry4(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1125779354_RadioButtonSkin_GradientEntry4;
         if(_loc2_ !== param1)
         {
            this._1125779354_RadioButtonSkin_GradientEntry4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_RadioButtonSkin_GradientEntry4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _RadioButtonSkin_GradientEntry5() : GradientEntry
      {
         return this._1125779353_RadioButtonSkin_GradientEntry5;
      }
      
      public function set _RadioButtonSkin_GradientEntry5(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1125779353_RadioButtonSkin_GradientEntry5;
         if(_loc2_ !== param1)
         {
            this._1125779353_RadioButtonSkin_GradientEntry5 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_RadioButtonSkin_GradientEntry5",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _RadioButtonSkin_GradientEntry6() : GradientEntry
      {
         return this._1125779352_RadioButtonSkin_GradientEntry6;
      }
      
      public function set _RadioButtonSkin_GradientEntry6(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1125779352_RadioButtonSkin_GradientEntry6;
         if(_loc2_ !== param1)
         {
            this._1125779352_RadioButtonSkin_GradientEntry6 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_RadioButtonSkin_GradientEntry6",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _RadioButtonSkin_Group1() : Group
      {
         return this._399597734_RadioButtonSkin_Group1;
      }
      
      public function set _RadioButtonSkin_Group1(param1:Group) : void
      {
         var _loc2_:Object = this._399597734_RadioButtonSkin_Group1;
         if(_loc2_ !== param1)
         {
            this._399597734_RadioButtonSkin_Group1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_RadioButtonSkin_Group1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _RadioButtonSkin_SolidColor2() : SolidColor
      {
         return this._1007364390_RadioButtonSkin_SolidColor2;
      }
      
      public function set _RadioButtonSkin_SolidColor2(param1:SolidColor) : void
      {
         var _loc2_:Object = this._1007364390_RadioButtonSkin_SolidColor2;
         if(_loc2_ !== param1)
         {
            this._1007364390_RadioButtonSkin_SolidColor2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_RadioButtonSkin_SolidColor2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get dot() : Path
      {
         return this._99657dot;
      }
      
      public function set dot(param1:Path) : void
      {
         var _loc2_:Object = this._99657dot;
         if(_loc2_ !== param1)
         {
            this._99657dot = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dot",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get dotFill() : SolidColor
      {
         return this._1843208812dotFill;
      }
      
      public function set dotFill(param1:SolidColor) : void
      {
         var _loc2_:Object = this._1843208812dotFill;
         if(_loc2_ !== param1)
         {
            this._1843208812dotFill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dotFill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelDisplay() : Label
      {
         return this._1184053038labelDisplay;
      }
      
      public function set labelDisplay(param1:Label) : void
      {
         var _loc2_:Object = this._1184053038labelDisplay;
         if(_loc2_ !== param1)
         {
            this._1184053038labelDisplay = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelDisplay",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : RadioButton
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:RadioButton) : void
      {
         var _loc2_:Object = this._213507019hostComponent;
         if(_loc2_ !== param1)
         {
            this._213507019hostComponent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hostComponent",_loc2_,param1));
            }
         }
      }
   }
}
