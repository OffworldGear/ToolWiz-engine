package comps
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.ListCollectionView;
   import mx.events.FlexEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.DataGrid;
   import spark.components.gridClasses.GridColumn;
   import spark.events.GridEvent;
   import utils.GWizStringUtils;
   
   public class GWizDataGrid extends DataGrid
   {
      
      private static const log:ILogger = Log.getLogger("GWizDataGrid");
      
      public static const SORT_NONE:int = 0;
      
      public static const SORT_ASCEND:int = 1;
      
      public static const SORT_DESCEND:int = 2;
      
      public static const SORT_COUNT:int = 3;
       
      
      private var topLevelClass:String = "";
      
      private var activeSortColumnIndex:int = -1;
      
      private var activeSortColumnOrder:int = 0;
      
      public var handleUpdates:Boolean = false;
      
      private var _filterStr:String = "";
      
      private var _configId:String;
      
      private var _configuring:Function;
      
      public function GWizDataGrid()
      {
         super();
         addEventListener(FlexEvent.CREATION_COMPLETE,this.onGridCreated);
      }
      
      public function set filterStr(param1:String) : void
      {
         this._filterStr = param1.toUpperCase();
         var _loc2_:ArrayCollection = this.dataProvider as ArrayCollection;
         if(param1 == "")
         {
            _loc2_.filterFunction = null;
         }
         else
         {
            _loc2_.filterFunction = this.strFilterFunction;
         }
         _loc2_.refresh();
      }
      
      public function get filterStr() : String
      {
         return this._filterStr;
      }
      
      private function strFilterFunction(param1:Object) : Boolean
      {
         var _loc2_:* = null;
         for(_loc2_ in param1)
         {
            if(String(param1[_loc2_]).toUpperCase().indexOf(this._filterStr) >= 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get configId() : String
      {
         return this._configId;
      }
      
      public function set configId(param1:String) : void
      {
         this._configId = param1;
      }
      
      public function get configuring() : Function
      {
         return this._configuring;
      }
      
      public function set configuring(param1:Function) : void
      {
         this._configuring = param1;
      }
      
      public function getSortState() : Object
      {
         return {
            "activeSortColumnIndex":this.activeSortColumnIndex,
            "activeSortColumnOrder":this.activeSortColumnOrder
         };
      }
      
      private function onGridCreated(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GWizGridColumn = null;
         sortableColumns = false;
         if(!GWizStringUtils.isBlank(this.configId))
         {
            _loc2_ = 0;
            while(_loc2_ < columns.length)
            {
               _loc3_ = columns.getItemAt(_loc2_) as GWizGridColumn;
               _loc3_.parentGrid = this;
               _loc2_++;
            }
            columnHeaderGroup.addEventListener(GridEvent.GRID_CLICK,this.handleHeaderClick);
            addEventListener("dataProviderChanged",this.handleDataProviderChange);
            this.configure();
         }
         this.handleUpdates = true;
      }
      
      private function handleHeaderClick(param1:MouseEvent) : void
      {
         var _loc2_:GWizDataGridSettings = GWizDataGridSettings.create(this);
      }
      
      public function columnMoved(param1:int, param2:int) : void
      {
         if(param1 < this.activeSortColumnIndex && param2 > this.activeSortColumnIndex)
         {
            --this.activeSortColumnIndex;
         }
         else if(param1 == this.activeSortColumnIndex)
         {
            this.activeSortColumnIndex = param2;
         }
         else if(param1 > this.activeSortColumnIndex && param2 <= this.activeSortColumnIndex)
         {
            ++this.activeSortColumnIndex;
         }
         this.sortByColumn();
      }
      
      public function configure() : void
      {
         if(GWizStringUtils.isBlank(this.configId))
         {
            return;
         }
         var _loc1_:GWizDataGridConfig = GWizDataGridConfigs.getInstance().register(this);
         if(this.configuring != null)
         {
            this.configuring(_loc1_);
         }
         this.applyConfig(_loc1_);
         _loc1_.updateFromGrid(this);
         GWizDataGridConfigs.getInstance().addEventListener(GWizDataGridEvent.CONFIG_CHANGED,this.handleConfigChange);
      }
      
      private function handleConfigChange(param1:GWizDataGridEvent) : void
      {
         if(param1.configId != this.configId)
         {
            return;
         }
         this.applyConfig(param1.config as GWizDataGridConfig);
      }
      
      private function applyConfig(param1:GWizDataGridConfig) : void
      {
         var natIds:Object = null;
         var colIdx:int = 0;
         var checkForNewColumns:Boolean = false;
         var newCols:ArrayList = null;
         var cfgCol:GWizDataGridConfigColumn = null;
         var nat:GWizGridColumn = null;
         var natCol:GWizGridColumn = null;
         var config:GWizDataGridConfig = param1;
         var cfgCols:Vector.<GWizDataGridConfigColumn> = config.config;
         this.handleUpdates = false;
         try
         {
            this.activeSortColumnOrder = SORT_NONE;
            natIds = new Object();
            colIdx = 0;
            while(colIdx < columns.length)
            {
               nat = columns.getItemAt(colIdx) as GWizGridColumn;
               if(!GWizStringUtils.isBlank(nat.configId))
               {
                  natIds[nat.configId] = nat;
               }
               colIdx++;
            }
            checkForNewColumns = true;
            newCols = new ArrayList();
            for each(cfgCol in cfgCols)
            {
               if(checkForNewColumns)
               {
                  this.checkForNewCols(newCols,config);
                  checkForNewColumns = false;
               }
               if(natIds.hasOwnProperty(cfgCol.configId))
               {
                  natCol = natIds[cfgCol.configId];
                  newCols.addItem(natCol);
                  checkForNewColumns = true;
                  if(cfgCol.hasSort)
                  {
                     natCol.sortDescending = cfgCol.sortDescending;
                     this.activeSortColumnIndex = newCols.length - 1;
                     this.activeSortColumnOrder = !!cfgCol.sortDescending ? int(SORT_DESCEND) : int(SORT_ASCEND);
                  }
                  if(cfgCol.hasOwnProperty("width"))
                  {
                     natCol.width = cfgCol.width;
                  }
                  natCol.visible = cfgCol.visible;
               }
            }
            if(checkForNewColumns)
            {
               this.checkForNewCols(newCols,config);
            }
            columns = newCols;
            if(dataProvider && this.activeSortColumnIndex != -1)
            {
               this.sortByColumn();
            }
         }
         finally
         {
            this.handleUpdates = true;
         }
      }
      
      private function checkForNewCols(param1:ArrayList, param2:GWizDataGridConfig) : void
      {
         var _loc4_:GWizGridColumn = null;
         var _loc3_:int = param1.length == 0 ? 0 : int(columns.getItemIndex(param1.getItemAt(param1.length - 1)) + 1);
         while(_loc3_ < columns.length)
         {
            if((_loc4_ = columns.getItemAt(_loc3_) as GWizGridColumn).hasOwnProperty("configId") && !GWizStringUtils.isBlank(_loc4_.configId) && param2.hasColConfigId(_loc4_.configId))
            {
               break;
            }
            param1.addItem(_loc4_);
            _loc3_++;
         }
      }
      
      private function handleDataProviderChange(param1:Event) : void
      {
         this.sortByColumn();
      }
      
      public function rotateSortDirection(param1:int) : void
      {
         if(param1 == this.activeSortColumnIndex)
         {
            this.activeSortColumnOrder = ++this.activeSortColumnOrder % SORT_COUNT;
         }
         else
         {
            this.activeSortColumnOrder = SORT_ASCEND;
            this.activeSortColumnIndex = param1;
         }
         this.sortByColumn();
      }
      
      private function sortByColumn() : void
      {
         var _loc1_:GridColumn = null;
         var _loc2_:Vector.<int> = null;
         if(this.activeSortColumnIndex == -1)
         {
            return;
         }
         (dataProvider as ListCollectionView).sort = null;
         if(this.activeSortColumnOrder == SORT_NONE)
         {
            (dataProvider as ListCollectionView).refresh();
            columnHeaderGroup.visibleSortIndicatorIndices = null;
         }
         else
         {
            _loc1_ = columns.getItemAt(this.activeSortColumnIndex) as GridColumn;
            _loc1_.sortDescending = this.activeSortColumnOrder == SORT_DESCEND;
            _loc2_ = new Vector.<int>();
            _loc2_.push(this.activeSortColumnIndex);
            sortByColumns(_loc2_,true);
         }
      }
   }
}
