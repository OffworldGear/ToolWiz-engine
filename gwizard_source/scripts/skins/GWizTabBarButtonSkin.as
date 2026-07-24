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
   import mx.graphics.SolidColorStroke;
   import mx.states.AddItems;
   import mx.states.SetProperty;
   import mx.states.SetStyle;
   import mx.states.State;
   import spark.components.Label;
   import spark.primitives.Line;
   import spark.primitives.Path;
   import spark.primitives.Rect;
   import spark.skins.SparkButtonSkin;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class GWizTabBarButtonSkin extends SparkButtonSkin implements IBindingClient, IStateClient2
   {
      
      private static const exclusions:Array = ["labelDisplay"];
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1882566191_GWizTabBarButtonSkin_GradientEntry10:GradientEntry;
      
      private var _1030559270_GWizTabBarButtonSkin_GradientEntry6:GradientEntry;
      
      private var _1030559271_GWizTabBarButtonSkin_GradientEntry7:GradientEntry;
      
      private var _1030559272_GWizTabBarButtonSkin_GradientEntry8:GradientEntry;
      
      private var _1030559273_GWizTabBarButtonSkin_GradientEntry9:GradientEntry;
      
      private var _40493968_GWizTabBarButtonSkin_SetStyle1:SetStyle;
      
      private var _40493969_GWizTabBarButtonSkin_SetStyle2:SetStyle;
      
      private var _40493970_GWizTabBarButtonSkin_SetStyle3:SetStyle;
      
      private var _40493971_GWizTabBarButtonSkin_SetStyle4:SetStyle;
      
      public var _GWizTabBarButtonSkin_SolidColor1:SolidColor;
      
      private var _993596456_GWizTabBarButtonSkin_SolidColor2:SolidColor;
      
      private var _993596457_GWizTabBarButtonSkin_SolidColor3:SolidColor;
      
      private var _187542607_GWizTabBarButtonSkin_SolidColorStroke1:SolidColorStroke;
      
      private var _187542608_GWizTabBarButtonSkin_SolidColorStroke2:SolidColorStroke;
      
      private var _904538487borderBottom:Line;
      
      private var _197416329borderTop:Path;
      
      private var _3143043fill:Rect;
      
      private var _681210700highlight:Rect;
      
      private var _1811511742lowlight:Rect;
      
      private var _576507650selectedHighlightH1:Rect;
      
      private var _576507651selectedHighlightH2:Rect;
      
      private var _397044963selectedHighlightV:Path;
      
      private var _2053804970shading:Rect;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1309160124backColor:uint;
      
      private var cornerRadius:Number = 4;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizTabBarButtonSkin()
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
         bindings = this._GWizTabBarButtonSkin_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_skins_GWizTabBarButtonSkinWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizTabBarButtonSkin[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.minWidth = 21;
         this.minHeight = 21;
         this.mxmlContent = [this._GWizTabBarButtonSkin_Rect1_i(),this._GWizTabBarButtonSkin_Rect3_i(),this._GWizTabBarButtonSkin_Rect4_i(),this._GWizTabBarButtonSkin_Path1_i(),this._GWizTabBarButtonSkin_Rect5_i(),this._GWizTabBarButtonSkin_Rect6_i(),this._GWizTabBarButtonSkin_Path2_i(),this._GWizTabBarButtonSkin_Label1_i()];
         this.currentState = "up";
         var _GWizTabBarButtonSkin_Line1_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._GWizTabBarButtonSkin_Line1_i);
         var _GWizTabBarButtonSkin_Rect2_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._GWizTabBarButtonSkin_Rect2_i);
         states = [new State({
            "name":"up",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizTabBarButtonSkin_Line1_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["selectedHighlightH2"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_GWizTabBarButtonSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["fill"]
            })]
         }),new State({
            "name":"over",
            "stateGroups":["overStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizTabBarButtonSkin_Line1_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["selectedHighlightH2"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_GWizTabBarButtonSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["fill"]
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry8",
               "name":"alpha",
               "value":0.12
            })]
         }),new State({
            "name":"down",
            "stateGroups":["downStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizTabBarButtonSkin_Line1_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["selectedHighlightH2"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_GWizTabBarButtonSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["fill"]
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke1",
               "name":"alpha",
               "value":0.15
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColor2",
               "name":"alpha",
               "value":0.25
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColor3",
               "name":"alpha",
               "value":0.15
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke2",
               "name":"alpha",
               "value":0.85
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0.6375
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0.85
            })]
         }),new State({
            "name":"disabled",
            "stateGroups":["disabledStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizTabBarButtonSkin_Line1_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["selectedHighlightH2"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_GWizTabBarButtonSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["fill"]
            }),new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"upAndSelected",
            "stateGroups":["selectedStates","selectedUpStates"],
            "overrides":[new SetProperty().initializeFromObject({
               "target":"fill",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"shading",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"lowlight",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"highlight",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"selectedHighlightV",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke1",
               "name":"alpha",
               "value":0.15
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColor2",
               "name":"alpha",
               "value":0.25
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColor3",
               "name":"alpha",
               "value":0.15
            }),new SetProperty().initializeFromObject({
               "target":"borderBottom",
               "name":"bottom",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke2",
               "name":"color",
               "value":4408131
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke2",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"borderTop",
               "name":"bottom",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0
            }),new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"fontWeight",
               "value":"bold"
            }),this._GWizTabBarButtonSkin_SetStyle4 = SetStyle(new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"color",
               "value":undefined
            }))]
         }),new State({
            "name":"overAndSelected",
            "stateGroups":["selectedStates","overStates"],
            "overrides":[new SetProperty().initializeFromObject({
               "target":"fill",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"shading",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"lowlight",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"highlight",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.44
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry8",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"selectedHighlightV",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke1",
               "name":"alpha",
               "value":0.15
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColor2",
               "name":"alpha",
               "value":0.25
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColor3",
               "name":"alpha",
               "value":0.15
            }),new SetProperty().initializeFromObject({
               "target":"borderBottom",
               "name":"bottom",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke2",
               "name":"color",
               "value":4408131
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke2",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"borderTop",
               "name":"bottom",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0
            }),new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"fontWeight",
               "value":"bold"
            }),this._GWizTabBarButtonSkin_SetStyle3 = SetStyle(new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"color",
               "value":undefined
            }))]
         }),new State({
            "name":"downAndSelected",
            "stateGroups":["selectedStates","downStates"],
            "overrides":[new SetProperty().initializeFromObject({
               "target":"fill",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"shading",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"lowlight",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"highlight",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"selectedHighlightV",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke1",
               "name":"alpha",
               "value":0.15
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColor2",
               "name":"alpha",
               "value":0.25
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColor3",
               "name":"alpha",
               "value":0.15
            }),new SetProperty().initializeFromObject({
               "target":"borderBottom",
               "name":"bottom",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke2",
               "name":"color",
               "value":4408131
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke2",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"borderTop",
               "name":"bottom",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0
            }),new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"fontWeight",
               "value":"bold"
            }),this._GWizTabBarButtonSkin_SetStyle1 = SetStyle(new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"color",
               "value":undefined
            }))]
         }),new State({
            "name":"disabledAndSelected",
            "stateGroups":["selectedStates","selectedUpStates","disabledStates"],
            "overrides":[new SetProperty().initializeFromObject({
               "target":"fill",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"shading",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"lowlight",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"highlight",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry6",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry7",
               "name":"alpha",
               "value":0.33
            }),new SetProperty().initializeFromObject({
               "target":"selectedHighlightV",
               "name":"bottom",
               "value":1
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke1",
               "name":"alpha",
               "value":0.15
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColor2",
               "name":"alpha",
               "value":0.25
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColor3",
               "name":"alpha",
               "value":0.15
            }),new SetProperty().initializeFromObject({
               "target":"borderBottom",
               "name":"bottom",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke2",
               "name":"color",
               "value":4408131
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_SolidColorStroke2",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"borderTop",
               "name":"bottom",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry9",
               "name":"alpha",
               "value":0
            }),new SetProperty().initializeFromObject({
               "target":"_GWizTabBarButtonSkin_GradientEntry10",
               "name":"alpha",
               "value":0
            }),new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"fontWeight",
               "value":"bold"
            }),this._GWizTabBarButtonSkin_SetStyle2 = SetStyle(new SetStyle().initializeFromObject({
               "target":"labelDisplay",
               "name":"color",
               "value":undefined
            }))]
         })];
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_SetStyle4",this._GWizTabBarButtonSkin_SetStyle4);
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_SetStyle3",this._GWizTabBarButtonSkin_SetStyle3);
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_SetStyle1",this._GWizTabBarButtonSkin_SetStyle1);
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_SetStyle2",this._GWizTabBarButtonSkin_SetStyle2);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizTabBarButtonSkin._watcherSetupUtil = param1;
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
         useChromeColor = false;
         this.backColor = getStyle("chromeColor");
         super.initializationComplete();
      }
      
      private function updateBorderTop(param1:Number, param2:Number) : void
      {
         var _loc3_:String = this.createPathData(true);
         this.borderTop.data = _loc3_;
         this.borderTop.setLayoutBoundsSize(param1,param2 - 1,false);
         this.borderTop.setLayoutBoundsPosition(0,0,false);
      }
      
      private function updateSelectedHighlight(param1:Number, param2:Number) : void
      {
         if(!this.selectedHighlightV)
         {
            return;
         }
         var _loc3_:Number = 0;
         var _loc4_:Number = param1;
         var _loc5_:String = this.createPathData(false);
         this.selectedHighlightV.data = _loc5_;
         this.selectedHighlightV.setLayoutBoundsSize(param1 - 2,param2 - 2,false);
         this.selectedHighlightV.setLayoutBoundsPosition(1,1,false);
         this.selectedHighlightH1.setLayoutBoundsSize(param1 - 2 * this.cornerRadius,1,false);
         this.selectedHighlightH1.setLayoutBoundsPosition(this.cornerRadius,1,false);
         this.selectedHighlightH2.setLayoutBoundsSize(param1 - 2 * this.cornerRadius,1,false);
         this.selectedHighlightH2.setLayoutBoundsPosition(this.cornerRadius,2,false);
      }
      
      private function createPathData(param1:Boolean) : String
      {
         var _loc2_:Number = 0;
         var _loc3_:Number = width;
         var _loc4_:Number = 0.5;
         var _loc5_:Number = height;
         var _loc6_:Number = this.cornerRadius * 0.292893218813453;
         var _loc7_:Number = this.cornerRadius * 0.585786437626905;
         var _loc8_:String = (_loc8_ = (_loc8_ = (_loc8_ = (_loc8_ = "") + ("M " + _loc2_ + " " + _loc5_)) + (" L " + _loc2_ + " " + (_loc4_ + this.cornerRadius))) + (" Q " + _loc2_ + " " + (_loc4_ + _loc7_) + " " + (_loc2_ + _loc6_) + " " + (_loc4_ + _loc6_))) + (" Q " + (_loc2_ + _loc7_) + " " + _loc4_ + " " + (_loc2_ + this.cornerRadius) + " " + _loc4_);
         if(param1)
         {
            _loc8_ += " L " + (_loc3_ - this.cornerRadius) + " " + _loc4_;
         }
         else
         {
            _loc8_ += " M " + (_loc3_ - this.cornerRadius) + " " + _loc4_;
         }
         return (_loc8_ = (_loc8_ += " Q " + (_loc3_ - _loc7_) + " " + _loc4_ + " " + (_loc3_ - _loc6_) + " " + (_loc4_ + _loc6_)) + (" Q " + _loc3_ + " " + (_loc4_ + _loc7_) + " " + _loc3_ + " " + (_loc4_ + this.cornerRadius))) + (" L " + _loc3_ + " " + _loc5_);
      }
      
      private function updateCornerRadius() : void
      {
         var _loc1_:Number = getStyle("cornerRadius");
         if(this.cornerRadius != _loc1_)
         {
            this.cornerRadius = _loc1_;
            this.fill.topLeftRadiusX = this.cornerRadius;
            this.fill.topRightRadiusX = this.cornerRadius;
            this.lowlight.topLeftRadiusX = this.cornerRadius;
            this.lowlight.topRightRadiusX = this.cornerRadius;
            this.highlight.topLeftRadiusX = this.cornerRadius;
            this.highlight.topRightRadiusX = this.cornerRadius;
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         this.updateCornerRadius();
         this.updateSelectedHighlight(param1,unscaledHeight);
         this.updateBorderTop(param1,unscaledHeight);
         super.updateDisplayList(param1,unscaledHeight);
      }
      
      private function _GWizTabBarButtonSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 2;
         _loc1_.topLeftRadiusX = 4;
         _loc1_.topRightRadiusX = 4;
         _loc1_.width = 70;
         _loc1_.height = 22;
         _loc1_.fill = this._GWizTabBarButtonSkin_SolidColor1_i();
         _loc1_.initialized(this,"fill");
         this.fill = _loc1_;
         BindingManager.executeBindings(this,"fill",this.fill);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.alpha = 1;
         this._GWizTabBarButtonSkin_SolidColor1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_SolidColor1",this._GWizTabBarButtonSkin_SolidColor1);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 2;
         _loc1_.topLeftRadiusX = 4;
         _loc1_.topRightRadiusX = 4;
         _loc1_.width = 70;
         _loc1_.height = 22;
         _loc1_.fill = this._GWizTabBarButtonSkin_LinearGradient1_c();
         _loc1_.initialized(this,"shading");
         this.shading = _loc1_;
         BindingManager.executeBindings(this,"shading",this.shading);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 270;
         _loc1_.entries = [this._GWizTabBarButtonSkin_GradientEntry1_c(),this._GWizTabBarButtonSkin_GradientEntry2_c()];
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_GradientEntry1_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.2;
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_GradientEntry2_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.3;
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_Rect3_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 2;
         _loc1_.topLeftRadiusX = 4;
         _loc1_.topRightRadiusX = 4;
         _loc1_.fill = this._GWizTabBarButtonSkin_LinearGradient2_c();
         _loc1_.initialized(this,"lowlight");
         this.lowlight = _loc1_;
         BindingManager.executeBindings(this,"lowlight",this.lowlight);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_LinearGradient2_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 270;
         _loc1_.entries = [this._GWizTabBarButtonSkin_GradientEntry3_c(),this._GWizTabBarButtonSkin_GradientEntry4_c(),this._GWizTabBarButtonSkin_GradientEntry5_c()];
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_GradientEntry3_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.0327;
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_GradientEntry4_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.65;
         _loc1_.alpha = 0.0099;
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_GradientEntry5_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.85;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_Rect4_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 2;
         _loc1_.topLeftRadiusX = 4;
         _loc1_.topRightRadiusX = 4;
         _loc1_.fill = this._GWizTabBarButtonSkin_LinearGradient3_c();
         _loc1_.initialized(this,"highlight");
         this.highlight = _loc1_;
         BindingManager.executeBindings(this,"highlight",this.highlight);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_LinearGradient3_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._GWizTabBarButtonSkin_GradientEntry6_i(),this._GWizTabBarButtonSkin_GradientEntry7_i(),this._GWizTabBarButtonSkin_GradientEntry8_i()];
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_GradientEntry6_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.22;
         this._GWizTabBarButtonSkin_GradientEntry6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_GradientEntry6",this._GWizTabBarButtonSkin_GradientEntry6);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_GradientEntry7_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.15;
         _loc1_.alpha = 0.22;
         this._GWizTabBarButtonSkin_GradientEntry7 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_GradientEntry7",this._GWizTabBarButtonSkin_GradientEntry7);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_GradientEntry8_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.45;
         _loc1_.alpha = 0;
         this._GWizTabBarButtonSkin_GradientEntry8 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_GradientEntry8",this._GWizTabBarButtonSkin_GradientEntry8);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_Path1_i() : Path
      {
         var _loc1_:Path = new Path();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 2;
         _loc1_.includeInLayout = false;
         _loc1_.stroke = this._GWizTabBarButtonSkin_SolidColorStroke1_i();
         _loc1_.initialized(this,"selectedHighlightV");
         this.selectedHighlightV = _loc1_;
         BindingManager.executeBindings(this,"selectedHighlightV",this.selectedHighlightV);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_SolidColorStroke1_i() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.weight = 1;
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         this._GWizTabBarButtonSkin_SolidColorStroke1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_SolidColorStroke1",this._GWizTabBarButtonSkin_SolidColorStroke1);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_Rect5_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.top = 1;
         _loc1_.height = 1;
         _loc1_.includeInLayout = false;
         _loc1_.fill = this._GWizTabBarButtonSkin_SolidColor2_i();
         _loc1_.initialized(this,"selectedHighlightH1");
         this.selectedHighlightH1 = _loc1_;
         BindingManager.executeBindings(this,"selectedHighlightH1",this.selectedHighlightH1);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_SolidColor2_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         this._GWizTabBarButtonSkin_SolidColor2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_SolidColor2",this._GWizTabBarButtonSkin_SolidColor2);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_Rect6_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.top = 2;
         _loc1_.height = 1;
         _loc1_.includeInLayout = false;
         _loc1_.fill = this._GWizTabBarButtonSkin_SolidColor3_i();
         _loc1_.initialized(this,"selectedHighlightH2");
         this.selectedHighlightH2 = _loc1_;
         BindingManager.executeBindings(this,"selectedHighlightH2",this.selectedHighlightH2);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_SolidColor3_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0;
         this._GWizTabBarButtonSkin_SolidColor3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_SolidColor3",this._GWizTabBarButtonSkin_SolidColor3);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_Line1_i() : Line
      {
         var _loc1_:Line = new Line();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 1;
         _loc1_.stroke = this._GWizTabBarButtonSkin_SolidColorStroke2_i();
         _loc1_.initialized(this,"borderBottom");
         this.borderBottom = _loc1_;
         BindingManager.executeBindings(this,"borderBottom",this.borderBottom);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_SolidColorStroke2_i() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.weight = 1;
         _loc1_.color = 0;
         _loc1_.alpha = 0.75;
         this._GWizTabBarButtonSkin_SolidColorStroke2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_SolidColorStroke2",this._GWizTabBarButtonSkin_SolidColorStroke2);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_Path2_i() : Path
      {
         var _loc1_:Path = new Path();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 1;
         _loc1_.includeInLayout = false;
         _loc1_.stroke = this._GWizTabBarButtonSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,"borderTop");
         this.borderTop = _loc1_;
         BindingManager.executeBindings(this,"borderTop",this.borderTop);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._GWizTabBarButtonSkin_GradientEntry9_i(),this._GWizTabBarButtonSkin_GradientEntry10_i()];
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_GradientEntry9_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.5625;
         this._GWizTabBarButtonSkin_GradientEntry9 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_GradientEntry9",this._GWizTabBarButtonSkin_GradientEntry9);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_GradientEntry10_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.75;
         this._GWizTabBarButtonSkin_GradientEntry10 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTabBarButtonSkin_GradientEntry10",this._GWizTabBarButtonSkin_GradientEntry10);
         return _loc1_;
      }
      
      private function _GWizTabBarButtonSkin_Label1_i() : Label
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
      
      private function _GWizTabBarButtonSkin_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return backColor;
         },null,"_GWizTabBarButtonSkin_SolidColor1.color");
         result[1] = new Binding(this,function():Object
         {
            return ColorPalette.complement5;
         },null,"_GWizTabBarButtonSkin_SetStyle1.value");
         result[2] = new Binding(this,function():Object
         {
            return ColorPalette.complement5;
         },null,"_GWizTabBarButtonSkin_SetStyle2.value");
         result[3] = new Binding(this,function():Object
         {
            return ColorPalette.complement5;
         },null,"_GWizTabBarButtonSkin_SetStyle3.value");
         result[4] = new Binding(this,function():Object
         {
            return ColorPalette.complement5;
         },null,"_GWizTabBarButtonSkin_SetStyle4.value");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_GradientEntry10() : GradientEntry
      {
         return this._1882566191_GWizTabBarButtonSkin_GradientEntry10;
      }
      
      public function set _GWizTabBarButtonSkin_GradientEntry10(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1882566191_GWizTabBarButtonSkin_GradientEntry10;
         if(_loc2_ !== param1)
         {
            this._1882566191_GWizTabBarButtonSkin_GradientEntry10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_GradientEntry10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_GradientEntry6() : GradientEntry
      {
         return this._1030559270_GWizTabBarButtonSkin_GradientEntry6;
      }
      
      public function set _GWizTabBarButtonSkin_GradientEntry6(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1030559270_GWizTabBarButtonSkin_GradientEntry6;
         if(_loc2_ !== param1)
         {
            this._1030559270_GWizTabBarButtonSkin_GradientEntry6 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_GradientEntry6",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_GradientEntry7() : GradientEntry
      {
         return this._1030559271_GWizTabBarButtonSkin_GradientEntry7;
      }
      
      public function set _GWizTabBarButtonSkin_GradientEntry7(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1030559271_GWizTabBarButtonSkin_GradientEntry7;
         if(_loc2_ !== param1)
         {
            this._1030559271_GWizTabBarButtonSkin_GradientEntry7 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_GradientEntry7",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_GradientEntry8() : GradientEntry
      {
         return this._1030559272_GWizTabBarButtonSkin_GradientEntry8;
      }
      
      public function set _GWizTabBarButtonSkin_GradientEntry8(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1030559272_GWizTabBarButtonSkin_GradientEntry8;
         if(_loc2_ !== param1)
         {
            this._1030559272_GWizTabBarButtonSkin_GradientEntry8 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_GradientEntry8",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_GradientEntry9() : GradientEntry
      {
         return this._1030559273_GWizTabBarButtonSkin_GradientEntry9;
      }
      
      public function set _GWizTabBarButtonSkin_GradientEntry9(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1030559273_GWizTabBarButtonSkin_GradientEntry9;
         if(_loc2_ !== param1)
         {
            this._1030559273_GWizTabBarButtonSkin_GradientEntry9 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_GradientEntry9",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_SetStyle1() : SetStyle
      {
         return this._40493968_GWizTabBarButtonSkin_SetStyle1;
      }
      
      public function set _GWizTabBarButtonSkin_SetStyle1(param1:SetStyle) : void
      {
         var _loc2_:Object = this._40493968_GWizTabBarButtonSkin_SetStyle1;
         if(_loc2_ !== param1)
         {
            this._40493968_GWizTabBarButtonSkin_SetStyle1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_SetStyle1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_SetStyle2() : SetStyle
      {
         return this._40493969_GWizTabBarButtonSkin_SetStyle2;
      }
      
      public function set _GWizTabBarButtonSkin_SetStyle2(param1:SetStyle) : void
      {
         var _loc2_:Object = this._40493969_GWizTabBarButtonSkin_SetStyle2;
         if(_loc2_ !== param1)
         {
            this._40493969_GWizTabBarButtonSkin_SetStyle2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_SetStyle2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_SetStyle3() : SetStyle
      {
         return this._40493970_GWizTabBarButtonSkin_SetStyle3;
      }
      
      public function set _GWizTabBarButtonSkin_SetStyle3(param1:SetStyle) : void
      {
         var _loc2_:Object = this._40493970_GWizTabBarButtonSkin_SetStyle3;
         if(_loc2_ !== param1)
         {
            this._40493970_GWizTabBarButtonSkin_SetStyle3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_SetStyle3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_SetStyle4() : SetStyle
      {
         return this._40493971_GWizTabBarButtonSkin_SetStyle4;
      }
      
      public function set _GWizTabBarButtonSkin_SetStyle4(param1:SetStyle) : void
      {
         var _loc2_:Object = this._40493971_GWizTabBarButtonSkin_SetStyle4;
         if(_loc2_ !== param1)
         {
            this._40493971_GWizTabBarButtonSkin_SetStyle4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_SetStyle4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_SolidColor2() : SolidColor
      {
         return this._993596456_GWizTabBarButtonSkin_SolidColor2;
      }
      
      public function set _GWizTabBarButtonSkin_SolidColor2(param1:SolidColor) : void
      {
         var _loc2_:Object = this._993596456_GWizTabBarButtonSkin_SolidColor2;
         if(_loc2_ !== param1)
         {
            this._993596456_GWizTabBarButtonSkin_SolidColor2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_SolidColor2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_SolidColor3() : SolidColor
      {
         return this._993596457_GWizTabBarButtonSkin_SolidColor3;
      }
      
      public function set _GWizTabBarButtonSkin_SolidColor3(param1:SolidColor) : void
      {
         var _loc2_:Object = this._993596457_GWizTabBarButtonSkin_SolidColor3;
         if(_loc2_ !== param1)
         {
            this._993596457_GWizTabBarButtonSkin_SolidColor3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_SolidColor3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_SolidColorStroke1() : SolidColorStroke
      {
         return this._187542607_GWizTabBarButtonSkin_SolidColorStroke1;
      }
      
      public function set _GWizTabBarButtonSkin_SolidColorStroke1(param1:SolidColorStroke) : void
      {
         var _loc2_:Object = this._187542607_GWizTabBarButtonSkin_SolidColorStroke1;
         if(_loc2_ !== param1)
         {
            this._187542607_GWizTabBarButtonSkin_SolidColorStroke1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_SolidColorStroke1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizTabBarButtonSkin_SolidColorStroke2() : SolidColorStroke
      {
         return this._187542608_GWizTabBarButtonSkin_SolidColorStroke2;
      }
      
      public function set _GWizTabBarButtonSkin_SolidColorStroke2(param1:SolidColorStroke) : void
      {
         var _loc2_:Object = this._187542608_GWizTabBarButtonSkin_SolidColorStroke2;
         if(_loc2_ !== param1)
         {
            this._187542608_GWizTabBarButtonSkin_SolidColorStroke2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizTabBarButtonSkin_SolidColorStroke2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get borderBottom() : Line
      {
         return this._904538487borderBottom;
      }
      
      public function set borderBottom(param1:Line) : void
      {
         var _loc2_:Object = this._904538487borderBottom;
         if(_loc2_ !== param1)
         {
            this._904538487borderBottom = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"borderBottom",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get borderTop() : Path
      {
         return this._197416329borderTop;
      }
      
      public function set borderTop(param1:Path) : void
      {
         var _loc2_:Object = this._197416329borderTop;
         if(_loc2_ !== param1)
         {
            this._197416329borderTop = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"borderTop",_loc2_,param1));
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
      public function get selectedHighlightH1() : Rect
      {
         return this._576507650selectedHighlightH1;
      }
      
      public function set selectedHighlightH1(param1:Rect) : void
      {
         var _loc2_:Object = this._576507650selectedHighlightH1;
         if(_loc2_ !== param1)
         {
            this._576507650selectedHighlightH1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"selectedHighlightH1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get selectedHighlightH2() : Rect
      {
         return this._576507651selectedHighlightH2;
      }
      
      public function set selectedHighlightH2(param1:Rect) : void
      {
         var _loc2_:Object = this._576507651selectedHighlightH2;
         if(_loc2_ !== param1)
         {
            this._576507651selectedHighlightH2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"selectedHighlightH2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get selectedHighlightV() : Path
      {
         return this._397044963selectedHighlightV;
      }
      
      public function set selectedHighlightV(param1:Path) : void
      {
         var _loc2_:Object = this._397044963selectedHighlightV;
         if(_loc2_ !== param1)
         {
            this._397044963selectedHighlightV = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"selectedHighlightV",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get shading() : Rect
      {
         return this._2053804970shading;
      }
      
      public function set shading(param1:Rect) : void
      {
         var _loc2_:Object = this._2053804970shading;
         if(_loc2_ !== param1)
         {
            this._2053804970shading = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"shading",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get backColor() : uint
      {
         return this._1309160124backColor;
      }
      
      private function set backColor(param1:uint) : void
      {
         var _loc2_:Object = this._1309160124backColor;
         if(_loc2_ !== param1)
         {
            this._1309160124backColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backColor",_loc2_,param1));
            }
         }
      }
   }
}
