package material
{
   import comps.GWizDataGrid;
   import comps.GWizGridColumn;
   import comps.GWizHardnessChooser;
   import comps.GWizPopUp;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.List;
   import spark.components.TextInput;
   import spark.events.IndexChangeEvent;
   import spark.skins.spark.DefaultGridItemRenderer;
   import utils.GATracker;
   
   use namespace mx_internal;
   
   public class GWizMatBrowser2 extends GWizPopUp implements IBindingClient
   {
      
      public static var alloySFMTweak:Number = 1;
      
      public static var alloyIPTTweak:Number = 1;
      
      private static var _740686515MaterialHistory:ArrayCollection = new ArrayCollection();
      
      public static const MAX_HISTORY:int = 5;
      
      private static var lastSelection:String = "";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _824935202FamLabel:Label;
      
      private var _2096973700Family:List;
      
      private var _2228070Grid:GWizDataGrid;
      
      private var _181289442Hardness:GWizHardnessChooser;
      
      private var _1703379852History:DropDownList;
      
      private var _512802999SearchStr:TextInput;
      
      private var _352074846hardnessCol:GWizGridColumn;
      
      private var _352078787hardnessGrp:HGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var setMaterial:Function = null;
      
      private var selection:String = "";
      
      private var oneShot:Boolean = false;
      
      private var _1471291351GapSize:int = 0;
      
      private var lastSearchStr:String = "";
      
      private var lastSearchPos:int = 0;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizMatBrowser2()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizMatBrowser2_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_material_GWizMatBrowser2WatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizMatBrowser2[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Material Browser";
         this.fullScreen = true;
         this.okLabel = "Select Material";
         this.mxmlContent = [this._GWizMatBrowser2_HGroup1_c(),this._GWizMatBrowser2_Label1_i(),this._GWizMatBrowser2_HGroup2_c(),this._GWizMatBrowser2_Label2_c(),this._GWizMatBrowser2_HGroup3_c(),this._GWizMatBrowser2_HGroup4_i()];
         this.addEventListener("creationComplete",this.___GWizMatBrowser2_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function addHistory(param1:int, param2:Number, param3:String) : void
      {
         var _loc4_:int = 0;
         if(param3 != lastSelection)
         {
            GATracker.logPageView("Material/" + param3,"Material/" + param3);
            lastSelection = param3;
         }
         _loc4_ = 0;
         while(_loc4_ < MaterialHistory.length)
         {
            if(MaterialHistory.getItemAt(_loc4_).name == param3)
            {
               break;
            }
            _loc4_++;
         }
         if(_loc4_ < MaterialHistory.length)
         {
            if(_loc4_ == 0)
            {
               return;
            }
            MaterialHistory.removeItemAt(_loc4_);
         }
         var _loc5_:Object;
         (_loc5_ = new Object()).name = param3;
         _loc5_.family = param1;
         _loc5_.hardness = param2;
         MaterialHistory.addItemAt(_loc5_,0);
         MaterialHistory.refresh();
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizMatBrowser2._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get MaterialHistory() : ArrayCollection
      {
         return GWizMatBrowser2._740686515MaterialHistory;
      }
      
      public static function set MaterialHistory(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMatBrowser2._740686515MaterialHistory;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMatBrowser2,"MaterialHistory",_loc2_,param1));
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
      
      private function doOKCancel(param1:Boolean) : void
      {
         super.close();
         if(param1 && this.setMaterial != null)
         {
            this.doGridSelect();
            this.setMaterial(this.Family.selectedIndex,this.doHardness(),this.selection);
            addHistory(this.Family.selectedIndex,this.doHardness(),this.selection);
         }
         GWizMaterialsDB.AlloyConditionList.filterFunction = null;
         GWizMaterialsDB.AlloyConditionList.refresh();
      }
      
      private function doHardness() : Number
      {
         var _loc1_:String = this.Hardness.Units.selectedItem.name;
         var _loc2_:String = GWizMaterialsDB.BRINELL_TUNG_STR;
         return GWizHardnessChooser.convertHardness(this.Hardness.Hardness.value,_loc1_,_loc2_);
      }
      
      private function doHistory() : void
      {
         if(this.oneShot)
         {
            return;
         }
         var _loc1_:Object = MaterialHistory.getItemAt(this.History.selectedIndex);
         this.Family.selectedIndex = _loc1_.family;
         this.Hardness.Hardness.value = _loc1_.hardness;
         this.selection = _loc1_.name;
         if(_loc1_.hasOwnProperty("janka"))
         {
            GWizSettings.jankaHardness = _loc1_.janka;
         }
         else
         {
            GWizSettings.jankaHardness = -1;
         }
         this.oneShot = true;
         GATracker.logPageView("Material/History/" + this.selection,"Material/History/" + this.selection);
         this.doOKCancel(true);
      }
      
      private function filterByFamily(param1:Object) : Boolean
      {
         return param1.family == this.Family.selectedItem;
      }
      
      private function onCC() : void
      {
         alloySFMTweak = 1;
         alloyIPTTweak = 1;
         GWizMaterialsDB.AlloyConditionList.filterFunction = null;
         GWizMaterialsDB.AlloyConditionList.refresh();
         title = "Material Browser: " + GWizMaterialsDB.AlloyConditionList.length + " materials";
         GWizMaterialsDB.AlloyConditionList.filterFunction = this.filterByFamily;
         this.doFamily();
         MaterialHistory.refresh();
         this.History.selectedIndex = 0;
         GATracker.logPageView("Material/More/","Material/More/");
      }
      
      private function doFamily() : void
      {
         var _loc1_:Object = null;
         GWizMaterialsDB.AlloyConditionList.refresh();
         if(this.Family && this.Family.selectedItem)
         {
            this.selection = this.Family.selectedItem;
            _loc1_ = GWizConfigData.findMaterialMF(this.selection);
            if(_loc1_)
            {
               this.Hardness.Hardness.min = _loc1_.minBHN;
               this.Hardness.Hardness.max = _loc1_.maxBHN;
               this.Hardness.Hardness.value = (_loc1_.maxBHN + _loc1_.minBHN) / 2;
            }
            else
            {
               this.Hardness.Hardness.min = 0;
               this.Hardness.Hardness.max = 1000;
            }
         }
         if(this.selection && (this.selection.indexOf("Softwood") >= 0 || this.selection.indexOf("Hardwood") >= 0))
         {
            this.hardnessCol.headerText = "Hard (Janka)";
            this.hardnessCol.dataField = "janka";
         }
         else
         {
            this.hardnessCol.headerText = "Hardness";
            this.hardnessCol.dataField = "hardness";
         }
      }
      
      private function doGridSelect() : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         if(!this.Grid || !this.Grid.selectedItem)
         {
            return;
         }
         this.hardnessGrp.enabled = false;
         var _loc1_:String = this.Grid.selectedItem.hardness;
         alloySFMTweak = 1;
         alloyIPTTweak = 1;
         if(this.Grid.selectedItem.hasOwnProperty("SFM"))
         {
            alloySFMTweak = this.Grid.selectedItem.SFM;
         }
         if(this.Grid.selectedItem.hasOwnProperty("IPT"))
         {
            alloyIPTTweak = this.Grid.selectedItem.IPT;
         }
         if(_loc1_.length > 0)
         {
            _loc2_ = "";
            _loc3_ = 0;
            _loc4_ = false;
            while(_loc3_ < _loc1_.length && !_loc4_)
            {
               if("0" <= _loc1_.charAt(_loc3_) && _loc1_.charAt(_loc3_) <= "9")
               {
                  _loc2_ += _loc1_.charAt(_loc3_);
               }
               else
               {
                  _loc4_ = true;
               }
               _loc3_++;
            }
            _loc5_ = "";
            while(_loc3_ < _loc1_.length)
            {
               if("0" <= _loc1_.charAt(_loc3_) && _loc1_.charAt(_loc3_) <= "9")
               {
                  _loc5_ += _loc1_.charAt(_loc3_);
               }
               _loc3_++;
            }
            if(_loc5_.length > 0)
            {
               this.Hardness.Hardness.value = Number(_loc5_);
            }
            else if(_loc2_.length > 0)
            {
               this.Hardness.Hardness.value = Number(_loc2_);
            }
            if(this.Grid.selectedItem.hasOwnProperty("janka"))
            {
               GWizSettings.jankaHardness = this.Grid.selectedItem.janka;
            }
            else
            {
               GWizSettings.jankaHardness = -1;
            }
         }
         this.selection = this.Grid.selectedItem.alloy + " " + this.Grid.selectedItem.condition;
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doOKCancel(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doOKCancel(false);
      }
      
      private function doSearch() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:String = null;
         GATracker.logPageView("Material/Search","Material/Search");
         if(this.SearchStr.text != this.lastSearchStr)
         {
            this.lastSearchStr = this.SearchStr.text;
            this.lastSearchPos = 0;
         }
         if(this.lastSearchStr.length > 0)
         {
            GWizMaterialsDB.AlloyConditionList.filterFunction = null;
            GWizMaterialsDB.AlloyConditionList.refresh();
            _loc1_ = this.lastSearchPos;
            while(_loc1_ < GWizMaterialsDB.AlloyConditionList.length)
            {
               _loc2_ = GWizMaterialsDB.AlloyConditionList.getItemAt(_loc1_);
               _loc3_ = _loc2_.family + " " + _loc2_.alloy + " " + _loc2_.altDesignations;
               if(_loc3_.toLowerCase().indexOf(this.SearchStr.text.toLowerCase()) >= 0)
               {
                  this.lastSearchPos = _loc1_ + 1;
                  this.setFamilyByName(_loc2_.family);
                  break;
               }
               _loc1_++;
            }
            GWizMaterialsDB.AlloyConditionList.filterFunction = this.filterByFamily;
            GWizMaterialsDB.AlloyConditionList.refresh();
            this.doFamily();
         }
      }
      
      private function setFamilyByName(param1:String) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < GWizMaterialsDB.MaterialsList.length)
         {
            if(GWizMaterialsDB.MaterialsList[_loc2_] == param1)
            {
               this.Family.selectedIndex = _loc2_;
               return;
            }
            _loc2_++;
         }
      }
      
      protected function doubleClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:DefaultGridItemRenderer = param1.target as DefaultGridItemRenderer;
         if(_loc2_)
         {
            this.doOKCancel(true);
         }
      }
      
      private function _GWizMatBrowser2_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMatBrowser2_TextInput1_i(),this._GWizMatBrowser2_Button1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.prompt = "Enter material to search for";
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Find the material family associated with the search string.";
         _loc1_.id = "SearchStr";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SearchStr = _loc1_;
         BindingManager.executeBindings(this,"SearchStr",this.SearchStr);
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Search";
         _loc1_.toolTip = "Find the material family associated with the search string.";
         _loc1_.addEventListener("click",this.___GWizMatBrowser2_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizMatBrowser2_Button1_click(param1:MouseEvent) : void
      {
         this.doSearch();
      }
      
      private function _GWizMatBrowser2_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Family";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "FamLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FamLabel = _loc1_;
         BindingManager.executeBindings(this,"FamLabel",this.FamLabel);
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMatBrowser2_List1_i(),this._GWizMatBrowser2_GWizDataGrid1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_List1_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.itemRenderer = this._GWizMatBrowser2_ClassFactory1_c();
         _loc1_.addEventListener("valueCommit",this.__Family_valueCommit);
         _loc1_.id = "Family";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Family = _loc1_;
         BindingManager.executeBindings(this,"Family",this.Family);
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_ClassFactory1_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizMatBrowser2InnerClass0;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      public function __Family_valueCommit(param1:FlexEvent) : void
      {
         this.doFamily();
      }
      
      private function _GWizMatBrowser2_GWizDataGrid1_i() : GWizDataGrid
      {
         var _loc1_:GWizDataGrid = new GWizDataGrid();
         _loc1_.configId = "materials";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.doubleClickEnabled = true;
         _loc1_.toolTip = "Double click or press \'OK\' to select a combination.";
         _loc1_.variableRowHeight = true;
         _loc1_.columns = this._GWizMatBrowser2_ArrayList1_c();
         _loc1_.addEventListener("doubleClick",this.__Grid_doubleClick);
         _loc1_.addEventListener("click",this.__Grid_click);
         _loc1_.id = "Grid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Grid = _loc1_;
         BindingManager.executeBindings(this,"Grid",this.Grid);
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizMatBrowser2_GWizGridColumn1_c(),this._GWizMatBrowser2_GWizGridColumn2_c(),this._GWizMatBrowser2_GWizGridColumn3_c(),this._GWizMatBrowser2_GWizGridColumn4_i()];
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_GWizGridColumn1_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colAlloy";
         _loc1_.headerText = "Alloy";
         _loc1_.dataField = "alloy";
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_GWizGridColumn2_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colAltDesignations";
         _loc1_.headerText = "Alt. Names";
         _loc1_.dataField = "altDesignations";
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_GWizGridColumn3_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colCond";
         _loc1_.headerText = "Condition";
         _loc1_.dataField = "condition";
         _loc1_.width = 80;
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_GWizGridColumn4_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colHardness";
         _loc1_.headerText = "Hardness";
         _loc1_.dataField = "hardness";
         _loc1_.width = 80;
         this.hardnessCol = _loc1_;
         BindingManager.executeBindings(this,"hardnessCol",this.hardnessCol);
         return _loc1_;
      }
      
      public function __Grid_doubleClick(param1:MouseEvent) : void
      {
         this.doubleClickHandler(param1);
      }
      
      public function __Grid_click(param1:MouseEvent) : void
      {
         this.doGridSelect();
      }
      
      private function _GWizMatBrowser2_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Missing a Material? Drop us a line.";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMatBrowser2_Label3_c(),this._GWizMatBrowser2_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "History";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 500;
         _loc1_.labelField = "name";
         _loc1_.toolTip = "Choose materials you\'ve used recently.";
         _loc1_.addEventListener("change",this.__History_change);
         _loc1_.id = "History";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.History = _loc1_;
         BindingManager.executeBindings(this,"History",this.History);
         return _loc1_;
      }
      
      public function __History_change(param1:IndexChangeEvent) : void
      {
         this.doHistory();
      }
      
      private function _GWizMatBrowser2_HGroup4_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.enabled = true;
         _loc1_.mxmlContent = [this._GWizMatBrowser2_Label4_c(),this._GWizMatBrowser2_GWizHardnessChooser1_i(),this._GWizMatBrowser2_Label5_c()];
         _loc1_.id = "hardnessGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.hardnessGrp = _loc1_;
         BindingManager.executeBindings(this,"hardnessGrp",this.hardnessGrp);
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hardness";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMatBrowser2_GWizHardnessChooser1_i() : GWizHardnessChooser
      {
         var _loc1_:GWizHardnessChooser = new GWizHardnessChooser();
         _loc1_.toolTip = "If you know the true hardness of your material, enter here.";
         _loc1_.addEventListener("valueCommit",this.__Hardness_valueCommit);
         _loc1_.id = "Hardness";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Hardness = _loc1_;
         BindingManager.executeBindings(this,"Hardness",this.Hardness);
         return _loc1_;
      }
      
      public function __Hardness_valueCommit(param1:FlexEvent) : void
      {
         this.doHardness();
      }
      
      private function _GWizMatBrowser2_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Set hardness or choose an alloy. You can\'t do both.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizMatBrowser2_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizMatBrowser2_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizMaterialsDB.MaterialsListAC;
         },null,"Family.dataProvider");
         result[1] = new Binding(this,function():IList
         {
            return GWizMaterialsDB.AlloyConditionList;
         },null,"Grid.dataProvider");
         result[2] = new Binding(this,function():IList
         {
            return MaterialHistory;
         },null,"History.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get FamLabel() : Label
      {
         return this._824935202FamLabel;
      }
      
      public function set FamLabel(param1:Label) : void
      {
         var _loc2_:Object = this._824935202FamLabel;
         if(_loc2_ !== param1)
         {
            this._824935202FamLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FamLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Family() : List
      {
         return this._2096973700Family;
      }
      
      public function set Family(param1:List) : void
      {
         var _loc2_:Object = this._2096973700Family;
         if(_loc2_ !== param1)
         {
            this._2096973700Family = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Family",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Grid() : GWizDataGrid
      {
         return this._2228070Grid;
      }
      
      public function set Grid(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = this._2228070Grid;
         if(_loc2_ !== param1)
         {
            this._2228070Grid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Grid",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Hardness() : GWizHardnessChooser
      {
         return this._181289442Hardness;
      }
      
      public function set Hardness(param1:GWizHardnessChooser) : void
      {
         var _loc2_:Object = this._181289442Hardness;
         if(_loc2_ !== param1)
         {
            this._181289442Hardness = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Hardness",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get History() : DropDownList
      {
         return this._1703379852History;
      }
      
      public function set History(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1703379852History;
         if(_loc2_ !== param1)
         {
            this._1703379852History = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"History",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SearchStr() : TextInput
      {
         return this._512802999SearchStr;
      }
      
      public function set SearchStr(param1:TextInput) : void
      {
         var _loc2_:Object = this._512802999SearchStr;
         if(_loc2_ !== param1)
         {
            this._512802999SearchStr = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SearchStr",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hardnessCol() : GWizGridColumn
      {
         return this._352074846hardnessCol;
      }
      
      public function set hardnessCol(param1:GWizGridColumn) : void
      {
         var _loc2_:Object = this._352074846hardnessCol;
         if(_loc2_ !== param1)
         {
            this._352074846hardnessCol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hardnessCol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hardnessGrp() : HGroup
      {
         return this._352078787hardnessGrp;
      }
      
      public function set hardnessGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._352078787hardnessGrp;
         if(_loc2_ !== param1)
         {
            this._352078787hardnessGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hardnessGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get GapSize() : int
      {
         return this._1471291351GapSize;
      }
      
      private function set GapSize(param1:int) : void
      {
         var _loc2_:Object = this._1471291351GapSize;
         if(_loc2_ !== param1)
         {
            this._1471291351GapSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GapSize",_loc2_,param1));
            }
         }
      }
   }
}
