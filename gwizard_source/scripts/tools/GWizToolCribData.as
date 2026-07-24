package tools
{
   import comps.GWizFileBrowser;
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import machines.GWizMachSettings;
   import mx.collections.ArrayCollection;
   import mx.collections.Sort;
   import mx.collections.SortField;
   import mx.events.CloseEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GATracker;
   import utils.GWizCSVUtils;
   import utils.GWizJustASec;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizToolCribData implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizToolCribData");
      
      private static var theCribTable:GWizCribList = new GWizCribList();
      
      public static var appHasToolCrib:Boolean = true;
      
      public static var onTableChooserFcn:Function;
      
      private static var _919441504ToolCrib:GWizToolCribArray = null;
      
      private static var _1927639697defToolTable:ArrayCollection = new ArrayCollection([{
         "key":0,
         "tabname":"Default",
         "machname":"VMC",
         "slot":0,
         "description":"1/2 inch 2 flute endmill",
         "tool":"HSS Endmill",
         "flutes":"2",
         "geometry":"Normal",
         "leadang":"90",
         "diameter":"0.500",
         "stickout":"1.0",
         "cutLength":"1.0",
         "noseRad":"0.0",
         "sfm":"1.0",
         "chipload":"1.0",
         "generic":false,
         "xcomp":0,
         "zcomp":0,
         "xgeom":0,
         "zgeom":0,
         "serialno":"",
         "vendor":"",
         "product":"",
         "idNo":"",
         "insNo":"",
         "useMfgSFM":false,
         "useMfgIPT":false,
         "mfgSFM":0,
         "mfgIPT":0,
         "shankSize":"0.5",
         "units":GWizToolCribEntry.INCHES_UNIT
      },{
         "key":1,
         "tabname":"Default",
         "machname":"VMC",
         "slot":1,
         "description":"1/2 inch 4 flute endmill",
         "tool":"HSS Endmill",
         "flutes":"4",
         "geometry":"Normal",
         "leadang":"90",
         "diameter":"0.500",
         "stickout":"1.0",
         "cutLength":"1.0",
         "noseRad":"0.0",
         "sfm":"1.0",
         "chipload":"1.0",
         "generic":false,
         "xcomp":0,
         "zcomp":0,
         "xgeom":0,
         "zgeom":0,
         "serialno":"",
         "vendor":"",
         "product":"",
         "idNo":"",
         "insNo":"",
         "useMfgSFM":false,
         "useMfgIPT":false,
         "mfgSFM":0,
         "mfgIPT":0,
         "shankSize":"0.5"
      },{
         "key":2,
         "tabname":"Default",
         "machname":"VMC",
         "slot":2,
         "description":"1/2 inch spot drill",
         "tool":"HSS Spot Drill",
         "flutes":"2",
         "geometry":"Normal",
         "leadang":"90",
         "diameter":"0.500",
         "stickout":"1.0",
         "cutLength":"0.5",
         "noseRad":"0.0",
         "sfm":"1.0",
         "chipload":"1.0",
         "generic":false,
         "xcomp":0,
         "zcomp":0,
         "xgeom":0,
         "zgeom":0,
         "serialno":"",
         "vendor":"",
         "product":"",
         "idNo":"",
         "insNo":"",
         "useMfgSFM":false,
         "useMfgIPT":false,
         "mfgSFM":0,
         "mfgIPT":0,
         "shankSize":"0.5"
      }]);
      
      private static const OLD_TOOLCRIB_NAME:String = "toolcrib.xml";
      
      private static const TOOLCRIB_NAME:String = "toolcrib.csv";
      
      private static var justReportSaveOnce:Boolean = false;
      
      private static var renumberCribName:String;
      
      private static var renumberSlots:int;
      
      private static var changesAfoot:Boolean;
      
      private static var _1315809025genericToolTable:ArrayCollection = new ArrayCollection([{
         "key":0,
         "tabname":"Default",
         "tabdesc":"",
         "machname":"VMC",
         "slot":0,
         "description":"1/2 inch 2 flute endmill",
         "tool":"HSS Endmill",
         "flutes":"2",
         "geometry":"Normal",
         "leadang":"90",
         "diameter":"0.500",
         "stickout":"1.0",
         "cutLength":"1.0",
         "noseRad":"0.0",
         "sfm":"1.0",
         "chipload":"1.0",
         "generic":false,
         "xcomp":0,
         "zcomp":0,
         "serialno":"",
         "vendor":"",
         "product":"",
         "idNo":"",
         "insNo":"",
         "useMfgSFM":false,
         "useMfgIPT":false,
         "mfgSFM":0,
         "mfgIPT":0
      },{
         "key":1,
         "tabname":"Default",
         "machname":"VMC",
         "slot":2,
         "description":"1/2 inch twist drill",
         "tool":"HSS Spot Drill",
         "flutes":"2",
         "geometry":"Normal",
         "leadang":"90",
         "diameter":"0.500",
         "stickout":"1.0",
         "cutLength":"1.0",
         "noseRad":"0.0",
         "sfm":"1.0",
         "chipload":"1.0",
         "generic":false,
         "xcomp":0,
         "zcomp":0,
         "serialno":"",
         "vendor":"",
         "product":"",
         "idNo":"",
         "insNo":"",
         "useMfgSFM":false,
         "useMfgIPT":false,
         "mfgSFM":0,
         "mfgIPT":0
      }]);
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var OEMCribName:String = "";
      
      private var loadMsg:GWizLoadingOEMCribPopup = null;
      
      private var cribEntryTabname:String = "";
      
      private var cribEntryIndex:int = -1;
      
      private var cribEntryCache:GWizToolCribEntry = null;
      
      public var dontFilter:Boolean = false;
      
      private var toolCribFile:File;
      
      private var maxToolCribKey:int = 0;
      
      public var cribFiles:GWizFileBrowser;
      
      private const GENERIC_ENDMILL:int = 0;
      
      private const GENERIC_TWIST_DRILL:int = 1;
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizToolCribData()
      {
         this.cribFiles = new GWizFileBrowser("ToolCribs","CSV","*.csv");
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         var _loc1_:GWizJustASec = new GWizJustASec(this.loadToolCrib);
      }
      
      public static function isCrib(param1:String) : Boolean
      {
         return ToolCrib && param1 != GWizCribList.NO_CRIB && param1 != "" && param1 != null;
      }
      
      public static function getCribFileExternal(param1:Boolean = false) : File
      {
         return GWizAbstractPrefs.getShareablePrefsFile(TOOLCRIB_NAME,param1);
      }
      
      public static function setMaxSlots(param1:String, param2:int, param3:Boolean = true) : void
      {
         var _loc4_:String = null;
         var _loc5_:* = 0;
         if(param2 <= 0)
         {
            return;
         }
         renumberCribName = param1;
         renumberSlots = param2;
         renumberConfirm(null,param3);
         if(changesAfoot && param3)
         {
            _loc4_ = "Max Slots changed.  Renumber slots and delete any excess slots?";
            _loc5_ = GWizPopUpManager.YES | GWizPopUpManager.NO | GWizPopUpManager.CANCEL;
            GWizPopUpManager.Show(_loc4_,"Renumber Crib Table...",_loc5_ | GWizPopUpManager.WARN,null,renumberConfirm);
         }
      }
      
      private static function renumberConfirm(param1:CloseEvent, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:Function = null;
         var _loc6_:Array = null;
         var _loc7_:Object = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:GWizToolCribEntry = null;
         var _loc12_:int = 0;
         changesAfoot = false;
         if(param2 || !param1 || param1.detail == GWizPopUpManager.YES)
         {
            _loc3_ = renumberCribName;
            _loc4_ = renumberSlots;
            _loc5_ = ToolCrib.filterFunction;
            ToolCrib.unFilterCrib();
            _loc6_ = [];
            _loc8_ = 0;
            while(_loc8_ <= _loc4_)
            {
               (_loc7_ = new Object()).number = -1;
               _loc6_[_loc8_] = _loc7_;
               _loc8_++;
            }
            _loc9_ = 0;
            while(_loc9_ < 2)
            {
               _loc10_ = 0;
               _loc8_ = 0;
               while(_loc8_ < ToolCrib.length)
               {
                  if((_loc11_ = ToolCrib.getCribEntryAt(_loc8_)).tabname == _loc3_)
                  {
                     _loc10_++;
                     if(_loc10_ > _loc4_)
                     {
                        changesAfoot = true;
                        if(param2)
                        {
                           break;
                        }
                        ToolCrib.removeItemAt(_loc8_);
                        _loc10_ = _loc4_;
                     }
                     else if(_loc9_ == 0)
                     {
                        if(_loc6_[_loc11_.slot].number != -1)
                        {
                           _loc11_.slot = 0;
                        }
                        else
                        {
                           _loc6_[_loc11_.slot].number = 0;
                        }
                     }
                  }
                  _loc8_++;
               }
               _loc9_++;
            }
            if(_loc10_ < _loc4_ && param2)
            {
               changesAfoot = true;
            }
            else
            {
               while(_loc10_ < _loc4_)
               {
                  (_loc11_ = new GWizToolCribEntry()).tabname = _loc3_;
                  ToolCrib.addCribEntry(_loc11_);
                  _loc10_++;
               }
            }
            _loc8_ = 0;
            for(; _loc8_ < ToolCrib.length; _loc8_++)
            {
               if((_loc11_ = ToolCrib.getCribEntryAt(_loc8_)).tabname == _loc3_ && _loc11_.slot <= 0)
               {
                  if(param2)
                  {
                     changesAfoot = true;
                  }
                  _loc12_ = 0;
                  while(_loc12_ < _loc6_.length)
                  {
                     if(_loc6_[_loc12_].number == -1)
                     {
                        _loc11_.slot = _loc12_;
                        _loc6_[_loc12_].number = 0;
                        break;
                     }
                     _loc12_++;
                  }
                  continue;
                  break;
               }
            }
            if(false && GWizUtils.debug)
            {
               _loc8_ = 0;
               while(_loc8_ < ToolCrib.length)
               {
                  if((_loc11_ = ToolCrib.getCribEntryAt(_loc8_)).tabname == _loc3_)
                  {
                     log.debug("Crib entry " + _loc8_ + " slot = " + _loc11_.slot);
                  }
                  _loc8_++;
               }
            }
            ToolCrib.filterCrib();
         }
      }
      
      public static function delFirstEmptySlot(param1:String) : void
      {
         var _loc4_:GWizToolCribEntry = null;
         var _loc2_:Function = ToolCrib.filterFunction;
         ToolCrib.unFilterCrib();
         var _loc3_:int = 0;
         while(_loc3_ < ToolCrib.length)
         {
            if((_loc4_ = ToolCrib.getCribEntryAt(_loc3_)).tabname == param1 && _loc4_.tool == GWizToolData.EMPTY_SLOT)
            {
               ToolCrib.removeItemAt(_loc3_);
               return;
            }
            _loc3_++;
         }
         ToolCrib.filterCrib();
      }
      
      [Bindable(event="propertyChange")]
      public static function get ToolCrib() : GWizToolCribArray
      {
         return GWizToolCribData._919441504ToolCrib;
      }
      
      public static function set ToolCrib(param1:GWizToolCribArray) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCribData._919441504ToolCrib;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCribData,"ToolCrib",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get defToolTable() : ArrayCollection
      {
         return GWizToolCribData._1927639697defToolTable;
      }
      
      public static function set defToolTable(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCribData._1927639697defToolTable;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCribData,"defToolTable",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get genericToolTable() : ArrayCollection
      {
         return GWizToolCribData._1315809025genericToolTable;
      }
      
      public static function set genericToolTable(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCribData._1315809025genericToolTable;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCribData,"genericToolTable",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      private function getCribMfgData(param1:String, param2:int) : Object
      {
         if(!ToolCrib || param1 == "")
         {
            return null;
         }
         var _loc3_:Object = null;
         var _loc4_:Object;
         if((_loc4_ = this.getCribEntry(param1,param2)) != null)
         {
            _loc3_ = new Object();
            _loc3_.useMfgSFM = _loc4_.useMfgSFM;
            _loc3_.mfgSFM = _loc4_.mfgSFM;
            _loc3_.useMfgIPT = _loc4_.useMfgIPT;
            _loc3_.mfgIPT = _loc4_.mfgIPT;
            _loc3_.toolFamily = _loc4_.toolFamily;
         }
         return _loc3_;
      }
      
      private function getCribToolDef(param1:String, param2:int, param3:GWizToolDef) : GWizToolDef
      {
         var _loc5_:GWizToolCribEntry = null;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         if(!ToolCrib || param1 == "")
         {
            return null;
         }
         var _loc4_:GWizToolCribArray = this.currCrib(param1);
         if(param2 < _loc4_.length)
         {
            _loc5_ = _loc4_.getCribEntryAt(param2);
         }
         if(false && GWizUtils.debug)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc4_.length)
            {
               _loc5_ = _loc4_.getCribEntryAt(_loc6_);
               log.debug("Crib[" + _loc6_ + "] = description:" + _loc5_.description + ", diameter:" + _loc5_.diameter + ", flutes:" + _loc5_.flutes);
               _loc6_++;
            }
            _loc5_ = _loc4_.getCribEntryAt(param2);
         }
         if(_loc5_ != null)
         {
            param3._toolDiameter.setVal(_loc5_.diameter);
            param3._flutes.value = _loc5_.flutes;
            if(_loc5_.hasOwnProperty("shankSize"))
            {
               if((_loc7_ = _loc5_.shankSize) < 0.005)
               {
                  _loc7_ = _loc5_.diameter;
               }
               param3.setGeometryParms(_loc5_.geometry,_loc7_ != _loc5_.diameter,_loc7_);
            }
            else
            {
               param3.setGeometry(_loc5_.geometry);
            }
            param3._LeadAngle.value = _loc5_.leadang;
            param3.toolParms.leadAngle = _loc5_.leadang;
            param3._stickout.setVal(_loc5_.stickout);
            param3.toolParms.cutLength = _loc5_.cutLength;
            param3.toolParms.overallLength = _loc5_.overallLength;
            param3.toolParms.noseRad = _loc5_.noseRad;
         }
         return param3;
      }
      
      private function getCribToolType(param1:String, param2:int, param3:String) : String
      {
         var _loc4_:GWizToolCribEntry;
         if((_loc4_ = this.getCribEntry(param1,param2)) != null)
         {
            param3 = _loc4_.tool;
         }
         return param3;
      }
      
      public function getCribToolDesc(param1:int, param2:String) : String
      {
         ToolCrib.unFilterCrib();
         var _loc3_:GWizToolCribEntry = ToolCrib.getCribEntryAt(param1);
         if(_loc3_ != null)
         {
            param2 = _loc3_.description;
         }
         this.onTableChooser();
         return param2;
      }
      
      public function getCribSlot(param1:int) : int
      {
         return ToolCrib.getCribEntryAt(param1).slot;
      }
      
      private function getCribGeneric(param1:String, param2:int) : Boolean
      {
         if(param1 == "" || param1.charAt(0) == "<" || !ToolCrib || ToolCrib.length <= 0)
         {
            return false;
         }
         GWizToolCribData.ToolCrib.filterCrib();
         param2 = Math.max(Math.min(param2,ToolCrib.length - 1),0);
         var _loc3_:* = ToolCrib.getCribEntryAt(param2).generic == "true";
         GWizToolCribData.ToolCrib.unFilterCrib();
         this.onTableChooser();
         return _loc3_;
      }
      
      public function checkOEMCribExists(param1:String) : void
      {
      }
      
      private function cribLoaded(param1:String, param2:String) : void
      {
         var _loc3_:ArrayCollection = GWizCSVUtils.CSVToArrayCol(param1,",");
         if(_loc3_ && _loc3_.length > 0)
         {
            this.importCSVToolTable(_loc3_,this.OEMCribName + ".csv");
            if(this.loadMsg)
            {
               this.loadMsg.close();
               this.loadMsg = null;
            }
         }
      }
      
      public function currToolList(param1:String) : Array
      {
         var _loc5_:GWizToolCribEntry = null;
         var _loc6_:String = null;
         var _loc2_:Array = null;
         ToolCrib.unFilterCrib();
         if(ToolCrib.length > 0)
         {
            _loc2_ = [];
         }
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < ToolCrib.length)
         {
            if((_loc5_ = ToolCrib.getCribEntryAt(_loc4_)).tabname == param1)
            {
               _loc6_ = "T" + _loc5_.slot + ": " + _loc5_.description;
               var _loc7_:*;
               _loc2_[_loc7_ = _loc3_++] = _loc6_;
            }
            _loc4_++;
         }
         this.onTableChooser();
         return _loc2_;
      }
      
      public function currCrib(param1:String) : GWizToolCribArray
      {
         var _loc5_:GWizToolCribEntry = null;
         var _loc2_:GWizToolCribArray = new GWizToolCribArray();
         ToolCrib.unFilterCrib();
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < ToolCrib.length)
         {
            if((_loc5_ = ToolCrib.getCribEntryAt(_loc4_)).tabname == param1)
            {
               _loc2_.addCribEntry(_loc5_);
            }
            _loc4_++;
         }
         this.onTableChooser();
         return _loc2_;
      }
      
      public function sortToolCrib(param1:ArrayCollection) : void
      {
         var _loc2_:SortField = new SortField();
         _loc2_.name = "slot";
         _loc2_.numeric = true;
         var _loc3_:Sort = new Sort();
         _loc3_.fields = [_loc2_];
         param1.sort = _loc3_;
         param1.refresh();
      }
      
      public function getKeyForSlot(param1:String, param2:int) : int
      {
         var _loc6_:GWizToolCribEntry = null;
         ToolCrib.unFilterCrib();
         var _loc3_:int = 0;
         var _loc4_:int = -1;
         var _loc5_:int = 0;
         while(_loc5_ < ToolCrib.length)
         {
            if((_loc6_ = ToolCrib.getCribEntryAt(_loc5_)).tabname == param1 && _loc6_.slot == param2)
            {
               _loc4_ = _loc6_.key;
               _loc3_++;
            }
            _loc5_++;
         }
         this.onTableChooser();
         if(_loc3_ > 1)
         {
            _loc4_ = -1;
         }
         return _loc4_;
      }
      
      public function getDescFromKey(param1:int) : String
      {
         var _loc3_:GWizToolCribEntry = null;
         var _loc4_:String = null;
         ToolCrib.unFilterCrib();
         var _loc2_:int = 0;
         while(_loc2_ < ToolCrib.length)
         {
            _loc3_ = ToolCrib.getCribEntryAt(_loc2_);
            if(_loc3_.key == param1)
            {
               return _loc3_.description;
            }
            _loc2_++;
         }
         this.onTableChooser();
         return "";
      }
      
      public function getKeyFromDesc(param1:String, param2:String) : int
      {
         var _loc6_:GWizToolCribEntry = null;
         var _loc7_:String = null;
         ToolCrib.unFilterCrib();
         param2 = GWizStringUtils.zapWhiteSpace(param2.toUpperCase());
         var _loc3_:int = 0;
         var _loc4_:int = -1;
         var _loc5_:int = 0;
         while(_loc5_ < ToolCrib.length)
         {
            _loc7_ = (_loc6_ = ToolCrib.getCribEntryAt(_loc5_)).description;
            _loc7_ = GWizStringUtils.zapWhiteSpace(_loc7_.toUpperCase());
            if(_loc6_.tabname == param1 && _loc7_ == param2)
            {
               _loc4_ = _loc6_.key;
               _loc3_++;
            }
            _loc5_++;
         }
         this.onTableChooser();
         if(_loc3_ > 1)
         {
            _loc4_ = -1;
         }
         return _loc4_;
      }
      
      public function flushGetCribEntryCache() : void
      {
         this.cribEntryTabname = "";
         this.cribEntryIndex = -1;
      }
      
      private function getCribEntry(param1:String, param2:int) : GWizToolCribEntry
      {
         var _loc3_:GWizToolCribEntry = null;
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         if(this.cribEntryTabname == param1 && this.cribEntryIndex == param2 && this.cribEntryCache)
         {
            return this.cribEntryCache;
         }
         if(ToolCrib)
         {
            _loc4_ = false;
            if(ToolCrib.filterFunction != ToolCrib.filterTC)
            {
               ToolCrib.filterFunction = ToolCrib.filterTC;
               _loc4_ = true;
            }
            _loc5_ = ToolCrib.tcFilter;
            if(ToolCrib.tcFilter != param1)
            {
               ToolCrib.tcFilter = param1;
               _loc4_ = true;
            }
            if(_loc4_)
            {
               ToolCrib.refresh();
            }
            if(param2 < ToolCrib.length)
            {
               _loc3_ = ToolCrib.getCribEntryAt(param2);
            }
            if(_loc4_)
            {
               ToolCrib.tcFilter = _loc5_;
               this.onTableChooser();
            }
         }
         this.cribEntryTabname = param1;
         this.cribEntryIndex = param2;
         this.cribEntryCache = this.cribEntryCache;
         return _loc3_;
      }
      
      private function onTableChooser() : void
      {
         if(onTableChooserFcn != null)
         {
            onTableChooserFcn();
         }
      }
      
      private function initDefCrib() : GWizToolCribArray
      {
         var _loc3_:GWizToolCribEntry = null;
         var _loc1_:GWizToolCribArray = new GWizToolCribArray();
         var _loc2_:int = 0;
         while(_loc2_ < defToolTable.length)
         {
            _loc3_ = this.newToolTabObject(defToolTable.getItemAt(_loc2_),"Default");
            _loc1_.addCribEntry(_loc3_);
            _loc2_++;
         }
         GWizUtils.assert(_loc1_ != null);
         return _loc1_;
      }
      
      public function getCribFile(param1:Boolean = false) : File
      {
         this.toolCribFile = getCribFileExternal(param1);
         return this.toolCribFile;
      }
      
      public function loadToolCrib() : void
      {
         var stream:FileStream = null;
         var i:int = 0;
         var item:GWizToolCribEntry = null;
         if(!appHasToolCrib)
         {
            return;
         }
         if(!ToolCrib)
         {
            ToolCrib = this.initDefCrib();
         }
         this.toolCribFile = this.getCribFile();
         try
         {
            stream = new FileStream();
            if(this.toolCribFile.exists)
            {
               if(GWizSettings.DEBUG_SHARING)
               {
                  log.debug("Tool Crib File \'" + this.toolCribFile.nativePath + "\'");
               }
               ToolCrib = GWizToolCribArray.ACToToolCrib(GWizCSVUtils.loadCSVFile(this.toolCribFile,true,true));
               if(false && GWizUtils.debug)
               {
                  GWizUtils.assert(ToolCrib && ToolCrib.length > 0);
                  i = 0;
                  while(i < ToolCrib.length)
                  {
                     item = ToolCrib.getCribEntryAt(i);
                     log.debug("ToolCrib[" + String(i) + "]: key(" + String(item.key) + ") tabname(" + item.tabname + ") machname(" + item.machname + ")");
                     i++;
                  }
                  log.debug("*** End ToolCrib ***");
               }
               this.legacyCSVCleanup(ToolCrib);
               if(GWizSettings.prefs.sharePrefs && !this.getCribFile().exists)
               {
                  this.saveToolCrib();
               }
            }
            else
            {
               this.saveToolCrib();
            }
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error reading or writing the Tool Crib.");
            ToolCrib = initDefCrib();
         }
         GWizCribList.loadToolCribList();
      }
      
      private function legacyCSVCleanup(param1:GWizToolCribArray) : void
      {
         var _loc5_:int = 0;
         var _loc6_:GWizToolCribEntry = null;
         var _loc8_:GWizToolData = null;
         var _loc9_:String = null;
         var _loc2_:String = "";
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc7_:Object = new Object();
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            if((_loc6_ = param1.getCribEntryAt(_loc5_)).hasOwnProperty("tabname") && String(_loc6_.tabname).length > 0 && String(_loc6_.tabname) != " ")
            {
               if(_loc2_ != "")
               {
                  _loc2_ = _loc6_.tabname;
               }
            }
            else
            {
               if(_loc2_ == "")
               {
                  _loc2_ = "ToolCrib";
               }
               _loc6_.tabname = _loc2_;
            }
            if(_loc6_.hasOwnProperty("stickout") && _loc6_.stickout <= 0)
            {
               _loc6_.stickout = _loc6_.cutLength + _loc6_.diameter;
            }
            if(_loc6_.hasOwnProperty("coating") || _loc6_.hasOwnProperty("toolmaterial"))
            {
               if(_loc6_.tool.indexOf("HP") < 0)
               {
                  (_loc8_ = new GWizToolData()).coating = _loc6_.coating;
                  _loc8_.toolmaterial = _loc6_.toolmaterial;
                  _loc8_.toolType = _loc6_.tool;
                  if(_loc8_.isHPToolFromMaterialAndCoating())
                  {
                     _loc9_ = _loc8_.toolType;
                     _loc8_.toolType = "HP " + _loc8_.toolType;
                     if(!_loc8_.validToolType())
                     {
                        _loc8_.toolType = _loc9_;
                     }
                     _loc6_.tool = _loc8_.toolType;
                  }
               }
            }
            if(_loc6_.guid == "")
            {
            }
            if(_loc7_.hasOwnProperty(_loc6_.guid))
            {
               _loc6_.guid = "";
            }
            else
            {
               _loc7_[_loc6_.guid] = true;
            }
            _loc5_++;
         }
      }
      
      public function saveToolCrib(param1:Boolean = false) : void
      {
         if(!appHasToolCrib)
         {
            return;
         }
         if(GWizSettings.prefs.sharePrefs && !GWizAbstractPrefs.gotLock())
         {
            return;
         }
         if(param1)
         {
            this.toolCribFile = this.getCribFile(false);
         }
         ToolCrib.unFilterCrib();
         if(!justReportSaveOnce && ToolCrib && GWizCribList.cribList)
         {
            GATracker.logPageView("ToolCrib/" + ToolCrib.length + "CribTools","ToolCrib/" + ToolCrib.length + "CribTools");
            GATracker.logPageView("ToolCrib/" + GWizCribList.cribList.length + "Tables","ToolCrib/" + GWizCribList.cribList.length + "Tables");
            justReportSaveOnce = true;
         }
         var _loc2_:Array = [];
         _loc2_.push("key");
         _loc2_.push("tabname");
         _loc2_.push("guid");
         var _loc3_:int = 0;
         while(_loc3_ < GWizToolCribEntry.toolCribFieldList.length)
         {
            _loc2_.push(GWizToolCribEntry.toolCribFieldList[_loc3_]);
            _loc3_++;
         }
         var _loc4_:* = this.toolCribFile.url;
         var _loc5_:String;
         if((_loc5_ = _loc4_.substr(_loc4_.length - 3,3)).toLowerCase() == "xml")
         {
            _loc4_ = (_loc4_ = _loc4_.substr(0,_loc4_.length - 3)) + "csv";
            this.toolCribFile.url = _loc4_;
         }
         GWizCSVUtils.saveCSVFileURL(this.toolCribFile.url,ToolCrib,_loc2_);
         GWizCribList.saveToolCribList();
         this.onTableChooser();
      }
      
      public function resetToolCrib() : void
      {
         GWizSettings.saveToolCrib = false;
         var _loc1_:File = this.getCribFile();
         _loc1_.deleteFile();
      }
      
      public function newToolTabObject(param1:Object, param2:String) : GWizToolCribEntry
      {
         if(!param1)
         {
            return null;
         }
         var _loc3_:GWizToolCribEntry = new GWizToolCribEntry(param1);
         _loc3_.tabname = param2;
         return _loc3_;
      }
      
      private function importTablePrefix(param1:ArrayCollection, param2:String) : String
      {
         if(!param1)
         {
            return "";
         }
         var _loc3_:int = param2.length - 1;
         while(_loc3_ > 0)
         {
            if(param2.charAt(_loc3_) == ".")
            {
               break;
            }
            _loc3_--;
         }
         if(param2.charAt(_loc3_) == ".")
         {
            _loc3_ = Math.max(0,_loc3_);
            param2 = param2.substr(0,_loc3_);
         }
         if(param2.length <= 0)
         {
            GWizPopUpManager.Show("Tool table import error.","Error: Invalid File Name",GWizPopUpManager.ERROR);
            return "";
         }
         var _loc4_:String = ToolCrib.tcFilter;
         ToolCrib.tcFilter = param2;
         ToolCrib.filterCrib();
         var _loc5_:int = ToolCrib.length;
         ToolCrib.tcFilter = _loc4_;
         this.onTableChooser();
         if(_loc5_ > 0)
         {
            GWizPopUpManager.Show("A table named " + param2 + " already exists. Please delete it before importing.","Error: Table Exists",GWizPopUpManager.ERROR);
            return "";
         }
         return param2;
      }
      
      public function importCSVToolTable(param1:ArrayCollection, param2:String) : void
      {
         var _loc5_:Object = null;
         var _loc6_:GWizToolCribEntry = null;
         param2 = this.importTablePrefix(param1,param2);
         if(param2 == "")
         {
            return;
         }
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            if(!(_loc6_ = (_loc5_ = param1.removeItemAt(_loc4_)) as GWizToolCribEntry))
            {
               _loc5_.key = _loc3_++;
            }
            _loc5_.machname = GWizMachSettings.currMachine;
            _loc5_.tabname = param2;
            if(_loc5_.geometry == "")
            {
               _loc5_.geometry = "Normal";
            }
            if(GWizAbstractPrefs.isOEM && GWizAbstractPrefs.oemStr == GWizAbstractPrefs.GARR_OEM_STR)
            {
               _loc5_.description += " - " + _loc5_.comment;
            }
            param1.addItemAt(_loc5_,_loc4_);
            _loc4_++;
         }
         this.createNewToolTable(param2,param1);
         this.flushGetCribEntryCache();
      }
      
      private function convertInchesToMM(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         var _loc2_:int = 0;
         while(_loc2_ < GWizToolCribEntry.toolCribUnitFieldList.length)
         {
            _loc3_ = GWizToolCribEntry.toolCribUnitFieldList[_loc2_];
            if(param1.hasOwnProperty(_loc3_))
            {
               _loc4_ = (_loc4_ = param1[_loc3_]) * 25.4;
               param1[_loc3_] = _loc4_;
            }
            _loc2_++;
         }
      }
      
      private function convertMMToInches(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         var _loc2_:int = 0;
         while(_loc2_ < GWizToolCribEntry.toolCribUnitFieldList.length)
         {
            _loc3_ = GWizToolCribEntry.toolCribUnitFieldList[_loc2_];
            if(param1.hasOwnProperty(_loc3_))
            {
               _loc4_ = (_loc4_ = param1[_loc3_]) / 25.4;
               param1[_loc3_] = _loc4_;
            }
            _loc2_++;
         }
      }
      
      public function doExport() : void
      {
         GWizCribFormat.getCribFormat(false,GWizCribFormat.exportFormats,this.exportNext,null);
      }
      
      private function exportNext(param1:ArrayCollection, param2:int, param3:Boolean) : void
      {
         var _loc4_:GWizCribMach3 = null;
         var _loc5_:GWizCSVUtils = null;
         var _loc6_:GWizToolCribEntry = null;
         switch(param2)
         {
            case GWizCribFormat.MACH3_EXPORT:
               (_loc4_ = new GWizCribMach3()).toolsAC = ToolCrib;
               _loc4_.browseForExport();
               break;
            default:
               _loc5_ = new GWizCSVUtils();
               param2 = 0;
               while(param2 < ToolCrib.length)
               {
                  if(!(_loc6_ = ToolCrib.getCribEntryAt(param2)).hasOwnProperty("units"))
                  {
                     _loc6_.units = GWizToolCribEntry.INCHES_UNIT;
                  }
                  if(_loc6_.units == GWizToolCribEntry.MM_UNIT)
                  {
                     this.convertInchesToMM(_loc6_);
                  }
                  param2++;
               }
               _loc5_.exportCSVData(ToolCrib,GWizToolCribEntry.toolCribFieldList,this.cribFiles);
               param2 = 0;
               while(param2 < ToolCrib.length)
               {
                  if(!(_loc6_ = ToolCrib.getCribEntryAt(param2)).hasOwnProperty("units"))
                  {
                     _loc6_.units = GWizToolCribEntry.INCHES_UNIT;
                  }
                  if(_loc6_.units == GWizToolCribEntry.MM_UNIT)
                  {
                     this.convertMMToInches(_loc6_);
                  }
                  param2++;
               }
         }
      }
      
      public function createNewToolTable(param1:String, param2:ArrayCollection) : void
      {
         var _loc3_:int = 0;
         var _loc4_:GWizToolCribEntry = null;
         if(param2 == null)
         {
            param2 = defToolTable;
         }
         if(param1 == GWizCribList.NO_CRIB)
         {
            GWizPopUpManager.Show("Sorry, you can\'t name a table " + GWizCribList.NO_CRIB,"Error: Invalid Name",GWizPopUpManager.ERROR);
            return;
         }
         _loc3_ = GWizCribList.cribList.findTableListIndex(param1);
         if(_loc3_ >= 0)
         {
            if(GWizSettings.theCrib && GWizSettings.theCrib.tableChooser)
            {
               GWizSettings.theCrib.tableChooser.selectedIndex = _loc3_;
            }
            return;
         }
         ToolCrib.unFilterCrib();
         _loc3_ = 0;
         while(_loc3_ < param2.length)
         {
            _loc4_ = this.newToolTabObject(param2.getItemAt(_loc3_),param1);
            ToolCrib.addItemAt(_loc4_,_loc3_);
            _loc3_++;
         }
         if(GWizSettings.theCrib)
         {
            GWizSettings.theCrib.rebuildTableList(param1);
         }
         this.saveToolCrib();
         this.flushGetCribEntryCache();
      }
      
      public function addEndmill(param1:Number, param2:int, param3:String, param4:String, param5:String, param6:Boolean, param7:Boolean, param8:String, param9:String = "") : void
      {
         var _loc10_:GWizToolCribEntry;
         (_loc10_ = this.newToolTabObject(genericToolTable.getItemAt(this.GENERIC_ENDMILL),param8)).tool = param3 + " Endmill";
         if(param9 == "")
         {
            _loc10_.description = this.endmillDesc(param1,param2,param4,param3,param5,param6);
         }
         else
         {
            _loc10_.description = param9;
         }
         if(param7)
         {
            _loc10_.slot = this.maxSlot(param8) + 1;
         }
         _loc10_.geometry = "Normal";
         _loc10_.diameter = param1;
         _loc10_.flutes = param2;
         _loc10_.stickout = Math.max(1,6 * param1);
         _loc10_.cutLength = _loc10_.stickout;
         _loc10_.overallLength = _loc10_.stickout * 2;
         _loc10_.vendor = "";
         _loc10_.product = "";
         _loc10_.sfm = 1;
         _loc10_.ipt = 0;
         _loc10_.chipload = 1;
         _loc10_.useMfgSFM = false;
         _loc10_.mfgSFM = 0;
         _loc10_.useMfgIPT = false;
         _loc10_.mfgIPT = 0;
         GWizToolCribData.ToolCrib.addItem(_loc10_);
         GWizSettings.cribData.flushGetCribEntryCache();
      }
      
      private function endmillDesc(param1:Number, param2:int, param3:String, param4:String, param5:String, param6:Boolean) : String
      {
         var _loc7_:String = param3;
         if(param6)
         {
            param3 = param3 + "( " + GWizUtils.roundTenths(param1) + " in )";
         }
         else
         {
            param3 = param3;
         }
         return param3 + " " + param2 + " flute " + param4 + " Endmill " + param5;
      }
      
      public function maxSlot(param1:String) : int
      {
         var _loc2_:GWizToolCribEntry = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < ToolCrib.length)
         {
            _loc2_ = ToolCrib.getCribEntryAt(_loc4_);
            if(_loc2_.tabname == param1 && _loc2_.hasOwnProperty("slot"))
            {
               _loc3_ = Math.max(_loc3_,_loc2_.slot);
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function addDrill(param1:Number, param2:String, param3:String, param4:String, param5:Boolean, param6:String, param7:String = "") : void
      {
         var _loc8_:GWizToolCribEntry;
         (_loc8_ = this.newToolTabObject(genericToolTable.getItemAt(this.GENERIC_TWIST_DRILL),param6)).tool = param2 + " Twist Drill";
         if(param7 == "")
         {
            _loc8_.description = this.drillDesc(param1,param3,param2,param4);
         }
         else
         {
            _loc8_.description = param7;
         }
         if(param5)
         {
            _loc8_.slot = this.maxSlot(param6) + 1;
         }
         _loc8_.geometry = "Normal";
         _loc8_.diameter = param1;
         _loc8_.stickout = Math.max(1,6 * param1);
         _loc8_.cutLength = _loc8_.stickout;
         _loc8_.overallLength = _loc8_.stickout + 1;
         _loc8_.vendor = "";
         _loc8_.product = "";
         _loc8_.sfm = 1;
         _loc8_.ipt = 0;
         _loc8_.chipload = 1;
         _loc8_.useMfgSFM = false;
         _loc8_.mfgSFM = 0;
         _loc8_.useMfgIPT = false;
         _loc8_.mfgIPT = 0;
         _loc8_.shankSize = Math.min(param1,0.5);
         GWizToolCribData.ToolCrib.addCribEntry(_loc8_);
         GWizSettings.cribData.flushGetCribEntryCache();
      }
      
      private function drillDesc(param1:Number, param2:String, param3:String, param4:String) : String
      {
         var _loc5_:String = param2;
         return param2 + " " + param3 + " Twist Drill " + param4;
      }
      
      public function set fsCribList(param1:int) : void
      {
         var _loc3_:int = 0;
         GWizCribList.cribListPlus.removeAll();
         var _loc2_:Object = new Object();
         if(!GWizAbstractPrefs.isOEM)
         {
            _loc2_.tabname = GWizCribList.NO_CRIB;
            GWizCribList.cribListPlus.addItem(_loc2_);
         }
         if(GWizCribList.cribList)
         {
            _loc3_ = 0;
            while(_loc3_ < GWizCribList.cribList.length)
            {
               _loc2_ = GWizCribList.cribList.getItemAt(_loc3_);
               GWizCribList.cribListPlus.addItem(_loc2_);
               _loc3_++;
            }
         }
         GWizUtils.arrayCollectionSort(GWizCribList.cribListPlus,"tabname",false);
         this.flushGetCribEntryCache();
      }
      
      public function rebuildTableList() : void
      {
         var _loc2_:GWizToolCribEntry = null;
         var _loc3_:Object = null;
         if(!ToolCrib)
         {
            return;
         }
         this.dontFilter = true;
         ToolCrib.unFilterCrib();
         var _loc1_:int = 0;
         while(_loc1_ < ToolCrib.length)
         {
            _loc2_ = ToolCrib.getCribEntryAt(_loc1_);
            _loc3_ = new Object();
            if(_loc2_.tabname == "")
            {
               _loc2_.tabname = "orphan";
            }
            _loc3_.tabname = _loc2_.tabname;
            _loc3_.description = !!_loc2_.hasOwnProperty("tabledesc") ? _loc2_.tabledesc : "";
            _loc3_.tabtype = 0;
            _loc3_.maxslot = 0;
            GWizCribList.cribList.addItem(_loc3_);
            _loc1_++;
         }
         GWizSettings.cribData.dontFilter = false;
         this.onTableChooser();
         GWizSettings.cribData.fsCribList = GWizSettings.cribGeneration++;
         GWizSettings.cribData.flushGetCribEntryCache();
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._bindingEventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.willTrigger(param1);
      }
   }
}
