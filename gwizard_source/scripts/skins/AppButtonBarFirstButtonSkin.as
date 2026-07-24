package skins
{
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.GradientEntry;
   import mx.graphics.LinearGradient;
   import mx.graphics.LinearGradientStroke;
   import mx.states.AddItems;
   import mx.states.SetProperty;
   import mx.states.SetStyle;
   import mx.states.State;
   import spark.components.Group;
   import spark.components.Label;
   import spark.primitives.Rect;
   import spark.skins.SparkButtonSkin;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class AppButtonBarFirstButtonSkin extends SparkButtonSkin implements IBindingClient, IStateClient2
   {
      
      private static const exclusions:Array = ["labelDisplay"];
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1590505294_AppButtonBarFirstButtonSkin_GradientEntry1:GradientEntry;
      
      private var _2061023906_AppButtonBarFirstButtonSkin_GradientEntry10:GradientEntry;
      
      private var _2061023907_AppButtonBarFirstButtonSkin_GradientEntry11:GradientEntry;
      
      private var _2061023908_AppButtonBarFirstButtonSkin_GradientEntry12:GradientEntry;
      
      private var _1590505295_AppButtonBarFirstButtonSkin_GradientEntry2:GradientEntry;
      
      private var _2061023937_AppButtonBarFirstButtonSkin_GradientEntry20:GradientEntry;
      
      private var _2061023938_AppButtonBarFirstButtonSkin_GradientEntry21:GradientEntry;
      
      private var _1590505296_AppButtonBarFirstButtonSkin_GradientEntry3:GradientEntry;
      
      private var _1590505297_AppButtonBarFirstButtonSkin_GradientEntry4:GradientEntry;
      
      private var _1590505301_AppButtonBarFirstButtonSkin_GradientEntry8:GradientEntry;
      
      private var _1590505302_AppButtonBarFirstButtonSkin_GradientEntry9:GradientEntry;
      
      private var _1304933009_AppButtonBarFirstButtonSkin_Group1:Group;
      
      private var _710933949_AppButtonBarFirstButtonSkin_SetStyle1:SetStyle;
      
      private var _710933948_AppButtonBarFirstButtonSkin_SetStyle2:SetStyle;
      
      private var _1383304148border:Rect;
      
      private var _3143043fill:Rect;
      
      private var _681210700highlight:Rect;
      
      private var _1507289076highlightStroke:Rect;
      
      private var _1472494227hldownstroke1:Rect;
      
      private var _1472494228hldownstroke2:Rect;
      
      private var _1811511742lowlight:Rect;
      
      private var _903579360shadow:Rect;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var cornerRadius:Number = 2;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function AppButtonBarFirstButtonSkin()
      {
         var bindings:Array = null;
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         bindings = this._AppButtonBarFirstButtonSkin_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_skins_AppButtonBarFirstButtonSkinWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return AppButtonBarFirstButtonSkin[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.minWidth = 21;
         this.minHeight = 21;
         this.mxmlContent = [this._AppButtonBarFirstButtonSkin_Group1_i(),this._AppButtonBarFirstButtonSkin_Label1_i()];
         this.currentState = "up";
         var _AppButtonBarFirstButtonSkin_Rect5_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AppButtonBarFirstButtonSkin_Rect5_i);
         var _AppButtonBarFirstButtonSkin_Rect6_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AppButtonBarFirstButtonSkin_Rect6_i);
         var _AppButtonBarFirstButtonSkin_Rect7_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AppButtonBarFirstButtonSkin_Rect7_i);
         states = [new State({
            "name":"up",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect5_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            })]
         }),new State({
            "name":"over",
            "stateGroups":["overStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect5_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry3",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry4",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry8",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry11",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry12",
               "name":"alpha",
               "value":0.22
            })]
         }),new State({
            "name":"down",
            "stateGroups":["downStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect7_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect6_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry1",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry2",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry2",
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry3",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry4",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry8",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry20",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry21",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"disabled",
            "stateGroups":["disabledStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect5_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"upAndSelected",
            "stateGroups":["selectedStates","selectedUpStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect7_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect6_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect5_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry3",
               "name":"color",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry4",
               "name":"color",
               "value":1118481
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry8",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry11",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry12",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry20",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry21",
               "name":"alpha",
               "value":0.85
            }),this._AppButtonBarFirstButtonSkin_SetStyle2 = SetStyle(new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"color",
               "value":undefined
            }))]
         }),new State({
            "name":"overAndSelected",
            "stateGroups":["selectedStates","overStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect7_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect6_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect5_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry3",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry3",
               "name":"alpha",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry4",
               "name":"color",
               "value":9342864
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry4",
               "name":"alpha",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry8",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry11",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry12",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry20",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry21",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"downAndSelected",
            "stateGroups":["selectedStates","downStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect7_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect6_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry1",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry2",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry2",
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry3",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry4",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry8",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry20",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry21",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"disabledAndSelected",
            "stateGroups":["selectedStates","selectedUpStates","disabledStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect7_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect6_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarFirstButtonSkin_Rect5_factory,
               "destination":"_AppButtonBarFirstButtonSkin_Group1",
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["highlight"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry3",
               "name":"color",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry4",
               "name":"color",
               "value":1118481
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry8",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry11",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry12",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry20",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarFirstButtonSkin_GradientEntry21",
               "name":"alpha",
               "value":0.85
            }),this._AppButtonBarFirstButtonSkin_SetStyle1 = SetStyle(new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"color",
               "value":undefined
            }))]
         })];
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_SetStyle2",this._AppButtonBarFirstButtonSkin_SetStyle2);
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_SetStyle1",this._AppButtonBarFirstButtonSkin_SetStyle1);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         AppButtonBarFirstButtonSkin._watcherSetupUtil = param1;
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
            this.shadow.topLeftRadiusX = this.cornerRadius;
            this.shadow.bottomLeftRadiusX = this.cornerRadius;
            this.fill.topLeftRadiusX = this.cornerRadius;
            this.fill.bottomLeftRadiusX = this.cornerRadius;
            this.lowlight.topLeftRadiusX = this.cornerRadius;
            this.lowlight.bottomLeftRadiusX = this.cornerRadius;
            this.highlight.topLeftRadiusX = this.cornerRadius;
            this.highlight.bottomLeftRadiusX = this.cornerRadius;
            this.highlightStroke.topLeftRadiusX = this.cornerRadius;
            this.highlightStroke.bottomLeftRadiusX = this.cornerRadius;
            this.border.topLeftRadiusX = this.cornerRadius;
            this.border.bottomLeftRadiusX = this.cornerRadius;
         }
         if(this.hldownstroke1)
         {
            this.hldownstroke1.topLeftRadiusX = this.cornerRadius;
            this.hldownstroke1.bottomLeftRadiusX = this.cornerRadius;
         }
         if(this.hldownstroke2)
         {
            this.hldownstroke2.topLeftRadiusX = this.cornerRadius;
            this.hldownstroke2.bottomLeftRadiusX = this.cornerRadius;
         }
         super.updateDisplayList(param1,unscaledHeight);
      }
      
      private function _AppButtonBarFirstButtonSkin_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.left = -1;
         _loc1_.right = 0;
         _loc1_.top = -1;
         _loc1_.bottom = -1;
         _loc1_.mxmlContent = [this._AppButtonBarFirstButtonSkin_Rect1_i(),this._AppButtonBarFirstButtonSkin_Rect2_i(),this._AppButtonBarFirstButtonSkin_Rect3_i(),this._AppButtonBarFirstButtonSkin_Rect4_i(),this._AppButtonBarFirstButtonSkin_Rect8_i()];
         _loc1_.id = "_AppButtonBarFirstButtonSkin_Group1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._AppButtonBarFirstButtonSkin_Group1 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_Group1",this._AppButtonBarFirstButtonSkin_Group1);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.width = 69;
         _loc1_.height = 20;
         _loc1_.topLeftRadiusX = 2;
         _loc1_.bottomLeftRadiusX = 2;
         _loc1_.stroke = this._AppButtonBarFirstButtonSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,"shadow");
         this.shadow = _loc1_;
         BindingManager.executeBindings(this,"shadow",this.shadow);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._AppButtonBarFirstButtonSkin_GradientEntry1_i(),this._AppButtonBarFirstButtonSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.01;
         this._AppButtonBarFirstButtonSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry1",this._AppButtonBarFirstButtonSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         this._AppButtonBarFirstButtonSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry2",this._AppButtonBarFirstButtonSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 2;
         _loc1_.right = 1;
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.topLeftRadiusX = 2;
         _loc1_.bottomLeftRadiusX = 2;
         _loc1_.fill = this._AppButtonBarFirstButtonSkin_LinearGradient1_c();
         _loc1_.initialized(this,"fill");
         this.fill = _loc1_;
         BindingManager.executeBindings(this,"fill",this.fill);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._AppButtonBarFirstButtonSkin_GradientEntry3_i(),this._AppButtonBarFirstButtonSkin_GradientEntry4_i()];
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry3_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 1;
         this._AppButtonBarFirstButtonSkin_GradientEntry3 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry3",this._AppButtonBarFirstButtonSkin_GradientEntry3);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry4_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         _loc1_.alpha = 0.85;
         this._AppButtonBarFirstButtonSkin_GradientEntry4 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry4",this._AppButtonBarFirstButtonSkin_GradientEntry4);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_Rect3_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 2;
         _loc1_.right = 1;
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.topLeftRadiusX = 2;
         _loc1_.bottomLeftRadiusX = 2;
         _loc1_.fill = this._AppButtonBarFirstButtonSkin_LinearGradient2_c();
         _loc1_.initialized(this,"lowlight");
         this.lowlight = _loc1_;
         BindingManager.executeBindings(this,"lowlight",this.lowlight);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_LinearGradient2_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 270;
         _loc1_.entries = [this._AppButtonBarFirstButtonSkin_GradientEntry5_c(),this._AppButtonBarFirstButtonSkin_GradientEntry6_c(),this._AppButtonBarFirstButtonSkin_GradientEntry7_c()];
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry5_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.0327;
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry6_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.65;
         _loc1_.alpha = 0.0099;
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry7_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.85;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_Rect4_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 2;
         _loc1_.right = 1;
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.topLeftRadiusX = 2;
         _loc1_.bottomLeftRadiusX = 2;
         _loc1_.fill = this._AppButtonBarFirstButtonSkin_LinearGradient3_c();
         _loc1_.initialized(this,"highlight");
         this.highlight = _loc1_;
         BindingManager.executeBindings(this,"highlight",this.highlight);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_LinearGradient3_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._AppButtonBarFirstButtonSkin_GradientEntry8_i(),this._AppButtonBarFirstButtonSkin_GradientEntry9_i(),this._AppButtonBarFirstButtonSkin_GradientEntry10_i()];
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry8_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.22;
         this._AppButtonBarFirstButtonSkin_GradientEntry8 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry8",this._AppButtonBarFirstButtonSkin_GradientEntry8);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry9_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.15;
         _loc1_.alpha = 0.22;
         this._AppButtonBarFirstButtonSkin_GradientEntry9 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry9",this._AppButtonBarFirstButtonSkin_GradientEntry9);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry10_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.45;
         _loc1_.alpha = 0;
         this._AppButtonBarFirstButtonSkin_GradientEntry10 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry10",this._AppButtonBarFirstButtonSkin_GradientEntry10);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_Rect5_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 2;
         _loc1_.right = 1;
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.topLeftRadiusX = 2;
         _loc1_.bottomLeftRadiusX = 2;
         _loc1_.stroke = this._AppButtonBarFirstButtonSkin_LinearGradientStroke2_c();
         _loc1_.initialized(this,"highlightStroke");
         this.highlightStroke = _loc1_;
         BindingManager.executeBindings(this,"highlightStroke",this.highlightStroke);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_LinearGradientStroke2_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._AppButtonBarFirstButtonSkin_GradientEntry11_i(),this._AppButtonBarFirstButtonSkin_GradientEntry12_i()];
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry11_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         this._AppButtonBarFirstButtonSkin_GradientEntry11 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry11",this._AppButtonBarFirstButtonSkin_GradientEntry11);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry12_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         this._AppButtonBarFirstButtonSkin_GradientEntry12 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry12",this._AppButtonBarFirstButtonSkin_GradientEntry12);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_Rect6_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 2;
         _loc1_.right = 1;
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.topLeftRadiusX = 2;
         _loc1_.bottomLeftRadiusX = 2;
         _loc1_.stroke = this._AppButtonBarFirstButtonSkin_LinearGradientStroke3_c();
         _loc1_.initialized(this,"hldownstroke1");
         this.hldownstroke1 = _loc1_;
         BindingManager.executeBindings(this,"hldownstroke1",this.hldownstroke1);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_LinearGradientStroke3_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._AppButtonBarFirstButtonSkin_GradientEntry13_c(),this._AppButtonBarFirstButtonSkin_GradientEntry14_c(),this._AppButtonBarFirstButtonSkin_GradientEntry15_c(),this._AppButtonBarFirstButtonSkin_GradientEntry16_c(),this._AppButtonBarFirstButtonSkin_GradientEntry17_c()];
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry13_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         _loc1_.ratio = 0;
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry14_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         _loc1_.ratio = 0.001;
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry15_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         _loc1_.ratio = 0.0011;
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry16_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         _loc1_.ratio = 0.965;
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry17_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         _loc1_.ratio = 0.9651;
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_Rect7_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 3;
         _loc1_.right = 2;
         _loc1_.top = 3;
         _loc1_.bottom = 3;
         _loc1_.topLeftRadiusX = 2;
         _loc1_.bottomLeftRadiusX = 2;
         _loc1_.stroke = this._AppButtonBarFirstButtonSkin_LinearGradientStroke4_c();
         _loc1_.initialized(this,"hldownstroke2");
         this.hldownstroke2 = _loc1_;
         BindingManager.executeBindings(this,"hldownstroke2",this.hldownstroke2);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_LinearGradientStroke4_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._AppButtonBarFirstButtonSkin_GradientEntry18_c(),this._AppButtonBarFirstButtonSkin_GradientEntry19_c()];
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry18_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.09;
         _loc1_.ratio = 0;
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry19_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         _loc1_.ratio = 0.0001;
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_Rect8_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 0;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.topLeftRadiusX = 2;
         _loc1_.bottomLeftRadiusX = 2;
         _loc1_.stroke = this._AppButtonBarFirstButtonSkin_LinearGradientStroke5_c();
         _loc1_.initialized(this,"border");
         this.border = _loc1_;
         BindingManager.executeBindings(this,"border",this.border);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_LinearGradientStroke5_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._AppButtonBarFirstButtonSkin_GradientEntry20_i(),this._AppButtonBarFirstButtonSkin_GradientEntry21_i()];
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry20_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.5625;
         this._AppButtonBarFirstButtonSkin_GradientEntry20 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry20",this._AppButtonBarFirstButtonSkin_GradientEntry20);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_GradientEntry21_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.75;
         this._AppButtonBarFirstButtonSkin_GradientEntry21 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarFirstButtonSkin_GradientEntry21",this._AppButtonBarFirstButtonSkin_GradientEntry21);
         return _loc1_;
      }
      
      private function _AppButtonBarFirstButtonSkin_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.maxDisplayedLines = 1;
         _loc1_.horizontalCenter = 0;
         _loc1_.verticalCenter = 1;
         _loc1_.left = 5;
         _loc1_.right = 5;
         _loc1_.top = 5;
         _loc1_.bottom = 5;
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
      
      private function _AppButtonBarFirstButtonSkin_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Object
         {
            return ColorPalette.complement5;
         },null,"_AppButtonBarFirstButtonSkin_SetStyle1.value");
         result[1] = new Binding(this,function():Object
         {
            return ColorPalette.complement5;
         },null,"_AppButtonBarFirstButtonSkin_SetStyle2.value");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry1() : GradientEntry
      {
         return this._1590505294_AppButtonBarFirstButtonSkin_GradientEntry1;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1590505294_AppButtonBarFirstButtonSkin_GradientEntry1;
         if(_loc2_ !== param1)
         {
            this._1590505294_AppButtonBarFirstButtonSkin_GradientEntry1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry10() : GradientEntry
      {
         return this._2061023906_AppButtonBarFirstButtonSkin_GradientEntry10;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry10(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._2061023906_AppButtonBarFirstButtonSkin_GradientEntry10;
         if(_loc2_ !== param1)
         {
            this._2061023906_AppButtonBarFirstButtonSkin_GradientEntry10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry11() : GradientEntry
      {
         return this._2061023907_AppButtonBarFirstButtonSkin_GradientEntry11;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry11(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._2061023907_AppButtonBarFirstButtonSkin_GradientEntry11;
         if(_loc2_ !== param1)
         {
            this._2061023907_AppButtonBarFirstButtonSkin_GradientEntry11 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry11",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry12() : GradientEntry
      {
         return this._2061023908_AppButtonBarFirstButtonSkin_GradientEntry12;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry12(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._2061023908_AppButtonBarFirstButtonSkin_GradientEntry12;
         if(_loc2_ !== param1)
         {
            this._2061023908_AppButtonBarFirstButtonSkin_GradientEntry12 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry12",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry2() : GradientEntry
      {
         return this._1590505295_AppButtonBarFirstButtonSkin_GradientEntry2;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1590505295_AppButtonBarFirstButtonSkin_GradientEntry2;
         if(_loc2_ !== param1)
         {
            this._1590505295_AppButtonBarFirstButtonSkin_GradientEntry2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry20() : GradientEntry
      {
         return this._2061023937_AppButtonBarFirstButtonSkin_GradientEntry20;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry20(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._2061023937_AppButtonBarFirstButtonSkin_GradientEntry20;
         if(_loc2_ !== param1)
         {
            this._2061023937_AppButtonBarFirstButtonSkin_GradientEntry20 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry20",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry21() : GradientEntry
      {
         return this._2061023938_AppButtonBarFirstButtonSkin_GradientEntry21;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry21(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._2061023938_AppButtonBarFirstButtonSkin_GradientEntry21;
         if(_loc2_ !== param1)
         {
            this._2061023938_AppButtonBarFirstButtonSkin_GradientEntry21 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry21",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry3() : GradientEntry
      {
         return this._1590505296_AppButtonBarFirstButtonSkin_GradientEntry3;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry3(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1590505296_AppButtonBarFirstButtonSkin_GradientEntry3;
         if(_loc2_ !== param1)
         {
            this._1590505296_AppButtonBarFirstButtonSkin_GradientEntry3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry4() : GradientEntry
      {
         return this._1590505297_AppButtonBarFirstButtonSkin_GradientEntry4;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry4(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1590505297_AppButtonBarFirstButtonSkin_GradientEntry4;
         if(_loc2_ !== param1)
         {
            this._1590505297_AppButtonBarFirstButtonSkin_GradientEntry4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry8() : GradientEntry
      {
         return this._1590505301_AppButtonBarFirstButtonSkin_GradientEntry8;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry8(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1590505301_AppButtonBarFirstButtonSkin_GradientEntry8;
         if(_loc2_ !== param1)
         {
            this._1590505301_AppButtonBarFirstButtonSkin_GradientEntry8 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry8",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_GradientEntry9() : GradientEntry
      {
         return this._1590505302_AppButtonBarFirstButtonSkin_GradientEntry9;
      }
      
      public function set _AppButtonBarFirstButtonSkin_GradientEntry9(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1590505302_AppButtonBarFirstButtonSkin_GradientEntry9;
         if(_loc2_ !== param1)
         {
            this._1590505302_AppButtonBarFirstButtonSkin_GradientEntry9 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_GradientEntry9",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_Group1() : Group
      {
         return this._1304933009_AppButtonBarFirstButtonSkin_Group1;
      }
      
      public function set _AppButtonBarFirstButtonSkin_Group1(param1:Group) : void
      {
         var _loc2_:Object = this._1304933009_AppButtonBarFirstButtonSkin_Group1;
         if(_loc2_ !== param1)
         {
            this._1304933009_AppButtonBarFirstButtonSkin_Group1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_Group1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_SetStyle1() : SetStyle
      {
         return this._710933949_AppButtonBarFirstButtonSkin_SetStyle1;
      }
      
      public function set _AppButtonBarFirstButtonSkin_SetStyle1(param1:SetStyle) : void
      {
         var _loc2_:Object = this._710933949_AppButtonBarFirstButtonSkin_SetStyle1;
         if(_loc2_ !== param1)
         {
            this._710933949_AppButtonBarFirstButtonSkin_SetStyle1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_SetStyle1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarFirstButtonSkin_SetStyle2() : SetStyle
      {
         return this._710933948_AppButtonBarFirstButtonSkin_SetStyle2;
      }
      
      public function set _AppButtonBarFirstButtonSkin_SetStyle2(param1:SetStyle) : void
      {
         var _loc2_:Object = this._710933948_AppButtonBarFirstButtonSkin_SetStyle2;
         if(_loc2_ !== param1)
         {
            this._710933948_AppButtonBarFirstButtonSkin_SetStyle2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarFirstButtonSkin_SetStyle2",_loc2_,param1));
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
