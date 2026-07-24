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
   import mx.states.State;
   import spark.primitives.Rect;
   import spark.skins.SparkSkin;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class GWizAccordionHeaderSkin extends SparkSkin implements IBindingClient, IStateClient2
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _89469788_GWizAccordionHeaderSkin_GradientEntry1:GradientEntry;
      
      private var _89469789_GWizAccordionHeaderSkin_GradientEntry2:GradientEntry;
      
      private var _89469790_GWizAccordionHeaderSkin_GradientEntry3:GradientEntry;
      
      private var _89469791_GWizAccordionHeaderSkin_GradientEntry4:GradientEntry;
      
      public var _GWizAccordionHeaderSkin_Rect1:Rect;
      
      public var _GWizAccordionHeaderSkin_Rect2:Rect;
      
      public var _GWizAccordionHeaderSkin_Rect3:Rect;
      
      public var _GWizAccordionHeaderSkin_Rect4:Rect;
      
      public var _GWizAccordionHeaderSkin_Rect5:Rect;
      
      public var _GWizAccordionHeaderSkin_Rect6:Rect;
      
      private var _1308728327_GWizAccordionHeaderSkin_SetProperty1:SetProperty;
      
      private var _1915872521_GWizAccordionHeaderSkin_SetProperty10:SetProperty;
      
      private var _1915872522_GWizAccordionHeaderSkin_SetProperty11:SetProperty;
      
      private var _1915872523_GWizAccordionHeaderSkin_SetProperty12:SetProperty;
      
      private var _1915872524_GWizAccordionHeaderSkin_SetProperty13:SetProperty;
      
      private var _1915872525_GWizAccordionHeaderSkin_SetProperty14:SetProperty;
      
      private var _1915872526_GWizAccordionHeaderSkin_SetProperty15:SetProperty;
      
      private var _1915872527_GWizAccordionHeaderSkin_SetProperty16:SetProperty;
      
      private var _1308728328_GWizAccordionHeaderSkin_SetProperty2:SetProperty;
      
      private var _1308728329_GWizAccordionHeaderSkin_SetProperty3:SetProperty;
      
      private var _1308728330_GWizAccordionHeaderSkin_SetProperty4:SetProperty;
      
      private var _1308728331_GWizAccordionHeaderSkin_SetProperty5:SetProperty;
      
      private var _1308728332_GWizAccordionHeaderSkin_SetProperty6:SetProperty;
      
      private var _1308728333_GWizAccordionHeaderSkin_SetProperty7:SetProperty;
      
      private var _1308728334_GWizAccordionHeaderSkin_SetProperty8:SetProperty;
      
      private var _1308728335_GWizAccordionHeaderSkin_SetProperty9:SetProperty;
      
      private var _1737441588_GWizAccordionHeaderSkin_SolidColorStroke1:SolidColorStroke;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizAccordionHeaderSkin()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizAccordionHeaderSkin_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_skins_GWizAccordionHeaderSkinWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizAccordionHeaderSkin[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.minWidth = 21;
         this.minHeight = 21;
         this.mxmlContent = [this._GWizAccordionHeaderSkin_Rect1_i(),this._GWizAccordionHeaderSkin_Rect7_c()];
         this.currentState = "up";
         var _GWizAccordionHeaderSkin_Rect2_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._GWizAccordionHeaderSkin_Rect2_i);
         var _GWizAccordionHeaderSkin_Rect3_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._GWizAccordionHeaderSkin_Rect3_i);
         var _GWizAccordionHeaderSkin_Rect4_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._GWizAccordionHeaderSkin_Rect4_i);
         var _GWizAccordionHeaderSkin_Rect5_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._GWizAccordionHeaderSkin_Rect5_i);
         var _GWizAccordionHeaderSkin_Rect6_factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._GWizAccordionHeaderSkin_Rect6_i);
         states = [new State({
            "name":"up",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            })]
         }),new State({
            "name":"over",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            }),new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry3",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry4",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_SolidColorStroke1",
               "name":"alpha",
               "value":1
            })]
         }),new State({
            "name":"down",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect6_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect5_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect4_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect3_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            }),new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry1",
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry2",
               "name":"alpha",
               "value":0.3
            }),new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_SolidColorStroke1",
               "name":"alpha",
               "value":1
            })]
         }),new State({
            "name":"disabled",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            }),new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"selectedUp",
            "stateGroups":["selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            }),this._GWizAccordionHeaderSkin_SetProperty1 = SetProperty(new SetProperty().initializeFromObject({
               "isBaseValueDataBound":true,
               "target":"_GWizAccordionHeaderSkin_GradientEntry1",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty5 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry2",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty9 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry3",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty13 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry4",
               "name":"color",
               "value":undefined
            }))]
         }),new State({
            "name":"selectedOver",
            "stateGroups":["selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            }),this._GWizAccordionHeaderSkin_SetProperty2 = SetProperty(new SetProperty().initializeFromObject({
               "isBaseValueDataBound":true,
               "target":"_GWizAccordionHeaderSkin_GradientEntry1",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty6 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry2",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty10 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry3",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty14 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry4",
               "name":"color",
               "value":undefined
            }))]
         }),new State({
            "name":"selectedDown",
            "stateGroups":["selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            }),this._GWizAccordionHeaderSkin_SetProperty3 = SetProperty(new SetProperty().initializeFromObject({
               "isBaseValueDataBound":true,
               "target":"_GWizAccordionHeaderSkin_GradientEntry1",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty7 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry2",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty11 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry3",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty15 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry4",
               "name":"color",
               "value":undefined
            }))]
         }),new State({
            "name":"selectedDisabled",
            "stateGroups":["selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_GWizAccordionHeaderSkin_Rect2_factory,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_GWizAccordionHeaderSkin_Rect1"]
            }),this._GWizAccordionHeaderSkin_SetProperty4 = SetProperty(new SetProperty().initializeFromObject({
               "isBaseValueDataBound":true,
               "target":"_GWizAccordionHeaderSkin_GradientEntry1",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty8 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry2",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty12 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry3",
               "name":"color",
               "value":undefined
            })),this._GWizAccordionHeaderSkin_SetProperty16 = SetProperty(new SetProperty().initializeFromObject({
               "target":"_GWizAccordionHeaderSkin_GradientEntry4",
               "name":"color",
               "value":undefined
            }))]
         })];
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty1",this._GWizAccordionHeaderSkin_SetProperty1);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty5",this._GWizAccordionHeaderSkin_SetProperty5);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty9",this._GWizAccordionHeaderSkin_SetProperty9);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty13",this._GWizAccordionHeaderSkin_SetProperty13);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty2",this._GWizAccordionHeaderSkin_SetProperty2);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty6",this._GWizAccordionHeaderSkin_SetProperty6);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty10",this._GWizAccordionHeaderSkin_SetProperty10);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty14",this._GWizAccordionHeaderSkin_SetProperty14);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty3",this._GWizAccordionHeaderSkin_SetProperty3);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty7",this._GWizAccordionHeaderSkin_SetProperty7);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty11",this._GWizAccordionHeaderSkin_SetProperty11);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty15",this._GWizAccordionHeaderSkin_SetProperty15);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty4",this._GWizAccordionHeaderSkin_SetProperty4);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty8",this._GWizAccordionHeaderSkin_SetProperty8);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty12",this._GWizAccordionHeaderSkin_SetProperty12);
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SetProperty16",this._GWizAccordionHeaderSkin_SetProperty16);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizAccordionHeaderSkin._watcherSetupUtil = param1;
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
      
      private function _GWizAccordionHeaderSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._GWizAccordionHeaderSkin_LinearGradient1_c();
         _loc1_.initialized(this,"_GWizAccordionHeaderSkin_Rect1");
         this._GWizAccordionHeaderSkin_Rect1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_Rect1",this._GWizAccordionHeaderSkin_Rect1);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._GWizAccordionHeaderSkin_GradientEntry1_i(),this._GWizAccordionHeaderSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.alpha = 1;
         this._GWizAccordionHeaderSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_GradientEntry1",this._GWizAccordionHeaderSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 8565972;
         _loc1_.alpha = 0.8;
         this._GWizAccordionHeaderSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_GradientEntry2",this._GWizAccordionHeaderSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.stroke = this._GWizAccordionHeaderSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,"_GWizAccordionHeaderSkin_Rect2");
         this._GWizAccordionHeaderSkin_Rect2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_Rect2",this._GWizAccordionHeaderSkin_Rect2);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._GWizAccordionHeaderSkin_GradientEntry3_i(),this._GWizAccordionHeaderSkin_GradientEntry4_i()];
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_GradientEntry3_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 8565972;
         this._GWizAccordionHeaderSkin_GradientEntry3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_GradientEntry3",this._GWizAccordionHeaderSkin_GradientEntry3);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_GradientEntry4_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 5480916;
         this._GWizAccordionHeaderSkin_GradientEntry4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_GradientEntry4",this._GWizAccordionHeaderSkin_GradientEntry4);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_Rect3_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.width = 1;
         _loc1_.fill = this._GWizAccordionHeaderSkin_SolidColor1_c();
         _loc1_.initialized(this,"_GWizAccordionHeaderSkin_Rect3");
         this._GWizAccordionHeaderSkin_Rect3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_Rect3",this._GWizAccordionHeaderSkin_Rect3);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_Rect4_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.width = 1;
         _loc1_.fill = this._GWizAccordionHeaderSkin_SolidColor2_c();
         _loc1_.initialized(this,"_GWizAccordionHeaderSkin_Rect4");
         this._GWizAccordionHeaderSkin_Rect4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_Rect4",this._GWizAccordionHeaderSkin_Rect4);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_SolidColor2_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_Rect5_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.top = 1;
         _loc1_.right = 1;
         _loc1_.height = 1;
         _loc1_.fill = this._GWizAccordionHeaderSkin_SolidColor3_c();
         _loc1_.initialized(this,"_GWizAccordionHeaderSkin_Rect5");
         this._GWizAccordionHeaderSkin_Rect5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_Rect5",this._GWizAccordionHeaderSkin_Rect5);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_SolidColor3_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_Rect6_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.top = 2;
         _loc1_.right = 1;
         _loc1_.height = 1;
         _loc1_.fill = this._GWizAccordionHeaderSkin_SolidColor4_c();
         _loc1_.initialized(this,"_GWizAccordionHeaderSkin_Rect6");
         this._GWizAccordionHeaderSkin_Rect6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_Rect6",this._GWizAccordionHeaderSkin_Rect6);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_SolidColor4_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.09;
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_Rect7_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.width = 69;
         _loc1_.height = 20;
         _loc1_.stroke = this._GWizAccordionHeaderSkin_SolidColorStroke1_i();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_SolidColorStroke1_i() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 6908265;
         _loc1_.alpha = 1;
         this._GWizAccordionHeaderSkin_SolidColorStroke1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAccordionHeaderSkin_SolidColorStroke1",this._GWizAccordionHeaderSkin_SolidColorStroke1);
         return _loc1_;
      }
      
      private function _GWizAccordionHeaderSkin_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizAccordionHeaderSkin_GradientEntry1.color");
         result[1] = new Binding(this,function():*
         {
            return ColorPalette.primary3;
         },null,"_GWizAccordionHeaderSkin_SetProperty1.value");
         result[2] = new Binding(this,function():*
         {
            return ColorPalette.primary3;
         },null,"_GWizAccordionHeaderSkin_SetProperty2.value");
         result[3] = new Binding(this,function():*
         {
            return ColorPalette.primary3;
         },null,"_GWizAccordionHeaderSkin_SetProperty3.value");
         result[4] = new Binding(this,function():*
         {
            return ColorPalette.primary3;
         },null,"_GWizAccordionHeaderSkin_SetProperty4.value");
         result[5] = new Binding(this,function():*
         {
            return ColorPalette.primary3;
         },null,"_GWizAccordionHeaderSkin_SetProperty5.value");
         result[6] = new Binding(this,function():*
         {
            return ColorPalette.primary3;
         },null,"_GWizAccordionHeaderSkin_SetProperty6.value");
         result[7] = new Binding(this,function():*
         {
            return ColorPalette.primary3;
         },null,"_GWizAccordionHeaderSkin_SetProperty7.value");
         result[8] = new Binding(this,function():*
         {
            return ColorPalette.primary3;
         },null,"_GWizAccordionHeaderSkin_SetProperty8.value");
         result[9] = new Binding(this,function():*
         {
            return ColorPalette.primary2;
         },null,"_GWizAccordionHeaderSkin_SetProperty9.value");
         result[10] = new Binding(this,function():*
         {
            return ColorPalette.primary2;
         },null,"_GWizAccordionHeaderSkin_SetProperty10.value");
         result[11] = new Binding(this,function():*
         {
            return ColorPalette.primary2;
         },null,"_GWizAccordionHeaderSkin_SetProperty11.value");
         result[12] = new Binding(this,function():*
         {
            return ColorPalette.primary2;
         },null,"_GWizAccordionHeaderSkin_SetProperty12.value");
         result[13] = new Binding(this,function():*
         {
            return ColorPalette.primary1;
         },null,"_GWizAccordionHeaderSkin_SetProperty13.value");
         result[14] = new Binding(this,function():*
         {
            return ColorPalette.primary1;
         },null,"_GWizAccordionHeaderSkin_SetProperty14.value");
         result[15] = new Binding(this,function():*
         {
            return ColorPalette.primary1;
         },null,"_GWizAccordionHeaderSkin_SetProperty15.value");
         result[16] = new Binding(this,function():*
         {
            return ColorPalette.primary1;
         },null,"_GWizAccordionHeaderSkin_SetProperty16.value");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_GradientEntry1() : GradientEntry
      {
         return this._89469788_GWizAccordionHeaderSkin_GradientEntry1;
      }
      
      public function set _GWizAccordionHeaderSkin_GradientEntry1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._89469788_GWizAccordionHeaderSkin_GradientEntry1;
         if(_loc2_ !== param1)
         {
            this._89469788_GWizAccordionHeaderSkin_GradientEntry1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_GradientEntry1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_GradientEntry2() : GradientEntry
      {
         return this._89469789_GWizAccordionHeaderSkin_GradientEntry2;
      }
      
      public function set _GWizAccordionHeaderSkin_GradientEntry2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._89469789_GWizAccordionHeaderSkin_GradientEntry2;
         if(_loc2_ !== param1)
         {
            this._89469789_GWizAccordionHeaderSkin_GradientEntry2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_GradientEntry2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_GradientEntry3() : GradientEntry
      {
         return this._89469790_GWizAccordionHeaderSkin_GradientEntry3;
      }
      
      public function set _GWizAccordionHeaderSkin_GradientEntry3(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._89469790_GWizAccordionHeaderSkin_GradientEntry3;
         if(_loc2_ !== param1)
         {
            this._89469790_GWizAccordionHeaderSkin_GradientEntry3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_GradientEntry3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_GradientEntry4() : GradientEntry
      {
         return this._89469791_GWizAccordionHeaderSkin_GradientEntry4;
      }
      
      public function set _GWizAccordionHeaderSkin_GradientEntry4(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._89469791_GWizAccordionHeaderSkin_GradientEntry4;
         if(_loc2_ !== param1)
         {
            this._89469791_GWizAccordionHeaderSkin_GradientEntry4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_GradientEntry4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty1() : SetProperty
      {
         return this._1308728327_GWizAccordionHeaderSkin_SetProperty1;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty1(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1308728327_GWizAccordionHeaderSkin_SetProperty1;
         if(_loc2_ !== param1)
         {
            this._1308728327_GWizAccordionHeaderSkin_SetProperty1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty10() : SetProperty
      {
         return this._1915872521_GWizAccordionHeaderSkin_SetProperty10;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty10(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1915872521_GWizAccordionHeaderSkin_SetProperty10;
         if(_loc2_ !== param1)
         {
            this._1915872521_GWizAccordionHeaderSkin_SetProperty10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty11() : SetProperty
      {
         return this._1915872522_GWizAccordionHeaderSkin_SetProperty11;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty11(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1915872522_GWizAccordionHeaderSkin_SetProperty11;
         if(_loc2_ !== param1)
         {
            this._1915872522_GWizAccordionHeaderSkin_SetProperty11 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty11",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty12() : SetProperty
      {
         return this._1915872523_GWizAccordionHeaderSkin_SetProperty12;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty12(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1915872523_GWizAccordionHeaderSkin_SetProperty12;
         if(_loc2_ !== param1)
         {
            this._1915872523_GWizAccordionHeaderSkin_SetProperty12 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty12",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty13() : SetProperty
      {
         return this._1915872524_GWizAccordionHeaderSkin_SetProperty13;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty13(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1915872524_GWizAccordionHeaderSkin_SetProperty13;
         if(_loc2_ !== param1)
         {
            this._1915872524_GWizAccordionHeaderSkin_SetProperty13 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty13",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty14() : SetProperty
      {
         return this._1915872525_GWizAccordionHeaderSkin_SetProperty14;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty14(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1915872525_GWizAccordionHeaderSkin_SetProperty14;
         if(_loc2_ !== param1)
         {
            this._1915872525_GWizAccordionHeaderSkin_SetProperty14 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty14",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty15() : SetProperty
      {
         return this._1915872526_GWizAccordionHeaderSkin_SetProperty15;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty15(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1915872526_GWizAccordionHeaderSkin_SetProperty15;
         if(_loc2_ !== param1)
         {
            this._1915872526_GWizAccordionHeaderSkin_SetProperty15 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty15",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty16() : SetProperty
      {
         return this._1915872527_GWizAccordionHeaderSkin_SetProperty16;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty16(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1915872527_GWizAccordionHeaderSkin_SetProperty16;
         if(_loc2_ !== param1)
         {
            this._1915872527_GWizAccordionHeaderSkin_SetProperty16 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty16",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty2() : SetProperty
      {
         return this._1308728328_GWizAccordionHeaderSkin_SetProperty2;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty2(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1308728328_GWizAccordionHeaderSkin_SetProperty2;
         if(_loc2_ !== param1)
         {
            this._1308728328_GWizAccordionHeaderSkin_SetProperty2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty3() : SetProperty
      {
         return this._1308728329_GWizAccordionHeaderSkin_SetProperty3;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty3(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1308728329_GWizAccordionHeaderSkin_SetProperty3;
         if(_loc2_ !== param1)
         {
            this._1308728329_GWizAccordionHeaderSkin_SetProperty3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty4() : SetProperty
      {
         return this._1308728330_GWizAccordionHeaderSkin_SetProperty4;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty4(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1308728330_GWizAccordionHeaderSkin_SetProperty4;
         if(_loc2_ !== param1)
         {
            this._1308728330_GWizAccordionHeaderSkin_SetProperty4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty5() : SetProperty
      {
         return this._1308728331_GWizAccordionHeaderSkin_SetProperty5;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty5(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1308728331_GWizAccordionHeaderSkin_SetProperty5;
         if(_loc2_ !== param1)
         {
            this._1308728331_GWizAccordionHeaderSkin_SetProperty5 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty5",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty6() : SetProperty
      {
         return this._1308728332_GWizAccordionHeaderSkin_SetProperty6;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty6(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1308728332_GWizAccordionHeaderSkin_SetProperty6;
         if(_loc2_ !== param1)
         {
            this._1308728332_GWizAccordionHeaderSkin_SetProperty6 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty6",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty7() : SetProperty
      {
         return this._1308728333_GWizAccordionHeaderSkin_SetProperty7;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty7(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1308728333_GWizAccordionHeaderSkin_SetProperty7;
         if(_loc2_ !== param1)
         {
            this._1308728333_GWizAccordionHeaderSkin_SetProperty7 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty7",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty8() : SetProperty
      {
         return this._1308728334_GWizAccordionHeaderSkin_SetProperty8;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty8(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1308728334_GWizAccordionHeaderSkin_SetProperty8;
         if(_loc2_ !== param1)
         {
            this._1308728334_GWizAccordionHeaderSkin_SetProperty8 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty8",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SetProperty9() : SetProperty
      {
         return this._1308728335_GWizAccordionHeaderSkin_SetProperty9;
      }
      
      public function set _GWizAccordionHeaderSkin_SetProperty9(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1308728335_GWizAccordionHeaderSkin_SetProperty9;
         if(_loc2_ !== param1)
         {
            this._1308728335_GWizAccordionHeaderSkin_SetProperty9 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SetProperty9",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizAccordionHeaderSkin_SolidColorStroke1() : SolidColorStroke
      {
         return this._1737441588_GWizAccordionHeaderSkin_SolidColorStroke1;
      }
      
      public function set _GWizAccordionHeaderSkin_SolidColorStroke1(param1:SolidColorStroke) : void
      {
         var _loc2_:Object = this._1737441588_GWizAccordionHeaderSkin_SolidColorStroke1;
         if(_loc2_ !== param1)
         {
            this._1737441588_GWizAccordionHeaderSkin_SolidColorStroke1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizAccordionHeaderSkin_SolidColorStroke1",_loc2_,param1));
            }
         }
      }
   }
}
