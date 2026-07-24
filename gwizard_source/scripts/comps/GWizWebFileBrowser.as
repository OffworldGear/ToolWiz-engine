package comps
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.getDefinitionByName;
   import login.GWizCredentials;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.DataGrid;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.gridClasses.GridColumn;
   import utils.GWizCSVUtils;
   import utils.GWizFileUtils;
   import utils.GWizURLLoader;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizWebFileBrowser extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizWebFileBrowser");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizWebFileBrowser_Button1:Button;
      
      private var _164802320browseGrid:DataGrid;
      
      private var _2070217669statusLab:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var source:ArrayCollection;
      
      private var columns:Array;
      
      private var headerText:Array = null;
      
      private var loadFcn:Function = null;
      
      private var _1280300492localFiles:Boolean = false;
      
      private var hangAround:Boolean = true;
      
      private var popupRemoved:Boolean = false;
      
      private var _208553304importDir:String;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizWebFileBrowser()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.source = new ArrayCollection([{
            "Manufacturer":"Glacern",
            "Product":"FM45 Face Mill",
            "Assembly":"Use Widia TS45F",
            "Insert":"SEHT43/SEHW43 Uncoated",
            "url":"http://www.cnccookbook.com/img/GWizard/Downloads/Tooling/WidiaTS45FSEHT4345DegreeFacemill.csv"
         }]);
         this.columns = ["Manufacturer","Product","Assembly","Insert"];
         this._208553304importDir = GWizFileUtils.nativePathToDir(File.documentsDirectory.nativePath);
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizWebFileBrowser_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizWebFileBrowserWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizWebFileBrowser[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.width = 800;
         this.height = 600;
         this.okLabel = "Load";
         this.mxmlContent = [this._GWizWebFileBrowser_Label1_i(),this._GWizWebFileBrowser_DataGrid1_i(),this._GWizWebFileBrowser_Spacer1_c(),this._GWizWebFileBrowser_HGroup1_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizWebFileBrowser._watcherSetupUtil = param1;
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
      
      public function setup(param1:String, param2:String, param3:Array, param4:Function, param5:Boolean = true, param6:Boolean = true) : void
      {
         this.title = param1;
         this.loadFcn = param4;
         this.headerText = param3;
         this.localFiles = param5;
         this.hangAround = param6;
         if(GWizCredentials.badConnection)
         {
            GWizPopUpManager.Show("Online data is unavailable.","No Internet Connection",GWizPopUpManager.WARN);
            this.doOK(false);
         }
         this.loadCatalog(param2);
      }
      
      private function addGridColumn(param1:DataGrid, param2:String, param3:String) : void
      {
         var _loc4_:GridColumn;
         (_loc4_ = new GridColumn(param3)).headerText = param2;
         var _loc5_:IList;
         (_loc5_ = param1.columns).addItem(_loc4_);
         param1.columns = _loc5_;
      }
      
      private function catalogLoaded(param1:String, param2:String) : void
      {
         var _loc3_:int = 0;
         this.source = GWizCSVUtils.CSVToArrayCol(param1,",");
         if(this.source && this.source.length > 0)
         {
            this.columns = GWizCSVUtils.fieldList;
            _loc3_ = 0;
            while(_loc3_ < this.columns.length)
            {
               if(this.columns[_loc3_].toString().toLowerCase() != "url" && this.columns[_loc3_] != "url1" && this.columns[_loc3_] != "url2")
               {
                  this.addGridColumn(this.browseGrid,this.headerText[_loc3_],this.columns[_loc3_]);
               }
               _loc3_++;
            }
            this.browseGrid.dataProvider = this.source;
            this.statusLab.text = "Select data to import:";
         }
         else
         {
            GWizPopUpManager.Show("Online data is unavailable.","No Data",GWizPopUpManager.WARN);
         }
      }
      
      private function loadCatalog(param1:String) : void
      {
         var _loc2_:GWizURLLoader = new GWizURLLoader();
         _loc2_.loadURL(param1,this.catalogLoaded);
         this.statusLab.text = "Loading catalog...";
      }
      
      private function dataLoaded(param1:String, param2:String) : void
      {
         if(!param1)
         {
            GWizPopUpManager.Show("Unable to load requested document.","Error: Load Failed",GWizPopUpManager.ERROR);
         }
         else
         {
            log.debug("Got the data: ");
            log.debug(param1);
            if(this.loadFcn != null)
            {
               this.loadFcn(param1,param2);
            }
         }
         if(!this.popupRemoved)
         {
            super.close();
            this.popupRemoved = true;
         }
      }
      
      private function doOK(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:GWizURLLoader = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(param1)
         {
            this.popupRemoved = false;
            _loc2_ = this.source.getItemAt(this.browseGrid.selectedIndex);
            _loc3_ = _loc2_.url;
            _loc4_ = new GWizURLLoader();
            _loc5_ = 1;
            if((_loc6_ = _loc2_.url1) && _loc6_.length > 0)
            {
               _loc5_++;
            }
            if((_loc7_ = _loc2_.url2) && _loc7_.length > 0)
            {
               _loc5_++;
            }
            _loc5_--;
            _loc4_.loadURL(_loc3_,this.dataLoaded);
            if(_loc5_ > 0)
            {
               _loc5_--;
               _loc4_.loadURL(_loc6_,this.dataLoaded);
               if(_loc5_ > 0)
               {
                  _loc5_--;
                  _loc4_.loadURL(_loc7_,this.dataLoaded);
               }
            }
         }
         this.statusLab.text = "Downloading data...";
         if(!param1 || !this.hangAround)
         {
            super.close();
         }
      }
      
      private function doLoadLocal() : void
      {
         var _loc1_:File = new File(this.importDir);
         _loc1_.browseForOpen(this.importDir);
         _loc1_.addEventListener(Event.SELECT,this.directorySelected);
      }
      
      private function directorySelected(param1:Event) : void
      {
         var custToolDataFile:File = null;
         var stream:FileStream = null;
         var buffer:String = null;
         var event:Event = param1;
         custToolDataFile = event.target as File;
         this.importDir = custToolDataFile.nativePath;
         try
         {
            stream = new FileStream();
            if(custToolDataFile.exists)
            {
               stream.open(custToolDataFile,FileMode.READ);
               buffer = stream.readUTFBytes(stream.bytesAvailable);
               stream.close();
               if(this.loadFcn != null)
               {
                  this.loadFcn(buffer,custToolDataFile.nativePath);
               }
            }
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error loading a local file: " + custToolDataFile.nativePath);
            GWizPopUpManager.Show("Couldn\'t load file " + custToolDataFile.nativePath + ", Error = " + e.message,"Error: Load Failed",GWizPopUpManager.ERROR);
         }
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doOK(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doOK(false);
      }
      
      private function _GWizWebFileBrowser_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Loading choices...";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "statusLab";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.statusLab = _loc1_;
         BindingManager.executeBindings(this,"statusLab",this.statusLab);
         return _loc1_;
      }
      
      private function _GWizWebFileBrowser_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.doubleClickEnabled = true;
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.columns = this._GWizWebFileBrowser_ArrayCollection1_c();
         _loc1_.addEventListener("doubleClick",this.__browseGrid_doubleClick);
         _loc1_.id = "browseGrid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.browseGrid = _loc1_;
         BindingManager.executeBindings(this,"browseGrid",this.browseGrid);
         return _loc1_;
      }
      
      private function _GWizWebFileBrowser_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      public function __browseGrid_doubleClick(param1:MouseEvent) : void
      {
         this.doOK(true);
      }
      
      private function _GWizWebFileBrowser_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWebFileBrowser_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizWebFileBrowser_Button1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizWebFileBrowser_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Load Local File...";
         _loc1_.addEventListener("click",this.___GWizWebFileBrowser_Button1_click);
         _loc1_.id = "_GWizWebFileBrowser_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizWebFileBrowser_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizWebFileBrowser_Button1",this._GWizWebFileBrowser_Button1);
         return _loc1_;
      }
      
      public function ___GWizWebFileBrowser_Button1_click(param1:MouseEvent) : void
      {
         this.doLoadLocal();
      }
      
      private function _GWizWebFileBrowser_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return localFiles;
         },null,"_GWizWebFileBrowser_Button1.visible");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get browseGrid() : DataGrid
      {
         return this._164802320browseGrid;
      }
      
      public function set browseGrid(param1:DataGrid) : void
      {
         var _loc2_:Object = this._164802320browseGrid;
         if(_loc2_ !== param1)
         {
            this._164802320browseGrid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"browseGrid",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get statusLab() : Label
      {
         return this._2070217669statusLab;
      }
      
      public function set statusLab(param1:Label) : void
      {
         var _loc2_:Object = this._2070217669statusLab;
         if(_loc2_ !== param1)
         {
            this._2070217669statusLab = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"statusLab",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get localFiles() : Boolean
      {
         return this._1280300492localFiles;
      }
      
      private function set localFiles(param1:Boolean) : void
      {
         var _loc2_:Object = this._1280300492localFiles;
         if(_loc2_ !== param1)
         {
            this._1280300492localFiles = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"localFiles",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get importDir() : String
      {
         return this._208553304importDir;
      }
      
      private function set importDir(param1:String) : void
      {
         var _loc2_:Object = this._208553304importDir;
         if(_loc2_ !== param1)
         {
            this._208553304importDir = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"importDir",_loc2_,param1));
            }
         }
      }
   }
}
