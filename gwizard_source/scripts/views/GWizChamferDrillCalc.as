package views
{
   import comps.GWizNumStep;
   import comps.GWizPopUpManager;
   import comps.GridComponent;
   import configinfo.GWizConfigData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.containers.ViewStack;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponent;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.events.PropertyChangeEvent;
   import mx.events.ResizeEvent;
   import mx.formatters.NumberBase;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GridSkin;
   import spark.components.Button;
   import spark.components.ButtonBar;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.NavigatorContent;
   import spark.components.NumericStepper;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import tools.GWizDrillPicker;
   import utils.ColorPalette;
   import utils.GWizGeomUtils;
   import utils.GWizUtils;
   import utils.GraphicsUtil;
   
   use namespace mx_internal;
   
   public class GWizChamferDrillCalc extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizChamferDrillCalc");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _980029210CenterDrill:NavigatorContent;
      
      private var _186417553Countersink:NavigatorContent;
      
      private var _1047339097SpotDrill:NavigatorContent;
      
      private var _1013607948TwistAngle:DropDownList;
      
      private var _1016499604TwistDrill:NavigatorContent;
      
      public var _GWizChamferDrillCalc_Button4:Button;
      
      public var _GWizChamferDrillCalc_Label11:Label;
      
      public var _GWizChamferDrillCalc_Label12:Label;
      
      public var _GWizChamferDrillCalc_Label13:Label;
      
      public var _GWizChamferDrillCalc_Label17:Label;
      
      public var _GWizChamferDrillCalc_Label24:Label;
      
      private var _313237985angleLabel:Label;
      
      private var _54908794bodyDia:Label;
      
      private var _465950277cdChamferDia:GWizNumStep;
      
      private var _1776873392cdClearBtn:Button;
      
      private var _1246108055cdDrillDepth:GWizNumStep;
      
      private var _199124959cdMaxChamfer:GWizNumStep;
      
      private var _1623843023cdMinChamfer:GWizNumStep;
      
      private var _1181867019centerDrillImage:Image;
      
      private var _464752201chamDiaLabel:Label;
      
      private var _250266604counterSinkImage:Image;
      
      private var _1024311875csAngle:NumericStepper;
      
      private var _1558198567csChamDiaLabel:Label;
      
      private var _1026823219csDepth:GWizNumStep;
      
      private var _1604067969csDepthLabel:Label;
      
      private var _94923244csDia:GWizNumStep;
      
      private var _2066504079csTipDia:GWizNumStep;
      
      private var _1867233533csTipDiaLabel:Label;
      
      private var _207291889depthLabel:Label;
      
      private var _1865259686drillSelector:DropDownList;
      
      private var _317561717gridComp:GridComponent;
      
      private var _477148508pilotDia:Label;
      
      private var _477140931pilotLen:Label;
      
      private var _1910031618sdAngle:NumericStepper;
      
      private var _951124166sdChamDiaLabel:Label;
      
      private var _1599373227sdChamferDia:GWizNumStep;
      
      private var _399328808sdClearLabel:Button;
      
      private var _558890786sdDepthLabel:Label;
      
      private var _819215449sdDrillDepth:GWizNumStep;
      
      private var _2023726190sdDrillDia:GWizNumStep;
      
      private var _1909459622sdIncludedAngle:Label;
      
      private var _2030518833sdMaxChamfer:GWizNumStep;
      
      private var _41084315sdMaxChamferLabel:Label;
      
      private var _441480481sdMinChamfer:GWizNumStep;
      
      private var _815209570spotDrillImage:Image;
      
      private var _881406642tabNav:ViewStack;
      
      private var _3552126tabs:ButtonBar;
      
      private var _1497431997tdAngle:NumericStepper;
      
      private var _789821436tdAngleGroup:HGroup;
      
      private var _110176236tdDia:GWizNumStep;
      
      private var _948298168tdDrillDepth:GWizNumStep;
      
      private var _2091450340tdDrillDepthLabel:Label;
      
      private var _879405610tdGrid:GridComponent;
      
      private var _1550111405tdHoleDepth:GWizNumStep;
      
      private var _1051214495tdHoleDepthLabel:Label;
      
      private var _145477703twistDrillImage:Image;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var noChanges:Boolean = false;
      
      private var centerDrillPoints:Array;
      
      private var spotDrillPoints:Array;
      
      private var twistDrillPoints:Array;
      
      private var counterSinkPoints:Array;
      
      private var cdDepthArrowPoints:Array;
      
      private var tdHoleDepthArrowPoints:Array;
      
      private var tdDrillDepthArrowPoints:Array;
      
      private var csDepthArrowPoints:Array;
      
      private var csTipArrowPoints:Array;
      
      private var _embed_mxml_assets_Countersink_png_2012612414:Class;
      
      private var _embed_mxml_assets_SpotDrill_png_1245456670:Class;
      
      private var _embed_mxml_assets_TwistDrill_png_1807610066:Class;
      
      private var _embed_mxml_assets_CenterDrill_png_1992689488:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizChamferDrillCalc()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._embed_mxml_assets_Countersink_png_2012612414 = GWizChamferDrillCalc__embed_mxml_assets_Countersink_png_2012612414;
         this._embed_mxml_assets_SpotDrill_png_1245456670 = GWizChamferDrillCalc__embed_mxml_assets_SpotDrill_png_1245456670;
         this._embed_mxml_assets_TwistDrill_png_1807610066 = GWizChamferDrillCalc__embed_mxml_assets_TwistDrill_png_1807610066;
         this._embed_mxml_assets_CenterDrill_png_1992689488 = GWizChamferDrillCalc__embed_mxml_assets_CenterDrill_png_1992689488;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizChamferDrillCalc_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizChamferDrillCalcWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizChamferDrillCalc[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.horizontalAlign = "center";
         this.mxmlContent = [this._GWizChamferDrillCalc_ButtonBar1_i(),this._GWizChamferDrillCalc_ViewStack1_i()];
         this.addEventListener("creationComplete",this.___GWizChamferDrillCalc_VGroup1_creationComplete);
         this.addEventListener("show",this.___GWizChamferDrillCalc_VGroup1_show);
         this.addEventListener("resize",this.___GWizChamferDrillCalc_VGroup1_resize);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizChamferDrillCalc._watcherSetupUtil = param1;
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
      
      private function showDrillPicker() : void
      {
         var _loc1_:GWizDrillPicker = GWizDrillPicker(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizDrillPicker,true));
         if(_loc1_)
         {
            _loc1_.dc.setFilter(true,false,false);
            _loc1_.diameter = this.tdDia;
            _loc1_.setDefault();
         }
      }
      
      private function chamferDepth(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = NaN;
         param1 = GWizUtils.radians(param1);
         _loc3_ = param2 / (2 * Math.tan(param1 / 2));
         log.debug("chamferDepth: " + param1 + ", " + param2 + " = " + _loc3_);
         return _loc3_;
      }
      
      private function checkUnits() : void
      {
         this.changeCenterDrill();
         this.changeSpotDrill();
         this.changeTwistDrill();
         this.changeCountersink();
      }
      
      private function changeCenterDrill() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:NumberBase = new NumberBase();
         if(this.noChanges)
         {
            return;
         }
         this.bodyDia.text = String(GWizUtils.roundTenths(this.drillSelector.selectedItem.bodydia,true));
         this.pilotDia.text = String(GWizUtils.roundTenths(this.drillSelector.selectedItem.pilotdia,true));
         this.pilotLen.text = String(GWizUtils.roundTenths(this.drillSelector.selectedItem.pilotlen,true));
         this.cdMaxChamfer.setVal(GWizUtils.roundThousandths(this.drillSelector.selectedItem.bodydia - 0.001,false));
         this.cdMinChamfer.setVal(GWizUtils.roundThousandths(this.drillSelector.selectedItem.pilotdia + 0.001,false));
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            this.cdChamferDia.max = this.cdMaxChamfer.getVal();
         }
         else
         {
            this.cdChamferDia.max = this.cdMaxChamfer.getVal() * 25.4;
         }
         this.cdChamferDia.min = 0;
         if(this.cdChamferDia.getVal() > 0)
         {
            this.cdDrillDepth.setVal(this.chamferDepth(60,this.cdChamferDia.getVal()) - this.chamferDepth(60,this.drillSelector.selectedItem.pilotdia) + this.drillSelector.selectedItem.pilotlen + this.chamferDepth(118,this.drillSelector.selectedItem.pilotdia));
         }
         else if(this.cdDrillDepth.getVal() > 0)
         {
            _loc2_ = this.cdDrillDepth.getVal() - this.drillSelector.selectedItem.pilotlen + this.chamferDepth(60,this.drillSelector.selectedItem.pilotdia);
            this.cdChamferDia.setVal(Math.min(GWizGeomUtils.coneDiameter(60,_loc2_),this.drillSelector.selectedItem.bodydia));
         }
      }
      
      private function changeSpotDrill() : void
      {
         this.sdMaxChamfer.setVal(this.sdDrillDia.getVal() - 0.001);
         this.sdMinChamfer.setVal(0.001);
         if(this.noChanges)
         {
            return;
         }
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            this.sdChamferDia.max = this.sdMaxChamfer.getVal();
         }
         else
         {
            this.sdChamferDia.max = this.sdMaxChamfer.getVal() * 25.4;
         }
         this.sdChamferDia.min = 0;
         if(this.sdChamferDia.getVal() > 0)
         {
            this.sdDrillDepth.setVal(this.chamferDepth(this.sdAngle.value,this.sdChamferDia.getVal()));
         }
         else if(this.sdDrillDepth.getVal() > 0)
         {
            this.sdChamferDia.setVal(Math.min(GWizGeomUtils.coneDiameter(this.sdAngle.value,this.sdDrillDepth.getVal()),this.sdDrillDia.getVal()));
         }
      }
      
      private function changeTwistDrill() : void
      {
         if(this.noChanges)
         {
            return;
         }
         if(this.tdDia.getVal() > 0 && this.tdAngle.value > 0)
         {
            if(this.tdHoleDepth.getVal() > 0)
            {
               this.tdDrillDepth.setVal(this.chamferDepth(this.tdAngle.value,this.tdDia.getVal()) + this.tdHoleDepth.getVal());
            }
            else if(this.tdDrillDepth.getVal() > 0)
            {
               this.tdHoleDepth.setVal(this.tdDrillDepth.getVal() - this.chamferDepth(this.tdAngle.value,this.tdDia.getVal()));
            }
         }
      }
      
      private function changeCountersink() : void
      {
         if(this.noChanges)
         {
            return;
         }
         if(this.csAngle.value > 0)
         {
            if(this.csDia.getVal() > 0)
            {
               this.csDepth.setVal(this.chamferDepth(this.csAngle.value,this.csDia.getVal()));
               this.csDepth.setVal(this.csDepth.getVal() - this.chamferDepth(this.csAngle.value,this.csTipDia.getVal()));
            }
            else if(this.csDepth.getVal() > 0)
            {
               this.csDia.setVal(GWizGeomUtils.coneDiameter(this.csAngle.value,this.csDepth.getVal() + this.chamferDepth(this.csAngle.value,this.csTipDia.getVal())));
            }
         }
      }
      
      private function init() : void
      {
         this.noChanges = true;
         this.drillSelector.selectedIndex = 0;
         this.cdChamferDia.setVal(0);
         this.cdDrillDepth.setVal(0);
         this.cdMinChamfer.setVal(0.021);
         this.cdMaxChamfer.setVal(0.124);
         this.sdChamferDia.setVal(0);
         this.sdDrillDepth.setVal(0);
         this.sdAngle.value = 90;
         this.sdDrillDia.setVal(0);
         this.sdMinChamfer.setVal(0);
         this.sdMaxChamfer.setVal(0);
         this.tdHoleDepth.setVal(0);
         this.tdAngle.value = 118;
         this.tdDia.setVal(0);
         this.tdDrillDepth.setVal(0);
         this.csDia.setVal(0);
         this.csDepth.setVal(0);
         this.csAngle.value = 60;
         this.csTipDia.setVal(0);
         this.noChanges = false;
         this.initPoints();
      }
      
      protected function doTwistAngle() : void
      {
         var _loc1_:Number = parseFloat(this.TwistAngle.selectedItem.data);
         if(!isNaN(_loc1_) && _loc1_ > 0)
         {
            this.tdAngle.value = _loc1_;
         }
      }
      
      public function appSelector(param1:String) : Object
      {
         var _loc2_:Object = this.tabNav.selectedChild;
         switch(param1)
         {
            case "CenterDrill":
               _loc2_ = this.CenterDrill;
               break;
            case "SpotDrill":
               _loc2_ = this.SpotDrill;
               break;
            case "TwistDrill":
               _loc2_ = this.TwistDrill;
               break;
            case "Countersink":
               _loc2_ = this.Countersink;
         }
         var _loc3_:NavigatorContent = _loc2_ as NavigatorContent;
         this.tabNav.selectedChild = _loc3_;
         return _loc3_.getElementAt(0);
      }
      
      private function initPoints() : void
      {
         this.centerDrillPoints = [[this.cdChamferDia,"lm",this.convPt(515,370,this.centerDrillImage)],[this.depthLabel,"lm",this.convPt(610,225,this.centerDrillImage)],[this.angleLabel,"rb",this.convPt(205,305,this.centerDrillImage)]];
         this.spotDrillPoints = [[this.sdChamferDia,"rb",this.convPt(30,220,this.spotDrillImage)],[this.sdMaxChamfer,"lb",this.convPt(250,220,this.spotDrillImage)],[this.sdIncludedAngle,"lt",this.convPt(510,530,this.spotDrillImage)],[this.sdDrillDia,"cb",this.convPt(158,667,this.spotDrillImage)],[this.sdDepthLabel,"lt",this.convPt(610,80,this.spotDrillImage)]];
         this.twistDrillPoints = [[this.tdDia,"lt",this.convPt(445,700,this.twistDrillImage)],[this.tdHoleDepth,"rt",this.convPt(70,175,this.twistDrillImage)],[this.tdDrillDepthLabel,"lb",this.convPt(650,153,this.twistDrillImage)],[this.tdAngleGroup,"ct",this.convPt(357,16,this.twistDrillImage)]];
         this.counterSinkPoints = [[this.csAngle,"lb",this.convPt(415,640,this.counterSinkImage)],[this.csTipDiaLabel,"lt",this.convPt(375,85,this.counterSinkImage)],[this.csDepthLabel,"lm",this.convPt(710,375,this.counterSinkImage)],[this.csDia,"lm",this.convPt(635,477,this.counterSinkImage)]];
         this.cdDepthArrowPoints = [this.convPt(650,297,this.centerDrillImage),this.convPt(650,154,this.centerDrillImage)];
         this.tdHoleDepthArrowPoints = [this.convPt(45,237,this.twistDrillImage),this.convPt(45,100,this.twistDrillImage)];
         this.tdDrillDepthArrowPoints = [this.convPt(670,237,this.twistDrillImage),this.convPt(670,56,this.twistDrillImage)];
         this.csDepthArrowPoints = [this.convPt(710,401,this.counterSinkImage),this.convPt(710,346,this.counterSinkImage)];
         this.csTipArrowPoints = [this.convPt(308,100,this.counterSinkImage),this.convPt(345,100,this.counterSinkImage)];
      }
      
      private function convPt(param1:Number, param2:Number, param3:Image) : Point
      {
         return new Point(param1 - param3.sourceWidth / 2,param3.sourceHeight - param2 - param3.sourceHeight / 2);
      }
      
      private function adjustPoint(param1:Array, param2:Point, param3:Number) : void
      {
         var _loc4_:Point = this.calcRelativePoint(param1[2],param2,param3);
         switch(param1[1].charAt(0))
         {
            case "c":
               _loc4_.x -= param1[0].width / 2;
               break;
            case "r":
               _loc4_.x -= param1[0].width;
         }
         switch(param1[1].charAt(1))
         {
            case "m":
               _loc4_.y -= param1[0].height / 2;
               break;
            case "b":
               _loc4_.y -= param1[0].height;
         }
         param1[0].x = _loc4_.x;
         param1[0].y = _loc4_.y;
      }
      
      private function calcRelativePoint(param1:Point, param2:Point, param3:Number, param4:Boolean = false) : Point
      {
         return new Point(param2.x + param1.x * param3 + (!!param4 ? 0 : 20),param2.y + param1.y * param3 + (!!param4 ? 0 : 20));
      }
      
      private function onResize() : void
      {
         var _loc1_:Array = null;
         var _loc2_:UIComponent = null;
         var _loc3_:Image = null;
         var _loc4_:Array = null;
         switch(this.tabs.selectedIndex)
         {
            case 0:
               _loc3_ = this.centerDrillImage;
               _loc4_ = this.centerDrillPoints;
               break;
            case 1:
               _loc3_ = this.spotDrillImage;
               _loc4_ = this.spotDrillPoints;
               break;
            case 2:
               _loc3_ = this.twistDrillImage;
               _loc4_ = this.twistDrillPoints;
               break;
            default:
               _loc3_ = this.counterSinkImage;
               _loc4_ = this.counterSinkPoints;
         }
         var _loc5_:Number = this.calcImageScale(_loc3_);
         var _loc6_:Point = this.calcImageCenter(_loc3_);
         if(this.tabs.selectedIndex == 0)
         {
            this.drawCenterDrillArrows(this.centerDrillImage.graphics,_loc5_,_loc6_);
         }
         if(this.tabs.selectedIndex == 2)
         {
            this.drawTwistDrillArrows(this.twistDrillImage.graphics,_loc5_,_loc6_);
         }
         if(this.tabs.selectedIndex == 3)
         {
            this.drawCounterSinkArrows(this.counterSinkImage.graphics,_loc5_,_loc6_);
         }
         for each(_loc1_ in _loc4_)
         {
            _loc2_ = _loc1_[0];
            this.adjustPoint(_loc1_,_loc6_,_loc5_);
         }
      }
      
      private function calcImageScale(param1:Image) : Number
      {
         return Math.min(param1.height / param1.sourceHeight,param1.width / param1.sourceWidth);
      }
      
      private function calcImageCenter(param1:Image) : Point
      {
         return new Point(param1.width / 2,param1.height / 2);
      }
      
      private function drawTwistDrillArrows(param1:Graphics, param2:Number, param3:Point) : void
      {
         if(this.tdHoleDepthArrowPoints == null)
         {
            return;
         }
         param1.clear();
         param1.beginFill(0,1);
         GraphicsUtil.drawArrows(param1,this.calcRelativePoint(this.tdHoleDepthArrowPoints[0],param3,param2,true),this.calcRelativePoint(this.tdHoleDepthArrowPoints[1],param3,param2,true),40);
         GraphicsUtil.drawArrows(param1,this.calcRelativePoint(this.tdDrillDepthArrowPoints[0],param3,param2,true),this.calcRelativePoint(this.tdDrillDepthArrowPoints[1],param3,param2,true),44);
         param1.endFill();
      }
      
      private function drawCenterDrillArrows(param1:Graphics, param2:Number, param3:Point) : void
      {
         if(this.cdDepthArrowPoints == null)
         {
            return;
         }
         param1.clear();
         param1.beginFill(0,1);
         GraphicsUtil.drawArrows(param1,this.calcRelativePoint(this.cdDepthArrowPoints[0],param3,param2,true),this.calcRelativePoint(this.cdDepthArrowPoints[1],param3,param2,true),20);
         param1.endFill();
      }
      
      private function drawCounterSinkArrows(param1:Graphics, param2:Number, param3:Point) : void
      {
         if(this.csDepthArrowPoints == null)
         {
            return;
         }
         param1.clear();
         param1.beginFill(0,1);
         GraphicsUtil.drawArrows(param1,this.calcRelativePoint(this.csDepthArrowPoints[0],param3,param2,true),this.calcRelativePoint(this.csDepthArrowPoints[1],param3,param2,true),15);
         GraphicsUtil.drawArrows(param1,this.calcRelativePoint(this.csTipArrowPoints[0],param3,param2,true),this.calcRelativePoint(this.csTipArrowPoints[1],param3,param2,true));
         param1.endFill();
      }
      
      private function _GWizChamferDrillCalc_ButtonBar1_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.requireSelection = true;
         _loc1_.id = "tabs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tabs = _loc1_;
         BindingManager.executeBindings(this,"tabs",this.tabs);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.bottom = 10;
         temp.right = 10;
         temp.left = 10;
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.creationPolicy = "all";
         temp.setStyle("borderAlpha",1);
         temp.setStyle("borderStyle","solid");
         temp.setStyle("borderVisible",true);
         temp.addEventListener("change",this.__tabNav_change);
         temp.id = "tabNav";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"tabNav",
            "events":{"change":"__tabNav_change"},
            "stylesFactory":function():void
            {
               this.borderAlpha = 1;
               this.borderStyle = "solid";
               this.borderVisible = true;
            },
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"CenterDrill",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Center Drill",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizChamferDrillCalc_Array2_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"SpotDrill",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Spot Drill",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizChamferDrillCalc_Array4_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"TwistDrill",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Twist Drill",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizChamferDrillCalc_Array6_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Countersink",
                  "events":{"show":"__Countersink_show"},
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Countersink",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizChamferDrillCalc_Array10_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.tabNav = temp;
         BindingManager.executeBindings(this,"tabNav",this.tabNav);
         return temp;
      }
      
      public function __tabNav_change(param1:IndexChangedEvent) : void
      {
         callLater(this.onResize);
      }
      
      private function _GWizChamferDrillCalc_Array2_c() : Array
      {
         return [this._GWizChamferDrillCalc_GridComponent1_i()];
      }
      
      private function _GWizChamferDrillCalc_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.showXAxis = false;
         _loc1_.showYAxis = false;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizChamferDrillCalc_Array3_c);
         _loc1_.setStyle("skinClass",GridSkin);
         _loc1_.id = "gridComp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridComp = _loc1_;
         BindingManager.executeBindings(this,"gridComp",this.gridComp);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Array3_c() : Array
      {
         return [this._GWizChamferDrillCalc_Image1_i(),this._GWizChamferDrillCalc_Label1_c(),this._GWizChamferDrillCalc_DropDownList1_i(),this._GWizChamferDrillCalc_Label2_c(),this._GWizChamferDrillCalc_Label3_i(),this._GWizChamferDrillCalc_Label4_c(),this._GWizChamferDrillCalc_Label5_i(),this._GWizChamferDrillCalc_Label6_c(),this._GWizChamferDrillCalc_Label7_i(),this._GWizChamferDrillCalc_Label8_i(),this._GWizChamferDrillCalc_GWizNumStep1_i(),this._GWizChamferDrillCalc_Label9_i(),this._GWizChamferDrillCalc_GWizNumStep2_i(),this._GWizChamferDrillCalc_Label10_i(),this._GWizChamferDrillCalc_Label11_i(),this._GWizChamferDrillCalc_GWizNumStep3_i(),this._GWizChamferDrillCalc_Label12_i(),this._GWizChamferDrillCalc_GWizNumStep4_i(),this._GWizChamferDrillCalc_Button1_i()];
      }
      
      private function _GWizChamferDrillCalc_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml_assets_CenterDrill_png_1992689488;
         _loc1_.top = 20;
         _loc1_.bottom = 20;
         _loc1_.left = 20;
         _loc1_.right = 20;
         _loc1_.smooth = true;
         _loc1_.id = "centerDrillImage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.centerDrillImage = _loc1_;
         BindingManager.executeBindings(this,"centerDrillImage",this.centerDrillImage);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 10;
         _loc1_.y = 10;
         _loc1_.text = "Select Center Drill";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.x = 120;
         _loc1_.y = 6;
         _loc1_.labelField = "drill";
         _loc1_.addEventListener("change",this.__drillSelector_change);
         _loc1_.id = "drillSelector";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.drillSelector = _loc1_;
         BindingManager.executeBindings(this,"drillSelector",this.drillSelector);
         return _loc1_;
      }
      
      public function __drillSelector_change(param1:IndexChangeEvent) : void
      {
         this.changeCenterDrill();
      }
      
      private function _GWizChamferDrillCalc_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 10;
         _loc1_.y = 30;
         _loc1_.text = "Body Dia.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0";
         _loc1_.x = 70;
         _loc1_.y = 30;
         _loc1_.id = "bodyDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.bodyDia = _loc1_;
         BindingManager.executeBindings(this,"bodyDia",this.bodyDia);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 10;
         _loc1_.y = 50;
         _loc1_.text = "Pilot Dia.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0";
         _loc1_.x = 70;
         _loc1_.y = 50;
         _loc1_.id = "pilotDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pilotDia = _loc1_;
         BindingManager.executeBindings(this,"pilotDia",this.pilotDia);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 10;
         _loc1_.y = 70;
         _loc1_.text = "Pilot Len.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0";
         _loc1_.x = 70;
         _loc1_.y = 70;
         _loc1_.id = "pilotLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pilotLen = _loc1_;
         BindingManager.executeBindings(this,"pilotLen",this.pilotLen);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Chamfer Diameter";
         _loc1_.id = "chamDiaLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.chamDiaLabel = _loc1_;
         BindingManager.executeBindings(this,"chamDiaLabel",this.chamDiaLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.x = 210;
         _loc1_.y = 233;
         _loc1_.steps = 0.0001;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__cdChamferDia_valueCommit);
         _loc1_.id = "cdChamferDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cdChamferDia = _loc1_;
         BindingManager.executeBindings(this,"cdChamferDia",this.cdChamferDia);
         return _loc1_;
      }
      
      public function __cdChamferDia_valueCommit(param1:FlexEvent) : void
      {
         this.changeCenterDrill();
      }
      
      private function _GWizChamferDrillCalc_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 260;
         _loc1_.y = 280;
         _loc1_.text = "Depth";
         _loc1_.id = "depthLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.depthLabel = _loc1_;
         BindingManager.executeBindings(this,"depthLabel",this.depthLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.steps = 0.0001;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__cdDrillDepth_valueCommit);
         _loc1_.id = "cdDrillDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cdDrillDepth = _loc1_;
         BindingManager.executeBindings(this,"cdDrillDepth",this.cdDrillDepth);
         return _loc1_;
      }
      
      public function __cdDrillDepth_valueCommit(param1:FlexEvent) : void
      {
         this.changeCenterDrill();
      }
      
      private function _GWizChamferDrillCalc_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 10;
         _loc1_.y = 209;
         _loc1_.text = "60° angle";
         _loc1_.id = "angleLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.angleLabel = _loc1_;
         BindingManager.executeBindings(this,"angleLabel",this.angleLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Min. Chamfer";
         _loc1_.id = "_GWizChamferDrillCalc_Label11";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChamferDrillCalc_Label11 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChamferDrillCalc_Label11",this._GWizChamferDrillCalc_Label11);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.steps = 0.0001;
         _loc1_.usesMetric = false;
         _loc1_.id = "cdMinChamfer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cdMinChamfer = _loc1_;
         BindingManager.executeBindings(this,"cdMinChamfer",this.cdMinChamfer);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label12_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max. Chamfer";
         _loc1_.id = "_GWizChamferDrillCalc_Label12";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChamferDrillCalc_Label12 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChamferDrillCalc_Label12",this._GWizChamferDrillCalc_Label12);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.steps = 0.0001;
         _loc1_.usesMetric = false;
         _loc1_.id = "cdMaxChamfer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cdMaxChamfer = _loc1_;
         BindingManager.executeBindings(this,"cdMaxChamfer",this.cdMaxChamfer);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Clear";
         _loc1_.right = 10;
         _loc1_.top = 10;
         _loc1_.addEventListener("click",this.__cdClearBtn_click);
         _loc1_.id = "cdClearBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cdClearBtn = _loc1_;
         BindingManager.executeBindings(this,"cdClearBtn",this.cdClearBtn);
         return _loc1_;
      }
      
      public function __cdClearBtn_click(param1:MouseEvent) : void
      {
         this.init();
      }
      
      private function _GWizChamferDrillCalc_Array4_c() : Array
      {
         return [this._GWizChamferDrillCalc_GridComponent2_c()];
      }
      
      private function _GWizChamferDrillCalc_GridComponent2_c() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.showXAxis = false;
         _loc1_.showYAxis = false;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizChamferDrillCalc_Array5_c);
         _loc1_.setStyle("skinClass",GridSkin);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Array5_c() : Array
      {
         return [this._GWizChamferDrillCalc_Image2_i(),this._GWizChamferDrillCalc_Label13_i(),this._GWizChamferDrillCalc_GWizNumStep5_i(),this._GWizChamferDrillCalc_Label14_i(),this._GWizChamferDrillCalc_NumericStepper1_i(),this._GWizChamferDrillCalc_Label15_i(),this._GWizChamferDrillCalc_GWizNumStep6_i(),this._GWizChamferDrillCalc_Label16_i(),this._GWizChamferDrillCalc_GWizNumStep7_i(),this._GWizChamferDrillCalc_Label17_i(),this._GWizChamferDrillCalc_GWizNumStep8_i(),this._GWizChamferDrillCalc_Label18_i(),this._GWizChamferDrillCalc_GWizNumStep9_i(),this._GWizChamferDrillCalc_Button2_i()];
      }
      
      private function _GWizChamferDrillCalc_Image2_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml_assets_SpotDrill_png_1245456670;
         _loc1_.top = 20;
         _loc1_.bottom = 20;
         _loc1_.left = 20;
         _loc1_.right = 20;
         _loc1_.smooth = true;
         _loc1_.id = "spotDrillImage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.spotDrillImage = _loc1_;
         BindingManager.executeBindings(this,"spotDrillImage",this.spotDrillImage);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label13_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Drill Diameter";
         _loc1_.id = "_GWizChamferDrillCalc_Label13";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChamferDrillCalc_Label13 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChamferDrillCalc_Label13",this._GWizChamferDrillCalc_Label13);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.x = 180;
         _loc1_.y = 34;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__sdDrillDia_valueCommit);
         _loc1_.id = "sdDrillDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdDrillDia = _loc1_;
         BindingManager.executeBindings(this,"sdDrillDia",this.sdDrillDia);
         return _loc1_;
      }
      
      public function __sdDrillDia_valueCommit(param1:FlexEvent) : void
      {
         this.changeSpotDrill();
      }
      
      private function _GWizChamferDrillCalc_Label14_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 193;
         _loc1_.y = 149;
         _loc1_.text = "Included Angle";
         _loc1_.id = "sdIncludedAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdIncludedAngle = _loc1_;
         BindingManager.executeBindings(this,"sdIncludedAngle",this.sdIncludedAngle);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.value = 90;
         _loc1_.minimum = 0;
         _loc1_.stepSize = 0.1;
         _loc1_.maximum = 180;
         _loc1_.addEventListener("change",this.__sdAngle_change);
         _loc1_.id = "sdAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdAngle = _loc1_;
         BindingManager.executeBindings(this,"sdAngle",this.sdAngle);
         return _loc1_;
      }
      
      public function __sdAngle_change(param1:Event) : void
      {
         this.changeSpotDrill();
      }
      
      private function _GWizChamferDrillCalc_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Chamfer Diameter";
         _loc1_.id = "sdChamDiaLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdChamDiaLabel = _loc1_;
         BindingManager.executeBindings(this,"sdChamDiaLabel",this.sdChamDiaLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep6_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.x = 100;
         _loc1_.y = 500;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__sdChamferDia_valueCommit);
         _loc1_.id = "sdChamferDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdChamferDia = _loc1_;
         BindingManager.executeBindings(this,"sdChamferDia",this.sdChamferDia);
         return _loc1_;
      }
      
      public function __sdChamferDia_valueCommit(param1:FlexEvent) : void
      {
         this.changeSpotDrill();
      }
      
      private function _GWizChamferDrillCalc_Label16_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 236;
         _loc1_.y = 262;
         _loc1_.text = "Depth";
         _loc1_.id = "sdDepthLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdDepthLabel = _loc1_;
         BindingManager.executeBindings(this,"sdDepthLabel",this.sdDepthLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep7_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__sdDrillDepth_valueCommit);
         _loc1_.id = "sdDrillDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdDrillDepth = _loc1_;
         BindingManager.executeBindings(this,"sdDrillDepth",this.sdDrillDepth);
         return _loc1_;
      }
      
      public function __sdDrillDepth_valueCommit(param1:FlexEvent) : void
      {
         this.changeSpotDrill();
      }
      
      private function _GWizChamferDrillCalc_Label17_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Min. Chamfer";
         _loc1_.id = "_GWizChamferDrillCalc_Label17";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChamferDrillCalc_Label17 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChamferDrillCalc_Label17",this._GWizChamferDrillCalc_Label17);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep8_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.usesMetric = false;
         _loc1_.id = "sdMinChamfer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdMinChamfer = _loc1_;
         BindingManager.executeBindings(this,"sdMinChamfer",this.sdMinChamfer);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label18_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max. Chamfer";
         _loc1_.id = "sdMaxChamferLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdMaxChamferLabel = _loc1_;
         BindingManager.executeBindings(this,"sdMaxChamferLabel",this.sdMaxChamferLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep9_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.x = 300;
         _loc1_.y = 100;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.usesMetric = false;
         _loc1_.id = "sdMaxChamfer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdMaxChamfer = _loc1_;
         BindingManager.executeBindings(this,"sdMaxChamfer",this.sdMaxChamfer);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Clear";
         _loc1_.x = 400;
         _loc1_.y = 260;
         _loc1_.right = 10;
         _loc1_.top = 10;
         _loc1_.addEventListener("click",this.__sdClearLabel_click);
         _loc1_.id = "sdClearLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sdClearLabel = _loc1_;
         BindingManager.executeBindings(this,"sdClearLabel",this.sdClearLabel);
         return _loc1_;
      }
      
      public function __sdClearLabel_click(param1:MouseEvent) : void
      {
         this.init();
      }
      
      private function _GWizChamferDrillCalc_Array6_c() : Array
      {
         return [this._GWizChamferDrillCalc_GridComponent3_i()];
      }
      
      private function _GWizChamferDrillCalc_GridComponent3_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.showXAxis = false;
         _loc1_.showYAxis = false;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizChamferDrillCalc_Array7_c);
         _loc1_.setStyle("skinClass",GridSkin);
         _loc1_.id = "tdGrid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdGrid = _loc1_;
         BindingManager.executeBindings(this,"tdGrid",this.tdGrid);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Array7_c() : Array
      {
         return [this._GWizChamferDrillCalc_Image3_i(),this._GWizChamferDrillCalc_Label19_c(),this._GWizChamferDrillCalc_Button3_c(),this._GWizChamferDrillCalc_GWizNumStep10_i(),this._GWizChamferDrillCalc_Button4_i(),this._GWizChamferDrillCalc_Label20_i(),this._GWizChamferDrillCalc_GWizNumStep11_i(),this._GWizChamferDrillCalc_Label21_i(),this._GWizChamferDrillCalc_GWizNumStep12_i(),this._GWizChamferDrillCalc_HGroup1_i()];
      }
      
      private function _GWizChamferDrillCalc_Image3_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml_assets_TwistDrill_png_1807610066;
         _loc1_.top = 20;
         _loc1_.bottom = 20;
         _loc1_.left = 20;
         _loc1_.right = 20;
         _loc1_.smooth = true;
         _loc1_.id = "twistDrillImage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.twistDrillImage = _loc1_;
         BindingManager.executeBindings(this,"twistDrillImage",this.twistDrillImage);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label19_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.left = 10;
         _loc1_.top = 10;
         _loc1_.text = "Enter Diameter and Angle and either depth.";
         _loc1_.setStyle("color",2237064);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Button3_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Clear";
         _loc1_.right = 10;
         _loc1_.top = 10;
         _loc1_.width = 83;
         _loc1_.addEventListener("click",this.___GWizChamferDrillCalc_Button3_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizChamferDrillCalc_Button3_click(param1:MouseEvent) : void
      {
         this.init();
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep10_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.x = 308;
         _loc1_.y = 75;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.usesMetric = false;
         _loc1_.titleTxt = "Diameter";
         _loc1_.addEventListener("valueCommit",this.__tdDia_valueCommit);
         _loc1_.id = "tdDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdDia = _loc1_;
         BindingManager.executeBindings(this,"tdDia",this.tdDia);
         return _loc1_;
      }
      
      public function __tdDia_valueCommit(param1:FlexEvent) : void
      {
         this.changeTwistDrill();
      }
      
      private function _GWizChamferDrillCalc_Button4_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Drill Chart";
         _loc1_.addEventListener("click",this.___GWizChamferDrillCalc_Button4_click);
         _loc1_.id = "_GWizChamferDrillCalc_Button4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChamferDrillCalc_Button4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChamferDrillCalc_Button4",this._GWizChamferDrillCalc_Button4);
         return _loc1_;
      }
      
      public function ___GWizChamferDrillCalc_Button4_click(param1:MouseEvent) : void
      {
         this.showDrillPicker();
      }
      
      private function _GWizChamferDrillCalc_Label20_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole Depth";
         _loc1_.id = "tdHoleDepthLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdHoleDepthLabel = _loc1_;
         BindingManager.executeBindings(this,"tdHoleDepthLabel",this.tdHoleDepthLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep11_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__tdHoleDepth_valueCommit);
         _loc1_.id = "tdHoleDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdHoleDepth = _loc1_;
         BindingManager.executeBindings(this,"tdHoleDepth",this.tdHoleDepth);
         return _loc1_;
      }
      
      public function __tdHoleDepth_valueCommit(param1:FlexEvent) : void
      {
         this.changeTwistDrill();
      }
      
      private function _GWizChamferDrillCalc_Label21_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Drill Depth";
         _loc1_.id = "tdDrillDepthLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdDrillDepthLabel = _loc1_;
         BindingManager.executeBindings(this,"tdDrillDepthLabel",this.tdDrillDepthLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep12_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__tdDrillDepth_valueCommit);
         _loc1_.id = "tdDrillDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdDrillDepth = _loc1_;
         BindingManager.executeBindings(this,"tdDrillDepth",this.tdDrillDepth);
         return _loc1_;
      }
      
      public function __tdDrillDepth_valueCommit(param1:FlexEvent) : void
      {
         this.changeTwistDrill();
      }
      
      private function _GWizChamferDrillCalc_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizChamferDrillCalc_Label22_c(),this._GWizChamferDrillCalc_NumericStepper2_i(),this._GWizChamferDrillCalc_DropDownList2_i()];
         _loc1_.id = "tdAngleGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdAngleGroup = _loc1_;
         BindingManager.executeBindings(this,"tdAngleGroup",this.tdAngleGroup);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label22_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Drill Angle:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.value = 118;
         _loc1_.minimum = 0;
         _loc1_.maximum = 180;
         _loc1_.stepSize = 0.1;
         _loc1_.addEventListener("change",this.__tdAngle_change);
         _loc1_.id = "tdAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdAngle = _loc1_;
         BindingManager.executeBindings(this,"tdAngle",this.tdAngle);
         return _loc1_;
      }
      
      public function __tdAngle_change(param1:Event) : void
      {
         this.TwistAngle.selectedIndex = 0;
         this.changeTwistDrill();
      }
      
      private function _GWizChamferDrillCalc_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 120;
         _loc1_.selectedIndex = 2;
         _loc1_.dataProvider = this._GWizChamferDrillCalc_ArrayList1_c();
         _loc1_.addEventListener("valueCommit",this.__TwistAngle_valueCommit);
         _loc1_.id = "TwistAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TwistAngle = _loc1_;
         BindingManager.executeBindings(this,"TwistAngle",this.TwistAngle);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [{
            "label":"Custom",
            "data":-1
         },{
            "label":90,
            "data":90
         },{
            "label":118,
            "data":118
         },{
            "label":135,
            "data":135
         }];
         return _loc1_;
      }
      
      public function __TwistAngle_valueCommit(param1:FlexEvent) : void
      {
         this.doTwistAngle();
      }
      
      private function _GWizChamferDrillCalc_Array10_c() : Array
      {
         return [this._GWizChamferDrillCalc_GridComponent4_c()];
      }
      
      private function _GWizChamferDrillCalc_GridComponent4_c() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.showXAxis = false;
         _loc1_.showYAxis = false;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizChamferDrillCalc_Array11_c);
         _loc1_.setStyle("skinClass",GridSkin);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Array11_c() : Array
      {
         return [this._GWizChamferDrillCalc_Image4_i(),this._GWizChamferDrillCalc_Label23_c(),this._GWizChamferDrillCalc_Label24_i(),this._GWizChamferDrillCalc_NumericStepper3_i(),this._GWizChamferDrillCalc_Label25_i(),this._GWizChamferDrillCalc_GWizNumStep13_i(),this._GWizChamferDrillCalc_Label26_i(),this._GWizChamferDrillCalc_GWizNumStep14_i(),this._GWizChamferDrillCalc_Label27_i(),this._GWizChamferDrillCalc_GWizNumStep15_i(),this._GWizChamferDrillCalc_Button5_c()];
      }
      
      private function _GWizChamferDrillCalc_Image4_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml_assets_Countersink_png_2012612414;
         _loc1_.top = 20;
         _loc1_.bottom = 20;
         _loc1_.left = 20;
         _loc1_.right = 20;
         _loc1_.smooth = true;
         _loc1_.id = "counterSinkImage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.counterSinkImage = _loc1_;
         BindingManager.executeBindings(this,"counterSinkImage",this.counterSinkImage);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label23_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.left = 10;
         _loc1_.top = 10;
         _loc1_.text = "Enter Angle and either Diameter or Depth";
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("color",2237064);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_Label24_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Included Angle";
         _loc1_.id = "_GWizChamferDrillCalc_Label24";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChamferDrillCalc_Label24 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChamferDrillCalc_Label24",this._GWizChamferDrillCalc_Label24);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_NumericStepper3_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.value = 60;
         _loc1_.minimum = 0;
         _loc1_.maximum = 360;
         _loc1_.stepSize = 0.1;
         _loc1_.addEventListener("valueCommit",this.__csAngle_valueCommit);
         _loc1_.id = "csAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.csAngle = _loc1_;
         BindingManager.executeBindings(this,"csAngle",this.csAngle);
         return _loc1_;
      }
      
      public function __csAngle_valueCommit(param1:FlexEvent) : void
      {
         this.changeCountersink();
      }
      
      private function _GWizChamferDrillCalc_Label25_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Chamfer Diameter";
         _loc1_.id = "csChamDiaLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.csChamDiaLabel = _loc1_;
         BindingManager.executeBindings(this,"csChamDiaLabel",this.csChamDiaLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep13_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.usesMetric = false;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.addEventListener("valueCommit",this.__csDia_valueCommit);
         _loc1_.id = "csDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.csDia = _loc1_;
         BindingManager.executeBindings(this,"csDia",this.csDia);
         return _loc1_;
      }
      
      public function __csDia_valueCommit(param1:FlexEvent) : void
      {
         this.changeCountersink();
      }
      
      private function _GWizChamferDrillCalc_Label26_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Depth";
         _loc1_.id = "csDepthLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.csDepthLabel = _loc1_;
         BindingManager.executeBindings(this,"csDepthLabel",this.csDepthLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep14_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.usesMetric = false;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.addEventListener("valueCommit",this.__csDepth_valueCommit);
         _loc1_.id = "csDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.csDepth = _loc1_;
         BindingManager.executeBindings(this,"csDepth",this.csDepth);
         return _loc1_;
      }
      
      public function __csDepth_valueCommit(param1:FlexEvent) : void
      {
         this.changeCountersink();
      }
      
      private function _GWizChamferDrillCalc_Label27_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tip Diameter";
         _loc1_.id = "csTipDiaLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.csTipDiaLabel = _loc1_;
         BindingManager.executeBindings(this,"csTipDiaLabel",this.csTipDiaLabel);
         return _loc1_;
      }
      
      private function _GWizChamferDrillCalc_GWizNumStep15_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.usesMetric = false;
         _loc1_.hideLabel = true;
         _loc1_.fatSpacer = false;
         _loc1_.addEventListener("valueCommit",this.__csTipDia_valueCommit);
         _loc1_.id = "csTipDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.csTipDia = _loc1_;
         BindingManager.executeBindings(this,"csTipDia",this.csTipDia);
         return _loc1_;
      }
      
      public function __csTipDia_valueCommit(param1:FlexEvent) : void
      {
         this.changeCountersink();
      }
      
      private function _GWizChamferDrillCalc_Button5_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Clear";
         _loc1_.right = 10;
         _loc1_.top = 10;
         _loc1_.addEventListener("click",this.___GWizChamferDrillCalc_Button5_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizChamferDrillCalc_Button5_click(param1:MouseEvent) : void
      {
         this.init();
      }
      
      public function __Countersink_show(param1:FlexEvent) : void
      {
         this.onResize();
      }
      
      public function ___GWizChamferDrillCalc_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.callLater(this.init);
      }
      
      public function ___GWizChamferDrillCalc_VGroup1_show(param1:FlexEvent) : void
      {
         this.checkUnits();
      }
      
      public function ___GWizChamferDrillCalc_VGroup1_resize(param1:ResizeEvent) : void
      {
         callLater(this.onResize);
      }
      
      private function _GWizChamferDrillCalc_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"tabs.dataProvider","tabNav");
         result[1] = new Binding(this,function():Object
         {
            return tabs.height + 8;
         },null,"tabNav.top");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.gray4;
         },function(param1:uint):void
         {
            tabNav.setStyle("borderColor",param1);
         },"tabNav.borderColor");
         result[3] = new Binding(this,function():IList
         {
            return GWizConfigData.CenterDrillList;
         },null,"drillSelector.dataProvider");
         result[4] = new Binding(this,function():Number
         {
            return cdChamferDia.x;
         },null,"chamDiaLabel.x");
         result[5] = new Binding(this,function():Number
         {
            return cdChamferDia.y - 13;
         },null,"chamDiaLabel.y");
         result[6] = new Binding(this,function():Number
         {
            return depthLabel.x + depthLabel.width + 5;
         },null,"cdDrillDepth.x");
         result[7] = new Binding(this,function():Number
         {
            return depthLabel.y - 6;
         },null,"cdDrillDepth.y");
         result[8] = new Binding(this,function():Number
         {
            return chamDiaLabel.x;
         },null,"_GWizChamferDrillCalc_Label11.x");
         result[9] = new Binding(this,function():Number
         {
            return chamDiaLabel.y - 100;
         },null,"_GWizChamferDrillCalc_Label11.y");
         result[10] = new Binding(this,function():Number
         {
            return chamDiaLabel.x + 80;
         },null,"cdMinChamfer.x");
         result[11] = new Binding(this,function():Number
         {
            return chamDiaLabel.y - 106;
         },null,"cdMinChamfer.y");
         result[12] = new Binding(this,function():Number
         {
            return chamDiaLabel.x;
         },null,"_GWizChamferDrillCalc_Label12.x");
         result[13] = new Binding(this,function():Number
         {
            return chamDiaLabel.y - 70;
         },null,"_GWizChamferDrillCalc_Label12.y");
         result[14] = new Binding(this,function():Number
         {
            return chamDiaLabel.x + 80;
         },null,"cdMaxChamfer.x");
         result[15] = new Binding(this,function():Number
         {
            return chamDiaLabel.y - 76;
         },null,"cdMaxChamfer.y");
         result[16] = new Binding(this,function():Number
         {
            return sdDrillDia.x;
         },null,"_GWizChamferDrillCalc_Label13.x");
         result[17] = new Binding(this,function():Number
         {
            return sdDrillDia.y - 13;
         },null,"_GWizChamferDrillCalc_Label13.y");
         result[18] = new Binding(this,function():Number
         {
            return sdIncludedAngle.x;
         },null,"sdAngle.x");
         result[19] = new Binding(this,function():Number
         {
            return sdIncludedAngle.y + 13;
         },null,"sdAngle.y");
         result[20] = new Binding(this,function():Number
         {
            return sdChamferDia.x;
         },null,"sdChamDiaLabel.x");
         result[21] = new Binding(this,function():Number
         {
            return sdChamferDia.y - 18;
         },null,"sdChamDiaLabel.y");
         result[22] = new Binding(this,function():Number
         {
            return sdDepthLabel.x;
         },null,"sdDrillDepth.x");
         result[23] = new Binding(this,function():Number
         {
            return sdDepthLabel.y + 13;
         },null,"sdDrillDepth.y");
         result[24] = new Binding(this,function():Number
         {
            return sdMaxChamfer.x;
         },null,"_GWizChamferDrillCalc_Label17.x");
         result[25] = new Binding(this,function():Number
         {
            return sdMaxChamfer.y - 58;
         },null,"_GWizChamferDrillCalc_Label17.y");
         result[26] = new Binding(this,function():Number
         {
            return sdMaxChamfer.x;
         },null,"sdMinChamfer.x");
         result[27] = new Binding(this,function():Number
         {
            return sdMaxChamfer.y - 45;
         },null,"sdMinChamfer.y");
         result[28] = new Binding(this,function():Number
         {
            return sdMaxChamfer.x;
         },null,"sdMaxChamferLabel.x");
         result[29] = new Binding(this,function():Number
         {
            return sdMaxChamfer.y - 13;
         },null,"sdMaxChamferLabel.y");
         result[30] = new Binding(this,function():Number
         {
            return tdDia.x + tdDia.stepperGroup.x;
         },null,"_GWizChamferDrillCalc_Button4.x");
         result[31] = new Binding(this,function():Number
         {
            return tdDia.y + 28;
         },null,"_GWizChamferDrillCalc_Button4.y");
         result[32] = new Binding(this,function():Number
         {
            return tdHoleDepth.x;
         },null,"tdHoleDepthLabel.x");
         result[33] = new Binding(this,function():Number
         {
            return tdHoleDepth.y - 13;
         },null,"tdHoleDepthLabel.y");
         result[34] = new Binding(this,function():Number
         {
            return tdDrillDepthLabel.x;
         },null,"tdDrillDepth.x");
         result[35] = new Binding(this,function():Number
         {
            return tdDrillDepthLabel.y + 13;
         },null,"tdDrillDepth.y");
         result[36] = new Binding(this,function():Number
         {
            return csAngle.x;
         },null,"_GWizChamferDrillCalc_Label24.x");
         result[37] = new Binding(this,function():Number
         {
            return csAngle.y - 13;
         },null,"_GWizChamferDrillCalc_Label24.y");
         result[38] = new Binding(this,function():Number
         {
            return csDia.x;
         },null,"csChamDiaLabel.x");
         result[39] = new Binding(this,function():Number
         {
            return csDia.y - 13;
         },null,"csChamDiaLabel.y");
         result[40] = new Binding(this,function():Number
         {
            return csDepthLabel.x + csDepthLabel.width + 5;
         },null,"csDepth.x");
         result[41] = new Binding(this,function():Number
         {
            return csDepthLabel.y - 6;
         },null,"csDepth.y");
         result[42] = new Binding(this,function():Number
         {
            return csTipDiaLabel.x;
         },null,"csTipDia.x");
         result[43] = new Binding(this,function():Number
         {
            return csTipDiaLabel.y + 13;
         },null,"csTipDia.y");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CenterDrill() : NavigatorContent
      {
         return this._980029210CenterDrill;
      }
      
      public function set CenterDrill(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._980029210CenterDrill;
         if(_loc2_ !== param1)
         {
            this._980029210CenterDrill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CenterDrill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Countersink() : NavigatorContent
      {
         return this._186417553Countersink;
      }
      
      public function set Countersink(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._186417553Countersink;
         if(_loc2_ !== param1)
         {
            this._186417553Countersink = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Countersink",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SpotDrill() : NavigatorContent
      {
         return this._1047339097SpotDrill;
      }
      
      public function set SpotDrill(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1047339097SpotDrill;
         if(_loc2_ !== param1)
         {
            this._1047339097SpotDrill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SpotDrill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TwistAngle() : DropDownList
      {
         return this._1013607948TwistAngle;
      }
      
      public function set TwistAngle(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1013607948TwistAngle;
         if(_loc2_ !== param1)
         {
            this._1013607948TwistAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TwistAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TwistDrill() : NavigatorContent
      {
         return this._1016499604TwistDrill;
      }
      
      public function set TwistDrill(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1016499604TwistDrill;
         if(_loc2_ !== param1)
         {
            this._1016499604TwistDrill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TwistDrill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get angleLabel() : Label
      {
         return this._313237985angleLabel;
      }
      
      public function set angleLabel(param1:Label) : void
      {
         var _loc2_:Object = this._313237985angleLabel;
         if(_loc2_ !== param1)
         {
            this._313237985angleLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"angleLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get bodyDia() : Label
      {
         return this._54908794bodyDia;
      }
      
      public function set bodyDia(param1:Label) : void
      {
         var _loc2_:Object = this._54908794bodyDia;
         if(_loc2_ !== param1)
         {
            this._54908794bodyDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bodyDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cdChamferDia() : GWizNumStep
      {
         return this._465950277cdChamferDia;
      }
      
      public function set cdChamferDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._465950277cdChamferDia;
         if(_loc2_ !== param1)
         {
            this._465950277cdChamferDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cdChamferDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cdClearBtn() : Button
      {
         return this._1776873392cdClearBtn;
      }
      
      public function set cdClearBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1776873392cdClearBtn;
         if(_loc2_ !== param1)
         {
            this._1776873392cdClearBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cdClearBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cdDrillDepth() : GWizNumStep
      {
         return this._1246108055cdDrillDepth;
      }
      
      public function set cdDrillDepth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1246108055cdDrillDepth;
         if(_loc2_ !== param1)
         {
            this._1246108055cdDrillDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cdDrillDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cdMaxChamfer() : GWizNumStep
      {
         return this._199124959cdMaxChamfer;
      }
      
      public function set cdMaxChamfer(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._199124959cdMaxChamfer;
         if(_loc2_ !== param1)
         {
            this._199124959cdMaxChamfer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cdMaxChamfer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cdMinChamfer() : GWizNumStep
      {
         return this._1623843023cdMinChamfer;
      }
      
      public function set cdMinChamfer(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1623843023cdMinChamfer;
         if(_loc2_ !== param1)
         {
            this._1623843023cdMinChamfer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cdMinChamfer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get centerDrillImage() : Image
      {
         return this._1181867019centerDrillImage;
      }
      
      public function set centerDrillImage(param1:Image) : void
      {
         var _loc2_:Object = this._1181867019centerDrillImage;
         if(_loc2_ !== param1)
         {
            this._1181867019centerDrillImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"centerDrillImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get chamDiaLabel() : Label
      {
         return this._464752201chamDiaLabel;
      }
      
      public function set chamDiaLabel(param1:Label) : void
      {
         var _loc2_:Object = this._464752201chamDiaLabel;
         if(_loc2_ !== param1)
         {
            this._464752201chamDiaLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"chamDiaLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get counterSinkImage() : Image
      {
         return this._250266604counterSinkImage;
      }
      
      public function set counterSinkImage(param1:Image) : void
      {
         var _loc2_:Object = this._250266604counterSinkImage;
         if(_loc2_ !== param1)
         {
            this._250266604counterSinkImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"counterSinkImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get csAngle() : NumericStepper
      {
         return this._1024311875csAngle;
      }
      
      public function set csAngle(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1024311875csAngle;
         if(_loc2_ !== param1)
         {
            this._1024311875csAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"csAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get csChamDiaLabel() : Label
      {
         return this._1558198567csChamDiaLabel;
      }
      
      public function set csChamDiaLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1558198567csChamDiaLabel;
         if(_loc2_ !== param1)
         {
            this._1558198567csChamDiaLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"csChamDiaLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get csDepth() : GWizNumStep
      {
         return this._1026823219csDepth;
      }
      
      public function set csDepth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1026823219csDepth;
         if(_loc2_ !== param1)
         {
            this._1026823219csDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"csDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get csDepthLabel() : Label
      {
         return this._1604067969csDepthLabel;
      }
      
      public function set csDepthLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1604067969csDepthLabel;
         if(_loc2_ !== param1)
         {
            this._1604067969csDepthLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"csDepthLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get csDia() : GWizNumStep
      {
         return this._94923244csDia;
      }
      
      public function set csDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._94923244csDia;
         if(_loc2_ !== param1)
         {
            this._94923244csDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"csDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get csTipDia() : GWizNumStep
      {
         return this._2066504079csTipDia;
      }
      
      public function set csTipDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2066504079csTipDia;
         if(_loc2_ !== param1)
         {
            this._2066504079csTipDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"csTipDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get csTipDiaLabel() : Label
      {
         return this._1867233533csTipDiaLabel;
      }
      
      public function set csTipDiaLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1867233533csTipDiaLabel;
         if(_loc2_ !== param1)
         {
            this._1867233533csTipDiaLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"csTipDiaLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get depthLabel() : Label
      {
         return this._207291889depthLabel;
      }
      
      public function set depthLabel(param1:Label) : void
      {
         var _loc2_:Object = this._207291889depthLabel;
         if(_loc2_ !== param1)
         {
            this._207291889depthLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"depthLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get drillSelector() : DropDownList
      {
         return this._1865259686drillSelector;
      }
      
      public function set drillSelector(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1865259686drillSelector;
         if(_loc2_ !== param1)
         {
            this._1865259686drillSelector = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"drillSelector",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gridComp() : GridComponent
      {
         return this._317561717gridComp;
      }
      
      public function set gridComp(param1:GridComponent) : void
      {
         var _loc2_:Object = this._317561717gridComp;
         if(_loc2_ !== param1)
         {
            this._317561717gridComp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gridComp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pilotDia() : Label
      {
         return this._477148508pilotDia;
      }
      
      public function set pilotDia(param1:Label) : void
      {
         var _loc2_:Object = this._477148508pilotDia;
         if(_loc2_ !== param1)
         {
            this._477148508pilotDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pilotDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pilotLen() : Label
      {
         return this._477140931pilotLen;
      }
      
      public function set pilotLen(param1:Label) : void
      {
         var _loc2_:Object = this._477140931pilotLen;
         if(_loc2_ !== param1)
         {
            this._477140931pilotLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pilotLen",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdAngle() : NumericStepper
      {
         return this._1910031618sdAngle;
      }
      
      public function set sdAngle(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1910031618sdAngle;
         if(_loc2_ !== param1)
         {
            this._1910031618sdAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdChamDiaLabel() : Label
      {
         return this._951124166sdChamDiaLabel;
      }
      
      public function set sdChamDiaLabel(param1:Label) : void
      {
         var _loc2_:Object = this._951124166sdChamDiaLabel;
         if(_loc2_ !== param1)
         {
            this._951124166sdChamDiaLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdChamDiaLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdChamferDia() : GWizNumStep
      {
         return this._1599373227sdChamferDia;
      }
      
      public function set sdChamferDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1599373227sdChamferDia;
         if(_loc2_ !== param1)
         {
            this._1599373227sdChamferDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdChamferDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdClearLabel() : Button
      {
         return this._399328808sdClearLabel;
      }
      
      public function set sdClearLabel(param1:Button) : void
      {
         var _loc2_:Object = this._399328808sdClearLabel;
         if(_loc2_ !== param1)
         {
            this._399328808sdClearLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdClearLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdDepthLabel() : Label
      {
         return this._558890786sdDepthLabel;
      }
      
      public function set sdDepthLabel(param1:Label) : void
      {
         var _loc2_:Object = this._558890786sdDepthLabel;
         if(_loc2_ !== param1)
         {
            this._558890786sdDepthLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdDepthLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdDrillDepth() : GWizNumStep
      {
         return this._819215449sdDrillDepth;
      }
      
      public function set sdDrillDepth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._819215449sdDrillDepth;
         if(_loc2_ !== param1)
         {
            this._819215449sdDrillDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdDrillDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdDrillDia() : GWizNumStep
      {
         return this._2023726190sdDrillDia;
      }
      
      public function set sdDrillDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2023726190sdDrillDia;
         if(_loc2_ !== param1)
         {
            this._2023726190sdDrillDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdDrillDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdIncludedAngle() : Label
      {
         return this._1909459622sdIncludedAngle;
      }
      
      public function set sdIncludedAngle(param1:Label) : void
      {
         var _loc2_:Object = this._1909459622sdIncludedAngle;
         if(_loc2_ !== param1)
         {
            this._1909459622sdIncludedAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdIncludedAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdMaxChamfer() : GWizNumStep
      {
         return this._2030518833sdMaxChamfer;
      }
      
      public function set sdMaxChamfer(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2030518833sdMaxChamfer;
         if(_loc2_ !== param1)
         {
            this._2030518833sdMaxChamfer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdMaxChamfer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdMaxChamferLabel() : Label
      {
         return this._41084315sdMaxChamferLabel;
      }
      
      public function set sdMaxChamferLabel(param1:Label) : void
      {
         var _loc2_:Object = this._41084315sdMaxChamferLabel;
         if(_loc2_ !== param1)
         {
            this._41084315sdMaxChamferLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdMaxChamferLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sdMinChamfer() : GWizNumStep
      {
         return this._441480481sdMinChamfer;
      }
      
      public function set sdMinChamfer(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._441480481sdMinChamfer;
         if(_loc2_ !== param1)
         {
            this._441480481sdMinChamfer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sdMinChamfer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get spotDrillImage() : Image
      {
         return this._815209570spotDrillImage;
      }
      
      public function set spotDrillImage(param1:Image) : void
      {
         var _loc2_:Object = this._815209570spotDrillImage;
         if(_loc2_ !== param1)
         {
            this._815209570spotDrillImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"spotDrillImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tabNav() : ViewStack
      {
         return this._881406642tabNav;
      }
      
      public function set tabNav(param1:ViewStack) : void
      {
         var _loc2_:Object = this._881406642tabNav;
         if(_loc2_ !== param1)
         {
            this._881406642tabNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tabNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tabs() : ButtonBar
      {
         return this._3552126tabs;
      }
      
      public function set tabs(param1:ButtonBar) : void
      {
         var _loc2_:Object = this._3552126tabs;
         if(_loc2_ !== param1)
         {
            this._3552126tabs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tabs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdAngle() : NumericStepper
      {
         return this._1497431997tdAngle;
      }
      
      public function set tdAngle(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1497431997tdAngle;
         if(_loc2_ !== param1)
         {
            this._1497431997tdAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdAngleGroup() : HGroup
      {
         return this._789821436tdAngleGroup;
      }
      
      public function set tdAngleGroup(param1:HGroup) : void
      {
         var _loc2_:Object = this._789821436tdAngleGroup;
         if(_loc2_ !== param1)
         {
            this._789821436tdAngleGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdAngleGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdDia() : GWizNumStep
      {
         return this._110176236tdDia;
      }
      
      public function set tdDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._110176236tdDia;
         if(_loc2_ !== param1)
         {
            this._110176236tdDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdDrillDepth() : GWizNumStep
      {
         return this._948298168tdDrillDepth;
      }
      
      public function set tdDrillDepth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._948298168tdDrillDepth;
         if(_loc2_ !== param1)
         {
            this._948298168tdDrillDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdDrillDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdDrillDepthLabel() : Label
      {
         return this._2091450340tdDrillDepthLabel;
      }
      
      public function set tdDrillDepthLabel(param1:Label) : void
      {
         var _loc2_:Object = this._2091450340tdDrillDepthLabel;
         if(_loc2_ !== param1)
         {
            this._2091450340tdDrillDepthLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdDrillDepthLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdGrid() : GridComponent
      {
         return this._879405610tdGrid;
      }
      
      public function set tdGrid(param1:GridComponent) : void
      {
         var _loc2_:Object = this._879405610tdGrid;
         if(_loc2_ !== param1)
         {
            this._879405610tdGrid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdGrid",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdHoleDepth() : GWizNumStep
      {
         return this._1550111405tdHoleDepth;
      }
      
      public function set tdHoleDepth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1550111405tdHoleDepth;
         if(_loc2_ !== param1)
         {
            this._1550111405tdHoleDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdHoleDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdHoleDepthLabel() : Label
      {
         return this._1051214495tdHoleDepthLabel;
      }
      
      public function set tdHoleDepthLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1051214495tdHoleDepthLabel;
         if(_loc2_ !== param1)
         {
            this._1051214495tdHoleDepthLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdHoleDepthLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get twistDrillImage() : Image
      {
         return this._145477703twistDrillImage;
      }
      
      public function set twistDrillImage(param1:Image) : void
      {
         var _loc2_:Object = this._145477703twistDrillImage;
         if(_loc2_ !== param1)
         {
            this._145477703twistDrillImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"twistDrillImage",_loc2_,param1));
            }
         }
      }
   }
}
