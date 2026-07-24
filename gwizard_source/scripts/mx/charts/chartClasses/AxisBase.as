package mx.charts.chartClasses
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import mx.charts.ChartItem;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class AxisBase extends EventDispatcher
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      protected var _transforms:Array;
      
      private var _displayName:String = "";
      
      private var _title:String = "";
      
      public function AxisBase()
      {
         this._transforms = [];
         super();
      }
      
      public function set chartDataProvider(param1:Object) : void
      {
      }
      
      public function get displayName() : String
      {
         return this._displayName;
      }
      
      public function set displayName(param1:String) : void
      {
         this._displayName = param1;
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function set title(param1:String) : void
      {
         dispatchEvent(new Event("titleChange"));
         this._title = param1;
      }
      
      public function get unitSize() : Number
      {
         return 1;
      }
      
      protected function describeData(param1:uint) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:int = this._transforms.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = _loc2_.concat(this._transforms[_loc4_].transform.describeData(this._transforms[_loc4_].dimension,param1));
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function registerDataTransform(param1:DataTransform, param2:String) : void
      {
         this._transforms.push({
            "transform":param1,
            "dimension":param2
         });
         this.dataChanged();
      }
      
      public function unregisterDataTransform(param1:DataTransform) : void
      {
         var _loc2_:int = this._transforms.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._transforms[_loc3_].transform == param1)
            {
               this._transforms.splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
         this.dataChanged();
      }
      
      public function dataChanged() : void
      {
      }
      
      mx_internal function highlightElements(param1:Boolean) : void
      {
         var _loc2_:Array = [];
         var _loc3_:int = this._transforms.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = _loc2_.concat(this._transforms[_loc4_].transform.elements);
            _loc4_++;
         }
         if(param1)
         {
            _loc3_ = _loc2_.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(_loc2_[_loc4_] is Series)
               {
                  Series(_loc2_[_loc4_]).setItemsState(ChartItem.ROLLOVER);
               }
               _loc4_++;
            }
         }
         else
         {
            _loc3_ = _loc2_.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(_loc2_[_loc4_] is Series)
               {
                  if(_loc2_[_loc4_].getChartSelectedStatus() == false)
                  {
                     _loc2_[_loc4_].setItemsState(ChartItem.NONE);
                  }
                  else if(_loc2_[_loc4_].selectedItems.length == 0)
                  {
                     _loc2_[_loc4_].setItemsState(ChartItem.DISABLED);
                  }
                  else
                  {
                     Series(_loc2_[_loc4_]).selectedItems = _loc2_[_loc4_].selectedItems;
                  }
               }
               _loc4_++;
            }
         }
      }
   }
}
