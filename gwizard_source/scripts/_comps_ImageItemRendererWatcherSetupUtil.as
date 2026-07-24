package
{
   import comps.ImageItemRenderer;
   import mx.binding.FunctionReturnWatcher;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_ImageItemRendererWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_ImageItemRendererWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         ImageItemRenderer.watcherSetupUtil = new _comps_ImageItemRendererWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         var target:Object = param1;
         var propertyGetter:Function = param2;
         var staticPropertyGetter:Function = param3;
         var bindings:Array = param4;
         var watchers:Array = param5;
         watchers[0] = new PropertyWatcher("selectedFilter",{"propertyChange":true},[bindings[0],bindings[1],bindings[2],bindings[3]],propertyGetter);
         watchers[2] = new FunctionReturnWatcher("getStyle",target,function():Array
         {
            return ["rollOverColor"];
         },null,[bindings[5]],propertyGetter,true);
         watchers[1] = new FunctionReturnWatcher("getStyle",target,function():Array
         {
            return ["rollOverColor"];
         },null,[bindings[4]],propertyGetter,true);
         watchers[4] = new FunctionReturnWatcher("getStyle",target,function():Array
         {
            return ["selectionColor"];
         },null,[bindings[7]],propertyGetter,true);
         watchers[3] = new FunctionReturnWatcher("getStyle",target,function():Array
         {
            return ["selectionColor"];
         },null,[bindings[6]],propertyGetter,true);
         watchers[0].updateParent(target);
         watchers[2].updateParent(target);
         watchers[1].updateParent(target);
         watchers[4].updateParent(target);
         watchers[3].updateParent(target);
      }
   }
}
