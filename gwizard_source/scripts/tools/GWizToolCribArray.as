package tools
{
   import configinfo.GWizSettings;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizToolCribArray extends ArrayCollection
   {
      
      private static const log:ILogger = Log.getLogger("GWizToolCribArray");
      
      public static var cribTool:int = -1;
      
      public static var cribToolGUID:String = "";
       
      
      private var guidCache:Object;
      
      public var lastGUIDIdx:int = -1;
      
      private var lastShowGenTT:int = -1;
      
      private var lastToolTypeGUID:String = "";
      
      private var lastToolType:String = "HSS Endmill";
      
      public var showAllTables:Boolean = false;
      
      public var tcFilter:String = "Default";
      
      public var opFilter:String = "All";
      
      public var materialFilter:String = "";
      
      public var diameterFilter:Number;
      
      public var cutLengthFilter:Number;
      
      public var stickoutFilter:Number;
      
      public var flutesFilter:Number;
      
      public var tipTypeFilter:String;
      
      public var filter:Function;
      
      public function GWizToolCribArray()
      {
         this.guidCache = new Object();
         this.filter = this.filterTC;
         super();
      }
      
      public static function ACToToolCrib(param1:ArrayCollection) : GWizToolCribArray
      {
         var _loc4_:GWizToolCribEntry = null;
         var _loc2_:GWizToolCribArray = new GWizToolCribArray();
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = new GWizToolCribEntry(param1.getItemAt(_loc3_));
            _loc2_.addCribEntry(_loc4_);
            _loc3_++;
         }
         return _loc2_;
      }
      
      override public function addItem(param1:Object) : void
      {
         var _loc2_:GWizToolCribEntry = new GWizToolCribEntry(param1);
         GWizUtils.assert(param1 && _loc2_ && !GWizUtils.debug);
         this.flushCache();
         super.addItem(_loc2_);
      }
      
      override public function addItemAt(param1:Object, param2:int) : void
      {
         var _loc3_:GWizToolCribEntry = new GWizToolCribEntry(param1);
         GWizUtils.assert(param1 && _loc3_);
         this.flushCache();
         super.addItemAt(_loc3_,param2);
      }
      
      override public function getItemAt(param1:int, param2:int = 0) : Object
      {
         return super.getItemAt(param1);
      }
      
      public function addCribEntry(param1:GWizToolCribEntry) : void
      {
         this.flushCache();
         super.addItem(param1);
      }
      
      public function addCribEntryAt(param1:GWizToolCribEntry, param2:int) : void
      {
         this.flushCache();
         super.addItemAt(param1,param2);
      }
      
      public function getCribEntryAt(param1:int) : GWizToolCribEntry
      {
         param1 = Math.min(param1,super.length - 1);
         var _loc2_:GWizToolCribEntry = null;
         if(super.length > 0)
         {
            _loc2_ = GWizToolCribEntry(super.getItemAt(param1));
            GWizUtils.assert(GWizUtils.debug && _loc2_);
         }
         return _loc2_;
      }
      
      private function flushCache() : void
      {
         this.guidCache = new Object();
      }
      
      public function getCribEntryByGUID(param1:String) : GWizToolCribEntry
      {
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         this.unFilterCrib();
         if(false && GWizUtils.debug)
         {
            log.debug(this.length + " entries in ToolCrib.");
         }
         var _loc2_:GWizToolCribEntry = null;
         this.lastGUIDIdx = -1;
         if(GWizSettings.cacheToolGUIDS && this.guidCache.hasOwnProperty(param1))
         {
            _loc2_ = this.getCribEntryAt(this.guidCache[param1]);
         }
         else
         {
            _loc3_ = false;
            _loc4_ = 0;
            while(_loc4_ < this.length)
            {
               _loc2_ = this.getCribEntryAt(_loc4_);
               if(_loc2_.guid == param1)
               {
                  this.lastGUIDIdx = _loc4_;
                  this.guidCache[param1] = _loc4_;
                  _loc3_ = true;
                  break;
               }
               if(param1 == "")
               {
                  break;
               }
               _loc4_++;
            }
            if(!_loc3_)
            {
               if(GWizUtils.debug && false)
               {
                  GWizUtils.assert(_loc3_);
               }
            }
         }
         this.filterCrib();
         return _loc2_;
      }
      
      public function getCribGenericGUID(param1:String) : Boolean
      {
         var _loc2_:GWizToolCribEntry = this.getCribEntryByGUID(param1);
         var _loc3_:Boolean = false;
         if(_loc2_)
         {
            _loc3_ = _loc2_.generic;
         }
         return _loc3_;
      }
      
      public function getCribToolTypeGUID(param1:String, param2:String) : String
      {
         var _loc3_:GWizToolCribEntry = null;
         if(this.lastShowGenTT != GWizToolCrib.showGeneration || this.lastToolTypeGUID != param1)
         {
            _loc3_ = this.getCribEntryByGUID(param1);
            if(_loc3_ != null)
            {
               param2 = _loc3_.tool;
            }
            this.lastToolType = param2;
            this.lastShowGenTT = GWizToolCrib.showGeneration;
            this.lastToolTypeGUID = param1;
         }
         else
         {
            param2 = this.lastToolType;
         }
         return param2;
      }
      
      public function getCribToolDefGUID(param1:String, param2:GWizToolDef) : GWizToolDef
      {
         var _loc4_:Number = NaN;
         var _loc3_:GWizToolCribEntry = this.getCribEntryByGUID(param1);
         if(_loc3_ != null)
         {
            param2.toolParms.toolType = _loc3_.tool;
            GWizToolData.refreshGeometry();
            param2._toolDiameter.setVal(_loc3_.diameter);
            param2._flutes.value = _loc3_.flutes;
            if(_loc3_.hasOwnProperty("shankSize"))
            {
               if((_loc4_ = _loc3_.shankSize) < 0.005)
               {
                  _loc4_ = _loc3_.diameter;
               }
               param2.setGeometryParms(_loc3_.geometry,_loc4_ != _loc3_.diameter,_loc4_);
            }
            else
            {
               param2.setGeometry(_loc3_.geometry);
            }
            param2._LeadAngle.value = _loc3_.leadang;
            param2.toolParms.leadAngle = _loc3_.leadang;
            param2._stickout.setVal(_loc3_.stickout);
            param2.toolParms.cutLength = _loc3_.cutLength;
            param2.toolParms.overallLength = _loc3_.overallLength;
            param2.toolParms.noseRad = _loc3_.noseRad;
            param2.toolParms.coating = _loc3_.coating;
            param2.toolParms.cribProduct = _loc3_.product;
         }
         return param2;
      }
      
      public function findEmptySlot(param1:String) : GWizToolCribEntry
      {
         var _loc2_:GWizToolCribEntry = null;
         var _loc3_:Function = this.filterFunction;
         this.filterFunction = null;
         this.refresh();
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         while(_loc5_ < this.length)
         {
            _loc2_ = this.getCribEntryAt(_loc5_);
            if(_loc2_.tabname == param1 && _loc2_.tool == GWizToolData.EMPTY_SLOT)
            {
               _loc4_ = true;
               break;
            }
            _loc5_++;
         }
         if(!_loc4_)
         {
            _loc2_ = null;
         }
         this.filterFunction = _loc3_;
         this.refresh();
         return _loc2_;
      }
      
      private function unCoated(param1:String) : Boolean
      {
         return param1 == "" || param1 == "Uncoated";
      }
      
      private function isBetterMaterialCoating(param1:String, param2:String, param3:GWizToolCribEntry) : Boolean
      {
         var _loc4_:Boolean = false;
         var _loc5_:String = param3.toolmaterial;
         var _loc6_:String = param3.coating;
         if(param1 == "HSS" || param1 == "")
         {
            if(_loc5_ != "HSS")
            {
               _loc4_ = true;
            }
         }
         if(!_loc4_ && this.unCoated(param2) && !this.unCoated(_loc6_))
         {
            _loc4_ = true;
         }
         return _loc4_;
      }
      
      public function maxEndmillDiaInCrib(param1:Number, param2:int, param3:Boolean, param4:Boolean) : Number
      {
         var _loc10_:GWizToolCribEntry = null;
         var _loc5_:Number = 0;
         var _loc6_:int = 0;
         var _loc7_:String = "";
         var _loc8_:String = "";
         cribTool = -1;
         cribToolGUID = "";
         var _loc9_:int = 0;
         while(_loc9_ < this.length)
         {
            if((_loc10_ = this.getCribEntryAt(_loc9_)).flutes <= param2 && _loc10_.isCompatibleType(true,param3,param4))
            {
               if(this.isBetterMaterialCoating(_loc7_,_loc8_,_loc10_))
               {
                  _loc5_ = _loc10_.diameter;
                  _loc6_ = _loc10_.flutes;
                  cribTool = _loc9_;
                  cribToolGUID = _loc10_.guid;
                  _loc7_ = _loc10_.toolmaterial;
                  _loc8_ = _loc10_.coating;
               }
               if(_loc10_.diameter >= _loc5_)
               {
                  if(_loc10_.flutes >= _loc6_)
                  {
                     if(isNaN(param1) || _loc10_.diameter <= param1)
                     {
                        _loc5_ = _loc10_.diameter;
                        _loc6_ = _loc10_.flutes;
                        cribTool = _loc9_;
                        cribToolGUID = _loc10_.guid;
                     }
                  }
               }
            }
            _loc9_++;
         }
         if(cribToolGUID == "" && !isNaN(param1))
         {
            _loc5_ = param1;
         }
         return _loc5_;
      }
      
      public function filterTC(param1:Object) : Boolean
      {
         var _loc3_:GWizToolCribEntry = null;
         var _loc2_:Boolean = this.showAllTables || param1.tabname == this.tcFilter;
         if(_loc2_)
         {
            _loc3_ = GWizToolCribEntry(param1);
            if(this.opFilter != "" && this.opFilter != "All")
            {
               _loc2_ = _loc2_ && this.toolOpFilter(_loc3_);
            }
            if(this.diameterFilter > 0)
            {
               _loc2_ = _loc2_ && this.plusOrMinus(_loc3_.diameter,this.diameterFilter,0.2);
            }
            if(this.cutLengthFilter > 0)
            {
               _loc2_ = _loc2_ && this.plusOrMinus(_loc3_.cutLength,this.cutLengthFilter,0.2);
            }
            if(this.stickoutFilter > 0)
            {
               _loc2_ = _loc2_ && this.plusOrMinus(_loc3_.stickout,this.stickoutFilter,0.2);
            }
            if(this.flutesFilter > 0)
            {
               _loc2_ = _loc2_ && _loc3_.flutes == int(this.flutesFilter);
            }
            if(this.tipTypeFilter && this.tipTypeFilter != "")
            {
               _loc2_ = _loc2_ && _loc3_.geometry == this.tipTypeFilter;
            }
            if(this.materialFilter != "")
            {
            }
         }
         return _loc2_;
      }
      
      private function plusOrMinus(param1:Number, param2:Number, param3:Number) : Boolean
      {
         var _loc4_:Boolean = false;
         if(param2 * (1 - param3) <= param1 && param1 <= param2 * (1 + param3))
         {
            _loc4_ = true;
         }
         return _loc4_;
      }
      
      private function toolOpFilter(param1:GWizToolCribEntry) : Boolean
      {
         var _loc2_:* = true;
         switch(this.opFilter)
         {
            case "Hole":
               _loc2_ = Boolean(param1.tool.indexOf("Drill") >= 0 || param1.tool.indexOf("Reamer") >= 0 || param1.tool.indexOf("Boring") >= 0);
               break;
            case "Pocket":
            case "2D Profiling":
               _loc2_ = Boolean(param1.tool.indexOf("Endmill") >= 0 || param1.tool.indexOf("Indexable") >= 0);
               break;
            case "Surfacing":
               _loc2_ = param1.tool.indexOf("Indexable") >= 0;
               break;
            case "Chamfer":
               _loc2_ = Boolean(param1.geometry.indexOf("Chamfer") >= 0 || param1.geometry.indexOf("Chamfer") >= 0 || param1.geometry.indexOf("Round") >= 0 || param1.geometry.indexOf("V-Bit") >= 0);
               break;
            case "3D Profiling":
               _loc2_ = param1.geometry.indexOf("Ballnose") >= 0;
               break;
            case "Threading":
               _loc2_ = Boolean(param1.geometry.indexOf("Tapping") >= 0 || param1.tool.indexOf("Thread") >= 0);
               break;
            case "Engrave/Carve":
               _loc2_ = Boolean(param1.geometry.indexOf("Ballnose") >= 0 || param1.geometry.indexOf("V-Bit") >= 0);
               break;
            case "Probe":
               _loc2_ = param1.tool.indexOf("Probe") >= 0;
               break;
            case "Turning":
               _loc2_ = param1.geometry.indexOf("Turning") >= 0;
               break;
            case "Boring":
               _loc2_ = param1.geometry.indexOf("Boring") >= 0;
               break;
            case "Part/Groove":
               _loc2_ = param1.geometry.indexOf("Groov") >= 0;
         }
         return _loc2_;
      }
      
      public function filterCrib() : void
      {
         this.filterFunction = this.filter;
         this.refresh();
      }
      
      public function unFilterCrib() : void
      {
         this.filterFunction = null;
         var _loc1_:Boolean = this.refresh();
         if(GWizUtils.debug)
         {
            GWizUtils.assert(_loc1_);
         }
      }
      
      public function filterCribByTabname(param1:String) : void
      {
         GWizToolCribData.ToolCrib.tcFilter = param1;
         GWizToolCribData.ToolCrib.filterCrib();
         GWizSettings.cribData.sortToolCrib(GWizToolCribData.ToolCrib);
      }
   }
}
