package cadcamwiz
{
   import configinfo.GWizSettings;
   import feedsspeeds.GWizFeedsSpeeds2;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizCCWEstRecord
   {
      
      private static const log:ILogger = Log.getLogger("GWizCCWEstRecord");
      
      public static var estimatorFields:Array = ["Seq","type","op","desc","qty","tool","toolOther","guid","time","opTime","oprate","addlTime","addlCost","height","width","rpm","sfm","feedrate","ipr","workcenter","material","hourly","rateper","stickout","toolDia","flutes","hsm","corncob","mrr","roughing","dfm","perimeter","volume","vendor","markup","var1"];
      
      public static var createNumber:int = 0;
      
      public static const CCE_DOC_SECTION:String = "Doc";
      
      public static const CCE_FIXED_COST_SECTION:String = "Fixed";
      
      public static const CCE_VARIABLE_COST_SECTION:String = "Variable";
      
      public static const SUMMARY_TYPE:String = "Summary";
      
      public static const MATERIAL_TYPE:String = "Material";
      
      public static const ROUGH_CUT_TYPE:String = "Rough Cut";
      
      public static const SETUP_TYPE:String = "Setup";
      
      public static const MACHINING_TYPE:String = "Machining";
      
      public static const INSPECTION_TYPE:String = "Inspection";
      
      public static const PROGRAMMING_TYPE:String = "Programming";
      
      public static const COMPONENTS_TYPE:String = "Components";
      
      public static const FINISH_DEBURR_TYPE:String = "Finish/Deburr";
      
      public static const PACK_SHIP_TYPE:String = "Pack-Ship";
      
      public static const OTHER_TYPE:String = "Other";
      
      public static var validCCETypes:Array = [SUMMARY_TYPE,MATERIAL_TYPE,ROUGH_CUT_TYPE,SETUP_TYPE,MACHINING_TYPE,INSPECTION_TYPE,PROGRAMMING_TYPE,COMPONENTS_TYPE,FINISH_DEBURR_TYPE,PACK_SHIP_TYPE,OTHER_TYPE];
      
      public static const CCE_CUSTOMER:String = "Customer";
      
      public static const CCE_BUYER:String = "Buyer";
      
      public static const CCE_EST_DESCRIPTION:String = "Description";
      
      public static const CCE_PARTNUM:String = "Part Num";
      
      public static const CCE_ORDERSZ:String = "Order Size";
      
      public static const CCE_ESTIMATOR:String = "Estimator";
      
      public static const CCE_EST_REVISION:String = "Revision";
      
      public static const CCE_EST_DATE:String = "Est Date";
      
      public static const CCE_SCRAP_ALLOWANCE:String = "Scrap Allowance";
      
      public static const CCE_VERSION:String = "Version";
      
      public static const CCE_CNC_PREFIX:String = "CNC";
      
      public static const CCE_MILL_POCKET:String = "Pocket";
      
      public static const CCE_MILL_2DProfile:String = "2D Profile";
      
      public static const CCE_MILL_HOLE:String = "CNC Mill Hole";
      
      public static const CCE_MILL_3DSURFACE:String = "3D Surface";
      
      public static const CCE_MILL_FACEMILL:String = "Face Mill";
      
      public static const CCE_LATHE_ODTURN:String = "CNC Lathe OD Turn";
      
      public static const CCE_LATHE_IDTURN:String = "CNC Lathe ID Turn";
      
      public static const CCE_LATHE_FACING:String = "CNC Lathe Facing";
      
      public static const CCE_LATHE_GROOVEPART:String = "CNC Lathe Grooving/Parting";
      
      public static const CCE_LATHE_THREADPART:String = "CNC Lathe Threading";
      
      public static const CCE_FEEDSSPEEDS:String = "Custom Feeds/Speeds";
      
      public static const CCE_DRILL:String = "Drill";
      
      public static const CCE_CHAMFER:String = "Chamfer";
      
      public static const CCE_SPOT_DRILL:String = "Spot Drill";
      
      public static const CCE_REAM:String = "Ream";
      
      public static const CCE_TAP:String = "Tap";
      
      public static const CCE_THREAD_MILL:String = "Thread Mill";
      
      public static const CCE_PROGRAMMING:String = "CNC Programming";
      
      public static const CCE_MATERIAL:String = "Material";
      
      public static const CCE_BANDSAW:String = "Bandsaw";
      
      public static const CCE_WATERJET:String = "Waterjet";
      
      public static const CCE_PLASMA:String = "Plasma Cutting";
      
      public static const CCE_CONSUME_CUTTERS:String = "Cutters";
      
      public static const CCE_CONSUME_ABRASIVES:String = "Abrasives";
      
      public static const CCE_CONSUME_OTHER:String = "Other Consumables";
      
      public static const CCE_COMPONENT_BEARINGS:String = "Bearings";
      
      public static const CCE_COMPONENT_ELECTRICAL:String = "Electrical";
      
      public static const CCE_COMPONENT_FASTENERS:String = "Fasteners";
      
      public static const CCE_COMPONENT_FITTINGS:String = "Fittings";
      
      public static const CCE_COMPONENT_SEALS:String = "Seals";
      
      public static const CCE_COMPONENT_SUBASSEMBLY:String = "Sub Assembly";
      
      public static const CCE_COMPONENT_OTHER:String = "Other Component";
      
      public static const CCE_SETUP:String = "Setup";
      
      public static const CCE_BEADBLAST:String = "Bead Blast";
      
      public static const CCE_TUMBLE:String = "Tumble";
      
      public static const CCE_FINISH_OTHER:String = "Other Finish";
      
      public static const CCE_INSPECTION_OTHER:String = "Other Inspection";
      
      public static const CCE_ANODIZING:String = "Anodizing";
      
      public static const CCE_POWDERCOATING:String = "Powder Coating";
      
      public static const CCE_PAINTING:String = "Painting";
      
      public static const CCE_COATING_OTHER:String = "Other Coating";
      
      public static const CCE_SUBCONTRACT_OTHER:String = "Other Subcontract";
      
      public static const CCE_FREIGHT_OTHER:String = "Other Freight";
      
      public static const CCE_OTHER:String = "Other Expense";
      
      public static var CCEEditors:ArrayCollection = new ArrayCollection([{
         "type":CCE_OTHER,
         "editor":null
      }]);
       
      
      public var createID:int = 0;
      
      public var Seq:int = 0;
      
      private var _type:String = "Other";
      
      public var op:String = "Other";
      
      private var _desc:String = "";
      
      public var qty:int = 1;
      
      private var _tool:String = "";
      
      public var toolOther:String = "";
      
      public var guid:String = "";
      
      private var _opTime:Number;
      
      public var oprate:Number;
      
      public var addlTime:Number = 0.0;
      
      public var addlCost:Number = 0.0;
      
      public var height:Number = 0.0;
      
      public var width:Number = 0.0;
      
      public var rpm:Number = 0.0;
      
      public var sfm:Number = 0.0;
      
      public var feedrate:Number = 0.0;
      
      public var ipr:Number;
      
      public var stickout:Number;
      
      public var workcenter:String = "";
      
      private var _hourly:Number;
      
      public var rateper:String = "Doc";
      
      public var entryMode:String = "";
      
      public var entryFeedrate:Number;
      
      private var _mrr:Number;
      
      private var _toolDia:Number;
      
      public var flutes:Number;
      
      public var hsm:String = "false";
      
      public var corncob:String = "false";
      
      public var roughing:String = "false";
      
      private var _perimeter:Number;
      
      public var dfm:String = "";
      
      public var passes:int;
      
      public var tests:int = 0;
      
      public var fitness:Number;
      
      public var hints:String = "";
      
      private var _volume:Number = 0.0;
      
      public var vendor:String = "";
      
      public var markup:Number = 0.0;
      
      public var material:String = "";
      
      public var var1:Number;
      
      public function GWizCCWEstRecord(param1:String, param2:String)
      {
         super();
         this.type = param1;
         this.op = param2;
         this.createID = createNumber++;
      }
      
      public static function initCustomer(param1:String) : GWizCCWEstRecord
      {
         return initDocRec(SUMMARY_TYPE,CCE_CUSTOMER,param1);
      }
      
      public static function initBuyer(param1:String) : GWizCCWEstRecord
      {
         return initDocRec(SUMMARY_TYPE,CCE_BUYER,param1);
      }
      
      public static function initDescription(param1:String) : GWizCCWEstRecord
      {
         return initDocRec(SUMMARY_TYPE,CCE_EST_DESCRIPTION,param1);
      }
      
      public static function initPartNum(param1:String) : GWizCCWEstRecord
      {
         return initDocRec(SUMMARY_TYPE,CCE_PARTNUM,param1);
      }
      
      public static function initOrderSize(param1:Number) : GWizCCWEstRecord
      {
         var _loc2_:GWizCCWEstRecord = new GWizCCWEstRecord(SUMMARY_TYPE,CCE_ORDERSZ);
         _loc2_.width = param1;
         return _loc2_;
      }
      
      public static function initEstimator(param1:String) : GWizCCWEstRecord
      {
         return initDocRec(SUMMARY_TYPE,CCE_ESTIMATOR,param1);
      }
      
      public static function initRevision(param1:String) : GWizCCWEstRecord
      {
         return initDocRec(SUMMARY_TYPE,CCE_EST_REVISION,param1);
      }
      
      public static function initDate(param1:String) : GWizCCWEstRecord
      {
         return initDocRec(SUMMARY_TYPE,CCE_EST_DATE,param1);
      }
      
      public static function initScrap(param1:Number) : GWizCCWEstRecord
      {
         var _loc2_:GWizCCWEstRecord = new GWizCCWEstRecord(SUMMARY_TYPE,CCE_SCRAP_ALLOWANCE);
         _loc2_.width = param1;
         return _loc2_;
      }
      
      public static function initVersion(param1:Number) : GWizCCWEstRecord
      {
         var _loc2_:GWizCCWEstRecord = new GWizCCWEstRecord(SUMMARY_TYPE,CCE_VERSION);
         _loc2_.width = param1;
         return _loc2_;
      }
      
      private static function initDocRec(param1:String, param2:String, param3:String) : GWizCCWEstRecord
      {
         var _loc4_:GWizCCWEstRecord;
         (_loc4_ = new GWizCCWEstRecord(param1,param2)).desc = param3;
         return _loc4_;
      }
      
      public static function whichEditor() : Function
      {
         return null;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function set type(param1:String) : void
      {
         if(!this.isValidCCEType(param1))
         {
            log.debug("Unkown type \'" + param1 + " converted to OTHER_TYPE");
            param1 = OTHER_TYPE;
         }
         this._type = param1;
      }
      
      public function set desc(param1:String) : void
      {
         this._desc = param1;
      }
      
      public function get desc() : String
      {
         return this._desc;
      }
      
      public function get tool() : String
      {
         return this._tool;
      }
      
      public function set tool(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         if(GWizUtils.debug)
         {
            _loc2_ = param1.toLowerCase().indexOf("ballnose");
            _loc3_ = param1.substr(_loc2_ + 1);
            if(_loc3_.toLowerCase().indexOf("ballnose") >= 0)
            {
               GWizUtils.assert(false);
            }
         }
         this._tool = param1;
      }
      
      public function get time() : String
      {
         return GWizUtils.formatMinToHMS(this.opTime);
      }
      
      public function set time(param1:String) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         while(_loc7_ < param1.length)
         {
            if(param1.charAt(_loc7_) == ":")
            {
               _loc5_++;
               if(_loc5_ == 1)
               {
                  _loc2_ = Number(param1.substr(0,_loc7_));
               }
               else if(_loc5_ == 2)
               {
                  _loc3_ = Number(param1.substr(_loc6_ + 1,_loc7_ - _loc6_));
               }
               _loc6_ = _loc7_;
            }
            _loc7_++;
         }
         _loc4_ = Number(param1.substr(_loc6_ + 1));
         this.opTime = _loc2_ * 60 + _loc3_ + _loc4_ / 60;
         if(isNaN(this.opTime))
         {
            this.opTime = 0;
         }
      }
      
      public function get opTime() : Number
      {
         return this._opTime;
      }
      
      public function set opTime(param1:Number) : void
      {
         this._opTime = param1;
      }
      
      public function set hourly(param1:Number) : void
      {
         this._hourly = param1;
      }
      
      public function get hourly() : Number
      {
         return this._hourly;
      }
      
      public function get mrr() : Number
      {
         return this._mrr;
      }
      
      public function set mrr(param1:Number) : void
      {
         this._mrr = param1;
      }
      
      public function get toolDia() : Number
      {
         return this._toolDia;
      }
      
      public function set toolDia(param1:Number) : void
      {
         this._toolDia = param1;
      }
      
      public function hsmTrue() : Boolean
      {
         return this.hsm.toLowerCase() == "true";
      }
      
      public function corncobTrue() : Boolean
      {
         return this.corncob.toLowerCase() == "true";
      }
      
      public function roughingTrue() : Boolean
      {
         return this.roughing.toLowerCase() == "true";
      }
      
      public function set perimeter(param1:Number) : void
      {
         this._perimeter = param1;
      }
      
      public function get perimeter() : Number
      {
         return this._perimeter;
      }
      
      public function set volume(param1:Number) : void
      {
         this._volume = param1;
      }
      
      public function get volume() : Number
      {
         return this._volume;
      }
      
      public function set holeDepth(param1:Number) : void
      {
         this.perimeter = param1;
      }
      
      public function get holeDepth() : Number
      {
         return this.perimeter;
      }
      
      public function set peck(param1:Number) : void
      {
         this.volume = param1;
      }
      
      public function get peck() : Number
      {
         return this.volume;
      }
      
      public function clone() : GWizCCWEstRecord
      {
         var _loc1_:GWizCCWEstRecord = new GWizCCWEstRecord(this.type,this.op);
         _loc1_.desc = this.desc;
         _loc1_.tool = this.tool;
         _loc1_.opTime = this.opTime;
         _loc1_.oprate = this.oprate;
         _loc1_.addlTime = this.addlTime;
         _loc1_.addlCost = this.addlCost;
         _loc1_.height = this.height;
         _loc1_.width = this.width;
         _loc1_.rpm = this.rpm;
         _loc1_.feedrate = this.feedrate;
         _loc1_.stickout = this.stickout;
         _loc1_.workcenter = this.workcenter;
         _loc1_.hourly = this.hourly;
         _loc1_.rateper = this.rateper;
         _loc1_.mrr = this.mrr;
         _loc1_.toolDia = this.toolDia;
         _loc1_.flutes = this.flutes;
         _loc1_.hsm = this.hsm;
         _loc1_.corncob = this.corncob;
         _loc1_.roughing = this.roughing;
         _loc1_.passes = this.passes;
         _loc1_.volume = this.volume;
         _loc1_.perimeter = this.perimeter;
         _loc1_.dfm = this.dfm;
         _loc1_.tests = this.tests;
         _loc1_.fitness = this.fitness;
         _loc1_.hints = this.hints;
         _loc1_.vendor = this.vendor;
         _loc1_.markup = this.markup;
         _loc1_.material = this.material;
         _loc1_.var1 = this.var1;
         return _loc1_;
      }
      
      public function fromObject(param1:Object, param2:Boolean = false) : Boolean
      {
         var _loc3_:int = 0;
         while(_loc3_ < estimatorFields.length)
         {
            if(param1.hasOwnProperty(estimatorFields[_loc3_]))
            {
               this[estimatorFields[_loc3_]] = param1[estimatorFields[_loc3_]];
            }
            else if(param2)
            {
               log.debug("Missing field: " + estimatorFields[_loc3_]);
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public function fromFeedsSpeeds(param1:GWizFeedsSpeeds2) : void
      {
         this.tool = this.toolDescFromFeedsSpeeds(param1);
         this.toolDia = param1.td.toolParms.toolDiam;
         this.flutes = param1.td.toolParms.flutes;
         this.stickout = param1.td.toolParms.stickout;
         this.corncob = String(param1.td.toolParms.isRougher());
         this.height = GWizUtils.zeroNaN(param1.cutDepth.getVal());
         this.width = GWizUtils.zeroNaN(param1.cutWidth.getVal());
         this.hsm = String(param1.useHSM());
         this.rpm = param1.RPM.getVal();
         this.sfm = GWizSettings.FeedsSpeedsApp.api.getSFM();
         this.feedrate = param1.IPM.getVal();
         this.ipr = GWizSettings.FeedsSpeedsApp.api.getIPR();
         this.mrr = GWizUtils.zeroNaN(GWizSettings.FeedsSpeedsApp.api.getMRR());
         this.addHints(param1);
         this.timeByType();
      }
      
      public function addHints(param1:GWizFeedsSpeeds2) : void
      {
         var _loc3_:* = null;
         this.hints = "";
         var _loc2_:int = 0;
         while(_loc2_ < param1.tipList.length)
         {
            _loc3_ = param1.tipList[_loc2_].label + "   ";
            this.hints += _loc3_;
            _loc2_++;
         }
      }
      
      public function toolDescFromFeedsSpeeds(param1:GWizFeedsSpeeds2) : String
      {
         var _loc2_:String = param1.Tool.selectedLabel;
         var _loc3_:* = String(GWizUtils.roundThousandths(param1.td.toolParms.toolDiam)) + "\"";
         var _loc4_:String = "";
         if(param1.td.toolParms.isRougher())
         {
            _loc4_ = "Corncob ";
         }
         else if(param1.td.toolParms.ballnose)
         {
            _loc4_ = "Ballnose ";
         }
         var _loc5_:* = "";
         if(_loc2_.toLowerCase().indexOf("endmill") >= 0)
         {
            _loc5_ = param1.td.toolParms.flutes + " flute ";
         }
         return _loc3_ + " " + _loc5_ + _loc4_ + _loc2_;
      }
      
      private function isValidCCEType(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < validCCETypes.length)
         {
            if(param1 == validCCETypes[_loc2_])
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      private function timeByVolumeMRR() : Number
      {
         var _loc1_:Number = this.volume / Number(this.mrr);
         this.opTime = _loc1_;
         return _loc1_;
      }
      
      private function timeByPerimeter() : Number
      {
         var _loc1_:Number = this.perimeter / Number(this.feedrate);
         this.opTime = _loc1_;
         return _loc1_;
      }
      
      private function timeByHoleDepthPeck() : Number
      {
         this.opTime = NaN;
         if(!isNaN(this.mrr))
         {
            this.opTime = this.holeDepth / this.feedrate;
            if(this.peck > 0)
            {
               this.opTime *= 2;
            }
         }
         return this.opTime;
      }
      
      private function pathLenByTimeAndFeedrate() : Number
      {
         var _loc1_:Number = this.opTime * 60;
         return Number(_loc1_ * this.feedrate);
      }
      
      private function pathLenByHoleDepthPeck() : Number
      {
         return Number(this.height);
      }
      
      public function pathLenByType() : Number
      {
         var _loc1_:Number = 0;
         switch(this.op)
         {
            case GWizCCWEstRecord.CCE_MILL_HOLE:
            case GWizCCWEstRecord.CCE_DRILL:
            case GWizCCWEstRecord.CCE_SPOT_DRILL:
            case GWizCCWEstRecord.CCE_REAM:
            case GWizCCWEstRecord.CCE_TAP:
            case GWizCCWEstRecord.CCE_THREAD_MILL:
               _loc1_ = this.pathLenByHoleDepthPeck();
               break;
            case GWizCCWEstRecord.CCE_MILL_POCKET:
            case GWizCCWEstRecord.CCE_MILL_2DProfile:
            case GWizCCWEstRecord.CCE_MILL_FACEMILL:
            case GWizCCWEstRecord.CCE_LATHE_ODTURN:
               _loc1_ = this.pathLenByTimeAndFeedrate();
               break;
            case GWizCCWEstRecord.CCE_FEEDSSPEEDS:
            case GWizCCWEstRecord.CCE_MILL_3DSURFACE:
            case GWizCCWEstRecord.CCE_CHAMFER:
               _loc1_ = this.pathLenByTimeAndFeedrate();
               break;
            default:
               log.debug("type = " + this.type + ", op = " + this.op + ", desc = " + this.desc);
         }
         return _loc1_;
      }
      
      public function timeByType() : Number
      {
         switch(this.op)
         {
            case GWizCCWEstRecord.CCE_MILL_HOLE:
            case GWizCCWEstRecord.CCE_DRILL:
            case GWizCCWEstRecord.CCE_SPOT_DRILL:
            case GWizCCWEstRecord.CCE_REAM:
            case GWizCCWEstRecord.CCE_TAP:
            case GWizCCWEstRecord.CCE_THREAD_MILL:
               this.opTime = this.timeByHoleDepthPeck();
               break;
            case GWizCCWEstRecord.CCE_MILL_POCKET:
            case GWizCCWEstRecord.CCE_MILL_2DProfile:
            case GWizCCWEstRecord.CCE_MILL_FACEMILL:
            case GWizCCWEstRecord.CCE_LATHE_ODTURN:
               this.opTime = this.timeByVolumeMRR();
               break;
            case GWizCCWEstRecord.CCE_FEEDSSPEEDS:
            case GWizCCWEstRecord.CCE_MILL_3DSURFACE:
            case GWizCCWEstRecord.CCE_CHAMFER:
               this.opTime = this.timeByPerimeter();
               break;
            default:
               log.debug("type = " + this.type + ", op = " + this.op);
               GWizUtils.assert(false);
         }
         return this.opTime;
      }
   }
}
