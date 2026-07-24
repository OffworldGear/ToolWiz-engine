package mx.charts
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.InteractiveObject;
   import flash.display.Loader;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextLineMetrics;
   import flash.utils.getDefinitionByName;
   import mx.binding.BindingManager;
   import mx.charts.chartClasses.ChartBase;
   import mx.charts.events.LegendMouseEvent;
   import mx.collections.ArrayCollection;
   import mx.collections.ICollectionView;
   import mx.collections.IList;
   import mx.collections.ListCollectionView;
   import mx.containers.utilityClasses.PostScaleAdapter;
   import mx.core.ComponentDescriptor;
   import mx.core.ContainerCreationPolicy;
   import mx.core.ContainerGlobals;
   import mx.core.EdgeMetrics;
   import mx.core.FlexGlobals;
   import mx.core.FlexSprite;
   import mx.core.FlexVersion;
   import mx.core.IChildList;
   import mx.core.IContainer;
   import mx.core.IDeferredInstantiationUIComponent;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IInvalidating;
   import mx.core.ILayoutDirectionElement;
   import mx.core.IRectangularBorder;
   import mx.core.IRepeater;
   import mx.core.IRepeaterClient;
   import mx.core.IUIComponent;
   import mx.core.IUITextField;
   import mx.core.IVisualElement;
   import mx.core.ScrollPolicy;
   import mx.core.UIComponent;
   import mx.core.UIComponentDescriptor;
   import mx.core.UIComponentGlobals;
   import mx.core.mx_internal;
   import mx.events.ChildExistenceChangedEvent;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.geom.RoundedRectangle;
   import mx.managers.ILayoutManagerClient;
   import mx.managers.ISystemManager;
   import mx.styles.CSSStyleDeclaration;
   import mx.styles.ISimpleStyleClient;
   import mx.styles.IStyleClient;
   import mx.styles.StyleProtoChain;
   
   use namespace mx_internal;
   
   public class Legend extends UIComponent implements IContainer
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const MULTIPLE_PROPERTIES:String = "<MULTIPLE>";
      
      private static var legendItemLinkage:LegendItem = null;
      
      private static var haloBorder:Class;
      
      private static var sparkBorder:Class;
      
      private static var sparkContainerBorder:Class;
      
      private static var didLookup:Boolean = false;
       
      
      protected var actualCreationPolicy:String;
      
      private var numChildrenBefore:int;
      
      public var recursionFlag:Boolean = true;
      
      private var forceLayout:Boolean = false;
      
      mx_internal var doingLayout:Boolean = false;
      
      private var changedStyles:String = null;
      
      private var _creatingContentPane:Boolean = false;
      
      protected var whiteBox:Shape;
      
      mx_internal var contentPane:Sprite = null;
      
      private var scrollPositionChanged:Boolean = true;
      
      private var horizontalScrollPositionPending:Number;
      
      private var verticalScrollPositionPending:Number;
      
      private var scrollableWidth:Number = 0;
      
      private var scrollableHeight:Number = 0;
      
      private var viewableWidth:Number = 0;
      
      private var viewableHeight:Number = 0;
      
      mx_internal var border:IFlexDisplayObject;
      
      mx_internal var blocker:Sprite;
      
      private var mouseEventReferenceCount:int = 0;
      
      private var richEditableTextClass:Class;
      
      mx_internal var cellWidth:Number;
      
      mx_internal var cellHeight:Number;
      
      private var _direction:String = "horizontal";
      
      private var _tileHeight:Number;
      
      private var _tileWidth:Number;
      
      private var _moduleFactoryInitialized:Boolean = false;
      
      private var _preferredMajorAxisLength:Number;
      
      private var _actualMajorAxisLength:Number;
      
      private var _childrenDirty:Boolean = false;
      
      private var _unscaledWidth:Number;
      
      private var _unscaledHeight:Number;
      
      private var _dataProviderChanged:Boolean = false;
      
      private var _focusPane:Sprite;
      
      mx_internal var _numChildren:int = 0;
      
      private var _dataProvider:Object;
      
      public var legendItemClass:Class;
      
      private var _autoLayout:Boolean = true;
      
      private var _childDescriptors:Array;
      
      private var _childRepeaters:Array;
      
      private var _clipContent:Boolean = true;
      
      private var _createdComponents:Array;
      
      private var _creationIndex:int = -1;
      
      private var creationPolicyNone:Boolean = false;
      
      private var _defaultButton:IFlexDisplayObject;
      
      private var _data:Object;
      
      private var _firstChildIndex:int = 0;
      
      private var _horizontalScrollPosition:Number = 0;
      
      mx_internal var _horizontalScrollPolicy:String = "auto";
      
      private var _icon:Class = null;
      
      private var _label:String = "";
      
      private var _numChildrenCreated:int = -1;
      
      private var _rawChildren:LegendRawChildrenList;
      
      private var _verticalScrollPosition:Number = 0;
      
      mx_internal var _verticalScrollPolicy:String = "auto";
      
      private var _viewMetrics:EdgeMetrics;
      
      private var _viewMetricsAndPadding:EdgeMetrics;
      
      private var _forceClippingCount:int;
      
      public function Legend()
      {
         this.legendItemClass = LegendItem;
         super();
         tabEnabled = false;
         tabFocusEnabled = false;
         showInAutomationHierarchy = false;
         if(ApplicationDomain.currentDomain.hasDefinition("spark.components.RichEditableText"))
         {
            this.richEditableTextClass = Class(ApplicationDomain.currentDomain.getDefinition("spark.components.RichEditableText"));
         }
         this.direction = "vertical";
         this.addEventListener(MouseEvent.CLICK,this.childMouseEventHandler);
         this.addEventListener(MouseEvent.MOUSE_OVER,this.childMouseEventHandler);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.childMouseEventHandler);
         this.addEventListener(MouseEvent.MOUSE_UP,this.childMouseEventHandler);
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.childMouseEventHandler);
         this._dataProvider = new ArrayCollection();
      }
      
      private static function getDefinition(param1:String) : Class
      {
         var _loc2_:Object = null;
         try
         {
            _loc2_ = getDefinitionByName(param1);
         }
         catch(e:Error)
         {
         }
         return _loc2_ as Class;
      }
      
      mx_internal function getLayoutChildAt(param1:int) : IUIComponent
      {
         return PostScaleAdapter.getCompatibleIUIComponent(this.getChildAt(param1));
      }
      
      public function get creatingContentPane() : Boolean
      {
         return this._creatingContentPane;
      }
      
      public function set creatingContentPane(param1:Boolean) : void
      {
         this._creatingContentPane = param1;
      }
      
      [Bindable("directionChanged")]
      public function get direction() : String
      {
         return this._direction;
      }
      
      public function set direction(param1:String) : void
      {
         this._direction = param1;
         invalidateSize();
         invalidateDisplayList();
         dispatchEvent(new Event("directionChanged"));
      }
      
      [Bindable("resize")]
      public function get tileHeight() : Number
      {
         return this._tileHeight;
      }
      
      public function set tileHeight(param1:Number) : void
      {
         this._tileHeight = param1;
         invalidateSize();
      }
      
      [Bindable("resize")]
      public function get tileWidth() : Number
      {
         return this._tileWidth;
      }
      
      public function set tileWidth(param1:Number) : void
      {
         this._tileWidth = param1;
         invalidateSize();
      }
      
      override public function get baselinePosition() : Number
      {
         if(!validateBaselinePosition())
         {
            return NaN;
         }
         var _loc1_:TextLineMetrics = measureText("Wj");
         if(height < 2 * this.viewMetrics.top + 4 + _loc1_.ascent)
         {
            return int(height + (_loc1_.ascent - height) / 2);
         }
         return this.viewMetrics.top + 2 + _loc1_.ascent;
      }
      
      override public function get contentMouseX() : Number
      {
         if(this.contentPane)
         {
            return this.contentPane.mouseX;
         }
         return super.contentMouseX;
      }
      
      override public function get contentMouseY() : Number
      {
         if(this.contentPane)
         {
            return this.contentPane.mouseY;
         }
         return super.contentMouseY;
      }
      
      override public function set doubleClickEnabled(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:InteractiveObject = null;
         super.doubleClickEnabled = param1;
         if(this.contentPane)
         {
            _loc2_ = this.contentPane.numChildren;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(_loc4_ = this.contentPane.getChildAt(_loc3_) as InteractiveObject)
               {
                  _loc4_.doubleClickEnabled = param1;
               }
               _loc3_++;
            }
         }
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         invalidateProperties();
         if(this.border && this.border is IInvalidating)
         {
            IInvalidating(this.border).invalidateDisplayList();
         }
      }
      
      override public function get focusPane() : Sprite
      {
         return this._focusPane;
      }
      
      override public function set focusPane(param1:Sprite) : void
      {
         var _loc2_:Boolean = mx_internal::invalidateSizeFlag;
         var _loc3_:Boolean = mx_internal::invalidateDisplayListFlag;
         invalidateSizeFlag = true;
         invalidateDisplayListFlag = true;
         if(param1)
         {
            this.rawChildren.addChild(param1);
            param1.x = 0;
            param1.y = 0;
            param1.scrollRect = null;
            this._focusPane = param1;
         }
         else
         {
            this.rawChildren.removeChild(this._focusPane);
            this._focusPane = null;
         }
         if(param1 && this.contentPane)
         {
            param1.x = this.contentPane.x;
            param1.y = this.contentPane.y;
            param1.scrollRect = this.contentPane.scrollRect;
         }
         invalidateSizeFlag = _loc2_;
         invalidateDisplayListFlag = _loc3_;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         styleManager.registerInheritingStyle("_creationPolicy");
      }
      
      mx_internal final function get $numChildren() : int
      {
         return super.numChildren;
      }
      
      override public function get numChildren() : int
      {
         return !!this.contentPane ? int(this.contentPane.numChildren) : int(this._numChildren);
      }
      
      [Bindable("collectionChange")]
      public function get dataProvider() : Object
      {
         return this._dataProvider;
      }
      
      public function set dataProvider(param1:Object) : void
      {
         if(this._dataProvider is ChartBase)
         {
            this._dataProvider.removeEventListener("legendDataChanged",this.legendDataChangedHandler);
         }
         this._dataProvider = !!param1 ? param1 : [];
         if(this._dataProvider is ChartBase)
         {
            this._dataProvider.addEventListener("legendDataChanged",this.legendDataChangedHandler,false,0,true);
         }
         else if(!(this._dataProvider is ICollectionView))
         {
            if(this._dataProvider is IList)
            {
               this._dataProvider = new ListCollectionView(IList(this._dataProvider));
            }
            else if(this._dataProvider is Array)
            {
               this._dataProvider = new ArrayCollection(this._dataProvider as Array);
            }
            else if(this._dataProvider != null)
            {
               this._dataProvider = new ArrayCollection([this._dataProvider]);
            }
            else
            {
               this._dataProvider = new ArrayCollection();
            }
         }
         invalidateProperties();
         invalidateSize();
         this._childrenDirty = true;
         dispatchEvent(new Event("collectionChange"));
      }
      
      public function get autoLayout() : Boolean
      {
         return this._autoLayout;
      }
      
      public function set autoLayout(param1:Boolean) : void
      {
         var _loc2_:IInvalidating = null;
         this._autoLayout = param1;
         if(param1)
         {
            invalidateSize();
            invalidateDisplayList();
            _loc2_ = parent as IInvalidating;
            if(_loc2_)
            {
               _loc2_.invalidateSize();
               _loc2_.invalidateDisplayList();
            }
         }
      }
      
      public function get borderMetrics() : EdgeMetrics
      {
         return this.border && this.border is IRectangularBorder ? IRectangularBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
      }
      
      public function get childDescriptors() : Array
      {
         return this._childDescriptors;
      }
      
      public function set childDescriptors(param1:Array) : void
      {
         this._childDescriptors = param1;
      }
      
      mx_internal function get childRepeaters() : Array
      {
         return this._childRepeaters;
      }
      
      mx_internal function set childRepeaters(param1:Array) : void
      {
         this._childRepeaters = param1;
      }
      
      public function get clipContent() : Boolean
      {
         return this._clipContent;
      }
      
      public function set clipContent(param1:Boolean) : void
      {
         if(this._clipContent != param1)
         {
            this._clipContent = param1;
            invalidateDisplayList();
         }
      }
      
      mx_internal function get createdComponents() : Array
      {
         return this._createdComponents;
      }
      
      mx_internal function set createdComponents(param1:Array) : void
      {
         this._createdComponents = param1;
      }
      
      public function get creationIndex() : int
      {
         return this._creationIndex;
      }
      
      public function set creationIndex(param1:int) : void
      {
         this._creationIndex = param1;
      }
      
      public function get creationPolicy() : String
      {
         if(this.creationPolicyNone)
         {
            return ContainerCreationPolicy.NONE;
         }
         return getStyle("_creationPolicy");
      }
      
      public function set creationPolicy(param1:String) : void
      {
         var _loc2_:String = param1;
         if(param1 == ContainerCreationPolicy.NONE)
         {
            this.creationPolicyNone = true;
            _loc2_ = ContainerCreationPolicy.AUTO;
         }
         else
         {
            this.creationPolicyNone = false;
         }
         setStyle("_creationPolicy",_loc2_);
         this.setActualCreationPolicies(param1);
      }
      
      public function get defaultButton() : IFlexDisplayObject
      {
         return this._defaultButton;
      }
      
      public function set defaultButton(param1:IFlexDisplayObject) : void
      {
         this._defaultButton = param1;
         ContainerGlobals.focusedContainer = null;
      }
      
      public function get deferredContentCreated() : Boolean
      {
         return processedDescriptors;
      }
      
      [Bindable("dataChange")]
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
         invalidateDisplayList();
      }
      
      mx_internal function get firstChildIndex() : int
      {
         return this._firstChildIndex;
      }
      
      [Bindable("viewChanged")]
      [Bindable("scroll")]
      public function get horizontalScrollPosition() : Number
      {
         if(!isNaN(this.horizontalScrollPositionPending))
         {
            return this.horizontalScrollPositionPending;
         }
         return this._horizontalScrollPosition;
      }
      
      public function set horizontalScrollPosition(param1:Number) : void
      {
         if(this._horizontalScrollPosition == param1)
         {
            return;
         }
         this._horizontalScrollPosition = param1;
         this.scrollPositionChanged = true;
         if(!initialized)
         {
            this.horizontalScrollPositionPending = param1;
         }
         invalidateDisplayList();
         dispatchEvent(new Event("viewChanged"));
      }
      
      [Bindable("horizontalScrollPolicyChanged")]
      public function get horizontalScrollPolicy() : String
      {
         return ScrollPolicy.OFF;
      }
      
      public function set horizontalScrollPolicy(param1:String) : void
      {
      }
      
      [Bindable("iconChanged")]
      public function get icon() : Class
      {
         return this._icon;
      }
      
      public function set icon(param1:Class) : void
      {
         this._icon = param1;
         dispatchEvent(new Event("iconChanged"));
      }
      
      [Bindable("labelChanged")]
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         dispatchEvent(new Event("labelChanged"));
      }
      
      public function get maxHorizontalScrollPosition() : Number
      {
         return Math.max(this.scrollableWidth - this.viewableWidth,0);
      }
      
      public function get maxVerticalScrollPosition() : Number
      {
         return Math.max(this.scrollableHeight - this.viewableHeight,0);
      }
      
      mx_internal function get numChildrenCreated() : int
      {
         return this._numChildrenCreated;
      }
      
      mx_internal function set numChildrenCreated(param1:int) : void
      {
         this._numChildrenCreated = param1;
      }
      
      mx_internal function get numRepeaters() : int
      {
         return !!this.childRepeaters ? int(this.childRepeaters.length) : 0;
      }
      
      public function get rawChildren() : IChildList
      {
         if(!this._rawChildren)
         {
            this._rawChildren = new LegendRawChildrenList(this);
         }
         return this._rawChildren;
      }
      
      mx_internal function get usePadding() : Boolean
      {
         return true;
      }
      
      [Bindable("viewChanged")]
      [Bindable("scroll")]
      public function get verticalScrollPosition() : Number
      {
         if(!isNaN(this.verticalScrollPositionPending))
         {
            return this.verticalScrollPositionPending;
         }
         return this._verticalScrollPosition;
      }
      
      public function set verticalScrollPosition(param1:Number) : void
      {
         if(this._verticalScrollPosition == param1)
         {
            return;
         }
         this._verticalScrollPosition = param1;
         this.scrollPositionChanged = true;
         if(!initialized)
         {
            this.verticalScrollPositionPending = param1;
         }
         invalidateDisplayList();
         dispatchEvent(new Event("viewChanged"));
      }
      
      [Bindable("verticalScrollPolicyChanged")]
      public function get verticalScrollPolicy() : String
      {
         return ScrollPolicy.OFF;
      }
      
      public function set verticalScrollPolicy(param1:String) : void
      {
      }
      
      public function get viewMetrics() : EdgeMetrics
      {
         var _loc1_:EdgeMetrics = this.borderMetrics;
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         if(!_loc2_ && !_loc3_)
         {
            return _loc1_;
         }
         if(!this._viewMetrics)
         {
            this._viewMetrics = _loc1_.clone();
         }
         else
         {
            this._viewMetrics.left = _loc1_.left;
            this._viewMetrics.right = _loc1_.right;
            this._viewMetrics.top = _loc1_.top;
            this._viewMetrics.bottom = _loc1_.bottom;
         }
         if(_loc2_)
         {
            this._viewMetrics.right;
         }
         if(_loc3_)
         {
            this._viewMetrics.bottom;
         }
         return this._viewMetrics;
      }
      
      public function get viewMetricsAndPadding() : EdgeMetrics
      {
         if(this._viewMetricsAndPadding && this.horizontalScrollPolicy == ScrollPolicy.ON && this.verticalScrollPolicy == ScrollPolicy.ON)
         {
            return this._viewMetricsAndPadding;
         }
         if(!this._viewMetricsAndPadding)
         {
            this._viewMetricsAndPadding = new EdgeMetrics();
         }
         var _loc1_:EdgeMetrics = this._viewMetricsAndPadding;
         var _loc2_:EdgeMetrics = this.viewMetrics;
         _loc1_.left = _loc2_.left + getStyle("paddingLeft");
         _loc1_.right = _loc2_.right + getStyle("paddingRight");
         _loc1_.top = _loc2_.top + getStyle("paddingTop");
         _loc1_.bottom = _loc2_.bottom + getStyle("paddingBottom");
         return _loc1_;
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         super.addEventListener(param1,param2,param3,param4,param5);
         if(param1 == MouseEvent.CLICK || param1 == MouseEvent.DOUBLE_CLICK || param1 == MouseEvent.MOUSE_DOWN || param1 == MouseEvent.MOUSE_MOVE || param1 == MouseEvent.MOUSE_OVER || param1 == MouseEvent.MOUSE_OUT || param1 == MouseEvent.MOUSE_UP || param1 == MouseEvent.MOUSE_WHEEL)
         {
            if(this.mouseEventReferenceCount < 2147483647 && this.mouseEventReferenceCount++ == 0)
            {
               setStyle("mouseShield",true);
               setStyle("mouseShieldChildren",true);
            }
         }
      }
      
      mx_internal function $addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         super.addEventListener(param1,param2,param3,param4,param5);
      }
      
      override public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         super.removeEventListener(param1,param2,param3);
         if(param1 == MouseEvent.CLICK || param1 == MouseEvent.DOUBLE_CLICK || param1 == MouseEvent.MOUSE_DOWN || param1 == MouseEvent.MOUSE_MOVE || param1 == MouseEvent.MOUSE_OVER || param1 == MouseEvent.MOUSE_OUT || param1 == MouseEvent.MOUSE_UP || param1 == MouseEvent.MOUSE_WHEEL)
         {
            if(this.mouseEventReferenceCount > 0 && --this.mouseEventReferenceCount == 0)
            {
               setStyle("mouseShield",false);
               setStyle("mouseShieldChildren",false);
            }
         }
      }
      
      mx_internal function $removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         super.removeEventListener(param1,param2,param3);
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         return this.addChildAt(param1,this.numChildren);
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         var _loc3_:DisplayObjectContainer = param1.parent;
         if(_loc3_ && !(_loc3_ is Loader))
         {
            if(_loc3_ == this)
            {
               param2 = param2 == this.numChildren ? int(param2 - 1) : int(param2);
            }
            _loc3_.removeChild(param1);
         }
         this.addingChild(param1);
         if(this.contentPane)
         {
            this.contentPane.addChildAt(param1,param2);
         }
         else
         {
            $addChildAt(param1,this._firstChildIndex + param2);
         }
         this.childAdded(param1);
         if(param1 is UIComponent && UIComponent(param1).isDocument)
         {
            BindingManager.setEnabled(param1,true);
         }
         return param1;
      }
      
      override public function removeChild(param1:DisplayObject) : DisplayObject
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 is IDeferredInstantiationUIComponent && IDeferredInstantiationUIComponent(param1).descriptor)
         {
            if(this.createdComponents)
            {
               _loc2_ = this.createdComponents.length;
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  if(this.createdComponents[_loc3_] === param1)
                  {
                     this.createdComponents.splice(_loc3_,1);
                  }
                  _loc3_++;
               }
            }
         }
         this.removingChild(param1);
         if(param1 is UIComponent && UIComponent(param1).isDocument)
         {
            BindingManager.setEnabled(param1,false);
         }
         if(this.contentPane)
         {
            this.contentPane.removeChild(param1);
         }
         else
         {
            $removeChild(param1);
         }
         this.childRemoved(param1);
         return param1;
      }
      
      override public function removeChildAt(param1:int) : DisplayObject
      {
         return this.removeChild(this.getChildAt(param1));
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         if(this.contentPane)
         {
            return this.contentPane.getChildAt(param1);
         }
         return super.getChildAt(this._firstChildIndex + param1);
      }
      
      override public function getChildByName(param1:String) : DisplayObject
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:int = 0;
         if(this.contentPane)
         {
            return this.contentPane.getChildByName(param1);
         }
         _loc2_ = super.getChildByName(param1);
         if(!_loc2_)
         {
            return null;
         }
         _loc3_ = super.getChildIndex(_loc2_) - this._firstChildIndex;
         if(_loc3_ < 0 || _loc3_ >= this._numChildren)
         {
            return null;
         }
         return _loc2_;
      }
      
      override public function getChildIndex(param1:DisplayObject) : int
      {
         var _loc2_:int = 0;
         if(this.contentPane)
         {
            return this.contentPane.getChildIndex(param1);
         }
         return int(super.getChildIndex(param1) - this._firstChildIndex);
      }
      
      override public function setChildIndex(param1:DisplayObject, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = _loc3_;
         var _loc5_:int = param2;
         if(this.contentPane)
         {
            this.contentPane.setChildIndex(param1,param2);
            if(this._autoLayout || this.forceLayout)
            {
               invalidateDisplayList();
            }
         }
         else
         {
            _loc3_ = super.getChildIndex(param1);
            param2 += this._firstChildIndex;
            if(param2 == _loc3_)
            {
               return;
            }
            super.setChildIndex(param1,param2);
            invalidateDisplayList();
            _loc4_ = _loc3_ - this._firstChildIndex;
            _loc5_ = param2 - this._firstChildIndex;
         }
         var _loc6_:IndexChangedEvent;
         (_loc6_ = new IndexChangedEvent(IndexChangedEvent.CHILD_INDEX_CHANGE)).relatedObject = param1;
         _loc6_.oldIndex = _loc4_;
         _loc6_.newIndex = _loc5_;
         dispatchEvent(_loc6_);
         dispatchEvent(new Event("childrenChanged"));
      }
      
      override public function contains(param1:DisplayObject) : Boolean
      {
         if(this.contentPane)
         {
            return this.contentPane.contains(param1);
         }
         return super.contains(param1);
      }
      
      public function get numElements() : int
      {
         return this.numChildren;
      }
      
      public function getElementAt(param1:int) : IVisualElement
      {
         return this.getChildAt(param1) as IVisualElement;
      }
      
      public function getElementIndex(param1:IVisualElement) : int
      {
         if(!(param1 is DisplayObject))
         {
            throw ArgumentError(param1 + " is not found in this Container");
         }
         return this.getChildIndex(param1 as DisplayObject);
      }
      
      public function addElement(param1:IVisualElement) : IVisualElement
      {
         if(!(param1 is DisplayObject))
         {
            throw ArgumentError(param1 + " is not supported in this Container");
         }
         return this.addChild(param1 as DisplayObject) as IVisualElement;
      }
      
      public function addElementAt(param1:IVisualElement, param2:int) : IVisualElement
      {
         if(!(param1 is DisplayObject))
         {
            throw ArgumentError(param1 + " is not supported in this Container");
         }
         return this.addChildAt(param1 as DisplayObject,param2) as IVisualElement;
      }
      
      public function removeElement(param1:IVisualElement) : IVisualElement
      {
         if(!(param1 is DisplayObject))
         {
            throw ArgumentError(param1 + " is not found in this Container");
         }
         return this.removeChild(param1 as DisplayObject) as IVisualElement;
      }
      
      public function removeElementAt(param1:int) : IVisualElement
      {
         return this.removeChildAt(param1) as IVisualElement;
      }
      
      public function removeAllElements() : void
      {
         var _loc1_:int = this.numElements - 1;
         while(_loc1_ >= 0)
         {
            this.removeElementAt(_loc1_);
            _loc1_--;
         }
      }
      
      public function setElementIndex(param1:IVisualElement, param2:int) : void
      {
         if(!(param1 is DisplayObject))
         {
            throw ArgumentError(param1 + " is not found in this Container");
         }
         return this.setChildIndex(param1 as DisplayObject,param2);
      }
      
      public function swapElements(param1:IVisualElement, param2:IVisualElement) : void
      {
         if(!(param1 is DisplayObject))
         {
            throw ArgumentError(param1 + " is not found in this Container");
         }
         if(!(param2 is DisplayObject))
         {
            throw ArgumentError(param2 + " is not found in this Container");
         }
         swapChildren(param1 as DisplayObject,param2 as DisplayObject);
      }
      
      public function swapElementsAt(param1:int, param2:int) : void
      {
         swapChildrenAt(param1,param2);
      }
      
      override public function initialize() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:String = null;
         if(mx_internal::documentDescriptor && !processedDescriptors)
         {
            _loc1_ = mx_internal::documentDescriptor.properties;
            if(_loc1_ && _loc1_.childDescriptors)
            {
               if(this._childDescriptors)
               {
                  _loc2_ = resourceManager.getString("core","multipleChildSets_ClassAndInstance");
                  throw new Error(_loc2_);
               }
               this._childDescriptors = _loc1_.childDescriptors;
            }
         }
         super.initialize();
      }
      
      override protected function createChildren() : void
      {
         var _loc1_:* = undefined;
         super.createChildren();
         this.createBorder();
         if(this.actualCreationPolicy == null)
         {
            if(this.creationPolicy != null)
            {
               this.actualCreationPolicy = this.creationPolicy;
            }
            if(this.actualCreationPolicy == ContainerCreationPolicy.QUEUED)
            {
               this.actualCreationPolicy = ContainerCreationPolicy.AUTO;
            }
         }
         if(this.actualCreationPolicy == ContainerCreationPolicy.NONE)
         {
            this.actualCreationPolicy = ContainerCreationPolicy.AUTO;
         }
         else if(this.actualCreationPolicy == ContainerCreationPolicy.QUEUED)
         {
            _loc1_ = !!parentApplication ? parentApplication : FlexGlobals.topLevelApplication;
            if("addToCreationQueue" in _loc1_)
            {
               _loc1_.addToCreationQueue(this,this._creationIndex,null,this);
            }
            else
            {
               this.createComponentsFromDescriptors();
            }
         }
         else if(this.recursionFlag)
         {
            this.createComponentsFromDescriptors();
         }
         if(this.autoLayout == false)
         {
            this.forceLayout = true;
         }
         UIComponentGlobals.layoutManager.addEventListener(FlexEvent.UPDATE_COMPLETE,this.layoutCompleteHandler,false,0,true);
      }
      
      override protected function initializationComplete() : void
      {
      }
      
      override public function invalidateLayoutDirection() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:DisplayObject = null;
         super.invalidateLayoutDirection();
         if(this._rawChildren)
         {
            _loc1_ = this._rawChildren.numChildren;
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               _loc3_ = this._rawChildren.getChildAt(_loc2_);
               if(!(_loc3_ is IStyleClient) && _loc3_ is ILayoutDirectionElement)
               {
                  ILayoutDirectionElement(_loc3_).invalidateLayoutDirection();
               }
               _loc2_++;
            }
         }
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:String = null;
         super.commitProperties();
         if(this.changedStyles)
         {
            _loc1_ = this.changedStyles == MULTIPLE_PROPERTIES ? null : this.changedStyles;
            super.notifyStyleChangeInChildren(_loc1_,true);
            this.changedStyles = null;
         }
         this.createOrDestroyBlocker();
         if(this._childrenDirty)
         {
            this.populateFromArray(this._dataProvider);
            this._childrenDirty = false;
         }
      }
      
      override public function validateSize(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:DisplayObject = null;
         if(this.autoLayout == false && this.forceLayout == false)
         {
            if(param1)
            {
               _loc2_ = super.numChildren;
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  if((_loc4_ = super.getChildAt(_loc3_)) is ILayoutManagerClient)
                  {
                     ILayoutManagerClient(_loc4_).validateSize(true);
                  }
                  _loc3_++;
               }
            }
            adjustSizesForScaleChanges();
         }
         else
         {
            super.validateSize(param1);
         }
      }
      
      override public function validateDisplayList() : void
      {
         var _loc1_:EdgeMetrics = null;
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(this._autoLayout || this.forceLayout)
         {
            this.doingLayout = true;
            super.validateDisplayList();
            this.doingLayout = false;
         }
         else
         {
            this.layoutChrome(unscaledWidth,unscaledHeight);
         }
         invalidateDisplayListFlag = true;
         if(this.createContentPaneAndScrollbarsIfNeeded())
         {
            if(this._autoLayout || this.forceLayout)
            {
               this.doingLayout = true;
               super.validateDisplayList();
               this.doingLayout = false;
            }
            this.createContentPaneAndScrollbarsIfNeeded();
         }
         if(this.clampScrollPositions())
         {
            this.scrollChildren();
         }
         if(this.contentPane)
         {
            _loc1_ = this.viewMetrics;
            if(mx_internal::effectOverlay)
            {
               mx_internal::effectOverlay.x = 0;
               mx_internal::effectOverlay.y = 0;
               mx_internal::effectOverlay.width = unscaledWidth;
               mx_internal::effectOverlay.height = unscaledHeight;
            }
            this.contentPane.x = _loc1_.left;
            this.contentPane.y = _loc1_.top;
            if(this.focusPane)
            {
               this.focusPane.x = _loc1_.left;
               this.focusPane.y = _loc1_.top;
            }
            this.scrollChildren();
         }
         invalidateDisplayListFlag = false;
         if(this.blocker)
         {
            _loc1_ = this.viewMetrics;
            if(FlexVersion.compatibilityVersion >= FlexVersion.VERSION_4_0)
            {
               _loc1_ = EdgeMetrics.EMPTY;
            }
            _loc2_ = !!enabled ? null : getStyle("backgroundDisabledColor");
            if(_loc2_ === null || isNaN(Number(_loc2_)))
            {
               _loc2_ = getStyle("backgroundColor");
            }
            if(_loc2_ === null || isNaN(Number(_loc2_)))
            {
               _loc2_ = 16777215;
            }
            _loc3_ = getStyle("disabledOverlayAlpha");
            if(isNaN(_loc3_))
            {
               _loc3_ = 0.6;
            }
            this.blocker.x = _loc1_.left;
            this.blocker.y = _loc1_.top;
            _loc4_ = unscaledWidth - (_loc1_.left + _loc1_.right);
            _loc5_ = unscaledHeight - (_loc1_.top + _loc1_.bottom);
            this.blocker.graphics.clear();
            this.blocker.graphics.beginFill(uint(_loc2_),_loc3_);
            this.blocker.graphics.drawRect(0,0,_loc4_,_loc5_);
            this.blocker.graphics.endFill();
            this.rawChildren.setChildIndex(this.blocker,this.rawChildren.numChildren - 1);
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc15_:int = 0;
         var _loc16_:IUIComponent = null;
         var _loc17_:Object = null;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         super.updateDisplayList(param1,param2);
         this.layoutChrome(param1,param2);
         if(this.scrollPositionChanged)
         {
            this.clampScrollPositions();
            this.scrollChildren();
            this.scrollPositionChanged = false;
         }
         if(this.contentPane && this.contentPane.scrollRect)
         {
            if((_loc17_ = !!enabled ? null : getStyle("backgroundDisabledColor")) === null || isNaN(Number(_loc17_)))
            {
               _loc17_ = getStyle("backgroundColor");
            }
            _loc18_ = getStyle("backgroundAlpha");
            if(!this._clipContent || isNaN(Number(_loc17_)) || _loc17_ === "" || !cacheAsBitmap)
            {
               _loc17_ = null;
            }
            else if(getStyle("backgroundImage") || getStyle("background"))
            {
               _loc17_ = null;
            }
            else if(_loc18_ != 1)
            {
               _loc17_ = null;
            }
            this.contentPane.opaqueBackground = _loc17_;
            this.contentPane.cacheAsBitmap = _loc17_ != null;
         }
         if(isNaN(this.cellWidth) || isNaN(this.cellHeight))
         {
            this.findCellSize();
         }
         var _loc3_:EdgeMetrics = this.viewMetricsAndPadding;
         var _loc4_:Number = getStyle("paddingLeft");
         var _loc5_:Number = getStyle("paddingTop");
         var _loc6_:Number = getStyle("horizontalGap");
         var _loc7_:Number = getStyle("verticalGap");
         var _loc8_:String = getStyle("horizontalAlign");
         var _loc9_:String = getStyle("verticalAlign");
         var _loc10_:Number = _loc4_;
         var _loc11_:Number = _loc5_;
         var _loc14_:int = this.numChildren;
         if(this.direction == "horizontal")
         {
            _loc19_ = Math.ceil(param1) - _loc3_.right;
            _loc15_ = 0;
            while(_loc15_ < _loc14_)
            {
               if((_loc16_ = this.getLayoutChildAt(_loc15_)).includeInLayout)
               {
                  if(_loc10_ + this.cellWidth > _loc19_)
                  {
                     if(_loc10_ != _loc4_)
                     {
                        _loc11_ += this.cellHeight + _loc7_;
                        _loc10_ = _loc4_;
                     }
                  }
                  this.setChildSize(_loc16_);
                  _loc12_ = Math.floor(this.calcHorizontalOffset(_loc16_.width,_loc8_));
                  _loc13_ = Math.floor(this.calcVerticalOffset(_loc16_.height,_loc9_));
                  _loc16_.move(_loc10_ + _loc12_,_loc11_ + _loc13_);
                  _loc10_ += this.cellWidth + _loc6_;
               }
               _loc15_++;
            }
         }
         else
         {
            _loc20_ = Math.ceil(param2) - _loc3_.bottom;
            _loc15_ = 0;
            while(_loc15_ < _loc14_)
            {
               if((_loc16_ = this.getLayoutChildAt(_loc15_)).includeInLayout)
               {
                  if(_loc11_ + this.cellHeight > _loc20_)
                  {
                     if(_loc11_ != _loc5_)
                     {
                        _loc10_ += this.cellWidth + _loc6_;
                        _loc11_ = _loc5_;
                     }
                  }
                  this.setChildSize(_loc16_);
                  _loc12_ = Math.floor(this.calcHorizontalOffset(_loc16_.width,_loc8_));
                  _loc13_ = Math.floor(this.calcVerticalOffset(_loc16_.height,_loc9_));
                  _loc16_.move(_loc10_ + _loc12_,_loc11_ + _loc13_);
                  _loc11_ += this.cellHeight + _loc7_;
               }
               _loc15_++;
            }
         }
         this.cellWidth = NaN;
         this.cellHeight = NaN;
         this._unscaledWidth = param1;
         this._unscaledHeight = param2;
         if(isNaN(this.cellWidth))
         {
            this.findCellSize();
         }
         if(this.direction == "vertical")
         {
            this.layoutVertical();
         }
         else
         {
            this.layoutHorizontal();
         }
      }
      
      override public function contentToGlobal(param1:Point) : Point
      {
         if(this.contentPane)
         {
            return this.contentPane.localToGlobal(param1);
         }
         return localToGlobal(param1);
      }
      
      override public function globalToContent(param1:Point) : Point
      {
         if(this.contentPane)
         {
            return this.contentPane.globalToLocal(param1);
         }
         return globalToLocal(param1);
      }
      
      override public function contentToLocal(param1:Point) : Point
      {
         if(!this.contentPane)
         {
            return param1;
         }
         param1 = this.contentToGlobal(param1);
         return globalToLocal(param1);
      }
      
      override public function localToContent(param1:Point) : Point
      {
         if(!this.contentPane)
         {
            return param1;
         }
         param1 = localToGlobal(param1);
         return this.globalToContent(param1);
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc2_:Boolean = param1 == null || param1 == "styleName";
         if(_loc2_ || styleManager.isSizeInvalidatingStyle(param1))
         {
            invalidateDisplayList();
         }
         if(_loc2_ || param1 == "borderSkin")
         {
            if(this.border)
            {
               this.rawChildren.removeChild(DisplayObject(this.border));
               this.border = null;
               this.createBorder();
            }
         }
         if(_loc2_ || param1 == "borderStyle" || param1 == "backgroundColor" || param1 == "backgroundImage" || param1 == "mouseShield" || param1 == "mouseShieldChildren")
         {
            this.createBorder();
         }
         super.styleChanged(param1);
         if(_loc2_ || styleManager.isSizeInvalidatingStyle(param1))
         {
            this.invalidateViewMetricsAndPadding();
         }
      }
      
      override public function notifyStyleChangeInChildren(param1:String, param2:Boolean) : void
      {
         var _loc5_:ISimpleStyleClient = null;
         var _loc3_:int = super.numChildren;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(this.contentPane || _loc4_ < this._firstChildIndex || _loc4_ >= this._firstChildIndex + this._numChildren)
            {
               if(_loc5_ = super.getChildAt(_loc4_) as ISimpleStyleClient)
               {
                  _loc5_.styleChanged(param1);
                  if(_loc5_ is IStyleClient)
                  {
                     IStyleClient(_loc5_).notifyStyleChangeInChildren(param1,param2);
                  }
               }
            }
            _loc4_++;
         }
         if(param2)
         {
            this.changedStyles = this.changedStyles != null || param1 == null ? MULTIPLE_PROPERTIES : param1;
            invalidateProperties();
         }
      }
      
      override public function regenerateStyleCache(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:DisplayObject = null;
         super.regenerateStyleCache(param1);
         if(this.contentPane)
         {
            _loc2_ = this.contentPane.numChildren;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if((_loc4_ = this.getChildAt(_loc3_)) is UIComponent)
               {
                  if(UIComponent(_loc4_).inheritingStyles != StyleProtoChain.STYLE_UNINITIALIZED)
                  {
                     UIComponent(_loc4_).regenerateStyleCache(param1);
                  }
               }
               else if(_loc4_ is IUITextField && IUITextField(_loc4_).inheritingStyles)
               {
                  StyleProtoChain.initTextField(IUITextField(_loc4_));
               }
               _loc3_++;
            }
         }
      }
      
      override protected function attachOverlay() : void
      {
         this.rawChildren_addChild(mx_internal::effectOverlay);
      }
      
      override mx_internal function fillOverlay(param1:UIComponent, param2:uint, param3:RoundedRectangle = null) : void
      {
         var _loc4_:EdgeMetrics = this.viewMetrics;
         var _loc5_:Number = 0;
         if(!param3)
         {
            param3 = new RoundedRectangle(_loc4_.left,_loc4_.top,unscaledWidth - _loc4_.right - _loc4_.left,unscaledHeight - _loc4_.bottom - _loc4_.top,_loc5_);
         }
         if(isNaN(param3.x) || isNaN(param3.y) || isNaN(param3.width) || isNaN(param3.height) || isNaN(param3.cornerRadius))
         {
            return;
         }
         var _loc6_:Graphics;
         (_loc6_ = param1.graphics).clear();
         _loc6_.beginFill(param2);
         _loc6_.drawRoundRect(param3.x,param3.y,param3.width,param3.height,param3.cornerRadius * 2,param3.cornerRadius * 2);
         _loc6_.endFill();
      }
      
      override public function executeBindings(param1:Boolean = false) : void
      {
         var _loc2_:Object = descriptor && descriptor.document ? descriptor.document : parentDocument;
         BindingManager.executeBindings(_loc2_,id,this);
         if(param1)
         {
            this.executeChildBindings(param1);
         }
      }
      
      override public function prepareToPrint(param1:IFlexDisplayObject) : Object
      {
         var _loc2_:Rectangle = this.contentPane && this.contentPane.scrollRect ? this.contentPane.scrollRect : null;
         if(_loc2_)
         {
            this.contentPane.scrollRect = null;
         }
         super.prepareToPrint(param1);
         return _loc2_;
      }
      
      override public function finishPrint(param1:Object, param2:IFlexDisplayObject) : void
      {
         if(param1)
         {
            this.contentPane.scrollRect = Rectangle(param1);
         }
         super.finishPrint(param1,param2);
      }
      
      override mx_internal function addingChild(param1:DisplayObject) : void
      {
         var _loc2_:IUIComponent = IUIComponent(param1);
         super.addingChild(param1);
         invalidateSize();
         invalidateDisplayList();
         if(!this.contentPane)
         {
            if(this._numChildren == 0)
            {
               this._firstChildIndex = super.numChildren;
            }
            ++this._numChildren;
         }
         if(this.contentPane && !this.autoLayout)
         {
            this.forceLayout = true;
            UIComponentGlobals.layoutManager.addEventListener(FlexEvent.UPDATE_COMPLETE,this.layoutCompleteHandler,false,0,true);
         }
      }
      
      override mx_internal function childAdded(param1:DisplayObject) : void
      {
         var _loc2_:ChildExistenceChangedEvent = null;
         if(hasEventListener("childrenChanged"))
         {
            dispatchEvent(new Event("childrenChanged"));
         }
         if(hasEventListener(ChildExistenceChangedEvent.CHILD_ADD))
         {
            _loc2_ = new ChildExistenceChangedEvent(ChildExistenceChangedEvent.CHILD_ADD);
            _loc2_.relatedObject = param1;
            dispatchEvent(_loc2_);
         }
         if(hasEventListener(FlexEvent.ADD))
         {
            param1.dispatchEvent(new FlexEvent(FlexEvent.ADD));
         }
         super.childAdded(param1);
      }
      
      override mx_internal function removingChild(param1:DisplayObject) : void
      {
         var _loc2_:ChildExistenceChangedEvent = null;
         super.removingChild(param1);
         if(hasEventListener(FlexEvent.REMOVE))
         {
            param1.dispatchEvent(new FlexEvent(FlexEvent.REMOVE));
         }
         if(hasEventListener(ChildExistenceChangedEvent.CHILD_REMOVE))
         {
            _loc2_ = new ChildExistenceChangedEvent(ChildExistenceChangedEvent.CHILD_REMOVE);
            _loc2_.relatedObject = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      override mx_internal function childRemoved(param1:DisplayObject) : void
      {
         super.childRemoved(param1);
         invalidateSize();
         invalidateDisplayList();
         if(!this.contentPane)
         {
            --this._numChildren;
            if(this._numChildren == 0)
            {
               this._firstChildIndex = super.numChildren;
            }
         }
         if(this.contentPane && !this.autoLayout)
         {
            this.forceLayout = true;
            UIComponentGlobals.layoutManager.addEventListener(FlexEvent.UPDATE_COMPLETE,this.layoutCompleteHandler,false,0,true);
         }
         if(hasEventListener("childrenChanged"))
         {
            dispatchEvent(new Event("childrenChanged"));
         }
      }
      
      [Bindable("childrenChanged")]
      public function getChildren() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:int = this.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_.push(this.getChildAt(_loc3_));
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function removeAllChildren() : void
      {
         while(this.numChildren > 0)
         {
            this.removeChildAt(0);
         }
      }
      
      mx_internal function setDocumentDescriptor(param1:UIComponentDescriptor) : void
      {
         var _loc2_:String = null;
         if(processedDescriptors)
         {
            return;
         }
         if(mx_internal::_documentDescriptor && mx_internal::_documentDescriptor.properties.childDescriptors)
         {
            if(param1.properties.childDescriptors)
            {
               _loc2_ = resourceManager.getString("core","multipleChildSets_ClassAndSubclass");
               throw new Error(_loc2_);
            }
         }
         else
         {
            _documentDescriptor = param1;
            mx_internal::_documentDescriptor.document = this;
         }
      }
      
      mx_internal function setActualCreationPolicies(param1:String) : void
      {
         var _loc5_:IFlexDisplayObject = null;
         this.actualCreationPolicy = param1;
         var _loc2_:String = param1;
         if(param1 == ContainerCreationPolicy.QUEUED)
         {
            _loc2_ = ContainerCreationPolicy.AUTO;
         }
         var _loc3_:int = this.numChildren;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = IFlexDisplayObject(this.getChildAt(_loc4_));
            _loc4_++;
         }
      }
      
      public function createComponentsFromDescriptors(param1:Boolean = true) : void
      {
         var _loc4_:IFlexDisplayObject = null;
         this.numChildrenBefore = this.numChildren;
         this.createdComponents = [];
         var _loc2_:int = !!this.childDescriptors ? int(this.childDescriptors.length) : 0;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this.createComponentFromDescriptor(this.childDescriptors[_loc3_],param1);
            this.createdComponents.push(_loc4_);
            _loc3_++;
         }
         if(this.creationPolicy == ContainerCreationPolicy.QUEUED || this.creationPolicy == ContainerCreationPolicy.NONE)
         {
            UIComponentGlobals.layoutManager.usePhasedInstantiation = false;
         }
         this.numChildrenCreated = this.numChildren - this.numChildrenBefore;
         processedDescriptors = true;
         dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
      }
      
      public function createDeferredContent() : void
      {
         this.createComponentsFromDescriptors(true);
      }
      
      public function createComponentFromDescriptor(param1:ComponentDescriptor, param2:Boolean) : IFlexDisplayObject
      {
         var _loc7_:* = null;
         var _loc10_:IRepeaterClient = null;
         var _loc11_:IStyleClient = null;
         var _loc12_:* = null;
         var _loc13_:String = null;
         var _loc3_:UIComponentDescriptor = UIComponentDescriptor(param1);
         var _loc4_:Object = _loc3_.properties;
         if((this.numChildrenBefore != 0 || this.numChildrenCreated != -1) && _loc3_.instanceIndices == null && this.hasChildMatchingDescriptor(_loc3_))
         {
            return null;
         }
         UIComponentGlobals.layoutManager.usePhasedInstantiation = true;
         var _loc6_:IDeferredInstantiationUIComponent;
         var _loc5_:Class;
         (_loc6_ = new (_loc5_ = _loc3_.type)()).id = _loc3_.id;
         if(_loc6_.id && _loc6_.id != "")
         {
            _loc6_.name = _loc6_.id;
         }
         _loc6_.descriptor = _loc3_;
         if(_loc4_.childDescriptors && _loc6_ is IContainer && (_loc6_ as Object).hasOwnProperty("_childDescriptors"))
         {
            (_loc6_ as Object)._childDescriptors = _loc4_.childDescriptors;
            delete _loc4_.childDescriptors;
         }
         for(_loc7_ in _loc4_)
         {
            _loc6_[_loc7_] = _loc4_[_loc7_];
         }
         if(_loc6_ is IContainer && (_loc6_ as Object).hasOwnProperty("recursionFlag"))
         {
            (_loc6_ as Object).recursionFlag = param2;
         }
         if(_loc3_.instanceIndices)
         {
            if(_loc6_ is IRepeaterClient)
            {
               (_loc10_ = IRepeaterClient(_loc6_)).instanceIndices = _loc3_.instanceIndices;
               _loc10_.repeaters = _loc3_.repeaters;
               _loc10_.repeaterIndices = _loc3_.repeaterIndices;
            }
         }
         if(_loc6_ is IStyleClient)
         {
            _loc11_ = IStyleClient(_loc6_);
            if(_loc3_.stylesFactory != null)
            {
               if(!_loc11_.styleDeclaration)
               {
                  _loc11_.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
               }
               _loc11_.styleDeclaration.factory = _loc3_.stylesFactory;
            }
         }
         var _loc8_:Object;
         if(_loc8_ = _loc3_.events)
         {
            for(_loc12_ in _loc8_)
            {
               _loc13_ = _loc8_[_loc12_];
               _loc6_.addEventListener(_loc12_,_loc3_.document[_loc13_]);
            }
         }
         var _loc9_:Array;
         if(_loc9_ = _loc3_.effects)
         {
            _loc6_.registerEffects(_loc9_);
         }
         if(_loc6_ is IRepeaterClient)
         {
            IRepeaterClient(_loc6_).initializeRepeaterArrays(this);
         }
         _loc6_.createReferenceOnParentDocument(IFlexDisplayObject(_loc3_.document));
         if(!_loc6_.document)
         {
            _loc6_.document = _loc3_.document;
         }
         if(_loc6_ is IRepeater)
         {
            if(!this.childRepeaters)
            {
               this.childRepeaters = [];
            }
            this.childRepeaters.push(_loc6_);
            _loc6_.executeBindings();
            IRepeater(_loc6_).initializeRepeater(this,param2);
         }
         else
         {
            this.addChild(DisplayObject(_loc6_));
            _loc6_.executeBindings();
            if(this.creationPolicy == ContainerCreationPolicy.QUEUED || this.creationPolicy == ContainerCreationPolicy.NONE)
            {
               _loc6_.addEventListener(FlexEvent.CREATION_COMPLETE,this.creationCompleteHandler);
            }
         }
         return _loc6_;
      }
      
      private function hasChildMatchingDescriptor(param1:UIComponentDescriptor) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:IUIComponent = null;
         var _loc2_:String = param1.id;
         if(_loc2_ != null && _loc2_ in document && document[_loc2_] == null)
         {
            return false;
         }
         var _loc3_:int = this.numChildren;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            if((_loc5_ = IUIComponent(this.getChildAt(_loc4_))) is IDeferredInstantiationUIComponent && IDeferredInstantiationUIComponent(_loc5_).descriptor == param1)
            {
               return true;
            }
            _loc4_++;
         }
         if(this.childRepeaters)
         {
            _loc3_ = this.childRepeaters.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(IDeferredInstantiationUIComponent(this.childRepeaters[_loc4_]).descriptor == param1)
               {
                  return true;
               }
               _loc4_++;
            }
         }
         return false;
      }
      
      mx_internal function rawChildren_addChild(param1:DisplayObject) : DisplayObject
      {
         if(this._numChildren == 0)
         {
            ++this._firstChildIndex;
         }
         super.addingChild(param1);
         $addChild(param1);
         super.childAdded(param1);
         dispatchEvent(new Event("childrenChanged"));
         return param1;
      }
      
      mx_internal function rawChildren_addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         if(this._firstChildIndex < param2 && param2 < this._firstChildIndex + this._numChildren + 1)
         {
            ++this._numChildren;
         }
         else if(param2 <= this._firstChildIndex)
         {
            ++this._firstChildIndex;
         }
         super.addingChild(param1);
         $addChildAt(param1,param2);
         super.childAdded(param1);
         dispatchEvent(new Event("childrenChanged"));
         return param1;
      }
      
      mx_internal function rawChildren_removeChild(param1:DisplayObject) : DisplayObject
      {
         var _loc2_:int = this.rawChildren_getChildIndex(param1);
         return this.rawChildren_removeChildAt(_loc2_);
      }
      
      mx_internal function rawChildren_removeChildAt(param1:int) : DisplayObject
      {
         var _loc2_:DisplayObject = super.getChildAt(param1);
         super.removingChild(_loc2_);
         $removeChildAt(param1);
         super.childRemoved(_loc2_);
         if(this._firstChildIndex < param1 && param1 < this._firstChildIndex + this._numChildren)
         {
            --this._numChildren;
         }
         else if(this._numChildren == 0 || param1 < this._firstChildIndex)
         {
            --this._firstChildIndex;
         }
         invalidateSize();
         invalidateDisplayList();
         dispatchEvent(new Event("childrenChanged"));
         return _loc2_;
      }
      
      mx_internal function rawChildren_getChildAt(param1:int) : DisplayObject
      {
         return super.getChildAt(param1);
      }
      
      mx_internal function rawChildren_getChildByName(param1:String) : DisplayObject
      {
         return super.getChildByName(param1);
      }
      
      mx_internal function rawChildren_getChildIndex(param1:DisplayObject) : int
      {
         return super.getChildIndex(param1);
      }
      
      mx_internal function rawChildren_setChildIndex(param1:DisplayObject, param2:int) : void
      {
         var _loc3_:int = super.getChildIndex(param1);
         super.setChildIndex(param1,param2);
         if(_loc3_ < this._firstChildIndex && param2 >= this._firstChildIndex)
         {
            --this._firstChildIndex;
         }
         else if(_loc3_ >= this._firstChildIndex && param2 <= this._firstChildIndex)
         {
            ++this._firstChildIndex;
         }
         dispatchEvent(new Event("childrenChanged"));
      }
      
      mx_internal function rawChildren_getObjectsUnderPoint(param1:Point) : Array
      {
         return super.getObjectsUnderPoint(param1);
      }
      
      mx_internal function rawChildren_contains(param1:DisplayObject) : Boolean
      {
         return super.contains(param1);
      }
      
      protected function layoutChrome(param1:Number, param2:Number) : void
      {
         if(this.border)
         {
            this.updateBackgroundImageRect();
            this.border.move(0,0);
            this.border.setActualSize(param1,param2);
         }
      }
      
      protected function createBorder() : void
      {
         var _loc1_:Class = null;
         if(!this.border && this.isBorderNeeded())
         {
            _loc1_ = getStyle("borderSkin");
            if(_loc1_ != null)
            {
               this.border = new _loc1_();
               this.border.name = "border";
               if(this.border is IUIComponent)
               {
                  IUIComponent(this.border).enabled = enabled;
               }
               if(this.border is ISimpleStyleClient)
               {
                  ISimpleStyleClient(this.border).styleName = this;
               }
               this.rawChildren.addChildAt(DisplayObject(this.border),0);
               invalidateDisplayList();
            }
         }
      }
      
      private function isBorderNeeded() : Boolean
      {
         var _loc1_:Class = getStyle("borderSkin");
         if(!didLookup)
         {
            haloBorder = getDefinition("mx.skins.halo::HaloBorder");
            sparkBorder = getDefinition("mx.skins.spark::BorderSkin");
            sparkContainerBorder = getDefinition("mx.skins.spark::ContainerBorderSkin");
            didLookup = true;
         }
         if(!(_loc1_ == haloBorder || _loc1_ == sparkBorder || _loc1_ == sparkContainerBorder))
         {
            return true;
         }
         var _loc2_:Object = getStyle("borderStyle");
         if(_loc2_)
         {
            if(_loc2_ != "none" || _loc2_ == "none" && getStyle("mouseShield"))
            {
               return true;
            }
         }
         _loc2_ = getStyle("contentBackgroundColor");
         if(_loc1_ == sparkBorder && _loc2_ !== null)
         {
            return true;
         }
         _loc2_ = getStyle("backgroundColor");
         if(_loc2_ !== null && _loc2_ !== "")
         {
            return true;
         }
         _loc2_ = getStyle("backgroundImage");
         return _loc2_ != null && _loc2_ != "";
      }
      
      mx_internal function invalidateViewMetricsAndPadding() : void
      {
         this._viewMetricsAndPadding = null;
      }
      
      private function createOrDestroyBlocker() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:ISystemManager = null;
         if(enabled)
         {
            if(this.blocker)
            {
               this.rawChildren.removeChild(this.blocker);
               this.blocker = null;
            }
         }
         else if(!this.blocker)
         {
            this.blocker = new FlexSprite();
            this.blocker.name = "blocker";
            this.blocker.mouseEnabled = true;
            this.rawChildren.addChild(this.blocker);
            this.blocker.addEventListener(MouseEvent.CLICK,this.blocker_clickHandler);
            _loc1_ = !!focusManager ? DisplayObject(focusManager.getFocus()) : null;
            while(_loc1_)
            {
               if(_loc1_ == this)
               {
                  _loc2_ = systemManager;
                  if(_loc2_ && _loc2_.stage)
                  {
                     _loc2_.stage.focus = null;
                  }
                  break;
               }
               _loc1_ = _loc1_.parent;
            }
         }
      }
      
      private function updateBackgroundImageRect() : void
      {
         var _loc1_:IRectangularBorder = this.border as IRectangularBorder;
         if(!_loc1_)
         {
            return;
         }
         if(this.viewableWidth == 0 && this.viewableHeight == 0)
         {
            _loc1_.backgroundImageBounds = null;
            return;
         }
         var _loc2_:EdgeMetrics = this.viewMetrics;
         var _loc3_:Number = !!this.viewableWidth ? Number(this.viewableWidth) : Number(unscaledWidth - _loc2_.left - _loc2_.right);
         var _loc4_:Number = !!this.viewableHeight ? Number(this.viewableHeight) : Number(unscaledHeight - _loc2_.top - _loc2_.bottom);
         if(getStyle("backgroundAttachment") == "fixed")
         {
            _loc1_.backgroundImageBounds = new Rectangle(_loc2_.left,_loc2_.top,_loc3_,_loc4_);
         }
         else
         {
            _loc1_.backgroundImageBounds = new Rectangle(_loc2_.left,_loc2_.top,Math.max(this.scrollableWidth,_loc3_),Math.max(this.scrollableHeight,_loc4_));
         }
      }
      
      private function createContentPaneAndScrollbarsIfNeeded() : Boolean
      {
         var _loc1_:Rectangle = null;
         var _loc2_:Boolean = false;
         if(this._clipContent)
         {
            _loc1_ = this.getScrollableRect();
            if(this.border)
            {
               this.updateBackgroundImageRect();
            }
            return _loc2_;
         }
         _loc1_ = this.getScrollableRect();
         this.scrollableWidth = _loc1_.right;
         this.scrollableHeight = _loc1_.bottom;
         if(_loc2_ && this.border)
         {
            this.updateBackgroundImageRect();
         }
         return _loc2_;
      }
      
      mx_internal function getScrollableRect() : Rectangle
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:DisplayObject = null;
         var _loc14_:IUIComponent = null;
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:int = this.numChildren;
         var _loc6_:int = 0;
         for(; _loc6_ < _loc5_; _loc6_++)
         {
            if((_loc13_ = this.getChildAt(_loc6_)) is IUIComponent)
            {
               if(!IUIComponent(_loc13_).includeInLayout)
               {
                  continue;
               }
               _loc11_ = (_loc14_ = PostScaleAdapter.getCompatibleIUIComponent(_loc13_)).width;
               _loc12_ = _loc14_.height;
               _loc9_ = _loc14_.x;
               _loc10_ = _loc14_.y;
            }
            else
            {
               _loc11_ = _loc13_.width;
               _loc12_ = _loc13_.height;
               _loc9_ = _loc13_.x;
               _loc10_ = _loc13_.y;
            }
            _loc1_ = Math.min(_loc1_,_loc9_);
            _loc2_ = Math.min(_loc2_,_loc10_);
            if(!isNaN(_loc11_))
            {
               _loc3_ = Math.max(_loc3_,_loc9_ + _loc11_);
            }
            if(!isNaN(_loc12_))
            {
               _loc4_ = Math.max(_loc4_,_loc10_ + _loc12_);
            }
         }
         var _loc7_:EdgeMetrics = this.viewMetrics;
         var _loc8_:Rectangle;
         (_loc8_ = new Rectangle()).left = _loc1_;
         _loc8_.top = _loc2_;
         _loc8_.right = _loc3_;
         _loc8_.bottom = _loc4_;
         if(this.usePadding)
         {
            _loc8_.right += getStyle("paddingRight");
            _loc8_.bottom += getStyle("paddingBottom");
         }
         return _loc8_;
      }
      
      private function clampScrollPositions() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this._horizontalScrollPosition < 0)
         {
            this._horizontalScrollPosition = 0;
            _loc1_ = true;
         }
         else if(this._horizontalScrollPosition > this.maxHorizontalScrollPosition)
         {
            this._horizontalScrollPosition = this.maxHorizontalScrollPosition;
            _loc1_ = true;
         }
         if(this._verticalScrollPosition < 0)
         {
            this._verticalScrollPosition = 0;
            _loc1_ = true;
         }
         else if(this._verticalScrollPosition > this.maxVerticalScrollPosition)
         {
            this._verticalScrollPosition = this.maxVerticalScrollPosition;
            _loc1_ = true;
         }
         return _loc1_;
      }
      
      mx_internal function createContentPane() : void
      {
         var _loc3_:int = 0;
         var _loc5_:IUIComponent = null;
         if(this.contentPane)
         {
            return;
         }
         this.creatingContentPane = true;
         var _loc1_:int = this.numChildren;
         var _loc2_:Sprite = new FlexSprite();
         _loc2_.name = "contentPane";
         if(this.border)
         {
            _loc3_ = this.rawChildren.getChildIndex(DisplayObject(this.border)) + 1;
            if(this.border is IRectangularBorder && IRectangularBorder(this.border).hasBackgroundImage)
            {
               _loc3_++;
            }
         }
         else
         {
            _loc3_ = 0;
         }
         this.rawChildren.addChildAt(_loc2_,_loc3_);
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_)
         {
            _loc5_ = IUIComponent(super.getChildAt(this._firstChildIndex));
            _loc2_.addChild(DisplayObject(_loc5_));
            _loc5_.parentChanged(_loc2_);
            --this._numChildren;
            _loc4_++;
         }
         this.contentPane = _loc2_;
         this.creatingContentPane = false;
         this.contentPane.visible = true;
      }
      
      protected function scrollChildren() : void
      {
         if(!this.contentPane)
         {
            return;
         }
         var _loc1_:EdgeMetrics = this.viewMetrics;
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = unscaledWidth - _loc1_.left - _loc1_.right;
         var _loc5_:Number = unscaledHeight - _loc1_.top - _loc1_.bottom;
         if(this._clipContent)
         {
            _loc2_ += this._horizontalScrollPosition;
            _loc3_ += this._verticalScrollPosition;
         }
         else
         {
            _loc4_ = this.scrollableWidth;
            _loc5_ = this.scrollableHeight;
         }
         var _loc6_:Rectangle = this.getScrollableRect();
         if(_loc2_ == 0 && _loc3_ == 0 && _loc4_ >= _loc6_.right && _loc5_ >= _loc6_.bottom && _loc6_.left >= 0 && _loc6_.top >= 0 && this._forceClippingCount <= 0)
         {
            this.contentPane.scrollRect = null;
            this.contentPane.opaqueBackground = null;
            this.contentPane.cacheAsBitmap = false;
         }
         else
         {
            this.contentPane.scrollRect = new Rectangle(_loc2_,_loc3_,_loc4_,_loc5_);
         }
         if(this.focusPane)
         {
            this.focusPane.scrollRect = this.contentPane.scrollRect;
         }
         if(this.border && this.border is IRectangularBorder && IRectangularBorder(this.border).hasBackgroundImage)
         {
            IRectangularBorder(this.border).layoutBackgroundImage();
         }
      }
      
      mx_internal function set forceClipping(param1:Boolean) : void
      {
         if(this._clipContent)
         {
            if(param1)
            {
               ++this._forceClippingCount;
            }
            else
            {
               --this._forceClippingCount;
            }
            this.createContentPane();
            this.scrollChildren();
         }
      }
      
      public function executeChildBindings(param1:Boolean) : void
      {
         var _loc4_:IUIComponent = null;
         var _loc2_:int = this.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if((_loc4_ = IUIComponent(this.getChildAt(_loc3_))) is IDeferredInstantiationUIComponent)
            {
               IDeferredInstantiationUIComponent(_loc4_).executeBindings(param1);
            }
            _loc3_++;
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:Object = getFocus();
         if(_loc2_ is TextField || this.richEditableTextClass && _loc2_ is this.richEditableTextClass)
         {
            return;
         }
         if(param1.isDefaultPrevented())
         {
            return;
         }
      }
      
      private function mouseWheelHandler(param1:MouseEvent) : void
      {
      }
      
      private function layoutCompleteHandler(param1:FlexEvent) : void
      {
         UIComponentGlobals.layoutManager.removeEventListener(FlexEvent.UPDATE_COMPLETE,this.layoutCompleteHandler);
         this.forceLayout = false;
         var _loc2_:Boolean = false;
         if(!isNaN(this.horizontalScrollPositionPending))
         {
            if(this.horizontalScrollPositionPending < 0)
            {
               this.horizontalScrollPositionPending = 0;
            }
            else if(this.horizontalScrollPositionPending > this.maxHorizontalScrollPosition)
            {
               this.horizontalScrollPositionPending = this.maxHorizontalScrollPosition;
            }
            this.horizontalScrollPositionPending = NaN;
         }
         if(!isNaN(this.verticalScrollPositionPending))
         {
            if(this.verticalScrollPositionPending < 0)
            {
               this.verticalScrollPositionPending = 0;
            }
            else if(this.verticalScrollPositionPending > this.maxVerticalScrollPosition)
            {
               this.verticalScrollPositionPending = this.maxVerticalScrollPosition;
            }
            this.verticalScrollPositionPending = NaN;
         }
         if(_loc2_)
         {
            this.scrollChildren();
         }
      }
      
      private function creationCompleteHandler(param1:FlexEvent) : void
      {
         --this.numChildrenCreated;
         if(this.numChildrenCreated <= 0)
         {
            dispatchEvent(new FlexEvent("childrenCreationComplete"));
         }
      }
      
      private function blocker_clickHandler(param1:Event) : void
      {
         param1.stopPropagation();
      }
      
      override protected function measure() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc11_:int = 0;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Array = null;
         var _loc22_:int = 0;
         var _loc23_:Boolean = false;
         super.measure();
         this.findCellSize();
         _loc3_ = this.cellWidth;
         _loc4_ = this.cellHeight;
         var _loc5_:int;
         var _loc6_:int = _loc5_ = this.numChildren;
         var _loc7_:int = 0;
         while(_loc7_ < _loc5_)
         {
            if(!IUIComponent(this.getChildAt(_loc7_)).includeInLayout)
            {
               _loc6_--;
            }
            _loc7_++;
         }
         if((_loc5_ = _loc6_) > 0)
         {
            _loc15_ = getStyle("horizontalGap");
            _loc16_ = getStyle("verticalGap");
            if(this.direction == "horizontal")
            {
               _loc19_ = explicitWidth / Math.abs(scaleX);
               if(!isNaN(_loc19_))
               {
                  _loc17_ = Math.floor((_loc19_ + _loc15_) / (this.cellWidth + _loc15_));
               }
            }
            else
            {
               _loc20_ = explicitHeight / Math.abs(scaleY);
               if(!isNaN(_loc20_))
               {
                  _loc17_ = Math.floor((_loc20_ + _loc16_) / (this.cellHeight + _loc16_));
               }
            }
            if(isNaN(_loc17_))
            {
               _loc17_ = Math.ceil(Math.sqrt(_loc5_));
            }
            if(_loc17_ < 1)
            {
               _loc17_ = 1;
            }
            _loc18_ = Math.ceil(_loc5_ / _loc17_);
            if(this.direction == "horizontal")
            {
               _loc1_ = _loc17_ * this.cellWidth + (_loc17_ - 1) * _loc15_;
               _loc2_ = _loc18_ * this.cellHeight + (_loc18_ - 1) * _loc16_;
            }
            else
            {
               _loc1_ = _loc18_ * this.cellWidth + (_loc18_ - 1) * _loc15_;
               _loc2_ = _loc17_ * this.cellHeight + (_loc17_ - 1) * _loc16_;
            }
         }
         else
         {
            _loc1_ = _loc3_;
            _loc2_ = _loc4_;
         }
         var _loc8_:EdgeMetrics;
         var _loc9_:Number = (_loc8_ = this.viewMetricsAndPadding).left + _loc8_.right;
         var _loc10_:Number = _loc8_.top + _loc8_.bottom;
         _loc3_ += _loc9_;
         _loc1_ += _loc9_;
         _loc4_ += _loc10_;
         _loc2_ += _loc10_;
         measuredMinWidth = Math.ceil(_loc3_);
         measuredMinHeight = Math.ceil(_loc4_);
         measuredWidth = Math.ceil(_loc1_);
         measuredHeight = Math.ceil(_loc2_);
         this.findCellSize();
         _loc3_ = this.cellWidth;
         _loc4_ = this.cellHeight;
         var _loc12_:int;
         if((_loc12_ = this.numChildren) > 0)
         {
            _loc15_ = getStyle("horizontalGap");
            _loc16_ = getStyle("verticalGap");
            _loc8_ = this.viewMetricsAndPadding;
            if(this.direction == "vertical")
            {
               _loc23_ = false;
               if(!isNaN(explicitHeight))
               {
                  _loc2_ = explicitHeight - _loc8_.top - _loc8_.bottom;
                  _loc23_ = true;
               }
               else if(!isNaN(this._actualMajorAxisLength))
               {
                  _loc2_ = this._actualMajorAxisLength * this.cellHeight + (this._actualMajorAxisLength - 1) * _loc16_;
                  this._actualMajorAxisLength = NaN;
                  _loc23_ = true;
               }
               if(_loc23_)
               {
                  _loc21_ = this.calcColumnWidthsForHeight(_loc2_);
                  _loc1_ = 0;
                  _loc5_ = _loc11_ = _loc21_.length;
                  _loc7_ = 0;
                  while(_loc7_ < _loc5_)
                  {
                     _loc1_ += _loc21_[_loc7_];
                     _loc7_++;
                  }
                  _loc1_ += (_loc11_ - 1) * _loc15_;
                  _loc2_ = (_loc22_ = Math.min(_loc12_,Math.max(1,Math.floor((_loc2_ + _loc16_) / (this.cellHeight + _loc16_))))) * this.cellHeight + (_loc22_ - 1) * _loc16_;
                  this._preferredMajorAxisLength = _loc22_;
               }
               else
               {
                  _loc2_ = _loc12_ * this.cellHeight + (_loc12_ - 1) * _loc16_;
                  _loc1_ = this.cellWidth;
                  this._preferredMajorAxisLength = _loc12_;
               }
            }
            else
            {
               if(!isNaN(explicitWidth))
               {
                  _loc1_ = explicitWidth - _loc8_.left - _loc8_.right;
               }
               else if(!isNaN(this._actualMajorAxisLength))
               {
                  _loc1_ = this._actualMajorAxisLength - _loc8_.left - _loc8_.right;
                  this._actualMajorAxisLength = NaN;
               }
               else
               {
                  _loc1_ = screen.width - _loc8_.left - _loc8_.right;
               }
               _loc21_ = this.calcColumnWidthsForWidth(_loc1_);
               _loc1_ = 0;
               _loc5_ = _loc11_ = _loc21_.length;
               _loc7_ = 0;
               while(_loc7_ < _loc5_)
               {
                  _loc1_ += _loc21_[_loc7_];
                  _loc7_++;
               }
               _loc1_ += (_loc11_ - 1) * _loc15_;
               _loc2_ = (_loc22_ = Math.ceil(_loc12_ / _loc11_)) * this.cellHeight + (_loc22_ - 1) * _loc16_;
               this._preferredMajorAxisLength = _loc11_;
            }
         }
         else
         {
            _loc1_ = _loc3_;
            _loc2_ = _loc4_;
         }
         var _loc13_:Number = (_loc8_ = this.viewMetricsAndPadding).left + _loc8_.right;
         var _loc14_:Number = _loc8_.top + _loc8_.bottom;
         _loc3_ += _loc13_;
         _loc1_ += _loc13_;
         _loc4_ += _loc14_;
         _loc2_ += _loc14_;
         measuredMinWidth = _loc3_;
         measuredMinHeight = _loc4_;
         measuredWidth = _loc1_;
         measuredHeight = _loc2_;
      }
      
      mx_internal function findCellSize() : void
      {
         var _loc7_:IUIComponent = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc1_:* = !isNaN(this.tileWidth);
         var _loc2_:* = !isNaN(this.tileHeight);
         if(_loc1_ && _loc2_)
         {
            this.cellWidth = this.tileWidth;
            this.cellHeight = this.tileHeight;
            return;
         }
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:int = this.numChildren;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            if((_loc7_ = this.getLayoutChildAt(_loc6_)).includeInLayout)
            {
               if((_loc8_ = _loc7_.getExplicitOrMeasuredWidth()) > _loc3_)
               {
                  _loc3_ = _loc8_;
               }
               if((_loc9_ = _loc7_.getExplicitOrMeasuredHeight()) > _loc4_)
               {
                  _loc4_ = _loc9_;
               }
            }
            _loc6_++;
         }
         this.cellWidth = !!_loc1_ ? Number(this.tileWidth) : Number(_loc3_);
         this.cellHeight = !!_loc2_ ? Number(this.tileHeight) : Number(_loc4_);
      }
      
      private function setChildSize(param1:IUIComponent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(param1.percentWidth > 0)
         {
            _loc2_ = Math.min(this.cellWidth,this.cellWidth * param1.percentWidth / 100);
         }
         else
         {
            _loc2_ = param1.getExplicitOrMeasuredWidth();
            if(_loc2_ > this.cellWidth)
            {
               _loc4_ = !!isNaN(param1.explicitWidth) ? Number(0) : Number(param1.explicitWidth);
               _loc5_ = !!isNaN(param1.explicitMinWidth) ? Number(0) : Number(param1.explicitMinWidth);
               _loc2_ = _loc4_ > this.cellWidth || _loc5_ > this.cellWidth ? Number(Math.max(_loc5_,_loc4_)) : Number(this.cellWidth);
            }
         }
         if(param1.percentHeight > 0)
         {
            _loc3_ = Math.min(this.cellHeight,this.cellHeight * param1.percentHeight / 100);
         }
         else
         {
            _loc3_ = param1.getExplicitOrMeasuredHeight();
            if(_loc3_ > this.cellHeight)
            {
               _loc4_ = !!isNaN(param1.explicitHeight) ? Number(0) : Number(param1.explicitHeight);
               _loc5_ = !!isNaN(param1.explicitMinHeight) ? Number(0) : Number(param1.explicitMinHeight);
               _loc3_ = _loc4_ > this.cellHeight || _loc5_ > this.cellHeight ? Number(Math.max(_loc5_,_loc4_)) : Number(this.cellHeight);
            }
         }
         param1.setActualSize(_loc2_,_loc3_);
      }
      
      mx_internal function calcHorizontalOffset(param1:Number, param2:String) : Number
      {
         var _loc3_:Number = NaN;
         if(param2 == "left")
         {
            _loc3_ = 0;
         }
         else if(param2 == "center")
         {
            _loc3_ = (this.cellWidth - param1) / 2;
         }
         else if(param2 == "right")
         {
            _loc3_ = this.cellWidth - param1;
         }
         return _loc3_;
      }
      
      mx_internal function calcVerticalOffset(param1:Number, param2:String) : Number
      {
         var _loc3_:Number = NaN;
         if(param2 == "top")
         {
            _loc3_ = 0;
         }
         else if(param2 == "middle")
         {
            _loc3_ = (this.cellHeight - param1) / 2;
         }
         else if(param2 == "bottom")
         {
            _loc3_ = this.cellHeight - param1;
         }
         return _loc3_;
      }
      
      private function addLegendItem(param1:Object) : void
      {
         var _loc2_:Class = this.legendItemClass;
         var _loc3_:LegendItem = new _loc2_();
         if(param1.label != "")
         {
            _loc3_.label = param1.label;
         }
         if(param1.element)
         {
            _loc3_.element = param1.element;
         }
         if("fill" in param1)
         {
            _loc3_.setStyle("fill",param1["fill"]);
         }
         _loc3_.markerAspectRatio = param1.aspectRatio;
         _loc3_.legendData = param1;
         _loc3_.percentWidth = 100;
         _loc3_.percentHeight = 100;
         this.addChild(_loc3_);
         _loc3_.marker = param1.marker;
         _loc3_.setStyle("backgroundColor",15658751);
      }
      
      private function populateFromArray(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param1 is ChartBase)
         {
            param1 = param1.legendData;
         }
         this.removeAllChildren();
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(!(_loc5_ = param1[_loc4_] as Array))
            {
               _loc2_ = param1[_loc4_];
               this.addLegendItem(_loc2_);
            }
            else
            {
               _loc6_ = _loc5_.length;
               _loc7_ = 0;
               while(_loc7_ < _loc6_)
               {
                  _loc2_ = _loc5_[_loc7_];
                  this.addLegendItem(_loc2_);
                  _loc7_++;
               }
            }
            _loc4_++;
         }
         this._actualMajorAxisLength = NaN;
      }
      
      private function findHorizontalAlignValue() : Number
      {
         var _loc1_:String = getStyle("horizontalAlign");
         if(_loc1_ == "center")
         {
            return 0.5;
         }
         if(_loc1_ == "right")
         {
            return 1;
         }
         return 0;
      }
      
      private function findVerticalAlignValue() : Number
      {
         var _loc1_:String = getStyle("verticalAlign");
         if(_loc1_ == "middle")
         {
            return 0.5;
         }
         if(_loc1_ == "bottom")
         {
            return 1;
         }
         return 0;
      }
      
      private function widthPadding(param1:Number) : Number
      {
         var _loc2_:EdgeMetrics = this.viewMetricsAndPadding;
         var _loc3_:Number = _loc2_.left + _loc2_.right;
         if(param1 > 1 && this.direction == "horizontal")
         {
            _loc3_ += getStyle("horizontalGap") * (param1 - 1);
         }
         return _loc3_;
      }
      
      private function heightPadding(param1:Number) : Number
      {
         var _loc2_:EdgeMetrics = this.viewMetricsAndPadding;
         var _loc3_:Number = _loc2_.top + _loc2_.bottom;
         if(param1 > 1 && this.direction == "vertical")
         {
            _loc3_ += getStyle("verticalGap") * (param1 - 1);
         }
         return _loc3_;
      }
      
      private function calcColumnWidthsForHeight(param1:Number) : Array
      {
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:IUIComponent = null;
         var _loc9_:int = 0;
         var _loc2_:Number = this.numChildren;
         var _loc3_:Number = getStyle("verticalGap");
         if(isNaN(_loc3_))
         {
            _loc3_ = 0;
         }
         var _loc5_:int;
         if((_loc5_ = (_loc4_ = int(Math.min(_loc2_,Math.max(1,Math.floor((param1 + _loc3_) / (this.cellHeight + _loc3_)))))) == 0 ? 0 : int(Math.ceil(_loc2_ / _loc4_))) <= 1)
         {
            _loc6_ = [this.cellWidth];
         }
         else
         {
            _loc6_ = [];
            _loc7_ = 0;
            while(_loc7_ < _loc5_)
            {
               _loc6_[_loc7_] = 0;
               _loc7_++;
            }
            _loc7_ = 0;
            while(_loc7_ < _loc2_)
            {
               _loc8_ = IUIComponent(this.getChildAt(_loc7_));
               _loc9_ = Math.floor(_loc7_ / _loc4_);
               _loc6_[_loc9_] = Math.max(_loc6_[_loc9_],_loc8_.getExplicitOrMeasuredWidth());
               _loc7_++;
            }
         }
         return _loc6_;
      }
      
      private function layoutVertical() : void
      {
         var _loc14_:IUIComponent = null;
         var _loc15_:int = 0;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc1_:Number = this.numChildren;
         var _loc2_:EdgeMetrics = this.viewMetricsAndPadding;
         var _loc3_:Number = getStyle("horizontalGap");
         var _loc4_:Number = getStyle("verticalGap");
         var _loc5_:String = getStyle("horizontalAlign");
         var _loc6_:String = getStyle("verticalAlign");
         var _loc7_:Number = _loc2_.left;
         var _loc8_:Number = _loc2_.top;
         var _loc9_:Number = unscaledHeight - _loc2_.bottom;
         var _loc10_:int = Math.min(_loc1_,Math.max(1,Math.floor((_loc9_ - _loc8_ + _loc4_) / (this.cellHeight + _loc4_))));
         var _loc11_:Array = [];
         var _loc12_:int = (_loc11_ = this.calcColumnWidthsForHeight(_loc9_ - _loc8_)).length;
         var _loc13_:Number = 0;
         while(_loc13_ < _loc1_)
         {
            _loc14_ = IUIComponent(this.getChildAt(_loc13_));
            _loc15_ = Math.floor(_loc13_ / _loc10_);
            _loc16_ = _loc11_[_loc15_];
            if(_loc14_.percentWidth > 0)
            {
               _loc17_ = Math.min(_loc16_,_loc16_ * _loc14_.percentWidth / 100);
            }
            else
            {
               _loc17_ = _loc14_.getExplicitOrMeasuredWidth();
            }
            if(_loc14_.percentHeight > 0)
            {
               _loc18_ = Math.min(this.cellHeight,this.cellHeight * _loc14_.percentHeight / 100);
            }
            else
            {
               _loc18_ = _loc14_.getExplicitOrMeasuredHeight();
            }
            _loc14_.setActualSize(_loc17_,_loc18_);
            _loc19_ = Math.floor(this.calcHorizontalOffset(_loc14_.width,_loc5_));
            _loc20_ = Math.floor(this.calcVerticalOffset(_loc14_.height,_loc6_));
            _loc14_.move(_loc7_ + _loc19_,_loc8_ + _loc20_);
            if(_loc13_ % _loc10_ == _loc10_ - 1)
            {
               _loc8_ = _loc2_.top;
               _loc7_ += _loc16_ + _loc3_;
            }
            else
            {
               _loc8_ += this.cellHeight + _loc4_;
            }
            _loc13_++;
         }
         if(_loc10_ != this._preferredMajorAxisLength)
         {
            this._actualMajorAxisLength = _loc10_;
            invalidateSize();
         }
      }
      
      private function calcColumnWidthsForWidth(param1:Number) : Array
      {
         var _loc7_:Array = null;
         var _loc10_:IUIComponent = null;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc2_:Number = this.numChildren;
         var _loc3_:Number = getStyle("horizontalGap");
         var _loc4_:Number = 0;
         var _loc5_:Number = param1;
         var _loc6_:int = 0;
         var _loc8_:Number = 0;
         while(_loc8_ < _loc2_)
         {
            _loc11_ = (_loc10_ = IUIComponent(this.getChildAt(_loc8_))).getExplicitOrMeasuredWidth();
            if(_loc4_ + _loc11_ > _loc5_)
            {
               break;
            }
            _loc4_ += _loc11_ + _loc3_;
            _loc6_++;
            _loc8_++;
         }
         var _loc9_:Boolean = true;
         while(_loc6_ > 1 && _loc9_)
         {
            _loc7_ = [];
            _loc8_ = 0;
            while(_loc8_ < _loc6_)
            {
               _loc7_[_loc8_] = 0;
               _loc8_++;
            }
            _loc8_ = 0;
            while(_loc8_ < _loc2_)
            {
               _loc12_ = _loc8_ % _loc6_;
               _loc7_[_loc12_] = Math.max(_loc7_[_loc12_],IUIComponent(this.getChildAt(_loc8_)).getExplicitOrMeasuredWidth());
               _loc8_++;
            }
            _loc4_ = 0;
            _loc8_ = 0;
            while(_loc8_ < _loc6_)
            {
               if(_loc4_ + _loc7_[_loc8_] > _loc5_)
               {
                  break;
               }
               _loc4_ += _loc7_[_loc8_] + _loc3_;
               _loc8_++;
            }
            if(_loc8_ == _loc6_)
            {
               _loc9_ = false;
            }
            else
            {
               _loc6_--;
            }
         }
         if(_loc6_ <= 1)
         {
            _loc6_ = 1;
            _loc7_ = [this.cellWidth];
         }
         return _loc7_;
      }
      
      private function layoutHorizontal() : void
      {
         var _loc11_:Array = null;
         var _loc13_:IUIComponent = null;
         var _loc14_:int = 0;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc1_:Number = this.numChildren;
         var _loc2_:EdgeMetrics = this.viewMetricsAndPadding;
         var _loc3_:Number = getStyle("horizontalGap");
         var _loc4_:Number = getStyle("verticalGap");
         var _loc5_:String = getStyle("horizontalAlign");
         var _loc6_:String = getStyle("verticalAlign");
         var _loc7_:Number = _loc2_.left;
         var _loc8_:Number = this._unscaledWidth - _loc2_.right;
         var _loc9_:Number = _loc2_.top;
         var _loc10_:int = 0;
         _loc10_ = (_loc11_ = this.calcColumnWidthsForWidth(_loc8_ - _loc7_)).length;
         var _loc12_:Number = 0;
         while(_loc12_ < _loc1_)
         {
            _loc13_ = IUIComponent(this.getChildAt(_loc12_));
            _loc14_ = _loc12_ % _loc10_;
            _loc15_ = _loc11_[_loc14_];
            if(_loc13_.percentWidth > 0)
            {
               _loc16_ = Math.min(_loc15_,_loc15_ * _loc13_.percentWidth / 100);
            }
            else
            {
               _loc16_ = _loc13_.getExplicitOrMeasuredWidth();
            }
            if(_loc13_.percentHeight > 0)
            {
               _loc17_ = Math.min(this.cellHeight,this.cellHeight * _loc13_.percentHeight / 100);
            }
            else
            {
               _loc17_ = _loc13_.getExplicitOrMeasuredHeight();
            }
            _loc13_.setActualSize(_loc16_,_loc17_);
            _loc18_ = Math.floor(this.calcHorizontalOffset(_loc13_.width,_loc5_));
            _loc19_ = Math.floor(this.calcVerticalOffset(_loc13_.height,_loc6_));
            _loc13_.move(_loc7_ + _loc18_,_loc9_ + _loc19_);
            if(_loc14_ == _loc10_ - 1)
            {
               _loc7_ = _loc2_.left;
               _loc9_ += this.cellHeight + _loc4_;
            }
            else
            {
               _loc7_ += _loc11_[_loc14_] + _loc3_;
            }
            _loc12_++;
         }
         if(_loc10_ != this._preferredMajorAxisLength)
         {
            this._actualMajorAxisLength = this._unscaledWidth;
            invalidateSize();
         }
      }
      
      private function legendDataChangedHandler(param1:Event = null) : void
      {
         invalidateProperties();
         invalidateSize();
         this._childrenDirty = true;
      }
      
      private function childMouseEventHandler(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         while(_loc2_ != this && _loc2_.parent != this)
         {
            _loc2_ = _loc2_.parent;
         }
         if(_loc2_ is LegendItem)
         {
            dispatchEvent(new LegendMouseEvent(param1.type,param1,LegendItem(_loc2_)));
         }
      }
   }
}

import flash.display.DisplayObject;
import flash.geom.Point;
import mx.charts.Legend;
import mx.core.IChildList;
import mx.core.mx_internal;

use namespace mx_internal;

class LegendRawChildrenList implements IChildList
{
   
   mx_internal static const VERSION:String = "4.6.0.23201";
    
   
   private var owner:Legend;
   
   function LegendRawChildrenList(param1:Legend)
   {
      super();
      this.owner = param1;
   }
   
   public function get numChildren() : int
   {
      return this.owner.$numChildren;
   }
   
   public function addChild(param1:DisplayObject) : DisplayObject
   {
      return this.owner.rawChildren_addChild(param1);
   }
   
   public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
   {
      return this.owner.rawChildren_addChildAt(param1,param2);
   }
   
   public function removeChild(param1:DisplayObject) : DisplayObject
   {
      return this.owner.rawChildren_removeChild(param1);
   }
   
   public function removeChildAt(param1:int) : DisplayObject
   {
      return this.owner.rawChildren_removeChildAt(param1);
   }
   
   public function getChildAt(param1:int) : DisplayObject
   {
      return this.owner.rawChildren_getChildAt(param1);
   }
   
   public function getChildByName(param1:String) : DisplayObject
   {
      return this.owner.rawChildren_getChildByName(param1);
   }
   
   public function getChildIndex(param1:DisplayObject) : int
   {
      return this.owner.rawChildren_getChildIndex(param1);
   }
   
   public function setChildIndex(param1:DisplayObject, param2:int) : void
   {
      this.owner.rawChildren_setChildIndex(param1,param2);
   }
   
   public function getObjectsUnderPoint(param1:Point) : Array
   {
      return this.owner.rawChildren_getObjectsUnderPoint(param1);
   }
   
   public function contains(param1:DisplayObject) : Boolean
   {
      return this.owner.rawChildren_contains(param1);
   }
}
