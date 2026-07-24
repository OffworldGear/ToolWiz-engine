package tools
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.utils.UIDUtil;
   import utils.GWizUtils;
   
   public class GWizToolCribEntry implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizToolCribEntry");
      
      public static const INCHES_UNIT:String = "inches";
      
      public static const MM_UNIT:String = "mm";
      
      public static var toolCribFieldList:Array = ["slot","description","serialno","tool","generic","geometry","flutes","leadang","diameter","stickout","cutLength","overallLength","shankSize","noseRad","helixAngle","coating","toolmaterial","toolFamily","vendor","product","idNo","insNo","sfm","ipt","chipload","useMfgSFM","mfgSFM","useMfgIPT","mfgIPT","xcomp","zcomp","xgeom","zgeom","status","quantity","field1","field2","field3","field4","units","holderType","holderDesc","holderDia","holderLen","comment","clockwise","coolantMode","coolantSupport","shoulderLength","taperAngle2","threadPitch","tipLength","tipDiameter","productLink","jobCode","pricePaid"];
      
      private static var _637093876toolCribUnitFieldList:Array = ["diameter","stickout","cutLength","overallLength","noseRad","sfm","ipt","chipload","mfgSFM","mfgIPT","xcomp","zcomp","xgeom","zgeom","shankSize","holderDia","holderLen","shoulderLength","threadPitch","tipLength","tipDiameter"];
      
      private static var _1163736428toolStatusValues:ArrayCollection = new ArrayCollection([{"name":"OK"},{"name":"No Consumable"},{"name":"Broken"},{"name":"Service"},{"name":"Other"},{"name":"Borrowed"}]);
      
      private static var maxKey:int = 1;
      
      public static const OTHER_TYPE:String = "Other";
      
      public static const COLLET_TYPE:String = "Collet";
      
      private static var _477293195toolHolderTypes:ArrayCollection = new ArrayCollection([{"name":"Other"},{"name":"Collet"},{"name":"Weldon / Side-Lock"},{"name":"Shell Mill / Arbor"},{"name":"Drill Chuck"},{"name":"Compression Tap"},{"name":"Morse Taper"},{"name":"Shrink Fit"},{"name":"Milling Chuck"},{"name":"Hydraulic Chuck"}]);
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      public var _slot:int = 0;
      
      public var description:String;
      
      private var _tool:String;
      
      public var coating:String = "Uncoated";
      
      public var toolmaterial:String;
      
      public var toolFamily:String;
      
      public var generic:Boolean = false;
      
      public var geometry:String = "Normal";
      
      public var flutes:int = 0;
      
      private var _leadang:Number = 90.0;
      
      private var _helixAngle:Number = 40.0;
      
      private var _diameter:Number = 0.5;
      
      private var _stickout:Number = 0.0;
      
      private var _cutLength:Number = 0.0;
      
      private var _overallLength:Number = 0.0;
      
      private var _noseRad:Number = 0.0;
      
      private var _sfm:Number = 0.0;
      
      private var _ipt:Number = 0.0;
      
      private var _chipload:Number = 0.0;
      
      private var _mfgSFM:Number = 0.0;
      
      public var useMfgSFM:Boolean = false;
      
      private var _mfgIPT:Number = 0.0;
      
      public var useMfgIPT:Boolean = false;
      
      private var _xcomp:Number = 0.0;
      
      private var _zcomp:Number = 0.0;
      
      private var _xgeom:Number = 0.0;
      
      private var _zgeom:Number = 0.0;
      
      private var _shankSize:Number = 0.0;
      
      private var _units:String = "inches";
      
      public var comment:String;
      
      public var clockwise:Boolean = true;
      
      public var coolantMode:String;
      
      public var coolantSupport:String;
      
      public var shoulderLength:Number;
      
      public var taperAngle2:Number;
      
      public var threadPitch:Number;
      
      public var tipLength:Number;
      
      public var tipDiameter:Number;
      
      public var productLink:String;
      
      public var jobCode:String;
      
      public var pricePaid:Number;
      
      private var _status:String = "OK";
      
      public var serialno:String;
      
      public var vendor:String;
      
      public var product:String;
      
      public var idNo:String;
      
      public var insNo:String;
      
      public var field1:String;
      
      public var field2:String;
      
      public var field3:String;
      
      public var field4:String;
      
      private var _key:int;
      
      public var tabname:String;
      
      private var _guid:String;
      
      public var machname:String;
      
      public var tabledesc:String;
      
      private var _holderType:String = "Collet";
      
      public var holderDesc:String = "";
      
      private var _holderDia:Number = 0.0;
      
      private var _holderLen:Number = 0.0;
      
      private var _quantity:int = 0;
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizToolCribEntry(param1:Object = null)
      {
         this._tool = GWizToolData.EMPTY_SLOT;
         this._key = maxKey++;
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         if(param1)
         {
            if(param1.hasOwnProperty("ballnose"))
            {
               param1.geometry = "Normal";
               if(param1.hasOwnProperty("tool"))
               {
                  if(String(param1.tool).indexOf("Twist Drill") != -1)
                  {
                     if(param1.ballnose == "true")
                     {
                        param1.geometry = "Parabolic";
                     }
                  }
                  else if(String(param1.tool).indexOf("Endmill") != -1)
                  {
                     if(param1.ballnose == "true")
                     {
                        param1.geometry = "Ballnose";
                     }
                  }
               }
            }
            if(GWizUtils.checkProp(param1,"rougher","Boolean") && String(param1.rougher) == "true")
            {
               param1.geometry = GWizToolData.ROUGHER_GEO_NAME;
            }
            if(!GWizUtils.checkProp(param1,"generic","Boolean"))
            {
               param1.generic = "false";
            }
            this.tabname = param1.tabname;
            this.guid = param1.guid;
            this.machname = param1.machname;
            this.tabledesc = param1.tabledesc;
            this.slot = param1.slot;
            this.description = param1.description;
            this.serialno = param1.serialno;
            this.tool = param1.tool;
            this.generic = String(param1.generic).toUpperCase() == "TRUE";
            this.geometry = param1.geometry;
            this.flutes = param1.flutes;
            this.leadang = param1.leadang;
            this.helixAngle = param1.helixAngle;
            this.diameter = param1.diameter;
            this.stickout = param1.stickout;
            this.cutLength = param1.cutLength;
            this.overallLength = param1.overallLength;
            this.noseRad = param1.noseRad;
            this.vendor = param1.vendor;
            this.product = param1.product;
            this.idNo = param1.idNo;
            this.insNo = param1.insNo;
            this.sfm = param1.sfm;
            this.ipt = param1.ipt;
            this.chipload = param1.chipload;
            this.mfgSFM = param1.mfgSFM;
            this.useMfgSFM = String(param1.useMfgSFM).toUpperCase() == "TRUE";
            this.mfgIPT = param1.mfgIPT;
            this.useMfgIPT = String(param1.useMfgIPT).toUpperCase() == "TRUE";
            this.xcomp = param1.xcomp;
            this.zcomp = param1.zcomp;
            this.xgeom = param1.xgeom;
            this.zgeom = param1.zgeom;
            this.shankSize = param1.shankSize;
            this.status = param1.status;
            this.quantity = param1.quantity;
            this.field1 = param1.field1;
            this.field2 = param1.field2;
            this.field3 = param1.field3;
            this.field4 = param1.field4;
            this.coating = param1.coating;
            this.toolmaterial = param1.toolmaterial;
            this.toolFamily = param1.toolFamily;
            this.holderType = param1.holderType;
            this.holderDia = param1.holderDia;
            this.holderLen = param1.holderLen;
            this.comment = param1.comment;
            if(!param1.hasOwnProperty("clockwise"))
            {
               this.clockwise = true;
            }
            else
            {
               this.clockwise = String(param1.clockwise).toLowerCase() == "true";
            }
            this.shoulderLength = param1.shoulderLength;
            this.taperAngle2 = param1.taperAngle2;
            this.tipLength = param1.tipLength;
            this.tipDiameter = param1.tipDiameter;
            this.threadPitch = param1.threadPitch;
            this.productLink = param1.productLink;
            this.jobCode = param1.jobCode;
            this.pricePaid = param1.pricePaid;
            this.units = param1.units;
            this.convertMMToInches();
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get toolCribUnitFieldList() : Array
      {
         return GWizToolCribEntry._637093876toolCribUnitFieldList;
      }
      
      public static function set toolCribUnitFieldList(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCribEntry._637093876toolCribUnitFieldList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCribEntry,"toolCribUnitFieldList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get toolStatusValues() : ArrayCollection
      {
         return GWizToolCribEntry._1163736428toolStatusValues;
      }
      
      public static function set toolStatusValues(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCribEntry._1163736428toolStatusValues;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCribEntry,"toolStatusValues",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get toolHolderTypes() : ArrayCollection
      {
         return GWizToolCribEntry._477293195toolHolderTypes;
      }
      
      public static function set toolHolderTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCribEntry._477293195toolHolderTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCribEntry,"toolHolderTypes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function get slot() : int
      {
         return this._slot;
      }
      
      public function set slot(param1:int) : void
      {
         this._slot = param1;
      }
      
      public function set tool(param1:String) : void
      {
         if(!GWizToolMenu.validToolName(param1))
         {
            param1 = GWizToolMenu.toPrimitiveLabel(param1);
         }
         if(param1 == "Indexable End / Facemill")
         {
            param1 = "Indexable End Or Face Mill";
         }
         this._tool = param1;
      }
      
      public function get tool() : String
      {
         return this._tool;
      }
      
      public function set leadang(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 90;
         }
         this._leadang = param1;
      }
      
      public function get leadang() : Number
      {
         return this._leadang;
      }
      
      public function set helixAngle(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 40;
         }
         this._helixAngle = param1;
      }
      
      public function get helixAngle() : Number
      {
         return this._helixAngle;
      }
      
      public function set diameter(param1:Number) : void
      {
         if(false && GWizUtils.debug && param1 >= 1)
         {
            log.debug("Big diameter.  tool = " + this.tool);
         }
         if(isNaN(param1) || param1 < 0)
         {
            param1 = 0.5;
         }
         this._diameter = param1;
      }
      
      public function get diameter() : Number
      {
         return this._diameter;
      }
      
      public function set stickout(param1:Number) : void
      {
         if(isNaN(param1) || param1 < 0)
         {
            param1 = 0;
         }
         this._stickout = param1;
      }
      
      public function get stickout() : Number
      {
         return this._stickout;
      }
      
      public function set cutLength(param1:Number) : void
      {
         if(isNaN(param1) || param1 < 0)
         {
            param1 = 0;
         }
         this._cutLength = param1;
         if(this.overallLength < this.cutLength)
         {
            this.overallLength = this.cutLength * 2;
         }
      }
      
      public function get cutLength() : Number
      {
         return this._cutLength;
      }
      
      public function set overallLength(param1:Number) : void
      {
         if(isNaN(param1) || param1 < 0)
         {
            param1 = 0;
         }
         this._overallLength = param1;
      }
      
      public function get overallLength() : Number
      {
         return this._overallLength;
      }
      
      public function set noseRad(param1:Number) : void
      {
         if(isNaN(param1) || param1 < 0)
         {
            param1 = 0;
         }
         this._noseRad = param1;
      }
      
      public function get noseRad() : Number
      {
         return this._noseRad;
      }
      
      public function set sfm(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         this._sfm = param1;
      }
      
      public function get sfm() : Number
      {
         return this._sfm;
      }
      
      public function set ipt(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         this._ipt = param1;
      }
      
      public function get ipt() : Number
      {
         return this._ipt;
      }
      
      public function set chipload(param1:Number) : void
      {
         if(isNaN(param1) || param1 < 0)
         {
            param1 = 0;
         }
         this._chipload = param1;
      }
      
      public function get chipload() : Number
      {
         return this._chipload;
      }
      
      public function set mfgSFM(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         this._mfgSFM = param1;
      }
      
      public function get mfgSFM() : Number
      {
         return this._mfgSFM;
      }
      
      public function set mfgIPT(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         this._mfgIPT = param1;
      }
      
      public function get mfgIPT() : Number
      {
         return this._mfgIPT;
      }
      
      public function set xcomp(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         this._xcomp = param1;
      }
      
      public function get xcomp() : Number
      {
         return this._xcomp;
      }
      
      public function set zcomp(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         this._zcomp = param1;
      }
      
      public function get zcomp() : Number
      {
         return this._zcomp;
      }
      
      public function set xgeom(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         this._xgeom = param1;
      }
      
      public function get xgeom() : Number
      {
         return this._xgeom;
      }
      
      public function set zgeom(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         this._zgeom = param1;
      }
      
      public function get zgeom() : Number
      {
         return this._zgeom;
      }
      
      public function set shankSize(param1:Number) : void
      {
         if(isNaN(param1) || param1 < 0)
         {
            param1 = 0;
         }
         this._shankSize = param1;
      }
      
      public function get shankSize() : Number
      {
         return this._shankSize;
      }
      
      public function get units() : String
      {
         if(this._units != MM_UNIT)
         {
            return INCHES_UNIT;
         }
         return MM_UNIT;
      }
      
      public function set units(param1:String) : void
      {
         if(param1 && param1.toLowerCase() == "millimeters")
         {
            param1 = MM_UNIT;
         }
         this._units = param1;
      }
      
      public function isSolidEndmill() : Boolean
      {
         return this.tool.indexOf("Endmill") >= 0 && !this.isIndexable();
      }
      
      public function isIndexable() : Boolean
      {
         return this.tool.indexOf("Indexable") >= 0;
      }
      
      public function isBallnose() : Boolean
      {
         return this.tool.indexOf("Ballnose") >= 0 || this.geometry.indexOf("Ballnose") >= 0;
      }
      
      public function isCorncob() : Boolean
      {
         return this.geometry.indexOf("Serrated") >= 0;
      }
      
      public function isCompatibleType(param1:Boolean, param2:Boolean, param3:Boolean) : Boolean
      {
         var _loc4_:Boolean = true;
         if(param1)
         {
            _loc4_ = _loc4_ && this.isSolidEndmill();
         }
         if(param3)
         {
            _loc4_ = _loc4_ && this.isBallnose();
         }
         else
         {
            _loc4_ = _loc4_ && this.geometry == "Normal";
         }
         if(!param2)
         {
            _loc4_ = _loc4_ && !this.isCorncob();
         }
         return _loc4_;
      }
      
      public function set status(param1:String) : void
      {
         var _loc4_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < toolStatusValues.length)
         {
            _loc4_ = toolStatusValues.getItemAt(_loc3_).name;
            if(param1 == _loc4_)
            {
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         if(!_loc2_)
         {
            param1 = "OK";
         }
         this._status = param1;
      }
      
      public function get status() : String
      {
         return this._status;
      }
      
      public function get key() : int
      {
         return this._key;
      }
      
      public function set guid(param1:String) : void
      {
         if(!param1 || param1 == "")
         {
            param1 = UIDUtil.createUID();
         }
         this._guid = param1;
      }
      
      public function get guid() : String
      {
         if(!this._guid || this._guid == "")
         {
            this._guid = UIDUtil.createUID();
         }
         return this._guid;
      }
      
      public function set holderType(param1:String) : void
      {
         var _loc4_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < toolHolderTypes.length)
         {
            _loc4_ = toolHolderTypes.getItemAt(_loc3_).name;
            if(param1 == _loc4_)
            {
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         if(!_loc2_)
         {
            param1 = OTHER_TYPE;
         }
         this._holderType = param1;
      }
      
      public function get holderType() : String
      {
         return this._holderType;
      }
      
      public function set holderDia(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         param1 = Math.max(0,param1);
         this._holderDia = param1;
      }
      
      public function get holderDia() : Number
      {
         return this._holderDia;
      }
      
      public function set holderLen(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         param1 = Math.max(0,param1);
         this._holderLen = param1;
      }
      
      public function get holderLen() : Number
      {
         return this._holderLen;
      }
      
      public function set quantity(param1:int) : void
      {
         param1 = Math.max(0,param1);
         if(this._quantity > 0 && param1 == 0)
         {
            log.debug("gotcha");
         }
         this._quantity = param1;
      }
      
      public function get quantity() : int
      {
         return this._quantity;
      }
      
      private function convertMMToInches() : void
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         if(this.units != MM_UNIT)
         {
            return;
         }
         if(GWizUtils.debug && this.description == "4x50mm .2mm 3FL 12mm F/L 14mm R/L 6mm SH.")
         {
            log.debug("gotcha");
         }
         var _loc1_:int = 0;
         while(_loc1_ < GWizToolCribEntry.toolCribUnitFieldList.length)
         {
            _loc2_ = GWizToolCribEntry.toolCribUnitFieldList[_loc1_];
            if(hasOwnProperty(_loc2_))
            {
               _loc3_ = this[_loc2_];
               _loc3_ /= 25.4;
               this[_loc2_] = _loc3_;
            }
            _loc1_++;
         }
         this.units = INCHES_UNIT;
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
