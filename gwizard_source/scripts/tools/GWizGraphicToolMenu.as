package tools
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizPopUpManager;
   import flash.display.DisplayObject;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.containers.VBox;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColor;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.DropDownList;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.List;
   import spark.components.NumericStepper;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import spark.primitives.Rect;
   import utils.GATracker;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizGraphicToolMenu extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizGraphicToolMenu");
      
      private static var _2109373890toolMaterialDataOld:ArrayCollection = new ArrayCollection([{"label":"HSS"},{"label":"HP HSS"},{"label":"Cobalt"},{"label":"Carbide"},{"label":"HP Carbide"},{"label":"TiAlN Carbide"},{"label":"PCD/CVD (Diamond)"}]);
      
      private static const BALLNOSE:String = "Ballnose";
      
      private static const LOLLIPOP:String = "Lollipop";
      
      private static const CHAMFER:String = "Chamfer / Countersink";
      
      private static const CORNER_ROUND:String = "Corner Round";
      
      private static const DOVETAIL:String = "Dovetail";
      
      private static const ENDMILL:String = "Endmill";
      
      private static const VBIT:String = "V-Bit";
      
      private static const BORING:String = "Boring";
      
      private static const WOODRUFF_SAW:String = "Saws & Woodruff Cutters";
      
      private static const EndMillConsts:Object = {
         "ToolholderX":30,
         "ToolholderY":203,
         "BottomX":30,
         "BottomY":218,
         "StickoutX":50,
         "StickoutY":350,
         "ShankX":190,
         "ShankY":170,
         "CutLenVisible":true,
         "CutLenX":350,
         "CutLenY":347,
         "OverallLenVisible":true,
         "OverallLenX":430,
         "OverallLenY":395,
         "LeadAngleX":14,
         "LeadAngleY":510,
         "CornerRadVisible":true,
         "CornerRadX":395,
         "CornerRadY":508,
         "CutDiaX":190,
         "CutDiaY":510,
         "SizesX":190,
         "SizesY":553,
         "NoCutDiaVisible":false,
         "NoCutDiaX":306,
         "NoCutDiaY":527.5,
         "LeadAngleMax":90,
         "LeadAngleVisible":true,
         "HelixAngleVisible":true,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      private static const FaceMillConsts:Object = {
         "ToolholderX":500,
         "ToolholderY":15,
         "BottomX":500,
         "BottomY":30,
         "StickoutX":30,
         "StickoutY":85,
         "ShankX":223,
         "ShankY":20,
         "CutLenVisible":true,
         "CutLenX":500,
         "CutLenY":260,
         "OverallLenVisible":true,
         "OverallLenX":450,
         "OverallLenY":92,
         "LeadAngleX":14,
         "LeadAngleY":315,
         "CornerRadVisible":true,
         "CornerRadX":500,
         "CornerRadY":310,
         "CutDiaX":230,
         "CutDiaY":313,
         "SizesX":230,
         "SizesY":363,
         "NoCutDiaVisible":false,
         "NoCutDiaX":306,
         "NoCutDiaY":527.5,
         "LeadAngleMax":90,
         "LeadAngleVisible":true,
         "HelixAngleVisible":false,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      private static const TwistDrillConsts:Object = {
         "ToolholderX":30,
         "ToolholderY":203,
         "BottomX":30,
         "BottomY":218,
         "StickoutX":50,
         "StickoutY":350,
         "ShankX":190,
         "ShankY":170,
         "CutLenVisible":true,
         "CutLenX":350,
         "CutLenY":347,
         "OverallLenVisible":true,
         "OverallLenX":430,
         "OverallLenY":395,
         "LeadAngleX":14,
         "LeadAngleY":510,
         "CornerRadVisible":false,
         "CornerRadX":395,
         "CornerRadY":508,
         "CutDiaX":190,
         "CutDiaY":510,
         "SizesX":190,
         "SizesY":553,
         "NoCutDiaVisible":false,
         "NoCutDiaX":306,
         "NoCutDiaY":527.5,
         "LeadAngleMax":90,
         "LeadAngleVisible":false,
         "HelixAngleVisible":false,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      private static const DoveTailConsts:Object = {
         "ToolholderX":30,
         "ToolholderY":203,
         "BottomX":30,
         "BottomY":264,
         "StickoutX":45,
         "StickoutY":350,
         "ShankX":190,
         "ShankY":170,
         "CutLenVisible":true,
         "CutLenX":320,
         "CutLenY":390,
         "OverallLenVisible":true,
         "OverallLenX":430,
         "OverallLenY":395,
         "LeadAngleX":65,
         "LeadAngleY":505,
         "CornerRadVisible":false,
         "CornerRadX":353,
         "CornerRadY":520,
         "CutDiaX":190,
         "CutDiaY":510,
         "SizesX":190,
         "SizesY":553,
         "NoCutDiaVisible":false,
         "NoCutDiaX":306,
         "NoCutDiaY":527.5,
         "LeadAngleMax":180,
         "LeadAngleVisible":true,
         "HelixAngleVisible":false,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      private static const VBitConsts:Object = {
         "ToolholderX":28,
         "ToolholderY":219,
         "BottomX":28,
         "BottomY":234,
         "StickoutX":50,
         "StickoutY":350,
         "ShankX":190,
         "ShankY":170,
         "CutLenVisible":true,
         "CutLenX":330,
         "CutLenY":420,
         "OverallLenVisible":true,
         "OverallLenX":430,
         "OverallLenY":390,
         "LeadAngleX":80,
         "LeadAngleY":510,
         "CornerRadVisible":false,
         "CornerRadX":353,
         "CornerRadY":520,
         "CutDiaX":190,
         "CutDiaY":510,
         "SizesX":190,
         "SizesY":553,
         "NoCutDiaVisible":true,
         "NoCutDiaX":305,
         "NoCutDiaY":506,
         "LeadAngleMax":180,
         "LeadAngleVisible":true,
         "HelixAngleVisible":false,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      private static const ChamferConsts:Object = {
         "ToolholderX":28,
         "ToolholderY":219,
         "BottomX":28,
         "BottomY":234,
         "StickoutX":50,
         "StickoutY":350,
         "ShankX":190,
         "ShankY":170,
         "CutLenVisible":true,
         "CutLenX":330,
         "CutLenY":440,
         "OverallLenVisible":true,
         "OverallLenX":430,
         "OverallLenY":390,
         "LeadAngleX":80,
         "LeadAngleY":510,
         "CornerRadVisible":false,
         "CornerRadX":353,
         "CornerRadY":520,
         "CutDiaX":190,
         "CutDiaY":510,
         "SizesX":190,
         "SizesY":553,
         "NoCutDiaVisible":false,
         "NoCutDiaX":305,
         "NoCutDiaY":506,
         "LeadAngleMax":180,
         "LeadAngleVisible":true,
         "HelixAngleVisible":false,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      private static const SpotReamConsts:Object = {
         "ToolholderX":28,
         "ToolholderY":219,
         "BottomX":28,
         "BottomY":234,
         "StickoutX":50,
         "StickoutY":350,
         "ShankX":190,
         "ShankY":170,
         "CutLenVisible":true,
         "CutLenX":330,
         "CutLenY":440,
         "OverallLenVisible":true,
         "OverallLenX":430,
         "OverallLenY":390,
         "LeadAngleX":80,
         "LeadAngleY":510,
         "CornerRadVisible":false,
         "CornerRadX":353,
         "CornerRadY":520,
         "CutDiaX":190,
         "CutDiaY":550,
         "NoCutDiaVisible":false,
         "NoCutDiaX":305,
         "NoCutDiaY":506,
         "LeadAngleMax":180,
         "LeadAngleVisible":false,
         "HelixAngleVisible":false,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      private static const BoringHeadConsts:Object = {
         "ToolholderX":28,
         "ToolholderY":219,
         "BottomX":28,
         "BottomY":234,
         "StickoutX":50,
         "StickoutY":350,
         "ShankX":190,
         "ShankY":170,
         "CutLenVisible":false,
         "CutLenX":330,
         "CutLenY":440,
         "OverallLenVisible":false,
         "OverallLenX":430,
         "OverallLenY":390,
         "LeadAngleX":80,
         "LeadAngleY":510,
         "CornerRadVisible":false,
         "CornerRadX":353,
         "CornerRadY":520,
         "CutDiaX":190,
         "CutDiaY":550,
         "NoCutDiaVisible":false,
         "NoCutDiaX":305,
         "NoCutDiaY":506,
         "LeadAngleMax":180,
         "LeadAngleVisible":false,
         "HelixAngleVisible":false,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      private static const BallNoseConsts:Object = {
         "ToolholderX":30,
         "ToolholderY":203,
         "BottomX":30,
         "BottomY":218,
         "StickoutX":50,
         "StickoutY":350,
         "ShankX":190,
         "ShankY":170,
         "CutLenVisible":true,
         "CutLenX":350,
         "CutLenY":347,
         "OverallLenVisible":true,
         "OverallLenX":430,
         "OverallLenY":395,
         "LeadAngleX":14,
         "LeadAngleY":510,
         "CornerRadVisible":false,
         "CornerRadX":395,
         "CornerRadY":508,
         "CutDiaX":190,
         "CutDiaY":510,
         "SizesX":190,
         "SizesY":553,
         "NoCutDiaVisible":false,
         "NoCutDiaX":306,
         "NoCutDiaY":527.5,
         "LeadAngleMax":90,
         "LeadAngleVisible":true,
         "HelixAngleVisible":true,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      private static const LollipopConsts:Object = {
         "ToolholderX":30,
         "ToolholderY":203,
         "BottomX":30,
         "BottomY":218,
         "StickoutX":50,
         "StickoutY":350,
         "ShankX":190,
         "ShankY":170,
         "CutLenVisible":true,
         "CutLenX":350,
         "CutLenY":347,
         "OverallLenVisible":true,
         "OverallLenX":430,
         "OverallLenY":395,
         "LeadAngleX":14,
         "LeadAngleY":510,
         "CornerRadVisible":false,
         "CornerRadX":395,
         "CornerRadY":508,
         "CutDiaX":190,
         "CutDiaY":510,
         "SizesX":190,
         "SizesY":553,
         "NoCutDiaVisible":false,
         "NoCutDiaX":306,
         "NoCutDiaY":527.5,
         "LeadAngleMax":90,
         "LeadAngleVisible":true,
         "HelixAngleVisible":false,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      private static const ProbeConsts:Object = {
         "ToolholderX":30,
         "ToolholderY":203,
         "BottomX":30,
         "BottomY":218,
         "StickoutX":50,
         "StickoutY":350,
         "ShankX":190,
         "ShankY":170,
         "CutLenVisible":false,
         "CutLenX":350,
         "CutLenY":347,
         "OverallLenVisible":false,
         "OverallLenX":430,
         "OverallLenY":395,
         "LeadAngleX":14,
         "LeadAngleY":510,
         "CornerRadVisible":false,
         "CornerRadX":395,
         "CornerRadY":508,
         "CutDiaX":190,
         "CutDiaY":510,
         "SizesX":190,
         "SizesY":553,
         "NoCutDiaVisible":false,
         "NoCutDiaX":306,
         "NoCutDiaY":527.5,
         "LeadAngleMax":90,
         "LeadAngleVisible":false,
         "HelixAngleVisible":false,
         "HelixAngleX":350,
         "HelixAngleY":170
      };
      
      public static var twistDrillGeometry:Boolean = false;
      
      public static var emGeometry:Boolean = false;
      
      public static var tapGeometry:Boolean = false;
      
      public static var turningGeometry:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1690785341Coating:DropDownList;
      
      private var _680218976CornerRad:GWizNumStep;
      
      private var _1984263141CuttingLen:GWizNumStep;
      
      private var _1111681345FlutesLabel:Label;
      
      private var _1910664338Geometry:GWizGeometryCombo;
      
      private var _1985877227HelixAngle:GWizNumStep;
      
      private var _1177533769LeadAngle:GWizNumStep;
      
      private var _363710791Material:DropDownList;
      
      private var _264475992OverallLen:GWizNumStep;
      
      private var _312927978ShankSize:GWizNumStep;
      
      private var _79900786Sizes:Button;
      
      private var _1596369118Stickout:GWizNumStep;
      
      private var _524530596ToolDia:GWizNumStep;
      
      public var _GWizGraphicToolMenu_Label1:Label;
      
      public var _GWizGraphicToolMenu_Label2:Label;
      
      private var _1437017714_flutes:NumericStepper;
      
      private var _1855390651bottomTxt:Label;
      
      private var _803039230coatingGrp:HGroup;
      
      private var _549910507firstGrp:VGroup;
      
      private var _1718295567leftPane:HGroup;
      
      private var _1081280667matGrp:HGroup;
      
      private var _956920212toolHolderTxt:Label;
      
      private var _436498781toolImage:Image;
      
      private var _983825834toolList:List;
      
      private var _983528355toolView:Group;
      
      private var _67441166vbitNoCutDia:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var td:GWizToolDef;
      
      private var toolParms:GWizToolData;
      
      public var saveToolParmsFcn:Function = null;
      
      private var resetTitleAux:Function;
      
      private var cribIdx:int = 0;
      
      public var setFunctions:Function = null;
      
      private var _664319200toolListData:ArrayCollection;
      
      private const EndMillImage:Class = GWizGraphicToolMenu_EndMillImage;
      
      private const RougherImage:Class = GWizGraphicToolMenu_RougherImage;
      
      private const FacemillImage:Class = GWizGraphicToolMenu_FacemillImage;
      
      private const TwistDrillImage:Class = GWizGraphicToolMenu_TwistDrillImage;
      
      private const DoveTailImage:Class = GWizGraphicToolMenu_DoveTailImage;
      
      private const WoodruffImage:Class = GWizGraphicToolMenu_WoodruffImage;
      
      private const IndexableDrillImage:Class = GWizGraphicToolMenu_IndexableDrillImage;
      
      private const GunDrillImage:Class = GWizGraphicToolMenu_GunDrillImage;
      
      private const VBitImage:Class = GWizGraphicToolMenu_VBitImage;
      
      private const ChamferImage:Class = GWizGraphicToolMenu_ChamferImage;
      
      private const CenterDrillImage:Class = GWizGraphicToolMenu_CenterDrillImage;
      
      private const SpotDrillImage:Class = GWizGraphicToolMenu_SpotDrillImage;
      
      private const ReamerImage:Class = GWizGraphicToolMenu_ReamerImage;
      
      private const SpadeDrillImage:Class = GWizGraphicToolMenu_SpadeDrillImage;
      
      private const CornerRoundImage:Class = GWizGraphicToolMenu_CornerRoundImage;
      
      private const BoringHeadImage:Class = GWizGraphicToolMenu_BoringHeadImage;
      
      private const TappingImage:Class = GWizGraphicToolMenu_TappingImage;
      
      private const ThreadMillImage:Class = GWizGraphicToolMenu_ThreadMillImage;
      
      private const BallNoseImage:Class = GWizGraphicToolMenu_BallNoseImage;
      
      private const LollipopImage:Class = GWizGraphicToolMenu_LollipopImage;
      
      private const ProbeImage:Class = GWizGraphicToolMenu_ProbeImage;
      
      private const TurningImage:Class = GWizGraphicToolMenu_TurningImage;
      
      private const BoringBarImage:Class = GWizGraphicToolMenu_BoringBarImage;
      
      private const PartingImage:Class = GWizGraphicToolMenu_PartingImage;
      
      private const ThreadingImage:Class = GWizGraphicToolMenu_ThreadingImage;
      
      private const OtherImage:Class = GWizGraphicToolMenu_OtherImage;
      
      private const EmptyToolholderImage:Class = GWizGraphicToolMenu_EmptyToolholderImage;
      
      private var lastGeometrySet:int = -1;
      
      private var _994048655showGeometry:Boolean = false;
      
      private var lastToolSelected:int = -1;
      
      private var pickerEM:Boolean = true;
      
      private var titleStr:String = "";
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizGraphicToolMenu()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._664319200toolListData = new ArrayCollection();
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizGraphicToolMenu_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizGraphicToolMenuWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizGraphicToolMenu[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.mxmlContent = [this._GWizGraphicToolMenu_VBox1_c()];
         this.addEventListener("click",this.___GWizGraphicToolMenu_VGroup1_click);
         this.addEventListener("keyDown",this.___GWizGraphicToolMenu_VGroup1_keyDown);
         this.addEventListener("creationComplete",this.___GWizGraphicToolMenu_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function toolDescStr(param1:String, param2:String, param3:String) : String
      {
         var _loc5_:Boolean = false;
         var _loc4_:String = param1;
         if(!GWizToolData.isNonCuttingTool(_loc4_))
         {
            _loc5_ = false;
            if(param1 == "Thread Mill")
            {
               param2 = "Carbide";
            }
            switch(param2)
            {
               case "Cobalt":
                  if(isTwistDrill(param1))
                  {
                     _loc4_ = "Cobalt " + _loc4_;
                  }
                  else
                  {
                     if(isEndmill(param1))
                     {
                        _loc5_ = true;
                     }
                     if(_loc4_.search("HSS") < 0 && !noHSSOption(param1))
                     {
                        _loc4_ = "HSS " + _loc4_;
                     }
                  }
                  break;
               case "HSS":
                  if(!noHSSOption(param1))
                  {
                     _loc4_ = "HSS " + _loc4_;
                  }
                  break;
               case "Carbide":
                  if(param1 != "Gun Drill")
                  {
                     _loc4_ = "Carbide " + _loc4_;
                  }
                  break;
               default:
                  GWizUtils.assert(false);
            }
            switch(param3)
            {
               case "Uncoated":
                  break;
               case "TiN":
               case "TiCN":
               case "ZrN":
               case "TiB2 (Alumastar)":
                  _loc5_ = true;
                  break;
               case "TiAlN (incl. Spektra, nACo)":
               case "AlTiN":
               case "AlTiN Based":
               case "AlCrN":
               case "AlCrN Based":
                  _loc5_ = false;
                  if(param2 == "Carbide")
                  {
                     _loc4_ = "TiAlN " + _loc4_;
                  }
                  else
                  {
                     _loc5_ = true;
                  }
            }
            if(_loc5_ && (isEndmill(param1) || isTwistDrill(param1)))
            {
               _loc4_ = "HP " + _loc4_;
            }
         }
         return _loc4_;
      }
      
      private static function isEndmill(param1:String) : Boolean
      {
         return param1.toLowerCase().indexOf("endmill") >= 0;
      }
      
      private static function isTwistDrill(param1:String) : Boolean
      {
         return param1.toLowerCase().indexOf("twist") >= 0;
      }
      
      private static function noHSSOption(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if(param1.toLowerCase().indexOf("indexable") >= 0)
         {
            _loc2_ = true;
         }
         else
         {
            switch(param1)
            {
               case "Gun Drill":
                  _loc2_ = true;
                  break;
               case "Thread Mill":
                  _loc2_ = true;
                  break;
               default:
                  _loc2_ = false;
            }
         }
         return _loc2_;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizGraphicToolMenu._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get toolMaterialDataOld() : ArrayCollection
      {
         return GWizGraphicToolMenu._2109373890toolMaterialDataOld;
      }
      
      private static function set toolMaterialDataOld(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizGraphicToolMenu._2109373890toolMaterialDataOld;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizGraphicToolMenu,"toolMaterialDataOld",_loc2_,param1));
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
      
      private function onCC() : void
      {
         log.debug("Creation Completed!");
      }
      
      public function setToolParms(param1:GWizToolDef, param2:XMLList, param3:int, param4:int, param5:Function) : void
      {
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:String = null;
         this.resetTitleAux = param5;
         if(param3 > 0)
         {
            GATracker.logPageView("Feeds/Speeds/CribTool","Feeds/Speeds/CribTool");
         }
         else
         {
            GATracker.logPageView("Feeds/Speeds/GenericTool","Feeds/Speeds/GenericTool");
         }
         this.cribIdx = param3;
         this.td = param1;
         this.buildToolList(param2);
         var _loc6_:GWizToolData = param1.toolParms;
         this.toolParms = new GWizToolData();
         this.toolParms.geometry = _loc6_.geometry;
         this.toolParms.toolType = _loc6_.toolType;
         this.toolParms.toolDiam = _loc6_.toolDiam;
         this.toolParms.flutes = _loc6_.flutes;
         this.toolParms.leadAngle = _loc6_.leadAngle;
         this.toolParms.helixAngle = _loc6_.helixAngle;
         this.toolParms.stickout = _loc6_.stickout;
         this.toolParms.cornerRadius = _loc6_.cornerRadius;
         this.toolParms.shankSize = _loc6_.shankSize;
         this.toolParms.cutLength = _loc6_.cutLength;
         this.toolParms.overallLength = _loc6_.overallLength;
         this.toolParms.noCutDia = _loc6_.noCutDia;
         if(param3 > 0 && param4 >= 0 && !GWizCribToolEditor.ignoreLockForToolCrib)
         {
            this.toolList.selectedIndex = param4;
         }
         else
         {
            _loc8_ = GWizToolMenu.toPrimitiveLabel(this.toolParms.toolType);
            if(GWizToolData.isTurningTool(this.toolParms.toolType))
            {
               _loc8_ = "Turning";
            }
            _loc8_ = _loc8_.toLowerCase();
            _loc9_ = 0;
            while(_loc9_ < this.toolListData.length)
            {
               _loc10_ = this.toolListData.getItemAt(_loc9_).label;
               if(_loc8_.indexOf(_loc10_.toLowerCase()) >= 0)
               {
                  if(this.toolList.selectedIndex != _loc9_)
                  {
                     this.toolList.selectedIndex = _loc9_;
                     this.doToolListVC();
                  }
                  break;
               }
               _loc9_++;
            }
         }
         var _loc7_:int = 0;
         while(_loc7_ < GWizToolData.geometryTypes.length)
         {
            _loc11_ = GWizToolData.geometryTypes.getItemAt(_loc7_).label;
            if(this.toolParms.geometry.indexOf(_loc11_) >= 0)
            {
               this.Geometry.selectedIndex = _loc7_;
               break;
            }
            _loc7_++;
         }
         if(this.Geometry.selectedIndex < 0)
         {
            this.Geometry.selectedIndex = 0;
         }
         this.ToolDia.setVal(this.toolParms.toolDiam);
         this.LeadAngle.setVal(this.toolParms.leadAngle);
         this.HelixAngle.setVal(this.toolParms.helixAngle);
         this.Stickout.setVal(this.toolParms.stickout);
         this.CornerRad.setVal(this.toolParms.cornerRadius);
         this.ShankSize.setVal(this.toolParms.shankSize);
         this.CuttingLen.setVal(this.toolParms.cutLength);
         this.OverallLen.setVal(this.toolParms.overallLength);
         this.vbitNoCutDia.setVal(this.toolParms.noCutDia);
         this.Coating.selectedIndex = _loc6_.coatingMenuIdx();
         this.toolParms.toolmaterial = _loc6_.toolmaterial;
         this.Material.selectedIndex = _loc6_.toolMaterialMenuIdx();
         this.Material.validateNow();
         this.onAnyChange(false);
      }
      
      public function close() : void
      {
         var _loc2_:String = null;
         var _loc1_:GWizToolData = new GWizToolData();
         _loc1_.toolType = this.titleStr;
         _loc1_.flutes = this._flutes.value;
         _loc1_.toolDiam = this.ToolDia.getVal();
         _loc1_.stickout = this.Stickout.getVal();
         if(this.Geometry.selectedIndex < 0)
         {
            this.Geometry.selectedIndex = 0;
         }
         if(this.Geometry && this.Geometry.selectedItem)
         {
            _loc1_.setGeometryParms(this.Geometry.selectedItem.label,this.ShankSize.getVal() != this.ToolDia.getVal(),this.ShankSize.getVal());
         }
         else
         {
            _loc1_.setGeometryParms("",false,this.ShankSize.getVal());
         }
         _loc1_.toolType = this.outboundToolType(_loc1_.toolType,_loc1_.geometry);
         _loc1_.leadAngle = this.LeadAngle.getVal();
         _loc1_.helixAngle = this.HelixAngle.getVal();
         _loc1_.cornerRadius = this.CornerRad.getVal();
         _loc1_.shankSize = this.ShankSize.getVal();
         _loc1_.cutLength = this.CuttingLen.getVal();
         _loc1_.overallLength = this.OverallLen.getVal();
         _loc1_.noCutDia = this.vbitNoCutDia.getVal();
         if(this.Coating.selectedIndex >= 0)
         {
            this.toolParms.coating = this.Coating.selectedItem.label;
         }
         if(this.Material.selectedIndex >= 0)
         {
            _loc2_ = this.Material.selectedItem.label;
            if(_loc2_ == "Cobalt")
            {
               if(!_loc1_.isTwistDrill())
               {
                  _loc2_ = "HSS";
               }
            }
            this.toolParms.toolmaterial = _loc2_;
         }
         _loc1_.coating = this.toolParms.coating;
         _loc1_.toolmaterial = this.toolParms.toolmaterial;
         GATracker.logPageView("Feeds/Speeds/ToolType/" + _loc1_.toolType,"Feeds/Speeds/ToolType/" + _loc1_.toolType);
         GATracker.logPageView("Feeds/Speeds/ToolGeometry/" + _loc1_.geometry,"Feeds/Speeds/ToolGeometry/" + _loc1_.geometry);
         if(this.setFunctions != null)
         {
            this.setFunctions(_loc1_);
         }
      }
      
      private function onAnyChange(param1:Boolean = false) : void
      {
         var _loc7_:Object = null;
         this.ShankSize.titleColor = 16777215;
         this.resetTitle();
         var _loc2_:String = this.getToolType();
         this.Coating.enabled = _loc2_.indexOf("endmill") >= 0 || _loc2_.indexOf("twist") >= 0;
         var _loc3_:String = "HSS";
         if(this.Material.selectedItem)
         {
            _loc3_ = this.Material.selectedItem.label;
         }
         this.Material.enabled = !(_loc2_.indexOf("indexable") >= 0 || _loc2_.indexOf("gun drill") >= 0 || _loc2_.indexOf("thread mill") >= 0);
         if(_loc2_.indexOf("endmill") >= 0 || _loc2_.indexOf("twist drill") >= 0)
         {
            GWizToolData.allowToolMaterial("PCD",true);
         }
         else
         {
            GWizToolData.allowToolMaterial("PCD",false);
         }
         if(_loc2_.indexOf("twist drill") < 0)
         {
            GWizToolData.allowToolMaterial("Cobalt",false);
         }
         else
         {
            GWizToolData.allowToolMaterial("Cobalt",true);
         }
         if(_loc2_.indexOf("thread mill") >= 0)
         {
            this.Material.selectedIndex = GWizToolData.CARBIDE_MATERIAL;
         }
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         while(_loc5_ < this.Material.dataProvider.length)
         {
            if((_loc7_ = this.Material.dataProvider.getItemAt(_loc5_)).label == _loc3_)
            {
               this.Material.selectedIndex = _loc5_;
               _loc4_ = true;
               break;
            }
            _loc5_++;
         }
         if(!_loc4_)
         {
            this.Material.selectedIndex = 0;
         }
         this.Stickout.enabled = true;
         var _loc6_:Boolean = !GWizToolDef.lockForToolCrib || GWizCribToolEditor.ignoreLockForToolCrib;
         if(this.Geometry.enabled != _loc6_)
         {
            this.Geometry.enabled = _loc6_;
         }
         if(this.Geometry.selectedIndex < 0 || _loc2_.indexOf("indexable") >= 0)
         {
            this.Geometry.selectedIndex = 0;
         }
      }
      
      private function buildToolList(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         this.toolListData.removeAll();
         for each(_loc2_ in param1)
         {
            _loc3_ = _loc2_.@label;
            _loc4_ = 0;
            while(_loc4_ < toolMaterialDataOld.length)
            {
               _loc7_ = toolMaterialDataOld.getItemAt(_loc4_).label;
               if(_loc3_.toLowerCase().indexOf(_loc7_.toLowerCase()) == 0)
               {
                  _loc3_ = _loc3_.substr(_loc7_.length + 1);
                  break;
               }
               _loc4_++;
            }
            _loc5_ = false;
            _loc6_ = 0;
            while(_loc6_ < this.toolListData.length)
            {
               if(this.toolListData.getItemAt(_loc6_).label == _loc3_)
               {
                  _loc5_ = true;
                  break;
               }
               _loc6_++;
            }
            if(!_loc5_)
            {
               (_loc8_ = new Object()).label = _loc3_;
               this.toolListData.addItem(_loc8_);
               if(false && GWizUtils.debug)
               {
                  log.debug("toolListData[" + String(this.toolListData.length - 1) + "] = " + _loc3_);
               }
            }
         }
         this.toolListData.refresh();
         this.toolList.selectedIndex = 0;
      }
      
      private function setGeometry(param1:Boolean = false) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Object = EndMillConsts;
         this.ShankSize.visible = true;
         this.Stickout.visible = true;
         this.toolHolderTxt.visible = true;
         this.ToolDia.visible = true;
         var _loc4_:String = ENDMILL;
         if(this.Geometry.selectedItem)
         {
            _loc4_ = this.Geometry.selectedItem.label;
         }
         switch(_loc4_)
         {
            case BALLNOSE:
               this.toolImage.source = this.BallNoseImage;
               _loc2_ = BallNoseConsts;
               break;
            case LOLLIPOP:
               this.toolImage.source = this.LollipopImage;
               _loc2_ = LollipopConsts;
               break;
            case CHAMFER:
               this.toolImage.source = this.ChamferImage;
               _loc2_ = ChamferConsts;
               break;
            case CORNER_ROUND:
               this.toolImage.source = this.CornerRoundImage;
               _loc2_ = ChamferConsts;
               break;
            case VBIT:
               if(this.Geometry.selectedItem.label == GWizToolData.CHAMFER_GEO_NAME)
               {
                  this.toolImage.source = this.ChamferImage;
               }
               else if(this.Geometry.selectedItem.label == GWizToolData.CORNER_ROUND_GEO_NAME)
               {
                  this.toolImage.source = this.CornerRoundImage;
               }
               else
               {
                  this.toolImage.source = this.VBitImage;
               }
               _loc2_ = VBitConsts;
               break;
            case DOVETAIL:
               this.toolImage.source = this.DoveTailImage;
               _loc2_ = DoveTailConsts;
               break;
            case "Turning":
            case "Boring Bar":
            case "Parting":
            case "Grooving":
            case "Threading":
               this.Coating.enabled = false;
               this.ShankSize.visible = false;
               this.Stickout.visible = false;
               this.toolHolderTxt.visible = false;
               this.ToolDia.visible = false;
               switch(this.Geometry.selectedItem.label)
               {
                  case "Boring Bar":
                     this.toolImage.source = this.BoringBarImage;
                     _loc2_ = ProbeConsts;
                     break;
                  case "Parting":
                  case "Grooving":
                     this.toolImage.source = this.PartingImage;
                     _loc2_ = ProbeConsts;
                     break;
                  case "Threading":
                     this.toolImage.source = this.ThreadingImage;
                     _loc2_ = ProbeConsts;
                     break;
                  case "Turning":
                     this.toolImage.source = this.TurningImage;
                     _loc2_ = ProbeConsts;
                  default:
                     if(GWizUtils.debug && this.Geometry.selectedItem.label != "Turning")
                     {
                        GWizUtils.assert(false);
                     }
               }
               this.Material.enabled = true;
               break;
            default:
               this.toolImage.source = this.EndMillImage;
               if(this.Geometry.selectedItem && this.Geometry.selectedItem.label == GWizToolData.ROUGHER_GEO_NAME)
               {
                  this.toolImage.source = this.RougherImage;
               }
               _loc2_ = EndMillConsts;
               if(String(this.toolList.selectedItem.label).indexOf("Twist Drill") >= 0)
               {
                  this.toolImage.source = this.TwistDrillImage;
                  _loc2_ = TwistDrillConsts;
                  _loc2_.helixAngleVisible = false;
               }
               else if(String(this.toolList.selectedItem.label) == "Annular Cutter (Rotabroach®)")
               {
                  this.toolImage.source = this.TwistDrillImage;
                  _loc2_ = TwistDrillConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Indexable End Or Face Mill")
               {
                  this.toolImage.source = this.FacemillImage;
                  this.Coating.enabled = false;
                  this.Material.enabled = false;
                  _loc2_ = FaceMillConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Center Drill")
               {
                  this.toolImage.source = this.CenterDrillImage;
                  _loc2_ = TwistDrillConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Spot Drill")
               {
                  this.toolImage.source = this.SpotDrillImage;
                  _loc2_ = TwistDrillConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Indexable Drill")
               {
                  this.toolImage.source = this.IndexableDrillImage;
                  _loc2_ = TwistDrillConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Gun Drill")
               {
                  this.toolImage.source = this.GunDrillImage;
                  _loc2_ = TwistDrillConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Reamer")
               {
                  this.toolImage.source = this.ReamerImage;
                  _loc2_ = TwistDrillConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Spade Drill")
               {
                  this.toolImage.source = this.SpadeDrillImage;
                  _loc2_ = TwistDrillConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Tapping")
               {
                  this.toolImage.source = this.TappingImage;
                  _loc2_ = TwistDrillConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Thread Mill")
               {
                  this.Coating.enabled = false;
                  this.Material.enabled = false;
                  this.toolImage.source = this.ThreadMillImage;
                  _loc2_ = TwistDrillConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Boring")
               {
                  this.toolImage.source = this.BoringHeadImage;
                  _loc2_ = BoringHeadConsts;
                  this.ShankSize.visible = false;
                  this.Stickout.visible = false;
                  this.toolHolderTxt.visible = false;
                  this.ToolDia.visible = false;
               }
               else if(String(this.toolList.selectedItem.label) == "Saws & Woodruff Cutters")
               {
                  this.toolImage.source = this.WoodruffImage;
                  _loc2_ = DoveTailConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Probe")
               {
                  this.Coating.enabled = false;
                  this.Material.enabled = false;
                  this.toolImage.source = this.ProbeImage;
                  _loc2_ = ProbeConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Other")
               {
                  this.toolImage.source = this.OtherImage;
                  _loc2_ = ProbeConsts;
               }
               else if(String(this.toolList.selectedItem.label) == "Empty Toolholder" || String(this.toolList.selectedItem.label) == GWizToolData.EMPTY_SLOT)
               {
                  this.Coating.enabled = false;
                  this.Material.enabled = false;
                  this.Stickout.visible = false;
                  this.toolImage.source = this.EmptyToolholderImage;
                  _loc2_ = ProbeConsts;
               }
         }
         this.toolHolderTxt.x = _loc2_.ToolholderX;
         this.toolHolderTxt.y = _loc2_.ToolholderY;
         this.bottomTxt.x = _loc2_.BottomX;
         this.bottomTxt.y = _loc2_.BottomY;
         this.Stickout.x = _loc2_.StickoutX;
         this.Stickout.y = _loc2_.StickoutY;
         this.ShankSize.x = _loc2_.ShankX;
         this.ShankSize.y = _loc2_.ShankY;
         this.CuttingLen.x = _loc2_.CutLenX;
         this.CuttingLen.y = _loc2_.CutLenY;
         this.OverallLen.x = _loc2_.OverallLenX;
         this.OverallLen.y = _loc2_.OverallLenY;
         this.LeadAngle.x = _loc2_.LeadAngleX;
         this.LeadAngle.y = _loc2_.LeadAngleY;
         this.CornerRad.x = _loc2_.CornerRadX;
         this.CornerRad.y = _loc2_.CornerRadY;
         this.ToolDia.x = _loc2_.CutDiaX;
         this.ToolDia.y = _loc2_.CutDiaY;
         if(_loc2_.hasOwnProperty("SizesX"))
         {
            this.Sizes.x = _loc2_.SizesX;
            this.Sizes.y = _loc2_.SizesY;
         }
         this.vbitNoCutDia.x = _loc2_.NoCutDiaX;
         this.vbitNoCutDia.y = _loc2_.NoCutDiaY;
         this.HelixAngle.x = _loc2_.HelixAngleX;
         this.HelixAngle.y = _loc2_.HelixAngleY;
         this.LeadAngle.max = _loc2_.LeadAngleMax;
         this.vbitNoCutDia.visible = _loc2_.NoCutDiaVisible;
         this.CornerRad.visible = _loc2_.CornerRadVisible;
         this.OverallLen.visible = _loc2_.OverallLenVisible;
         this.CuttingLen.visible = _loc2_.CutLenVisible;
         this.LeadAngle.visible = _loc2_.LeadAngleVisible;
         this.HelixAngle.visible = _loc2_.HelixAngleVisible;
         if(_loc4_.indexOf("Straight Flute") >= 0)
         {
            this.HelixAngle.visible = false;
         }
         if(GWizToolData.isNonCuttingTool(String(this.toolList.selectedItem.label)))
         {
            this.ToolDia.visible = false;
            this.LeadAngle.visible = false;
            this.ShankSize.visible = false;
            if(String(this.toolList.selectedItem.label) != "Probe")
            {
               this.Stickout.visible = false;
               this.toolHolderTxt.visible = false;
            }
         }
         if(this.toolParms && this.Geometry.selectedIndex != this.lastGeometrySet)
         {
            if(param1)
            {
               this.toolParms.leadAngle = 90;
               this.ToolDia.setVal(this.toolParms.toolDiam);
               this.Stickout.setVal(this.toolParms.stickout);
               this.ShankSize.setVal(this.toolParms.shankSize);
               this.CornerRad.setVal(this.toolParms.cornerRadius);
               this.OverallLen.setVal(this.toolParms.overallLength);
               this.HelixAngle.setVal(this.toolParms.helixAngle);
            }
            this.lastGeometrySet = this.Geometry.selectedIndex;
         }
      }
      
      private function doToolListVC() : void
      {
         if(this.toolList.selectedIndex < 0)
         {
            this.toolList.selectedIndex = 0;
         }
         GWizToolDef.lockForToolCrib = false;
         this.pickerEM = false;
         twistDrillGeometry = false;
         emGeometry = false;
         tapGeometry = false;
         turningGeometry = false;
         this.showGeometry = true;
         this.ToolDia.titleTxt = "Tool Dia.";
         this.ShankSize.enabled = true;
         this.CuttingLen.enabled = true;
         this.OverallLen.enabled = true;
         this.LeadAngle.enabled = true;
         this.CornerRad.enabled = true;
         this.ToolDia.enabled = true;
         this.vbitNoCutDia.enabled = true;
         this.HelixAngle.enabled = true;
         this.matGrp.visible = true;
         this.coatingGrp.visible = true;
         this.LeadAngle.visible = false;
         this._flutes.value = this.toolParms.flutes;
         var _loc1_:String = this.getToolType();
         switch(_loc1_)
         {
            case "twist drill":
            case "pcd twist drill":
            case "spot drill":
            case "center drill":
            case "spade drill":
            case "gun drill":
            case "annular cutter (rotabroach®)":
               this.FlutesLabel.visible = false;
               this._flutes.value = 2;
               this._flutes.visible = false;
               this.Stickout.enabled = _loc1_.indexOf("gun") < 0;
               twistDrillGeometry = false;
               if(_loc1_.indexOf("twist drill") >= 0)
               {
                  twistDrillGeometry = true;
               }
               this.showGeometry = twistDrillGeometry;
               this.LeadAngle.value = 90;
               if(_loc1_ == "annular cutter (rotabroach®)")
               {
                  this.matGrp.visible = false;
                  this.coatingGrp.visible = false;
               }
               break;
            case "indexable drill":
            case "reamer":
               this._flutes.value = 2;
               this._flutes.visible = _loc1_ == "indexable drill" ? true : false;
               this.FlutesLabel.visible = this._flutes.visible;
               this.Stickout.enabled = false;
               this.showGeometry = false;
               this.LeadAngle.value = 90;
               break;
            case "boring":
               this.FlutesLabel.visible = false;
               this._flutes.value = 1;
               this._flutes.visible = false;
               this.ToolDia.titleTxt = "Bore Diameter";
               this.Stickout.enabled = false;
               this.showGeometry = false;
               this.LeadAngle.value = 90;
               break;
            case "tapping":
               this.FlutesLabel.visible = false;
               this._flutes.value = 1;
               this._flutes.visible = false;
               this.ToolDia.titleTxt = "Major Diameter";
               this.Stickout.enabled = false;
               tapGeometry = true;
               this.showGeometry = true;
               this.LeadAngle.value = 90;
               break;
            case "thread mill":
               this.FlutesLabel.visible = true;
               this._flutes.visible = true;
               this.Stickout.enabled = true;
               this.showGeometry = false;
               this.LeadAngle.value = 90;
               break;
            case "saws & woodruff cutters":
               this.FlutesLabel.visible = true;
               this._flutes.visible = true;
               this.Stickout.enabled = false;
               this.showGeometry = false;
               this.LeadAngle.value = 90;
               break;
            case "turning":
               this.FlutesLabel.visible = false;
               this._flutes.visible = false;
               this.Stickout.enabled = false;
               turningGeometry = true;
               this.showGeometry = true;
               this.LeadAngle.value = 90;
               break;
            case "other":
            case "probe":
            case "empty toolholder":
            case GWizToolData.EMPTY_SLOT:
               this.FlutesLabel.visible = false;
               this._flutes.visible = false;
               this.Material.enabled = false;
               this.Stickout.enabled = false;
               this.Stickout.visible = false;
               this.showGeometry = false;
               this.LeadAngle.value = 90;
               break;
            case "Indexable End Or Face Mill":
               this.LeadAngle.visible = true;
               this.showGeometry = false;
            case "endmill":
            default:
               this.FlutesLabel.visible = true;
               this._flutes.visible = true;
               this.pickerEM = true;
               this.Stickout.enabled = true;
               emGeometry = true;
               this.LeadAngle.visible = true;
               if(_loc1_ != "Indexable End Or Face Mill")
               {
                  this.LeadAngle.titleTxt = "Taper Angle";
               }
               else
               {
                  this.LeadAngle.titleTxt = "Lead Angle";
                  emGeometry = false;
               }
               if(GWizToolData.isNonCuttingTool(this.toolList.selectedItem.label))
               {
                  this.LeadAngle.visible = false;
               }
         }
         if(this.lastToolSelected != this.toolList.selectedIndex)
         {
            GWizToolData.refreshGeometry();
            this.setGeometry();
         }
         this.lastToolSelected = this.toolList.selectedIndex;
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
            _loc1_.diameter = this.ToolDia;
            _loc1_.setDefault();
         }
      }
      
      private function getToolType() : String
      {
         if(this.toolList.selectedIndex < 0 || !this.toolList.selectedItem)
         {
            return "twist drill";
         }
         return String(this.toolList.selectedItem.label).toLowerCase();
      }
      
      private function resetTitle() : void
      {
         this.titleStr = "";
         if(this.toolList && this.toolList.selectedItem && this.Material && this.Material.selectedItem && this.Coating && this.Coating.selectedItem)
         {
            this.titleStr = toolDescStr(this.toolList.selectedItem.label,this.Material.selectedItem.label,this.Coating.selectedItem.label);
         }
         if(this.resetTitleAux != null)
         {
            this.resetTitleAux(this.titleStr);
         }
         if(this.Coating.selectedIndex >= 0)
         {
            this.toolParms.coating = this.Coating.selectedItem.label;
         }
         if(this.Material.selectedIndex >= 0)
         {
            this.toolParms.toolmaterial = this.Material.selectedItem.label;
         }
      }
      
      private function outboundToolType(param1:String, param2:String) : String
      {
         var _loc3_:String = null;
         if(param1.indexOf("Turning") >= 0)
         {
            if(true || param1.indexOf("Turning:") < 0)
            {
               if(param1.substr(0,3) == "HSS")
               {
                  _loc3_ = "HSS";
               }
               else
               {
                  _loc3_ = "Carbide";
               }
               param1 = "Turning: " + _loc3_;
            }
         }
         return param1;
      }
      
      private function _GWizGraphicToolMenu_VBox1_c() : VBox
      {
         var temp:VBox = new VBox();
         temp.label = "Mock Up";
         temp.percentWidth = 100;
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":VBox,
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":HGroup,
                  "id":"leftPane",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "horizontalAlign":"center",
                        "verticalAlign":"middle",
                        "mxmlContent":[_GWizGraphicToolMenu_VGroup2_i(),_GWizGraphicToolMenu_GWizForePanel1_c()]
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         return temp;
      }
      
      private function _GWizGraphicToolMenu_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizGraphicToolMenu_List1_i(),this._GWizGraphicToolMenu_HGroup2_i(),this._GWizGraphicToolMenu_HGroup3_i(),this._GWizGraphicToolMenu_HGroup4_c(),this._GWizGraphicToolMenu_Label4_c(),this._GWizGraphicToolMenu_GWizGeometryCombo1_i()];
         _loc1_.id = "firstGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.firstGrp = _loc1_;
         BindingManager.executeBindings(this,"firstGrp",this.firstGrp);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_List1_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.labelField = "label";
         _loc1_.percentWidth = 100;
         _loc1_.height = 225;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__toolList_valueCommit);
         _loc1_.id = "toolList";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolList = _loc1_;
         BindingManager.executeBindings(this,"toolList",this.toolList);
         return _loc1_;
      }
      
      public function __toolList_valueCommit(param1:FlexEvent) : void
      {
         this.doToolListVC();
      }
      
      private function _GWizGraphicToolMenu_HGroup2_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGraphicToolMenu_Label1_i(),this._GWizGraphicToolMenu_DropDownList1_i()];
         _loc1_.id = "matGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.matGrp = _loc1_;
         BindingManager.executeBindings(this,"matGrp",this.matGrp);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Material";
         _loc1_.id = "_GWizGraphicToolMenu_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGraphicToolMenu_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGraphicToolMenu_Label1",this._GWizGraphicToolMenu_Label1);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.percentWidth = 100;
         _loc1_.labelField = "label";
         _loc1_.toolTip = "Tool material.";
         _loc1_.addEventListener("change",this.__Material_change);
         _loc1_.id = "Material";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Material = _loc1_;
         BindingManager.executeBindings(this,"Material",this.Material);
         return _loc1_;
      }
      
      public function __Material_change(param1:IndexChangeEvent) : void
      {
         this.resetTitle();
      }
      
      private function _GWizGraphicToolMenu_HGroup3_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGraphicToolMenu_Label2_i(),this._GWizGraphicToolMenu_DropDownList2_i()];
         _loc1_.id = "coatingGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.coatingGrp = _loc1_;
         BindingManager.executeBindings(this,"coatingGrp",this.coatingGrp);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Coating";
         _loc1_.id = "_GWizGraphicToolMenu_Label2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGraphicToolMenu_Label2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGraphicToolMenu_Label2",this._GWizGraphicToolMenu_Label2);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.percentWidth = 100;
         _loc1_.labelField = "label";
         _loc1_.selectedIndex = 0;
         _loc1_.toolTip = "Tool coatings.";
         _loc1_.addEventListener("change",this.__Coating_change);
         _loc1_.id = "Coating";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Coating = _loc1_;
         BindingManager.executeBindings(this,"Coating",this.Coating);
         return _loc1_;
      }
      
      public function __Coating_change(param1:IndexChangeEvent) : void
      {
         this.resetTitle();
      }
      
      private function _GWizGraphicToolMenu_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "right";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGraphicToolMenu_Label3_i(),this._GWizGraphicToolMenu_NumericStepper1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_Label3_i() : Label
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
      
      private function _GWizGraphicToolMenu_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.value = 2;
         _loc1_.minimum = 1;
         _loc1_.stepSize = 1;
         _loc1_.maximum = 200;
         _loc1_.setStyle("color",0);
         _loc1_.id = "_flutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._flutes = _loc1_;
         BindingManager.executeBindings(this,"_flutes",this._flutes);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tip Shape:";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("backgroundColor",4473924);
         _loc1_.setStyle("color",16777215);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingLeft",3);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_GWizGeometryCombo1_i() : GWizGeometryCombo
      {
         var _loc1_:GWizGeometryCombo = new GWizGeometryCombo();
         _loc1_.addEventListener("valueCommit",this.__Geometry_valueCommit);
         _loc1_.id = "Geometry";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Geometry = _loc1_;
         BindingManager.executeBindings(this,"Geometry",this.Geometry);
         return _loc1_;
      }
      
      public function __Geometry_valueCommit(param1:FlexEvent) : void
      {
         this.setGeometry(true);
      }
      
      private function _GWizGraphicToolMenu_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 75;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGraphicToolMenu_Array7_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_Array7_c() : Array
      {
         return [this._GWizGraphicToolMenu_Group1_i()];
      }
      
      private function _GWizGraphicToolMenu_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizGraphicToolMenu_Rect1_c(),this._GWizGraphicToolMenu_Image1_i(),this._GWizGraphicToolMenu_Label5_i(),this._GWizGraphicToolMenu_Label6_i(),this._GWizGraphicToolMenu_GWizNumStep1_i(),this._GWizGraphicToolMenu_GWizNumStep2_i(),this._GWizGraphicToolMenu_GWizNumStep3_i(),this._GWizGraphicToolMenu_GWizNumStep4_i(),this._GWizGraphicToolMenu_GWizNumStep5_i(),this._GWizGraphicToolMenu_GWizNumStep6_i(),this._GWizGraphicToolMenu_GWizNumStep7_i(),this._GWizGraphicToolMenu_Button1_i(),this._GWizGraphicToolMenu_GWizNumStep8_i(),this._GWizGraphicToolMenu_GWizNumStep9_i()];
         _loc1_.setStyle("color",0);
         _loc1_.id = "toolView";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolView = _loc1_;
         BindingManager.executeBindings(this,"toolView",this.toolView);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.fill = this._GWizGraphicToolMenu_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.x = 0;
         _loc1_.y = 0;
         _loc1_.id = "toolImage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolImage = _loc1_;
         BindingManager.executeBindings(this,"toolImage",this.toolImage);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Toolholder";
         _loc1_.x = 44;
         _loc1_.y = 199;
         _loc1_.id = "toolHolderTxt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolHolderTxt = _loc1_;
         BindingManager.executeBindings(this,"toolHolderTxt",this.toolHolderTxt);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Bottom";
         _loc1_.x = 55;
         _loc1_.y = 212;
         _loc1_.id = "bottomTxt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.bottomTxt = _loc1_;
         BindingManager.executeBindings(this,"bottomTxt",this.bottomTxt);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Stickout";
         _loc1_.x = 12;
         _loc1_.y = 365;
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.horizontalLayout = false;
         _loc1_.titleColor = 0;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.id = "Stickout";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Stickout = _loc1_;
         BindingManager.executeBindings(this,"Stickout",this.Stickout);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Shank Dia.";
         _loc1_.x = 150;
         _loc1_.y = 60;
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.titleColor = 16777215;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.toolTip = "Specify a shank larger or smaller than tool diameter here for deflection calculations.";
         _loc1_.horizontalLayout = false;
         _loc1_.setStyle("color",0);
         _loc1_.id = "ShankSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ShankSize = _loc1_;
         BindingManager.executeBindings(this,"ShankSize",this.ShankSize);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Cut Len.";
         _loc1_.x = 302;
         _loc1_.y = 365;
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.horizontalLayout = false;
         _loc1_.titleColor = 0;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.toolTip = "Cut Length is the maximum vertical cutting height of the flutes.";
         _loc1_.setStyle("color",0);
         _loc1_.id = "CuttingLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CuttingLen = _loc1_;
         BindingManager.executeBindings(this,"CuttingLen",this.CuttingLen);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Overall Len.";
         _loc1_.x = 396;
         _loc1_.y = 405;
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.enabled = true;
         _loc1_.horizontalLayout = false;
         _loc1_.titleColor = 0;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.setStyle("color",0);
         _loc1_.id = "OverallLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.OverallLen = _loc1_;
         BindingManager.executeBindings(this,"OverallLen",this.OverallLen);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Taper Angle";
         _loc1_.x = 14;
         _loc1_.y = 520;
         _loc1_.min = 0;
         _loc1_.max = 90;
         _loc1_.steps = 1;
         _loc1_.horizontalLayout = false;
         _loc1_.titleColor = 0;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.toolTip = "The angle of one side of the taper in degrees.  Use either 0 or 90 for straight tools and inserts.";
         _loc1_.usesMetric = false;
         _loc1_.visible = true;
         _loc1_.setStyle("color",0);
         _loc1_.id = "LeadAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LeadAngle = _loc1_;
         BindingManager.executeBindings(this,"LeadAngle",this.LeadAngle);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_GWizNumStep6_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Corner Rad.";
         _loc1_.x = 353;
         _loc1_.y = 520;
         _loc1_.min = 0;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.horizontalLayout = false;
         _loc1_.titleColor = 0;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.setStyle("color",0);
         _loc1_.id = "CornerRad";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CornerRad = _loc1_;
         BindingManager.executeBindings(this,"CornerRad",this.CornerRad);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_GWizNumStep7_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Tool Dia.";
         _loc1_.x = 150;
         _loc1_.y = 560;
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.horizontalLayout = false;
         _loc1_.titleColor = 0;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.setStyle("color",0);
         _loc1_.id = "ToolDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolDia = _loc1_;
         BindingManager.executeBindings(this,"ToolDia",this.ToolDia);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Sizes";
         _loc1_.x = 150;
         _loc1_.y = 575;
         _loc1_.toolTip = "Select diameter from std drill sizes";
         _loc1_.setStyle("color",734012);
         _loc1_.addEventListener("click",this.__Sizes_click);
         _loc1_.id = "Sizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Sizes = _loc1_;
         BindingManager.executeBindings(this,"Sizes",this.Sizes);
         return _loc1_;
      }
      
      public function __Sizes_click(param1:MouseEvent) : void
      {
         this.showDrillPicker();
      }
      
      private function _GWizGraphicToolMenu_GWizNumStep8_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "No Cut Dia";
         _loc1_.x = 306;
         _loc1_.y = 527.5;
         _loc1_.min = 0;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.enabled = false;
         _loc1_.titleColor = 0;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.horizontalLayout = false;
         _loc1_.setStyle("color",0);
         _loc1_.id = "vbitNoCutDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.vbitNoCutDia = _loc1_;
         BindingManager.executeBindings(this,"vbitNoCutDia",this.vbitNoCutDia);
         return _loc1_;
      }
      
      private function _GWizGraphicToolMenu_GWizNumStep9_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Helix Angle";
         _loc1_.x = 306;
         _loc1_.y = 527.5;
         _loc1_.min = 10;
         _loc1_.max = 90;
         _loc1_.steps = 1;
         _loc1_.visible = false;
         _loc1_.titleColor = 0;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.horizontalLayout = false;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.id = "HelixAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HelixAngle = _loc1_;
         BindingManager.executeBindings(this,"HelixAngle",this.HelixAngle);
         return _loc1_;
      }
      
      public function ___GWizGraphicToolMenu_VGroup1_click(param1:MouseEvent) : void
      {
         this.onAnyChange();
      }
      
      public function ___GWizGraphicToolMenu_VGroup1_keyDown(param1:KeyboardEvent) : void
      {
         this.onAnyChange();
      }
      
      public function ___GWizGraphicToolMenu_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizGraphicToolMenu_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return toolListData;
         },null,"toolList.dataProvider");
         result[1] = new Binding(this,function():Boolean
         {
            return Material.enabled;
         },null,"matGrp.visible");
         result[2] = new Binding(this,function():uint
         {
            return 16777215;
         },function(param1:uint):void
         {
            _GWizGraphicToolMenu_Label1.setStyle("color",param1);
         },"_GWizGraphicToolMenu_Label1.color");
         result[3] = new Binding(this,function():IList
         {
            return GWizToolData.toolMaterialData;
         },null,"Material.dataProvider");
         result[4] = new Binding(this,function():Boolean
         {
            return Coating.enabled;
         },null,"coatingGrp.visible");
         result[5] = new Binding(this,function():uint
         {
            return 16777215;
         },function(param1:uint):void
         {
            _GWizGraphicToolMenu_Label2.setStyle("color",param1);
         },"_GWizGraphicToolMenu_Label2.color");
         result[6] = new Binding(this,function():IList
         {
            return GWizToolData.toolCoatingData;
         },null,"Coating.dataProvider");
         result[7] = new Binding(this,function():uint
         {
            return 16777215;
         },function(param1:uint):void
         {
            FlutesLabel.setStyle("color",param1);
         },"FlutesLabel.color");
         result[8] = new Binding(this,function():Number
         {
            return Coating.width;
         },null,"_flutes.width");
         result[9] = new Binding(this,function():Boolean
         {
            return showGeometry;
         },null,"Geometry.visible");
         result[10] = new Binding(this,function():Boolean
         {
            return toolHolderTxt.visible;
         },null,"bottomTxt.visible");
         result[11] = new Binding(this,function():Number
         {
            return ToolDia.width;
         },null,"Sizes.width");
         result[12] = new Binding(this,function():Boolean
         {
            return ToolDia.visible;
         },null,"Sizes.visible");
         result[13] = new Binding(this,function():Boolean
         {
            return HelixAngle.visible;
         },null,"HelixAngle.enabled");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Coating() : DropDownList
      {
         return this._1690785341Coating;
      }
      
      public function set Coating(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1690785341Coating;
         if(_loc2_ !== param1)
         {
            this._1690785341Coating = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Coating",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CornerRad() : GWizNumStep
      {
         return this._680218976CornerRad;
      }
      
      public function set CornerRad(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._680218976CornerRad;
         if(_loc2_ !== param1)
         {
            this._680218976CornerRad = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CornerRad",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CuttingLen() : GWizNumStep
      {
         return this._1984263141CuttingLen;
      }
      
      public function set CuttingLen(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1984263141CuttingLen;
         if(_loc2_ !== param1)
         {
            this._1984263141CuttingLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CuttingLen",_loc2_,param1));
            }
         }
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
      public function get Geometry() : GWizGeometryCombo
      {
         return this._1910664338Geometry;
      }
      
      public function set Geometry(param1:GWizGeometryCombo) : void
      {
         var _loc2_:Object = this._1910664338Geometry;
         if(_loc2_ !== param1)
         {
            this._1910664338Geometry = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Geometry",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HelixAngle() : GWizNumStep
      {
         return this._1985877227HelixAngle;
      }
      
      public function set HelixAngle(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1985877227HelixAngle;
         if(_loc2_ !== param1)
         {
            this._1985877227HelixAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HelixAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LeadAngle() : GWizNumStep
      {
         return this._1177533769LeadAngle;
      }
      
      public function set LeadAngle(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1177533769LeadAngle;
         if(_loc2_ !== param1)
         {
            this._1177533769LeadAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LeadAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Material() : DropDownList
      {
         return this._363710791Material;
      }
      
      public function set Material(param1:DropDownList) : void
      {
         var _loc2_:Object = this._363710791Material;
         if(_loc2_ !== param1)
         {
            this._363710791Material = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Material",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get OverallLen() : GWizNumStep
      {
         return this._264475992OverallLen;
      }
      
      public function set OverallLen(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._264475992OverallLen;
         if(_loc2_ !== param1)
         {
            this._264475992OverallLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"OverallLen",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShankSize() : GWizNumStep
      {
         return this._312927978ShankSize;
      }
      
      public function set ShankSize(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._312927978ShankSize;
         if(_loc2_ !== param1)
         {
            this._312927978ShankSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShankSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Sizes() : Button
      {
         return this._79900786Sizes;
      }
      
      public function set Sizes(param1:Button) : void
      {
         var _loc2_:Object = this._79900786Sizes;
         if(_loc2_ !== param1)
         {
            this._79900786Sizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Sizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Stickout() : GWizNumStep
      {
         return this._1596369118Stickout;
      }
      
      public function set Stickout(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1596369118Stickout;
         if(_loc2_ !== param1)
         {
            this._1596369118Stickout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Stickout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolDia() : GWizNumStep
      {
         return this._524530596ToolDia;
      }
      
      public function set ToolDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._524530596ToolDia;
         if(_loc2_ !== param1)
         {
            this._524530596ToolDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolDia",_loc2_,param1));
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
      public function get bottomTxt() : Label
      {
         return this._1855390651bottomTxt;
      }
      
      public function set bottomTxt(param1:Label) : void
      {
         var _loc2_:Object = this._1855390651bottomTxt;
         if(_loc2_ !== param1)
         {
            this._1855390651bottomTxt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bottomTxt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get coatingGrp() : HGroup
      {
         return this._803039230coatingGrp;
      }
      
      public function set coatingGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._803039230coatingGrp;
         if(_loc2_ !== param1)
         {
            this._803039230coatingGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"coatingGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get firstGrp() : VGroup
      {
         return this._549910507firstGrp;
      }
      
      public function set firstGrp(param1:VGroup) : void
      {
         var _loc2_:Object = this._549910507firstGrp;
         if(_loc2_ !== param1)
         {
            this._549910507firstGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"firstGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get leftPane() : HGroup
      {
         return this._1718295567leftPane;
      }
      
      public function set leftPane(param1:HGroup) : void
      {
         var _loc2_:Object = this._1718295567leftPane;
         if(_loc2_ !== param1)
         {
            this._1718295567leftPane = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"leftPane",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get matGrp() : HGroup
      {
         return this._1081280667matGrp;
      }
      
      public function set matGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._1081280667matGrp;
         if(_loc2_ !== param1)
         {
            this._1081280667matGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"matGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolHolderTxt() : Label
      {
         return this._956920212toolHolderTxt;
      }
      
      public function set toolHolderTxt(param1:Label) : void
      {
         var _loc2_:Object = this._956920212toolHolderTxt;
         if(_loc2_ !== param1)
         {
            this._956920212toolHolderTxt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolHolderTxt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolImage() : Image
      {
         return this._436498781toolImage;
      }
      
      public function set toolImage(param1:Image) : void
      {
         var _loc2_:Object = this._436498781toolImage;
         if(_loc2_ !== param1)
         {
            this._436498781toolImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolList() : List
      {
         return this._983825834toolList;
      }
      
      public function set toolList(param1:List) : void
      {
         var _loc2_:Object = this._983825834toolList;
         if(_loc2_ !== param1)
         {
            this._983825834toolList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolView() : Group
      {
         return this._983528355toolView;
      }
      
      public function set toolView(param1:Group) : void
      {
         var _loc2_:Object = this._983528355toolView;
         if(_loc2_ !== param1)
         {
            this._983528355toolView = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolView",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get vbitNoCutDia() : GWizNumStep
      {
         return this._67441166vbitNoCutDia;
      }
      
      public function set vbitNoCutDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._67441166vbitNoCutDia;
         if(_loc2_ !== param1)
         {
            this._67441166vbitNoCutDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"vbitNoCutDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get toolListData() : ArrayCollection
      {
         return this._664319200toolListData;
      }
      
      private function set toolListData(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._664319200toolListData;
         if(_loc2_ !== param1)
         {
            this._664319200toolListData = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolListData",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get showGeometry() : Boolean
      {
         return this._994048655showGeometry;
      }
      
      private function set showGeometry(param1:Boolean) : void
      {
         var _loc2_:Object = this._994048655showGeometry;
         if(_loc2_ !== param1)
         {
            this._994048655showGeometry = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"showGeometry",_loc2_,param1));
            }
         }
      }
   }
}
