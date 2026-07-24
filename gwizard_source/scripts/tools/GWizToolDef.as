package tools
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizNumStepOvr;
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import feedsspeeds.GWizFeedsSpeeds2;
   import feedsspeeds.GWizOptimizeBtn;
   import flash.display.DisplayObject;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizToolDef extends HGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizToolDef");
      
      private static var _1926562559_lockForToolCrib:Boolean = false;
      
      private static var stopSetFunctionsRecursion:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1111681345FlutesLabel:Label;
      
      private var _912500874SizesBtn:Button;
      
      private var _919276975ToolIcon:Image;
      
      public var _GWizToolDef_GWizForePanel1:GWizForePanel;
      
      public var _GWizToolDef_GWizForePanel2:GWizForePanel;
      
      public var _GWizToolDef_GWizForePanel3:GWizForePanel;
      
      private var _1628519736_LeadAngle:GWizNumStep;
      
      private var _1437017714_flutes:NumericStepper;
      
      private var _1622242845_stickout:GWizNumStep;
      
      private var _51203036_toolDiameter:GWizNumStep;
      
      private var _803034925coatingLbl:Label;
      
      private var _797109874geomButton:Label;
      
      private var _1364283555geomGroup:HGroup;
      
      private var _99190371optStick:GWizOptimizeBtn;
      
      private var _869366045toCrib:Button;
      
      private var _2021666192toolDiaLabel:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _toolParms:GWizToolData;
      
      public var IPT:GWizNumStepOvr = null;
      
      public var recalcFcn:Function = null;
      
      public var setFunctionsFcn:Function = null;
      
      public var ccDone:Boolean = false;
      
      private var pickerEM:Boolean = false;
      
      private var lastTool:String = "";
      
      private const TOOL_DIAM:String = "Tool Dia.";
      
      private var saveLeadAng:GWizNumStep = null;
      
      private var geomIndex:int = 0;
      
      public var popupToolMenu:Function;
      
      private var _373675717hideToCrib:Boolean = false;
      
      private var _1657211086labelWidth:int = 90;
      
      private var _193361929gapSize:int = 10;
      
      private var _835562194hideLabel:Boolean = false;
      
      private var _186804323firstColWd:int;
      
      private var _239444057secondColWd:int;
      
      private var _981532858thirdColWd:int;
      
      private var _42772364optStickFcn:Function;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizToolDef()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._toolParms = new GWizToolData();
         this.popupToolMenu = GWizFeedsSpeeds2.popToolMenu;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizToolDef_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizToolDefWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizToolDef[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.gap = 1;
         this.verticalAlign = "middle";
         this.horizontalAlign = "left";
         this.mxmlContent = [this._GWizToolDef_GWizForePanel1_i(),this._GWizToolDef_GWizForePanel2_i(),this._GWizToolDef_GWizForePanel3_i()];
         this.addEventListener("creationComplete",this.___GWizToolDef_HGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set lockForToolCrib(param1:Boolean) : void
      {
         _lockForToolCrib = param1;
      }
      
      public static function get lockForToolCrib() : Boolean
      {
         return _lockForToolCrib;
      }
      
      public static function geometryFromBasics(param1:String, param2:String) : String
      {
         var _loc3_:String = param2;
         if(_loc3_ == "Normal")
         {
            _loc3_ = "";
         }
         return _loc3_;
      }
      
      public static function toolDefDescArgs(param1:Number, param2:int, param3:int, param4:String, param5:String, param6:Number, param7:Number) : String
      {
         var _loc8_:* = "";
         var _loc9_:String = GWizUtils.Units == GWizUtils.INCHES_UNITS ? "\" " : "mm ";
         _loc8_ = GWizUtils.roundThousandths(param1,true) + _loc9_ + param2 + " Flute";
         if(param3 != 90)
         {
            _loc8_ += param3 + " degree";
         }
         if(param4.length > 0)
         {
            _loc8_ += " " + param4;
         }
         _loc8_ = (_loc8_ += " " + param5 + " ") + (" " + GWizUtils.roundThousandths(param6,true) + _loc9_ + "stickout");
         if(param7 > 0)
         {
            _loc8_ += " " + GWizUtils.roundThousandths(param7,true) + _loc9_ + "nose radius";
         }
         return _loc8_;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizToolDef._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get _lockForToolCrib() : Boolean
      {
         return GWizToolDef._1926562559_lockForToolCrib;
      }
      
      private static function set _lockForToolCrib(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolDef._1926562559_lockForToolCrib;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolDef,"_lockForToolCrib",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      public function set toolParms(param1:GWizToolData) : void
      {
         this._toolParms = param1;
         this._flutes.value = param1.flutes;
         this._toolDiameter.setVal(param1.toolDiam);
         this._stickout.setVal(param1.stickout);
         this._LeadAngle.setVal(param1.leadAngle);
         var _loc2_:String = this.geometryLabel();
         this.coatingLbl.text = param1.coating;
      }
      
      public function get toolParms() : GWizToolData
      {
         return this._toolParms;
      }
      
      private function onCC() : void
      {
         this._toolDiameter.customArrowInterval(GWizUtils.SIXTEENTH,GWizUtils.TENTH_MM);
         this.ccDone = true;
      }
      
      public function recalc(param1:Boolean = true) : void
      {
         GWizUtils.LogErrorContext = "GWizToolDef.recalc";
         this.toolParms.toolDiam = this._toolDiameter.getVal();
         this.toolParms.flutes = this._flutes.value;
         this.toolParms.geometry = this.geometryLabel();
         this.toolParms.stickout = this._stickout.getVal();
         if(this._LeadAngle.visible)
         {
            this.toolParms.leadAngle = this._LeadAngle.value;
         }
         if(this.recalcFcn != null && param1)
         {
            this.recalcFcn();
         }
      }
      
      private function showDrillPicker() : void
      {
         var _loc1_:GWizDrillPicker = GWizDrillPicker(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizDrillPicker,true));
         if(_loc1_)
         {
            if(!this.pickerEM)
            {
               _loc1_.dc.setFilter(true,false,false);
            }
            else if(GWizUtils.Units == GWizUtils.MM_UNITS)
            {
               _loc1_.dc.setFilter(false,false,true);
            }
            else
            {
               _loc1_.dc.setFilter(false,true,false);
            }
            _loc1_.diameter = this._toolDiameter;
            _loc1_.setDefault();
         }
      }
      
      public function setFunctions(param1:String) : void
      {
         GWizUtils.LogErrorContext = "GWizToolDef.setFunctions( tool = " + param1 + " )";
         if(this._toolDiameter == null)
         {
            return;
         }
         param1 = GWizToolMenu.toPrimitiveLabel(param1);
         if(!this.saveLeadAng)
         {
            this.saveLeadAng = GWizNumStep(this.geomGroup.removeElement(this._LeadAngle));
         }
         GWizUtils.LogErrorContext = "GWizToolDef.setFunctions( toolDiameter != null )";
         GWizUtils.LogErrorContext = "GWizToolDef.setFunctions( ballnose defaults )";
         GWizUtils.LogErrorContext = "GWizToolDef.setFunctions( top of switch )";
         this.saveLeadAng.visible = false;
         this.pickerEM = false;
         GWizGraphicToolMenu.twistDrillGeometry = false;
         GWizGraphicToolMenu.emGeometry = false;
         GWizGraphicToolMenu.tapGeometry = false;
         this.showGeometry(true);
         switch(param1)
         {
            case "HSS Spot Drill":
            case "Carbide Spot Drill":
            case "HSS Center Drill":
            case "Carbide Center Drill":
            case "HSS Twist Drill":
            case "Carbide Twist Drill":
            case "HSS Spade Drill":
            case "Carbide Spade Drill":
            case "Gun Drill":
            case "Cobalt Twist Drill":
            case "HP HSS Twist Drill":
            case "HP Carbide Twist Drill":
               this.toolDiaLabel.text = this.TOOL_DIAM;
               this.toolDiaLabel.toolTip = "Diameter of the cutting tool.";
               this.FlutesLabel.visible = false;
               this._flutes.value = 2;
               this._flutes.visible = false;
               this._stickout.visible = param1.indexOf("Gun") < 0;
               this.saveLeadAng.value = 90;
               GWizGraphicToolMenu.twistDrillGeometry = false;
               if(param1 != "HSS Spade Drill" && param1 != "Gun Drill")
               {
                  if(param1 != "HSS Spot Drill")
                  {
                     GWizGraphicToolMenu.twistDrillGeometry = true;
                  }
               }
               this.showGeometry(GWizGraphicToolMenu.twistDrillGeometry);
               break;
            case "Indexable Drill":
            case "HSS Reamer":
            case "Carbide Reamer":
               this.toolDiaLabel.text = this.TOOL_DIAM;
               this.toolDiaLabel.toolTip = "Diameter of the cutting tool.";
               this._flutes.value = 2;
               this._flutes.visible = param1 == "Indexable Drill" ? true : false;
               this.FlutesLabel.visible = this._flutes.visible;
               this.showGeometry(false);
               this._stickout.visible = false;
               this.saveLeadAng.value = 90;
               break;
            case "Turning: HSS":
            case "Turning: Carbide":
            case "HSS Turning":
            case "Carbide Turning":
            case "HSS Boring":
            case "Carbide Boring":
            case "HSS Boring Bar":
            case "Carbide Boring Bar":
            case "Carbide Parting/Grooving":
            case "HSS Parting/Grooving":
            case "Parting/Grooving":
            case "Carbide Parting":
            case "HSS Parting":
            case "Parting":
            case "Carbide Grooving":
            case "HSS Grooving":
            case "Grooving":
            case "Carbide Threading":
            case "HSS Threading":
            case "Threading":
               this.toolDiaLabel.text = "Max Dia.";
               this.toolDiaLabel.toolTip = "Diameter of the circle we\'re cutting or threading.";
               this.FlutesLabel.visible = false;
               this._flutes.value = 1;
               this._flutes.visible = false;
               this._stickout.visible = false;
               this.saveLeadAng.value = 90;
               this.showGeometry(false);
               break;
            case "Carbide Tapping":
            case "HSS Tapping":
            case "Tapping":
               this.toolDiaLabel.text = "Major Diameter";
               this.toolDiaLabel.toolTip = "Major Diameter of the thread.";
               this.FlutesLabel.visible = false;
               this._flutes.value = 1;
               this._flutes.visible = false;
               this._stickout.visible = true;
               this.saveLeadAng.value = 90;
               GWizGraphicToolMenu.tapGeometry = true;
               this.showGeometry(true);
               break;
            case "Carbide Thread Mill":
               this._stickout.visible = true;
               this.saveLeadAng.value = 90;
               this.showGeometry(false);
               break;
            case "Saws & Woodruff Cutters":
            case "Carbide Saws & Woodruff Cutters":
            case "HSS Saws & Woodruff Cutters":
               this.toolDiaLabel.text = this.TOOL_DIAM;
               this.toolDiaLabel.toolTip = "Diameter of the cutting tool.";
               this.FlutesLabel.visible = true;
               this._flutes.visible = true;
               this._stickout.visible = false;
               this.saveLeadAng.value = 90;
               this.showGeometry(false);
               break;
            case "Indexable End Or Face Mill":
               GWizUtils.LogErrorContext = "GWizToolDef.setFunctions( Indexable End Or Face Mill switch top )";
               this.saveLeadAng.visible = true;
            default:
               GWizUtils.LogErrorContext = "GWizToolDef.setFunctions( switch default top )";
               this.toolDiaLabel.text = this.TOOL_DIAM;
               this.toolDiaLabel.toolTip = "Diameter of the cutting tool.";
               this.FlutesLabel.visible = true;
               this._flutes.visible = true;
               this._stickout.visible = true;
               if(param1 != "Indexable End Or Face Mill" && this.geomButton.text == "Normal")
               {
                  this.saveLeadAng.value = 90;
               }
               this.pickerEM = true;
               GWizGraphicToolMenu.emGeometry = true;
         }
         this.toolParms.toolType = param1;
         if(param1 != this.lastTool)
         {
            GWizToolData.refreshGeometry();
            if(this.toolFamily(this.lastTool) != this.toolFamily(param1))
            {
               this.setGeometryIndex(0);
            }
            this.lastTool = param1;
         }
         GWizUtils.LogErrorContext = "GWizToolDef.setFunctions( Finished switch stmt )";
         if(this.toolParms.isBallnose() || this.toolParms.VBitAngle() > 0 || this.toolParms.DovetailAngle() > 0 || this.toolParms.isDowncut() || this.toolParms.isCompression() || this.toolParms.isStraightFlute())
         {
            this.saveLeadAng.visible = false;
            this.saveLeadAng.value = 90;
         }
         GWizUtils.LogErrorContext = "GWizToolDef.setFunctions( Did LeadAngle visibility )";
         if(this.saveLeadAng.visible)
         {
            this.geomGroup.addElement(this.saveLeadAng);
            this.saveLeadAng = null;
         }
         GWizUtils.LogErrorContext = "GWizToolDef.setFunctions( Did object widths )";
         this.recalc();
         GWizUtils.LogErrorContext = "GWizToolDef.setFunctions( Finished recalc, returning )";
      }
      
      private function toolFamily(param1:String) : String
      {
         var _loc2_:String = "";
         switch(param1)
         {
            case "HSS Spot Drill":
            case "Carbide Spot Drill":
            case "HSS Center Drill":
            case "Carbide Center Drill":
               _loc2_ = "Spot Drill";
               break;
            case "HSS Twist Drill":
            case "Carbide Twist Drill":
            case "Cobalt Twist Drill":
            case "HP HSS Twist Drill":
            case "HP Carbide Twist Drill":
               _loc2_ = "Twist Drill";
               break;
            case "HSS Spade Drill":
            case "Carbide Spade Drill":
            case "Gun Drill":
            case "Indexable Drill":
               _loc2_ = "Other Drill";
               break;
            case "HSS Reamer":
            case "Carbide Reamer":
               _loc2_ = "Reamer";
               break;
            case "Turning: HSS":
            case "Turning: Carbide":
            case "HSS Boring":
            case "Carbide Boring":
            case "Carbide Parting/Grooving":
            case "HSS Parting/Grooving":
            case "Parting/Grooving":
               _loc2_ = "Single Point";
               break;
            case "Carbide Tapping":
            case "HSS Tapping":
            case "Tapping":
               _loc2_ = "Tapping";
               break;
            case "Saws & Woodruff Cutters":
            case "Carbide Saws & Woodruff Cutters":
            case "HSS Saws & Woodruff Cutters":
               _loc2_ = "Saw";
               break;
            case "Indexable End Or Face Mill":
               _loc2_ = "Indexable";
               break;
            default:
               _loc2_ = "Endmill";
         }
         return _loc2_;
      }
      
      private function setFunctionsParent() : void
      {
         if(this.setFunctionsFcn != null && !stopSetFunctionsRecursion)
         {
            stopSetFunctionsRecursion = true;
            this.setFunctionsFcn();
            stopSetFunctionsRecursion = false;
         }
      }
      
      public function setGeometry(param1:String) : void
      {
         this.toolParms.geometry = param1;
         this.setGeometryIndex(GWizToolData.geomNameToIdx(param1));
      }
      
      public function setGeometryViaRougher(param1:Boolean) : void
      {
         var _loc2_:String = GWizToolData.ROUGHER_GEO_NAME;
         if(param1)
         {
            this.setGeometry(_loc2_);
         }
         else if(this.geomButton.text == _loc2_)
         {
            this.setGeometry("Normal");
         }
      }
      
      public function setGeometryViaBallnose(param1:Boolean) : void
      {
         var _loc2_:String = this.toolParms.geometry;
         if(GWizGraphicToolMenu.twistDrillGeometry && param1)
         {
            _loc2_ = "Parabolic";
         }
         else if(GWizGraphicToolMenu.emGeometry && param1)
         {
            _loc2_ = "Ballnose";
         }
         this.setGeometry(_loc2_);
      }
      
      public function copyToolDef(param1:GWizToolDef) : void
      {
         this.saveToolParms(param1.toolParms);
         this._toolDiameter.setVal(this.toolParms.toolDiam);
         this._flutes.value = this.toolParms.flutes;
         this._stickout.setVal(this.toolParms.stickout);
         this._LeadAngle.value = this.toolParms.leadAngle;
         this.setFunctions(this.toolParms.toolType);
      }
      
      private function doGeometry() : void
      {
         if(this.popupToolMenu != null)
         {
            this.popupToolMenu();
         }
      }
      
      public function saveToolParms(param1:GWizToolData) : void
      {
         this.toolParms.toolType = param1.toolType;
         this.toolParms.geometry = param1.geometry;
         this.toolParms.toolDiam = param1.toolDiam;
         this._toolDiameter.setVal(this.toolParms.toolDiam);
         this.toolParms.flutes = param1.flutes;
         this.toolParms.leadAngle = param1.leadAngle;
         this.toolParms.stickout = param1.stickout;
         this._stickout.setVal(this.toolParms.stickout);
         this.toolParms.noseRad = param1.noseRad;
         this.toolParms.cornerRadius = param1.cornerRadius;
         this.toolParms.cornerRadius = param1.cornerRadius;
         this.toolParms.shankSize = param1.shankSize;
         this.toolParms.cutLength = param1.cutLength;
         this.toolParms.overallLength = param1.overallLength;
         this.toolParms.noCutDia = param1.noCutDia;
         var _loc2_:String = this.geometryLabel();
         if(this.recalcFcn != null)
         {
            this.recalcFcn(true);
         }
      }
      
      private function showGeometry(param1:Boolean) : void
      {
         this.geomButton.visible = param1;
      }
      
      public function geometryLabel() : String
      {
         var _loc1_:String = this.toolParms.geometry;
         if(this.geomButton)
         {
            if(GWizToolData.isNormalGeoName(_loc1_))
            {
               this.geomButton.text = "";
            }
            else
            {
               this.geomButton.text = _loc1_;
            }
         }
         if(this.ToolIcon)
         {
            this.ToolIcon.source = GWizToolTypeRenderer.toolTypeIcon(this.toolParms.toolType,_loc1_);
         }
         return _loc1_;
      }
      
      public function setGeometryParms(param1:String, param2:Boolean, param3:Number) : void
      {
         this.toolParms.setGeometryParms(param1,param2,param3);
         var _loc4_:String = this.geometryLabel();
      }
      
      public function setGeometryIndex(param1:int) : void
      {
         this.geomIndex = param1;
         this.setFunctionsParent();
         var _loc2_:String = this.geometryLabel();
      }
      
      public function getGeometryIndex() : int
      {
         return this.geomIndex;
      }
      
      private function initToolDiam() : void
      {
         this._toolDiameter.setVal(0.5);
      }
      
      private function _GWizToolDef_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Tool";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizToolDef_Array2_c);
         _loc1_.id = "_GWizToolDef_GWizForePanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolDef_GWizForePanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolDef_GWizForePanel1",this._GWizToolDef_GWizForePanel1);
         return _loc1_;
      }
      
      private function _GWizToolDef_Array2_c() : Array
      {
         return [this._GWizToolDef_HGroup2_c()];
      }
      
      private function _GWizToolDef_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "left";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolDef_Label1_i(),this._GWizToolDef_GWizNumStep1_i(),this._GWizToolDef_Button1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolDef_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "toolDiaLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolDiaLabel = _loc1_;
         BindingManager.executeBindings(this,"toolDiaLabel",this.toolDiaLabel);
         return _loc1_;
      }
      
      private function _GWizToolDef_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.stepBySizes = true;
         _loc1_.addEventListener("valueCommit",this.___toolDiameter_valueCommit);
         _loc1_.addEventListener("initialize",this.___toolDiameter_initialize);
         _loc1_.id = "_toolDiameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._toolDiameter = _loc1_;
         BindingManager.executeBindings(this,"_toolDiameter",this._toolDiameter);
         return _loc1_;
      }
      
      public function ___toolDiameter_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function ___toolDiameter_initialize(param1:FlexEvent) : void
      {
         this.initToolDiam();
      }
      
      private function _GWizToolDef_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Sizes";
         _loc1_.toolTip = "Select diameter from std drill sizes";
         _loc1_.addEventListener("click",this.__SizesBtn_click);
         _loc1_.id = "SizesBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SizesBtn = _loc1_;
         BindingManager.executeBindings(this,"SizesBtn",this.SizesBtn);
         return _loc1_;
      }
      
      public function __SizesBtn_click(param1:MouseEvent) : void
      {
         this.showDrillPicker();
      }
      
      private function _GWizToolDef_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizToolDef_Array4_c);
         _loc1_.id = "_GWizToolDef_GWizForePanel2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolDef_GWizForePanel2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolDef_GWizForePanel2",this._GWizToolDef_GWizForePanel2);
         return _loc1_;
      }
      
      private function _GWizToolDef_Array4_c() : Array
      {
         return [this._GWizToolDef_HGroup3_c()];
      }
      
      private function _GWizToolDef_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "left";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolDef_Label2_i(),this._GWizToolDef_NumericStepper1_i(),this._GWizToolDef_Label3_i(),this._GWizToolDef_Label4_i(),this._GWizToolDef_Image1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolDef_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Flutes";
         _loc1_.id = "FlutesLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FlutesLabel = _loc1_;
         BindingManager.executeBindings(this,"FlutesLabel",this.FlutesLabel);
         return _loc1_;
      }
      
      private function _GWizToolDef_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.value = 2;
         _loc1_.minimum = 1;
         _loc1_.stepSize = 1;
         _loc1_.maximum = 200;
         _loc1_.width = 50;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.___flutes_valueCommit);
         _loc1_.id = "_flutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._flutes = _loc1_;
         BindingManager.executeBindings(this,"_flutes",this._flutes);
         return _loc1_;
      }
      
      public function ___flutes_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizToolDef_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 170;
         _loc1_.id = "geomButton";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.geomButton = _loc1_;
         BindingManager.executeBindings(this,"geomButton",this.geomButton);
         return _loc1_;
      }
      
      private function _GWizToolDef_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.id = "coatingLbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.coatingLbl = _loc1_;
         BindingManager.executeBindings(this,"coatingLbl",this.coatingLbl);
         return _loc1_;
      }
      
      private function _GWizToolDef_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.id = "ToolIcon";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolIcon = _loc1_;
         BindingManager.executeBindings(this,"ToolIcon",this.ToolIcon);
         return _loc1_;
      }
      
      private function _GWizToolDef_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizToolDef_Array6_c);
         _loc1_.id = "_GWizToolDef_GWizForePanel3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolDef_GWizForePanel3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolDef_GWizForePanel3",this._GWizToolDef_GWizForePanel3);
         return _loc1_;
      }
      
      private function _GWizToolDef_Array6_c() : Array
      {
         return [this._GWizToolDef_HGroup4_i()];
      }
      
      private function _GWizToolDef_HGroup4_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "left";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolDef_GWizNumStep2_i(),this._GWizToolDef_GWizOptimizeBtn1_i(),this._GWizToolDef_GWizNumStep3_i(),this._GWizToolDef_Button2_i()];
         _loc1_.id = "geomGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.geomGroup = _loc1_;
         BindingManager.executeBindings(this,"geomGroup",this.geomGroup);
         return _loc1_;
      }
      
      private function _GWizToolDef_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Stickout";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Distance from tool holder to tool tip.";
         _loc1_.UnitLabel = "in";
         _loc1_.addEventListener("valueCommit",this.___stickout_valueCommit);
         _loc1_.addEventListener("initialize",this.___stickout_initialize);
         _loc1_.id = "_stickout";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._stickout = _loc1_;
         BindingManager.executeBindings(this,"_stickout",this._stickout);
         return _loc1_;
      }
      
      public function ___stickout_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function ___stickout_initialize(param1:FlexEvent) : void
      {
         this._stickout.setVal(1);
      }
      
      private function _GWizToolDef_GWizOptimizeBtn1_i() : GWizOptimizeBtn
      {
         var _loc1_:GWizOptimizeBtn = new GWizOptimizeBtn();
         _loc1_.mode = "stick";
         _loc1_.logContext = "Feeds/Speeds/OptimizeStickout";
         _loc1_.visible = false;
         _loc1_.toolTip = "Optimize stickout to fix deflection warnings.";
         _loc1_.id = "optStick";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.optStick = _loc1_;
         BindingManager.executeBindings(this,"optStick",this.optStick);
         return _loc1_;
      }
      
      private function _GWizToolDef_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Lead Ang.";
         _loc1_.numStepWidth = 50;
         _loc1_.value = 90;
         _loc1_.min = 0;
         _loc1_.max = 90;
         _loc1_.steps = 1;
         _loc1_.toolTip = "Lead angle for indexable tooling";
         _loc1_.usesMetric = false;
         _loc1_.visible = false;
         _loc1_.addEventListener("valueCommit",this.___LeadAngle_valueCommit);
         _loc1_.id = "_LeadAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._LeadAngle = _loc1_;
         BindingManager.executeBindings(this,"_LeadAngle",this._LeadAngle);
         return _loc1_;
      }
      
      public function ___LeadAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizToolDef_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "To Crib";
         _loc1_.toolTip = "Add the currently defined tool to the Tool Crib. Popup will ask which table.";
         _loc1_.addEventListener("click",this.__toCrib_click);
         _loc1_.id = "toCrib";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toCrib = _loc1_;
         BindingManager.executeBindings(this,"toCrib",this.toCrib);
         return _loc1_;
      }
      
      public function __toCrib_click(param1:MouseEvent) : void
      {
         GWizSettings.theCrib.toCrib();
      }
      
      public function ___GWizToolDef_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizToolDef_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"_GWizToolDef_GWizForePanel1.width","firstColWd");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizToolDef_GWizForePanel1.labelBackgroundColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizToolDef_GWizForePanel1.labelColor");
         result[3] = new Binding(this,function():int
         {
            return this.labelWidth;
         },null,"_GWizToolDef_GWizForePanel1.labelWidth");
         result[4] = new Binding(this,function():int
         {
            return this.gapSize;
         },null,"_GWizToolDef_GWizForePanel1.gapSize");
         result[5] = new Binding(this,function():String
         {
            var _loc1_:* = TOOL_DIAM;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"toolDiaLabel.text");
         result[6] = new Binding(this,function():Boolean
         {
            return !_lockForToolCrib || GWizCribToolEditor.ignoreLockForToolCrib;
         },null,"_toolDiameter.enabled");
         result[7] = new Binding(this,function():Boolean
         {
            return !_lockForToolCrib || GWizCribToolEditor.ignoreLockForToolCrib;
         },null,"SizesBtn.enabled");
         result[8] = new Binding(this,function():Boolean
         {
            return SizesBtn.enabled;
         },null,"SizesBtn.visible");
         result[9] = new Binding(this,null,null,"_GWizToolDef_GWizForePanel2.width","secondColWd");
         result[10] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizToolDef_GWizForePanel2.labelBackgroundColor");
         result[11] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizToolDef_GWizForePanel2.labelColor");
         result[12] = new Binding(this,function():int
         {
            return this.labelWidth;
         },null,"_GWizToolDef_GWizForePanel2.labelWidth");
         result[13] = new Binding(this,function():int
         {
            return this.gapSize;
         },null,"_GWizToolDef_GWizForePanel2.gapSize");
         result[14] = new Binding(this,function():Boolean
         {
            return !_lockForToolCrib || GWizCribToolEditor.ignoreLockForToolCrib;
         },null,"_flutes.enabled");
         result[15] = new Binding(this,null,null,"_GWizToolDef_GWizForePanel3.width","thirdColWd");
         result[16] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizToolDef_GWizForePanel3.labelBackgroundColor");
         result[17] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizToolDef_GWizForePanel3.labelColor");
         result[18] = new Binding(this,function():int
         {
            return this.labelWidth;
         },null,"_GWizToolDef_GWizForePanel3.labelWidth");
         result[19] = new Binding(this,function():int
         {
            return this.gapSize;
         },null,"_GWizToolDef_GWizForePanel3.gapSize");
         result[20] = new Binding(this,function():Boolean
         {
            return optStick.visible;
         },null,"optStick.includeInLayout");
         result[21] = new Binding(this,function():Boolean
         {
            return !_lockForToolCrib || GWizCribToolEditor.ignoreLockForToolCrib;
         },null,"_LeadAngle.enabled");
         result[22] = new Binding(this,function():Boolean
         {
            return !(_lockForToolCrib || (hideToCrib || GWizAbstractPrefs.isOEM));
         },null,"toCrib.visible");
         result[23] = new Binding(this,function():Boolean
         {
            return toCrib.visible;
         },null,"toCrib.includeInLayout");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get FlutesLabel() : Label
      {
         return this._1111681345FlutesLabel;
      }
      
      public function set FlutesLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1111681345FlutesLabel;
         if(_loc2_ !== param1)
         {
            this._1111681345FlutesLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FlutesLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SizesBtn() : Button
      {
         return this._912500874SizesBtn;
      }
      
      public function set SizesBtn(param1:Button) : void
      {
         var _loc2_:Object = this._912500874SizesBtn;
         if(_loc2_ !== param1)
         {
            this._912500874SizesBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SizesBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolIcon() : Image
      {
         return this._919276975ToolIcon;
      }
      
      public function set ToolIcon(param1:Image) : void
      {
         var _loc2_:Object = this._919276975ToolIcon;
         if(_loc2_ !== param1)
         {
            this._919276975ToolIcon = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolIcon",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _LeadAngle() : GWizNumStep
      {
         return this._1628519736_LeadAngle;
      }
      
      public function set _LeadAngle(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1628519736_LeadAngle;
         if(_loc2_ !== param1)
         {
            this._1628519736_LeadAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_LeadAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _flutes() : NumericStepper
      {
         return this._1437017714_flutes;
      }
      
      public function set _flutes(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1437017714_flutes;
         if(_loc2_ !== param1)
         {
            this._1437017714_flutes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_flutes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _stickout() : GWizNumStep
      {
         return this._1622242845_stickout;
      }
      
      public function set _stickout(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1622242845_stickout;
         if(_loc2_ !== param1)
         {
            this._1622242845_stickout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_stickout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _toolDiameter() : GWizNumStep
      {
         return this._51203036_toolDiameter;
      }
      
      public function set _toolDiameter(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._51203036_toolDiameter;
         if(_loc2_ !== param1)
         {
            this._51203036_toolDiameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_toolDiameter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get coatingLbl() : Label
      {
         return this._803034925coatingLbl;
      }
      
      public function set coatingLbl(param1:Label) : void
      {
         var _loc2_:Object = this._803034925coatingLbl;
         if(_loc2_ !== param1)
         {
            this._803034925coatingLbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"coatingLbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get geomButton() : Label
      {
         return this._797109874geomButton;
      }
      
      public function set geomButton(param1:Label) : void
      {
         var _loc2_:Object = this._797109874geomButton;
         if(_loc2_ !== param1)
         {
            this._797109874geomButton = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"geomButton",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get geomGroup() : HGroup
      {
         return this._1364283555geomGroup;
      }
      
      public function set geomGroup(param1:HGroup) : void
      {
         var _loc2_:Object = this._1364283555geomGroup;
         if(_loc2_ !== param1)
         {
            this._1364283555geomGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"geomGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get optStick() : GWizOptimizeBtn
      {
         return this._99190371optStick;
      }
      
      public function set optStick(param1:GWizOptimizeBtn) : void
      {
         var _loc2_:Object = this._99190371optStick;
         if(_loc2_ !== param1)
         {
            this._99190371optStick = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"optStick",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toCrib() : Button
      {
         return this._869366045toCrib;
      }
      
      public function set toCrib(param1:Button) : void
      {
         var _loc2_:Object = this._869366045toCrib;
         if(_loc2_ !== param1)
         {
            this._869366045toCrib = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toCrib",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolDiaLabel() : Label
      {
         return this._2021666192toolDiaLabel;
      }
      
      public function set toolDiaLabel(param1:Label) : void
      {
         var _loc2_:Object = this._2021666192toolDiaLabel;
         if(_loc2_ !== param1)
         {
            this._2021666192toolDiaLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolDiaLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hideToCrib() : Boolean
      {
         return this._373675717hideToCrib;
      }
      
      public function set hideToCrib(param1:Boolean) : void
      {
         var _loc2_:Object = this._373675717hideToCrib;
         if(_loc2_ !== param1)
         {
            this._373675717hideToCrib = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hideToCrib",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelWidth() : int
      {
         return this._1657211086labelWidth;
      }
      
      public function set labelWidth(param1:int) : void
      {
         var _loc2_:Object = this._1657211086labelWidth;
         if(_loc2_ !== param1)
         {
            this._1657211086labelWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gapSize() : int
      {
         return this._193361929gapSize;
      }
      
      public function set gapSize(param1:int) : void
      {
         var _loc2_:Object = this._193361929gapSize;
         if(_loc2_ !== param1)
         {
            this._193361929gapSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gapSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hideLabel() : Boolean
      {
         return this._835562194hideLabel;
      }
      
      public function set hideLabel(param1:Boolean) : void
      {
         var _loc2_:Object = this._835562194hideLabel;
         if(_loc2_ !== param1)
         {
            this._835562194hideLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hideLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get firstColWd() : int
      {
         return this._186804323firstColWd;
      }
      
      public function set firstColWd(param1:int) : void
      {
         var _loc2_:Object = this._186804323firstColWd;
         if(_loc2_ !== param1)
         {
            this._186804323firstColWd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"firstColWd",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get secondColWd() : int
      {
         return this._239444057secondColWd;
      }
      
      public function set secondColWd(param1:int) : void
      {
         var _loc2_:Object = this._239444057secondColWd;
         if(_loc2_ !== param1)
         {
            this._239444057secondColWd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"secondColWd",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get thirdColWd() : int
      {
         return this._981532858thirdColWd;
      }
      
      public function set thirdColWd(param1:int) : void
      {
         var _loc2_:Object = this._981532858thirdColWd;
         if(_loc2_ !== param1)
         {
            this._981532858thirdColWd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"thirdColWd",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get optStickFcn() : Function
      {
         return this._42772364optStickFcn;
      }
      
      public function set optStickFcn(param1:Function) : void
      {
         var _loc2_:Object = this._42772364optStickFcn;
         if(_loc2_ !== param1)
         {
            this._42772364optStickFcn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"optStickFcn",_loc2_,param1));
            }
         }
      }
   }
}
