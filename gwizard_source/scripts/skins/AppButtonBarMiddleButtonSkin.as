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
   import mx.graphics.SolidColor;
   import mx.states.AddItems;
   import mx.states.SetProperty;
   import mx.states.SetStyle;
   import mx.states.State;
   import spark.components.Label;
   import spark.primitives.Rect;
   import spark.skins.SparkButtonSkin;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class AppButtonBarMiddleButtonSkin extends SparkButtonSkin implements IBindingClient, IStateClient2
   {
      
      private static const exclusions:Array = ["labelDisplay"];
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1161940117_AppButtonBarMiddleButtonSkin_GradientEntry1:GradientEntry;
      
      private var _1660405211_AppButtonBarMiddleButtonSkin_GradientEntry10:GradientEntry;
      
      private var _1660405203_AppButtonBarMiddleButtonSkin_GradientEntry18:GradientEntry;
      
      private var _1660405202_AppButtonBarMiddleButtonSkin_GradientEntry19:GradientEntry;
      
      private var _1161940116_AppButtonBarMiddleButtonSkin_GradientEntry2:GradientEntry;
      
      private var _1161940112_AppButtonBarMiddleButtonSkin_GradientEntry6:GradientEntry;
      
      private var _1161940111_AppButtonBarMiddleButtonSkin_GradientEntry7:GradientEntry;
      
      private var _1161940110_AppButtonBarMiddleButtonSkin_GradientEntry8:GradientEntry;
      
      private var _1161940109_AppButtonBarMiddleButtonSkin_GradientEntry9:GradientEntry;
      
      public var _AppButtonBarMiddleButtonSkin_Rect4:Rect;
      
      public var _AppButtonBarMiddleButtonSkin_Rect5:Rect;
      
      private var _1288036346_AppButtonBarMiddleButtonSkin_SetStyle1:SetStyle;
      
      private var _1288036345_AppButtonBarMiddleButtonSkin_SetStyle2:SetStyle;
      
      private var _118748387_AppButtonBarMiddleButtonSkin_SolidColor1:SolidColor;
      
      private var _1472494227hldownstroke1:Rect;
      
      private var _1472494228hldownstroke2:Rect;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function AppButtonBarMiddleButtonSkin()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._AppButtonBarMiddleButtonSkin_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_skins_AppButtonBarMiddleButtonSkinWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return AppButtonBarMiddleButtonSkin[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.minWidth = 21;
         this.minHeight = 21;
         this.mxmlContent = [this._AppButtonBarMiddleButtonSkin_Rect1_c(),this._AppButtonBarMiddleButtonSkin_Rect2_c(),this._AppButtonBarMiddleButtonSkin_Rect3_c(),this._AppButtonBarMiddleButtonSkin_Rect4_i(),this._AppButtonBarMiddleButtonSkin_Rect8_c(),this._AppButtonBarMiddleButtonSkin_Label1_i()];
         this.currentState = "up";
         var _AppButtonBarMiddleButtonSkin_Rect5_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AppButtonBarMiddleButtonSkin_Rect5_i);
         var _AppButtonBarMiddleButtonSkin_Rect6_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AppButtonBarMiddleButtonSkin_Rect6_i);
         var _AppButtonBarMiddleButtonSkin_Rect7_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AppButtonBarMiddleButtonSkin_Rect7_i);
         states = [new State({
            "name":"up",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect5_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            })]
         }),new State({
            "name":"over",
            "stateGroups":["overStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect5_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry8",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.22
            })]
         }),new State({
            "name":"down",
            "stateGroups":["downStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect7_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect6_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_SolidColor1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_SolidColor1",
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry19",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"disabled",
            "stateGroups":["disabledStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect5_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"upAndSelected",
            "stateGroups":["selectedStates","selectedUpStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect7_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect6_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect5_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":1118481
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry19",
               "name":"alpha",
               "value":0.85
            }),this._AppButtonBarMiddleButtonSkin_SetStyle2 = SetStyle(new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"color",
               "value":undefined
            }))]
         }),new State({
            "name":"overAndSelected",
            "stateGroups":["selectedStates","overStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect7_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect6_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect5_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"alpha",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":9342864
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"alpha",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry8",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry19",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"downAndSelected",
            "stateGroups":["selectedStates","downStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect7_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect6_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_SolidColor1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_SolidColor1",
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry19",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"disabledAndSelected",
            "stateGroups":["selectedStates","selectedUpStates","disabledStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect7_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect6_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_AppButtonBarMiddleButtonSkin_Rect5_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AppButtonBarMiddleButtonSkin_Rect4"]
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry1",
               "name":"color",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry2",
               "name":"color",
               "value":1118481
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry18",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_AppButtonBarMiddleButtonSkin_GradientEntry19",
               "name":"alpha",
               "value":0.85
            }),this._AppButtonBarMiddleButtonSkin_SetStyle1 = SetStyle(new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"color",
               "value":undefined
            }))]
         })];
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_SetStyle2",this._AppButtonBarMiddleButtonSkin_SetStyle2);
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_SetStyle1",this._AppButtonBarMiddleButtonSkin_SetStyle1);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         AppButtonBarMiddleButtonSkin._watcherSetupUtil = param1;
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
      
      private function _AppButtonBarMiddleButtonSkin_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.bottom = -1;
         _loc1_.height = 1;
         _loc1_.fill = this._AppButtonBarMiddleButtonSkin_SolidColor1_i();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         this._AppButtonBarMiddleButtonSkin_SolidColor1 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_SolidColor1",this._AppButtonBarMiddleButtonSkin_SolidColor1);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_Rect2_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._AppButtonBarMiddleButtonSkin_LinearGradient1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._AppButtonBarMiddleButtonSkin_GradientEntry1_i(),this._AppButtonBarMiddleButtonSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 1;
         this._AppButtonBarMiddleButtonSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_GradientEntry1",this._AppButtonBarMiddleButtonSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         _loc1_.alpha = 0.85;
         this._AppButtonBarMiddleButtonSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_GradientEntry2",this._AppButtonBarMiddleButtonSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_Rect3_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._AppButtonBarMiddleButtonSkin_LinearGradient2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_LinearGradient2_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 270;
         _loc1_.entries = [this._AppButtonBarMiddleButtonSkin_GradientEntry3_c(),this._AppButtonBarMiddleButtonSkin_GradientEntry4_c(),this._AppButtonBarMiddleButtonSkin_GradientEntry5_c()];
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry3_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.0327;
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry4_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.65;
         _loc1_.alpha = 0.0099;
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry5_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.85;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_Rect4_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._AppButtonBarMiddleButtonSkin_LinearGradient3_c();
         _loc1_.initialized(this,"_AppButtonBarMiddleButtonSkin_Rect4");
         this._AppButtonBarMiddleButtonSkin_Rect4 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_Rect4",this._AppButtonBarMiddleButtonSkin_Rect4);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_LinearGradient3_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._AppButtonBarMiddleButtonSkin_GradientEntry6_i(),this._AppButtonBarMiddleButtonSkin_GradientEntry7_i(),this._AppButtonBarMiddleButtonSkin_GradientEntry8_i()];
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry6_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.22;
         this._AppButtonBarMiddleButtonSkin_GradientEntry6 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_GradientEntry6",this._AppButtonBarMiddleButtonSkin_GradientEntry6);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry7_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.15;
         _loc1_.alpha = 0.22;
         this._AppButtonBarMiddleButtonSkin_GradientEntry7 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_GradientEntry7",this._AppButtonBarMiddleButtonSkin_GradientEntry7);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry8_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.45;
         _loc1_.alpha = 0;
         this._AppButtonBarMiddleButtonSkin_GradientEntry8 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_GradientEntry8",this._AppButtonBarMiddleButtonSkin_GradientEntry8);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_Rect5_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.stroke = this._AppButtonBarMiddleButtonSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,"_AppButtonBarMiddleButtonSkin_Rect5");
         this._AppButtonBarMiddleButtonSkin_Rect5 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_Rect5",this._AppButtonBarMiddleButtonSkin_Rect5);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._AppButtonBarMiddleButtonSkin_GradientEntry9_i(),this._AppButtonBarMiddleButtonSkin_GradientEntry10_i()];
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry9_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         this._AppButtonBarMiddleButtonSkin_GradientEntry9 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_GradientEntry9",this._AppButtonBarMiddleButtonSkin_GradientEntry9);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry10_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         this._AppButtonBarMiddleButtonSkin_GradientEntry10 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_GradientEntry10",this._AppButtonBarMiddleButtonSkin_GradientEntry10);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_Rect6_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.stroke = this._AppButtonBarMiddleButtonSkin_LinearGradientStroke2_c();
         _loc1_.initialized(this,"hldownstroke1");
         this.hldownstroke1 = _loc1_;
         BindingManager.executeBindings(this,"hldownstroke1",this.hldownstroke1);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_LinearGradientStroke2_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._AppButtonBarMiddleButtonSkin_GradientEntry11_c(),this._AppButtonBarMiddleButtonSkin_GradientEntry12_c(),this._AppButtonBarMiddleButtonSkin_GradientEntry13_c(),this._AppButtonBarMiddleButtonSkin_GradientEntry14_c(),this._AppButtonBarMiddleButtonSkin_GradientEntry15_c()];
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry11_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         _loc1_.ratio = 0;
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry12_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         _loc1_.ratio = 0.001;
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry13_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         _loc1_.ratio = 0.0011;
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry14_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         _loc1_.ratio = 0.965;
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry15_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         _loc1_.ratio = 0.9651;
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_Rect7_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 2;
         _loc1_.right = 2;
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.stroke = this._AppButtonBarMiddleButtonSkin_LinearGradientStroke3_c();
         _loc1_.initialized(this,"hldownstroke2");
         this.hldownstroke2 = _loc1_;
         BindingManager.executeBindings(this,"hldownstroke2",this.hldownstroke2);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_LinearGradientStroke3_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._AppButtonBarMiddleButtonSkin_GradientEntry16_c(),this._AppButtonBarMiddleButtonSkin_GradientEntry17_c()];
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry16_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.09;
         _loc1_.ratio = 0;
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry17_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         _loc1_.ratio = 0.0001;
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_Rect8_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.width = 69;
         _loc1_.height = 20;
         _loc1_.stroke = this._AppButtonBarMiddleButtonSkin_LinearGradientStroke4_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_LinearGradientStroke4_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._AppButtonBarMiddleButtonSkin_GradientEntry18_i(),this._AppButtonBarMiddleButtonSkin_GradientEntry19_i()];
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry18_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.5625;
         this._AppButtonBarMiddleButtonSkin_GradientEntry18 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_GradientEntry18",this._AppButtonBarMiddleButtonSkin_GradientEntry18);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_GradientEntry19_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.75;
         this._AppButtonBarMiddleButtonSkin_GradientEntry19 = _loc1_;
         BindingManager.executeBindings(this,"_AppButtonBarMiddleButtonSkin_GradientEntry19",this._AppButtonBarMiddleButtonSkin_GradientEntry19);
         return _loc1_;
      }
      
      private function _AppButtonBarMiddleButtonSkin_Label1_i() : Label
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
      
      private function _AppButtonBarMiddleButtonSkin_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Object
         {
            return ColorPalette.complement5;
         },null,"_AppButtonBarMiddleButtonSkin_SetStyle1.value");
         result[1] = new Binding(this,function():Object
         {
            return ColorPalette.complement5;
         },null,"_AppButtonBarMiddleButtonSkin_SetStyle2.value");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_GradientEntry1() : GradientEntry
      {
         return this._1161940117_AppButtonBarMiddleButtonSkin_GradientEntry1;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_GradientEntry1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1161940117_AppButtonBarMiddleButtonSkin_GradientEntry1;
         if(_loc2_ !== param1)
         {
            this._1161940117_AppButtonBarMiddleButtonSkin_GradientEntry1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_GradientEntry1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_GradientEntry10() : GradientEntry
      {
         return this._1660405211_AppButtonBarMiddleButtonSkin_GradientEntry10;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_GradientEntry10(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1660405211_AppButtonBarMiddleButtonSkin_GradientEntry10;
         if(_loc2_ !== param1)
         {
            this._1660405211_AppButtonBarMiddleButtonSkin_GradientEntry10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_GradientEntry10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_GradientEntry18() : GradientEntry
      {
         return this._1660405203_AppButtonBarMiddleButtonSkin_GradientEntry18;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_GradientEntry18(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1660405203_AppButtonBarMiddleButtonSkin_GradientEntry18;
         if(_loc2_ !== param1)
         {
            this._1660405203_AppButtonBarMiddleButtonSkin_GradientEntry18 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_GradientEntry18",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_GradientEntry19() : GradientEntry
      {
         return this._1660405202_AppButtonBarMiddleButtonSkin_GradientEntry19;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_GradientEntry19(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1660405202_AppButtonBarMiddleButtonSkin_GradientEntry19;
         if(_loc2_ !== param1)
         {
            this._1660405202_AppButtonBarMiddleButtonSkin_GradientEntry19 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_GradientEntry19",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_GradientEntry2() : GradientEntry
      {
         return this._1161940116_AppButtonBarMiddleButtonSkin_GradientEntry2;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_GradientEntry2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1161940116_AppButtonBarMiddleButtonSkin_GradientEntry2;
         if(_loc2_ !== param1)
         {
            this._1161940116_AppButtonBarMiddleButtonSkin_GradientEntry2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_GradientEntry2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_GradientEntry6() : GradientEntry
      {
         return this._1161940112_AppButtonBarMiddleButtonSkin_GradientEntry6;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_GradientEntry6(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1161940112_AppButtonBarMiddleButtonSkin_GradientEntry6;
         if(_loc2_ !== param1)
         {
            this._1161940112_AppButtonBarMiddleButtonSkin_GradientEntry6 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_GradientEntry6",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_GradientEntry7() : GradientEntry
      {
         return this._1161940111_AppButtonBarMiddleButtonSkin_GradientEntry7;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_GradientEntry7(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1161940111_AppButtonBarMiddleButtonSkin_GradientEntry7;
         if(_loc2_ !== param1)
         {
            this._1161940111_AppButtonBarMiddleButtonSkin_GradientEntry7 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_GradientEntry7",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_GradientEntry8() : GradientEntry
      {
         return this._1161940110_AppButtonBarMiddleButtonSkin_GradientEntry8;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_GradientEntry8(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1161940110_AppButtonBarMiddleButtonSkin_GradientEntry8;
         if(_loc2_ !== param1)
         {
            this._1161940110_AppButtonBarMiddleButtonSkin_GradientEntry8 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_GradientEntry8",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_GradientEntry9() : GradientEntry
      {
         return this._1161940109_AppButtonBarMiddleButtonSkin_GradientEntry9;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_GradientEntry9(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1161940109_AppButtonBarMiddleButtonSkin_GradientEntry9;
         if(_loc2_ !== param1)
         {
            this._1161940109_AppButtonBarMiddleButtonSkin_GradientEntry9 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_GradientEntry9",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_SetStyle1() : SetStyle
      {
         return this._1288036346_AppButtonBarMiddleButtonSkin_SetStyle1;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_SetStyle1(param1:SetStyle) : void
      {
         var _loc2_:Object = this._1288036346_AppButtonBarMiddleButtonSkin_SetStyle1;
         if(_loc2_ !== param1)
         {
            this._1288036346_AppButtonBarMiddleButtonSkin_SetStyle1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_SetStyle1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_SetStyle2() : SetStyle
      {
         return this._1288036345_AppButtonBarMiddleButtonSkin_SetStyle2;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_SetStyle2(param1:SetStyle) : void
      {
         var _loc2_:Object = this._1288036345_AppButtonBarMiddleButtonSkin_SetStyle2;
         if(_loc2_ !== param1)
         {
            this._1288036345_AppButtonBarMiddleButtonSkin_SetStyle2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_SetStyle2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AppButtonBarMiddleButtonSkin_SolidColor1() : SolidColor
      {
         return this._118748387_AppButtonBarMiddleButtonSkin_SolidColor1;
      }
      
      public function set _AppButtonBarMiddleButtonSkin_SolidColor1(param1:SolidColor) : void
      {
         var _loc2_:Object = this._118748387_AppButtonBarMiddleButtonSkin_SolidColor1;
         if(_loc2_ !== param1)
         {
            this._118748387_AppButtonBarMiddleButtonSkin_SolidColor1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AppButtonBarMiddleButtonSkin_SolidColor1",_loc2_,param1));
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
