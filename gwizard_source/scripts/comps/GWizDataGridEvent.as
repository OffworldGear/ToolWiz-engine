package comps
{
   import flash.events.Event;
   
   public class GWizDataGridEvent extends Event
   {
      
      public static const CONFIG_CHANGED:String = "configChanged";
       
      
      public var configId:String;
      
      public var config:GWizDataGridConfig;
      
      public function GWizDataGridEvent(param1:String, param2:String, param3:GWizDataGridConfig)
      {
         super(param1);
         this.configId = param2;
         this.config = param3;
      }
   }
}
