package spark.filters
{
   import flash.filters.BitmapFilter;
   import flash.filters.ColorMatrixFilter;
   import mx.filters.BaseFilter;
   import mx.filters.IBitmapFilter;
   
   public class ColorMatrixFilter extends BaseFilter implements IBitmapFilter
   {
       
      
      private var _matrix:Array;
      
      public function ColorMatrixFilter(param1:Array = null)
      {
         this._matrix = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
         super();
         if(param1 != null)
         {
            this.matrix = param1;
         }
      }
      
      public function get matrix() : Object
      {
         return this._matrix;
      }
      
      public function set matrix(param1:Object) : void
      {
         if(param1 != this._matrix)
         {
            if(param1 is Array)
            {
               this._matrix = param1 as Array;
            }
            else if(param1 is String)
            {
               this._matrix = String(param1).split(",");
            }
            notifyFilterChanged();
         }
      }
      
      public function clone() : BitmapFilter
      {
         return new flash.filters.ColorMatrixFilter(this._matrix);
      }
   }
}
