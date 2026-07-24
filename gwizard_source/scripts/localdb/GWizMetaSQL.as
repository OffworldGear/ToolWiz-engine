package localdb
{
   import flash.data.SQLResult;
   import flash.data.SQLStatement;
   import flash.errors.SQLError;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizMetaSQL extends GWizSQLObject
   {
      
      private static const log:ILogger = Log.getLogger("GWizMetaSQL");
      
      public static const META_TABLE:String = "tblMeta";
      
      public static var liveTables:ArrayCollection = new ArrayCollection();
       
      
      private const REQUIRED_VSN:Number = 0.2;
      
      public function GWizMetaSQL(param1:GWizLocalSQL)
      {
         tabName = META_TABLE;
         tabVersion = this.REQUIRED_VSN;
         enable = true;
         super(param1);
      }
      
      public static function openTable(param1:String, param2:GWizSQLObject) : void
      {
         var _loc3_:Object = new Object();
         _loc3_.tabName = param1;
         _loc3_.obj = param2;
         liveTables.addItem(_loc3_);
      }
      
      override public function createTbl() : Boolean
      {
         var sql:String = null;
         var retval:Boolean = false;
         var createStmt:SQLStatement = new SQLStatement();
         createStmt.sqlConnection = db.conn;
         sql = "";
         sql += "CREATE TABLE IF NOT EXISTS " + META_TABLE + " (";
         sql += "    id  \t\tINTEGER PRIMARY KEY AUTOINCREMENT,";
         sql += "\ttabName\t\tTEXT,";
         sql += "\ttabVer\t\tREAL,";
         sql += "    CONSTRAINT uc_1Key UNIQUE (tabName)";
         sql += ")";
         createStmt.text = sql;
         try
         {
            createStmt.execute();
            db.setTableVersion(tabName,tabVersion);
            retval = true;
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizMetaSQL createTbl error." + error.message + ", " + error.details);
            log.debug("CREATE TABLE error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("sql = \'" + sql + "\'");
            enable = false;
         }
         return retval;
      }
      
      override public function evolveAux(param1:Number) : Number
      {
         return this.REQUIRED_VSN;
      }
      
      public function getVersion(param1:String) : Number
      {
         var table:String = param1;
         if(!enable)
         {
            return 0;
         }
         var selectStmt:SQLStatement = new SQLStatement();
         selectStmt.sqlConnection = db.conn;
         var sql:String = "SELECT tabVer FROM " + META_TABLE + " WHERE tabName = :tabName";
         selectStmt.text = sql;
         selectStmt.parameters[":tabName"] = table;
         try
         {
            selectStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizMetaSQL getVersion error." + error.message + ", " + error.details);
            log.debug("SELECT(GWizMetaSQL) error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            enable = false;
         }
         var result:SQLResult = selectStmt.getResult();
         var retval:Number = 0;
         var metadata:Object = null;
         if(!result || !result.data || result.data.length == 0 || !enable)
         {
            retval = 0;
         }
         else
         {
            if(result.data.length != 1)
            {
               GWizUtils.LogError("Incorrect entries in GWizMetaSQL for " + table + ", length = " + result.data.length);
            }
            metadata = result.data[result.data.length - 1];
            retval = metadata.tabVer;
         }
         return retval;
      }
      
      public function setVersion(param1:String, param2:Number) : Boolean
      {
         if(!enable)
         {
            return false;
         }
         if(this.getVersion(param1) == 0)
         {
            enable = this.insertEntry(param1,param2);
         }
         else
         {
            enable = this.updateEntry(param1,param2);
         }
         return enable;
      }
      
      public function insertEntry(param1:String, param2:Number) : Boolean
      {
         var tabName:String = param1;
         var tabVer:Number = param2;
         if(!enable)
         {
            return false;
         }
         var insertStmt:SQLStatement = new SQLStatement();
         insertStmt.sqlConnection = db.conn;
         var sql:String = "";
         sql += "INSERT OR REPLACE INTO " + META_TABLE + " (tabName, tabVer) ";
         sql += "VALUES (:tabName, :tabVer)";
         insertStmt.text = sql;
         insertStmt.parameters[":tabName"] = tabName;
         insertStmt.parameters[":tabVer"] = tabVer;
         try
         {
            insertStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizMetaSQL insertEntry error." + error.message + ", " + error.details);
            log.debug("INSERT error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            enable = false;
         }
         return enable;
      }
      
      public function updateEntry(param1:String, param2:Number) : Boolean
      {
         var sql:String = null;
         var tabName:String = param1;
         var tabVer:Number = param2;
         if(!enable)
         {
            return false;
         }
         var updateStmt:SQLStatement = new SQLStatement();
         updateStmt.sqlConnection = db.conn;
         sql = "";
         sql += "UPDATE " + META_TABLE + " SET tabVer = :tabVer";
         sql += " WHERE tabName = :tabName";
         updateStmt.text = sql;
         updateStmt.parameters[":tabName"] = tabName;
         updateStmt.parameters[":tabVer"] = tabVer;
         try
         {
            updateStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizMetaSQL updateEntry error." + error.message + ", " + error.details);
            log.debug("UPDATE error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("sql = \'" + sql + "\'");
            enable = false;
         }
         return enable;
      }
      
      override public function dumpRow(param1:Object) : void
      {
         log.debug("id: " + param1.id + " " + "tabName: \'" + param1.tabName + "\' " + "tabVer: " + param1.tabVer);
      }
   }
}
