package tools
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizGeomUtils;
   import utils.GWizUtils;
   
   public class GWizToolData implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizToolData");
      
      public static var _663562685LatheToolsList:Array = ["Turning: HSS","Turning: Carbide","HSS Twist Drill","Carbide Twist Drill","Cobalt Twist Drill","HP HSS Twist Drill","HP Carbide Twist Drill","Indexable Drill","HSS Spot Drill","Carbide Spot Drill","HSS Center Drill","Carbide Center Drill","HSS Reamer","Carbide Reamer","HSS Spade Drill","Gun Drill","Parting/Grooving","Threading","Tapping"];
      
      public static const EMPTY_SLOT:String = "Empty Slot";
      
      public static var _611030077MillToolsList:Array = ["HSS Endmill","HP HSS Endmill","Carbide Endmill","HP Carbide Endmill","TiAlN Carbide Endmill","PCD Endmill","Indexable End Or Face Mill","HSS Twist Drill","HP HSS Twist Drill","Cobalt Twist Drill","Carbide Twist Drill","HP Carbide Twist Drill","PCD Twist Drill","Indexable Drill","HSS Spot Drill","Carbide Spot Drill","HSS Center Drill","Carbide Center Drill","HSS Spade Drill","Carbide Spade Drill","Gun Drill","HSS Reamer","Carbide Reamer","Tapping","Carbide Thread Mill","HSS Boring","Carbide Boring","Saws & Woodruff Cutters","Annular Cutter (Rotabroach®)","HSS Turning","Carbide Turning","HSS Parting","Carbide Parting","HSS Grooving","Carbide Grooving","HSS Threading","Carbide Threading","Probe","Other","Empty Toolholder",EMPTY_SLOT];
      
      public static const CHAMFER_GEO_NAME:String = "Chamfer / Countersink";
      
      public static const CORNER_ROUND_GEO_NAME:String = "Corner Round";
      
      public static const FORM_TAP_GEO_NAME:String = "Form Tap";
      
      public static const ROUGHER_GEO_NAME:String = "Serrated Rougher";
      
      private static var _2061641945geometryTypes:ArrayCollection = new ArrayCollection([{
         "label":"Normal",
         "td":1,
         "em":1,
         "tap":1,
         "turning":0,
         "family":"Endmill",
         "chipThin":true
      },{
         "label":ROUGHER_GEO_NAME,
         "td":0,
         "em":1,
         "tap":0,
         "turning":0,
         "family":"Endmill",
         "chipThin":true
      },{
         "label":"Ballnose",
         "td":0,
         "em":1,
         "tap":0,
         "turning":0,
         "family":"Endmill",
         "chipThin":true
      },{
         "label":"Lollipop",
         "td":0,
         "em":1,
         "tap":0,
         "turning":0,
         "family":"Endmill",
         "chipThin":true
      },{
         "label":CHAMFER_GEO_NAME,
         "td":0,
         "em":1,
         "tap":0,
         "turning":0,
         "family":"Endmill",
         "chipThin":false
      },{
         "label":CORNER_ROUND_GEO_NAME,
         "td":0,
         "em":1,
         "tap":0,
         "turning":0,
         "family":"Endmill",
         "chipThin":false
      },{
         "label":"V-Bit",
         "td":0,
         "em":1,
         "tap":0,
         "turning":0,
         "family":"Endmill",
         "chipThin":false
      },{
         "label":"Dovetail",
         "td":0,
         "em":1,
         "tap":0,
         "turning":0,
         "family":"Endmill",
         "chipThin":false
      },{
         "label":"Router: Downcut",
         "td":0,
         "em":1,
         "tap":0,
         "turning":0,
         "family":"Endmill",
         "chipThin":true
      },{
         "label":"Router: Compression",
         "td":0,
         "em":1,
         "tap":0,
         "turning":0,
         "family":"Endmill",
         "chipThin":true
      },{
         "label":"Router: Straight Flute",
         "td":0,
         "em":1,
         "tap":0,
         "turning":0,
         "family":"Endmill",
         "chipThin":false
      },{
         "label":"Parabolic",
         "td":1,
         "em":0,
         "tap":0,
         "turning":0,
         "family":"Endmill"
      },{
         "label":FORM_TAP_GEO_NAME,
         "td":0,
         "em":0,
         "tap":1,
         "turning":0,
         "family":"Endmill"
      },{
         "label":"Turning",
         "td":0,
         "em":0,
         "tap":0,
         "turning":1,
         "family":"Turning"
      },{
         "label":"Boring Bar",
         "td":0,
         "em":0,
         "tap":0,
         "turning":1,
         "family":"Turning"
      },{
         "label":"Parting",
         "td":0,
         "em":0,
         "tap":0,
         "turning":1,
         "family":"Turning"
      },{
         "label":"Threading",
         "td":0,
         "em":0,
         "tap":0,
         "turning":1,
         "family":"Turning"
      },{
         "label":"Grooving",
         "td":0,
         "em":0,
         "tap":0,
         "turning":1,
         "family":"Turning"
      }]);
      
      public static const UNCOATED:int = 0;
      
      public static const HP_COATING:int = 1;
      
      public static const TIALN_COATING:int = 3;
      
      private static var _403661963toolCoatingData:ArrayCollection = new ArrayCollection([{"label":"Uncoated"},{"label":"Hardlube"},{"label":"TiN"},{"label":"TiCN"},{"label":"ZrN"},{"label":"TiB2 (Alumastar)"},{"label":"TiAlN (incl. Spektra, nACo)"},{"label":"AlTiN"},{"label":"AlCrN"},{"label":"PCD/CVD (Diamond)"}]);
      
      public static const HSS_MATERIAL:int = 0;
      
      public static const COBALT_MATERIAL:int = 1;
      
      public static const CARBIDE_MATERIAL:int = 2;
      
      private static var _1180104489toolMaterialData:ArrayCollection = new ArrayCollection([{
         "label":"HSS",
         "visible":true
      },{
         "label":"Cobalt",
         "visible":false
      },{
         "label":"Carbide",
         "visible":true
      }]);
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _toolType:String = "HSS Endmill";
      
      public var cribName:String = "";
      
      private var _cribProduct:String = "";
      
      private var _geometry:String = "Normal";
      
      public var toolDiam:Number = 0.5;
      
      public var flutes:int = 2;
      
      public var _leadAngle:Number = 90;
      
      public var _helixAngle:Number = 40.0;
      
      private var _stickout:Number;
      
      public var cornerRadius:Number;
      
      private var _shankSize:Number = 0.0;
      
      private var _customShank:Boolean = false;
      
      private var _cutLength:Number;
      
      private var _overallLength:Number;
      
      public var noCutDia:Number;
      
      public var threadPitch:Number;
      
      private var _coating:String = "";
      
      private var _toolMaterial:String = "";
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizToolData()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         toolMaterialData.filterFunction = filterMaterial;
         toolMaterialData.refresh();
      }
      
      public static function validToolTypeStr(param1:String) : Boolean
      {
         var _loc3_:String = null;
         var _loc5_:int = 0;
         if(false && GWizUtils.debug && param1.toLowerCase().indexOf("annular") >= 0)
         {
            log.debug("validToolTypeStr(\'" + param1 + "\'");
         }
         var _loc2_:Boolean = false;
         param1 = param1.toLowerCase();
         var _loc4_:int = 0;
         while(_loc4_ < MillToolsList.length)
         {
            _loc3_ = String(MillToolsList[_loc4_]).toLowerCase();
            if(param1.indexOf(_loc3_) >= 0)
            {
               _loc2_ = true;
               break;
            }
            _loc4_++;
         }
         if(!_loc2_)
         {
            _loc5_ = 0;
            while(_loc5_ < LatheToolsList.length)
            {
               _loc3_ = String(LatheToolsList[_loc5_]).toLowerCase();
               if(param1.indexOf(_loc3_) >= 0)
               {
                  _loc2_ = true;
                  break;
               }
               _loc5_++;
            }
         }
         return _loc2_;
      }
      
      public static function filterGeometry(param1:Object) : Boolean
      {
         var _loc2_:Boolean = isNormalGeoName(param1.label) && param1.turning != 0;
         if(GWizGraphicToolMenu.twistDrillGeometry)
         {
            _loc2_ = _loc2_ || param1.td != 0;
         }
         else if(GWizGraphicToolMenu.emGeometry)
         {
            _loc2_ = _loc2_ || param1.em != 0;
         }
         else if(GWizGraphicToolMenu.tapGeometry)
         {
            _loc2_ = _loc2_ || param1.tap != 0;
         }
         else if(GWizGraphicToolMenu.turningGeometry)
         {
            _loc2_ = _loc2_ || param1.turning != 0;
         }
         return _loc2_;
      }
      
      public static function refreshGeometry() : void
      {
         geometryTypes.filterFunction = filterGeometry;
         geometryTypes.refresh();
      }
      
      public static function geomNameToIdx(param1:String) : int
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < GWizToolData.geometryTypes.length)
         {
            _loc3_ = GWizToolData.geometryTypes.getItemAt(_loc2_);
            if(_loc3_.label == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public static function allowToolMaterial(param1:String, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(isMaterialVisible(param1) == param2)
         {
            return;
         }
         var _loc5_:Function = toolMaterialData.filterFunction;
         toolMaterialData.filterFunction = null;
         toolMaterialData.refresh();
         _loc3_ = 0;
         while(_loc3_ < toolMaterialData.length)
         {
            if((_loc4_ = toolMaterialData.getItemAt(_loc3_)).label == param1)
            {
               _loc4_.visible = param2;
               break;
            }
            _loc3_++;
         }
         toolMaterialData.filterFunction = _loc5_;
         toolMaterialData.refresh();
      }
      
      private static function isMaterialVisible(param1:String) : Boolean
      {
         var _loc4_:Object = null;
         var _loc2_:* = false;
         var _loc3_:int = 0;
         while(_loc3_ < toolMaterialData.length)
         {
            if((_loc4_ = toolMaterialData.getItemAt(_loc3_)).label == param1)
            {
               _loc2_ = String(_loc4_.visible) != "false";
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private static function filterMaterial(param1:Object) : Boolean
      {
         var _loc2_:* = true;
         if(param1.hasOwnProperty("visible"))
         {
            _loc2_ = String(param1.visible) != "false";
         }
         return _loc2_;
      }
      
      public static function isNormalGeoName(param1:String) : Boolean
      {
         return !param1 || param1 == "" || param1 == "Normal";
      }
      
      public static function isTurningTool(param1:String) : Boolean
      {
         return param1.indexOf("Turning") >= 0 || param1.indexOf("Parting") >= 0 || param1.indexOf("Grooving") >= 0 || param1.indexOf("Threading") >= 0 || param1.indexOf("Boring Bar") >= 0;
      }
      
      public static function isNonCuttingTool(param1:String) : Boolean
      {
         return param1.indexOf("Probe") >= 0 || param1.indexOf("Other") >= 0 || param1.indexOf("Empty Toolholder") >= 0 || param1.indexOf("Empty Slot") >= 0;
      }
      
      [Bindable(event="propertyChange")]
      public static function get LatheToolsList() : Array
      {
         return GWizToolData._663562685LatheToolsList;
      }
      
      public static function set LatheToolsList(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolData._663562685LatheToolsList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolData,"LatheToolsList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get MillToolsList() : Array
      {
         return GWizToolData._611030077MillToolsList;
      }
      
      public static function set MillToolsList(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolData._611030077MillToolsList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolData,"MillToolsList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get geometryTypes() : ArrayCollection
      {
         return GWizToolData._2061641945geometryTypes;
      }
      
      public static function set geometryTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolData._2061641945geometryTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolData,"geometryTypes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get toolCoatingData() : ArrayCollection
      {
         return GWizToolData._403661963toolCoatingData;
      }
      
      public static function set toolCoatingData(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolData._403661963toolCoatingData;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolData,"toolCoatingData",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get toolMaterialData() : ArrayCollection
      {
         return GWizToolData._1180104489toolMaterialData;
      }
      
      public static function set toolMaterialData(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolData._1180104489toolMaterialData;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolData,"toolMaterialData",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function set toolType(param1:String) : void
      {
         this._toolType = GWizToolMenu.toPrimitiveLabel(param1);
         if(GWizUtils.debug && param1 == "Empty Slot")
         {
            GWizUtils.assert(this.validToolType());
         }
      }
      
      public function validToolType() : Boolean
      {
         var _loc1_:String = this.toolType;
         return validToolTypeStr(_loc1_);
      }
      
      public function get toolType() : String
      {
         return this._toolType;
      }
      
      public function set cribProduct(param1:String) : void
      {
         this._cribProduct = param1;
      }
      
      public function get cribProduct() : String
      {
         return this._cribProduct;
      }
      
      public function isRougher() : Boolean
      {
         return this.geometry == ROUGHER_GEO_NAME;
      }
      
      public function isFormTap() : Boolean
      {
         return this.geometry == FORM_TAP_GEO_NAME;
      }
      
      public function set geometry(param1:String) : void
      {
         if(!param1)
         {
            param1 = "Normal";
         }
         this._geometry = param1;
         if(param1.toLowerCase().indexOf("degree") >= 0)
         {
            this._geometry = this.cleanGeometry(param1);
         }
         if(this.isEndmill())
         {
            if(this._geometry == "Parabolic")
            {
               this._geometry = "Normal";
            }
         }
         else if(this.isTwistDrill())
         {
            if(this._geometry != "Parabolic")
            {
               this._geometry = "Normal";
            }
         }
         else if(this.isTap())
         {
            if(this._geometry != "Form Tap")
            {
               this._geometry = "Normal";
            }
         }
         else if(!isTurningTool(this.toolType))
         {
            this._geometry = "Normal";
         }
      }
      
      public function isPCD() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.toolmaterial.toLowerCase().indexOf("pcd") >= 0)
         {
            _loc1_ = true;
         }
         else if(this._coating && this._coating.toLowerCase().indexOf("pcd") >= 0)
         {
            _loc1_ = true;
         }
         return _loc1_;
      }
      
      public function get geometry() : String
      {
         return this._geometry;
      }
      
      public function get ballnose() : Boolean
      {
         var _loc1_:String = this.geometry;
         return this.geometry.toLowerCase().indexOf("ballnose") >= 0;
      }
      
      public function get leadAngle() : Number
      {
         if(this._leadAngle <= 0)
         {
            this._leadAngle = 90;
         }
         return this._leadAngle;
      }
      
      public function set leadAngle(param1:Number) : void
      {
         if(param1 <= 0)
         {
            param1 = 90;
         }
         this._leadAngle = param1;
      }
      
      public function set helixAngle(param1:Number) : void
      {
         this._helixAngle = param1;
      }
      
      public function get helixAngle() : Number
      {
         return this._helixAngle;
      }
      
      public function get stickout() : Number
      {
         return this._stickout;
      }
      
      public function set stickout(param1:Number) : void
      {
         this._stickout = param1;
      }
      
      public function get noseRad() : Number
      {
         return this.cornerRadius;
      }
      
      public function set noseRad(param1:Number) : void
      {
         this.cornerRadius = param1;
      }
      
      public function get shankSize() : Number
      {
         var _loc1_:Number = this.toolDiam;
         if(this._customShank)
         {
            if(this._shankSize > 0 && !isNaN(this._shankSize))
            {
               _loc1_ = this._shankSize;
            }
         }
         return _loc1_;
      }
      
      public function set shankSize(param1:Number) : void
      {
         this._customShank = Math.abs(this.toolDiam - param1) >= 0.0001;
         this._shankSize = param1;
      }
      
      public function get cutLength() : Number
      {
         if(isNaN(this._cutLength))
         {
            this._cutLength = this.stickout;
         }
         return this._cutLength;
      }
      
      public function set cutLength(param1:Number) : void
      {
         this._cutLength = param1;
      }
      
      public function get overallLength() : Number
      {
         if(isNaN(this._overallLength) || this._overallLength < this.cutLength)
         {
            this._overallLength = this.cutLength + 1;
         }
         return this._overallLength;
      }
      
      public function set overallLength(param1:Number) : void
      {
         this._overallLength = param1;
      }
      
      public function get coating() : String
      {
         var _loc1_:String = this._coating;
         if(_loc1_ == "")
         {
            if(this.toolType.toLowerCase().indexOf("tialn") >= 0)
            {
               _loc1_ = "TIAlN";
            }
            else if(this.toolType.toLowerCase().indexOf("hp") >= 0)
            {
               _loc1_ = "Uncoated";
            }
            else
            {
               _loc1_ = "Uncoated";
            }
         }
         return _loc1_;
      }
      
      public function set coating(param1:String) : void
      {
         this._coating = param1;
      }
      
      public function get toolmaterial() : String
      {
         var _loc1_:String = this._toolMaterial;
         if(_loc1_ == "")
         {
            if(this.toolType.toLowerCase().indexOf("hss") >= 0)
            {
               _loc1_ = "HSS";
               if(this._coating == "" && this.toolType.toLowerCase().indexOf("hp") >= 0)
               {
                  _loc1_ = "Cobalt";
               }
            }
            else if(this.toolType.toLowerCase().indexOf("cobalt") >= 0)
            {
               _loc1_ = "Cobalt";
            }
            else
            {
               _loc1_ = "Carbide";
            }
         }
         return _loc1_;
      }
      
      public function set toolmaterial(param1:String) : void
      {
         if(GWizUtils.debug && this._toolMaterial == "Carbide" && param1 == "HSS")
         {
            log.debug("gotcha");
         }
         if(param1.toLowerCase().indexOf("pcd") >= 0)
         {
            param1 = "Carbide";
            this.coating = "PCD/CVD (Diamond)";
         }
         this._toolMaterial = param1;
      }
      
      public function coatingMenuIdx() : int
      {
         var _loc1_:String = this.coating;
         var _loc2_:int = 0;
         while(_loc2_ < toolCoatingData.length)
         {
            if(_loc1_ == toolCoatingData.getItemAt(_loc2_).label)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public function toolMaterialMenuIdx() : int
      {
         var _loc1_:String = this.toolmaterial;
         var _loc2_:int = 0;
         while(_loc2_ < toolMaterialData.length)
         {
            if(_loc1_ == toolMaterialData.getItemAt(_loc2_).label)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public function isEndmill() : Boolean
      {
         return this.toolType.toLowerCase().indexOf("mill") >= 0;
      }
      
      public function hasRubbingLimit() : Boolean
      {
         return this.isEndmill() && !this.isVBit() && !this.isDovetail();
      }
      
      public function isTapping() : Boolean
      {
         return this.toolType.indexOf("Tapping") >= 0;
      }
      
      public function isBallnose() : Boolean
      {
         return this.geometry.indexOf("Ballnose") >= 0 || this.isLollipop();
      }
      
      public function isLollipop() : Boolean
      {
         return this.geometry.indexOf("Lollipop") >= 0;
      }
      
      public function isVBit() : Boolean
      {
         return this.geometry.indexOf("V-Bit") >= 0;
      }
      
      public function isChamfer() : Boolean
      {
         return this.geometry.indexOf("Chamfer") >= 0;
      }
      
      public function isCornerRound() : Boolean
      {
         return this.geometry.indexOf("Corner Round") >= 0;
      }
      
      public function isDovetail() : Boolean
      {
         return this.geometry.indexOf("Dovetail") >= 0;
      }
      
      public function isParabolic() : Boolean
      {
         return this.geometry.indexOf("Parabolic") >= 0;
      }
      
      public function isDowncut() : Boolean
      {
         return this.geometry.indexOf("Downcut") >= 0;
      }
      
      public function isCompression() : Boolean
      {
         return this.geometry.indexOf("Compression") >= 0;
      }
      
      public function isStraightFlute() : Boolean
      {
         return this.geometry.indexOf("Straight Flute") >= 0;
      }
      
      public function isNormal() : Boolean
      {
         return this.geometry.indexOf("Normal") >= 0;
      }
      
      public function isTwistDrill() : Boolean
      {
         return this.toolType.indexOf("Twist Drill") >= 0;
      }
      
      public function isTap() : Boolean
      {
         return this.toolType.indexOf("Tapping") >= 0;
      }
      
      public function isReamer() : Boolean
      {
         return this.toolType.indexOf("Reamer") >= 0;
      }
      
      public function isSpotDrill() : Boolean
      {
         return this.toolType.indexOf("Spot Drill") >= 0;
      }
      
      public function getVBitAngle() : Number
      {
         var _loc1_:String = this.geometry;
         if(this.geometry.indexOf("V-Bit") < 0)
         {
            return -1;
         }
         return this.taper(_loc1_);
      }
      
      public function getDovetailAngle() : Number
      {
         var _loc1_:String = this.geometry;
         if(this.geometry.indexOf("Dovetail") < 0)
         {
            return -1;
         }
         return this.taper(_loc1_);
      }
      
      public function isBallnoseDB() : Boolean
      {
         return this.isBallnose() || this.isParabolic();
      }
      
      public function tscTool() : Boolean
      {
         return this.isTwistDrill() || this.toolType == "Indexable Drill" || this.toolType == "Indexable End Or Face Mill" || this.isEndmill();
      }
      
      public function isHP() : Boolean
      {
         return this.toolType.toLowerCase().indexOf("hp") >= 0;
      }
      
      public function isHPToolFromMaterialAndCoating() : Boolean
      {
         var _loc1_:* = false;
         if(this.toolmaterial == "Cobalt" && this.isEndmill())
         {
            _loc1_ = true;
         }
         switch(this.coating)
         {
            case "Uncoated":
               break;
            case "TiN":
            case "TiCN":
            case "ZrN":
            case "TiB2 (Alumastar)":
               _loc1_ = true;
               break;
            case "TiAlN":
            case "AlTiN":
            case "AlTiN Based":
            case "AlCrN":
            case "AlCrN Based":
               _loc1_ = this.toolmaterial != "Carbide";
         }
         return _loc1_;
      }
      
      public function isCarbide() : Boolean
      {
         return this.toolType.toLowerCase().indexOf("carbide") >= 0 || this.toolType.toLowerCase().indexOf("indexable") >= 0;
      }
      
      public function isIndexableMillTool() : Boolean
      {
         return this.toolType.toLowerCase().indexOf("indexable") >= 0;
      }
      
      public function isThreadMill() : Boolean
      {
         return this.toolType.toLowerCase().indexOf("thread") >= 0;
      }
      
      public function rigidityUpgrade() : Boolean
      {
         return !this.isBallnose() && this.VBitAngle() < 0 && this.DovetailAngle() < 0 && !this.isCompression() && !this.isStraightFlute() && !this.isDowncut();
      }
      
      public function VBitAngle() : Number
      {
         var _loc1_:Number = -1;
         if(this.isVBit())
         {
            _loc1_ = this.leadAngle;
         }
         return _loc1_;
      }
      
      public function DovetailAngle() : Number
      {
         var _loc1_:Number = -1;
         if(this.isDovetail())
         {
            _loc1_ = this.leadAngle;
         }
         return _loc1_;
      }
      
      public function taper(param1:String) : Number
      {
         var _loc2_:Number = 0;
         if(param1.indexOf("V-Bit") >= 0)
         {
            switch(param1)
            {
               case "V-Bit - 30 Degree":
                  _loc2_ = 30;
                  break;
               case "V-Bit - 45 Degree":
                  _loc2_ = 45;
                  break;
               case "V-Bit - 60 Degree":
                  _loc2_ = 60;
                  break;
               case "V-Bit - 90 Degree":
                  _loc2_ = 90;
                  break;
               default:
                  _loc2_ = 0;
            }
         }
         else if(param1.indexOf("Dovetail") >= 0)
         {
            switch(param1)
            {
               case "Dovetail - 30 Degree":
                  _loc2_ = 30;
                  break;
               case "Dovetail - 45 Degree":
                  _loc2_ = 45;
                  break;
               case "Dovetail - 60 Degree":
                  _loc2_ = 60;
                  break;
               case "Dovetail - 90 Degree":
                  _loc2_ = 90;
                  break;
               default:
                  _loc2_ = 0;
            }
         }
         else
         {
            _loc2_ = this.leadAngle;
         }
         return _loc2_;
      }
      
      public function cleanGeometry(param1:String) : String
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < geometryTypes.length)
         {
            _loc3_ = geometryTypes.getItemAt(_loc2_);
            if(param1.indexOf(_loc3_.label) >= 0)
            {
               return _loc3_.label;
            }
            _loc2_++;
         }
         return param1;
      }
      
      public function setFromTD(param1:GWizToolDef) : void
      {
         param1.recalc(false);
         this.toolDiam = param1.toolParms.toolDiam;
         this.shankSize = param1.toolParms.shankSize;
         this.flutes = param1.toolParms.flutes;
         this.geometry = param1.geometryLabel();
         this.stickout = param1.toolParms.stickout;
         this.cutLength = param1.toolParms.cutLength;
         this.overallLength = param1.toolParms.overallLength;
         this.cornerRadius = param1.toolParms.cornerRadius;
         this.leadAngle = param1.toolParms.leadAngle;
         this.coating = param1.toolParms.coating;
         this.toolmaterial = param1.toolParms.toolmaterial;
         this.cribProduct = param1.toolParms.cribProduct;
      }
      
      public function setGeometryParms(param1:String, param2:Boolean, param3:Number) : void
      {
         if(!param2)
         {
            param3 = this.toolDiam;
         }
         this._customShank = param2;
         this._shankSize = param3;
         this.geometry = param1;
      }
      
      public function delicateBitIPT(param1:Number) : Number
      {
         if(this.VBitAngle() > 0)
         {
            param1 /= 4;
         }
         else if(this.DovetailAngle() > 0)
         {
            param1 /= 3;
         }
         else if(this.isCompression())
         {
            param1 *= 0.75;
         }
         else if(this.isStraightFlute())
         {
            param1 *= 0.4;
         }
         else if(this.isDowncut())
         {
            param1 *= 0.96;
         }
         else if(this.isCornerRound() || this.isChamfer())
         {
            param1 *= 0.8;
         }
         return param1;
      }
      
      public function calcEffDiam(param1:Number, param2:Number) : Number
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc3_:Number = param1;
         var _loc4_:Boolean = false;
         if(!this.isTwistDrill() && !this.isSpotDrill() && !this.isTapping() && this.toolType.indexOf("Gun Drill") < 0)
         {
            this.leadAngle = Math.round(this.leadAngle);
            if(this.isBallnose())
            {
               _loc5_ = param1 / 2;
               if(param2 > _loc5_)
               {
                  if(this.leadAngle <= 89)
                  {
                     _loc3_ = this.taperDia(this.cutLength - param2,this.leadAngle);
                  }
               }
               else
               {
                  _loc3_ = this.ballnoseDiam(_loc5_,param2);
               }
            }
            else if(_loc4_ && this.isVBit())
            {
               _loc3_ = Math.min(this.toolDiam,GWizGeomUtils.coneDiameter(this.VBitAngle(),param2));
            }
            else if(_loc4_ && this.isChamfer())
            {
               _loc3_ = GWizGeomUtils.coneDiameter(this.leadAngle,param2);
            }
            else if(_loc4_ && this.isCornerRound())
            {
               _loc3_ = GWizGeomUtils.cornerRoundDiameter(this.cutLength,this.toolDiam,param2);
            }
            else if(_loc4_ && this.isNormal() && !this.isIndexableMillTool() && !this.isThreadMill())
            {
               if(param2 > 0)
               {
                  if(this.leadAngle <= 89)
                  {
                     _loc3_ = this.taperDia(this.cutLength - param2,this.leadAngle);
                  }
                  if(param2 < this.cornerRadius)
                  {
                     _loc6_ = 2 * (_loc3_ / 2 - this.cornerRadius);
                     _loc3_ = this.ballnoseDiam(this.cornerRadius,param2);
                     _loc3_ += _loc6_;
                  }
               }
            }
            else
            {
               _loc3_ = param1;
            }
         }
         return _loc3_;
      }
      
      private function ballnoseDiam(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = param2;
         if(_loc3_ > param1)
         {
            _loc3_ = param1;
         }
         var _loc4_:Number = param1 * param1 - (param1 - _loc3_) * (param1 - _loc3_);
         return Number(2 * Math.sqrt(_loc4_));
      }
      
      private function taperDia(param1:Number, param2:Number) : Number
      {
         param2 = GWizUtils.radians(param2 / 2);
         var _loc3_:Number = param1 * Math.tan(param2);
         return Math.max(0,this.toolDiam - 2 * _loc3_);
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
