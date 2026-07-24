package comps
{
   import flash.events.Event;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.gridClasses.GridColumn;
   
   public class GWizGridColumn extends GridColumn
   {
      
      private static const log:ILogger = Log.getLogger("GWizGridColumn");
       
      
      public var parentGrid:GWizDataGrid;
      
      private var _configId:String;
      
      public function GWizGridColumn(param1:String = null)
      {
         super(param1);
         addEventListener("widthChanged",this.handleWidthChange);
      }
      
      private function handleWidthChange(param1:Event) : void
      {
         if(this.parentGrid == null)
         {
            return;
         }
         GWizDataGridConfigs.getInstance().updateConfig(this.parentGrid);
      }
      
      public function get configId() : String
      {
         return this._configId;
      }
      
      public function set configId(param1:String) : void
      {
         this._configId = param1;
      }
   }
}
