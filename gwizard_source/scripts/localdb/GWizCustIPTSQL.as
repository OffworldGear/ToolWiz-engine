package localdb
{
   import flash.data.SQLResult;
   import flash.data.SQLStatement;
   import flash.errors.SQLError;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.utils.StringUtil;
   import utils.GWizDebugUtils;
   import utils.GWizUtils;
   
   public class GWizCustIPTSQL extends GWizSQLObject
   {
      
      private static const log:ILogger = Log.getLogger("GWizCustIPTSQL");
      
      public static const TEMP_TAG:int = 1961;
      
      public static const VENDOR:String = "vendor";
      
      public static const PRODUCT:String = "product";
       
      
      private const CUST_IPT_TABLE:String = "custIPT";
      
      private const REQUIRED_VSN:Number = 0.1;
      
      public function GWizCustIPTSQL(param1:GWizLocalSQL)
      {
         tabName = this.CUST_IPT_TABLE;
         tabVersion = this.REQUIRED_VSN;
         enable = true;
         super(param1);
         this.deleteTempRows();
      }
      
      override public function createTbl() : Boolean
      {
         var sql:String = null;
         if(!enable)
         {
            return enable;
         }
         var createStmt:SQLStatement = new SQLStatement();
         createStmt.sqlConnection = db.conn;
         sql = "";
         sql += "CREATE TABLE IF NOT EXISTS " + tabName + " (";
         sql += systemFields();
         sql += "\tvendor\t\tTEXT COLLATE NOCASE,";
         sql += "\tproduct\t\tTEXT COLLATE NOCASE,";
         sql += "\tidNo\t\tTEXT COLLATE NOCASE,";
         sql += "\tinsNo\t\tTEXT COLLATE NOCASE,";
         sql += "    link        TEXT,";
         sql += "\tmaterial\tINTEGER,";
         sql += "\tsfm\t\t\tREAL,";
         sql += "\tipt00625\tREAL,";
         sql += "\tipt01250\tREAL,";
         sql += "\tipt01875\tREAL,";
         sql += "\tipt02500\tREAL,";
         sql += "\tipt03750\tREAL,";
         sql += "\tipt05000\tREAL,";
         sql += "\tipt07500\tREAL,";
         sql += "\tipt10000\tREAL,";
         sql += "\tipt15000\tREAL,";
         sql += "\tipt20000\tREAL,";
         sql += "\tipt30000\tREAL,";
         sql += "\tipt40000\tREAL,";
         sql += "\tipt50000\tREAL,";
         sql += "    changed\t\tINTEGER,";
         sql += "    CONSTRAINT uc_6Keys UNIQUE (vendor, product, idNo, insNo, material, changed)";
         sql += ")";
         createStmt.text = sql;
         try
         {
            createStmt.execute();
            db.setTableVersion(tabName,tabVersion);
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCustIPTSQL CREATE TABLE error." + error.message + ", " + error.details);
            log.debug("CREATE TABLE error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("sql = \'" + sql + "\'");
            enable = false;
         }
         this.deleteTempRows();
         return enable;
      }
      
      override public function evolveAux(param1:Number) : Number
      {
         return this.REQUIRED_VSN;
      }
      
      private function placeholderExists(param1:String, param2:String, param3:String, param4:String) : Boolean
      {
         var sql:String = null;
         var metadata:Object = null;
         var vendor:String = param1;
         var product:String = param2;
         var toolNo:String = param3;
         var insert:String = param4;
         if(!enable)
         {
            return false;
         }
         var countStmt:SQLStatement = new SQLStatement();
         countStmt.sqlConnection = db.conn;
         sql = "";
         sql += "SELECT count(id) AS rowCt FROM " + tabName + " WHERE ";
         var where:String = "";
         if(vendor.length > 0)
         {
            where += "vendor = :vendor ";
         }
         if(product.length > 0)
         {
            where += addAND(where) + " product = :product ";
         }
         if(toolNo.length > 0)
         {
            where += addAND(where) + " idNo = :idNo ";
         }
         if(insert.length > 0)
         {
            where += addAND(where) + " insNo = :insNo ";
         }
         sql += where;
         countStmt.text = sql;
         if(where.length > 0)
         {
            if(vendor.length > 0)
            {
               countStmt.parameters[":vendor"] = vendor;
            }
            if(product.length > 0)
            {
               countStmt.parameters[":product"] = product;
            }
            if(toolNo.length > 0)
            {
               countStmt.parameters[":idNo"] = toolNo;
            }
            if(insert.length > 0)
            {
               countStmt.parameters[":insNo"] = insert;
            }
         }
         try
         {
            countStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCustIPTSQL COUNT error." + error.message + ", " + error.details);
            log.debug("COUNT error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
         }
         var result:SQLResult = countStmt.getResult();
         var retval:Number = 0;
         if(!enable || !result.data || result.data.length == 0)
         {
            retval = 0;
         }
         else if(result.data.length == 1)
         {
            metadata = result.data[0];
            retval = metadata.rowCt;
         }
         else
         {
            GWizUtils.assert(false);
         }
         return retval > 0;
      }
      
      public function insertPlaceholder(param1:String, param2:String, param3:String, param4:String) : void
      {
         var sql:String = null;
         var vendor:String = param1;
         var product:String = param2;
         var toolNo:String = param3;
         var insert:String = param4;
         if(!enable || this.placeholderExists(vendor,product,toolNo,insert))
         {
            return;
         }
         vendor = StringUtil.trim(vendor);
         product = StringUtil.trim(product);
         toolNo = StringUtil.trim(toolNo);
         insert = StringUtil.trim(insert);
         var insertStmt:SQLStatement = new SQLStatement();
         insertStmt.sqlConnection = db.conn;
         sql = "";
         sql += "INSERT OR REPLACE INTO " + tabName + " (";
         sql += "vendor, ";
         sql += "product, ";
         sql += "idNo, ";
         sql += "insNo,";
         sql += "changed, ";
         sql += "createDate";
         sql += ") VALUES (";
         sql += ":vendor, ";
         sql += ":product, ";
         sql += ":toolNo, ";
         sql += ":insNo, ";
         sql += ":changed, ";
         sql += ":createDate)";
         insertStmt.text = sql;
         insertStmt.parameters[":vendor"] = vendor;
         insertStmt.parameters[":product"] = product;
         insertStmt.parameters[":toolNo"] = toolNo;
         insertStmt.parameters[":insNo"] = insert;
         insertStmt.parameters[":changed"] = TEMP_TAG;
         insertStmt.parameters[":createDate"] = Number(new Date());
         try
         {
            insertStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCustIPTSQL insertPlaceholder error." + error.message + ", " + error.details);
            log.debug("insertPlaceholder error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
         }
      }
      
      public function insertRow(param1:String, param2:String, param3:String, param4:String, param5:String, param6:int, param7:Number, param8:Number, param9:Number, param10:Number, param11:Number, param12:Number, param13:Number, param14:Number, param15:Number, param16:Number, param17:Number, param18:Number, param19:Number, param20:Number) : void
      {
         var sql:String = null;
         var vendor:String = param1;
         var product:String = param2;
         var toolNo:String = param3;
         var insert:String = param4;
         var link:String = param5;
         var material:int = param6;
         var sfm:Number = param7;
         var ipt00625:Number = param8;
         var ipt01250:Number = param9;
         var ipt01875:Number = param10;
         var ipt02500:Number = param11;
         var ipt03750:Number = param12;
         var ipt05000:Number = param13;
         var ipt07500:Number = param14;
         var ipt10000:Number = param15;
         var ipt15000:Number = param16;
         var ipt20000:Number = param17;
         var ipt30000:Number = param18;
         var ipt40000:Number = param19;
         var ipt50000:Number = param20;
         if(!enable)
         {
            return;
         }
         vendor = StringUtil.trim(vendor);
         product = StringUtil.trim(product);
         toolNo = StringUtil.trim(toolNo);
         insert = StringUtil.trim(insert);
         var insertStmt:SQLStatement = new SQLStatement();
         insertStmt.sqlConnection = db.conn;
         sql = "";
         sql += "INSERT OR REPLACE INTO " + tabName + " (";
         sql += "vendor, ";
         sql += "product, ";
         sql += "idNo, ";
         sql += "insNo,";
         sql += "link,";
         sql += "material, ";
         sql += "sfm, ";
         sql += "ipt00625, ";
         sql += "ipt01250, ";
         sql += "ipt01875, ";
         sql += "ipt02500, ";
         sql += "ipt03750, ";
         sql += "ipt05000, ";
         sql += "ipt07500, ";
         sql += "ipt10000, ";
         sql += "ipt15000, ";
         sql += "ipt20000, ";
         sql += "ipt30000, ";
         sql += "ipt40000, ";
         sql += "ipt50000, ";
         sql += "changed, ";
         sql += "createDate";
         sql += ") VALUES (";
         sql += ":vendor, ";
         sql += ":product, ";
         sql += ":toolNo, ";
         sql += ":insNo, ";
         sql += ":link, ";
         sql += ":material, ";
         sql += ":sfm, ";
         sql += ":ipt00625, ";
         sql += ":ipt01250, ";
         sql += ":ipt01875, ";
         sql += ":ipt02500, ";
         sql += ":ipt03750, ";
         sql += ":ipt05000, ";
         sql += ":ipt07500, ";
         sql += ":ipt10000, ";
         sql += ":ipt15000, ";
         sql += ":ipt20000, ";
         sql += ":ipt30000, ";
         sql += ":ipt40000, ";
         sql += ":ipt50000, ";
         sql += ":changed, ";
         sql += ":createDate)";
         insertStmt.text = sql;
         insertStmt.parameters[":vendor"] = vendor;
         insertStmt.parameters[":product"] = product;
         insertStmt.parameters[":toolNo"] = toolNo;
         insertStmt.parameters[":insNo"] = insert;
         insertStmt.parameters[":link"] = link;
         insertStmt.parameters[":material"] = material;
         insertStmt.parameters[":sfm"] = sfm;
         insertStmt.parameters[":ipt00625"] = ipt00625;
         insertStmt.parameters[":ipt01250"] = ipt01250;
         insertStmt.parameters[":ipt01875"] = ipt01875;
         insertStmt.parameters[":ipt02500"] = ipt02500;
         insertStmt.parameters[":ipt03750"] = ipt03750;
         insertStmt.parameters[":ipt05000"] = ipt05000;
         insertStmt.parameters[":ipt07500"] = ipt07500;
         insertStmt.parameters[":ipt10000"] = ipt10000;
         insertStmt.parameters[":ipt15000"] = ipt15000;
         insertStmt.parameters[":ipt20000"] = ipt20000;
         insertStmt.parameters[":ipt30000"] = ipt30000;
         insertStmt.parameters[":ipt40000"] = ipt40000;
         insertStmt.parameters[":ipt50000"] = ipt50000;
         insertStmt.parameters[":changed"] = TEMP_TAG;
         insertStmt.parameters[":createDate"] = Number(new Date());
         try
         {
            insertStmt.execute();
         }
         catch(error:SQLError)
         {
            log.debug("insertRow error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            GWizUtils.LogError("GWizCustIPTSQL insertRow error." + error.message + ", " + error.details);
            enable = false;
         }
      }
      
      override public function dumpRow(param1:Object) : void
      {
         var _loc2_:Date = param1.createDate as Date;
         log.debug("id: \'" + param1.id + " " + "\' vendor: \'" + param1.vendor + "\' " + " product: \'" + param1.product + "\' idNo: \'" + param1.idNo + "\' insNo: \'" + param1.insNo + "\' material:" + param1.material + " created:" + _loc2_);
      }
      
      public function getColValues(param1:String, param2:Boolean, param3:Boolean, param4:Boolean) : Array
      {
         var sql:String = null;
         var result:SQLResult = null;
         var i:int = 0;
         var entry:Object = null;
         var colName:String = param1;
         var firstBlank:Boolean = param2;
         var distinct:Boolean = param3;
         var sort:Boolean = param4;
         if(!enable)
         {
            return null;
         }
         var selectStmt:SQLStatement = new SQLStatement();
         selectStmt.sqlConnection = db.conn;
         sql = "";
         if(distinct)
         {
            sql += "SELECT DISTINCT " + colName;
         }
         else
         {
            sql += "SELECT " + colName;
         }
         sql += " FROM " + tabName;
         if(sort)
         {
            sql += " ORDER BY " + colName;
         }
         selectStmt.text = sql;
         try
         {
            selectStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCustIPTSQL getColValues error." + error.message + ", " + error.details);
            log.debug("getColValues error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
         }
         var retval:Array = [];
         if(firstBlank)
         {
            retval.push(" ");
         }
         if(enable)
         {
            result = selectStmt.getResult();
            if(result.data && result.data.length > 0)
            {
               i = 0;
               while(i < result.data.length)
               {
                  entry = result.data[i];
                  switch(colName)
                  {
                     case "vendor":
                        retval.push(entry.vendor);
                        break;
                     case "product":
                        retval.push(entry.product);
                        break;
                     case "idNo":
                        retval.push(entry.idNo);
                        break;
                     case "insNo":
                        retval.push(entry.insNo);
                        break;
                  }
                  i++;
               }
            }
         }
         return retval;
      }
      
      public function filterList(param1:String, param2:String, param3:String, param4:String, param5:Number) : ArrayCollection
      {
         var sql:String = null;
         var result:SQLResult = null;
         var i:int = 0;
         var entry:Object = null;
         var vendor:String = param1;
         var product:String = param2;
         var toolNo:String = param3;
         var insert:String = param4;
         var date:Number = param5;
         if(!enable)
         {
            return null;
         }
         var selectStmt:SQLStatement = new SQLStatement();
         selectStmt.sqlConnection = db.conn;
         sql = "";
         sql += "SELECT DISTINCT vendor, product, idNo, insNo FROM " + tabName + " WHERE ";
         var where:String = "";
         if(vendor)
         {
            where += "vendor = :vendor ";
         }
         if(product)
         {
            where += addAND(where) + " product = :product ";
         }
         if(toolNo)
         {
            where += addAND(where) + " idNo = :idNo ";
         }
         if(insert)
         {
            where += addAND(where) + " insNo = :insNo ";
         }
         if(!isNaN(date))
         {
            where += addAND(where) + " createDate = :createDate ";
         }
         if(where.length == 0)
         {
            sql = "SELECT DISTINCT vendor, product, idNo, insNo FROM " + tabName;
         }
         selectStmt.text = sql + where;
         if(where.length > 0)
         {
            if(vendor)
            {
               selectStmt.parameters[":vendor"] = vendor;
            }
            if(product)
            {
               selectStmt.parameters[":product"] = product;
            }
            if(toolNo)
            {
               selectStmt.parameters[":idNo"] = toolNo;
            }
            if(insert)
            {
               selectStmt.parameters[":insNo"] = insert;
            }
            if(!isNaN(date))
            {
               selectStmt.parameters[":createDate"] = date;
            }
         }
         try
         {
            selectStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCustIPTSQL filterList error." + error.message + ", " + error.details);
            log.debug("filterList error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
         }
         var retval:ArrayCollection = new ArrayCollection();
         if(enable)
         {
            result = selectStmt.getResult();
            if(result.data && result.data.length > 0)
            {
               i = 0;
               while(i < result.data.length)
               {
                  entry = result.data[i];
                  GWizDebugUtils.traceObj(entry);
                  retval.addItem(entry);
                  i++;
               }
            }
         }
         return retval;
      }
      
      public function getSearchChoices(param1:String, param2:String, param3:String, param4:String, param5:Boolean) : Array
      {
         var sql:String = null;
         var result:SQLResult = null;
         var i:int = 0;
         var entry:Object = null;
         var vendor:String = param1;
         var product:String = param2;
         var toolNo:String = param3;
         var insert:String = param4;
         var firstBlank:Boolean = param5;
         if(!enable)
         {
            return null;
         }
         var selectStmt:SQLStatement = new SQLStatement();
         selectStmt.sqlConnection = db.conn;
         sql = "";
         var colName:String = "vendor";
         if(vendor == "*")
         {
            colName = "vendor";
            product = "";
            toolNo = "";
            insert = "";
         }
         else if(product == "*")
         {
            colName = "product";
            toolNo = "";
            insert = "";
         }
         else if(toolNo == "*")
         {
            colName = "idNo";
            insert = "";
         }
         else
         {
            colName = "insert";
         }
         sql += "SELECT DISTINCT " + colName + " FROM " + tabName;
         var where:String = "";
         if(vendor && vendor != "*")
         {
            where += "vendor = :vendor ";
         }
         if(product && product != "*")
         {
            where += addAND(where) + " product = :product ";
         }
         if(toolNo && toolNo != "*")
         {
            where += addAND(where) + " idNo = :idNo ";
         }
         if(insert && insert != "*")
         {
            where += addAND(where) + " insNo = :insNo ";
         }
         if(where.length > 0)
         {
            sql += " WHERE " + where;
         }
         if(where.length > 0)
         {
            if(vendor && vendor != "*")
            {
               selectStmt.parameters[":vendor"] = vendor;
            }
            if(product && product != "*")
            {
               selectStmt.parameters[":product"] = product;
            }
            if(toolNo && toolNo != "*")
            {
               selectStmt.parameters[":idNo"] = toolNo;
            }
            if(insert && insert != "*")
            {
               selectStmt.parameters[":insNo"] = insert;
            }
         }
         sql += " ORDER BY " + colName;
         selectStmt.text = sql;
         try
         {
            selectStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCustIPTSQL getSearchChoices error." + error.message + ", " + error.details);
            log.debug("getSearchChoices error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
         }
         var retval:Array = [];
         if(firstBlank)
         {
            retval.push(" ");
         }
         if(enable)
         {
            result = selectStmt.getResult();
            if(result.data && result.data.length > 0)
            {
               i = 0;
               while(i < result.data.length)
               {
                  entry = result.data[i];
                  switch(colName)
                  {
                     case "vendor":
                        retval.push(entry.vendor);
                        break;
                     case "product":
                        retval.push(entry.product);
                        break;
                     case "idNo":
                        retval.push(entry.idNo);
                        break;
                     case "insNo":
                        retval.push(entry.insNo);
                        break;
                  }
                  i++;
               }
            }
         }
         return retval;
      }
      
      public function makePermanent() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc1_:ArrayCollection = this.tempRows();
         if(_loc1_)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               _loc3_ = _loc1_.getItemAt(_loc2_);
               this.deleteNonTempRow(_loc3_);
               _loc2_++;
            }
         }
         this.clearTempTags();
      }
      
      public function cancelChanges() : void
      {
         this.deleteTempRows();
      }
      
      private function deleteTempRows() : void
      {
         var sql:String = null;
         if(!enable)
         {
            return;
         }
         var deleteStmt:SQLStatement = new SQLStatement();
         deleteStmt.sqlConnection = db.conn;
         sql = "";
         sql += "DELETE FROM " + tabName + " WHERE changed=" + TEMP_TAG + ";";
         deleteStmt.text = sql;
         try
         {
            deleteStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCustIPTSQL deleteTempRows error." + error.message + ", " + error.details);
            log.debug("deleteTempRows error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
         }
      }
      
      private function tempRows() : ArrayCollection
      {
         var sql:String = null;
         var result:SQLResult = null;
         var i:int = 0;
         var entry:Object = null;
         if(!enable)
         {
            return null;
         }
         var selectStmt:SQLStatement = new SQLStatement();
         selectStmt.sqlConnection = db.conn;
         sql = "";
         sql += "SELECT * FROM " + tabName + " WHERE changed = " + TEMP_TAG + ";";
         selectStmt.text = sql;
         try
         {
            selectStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCustIPTSQL tempRows error." + error.message + ", " + error.details);
            log.debug("tempRows error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
         }
         var retval:ArrayCollection = new ArrayCollection();
         if(enable)
         {
            result = selectStmt.getResult();
            if(result.data && result.data.length > 0)
            {
               i = 0;
               while(i < result.data.length)
               {
                  entry = result.data[i];
                  if(entry.sfm >= 0)
                  {
                     retval.addItem(entry);
                  }
                  i++;
               }
            }
         }
         return retval;
      }
      
      private function deleteNonTempRow(param1:Object) : void
      {
         var sql:String = null;
         var entry:Object = param1;
         if(!enable || !entry)
         {
            return;
         }
         var deleteStmt:SQLStatement = new SQLStatement();
         deleteStmt.sqlConnection = db.conn;
         sql = "";
         sql += "DELETE FROM " + tabName + " WHERE ";
         if(entry.vendor.length > 0)
         {
            sql += "vendor = :vendor ";
         }
         if(entry.product.length > 0)
         {
            sql += addAND(sql) + " product = :product ";
         }
         if(entry.idNo.length > 0)
         {
            sql += addAND(sql) + " idNo = :idNo ";
         }
         if(entry.insNo.length > 0)
         {
            sql += addAND(sql) + " insNo = :insNo ";
         }
         sql += " AND material = :material AND changed <> " + TEMP_TAG;
         deleteStmt.text = sql;
         if(entry.vendor.length > 0)
         {
            deleteStmt.parameters[":vendor"] = entry.vendor;
         }
         if(entry.product.length > 0)
         {
            deleteStmt.parameters[":product"] = entry.product;
         }
         if(entry.idNo.length > 0)
         {
            deleteStmt.parameters[":idNo"] = entry.idNo;
         }
         if(entry.insNo.length > 0)
         {
            deleteStmt.parameters[":insNo"] = entry.insNo;
         }
         deleteStmt.parameters[":material"] = entry.material;
         try
         {
            deleteStmt.execute();
         }
         catch(error:SQLError)
         {
            log.debug("deleteNonTempRow error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            GWizUtils.LogError("GWizCustIPTSQL deleteNonTempRow error." + error.message + ", " + error.details);
            enable = false;
         }
      }
      
      private function clearTempTags() : void
      {
         var sql:String = null;
         if(!enable)
         {
            return;
         }
         var updateStmt:SQLStatement = new SQLStatement();
         updateStmt.sqlConnection = db.conn;
         sql = "";
         sql += "UPDATE " + tabName + " SET changed = 0 WHERE sfm >= 0";
         updateStmt.text = sql;
         try
         {
            updateStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCustIPTSQL clearTempTags error." + error.message + ", " + error.details);
            log.debug("clearTempTags error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("sql = \'" + sql + "\'");
            enable = false;
         }
      }
      
      public function getCustomData(param1:String, param2:String, param3:String, param4:String, param5:int) : Object
      {
         var sql:String = null;
         var result:SQLResult = null;
         var vendor:String = param1;
         var product:String = param2;
         var toolNo:String = param3;
         var insert:String = param4;
         var material:int = param5;
         if(!enable)
         {
            return null;
         }
         var selectStmt:SQLStatement = new SQLStatement();
         selectStmt.sqlConnection = db.conn;
         sql = "";
         sql += "SELECT * FROM " + tabName + " WHERE ";
         var where:String = "";
         if(vendor && vendor.length > 0)
         {
            where += "vendor = :vendor ";
         }
         if(product && product.length > 0)
         {
            where += addAND(where) + " product = :product ";
         }
         if(toolNo && toolNo.length > 0)
         {
            where += addAND(where) + " idNo = :idNo ";
         }
         if(insert && insert.length > 0)
         {
            where += addAND(where) + " insNo = :insNo ";
         }
         if(where.length == 0)
         {
            return null;
         }
         if(material >= 0)
         {
            where += addAND(where) + " material = :material ";
         }
         where += addAND(where) + " changed <> " + TEMP_TAG + " ";
         selectStmt.text = sql + where;
         if(where.length > 0)
         {
            if(vendor && vendor.length > 0)
            {
               selectStmt.parameters[":vendor"] = vendor;
            }
            if(product && product.length > 0)
            {
               selectStmt.parameters[":product"] = product;
            }
            if(toolNo && toolNo.length > 0)
            {
               selectStmt.parameters[":idNo"] = toolNo;
            }
            if(insert && insert.length > 0)
            {
               selectStmt.parameters[":insNo"] = insert;
            }
            if(material >= 0)
            {
               selectStmt.parameters[":material"] = material;
            }
         }
         try
         {
            selectStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCustIPTSQL getCustomData error." + error.message + ", " + error.details);
            log.debug("getCustomData error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
         }
         var retval:Object = null;
         if(enable)
         {
            result = selectStmt.getResult();
            if(result.data && result.data.length > 0)
            {
               retval = result.data[0];
               GWizUtils.assert(result.data.length == 1 || material == -1);
            }
         }
         return retval;
      }
   }
}
