package threads2
{
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizThreadDataItem
   {
      
      private static const log:ILogger = Log.getLogger("GWizThreadDataItem");
       
      
      public var label:String;
      
      public var _value:String;
      
      public var _mmvalue:String;
      
      public var checkUnits:Boolean;
      
      public function GWizThreadDataItem()
      {
         super();
      }
      
      public function get value() : String
      {
         return this._value;
      }
      
      public function set value(param1:String) : void
      {
         this._value = param1;
         if(GWizUtils.debug)
         {
            if(this.label == "Family")
            {
               log.debug("Set Family value to " + param1);
               if(param1 == "0.001")
               {
                  log.debug("gotcha");
               }
            }
         }
      }
      
      public function get mmvalue() : String
      {
         return this._mmvalue;
      }
      
      public function set mmvalue(param1:String) : void
      {
         this._mmvalue = param1;
         if(GWizUtils.debug)
         {
            if(this.label == "Family")
            {
               log.debug("Set Family mmvalue to " + param1);
               if(param1 == "0.001")
               {
                  log.debug("gotcha");
               }
            }
         }
      }
      
      public function bozon() : void
      {
         log.debug("Bozon");
      }
   }
}
