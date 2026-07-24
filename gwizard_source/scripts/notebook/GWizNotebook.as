package notebook
{
   import comps.GWizForePanel;
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.CloseEvent;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.List;
   import spark.components.VGroup;
   import utils.ColorPalette;
   import utils.GWizFileUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizNotebook extends GWizForePanel implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizNotebook");
      
      public static const WEB_PAGE:String = "WebPage";
      
      public static const CSV_PAGE:String = "CSVPage";
      
      public static const TXT_PAGE:String = "TXTPage";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _369329508contentReader:VGroup;
      
      private var _859219917pageList:List;
      
      private var _859271610pageName:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var webBrowser:GWizNBWebPage;
      
      public var nbName:String = "Notebook";
      
      private var saveName:String;
      
      private var saveType:String;
      
      private var saveURL:String;
      
      private var saveIndex:int;
      
      private var savePos:int;
      
      private var notebookLoaded:Boolean = false;
      
      private var notebookDirty:Boolean = false;
      
      private var _1666689515notebookContents:ArrayCollection;
      
      private var allowDefaults:Boolean = true;
      
      private var ndi:GWizNotebookDataImport = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizNotebook()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1666689515notebookContents = new ArrayCollection();
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizNotebook_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_notebook_GWizNotebookWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizNotebook[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizNotebook_Array1_c);
         this.addEventListener("creationComplete",this.___GWizNotebook_GWizForePanel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizNotebook._watcherSetupUtil = param1;
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
      
      public function addNotebookPage(param1:String, param2:String, param3:String, param4:int = -1) : void
      {
         var _loc5_:Object = null;
         var _loc7_:* = 0;
         var _loc6_:int = 0;
         while(_loc6_ < this.notebookContents.length)
         {
            if((_loc5_ = this.notebookContents.getItemAt(_loc6_)).name == param1)
            {
               if(param4 != -1)
               {
                  if(_loc5_.isDefault == "true")
                  {
                     GWizPopUpManager.Show("Sorry, can\'t overwrite a default page.","Error: Cannot Overwrite",GWizPopUpManager.ERROR);
                  }
                  else
                  {
                     _loc7_ = GWizPopUpManager.YES | GWizPopUpManager.NO;
                     GWizPopUpManager.Show("Overwrite Notebook page of the same name?","Replace Page",_loc7_ | GWizPopUpManager.WARN,this,this.replaceListener);
                     this.saveName = param1;
                     this.saveType = param2;
                     this.saveURL = param3;
                     this.saveIndex = param4;
                     this.savePos = _loc6_;
                  }
               }
               return;
            }
            _loc6_++;
         }
         this.addNotebookPageAux(param1,param2,param3,param4);
      }
      
      private function addNotebookPageAux(param1:String, param2:String, param3:String, param4:int = -1, param5:int = -1) : void
      {
         var _loc6_:Object;
         (_loc6_ = new Object()).name = this.convertValid(param1,false);
         _loc6_.type = param2;
         _loc6_.url = this.convertValid(param3,true);
         _loc6_.isDefault = param4 == -1 ? "true" : "false";
         if(param4 == -1)
         {
            this.notebookContents.addItem(_loc6_);
         }
         else
         {
            if(param4 >= 0 && this.pageList.selectedIndex >= 0)
            {
               param4 = this.pageList.selectedIndex;
            }
            else
            {
               param4 = 0;
            }
            if(param5 != -1)
            {
               this.notebookContents.removeItemAt(param5);
               param4 = param5;
            }
            this.notebookContents.addItemAt(_loc6_,param4);
         }
         if(param4 != -1)
         {
            this.saveNotebook();
         }
      }
      
      private function replaceListener(param1:CloseEvent) : void
      {
         if(param1.detail == GWizPopUpManager.YES)
         {
            this.addNotebookPageAux(this.saveName,this.saveType,this.saveURL,this.saveIndex,this.savePos);
         }
      }
      
      public function loadNotebook() : void
      {
         var stream:FileStream = null;
         var xml:XML = null;
         var nbFile:File = GWizSettings.getPrefsFile(this.nbName + ".xml");
         try
         {
            stream = new FileStream();
            if(nbFile.exists)
            {
               stream.open(nbFile,FileMode.READ);
               xml = XML(stream.readUTFBytes(stream.bytesAvailable));
               stream.close();
               log.debug("notebook xml = \'" + xml + "\'");
               this.notebookContents.removeAll();
               this.notebookContents = GWizUtils.XMLToArrayCollection(xml);
            }
            this.notebookLoaded = true;
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error with GWizNotebook load.");
         }
      }
      
      public function saveNotebook() : void
      {
         this.notebookDirty = true;
         this.callLater(invalidateProperties);
      }
      
      override public function validateProperties() : void
      {
         super.validateProperties();
         if(this.notebookDirty && this.notebookLoaded)
         {
            if(this.notebookLoaded)
            {
               this.saveNotebookAux();
            }
            else
            {
               this.callLater(invalidateProperties);
            }
         }
      }
      
      private function convertValid(param1:String, param2:Boolean) : String
      {
         var _loc5_:String = null;
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1.charAt(_loc4_);
            if(param2)
            {
               if(!GWizFileUtils.validFilenameChar(_loc5_) && _loc5_ != ":" && _loc5_ != "/")
               {
                  _loc5_ = "_";
               }
            }
            else if(!GWizFileUtils.validFilenameChar(_loc5_))
            {
               _loc5_ = "_";
            }
            _loc3_ += _loc5_;
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function saveNotebookAux() : void
      {
         var xml:XML = null;
         var outputString:String = null;
         var nbFile:File = null;
         var stream:FileStream = null;
         try
         {
            xml = this.toXML();
            outputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
            outputString += xml.toXMLString();
            outputString = outputString.replace(/\n/g,File.lineEnding);
            nbFile = GWizSettings.getPrefsFile(this.nbName + ".xml");
            stream = new FileStream();
            stream.open(nbFile,FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
            this.notebookDirty = false;
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error saving Notebook(\'" + nbName + "\'). msg = " + e.message);
         }
      }
      
      private function toXML() : XML
      {
         var _loc4_:Object = null;
         var _loc1_:* = "";
         _loc1_ += "<root>\n";
         var _loc2_:int = 0;
         while(_loc2_ < this.notebookContents.length)
         {
            _loc4_ = this.notebookContents.getItemAt(_loc2_);
            _loc1_ += "  <item>\n";
            _loc1_ += "    <name>" + _loc4_.name + "</name>\n";
            _loc1_ += "    <type>" + _loc4_.type + "</type>\n";
            _loc1_ += "    <url>" + _loc4_.url + "</url>\n";
            _loc1_ += "    <isDefault>" + _loc4_.isDefault + "</isDefault>\n";
            _loc1_ += "  </item>\n";
            _loc2_++;
         }
         _loc1_ += "</root>\n";
         return new XML(_loc1_);
      }
      
      private function onCC() : void
      {
         this.addNotebookPage("CNCCookbook",WEB_PAGE,"http://www.cnccookbook.com");
         this.loadNotebook();
      }
      
      public function onShow() : void
      {
         if(this.pageList && this.pageList.selectedIndex > -1)
         {
            this.clickPage();
         }
         else
         {
            this.changePage(0);
         }
      }
      
      public function onHide() : void
      {
         this.contentReader.removeAllElements();
      }
      
      private function clickPage() : void
      {
         this.changePage(this.pageList.selectedIndex);
      }
      
      private function changePage(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:GWizNBCSVPage = null;
         var _loc7_:GWizNBNotepadPage = null;
         if(0 <= param1 && param1 < this.notebookContents.length)
         {
            _loc2_ = this.notebookContents.getItemAt(param1);
            if(_loc2_)
            {
               _loc3_ = _loc2_.name;
               _loc4_ = _loc2_.type;
               _loc5_ = _loc2_.url;
               this.contentReader.removeAllElements();
               this.pageName.text = _loc3_;
               switch(_loc4_)
               {
                  case WEB_PAGE:
                     if(!this.webBrowser)
                     {
                        this.webBrowser = new GWizNBWebPage();
                     }
                     this.contentReader.addElement(this.webBrowser);
                     this.webBrowser.setURL(_loc5_);
                     break;
                  case CSV_PAGE:
                     _loc6_ = new GWizNBCSVPage();
                     this.contentReader.addElement(_loc6_);
                     _loc6_.setURL(_loc5_);
                     break;
                  case TXT_PAGE:
                     _loc7_ = new GWizNBNotepadPage();
                     this.contentReader.addElement(_loc7_);
                     _loc7_.setURL(_loc5_);
               }
            }
         }
      }
      
      private function handlePageLoadError(param1:Object) : void
      {
         if(this.pageList == null || this.pageList.selectedItem != param1)
         {
            return;
         }
         this.pageName.text = "Error loading Notebook page.";
         var _loc2_:int = this.notebookContents.getItemIndex(param1);
         if(_loc2_ != -1)
         {
            this.notebookContents.removeItemAt(_loc2_);
            this.saveNotebookAux();
         }
      }
      
      private function doNew() : void
      {
         var _loc1_:GWizNBNewPage = GWizNBNewPage(GWizPopUpManager.createPopUp(this,GWizNBNewPage,true));
         _loc1_.newPageCallback = this.addNotebookPage;
      }
      
      private function doDelete() : void
      {
         var _loc1_:Object = this.notebookContents.getItemAt(this.pageList.selectedIndex);
         if(_loc1_.isDefault != "true")
         {
            this.notebookContents.removeItemAt(this.pageList.selectedIndex);
            this.saveNotebook();
         }
         else
         {
            GWizPopUpManager.Show("Can\'t delete a default page.","Error: Cannot Delete",GWizPopUpManager.ERROR);
         }
      }
      
      private function doUp() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(this.pageList.selectedIndex > 0 && this.notebookContents.length > 0)
         {
            _loc1_ = this.pageList.selectedIndex;
            _loc2_ = this.notebookContents.removeItemAt(this.pageList.selectedIndex);
            this.notebookContents.addItemAt(_loc2_,_loc1_ - 1);
            this.pageList.validateNow();
            this.pageList.selectedIndex = _loc1_ - 1;
            this.saveNotebook();
         }
      }
      
      private function doDown() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(this.pageList.selectedIndex >= 0 && this.pageList.selectedIndex < this.notebookContents.length - 1 && this.notebookContents.length > 0)
         {
            _loc1_ = this.pageList.selectedIndex;
            _loc2_ = this.notebookContents.removeItemAt(this.pageList.selectedIndex);
            this.notebookContents.addItemAt(_loc2_,_loc1_ + 1);
            this.pageList.validateNow();
            this.pageList.selectedIndex = _loc1_ + 1;
            this.saveNotebook();
         }
      }
      
      private function doDownload() : void
      {
         this.ndi = new GWizNotebookDataImport();
         this.ndi.loadCustData = this.loadCustData;
      }
      
      private function loadCustData(param1:String, param2:String) : void
      {
         var f:File = null;
         var stream:FileStream = null;
         var buff:String = param1;
         var url:String = param2;
         var fname:String = "";
         var i:int = url.length - 1;
         while(i >= 0 && url.charAt(i) != "/")
         {
            fname = url.charAt(i) + fname;
            i--;
         }
         log.debug("fname = \'" + fname + "\'");
         var done:Boolean = false;
         var trialFname:String = fname;
         var index:int = 0;
         while(!done)
         {
            f = GWizSettings.getPrefsFile(trialFname);
            if(!f.exists)
            {
               done = true;
            }
            else
            {
               trialFname = String(index) + fname;
               index++;
            }
         }
         fname = trialFname;
         try
         {
            f = GWizSettings.getPrefsFile(fname);
            stream = new FileStream();
            stream.open(f,FileMode.WRITE);
            stream.writeUTFBytes(buff);
            stream.close();
            this.addNotebookPage(fname,this.typeFromExtension(f.extension),f.nativePath,0);
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error saving downloaded notebook file");
            log.debug("Error saving downloaded notebook file");
         }
      }
      
      private function typeFromExtension(param1:String) : String
      {
         var _loc2_:String = WEB_PAGE;
         switch(param1.toLowerCase())
         {
            case "csv":
               _loc2_ = CSV_PAGE;
               break;
            case "htm":
            case "html":
               _loc2_ = WEB_PAGE;
               break;
            default:
               _loc2_ = TXT_PAGE;
         }
         return _loc2_;
      }
      
      private function _GWizNotebook_Array1_c() : Array
      {
         return [this._GWizNotebook_VGroup1_c()];
      }
      
      private function _GWizNotebook_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.paddingTop = 10;
         _loc1_.mxmlContent = [this._GWizNotebook_HGroup1_c(),this._GWizNotebook_HGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizNotebook_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizNotebook_Button1_c(),this._GWizNotebook_Button2_c(),this._GWizNotebook_Button3_c(),this._GWizNotebook_Button4_c(),this._GWizNotebook_Spacer1_c(),this._GWizNotebook_Button5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizNotebook_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 22;
         _loc1_.label = "New...";
         _loc1_.addEventListener("click",this.___GWizNotebook_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizNotebook_Button1_click(param1:MouseEvent) : void
      {
         this.doNew();
      }
      
      private function _GWizNotebook_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Download...";
         _loc1_.height = 22;
         _loc1_.addEventListener("click",this.___GWizNotebook_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizNotebook_Button2_click(param1:MouseEvent) : void
      {
         this.doDownload();
      }
      
      private function _GWizNotebook_Button3_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.width = 34;
         _loc1_.height = 22;
         _loc1_.label = "˄";
         _loc1_.setStyle("fontSize",14);
         _loc1_.addEventListener("click",this.___GWizNotebook_Button3_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizNotebook_Button3_click(param1:MouseEvent) : void
      {
         this.doUp();
      }
      
      private function _GWizNotebook_Button4_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.width = 34;
         _loc1_.height = 22;
         _loc1_.label = "˅";
         _loc1_.setStyle("fontSize",14);
         _loc1_.addEventListener("click",this.___GWizNotebook_Button4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizNotebook_Button4_click(param1:MouseEvent) : void
      {
         this.doDown();
      }
      
      private function _GWizNotebook_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 60;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizNotebook_Button5_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 22;
         _loc1_.label = "Delete";
         _loc1_.addEventListener("click",this.___GWizNotebook_Button5_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizNotebook_Button5_click(param1:MouseEvent) : void
      {
         this.doDelete();
      }
      
      private function _GWizNotebook_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizNotebook_List1_i(),this._GWizNotebook_VGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizNotebook_List1_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.labelField = "name";
         _loc1_.width = 200;
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.__pageList_click);
         _loc1_.id = "pageList";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pageList = _loc1_;
         BindingManager.executeBindings(this,"pageList",this.pageList);
         return _loc1_;
      }
      
      public function __pageList_click(param1:MouseEvent) : void
      {
         this.clickPage();
      }
      
      private function _GWizNotebook_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizNotebook_Label1_i(),this._GWizNotebook_VGroup3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizNotebook_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "pageName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pageName = _loc1_;
         BindingManager.executeBindings(this,"pageName",this.pageName);
         return _loc1_;
      }
      
      private function _GWizNotebook_VGroup3_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "contentReader";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.contentReader = _loc1_;
         BindingManager.executeBindings(this,"contentReader",this.contentReader);
         return _loc1_;
      }
      
      public function ___GWizNotebook_GWizForePanel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizNotebook_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return notebookContents;
         },null,"pageList.dataProvider");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb4;
         },function(param1:uint):void
         {
            pageList.setStyle("selectionColor",param1);
         },"pageList.selectionColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            pageList.setStyle("rollOverColor",param1);
         },"pageList.rollOverColor");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            pageName.setStyle("color",param1);
         },"pageName.color");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get contentReader() : VGroup
      {
         return this._369329508contentReader;
      }
      
      public function set contentReader(param1:VGroup) : void
      {
         var _loc2_:Object = this._369329508contentReader;
         if(_loc2_ !== param1)
         {
            this._369329508contentReader = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentReader",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pageList() : List
      {
         return this._859219917pageList;
      }
      
      public function set pageList(param1:List) : void
      {
         var _loc2_:Object = this._859219917pageList;
         if(_loc2_ !== param1)
         {
            this._859219917pageList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pageList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pageName() : Label
      {
         return this._859271610pageName;
      }
      
      public function set pageName(param1:Label) : void
      {
         var _loc2_:Object = this._859271610pageName;
         if(_loc2_ !== param1)
         {
            this._859271610pageName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pageName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get notebookContents() : ArrayCollection
      {
         return this._1666689515notebookContents;
      }
      
      private function set notebookContents(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._1666689515notebookContents;
         if(_loc2_ !== param1)
         {
            this._1666689515notebookContents = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"notebookContents",_loc2_,param1));
            }
         }
      }
   }
}
