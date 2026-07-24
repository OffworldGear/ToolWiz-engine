package tools
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import configinfo.GWizConfigData;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.DataGrid;
   import spark.components.HGroup;
   import spark.components.VGroup;
   import spark.components.gridClasses.GridColumn;
   import utils.GWizCSVUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizDrillChart extends GWizForePanel implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1112857018EndMillsInch:CheckBox;
      
      private var _1011212676EndMillsMM:CheckBox;
      
      private var _1446716767TwistDrills:CheckBox;
      
      private var _1323535496drills:DataGrid;
      
      private var _2052278853toolDiameter:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var selectDrillFcn:Function;
      
      private var _1647487323drillData:ArrayCollection;
      
      private var _157190662topLineColor:int = 0;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizDrillChart()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizDrillChart_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizDrillChartWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizDrillChart[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizDrillChart_Array1_c);
         this.addEventListener("creationComplete",this.___GWizDrillChart_GWizForePanel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizDrillChart._watcherSetupUtil = param1;
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
         this.toolDiameter.customArrowInterval(GWizUtils.SIXTEENTH,GWizUtils.TENTH_MM);
         this.drillData = GWizUtils.clone(GWizConfigData.DrillData);
         if(false && GWizUtils.debug)
         {
            GWizCSVUtils.saveCSVFileURL("C:\\Users\\BobWarfield\\Dropbox\\CNCCookbook\\ArticleResearch\\DrillData.csv",GWizConfigData.DrillData,GWizConfigData.drillDataFields);
         }
      }
      
      private function selectDrill() : void
      {
         if(this.selectDrillFcn != null)
         {
            this.selectDrillFcn();
         }
      }
      
      private function search(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this.drillData)
         {
            _loc2_ = 0;
            while(_loc2_ < this.drillData.length)
            {
               _loc3_ = this.drillData.getItemAt(_loc2_);
               if(param1 < _loc3_.inch)
               {
                  if(_loc2_ > 0)
                  {
                     _loc2_--;
                  }
                  this.drills.ensureCellIsVisible(_loc2_);
                  this.drills.selectedIndex = _loc2_;
                  return;
               }
               _loc2_++;
            }
         }
      }
      
      private function filterDrills(param1:Object) : Boolean
      {
         var _loc2_:Boolean = false;
         if(this.TwistDrills.selected)
         {
            _loc2_ = _loc2_ || param1.td != 0;
         }
         if(this.EndMillsInch.selected)
         {
            _loc2_ = _loc2_ || param1.eminch != 0;
         }
         if(this.EndMillsMM.selected)
         {
            _loc2_ = _loc2_ || param1.emmm != 0;
         }
         return _loc2_;
      }
      
      private function doFilter() : void
      {
         this.drillData.filterFunction = this.filterDrills;
         this.drillData.refresh();
      }
      
      public function setFilter(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         this.TwistDrills.selected = param1;
         this.EndMillsInch.selected = param2;
         this.EndMillsMM.selected = param3;
      }
      
      private function renderMetric(param1:Object, param2:GridColumn) : String
      {
         return String(GWizUtils.roundThousandths(param1.inch * 25.4));
      }
      
      private function _GWizDrillChart_Array1_c() : Array
      {
         return [this._GWizDrillChart_VGroup1_c()];
      }
      
      private function _GWizDrillChart_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.paddingTop = 10;
         _loc1_.mxmlContent = [this._GWizDrillChart_HGroup1_c(),this._GWizDrillChart_DataGrid1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDrillChart_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizDrillChart_GWizNumStep1_i(),this._GWizDrillChart_CheckBox1_i(),this._GWizDrillChart_CheckBox2_i(),this._GWizDrillChart_CheckBox3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDrillChart_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Diameter";
         _loc1_.min = 0.0001;
         _loc1_.max = 30;
         _loc1_.steps = 0.001;
         _loc1_.addEventListener("valueCommit",this.__toolDiameter_valueCommit);
         _loc1_.id = "toolDiameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolDiameter = _loc1_;
         BindingManager.executeBindings(this,"toolDiameter",this.toolDiameter);
         return _loc1_;
      }
      
      public function __toolDiameter_valueCommit(param1:FlexEvent) : void
      {
         this.search(this.toolDiameter.getVal());
      }
      
      private function _GWizDrillChart_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Twist Drills";
         _loc1_.selected = true;
         _loc1_.addEventListener("valueCommit",this.__TwistDrills_valueCommit);
         _loc1_.id = "TwistDrills";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TwistDrills = _loc1_;
         BindingManager.executeBindings(this,"TwistDrills",this.TwistDrills);
         return _loc1_;
      }
      
      public function __TwistDrills_valueCommit(param1:FlexEvent) : void
      {
         this.doFilter();
      }
      
      private function _GWizDrillChart_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "End Mills (Imperial)";
         _loc1_.selected = true;
         _loc1_.addEventListener("valueCommit",this.__EndMillsInch_valueCommit);
         _loc1_.id = "EndMillsInch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EndMillsInch = _loc1_;
         BindingManager.executeBindings(this,"EndMillsInch",this.EndMillsInch);
         return _loc1_;
      }
      
      public function __EndMillsInch_valueCommit(param1:FlexEvent) : void
      {
         this.doFilter();
      }
      
      private function _GWizDrillChart_CheckBox3_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "End Mills (Metric)";
         _loc1_.selected = true;
         _loc1_.addEventListener("valueCommit",this.__EndMillsMM_valueCommit);
         _loc1_.id = "EndMillsMM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EndMillsMM = _loc1_;
         BindingManager.executeBindings(this,"EndMillsMM",this.EndMillsMM);
         return _loc1_;
      }
      
      public function __EndMillsMM_valueCommit(param1:FlexEvent) : void
      {
         this.doFilter();
      }
      
      private function _GWizDrillChart_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.x = 10;
         _loc1_.y = 10;
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.variableRowHeight = true;
         _loc1_.doubleClickEnabled = true;
         _loc1_.columns = this._GWizDrillChart_ArrayCollection1_c();
         _loc1_.addEventListener("doubleClick",this.__drills_doubleClick);
         _loc1_.id = "drills";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.drills = _loc1_;
         BindingManager.executeBindings(this,"drills",this.drills);
         return _loc1_;
      }
      
      private function _GWizDrillChart_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = [this._GWizDrillChart_GridColumn1_c(),this._GWizDrillChart_GridColumn2_c(),this._GWizDrillChart_GridColumn3_c(),this._GWizDrillChart_GridColumn4_c()];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizDrillChart_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Inch";
         _loc1_.dataField = "inch";
         _loc1_.width = 90;
         return _loc1_;
      }
      
      private function _GWizDrillChart_GridColumn2_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Metric (mm)";
         _loc1_.dataField = "metric";
         _loc1_.width = 90;
         _loc1_.labelFunction = this.renderMetric;
         return _loc1_;
      }
      
      private function _GWizDrillChart_GridColumn3_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Designation";
         _loc1_.dataField = "designation";
         _loc1_.width = 90;
         return _loc1_;
      }
      
      private function _GWizDrillChart_GridColumn4_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Use";
         _loc1_.dataField = "note";
         return _loc1_;
      }
      
      public function __drills_doubleClick(param1:MouseEvent) : void
      {
         this.selectDrill();
      }
      
      public function ___GWizDrillChart_GWizForePanel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizDrillChart_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,function(param1:uint):void
         {
            toolDiameter.setStyle("color",param1);
         },"toolDiameter.color","topLineColor");
         result[1] = new Binding(this,null,function(param1:uint):void
         {
            TwistDrills.setStyle("color",param1);
         },"TwistDrills.color","topLineColor");
         result[2] = new Binding(this,null,function(param1:uint):void
         {
            EndMillsInch.setStyle("color",param1);
         },"EndMillsInch.color","topLineColor");
         result[3] = new Binding(this,null,function(param1:uint):void
         {
            EndMillsMM.setStyle("color",param1);
         },"EndMillsMM.color","topLineColor");
         result[4] = new Binding(this,function():IList
         {
            return drillData;
         },null,"drills.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get EndMillsInch() : CheckBox
      {
         return this._1112857018EndMillsInch;
      }
      
      public function set EndMillsInch(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1112857018EndMillsInch;
         if(_loc2_ !== param1)
         {
            this._1112857018EndMillsInch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EndMillsInch",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EndMillsMM() : CheckBox
      {
         return this._1011212676EndMillsMM;
      }
      
      public function set EndMillsMM(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1011212676EndMillsMM;
         if(_loc2_ !== param1)
         {
            this._1011212676EndMillsMM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EndMillsMM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TwistDrills() : CheckBox
      {
         return this._1446716767TwistDrills;
      }
      
      public function set TwistDrills(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1446716767TwistDrills;
         if(_loc2_ !== param1)
         {
            this._1446716767TwistDrills = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TwistDrills",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get drills() : DataGrid
      {
         return this._1323535496drills;
      }
      
      public function set drills(param1:DataGrid) : void
      {
         var _loc2_:Object = this._1323535496drills;
         if(_loc2_ !== param1)
         {
            this._1323535496drills = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"drills",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolDiameter() : GWizNumStep
      {
         return this._2052278853toolDiameter;
      }
      
      public function set toolDiameter(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2052278853toolDiameter;
         if(_loc2_ !== param1)
         {
            this._2052278853toolDiameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolDiameter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get drillData() : ArrayCollection
      {
         return this._1647487323drillData;
      }
      
      private function set drillData(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._1647487323drillData;
         if(_loc2_ !== param1)
         {
            this._1647487323drillData = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"drillData",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get topLineColor() : int
      {
         return this._157190662topLineColor;
      }
      
      public function set topLineColor(param1:int) : void
      {
         var _loc2_:Object = this._157190662topLineColor;
         if(_loc2_ !== param1)
         {
            this._157190662topLineColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"topLineColor",_loc2_,param1));
            }
         }
      }
   }
}
