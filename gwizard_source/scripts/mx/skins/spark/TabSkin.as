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
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import mx.states.AddItems;
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.primitives.Rect;
   import spark.skins.SparkSkin;
   
   public class TabSkin extends SparkSkin implements IStateClient2
   {
       
      
      private var _115788251_TabSkin_GradientEntry1:GradientEntry;
      
      private var _115788252_TabSkin_GradientEntry2:GradientEntry;
      
      private var _115788255_TabSkin_GradientEntry5:GradientEntry;
      
      public var _TabSkin_Rect3:Rect;
      
      public var _TabSkin_Rect4:Rect;
      
      public var _TabSkin_Rect5:Rect;
      
      public var _TabSkin_Rect6:Rect;
      
      public var _TabSkin_Rect7:Rect;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function TabSkin()
      {
         super();
         mx_internal::_document = this;
         this.minWidth = 21;
         this.minHeight = 21;
         this.mxmlContent = [this._TabSkin_Rect1_c(),this._TabSkin_Rect2_c(),this._TabSkin_Rect3_i()];
         this.currentState = "up";
         var _loc1_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._TabSkin_Rect4_i);
         var _loc2_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._TabSkin_Rect5_i);
         var _loc3_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._TabSkin_Rect6_i);
         var _loc4_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._TabSkin_Rect7_i);
         states = [new State({
            "name":"up",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            })]
         }),new State({
            "name":"over",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry1",
               "name":"color",
               "value":13290186
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry2",
               "name":"color",
               "value":8882055
            })]
         }),new State({
            "name":"down",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry5",
               "name":"alpha",
               "value":0.12
            })]
         }),new State({
            "name":"disabled",
            "stateGroups":["disabledStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"selectedUp",
            "stateGroups":["selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc4_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry2",
               "name":"color",
               "value":15000804
            })]
         }),new State({
            "name":"selectedOver",
            "stateGroups":["selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc4_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry2",
               "name":"color",
               "value":15000804
            })]
         }),new State({
            "name":"selectedDown",
            "stateGroups":["selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc4_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry2",
               "name":"color",
               "value":15000804
            })]
         }),new State({
            "name":"selectedDisabled",
            "stateGroups":["disabledStates","selectedStates"],
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc4_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_TabSkin_Rect3"]
            }),new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry1",
               "name":"color",
               "value":16777215
            }),new SetProperty().initializeFromObject({
               "target":"_TabSkin_GradientEntry2",
               "name":"color",
               "value":15000804
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
      
      private function _TabSkin_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 0;
         _loc1_.fill = this._TabSkin_LinearGradient1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _TabSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._TabSkin_GradientEntry1_i(),this._TabSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _TabSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 15000804;
         _loc1_.alpha = 1;
         this._TabSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_TabSkin_GradientEntry1",this._TabSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _TabSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 10592673;
         _loc1_.alpha = 1;
         this._TabSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_TabSkin_GradientEntry2",this._TabSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _TabSkin_Rect2_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.alpha = 0.22;
         _loc1_.stroke = this._TabSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _TabSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._TabSkin_GradientEntry3_c(),this._TabSkin_GradientEntry4_c()];
         return _loc1_;
      }
      
      private function _TabSkin_GradientEntry3_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 1;
         return _loc1_;
      }
      
      private function _TabSkin_GradientEntry4_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         _loc1_.alpha = 1;
         return _loc1_;
      }
      
      private function _TabSkin_Rect3_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._TabSkin_LinearGradient2_c();
         _loc1_.initialized(this,"_TabSkin_Rect3");
         this._TabSkin_Rect3 = _loc1_;
         BindingManager.executeBindings(this,"_TabSkin_Rect3",this._TabSkin_Rect3);
         return _loc1_;
      }
      
      private function _TabSkin_LinearGradient2_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._TabSkin_GradientEntry5_i(),this._TabSkin_GradientEntry6_c(),this._TabSkin_GradientEntry7_c()];
         return _loc1_;
      }
      
      private function _TabSkin_GradientEntry5_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.12;
         this._TabSkin_GradientEntry5 = _loc1_;
         BindingManager.executeBindings(this,"_TabSkin_GradientEntry5",this._TabSkin_GradientEntry5);
         return _loc1_;
      }
      
      private function _TabSkin_GradientEntry6_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.48;
         _loc1_.alpha = 0.12;
         return _loc1_;
      }
      
      private function _TabSkin_GradientEntry7_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.48001;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _TabSkin_Rect4_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.stroke = this._TabSkin_SolidColorStroke1_c();
         _loc1_.initialized(this,"_TabSkin_Rect4");
         this._TabSkin_Rect4 = _loc1_;
         BindingManager.executeBindings(this,"_TabSkin_Rect4",this._TabSkin_Rect4);
         return _loc1_;
      }
      
      private function _TabSkin_SolidColorStroke1_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 6908265;
         _loc1_.alpha = 1;
         return _loc1_;
      }
      
      private function _TabSkin_Rect5_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.width = 1;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._TabSkin_SolidColor1_c();
         _loc1_.initialized(this,"_TabSkin_Rect5");
         this._TabSkin_Rect5 = _loc1_;
         BindingManager.executeBindings(this,"_TabSkin_Rect5",this._TabSkin_Rect5);
         return _loc1_;
      }
      
      private function _TabSkin_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 6908265;
         _loc1_.alpha = 1;
         return _loc1_;
      }
      
      private function _TabSkin_Rect6_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 0;
         _loc1_.height = 1;
         _loc1_.fill = this._TabSkin_SolidColor2_c();
         _loc1_.initialized(this,"_TabSkin_Rect6");
         this._TabSkin_Rect6 = _loc1_;
         BindingManager.executeBindings(this,"_TabSkin_Rect6",this._TabSkin_Rect6);
         return _loc1_;
      }
      
      private function _TabSkin_SolidColor2_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 6908265;
         _loc1_.alpha = 1;
         return _loc1_;
      }
      
      private function _TabSkin_Rect7_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.width = 1;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._TabSkin_SolidColor3_c();
         _loc1_.initialized(this,"_TabSkin_Rect7");
         this._TabSkin_Rect7 = _loc1_;
         BindingManager.executeBindings(this,"_TabSkin_Rect7",this._TabSkin_Rect7);
         return _loc1_;
      }
      
      private function _TabSkin_SolidColor3_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 6908265;
         _loc1_.alpha = 1;
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get _TabSkin_GradientEntry1() : GradientEntry
      {
         return this._115788251_TabSkin_GradientEntry1;
      }
      
      public function set _TabSkin_GradientEntry1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._115788251_TabSkin_GradientEntry1;
         if(_loc2_ !== param1)
         {
            this._115788251_TabSkin_GradientEntry1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_TabSkin_GradientEntry1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _TabSkin_GradientEntry2() : GradientEntry
      {
         return this._115788252_TabSkin_GradientEntry2;
      }
      
      public function set _TabSkin_GradientEntry2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._115788252_TabSkin_GradientEntry2;
         if(_loc2_ !== param1)
         {
            this._115788252_TabSkin_GradientEntry2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_TabSkin_GradientEntry2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _TabSkin_GradientEntry5() : GradientEntry
      {
         return this._115788255_TabSkin_GradientEntry5;
      }
      
      public function set _TabSkin_GradientEntry5(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._115788255_TabSkin_GradientEntry5;
         if(_loc2_ !== param1)
         {
            this._115788255_TabSkin_GradientEntry5 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_TabSkin_GradientEntry5",_loc2_,param1));
            }
         }
      }
   }
}
