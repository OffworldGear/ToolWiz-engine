package mx.charts
{
   import flash.events.Event;
   import mx.charts.chartClasses.AxisBase;
   import mx.charts.chartClasses.AxisLabelSet;
   import mx.charts.chartClasses.IAxis;
   import mx.collections.ArrayCollection;
   import mx.collections.CursorBookmark;
   import mx.collections.ICollectionView;
   import mx.collections.IViewCursor;
   import mx.collections.XMLListCollection;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.PropertyChangeEvent;
   
   use namespace mx_internal;
   
   public class CategoryAxis extends AxisBase implements IAxis
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _cursor:IViewCursor;
      
      private var _catMap:Object;
      
      private var _categoryValues:Array;
      
      private var _labelsMatchToCategoryValuesByIndex:Array;
      
      private var _cachedMinorTicks:Array = null;
      
      private var _cachedTicks:Array = null;
      
      private var _labelSet:AxisLabelSet;
      
      private var _chartDataProvider:Object;
      
      private var _categoryField:String = "";
      
      private var _604694401_dataFunction:Function = null;
      
      private var _dataProvider:ICollectionView;
      
      private var _userDataProvider:Object;
      
      private var _labelFunction:Function = null;
      
      private var _padding:Number = 0.5;
      
      private var _ticksBetweenLabels:Boolean = true;
      
      public function CategoryAxis()
      {
         super();
         this.workingDataProvider = new ArrayCollection();
      }
      
      override public function set chartDataProvider(param1:Object) : void
      {
         if(this._chartDataProvider != param1)
         {
            this._chartDataProvider = param1;
            if(!this._userDataProvider)
            {
               this.workingDataProvider = this._chartDataProvider;
            }
         }
      }
      
      public function get baseline() : Number
      {
         return -this._padding;
      }
      
      public function get categoryField() : String
      {
         return this._categoryField;
      }
      
      public function set categoryField(param1:String) : void
      {
         this._categoryField = param1;
         this.collectionChangeHandler();
      }
      
      public function get dataFunction() : Function
      {
         return this._dataFunction;
      }
      
      public function set dataFunction(param1:Function) : void
      {
         this._dataFunction = param1;
         this.collectionChangeHandler();
      }
      
      public function get dataProvider() : Object
      {
         return this._dataProvider;
      }
      
      public function set dataProvider(param1:Object) : void
      {
         this._userDataProvider = param1;
         if(this._userDataProvider != null)
         {
            this.workingDataProvider = this._userDataProvider;
         }
         else
         {
            this.workingDataProvider = this._chartDataProvider;
         }
      }
      
      public function get labelFunction() : Function
      {
         return this._labelFunction;
      }
      
      public function set labelFunction(param1:Function) : void
      {
         this._labelFunction = param1;
         this.invalidateCategories();
      }
      
      private function get minorTicks() : Array
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(!this._cachedMinorTicks)
         {
            this._cachedMinorTicks = [];
            if(this._ticksBetweenLabels == false)
            {
               _loc1_ = this._categoryValues.length;
               _loc2_ = -this._padding;
               _loc3_ = _loc1_ - 1 + this._padding;
               _loc4_ = _loc3_ - _loc2_;
               _loc6_ = _loc2_ <= -0.5 ? Number(0) : Number(1);
               _loc7_ = _loc3_ >= _loc1_ - 0.5 ? Number(_loc1_) : Number(_loc1_ - 1);
               _loc5_ = _loc6_;
               while(_loc5_ <= _loc7_)
               {
                  this._cachedMinorTicks.push((_loc5_ - 0.5 - _loc2_) / _loc4_);
                  _loc5_++;
               }
            }
            else
            {
               _loc1_ = this._categoryValues.length;
               _loc2_ = -this._padding;
               _loc3_ = _loc1_ - 1 + this._padding;
               _loc4_ = _loc3_ - _loc2_;
               _loc5_ = 0;
               while(_loc5_ < _loc1_)
               {
                  this._cachedMinorTicks.push((_loc5_ - _loc2_) / _loc4_);
                  _loc5_++;
               }
            }
         }
         return this._cachedMinorTicks;
      }
      
      public function get padding() : Number
      {
         return this._padding;
      }
      
      public function set padding(param1:Number) : void
      {
         this._padding = param1;
         this.invalidateCategories();
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      public function get ticksBetweenLabels() : Boolean
      {
         return this._ticksBetweenLabels;
      }
      
      public function set ticksBetweenLabels(param1:Boolean) : void
      {
         this._ticksBetweenLabels = param1;
      }
      
      private function set workingDataProvider(param1:Object) : void
      {
         if(this._dataProvider != null)
         {
            this._dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler);
         }
         if(param1 is Array)
         {
            param1 = new ArrayCollection(param1 as Array);
         }
         else if(!(param1 is ICollectionView))
         {
            if(param1 is XMLList)
            {
               param1 = new XMLListCollection(XMLList(param1));
            }
            else if(param1 != null)
            {
               param1 = new ArrayCollection([param1]);
            }
            else
            {
               param1 = new ArrayCollection();
            }
         }
         this._dataProvider = ICollectionView(param1);
         this._cursor = param1.createCursor();
         if(this._dataProvider)
         {
            this._dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,0,true);
         }
         this.collectionChangeHandler();
      }
      
      public function mapCache(param1:Array, param2:String, param3:String, param4:Boolean = false) : void
      {
         var _loc8_:Object = null;
         this.update();
         var _loc5_:int = param1.length;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            if(param1[_loc6_][param2] != null)
            {
               break;
            }
            _loc6_++;
         }
         if(_loc6_ == _loc5_)
         {
            return;
         }
         var _loc7_:Object;
         if((_loc7_ = param1[_loc6_][param2]) is XML || _loc7_ is XMLList)
         {
            while(_loc6_ < _loc5_)
            {
               param1[_loc6_][param3] = this._catMap[param1[_loc6_][param2].toString()];
               _loc6_++;
            }
         }
         else if((_loc7_ is Number || _loc7_ is int || _loc7_ is uint) && param4 == true)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               (_loc8_ = param1[_loc6_])[param3] = _loc8_[param2];
               _loc6_++;
            }
         }
         else
         {
            while(_loc6_ < _loc5_)
            {
               param1[_loc6_][param3] = this._catMap[param1[_loc6_][param2]];
               _loc6_++;
            }
         }
      }
      
      public function filterCache(param1:Array, param2:String, param3:String) : void
      {
         var _loc8_:Number = NaN;
         this.update();
         var _loc4_:Number = this._categoryValues.length - 1 + this._padding + 0.000001;
         var _loc5_:Number = -this._padding - 0.000001;
         var _loc6_:int = param1.length;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = param1[_loc7_][param2];
            param1[_loc7_][param3] = _loc8_ >= _loc5_ && _loc8_ < _loc4_ ? _loc8_ : NaN;
            _loc7_++;
         }
      }
      
      public function transformCache(param1:Array, param2:String, param3:String) : void
      {
         this.update();
         var _loc4_:Number = -this._padding;
         var _loc5_:Number;
         var _loc6_:Number = (_loc5_ = this._categoryValues.length - 1 + this._padding) - _loc4_;
         var _loc7_:int = param1.length;
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            param1[_loc8_][param3] = (param1[_loc8_][param2] - _loc4_) / _loc6_;
            _loc8_++;
         }
      }
      
      public function invertTransform(param1:Number) : Object
      {
         this.update();
         var _loc2_:Number = -this._padding;
         var _loc3_:Number = this._categoryValues.length - 1 + this._padding;
         var _loc4_:Number = _loc3_ - _loc2_;
         return this._categoryValues[Math.round(param1 * _loc4_ + _loc2_)];
      }
      
      public function formatForScreen(param1:Object) : String
      {
         var _loc2_:Object = null;
         if(param1 is Number && param1 < this._categoryValues.length)
         {
            _loc2_ = this._categoryValues[Math.round(Number(param1))];
            return _loc2_ == null ? param1.toString() : _loc2_.toString();
         }
         return param1.toString();
      }
      
      public function getLabelEstimate() : AxisLabelSet
      {
         this.update();
         return this._labelSet;
      }
      
      public function preferDropLabels() : Boolean
      {
         return false;
      }
      
      public function getLabels(param1:Number) : AxisLabelSet
      {
         this.update();
         return this._labelSet;
      }
      
      public function reduceLabels(param1:AxisLabel, param2:AxisLabel) : AxisLabelSet
      {
         var _loc3_:int = this._catMap[param2.value] - this._catMap[param1.value] + 1;
         if(_loc3_ <= 0)
         {
            return null;
         }
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc6_:Number = -this._padding;
         var _loc7_:Number;
         var _loc8_:Number = (_loc7_ = this._categoryValues.length - 1 + this._padding) - _loc6_;
         var _loc9_:int = this._categoryValues.length;
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_)
         {
            _loc4_.push(this._labelsMatchToCategoryValuesByIndex[_loc10_]);
            _loc5_.push(this._labelsMatchToCategoryValuesByIndex[_loc10_].position);
            _loc10_ += _loc3_;
         }
         var _loc11_:AxisLabelSet;
         (_loc11_ = new AxisLabelSet()).labels = _loc4_;
         _loc11_.minorTicks = this.minorTicks;
         _loc11_.ticks = this.generateTicks();
         return _loc11_;
      }
      
      public function update() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:AxisLabel = null;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         if(!this._labelSet)
         {
            this._catMap = {};
            this._categoryValues = [];
            this._labelsMatchToCategoryValuesByIndex = [];
            _loc2_ = [];
            if(this._dataFunction != null)
            {
               this._cursor.seek(CursorBookmark.FIRST);
               _loc3_ = 0;
               while(!this._cursor.afterLast)
               {
                  _loc2_[_loc3_] = this._cursor.current;
                  _loc1_ = this.dataFunction(this,_loc2_[_loc3_]);
                  if(_loc1_)
                  {
                     this._catMap[_loc1_.toString()] = _loc3_;
                  }
                  this._categoryValues[_loc3_] = _loc1_;
                  _loc3_++;
                  this._cursor.moveNext();
               }
            }
            else if(this._categoryField == "")
            {
               this._cursor.seek(CursorBookmark.FIRST);
               _loc3_ = 0;
               while(!this._cursor.afterLast)
               {
                  _loc1_ = this._cursor.current;
                  if(_loc1_ != null)
                  {
                     this._catMap[_loc1_.toString()] = _loc3_;
                  }
                  this._categoryValues[_loc3_] = _loc2_[_loc3_] = _loc1_;
                  this._cursor.moveNext();
                  _loc3_++;
               }
            }
            else
            {
               this._cursor.seek(CursorBookmark.FIRST);
               _loc3_ = 0;
               while(!this._cursor.afterLast)
               {
                  _loc2_[_loc3_] = this._cursor.current;
                  if(_loc2_[_loc3_] && this._categoryField in _loc2_[_loc3_])
                  {
                     _loc1_ = _loc2_[_loc3_][this._categoryField];
                     if(_loc1_ != null)
                     {
                        this._catMap[_loc1_.toString()] = _loc3_;
                     }
                     this._categoryValues[_loc3_] = _loc1_;
                  }
                  else
                  {
                     this._categoryValues[_loc3_] = null;
                  }
                  _loc3_++;
                  this._cursor.moveNext();
               }
            }
            _loc4_ = [];
            _loc5_ = -this._padding;
            _loc7_ = (_loc6_ = this._categoryValues.length - 1 + this._padding) - _loc5_;
            _loc9_ = this._categoryValues.length;
            if(this._labelFunction != null)
            {
               _loc10_ = null;
               _loc3_ = 0;
               while(_loc3_ < _loc9_)
               {
                  if(this._categoryValues[_loc3_] != null)
                  {
                     _loc8_ = new AxisLabel((_loc3_ - _loc5_) / _loc7_,this._categoryValues[_loc3_],this._labelFunction(this._categoryValues[_loc3_],_loc10_,this,_loc2_[_loc3_]));
                     this._labelsMatchToCategoryValuesByIndex[_loc3_] = _loc8_;
                     _loc4_.push(_loc8_);
                     _loc10_ = this._categoryValues[_loc3_];
                  }
                  _loc3_++;
               }
            }
            else
            {
               _loc3_ = 0;
               while(_loc3_ < _loc9_)
               {
                  if(this._categoryValues[_loc3_])
                  {
                     _loc8_ = new AxisLabel((_loc3_ - _loc5_) / _loc7_,this._categoryValues[_loc3_],this._categoryValues[_loc3_].toString());
                     this._labelsMatchToCategoryValuesByIndex[_loc3_] = _loc8_;
                     _loc4_.push(_loc8_);
                  }
                  _loc3_++;
               }
            }
            this._labelSet = new AxisLabelSet();
            this._labelSet.labels = _loc4_;
            this._labelSet.accurate = true;
            this._labelSet.minorTicks = this.minorTicks;
            this._labelSet.ticks = this.generateTicks();
         }
      }
      
      private function generateTicks() : Array
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(!this._cachedTicks)
         {
            this._cachedTicks = [];
            if(this._ticksBetweenLabels == false)
            {
               _loc1_ = this._categoryValues.length;
               _loc2_ = -this._padding;
               _loc3_ = _loc1_ - 1 + this._padding;
               _loc4_ = _loc3_ - _loc2_;
               _loc5_ = 0;
               while(_loc5_ < _loc1_)
               {
                  this._cachedTicks.push((_loc5_ - _loc2_) / _loc4_);
                  _loc5_++;
               }
            }
            else
            {
               this._cachedMinorTicks = [];
               _loc1_ = this._categoryValues.length;
               _loc2_ = -this._padding;
               _loc3_ = _loc1_ - 1 + this._padding;
               _loc4_ = _loc3_ - _loc2_;
               _loc6_ = this._padding < 0.5 ? Number(0.5) : Number(-0.5);
               _loc7_ = this._padding < 0.5 ? Number(_loc1_ - 1.5) : Number(_loc1_ - 0.5);
               _loc5_ = _loc6_;
               while(_loc5_ <= _loc7_)
               {
                  this._cachedTicks.push((_loc5_ - _loc2_) / _loc4_);
                  _loc5_ += 1;
               }
            }
         }
         return this._cachedTicks;
      }
      
      private function invalidateCategories() : void
      {
         this._labelSet = null;
         this._cachedMinorTicks = null;
         this._cachedTicks = null;
         dispatchEvent(new Event("mappingChange"));
         dispatchEvent(new Event("axisChange"));
      }
      
      mx_internal function getCategoryValues() : Array
      {
         return this._categoryValues;
      }
      
      private function collectionChangeHandler(param1:CollectionEvent = null) : void
      {
         if(param1 && param1.kind == CollectionEventKind.RESET)
         {
            this._cursor = this._dataProvider.createCursor();
         }
         this.invalidateCategories();
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
   }
}
