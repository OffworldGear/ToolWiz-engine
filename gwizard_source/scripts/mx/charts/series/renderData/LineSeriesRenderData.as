package mx.charts.series.renderData
{
   import mx.charts.chartClasses.RenderData;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class LineSeriesRenderData extends RenderData
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public var radius:Number;
      
      public var segments:Array;
      
      public var validPoints:Number;
      
      public function LineSeriesRenderData(param1:Array = null, param2:Array = null, param3:Number = 0, param4:Array = null, param5:Number = 0)
      {
         super(param1,param2);
         this.validPoints = param3;
         this.segments = param4;
         this.radius = param5;
      }
      
      override public function clone() : RenderData
      {
         var _loc1_:Array = [];
         var _loc2_:int = this.segments.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_[_loc3_] = this.segments[_loc3_].clone();
            _loc3_++;
         }
         return new LineSeriesRenderData(cache,filteredCache,this.validPoints,_loc1_,this.radius);
      }
   }
}
