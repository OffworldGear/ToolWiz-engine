package mx.skins.spark
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
   import mx.graphics.SolidColor;
   import mx.states.AddItems;
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.primitives.Path;
   import spark.primitives.Rect;
   
   public class PopUpButtonSkin extends SparkSkinForHalo implements IStateClient2
   {
      
      private static const exclusions:Array = ["arrow"];
      
      private static const symbols:Array = ["arrowFill1","arrowFill2"];
      
      private static const borderItem:Array = ["borderEntry1","borderEntry2"];
       
      
      private var _818185038_PopUpButtonSkin_GradientEntry1:GradientEntry;
      
      private var _406067646_PopUpButtonSkin_GradientEntry10:GradientEntry;
      
      private var _406067647_PopUpButtonSkin_GradientEntry11:GradientEntry;
      
      private var _406067649_PopUpButtonSkin_GradientEntry13:GradientEntry;
      
      private var _406067650_PopUpButtonSkin_GradientEntry14:GradientEntry;
      
      private var _406067653_PopUpButtonSkin_GradientEntry17:GradientEntry;
      
      private var _406067654_PopUpButtonSkin_GradientEntry18:GradientEntry;
      
      private var _818185037_PopUpButtonSkin_GradientEntry2:GradientEntry;
      
      private var _818185036_PopUpButtonSkin_GradientEntry3:GradientEntry;
      
      private var _818185035_PopUpButtonSkin_GradientEntry4:GradientEntry;
      
      private var _818185034_PopUpButtonSkin_GradientEntry5:GradientEntry;
      
      private var _818185033_PopUpButtonSkin_GradientEntry6:GradientEntry;
      
      public var _PopUpButtonSkin_Rect10:Rect;
      
      public var _PopUpButtonSkin_Rect11:Rect;
      
      public var _PopUpButtonSkin_Rect12:Rect;
      
      public var _PopUpButtonSkin_Rect13:Rect;
      
      public var _PopUpButtonSkin_Rect14:Rect;
      
      public var _PopUpButtonSkin_Rect7:Rect;
      
      public var _PopUpButtonSkin_Rect8:Rect;
      
      public var _PopUpButtonSkin_Rect9:Rect;
      
      private var _93090825arrow:Path;
      
      private var _1752992635arrowFill1:GradientEntry;
      
      private var _1752992634arrowFill2:GradientEntry;
      
      private var _1383304148border:Rect;
      
      private var _989500747borderEntry1:GradientEntry;
      
      private var _989500748borderEntry2:GradientEntry;
      
      private var _3143043fill:Rect;
      
      private var _97434383fill2:Rect;
      
      private var _681210700highlight:Rect;
      
      private var _1507289076highlightStroke:Rect;
      
      private var _1811511742lowlight:Rect;
      
      private var _903579360shadow:Rect;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var cornerRadius:Number = 2;
      
      public function PopUpButtonSkin()
      {
         super();
         mx_internal::_document = this;
         this.minWidth = 21;
         this.minHeight = 21;
         this.mxmlContent = [this._PopUpButtonSkin_Rect1_i(),this._PopUpButtonSkin_Rect2_i(),this._PopUpButtonSkin_Rect3_i(),this._PopUpButtonSkin_Rect4_i(),this._PopUpButtonSkin_Rect5_i(),this._PopUpButtonSkin_Rect15_i(),this._PopUpButtonSkin_Rect16_c(),this._PopUpButtonSkin_Path1_i()];
         this.currentState = "up";
         var _loc1_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._PopUpButtonSkin_Rect10_i);
         var _loc2_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._PopUpButtonSkin_Rect11_i);
         var _loc3_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._PopUpButtonSkin_Rect12_i);
         var _loc4_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._PopUpButtonSkin_Rect13_i);
         var _loc5_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._PopUpButtonSkin_Rect14_i);
         var _loc6_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._PopUpButtonSkin_Rect6_i);
         var _loc7_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._PopUpButtonSkin_Rect7_i);
         var _loc8_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._PopUpButtonSkin_Rect8_i);
         var _loc9_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._PopUpButtonSkin_Rect9_i);
         states = [new State({
            "name":"up",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc6_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            })]
         }),new State({
            "name":"over",
            "stateGroups":["overStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc6_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry3",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry4",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry11",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry13",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry14",
               "name":"alpha",
               "value":0.22
            })]
         }),new State({
            "name":"down",
            "stateGroups":["downStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc9_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc8_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc7_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry1",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry2",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry2",
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry3",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry4",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry11",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"borderEntry1",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"borderEntry2",
               "name":"alpha",
               "value":0.85
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry17",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"disabled",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc6_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"popUpOver",
            "stateGroups":["overStates","popUpStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc6_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry5",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry6",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry11",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry13",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry14",
               "name":"alpha",
               "value":0.22
            })]
         }),new State({
            "name":"popUpDown",
            "stateGroups":["downStates","popUpStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc5_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc4_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
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
               "target":"_PopUpButtonSkin_GradientEntry1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry1",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry2",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry2",
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry5",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry6",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry11",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"borderEntry1",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"borderEntry2",
               "name":"alpha",
               "value":0.85
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry17",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_PopUpButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.85
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
      
      override protected function get borderItems() : Array
      {
         return borderItem;
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
            this.shadow.radiusX = this.cornerRadius;
            this.fill.topLeftRadiusX = this.cornerRadius;
            this.fill.bottomLeftRadiusX = this.cornerRadius;
            this.fill2.topRightRadiusX = this.cornerRadius;
            this.fill2.bottomRightRadiusX = this.cornerRadius;
            this.lowlight.radiusX = this.cornerRadius;
            this.highlight.radiusX = this.cornerRadius;
            this.border.radiusX = this.cornerRadius;
         }
         if(this.highlightStroke)
         {
            this.highlightStroke.radiusX = this.cornerRadius;
         }
         super.updateDisplayList(param1,param2);
      }
      
      private function _PopUpButtonSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = -1;
         _loc1_.right = -1;
         _loc1_.top = -1;
         _loc1_.bottom = -1;
         _loc1_.radiusX = 2;
         _loc1_.fill = this._PopUpButtonSkin_LinearGradient1_c();
         _loc1_.initialized(this,"shadow");
         this.shadow = _loc1_;
         BindingManager.executeBindings(this,"shadow",this.shadow);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._PopUpButtonSkin_GradientEntry1_i(),this._PopUpButtonSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.01;
         this._PopUpButtonSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry1",this._PopUpButtonSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         this._PopUpButtonSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry2",this._PopUpButtonSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 18;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.topLeftRadiusX = 2;
         _loc1_.bottomLeftRadiusX = 2;
         _loc1_.fill = this._PopUpButtonSkin_LinearGradient2_c();
         _loc1_.initialized(this,"fill");
         this.fill = _loc1_;
         BindingManager.executeBindings(this,"fill",this.fill);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_LinearGradient2_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._PopUpButtonSkin_GradientEntry3_i(),this._PopUpButtonSkin_GradientEntry4_i()];
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry3_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.85;
         this._PopUpButtonSkin_GradientEntry3 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry3",this._PopUpButtonSkin_GradientEntry3);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry4_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         _loc1_.alpha = 0.85;
         this._PopUpButtonSkin_GradientEntry4 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry4",this._PopUpButtonSkin_GradientEntry4);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect3_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.width = 18;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.topRightRadiusX = 2;
         _loc1_.bottomRightRadiusX = 2;
         _loc1_.fill = this._PopUpButtonSkin_LinearGradient3_c();
         _loc1_.initialized(this,"fill2");
         this.fill2 = _loc1_;
         BindingManager.executeBindings(this,"fill2",this.fill2);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_LinearGradient3_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._PopUpButtonSkin_GradientEntry5_i(),this._PopUpButtonSkin_GradientEntry6_i()];
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry5_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.85;
         this._PopUpButtonSkin_GradientEntry5 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry5",this._PopUpButtonSkin_GradientEntry5);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry6_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         _loc1_.alpha = 0.85;
         this._PopUpButtonSkin_GradientEntry6 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry6",this._PopUpButtonSkin_GradientEntry6);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect4_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.radiusX = 2;
         _loc1_.fill = this._PopUpButtonSkin_LinearGradient4_c();
         _loc1_.initialized(this,"lowlight");
         this.lowlight = _loc1_;
         BindingManager.executeBindings(this,"lowlight",this.lowlight);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_LinearGradient4_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 270;
         _loc1_.entries = [this._PopUpButtonSkin_GradientEntry7_c(),this._PopUpButtonSkin_GradientEntry8_c(),this._PopUpButtonSkin_GradientEntry9_c()];
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry7_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.0627;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry8_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.48;
         _loc1_.alpha = 0.0099;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry9_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.48001;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect5_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.radiusX = 2;
         _loc1_.fill = this._PopUpButtonSkin_LinearGradient5_c();
         _loc1_.initialized(this,"highlight");
         this.highlight = _loc1_;
         BindingManager.executeBindings(this,"highlight",this.highlight);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_LinearGradient5_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._PopUpButtonSkin_GradientEntry10_i(),this._PopUpButtonSkin_GradientEntry11_i(),this._PopUpButtonSkin_GradientEntry12_c()];
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry10_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.33;
         this._PopUpButtonSkin_GradientEntry10 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry10",this._PopUpButtonSkin_GradientEntry10);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry11_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.48;
         _loc1_.alpha = 0.33;
         this._PopUpButtonSkin_GradientEntry11 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry11",this._PopUpButtonSkin_GradientEntry11);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry12_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.48001;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect6_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.radiusX = 2;
         _loc1_.stroke = this._PopUpButtonSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,"highlightStroke");
         this.highlightStroke = _loc1_;
         BindingManager.executeBindings(this,"highlightStroke",this.highlightStroke);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._PopUpButtonSkin_GradientEntry13_i(),this._PopUpButtonSkin_GradientEntry14_i()];
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry13_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         this._PopUpButtonSkin_GradientEntry13 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry13",this._PopUpButtonSkin_GradientEntry13);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry14_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         this._PopUpButtonSkin_GradientEntry14 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry14",this._PopUpButtonSkin_GradientEntry14);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect7_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.width = 1;
         _loc1_.fill = this._PopUpButtonSkin_SolidColor1_c();
         _loc1_.initialized(this,"_PopUpButtonSkin_Rect7");
         this._PopUpButtonSkin_Rect7 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_Rect7",this._PopUpButtonSkin_Rect7);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect8_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.right = 19;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.width = 1;
         _loc1_.fill = this._PopUpButtonSkin_SolidColor2_c();
         _loc1_.initialized(this,"_PopUpButtonSkin_Rect8");
         this._PopUpButtonSkin_Rect8 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_Rect8",this._PopUpButtonSkin_Rect8);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_SolidColor2_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect9_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 2;
         _loc1_.top = 1;
         _loc1_.right = 19;
         _loc1_.height = 1;
         _loc1_.fill = this._PopUpButtonSkin_SolidColor3_c();
         _loc1_.initialized(this,"_PopUpButtonSkin_Rect9");
         this._PopUpButtonSkin_Rect9 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_Rect9",this._PopUpButtonSkin_Rect9);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_SolidColor3_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect10_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.top = 2;
         _loc1_.right = 19;
         _loc1_.height = 1;
         _loc1_.fill = this._PopUpButtonSkin_SolidColor4_c();
         _loc1_.initialized(this,"_PopUpButtonSkin_Rect10");
         this._PopUpButtonSkin_Rect10 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_Rect10",this._PopUpButtonSkin_Rect10);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_SolidColor4_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.09;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect11_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.right = 17;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.width = 1;
         _loc1_.fill = this._PopUpButtonSkin_SolidColor5_c();
         _loc1_.initialized(this,"_PopUpButtonSkin_Rect11");
         this._PopUpButtonSkin_Rect11 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_Rect11",this._PopUpButtonSkin_Rect11);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_SolidColor5_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect12_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.width = 1;
         _loc1_.fill = this._PopUpButtonSkin_SolidColor6_c();
         _loc1_.initialized(this,"_PopUpButtonSkin_Rect12");
         this._PopUpButtonSkin_Rect12 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_Rect12",this._PopUpButtonSkin_Rect12);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_SolidColor6_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect13_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.width = 16;
         _loc1_.top = 1;
         _loc1_.right = 2;
         _loc1_.height = 1;
         _loc1_.fill = this._PopUpButtonSkin_SolidColor7_c();
         _loc1_.initialized(this,"_PopUpButtonSkin_Rect13");
         this._PopUpButtonSkin_Rect13 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_Rect13",this._PopUpButtonSkin_Rect13);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_SolidColor7_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect14_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.width = 17;
         _loc1_.top = 2;
         _loc1_.right = 1;
         _loc1_.height = 1;
         _loc1_.fill = this._PopUpButtonSkin_SolidColor8_c();
         _loc1_.initialized(this,"_PopUpButtonSkin_Rect14");
         this._PopUpButtonSkin_Rect14 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_Rect14",this._PopUpButtonSkin_Rect14);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_SolidColor8_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.09;
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect15_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.width = 69;
         _loc1_.height = 20;
         _loc1_.radiusX = 2;
         _loc1_.stroke = this._PopUpButtonSkin_LinearGradientStroke2_c();
         _loc1_.initialized(this,"border");
         this.border = _loc1_;
         BindingManager.executeBindings(this,"border",this.border);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_LinearGradientStroke2_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._PopUpButtonSkin_GradientEntry15_i(),this._PopUpButtonSkin_GradientEntry16_i()];
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry15_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.alpha = 0.5625;
         this.borderEntry1 = _loc1_;
         BindingManager.executeBindings(this,"borderEntry1",this.borderEntry1);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry16_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.alpha = 0.75;
         this.borderEntry2 = _loc1_;
         BindingManager.executeBindings(this,"borderEntry2",this.borderEntry2);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Rect16_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.right = 18;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.width = 1;
         _loc1_.fill = this._PopUpButtonSkin_LinearGradient6_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_LinearGradient6_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._PopUpButtonSkin_GradientEntry17_i(),this._PopUpButtonSkin_GradientEntry18_i()];
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry17_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.5625;
         this._PopUpButtonSkin_GradientEntry17 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry17",this._PopUpButtonSkin_GradientEntry17);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry18_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.75;
         this._PopUpButtonSkin_GradientEntry18 = _loc1_;
         BindingManager.executeBindings(this,"_PopUpButtonSkin_GradientEntry18",this._PopUpButtonSkin_GradientEntry18);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_Path1_i() : Path
      {
         var _loc1_:Path = new Path();
         _loc1_.right = 6;
         _loc1_.verticalCenter = 0;
         _loc1_.data = "M 4.0 4.0 L 4.0 3.0 L 5.0 3.0 L 5.0 2.0 L 6.0 2.0 L 6.0 1.0 L 7.0 1.0 L 7.0 0.0 L 0.0 0.0 L 0.0 1.0 L 1.0 1.0 L 1.0 2.0 L 2.0 2.0 L 2.0 3.0 L 3.0 3.0 L 3.0 4.0 L 4.0 4.0";
         _loc1_.fill = this._PopUpButtonSkin_RadialGradient1_c();
         _loc1_.initialized(this,"arrow");
         this.arrow = _loc1_;
         BindingManager.executeBindings(this,"arrow",this.arrow);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_RadialGradient1_c() : RadialGradient
      {
         var _loc1_:RadialGradient = new RadialGradient();
         _loc1_.rotation = 90;
         _loc1_.focalPointRatio = 1;
         _loc1_.entries = [this._PopUpButtonSkin_GradientEntry19_i(),this._PopUpButtonSkin_GradientEntry20_i()];
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry19_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.6;
         this.arrowFill1 = _loc1_;
         BindingManager.executeBindings(this,"arrowFill1",this.arrowFill1);
         return _loc1_;
      }
      
      private function _PopUpButtonSkin_GradientEntry20_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.8;
         this.arrowFill2 = _loc1_;
         BindingManager.executeBindings(this,"arrowFill2",this.arrowFill2);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry1() : GradientEntry
      {
         return this._818185038_PopUpButtonSkin_GradientEntry1;
      }
      
      public function set _PopUpButtonSkin_GradientEntry1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._818185038_PopUpButtonSkin_GradientEntry1;
         if(_loc2_ !== param1)
         {
            this._818185038_PopUpButtonSkin_GradientEntry1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry10() : GradientEntry
      {
         return this._406067646_PopUpButtonSkin_GradientEntry10;
      }
      
      public function set _PopUpButtonSkin_GradientEntry10(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._406067646_PopUpButtonSkin_GradientEntry10;
         if(_loc2_ !== param1)
         {
            this._406067646_PopUpButtonSkin_GradientEntry10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry11() : GradientEntry
      {
         return this._406067647_PopUpButtonSkin_GradientEntry11;
      }
      
      public function set _PopUpButtonSkin_GradientEntry11(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._406067647_PopUpButtonSkin_GradientEntry11;
         if(_loc2_ !== param1)
         {
            this._406067647_PopUpButtonSkin_GradientEntry11 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry11",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry13() : GradientEntry
      {
         return this._406067649_PopUpButtonSkin_GradientEntry13;
      }
      
      public function set _PopUpButtonSkin_GradientEntry13(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._406067649_PopUpButtonSkin_GradientEntry13;
         if(_loc2_ !== param1)
         {
            this._406067649_PopUpButtonSkin_GradientEntry13 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry13",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry14() : GradientEntry
      {
         return this._406067650_PopUpButtonSkin_GradientEntry14;
      }
      
      public function set _PopUpButtonSkin_GradientEntry14(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._406067650_PopUpButtonSkin_GradientEntry14;
         if(_loc2_ !== param1)
         {
            this._406067650_PopUpButtonSkin_GradientEntry14 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry14",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry17() : GradientEntry
      {
         return this._406067653_PopUpButtonSkin_GradientEntry17;
      }
      
      public function set _PopUpButtonSkin_GradientEntry17(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._406067653_PopUpButtonSkin_GradientEntry17;
         if(_loc2_ !== param1)
         {
            this._406067653_PopUpButtonSkin_GradientEntry17 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry17",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry18() : GradientEntry
      {
         return this._406067654_PopUpButtonSkin_GradientEntry18;
      }
      
      public function set _PopUpButtonSkin_GradientEntry18(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._406067654_PopUpButtonSkin_GradientEntry18;
         if(_loc2_ !== param1)
         {
            this._406067654_PopUpButtonSkin_GradientEntry18 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry18",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry2() : GradientEntry
      {
         return this._818185037_PopUpButtonSkin_GradientEntry2;
      }
      
      public function set _PopUpButtonSkin_GradientEntry2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._818185037_PopUpButtonSkin_GradientEntry2;
         if(_loc2_ !== param1)
         {
            this._818185037_PopUpButtonSkin_GradientEntry2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry3() : GradientEntry
      {
         return this._818185036_PopUpButtonSkin_GradientEntry3;
      }
      
      public function set _PopUpButtonSkin_GradientEntry3(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._818185036_PopUpButtonSkin_GradientEntry3;
         if(_loc2_ !== param1)
         {
            this._818185036_PopUpButtonSkin_GradientEntry3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry4() : GradientEntry
      {
         return this._818185035_PopUpButtonSkin_GradientEntry4;
      }
      
      public function set _PopUpButtonSkin_GradientEntry4(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._818185035_PopUpButtonSkin_GradientEntry4;
         if(_loc2_ !== param1)
         {
            this._818185035_PopUpButtonSkin_GradientEntry4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry5() : GradientEntry
      {
         return this._818185034_PopUpButtonSkin_GradientEntry5;
      }
      
      public function set _PopUpButtonSkin_GradientEntry5(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._818185034_PopUpButtonSkin_GradientEntry5;
         if(_loc2_ !== param1)
         {
            this._818185034_PopUpButtonSkin_GradientEntry5 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry5",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PopUpButtonSkin_GradientEntry6() : GradientEntry
      {
         return this._818185033_PopUpButtonSkin_GradientEntry6;
      }
      
      public function set _PopUpButtonSkin_GradientEntry6(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._818185033_PopUpButtonSkin_GradientEntry6;
         if(_loc2_ !== param1)
         {
            this._818185033_PopUpButtonSkin_GradientEntry6 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PopUpButtonSkin_GradientEntry6",_loc2_,param1));
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
      public function get borderEntry1() : GradientEntry
      {
         return this._989500747borderEntry1;
      }
      
      public function set borderEntry1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._989500747borderEntry1;
         if(_loc2_ !== param1)
         {
            this._989500747borderEntry1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"borderEntry1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get borderEntry2() : GradientEntry
      {
         return this._989500748borderEntry2;
      }
      
      public function set borderEntry2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._989500748borderEntry2;
         if(_loc2_ !== param1)
         {
            this._989500748borderEntry2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"borderEntry2",_loc2_,param1));
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
      public function get fill2() : Rect
      {
         return this._97434383fill2;
      }
      
      public function set fill2(param1:Rect) : void
      {
         var _loc2_:Object = this._97434383fill2;
         if(_loc2_ !== param1)
         {
            this._97434383fill2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fill2",_loc2_,param1));
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
      public function get shadow() : Rect
      {
         return this._903579360shadow;
      }
      
      public function set shadow(param1:Rect) : void
      {
         var _loc2_:Object = this._903579360shadow;
         if(_loc2_ !== param1)
         {
            this._903579360shadow = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"shadow",_loc2_,param1));
            }
         }
      }
   }
}
