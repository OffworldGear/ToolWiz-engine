package machines
{
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import flash.display.DisplayObject;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.containers.ViewStack;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.AppButtonBarSkin;
   import spark.components.Button;
   import spark.components.ButtonBar;
   import spark.components.DataGrid;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NavigatorContent;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import spark.components.gridClasses.GridColumn;
   import spark.events.IndexChangeEvent;
   import spark.layouts.TileLayout;
   import utils.ColorPalette;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizMachBrowser extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizMachBrowser");
      
      private static const SHOW_ALL:String = "<Show All>";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizMachBrowser_Button1:Button;
      
      public var _GWizMachBrowser_Button3:Button;
      
      public var _GWizMachBrowser_Label1:Label;
      
      public var _GWizMachBrowser_NavigatorContent1:NavigatorContent;
      
      public var _GWizMachBrowser_NavigatorContent2:NavigatorContent;
      
      private var _124513530makeFilter:DropDownList;
      
      private var _1452961698modeButtons:ButtonBar;
      
      private var _207437474modeSelector:ViewStack;
      
      private var _1060275094myList:DataGrid;
      
      private var _1778179843searchBox:TextInput;
      
      private var _1350679377theList:DataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _779970058machProvider:ArrayCollection;
      
      private var _1973759699myShopProvider:ArrayCollection;
      
      private var _103659589makes:ArrayCollection;
      
      private var makesHash:Object;
      
      private var originalMachine:String;
      
      private var _1909287768lockSafe:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizMachBrowser()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._103659589makes = new ArrayCollection();
         this.makesHash = new Object();
         this.originalMachine = GWizMachSettings.currMachine;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizMachBrowser_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_machines_GWizMachBrowserWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizMachBrowser[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Select Machine...";
         this.cancelLabel = "";
         this.fullScreen = true;
         this.mxmlContent = [this._GWizMachBrowser_ButtonBar1_i(),this._GWizMachBrowser_ViewStack1_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function machBrowse(param1:ArrayCollection, param2:ArrayCollection, param3:int, param4:Number, param5:Number, param6:DisplayObject = null) : GWizMachBrowser
      {
         var _loc7_:GWizMachBrowser;
         if(_loc7_ = GWizMachBrowser(GWizPopUpManager.createPopUp(param6,GWizMachBrowser,true)))
         {
            _loc7_.lockSafe = GWizAbstractPrefs.gotLock();
            _loc7_.machProvider = param1;
            _loc7_.myShopProvider = param2;
            if(param3 < 0)
            {
               param3 = 0;
            }
            _loc7_.theList.selectedIndex = param3;
            _loc7_.init();
            _loc7_.x = param4;
            _loc7_.y = param5;
         }
         return _loc7_;
      }
      
      public static function changeMachine(param1:String) : void
      {
         if(param1 != "")
         {
            GWizMachSettings.currMachine = param1;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizMachBrowser._watcherSetupUtil = param1;
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
      
      private function init() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         GWizUtils.assert(this.machProvider != null);
         this.machProvider.filterFunction = null;
         GWizUtils.arrayCollectionSort(this.machProvider,"name",false);
         this.machProvider.refresh();
         _loc2_ = 0;
         while(_loc2_ < this.machProvider.length)
         {
            _loc3_ = this.machProvider.getItemAt(_loc2_);
            if(_loc3_.hasOwnProperty("make") && !this.makesHash[_loc3_.make])
            {
               this.addMake(_loc3_.make);
            }
            _loc2_++;
         }
         this.addMake(SHOW_ALL);
         GWizUtils.arrayCollectionSort(this.makes,"make",false);
         this.makeFilter.selectedIndex = 0;
         _loc2_ = 0;
         while(_loc2_ < this.machProvider.length)
         {
            _loc3_ = this.machProvider.getItemAt(_loc2_);
            if(_loc3_.hasOwnProperty("name") && _loc3_.name == this.originalMachine)
            {
               this.theList.selectedIndex = _loc2_;
               break;
            }
            _loc2_++;
         }
         if(this.myShopProvider.length <= 0)
         {
            this.modeSelector.selectedIndex = 1;
         }
      }
      
      private function addMake(param1:String) : void
      {
         var _loc2_:Object = null;
         if(param1 && param1 != "" && !this.makesHash[param1])
         {
            _loc2_ = new Object();
            _loc2_.make = param1;
            this.makes.addItem(_loc2_);
            this.makesHash[param1] = true;
         }
      }
      
      private function filterMakes() : void
      {
         if(this.makeFilter.selectedIndex >= 0 && this.makeFilter.selectedItem.make != SHOW_ALL)
         {
            this.machProvider.filterFunction = this.filterMakesFcn;
         }
         else
         {
            this.machProvider.filterFunction = null;
         }
         this.machProvider.refresh();
      }
      
      private function filterMakesFcn(param1:Object) : Boolean
      {
         return param1.make == this.makeFilter.selectedItem.make;
      }
      
      private function onChange() : void
      {
         if(this.modeButtons.selectedIndex > 0)
         {
            if(this.theList.selectedIndex < 0)
            {
               this.theList.selectedIndex = 0;
            }
            if(this.theList.selectedItem)
            {
               changeMachine(this.theList.selectedItem.name);
            }
            else
            {
               this.callLater(this.onChange);
            }
         }
         else
         {
            if(this.myShopProvider.length <= 0)
            {
               return;
            }
            if(this.myList.selectedIndex < 0)
            {
               this.myList.selectedIndex = 0;
            }
            if(this.myList.selectedItem)
            {
               changeMachine(this.myList.selectedItem.name);
            }
            else
            {
               this.callLater(this.onChange);
            }
         }
      }
      
      override public function close() : void
      {
         this.machProvider.filterFunction = null;
         this.machProvider.refresh();
         this.lockSafe = false;
         super.close();
      }
      
      private function addToMyShop() : void
      {
         if(this.theList.selectedIndex < 0)
         {
            this.theList.selectedIndex = 0;
         }
         var _loc1_:Object = this.machProvider.getItemAt(this.theList.selectedIndex);
         GWizMachSettings.addToMyShop(_loc1_.name,_loc1_.make,_loc1_.model);
      }
      
      private function removeFromMyShop() : void
      {
         if(this.myList.selectedIndex < 0)
         {
            return;
         }
         this.myShopProvider.removeItemAt(this.myList.selectedIndex);
      }
      
      private function quickHelp() : void
      {
         GWizUtils.doWebPage("https://www.cnccookbook.com/g-wizard-videos/machine-selector/");
      }
      
      private function doSearch() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(this.machProvider && this.machProvider.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this.machProvider.length)
            {
               _loc2_ = this.machProvider.getItemAt(_loc1_);
               _loc3_ = _loc2_.name + _loc2_.make + _loc2_.model;
               _loc3_ = GWizStringUtils.zapWhiteSpace(_loc3_).toLowerCase();
               _loc4_ = GWizStringUtils.zapWhiteSpace(this.searchBox.text).toLowerCase();
               if(_loc3_.search(_loc4_) >= 0)
               {
                  this.theList.selectedIndex = _loc1_;
                  this.theList.ensureCellIsVisible(_loc1_);
                  return;
               }
               _loc1_++;
            }
         }
      }
      
      private function _GWizMachBrowser_ButtonBar1_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.percentWidth = 100;
         _loc1_.requireSelection = true;
         _loc1_.horizontalCenter = 0;
         _loc1_.verticalCenter = 0;
         _loc1_.layout = this._GWizMachBrowser_TileLayout1_c();
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("skinClass",AppButtonBarSkin);
         _loc1_.id = "modeButtons";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.modeButtons = _loc1_;
         BindingManager.executeBindings(this,"modeButtons",this.modeButtons);
         return _loc1_;
      }
      
      private function _GWizMachBrowser_TileLayout1_c() : TileLayout
      {
         var _loc1_:TileLayout = new TileLayout();
         _loc1_.requestedRowCount = 1;
         _loc1_.columnAlign = "justifyUsingWidth";
         _loc1_.paddingLeft = 0;
         _loc1_.paddingRight = 0;
         _loc1_.horizontalGap = 0;
         return _loc1_;
      }
      
      private function _GWizMachBrowser_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.creationPolicy = "all";
         temp.id = "modeSelector";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"modeSelector",
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizMachBrowser_NavigatorContent1",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"My Shop",
                        "name":"MyShop",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizMachBrowser_Array2_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizMachBrowser_NavigatorContent2",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"All Machines",
                        "name":"AllMachines",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizMachBrowser_Array6_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.modeSelector = temp;
         BindingManager.executeBindings(this,"modeSelector",this.modeSelector);
         return temp;
      }
      
      private function _GWizMachBrowser_Array2_c() : Array
      {
         return [this._GWizMachBrowser_VGroup1_c()];
      }
      
      private function _GWizMachBrowser_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizMachBrowser_DataGrid1_i(),this._GWizMachBrowser_HGroup1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.editable = false;
         _loc1_.columns = this._GWizMachBrowser_ArrayList1_c();
         _loc1_.addEventListener("valueCommit",this.__myList_valueCommit);
         _loc1_.id = "myList";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.myList = _loc1_;
         BindingManager.executeBindings(this,"myList",this.myList);
         return _loc1_;
      }
      
      private function _GWizMachBrowser_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizMachBrowser_GridColumn1_c(),this._GWizMachBrowser_GridColumn2_c(),this._GWizMachBrowser_GridColumn3_c(),this._GWizMachBrowser_GridColumn4_c()];
         return _loc1_;
      }
      
      private function _GWizMachBrowser_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Description";
         _loc1_.dataField = "description";
         _loc1_.editable = true;
         return _loc1_;
      }
      
      private function _GWizMachBrowser_GridColumn2_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Name";
         _loc1_.dataField = "name";
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizMachBrowser_GridColumn3_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Make";
         _loc1_.dataField = "make";
         _loc1_.width = 100;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizMachBrowser_GridColumn4_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Model";
         _loc1_.dataField = "model";
         _loc1_.editable = false;
         return _loc1_;
      }
      
      public function __myList_valueCommit(param1:FlexEvent) : void
      {
         this.onChange();
      }
      
      private function _GWizMachBrowser_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.mxmlContent = [this._GWizMachBrowser_Button1_i(),this._GWizMachBrowser_Spacer1_c(),this._GWizMachBrowser_Label1_i(),this._GWizMachBrowser_Button2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Delete from My Shop";
         _loc1_.toolTip = "Delete currently selected machine from My Shop.  You can get it back from the All Machines tab.";
         _loc1_.addEventListener("click",this.___GWizMachBrowser_Button1_click);
         _loc1_.id = "_GWizMachBrowser_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachBrowser_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachBrowser_Button1",this._GWizMachBrowser_Button1);
         return _loc1_;
      }
      
      public function ___GWizMachBrowser_Button1_click(param1:MouseEvent) : void
      {
         this.removeFromMyShop();
      }
      
      private function _GWizMachBrowser_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Add machines to your shop from the All Machines tab. Click to edit Description.";
         _loc1_.id = "_GWizMachBrowser_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachBrowser_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachBrowser_Label1",this._GWizMachBrowser_Label1);
         return _loc1_;
      }
      
      private function _GWizMachBrowser_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Help ?";
         _loc1_.addEventListener("click",this.___GWizMachBrowser_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizMachBrowser_Button2_click(param1:MouseEvent) : void
      {
         this.quickHelp();
      }
      
      private function _GWizMachBrowser_Array6_c() : Array
      {
         return [this._GWizMachBrowser_VGroup2_c()];
      }
      
      private function _GWizMachBrowser_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingTop = 3;
         _loc1_.mxmlContent = [this._GWizMachBrowser_HGroup2_c(),this._GWizMachBrowser_HGroup3_c(),this._GWizMachBrowser_DataGrid2_i(),this._GWizMachBrowser_HGroup4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachBrowser_Label2_c(),this._GWizMachBrowser_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Search";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.prompt = "Search Text";
         _loc1_.addEventListener("keyUp",this.__searchBox_keyUp);
         _loc1_.id = "searchBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.searchBox = _loc1_;
         BindingManager.executeBindings(this,"searchBox",this.searchBox);
         return _loc1_;
      }
      
      public function __searchBox_keyUp(param1:KeyboardEvent) : void
      {
         this.doSearch();
      }
      
      private function _GWizMachBrowser_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachBrowser_Label3_c(),this._GWizMachBrowser_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Make";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "make";
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("change",this.__makeFilter_change);
         _loc1_.id = "makeFilter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.makeFilter = _loc1_;
         BindingManager.executeBindings(this,"makeFilter",this.makeFilter);
         return _loc1_;
      }
      
      public function __makeFilter_change(param1:IndexChangeEvent) : void
      {
         this.filterMakes();
      }
      
      private function _GWizMachBrowser_DataGrid2_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.columns = this._GWizMachBrowser_ArrayList2_c();
         _loc1_.addEventListener("valueCommit",this.__theList_valueCommit);
         _loc1_.id = "theList";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theList = _loc1_;
         BindingManager.executeBindings(this,"theList",this.theList);
         return _loc1_;
      }
      
      private function _GWizMachBrowser_ArrayList2_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizMachBrowser_GridColumn5_c(),this._GWizMachBrowser_GridColumn6_c(),this._GWizMachBrowser_GridColumn7_c(),this._GWizMachBrowser_GridColumn8_c()];
         return _loc1_;
      }
      
      private function _GWizMachBrowser_GridColumn5_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Name";
         _loc1_.dataField = "name";
         return _loc1_;
      }
      
      private function _GWizMachBrowser_GridColumn6_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Type";
         _loc1_.dataField = "type";
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizMachBrowser_GridColumn7_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Make";
         _loc1_.dataField = "make";
         _loc1_.width = 150;
         return _loc1_;
      }
      
      private function _GWizMachBrowser_GridColumn8_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Model";
         _loc1_.dataField = "model";
         return _loc1_;
      }
      
      public function __theList_valueCommit(param1:FlexEvent) : void
      {
         this.onChange();
      }
      
      private function _GWizMachBrowser_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.mxmlContent = [this._GWizMachBrowser_Button3_i(),this._GWizMachBrowser_Spacer2_c(),this._GWizMachBrowser_Label4_c(),this._GWizMachBrowser_Button4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Add to My Shop";
         _loc1_.toolTip = "Add currently selected machine to My Shop tab.";
         _loc1_.addEventListener("click",this.___GWizMachBrowser_Button3_click);
         _loc1_.id = "_GWizMachBrowser_Button3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachBrowser_Button3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachBrowser_Button3",this._GWizMachBrowser_Button3);
         return _loc1_;
      }
      
      public function ___GWizMachBrowser_Button3_click(param1:MouseEvent) : void
      {
         this.addToMyShop();
      }
      
      private function _GWizMachBrowser_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Note: You can create your own profiles in setup easily, or we\'ll make one for you for free.  Click the Help button to learn more.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachBrowser_Button4_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Help ?";
         _loc1_.addEventListener("click",this.___GWizMachBrowser_Button4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizMachBrowser_Button4_click(param1:MouseEvent) : void
      {
         this.quickHelp();
      }
      
      private function _GWizMachBrowser_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"modeButtons.dataProvider","modeSelector");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.primary4;
         },function(param1:uint):void
         {
            modeButtons.setStyle("chromeColor",param1);
         },"modeButtons.chromeColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.primary1;
         },function(param1:uint):void
         {
            _GWizMachBrowser_NavigatorContent1.setStyle("backgroundColor",param1);
         },"_GWizMachBrowser_NavigatorContent1.backgroundColor");
         result[3] = new Binding(this,function():IList
         {
            return myShopProvider;
         },null,"myList.dataProvider");
         result[4] = new Binding(this,function():Boolean
         {
            return lockSafe;
         },null,"_GWizMachBrowser_Button1.visible");
         result[5] = new Binding(this,function():Boolean
         {
            return lockSafe;
         },null,"_GWizMachBrowser_Label1.visible");
         result[6] = new Binding(this,function():uint
         {
            return ColorPalette.primary1;
         },function(param1:uint):void
         {
            _GWizMachBrowser_NavigatorContent2.setStyle("backgroundColor",param1);
         },"_GWizMachBrowser_NavigatorContent2.backgroundColor");
         result[7] = new Binding(this,function():IList
         {
            return makes;
         },null,"makeFilter.dataProvider");
         result[8] = new Binding(this,function():IList
         {
            return machProvider;
         },null,"theList.dataProvider");
         result[9] = new Binding(this,function():Boolean
         {
            return lockSafe;
         },null,"_GWizMachBrowser_Button3.visible");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get makeFilter() : DropDownList
      {
         return this._124513530makeFilter;
      }
      
      public function set makeFilter(param1:DropDownList) : void
      {
         var _loc2_:Object = this._124513530makeFilter;
         if(_loc2_ !== param1)
         {
            this._124513530makeFilter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"makeFilter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get modeButtons() : ButtonBar
      {
         return this._1452961698modeButtons;
      }
      
      public function set modeButtons(param1:ButtonBar) : void
      {
         var _loc2_:Object = this._1452961698modeButtons;
         if(_loc2_ !== param1)
         {
            this._1452961698modeButtons = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"modeButtons",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get modeSelector() : ViewStack
      {
         return this._207437474modeSelector;
      }
      
      public function set modeSelector(param1:ViewStack) : void
      {
         var _loc2_:Object = this._207437474modeSelector;
         if(_loc2_ !== param1)
         {
            this._207437474modeSelector = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"modeSelector",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get myList() : DataGrid
      {
         return this._1060275094myList;
      }
      
      public function set myList(param1:DataGrid) : void
      {
         var _loc2_:Object = this._1060275094myList;
         if(_loc2_ !== param1)
         {
            this._1060275094myList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"myList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get searchBox() : TextInput
      {
         return this._1778179843searchBox;
      }
      
      public function set searchBox(param1:TextInput) : void
      {
         var _loc2_:Object = this._1778179843searchBox;
         if(_loc2_ !== param1)
         {
            this._1778179843searchBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"searchBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theList() : DataGrid
      {
         return this._1350679377theList;
      }
      
      public function set theList(param1:DataGrid) : void
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
      private function get machProvider() : ArrayCollection
      {
         return this._779970058machProvider;
      }
      
      private function set machProvider(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._779970058machProvider;
         if(_loc2_ !== param1)
         {
            this._779970058machProvider = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machProvider",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get myShopProvider() : ArrayCollection
      {
         return this._1973759699myShopProvider;
      }
      
      private function set myShopProvider(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._1973759699myShopProvider;
         if(_loc2_ !== param1)
         {
            this._1973759699myShopProvider = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"myShopProvider",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get makes() : ArrayCollection
      {
         return this._103659589makes;
      }
      
      private function set makes(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._103659589makes;
         if(_loc2_ !== param1)
         {
            this._103659589makes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"makes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get lockSafe() : Boolean
      {
         return this._1909287768lockSafe;
      }
      
      private function set lockSafe(param1:Boolean) : void
      {
         var _loc2_:Object = this._1909287768lockSafe;
         if(_loc2_ !== param1)
         {
            this._1909287768lockSafe = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"lockSafe",_loc2_,param1));
            }
         }
      }
   }
}
