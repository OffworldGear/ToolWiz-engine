package mx.binding.utils
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class BindingUtils
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function BindingUtils()
      {
         super();
      }
      
      public static function bindProperty(param1:Object, param2:String, param3:Object, param4:Object, param5:Boolean = false, param6:Boolean = false) : ChangeWatcher
      {
         var w:ChangeWatcher = null;
         var assign:Function = null;
         var site:Object = param1;
         var prop:String = param2;
         var host:Object = param3;
         var chain:Object = param4;
         var commitOnly:Boolean = param5;
         var useWeakReference:Boolean = param6;
         w = ChangeWatcher.watch(host,chain,null,commitOnly,useWeakReference);
         if(w != null)
         {
            assign = function(param1:*):void
            {
               site[prop] = w.getValue();
            };
            w.setHandler(assign);
            assign(null);
         }
         return w;
      }
      
      public static function bindSetter(param1:Function, param2:Object, param3:Object, param4:Boolean = false, param5:Boolean = false) : ChangeWatcher
      {
         var w:ChangeWatcher = null;
         var invoke:Function = null;
         var setter:Function = param1;
         var host:Object = param2;
         var chain:Object = param3;
         var commitOnly:Boolean = param4;
         var useWeakReference:Boolean = param5;
         w = ChangeWatcher.watch(host,chain,null,commitOnly,useWeakReference);
         if(w != null)
         {
            invoke = function(param1:*):void
            {
               setter(w.getValue());
            };
            w.setHandler(invoke);
            invoke(null);
         }
         return w;
      }
   }
}
