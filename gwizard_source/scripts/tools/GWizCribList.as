package tools
{
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizCSVUtils;
   import utils.GWizUtils;
   
   public class GWizCribList extends ArrayCollection
   {
      
      private static const log:ILogger = Log.getLogger("GWizCribList");
      
      private static var _1934670470cribList:GWizCribList = new GWizCribList();
      
      private static var _1880487616cribListPlus:GWizCribList = new GWizCribList();
      
      public static const NO_CRIB:String = "<No Crib>";
      
      public static var _479017323TableTypes:ArrayCollection = new ArrayCollection([{"label":"Catalog: Just a collection of tools for my own purposes."},{"label":"Job: Tools needed for a particular job or part program."},{"label":"Machine: Tools located with a machine in toolchanger or spindle."},{"label":"Storage: Tools located in holders in storage."},{"label":"Bin: Loose tools without holders."},{"label":"Cart: Tools located on a cart."}]);
      
      private static const CRIB_LIST_NAME:String = "tooltables.csv";
      
      private static var toolCribListFile:File;
      
      private static var _1876072381ccwCribList:ArrayCollection;
      
      public static const CCW_CRIB_ORDER_FIELD:String = "ccworder";
      
      public static var toolCribListFieldList:Array = ["tabname","description","tabtype","maxslot",CCW_CRIB_ORDER_FIELD,"version"];
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var hashTable:Object;
      
      public function GWizCribList(param1:Array = null)
      {
         this.hashTable = new Object();
         super(param1);
      }
      
      public static function isMaxSlotTable(param1:String) : Boolean
      {
         var _loc4_:Object = null;
         var _loc2_:int = cribList.findTableListIndex(param1);
         var _loc3_:Boolean = false;
         if(_loc2_ >= 0)
         {
            if((_loc4_ = cribList.getItemAt(_loc2_)).maxslot > 0)
            {
               _loc3_ = true;
            }
         }
         return _loc3_;
      }
      
      public static function tableVersion(param1:String) : Number
      {
         var _loc4_:Object = null;
         var _loc2_:int = cribList.findTableListIndex(param1);
         var _loc3_:Number = 0;
         if(_loc2_ >= 0)
         {
            if((_loc4_ = cribList.getItemAt(_loc2_)) && _loc4_.hasOwnProperty("version"))
            {
               _loc3_ = _loc4_.version;
            }
         }
         return _loc3_;
      }
      
      public static function setTableVersion(param1:String, param2:Number) : void
      {
         var _loc5_:Object = null;
         var _loc3_:int = cribList.findTableListIndex(param1);
         var _loc4_:Number = 0;
         if(_loc3_ >= 0)
         {
            (_loc5_ = cribList.getItemAt(_loc3_)).version = param2;
         }
      }
      
      public static function slotsInTable(param1:String) : int
      {
         var _loc4_:Object = null;
         var _loc2_:int = cribList.findTableListIndex(param1);
         var _loc3_:Boolean = false;
         if(_loc2_ >= 0)
         {
            if((_loc4_ = cribList.getItemAt(_loc2_)).maxslot > 0)
            {
               return _loc4_.maxslot;
            }
         }
         return 0;
      }
      
      public static function maxEndmillDiaInCrib(param1:String, param2:Number, param3:int, param4:Boolean, param5:Boolean) : Number
      {
         var _loc6_:GWizToolCribArray = GWizSettings.cribData.currCrib(param1);
         GWizToolCribArray.cribTool = -1;
         if(_loc6_)
         {
            return _loc6_.maxEndmillDiaInCrib(param2,param3,param4,param5);
         }
         return 0;
      }
      
      public static function getCribEntryAt(param1:String, param2:int) : GWizToolCribEntry
      {
         return GWizSettings.cribData.currCrib(param1).getCribEntryAt(param2);
      }
      
      public static function delToolCrib(param1:String, param2:Boolean = false) : void
      {
         var _loc4_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < cribList.length)
         {
            if((_loc4_ = cribList.getItemAt(_loc3_)).tabname == param1)
            {
               cribList.removeItemAt(_loc3_);
               if(param2 && GWizToolCribData.ToolCrib)
               {
                  GWizToolCribData.ToolCrib.filterCribByTabname(param1);
                  GWizToolCribData.ToolCrib.removeAll();
                  GWizToolCribData.ToolCrib.unFilterCrib();
               }
               return;
            }
            _loc3_++;
         }
      }
      
      private static function getCribListFileExternal(param1:Boolean = false) : File
      {
         return GWizAbstractPrefs.getShareablePrefsFile(CRIB_LIST_NAME,param1);
      }
      
      public static function loadToolCribList() : void
      {
         var stream:FileStream = null;
         var ac:ArrayCollection = null;
         var j:int = 0;
         var tableObj:Object = null;
         var entry:Object = null;
         cribList.removeAll();
         toolCribListFile = getCribListFileExternal();
         try
         {
            stream = new FileStream();
            if(toolCribListFile.exists)
            {
               ac = GWizCSVUtils.loadCSVFile(toolCribListFile,true,true,toolCribListFieldList);
               j = 0;
               while(j < ac.length)
               {
                  tableObj = ac.getItemAt(j);
                  cribList.addItem(tableObj);
                  if(false && GWizUtils.debug)
                  {
                     log.debug("tabname = " + tableObj.tabname);
                     if(tableObj.hasOwnProperty("description"))
                     {
                        log.debug("description = \'" + tableObj.description + "\'");
                     }
                     if(tableObj.hasOwnProperty("tabtype"))
                     {
                        log.debug("tabtype = \'" + String(tableObj.tabtype) + "\'");
                     }
                     if(tableObj.hasOwnProperty("maxslot"))
                     {
                        log.debug("maxslot = \'" + String(tableObj.maxslot) + "\'");
                     }
                  }
                  j++;
               }
               ccwCribList = GWizCribList.createCCWCribList();
               if(GWizSettings.prefs.sharePrefs && !getCribListFileExternal().exists)
               {
                  saveToolCribList();
               }
            }
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error reading or writing the Tool Crib List. Error = " + e.message);
         }
         GWizSettings.cribData.rebuildTableList();
         var i:int = 0;
         while(i < cribList.length)
         {
            entry = cribList.getItemAt(i);
            if(!entry.hasOwnProperty("maxslot"))
            {
               entry.maxslot = int(entry.maxslot);
               entry.maxslot = Math.max(0,Math.min(entry.maxslot,1000));
            }
            if(!entry.hasOwnProperty("tabtype"))
            {
               entry.tabtype = int(entry.tabtype);
               entry.tabtype = Math.max(0,Math.min(entry.tabtype,TableTypes.length - 1));
            }
            if(false && GWizUtils.debug)
            {
               log.debug("tabname = " + entry.tabname);
               if(entry.hasOwnProperty("description"))
               {
                  log.debug("description = \'" + entry.description + "\'");
               }
               if(entry.hasOwnProperty("tabtype"))
               {
                  log.debug("tabtype = \'" + String(entry.tabtype) + "\'");
               }
               if(entry.hasOwnProperty("maxslot"))
               {
                  log.debug("maxslot = \'" + String(entry.maxslot) + "\'");
               }
            }
            i++;
         }
      }
      
      public static function saveToolCribList(param1:Boolean = false) : void
      {
         var _loc5_:Object = null;
         var _loc6_:Boolean = false;
         if(param1)
         {
            toolCribListFile = getCribListFileExternal(false);
         }
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         while(_loc4_ < cribList.length)
         {
            _loc5_ = cribList.getItemAt(_loc4_);
            _loc6_ = false;
            if(_loc5_.tabname == NO_CRIB)
            {
               _loc3_ = _loc5_;
               _loc6_ = true;
            }
            if(_loc6_)
            {
               cribList.removeItemAt(_loc4_);
               _loc4_ = Math.max(0,_loc4_ - 1);
            }
            _loc4_++;
         }
         GWizCSVUtils.saveCSVFileURL(toolCribListFile.url,cribList,toolCribListFieldList);
         if(_loc3_)
         {
            cribList.addItemAt(_loc3_,0);
         }
         else if(_loc2_)
         {
            cribList.addItemAt(_loc2_,0);
         }
      }
      
      public static function createCCWCribList() : ArrayCollection
      {
         var _loc3_:Object = null;
         var _loc4_:Number = NaN;
         var _loc1_:ArrayCollection = new ArrayCollection();
         var _loc2_:int = 0;
         while(_loc2_ < cribList.length)
         {
            _loc3_ = cribList.getItemAt(_loc2_);
            if(_loc3_.hasOwnProperty(CCW_CRIB_ORDER_FIELD))
            {
               if((_loc4_ = _loc3_[CCW_CRIB_ORDER_FIELD]) > 0)
               {
                  _loc1_.addItem(_loc3_);
               }
            }
            _loc2_++;
         }
         GWizUtils.arrayCollectionSort(_loc1_,CCW_CRIB_ORDER_FIELD,true);
         return _loc1_;
      }
      
      public static function ccwCribListAdd(param1:Object, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(ccwCribList)
         {
            _loc3_ = 0;
            while(_loc3_ < ccwCribList.length)
            {
               if((_loc4_ = ccwCribList.getItemAt(_loc3_)).tabname == param1.tabname)
               {
                  return;
               }
               _loc3_++;
            }
            ccwCribList.addItemAt(param1,param2);
            renumberCCWCribList();
         }
      }
      
      public static function ccwCribListDel(param1:int) : void
      {
         var _loc2_:Object = null;
         if(ccwCribList && param1 >= 0)
         {
            _loc2_ = ccwCribList.getItemAt(param1);
            _loc2_[CCW_CRIB_ORDER_FIELD] = 0;
            ccwCribList.removeItemAt(param1);
            renumberCCWCribList();
         }
      }
      
      public static function ccwCribListUp(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         if(ccwCribList && param1 > 0)
         {
            _loc2_ = ccwCribList.getItemAt(param1);
            _loc3_ = Number(_loc2_[CCW_CRIB_ORDER_FIELD]) - 1.5;
            _loc2_[CCW_CRIB_ORDER_FIELD] = _loc3_;
            renumberCCWCribList();
         }
      }
      
      public static function ccwCribListDown(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         if(ccwCribList && param1 >= 0)
         {
            _loc2_ = ccwCribList.getItemAt(param1);
            _loc3_ = Number(_loc2_[CCW_CRIB_ORDER_FIELD]) + 1.5;
            _loc2_[CCW_CRIB_ORDER_FIELD] = _loc3_;
            renumberCCWCribList();
         }
      }
      
      private static function renumberCCWCribList() : void
      {
         var _loc2_:Object = null;
         GWizUtils.arrayCollectionSort(ccwCribList,CCW_CRIB_ORDER_FIELD,true);
         var _loc1_:int = 0;
         while(_loc1_ < ccwCribList.length)
         {
            _loc2_ = ccwCribList.getItemAt(_loc1_);
            _loc2_[CCW_CRIB_ORDER_FIELD] = _loc1_ + 1;
            _loc1_++;
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get cribList() : GWizCribList
      {
         return GWizCribList._1934670470cribList;
      }
      
      public static function set cribList(param1:GWizCribList) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCribList._1934670470cribList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCribList,"cribList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get cribListPlus() : GWizCribList
      {
         return GWizCribList._1880487616cribListPlus;
      }
      
      public static function set cribListPlus(param1:GWizCribList) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCribList._1880487616cribListPlus;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCribList,"cribListPlus",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get TableTypes() : ArrayCollection
      {
         return GWizCribList._479017323TableTypes;
      }
      
      public static function set TableTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCribList._479017323TableTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCribList,"TableTypes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get ccwCribList() : ArrayCollection
      {
         return GWizCribList._1876072381ccwCribList;
      }
      
      public static function set ccwCribList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCribList._1876072381ccwCribList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCribList,"ccwCribList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function allowAllTables() : Boolean
      {
         return false;
      }
      
      public function findTableListIndex(param1:String) : Number
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.length)
         {
            _loc3_ = this.getItemAt(_loc2_);
            if(_loc3_.tabname == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      override public function addItem(param1:Object) : void
      {
         GWizUtils.assert(param1.tabname != "");
         if(!this.hashTable.hasOwnProperty(param1.tabname))
         {
            super.addItem(param1);
            this.hashTable[param1.tabname] = true;
         }
      }
      
      override public function addItemAt(param1:Object, param2:int) : void
      {
         GWizUtils.assert(param1.tabname != "");
         if(!this.hashTable.hasOwnProperty(param1.tabname))
         {
            super.addItemAt(param1,param2);
            this.hashTable[param1.tabname] = true;
         }
      }
      
      override public function removeAll() : void
      {
         super.removeAll();
         this.hashTable = new Object();
      }
      
      override public function removeItemAt(param1:int) : Object
      {
         var _loc2_:Object = null;
         if(0 <= param1 && param1 < this.length)
         {
            _loc2_ = this.getItemAt(param1);
            super.removeItemAt(param1);
            delete this.hashTable[_loc2_.tabname];
         }
         return _loc2_;
      }
      
      public function removeCribByName(param1:String) : void
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.length)
         {
            _loc3_ = this.getItemAt(_loc2_);
            if(_loc3_.tabname == param1)
            {
               this.removeItemAt(_loc2_);
               return;
            }
            _loc2_++;
         }
      }
   }
}
