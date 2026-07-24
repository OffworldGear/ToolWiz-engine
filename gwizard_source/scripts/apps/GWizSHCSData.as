package apps
{
   import comps.GWizDataGrid;
   import comps.GWizForePanel;
   import comps.GWizGridColumn;
   import configinfo.GWizFastenerData;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.INavigatorContent;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.VGroup;
   import utils.ColorPalette;
   import utils.GWizUtils;
   import views.GWizChamferDrillCalc;
   
   use namespace mx_internal;
   
   public class GWizSHCSData extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1655318225ChamferDiameter:Label;
      
      private var _1817677445CloseDiameter:Label;
      
      private var _989163257CounterboreDepth:Label;
      
      private var _1572800567CounterboreDiameter:Label;
      
      private var _975435597Diagram:Group;
      
      private var _174544591FHAngle:Label;
      
      private var _173555713FHCS100:RadioButton;
      
      private var _2072611628FHCS82:RadioButton;
      
      private var _66858459FHCSM:RadioButton;
      
      private var _1160576369GeometryButtons:HGroup;
      
      private var _1488206509HeadDiameter:Label;
      
      private var _562408116NormalDiameter:Label;
      
      private var _2544005SHCS:RadioButton;
      
      public var _GWizSHCSData_GWizForePanel1:GWizForePanel;
      
      private var _104387img:Image;
      
      private var _1350679377theList:GWizDataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var shcsMetricUnitsData:ArrayCollection;
      
      private var shcsMetricUnitsDataInitialized:Boolean = false;
      
      private var screwType:String = "SHCS";
      
      private var angle:Number = 0;
      
      private var headDia:Number = 0;
      
      private var _2056068094shcsImg:Class;
      
      private var _891545167fhcsImg:Class;
      
      private var theType:String;
      
      private var _embed_mxml_assets_SHCS_jpg_366773148:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizSHCSData()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._2056068094shcsImg = GWizSHCSData_shcsImg;
         this._891545167fhcsImg = GWizSHCSData_fhcsImg;
         this._embed_mxml_assets_SHCS_jpg_366773148 = GWizSHCSData__embed_mxml_assets_SHCS_jpg_366773148;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizSHCSData_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizSHCSDataWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizSHCSData[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.gap = 1;
         this.mxmlContent = [this._GWizSHCSData_GWizForePanel1_i(),this._GWizSHCSData_GWizDataGrid1_i()];
         this.addEventListener("show",this.___GWizSHCSData_VGroup1_show);
         this.addEventListener("creationComplete",this.___GWizSHCSData_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizSHCSData._watcherSetupUtil = param1;
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
      
      private function updateDiagram() : void
      {
         var _loc1_:Object = this.theList.selectedItem;
         if(_loc1_ != null)
         {
            this.ChamferDiameter.text = GWizUtils.sroundThousandths(_loc1_.csdiam,false) + " chamf dia.";
            this.CloseDiameter.text = GWizUtils.sroundThousandths(_loc1_.close,false);
            this.CloseDiameter.text += " to ";
            this.CounterboreDepth.text = GWizUtils.sroundThousandths(_loc1_.cbdepth,false);
            this.CounterboreDiameter.text = GWizUtils.sroundThousandths(_loc1_.cbdiam,false);
            this.HeadDiameter.text = GWizUtils.sroundThousandths(_loc1_.hdiam,false);
            this.headDia = _loc1_.hdiam;
            if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
            {
               this.headDia /= 25.4;
            }
            this.NormalDiameter.text = GWizUtils.sroundThousandths(_loc1_.norm,false);
            if(this.img.source == "assets/FHCS.jpg")
            {
               this.CounterboreDiameter.text = GWizUtils.sroundThousandths(_loc1_.hdiam,false);
            }
         }
      }
      
      private function init() : void
      {
         var _loc1_:Object = null;
         if(this.shcsMetricUnitsDataInitialized)
         {
            return;
         }
         GWizFastenerData.calcDrillSizes();
         this.shcsMetricUnitsData = new ArrayCollection(GWizUtils.clone(GWizFastenerData.SHCSData.source));
         var _loc2_:int = 0;
         while(_loc2_ < this.shcsMetricUnitsData.length)
         {
            _loc1_ = this.shcsMetricUnitsData.getItemAt(_loc2_);
            if(_loc1_)
            {
               _loc1_.hdiam = GWizUtils.roundThousandths(_loc1_.hdiam * 25.4);
               _loc1_.norm = GWizUtils.roundThousandths(_loc1_.norm * 25.4);
               _loc1_.close = GWizUtils.roundThousandths(_loc1_.close * 25.4);
               _loc1_.cbdepth = GWizUtils.roundThousandths(_loc1_.cbdepth * 25.4);
               _loc1_.cbdiam = GWizUtils.roundThousandths(_loc1_.cbdiam * 25.4);
               _loc1_.csdiam = GWizUtils.roundThousandths(_loc1_.csdiam * 25.4);
               this.shcsMetricUnitsData.setItemAt(_loc1_,_loc2_);
            }
            _loc2_++;
         }
         this.shcsMetricUnitsDataInitialized = true;
         GWizFastenerData.SHCSData.filterFunction = this.filterScrews;
         GWizFastenerData.SHCSData.refresh();
      }
      
      private function checkUnits() : void
      {
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS && this.theList.dataProvider != GWizFastenerData.SHCSData)
         {
            this.theList.dataProvider = GWizFastenerData.SHCSData;
            this.theList.invalidateDisplayList();
            this.updateDiagram();
         }
         else if(GWizUtils.Units == GWizUtils.MM_UNITS && this.theList.dataProvider != this.shcsMetricUnitsData)
         {
            if(!this.shcsMetricUnitsDataInitialized)
            {
               this.init();
            }
            this.theList.dataProvider = this.shcsMetricUnitsData;
            this.theList.invalidateDisplayList();
            this.updateDiagram();
         }
      }
      
      private function filterScrews(param1:Object) : Boolean
      {
         return param1.type == this.screwType;
      }
      
      private function changeType() : void
      {
         if(this.SHCS.selected)
         {
            this.img.source = this.shcsImg;
            this.FHAngle.visible = false;
            this.angle = 0;
            this.screwType = "SHCS";
            this.GeometryButtons.visible = false;
         }
         else if(this.FHCS82.selected)
         {
            this.img.source = this.fhcsImg;
            this.FHAngle.visible = true;
            this.FHAngle.text = "80 - 84 degrees";
            this.angle = 82;
            this.screwType = "FHCS82";
            this.GeometryButtons.visible = true;
         }
         else if(this.FHCS100.selected)
         {
            this.img.source = this.fhcsImg;
            this.FHAngle.visible = true;
            this.FHAngle.text = "99 - 101 degrees";
            this.angle = 100;
            this.screwType = "FHCS100";
            this.GeometryButtons.visible = true;
         }
         else if(this.FHCSM.selected)
         {
            this.img.source = this.fhcsImg;
            this.FHAngle.visible = true;
            this.FHAngle.text = "90 - 92 degrees";
            this.angle = 90;
            this.screwType = "FHCSM";
            this.GeometryButtons.visible = true;
         }
         GWizFastenerData.SHCSData.filterFunction = this.filterScrews;
         GWizFastenerData.SHCSData.refresh();
      }
      
      private function sizeCompare(param1:Object, param2:Object) : int
      {
         var _loc3_:String = param1.size;
         var _loc4_:String = param2.size;
         if(_loc3_.search("M") != -1 && _loc4_.search("M") == -1)
         {
            return 1;
         }
         if(_loc3_.search("M") == -1 && _loc4_.search("M") != -1)
         {
            return -1;
         }
         if(param1.norm < param2.norm)
         {
            return -1;
         }
         if(param1.norm > param2.norm)
         {
            return 1;
         }
         return 0;
      }
      
      private function doCountersink(param1:String) : void
      {
         this.theType = param1;
         GWizSettings.appSelector("Geometry",this.countersinkSelected);
      }
      
      private function countersinkSelected(param1:Object) : void
      {
         var _loc2_:GWizGeometry = param1 as GWizGeometry;
         if(_loc2_)
         {
            _loc2_.appSelector(GWizGeometry.CHAMFER_DRILL,this.countersinkSelectCallback);
         }
      }
      
      private function countersinkSelectCallback(param1:Object) : void
      {
         var _loc3_:INavigatorContent = null;
         var _loc2_:GWizChamferDrillCalc = param1 as GWizChamferDrillCalc;
         if(_loc2_)
         {
            _loc3_ = _loc2_.appSelector(this.theType) as INavigatorContent;
            if(_loc3_)
            {
               switch(this.theType)
               {
                  case "Countersink":
                     _loc2_.csAngle.value = this.angle;
                     _loc2_.csDia.setVal(this.headDia);
                     break;
                  case "SpotDrill":
                     _loc2_.sdAngle.value = this.angle;
                     _loc2_.sdChamferDia.setVal(this.headDia);
               }
            }
         }
      }
      
      private function _GWizSHCSData_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizSHCSData_Array2_c);
         _loc1_.id = "_GWizSHCSData_GWizForePanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSHCSData_GWizForePanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSHCSData_GWizForePanel1",this._GWizSHCSData_GWizForePanel1);
         return _loc1_;
      }
      
      private function _GWizSHCSData_Array2_c() : Array
      {
         return [this._GWizSHCSData_VGroup2_c(),this._GWizSHCSData_Group1_i()];
      }
      
      private function _GWizSHCSData_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizSHCSData_Label1_c(),this._GWizSHCSData_RadioButton1_i(),this._GWizSHCSData_RadioButton2_i(),this._GWizSHCSData_RadioButton3_i(),this._GWizSHCSData_RadioButton4_i(),this._GWizSHCSData_Spacer1_c(),this._GWizSHCSData_HGroup1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSHCSData_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Type";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("textDecoration","underline");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSHCSData_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Socket Head Cap Screw";
         _loc1_.selected = true;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("valueCommit",this.__SHCS_valueCommit);
         _loc1_.id = "SHCS";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SHCS = _loc1_;
         BindingManager.executeBindings(this,"SHCS",this.SHCS);
         return _loc1_;
      }
      
      public function __SHCS_valueCommit(param1:FlexEvent) : void
      {
         this.changeType();
      }
      
      private function _GWizSHCSData_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "82 Degree Flat Head Cap Screw";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("valueCommit",this.__FHCS82_valueCommit);
         _loc1_.id = "FHCS82";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FHCS82 = _loc1_;
         BindingManager.executeBindings(this,"FHCS82",this.FHCS82);
         return _loc1_;
      }
      
      public function __FHCS82_valueCommit(param1:FlexEvent) : void
      {
         this.changeType();
      }
      
      private function _GWizSHCSData_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "100 Degree Head Cap Screw";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("valueCommit",this.__FHCS100_valueCommit);
         _loc1_.id = "FHCS100";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FHCS100 = _loc1_;
         BindingManager.executeBindings(this,"FHCS100",this.FHCS100);
         return _loc1_;
      }
      
      public function __FHCS100_valueCommit(param1:FlexEvent) : void
      {
         this.changeType();
      }
      
      private function _GWizSHCSData_RadioButton4_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Metric Flat Head Cap Screw";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("valueCommit",this.__FHCSM_valueCommit);
         _loc1_.id = "FHCSM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FHCSM = _loc1_;
         BindingManager.executeBindings(this,"FHCSM",this.FHCSM);
         return _loc1_;
      }
      
      public function __FHCSM_valueCommit(param1:FlexEvent) : void
      {
         this.changeType();
      }
      
      private function _GWizSHCSData_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSHCSData_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.visible = false;
         _loc1_.mxmlContent = [this._GWizSHCSData_Button1_c(),this._GWizSHCSData_Button2_c()];
         _loc1_.id = "GeometryButtons";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GeometryButtons = _loc1_;
         BindingManager.executeBindings(this,"GeometryButtons",this.GeometryButtons);
         return _loc1_;
      }
      
      private function _GWizSHCSData_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Countersink";
         _loc1_.toolTip = "Switch to Countersink to calculate parameters.";
         _loc1_.addEventListener("click",this.___GWizSHCSData_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizSHCSData_Button1_click(param1:MouseEvent) : void
      {
         this.doCountersink("Countersink");
      }
      
      private function _GWizSHCSData_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Spot Drill";
         _loc1_.toolTip = "Switch to Spot Drill to calculate parameters.";
         _loc1_.addEventListener("click",this.___GWizSHCSData_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizSHCSData_Button2_click(param1:MouseEvent) : void
      {
         this.doCountersink("SpotDrill");
      }
      
      private function _GWizSHCSData_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.width = 600;
         _loc1_.height = 283;
         _loc1_.mxmlContent = [this._GWizSHCSData_Image1_i(),this._GWizSHCSData_Label2_i(),this._GWizSHCSData_Label3_i(),this._GWizSHCSData_Label4_i(),this._GWizSHCSData_Label5_i(),this._GWizSHCSData_Label6_i(),this._GWizSHCSData_Label7_i(),this._GWizSHCSData_Label8_i()];
         _loc1_.id = "Diagram";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Diagram = _loc1_;
         BindingManager.executeBindings(this,"Diagram",this.Diagram);
         return _loc1_;
      }
      
      private function _GWizSHCSData_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml_assets_SHCS_jpg_366773148;
         _loc1_.height = 283;
         _loc1_.width = 600;
         _loc1_.x = 0;
         _loc1_.y = 0;
         _loc1_.id = "img";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img = _loc1_;
         BindingManager.executeBindings(this,"img",this.img);
         return _loc1_;
      }
      
      private function _GWizSHCSData_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 42;
         _loc1_.y = 142;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "HeadDiameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HeadDiameter = _loc1_;
         BindingManager.executeBindings(this,"HeadDiameter",this.HeadDiameter);
         return _loc1_;
      }
      
      private function _GWizSHCSData_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 131;
         _loc1_.y = 95;
         _loc1_.text = "9.999\"";
         _loc1_.toolTip = "OD of chamfer";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "ChamferDiameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ChamferDiameter = _loc1_;
         BindingManager.executeBindings(this,"ChamferDiameter",this.ChamferDiameter);
         return _loc1_;
      }
      
      private function _GWizSHCSData_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 511;
         _loc1_.y = 128;
         _loc1_.text = "9.999\" to";
         _loc1_.width = 56;
         _loc1_.height = 22;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "CloseDiameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CloseDiameter = _loc1_;
         BindingManager.executeBindings(this,"CloseDiameter",this.CloseDiameter);
         return _loc1_;
      }
      
      private function _GWizSHCSData_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 511;
         _loc1_.y = 158;
         _loc1_.text = "9.999\"";
         _loc1_.width = 56;
         _loc1_.height = 22;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "NormalDiameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.NormalDiameter = _loc1_;
         BindingManager.executeBindings(this,"NormalDiameter",this.NormalDiameter);
         return _loc1_;
      }
      
      private function _GWizSHCSData_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 264;
         _loc1_.y = 142;
         _loc1_.text = "9.999\"";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "CounterboreDiameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CounterboreDiameter = _loc1_;
         BindingManager.executeBindings(this,"CounterboreDiameter",this.CounterboreDiameter);
         return _loc1_;
      }
      
      private function _GWizSHCSData_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 319;
         _loc1_.y = 249;
         _loc1_.text = "9.999\"";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "CounterboreDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CounterboreDepth = _loc1_;
         BindingManager.executeBindings(this,"CounterboreDepth",this.CounterboreDepth);
         return _loc1_;
      }
      
      private function _GWizSHCSData_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 99;
         _loc1_.y = 80;
         _loc1_.text = "80 - 84 degrees";
         _loc1_.visible = false;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "FHAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FHAngle = _loc1_;
         BindingManager.executeBindings(this,"FHAngle",this.FHAngle);
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizDataGrid1_i() : GWizDataGrid
      {
         var _loc1_:GWizDataGrid = new GWizDataGrid();
         _loc1_.configId = "fasteners";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.columns = this._GWizSHCSData_ArrayList1_c();
         _loc1_.addEventListener("valueCommit",this.__theList_valueCommit);
         _loc1_.addEventListener("render",this.__theList_render);
         _loc1_.id = "theList";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theList = _loc1_;
         BindingManager.executeBindings(this,"theList",this.theList);
         return _loc1_;
      }
      
      private function _GWizSHCSData_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizSHCSData_GWizGridColumn1_c(),this._GWizSHCSData_GWizGridColumn2_c(),this._GWizSHCSData_GWizGridColumn3_c(),this._GWizSHCSData_GWizGridColumn4_c(),this._GWizSHCSData_GWizGridColumn5_c(),this._GWizSHCSData_GWizGridColumn6_c(),this._GWizSHCSData_GWizGridColumn7_c(),this._GWizSHCSData_GWizGridColumn8_c(),this._GWizSHCSData_GWizGridColumn9_c(),this._GWizSHCSData_GWizGridColumn10_c()];
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizGridColumn1_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colSize";
         _loc1_.headerText = "Size";
         _loc1_.dataField = "size";
         _loc1_.width = 100;
         _loc1_.sortCompareFunction = this.sizeCompare;
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizGridColumn2_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colHeadDia";
         _loc1_.headerText = "Head Diameter";
         _loc1_.dataField = "hdiam";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizGridColumn3_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colNormDia";
         _loc1_.headerText = "Normal Diam.";
         _loc1_.dataField = "norm";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizGridColumn4_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colNormDrill";
         _loc1_.headerText = "Normal Drill";
         _loc1_.dataField = "normDrill";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizGridColumn5_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colCloseDia";
         _loc1_.headerText = "Close Diam.";
         _loc1_.dataField = "close";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizGridColumn6_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colCloseFit";
         _loc1_.headerText = "Close Fit Drill";
         _loc1_.dataField = "closeFitDrill";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizGridColumn7_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colCBoreDepth";
         _loc1_.headerText = "CBore Depth";
         _loc1_.dataField = "cbdepth";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizGridColumn8_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colCBoreDiam";
         _loc1_.headerText = "CBore Diam.";
         _loc1_.dataField = "cbdiam";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizGridColumn9_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colChamfDiam";
         _loc1_.headerText = "Chamf Diam.";
         _loc1_.dataField = "csdiam";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizSHCSData_GWizGridColumn10_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colHexKey";
         _loc1_.headerText = "Hex Key";
         _loc1_.dataField = "hex";
         return _loc1_;
      }
      
      public function __theList_valueCommit(param1:FlexEvent) : void
      {
         this.updateDiagram();
      }
      
      public function __theList_render(param1:Event) : void
      {
         this.checkUnits();
      }
      
      public function ___GWizSHCSData_VGroup1_show(param1:FlexEvent) : void
      {
         this.checkUnits();
      }
      
      public function ___GWizSHCSData_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.theList.selectedIndex = 0;
         this.init();
         this.updateDiagram();
      }
      
      private function _GWizSHCSData_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizSHCSData_GWizForePanel1.labelBackgroundColor");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizSHCSData_GWizForePanel1.labelColor");
         result[2] = new Binding(this,function():IList
         {
            return GWizFastenerData.SHCSData;
         },null,"theList.dataProvider");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb4;
         },function(param1:uint):void
         {
            theList.setStyle("selectionColor",param1);
         },"theList.selectionColor");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            theList.setStyle("rollOverColor",param1);
         },"theList.rollOverColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get ChamferDiameter() : Label
      {
         return this._1655318225ChamferDiameter;
      }
      
      public function set ChamferDiameter(param1:Label) : void
      {
         var _loc2_:Object = this._1655318225ChamferDiameter;
         if(_loc2_ !== param1)
         {
            this._1655318225ChamferDiameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ChamferDiameter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CloseDiameter() : Label
      {
         return this._1817677445CloseDiameter;
      }
      
      public function set CloseDiameter(param1:Label) : void
      {
         var _loc2_:Object = this._1817677445CloseDiameter;
         if(_loc2_ !== param1)
         {
            this._1817677445CloseDiameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CloseDiameter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CounterboreDepth() : Label
      {
         return this._989163257CounterboreDepth;
      }
      
      public function set CounterboreDepth(param1:Label) : void
      {
         var _loc2_:Object = this._989163257CounterboreDepth;
         if(_loc2_ !== param1)
         {
            this._989163257CounterboreDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CounterboreDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CounterboreDiameter() : Label
      {
         return this._1572800567CounterboreDiameter;
      }
      
      public function set CounterboreDiameter(param1:Label) : void
      {
         var _loc2_:Object = this._1572800567CounterboreDiameter;
         if(_loc2_ !== param1)
         {
            this._1572800567CounterboreDiameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CounterboreDiameter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Diagram() : Group
      {
         return this._975435597Diagram;
      }
      
      public function set Diagram(param1:Group) : void
      {
         var _loc2_:Object = this._975435597Diagram;
         if(_loc2_ !== param1)
         {
            this._975435597Diagram = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Diagram",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FHAngle() : Label
      {
         return this._174544591FHAngle;
      }
      
      public function set FHAngle(param1:Label) : void
      {
         var _loc2_:Object = this._174544591FHAngle;
         if(_loc2_ !== param1)
         {
            this._174544591FHAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FHAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FHCS100() : RadioButton
      {
         return this._173555713FHCS100;
      }
      
      public function set FHCS100(param1:RadioButton) : void
      {
         var _loc2_:Object = this._173555713FHCS100;
         if(_loc2_ !== param1)
         {
            this._173555713FHCS100 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FHCS100",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FHCS82() : RadioButton
      {
         return this._2072611628FHCS82;
      }
      
      public function set FHCS82(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2072611628FHCS82;
         if(_loc2_ !== param1)
         {
            this._2072611628FHCS82 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FHCS82",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FHCSM() : RadioButton
      {
         return this._66858459FHCSM;
      }
      
      public function set FHCSM(param1:RadioButton) : void
      {
         var _loc2_:Object = this._66858459FHCSM;
         if(_loc2_ !== param1)
         {
            this._66858459FHCSM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FHCSM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GeometryButtons() : HGroup
      {
         return this._1160576369GeometryButtons;
      }
      
      public function set GeometryButtons(param1:HGroup) : void
      {
         var _loc2_:Object = this._1160576369GeometryButtons;
         if(_loc2_ !== param1)
         {
            this._1160576369GeometryButtons = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GeometryButtons",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HeadDiameter() : Label
      {
         return this._1488206509HeadDiameter;
      }
      
      public function set HeadDiameter(param1:Label) : void
      {
         var _loc2_:Object = this._1488206509HeadDiameter;
         if(_loc2_ !== param1)
         {
            this._1488206509HeadDiameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HeadDiameter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get NormalDiameter() : Label
      {
         return this._562408116NormalDiameter;
      }
      
      public function set NormalDiameter(param1:Label) : void
      {
         var _loc2_:Object = this._562408116NormalDiameter;
         if(_loc2_ !== param1)
         {
            this._562408116NormalDiameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"NormalDiameter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SHCS() : RadioButton
      {
         return this._2544005SHCS;
      }
      
      public function set SHCS(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2544005SHCS;
         if(_loc2_ !== param1)
         {
            this._2544005SHCS = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SHCS",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img() : Image
      {
         return this._104387img;
      }
      
      public function set img(param1:Image) : void
      {
         var _loc2_:Object = this._104387img;
         if(_loc2_ !== param1)
         {
            this._104387img = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theList() : GWizDataGrid
      {
         return this._1350679377theList;
      }
      
      public function set theList(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = this._1350679377theList;
         if(_loc2_ !== param1)
         {
            this._1350679377theList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get shcsImg() : Class
      {
         return this._2056068094shcsImg;
      }
      
      public function set shcsImg(param1:Class) : void
      {
         var _loc2_:Object = this._2056068094shcsImg;
         if(_loc2_ !== param1)
         {
            this._2056068094shcsImg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"shcsImg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fhcsImg() : Class
      {
         return this._891545167fhcsImg;
      }
      
      public function set fhcsImg(param1:Class) : void
      {
         var _loc2_:Object = this._891545167fhcsImg;
         if(_loc2_ !== param1)
         {
            this._891545167fhcsImg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fhcsImg",_loc2_,param1));
            }
         }
      }
   }
}
