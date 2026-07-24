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
   import mx.graphics.RadialGradient;
   import mx.states.AddItems;
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.components.Button;
   import spark.primitives.Path;
   import spark.primitives.Rect;
   import spark.skins.SparkSkin;
   
   public class ComboBoxButtonSkin extends SparkSkin implements IStateClient2
   {
      
      private static const exclusions:Array = ["arrow"];
      
      private static const symbols:Array = ["arrowFill1","arrowFill2"];
       
      
      private var _1186801763_ComboBoxButtonSkin_GradientEntry1:GradientEntry;
      
      private var _1863850963_ComboBoxButtonSkin_GradientEntry10:GradientEntry;
      
      private var _1863850955_ComboBoxButtonSkin_GradientEntry18:GradientEntry;
      
      private var _1863850954_ComboBoxButtonSkin_GradientEntry19:GradientEntry;
      
      private var _1186801764_ComboBoxButtonSkin_GradientEntry2:GradientEntry;
      
      private var _1186801768_ComboBoxButtonSkin_GradientEntry6:GradientEntry;
      
      private var _1186801769_ComboBoxButtonSkin_GradientEntry7:GradientEntry;
      
      private var _1186801771_ComboBoxButtonSkin_GradientEntry9:GradientEntry;
      
      private var _93090825arrow:Path;
      
      private var _1752992635arrowFill1:GradientEntry;
      
      private var _1752992634arrowFill2:GradientEntry;
      
      private var _1383304148border:Rect;
      
      private var _3143043fill:Rect;
      
      private var _681210700highlight:Rect;
      
      private var _1507289076highlightStroke:Rect;
      
      private var _1472494227hldownstroke1:Rect;
      
      private var _1472494228hldownstroke2:Rect;
      
      private var _1811511742lowlight:Rect;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var cornerRadius:Number = 0;
      
      private var _213507019hostComponent:Button;
      
      public function ComboBoxButtonSkin()
      {
         super();
         mx_internal::_document = this;
         this.minWidth = 19;
         this.minHeight = 23;
         this.mxmlContent = [this._ComboBoxButtonSkin_Rect1_i(),this._ComboBoxButtonSkin_Rect2_i(),this._ComboBoxButtonSkin_Rect3_i(),this._ComboBoxButtonSkin_Rect7_i(),this._ComboBoxButtonSkin_Path1_i()];
         this.currentState = "up";
         var _loc1_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._ComboBoxButtonSkin_Rect4_i);
         var _loc2_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._ComboBoxButtonSkin_Rect5_i);
         var _loc3_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._ComboBoxButtonSkin_Rect6_i);
         states = [new State({
            "name":"up",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            })]
         }),new State({
            "name":"over",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry1",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry2",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.22
            })]
         }),new State({
            "name":"down",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry1",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry2",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_ComboBoxButtonSkin_GradientEntry19",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"disabled",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            })]
         })];
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
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = getStyle("cornerRadius");
         if(this.cornerRadius != _loc3_)
         {
            this.cornerRadius = _loc3_;
            this.fill.bottomRightRadiusX = this.fill.topRightRadiusX = this.cornerRadius;
            this.lowlight.bottomRightRadiusX = this.lowlight.topRightRadiusX = this.cornerRadius;
            this.highlight.bottomRightRadiusX = this.highlight.topRightRadiusX = this.cornerRadius;
            this.border.bottomRightRadiusX = this.border.topRightRadiusX = this.cornerRadius;
         }
         if(this.highlightStroke)
         {
            this.highlightStroke.bottomRightRadiusX = this.highlightStroke.topRightRadiusX = this.cornerRadius;
         }
         if(this.hldownstroke1)
         {
            this.hldownstroke1.bottomRightRadiusX = this.hldownstroke1.topRightRadiusX = this.cornerRadius;
         }
         if(this.hldownstroke2)
         {
            this.hldownstroke2.bottomRightRadiusX = this.hldownstroke2.topRightRadiusX = this.cornerRadius;
         }
         super.updateDisplayList(param1,param2);
      }
      
      private function _ComboBoxButtonSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._ComboBoxButtonSkin_LinearGradient1_c();
         _loc1_.initialized(this,"fill");
         this.fill = _loc1_;
         BindingManager.executeBindings(this,"fill",this.fill);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._ComboBoxButtonSkin_GradientEntry1_i(),this._ComboBoxButtonSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.85;
         this._ComboBoxButtonSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_ComboBoxButtonSkin_GradientEntry1",this._ComboBoxButtonSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         _loc1_.alpha = 0.85;
         this._ComboBoxButtonSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_ComboBoxButtonSkin_GradientEntry2",this._ComboBoxButtonSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._ComboBoxButtonSkin_LinearGradient2_c();
         _loc1_.initialized(this,"lowlight");
         this.lowlight = _loc1_;
         BindingManager.executeBindings(this,"lowlight",this.lowlight);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_LinearGradient2_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 270;
         _loc1_.entries = [this._ComboBoxButtonSkin_GradientEntry3_c(),this._ComboBoxButtonSkin_GradientEntry4_c(),this._ComboBoxButtonSkin_GradientEntry5_c()];
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry3_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.0627;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry4_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.48;
         _loc1_.alpha = 0.0099;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry5_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.48001;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_Rect3_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._ComboBoxButtonSkin_LinearGradient3_c();
         _loc1_.initialized(this,"highlight");
         this.highlight = _loc1_;
         BindingManager.executeBindings(this,"highlight",this.highlight);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_LinearGradient3_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._ComboBoxButtonSkin_GradientEntry6_i(),this._ComboBoxButtonSkin_GradientEntry7_i(),this._ComboBoxButtonSkin_GradientEntry8_c()];
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry6_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.33;
         this._ComboBoxButtonSkin_GradientEntry6 = _loc1_;
         BindingManager.executeBindings(this,"_ComboBoxButtonSkin_GradientEntry6",this._ComboBoxButtonSkin_GradientEntry6);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry7_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.48;
         _loc1_.alpha = 0.33;
         this._ComboBoxButtonSkin_GradientEntry7 = _loc1_;
         BindingManager.executeBindings(this,"_ComboBoxButtonSkin_GradientEntry7",this._ComboBoxButtonSkin_GradientEntry7);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry8_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.48001;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_Rect4_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.radiusX = 0;
         _loc1_.radiusY = 0;
         _loc1_.stroke = this._ComboBoxButtonSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,"highlightStroke");
         this.highlightStroke = _loc1_;
         BindingManager.executeBindings(this,"highlightStroke",this.highlightStroke);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._ComboBoxButtonSkin_GradientEntry9_i(),this._ComboBoxButtonSkin_GradientEntry10_i()];
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry9_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         this._ComboBoxButtonSkin_GradientEntry9 = _loc1_;
         BindingManager.executeBindings(this,"_ComboBoxButtonSkin_GradientEntry9",this._ComboBoxButtonSkin_GradientEntry9);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry10_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         this._ComboBoxButtonSkin_GradientEntry10 = _loc1_;
         BindingManager.executeBindings(this,"_ComboBoxButtonSkin_GradientEntry10",this._ComboBoxButtonSkin_GradientEntry10);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_Rect5_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.radiusX = 0;
         _loc1_.radiusY = 0;
         _loc1_.stroke = this._ComboBoxButtonSkin_LinearGradientStroke2_c();
         _loc1_.initialized(this,"hldownstroke1");
         this.hldownstroke1 = _loc1_;
         BindingManager.executeBindings(this,"hldownstroke1",this.hldownstroke1);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_LinearGradientStroke2_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._ComboBoxButtonSkin_GradientEntry11_c(),this._ComboBoxButtonSkin_GradientEntry12_c(),this._ComboBoxButtonSkin_GradientEntry13_c(),this._ComboBoxButtonSkin_GradientEntry14_c(),this._ComboBoxButtonSkin_GradientEntry15_c()];
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry11_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         _loc1_.ratio = 0;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry12_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         _loc1_.ratio = 0.001;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry13_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         _loc1_.ratio = 0.0011;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry14_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         _loc1_.ratio = 0.965;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry15_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         _loc1_.ratio = 0.9651;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_Rect6_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 2;
         _loc1_.right = 2;
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.radiusX = 0;
         _loc1_.radiusY = 0;
         _loc1_.stroke = this._ComboBoxButtonSkin_LinearGradientStroke3_c();
         _loc1_.initialized(this,"hldownstroke2");
         this.hldownstroke2 = _loc1_;
         BindingManager.executeBindings(this,"hldownstroke2",this.hldownstroke2);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_LinearGradientStroke3_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._ComboBoxButtonSkin_GradientEntry16_c(),this._ComboBoxButtonSkin_GradientEntry17_c()];
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry16_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.09;
         _loc1_.ratio = 0;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry17_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         _loc1_.ratio = 0.0001;
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_Rect7_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.width = 18;
         _loc1_.height = 21;
         _loc1_.stroke = this._ComboBoxButtonSkin_LinearGradientStroke4_c();
         _loc1_.initialized(this,"border");
         this.border = _loc1_;
         BindingManager.executeBindings(this,"border",this.border);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_LinearGradientStroke4_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._ComboBoxButtonSkin_GradientEntry18_i(),this._ComboBoxButtonSkin_GradientEntry19_i()];
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry18_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.5625;
         this._ComboBoxButtonSkin_GradientEntry18 = _loc1_;
         BindingManager.executeBindings(this,"_ComboBoxButtonSkin_GradientEntry18",this._ComboBoxButtonSkin_GradientEntry18);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry19_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.75;
         this._ComboBoxButtonSkin_GradientEntry19 = _loc1_;
         BindingManager.executeBindings(this,"_ComboBoxButtonSkin_GradientEntry19",this._ComboBoxButtonSkin_GradientEntry19);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_Path1_i() : Path
      {
         var _loc1_:Path = new Path();
         _loc1_.right = 6;
         _loc1_.verticalCenter = 0;
         _loc1_.data = "M 4.0 4.0 L 4.0 3.0 L 5.0 3.0 L 5.0 2.0 L 6.0 2.0 L 6.0 1.0 L 7.0 1.0 L 7.0 0.0 L 0.0 0.0 L 0.0 1.0 L 1.0 1.0 L 1.0 2.0 L 2.0 2.0 L 2.0 3.0 L 3.0 3.0 L 3.0 4.0 L 4.0 4.0";
         _loc1_.fill = this._ComboBoxButtonSkin_RadialGradient1_c();
         _loc1_.initialized(this,"arrow");
         this.arrow = _loc1_;
         BindingManager.executeBindings(this,"arrow",this.arrow);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_RadialGradient1_c() : RadialGradient
      {
         var _loc1_:RadialGradient = new RadialGradient();
         _loc1_.rotation = 90;
         _loc1_.focalPointRatio = 1;
         _loc1_.entries = [this._ComboBoxButtonSkin_GradientEntry20_i(),this._ComboBoxButtonSkin_GradientEntry21_i()];
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry20_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.6;
         this.arrowFill1 = _loc1_;
         BindingManager.executeBindings(this,"arrowFill1",this.arrowFill1);
         return _loc1_;
      }
      
      private function _ComboBoxButtonSkin_GradientEntry21_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.8;
         this.arrowFill2 = _loc1_;
         BindingManager.executeBindings(this,"arrowFill2",this.arrowFill2);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get _ComboBoxButtonSkin_GradientEntry1() : GradientEntry
      {
         return this._1186801763_ComboBoxButtonSkin_GradientEntry1;
      }
      
      public function set _ComboBoxButtonSkin_GradientEntry1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1186801763_ComboBoxButtonSkin_GradientEntry1;
         if(_loc2_ !== param1)
         {
            this._1186801763_ComboBoxButtonSkin_GradientEntry1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ComboBoxButtonSkin_GradientEntry1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ComboBoxButtonSkin_GradientEntry10() : GradientEntry
      {
         return this._1863850963_ComboBoxButtonSkin_GradientEntry10;
      }
      
      public function set _ComboBoxButtonSkin_GradientEntry10(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1863850963_ComboBoxButtonSkin_GradientEntry10;
         if(_loc2_ !== param1)
         {
            this._1863850963_ComboBoxButtonSkin_GradientEntry10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ComboBoxButtonSkin_GradientEntry10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ComboBoxButtonSkin_GradientEntry18() : GradientEntry
      {
         return this._1863850955_ComboBoxButtonSkin_GradientEntry18;
      }
      
      public function set _ComboBoxButtonSkin_GradientEntry18(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1863850955_ComboBoxButtonSkin_GradientEntry18;
         if(_loc2_ !== param1)
         {
            this._1863850955_ComboBoxButtonSkin_GradientEntry18 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ComboBoxButtonSkin_GradientEntry18",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ComboBoxButtonSkin_GradientEntry19() : GradientEntry
      {
         return this._1863850954_ComboBoxButtonSkin_GradientEntry19;
      }
      
      public function set _ComboBoxButtonSkin_GradientEntry19(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1863850954_ComboBoxButtonSkin_GradientEntry19;
         if(_loc2_ !== param1)
         {
            this._1863850954_ComboBoxButtonSkin_GradientEntry19 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ComboBoxButtonSkin_GradientEntry19",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ComboBoxButtonSkin_GradientEntry2() : GradientEntry
      {
         return this._1186801764_ComboBoxButtonSkin_GradientEntry2;
      }
      
      public function set _ComboBoxButtonSkin_GradientEntry2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1186801764_ComboBoxButtonSkin_GradientEntry2;
         if(_loc2_ !== param1)
         {
            this._1186801764_ComboBoxButtonSkin_GradientEntry2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ComboBoxButtonSkin_GradientEntry2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ComboBoxButtonSkin_GradientEntry6() : GradientEntry
      {
         return this._1186801768_ComboBoxButtonSkin_GradientEntry6;
      }
      
      public function set _ComboBoxButtonSkin_GradientEntry6(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1186801768_ComboBoxButtonSkin_GradientEntry6;
         if(_loc2_ !== param1)
         {
            this._1186801768_ComboBoxButtonSkin_GradientEntry6 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ComboBoxButtonSkin_GradientEntry6",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ComboBoxButtonSkin_GradientEntry7() : GradientEntry
      {
         return this._1186801769_ComboBoxButtonSkin_GradientEntry7;
      }
      
      public function set _ComboBoxButtonSkin_GradientEntry7(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1186801769_ComboBoxButtonSkin_GradientEntry7;
         if(_loc2_ !== param1)
         {
            this._1186801769_ComboBoxButtonSkin_GradientEntry7 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ComboBoxButtonSkin_GradientEntry7",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ComboBoxButtonSkin_GradientEntry9() : GradientEntry
      {
         return this._1186801771_ComboBoxButtonSkin_GradientEntry9;
      }
      
      public function set _ComboBoxButtonSkin_GradientEntry9(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1186801771_ComboBoxButtonSkin_GradientEntry9;
         if(_loc2_ !== param1)
         {
            this._1186801771_ComboBoxButtonSkin_GradientEntry9 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ComboBoxButtonSkin_GradientEntry9",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get arrow() : Path
      {
         return this._93090825arrow;
      }
      
      public function set arrow(param1:Path) : void
      {
         var _loc2_:Object = this._93090825arrow;
         if(_loc2_ !== param1)
         {
            this._93090825arrow = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"arrow",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get arrowFill1() : GradientEntry
      {
         return this._1752992635arrowFill1;
      }
      
      public function set arrowFill1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1752992635arrowFill1;
         if(_loc2_ !== param1)
         {
            this._1752992635arrowFill1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"arrowFill1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get arrowFill2() : GradientEntry
      {
         return this._1752992634arrowFill2;
      }
      
      public function set arrowFill2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1752992634arrowFill2;
         if(_loc2_ !== param1)
         {
            this._1752992634arrowFill2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"arrowFill2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get border() : Rect
      {
         return this._1383304148border;
      }
      
      public function set border(param1:Rect) : void
      {
         var _loc2_:Object = this._1383304148border;
         if(_loc2_ !== param1)
         {
            this._1383304148border = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"border",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fill() : Rect
      {
         return this._3143043fill;
      }
      
      public function set fill(param1:Rect) : void
      {
         var _loc2_:Object = this._3143043fill;
         if(_loc2_ !== param1)
         {
            this._3143043fill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get highlight() : Rect
      {
         return this._681210700highlight;
      }
      
      public function set highlight(param1:Rect) : void
      {
         var _loc2_:Object = this._681210700highlight;
         if(_loc2_ !== param1)
         {
            this._681210700highlight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"highlight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get highlightStroke() : Rect
      {
         return this._1507289076highlightStroke;
      }
      
      public function set highlightStroke(param1:Rect) : void
      {
         var _loc2_:Object = this._1507289076highlightStroke;
         if(_loc2_ !== param1)
         {
            this._1507289076highlightStroke = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"highlightStroke",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hldownstroke1() : Rect
      {
         return this._1472494227hldownstroke1;
      }
      
      public function set hldownstroke1(param1:Rect) : void
      {
         var _loc2_:Object = this._1472494227hldownstroke1;
         if(_loc2_ !== param1)
         {
            this._1472494227hldownstroke1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hldownstroke1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hldownstroke2() : Rect
      {
         return this._1472494228hldownstroke2;
      }
      
      public function set hldownstroke2(param1:Rect) : void
      {
         var _loc2_:Object = this._1472494228hldownstroke2;
         if(_loc2_ !== param1)
         {
            this._1472494228hldownstroke2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hldownstroke2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get lowlight() : Rect
      {
         return this._1811511742lowlight;
      }
      
      public function set lowlight(param1:Rect) : void
      {
         var _loc2_:Object = this._1811511742lowlight;
         if(_loc2_ !== param1)
         {
            this._1811511742lowlight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"lowlight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : Button
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:Button) : void
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
