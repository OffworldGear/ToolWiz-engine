package mx.controls.dataGridClasses
{
   import flash.display.DisplayObject;
   import flash.display.GradientType;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import mx.controls.DataGrid;
   import mx.controls.listClasses.IDropInListItemRenderer;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.core.EdgeMetrics;
   import mx.core.FlexSprite;
   import mx.core.IFlexDisplayObject;
   import mx.core.IUIComponent;
   import mx.core.LayoutDirection;
   import mx.core.UIComponent;
   import mx.core.UIComponentGlobals;
   import mx.core.mx_internal;
   import mx.events.DataGridEvent;
   import mx.events.SandboxMouseEvent;
   import mx.managers.CursorManagerPriority;
   import mx.skins.halo.DataGridColumnDropIndicator;
   import mx.styles.ISimpleStyleClient;
   
   use namespace mx_internal;
   
   public class DataGridHeader extends DataGridHeaderBase
   {
       
      
      private var separatorAffordance:Number = 3;
      
      protected var dataGrid:DataGrid;
      
      protected var headerItems:Array;
      
      protected var cachedHeaderHeight:Number = 0;
      
      protected var cachedPaddingBottom:Number = 0;
      
      protected var cachedPaddingTop:Number = 0;
      
      public var needRightSeparator:Boolean = false;
      
      public var needRightSeparatorEvents:Boolean = false;
      
      private var resizeCursorID:int = 0;
      
      private var startX:Number;
      
      private var minX:Number;
      
      private var lastPt:Point;
      
      private var separators:Array;
      
      private var resizeGraphic:IFlexDisplayObject;
      
      private var lastItemDown:IListItemRenderer;
      
      private var dropColumnIndex:int = -1;
      
      mx_internal var columnDropIndicator:IFlexDisplayObject;
      
      mx_internal var sortArrow:IFlexDisplayObject;
      
      public var leftOffset:Number = 0;
      
      public var topOffset:Number = 0;
      
      public var rightOffset:Number = 0;
      
      public var bottomOffset:Number = 0;
      
      private var allowItemSizeChangeNotification:Boolean = true;
      
      private var headerBGSkinChanged:Boolean = false;
      
      private var headerSepSkinChanged:Boolean = false;
      
      public function DataGridHeader()
      {
         this.headerItems = [];
         super();
         addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
      }
      
      override mx_internal function clearSelectionLayer() : void
      {
         while(mx_internal::selectionLayer.numChildren > 0)
         {
            mx_internal::selectionLayer.removeChildAt(0);
         }
      }
      
      override protected function createChildren() : void
      {
         this.dataGrid = parent as DataGrid;
         selectionLayer = new UIComponent();
         addChild(mx_internal::selectionLayer);
      }
      
      override protected function measure() : void
      {
         super.measure();
         var _loc1_:Number = this.dataGrid.calculateHeaderHeight();
         this.cachedHeaderHeight = !!this.dataGrid._explicitHeaderHeight ? Number(this.dataGrid.headerHeight) : Number(_loc1_);
         this.cachedPaddingBottom = getStyle("paddingBottom");
         this.cachedPaddingTop = getStyle("paddingTop");
         measuredHeight = this.cachedHeaderHeight;
         var _loc2_:Number = 0;
         var _loc3_:int = !!mx_internal::visibleColumns ? int(mx_internal::visibleColumns.length) : 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ += mx_internal::visibleColumns[_loc4_].preferredWidth;
            _loc4_++;
         }
         measuredWidth = _loc2_;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:DataGridListData = null;
         var _loc12_:IListItemRenderer = null;
         var _loc13_:IListItemRenderer = null;
         var _loc14_:Object = null;
         var _loc15_:String = null;
         var _loc16_:DataGridColumn = null;
         var _loc17_:Number = NaN;
         var _loc18_:Array = null;
         var _loc19_:int = 0;
         var _loc20_:Class = null;
         var _loc21_:IFlexDisplayObject = null;
         this.allowItemSizeChangeNotification = false;
         var _loc3_:Array = mx_internal::visibleColumns;
         if(mx_internal::headerItemsChanged && (_loc3_ && _loc3_.length > 0 || this.dataGrid.headerVisible))
         {
            headerItemsChanged = false;
            _loc5_ = 0;
            _loc6_ = 0;
            _loc7_ = 0;
            _loc8_ = 0;
            _loc10_ = 0;
            _loc17_ = 0;
            _loc18_ = this.headerItems.slice();
            while(_loc3_ && _loc10_ < _loc3_.length)
            {
               if(!(_loc12_ = (_loc16_ = _loc3_[_loc10_]).cachedHeaderRenderer))
               {
                  (_loc12_ = this.dataGrid.createColumnItemRenderer(_loc16_,true,_loc16_)).styleName = _loc16_;
                  _loc16_.cachedHeaderRenderer = _loc12_;
               }
               _loc11_ = new DataGridListData(_loc16_.headerText != null ? _loc16_.headerText : _loc16_.dataField,_loc16_.dataField,_loc10_,_loc15_,this.dataGrid,0);
               if(_loc12_ is IDropInListItemRenderer)
               {
                  IDropInListItemRenderer(_loc12_).listData = _loc11_;
               }
               _loc12_.data = _loc16_;
               _loc12_.visible = true;
               if(_loc12_.parent != this)
               {
                  addChild(DisplayObject(_loc12_));
               }
               this.headerItems[_loc10_] = _loc12_;
               _loc12_.explicitWidth = _loc8_ = _loc16_.width;
               UIComponentGlobals.layoutManager.validateClient(_loc12_,true);
               _loc9_ = _loc12_.getExplicitOrMeasuredHeight();
               _loc12_.setActualSize(_loc8_,!!this.dataGrid._explicitHeaderHeight ? Number(this.cachedHeaderHeight - this.cachedPaddingTop - this.cachedPaddingBottom) : Number(_loc9_));
               _loc12_.move(_loc5_,_loc6_ + this.cachedPaddingTop);
               _loc5_ += _loc8_;
               _loc10_++;
               _loc7_ = Math.ceil(Math.max(_loc7_,!!this.dataGrid._explicitHeaderHeight ? Number(this.cachedHeaderHeight) : Number(_loc9_ + this.cachedPaddingBottom + this.cachedPaddingTop)));
               _loc17_ = Math.max(_loc17_,!!this.dataGrid._explicitHeaderHeight ? Number(this.cachedHeaderHeight - this.cachedPaddingTop - this.cachedPaddingBottom) : Number(_loc9_));
            }
            _loc19_ = 0;
            while(_loc19_ < this.headerItems.length)
            {
               this.headerItems[_loc19_].setActualSize(this.headerItems[_loc19_].width,_loc17_);
               _loc19_++;
            }
            _loc19_ = 0;
            while(_loc19_ < _loc18_.length)
            {
               if((_loc12_ = _loc18_[_loc19_]) && this.headerItems.indexOf(_loc12_) == -1)
               {
                  if(_loc12_.parent == this)
                  {
                     removeChild(DisplayObject(_loc12_));
                  }
               }
               _loc19_++;
            }
            while(this.headerItems.length > _loc10_)
            {
               if((_loc13_ = this.headerItems.pop()).parent == this)
               {
                  if(this.headerItems.indexOf(_loc13_) == -1)
                  {
                     removeChild(DisplayObject(_loc13_));
                  }
               }
            }
         }
         var _loc4_:UIComponent = UIComponent(getChildByName("headerBG"));
         if(this.headerBGSkinChanged)
         {
            this.headerBGSkinChanged = false;
            if(_loc4_)
            {
               removeChild(_loc4_);
            }
            _loc4_ = null;
         }
         if(!_loc4_)
         {
            (_loc4_ = new UIComponent()).name = "headerBG";
            addChildAt(DisplayObject(_loc4_),0);
            if((_loc21_ = new (_loc20_ = getStyle("headerBackgroundSkin"))()) is ISimpleStyleClient)
            {
               ISimpleStyleClient(_loc21_).styleName = this;
            }
            _loc4_.addChild(DisplayObject(_loc21_));
         }
         if(this.dataGrid.headerVisible)
         {
            _loc4_.visible = true;
            this.drawHeaderBackgroundSkin(IFlexDisplayObject(_loc4_.getChildAt(0)));
            this.dataGrid._drawSeparators();
         }
         else
         {
            _loc4_.visible = false;
            this.dataGrid._clearSeparators();
         }
         this.dataGrid._placeSortArrow();
         this.allowItemSizeChangeNotification = true;
      }
      
      mx_internal function _drawHeaderBackground(param1:UIComponent) : void
      {
         this.drawHeaderBackground(param1);
      }
      
      protected function drawHeaderBackground(param1:UIComponent) : void
      {
         var _loc2_:Number = width;
         var _loc3_:Number = this.cachedHeaderHeight;
         var _loc4_:Graphics;
         (_loc4_ = param1.graphics).clear();
         var _loc5_:Array = getStyle("headerColors");
         styleManager.getColorNames(_loc5_);
         var _loc6_:Matrix;
         (_loc6_ = new Matrix()).createGradientBox(_loc2_,_loc3_ + 1,Math.PI / 2,0,0);
         _loc5_ = [_loc5_[0],_loc5_[0],_loc5_[1]];
         var _loc7_:Array = [0,60,255];
         var _loc8_:Array = [1,1,1];
         _loc4_.beginGradientFill(GradientType.LINEAR,_loc5_,_loc8_,_loc7_,_loc6_);
         _loc4_.lineStyle(0,0,0);
         _loc4_.moveTo(0,0);
         _loc4_.lineTo(_loc2_,0);
         _loc4_.lineTo(_loc2_,_loc3_ - 0.5);
         _loc4_.lineStyle(0,getStyle("borderColor"),100);
         _loc4_.lineTo(0,_loc3_ - 0.5);
         _loc4_.lineStyle(0,0,0);
         _loc4_.endFill();
      }
      
      private function drawHeaderBackgroundSkin(param1:IFlexDisplayObject) : void
      {
         param1.setActualSize(unscaledWidth,Math.ceil(this.cachedHeaderHeight));
      }
      
      mx_internal function _clearSeparators() : void
      {
         this.clearSeparators();
      }
      
      protected function clearSeparators() : void
      {
         if(!this.separators)
         {
            return;
         }
         var _loc1_:Sprite = Sprite(getChildByName("lines"));
         while(_loc1_.numChildren)
         {
            _loc1_.removeChildAt(_loc1_.numChildren - 1);
            this.separators.pop();
         }
      }
      
      mx_internal function _drawSeparators() : void
      {
         this.drawSeparators();
      }
      
      protected function drawSeparators() : void
      {
         var _loc4_:UIComponent = null;
         var _loc5_:IFlexDisplayObject = null;
         var _loc6_:Array = null;
         var _loc7_:Number = NaN;
         var _loc8_:Class = null;
         if(!this.separators)
         {
            this.separators = [];
         }
         var _loc1_:UIComponent = UIComponent(getChildByName("lines"));
         if(!_loc1_)
         {
            _loc1_ = new UIComponent();
            _loc1_.name = "lines";
            addChild(_loc1_);
         }
         else
         {
            setChildIndex(_loc1_,numChildren - 1);
         }
         _loc1_.scrollRect = new Rectangle(0,0,unscaledWidth,unscaledHeight + 1);
         if(this.headerSepSkinChanged)
         {
            this.headerSepSkinChanged = false;
            this.clearSeparators();
         }
         var _loc2_:int = !!mx_internal::visibleColumns ? int(mx_internal::visibleColumns.length) : 0;
         if(!this.needRightSeparator && _loc2_ > 0)
         {
            _loc2_--;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_loc3_ < _loc1_.numChildren)
            {
               _loc4_ = UIComponent(_loc1_.getChildAt(_loc3_));
               _loc5_ = IFlexDisplayObject(_loc4_.getChildAt(0));
            }
            else
            {
               if((_loc5_ = new (_loc8_ = getStyle("headerSeparatorSkin"))()) is ISimpleStyleClient)
               {
                  ISimpleStyleClient(_loc5_).styleName = this;
               }
               (_loc4_ = new UIComponent()).addChild(DisplayObject(_loc5_));
               _loc1_.addChild(_loc4_);
               UIComponentGlobals.layoutManager.validateClient(_loc4_,true);
               this.separators.push(_loc4_);
            }
            if(!(_loc3_ == mx_internal::visibleColumns.length - 1 && !this.needRightSeparatorEvents))
            {
               DisplayObject(_loc4_).addEventListener(MouseEvent.MOUSE_OVER,this.columnResizeMouseOverHandler);
               DisplayObject(_loc4_).addEventListener(MouseEvent.MOUSE_OUT,this.columnResizeMouseOutHandler);
               DisplayObject(_loc4_).addEventListener(MouseEvent.MOUSE_DOWN,this.columnResizeMouseDownHandler);
            }
            else if(_loc3_ == mx_internal::visibleColumns.length - 1 && !this.needRightSeparatorEvents)
            {
               DisplayObject(_loc4_).removeEventListener(MouseEvent.MOUSE_OVER,this.columnResizeMouseOverHandler);
               DisplayObject(_loc4_).removeEventListener(MouseEvent.MOUSE_OUT,this.columnResizeMouseOutHandler);
               DisplayObject(_loc4_).removeEventListener(MouseEvent.MOUSE_DOWN,this.columnResizeMouseDownHandler);
            }
            if(!((_loc6_ = mx_internal::visibleColumns) && _loc6_.length > 0 || this.dataGrid.headerVisible))
            {
               _loc4_.visible = false;
            }
            else
            {
               if(_loc5_ is IUIComponent)
               {
                  _loc7_ = IUIComponent(_loc5_).getExplicitOrMeasuredWidth();
               }
               else
               {
                  _loc7_ = _loc5_.measuredWidth;
               }
               _loc4_.visible = true;
               _loc4_.x = this.headerItems[_loc3_].x + mx_internal::visibleColumns[_loc3_].width - Math.round(_loc7_ / 2);
               if(_loc3_ > 0)
               {
                  _loc4_.x = Math.max(_loc4_.x,this.separators[_loc3_ - 1].x + Math.round(_loc7_ / 2));
               }
               _loc4_.y = 0;
               _loc5_.setActualSize(_loc7_,Math.ceil(this.cachedHeaderHeight));
               _loc4_.graphics.clear();
               _loc4_.graphics.beginFill(16777215,0);
               _loc4_.graphics.drawRect(-this.separatorAffordance,0,_loc5_.measuredWidth + this.separatorAffordance,this.cachedHeaderHeight);
               _loc4_.graphics.endFill();
               _loc4_.mouseEnabled = true;
            }
            _loc3_++;
         }
         while(_loc1_.numChildren > _loc2_)
         {
            _loc1_.removeChildAt(_loc1_.numChildren - 1);
            this.separators.pop();
         }
         UIComponentGlobals.layoutManager.validateClient(_loc1_,true);
      }
      
      protected function drawHeaderIndicator(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint, param7:IListItemRenderer) : void
      {
         var _loc8_:Graphics;
         (_loc8_ = param1.graphics).clear();
         _loc8_.beginFill(param6);
         _loc8_.drawRect(0,0,param4,param5);
         _loc8_.endFill();
         param1.x = param2;
         param1.y = param3;
      }
      
      protected function drawSelectionIndicator(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint, param7:IListItemRenderer) : void
      {
         var _loc8_:Graphics;
         (_loc8_ = param1.graphics).clear();
         _loc8_.beginFill(param6);
         _loc8_.drawRect(0,0,param4,param5);
         _loc8_.endFill();
         param1.x = param2;
         param1.y = param3;
      }
      
      protected function drawColumnDragOverlay(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint, param7:IListItemRenderer) : void
      {
         var _loc8_:Graphics;
         (_loc8_ = param1.graphics).clear();
         _loc8_.beginFill(param6);
         _loc8_.drawRect(0,0,param4,param5);
         _loc8_.endFill();
         param1.x = param2;
         param1.y = param3;
      }
      
      private function columnResizeMouseOverHandler(param1:MouseEvent) : void
      {
         if(!enabled || !this.dataGrid.resizableColumns)
         {
            return;
         }
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         var _loc3_:int = _loc2_.parent.getChildIndex(_loc2_);
         if(!mx_internal::visibleColumns[_loc3_].resizable)
         {
            return;
         }
         var _loc4_:Class = getStyle("stretchCursor");
         this.resizeCursorID = cursorManager.setCursor(_loc4_,CursorManagerPriority.HIGH,0,0);
      }
      
      private function columnResizeMouseOutHandler(param1:MouseEvent) : void
      {
         if(!enabled || !this.dataGrid.resizableColumns)
         {
            return;
         }
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         var _loc3_:int = _loc2_.parent.getChildIndex(_loc2_);
         if(!mx_internal::visibleColumns[_loc3_].resizable)
         {
            return;
         }
         cursorManager.removeCursor(this.resizeCursorID);
      }
      
      private function columnResizeMouseDownHandler(param1:MouseEvent) : void
      {
         if(!enabled || !this.dataGrid.resizableColumns)
         {
            return;
         }
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         var _loc3_:int = _loc2_.parent.getChildIndex(_loc2_);
         if(!mx_internal::visibleColumns[_loc3_].resizable)
         {
            return;
         }
         this.startX = DisplayObject(param1.target).x + x;
         this.lastPt = new Point(param1.stageX,param1.stageY);
         this.lastPt = this.dataGrid.globalToLocal(this.lastPt);
         var _loc4_:int = this.separators.length;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_)
         {
            if(this.separators[_loc6_] == param1.target)
            {
               this.resizingColumn = mx_internal::visibleColumns[_loc6_];
               _loc5_ = _loc6_;
            }
            else
            {
               this.separators[_loc6_].mouseEnabled = false;
            }
            _loc6_++;
         }
         if(!this.resizingColumn)
         {
            return;
         }
         this.minX = this.headerItems[_loc5_].x + x + this.resizingColumn.minWidth;
         var _loc7_:DisplayObject;
         (_loc7_ = systemManager.getSandboxRoot()).addEventListener(MouseEvent.MOUSE_MOVE,this.columnResizingHandler,true);
         _loc7_.addEventListener(MouseEvent.MOUSE_UP,this.columnResizeMouseUpHandler,true);
         _loc7_.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.columnResizeMouseUpHandler);
         systemManager.deployMouseShields(true);
         var _loc8_:Class = getStyle("columnResizeSkin");
         this.resizeGraphic = new _loc8_();
         if(this.resizeGraphic is Sprite)
         {
            Sprite(this.resizeGraphic).mouseEnabled = false;
         }
         this.dataGrid.addChild(DisplayObject(this.resizeGraphic));
         this.resizeGraphic.move(DisplayObject(param1.target).x + x,0);
         this.resizeGraphic.setActualSize(this.resizeGraphic.measuredWidth,this.dataGrid.height / this.dataGrid.scaleY);
      }
      
      private function columnResizingHandler(param1:MouseEvent) : void
      {
         if(!MouseEvent(param1).buttonDown)
         {
            this.columnResizeMouseUpHandler(param1);
            return;
         }
         var _loc2_:int = !!this.dataGrid.vScrollBar ? int(this.dataGrid.vScrollBar.width) : 0;
         var _loc3_:Point = new Point(param1.stageX,param1.stageY);
         _loc3_ = this.dataGrid.globalToLocal(_loc3_);
         this.lastPt = _loc3_;
         this.resizeGraphic.move(Math.min(Math.max(this.minX,_loc3_.x),this.dataGrid.width / this.dataGrid.scaleX - this.separators[0].width - _loc2_),0);
      }
      
      private function columnResizeMouseUpHandler(param1:Event) : void
      {
         var _loc6_:Point = null;
         if(!enabled || !this.dataGrid.resizableColumns)
         {
            return;
         }
         this.lastItemDown = null;
         var _loc2_:DisplayObject = systemManager.getSandboxRoot();
         _loc2_.removeEventListener(MouseEvent.MOUSE_MOVE,this.columnResizingHandler,true);
         _loc2_.removeEventListener(MouseEvent.MOUSE_UP,this.columnResizeMouseUpHandler,true);
         _loc2_.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.columnResizeMouseUpHandler);
         systemManager.deployMouseShields(false);
         this.dataGrid.removeChild(DisplayObject(this.resizeGraphic));
         this.resizeGraphic = null;
         cursorManager.removeCursor(this.resizeCursorID);
         var _loc3_:DataGridColumn = this.resizingColumn;
         this.resizingColumn = null;
         var _loc4_:int = !!this.dataGrid.vScrollBar ? int(this.dataGrid.vScrollBar.width) : 0;
         var _loc5_:MouseEvent;
         if(_loc5_ = param1 as MouseEvent)
         {
            _loc6_ = new Point(_loc5_.stageX,_loc5_.stageY);
            _loc6_ = this.dataGrid.globalToLocal(_loc6_);
         }
         else
         {
            _loc6_ = this.lastPt;
         }
         var _loc7_:Number = Math.min(Math.max(this.minX,_loc6_.x),this.dataGrid.width / this.dataGrid.scaleX - this.separators[0].width - _loc4_) - this.startX;
         this.dataGrid.resizeColumn(_loc3_.colNum,Math.floor(_loc3_.width + _loc7_));
         invalidateDisplayList();
         var _loc8_:DataGridEvent;
         (_loc8_ = new DataGridEvent(DataGridEvent.COLUMN_STRETCH)).columnIndex = _loc3_.colNum;
         _loc8_.dataField = _loc3_.dataField;
         _loc8_.localX = _loc6_.x;
         this.dataGrid.dispatchEvent(_loc8_);
      }
      
      private function columnDraggingMouseMoveHandler(param1:MouseEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc4_:Sprite = null;
         var _loc7_:Sprite = null;
         var _loc13_:Number = NaN;
         var _loc14_:EdgeMetrics = null;
         var _loc15_:IListItemRenderer = null;
         var _loc16_:DataGridListData = null;
         var _loc17_:Class = null;
         var _loc18_:Shape = null;
         if(!param1.buttonDown)
         {
            this.columnDraggingMouseUpHandler(param1);
            return;
         }
         var _loc3_:DataGridColumn = this.dataGrid.movingColumn;
         var _loc5_:int = 0;
         var _loc6_:int = this.headerItems.length;
         if(isNaN(this.startX))
         {
            this.startX = param1.stageX;
            this.lastItemDown = null;
            _loc14_ = this.dataGrid.viewMetrics;
            (_loc7_ = new UIComponent()).name = "columnDragSelectionLayer";
            _loc7_.alpha = 0.6;
            this.dataGrid.addChild(_loc7_);
            _loc7_.x = _loc14_.left;
            _loc7_.y = _loc14_.top;
            (_loc15_ = this.dataGrid.createColumnItemRenderer(_loc3_,true,_loc3_)).name = "headerDragProxy";
            _loc16_ = new DataGridListData(_loc3_.headerText != null ? _loc3_.headerText : _loc3_.dataField,_loc3_.dataField,_loc3_.colNum,uid,this.dataGrid,0);
            if(_loc15_ is IDropInListItemRenderer)
            {
               IDropInListItemRenderer(_loc15_).listData = _loc16_;
            }
            _loc7_.addChild(DisplayObject(_loc15_));
            _loc15_.data = _loc3_;
            _loc15_.styleName = getStyle("headerDragProxyStyleName");
            UIComponentGlobals.layoutManager.validateClient(_loc15_,true);
            _loc15_.setActualSize(_loc3_.width,!!this.dataGrid._explicitHeaderHeight ? Number(this.dataGrid.headerHeight) : Number(_loc15_.getExplicitOrMeasuredHeight()));
            _loc5_ = 0;
            while(_loc5_ < _loc6_)
            {
               _loc2_ = this.headerItems[_loc5_];
               if(_loc2_.data == this.dataGrid.movingColumn)
               {
                  break;
               }
               _loc5_++;
            }
            _loc15_.move(_loc2_.x + x,_loc2_.y);
            (_loc4_ = new FlexSprite()).name = "columnDragOverlay";
            _loc4_.alpha = 0.6;
            this.dataGrid.addChild(_loc4_);
            if(_loc3_.width > 0)
            {
               this.drawColumnDragOverlay(_loc4_,_loc2_.x + x,0,_loc3_.width,this.dataGrid.height / this.dataGrid.scaleY - _loc14_.bottom - _loc4_.y,getStyle("disabledColor"),_loc2_);
            }
            if(_loc4_ = Sprite(mx_internal::selectionLayer.getChildByName("headerSelection")))
            {
               _loc4_.width = this.dataGrid.movingColumn.width;
               _loc7_.addChild(_loc4_);
               _loc4_.x += x;
            }
            _loc7_.scrollRect = new Rectangle(0,0,this.dataGrid.width / this.dataGrid.scaleX,unscaledHeight);
            return;
         }
         var _loc8_:Number = param1.stageX - this.startX;
         _loc7_ = Sprite(this.dataGrid.getChildByName("columnDragSelectionLayer"));
         var _loc9_:Number = layoutDirection == LayoutDirection.LTR ? Number(Number(_loc8_)) : Number(-_loc8_);
         if(_loc4_ = Sprite(_loc7_.getChildByName("headerSelection")))
         {
            _loc4_.x += _loc9_;
         }
         _loc2_ = IListItemRenderer(_loc7_.getChildByName("headerDragProxy"));
         if(_loc2_)
         {
            _loc2_.move(_loc2_.x + _loc9_,_loc2_.y);
         }
         this.startX += _loc8_;
         var _loc10_:Array = this.dataGrid.getAllVisibleColumns();
         var _loc11_:Point = new Point(param1.stageX,param1.stageY);
         _loc11_ = this.dataGrid.globalToLocal(_loc11_);
         this.lastPt = _loc11_;
         _loc6_ = _loc10_.length;
         var _loc12_:Number = this.dataGrid.viewMetrics.left;
         _loc5_ = 0;
         while(_loc5_ < _loc6_)
         {
            _loc13_ = _loc10_[_loc5_].width;
            if(_loc11_.x < _loc12_ + _loc13_)
            {
               if(_loc11_.x > _loc12_ + _loc13_ / 2)
               {
                  _loc5_++;
                  _loc12_ += _loc13_;
               }
               if(this.dropColumnIndex != _loc5_)
               {
                  this.dropColumnIndex = _loc5_;
                  if(!this.columnDropIndicator)
                  {
                     if(!(_loc17_ = getStyle("columnDropIndicatorSkin")))
                     {
                        _loc17_ = DataGridColumnDropIndicator;
                     }
                     this.columnDropIndicator = IFlexDisplayObject(new _loc17_());
                     if(this.columnDropIndicator is ISimpleStyleClient)
                     {
                        ISimpleStyleClient(this.columnDropIndicator).styleName = this;
                     }
                     this.dataGrid.addChild(DisplayObject(this.columnDropIndicator));
                     (_loc18_ = new Shape()).graphics.beginFill(16777215);
                     _loc18_.graphics.drawRect(0,0,10,10);
                     _loc18_.graphics.endFill();
                     this.dataGrid.addChild(_loc18_);
                     this.columnDropIndicator.mask = _loc18_;
                  }
                  this.dataGrid.setChildIndex(DisplayObject(this.columnDropIndicator),this.dataGrid.numChildren - 1);
                  this.columnDropIndicator.visible = true;
                  (_loc18_ = this.columnDropIndicator.mask as Shape).x = this.dataGrid.viewMetrics.left;
                  _loc18_.y = this.dataGrid.viewMetrics.top;
                  _loc18_.width = this.dataGrid.width / this.dataGrid.scaleX - _loc18_.x - this.dataGrid.viewMetrics.right;
                  _loc18_.height = this.dataGrid.height / this.dataGrid.scaleY - _loc18_.x - this.dataGrid.viewMetrics.bottom;
                  this.columnDropIndicator.setActualSize(3,this.dataGrid.height / this.dataGrid.scaleY);
                  this.columnDropIndicator.x = _loc12_ - this.columnDropIndicator.width + (layoutDirection == LayoutDirection.LTR ? 0 : 1);
                  this.columnDropIndicator.y = 0;
               }
               break;
            }
            _loc12_ += _loc13_;
            _loc5_++;
         }
      }
      
      private function columnDraggingMouseUpHandler(param1:Event) : void
      {
         if(!this.dataGrid.movingColumn)
         {
            return;
         }
         var _loc2_:int = this.dataGrid.movingColumn.colNum;
         var _loc3_:Array = this.dataGrid.getAllVisibleColumns();
         if(this.dropColumnIndex >= 0)
         {
            if(this.dropColumnIndex >= _loc3_.length)
            {
               this.dropColumnIndex = _loc3_.length - 1;
            }
            else if(_loc2_ < _loc3_[this.dropColumnIndex].colNum)
            {
               --this.dropColumnIndex;
            }
            this.dropColumnIndex = _loc3_[this.dropColumnIndex].colNum;
         }
         this.dataGrid.shiftColumns(_loc2_,this.dropColumnIndex,param1 as MouseEvent);
         var _loc4_:DisplayObject;
         (_loc4_ = systemManager.getSandboxRoot()).removeEventListener(MouseEvent.MOUSE_MOVE,this.columnDraggingMouseMoveHandler,true);
         _loc4_.removeEventListener(MouseEvent.MOUSE_UP,this.columnDraggingMouseUpHandler,true);
         _loc4_.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.columnDraggingMouseUpHandler);
         systemManager.deployMouseShields(false);
         var _loc5_:Sprite;
         if(!(_loc5_ = Sprite(this.dataGrid.getChildByName("columnDragSelectionLayer"))))
         {
            this.startX = NaN;
            this.dataGrid.movingColumn = null;
            this.dropColumnIndex = -1;
            return;
         }
         var _loc6_:IListItemRenderer;
         if(_loc6_ = IListItemRenderer(getChildByName("headerDragProxy")))
         {
            _loc5_.removeChild(DisplayObject(_loc6_));
         }
         var _loc7_:Sprite;
         if(_loc7_ = Sprite(_loc5_.getChildByName("headerSelection")))
         {
            _loc5_.removeChild(_loc7_);
         }
         if(this.columnDropIndicator)
         {
            this.columnDropIndicator.visible = false;
         }
         if(_loc7_ = Sprite(this.dataGrid.getChildByName("columnDragOverlay")))
         {
            this.dataGrid.removeChild(_loc7_);
         }
         this.dataGrid.removeChild(_loc5_);
         this.startX = NaN;
         this.dataGrid.movingColumn = null;
         this.dropColumnIndex = -1;
         invalidateDisplayList();
      }
      
      protected function mouseOverHandler(param1:MouseEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Point = null;
         var _loc6_:Sprite = null;
         if(this.resizingColumn || this.dataGrid.movingColumn)
         {
            return;
         }
         if(this.dataGrid.enabled && this.dataGrid.sortableColumns && this.dataGrid.headerVisible)
         {
            _loc6_ = Sprite(getChildByName("sortArrowHitArea"));
            if(param1.target == _loc6_)
            {
               _loc4_ = mx_internal::visibleColumns.length;
               _loc3_ = 0;
               while(_loc3_ < _loc4_)
               {
                  if(mx_internal::visibleColumns[_loc3_].colNum == this.dataGrid.sortIndex)
                  {
                     _loc2_ = this.headerItems[_loc3_];
                     break;
                  }
                  _loc3_++;
               }
            }
            else
            {
               _loc3_ = 0;
               while(_loc3_ < this.separators.length)
               {
                  if(param1.target == this.separators[_loc3_] && mx_internal::visibleColumns[_loc3_].resizable)
                  {
                     return;
                  }
                  _loc3_++;
               }
               _loc5_ = new Point(param1.stageX,param1.stageY);
               _loc5_ = globalToLocal(_loc5_);
               _loc3_ = 0;
               while(_loc3_ < this.headerItems.length)
               {
                  if(this.headerItems[_loc3_].x + this.headerItems[_loc3_].width >= _loc5_.x)
                  {
                     _loc2_ = this.headerItems[_loc3_];
                     break;
                  }
                  _loc3_++;
               }
               if(_loc3_ >= this.headerItems.length)
               {
                  return;
               }
            }
            _loc6_ = Sprite(getChildByName("sortArrowHitArea"));
            if(mx_internal::visibleColumns[_loc3_].sortable)
            {
               if(!(_loc6_ = Sprite(mx_internal::selectionLayer.getChildByName("headerSelection"))))
               {
                  (_loc6_ = new FlexSprite()).name = "headerSelection";
                  _loc6_.mouseEnabled = false;
                  mx_internal::selectionLayer.addChild(_loc6_);
               }
               this.drawHeaderIndicator(_loc6_,_loc2_.x,0,mx_internal::visibleColumns[_loc3_].width,this.cachedHeaderHeight - 0.5,getStyle("rollOverColor"),_loc2_);
            }
         }
         if(param1.buttonDown)
         {
            this.lastItemDown = _loc2_;
         }
         else
         {
            this.lastItemDown = null;
         }
      }
      
      protected function mouseOutHandler(param1:MouseEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Point = null;
         var _loc6_:Sprite = null;
         if(this.resizeGraphic || this.dataGrid.movingColumn)
         {
            return;
         }
         if(this.dataGrid.enabled && this.dataGrid.sortableColumns && this.dataGrid.headerVisible)
         {
            _loc6_ = Sprite(getChildByName("sortArrowHitArea"));
            if(param1.target == _loc6_)
            {
               _loc4_ = mx_internal::visibleColumns.length;
               _loc3_ = 0;
               while(_loc3_ < _loc4_)
               {
                  if(mx_internal::visibleColumns[_loc3_].colNum == this.dataGrid.sortIndex)
                  {
                     _loc2_ = this.headerItems[_loc3_];
                     break;
                  }
                  _loc3_++;
               }
               if(_loc3_ >= mx_internal::visibleColumns.length)
               {
                  return;
               }
            }
            else
            {
               _loc3_ = 0;
               while(_loc3_ < this.separators.length)
               {
                  if(param1.target == this.separators[_loc3_] && mx_internal::visibleColumns[_loc3_].resizable)
                  {
                     return;
                  }
                  _loc3_++;
               }
               _loc5_ = new Point(param1.stageX,param1.stageY);
               _loc5_ = globalToLocal(_loc5_);
               _loc3_ = 0;
               while(_loc3_ < this.headerItems.length)
               {
                  if(this.headerItems[_loc3_].x + this.headerItems[_loc3_].width >= _loc5_.x)
                  {
                     _loc2_ = this.headerItems[_loc3_];
                     break;
                  }
                  _loc3_++;
               }
               if(_loc3_ >= this.headerItems.length)
               {
                  _loc3_ = this.headerItems.length - 1;
               }
            }
            if(mx_internal::visibleColumns.length > 0 && mx_internal::visibleColumns[_loc3_].sortable)
            {
               if(_loc6_ = Sprite(mx_internal::selectionLayer.getChildByName("headerSelection")))
               {
                  mx_internal::selectionLayer.removeChild(_loc6_);
               }
            }
         }
         if(param1.buttonDown)
         {
            this.lastItemDown = _loc2_;
         }
         else
         {
            this.lastItemDown = null;
         }
      }
      
      protected function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:IListItemRenderer = null;
         var _loc3_:Sprite = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Point = null;
         var _loc7_:DisplayObject = null;
         systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true,0,true);
         systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.mouseLeaveHandler,false,0,true);
         _loc3_ = Sprite(getChildByName("sortArrowHitArea"));
         if(param1.target == _loc3_)
         {
            _loc5_ = mx_internal::visibleColumns.length;
            _loc4_ = 0;
            while(_loc4_ < _loc5_)
            {
               if(mx_internal::visibleColumns[_loc4_].colNum == this.dataGrid.sortIndex)
               {
                  _loc2_ = this.headerItems[_loc4_];
                  break;
               }
               _loc4_++;
            }
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < this.separators.length)
            {
               if(param1.target == this.separators[_loc4_] && mx_internal::visibleColumns[_loc4_].resizable)
               {
                  return;
               }
               _loc4_++;
            }
            _loc6_ = new Point(param1.stageX,param1.stageY);
            _loc6_ = globalToLocal(_loc6_);
            _loc4_ = 0;
            while(_loc4_ < this.headerItems.length)
            {
               if(this.headerItems[_loc4_].x + this.headerItems[_loc4_].width >= _loc6_.x)
               {
                  _loc2_ = this.headerItems[_loc4_];
                  break;
               }
               _loc4_++;
            }
            if(_loc4_ >= this.headerItems.length)
            {
               return;
            }
         }
         if(this.dataGrid.enabled && (this.dataGrid.sortableColumns || this.dataGrid.draggableColumns) && this.dataGrid.headerVisible)
         {
            if(this.dataGrid.sortableColumns && mx_internal::visibleColumns[_loc4_].sortable)
            {
               this.lastItemDown = _loc2_;
               _loc3_ = Sprite(mx_internal::selectionLayer.getChildByName("headerSelection"));
               if(!_loc3_)
               {
                  _loc3_ = new FlexSprite();
                  _loc3_.name = "headerSelection";
                  mx_internal::selectionLayer.addChild(_loc3_);
               }
               this.drawSelectionIndicator(_loc3_,_loc2_.x,0,mx_internal::visibleColumns[_loc4_].width,this.cachedHeaderHeight - 0.5,getStyle("selectionColor"),_loc2_);
            }
            if(this.dataGrid.draggableColumns && mx_internal::visibleColumns[_loc4_].draggable)
            {
               this.startX = NaN;
               (_loc7_ = systemManager.getSandboxRoot()).addEventListener(MouseEvent.MOUSE_MOVE,this.columnDraggingMouseMoveHandler,true);
               _loc7_.addEventListener(MouseEvent.MOUSE_UP,this.columnDraggingMouseUpHandler,true);
               _loc7_.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.columnDraggingMouseUpHandler);
               systemManager.deployMouseShields(true);
               this.dataGrid.movingColumn = mx_internal::visibleColumns[_loc4_];
            }
         }
      }
      
      protected function mouseUpHandler(param1:MouseEvent) : void
      {
         var _loc2_:DataGridEvent = null;
         var _loc3_:IListItemRenderer = null;
         var _loc4_:Sprite = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Point = null;
         systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true);
         systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.mouseLeaveHandler);
         _loc4_ = Sprite(getChildByName("sortArrowHitArea"));
         if(param1.target == _loc4_)
         {
            _loc5_ = mx_internal::visibleColumns.length;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(mx_internal::visibleColumns[_loc6_].colNum == this.dataGrid.sortIndex)
               {
                  _loc3_ = this.headerItems[_loc6_];
                  break;
               }
               _loc6_++;
            }
         }
         else
         {
            _loc6_ = 0;
            while(_loc6_ < this.separators.length)
            {
               if(param1.target == this.separators[_loc6_] && mx_internal::visibleColumns[_loc6_].resizable)
               {
                  return;
               }
               _loc6_++;
            }
            _loc7_ = new Point(param1.stageX,param1.stageY);
            _loc7_ = globalToLocal(_loc7_);
            _loc6_ = 0;
            while(_loc6_ < this.headerItems.length)
            {
               if(this.headerItems[_loc6_].x + this.headerItems[_loc6_].width >= _loc7_.x)
               {
                  _loc3_ = this.headerItems[_loc6_];
                  break;
               }
               _loc6_++;
            }
            if(_loc6_ >= this.headerItems.length)
            {
               return;
            }
         }
         if(this.dataGrid.enabled && (this.dataGrid.sortableColumns || this.dataGrid.draggableColumns) && this.dataGrid.dataProvider && this.dataGrid.headerVisible)
         {
            if(_loc3_ == this.lastItemDown)
            {
               if(this.dataGrid.sortableColumns && mx_internal::visibleColumns[_loc6_].sortable)
               {
                  this.lastItemDown = null;
                  _loc2_ = new DataGridEvent(DataGridEvent.HEADER_RELEASE,false,true);
                  _loc2_.columnIndex = mx_internal::visibleColumns[_loc6_].colNum;
                  _loc2_.dataField = mx_internal::visibleColumns[_loc6_].dataField;
                  _loc2_.itemRenderer = _loc3_;
                  this.dataGrid.dispatchEvent(_loc2_);
               }
            }
         }
      }
      
      private function mouseLeaveHandler(param1:Event) : void
      {
         systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true);
         systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.mouseLeaveHandler);
      }
      
      mx_internal function _placeSortArrow() : void
      {
         this.placeSortArrow();
      }
      
      protected function placeSortArrow() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:Class = null;
         var _loc9_:Graphics = null;
         var _loc10_:int = 0;
         var _loc1_:Sprite = Sprite(getChildByName("sortArrowHitArea"));
         if(this.dataGrid.sortIndex == -1 && this.dataGrid.lastSortIndex == -1)
         {
            if(this.sortArrow)
            {
               this.sortArrow.visible = false;
            }
            if(_loc1_)
            {
               _loc1_.visible = false;
            }
            return;
         }
         if(!this.dataGrid.headerVisible)
         {
            if(this.sortArrow)
            {
               this.sortArrow.visible = false;
            }
            if(_loc1_)
            {
               _loc1_.visible = false;
            }
            return;
         }
         if(!this.sortArrow)
         {
            _loc8_ = getStyle("sortArrowSkin");
            this.sortArrow = new _loc8_();
            DisplayObject(this.sortArrow).name = !!enabled ? "sortArrow" : "sortArrowDisabled";
            if(this.sortArrow is ISimpleStyleClient)
            {
               ISimpleStyleClient(this.sortArrow).styleName = this;
            }
            addChild(DisplayObject(this.sortArrow));
         }
         var _loc5_:Boolean = false;
         if(this.headerItems && this.headerItems.length)
         {
            _loc3_ = this.headerItems.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(mx_internal::visibleColumns[_loc4_].colNum == this.dataGrid.sortIndex)
               {
                  _loc2_ = this.headerItems[_loc4_].x + mx_internal::visibleColumns[_loc4_].width;
                  this.headerItems[_loc4_].setActualSize(mx_internal::visibleColumns[_loc4_].width - this.sortArrow.measuredWidth - 8,this.headerItems[_loc4_].height);
                  if(!isNaN(this.headerItems[_loc4_].explicitWidth))
                  {
                     this.headerItems[_loc4_].explicitWidth = this.headerItems[_loc4_].width;
                  }
                  UIComponentGlobals.layoutManager.validateClient(this.headerItems[_loc4_],true);
                  if(!_loc1_)
                  {
                     _loc1_ = new FlexSprite();
                     _loc1_.name = "sortArrowHitArea";
                     addChild(_loc1_);
                  }
                  else
                  {
                     _loc1_.visible = true;
                  }
                  _loc1_.x = this.headerItems[_loc4_].x + this.headerItems[_loc4_].width;
                  _loc1_.y = this.headerItems[_loc4_].y;
                  (_loc9_ = _loc1_.graphics).clear();
                  _loc9_.beginFill(0,0);
                  _loc9_.drawRect(0,0,this.sortArrow.measuredWidth + 8,this.headerItems[_loc4_].height);
                  _loc9_.endFill();
                  _loc5_ = true;
                  break;
               }
               _loc4_++;
            }
         }
         if(isNaN(_loc2_))
         {
            this.sortArrow.visible = false;
         }
         else
         {
            this.sortArrow.visible = true;
         }
         if(mx_internal::visibleColumns.length && this.dataGrid.lastSortIndex >= 0 && this.dataGrid.lastSortIndex != this.dataGrid.sortIndex)
         {
            if(mx_internal::visibleColumns[0].colNum <= this.dataGrid.lastSortIndex && this.dataGrid.lastSortIndex <= mx_internal::visibleColumns[mx_internal::visibleColumns.length - 1].colNum)
            {
               _loc3_ = this.headerItems.length;
               _loc10_ = 0;
               while(_loc10_ < _loc3_)
               {
                  if(mx_internal::visibleColumns[_loc10_].colNum == this.dataGrid.lastSortIndex)
                  {
                     this.headerItems[_loc10_].setActualSize(mx_internal::visibleColumns[_loc10_].width,this.headerItems[_loc10_].height);
                     UIComponentGlobals.layoutManager.validateClient(this.headerItems[_loc10_],true);
                     break;
                  }
                  _loc10_++;
               }
            }
         }
         var _loc6_:* = this.dataGrid.sortDirection == "ASC";
         this.sortArrow.width = this.sortArrow.measuredWidth;
         this.sortArrow.height = this.sortArrow.measuredHeight;
         DisplayObject(this.sortArrow).scaleY = !!_loc6_ ? Number(-1) : Number(1);
         this.sortArrow.x = _loc2_ - this.sortArrow.measuredWidth - 8;
         var _loc7_:Number = this.cachedHeaderHeight;
         this.sortArrow.y = (_loc7_ - this.sortArrow.measuredHeight) / 2 + (!!_loc6_ ? this.sortArrow.measuredHeight : 0);
         if(_loc5_ && this.sortArrow.x < this.headerItems[_loc4_].x)
         {
            this.sortArrow.visible = false;
         }
         if(!this.sortArrow.visible && _loc1_)
         {
            _loc1_.visible = false;
         }
      }
      
      override public function invalidateSize() : void
      {
         if(this.allowItemSizeChangeNotification)
         {
            super.invalidateSize();
         }
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         if(this.sortArrow)
         {
            removeChild(DisplayObject(this.sortArrow));
            this.sortArrow = null;
            this.placeSortArrow();
         }
      }
      
      override public function styleChanged(param1:String) : void
      {
         super.styleChanged(param1);
         if(param1 == "headerBackgroundSkin")
         {
            this.headerBGSkinChanged = true;
         }
         else if(param1 == "headerSeparatorSkin")
         {
            this.headerSepSkinChanged = true;
         }
      }
      
      mx_internal function getSeparators() : Array
      {
         return this.separators;
      }
      
      private function get resizingColumn() : DataGridColumn
      {
         return this.dataGrid.resizingColumn;
      }
      
      private function set resizingColumn(param1:DataGridColumn) : void
      {
         this.dataGrid.resizingColumn = param1;
      }
      
      mx_internal function get rendererArray() : Array
      {
         return this.headerItems;
      }
   }
}
