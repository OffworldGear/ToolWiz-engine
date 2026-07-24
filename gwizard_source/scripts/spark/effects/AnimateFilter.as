package spark.effects
{
   import mx.core.mx_internal;
   import mx.effects.IEffectInstance;
   import mx.filters.IBitmapFilter;
   import spark.effects.supportClasses.AnimateFilterInstance;
   
   use namespace mx_internal;
   
   public class AnimateFilter extends Animate
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public var bitmapFilter:IBitmapFilter;
      
      public function AnimateFilter(param1:Object = null, param2:IBitmapFilter = null)
      {
         super(param1);
         instanceClass = AnimateFilterInstance;
         this.bitmapFilter = param2;
      }
      
      override public function getAffectedProperties() : Array
      {
         return [];
      }
      
      override protected function initInstance(param1:IEffectInstance) : void
      {
         super.initInstance(param1);
         var _loc2_:AnimateFilterInstance = param1 as AnimateFilterInstance;
         _loc2_.bitmapFilter = this.bitmapFilter;
      }
   }
}
