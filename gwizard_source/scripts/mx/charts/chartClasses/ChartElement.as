package mx.charts.chartClasses
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Point;
   import mx.collections.ArrayCollection;
   import mx.collections.ICollectionView;
   import mx.collections.IList;
   import mx.collections.IViewCursor;
   import mx.collections.ListCollectionView;
   import mx.collections.XMLListCollection;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   
   use namespace mx_internal;
   
   public class ChartElement extends DualStyleObject implements IChartElement2
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static var nextID:uint = 0;
       
      
      private var _userDataProvider:Object;
      
      private var _glyphID:uint;
      
      protected var cursor:IViewCursor;
      
      private var _dataProvider:ICollectionView;
      
      private var _dataTransform:DataTransform;
      
      public function ChartElement()
      {
         super();
         this._glyphID = generateGlyphID();
      }
      
      private static function generateGlyphID() : uint
      {
         return nextID++;
      }
      
      protected function get chart() : ChartBase
      {
         var _loc1_:DisplayObject = parent;
         while(!(_loc1_ is ChartBase) && _loc1_)
         {
            _loc1_ = _loc1_.parent;
         }
         return _loc1_ as ChartBase;
      }
      
      public function set chartDataProvider(param1:Object) : void
      {
         if(this._userDataProvider == null)
         {
            this.processNewDataProvider(param1);
         }
      }
      
      public function get dataProvider() : Object
      {
         return this._dataProvider;
      }
      
      public function set dataProvider(param1:Object) : void
      {
         if(this._userDataProvider == param1)
         {
            return;
         }
         this._userDataProvider = param1;
         this.processNewDataProvider(param1);
      }
      
      public function get dataTransform() : DataTransform
      {
         return this._dataTransform;
      }
      
      public function set dataTransform(param1:DataTransform) : void
      {
         var _loc4_:DisplayObject = null;
         this._dataTransform = param1;
         var _loc2_:int = numChildren;
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = getChildAt(_loc3_);
            if(this._dataTransform && _loc4_ is IChartElement)
            {
               IChartElement(_loc4_).dataTransform = this._dataTransform;
            }
            _loc3_++;
         }
         if(this._dataTransform)
         {
            this._dataTransform.dataChanged();
         }
         invalidateDisplayList();
      }
      
      public function get labelContainer() : Sprite
      {
         return null;
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         super.addChild(param1);
         if(this._dataTransform && param1 is IChartElement)
         {
            IChartElement(param1).dataTransform = this._dataTransform;
         }
         return param1;
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         super.addChildAt(param1,param2);
         if(this._dataTransform && param1 is IChartElement)
         {
            IChartElement(param1).dataTransform = this._dataTransform;
         }
         return param1;
      }
      
      protected function processNewDataProvider(param1:Object) : void
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
            if(param1 is IList)
            {
               param1 = new ListCollectionView(IList(param1));
            }
            else if(param1 is XMLList)
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
         this.cursor = this._dataProvider.createCursor();
         if(this._dataProvider != null)
         {
            this._dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,0,true);
         }
         this.dataChanged();
      }
      
      public function mappingChanged() : void
      {
      }
      
      protected function dataChanged() : void
      {
         invalidateDisplayList();
         if(this._dataTransform)
         {
            this._dataTransform.dataChanged();
         }
      }
      
      public function findDataPoints(param1:Number, param2:Number, param3:Number) : Array
      {
         var _loc7_:IChartElement = null;
         var _loc8_:Array = null;
         var _loc4_:Array = [];
         var _loc5_:int;
         var _loc6_:int = (_loc5_ = numChildren) - 1;
         while(_loc6_ >= 0)
         {
            if(!(!(_loc7_ = getChildAt(_loc6_) as IChartElement) || _loc7_.visible == false))
            {
               if((_loc8_ = _loc7_.findDataPoints(param1,param2,param3)).length != 0)
               {
                  _loc4_ = _loc4_.concat(_loc8_);
               }
            }
            _loc6_--;
         }
         return _loc4_;
      }
      
      public function getAllDataPoints() : Array
      {
         var _loc4_:IChartElement2 = null;
         var _loc5_:Array = null;
         var _loc1_:Array = [];
         var _loc2_:int = numChildren;
         var _loc3_:int = _loc2_ - 1;
         while(_loc3_ >= 0)
         {
            if(!(!(_loc4_ = getChildAt(_loc3_) as IChartElement2) || _loc4_.visible == false))
            {
               if((_loc5_ = _loc4_.getAllDataPoints()).length != 0)
               {
                  _loc1_ = _loc1_.concat(_loc5_);
               }
            }
            _loc3_--;
         }
         return _loc1_;
      }
      
      protected function createDataID(param1:Number) : Number
      {
         return (this._glyphID << 16) + param1;
      }
      
      public function describeData(param1:String, param2:uint) : Array
      {
         return [];
      }
      
      public function chartStateChanged(param1:uint, param2:uint) : void
      {
         var _loc5_:IChartElement = null;
         var _loc3_:int = numChildren;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc5_ = getChildAt(_loc4_) as IChartElement)
            {
               _loc5_.chartStateChanged(param1,param2);
            }
            _loc4_++;
         }
      }
      
      public function collectTransitions(param1:Number, param2:Array) : void
      {
         var _loc5_:IChartElement = null;
         var _loc3_:int = numChildren;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc5_ = getChildAt(_loc4_) as IChartElement)
            {
               _loc5_.collectTransitions(param1,param2);
            }
            _loc4_++;
         }
      }
      
      public function claimStyles(param1:Array, param2:uint) : uint
      {
         return param2;
      }
      
      public function dataToLocal(... rest) : Point
      {
         return null;
      }
      
      public function localToData(param1:Point) : Array
      {
         return null;
      }
      
      private function collectionChangeHandler(param1:CollectionEvent = null) : void
      {
         if(param1 && param1.kind == CollectionEventKind.RESET)
         {
            this.cursor = this._dataProvider.createCursor();
         }
         this.dataChanged();
      }
   }
}
