package mx.charts.chartClasses
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import mx.charts.LinearAxis;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class DataTransform extends EventDispatcher
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _axes:Object;
      
      private var _elements:Array;
      
      public function DataTransform()
      {
         this._axes = {};
         this._elements = [];
         super();
      }
      
      public function get axes() : Object
      {
         return this._axes;
      }
      
      public function get elements() : Array
      {
         return this._elements;
      }
      
      public function set elements(param1:Array) : void
      {
         this._elements = param1;
      }
      
      public function transformCache(param1:Array, param2:String, param3:String, param4:String, param5:String) : void
      {
      }
      
      public function invertTransform(... rest) : Array
      {
         return null;
      }
      
      public function dataChanged() : void
      {
         var _loc1_:* = null;
         for(_loc1_ in this._axes)
         {
            if(this._axes[_loc1_])
            {
               this._axes[_loc1_].dataChanged();
            }
         }
      }
      
      public function describeData(param1:String, param2:uint) : Array
      {
         var _loc6_:IChartElement = null;
         var _loc3_:Array = [];
         var _loc4_:int = this.elements.length;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(_loc6_ = this.elements[_loc5_] as IChartElement)
            {
               _loc3_ = _loc3_.concat(_loc6_.describeData(param1,param2));
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      public function getAxis(param1:String) : IAxis
      {
         var _loc2_:LinearAxis = null;
         if(!this._axes[param1])
         {
            _loc2_ = new LinearAxis();
            _loc2_.autoAdjust = false;
            this.setAxisNoEvent(param1,_loc2_);
         }
         return this._axes[param1];
      }
      
      public function setAxis(param1:String, param2:IAxis) : void
      {
         if(this.setAxisNoEvent(param1,param2))
         {
            this.mappingChangeHandler();
         }
      }
      
      private function setAxisNoEvent(param1:String, param2:IAxis) : Boolean
      {
         var _loc3_:IAxis = this._axes[param1];
         if(_loc3_ != param2)
         {
            if(_loc3_)
            {
               _loc3_.unregisterDataTransform(this);
               _loc3_.removeEventListener("mappingChange",this.mappingChangeHandler);
            }
            this._axes[param1] = param2;
            param2.registerDataTransform(this,param1);
            param2.addEventListener("mappingChange",this.mappingChangeHandler,false,0,true);
            return true;
         }
         return false;
      }
      
      private function mappingChangeHandler(param1:Event = null) : void
      {
         var _loc4_:IChartElement = null;
         var _loc2_:int = this.elements.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_loc4_ = this.elements[_loc3_] as IChartElement)
            {
               _loc4_.mappingChanged();
            }
            _loc3_++;
         }
      }
   }
}
