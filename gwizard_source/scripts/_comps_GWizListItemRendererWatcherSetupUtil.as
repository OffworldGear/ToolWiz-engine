package
{
   import comps.GWizListItemRenderer;
   import mx.binding.FunctionReturnWatcher;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   
   public class _comps_GWizListItemRendererWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _comps_GWizListItemRendererWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizListItemRenderer.watcherSetupUtil = new _comps_GWizListItemRendererWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         var target:Object = param1;
         var propertyGetter:Function = param2;
         var staticPropertyGetter:Function = param3;
         var bindings:Array = param4;
         var watchers:Array = param5;
         watchers[0] = new FunctionReturnWatcher("getStyle",target,function():Array
         {
            return ["selectionColor"];
         },null,[bindings[0]],propertyGetter,true);
         watchers[1] = new PropertyWatcher("label",{"labelChanged":true},[bindings[1]],propertyGetter);
         watchers[0].updateParent(target);
         watchers[1].updateParent(target);
      }
   }
}
