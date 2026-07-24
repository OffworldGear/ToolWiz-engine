package mx.controls.listClasses
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   import mx.collections.ArrayCollection;
   import mx.collections.CursorBookmark;
   import mx.collections.ICollectionView;
   import mx.collections.IList;
   import mx.collections.IViewCursor;
   import mx.collections.ItemResponder;
   import mx.collections.ItemWrapper;
   import mx.collections.ListCollectionView;
   import mx.collections.ModifiedCollectionView;
   import mx.collections.XMLListCollection;
   import mx.collections.errors.CursorError;
   import mx.collections.errors.ItemPendingError;
   import mx.controls.dataGridClasses.DataGridListData;
   import mx.core.DragSource;
   import mx.core.EdgeMetrics;
   import mx.core.EventPriority;
   import mx.core.FlexShape;
   import mx.core.IDataRenderer;
   import mx.core.IFactory;
   import mx.core.IFlexDisplayObject;
   import mx.core.IInvalidating;
   import mx.core.ILayoutDirectionElement;
   import mx.core.IUIComponent;
   import mx.core.IUID;
   import mx.core.IUITextField;
   import mx.core.ScrollControlBase;
   import mx.core.ScrollPolicy;
   import mx.core.SpriteAsset;
   import mx.core.mx_internal;
   import mx.effects.IEffect;
   import mx.effects.IEffectTargetHost;
   import mx.effects.Tween;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.DragEvent;
   import mx.events.EffectEvent;
   import mx.events.FlexEvent;
   import mx.events.ListEvent;
   import mx.events.MoveEvent;
   import mx.events.SandboxMouseEvent;
   import mx.events.ScrollEvent;
   import mx.events.ScrollEventDetail;
   import mx.events.ScrollEventDirection;
   import mx.events.TweenEvent;
   import mx.managers.DragManager;
   import mx.managers.IFocusManagerComponent;
   import mx.managers.ISystemManager;
   import mx.skins.halo.ListDropIndicator;
   import mx.styles.StyleProxy;
   import mx.utils.ObjectUtil;
   import mx.utils.UIDUtil;
   
   use namespace mx_internal;
   
   public class ListBase extends ScrollControlBase implements IDataRenderer, IFocusManagerComponent, IListItemRenderer, IDropInListItemRenderer, IEffectTargetHost
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      mx_internal static const DRAG_THRESHOLD:int = 4;
      
      mx_internal static var createAccessibilityImplementation:Function;
      
      private static var _listContentStyleFilters:Object = null;
       
      
      private var IS_ITEM_STYLE:Object;
      
      protected var collection:ICollectionView;
      
      protected var iterator:IViewCursor;
      
      protected var iteratorValid:Boolean = true;
      
      protected var lastSeekPending:ListBaseSeekPending;
      
      protected var listContent:ListBaseContentHolder;
      
      protected var selectionLayer:Sprite;
      
      protected var rowMap:Object;
      
      protected var factoryMap:Dictionary;
      
      protected var freeItemRenderers:Array;
      
      protected var freeItemRenderersByFactory:Dictionary;
      
      protected var reservedItemRenderers:Object;
      
      protected var unconstrainedRenderers:Dictionary;
      
      protected var dataItemWrappersByRenderer:Dictionary;
      
      protected var runDataEffectNextUpdate:Boolean = false;
      
      protected var runningDataEffect:Boolean = false;
      
      protected var cachedItemsChangeEffect:IEffect = null;
      
      protected var modifiedCollectionView:ModifiedCollectionView;
      
      protected var actualCollection:ICollectionView;
      
      protected var offscreenExtraRows:int = 0;
      
      protected var offscreenExtraRowsTop:int = 0;
      
      protected var offscreenExtraRowsBottom:int = 0;
      
      protected var offscreenExtraColumns:int = 0;
      
      protected var offscreenExtraColumnsLeft:int = 0;
      
      protected var offscreenExtraColumnsRight:int = 0;
      
      protected var actualIterator:IViewCursor;
      
      mx_internal var allowRendererStealingDuringLayout:Boolean = true;
      
      protected var highlightUID:String;
      
      protected var highlightItemRenderer:IListItemRenderer;
      
      protected var highlightIndicator:Sprite;
      
      protected var caretUID:String;
      
      protected var caretItemRenderer:IListItemRenderer;
      
      protected var caretIndicator:Sprite;
      
      protected var selectedData:Object;
      
      protected var selectionIndicators:Object;
      
      protected var selectionTweens:Object;
      
      protected var caretBookmark:CursorBookmark;
      
      protected var anchorBookmark:CursorBookmark;
      
      protected var showCaret:Boolean;
      
      protected var lastDropIndex:int;
      
      protected var itemsNeedMeasurement:Boolean = true;
      
      protected var itemsSizeChanged:Boolean = false;
      
      protected var rendererChanged:Boolean = false;
      
      protected var dataEffectCompleted:Boolean = false;
      
      protected var wordWrapChanged:Boolean = false;
      
      protected var keySelectionPending:Boolean = false;
      
      mx_internal var cachedPaddingTop:Number;
      
      mx_internal var cachedPaddingBottom:Number;
      
      mx_internal var cachedVerticalAlign:String;
      
      private var oldUnscaledWidth:Number;
      
      private var oldUnscaledHeight:Number;
      
      private var horizontalScrollPositionPending:Number;
      
      private var verticalScrollPositionPending:Number;
      
      private var mouseDownPoint:Point;
      
      private var bSortItemPending:Boolean = false;
      
      private var bShiftKey:Boolean = false;
      
      private var bCtrlKey:Boolean = false;
      
      private var lastKey:uint = 0;
      
      private var bSelectItem:Boolean = false;
      
      private var approximate:Boolean = false;
      
      mx_internal var bColumnScrolling:Boolean = true;
      
      mx_internal var listType:String = "grid";
      
      mx_internal var bSelectOnRelease:Boolean;
      
      private var mouseDownItem:IListItemRenderer;
      
      private var mouseDownIndex:int;
      
      mx_internal var bSelectionChanged:Boolean = false;
      
      mx_internal var bSelectedIndexChanged:Boolean = false;
      
      private var bSelectedItemChanged:Boolean = false;
      
      private var bSelectedItemsChanged:Boolean = false;
      
      private var bSelectedIndicesChanged:Boolean = false;
      
      private var cachedPaddingTopInvalid:Boolean = true;
      
      private var cachedPaddingBottomInvalid:Boolean = true;
      
      private var cachedVerticalAlignInvalid:Boolean = true;
      
      private var firstSelectionData:ListBaseSelectionData;
      
      private var lastSelectionData:ListBaseSelectionData;
      
      private var firstSelectedItem:Object;
      
      private var proposedSelectedItemIndexes:Dictionary;
      
      mx_internal var lastHighlightItemRenderer:IListItemRenderer;
      
      mx_internal var lastHighlightItemRendererAtIndices:IListItemRenderer;
      
      private var lastHighlightItemIndices:Point;
      
      private var selectionDataArray:Array;
      
      mx_internal var dragScrollingInterval:int = 0;
      
      mx_internal var itemMaskFreeList:Array;
      
      private var trackedRenderers:Array;
      
      private var rendererTrackingSuspended:Boolean = false;
      
      mx_internal var isPressed:Boolean = false;
      
      mx_internal var collectionIterator:IViewCursor;
      
      mx_internal var dropIndicator:IFlexDisplayObject;
      
      mx_internal var lastDragEvent:DragEvent;
      
      public var allowDragSelection:Boolean = false;
      
      private var _allowMultipleSelection:Boolean = false;
      
      protected var anchorIndex:int = -1;
      
      protected var caretIndex:int = -1;
      
      private var _columnCount:int = -1;
      
      private var columnCountChanged:Boolean = true;
      
      private var _columnWidth:Number;
      
      private var columnWidthChanged:Boolean = false;
      
      private var _data:Object;
      
      private var _dataTipField:String = "label";
      
      private var _dataTipFunction:Function;
      
      protected var defaultColumnCount:int = 4;
      
      protected var defaultRowCount:int = 4;
      
      private var _dragEnabled:Boolean = false;
      
      private var _dragMoveEnabled:Boolean = false;
      
      private var _dropEnabled:Boolean = false;
      
      protected var explicitColumnCount:int = -1;
      
      protected var explicitColumnWidth:Number;
      
      protected var explicitRowCount:int = -1;
      
      protected var explicitRowHeight:Number;
      
      private var _iconField:String = "icon";
      
      private var _iconFunction:Function;
      
      private var _itemRenderer:IFactory;
      
      private var _labelField:String = "label";
      
      private var _labelFunction:Function;
      
      private var _listData:BaseListData;
      
      public var menuSelectionMode:Boolean = false;
      
      private var _offscreenExtraRowsOrColumns:int = 0;
      
      protected var offscreenExtraRowsOrColumnsChanged:Boolean = false;
      
      private var _nullItemRenderer:IFactory;
      
      private var _rowCount:int = -1;
      
      private var rowCountChanged:Boolean = true;
      
      private var _rowHeight:Number;
      
      private var rowHeightChanged:Boolean = false;
      
      private var _selectable:Boolean = true;
      
      mx_internal var _selectedIndex:int = -1;
      
      private var _selectedIndices:Array;
      
      private var _selectedItem:Object;
      
      private var _selectedItems:Array;
      
      private var _selectedItemsCompareFunction:Function;
      
      private var _showDataTips:Boolean = false;
      
      private var _variableRowHeight:Boolean = false;
      
      private var _wordWrap:Boolean = false;
      
      public function ListBase()
      {
         this.IS_ITEM_STYLE = {
            "alternatingItemColors":true,
            "backgroundColor":true,
            "backgroundDisabledColor":true,
            "color":true,
            "rollOverColor":true,
            "selectionColor":true,
            "selectionDisabledColor":true,
            "styleName":true,
            "textColor":true,
            "textRollOverColor":true,
            "textSelectedColor":true
         };
         this.rowMap = {};
         this.freeItemRenderers = [];
         this.reservedItemRenderers = {};
         this.unconstrainedRenderers = new Dictionary();
         this.dataItemWrappersByRenderer = new Dictionary(true);
         this.selectedData = {};
         this.selectionIndicators = {};
         this.selectionTweens = {};
         this.trackedRenderers = [];
         super();
         tabEnabled = true;
         tabFocusEnabled = true;
         this.factoryMap = new Dictionary(true);
         addEventListener(MouseEvent.MOUSE_WHEEL,this.mouseWheelHandler);
         addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         addEventListener(MouseEvent.CLICK,this.mouseClickHandler);
         addEventListener(MouseEvent.DOUBLE_CLICK,this.mouseDoubleClickHandler);
         invalidateProperties();
      }
      
      protected function get visibleData() : Object
      {
         return this.listContent.visibleData;
      }
      
      protected function get listContentStyleFilters() : Object
      {
         return _listContentStyleFilters;
      }
      
      protected function get listItems() : Array
      {
         return !!this.listContent ? this.listContent.listItems : [];
      }
      
      protected function get rowInfo() : Array
      {
         return this.listContent.rowInfo;
      }
      
      mx_internal function get rendererArray() : Array
      {
         return this.listItems;
      }
      
      override public function get baselinePosition() : Number
      {
         if(!validateBaselinePosition())
         {
            return NaN;
         }
         var _loc1_:* = this.dataProvider == null;
         var _loc2_:Boolean = this.dataProvider != null && this.dataProvider.length == 0;
         var _loc3_:Object = this.dataProvider;
         if(_loc1_ || _loc2_)
         {
            this.dataProvider = [null];
            validateNow();
         }
         if(!this.listItems || this.listItems.length == 0)
         {
            return super.baselinePosition;
         }
         var _loc4_:IUIComponent;
         if(!(_loc4_ = this.listItems[0][0] as IUIComponent))
         {
            return super.baselinePosition;
         }
         var _loc5_:ListBaseContentHolder;
         var _loc6_:Number = (_loc5_ = ListBaseContentHolder(_loc4_.parent)).y + _loc4_.y + _loc4_.baselinePosition;
         if(_loc1_ || _loc2_)
         {
            this.dataProvider = _loc3_;
            validateNow();
         }
         return _loc6_;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         var _loc2_:IFlexDisplayObject = border as IFlexDisplayObject;
         if(_loc2_)
         {
            if(_loc2_ is IUIComponent)
            {
               IUIComponent(_loc2_).enabled = param1;
            }
            if(_loc2_ is IInvalidating)
            {
               IInvalidating(_loc2_).invalidateDisplayList();
            }
         }
         this.itemsSizeChanged = true;
         invalidateDisplayList();
      }
      
      override public function set showInAutomationHierarchy(param1:Boolean) : void
      {
      }
      
      override public function set horizontalScrollPolicy(param1:String) : void
      {
         super.horizontalScrollPolicy = param1;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
      }
      
      [Bindable("viewChanged")]
      [Bindable("scroll")]
      override public function get horizontalScrollPosition() : Number
      {
         if(!isNaN(this.horizontalScrollPositionPending))
         {
            return this.horizontalScrollPositionPending;
         }
         return super.horizontalScrollPosition;
      }
      
      override public function set horizontalScrollPosition(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = false;
         if(this.listItems.length == 0 || !this.dataProvider || !isNaN(this.horizontalScrollPositionPending))
         {
            this.horizontalScrollPositionPending = param1;
            if(this.dataProvider)
            {
               invalidateDisplayList();
            }
            return;
         }
         this.horizontalScrollPositionPending = NaN;
         var _loc2_:int = super.horizontalScrollPosition;
         super.horizontalScrollPosition = param1;
         this.removeClipMask();
         if(_loc2_ != param1)
         {
            if(this.itemsSizeChanged)
            {
               return;
            }
            _loc3_ = param1 - _loc2_;
            _loc4_ = _loc3_ > 0;
            _loc3_ = Math.abs(_loc3_);
            if(this.bColumnScrolling && _loc3_ >= this.columnCount)
            {
               this.clearIndicators();
               this.clearVisibleData();
               this.makeRowsAndColumnsWithExtraColumns(this.oldUnscaledWidth,this.oldUnscaledHeight);
               this.drawRowBackgrounds();
            }
            else
            {
               this.scrollHorizontally(param1,_loc3_,_loc4_);
            }
         }
         this.addClipMask(false);
      }
      
      mx_internal function set $horizontalScrollPosition(param1:Number) : void
      {
         var _loc2_:int = super.horizontalScrollPosition;
         if(_loc2_ != param1)
         {
            super.horizontalScrollPosition = param1;
         }
      }
      
      override public function set verticalScrollPolicy(param1:String) : void
      {
         super.verticalScrollPolicy = param1;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
      }
      
      [Bindable("viewChanged")]
      [Bindable("scroll")]
      override public function get verticalScrollPosition() : Number
      {
         if(!isNaN(this.verticalScrollPositionPending))
         {
            return this.verticalScrollPositionPending;
         }
         return super.verticalScrollPosition;
      }
      
      override public function set verticalScrollPosition(param1:Number) : void
      {
         var _loc5_:int = 0;
         var _loc6_:* = false;
         if(this.listItems.length == 0 || !this.dataProvider || !isNaN(this.verticalScrollPositionPending))
         {
            this.verticalScrollPositionPending = param1;
            if(this.dataProvider)
            {
               invalidateDisplayList();
            }
            return;
         }
         this.verticalScrollPositionPending = NaN;
         var _loc2_:int = super.verticalScrollPosition;
         super.verticalScrollPosition = param1;
         this.removeClipMask();
         var _loc3_:int = this.offscreenExtraRowsTop;
         var _loc4_:int = this.offscreenExtraRowsBottom;
         if(_loc2_ != param1)
         {
            _loc6_ = (_loc5_ = param1 - _loc2_) > 0;
            if((_loc5_ = Math.abs(_loc5_)) >= this.rowInfo.length - this.offscreenExtraRows || !this.iteratorValid)
            {
               this.clearIndicators();
               this.clearVisibleData();
               this.makeRowsAndColumnsWithExtraRows(this.oldUnscaledWidth,this.oldUnscaledHeight);
            }
            else
            {
               this.scrollVertically(param1,_loc5_,_loc6_);
               this.adjustListContent(this.oldUnscaledWidth,this.oldUnscaledHeight);
            }
            if(this.variableRowHeight)
            {
               this.configureScrollBars();
            }
            this.drawRowBackgrounds();
         }
         this.addClipMask(this.offscreenExtraRowsTop != _loc3_ || this.offscreenExtraRowsBottom != _loc4_);
      }
      
      mx_internal function set $verticalScrollPosition(param1:Number) : void
      {
         var _loc2_:int = super.verticalScrollPosition;
         if(_loc2_ != param1)
         {
            super.verticalScrollPosition = param1;
         }
      }
      
      private function makeRowsAndColumnsWithExtraRows(param1:Number, param2:Number) : void
      {
         var _loc3_:ListRowInfo = null;
         var _loc4_:ListRowInfo = null;
         var _loc5_:ListRowInfo = null;
         var _loc6_:int = 0;
         var _loc7_:Point = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc8_:int = this.offscreenExtraRows / 2;
         var _loc9_:int = this.offscreenExtraRows / 2;
         this.offscreenExtraRowsTop = Math.min(_loc8_,this.verticalScrollPosition);
         var _loc10_:int = this.scrollPositionToIndex(this.horizontalScrollPosition,this.verticalScrollPosition - this.offscreenExtraRowsTop);
         this.seekPositionSafely(_loc10_);
         var _loc11_:CursorBookmark = this.iterator.bookmark;
         if(this.offscreenExtraRowsTop > 0)
         {
            this.makeRowsAndColumns(0,0,this.listContent.width,this.listContent.height,0,0,true,this.offscreenExtraRowsTop);
         }
         var _loc12_:Number = !!this.offscreenExtraRowsTop ? Number(this.rowInfo[this.offscreenExtraRowsTop - 1].y + this.rowHeight) : Number(0);
         _loc7_ = this.makeRowsAndColumns(0,_loc12_,this.listContent.width,_loc12_ + this.listContent.heightExcludingOffsets,0,this.offscreenExtraRowsTop);
         if(_loc9_ > 0 && !this.iterator.afterLast)
         {
            if(this.offscreenExtraRowsTop + _loc7_.y - 1 < 0)
            {
               _loc12_ = 0;
            }
            else
            {
               _loc12_ = this.rowInfo[this.offscreenExtraRowsTop + _loc7_.y - 1].y + this.rowInfo[this.offscreenExtraRowsTop + _loc7_.y - 1].height;
            }
            _loc14_ = this.listItems.length;
            if((_loc7_ = this.makeRowsAndColumns(0,_loc12_,this.listContent.width,_loc12_,0,this.offscreenExtraRowsTop + _loc7_.y,true,_loc9_)).y == _loc9_)
            {
               while(_loc7_.y > 0 && this.listItems[this.listItems.length - 1] && this.listItems[this.listItems.length - 1].length == 0)
               {
                  --_loc7_.y;
                  this.listItems.pop();
                  this.rowInfo.pop();
               }
            }
            else if(_loc7_.y < _loc9_)
            {
               if(_loc15_ = this.listItems.length - (_loc14_ + _loc7_.y))
               {
                  _loc16_ = 0;
                  while(_loc16_ < _loc15_)
                  {
                     this.listItems.pop();
                     this.rowInfo.pop();
                     _loc16_++;
                  }
               }
            }
            this.offscreenExtraRowsBottom = _loc7_.y;
         }
         else
         {
            this.offscreenExtraRowsBottom = 0;
         }
         var _loc13_:Number = this.listContent.heightExcludingOffsets;
         this.listContent.topOffset = -this.offscreenExtraRowsTop * this.rowHeight;
         this.listContent.bottomOffset = this.offscreenExtraRowsBottom > 0 ? Number(this.listItems[this.listItems.length - 1][0].y + this.rowHeight - _loc13_ + this.listContent.topOffset) : Number(0);
         this.seekPositionIgnoreError(this.iterator,_loc11_);
         this.adjustListContent(param1,param2);
      }
      
      private function makeRowsAndColumnsWithExtraColumns(param1:Number, param2:Number) : void
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc3_:int = this.offscreenExtraColumns / 2;
         var _loc4_:int = this.offscreenExtraColumns / 2;
         if(this.horizontalScrollPosition > this.collection.length - this.columnCount)
         {
            super.horizontalScrollPosition = Math.max(0,this.collection.length - this.columnCount);
         }
         this.offscreenExtraColumnsLeft = Math.min(_loc3_,this.horizontalScrollPosition);
         var _loc5_:int = this.scrollPositionToIndex(this.horizontalScrollPosition - this.offscreenExtraColumnsLeft,this.verticalScrollPosition);
         this.seekPositionSafely(_loc5_);
         var _loc6_:CursorBookmark = this.iterator.bookmark;
         if(this.offscreenExtraColumnsLeft > 0)
         {
            this.makeRowsAndColumns(0,0,0,this.listContent.height,0,0,true,this.offscreenExtraColumnsLeft);
         }
         var _loc7_:Number = !!this.offscreenExtraColumnsLeft ? Number(this.listItems[0][this.offscreenExtraColumnsLeft - 1].x + this.columnWidth) : Number(0);
         var _loc8_:Point = this.makeRowsAndColumns(_loc7_,0,_loc7_ + this.listContent.widthExcludingOffsets,this.listContent.height,this.offscreenExtraColumnsLeft,0);
         if(_loc4_ > 0 && !this.iterator.afterLast)
         {
            if(this.offscreenExtraColumnsLeft + _loc8_.x - 1 < 0)
            {
               _loc7_ = 0;
            }
            else
            {
               _loc7_ = this.listItems[0][this.offscreenExtraColumnsLeft + _loc8_.x - 1].x + this.columnWidth;
            }
            _loc10_ = this.listItems[0].length;
            if((_loc8_ = this.makeRowsAndColumns(_loc7_,0,_loc7_,this.listContent.height,this.offscreenExtraColumnsLeft + _loc8_.x,0,true,_loc4_)).x < _loc4_)
            {
               if(_loc11_ = this.listItems[0].length - (_loc10_ + _loc8_.x))
               {
                  _loc12_ = 0;
                  while(_loc12_ < this.listItems.length)
                  {
                     _loc13_ = 0;
                     while(_loc13_ < _loc11_)
                     {
                        this.listItems[_loc12_].pop();
                        _loc13_++;
                     }
                     _loc12_++;
                  }
               }
            }
            this.offscreenExtraColumnsRight = _loc8_.x;
         }
         else
         {
            this.offscreenExtraColumnsRight = 0;
         }
         var _loc9_:Number = this.listContent.widthExcludingOffsets;
         this.listContent.leftOffset = -this.offscreenExtraColumnsLeft * this.columnWidth;
         this.listContent.rightOffset = this.offscreenExtraColumnsRight > 0 ? Number(this.listItems[0][this.listItems[0].length - 1].x + this.columnWidth - _loc9_ + this.listContent.leftOffset) : Number(0);
         this.iterator.seek(_loc6_,0);
         this.adjustListContent(param1,param2);
      }
      
      public function get allowMultipleSelection() : Boolean
      {
         return this._allowMultipleSelection;
      }
      
      public function set allowMultipleSelection(param1:Boolean) : void
      {
         this._allowMultipleSelection = param1;
      }
      
      public function get columnCount() : int
      {
         return this._columnCount;
      }
      
      public function set columnCount(param1:int) : void
      {
         this.explicitColumnCount = param1;
         if(this._columnCount != param1)
         {
            this.setColumnCount(param1);
            this.columnCountChanged = true;
            invalidateProperties();
            invalidateSize();
            this.itemsSizeChanged = true;
            invalidateDisplayList();
            dispatchEvent(new Event("columnCountChanged"));
         }
      }
      
      mx_internal function setColumnCount(param1:int) : void
      {
         this._columnCount = param1;
      }
      
      public function get columnWidth() : Number
      {
         return this._columnWidth;
      }
      
      public function set columnWidth(param1:Number) : void
      {
         this.explicitColumnWidth = param1;
         if(this._columnWidth != param1)
         {
            this.setColumnWidth(param1);
            invalidateSize();
            this.itemsSizeChanged = true;
            invalidateDisplayList();
            dispatchEvent(new Event("columnWidthChanged"));
         }
      }
      
      mx_internal function setColumnWidth(param1:Number) : void
      {
         this._columnWidth = param1;
      }
      
      [Bindable("dataChange")]
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         if(this._listData && this._listData is DataGridListData)
         {
            this.selectedItem = this._data[DataGridListData(this._listData).dataField];
         }
         else if(this._listData is ListData && ListData(this._listData).labelField in this._data)
         {
            this.selectedItem = this._data[ListData(this._listData).labelField];
         }
         else
         {
            this.selectedItem = this._data;
         }
         dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
      }
      
      [Bindable("collectionChange")]
      public function get dataProvider() : Object
      {
         if(this.actualCollection)
         {
            return this.actualCollection;
         }
         return this.collection;
      }
      
      public function set dataProvider(param1:Object) : void
      {
         var _loc3_:XMLList = null;
         var _loc4_:Array = null;
         if(this.collection)
         {
            this.collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler);
         }
         if(param1 is Array)
         {
            this.collection = new ArrayCollection(param1 as Array);
         }
         else if(param1 is ICollectionView)
         {
            this.collection = ICollectionView(param1);
         }
         else if(param1 is IList)
         {
            this.collection = new ListCollectionView(IList(param1));
         }
         else if(param1 is XMLList)
         {
            this.collection = new XMLListCollection(param1 as XMLList);
         }
         else if(param1 is XML)
         {
            _loc3_ = new XMLList();
            _loc3_ += param1;
            this.collection = new XMLListCollection(_loc3_);
         }
         else
         {
            _loc4_ = [];
            if(param1 != null)
            {
               _loc4_.push(param1);
            }
            this.collection = new ArrayCollection(_loc4_);
         }
         this.iterator = this.collection.createCursor();
         this.collectionIterator = this.collection.createCursor();
         this.collection.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,0,true);
         this.clearSelectionData();
         var _loc2_:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
         _loc2_.kind = CollectionEventKind.RESET;
         this.collectionChangeHandler(_loc2_);
         dispatchEvent(_loc2_);
         this.itemsNeedMeasurement = true;
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
      }
      
      [Bindable("dataTipFieldChanged")]
      public function get dataTipField() : String
      {
         return this._dataTipField;
      }
      
      public function set dataTipField(param1:String) : void
      {
         this._dataTipField = param1;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
         dispatchEvent(new Event("dataTipFieldChanged"));
      }
      
      [Bindable("dataTipFunctionChanged")]
      public function get dataTipFunction() : Function
      {
         return this._dataTipFunction;
      }
      
      public function set dataTipFunction(param1:Function) : void
      {
         this._dataTipFunction = param1;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
         dispatchEvent(new Event("dataTipFunctionChanged"));
      }
      
      public function get dragEnabled() : Boolean
      {
         return this._dragEnabled;
      }
      
      public function set dragEnabled(param1:Boolean) : void
      {
         if(this._dragEnabled && !param1)
         {
            removeEventListener(DragEvent.DRAG_START,this.dragStartHandler,false);
            removeEventListener(DragEvent.DRAG_COMPLETE,this.dragCompleteHandler,false);
         }
         this._dragEnabled = param1;
         if(param1)
         {
            addEventListener(DragEvent.DRAG_START,this.dragStartHandler,false,EventPriority.DEFAULT_HANDLER);
            addEventListener(DragEvent.DRAG_COMPLETE,this.dragCompleteHandler,false,EventPriority.DEFAULT_HANDLER);
         }
      }
      
      protected function get dragImage() : IUIComponent
      {
         var _loc1_:ListItemDragProxy = new ListItemDragProxy();
         _loc1_.owner = this;
         _loc1_.moduleFactory = moduleFactory;
         return _loc1_;
      }
      
      protected function get dragImageOffsets() : Point
      {
         var _loc1_:Point = new Point();
         var _loc2_:int = this.listItems.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this.selectedData[this.rowInfo[_loc3_].uid])
            {
               _loc1_.x = this.listItems[_loc3_][0].x;
               _loc1_.y = this.listItems[_loc3_][0].y;
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function get dragMoveEnabled() : Boolean
      {
         return this._dragMoveEnabled;
      }
      
      public function set dragMoveEnabled(param1:Boolean) : void
      {
         this._dragMoveEnabled = param1;
      }
      
      public function get dropEnabled() : Boolean
      {
         return this._dropEnabled;
      }
      
      public function set dropEnabled(param1:Boolean) : void
      {
         if(this._dropEnabled && !param1)
         {
            removeEventListener(DragEvent.DRAG_ENTER,this.dragEnterHandler,false);
            removeEventListener(DragEvent.DRAG_EXIT,this.dragExitHandler,false);
            removeEventListener(DragEvent.DRAG_OVER,this.dragOverHandler,false);
            removeEventListener(DragEvent.DRAG_DROP,this.dragDropHandler,false);
         }
         this._dropEnabled = param1;
         if(param1)
         {
            addEventListener(DragEvent.DRAG_ENTER,this.dragEnterHandler,false,EventPriority.DEFAULT_HANDLER);
            addEventListener(DragEvent.DRAG_EXIT,this.dragExitHandler,false,EventPriority.DEFAULT_HANDLER);
            addEventListener(DragEvent.DRAG_OVER,this.dragOverHandler,false,EventPriority.DEFAULT_HANDLER);
            addEventListener(DragEvent.DRAG_DROP,this.dragDropHandler,false,EventPriority.DEFAULT_HANDLER);
         }
      }
      
      [Bindable("iconFieldChanged")]
      public function get iconField() : String
      {
         return this._iconField;
      }
      
      public function set iconField(param1:String) : void
      {
         this._iconField = param1;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
         dispatchEvent(new Event("iconFieldChanged"));
      }
      
      [Bindable("iconFunctionChanged")]
      public function get iconFunction() : Function
      {
         return this._iconFunction;
      }
      
      public function set iconFunction(param1:Function) : void
      {
         this._iconFunction = param1;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
         dispatchEvent(new Event("iconFunctionChanged"));
      }
      
      public function get itemRenderer() : IFactory
      {
         return this._itemRenderer;
      }
      
      public function set itemRenderer(param1:IFactory) : void
      {
         this._itemRenderer = param1;
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
         this.itemsSizeChanged = true;
         this.itemsNeedMeasurement = true;
         this.rendererChanged = true;
         dispatchEvent(new Event("itemRendererChanged"));
      }
      
      [Bindable("labelFieldChanged")]
      public function get labelField() : String
      {
         return this._labelField;
      }
      
      public function set labelField(param1:String) : void
      {
         this._labelField = param1;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
         dispatchEvent(new Event("labelFieldChanged"));
      }
      
      [Bindable("labelFunctionChanged")]
      public function get labelFunction() : Function
      {
         return this._labelFunction;
      }
      
      public function set labelFunction(param1:Function) : void
      {
         this._labelFunction = param1;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
         dispatchEvent(new Event("labelFunctionChanged"));
      }
      
      [Bindable("dataChange")]
      public function get listData() : BaseListData
      {
         return this._listData;
      }
      
      public function set listData(param1:BaseListData) : void
      {
         this._listData = param1;
      }
      
      public function get offscreenExtraRowsOrColumns() : int
      {
         return this._offscreenExtraRowsOrColumns;
      }
      
      public function set offscreenExtraRowsOrColumns(param1:int) : void
      {
         param1 = Math.max(param1,0);
         if(param1 % 2)
         {
            param1++;
         }
         if(this._offscreenExtraRowsOrColumns == param1)
         {
            return;
         }
         this._offscreenExtraRowsOrColumns = param1;
         this.offscreenExtraRowsOrColumnsChanged = true;
         invalidateProperties();
      }
      
      public function get nullItemRenderer() : IFactory
      {
         return this._nullItemRenderer;
      }
      
      public function set nullItemRenderer(param1:IFactory) : void
      {
         this._nullItemRenderer = param1;
         invalidateSize();
         invalidateDisplayList();
         this.itemsSizeChanged = true;
         this.rendererChanged = true;
         dispatchEvent(new Event("nullItemRendererChanged"));
      }
      
      public function get rowCount() : int
      {
         return this._rowCount;
      }
      
      public function set rowCount(param1:int) : void
      {
         this.explicitRowCount = param1;
         if(this._rowCount != param1)
         {
            this.setRowCount(param1);
            this.rowCountChanged = true;
            invalidateProperties();
            invalidateSize();
            this.itemsSizeChanged = true;
            invalidateDisplayList();
            dispatchEvent(new Event("rowCountChanged"));
         }
      }
      
      protected function setRowCount(param1:int) : void
      {
         this._rowCount = param1;
      }
      
      public function get rowHeight() : Number
      {
         return this._rowHeight;
      }
      
      public function set rowHeight(param1:Number) : void
      {
         this.explicitRowHeight = param1;
         if(this._rowHeight != param1)
         {
            this.setRowHeight(param1);
            invalidateSize();
            this.itemsSizeChanged = true;
            invalidateDisplayList();
            dispatchEvent(new Event("rowHeightChanged"));
         }
      }
      
      protected function setRowHeight(param1:Number) : void
      {
         this._rowHeight = param1;
      }
      
      public function get selectable() : Boolean
      {
         return this._selectable;
      }
      
      public function set selectable(param1:Boolean) : void
      {
         this._selectable = param1;
      }
      
      [Bindable("valueCommit")]
      [Bindable("change")]
      public function get selectedIndex() : int
      {
         return this._selectedIndex;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(!this.collection || this.collection.length == 0)
         {
            this._selectedIndex = param1;
            this.bSelectionChanged = true;
            this.bSelectedIndexChanged = true;
            invalidateDisplayList();
            return;
         }
         this.commitSelectedIndex(param1);
      }
      
      [Bindable("valueCommit")]
      [Bindable("change")]
      public function get selectedIndices() : Array
      {
         if(this.bSelectedIndicesChanged)
         {
            return this._selectedIndices;
         }
         return this.copySelectedItems(false);
      }
      
      public function set selectedIndices(param1:Array) : void
      {
         if(!this.collection || this.collection.length == 0)
         {
            this._selectedIndices = param1;
            this.bSelectedIndicesChanged = true;
            this.bSelectionChanged = true;
            invalidateDisplayList();
            return;
         }
         this.commitSelectedIndices(param1);
      }
      
      [Bindable("valueCommit")]
      [Bindable("change")]
      public function get selectedItem() : Object
      {
         return this._selectedItem;
      }
      
      public function set selectedItem(param1:Object) : void
      {
         if(!this.collection || this.collection.length == 0)
         {
            this._selectedItem = param1;
            this.bSelectedItemChanged = true;
            this.bSelectionChanged = true;
            invalidateDisplayList();
            return;
         }
         this.commitSelectedItem(param1);
      }
      
      [Bindable("valueCommit")]
      [Bindable("change")]
      public function get selectedItems() : Array
      {
         return !!this.bSelectedItemsChanged ? this._selectedItems : this.copySelectedItems();
      }
      
      public function set selectedItems(param1:Array) : void
      {
         if(!this.collection || this.collection.length == 0)
         {
            this._selectedItems = param1;
            this.bSelectedItemsChanged = true;
            this.bSelectionChanged = true;
            invalidateDisplayList();
            return;
         }
         this.commitSelectedItems(param1);
      }
      
      [Bindable("selectedItemsCompareFunctionChanged")]
      public function get selectedItemsCompareFunction() : Function
      {
         return this._selectedItemsCompareFunction;
      }
      
      public function set selectedItemsCompareFunction(param1:Function) : void
      {
         this._selectedItemsCompareFunction = param1;
         dispatchEvent(new Event("selectedItemsCompareFunctionChanged"));
      }
      
      [Bindable("showDataTipsChanged")]
      public function get showDataTips() : Boolean
      {
         return this._showDataTips;
      }
      
      public function set showDataTips(param1:Boolean) : void
      {
         this._showDataTips = param1;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
         dispatchEvent(new Event("showDataTipsChanged"));
      }
      
      [Bindable("valueCommit")]
      [Bindable("change")]
      public function get value() : Object
      {
         var _loc1_:Object = this.selectedItem;
         if(!_loc1_)
         {
            return null;
         }
         if(typeof _loc1_ != "object")
         {
            return _loc1_;
         }
         return _loc1_.data != null ? _loc1_.data : _loc1_.label;
      }
      
      public function get variableRowHeight() : Boolean
      {
         return this._variableRowHeight;
      }
      
      public function set variableRowHeight(param1:Boolean) : void
      {
         this._variableRowHeight = param1;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
         dispatchEvent(new Event("variableRowHeightChanged"));
      }
      
      public function get wordWrap() : Boolean
      {
         return this._wordWrap;
      }
      
      public function set wordWrap(param1:Boolean) : void
      {
         if(param1 == this._wordWrap)
         {
            return;
         }
         this._wordWrap = param1;
         this.wordWrapChanged = true;
         this.itemsSizeChanged = true;
         invalidateDisplayList();
         dispatchEvent(new Event("wordWrapChanged"));
      }
      
      override protected function initializeAccessibility() : void
      {
         if(ListBase.createAccessibilityImplementation != null)
         {
            ListBase.createAccessibilityImplementation(this);
         }
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         if(!this.listContent)
         {
            this.listContent = new ListBaseContentHolder(this);
            this.listContent.styleName = new StyleProxy(this,this.listContentStyleFilters);
            addChild(this.listContent);
         }
         if(!this.selectionLayer)
         {
            this.selectionLayer = this.listContent.selectionLayer;
         }
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         super.commitProperties();
         if(this.listContent && this.listContent.iterator != this.iterator)
         {
            this.listContent.iterator = this.iterator;
         }
         if(this.cachedPaddingTopInvalid)
         {
            this.cachedPaddingTopInvalid = false;
            this.cachedPaddingTop = getStyle("paddingTop");
            this.itemsSizeChanged = true;
            invalidateDisplayList();
         }
         if(this.cachedPaddingBottomInvalid)
         {
            this.cachedPaddingBottomInvalid = false;
            this.cachedPaddingBottom = getStyle("paddingBottom");
            this.itemsSizeChanged = true;
            invalidateDisplayList();
         }
         if(this.cachedVerticalAlignInvalid)
         {
            this.cachedVerticalAlignInvalid = false;
            this.cachedVerticalAlign = getStyle("verticalAlign");
            this.itemsSizeChanged = true;
            invalidateDisplayList();
         }
         if(this.columnCountChanged)
         {
            if(this._columnCount < 1)
            {
               this._columnCount = this.defaultColumnCount;
            }
            if(!isNaN(explicitWidth) && isNaN(this.explicitColumnWidth) && this.explicitColumnCount > 0)
            {
               this.setColumnWidth((explicitWidth - viewMetrics.left - viewMetrics.right) / this.columnCount);
            }
            this.columnCountChanged = false;
         }
         if(this.rowCountChanged)
         {
            if(this._rowCount < 1)
            {
               this._rowCount = this.defaultRowCount;
            }
            if(!isNaN(explicitHeight) && isNaN(this.explicitRowHeight) && this.explicitRowCount > 0)
            {
               this.setRowHeight((explicitHeight - viewMetrics.top - viewMetrics.bottom) / this.rowCount);
            }
            this.rowCountChanged = false;
         }
         if(this.offscreenExtraRowsOrColumnsChanged)
         {
            this.adjustOffscreenRowsAndColumns();
            if(this.iterator)
            {
               _loc1_ = Math.min(this.offscreenExtraColumns / 2,this.horizontalScrollPosition);
               _loc2_ = Math.min(this.offscreenExtraRows / 2,this.verticalScrollPosition);
               _loc3_ = this.scrollPositionToIndex(this.horizontalScrollPosition - _loc1_,this.verticalScrollPosition - _loc2_);
               this.seekPositionSafely(_loc3_);
               this.invalidateList();
            }
            this.offscreenExtraRowsOrColumnsChanged = false;
         }
      }
      
      override protected function measure() : void
      {
         super.measure();
         var _loc1_:EdgeMetrics = viewMetrics;
         var _loc2_:int = this.explicitColumnCount < 1 ? int(this.defaultColumnCount) : int(this.explicitColumnCount);
         var _loc3_:int = this.explicitRowCount < 1 ? int(this.defaultRowCount) : int(this.explicitRowCount);
         if(!isNaN(this.explicitRowHeight))
         {
            measuredHeight = this.explicitRowHeight * _loc3_ + _loc1_.top + _loc1_.bottom;
            measuredMinHeight = this.explicitRowHeight * Math.min(_loc3_,2) + _loc1_.top + _loc1_.bottom;
         }
         else
         {
            measuredHeight = this.rowHeight * _loc3_ + _loc1_.top + _loc1_.bottom;
            measuredMinHeight = this.rowHeight * Math.min(_loc3_,2) + _loc1_.top + _loc1_.bottom;
         }
         if(!isNaN(this.explicitColumnWidth))
         {
            measuredWidth = this.explicitColumnWidth * _loc2_ + _loc1_.left + _loc1_.right;
            measuredMinWidth = this.explicitColumnWidth * Math.min(_loc2_,1) + _loc1_.left + _loc1_.right;
         }
         else
         {
            measuredWidth = this.columnWidth * _loc2_ + _loc1_.left + _loc1_.right;
            measuredMinWidth = this.columnWidth * Math.min(_loc2_,1) + _loc1_.left + _loc1_.right;
         }
         if(verticalScrollPolicy == ScrollPolicy.AUTO && verticalScrollBar && verticalScrollBar.visible)
         {
            measuredWidth -= verticalScrollBar.minWidth;
            measuredMinWidth -= verticalScrollBar.minWidth;
         }
         if(horizontalScrollPolicy == ScrollPolicy.AUTO && horizontalScrollBar && horizontalScrollBar.visible)
         {
            measuredHeight -= horizontalScrollBar.minHeight;
            measuredMinHeight -= horizontalScrollBar.minHeight;
         }
      }
      
      override public function validateDisplayList() : void
      {
         var _loc1_:ISystemManager = null;
         oldLayoutDirection = layoutDirection;
         if(mx_internal::invalidateDisplayListFlag)
         {
            _loc1_ = parent as ISystemManager;
            if(_loc1_)
            {
               if(_loc1_ == systemManager.topLevelSystemManager && _loc1_.document != this)
               {
                  setActualSize(getExplicitOrMeasuredWidth(),getExplicitOrMeasuredHeight());
               }
            }
            validateMatrix();
            if(this.runDataEffectNextUpdate)
            {
               this.runDataEffectNextUpdate = false;
               this.runningDataEffect = true;
               this.initiateDataChangeEffect(unscaledWidth,unscaledHeight);
            }
            else
            {
               this.updateDisplayList(unscaledWidth,unscaledHeight);
            }
            invalidateDisplayListFlag = false;
         }
         else
         {
            validateMatrix();
         }
      }
      
      protected function initiateDataChangeEffect(param1:Number, param2:Number) : void
      {
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:Object = null;
         this.actualCollection = this.collection;
         this.actualIterator = this.iterator;
         this.collection = this.modifiedCollectionView;
         this.modifiedCollectionView.showPreservedState = true;
         this.listContent.iterator = this.iterator = this.collection.createCursor();
         var _loc3_:int = this.scrollPositionToIndex(this.horizontalScrollPosition - this.offscreenExtraColumnsLeft,this.verticalScrollPosition - this.offscreenExtraRowsTop);
         this.iterator.seek(CursorBookmark.FIRST,_loc3_);
         this.updateDisplayList(param1,param2);
         var _loc4_:Array = [];
         var _loc5_:Dictionary = new Dictionary(true);
         var _loc6_:int = 0;
         while(_loc6_ < this.listItems.length)
         {
            if((_loc9_ = this.listItems[_loc6_]) && _loc9_.length > 0)
            {
               _loc10_ = 0;
               while(_loc10_ < _loc9_.length)
               {
                  if(_loc11_ = _loc9_[_loc10_])
                  {
                     _loc4_.push(_loc11_);
                     _loc5_[_loc11_] = true;
                  }
                  _loc10_++;
               }
            }
            _loc6_++;
         }
         this.cachedItemsChangeEffect.targets = _loc4_;
         if(this.cachedItemsChangeEffect.effectTargetHost != this)
         {
            this.cachedItemsChangeEffect.effectTargetHost = this;
         }
         this.cachedItemsChangeEffect.captureStartValues();
         this.modifiedCollectionView.showPreservedState = false;
         this.iterator.seek(CursorBookmark.FIRST,_loc3_);
         this.itemsSizeChanged = true;
         this.updateDisplayList(param1,param2);
         var _loc7_:Array = [];
         var _loc8_:Array = this.cachedItemsChangeEffect.targets;
         _loc6_ = 0;
         while(_loc6_ < this.listItems.length)
         {
            if((_loc9_ = this.listItems[_loc6_]) && _loc9_.length > 0)
            {
               _loc10_ = 0;
               while(_loc10_ < _loc9_.length)
               {
                  if((_loc11_ = _loc9_[_loc10_]) && !_loc5_[_loc11_])
                  {
                     _loc8_.push(_loc11_);
                     _loc7_.push(_loc11_);
                  }
                  _loc10_++;
               }
            }
            _loc6_++;
         }
         if(_loc7_.length > 0)
         {
            this.cachedItemsChangeEffect.targets = _loc8_;
            this.cachedItemsChangeEffect.captureMoreStartValues(_loc7_);
         }
         this.cachedItemsChangeEffect.captureEndValues();
         this.modifiedCollectionView.showPreservedState = true;
         this.iterator.seek(CursorBookmark.FIRST,_loc3_);
         this.itemsSizeChanged = true;
         this.updateDisplayList(param1,param2);
         this.initiateSelectionTracking(_loc8_);
         this.cachedItemsChangeEffect.addEventListener(EffectEvent.EFFECT_END,this.finishDataChangeEffect);
         this.cachedItemsChangeEffect.play();
      }
      
      private function initiateSelectionTracking(param1:Array) : void
      {
         var _loc3_:IListItemRenderer = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1[_loc2_] as IListItemRenderer;
            if(this.selectedData[this.itemToUID(_loc3_.data)])
            {
               _loc3_.addEventListener(MoveEvent.MOVE,this.rendererMoveHandler);
               this.trackedRenderers.push(_loc3_);
            }
            _loc2_++;
         }
      }
      
      private function terminateSelectionTracking() : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.trackedRenderers.length)
         {
            _loc2_ = this.trackedRenderers[_loc1_] as IListItemRenderer;
            _loc2_.removeEventListener(MoveEvent.MOVE,this.rendererMoveHandler);
            _loc1_++;
         }
         this.trackedRenderers = [];
      }
      
      public function removeDataEffectItem(param1:Object) : void
      {
         if(this.modifiedCollectionView)
         {
            this.modifiedCollectionView.removeItem(this.dataItemWrappersByRenderer[param1]);
            this.iterator.seek(CursorBookmark.CURRENT);
            if(mx_internal::invalidateDisplayListFlag)
            {
               callLater(this.invalidateList);
            }
            else
            {
               this.invalidateList();
            }
         }
      }
      
      public function addDataEffectItem(param1:Object) : void
      {
         if(this.modifiedCollectionView)
         {
            this.modifiedCollectionView.addItem(this.dataItemWrappersByRenderer[param1]);
         }
         if(this.iterator.afterLast)
         {
            this.iterator.seek(CursorBookmark.FIRST);
         }
         else
         {
            this.iterator.seek(CursorBookmark.CURRENT);
         }
         if(mx_internal::invalidateDisplayListFlag)
         {
            callLater(this.invalidateList);
         }
         else
         {
            this.invalidateList();
         }
      }
      
      public function unconstrainRenderer(param1:Object) : void
      {
         this.unconstrainedRenderers[param1] = true;
      }
      
      public function getRendererSemanticValue(param1:Object, param2:String) : Object
      {
         return this.modifiedCollectionView.getSemantics(this.dataItemWrappersByRenderer[param1]) == param2;
      }
      
      protected function isRendererUnconstrained(param1:Object) : Boolean
      {
         return this.unconstrainedRenderers[param1] != null;
      }
      
      protected function finishDataChangeEffect(param1:EffectEvent) : void
      {
         this.collection = this.actualCollection;
         this.actualCollection = null;
         this.modifiedCollectionView = null;
         this.listContent.iterator = this.iterator = this.actualIterator;
         this.runningDataEffect = false;
         this.unconstrainedRenderers = new Dictionary();
         this.terminateSelectionTracking();
         this.reKeyVisibleData();
         var _loc2_:int = this.scrollPositionToIndex(this.horizontalScrollPosition - this.offscreenExtraColumnsLeft,this.verticalScrollPosition - this.offscreenExtraRowsTop);
         this.iterator.seek(CursorBookmark.FIRST,_loc2_);
         callLater(this.cleanupAfterDataChangeEffect);
      }
      
      private function cleanupAfterDataChangeEffect() : void
      {
         if(this.runningDataEffect || this.runDataEffectNextUpdate)
         {
            return;
         }
         var _loc1_:int = this.scrollPositionToIndex(this.horizontalScrollPosition - this.offscreenExtraColumnsLeft,this.verticalScrollPosition - this.offscreenExtraRowsTop);
         this.iterator.seek(CursorBookmark.FIRST,_loc1_);
         this.dataEffectCompleted = true;
         this.itemsSizeChanged = true;
         this.invalidateList();
         this.dataItemWrappersByRenderer = new Dictionary();
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:CursorBookmark = null;
         var _loc6_:int = 0;
         super.updateDisplayList(param1,param2);
         if(this.oldUnscaledWidth == param1 && this.oldUnscaledHeight == param2 && !this.itemsSizeChanged && !this.bSelectionChanged && !scrollAreaChanged)
         {
            return;
         }
         if(this.oldUnscaledWidth != param1)
         {
            this.itemsSizeChanged = true;
         }
         this.removeClipMask();
         var _loc4_:Graphics;
         (_loc4_ = this.selectionLayer.graphics).clear();
         if(this.listContent.width > 0 && this.listContent.height > 0)
         {
            _loc4_.beginFill(8421504,0);
            _loc4_.drawRect(0,0,this.listContent.width,this.listContent.height);
            _loc4_.endFill();
         }
         if(this.rendererChanged)
         {
            this.purgeItemRenderers();
         }
         else if(this.dataEffectCompleted)
         {
            this.partialPurgeItemRenderers();
         }
         this.adjustListContent(param1,param2);
         var _loc5_:Boolean;
         if(_loc5_ = this.collection && this.collection.length > 0)
         {
            this.adjustScrollPosition();
         }
         if(this.oldUnscaledWidth == param1 && !scrollAreaChanged && !this.itemsSizeChanged && this.listItems.length > 0 && this.iterator && this.columnCount == 1)
         {
            _loc6_ = this.listItems.length - 1;
            if(this.oldUnscaledHeight > param2)
            {
               this.reduceRows(_loc6_);
            }
            else
            {
               this.makeAdditionalRows(_loc6_);
            }
         }
         else
         {
            if(this.iterator)
            {
               _loc3_ = this.iterator.bookmark;
            }
            this.clearIndicators();
            this.rendererTrackingSuspended = true;
            if(this.iterator)
            {
               if(int(this.offscreenExtraColumns) || int(this.offscreenExtraColumnsLeft) || this.offscreenExtraColumnsRight)
               {
                  this.makeRowsAndColumnsWithExtraColumns(param1,param2);
               }
               else
               {
                  this.makeRowsAndColumnsWithExtraRows(param1,param2);
               }
            }
            else
            {
               this.makeRowsAndColumns(0,0,this.listContent.width,this.listContent.height,0,0);
            }
            this.rendererTrackingSuspended = false;
            this.seekPositionIgnoreError(this.iterator,_loc3_);
         }
         this.oldUnscaledWidth = param1;
         this.oldUnscaledHeight = param2;
         this.configureScrollBars();
         this.addClipMask(true);
         this.itemsSizeChanged = false;
         this.wordWrapChanged = false;
         this.adjustSelectionSettings(_loc5_);
         if(this.keySelectionPending && this.iteratorValid)
         {
            this.keySelectionPending = false;
            this.finishKeySelection();
         }
      }
      
      protected function adjustListContent(param1:Number = -1, param2:Number = -1) : void
      {
         if(param2 < 0)
         {
            param2 = this.oldUnscaledHeight;
            param1 = this.oldUnscaledWidth;
         }
         var _loc3_:Number = viewMetrics.left + this.listContent.leftOffset;
         var _loc4_:Number = viewMetrics.top + this.listContent.topOffset;
         this.listContent.move(_loc3_,_loc4_);
         var _loc5_:Number = Math.max(0,this.listContent.rightOffset) - _loc3_ - viewMetrics.right;
         var _loc6_:Number = Math.max(0,this.listContent.bottomOffset) - _loc4_ - viewMetrics.bottom;
         this.listContent.setActualSize(param1 + _loc5_,param2 + _loc6_);
      }
      
      private function adjustScrollPosition() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc1_:Boolean = false;
         if(!isNaN(this.horizontalScrollPositionPending))
         {
            _loc1_ = true;
            _loc2_ = Math.min(this.horizontalScrollPositionPending,maxHorizontalScrollPosition);
            this.horizontalScrollPositionPending = NaN;
            super.horizontalScrollPosition = _loc2_;
         }
         if(!isNaN(this.verticalScrollPositionPending))
         {
            _loc1_ = true;
            _loc3_ = Math.min(this.verticalScrollPositionPending,maxVerticalScrollPosition);
            this.verticalScrollPositionPending = NaN;
            super.verticalScrollPosition = _loc3_;
         }
         if(_loc1_)
         {
            _loc4_ = this.scrollPositionToIndex(this.horizontalScrollPosition,this.verticalScrollPosition - this.offscreenExtraRowsTop);
            this.seekPositionSafely(_loc4_);
         }
      }
      
      mx_internal function adjustOffscreenRowsAndColumns() : void
      {
         this.offscreenExtraColumns = 0;
         this.offscreenExtraRows = this.offscreenExtraRowsOrColumns;
      }
      
      protected function purgeItemRenderers() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:Array = null;
         var _loc3_:IListItemRenderer = null;
         var _loc4_:DisplayObject = null;
         var _loc5_:Dictionary = null;
         var _loc6_:* = undefined;
         this.rendererChanged = false;
         while(this.listItems.length)
         {
            _loc2_ = this.listItems.pop();
            while(_loc2_.length)
            {
               _loc3_ = IListItemRenderer(_loc2_.pop());
               if(_loc3_)
               {
                  this.listContent.removeChild(DisplayObject(_loc3_));
                  if(this.dataItemWrappersByRenderer[_loc3_])
                  {
                     delete this.visibleData[this.itemToUID(this.dataItemWrappersByRenderer[_loc3_])];
                  }
                  else
                  {
                     delete this.visibleData[this.itemToUID(_loc3_.data)];
                  }
               }
            }
         }
         while(this.freeItemRenderers.length)
         {
            if((_loc4_ = DisplayObject(this.freeItemRenderers.pop())).parent)
            {
               this.listContent.removeChild(_loc4_);
            }
         }
         for(_loc1_ in this.freeItemRenderersByFactory)
         {
            _loc5_ = this.freeItemRenderersByFactory[_loc1_];
            for(_loc6_ in _loc5_)
            {
               _loc4_ = DisplayObject(_loc6_);
               delete _loc5_[_loc6_];
               if(_loc4_.parent)
               {
                  this.listContent.removeChild(_loc4_);
               }
            }
         }
         this.rowMap = {};
         this.listContent.rowInfo = [];
      }
      
      private function partialPurgeItemRenderers() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:* = null;
         var _loc3_:DisplayObject = null;
         var _loc4_:Dictionary = null;
         var _loc5_:* = undefined;
         this.dataEffectCompleted = false;
         while(this.freeItemRenderers.length)
         {
            _loc3_ = DisplayObject(this.freeItemRenderers.pop());
            if(_loc3_.parent)
            {
               this.listContent.removeChild(_loc3_);
            }
         }
         for(_loc1_ in this.freeItemRenderersByFactory)
         {
            _loc4_ = this.freeItemRenderersByFactory[_loc1_];
            for(_loc5_ in _loc4_)
            {
               _loc3_ = DisplayObject(_loc5_);
               delete _loc4_[_loc5_];
               if(_loc3_.parent)
               {
                  this.listContent.removeChild(_loc3_);
               }
            }
         }
         for(_loc2_ in this.reservedItemRenderers)
         {
            _loc3_ = DisplayObject(this.reservedItemRenderers[_loc2_]);
            if(_loc3_.parent)
            {
               this.listContent.removeChild(_loc3_);
            }
         }
         this.reservedItemRenderers = {};
         this.rowMap = {};
         this.clearVisibleData();
      }
      
      private function reduceRows(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         while(param1 >= 0)
         {
            if(this.rowInfo[param1].y < this.listContent.height)
            {
               break;
            }
            _loc2_ = this.listItems[param1].length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               this.addToFreeItemRenderers(this.listItems[param1][_loc3_]);
               _loc3_++;
            }
            _loc4_ = this.rowInfo[param1].uid;
            delete this.visibleData[_loc4_];
            this.removeIndicators(_loc4_);
            this.listItems.pop();
            this.rowInfo.pop();
            param1--;
         }
      }
      
      private function makeAdditionalRows(param1:int) : void
      {
         var cursorPos:CursorBookmark = null;
         var rowIndex:int = param1;
         if(this.iterator)
         {
            cursorPos = this.iterator.bookmark;
            try
            {
               this.iterator.seek(CursorBookmark.CURRENT,this.listItems.length);
            }
            catch(e:ItemPendingError)
            {
               iteratorValid = false;
            }
         }
         var curY:Number = this.rowInfo[rowIndex].y + this.rowInfo[rowIndex].height;
         this.makeRowsAndColumns(0,curY,this.listContent.width,this.listContent.height,0,rowIndex + 1);
         this.seekPositionIgnoreError(this.iterator,cursorPos);
      }
      
      private function adjustSelectionSettings(param1:Boolean) : void
      {
         if(this.bSelectionChanged)
         {
            this.bSelectionChanged = false;
            if(this.bSelectedIndicesChanged && (param1 || this._selectedIndices == null))
            {
               this.bSelectedIndicesChanged = false;
               this.bSelectedIndexChanged = false;
               this.commitSelectedIndices(this._selectedIndices);
            }
            if(this.bSelectedItemChanged && (param1 || this._selectedItem == null))
            {
               this.bSelectedItemChanged = false;
               this.bSelectedIndexChanged = false;
               this.commitSelectedItem(this._selectedItem);
            }
            if(this.bSelectedItemsChanged && (param1 || this._selectedItems == null))
            {
               this.bSelectedItemsChanged = false;
               this.bSelectedIndexChanged = false;
               this.commitSelectedItems(this._selectedItems);
            }
            if(this.bSelectedIndexChanged && (param1 || this._selectedIndex == -1))
            {
               this.commitSelectedIndex(this._selectedIndex);
               this.bSelectedIndexChanged = false;
            }
         }
      }
      
      private function seekPositionIgnoreError(param1:IViewCursor, param2:CursorBookmark) : void
      {
         if(param1)
         {
            try
            {
               param1.seek(param2,0);
            }
            catch(e:ItemPendingError)
            {
            }
         }
      }
      
      private function seekNextSafely(param1:IViewCursor, param2:int) : Boolean
      {
         var iterator:IViewCursor = param1;
         var pos:int = param2;
         try
         {
            iterator.moveNext();
         }
         catch(e:ItemPendingError)
         {
            lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,pos);
            e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
            iteratorValid = false;
         }
         return this.iteratorValid;
      }
      
      private function seekPreviousSafely(param1:IViewCursor, param2:int) : Boolean
      {
         var iterator:IViewCursor = param1;
         var pos:int = param2;
         try
         {
            iterator.movePrevious();
         }
         catch(e:ItemPendingError)
         {
            lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,pos);
            e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
            iteratorValid = false;
         }
         return this.iteratorValid;
      }
      
      protected function seekPositionSafely(param1:int) : Boolean
      {
         var index:int = param1;
         try
         {
            this.iterator.seek(CursorBookmark.FIRST,index);
            if(!this.iteratorValid)
            {
               this.iteratorValid = true;
               this.lastSeekPending = null;
            }
         }
         catch(e:ItemPendingError)
         {
            lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,index);
            e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
            iteratorValid = false;
         }
         return this.iteratorValid;
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this.IS_ITEM_STYLE[param1])
         {
            this.itemsSizeChanged = true;
            invalidateDisplayList();
         }
         else if(param1 == "paddingTop")
         {
            this.cachedPaddingTopInvalid = true;
            invalidateProperties();
         }
         else if(param1 == "paddingBottom")
         {
            this.cachedPaddingBottomInvalid = true;
            invalidateProperties();
         }
         else if(param1 == "verticalAlign")
         {
            this.cachedVerticalAlignInvalid = true;
            invalidateProperties();
         }
         else if(param1 == "itemsChangeEffect")
         {
            this.cachedItemsChangeEffect = null;
         }
         else if(this.listContent && this.listItems)
         {
            _loc2_ = this.listItems.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = this.listItems[_loc3_].length;
               _loc5_ = 0;
               while(_loc5_ < _loc4_)
               {
                  if(this.listItems[_loc3_][_loc5_])
                  {
                     this.listItems[_loc3_][_loc5_].styleChanged(param1);
                  }
                  _loc5_++;
               }
               _loc3_++;
            }
         }
         super.styleChanged(param1);
         if(mx_internal::invalidateSizeFlag)
         {
            this.itemsNeedMeasurement = true;
            invalidateProperties();
         }
         if(styleManager.isSizeInvalidatingStyle(param1))
         {
            scrollAreaChanged = true;
         }
      }
      
      public function measureWidthOfItems(param1:int = -1, param2:int = 0) : Number
      {
         return NaN;
      }
      
      public function measureHeightOfItems(param1:int = -1, param2:int = 0) : Number
      {
         return NaN;
      }
      
      public function itemToLabel(param1:Object) : String
      {
         if(param1 == null)
         {
            return " ";
         }
         if(this.labelFunction != null)
         {
            return this.labelFunction(param1);
         }
         if(param1 is XML)
         {
            try
            {
               if(param1[this.labelField].length() != 0)
               {
                  param1 = param1[this.labelField];
               }
            }
            catch(e:Error)
            {
            }
         }
         else if(param1 is Object)
         {
            try
            {
               if(param1[this.labelField] != null)
               {
                  param1 = param1[this.labelField];
               }
            }
            catch(e:Error)
            {
            }
         }
         if(param1 is String)
         {
            return String(param1);
         }
         try
         {
            return param1.toString();
         }
         catch(e:Error)
         {
            return " ";
         }
      }
      
      public function itemToDataTip(param1:Object) : String
      {
         if(param1 == null)
         {
            return " ";
         }
         if(this.dataTipFunction != null)
         {
            return this.dataTipFunction(param1);
         }
         if(param1 is XML)
         {
            try
            {
               if(param1[this.dataTipField].length() != 0)
               {
                  param1 = param1[this.dataTipField];
               }
            }
            catch(e:Error)
            {
            }
         }
         else if(param1 is Object)
         {
            try
            {
               if(param1[this.dataTipField] != null)
               {
                  param1 = param1[this.dataTipField];
               }
               else if(param1.label != null)
               {
                  param1 = param1.label;
               }
            }
            catch(e:Error)
            {
            }
         }
         if(param1 is String)
         {
            return String(param1);
         }
         try
         {
            return param1.toString();
         }
         catch(e:Error)
         {
            return " ";
         }
      }
      
      public function itemToIcon(param1:Object) : Class
      {
         var _loc2_:Class = null;
         var _loc3_:* = undefined;
         if(param1 == null)
         {
            return null;
         }
         if(this.iconFunction != null)
         {
            return this.iconFunction(param1);
         }
         if(param1 is XML)
         {
            try
            {
               if(param1[this.iconField].length() != 0)
               {
                  _loc3_ = String(param1[this.iconField]);
                  if(_loc3_ != null)
                  {
                     _loc2_ = Class(systemManager.getDefinitionByName(_loc3_));
                     if(_loc2_)
                     {
                        return _loc2_;
                     }
                     return document[_loc3_];
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
         else if(param1 is Object)
         {
            try
            {
               if(param1[this.iconField] != null)
               {
                  if(param1[this.iconField] is Class)
                  {
                     return param1[this.iconField];
                  }
                  if(param1[this.iconField] is String)
                  {
                     _loc2_ = Class(systemManager.getDefinitionByName(param1[this.iconField]));
                     if(_loc2_)
                     {
                        return _loc2_;
                     }
                     return document[param1[this.iconField]];
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
         return null;
      }
      
      protected function makeRowsAndColumns(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:int, param7:Boolean = false, param8:uint = 0) : Point
      {
         return new Point(0,0);
      }
      
      public function indicesToIndex(param1:int, param2:int) : int
      {
         return param1 * this.columnCount + param2;
      }
      
      protected function indexToRow(param1:int) : int
      {
         return param1;
      }
      
      protected function indexToColumn(param1:int) : int
      {
         return 0;
      }
      
      mx_internal function indicesToItemRenderer(param1:int, param2:int) : IListItemRenderer
      {
         return this.listItems[param1][param2];
      }
      
      protected function itemRendererToIndices(param1:IListItemRenderer) : Point
      {
         if(!param1 || !(param1.name in this.rowMap))
         {
            return null;
         }
         var _loc2_:int = this.rowMap[param1.name].rowIndex;
         var _loc3_:int = this.listItems[_loc2_].length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(this.listItems[_loc2_][_loc4_] == param1)
            {
               break;
            }
            _loc4_++;
         }
         return new Point(_loc4_ + this.horizontalScrollPosition,_loc2_ + this.verticalScrollPosition + this.offscreenExtraRowsTop);
      }
      
      public function indexToItemRenderer(param1:int) : IListItemRenderer
      {
         var _loc2_:int = this.verticalScrollPosition - this.offscreenExtraRowsTop;
         if(param1 < _loc2_ || param1 >= _loc2_ + this.listItems.length)
         {
            return null;
         }
         return this.listItems[param1 - _loc2_][0];
      }
      
      public function itemRendererToIndex(param1:IListItemRenderer) : int
      {
         var _loc2_:int = 0;
         if(param1.name in this.rowMap)
         {
            _loc2_ = this.rowMap[param1.name].rowIndex;
            return _loc2_ + this.verticalScrollPosition - this.offscreenExtraRowsTop;
         }
         return int.MIN_VALUE;
      }
      
      protected function itemToUID(param1:Object) : String
      {
         if(param1 == null)
         {
            return "null";
         }
         return UIDUtil.getUID(param1);
      }
      
      protected function UIDToItemRenderer(param1:String) : IListItemRenderer
      {
         if(!this.listContent)
         {
            return null;
         }
         return this.visibleData[param1];
      }
      
      public function itemToItemRenderer(param1:Object) : IListItemRenderer
      {
         return this.UIDToItemRenderer(this.itemToUID(param1));
      }
      
      public function isItemVisible(param1:Object) : Boolean
      {
         return this.itemToItemRenderer(param1) != null;
      }
      
      protected function mouseEventToItemRenderer(param1:MouseEvent) : IListItemRenderer
      {
         return this.mouseEventToItemRendererOrEditor(param1);
      }
      
      mx_internal function mouseEventToItemRendererOrEditor(param1:MouseEvent) : IListItemRenderer
      {
         var _loc3_:Point = null;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         if(_loc2_ == this.listContent)
         {
            _loc3_ = new Point(param1.stageX,param1.stageY);
            _loc3_ = this.listContent.globalToLocal(_loc3_);
            _loc4_ = 0;
            _loc5_ = this.listItems.length;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(this.listItems[_loc6_].length)
               {
                  if(_loc3_.y < _loc4_ + this.rowInfo[_loc6_].height)
                  {
                     if((_loc7_ = this.listItems[_loc6_].length) == 1)
                     {
                        return this.listItems[_loc6_][0];
                     }
                     _loc8_ = Math.floor(_loc3_.x / this.columnWidth);
                     return this.listItems[_loc6_][_loc8_];
                  }
               }
               _loc4_ += this.rowInfo[_loc6_].height;
               _loc6_++;
            }
         }
         else if(_loc2_ == this.highlightIndicator)
         {
            return this.lastHighlightItemRenderer;
         }
         while(_loc2_ && _loc2_ != this)
         {
            if(_loc2_ is IListItemRenderer && _loc2_.parent == this.listContent)
            {
               if(_loc2_.visible)
               {
                  return IListItemRenderer(_loc2_);
               }
               break;
            }
            if(_loc2_ is IUIComponent)
            {
               _loc2_ = IUIComponent(_loc2_).owner;
            }
            else
            {
               _loc2_ = _loc2_.parent;
            }
         }
         return null;
      }
      
      mx_internal function hasOnlyTextRenderers() : Boolean
      {
         if(this.listItems.length == 0)
         {
            return true;
         }
         var _loc1_:Array = this.listItems[this.listItems.length - 1];
         var _loc2_:int = _loc1_.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(!(_loc1_[_loc3_] is IUITextField))
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public function itemRendererContains(param1:IListItemRenderer, param2:DisplayObject) : Boolean
      {
         if(!param2)
         {
            return false;
         }
         if(!param1)
         {
            return false;
         }
         return param1.owns(param2);
      }
      
      protected function addToFreeItemRenderers(param1:IListItemRenderer) : void
      {
         DisplayObject(param1).visible = false;
         var _loc2_:IFactory = this.factoryMap[param1];
         var _loc3_:ItemWrapper = this.dataItemWrappersByRenderer[param1];
         var _loc4_:String = !!_loc3_ ? this.itemToUID(_loc3_) : this.itemToUID(param1.data);
         if(this.visibleData[_loc4_] == param1)
         {
            delete this.visibleData[_loc4_];
         }
         if(_loc3_)
         {
            this.reservedItemRenderers[this.itemToUID(_loc3_)] = param1;
         }
         else
         {
            if(!this.freeItemRenderersByFactory)
            {
               this.freeItemRenderersByFactory = new Dictionary(true);
            }
            if(this.freeItemRenderersByFactory[_loc2_] == undefined)
            {
               this.freeItemRenderersByFactory[_loc2_] = new Dictionary(true);
            }
            this.freeItemRenderersByFactory[_loc2_][param1] = 1;
            if(_loc2_ == this.itemRenderer)
            {
               this.freeItemRenderers.push(param1);
            }
         }
         delete this.rowMap[param1.name];
      }
      
      protected function getReservedOrFreeItemRenderer(param1:Object) : IListItemRenderer
      {
         var _loc2_:* = null;
         var _loc3_:String = null;
         var _loc4_:IFactory = null;
         var _loc5_:Dictionary = null;
         var _loc6_:* = undefined;
         if(this.runningDataEffect)
         {
            _loc2_ = IListItemRenderer(this.reservedItemRenderers[_loc3_ = this.itemToUID(param1)]);
         }
         if(_loc2_)
         {
            delete this.reservedItemRenderers[_loc3_];
         }
         else
         {
            _loc4_ = this.getItemRendererFactory(param1);
            if(this.freeItemRenderersByFactory)
            {
               if(_loc4_ == this.itemRenderer)
               {
                  if(this.freeItemRenderers.length)
                  {
                     _loc2_ = this.freeItemRenderers.pop();
                     delete this.freeItemRenderersByFactory[_loc4_][_loc2_];
                  }
               }
               else if(_loc5_ = this.freeItemRenderersByFactory[_loc4_])
               {
                  var _loc7_:int = 0;
                  var _loc8_:* = _loc5_;
                  for(_loc2_ in _loc8_)
                  {
                     delete this.freeItemRenderersByFactory[_loc4_][_loc2_];
                  }
               }
            }
         }
         return _loc2_;
      }
      
      public function getItemRendererFactory(param1:Object) : IFactory
      {
         if(param1 == null)
         {
            return this.nullItemRenderer;
         }
         return this.itemRenderer;
      }
      
      protected function drawRowBackgrounds() : void
      {
      }
      
      protected function drawItem(param1:IListItemRenderer, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false) : void
      {
         var _loc6_:Sprite = null;
         var _loc7_:Graphics = null;
         var _loc12_:Number = NaN;
         var _loc13_:IListItemRenderer = null;
         if(!param1)
         {
            return;
         }
         var _loc8_:ListBaseContentHolder;
         if(!(_loc8_ = DisplayObject(param1).parent as ListBaseContentHolder))
         {
            return;
         }
         var _loc9_:Array = _loc8_.rowInfo;
         var _loc10_:Sprite = _loc8_.selectionLayer;
         var _loc11_:BaseListData;
         if(!(_loc11_ = this.rowMap[param1.name]))
         {
            return;
         }
         if(param3 && (!this.highlightItemRenderer || this.highlightUID != _loc11_.uid))
         {
            if(!this.highlightIndicator)
            {
               _loc6_ = new SpriteAsset();
               _loc10_.addChild(DisplayObject(_loc6_));
               this.highlightIndicator = _loc6_;
            }
            else if(this.highlightIndicator.parent != _loc10_)
            {
               _loc10_.addChild(this.highlightIndicator);
            }
            else
            {
               _loc10_.setChildIndex(DisplayObject(this.highlightIndicator),_loc10_.numChildren - 1);
            }
            if((_loc6_ = this.highlightIndicator) is ILayoutDirectionElement)
            {
               ILayoutDirectionElement(_loc6_).layoutDirection = null;
            }
            this.drawHighlightIndicator(_loc6_,param1.x,_loc9_[_loc11_.rowIndex].y,param1.width,_loc9_[_loc11_.rowIndex].height,getStyle("rollOverColor"),param1);
            this.lastHighlightItemRenderer = this.highlightItemRenderer = param1;
            this.highlightUID = _loc11_.uid;
         }
         else if(!param3 && this.highlightItemRenderer && (_loc11_ && this.highlightUID == _loc11_.uid))
         {
            this.clearHighlightIndicator(this.highlightIndicator,param1);
            this.highlightItemRenderer = null;
            this.highlightUID = null;
         }
         if(param2)
         {
            _loc12_ = !!this.runningDataEffect ? Number(param1.y - this.cachedPaddingTop) : Number(_loc9_[_loc11_.rowIndex].y);
            if(!this.selectionIndicators[_loc11_.uid])
            {
               (_loc6_ = new SpriteAsset()).mouseEnabled = false;
               ILayoutDirectionElement(_loc6_).layoutDirection = null;
               _loc10_.addChild(DisplayObject(_loc6_));
               this.selectionIndicators[_loc11_.uid] = _loc6_;
               this.drawSelectionIndicator(_loc6_,param1.x,_loc12_,param1.width,_loc9_[_loc11_.rowIndex].height,!!enabled ? uint(getStyle("selectionColor")) : uint(getStyle("selectionDisabledColor")),param1);
               if(param5)
               {
                  this.applySelectionEffect(_loc6_,_loc11_.uid,param1);
               }
            }
            else
            {
               if((_loc6_ = this.selectionIndicators[_loc11_.uid]) is ILayoutDirectionElement)
               {
                  ILayoutDirectionElement(_loc6_).layoutDirection = null;
               }
               this.drawSelectionIndicator(_loc6_,param1.x,_loc12_,param1.width,_loc9_[_loc11_.rowIndex].height,!!enabled ? uint(getStyle("selectionColor")) : uint(getStyle("selectionDisabledColor")),param1);
            }
         }
         else if(!param2)
         {
            if(_loc11_ && this.selectionIndicators[_loc11_.uid])
            {
               if(this.selectionTweens[_loc11_.uid])
               {
                  this.selectionTweens[_loc11_.uid].removeEventListener(TweenEvent.TWEEN_UPDATE,this.selectionTween_updateHandler);
                  this.selectionTweens[_loc11_.uid].removeEventListener(TweenEvent.TWEEN_END,this.selectionTween_endHandler);
                  if(this.selectionIndicators[_loc11_.uid].alpha < 1)
                  {
                     Tween.removeTween(this.selectionTweens[_loc11_.uid]);
                  }
                  delete this.selectionTweens[_loc11_.uid];
               }
               _loc10_.removeChild(this.selectionIndicators[_loc11_.uid]);
               delete this.selectionIndicators[_loc11_.uid];
            }
         }
         if(param4)
         {
            if(this.showCaret)
            {
               if(!this.caretIndicator)
               {
                  (_loc6_ = new SpriteAsset()).mouseEnabled = false;
                  _loc10_.addChild(DisplayObject(_loc6_));
                  this.caretIndicator = _loc6_;
               }
               else if(this.caretIndicator.parent != _loc10_)
               {
                  _loc10_.addChild(this.caretIndicator);
               }
               else
               {
                  _loc10_.setChildIndex(DisplayObject(this.caretIndicator),_loc10_.numChildren - 1);
               }
               if((_loc6_ = this.caretIndicator) is ILayoutDirectionElement)
               {
                  ILayoutDirectionElement(_loc6_).layoutDirection = null;
               }
               this.drawCaretIndicator(_loc6_,param1.x,_loc9_[_loc11_.rowIndex].y,param1.width,_loc9_[_loc11_.rowIndex].height,getStyle("selectionColor"),param1);
               _loc13_ = this.caretItemRenderer;
               this.caretItemRenderer = param1;
               this.caretUID = _loc11_.uid;
               if(_loc13_)
               {
                  if(_loc13_ is IFlexDisplayObject)
                  {
                     if(_loc13_ is IInvalidating)
                     {
                        IInvalidating(_loc13_).invalidateDisplayList();
                        IInvalidating(_loc13_).validateNow();
                     }
                  }
                  else if(_loc13_ is IUITextField)
                  {
                     IUITextField(_loc13_).validateNow();
                  }
               }
            }
         }
         else if(!param4 && this.caretItemRenderer && this.caretUID == _loc11_.uid)
         {
            this.clearCaretIndicator(this.caretIndicator,param1);
            this.caretItemRenderer = null;
            this.caretUID = "";
         }
         if(param1 is IFlexDisplayObject)
         {
            if(param1 is IInvalidating)
            {
               IInvalidating(param1).invalidateDisplayList();
               IInvalidating(param1).validateNow();
            }
         }
         else if(param1 is IUITextField)
         {
            IUITextField(param1).validateNow();
         }
      }
      
      protected function drawHighlightIndicator(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint, param7:IListItemRenderer) : void
      {
         var _loc8_:Graphics;
         (_loc8_ = Sprite(param1).graphics).clear();
         _loc8_.beginFill(param6);
         _loc8_.drawRect(0,0,param4,param5);
         _loc8_.endFill();
         param1.x = param2;
         param1.y = param3;
      }
      
      protected function clearHighlightIndicator(param1:Sprite, param2:IListItemRenderer) : void
      {
         if(this.highlightIndicator)
         {
            Sprite(this.highlightIndicator).graphics.clear();
         }
      }
      
      protected function drawSelectionIndicator(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint, param7:IListItemRenderer) : void
      {
         var _loc8_:Graphics;
         (_loc8_ = Sprite(param1).graphics).clear();
         _loc8_.beginFill(param6);
         _loc8_.drawRect(0,0,param4,param5);
         _loc8_.endFill();
         param1.x = param2;
         param1.y = param3;
      }
      
      protected function drawCaretIndicator(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint, param7:IListItemRenderer) : void
      {
         var _loc8_:Graphics;
         (_loc8_ = Sprite(param1).graphics).clear();
         _loc8_.lineStyle(1,param6,1);
         _loc8_.drawRect(0,0,param4 - 1,param5 - 1);
         param1.x = param2;
         param1.y = param3;
      }
      
      protected function clearCaretIndicator(param1:Sprite, param2:IListItemRenderer) : void
      {
         if(this.caretIndicator)
         {
            Sprite(this.caretIndicator).graphics.clear();
         }
      }
      
      protected function clearIndicators() : void
      {
         var _loc1_:* = null;
         for(_loc1_ in this.selectionTweens)
         {
            this.removeIndicators(_loc1_);
         }
         while(this.selectionLayer.numChildren > 0)
         {
            this.selectionLayer.removeChildAt(0);
         }
         this.selectionTweens = {};
         this.selectionIndicators = {};
         this.highlightIndicator = null;
         this.highlightUID = null;
         this.caretIndicator = null;
         this.caretUID = null;
      }
      
      protected function removeIndicators(param1:String) : void
      {
         if(this.selectionTweens[param1])
         {
            this.selectionTweens[param1].removeEventListener(TweenEvent.TWEEN_UPDATE,this.selectionTween_updateHandler);
            this.selectionTweens[param1].removeEventListener(TweenEvent.TWEEN_END,this.selectionTween_endHandler);
            if(this.selectionIndicators[param1].alpha < 1)
            {
               Tween.removeTween(this.selectionTweens[param1]);
            }
            delete this.selectionTweens[param1];
         }
         if(this.selectionIndicators[param1])
         {
            this.selectionIndicators[param1].parent.removeChild(this.selectionIndicators[param1]);
            this.selectionIndicators[param1] = null;
         }
         if(param1 == this.highlightUID)
         {
            this.highlightItemRenderer = null;
            this.highlightUID = null;
            this.clearHighlightIndicator(this.highlightIndicator,this.UIDToItemRenderer(param1));
         }
         if(param1 == this.caretUID)
         {
            this.caretItemRenderer = null;
            this.caretUID = null;
            this.clearCaretIndicator(this.caretIndicator,this.UIDToItemRenderer(param1));
         }
      }
      
      mx_internal function clearHighlight(param1:IListItemRenderer) : void
      {
         var _loc4_:ListEvent = null;
         var _loc2_:String = this.itemToUID(param1.data);
         this.drawItem(this.UIDToItemRenderer(_loc2_),this.isItemSelected(param1.data),false,_loc2_ == this.caretUID);
         var _loc3_:Point = this.itemRendererToIndices(param1);
         if(_loc3_ && this.lastHighlightItemIndices)
         {
            (_loc4_ = new ListEvent(ListEvent.ITEM_ROLL_OUT)).columnIndex = this.lastHighlightItemIndices.x;
            _loc4_.rowIndex = this.lastHighlightItemIndices.y;
            _loc4_.itemRenderer = this.lastHighlightItemRendererAtIndices;
            dispatchEvent(_loc4_);
            this.lastHighlightItemIndices = null;
         }
      }
      
      public function invalidateList() : void
      {
         this.itemsSizeChanged = true;
         invalidateDisplayList();
      }
      
      protected function updateList() : void
      {
         this.removeClipMask();
         var _loc1_:CursorBookmark = !!this.iterator ? this.iterator.bookmark : null;
         this.clearIndicators();
         this.clearVisibleData();
         if(this.iterator)
         {
            if(int(this.offscreenExtraColumns) || int(this.offscreenExtraColumnsLeft) || this.offscreenExtraColumnsRight)
            {
               this.makeRowsAndColumnsWithExtraColumns(unscaledWidth,unscaledHeight);
            }
            else
            {
               this.makeRowsAndColumnsWithExtraRows(unscaledWidth,unscaledHeight);
            }
            this.iterator.seek(_loc1_,0);
         }
         else
         {
            this.makeRowsAndColumns(0,0,this.listContent.width,this.listContent.height,0,0);
         }
         this.drawRowBackgrounds();
         this.configureScrollBars();
         this.addClipMask(true);
      }
      
      protected function clearVisibleData() : void
      {
         this.listContent.visibleData = {};
      }
      
      protected function reKeyVisibleData() : void
      {
         var _loc2_:Object = null;
         var _loc1_:Object = {};
         for each(_loc2_ in this.visibleData)
         {
            if(_loc2_.data)
            {
               _loc1_[this.itemToUID(_loc2_.data)] = _loc2_;
            }
         }
         this.listContent.visibleData = _loc1_;
      }
      
      protected function set allowItemSizeChangeNotification(param1:Boolean) : void
      {
         this.listContent.allowItemSizeChangeNotification = param1;
      }
      
      mx_internal function addClipMask(param1:Boolean) : void
      {
         var _loc10_:DisplayObject = null;
         var _loc11_:Number = NaN;
         if(param1)
         {
            if(horizontalScrollBar && horizontalScrollBar.visible || this.hasOnlyTextRenderers() || this.runningDataEffect || this.listContent.bottomOffset != 0 || this.listContent.topOffset != 0 || this.listContent.leftOffset != 0 || this.listContent.rightOffset != 0)
            {
               this.listContent.mask = maskShape;
               this.selectionLayer.mask = null;
            }
            else
            {
               this.listContent.mask = null;
               this.selectionLayer.mask = maskShape;
            }
         }
         if(this.listContent.mask)
         {
            return;
         }
         var _loc2_:int = this.listItems.length - 1;
         var _loc3_:ListRowInfo = this.rowInfo[_loc2_];
         var _loc4_:Array = this.listItems[_loc2_];
         if(_loc3_.y + _loc3_.height <= this.listContent.height)
         {
            return;
         }
         var _loc5_:int = _loc4_.length;
         var _loc6_:Number = _loc3_.y;
         var _loc7_:Number = this.listContent.width;
         var _loc8_:Number = this.listContent.height - _loc3_.y;
         var _loc9_:int = 0;
         while(_loc9_ < _loc5_)
         {
            _loc11_ = (_loc10_ = _loc4_[_loc9_]).y - _loc6_;
            if(_loc10_ is IUITextField && !IUITextField(_loc10_).embedFonts)
            {
               _loc10_.height = Math.max(_loc8_ - _loc11_,0);
            }
            else
            {
               _loc10_.mask = this.createItemMask(0,_loc6_ + _loc11_,_loc7_,Math.max(_loc8_ - _loc11_,0));
            }
            _loc9_++;
         }
      }
      
      mx_internal function createItemMask(param1:Number, param2:Number, param3:Number, param4:Number, param5:DisplayObjectContainer = null) : DisplayObject
      {
         var _loc6_:Shape = null;
         var _loc7_:Graphics = null;
         if(!this.itemMaskFreeList)
         {
            this.itemMaskFreeList = [];
         }
         if(this.itemMaskFreeList.length > 0)
         {
            if((_loc6_ = this.itemMaskFreeList.pop()).width != param3)
            {
               _loc6_.width = param3;
            }
            if(_loc6_.height != param4)
            {
               _loc6_.height = param4;
            }
         }
         else
         {
            (_loc6_ = new FlexShape()).name = "mask";
            (_loc7_ = _loc6_.graphics).beginFill(16777215);
            _loc7_.drawRect(0,0,param3,param4);
            _loc7_.endFill();
            _loc6_.visible = false;
            if(param5)
            {
               param5.addChild(_loc6_);
            }
            else
            {
               this.listContent.addChild(_loc6_);
            }
         }
         if(_loc6_.x != param1)
         {
            _loc6_.x = param1;
         }
         if(_loc6_.y != param2)
         {
            _loc6_.y = param2;
         }
         return _loc6_;
      }
      
      mx_internal function removeClipMask() : void
      {
         var _loc7_:DisplayObject = null;
         if(this.listContent && this.listContent.mask)
         {
            return;
         }
         var _loc1_:int = this.listItems.length - 1;
         if(_loc1_ < 0)
         {
            return;
         }
         var _loc2_:Number = this.rowInfo[_loc1_].height;
         var _loc3_:ListRowInfo = this.rowInfo[_loc1_];
         var _loc4_:Array;
         var _loc5_:int = (_loc4_ = this.listItems[_loc1_]).length;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            if((_loc7_ = _loc4_[_loc6_]) is IUITextField && !IUITextField(_loc7_).embedFonts)
            {
               if(_loc7_.height != _loc2_ - (_loc7_.y - _loc3_.y))
               {
                  _loc7_.height = _loc2_ - (_loc7_.y - _loc3_.y);
               }
            }
            else if(_loc7_ && _loc7_.mask)
            {
               this.itemMaskFreeList.push(_loc7_.mask);
               _loc7_.mask = null;
            }
            _loc6_++;
         }
      }
      
      public function isItemShowingCaret(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(param1 is String)
         {
            return param1 == this.caretUID;
         }
         return this.itemToUID(param1) == this.caretUID;
      }
      
      public function isItemHighlighted(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         var _loc2_:Boolean = this.highlightUID && this.selectedData[this.highlightUID];
         if(param1 is String)
         {
            return param1 == this.highlightUID && !_loc2_;
         }
         return this.itemToUID(param1) == this.highlightUID && !_loc2_;
      }
      
      public function isItemSelected(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(param1 is String)
         {
            return this.selectedData[param1] != undefined;
         }
         return this.selectedData[this.itemToUID(param1)] != undefined;
      }
      
      public function isItemSelectable(param1:Object) : Boolean
      {
         if(!this.selectable)
         {
            return false;
         }
         if(param1 == null)
         {
            return false;
         }
         return true;
      }
      
      private function calculateSelectedIndexAndItem() : void
      {
         var _loc2_:* = null;
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:* = this.selectedData;
         for(_loc2_ in _loc4_)
         {
            _loc1_ = 1;
         }
         if(!_loc1_)
         {
            this._selectedIndex = -1;
            this._selectedItem = null;
            return;
         }
         this._selectedIndex = this.selectedData[_loc2_].index;
         this._selectedItem = this.selectedData[_loc2_].data;
      }
      
      protected function selectItem(param1:IListItemRenderer, param2:Boolean, param3:Boolean, param4:Boolean = true) : Boolean
      {
         var placeHolder:CursorBookmark = null;
         var index:int = 0;
         var numSelected:int = 0;
         var curSelectionData:ListBaseSelectionData = null;
         var oldAnchorBookmark:CursorBookmark = null;
         var oldAnchorIndex:int = 0;
         var incr:Boolean = false;
         var item:IListItemRenderer = param1;
         var shiftKey:Boolean = param2;
         var ctrlKey:Boolean = param3;
         var transition:Boolean = param4;
         if(!item || !this.isItemSelectable(item.data))
         {
            return false;
         }
         var selectionChange:Boolean = false;
         placeHolder = this.iterator.bookmark;
         index = this.itemRendererToIndex(item);
         var uid:String = this.itemToUID(item.data);
         if(!this.allowMultipleSelection || !shiftKey && !ctrlKey)
         {
            numSelected = 0;
            if(this.allowMultipleSelection)
            {
               curSelectionData = this.firstSelectionData;
               if(curSelectionData != null)
               {
                  numSelected++;
                  if(curSelectionData.nextSelectionData)
                  {
                     numSelected++;
                  }
               }
            }
            if(ctrlKey && this.selectedData[uid])
            {
               selectionChange = true;
               this.clearSelected(transition);
            }
            else if(this._selectedIndex != index || this.bSelectedIndexChanged || this.allowMultipleSelection && numSelected != 1)
            {
               selectionChange = true;
               this.clearSelected(transition);
               this.insertSelectionDataBefore(uid,new ListBaseSelectionData(item.data,index,this.approximate),this.firstSelectionData);
               this.drawItem(this.UIDToItemRenderer(uid),true,uid == this.highlightUID,true,transition);
               this._selectedIndex = index;
               this._selectedItem = item.data;
               this.iterator.seek(CursorBookmark.CURRENT,this._selectedIndex - this.indicesToIndex(this.verticalScrollPosition - this.offscreenExtraRowsTop,this.horizontalScrollPosition - this.offscreenExtraColumnsLeft));
               this.caretIndex = this._selectedIndex;
               this.caretBookmark = this.iterator.bookmark;
               this.anchorIndex = this._selectedIndex;
               this.anchorBookmark = this.iterator.bookmark;
               this.iterator.seek(placeHolder,0);
            }
         }
         else if(shiftKey && this.allowMultipleSelection)
         {
            if(this.anchorBookmark)
            {
               oldAnchorBookmark = this.anchorBookmark;
               oldAnchorIndex = this.anchorIndex;
               incr = this.anchorIndex < index;
               this.clearSelected(false);
               this.caretIndex = index;
               this.caretBookmark = this.iterator.bookmark;
               this.anchorIndex = oldAnchorIndex;
               this.anchorBookmark = oldAnchorBookmark;
               this._selectedIndex = index;
               this._selectedItem = item.data;
               try
               {
                  this.iterator.seek(this.anchorBookmark,0);
               }
               catch(e:ItemPendingError)
               {
                  e.addResponder(new ItemResponder(selectionPendingResultHandler,selectionPendingFailureHandler,new ListBaseSelectionPending(incr,index,item.data,transition,placeHolder,CursorBookmark.CURRENT,0)));
                  iteratorValid = false;
               }
               this.shiftSelectionLoop(incr,this.anchorIndex,item.data,transition,placeHolder);
            }
            selectionChange = true;
         }
         else if(ctrlKey && this.allowMultipleSelection)
         {
            if(this.selectedData[uid])
            {
               this.removeSelectionData(uid);
               this.drawItem(this.UIDToItemRenderer(uid),false,uid == this.highlightUID,true,transition);
               if(item.data == this.selectedItem)
               {
                  this.calculateSelectedIndexAndItem();
               }
            }
            else
            {
               this.insertSelectionDataBefore(uid,new ListBaseSelectionData(item.data,index,this.approximate),this.firstSelectionData);
               this.drawItem(this.UIDToItemRenderer(uid),true,uid == this.highlightUID,true,transition);
               this._selectedIndex = index;
               this._selectedItem = item.data;
            }
            this.iterator.seek(CursorBookmark.CURRENT,index - this.indicesToIndex(this.verticalScrollPosition,this.horizontalScrollPosition));
            this.caretIndex = index;
            this.caretBookmark = this.iterator.bookmark;
            this.anchorIndex = index;
            this.anchorBookmark = this.iterator.bookmark;
            this.iterator.seek(placeHolder,0);
            selectionChange = true;
         }
         return selectionChange;
      }
      
      private function shiftSelectionLoop(param1:Boolean, param2:int, param3:Object, param4:Boolean, param5:CursorBookmark) : void
      {
         var data:Object = null;
         var uid:String = null;
         var incr:Boolean = param1;
         var index:int = param2;
         var stopData:Object = param3;
         var transition:Boolean = param4;
         var placeHolder:CursorBookmark = param5;
         try
         {
            do
            {
               data = this.iterator.current;
               uid = this.itemToUID(data);
               this.insertSelectionDataBefore(uid,new ListBaseSelectionData(data,index,this.approximate),this.firstSelectionData);
               if(this.UIDToItemRenderer(uid))
               {
                  this.drawItem(this.UIDToItemRenderer(uid),true,uid == this.highlightUID,false,transition);
               }
               if(data === stopData)
               {
                  if(this.UIDToItemRenderer(uid))
                  {
                     this.drawItem(this.UIDToItemRenderer(uid),true,uid == this.highlightUID,true,transition);
                  }
                  break;
               }
               if(incr)
               {
                  index++;
               }
               else
               {
                  index--;
               }
            }
            while(!!incr ? Boolean(this.iterator.moveNext()) : Boolean(this.iterator.movePrevious()));
            
         }
         catch(e:ItemPendingError)
         {
            e.addResponder(new ItemResponder(selectionPendingResultHandler,selectionPendingFailureHandler,new ListBaseSelectionPending(incr,index,stopData,transition,placeHolder,CursorBookmark.CURRENT,0)));
            iteratorValid = false;
         }
         try
         {
            this.iterator.seek(placeHolder,0);
            if(!this.iteratorValid)
            {
               this.iteratorValid = true;
               this.lastSeekPending = null;
            }
         }
         catch(e2:ItemPendingError)
         {
            lastSeekPending = new ListBaseSeekPending(placeHolder,0);
            e2.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
         }
      }
      
      protected function clearSelected(param1:Boolean = false) : void
      {
         var _loc2_:* = null;
         var _loc3_:Object = null;
         var _loc4_:IListItemRenderer = null;
         for(_loc2_ in this.selectedData)
         {
            _loc3_ = this.selectedData[_loc2_].data;
            this.removeSelectionData(_loc2_);
            if(_loc4_ = this.UIDToItemRenderer(this.itemToUID(_loc3_)))
            {
               this.drawItem(_loc4_,false,_loc2_ == this.highlightUID,false,param1);
            }
         }
         this.clearSelectionData();
         this._selectedIndex = -1;
         this._selectedItem = null;
         this.caretIndex = -1;
         this.anchorIndex = -1;
         this.caretBookmark = null;
         this.anchorBookmark = null;
      }
      
      protected function moveSelectionHorizontally(param1:uint, param2:Boolean, param3:Boolean) : void
      {
      }
      
      protected function moveSelectionVertically(param1:uint, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:IListItemRenderer = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc13_:ScrollEvent = null;
         var _loc8_:Boolean = false;
         this.showCaret = true;
         var _loc9_:int = this.listItems.length;
         var _loc10_:int = this.listItems.length - this.offscreenExtraRowsTop - this.offscreenExtraRowsBottom;
         var _loc11_:int = this.rowInfo[_loc9_ - this.offscreenExtraRowsBottom - 1].y + this.rowInfo[_loc9_ - this.offscreenExtraRowsBottom - 1].height > this.listContent.heightExcludingOffsets - this.listContent.topOffset ? 1 : 0;
         var _loc12_:Boolean = false;
         this.bSelectItem = false;
         switch(param1)
         {
            case Keyboard.UP:
               if(this.caretIndex > 0)
               {
                  --this.caretIndex;
                  _loc12_ = true;
                  this.bSelectItem = true;
               }
               break;
            case Keyboard.DOWN:
               if(this.caretIndex < this.collection.length - 1)
               {
                  ++this.caretIndex;
                  _loc12_ = true;
                  this.bSelectItem = true;
               }
               else if(this.caretIndex == this.collection.length - 1 && _loc11_)
               {
                  if(this.verticalScrollPosition < maxVerticalScrollPosition)
                  {
                     _loc4_ = this.verticalScrollPosition + 1;
                  }
               }
               break;
            case Keyboard.PAGE_UP:
               if(this.caretIndex > this.verticalScrollPosition && this.caretIndex < this.verticalScrollPosition + _loc10_)
               {
                  this.caretIndex = this.verticalScrollPosition;
               }
               else
               {
                  this.caretIndex = Math.max(this.caretIndex - Math.max(_loc10_ - _loc11_,1),0);
                  _loc4_ = Math.max(this.caretIndex,0);
               }
               this.bSelectItem = true;
               break;
            case Keyboard.PAGE_DOWN:
               if(!(this.caretIndex >= this.verticalScrollPosition && this.caretIndex < this.verticalScrollPosition + _loc10_ - _loc11_ - 1))
               {
                  if(this.caretIndex == this.verticalScrollPosition && _loc10_ - _loc11_ <= 1)
                  {
                     ++this.caretIndex;
                  }
                  _loc4_ = Math.max(Math.min(this.caretIndex,maxVerticalScrollPosition),0);
               }
               this.bSelectItem = true;
               break;
            case Keyboard.HOME:
               if(this.caretIndex > 0)
               {
                  this.caretIndex = 0;
                  this.bSelectItem = true;
                  _loc4_ = 0;
               }
               break;
            case Keyboard.END:
               if(this.caretIndex < this.collection.length - 1)
               {
                  this.caretIndex = this.collection.length - 1;
                  this.bSelectItem = true;
                  _loc4_ = maxVerticalScrollPosition;
               }
         }
         if(_loc12_)
         {
            if(this.caretIndex >= this.verticalScrollPosition + _loc10_ - _loc11_)
            {
               if(_loc10_ - _loc11_ == 0)
               {
                  _loc4_ = Math.min(maxVerticalScrollPosition,this.caretIndex);
               }
               else
               {
                  _loc4_ = Math.min(maxVerticalScrollPosition,this.caretIndex - _loc10_ + _loc11_ + 1);
               }
            }
            else if(this.caretIndex < this.verticalScrollPosition)
            {
               _loc4_ = Math.max(this.caretIndex,0);
            }
         }
         if(!isNaN(_loc4_))
         {
            if(this.verticalScrollPosition != _loc4_)
            {
               (_loc13_ = new ScrollEvent(ScrollEvent.SCROLL)).detail = ScrollEventDetail.THUMB_POSITION;
               _loc13_.direction = ScrollEventDirection.VERTICAL;
               _loc13_.delta = _loc4_ - this.verticalScrollPosition;
               _loc13_.position = _loc4_;
               this.verticalScrollPosition = _loc4_;
               dispatchEvent(_loc13_);
            }
            if(!this.iteratorValid)
            {
               this.keySelectionPending = true;
               return;
            }
         }
         this.bShiftKey = param2;
         this.bCtrlKey = param3;
         this.lastKey = param1;
         this.finishKeySelection();
      }
      
      protected function finishKeySelection() : void
      {
         var _loc1_:String = null;
         var _loc5_:IListItemRenderer = null;
         var _loc7_:Point = null;
         var _loc8_:ListEvent = null;
         var _loc2_:int = this.listItems.length;
         var _loc3_:int = this.listItems.length - this.offscreenExtraRowsTop - this.offscreenExtraRowsBottom;
         var _loc4_:int = this.rowInfo[_loc2_ - this.offscreenExtraRowsBottom - 1].y + this.rowInfo[_loc2_ - this.offscreenExtraRowsBottom - 1].height > this.listContent.heightExcludingOffsets - this.listContent.topOffset ? 1 : 0;
         if(this.lastKey == Keyboard.PAGE_DOWN)
         {
            if(_loc3_ - _loc4_ == 0)
            {
               this.caretIndex = Math.min(this.verticalScrollPosition + _loc3_ - _loc4_,this.collection.length - 1);
            }
            else
            {
               this.caretIndex = Math.min(this.verticalScrollPosition + _loc3_ - _loc4_ - 1,this.collection.length - 1);
            }
         }
         var _loc6_:Boolean = false;
         if(this.bSelectItem && this.caretIndex - this.verticalScrollPosition >= 0)
         {
            if(this.caretIndex - this.verticalScrollPosition > Math.max(_loc3_ - _loc4_ - 1,0))
            {
               if(this.lastKey == Keyboard.END && maxVerticalScrollPosition > this.verticalScrollPosition)
               {
                  this.caretIndex = this.caretIndex - 1;
                  this.moveSelectionVertically(this.lastKey,this.bShiftKey,this.bCtrlKey);
                  return;
               }
               this.caretIndex = _loc3_ - _loc4_ - 1 + this.verticalScrollPosition;
            }
            if(_loc5_ = this.listItems[this.caretIndex - this.verticalScrollPosition + this.offscreenExtraRowsTop][0])
            {
               _loc1_ = this.itemToUID(_loc5_.data);
               _loc5_ = this.UIDToItemRenderer(_loc1_);
               if(!this.bCtrlKey || this.lastKey == Keyboard.SPACE)
               {
                  this.selectItem(_loc5_,this.bShiftKey,this.bCtrlKey);
                  _loc6_ = true;
               }
               if(this.bCtrlKey)
               {
                  this.drawItem(_loc5_,this.selectedData[_loc1_] != null,_loc1_ == this.highlightUID,true);
               }
            }
         }
         if(_loc6_)
         {
            _loc7_ = this.itemRendererToIndices(_loc5_);
            _loc8_ = new ListEvent(ListEvent.CHANGE);
            if(_loc7_)
            {
               _loc8_.columnIndex = _loc7_.x;
               _loc8_.rowIndex = _loc7_.y;
            }
            _loc8_.itemRenderer = _loc5_;
            dispatchEvent(_loc8_);
         }
      }
      
      mx_internal function commitSelectedIndex(param1:int) : void
      {
         var bookmark:CursorBookmark = null;
         var len:int = 0;
         var data:Object = null;
         var selectedBookmark:CursorBookmark = null;
         var uid:String = null;
         var value:int = param1;
         if(value != -1)
         {
            value = Math.min(value,this.collection.length - 1);
            bookmark = this.iterator.bookmark;
            len = value - this.scrollPositionToIndex(this.horizontalScrollPosition - this.offscreenExtraColumnsLeft,this.verticalScrollPosition - this.offscreenExtraRowsTop);
            try
            {
               this.iterator.seek(CursorBookmark.CURRENT,len);
            }
            catch(e:ItemPendingError)
            {
               iterator.seek(bookmark,0);
               bSelectedIndexChanged = true;
               _selectedIndex = value;
               return;
            }
            data = this.iterator.current;
            selectedBookmark = this.iterator.bookmark;
            uid = this.itemToUID(data);
            this.iterator.seek(bookmark,0);
            if(!this.selectedData[uid])
            {
               if(this.listContent && this.UIDToItemRenderer(uid))
               {
                  this.selectItem(this.UIDToItemRenderer(uid),false,false);
               }
               else
               {
                  this.clearSelected();
                  this.insertSelectionDataBefore(uid,new ListBaseSelectionData(data,value,this.approximate),this.firstSelectionData);
                  this._selectedIndex = value;
                  this.caretIndex = value;
                  this.caretBookmark = selectedBookmark;
                  this.anchorIndex = value;
                  this.anchorBookmark = selectedBookmark;
                  this._selectedItem = data;
               }
            }
         }
         else
         {
            this.clearSelected();
         }
         dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
      
      mx_internal function commitSelectedIndices(param1:Array) : void
      {
         var indices:Array = param1;
         this.clearSelected();
         try
         {
            this.collectionIterator.seek(CursorBookmark.FIRST,0);
         }
         catch(e:ItemPendingError)
         {
            e.addResponder(new ItemResponder(selectionIndicesPendingResultHandler,selectionIndicesPendingFailureHandler,new ListBaseSelectionDataPending(true,0,indices,CursorBookmark.FIRST,0)));
            return;
         }
         this.setSelectionIndicesLoop(0,indices,true);
      }
      
      private function setSelectionIndicesLoop(param1:int, param2:Array, param3:Boolean = false) : void
      {
         var data:Object = null;
         var uid:String = null;
         var index:int = param1;
         var indices:Array = param2;
         var firstTime:Boolean = param3;
         while(indices.length)
         {
            if(index != indices[0])
            {
               try
               {
                  this.collectionIterator.seek(CursorBookmark.CURRENT,indices[0] - index);
               }
               catch(e:ItemPendingError)
               {
                  e.addResponder(new ItemResponder(selectionIndicesPendingResultHandler,selectionIndicesPendingFailureHandler,new ListBaseSelectionDataPending(firstTime,index,indices,CursorBookmark.CURRENT,indices[0] - index)));
                  return;
               }
            }
            index = indices[0];
            indices.shift();
            data = this.collectionIterator.current;
            if(firstTime)
            {
               this._selectedIndex = index;
               this._selectedItem = data;
               this.caretIndex = index;
               this.caretBookmark = this.collectionIterator.bookmark;
               this.anchorIndex = index;
               this.anchorBookmark = this.collectionIterator.bookmark;
               firstTime = false;
            }
            uid = this.itemToUID(data);
            this.insertSelectionDataAfter(uid,new ListBaseSelectionData(data,index,false),this.lastSelectionData);
            if(this.UIDToItemRenderer(uid))
            {
               this.drawItem(this.UIDToItemRenderer(uid),true,uid == this.highlightUID,this.caretIndex == index);
            }
         }
         if(initialized)
         {
            this.updateList();
         }
         dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
      
      private function commitSelectedItem(param1:Object, param2:Boolean = true) : void
      {
         if(param2)
         {
            this.clearSelected();
         }
         if(param1 != null)
         {
            this.commitSelectedItems([param1]);
         }
      }
      
      private function commitSelectedItems(param1:Array) : void
      {
         var useFind:Boolean = false;
         var uid:String = null;
         var items:Array = param1;
         this.clearSelected();
         items = items.slice();
         useFind = this.collection.sort != null;
         try
         {
            this.collectionIterator.seek(CursorBookmark.FIRST,0);
         }
         catch(e:ItemPendingError)
         {
            e.addResponder(new ItemResponder(mx_internal::selectionDataPendingResultHandler,selectionDataPendingFailureHandler,new ListBaseSelectionDataPending(useFind,0,items,null,0)));
            return;
         }
         var n:int = items.length;
         this.selectionDataArray = new Array(n);
         this.firstSelectedItem = !!n ? items[0] : null;
         this.proposedSelectedItemIndexes = new Dictionary();
         var i:int = 0;
         while(i < n)
         {
            uid = this.itemToUID(items[i]);
            this.proposedSelectedItemIndexes[uid] = i;
            i++;
         }
         this.setSelectionDataLoop(items,0,useFind);
      }
      
      private function setSelectionDataLoop(param1:Array, param2:int, param3:Boolean = true) : void
      {
         var uid:String = null;
         var item:Object = null;
         var bookmark:CursorBookmark = null;
         var compareFunction:Function = null;
         var selectionData:ListBaseSelectionData = null;
         var lastSelectionData:ListBaseSelectionData = null;
         var len:int = 0;
         var data:Object = null;
         var i:int = 0;
         var items:Array = param1;
         var index:int = param2;
         var useFind:Boolean = param3;
         if(useFind)
         {
            while(items.length)
            {
               item = items.pop();
               uid = this.itemToUID(item);
               try
               {
                  this.collectionIterator.findAny(item);
               }
               catch(e1:ItemPendingError)
               {
                  items.push(item);
                  e1.addResponder(new ItemResponder(mx_internal::selectionDataPendingResultHandler,selectionDataPendingFailureHandler,new ListBaseSelectionDataPending(useFind,0,items,null,0)));
                  return;
               }
               bookmark = this.collectionIterator.bookmark;
               index = bookmark.getViewIndex();
               if(index < 0)
               {
                  try
                  {
                     this.collectionIterator.seek(CursorBookmark.FIRST,0);
                  }
                  catch(e2:ItemPendingError)
                  {
                     e2.addResponder(new ItemResponder(mx_internal::selectionDataPendingResultHandler,selectionDataPendingFailureHandler,new ListBaseSelectionDataPending(false,0,items,CursorBookmark.FIRST,0)));
                     return;
                  }
                  this.setSelectionDataLoop(items,0,false);
               }
               this.insertSelectionDataBefore(uid,new ListBaseSelectionData(item,index,true),this.firstSelectionData);
               if(items.length == 0)
               {
                  this._selectedIndex = index;
                  this._selectedItem = item;
                  this.caretIndex = index;
                  this.caretBookmark = this.collectionIterator.bookmark;
                  this.anchorIndex = index;
                  this.anchorBookmark = this.collectionIterator.bookmark;
               }
               continue;
               return;
            }
         }
         else
         {
            compareFunction = this.selectedItemsCompareFunction;
            if(compareFunction == null)
            {
               compareFunction = this.strictEqualityCompareFunction;
            }
            while(items.length && !this.collectionIterator.afterLast)
            {
               len = items.length;
               data = this.collectionIterator.current;
               i = 0;
               while(i < len)
               {
                  item = items[i];
                  if(compareFunction(data,item))
                  {
                     uid = this.itemToUID(data);
                     this.selectionDataArray[this.proposedSelectedItemIndexes[uid]] = new ListBaseSelectionData(data,index,false);
                     items.splice(i,1);
                     if(item === this.firstSelectedItem)
                     {
                        this._selectedIndex = index;
                        this._selectedItem = data;
                        this.caretIndex = index;
                        this.caretBookmark = this.collectionIterator.bookmark;
                        this.anchorIndex = index;
                        this.anchorBookmark = this.collectionIterator.bookmark;
                     }
                     break;
                  }
                  i++;
               }
               try
               {
                  this.collectionIterator.moveNext();
                  index++;
               }
               catch(e2:ItemPendingError)
               {
                  e2.addResponder(new ItemResponder(mx_internal::selectionDataPendingResultHandler,selectionDataPendingFailureHandler,new ListBaseSelectionDataPending(false,index,items,CursorBookmark.FIRST,index)));
                  return;
               }
            }
            len = this.selectionDataArray.length;
            lastSelectionData = this.firstSelectionData;
            if(len)
            {
               selectionData = this.selectionDataArray[0];
               if(selectionData)
               {
                  uid = this.itemToUID(selectionData.data);
                  this.insertSelectionDataBefore(uid,selectionData,this.firstSelectionData);
                  lastSelectionData = selectionData;
               }
            }
            i = 1;
            while(i < len)
            {
               selectionData = this.selectionDataArray[i];
               if(selectionData)
               {
                  uid = this.itemToUID(selectionData.data);
                  this.insertSelectionDataAfter(uid,selectionData,lastSelectionData);
                  lastSelectionData = selectionData;
               }
               i++;
            }
            this.selectionDataArray = null;
            this.proposedSelectedItemIndexes = null;
            this.firstSelectedItem = null;
         }
         if(initialized)
         {
            this.updateList();
         }
         dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
      
      private function clearSelectionData() : void
      {
         this.selectedData = {};
         this.firstSelectionData = null;
         this.lastSelectionData = null;
      }
      
      private function insertSelectionDataBefore(param1:String, param2:ListBaseSelectionData, param3:ListBaseSelectionData) : void
      {
         if(param3 == null)
         {
            this.firstSelectionData = this.lastSelectionData = param2;
         }
         else
         {
            if(param3 == this.firstSelectionData)
            {
               this.firstSelectionData = param2;
            }
            param2.nextSelectionData = param3;
            param2.prevSelectionData = param3.prevSelectionData;
            param3.prevSelectionData = param2;
         }
         this.selectedData[param1] = param2;
      }
      
      private function insertSelectionDataAfter(param1:String, param2:ListBaseSelectionData, param3:ListBaseSelectionData) : void
      {
         if(param3 == null)
         {
            this.firstSelectionData = this.lastSelectionData = param2;
         }
         else
         {
            if(param3 == this.lastSelectionData)
            {
               this.lastSelectionData = param2;
            }
            param2.prevSelectionData = param3;
            param2.nextSelectionData = param3.nextSelectionData;
            param3.nextSelectionData = param2;
         }
         this.selectedData[param1] = param2;
      }
      
      private function removeSelectionData(param1:String) : void
      {
         var _loc2_:ListBaseSelectionData = this.selectedData[param1];
         if(this.firstSelectionData == _loc2_)
         {
            this.firstSelectionData = _loc2_.nextSelectionData;
         }
         if(this.lastSelectionData == _loc2_)
         {
            this.lastSelectionData = _loc2_.prevSelectionData;
         }
         if(_loc2_.prevSelectionData != null)
         {
            _loc2_.prevSelectionData.nextSelectionData = _loc2_.nextSelectionData;
         }
         if(_loc2_.nextSelectionData != null)
         {
            _loc2_.nextSelectionData.prevSelectionData = _loc2_.prevSelectionData;
         }
         delete this.selectedData[param1];
      }
      
      protected function applySelectionEffect(param1:Sprite, param2:String, param3:IListItemRenderer) : void
      {
         var _loc5_:Function = null;
         var _loc4_:Number;
         if((_loc4_ = getStyle("selectionDuration")) != 0)
         {
            param1.alpha = 0;
            this.selectionTweens[param2] = new Tween(param1,0,1,_loc4_,5);
            this.selectionTweens[param2].addEventListener(TweenEvent.TWEEN_UPDATE,this.selectionTween_updateHandler);
            this.selectionTweens[param2].addEventListener(TweenEvent.TWEEN_END,this.selectionTween_endHandler);
            this.selectionTweens[param2].setTweenHandlers(this.onSelectionTweenUpdate,this.onSelectionTweenUpdate);
            if((_loc5_ = getStyle("selectionEasingFunction") as Function) != null)
            {
               this.selectionTweens[param2].easingFunction = _loc5_;
            }
         }
      }
      
      private function onSelectionTweenUpdate(param1:Number) : void
      {
      }
      
      protected function copySelectedItems(param1:Boolean = true) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:ListBaseSelectionData = this.firstSelectionData;
         while(_loc3_ != null)
         {
            if(param1)
            {
               _loc2_.push(_loc3_.data);
            }
            else
            {
               _loc2_.push(_loc3_.index);
            }
            _loc3_ = _loc3_.nextSelectionData;
         }
         return _loc2_;
      }
      
      protected function scrollPositionToIndex(param1:int, param2:int) : int
      {
         return !!this.iterator ? int(param2) : -1;
      }
      
      public function scrollToIndex(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         if(param1 >= this.verticalScrollPosition + this.listItems.length - this.offscreenExtraRowsBottom || param1 < this.verticalScrollPosition)
         {
            _loc2_ = Math.min(param1,maxVerticalScrollPosition);
            this.verticalScrollPosition = _loc2_;
            return true;
         }
         return false;
      }
      
      protected function scrollVertically(param1:int, param2:int, param3:Boolean) : void
      {
         var i:int = 0;
         var j:int = 0;
         var numRows:int = 0;
         var numCols:int = 0;
         var uid:String = null;
         var curY:Number = NaN;
         var cursorPos:CursorBookmark = null;
         var discardRows:int = 0;
         var desiredoffscreenExtraRowsTop:int = 0;
         var newoffscreenExtraRowsTop:int = 0;
         var offscreenExtraRowsBottomToMake:int = 0;
         var newTopOffset:Number = NaN;
         var fillHeight:Number = NaN;
         var pt:Point = null;
         var rowIdx:int = 0;
         var modDeltaPos:int = 0;
         var desiredPrefixItems:int = 0;
         var actual:Point = null;
         var row:Array = null;
         var rowData:Object = null;
         var desiredSuffixItems:int = 0;
         var newOffscreenRows:int = 0;
         var visibleAreaBottomY:int = 0;
         var pos:int = param1;
         var deltaPos:int = param2;
         var scrollUp:Boolean = param3;
         var rowCount:int = this.rowInfo.length;
         var columnCount:int = this.listItems[0].length;
         var moveBlockDistance:Number = 0;
         var listContentVisibleHeight:Number = this.listContent.heightExcludingOffsets;
         if(scrollUp)
         {
            discardRows = deltaPos;
            desiredoffscreenExtraRowsTop = this.offscreenExtraRows / 2;
            newoffscreenExtraRowsTop = Math.min(desiredoffscreenExtraRowsTop,this.offscreenExtraRowsTop + deltaPos);
            if(this.offscreenExtraRowsTop < desiredoffscreenExtraRowsTop)
            {
               discardRows = Math.max(0,deltaPos - (desiredoffscreenExtraRowsTop - this.offscreenExtraRowsTop));
            }
            moveBlockDistance = this.sumRowHeights(0,discardRows - 1);
            i = 0;
            while(i < discardRows)
            {
               if(!this.seekNextSafely(this.iterator,pos))
               {
                  return;
               }
               i++;
            }
            i = 0;
            while(i < rowCount)
            {
               numCols = this.listItems[i].length;
               if(i < discardRows)
               {
                  this.destroyRow(i,numCols);
               }
               else if(discardRows > 0)
               {
                  this.moveRowVertically(i,numCols,-moveBlockDistance);
                  this.moveIndicatorsVertically(this.rowInfo[i].uid,-moveBlockDistance);
                  this.shiftRow(i,i - discardRows,numCols,true);
                  if(this.listItems[i].length == 0)
                  {
                     this.listItems[i - discardRows].splice(0);
                  }
               }
               i++;
            }
            if(discardRows)
            {
               this.truncateRowArrays(rowCount - discardRows);
            }
            curY = this.rowInfo[rowCount - discardRows - 1].y + this.rowInfo[rowCount - discardRows - 1].height;
            cursorPos = this.iterator.bookmark;
            try
            {
               this.iterator.seek(CursorBookmark.CURRENT,rowCount - discardRows);
               if(!this.iteratorValid)
               {
                  this.iteratorValid = true;
                  this.lastSeekPending = null;
               }
            }
            catch(e1:ItemPendingError)
            {
               lastSeekPending = new ListBaseSeekPending(cursorPos,0);
               e1.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
               iteratorValid = false;
            }
            offscreenExtraRowsBottomToMake = this.offscreenExtraRows / 2;
            newTopOffset = 0;
            i = 0;
            while(i < newoffscreenExtraRowsTop)
            {
               newTopOffset -= this.rowInfo[i].height;
               i++;
            }
            fillHeight = listContentVisibleHeight - (curY + newTopOffset);
            if(fillHeight > 0)
            {
               pt = this.makeRowsAndColumns(0,curY,this.listContent.width,curY + fillHeight,0,rowCount - discardRows);
               rowCount += pt.y;
            }
            else
            {
               rowIdx = rowCount - discardRows - 1;
               fillHeight += this.rowInfo[rowIdx--].height;
               while(fillHeight < 0)
               {
                  offscreenExtraRowsBottomToMake--;
                  fillHeight += this.rowInfo[rowIdx--].height;
               }
            }
            if(offscreenExtraRowsBottomToMake > 0)
            {
               if(pt)
               {
                  curY = this.rowInfo[rowCount - discardRows - 1].y + this.rowInfo[rowCount - discardRows - 1].height;
               }
               pt = this.makeRowsAndColumns(0,curY,this.listContent.width,this.listContent.height,0,rowCount - discardRows,true,offscreenExtraRowsBottomToMake);
            }
            else
            {
               pt = new Point(0,0);
            }
            try
            {
               this.iterator.seek(cursorPos,0);
            }
            catch(e2:ItemPendingError)
            {
               lastSeekPending = new ListBaseSeekPending(cursorPos,0);
               e2.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
               iteratorValid = false;
            }
            this.offscreenExtraRowsTop = newoffscreenExtraRowsTop;
            this.offscreenExtraRowsBottom = this.offscreenExtraRows / 2 - offscreenExtraRowsBottomToMake + pt.y;
         }
         else
         {
            curY = 0;
            modDeltaPos = deltaPos;
            desiredPrefixItems = this.offscreenExtraRows / 2;
            if(pos < desiredPrefixItems)
            {
               modDeltaPos -= desiredPrefixItems - pos;
            }
            i = 0;
            while(i < modDeltaPos)
            {
               this.addToRowArrays();
               i++;
            }
            actual = new Point(0,0);
            if(modDeltaPos > 0)
            {
               try
               {
                  this.iterator.seek(CursorBookmark.CURRENT,-modDeltaPos);
                  if(!this.iteratorValid)
                  {
                     this.iteratorValid = true;
                     this.lastSeekPending = null;
                  }
               }
               catch(e3:ItemPendingError)
               {
                  lastSeekPending = new ListBaseSeekPending(CursorBookmark.CURRENT,-modDeltaPos);
                  e3.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                  iteratorValid = false;
               }
               cursorPos = this.iterator.bookmark;
               this.allowRendererStealingDuringLayout = false;
               actual = this.makeRowsAndColumns(0,curY,this.listContent.width,this.listContent.height,0,0,true,modDeltaPos);
               this.allowRendererStealingDuringLayout = true;
               try
               {
                  this.iterator.seek(cursorPos,0);
               }
               catch(e4:ItemPendingError)
               {
                  lastSeekPending = new ListBaseSeekPending(cursorPos,0);
                  e4.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                  iteratorValid = false;
               }
            }
            if(actual.y == 0 && modDeltaPos > 0)
            {
               this.verticalScrollPosition = 0;
               this.restoreRowArrays(modDeltaPos);
            }
            moveBlockDistance = this.sumRowHeights(0,actual.y - 1);
            desiredSuffixItems = this.offscreenExtraRows / 2;
            newOffscreenRows = 0;
            visibleAreaBottomY = listContentVisibleHeight + this.sumRowHeights(0,Math.min(desiredPrefixItems,pos) - 1);
            i = actual.y;
            while(i < this.listItems.length)
            {
               row = this.listItems[i];
               rowData = this.rowInfo[i];
               this.moveRowVertically(i,this.listItems[i].length,moveBlockDistance);
               if(rowData.y >= visibleAreaBottomY)
               {
                  newOffscreenRows++;
                  if(newOffscreenRows > desiredSuffixItems)
                  {
                     this.destroyRow(i,this.listItems[i].length);
                     this.removeFromRowArrays(i);
                     i--;
                  }
                  else
                  {
                     this.shiftRow(i,i + deltaPos,this.listItems[i].length,false);
                     this.moveIndicatorsVertically(this.rowInfo[i].uid,moveBlockDistance);
                  }
               }
               else
               {
                  this.shiftRow(i,i + deltaPos,this.listItems[i].length,false);
                  this.moveIndicatorsVertically(this.rowInfo[i].uid,moveBlockDistance);
               }
               i++;
            }
            rowCount = this.listItems.length;
            this.offscreenExtraRowsTop = Math.min(desiredPrefixItems,pos);
            this.offscreenExtraRowsBottom = Math.min(newOffscreenRows,desiredSuffixItems);
         }
         this.listContent.topOffset = -this.sumRowHeights(0,this.offscreenExtraRowsTop - 1);
         this.listContent.bottomOffset = this.rowInfo[this.rowInfo.length - 1].y + this.rowInfo[this.rowInfo.length - 1].height + this.listContent.topOffset - listContentVisibleHeight;
         this.adjustListContent(this.oldUnscaledWidth,this.oldUnscaledHeight);
         this.addClipMask(true);
      }
      
      protected function destroyRow(param1:int, param2:int) : void
      {
         var _loc3_:IListItemRenderer = null;
         var _loc4_:String = this.rowInfo[param1].uid;
         this.removeIndicators(_loc4_);
         var _loc5_:int = 0;
         while(_loc5_ < param2)
         {
            _loc3_ = this.listItems[param1][_loc5_];
            if(_loc3_.data)
            {
               delete this.visibleData[_loc4_];
            }
            this.addToFreeItemRenderers(_loc3_);
            _loc5_++;
         }
      }
      
      protected function moveRowVertically(param1:int, param2:int, param3:Number) : void
      {
         var _loc4_:IListItemRenderer = null;
         var _loc5_:int = 0;
         while(_loc5_ < param2)
         {
            _loc4_ = this.listItems[param1][_loc5_];
            _loc4_.move(_loc4_.x,_loc4_.y + param3);
            _loc5_++;
         }
         this.rowInfo[param1].y += param3;
      }
      
      protected function shiftRow(param1:int, param2:int, param3:int, param4:Boolean) : void
      {
         var _loc5_:IListItemRenderer = null;
         var _loc6_:int = 0;
         while(_loc6_ < param3)
         {
            _loc5_ = this.listItems[param1][_loc6_];
            if(param4)
            {
               this.listItems[param2][_loc6_] = _loc5_;
               this.rowMap[_loc5_.name].rowIndex = param2;
            }
            else
            {
               this.rowMap[_loc5_.name].rowIndex = param1;
            }
            _loc6_++;
         }
         if(param4)
         {
            this.rowInfo[param2] = this.rowInfo[param1];
         }
      }
      
      protected function moveIndicatorsVertically(param1:String, param2:Number) : void
      {
         if(param1 != null)
         {
            if(this.selectionIndicators[param1])
            {
               this.selectionIndicators[param1].y += param2;
            }
            if(this.highlightUID == param1)
            {
               this.highlightIndicator.y += param2;
            }
            if(this.caretUID == param1)
            {
               this.caretIndicator.y += param2;
            }
         }
      }
      
      protected function moveIndicatorsHorizontally(param1:String, param2:Number) : void
      {
         if(param1 != null)
         {
            if(this.selectionIndicators[param1])
            {
               this.selectionIndicators[param1].x += param2;
            }
            if(this.highlightUID == param1)
            {
               this.highlightIndicator.x += param2;
            }
            if(this.caretUID == param1)
            {
               this.caretIndicator.x += param2;
            }
         }
      }
      
      protected function sumRowHeights(param1:int, param2:int) : Number
      {
         var _loc3_:Number = 0;
         var _loc4_:int = param1;
         while(_loc4_ <= param2)
         {
            _loc3_ += this.rowInfo[_loc4_].height;
            _loc4_++;
         }
         return _loc3_;
      }
      
      protected function truncateRowArrays(param1:int) : void
      {
         this.listItems.splice(param1);
         this.rowInfo.splice(param1);
      }
      
      protected function addToRowArrays() : void
      {
         this.listItems.splice(0,0,null);
         this.rowInfo.splice(0,0,null);
      }
      
      protected function restoreRowArrays(param1:int) : void
      {
         this.rowInfo.splice(0,param1);
         this.listItems.splice(0,param1);
      }
      
      protected function removeFromRowArrays(param1:int) : void
      {
         this.listItems.splice(param1,1);
         this.rowInfo.splice(param1,1);
      }
      
      protected function scrollHorizontally(param1:int, param2:int, param3:Boolean) : void
      {
      }
      
      public function createItemRenderer(param1:Object) : IListItemRenderer
      {
         return null;
      }
      
      protected function configureScrollBars() : void
      {
      }
      
      protected function dragScroll() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:ScrollEvent = null;
         var _loc1_:Number = 0;
         if(this.dragScrollingInterval == 0)
         {
            return;
         }
         var _loc6_:Number = 30;
         _loc3_ = this.verticalScrollPosition;
         if(DragManager.isDragging)
         {
            _loc1_ = viewMetrics.top + (!!this.variableRowHeight ? getStyle("fontSize") / 4 : this.rowHeight);
         }
         clearInterval(this.dragScrollingInterval);
         if(mouseY < _loc1_)
         {
            this.verticalScrollPosition = Math.max(0,_loc3_ - 1);
            if(DragManager.isDragging)
            {
               _loc2_ = 100;
            }
            else
            {
               _loc4_ = Math.min(0 - mouseY - 30,0);
               _loc2_ = 0.593 * _loc4_ * _loc4_ + 1 + _loc6_;
            }
            this.dragScrollingInterval = setInterval(this.dragScroll,_loc2_);
            if(_loc3_ != this.verticalScrollPosition)
            {
               (_loc5_ = new ScrollEvent(ScrollEvent.SCROLL)).detail = ScrollEventDetail.THUMB_POSITION;
               _loc5_.direction = ScrollEventDirection.VERTICAL;
               _loc5_.position = this.verticalScrollPosition;
               _loc5_.delta = this.verticalScrollPosition - _loc3_;
               dispatchEvent(_loc5_);
            }
         }
         else if(mouseY > unscaledHeight - _loc1_)
         {
            this.verticalScrollPosition = Math.min(maxVerticalScrollPosition,this.verticalScrollPosition + 1);
            if(DragManager.isDragging)
            {
               _loc2_ = 100;
            }
            else
            {
               _loc4_ = Math.min(mouseY - unscaledHeight - 30,0);
               _loc2_ = 0.593 * _loc4_ * _loc4_ + 1 + _loc6_;
            }
            this.dragScrollingInterval = setInterval(this.dragScroll,_loc2_);
            if(_loc3_ != this.verticalScrollPosition)
            {
               (_loc5_ = new ScrollEvent(ScrollEvent.SCROLL)).detail = ScrollEventDetail.THUMB_POSITION;
               _loc5_.direction = ScrollEventDirection.VERTICAL;
               _loc5_.position = this.verticalScrollPosition;
               _loc5_.delta = this.verticalScrollPosition - _loc3_;
               dispatchEvent(_loc5_);
            }
         }
         else
         {
            this.dragScrollingInterval = setInterval(this.dragScroll,15);
         }
         if(DragManager.isDragging && this.lastDragEvent && _loc3_ != this.verticalScrollPosition)
         {
            this.dragOverHandler(this.lastDragEvent);
         }
      }
      
      mx_internal function resetDragScrolling() : void
      {
         if(this.dragScrollingInterval != 0)
         {
            clearInterval(this.dragScrollingInterval);
            this.dragScrollingInterval = 0;
         }
      }
      
      protected function addDragData(param1:Object) : void
      {
         param1.addHandler(this.copySelectedItems,"items");
         param1.addHandler(this.copySelectedItemsForDragDrop,"itemsByIndex");
         var _loc2_:int = 0;
         var _loc3_:Array = this.selectedIndices;
         var _loc4_:int = _loc3_.length;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(this.mouseDownIndex > _loc3_[_loc5_])
            {
               _loc2_++;
            }
            _loc5_++;
         }
         param1.addData(_loc2_,"caretIndex");
      }
      
      private function copySelectedItemsForDragDrop() : Vector.<Object>
      {
         var _loc1_:Array = this.selectedIndices.slice(0,this.selectedIndices.length);
         var _loc2_:Vector.<Object> = new Vector.<Object>(_loc1_.length);
         _loc1_.sort();
         var _loc3_:int = _loc1_.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_[_loc4_] = this.dataProvider.getItemAt(_loc1_[_loc4_]);
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function calculateDropIndex(param1:DragEvent = null) : int
      {
         var _loc2_:IListItemRenderer = null;
         var _loc3_:IListItemRenderer = null;
         var _loc4_:Point = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1)
         {
            _loc4_ = new Point(param1.localX,param1.localY);
            _loc4_ = DisplayObject(param1.target).localToGlobal(_loc4_);
            _loc4_ = this.listContent.globalToLocal(_loc4_);
            _loc5_ = this.listItems.length;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(this.listItems[_loc6_][0])
               {
                  _loc3_ = this.listItems[_loc6_][0];
               }
               if(this.rowInfo[_loc6_].y <= _loc4_.y && _loc4_.y < this.rowInfo[_loc6_].y + this.rowInfo[_loc6_].height)
               {
                  _loc2_ = this.listItems[_loc6_][0];
                  break;
               }
               _loc6_++;
            }
            if(_loc2_)
            {
               this.lastDropIndex = this.itemRendererToIndex(_loc2_);
            }
            else if(_loc3_)
            {
               this.lastDropIndex = this.itemRendererToIndex(_loc3_) + 1;
            }
            else
            {
               this.lastDropIndex = !!this.collection ? int(this.collection.length) : 0;
            }
         }
         return this.lastDropIndex;
      }
      
      protected function calculateDropIndicatorY(param1:Number, param2:int) : Number
      {
         var _loc3_:int = 0;
         var _loc4_:Number = 0;
         if(param1 && param2 < param1 && this.listItems[param2].length && this.listItems[param2][0])
         {
            return this.listItems[param2][0].y - 1;
         }
         _loc3_ = 0;
         while(_loc3_ < param1)
         {
            if(!this.listItems[_loc3_].length)
            {
               break;
            }
            _loc4_ += this.rowInfo[_loc3_].height;
            _loc3_++;
         }
         return _loc4_;
      }
      
      public function showDropFeedback(param1:DragEvent) : void
      {
         var _loc6_:Class = null;
         var _loc7_:EdgeMetrics = null;
         if(!this.dropIndicator)
         {
            if(!(_loc6_ = getStyle("dropIndicatorSkin")))
            {
               _loc6_ = ListDropIndicator;
            }
            this.dropIndicator = IFlexDisplayObject(new _loc6_());
            _loc7_ = viewMetrics;
            drawFocus(true);
            this.dropIndicator.x = 2;
            this.dropIndicator.setActualSize(this.listContent.width - 4,4);
            this.dropIndicator.visible = true;
            this.listContent.addChild(DisplayObject(this.dropIndicator));
            if(this.collection)
            {
               if(this.dragScrollingInterval == 0)
               {
                  this.dragScrollingInterval = setInterval(this.dragScroll,15);
               }
            }
         }
         var _loc2_:int = this.listItems.length;
         var _loc3_:int = this.rowInfo[_loc2_ - this.offscreenExtraRowsBottom - 1].y + this.rowInfo[_loc2_ - this.offscreenExtraRowsBottom - 1].height > this.listContent.heightExcludingOffsets - this.listContent.topOffset ? 1 : 0;
         var _loc4_:Number = (_loc4_ = this.calculateDropIndex(param1)) - this.verticalScrollPosition;
         var _loc5_:Number = this.listItems.length;
         if(_loc4_ >= _loc5_)
         {
            if(_loc3_)
            {
               _loc4_ = _loc5_ - 1;
            }
            else
            {
               _loc4_ = _loc5_;
            }
         }
         if(_loc4_ < 0)
         {
            _loc4_ = 0;
         }
         this.dropIndicator.y = this.calculateDropIndicatorY(_loc5_,_loc4_ + this.offscreenExtraRowsTop);
      }
      
      public function hideDropFeedback(param1:DragEvent) : void
      {
         if(this.dropIndicator)
         {
            DisplayObject(this.dropIndicator).parent.removeChild(DisplayObject(this.dropIndicator));
            this.dropIndicator = null;
            drawFocus(false);
         }
      }
      
      protected function seekPendingFailureHandler(param1:Object, param2:ListBaseSeekPending) : void
      {
      }
      
      protected function seekPendingResultHandler(param1:Object, param2:ListBaseSeekPending) : void
      {
         var data:Object = param1;
         var info:ListBaseSeekPending = param2;
         if(info != this.lastSeekPending)
         {
            return;
         }
         this.lastSeekPending = null;
         this.iteratorValid = true;
         try
         {
            this.iterator.seek(info.bookmark,info.offset);
         }
         catch(e:ItemPendingError)
         {
            lastSeekPending = new ListBaseSeekPending(info.bookmark,info.offset);
            e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
            iteratorValid = false;
         }
         if(this.bSortItemPending)
         {
            this.bSortItemPending = false;
            this.adjustAfterSort();
         }
         this.itemsSizeChanged = true;
         invalidateDisplayList();
      }
      
      private function findPendingFailureHandler(param1:Object, param2:ListBaseFindPending) : void
      {
      }
      
      private function findPendingResultHandler(param1:Object, param2:ListBaseFindPending) : void
      {
         this.iterator.seek(param2.bookmark,param2.offset);
         this.findStringLoop(param2.searchString,param2.startingBookmark,param2.currentIndex,param2.stopIndex);
      }
      
      private function selectionPendingFailureHandler(param1:Object, param2:ListBaseSelectionPending) : void
      {
      }
      
      private function selectionPendingResultHandler(param1:Object, param2:ListBaseSelectionPending) : void
      {
         this.iterator.seek(param2.bookmark,param2.offset);
         this.shiftSelectionLoop(param2.incrementing,param2.index,param2.stopData,param2.transition,param2.placeHolder);
      }
      
      private function selectionDataPendingFailureHandler(param1:Object, param2:ListBaseSelectionDataPending) : void
      {
      }
      
      mx_internal function selectionDataPendingResultHandler(param1:Object, param2:ListBaseSelectionDataPending) : void
      {
         if(param2.bookmark)
         {
            this.collectionIterator.seek(param2.bookmark,param2.offset);
         }
         this.setSelectionDataLoop(param2.items,param2.index,param2.useFind);
      }
      
      private function selectionIndicesPendingFailureHandler(param1:Object, param2:ListBaseSelectionDataPending) : void
      {
      }
      
      private function selectionIndicesPendingResultHandler(param1:Object, param2:ListBaseSelectionDataPending) : void
      {
         if(param2.bookmark)
         {
            this.iterator.seek(param2.bookmark,param2.offset);
         }
         this.setSelectionIndicesLoop(param2.index,param2.items,param2.useFind);
      }
      
      protected function findKey(param1:int) : Boolean
      {
         var _loc2_:int = param1;
         return _loc2_ >= 33 && _loc2_ <= 126 && this.findString(String.fromCharCode(_loc2_));
      }
      
      public function findString(param1:String) : Boolean
      {
         var cursorPos:CursorBookmark = null;
         var bMovedNext:Boolean = false;
         var str:String = param1;
         if(!this.collection || this.collection.length == 0)
         {
            return false;
         }
         cursorPos = this.iterator.bookmark;
         var stopIndex:int = this.selectedIndex;
         var i:int = stopIndex + 1;
         if(this.selectedIndex == -1)
         {
            try
            {
               this.iterator.seek(CursorBookmark.FIRST,0);
            }
            catch(e1:ItemPendingError)
            {
               e1.addResponder(new ItemResponder(findPendingResultHandler,findPendingFailureHandler,new ListBaseFindPending(str,cursorPos,CursorBookmark.FIRST,0,0,collection.length)));
               iteratorValid = false;
               return false;
            }
            stopIndex = this.collection.length;
            i = 0;
         }
         else
         {
            try
            {
               this.iterator.seek(CursorBookmark.FIRST,stopIndex);
            }
            catch(e2:ItemPendingError)
            {
               if(anchorIndex == collection.length - 1)
               {
                  e2.addResponder(new ItemResponder(findPendingResultHandler,findPendingFailureHandler,new ListBaseFindPending(str,cursorPos,CursorBookmark.FIRST,0,0,collection.length)));
               }
               else
               {
                  e2.addResponder(new ItemResponder(findPendingResultHandler,findPendingFailureHandler,new ListBaseFindPending(str,cursorPos,anchorBookmark,1,anchorIndex + 1,anchorIndex)));
               }
               iteratorValid = false;
               return false;
            }
            bMovedNext = false;
            try
            {
               bMovedNext = this.iterator.moveNext();
            }
            catch(e3:ItemPendingError)
            {
               e3.addResponder(new ItemResponder(findPendingResultHandler,findPendingFailureHandler,new ListBaseFindPending(str,cursorPos,anchorBookmark,1,anchorIndex + 1,anchorIndex)));
               iteratorValid = false;
               return false;
            }
            if(!bMovedNext)
            {
               try
               {
                  this.iterator.seek(CursorBookmark.FIRST,0);
               }
               catch(e4:ItemPendingError)
               {
                  e4.addResponder(new ItemResponder(findPendingResultHandler,findPendingFailureHandler,new ListBaseFindPending(str,cursorPos,CursorBookmark.FIRST,0,0,collection.length)));
                  iteratorValid = false;
                  return false;
               }
               stopIndex = this.collection.length;
               i = 0;
            }
         }
         return this.findStringLoop(str,cursorPos,i,stopIndex);
      }
      
      private function findStringLoop(param1:String, param2:CursorBookmark, param3:int, param4:int) : Boolean
      {
         var itmStr:String = null;
         var item:IListItemRenderer = null;
         var pt:Point = null;
         var evt:ListEvent = null;
         var more:Boolean = false;
         var str:String = param1;
         var cursorPos:CursorBookmark = param2;
         var i:int = param3;
         var stopIndex:int = param4;
         while(i != stopIndex)
         {
            itmStr = this.itemToLabel(this.iterator.current);
            itmStr = itmStr.substring(0,str.length);
            if(str == itmStr || str.toUpperCase() == itmStr.toUpperCase())
            {
               this.iterator.seek(cursorPos,0);
               this.scrollToIndex(i);
               this.commitSelectedIndex(i);
               item = this.indexToItemRenderer(i);
               pt = this.itemRendererToIndices(item);
               evt = new ListEvent(ListEvent.CHANGE);
               evt.itemRenderer = item;
               if(pt)
               {
                  evt.columnIndex = pt.x;
                  evt.rowIndex = pt.y;
               }
               dispatchEvent(evt);
               return true;
            }
            try
            {
               more = this.iterator.moveNext();
            }
            catch(e1:ItemPendingError)
            {
               e1.addResponder(new ItemResponder(findPendingResultHandler,findPendingFailureHandler,new ListBaseFindPending(str,cursorPos,CursorBookmark.CURRENT,1,i + 1,stopIndex)));
               iteratorValid = false;
               return false;
            }
            if(!more && stopIndex != this.collection.length)
            {
               i = -1;
               try
               {
                  this.iterator.seek(CursorBookmark.FIRST,0);
               }
               catch(e2:ItemPendingError)
               {
                  e2.addResponder(new ItemResponder(findPendingResultHandler,findPendingFailureHandler,new ListBaseFindPending(str,cursorPos,CursorBookmark.FIRST,0,0,stopIndex)));
                  iteratorValid = false;
                  return false;
               }
            }
            i++;
         }
         this.iterator.seek(cursorPos,0);
         this.iteratorValid = true;
         return false;
      }
      
      private function adjustAfterSort() : void
      {
         var p:String = null;
         var index:int = 0;
         var newVerticalScrollPosition:int = 0;
         var newHorizontalScrollPosition:int = 0;
         var pos:int = 0;
         var data:ListBaseSelectionData = null;
         var i:int = 0;
         for(p in this.selectedData)
         {
            i++;
         }
         index = !!this.anchorBookmark ? int(this.anchorBookmark.getViewIndex()) : -1;
         if(index >= 0)
         {
            if(i == 1)
            {
               this._selectedIndex = this.anchorIndex = this.caretIndex = index;
               data = this.selectedData[p];
               data.index = index;
            }
            newVerticalScrollPosition = this.indexToRow(index);
            if(newVerticalScrollPosition == -1)
            {
               return;
            }
            newVerticalScrollPosition = Math.min(maxVerticalScrollPosition,newVerticalScrollPosition);
            newHorizontalScrollPosition = this.indexToColumn(index);
            if(newHorizontalScrollPosition == -1)
            {
               return;
            }
            newHorizontalScrollPosition = Math.min(maxHorizontalScrollPosition,newHorizontalScrollPosition);
            pos = this.scrollPositionToIndex(newHorizontalScrollPosition,newVerticalScrollPosition);
            try
            {
               this.iterator.seek(CursorBookmark.CURRENT,pos - index);
               if(!this.iteratorValid)
               {
                  this.iteratorValid = true;
                  this.lastSeekPending = null;
               }
            }
            catch(e:ItemPendingError)
            {
               lastSeekPending = new ListBaseSeekPending(CursorBookmark.CURRENT,pos - index);
               e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
               iteratorValid = false;
               return;
            }
            super.verticalScrollPosition = newVerticalScrollPosition;
            if(this.listType != "vertical")
            {
               super.horizontalScrollPosition = newHorizontalScrollPosition;
            }
         }
         else
         {
            try
            {
               index = this.scrollPositionToIndex(this.horizontalScrollPosition,this.verticalScrollPosition - this.offscreenExtraRowsTop);
               this.iterator.seek(CursorBookmark.FIRST,index);
               if(!this.iteratorValid)
               {
                  this.iteratorValid = true;
                  this.lastSeekPending = null;
               }
            }
            catch(e:ItemPendingError)
            {
               lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,index);
               e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
               iteratorValid = false;
               return;
            }
         }
         if(i > 1)
         {
            this.commitSelectedItems(this.selectedItems);
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc3_:Point = null;
         var _loc4_:ListEvent = null;
         if(!this.selectable)
         {
            return;
         }
         if(!this.iteratorValid)
         {
            return;
         }
         if(!this.collection || this.collection.length == 0)
         {
            return;
         }
         switch(param1.keyCode)
         {
            case Keyboard.UP:
            case Keyboard.DOWN:
               this.moveSelectionVertically(param1.keyCode,param1.shiftKey,param1.ctrlKey);
               param1.stopPropagation();
               break;
            case Keyboard.LEFT:
            case Keyboard.RIGHT:
               this.moveSelectionHorizontally(param1.keyCode,param1.shiftKey,param1.ctrlKey);
               param1.stopPropagation();
               break;
            case Keyboard.END:
            case Keyboard.HOME:
            case Keyboard.PAGE_UP:
            case Keyboard.PAGE_DOWN:
               this.moveSelectionVertically(param1.keyCode,param1.shiftKey,param1.ctrlKey);
               param1.stopPropagation();
               break;
            case Keyboard.SPACE:
               if(this.caretIndex != -1 && this.caretIndex - this.verticalScrollPosition >= 0 && this.caretIndex - this.verticalScrollPosition < this.listItems.length)
               {
                  _loc2_ = this.listItems[this.caretIndex - this.verticalScrollPosition][0];
                  if(this.selectItem(_loc2_,param1.shiftKey,param1.ctrlKey))
                  {
                     _loc3_ = this.itemRendererToIndices(_loc2_);
                     _loc4_ = new ListEvent(ListEvent.CHANGE);
                     if(_loc3_)
                     {
                        _loc4_.columnIndex = _loc3_.x;
                        _loc4_.rowIndex = _loc3_.y;
                     }
                     _loc4_.itemRenderer = _loc2_;
                     dispatchEvent(_loc4_);
                  }
               }
               break;
            default:
               if(this.findKey(param1.charCode))
               {
                  param1.stopPropagation();
               }
         }
      }
      
      override protected function mouseWheelHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:ScrollEvent = null;
         if(!param1.isDefaultPrevented() && verticalScrollBar && verticalScrollBar.visible)
         {
            _loc2_ = this.verticalScrollPosition;
            _loc3_ = this.verticalScrollPosition;
            _loc3_ -= param1.delta * verticalScrollBar.lineScrollSize;
            _loc3_ = Math.max(0,Math.min(_loc3_,verticalScrollBar.maxScrollPosition));
            this.verticalScrollPosition = _loc3_;
            if(_loc2_ != this.verticalScrollPosition)
            {
               (_loc4_ = new ScrollEvent(ScrollEvent.SCROLL)).direction = ScrollEventDirection.VERTICAL;
               _loc4_.position = this.verticalScrollPosition;
               _loc4_.delta = this.verticalScrollPosition - _loc2_;
               dispatchEvent(_loc4_);
            }
            param1.preventDefault();
         }
      }
      
      protected function collectionChangeHandler(param1:Event) : void
      {
         var len:int = 0;
         var index:int = 0;
         var i:int = 0;
         var data:ListBaseSelectionData = null;
         var p:String = null;
         var selectedUID:String = null;
         var ce:CollectionEvent = null;
         var emitEvent:Boolean = false;
         var oldUID:String = null;
         var sd:ListBaseSelectionData = null;
         var requiresValueCommit:Boolean = false;
         var firstUID:String = null;
         var uid:String = null;
         var deletedItems:Array = null;
         var fakeRemove:CollectionEvent = null;
         var event:Event = param1;
         if(event is CollectionEvent)
         {
            ce = CollectionEvent(event);
            if(ce.kind == CollectionEventKind.ADD)
            {
               this.prepareDataEffect(ce);
               if(ce.location == 0 && this.verticalScrollPosition == 0)
               {
                  try
                  {
                     this.iterator.seek(CursorBookmark.FIRST);
                     if(!this.iteratorValid)
                     {
                        this.iteratorValid = true;
                        this.lastSeekPending = null;
                     }
                  }
                  catch(e:ItemPendingError)
                  {
                     lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,0);
                     e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                     iteratorValid = false;
                  }
               }
               else if(this.listType == "vertical" && this.verticalScrollPosition >= ce.location)
               {
                  super.verticalScrollPosition += ce.items.length;
               }
               emitEvent = this.adjustAfterAdd(ce.items,ce.location);
               if(emitEvent)
               {
                  dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
               }
            }
            else if(ce.kind == CollectionEventKind.REPLACE)
            {
               selectedUID = !!this.selectedItem ? this.itemToUID(this.selectedItem) : null;
               len = ce.items.length;
               i = 0;
               while(i < len)
               {
                  oldUID = this.itemToUID(ce.items[i].oldValue);
                  sd = this.selectedData[oldUID];
                  if(sd)
                  {
                     sd.data = ce.items[i].newValue;
                     delete this.selectedData[oldUID];
                     this.selectedData[this.itemToUID(sd.data)] = sd;
                     if(selectedUID == oldUID)
                     {
                        this._selectedItem = sd.data;
                        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
                     }
                  }
                  i++;
               }
               this.prepareDataEffect(ce);
            }
            else if(ce.kind == CollectionEventKind.REMOVE)
            {
               this.prepareDataEffect(ce);
               requiresValueCommit = false;
               if(this.listItems.length && this.listItems[0].length)
               {
                  firstUID = this.rowMap[this.listItems[0][0].name].uid;
                  selectedUID = !!this.selectedItem ? this.itemToUID(this.selectedItem) : null;
                  i = 0;
                  for(; i < ce.items.length; if(this.selectedData[uid])
                  {
                     this.removeSelectionData(uid);
                  },if(selectedUID == uid)
                  {
                     this._selectedItem = null;
                     this._selectedIndex = -1;
                     requiresValueCommit = true;
                  },this.removeIndicators(uid),i++)
                  {
                     uid = this.itemToUID(ce.items[i]);
                     if(uid == firstUID && this.verticalScrollPosition == 0)
                     {
                        try
                        {
                           this.iterator.seek(CursorBookmark.FIRST);
                           if(!this.iteratorValid)
                           {
                              this.iteratorValid = true;
                              this.lastSeekPending = null;
                           }
                        }
                        catch(e1:ItemPendingError)
                        {
                           lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,0);
                           e1.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                           iteratorValid = false;
                           continue;
                        }
                     }
                  }
                  if(this.listType == "vertical" && this.verticalScrollPosition >= ce.location)
                  {
                     if(this.verticalScrollPosition > ce.location)
                     {
                        super.verticalScrollPosition = this.verticalScrollPosition - Math.min(ce.items.length,this.verticalScrollPosition - ce.location);
                     }
                     else if(this.verticalScrollPosition >= this.collection.length)
                     {
                        super.verticalScrollPosition = Math.max(this.collection.length - 1,0);
                     }
                     try
                     {
                        this.offscreenExtraRowsTop = Math.min(this.offscreenExtraRowsTop,this.verticalScrollPosition);
                        index = this.scrollPositionToIndex(this.horizontalScrollPosition,this.verticalScrollPosition - this.offscreenExtraRowsTop);
                        this.iterator.seek(CursorBookmark.FIRST,index);
                        if(!this.iteratorValid)
                        {
                           this.iteratorValid = true;
                           this.lastSeekPending = null;
                        }
                     }
                     catch(e2:ItemPendingError)
                     {
                        lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,index);
                        e2.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                        iteratorValid = false;
                     }
                  }
                  emitEvent = this.adjustAfterRemove(ce.items,ce.location,requiresValueCommit);
                  if(emitEvent)
                  {
                     dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
                  }
               }
            }
            else if(ce.kind == CollectionEventKind.MOVE)
            {
               if(ce.oldLocation < ce.location)
               {
                  for(p in this.selectedData)
                  {
                     data = this.selectedData[p];
                     if(data.index > ce.oldLocation && data.index < ce.location)
                     {
                        --data.index;
                     }
                     else if(data.index == ce.oldLocation)
                     {
                        data.index = ce.location;
                     }
                  }
                  if(this._selectedIndex > ce.oldLocation && this._selectedIndex < ce.location)
                  {
                     --this._selectedIndex;
                  }
                  else if(this._selectedIndex == ce.oldLocation)
                  {
                     this._selectedIndex = ce.location;
                  }
               }
               else if(ce.location < ce.oldLocation)
               {
                  for(p in this.selectedData)
                  {
                     data = this.selectedData[p];
                     if(data.index > ce.location && data.index < ce.oldLocation)
                     {
                        ++data.index;
                     }
                     else if(data.index == ce.oldLocation)
                     {
                        data.index = ce.location;
                     }
                  }
                  if(this._selectedIndex > ce.location && this._selectedIndex < ce.oldLocation)
                  {
                     ++this._selectedIndex;
                  }
                  else if(this._selectedIndex == ce.oldLocation)
                  {
                     this._selectedIndex = ce.location;
                  }
               }
               if(ce.oldLocation == this.verticalScrollPosition)
               {
                  if(ce.location > maxVerticalScrollPosition)
                  {
                     this.iterator.seek(CursorBookmark.CURRENT,maxVerticalScrollPosition - ce.location);
                  }
                  super.verticalScrollPosition = Math.min(ce.location,maxVerticalScrollPosition);
               }
               else if(ce.location >= this.verticalScrollPosition && ce.oldLocation < this.verticalScrollPosition)
               {
                  this.seekNextSafely(this.iterator,this.verticalScrollPosition);
               }
               else if(ce.location <= this.verticalScrollPosition && ce.oldLocation > this.verticalScrollPosition)
               {
                  this.seekPreviousSafely(this.iterator,this.verticalScrollPosition);
               }
            }
            else if(ce.kind == CollectionEventKind.REFRESH)
            {
               if(this.anchorBookmark)
               {
                  try
                  {
                     this.iterator.seek(this.anchorBookmark,0);
                     if(!this.iteratorValid)
                     {
                        this.iteratorValid = true;
                        this.lastSeekPending = null;
                     }
                  }
                  catch(e:ItemPendingError)
                  {
                     bSortItemPending = true;
                     lastSeekPending = new ListBaseSeekPending(anchorBookmark,0);
                     e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                     iteratorValid = false;
                  }
                  catch(cursorError:CursorError)
                  {
                     clearSelected();
                  }
                  this.adjustAfterSort();
               }
               else
               {
                  try
                  {
                     index = this.scrollPositionToIndex(this.horizontalScrollPosition,this.verticalScrollPosition);
                     this.iterator.seek(CursorBookmark.FIRST,index);
                     if(!this.iteratorValid)
                     {
                        this.iteratorValid = true;
                        this.lastSeekPending = null;
                     }
                  }
                  catch(e:ItemPendingError)
                  {
                     bSortItemPending = true;
                     lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,index);
                     e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                     iteratorValid = false;
                  }
               }
            }
            else if(ce.kind == CollectionEventKind.RESET)
            {
               if(this.collection.length == 0 || this.runningDataEffect && this.actualCollection.length == 0)
               {
                  deletedItems = this.reconstructDataFromListItems();
                  if(deletedItems.length)
                  {
                     fakeRemove = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
                     fakeRemove.kind = CollectionEventKind.REMOVE;
                     fakeRemove.items = deletedItems;
                     fakeRemove.location = 0;
                     this.prepareDataEffect(fakeRemove);
                  }
               }
               try
               {
                  this.iterator.seek(CursorBookmark.FIRST);
                  if(!this.iteratorValid)
                  {
                     this.iteratorValid = true;
                     this.lastSeekPending = null;
                  }
                  this.collectionIterator.seek(CursorBookmark.FIRST);
               }
               catch(e:ItemPendingError)
               {
                  lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,0);
                  e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                  iteratorValid = false;
               }
               if(this.bSelectedIndexChanged || this.bSelectedItemChanged || this.bSelectedIndicesChanged || this.bSelectedItemsChanged)
               {
                  this.bSelectionChanged = true;
               }
               else
               {
                  this.commitSelectedIndex(-1);
               }
               if(isNaN(this.verticalScrollPositionPending))
               {
                  this.verticalScrollPositionPending = 0;
                  super.verticalScrollPosition = 0;
               }
               if(isNaN(this.horizontalScrollPositionPending))
               {
                  this.horizontalScrollPositionPending = 0;
                  super.horizontalScrollPosition = 0;
               }
               invalidateSize();
            }
            else if(ce.kind == CollectionEventKind.UPDATE)
            {
               selectedUID = !!this.selectedItem ? this.itemToUID(this.selectedItem) : null;
               len = ce.items.length;
               i = 0;
               while(i < len)
               {
                  if(ce.items[i].property == "uid")
                  {
                     oldUID = ce.items[i].oldValue;
                     sd = this.selectedData[oldUID];
                     if(sd)
                     {
                        sd.data = ce.items[i].target;
                        delete this.selectedData[oldUID];
                        this.selectedData[ce.items[i].newValue] = sd;
                        if(selectedUID == oldUID)
                        {
                           this._selectedItem = sd.data;
                           dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
                        }
                     }
                  }
                  i++;
               }
            }
         }
         this.itemsSizeChanged = true;
         invalidateDisplayList();
      }
      
      mx_internal function reconstructDataFromListItems() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:IListItemRenderer = null;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         if(!this.listItems)
         {
            return [];
         }
         _loc1_ = [];
         _loc2_ = 0;
         while(_loc2_ < this.listItems.length)
         {
            if(this.listItems[_loc2_])
            {
               _loc3_ = this.listItems[_loc2_][0] as IListItemRenderer;
               if(_loc3_)
               {
                  _loc4_ = _loc3_.data;
                  _loc1_.push(_loc4_);
                  _loc6_ = 0;
                  while(_loc6_ < this.listItems[_loc2_].length)
                  {
                     _loc3_ = this.listItems[_loc2_][_loc6_] as IListItemRenderer;
                     if(_loc3_)
                     {
                        if((_loc5_ = _loc3_.data) != _loc4_)
                        {
                           _loc1_.push(_loc5_);
                        }
                     }
                     _loc6_++;
                  }
               }
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      protected function prepareDataEffect(param1:CollectionEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Class = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(!this.cachedItemsChangeEffect)
         {
            _loc2_ = getStyle("itemsChangeEffect");
            _loc3_ = _loc2_ as Class;
            if(_loc3_)
            {
               _loc2_ = new _loc3_();
            }
            this.cachedItemsChangeEffect = _loc2_ as IEffect;
         }
         if(this.runningDataEffect)
         {
            this.collection = this.actualCollection;
            this.listContent.iterator = this.iterator = this.actualIterator;
            this.cachedItemsChangeEffect.end();
            this.modifiedCollectionView = null;
         }
         if(this.cachedItemsChangeEffect && this.iteratorValid)
         {
            _loc5_ = (_loc4_ = this.iterator.bookmark.getViewIndex()) + this.rowCount * this.columnCount - 1;
            if(!this.modifiedCollectionView && this.collection is IList)
            {
               this.modifiedCollectionView = new ModifiedCollectionView(ICollectionView(this.collection));
            }
            if(this.modifiedCollectionView)
            {
               this.modifiedCollectionView.processCollectionEvent(param1,_loc4_,_loc5_);
               this.runDataEffectNextUpdate = true;
               if(mx_internal::invalidateDisplayListFlag)
               {
                  callLater(this.invalidateList);
               }
               else
               {
                  this.invalidateList();
               }
            }
         }
      }
      
      protected function adjustAfterAdd(param1:Array, param2:int) : Boolean
      {
         var length:int = 0;
         var requiresValueCommit:Boolean = false;
         var data:ListBaseSelectionData = null;
         var placeHolder:CursorBookmark = null;
         var p:String = null;
         var items:Array = param1;
         var location:int = param2;
         length = items.length;
         requiresValueCommit = false;
         for(p in this.selectedData)
         {
            data = this.selectedData[p];
            if(data.index >= location)
            {
               data.index += length;
            }
         }
         if(this._selectedIndex >= location)
         {
            this._selectedIndex += length;
            requiresValueCommit = true;
         }
         if(this.anchorIndex >= location)
         {
            this.anchorIndex += length;
            placeHolder = this.iterator.bookmark;
            try
            {
               this.iterator.seek(CursorBookmark.FIRST,this.anchorIndex);
               this.anchorBookmark = this.iterator.bookmark;
            }
            catch(e:ItemPendingError)
            {
               e.addResponder(new ItemResponder(mx_internal::setBookmarkPendingResultHandler,mx_internal::setBookmarkPendingFailureHandler,{
                  "property":"anchorBookmark",
                  "value":anchorIndex
               }));
            }
            this.iterator.seek(placeHolder);
         }
         if(this.caretIndex >= location)
         {
            this.caretIndex += length;
            placeHolder = this.iterator.bookmark;
            try
            {
               this.iterator.seek(CursorBookmark.FIRST,this.caretIndex);
               this.caretBookmark = this.iterator.bookmark;
            }
            catch(e:ItemPendingError)
            {
               e.addResponder(new ItemResponder(mx_internal::setBookmarkPendingResultHandler,mx_internal::setBookmarkPendingFailureHandler,{
                  "property":"caretBookmark",
                  "value":caretIndex
               }));
            }
            this.iterator.seek(placeHolder);
         }
         return requiresValueCommit;
      }
      
      protected function adjustAfterRemove(param1:Array, param2:int, param3:Boolean) : Boolean
      {
         var data:ListBaseSelectionData = null;
         var requiresValueCommit:Boolean = false;
         var i:int = 0;
         var length:int = 0;
         var placeHolder:CursorBookmark = null;
         var s:String = null;
         var items:Array = param1;
         var location:int = param2;
         var emitEvent:Boolean = param3;
         requiresValueCommit = emitEvent;
         i = 0;
         length = items.length;
         for(s in this.selectedData)
         {
            i++;
            data = this.selectedData[s];
            if(data.index > location)
            {
               data.index -= length;
            }
         }
         if(this._selectedIndex > location)
         {
            this._selectedIndex -= length;
            requiresValueCommit = true;
         }
         if(i > 0 && this._selectedIndex == -1)
         {
            this._selectedIndex = data.index;
            this._selectedItem = data.data;
            requiresValueCommit = true;
         }
         if(i == 0)
         {
            this._selectedIndex = -1;
            this.bSelectionChanged = true;
            this.bSelectedIndexChanged = true;
            invalidateDisplayList();
         }
         if(this.anchorIndex > location)
         {
            this.anchorIndex -= length;
            placeHolder = this.iterator.bookmark;
            try
            {
               this.iterator.seek(CursorBookmark.FIRST,this.anchorIndex);
               this.anchorBookmark = this.iterator.bookmark;
            }
            catch(e:ItemPendingError)
            {
               e.addResponder(new ItemResponder(mx_internal::setBookmarkPendingResultHandler,mx_internal::setBookmarkPendingFailureHandler,{
                  "property":"anchorBookmark",
                  "value":anchorIndex
               }));
            }
            this.iterator.seek(placeHolder);
         }
         if(this.caretIndex > location)
         {
            this.caretIndex -= length;
            placeHolder = this.iterator.bookmark;
            try
            {
               this.iterator.seek(CursorBookmark.FIRST,this.caretIndex);
               this.caretBookmark = this.iterator.bookmark;
            }
            catch(e:ItemPendingError)
            {
               e.addResponder(new ItemResponder(mx_internal::setBookmarkPendingResultHandler,mx_internal::setBookmarkPendingFailureHandler,{
                  "property":"caretBookmark",
                  "value":caretIndex
               }));
            }
            this.iterator.seek(placeHolder);
         }
         return requiresValueCommit;
      }
      
      mx_internal function setBookmarkPendingFailureHandler(param1:Object, param2:Object) : void
      {
      }
      
      mx_internal function setBookmarkPendingResultHandler(param1:Object, param2:Object) : void
      {
         var placeHolder:CursorBookmark = null;
         var data:Object = param1;
         var info:Object = param2;
         placeHolder = this.iterator.bookmark;
         try
         {
            this.iterator.seek(CursorBookmark.FIRST,info.value);
            this[info.property] = this.iterator.bookmark;
         }
         catch(e:ItemPendingError)
         {
            e.addResponder(new ItemResponder(mx_internal::setBookmarkPendingResultHandler,mx_internal::setBookmarkPendingFailureHandler,info));
         }
         this.iterator.seek(placeHolder);
      }
      
      protected function mouseOverHandler(param1:MouseEvent) : void
      {
         var _loc2_:ListEvent = null;
         var _loc3_:IListItemRenderer = null;
         var _loc4_:Point = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:BaseListData = null;
         if(!enabled || !this.selectable)
         {
            return;
         }
         if(this.dragScrollingInterval != 0 && !param1.buttonDown)
         {
            this.mouseIsUp();
         }
         this.isPressed = param1.buttonDown;
         _loc3_ = this.mouseEventToItemRenderer(param1);
         _loc4_ = this.itemRendererToIndices(_loc3_);
         if(!_loc3_)
         {
            return;
         }
         _loc5_ = this.itemToUID(_loc3_.data);
         if(!this.isPressed || this.allowDragSelection)
         {
            if(param1.relatedObject)
            {
               if(this.lastHighlightItemRenderer && this.highlightUID)
               {
                  _loc6_ = (_loc7_ = this.rowMap[_loc3_.name]).uid;
               }
               if(this.itemRendererContains(_loc3_,param1.relatedObject) || _loc5_ == _loc6_ || param1.relatedObject == this.highlightIndicator)
               {
                  return;
               }
            }
            if(getStyle("useRollOver") && _loc3_.data != null)
            {
               if(this.allowDragSelection)
               {
                  this.bSelectOnRelease = true;
               }
               this.drawItem(this.UIDToItemRenderer(_loc5_),this.isItemSelected(_loc3_.data),true,_loc5_ == this.caretUID);
               if(_loc4_)
               {
                  _loc2_ = new ListEvent(ListEvent.ITEM_ROLL_OVER);
                  _loc2_.columnIndex = _loc4_.x;
                  _loc2_.rowIndex = _loc4_.y;
                  _loc2_.itemRenderer = _loc3_;
                  dispatchEvent(_loc2_);
                  this.lastHighlightItemIndices = _loc4_;
                  this.lastHighlightItemRendererAtIndices = _loc3_;
               }
            }
         }
         else
         {
            if(DragManager.isDragging)
            {
               return;
            }
            if(this.dragScrollingInterval != 0 && this.allowDragSelection || this.menuSelectionMode)
            {
               if(this.selectItem(_loc3_,param1.shiftKey,param1.ctrlKey))
               {
                  _loc2_ = new ListEvent(ListEvent.CHANGE);
                  _loc2_.itemRenderer = _loc3_;
                  if(_loc4_)
                  {
                     _loc2_.columnIndex = _loc4_.x;
                     _loc2_.rowIndex = _loc4_.y;
                  }
                  dispatchEvent(_loc2_);
               }
            }
         }
      }
      
      protected function mouseOutHandler(param1:MouseEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         if(!enabled || !this.selectable)
         {
            return;
         }
         this.isPressed = param1.buttonDown;
         _loc2_ = this.mouseEventToItemRenderer(param1);
         if(!_loc2_)
         {
            return;
         }
         if(!this.isPressed)
         {
            if(this.itemRendererContains(_loc2_,param1.relatedObject) || param1.relatedObject == this.listContent || param1.relatedObject == this.highlightIndicator || !this.highlightItemRenderer)
            {
               return;
            }
            if(getStyle("useRollOver") && _loc2_.data != null)
            {
               this.clearHighlight(_loc2_);
            }
         }
      }
      
      protected function mouseMoveHandler(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:IListItemRenderer = null;
         var _loc4_:DragEvent = null;
         var _loc5_:BaseListData = null;
         if(!enabled || !this.selectable)
         {
            return;
         }
         _loc2_ = new Point(param1.localX,param1.localY);
         _loc2_ = DisplayObject(param1.target).localToGlobal(_loc2_);
         _loc2_ = globalToLocal(_loc2_);
         if(this.isPressed && this.mouseDownPoint && (Math.abs(this.mouseDownPoint.x - _loc2_.x) > mx_internal::DRAG_THRESHOLD || Math.abs(this.mouseDownPoint.y - _loc2_.y) > mx_internal::DRAG_THRESHOLD))
         {
            if(this.dragEnabled && !DragManager.isDragging && this.mouseDownPoint)
            {
               (_loc4_ = new DragEvent(DragEvent.DRAG_START)).dragInitiator = this;
               _loc4_.localX = this.mouseDownPoint.x;
               _loc4_.localY = this.mouseDownPoint.y;
               _loc4_.buttonDown = true;
               dispatchEvent(_loc4_);
            }
         }
         _loc3_ = this.mouseEventToItemRenderer(param1);
         if(_loc3_ && this.highlightItemRenderer)
         {
            _loc5_ = this.rowMap[_loc3_.name];
            if(this.highlightItemRenderer && this.highlightUID && _loc5_.uid != this.highlightUID)
            {
               if(!this.isPressed)
               {
                  if(getStyle("useRollOver") && this.highlightItemRenderer.data != null)
                  {
                     this.clearHighlight(this.highlightItemRenderer);
                  }
               }
            }
         }
         else if(!_loc3_ && this.highlightItemRenderer)
         {
            if(!this.isPressed)
            {
               if(getStyle("useRollOver") && this.highlightItemRenderer.data)
               {
                  this.clearHighlight(this.highlightItemRenderer);
               }
            }
         }
         if(_loc3_ && !this.highlightItemRenderer)
         {
            this.mouseOverHandler(param1);
         }
      }
      
      protected function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc3_:Point = null;
         if(!enabled || !this.selectable)
         {
            return;
         }
         if(this.runningDataEffect)
         {
            this.cachedItemsChangeEffect.end();
            this.dataEffectCompleted = true;
            this.itemsSizeChanged = true;
            this.invalidateList();
            this.dataItemWrappersByRenderer = new Dictionary();
            this.validateDisplayList();
         }
         this.isPressed = true;
         _loc2_ = this.mouseEventToItemRenderer(param1);
         if(!_loc2_)
         {
            return;
         }
         this.bSelectOnRelease = false;
         _loc3_ = new Point(param1.localX,param1.localY);
         _loc3_ = DisplayObject(param1.target).localToGlobal(_loc3_);
         this.mouseDownPoint = globalToLocal(_loc3_);
         systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true,0,true);
         systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.mouseLeaveHandler,false,0,true);
         if(!this.dragEnabled)
         {
            this.dragScrollingInterval = setInterval(this.dragScroll,15);
         }
         if(this.dragEnabled)
         {
            this.mouseDownIndex = this.itemRendererToIndex(_loc2_);
         }
         if(this.dragEnabled && this.selectedData[this.rowMap[_loc2_.name].uid])
         {
            this.bSelectOnRelease = true;
         }
         else if(this.selectItem(_loc2_,param1.shiftKey,param1.ctrlKey))
         {
            this.mouseDownItem = _loc2_;
         }
      }
      
      private function mouseIsUp() : void
      {
         systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true);
         systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.mouseLeaveHandler);
         if(this.dragScrollingInterval != 0)
         {
            clearInterval(this.dragScrollingInterval);
            this.dragScrollingInterval = 0;
         }
      }
      
      private function mouseLeaveHandler(param1:Event) : void
      {
         var _loc2_:ListEvent = null;
         var _loc3_:Point = null;
         this.mouseDownPoint = null;
         this.mouseDownIndex = -1;
         this.mouseIsUp();
         if(!enabled || !this.selectable)
         {
            return;
         }
         if(this.mouseDownItem)
         {
            _loc2_ = new ListEvent(ListEvent.CHANGE);
            _loc2_.itemRenderer = this.mouseDownItem;
            _loc3_ = this.itemRendererToIndices(this.mouseDownItem);
            if(_loc3_)
            {
               _loc2_.columnIndex = _loc3_.x;
               _loc2_.rowIndex = _loc3_.y;
            }
            dispatchEvent(_loc2_);
            this.mouseDownItem = null;
         }
         this.isPressed = false;
      }
      
      protected function mouseUpHandler(param1:MouseEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc3_:Point = null;
         var _loc4_:ListEvent = null;
         this.mouseDownPoint = null;
         this.mouseDownIndex = -1;
         _loc2_ = this.mouseEventToItemRenderer(param1);
         _loc3_ = this.itemRendererToIndices(_loc2_);
         this.mouseIsUp();
         if(!enabled || !this.selectable)
         {
            return;
         }
         if(this.mouseDownItem)
         {
            (_loc4_ = new ListEvent(ListEvent.CHANGE)).itemRenderer = this.mouseDownItem;
            _loc3_ = this.itemRendererToIndices(this.mouseDownItem);
            if(_loc3_)
            {
               _loc4_.columnIndex = _loc3_.x;
               _loc4_.rowIndex = _loc3_.y;
            }
            dispatchEvent(_loc4_);
            this.mouseDownItem = null;
         }
         if(!_loc2_ || !hitTestPoint(param1.stageX,param1.stageY))
         {
            this.isPressed = false;
            return;
         }
         if(this.bSelectOnRelease)
         {
            this.bSelectOnRelease = false;
            if(this.selectItem(_loc2_,param1.shiftKey,param1.ctrlKey))
            {
               (_loc4_ = new ListEvent(ListEvent.CHANGE)).itemRenderer = _loc2_;
               if(_loc3_)
               {
                  _loc4_.columnIndex = _loc3_.x;
                  _loc4_.rowIndex = _loc3_.y;
               }
               dispatchEvent(_loc4_);
            }
         }
         this.isPressed = false;
      }
      
      protected function mouseClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc3_:Point = null;
         var _loc4_:ListEvent = null;
         _loc2_ = this.mouseEventToItemRenderer(param1);
         if(!_loc2_)
         {
            return;
         }
         _loc3_ = this.itemRendererToIndices(_loc2_);
         if(_loc3_)
         {
            (_loc4_ = new ListEvent(ListEvent.ITEM_CLICK)).columnIndex = _loc3_.x;
            _loc4_.rowIndex = _loc3_.y;
            _loc4_.itemRenderer = _loc2_;
            dispatchEvent(_loc4_);
         }
      }
      
      protected function mouseDoubleClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc3_:Point = null;
         var _loc4_:ListEvent = null;
         _loc2_ = this.mouseEventToItemRenderer(param1);
         if(!_loc2_)
         {
            return;
         }
         _loc3_ = this.itemRendererToIndices(_loc2_);
         if(_loc3_)
         {
            (_loc4_ = new ListEvent(ListEvent.ITEM_DOUBLE_CLICK)).columnIndex = _loc3_.x;
            _loc4_.rowIndex = _loc3_.y;
            _loc4_.itemRenderer = _loc2_;
            dispatchEvent(_loc4_);
         }
      }
      
      protected function dragStartHandler(param1:DragEvent) : void
      {
         var _loc2_:DragSource = null;
         if(param1.isDefaultPrevented())
         {
            return;
         }
         _loc2_ = new DragSource();
         this.addDragData(_loc2_);
         DragManager.doDrag(this,_loc2_,param1,this.dragImage,0,0,0.5,this.dragMoveEnabled);
      }
      
      protected function dragEnterHandler(param1:DragEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         this.lastDragEvent = param1;
         if(enabled && this.iteratorValid && (param1.dragSource.hasFormat("items") || param1.dragSource.hasFormat("itemsByIndex")))
         {
            DragManager.acceptDragDrop(this);
            DragManager.showFeedback(!!param1.ctrlKey ? DragManager.COPY : DragManager.MOVE);
            this.showDropFeedback(param1);
            return;
         }
         this.hideDropFeedback(param1);
         DragManager.showFeedback(DragManager.NONE);
      }
      
      protected function dragOverHandler(param1:DragEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         this.lastDragEvent = param1;
         if(enabled && this.iteratorValid && (param1.dragSource.hasFormat("items") || param1.dragSource.hasFormat("itemsByIndex")))
         {
            DragManager.showFeedback(!!param1.ctrlKey ? DragManager.COPY : DragManager.MOVE);
            this.showDropFeedback(param1);
            return;
         }
         this.hideDropFeedback(param1);
         DragManager.showFeedback(DragManager.NONE);
      }
      
      protected function dragExitHandler(param1:DragEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         this.lastDragEvent = null;
         this.hideDropFeedback(param1);
         this.resetDragScrolling();
         DragManager.showFeedback(DragManager.NONE);
      }
      
      protected function dragDropHandler(param1:DragEvent) : void
      {
         var _loc2_:DragSource = null;
         var _loc3_:int = 0;
         if(param1.isDefaultPrevented())
         {
            return;
         }
         this.hideDropFeedback(param1);
         this.lastDragEvent = null;
         this.resetDragScrolling();
         if(!enabled)
         {
            return;
         }
         _loc2_ = param1.dragSource;
         if(!_loc2_.hasFormat("items") && !_loc2_.hasFormat("itemsByIndex"))
         {
            return;
         }
         if(!this.dataProvider)
         {
            this.dataProvider = [];
         }
         _loc3_ = this.calculateDropIndex(param1);
         if(_loc2_.hasFormat("items"))
         {
            this.insertItems(_loc3_,_loc2_,param1);
         }
         else
         {
            this.insertItemsByIndex(_loc3_,_loc2_,param1);
         }
         this.lastDragEvent = null;
      }
      
      private function insertItemsByIndex(param1:int, param2:DragSource, param3:DragEvent) : void
      {
         var _loc4_:Vector.<Object> = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         _loc4_ = param2.dataForFormat("itemsByIndex") as Vector.<Object>;
         this.collectionIterator.seek(CursorBookmark.FIRST,param1);
         _loc5_ = _loc4_.length;
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            if(param3.action == DragManager.COPY)
            {
               this.collectionIterator.insert(this.copyItemWithUID(_loc4_[_loc6_]));
            }
            else if(param3.action == DragManager.MOVE)
            {
               this.collectionIterator.insert(_loc4_[_loc6_]);
            }
            _loc6_++;
         }
      }
      
      private function insertItems(param1:int, param2:DragSource, param3:DragEvent) : void
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         _loc4_ = param2.dataForFormat("items") as Array;
         if(param3.action == DragManager.MOVE && this.dragMoveEnabled && param3.dragInitiator == this)
         {
            (_loc5_ = this.selectedIndices).sort(Array.NUMERIC);
            _loc6_ = _loc5_.length - 1;
            while(_loc6_ >= 0)
            {
               this.collectionIterator.seek(CursorBookmark.FIRST,_loc5_[_loc6_]);
               if(_loc5_[_loc6_] < param1)
               {
                  param1--;
               }
               this.collectionIterator.remove();
               _loc6_--;
            }
            this.clearSelected(false);
         }
         this.collectionIterator.seek(CursorBookmark.FIRST,param1);
         _loc6_ = _loc4_.length - 1;
         while(_loc6_ >= 0)
         {
            if(param3.action == DragManager.COPY)
            {
               this.collectionIterator.insert(this.copyItemWithUID(_loc4_[_loc6_]));
            }
            else if(param3.action == DragManager.MOVE)
            {
               this.collectionIterator.insert(_loc4_[_loc6_]);
            }
            _loc6_--;
         }
      }
      
      protected function copyItemWithUID(param1:Object) : Object
      {
         var _loc2_:Object = null;
         _loc2_ = ObjectUtil.copy(param1);
         if(_loc2_ is IUID)
         {
            IUID(_loc2_).uid = UIDUtil.createUID();
         }
         else if(_loc2_ is Object && "mx_internal_uid" in _loc2_)
         {
            _loc2_.mx_internal_uid = UIDUtil.createUID();
         }
         return _loc2_;
      }
      
      protected function dragCompleteHandler(param1:DragEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.isPressed = false;
         if(param1.isDefaultPrevented())
         {
            return;
         }
         if(param1.action == DragManager.MOVE && this.dragMoveEnabled)
         {
            if(param1.relatedObject != this)
            {
               _loc2_ = this.selectedIndices;
               this.clearSelected(false);
               _loc2_.sort(Array.NUMERIC);
               _loc3_ = _loc2_.length;
               _loc4_ = _loc3_ - 1;
               while(_loc4_ >= 0)
               {
                  this.collectionIterator.seek(CursorBookmark.FIRST,_loc2_[_loc4_]);
                  this.collectionIterator.remove();
                  _loc4_--;
               }
            }
         }
         this.lastDragEvent = null;
         this.resetDragScrolling();
      }
      
      mx_internal function selectionTween_updateHandler(param1:TweenEvent) : void
      {
         Sprite(param1.target.listener).alpha = Number(param1.value);
      }
      
      mx_internal function selectionTween_endHandler(param1:TweenEvent) : void
      {
         this.selectionTween_updateHandler(param1);
      }
      
      private function rendererMoveHandler(param1:MoveEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         if(!this.rendererTrackingSuspended)
         {
            _loc2_ = param1.currentTarget as IListItemRenderer;
            this.drawItem(_loc2_,true);
         }
      }
      
      private function strictEqualityCompareFunction(param1:Object, param2:Object) : Boolean
      {
         return param1 === param2;
      }
      
      mx_internal function getListVisibleData() : Object
      {
         return this.visibleData;
      }
      
      mx_internal function getItemUID(param1:Object) : String
      {
         return this.itemToUID(param1);
      }
      
      mx_internal function getItemRendererForMouseEvent(param1:MouseEvent) : IListItemRenderer
      {
         return this.mouseEventToItemRenderer(param1);
      }
      
      mx_internal function getListContentHolder() : ListBaseContentHolder
      {
         return this.listContent;
      }
      
      mx_internal function getRowInfo() : Array
      {
         return this.rowInfo;
      }
      
      mx_internal function convertIndexToRow(param1:int) : int
      {
         return this.indexToRow(param1);
      }
      
      mx_internal function convertIndexToColumn(param1:int) : int
      {
         return this.indexToColumn(param1);
      }
      
      mx_internal function getCaretIndex() : int
      {
         return this.caretIndex;
      }
      
      mx_internal function getIterator() : IViewCursor
      {
         return this.iterator;
      }
   }
}
