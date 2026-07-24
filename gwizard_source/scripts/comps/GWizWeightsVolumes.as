package comps
{
   import cadcamwiz.GWizCCWEstRecord;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import login.GWizLoginBar;
   import material.GWizMaterialChooser;
   import material.GWizMaterialsDB;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.core.IVisualElement;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.events.ResizeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.states.SetProperty;
   import mx.states.SetStyle;
   import mx.states.State;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.List;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import spark.layouts.HorizontalLayout;
   import spark.layouts.VerticalLayout;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizWeightsVolumes extends Group implements IBindingClient, IStateClient2
   {
      
      private static const log:ILogger = Log.getLogger("GWizWeightsVolumes");
      
      private static var gotMarkup:Boolean = false;
      
      private static var _1675036953MaterialShapes:ArrayCollection = new ArrayCollection([{"name":"Pipe"},{"name":"Channel"},{"name":"Angle"},{"name":"I-Beam"},{"name":"Rectangular"},{"name":"Round"},{"name":"Hex"},{"name":"Round Tube"},{"name":"Square Tube"},{"name":"Sphere"}]);
      
      private static var _795868523appIsEstimator:Boolean;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _669510880CustCost:Label;
      
      private var _295364860CustUnitCost:Label;
      
      private var _1036247284DensityLabel:Label;
      
      private var _1027001975DensityValue:Label;
      
      private var _1081513051DescEdit:CheckBox;
      
      private var _56677412Description:TextArea;
      
      private var _148082300DimPanel:VGroup;
      
      private var _570858376FabSize:List;
      
      private var _2018597731GetGauge:Button;
      
      private var _1686606623GetLumber:Button;
      
      private var _363710791Material:GWizMaterialChooser;
      
      private var _1253774909PartsPer:GWizNumStep;
      
      private var _1253776342PartsQty:GWizNumStep;
      
      private var _1022989412StockReqd:Label;
      
      private var _707459912StockReqdLabel:Label;
      
      private var _1685979752TWeightLabel:Label;
      
      private var _1426185489TotalCost:Label;
      
      private var _1032728252TotalWeight:Label;
      
      private var _858156714UVolLabel:Label;
      
      private var _1815062471UWeightLabel:Label;
      
      private var _228524143UnitCost:Label;
      
      private var _24619554UnitVolume:Label;
      
      private var _5328580UnitWeight:Label;
      
      private var _1861957547_GWizWeightsVolumes_GWizForePanel1:GWizForePanel;
      
      private var _1861957550_GWizWeightsVolumes_GWizForePanel4:GWizForePanel;
      
      private var _519963948_GWizWeightsVolumes_Group2:Group;
      
      public var _GWizWeightsVolumes_HGroup16:HGroup;
      
      public var _GWizWeightsVolumes_Label1:Label;
      
      private var _260185223_GWizWeightsVolumes_VGroup1:VGroup;
      
      private var _1354630262costWt:GWizNumStep;
      
      private var _1081305560markup:GWizNumStep;
      
      private var _2108440531materialParentPanel:GWizForePanel;
      
      private var _676559112typeList:ArrayList;
      
      private var _2036789959typeSelector:List;
      
      private var _114810uIn:GWizNumStep;
      
      private var _112084677wFeet:CheckBox;
      
      private var _116732wIn:GWizNumStep;
      
      private var _113008198xFeet:CheckBox;
      
      private var _117693xIn:GWizNumStep;
      
      private var _113931719yFeet:CheckBox;
      
      private var _118654yIn:GWizNumStep;
      
      private var _114855240zFeet:CheckBox;
      
      private var _119615zIn:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var opPickerAPI:GWizEstOpPickerAPI;
      
      public var titleLabel:String = "Material";
      
      private var currType:String = "Channel";
      
      private var tempFabPanel:IVisualElement = null;
      
      private var lastFabSize:int = -1;
      
      private var restoreViewDataDone:Boolean = false;
      
      private var fabPanelVisible:Boolean = true;
      
      private var lbsPerFoot:Number = 0.0;
      
      private var recalcOK:Boolean = false;
      
      private var custCostOpRate:Number = 0.0;
      
      private var custCostUnitOpRate:Number = 0.0;
      
      private var _embed_mxml__assets_TubeStock_jpg_1245505390:Class;
      
      private var _embed_mxml__assets_PlateStock_jpg_1581614640:Class;
      
      private var _embed_mxml__assets_SphereStock_jpg_856838288:Class;
      
      private var _embed_mxml__assets_HexStock_jpg_992691622:Class;
      
      private var _embed_mxml__assets_ChannelStock_jpg_81215990:Class;
      
      private var _embed_mxml__assets_SquareTubeStock_jpg_1971289328:Class;
      
      private var _embed_mxml__assets_RoundStock_jpg_1027981824:Class;
      
      private var _embed_mxml__assets_AngleStock_jpg_1584305782:Class;
      
      private var _embed_mxml__assets_IBeamStock_jpg_1499665132:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizWeightsVolumes()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.opPickerAPI = new GWizEstOpPickerAPI(this.UIToOp,this.OpToUI);
         this._embed_mxml__assets_TubeStock_jpg_1245505390 = GWizWeightsVolumes__embed_mxml__assets_TubeStock_jpg_1245505390;
         this._embed_mxml__assets_PlateStock_jpg_1581614640 = GWizWeightsVolumes__embed_mxml__assets_PlateStock_jpg_1581614640;
         this._embed_mxml__assets_SphereStock_jpg_856838288 = GWizWeightsVolumes__embed_mxml__assets_SphereStock_jpg_856838288;
         this._embed_mxml__assets_HexStock_jpg_992691622 = GWizWeightsVolumes__embed_mxml__assets_HexStock_jpg_992691622;
         this._embed_mxml__assets_ChannelStock_jpg_81215990 = GWizWeightsVolumes__embed_mxml__assets_ChannelStock_jpg_81215990;
         this._embed_mxml__assets_SquareTubeStock_jpg_1971289328 = GWizWeightsVolumes__embed_mxml__assets_SquareTubeStock_jpg_1971289328;
         this._embed_mxml__assets_RoundStock_jpg_1027981824 = GWizWeightsVolumes__embed_mxml__assets_RoundStock_jpg_1027981824;
         this._embed_mxml__assets_AngleStock_jpg_1584305782 = GWizWeightsVolumes__embed_mxml__assets_AngleStock_jpg_1584305782;
         this._embed_mxml__assets_IBeamStock_jpg_1499665132 = GWizWeightsVolumes__embed_mxml__assets_IBeamStock_jpg_1499665132;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizWeightsVolumes_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizWeightsVolumesWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizWeightsVolumes[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.styleName = "refView";
         this.mxmlContent = [this._GWizWeightsVolumes_GWizForePanel1_i(),this._GWizWeightsVolumes_Group2_i()];
         this.currentState = "portrait";
         this.addEventListener("creationComplete",this.___GWizWeightsVolumes_Group1_creationComplete);
         this.addEventListener("resize",this.___GWizWeightsVolumes_Group1_resize);
         this.addEventListener("click",this.___GWizWeightsVolumes_Group1_click);
         this.addEventListener("keyUp",this.___GWizWeightsVolumes_Group1_keyUp);
         states = [new State({
            "name":"portrait",
            "overrides":[new SetProperty().initializeFromObject({
               "name":"layout",
               "value":this._GWizWeightsVolumes_HorizontalLayout1_c()
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_GWizForePanel1",
               "name":"percentHeight",
               "value":100
            }),new SetStyle().initializeFromObject({
               "target":"typeSelector",
               "name":"horizontalScrollPolicy",
               "value":"off"
            }),new SetProperty().initializeFromObject({
               "target":"typeSelector",
               "name":"layout",
               "value":this._GWizWeightsVolumes_VerticalLayout3_c()
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_Group2",
               "name":"layout",
               "value":this._GWizWeightsVolumes_VerticalLayout4_c()
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_VGroup1",
               "name":"percentHeight",
               "value":40
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_VGroup1",
               "name":"percentWidth",
               "value":100
            }),new SetProperty().initializeFromObject({
               "target":"materialParentPanel",
               "name":"layout",
               "value":this._GWizWeightsVolumes_HorizontalLayout4_c()
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_GWizForePanel4",
               "name":"percentWidth",
               "value":100
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_GWizForePanel4",
               "name":"percentHeight",
               "value":25
            })]
         }),new State({
            "name":"landscape",
            "overrides":[new SetProperty().initializeFromObject({
               "name":"layout",
               "value":this._GWizWeightsVolumes_VerticalLayout1_c()
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_GWizForePanel1",
               "name":"percentWidth",
               "value":100
            }),new SetStyle().initializeFromObject({
               "target":"typeSelector",
               "name":"verticalScrollPolicy",
               "value":"off"
            }),new SetProperty().initializeFromObject({
               "target":"typeSelector",
               "name":"layout",
               "value":this._GWizWeightsVolumes_HorizontalLayout2_c()
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_Group2",
               "name":"layout",
               "value":this._GWizWeightsVolumes_HorizontalLayout3_c()
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_VGroup1",
               "name":"percentHeight",
               "value":100
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_VGroup1",
               "name":"percentWidth",
               "value":50
            }),new SetProperty().initializeFromObject({
               "target":"materialParentPanel",
               "name":"layout",
               "value":this._GWizWeightsVolumes_VerticalLayout6_c()
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_GWizForePanel4",
               "name":"percentWidth",
               "value":50
            }),new SetProperty().initializeFromObject({
               "target":"_GWizWeightsVolumes_GWizForePanel4",
               "name":"percentHeight",
               "value":100
            })]
         })];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizWeightsVolumes._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get MaterialShapes() : ArrayCollection
      {
         return GWizWeightsVolumes._1675036953MaterialShapes;
      }
      
      public static function set MaterialShapes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizWeightsVolumes._1675036953MaterialShapes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizWeightsVolumes,"MaterialShapes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get appIsEstimator() : Boolean
      {
         return GWizWeightsVolumes._795868523appIsEstimator;
      }
      
      private static function set appIsEstimator(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizWeightsVolumes._795868523appIsEstimator;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizWeightsVolumes,"appIsEstimator",_loc2_,param1));
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
      
      public function UIToOp(param1:GWizCCWEstRecord) : void
      {
         if(param1)
         {
            param1.op = "Material";
            param1.type = "Material";
            param1.desc = this.Description.text;
            if(param1.rateper == GWizCCWEstRecord.CCE_FIXED_COST_SECTION)
            {
               param1.oprate = this.custCostOpRate;
            }
            else
            {
               param1.oprate = this.custCostUnitOpRate;
            }
            param1.rpm = 0;
            param1.height = this.uIn.value;
            param1.width = this.wIn.value;
            param1.rpm = this.xIn.value;
            param1.sfm = this.yIn.value;
            param1.feedrate = this.zIn.value;
            param1.toolOther = this.currType;
            param1.material = this.Material.Selection;
            param1.hourly = this.costWt.value;
            param1.ipr = this.PartsPer.value;
            param1.markup = this.markup.value;
         }
      }
      
      public function OpToUI(param1:GWizCCWEstRecord) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(param1)
         {
            this.restoreViewData();
            if(param1.rateper == GWizCCWEstRecord.CCE_FIXED_COST_SECTION)
            {
               this.PartsQty.enabled = true;
            }
            else
            {
               this.PartsQty.value = GWizEstOpPickerAPI.OrderSize;
               this.PartsQty.enabled = false;
            }
            this.Description.text = param1.desc;
            this.currType = param1.toolOther;
            _loc2_ = 0;
            while(_loc2_ < this.typeList.length)
            {
               _loc3_ = this.typeList.getItemAt(_loc2_);
               if(_loc3_.name == this.currType)
               {
                  this.typeSelector.selectedIndex = _loc2_;
                  this.selectType();
                  break;
               }
               _loc2_++;
            }
            this.uIn.value = param1.height;
            this.wIn.value = param1.width;
            this.xIn.value = param1.rpm;
            this.yIn.value = param1.sfm;
            this.zIn.value = param1.feedrate;
            this.Material.setMaterialToLabel(param1.material);
            this.costWt.value = param1.hourly;
            this.PartsPer.value = param1.ipr;
            this.markup.value = param1.markup;
            this.recalc();
         }
      }
      
      private function restoreViewData() : void
      {
         if(this.restoreViewDataDone)
         {
            return;
         }
         appIsEstimator = GWizLoginBar.isGWEstimator();
         GWizMaterialsDB.FabricationsList.filterFunction = this.filterFabs;
         GWizMaterialsDB.FabricationsList.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.fabSizeRefresh);
         this.typeSelector.selectedIndex = 0;
         this.recalcOK = true;
         this.selectType();
         GWizNumStep.checkUnitsCC.addFunction("GWizWeightsVolumes",this.setUnitsIndicator);
         this.restoreViewDataDone = true;
      }
      
      private function setUnitsIndicator(param1:Object = null) : Boolean
      {
         this.recalc();
         return true;
      }
      
      private function saveViewData() : void
      {
      }
      
      private function restoreFabPanel() : void
      {
         if(this.tempFabPanel != null)
         {
            this.materialParentPanel.addElementAt(this.tempFabPanel,0);
            this.tempFabPanel = null;
            this.fabPanelVisible = true;
         }
      }
      
      private function removeFabPanel() : void
      {
         if(this.tempFabPanel == null)
         {
            this.tempFabPanel = this.materialParentPanel.removeElementAt(0);
            this.fabPanelVisible = false;
         }
      }
      
      private function selectType(param1:int = -1, param2:int = -1) : void
      {
         this.lastFabSize = param2;
         this.FabSize.selectedIndex = param2;
         this.GetGauge.visible = false;
         switch(this.typeSelector.selectedItem.name)
         {
            case "Pipes":
               this.restoreFabPanel();
               this.uIn.titleTxt = "Outside Diameter";
               this.wIn.titleTxt = "Inside Diameter";
               this.xIn.titleTxt = "Wall Thickness";
               this.yIn.titleTxt = "Length";
               this.zIn.titleTxt = "";
               this.wIn.visible = true;
               this.xIn.visible = true;
               this.yIn.visible = true;
               this.zIn.visible = false;
               break;
            case "Channel":
               this.restoreFabPanel();
               this.uIn.titleTxt = "Depth";
               this.wIn.titleTxt = "Flange Width";
               this.xIn.titleTxt = "Web Thickness";
               this.yIn.titleTxt = "Length";
               this.zIn.titleTxt = "";
               this.wIn.visible = true;
               this.xIn.visible = true;
               this.yIn.visible = true;
               this.zIn.visible = false;
               break;
            case "Angle":
               this.restoreFabPanel();
               this.uIn.titleTxt = "First Leg";
               this.wIn.titleTxt = "Second Leg";
               this.xIn.titleTxt = "Leg Thickness";
               this.yIn.titleTxt = "Length";
               this.zIn.titleTxt = "";
               this.wIn.visible = true;
               this.xIn.visible = true;
               this.yIn.visible = true;
               this.zIn.visible = false;
               break;
            case "I-Beam":
               this.restoreFabPanel();
               this.uIn.titleTxt = "Depth";
               this.wIn.titleTxt = "Flange Width";
               this.xIn.titleTxt = "Web Thickness";
               this.yIn.titleTxt = "Length";
               this.zIn.titleTxt = "";
               this.wIn.visible = true;
               this.xIn.visible = true;
               this.yIn.visible = true;
               this.zIn.visible = false;
               break;
            case "Rectangular":
               this.removeFabPanel();
               this.uIn.titleTxt = "Thickness";
               this.wIn.titleTxt = "Width";
               this.xIn.titleTxt = "Length";
               this.yIn.titleTxt = "";
               this.zIn.titleTxt = "";
               this.wIn.visible = true;
               this.xIn.visible = true;
               this.yIn.visible = false;
               this.zIn.visible = false;
               this.GetGauge.visible = true;
               break;
            case "Round":
               this.removeFabPanel();
               this.uIn.titleTxt = "Outside Diameter";
               this.wIn.titleTxt = "Length";
               this.xIn.titleTxt = "";
               this.yIn.titleTxt = "";
               this.zIn.titleTxt = "";
               this.wIn.visible = true;
               this.xIn.visible = false;
               this.yIn.visible = false;
               this.zIn.visible = false;
               break;
            case "Hex":
               this.removeFabPanel();
               this.uIn.titleTxt = "Across Flats";
               this.wIn.titleTxt = "Length";
               this.xIn.titleTxt = "";
               this.yIn.titleTxt = "";
               this.zIn.titleTxt = "";
               this.wIn.visible = true;
               this.xIn.visible = false;
               this.yIn.visible = false;
               this.zIn.visible = false;
               break;
            case "Round Tube":
               this.removeFabPanel();
               this.uIn.titleTxt = "Outside Diameter";
               this.wIn.titleTxt = "Inside Diameter";
               this.xIn.titleTxt = "Length";
               this.yIn.titleTxt = "";
               this.zIn.titleTxt = "";
               this.wIn.visible = true;
               this.xIn.visible = true;
               this.yIn.visible = false;
               this.zIn.visible = false;
               break;
            case "Square Tube":
               this.removeFabPanel();
               this.uIn.titleTxt = "Outside Measurement";
               this.wIn.titleTxt = "Wall Thickness";
               this.xIn.titleTxt = "External Fillet";
               this.yIn.titleTxt = "Internal Fillet";
               this.zIn.titleTxt = "Length";
               this.wIn.visible = true;
               this.xIn.visible = true;
               this.yIn.visible = true;
               this.zIn.visible = true;
               break;
            case "Sphere":
               this.removeFabPanel();
               this.uIn.titleTxt = "Diameter";
               this.wIn.titleTxt = "";
               this.xIn.titleTxt = "";
               this.yIn.titleTxt = "";
               this.zIn.titleTxt = "";
               this.wIn.visible = false;
               this.xIn.visible = false;
               this.yIn.visible = false;
               this.zIn.visible = false;
         }
         this.GetLumber.visible = this.GetGauge.visible;
         this.currType = this.typeSelector.selectedItem.name;
         log.debug("currType = " + this.currType);
         GWizMaterialsDB.FabricationsList.refresh();
         this.fabChanged();
         this.wFeet.visible = this.wIn.visible;
         this.wFeet.selected = false;
         this.xFeet.visible = this.xIn.visible;
         this.xFeet.selected = false;
         this.yFeet.visible = this.yIn.visible;
         this.yFeet.selected = false;
         this.zFeet.visible = this.zIn.visible;
         this.zFeet.selected = false;
         if(param1 > -1)
         {
            this.Material.MaterialSelectedIndex = param1;
         }
         this.recalc();
      }
      
      private function fabSizeRefresh(param1:CollectionEvent) : void
      {
         this.FabSize.selectedIndex = this.lastFabSize > -1 ? int(this.lastFabSize) : 0;
         this.fabChanged();
      }
      
      private function filterDensity(param1:Object) : Boolean
      {
         return param1.material == this.Material.Selection;
      }
      
      private function lookupDensity() : Number
      {
         if(!this.Material.materialSelected())
         {
            return 0.0975;
         }
         GWizConfigData.MachinabilityFactors.filterFunction = this.filterDensity;
         GWizConfigData.MachinabilityFactors.refresh();
         if(GWizConfigData.MachinabilityFactors.length != 1)
         {
            if(GWizUtils.debug)
            {
               log.debug("length = " + GWizConfigData.MachinabilityFactors.length);
               log.debug("Material.Selection = " + this.Material.Selection);
            }
            return 0.0975;
         }
         var _loc1_:Object = GWizConfigData.MachinabilityFactors.getItemAt(0);
         var _loc2_:Number = _loc1_.density;
         GWizConfigData.MachinabilityFactors.filterFunction = null;
         GWizConfigData.MachinabilityFactors.refresh();
         return _loc2_;
      }
      
      private function filterFabs(param1:Object) : Boolean
      {
         return param1.type == this.currType;
      }
      
      private function cylVolume(param1:Number, param2:Number) : Number
      {
         return Math.PI * (param1 / 2) * (param1 / 2) * param2;
      }
      
      private function roundCornerRectArea(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:Number = NaN;
         return Number(param1 * param2 + 2 * param3 * (param1 + param2) + Math.PI * param3 * param3);
      }
      
      private function roundCornerRectVol(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return this.roundCornerRectArea(param1,param2,param3) * param4;
      }
      
      private function fabChanged() : void
      {
         if(!this.recalcOK)
         {
            return;
         }
         log.debug("fabChanged; currType = " + this.currType);
         var _loc1_:Object = this.FabSize.selectedItem;
         switch(this.currType)
         {
            case "Channel":
            case "Angle":
            case "I-Beam":
               if(_loc1_ != null)
               {
                  this.lbsPerFoot = Number(_loc1_.fourthParm);
                  log.debug("lbsPerFoot = " + this.lbsPerFoot);
               }
               else
               {
                  log.debug("fabItem == null");
               }
            case "Pipes":
               if(_loc1_ != null)
               {
                  this.uIn.setVal(Number(_loc1_.firstParm));
                  this.wIn.setVal(Number(_loc1_.secondParm) - Number(_loc1_.thirdParm));
                  this.xIn.setVal(Number(_loc1_.thirdParm));
               }
               else
               {
                  log.debug("fabItem == null");
               }
         }
         this.recalc();
      }
      
      private function feet(param1:Number, param2:Boolean) : Number
      {
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            if(param2)
            {
               param1 *= 12;
            }
         }
         else if(param2)
         {
            param1 *= 1000;
         }
         return param1;
      }
      
      private function checkPipes() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc1_:int = 0;
         while(_loc1_ < GWizMaterialsDB.FabricationsList.length)
         {
            _loc2_ = GWizMaterialsDB.FabricationsList.getItemAt(_loc1_);
            if(_loc2_.type == "Pipes")
            {
               this.uIn.setVal(Number(_loc2_.firstParm));
               this.wIn.setVal(Number(_loc2_.secondParm));
               this.xIn.setVal(Number(_loc2_.thirdParm));
               _loc3_ = this.uIn.getVal();
               _loc4_ = this.wIn.getVal();
               _loc5_ = this.xIn.getVal();
               if(Math.abs(_loc3_ - 2 * _loc5_ - _loc4_) > 0.0001)
               {
                  _loc4_ -= _loc5_;
                  if(Math.abs(_loc3_ - 2 * _loc5_ - _loc4_) > 0.0001)
                  {
                     log.debug("OD/ID error on " + _loc2_.name);
                  }
               }
               else
               {
                  log.debug("No error");
               }
            }
            _loc1_++;
         }
      }
      
      private function recalc() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc1_:Number = this.lookupDensity();
         var _loc8_:* = "";
         var _loc9_:* = "";
         var _loc10_:* = "";
         var _loc11_:String = "";
         var _loc12_:String = "";
         if(!this.recalcOK)
         {
            return;
         }
         if(!this.PartsQty.enabled)
         {
            this.PartsQty.value = GWizEstOpPickerAPI.OrderSize;
         }
         switch(this.currType)
         {
            case "Pipes":
            case "Round Tube":
               _loc6_ = this.uIn.getVal();
               _loc7_ = this.feet(this.wIn.getVal(),this.wFeet.selected);
               _loc5_ = this.feet(this.yIn.getVal(),this.yFeet.selected);
               _loc2_ = this.cylVolume(_loc6_,_loc5_) - this.cylVolume(_loc7_,_loc5_);
               _loc8_ = _loc6_ + " OD";
               _loc9_ = _loc7_ + " ID";
               _loc10_ = " long";
               break;
            case "Channel":
            case "Angle":
            case "I-Beam":
               _loc15_ = 0.2836;
               _loc2_ = (_loc4_ = this.lbsPerFoot * (this.feet(this.yIn.getVal(),this.yFeet.selected) / 12)) / _loc15_;
               _loc8_ = this.uIn.getVal() + " " + this.uIn.theLabel;
               _loc9_ = this.wIn.getVal() + " " + this.wIn.theLabel;
               _loc10_ = this.xIn.getVal() + " " + this.xIn.theLabel;
               _loc11_ = this.yIn.getVal() + " " + this.yIn.theLabel;
               break;
            case "Rectangular":
               _loc2_ = this.uIn.getVal() * this.feet(this.wIn.getVal(),this.wFeet.selected) * this.feet(this.xIn.getVal(),this.xFeet.selected);
               _loc8_ = this.uIn.getVal() + " Thick";
               _loc9_ = this.wIn.getVal() + " Wide";
               _loc10_ = this.xIn.getVal() + " Long";
               break;
            case "Round":
               _loc2_ = this.cylVolume(this.uIn.getVal(),this.feet(this.wIn.getVal(),this.wFeet.selected));
               _loc8_ = this.uIn.getVal() + " OD";
               _loc9_ = this.wIn.getVal() + " Long";
               break;
            case "Hex":
               _loc2_ = 0.8660254037844386 * (this.uIn.getVal() * this.uIn.getVal()) * this.feet(this.wIn.getVal(),this.wFeet.selected);
               _loc8_ = this.uIn.getVal() + " Across Flats";
               _loc9_ = this.wIn.getVal() + " Long";
               break;
            case "Square Tube":
               _loc2_ = this.roundCornerRectVol(this.uIn.getVal(),this.uIn.getVal(),this.feet(this.xIn.getVal(),this.xFeet.selected),this.feet(this.zIn.getVal(),this.zFeet.selected)) - this.roundCornerRectVol(this.uIn.getVal() - 2 * this.feet(this.wIn.getVal(),this.wFeet.selected),this.uIn.getVal() - 2 * this.feet(this.wIn.getVal(),this.wFeet.selected),this.feet(this.yIn.getVal(),this.yFeet.selected),this.feet(this.zIn.getVal(),this.zFeet.selected));
               _loc8_ = this.uIn.getVal() + " " + this.uIn.theLabel;
               _loc9_ = this.wIn.getVal() + " " + this.wIn.theLabel;
               _loc10_ = this.xIn.getVal() + " " + this.xIn.theLabel;
               _loc11_ = this.yIn.getVal() + " " + this.yIn.theLabel;
               _loc12_ = this.zIn.getVal() + " " + this.zIn.theLabel;
               break;
            case "Sphere":
               _loc2_ = 4 / 3 * Math.PI * (this.uIn.getVal() / 2) * (this.uIn.getVal() / 2) * (this.uIn.getVal() / 2);
               _loc8_ = this.uIn.getVal() + " Diameter";
         }
         _loc3_ = _loc2_ * _loc1_;
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            this.materialParentPanel.title = "Size (in)";
            this.UVolLabel.text = "Unit Volume (ci)";
            this.UWeightLabel.text = "Unit Weight (lb)";
            this.TWeightLabel.text = "Total Weigth (lb)";
            this.costWt.titleTxt = "Cost Per Lb";
            this.DensityLabel.text = "Lb/ci";
            this.DensityValue.text = String(_loc1_);
            this.wFeet.label = "Feet";
            this.xFeet.label = "Feet";
            this.yFeet.label = "Feet";
            this.zFeet.label = "Feet";
         }
         else
         {
            this.materialParentPanel.title = "Size (mm)";
            this.UVolLabel.text = "Unit Volume (cm3)";
            this.UWeightLabel.text = "Unit Weight (kg)";
            this.TWeightLabel.text = "Total Weigth (kg)";
            this.costWt.titleTxt = "Cost Per Kg";
            this.wFeet.label = "Meters";
            this.xFeet.label = "Meters";
            this.yFeet.label = "Meters";
            this.zFeet.label = "Meters";
            _loc2_ *= 16.3871;
            _loc3_ /= 2.2;
            this.DensityLabel.text = "g/cm3";
            this.DensityValue.text = GWizUtils.sroundHundredths(String(_loc1_ * 27.6799047));
         }
         var _loc13_:Number = 0;
         if((_loc13_ = this.PartsQty.value / int(this.PartsPer.value)) != int(_loc13_))
         {
            _loc13_ = int(_loc13_) + 1;
         }
         this.StockReqd.text = String(int(_loc13_)) + " pieces";
         _loc4_ = _loc3_ * _loc13_;
         this.UnitVolume.text = String(GWizUtils.roundThousandths(_loc2_));
         this.UnitWeight.text = String(GWizUtils.roundThousandths(_loc3_));
         this.TotalWeight.text = String(GWizUtils.roundThousandths(_loc4_));
         this.UnitCost.text = GWizUtils.sroundHundredths(String(_loc3_ * this.costWt.getVal()));
         var _loc14_:Number = _loc3_ * this.costWt.getVal() * _loc13_;
         this.TotalCost.text = GWizUtils.sroundHundredths(String(_loc14_));
         if(!gotMarkup && GWizSettings.lookupCost != null)
         {
            _loc16_ = GWizSettings.lookupCost(GWizSettings.MATERIAL_MARKUP);
            if(isNaN(_loc16_))
            {
               _loc16_ = 15;
            }
            this.markup.setVal(_loc16_);
            gotMarkup = true;
         }
         this.custCostOpRate = _loc14_ * (1 + this.markup.getVal() / 100);
         this.CustCost.text = GWizUtils.sroundHundredths(String(this.custCostOpRate));
         this.custCostUnitOpRate = this.custCostOpRate / this.PartsQty.value;
         this.CustUnitCost.text = GWizUtils.sroundHundredths(String(this.custCostUnitOpRate));
         if(!this.DescEdit.selected)
         {
            this.Description.text = this.getDescription(_loc8_,_loc9_,_loc10_,_loc11_,_loc12_);
         }
      }
      
      private function gageFunction(param1:Number) : void
      {
         if(param1 && !isNaN(param1))
         {
            this.uIn.setVal(param1);
         }
      }
      
      private function doSheetMetalGauge() : void
      {
         var _loc1_:GWizSheetMetalGauge = GWizSheetMetalGauge(GWizPopUpManager.createPopUp(this,GWizSheetMetalGauge,true));
         _loc1_.okFunction = this.gageFunction;
      }
      
      private function doLumberSizes() : void
      {
         var _loc1_:GWizLumberSizes = GWizLumberSizes(GWizPopUpManager.createPopUp(this,GWizLumberSizes,true));
         _loc1_.okFunction = this.lumberFunction;
      }
      
      private function lumberFunction(param1:Number, param2:Number) : void
      {
         if(!isNaN(param1) && !isNaN(param2))
         {
            this.uIn.setVal(param1);
            this.wIn.setVal(param2);
         }
      }
      
      protected function group1_resizeHandler(param1:ResizeEvent) : void
      {
         currentState = "landscape";
      }
      
      private function addDim(param1:String, param2:Boolean = true) : String
      {
         if(param1 != "" && param2)
         {
            param1 = " x " + param1;
         }
         return param1;
      }
      
      private function getDescription(param1:String, param2:String, param3:String, param4:String, param5:String) : String
      {
         var _loc6_:* = (_loc6_ = (_loc6_ = this.Material.Selection + ", " + this.typeSelector.selectedItem.name) + ", Dimensions: ") + (this.addDim(param1) + this.addDim(param2) + this.addDim(param3) + this.addDim(param4) + this.addDim(param5,false));
         if(this.fabPanelVisible && this.FabSize.selectedIndex >= 0 && this.FabSize.selectedItem)
         {
            _loc6_ = (_loc6_ += " ( ") + (this.FabSize.selectedItem.name + " )");
         }
         return _loc6_;
      }
      
      public function getCost() : Number
      {
         return Number(this.TotalCost.text);
      }
      
      public function selectOp() : void
      {
         log.debug("selectOp for Material Op");
      }
      
      public function setSubOp(param1:String) : void
      {
      }
      
      private function _GWizWeightsVolumes_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Shape";
         _loc1_.layout = this._GWizWeightsVolumes_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizWeightsVolumes_Array3_c);
         _loc1_.id = "_GWizWeightsVolumes_GWizForePanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizWeightsVolumes_GWizForePanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizWeightsVolumes_GWizForePanel1",this._GWizWeightsVolumes_GWizForePanel1);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_VerticalLayout2_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizWeightsVolumes_Array3_c() : Array
      {
         return [this._GWizWeightsVolumes_List1_i()];
      }
      
      private function _GWizWeightsVolumes_List1_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.itemRenderer = this._GWizWeightsVolumes_ClassFactory1_c();
         _loc1_.useVirtualLayout = true;
         _loc1_.dataProvider = this._GWizWeightsVolumes_ArrayList1_i();
         _loc1_.setStyle("borderColor",0);
         _loc1_.setStyle("borderAlpha",1);
         _loc1_.setStyle("borderVisible",true);
         _loc1_.addEventListener("change",this.__typeSelector_change);
         _loc1_.id = "typeSelector";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.typeSelector = _loc1_;
         BindingManager.executeBindings(this,"typeSelector",this.typeSelector);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_ClassFactory1_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = ImageItemRenderer;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_ArrayList1_i() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [{
            "name":"Pipes",
            "src":this._embed_mxml__assets_TubeStock_jpg_1245505390
         },{
            "name":"Channel",
            "src":this._embed_mxml__assets_ChannelStock_jpg_81215990
         },{
            "name":"Angle",
            "src":this._embed_mxml__assets_AngleStock_jpg_1584305782
         },{
            "name":"I-Beam",
            "src":this._embed_mxml__assets_IBeamStock_jpg_1499665132
         },{
            "name":"Rectangular",
            "src":this._embed_mxml__assets_PlateStock_jpg_1581614640
         },{
            "name":"Round",
            "src":this._embed_mxml__assets_RoundStock_jpg_1027981824
         },{
            "name":"Hex",
            "src":this._embed_mxml__assets_HexStock_jpg_992691622
         },{
            "name":"Round Tube",
            "src":this._embed_mxml__assets_TubeStock_jpg_1245505390
         },{
            "name":"Square Tube",
            "src":this._embed_mxml__assets_SquareTubeStock_jpg_1971289328
         },{
            "name":"Sphere",
            "src":this._embed_mxml__assets_SphereStock_jpg_856838288
         }];
         this.typeList = _loc1_;
         BindingManager.executeBindings(this,"typeList",this.typeList);
         return _loc1_;
      }
      
      public function __typeSelector_change(param1:IndexChangeEvent) : void
      {
         this.selectType();
      }
      
      private function _GWizWeightsVolumes_Group2_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_VGroup1_i(),this._GWizWeightsVolumes_GWizForePanel4_i()];
         _loc1_.setStyle("color",0);
         _loc1_.id = "_GWizWeightsVolumes_Group2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizWeightsVolumes_Group2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizWeightsVolumes_Group2",this._GWizWeightsVolumes_Group2);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_VGroup1_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.gap = 2;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_GWizForePanel2_c(),this._GWizWeightsVolumes_GWizForePanel3_i()];
         _loc1_.id = "_GWizWeightsVolumes_VGroup1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizWeightsVolumes_VGroup1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizWeightsVolumes_VGroup1",this._GWizWeightsVolumes_VGroup1);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_GWizForePanel2_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Material";
         _loc1_.layout = this._GWizWeightsVolumes_VerticalLayout5_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizWeightsVolumes_Array7_c);
         _loc1_.setStyle("backgroundColor",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_VerticalLayout5_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Array7_c() : Array
      {
         return [this._GWizWeightsVolumes_GWizMaterialChooser1_i()];
      }
      
      private function _GWizWeightsVolumes_GWizMaterialChooser1_i() : GWizMaterialChooser
      {
         var _loc1_:GWizMaterialChooser = new GWizMaterialChooser();
         _loc1_.percentWidth = 100;
         _loc1_.onChangeFcn = this.recalc;
         _loc1_.id = "Material";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Material = _loc1_;
         BindingManager.executeBindings(this,"Material",this.Material);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.title = "Size (in)";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizWeightsVolumes_Array8_c);
         _loc1_.setStyle("backgroundColor",16777215);
         _loc1_.id = "materialParentPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.materialParentPanel = _loc1_;
         BindingManager.executeBindings(this,"materialParentPanel",this.materialParentPanel);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Array8_c() : Array
      {
         return [this._GWizWeightsVolumes_List2_i(),this._GWizWeightsVolumes_VGroup2_i()];
      }
      
      private function _GWizWeightsVolumes_List2_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.labelField = "name";
         _loc1_.itemRenderer = this._GWizWeightsVolumes_ClassFactory2_c();
         _loc1_.layout = this._GWizWeightsVolumes_VerticalLayout7_c();
         _loc1_.addEventListener("valueCommit",this.__FabSize_valueCommit);
         _loc1_.id = "FabSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FabSize = _loc1_;
         BindingManager.executeBindings(this,"FabSize",this.FabSize);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_ClassFactory2_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizListItemRenderer;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_VerticalLayout7_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.rowHeight = 22;
         _loc1_.variableRowHeight = false;
         _loc1_.gap = 0;
         return _loc1_;
      }
      
      public function __FabSize_valueCommit(param1:FlexEvent) : void
      {
         this.fabChanged();
      }
      
      private function _GWizWeightsVolumes_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_HGroup1_c(),this._GWizWeightsVolumes_HGroup2_c(),this._GWizWeightsVolumes_HGroup3_c(),this._GWizWeightsVolumes_HGroup4_c(),this._GWizWeightsVolumes_HGroup5_c(),this._GWizWeightsVolumes_HGroup6_c()];
         _loc1_.id = "DimPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DimPanel = _loc1_;
         BindingManager.executeBindings(this,"DimPanel",this.DimPanel);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_GWizNumStep1_i(),this._GWizWeightsVolumes_Label1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.value = 0;
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.001;
         _loc1_.titleTxt = "Depth";
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("change",this.__uIn_change);
         _loc1_.id = "uIn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.uIn = _loc1_;
         BindingManager.executeBindings(this,"uIn",this.uIn);
         return _loc1_;
      }
      
      public function __uIn_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizWeightsVolumes_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizWeightsVolumes_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizWeightsVolumes_Label1",this._GWizWeightsVolumes_Label1);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_GWizNumStep2_i(),this._GWizWeightsVolumes_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.value = 0;
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.001;
         _loc1_.titleTxt = "Flange Width";
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("change",this.__wIn_change);
         _loc1_.id = "wIn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.wIn = _loc1_;
         BindingManager.executeBindings(this,"wIn",this.wIn);
         return _loc1_;
      }
      
      public function __wIn_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Feet";
         _loc1_.addEventListener("change",this.__wFeet_change);
         _loc1_.id = "wFeet";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.wFeet = _loc1_;
         BindingManager.executeBindings(this,"wFeet",this.wFeet);
         return _loc1_;
      }
      
      public function __wFeet_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_GWizNumStep3_i(),this._GWizWeightsVolumes_CheckBox2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.value = 0;
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.001;
         _loc1_.titleTxt = "Web Thickness";
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("change",this.__xIn_change);
         _loc1_.id = "xIn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xIn = _loc1_;
         BindingManager.executeBindings(this,"xIn",this.xIn);
         return _loc1_;
      }
      
      public function __xIn_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Feet";
         _loc1_.addEventListener("change",this.__xFeet_change);
         _loc1_.id = "xFeet";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xFeet = _loc1_;
         BindingManager.executeBindings(this,"xFeet",this.xFeet);
         return _loc1_;
      }
      
      public function __xFeet_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_GWizNumStep4_i(),this._GWizWeightsVolumes_CheckBox3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.value = 0;
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.001;
         _loc1_.titleTxt = "Length";
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("change",this.__yIn_change);
         _loc1_.id = "yIn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.yIn = _loc1_;
         BindingManager.executeBindings(this,"yIn",this.yIn);
         return _loc1_;
      }
      
      public function __yIn_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_CheckBox3_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Feet";
         _loc1_.addEventListener("change",this.__yFeet_change);
         _loc1_.id = "yFeet";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.yFeet = _loc1_;
         BindingManager.executeBindings(this,"yFeet",this.yFeet);
         return _loc1_;
      }
      
      public function __yFeet_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_GWizNumStep5_i(),this._GWizWeightsVolumes_CheckBox4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.value = 0;
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.001;
         _loc1_.titleTxt = "";
         _loc1_.percentWidth = 100;
         _loc1_.id = "zIn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.zIn = _loc1_;
         BindingManager.executeBindings(this,"zIn",this.zIn);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_CheckBox4_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Feet";
         _loc1_.addEventListener("change",this.__zFeet_change);
         _loc1_.id = "zFeet";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.zFeet = _loc1_;
         BindingManager.executeBindings(this,"zFeet",this.zFeet);
         return _loc1_;
      }
      
      public function __zFeet_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Button1_i(),this._GWizWeightsVolumes_Button2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Sheet Metal Gauge";
         _loc1_.addEventListener("click",this.__GetGauge_click);
         _loc1_.id = "GetGauge";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GetGauge = _loc1_;
         BindingManager.executeBindings(this,"GetGauge",this.GetGauge);
         return _loc1_;
      }
      
      public function __GetGauge_click(param1:MouseEvent) : void
      {
         this.doSheetMetalGauge();
      }
      
      private function _GWizWeightsVolumes_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Lumber Sizes";
         _loc1_.addEventListener("click",this.__GetLumber_click);
         _loc1_.id = "GetLumber";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GetLumber = _loc1_;
         BindingManager.executeBindings(this,"GetLumber",this.GetLumber);
         return _loc1_;
      }
      
      public function __GetLumber_click(param1:MouseEvent) : void
      {
         this.doLumberSizes();
      }
      
      private function _GWizWeightsVolumes_GWizForePanel4_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Results";
         _loc1_.layout = this._GWizWeightsVolumes_VerticalLayout8_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizWeightsVolumes_Array16_c);
         _loc1_.setStyle("backgroundColor",16777215);
         _loc1_.id = "_GWizWeightsVolumes_GWizForePanel4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizWeightsVolumes_GWizForePanel4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizWeightsVolumes_GWizForePanel4",this._GWizWeightsVolumes_GWizForePanel4);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_VerticalLayout8_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Array16_c() : Array
      {
         return [this._GWizWeightsVolumes_GWizNumStep6_i(),this._GWizWeightsVolumes_GWizNumStep7_i(),this._GWizWeightsVolumes_HGroup7_c(),this._GWizWeightsVolumes_GWizNumStep8_i(),this._GWizWeightsVolumes_GWizNumStep9_i(),this._GWizWeightsVolumes_Spacer1_c(),this._GWizWeightsVolumes_HGroup8_c(),this._GWizWeightsVolumes_HGroup9_c(),this._GWizWeightsVolumes_HGroup10_c(),this._GWizWeightsVolumes_HGroup11_c(),this._GWizWeightsVolumes_HGroup12_c(),this._GWizWeightsVolumes_HGroup13_c(),this._GWizWeightsVolumes_HGroup14_c(),this._GWizWeightsVolumes_HGroup15_c(),this._GWizWeightsVolumes_HGroup16_i(),this._GWizWeightsVolumes_TextArea1_i()];
      }
      
      private function _GWizWeightsVolumes_GWizNumStep6_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.value = 1;
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 1;
         _loc1_.titleTxt = "Parts";
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__PartsQty_change);
         _loc1_.id = "PartsQty";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PartsQty = _loc1_;
         BindingManager.executeBindings(this,"PartsQty",this.PartsQty);
         return _loc1_;
      }
      
      public function __PartsQty_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_GWizNumStep7_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.value = 1;
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 1;
         _loc1_.titleTxt = "Parts/Raw Stock";
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__PartsPer_change);
         _loc1_.id = "PartsPer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PartsPer = _loc1_;
         BindingManager.executeBindings(this,"PartsPer",this.PartsPer);
         return _loc1_;
      }
      
      public function __PartsPer_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Label2_i(),this._GWizWeightsVolumes_Label3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Raw Stock Req\'d: ";
         _loc1_.id = "StockReqdLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.StockReqdLabel = _loc1_;
         BindingManager.executeBindings(this,"StockReqdLabel",this.StockReqdLabel);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "StockReqd";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.StockReqd = _loc1_;
         BindingManager.executeBindings(this,"StockReqd",this.StockReqd);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_GWizNumStep8_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.1;
         _loc1_.titleTxt = "Cost Per Lb";
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valid",this.__costWt_valid);
         _loc1_.addEventListener("change",this.__costWt_change);
         _loc1_.id = "costWt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.costWt = _loc1_;
         BindingManager.executeBindings(this,"costWt",this.costWt);
         return _loc1_;
      }
      
      public function __costWt_valid(param1:FlexEvent) : void
      {
      }
      
      public function __costWt_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_GWizNumStep9_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = -100;
         _loc1_.max = 1000;
         _loc1_.steps = 0.1;
         _loc1_.titleTxt = "Markup (%)";
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valid",this.__markup_valid);
         _loc1_.addEventListener("change",this.__markup_change);
         _loc1_.id = "markup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.markup = _loc1_;
         BindingManager.executeBindings(this,"markup",this.markup);
         return _loc1_;
      }
      
      public function __markup_valid(param1:FlexEvent) : void
      {
      }
      
      public function __markup_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 20;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Label4_i(),this._GWizWeightsVolumes_Label5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Unit Volume";
         _loc1_.id = "UVolLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.UVolLabel = _loc1_;
         BindingManager.executeBindings(this,"UVolLabel",this.UVolLabel);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "UnitVolume";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.UnitVolume = _loc1_;
         BindingManager.executeBindings(this,"UnitVolume",this.UnitVolume);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup9_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Label6_i(),this._GWizWeightsVolumes_Label7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Lb/ci";
         _loc1_.id = "DensityLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DensityLabel = _loc1_;
         BindingManager.executeBindings(this,"DensityLabel",this.DensityLabel);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "DensityValue";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DensityValue = _loc1_;
         BindingManager.executeBindings(this,"DensityValue",this.DensityValue);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup10_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Label8_i(),this._GWizWeightsVolumes_Label9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Unit Weight";
         _loc1_.id = "UWeightLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.UWeightLabel = _loc1_;
         BindingManager.executeBindings(this,"UWeightLabel",this.UWeightLabel);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "UnitWeight";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.UnitWeight = _loc1_;
         BindingManager.executeBindings(this,"UnitWeight",this.UnitWeight);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup11_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Label10_i(),this._GWizWeightsVolumes_Label11_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Total Weight";
         _loc1_.id = "TWeightLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TWeightLabel = _loc1_;
         BindingManager.executeBindings(this,"TWeightLabel",this.TWeightLabel);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "TotalWeight";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TotalWeight = _loc1_;
         BindingManager.executeBindings(this,"TotalWeight",this.TotalWeight);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup12_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Label12_c(),this._GWizWeightsVolumes_Label13_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Unit Cost";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label13_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "$0.0";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "UnitCost";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.UnitCost = _loc1_;
         BindingManager.executeBindings(this,"UnitCost",this.UnitCost);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup13_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Label14_c(),this._GWizWeightsVolumes_Label15_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label14_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Customer Unit Cost";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "$0.0";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "CustUnitCost";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CustUnitCost = _loc1_;
         BindingManager.executeBindings(this,"CustUnitCost",this.CustUnitCost);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup14_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Label16_c(),this._GWizWeightsVolumes_Label17_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label16_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Total Cost";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label17_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "$0.0";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "TotalCost";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TotalCost = _loc1_;
         BindingManager.executeBindings(this,"TotalCost",this.TotalCost);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup15_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Label18_c(),this._GWizWeightsVolumes_Label19_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label18_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Customer Total Cost";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label19_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "$0.0";
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Cost include the markup.";
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "CustCost";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CustCost = _loc1_;
         BindingManager.executeBindings(this,"CustCost",this.CustCost);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HGroup16_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "baseline";
         _loc1_.mxmlContent = [this._GWizWeightsVolumes_Label20_c(),this._GWizWeightsVolumes_CheckBox5_i()];
         _loc1_.id = "_GWizWeightsVolumes_HGroup16";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizWeightsVolumes_HGroup16 = _loc1_;
         BindingManager.executeBindings(this,"_GWizWeightsVolumes_HGroup16",this._GWizWeightsVolumes_HGroup16);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_Label20_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Description:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_CheckBox5_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Edit";
         _loc1_.toolTip = "Select to make Description editable.";
         _loc1_.id = "DescEdit";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DescEdit = _loc1_;
         BindingManager.executeBindings(this,"DescEdit",this.DescEdit);
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "Description";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Description = _loc1_;
         BindingManager.executeBindings(this,"Description",this.Description);
         return _loc1_;
      }
      
      public function ___GWizWeightsVolumes_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.restoreViewData();
      }
      
      public function ___GWizWeightsVolumes_Group1_resize(param1:ResizeEvent) : void
      {
         this.group1_resizeHandler(param1);
      }
      
      public function ___GWizWeightsVolumes_Group1_click(param1:MouseEvent) : void
      {
         this.recalc();
      }
      
      public function ___GWizWeightsVolumes_Group1_keyUp(param1:KeyboardEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizWeightsVolumes_HorizontalLayout1_c() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = new HorizontalLayout();
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.paddingTop = 10;
         _loc1_.gap = 2;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_VerticalLayout3_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.gap = 1;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_VerticalLayout4_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.gap = 2;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HorizontalLayout4_c() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = new HorizontalLayout();
         _loc1_.gap = 5;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.paddingTop = 10;
         _loc1_.gap = 2;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HorizontalLayout2_c() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = new HorizontalLayout();
         _loc1_.gap = 1;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_HorizontalLayout3_c() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = new HorizontalLayout();
         _loc1_.gap = 2;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_VerticalLayout6_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.gap = 5;
         return _loc1_;
      }
      
      private function _GWizWeightsVolumes_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb4;
         },function(param1:uint):void
         {
            typeSelector.setStyle("selectionColor",param1);
         },"typeSelector.selectionColor");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            typeSelector.setStyle("rollOverColor",param1);
         },"typeSelector.rollOverColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.gray2;
         },function(param1:uint):void
         {
            typeSelector.setStyle("contentBackgroundColor",param1);
         },"typeSelector.contentBackgroundColor");
         result[3] = new Binding(this,function():String
         {
            var _loc1_:* = ColorPalette.alternateb4;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"Material.selectionColor");
         result[4] = new Binding(this,function():String
         {
            var _loc1_:* = ColorPalette.alternateb5;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"Material.rolloverColor");
         result[5] = new Binding(this,function():IList
         {
            return GWizMaterialsDB.FabricationsList;
         },null,"FabSize.dataProvider");
         result[6] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb4;
         },function(param1:uint):void
         {
            FabSize.setStyle("selectionColor",param1);
         },"FabSize.selectionColor");
         result[7] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            FabSize.setStyle("rollOverColor",param1);
         },"FabSize.rollOverColor");
         result[8] = new Binding(this,function():Number
         {
            return wFeet.width;
         },null,"_GWizWeightsVolumes_Label1.width");
         result[9] = new Binding(this,function():Boolean
         {
            return appIsEstimator;
         },null,"_GWizWeightsVolumes_HGroup16.visible");
         result[10] = new Binding(this,function():Boolean
         {
            return appIsEstimator;
         },null,"_GWizWeightsVolumes_HGroup16.includeInLayout");
         result[11] = new Binding(this,function():Boolean
         {
            return DescEdit.selected;
         },null,"Description.editable");
         result[12] = new Binding(this,function():Boolean
         {
            return appIsEstimator;
         },null,"Description.visible");
         result[13] = new Binding(this,function():Boolean
         {
            return appIsEstimator;
         },null,"Description.includeInLayout");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CustCost() : Label
      {
         return this._669510880CustCost;
      }
      
      public function set CustCost(param1:Label) : void
      {
         var _loc2_:Object = this._669510880CustCost;
         if(_loc2_ !== param1)
         {
            this._669510880CustCost = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CustCost",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CustUnitCost() : Label
      {
         return this._295364860CustUnitCost;
      }
      
      public function set CustUnitCost(param1:Label) : void
      {
         var _loc2_:Object = this._295364860CustUnitCost;
         if(_loc2_ !== param1)
         {
            this._295364860CustUnitCost = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CustUnitCost",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DensityLabel() : Label
      {
         return this._1036247284DensityLabel;
      }
      
      public function set DensityLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1036247284DensityLabel;
         if(_loc2_ !== param1)
         {
            this._1036247284DensityLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DensityLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DensityValue() : Label
      {
         return this._1027001975DensityValue;
      }
      
      public function set DensityValue(param1:Label) : void
      {
         var _loc2_:Object = this._1027001975DensityValue;
         if(_loc2_ !== param1)
         {
            this._1027001975DensityValue = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DensityValue",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DescEdit() : CheckBox
      {
         return this._1081513051DescEdit;
      }
      
      public function set DescEdit(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1081513051DescEdit;
         if(_loc2_ !== param1)
         {
            this._1081513051DescEdit = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DescEdit",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Description() : TextArea
      {
         return this._56677412Description;
      }
      
      public function set Description(param1:TextArea) : void
      {
         var _loc2_:Object = this._56677412Description;
         if(_loc2_ !== param1)
         {
            this._56677412Description = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Description",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DimPanel() : VGroup
      {
         return this._148082300DimPanel;
      }
      
      public function set DimPanel(param1:VGroup) : void
      {
         var _loc2_:Object = this._148082300DimPanel;
         if(_loc2_ !== param1)
         {
            this._148082300DimPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DimPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FabSize() : List
      {
         return this._570858376FabSize;
      }
      
      public function set FabSize(param1:List) : void
      {
         var _loc2_:Object = this._570858376FabSize;
         if(_loc2_ !== param1)
         {
            this._570858376FabSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FabSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GetGauge() : Button
      {
         return this._2018597731GetGauge;
      }
      
      public function set GetGauge(param1:Button) : void
      {
         var _loc2_:Object = this._2018597731GetGauge;
         if(_loc2_ !== param1)
         {
            this._2018597731GetGauge = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GetGauge",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GetLumber() : Button
      {
         return this._1686606623GetLumber;
      }
      
      public function set GetLumber(param1:Button) : void
      {
         var _loc2_:Object = this._1686606623GetLumber;
         if(_loc2_ !== param1)
         {
            this._1686606623GetLumber = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GetLumber",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Material() : GWizMaterialChooser
      {
         return this._363710791Material;
      }
      
      public function set Material(param1:GWizMaterialChooser) : void
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
      public function get PartsPer() : GWizNumStep
      {
         return this._1253774909PartsPer;
      }
      
      public function set PartsPer(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1253774909PartsPer;
         if(_loc2_ !== param1)
         {
            this._1253774909PartsPer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PartsPer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PartsQty() : GWizNumStep
      {
         return this._1253776342PartsQty;
      }
      
      public function set PartsQty(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1253776342PartsQty;
         if(_loc2_ !== param1)
         {
            this._1253776342PartsQty = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PartsQty",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get StockReqd() : Label
      {
         return this._1022989412StockReqd;
      }
      
      public function set StockReqd(param1:Label) : void
      {
         var _loc2_:Object = this._1022989412StockReqd;
         if(_loc2_ !== param1)
         {
            this._1022989412StockReqd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"StockReqd",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get StockReqdLabel() : Label
      {
         return this._707459912StockReqdLabel;
      }
      
      public function set StockReqdLabel(param1:Label) : void
      {
         var _loc2_:Object = this._707459912StockReqdLabel;
         if(_loc2_ !== param1)
         {
            this._707459912StockReqdLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"StockReqdLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TWeightLabel() : Label
      {
         return this._1685979752TWeightLabel;
      }
      
      public function set TWeightLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1685979752TWeightLabel;
         if(_loc2_ !== param1)
         {
            this._1685979752TWeightLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TWeightLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TotalCost() : Label
      {
         return this._1426185489TotalCost;
      }
      
      public function set TotalCost(param1:Label) : void
      {
         var _loc2_:Object = this._1426185489TotalCost;
         if(_loc2_ !== param1)
         {
            this._1426185489TotalCost = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TotalCost",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TotalWeight() : Label
      {
         return this._1032728252TotalWeight;
      }
      
      public function set TotalWeight(param1:Label) : void
      {
         var _loc2_:Object = this._1032728252TotalWeight;
         if(_loc2_ !== param1)
         {
            this._1032728252TotalWeight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TotalWeight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get UVolLabel() : Label
      {
         return this._858156714UVolLabel;
      }
      
      public function set UVolLabel(param1:Label) : void
      {
         var _loc2_:Object = this._858156714UVolLabel;
         if(_loc2_ !== param1)
         {
            this._858156714UVolLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"UVolLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get UWeightLabel() : Label
      {
         return this._1815062471UWeightLabel;
      }
      
      public function set UWeightLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1815062471UWeightLabel;
         if(_loc2_ !== param1)
         {
            this._1815062471UWeightLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"UWeightLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get UnitCost() : Label
      {
         return this._228524143UnitCost;
      }
      
      public function set UnitCost(param1:Label) : void
      {
         var _loc2_:Object = this._228524143UnitCost;
         if(_loc2_ !== param1)
         {
            this._228524143UnitCost = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"UnitCost",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get UnitVolume() : Label
      {
         return this._24619554UnitVolume;
      }
      
      public function set UnitVolume(param1:Label) : void
      {
         var _loc2_:Object = this._24619554UnitVolume;
         if(_loc2_ !== param1)
         {
            this._24619554UnitVolume = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"UnitVolume",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get UnitWeight() : Label
      {
         return this._5328580UnitWeight;
      }
      
      public function set UnitWeight(param1:Label) : void
      {
         var _loc2_:Object = this._5328580UnitWeight;
         if(_loc2_ !== param1)
         {
            this._5328580UnitWeight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"UnitWeight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizWeightsVolumes_GWizForePanel1() : GWizForePanel
      {
         return this._1861957547_GWizWeightsVolumes_GWizForePanel1;
      }
      
      public function set _GWizWeightsVolumes_GWizForePanel1(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1861957547_GWizWeightsVolumes_GWizForePanel1;
         if(_loc2_ !== param1)
         {
            this._1861957547_GWizWeightsVolumes_GWizForePanel1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizWeightsVolumes_GWizForePanel1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizWeightsVolumes_GWizForePanel4() : GWizForePanel
      {
         return this._1861957550_GWizWeightsVolumes_GWizForePanel4;
      }
      
      public function set _GWizWeightsVolumes_GWizForePanel4(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1861957550_GWizWeightsVolumes_GWizForePanel4;
         if(_loc2_ !== param1)
         {
            this._1861957550_GWizWeightsVolumes_GWizForePanel4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizWeightsVolumes_GWizForePanel4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizWeightsVolumes_Group2() : Group
      {
         return this._519963948_GWizWeightsVolumes_Group2;
      }
      
      public function set _GWizWeightsVolumes_Group2(param1:Group) : void
      {
         var _loc2_:Object = this._519963948_GWizWeightsVolumes_Group2;
         if(_loc2_ !== param1)
         {
            this._519963948_GWizWeightsVolumes_Group2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizWeightsVolumes_Group2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizWeightsVolumes_VGroup1() : VGroup
      {
         return this._260185223_GWizWeightsVolumes_VGroup1;
      }
      
      public function set _GWizWeightsVolumes_VGroup1(param1:VGroup) : void
      {
         var _loc2_:Object = this._260185223_GWizWeightsVolumes_VGroup1;
         if(_loc2_ !== param1)
         {
            this._260185223_GWizWeightsVolumes_VGroup1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizWeightsVolumes_VGroup1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get costWt() : GWizNumStep
      {
         return this._1354630262costWt;
      }
      
      public function set costWt(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1354630262costWt;
         if(_loc2_ !== param1)
         {
            this._1354630262costWt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"costWt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get markup() : GWizNumStep
      {
         return this._1081305560markup;
      }
      
      public function set markup(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1081305560markup;
         if(_loc2_ !== param1)
         {
            this._1081305560markup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"markup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get materialParentPanel() : GWizForePanel
      {
         return this._2108440531materialParentPanel;
      }
      
      public function set materialParentPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._2108440531materialParentPanel;
         if(_loc2_ !== param1)
         {
            this._2108440531materialParentPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"materialParentPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get typeList() : ArrayList
      {
         return this._676559112typeList;
      }
      
      public function set typeList(param1:ArrayList) : void
      {
         var _loc2_:Object = this._676559112typeList;
         if(_loc2_ !== param1)
         {
            this._676559112typeList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"typeList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get typeSelector() : List
      {
         return this._2036789959typeSelector;
      }
      
      public function set typeSelector(param1:List) : void
      {
         var _loc2_:Object = this._2036789959typeSelector;
         if(_loc2_ !== param1)
         {
            this._2036789959typeSelector = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"typeSelector",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get uIn() : GWizNumStep
      {
         return this._114810uIn;
      }
      
      public function set uIn(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._114810uIn;
         if(_loc2_ !== param1)
         {
            this._114810uIn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"uIn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get wFeet() : CheckBox
      {
         return this._112084677wFeet;
      }
      
      public function set wFeet(param1:CheckBox) : void
      {
         var _loc2_:Object = this._112084677wFeet;
         if(_loc2_ !== param1)
         {
            this._112084677wFeet = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"wFeet",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get wIn() : GWizNumStep
      {
         return this._116732wIn;
      }
      
      public function set wIn(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._116732wIn;
         if(_loc2_ !== param1)
         {
            this._116732wIn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"wIn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xFeet() : CheckBox
      {
         return this._113008198xFeet;
      }
      
      public function set xFeet(param1:CheckBox) : void
      {
         var _loc2_:Object = this._113008198xFeet;
         if(_loc2_ !== param1)
         {
            this._113008198xFeet = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xFeet",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xIn() : GWizNumStep
      {
         return this._117693xIn;
      }
      
      public function set xIn(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._117693xIn;
         if(_loc2_ !== param1)
         {
            this._117693xIn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xIn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yFeet() : CheckBox
      {
         return this._113931719yFeet;
      }
      
      public function set yFeet(param1:CheckBox) : void
      {
         var _loc2_:Object = this._113931719yFeet;
         if(_loc2_ !== param1)
         {
            this._113931719yFeet = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yFeet",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yIn() : GWizNumStep
      {
         return this._118654yIn;
      }
      
      public function set yIn(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._118654yIn;
         if(_loc2_ !== param1)
         {
            this._118654yIn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yIn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get zFeet() : CheckBox
      {
         return this._114855240zFeet;
      }
      
      public function set zFeet(param1:CheckBox) : void
      {
         var _loc2_:Object = this._114855240zFeet;
         if(_loc2_ !== param1)
         {
            this._114855240zFeet = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"zFeet",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get zIn() : GWizNumStep
      {
         return this._119615zIn;
      }
      
      public function set zIn(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._119615zIn;
         if(_loc2_ !== param1)
         {
            this._119615zIn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"zIn",_loc2_,param1));
            }
         }
      }
   }
}
