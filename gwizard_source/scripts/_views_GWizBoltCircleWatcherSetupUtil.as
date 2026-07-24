package
{
   import mx.binding.FunctionReturnWatcher;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import views.GWizBoltCircle;
   
   public class _views_GWizBoltCircleWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizBoltCircleWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizBoltCircle.watcherSetupUtil = new _views_GWizBoltCircleWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         var target:Object = param1;
         var propertyGetter:Function = param2;
         var staticPropertyGetter:Function = param3;
         var bindings:Array = param4;
         var watchers:Array = param5;
         watchers[1] = new PropertyWatcher("gridArea",{"propertyChange":true},[bindings[1],bindings[2],bindings[3],bindings[4],bindings[5],bindings[6],bindings[7],bindings[8],bindings[9]],propertyGetter);
         watchers[3] = new PropertyWatcher("yOrigin",{"propertyChange":true},[bindings[3],bindings[5],bindings[7],bindings[9]],null);
         watchers[2] = new PropertyWatcher("xOrigin",{"propertyChange":true},[bindings[1],bindings[2],bindings[4],bindings[6],bindings[8]],null);
         watchers[4] = new PropertyWatcher("yMax",{"propertyChange":true},[bindings[3]],null);
         watchers[11] = new FunctionReturnWatcher("getStyle",target,function():Array
         {
            return ["backgroundColor"];
         },null,[bindings[13]],propertyGetter,true);
         watchers[5] = new PropertyWatcher("Clear",{"propertyChange":true},[bindings[10],bindings[11]],propertyGetter);
         watchers[7] = new PropertyWatcher("height",{"heightChanged":true},[bindings[10]],null);
         watchers[8] = new PropertyWatcher("width",{"widthChanged":true},[bindings[11]],null);
         watchers[9] = new PropertyWatcher("holeArray",{"propertyChange":true},[bindings[12]],propertyGetter);
         watchers[1].updateParent(target);
         watchers[1].addChild(watchers[3]);
         watchers[1].addChild(watchers[2]);
         watchers[1].addChild(watchers[4]);
         watchers[11].updateParent(target);
         watchers[5].updateParent(target);
         watchers[5].addChild(watchers[7]);
         watchers[5].addChild(watchers[8]);
         watchers[9].updateParent(target);
      }
   }
}
