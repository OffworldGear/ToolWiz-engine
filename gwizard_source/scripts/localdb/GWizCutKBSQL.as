package localdb
{
   import flash.data.SQLResult;
   import flash.data.SQLStatement;
   import flash.errors.SQLError;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizCutKBSQL extends GWizSQLObject
   {
      
      private static const log:ILogger = Log.getLogger("GWizCutKBSQL");
      
      public static var activeRec:GWizCutKB = new GWizCutKB();
       
      
      private const CUT_KB_TABLE:String = "cutKB";
      
      private const REQUIRED_VSN:Number = 0.4;
      
      private var searchFilterStr:String = "";
      
      public function GWizCutKBSQL(param1:GWizLocalSQL)
      {
         tabName = this.CUT_KB_TABLE;
         tabVersion = this.REQUIRED_VSN;
         enable = true;
         super(param1);
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
         sql += "CREATE TABLE IF NOT EXISTS " + this.CUT_KB_TABLE + " (";
         sql += systemFields();
         sql += "\tmrr\t\t\tREAL,";
         sql += "\tmrrPct\t\tREAL,";
         sql += "\trpm\t\t\tREAL,";
         sql += "\trpmPct\t\tREAL,";
         sql += "\tipm\t\t\tREAL,";
         sql += "\tipmPct\t\tREAL,";
         sql += "\tsfm\t\t\tREAL,";
         sql += "\tsfmPct\t\tREAL,";
         sql += "\tipt\t\t\tREAL,";
         sql += "\tiptPct\t\tREAL,";
         sql += "\tmachine\t\tTEXT,";
         sql += "\ttool\t\tTEXT,";
         sql += "\tcrib\t\tTEXT,";
         sql += "\ttoolDia\t\tREAL,";
         sql += "\tflutes\t\tINTEGER,";
         sql += "\tgeometry\tTEXT,";
         sql += "\trougher\t\tINTEGER,";
         sql += "\tstickout\tREAL,";
         sql += "\tleadAng\t\tINTEGER,";
         sql += "\tnoseRad\t\tREAL,";
         sql += "\tmaterial\tINTEGER,";
         sql += "\thardness\tINTEGER,";
         sql += "\tcutDepth\tREAL,";
         sql += "\tcutWidth\tREAL,";
         sql += "\ttea\t\t\tINTEGER,";
         sql += "\tdescription\tTEXT,";
         sql += "\trating\t\tINTEGER,";
         sql += "\tcomments\tTEXT,";
         sql += "\twear\t\tINTEGER,";
         sql += "\tchatter\t\tINTEGER,";
         sql += "\tcutType\t\tINTEGER,";
         sql += "\trough\t\tINTEGER,";
         sql += "\tholder\t\tINTEGER,";
         sql += "\tcoolant\t\tINTEGER";
         sql += ")";
         createStmt.text = sql;
         try
         {
            createStmt.execute();
            db.setTableVersion(tabName,tabVersion);
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCutKBSQL createTbl error." + error.message + ", " + error.details);
            log.debug("CREATE TABLE error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("sql = \'" + sql + "\'");
            enable = false;
            GWizUtils.assert(false);
         }
         return enable;
      }
      
      override public function evolveAux(param1:Number) : Number
      {
         var sql:String = null;
         var updateStmt:SQLStatement = null;
         var alterStmt:SQLStatement = null;
         var s:String = null;
         var requiredVersion:Number = param1;
         var evolvedTo:Number = 0;
         if(requiredVersion < 0.2)
         {
            if(dropTbl())
            {
               if(this.createTbl())
               {
                  evolvedTo = 0.2;
               }
               else
               {
                  enable = false;
               }
            }
            else
            {
               enable = false;
            }
         }
         sql = "";
         if(requiredVersion == 0.2)
         {
            updateStmt = new SQLStatement();
            updateStmt.sqlConnection = db.conn;
            sql += "UPDATE " + tabName + " SET ";
            sql += "tool = :tool ";
            sql += "WHERE tool = :oldtool ";
            updateStmt.text = sql;
            updateStmt.parameters[":tool"] = "Indexable End Or Face Mill";
            updateStmt.parameters[":oldtool"] = "Indexable End / Facemill";
            try
            {
               updateStmt.execute();
               evolvedTo = 0.3;
            }
            catch(error:SQLError)
            {
               log.debug("evolveAux( GWizCutKBSQL ) error:",error);
               log.debug("error.message:",error.message);
               log.debug("error.details:",error.details);
               log.debug("SQL = \'" + sql + "\'");
               GWizUtils.LogError("GWizCutKBSQL evolveAux error." + error.message + ", " + error.details);
               enable = false;
            }
         }
         if(requiredVersion == 0.3)
         {
            alterStmt = new SQLStatement();
            alterStmt.sqlConnection = db.conn;
            sql = "";
            sql += "ALTER TABLE " + tabName + " ADD COLUMN geometry TEXT";
            alterStmt.text = sql;
            try
            {
               alterStmt.execute();
               evolvedTo = 0.4;
            }
            catch(error:SQLError)
            {
               log.debug("evolveAux( GWizCutKBSQL ) error:",error);
               log.debug("error.message:",error.message);
               log.debug("error.details:",error.details);
               log.debug("SQL = \'" + sql + "\'");
               GWizUtils.LogError("GWizCutKBSQL evolveAux error." + error.message + ", " + error.details);
               enable = false;
               s = error.details;
               if(s.indexOf("\'geometry\' already exists") > 0)
               {
                  enable = true;
                  evolvedTo = 0.4;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
         }
         return evolvedTo;
      }
      
      public function insertRow(param1:Object) : void
      {
         this.insertRowFromArgs(param1.mrr,param1.mrrPct,param1.rpm,param1.rpmPct,param1.ipm,param1.ipmPct,param1.sfm,param1.sfmPct,param1.ipt,param1.iptPct,param1.machine,param1.tool,param1.crib,param1.toolDia,param1.flutes,param1.geometry,param1.rougher,param1.stickout,param1.leadAng,param1.noseRad,param1.material,param1.hardness,param1.cutDepth,param1.cutWidth,param1.tea,param1.description,param1.rating,param1.comments,param1.wear,param1.chatter,param1.cutType,int(param1.rough),param1.holder,param1.coolant);
      }
      
      public function insertRowAR() : void
      {
         this.insertRow(activeRec);
      }
      
      public function updateRowAR() : void
      {
         var updateStmt:SQLStatement = null;
         var sql:String = null;
         if(!enable)
         {
            return;
         }
         if(activeRec.id == -1)
         {
            this.insertRowAR();
         }
         else
         {
            updateStmt = new SQLStatement();
            updateStmt.sqlConnection = db.conn;
            sql = "";
            sql += "UPDATE " + tabName + " SET ";
            sql += "mrr = :mrr, ";
            sql += "mrrPct = :mrrPct, ";
            sql += "rpm = :rpm, ";
            sql += "rpmPct = :rpmPct, ";
            sql += "ipm = :ipm, ";
            sql += "ipmPct = :ipmPct, ";
            sql += "sfm = :sfm, ";
            sql += "sfmPct = :sfmPct, ";
            sql += "ipt = :ipt, ";
            sql += "iptPct = :iptPct, ";
            sql += "machine = :machine, ";
            sql += "tool = :tool, ";
            sql += "crib = :crib, ";
            sql += "toolDia = :toolDia, ";
            sql += "flutes = :flutes, ";
            sql += "geometry = :geometry, ";
            sql += "rougher = :rougher, ";
            sql += "stickout = :stickout, ";
            sql += "leadAng = :leadAng, ";
            sql += "noseRad = :noseRad, ";
            sql += "material = :material, ";
            sql += "hardness = :hardness, ";
            sql += "cutDepth = :cutDepth, ";
            sql += "cutWidth = :cutWidth, ";
            sql += "tea = :tea, ";
            sql += "description = :description, ";
            sql += "rating = :rating, ";
            sql += "comments = :comments, ";
            sql += "wear = :wear, ";
            sql += "chatter = :chatter, ";
            sql += "cutType = :cutType, ";
            sql += "rough = :rough, ";
            sql += "holder = :holder, ";
            sql += "coolant = :coolant ";
            sql += "WHERE id = :id ";
            updateStmt.text = sql;
            updateStmt.parameters[":mrr"] = activeRec.mrr;
            updateStmt.parameters[":mrrPct"] = activeRec.mrrPct;
            updateStmt.parameters[":rpm"] = activeRec.rpm;
            updateStmt.parameters[":rpmPct"] = activeRec.rpmPct;
            updateStmt.parameters[":ipm"] = activeRec.ipm;
            updateStmt.parameters[":ipmPct"] = activeRec.ipmPct;
            updateStmt.parameters[":sfm"] = activeRec.sfm;
            updateStmt.parameters[":sfmPct"] = activeRec.sfmPct;
            updateStmt.parameters[":ipt"] = activeRec.ipt;
            updateStmt.parameters[":iptPct"] = activeRec.iptPct;
            updateStmt.parameters[":machine"] = activeRec.machine;
            updateStmt.parameters[":tool"] = activeRec.tool;
            updateStmt.parameters[":crib"] = activeRec.crib;
            updateStmt.parameters[":toolDia"] = activeRec.toolDia;
            updateStmt.parameters[":flutes"] = activeRec.flutes;
            updateStmt.parameters[":geometry"] = activeRec.geometry;
            updateStmt.parameters[":rougher"] = activeRec.rougher;
            updateStmt.parameters[":stickout"] = activeRec.stickout;
            updateStmt.parameters[":leadAng"] = activeRec.leadAng;
            updateStmt.parameters[":noseRad"] = activeRec.noseRad;
            updateStmt.parameters[":material"] = activeRec.material;
            updateStmt.parameters[":hardness"] = activeRec.hardness;
            updateStmt.parameters[":cutDepth"] = activeRec.cutDepth;
            updateStmt.parameters[":cutWidth"] = activeRec.cutWidth;
            updateStmt.parameters[":tea"] = activeRec.tea;
            updateStmt.parameters[":description"] = activeRec.description;
            updateStmt.parameters[":rating"] = activeRec.rating;
            updateStmt.parameters[":comments"] = activeRec.comments;
            updateStmt.parameters[":wear"] = activeRec.wear;
            updateStmt.parameters[":chatter"] = activeRec.chatter;
            updateStmt.parameters[":cutType"] = activeRec.cutType;
            updateStmt.parameters[":rough"] = activeRec.rough;
            updateStmt.parameters[":holder"] = activeRec.holder;
            updateStmt.parameters[":coolant"] = activeRec.coolant;
            updateStmt.parameters[":id"] = activeRec.id;
            try
            {
               updateStmt.execute();
            }
            catch(error:SQLError)
            {
               GWizUtils.LogError("GWizCutKBSQL updateRowAR error." + error.message + ", " + error.details);
               log.debug("updateRowAR( GWizCutKBSQL ) error:",error);
               log.debug("error.message:",error.message);
               log.debug("error.details:",error.details);
               log.debug("SQL = \'" + sql + "\'");
               enable = false;
               GWizUtils.assert(false);
            }
         }
         dumpTable("updateRowAR( GWizCutKBSQL )");
      }
      
      private function insertRowFromArgs(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Number, param10:Number, param11:String, param12:String, param13:String, param14:Number, param15:int, param16:String, param17:Boolean, param18:Number, param19:int, param20:Number, param21:int, param22:int, param23:Number, param24:Number, param25:int, param26:String, param27:int, param28:String, param29:int, param30:int, param31:int, param32:int, param33:int, param34:int) : void
      {
         var sql:String = null;
         var mrr:Number = param1;
         var mrrPct:Number = param2;
         var rpm:Number = param3;
         var rpmPct:Number = param4;
         var ipm:Number = param5;
         var ipmPct:Number = param6;
         var sfm:Number = param7;
         var sfmPct:Number = param8;
         var ipt:Number = param9;
         var iptPct:Number = param10;
         var machine:String = param11;
         var tool:String = param12;
         var crib:String = param13;
         var toolDia:Number = param14;
         var flutes:int = param15;
         var geometry:String = param16;
         var rougher:Boolean = param17;
         var stickout:Number = param18;
         var leadAng:int = param19;
         var noseRad:Number = param20;
         var material:int = param21;
         var hardness:int = param22;
         var cutDepth:Number = param23;
         var cutWidth:Number = param24;
         var tea:int = param25;
         var description:String = param26;
         var rating:int = param27;
         var comments:String = param28;
         var wear:int = param29;
         var chatter:int = param30;
         var cutType:int = param31;
         var rough:int = param32;
         var holder:int = param33;
         var coolant:int = param34;
         if(!enable)
         {
            return;
         }
         var insertStmt:SQLStatement = new SQLStatement();
         insertStmt.sqlConnection = db.conn;
         sql = "";
         sql += "INSERT OR REPLACE INTO " + tabName + " (";
         sql += "mrr, ";
         sql += "mrrPct, ";
         sql += "rpm, ";
         sql += "rpmPct, ";
         sql += "ipm, ";
         sql += "ipmPct, ";
         sql += "sfm, ";
         sql += "sfmPct, ";
         sql += "ipt, ";
         sql += "iptPct, ";
         sql += "machine, ";
         sql += "tool, ";
         sql += "crib, ";
         sql += "toolDia, ";
         sql += "flutes, ";
         sql += "geometry, ";
         sql += "rougher, ";
         sql += "stickout, ";
         sql += "leadAng, ";
         sql += "noseRad, ";
         sql += "material, ";
         sql += "hardness, ";
         sql += "cutDepth, ";
         sql += "cutWidth, ";
         sql += "tea, ";
         sql += "description, ";
         sql += "rating, ";
         sql += "comments, ";
         sql += "wear, ";
         sql += "chatter, ";
         sql += "cutType, ";
         sql += "rough, ";
         sql += "holder, ";
         sql += "coolant) ";
         sql += "VALUES (";
         sql += ":mrr, ";
         sql += ":mrrPct, ";
         sql += ":rpm, ";
         sql += ":rpmPct, ";
         sql += ":ipm, ";
         sql += ":ipmPct, ";
         sql += ":sfm, ";
         sql += ":sfmPct, ";
         sql += ":ipt, ";
         sql += ":iptPct, ";
         sql += ":machine, ";
         sql += ":tool, ";
         sql += ":crib, ";
         sql += ":toolDia, ";
         sql += ":flutes, ";
         sql += ":geometry, ";
         sql += ":rougher, ";
         sql += ":stickout, ";
         sql += ":leadAng, ";
         sql += ":noseRad, ";
         sql += ":material, ";
         sql += ":hardness, ";
         sql += ":cutDepth, ";
         sql += ":cutWidth, ";
         sql += ":tea, ";
         sql += ":description, ";
         sql += ":rating, ";
         sql += ":comments, ";
         sql += ":wear, ";
         sql += ":chatter, ";
         sql += ":cutType, ";
         sql += ":rough, ";
         sql += ":holder, ";
         sql += ":coolant) ";
         insertStmt.text = sql;
         insertStmt.parameters[":mrr"] = mrr;
         insertStmt.parameters[":mrrPct"] = mrrPct;
         insertStmt.parameters[":rpm"] = rpm;
         insertStmt.parameters[":rpmPct"] = rpmPct;
         insertStmt.parameters[":ipm"] = ipm;
         insertStmt.parameters[":ipmPct"] = ipmPct;
         insertStmt.parameters[":sfm"] = sfm;
         insertStmt.parameters[":sfmPct"] = sfmPct;
         insertStmt.parameters[":ipt"] = ipt;
         insertStmt.parameters[":iptPct"] = iptPct;
         insertStmt.parameters[":machine"] = machine;
         insertStmt.parameters[":tool"] = tool;
         insertStmt.parameters[":crib"] = crib;
         insertStmt.parameters[":toolDia"] = toolDia;
         insertStmt.parameters[":flutes"] = flutes;
         insertStmt.parameters[":geometry"] = geometry;
         insertStmt.parameters[":rougher"] = rougher;
         insertStmt.parameters[":stickout"] = stickout;
         insertStmt.parameters[":leadAng"] = leadAng;
         insertStmt.parameters[":noseRad"] = noseRad;
         insertStmt.parameters[":material"] = material;
         insertStmt.parameters[":hardness"] = hardness;
         insertStmt.parameters[":cutDepth"] = cutDepth;
         insertStmt.parameters[":cutWidth"] = cutWidth;
         insertStmt.parameters[":tea"] = tea;
         insertStmt.parameters[":description"] = description;
         insertStmt.parameters[":rating"] = rating;
         insertStmt.parameters[":comments"] = comments;
         insertStmt.parameters[":wear"] = wear;
         insertStmt.parameters[":chatter"] = chatter;
         insertStmt.parameters[":cutType"] = cutType;
         insertStmt.parameters[":rough"] = rough;
         insertStmt.parameters[":holder"] = holder;
         insertStmt.parameters[":coolant"] = coolant;
         try
         {
            insertStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCutKBSQL insertRow error." + error.message + ", " + error.details + ", sql = \'" + sql);
            log.debug("insertRow( GWizCutKBSQL ) error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
            GWizUtils.assert(false);
         }
      }
      
      public function countRows() : Number
      {
         var metadata:Object = null;
         if(!enable)
         {
            return 0;
         }
         var countStmt:SQLStatement = new SQLStatement();
         countStmt.sqlConnection = db.conn;
         var sql:String = "";
         sql += "SELECT count(id) AS rowCt FROM cutKB";
         countStmt.text = sql;
         try
         {
            countStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCutKBSQL countRows error." + error.message + ", " + error.details);
            log.debug("COUNT error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            enable = false;
            GWizUtils.assert(false);
         }
         var result:SQLResult = countStmt.getResult();
         var retval:Number = 0;
         if(!result.data || result.data.length == 0 || !enable)
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
         return retval;
      }
      
      public function deleteRowAR() : void
      {
         var sql:String = null;
         if(!enable || !activeRec || activeRec.id == -1)
         {
            return;
         }
         var deleteStmt:SQLStatement = new SQLStatement();
         deleteStmt.sqlConnection = db.conn;
         sql = "";
         sql += "DELETE FROM " + tabName + " WHERE id = :id;";
         deleteStmt.text = sql;
         deleteStmt.parameters[":id"] = activeRec.id;
         try
         {
            deleteStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCutKBSQL deleteRowAR error." + error.message + ", " + error.details);
            log.debug("deleteRowAR(GWizCutKBSQL) error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
            GWizUtils.assert(false);
         }
      }
      
      private function addCheckbox(param1:Boolean, param2:String) : void
      {
         if(param1)
         {
            this.searchFilterStr += addAND(this.searchFilterStr) + " " + param2 + " = :" + param2 + " ";
         }
      }
      
      private function addParm(param1:SQLStatement, param2:Boolean, param3:String, param4:Object) : SQLStatement
      {
         if(param2)
         {
            param1.parameters[param3] = param4;
         }
         return param1;
      }
      
      public function filterList(param1:String, param2:Boolean, param3:Boolean, param4:Boolean, param5:Boolean, param6:Boolean, param7:Boolean, param8:Boolean, param9:Boolean, param10:Boolean) : ArrayCollection
      {
         var sql:String = null;
         var result:SQLResult = null;
         var i:int = 0;
         var entry:Object = null;
         var keywords:String = param1;
         var material:Boolean = param2;
         var machine:Boolean = param3;
         var toolType:Boolean = param4;
         var toolDia:Boolean = param5;
         var flutes:Boolean = param6;
         var lead:Boolean = param7;
         var stickout:Boolean = param8;
         var cutDepth:Boolean = param9;
         var cutWidth:Boolean = param10;
         if(!enable)
         {
            return null;
         }
         this.searchFilterStr = "";
         if(keywords.length > 0)
         {
         }
         this.addCheckbox(material,"material");
         this.addCheckbox(machine,"machine");
         this.addCheckbox(toolType,"tool");
         this.addCheckbox(toolType,"crib");
         this.addCheckbox(toolDia,"toolDia");
         this.addCheckbox(flutes,"flutes");
         this.addCheckbox(lead,"leadAng");
         this.addCheckbox(stickout,"stickout");
         this.addCheckbox(cutDepth,"cutDepth");
         this.addCheckbox(cutWidth,"cutWidth");
         var selectStmt:SQLStatement = new SQLStatement();
         selectStmt.sqlConnection = db.conn;
         sql = "";
         sql += "SELECT * FROM " + tabName;
         if(this.searchFilterStr.length > 0)
         {
            sql += " WHERE " + this.searchFilterStr;
         }
         selectStmt.text = sql;
         selectStmt = this.addParm(selectStmt,material,":material",activeRec.material);
         selectStmt = this.addParm(selectStmt,machine,":machine",activeRec.machine);
         selectStmt = this.addParm(selectStmt,toolType,":tool",activeRec.tool);
         selectStmt = this.addParm(selectStmt,toolType,":crib",activeRec.crib);
         selectStmt = this.addParm(selectStmt,toolDia,":toolDia",activeRec.toolDia);
         selectStmt = this.addParm(selectStmt,flutes,":flutes",activeRec.flutes);
         selectStmt = this.addParm(selectStmt,lead,":leadAng",activeRec.leadAng);
         selectStmt = this.addParm(selectStmt,stickout,":stickout",activeRec.stickout);
         selectStmt = this.addParm(selectStmt,cutDepth,":cutDepth",activeRec.cutDepth);
         selectStmt = this.addParm(selectStmt,cutWidth,":cutWidth",activeRec.cutWidth);
         try
         {
            selectStmt.execute();
         }
         catch(error:SQLError)
         {
            GWizUtils.LogError("GWizCutKBSQL filterList error." + error.message + ", " + error.details);
            log.debug("filterList(GWizCutKBSQL) error:",error);
            log.debug("error.message:",error.message);
            log.debug("error.details:",error.details);
            log.debug("SQL = \'" + sql + "\'");
            enable = false;
            GWizUtils.assert(false);
         }
         var retval:ArrayCollection = new ArrayCollection();
         if(enable)
         {
            result = selectStmt.getResult();
            log.debug("filterList(GWizCutKBSQL) results:");
            if(result && result.data && result.data.length > 0)
            {
               i = 0;
               while(i < result.data.length)
               {
                  entry = result.data[i];
                  retval.addItem(entry);
                  i++;
               }
            }
            else
            {
               log.debug("No results");
               log.debug("sql = " + selectStmt.toString());
            }
         }
         return retval;
      }
   }
}
