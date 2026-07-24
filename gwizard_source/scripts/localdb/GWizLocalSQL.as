package localdb
{
   import configinfo.GWizSettings;
   import flash.data.SQLConnection;
   import flash.errors.SQLError;
   import flash.filesystem.File;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizLocalSQL
   {
      
      private static const log:ILogger = Log.getLogger("GWizLocalSQL");
       
      
      public var conn:SQLConnection;
      
      public var enable:Boolean = true;
      
      private var dbFile:File;
      
      private var tblMeta:GWizMetaSQL = null;
      
      public function GWizLocalSQL()
      {
         this.conn = new SQLConnection();
         this.dbFile = GWizSettings.getPrefsFile("GWizard.db");
         super();
         if(!this.enable)
         {
            return;
         }
         try
         {
            this.conn.open(this.dbFile);
            this.tblMeta = new GWizMetaSQL(this);
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("Error creating local SQL database. " + error.message + ", " + error.details);
            log.debug("Error creating local SQL database.");
            log.debug("Error message:",error.message);
            log.debug("Details:",error.details);
         }
      }
      
      public function getTableVersion(param1:String) : Number
      {
         if(this.tblMeta)
         {
            return this.tblMeta.getVersion(param1);
         }
         return 0;
      }
      
      public function setTableVersion(param1:String, param2:Number) : Boolean
      {
         if(!this.tblMeta)
         {
            return true;
         }
         return this.tblMeta.setVersion(param1,param2);
      }
   }
}
