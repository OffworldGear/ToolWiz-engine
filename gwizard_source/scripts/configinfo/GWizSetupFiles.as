package configinfo
{
   import comps.GWizForePanel;
   import comps.GWizPopUpManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.globalization.LocaleID;
   import flash.net.FileReference;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
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
   import spark.components.TextInput;
   import spark.components.VGroup;
   import spark.events.TextOperationEvent;
   import spark.layouts.VerticalLayout;
   
   use namespace mx_internal;
   
   public class GWizSetupFiles extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizSetupFiles");
      
      private static var _855010733fileURL:String = "none";
      
      private static var _197447892serverURL:String = "none";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1982161378Backup:GWizForePanel;
      
      private var _2013595014Locale:TextInput;
      
      private var _799233035LocaleGrp:GWizForePanel;
      
      private var _2613508URLs:GWizForePanel;
      
      public var _GWizSetupFiles_Label2:Label;
      
      public var _GWizSetupFiles_Label3:Label;
      
      public var _GWizSetupFiles_Label4:Label;
      
      public var _GWizSetupFiles_Label5:Label;
      
      public var _GWizSetupFiles_Label6:Label;
      
      public var _GWizSetupFiles_TextInput1:TextInput;
      
      public var _GWizSetupFiles_TextInput2:TextInput;
      
      public var _GWizSetupFiles_TextInput4:TextInput;
      
      public var _GWizSetupFiles_TextInput5:TextInput;
      
      private var _1355327339backupDir:TextInput;
      
      private var _154889334longestLabel:Label;
      
      private var _437996325resetCribBtn:Button;
      
      private var _350370538resetGrp:HGroup;
      
      private var _1238272225resetMachinesBtn:Button;
      
      private var _1765271547resetPrefsBtn:Button;
      
      private var _517799243sharedPrefs:GWizSharedPrefs;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1852586209showSharing:Boolean = true;
      
      private const BACKUP_OP:int = 0;
      
      private const RESTORE_OP:int = 1;
      
      private var pendingConfirmOp:int = 0;
      
      private var powerUserState:Boolean = true;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizSetupFiles()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizSetupFiles_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_configinfo_GWizSetupFilesWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizSetupFiles[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.paddingBottom = 5;
         this.paddingLeft = 5;
         this.paddingRight = 5;
         this.mxmlContent = [this._GWizSetupFiles_GWizForePanel1_c(),this._GWizSetupFiles_GWizSharedPrefs1_i(),this._GWizSetupFiles_GWizForePanel2_i(),this._GWizSetupFiles_GWizForePanel3_i(),this._GWizSetupFiles_GWizForePanel4_i(),this._GWizSetupFiles_Spacer1_c(),this._GWizSetupFiles_HGroup8_i()];
         this.addEventListener("creationComplete",this.___GWizSetupFiles_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizSetupFiles._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get fileURL() : String
      {
         return GWizSetupFiles._855010733fileURL;
      }
      
      public static function set fileURL(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSetupFiles._855010733fileURL;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSetupFiles,"fileURL",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get serverURL() : String
      {
         return GWizSetupFiles._197447892serverURL;
      }
      
      public static function set serverURL(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSetupFiles._197447892serverURL;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSetupFiles,"serverURL",_loc2_,param1));
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
         GWizAbstractPrefs.powerUserCC.addFunction("GWizSetupFiles",this.powerUserChanged,false);
         this.powerUserChanged();
      }
      
      private function resetPrefs() : void
      {
         GWizSettings.savePrefs = false;
         var _loc1_:File = GWizSettings.getPrefsFile(GWizSettings.PREFS_NAME);
         _loc1_.deleteFile();
      }
      
      private function resetMachines() : void
      {
         GWizSettings.saveMachines = false;
         var _loc1_:File = GWizSettings.getPrefsFile(GWizSettings.MACHINES_NAME);
         _loc1_.deleteFile();
      }
      
      private function noPrefSave() : void
      {
         GWizSettings.savePrefs = false;
         GWizSettings.saveMachines = false;
         GWizSettings.saveToolCrib = false;
         GWizSettings.saveCodes = false;
         GWizSettings.saveGCVars = false;
         GWizSettings.savePost = false;
      }
      
      private function dobackupDirBrowse() : void
      {
         var _loc1_:File = new File(GWizSettings.prefs.backupDir);
         _loc1_.browseForDirectory(GWizSettings.prefs.backupDir);
         _loc1_.addEventListener(Event.SELECT,this.directorySelected);
      }
      
      private function directorySelected(param1:Event) : void
      {
         var _loc2_:File = param1.target as File;
         GWizSettings.prefs.backupDir = _loc2_.nativePath;
         this.backupDir.text = _loc2_.nativePath;
      }
      
      private function backup(param1:String) : void
      {
         var toFile:File = null;
         var to:FileReference = null;
         var from:File = null;
         var fname:String = param1;
         try
         {
            toFile = new File(GWizSettings.prefs.backupDir);
            toFile = toFile.resolvePath(fname);
            log.debug(toFile.nativePath);
            to = toFile;
            from = GWizSettings.getPrefsFile(fname);
            from.copyTo(to,true);
         }
         catch(e:Error)
         {
            log.debug("Error backing up file: " + e.message);
         }
      }
      
      private function restore(param1:String) : void
      {
         var _loc2_:File = GWizSettings.getPrefsFile(param1);
         var _loc3_:FileReference = _loc2_;
         var _loc4_:File;
         (_loc4_ = new File()).nativePath = GWizSettings.prefs.backupDir;
         (_loc4_ = _loc4_.resolvePath(param1)).copyTo(_loc3_,true);
      }
      
      private function alertListener(param1:CloseEvent) : void
      {
         if(param1.detail == GWizPopUpManager.YES)
         {
            if(this.pendingConfirmOp == this.BACKUP_OP)
            {
               this.doBackupAux();
            }
            else
            {
               this.doRestoreAux();
            }
         }
         else if(param1.detail == GWizPopUpManager.NO)
         {
            this.pendingConfirmOp = this.BACKUP_OP;
         }
      }
      
      private function confirm(param1:int) : void
      {
         this.pendingConfirmOp = param1;
         var _loc2_:* = GWizPopUpManager.YES | GWizPopUpManager.NO;
         var _loc3_:String = "";
         if(param1 == this.BACKUP_OP)
         {
            _loc3_ = "Copy preferences files to Backup Directory?";
         }
         else
         {
            _loc3_ = "Are you sure you want to overwrite your Preferences files from the Backup Directory?";
         }
         GWizPopUpManager.Show(_loc3_,"Confirm Backup/Restore",_loc2_ | GWizPopUpManager.WARN,this,this.alertListener);
      }
      
      private function doBackupAux() : void
      {
         var _loc1_:File = GWizSettings.getPrefsDir();
         var _loc2_:Array = _loc1_.getDirectoryListing();
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_.length)
         {
            this.backup(_loc2_[_loc3_].name);
            _loc3_++;
         }
      }
      
      private function doRestoreAux() : void
      {
         var _loc1_:File = new File(GWizSettings.prefs.backupDir);
         var _loc2_:Array = _loc1_.getDirectoryListing();
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_.length)
         {
            this.restore(_loc2_[_loc3_].name);
            _loc3_++;
         }
         this.noPrefSave();
         GWizPopUpManager.Show("Please Exit and Restart to load the restored Preferences.","Restore Complete");
      }
      
      private function setCustomLocale() : void
      {
         this.setStyle("locale",this.Locale.text);
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         if(GWizSettings.prefs.powerUser != this.powerUserState)
         {
            if(!GWizSettings.prefs.powerUser)
            {
               try
               {
                  this.removeElement(this.sharedPrefs);
               }
               catch(e:Error)
               {
               }
               this.removeElement(this.Backup);
               this.removeElement(this.URLs);
               this.removeElement(this.LocaleGrp);
            }
            this.powerUserState = GWizSettings.prefs.powerUser;
         }
         return true;
      }
      
      private function _GWizSetupFiles_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Folders";
         _loc1_.percentWidth = 100;
         _loc1_.layout = this._GWizSetupFiles_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizSetupFiles_Array2_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupFiles_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Array2_c() : Array
      {
         return [this._GWizSetupFiles_HGroup1_c(),this._GWizSetupFiles_HGroup2_c()];
      }
      
      private function _GWizSetupFiles_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizSetupFiles_Label1_i(),this._GWizSetupFiles_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Preferences Folder";
         _loc1_.id = "longestLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.longestLabel = _loc1_;
         BindingManager.executeBindings(this,"longestLabel",this.longestLabel);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.id = "_GWizSetupFiles_TextInput1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSetupFiles_TextInput1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSetupFiles_TextInput1",this._GWizSetupFiles_TextInput1);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizSetupFiles_Label2_i(),this._GWizSetupFiles_TextInput2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Application Folder";
         _loc1_.id = "_GWizSetupFiles_Label2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSetupFiles_Label2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSetupFiles_Label2",this._GWizSetupFiles_Label2);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.id = "_GWizSetupFiles_TextInput2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSetupFiles_TextInput2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSetupFiles_TextInput2",this._GWizSetupFiles_TextInput2);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_GWizSharedPrefs1_i() : GWizSharedPrefs
      {
         var _loc1_:GWizSharedPrefs = new GWizSharedPrefs();
         _loc1_.title = "Sharing";
         _loc1_.percentWidth = 100;
         _loc1_.id = "sharedPrefs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sharedPrefs = _loc1_;
         BindingManager.executeBindings(this,"sharedPrefs",this.sharedPrefs);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Backup";
         _loc1_.percentWidth = 100;
         _loc1_.layout = this._GWizSetupFiles_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizSetupFiles_Array5_c);
         _loc1_.id = "Backup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Backup = _loc1_;
         BindingManager.executeBindings(this,"Backup",this.Backup);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_VerticalLayout2_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Array5_c() : Array
      {
         return [this._GWizSetupFiles_HGroup3_c(),this._GWizSetupFiles_HGroup4_c()];
      }
      
      private function _GWizSetupFiles_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizSetupFiles_Label3_i(),this._GWizSetupFiles_TextInput3_i(),this._GWizSetupFiles_Button1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Backup Folder";
         _loc1_.id = "_GWizSetupFiles_Label3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSetupFiles_Label3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSetupFiles_Label3",this._GWizSetupFiles_Label3);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Folder used for Backups and Restores";
         _loc1_.id = "backupDir";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.backupDir = _loc1_;
         BindingManager.executeBindings(this,"backupDir",this.backupDir);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Browse";
         _loc1_.toolTip = "Change the Backup Folder";
         _loc1_.addEventListener("click",this.___GWizSetupFiles_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizSetupFiles_Button1_click(param1:MouseEvent) : void
      {
         this.dobackupDirBrowse();
      }
      
      private function _GWizSetupFiles_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizSetupFiles_Button2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Backup";
         _loc1_.toolTip = "Copy preferences files from Preferences Folder to Backup Folder";
         _loc1_.addEventListener("click",this.___GWizSetupFiles_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizSetupFiles_Button2_click(param1:MouseEvent) : void
      {
         this.confirm(this.BACKUP_OP);
      }
      
      private function _GWizSetupFiles_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "URLs";
         _loc1_.percentWidth = 100;
         _loc1_.layout = this._GWizSetupFiles_VerticalLayout3_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizSetupFiles_Array8_c);
         _loc1_.id = "URLs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.URLs = _loc1_;
         BindingManager.executeBindings(this,"URLs",this.URLs);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_VerticalLayout3_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Array8_c() : Array
      {
         return [this._GWizSetupFiles_HGroup5_c(),this._GWizSetupFiles_HGroup6_c()];
      }
      
      private function _GWizSetupFiles_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizSetupFiles_Label4_i(),this._GWizSetupFiles_TextInput4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "File URL";
         _loc1_.id = "_GWizSetupFiles_Label4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSetupFiles_Label4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSetupFiles_Label4",this._GWizSetupFiles_Label4);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_TextInput4_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "URL used to download files.";
         _loc1_.id = "_GWizSetupFiles_TextInput4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSetupFiles_TextInput4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSetupFiles_TextInput4",this._GWizSetupFiles_TextInput4);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizSetupFiles_Label5_i(),this._GWizSetupFiles_TextInput5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Server URL";
         _loc1_.id = "_GWizSetupFiles_Label5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSetupFiles_Label5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSetupFiles_Label5",this._GWizSetupFiles_Label5);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_TextInput5_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "URL used for server communication.";
         _loc1_.id = "_GWizSetupFiles_TextInput5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSetupFiles_TextInput5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSetupFiles_TextInput5",this._GWizSetupFiles_TextInput5);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_GWizForePanel4_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Locale";
         _loc1_.percentWidth = 100;
         _loc1_.layout = this._GWizSetupFiles_VerticalLayout4_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizSetupFiles_Array11_c);
         _loc1_.id = "LocaleGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LocaleGrp = _loc1_;
         BindingManager.executeBindings(this,"LocaleGrp",this.LocaleGrp);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_VerticalLayout4_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Array11_c() : Array
      {
         return [this._GWizSetupFiles_HGroup7_c()];
      }
      
      private function _GWizSetupFiles_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizSetupFiles_Label6_i(),this._GWizSetupFiles_TextInput6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Locale";
         _loc1_.id = "_GWizSetupFiles_Label6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSetupFiles_Label6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSetupFiles_Label6",this._GWizSetupFiles_Label6);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_TextInput6_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = true;
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Language locale, e.g. \'de_DE\'.";
         _loc1_.addEventListener("change",this.__Locale_change);
         _loc1_.id = "Locale";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Locale = _loc1_;
         BindingManager.executeBindings(this,"Locale",this.Locale);
         return _loc1_;
      }
      
      public function __Locale_change(param1:TextOperationEvent) : void
      {
         this.setCustomLocale();
      }
      
      private function _GWizSetupFiles_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSetupFiles_HGroup8_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizSetupFiles_Button3_i(),this._GWizSetupFiles_Button4_i(),this._GWizSetupFiles_Button5_i()];
         _loc1_.id = "resetGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.resetGrp = _loc1_;
         BindingManager.executeBindings(this,"resetGrp",this.resetGrp);
         return _loc1_;
      }
      
      private function _GWizSetupFiles_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Reset Prefs";
         _loc1_.width = 114;
         _loc1_.addEventListener("click",this.__resetPrefsBtn_click);
         _loc1_.id = "resetPrefsBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.resetPrefsBtn = _loc1_;
         BindingManager.executeBindings(this,"resetPrefsBtn",this.resetPrefsBtn);
         return _loc1_;
      }
      
      public function __resetPrefsBtn_click(param1:MouseEvent) : void
      {
         this.resetPrefs();
      }
      
      private function _GWizSetupFiles_Button4_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Reset Machines";
         _loc1_.addEventListener("click",this.__resetMachinesBtn_click);
         _loc1_.id = "resetMachinesBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.resetMachinesBtn = _loc1_;
         BindingManager.executeBindings(this,"resetMachinesBtn",this.resetMachinesBtn);
         return _loc1_;
      }
      
      public function __resetMachinesBtn_click(param1:MouseEvent) : void
      {
         this.resetMachines();
      }
      
      private function _GWizSetupFiles_Button5_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Reset Tool Crib";
         _loc1_.width = 114;
         _loc1_.addEventListener("click",this.__resetCribBtn_click);
         _loc1_.id = "resetCribBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.resetCribBtn = _loc1_;
         BindingManager.executeBindings(this,"resetCribBtn",this.resetCribBtn);
         return _loc1_;
      }
      
      public function __resetCribBtn_click(param1:MouseEvent) : void
      {
         GWizSettings.cribData.resetToolCrib();
      }
      
      public function ___GWizSetupFiles_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizSetupFiles_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():String
         {
            var _loc1_:* = GWizSettings.prefsDir;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizSetupFiles_TextInput1.text");
         result[1] = new Binding(this,function():Number
         {
            return longestLabel.width;
         },null,"_GWizSetupFiles_Label2.width");
         result[2] = new Binding(this,function():String
         {
            var _loc1_:* = GWizSettings.exeDir;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizSetupFiles_TextInput2.text");
         result[3] = new Binding(this,function():Boolean
         {
            return this.showSharing;
         },null,"sharedPrefs.showSharing");
         result[4] = new Binding(this,function():Number
         {
            return longestLabel.width;
         },null,"_GWizSetupFiles_Label3.width");
         result[5] = new Binding(this,function():String
         {
            var _loc1_:* = GWizSettings.prefs.backupDir;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"backupDir.text");
         result[6] = new Binding(this,function():Number
         {
            return longestLabel.width;
         },null,"_GWizSetupFiles_Label4.width");
         result[7] = new Binding(this,function():String
         {
            var _loc1_:* = fileURL;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizSetupFiles_TextInput4.text");
         result[8] = new Binding(this,function():Number
         {
            return longestLabel.width;
         },null,"_GWizSetupFiles_Label5.width");
         result[9] = new Binding(this,function():String
         {
            var _loc1_:* = serverURL;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizSetupFiles_TextInput5.text");
         result[10] = new Binding(this,function():Number
         {
            return longestLabel.width;
         },null,"_GWizSetupFiles_Label6.width");
         result[11] = new Binding(this,function():String
         {
            var _loc1_:* = LocaleID.DEFAULT;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"Locale.text");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Backup() : GWizForePanel
      {
         return this._1982161378Backup;
      }
      
      public function set Backup(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1982161378Backup;
         if(_loc2_ !== param1)
         {
            this._1982161378Backup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Backup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Locale() : TextInput
      {
         return this._2013595014Locale;
      }
      
      public function set Locale(param1:TextInput) : void
      {
         var _loc2_:Object = this._2013595014Locale;
         if(_loc2_ !== param1)
         {
            this._2013595014Locale = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Locale",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LocaleGrp() : GWizForePanel
      {
         return this._799233035LocaleGrp;
      }
      
      public function set LocaleGrp(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._799233035LocaleGrp;
         if(_loc2_ !== param1)
         {
            this._799233035LocaleGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LocaleGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get URLs() : GWizForePanel
      {
         return this._2613508URLs;
      }
      
      public function set URLs(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._2613508URLs;
         if(_loc2_ !== param1)
         {
            this._2613508URLs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"URLs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backupDir() : TextInput
      {
         return this._1355327339backupDir;
      }
      
      public function set backupDir(param1:TextInput) : void
      {
         var _loc2_:Object = this._1355327339backupDir;
         if(_loc2_ !== param1)
         {
            this._1355327339backupDir = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backupDir",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get longestLabel() : Label
      {
         return this._154889334longestLabel;
      }
      
      public function set longestLabel(param1:Label) : void
      {
         var _loc2_:Object = this._154889334longestLabel;
         if(_loc2_ !== param1)
         {
            this._154889334longestLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"longestLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get resetCribBtn() : Button
      {
         return this._437996325resetCribBtn;
      }
      
      public function set resetCribBtn(param1:Button) : void
      {
         var _loc2_:Object = this._437996325resetCribBtn;
         if(_loc2_ !== param1)
         {
            this._437996325resetCribBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"resetCribBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get resetGrp() : HGroup
      {
         return this._350370538resetGrp;
      }
      
      public function set resetGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._350370538resetGrp;
         if(_loc2_ !== param1)
         {
            this._350370538resetGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"resetGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get resetMachinesBtn() : Button
      {
         return this._1238272225resetMachinesBtn;
      }
      
      public function set resetMachinesBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1238272225resetMachinesBtn;
         if(_loc2_ !== param1)
         {
            this._1238272225resetMachinesBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"resetMachinesBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get resetPrefsBtn() : Button
      {
         return this._1765271547resetPrefsBtn;
      }
      
      public function set resetPrefsBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1765271547resetPrefsBtn;
         if(_loc2_ !== param1)
         {
            this._1765271547resetPrefsBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"resetPrefsBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sharedPrefs() : GWizSharedPrefs
      {
         return this._517799243sharedPrefs;
      }
      
      public function set sharedPrefs(param1:GWizSharedPrefs) : void
      {
         var _loc2_:Object = this._517799243sharedPrefs;
         if(_loc2_ !== param1)
         {
            this._517799243sharedPrefs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sharedPrefs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get showSharing() : Boolean
      {
         return this._1852586209showSharing;
      }
      
      public function set showSharing(param1:Boolean) : void
      {
         var _loc2_:Object = this._1852586209showSharing;
         if(_loc2_ !== param1)
         {
            this._1852586209showSharing = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"showSharing",_loc2_,param1));
            }
         }
      }
   }
}
