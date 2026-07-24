package mx.controls
{
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import mx.collections.CursorBookmark;
   import mx.collections.ICollectionView;
   import mx.collections.ISort;
   import mx.collections.ISortField;
   import mx.collections.ItemResponder;
   import mx.collections.Sort;
   import mx.collections.SortField;
   import mx.collections.errors.ItemPendingError;
   import mx.controls.dataGridClasses.DataGridBase;
   import mx.controls.dataGridClasses.DataGridColumn;
   import mx.controls.dataGridClasses.DataGridDragProxy;
   import mx.controls.dataGridClasses.DataGridHeader;
   import mx.controls.dataGridClasses.DataGridItemRenderer;
   import mx.controls.dataGridClasses.DataGridListData;
   import mx.controls.listClasses.BaseListData;
   import mx.controls.listClasses.IDropInListItemRenderer;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.controls.listClasses.ListBaseContentHolder;
   import mx.controls.listClasses.ListBaseSeekPending;
   import mx.controls.listClasses.ListRowInfo;
   import mx.controls.scrollClasses.ScrollBar;
   import mx.core.ContextualClassFactory;
   import mx.core.EdgeMetrics;
   import mx.core.EventPriority;
   import mx.core.FlexShape;
   import mx.core.FlexSprite;
   import mx.core.IFactory;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IIMESupport;
   import mx.core.IInvalidating;
   import mx.core.IPropertyChangeNotifier;
   import mx.core.IUIComponent;
   import mx.core.ScrollPolicy;
   import mx.core.UIComponent;
   import mx.core.UIComponentGlobals;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.DataGridEvent;
   import mx.events.DataGridEventReason;
   import mx.events.DragEvent;
   import mx.events.IndexChangedEvent;
   import mx.events.ListEvent;
   import mx.events.SandboxMouseEvent;
   import mx.events.ScrollEvent;
   import mx.events.ScrollEventDetail;
   import mx.managers.IFocusManager;
   import mx.managers.IFocusManagerComponent;
   import mx.skins.halo.ListDropIndicator;
   import mx.styles.ISimpleStyleClient;
   import mx.utils.ObjectUtil;
   import mx.utils.StringUtil;
   
   use namespace mx_internal;
   
   public class DataGrid extends DataGridBase implements IIMESupport
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      mx_internal static var createAccessibilityImplementation:Function;
       
      
      public var itemEditorInstance:IListItemRenderer;
      
      private var skipHeaderUpdate:Boolean = false;
      
      private var dontEdit:Boolean = false;
      
      private var losingFocus:Boolean = false;
      
      private var inEndEdit:Boolean = false;
      
      private var collectionUpdatesDisabled:Boolean = false;
      
      mx_internal var sortIndex:int = -1;
      
      private var sortColumn:DataGridColumn;
      
      mx_internal var sortDirection:String;
      
      mx_internal var lastSortIndex:int = -1;
      
      private var lastItemDown:IListItemRenderer;
      
      private var lastItemFocused:DisplayObject;
      
      private var displayWidth:Number;
      
      private var lockedColumnWidth:Number = 0;
      
      mx_internal var movingColumn:DataGridColumn;
      
      mx_internal var resizingColumn:DataGridColumn;
      
      private var displayableColumns:Array;
      
      private var generatedColumns:Boolean = true;
      
      private var actualRowIndex:int;
      
      private var actualColIndex:int;
      
      private var actualContentHolder:ListBaseContentHolder;
      
      private var manualSort:Boolean;
      
      private var _imeMode:String = null;
      
      private var _minColumnWidth:Number;
      
      private var minColumnWidthInvalid:Boolean = false;
      
      private var _columns:Array;
      
      private var _draggableColumns:Boolean = true;
      
      private var _editable:Boolean = false;
      
      private var bEditedItemPositionChanged:Boolean = false;
      
      private var _proposedEditedItemPosition;
      
      private var lastEditedItemPosition;
      
      private var _editedItemPosition:Object;
      
      private var itemEditorPositionChanged:Boolean = false;
      
      public var resizableColumns:Boolean = true;
      
      public var sortableColumns:Boolean = true;
      
      private var _headerWordWrapPresent:Boolean = false;
      
      private var _originalExplicitHeaderHeight:Boolean = false;
      
      private var _originalHeaderHeight:Number = 0;
      
      private var _focusPane:Sprite;
      
      mx_internal var lockedColumnDropIndicator:IFlexDisplayObject;
      
      public function DataGrid()
      {
         super();
         this._columns = [];
         setRowHeight(20);
         addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING,this.itemEditorItemEditBeginningHandler,false,EventPriority.DEFAULT_HANDLER);
         addEventListener(DataGridEvent.ITEM_EDIT_BEGIN,this.itemEditorItemEditBeginHandler,false,EventPriority.DEFAULT_HANDLER);
         addEventListener(DataGridEvent.ITEM_EDIT_END,this.itemEditorItemEditEndHandler,false,EventPriority.DEFAULT_HANDLER);
         addEventListener(DataGridEvent.HEADER_RELEASE,this.headerReleaseHandler,false,EventPriority.DEFAULT_HANDLER);
         addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
      }
      
      public function get editedItemRenderer() : IListItemRenderer
      {
         if(!this.itemEditorInstance)
         {
            return null;
         }
         return this.actualContentHolder.listItems[this.actualRowIndex][this.actualColIndex];
      }
      
      override public function get baselinePosition() : Number
      {
         if(!validateBaselinePosition())
         {
            return NaN;
         }
         if(!showHeaders)
         {
            return super.baselinePosition;
         }
         var _loc1_:IUIComponent = DataGridHeader(header).rendererArray[0];
         if(!_loc1_)
         {
            return super.baselinePosition;
         }
         return header.y + _loc1_.y + _loc1_.baselinePosition;
      }
      
      override public function get columnCount() : int
      {
         if(this._columns)
         {
            return this._columns.length;
         }
         return 0;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         if(header)
         {
            header.enabled = param1;
         }
         if(this.itemEditorInstance)
         {
            this.endEdit(DataGridEventReason.OTHER);
         }
         this.invalidateDisplayList();
      }
      
      override public function set headerHeight(param1:Number) : void
      {
         super.headerHeight = param1;
         this._originalHeaderHeight = !!isNaN(param1) ? Number(22) : Number(param1);
         this._originalExplicitHeaderHeight = !isNaN(param1);
      }
      
      override public function set horizontalScrollPosition(param1:Number) : void
      {
         var _loc3_:CursorBookmark = null;
         var _loc4_:CursorBookmark = null;
         if(!initialized || listItems.length == 0)
         {
            super.horizontalScrollPosition = param1;
            return;
         }
         var _loc2_:int = super.horizontalScrollPosition;
         super.horizontalScrollPosition = param1;
         scrollAreaChanged = true;
         columnsInvalid = true;
         this.calculateColumnSizes();
         if(itemsSizeChanged)
         {
            return;
         }
         if(_loc2_ != param1)
         {
            removeClipMask();
            if(iterator)
            {
               _loc3_ = iterator.bookmark;
            }
            clearIndicators();
            clearVisibleData();
            this.makeRowsAndColumns(0,0,listContent.width,listContent.height,0,0);
            if(lockedRowCount)
            {
               _loc4_ = lockedRowContent.iterator.bookmark;
               makeRows(lockedRowContent,0,0,unscaledWidth,unscaledHeight,0,0,true,lockedRowCount);
               if(iteratorValid)
               {
                  lockedRowContent.iterator.seek(_loc4_,0);
               }
            }
            if(mx_internal::headerVisible && header)
            {
               header.visibleColumns = mx_internal::visibleColumns;
               header.headerItemsChanged = true;
               header.invalidateSize();
               header.validateNow();
            }
            if(iterator && _loc3_)
            {
               iterator.seek(_loc3_,0);
            }
            this.invalidateDisplayList();
            addClipMask(false);
         }
      }
      
      override public function set horizontalScrollPolicy(param1:String) : void
      {
         super.horizontalScrollPolicy = param1;
         columnsInvalid = true;
         itemsSizeChanged = true;
         this.invalidateDisplayList();
      }
      
      override public function set itemRenderer(param1:IFactory) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         super.itemRenderer = param1;
         if(this.columns)
         {
            _loc2_ = this.columns.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               this.columns[_loc3_].resetFactories();
               _loc3_++;
            }
         }
      }
      
      override public function set verticalScrollPosition(param1:Number) : void
      {
         this.skipHeaderUpdate = true;
         var _loc2_:Number = super.verticalScrollPosition;
         super.verticalScrollPosition = param1;
         if(_loc2_ != param1)
         {
            if(lockedColumnContent)
            {
               this.drawRowGraphics(lockedColumnContent);
            }
         }
         this.skipHeaderUpdate = false;
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         if(!header)
         {
            header = new headerClass();
            header.styleName = this;
            addChild(header);
         }
      }
      
      public function get enableIME() : Boolean
      {
         return false;
      }
      
      public function get imeMode() : String
      {
         return this._imeMode;
      }
      
      public function set imeMode(param1:String) : void
      {
         this._imeMode = param1;
      }
      
      override public function get itemRenderer() : IFactory
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:* = false;
         var _loc5_:* = false;
         var _loc6_:IFlexModuleFactory = null;
         var _loc7_:Class = null;
         if(super.itemRenderer == null)
         {
            _loc1_ = StringUtil.trimArrayElements(getStyle("fontFamily"),",");
            _loc2_ = getStyle("fontWeight");
            _loc3_ = getStyle("fontStyle");
            _loc4_ = _loc2_ == "bold";
            _loc5_ = _loc3_ == "italic";
            _loc6_ = getFontContext(_loc1_,_loc4_,_loc5_);
            if(!(_loc7_ = getStyle("defaultDataGridItemRenderer")))
            {
               _loc7_ = DataGridItemRenderer;
            }
            super.itemRenderer = new ContextualClassFactory(_loc7_,_loc6_);
         }
         return super.itemRenderer;
      }
      
      public function get minColumnWidth() : Number
      {
         return this._minColumnWidth;
      }
      
      public function set minColumnWidth(param1:Number) : void
      {
         this._minColumnWidth = param1;
         this.minColumnWidthInvalid = true;
         itemsSizeChanged = true;
         columnsInvalid = true;
         this.invalidateDisplayList();
      }
      
      [Bindable("columnsChanged")]
      override public function get columns() : Array
      {
         return this._columns.slice(0);
      }
      
      override public function set columns(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:DataGridColumn = null;
         var _loc5_:DisplayObject = null;
         _loc2_ = this._columns.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            this.columnRendererChanged(this._columns[_loc3_]);
            _loc3_++;
         }
         freeItemRenderersTable = new Dictionary(false);
         columnMap = {};
         this._columns = param1.slice(0);
         columnsInvalid = true;
         this.generatedColumns = false;
         _loc2_ = param1.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            (_loc4_ = this._columns[_loc3_]).owner = this;
            _loc4_.colNum = _loc3_;
            if(_loc4_.cachedHeaderRenderer)
            {
               if((_loc5_ = _loc4_.cachedHeaderRenderer as DisplayObject).parent)
               {
                  _loc5_.parent.removeChild(_loc5_);
               }
               _loc4_.cachedHeaderRenderer = null;
            }
            _loc3_++;
         }
         this.updateSortIndexAndDirection();
         fontContextChanged = true;
         invalidateProperties();
         itemsSizeChanged = true;
         this.invalidateDisplayList();
         dispatchEvent(new Event("columnsChanged"));
      }
      
      public function get draggableColumns() : Boolean
      {
         return this._draggableColumns;
      }
      
      public function set draggableColumns(param1:Boolean) : void
      {
         this._draggableColumns = param1;
      }
      
      public function get editable() : Boolean
      {
         return this._editable;
      }
      
      public function set editable(param1:Boolean) : void
      {
         this._editable = param1;
      }
      
      [Bindable("itemFocusIn")]
      public function get editedItemPosition() : Object
      {
         if(this._editedItemPosition)
         {
            return {
               "rowIndex":this._editedItemPosition.rowIndex,
               "columnIndex":this._editedItemPosition.columnIndex
            };
         }
         return this._editedItemPosition;
      }
      
      public function set editedItemPosition(param1:Object) : void
      {
         if(!param1)
         {
            this.setEditedItemPosition(null);
            return;
         }
         var _loc2_:Object = {
            "rowIndex":param1.rowIndex,
            "columnIndex":param1.columnIndex
         };
         this.setEditedItemPosition(_loc2_);
      }
      
      override public function invalidateDisplayList() : void
      {
         super.invalidateDisplayList();
         if(header)
         {
            header.headerItemsChanged = true;
            header.invalidateSize();
            header.invalidateDisplayList();
         }
         if(lockedColumnHeader)
         {
            lockedColumnHeader.headerItemsChanged = true;
            lockedColumnHeader.invalidateSize();
            lockedColumnHeader.invalidateDisplayList();
         }
      }
      
      override public function set dataProvider(param1:Object) : void
      {
         if(this.itemEditorInstance)
         {
            this.endEdit(DataGridEventReason.OTHER);
         }
         this.lastEditedItemPosition = null;
         super.dataProvider = param1;
      }
      
      override protected function initializeAccessibility() : void
      {
         if(DataGrid.createAccessibilityImplementation != null)
         {
            DataGrid.createAccessibilityImplementation(this);
         }
      }
      
      override protected function measure() : void
      {
         var _loc1_:EdgeMetrics = null;
         super.measure();
         if(explicitRowCount != -1)
         {
            measuredHeight += !!mx_internal::_explicitHeaderHeight ? headerHeight : header.getExplicitOrMeasuredHeight();
            measuredMinHeight += !!mx_internal::_explicitHeaderHeight ? headerHeight : header.getExplicitOrMeasuredHeight();
         }
         _loc1_ = viewMetrics;
         var _loc2_:int = this.columns.length;
         if(_loc2_ == 0)
         {
            measuredWidth = DEFAULT_MEASURED_WIDTH;
            measuredMinWidth = DEFAULT_MEASURED_MIN_WIDTH;
            return;
         }
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_)
         {
            if(this.columns[_loc5_].visible)
            {
               _loc3_ += this.columns[_loc5_].preferredWidth;
               if(isNaN(this._minColumnWidth))
               {
                  _loc4_ += this.columns[_loc5_].minWidth;
               }
            }
            _loc5_++;
         }
         if(!isNaN(this._minColumnWidth))
         {
            _loc4_ = _loc2_ * this._minColumnWidth;
         }
         measuredWidth = _loc3_ + _loc1_.left + _loc1_.right;
         measuredMinWidth = _loc4_ + _loc1_.left + _loc1_.right;
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
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:EdgeMetrics = null;
         if(this.displayWidth != param1 - viewMetrics.right - viewMetrics.left)
         {
            this.displayWidth = param1 - viewMetrics.right - viewMetrics.left;
            columnsInvalid = true;
         }
         this.calculateColumnSizes();
         if(this.itemEditorPositionChanged)
         {
            this.itemEditorPositionChanged = false;
            if(!this.lastItemDown)
            {
               this.scrollToEditedItem(this.editedItemPosition.rowIndex,this.editedItemPosition.colIndex);
            }
         }
         super.updateDisplayList(param1,param2);
         if(collection && collection.length)
         {
            setRowCount(listItems.length);
            if(listItems.length)
            {
               setColumnCount(listItems[0].length);
            }
            else
            {
               setColumnCount(0);
            }
         }
         if(verticalScrollBar != null && verticalScrollBar.visible && (horizontalScrollBar == null || !horizontalScrollBar.visible) && mx_internal::headerVisible)
         {
            _loc3_ = header.height;
            _loc4_ = borderMetrics;
            if(roomForScrollBar(verticalScrollBar,param1 - _loc4_.left - _loc4_.right,param2 - _loc3_ - _loc4_.top - _loc4_.bottom))
            {
               verticalScrollBar.move(verticalScrollBar.x,viewMetrics.top + _loc3_);
               verticalScrollBar.setActualSize(verticalScrollBar.width,param2 - viewMetrics.top - viewMetrics.bottom - _loc3_);
               verticalScrollBar.visible = true;
               headerMask.width += verticalScrollBar.getExplicitOrMeasuredWidth();
               if(!DataGridHeader(header).needRightSeparator)
               {
                  header.invalidateDisplayList();
                  DataGridHeader(header).needRightSeparator = true;
               }
            }
            else if(DataGridHeader(header).needRightSeparator)
            {
               header.invalidateDisplayList();
               DataGridHeader(header).needRightSeparator = false;
            }
         }
         else if(DataGridHeader(header).needRightSeparator)
         {
            header.invalidateDisplayList();
            DataGridHeader(header).needRightSeparator = false;
         }
         if(this.bEditedItemPositionChanged)
         {
            this.bEditedItemPositionChanged = false;
            if(!this.lastItemDown)
            {
               this.commitEditedItemPosition(this._proposedEditedItemPosition);
            }
            this._proposedEditedItemPosition = undefined;
            itemsSizeChanged = false;
         }
         this.drawRowBackgrounds();
         this.drawLinesAndColumnBackgrounds();
         if(lockedRowCount && lockedRowContent)
         {
            this.drawRowGraphics(lockedRowContent);
            this.drawLinesAndColumnGraphics(lockedRowContent,mx_internal::visibleColumns,{"bottom":1});
            if(lockedColumnCount)
            {
               this.drawRowGraphics(lockedColumnAndRowContent);
               this.drawLinesAndColumnGraphics(lockedColumnAndRowContent,mx_internal::visibleLockedColumns,{
                  "right":1,
                  "bottom":1
               });
            }
         }
         if(lockedColumnCount)
         {
            this.drawRowGraphics(lockedColumnContent);
            this.drawLinesAndColumnGraphics(lockedColumnContent,mx_internal::visibleLockedColumns,{"right":1});
         }
      }
      
      override protected function makeRowsAndColumns(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:int, param7:Boolean = false, param8:uint = 0) : Point
      {
         var _loc10_:DataGridColumn = null;
         var _loc11_:IListItemRenderer = null;
         var _loc12_:ListRowInfo = null;
         var _loc13_:Sprite = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         allowItemSizeChangeNotification = false;
         var _loc9_:Point = super.makeRowsAndColumns(param1,param2,param3,param4,param5,param6,param7,param8);
         if(this.itemEditorInstance)
         {
            this.actualContentHolder.setChildIndex(DisplayObject(this.itemEditorInstance),this.actualContentHolder.numChildren - 1);
            if(lockedColumnCount && this.editedItemPosition.columnIndex <= mx_internal::visibleLockedColumns[lockedColumnCount - 1].colNum)
            {
               _loc10_ = mx_internal::visibleLockedColumns[this.actualColIndex];
            }
            else
            {
               _loc10_ = mx_internal::visibleColumns[this.actualColIndex];
            }
            _loc11_ = this.actualContentHolder.listItems[this.actualRowIndex][this.actualColIndex];
            _loc12_ = this.actualContentHolder.rowInfo[this.actualRowIndex];
            if(_loc11_ && !_loc10_.rendererIsEditor)
            {
               _loc14_ = _loc10_.editorXOffset;
               _loc15_ = _loc10_.editorYOffset;
               _loc16_ = _loc10_.editorWidthOffset;
               _loc17_ = _loc10_.editorHeightOffset;
               this.itemEditorInstance.move(_loc11_.x + _loc14_,_loc12_.y + _loc15_);
               this.itemEditorInstance.setActualSize(Math.min(_loc10_.width + _loc16_,this.actualContentHolder.width - this.itemEditorInstance.x),Math.min(_loc12_.height + _loc17_,this.actualContentHolder.height - this.itemEditorInstance.y));
               _loc11_.visible = false;
            }
            if(_loc13_ = Sprite(this.actualContentHolder.getChildByName("lines")))
            {
               this.actualContentHolder.setChildIndex(_loc13_,this.actualContentHolder.numChildren - 1);
            }
         }
         allowItemSizeChangeNotification = variableRowHeight;
         return _loc9_;
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:DataGridColumn = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Object = null;
         var _loc7_:IListItemRenderer = null;
         var _loc8_:Number = NaN;
         super.commitProperties();
         if(mx_internal::fontContextChanged)
         {
            fontContextChanged = false;
            _loc2_ = this.columns.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc1_ = this.columns[_loc3_];
               _loc1_.determineFontContext();
               _loc3_++;
            }
         }
         if(itemsNeedMeasurement)
         {
            itemsNeedMeasurement = false;
            if(isNaN(explicitRowHeight))
            {
               if(iterator && this.columns.length > 0)
               {
                  visibleColumns = this.columns;
                  columnsInvalid = true;
                  _loc4_ = getStyle("paddingTop");
                  _loc5_ = getStyle("paddingBottom");
                  _loc6_ = iterator.current;
                  _loc8_ = 0;
                  _loc2_ = this.columns.length;
                  _loc3_ = 0;
                  while(_loc3_ < _loc2_)
                  {
                     _loc1_ = this.columns[_loc3_];
                     if(_loc1_.visible)
                     {
                        _loc7_ = _loc1_.getMeasuringRenderer(false,_loc6_);
                        if(DisplayObject(_loc7_).parent == null)
                        {
                           listContent.addChild(DisplayObject(_loc7_));
                        }
                        this.setupRendererFromData(_loc1_,_loc7_,_loc6_);
                        _loc8_ = Math.max(_loc8_,_loc7_.getExplicitOrMeasuredHeight() + _loc5_ + _loc4_);
                     }
                     _loc3_++;
                  }
                  setRowHeight(Math.max(_loc8_,20));
               }
               else
               {
                  setRowHeight(20);
               }
               if(!collection || collection.length == 0 || this.columns.length == 0)
               {
                  itemsNeedMeasurement = true;
               }
            }
         }
      }
      
      override public function measureWidthOfItems(param1:int = -1, param2:int = 0) : Number
      {
         var _loc3_:Number = 0;
         var _loc4_:int = !!this.columns ? int(this.columns.length) : 0;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(this.columns[_loc5_].visible)
            {
               _loc3_ += this.columns[_loc5_].width;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      mx_internal function setupRendererFromData(param1:DataGridColumn, param2:IListItemRenderer, param3:Object) : void
      {
         var _loc4_:DataGridListData = DataGridListData(makeListData(param3,itemToUID(param3),0,param1.colNum,param1));
         if(param2 is IDropInListItemRenderer)
         {
            IDropInListItemRenderer(param2).listData = !!param3 ? _loc4_ : null;
         }
         param2.data = param3;
         param2.explicitWidth = getWidthOfItem(param2,param1);
         UIComponentGlobals.layoutManager.validateClient(param2,true);
      }
      
      override public function measureHeightOfItems(param1:int = -1, param2:int = 0) : Number
      {
         return this.measureHeightOfItemsUptoMaxHeight(param1,param2);
      }
      
      mx_internal function measureHeightOfItemsUptoMaxHeight(param1:int = -1, param2:int = 0, param3:Number = -1) : Number
      {
         var item:IListItemRenderer = null;
         var c:DataGridColumn = null;
         var n:int = 0;
         var j:int = 0;
         var data:Object = null;
         var index:int = param1;
         var count:int = param2;
         var maxHeight:Number = param3;
         if(!this.columns.length)
         {
            return rowHeight * count;
         }
         var h:Number = 0;
         var ch:Number = 0;
         var paddingTop:Number = getStyle("paddingTop");
         var paddingBottom:Number = getStyle("paddingBottom");
         var lockedCount:int = lockedRowCount;
         if(mx_internal::headerVisible && count > 0 && index == -1)
         {
            h = this.calculateHeaderHeight();
            if(maxHeight != -1 && h > maxHeight)
            {
               setRowCount(0);
               return 0;
            }
            count--;
            index = 0;
         }
         var bookmark:CursorBookmark = !!iterator ? iterator.bookmark : null;
         var bMore:Boolean = iterator != null;
         if(index != -1 && iterator)
         {
            try
            {
               iterator.seek(CursorBookmark.FIRST,index);
            }
            catch(e:ItemPendingError)
            {
               bMore = false;
            }
         }
         if(lockedCount > 0)
         {
            try
            {
               mx_internal::collectionIterator.seek(CursorBookmark.FIRST,0);
            }
            catch(e:ItemPendingError)
            {
               bMore = false;
            }
         }
         var i:int = 0;
         for(; i < count; i++)
         {
            if(bMore)
            {
               data = lockedCount > 0 ? mx_internal::collectionIterator.current : iterator.current;
               ch = 0;
               n = this.columns.length;
               j = 0;
               while(j < n)
               {
                  c = this.columns[j];
                  if(c.visible)
                  {
                     item = c.getMeasuringRenderer(false,data);
                     if(DisplayObject(item).parent == null)
                     {
                        listContent.addChild(DisplayObject(item));
                     }
                     this.setupRendererFromData(c,item,data);
                     ch = Math.ceil(Math.max(ch,!!variableRowHeight ? Number(item.getExplicitOrMeasuredHeight() + paddingBottom + paddingTop) : Number(rowHeight)));
                  }
                  j++;
               }
            }
            if(maxHeight != -1 && (h + ch > maxHeight || !bMore))
            {
               try
               {
                  if(iterator)
                  {
                     iterator.seek(bookmark,0);
                  }
               }
               catch(e:ItemPendingError)
               {
               }
               count = !!mx_internal::headerVisible ? int(i + 1) : int(i);
               setRowCount(count);
               return h;
            }
            h += ch;
            if(iterator)
            {
               try
               {
                  bMore = iterator.moveNext();
                  if(lockedCount > 0)
                  {
                     mx_internal::collectionIterator.moveNext();
                     lockedCount--;
                  }
               }
               catch(e:ItemPendingError)
               {
                  bMore = false;
                  continue;
               }
            }
         }
         if(iterator)
         {
            try
            {
               iterator.seek(bookmark,0);
            }
            catch(e:ItemPendingError)
            {
            }
         }
         return h;
      }
      
      mx_internal function calculateHeaderHeight() : Number
      {
         var _loc1_:IListItemRenderer = null;
         var _loc2_:DataGridColumn = null;
         var _loc3_:DataGridListData = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(!this.columns.length)
         {
            return rowHeight;
         }
         if(!listContent)
         {
            return rowHeight;
         }
         var _loc4_:Number = 0;
         var _loc7_:Number = getStyle("paddingTop");
         var _loc8_:Number = getStyle("paddingBottom");
         if(showHeaders)
         {
            _loc4_ = 0;
            _loc5_ = this.columns.length;
            if(this._headerWordWrapPresent)
            {
               _headerHeight = this._originalHeaderHeight;
               _explicitHeaderHeight = this._originalExplicitHeaderHeight;
            }
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc2_ = this.columns[_loc6_];
               if(_loc2_.visible)
               {
                  _loc1_ = _loc2_.cachedHeaderRenderer;
                  if(!_loc1_)
                  {
                     _loc1_ = createColumnItemRenderer(_loc2_,true,_loc2_);
                     _loc1_.styleName = _loc2_;
                     _loc2_.cachedHeaderRenderer = _loc1_;
                  }
                  if(DisplayObject(_loc1_).parent == null)
                  {
                     listContent.addChild(DisplayObject(_loc1_));
                     _loc1_.visible = false;
                  }
                  _loc3_ = DataGridListData(makeListData(_loc2_,uid,0,_loc2_.colNum,_loc2_));
                  rowMap[_loc1_.name] = _loc3_;
                  if(_loc1_ is IDropInListItemRenderer)
                  {
                     IDropInListItemRenderer(_loc1_).listData = _loc3_;
                  }
                  _loc1_.data = _loc2_;
                  _loc1_.explicitWidth = _loc2_.width;
                  UIComponentGlobals.layoutManager.validateClient(_loc1_,true);
                  _loc4_ = Math.max(_loc4_,!!mx_internal::_explicitHeaderHeight ? Number(headerHeight) : Number(_loc1_.getExplicitOrMeasuredHeight() + _loc8_ + _loc7_));
                  if(columnHeaderWordWrap(_loc2_))
                  {
                     this._headerWordWrapPresent = true;
                  }
               }
               _loc6_++;
            }
            if(this._headerWordWrapPresent)
            {
               this._originalHeaderHeight = mx_internal::_headerHeight;
               this._originalExplicitHeaderHeight = mx_internal::_explicitHeaderHeight;
               _headerHeight = _loc4_;
               _explicitHeaderHeight = true;
            }
         }
         return _loc4_;
      }
      
      override protected function calculateRowHeight(param1:Object, param2:Number, param3:Boolean = false) : Number
      {
         var _loc4_:IListItemRenderer = null;
         var _loc5_:DataGridColumn = null;
         var _loc7_:int = 0;
         var _loc6_:int = this.columns.length;
         var _loc8_:int = 0;
         var _loc9_:int = mx_internal::visibleLockedColumns.length;
         if(param3 && mx_internal::visibleColumns.length == this._columns.length)
         {
            return param2;
         }
         var _loc10_:Number = getStyle("paddingTop");
         var _loc11_:Number = getStyle("paddingBottom");
         _loc7_ = 0;
         while(_loc7_ < _loc6_)
         {
            if(param3 && _loc8_ < _loc9_ && mx_internal::visibleLockedColumns[_loc8_].colNum == this.columns[_loc7_].colNum)
            {
               _loc8_++;
            }
            else if(param3 && _loc8_ - _loc9_ < mx_internal::visibleColumns.length && mx_internal::visibleColumns[_loc8_ - _loc9_].colNum == this.columns[_loc7_].colNum)
            {
               _loc8_++;
            }
            else if((_loc5_ = this.columns[_loc7_]).visible)
            {
               _loc4_ = _loc5_.getMeasuringRenderer(false,param1);
               if(DisplayObject(_loc4_).parent == null)
               {
                  listContent.addChild(DisplayObject(_loc4_));
               }
               this.setupRendererFromData(_loc5_,_loc4_,param1);
               param2 = Math.max(param2,_loc4_.getExplicitOrMeasuredHeight() + _loc11_ + _loc10_);
            }
            _loc7_++;
         }
         return param2;
      }
      
      override protected function scrollHandler(param1:Event) : void
      {
         var _loc2_:ScrollBar = null;
         var _loc3_:Number = NaN;
         if(param1.target == verticalScrollBar || param1.target == horizontalScrollBar)
         {
            if(param1 is ScrollEvent)
            {
               if(!liveScrolling && ScrollEvent(param1).detail == ScrollEventDetail.THUMB_TRACK)
               {
                  return;
               }
               if(this.itemEditorInstance)
               {
                  this.endEdit(DataGridEventReason.OTHER);
               }
               _loc2_ = ScrollBar(param1.target);
               _loc3_ = _loc2_.scrollPosition;
               if(_loc2_ == verticalScrollBar)
               {
                  this.verticalScrollPosition = _loc3_;
               }
               else if(_loc2_ == horizontalScrollBar)
               {
                  this.horizontalScrollPosition = _loc3_;
               }
               super.scrollHandler(param1);
            }
         }
      }
      
      private function displayingPartialRow() : Boolean
      {
         var _loc1_:int = listItems.length - 1 - offscreenExtraRowsBottom;
         if(rowInfo[_loc1_].y + rowInfo[_loc1_].height > listContent.heightExcludingOffsets - listContent.topOffset)
         {
            return true;
         }
         return false;
      }
      
      override protected function configureScrollBars() : void
      {
         var _loc9_:CursorBookmark = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         if(mx_internal::columnsInvalid)
         {
            return;
         }
         if(!this.displayableColumns)
         {
            return;
         }
         var _loc1_:Array = this.listItems;
         if(mx_internal::visibleColumns && !mx_internal::visibleColumns.length && mx_internal::visibleLockedColumns && mx_internal::visibleLockedColumns.length)
         {
            _loc1_ = lockedColumnContent.listItems;
         }
         var _loc2_:Object = horizontalScrollBar;
         var _loc3_:Object = verticalScrollBar;
         var _loc4_:int;
         if((_loc4_ = _loc1_.length) == 0)
         {
            if(_loc2_ || _loc3_)
            {
               if(listContent.height)
               {
                  setScrollBarProperties(0,0,0,0);
               }
            }
            return;
         }
         if(_loc4_ > 1 && this.displayingPartialRow())
         {
            _loc4_--;
         }
         var _loc5_:int = verticalScrollPosition;
         var _loc6_:int = 0;
         while(_loc4_ && _loc1_[_loc4_ - 1].length == 0)
         {
            if(!(collection && _loc4_ + _loc5_ >= collection.length - lockedRowCount))
            {
               break;
            }
            _loc4_--;
            _loc6_++;
         }
         if(verticalScrollPosition > 0 && _loc6_ > 0)
         {
            _loc10_ = (_loc9_ = iterator.bookmark).getViewIndex();
            if(verticalScrollPosition != _loc10_ - lockedRowCount)
            {
               super.verticalScrollPosition = Math.max(_loc10_ - lockedRowCount,0);
            }
            if(this.adjustVerticalScrollPositionDownward(Math.max(_loc4_,1)))
            {
               return;
            }
         }
         _loc4_ -= offscreenExtraRowsTop + offscreenExtraRowsBottom;
         var _loc8_:int = (_loc7_ = Boolean(collection && collection.length > 0)) && _loc4_ > 0 ? int(listItems[0].length) : int(mx_internal::visibleColumns.length);
         if(_loc7_ && _loc4_ > 0 && _loc8_ > 1 && listItems[0][_loc8_ - 1].x + mx_internal::visibleColumns[_loc8_ - 1].width > this.displayWidth - listContent.x + viewMetrics.left)
         {
            _loc8_--;
         }
         else if(_loc8_ > 1 && !_loc7_)
         {
            _loc11_ = 0;
            _loc12_ = 0;
            while(_loc12_ < mx_internal::visibleColumns.length)
            {
               _loc11_ += mx_internal::visibleColumns[_loc12_].width;
               _loc12_++;
            }
            if(_loc11_ > this.displayWidth - listContent.x + viewMetrics.left)
            {
               _loc8_--;
            }
         }
         setScrollBarProperties(this.displayableColumns.length - lockedColumnCount,Math.max(_loc8_,1),!!collection ? int(collection.length - lockedRowCount) : 0,Math.max(_loc4_,1));
         if((!verticalScrollBar || !verticalScrollBar.visible) && collection && collection.length - lockedRowCount > _loc4_)
         {
            maxVerticalScrollPosition = collection.length - lockedRowCount - _loc4_;
         }
         if((!horizontalScrollBar || !horizontalScrollBar.visible) && this.displayableColumns.length - lockedColumnCount > _loc8_ - lockedColumnCount)
         {
            maxHorizontalScrollPosition = this.displayableColumns.length - lockedColumnCount - _loc8_;
         }
      }
      
      private function adjustVerticalScrollPositionDownward(param1:int) : Boolean
      {
         var item:IListItemRenderer = null;
         var c:DataGridColumn = null;
         var n:int = 0;
         var j:int = 0;
         var bMore:Boolean = false;
         var data:Object = null;
         var rowCount:int = param1;
         var bookmark:CursorBookmark = iterator.bookmark;
         var h:Number = 0;
         var ch:Number = 0;
         var paddingTop:Number = getStyle("paddingTop");
         var paddingBottom:Number = getStyle("paddingBottom");
         h = rowInfo[rowCount - 1].y + rowInfo[rowCount - 1].height;
         h = listContent.heightExcludingOffsets - listContent.topOffset - h;
         var numRows:int = 0;
         try
         {
            if(iterator.afterLast)
            {
               iterator.seek(CursorBookmark.LAST,0);
            }
            else
            {
               bMore = iterator.movePrevious();
            }
         }
         catch(e:ItemPendingError)
         {
            bMore = false;
         }
         if(!bMore)
         {
            super.verticalScrollPosition = 0;
            try
            {
               iterator.seek(CursorBookmark.FIRST,0);
               if(!iteratorValid)
               {
                  iteratorValid = true;
                  lastSeekPending = null;
               }
            }
            catch(e:ItemPendingError)
            {
               lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,0);
               e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
               iteratorValid = false;
               invalidateList();
               return true;
            }
            updateList();
            return true;
         }
         while(h > 0 && bMore)
         {
            if(bMore)
            {
               data = iterator.current;
               ch = 0;
               n = this.columns.length;
               j = 0;
               while(j < n)
               {
                  c = this.columns[j];
                  if(c.visible)
                  {
                     if(variableRowHeight)
                     {
                        item = c.getMeasuringRenderer(false,data);
                        if(DisplayObject(item).parent == null)
                        {
                           listContent.addChild(DisplayObject(item));
                        }
                        this.setupRendererFromData(c,item,data);
                     }
                     ch = Math.max(ch,!!variableRowHeight ? Number(item.getExplicitOrMeasuredHeight() + paddingBottom + paddingTop) : Number(rowHeight));
                  }
                  j++;
               }
            }
            h -= ch;
            try
            {
               bMore = iterator.movePrevious();
               numRows++;
            }
            catch(e:ItemPendingError)
            {
               bMore = false;
            }
         }
         if(h < 0)
         {
            numRows--;
         }
         iterator.seek(bookmark,0);
         this.verticalScrollPosition = Math.max(0,verticalScrollPosition - numRows);
         if(numRows > 0 && !variableRowHeight)
         {
            this.configureScrollBars();
         }
         return numRows > 0;
      }
      
      override public function calculateDropIndex(param1:DragEvent = null) : int
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
            _loc4_ = listContent.globalToLocal(_loc4_);
            _loc5_ = listItems.length;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(listItems[_loc6_][0])
               {
                  _loc3_ = listItems[_loc6_][0];
               }
               if(rowInfo[_loc6_].y <= _loc4_.y && _loc4_.y < rowInfo[_loc6_].y + rowInfo[_loc6_].height)
               {
                  _loc2_ = listItems[_loc6_][0];
                  break;
               }
               _loc6_++;
            }
            if(!_loc2_ && lockedRowContent)
            {
               _loc4_ = listContent.localToGlobal(_loc4_);
               _loc4_ = lockedRowContent.globalToLocal(_loc4_);
               _loc5_ = lockedRowContent.listItems.length;
               _loc6_ = 0;
               while(_loc6_ < _loc5_)
               {
                  if(lockedRowContent.rowInfo[_loc6_].y <= _loc4_.y && _loc4_.y < lockedRowContent.rowInfo[_loc6_].y + lockedRowContent.rowInfo[_loc6_].height)
                  {
                     _loc2_ = lockedRowContent.listItems[_loc6_][0];
                     break;
                  }
                  _loc6_++;
               }
            }
            if(_loc2_)
            {
               lastDropIndex = itemRendererToIndex(_loc2_);
            }
            else if(_loc3_)
            {
               lastDropIndex = itemRendererToIndex(_loc3_) + 1;
            }
            else
            {
               lastDropIndex = !!collection ? int(collection.length) : 0;
            }
         }
         return lastDropIndex;
      }
      
      override protected function drawRowBackgrounds() : void
      {
         this.drawRowGraphics(listContent);
      }
      
      protected function drawRowGraphics(param1:ListBaseContentHolder) : void
      {
         var _loc3_:Array = null;
         var _loc8_:int = 0;
         var _loc2_:Sprite = Sprite(param1.getChildByName("rowBGs"));
         if(!_loc2_)
         {
            _loc2_ = new FlexSprite();
            _loc2_.mouseEnabled = false;
            _loc2_.name = "rowBGs";
            param1.addChildAt(_loc2_,0);
         }
         var _loc4_:Object;
         if(_loc4_ = getStyle("alternatingItemColors"))
         {
            _loc3_ = _loc4_ is Array ? _loc4_ as Array : [_loc4_];
         }
         if(!_loc3_ || _loc3_.length == 0)
         {
            while(_loc2_.numChildren > _loc8_)
            {
               _loc2_.removeChildAt(_loc2_.numChildren - 1);
            }
            return;
         }
         styleManager.getColorNames(_loc3_);
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = verticalScrollPosition;
         _loc8_ = param1.listItems.length;
         while(_loc5_ < _loc8_)
         {
            this.drawRowBackground(_loc2_,_loc6_++,param1.rowInfo[_loc5_].y,param1.rowInfo[_loc5_].height,_loc3_[_loc7_ % _loc3_.length],_loc7_);
            _loc5_++;
            _loc7_++;
         }
         while(_loc2_.numChildren > _loc6_)
         {
            _loc2_.removeChildAt(_loc2_.numChildren - 1);
         }
      }
      
      override protected function mouseEventToItemRenderer(param1:MouseEvent) : IListItemRenderer
      {
         var _loc2_:IListItemRenderer = null;
         _loc2_ = super.mouseEventToItemRenderer(param1);
         return _loc2_ == this.itemEditorInstance ? null : _loc2_;
      }
      
      override protected function get dragImage() : IUIComponent
      {
         var _loc1_:DataGridDragProxy = new DataGridDragProxy();
         _loc1_.owner = this;
         _loc1_.moduleFactory = moduleFactory;
         return _loc1_;
      }
      
      mx_internal function shiftColumns(param1:int, param2:int, param3:Event = null) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:IndexChangedEvent = null;
         var _loc7_:int = 0;
         var _loc8_:DataGridColumn = null;
         if(param2 >= 0 && param1 != param2)
         {
            _loc4_ = param1 < param2 ? 1 : -1;
            _loc5_ = param1;
            while(_loc5_ != param2)
            {
               _loc7_ = _loc5_ + _loc4_;
               _loc8_ = this._columns[_loc5_];
               this._columns[_loc5_] = this._columns[_loc7_];
               this._columns[_loc7_] = _loc8_;
               this._columns[_loc5_].colNum = _loc5_;
               this._columns[_loc7_].colNum = _loc7_;
               _loc5_ += _loc4_;
            }
            if(this.sortIndex == param1)
            {
               this.sortIndex += param2 - param1;
            }
            else if(param1 < this.sortIndex && this.sortIndex <= param2 || param2 <= this.sortIndex && this.sortIndex < param1)
            {
               this.sortIndex -= _loc4_;
            }
            if(this.lastSortIndex == param1)
            {
               this.lastSortIndex += param2 - param1;
            }
            else if(param1 < this.lastSortIndex && this.lastSortIndex <= param2 || param2 <= this.lastSortIndex && this.lastSortIndex < param1)
            {
               this.lastSortIndex -= _loc4_;
            }
            columnsInvalid = true;
            itemsSizeChanged = true;
            this.invalidateDisplayList();
            if(lockedColumnHeader)
            {
               lockedColumnHeader.invalidateDisplayList();
            }
            (_loc6_ = new IndexChangedEvent(IndexChangedEvent.HEADER_SHIFT)).oldIndex = param1;
            _loc6_.newIndex = param2;
            _loc6_.triggerEvent = param3;
            dispatchEvent(_loc6_);
         }
      }
      
      private function generateCols() : void
      {
         var col:DataGridColumn = null;
         var newCols:Array = null;
         var cols:Array = null;
         var info:Object = null;
         var itmObj:Object = null;
         var p:String = null;
         var n:int = 0;
         var colName:Object = null;
         var i:int = 0;
         if(collection.length > 0)
         {
            newCols = [];
            if(dataProvider)
            {
               try
               {
                  iterator.seek(CursorBookmark.FIRST);
                  if(!iteratorValid)
                  {
                     iteratorValid = true;
                     lastSeekPending = null;
                  }
               }
               catch(e:ItemPendingError)
               {
                  lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,0);
                  e.addResponder(new ItemResponder(generateColumnsPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                  iteratorValid = false;
                  return;
               }
               info = ObjectUtil.getClassInfo(iterator.current,["uid","mx_internal_uid"]);
               if(info)
               {
                  cols = info.properties;
               }
            }
            if(!cols)
            {
               itmObj = iterator.current;
               for(p in itmObj)
               {
                  if(p != "uid")
                  {
                     col = new DataGridColumn();
                     col.dataField = p;
                     newCols.push(col);
                  }
               }
            }
            else
            {
               n = cols.length;
               i = 0;
               while(i < n)
               {
                  colName = cols[i];
                  if(colName is QName)
                  {
                     colName = QName(colName).localName;
                  }
                  col = new DataGridColumn();
                  col.dataField = String(colName);
                  newCols.push(col);
                  i++;
               }
            }
            this.columns = newCols;
            this.generatedColumns = true;
         }
      }
      
      private function generateColumnsPendingResultHandler(param1:Object, param2:ListBaseSeekPending) : void
      {
         if(this.columns.length == 0)
         {
            this.generateCols();
         }
         seekPendingResultHandler(param1,param2);
      }
      
      private function calculateColumnSizes() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:DataGridColumn = null;
         var _loc6_:Number = NaN;
         var _loc7_:DataGridColumn = null;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc4_:Number = 0;
         if(this.columns.length == 0)
         {
            visibleColumns = [];
            visibleLockedColumns = [];
            this.lockedColumnWidth = 0;
            columnsInvalid = false;
            return;
         }
         if(mx_internal::columnsInvalid)
         {
            columnsInvalid = false;
            visibleColumns = [];
            visibleLockedColumns = [];
            this.lockedColumnWidth = 0;
            if(this.minColumnWidthInvalid)
            {
               _loc2_ = this.columns.length;
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  this.columns[_loc3_].minWidth = this.minColumnWidth;
                  _loc3_++;
               }
               this.minColumnWidthInvalid = false;
            }
            this.displayableColumns = null;
            _loc2_ = this._columns.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(this.displayableColumns && this._columns[_loc3_].visible)
               {
                  this.displayableColumns.push(this._columns[_loc3_]);
               }
               else if(!this.displayableColumns && !this._columns[_loc3_].visible)
               {
                  this.displayableColumns = new Array(_loc3_);
                  _loc9_ = 0;
                  while(_loc9_ < _loc3_)
                  {
                     this.displayableColumns[_loc9_] = this._columns[_loc9_];
                     _loc9_++;
                  }
               }
               _loc3_++;
            }
            if(!this.displayableColumns)
            {
               this.displayableColumns = this._columns;
            }
            if(horizontalScrollPolicy == ScrollPolicy.OFF)
            {
               _loc2_ = this.displayableColumns.length;
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  _loc5_ = this.displayableColumns[_loc3_];
                  if(_loc3_ < lockedColumnCount)
                  {
                     mx_internal::visibleLockedColumns.push(_loc5_);
                  }
                  else
                  {
                     mx_internal::visibleColumns.push(_loc5_);
                  }
                  _loc3_++;
               }
            }
            else
            {
               _loc2_ = this.displayableColumns.length;
               _loc3_ = 0;
               for(; _loc3_ < _loc2_; _loc3_++)
               {
                  if(!(_loc3_ >= lockedColumnCount && _loc3_ < lockedColumnCount + horizontalScrollPosition))
                  {
                     if((_loc5_ = this.displayableColumns[_loc3_]).preferredWidth < _loc5_.minWidth)
                     {
                        _loc5_.preferredWidth = _loc5_.minWidth;
                     }
                     if(_loc4_ >= this.displayWidth)
                     {
                        if(mx_internal::visibleColumns.length == 0)
                        {
                           mx_internal::visibleColumns.push(this.displayableColumns[0]);
                        }
                     }
                     if(_loc3_ < lockedColumnCount)
                     {
                        this.lockedColumnWidth += Math.max(!!isNaN(_loc5_.explicitWidth) ? Number(_loc5_.preferredWidth) : Number(_loc5_.explicitWidth),_loc5_.minWidth);
                        mx_internal::visibleLockedColumns.push(_loc5_);
                     }
                     else
                     {
                        mx_internal::visibleColumns.push(_loc5_);
                     }
                     _loc4_ += Math.max(!!isNaN(_loc5_.explicitWidth) ? Number(_loc5_.preferredWidth) : Number(_loc5_.explicitWidth),_loc5_.minWidth);
                  }
                  continue;
                  if(_loc5_.width != _loc5_.preferredWidth)
                  {
                     _loc5_.setWidth(_loc5_.preferredWidth);
                  }
               }
            }
         }
         if(horizontalScrollPolicy == ScrollPolicy.OFF)
         {
            _loc10_ = 0;
            _loc11_ = 0;
            _loc2_ = mx_internal::visibleColumns.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(mx_internal::visibleColumns[_loc3_].resizable && !mx_internal::visibleColumns[_loc3_].newlyVisible)
               {
                  if(!isNaN(mx_internal::visibleColumns[_loc3_].explicitWidth))
                  {
                     _loc11_ += mx_internal::visibleColumns[_loc3_].width;
                  }
                  else
                  {
                     _loc10_++;
                     _loc11_ += mx_internal::visibleColumns[_loc3_].minWidth;
                  }
               }
               else
               {
                  _loc11_ += mx_internal::visibleColumns[_loc3_].width;
               }
               _loc4_ += mx_internal::visibleColumns[_loc3_].width;
               _loc3_++;
            }
            _loc2_ = mx_internal::visibleLockedColumns.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(mx_internal::visibleLockedColumns[_loc3_].resizable && !mx_internal::visibleLockedColumns[_loc3_].newlyVisible)
               {
                  if(!isNaN(mx_internal::visibleLockedColumns[_loc3_].explicitWidth))
                  {
                     _loc11_ += mx_internal::visibleLockedColumns[_loc3_].width;
                  }
                  else
                  {
                     _loc10_++;
                     _loc11_ += mx_internal::visibleLockedColumns[_loc3_].minWidth;
                  }
               }
               else
               {
                  _loc11_ += mx_internal::visibleLockedColumns[_loc3_].width;
               }
               _loc4_ += mx_internal::visibleLockedColumns[_loc3_].width;
               _loc3_++;
            }
            _loc13_ = this.displayWidth;
            if(this.displayWidth > _loc11_ && _loc10_)
            {
               _loc2_ = mx_internal::visibleLockedColumns.length;
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  if(mx_internal::visibleLockedColumns[_loc3_].resizable && !mx_internal::visibleLockedColumns[_loc3_].newlyVisible && isNaN(mx_internal::visibleLockedColumns[_loc3_].explicitWidth))
                  {
                     _loc7_ = mx_internal::visibleLockedColumns[_loc3_];
                     if(_loc4_ > this.displayWidth)
                     {
                        _loc12_ = (_loc7_.width - _loc7_.minWidth) / (_loc4_ - _loc11_);
                     }
                     else
                     {
                        _loc12_ = _loc7_.width / _loc4_;
                     }
                     _loc8_ = Math.floor(_loc7_.width - (_loc4_ - this.displayWidth) * _loc12_);
                     _loc14_ = mx_internal::visibleLockedColumns[_loc3_].minWidth;
                     mx_internal::visibleLockedColumns[_loc3_].setWidth(_loc8_ > _loc14_ ? _loc8_ : _loc14_);
                  }
                  _loc13_ -= mx_internal::visibleLockedColumns[_loc3_].width;
                  mx_internal::visibleLockedColumns[_loc3_].newlyVisible = false;
                  _loc3_++;
               }
               _loc2_ = mx_internal::visibleColumns.length;
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  if(mx_internal::visibleColumns[_loc3_].resizable && !mx_internal::visibleColumns[_loc3_].newlyVisible && isNaN(mx_internal::visibleColumns[_loc3_].explicitWidth))
                  {
                     _loc7_ = mx_internal::visibleColumns[_loc3_];
                     if(_loc4_ > this.displayWidth)
                     {
                        _loc12_ = (_loc7_.width - _loc7_.minWidth) / (_loc4_ - _loc11_);
                     }
                     else
                     {
                        _loc12_ = _loc7_.width / _loc4_;
                     }
                     _loc8_ = Math.floor(_loc7_.width - (_loc4_ - this.displayWidth) * _loc12_);
                     _loc14_ = mx_internal::visibleColumns[_loc3_].minWidth;
                     mx_internal::visibleColumns[_loc3_].setWidth(_loc8_ > _loc14_ ? _loc8_ : _loc14_);
                  }
                  _loc13_ -= mx_internal::visibleColumns[_loc3_].width;
                  mx_internal::visibleColumns[_loc3_].newlyVisible = false;
                  _loc3_++;
               }
               if(_loc13_ && _loc7_)
               {
                  _loc7_.setWidth(_loc7_.width + _loc13_);
               }
            }
            else
            {
               _loc2_ = mx_internal::visibleLockedColumns.length;
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  _loc12_ = (_loc7_ = mx_internal::visibleLockedColumns[_loc3_]).width / _loc4_;
                  _loc8_ = Math.floor(this.displayWidth * _loc12_);
                  _loc7_.setWidth(_loc8_);
                  _loc7_.explicitWidth = NaN;
                  _loc13_ -= _loc8_;
                  _loc3_++;
               }
               _loc2_ = mx_internal::visibleColumns.length;
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  _loc12_ = (_loc7_ = mx_internal::visibleColumns[_loc3_]).width / _loc4_;
                  _loc8_ = Math.floor(this.displayWidth * _loc12_);
                  _loc7_.setWidth(_loc8_);
                  _loc7_.explicitWidth = NaN;
                  _loc13_ -= _loc8_;
                  _loc3_++;
               }
               if(_loc13_ && _loc7_)
               {
                  _loc7_.setWidth(_loc7_.width + _loc13_);
               }
            }
         }
         else
         {
            _loc4_ = 0;
            _loc2_ = mx_internal::visibleColumns.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(_loc4_ > this.displayWidth - this.lockedColumnWidth)
               {
                  mx_internal::visibleColumns.splice(_loc3_);
                  break;
               }
               _loc4_ += !!isNaN(mx_internal::visibleColumns[_loc3_].explicitWidth) ? mx_internal::visibleColumns[_loc3_].preferredWidth : mx_internal::visibleColumns[_loc3_].explicitWidth;
               _loc3_++;
            }
            if(mx_internal::visibleColumns.length == 0)
            {
               return;
            }
            _loc3_ = mx_internal::visibleColumns[mx_internal::visibleColumns.length - 1].colNum + 1;
            if(_loc4_ < this.displayWidth - this.lockedColumnWidth && _loc3_ < this.displayableColumns.length)
            {
               _loc2_ = this.displayableColumns.length;
               while(_loc3_ < _loc2_ && _loc4_ < this.displayWidth - this.lockedColumnWidth)
               {
                  _loc5_ = this.displayableColumns[_loc3_];
                  mx_internal::visibleColumns.push(_loc5_);
                  _loc4_ += !!isNaN(_loc5_.explicitWidth) ? _loc5_.preferredWidth : _loc5_.explicitWidth;
                  _loc3_++;
               }
            }
            else if(_loc4_ < this.displayWidth - this.lockedColumnWidth && horizontalScrollPosition > 0)
            {
               while(_loc4_ < this.displayWidth - this.lockedColumnWidth && horizontalScrollPosition > 0)
               {
                  _loc5_ = this.displayableColumns[lockedColumnCount + horizontalScrollPosition - 1];
                  if((_loc6_ = !!isNaN(_loc5_.explicitWidth) ? Number(_loc5_.preferredWidth) : Number(_loc5_.explicitWidth)) >= this.displayWidth - this.lockedColumnWidth - _loc4_)
                  {
                     break;
                  }
                  mx_internal::visibleColumns.splice(0,0,_loc5_);
                  var _loc15_:*;
                  var _loc16_:* = _loc15_ = this.super.horizontalScrollPosition - 1;
                  _loc15_.super.horizontalScrollPosition = _loc16_;
                  _loc4_ += _loc6_;
               }
            }
            _loc7_ = mx_internal::visibleColumns[mx_internal::visibleColumns.length - 1];
            _loc8_ = (_loc6_ = !!isNaN(_loc7_.explicitWidth) ? Number(_loc7_.preferredWidth) : Number(_loc7_.explicitWidth)) + this.displayWidth - this.lockedColumnWidth - _loc4_;
            if(_loc7_ == this.displayableColumns[this.displayableColumns.length - 1] && _loc7_.resizable && _loc8_ >= _loc7_.minWidth && _loc8_ > _loc6_)
            {
               _loc7_.setWidth(_loc8_);
               maxHorizontalScrollPosition = this.displayableColumns.length - mx_internal::visibleColumns.length;
            }
            else if(mx_internal::visibleColumns.length == 1 && _loc7_ == this.displayableColumns[this.displayableColumns.length - 1])
            {
               maxHorizontalScrollPosition = this.displayableColumns.length - mx_internal::visibleColumns.length;
            }
            else
            {
               maxHorizontalScrollPosition = this.displayableColumns.length - mx_internal::visibleColumns.length + 1;
            }
         }
         this.lockedColumnWidth = 0;
         if(mx_internal::visibleLockedColumns.length)
         {
            _loc2_ = mx_internal::visibleLockedColumns.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc5_ = mx_internal::visibleLockedColumns[_loc3_];
               this.lockedColumnWidth += _loc5_.width;
               _loc3_++;
            }
         }
      }
      
      override mx_internal function resizeColumn(param1:int, param2:Number) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:DataGridColumn = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if((!mx_internal::visibleColumns || mx_internal::visibleColumns.length == 0) && (!mx_internal::visibleLockedColumns || mx_internal::visibleLockedColumns.length == 0))
         {
            this._columns[param1].setWidth(param2);
            this._columns[param1].preferredWidth = param2;
            return;
         }
         if(param2 < this._columns[param1].minWidth)
         {
            param2 = this._columns[param1].minWidth;
         }
         if(mx_internal::_horizontalScrollPolicy == ScrollPolicy.ON || mx_internal::_horizontalScrollPolicy == ScrollPolicy.AUTO)
         {
            this._columns[param1].setWidth(param2);
            this._columns[param1].explicitWidth = param2;
            this._columns[param1].preferredWidth = param2;
            columnsInvalid = true;
         }
         else
         {
            _loc3_ = this._columns.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(param1 == this._columns[_loc4_].colNum)
               {
                  break;
               }
               _loc4_++;
            }
            if(_loc4_ >= this._columns.length - 1)
            {
               return;
            }
            param1 = _loc4_;
            _loc5_ = 0;
            _loc4_ = param1 + 1;
            while(_loc4_ < _loc3_)
            {
               if(this._columns[_loc4_].visible)
               {
                  if(this._columns[_loc4_].resizable)
                  {
                     _loc5_ += this._columns[_loc4_].width;
                  }
               }
               _loc4_++;
            }
            _loc8_ = this._columns[param1].width - param2 + _loc5_;
            if(_loc5_)
            {
               this._columns[param1].setWidth(param2);
               this._columns[param1].explicitWidth = param2;
            }
            _loc9_ = 0;
            _loc4_ = param1 + 1;
            while(_loc4_ < _loc3_)
            {
               if(this._columns[_loc4_].visible)
               {
                  if(this._columns[_loc4_].resizable)
                  {
                     if((_loc7_ = Math.floor(this._columns[_loc4_].width * _loc8_ / _loc5_)) < this._columns[_loc4_].minWidth)
                     {
                        _loc7_ = this._columns[_loc4_].minWidth;
                     }
                     this._columns[_loc4_].setWidth(_loc7_);
                     _loc9_ += this._columns[_loc4_].width;
                     _loc6_ = this._columns[_loc4_];
                  }
               }
               _loc4_++;
            }
            if(_loc9_ > _loc8_)
            {
               if((_loc7_ = this._columns[param1].width - _loc9_ + _loc8_) < this._columns[param1].minWidth)
               {
                  _loc7_ = this._columns[param1].minWidth;
               }
               this._columns[param1].setWidth(_loc7_);
            }
            else if(_loc6_)
            {
               _loc6_.setWidth(_loc6_.width - _loc9_ + _loc8_);
            }
         }
         itemsSizeChanged = true;
         this.invalidateDisplayList();
      }
      
      protected function drawRowBackground(param1:Sprite, param2:int, param3:Number, param4:Number, param5:uint, param6:int) : void
      {
         var _loc8_:Shape = null;
         var _loc7_:ListBaseContentHolder = ListBaseContentHolder(param1.parent);
         if(param2 < param1.numChildren)
         {
            _loc8_ = Shape(param1.getChildAt(param2));
         }
         else
         {
            (_loc8_ = new FlexShape()).name = "background";
            param1.addChild(_loc8_);
         }
         _loc8_.y = param3;
         param4 = Math.min(param4,_loc7_.height - param3);
         var _loc9_:Graphics;
         (_loc9_ = _loc8_.graphics).clear();
         _loc9_.beginFill(param5,getStyle("backgroundAlpha"));
         _loc9_.drawRect(0,0,_loc7_.width,param4);
         _loc9_.endFill();
      }
      
      protected function drawColumnBackground(param1:Sprite, param2:int, param3:uint, param4:DataGridColumn) : void
      {
         var _loc5_:Shape = null;
         if(!(_loc5_ = Shape(param1.getChildByName(param2.toString()))))
         {
            _loc5_ = new FlexShape();
            param1.addChild(_loc5_);
            _loc5_.name = param2.toString();
         }
         var _loc6_:Graphics;
         (_loc6_ = _loc5_.graphics).clear();
         _loc6_.beginFill(param3);
         var _loc7_:Object = rowInfo[listItems.length - 1];
         var _loc8_:DataGridHeader;
         var _loc9_:Number = (_loc8_ = param1.parent == lockedColumnContent ? DataGridHeader(lockedColumnHeader) : DataGridHeader(header)).rendererArray[param2].x;
         var _loc10_:Number = rowInfo[0].y;
         var _loc11_:Number = Math.min(_loc7_.y + _loc7_.height,listContent.height - _loc10_);
         _loc6_.drawRect(_loc9_,_loc10_,_loc8_.visibleColumns[param2].width,listContent.height - _loc10_);
         _loc6_.endFill();
      }
      
      private function drawHorizontalSeparator(param1:Sprite, param2:int, param3:uint, param4:Number, param5:Boolean = false) : void
      {
         var _loc10_:IFlexDisplayObject = null;
         var _loc11_:IFlexDisplayObject = null;
         var _loc12_:IFlexDisplayObject = null;
         var _loc13_:IFlexDisplayObject = null;
         var _loc14_:Class = null;
         var _loc15_:ISimpleStyleClient = null;
         var _loc16_:Number = NaN;
         var _loc6_:String = "hSeparator" + param2;
         var _loc7_:String = "hLockedSeparator" + param2;
         var _loc8_:String = !!param5 ? _loc7_ : _loc6_;
         var _loc9_:String = !!param5 ? "horizontalLockedSeparatorSkin" : "horizontalSeparatorSkin";
         _loc10_ = IFlexDisplayObject(param1.getChildByName(_loc6_));
         _loc11_ = IFlexDisplayObject(param1.getChildByName(_loc7_));
         _loc13_ = !!param5 ? _loc11_ : _loc10_;
         if(_loc12_ = !!param5 ? _loc10_ : _loc11_)
         {
            param1.removeChild(DisplayObject(_loc12_));
         }
         if(!_loc13_)
         {
            if(_loc14_ = Class(getStyle(_loc9_)))
            {
               (_loc13_ = IFlexDisplayObject(new _loc14_())).name = _loc8_;
               if(_loc15_ = _loc13_ as ISimpleStyleClient)
               {
                  _loc15_.styleName = this;
               }
               param1.addChild(DisplayObject(_loc13_));
            }
         }
         if(_loc13_)
         {
            _loc16_ = !isNaN(_loc13_.measuredHeight) ? Number(_loc13_.measuredHeight) : Number(1);
            _loc13_.setActualSize(this.displayWidth - this.lockedColumnWidth,_loc16_);
            _loc13_.move(0,param4);
         }
         else
         {
            this.drawHorizontalLine(param1,param2,param3,param4);
         }
      }
      
      protected function drawHorizontalLine(param1:Sprite, param2:int, param3:uint, param4:Number) : void
      {
         var _loc5_:ListBaseContentHolder = param1.parent.parent as ListBaseContentHolder;
         var _loc6_:Graphics;
         (_loc6_ = param1.graphics).lineStyle(1,param3);
         _loc6_.moveTo(0,param4);
         _loc6_.lineTo(_loc5_.width,param4);
      }
      
      private function drawVerticalSeparator(param1:Sprite, param2:int, param3:uint, param4:Number, param5:Boolean = false) : void
      {
         var _loc10_:IFlexDisplayObject = null;
         var _loc11_:IFlexDisplayObject = null;
         var _loc12_:IFlexDisplayObject = null;
         var _loc13_:IFlexDisplayObject = null;
         var _loc14_:Class = null;
         var _loc15_:ISimpleStyleClient = null;
         var _loc16_:Number = NaN;
         var _loc6_:String = "vSeparator" + param2;
         var _loc7_:String = "vLockedSeparator" + param2;
         var _loc8_:String = !!param5 ? _loc7_ : _loc6_;
         var _loc9_:String = !!param5 ? "verticalLockedSeparatorSkin" : "verticalSeparatorSkin";
         _loc10_ = IFlexDisplayObject(param1.getChildByName(_loc6_));
         _loc11_ = IFlexDisplayObject(param1.getChildByName(_loc7_));
         _loc13_ = !!param5 ? _loc11_ : _loc10_;
         if(_loc12_ = !!param5 ? _loc10_ : _loc11_)
         {
            param1.removeChild(DisplayObject(_loc12_));
         }
         if(!_loc13_)
         {
            if(_loc14_ = Class(getStyle(_loc9_)))
            {
               (_loc13_ = IFlexDisplayObject(new _loc14_())).name = _loc8_;
               if(_loc15_ = _loc13_ as ISimpleStyleClient)
               {
                  _loc15_.styleName = this;
               }
               param1.addChild(DisplayObject(_loc13_));
            }
         }
         if(_loc13_)
         {
            _loc16_ = !isNaN(_loc13_.measuredWidth) ? Number(_loc13_.measuredWidth) : Number(1);
            _loc13_.setActualSize(_loc16_,param1.parent.parent.height);
            _loc13_.move(param4 - Math.round(_loc16_ / 2),0);
         }
         else
         {
            this.drawVerticalLine(param1,param2,param3,param4);
         }
      }
      
      protected function drawVerticalLine(param1:Sprite, param2:int, param3:uint, param4:Number) : void
      {
         var _loc5_:ListBaseContentHolder = param1.parent.parent as ListBaseContentHolder;
         var _loc6_:Graphics;
         (_loc6_ = param1.graphics).lineStyle();
         _loc6_.beginFill(param3);
         _loc6_.drawRect(param4,!!mx_internal::headerVisible ? Number(0) : Number(1),1,_loc5_.height);
         _loc6_.endFill();
      }
      
      protected function drawLinesAndColumnBackgrounds() : void
      {
         this.drawLinesAndColumnGraphics(listContent,mx_internal::visibleColumns,{});
      }
      
      protected function drawLinesAndColumnGraphics(param1:ListBaseContentHolder, param2:Array, param3:Object) : void
      {
         var _loc7_:uint = 0;
         var _loc8_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:Sprite = null;
         var _loc14_:int = 0;
         var _loc15_:Number = NaN;
         var _loc16_:DataGridColumn = null;
         var _loc17_:Object = null;
         var _loc18_:Shape = null;
         var _loc19_:Graphics = null;
         var _loc20_:DisplayObject = null;
         var _loc4_:Sprite;
         if(!(_loc4_ = Sprite(param1.getChildByName("lines"))))
         {
            (_loc4_ = new UIComponent()).name = "lines";
            _loc4_.cacheAsBitmap = true;
            _loc4_.mouseEnabled = false;
            param1.addChild(_loc4_);
         }
         param1.setChildIndex(_loc4_,param1.numChildren - 1);
         var _loc5_:Array = param1.rowInfo;
         _loc4_.graphics.clear();
         var _loc6_:Sprite;
         if(!(_loc6_ = Sprite(_loc4_.getChildByName("body"))))
         {
            (_loc6_ = new UIComponent()).name = "body";
            _loc6_.mouseEnabled = false;
            _loc4_.addChild(_loc6_);
         }
         _loc6_.graphics.clear();
         while(_loc6_.numChildren)
         {
            _loc6_.removeChildAt(0);
         }
         var _loc9_:uint = !!param2 ? uint(param2.length) : uint(0);
         var _loc10_:uint = param1.listItems.length;
         _loc7_ = getStyle("horizontalGridLineColor");
         if(getStyle("horizontalGridLines"))
         {
            _loc8_ = 0;
            while(_loc8_ < _loc10_)
            {
               if((_loc12_ = _loc5_[_loc8_].y + _loc5_[_loc8_].height) < param1.height)
               {
                  this.drawHorizontalSeparator(_loc6_,_loc8_,_loc7_,_loc12_);
               }
               _loc8_++;
            }
         }
         if(param3.top)
         {
            this.drawHorizontalSeparator(_loc6_,_loc8_++,0,_loc5_[0].y,true);
         }
         if(param3.bottom && _loc10_ > 0)
         {
            this.drawHorizontalSeparator(_loc6_,_loc8_++,0,_loc5_[_loc10_ - 1].y + _loc5_[_loc10_ - 1].height,true);
         }
         var _loc11_:Boolean = getStyle("verticalGridLines");
         _loc7_ = getStyle("verticalGridLineColor");
         if(_loc9_)
         {
            _loc13_ = Sprite(param1.getChildByName("colBGs"));
            _loc14_ = -1;
            _loc15_ = 0;
            _loc8_ = 0;
            while(_loc8_ < _loc9_)
            {
               if(_loc11_ && _loc8_ < _loc9_ - 1)
               {
                  this.drawVerticalSeparator(_loc6_,_loc8_,_loc7_,_loc15_ + param2[_loc8_].width);
               }
               _loc16_ = param2[_loc8_];
               if(enabled)
               {
                  _loc17_ = _loc16_.getStyle("backgroundColor");
               }
               else
               {
                  _loc17_ = _loc16_.getStyle("backgroundDisabledColor");
               }
               if(_loc17_ !== null && !isNaN(Number(_loc17_)))
               {
                  if(!_loc13_)
                  {
                     (_loc13_ = new FlexSprite()).mouseEnabled = false;
                     _loc13_.name = "colBGs";
                     param1.addChildAt(_loc13_,param1.getChildIndex(param1.getChildByName("rowBGs")) + 1);
                  }
                  this.drawColumnBackground(_loc13_,_loc8_,Number(_loc17_),_loc16_);
                  _loc14_ = _loc8_;
               }
               else if(_loc13_)
               {
                  if(_loc18_ = Shape(_loc13_.getChildByName(_loc8_.toString())))
                  {
                     (_loc19_ = _loc18_.graphics).clear();
                     _loc13_.removeChild(_loc18_);
                  }
               }
               _loc15_ += param2[_loc8_].width;
               _loc8_++;
            }
            if(_loc13_ && _loc13_.numChildren)
            {
               while(_loc13_.numChildren)
               {
                  _loc20_ = _loc13_.getChildAt(_loc13_.numChildren - 1);
                  if(parseInt(_loc20_.name) <= _loc14_)
                  {
                     break;
                  }
                  _loc13_.removeChild(_loc20_);
               }
            }
         }
         if(param3.right && param2 && param2.length)
         {
            if(param1.listItems.length && param1.listItems[0].length)
            {
               this.drawVerticalSeparator(_loc6_,_loc8_++,0,param1.listItems[0][_loc9_ - 1].x + param2[_loc9_ - 1].width,true);
            }
            else
            {
               _loc15_ = 0;
               _loc8_ = 0;
               while(_loc8_ < _loc9_)
               {
                  _loc15_ += param2[_loc8_].width;
                  _loc8_++;
               }
               this.drawVerticalSeparator(_loc6_,_loc8_++,0,_loc15_,true);
            }
         }
         if(param3.left)
         {
            this.drawVerticalSeparator(_loc6_,_loc8_++,0,0,true);
         }
      }
      
      mx_internal function _drawHeaderBackground(param1:UIComponent) : void
      {
         this.drawHeaderBackground(param1);
      }
      
      protected function drawHeaderBackground(param1:UIComponent) : void
      {
         DataGridHeader(param1.parent)._drawHeaderBackground(param1);
      }
      
      mx_internal function _clearSeparators() : void
      {
         this.clearSeparators();
      }
      
      protected function clearSeparators() : void
      {
         DataGridHeader(header)._clearSeparators();
         if(lockedColumnHeader)
         {
            DataGridHeader(lockedColumnHeader)._clearSeparators();
         }
      }
      
      mx_internal function _drawSeparators() : void
      {
         this.drawSeparators();
      }
      
      protected function drawSeparators() : void
      {
         DataGridHeader(header)._drawSeparators();
         if(lockedColumnHeader)
         {
            DataGridHeader(lockedColumnHeader)._drawSeparators();
         }
      }
      
      private function updateSortIndexAndDirection() : void
      {
         if(!this.sortableColumns)
         {
            this.lastSortIndex = this.sortIndex;
            this.sortIndex = -1;
            if(this.lastSortIndex != this.sortIndex)
            {
               this.invalidateDisplayList();
            }
            return;
         }
         if(!dataProvider)
         {
            return;
         }
         var _loc1_:ICollectionView = ICollectionView(dataProvider);
         var _loc2_:ISort = _loc1_.sort;
         if(!_loc2_)
         {
            this.sortIndex = this.lastSortIndex = -1;
            return;
         }
         var _loc3_:Array = _loc2_.fields;
         if(!_loc3_)
         {
            return;
         }
         if(_loc3_.length != 1)
         {
            this.lastSortIndex = this.sortIndex;
            this.sortIndex = -1;
            if(this.lastSortIndex != this.sortIndex)
            {
               this.invalidateDisplayList();
            }
            return;
         }
         var _loc4_:ISortField = _loc3_[0];
         var _loc5_:int = this._columns.length;
         this.sortIndex = -1;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            if(this._columns[_loc6_].dataField == _loc4_.name)
            {
               this.sortIndex = !!this._columns[_loc6_].sortable ? int(_loc6_) : -1;
               this.sortDirection = !!_loc4_.descending ? "DESC" : "ASC";
               return;
            }
            _loc6_++;
         }
      }
      
      mx_internal function _placeSortArrow() : void
      {
         this.placeSortArrow();
      }
      
      protected function placeSortArrow() : void
      {
         DataGridHeader(header)._placeSortArrow();
         if(lockedColumnHeader)
         {
            DataGridHeader(lockedColumnHeader)._placeSortArrow();
         }
      }
      
      private function sortByColumn(param1:int) : void
      {
         var _loc4_:ISort = null;
         var _loc5_:ISortField = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc2_:DataGridColumn = this.columns[param1];
         var _loc3_:* = Boolean(_loc2_.sortDescending);
         if(_loc2_.sortable)
         {
            if(_loc4_ = collection.sort)
            {
               _loc4_.compareFunction = null;
               if(_loc7_ = _loc4_.fields)
               {
                  _loc8_ = 0;
                  while(_loc8_ < _loc7_.length)
                  {
                     if(_loc7_[_loc8_].name == _loc2_.dataField)
                     {
                        _loc3_ = !(_loc5_ = _loc7_[_loc8_]).descending;
                        break;
                     }
                     _loc8_++;
                  }
               }
            }
            else
            {
               _loc4_ = new Sort();
            }
            if(!_loc5_)
            {
               _loc5_ = new SortField(_loc2_.dataField);
            }
            _loc2_.sortDescending = _loc3_;
            _loc6_ = !!_loc3_ ? "DESC" : "ASC";
            this.sortDirection = _loc6_;
            this.lastSortIndex = this.sortIndex;
            this.sortIndex = param1;
            this.sortColumn = _loc2_;
            _loc5_.name = _loc2_.dataField;
            if(_loc2_.sortCompareFunction != null)
            {
               _loc5_.compareFunction = _loc2_.sortCompareFunction;
            }
            else
            {
               _loc5_.compareFunction = null;
            }
            _loc5_.descending = _loc3_;
            _loc4_.fields = [_loc5_];
         }
         collection.sort = _loc4_;
         collection.refresh();
      }
      
      private function setEditedItemPosition(param1:Object) : void
      {
         this.bEditedItemPositionChanged = true;
         this._proposedEditedItemPosition = param1;
         this.invalidateDisplayList();
      }
      
      private function commitEditedItemPosition(param1:Object) : void
      {
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:ListEvent = null;
         if(!enabled || !this.editable)
         {
            return;
         }
         if(!collection || collection.length == 0)
         {
            return;
         }
         if(this.itemEditorInstance && param1 && this.itemEditorInstance is IFocusManagerComponent && this._editedItemPosition.rowIndex == param1.rowIndex && this._editedItemPosition.columnIndex == param1.columnIndex)
         {
            IFocusManagerComponent(this.itemEditorInstance).setFocus();
            return;
         }
         if(this.itemEditorInstance)
         {
            if(!param1)
            {
               _loc7_ = DataGridEventReason.OTHER;
            }
            else
            {
               _loc7_ = !this.editedItemPosition || param1.rowIndex == this.editedItemPosition.rowIndex ? DataGridEventReason.NEW_COLUMN : DataGridEventReason.NEW_ROW;
            }
            if(!this.endEdit(_loc7_) && _loc7_ != DataGridEventReason.OTHER)
            {
               return;
            }
         }
         this._editedItemPosition = param1;
         if(!param1)
         {
            return;
         }
         if(this.dontEdit)
         {
            return;
         }
         var _loc2_:int = param1.rowIndex;
         var _loc3_:int = param1.columnIndex;
         if(this.displayableColumns.length != this._columns.length)
         {
            _loc8_ = 0;
            while(_loc8_ < this.displayableColumns.length)
            {
               if(this.displayableColumns[_loc8_].colNum >= _loc3_)
               {
                  _loc3_ = _loc8_;
                  break;
               }
               _loc8_++;
            }
            if(_loc8_ == this.displayableColumns.length)
            {
               _loc3_ = 0;
            }
         }
         var _loc4_:Boolean = false;
         if(selectedIndex != param1.rowIndex)
         {
            commitSelectedIndex(param1.rowIndex);
            _loc4_ = true;
         }
         this.scrollToEditedItem(_loc2_,_loc3_);
         var _loc5_:IListItemRenderer;
         if(!(_loc5_ = this.actualContentHolder.listItems[this.actualRowIndex][this.actualColIndex]))
         {
            this.commitEditedItemPosition(null);
            return;
         }
         if(!this.isItemEditable(_loc5_.data))
         {
            this.commitEditedItemPosition(null);
            return;
         }
         if(_loc4_)
         {
            (_loc9_ = new ListEvent(ListEvent.CHANGE)).columnIndex = param1.columnIndex;
            _loc9_.rowIndex = param1.rowIndex;
            _loc9_.itemRenderer = _loc5_;
            dispatchEvent(_loc9_);
         }
         var _loc6_:DataGridEvent;
         (_loc6_ = new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGIN,false,true)).columnIndex = this.displayableColumns[_loc3_].colNum;
         _loc6_.rowIndex = this._editedItemPosition.rowIndex;
         _loc6_.itemRenderer = _loc5_;
         dispatchEvent(_loc6_);
         this.lastEditedItemPosition = this._editedItemPosition;
         if(this.bEditedItemPositionChanged)
         {
            this.bEditedItemPositionChanged = false;
            this.commitEditedItemPosition(this._proposedEditedItemPosition);
            this._proposedEditedItemPosition = undefined;
         }
         if(!this.itemEditorInstance)
         {
            this.commitEditedItemPosition(null);
         }
      }
      
      private function scrollToEditedItem(param1:int, param2:int) : void
      {
         var _loc8_:int = 0;
         this.actualContentHolder = listContent;
         var _loc3_:Array = this.actualContentHolder.listItems;
         var _loc4_:int = verticalScrollPosition + _loc3_.length - 1 + lockedRowCount;
         var _loc5_:int = rowInfo[_loc3_.length - 1].y + rowInfo[_loc3_.length - 1].height > listContent.height ? 1 : 0;
         if(param1 > lockedRowCount)
         {
            if(param1 < verticalScrollPosition + lockedRowCount)
            {
               this.verticalScrollPosition = param1 - lockedRowCount;
            }
            else
            {
               while(param1 > _loc4_ || param1 == _loc4_ && param1 > verticalScrollPosition + lockedRowCount && _loc5_)
               {
                  if(verticalScrollPosition == maxVerticalScrollPosition)
                  {
                     break;
                  }
                  this.verticalScrollPosition = Math.min(verticalScrollPosition + (param1 > _loc4_ ? param1 - _loc4_ : _loc5_),maxVerticalScrollPosition);
                  _loc4_ = verticalScrollPosition + _loc3_.length - 1 + lockedRowCount;
                  _loc5_ = rowInfo[_loc3_.length - 1].y + rowInfo[_loc3_.length - 1].height > listContent.height ? 1 : 0;
               }
            }
            this.actualRowIndex = param1 - verticalScrollPosition - lockedRowCount;
         }
         else if(param1 == lockedRowCount)
         {
            this.verticalScrollPosition = 0;
            this.actualRowIndex = param1 - lockedRowCount;
         }
         else
         {
            if(lockedRowCount)
            {
               this.actualContentHolder = lockedRowContent;
            }
            this.actualRowIndex = param1;
         }
         _loc3_ = this.actualContentHolder.listItems;
         var _loc6_:uint = _loc3_ && _loc3_[0] ? uint(_loc3_[0].length) : uint(mx_internal::visibleColumns.length);
         var _loc7_:int = horizontalScrollPosition + _loc6_ - 1 + lockedColumnCount;
         if(param2 > lockedColumnCount)
         {
            _loc8_ = _loc3_[0][_loc6_ - 1].x + _loc3_[0][_loc6_ - 1].width > listContent.width ? 1 : 0;
            if(param2 < horizontalScrollPosition + lockedColumnCount)
            {
               this.horizontalScrollPosition = param2 - lockedColumnCount;
            }
            else
            {
               while(param2 > _loc7_ || param2 == _loc7_ && param2 > horizontalScrollPosition + lockedColumnCount && _loc8_)
               {
                  if(horizontalScrollPosition == maxHorizontalScrollPosition)
                  {
                     break;
                  }
                  this.horizontalScrollPosition = Math.min(horizontalScrollPosition + (param2 > _loc7_ ? param2 - _loc7_ : _loc8_),maxHorizontalScrollPosition);
                  _loc6_ = _loc3_ && _loc3_[0] ? uint(_loc3_[0].length) : uint(mx_internal::visibleColumns.length);
                  _loc7_ = horizontalScrollPosition + _loc6_ - 1 + lockedColumnCount;
                  _loc8_ = _loc3_[0][_loc6_ - 1].x + _loc3_[0][_loc6_ - 1].width > listContent.width ? 1 : 0;
               }
            }
            this.actualColIndex = param2 - horizontalScrollPosition - lockedColumnCount;
         }
         else if(param2 == lockedColumnCount)
         {
            this.horizontalScrollPosition = 0;
            this.actualColIndex = param2 - lockedColumnCount;
         }
         else
         {
            if(lockedColumnCount)
            {
               if(this.actualContentHolder == lockedRowContent)
               {
                  this.actualContentHolder = lockedColumnAndRowContent;
               }
               else
               {
                  this.actualContentHolder = lockedColumnContent;
               }
            }
            this.actualColIndex = param2;
         }
      }
      
      public function createItemEditor(param1:int, param2:int) : void
      {
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:IFactory = null;
         var _loc13_:Class = null;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:String = null;
         var _loc17_:* = false;
         var _loc18_:* = false;
         var _loc19_:IFlexModuleFactory = null;
         if(this.displayableColumns.length != this._columns.length)
         {
            _loc7_ = 0;
            while(_loc7_ < this.displayableColumns.length)
            {
               if(this.displayableColumns[_loc7_].colNum >= param1)
               {
                  param1 = _loc7_;
                  break;
               }
               _loc7_++;
            }
            if(_loc7_ == this.displayableColumns.length)
            {
               param1 = 0;
            }
         }
         var _loc3_:DataGridColumn = this.displayableColumns[param1];
         if(param2 >= lockedRowCount)
         {
            param2 -= verticalScrollPosition + lockedRowCount;
         }
         if(param1 >= lockedColumnCount)
         {
            param1 -= horizontalScrollPosition + lockedColumnCount;
         }
         var _loc4_:IListItemRenderer = this.actualContentHolder.listItems[param2][param1];
         var _loc5_:ListRowInfo = this.actualContentHolder.rowInfo[param2];
         if(!_loc3_.rendererIsEditor)
         {
            _loc8_ = 0;
            _loc9_ = -2;
            _loc10_ = 0;
            _loc11_ = 4;
            if(!this.itemEditorInstance)
            {
               if((_loc12_ = _loc3_.itemEditor) == DataGridColumn.defaultItemEditorFactory)
               {
                  if(_loc13_ = getStyle("defaultDataGridItemEditor"))
                  {
                     _loc14_ = StringUtil.trimArrayElements(_loc3_.getStyle("fontFamily"),",");
                     _loc15_ = _loc3_.getStyle("fontWeight");
                     _loc16_ = _loc3_.getStyle("fontStyle");
                     _loc17_ = _loc15_ == "bold";
                     _loc18_ = _loc16_ == "italic";
                     _loc19_ = getFontContext(_loc14_,_loc17_,_loc18_);
                     _loc12_ = _loc3_.itemEditor = new ContextualClassFactory(_loc13_,_loc19_);
                  }
               }
               _loc8_ = _loc3_.editorXOffset;
               _loc9_ = _loc3_.editorYOffset;
               _loc10_ = _loc3_.editorWidthOffset;
               _loc11_ = _loc3_.editorHeightOffset;
               this.itemEditorInstance = _loc12_.newInstance();
               this.itemEditorInstance.owner = this;
               this.itemEditorInstance.styleName = _loc3_;
               this.actualContentHolder.addChild(DisplayObject(this.itemEditorInstance));
            }
            this.actualContentHolder.setChildIndex(DisplayObject(this.itemEditorInstance),this.actualContentHolder.numChildren - 1);
            this.itemEditorInstance.visible = true;
            this.itemEditorInstance.move(_loc4_.x + _loc8_,_loc5_.y + _loc9_);
            this.itemEditorInstance.setActualSize(Math.min(_loc3_.width + _loc10_,this.actualContentHolder.width - 1 - this.itemEditorInstance.x),Math.min(_loc5_.height + _loc11_,this.actualContentHolder.height - this.itemEditorInstance.y));
            DisplayObject(this.itemEditorInstance).addEventListener(FocusEvent.FOCUS_OUT,this.itemEditorFocusOutHandler);
            _loc4_.visible = false;
         }
         else
         {
            this.itemEditorInstance = _loc4_;
         }
         DisplayObject(this.itemEditorInstance).addEventListener(KeyboardEvent.KEY_DOWN,this.editorKeyDownHandler);
         if(focusManager)
         {
            focusManager.defaultButtonEnabled = false;
         }
         systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_DOWN,this.editorMouseDownHandler,true,0,true);
         systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,this.editorMouseDownHandler,false,0,true);
         systemManager.addEventListener(Event.RESIZE,this.editorAncestorResizeHandler);
         addEventListener(Event.RESIZE,this.editorAncestorResizeHandler);
         var _loc6_:DataGridEvent = new DataGridEvent(DataGridEvent.ITEM_EDITOR_CREATE,false,true,param1,null,param2);
         dispatchEvent(_loc6_);
      }
      
      private function findNextItemRenderer(param1:Boolean) : Boolean
      {
         var _loc7_:String = null;
         if(!this.lastEditedItemPosition)
         {
            return false;
         }
         if(this._proposedEditedItemPosition !== undefined)
         {
            return true;
         }
         this._editedItemPosition = this.lastEditedItemPosition;
         var _loc2_:int = this._editedItemPosition.rowIndex;
         var _loc3_:int = this._editedItemPosition.columnIndex;
         var _loc4_:Boolean = false;
         var _loc5_:int = !!param1 ? -1 : 1;
         var _loc6_:int = collection.length - 1;
         while(!_loc4_)
         {
            _loc3_ += _loc5_;
            if(_loc3_ >= this._columns.length || _loc3_ < 0)
            {
               _loc3_ = _loc3_ < 0 ? int(this._columns.length - 1) : 0;
               _loc2_ += _loc5_;
               if(_loc2_ > _loc6_ || _loc2_ < 0)
               {
                  if(this.endEdit(DataGridEventReason.NEW_ROW))
                  {
                     this.setEditedItemPosition(null);
                     this.deferFocus();
                     return false;
                  }
                  return true;
               }
            }
            if(this._columns[_loc3_].editable && this._columns[_loc3_].visible)
            {
               _loc4_ = true;
               _loc7_ = _loc2_ == this._editedItemPosition.rowIndex ? DataGridEventReason.NEW_COLUMN : DataGridEventReason.NEW_ROW;
               if(!this.itemEditorInstance || this.endEdit(_loc7_))
               {
                  this.beginningEdit(_loc3_,_loc2_);
               }
            }
         }
         return _loc4_;
      }
      
      public function destroyItemEditor() : void
      {
         var _loc1_:DataGridEvent = null;
         if(this.itemEditorInstance)
         {
            DisplayObject(this.itemEditorInstance).removeEventListener(KeyboardEvent.KEY_DOWN,this.editorKeyDownHandler);
            if(focusManager)
            {
               focusManager.defaultButtonEnabled = true;
            }
            systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_DOWN,this.editorMouseDownHandler,true);
            systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,this.editorMouseDownHandler);
            systemManager.removeEventListener(Event.RESIZE,this.editorAncestorResizeHandler);
            removeEventListener(Event.RESIZE,this.editorAncestorResizeHandler);
            _loc1_ = new DataGridEvent(DataGridEvent.ITEM_FOCUS_OUT);
            _loc1_.columnIndex = this._editedItemPosition.columnIndex;
            _loc1_.rowIndex = this._editedItemPosition.rowIndex;
            _loc1_.itemRenderer = this.itemEditorInstance;
            dispatchEvent(_loc1_);
            if(!this._columns[this._editedItemPosition.columnIndex].rendererIsEditor)
            {
               if(this.itemEditorInstance && this.itemEditorInstance is UIComponent)
               {
                  UIComponent(this.itemEditorInstance).drawFocus(false);
               }
               this.deferFocus();
               if(this.itemEditorInstance)
               {
                  this.actualContentHolder.removeChild(DisplayObject(this.itemEditorInstance));
                  this.editedItemRenderer.visible = true;
               }
            }
            this.itemEditorInstance = null;
            this._editedItemPosition = null;
         }
      }
      
      private function beginningEdit(param1:int, param2:int, param3:IListItemRenderer = null) : void
      {
         var _loc4_:DataGridEvent;
         (_loc4_ = new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING,false,true)).columnIndex = Math.min(param1,this.columns.length - 1);
         _loc4_.dataField = this._columns[param1].dataField;
         _loc4_.rowIndex = Math.min(param2,collection.length - 1);
         _loc4_.itemRenderer = param3;
         if(!dispatchEvent(_loc4_))
         {
            this.lastEditedItemPosition = {
               "columnIndex":param1,
               "rowIndex":param2
            };
         }
      }
      
      private function endEdit(param1:String) : Boolean
      {
         if(!this.editedItemRenderer)
         {
            return true;
         }
         this.inEndEdit = true;
         var _loc2_:DataGridEvent = new DataGridEvent(DataGridEvent.ITEM_EDIT_END,false,true);
         _loc2_.columnIndex = this.editedItemPosition.columnIndex;
         _loc2_.dataField = this._columns[this.editedItemPosition.columnIndex].dataField;
         _loc2_.rowIndex = this.editedItemPosition.rowIndex;
         _loc2_.itemRenderer = this.editedItemRenderer;
         _loc2_.reason = param1;
         dispatchEvent(_loc2_);
         this.dontEdit = this.itemEditorInstance != null;
         if(!this.dontEdit && param1 == DataGridEventReason.CANCELLED)
         {
            this.deferFocus();
         }
         this.inEndEdit = false;
         return !_loc2_.isDefaultPrevented();
      }
      
      public function isItemEditable(param1:Object) : Boolean
      {
         if(!this.editable)
         {
            return false;
         }
         if(!param1)
         {
            return false;
         }
         return true;
      }
      
      override mx_internal function columnRendererChanged(param1:DataGridColumn) : void
      {
         var _loc2_:DisplayObject = null;
         var _loc4_:* = undefined;
         var _loc5_:Array = null;
         var _loc6_:IFactory = null;
         var _loc7_:Dictionary = null;
         var _loc8_:* = undefined;
         var _loc3_:Dictionary = param1.measuringObjects;
         if(_loc3_)
         {
            for(_loc4_ in _loc3_)
            {
               _loc6_ = IFactory(_loc4_);
               _loc2_ = param1.measuringObjects[_loc6_];
               if(_loc2_)
               {
                  _loc2_.parent.removeChild(_loc2_);
                  param1.measuringObjects[_loc6_] = null;
               }
               if(param1.freeItemRenderersByFactory && param1.freeItemRenderersByFactory[_loc6_])
               {
                  _loc7_ = param1.freeItemRenderersByFactory[_loc6_];
                  for(_loc8_ in _loc7_)
                  {
                     _loc2_ = DisplayObject(_loc8_);
                     _loc2_.parent.removeChild(_loc2_);
                  }
                  param1.freeItemRenderersByFactory[_loc6_] = new Dictionary(true);
               }
            }
            if(_loc5_ = freeItemRenderersTable[param1] as Array)
            {
               while(_loc5_.length)
               {
                  _loc2_ = _loc5_.pop();
               }
            }
         }
         _loc2_ = param1.cachedHeaderRenderer as DisplayObject;
         if(_loc2_ && _loc2_.parent)
         {
            _loc2_.parent.removeChild(_loc2_);
         }
         param1.cachedHeaderRenderer = null;
         rendererChanged = true;
         this.invalidateDisplayList();
      }
      
      override protected function collectionChangeHandler(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:CollectionEvent = null;
         var _loc4_:CollectionEvent = null;
         if(param1 is CollectionEvent)
         {
            _loc3_ = CollectionEvent(param1);
            if(_loc3_.kind == CollectionEventKind.RESET)
            {
               if(this.itemEditorInstance)
               {
                  this.endEdit(DataGridEventReason.CANCELLED);
               }
               this.setEditedItemPosition(null);
               if(this.generatedColumns)
               {
                  this.generateCols();
               }
               else
               {
                  columnsInvalid = true;
               }
               this.updateSortIndexAndDirection();
               if(lockedRowContent)
               {
                  lockedRowContent.iterator = collection.createCursor();
               }
               if(lockedColumnAndRowContent)
               {
                  lockedColumnAndRowContent.iterator = collection.createCursor();
               }
            }
            else if(_loc3_.kind == CollectionEventKind.REFRESH && !this.manualSort)
            {
               this.updateSortIndexAndDirection();
            }
            else if(_loc3_.kind == CollectionEventKind.ADD)
            {
               if(this.editedItemPosition)
               {
                  if(_loc3_.location <= this.editedItemPosition.rowIndex)
                  {
                     _loc2_ = this.editedItemPosition;
                     if(this.inEndEdit)
                     {
                        this._editedItemPosition = {
                           "columnIndex":this.editedItemPosition.columnIndex,
                           "rowIndex":Math.max(0,this.editedItemPosition.rowIndex + _loc3_.items.length)
                        };
                     }
                     else if(this.itemEditorInstance)
                     {
                        this._editedItemPosition = {
                           "columnIndex":this.editedItemPosition.columnIndex,
                           "rowIndex":Math.max(0,this.editedItemPosition.rowIndex + _loc3_.items.length)
                        };
                        this.itemEditorPositionChanged = true;
                        this.lastEditedItemPosition = this._editedItemPosition;
                     }
                     else
                     {
                        this.setEditedItemPosition({
                           "columnIndex":_loc2_.columnIndex,
                           "rowIndex":Math.max(0,_loc2_.rowIndex + _loc3_.items.length)
                        });
                     }
                  }
               }
            }
            else if(_loc3_.kind == CollectionEventKind.REMOVE)
            {
               if(this.editedItemPosition)
               {
                  if(collection.length == 0)
                  {
                     if(this.itemEditorInstance)
                     {
                        this.endEdit(DataGridEventReason.CANCELLED);
                     }
                     this.setEditedItemPosition(null);
                  }
                  else if(_loc3_.location <= this.editedItemPosition.rowIndex)
                  {
                     _loc2_ = this.editedItemPosition;
                     if(_loc3_.location == this.editedItemPosition.rowIndex && this.itemEditorInstance)
                     {
                        this.endEdit(DataGridEventReason.CANCELLED);
                     }
                     if(this.inEndEdit)
                     {
                        this._editedItemPosition = {
                           "columnIndex":this.editedItemPosition.columnIndex,
                           "rowIndex":Math.max(0,this.editedItemPosition.rowIndex - _loc3_.items.length)
                        };
                     }
                     else if(this.itemEditorInstance)
                     {
                        this._editedItemPosition = {
                           "columnIndex":this.editedItemPosition.columnIndex,
                           "rowIndex":Math.max(0,this.editedItemPosition.rowIndex - _loc3_.items.length)
                        };
                        this.itemEditorPositionChanged = true;
                        this.lastEditedItemPosition = this._editedItemPosition;
                     }
                     else
                     {
                        this.setEditedItemPosition({
                           "columnIndex":_loc2_.columnIndex,
                           "rowIndex":Math.max(0,_loc2_.rowIndex - _loc3_.items.length)
                        });
                     }
                  }
               }
            }
            else if(_loc3_.kind == CollectionEventKind.REPLACE)
            {
               if(this.editedItemPosition)
               {
                  if(_loc3_.location == this.editedItemPosition.rowIndex && this.itemEditorInstance)
                  {
                     this.endEdit(DataGridEventReason.CANCELLED);
                  }
               }
            }
         }
         super.collectionChangeHandler(param1);
         if(param1 is CollectionEvent)
         {
            if((_loc4_ = CollectionEvent(param1)).kind == CollectionEventKind.ADD)
            {
               if(collection.length == 1)
               {
                  if(this.generatedColumns)
                  {
                     this.generateCols();
                  }
               }
            }
            else if(_loc4_.kind == CollectionEventKind.REFRESH)
            {
               if(lockedRowCount && lockedRowContent)
               {
                  lockedRowContent.iterator.seek(CursorBookmark.FIRST,0);
               }
            }
         }
         if(itemsNeedMeasurement)
         {
            invalidateProperties();
         }
      }
      
      override protected function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc3_:Sprite = null;
         var _loc5_:Point = null;
         var _loc6_:Boolean = false;
         _loc2_ = this.mouseEventToItemRenderer(param1);
         this.lastItemDown = null;
         var _loc4_:Boolean;
         if(!(_loc4_ = itemRendererContains(this.itemEditorInstance,DisplayObject(param1.target))))
         {
            if(_loc2_)
            {
               this.lastItemDown = _loc2_;
               _loc5_ = itemRendererToIndices(_loc2_);
               _loc6_ = true;
               if(this.itemEditorInstance)
               {
                  if(this.displayableColumns[_loc5_.x].editable == false)
                  {
                     _loc6_ = this.endEdit(DataGridEventReason.OTHER);
                  }
                  else if(this.editedItemPosition)
                  {
                     _loc6_ = this.endEdit(this.editedItemPosition.rowIndex == _loc5_.y ? DataGridEventReason.NEW_COLUMN : DataGridEventReason.NEW_ROW);
                  }
                  else
                  {
                     _loc6_ = false;
                  }
               }
               if(!_loc6_)
               {
                  return;
               }
            }
            else if(this.itemEditorInstance)
            {
               this.endEdit(DataGridEventReason.OTHER);
            }
            super.mouseDownHandler(param1);
            if(_loc2_)
            {
               if(this.displayableColumns[_loc5_.x].rendererIsEditor)
               {
                  resetDragScrolling();
               }
            }
         }
         else
         {
            resetDragScrolling();
         }
      }
      
      override protected function mouseUpHandler(param1:MouseEvent) : void
      {
         var _loc2_:DataGridEvent = null;
         var _loc3_:IListItemRenderer = null;
         var _loc4_:Sprite = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Point = null;
         _loc3_ = this.mouseEventToItemRenderer(param1);
         super.mouseUpHandler(param1);
         if(_loc3_ && _loc3_ != this.itemEditorInstance && (this.lastItemDown == _loc3_ || itemRendererContains(this.lastItemDown,this.lastItemFocused)))
         {
            if(this.lastItemDown != _loc3_)
            {
               _loc3_ = this.lastItemDown;
            }
            this.lastItemFocused = null;
            if((_loc7_ = itemRendererToIndices(_loc3_)) && _loc7_.y >= 0 && this.editable && !this.dontEdit)
            {
               if(this.displayableColumns[_loc7_.x].editable)
               {
                  this.beginningEdit(this.displayableColumns[_loc7_.x].colNum,_loc7_.y,_loc3_);
               }
               else
               {
                  this.lastEditedItemPosition = {
                     "columnIndex":this.displayableColumns[_loc7_.x].colNum,
                     "rowIndex":_loc7_.y
                  };
               }
            }
         }
         else if(this.lastItemDown && this.lastItemDown != this.itemEditorInstance)
         {
            if((_loc7_ = itemRendererToIndices(this.lastItemDown)) && _loc7_.y >= 0 && this.editable && !this.dontEdit)
            {
               if(this.displayableColumns[_loc7_.x].editable)
               {
                  this.beginningEdit(this.displayableColumns[_loc7_.x].colNum,_loc7_.y,this.lastItemDown);
               }
               else
               {
                  this.lastEditedItemPosition = {
                     "columnIndex":this.displayableColumns[_loc7_.x].colNum,
                     "rowIndex":_loc7_.y
                  };
               }
            }
         }
         this.lastItemDown = null;
      }
      
      override protected function focusInHandler(param1:FocusEvent) : void
      {
         var _loc2_:DataGridEvent = null;
         var _loc3_:Boolean = false;
         if(this.losingFocus)
         {
            this.losingFocus = false;
            return;
         }
         if(this.editable)
         {
            addEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.keyFocusChangeHandler);
            addEventListener(MouseEvent.MOUSE_DOWN,this.mouseFocusChangeHandler);
         }
         if(param1.target != this)
         {
            if(this.itemEditorInstance && itemRendererContains(this.itemEditorInstance,DisplayObject(param1.target)))
            {
               return;
            }
            this.lastItemFocused = DisplayObject(param1.target);
            return;
         }
         this.lastItemFocused = null;
         super.focusInHandler(param1);
         if(this.editable && !mx_internal::isPressed)
         {
            this._editedItemPosition = this.lastEditedItemPosition;
            _loc3_ = false;
            if(!this._editedItemPosition)
            {
               this._editedItemPosition = {
                  "rowIndex":0,
                  "columnIndex":0
               };
            }
            while(this._editedItemPosition.columnIndex != this._columns.length)
            {
               if(this._columns[this._editedItemPosition.columnIndex].editable && this._columns[this._editedItemPosition.columnIndex].visible)
               {
                  _loc3_ = true;
                  break;
               }
               ++this._editedItemPosition.columnIndex;
            }
            if(_loc3_)
            {
               this.beginningEdit(this._editedItemPosition.columnIndex,this._editedItemPosition.rowIndex);
            }
         }
      }
      
      override protected function focusOutHandler(param1:FocusEvent) : void
      {
         var _loc2_:DisplayObject = null;
         if(param1.target == this)
         {
            super.focusOutHandler(param1);
         }
         if(param1.relatedObject == this && itemRendererContains(this.itemEditorInstance,DisplayObject(param1.target)))
         {
            return;
         }
         if(param1.relatedObject == null && itemRendererContains(this.editedItemRenderer,DisplayObject(param1.target)))
         {
            return;
         }
         if(param1.relatedObject == null && itemRendererContains(this.itemEditorInstance,DisplayObject(param1.target)))
         {
            return;
         }
         if(this.itemEditorInstance && (!param1.relatedObject || !itemRendererContains(this.itemEditorInstance,param1.relatedObject)))
         {
            _loc2_ = DisplayObject(param1.relatedObject);
            while(_loc2_ && _loc2_ != this)
            {
               if(_loc2_ is IListItemRenderer && _loc2_.parent.parent == this && _loc2_.parent is ListBaseContentHolder)
               {
                  if(_loc2_.visible)
                  {
                     return;
                  }
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
            this.endEdit(DataGridEventReason.OTHER);
            removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.keyFocusChangeHandler);
            removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseFocusChangeHandler);
         }
      }
      
      private function deactivateHandler(param1:Event) : void
      {
         if(this.itemEditorInstance)
         {
            this.endEdit(DataGridEventReason.OTHER);
            this.deferFocus();
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(this.itemEditorInstance || param1.target != param1.currentTarget)
         {
            return;
         }
         if(param1.keyCode != Keyboard.SPACE)
         {
            super.keyDownHandler(param1);
         }
         else if(caretIndex != -1)
         {
            moveSelectionVertically(param1.keyCode,param1.shiftKey,param1.ctrlKey);
         }
      }
      
      override public function itemToLabel(param1:Object) : String
      {
         return this._columns[this.sortIndex == -1 ? 0 : this.sortIndex].itemToLabel(param1);
      }
      
      private function editorMouseDownHandler(param1:Event) : void
      {
         if(param1 is MouseEvent && owns(DisplayObject(param1.target)))
         {
            return;
         }
         this.endEdit(DataGridEventReason.OTHER);
         this.deferFocus();
      }
      
      private function editorKeyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ESCAPE)
         {
            this.endEdit(DataGridEventReason.CANCELLED);
         }
         else if(param1.ctrlKey && param1.charCode == 46)
         {
            this.endEdit(DataGridEventReason.CANCELLED);
         }
         else if(param1.charCode == Keyboard.ENTER && param1.keyCode != 229)
         {
            if(!this._editedItemPosition)
            {
               return;
            }
            if(this.columns[this._editedItemPosition.columnIndex].editorUsesEnterKey)
            {
               return;
            }
            if(this.endEdit(DataGridEventReason.NEW_ROW) && !this.dontEdit)
            {
               this.findNextEnterItemRenderer(param1);
               if(focusManager)
               {
                  focusManager.defaultButtonEnabled = false;
               }
            }
         }
      }
      
      private function editorAncestorResizeHandler(param1:Event) : void
      {
         this.endEdit(DataGridEventReason.OTHER);
      }
      
      private function findNextEnterItemRenderer(param1:KeyboardEvent) : void
      {
         if(this._proposedEditedItemPosition !== undefined)
         {
            return;
         }
         this._editedItemPosition = this.lastEditedItemPosition;
         if(!this._editedItemPosition)
         {
            return;
         }
         var _loc2_:int = this._editedItemPosition.rowIndex;
         var _loc3_:int = this._editedItemPosition.columnIndex;
         var _loc4_:int;
         if((_loc4_ = this._editedItemPosition.rowIndex + (!!param1.shiftKey ? -1 : 1)) < collection.length && _loc4_ >= 0)
         {
            _loc2_ = _loc4_;
         }
         this.beginningEdit(_loc3_,_loc2_);
      }
      
      private function mouseFocusChangeHandler(param1:MouseEvent) : void
      {
         if(this.itemEditorInstance && !param1.isDefaultPrevented() && itemRendererContains(this.itemEditorInstance,DisplayObject(param1.target)))
         {
            param1.preventDefault();
         }
      }
      
      private function keyFocusChangeHandler(param1:FocusEvent) : void
      {
         if(param1.keyCode == Keyboard.TAB && !param1.isDefaultPrevented() && this.findNextItemRenderer(param1.shiftKey))
         {
            param1.preventDefault();
         }
      }
      
      private function itemEditorFocusOutHandler(param1:FocusEvent) : void
      {
         if(param1.relatedObject && contains(param1.relatedObject))
         {
            return;
         }
         if(!param1.relatedObject)
         {
            return;
         }
         if(this.itemEditorInstance)
         {
            this.endEdit(DataGridEventReason.OTHER);
         }
      }
      
      private function itemEditorItemEditBeginningHandler(param1:DataGridEvent) : void
      {
         if(!param1.isDefaultPrevented())
         {
            this.setEditedItemPosition({
               "columnIndex":param1.columnIndex,
               "rowIndex":param1.rowIndex
            });
         }
         else if(!this.itemEditorInstance)
         {
            this._editedItemPosition = null;
            this.editable = false;
            setFocus();
            this.editable = true;
         }
      }
      
      private function itemEditorItemEditBeginHandler(param1:DataGridEvent) : void
      {
         var _loc2_:IFocusManager = null;
         if(root)
         {
            systemManager.addEventListener(Event.DEACTIVATE,this.deactivateHandler,false,0,true);
         }
         if(!param1.isDefaultPrevented() && this.actualContentHolder.listItems[this.actualRowIndex][this.actualColIndex].data != null)
         {
            this.createItemEditor(param1.columnIndex,param1.rowIndex);
            if(this.editedItemRenderer is IDropInListItemRenderer && this.itemEditorInstance is IDropInListItemRenderer)
            {
               IDropInListItemRenderer(this.itemEditorInstance).listData = IDropInListItemRenderer(this.editedItemRenderer).listData;
            }
            if(!this.columns[param1.columnIndex].rendererIsEditor)
            {
               this.itemEditorInstance.data = this.editedItemRenderer.data;
            }
            if(this.itemEditorInstance is IInvalidating)
            {
               IInvalidating(this.itemEditorInstance).validateNow();
            }
            if(this.itemEditorInstance is IIMESupport)
            {
               IIMESupport(this.itemEditorInstance).imeMode = this.columns[param1.columnIndex].imeMode == null ? this._imeMode : this.columns[param1.columnIndex].imeMode;
            }
            _loc2_ = focusManager;
            if(this.itemEditorInstance is IFocusManagerComponent)
            {
               _loc2_.setFocus(IFocusManagerComponent(this.itemEditorInstance));
            }
            param1 = new DataGridEvent(DataGridEvent.ITEM_FOCUS_IN);
            param1.columnIndex = this._editedItemPosition.columnIndex;
            param1.rowIndex = this._editedItemPosition.rowIndex;
            param1.itemRenderer = this.itemEditorInstance;
            dispatchEvent(param1);
         }
      }
      
      private function itemEditorItemEditEndHandler(param1:DataGridEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:XML = null;
         var _loc8_:DataGridListData = null;
         var _loc9_:IFocusManager = null;
         if(!param1.isDefaultPrevented())
         {
            _loc2_ = false;
            if(param1.reason == DataGridEventReason.NEW_COLUMN)
            {
               if(!this.collectionUpdatesDisabled)
               {
                  collection.disableAutoUpdate();
                  this.collectionUpdatesDisabled = true;
               }
            }
            else if(this.collectionUpdatesDisabled)
            {
               collection.enableAutoUpdate();
               this.collectionUpdatesDisabled = false;
            }
            if(this.itemEditorInstance && param1.reason != DataGridEventReason.CANCELLED)
            {
               _loc3_ = this.itemEditorInstance[this._columns[param1.columnIndex].editorDataField];
               _loc4_ = this._columns[param1.columnIndex].dataField;
               _loc5_ = param1.itemRenderer.data;
               _loc6_ = "";
               for each(_loc7_ in describeType(_loc5_).variable)
               {
                  if(_loc4_ == _loc7_.@name.toString())
                  {
                     _loc6_ = _loc7_.@type.toString();
                     break;
                  }
               }
               if(_loc6_ == "String")
               {
                  if(!(_loc3_ is String))
                  {
                     _loc3_ = _loc3_.toString();
                  }
               }
               else if(_loc6_ == "uint")
               {
                  if(!(_loc3_ is uint))
                  {
                     _loc3_ = uint(_loc3_);
                  }
               }
               else if(_loc6_ == "int")
               {
                  if(!(_loc3_ is int))
                  {
                     _loc3_ = int(_loc3_);
                  }
               }
               else if(_loc6_ == "Number")
               {
                  if(!(_loc3_ is int))
                  {
                     _loc3_ = Number(_loc3_);
                  }
               }
               if(_loc4_ != null && this.getCurrentDataValue(_loc5_,_loc4_) !== _loc3_)
               {
                  _loc2_ = this.setNewValue(_loc5_,_loc4_,_loc3_,param1.columnIndex);
               }
               if(_loc2_ && !(_loc5_ is IPropertyChangeNotifier || _loc5_ is XML))
               {
                  collection.itemUpdated(_loc5_,_loc4_);
               }
               if(param1.itemRenderer is IDropInListItemRenderer)
               {
                  (_loc8_ = DataGridListData(IDropInListItemRenderer(param1.itemRenderer).listData)).label = this._columns[param1.columnIndex].itemToLabel(_loc5_);
                  IDropInListItemRenderer(param1.itemRenderer).listData = _loc8_;
               }
               param1.itemRenderer.data = _loc5_;
            }
         }
         else if(param1.reason != DataGridEventReason.OTHER)
         {
            if(this.itemEditorInstance && this._editedItemPosition)
            {
               if(selectedIndex != this._editedItemPosition.rowIndex)
               {
                  selectedIndex = this._editedItemPosition.rowIndex;
               }
               _loc9_ = focusManager;
               if(this.itemEditorInstance is IFocusManagerComponent)
               {
                  _loc9_.setFocus(IFocusManagerComponent(this.itemEditorInstance));
               }
            }
         }
         if(param1.reason == DataGridEventReason.OTHER || !param1.isDefaultPrevented())
         {
            this.destroyItemEditor();
         }
      }
      
      private function deferFocus() : void
      {
         this.losingFocus = true;
         setFocus();
         this.losingFocus = false;
      }
      
      protected function isComplexColumn(param1:String) : Boolean
      {
         return param1.indexOf(".") != -1;
      }
      
      protected function deriveComplexFieldReference(param1:Object, param2:Array) : Object
      {
         var _loc4_:int = 0;
         var _loc3_:Object = param1;
         if(param2)
         {
            _loc4_ = 0;
            while(_loc4_ < param2.length)
            {
               _loc3_ = _loc3_[param2[_loc4_]];
               _loc4_++;
            }
         }
         return _loc3_;
      }
      
      protected function getCurrentDataValue(param1:Object, param2:String) : String
      {
         if(!this.isComplexColumn(param2))
         {
            return param1[param2];
         }
         var _loc3_:Array = param2.split(".");
         var _loc4_:Object = this.deriveComplexFieldReference(param1,_loc3_);
         return String(_loc4_);
      }
      
      protected function setNewValue(param1:Object, param2:String, param3:Object, param4:int) : Boolean
      {
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         if(!this.isComplexColumn(param2))
         {
            param1[param2] = param3;
         }
         else
         {
            _loc6_ = (_loc5_ = param2.split(".")).pop();
            (_loc7_ = this.deriveComplexFieldReference(param1,_loc5_))[_loc6_] = param3;
         }
         return true;
      }
      
      private function headerReleaseHandler(param1:DataGridEvent) : void
      {
         if(!param1.isDefaultPrevented())
         {
            this.manualSort = true;
            this.sortByColumn(param1.columnIndex);
            this.manualSort = false;
         }
      }
      
      override protected function mouseWheelHandler(param1:MouseEvent) : void
      {
         if(this.itemEditorInstance)
         {
            this.endEdit(DataGridEventReason.OTHER);
         }
         super.mouseWheelHandler(param1);
      }
      
      override protected function dragStartHandler(param1:DragEvent) : void
      {
         if(this.collectionUpdatesDisabled)
         {
            collection.enableAutoUpdate();
            this.collectionUpdatesDisabled = false;
         }
         super.dragStartHandler(param1);
      }
      
      mx_internal function get vScrollBar() : ScrollBar
      {
         return verticalScrollBar;
      }
      
      override mx_internal function get rendererArray() : Array
      {
         var _loc1_:Array = listItems.slice();
         var _loc2_:Array = DataGridHeader(header).rendererArray;
         _loc1_.unshift(_loc2_);
         return _loc1_;
      }
      
      mx_internal function get sortArrow() : IFlexDisplayObject
      {
         return DataGridHeader(header).sortArrow;
      }
      
      override protected function adjustListContent(param1:Number = -1, param2:Number = -1) : void
      {
         var ww:Number = NaN;
         var lcx:Number = NaN;
         var lcy:Number = NaN;
         var hcx:Number = NaN;
         var pt:Point = null;
         var unscaledWidth:Number = param1;
         var unscaledHeight:Number = param2;
         var hh:Number = 0;
         if(mx_internal::headerVisible)
         {
            if(lockedColumnCount > 0)
            {
               lockedColumnHeader.visible = true;
               hcx = viewMetrics.left + Math.min(DataGridHeader(lockedColumnHeader).leftOffset,0);
               lockedColumnHeader.move(hcx,viewMetrics.top);
               hh = lockedColumnHeader.getExplicitOrMeasuredHeight();
               lockedColumnHeader.setActualSize(this.lockedColumnWidth + 1,hh);
               DataGridHeader(lockedColumnHeader).needRightSeparator = true;
               DataGridHeader(lockedColumnHeader).needRightSeparatorEvents = true;
            }
            header.visible = true;
            hcx = viewMetrics.left + this.lockedColumnWidth + Math.min(DataGridHeader(header).leftOffset,0);
            header.move(hcx,viewMetrics.top);
            if(verticalScrollBar != null && verticalScrollBar.visible && (horizontalScrollBar == null || !horizontalScrollBar.visible) && mx_internal::headerVisible && roomForScrollBar(verticalScrollBar,unscaledWidth,unscaledHeight - header.height))
            {
               ww = Math.max(0,DataGridHeader(header).rightOffset) - hcx - borderMetrics.right;
            }
            else
            {
               ww = Math.max(0,DataGridHeader(header).rightOffset) - hcx - viewMetrics.right;
            }
            hh = header.getExplicitOrMeasuredHeight();
            header.setActualSize(unscaledWidth + ww,hh);
            if(!this.skipHeaderUpdate)
            {
               header.headerItemsChanged = true;
               header.invalidateDisplayList();
            }
         }
         else
         {
            header.visible = false;
            if(lockedColumnCount > 0)
            {
               lockedColumnHeader.visible = false;
            }
         }
         if(lockedRowCount > 0 && lockedRowContent && lockedRowContent.iterator)
         {
            try
            {
               lockedRowContent.iterator.seek(CursorBookmark.FIRST);
               pt = makeRows(lockedRowContent,0,0,unscaledWidth,unscaledHeight,0,0,true,lockedRowCount,true);
               if(lockedColumnCount > 0)
               {
                  lcx = viewMetrics.left + Math.min(lockedColumnAndRowContent.leftOffset,0);
                  lcy = viewMetrics.top + Math.min(lockedColumnAndRowContent.topOffset,0) + Math.ceil(hh);
                  lockedColumnAndRowContent.move(lcx,lcy);
                  lockedColumnAndRowContent.setActualSize(this.lockedColumnWidth,lockedColumnAndRowContent.getExplicitOrMeasuredHeight());
               }
               lcx = viewMetrics.left + this.lockedColumnWidth + Math.min(lockedRowContent.leftOffset,0);
               lcy = viewMetrics.top + Math.min(lockedRowContent.topOffset,0) + Math.ceil(hh);
               lockedRowContent.move(lcx,lcy);
               ww = Math.max(0,lockedRowContent.rightOffset) - lcx - viewMetrics.right;
               lockedRowContent.setActualSize(unscaledWidth + ww,lockedRowContent.getExplicitOrMeasuredHeight());
               hh += lockedRowContent.getExplicitOrMeasuredHeight();
            }
            catch(e:ItemPendingError)
            {
               e.addResponder(new ItemResponder(lockedRowSeekPendingResultHandler,seekPendingFailureHandler,null));
            }
         }
         if(lockedColumnCount > 0)
         {
            lcx = viewMetrics.left + Math.min(lockedColumnContent.leftOffset,0);
            lcy = viewMetrics.top + Math.min(lockedColumnContent.topOffset,0) + Math.ceil(hh);
            lockedColumnContent.move(lcx,lcy);
            ww = this.lockedColumnWidth + lockedColumnContent.rightOffset - lockedColumnContent.leftOffset;
            lockedColumnContent.setActualSize(ww,unscaledHeight + Math.max(0,lockedColumnContent.bottomOffset) - lcy - viewMetrics.bottom);
         }
         lcx = viewMetrics.left + this.lockedColumnWidth + Math.min(listContent.leftOffset,0);
         lcy = viewMetrics.top + Math.min(listContent.topOffset,0) + Math.ceil(hh);
         listContent.move(lcx,lcy);
         ww = Math.max(0,listContent.rightOffset) - lcx - viewMetrics.right;
         hh = Math.max(0,listContent.bottomOffset) - lcy - viewMetrics.bottom;
         listContent.setActualSize(Math.max(0,unscaledWidth + ww),Math.max(0,unscaledHeight + hh));
      }
      
      private function lockedRowSeekPendingResultHandler(param1:Object, param2:ListBaseSeekPending) : void
      {
         var data:Object = param1;
         var info:ListBaseSeekPending = param2;
         try
         {
            lockedRowContent.iterator.seek(CursorBookmark.FIRST);
         }
         catch(e:ItemPendingError)
         {
            e.addResponder(new ItemResponder(lockedRowSeekPendingResultHandler,seekPendingFailureHandler,null));
         }
         itemsSizeChanged = true;
         this.invalidateDisplayList();
      }
      
      override protected function scrollPositionToIndex(param1:int, param2:int) : int
      {
         return !!iterator ? int(param2 + lockedRowCount) : -1;
      }
      
      override protected function scrollVertically(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:Sprite = null;
         super.scrollVertically(param1,param2,param3);
         if(getStyle("horizontalGridLines"))
         {
            this.drawLinesAndColumnGraphics(listContent,mx_internal::visibleColumns,{});
            if(lockedColumnCount)
            {
               this.drawLinesAndColumnGraphics(lockedColumnContent,mx_internal::visibleLockedColumns,{"right":1});
            }
         }
         else
         {
            if(_loc4_ = Sprite(listContent.getChildByName("lines")))
            {
               listContent.setChildIndex(_loc4_,listContent.numChildren - 1);
            }
            if(lockedColumnCount)
            {
               if(_loc4_ = Sprite(lockedColumnContent.getChildByName("lines")))
               {
                  lockedColumnContent.setChildIndex(_loc4_,lockedColumnContent.numChildren - 1);
               }
            }
         }
      }
      
      override public function set focusPane(param1:Sprite) : void
      {
         super.focusPane = param1;
         if(!param1 && this._focusPane)
         {
            this._focusPane.mask = null;
         }
         this._focusPane = param1;
      }
      
      override public function showDropFeedback(param1:DragEvent) : void
      {
         var _loc2_:Class = null;
         super.showDropFeedback(param1);
         if(lockedColumnCount > 0)
         {
            if(!this.lockedColumnDropIndicator)
            {
               _loc2_ = getStyle("dropIndicatorSkin");
               if(!_loc2_)
               {
                  _loc2_ = ListDropIndicator;
               }
               this.lockedColumnDropIndicator = IFlexDisplayObject(new _loc2_());
               this.lockedColumnDropIndicator.x = 2;
               this.lockedColumnDropIndicator.setActualSize(lockedColumnContent.width - 2,4);
               this.lockedColumnDropIndicator.visible = true;
            }
            if(mx_internal::dropIndicator.parent == listContent)
            {
               lockedColumnContent.addChild(DisplayObject(this.lockedColumnDropIndicator));
            }
            else
            {
               lockedColumnAndRowContent.addChild(DisplayObject(this.lockedColumnDropIndicator));
            }
            this.lockedColumnDropIndicator.y = mx_internal::dropIndicator.y;
         }
      }
      
      override public function hideDropFeedback(param1:DragEvent) : void
      {
         super.hideDropFeedback(param1);
         if(this.lockedColumnDropIndicator)
         {
            DisplayObject(this.lockedColumnDropIndicator).parent.removeChild(DisplayObject(this.lockedColumnDropIndicator));
            this.lockedColumnDropIndicator = null;
         }
      }
      
      override public function regenerateStyleCache(param1:Boolean) : void
      {
         super.regenerateStyleCache(param1);
         fontContextChanged = true;
         invalidateProperties();
      }
   }
}
