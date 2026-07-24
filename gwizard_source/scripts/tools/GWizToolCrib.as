package tools
{
   import comps.GWizDataGrid;
   import comps.GWizFileBrowser;
   import comps.GWizForePanel;
   import comps.GWizGridColumn;
   import comps.GWizNumStep;
   import comps.GWizPopUpManager;
   import comps.GWizTableName;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import feedsspeeds.GWizMfgFamilyPopup;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.Proxy;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.containers.HDividedBox;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.CloseEvent;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.utils.StringUtil;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButtonGroup;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import spark.events.TextOperationEvent;
   import spark.layouts.VerticalLayout;
   import utils.GATracker;
   import utils.GWizCSVUtils;
   import utils.GWizJustASec;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizToolCrib extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizToolCrib");
      
      private static var _533223842field1Name:String = "Field 1";
      
      private static var _534147363field2Name:String = "Field 2";
      
      private static var _535070884field3Name:String = "Field 3";
      
      private static var _535994405field4Name:String = "Field 4";
      
      private static var _139385291lockToolCrib:Boolean = false;
      
      private static var _1988717703tableName:String = "";
      
      public static var showGeneration:int = 0;
      
      private static const TOOLCRIB_DOWNLOAD_FOLDER:String = "http://cnccookbook.com/img/GWizard/Downloads/ToolCribs/";
      
      private static var downloadedCribName:String = "";
      
      private static var cribDownloadQueue:Array = [];
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1073484516DescLab:Label;
      
      private var _69798G10:Button;
      
      private var _151342134GrabData:Button;
      
      private var _1849163057ToolCompData:HGroup;
      
      public var _GWizToolCrib_Button16:Button;
      
      public var _GWizToolCrib_Button19:Button;
      
      public var _GWizToolCrib_Button9:Button;
      
      public var _GWizToolCrib_ClassFactory1:ClassFactory;
      
      public var _GWizToolCrib_ClassFactory2:ClassFactory;
      
      public var _GWizToolCrib_ClassFactory3:ClassFactory;
      
      public var _GWizToolCrib_GWizGridColumn1:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn16:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn17:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn18:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn19:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn20:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn21:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn22:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn23:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn24:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn25:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn26:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn27:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn28:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn29:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn30:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn31:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn32:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn33:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn34:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn35:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn39:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn41:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn42:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn43:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn44:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn45:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn46:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn47:GWizGridColumn;
      
      public var _GWizToolCrib_GWizGridColumn48:GWizGridColumn;
      
      public var _GWizToolCrib_HGroup7:HGroup;
      
      public var _GWizToolCrib_Label1:Label;
      
      public var _GWizToolCrib_Label3:Label;
      
      public var _GWizToolCrib_Label5:Label;
      
      public var _GWizToolCrib_Label7:Label;
      
      public var _GWizToolCrib_Spacer1:Spacer;
      
      public var _GWizToolCrib_Spacer3:Spacer;
      
      private var _420862106allTables:CheckBox;
      
      private var _505951571copyTool:Button;
      
      private var _1032250624cribWiz:Button;
      
      private var _1582196519customCrib:Button;
      
      private var _441893671delTableBtn:Button;
      
      private var _1764595171deleteTool:Button;
      
      private var _1556825236descGrp:HGroup;
      
      private var _1017317214descText:TextInput;
      
      private var _1602041538editTool:Button;
      
      private var _549910507firstGrp:HGroup;
      
      private var _1142825131g10style:RadioButtonGroup;
      
      private var _1333733352gridColList:ArrayList;
      
      private var _208554889importBtn:Button;
      
      private var _844083586maxSlot:GWizNumStep;
      
      private var _104412919moveTool:Button;
      
      private var _1366599182newTable:Button;
      
      private var _1845213016newTool:Button;
      
      private var _346617056opSelector:GWizOpSelector;
      
      private var _1374473820optionsRow:HGroup;
      
      private var _105803054pList:GWizPropertyList;
      
      private var _138876112renameTable:Button;
      
      private var _549831489searchTerms:TextInput;
      
      private var _2080152179tableChooser:GWizGWCToolCribSelector;
      
      private var _1988515800tableType:DropDownList;
      
      private var _983825834toolList:GWizDataGrid;
      
      private var _426680106toolTasks:Button;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _207353194isTabbed:Boolean = true;
      
      private var _1345619391listSize:int = 0;
      
      public var verifyToolCrib:Function = null;
      
      public var allowG10:Boolean = false;
      
      public var allowCatWiz:Boolean = true;
      
      public var allowTasks:Boolean = false;
      
      private var createdNew:Boolean = false;
      
      private var picker:GWizCribToolEditor = null;
      
      private var newNum:int = 0;
      
      public var doubleClickFcn:Function = null;
      
      private var oldCribUnits:String = "Inches";
      
      private var renamer:GWizCribRename = null;
      
      private var customizer:GWizCribCustom = null;
      
      private var g10Export:GWizG10Export = null;
      
      private var fileOpenBrowser:GWizFileBrowser;
      
      private var g10Program:String = "";
      
      private var lastSelectedTool:int = -1;
      
      private var _927721558taskPopupFcn:Function;
      
      private var cribSelector:GWizCribSelector = null;
      
      private var _541841110easyFieldList:Array;
      
      private var _675673549defFieldList:Array;
      
      private var _1264957624fieldList:Array;
      
      private var _513770495powerUserState:Boolean = true;
      
      private var _1439080146allowDoubleClick:Boolean;
      
      private var _1491869303productLink:String = "";
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizToolCrib()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.fileOpenBrowser = new GWizFileBrowser("GCodeFiles","G-Code",GWizSettings.gcodeFileExtensions);
         this._541841110easyFieldList = ["tabname","slot","tool","description","comment","diameter","flutes","stickout","leadang","noseRad","cutLength","overallLength","shankSize","geometry","coating","toolmaterial","helixAngle","vendor","product","idNo","productLink"];
         this._675673549defFieldList = ["tabname","slot","tool","description","comment","diameter","flutes","stickout","leadang","noseRad","cutLength","overallLength","shankSize","geometry","coating","toolmaterial","helixAngle","toolFamily","xcomp","zcomp","zgeom","holderType","holderDesc","holderDia","holderLen","clockwise","coolantMode","coolantSupport","shoulderLength","threadPitch","taperAngle2","tipLength","tipDiameter","productLink","serialno","vendor","product","idNo","insNo","jobCode","pricePaid","status","quantity","guid","field1","field2","field3","field4"];
         this._1264957624fieldList = this.defFieldList;
         this._1439080146allowDoubleClick = !lockToolCrib && !GWizAbstractPrefs.isOEM;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizToolCrib_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizToolCribWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizToolCrib[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.paddingBottom = 5;
         this.paddingLeft = 5;
         this.paddingRight = 5;
         this.paddingTop = 0;
         this.mxmlContent = [this._GWizToolCrib_GWizForePanel1_c()];
         this._GWizToolCrib_ClassFactory1_i();
         this._GWizToolCrib_ClassFactory2_i();
         this._GWizToolCrib_ClassFactory3_i();
         this._GWizToolCrib_RadioButtonGroup1_i();
         this.addEventListener("initialize",this.___GWizToolCrib_VGroup1_initialize);
         this.addEventListener("creationComplete",this.___GWizToolCrib_VGroup1_creationComplete);
         this.addEventListener("show",this.___GWizToolCrib_VGroup1_show);
         this.addEventListener("hide",this.___GWizToolCrib_VGroup1_hide);
         this.addEventListener("keyUp",this.___GWizToolCrib_VGroup1_keyUp);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      private static function gotCrib(param1:ArrayCollection) : void
      {
         GWizSettings.cribData.createNewToolTable(downloadedCribName,param1);
         var _loc2_:GWizJustASec = new GWizJustASec(downloadAndAddCribAux);
      }
      
      private static function downloadAndAddCrib(param1:String, param2:String) : void
      {
         if(param1 != "" && param2 != "")
         {
            log.debug("Download Tool Crib \'" + param1 + "\', from file \'" + param2 + "\'");
            downloadedCribName = param1;
            GWizCSVUtils.downloadCSV(TOOLCRIB_DOWNLOAD_FOLDER + param2,gotCrib);
         }
      }
      
      private static function gotCatalog(param1:ArrayCollection) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:GWizJustASec = null;
         if(param1 && param1.length > 0)
         {
            cribDownloadQueue = [];
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               _loc2_ = param1.getItemAt(_loc3_);
               cribDownloadQueue.push(_loc2_);
               _loc3_++;
            }
            _loc4_ = new GWizJustASec(downloadAndAddCribAux);
         }
      }
      
      private static function downloadAndAddCribAux() : void
      {
         var _loc1_:Object = null;
         if(cribDownloadQueue.length > 0)
         {
            _loc1_ = cribDownloadQueue.pop();
            downloadAndAddCrib(_loc1_.cribname,_loc1_.file);
         }
         else
         {
            log.debug("Done downloading cribs.");
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizToolCrib._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get field1Name() : String
      {
         return GWizToolCrib._533223842field1Name;
      }
      
      public static function set field1Name(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCrib._533223842field1Name;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCrib,"field1Name",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get field2Name() : String
      {
         return GWizToolCrib._534147363field2Name;
      }
      
      public static function set field2Name(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCrib._534147363field2Name;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCrib,"field2Name",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get field3Name() : String
      {
         return GWizToolCrib._535070884field3Name;
      }
      
      public static function set field3Name(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCrib._535070884field3Name;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCrib,"field3Name",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get field4Name() : String
      {
         return GWizToolCrib._535994405field4Name;
      }
      
      public static function set field4Name(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCrib._535994405field4Name;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCrib,"field4Name",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get lockToolCrib() : Boolean
      {
         return GWizToolCrib._139385291lockToolCrib;
      }
      
      public static function set lockToolCrib(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCrib._139385291lockToolCrib;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCrib,"lockToolCrib",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get tableName() : String
      {
         return GWizToolCrib._1988717703tableName;
      }
      
      public static function set tableName(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolCrib._1988717703tableName;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolCrib,"tableName",_loc2_,param1));
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
      
      public function onInit() : void
      {
         if(!GWizSettings.theCrib)
         {
            GWizSettings.theCrib = this;
         }
      }
      
      public function onCC() : void
      {
         if(this.allowCatWiz || GWizUtils.debug)
         {
            this.cribWiz.visible = true;
         }
         if(this.allowTasks || GWizUtils.debug)
         {
            this.toolTasks.visible = true;
         }
         this.rebuildTableList("Default",GWizSettings.theCrib == this);
         this.verifyTbl();
         this.checkCribUnits();
         GWizToolCribData.onTableChooserFcn = this.onTableChooser;
         this.setOEMCrib();
         this.maxSlot.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheelIgnore);
         GWizNumStep.checkUnitsCC.addFunction("GWizToolCrib",this.checkUnits,false);
         GWizAbstractPrefs.powerUserCC.addFunction("GWizToolCrib",this.powerUserChanged,false);
         this.powerUserChanged();
         this.refreshListSize();
      }
      
      private function refreshListSize() : void
      {
         if(GWizToolCribData.ToolCrib)
         {
            this.listSize = GWizToolCribData.ToolCrib.length;
         }
         else
         {
            this.listSize = 0;
         }
      }
      
      public function chooseCrib(param1:String) : void
      {
         this.rebuildTableList(param1,false);
      }
      
      public function checkUnits(param1:Object = null) : Boolean
      {
         GWizToolCribData.ToolCrib.refresh();
         this.pList.refresh();
         this.refreshListSize();
         return true;
      }
      
      public function onShow() : void
      {
         var _loc1_:Boolean = GWizAbstractPrefs.lockSharedFiles(true);
         if(_loc1_)
         {
            this.enabled = false;
         }
         ++showGeneration;
         log.debug("Show");
      }
      
      public function onHide() : void
      {
         GWizAbstractPrefs.lockSharedFiles(false);
         this.enabled = true;
         log.debug("Hide");
      }
      
      private function onMouseWheelIgnore(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         param1.preventDefault();
      }
      
      private function setOEMCrib() : void
      {
         var _loc1_:Boolean = true;
         if(GWizAbstractPrefs.auxPrefsSet)
         {
            if(GWizAbstractPrefs.isOEM)
            {
               if(GWizCribList.cribList.length > 0)
               {
                  this.tableChooser.selectedIndex = 0;
                  _loc1_ = false;
               }
            }
            else
            {
               _loc1_ = false;
            }
         }
         if(_loc1_)
         {
            this.callLater(this.setOEMCrib);
         }
      }
      
      private function showMe() : void
      {
         log.debug("showMe");
      }
      
      private function traceCrib(param1:String) : void
      {
      }
      
      private function showToolEditor(param1:Boolean, param2:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc5_:GWizToolCribEntry = null;
         this.onShow();
         if(!this.isTabbed)
         {
            if(this.toolList.selectedIndex < 0)
            {
               this.toolList.selectedIndex = 0;
            }
            if(this.doubleClickFcn != null)
            {
               this.doubleClickFcn(null);
               return;
            }
         }
         if(this.tableChooser.selectedIndex < 0)
         {
            if(GWizCribList.cribList.length <= 0)
            {
               this.doNewTable();
            }
            else
            {
               this.tableChooser.selectedIndex = 0;
            }
            return;
         }
         this.createdNew = false;
         var _loc3_:GWizCribToolEditor = GWizCribToolEditor(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizCribToolEditor,true));
         if(_loc3_)
         {
            this.picker = _loc3_;
            if(this.toolList.selectedIndex < 0)
            {
               this.toolList.selectedIndex = 0;
            }
            this.picker.showSlot();
            if((_loc4_ = Math.max(0,this.toolList.selectedIndex)) < GWizToolCribData.ToolCrib.length)
            {
               this.picker.refObject = GWizToolCribData.ToolCrib.getCribEntryAt(_loc4_) as GWizToolCribEntry;
            }
            else
            {
               this.picker.refObject = new GWizToolCribEntry();
            }
            this.createdNew = param1;
            if(param1)
            {
               _loc5_ = GWizSettings.cribData.newToolTabObject(GWizToolCribData.defToolTable.getItemAt(0),this.tableChooser.selectedItem.tabname);
               this.picker.refObject = _loc5_;
               GWizSettings.cribData.flushGetCribEntryCache();
            }
            if(this.toolList.selectedIndex < 0)
            {
               this.toolList.selectedIndex = 0;
            }
            this.picker.toolNum = 0;
            this.picker.isNewTool = param1;
            this.picker.saveFcn = this.onToolEditorSave;
            this.picker.cancelFcn = this.onToolEditorCancel;
            this.picker.toolsList = GWizSettings.cribData.currToolList(this.tableChooser.selectedItem.tabname);
            this.picker.toolKey = this.picker.refObject.key;
            this.picker.updateFromRefObject();
            if(param2)
            {
               this.picker.fromFeedsSpeeds();
            }
         }
      }
      
      private function onToolEditorSave(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GWizToolCribEntry = null;
         if(this.createdNew)
         {
            GWizToolCribData.ToolCrib.addCribEntryAt(this.picker.refObject,0);
            this.toolList.selectedIndex = 0;
            ++GWizSettings.cribToolsCreated;
            GATracker.logPageView("ToolCrib/NewTool","ToolCrib/NewTool");
         }
         else if(param1 != this.picker.refObject.slot && param1 >= 0)
         {
            if(this.maxSlot.value > 0)
            {
               _loc2_ = 0;
               while(_loc2_ < GWizToolCribData.ToolCrib.length)
               {
                  _loc3_ = GWizToolCribData.ToolCrib.getCribEntryAt(_loc2_);
                  if(this.tableChooser.selectedItem.tabname == _loc3_.tabname && _loc3_.slot == this.picker.refObject.slot && _loc3_.key != this.picker.refObject.key)
                  {
                     _loc3_.slot = param1;
                     param1 = -1;
                     break;
                  }
                  _loc2_++;
               }
            }
         }
         GWizSettings.cribData.saveToolCrib();
         this.verifyTbl();
         GWizToolCribData.ToolCrib.refresh();
         this.refreshListSize();
         this.picker = null;
         GWizSettings.cribData.flushGetCribEntryCache();
         this.syncPList();
      }
      
      private function onToolEditorCancel() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(false && this.createdNew)
         {
            _loc1_ = this.picker.refObject.key;
            _loc2_ = 0;
            while(_loc2_ < GWizToolCribData.ToolCrib.length)
            {
               if(GWizToolCribData.ToolCrib.getCribEntryAt(_loc2_).key == _loc1_)
               {
                  GWizToolCribData.ToolCrib.removeItemAt(_loc2_);
                  break;
               }
               _loc2_++;
            }
            this.createdNew = false;
            this.toolList.selectedIndex = 0;
            this.picker = null;
         }
         GWizToolCribData.ToolCrib.refresh();
         this.refreshListSize();
      }
      
      private function deleteRow() : void
      {
         var _loc2_:GWizToolCribEntry = null;
         this.onShow();
         var _loc1_:Boolean = false;
         if(GWizToolCribData.ToolCrib.length <= 1)
         {
            GWizPopUpManager.Show("Sorry, there has to be at least 1 tool in a Tool Table.","Error: Cannot Delete",GWizPopUpManager.OK | GWizPopUpManager.ERROR,this);
         }
         else if(this.toolList.selectedIndex < 0)
         {
            GWizPopUpManager.Show("Select a tool to delete first.","Error: No Selection",GWizPopUpManager.OK | GWizPopUpManager.ERROR,this);
         }
         else if(this.maxSlot.value > 0)
         {
            _loc2_ = GWizToolCribEntry(this.toolList.selectedItem);
            _loc2_.tool = GWizToolData.EMPTY_SLOT;
            _loc1_ = true;
         }
         else
         {
            GWizToolCribData.ToolCrib.removeItemAt(this.toolList.selectedIndex);
            GWizToolCribData.ToolCrib.refresh();
            _loc1_ = true;
         }
         if(_loc1_)
         {
            GWizSettings.cribData.saveToolCrib();
            this.verifyTbl();
            GWizSettings.cribData.flushGetCribEntryCache();
         }
         this.refreshListSize();
      }
      
      private function rowNumber(param1:Object, param2:int) : String
      {
         var _loc3_:int = GWizToolCribData.ToolCrib.getItemIndex(param1) + 1;
         return String(_loc3_);
      }
      
      private function pctSFM(param1:Object, param2:int) : String
      {
         var _loc3_:Number = param1.sfm;
         return String(Math.floor(_loc3_ * 100)) + "%";
      }
      
      private function pctIPT(param1:Object, param2:int) : String
      {
         var _loc3_:Number = param1.chipload;
         return String(Math.floor(_loc3_ * 100)) + "%";
      }
      
      private function mfgSFM(param1:Object, param2:int) : String
      {
         var _loc3_:String = "-";
         if(param1.hasOwnProperty("useMfgSFM") && String(param1.useMfgSFM) == "true")
         {
            if(param1.hasOwnProperty("mfgSFM"))
            {
               _loc3_ = GWizUtils.formatPlaces(param1.mfgSFM,0,true,GWizUtils.M_UNITS);
            }
         }
         return _loc3_;
      }
      
      private function mfgIPT(param1:Object, param2:int) : String
      {
         var _loc3_:String = "-";
         if(param1.hasOwnProperty("useMfgIPT") && String(param1.useMfgIPT) == "true")
         {
            if(param1.hasOwnProperty("mfgIPT"))
            {
               _loc3_ = GWizUtils.formatPlaces(param1.mfgIPT,4,true,GWizUtils.MM_UNITS);
            }
         }
         return _loc3_;
      }
      
      private function verifyTbl() : void
      {
         if(this.verifyToolCrib != null)
         {
            this.verifyToolCrib();
         }
      }
      
      private function onTableChooser() : Boolean
      {
         if(GWizSettings.cribData.dontFilter || GWizCribList.cribList.length <= 0)
         {
            return false;
         }
         var _loc1_:Object = this.tableChooser.selectedItem;
         if(this.tableChooser.selectedIndex < 0 || !_loc1_)
         {
            this.tableChooser.selectedIndex = 0;
            this.callLater(this.onTableChooser);
            return false;
         }
         GWizToolCrib.tableName = _loc1_.tabname;
         this.descText.text = _loc1_.description;
         this.tableType.selectedIndex = _loc1_.tabtype;
         if(this.maxSlot.value != _loc1_.maxslot)
         {
            this.maxSlot.value = _loc1_.maxslot;
            GWizToolCribData.setMaxSlots(_loc1_.tabname,_loc1_.maxslot);
         }
         if(GWizToolCribData.ToolCrib)
         {
            GWizToolCribData.ToolCrib.filterCribByTabname(_loc1_.tabname);
         }
         this.refreshListSize();
         this.toolList.selectedIndex = 0;
         return true;
      }
      
      private function doNewTable() : void
      {
         GWizTableName.toolTableName(GWizSettings.cribData.createNewToolTable,"My New Table");
      }
      
      private function confirmTableDelete(param1:Event) : void
      {
         this.onShow();
         GWizPopUpManager.Show("Are you sure you want to delete?","Confirm Table Deletion",GWizPopUpManager.YES | GWizPopUpManager.NO | GWizPopUpManager.WARN,this,this.doDeleteTable);
      }
      
      private function doDeleteTable(param1:CloseEvent) : void
      {
         var _loc2_:Object = null;
         if(param1.detail == GWizPopUpManager.YES)
         {
            _loc2_ = this.tableChooser.selectedItem;
            if(this.tableChooser.selectedIndex < 0 || !_loc2_)
            {
               return;
            }
            if(this.onTableChooser())
            {
               GWizCribList.delToolCrib(_loc2_.tabname);
               GWizToolCribData.ToolCrib.removeAll();
               GWizSettings.cribData.saveToolCrib();
               this.rebuildTableList("Default");
               this.verifyTbl();
               GWizSettings.cribData.flushGetCribEntryCache();
               this.refreshListSize();
            }
         }
      }
      
      private function validTableName(param1:String) : Boolean
      {
         param1 = StringUtil.trim(param1);
         if(param1 == GWizCribList.NO_CRIB)
         {
            GWizPopUpManager.Show("Sorry, you can\'t name a table " + GWizCribList.NO_CRIB,"Error: Invalid Name",GWizPopUpManager.ERROR);
            return false;
         }
         if(param1.length < 1)
         {
            GWizPopUpManager.Show("Table name cannot be blank.","Error: Invalid Name",GWizPopUpManager.ERROR);
            return false;
         }
         var _loc2_:String = GWizToolCribData.ToolCrib.tcFilter;
         GWizToolCribData.ToolCrib.tcFilter = param1;
         GWizToolCribData.ToolCrib.filterCrib();
         var _loc3_:int = GWizToolCribData.ToolCrib.length;
         GWizToolCribData.ToolCrib.unFilterCrib();
         GWizToolCribData.ToolCrib.tcFilter = _loc2_;
         this.onTableChooser();
         if(_loc3_ > 0)
         {
            GWizPopUpManager.Show("Sorry, can\'t rename because that name is already used.","Error: Invalid Name",GWizPopUpManager.OK | GWizPopUpManager.ERROR,this);
            return false;
         }
         this.refreshListSize();
         return true;
      }
      
      public function renameCurrTbl(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(this.validTableName(param1))
         {
            _loc2_ = GWizToolCribData.ToolCrib.tcFilter;
            _loc3_ = GWizToolCribData.ToolCrib.length - 1;
            while(_loc3_ >= 0)
            {
               if((_loc4_ = GWizToolCribData.ToolCrib[_loc3_]).tabname == _loc2_)
               {
                  _loc4_.tabname = param1;
               }
               _loc3_--;
            }
            GWizSettings.cribData.saveToolCrib();
            this.verifyTbl();
            GWizSettings.cribData.flushGetCribEntryCache();
            GWizCribList.delToolCrib(_loc2_);
            this.rebuildTableList(param1);
         }
      }
      
      public function rebuildTableList(param1:String, param2:Boolean = true) : void
      {
         if(!this.tableChooser)
         {
            return;
         }
         if(param2)
         {
            this.tableChooser.dataProvider = null;
            GWizSettings.cribData.rebuildTableList();
         }
         this.tableChooser.dataProvider = GWizCribList.cribList;
         var _loc3_:int = GWizCribList.cribList.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_ && GWizCribList.cribList.getItemAt(_loc4_).tabname != param1)
         {
            _loc4_++;
         }
         if(param1.length == 0 || _loc4_ >= GWizCribList.cribList.length)
         {
            this.tableChooser.selectedIndex = 0;
         }
         else
         {
            this.tableChooser.selectedIndex = _loc4_;
         }
         this.onTableChooser();
         if(param2)
         {
            GWizSettings.cribData.fsCribList = GWizSettings.cribGeneration++;
            GWizSettings.cribData.flushGetCribEntryCache();
         }
      }
      
      public function checkCribUnits() : void
      {
         if(!this.allowG10)
         {
            this.ToolCompData.visible = false;
         }
         else
         {
            this.ToolCompData.visible = true;
         }
         if(GWizUtils.Units != this.oldCribUnits)
         {
            this.oldCribUnits = GWizUtils.Units;
            GWizToolCribData.ToolCrib.refresh();
            this.refreshListSize();
         }
      }
      
      protected function onChangeTableOptions() : void
      {
         if(this.tableChooser.selectedIndex >= 0)
         {
            this.tableChooser.selectedItem.description = this.descText.text;
            this.tableChooser.selectedItem.tabtype = this.tableType.selectedIndex;
            if(this.tableChooser.selectedItem.maxslot != this.maxSlot.value)
            {
               this.tableChooser.selectedItem.maxslot = this.maxSlot.value;
               GWizToolCribData.setMaxSlots(this.tableChooser.selectedItem.tabname,this.tableChooser.selectedItem.maxslot);
            }
         }
         GWizSettings.cribData.flushGetCribEntryCache();
      }
      
      public function onMoveToolOK(param1:Event) : void
      {
         var _loc2_:String = null;
         var _loc3_:GWizToolCribEntry = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:GWizToolCribEntry = null;
         if(this.cribSelector.CribChoice.selectedItem)
         {
            _loc2_ = this.cribSelector.CribChoice.selectedItem.tabname;
            if(this.lastSelectedTool >= 0)
            {
               _loc3_ = GWizToolCribData.ToolCrib.getCribEntryAt(this.lastSelectedTool);
               _loc4_ = this.tableChooser.selectedItem.tabname;
               _loc5_ = this.tableChooser.selectedItem.maxslot;
               if(GWizCribList.isMaxSlotTable(_loc2_))
               {
                  if(!(_loc6_ = GWizToolCribData.ToolCrib.findEmptySlot(_loc2_)))
                  {
                     GWizPopUpManager.Show("Sorry, there are no empty slots in destination Tool Table.","Error: Cannot Move",GWizPopUpManager.OK | GWizPopUpManager.ERROR,this);
                  }
                  else
                  {
                     _loc3_.tabname = _loc2_;
                     _loc3_.slot = _loc6_.slot;
                     GWizToolCribData.setMaxSlots(_loc4_,_loc5_,false);
                     GWizToolCribData.setMaxSlots(_loc2_,GWizCribList.slotsInTable(_loc2_),false);
                  }
               }
               else
               {
                  _loc3_.tabname = _loc2_;
               }
               GWizSettings.cribData.saveToolCrib();
               this.verifyTbl();
               GWizSettings.cribData.flushGetCribEntryCache();
            }
         }
      }
      
      public function onCopyToolOK(param1:Event) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:GWizToolCribEntry = null;
         var _loc5_:GWizToolCribEntry = null;
         if(this.cribSelector.CribChoice.selectedItem)
         {
            _loc2_ = this.cribSelector.CribChoice.selectedItem.tabname;
            _loc3_ = GWizToolCribData.ToolCrib.getCribEntryAt(this.toolList.selectedIndex);
            (_loc4_ = new GWizToolCribEntry(_loc3_)).guid = "";
            if(GWizCribList.isMaxSlotTable(_loc2_))
            {
               if(!(_loc5_ = GWizToolCribData.ToolCrib.findEmptySlot(_loc2_)))
               {
                  GWizPopUpManager.Show("Sorry, there are no empty slots in destination Tool Table.","Error: Cannot Copy",GWizPopUpManager.OK | GWizPopUpManager.ERROR,this);
               }
               else
               {
                  _loc4_.tabname = _loc2_;
                  _loc4_.slot = _loc5_.slot;
                  GWizToolCribData.delFirstEmptySlot(_loc2_);
                  GWizToolCribData.setMaxSlots(_loc2_,GWizCribList.slotsInTable(_loc2_),false);
               }
            }
            else
            {
               _loc4_.tabname = _loc2_;
               GWizToolCribData.ToolCrib.addCribEntry(_loc4_);
            }
            this.refreshListSize();
            GWizSettings.cribData.saveToolCrib();
            this.verifyTbl();
            GWizSettings.cribData.flushGetCribEntryCache();
         }
      }
      
      private function onRename() : void
      {
         if(this.tableChooser.selectedItem.tabname == "Default")
         {
            GWizPopUpManager.Show("Sorry, you can\'t rename the default table. Select another table and try again.","Error: Cannot Rename",GWizPopUpManager.OK | GWizPopUpManager.ERROR,this);
            return;
         }
         this.renamer = GWizCribRename(GWizPopUpManager.createPopUp(DisplayObject(this),GWizCribRename,true));
         if(this.renamer)
         {
            this.renamer.renameFunc = this.renameCurrTbl;
         }
         GWizSettings.cribData.flushGetCribEntryCache();
      }
      
      private function onCustomCrib() : void
      {
         var _loc1_:GWizCribCustom = GWizCribCustom(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizCribCustom,true));
         if(_loc1_)
         {
            this.customizer = _loc1_;
            this.customizer.toolCrib = this;
            this.customizer.field1Name.text = GWizToolCrib.field1Name;
            this.customizer.field2Name.text = GWizToolCrib.field2Name;
            this.customizer.field3Name.text = GWizToolCrib.field3Name;
            this.customizer.field4Name.text = GWizToolCrib.field4Name;
         }
      }
      
      public function onCustomOK(param1:Event) : void
      {
         GWizToolCrib.field1Name = this.customizer.field1Name.text;
         GWizToolCrib.field2Name = this.customizer.field2Name.text;
         GWizToolCrib.field3Name = this.customizer.field3Name.text;
         GWizToolCrib.field4Name = this.customizer.field4Name.text;
      }
      
      private function doG10() : void
      {
         var _loc1_:GWizG10Export = GWizG10Export(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizG10Export,true));
         if(_loc1_)
         {
            this.g10Export = _loc1_;
            this.g10Export.toolCrib = this;
            if(this.toolList.selectedIndex < 0)
            {
               this.g10Export.currToolOnly.enabled = false;
            }
         }
      }
      
      private function g10Header() : String
      {
         var _loc1_:* = "%\nO0000\n";
         _loc1_ += "( G-Wizard Tool Offsets )\n";
         _loc1_ += "G00 G20 G17 G40 G49 G80 G90\n";
         return _loc1_ + "\n";
      }
      
      private function g10Footer() : String
      {
         return "( End of G-Wizard Tool Offsets )\n";
      }
      
      public function onG10OK(param1:Event) : void
      {
         var _loc3_:Boolean = false;
         var _loc2_:int = 0;
         this.g10Program = this.g10Header();
         if(this.g10Export.currToolOnly.selected)
         {
            this.g10Program += this.g10Entry(this.toolList.selectedIndex);
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < GWizToolCribData.ToolCrib.length)
            {
               _loc3_ = true;
               if(this.g10Export.toolRange.selected)
               {
                  _loc3_ = this.inSlotRange(_loc2_);
               }
               if(_loc3_)
               {
                  this.g10Program += this.g10Entry(_loc2_);
               }
               _loc2_++;
            }
         }
         this.g10Program += this.g10Footer();
         this.saveG10Program();
      }
      
      private function inSlotRange(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object;
         param1 = (_loc4_ = GWizToolCribData.ToolCrib.getCribEntryAt(param1)).slot;
         if(this.g10Export.fromSlot.value > this.g10Export.toSlot.value)
         {
            _loc3_ = this.g10Export.fromSlot.value;
            _loc2_ = this.g10Export.toSlot.value;
         }
         else
         {
            _loc2_ = this.g10Export.fromSlot.value;
            _loc3_ = this.g10Export.toSlot.value;
         }
         return _loc2_ <= param1 && param1 <= _loc3_;
      }
      
      private function saveG10Program() : void
      {
         var _loc1_:String = GWizSettings.FilePath;
         var _loc2_:String = "";
         var _loc3_:int = _loc1_.length;
         while(_loc3_ >= 0)
         {
            if(_loc1_.charAt(_loc3_) == ".")
            {
               break;
            }
            _loc3_--;
         }
         if(_loc3_ > 0)
         {
            _loc2_ = _loc1_.substr(_loc3_,_loc1_.length);
            _loc1_ = _loc1_.substr(0,_loc1_.length - _loc2_.length);
         }
         var _loc4_:File = null;
         if(_loc1_.length > 0)
         {
            _loc1_ += "_G10" + _loc2_;
            _loc4_ = new File(_loc1_);
         }
         else
         {
            _loc4_ = new File();
         }
         this.fileOpenBrowser.doFileSaveAs(this.fileSelectedForSave,"Export Tool Table as G10 Program");
      }
      
      private function fileSelectedForSave(param1:File) : void
      {
         var f:File = param1;
         var stream:FileStream = new FileStream();
         try
         {
            stream.open(f,FileMode.WRITE);
            stream.writeUTFBytes(this.g10Program);
            stream.close();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error writing G10 program.");
            GWizPopUpManager.Show("Error writing G10 program.","Error Writing Program",GWizPopUpManager.ERROR);
         }
      }
      
      private function g10Entry(param1:int) : String
      {
         var _loc2_:String = "";
         if(this.g10Export.doToolLength.selected)
         {
            _loc2_ += this.lengthOff(param1);
         }
         if(this.g10Export.doToolComp.selected)
         {
            _loc2_ += this.toolComp(param1);
         }
         return _loc2_ + "\n";
      }
      
      private function lengthOff(param1:int) : String
      {
         var _loc2_:* = "";
         var _loc3_:Object = GWizToolCribData.ToolCrib.getCribEntryAt(param1);
         _loc2_ = "( Length offset for " + _loc3_.description + ", Serial #" + _loc3_.serialno + " )\n";
         switch(GWizSettings.post.g10Style)
         {
            case GWizSettings.post.G10_MACH3:
               _loc2_ += "G10 L1 P" + _loc3_.slot + " " + "Z" + _loc3_.zcomp + "\n";
               break;
            case GWizSettings.post.G10_FANUC:
               _loc2_ += "G10 L10 P" + _loc3_.slot + " " + "R" + _loc3_.zcomp + "\n";
               break;
            default:
               GWizUtils.assert(false);
         }
         return _loc2_;
      }
      
      private function toolComp(param1:int) : String
      {
         if(param1 == 0)
         {
            return "\n";
         }
         var _loc2_:* = "";
         var _loc3_:Object = GWizToolCribData.ToolCrib.getCribEntryAt(param1);
         _loc2_ = "( Tool Wear Comp for " + _loc3_.description + ", Serial #" + _loc3_.serialno + " )\n";
         switch(GWizSettings.post.g10Style)
         {
            case GWizSettings.post.G10_MACH3:
               _loc2_ += "G10 L1 P" + _loc3_.slot + " " + "X" + _loc3_.xcomp + "\n";
               break;
            case GWizSettings.post.G10_FANUC:
               _loc2_ += "G10 L13 P" + _loc3_.slot + " " + "R" + _loc3_.xcomp + "\n";
               break;
            default:
               GWizUtils.assert(false);
         }
         return _loc2_ + "\n";
      }
      
      private function doUseSimData() : void
      {
         var _loc2_:GWizToolCribEntry = null;
         var _loc1_:int = 0;
         while(_loc1_ < GWizToolCribData.ToolCrib.length)
         {
            _loc2_ = GWizToolCribData.ToolCrib.getCribEntryAt(_loc1_);
            if(_loc2_.slot != 0)
            {
               _loc2_.zcomp = GWizSettings.post.GCodeVariables.getLengthOffset(_loc2_.slot,false);
               _loc2_.xcomp = GWizSettings.post.GCodeVariables.getWearOffset(_loc2_.slot,false);
               GWizToolCribData.ToolCrib.removeItemAt(_loc1_);
               GWizToolCribData.ToolCrib.addCribEntryAt(_loc2_,_loc1_);
            }
            _loc1_++;
         }
         this.refreshListSize();
      }
      
      private function doLoadData() : void
      {
         this.onShow();
         GWizCribFormat.getCribFormat(true,GWizCribFormat.importFormats,this.importNext,this.parentApplication);
      }
      
      private function importNext(param1:ArrayCollection, param2:int, param3:Boolean) : void
      {
         var _loc5_:GWizCribMach3 = null;
         var _loc6_:GWizCribF360TSV = null;
         var _loc7_:GWizCribF360CSV = null;
         var _loc4_:GWizCSVUtils = new GWizCSVUtils();
         switch(param2)
         {
            case GWizCribFormat.MACH3_IMPORT:
               (_loc5_ = new GWizCribMach3()).browseForImport(GWizSettings.cribData.importCSVToolTable);
               break;
            case GWizCribFormat.F360_TSV_IMPORT:
               (_loc6_ = new GWizCribF360TSV()).browseForImport(GWizSettings.cribData.importCSVToolTable);
               break;
            case GWizCribFormat.F360_CSV_IMPORT:
               (_loc7_ = new GWizCribF360CSV()).browseForImport(GWizSettings.cribData.importCSVToolTable);
               break;
            default:
               _loc4_.importCSVData(GWizSettings.cribData.importCSVToolTable,GWizSettings.cribData.cribFiles);
         }
      }
      
      private function onToolSelChange(param1:FlexEvent) : void
      {
         var _loc2_:* = this.toolList.selectedIndex >= 0;
         var _loc3_:Boolean = _loc2_ && !lockToolCrib;
         this.editTool.enabled = _loc3_;
         this.moveTool.enabled = _loc3_;
         this.copyTool.enabled = _loc3_;
         this.deleteTool.enabled = _loc3_;
         this.syncPList();
         this.lastSelectedTool = this.toolList.selectedIndex;
      }
      
      private function isTrue(param1:Object) : Boolean
      {
         return GWizStringUtils.isXMLCSVTrue(param1);
      }
      
      private function onCribOptions() : void
      {
         var _loc1_:GWizCribOptions = GWizCribOptions(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizCribOptions,true));
         if(!_loc1_)
         {
         }
      }
      
      private function onCribWiz() : void
      {
         this.onShow();
         GATracker.logPageView("ToolCrib/CribWizard","ToolCrib/CribWizard");
         var _loc1_:GWizCribWiz = GWizCribWiz(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizCribWiz,true));
         if(_loc1_)
         {
            _loc1_.theCrib = GWizToolCribData.ToolCrib;
            _loc1_.verifyTblFcn = this.cribWizVerifyAndSave;
            _loc1_.addEndmillFcn = GWizSettings.cribData.addEndmill;
            _loc1_.addDrillFcn = GWizSettings.cribData.addDrill;
            _loc1_.maxSlot = GWizSettings.cribData.maxSlot(this.tableChooser.selectedItem.tabname);
         }
      }
      
      private function cribWizVerifyAndSave() : void
      {
         GWizSettings.cribData.saveToolCrib();
         this.verifyTbl();
      }
      
      private function onTasks() : void
      {
         this.onShow();
         if(this.taskPopupFcn != null)
         {
            this.taskPopupFcn();
         }
      }
      
      private function filterChanged(param1:String, param2:String = "", param3:Number = NaN, param4:Number = NaN, param5:Number = NaN, param6:int = 0, param7:String = "") : void
      {
         GWizToolCribData.ToolCrib.opFilter = param1;
         GWizToolCribData.ToolCrib.materialFilter = param2;
         GWizToolCribData.ToolCrib.diameterFilter = param3;
         GWizToolCribData.ToolCrib.cutLengthFilter = param4;
         GWizToolCribData.ToolCrib.stickoutFilter = param5;
         GWizToolCribData.ToolCrib.flutesFilter = param6;
         GWizToolCribData.ToolCrib.tipTypeFilter = param7;
         GWizToolCribData.ToolCrib.refresh();
         this.refreshListSize();
      }
      
      public function closePopUp() : void
      {
         this.opSelector.resetOpSelector();
      }
      
      private function addSearchField(param1:Object, param2:String) : String
      {
         var _loc3_:String = "";
         if(param1 && param1.hasOwnProperty(param2))
         {
            _loc3_ = param1[param2];
         }
         return _loc3_;
      }
      
      private function doSearch(param1:String, param2:int = -1) : int
      {
         var _loc4_:ArrayCollection = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc3_:int = 0;
         if(this.tableChooser && this.tableChooser.selectedItem)
         {
            _loc4_ = GWizToolCribData.ToolCrib;
            param1 = param1.toLowerCase();
            if(param2 == -1)
            {
               param2 = 0;
            }
            _loc5_ = false;
            _loc6_ = param2;
            while(_loc6_ < _loc4_.length)
            {
               _loc7_ = "";
               _loc8_ = _loc4_.getItemAt(_loc6_);
               if((_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ = (_loc7_ += this.addSearchField(_loc8_,"description") + " ") + (this.addSearchField(_loc8_,"comment") + " ")) + (this.addSearchField(_loc8_,"tool") + " ")) + (this.addSearchField(_loc8_,"geometry") + " ")) + (this.addSearchField(_loc8_,"coating") + " ")) + (this.addSearchField(_loc8_,"toolmaterial") + " ")) + (this.addSearchField(_loc8_,"vendor") + " ")) + (this.addSearchField(_loc8_,"product") + " ")) + (this.addSearchField(_loc8_,"idNo") + " ")) + (this.addSearchField(_loc8_,"insNo") + " ")) + (this.addSearchField(_loc8_,"toolFamily") + " ")) + (this.addSearchField(_loc8_,"status") + " ")) + (this.addSearchField(_loc8_,"holderType") + " ")) + (this.addSearchField(_loc8_,"holderDesc") + " ")) + (this.addSearchField(_loc8_,"productLink") + " ")) + (this.addSearchField(_loc8_,"jobCode") + " ")).toLowerCase().indexOf(param1) >= 0)
               {
                  _loc3_ = _loc6_;
                  _loc5_ = true;
                  break;
               }
               _loc6_++;
            }
         }
         if(!_loc5_)
         {
            GWizPopUpManager.Show("Nothing found.","Finished Search",GWizPopUpManager.WARN);
         }
         return _loc3_;
      }
      
      private function openCribSelector(param1:String, param2:Function) : void
      {
         var _loc3_:GWizCribSelector = null;
         if(this.enabled)
         {
            _loc3_ = GWizCribSelector(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizCribSelector,true));
            if(_loc3_)
            {
               this.cribSelector = _loc3_;
               this.cribSelector.title = param1 + " tool to new crib";
               this.cribSelector.okLabel = param1;
               this.cribSelector.okHandler = param2;
               this.cribSelector.listLbl.text = param1 + " to crib";
               this.cribSelector.toolCrib = this;
               this.cribSelector.CribChoice.dataProvider = GWizCribList.cribList;
            }
            GWizSettings.cribData.flushGetCribEntryCache();
         }
      }
      
      public function toCrib() : void
      {
         GWizSettings.TabToToolCrib();
         this.callLater(this.toCribAux);
      }
      
      private function toCribAux() : void
      {
         this.openCribSelector("Copy from F/S ",this.onToCribOK);
      }
      
      private function onToCribOK(param1:Event) : void
      {
         if(this.cribSelector.CribChoice.selectedItem)
         {
            this.tableChooser.selectedIndex = this.cribSelector.CribChoice.selectedIndex;
            this.showToolEditor(true,true);
         }
      }
      
      private function doAllTools() : void
      {
         GWizToolCribData.ToolCrib.showAllTables = this.allTables.selected;
         GWizToolCribData.ToolCrib.refresh();
         this.refreshListSize();
         this.delTableBtn.enabled = !this.allTables.selected;
         this.importBtn.enabled = !this.allTables.selected;
         this.newTable.enabled = !this.allTables.selected;
         this.renameTable.enabled = !this.allTables.selected;
         this.descText.enabled = !this.allTables.selected;
         this.newTool.enabled = !this.allTables.selected;
         this.cribWiz.enabled = !this.allTables.selected;
         this.toolTasks.enabled = !this.allTables.selected;
      }
      
      private function onDownloadAux() : void
      {
         GWizCSVUtils.downloadCSV(TOOLCRIB_DOWNLOAD_FOLDER + "CribDownloadCatalog.csv",gotCatalog);
      }
      
      private function onDownload() : void
      {
         GWizMfgFamilyPopup.doDownload(this.onDownloadAux);
         GATracker.logPageView("ToolCrib/Download","ToolCrib/Download");
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         if(GWizSettings.prefs.powerUser != this.powerUserState)
         {
            if(GWizSettings.prefs.powerUser)
            {
               this.cribWiz.visible = true;
               this.fieldList = this.defFieldList;
               if(this.allowTasks || GWizUtils.debug)
               {
                  this.toolTasks.visible = true;
               }
            }
            else
            {
               this.cribWiz.visible = false;
               this.fieldList = this.easyFieldList;
               this.toolTasks.visible = false;
            }
            this.matchPropertiesToGrid();
            this.powerUserState = GWizSettings.prefs.powerUser;
         }
         return true;
      }
      
      protected function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == GWizStringUtils.CR.charCodeAt(0))
         {
            this.makeRowVisible(this.doSearch(this.searchTerms.text));
         }
      }
      
      private function makeRowVisible(param1:int) : void
      {
         this.toolList.ensureCellIsVisible(param1);
         this.toolList.selectedIndex = param1;
      }
      
      private function syncPList() : void
      {
         this.pList.data = this.toolList.selectedItem;
         if(this.pList.data.hasOwnProperty("productLink"))
         {
            this.productLink = this.pList.data.productLink;
         }
         else
         {
            this.productLink = "";
         }
         this.matchPropertiesToGrid();
      }
      
      private function openProductLink() : void
      {
         GWizUtils.doWebPage(this.productLink);
      }
      
      private function matchPropertiesToGrid() : void
      {
         var _loc3_:GWizGridColumn = null;
         var _loc4_:String = null;
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < this.gridColList.length)
         {
            _loc3_ = this.gridColList.getItemAt(_loc2_) as GWizGridColumn;
            if(_loc3_.visible)
            {
               if((_loc4_ = _loc3_.dataField) && _loc4_.length > 0)
               {
                  _loc1_.push(_loc4_);
               }
            }
            _loc2_++;
         }
         this.fieldList = _loc1_;
      }
      
      private function sendToFS() : void
      {
         var _loc1_:String = null;
         if(GWizSettings.FeedsSpeedsApp && this.toolList.selectedItem && this.toolList.selectedItem.hasOwnProperty("guid"))
         {
            _loc1_ = this.toolList.selectedItem.guid;
            log.debug("guid = " + _loc1_);
            GWizSettings.FeedsSpeedsApp.Tool.setGuid(_loc1_);
            if(GWizSettings.TabToFSCalculator != null)
            {
               GWizSettings.TabToFSCalculator();
            }
         }
      }
      
      private function _GWizToolCrib_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizCribRename;
         _loc1_.properties = {"outerDocument":this};
         this._GWizToolCrib_ClassFactory1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_ClassFactory1",this._GWizToolCrib_ClassFactory1);
         return _loc1_;
      }
      
      private function _GWizToolCrib_ClassFactory2_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizG10Export;
         _loc1_.properties = {"outerDocument":this};
         this._GWizToolCrib_ClassFactory2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_ClassFactory2",this._GWizToolCrib_ClassFactory2);
         return _loc1_;
      }
      
      private function _GWizToolCrib_ClassFactory3_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizCribCustom;
         _loc1_.properties = {"outerDocument":this};
         this._GWizToolCrib_ClassFactory3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_ClassFactory3",this._GWizToolCrib_ClassFactory3);
         return _loc1_;
      }
      
      private function _GWizToolCrib_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"g10style");
         this.g10style = _loc1_;
         BindingManager.executeBindings(this,"g10style",this.g10style);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizToolCrib_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizToolCrib_Array2_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_VerticalLayout1_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizToolCrib_Array2_c() : Array
      {
         return [this._GWizToolCrib_HGroup1_c(),this._GWizToolCrib_HDividedBox1_c(),this._GWizToolCrib_HGroup8_c()];
      }
      
      private function _GWizToolCrib_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "top";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolCrib_VGroup2_c(),this._GWizToolCrib_GWizOpSelector1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolCrib_HGroup2_i(),this._GWizToolCrib_HGroup3_i(),this._GWizToolCrib_HGroup4_i(),this._GWizToolCrib_HGroup6_c(),this._GWizToolCrib_HGroup7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_HGroup2_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolCrib_Label1_i(),this._GWizToolCrib_GWizGWCToolCribSelector1_i(),this._GWizToolCrib_CheckBox1_i(),this._GWizToolCrib_Button1_i(),this._GWizToolCrib_Button2_i(),this._GWizToolCrib_Button3_i()];
         _loc1_.id = "firstGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.firstGrp = _loc1_;
         BindingManager.executeBindings(this,"firstGrp",this.firstGrp);
         return _loc1_;
      }
      
      private function _GWizToolCrib_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Table";
         _loc1_.id = "_GWizToolCrib_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolCrib_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_Label1",this._GWizToolCrib_Label1);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGWCToolCribSelector1_i() : GWizGWCToolCribSelector
      {
         var _loc1_:GWizGWCToolCribSelector = new GWizGWCToolCribSelector();
         _loc1_.changeFcn = this.onTableChooser;
         _loc1_.id = "tableChooser";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tableChooser = _loc1_;
         BindingManager.executeBindings(this,"tableChooser",this.tableChooser);
         return _loc1_;
      }
      
      private function _GWizToolCrib_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "All Tools";
         _loc1_.toolTip = "Show all tools from all tables when selected.";
         _loc1_.selected = false;
         _loc1_.addEventListener("click",this.__allTables_click);
         _loc1_.id = "allTables";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.allTables = _loc1_;
         BindingManager.executeBindings(this,"allTables",this.allTables);
         return _loc1_;
      }
      
      public function __allTables_click(param1:MouseEvent) : void
      {
         this.doAllTools();
      }
      
      private function _GWizToolCrib_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "New...";
         _loc1_.addEventListener("click",this.__newTable_click);
         _loc1_.id = "newTable";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.newTable = _loc1_;
         BindingManager.executeBindings(this,"newTable",this.newTable);
         return _loc1_;
      }
      
      public function __newTable_click(param1:MouseEvent) : void
      {
         this.doNewTable();
      }
      
      private function _GWizToolCrib_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Rename...";
         _loc1_.addEventListener("click",this.__renameTable_click);
         _loc1_.id = "renameTable";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.renameTable = _loc1_;
         BindingManager.executeBindings(this,"renameTable",this.renameTable);
         return _loc1_;
      }
      
      public function __renameTable_click(param1:MouseEvent) : void
      {
         this.onRename();
      }
      
      private function _GWizToolCrib_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Del Table...";
         _loc1_.toolTip = "Delete the selected tool table and all its tools.";
         _loc1_.addEventListener("click",this.__delTableBtn_click);
         _loc1_.id = "delTableBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.delTableBtn = _loc1_;
         BindingManager.executeBindings(this,"delTableBtn",this.delTableBtn);
         return _loc1_;
      }
      
      public function __delTableBtn_click(param1:MouseEvent) : void
      {
         this.confirmTableDelete(param1);
      }
      
      private function _GWizToolCrib_HGroup3_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolCrib_Label2_i(),this._GWizToolCrib_TextInput1_i()];
         _loc1_.id = "descGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.descGrp = _loc1_;
         BindingManager.executeBindings(this,"descGrp",this.descGrp);
         return _loc1_;
      }
      
      private function _GWizToolCrib_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Description";
         _loc1_.id = "DescLab";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DescLab = _loc1_;
         BindingManager.executeBindings(this,"DescLab",this.DescLab);
         return _loc1_;
      }
      
      private function _GWizToolCrib_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("change",this.__descText_change);
         _loc1_.id = "descText";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.descText = _loc1_;
         BindingManager.executeBindings(this,"descText",this.descText);
         return _loc1_;
      }
      
      public function __descText_change(param1:TextOperationEvent) : void
      {
         this.onChangeTableOptions();
      }
      
      private function _GWizToolCrib_HGroup4_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolCrib_Label3_i(),this._GWizToolCrib_DropDownList1_i(),this._GWizToolCrib_GWizNumStep1_i(),this._GWizToolCrib_HGroup5_i()];
         _loc1_.id = "optionsRow";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.optionsRow = _loc1_;
         BindingManager.executeBindings(this,"optionsRow",this.optionsRow);
         return _loc1_;
      }
      
      private function _GWizToolCrib_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Options";
         _loc1_.id = "_GWizToolCrib_Label3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolCrib_Label3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_Label3",this._GWizToolCrib_Label3);
         return _loc1_;
      }
      
      private function _GWizToolCrib_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("change",this.__tableType_change);
         _loc1_.id = "tableType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tableType = _loc1_;
         BindingManager.executeBindings(this,"tableType",this.tableType);
         return _loc1_;
      }
      
      public function __tableType_change(param1:IndexChangeEvent) : void
      {
         this.onChangeTableOptions();
      }
      
      private function _GWizToolCrib_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "# of Slots (0 = unlimited):";
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 1;
         _loc1_.value = 0;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("change",this.__maxSlot_change);
         _loc1_.id = "maxSlot";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.maxSlot = _loc1_;
         BindingManager.executeBindings(this,"maxSlot",this.maxSlot);
         return _loc1_;
      }
      
      public function __maxSlot_change(param1:Event) : void
      {
         this.onChangeTableOptions();
      }
      
      private function _GWizToolCrib_HGroup5_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolCrib_Label4_c(),this._GWizToolCrib_Button4_i(),this._GWizToolCrib_Button5_i()];
         _loc1_.id = "ToolCompData";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolCompData = _loc1_;
         BindingManager.executeBindings(this,"ToolCompData",this.ToolCompData);
         return _loc1_;
      }
      
      private function _GWizToolCrib_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tool Comp Data";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_Button4_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "G10";
         _loc1_.toolTip = "Generate a G10 program with tool comp data";
         _loc1_.addEventListener("click",this.__G10_click);
         _loc1_.id = "G10";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.G10 = _loc1_;
         BindingManager.executeBindings(this,"G10",this.G10);
         return _loc1_;
      }
      
      public function __G10_click(param1:MouseEvent) : void
      {
         this.doG10();
      }
      
      private function _GWizToolCrib_Button5_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Use Sim Data";
         _loc1_.toolTip = "Load tool comp data into crib from simulator #variables";
         _loc1_.addEventListener("click",this.__GrabData_click);
         _loc1_.id = "GrabData";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GrabData = _loc1_;
         BindingManager.executeBindings(this,"GrabData",this.GrabData);
         return _loc1_;
      }
      
      public function __GrabData_click(param1:MouseEvent) : void
      {
         this.doUseSimData();
      }
      
      private function _GWizToolCrib_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolCrib_Spacer1_i(),this._GWizToolCrib_TextInput2_i(),this._GWizToolCrib_Button6_c(),this._GWizToolCrib_Button7_c(),this._GWizToolCrib_Spacer2_c(),this._GWizToolCrib_Button8_i(),this._GWizToolCrib_Button9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_Spacer1_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizToolCrib_Spacer1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolCrib_Spacer1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_Spacer1",this._GWizToolCrib_Spacer1);
         return _loc1_;
      }
      
      private function _GWizToolCrib_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.prompt = "Search";
         _loc1_.id = "searchTerms";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.searchTerms = _loc1_;
         BindingManager.executeBindings(this,"searchTerms",this.searchTerms);
         return _loc1_;
      }
      
      private function _GWizToolCrib_Button6_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Find";
         _loc1_.addEventListener("click",this.___GWizToolCrib_Button6_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizToolCrib_Button6_click(param1:MouseEvent) : void
      {
         this.makeRowVisible(this.doSearch(this.searchTerms.text));
      }
      
      private function _GWizToolCrib_Button7_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Next";
         _loc1_.addEventListener("click",this.___GWizToolCrib_Button7_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizToolCrib_Button7_click(param1:MouseEvent) : void
      {
         this.makeRowVisible(this.doSearch(this.searchTerms.text,this.toolList.selectedIndex + 1));
      }
      
      private function _GWizToolCrib_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_Button8_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Import...";
         _loc1_.toolTip = "Load custom tool data from preferences directory.";
         _loc1_.addEventListener("click",this.__importBtn_click);
         _loc1_.id = "importBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.importBtn = _loc1_;
         BindingManager.executeBindings(this,"importBtn",this.importBtn);
         return _loc1_;
      }
      
      public function __importBtn_click(param1:MouseEvent) : void
      {
         this.doLoadData();
      }
      
      private function _GWizToolCrib_Button9_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Export...";
         _loc1_.toolTip = "Export tool crib to a CSV file.";
         _loc1_.addEventListener("click",this.___GWizToolCrib_Button9_click);
         _loc1_.id = "_GWizToolCrib_Button9";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolCrib_Button9 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_Button9",this._GWizToolCrib_Button9);
         return _loc1_;
      }
      
      public function ___GWizToolCrib_Button9_click(param1:MouseEvent) : void
      {
         GWizSettings.cribData.doExport();
      }
      
      private function _GWizToolCrib_HGroup7_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolCrib_Spacer3_i(),this._GWizToolCrib_Button10_i(),this._GWizToolCrib_Button11_i(),this._GWizToolCrib_Spacer4_c(),this._GWizToolCrib_Button12_i(),this._GWizToolCrib_Button13_i(),this._GWizToolCrib_Spacer5_c(),this._GWizToolCrib_Button14_i(),this._GWizToolCrib_Button15_i(),this._GWizToolCrib_Spacer6_c(),this._GWizToolCrib_Button16_i(),this._GWizToolCrib_Button17_i(),this._GWizToolCrib_Button18_i()];
         _loc1_.id = "_GWizToolCrib_HGroup7";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolCrib_HGroup7 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_HGroup7",this._GWizToolCrib_HGroup7);
         return _loc1_;
      }
      
      private function _GWizToolCrib_Spacer3_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizToolCrib_Spacer3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolCrib_Spacer3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_Spacer3",this._GWizToolCrib_Spacer3);
         return _loc1_;
      }
      
      private function _GWizToolCrib_Button10_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "New Tool...";
         _loc1_.addEventListener("click",this.__newTool_click);
         _loc1_.id = "newTool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.newTool = _loc1_;
         BindingManager.executeBindings(this,"newTool",this.newTool);
         return _loc1_;
      }
      
      public function __newTool_click(param1:MouseEvent) : void
      {
         this.showToolEditor(true);
      }
      
      private function _GWizToolCrib_Button11_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Edit Tool...";
         _loc1_.enabled = false;
         _loc1_.addEventListener("click",this.__editTool_click);
         _loc1_.id = "editTool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.editTool = _loc1_;
         BindingManager.executeBindings(this,"editTool",this.editTool);
         return _loc1_;
      }
      
      public function __editTool_click(param1:MouseEvent) : void
      {
         this.showToolEditor(false);
      }
      
      private function _GWizToolCrib_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 40;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_Button12_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Crib Wizard...";
         _loc1_.toolTip = "Quickly add standard cutters to your crib.";
         _loc1_.visible = false;
         _loc1_.addEventListener("click",this.__cribWiz_click);
         _loc1_.id = "cribWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cribWiz = _loc1_;
         BindingManager.executeBindings(this,"cribWiz",this.cribWiz);
         return _loc1_;
      }
      
      public function __cribWiz_click(param1:MouseEvent) : void
      {
         this.onCribWiz();
      }
      
      private function _GWizToolCrib_Button13_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Tasks...";
         _loc1_.addEventListener("click",this.__toolTasks_click);
         _loc1_.id = "toolTasks";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolTasks = _loc1_;
         BindingManager.executeBindings(this,"toolTasks",this.toolTasks);
         return _loc1_;
      }
      
      public function __toolTasks_click(param1:MouseEvent) : void
      {
         this.onTasks();
      }
      
      private function _GWizToolCrib_Spacer5_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 40;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_Button14_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Move Tool...";
         _loc1_.enabled = false;
         _loc1_.addEventListener("click",this.__moveTool_click);
         _loc1_.id = "moveTool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.moveTool = _loc1_;
         BindingManager.executeBindings(this,"moveTool",this.moveTool);
         return _loc1_;
      }
      
      public function __moveTool_click(param1:MouseEvent) : void
      {
         this.openCribSelector("Move",this.onMoveToolOK);
      }
      
      private function _GWizToolCrib_Button15_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Copy Tool...";
         _loc1_.enabled = false;
         _loc1_.addEventListener("click",this.__copyTool_click);
         _loc1_.id = "copyTool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.copyTool = _loc1_;
         BindingManager.executeBindings(this,"copyTool",this.copyTool);
         return _loc1_;
      }
      
      public function __copyTool_click(param1:MouseEvent) : void
      {
         this.openCribSelector("Copy",this.onCopyToolOK);
      }
      
      private function _GWizToolCrib_Spacer6_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_Button16_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Download...";
         _loc1_.toolTip = "Download pre-defined tool cribs from CNCCookbook.  Will not overwrite your cribs of same name.";
         _loc1_.addEventListener("click",this.___GWizToolCrib_Button16_click);
         _loc1_.id = "_GWizToolCrib_Button16";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolCrib_Button16 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_Button16",this._GWizToolCrib_Button16);
         return _loc1_;
      }
      
      public function ___GWizToolCrib_Button16_click(param1:MouseEvent) : void
      {
         this.onDownload();
      }
      
      private function _GWizToolCrib_Button17_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Custom...";
         _loc1_.toolTip = "Add your own custom fields to tool cribs.";
         _loc1_.addEventListener("click",this.__customCrib_click);
         _loc1_.id = "customCrib";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.customCrib = _loc1_;
         BindingManager.executeBindings(this,"customCrib",this.customCrib);
         return _loc1_;
      }
      
      public function __customCrib_click(param1:MouseEvent) : void
      {
         this.onCustomCrib();
      }
      
      private function _GWizToolCrib_Button18_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Del Tool";
         _loc1_.enabled = false;
         _loc1_.addEventListener("click",this.__deleteTool_click);
         _loc1_.id = "deleteTool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.deleteTool = _loc1_;
         BindingManager.executeBindings(this,"deleteTool",this.deleteTool);
         return _loc1_;
      }
      
      public function __deleteTool_click(param1:MouseEvent) : void
      {
         this.deleteRow();
      }
      
      private function _GWizToolCrib_GWizOpSelector1_i() : GWizOpSelector
      {
         var _loc1_:GWizOpSelector = new GWizOpSelector();
         _loc1_.id = "opSelector";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.opSelector = _loc1_;
         BindingManager.executeBindings(this,"opSelector",this.opSelector);
         return _loc1_;
      }
      
      private function _GWizToolCrib_HDividedBox1_c() : HDividedBox
      {
         var temp:HDividedBox = new HDividedBox();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":HDividedBox,
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":GWizDataGrid,
                  "id":"toolList",
                  "events":{
                     "doubleClick":"__toolList_doubleClick",
                     "valueCommit":"__toolList_valueCommit"
                  },
                  "stylesFactory":function():void
                  {
                     this.horizontalScrollPolicy = "auto";
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "configId":"toolCrib",
                        "percentWidth":70,
                        "percentHeight":100,
                        "sortableColumns":false,
                        "editable":false,
                        "doubleClickEnabled":true,
                        "variableRowHeight":true,
                        "columns":_GWizToolCrib_ArrayList1_i()
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":VGroup,
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":30,
                        "percentHeight":100,
                        "mxmlContent":[_GWizToolCrib_GWizPropertyList1_i(),_GWizToolCrib_Button19_i()]
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         return temp;
      }
      
      private function _GWizToolCrib_ArrayList1_i() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizToolCrib_GWizGridColumn1_i(),this._GWizToolCrib_GWizGridColumn2_c(),this._GWizToolCrib_GWizGridColumn3_c(),this._GWizToolCrib_GWizGridColumn4_c(),this._GWizToolCrib_GWizGridColumn5_c(),this._GWizToolCrib_GWizGridColumn6_c(),this._GWizToolCrib_GWizGridColumn7_c(),this._GWizToolCrib_GWizGridColumn8_c(),this._GWizToolCrib_GWizGridColumn9_c(),this._GWizToolCrib_GWizGridColumn10_c(),this._GWizToolCrib_GWizGridColumn11_c(),this._GWizToolCrib_GWizGridColumn12_c(),this._GWizToolCrib_GWizGridColumn13_c(),this._GWizToolCrib_GWizGridColumn14_c(),this._GWizToolCrib_GWizGridColumn15_c(),this._GWizToolCrib_GWizGridColumn16_i(),this._GWizToolCrib_GWizGridColumn17_i(),this._GWizToolCrib_GWizGridColumn18_i(),this._GWizToolCrib_GWizGridColumn19_i(),this._GWizToolCrib_GWizGridColumn20_i(),this._GWizToolCrib_GWizGridColumn21_i(),this._GWizToolCrib_GWizGridColumn22_i(),this._GWizToolCrib_GWizGridColumn23_i(),this._GWizToolCrib_GWizGridColumn24_i(),this._GWizToolCrib_GWizGridColumn25_i(),this._GWizToolCrib_GWizGridColumn26_i(),this._GWizToolCrib_GWizGridColumn27_i(),this._GWizToolCrib_GWizGridColumn28_i(),this._GWizToolCrib_GWizGridColumn29_i(),this._GWizToolCrib_GWizGridColumn30_i(),this._GWizToolCrib_GWizGridColumn31_i(),this._GWizToolCrib_GWizGridColumn32_i(),this._GWizToolCrib_GWizGridColumn33_i(),this._GWizToolCrib_GWizGridColumn34_i(),this._GWizToolCrib_GWizGridColumn35_i(),this._GWizToolCrib_GWizGridColumn36_c(),this._GWizToolCrib_GWizGridColumn37_c(),this._GWizToolCrib_GWizGridColumn38_c(),this._GWizToolCrib_GWizGridColumn39_i(),this._GWizToolCrib_GWizGridColumn40_c(),this._GWizToolCrib_GWizGridColumn41_i(),this._GWizToolCrib_GWizGridColumn42_i(),this._GWizToolCrib_GWizGridColumn43_i(),this._GWizToolCrib_GWizGridColumn44_i(),this._GWizToolCrib_GWizGridColumn45_i(),this._GWizToolCrib_GWizGridColumn46_i(),this._GWizToolCrib_GWizGridColumn47_i(),this._GWizToolCrib_GWizGridColumn48_i(),this._GWizToolCrib_GWizGridColumn49_c()];
         this.gridColList = _loc1_;
         BindingManager.executeBindings(this,"gridColList",this.gridColList);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn1_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colT";
         _loc1_.headerText = "T#";
         _loc1_.dataField = "slot";
         _loc1_.width = 50;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn1",this._GWizToolCrib_GWizGridColumn1);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn2_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colType";
         _loc1_.headerText = "Type";
         _loc1_.dataField = "tool";
         _loc1_.itemRenderer = this._GWizToolCrib_ClassFactory4_c();
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_ClassFactory4_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizToolTypeRenderer;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn3_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colDesc";
         _loc1_.headerText = "Description";
         _loc1_.dataField = "description";
         _loc1_.width = 200;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn4_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colComment";
         _loc1_.headerText = "Comment";
         _loc1_.dataField = "comment";
         _loc1_.width = 200;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn5_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colDiam";
         _loc1_.headerText = "Diameter";
         _loc1_.dataField = "diameter";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 80;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn6_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colFlutes";
         _loc1_.headerText = "Flutes";
         _loc1_.dataField = "flutes";
         _loc1_.width = 60;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn7_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colStickout";
         _loc1_.headerText = "Stickout";
         _loc1_.dataField = "stickout";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 80;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn8_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colLead";
         _loc1_.headerText = "Lead";
         _loc1_.dataField = "leadang";
         _loc1_.width = 60;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn9_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colNoseRad";
         _loc1_.headerText = "Nose Rad.";
         _loc1_.dataField = "noseRad";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 80;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn10_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colCutLength";
         _loc1_.headerText = "Flute Len";
         _loc1_.dataField = "cutLength";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 80;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn11_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colOverallLength";
         _loc1_.headerText = "Overall Len";
         _loc1_.dataField = "overallLength";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 80;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn12_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colShankSz";
         _loc1_.headerText = "Shank Sz";
         _loc1_.dataField = "shankSize";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.width = 80;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn13_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colGeom";
         _loc1_.headerText = "Geometry";
         _loc1_.dataField = "geometry";
         _loc1_.width = 90;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn14_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colCoating";
         _loc1_.headerText = "Coating";
         _loc1_.dataField = "coating";
         _loc1_.width = 60;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn15_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colMaterial";
         _loc1_.headerText = "Material";
         _loc1_.dataField = "toolmaterial";
         _loc1_.width = 60;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn16_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colHelix";
         _loc1_.headerText = "Helix Angle";
         _loc1_.dataField = "helixAngle";
         _loc1_.width = 60;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn16 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn16",this._GWizToolCrib_GWizGridColumn16);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn17_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colSfcSpd";
         _loc1_.headerText = "Sfc Spd";
         _loc1_.labelFunction = this.pctSFM;
         _loc1_.width = 60;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn17 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn17",this._GWizToolCrib_GWizGridColumn17);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn18_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colChipload";
         _loc1_.headerText = "Chipload";
         _loc1_.labelFunction = this.pctIPT;
         _loc1_.width = 60;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn18 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn18",this._GWizToolCrib_GWizGridColumn18);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn19_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colMfgSfcSpd";
         _loc1_.headerText = "Mfg Sfc Spd";
         _loc1_.labelFunction = this.mfgSFM;
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn19 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn19",this._GWizToolCrib_GWizGridColumn19);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn20_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colMfgChipload";
         _loc1_.headerText = "Mfg Chipload";
         _loc1_.labelFunction = this.mfgIPT;
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn20 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn20",this._GWizToolCrib_GWizGridColumn20);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn21_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colToolFamily";
         _loc1_.headerText = "Family";
         _loc1_.dataField = "toolFamily";
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn21 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn21",this._GWizToolCrib_GWizGridColumn21);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn22_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colXWear";
         _loc1_.headerText = "X Wear";
         _loc1_.dataField = "xcomp";
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn22 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn22",this._GWizToolCrib_GWizGridColumn22);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn23_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colZWear";
         _loc1_.headerText = "Z Wear";
         _loc1_.dataField = "zcomp";
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn23 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn23",this._GWizToolCrib_GWizGridColumn23);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn24_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colZGeom";
         _loc1_.headerText = "Z Geom";
         _loc1_.dataField = "zgeom";
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn24 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn24",this._GWizToolCrib_GWizGridColumn24);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn25_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colHolderType";
         _loc1_.headerText = "Holder";
         _loc1_.dataField = "holderType";
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn25 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn25",this._GWizToolCrib_GWizGridColumn25);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn26_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colHolderDesc";
         _loc1_.headerText = "Holder Description";
         _loc1_.dataField = "holderDesc";
         _loc1_.width = 80;
         this._GWizToolCrib_GWizGridColumn26 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn26",this._GWizToolCrib_GWizGridColumn26);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn27_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colHolderDia";
         _loc1_.headerText = "Holder Dia";
         _loc1_.dataField = "holderDia";
         _loc1_.width = 80;
         _loc1_.editable = false;
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         this._GWizToolCrib_GWizGridColumn27 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn27",this._GWizToolCrib_GWizGridColumn27);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn28_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colHolderLen";
         _loc1_.headerText = "Holder Len";
         _loc1_.dataField = "holderLen";
         _loc1_.width = 80;
         _loc1_.editable = false;
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         this._GWizToolCrib_GWizGridColumn28 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn28",this._GWizToolCrib_GWizGridColumn28);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn29_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colClockwise";
         _loc1_.headerText = "Clockwise";
         _loc1_.dataField = "clockwise";
         _loc1_.width = 60;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn29 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn29",this._GWizToolCrib_GWizGridColumn29);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn30_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colShoulderLen";
         _loc1_.headerText = "Shoulder Len";
         _loc1_.dataField = "shoulderLength";
         _loc1_.width = 80;
         _loc1_.editable = false;
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         this._GWizToolCrib_GWizGridColumn30 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn30",this._GWizToolCrib_GWizGridColumn30);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn31_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colTaperAng2";
         _loc1_.headerText = "Taper Ang 2";
         _loc1_.dataField = "taperAngle2";
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn31 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn31",this._GWizToolCrib_GWizGridColumn31);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn32_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colTipLen";
         _loc1_.headerText = "Tip Len";
         _loc1_.dataField = "tipLength";
         _loc1_.width = 80;
         _loc1_.editable = false;
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         this._GWizToolCrib_GWizGridColumn32 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn32",this._GWizToolCrib_GWizGridColumn32);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn33_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colTipDia";
         _loc1_.headerText = "Tip Dia";
         _loc1_.dataField = "tipDiameter";
         _loc1_.width = 80;
         _loc1_.editable = false;
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         this._GWizToolCrib_GWizGridColumn33 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn33",this._GWizToolCrib_GWizGridColumn33);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn34_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colThreadPitch";
         _loc1_.headerText = "Thread Pitch";
         _loc1_.dataField = "threadPitch";
         _loc1_.width = 80;
         _loc1_.editable = false;
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         this._GWizToolCrib_GWizGridColumn34 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn34",this._GWizToolCrib_GWizGridColumn34);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn35_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colSerNum";
         _loc1_.headerText = "Serial #";
         _loc1_.dataField = "serialno";
         _loc1_.width = 60;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn35 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn35",this._GWizToolCrib_GWizGridColumn35);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn36_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colVendor";
         _loc1_.headerText = "Vendor";
         _loc1_.dataField = "vendor";
         _loc1_.width = 80;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn37_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colProduct";
         _loc1_.headerText = "Product";
         _loc1_.dataField = "product";
         _loc1_.width = 80;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn38_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colPartNum";
         _loc1_.headerText = "Part #";
         _loc1_.dataField = "idNo";
         _loc1_.width = 80;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn39_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colInsert";
         _loc1_.headerText = "Insert";
         _loc1_.dataField = "insNo";
         _loc1_.width = 80;
         this._GWizToolCrib_GWizGridColumn39 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn39",this._GWizToolCrib_GWizGridColumn39);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn40_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colProdLink";
         _loc1_.headerText = "Link";
         _loc1_.dataField = "productLink";
         _loc1_.width = 80;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn41_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colJobCode";
         _loc1_.headerText = "Job Code";
         _loc1_.dataField = "jobCode";
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn41 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn41",this._GWizToolCrib_GWizGridColumn41);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn42_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colPricePaid";
         _loc1_.headerText = "Price Paid";
         _loc1_.dataField = "pricePaid";
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn42 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn42",this._GWizToolCrib_GWizGridColumn42);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn43_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colStatus";
         _loc1_.headerText = "Status";
         _loc1_.dataField = "status";
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn43 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn43",this._GWizToolCrib_GWizGridColumn43);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn44_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colQty";
         _loc1_.headerText = "Quantity";
         _loc1_.dataField = "quantity";
         _loc1_.width = 80;
         _loc1_.editable = false;
         this._GWizToolCrib_GWizGridColumn44 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn44",this._GWizToolCrib_GWizGridColumn44);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn45_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colField1";
         _loc1_.dataField = "field1";
         _loc1_.width = 80;
         this._GWizToolCrib_GWizGridColumn45 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn45",this._GWizToolCrib_GWizGridColumn45);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn46_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colField2";
         _loc1_.dataField = "field2";
         _loc1_.width = 80;
         this._GWizToolCrib_GWizGridColumn46 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn46",this._GWizToolCrib_GWizGridColumn46);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn47_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colField3";
         _loc1_.dataField = "field3";
         _loc1_.width = 80;
         this._GWizToolCrib_GWizGridColumn47 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn47",this._GWizToolCrib_GWizGridColumn47);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn48_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colField4";
         _loc1_.dataField = "field4";
         _loc1_.width = 80;
         this._GWizToolCrib_GWizGridColumn48 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_GWizGridColumn48",this._GWizToolCrib_GWizGridColumn48);
         return _loc1_;
      }
      
      private function _GWizToolCrib_GWizGridColumn49_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colGUID";
         _loc1_.headerText = "GUID";
         _loc1_.dataField = "guid";
         _loc1_.width = 80;
         _loc1_.editable = false;
         return _loc1_;
      }
      
      public function __toolList_doubleClick(param1:MouseEvent) : void
      {
         this.sendToFS();
      }
      
      public function __toolList_valueCommit(param1:FlexEvent) : void
      {
         this.onToolSelChange(param1);
      }
      
      private function _GWizToolCrib_GWizPropertyList1_i() : GWizPropertyList
      {
         var _loc1_:GWizPropertyList = new GWizPropertyList();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("doubleClick",this.__pList_doubleClick);
         _loc1_.id = "pList";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pList = _loc1_;
         BindingManager.executeBindings(this,"pList",this.pList);
         return _loc1_;
      }
      
      public function __pList_doubleClick(param1:MouseEvent) : void
      {
         this.showToolEditor(false);
      }
      
      private function _GWizToolCrib_Button19_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Open Product Link";
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("click",this.___GWizToolCrib_Button19_click);
         _loc1_.id = "_GWizToolCrib_Button19";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolCrib_Button19 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_Button19",this._GWizToolCrib_Button19);
         return _loc1_;
      }
      
      public function ___GWizToolCrib_Button19_click(param1:MouseEvent) : void
      {
         this.openProductLink();
      }
      
      private function _GWizToolCrib_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToolCrib_Label5_i(),this._GWizToolCrib_Label6_c(),this._GWizToolCrib_Spacer7_c(),this._GWizToolCrib_Label7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizToolCrib_Label5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolCrib_Label5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_Label5",this._GWizToolCrib_Label5);
         return _loc1_;
      }
      
      private function _GWizToolCrib_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " tools in list. Double click tool to send to Feeds/Speeds.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_Spacer7_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToolCrib_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " (Double click a property row to edit the tool)";
         _loc1_.id = "_GWizToolCrib_Label7";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToolCrib_Label7 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToolCrib_Label7",this._GWizToolCrib_Label7);
         return _loc1_;
      }
      
      public function ___GWizToolCrib_VGroup1_initialize(param1:FlexEvent) : void
      {
         this.onInit();
      }
      
      public function ___GWizToolCrib_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizToolCrib_VGroup1_show(param1:FlexEvent) : void
      {
         this.onShow();
      }
      
      public function ___GWizToolCrib_VGroup1_hide(param1:FlexEvent) : void
      {
         this.onHide();
      }
      
      public function ___GWizToolCrib_VGroup1_keyUp(param1:KeyboardEvent) : void
      {
         this.onKeyUp(param1);
      }
      
      private function _GWizToolCrib_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return firstGrp.height;
         },null,"_GWizToolCrib_Label1.height");
         result[1] = new Binding(this,function():Number
         {
            return DescLab.width;
         },null,"_GWizToolCrib_Label1.width");
         result[2] = new Binding(this,function():IList
         {
            return GWizCribList.cribList;
         },null,"tableChooser.dataProvider");
         result[3] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(isTabbed,powerUserState);
         },null,"allTables.visible");
         result[4] = new Binding(this,function():Boolean
         {
            return allTables.visible;
         },null,"allTables.includeInLayout");
         result[5] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"newTable.enabled");
         result[6] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(isTabbed,!GWizAbstractPrefs.isOEM);
         },null,"newTable.visible");
         result[7] = new Binding(this,function():Boolean
         {
            return newTable.visible;
         },null,"newTable.includeInLayout");
         result[8] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"renameTable.enabled");
         result[9] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(isTabbed,!GWizAbstractPrefs.isOEM);
         },null,"renameTable.visible");
         result[10] = new Binding(this,function():Boolean
         {
            return renameTable.visible;
         },null,"renameTable.includeInLayout");
         result[11] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"delTableBtn.enabled");
         result[12] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(isTabbed,!GWizAbstractPrefs.isOEM);
         },null,"delTableBtn.visible");
         result[13] = new Binding(this,function():Boolean
         {
            return delTableBtn.visible;
         },null,"delTableBtn.includeInLayout");
         result[14] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"descGrp.visible");
         result[15] = new Binding(this,function():Number
         {
            return firstGrp.height;
         },null,"DescLab.height");
         result[16] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"descText.enabled");
         result[17] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(isTabbed,powerUserState);
         },null,"optionsRow.visible");
         result[18] = new Binding(this,function():Boolean
         {
            return optionsRow.visible;
         },null,"optionsRow.includeInLayout");
         result[19] = new Binding(this,function():Number
         {
            return firstGrp.height;
         },null,"_GWizToolCrib_Label3.height");
         result[20] = new Binding(this,null,null,"_GWizToolCrib_Label3.visible","isTabbed");
         result[21] = new Binding(this,function():Number
         {
            return DescLab.width;
         },null,"_GWizToolCrib_Label3.width");
         result[22] = new Binding(this,function():IList
         {
            return GWizCribList.TableTypes;
         },null,"tableType.dataProvider");
         result[23] = new Binding(this,function():Boolean
         {
            return !allTables.selected;
         },null,"tableType.enabled");
         result[24] = new Binding(this,function():Boolean
         {
            return !allTables.selected;
         },null,"maxSlot.enabled");
         result[25] = new Binding(this,null,null,"ToolCompData.visible","isTabbed");
         result[26] = new Binding(this,null,null,"ToolCompData.includeInLayout","isTabbed");
         result[27] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"GrabData.enabled");
         result[28] = new Binding(this,function():Number
         {
            return DescLab.width;
         },null,"_GWizToolCrib_Spacer1.width");
         result[29] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"importBtn.enabled");
         result[30] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"importBtn.visible");
         result[31] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_Button9.visible");
         result[32] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(isTabbed,!GWizAbstractPrefs.isOEM);
         },null,"_GWizToolCrib_HGroup7.visible");
         result[33] = new Binding(this,function():Boolean
         {
            return GWizUtils.AND(isTabbed,!GWizAbstractPrefs.isOEM);
         },null,"_GWizToolCrib_HGroup7.includeInLayout");
         result[34] = new Binding(this,function():Number
         {
            return DescLab.width;
         },null,"_GWizToolCrib_Spacer3.width");
         result[35] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"newTool.enabled");
         result[36] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"newTool.visible");
         result[37] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"editTool.visible");
         result[38] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"cribWiz.enabled");
         result[39] = new Binding(this,function():Boolean
         {
            return taskPopupFcn != null;
         },null,"toolTasks.visible");
         result[40] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"toolTasks.enabled");
         result[41] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"moveTool.visible");
         result[42] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"copyTool.visible");
         result[43] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"_GWizToolCrib_Button16.enabled");
         result[44] = new Binding(this,function():Boolean
         {
            return !lockToolCrib;
         },null,"customCrib.enabled");
         result[45] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"customCrib.visible");
         result[46] = new Binding(this,function():Number
         {
            return delTableBtn.width;
         },null,"deleteTool.width");
         result[47] = new Binding(this,function():Function
         {
            return filterChanged;
         },null,"opSelector.opSelectedFcn");
         result[48] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"opSelector.centerParent");
         result[49] = new Binding(this,function():IList
         {
            return GWizToolCribData.ToolCrib;
         },null,"toolList.dataProvider");
         result[50] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn1.visible");
         result[51] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn16.visible");
         result[52] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn17.visible");
         result[53] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn18.visible");
         result[54] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn19.visible");
         result[55] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn20.visible");
         result[56] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn21.visible");
         result[57] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn22.visible");
         result[58] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn23.visible");
         result[59] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn24.visible");
         result[60] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn25.visible");
         result[61] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn26.visible");
         result[62] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn27.visible");
         result[63] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn28.visible");
         result[64] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn29.visible");
         result[65] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn30.visible");
         result[66] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn31.visible");
         result[67] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn32.visible");
         result[68] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn33.visible");
         result[69] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn34.visible");
         result[70] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn35.visible");
         result[71] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn39.visible");
         result[72] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn41.visible");
         result[73] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn42.visible");
         result[74] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn43.visible");
         result[75] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn44.visible");
         result[76] = new Binding(this,function():String
         {
            var _loc1_:* = GWizToolCrib.field1Name;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizToolCrib_GWizGridColumn45.headerText");
         result[77] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn45.visible");
         result[78] = new Binding(this,function():String
         {
            var _loc1_:* = GWizToolCrib.field2Name;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizToolCrib_GWizGridColumn46.headerText");
         result[79] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn46.visible");
         result[80] = new Binding(this,function():String
         {
            var _loc1_:* = GWizToolCrib.field3Name;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizToolCrib_GWizGridColumn47.headerText");
         result[81] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn47.visible");
         result[82] = new Binding(this,function():String
         {
            var _loc1_:* = GWizToolCrib.field4Name;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizToolCrib_GWizGridColumn48.headerText");
         result[83] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"_GWizToolCrib_GWizGridColumn48.visible");
         result[84] = new Binding(this,function():Array
         {
            var _loc1_:* = fieldList;
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },null,"pList.fieldList");
         result[85] = new Binding(this,function():Boolean
         {
            return allowDoubleClick;
         },null,"pList.doubleClickEnabled");
         result[86] = new Binding(this,function():Array
         {
            var _loc1_:* = GWizToolCribEntry.toolCribUnitFieldList;
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },null,"pList.unitFields");
         result[87] = new Binding(this,function():Boolean
         {
            return productLink != "";
         },null,"_GWizToolCrib_Button19.visible");
         result[88] = new Binding(this,function():String
         {
            var _loc1_:* = listSize;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizToolCrib_Label5.text");
         result[89] = new Binding(this,function():Boolean
         {
            return allowDoubleClick;
         },null,"_GWizToolCrib_Label7.visible");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get DescLab() : Label
      {
         return this._1073484516DescLab;
      }
      
      public function set DescLab(param1:Label) : void
      {
         var _loc2_:Object = this._1073484516DescLab;
         if(_loc2_ !== param1)
         {
            this._1073484516DescLab = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DescLab",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get G10() : Button
      {
         return this._69798G10;
      }
      
      public function set G10(param1:Button) : void
      {
         var _loc2_:Object = this._69798G10;
         if(_loc2_ !== param1)
         {
            this._69798G10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"G10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GrabData() : Button
      {
         return this._151342134GrabData;
      }
      
      public function set GrabData(param1:Button) : void
      {
         var _loc2_:Object = this._151342134GrabData;
         if(_loc2_ !== param1)
         {
            this._151342134GrabData = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GrabData",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolCompData() : HGroup
      {
         return this._1849163057ToolCompData;
      }
      
      public function set ToolCompData(param1:HGroup) : void
      {
         var _loc2_:Object = this._1849163057ToolCompData;
         if(_loc2_ !== param1)
         {
            this._1849163057ToolCompData = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolCompData",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get allTables() : CheckBox
      {
         return this._420862106allTables;
      }
      
      public function set allTables(param1:CheckBox) : void
      {
         var _loc2_:Object = this._420862106allTables;
         if(_loc2_ !== param1)
         {
            this._420862106allTables = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"allTables",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get copyTool() : Button
      {
         return this._505951571copyTool;
      }
      
      public function set copyTool(param1:Button) : void
      {
         var _loc2_:Object = this._505951571copyTool;
         if(_loc2_ !== param1)
         {
            this._505951571copyTool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"copyTool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cribWiz() : Button
      {
         return this._1032250624cribWiz;
      }
      
      public function set cribWiz(param1:Button) : void
      {
         var _loc2_:Object = this._1032250624cribWiz;
         if(_loc2_ !== param1)
         {
            this._1032250624cribWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cribWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get customCrib() : Button
      {
         return this._1582196519customCrib;
      }
      
      public function set customCrib(param1:Button) : void
      {
         var _loc2_:Object = this._1582196519customCrib;
         if(_loc2_ !== param1)
         {
            this._1582196519customCrib = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"customCrib",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get delTableBtn() : Button
      {
         return this._441893671delTableBtn;
      }
      
      public function set delTableBtn(param1:Button) : void
      {
         var _loc2_:Object = this._441893671delTableBtn;
         if(_loc2_ !== param1)
         {
            this._441893671delTableBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"delTableBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get deleteTool() : Button
      {
         return this._1764595171deleteTool;
      }
      
      public function set deleteTool(param1:Button) : void
      {
         var _loc2_:Object = this._1764595171deleteTool;
         if(_loc2_ !== param1)
         {
            this._1764595171deleteTool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"deleteTool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get descGrp() : HGroup
      {
         return this._1556825236descGrp;
      }
      
      public function set descGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._1556825236descGrp;
         if(_loc2_ !== param1)
         {
            this._1556825236descGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"descGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get descText() : TextInput
      {
         return this._1017317214descText;
      }
      
      public function set descText(param1:TextInput) : void
      {
         var _loc2_:Object = this._1017317214descText;
         if(_loc2_ !== param1)
         {
            this._1017317214descText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"descText",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get editTool() : Button
      {
         return this._1602041538editTool;
      }
      
      public function set editTool(param1:Button) : void
      {
         var _loc2_:Object = this._1602041538editTool;
         if(_loc2_ !== param1)
         {
            this._1602041538editTool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"editTool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get firstGrp() : HGroup
      {
         return this._549910507firstGrp;
      }
      
      public function set firstGrp(param1:HGroup) : void
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
      public function get g10style() : RadioButtonGroup
      {
         return this._1142825131g10style;
      }
      
      public function set g10style(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1142825131g10style;
         if(_loc2_ !== param1)
         {
            this._1142825131g10style = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"g10style",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gridColList() : ArrayList
      {
         return this._1333733352gridColList;
      }
      
      public function set gridColList(param1:ArrayList) : void
      {
         var _loc2_:Object = this._1333733352gridColList;
         if(_loc2_ !== param1)
         {
            this._1333733352gridColList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gridColList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get importBtn() : Button
      {
         return this._208554889importBtn;
      }
      
      public function set importBtn(param1:Button) : void
      {
         var _loc2_:Object = this._208554889importBtn;
         if(_loc2_ !== param1)
         {
            this._208554889importBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"importBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get maxSlot() : GWizNumStep
      {
         return this._844083586maxSlot;
      }
      
      public function set maxSlot(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._844083586maxSlot;
         if(_loc2_ !== param1)
         {
            this._844083586maxSlot = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"maxSlot",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get moveTool() : Button
      {
         return this._104412919moveTool;
      }
      
      public function set moveTool(param1:Button) : void
      {
         var _loc2_:Object = this._104412919moveTool;
         if(_loc2_ !== param1)
         {
            this._104412919moveTool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"moveTool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get newTable() : Button
      {
         return this._1366599182newTable;
      }
      
      public function set newTable(param1:Button) : void
      {
         var _loc2_:Object = this._1366599182newTable;
         if(_loc2_ !== param1)
         {
            this._1366599182newTable = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"newTable",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get newTool() : Button
      {
         return this._1845213016newTool;
      }
      
      public function set newTool(param1:Button) : void
      {
         var _loc2_:Object = this._1845213016newTool;
         if(_loc2_ !== param1)
         {
            this._1845213016newTool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"newTool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get opSelector() : GWizOpSelector
      {
         return this._346617056opSelector;
      }
      
      public function set opSelector(param1:GWizOpSelector) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._346617056opSelector;
         if(_loc2_ !== param1)
         {
            this._346617056opSelector = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"opSelector",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get optionsRow() : HGroup
      {
         return this._1374473820optionsRow;
      }
      
      public function set optionsRow(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1374473820optionsRow;
         if(_loc2_ !== param1)
         {
            this._1374473820optionsRow = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"optionsRow",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pList() : GWizPropertyList
      {
         return this._105803054pList;
      }
      
      public function set pList(param1:GWizPropertyList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._105803054pList;
         if(_loc2_ !== param1)
         {
            this._105803054pList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get renameTable() : Button
      {
         return this._138876112renameTable;
      }
      
      public function set renameTable(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._138876112renameTable;
         if(_loc2_ !== param1)
         {
            this._138876112renameTable = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"renameTable",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get searchTerms() : TextInput
      {
         return this._549831489searchTerms;
      }
      
      public function set searchTerms(param1:TextInput) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._549831489searchTerms;
         if(_loc2_ !== param1)
         {
            this._549831489searchTerms = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"searchTerms",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tableChooser() : GWizGWCToolCribSelector
      {
         return this._2080152179tableChooser;
      }
      
      public function set tableChooser(param1:GWizGWCToolCribSelector) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2080152179tableChooser;
         if(_loc2_ !== param1)
         {
            this._2080152179tableChooser = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tableChooser",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tableType() : DropDownList
      {
         return this._1988515800tableType;
      }
      
      public function set tableType(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1988515800tableType;
         if(_loc2_ !== param1)
         {
            this._1988515800tableType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tableType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolList() : GWizDataGrid
      {
         return this._983825834toolList;
      }
      
      public function set toolList(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._983825834toolList;
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
      public function get toolTasks() : Button
      {
         return this._426680106toolTasks;
      }
      
      public function set toolTasks(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._426680106toolTasks;
         if(_loc2_ !== param1)
         {
            this._426680106toolTasks = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolTasks",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get isTabbed() : Boolean
      {
         return this._207353194isTabbed;
      }
      
      public function set isTabbed(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._207353194isTabbed;
         if(_loc2_ !== param1)
         {
            this._207353194isTabbed = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"isTabbed",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get listSize() : int
      {
         return this._1345619391listSize;
      }
      
      private function set listSize(param1:int) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1345619391listSize;
         if(_loc2_ !== param1)
         {
            this._1345619391listSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"listSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get taskPopupFcn() : Function
      {
         return this._927721558taskPopupFcn;
      }
      
      public function set taskPopupFcn(param1:Function) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._927721558taskPopupFcn;
         if(_loc2_ !== param1)
         {
            this._927721558taskPopupFcn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"taskPopupFcn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get easyFieldList() : Array
      {
         return this._541841110easyFieldList;
      }
      
      private function set easyFieldList(param1:Array) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._541841110easyFieldList;
         if(_loc2_ !== param1)
         {
            this._541841110easyFieldList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"easyFieldList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get defFieldList() : Array
      {
         return this._675673549defFieldList;
      }
      
      private function set defFieldList(param1:Array) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._675673549defFieldList;
         if(_loc2_ !== param1)
         {
            this._675673549defFieldList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"defFieldList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get fieldList() : Array
      {
         return this._1264957624fieldList;
      }
      
      private function set fieldList(param1:Array) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1264957624fieldList;
         if(_loc2_ !== param1)
         {
            this._1264957624fieldList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fieldList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get powerUserState() : Boolean
      {
         return this._513770495powerUserState;
      }
      
      private function set powerUserState(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._513770495powerUserState;
         if(_loc2_ !== param1)
         {
            this._513770495powerUserState = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"powerUserState",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get allowDoubleClick() : Boolean
      {
         return this._1439080146allowDoubleClick;
      }
      
      private function set allowDoubleClick(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1439080146allowDoubleClick;
         if(_loc2_ !== param1)
         {
            this._1439080146allowDoubleClick = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"allowDoubleClick",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get productLink() : String
      {
         return this._1491869303productLink;
      }
      
      private function set productLink(param1:String) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1491869303productLink;
         if(_loc2_ !== param1)
         {
            this._1491869303productLink = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"productLink",_loc2_,param1));
            }
         }
      }
   }
}
