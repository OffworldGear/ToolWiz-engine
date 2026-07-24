package mx.charts.chartClasses
{
   import flash.geom.Rectangle;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class RenderData
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public var bounds:Rectangle;
      
      public var cache:Array;
      
      public var elementBounds:Array;
      
      public var filteredCache:Array;
      
      public var visibleRegion:Rectangle;
      
      public function RenderData(param1:Array = null, param2:Array = null)
      {
         super();
         this.cache = param1;
         this.filteredCache = param2;
      }
      
      public function get length() : uint
      {
         return !!this.cache ? uint(this.cache.length) : uint(0);
      }
      
      public function clone() : RenderData
      {
         return null;
      }
   }
}
