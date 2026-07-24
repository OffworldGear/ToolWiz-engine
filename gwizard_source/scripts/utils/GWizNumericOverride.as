package utils
{
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizNumericOverride
   {
      
      private static const log:ILogger = Log.getLogger("GWizNumericOverride");
       
      
      public var name:String = "";
      
      private var privateValue:Number = NaN;
      
      private var useOverride:Boolean = false;
      
      public var lowerLimit:Number = NaN;
      
      public function GWizNumericOverride(param1:Object = null)
      {
         super();
         if(param1)
         {
            this.privateValue = Number(param1);
         }
      }
      
      public function setOverVal(param1:Number, param2:Boolean) : void
      {
         this.privateValue = param1;
         this.useOverride = param2;
      }
      
      public function get value() : Number
      {
         return this.privateValue;
      }
      
      public function set value(param1:Number) : void
      {
         if(false && GWizUtils.DoNotShip && this.name == "fsm.rpm")
         {
            log.debug("fsm.rpm set to " + param1);
         }
         if(!this.useOverride)
         {
            this.privateValue = param1;
         }
      }
      
      public function isOverridden() : Boolean
      {
         return this.useOverride;
      }
   }
}
