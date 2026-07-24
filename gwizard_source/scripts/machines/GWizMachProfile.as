package machines
{
   import bubbletip.GWizBubbleTip;
   import comps.GWizAppearanceGrp;
   import comps.GWizAxisOptions;
   import comps.GWizFileBrowser;
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.geom.Vector3D;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import login.GWizProvisions;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.containers.ViewStack;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.CloseEvent;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColorStroke;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import post.GWizGCParseData;
   import post.GWizPostFileBrowser;
   import post.GWizPostSettings;
   import post.GWizPostVars;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NavigatorContent;
   import spark.components.NumericStepper;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import spark.events.TextOperationEvent;
   import spark.primitives.Line;
   import utils.ColorPalette;
   import utils.FontSizeManager;
   import utils.GATracker;
   import utils.GWizCSVUtils;
   import utils.GWizCallChain;
   import utils.GWizFileUtils;
   import utils.GWizJustASec;
   import utils.GWizStringUtils;
   import utils.GWizURLLoader;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizMachProfile extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizMachProfile");
      
      private static var gcp:GWizGCParseData = new GWizGCParseData();
      
      private static var parentApp:Object;
      
      private static var updatedControls:Boolean = false;
      
      public static var currMachProfile:GWizMachProfile;
      
      private static var controllerName:String;
      
      private static const POSTS_URL:String = "http://www.cnccookbook.com/img/GWizardE/Downloads/Posts/";
      
      private static const CNC_POSTS_CATALOG:String = POSTS_URL + "CNCPostsCatalog.csv";
      
      private static var loader:GWizURLLoader = new GWizURLLoader();
      
      private static var _1211129254downloading:Boolean = false;
      
      public static var didDownload:Boolean = false;
      
      public static var catalogDownloaded:Boolean = false;
      
      private static var catalogSize:int = 0;
      
      private static var downloadQueue:Array = [];
      
      public static var downloadPostCt:int = 0;
      
      private static var watchdogCt:int = 0;
      
      public static var defMyShopMachine:String = "";
      
      public static var initMyShopDone:Boolean = false;
      
      private static var inPostDownloaded:int = 0;
      
      private static var launchedPostDownloadDoneCheck:Boolean = false;
      
      public static var loadMsg:GWizLoadingProfilesPopup;
      
      private static var renamePopup:GWizRenamePostPopup;
      
      public static var fourthAxis:String = "A";
      
      public static var parallelAxis:String = "X";
      
      public static var rapidsRate:Number = 1800;
      
      public static var xCenter:Number = 0;
      
      public static var yCenter:Number = 0;
      
      public static var zCenter:Number = 0;
      
      private static var AXIS_VECTOR_LEN:int = 1000;
      
      public static var setupLocked:Boolean = false;
      
      public static var setupLockCC:GWizCallChain = new GWizCallChain();
      
      private static var _108456666_showHourlyCost:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _325142647AdjustType:Label;
      
      private var _1480189313AdvancedNav:NavigatorContent;
      
      private var _1664073796Controller:TextInput;
      
      private var _975235311HourlyRate:GWizNumStep;
      
      private var _1974350117Lockable:HGroup;
      
      private var _2390542Make:TextInput;
      
      private var _74517257Model:TextInput;
      
      private var _77302641Post1:HGroup;
      
      private var _1828733680SafeMode:CheckBox;
      
      private var _1855023197SafeModeAdv:CheckBox;
      
      private var _120428047SimpleNav:NavigatorContent;
      
      private var _787319301TravelsLabel:Label;
      
      private var _81880911Units:GWizAppearanceGrp;
      
      public var _GWizMachProfile_ClassFactory1:ClassFactory;
      
      public var _GWizMachProfile_ClassFactory2:ClassFactory;
      
      public var _GWizMachProfile_GWizBubbleTip1:GWizBubbleTip;
      
      public var _GWizMachProfile_GWizBubbleTip2:GWizBubbleTip;
      
      public var _GWizMachProfile_GWizBubbleTip3:GWizBubbleTip;
      
      public var _GWizMachProfile_GWizForePanel1:GWizForePanel;
      
      public var _GWizMachProfile_GWizForePanel3:GWizForePanel;
      
      public var _GWizMachProfile_GWizForePanel4:GWizForePanel;
      
      public var _GWizMachProfile_GWizForePanel5:GWizForePanel;
      
      public var _GWizMachProfile_HGroup10:HGroup;
      
      public var _GWizMachProfile_HGroup11:HGroup;
      
      public var _GWizMachProfile_HGroup17:HGroup;
      
      public var _GWizMachProfile_HGroup23:HGroup;
      
      public var _GWizMachProfile_HGroup25:HGroup;
      
      public var _GWizMachProfile_HGroup27:HGroup;
      
      public var _GWizMachProfile_HGroup6:HGroup;
      
      public var _GWizMachProfile_HGroup8:HGroup;
      
      public var _GWizMachProfile_HGroup9:HGroup;
      
      public var _GWizMachProfile_Label1:Label;
      
      public var _GWizMachProfile_Label10:Label;
      
      public var _GWizMachProfile_Label11:Label;
      
      public var _GWizMachProfile_Label12:Label;
      
      public var _GWizMachProfile_Label13:Label;
      
      public var _GWizMachProfile_Label18:Label;
      
      public var _GWizMachProfile_Label2:Label;
      
      public var _GWizMachProfile_Label3:Label;
      
      public var _GWizMachProfile_Label4:Label;
      
      public var _GWizMachProfile_Label5:Label;
      
      public var _GWizMachProfile_Label6:Label;
      
      public var _GWizMachProfile_Label7:Label;
      
      public var _GWizMachProfile_Label8:Label;
      
      public var _GWizMachProfile_Spacer2:Spacer;
      
      public var _GWizMachProfile_Spacer3:Spacer;
      
      private var _1380236942advancedMachProfileBtn:Button;
      
      private var _2146660419axisOptions:Button;
      
      private var _975152270browseBtn:Button;
      
      private var _427139497conciergeBtn:Button;
      
      private var _546592330coolTime:NumericStepper;
      
      private var _1335492015delBtn:Button;
      
      private var _862964399downloadControllers:Button;
      
      private var _1661895690feedLabel:Label;
      
      private var _1446392814feedLabelWiz:Label;
      
      private var _1090741964hpLabel:Label;
      
      private var _1770188739ignoreSpindleSpeedGCodes:CheckBox;
      
      private var _1165170855ignoreToolchangeGCodes:CheckBox;
      
      private var _1148733095keepMyShop:CheckBox;
      
      private var _1481070737machAccel:GWizNumStep;
      
      private var _549384890machChiploadAdjust:NumericStepper;
      
      private var _186172873machFeed:GWizNumStep;
      
      private var _928684893machFeedSecMode:CheckBox;
      
      private var _2044226871machFeedSimple:GWizNumStep;
      
      private var _1476173179machFlood:CheckBox;
      
      private var _1081756735machHP:GWizNumStep;
      
      private var _825279650machHPC:CheckBox;
      
      private var _1201455917machHPSimple:GWizNumStep;
      
      private var _1680846998machMinRPM:GWizNumStep;
      
      private var _539985384machMinRPMSimple:GWizNumStep;
      
      private var _185960042machMist:CheckBox;
      
      private var _185938140machName:TextInput;
      
      private var _1224754977machNameGrp:GWizMachNameGrp;
      
      private var _825286946machPCN:CheckBox;
      
      private var _825289270machRPM:GWizNumStep;
      
      private var _1148778616machRPMSimple:GWizNumStep;
      
      private var _1816686928machRapids:GWizNumStep;
      
      private var _570473392machSFMAdjust:NumericStepper;
      
      private var _1464167236machSlots:NumericStepper;
      
      private var _825291275machTSC:CheckBox;
      
      private var _185736237machType:GWizMachTypeSelector;
      
      private var _1963316433machWeight:GWizNumStep;
      
      private var _1576518654postRename:Button;
      
      private var _914329027rapidsLabel:Label;
      
      private var _350375283resetBtn:Button;
      
      private var _1872787359saveBtn:Button;
      
      private var _260429100selectedMachine:GWizMachSelector2;
      
      private var _589911613simTimeAdj:NumericStepper;
      
      private var _47346658simpleMachProfileBtn:Button;
      
      private var _1191661135spindleRPMGrp:HGroup;
      
      private var _1650315576spindleTime:NumericStepper;
      
      private var _670905874stSizeLabel:Label;
      
      private var _1658158001taperSize:DropDownList;
      
      private var _1658202858taperType:DropDownList;
      
      private var _879950372tcTime:NumericStepper;
      
      private var _22253370timeParms:GWizForePanel;
      
      private var _983826252toolLife:Label;
      
      private var _310967763toolLifeMsg:Label;
      
      private var _983572238toolType:DropDownList;
      
      private var _112204398views:ViewStack;
      
      private var _28375287wordTime:NumericStepper;
      
      private var _1639395762xTravel:GWizNumStep;
      
      private var _1768067853yTravel:GWizNumStep;
      
      private var _880564172zTravel:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1105127068forceAdvancedMachineProfiles:Boolean = false;
      
      private var stopSMRecursion:Boolean = false;
      
      private var initialSelectMachine:Boolean = true;
      
      private var _1710417185toolMaterial:Array;
      
      private var curvePicker:GWizSpindleCurve = null;
      
      private var axisOptionPicker:GWizAxisOptions = null;
      
      private var hourlyPicker:GWizMachHourly = null;
      
      private var _513770495powerUserState:Boolean = true;
      
      private const SPACER_HT:int = 5;
      
      private var machFile:GWizFileBrowser;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizMachProfile()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1710417185toolMaterial = ["HSS","Carbide","Coated Carbide","Ceramic"];
         this.machFile = new GWizFileBrowser("MachineProfile","MachineProfile","*.csv");
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizMachProfile_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_machines_GWizMachProfileWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizMachProfile[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.styleName = "fontSizeDelta-2";
         this.gap = 0;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 15;
         this.paddingBottom = 10;
         this.mxmlContent = [this._GWizMachProfile_GWizAppearanceGrp1_i(),this._GWizMachProfile_VGroup2_c(),this._GWizMachProfile_GWizForePanel2_c(),this._GWizMachProfile_GWizForePanel9_c()];
         this._GWizMachProfile_ClassFactory1_i();
         this._GWizMachProfile_ClassFactory2_i();
         this.addEventListener("creationComplete",this.___GWizMachProfile_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function toggleUnits() : void
      {
         currMachProfile.Units.impMetric.Inches.selected = !currMachProfile.Units.impMetric.Inches.selected;
         setUnits();
      }
      
      public static function setUnits() : void
      {
         currMachProfile.setUnitsAux();
      }
      
      public static function doBrowseFor(param1:String) : File
      {
         return fileSelectedForOpen(openFileByPostName(param1));
      }
      
      private static function openFileByPostName(param1:String) : File
      {
         var _loc2_:File = GWizPostFileBrowser.postsDirectory();
         return _loc2_.resolvePath("post" + param1 + ".pst");
      }
      
      private static function getPostFile(param1:String) : File
      {
         GATracker.logPageView("SelectPost/" + param1,"SelectPost/" + param1);
         return GWizAbstractPrefs.getShareablePrefsFile(param1);
      }
      
      private static function fileSelectedForOpen(param1:File) : File
      {
         var len:int = 0;
         var f:File = param1;
         if(!f)
         {
            return f;
         }
         var fname:String = GWizURLLoader.URLToFilename(f.url);
         var stream:FileStream = new FileStream();
         var s:String = new String();
         try
         {
            stream.open(f,FileMode.READ);
            len = stream.bytesAvailable;
            if(len > 0)
            {
               s = stream.readUTFBytes(len);
            }
            stream.close();
            if(fname.length > 0)
            {
               f = getPostFile(fname);
               if(f)
               {
                  stream.open(f,FileMode.WRITE);
                  stream.writeUTFBytes(s);
                  stream.close();
                  fname = GWizFileUtils.removeExtension(fname);
                  if(fname.indexOf("post") == 0)
                  {
                     fname = fname.substr("post".length);
                  }
                  controllerName = fname;
                  updateControllerAux();
               }
            }
            else
            {
               f = null;
            }
         }
         catch(e:Error)
         {
            GWizPopUpManager.Show("Sorry, can\'t open the post file.","Error: Open Failed",GWizPopUpManager.ERROR);
            f = null;
         }
         return f;
      }
      
      private static function updateControllerAux() : void
      {
         var _loc1_:Timer = null;
         if(currMachProfile)
         {
            currMachProfile.updateController(controllerName);
         }
         else
         {
            _loc1_ = new Timer(500,1);
            _loc1_.addEventListener("timer",waitTimerHandler);
            _loc1_.start();
         }
      }
      
      private static function waitTimerHandler(param1:TimerEvent) : void
      {
         updateControllerAux();
      }
      
      public static function downloadPosts(param1:Boolean = false) : void
      {
         var _loc2_:File = GWizPostFileBrowser.postsDirectory();
         if(!_loc2_ || param1)
         {
            doDownload();
         }
      }
      
      private static function doDownload(param1:Boolean = true) : void
      {
         var watchdog:GWizJustASec = null;
         var loader:GWizURLLoader = null;
         var msg:String = null;
         var showPopup:Boolean = param1;
         if(downloading || GWizPostVars.noLoad)
         {
            return;
         }
         downloading = true;
         catalogDownloaded = false;
         catalogSize = 0;
         downloadPostCt = 0;
         if(showPopup)
         {
            watchdogCt = 0;
            watchdog = new GWizJustASec(postDownloadWatchdog,7);
            doLoadMsg();
         }
         try
         {
            loader = new GWizURLLoader();
            loader.loadURL(CNC_POSTS_CATALOG,catalogLoaded);
            didDownload = true;
         }
         catch(e:Error)
         {
            msg = "Error downloading controller profiles: " + e.message;
            writeLoadMsg(msg);
            GWizUtils.LogError(msg);
            loadMsg.close();
         }
         GATracker.logPageView("DownloadPosts","DownloadPosts");
      }
      
      private static function catalogLoaded(param1:String, param2:String) : void
      {
         var _loc4_:int = 0;
         writeLoadMsg("Catalog downloaded.");
         var _loc3_:ArrayCollection = GWizCSVUtils.CSVToArrayCol(param1,",");
         if(_loc3_ && _loc3_.length > 0)
         {
            downloadQueue = [];
            catalogSize = _loc3_.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               downloadQueue.push(POSTS_URL + String(_loc3_[_loc4_].Name));
               _loc4_++;
            }
            catalogDownloaded = true;
            downloadPost();
         }
         else
         {
            GWizPopUpManager.Show("Can\'t download post data.","Error: Post Data Unavailable",GWizPopUpManager.ERROR);
         }
      }
      
      private static function downloadPost() : void
      {
         var _loc1_:String = null;
         ++downloadPostCt;
         if(downloadQueue.length > 0)
         {
            _loc1_ = downloadQueue.pop();
            loader.loadURL(_loc1_,postDownloaded);
            writeLoadMsg("Downloaded #" + String(catalogSize--) + ": " + _loc1_);
         }
         --downloadPostCt;
      }
      
      private static function postDownloadWatchdog() : void
      {
         ++watchdogCt;
         if(!catalogDownloaded)
         {
            stopDownloadMode(true);
            GWizPopUpManager.Show("Can\'t download posts from Internet. Make sure your connection is good and allows file downloads. Exit GWE with the X at top right of window.","Error: Can\'t download posts.",GWizPopUpManager.ERROR);
         }
         else if(watchdogCt > 1)
         {
         }
      }
      
      private static function initMyShop() : void
      {
         var _loc2_:GWizJustASec = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(!currMachProfile)
         {
            _loc2_ = new GWizJustASec(initMyShop);
         }
         var _loc1_:ArrayCollection = GWizMachSettings.MyShopMachinesList;
         if(_loc1_.length <= 0)
         {
            if(GWizSettings.prefs.logins <= 1)
            {
               _loc3_ = 0;
               while(_loc3_ < GWizMachSettings.MachinesList.length)
               {
                  if((_loc4_ = GWizMachSettings.MachinesList.getItemAt(_loc3_)).make == "Haas" && String(_loc4_.model).search("VF") >= 0)
                  {
                     _loc1_.addItem(_loc4_);
                     defMyShopMachine = _loc4_.name;
                     break;
                  }
                  _loc3_++;
               }
            }
         }
         initMyShopDone = true;
      }
      
      private static function postDownloaded(param1:String, param2:String) : void
      {
         var justASec:GWizJustASec = null;
         var stream:FileStream = null;
         var poFile:File = null;
         var msg:String = null;
         var post:String = param1;
         var url:String = param2;
         ++inPostDownloaded;
         url = GWizURLLoader.URLToFilename(url);
         if(url.length > 0)
         {
            try
            {
               stream = new FileStream();
               poFile = GWizPostFileBrowser.postsDirectory(false);
               poFile.createDirectory();
               poFile = poFile.resolvePath(url);
               stream.open(poFile,FileMode.WRITE);
               stream.writeUTFBytes(post);
               stream.close();
            }
            catch(e:Error)
            {
               msg = "Error with post download: " + e.message;
               writeLoadMsg(msg);
               GWizUtils.LogError(msg);
            }
            justASec = new GWizJustASec(downloadPost,0);
         }
         --inPostDownloaded;
         if(!launchedPostDownloadDoneCheck)
         {
            launchedPostDownloadDoneCheck = true;
            postDownloadDoneCheck();
         }
      }
      
      private static function postDownloadDoneCheck() : void
      {
         var _loc1_:GWizJustASec = null;
         if(downloadQueue.length <= 0 && inPostDownloaded <= 0 && downloadPostCt <= 0)
         {
            stopDownloadMode();
         }
         else
         {
            _loc1_ = new GWizJustASec(postDownloadDoneCheck,0);
         }
      }
      
      private static function stopDownloadMode(param1:Boolean = false) : void
      {
         GWizPostSettings.lastPostLoaded = "";
         GWizMachProfile.downloading = false;
         writeLoadMsg("Finished downloads!\n\n",true);
         if(!param1)
         {
            if(loadMsg)
            {
               loadMsg.close();
               loadMsg = null;
            }
            initMyShop();
         }
         if(loadMsg)
         {
            loadMsg.close();
         }
         loadMsg = null;
      }
      
      private static function doLoadMsg() : void
      {
         loadMsg = GWizLoadingProfilesPopup(GWizPopUpManager.createPopUp(DisplayObject(parentApp),GWizLoadingProfilesPopup,true));
      }
      
      private static function writeLoadMsg(param1:String, param2:Boolean = false) : void
      {
         if(loadMsg)
         {
            if(param2)
            {
               loadMsg.LineLabel.text = param1;
            }
            loadMsg.msgs.text = param1 + "\n\n" + loadMsg.msgs.text;
         }
      }
      
      public static function getAAxis() : Vector3D
      {
         var _loc1_:Vector3D = null;
         if(fourthAxis == "A")
         {
            _loc1_ = new Vector3D(AXIS_VECTOR_LEN,0,0);
         }
         return _loc1_;
      }
      
      public static function getBAxis() : Vector3D
      {
         var _loc1_:Vector3D = null;
         if(fourthAxis == "B")
         {
            _loc1_ = new Vector3D(0,AXIS_VECTOR_LEN,0);
         }
         return _loc1_;
      }
      
      public static function getCAxis() : Vector3D
      {
         var _loc1_:Vector3D = null;
         if(fourthAxis == "C")
         {
            _loc1_ = new Vector3D(0,0,AXIS_VECTOR_LEN);
         }
         return _loc1_;
      }
      
      public static function doLock() : void
      {
         currMachProfile.doLockAux();
      }
      
      public static function showHourlyCost(param1:Boolean = true) : void
      {
         _showHourlyCost = param1;
      }
      
      public static function lockMachineProfiles(param1:Boolean) : void
      {
         if(!currMachProfile)
         {
            return;
         }
         currMachProfile.blockEnable(!param1);
         if(!param1)
         {
            if(GWizMachSettings.newerMachinesAvailable())
            {
               GWizMachSettings.loadMachines();
            }
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizMachProfile._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get downloading() : Boolean
      {
         return GWizMachProfile._1211129254downloading;
      }
      
      public static function set downloading(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMachProfile._1211129254downloading;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMachProfile,"downloading",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get _showHourlyCost() : Boolean
      {
         return GWizMachProfile._108456666_showHourlyCost;
      }
      
      private static function set _showHourlyCost(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMachProfile._108456666_showHourlyCost;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMachProfile,"_showHourlyCost",_loc2_,param1));
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
         currMachProfile = this;
         GWizMachSettings.selectMachineCC.addFunction("GWizMachProfile",this.matchMachine);
         this.matchMachine();
         this.showMe();
         downloadPosts();
         this.machNameGrp.typeChangeFcn = this.onMachType;
         if(this.forceAdvancedMachineProfiles)
         {
            this.views.selectedIndex = 1;
            this.simpleMachProfileBtn.visible = false;
            this.advancedMachProfileBtn.visible = false;
            this.Units.themeSelector.visible = false;
            this.Units.themeSelector.includeInLayout = false;
         }
         if(GWizMachProfile.defMyShopMachine != "")
         {
            this.selectedMachine.doMachBrowse();
            this.newUserPromptForMyShopSetup();
            GWizMachProfile.defMyShopMachine = "";
         }
         GWizAbstractPrefs.powerUserCC.addFunction("GWizMachProfile",this.powerUserChanged,false);
         this.powerUserChanged();
      }
      
      private function newUserPromptForMyShopSetup() : void
      {
      }
      
      private function matchMachine(param1:Object = null) : Boolean
      {
         this.selectMachine();
         return true;
      }
      
      public function showMe() : void
      {
         this.setLockLabel();
         this.setSelectedFontSize();
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            this.Units.impMetric.Inches.selected = true;
         }
         else
         {
            this.Units.impMetric.mm.selected = true;
         }
         parentApp = this.parentApplication;
         setUnits();
         this.selectMachine();
         if(!updatedControls && GWizSettings.appVersionChanged && !didDownload)
         {
            downloadPosts(true);
            updatedControls = true;
         }
      }
      
      private function setSelectedFontSize() : void
      {
         this.Units.fontManager.selectedIndex = GWizSettings.fontManager.fontSize < FontSizeManager.MEDIUM_FONT ? 0 : (GWizSettings.fontManager.fontSize > FontSizeManager.MEDIUM_FONT ? 2 : 1);
      }
      
      private function confirmDelete(param1:Event) : void
      {
         if(GWizMachSettings.MachinesList.length > 1)
         {
            GWizPopUpManager.Show("Are you sure you want to delete?","Confirm Machine Deletion",GWizPopUpManager.YES | GWizPopUpManager.NO | GWizPopUpManager.WARN,this,this.deleteClickHandler);
         }
         else
         {
            GWizPopUpManager.Show("Can\'t delete the last machine profile--there must be at least one profile.","Error: Cannot Delete Machine",GWizPopUpManager.ERROR);
         }
      }
      
      private function deleteClickHandler(param1:CloseEvent) : void
      {
         if(param1.detail == GWizPopUpManager.YES)
         {
            this.DeleteMachine();
         }
      }
      
      private function DeleteMachine() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Object = null;
         _loc2_ = 0;
         while(_loc2_ < GWizMachSettings.MyShopMachinesList.length)
         {
            _loc1_ = GWizMachSettings.MyShopMachinesList.getItemAt(_loc2_);
            if(_loc1_.name == this.machNameGrp.machName.text)
            {
               GWizMachSettings.MyShopMachinesList.removeItemAt(_loc2_);
               GWizMachSettings.saveMachines();
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < GWizMachSettings.MachinesList.length)
         {
            _loc1_ = GWizMachSettings.MachinesList.getItemAt(_loc2_);
            if(_loc1_.name == this.machNameGrp.machName.text)
            {
               GWizMachSettings.deleteMachineCC.callChain(this.machNameGrp.machName.text);
               GWizMachSettings.MachinesList.removeItemAt(_loc2_);
               GWizMachSettings.saveMachines();
               GWizMachSettings.MachinesList.refresh();
               this.selectedMachine.dropDown.selectedIndex = 0;
               return;
            }
            _loc2_++;
         }
      }
      
      private function selectMachine() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         GWizUtils.LogErrorContext = "GWizMachProfile.selectMachine";
         if(this.stopSMRecursion || GWizMachSettings.MachinesList == null || this.machNameGrp == null || !this.machNameGrp.machName)
         {
            return;
         }
         this.stopSMRecursion = true;
         if(GWizMachSettings.MachinesList.length > 0)
         {
            _loc2_ = GWizMachSettings.MachinesList.getItemAt(0);
            _loc1_ = 0;
            while(_loc1_ < GWizMachSettings.MachinesList.length)
            {
               _loc2_ = GWizMachSettings.MachinesList.getItemAt(_loc1_);
               if(_loc2_.name == GWizMachSettings.currMachine)
               {
                  break;
               }
               _loc1_++;
            }
            this.machNameGrp.machName.text = GWizMachSettings.cleanName(_loc2_.name);
            this.machNameGrp.Make.text = _loc2_.make;
            this.machNameGrp.Model.text = _loc2_.model;
            this.machWeight.setVal(_loc2_.weight);
            if(GWizSpindleCurve.NO_ADJUST <= _loc2_.adjustMode && _loc2_.adjustMode <= GWizSpindleCurve.CURVE_ADJUST)
            {
               GWizSpindleCurve.adjustMode = _loc2_.adjustMode;
            }
            else if(_loc2_.doadjhp != "false")
            {
               GWizSpindleCurve.adjustMode = GWizSpindleCurve.WEIGHT_ADJUST;
            }
            if(_loc2_.hasOwnProperty("vmcRigidity"))
            {
               GWizSpindleCurve.vmcRigidity = String(_loc2_.vmcRigidity) == "true";
            }
            else
            {
               GWizSpindleCurve.vmcRigidity = true;
            }
            GWizSpindleCurve.setSpindleCurve(_loc2_);
            if(!_loc2_.hasOwnProperty("simAdj"))
            {
               _loc2_.simAdj = 100;
            }
            this.simTimeAdj.value = _loc2_.simAdj;
            this.machNameGrp.machType.selectedIndex = 0;
            _loc1_ = 0;
            while(_loc1_ < GWizMachTypeSelector.MachineTypes.length)
            {
               if(GWizMachTypeSelector.MachineTypes[_loc1_] == _loc2_.type)
               {
                  this.machNameGrp.machType.selectedIndex = _loc1_;
                  this.machType.selectedIndex = _loc1_;
                  break;
               }
               _loc1_++;
            }
            this.onMachType();
            this.setTaperInfo(_loc2_);
            this.machRPM.value = _loc2_.rpmLimit;
            if(_loc2_.hasOwnProperty("rpmMinLimit"))
            {
               this.machMinRPM.value = _loc2_.rpmMinLimit;
            }
            else
            {
               this.machMinRPM.value = 0;
            }
            this.machFeed.setVal(_loc2_.feedLimit);
            this.machFeedSecMode.selected = String(_loc2_.feedSecMode).toLowerCase() == "true";
            this.machHP.setVal(_loc2_.hpLimit);
            if(_loc2_.sfmAdjust == 0)
            {
               _loc2_.sfmAdjust = 100;
            }
            this.machSFMAdjust.value = _loc2_.sfmAdjust;
            if(_loc2_.chiploadAdjust == 0)
            {
               _loc2_.chiploadAdjust = 100;
            }
            this.machChiploadAdjust.value = _loc2_.chiploadAdjust;
            this.machRapids.setVal(_loc2_.rapids);
            this.machAccel.value = _loc2_.accel;
            this.machTSC.selected = String(_loc2_.tsc).toLowerCase() == "true";
            this.machHPC.selected = String(_loc2_.hpc).toLowerCase() == "true";
            this.machPCN.selected = String(_loc2_.pcn).toLowerCase() == "true";
            this.machFlood.selected = String(_loc2_.flood).toLowerCase() == "true";
            this.machMist.selected = String(_loc2_.mist).toLowerCase() == "true";
            this.machSlots.value = _loc2_.slots;
            this.tcTime.value = _loc2_.tcTime;
            this.xTravel.setVal(_loc2_.xTravel);
            this.yTravel.setVal(_loc2_.yTravel);
            this.zTravel.setVal(_loc2_.zTravel);
            this.updateSpindleCurve();
            this.spindleTime.value = _loc2_.spindletime;
            this.wordTime.value = _loc2_.wordtime;
            this.coolTime.value = _loc2_.cooltime;
            this.Controller.text = _loc2_.controller;
            if(this.Controller.text == "")
            {
               this.Controller.text = GWizMachSettings.UNDEF_CONTROLLER;
            }
            GWizMachSettings.Control = this.Controller.text;
            this.itemToFourth(_loc2_);
            this.HourlyRate.value = _loc2_.hourly;
            if(_loc2_.hasOwnProperty("safeMode"))
            {
               this.SafeModeAdv.selected = String(_loc2_.safeMode).toLowerCase() == "true";
            }
            else
            {
               _loc2_.safeMode = false;
               this.SafeModeAdv.selected = false;
            }
            this.ignoreSpindleSpeedGCodes.selected = String(_loc2_.ignoreSpindleSpeedGCodes).toLowerCase() == "true";
            this.ignoreToolchangeGCodes.selected = String(_loc2_.ignoreToolchangeGCodes).toLowerCase() == "true";
         }
         this.stopSMRecursion = false;
         this.initialSelectMachine = false;
      }
      
      private function fourthToItem(param1:Object) : void
      {
         param1.fourthAxis = fourthAxis;
         param1.parallelAxis = parallelAxis;
         param1.rapidsRate = rapidsRate;
         param1.xCenter = xCenter;
         param1.yCenter = yCenter;
         param1.zCenter = zCenter;
      }
      
      private function itemToFourth(param1:Object) : void
      {
         fourthAxis = param1.fourthAxis;
         parallelAxis = param1.parallelAxis;
         rapidsRate = param1.rapidsRate;
         xCenter = param1.xCenter;
         yCenter = param1.yCenter;
         zCenter = param1.zCenter;
         if(!fourthAxis || fourthAxis.length != 1)
         {
            fourthAxis = "A";
         }
         if(!parallelAxis || parallelAxis.length != 1)
         {
            parallelAxis = "X";
         }
         if(isNaN(rapidsRate))
         {
            rapidsRate = 1800;
         }
         if(isNaN(xCenter))
         {
            xCenter = 0;
         }
         if(isNaN(yCenter))
         {
            yCenter = 0;
         }
         if(isNaN(zCenter))
         {
            zCenter = 0;
         }
      }
      
      public function modalSetupAddMachine(param1:String, param2:String, param3:String, param4:int, param5:Number, param6:Number, param7:Number, param8:Number) : Boolean
      {
         this.machNameGrp.machName.text = param1;
         this.machNameGrp.Make.text = param2;
         this.machNameGrp.Model.text = param3;
         this.machNameGrp.machType.selectedIndex = param4;
         this.machRPM.value = param5;
         this.machMinRPM.value = param6;
         this.machHP.setVal(param7);
         this.machFeed.setVal(param8);
         return this.UpdateMachine();
      }
      
      private function UpdateMachine() : Boolean
      {
         var _loc1_:int = 0;
         var _loc3_:Object = null;
         GWizUtils.LogErrorContext = "GWizMachProfile.UpdateMachine";
         var _loc2_:String = GWizMachSettings.currMachine;
         if(_loc2_ != this.machNameGrp.machName.text)
         {
            _loc2_ = this.makeUniqueName(this.machNameGrp.machName.text);
            this.machNameGrp.machName.text = _loc2_;
         }
         if(_loc2_ == "")
         {
            GWizPopUpManager.Show("Invalid machine name. Machine names must be valid file names.","Error: Invalid Name",GWizPopUpManager.ERROR);
            return false;
         }
         GATracker.logPageView("Setup/UpdateMachine/" + this.machNameGrp.Make.text + "/" + this.machNameGrp.Model.text + "/" + _loc2_,"Setup UpdateMachine: " + _loc2_);
         if(this.machRPM.value <= 0)
         {
            GWizPopUpManager.Show("Machine max rpm must be greater than 0.","Error: Invalid Max RPM",GWizPopUpManager.ERROR);
            return false;
         }
         if(this.machHP.getVal() <= 0)
         {
            GWizPopUpManager.Show("Machine max power must be greater than 0.","Error: Invalid Max Power",GWizPopUpManager.ERROR);
            return false;
         }
         if(this.machFeed.getVal() <= 0)
         {
            GWizPopUpManager.Show("Machine max feedrate must be greater than 0.","Error: Invalid Max Feedrate",GWizPopUpManager.ERROR);
            return false;
         }
         _loc1_ = 0;
         while(_loc1_ < GWizMachSettings.MachinesList.length)
         {
            _loc3_ = GWizMachSettings.MachinesList.getItemAt(_loc1_);
            if(_loc3_.name == _loc2_)
            {
               _loc3_.name = this.machNameGrp.machName.text;
               _loc3_.make = this.machNameGrp.Make.text;
               _loc3_.weight = this.machWeight.getVal();
               _loc3_.adjustMode = GWizSpindleCurve.adjustMode;
               _loc3_.vmcRigidity = GWizSpindleCurve.vmcRigidity;
               GWizSpindleCurve.getSpindleCurve(_loc3_);
               _loc3_.model = this.machNameGrp.Model.text;
               _loc3_.type = this.machNameGrp.machType.selectedItem;
               _loc3_.taperType = this.taperType.selectedItem;
               _loc3_.taperSize = this.taperSize.selectedItem;
               _loc3_.rpmLimit = this.machRPM.value;
               _loc3_.rpmMinLimit = this.machMinRPM.value;
               _loc3_.feedLimit = this.machFeed.getVal();
               _loc3_.feedSecMode = this.machFeedSecMode.selected;
               _loc3_.hpLimit = this.machHP.getVal();
               _loc3_.sfmAdjust = this.machSFMAdjust.value;
               _loc3_.chiploadAdjust = this.machChiploadAdjust.value;
               _loc3_.rapids = this.machRapids.getVal();
               _loc3_.accel = this.machAccel.value;
               _loc3_.tsc = this.machTSC.selected;
               _loc3_.hpc = this.machHPC.selected;
               _loc3_.pcn = this.machPCN.selected;
               _loc3_.flood = this.machFlood.selected;
               _loc3_.mist = this.machMist.selected;
               _loc3_.slots = this.machSlots.value;
               _loc3_.tcTime = this.tcTime.value;
               _loc3_.xTravel = this.xTravel.getVal();
               _loc3_.yTravel = this.yTravel.getVal();
               _loc3_.zTravel = this.zTravel.getVal();
               _loc3_.spindletime = this.spindleTime.value;
               _loc3_.wordtime = this.wordTime.value;
               _loc3_.cooltime = this.coolTime.value;
               _loc3_.simAdj = this.simTimeAdj.value;
               if(this.Controller.text == "")
               {
                  this.Controller.text = GWizMachSettings.UNDEF_CONTROLLER;
               }
               _loc3_.controller = this.Controller.text;
               this.fourthToItem(_loc3_);
               _loc3_.hourly = this.HourlyRate.getVal();
               _loc3_.changeDate = new Date();
               _loc3_.sessions = 0;
               _loc3_.ignoreSpindleSpeedGCodes = this.ignoreSpindleSpeedGCodes.selected;
               _loc3_.ignoreToolchangeGCodes = this.ignoreToolchangeGCodes.selected;
               _loc3_.safeMode = this.SafeModeAdv.selected;
               if(this.SafeModeAdv.selected)
               {
                  GATracker.logPageView("SafeModeSelected","SafeModeSelected");
               }
               GWizMachSettings.saveMachines();
               if(_loc2_ == GWizMachSettings.currMachine)
               {
                  GWizMachSettings.selectMachineCC.callChain(GWizMachSettings.currMachine);
               }
               break;
            }
            _loc1_++;
         }
         if(_loc1_ >= GWizMachSettings.MachinesList.length)
         {
            this.AddMachine();
         }
         _loc1_ = 0;
         while(_loc1_ < GWizMachSettings.MachinesList.length)
         {
            _loc3_ = GWizMachSettings.MachinesList.getItemAt(_loc1_);
            if(_loc3_.name == _loc2_)
            {
               this.selectedMachine.dropDown.selectedIndex = _loc1_;
               GWizMachBrowser.changeMachine(_loc2_);
               return true;
            }
            _loc1_++;
         }
         return true;
      }
      
      private function makeUniqueName(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc5_:Object = null;
         var _loc2_:int = 100;
         var _loc4_:int = 0;
         var _loc6_:String = param1;
         param1 = GWizFileUtils.fixInvalidFilename(param1,"");
         _loc6_ = param1;
         _loc3_ = 0;
         while(_loc3_ < GWizMachSettings.MachinesList.length)
         {
            if((_loc5_ = GWizMachSettings.MachinesList.getItemAt(_loc3_)).name == param1)
            {
               param1 = _loc6_ + String(_loc4_);
               _loc4_++;
               _loc3_ = 0;
            }
            if(_loc4_ > _loc2_)
            {
               GWizUtils.assert(false);
            }
            _loc3_++;
         }
         return param1;
      }
      
      private function AddMachine() : void
      {
         GWizUtils.LogErrorContext = "GWizMachProfile.AddMachine";
         var _loc1_:Object = new Object();
         _loc1_.name = this.makeUniqueName(this.machNameGrp.machName.text);
         _loc1_.make = this.machNameGrp.Make.text;
         _loc1_.model = this.machNameGrp.Model.text;
         _loc1_.type = this.machNameGrp.machType.selectedItem;
         _loc1_.taperType = this.taperType.selectedItem;
         _loc1_.taperSize = this.taperSize.selectedItem;
         _loc1_.rpmLimit = this.machRPM.value;
         _loc1_.rpmMinLimit = this.machMinRPM.value;
         _loc1_.feedLimit = this.machFeed.getVal();
         _loc1_.feedSecMode = this.machFeedSecMode.selected;
         _loc1_.hpLimit = this.machHP.getVal();
         _loc1_.sfmAdjust = this.machSFMAdjust.value;
         _loc1_.chiploadAdjust = this.machChiploadAdjust.value;
         _loc1_.rapids = this.machRapids.getVal();
         _loc1_.accel = this.machAccel.value;
         _loc1_.weight = this.machWeight.getVal();
         _loc1_.adjustMode = GWizSpindleCurve.adjustMode;
         _loc1_.tsc = this.machTSC.selected;
         _loc1_.hpc = this.machHPC.selected;
         _loc1_.pcn = this.machPCN.selected;
         _loc1_.flood = this.machFlood.selected;
         _loc1_.mist = this.machMist.selected;
         _loc1_.slots = this.machSlots.value;
         _loc1_.tcTime = this.tcTime.value;
         _loc1_.xTravel = this.xTravel.getVal();
         _loc1_.yTravel = this.yTravel.getVal();
         _loc1_.zTravel = this.zTravel.getVal();
         _loc1_.spindletime = this.spindleTime.value;
         _loc1_.wordtime = this.wordTime.value;
         _loc1_.cooltime = this.coolTime.value;
         _loc1_.simAdj = this.simTimeAdj.value;
         if(this.Controller.text == "" || this.Controller.text == GWizMachSettings.UNDEF_CONTROLLER)
         {
            this.Controller.text = GWizMachSettings.UNDEF_CONTROLLER;
            _loc1_.controller = "";
         }
         else
         {
            _loc1_.controller = this.Controller.text;
         }
         this.fourthToItem(_loc1_);
         _loc1_.hourly = this.HourlyRate.getVal();
         _loc1_.changeDate = new Date();
         _loc1_.sessions = 0;
         _loc1_.ignoreSpindleSpeedGCodes = this.ignoreSpindleSpeedGCodes.selected;
         _loc1_.ignoreToolchangeGCodes = this.ignoreToolchangeGCodes.selected;
         _loc1_.safeMode = this.SafeMode.selected;
         GWizMachSettings.MachinesList.addItem(_loc1_);
         GWizMachSettings.newMachineCC.callChain(_loc1_.name);
         GWizMachSettings.saveMachines();
      }
      
      protected function recalcToolLife(param1:FlexEvent) : void
      {
         var _loc2_:Number = 1 / 0.16;
         switch(this.toolType.selectedItem)
         {
            case "HSS":
               _loc2_ = 1 / 0.16;
               break;
            case "Carbide":
               _loc2_ = 1 / 0.35;
               break;
            case "Coated Carbide":
               _loc2_ = 1 / 0.5;
               break;
            case "Ceramic":
               _loc2_ = 1 / 0.6;
         }
         var _loc3_:String = GWizUtils.roundBigTenths(String(Math.pow(100 / this.machSFMAdjust.value,_loc2_)));
         _loc3_ = String(Math.min(Number(_loc3_),1000));
         this.toolLifeMsg.text = _loc3_ + "x as long for ";
      }
      
      private function onMachType() : void
      {
         if(this.taperType)
         {
            if(this.machNameGrp.machType.selectedItem == "Lathe")
            {
               this.taperType.dataProvider = new ArrayCollection(GWizConfigData.latheSpindleNose);
            }
            else
            {
               this.taperType.dataProvider = new ArrayCollection(GWizConfigData.millTapers);
            }
         }
      }
      
      private function setTaperInfo(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ArrayCollection = this.taperType.dataProvider as ArrayCollection;
         this.taperType.selectedIndex = 6;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(_loc3_[_loc2_] == param1.taperType)
            {
               this.taperType.selectedIndex = _loc2_;
               break;
            }
            _loc2_++;
         }
         _loc3_ = this.taperSize.dataProvider as ArrayCollection;
         this.taperSize.selectedIndex = 0;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(_loc3_[_loc2_] == param1.taperSize)
            {
               this.taperSize.selectedIndex = _loc2_;
               break;
            }
            _loc2_++;
         }
      }
      
      private function onTaperType() : void
      {
         if(this.taperSize && this.stage)
         {
            switch(this.taperType.selectedItem)
            {
               case "BT":
               case "CAT":
               case "DIN":
               case "HSK":
               case "NMTB":
                  this.taperSize.visible = true;
                  break;
               default:
                  this.taperSize.visible = false;
            }
         }
      }
      
      public function set unitsMsgTxt(param1:String) : void
      {
         this.Units.unitsText = param1;
      }
      
      private function setUnitsAux() : void
      {
         if(this.Units.impMetric.Inches.selected)
         {
            GWizUtils.Units = GWizUtils.INCHES_UNITS;
         }
         else
         {
            GWizUtils.Units = GWizUtils.MM_UNITS;
         }
         GWizNumStep.checkUnitsCC.callChain(null);
      }
      
      private function doCurve() : void
      {
         this.curvePicker = GWizSpindleCurve(GWizPopUpManager.createPopUp(DisplayObject(GWizSettings.docWindow),GWizSpindleCurve,true));
         this.updateSpindleCurve();
         this.curvePicker.saveDefaults();
      }
      
      private function updateSpindleCurve() : void
      {
         GWizSpindleCurve.machHP = this.machHP.getVal();
         GWizSpindleCurve.machWeight = this.machWeight.getVal();
         GWizSpindleCurve.xTravel = this.xTravel.getVal();
         GWizSpindleCurve.yTravel = this.yTravel.getVal();
         GWizSpindleCurve.zTravel = this.zTravel.getVal();
      }
      
      private function doController(param1:MouseEvent) : void
      {
         if(downloading)
         {
            return;
         }
         var _loc2_:GWizPostFileBrowser = GWizPostFileBrowser(GWizPopUpManager.createPopUp(this,GWizPostFileBrowser,true));
         _loc2_.handler = GWizMachProfile.fileSelectedForOpen;
         if(!GWizPostFileBrowser.postsAvailable)
         {
            _loc2_.close();
            doDownload();
         }
      }
      
      private function updateController(param1:String) : void
      {
         this.Controller.text = param1;
         GWizMachSettings.Control = this.Controller.text;
         this.UpdateMachine();
      }
      
      private function doRename() : void
      {
         renamePopup = GWizRenamePostPopup(GWizPopUpManager.createPopUp(DisplayObject(parentApp),GWizRenamePostPopup,true));
         renamePopup.newName.text = this.Controller.text;
         renamePopup.renameFcn = this.renameThePost;
      }
      
      private function renameThePost(param1:String) : void
      {
         var entry:Object = null;
         var newFile:File = null;
         var theNewName:String = param1;
         if(GWizPostFileBrowser.posts.length <= 0)
         {
            GWizPostFileBrowser.initPostsList(null);
         }
         var searchFor:String = "post" + this.Controller.text + ".pst";
         var i:int = 0;
         while(i < GWizPostFileBrowser.posts.length)
         {
            entry = GWizPostFileBrowser.posts.getItemAt(i);
            if(entry.fname == searchFor)
            {
               try
               {
                  newFile = GWizSettings.getPrefsFile("post" + theNewName + ".pst");
                  (entry.f as File).moveTo(newFile);
                  entry.fname = theNewName;
                  this.Controller.text = theNewName;
                  controllerName = theNewName;
                  updateControllerAux();
               }
               catch(e:Error)
               {
                  GWizPopUpManager.Show("Sorry, can\'t rename the post file. Msg = " + e.message,"Error: Rename Failed",GWizPopUpManager.ERROR);
               }
               return;
            }
            i++;
         }
         log.debug("Never found post in list.");
      }
      
      private function doAxisOptions() : void
      {
         this.axisOptionPicker = GWizAxisOptions(GWizPopUpManager.createPopUp(DisplayObject(GWizSettings.docWindow),GWizAxisOptions,true));
      }
      
      private function doLockAux() : void
      {
         if(this.checkLockID())
         {
            setupLocked = !setupLocked;
            this.setLockLabel();
         }
         else
         {
            GWizPopUpManager.Show("Sorry, locking ID not recognized.","Error: Unrecognized Locking ID",GWizPopUpManager.ERROR);
         }
      }
      
      private function checkLockID() : Boolean
      {
         var _loc1_:Date = GWizProvisions.provisionEndDate(GWizProvisions.appSubscProvision());
         var _loc2_:String = String(int(_loc1_.time / (1000 * 60 * 60 * 24)));
         log.debug("unlockCode = \'" + _loc2_ + "\'");
         return _loc2_ == GWizStringUtils.zapWhiteSpace(this.Units.lockID.text);
      }
      
      private function setLockLabel() : void
      {
         if(!setupLocked)
         {
            this.Units.lockBtn.label = "Lock";
            this.blockEnable(true);
         }
         else
         {
            this.Units.lockBtn.label = "Unlock";
            this.blockEnable(false);
         }
         setupLockCC.callChain(null);
      }
      
      private function blockEnable(param1:Boolean) : void
      {
         this.saveBtn.enabled = param1;
         this.delBtn.enabled = param1;
         this.resetBtn.enabled = param1;
         this.Lockable.enabled = param1;
      }
      
      private function doHourlyCalc(param1:Boolean) : void
      {
         if(param1)
         {
            this.hourlyPicker = GWizMachHourly(GWizPopUpManager.createPopUp(DisplayObject(GWizSettings.docWindow),GWizMachHourly,true));
            this.hourlyPicker.setHourlyRate = this.setHourlyRate;
         }
         else
         {
            GWizPopUpManager.Show("The Machine Hourly Cost Estimator is part of GW Estimator.  Estimator is free for GW Calculator users while it\'s in Beta test.  Check it out on our web site.","Hourly Cost Calculator",GWizPopUpManager.WARN);
         }
      }
      
      private function setHourlyRate(param1:Number) : void
      {
         this.HourlyRate.setVal(param1);
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         if(GWizSettings.prefs.powerUser != this.powerUserState)
         {
            if(!GWizSettings.prefs.powerUser)
            {
            }
            this.powerUserState = GWizSettings.prefs.powerUser;
         }
         return true;
      }
      
      private function requestProfile() : void
      {
         GWizUtils.doWebPage("https://www.cnccookbook.com/g-wizard-machine-concierge-service/");
      }
      
      private function importMachProfile() : void
      {
         this.machFile.doFileOpen(this.fileSelectedForOpen,"Open Machine Profile");
      }
      
      private function fileSelectedForOpen(param1:File) : void
      {
         var ac:ArrayCollection = null;
         var i:int = 0;
         var entry:Object = null;
         var f:File = param1;
         try
         {
            if(!f.exists)
            {
               throw new Error("Error loading machine profile. File not found.");
            }
            ac = GWizCSVUtils.loadCSVFile(f,true,true,GWizMachSettings.machProfileFieldList);
            if(!(ac && ac.length > 0))
            {
               throw new Error("Error loading machine profile. No valid machines.");
            }
            i = 0;
            while(i < ac.length)
            {
               entry = ac.getItemAt(i);
               GWizMachSettings.updateMachinesList(entry.name,entry,false);
               i++;
            }
         }
         catch(e:Error)
         {
            log.debug("Error loading machine profile: " + e.errorID + ", msg = " + e.message);
         }
      }
      
      private function exportMachProfile() : void
      {
         this.machFile.doFileSaveAs(this.fileSelectedForSave,"Save Machine Profile");
      }
      
      private function fileSelectedForSave(param1:File) : void
      {
      }
      
      private function _GWizMachProfile_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizLoadingProfilesPopup;
         _loc1_.properties = {"outerDocument":this};
         this._GWizMachProfile_ClassFactory1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_ClassFactory1",this._GWizMachProfile_ClassFactory1);
         return _loc1_;
      }
      
      private function _GWizMachProfile_ClassFactory2_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizRenamePostPopup;
         _loc1_.properties = {"outerDocument":this};
         this._GWizMachProfile_ClassFactory2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_ClassFactory2",this._GWizMachProfile_ClassFactory2);
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizAppearanceGrp1_i() : GWizAppearanceGrp
      {
         var _loc1_:GWizAppearanceGrp = new GWizAppearanceGrp();
         _loc1_.id = "Units";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Units = _loc1_;
         BindingManager.executeBindings(this,"Units",this.Units);
         return _loc1_;
      }
      
      private function _GWizMachProfile_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.gap = 0;
         _loc1_.paddingTop = 3;
         _loc1_.paddingBottom = 3;
         _loc1_.mxmlContent = [this._GWizMachProfile_Label1_i(),this._GWizMachProfile_GWizForePanel1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Machine Profiles";
         _loc1_.percentWidth = 100;
         _loc1_.styleName = "fontSizeDelta4";
         _loc1_.setStyle("paddingBottom",5);
         _loc1_.setStyle("paddingTop",5);
         _loc1_.setStyle("paddingLeft",5);
         _loc1_.setStyle("paddingRight",5);
         _loc1_.id = "_GWizMachProfile_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label1",this._GWizMachProfile_Label1);
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachProfile_Array3_c);
         _loc1_.id = "_GWizMachProfile_GWizForePanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_GWizForePanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_GWizForePanel1",this._GWizMachProfile_GWizForePanel1);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Array3_c() : Array
      {
         return [this._GWizMachProfile_HGroup1_c()];
      }
      
      private function _GWizMachProfile_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.paddingTop = 0;
         _loc1_.paddingBottom = 0;
         _loc1_.mxmlContent = [this._GWizMachProfile_GWizBubbleTip1_i(),this._GWizMachProfile_Spacer1_c(),this._GWizMachProfile_Button1_i(),this._GWizMachProfile_Button2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizBubbleTip1_i() : GWizBubbleTip
      {
         var _loc1_:GWizBubbleTip = new GWizBubbleTip();
         _loc1_.bubbleID = "MachineProfile";
         _loc1_.mxmlContent = [this._GWizMachProfile_GWizMachSelector21_i()];
         _loc1_.id = "_GWizMachProfile_GWizBubbleTip1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_GWizBubbleTip1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_GWizBubbleTip1",this._GWizMachProfile_GWizBubbleTip1);
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizMachSelector21_i() : GWizMachSelector2
      {
         var _loc1_:GWizMachSelector2 = new GWizMachSelector2();
         _loc1_.width = 161;
         _loc1_.id = "selectedMachine";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.selectedMachine = _loc1_;
         BindingManager.executeBindings(this,"selectedMachine",this.selectedMachine);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Simple...";
         _loc1_.toolTip = "Simple Setup";
         _loc1_.addEventListener("click",this.__simpleMachProfileBtn_click);
         _loc1_.id = "simpleMachProfileBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.simpleMachProfileBtn = _loc1_;
         BindingManager.executeBindings(this,"simpleMachProfileBtn",this.simpleMachProfileBtn);
         return _loc1_;
      }
      
      public function __simpleMachProfileBtn_click(param1:MouseEvent) : void
      {
         this.views.selectedIndex = 0;
      }
      
      private function _GWizMachProfile_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Advanced...";
         _loc1_.toolTip = "Advanced Setup";
         _loc1_.addEventListener("click",this.__advancedMachProfileBtn_click);
         _loc1_.id = "advancedMachProfileBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.advancedMachProfileBtn = _loc1_;
         BindingManager.executeBindings(this,"advancedMachProfileBtn",this.advancedMachProfileBtn);
         return _loc1_;
      }
      
      public function __advancedMachProfileBtn_click(param1:MouseEvent) : void
      {
         this.views.selectedIndex = 1;
      }
      
      private function _GWizMachProfile_GWizForePanel2_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachProfile_Array6_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Array6_c() : Array
      {
         return [this._GWizMachProfile_ViewStack1_i()];
      }
      
      private function _GWizMachProfile_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.creationPolicy = "all";
         temp.id = "views";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"views",
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"SimpleNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "name":"Simple",
                        "label":"Simple",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizMachProfile_Array7_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"AdvancedNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "name":"Advanced",
                        "label":"Advanced",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizMachProfile_Array21_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.views = temp;
         BindingManager.executeBindings(this,"views",this.views);
         return temp;
      }
      
      private function _GWizMachProfile_Array7_c() : Array
      {
         return [this._GWizMachProfile_VGroup3_c()];
      }
      
      private function _GWizMachProfile_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizMachProfile_GWizForePanel3_i(),this._GWizMachProfile_GWizForePanel4_i(),this._GWizMachProfile_GWizForePanel5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Name";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachProfile_Array9_c);
         _loc1_.id = "_GWizMachProfile_GWizForePanel3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_GWizForePanel3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_GWizForePanel3",this._GWizMachProfile_GWizForePanel3);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Array9_c() : Array
      {
         return [this._GWizMachProfile_HGroup2_c()];
      }
      
      private function _GWizMachProfile_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_VGroup4_c(),this._GWizMachProfile_VGroup5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizMachProfile_Label2_i(),this._GWizMachProfile_Label3_i(),this._GWizMachProfile_Label4_i(),this._GWizMachProfile_Label5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "1. What name would you like to use for this Machine?";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label2",this._GWizMachProfile_Label2);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "2. What type of machine is it?";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label3",this._GWizMachProfile_Label3);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "3. Who makes this Machine?";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label4",this._GWizMachProfile_Label4);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "4. What model is this Machine?";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label5",this._GWizMachProfile_Label5);
         return _loc1_;
      }
      
      private function _GWizMachProfile_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.horizontalAlign = "left";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_TextInput1_i(),this._GWizMachProfile_GWizMachTypeSelector1_i(),this._GWizMachProfile_TextInput2_i(),this._GWizMachProfile_TextInput3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = true;
         _loc1_.toolTip = "Name of this machine profile.";
         _loc1_.width = 200;
         _loc1_.prompt = "Name";
         _loc1_.addEventListener("change",this.__machName_change);
         _loc1_.id = "machName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machName = _loc1_;
         BindingManager.executeBindings(this,"machName",this.machName);
         return _loc1_;
      }
      
      public function __machName_change(param1:TextOperationEvent) : void
      {
         this.machNameGrp.machName.text = this.machName.text;
      }
      
      private function _GWizMachProfile_GWizMachTypeSelector1_i() : GWizMachTypeSelector
      {
         var _loc1_:GWizMachTypeSelector = new GWizMachTypeSelector();
         _loc1_.addEventListener("change",this.__machType_change);
         _loc1_.id = "machType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machType = _loc1_;
         BindingManager.executeBindings(this,"machType",this.machType);
         return _loc1_;
      }
      
      public function __machType_change(param1:IndexChangeEvent) : void
      {
         this.machNameGrp.machType.selectedIndex = this.machType.selectedIndex;
      }
      
      private function _GWizMachProfile_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = true;
         _loc1_.toolTip = "Machine manufacturer.";
         _loc1_.width = 200;
         _loc1_.prompt = "Make";
         _loc1_.addEventListener("change",this.__Make_change);
         _loc1_.id = "Make";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Make = _loc1_;
         BindingManager.executeBindings(this,"Make",this.Make);
         return _loc1_;
      }
      
      public function __Make_change(param1:TextOperationEvent) : void
      {
         this.machNameGrp.Make.text = this.Make.text;
      }
      
      private function _GWizMachProfile_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = true;
         _loc1_.toolTip = "Machine model name.";
         _loc1_.width = 200;
         _loc1_.prompt = "Model";
         _loc1_.addEventListener("change",this.__Model_change);
         _loc1_.id = "Model";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Model = _loc1_;
         BindingManager.executeBindings(this,"Model",this.Model);
         return _loc1_;
      }
      
      public function __Model_change(param1:TextOperationEvent) : void
      {
         this.machNameGrp.Model.text = this.Model.text;
      }
      
      private function _GWizMachProfile_GWizForePanel4_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Limits";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachProfile_Array13_c);
         _loc1_.id = "_GWizMachProfile_GWizForePanel4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_GWizForePanel4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_GWizForePanel4",this._GWizMachProfile_GWizForePanel4);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Array13_c() : Array
      {
         return [this._GWizMachProfile_HGroup3_c()];
      }
      
      private function _GWizMachProfile_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_VGroup6_c(),this._GWizMachProfile_VGroup7_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_VGroup6_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizMachProfile_Label6_i(),this._GWizMachProfile_Label7_i(),this._GWizMachProfile_Label8_i(),this._GWizMachProfile_Label9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "5. Max Spindle RPM";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label6",this._GWizMachProfile_Label6);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "6. Min Spindle RPM";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label7";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label7 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label7",this._GWizMachProfile_Label7);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "7. Spindle Power";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label8";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label8 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label8",this._GWizMachProfile_Label8);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "8. Max Feedrate";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "feedLabelWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.feedLabelWiz = _loc1_;
         BindingManager.executeBindings(this,"feedLabelWiz",this.feedLabelWiz);
         return _loc1_;
      }
      
      private function _GWizMachProfile_VGroup7_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.horizontalAlign = "left";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_GWizNumStep1_i(),this._GWizMachProfile_GWizNumStep2_i(),this._GWizMachProfile_GWizNumStep3_i(),this._GWizMachProfile_GWizNumStep4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.toolTip = "Maximum rpm the spindle is capable of.";
         _loc1_.min = 0;
         _loc1_.steps = 10;
         _loc1_.stepWidth = 70;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__machRPMSimple_change);
         _loc1_.id = "machRPMSimple";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machRPMSimple = _loc1_;
         BindingManager.executeBindings(this,"machRPMSimple",this.machRPMSimple);
         return _loc1_;
      }
      
      public function __machRPMSimple_change(param1:Event) : void
      {
         this.machRPM.value = this.machRPMSimple.value;
      }
      
      private function _GWizMachProfile_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.toolTip = "Minimum rpm the spindle is capable of.";
         _loc1_.min = 0;
         _loc1_.steps = 10;
         _loc1_.stepWidth = 70;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__machMinRPMSimple_change);
         _loc1_.id = "machMinRPMSimple";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machMinRPMSimple = _loc1_;
         BindingManager.executeBindings(this,"machMinRPMSimple",this.machMinRPMSimple);
         return _loc1_;
      }
      
      public function __machMinRPMSimple_change(param1:Event) : void
      {
         this.machMinRPM.value = this.machMinRPMSimple.value;
      }
      
      private function _GWizMachProfile_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 0.01;
         _loc1_.stepWidth = 70;
         _loc1_.toolTip = "Rated spindle power";
         _loc1_.UnitLabel = "hp";
         _loc1_.addEventListener("change",this.__machHPSimple_change);
         _loc1_.id = "machHPSimple";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machHPSimple = _loc1_;
         BindingManager.executeBindings(this,"machHPSimple",this.machHPSimple);
         return _loc1_;
      }
      
      public function __machHPSimple_change(param1:Event) : void
      {
         this.machHP.value = this.machHPSimple.value;
      }
      
      private function _GWizMachProfile_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 1;
         _loc1_.stepWidth = 65;
         _loc1_.UnitLabel = "ipm";
         _loc1_.toolTip = "Machine\'s maximum accurate cutting feedrate. When in doubt, just use the rapids speed here too.";
         _loc1_.addEventListener("change",this.__machFeedSimple_change);
         _loc1_.id = "machFeedSimple";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machFeedSimple = _loc1_;
         BindingManager.executeBindings(this,"machFeedSimple",this.machFeedSimple);
         return _loc1_;
      }
      
      public function __machFeedSimple_change(param1:Event) : void
      {
         this.machFeed.value = this.machFeedSimple.value;
      }
      
      private function _GWizMachProfile_GWizForePanel5_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Finish";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachProfile_Array17_c);
         _loc1_.id = "_GWizMachProfile_GWizForePanel5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_GWizForePanel5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_GWizForePanel5",this._GWizMachProfile_GWizForePanel5);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Array17_c() : Array
      {
         return [this._GWizMachProfile_HGroup4_c()];
      }
      
      private function _GWizMachProfile_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 67;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_VGroup8_c(),this._GWizMachProfile_VGroup9_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_VGroup8_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_Label10_i(),this._GWizMachProfile_Label11_i(),this._GWizMachProfile_Spacer2_i(),this._GWizMachProfile_Label12_i(),this._GWizMachProfile_Label13_i(),this._GWizMachProfile_Spacer3_i(),this._GWizMachProfile_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "The questions above are all that\'s needed for a basic machine profile.  The next step is to decide";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label10";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label10 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label10",this._GWizMachProfile_Label10);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "how aggressively you want to use your CNC Machine.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label11";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label11 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label11",this._GWizMachProfile_Label11);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer2_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizMachProfile_Spacer2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Spacer2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Spacer2",this._GWizMachProfile_Spacer2);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label12_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Safe Mode extra conservative for Beginners and smaller CNC machines. Use Normal Mode";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label12";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label12 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label12",this._GWizMachProfile_Label12);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label13_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "for everything else. Experts can often ignore Safe Mode even on small machines.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizMachProfile_Label13";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label13 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label13",this._GWizMachProfile_Label13);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer3_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.id = "_GWizMachProfile_Spacer3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Spacer3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Spacer3",this._GWizMachProfile_Spacer3);
         return _loc1_;
      }
      
      private function _GWizMachProfile_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Keep machine in My Shop.";
         _loc1_.selected = true;
         _loc1_.id = "keepMyShop";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.keepMyShop = _loc1_;
         BindingManager.executeBindings(this,"keepMyShop",this.keepMyShop);
         return _loc1_;
      }
      
      private function _GWizMachProfile_VGroup9_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 33;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "right";
         _loc1_.mxmlContent = [this._GWizMachProfile_CheckBox2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Safe Mode";
         _loc1_.toolTip = "Safe Mode extra conservative for Beginners and smaller CNC machines.";
         _loc1_.addEventListener("change",this.__SafeMode_change);
         _loc1_.id = "SafeMode";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SafeMode = _loc1_;
         BindingManager.executeBindings(this,"SafeMode",this.SafeMode);
         return _loc1_;
      }
      
      public function __SafeMode_change(param1:Event) : void
      {
         this.SafeModeAdv.selected = this.SafeMode.selected;
      }
      
      private function _GWizMachProfile_Array21_c() : Array
      {
         return [this._GWizMachProfile_HGroup5_i()];
      }
      
      private function _GWizMachProfile_HGroup5_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.gap = 1;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_GWizForePanel6_c(),this._GWizMachProfile_GWizForePanel7_c(),this._GWizMachProfile_GWizForePanel8_i()];
         _loc1_.id = "Lockable";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Lockable = _loc1_;
         BindingManager.executeBindings(this,"Lockable",this.Lockable);
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizForePanel6_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachProfile_Array23_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Array23_c() : Array
      {
         return [this._GWizMachProfile_VGroup10_c()];
      }
      
      private function _GWizMachProfile_VGroup10_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_GWizMachNameGrp1_i(),this._GWizMachProfile_Line1_c(),this._GWizMachProfile_HGroup6_i(),this._GWizMachProfile_HGroup7_i(),this._GWizMachProfile_HGroup8_i(),this._GWizMachProfile_HGroup9_i(),this._GWizMachProfile_HGroup10_i(),this._GWizMachProfile_HGroup11_i(),this._GWizMachProfile_CheckBox3_i(),this._GWizMachProfile_CheckBox4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizMachNameGrp1_i() : GWizMachNameGrp
      {
         var _loc1_:GWizMachNameGrp = new GWizMachNameGrp();
         _loc1_.id = "machNameGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machNameGrp = _loc1_;
         BindingManager.executeBindings(this,"machNameGrp",this.machNameGrp);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Line1_c() : Line
      {
         var _loc1_:Line = new Line();
         _loc1_.percentWidth = 100;
         _loc1_.stroke = this._GWizMachProfile_SolidColorStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizMachProfile_SolidColorStroke1_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 8947848;
         _loc1_.weight = 1;
         _loc1_.caps = "square";
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup6_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label14_c(),this._GWizMachProfile_Spacer4_c(),this._GWizMachProfile_DropDownList1_i(),this._GWizMachProfile_Label15_i(),this._GWizMachProfile_DropDownList2_i()];
         _loc1_.id = "_GWizMachProfile_HGroup6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_HGroup6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_HGroup6",this._GWizMachProfile_HGroup6);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label14_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Spindle Type";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.selectedIndex = 6;
         _loc1_.width = 70;
         _loc1_.addEventListener("valueCommit",this.__taperType_valueCommit);
         _loc1_.id = "taperType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.taperType = _loc1_;
         BindingManager.executeBindings(this,"taperType",this.taperType);
         return _loc1_;
      }
      
      public function __taperType_valueCommit(param1:FlexEvent) : void
      {
         this.onTaperType();
      }
      
      private function _GWizMachProfile_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Size";
         _loc1_.id = "stSizeLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stSizeLabel = _loc1_;
         BindingManager.executeBindings(this,"stSizeLabel",this.stSizeLabel);
         return _loc1_;
      }
      
      private function _GWizMachProfile_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 70;
         _loc1_.id = "taperSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.taperSize = _loc1_;
         BindingManager.executeBindings(this,"taperSize",this.taperSize);
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup7_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label16_c(),this._GWizMachProfile_Spacer5_c(),this._GWizMachProfile_GWizNumStep5_i(),this._GWizMachProfile_GWizNumStep6_i()];
         _loc1_.id = "spindleRPMGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.spindleRPMGrp = _loc1_;
         BindingManager.executeBindings(this,"spindleRPMGrp",this.spindleRPMGrp);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label16_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Spindle RPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer5_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Max";
         _loc1_.toolTip = "Maximum rpm the spindle is capable of.";
         _loc1_.fatSpacer = false;
         _loc1_.min = 0;
         _loc1_.steps = 10;
         _loc1_.stepWidth = 70;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__machRPM_valueCommit);
         _loc1_.id = "machRPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machRPM = _loc1_;
         BindingManager.executeBindings(this,"machRPM",this.machRPM);
         return _loc1_;
      }
      
      public function __machRPM_valueCommit(param1:FlexEvent) : void
      {
         this.machRPMSimple.value = this.machRPM.value;
      }
      
      private function _GWizMachProfile_GWizNumStep6_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Min";
         _loc1_.toolTip = "Minimum rpm the spindle is capable of.";
         _loc1_.fatSpacer = false;
         _loc1_.min = 0;
         _loc1_.steps = 10;
         _loc1_.stepWidth = 70;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__machMinRPM_valueCommit);
         _loc1_.id = "machMinRPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machMinRPM = _loc1_;
         BindingManager.executeBindings(this,"machMinRPM",this.machMinRPM);
         return _loc1_;
      }
      
      public function __machMinRPM_valueCommit(param1:FlexEvent) : void
      {
         this.machMinRPMSimple.value = this.machMinRPM.value;
      }
      
      private function _GWizMachProfile_HGroup8_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label17_i(),this._GWizMachProfile_Spacer6_c(),this._GWizMachProfile_GWizNumStep7_i(),this._GWizMachProfile_Label18_i(),this._GWizMachProfile_Button3_c()];
         _loc1_.id = "_GWizMachProfile_HGroup8";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_HGroup8 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_HGroup8",this._GWizMachProfile_HGroup8);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label17_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Spindle Power";
         _loc1_.id = "hpLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.hpLabel = _loc1_;
         BindingManager.executeBindings(this,"hpLabel",this.hpLabel);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer6_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep7_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 0.01;
         _loc1_.fatSpacer = false;
         _loc1_.stepWidth = 70;
         _loc1_.toolTip = "Rated spindle power";
         _loc1_.titleTxt = "Max";
         _loc1_.UnitLabel = "hp";
         _loc1_.addEventListener("valueCommit",this.__machHP_valueCommit);
         _loc1_.id = "machHP";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machHP = _loc1_;
         BindingManager.executeBindings(this,"machHP",this.machHP);
         return _loc1_;
      }
      
      public function __machHP_valueCommit(param1:FlexEvent) : void
      {
         this.machHPSimple.value = this.machHP.value;
      }
      
      private function _GWizMachProfile_Label18_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.id = "_GWizMachProfile_Label18";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_Label18 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_Label18",this._GWizMachProfile_Label18);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Button3_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Adjust";
         _loc1_.toolTip = "Setup spindle power adjustment options such as weight adjusted or power curve adjusted.";
         _loc1_.width = 70;
         _loc1_.addEventListener("click",this.___GWizMachProfile_Button3_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizMachProfile_Button3_click(param1:MouseEvent) : void
      {
         this.doCurve();
      }
      
      private function _GWizMachProfile_HGroup9_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Spacer7_c(),this._GWizMachProfile_Label19_i()];
         _loc1_.id = "_GWizMachProfile_HGroup9";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_HGroup9 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_HGroup9",this._GWizMachProfile_HGroup9);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer7_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label19_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "AdjustType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AdjustType = _loc1_;
         BindingManager.executeBindings(this,"AdjustType",this.AdjustType);
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup10_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label20_c(),this._GWizMachProfile_Spacer8_c(),this._GWizMachProfile_NumericStepper1_i(),this._GWizMachProfile_Label21_c()];
         _loc1_.id = "_GWizMachProfile_HGroup10";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_HGroup10 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_HGroup10",this._GWizMachProfile_HGroup10);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label20_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Spindle 0-max rpm time";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer8_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.maximum = 100;
         _loc1_.minimum = 0;
         _loc1_.stepSize = 0.1;
         _loc1_.value = 2;
         _loc1_.width = 70;
         _loc1_.id = "spindleTime";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.spindleTime = _loc1_;
         BindingManager.executeBindings(this,"spindleTime",this.spindleTime);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label21_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "secs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup11_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label22_c(),this._GWizMachProfile_Spacer9_c(),this._GWizMachProfile_NumericStepper2_i(),this._GWizMachProfile_Label23_c()];
         _loc1_.id = "_GWizMachProfile_HGroup11";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_HGroup11 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_HGroup11",this._GWizMachProfile_HGroup11);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label22_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Spindle Adjustment";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer9_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.value = 100;
         _loc1_.minimum = 10;
         _loc1_.maximum = 200;
         _loc1_.stepSize = 1;
         _loc1_.width = 70;
         _loc1_.toolTip = "Scale spindle speeds for Feeds/Speeds by this much.";
         _loc1_.addEventListener("valueCommit",this.__machSFMAdjust_valueCommit);
         _loc1_.id = "machSFMAdjust";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machSFMAdjust = _loc1_;
         BindingManager.executeBindings(this,"machSFMAdjust",this.machSFMAdjust);
         return _loc1_;
      }
      
      public function __machSFMAdjust_valueCommit(param1:FlexEvent) : void
      {
         this.recalcToolLife(param1);
      }
      
      private function _GWizMachProfile_Label23_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "%";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_CheckBox3_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Safe Mode";
         _loc1_.toolTip = "Safe Mode extra conservative for Beginners and smaller CNC machines.";
         _loc1_.addEventListener("valueCommit",this.__SafeModeAdv_valueCommit);
         _loc1_.id = "SafeModeAdv";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SafeModeAdv = _loc1_;
         BindingManager.executeBindings(this,"SafeModeAdv",this.SafeModeAdv);
         return _loc1_;
      }
      
      public function __SafeModeAdv_valueCommit(param1:FlexEvent) : void
      {
         this.SafeMode.selected = this.SafeModeAdv.selected;
      }
      
      private function _GWizMachProfile_CheckBox4_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Ignore \'S\' and M03/04 g-codes for spindle";
         _loc1_.toolTip = "Use this if you adjust your spindle speed manually.";
         _loc1_.addEventListener("valueCommit",this.__ignoreSpindleSpeedGCodes_valueCommit);
         _loc1_.id = "ignoreSpindleSpeedGCodes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ignoreSpindleSpeedGCodes = _loc1_;
         BindingManager.executeBindings(this,"ignoreSpindleSpeedGCodes",this.ignoreSpindleSpeedGCodes);
         return _loc1_;
      }
      
      public function __ignoreSpindleSpeedGCodes_valueCommit(param1:FlexEvent) : void
      {
         GWizSettings.post.spindleCheck = !this.ignoreSpindleSpeedGCodes.selected;
      }
      
      private function _GWizMachProfile_GWizForePanel7_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachProfile_Array31_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Array31_c() : Array
      {
         return [this._GWizMachProfile_VGroup11_c()];
      }
      
      private function _GWizMachProfile_VGroup11_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_HGroup12_c(),this._GWizMachProfile_HGroup13_c(),this._GWizMachProfile_HGroup14_c(),this._GWizMachProfile_VGroup12_c(),this._GWizMachProfile_GWizNumStep13_i(),this._GWizMachProfile_GWizNumStep14_i(),this._GWizMachProfile_GWizNumStep15_i(),this._GWizMachProfile_HGroup16_c(),this._GWizMachProfile_HGroup17_i(),this._GWizMachProfile_HGroup18_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup12_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label24_i(),this._GWizMachProfile_Spacer10_c(),this._GWizMachProfile_GWizNumStep8_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label24_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max Feed";
         _loc1_.id = "feedLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.feedLabel = _loc1_;
         BindingManager.executeBindings(this,"feedLabel",this.feedLabel);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer10_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep8_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 1;
         _loc1_.stepWidth = 65;
         _loc1_.UnitLabel = "ipm";
         _loc1_.toolTip = "Machine\'s maximum accurate cutting feedrate. When in doubt, just use the rapids speed here too.";
         _loc1_.addEventListener("valueCommit",this.__machFeed_valueCommit);
         _loc1_.id = "machFeed";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machFeed = _loc1_;
         BindingManager.executeBindings(this,"machFeed",this.machFeed);
         return _loc1_;
      }
      
      public function __machFeed_valueCommit(param1:FlexEvent) : void
      {
         this.machFeedSimple.value = this.machFeed.value;
      }
      
      private function _GWizMachProfile_HGroup13_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label25_c(),this._GWizMachProfile_Spacer11_c(),this._GWizMachProfile_CheckBox5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label25_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Feedrates per second";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer11_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_CheckBox5_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.selected = false;
         _loc1_.toolTip = "Feedrates are units/second not units/minute in Feeds/Speeds Calculator.";
         _loc1_.id = "machFeedSecMode";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machFeedSecMode = _loc1_;
         BindingManager.executeBindings(this,"machFeedSecMode",this.machFeedSecMode);
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup14_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label26_i(),this._GWizMachProfile_Spacer12_c(),this._GWizMachProfile_GWizNumStep9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label26_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max Rapids";
         _loc1_.id = "rapidsLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rapidsLabel = _loc1_;
         BindingManager.executeBindings(this,"rapidsLabel",this.rapidsLabel);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer12_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep9_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.steps = 1;
         _loc1_.stepWidth = 65;
         _loc1_.UnitLabel = "ipm";
         _loc1_.toolTip = "Maximum rate the machine can move its table or tools.";
         _loc1_.id = "machRapids";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machRapids = _loc1_;
         BindingManager.executeBindings(this,"machRapids",this.machRapids);
         return _loc1_;
      }
      
      private function _GWizMachProfile_VGroup12_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "right";
         _loc1_.mxmlContent = [this._GWizMachProfile_HGroup15_c(),this._GWizMachProfile_GWizNumStep11_i(),this._GWizMachProfile_GWizNumStep12_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup15_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label27_i(),this._GWizMachProfile_Spacer13_c(),this._GWizMachProfile_GWizNumStep10_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label27_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Travels";
         _loc1_.id = "TravelsLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TravelsLabel = _loc1_;
         BindingManager.executeBindings(this,"TravelsLabel",this.TravelsLabel);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer13_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep10_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "X";
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 0.01;
         _loc1_.stepWidth = 65;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("textAlign","left");
         _loc1_.id = "xTravel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xTravel = _loc1_;
         BindingManager.executeBindings(this,"xTravel",this.xTravel);
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep11_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Y";
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 0.01;
         _loc1_.stepWidth = 65;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("textAlign","left");
         _loc1_.id = "yTravel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.yTravel = _loc1_;
         BindingManager.executeBindings(this,"yTravel",this.yTravel);
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep12_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = null;
         _loc1_ = new GWizNumStep();
         _loc1_.titleTxt = "Z";
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 0.01;
         _loc1_.stepWidth = 65;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("textAlign","left");
         _loc1_.id = "zTravel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.zTravel = _loc1_;
         BindingManager.executeBindings(this,"zTravel",this.zTravel);
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep13_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = null;
         _loc1_ = new GWizNumStep();
         _loc1_.titleTxt = "Acceleration (g)";
         _loc1_.min = 0;
         _loc1_.max = 20;
         _loc1_.steps = 0.01;
         _loc1_.width = 65;
         _loc1_.usesMetric = false;
         _loc1_.toolTip = "Maximum acceleration in G\'s of your machine\'s axes for accurate motion";
         _loc1_.id = "machAccel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machAccel = _loc1_;
         BindingManager.executeBindings(this,"machAccel",this.machAccel);
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep14_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = null;
         _loc1_ = new GWizNumStep();
         _loc1_.titleTxt = "Machine Weight";
         _loc1_.min = 0;
         _loc1_.max = 50000;
         _loc1_.steps = 1;
         _loc1_.stepWidth = 65;
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Machine weight in lbs or kgs";
         _loc1_.UnitLabel = "lb";
         _loc1_.id = "machWeight";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machWeight = _loc1_;
         BindingManager.executeBindings(this,"machWeight",this.machWeight);
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizNumStep15_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = null;
         _loc1_ = new GWizNumStep();
         _loc1_.titleTxt = "Hourly Rate";
         _loc1_.min = 0;
         _loc1_.max = 100000;
         _loc1_.steps = 0.01;
         _loc1_.stepWidth = 65;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__HourlyRate_initialize);
         _loc1_.id = "HourlyRate";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HourlyRate = _loc1_;
         BindingManager.executeBindings(this,"HourlyRate",this.HourlyRate);
         return _loc1_;
      }
      
      public function __HourlyRate_initialize(param1:FlexEvent) : void
      {
         this.HourlyRate.setVal(60);
      }
      
      private function _GWizMachProfile_HGroup16_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "right";
         _loc1_.mxmlContent = [this._GWizMachProfile_Button4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Button4_c() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Calculate";
         _loc1_.width = 65;
         _loc1_.addEventListener("click",this.___GWizMachProfile_Button4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizMachProfile_Button4_click(param1:MouseEvent) : void
      {
         this.doHourlyCalc(_showHourlyCost);
      }
      
      private function _GWizMachProfile_HGroup17_i() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_Label28_c(),this._GWizMachProfile_Spacer14_c(),this._GWizMachProfile_NumericStepper3_i()];
         _loc1_.id = "_GWizMachProfile_HGroup17";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_HGroup17 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_HGroup17",this._GWizMachProfile_HGroup17);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label28_c() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "Sim Time Adj (%)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer14_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_NumericStepper3_i() : NumericStepper
      {
         var _loc1_:NumericStepper = null;
         _loc1_ = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 500;
         _loc1_.stepSize = 1;
         _loc1_.width = 65;
         _loc1_.addEventListener("initialize",this.__simTimeAdj_initialize);
         _loc1_.id = "simTimeAdj";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.simTimeAdj = _loc1_;
         BindingManager.executeBindings(this,"simTimeAdj",this.simTimeAdj);
         return _loc1_;
      }
      
      public function __simTimeAdj_initialize(param1:FlexEvent) : void
      {
         this.simTimeAdj.value = 100;
      }
      
      private function _GWizMachProfile_HGroup18_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_Button5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Button5_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "4th Axis...";
         _loc1_.toolTip = "Setup 4th axis.";
         _loc1_.addEventListener("click",this.__axisOptions_click);
         _loc1_.id = "axisOptions";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.axisOptions = _loc1_;
         BindingManager.executeBindings(this,"axisOptions",this.axisOptions);
         return _loc1_;
      }
      
      public function __axisOptions_click(param1:MouseEvent) : void
      {
         this.doAxisOptions();
      }
      
      private function _GWizMachProfile_GWizForePanel8_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = null;
         _loc1_ = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachProfile_Array41_c);
         _loc1_.id = "timeParms";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.timeParms = _loc1_;
         BindingManager.executeBindings(this,"timeParms",this.timeParms);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Array41_c() : Array
      {
         var _loc1_:Array = null;
         return [this._GWizMachProfile_VGroup13_c()];
      }
      
      private function _GWizMachProfile_VGroup13_c() : VGroup
      {
         var _loc1_:VGroup = null;
         _loc1_ = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_HGroup19_c(),this._GWizMachProfile_HGroup20_c(),this._GWizMachProfile_CheckBox6_i(),this._GWizMachProfile_HGroup21_c(),this._GWizMachProfile_HGroup22_c(),this._GWizMachProfile_HGroup23_i(),this._GWizMachProfile_HGroup24_c(),this._GWizMachProfile_Line2_c(),this._GWizMachProfile_HGroup25_i(),this._GWizMachProfile_HGroup26_i(),this._GWizMachProfile_HGroup27_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup19_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label29_c(),this._GWizMachProfile_Spacer15_c(),this._GWizMachProfile_NumericStepper4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label29_c() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "Tool Changer Slots";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer15_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_NumericStepper4_i() : NumericStepper
      {
         var _loc1_:NumericStepper = null;
         _loc1_ = new NumericStepper();
         _loc1_.value = 0;
         _loc1_.minimum = 0;
         _loc1_.maximum = 1000;
         _loc1_.stepSize = 1;
         _loc1_.toolTip = "Number of slots in this machine\'s toolchanger.";
         _loc1_.width = 60;
         _loc1_.id = "machSlots";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machSlots = _loc1_;
         BindingManager.executeBindings(this,"machSlots",this.machSlots);
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup20_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label30_c(),this._GWizMachProfile_Spacer16_c(),this._GWizMachProfile_NumericStepper5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label30_c() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "Tool Change Time (secs)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer16_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_NumericStepper5_i() : NumericStepper
      {
         var _loc1_:NumericStepper = null;
         _loc1_ = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 300;
         _loc1_.stepSize = 0.1;
         _loc1_.width = 60;
         _loc1_.value = 3;
         _loc1_.toolTip = "Chip to chip toolchange time for this machine.";
         _loc1_.id = "tcTime";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tcTime = _loc1_;
         BindingManager.executeBindings(this,"tcTime",this.tcTime);
         return _loc1_;
      }
      
      private function _GWizMachProfile_CheckBox6_i() : CheckBox
      {
         var _loc1_:CheckBox = null;
         _loc1_ = new CheckBox();
         _loc1_.label = "Ignore \'T\' and M06 tool change g-codes";
         _loc1_.addEventListener("valueCommit",this.__ignoreToolchangeGCodes_valueCommit);
         _loc1_.id = "ignoreToolchangeGCodes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ignoreToolchangeGCodes = _loc1_;
         BindingManager.executeBindings(this,"ignoreToolchangeGCodes",this.ignoreToolchangeGCodes);
         return _loc1_;
      }
      
      public function __ignoreToolchangeGCodes_valueCommit(param1:FlexEvent) : void
      {
         GWizSettings.post.toolCheck = !this.ignoreToolchangeGCodes.selected;
      }
      
      private function _GWizMachProfile_HGroup21_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_Label31_i(),this._GWizMachProfile_Spacer17_c(),this._GWizMachProfile_VGroup14_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label31_i() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "Tool life vs 100% SFM:";
         _loc1_.id = "toolLife";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolLife = _loc1_;
         BindingManager.executeBindings(this,"toolLife",this.toolLife);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer17_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_VGroup14_c() : VGroup
      {
         var _loc1_:VGroup = null;
         _loc1_ = new VGroup();
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizMachProfile_Label32_i(),this._GWizMachProfile_DropDownList3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label32_i() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "";
         _loc1_.id = "toolLifeMsg";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolLifeMsg = _loc1_;
         BindingManager.executeBindings(this,"toolLifeMsg",this.toolLifeMsg);
         return _loc1_;
      }
      
      private function _GWizMachProfile_DropDownList3_i() : DropDownList
      {
         var _loc1_:DropDownList = null;
         _loc1_ = new DropDownList();
         _loc1_.addEventListener("valueCommit",this.__toolType_valueCommit);
         _loc1_.id = "toolType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolType = _loc1_;
         BindingManager.executeBindings(this,"toolType",this.toolType);
         return _loc1_;
      }
      
      public function __toolType_valueCommit(param1:FlexEvent) : void
      {
         this.recalcToolLife(param1);
      }
      
      private function _GWizMachProfile_HGroup22_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label33_c(),this._GWizMachProfile_Spacer18_c(),this._GWizMachProfile_NumericStepper6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label33_c() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "Chipload Adjustment (%)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer18_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_NumericStepper6_i() : NumericStepper
      {
         var _loc1_:NumericStepper = null;
         _loc1_ = new NumericStepper();
         _loc1_.value = 100;
         _loc1_.minimum = 10;
         _loc1_.maximum = 200;
         _loc1_.stepSize = 1;
         _loc1_.width = 60;
         _loc1_.id = "machChiploadAdjust";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machChiploadAdjust = _loc1_;
         BindingManager.executeBindings(this,"machChiploadAdjust",this.machChiploadAdjust);
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup23_i() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label34_c(),this._GWizMachProfile_Spacer19_c(),this._GWizMachProfile_NumericStepper7_i()];
         _loc1_.id = "_GWizMachProfile_HGroup23";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_HGroup23 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_HGroup23",this._GWizMachProfile_HGroup23);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label34_c() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "Coolant on/off time (secs)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer19_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_NumericStepper7_i() : NumericStepper
      {
         var _loc1_:NumericStepper = null;
         _loc1_ = new NumericStepper();
         _loc1_.width = 60;
         _loc1_.maximum = 100;
         _loc1_.minimum = 0;
         _loc1_.stepSize = 0.1;
         _loc1_.value = 1.5;
         _loc1_.id = "coolTime";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.coolTime = _loc1_;
         BindingManager.executeBindings(this,"coolTime",this.coolTime);
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup24_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label35_c(),this._GWizMachProfile_Spacer20_c(),this._GWizMachProfile_CheckBox7_i(),this._GWizMachProfile_CheckBox8_i(),this._GWizMachProfile_CheckBox9_i(),this._GWizMachProfile_CheckBox10_i(),this._GWizMachProfile_CheckBox11_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label35_c() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "Coolant  ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer20_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_CheckBox7_i() : CheckBox
      {
         var _loc1_:CheckBox = null;
         _loc1_ = new CheckBox();
         _loc1_.label = "TSC";
         _loc1_.selected = false;
         _loc1_.toolTip = "Machine has through spindle coolant";
         _loc1_.id = "machTSC";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machTSC = _loc1_;
         BindingManager.executeBindings(this,"machTSC",this.machTSC);
         return _loc1_;
      }
      
      private function _GWizMachProfile_CheckBox8_i() : CheckBox
      {
         var _loc1_:CheckBox = null;
         _loc1_ = new CheckBox();
         _loc1_.label = "HP";
         _loc1_.selected = false;
         _loc1_.toolTip = "Machine has high pressure (1000 psi) through spindle coolant";
         _loc1_.id = "machHPC";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machHPC = _loc1_;
         BindingManager.executeBindings(this,"machHPC",this.machHPC);
         return _loc1_;
      }
      
      private function _GWizMachProfile_CheckBox9_i() : CheckBox
      {
         var _loc1_:CheckBox = null;
         _loc1_ = new CheckBox();
         _loc1_.label = "PCN";
         _loc1_.selected = false;
         _loc1_.toolTip = "Machine has programmable coolant nozzle";
         _loc1_.id = "machPCN";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machPCN = _loc1_;
         BindingManager.executeBindings(this,"machPCN",this.machPCN);
         return _loc1_;
      }
      
      private function _GWizMachProfile_CheckBox10_i() : CheckBox
      {
         var _loc1_:CheckBox = null;
         _loc1_ = new CheckBox();
         _loc1_.label = "Flood";
         _loc1_.selected = true;
         _loc1_.toolTip = "Machine has flood coolant";
         _loc1_.id = "machFlood";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machFlood = _loc1_;
         BindingManager.executeBindings(this,"machFlood",this.machFlood);
         return _loc1_;
      }
      
      private function _GWizMachProfile_CheckBox11_i() : CheckBox
      {
         var _loc1_:CheckBox = null;
         _loc1_ = new CheckBox();
         _loc1_.label = "Mist";
         _loc1_.selected = true;
         _loc1_.toolTip = "Machine has mist coolant";
         _loc1_.id = "machMist";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machMist = _loc1_;
         BindingManager.executeBindings(this,"machMist",this.machMist);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Line2_c() : Line
      {
         var _loc1_:Line = null;
         _loc1_ = new Line();
         _loc1_.percentWidth = 100;
         _loc1_.stroke = this._GWizMachProfile_SolidColorStroke2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizMachProfile_SolidColorStroke2_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = null;
         _loc1_ = new SolidColorStroke();
         _loc1_.color = 8947848;
         _loc1_.weight = 1;
         _loc1_.caps = "square";
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup25_i() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label36_c(),this._GWizMachProfile_Spacer21_c(),this._GWizMachProfile_NumericStepper8_i()];
         _loc1_.id = "_GWizMachProfile_HGroup25";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_HGroup25 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_HGroup25",this._GWizMachProfile_HGroup25);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label36_c() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "Min. word time (millisecs)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer21_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_NumericStepper8_i() : NumericStepper
      {
         var _loc1_:NumericStepper = null;
         _loc1_ = new NumericStepper();
         _loc1_.width = 60;
         _loc1_.maximum = 1000;
         _loc1_.minimum = 0;
         _loc1_.stepSize = 1;
         _loc1_.value = 5;
         _loc1_.id = "wordTime";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.wordTime = _loc1_;
         BindingManager.executeBindings(this,"wordTime",this.wordTime);
         return _loc1_;
      }
      
      private function _GWizMachProfile_HGroup26_i() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Label37_c(),this._GWizMachProfile_TextInput4_i(),this._GWizMachProfile_GWizBubbleTip2_i()];
         _loc1_.id = "Post1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Post1 = _loc1_;
         BindingManager.executeBindings(this,"Post1",this.Post1);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label37_c() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "CNC Control (Post)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_TextInput4_i() : TextInput
      {
         var _loc1_:TextInput = null;
         _loc1_ = new TextInput();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.id = "Controller";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Controller = _loc1_;
         BindingManager.executeBindings(this,"Controller",this.Controller);
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizBubbleTip2_i() : GWizBubbleTip
      {
         var _loc1_:GWizBubbleTip = null;
         _loc1_ = new GWizBubbleTip();
         _loc1_.bubbleID = "PostBrowse";
         _loc1_.mxmlContent = [this._GWizMachProfile_Button6_i()];
         _loc1_.id = "_GWizMachProfile_GWizBubbleTip2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_GWizBubbleTip2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_GWizBubbleTip2",this._GWizMachProfile_GWizBubbleTip2);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Button6_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.width = 78;
         _loc1_.label = "Browse";
         _loc1_.addEventListener("click",this.__browseBtn_click);
         _loc1_.id = "browseBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.browseBtn = _loc1_;
         BindingManager.executeBindings(this,"browseBtn",this.browseBtn);
         return _loc1_;
      }
      
      public function __browseBtn_click(param1:MouseEvent) : void
      {
         this.doController(param1);
      }
      
      private function _GWizMachProfile_HGroup27_i() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachProfile_Spacer22_c(),this._GWizMachProfile_Button7_i(),this._GWizMachProfile_Button8_i()];
         _loc1_.id = "_GWizMachProfile_HGroup27";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_HGroup27 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_HGroup27",this._GWizMachProfile_HGroup27);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer22_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Button7_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Download Latest Posts";
         _loc1_.addEventListener("click",this.__downloadControllers_click);
         _loc1_.id = "downloadControllers";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.downloadControllers = _loc1_;
         BindingManager.executeBindings(this,"downloadControllers",this.downloadControllers);
         return _loc1_;
      }
      
      public function __downloadControllers_click(param1:MouseEvent) : void
      {
         doDownload();
      }
      
      private function _GWizMachProfile_Button8_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Rename...";
         _loc1_.toolTip = "Rename your post so it won\'t be overwritten when latest versions are downloaded.";
         _loc1_.addEventListener("click",this.__postRename_click);
         _loc1_.id = "postRename";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.postRename = _loc1_;
         BindingManager.executeBindings(this,"postRename",this.postRename);
         return _loc1_;
      }
      
      public function __postRename_click(param1:MouseEvent) : void
      {
         this.doRename();
      }
      
      private function _GWizMachProfile_GWizForePanel9_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = null;
         _loc1_ = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachProfile_Array54_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Array54_c() : Array
      {
         var _loc1_:Array = null;
         return [this._GWizMachProfile_HGroup28_c()];
      }
      
      private function _GWizMachProfile_HGroup28_c() : HGroup
      {
         var _loc1_:HGroup = null;
         _loc1_ = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachProfile_Spacer23_c(),this._GWizMachProfile_Label38_c(),this._GWizMachProfile_GWizBubbleTip3_i(),this._GWizMachProfile_Button10_i(),this._GWizMachProfile_Spacer24_c(),this._GWizMachProfile_Button11_c(),this._GWizMachProfile_Button12_i(),this._GWizMachProfile_Spacer25_c(),this._GWizMachProfile_Button13_i(),this._GWizMachProfile_Spacer26_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Spacer23_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Label38_c() : Label
      {
         var _loc1_:Label = null;
         _loc1_ = new Label();
         _loc1_.text = "Machine Profile:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_GWizBubbleTip3_i() : GWizBubbleTip
      {
         var _loc1_:GWizBubbleTip = null;
         _loc1_ = new GWizBubbleTip();
         _loc1_.bubbleID = "SaveMachProfile";
         _loc1_.mxmlContent = [this._GWizMachProfile_Button9_i()];
         _loc1_.id = "_GWizMachProfile_GWizBubbleTip3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMachProfile_GWizBubbleTip3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMachProfile_GWizBubbleTip3",this._GWizMachProfile_GWizBubbleTip3);
         return _loc1_;
      }
      
      private function _GWizMachProfile_Button9_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Save";
         _loc1_.addEventListener("click",this.__saveBtn_click);
         _loc1_.id = "saveBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.saveBtn = _loc1_;
         BindingManager.executeBindings(this,"saveBtn",this.saveBtn);
         return _loc1_;
      }
      
      public function __saveBtn_click(param1:MouseEvent) : void
      {
         this.UpdateMachine();
      }
      
      private function _GWizMachProfile_Button10_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Delete";
         _loc1_.addEventListener("click",this.__delBtn_click);
         _loc1_.id = "delBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.delBtn = _loc1_;
         BindingManager.executeBindings(this,"delBtn",this.delBtn);
         return _loc1_;
      }
      
      public function __delBtn_click(param1:MouseEvent) : void
      {
         this.confirmDelete(param1);
      }
      
      private function _GWizMachProfile_Spacer24_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.width = 20;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Button11_c() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Import";
         _loc1_.toolTip = "Import a CSV File machine profile";
         _loc1_.addEventListener("click",this.___GWizMachProfile_Button11_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizMachProfile_Button11_click(param1:MouseEvent) : void
      {
         this.importMachProfile();
      }
      
      private function _GWizMachProfile_Button12_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Download New";
         _loc1_.toolTip = "Download and add profiles not already listed.";
         _loc1_.addEventListener("click",this.__resetBtn_click);
         _loc1_.id = "resetBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.resetBtn = _loc1_;
         BindingManager.executeBindings(this,"resetBtn",this.resetBtn);
         return _loc1_;
      }
      
      public function __resetBtn_click(param1:MouseEvent) : void
      {
         GWizMachSettings.resetDefaults();
      }
      
      private function _GWizMachProfile_Spacer25_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.width = 20;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachProfile_Button13_i() : Button
      {
         var _loc1_:Button = null;
         _loc1_ = new Button();
         _loc1_.label = "Request Profile";
         _loc1_.toolTip = "Request us to add a new machine profile for you.";
         _loc1_.setStyle("chromeColor",5168750);
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("click",this.__conciergeBtn_click);
         _loc1_.id = "conciergeBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.conciergeBtn = _loc1_;
         BindingManager.executeBindings(this,"conciergeBtn",this.conciergeBtn);
         return _loc1_;
      }
      
      public function __conciergeBtn_click(param1:MouseEvent) : void
      {
         this.requestProfile();
      }
      
      private function _GWizMachProfile_Spacer26_c() : Spacer
      {
         var _loc1_:Spacer = null;
         _loc1_ = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizMachProfile_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizMachProfile_bindingsSetup() : Array
      {
         var result:Array = null;
         result = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.gray3;
         },function(param1:uint):void
         {
            _GWizMachProfile_Label1.setStyle("backgroundColor",param1);
         },"_GWizMachProfile_Label1.backgroundColor");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.gray5;
         },function(param1:uint):void
         {
            _GWizMachProfile_Label1.setStyle("color",param1);
         },"_GWizMachProfile_Label1.color");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            _GWizMachProfile_GWizForePanel1.setStyle("backgroundColor",param1);
         },"_GWizMachProfile_GWizForePanel1.backgroundColor");
         result[3] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"_GWizMachProfile_GWizBubbleTip1.myWindow");
         result[4] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"simpleMachProfileBtn.visible");
         result[5] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"advancedMachProfileBtn.visible");
         result[6] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            SimpleNav.setStyle("backgroundColor",param1);
         },"SimpleNav.backgroundColor");
         result[7] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizMachProfile_GWizForePanel3.labelBackgroundColor");
         result[8] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizMachProfile_GWizForePanel3.labelColor");
         result[9] = new Binding(this,function():Number
         {
            return machName.height;
         },null,"_GWizMachProfile_Label2.height");
         result[10] = new Binding(this,function():Number
         {
            return machType.height;
         },null,"_GWizMachProfile_Label3.height");
         result[11] = new Binding(this,function():Number
         {
            return machName.height;
         },null,"_GWizMachProfile_Label4.height");
         result[12] = new Binding(this,function():Number
         {
            return machName.height;
         },null,"_GWizMachProfile_Label5.height");
         result[13] = new Binding(this,function():Number
         {
            return machName.width;
         },null,"machType.width");
         result[14] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizMachProfile_GWizForePanel4.labelBackgroundColor");
         result[15] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizMachProfile_GWizForePanel4.labelColor");
         result[16] = new Binding(this,function():Number
         {
            return machRPMSimple.height;
         },null,"_GWizMachProfile_Label6.height");
         result[17] = new Binding(this,function():Number
         {
            return machRPMSimple.height;
         },null,"_GWizMachProfile_Label7.height");
         result[18] = new Binding(this,function():Number
         {
            return machRPMSimple.height;
         },null,"_GWizMachProfile_Label8.height");
         result[19] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_RPM;
         },null,"machRPMSimple.max");
         result[20] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_RPM;
         },null,"machMinRPMSimple.max");
         result[21] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.HP_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"machHPSimple.impUnits");
         result[22] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.KW_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"machHPSimple.metUnits");
         result[23] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_FEEDRATE;
         },null,"machFeedSimple.max");
         result[24] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizMachProfile_GWizForePanel5.labelBackgroundColor");
         result[25] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizMachProfile_GWizForePanel5.labelColor");
         result[26] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"_GWizMachProfile_Label10.visible");
         result[27] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"_GWizMachProfile_Label11.visible");
         result[28] = new Binding(this,function():Number
         {
            return SPACER_HT;
         },null,"_GWizMachProfile_Spacer2.height");
         result[29] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"_GWizMachProfile_Label12.visible");
         result[30] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"_GWizMachProfile_Label13.visible");
         result[31] = new Binding(this,function():Number
         {
            return SPACER_HT;
         },null,"_GWizMachProfile_Spacer3.height");
         result[32] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"SafeMode.visible");
         result[33] = new Binding(this,function():uint
         {
            return ColorPalette.gray1;
         },function(param1:uint):void
         {
            AdvancedNav.setStyle("backgroundColor",param1);
         },"AdvancedNav.backgroundColor");
         result[34] = new Binding(this,function():Number
         {
            return spindleRPMGrp.width;
         },null,"machNameGrp.width");
         result[35] = new Binding(this,null,null,"machNameGrp.altMachName","machName");
         result[36] = new Binding(this,null,null,"machNameGrp.altMachType","machType");
         result[37] = new Binding(this,null,null,"machNameGrp.altMake","Make");
         result[38] = new Binding(this,null,null,"machNameGrp.altModel","Model");
         result[39] = new Binding(this,function():Number
         {
            return spindleRPMGrp.width;
         },null,"_GWizMachProfile_HGroup6.width");
         result[40] = new Binding(this,function():IList
         {
            return new ArrayCollection(GWizConfigData.millTapers);
         },null,"taperType.dataProvider");
         result[41] = new Binding(this,function():Boolean
         {
            return taperSize.visible;
         },null,"stSizeLabel.visible");
         result[42] = new Binding(this,function():IList
         {
            return new ArrayCollection(GWizConfigData.millTaperSizes);
         },null,"taperSize.dataProvider");
         result[43] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_RPM;
         },null,"machRPM.max");
         result[44] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_RPM;
         },null,"machMinRPM.max");
         result[45] = new Binding(this,function():Number
         {
            return stSizeLabel.width;
         },null,"machMinRPM.labelWidth");
         result[46] = new Binding(this,function():Number
         {
            return spindleRPMGrp.width;
         },null,"_GWizMachProfile_HGroup8.width");
         result[47] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.HP_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"machHP.impUnits");
         result[48] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.KW_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"machHP.metUnits");
         result[49] = new Binding(this,function():Boolean
         {
            return taperSize.visible;
         },null,"_GWizMachProfile_Label18.visible");
         result[50] = new Binding(this,function():Number
         {
            return stSizeLabel.width;
         },null,"_GWizMachProfile_Label18.width");
         result[51] = new Binding(this,function():Number
         {
            return spindleRPMGrp.width;
         },null,"_GWizMachProfile_HGroup9.width");
         result[52] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizSpindleCurve.adjustMsg;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"AdjustType.text");
         result[53] = new Binding(this,function():Number
         {
            return spindleRPMGrp.width;
         },null,"_GWizMachProfile_HGroup10.width");
         result[54] = new Binding(this,function():Number
         {
            return spindleRPMGrp.width;
         },null,"_GWizMachProfile_HGroup11.width");
         result[55] = new Binding(this,function():Boolean
         {
            return !GWizPostVars.noLoad;
         },null,"ignoreSpindleSpeedGCodes.visible");
         result[56] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_FEEDRATE;
         },null,"machFeed.max");
         result[57] = new Binding(this,function():Number
         {
            return GWizMachSettings.MAX_FEEDRATE;
         },null,"machRapids.max");
         result[58] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.LB_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"machWeight.impUnits");
         result[59] = new Binding(this,function():String
         {
            var _loc1_:* = undefined;
            _loc1_ = GWizUtils.KG_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"machWeight.metUnits");
         result[60] = new Binding(this,function():Boolean
         {
            return !GWizPostVars.noLoad;
         },null,"_GWizMachProfile_HGroup17.visible");
         result[61] = new Binding(this,function():Boolean
         {
            return !GWizPostVars.noLoad;
         },null,"axisOptions.visible");
         result[62] = new Binding(this,function():Boolean
         {
            return !GWizPostVars.noLoad;
         },null,"ignoreToolchangeGCodes.visible");
         result[63] = new Binding(this,function():IList
         {
            return new ArrayCollection(toolMaterial);
         },null,"toolType.dataProvider");
         result[64] = new Binding(this,function():Boolean
         {
            return !GWizPostVars.noLoad;
         },null,"_GWizMachProfile_HGroup23.visible");
         result[65] = new Binding(this,function():Boolean
         {
            return !GWizPostVars.noLoad;
         },null,"_GWizMachProfile_HGroup25.visible");
         result[66] = new Binding(this,function():Boolean
         {
            return !GWizPostVars.noLoad;
         },null,"Post1.visible");
         result[67] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"_GWizMachProfile_GWizBubbleTip2.myWindow");
         result[68] = new Binding(this,function():Boolean
         {
            return !downloading;
         },null,"browseBtn.enabled");
         result[69] = new Binding(this,function():Boolean
         {
            return !GWizPostVars.noLoad;
         },null,"_GWizMachProfile_HGroup27.visible");
         result[70] = new Binding(this,function():Number
         {
            return Controller.width;
         },null,"downloadControllers.width");
         result[71] = new Binding(this,function():Number
         {
            return browseBtn.width;
         },null,"postRename.width");
         result[72] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"_GWizMachProfile_GWizBubbleTip3.myWindow");
         result[73] = new Binding(this,function():Boolean
         {
            return !GWizAbstractPrefs.isOEM;
         },null,"conciergeBtn.visible");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get AdjustType() : Label
      {
         return this._325142647AdjustType;
      }
      
      public function set AdjustType(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._325142647AdjustType;
         if(_loc2_ !== param1)
         {
            this._325142647AdjustType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AdjustType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get AdvancedNav() : NavigatorContent
      {
         return this._1480189313AdvancedNav;
      }
      
      public function set AdvancedNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1480189313AdvancedNav;
         if(_loc2_ !== param1)
         {
            this._1480189313AdvancedNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AdvancedNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Controller() : TextInput
      {
         return this._1664073796Controller;
      }
      
      public function set Controller(param1:TextInput) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1664073796Controller;
         if(_loc2_ !== param1)
         {
            this._1664073796Controller = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Controller",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HourlyRate() : GWizNumStep
      {
         return this._975235311HourlyRate;
      }
      
      public function set HourlyRate(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._975235311HourlyRate;
         if(_loc2_ !== param1)
         {
            this._975235311HourlyRate = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HourlyRate",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Lockable() : HGroup
      {
         return this._1974350117Lockable;
      }
      
      public function set Lockable(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1974350117Lockable;
         if(_loc2_ !== param1)
         {
            this._1974350117Lockable = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Lockable",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Make() : TextInput
      {
         return this._2390542Make;
      }
      
      public function set Make(param1:TextInput) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2390542Make;
         if(_loc2_ !== param1)
         {
            this._2390542Make = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Make",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Model() : TextInput
      {
         return this._74517257Model;
      }
      
      public function set Model(param1:TextInput) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._74517257Model;
         if(_loc2_ !== param1)
         {
            this._74517257Model = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Model",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Post1() : HGroup
      {
         return this._77302641Post1;
      }
      
      public function set Post1(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._77302641Post1;
         if(_loc2_ !== param1)
         {
            this._77302641Post1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Post1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SafeMode() : CheckBox
      {
         return this._1828733680SafeMode;
      }
      
      public function set SafeMode(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1828733680SafeMode;
         if(_loc2_ !== param1)
         {
            this._1828733680SafeMode = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SafeMode",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SafeModeAdv() : CheckBox
      {
         return this._1855023197SafeModeAdv;
      }
      
      public function set SafeModeAdv(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1855023197SafeModeAdv;
         if(_loc2_ !== param1)
         {
            this._1855023197SafeModeAdv = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SafeModeAdv",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SimpleNav() : NavigatorContent
      {
         return this._120428047SimpleNav;
      }
      
      public function set SimpleNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._120428047SimpleNav;
         if(_loc2_ !== param1)
         {
            this._120428047SimpleNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SimpleNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TravelsLabel() : Label
      {
         return this._787319301TravelsLabel;
      }
      
      public function set TravelsLabel(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._787319301TravelsLabel;
         if(_loc2_ !== param1)
         {
            this._787319301TravelsLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TravelsLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Units() : GWizAppearanceGrp
      {
         return this._81880911Units;
      }
      
      public function set Units(param1:GWizAppearanceGrp) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._81880911Units;
         if(_loc2_ !== param1)
         {
            this._81880911Units = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Units",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get advancedMachProfileBtn() : Button
      {
         return this._1380236942advancedMachProfileBtn;
      }
      
      public function set advancedMachProfileBtn(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1380236942advancedMachProfileBtn;
         if(_loc2_ !== param1)
         {
            this._1380236942advancedMachProfileBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"advancedMachProfileBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get axisOptions() : Button
      {
         return this._2146660419axisOptions;
      }
      
      public function set axisOptions(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2146660419axisOptions;
         if(_loc2_ !== param1)
         {
            this._2146660419axisOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"axisOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get browseBtn() : Button
      {
         return this._975152270browseBtn;
      }
      
      public function set browseBtn(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._975152270browseBtn;
         if(_loc2_ !== param1)
         {
            this._975152270browseBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"browseBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get conciergeBtn() : Button
      {
         return this._427139497conciergeBtn;
      }
      
      public function set conciergeBtn(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._427139497conciergeBtn;
         if(_loc2_ !== param1)
         {
            this._427139497conciergeBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"conciergeBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get coolTime() : NumericStepper
      {
         return this._546592330coolTime;
      }
      
      public function set coolTime(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._546592330coolTime;
         if(_loc2_ !== param1)
         {
            this._546592330coolTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"coolTime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get delBtn() : Button
      {
         return this._1335492015delBtn;
      }
      
      public function set delBtn(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1335492015delBtn;
         if(_loc2_ !== param1)
         {
            this._1335492015delBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"delBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get downloadControllers() : Button
      {
         return this._862964399downloadControllers;
      }
      
      public function set downloadControllers(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._862964399downloadControllers;
         if(_loc2_ !== param1)
         {
            this._862964399downloadControllers = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"downloadControllers",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get feedLabel() : Label
      {
         return this._1661895690feedLabel;
      }
      
      public function set feedLabel(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1661895690feedLabel;
         if(_loc2_ !== param1)
         {
            this._1661895690feedLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"feedLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get feedLabelWiz() : Label
      {
         return this._1446392814feedLabelWiz;
      }
      
      public function set feedLabelWiz(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1446392814feedLabelWiz;
         if(_loc2_ !== param1)
         {
            this._1446392814feedLabelWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"feedLabelWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hpLabel() : Label
      {
         return this._1090741964hpLabel;
      }
      
      public function set hpLabel(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1090741964hpLabel;
         if(_loc2_ !== param1)
         {
            this._1090741964hpLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hpLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ignoreSpindleSpeedGCodes() : CheckBox
      {
         return this._1770188739ignoreSpindleSpeedGCodes;
      }
      
      public function set ignoreSpindleSpeedGCodes(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1770188739ignoreSpindleSpeedGCodes;
         if(_loc2_ !== param1)
         {
            this._1770188739ignoreSpindleSpeedGCodes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ignoreSpindleSpeedGCodes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ignoreToolchangeGCodes() : CheckBox
      {
         return this._1165170855ignoreToolchangeGCodes;
      }
      
      public function set ignoreToolchangeGCodes(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1165170855ignoreToolchangeGCodes;
         if(_loc2_ !== param1)
         {
            this._1165170855ignoreToolchangeGCodes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ignoreToolchangeGCodes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get keepMyShop() : CheckBox
      {
         return this._1148733095keepMyShop;
      }
      
      public function set keepMyShop(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1148733095keepMyShop;
         if(_loc2_ !== param1)
         {
            this._1148733095keepMyShop = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"keepMyShop",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machAccel() : GWizNumStep
      {
         return this._1481070737machAccel;
      }
      
      public function set machAccel(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1481070737machAccel;
         if(_loc2_ !== param1)
         {
            this._1481070737machAccel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machAccel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machChiploadAdjust() : NumericStepper
      {
         return this._549384890machChiploadAdjust;
      }
      
      public function set machChiploadAdjust(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._549384890machChiploadAdjust;
         if(_loc2_ !== param1)
         {
            this._549384890machChiploadAdjust = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machChiploadAdjust",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machFeed() : GWizNumStep
      {
         return this._186172873machFeed;
      }
      
      public function set machFeed(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._186172873machFeed;
         if(_loc2_ !== param1)
         {
            this._186172873machFeed = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machFeed",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machFeedSecMode() : CheckBox
      {
         return this._928684893machFeedSecMode;
      }
      
      public function set machFeedSecMode(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._928684893machFeedSecMode;
         if(_loc2_ !== param1)
         {
            this._928684893machFeedSecMode = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machFeedSecMode",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machFeedSimple() : GWizNumStep
      {
         return this._2044226871machFeedSimple;
      }
      
      public function set machFeedSimple(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._2044226871machFeedSimple;
         if(_loc2_ !== param1)
         {
            this._2044226871machFeedSimple = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machFeedSimple",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machFlood() : CheckBox
      {
         return this._1476173179machFlood;
      }
      
      public function set machFlood(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1476173179machFlood;
         if(_loc2_ !== param1)
         {
            this._1476173179machFlood = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machFlood",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machHP() : GWizNumStep
      {
         return this._1081756735machHP;
      }
      
      public function set machHP(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1081756735machHP;
         if(_loc2_ !== param1)
         {
            this._1081756735machHP = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machHP",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machHPC() : CheckBox
      {
         return this._825279650machHPC;
      }
      
      public function set machHPC(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._825279650machHPC;
         if(_loc2_ !== param1)
         {
            this._825279650machHPC = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machHPC",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machHPSimple() : GWizNumStep
      {
         return this._1201455917machHPSimple;
      }
      
      public function set machHPSimple(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1201455917machHPSimple;
         if(_loc2_ !== param1)
         {
            this._1201455917machHPSimple = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machHPSimple",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machMinRPM() : GWizNumStep
      {
         return this._1680846998machMinRPM;
      }
      
      public function set machMinRPM(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1680846998machMinRPM;
         if(_loc2_ !== param1)
         {
            this._1680846998machMinRPM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machMinRPM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machMinRPMSimple() : GWizNumStep
      {
         return this._539985384machMinRPMSimple;
      }
      
      public function set machMinRPMSimple(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._539985384machMinRPMSimple;
         if(_loc2_ !== param1)
         {
            this._539985384machMinRPMSimple = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machMinRPMSimple",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machMist() : CheckBox
      {
         return this._185960042machMist;
      }
      
      public function set machMist(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._185960042machMist;
         if(_loc2_ !== param1)
         {
            this._185960042machMist = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machMist",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machName() : TextInput
      {
         return this._185938140machName;
      }
      
      public function set machName(param1:TextInput) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._185938140machName;
         if(_loc2_ !== param1)
         {
            this._185938140machName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machNameGrp() : GWizMachNameGrp
      {
         return this._1224754977machNameGrp;
      }
      
      public function set machNameGrp(param1:GWizMachNameGrp) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1224754977machNameGrp;
         if(_loc2_ !== param1)
         {
            this._1224754977machNameGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machNameGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machPCN() : CheckBox
      {
         return this._825286946machPCN;
      }
      
      public function set machPCN(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._825286946machPCN;
         if(_loc2_ !== param1)
         {
            this._825286946machPCN = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machPCN",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machRPM() : GWizNumStep
      {
         return this._825289270machRPM;
      }
      
      public function set machRPM(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._825289270machRPM;
         if(_loc2_ !== param1)
         {
            this._825289270machRPM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machRPM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machRPMSimple() : GWizNumStep
      {
         return this._1148778616machRPMSimple;
      }
      
      public function set machRPMSimple(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1148778616machRPMSimple;
         if(_loc2_ !== param1)
         {
            this._1148778616machRPMSimple = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machRPMSimple",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machRapids() : GWizNumStep
      {
         return this._1816686928machRapids;
      }
      
      public function set machRapids(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1816686928machRapids;
         if(_loc2_ !== param1)
         {
            this._1816686928machRapids = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machRapids",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machSFMAdjust() : NumericStepper
      {
         return this._570473392machSFMAdjust;
      }
      
      public function set machSFMAdjust(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._570473392machSFMAdjust;
         if(_loc2_ !== param1)
         {
            this._570473392machSFMAdjust = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machSFMAdjust",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machSlots() : NumericStepper
      {
         return this._1464167236machSlots;
      }
      
      public function set machSlots(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1464167236machSlots;
         if(_loc2_ !== param1)
         {
            this._1464167236machSlots = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machSlots",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machTSC() : CheckBox
      {
         return this._825291275machTSC;
      }
      
      public function set machTSC(param1:CheckBox) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._825291275machTSC;
         if(_loc2_ !== param1)
         {
            this._825291275machTSC = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machTSC",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machType() : GWizMachTypeSelector
      {
         return this._185736237machType;
      }
      
      public function set machType(param1:GWizMachTypeSelector) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._185736237machType;
         if(_loc2_ !== param1)
         {
            this._185736237machType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machWeight() : GWizNumStep
      {
         return this._1963316433machWeight;
      }
      
      public function set machWeight(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1963316433machWeight;
         if(_loc2_ !== param1)
         {
            this._1963316433machWeight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machWeight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get postRename() : Button
      {
         return this._1576518654postRename;
      }
      
      public function set postRename(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1576518654postRename;
         if(_loc2_ !== param1)
         {
            this._1576518654postRename = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"postRename",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rapidsLabel() : Label
      {
         return this._914329027rapidsLabel;
      }
      
      public function set rapidsLabel(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._914329027rapidsLabel;
         if(_loc2_ !== param1)
         {
            this._914329027rapidsLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rapidsLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get resetBtn() : Button
      {
         return this._350375283resetBtn;
      }
      
      public function set resetBtn(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._350375283resetBtn;
         if(_loc2_ !== param1)
         {
            this._350375283resetBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"resetBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get saveBtn() : Button
      {
         return this._1872787359saveBtn;
      }
      
      public function set saveBtn(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1872787359saveBtn;
         if(_loc2_ !== param1)
         {
            this._1872787359saveBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"saveBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get selectedMachine() : GWizMachSelector2
      {
         return this._260429100selectedMachine;
      }
      
      public function set selectedMachine(param1:GWizMachSelector2) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._260429100selectedMachine;
         if(_loc2_ !== param1)
         {
            this._260429100selectedMachine = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"selectedMachine",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get simTimeAdj() : NumericStepper
      {
         return this._589911613simTimeAdj;
      }
      
      public function set simTimeAdj(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._589911613simTimeAdj;
         if(_loc2_ !== param1)
         {
            this._589911613simTimeAdj = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"simTimeAdj",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get simpleMachProfileBtn() : Button
      {
         return this._47346658simpleMachProfileBtn;
      }
      
      public function set simpleMachProfileBtn(param1:Button) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._47346658simpleMachProfileBtn;
         if(_loc2_ !== param1)
         {
            this._47346658simpleMachProfileBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"simpleMachProfileBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get spindleRPMGrp() : HGroup
      {
         return this._1191661135spindleRPMGrp;
      }
      
      public function set spindleRPMGrp(param1:HGroup) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1191661135spindleRPMGrp;
         if(_loc2_ !== param1)
         {
            this._1191661135spindleRPMGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"spindleRPMGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get spindleTime() : NumericStepper
      {
         return this._1650315576spindleTime;
      }
      
      public function set spindleTime(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1650315576spindleTime;
         if(_loc2_ !== param1)
         {
            this._1650315576spindleTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"spindleTime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stSizeLabel() : Label
      {
         return this._670905874stSizeLabel;
      }
      
      public function set stSizeLabel(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._670905874stSizeLabel;
         if(_loc2_ !== param1)
         {
            this._670905874stSizeLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stSizeLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get taperSize() : DropDownList
      {
         return this._1658158001taperSize;
      }
      
      public function set taperSize(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1658158001taperSize;
         if(_loc2_ !== param1)
         {
            this._1658158001taperSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"taperSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get taperType() : DropDownList
      {
         return this._1658202858taperType;
      }
      
      public function set taperType(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1658202858taperType;
         if(_loc2_ !== param1)
         {
            this._1658202858taperType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"taperType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tcTime() : NumericStepper
      {
         return this._879950372tcTime;
      }
      
      public function set tcTime(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._879950372tcTime;
         if(_loc2_ !== param1)
         {
            this._879950372tcTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tcTime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get timeParms() : GWizForePanel
      {
         return this._22253370timeParms;
      }
      
      public function set timeParms(param1:GWizForePanel) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._22253370timeParms;
         if(_loc2_ !== param1)
         {
            this._22253370timeParms = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"timeParms",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolLife() : Label
      {
         return this._983826252toolLife;
      }
      
      public function set toolLife(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._983826252toolLife;
         if(_loc2_ !== param1)
         {
            this._983826252toolLife = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolLife",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolLifeMsg() : Label
      {
         return this._310967763toolLifeMsg;
      }
      
      public function set toolLifeMsg(param1:Label) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._310967763toolLifeMsg;
         if(_loc2_ !== param1)
         {
            this._310967763toolLifeMsg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolLifeMsg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolType() : DropDownList
      {
         return this._983572238toolType;
      }
      
      public function set toolType(param1:DropDownList) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._983572238toolType;
         if(_loc2_ !== param1)
         {
            this._983572238toolType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get views() : ViewStack
      {
         return this._112204398views;
      }
      
      public function set views(param1:ViewStack) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._112204398views;
         if(_loc2_ !== param1)
         {
            this._112204398views = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"views",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get wordTime() : NumericStepper
      {
         return this._28375287wordTime;
      }
      
      public function set wordTime(param1:NumericStepper) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._28375287wordTime;
         if(_loc2_ !== param1)
         {
            this._28375287wordTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"wordTime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xTravel() : GWizNumStep
      {
         return this._1639395762xTravel;
      }
      
      public function set xTravel(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1639395762xTravel;
         if(_loc2_ !== param1)
         {
            this._1639395762xTravel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xTravel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yTravel() : GWizNumStep
      {
         return this._1768067853yTravel;
      }
      
      public function set yTravel(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1768067853yTravel;
         if(_loc2_ !== param1)
         {
            this._1768067853yTravel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yTravel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get zTravel() : GWizNumStep
      {
         return this._880564172zTravel;
      }
      
      public function set zTravel(param1:GWizNumStep) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._880564172zTravel;
         if(_loc2_ !== param1)
         {
            this._880564172zTravel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"zTravel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get forceAdvancedMachineProfiles() : Boolean
      {
         return this._1105127068forceAdvancedMachineProfiles;
      }
      
      public function set forceAdvancedMachineProfiles(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1105127068forceAdvancedMachineProfiles;
         if(_loc2_ !== param1)
         {
            this._1105127068forceAdvancedMachineProfiles = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"forceAdvancedMachineProfiles",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get toolMaterial() : Array
      {
         return this._1710417185toolMaterial;
      }
      
      private function set toolMaterial(param1:Array) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._1710417185toolMaterial;
         if(_loc2_ !== param1)
         {
            this._1710417185toolMaterial = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolMaterial",_loc2_,param1));
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
   }
}
