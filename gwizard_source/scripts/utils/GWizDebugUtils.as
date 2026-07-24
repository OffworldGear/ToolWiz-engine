package utils
{
   import configinfo.GWizSettings;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.geom.Point;
   import flash.utils.describeType;
   import mx.core.UIComponent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizDebugUtils
   {
      
      private static const log:ILogger = Log.getLogger("GWizDebugUtils");
      
      private static var theTime:Date = new Date();
       
      
      public function GWizDebugUtils()
      {
         super();
      }
      
      public static function traceContainers(param1:UIComponent) : void
      {
         var _loc2_:Point = null;
         log.debug("Trace Containers: ");
         while(param1 != null)
         {
            log.debug(" " + param1 + " is a " + className(param1));
            _loc2_ = new Point(param1.x,param1.y);
            _loc2_ = param1.localToGlobal(_loc2_);
            log.debug("    localX = " + param1.x + ", localY = " + param1.y + ", globalX = " + _loc2_.x + ", globalY = " + _loc2_.y + ", width = " + param1.width + ", height = " + param1.height);
            param1 = param1.parent as UIComponent;
         }
         log.debug("*********************************************************");
      }
      
      public static function className(param1:Object) : String
      {
         var _loc2_:XML = describeType(param1);
         return _loc2_.@name.toString();
      }
      
      public static function traceObjStr(param1:Object) : String
      {
         var _loc3_:* = null;
         var _loc2_:String = "";
         for(_loc3_ in param1)
         {
            _loc2_ += _loc3_ + ":" + param1[_loc3_] + "\n";
         }
         return _loc2_;
      }
      
      public static function traceObj(param1:Object) : void
      {
         var _loc2_:String = traceObjStr(param1);
         log.debug(_loc2_);
      }
      
      public static function saveToFile(param1:String, param2:String) : void
      {
         var _loc3_:File = GWizSettings.getPrefsFile(param2);
         var _loc4_:FileStream;
         (_loc4_ = new FileStream()).open(_loc3_,FileMode.WRITE);
         _loc4_.writeUTFBytes(param1);
         _loc4_.close();
      }
      
      public static function timeIt(param1:String) : void
      {
         if(!GWizUtils.debug || !GWizSettings.TIMEIT_TRACE)
         {
            return;
         }
         var _loc2_:Date = new Date();
         var _loc3_:Number = _loc2_.time - theTime.time;
         log.debug("timeit: " + param1 + _loc3_);
         GWizUtils.LogError("timeit: " + param1 + _loc3_);
         theTime = _loc2_;
      }
      
      public static function startTimer() : Number
      {
         return 0;
      }
      
      public static function beginTimer() : Date
      {
         return new Date();
      }
      
      public static function accumTime(param1:Number, param2:Date) : Number
      {
         var _loc4_:Number = NaN;
         var _loc3_:Date = new Date();
         if(param2)
         {
            _loc4_ = _loc3_.time - param2.time;
         }
         else
         {
            _loc4_ = 0;
         }
         return param1 + _loc4_;
      }
   }
}
