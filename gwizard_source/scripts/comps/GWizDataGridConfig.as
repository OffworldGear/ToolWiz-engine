package comps
{
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizStringUtils;
   
   public class GWizDataGridConfig
   {
      
      private static const log:ILogger = Log.getLogger("GWizDataGridConfig");
       
      
      private var _configStr:String;
      
      private var _config:Vector.<GWizDataGridConfigColumn>;
      
      private var _dirty:Boolean;
      
      private var colConfigIdMap:Object;
      
      private const configFileVersion:String = "0";
      
      public function GWizDataGridConfig()
      {
         super();
         this.dirty = false;
      }
      
      public static function fromConfigStr(param1:String) : GWizDataGridConfig
      {
         var _loc2_:GWizDataGridConfig = new GWizDataGridConfig();
         _loc2_.configStr = param1;
         return _loc2_;
      }
      
      public static function fromGrid(param1:GWizDataGrid) : GWizDataGridConfig
      {
         var _loc2_:GWizDataGridConfig = new GWizDataGridConfig();
         _loc2_.configStr = _loc2_.buildConfigStr(param1);
         return _loc2_;
      }
      
      public function hasColConfigId(param1:String) : Boolean
      {
         if(this.colConfigIdMap == null)
         {
            return false;
         }
         return this.colConfigIdMap.hasOwnProperty(param1);
      }
      
      public function setSort(param1:String, param2:int) : void
      {
         var _loc4_:GWizDataGridConfigColumn = null;
         if(this.config == null)
         {
            return;
         }
         if(!this.colConfigIdMap.hasOwnProperty(param1))
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.config.length)
         {
            if((_loc4_ = this.config[_loc3_] as GWizDataGridConfigColumn).configId == param1)
            {
               _loc4_.hasSort = param2 != GWizDataGrid.SORT_NONE;
               _loc4_.sortDescending = param2 == GWizDataGrid.SORT_DESCEND;
            }
            else
            {
               _loc4_.hasSort = false;
            }
            _loc3_++;
         }
      }
      
      private function parseConfigStr() : void
      {
         var _loc3_:String = null;
         var _loc4_:GWizDataGridConfigColumn = null;
         if(GWizStringUtils.isBlank(this._configStr))
         {
            this._config = null;
            return;
         }
         this._config = new Vector.<GWizDataGridConfigColumn>();
         this.colConfigIdMap = new Object();
         var _loc1_:Array = this._configStr.split(",");
         var _loc2_:String = null;
         for each(_loc3_ in _loc1_)
         {
            if(_loc2_ == null)
            {
               _loc2_ = _loc3_;
               if(_loc2_ != this.configFileVersion)
               {
                  this._config = null;
                  return;
               }
            }
            else
            {
               _loc4_ = GWizDataGridConfigColumn.fromColumnConfigStr(_loc3_);
               this._config.push(_loc4_);
               this.colConfigIdMap[_loc4_.configId] = _loc4_;
            }
         }
      }
      
      public function updateFromGrid(param1:GWizDataGrid) : Boolean
      {
         var _loc2_:String = this.buildConfigStr(param1);
         if(_loc2_ == this.configStr)
         {
            return false;
         }
         this.configStr = _loc2_;
         this.dirty = true;
         return true;
      }
      
      private function buildConfigStr(param1:GWizDataGrid) : String
      {
         var _loc6_:GWizGridColumn = null;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc2_:String = param1.configId;
         var _loc3_:String = "";
         var _loc4_:String = "";
         var _loc5_:int = 0;
         while(_loc5_ < param1.columns.length)
         {
            _loc6_ = param1.columns.getItemAt(_loc5_) as GWizGridColumn;
            if(GWizStringUtils.isBlank(_loc6_.configId))
            {
               log.debug("Missing configId for GWizGridColumn(" + _loc5_ + ") in grid: " + _loc2_);
            }
            else if(_loc6_.configId.indexOf("=") != -1)
            {
               log.debug("Illegal configId for GWizGridColumn(" + _loc5_ + ") in grid: " + _loc2_);
            }
            else
            {
               _loc4_ += _loc3_;
               _loc7_ = "";
               _loc8_ = param1.getSortState();
               if(_loc6_.columnIndex == _loc8_.activeSortColumnIndex)
               {
                  if(_loc8_.activeSortColumnOrder == GWizDataGrid.SORT_ASCEND)
                  {
                     _loc7_ = "a";
                  }
                  else if(_loc8_.activeSortColumnOrder == GWizDataGrid.SORT_DESCEND)
                  {
                     _loc7_ = "d";
                  }
               }
               _loc4_ += this.encode(_loc6_.configId) + "=" + (!!_loc6_.visible ? "" : "-") + _loc6_.width + _loc7_;
               _loc3_ = ",";
            }
            _loc5_++;
         }
         return this.configFileVersion + _loc3_ + _loc4_;
      }
      
      private function encode(param1:String) : String
      {
         var _loc2_:String = param1;
         _loc2_.replace("=","[equal]");
         _loc2_.replace(",","[comma]");
         return _loc2_;
      }
      
      private function decode(param1:String) : String
      {
         var _loc2_:String = param1;
         _loc2_.replace("[equal]","=");
         _loc2_.replace("[comma]",",");
         return _loc2_;
      }
      
      public function get configStr() : String
      {
         return this._configStr;
      }
      
      public function set configStr(param1:String) : void
      {
         this._configStr = param1;
         this.parseConfigStr();
      }
      
      public function get config() : Vector.<GWizDataGridConfigColumn>
      {
         return this._config;
      }
      
      public function get dirty() : Boolean
      {
         return this._dirty;
      }
      
      public function set dirty(param1:Boolean) : void
      {
         this._dirty = param1;
      }
   }
}
