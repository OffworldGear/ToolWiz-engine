package localdb
{
   import flash.data.SQLResult;
   import flash.data.SQLStatement;
   import flash.errors.SQLError;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizSQLObject
   {
      
      private static const log:ILogger = Log.getLogger("GWizSQLObject");
       
      
      protected var enable:Boolean;
      
      protected var tabName:String;
      
      protected var tabVersion:Number = 0.0;
      
      protected var db:GWizLocalSQL = null;
      
      public function GWizSQLObject(param1:GWizLocalSQL)
      {
         var database:GWizLocalSQL = param1;
         super();
         if(!database)
         {
            this.enable = false;
            GWizUtils.LogErrorContext = "GWizSQLObject.GWizSQLObject";
            GWizUtils.LogError("Database is null.");
            return;
         }
         this.db = database;
         this.enable = this.enable && this.db.enable;
         try
         {
            if(this.enable)
            {
               this.enable = this.evolveTbl(this.tabVersion);
            }
            if(this.enable)
            {
               GWizMetaSQL.openTable(this.tabName,this);
            }
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizSQLObject constructor error.");
            log.debug("Error message:",error.message);
            log.debug("Details:",error.details);
         }
      }
      
      public function createTbl() : Boolean
      {
         return this.enable;
      }
      
      public function dropTbl() : Boolean
      {
         var sql:String = null;
         if(!this.enable)
         {
            return this.enable;
         }
         var dropStmt:SQLStatement = new SQLStatement();
         dropStmt.sqlConnection = this.db.conn;
         sql = "";
         sql += "DROP TABLE IF EXISTS " + this.tabName;
         dropStmt.text = sql;
         try
         {
            dropStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizSQLObject dropTbl error." + error.message + ", " + error.details);
            log.debug("DROP TABLE error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("sql = \'" + sql + "\'");
            enable = false;
         }
         return this.enable;
      }
      
      public function systemFields() : String
      {
         var _loc1_:* = "";
         _loc1_ += "    id  \t\tINTEGER PRIMARY KEY AUTOINCREMENT,";
         _loc1_ += "\tcreateDate\tREAL,";
         _loc1_ += "\tmodifyDate\tREAL,";
         return _loc1_ + "\tdeleteDate\tREAL,";
      }
      
      public function evolveTbl(param1:Number) : Boolean
      {
         var _loc2_:Number = NaN;
         if(this.enable)
         {
            _loc2_ = this.db.getTableVersion(this.tabName);
            if(_loc2_ == 0)
            {
               this.enable = this.createTbl();
               if(this.tabName != GWizMetaSQL.META_TABLE)
               {
                  this.db.setTableVersion(this.tabName,param1);
               }
            }
            else
            {
               while(this.enable && _loc2_ < param1)
               {
                  _loc2_ = this.evolveAux(_loc2_);
                  if(!this.enable)
                  {
                     break;
                  }
                  this.db.setTableVersion(this.tabName,_loc2_);
               }
            }
         }
         return this.enable;
      }
      
      public function evolveAux(param1:Number) : Number
      {
         GWizUtils.assert(false);
         this.enable = false;
         return param1 + 1;
      }
      
      public function dumpTable(param1:String) : void
      {
         var i:int = 0;
         var msg:String = param1;
         log.debug("dumpTable( " + msg + " )");
         var selectStmt:SQLStatement = new SQLStatement();
         selectStmt.sqlConnection = this.db.conn;
         var sql:String = "SELECT * FROM " + this.tabName;
         selectStmt.text = sql;
         try
         {
            selectStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizSQLObject dumpTable error." + error.message + ", " + error.details);
            log.debug("SELECT error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            enable = false;
         }
         var result:SQLResult = selectStmt.getResult();
         if(result.data)
         {
            log.debug(this.tabName + " has " + result.data.length + " records");
            i = 0;
            while(i < result.data.length)
            {
               this.dumpRow(result.data[i]);
               i++;
            }
         }
         else
         {
            log.debug("*** Table is Empty ***");
         }
      }
      
      public function dumpRow(param1:Object) : void
      {
      }
      
      public function addAND(param1:String) : String
      {
         if(param1.length > 0)
         {
            param1 = "AND ";
         }
         else
         {
            param1 = "";
         }
         return param1;
      }
   }
}
