package mx.controls.dataGridClasses
{
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import flash.utils.setInterval;
   import mx.collections.CursorBookmark;
   import mx.collections.IViewCursor;
   import mx.collections.ItemResponder;
   import mx.collections.errors.ItemPendingError;
   import mx.controls.listClasses.BaseListData;
   import mx.controls.listClasses.IDropInListItemRenderer;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.controls.listClasses.ListBase;
   import mx.controls.listClasses.ListBaseContentHolder;
   import mx.controls.listClasses.ListBaseSeekPending;
   import mx.controls.listClasses.ListRowInfo;
   import mx.core.EdgeMetrics;
   import mx.core.IFactory;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IFontContextComponent;
   import mx.core.IInvalidating;
   import mx.core.ILayoutDirectionElement;
   import mx.core.IUIComponent;
   import mx.core.IUITextField;
   import mx.core.SpriteAsset;
   import mx.core.UIComponentGlobals;
   import mx.core.mx_internal;
   import mx.events.DragEvent;
   import mx.events.ListEvent;
   import mx.events.ScrollEvent;
   import mx.events.ScrollEventDetail;
   import mx.events.ScrollEventDirection;
   import mx.events.TweenEvent;
   import mx.skins.halo.ListDropIndicator;
   
   use namespace mx_internal;
   
   public class DataGridBase extends ListBase implements IFontContextComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      protected var columnMap:Object;
      
      protected var freeItemRenderersTable:Dictionary;
      
      mx_internal var visibleColumns:Array;
      
      mx_internal var visibleLockedColumns:Array;
      
      protected var header:DataGridHeaderBase;
      
      mx_internal var headerClass:Class;
      
      protected var headerMask:Shape;
      
      protected var lockedColumnHeader:DataGridHeaderBase;
      
      private var lockedColumnHeaderMask:Shape;
      
      protected var lockedRowContent:DataGridLockedRowContentHolder;
      
      private var lockedRowMask:Shape;
      
      protected var lockedColumnAndRowContent:DataGridLockedRowContentHolder;
      
      private var lockedColumnAndRowMask:Shape;
      
      protected var lockedColumnContent:ListBaseContentHolder;
      
      private var lockedColumnMask:Shape;
      
      mx_internal var columnsInvalid:Boolean = true;
      
      mx_internal var fontContextChanged:Boolean = true;
      
      private var bShiftKey:Boolean = false;
      
      private var bCtrlKey:Boolean = false;
      
      private var lastKey:uint = 0;
      
      private var bSelectItem:Boolean = false;
      
      private var inSelectItem:Boolean = false;
      
      mx_internal var _headerHeight:Number = 22;
      
      mx_internal var _explicitHeaderHeight:Boolean;
      
      private var lockedColumnCountChanged:Boolean = false;
      
      mx_internal var _lockedColumnCount:int = 0;
      
      private var lockedRowCountChanged:Boolean = false;
      
      mx_internal var _lockedRowCount:int = 0;
      
      private var _showHeaders:Boolean = true;
      
      protected var columnHighlightIndicator:Sprite;
      
      protected var columnCaretIndicator:Sprite;
      
      private var indicatorDictionary:Dictionary;
      
      public function DataGridBase()
      {
         this.headerClass = DataGridHeader;
         this.indicatorDictionary = new Dictionary(true);
         super();
         listType = "vertical";
         defaultRowCount = 7;
         this.columnMap = {};
         this.freeItemRenderersTable = new Dictionary(false);
      }
      
      mx_internal function get dataGridHeader() : DataGridHeaderBase
      {
         return this.header;
      }
      
      mx_internal function get dataGridLockedColumnHeader() : DataGridHeaderBase
      {
         return this.lockedColumnHeader;
      }
      
      mx_internal function get dataGridLockedColumnAndRows() : ListBaseContentHolder
      {
         return this.lockedColumnAndRowContent;
      }
      
      mx_internal function get dataGridLockedRows() : ListBaseContentHolder
      {
         return this.lockedRowContent;
      }
      
      mx_internal function get dataGridLockedColumns() : ListBaseContentHolder
      {
         return this.lockedColumnContent;
      }
      
      mx_internal function columnRendererChanged(param1:DataGridColumn) : void
      {
      }
      
      mx_internal function resizeColumn(param1:int, param2:Number) : void
      {
      }
      
      public function get columns() : Array
      {
         return null;
      }
      
      public function set columns(param1:Array) : void
      {
      }
      
      public function get fontContext() : IFlexModuleFactory
      {
         return moduleFactory;
      }
      
      public function set fontContext(param1:IFlexModuleFactory) : void
      {
         this.moduleFactory = param1;
      }
      
      [Bindable("resize")]
      public function get headerHeight() : Number
      {
         return this._headerHeight;
      }
      
      public function set headerHeight(param1:Number) : void
      {
         this._headerHeight = param1;
         this._explicitHeaderHeight = true;
         itemsSizeChanged = true;
         invalidateDisplayList();
      }
      
      public function get lockedColumnCount() : int
      {
         return this._lockedColumnCount;
      }
      
      public function set lockedColumnCount(param1:int) : void
      {
         this._lockedColumnCount = param1;
         this.lockedColumnCountChanged = true;
         itemsSizeChanged = true;
         this.columnsInvalid = true;
         invalidateDisplayList();
      }
      
      public function get lockedRowCount() : int
      {
         return this._lockedRowCount;
      }
      
      public function set lockedRowCount(param1:int) : void
      {
         this._lockedRowCount = param1;
         this.lockedRowCountChanged = true;
         itemsSizeChanged = true;
         invalidateDisplayList();
      }
      
      [Bindable("showHeadersChanged")]
      public function get showHeaders() : Boolean
      {
         return this._showHeaders;
      }
      
      public function set showHeaders(param1:Boolean) : void
      {
         if(param1 == this._showHeaders)
         {
            return;
         }
         this._showHeaders = param1;
         itemsSizeChanged = true;
         invalidateDisplayList();
         dispatchEvent(new Event("showHeadersChanged"));
      }
      
      mx_internal function get headerVisible() : Boolean
      {
         return this.showHeaders && this.headerHeight > 0;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.header)
         {
            this.header.visibleColumns = this.visibleColumns;
            this.header.headerItemsChanged = true;
            this.header.invalidateSize();
            this.header.validateNow();
         }
         if(this.lockedColumnCountChanged)
         {
            this.lockedColumnCountChanged = false;
            if(this.lockedColumnCount > 0)
            {
               if(!this.lockedColumnContent)
               {
                  this.lockedColumnHeader = new this.headerClass();
                  this.lockedColumnHeader.styleName = this;
                  addChild(this.lockedColumnHeader);
                  this.lockedColumnAndRowContent = new DataGridLockedRowContentHolder(this);
                  this.lockedColumnAndRowContent.styleName = this;
                  addChild(this.lockedColumnAndRowContent);
                  this.lockedColumnContent = new ListBaseContentHolder(this);
                  this.lockedColumnContent.styleName = this;
                  addChild(this.lockedColumnContent);
               }
               this.lockedColumnHeader.visible = true;
               this.lockedColumnAndRowContent.visible = this.lockedRowCount > 0;
               this.lockedColumnContent.visible = true;
            }
            else if(this.lockedColumnContent)
            {
               this.lockedColumnHeader.visible = false;
               this.lockedColumnAndRowContent.visible = false;
               this.lockedColumnContent.visible = false;
            }
         }
         if(this.lockedRowCountChanged && iterator)
         {
            this.lockedRowCountChanged = false;
            if(this.lockedRowCount > 0)
            {
               if(!this.lockedRowContent)
               {
                  this.lockedRowContent = new DataGridLockedRowContentHolder(this);
                  this.lockedRowContent.styleName = this;
                  addChild(this.lockedRowContent);
               }
               this.lockedRowContent.visible = true;
            }
            else if(this.lockedRowContent)
            {
               this.lockedRowContent.visible = false;
            }
            if(this.lockedColumnAndRowContent)
            {
               this.lockedColumnAndRowContent.visible = this.lockedRowCount > 0 && this.lockedColumnCount > 0;
            }
            seekPositionSafely(this.lockedRowCount + verticalScrollPosition);
         }
         if(this.lockedRowContent && this.lockedColumnAndRowContent)
         {
            _loc4_ = getChildIndex(this.lockedColumnAndRowContent);
            _loc3_ = getChildIndex(this.lockedRowContent);
            if(_loc4_ < _loc3_)
            {
               setChildIndex(this.lockedRowContent,_loc4_);
            }
         }
         if(this.lockedColumnContent && this.lockedColumnAndRowContent)
         {
            _loc4_ = getChildIndex(this.lockedColumnAndRowContent);
            _loc3_ = getChildIndex(this.lockedColumnContent);
            if(_loc4_ < _loc3_)
            {
               setChildIndex(this.lockedColumnContent,_loc4_);
            }
         }
         if(this.headerVisible && this.lockedColumnHeader)
         {
            this.lockedColumnHeader.visibleColumns = this.visibleLockedColumns;
            this.lockedColumnHeader.headerItemsChanged = true;
            this.lockedColumnHeader.invalidateSize();
            this.lockedColumnHeader.validateNow();
         }
         super.updateDisplayList(param1,param2);
      }
      
      override protected function makeRowsAndColumns(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:int, param7:Boolean = false, param8:uint = 0) : Point
      {
         return this.makeRows(listContent,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      protected function makeRows(param1:ListBaseContentHolder, param2:Number, param3:Number, param4:Number, param5:Number, param6:int, param7:int, param8:Boolean = false, param9:uint = 0, param10:Boolean = false) : Point
      {
         var xx:Number = NaN;
         var yy:Number = NaN;
         var hh:Number = NaN;
         var i:int = 0;
         var j:int = 0;
         var n:int = 0;
         var item:IListItemRenderer = null;
         var data:Object = null;
         var uid:String = null;
         var contentHolder:ListBaseContentHolder = param1;
         var left:Number = param2;
         var top:Number = param3;
         var right:Number = param4;
         var bottom:Number = param5;
         var firstCol:int = param6;
         var firstRow:int = param7;
         var byCount:Boolean = param8;
         var rowsNeeded:uint = param9;
         var alwaysCleanup:Boolean = param10;
         var bSelected:Boolean = false;
         var bHighlight:Boolean = false;
         var bCaret:Boolean = false;
         var colNum:int = 0;
         var rowNum:int = 0;
         var rowsMade:int = 0;
         var listItems:Array = contentHolder.listItems;
         var iterator:IViewCursor = contentHolder.iterator;
         var visibleData:Object = contentHolder.visibleData;
         var rowInfo:Object = contentHolder.rowInfo;
         if((!this.visibleColumns || this.visibleColumns.length == 0) && this.lockedColumnCount == 0)
         {
            while(listItems.length)
            {
               rowNum = listItems.length - 1;
               while(listItems[rowNum].length)
               {
                  item = listItems[rowNum].pop();
                  this.addToFreeItemRenderers(item);
               }
               listItems.pop();
            }
            contentHolder.visibleData = {};
            return new Point(0,0);
         }
         invalidateSizeFlag = true;
         var more:Boolean = true;
         var valid:Boolean = true;
         yy = top;
         rowNum = firstRow;
         more = iterator != null && !iterator.afterLast && iteratorValid;
         while(!byCount && yy < bottom || byCount && rowsNeeded > 0)
         {
            if(byCount)
            {
               rowsNeeded--;
            }
            valid = more;
            data = !!more ? iterator.current : null;
            if(iterator && more)
            {
               try
               {
                  more = iterator.moveNext();
               }
               catch(e:ItemPendingError)
               {
                  more = false;
                  iteratorValid = false;
               }
            }
            hh = 0;
            uid = null;
            this.prepareRowArray(contentHolder,rowNum);
            if(valid)
            {
               uid = itemToUID(data);
               hh = this.makeRow(contentHolder,rowNum,left,right,yy,data,uid);
            }
            else
            {
               hh = rowNum > 1 ? Number(rowInfo[rowNum - 1].height) : Number(rowHeight);
            }
            if(valid && variableRowHeight)
            {
               hh = Math.ceil(this.calculateRowHeight(data,hh,true));
            }
            if(valid)
            {
               this.adjustRow(contentHolder,rowNum,yy,hh);
            }
            else
            {
               this.clearRow(contentHolder,rowNum);
            }
            bSelected = isItemSelectable(data) && isItemSelected(uid);
            bHighlight = highlightUID == uid;
            bCaret = caretUID == uid;
            this.setRowInfo(contentHolder,rowNum,yy,hh,uid);
            if(valid)
            {
               this.drawVisibleItem(uid,bSelected,bHighlight,bCaret);
            }
            if(hh == 0)
            {
               hh = rowHeight;
            }
            yy += hh;
            rowNum++;
            rowsMade++;
         }
         if(!byCount || alwaysCleanup)
         {
            while(rowNum < listItems.length)
            {
               this.removeExtraRow(contentHolder);
            }
         }
         invalidateSizeFlag = false;
         return new Point(colNum,rowsMade);
      }
      
      protected function prepareRowArray(param1:ListBaseContentHolder, param2:int) : void
      {
         var _loc4_:ListBaseContentHolder = null;
         var _loc3_:Array = param1.listItems;
         if(this.lockedColumnCount > 0)
         {
            if(param1 == this.lockedRowContent)
            {
               _loc4_ = this.lockedColumnAndRowContent;
            }
            else
            {
               _loc4_ = this.lockedColumnContent;
            }
         }
         else
         {
            _loc4_ = null;
         }
         if(!_loc3_[param2])
         {
            _loc3_[param2] = [];
         }
         if(_loc4_)
         {
            if(!_loc4_.listItems[param2])
            {
               _loc4_.listItems[param2] = [];
            }
         }
      }
      
      protected function makeRow(param1:ListBaseContentHolder, param2:int, param3:Number, param4:Number, param5:Number, param6:Object, param7:String) : Number
      {
         var _loc9_:ListBaseContentHolder = null;
         var _loc10_:IListItemRenderer = null;
         var _loc11_:IListItemRenderer = null;
         var _loc12_:DataGridColumn = null;
         var _loc13_:Point = null;
         var _loc8_:Array = param1.listItems;
         if(this.lockedColumnCount > 0)
         {
            if(param1 == this.lockedRowContent)
            {
               _loc9_ = this.lockedColumnAndRowContent;
            }
            else
            {
               _loc9_ = this.lockedColumnContent;
            }
         }
         else
         {
            _loc9_ = null;
         }
         var _loc14_:int = 0;
         var _loc15_:Number = param3;
         var _loc16_:Number = 0;
         while(_loc14_ < this.visibleLockedColumns.length)
         {
            _loc12_ = this.visibleLockedColumns[_loc14_];
            _loc10_ = this.setupColumnItemRenderer(_loc12_,_loc9_,param2,_loc14_,param6,param7);
            _loc13_ = this.layoutColumnItemRenderer(_loc12_,_loc10_,_loc15_,param5);
            _loc15_ += _loc13_.x;
            _loc14_++;
            _loc16_ = Math.ceil(Math.max(_loc16_,!!variableRowHeight ? Number(_loc13_.y + mx_internal::cachedPaddingTop + mx_internal::cachedPaddingBottom) : Number(rowHeight)));
         }
         if(this.visibleLockedColumns.length)
         {
            while(_loc9_.listItems[param2].length > _loc14_)
            {
               _loc11_ = _loc9_.listItems[param2].pop();
               this.addToFreeItemRenderers(_loc11_);
            }
         }
         _loc14_ = 0;
         _loc15_ = param3;
         while(_loc15_ < param4 && _loc14_ < this.visibleColumns.length)
         {
            _loc12_ = this.visibleColumns[_loc14_];
            _loc10_ = this.setupColumnItemRenderer(_loc12_,param1,param2,_loc14_,param6,param7);
            _loc13_ = this.layoutColumnItemRenderer(_loc12_,_loc10_,_loc15_,param5);
            _loc15_ += _loc13_.x;
            _loc14_++;
            _loc16_ = Math.ceil(Math.max(_loc16_,!!variableRowHeight ? Number(_loc13_.y + mx_internal::cachedPaddingTop + mx_internal::cachedPaddingBottom) : Number(rowHeight)));
         }
         while(_loc8_[param2].length > _loc14_)
         {
            _loc11_ = _loc8_[param2].pop();
            this.addToFreeItemRenderers(_loc11_);
         }
         return _loc16_;
      }
      
      protected function clearRow(param1:ListBaseContentHolder, param2:int) : void
      {
         var _loc4_:ListBaseContentHolder = null;
         var _loc5_:IListItemRenderer = null;
         var _loc3_:Array = param1.listItems;
         if(this.lockedColumnCount > 0)
         {
            if(param1 == this.lockedRowContent)
            {
               _loc4_ = this.lockedColumnAndRowContent;
            }
            else
            {
               _loc4_ = this.lockedColumnContent;
            }
         }
         else
         {
            _loc4_ = null;
         }
         while(_loc3_[param2].length)
         {
            _loc5_ = _loc3_[param2].pop();
            this.addToFreeItemRenderers(_loc5_);
         }
         if(_loc4_)
         {
            while(_loc4_.listItems[param2].length)
            {
               _loc5_ = _loc4_.listItems[param2].pop();
               this.addToFreeItemRenderers(_loc5_);
            }
         }
      }
      
      protected function adjustRow(param1:ListBaseContentHolder, param2:int, param3:Number, param4:Number) : void
      {
         var _loc6_:ListBaseContentHolder = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:IListItemRenderer = null;
         var _loc5_:Array = param1.listItems;
         if(this.lockedColumnCount > 0)
         {
            if(param1 == this.lockedRowContent)
            {
               _loc6_ = this.lockedColumnAndRowContent;
            }
            else
            {
               _loc6_ = this.lockedColumnContent;
            }
         }
         else
         {
            _loc6_ = null;
         }
         if(_loc5_[param2])
         {
            if(_loc6_)
            {
               _loc9_ = _loc6_.listItems[param2].length;
               _loc8_ = 0;
               while(_loc8_ < _loc9_)
               {
                  _loc6_.listItems[param2][_loc8_].setActualSize(_loc6_.listItems[param2][_loc8_].width,param4 - mx_internal::cachedPaddingTop - mx_internal::cachedPaddingBottom);
                  _loc8_++;
               }
            }
            _loc9_ = _loc5_[param2].length;
            _loc8_ = 0;
            while(_loc8_ < _loc9_)
            {
               _loc5_[param2][_loc8_].setActualSize(_loc5_[param2][_loc8_].width,param4 - mx_internal::cachedPaddingTop - mx_internal::cachedPaddingBottom);
               _loc8_++;
            }
         }
         if(mx_internal::cachedVerticalAlign != "top")
         {
            if(mx_internal::cachedVerticalAlign == "bottom")
            {
               _loc10_ = _loc5_[param2].length;
               _loc8_ = 0;
               while(_loc8_ < _loc10_)
               {
                  _loc11_ = _loc5_[param2][_loc8_];
                  _loc11_.move(_loc11_.x,param3 + param4 - mx_internal::cachedPaddingBottom - _loc11_.getExplicitOrMeasuredHeight());
                  _loc8_++;
               }
               if(_loc6_)
               {
                  _loc9_ = _loc6_.listItems[param2].length;
                  _loc8_ = 0;
                  while(_loc8_ < _loc9_)
                  {
                     _loc11_ = _loc6_.listItems[param2][_loc8_];
                     _loc11_.move(_loc11_.x,param3 + param4 - mx_internal::cachedPaddingBottom - _loc11_.getExplicitOrMeasuredHeight());
                     _loc8_++;
                  }
               }
            }
            else
            {
               _loc10_ = _loc5_[param2].length;
               _loc8_ = 0;
               while(_loc8_ < _loc10_)
               {
                  _loc11_ = _loc5_[param2][_loc8_];
                  _loc11_.move(_loc11_.x,param3 + mx_internal::cachedPaddingTop + (param4 - mx_internal::cachedPaddingBottom - mx_internal::cachedPaddingTop - _loc11_.getExplicitOrMeasuredHeight()) / 2);
                  _loc8_++;
               }
               if(_loc6_)
               {
                  _loc9_ = _loc6_.listItems[param2].length;
                  _loc8_ = 0;
                  while(_loc8_ < _loc9_)
                  {
                     _loc11_ = _loc6_.listItems[param2][_loc8_];
                     _loc11_.move(_loc11_.x,param3 + mx_internal::cachedPaddingTop + (param4 - mx_internal::cachedPaddingBottom - mx_internal::cachedPaddingTop - _loc11_.getExplicitOrMeasuredHeight()) / 2);
                     _loc8_++;
                  }
               }
            }
         }
      }
      
      protected function setRowInfo(param1:ListBaseContentHolder, param2:int, param3:Number, param4:Number, param5:String) : void
      {
         var _loc8_:ListBaseContentHolder = null;
         var _loc6_:Array = param1.listItems;
         var _loc7_:Object = param1.rowInfo;
         if(this.lockedColumnCount > 0)
         {
            if(param1 == this.lockedRowContent)
            {
               _loc8_ = this.lockedColumnAndRowContent;
            }
            else
            {
               _loc8_ = this.lockedColumnContent;
            }
         }
         else
         {
            _loc8_ = null;
         }
         _loc7_[param2] = new ListRowInfo(param3,param4,param5);
         if(_loc8_)
         {
            _loc8_.rowInfo[param2] = _loc7_[param2];
         }
      }
      
      protected function removeExtraRow(param1:ListBaseContentHolder) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc5_:ListBaseContentHolder = null;
         var _loc3_:Array = param1.listItems;
         var _loc4_:Object = param1.rowInfo;
         if(param1 == this.lockedRowContent)
         {
            _loc5_ = this.lockedColumnAndRowContent;
         }
         else
         {
            _loc5_ = this.lockedColumnContent;
         }
         var _loc6_:Array = _loc3_.pop();
         _loc4_.pop();
         while(_loc6_.length)
         {
            _loc2_ = _loc6_.pop();
            this.addToFreeItemRenderers(_loc2_);
         }
         if(_loc5_)
         {
            _loc5_.rowInfo.pop();
            _loc6_ = _loc5_.listItems.pop();
            while(_loc6_ && _loc6_.length)
            {
               _loc2_ = _loc6_.pop();
               this.addToFreeItemRenderers(_loc2_);
            }
         }
      }
      
      protected function setupColumnItemRenderer(param1:DataGridColumn, param2:ListBaseContentHolder, param3:int, param4:int, param5:Object, param6:String) : IListItemRenderer
      {
         var _loc8_:IListItemRenderer = null;
         var _loc9_:DataGridListData = null;
         var _loc7_:Array;
         if(!(_loc8_ = (_loc7_ = param2.listItems)[param3][param4]) || itemToUID(_loc8_.data) != param6 || this.columnMap[_loc8_.name] != param1)
         {
            if((_loc8_ = this.createColumnItemRenderer(param1,false,param5)) == null)
            {
               return null;
            }
            if(_loc8_.parent != param2)
            {
               param2.addChild(DisplayObject(_loc8_));
            }
            this.columnMap[_loc8_.name] = param1;
            if(_loc7_[param3][param4])
            {
               this.addToFreeItemRenderers(_loc7_[param3][param4]);
            }
            _loc7_[param3][param4] = _loc8_;
         }
         _loc9_ = DataGridListData(this.makeListData(param5,param6,param3,param1.colNum,param1));
         rowMap[_loc8_.name] = _loc9_;
         if(_loc8_ is IDropInListItemRenderer)
         {
            IDropInListItemRenderer(_loc8_).listData = !!param5 ? _loc9_ : null;
         }
         _loc8_.data = param5;
         _loc8_.visible = true;
         if(param6 && param4 == 0)
         {
            param2.visibleData[param6] = _loc8_;
         }
         return _loc8_;
      }
      
      protected function layoutColumnItemRenderer(param1:DataGridColumn, param2:IListItemRenderer, param3:Number, param4:Number) : Point
      {
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         if(param2)
         {
            param2.explicitWidth = _loc5_ = this.getWidthOfItem(param2,param1);
            UIComponentGlobals.layoutManager.validateClient(param2,true);
            _loc6_ = param2.getExplicitOrMeasuredHeight();
            param2.setActualSize(_loc5_,!!variableRowHeight ? Number(param2.getExplicitOrMeasuredHeight()) : Number(rowHeight - mx_internal::cachedPaddingTop - mx_internal::cachedPaddingBottom));
            param2.move(param3,param4 + mx_internal::cachedPaddingTop);
         }
         return new Point(_loc5_,_loc6_);
      }
      
      protected function drawVisibleItem(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false) : void
      {
         if(visibleData[param1])
         {
            this.drawItem(visibleData[param1],param2,param3,param4,param5);
         }
         if(this.lockedRowCount && this.lockedRowContent && this.lockedRowContent.visibleData[param1])
         {
            this.drawItem(this.lockedRowContent.visibleData[param1],param2,param3,param4,param5);
         }
      }
      
      override protected function drawItem(param1:IListItemRenderer, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false) : void
      {
         var _loc7_:int = 0;
         var _loc8_:IListItemRenderer = null;
         var _loc9_:ListBaseContentHolder = null;
         if(!param1)
         {
            return;
         }
         super.drawItem(param1,param2,param3,param4,param5);
         var _loc6_:int = rowMap[param1.name].rowIndex;
         _loc7_ = 0;
         while(_loc7_ < this.visibleColumns.length)
         {
            _loc8_ = (param1.parent as ListBaseContentHolder).listItems[_loc6_][_loc7_];
            this.updateRendererDisplayList(_loc8_);
            _loc7_++;
         }
         if(this.lockedColumnCount)
         {
            if(param1.parent == listContent || param1.parent == this.lockedColumnContent)
            {
               _loc9_ = this.lockedColumnContent;
            }
            else
            {
               _loc9_ = this.lockedColumnAndRowContent;
            }
            _loc7_ = 0;
            while(_loc7_ < this.visibleLockedColumns.length)
            {
               _loc8_ = _loc9_.listItems[_loc6_][_loc7_];
               this.updateRendererDisplayList(_loc8_);
               _loc7_++;
            }
         }
      }
      
      protected function updateRendererDisplayList(param1:IListItemRenderer) : void
      {
         var _loc2_:IInvalidating = null;
         if(param1 is IInvalidating)
         {
            _loc2_ = IInvalidating(param1);
            _loc2_.invalidateDisplayList();
            _loc2_.validateNow();
         }
      }
      
      override protected function addToFreeItemRenderers(param1:IListItemRenderer) : void
      {
         var _loc5_:DataGridColumn = null;
         DisplayObject(param1).visible = false;
         delete rowMap[param1.name];
         var _loc2_:IFactory = factoryMap[param1];
         var _loc3_:String = itemToUID(param1.data);
         var _loc4_:Object;
         if((_loc4_ = ListBaseContentHolder(param1.parent).visibleData)[_loc3_] == param1)
         {
            delete _loc4_[_loc3_];
         }
         if(this.columnMap[param1.name])
         {
            _loc5_ = this.columnMap[param1.name];
            if(_loc2_ == _loc5_.itemRenderer)
            {
               if(this.freeItemRenderersTable[_loc5_] == undefined)
               {
                  this.freeItemRenderersTable[_loc5_] = [];
               }
               this.freeItemRenderersTable[_loc5_].push(param1);
            }
            if(!_loc5_.freeItemRenderersByFactory)
            {
               _loc5_.freeItemRenderersByFactory = new Dictionary(true);
            }
            if(_loc5_.freeItemRenderersByFactory[_loc2_] == undefined)
            {
               _loc5_.freeItemRenderersByFactory[_loc2_] = new Dictionary(true);
            }
            _loc5_.freeItemRenderersByFactory[_loc2_][param1] = 1;
            delete this.columnMap[param1.name];
         }
      }
      
      override protected function purgeItemRenderers() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Array = null;
         var _loc3_:IListItemRenderer = null;
         if(this.lockedRowContent)
         {
            _loc1_ = this.lockedRowContent.listItems;
            while(_loc1_.length)
            {
               _loc2_ = _loc1_.pop();
               while(_loc2_.length)
               {
                  _loc3_ = IListItemRenderer(_loc2_.pop());
                  if(_loc3_)
                  {
                     this.lockedRowContent.removeChild(DisplayObject(_loc3_));
                     delete this.lockedRowContent.visibleData[itemToUID(_loc3_.data)];
                  }
               }
            }
         }
         if(this.lockedColumnContent)
         {
            _loc1_ = this.lockedColumnContent.listItems;
            while(_loc1_.length)
            {
               _loc2_ = _loc1_.pop();
               while(_loc2_.length)
               {
                  _loc3_ = IListItemRenderer(_loc2_.pop());
                  if(_loc3_)
                  {
                     this.lockedColumnContent.removeChild(DisplayObject(_loc3_));
                     delete this.lockedColumnContent.visibleData[itemToUID(_loc3_.data)];
                  }
               }
            }
         }
         if(this.lockedColumnAndRowContent)
         {
            _loc1_ = this.lockedColumnAndRowContent.listItems;
            while(_loc1_.length)
            {
               _loc2_ = _loc1_.pop();
               while(_loc2_.length)
               {
                  _loc3_ = IListItemRenderer(_loc2_.pop());
                  if(_loc3_)
                  {
                     this.lockedColumnAndRowContent.removeChild(DisplayObject(_loc3_));
                     delete this.lockedColumnAndRowContent.visibleData[itemToUID(_loc3_.data)];
                  }
               }
            }
         }
         super.purgeItemRenderers();
      }
      
      override public function indicesToIndex(param1:int, param2:int) : int
      {
         if(this.inSelectItem)
         {
            return 0;
         }
         return param1;
      }
      
      protected function makeListData(param1:Object, param2:String, param3:int, param4:int, param5:DataGridColumn) : BaseListData
      {
         if(param1 is DataGridColumn)
         {
            return new DataGridListData(param5.headerText != null ? param5.headerText : param5.dataField,param5.dataField,param4,param2,this,param3);
         }
         return new DataGridListData(param5.itemToLabel(param1),param5.dataField,param4,param2,this,param3);
      }
      
      mx_internal function getWidthOfItem(param1:IListItemRenderer, param2:DataGridColumn) : Number
      {
         return param2.width;
      }
      
      protected function calculateRowHeight(param1:Object, param2:Number, param3:Boolean = false) : Number
      {
         return NaN;
      }
      
      public function createColumnItemRenderer(param1:DataGridColumn, param2:Boolean, param3:Object) : IListItemRenderer
      {
         var _loc4_:IFactory = null;
         var _loc5_:IListItemRenderer = null;
         var _loc6_:Dictionary = null;
         var _loc7_:* = undefined;
         if(!(_loc4_ = param1.getItemRendererFactory(param2,param3)))
         {
            if(!param3)
            {
               _loc4_ = nullItemRenderer;
            }
            if(!_loc4_)
            {
               _loc4_ = itemRenderer;
            }
         }
         if(_loc4_ == param1.itemRenderer)
         {
            if(this.freeItemRenderersTable[param1] && this.freeItemRenderersTable[param1].length)
            {
               _loc5_ = this.freeItemRenderersTable[param1].pop();
               delete param1.freeItemRenderersByFactory[_loc4_][_loc5_];
            }
         }
         else if(param1.freeItemRenderersByFactory)
         {
            if(_loc6_ = param1.freeItemRenderersByFactory[_loc4_])
            {
               var _loc8_:int = 0;
               var _loc9_:* = _loc6_;
               for(_loc7_ in _loc9_)
               {
                  _loc5_ = IListItemRenderer(_loc7_);
                  delete _loc6_[_loc7_];
               }
            }
         }
         if(!_loc5_)
         {
            if(_loc5_ = _loc4_.newInstance())
            {
               _loc5_.styleName = param1;
               factoryMap[_loc5_] = _loc4_;
            }
         }
         if(_loc5_)
         {
            _loc5_.owner = this;
         }
         return _loc5_;
      }
      
      mx_internal function columnHeaderWordWrap(param1:DataGridColumn) : Boolean
      {
         if(param1.headerWordWrap == true)
         {
            return true;
         }
         if(param1.headerWordWrap == false)
         {
            return false;
         }
         return wordWrap;
      }
      
      mx_internal function columnWordWrap(param1:DataGridColumn) : Boolean
      {
         if(param1.wordWrap == true)
         {
            return true;
         }
         if(param1.wordWrap == false)
         {
            return false;
         }
         return wordWrap;
      }
      
      override protected function clearIndicators() : void
      {
         super.clearIndicators();
         if(this.lockedColumnCount && this.lockedColumnContent)
         {
            while(this.lockedColumnContent.selectionLayer.numChildren > 0)
            {
               this.lockedColumnContent.selectionLayer.removeChildAt(0);
            }
         }
         if(this.lockedRowCount && this.lockedRowContent)
         {
            while(this.lockedRowContent.selectionLayer.numChildren > 0)
            {
               this.lockedRowContent.selectionLayer.removeChildAt(0);
            }
            if(this.lockedColumnCount && this.lockedColumnAndRowContent)
            {
               while(this.lockedColumnAndRowContent.selectionLayer.numChildren > 0)
               {
                  this.lockedColumnAndRowContent.selectionLayer.removeChildAt(0);
               }
            }
         }
         if(this.header)
         {
            this.header.clearSelectionLayer();
         }
         if(this.lockedColumnHeader)
         {
            this.lockedColumnHeader.clearSelectionLayer();
         }
      }
      
      override protected function drawHighlightIndicator(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint, param7:IListItemRenderer) : void
      {
         var _loc8_:ListBaseContentHolder = null;
         var _loc9_:Sprite = null;
         super.drawHighlightIndicator(param1,param2,param3,unscaledWidth - viewMetrics.left - viewMetrics.right,param5,param6,param7);
         if(this.lockedColumnCount)
         {
            if(param7.parent == listContent)
            {
               _loc8_ = this.lockedColumnContent;
            }
            else
            {
               _loc8_ = this.lockedColumnAndRowContent;
            }
            _loc9_ = _loc8_.selectionLayer;
            if(!this.columnHighlightIndicator)
            {
               this.columnHighlightIndicator = new SpriteAsset();
               _loc8_.selectionLayer.addChild(DisplayObject(this.columnHighlightIndicator));
            }
            else if(this.columnHighlightIndicator.parent != _loc9_)
            {
               _loc9_.addChild(this.columnHighlightIndicator);
            }
            else
            {
               _loc9_.setChildIndex(DisplayObject(this.columnHighlightIndicator),_loc9_.numChildren - 1);
            }
            if(this.columnHighlightIndicator is ILayoutDirectionElement)
            {
               ILayoutDirectionElement(this.columnHighlightIndicator).layoutDirection = null;
            }
            super.drawHighlightIndicator(this.columnHighlightIndicator,param2,param3,_loc8_.width,param5,param6,param7);
         }
      }
      
      override protected function clearHighlightIndicator(param1:Sprite, param2:IListItemRenderer) : void
      {
         super.clearHighlightIndicator(param1,param2);
         if(this.lockedColumnCount)
         {
            if(this.columnHighlightIndicator)
            {
               Sprite(this.columnHighlightIndicator).graphics.clear();
            }
         }
      }
      
      override protected function drawCaretIndicator(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint, param7:IListItemRenderer) : void
      {
         var _loc8_:ListBaseContentHolder = null;
         var _loc9_:Sprite = null;
         super.drawCaretIndicator(param1,param2,param3,unscaledWidth - viewMetrics.left - viewMetrics.right,param5,param6,param7);
         if(this.lockedColumnCount)
         {
            if(param7.parent == listContent)
            {
               _loc8_ = this.lockedColumnContent;
            }
            else
            {
               _loc8_ = this.lockedColumnAndRowContent;
            }
            _loc9_ = _loc8_.selectionLayer;
            if(!this.columnCaretIndicator)
            {
               this.columnCaretIndicator = new SpriteAsset();
               _loc8_.selectionLayer.addChild(DisplayObject(this.columnCaretIndicator));
            }
            else if(this.columnCaretIndicator.parent != _loc9_)
            {
               _loc9_.addChild(this.columnCaretIndicator);
            }
            else
            {
               _loc9_.setChildIndex(DisplayObject(this.columnCaretIndicator),_loc9_.numChildren - 1);
            }
            if(this.columnCaretIndicator is ILayoutDirectionElement)
            {
               ILayoutDirectionElement(this.columnCaretIndicator).layoutDirection = null;
            }
            super.drawCaretIndicator(this.columnCaretIndicator,param2,param3,_loc8_.width,param5,param6,param7);
         }
      }
      
      override protected function clearCaretIndicator(param1:Sprite, param2:IListItemRenderer) : void
      {
         super.clearCaretIndicator(param1,param2);
         if(this.lockedColumnCount)
         {
            if(this.columnCaretIndicator)
            {
               Sprite(this.columnCaretIndicator).graphics.clear();
            }
         }
      }
      
      override protected function drawSelectionIndicator(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint, param7:IListItemRenderer) : void
      {
         var _loc8_:ListBaseContentHolder = null;
         var _loc9_:Sprite = null;
         var _loc10_:Sprite = null;
         super.drawSelectionIndicator(param1,param2,param3,unscaledWidth - viewMetrics.left - viewMetrics.right,param5,param6,param7);
         if(this.lockedColumnCount)
         {
            if(param7.parent == listContent)
            {
               _loc8_ = this.lockedColumnContent;
            }
            else
            {
               _loc8_ = this.lockedColumnAndRowContent;
            }
            _loc9_ = _loc8_.selectionLayer;
            if(!(_loc10_ = this.indicatorDictionary[param1] as Sprite))
            {
               (_loc10_ = new SpriteAsset()).mouseEnabled = false;
               _loc9_.addChild(DisplayObject(_loc10_));
               param1.parent.addEventListener(Event.REMOVED,this.selectionRemovedListener);
               this.indicatorDictionary[param1] = _loc10_;
            }
            if(_loc10_ is ILayoutDirectionElement)
            {
               ILayoutDirectionElement(_loc10_).layoutDirection = null;
            }
            super.drawSelectionIndicator(_loc10_,param2,param3,_loc8_.width,param5,param6,param7);
         }
      }
      
      private function selectionRemovedListener(param1:Event) : void
      {
         if(!this.lockedColumnCount)
         {
            return;
         }
         var _loc2_:Sprite = this.indicatorDictionary[param1.target] as Sprite;
         if(_loc2_)
         {
            _loc2_.parent.removeChild(_loc2_);
         }
      }
      
      override mx_internal function mouseEventToItemRendererOrEditor(param1:MouseEvent) : IListItemRenderer
      {
         var _loc4_:ListBaseContentHolder = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:Point = null;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc2_:Boolean = false;
         var _loc3_:DisplayObject = DisplayObject(param1.target);
         var _loc5_:Array = this.visibleColumns;
         if(param1.target == listContent)
         {
            _loc4_ = listContent;
         }
         else if(param1.target == this.lockedColumnContent)
         {
            _loc4_ = this.lockedColumnContent;
            _loc5_ = this.visibleLockedColumns;
         }
         else if(param1.target == this.lockedRowContent)
         {
            _loc4_ = this.lockedRowContent;
         }
         else if(param1.target == this.lockedColumnAndRowContent)
         {
            _loc4_ = this.lockedColumnAndRowContent;
            _loc5_ = this.visibleLockedColumns;
         }
         else if(param1.target == highlightIndicator)
         {
            _loc4_ = highlightIndicator.parent.parent as ListBaseContentHolder;
            _loc5_ = this.visibleColumns;
            if(_loc4_ == this.lockedColumnContent || _loc4_ == this.lockedColumnAndRowContent)
            {
               _loc5_ = this.visibleLockedColumns;
            }
            _loc2_ = true;
         }
         else if(param1.target == this.columnHighlightIndicator)
         {
            _loc4_ = this.columnHighlightIndicator.parent.parent as ListBaseContentHolder;
            _loc5_ = this.visibleColumns;
            if(_loc4_ == this.lockedColumnContent || _loc4_ == this.lockedColumnAndRowContent)
            {
               _loc5_ = this.visibleLockedColumns;
            }
            _loc2_ = true;
         }
         if(_loc2_ || _loc3_ == _loc4_)
         {
            _loc6_ = _loc4_.listItems;
            _loc7_ = _loc4_.rowInfo;
            _loc8_ = new Point(param1.stageX,param1.stageY);
            _loc8_ = _loc4_.globalToLocal(_loc8_);
            _loc9_ = 0;
            _loc10_ = _loc6_.length;
            _loc11_ = 0;
            while(_loc11_ < _loc10_)
            {
               if(_loc6_[_loc11_].length)
               {
                  if(_loc8_.y < _loc9_ + _loc7_[_loc11_].height)
                  {
                     _loc12_ = 0;
                     _loc13_ = _loc5_.length;
                     _loc14_ = 0;
                     while(_loc14_ < _loc13_)
                     {
                        if(_loc8_.x < _loc12_ + _loc5_[_loc14_].width)
                        {
                           return _loc6_[_loc11_][_loc14_];
                        }
                        _loc12_ += _loc5_[_loc14_].width;
                        _loc14_++;
                     }
                  }
               }
               _loc9_ += _loc7_[_loc11_].height;
               _loc11_++;
            }
         }
         while(_loc3_ && _loc3_ != this)
         {
            if(_loc3_ is IListItemRenderer && _loc3_.parent && _loc3_.parent.parent == this && _loc3_.parent is ListBaseContentHolder)
            {
               if(_loc3_.visible)
               {
                  return IListItemRenderer(_loc3_);
               }
               break;
            }
            if(_loc3_ is IUIComponent)
            {
               _loc3_ = IUIComponent(_loc3_).owner;
            }
            else
            {
               _loc3_ = _loc3_.parent;
            }
         }
         return null;
      }
      
      mx_internal function getAllVisibleColumns() : Array
      {
         var _loc1_:Array = [];
         if(this.lockedColumnCount)
         {
            _loc1_ = _loc1_.concat(this.visibleLockedColumns);
         }
         return _loc1_.concat(this.visibleColumns);
      }
      
      override protected function UIDToItemRenderer(param1:String) : IListItemRenderer
      {
         var _loc2_:IListItemRenderer = visibleData[param1];
         if(!_loc2_)
         {
            if(this.lockedRowContent)
            {
               _loc2_ = this.lockedRowContent.visibleData[param1];
            }
         }
         if(!_loc2_)
         {
            if(this.lockedColumnContent)
            {
               _loc2_ = this.lockedColumnContent.visibleData[param1];
            }
         }
         if(!_loc2_)
         {
            if(this.lockedColumnAndRowContent)
            {
               _loc2_ = this.lockedColumnAndRowContent.visibleData[param1];
            }
         }
         return _loc2_;
      }
      
      override mx_internal function addClipMask(param1:Boolean) : void
      {
         var _loc2_:Graphics = null;
         var _loc11_:DisplayObject = null;
         var _loc12_:Number = NaN;
         if(param1)
         {
            if(horizontalScrollBar && horizontalScrollBar.visible || hasOnlyTextRenderers() || listContent.bottomOffset != 0 || listContent.topOffset != 0 || listContent.leftOffset != 0 || listContent.rightOffset != 0)
            {
               listContent.mask = maskShape;
               selectionLayer.mask = null;
               if(!this.headerMask)
               {
                  this.headerMask = new Shape();
                  addChild(this.headerMask);
                  _loc2_ = this.headerMask.graphics;
                  _loc2_.beginFill(16777215);
                  _loc2_.drawRect(0,0,10,10);
                  _loc2_.endFill();
                  this.headerMask.visible = false;
               }
               this.header.mask = this.headerMask;
               this.header.selectionLayer.mask = null;
               this.headerMask.width = maskShape.width;
               this.headerMask.height = maskShape.height;
               this.headerMask.x = maskShape.x;
               this.headerMask.y = maskShape.y;
               if(verticalScrollBar != null && verticalScrollBar.visible && (horizontalScrollBar == null || !horizontalScrollBar.visible) && this.headerVisible)
               {
                  this.headerMask.width += verticalScrollBar.getExplicitOrMeasuredWidth();
               }
               if(this.lockedRowContent)
               {
                  if(!this.lockedRowMask)
                  {
                     this.lockedRowMask = new Shape();
                     addChild(this.lockedRowMask);
                     _loc2_ = this.lockedRowMask.graphics;
                     _loc2_.beginFill(16777215);
                     _loc2_.drawRect(0,0,10,10);
                     _loc2_.endFill();
                     this.lockedRowMask.visible = false;
                  }
                  this.lockedRowContent.mask = this.lockedRowMask;
                  this.lockedRowContent.selectionLayer.mask = null;
                  this.lockedRowMask.width = maskShape.width;
                  this.lockedRowMask.height = maskShape.height;
                  this.lockedRowMask.x = maskShape.x;
                  this.lockedRowMask.y = maskShape.y;
               }
               if(this.lockedColumnContent)
               {
                  if(!this.lockedColumnMask)
                  {
                     this.lockedColumnMask = new Shape();
                     addChild(this.lockedColumnMask);
                     _loc2_ = this.lockedColumnMask.graphics;
                     _loc2_.beginFill(16777215);
                     _loc2_.drawRect(0,0,10,10);
                     _loc2_.endFill();
                     this.lockedColumnMask.visible = false;
                  }
                  this.lockedColumnContent.mask = this.lockedColumnMask;
                  this.lockedColumnContent.selectionLayer.mask = null;
                  this.lockedColumnMask.width = maskShape.width;
                  this.lockedColumnMask.height = maskShape.height;
                  this.lockedColumnMask.x = maskShape.x;
                  this.lockedColumnMask.y = maskShape.y;
               }
               if(this.lockedColumnAndRowContent)
               {
                  if(!this.lockedColumnAndRowMask)
                  {
                     this.lockedColumnAndRowMask = new Shape();
                     addChild(this.lockedColumnAndRowMask);
                     _loc2_ = this.lockedColumnAndRowMask.graphics;
                     _loc2_.beginFill(16777215);
                     _loc2_.drawRect(0,0,10,10);
                     _loc2_.endFill();
                     this.lockedColumnAndRowMask.visible = false;
                  }
                  this.lockedColumnAndRowContent.mask = this.lockedColumnAndRowMask;
                  this.lockedColumnAndRowContent.selectionLayer.mask = null;
                  this.lockedColumnAndRowMask.width = maskShape.width;
                  this.lockedColumnAndRowMask.height = maskShape.height;
                  this.lockedColumnAndRowMask.x = maskShape.x;
                  this.lockedColumnAndRowMask.y = maskShape.y;
               }
               if(this.lockedColumnHeader)
               {
                  if(!this.lockedColumnHeaderMask)
                  {
                     this.lockedColumnHeaderMask = new Shape();
                     addChild(this.lockedColumnHeaderMask);
                     _loc2_ = this.lockedColumnHeaderMask.graphics;
                     _loc2_.beginFill(16777215);
                     _loc2_.drawRect(0,0,10,10);
                     _loc2_.endFill();
                     this.lockedColumnHeaderMask.visible = false;
                  }
                  this.lockedColumnHeader.mask = this.lockedColumnHeaderMask;
                  this.lockedColumnHeader.selectionLayer.mask = null;
                  this.lockedColumnHeaderMask.width = maskShape.width;
                  this.lockedColumnHeaderMask.height = maskShape.height;
                  this.lockedColumnHeaderMask.x = maskShape.x;
                  this.lockedColumnHeaderMask.y = maskShape.y;
               }
            }
            else
            {
               listContent.mask = null;
               selectionLayer.mask = maskShape;
               if(!this.headerMask)
               {
                  this.headerMask = new Shape();
                  addChild(this.headerMask);
                  _loc2_ = this.headerMask.graphics;
                  _loc2_.beginFill(16777215);
                  _loc2_.drawRect(0,0,10,10);
                  _loc2_.endFill();
                  this.headerMask.visible = false;
               }
               this.header.mask = null;
               this.header.selectionLayer.mask = this.headerMask;
               this.headerMask.width = maskShape.width;
               this.headerMask.height = maskShape.height;
               this.headerMask.x = maskShape.x;
               this.headerMask.y = maskShape.y;
               if(verticalScrollBar != null && verticalScrollBar.visible && (horizontalScrollBar == null || !horizontalScrollBar.visible) && this.headerVisible)
               {
                  this.headerMask.width += verticalScrollBar.getExplicitOrMeasuredWidth();
               }
               if(this.lockedRowContent)
               {
                  if(!this.lockedRowMask)
                  {
                     this.lockedRowMask = new Shape();
                     addChild(this.lockedRowMask);
                     _loc2_ = this.lockedRowMask.graphics;
                     _loc2_.beginFill(16777215);
                     _loc2_.drawRect(0,0,10,10);
                     _loc2_.endFill();
                     this.lockedRowMask.visible = false;
                  }
                  this.lockedRowContent.mask = null;
                  this.lockedRowContent.selectionLayer.mask = this.lockedRowMask;
                  this.lockedRowMask.width = maskShape.width;
                  this.lockedRowMask.height = maskShape.height;
                  this.lockedRowMask.x = maskShape.x;
                  this.lockedRowMask.y = maskShape.y;
               }
               if(this.lockedColumnContent)
               {
                  if(!this.lockedColumnMask)
                  {
                     this.lockedColumnMask = new Shape();
                     addChild(this.lockedColumnMask);
                     _loc2_ = this.lockedColumnMask.graphics;
                     _loc2_.beginFill(16777215);
                     _loc2_.drawRect(0,0,10,10);
                     _loc2_.endFill();
                     this.lockedColumnMask.visible = false;
                  }
                  this.lockedColumnContent.mask = null;
                  this.lockedColumnContent.selectionLayer.mask = this.lockedColumnMask;
                  this.lockedColumnMask.width = maskShape.width;
                  this.lockedColumnMask.height = maskShape.height;
                  this.lockedColumnMask.x = maskShape.x;
                  this.lockedColumnMask.y = maskShape.y;
               }
               if(this.lockedColumnAndRowContent)
               {
                  if(!this.lockedColumnAndRowMask)
                  {
                     this.lockedColumnAndRowMask = new Shape();
                     addChild(this.lockedColumnAndRowMask);
                     _loc2_ = this.lockedColumnAndRowMask.graphics;
                     _loc2_.beginFill(16777215);
                     _loc2_.drawRect(0,0,10,10);
                     _loc2_.endFill();
                     this.lockedColumnAndRowMask.visible = false;
                  }
                  this.lockedColumnAndRowContent.mask = null;
                  this.lockedColumnAndRowContent.selectionLayer.mask = this.lockedColumnAndRowMask;
                  this.lockedColumnAndRowMask.width = maskShape.width;
                  this.lockedColumnAndRowMask.height = maskShape.height;
                  this.lockedColumnAndRowMask.x = maskShape.x;
                  this.lockedColumnAndRowMask.y = maskShape.y;
               }
               if(this.lockedColumnHeader)
               {
                  if(!this.lockedColumnHeaderMask)
                  {
                     this.lockedColumnHeaderMask = new Shape();
                     addChild(this.lockedColumnHeaderMask);
                     _loc2_ = this.lockedColumnHeaderMask.graphics;
                     _loc2_.beginFill(16777215);
                     _loc2_.drawRect(0,0,10,10);
                     _loc2_.endFill();
                     this.lockedColumnHeaderMask.visible = false;
                  }
                  this.lockedColumnHeader.mask = null;
                  this.lockedColumnHeader.selectionLayer.mask = this.lockedColumnHeaderMask;
                  this.lockedColumnHeaderMask.width = maskShape.width;
                  this.lockedColumnHeaderMask.height = maskShape.height;
                  this.lockedColumnHeaderMask.x = maskShape.x;
                  this.lockedColumnHeaderMask.y = maskShape.y;
               }
            }
         }
         if(listContent.mask)
         {
            return;
         }
         var _loc3_:int = listItems.length - 1;
         var _loc4_:ListRowInfo = rowInfo[_loc3_];
         var _loc5_:Array = listItems[_loc3_];
         if(_loc4_.y + _loc4_.height <= listContent.height)
         {
            return;
         }
         var _loc6_:int = _loc5_.length;
         var _loc7_:Number = _loc4_.y;
         var _loc8_:Number = listContent.width;
         var _loc9_:Number = listContent.height - _loc4_.y;
         var _loc10_:int = 0;
         while(_loc10_ < _loc6_)
         {
            _loc12_ = (_loc11_ = _loc5_[_loc10_]).y - _loc7_;
            if(_loc11_ is IUITextField && !IUITextField(_loc11_).embedFonts)
            {
               _loc11_.height = Math.max(_loc9_ - _loc12_,0);
            }
            else
            {
               _loc11_.mask = createItemMask(0,_loc7_ + _loc12_,_loc8_,Math.max(_loc9_ - _loc12_,0));
            }
            _loc10_++;
         }
         if(this.lockedColumnContent)
         {
            _loc6_ = (_loc5_ = this.lockedColumnContent.listItems[_loc3_]).length;
            _loc8_ = this.lockedColumnContent.width;
            _loc10_ = 0;
            while(_loc10_ < _loc6_)
            {
               _loc12_ = (_loc11_ = _loc5_[_loc10_]).y - _loc7_;
               if(_loc11_ is IUITextField && !IUITextField(_loc11_).embedFonts)
               {
                  _loc11_.height = Math.max(_loc9_ - _loc12_,0);
               }
               else
               {
                  _loc11_.mask = createItemMask(0,_loc7_ + _loc12_,_loc8_,Math.max(_loc9_ - _loc12_,0),this.lockedColumnContent);
               }
               _loc10_++;
            }
         }
      }
      
      override mx_internal function removeClipMask() : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:DisplayObject = null;
         super.removeClipMask();
         if(!this.lockedColumnContent)
         {
            return;
         }
         var _loc1_:int = listItems.length - 1;
         if(_loc1_ < 0)
         {
            return;
         }
         var _loc2_:Number = rowInfo[_loc1_].height;
         var _loc3_:ListRowInfo = rowInfo[_loc1_];
         var _loc4_:Array;
         if(_loc4_ = this.lockedColumnContent.listItems[_loc1_])
         {
            _loc5_ = _loc4_.length;
            _loc6_ = 0;
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
                  mx_internal::itemMaskFreeList.push(_loc7_.mask);
                  _loc7_.mask = null;
               }
               _loc6_++;
            }
         }
      }
      
      mx_internal function get gridColumnMap() : Object
      {
         return this.columnMap;
      }
      
      override public function itemRendererToIndex(param1:IListItemRenderer) : int
      {
         var _loc2_:int = 0;
         if(param1.name in rowMap)
         {
            _loc2_ = rowMap[param1.name].rowIndex;
            if(param1.parent is DataGridLockedRowContentHolder)
            {
               return _loc2_;
            }
            return _loc2_ + this.lockedRowCount + verticalScrollPosition - offscreenExtraRowsTop;
         }
         return int.MIN_VALUE;
      }
      
      override mx_internal function selectionTween_updateHandler(param1:TweenEvent) : void
      {
         var _loc2_:Sprite = null;
         super.selectionTween_updateHandler(param1);
         if(this.lockedColumnCount)
         {
            _loc2_ = Sprite(param1.target.listener);
            _loc2_ = this.indicatorDictionary[_loc2_] as Sprite;
            _loc2_.alpha = Number(param1.value);
         }
      }
      
      override protected function destroyRow(param1:int, param2:int) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc6_:IListItemRenderer = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         super.destroyRow(param1,param2);
         if(this.lockedColumnCount)
         {
            _loc3_ = this.lockedColumnContent.listItems;
            param2 = _loc3_[param1].length;
            _loc4_ = this.lockedColumnContent.rowInfo;
            _loc5_ = this.lockedColumnContent.visibleData;
            _loc7_ = _loc4_[param1].uid;
            removeIndicators(_loc7_);
            _loc8_ = 0;
            while(_loc8_ < param2)
            {
               if((_loc6_ = _loc3_[param1][_loc8_]).data)
               {
                  delete _loc5_[_loc7_];
               }
               this.addToFreeItemRenderers(_loc6_);
               _loc8_++;
            }
         }
      }
      
      override protected function moveRowVertically(param1:int, param2:int, param3:Number) : void
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:IListItemRenderer = null;
         var _loc7_:int = 0;
         super.moveRowVertically(param1,param2,param3);
         if(this.lockedColumnCount)
         {
            param2 = (_loc4_ = this.lockedColumnContent.listItems)[param1].length;
            _loc5_ = this.lockedColumnContent.rowInfo;
            _loc7_ = 0;
            while(_loc7_ < param2)
            {
               _loc6_ = _loc4_[param1][_loc7_];
               _loc6_.move(_loc6_.x,_loc6_.y + param3);
               _loc7_++;
            }
         }
      }
      
      override protected function shiftRow(param1:int, param2:int, param3:int, param4:Boolean) : void
      {
         var _loc5_:Array = null;
         var _loc6_:IListItemRenderer = null;
         var _loc7_:int = 0;
         super.shiftRow(param1,param2,param3,param4);
         if(this.lockedColumnCount)
         {
            param3 = (_loc5_ = this.lockedColumnContent.listItems)[param1].length;
            _loc7_ = 0;
            while(_loc7_ < param3)
            {
               _loc6_ = _loc5_[param1][_loc7_];
               if(param4)
               {
                  _loc5_[param2][_loc7_] = _loc6_;
                  rowMap[_loc6_.name].rowIndex = param2;
               }
               else
               {
                  rowMap[_loc6_.name].rowIndex = param1;
               }
               _loc7_++;
            }
            if(param4)
            {
               this.lockedColumnContent.rowInfo[param2] = this.lockedColumnContent.rowInfo[param1];
            }
         }
      }
      
      override protected function moveIndicatorsVertically(param1:String, param2:Number) : void
      {
         super.moveIndicatorsVertically(param1,param2);
         if(this.lockedColumnCount)
         {
            if(param1)
            {
               if(selectionIndicators[param1])
               {
                  Sprite(this.indicatorDictionary[selectionIndicators[param1]]).y = Sprite(this.indicatorDictionary[selectionIndicators[param1]]).y + param2;
               }
               if(highlightUID == param1)
               {
                  this.columnHighlightIndicator.y += param2;
               }
               if(caretUID == param1)
               {
                  this.columnCaretIndicator.y += param2;
               }
            }
         }
      }
      
      override protected function truncateRowArrays(param1:int) : void
      {
         super.truncateRowArrays(param1);
         if(this.lockedColumnCount)
         {
            this.lockedColumnContent.listItems.splice(param1);
            this.lockedColumnContent.rowInfo.splice(param1);
         }
      }
      
      override protected function addToRowArrays() : void
      {
         super.addToRowArrays();
         if(this.lockedColumnCount)
         {
            this.lockedColumnContent.listItems.splice(0,0,null);
            this.lockedColumnContent.rowInfo.splice(0,0,null);
         }
      }
      
      override protected function restoreRowArrays(param1:int) : void
      {
         super.restoreRowArrays(param1);
         if(this.lockedColumnCount)
         {
            this.lockedColumnContent.listItems.splice(0,param1);
            this.lockedColumnContent.rowInfo.splice(0,param1);
         }
      }
      
      override protected function removeFromRowArrays(param1:int) : void
      {
         super.removeFromRowArrays(param1);
         if(this.lockedColumnCount)
         {
            this.lockedColumnContent.listItems.splice(param1,1);
            this.lockedColumnContent.rowInfo.splice(param1,1);
         }
      }
      
      override protected function clearVisibleData() : void
      {
         if(this.lockedColumnContent)
         {
            this.lockedColumnContent.visibleData = {};
         }
         if(this.lockedRowContent)
         {
            this.lockedRowContent.visibleData = {};
         }
         if(this.lockedColumnAndRowContent)
         {
            this.lockedColumnAndRowContent.visibleData = {};
         }
         super.clearVisibleData();
      }
      
      override protected function set allowItemSizeChangeNotification(param1:Boolean) : void
      {
         if(this.lockedColumnContent)
         {
            this.lockedColumnContent.allowItemSizeChangeNotification = param1;
         }
         if(this.lockedRowContent)
         {
            this.lockedRowContent.allowItemSizeChangeNotification = param1;
         }
         if(this.lockedColumnAndRowContent)
         {
            this.lockedColumnAndRowContent.allowItemSizeChangeNotification = param1;
         }
         super.allowItemSizeChangeNotification = param1;
      }
      
      override protected function indexToRow(param1:int) : int
      {
         if(param1 < this.lockedRowCount)
         {
            return -1;
         }
         return param1 - this.lockedRowCount;
      }
      
      override protected function moveSelectionVertically(param1:uint, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:IListItemRenderer = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc13_:ScrollEvent = null;
         var _loc8_:Boolean = false;
         showCaret = true;
         var _loc9_:int = listItems.length;
         var _loc10_:int = listItems.length - offscreenExtraRowsTop - offscreenExtraRowsBottom;
         var _loc11_:int = rowInfo[_loc9_ - offscreenExtraRowsBottom - 1].y + rowInfo[_loc9_ - offscreenExtraRowsBottom - 1].height > listContent.heightExcludingOffsets - listContent.topOffset ? 1 : 0;
         var _loc12_:Boolean = false;
         this.bSelectItem = false;
         switch(param1)
         {
            case Keyboard.UP:
               if(caretIndex > 0)
               {
                  --caretIndex;
                  this.bSelectItem = true;
                  if(caretIndex >= this.lockedRowCount)
                  {
                     _loc12_ = true;
                  }
               }
               break;
            case Keyboard.DOWN:
               if(caretIndex >= this.lockedRowCount - 1)
               {
                  if(caretIndex < collection.length - 1)
                  {
                     ++caretIndex;
                     _loc12_ = true;
                     this.bSelectItem = true;
                  }
                  else if(caretIndex == collection.length - 1 && _loc11_)
                  {
                     if(verticalScrollPosition < maxVerticalScrollPosition)
                     {
                        _loc4_ = verticalScrollPosition + 1;
                     }
                  }
               }
               else if(caretIndex < collection.length - 1)
               {
                  ++caretIndex;
                  this.bSelectItem = true;
               }
               break;
            case Keyboard.PAGE_UP:
               if(caretIndex > this.lockedRowCount)
               {
                  if(caretIndex > verticalScrollPosition + this.lockedRowCount && caretIndex < verticalScrollPosition + this.lockedRowCount + _loc10_)
                  {
                     caretIndex = verticalScrollPosition + this.lockedRowCount;
                  }
                  else
                  {
                     caretIndex = Math.max(caretIndex - Math.max(_loc10_ - _loc11_,1),this.lockedRowCount);
                     _loc4_ = Math.max(caretIndex,this.lockedRowCount) - this.lockedRowCount;
                  }
                  this.bSelectItem = true;
               }
               else
               {
                  caretIndex = 0;
                  this.bSelectItem = true;
               }
               break;
            case Keyboard.PAGE_DOWN:
               if(!(caretIndex >= verticalScrollPosition + this.lockedRowCount && caretIndex < verticalScrollPosition + this.lockedRowCount + _loc10_ - _loc11_ - 1))
               {
                  if(caretIndex - this.lockedRowCount == verticalScrollPosition && _loc10_ - _loc11_ <= 1)
                  {
                     ++caretIndex;
                  }
                  _loc4_ = Math.min(Math.max(caretIndex - this.lockedRowCount,0),maxVerticalScrollPosition);
               }
               this.bSelectItem = true;
               break;
            case Keyboard.HOME:
               if(caretIndex > 0)
               {
                  caretIndex = 0;
                  this.bSelectItem = true;
                  _loc4_ = 0;
               }
               break;
            case Keyboard.END:
               if(this.lockedRowCount >= collection.length)
               {
                  caretIndex = collection.length - 1;
                  this.bSelectItem = true;
               }
               else if(caretIndex < collection.length - 1)
               {
                  caretIndex = collection.length - 1;
                  this.bSelectItem = true;
                  _loc4_ = maxVerticalScrollPosition;
               }
               break;
            case Keyboard.SPACE:
               _loc12_ = true;
               this.bSelectItem = true;
         }
         if(_loc12_)
         {
            if(caretIndex >= verticalScrollPosition + this.lockedRowCount + _loc10_ - _loc11_)
            {
               if(_loc10_ - _loc11_ == 0)
               {
                  _loc4_ = Math.min(maxVerticalScrollPosition,Math.max(caretIndex - this.lockedRowCount,0));
               }
               else
               {
                  _loc4_ = Math.min(maxVerticalScrollPosition,caretIndex - this.lockedRowCount - _loc10_ + _loc11_ + 1);
               }
            }
            else if(caretIndex < verticalScrollPosition + this.lockedRowCount)
            {
               _loc4_ = Math.max(caretIndex - this.lockedRowCount,0);
            }
         }
         if(!isNaN(_loc4_))
         {
            if(verticalScrollPosition != _loc4_)
            {
               (_loc13_ = new ScrollEvent(ScrollEvent.SCROLL)).detail = ScrollEventDetail.THUMB_POSITION;
               _loc13_.direction = ScrollEventDirection.VERTICAL;
               _loc13_.delta = _loc4_ - verticalScrollPosition;
               _loc13_.position = _loc4_;
               verticalScrollPosition = _loc4_;
               dispatchEvent(_loc13_);
            }
            if(!iteratorValid)
            {
               keySelectionPending = true;
               return;
            }
         }
         this.bShiftKey = param2;
         this.bCtrlKey = param3;
         this.lastKey = param1;
         this.finishKeySelection();
      }
      
      override protected function finishKeySelection() : void
      {
         var _loc1_:String = null;
         var _loc5_:IListItemRenderer = null;
         var _loc7_:Point = null;
         var _loc8_:ListEvent = null;
         var _loc2_:int = listItems.length;
         var _loc3_:int = listItems.length - offscreenExtraRowsTop - offscreenExtraRowsBottom;
         var _loc4_:int = rowInfo[_loc2_ - offscreenExtraRowsBottom - 1].y + rowInfo[_loc2_ - offscreenExtraRowsBottom - 1].height > listContent.heightExcludingOffsets - listContent.topOffset ? 1 : 0;
         if(this.lastKey == Keyboard.PAGE_DOWN)
         {
            if(_loc3_ - _loc4_ == 0)
            {
               caretIndex = Math.min(verticalScrollPosition + this.lockedRowCount + _loc3_ - _loc4_,collection.length - 1);
            }
            else
            {
               caretIndex = Math.min(verticalScrollPosition + this.lockedRowCount + _loc3_ - _loc4_ - 1,collection.length - 1);
            }
         }
         var _loc6_:Boolean = false;
         if(this.bSelectItem && (caretIndex - verticalScrollPosition >= 0 || caretIndex < this.lockedRowCount))
         {
            if(caretIndex - this.lockedRowCount - verticalScrollPosition > Math.max(_loc3_ - _loc4_ - 1,0))
            {
               if(this.lastKey == Keyboard.END && maxVerticalScrollPosition > verticalScrollPosition)
               {
                  caretIndex = caretIndex - 1;
                  this.moveSelectionVertically(this.lastKey,this.bShiftKey,this.bCtrlKey);
                  return;
               }
               caretIndex = this.lockedRowCount + _loc3_ - _loc4_ - 1 + verticalScrollPosition;
            }
            if(caretIndex < this.lockedRowCount)
            {
               _loc5_ = this.lockedRowContent.listItems[caretIndex][0];
            }
            else
            {
               _loc5_ = listItems[caretIndex - this.lockedRowCount - verticalScrollPosition + offscreenExtraRowsTop][0];
            }
            if(_loc5_)
            {
               _loc1_ = itemToUID(_loc5_.data);
               _loc5_ = this.UIDToItemRenderer(_loc1_);
               if(!this.bCtrlKey || this.lastKey == Keyboard.SPACE)
               {
                  this.selectItem(_loc5_,this.bShiftKey,this.bCtrlKey);
                  _loc6_ = true;
               }
               if(this.bCtrlKey)
               {
                  this.drawItem(_loc5_,selectedData[_loc1_] != null,_loc1_ == highlightUID,true);
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
      
      override protected function itemRendererToIndices(param1:IListItemRenderer) : Point
      {
         if(!param1 || !(param1.name in rowMap))
         {
            return null;
         }
         var _loc2_:ListBaseContentHolder = param1.parent as ListBaseContentHolder;
         var _loc3_:Boolean = false;
         var _loc4_:int = rowMap[param1.name].rowIndex;
         var _loc5_:int = _loc2_.listItems[_loc4_].length;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            if(_loc2_.listItems[_loc4_][_loc6_] == param1)
            {
               _loc3_ = true;
               break;
            }
            _loc6_++;
         }
         if(!_loc3_)
         {
            return null;
         }
         if(this.lockedRowContent == _loc2_)
         {
            return new Point(_loc6_ + horizontalScrollPosition + this.lockedColumnCount,_loc4_ + offscreenExtraRowsTop);
         }
         if(this.lockedColumnAndRowContent == _loc2_)
         {
            return new Point(_loc6_,_loc4_ + offscreenExtraRowsTop);
         }
         if(this.lockedColumnContent == _loc2_)
         {
            return new Point(_loc6_,_loc4_ + verticalScrollPosition + this.lockedRowCount + offscreenExtraRowsTop);
         }
         return new Point(_loc6_ + horizontalScrollPosition + this.lockedColumnCount,_loc4_ + verticalScrollPosition + this.lockedRowCount + offscreenExtraRowsTop);
      }
      
      override protected function selectItem(param1:IListItemRenderer, param2:Boolean, param3:Boolean, param4:Boolean = true) : Boolean
      {
         var _loc5_:CursorBookmark = iterator.bookmark;
         if(this.lockedRowCount)
         {
            this.inSelectItem = true;
            iterator.seek(CursorBookmark.FIRST,0);
         }
         var _loc6_:Boolean = super.selectItem(param1,param2,param3,param4);
         if(this.lockedRowCount)
         {
            iterator.seek(_loc5_,0);
            this.inSelectItem = false;
         }
         return _loc6_;
      }
      
      override public function showDropFeedback(param1:DragEvent) : void
      {
         var _loc3_:Class = null;
         var _loc4_:EdgeMetrics = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(!mx_internal::dropIndicator)
         {
            _loc3_ = getStyle("dropIndicatorSkin");
            if(!_loc3_)
            {
               _loc3_ = ListDropIndicator;
            }
            dropIndicator = IFlexDisplayObject(new _loc3_());
            _loc4_ = viewMetrics;
            drawFocus(true);
            mx_internal::dropIndicator.x = 2;
            mx_internal::dropIndicator.setActualSize(listContent.width - 4,4);
            mx_internal::dropIndicator.visible = true;
            listContent.addChild(DisplayObject(mx_internal::dropIndicator));
            if(collection)
            {
               dragScrollingInterval = setInterval(dragScroll,15);
            }
         }
         var _loc2_:Number = calculateDropIndex(param1);
         if(this.lockedRowCount && _loc2_ < this.lockedRowCount)
         {
            if(mx_internal::dropIndicator.parent != this.lockedRowContent)
            {
               this.lockedRowContent.addChild(DisplayObject(mx_internal::dropIndicator));
            }
            mx_internal::dropIndicator.y = this.lockedRowContent.listItems[_loc2_][0].y - 1;
         }
         else
         {
            _loc6_ = (_loc5_ = int(listItems.length)) > 0 && rowInfo[_loc5_ - offscreenExtraRowsBottom - 1].y + rowInfo[_loc5_ - offscreenExtraRowsBottom - 1].height > listContent.heightExcludingOffsets - listContent.topOffset ? 1 : 0;
            _loc2_ -= verticalScrollPosition + this.lockedRowCount;
            if(_loc2_ >= _loc5_)
            {
               if(_loc6_)
               {
                  _loc2_ = _loc5_ - 1;
               }
               else
               {
                  _loc2_ = _loc5_;
               }
            }
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            if(mx_internal::dropIndicator.parent != listContent)
            {
               listContent.addChild(DisplayObject(mx_internal::dropIndicator));
            }
            mx_internal::dropIndicator.y = calculateDropIndicatorY(_loc5_,_loc2_ + offscreenExtraRowsTop);
         }
      }
      
      override protected function adjustAfterAdd(param1:Array, param2:int) : Boolean
      {
         var items:Array = param1;
         var location:int = param2;
         var retval:Boolean = super.adjustAfterAdd(items,location);
         if(this.lockedRowCount)
         {
            if(verticalScrollPosition > 0 && verticalScrollPosition >= location && location <= this.lockedRowCount)
            {
               if(verticalScrollPosition + this.lockedRowCount >= collection.length)
               {
                  super.verticalScrollPosition = verticalScrollPosition - items.length;
               }
            }
            if(collection.length - items.length <= this.lockedRowCount && collection.length >= this.lockedRowCount || location <= this.lockedRowCount || location == this.lockedRowCount + verticalScrollPosition)
            {
               try
               {
                  iterator.seek(CursorBookmark.FIRST,this.lockedRowCount + verticalScrollPosition);
                  if(!iteratorValid)
                  {
                     iteratorValid = true;
                     lastSeekPending = null;
                  }
               }
               catch(e:ItemPendingError)
               {
                  lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,lockedRowCount + verticalScrollPosition);
                  e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                  iteratorValid = false;
               }
            }
         }
         return retval;
      }
      
      override protected function adjustAfterRemove(param1:Array, param2:int, param3:Boolean) : Boolean
      {
         var firstUID:String = null;
         var i:int = 0;
         var uid:String = null;
         var items:Array = param1;
         var location:int = param2;
         var requiresValueCommit:Boolean = param3;
         var adjustIterator:Boolean = false;
         if(this.lockedRowCount && listItems.length && listItems[0].length)
         {
            if(location <= this.lockedRowCount + verticalScrollPosition)
            {
               adjustIterator = true;
            }
            else
            {
               firstUID = rowMap[listItems[0][0].name].uid;
               i = 0;
               while(i < items.length)
               {
                  uid = itemToUID(items[i]);
                  if(uid == firstUID && verticalScrollPosition == 0)
                  {
                     adjustIterator = true;
                     break;
                  }
                  i++;
               }
            }
         }
         var retval:Boolean = super.adjustAfterRemove(items,location,requiresValueCommit);
         if(this.lockedRowCount)
         {
            if(verticalScrollPosition > 0 && location > this.lockedRowCount && verticalScrollPosition <= this.lockedRowCount && verticalScrollPosition == maxVerticalScrollPosition)
            {
               super.verticalScrollPosition = verticalScrollPosition - items.length;
               adjustIterator = true;
            }
            if(adjustIterator)
            {
               try
               {
                  iterator.seek(CursorBookmark.FIRST,this.lockedRowCount + verticalScrollPosition);
                  if(!iteratorValid)
                  {
                     iteratorValid = true;
                     lastSeekPending = null;
                  }
               }
               catch(e:ItemPendingError)
               {
                  lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST,lockedRowCount + verticalScrollPosition);
                  e.addResponder(new ItemResponder(seekPendingResultHandler,seekPendingFailureHandler,lastSeekPending));
                  iteratorValid = false;
               }
            }
         }
         return retval;
      }
   }
}
