package spark.effects.supportClasses
{
   import mx.filters.IBitmapFilter;
   
   public class AnimateFilterInstance extends AnimateInstance
   {
       
      
      public var bitmapFilter:IBitmapFilter;
      
      public function AnimateFilterInstance(param1:Object)
      {
         super(param1);
      }
      
      override public function play() : void
      {
         var _loc1_:Array = target.filters;
         _loc1_.push(this.bitmapFilter);
         target.filters = _loc1_;
         super.play();
      }
      
      override public function finishEffect() : void
      {
         var _loc1_:Array = target.filters;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            if(_loc1_[_loc2_] == this.bitmapFilter)
            {
               _loc1_.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
         target.filters = _loc1_;
         super.finishEffect();
      }
      
      override protected function setValue(param1:String, param2:Object) : void
      {
         this.bitmapFilter[param1] = param2;
      }
      
      override protected function getCurrentValue(param1:String) : *
      {
         return this.bitmapFilter[param1];
      }
      
      override protected function setupStyleMapEntry(param1:String) : void
      {
      }
   }
}
