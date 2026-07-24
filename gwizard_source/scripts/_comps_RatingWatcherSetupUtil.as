package
{
   import comps.Rating;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_RatingWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_RatingWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         Rating.watcherSetupUtil = new _comps_RatingWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
      }
   }
}
