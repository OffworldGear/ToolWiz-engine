package spark.skins.spark
{
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.GradientEntry;
   import mx.graphics.LinearGradient;
   import mx.graphics.LinearGradientStroke;
   import mx.graphics.SolidColor;
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.components.Group;
   import spark.components.Label;
   import spark.layouts.VerticalLayout;
   import spark.primitives.Rect;
   import spark.skins.SparkSkin;
   
   public class WindowedApplicationSkin extends SparkSkin implements IStateClient2
   {
      
      private static const exclusions:Array = ["backgroundRect","contentGroup","statusText"];
       
      
      private var _1427077073backgroundFill:SolidColor;
      
      private var _1427430450backgroundRect:Rect;
      
      private var _809612678contentGroup:Group;
      
      private var _2070227263statusBar:Group;
      
      private var _248004671statusText:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _213507019hostComponent:Object;
      
      public function WindowedApplicationSkin()
      {
         super();
         mx_internal::_document = this;
         this.mxmlContent = [this._WindowedApplicationSkin_Rect1_i(),this._WindowedApplicationSkin_Group1_c()];
         this.currentState = "normal";
         states = [new State({
            "name":"normal",
            "overrides":[]
         }),new State({
            "name":"disabled",
            "stateGroups":["disabledGroup"],
            "overrides":[new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"normalAndInactive",
            "stateGroups":["inactiveGroup"],
            "overrides":[]
         }),new State({
            "name":"disabledAndInactive",
            "stateGroups":["inactiveGroup","disabledGroup"],
            "overrides":[new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
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
      
      override protected function initializationComplete() : void
      {
         useChromeColor = true;
         super.initializationComplete();
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         this.backgroundFill.color = getStyle("backgroundColor");
         this.backgroundFill.alpha = getStyle("backgroundAlpha");
         super.updateDisplayList(param1,param2);
      }
      
      private function _WindowedApplicationSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._WindowedApplicationSkin_SolidColor1_i();
         _loc1_.initialized(this,"backgroundRect");
         this.backgroundRect = _loc1_;
         BindingManager.executeBindings(this,"backgroundRect",this.backgroundRect);
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         this.backgroundFill = _loc1_;
         BindingManager.executeBindings(this,"backgroundFill",this.backgroundFill);
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_Group1_c() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.minHeight = 24;
         _loc1_.minWidth = 0;
         _loc1_.layout = this._WindowedApplicationSkin_VerticalLayout1_c();
         _loc1_.mxmlContent = [this._WindowedApplicationSkin_Group2_i(),this._WindowedApplicationSkin_Group3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.gap = 0;
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_Group2_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.minHeight = 0;
         _loc1_.minWidth = 0;
         _loc1_.id = "contentGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.contentGroup = _loc1_;
         BindingManager.executeBindings(this,"contentGroup",this.contentGroup);
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_Group3_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.minHeight = 24;
         _loc1_.mxmlContent = [this._WindowedApplicationSkin_Rect2_c(),this._WindowedApplicationSkin_Rect3_c(),this._WindowedApplicationSkin_Label1_i()];
         _loc1_.id = "statusBar";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.statusBar = _loc1_;
         BindingManager.executeBindings(this,"statusBar",this.statusBar);
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_Rect2_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._WindowedApplicationSkin_LinearGradient1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._WindowedApplicationSkin_GradientEntry1_c(),this._WindowedApplicationSkin_GradientEntry2_c()];
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_GradientEntry1_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14869218;
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_GradientEntry2_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14277081;
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_Rect3_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 0;
         _loc1_.stroke = this._WindowedApplicationSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._WindowedApplicationSkin_GradientEntry3_c(),this._WindowedApplicationSkin_GradientEntry4_c()];
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_GradientEntry3_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 15395562;
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_GradientEntry4_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 12500670;
         return _loc1_;
      }
      
      private function _WindowedApplicationSkin_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.top = 2;
         _loc1_.bottom = 2;
         _loc1_.left = 10;
         _loc1_.right = 10;
         _loc1_.percentWidth = 100;
         _loc1_.maxDisplayedLines = 1;
         _loc1_.setStyle("verticalAlign","middle");
         _loc1_.setStyle("fontSize",10);
         _loc1_.setStyle("color",5789784);
         _loc1_.id = "statusText";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.statusText = _loc1_;
         BindingManager.executeBindings(this,"statusText",this.statusText);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get backgroundFill() : SolidColor
      {
         return this._1427077073backgroundFill;
      }
      
      public function set backgroundFill(param1:SolidColor) : void
      {
         var _loc2_:Object = this._1427077073backgroundFill;
         if(_loc2_ !== param1)
         {
            this._1427077073backgroundFill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backgroundFill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backgroundRect() : Rect
      {
         return this._1427430450backgroundRect;
      }
      
      public function set backgroundRect(param1:Rect) : void
      {
         var _loc2_:Object = this._1427430450backgroundRect;
         if(_loc2_ !== param1)
         {
            this._1427430450backgroundRect = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backgroundRect",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contentGroup() : Group
      {
         return this._809612678contentGroup;
      }
      
      public function set contentGroup(param1:Group) : void
      {
         var _loc2_:Object = this._809612678contentGroup;
         if(_loc2_ !== param1)
         {
            this._809612678contentGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get statusBar() : Group
      {
         return this._2070227263statusBar;
      }
      
      public function set statusBar(param1:Group) : void
      {
         var _loc2_:Object = this._2070227263statusBar;
         if(_loc2_ !== param1)
         {
            this._2070227263statusBar = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"statusBar",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get statusText() : Label
      {
         return this._248004671statusText;
      }
      
      public function set statusText(param1:Label) : void
      {
         var _loc2_:Object = this._248004671statusText;
         if(_loc2_ !== param1)
         {
            this._248004671statusText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"statusText",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : Object
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:Object) : void
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
