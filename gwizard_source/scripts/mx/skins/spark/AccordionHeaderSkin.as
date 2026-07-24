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
   
   public class AccordionHeaderSkin extends SparkSkin implements IStateClient2
   {
       
      
      private var _993839355_AccordionHeaderSkin_GradientEntry1:GradientEntry;
      
      private var _744248981_AccordionHeaderSkin_GradientEntry10:GradientEntry;
      
      private var _993839356_AccordionHeaderSkin_GradientEntry2:GradientEntry;
      
      private var _993839360_AccordionHeaderSkin_GradientEntry6:GradientEntry;
      
      private var _993839361_AccordionHeaderSkin_GradientEntry7:GradientEntry;
      
      private var _993839363_AccordionHeaderSkin_GradientEntry9:GradientEntry;
      
      public var _AccordionHeaderSkin_Rect3:Rect;
      
      public var _AccordionHeaderSkin_Rect4:Rect;
      
      public var _AccordionHeaderSkin_Rect5:Rect;
      
      public var _AccordionHeaderSkin_Rect6:Rect;
      
      public var _AccordionHeaderSkin_Rect7:Rect;
      
      public var _AccordionHeaderSkin_Rect8:Rect;
      
      private var _1481364277_AccordionHeaderSkin_SolidColorStroke1:SolidColorStroke;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function AccordionHeaderSkin()
      {
         super();
         mx_internal::_document = this;
         this.minWidth = 21;
         this.minHeight = 21;
         this.mxmlContent = [this._AccordionHeaderSkin_Rect1_c(),this._AccordionHeaderSkin_Rect2_c(),this._AccordionHeaderSkin_Rect3_i(),this._AccordionHeaderSkin_Rect9_c()];
         this.currentState = "up";
         var _loc1_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AccordionHeaderSkin_Rect4_i);
         var _loc2_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AccordionHeaderSkin_Rect5_i);
         var _loc3_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AccordionHeaderSkin_Rect6_i);
         var _loc4_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AccordionHeaderSkin_Rect7_i);
         var _loc5_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._AccordionHeaderSkin_Rect8_i);
         states = [new State({
            "name":"up",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
            })]
         }),new State({
            "name":"over",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_GradientEntry1",
               "name":"color",
               "value":12303805
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_GradientEntry2",
               "name":"color",
               "value":10461345
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_GradientEntry6",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_GradientEntry7",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_GradientEntry9",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_GradientEntry10",
               "name":"alpha",
               "value":0.22
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_SolidColorStroke1",
               "name":"alpha",
               "value":1
            })]
         }),new State({
            "name":"down",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc5_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc4_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_GradientEntry1",
               "name":"color",
               "value":11184810
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_GradientEntry2",
               "name":"color",
               "value":9606294
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_GradientEntry6",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_GradientEntry7",
               "name":"alpha",
               "value":0.12
            }),new SetProperty().initializeFromObject({
               "target":"_AccordionHeaderSkin_SolidColorStroke1",
               "name":"alpha",
               "value":1
            })]
         }),new State({
            "name":"disabled",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
            }),new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"selectedUp",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
            })]
         }),new State({
            "name":"selectedOver",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
            })]
         }),new State({
            "name":"selectedDown",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
            })]
         }),new State({
            "name":"selectedDisabled",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"after",
               "relativeTo":["_AccordionHeaderSkin_Rect3"]
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
      
      private function _AccordionHeaderSkin_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._AccordionHeaderSkin_LinearGradient1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._AccordionHeaderSkin_GradientEntry1_i(),this._AccordionHeaderSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.85;
         this._AccordionHeaderSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_GradientEntry1",this._AccordionHeaderSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         _loc1_.alpha = 0.85;
         this._AccordionHeaderSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_GradientEntry2",this._AccordionHeaderSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_Rect2_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._AccordionHeaderSkin_LinearGradient2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_LinearGradient2_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 270;
         _loc1_.entries = [this._AccordionHeaderSkin_GradientEntry3_c(),this._AccordionHeaderSkin_GradientEntry4_c(),this._AccordionHeaderSkin_GradientEntry5_c()];
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_GradientEntry3_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.0627;
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_GradientEntry4_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.48;
         _loc1_.alpha = 0.0099;
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_GradientEntry5_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.ratio = 0.48001;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_Rect3_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._AccordionHeaderSkin_LinearGradient3_c();
         _loc1_.initialized(this,"_AccordionHeaderSkin_Rect3");
         this._AccordionHeaderSkin_Rect3 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_Rect3",this._AccordionHeaderSkin_Rect3);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_LinearGradient3_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._AccordionHeaderSkin_GradientEntry6_i(),this._AccordionHeaderSkin_GradientEntry7_i(),this._AccordionHeaderSkin_GradientEntry8_c()];
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_GradientEntry6_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0;
         _loc1_.alpha = 0.33;
         this._AccordionHeaderSkin_GradientEntry6 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_GradientEntry6",this._AccordionHeaderSkin_GradientEntry6);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_GradientEntry7_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.48;
         _loc1_.alpha = 0.33;
         this._AccordionHeaderSkin_GradientEntry7 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_GradientEntry7",this._AccordionHeaderSkin_GradientEntry7);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_GradientEntry8_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.ratio = 0.48001;
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_Rect4_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.stroke = this._AccordionHeaderSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,"_AccordionHeaderSkin_Rect4");
         this._AccordionHeaderSkin_Rect4 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_Rect4",this._AccordionHeaderSkin_Rect4);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._AccordionHeaderSkin_GradientEntry9_i(),this._AccordionHeaderSkin_GradientEntry10_i()];
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_GradientEntry9_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         this._AccordionHeaderSkin_GradientEntry9 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_GradientEntry9",this._AccordionHeaderSkin_GradientEntry9);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_GradientEntry10_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         this._AccordionHeaderSkin_GradientEntry10 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_GradientEntry10",this._AccordionHeaderSkin_GradientEntry10);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_Rect5_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.width = 1;
         _loc1_.fill = this._AccordionHeaderSkin_SolidColor1_c();
         _loc1_.initialized(this,"_AccordionHeaderSkin_Rect5");
         this._AccordionHeaderSkin_Rect5 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_Rect5",this._AccordionHeaderSkin_Rect5);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_Rect6_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.width = 1;
         _loc1_.fill = this._AccordionHeaderSkin_SolidColor2_c();
         _loc1_.initialized(this,"_AccordionHeaderSkin_Rect6");
         this._AccordionHeaderSkin_Rect6 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_Rect6",this._AccordionHeaderSkin_Rect6);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_SolidColor2_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.07;
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_Rect7_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.top = 1;
         _loc1_.right = 1;
         _loc1_.height = 1;
         _loc1_.fill = this._AccordionHeaderSkin_SolidColor3_c();
         _loc1_.initialized(this,"_AccordionHeaderSkin_Rect7");
         this._AccordionHeaderSkin_Rect7 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_Rect7",this._AccordionHeaderSkin_Rect7);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_SolidColor3_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.25;
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_Rect8_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.top = 2;
         _loc1_.right = 1;
         _loc1_.height = 1;
         _loc1_.fill = this._AccordionHeaderSkin_SolidColor4_c();
         _loc1_.initialized(this,"_AccordionHeaderSkin_Rect8");
         this._AccordionHeaderSkin_Rect8 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_Rect8",this._AccordionHeaderSkin_Rect8);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_SolidColor4_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.09;
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_Rect9_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.width = 69;
         _loc1_.height = 20;
         _loc1_.stroke = this._AccordionHeaderSkin_SolidColorStroke1_i();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _AccordionHeaderSkin_SolidColorStroke1_i() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 6908265;
         _loc1_.alpha = 1;
         this._AccordionHeaderSkin_SolidColorStroke1 = _loc1_;
         BindingManager.executeBindings(this,"_AccordionHeaderSkin_SolidColorStroke1",this._AccordionHeaderSkin_SolidColorStroke1);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get _AccordionHeaderSkin_GradientEntry1() : GradientEntry
      {
         return this._993839355_AccordionHeaderSkin_GradientEntry1;
      }
      
      public function set _AccordionHeaderSkin_GradientEntry1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._993839355_AccordionHeaderSkin_GradientEntry1;
         if(_loc2_ !== param1)
         {
            this._993839355_AccordionHeaderSkin_GradientEntry1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AccordionHeaderSkin_GradientEntry1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AccordionHeaderSkin_GradientEntry10() : GradientEntry
      {
         return this._744248981_AccordionHeaderSkin_GradientEntry10;
      }
      
      public function set _AccordionHeaderSkin_GradientEntry10(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._744248981_AccordionHeaderSkin_GradientEntry10;
         if(_loc2_ !== param1)
         {
            this._744248981_AccordionHeaderSkin_GradientEntry10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AccordionHeaderSkin_GradientEntry10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AccordionHeaderSkin_GradientEntry2() : GradientEntry
      {
         return this._993839356_AccordionHeaderSkin_GradientEntry2;
      }
      
      public function set _AccordionHeaderSkin_GradientEntry2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._993839356_AccordionHeaderSkin_GradientEntry2;
         if(_loc2_ !== param1)
         {
            this._993839356_AccordionHeaderSkin_GradientEntry2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AccordionHeaderSkin_GradientEntry2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AccordionHeaderSkin_GradientEntry6() : GradientEntry
      {
         return this._993839360_AccordionHeaderSkin_GradientEntry6;
      }
      
      public function set _AccordionHeaderSkin_GradientEntry6(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._993839360_AccordionHeaderSkin_GradientEntry6;
         if(_loc2_ !== param1)
         {
            this._993839360_AccordionHeaderSkin_GradientEntry6 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AccordionHeaderSkin_GradientEntry6",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AccordionHeaderSkin_GradientEntry7() : GradientEntry
      {
         return this._993839361_AccordionHeaderSkin_GradientEntry7;
      }
      
      public function set _AccordionHeaderSkin_GradientEntry7(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._993839361_AccordionHeaderSkin_GradientEntry7;
         if(_loc2_ !== param1)
         {
            this._993839361_AccordionHeaderSkin_GradientEntry7 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AccordionHeaderSkin_GradientEntry7",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AccordionHeaderSkin_GradientEntry9() : GradientEntry
      {
         return this._993839363_AccordionHeaderSkin_GradientEntry9;
      }
      
      public function set _AccordionHeaderSkin_GradientEntry9(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._993839363_AccordionHeaderSkin_GradientEntry9;
         if(_loc2_ !== param1)
         {
            this._993839363_AccordionHeaderSkin_GradientEntry9 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AccordionHeaderSkin_GradientEntry9",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _AccordionHeaderSkin_SolidColorStroke1() : SolidColorStroke
      {
         return this._1481364277_AccordionHeaderSkin_SolidColorStroke1;
      }
      
      public function set _AccordionHeaderSkin_SolidColorStroke1(param1:SolidColorStroke) : void
      {
         var _loc2_:Object = this._1481364277_AccordionHeaderSkin_SolidColorStroke1;
         if(_loc2_ !== param1)
         {
            this._1481364277_AccordionHeaderSkin_SolidColorStroke1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_AccordionHeaderSkin_SolidColorStroke1",_loc2_,param1));
            }
         }
      }
   }
}
