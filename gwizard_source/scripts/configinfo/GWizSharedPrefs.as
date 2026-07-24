package configinfo
{
   import comps.GWizForePanel;
   import comps.GWizPopUpManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachProfile;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.CloseEvent;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import post.GWizPostFileBrowser;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.TextInput;
   import spark.layouts.VerticalLayout;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizSharedPrefs extends GWizForePanel implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizSharedPrefs");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizSharedPrefs_Label1:Label;
      
      private var _743785426shareDir:TextInput;
      
      private var _736870864sharePrefsCB:CheckBox;
      
      private var _1842528509sharingGroup:HGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1852586209showSharing:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizSharedPrefs()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizSharedPrefs_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_configinfo_GWizSharedPrefsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizSharedPrefs[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.layout = this._GWizSharedPrefs_VerticalLayout1_c();
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizSharedPrefs_Array1_c);
         this.addEventListener("creationComplete",this.___GWizSharedPrefs_GWizForePanel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizSharedPrefs._watcherSetupUtil = param1;
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
         if(GWizSettings.gotPreferences)
         {
            this.shareDir.text = GWizSettings.prefs.sharingDir;
            this.sharePrefsCB.selected = GWizSettings.prefs.sharePrefs;
         }
         else
         {
            this.callLater(this.onCC);
         }
      }
      
      private function doSharingDirBrowse() : void
      {
         var _loc1_:File = new File(GWizSettings.prefs.sharingDir);
         _loc1_.browseForDirectory(GWizSettings.prefs.sharingDir);
         _loc1_.addEventListener(Event.SELECT,this.shareDirSelected);
      }
      
      private function shareDirSelected(param1:Event) : void
      {
         var _loc2_:File = param1.target as File;
         GWizSettings.prefs.sharingDir = _loc2_.nativePath;
         this.shareDir.text = _loc2_.nativePath;
         this.changeSharePrefs();
      }
      
      private function changeSharePrefs() : void
      {
         var error:Boolean = false;
         var backupName:String = null;
         var postsDir:File = null;
         var prefs:File = null;
         var directory:Array = null;
         var f:File = null;
         var targetFile:File = null;
         try
         {
            if(this.sharePrefsCB.selected)
            {
               GWizSettings.prefs.sharePrefs = true;
               error = GWizAbstractPrefs.lockSharedFiles(true);
               if(!GWizMachSettings.machinesFileExists(GWizSettings.prefs.sharingDir))
               {
                  GWizMachSettings.saveMachinesAux();
               }
               else
               {
                  backupName = GWizMachSettings.backupLocal();
                  GWizPopUpManager.Show("Shared Preferences already exist.  Your local prefs have been backed up to " + backupName + ". If you cancel, sharing will be turned off.","Backup Preferences...",GWizPopUpManager.WARN,null,this.alertListener);
               }
               if(error)
               {
                  this.sharePrefsCB.selected = false;
               }
               else
               {
                  postsDir = GWizPostFileBrowser.postsDirectory(false);
                  if(!postsDir.exists)
                  {
                     postsDir.createDirectory();
                     GWizMachProfile.downloadPosts(true);
                  }
                  prefs = GWizSettings.getPrefsDir();
                  postsDir = new File(GWizSettings.prefs.sharingDir);
                  directory = prefs.getDirectoryListing();
                  for each(f in directory)
                  {
                     log.debug(f.nativePath);
                     if(!f.isDirectory && f.extension && f.extension.toLowerCase() == "pst")
                     {
                        targetFile = postsDir.resolvePath(f.name);
                        if(!targetFile.exists)
                        {
                           f.copyTo(postsDir.resolvePath(f.name),true);
                           log.debug("copying: " + f.nativePath);
                        }
                        else
                        {
                           log.debug("Skipping: " + targetFile.nativePath);
                        }
                     }
                  }
                  GWizSettings.post.loadSelectedMachinesPost();
                  if(GWizSettings.cribData.getCribFile(true).exists)
                  {
                     GWizSettings.cribData.loadToolCrib();
                     GWizSettings.cribData.saveToolCrib(true);
                  }
                  if(GWizSettings.FeedsSpeedsApp)
                  {
                     GWizSettings.FeedsSpeedsApp.mfgSpecs.saveToolFamilies();
                  }
               }
            }
            else
            {
               GWizAbstractPrefs.lockSharedFiles(false);
            }
         }
         catch(e:Error)
         {
            log.debug(e.errorID + ": " + e.message);
            GWizUtils.LogError("Error saving machine profiles.");
            sharePrefsCB.selected = false;
            GWizAbstractPrefs.lockSharedFiles(false);
         }
      }
      
      private function alertListener(param1:CloseEvent) : void
      {
         if(param1.detail == GWizPopUpManager.CANCEL)
         {
            this.sharePrefsCB.selected = false;
         }
         else
         {
            GWizMachSettings.loadMachines();
         }
      }
      
      private function _GWizSharedPrefs_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         return _loc1_;
      }
      
      private function _GWizSharedPrefs_Array1_c() : Array
      {
         return [this._GWizSharedPrefs_HGroup1_i(),this._GWizSharedPrefs_HGroup2_c()];
      }
      
      private function _GWizSharedPrefs_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizSharedPrefs_Label1_i(),this._GWizSharedPrefs_TextInput1_i(),this._GWizSharedPrefs_Button1_c()];
         _loc1_.id = "sharingGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sharingGroup = _loc1_;
         BindingManager.executeBindings(this,"sharingGroup",this.sharingGroup);
         return _loc1_;
      }
      
      private function _GWizSharedPrefs_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Sharing Folder";
         _loc1_.id = "_GWizSharedPrefs_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizSharedPrefs_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizSharedPrefs_Label1",this._GWizSharedPrefs_Label1);
         return _loc1_;
      }
      
      private function _GWizSharedPrefs_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Folder used for Shared Preferences";
         _loc1_.id = "shareDir";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.shareDir = _loc1_;
         BindingManager.executeBindings(this,"shareDir",this.shareDir);
         return _loc1_;
      }
      
      private function _GWizSharedPrefs_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Browse";
         _loc1_.toolTip = "Change the Sharing Folder";
         _loc1_.addEventListener("click",this.___GWizSharedPrefs_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizSharedPrefs_Button1_click(param1:MouseEvent) : void
      {
         this.doSharingDirBrowse();
      }
      
      private function _GWizSharedPrefs_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizSharedPrefs_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSharedPrefs_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Use shared preferences";
         _loc1_.addEventListener("valueCommit",this.__sharePrefsCB_valueCommit);
         _loc1_.addEventListener("change",this.__sharePrefsCB_change);
         _loc1_.id = "sharePrefsCB";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sharePrefsCB = _loc1_;
         BindingManager.executeBindings(this,"sharePrefsCB",this.sharePrefsCB);
         return _loc1_;
      }
      
      public function __sharePrefsCB_valueCommit(param1:FlexEvent) : void
      {
         GWizSettings.prefs.sharePrefs = this.sharePrefsCB.selected;
      }
      
      public function __sharePrefsCB_change(param1:Event) : void
      {
         this.changeSharePrefs();
      }
      
      public function ___GWizSharedPrefs_GWizForePanel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizSharedPrefs_bindingsSetup() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new Binding(this,null,null,"this.visible","showSharing");
         _loc1_[1] = new Binding(this,null,null,"_GWizSharedPrefs_Label1.width","labelWidth");
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get shareDir() : TextInput
      {
         return this._743785426shareDir;
      }
      
      public function set shareDir(param1:TextInput) : void
      {
         var _loc2_:Object = this._743785426shareDir;
         if(_loc2_ !== param1)
         {
            this._743785426shareDir = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"shareDir",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sharePrefsCB() : CheckBox
      {
         return this._736870864sharePrefsCB;
      }
      
      public function set sharePrefsCB(param1:CheckBox) : void
      {
         var _loc2_:Object = this._736870864sharePrefsCB;
         if(_loc2_ !== param1)
         {
            this._736870864sharePrefsCB = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sharePrefsCB",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sharingGroup() : HGroup
      {
         return this._1842528509sharingGroup;
      }
      
      public function set sharingGroup(param1:HGroup) : void
      {
         var _loc2_:Object = this._1842528509sharingGroup;
         if(_loc2_ !== param1)
         {
            this._1842528509sharingGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sharingGroup",_loc2_,param1));
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
