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
   import spark.components.Label;
   import spark.primitives.Rect;
   import spark.skins.SparkButtonSkin;
   
   public class ButtonBarMiddleButtonSkin extends SparkButtonSkin implements IStateClient2
   {
      
      private static const exclusions:Array = ["labelDisplay"];
       
      
      private var _1669602936_ButtonBarMiddleButtonSkin_GradientEntry1:GradientEntry;
      
      private var _218083416_ButtonBarMiddleButtonSkin_GradientEntry10:GradientEntry;
      
      private var _218083408_ButtonBarMiddleButtonSkin_GradientEntry18:GradientEntry;
      
      private var _218083407_ButtonBarMiddleButtonSkin_GradientEntry19:GradientEntry;
      
      private var _1669602935_ButtonBarMiddleButtonSkin_GradientEntry2:GradientEntry;
      
      private var _1669602931_ButtonBarMiddleButtonSkin_GradientEntry6:GradientEntry;
      
      private var _1669602930_ButtonBarMiddleButtonSkin_GradientEntry7:GradientEntry;
      
      private var _1669602928_ButtonBarMiddleButtonSkin_GradientEntry9:GradientEntry;
      
      public var _ButtonBarMiddleButtonSkin_Rect4:Rect;
      
      public var _ButtonBarMiddleButtonSkin_Rect5:Rect;
      
      private var _1140415008_ButtonBarMiddleButtonSkin_SolidColor1:SolidColor;
      
      private var _1472494227hldownstroke1:Rect;
      
      private var _1472494228hldownstroke2:Rect;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function ButtonBarMiddleButtonSkin()
      {
         super();
         mx_internal::_document = this;
         this.minWidth = 21;
         this.minHeight = 21;
         this.mxmlContent = [this._ButtonBarMiddleButtonSkin_Rect1_c(),this._ButtonBarMiddleButtonSkin_Rect2_c(),this._ButtonBarMiddleButtonSkin_Rect3_c(),this._ButtonBarMiddleButtonSkin_Rect4_i(),this._ButtonBarMiddleButtonSkin_Rect8_c(),this._ButtonBarMiddleButtonSkin_Label1_i()];
         this.currentState = "up";
         var _loc1_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._ButtonBarMiddleButtonSkin_Rect5_i);
         var _loc2_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._ButtonBarMiddleButtonSkin_Rect6_i);
         var _loc3_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._ButtonBarMiddleButtonSkin_Rect7_i);
         states = [new State({
            "name":"up",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            })]
         }),new State({
            "name":"over",
            "stateGroups":["overStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.22
            })]
         }),new State({
            "name":"down",
            "stateGroups":["downStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_SolidColor1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_SolidColor1",
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry19",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"disabled",
            "stateGroups":["disabledStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"upAndSelected",
            "stateGroups":["selectedUpStates","selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry19",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"overAndSelected",
            "stateGroups":["overStates","selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"alpha",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":9342864
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"alpha",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry19",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"downAndSelected",
            "stateGroups":["downStates","selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_SolidColor1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_SolidColor1",
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry19",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"disabledAndSelected",
            "stateGroups":["disabledStates","selectedUpStates","selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_ButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_ButtonBarMiddleButtonSkin_GradientEntry19",
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
      
      override protected function initializationComplete() : void
      {
         useChromeColor = true;
         super.initializationComplete();
      }
      
      override public function get colorizeExclusions() : Array
      {
         return exclusions;
      }
      
      private function _ButtonBarMiddleButtonSkin_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.bottom = -1;
         _loc1_.height = 1;
         _loc1_.fill = this._ButtonBarMiddleButtonSkin_SolidColor1_i();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         this._ButtonBarMiddleButtonSkin_SolidColor1 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_SolidColor1",this._ButtonBarMiddleButtonSkin_SolidColor1);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_Rect2_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._ButtonBarMiddleButtonSkin_LinearGradient1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._ButtonBarMiddleButtonSkin_GradientEntry1_i(),this._ButtonBarMiddleButtonSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.85;
         this._ButtonBarMiddleButtonSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_GradientEntry1",this._ButtonBarMiddleButtonSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         _loc1_.alpha = 0.85;
         this._ButtonBarMiddleButtonSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_GradientEntry2",this._ButtonBarMiddleButtonSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_Rect3_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._ButtonBarMiddleButtonSkin_LinearGradient2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_LinearGradient2_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 270;
         _loc1_.entries = [this._ButtonBarMiddleButtonSkin_GradientEntry3_c(),this._ButtonBarMiddleButtonSkin_GradientEntry4_c(),this._ButtonBarMiddleButtonSkin_GradientEntry5_c()];
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry3_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.0627;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry4_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.48;
         _loc1_.alpha = 0.0099;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry5_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.48001;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_Rect4_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._ButtonBarMiddleButtonSkin_LinearGradient3_c();
         _loc1_.initialized(this,"_ButtonBarMiddleButtonSkin_Rect4");
         this._ButtonBarMiddleButtonSkin_Rect4 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_Rect4",this._ButtonBarMiddleButtonSkin_Rect4);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_LinearGradient3_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._ButtonBarMiddleButtonSkin_GradientEntry6_i(),this._ButtonBarMiddleButtonSkin_GradientEntry7_i(),this._ButtonBarMiddleButtonSkin_GradientEntry8_c()];
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry6_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.33;
         this._ButtonBarMiddleButtonSkin_GradientEntry6 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_GradientEntry6",this._ButtonBarMiddleButtonSkin_GradientEntry6);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry7_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.48;
         _loc1_.alpha = 0.33;
         this._ButtonBarMiddleButtonSkin_GradientEntry7 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_GradientEntry7",this._ButtonBarMiddleButtonSkin_GradientEntry7);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry8_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.48001;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_Rect5_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.stroke = this._ButtonBarMiddleButtonSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,"_ButtonBarMiddleButtonSkin_Rect5");
         this._ButtonBarMiddleButtonSkin_Rect5 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_Rect5",this._ButtonBarMiddleButtonSkin_Rect5);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._ButtonBarMiddleButtonSkin_GradientEntry9_i(),this._ButtonBarMiddleButtonSkin_GradientEntry10_i()];
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry9_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         this._ButtonBarMiddleButtonSkin_GradientEntry9 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_GradientEntry9",this._ButtonBarMiddleButtonSkin_GradientEntry9);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry10_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         this._ButtonBarMiddleButtonSkin_GradientEntry10 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_GradientEntry10",this._ButtonBarMiddleButtonSkin_GradientEntry10);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_Rect6_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.stroke = this._ButtonBarMiddleButtonSkin_LinearGradientStroke2_c();
         _loc1_.initialized(this,"hldownstroke1");
         this.hldownstroke1 = _loc1_;
         BindingManager.executeBindings(this,"hldownstroke1",this.hldownstroke1);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_LinearGradientStroke2_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._ButtonBarMiddleButtonSkin_GradientEntry11_c(),this._ButtonBarMiddleButtonSkin_GradientEntry12_c(),this._ButtonBarMiddleButtonSkin_GradientEntry13_c(),this._ButtonBarMiddleButtonSkin_GradientEntry14_c(),this._ButtonBarMiddleButtonSkin_GradientEntry15_c()];
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry11_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         _loc1_.ratio = 0;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry12_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         _loc1_.ratio = 0.001;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry13_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         _loc1_.ratio = 0.0011;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry14_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         _loc1_.ratio = 0.965;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry15_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         _loc1_.ratio = 0.9651;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_Rect7_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 2;
         _loc1_.right = 2;
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.stroke = this._ButtonBarMiddleButtonSkin_LinearGradientStroke3_c();
         _loc1_.initialized(this,"hldownstroke2");
         this.hldownstroke2 = _loc1_;
         BindingManager.executeBindings(this,"hldownstroke2",this.hldownstroke2);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_LinearGradientStroke3_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._ButtonBarMiddleButtonSkin_GradientEntry16_c(),this._ButtonBarMiddleButtonSkin_GradientEntry17_c()];
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry16_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.09;
         _loc1_.ratio = 0;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry17_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         _loc1_.ratio = 0.0001;
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_Rect8_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.width = 69;
         _loc1_.height = 20;
         _loc1_.stroke = this._ButtonBarMiddleButtonSkin_LinearGradientStroke4_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_LinearGradientStroke4_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._ButtonBarMiddleButtonSkin_GradientEntry18_i(),this._ButtonBarMiddleButtonSkin_GradientEntry19_i()];
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry18_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.5625;
         this._ButtonBarMiddleButtonSkin_GradientEntry18 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_GradientEntry18",this._ButtonBarMiddleButtonSkin_GradientEntry18);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_GradientEntry19_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.75;
         this._ButtonBarMiddleButtonSkin_GradientEntry19 = _loc1_;
         BindingManager.executeBindings(this,"_ButtonBarMiddleButtonSkin_GradientEntry19",this._ButtonBarMiddleButtonSkin_GradientEntry19);
         return _loc1_;
      }
      
      private function _ButtonBarMiddleButtonSkin_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.maxDisplayedLines = 1;
         _loc1_.horizontalCenter = 0;
         _loc1_.verticalCenter = 1;
         _loc1_.left = 10;
         _loc1_.right = 10;
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("verticalAlign","middle");
         _loc1_.id = "labelDisplay";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         labelDisplay = _loc1_;
         BindingManager.executeBindings(this,"labelDisplay",labelDisplay);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get _ButtonBarMiddleButtonSkin_GradientEntry1() : GradientEntry
      {
         return this._1669602936_ButtonBarMiddleButtonSkin_GradientEntry1;
      }
      
      public function set _ButtonBarMiddleButtonSkin_GradientEntry1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1669602936_ButtonBarMiddleButtonSkin_GradientEntry1;
         if(_loc2_ !== param1)
         {
            this._1669602936_ButtonBarMiddleButtonSkin_GradientEntry1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ButtonBarMiddleButtonSkin_GradientEntry1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ButtonBarMiddleButtonSkin_GradientEntry10() : GradientEntry
      {
         return this._218083416_ButtonBarMiddleButtonSkin_GradientEntry10;
      }
      
      public function set _ButtonBarMiddleButtonSkin_GradientEntry10(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._218083416_ButtonBarMiddleButtonSkin_GradientEntry10;
         if(_loc2_ !== param1)
         {
            this._218083416_ButtonBarMiddleButtonSkin_GradientEntry10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ButtonBarMiddleButtonSkin_GradientEntry10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ButtonBarMiddleButtonSkin_GradientEntry18() : GradientEntry
      {
         return this._218083408_ButtonBarMiddleButtonSkin_GradientEntry18;
      }
      
      public function set _ButtonBarMiddleButtonSkin_GradientEntry18(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._218083408_ButtonBarMiddleButtonSkin_GradientEntry18;
         if(_loc2_ !== param1)
         {
            this._218083408_ButtonBarMiddleButtonSkin_GradientEntry18 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ButtonBarMiddleButtonSkin_GradientEntry18",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ButtonBarMiddleButtonSkin_GradientEntry19() : GradientEntry
      {
         return this._218083407_ButtonBarMiddleButtonSkin_GradientEntry19;
      }
      
      public function set _ButtonBarMiddleButtonSkin_GradientEntry19(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._218083407_ButtonBarMiddleButtonSkin_GradientEntry19;
         if(_loc2_ !== param1)
         {
            this._218083407_ButtonBarMiddleButtonSkin_GradientEntry19 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ButtonBarMiddleButtonSkin_GradientEntry19",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ButtonBarMiddleButtonSkin_GradientEntry2() : GradientEntry
      {
         return this._1669602935_ButtonBarMiddleButtonSkin_GradientEntry2;
      }
      
      public function set _ButtonBarMiddleButtonSkin_GradientEntry2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1669602935_ButtonBarMiddleButtonSkin_GradientEntry2;
         if(_loc2_ !== param1)
         {
            this._1669602935_ButtonBarMiddleButtonSkin_GradientEntry2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ButtonBarMiddleButtonSkin_GradientEntry2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ButtonBarMiddleButtonSkin_GradientEntry6() : GradientEntry
      {
         return this._1669602931_ButtonBarMiddleButtonSkin_GradientEntry6;
      }
      
      public function set _ButtonBarMiddleButtonSkin_GradientEntry6(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1669602931_ButtonBarMiddleButtonSkin_GradientEntry6;
         if(_loc2_ !== param1)
         {
            this._1669602931_ButtonBarMiddleButtonSkin_GradientEntry6 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ButtonBarMiddleButtonSkin_GradientEntry6",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ButtonBarMiddleButtonSkin_GradientEntry7() : GradientEntry
      {
         return this._1669602930_ButtonBarMiddleButtonSkin_GradientEntry7;
      }
      
      public function set _ButtonBarMiddleButtonSkin_GradientEntry7(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1669602930_ButtonBarMiddleButtonSkin_GradientEntry7;
         if(_loc2_ !== param1)
         {
            this._1669602930_ButtonBarMiddleButtonSkin_GradientEntry7 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ButtonBarMiddleButtonSkin_GradientEntry7",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ButtonBarMiddleButtonSkin_GradientEntry9() : GradientEntry
      {
         return this._1669602928_ButtonBarMiddleButtonSkin_GradientEntry9;
      }
      
      public function set _ButtonBarMiddleButtonSkin_GradientEntry9(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1669602928_ButtonBarMiddleButtonSkin_GradientEntry9;
         if(_loc2_ !== param1)
         {
            this._1669602928_ButtonBarMiddleButtonSkin_GradientEntry9 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ButtonBarMiddleButtonSkin_GradientEntry9",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ButtonBarMiddleButtonSkin_SolidColor1() : SolidColor
      {
         return this._1140415008_ButtonBarMiddleButtonSkin_SolidColor1;
      }
      
      public function set _ButtonBarMiddleButtonSkin_SolidColor1(param1:SolidColor) : void
      {
         var _loc2_:Object = this._1140415008_ButtonBarMiddleButtonSkin_SolidColor1;
         if(_loc2_ !== param1)
         {
            this._1140415008_ButtonBarMiddleButtonSkin_SolidColor1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ButtonBarMiddleButtonSkin_SolidColor1",_loc2_,param1));
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
   }
}
