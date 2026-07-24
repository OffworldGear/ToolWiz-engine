package mx.charts.chartClasses
{
   import flash.geom.Rectangle;
   import mx.charts.ChartItem;
   import mx.charts.effects.effectClasses.SeriesEffectInstance;
   import mx.core.mx_internal;
   import mx.effects.Effect;
   import mx.effects.EffectManager;
   import mx.effects.IEffectInstance;
   import mx.events.DragEvent;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   
   use namespace mx_internal;
   
   public class Series extends ChartElement
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      protected var allSeriesTransform:Boolean = true;
      
      private var _previousTransitionData:Object;
      
      private var _bDataDirty:Boolean = true;
      
      private var _bMappingDirty:Boolean = true;
      
      private var _bFilterDirty:Boolean = true;
      
      private var _bTransformDirty:Boolean = true;
      
      private var _bHideTransitionDirty:Boolean = false;
      
      private var _selectionDirty:Boolean = false;
      
      private var _selectionDirtyArray:Array;
      
      private var _selectionIndicesDirty:Boolean = false;
      
      private var _selectionIndicesDirtyArray:Array;
      
      private var _604694401_dataFunction:Function;
      
      private var _1502335886_dataTipItems:Array;
      
      private var _displayName:String;
      
      private var _filterDataValues:String = "outsideRange";
      
      private var _userfilterDataValues:String = "";
      
      private var _filterData:Boolean = true;
      
      private var _filterFunction:Function;
      
      private var _interactive:Boolean = true;
      
      private var _selectable:Boolean = true;
      
      private var _selectedItems:Array;
      
      private var _transitionRenderData:Object;
      
      public function Series()
      {
         this._selectionDirtyArray = [];
         this._selectionIndicesDirtyArray = [];
         this._filterFunction = this.defaultFilterFunction;
         this._selectedItems = [];
         super();
         super.showInAutomationHierarchy = false;
         this.addEventListener(DragEvent.DRAG_START,this.dragStartHandler);
      }
      
      override public function set dataTransform(param1:DataTransform) : void
      {
         var _loc2_:* = null;
         if(dataTransform)
         {
            dataTransform.removeEventListener(FlexEvent.TRANSFORM_CHANGE,this.transformChangeHandler);
         }
         if(param1)
         {
            super.dataTransform = param1;
            param1.addEventListener(FlexEvent.TRANSFORM_CHANGE,this.transformChangeHandler,false,0,true);
         }
         else
         {
            for(_loc2_ in dataTransform.axes)
            {
               dataTransform.getAxis(_loc2_).unregisterDataTransform(dataTransform);
            }
         }
      }
      
      override public function set showInAutomationHierarchy(param1:Boolean) : void
      {
      }
      
      public function get dataFunction() : Function
      {
         return this._dataFunction;
      }
      
      public function set dataFunction(param1:Function) : void
      {
         this._dataFunction = param1;
         this.dataChanged();
      }
      
      public function get dataTipItems() : Array
      {
         return this._dataTipItems;
      }
      
      public function set dataTipItems(param1:Array) : void
      {
         this._dataTipItems = param1;
         invalidateProperties();
      }
      
      public function get displayName() : String
      {
         return this._displayName;
      }
      
      public function set displayName(param1:String) : void
      {
         this._displayName = param1;
         var _loc2_:ChartBase = chart;
         if(_loc2_)
         {
            _loc2_.legendDataChanged();
         }
      }
      
      public function get filterDataValues() : String
      {
         return this._filterDataValues;
      }
      
      public function set filterDataValues(param1:String) : void
      {
         this._filterDataValues = param1;
         this._userfilterDataValues = param1;
         this.invalidateFilter();
      }
      
      public function get filterData() : Boolean
      {
         return this._filterData;
      }
      
      public function set filterData(param1:Boolean) : void
      {
         this._filterData = param1;
         if(this._userfilterDataValues == "")
         {
            if(param1)
            {
               this._filterDataValues = "outsideRange";
            }
            else
            {
               this._filterDataValues = "none";
            }
            this.invalidateFilter();
         }
      }
      
      public function get filterFunction() : Function
      {
         return this._filterFunction;
      }
      
      public function set filterFunction(param1:Function) : void
      {
         if(param1 != null)
         {
            this._filterFunction = param1;
         }
         else
         {
            this._filterFunction = this.defaultFilterFunction;
         }
         this.invalidateFilter();
      }
      
      public function get interactive() : Boolean
      {
         return this._interactive;
      }
      
      public function set interactive(param1:Boolean) : void
      {
         this._interactive = param1;
         invalidateDisplayList();
      }
      
      public function get legendData() : Array
      {
         return null;
      }
      
      protected function get renderData() : Object
      {
         return null;
      }
      
      public function get selectable() : Boolean
      {
         return this._selectable;
      }
      
      public function set selectable(param1:Boolean) : void
      {
         if(this._selectable != param1)
         {
            this._selectable = param1;
            invalidateProperties();
         }
      }
      
      public function get selectedIndex() : int
      {
         var _loc1_:int = 0;
         _loc1_ = this._selectedItems.length;
         if(_loc1_ > 0)
         {
            return this._selectedItems[_loc1_ - 1].index;
         }
         return -1;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         var _loc2_:ChartItem = null;
         if(this._selectedItems.length == 1 && this._selectedItems[0].index == param1)
         {
            return;
         }
         if(this.items)
         {
            _loc2_ = null;
            _loc2_ = this.findChartItemFor(param1);
            if(!_loc2_)
            {
               return;
            }
            this._selectionDirtyArray = [];
            this._selectionDirtyArray.push(_loc2_);
            this._selectionDirty = true;
            invalidateProperties();
         }
         else
         {
            this._selectionIndicesDirty = true;
            this._selectionIndicesDirtyArray.push(param1);
            invalidateProperties();
         }
      }
      
      public function get selectedIndices() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:int = this._selectedItems.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_.push(this._selectedItems[_loc3_].index);
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function set selectedIndices(param1:Array) : void
      {
         var _loc2_:ChartItem = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._selectedItems.length == 0 && param1.length == 0)
         {
            return;
         }
         if(this.items)
         {
            _loc2_ = null;
            this._selectionDirtyArray = [];
            _loc3_ = param1.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc2_ = this.findChartItemFor(param1[_loc4_]);
               if(_loc2_)
               {
                  this._selectionDirtyArray.push(_loc2_);
               }
               _loc4_++;
            }
            this._selectionDirty = true;
            invalidateProperties();
         }
         else
         {
            this._selectionIndicesDirty = true;
            this._selectionIndicesDirtyArray = param1;
            invalidateProperties();
         }
      }
      
      public function get selectedItem() : ChartItem
      {
         var _loc1_:int = 0;
         _loc1_ = this._selectedItems.length;
         if(_loc1_ > 0)
         {
            return this._selectedItems[_loc1_ - 1];
         }
         return null;
      }
      
      public function set selectedItem(param1:ChartItem) : void
      {
         if(this._selectedItems.length == 1 && this._selectedItems[0] == param1)
         {
            return;
         }
         this._selectionDirtyArray = [];
         this._selectionDirtyArray.push(param1);
         this._selectionDirty = true;
         invalidateProperties();
      }
      
      public function get selectedItems() : Array
      {
         return this._selectedItems;
      }
      
      public function set selectedItems(param1:Array) : void
      {
         if(this._selectedItems.length == 0 && param1.length == 0)
         {
            return;
         }
         this._selectionDirtyArray = param1;
         this._selectionDirty = true;
         invalidateProperties();
      }
      
      public function get transitionRenderData() : Object
      {
         return this._transitionRenderData;
      }
      
      public function set transitionRenderData(param1:Object) : void
      {
         this._transitionRenderData = param1;
      }
      
      override public function stylesInitialized() : void
      {
         this.legendDataChanged();
      }
      
      override public function invalidateSize() : void
      {
         this.invalidateTransform();
         super.invalidateSize();
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc4_:uint = 0;
         super.updateDisplayList(param1,param2);
         if(this._bHideTransitionDirty)
         {
            this._bHideTransitionDirty = false;
         }
         var _loc3_:ChartBase = chart;
         if(_loc3_)
         {
            _loc4_ = _loc3_.chartState;
         }
         this.validateData();
         this.validateTransform();
         this.validateSelection();
      }
      
      override public function setActualSize(param1:Number, param2:Number) : void
      {
         this.invalidateTransform();
         super.setActualSize(param1,param2);
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(this._dataTipItems && chart)
         {
            chart.dataTipItemsSet = true;
            invalidateDisplayList();
         }
         if(this._selectionDirty)
         {
            this._selectionDirty = false;
            if(this._selectable && chart)
            {
               chart.seriesSelectionChanged(this,this._selectionDirtyArray);
            }
         }
      }
      
      override public function mappingChanged() : void
      {
         this.invalidateMapping();
      }
      
      override public function chartStateChanged(param1:uint, param2:uint) : void
      {
         invalidateDisplayList();
         if(param2 == ChartState.PREPARING_TO_SHOW_DATA || param2 == ChartState.NONE)
         {
            this.transitionRenderData = null;
         }
         super.chartStateChanged(param1,param2);
      }
      
      override public function collectTransitions(param1:Number, param2:Array) : void
      {
         var _loc4_:IEffectInstance = null;
         var _loc3_:Effect = null;
         if(param1 == ChartState.PREPARING_TO_HIDE_DATA)
         {
            _loc3_ = EffectManager.createEffectForType(this,"hideData") as Effect;
            if(_loc3_)
            {
               if((_loc4_ = _loc3_.createInstance(this)) is SeriesEffectInstance)
               {
                  (_loc4_ as SeriesEffectInstance).type = "hide";
               }
            }
         }
         else if(param1 == ChartState.PREPARING_TO_SHOW_DATA)
         {
            validateProperties();
            _loc3_ = EffectManager.createEffectForType(this,"showData") as Effect;
            if(_loc3_)
            {
               if((_loc4_ = _loc3_.createInstance(this)) is SeriesEffectInstance)
               {
                  (_loc4_ as SeriesEffectInstance).type = "show";
               }
            }
         }
         if(_loc4_)
         {
            param2.push(_loc4_);
         }
         super.collectTransitions(param1,param2);
      }
      
      override public function claimStyles(param1:Array, param2:uint) : uint
      {
         internalStyleName = param1[param2];
         return (param2 + 1) % param1.length;
      }
      
      public function get items() : Array
      {
         return [];
      }
      
      public function getItemsInRegion(param1:Rectangle) : Array
      {
         return [];
      }
      
      mx_internal function addItemtoSelection(param1:ChartItem) : void
      {
         this._selectedItems.push(param1);
         param1.currentState = ChartItem.SELECTED;
      }
      
      mx_internal function removeItemfromSelection(param1:ChartItem, param2:String = "disabled") : void
      {
         var _loc3_:int = 0;
         _loc3_ = this._selectedItems.indexOf(param1);
         this._selectedItems.splice(_loc3_,1);
         param1.currentState = param2;
      }
      
      mx_internal function setItemsState(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc2_ = !!this.renderData ? this.renderData.filteredCache : [];
         if(_loc2_)
         {
            _loc3_ = _loc2_.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc2_[_loc4_].currentState = param1;
               _loc4_++;
            }
         }
      }
      
      mx_internal function clearSeriesItemsState(param1:Boolean, param2:String = "none") : void
      {
         if(param1)
         {
            this._selectedItems = [];
         }
         this.setItemsState(param2);
      }
      
      mx_internal function getTransformState() : Boolean
      {
         return this._bTransformDirty;
      }
      
      mx_internal function emptySelectedItems() : void
      {
         this._selectedItems = [];
      }
      
      private function validateSelection() : void
      {
         if(this._selectionIndicesDirty)
         {
            this._selectionIndicesDirty = false;
            this.selectedIndices = this._selectionIndicesDirtyArray;
            this._selectionIndicesDirtyArray = [];
         }
         else if(this._selectionDirty == true)
         {
            this._selectionDirty = false;
            if(chart)
            {
               chart.updateKeyboardCache();
            }
         }
      }
      
      mx_internal function getChartSelectedStatus() : Boolean
      {
         if(chart)
         {
            return chart.selectedChartItems.length > 0;
         }
         return false;
      }
      
      protected function cacheDefaultValues(param1:String, param2:Array, param3:String) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc4_:int = param2.length;
         if(this._dataFunction != null)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               (_loc6_ = param2[_loc5_])[param3] = this.dataFunction(this,_loc6_.item,param3);
               _loc5_++;
            }
            return true;
         }
         if(param1 == "" || param1 == null)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               (_loc6_ = param2[_loc5_])[param3] = _loc6_.item;
               _loc5_++;
            }
            return false;
         }
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if((_loc6_ = param2[_loc5_]).item != null)
            {
               _loc6_[param3] = _loc6_.item[param1];
            }
            _loc5_++;
         }
         return true;
      }
      
      protected function cacheNamedValues(param1:String, param2:Array, param3:String) : Boolean
      {
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc4_:int = param2.length;
         if(this._dataFunction != null)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               (_loc5_ = param2[_loc6_])[param3] = this.dataFunction(this,_loc5_.item,param3);
               _loc6_++;
            }
            return true;
         }
         if(param1 == "")
         {
            return false;
         }
         _loc6_ = 0;
         while(_loc6_ < _loc4_)
         {
            if((_loc5_ = param2[_loc6_]).item != null)
            {
               _loc5_[param3] = _loc5_.item[param1];
            }
            _loc6_++;
         }
         return true;
      }
      
      protected function cacheIndexValues(param1:String, param2:Array, param3:String) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc4_:int = param2.length;
         if(this._dataFunction != null)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               (_loc6_ = param2[_loc5_])[param3] = this.dataFunction(this,_loc6_.item,param3);
               _loc5_++;
            }
            return true;
         }
         if(param1 == "")
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               (_loc6_ = param2[_loc5_])[param3] = _loc6_.index;
               _loc5_++;
            }
            return false;
         }
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if((_loc6_ = param2[_loc5_]).item != null)
            {
               _loc6_[param3] = _loc6_.item[param1];
            }
            _loc5_++;
         }
         return true;
      }
      
      protected function extractMinMax(param1:Array, param2:String, param3:DataDescription, param4:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc5_:int = param1.length;
         var _loc9_:Number = Number.POSITIVE_INFINITY;
         if(isNaN(param3.min))
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc7_ = param1[_loc6_][param2];
               if(isNaN(_loc7_) == false)
               {
                  break;
               }
               _loc6_++;
            }
            if(isNaN(_loc7_))
            {
               return;
            }
            param3.min = param3.max = _loc7_;
            _loc8_ = _loc7_;
         }
         _loc6_++;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = param1[_loc6_][param2];
            if(!isNaN(_loc7_))
            {
               if(_loc7_ < param3.min)
               {
                  param3.min = _loc7_;
               }
               if(_loc7_ > param3.max)
               {
                  param3.max = _loc7_;
               }
               if(param4 && _loc7_ - _loc8_ < _loc9_)
               {
                  _loc9_ = Math.abs(_loc7_ - _loc8_);
               }
               _loc8_ = _loc7_;
            }
            _loc6_++;
         }
         if(param4 && _loc9_ < Number.POSITIVE_INFINITY && (_loc9_ < param3.minInterval || isNaN(param3.minInterval)))
         {
            param3.minInterval = _loc9_;
         }
      }
      
      protected function extractMinInterval(param1:Array, param2:String, param3:DataDescription) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc4_:int = param1.length;
         var _loc8_:Number = Number.POSITIVE_INFINITY;
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = param1[_loc5_][param2];
            if(isNaN(_loc6_) == false)
            {
               break;
            }
            _loc5_++;
         }
         if(isNaN(_loc6_))
         {
            return;
         }
         _loc7_ = _loc6_;
         _loc5_++;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = param1[_loc5_][param2];
            if(!isNaN(_loc6_))
            {
               if(_loc6_ - _loc7_ < _loc8_)
               {
                  _loc8_ = Math.abs(_loc6_ - _loc7_);
               }
               _loc7_ = _loc6_;
            }
            _loc5_++;
         }
         if(_loc8_ < Number.POSITIVE_INFINITY && (_loc8_ < param3.minInterval || isNaN(param3.minInterval)))
         {
            param3.minInterval = _loc8_;
         }
      }
      
      protected function stripNaNs(param1:Array, param2:String) : void
      {
         var _loc6_:int = 0;
         if(this.filterDataValues == "none")
         {
            return;
         }
         var _loc3_:int = param1.length;
         var _loc4_:int = -1;
         var _loc5_:int = -1;
         var _loc7_:int = param1.length;
         if(param2 == "")
         {
            _loc6_ = _loc7_ - 1;
            while(_loc6_ >= 0)
            {
               if(isNaN(param1[_loc6_]))
               {
                  if(_loc4_ < 0)
                  {
                     _loc4_ = _loc5_ = _loc6_;
                  }
                  else if(_loc5_ - 1 == _loc6_)
                  {
                     _loc5_ = _loc6_;
                  }
                  else
                  {
                     param1.splice(_loc5_,_loc4_ - _loc5_ + 1);
                     _loc4_ = _loc5_ = _loc6_;
                  }
               }
               _loc6_--;
            }
         }
         else
         {
            _loc6_ = _loc7_ - 1;
            while(_loc6_ >= 0)
            {
               if(isNaN(param1[_loc6_][param2]))
               {
                  if(_loc4_ < 0)
                  {
                     _loc4_ = _loc5_ = _loc6_;
                  }
                  else if(_loc5_ - 1 == _loc6_)
                  {
                     _loc5_ = _loc6_;
                  }
                  else
                  {
                     param1.splice(_loc5_,_loc4_ - _loc5_ + 1);
                     _loc4_ = _loc5_ = _loc6_;
                  }
               }
               _loc6_--;
            }
         }
         if(_loc4_ >= 0)
         {
            param1.splice(_loc5_,_loc4_ - _loc5_ + 1);
         }
      }
      
      protected function invalidateData(param1:Boolean = true) : void
      {
         if(param1)
         {
            this._bDataDirty = true;
            this._bMappingDirty = true;
            this._bFilterDirty = true;
            this._bTransformDirty = true;
            invalidateProperties();
            invalidateDisplayList();
         }
         else
         {
            this._bDataDirty = false;
         }
      }
      
      protected function invalidateMapping(param1:Boolean = true) : void
      {
         if(param1)
         {
            this._bDataDirty = true;
            this._bMappingDirty = true;
            this._bFilterDirty = true;
            this._bTransformDirty = true;
            this.invalidateTransitions();
            invalidateDisplayList();
         }
         else
         {
            this._bMappingDirty = true;
         }
      }
      
      protected function invalidateFilter(param1:Boolean = true) : void
      {
         if(param1)
         {
            this._bFilterDirty = true;
            this._bTransformDirty = true;
            this.invalidateTransitions();
            invalidateDisplayList();
         }
         else
         {
            this._bFilterDirty = false;
         }
      }
      
      protected function invalidateTransform(param1:Boolean = true) : void
      {
         if(param1)
         {
            this._bTransformDirty = true;
            invalidateDisplayList();
         }
         else
         {
            this._bTransformDirty = false;
         }
      }
      
      protected function invalidateTransitions() : void
      {
         var _loc1_:ChartBase = null;
         if(this._bHideTransitionDirty == false)
         {
            this._previousTransitionData = this.renderData;
            _loc1_ = chart;
            if(_loc1_)
            {
               _loc1_.hideData();
            }
            this._bHideTransitionDirty = true;
         }
      }
      
      protected function updateData() : void
      {
         this._bDataDirty = false;
      }
      
      protected function updateMapping() : void
      {
         this._bMappingDirty = false;
      }
      
      protected function updateFilter() : void
      {
         this._bFilterDirty = false;
      }
      
      protected function updateTransform() : void
      {
         this._bTransformDirty = false;
      }
      
      protected function validateTransform() : void
      {
         if(dataTransform)
         {
            if(this._bFilterDirty)
            {
               this._selectionDirty = true;
               this.updateFilter();
            }
            if(this._bTransformDirty)
            {
               this._selectionDirty = true;
               this.updateTransform();
            }
         }
      }
      
      protected function validateData() : void
      {
         if(dataTransform)
         {
            if(this._bDataDirty)
            {
               this._selectionDirty = true;
               this.updateData();
            }
            if(this._bMappingDirty)
            {
               this._selectionDirty = true;
               this.updateMapping();
            }
         }
      }
      
      public function getRenderDataForTransition(param1:String) : Object
      {
         if(param1 == "hide")
         {
            return this._previousTransitionData;
         }
         this.validateData();
         this.validateTransform();
         return this.renderData;
      }
      
      public function getElementBounds(param1:Object) : void
      {
      }
      
      public function endInterpolation(param1:Object) : void
      {
         this.transitionRenderData = null;
      }
      
      public function beginInterpolation(param1:Object, param2:Object) : Object
      {
         return null;
      }
      
      protected function initializeInterpolationData(param1:Array, param2:Array, param3:Object, param4:Class = null, param5:Object = null) : Object
      {
         var _loc12_:ChartItem = null;
         var _loc13_:ChartItem = null;
         var _loc14_:ChartItem = null;
         var _loc15_:ChartItem = null;
         var _loc16_:ChartItem = null;
         var _loc17_:Boolean = false;
         var _loc18_:Object = null;
         var _loc19_:Object = null;
         var _loc20_:Boolean = false;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:* = null;
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         var _loc8_:int = Math.max(param1.length,param2.length);
         var _loc9_:Array = [];
         if(!param4)
         {
            param4 = Object;
         }
         var _loc10_:int = 0;
         while(_loc10_ < _loc8_)
         {
            _loc12_ = param1[_loc10_];
            _loc14_ = (_loc13_ = param2[_loc10_]) == null ? _loc12_.clone() : _loc13_.clone();
            _loc15_ = _loc12_ == null ? _loc13_.clone() : _loc12_.clone();
            _loc16_ = new param4();
            _loc17_ = false;
            _loc18_ = {};
            _loc19_ = {};
            _loc20_ = false;
            for(_loc23_ in param3)
            {
               if(_loc12_)
               {
                  _loc21_ = _loc12_[_loc23_];
               }
               else
               {
                  _loc21_ = NaN;
               }
               if(_loc13_)
               {
                  _loc22_ = _loc13_[_loc23_];
               }
               else
               {
                  _loc22_ = NaN;
               }
               if(isNaN(_loc21_) || isNaN(_loc22_))
               {
                  _loc20_ = true;
                  _loc18_[_loc23_] = _loc21_;
                  _loc19_[_loc23_] = _loc22_;
               }
               else
               {
                  _loc15_[_loc23_] = _loc21_;
                  _loc14_[_loc23_] = _loc21_;
                  _loc16_[_loc23_] = _loc22_ - _loc21_;
               }
            }
            if(_loc20_)
            {
               this.getMissingInterpolationValues(_loc18_,param1,_loc19_,param2,_loc10_,param5);
               for(_loc23_ in _loc18_)
               {
                  _loc21_ = _loc18_[_loc23_];
                  _loc15_[_loc23_] = _loc21_;
                  _loc14_[_loc23_] = _loc21_;
                  _loc16_[_loc23_] = _loc19_[_loc23_] - _loc21_;
               }
            }
            _loc9_[_loc10_] = _loc15_;
            _loc6_[_loc10_] = _loc14_;
            _loc7_[_loc10_] = _loc16_;
            _loc10_++;
         }
         return {
            "cache":_loc6_,
            "interpolationSource":_loc9_,
            "deltaCache":_loc7_,
            "properties":param3
         };
      }
      
      protected function getMissingInterpolationValues(param1:Object, param2:Array, param3:Object, param4:Array, param5:Number, param6:Object) : void
      {
      }
      
      public function interpolate(param1:Array, param2:Object) : void
      {
         this.applyInterpolation(param2,param1);
      }
      
      private function applyInterpolation(param1:Object, param2:Array) : void
      {
         var _loc9_:Number = NaN;
         var _loc10_:Object = null;
         var _loc11_:Object = null;
         var _loc12_:Object = null;
         var _loc13_:* = null;
         var _loc3_:int = param2.length;
         var _loc4_:Array = param1.interpolationSource;
         var _loc5_:Array = param1.deltaCache;
         var _loc6_:Array = param1.cache;
         var _loc7_:Object = param1.properties;
         _loc3_ = _loc6_.length;
         var _loc8_:int = 0;
         while(_loc8_ < _loc3_)
         {
            _loc9_ = param2[_loc8_];
            _loc10_ = _loc4_[_loc8_];
            _loc11_ = _loc5_[_loc8_];
            _loc12_ = _loc6_[_loc8_];
            for(_loc13_ in _loc7_)
            {
               _loc12_[_loc13_] = _loc10_[_loc13_] + _loc11_[_loc13_] * _loc9_;
            }
            _loc8_++;
         }
      }
      
      protected function legendDataChanged() : void
      {
         var _loc1_:ChartBase = chart;
         if(_loc1_)
         {
            _loc1_.legendDataChanged();
         }
      }
      
      private function findChartItemFor(param1:int) : ChartItem
      {
         var _loc2_:Array = null;
         var _loc3_:ChartItem = null;
         _loc2_ = !!this.renderData ? this.renderData.filteredCache : [];
         var _loc4_:int = _loc2_.length;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(_loc2_[_loc5_].index == param1)
            {
               _loc3_ = _loc2_[_loc5_];
               break;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      protected function defaultFilterFunction(param1:Array) : Array
      {
         return [];
      }
      
      public function getAxis(param1:String) : IAxis
      {
         return dataTransform.getAxis(param1);
      }
      
      public function setAxis(param1:String, param2:IAxis) : void
      {
         dataTransform.setAxis(param1,param2);
      }
      
      override protected function dataChanged() : void
      {
         this.invalidateData();
         super.dataChanged();
      }
      
      private function transformChangeHandler(param1:FlexEvent) : void
      {
         this.invalidateTransform();
      }
      
      protected function dragStartHandler(param1:DragEvent) : void
      {
         if(chart)
         {
            chart.dragStartHandler(param1);
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get _dataFunction() : Function
      {
         return this._604694401_dataFunction;
      }
      
      private function set _dataFunction(param1:Function) : void
      {
         var _loc2_:Object = this._604694401_dataFunction;
         if(_loc2_ !== param1)
         {
            this._604694401_dataFunction = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_dataFunction",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get _dataTipItems() : Array
      {
         return this._1502335886_dataTipItems;
      }
      
      private function set _dataTipItems(param1:Array) : void
      {
         var _loc2_:Object = this._1502335886_dataTipItems;
         if(_loc2_ !== param1)
         {
            this._1502335886_dataTipItems = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_dataTipItems",_loc2_,param1));
            }
         }
      }
   }
}
