package cadcamwizp
{
   import cadcamwiz.GWizCCW2DProfile;
   import cadcamwiz.GWizCCW3DSurface;
   import cadcamwiz.GWizCCWCustomFS;
   import cadcamwiz.GWizCCWEstRecord;
   import cadcamwiz.GWizCCWEstimatorInput;
   import cadcamwiz.GWizCCWFaceMill;
   import cadcamwiz.GWizCCWFacing;
   import cadcamwiz.GWizCCWGenericWizard;
   import cadcamwiz.GWizCCWGroovePart;
   import cadcamwiz.GWizCCWHole;
   import cadcamwiz.GWizCCWIDTurn;
   import cadcamwiz.GWizCCWLatheOptions;
   import cadcamwiz.GWizCCWMillOptions;
   import cadcamwiz.GWizCCWODTurn;
   import cadcamwiz.GWizCCWPocket;
   import cadcamwiz.GWizCCWThreading;
   import cadcamwiz.GWizCadCam;
   import comps.GWizEstOpPickerAPI;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import gwapi.GWizCalcAPIServer;
   import login.GWizLoginBar;
   import machines.GWizMachSettings;
   import material.GWizFSMachineMaterialSelector;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.utils.ChangeWatcher;
   import mx.containers.ViewStack;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.INavigatorContent;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.events.PropertyChangeEvent;
   import skins.GWizTabBarSkin;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.NavigatorContent;
   import spark.components.TabBar;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizCadCamD extends GWizCadCam implements IBindingClient
   {
      
      public static var currWizard:GWizCCWGenericWizard;
      
      private static const NO_RECALC_COLOR:uint = 0;
      
      private static const NEEDS_RECALC_COLOR:uint = ColorPalette.secondaryb1;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _572300331FaceWiz:GWizCCWFacing;
      
      private var _1620926216FaceWizNav:NavigatorContent;
      
      private var _1781858949GroovePartWiz:GWizCCWGroovePart;
      
      private var _1859060312GroovePartWizNav:NavigatorContent;
      
      private var _150982800IDTurnWiz:GWizCCWIDTurn;
      
      private var _1097913971IDTurnWizNav:NavigatorContent;
      
      private var _2103809386ODTurnWiz:GWizCCWODTurn;
      
      private var _1872410285ODTurnWizNav:NavigatorContent;
      
      private var _927043842OptionsBtn:Button;
      
      private var _1703857644RecalcBtn:Button;
      
      private var _177425232ThreadingWiz:GWizCCWThreading;
      
      private var _1429576781ThreadingWizNav:NavigatorContent;
      
      private var _228171914ccwLatheOptionsNav:NavigatorContent;
      
      private var _231719851ccwLatheOptionsPanel:GWizCCWLatheOptions;
      
      private var _843636008ccwMillOptionsNav:NavigatorContent;
      
      private var _1016457849ccwMillOptionsPanel:GWizCCWMillOptions;
      
      private var _2080171387customMillWiz:GWizCCWCustomFS;
      
      private var _492329708customWizNav:NavigatorContent;
      
      private var _1956192559facemillWiz:GWizCCWFaceMill;
      
      private var _1478636172facemillWizNav:NavigatorContent;
      
      private var _1091774216holeWiz:GWizCCWHole;
      
      private var _741585669holeWizNav:NavigatorContent;
      
      private var _1070233532mmsCCW:GWizFSMachineMaterialSelector;
      
      private var _435670642pocketWiz:GWizCCWPocket;
      
      private var _326994607pocketWizNav:NavigatorContent;
      
      private var _1180888109profile2DWiz:GWizCCW2DProfile;
      
      private var _239388234profile2DWizNav:NavigatorContent;
      
      private var _571546838surface3DWiz:GWizCCW3DSurface;
      
      private var _1701411431surface3DWizNav:NavigatorContent;
      
      private var _881406642tabNav:ViewStack;
      
      private var _3552126tabs:TabBar;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var titleLabel:String = "Machining";
      
      private var _1008240571nativeWin:DisplayObject = null;
      
      private var widthWatch:ChangeWatcher;
      
      private var heightWatch:ChangeWatcher;
      
      private var resizeExecuting:Boolean = false;
      
      private var cfg:GWizConfigData;
      
      private var lastShownChild:Object = null;
      
      public var opPickerAPI:GWizEstOpPickerAPI;
      
      private var stopShowMeRecursion:Boolean = false;
      
      private var tabMachType:String = "";
      
      private var matchMachineRecursion:Boolean = false;
      
      private var customRemoved:Boolean = false;
      
      private var currWiz:GWizCCWGenericWizard = null;
      
      private var setWizardTries:int = 0;
      
      private const LABEL_WIDTH:int = 80;
      
      private var powerUserState:Boolean = true;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCadCamD()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.cfg = new GWizConfigData();
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCadCamD_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwizp_GWizCadCamDWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCadCamD[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.paddingTop = 10;
         this.gap = 0;
         this.mxmlContent = [this._GWizCadCamD_HGroup1_c(),this._GWizCadCamD_TabBar1_i(),this._GWizCadCamD_ViewStack1_i()];
         this.addEventListener("creationComplete",this.___GWizCadCamD_GWizCadCam1_creationComplete);
         this.addEventListener("initialize",this.___GWizCadCamD_GWizCadCam1_initialize);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCadCamD._watcherSetupUtil = param1;
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
      
      private function updateMMSAux() : void
      {
         var _loc1_:int = 0;
         var _loc2_:GWizFSMachineMaterialSelector = null;
         if(this.customMillWiz && this.customMillWiz.FeedsSpeedsApp && this.customMillWiz.FeedsSpeedsApp.machPanel && this.customMillWiz.FeedsSpeedsApp.didCC && this.customMillWiz.FeedsSpeedsApp.mms && this.mmsCCW)
         {
            _loc1_ = 0;
            while(_loc1_ < this.customMillWiz.FeedsSpeedsApp.machPanel.numElements)
            {
               _loc2_ = this.customMillWiz.FeedsSpeedsApp.machPanel.getElementAt(_loc1_) as GWizFSMachineMaterialSelector;
               if(_loc2_)
               {
                  this.customMillWiz.FeedsSpeedsApp.machPanel.removeElementAt(_loc1_);
                  this.customMillWiz.estInput = new GWizCCWEstimatorInput();
                  this.customMillWiz.FeedsSpeedsApp.machPanel.addElementAt(this.customMillWiz.estInput,_loc1_);
                  this.customMillWiz.estInput.vGrp.gap = this.customMillWiz.FeedsSpeedsApp.gapSizes;
                  this.customMillWiz.FeedsSpeedsApp.estInput = this.customMillWiz.estInput;
                  GWizCadCam.oldMMSChangeFcn = this.customMillWiz.FeedsSpeedsApp.mms.onChangeFcn;
                  this.customMillWiz.FeedsSpeedsApp.mms = this.mmsCCW;
                  break;
               }
               _loc1_++;
            }
         }
         else
         {
            this.callLater(this.updateMMSAux);
         }
      }
      
      private function onCC() : void
      {
         GWizAbstractPrefs.powerUserCC.addFunction("GWizCadCamD",this.powerUserChanged,false);
         GWizEstOpPickerAPI.CadCamD = this;
         this.opPickerAPI = this.pocketWiz.opPickerAPI;
         this.updateMMSAux();
         Machine = this.mmsCCW.Machine;
         MatChooser = this.mmsCCW.MatChooser;
         if(false && !GWizLoginBar.isGWEstimator() && !this.customRemoved)
         {
            this.tabNav.removeElement(this.customWizNav);
            this.customRemoved = true;
         }
         ccwOptions = this.ccwMillOptionsPanel;
         ccwLatheOptions = this.ccwLatheOptionsPanel;
         GWizMachSettings.selectMachineCC.addFunction("GWizCadCam",this.matchMachine);
         this.matchMachine();
         GWizCalcAPIServer.selectCADCAM = this.selectCADCAMAPI;
         this.showMe();
         this.widthWatch = ChangeWatcher.watch(this,"width",this.onResize);
         this.heightWatch = ChangeWatcher.watch(this,"height",this.onResize);
         this.handleResize();
      }
      
      public function onResize(param1:Event) : void
      {
         if(!this.resizeExecuting)
         {
            this.callLater(this.handleResize);
         }
         this.resizeExecuting = true;
      }
      
      private function handleResize() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(false && GWizUtils.debug)
         {
            _loc1_ = 0.33 * this.width;
            _loc2_ = 0.34 * this.width;
            _loc3_ = 0.33 * this.width;
            log.debug("this.width = " + this.width);
            log.debug("firstColWd = " + _loc1_ + ", secondColWd = " + _loc2_ + ", thirdColWd = " + _loc3_);
            log.debug("mmsCCW.width = " + this.mmsCCW.width + ", mmsCCW.firstColWd = " + this.mmsCCW.firstColWd + ", mmsCCW.secondColWd = " + this.mmsCCW.secondColWd);
            log.debug("mmsCCW.height = " + this.mmsCCW.height);
         }
         this.mmsCCW.height = GWizSettings.FeedsSpeedsApp.mmsDefault.height - 15;
         invalidateDisplayList();
         this.resizeExecuting = false;
      }
      
      public function showMe() : void
      {
         var _loc1_:Object = null;
         if(!GWizSettings.docWindow || !GWizSettings.docWindow.visible || !this.ccwMillOptionsNav || !this.ccwLatheOptionsNav)
         {
            this.callLater(this.showMe);
            return;
         }
         if(this.stopShowMeRecursion)
         {
            return;
         }
         this.stopShowMeRecursion = true;
         showing = true;
         if(this.lastShownChild != this.tabNav.selectedChild)
         {
            _loc1_ = this.whichWiz(this.tabNav.selectedChild);
            currWizard = _loc1_ as GWizCCWGenericWizard;
            if(this.tabNav && this.tabNav.selectedChild)
            {
               GWizCadCam.currWizard = this.tabNav.selectedChild.label;
            }
            if(!_loc1_)
            {
               this.stopShowMeRecursion = false;
               this.callLater(this.showMe);
               return;
            }
            this.opPickerAPI = _loc1_.opPickerAPI;
            _loc1_.showMe();
            this.lastShownChild = this.tabNav.selectedChild;
         }
         this.matchMachine();
         this.stopShowMeRecursion = false;
      }
      
      private function matchMachine(param1:Object = null) : Boolean
      {
         if(this.matchMachineRecursion)
         {
            return true;
         }
         this.matchMachineRecursion = true;
         this.customRemoved = false;
         if(this.tabMachType != GWizMachSettings.currMachType)
         {
            this.tabNav.removeAllChildren();
            if(GWizMachSettings.isMill(GWizMachSettings.currMachType))
            {
               this.tabNav.addChild(this.pocketWizNav);
               this.tabNav.addChild(this.profile2DWizNav);
               this.tabNav.addChild(this.holeWizNav);
               this.tabNav.addChild(this.surface3DWizNav);
               this.tabNav.addChild(this.facemillWizNav);
               this.tabNav.addChild(this.customWizNav);
               this.tabNav.addChild(this.ccwMillOptionsNav);
            }
            else if(GWizMachSettings.currMachType == "Lathe")
            {
               this.tabNav.addChild(this.ODTurnWizNav);
               this.tabNav.addChild(this.IDTurnWizNav);
               this.tabNav.addChild(this.FaceWizNav);
               this.tabNav.addChild(this.holeWizNav);
               this.tabNav.addChild(this.GroovePartWizNav);
               this.tabNav.addChild(this.ThreadingWizNav);
               this.tabNav.addChild(this.customWizNav);
               this.tabNav.addChild(this.ccwLatheOptionsNav);
            }
            else
            {
               log.debug("Unknown machineType = " + GWizMachSettings.currMachType);
               GWizUtils.assert(false);
            }
            if(!GWizLoginBar.isGWEstimator() && !this.customRemoved)
            {
               this.tabNav.removeElement(this.customWizNav);
               this.customRemoved = true;
            }
            this.tabNav.selectedIndex = 0;
            this.tabMachType = GWizMachSettings.currMachType;
         }
         this.setWizard();
         this.matchMachineRecursion = false;
         return true;
      }
      
      override protected function recalc() : void
      {
         var _loc1_:GWizJustASec = null;
         GWizCalcAPIServer.getCCField = null;
         if(GWizSettings.FeedsSpeedsApp == null || !this.enabled || !showing)
         {
            _loc1_ = new GWizJustASec(this.recalc);
            return;
         }
         switch(this.tabNav.selectedChild)
         {
            case this.pocketWizNav:
               this.pocketWiz.recalcAux();
               break;
            case this.profile2DWizNav:
               this.profile2DWiz.recalcAux();
               break;
            case this.surface3DWizNav:
               this.surface3DWiz.recalcAux();
               break;
            case this.facemillWizNav:
               this.facemillWiz.recalcAux();
               break;
            case this.holeWizNav:
               this.holeWiz.recalcAux();
               break;
            case this.ODTurnWizNav:
               this.ODTurnWiz.recalcAux();
               break;
            case this.IDTurnWizNav:
               this.IDTurnWiz.recalcAux();
               break;
            case this.FaceWizNav:
               this.FaceWiz.recalcAux();
               break;
            case this.GroovePartWizNav:
               this.GroovePartWiz.recalcAux();
               break;
            case this.ThreadingWizNav:
               this.ThreadingWiz.recalcAux();
               break;
            case this.customWizNav:
         }
      }
      
      private function newTab() : void
      {
         var _loc1_:GWizCCWGenericWizard = this.whichWiz(this.tabNav.selectedChild);
         if(this.currWiz != _loc1_)
         {
            if(this.currWiz)
            {
               this.currWiz.hideMe();
            }
            if(_loc1_)
            {
               _loc1_.showMe();
            }
            this.currWiz = _loc1_;
         }
         userActivity();
         if(this.tabNav.selectedChild && this.tabNav.selectedChild.label == "Estimator")
         {
            ++GWizSettings.ccwEstimatorTab;
         }
      }
      
      private function whichWiz(param1:INavigatorContent) : GWizCCWGenericWizard
      {
         var _loc2_:GWizCCWGenericWizard = null;
         switch(param1)
         {
            case this.pocketWizNav:
               _loc2_ = this.pocketWiz;
               break;
            case this.profile2DWizNav:
               _loc2_ = this.profile2DWiz;
               break;
            case this.surface3DWizNav:
               _loc2_ = this.surface3DWiz;
               break;
            case this.facemillWizNav:
               _loc2_ = this.facemillWiz;
               break;
            case this.holeWizNav:
               _loc2_ = this.holeWiz;
               break;
            case this.ODTurnWizNav:
               _loc2_ = this.ODTurnWiz;
               break;
            case this.IDTurnWizNav:
               _loc2_ = this.IDTurnWiz;
               break;
            case this.FaceWizNav:
               _loc2_ = this.FaceWiz;
               break;
            case this.GroovePartWizNav:
               _loc2_ = this.GroovePartWiz;
               break;
            case this.ThreadingWizNav:
               _loc2_ = this.ThreadingWiz;
               break;
            case this.customWizNav:
               _loc2_ = null;
               break;
            default:
               _loc2_ = null;
         }
         return _loc2_;
      }
      
      override public function enableOutputs() : void
      {
         var _loc1_:GWizCCWGenericWizard = this.whichWiz(this.tabNav.selectedChild);
         if(_loc1_)
         {
            _loc1_.enableOutputs();
         }
      }
      
      private function setWizard() : void
      {
         var _loc1_:String = null;
         var _loc2_:GWizJustASec = null;
         if(this.tabNav && this.tabNav.selectedChild)
         {
            _loc1_ = this.tabNav.selectedChild.label;
            this.callLater(this.showMe);
            this.setWizardTries = 0;
         }
         else if(this.setWizardTries < 10)
         {
            _loc2_ = new GWizJustASec(this.setWizard);
            ++this.setWizardTries;
         }
         if(_loc1_ == "Custom")
         {
            this.RecalcBtn.visible = false;
         }
         else
         {
            this.RecalcBtn.visible = true;
         }
      }
      
      private function logPageView() : void
      {
         GATracker.logPageView("CADCAM/" + this.tabNav.selectedChild.label,"CADCAM: " + this.tabNav.selectedChild.label);
      }
      
      private function selectCADCAMAPI(param1:String) : void
      {
         var _loc5_:Object = null;
         var _loc2_:Object = this.tabNav.selectedChild;
         var _loc3_:int = 0;
         while(_loc3_ < this.tabNav.numChildren)
         {
            if((_loc5_ = this.tabNav.getChildAt(_loc3_)).hasOwnProperty("label") && _loc5_.label == param1)
            {
               _loc2_ = _loc5_;
               break;
            }
            _loc3_++;
         }
         var _loc4_:NavigatorContent = _loc2_ as NavigatorContent;
         this.tabNav.selectedChild = _loc4_;
      }
      
      public function selectOp() : void
      {
         log.debug("selectOp for CADCAM Wizards");
         if(GWizEstOpPickerAPI.editing)
         {
            if(GWizSettings.FeedsSpeedsApp && GWizSettings.FeedsSpeedsApp.didCC)
            {
               log.debug("FeedsSpeeds did CC: " + GWizSettings.FeedsSpeedsApp.didCC);
               if(GWizEstOpPickerAPI.editOp.material != "")
               {
                  GWizCadCam.CADCAMWiz.MatChooser.setMaterialToLabel(GWizEstOpPickerAPI.editOp.material);
               }
               this.customMillWiz.TimeFactor.value = GWizEstOpPickerAPI.editOp.var1;
               this.customMillWiz.PathLen.value = GWizEstOpPickerAPI.editOp.perimeter;
               GWizCCWGenericWizard.estRecToFeedsSpeedsApp(GWizEstOpPickerAPI.editOp,GWizCadCam.CADCAMWiz.Machine.dropDown.selectedItem.name,GWizCadCam.CADCAMWiz.MatChooser.Selection,GWizCCWMillOptions.GasPedalSlider,GWizCCWMillOptions.usePremiumCoolantOptions);
            }
            else
            {
               this.callLater(this.selectOp);
            }
         }
      }
      
      public function saveOp(param1:GWizCCWEstRecord) : void
      {
         var _loc2_:Object = this.tabNav.selectedChild;
         if(_loc2_.hasOwnProperty("label") && _loc2_.label == "Custom")
         {
            this.customMillWiz.addToEstimate();
         }
         else
         {
            currWizard.EstInput.addToEstimate();
         }
      }
      
      public function setSubOp(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.tabNav.length)
         {
            _loc3_ = Object(this.tabNav.getChildAt(_loc2_)).label;
            if(_loc3_ == param1)
            {
               this.tabNav.selectedIndex = _loc2_;
            }
            _loc2_++;
         }
      }
      
      private function doRecalc() : void
      {
         manualRecalc();
      }
      
      private function toggleOptions() : void
      {
         if(GWizCadCamD.currWizard)
         {
            GWizCadCamD.currWizard.toggleOptions();
         }
      }
      
      public function selectFSCalculator() : void
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.tabNav.length)
         {
            _loc2_ = this.tabNav.getItemAt(_loc1_);
            if(_loc2_.label == "Custom")
            {
               this.tabNav.selectedIndex = _loc1_;
               this.tabNav.validateNow();
               return;
            }
            _loc1_++;
         }
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         this.OptionsBtn.visible = GWizSettings.prefs.powerUser;
         return true;
      }
      
      private function _GWizCadCamD_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.mxmlContent = [this._GWizCadCamD_GWizFSMachineMaterialSelector1_i(),this._GWizCadCamD_Spacer1_c(),this._GWizCadCamD_Button1_i(),this._GWizCadCamD_Button2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCadCamD_GWizFSMachineMaterialSelector1_i() : GWizFSMachineMaterialSelector
      {
         var _loc1_:GWizFSMachineMaterialSelector = new GWizFSMachineMaterialSelector();
         _loc1_.onChangeFcn = requestRecalc;
         _loc1_.theOwner = "GWizCadCamD";
         _loc1_.verticalAlign = "middle";
         _loc1_.id = "mmsCCW";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mmsCCW = _loc1_;
         BindingManager.executeBindings(this,"mmsCCW",this.mmsCCW);
         return _loc1_;
      }
      
      private function _GWizCadCamD_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCadCamD_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Options";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.addEventListener("click",this.__OptionsBtn_click);
         _loc1_.id = "OptionsBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.OptionsBtn = _loc1_;
         BindingManager.executeBindings(this,"OptionsBtn",this.OptionsBtn);
         return _loc1_;
      }
      
      public function __OptionsBtn_click(param1:MouseEvent) : void
      {
         this.toggleOptions();
      }
      
      private function _GWizCadCamD_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Recalc";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.addEventListener("click",this.__RecalcBtn_click);
         _loc1_.id = "RecalcBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RecalcBtn = _loc1_;
         BindingManager.executeBindings(this,"RecalcBtn",this.RecalcBtn);
         return _loc1_;
      }
      
      public function __RecalcBtn_click(param1:MouseEvent) : void
      {
         this.doRecalc();
      }
      
      private function _GWizCadCamD_TabBar1_i() : TabBar
      {
         var _loc1_:TabBar = new TabBar();
         _loc1_.styleName = "tabHeader";
         _loc1_.top = 0;
         _loc1_.left = 0;
         _loc1_.setStyle("skinClass",GWizTabBarSkin);
         _loc1_.addEventListener("valueCommit",this.__tabs_valueCommit);
         _loc1_.id = "tabs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tabs = _loc1_;
         BindingManager.executeBindings(this,"tabs",this.tabs);
         return _loc1_;
      }
      
      public function __tabs_valueCommit(param1:FlexEvent) : void
      {
         this.newTab();
      }
      
      private function _GWizCadCamD_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.bottom = 0;
         temp.right = 0;
         temp.left = 0;
         temp.creationPolicy = "auto";
         temp.setStyle("borderColor",8752525);
         temp.setStyle("paddingTop",10);
         temp.setStyle("paddingLeft",5);
         temp.setStyle("paddingBottom",5);
         temp.setStyle("paddingRight",5);
         temp.setStyle("backgroundAlpha",1);
         temp.addEventListener("valueCommit",this.__tabNav_valueCommit);
         temp.addEventListener("change",this.__tabNav_change);
         temp.id = "tabNav";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"tabNav",
            "events":{
               "valueCommit":"__tabNav_valueCommit",
               "change":"__tabNav_change"
            },
            "stylesFactory":function():void
            {
               this.borderColor = 8752525;
               this.paddingTop = 10;
               this.paddingLeft = 5;
               this.paddingBottom = 5;
               this.paddingRight = 5;
               this.backgroundAlpha = 1;
            },
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"pocketWizNav",
                  "events":{"show":"__pocketWizNav_show"},
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array3_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"profile2DWizNav",
                  "events":{
                     "show":"__profile2DWizNav_show",
                     "hide":"__profile2DWizNav_hide"
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array4_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"surface3DWizNav",
                  "events":{
                     "show":"__surface3DWizNav_show",
                     "hide":"__surface3DWizNav_hide"
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array5_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"facemillWizNav",
                  "events":{
                     "show":"__facemillWizNav_show",
                     "hide":"__facemillWizNav_hide"
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array6_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"holeWizNav",
                  "events":{
                     "show":"__holeWizNav_show",
                     "hide":"__holeWizNav_hide"
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Hole",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array7_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"customWizNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Custom",
                        "percentWidth":100,
                        "percentHeight":100,
                        "creationPolicy":"all",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array8_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"ccwMillOptionsNav",
                  "events":{
                     "show":"__ccwMillOptionsNav_show",
                     "hide":"__ccwMillOptionsNav_hide"
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Setup",
                        "percentWidth":100,
                        "percentHeight":100,
                        "creationPolicy":"all",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array9_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"ccwLatheOptionsNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Setup",
                        "percentWidth":100,
                        "percentHeight":100,
                        "creationPolicy":"all",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array10_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"ODTurnWizNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"OD Turn",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array11_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"IDTurnWizNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"ID Turn",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array12_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"FaceWizNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Face",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array13_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"GroovePartWizNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Groove/Part",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array14_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"ThreadingWizNav",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Thread",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCadCamD_Array15_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.tabNav = temp;
         BindingManager.executeBindings(this,"tabNav",this.tabNav);
         return temp;
      }
      
      public function __tabNav_valueCommit(param1:FlexEvent) : void
      {
         this.setWizard();
      }
      
      public function __tabNav_change(param1:IndexChangedEvent) : void
      {
         this.logPageView();
      }
      
      private function _GWizCadCamD_Array3_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWPocket1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWPocket1_i() : GWizCCWPocket
      {
         var _loc1_:GWizCCWPocket = new GWizCCWPocket();
         _loc1_.id = "pocketWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pocketWiz = _loc1_;
         BindingManager.executeBindings(this,"pocketWiz",this.pocketWiz);
         return _loc1_;
      }
      
      public function __pocketWizNav_show(param1:FlexEvent) : void
      {
         this.pocketWiz.showMe();
      }
      
      private function _GWizCadCamD_Array4_c() : Array
      {
         return [this._GWizCadCamD_GWizCCW2DProfile1_i()];
      }
      
      private function _GWizCadCamD_GWizCCW2DProfile1_i() : GWizCCW2DProfile
      {
         var _loc1_:GWizCCW2DProfile = new GWizCCW2DProfile();
         _loc1_.id = "profile2DWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.profile2DWiz = _loc1_;
         BindingManager.executeBindings(this,"profile2DWiz",this.profile2DWiz);
         return _loc1_;
      }
      
      public function __profile2DWizNav_show(param1:FlexEvent) : void
      {
         this.profile2DWiz.showMe();
      }
      
      public function __profile2DWizNav_hide(param1:FlexEvent) : void
      {
         this.profile2DWiz.hideMe();
      }
      
      private function _GWizCadCamD_Array5_c() : Array
      {
         return [this._GWizCadCamD_GWizCCW3DSurface1_i()];
      }
      
      private function _GWizCadCamD_GWizCCW3DSurface1_i() : GWizCCW3DSurface
      {
         var _loc1_:GWizCCW3DSurface = new GWizCCW3DSurface();
         _loc1_.id = "surface3DWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.surface3DWiz = _loc1_;
         BindingManager.executeBindings(this,"surface3DWiz",this.surface3DWiz);
         return _loc1_;
      }
      
      public function __surface3DWizNav_show(param1:FlexEvent) : void
      {
         this.surface3DWiz.showMe();
      }
      
      public function __surface3DWizNav_hide(param1:FlexEvent) : void
      {
         this.surface3DWiz.hideMe();
      }
      
      private function _GWizCadCamD_Array6_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWFaceMill1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWFaceMill1_i() : GWizCCWFaceMill
      {
         var _loc1_:GWizCCWFaceMill = new GWizCCWFaceMill();
         _loc1_.id = "facemillWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.facemillWiz = _loc1_;
         BindingManager.executeBindings(this,"facemillWiz",this.facemillWiz);
         return _loc1_;
      }
      
      public function __facemillWizNav_show(param1:FlexEvent) : void
      {
         this.facemillWiz.showMe();
      }
      
      public function __facemillWizNav_hide(param1:FlexEvent) : void
      {
         this.facemillWiz.hideMe();
      }
      
      private function _GWizCadCamD_Array7_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWHole1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWHole1_i() : GWizCCWHole
      {
         var _loc1_:GWizCCWHole = new GWizCCWHole();
         _loc1_.id = "holeWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.holeWiz = _loc1_;
         BindingManager.executeBindings(this,"holeWiz",this.holeWiz);
         return _loc1_;
      }
      
      public function __holeWizNav_show(param1:FlexEvent) : void
      {
         this.holeWiz.showMe();
      }
      
      public function __holeWizNav_hide(param1:FlexEvent) : void
      {
         this.holeWiz.hideMe();
      }
      
      private function _GWizCadCamD_Array8_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWCustomFS1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWCustomFS1_i() : GWizCCWCustomFS
      {
         var _loc1_:GWizCCWCustomFS = new GWizCCWCustomFS();
         _loc1_.id = "customMillWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.customMillWiz = _loc1_;
         BindingManager.executeBindings(this,"customMillWiz",this.customMillWiz);
         return _loc1_;
      }
      
      private function _GWizCadCamD_Array9_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWMillOptions1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWMillOptions1_i() : GWizCCWMillOptions
      {
         var _loc1_:GWizCCWMillOptions = new GWizCCWMillOptions();
         _loc1_.id = "ccwMillOptionsPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ccwMillOptionsPanel = _loc1_;
         BindingManager.executeBindings(this,"ccwMillOptionsPanel",this.ccwMillOptionsPanel);
         return _loc1_;
      }
      
      public function __ccwMillOptionsNav_show(param1:FlexEvent) : void
      {
         this.ccwMillOptionsPanel.showMe();
      }
      
      public function __ccwMillOptionsNav_hide(param1:FlexEvent) : void
      {
         this.ccwMillOptionsPanel.hideMe();
      }
      
      private function _GWizCadCamD_Array10_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWLatheOptions1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWLatheOptions1_i() : GWizCCWLatheOptions
      {
         var _loc1_:GWizCCWLatheOptions = new GWizCCWLatheOptions();
         _loc1_.id = "ccwLatheOptionsPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ccwLatheOptionsPanel = _loc1_;
         BindingManager.executeBindings(this,"ccwLatheOptionsPanel",this.ccwLatheOptionsPanel);
         return _loc1_;
      }
      
      private function _GWizCadCamD_Array11_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWODTurn1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWODTurn1_i() : GWizCCWODTurn
      {
         var _loc1_:GWizCCWODTurn = new GWizCCWODTurn();
         _loc1_.id = "ODTurnWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ODTurnWiz = _loc1_;
         BindingManager.executeBindings(this,"ODTurnWiz",this.ODTurnWiz);
         return _loc1_;
      }
      
      private function _GWizCadCamD_Array12_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWIDTurn1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWIDTurn1_i() : GWizCCWIDTurn
      {
         var _loc1_:GWizCCWIDTurn = new GWizCCWIDTurn();
         _loc1_.id = "IDTurnWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.IDTurnWiz = _loc1_;
         BindingManager.executeBindings(this,"IDTurnWiz",this.IDTurnWiz);
         return _loc1_;
      }
      
      private function _GWizCadCamD_Array13_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWFacing1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWFacing1_i() : GWizCCWFacing
      {
         var _loc1_:GWizCCWFacing = new GWizCCWFacing();
         _loc1_.id = "FaceWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FaceWiz = _loc1_;
         BindingManager.executeBindings(this,"FaceWiz",this.FaceWiz);
         return _loc1_;
      }
      
      private function _GWizCadCamD_Array14_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWGroovePart1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWGroovePart1_i() : GWizCCWGroovePart
      {
         var _loc1_:GWizCCWGroovePart = new GWizCCWGroovePart();
         _loc1_.id = "GroovePartWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GroovePartWiz = _loc1_;
         BindingManager.executeBindings(this,"GroovePartWiz",this.GroovePartWiz);
         return _loc1_;
      }
      
      private function _GWizCadCamD_Array15_c() : Array
      {
         return [this._GWizCadCamD_GWizCCWThreading1_i()];
      }
      
      private function _GWizCadCamD_GWizCCWThreading1_i() : GWizCCWThreading
      {
         var _loc1_:GWizCCWThreading = new GWizCCWThreading();
         _loc1_.id = "ThreadingWiz";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ThreadingWiz = _loc1_;
         BindingManager.executeBindings(this,"ThreadingWiz",this.ThreadingWiz);
         return _loc1_;
      }
      
      public function ___GWizCadCamD_GWizCadCam1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizCadCamD_GWizCadCam1_initialize(param1:FlexEvent) : void
      {
         CADCAMWiz = this;
      }
      
      private function _GWizCadCamD_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():int
         {
            return 0.33 * this.width;
         },null,"mmsCCW.firstColWd");
         result[1] = new Binding(this,function():int
         {
            return 0.33 * this.width;
         },null,"mmsCCW.secondColWd");
         result[2] = new Binding(this,function():Number
         {
            return 0.66 * this.width;
         },null,"mmsCCW.width");
         result[3] = new Binding(this,function():DisplayObject
         {
            return this.nativeWin;
         },null,"mmsCCW.nativeWin");
         result[4] = new Binding(this,function():Number
         {
            return mmsCCW.height;
         },null,"OptionsBtn.height");
         result[5] = new Binding(this,function():Number
         {
            return mmsCCW.height;
         },null,"RecalcBtn.height");
         result[6] = new Binding(this,function():Number
         {
            return OptionsBtn.width;
         },null,"RecalcBtn.width");
         result[7] = new Binding(this,function():uint
         {
            return !!GWizCadCam._needRecalc ? uint(NEEDS_RECALC_COLOR) : uint(NO_RECALC_COLOR);
         },function(param1:uint):void
         {
            RecalcBtn.setStyle("color",param1);
         },"RecalcBtn.color");
         result[8] = new Binding(this,null,null,"tabs.dataProvider","tabNav");
         result[9] = new Binding(this,function():uint
         {
            return ColorPalette.secondarya2;
         },function(param1:uint):void
         {
            tabs.setStyle("chromeColor",param1);
         },"tabs.chromeColor");
         result[10] = new Binding(this,function():uint
         {
            return ColorPalette.secondarya4;
         },function(param1:uint):void
         {
            tabs.setStyle("color",param1);
         },"tabs.color");
         result[11] = new Binding(this,function():uint
         {
            return ColorPalette.secondarya2;
         },function(param1:uint):void
         {
            tabNav.setStyle("backgroundColor",param1);
         },"tabNav.backgroundColor");
         result[12] = new Binding(this,function():Object
         {
            return tabs.height - 1;
         },null,"tabNav.top");
         result[13] = new Binding(this,function():String
         {
            var _loc1_:* = GWizCCWEstRecord.CCE_MILL_POCKET;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"pocketWizNav.label");
         result[14] = new Binding(this,function():int
         {
            return LABEL_WIDTH;
         },null,"pocketWiz.theLabelWidth");
         result[15] = new Binding(this,function():String
         {
            var _loc1_:* = GWizCCWEstRecord.CCE_MILL_2DProfile;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"profile2DWizNav.label");
         result[16] = new Binding(this,function():String
         {
            var _loc1_:* = GWizCCWEstRecord.CCE_MILL_3DSURFACE;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"surface3DWizNav.label");
         result[17] = new Binding(this,function():String
         {
            var _loc1_:* = GWizCCWEstRecord.CCE_MILL_FACEMILL;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"facemillWizNav.label");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get FaceWiz() : GWizCCWFacing
      {
         return this._572300331FaceWiz;
      }
      
      public function set FaceWiz(param1:GWizCCWFacing) : void
      {
         var _loc2_:Object = this._572300331FaceWiz;
         if(_loc2_ !== param1)
         {
            this._572300331FaceWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FaceWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FaceWizNav() : NavigatorContent
      {
         return this._1620926216FaceWizNav;
      }
      
      public function set FaceWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1620926216FaceWizNav;
         if(_loc2_ !== param1)
         {
            this._1620926216FaceWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FaceWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GroovePartWiz() : GWizCCWGroovePart
      {
         return this._1781858949GroovePartWiz;
      }
      
      public function set GroovePartWiz(param1:GWizCCWGroovePart) : void
      {
         var _loc2_:Object = this._1781858949GroovePartWiz;
         if(_loc2_ !== param1)
         {
            this._1781858949GroovePartWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GroovePartWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GroovePartWizNav() : NavigatorContent
      {
         return this._1859060312GroovePartWizNav;
      }
      
      public function set GroovePartWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1859060312GroovePartWizNav;
         if(_loc2_ !== param1)
         {
            this._1859060312GroovePartWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GroovePartWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get IDTurnWiz() : GWizCCWIDTurn
      {
         return this._150982800IDTurnWiz;
      }
      
      public function set IDTurnWiz(param1:GWizCCWIDTurn) : void
      {
         var _loc2_:Object = this._150982800IDTurnWiz;
         if(_loc2_ !== param1)
         {
            this._150982800IDTurnWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IDTurnWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get IDTurnWizNav() : NavigatorContent
      {
         return this._1097913971IDTurnWizNav;
      }
      
      public function set IDTurnWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1097913971IDTurnWizNav;
         if(_loc2_ !== param1)
         {
            this._1097913971IDTurnWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IDTurnWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ODTurnWiz() : GWizCCWODTurn
      {
         return this._2103809386ODTurnWiz;
      }
      
      public function set ODTurnWiz(param1:GWizCCWODTurn) : void
      {
         var _loc2_:Object = this._2103809386ODTurnWiz;
         if(_loc2_ !== param1)
         {
            this._2103809386ODTurnWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ODTurnWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ODTurnWizNav() : NavigatorContent
      {
         return this._1872410285ODTurnWizNav;
      }
      
      public function set ODTurnWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1872410285ODTurnWizNav;
         if(_loc2_ !== param1)
         {
            this._1872410285ODTurnWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ODTurnWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get OptionsBtn() : Button
      {
         return this._927043842OptionsBtn;
      }
      
      public function set OptionsBtn(param1:Button) : void
      {
         var _loc2_:Object = this._927043842OptionsBtn;
         if(_loc2_ !== param1)
         {
            this._927043842OptionsBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"OptionsBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RecalcBtn() : Button
      {
         return this._1703857644RecalcBtn;
      }
      
      public function set RecalcBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1703857644RecalcBtn;
         if(_loc2_ !== param1)
         {
            this._1703857644RecalcBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RecalcBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThreadingWiz() : GWizCCWThreading
      {
         return this._177425232ThreadingWiz;
      }
      
      public function set ThreadingWiz(param1:GWizCCWThreading) : void
      {
         var _loc2_:Object = this._177425232ThreadingWiz;
         if(_loc2_ !== param1)
         {
            this._177425232ThreadingWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThreadingWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThreadingWizNav() : NavigatorContent
      {
         return this._1429576781ThreadingWizNav;
      }
      
      public function set ThreadingWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1429576781ThreadingWizNav;
         if(_loc2_ !== param1)
         {
            this._1429576781ThreadingWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThreadingWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ccwLatheOptionsNav() : NavigatorContent
      {
         return this._228171914ccwLatheOptionsNav;
      }
      
      public function set ccwLatheOptionsNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._228171914ccwLatheOptionsNav;
         if(_loc2_ !== param1)
         {
            this._228171914ccwLatheOptionsNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ccwLatheOptionsNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ccwLatheOptionsPanel() : GWizCCWLatheOptions
      {
         return this._231719851ccwLatheOptionsPanel;
      }
      
      public function set ccwLatheOptionsPanel(param1:GWizCCWLatheOptions) : void
      {
         var _loc2_:Object = this._231719851ccwLatheOptionsPanel;
         if(_loc2_ !== param1)
         {
            this._231719851ccwLatheOptionsPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ccwLatheOptionsPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ccwMillOptionsNav() : NavigatorContent
      {
         return this._843636008ccwMillOptionsNav;
      }
      
      public function set ccwMillOptionsNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._843636008ccwMillOptionsNav;
         if(_loc2_ !== param1)
         {
            this._843636008ccwMillOptionsNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ccwMillOptionsNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ccwMillOptionsPanel() : GWizCCWMillOptions
      {
         return this._1016457849ccwMillOptionsPanel;
      }
      
      public function set ccwMillOptionsPanel(param1:GWizCCWMillOptions) : void
      {
         var _loc2_:Object = this._1016457849ccwMillOptionsPanel;
         if(_loc2_ !== param1)
         {
            this._1016457849ccwMillOptionsPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ccwMillOptionsPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get customMillWiz() : GWizCCWCustomFS
      {
         return this._2080171387customMillWiz;
      }
      
      public function set customMillWiz(param1:GWizCCWCustomFS) : void
      {
         var _loc2_:Object = this._2080171387customMillWiz;
         if(_loc2_ !== param1)
         {
            this._2080171387customMillWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"customMillWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get customWizNav() : NavigatorContent
      {
         return this._492329708customWizNav;
      }
      
      public function set customWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._492329708customWizNav;
         if(_loc2_ !== param1)
         {
            this._492329708customWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"customWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get facemillWiz() : GWizCCWFaceMill
      {
         return this._1956192559facemillWiz;
      }
      
      public function set facemillWiz(param1:GWizCCWFaceMill) : void
      {
         var _loc2_:Object = this._1956192559facemillWiz;
         if(_loc2_ !== param1)
         {
            this._1956192559facemillWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"facemillWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get facemillWizNav() : NavigatorContent
      {
         return this._1478636172facemillWizNav;
      }
      
      public function set facemillWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1478636172facemillWizNav;
         if(_loc2_ !== param1)
         {
            this._1478636172facemillWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"facemillWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get holeWiz() : GWizCCWHole
      {
         return this._1091774216holeWiz;
      }
      
      public function set holeWiz(param1:GWizCCWHole) : void
      {
         var _loc2_:Object = this._1091774216holeWiz;
         if(_loc2_ !== param1)
         {
            this._1091774216holeWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"holeWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get holeWizNav() : NavigatorContent
      {
         return this._741585669holeWizNav;
      }
      
      public function set holeWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._741585669holeWizNav;
         if(_loc2_ !== param1)
         {
            this._741585669holeWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"holeWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mmsCCW() : GWizFSMachineMaterialSelector
      {
         return this._1070233532mmsCCW;
      }
      
      public function set mmsCCW(param1:GWizFSMachineMaterialSelector) : void
      {
         var _loc2_:Object = this._1070233532mmsCCW;
         if(_loc2_ !== param1)
         {
            this._1070233532mmsCCW = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mmsCCW",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pocketWiz() : GWizCCWPocket
      {
         return this._435670642pocketWiz;
      }
      
      public function set pocketWiz(param1:GWizCCWPocket) : void
      {
         var _loc2_:Object = this._435670642pocketWiz;
         if(_loc2_ !== param1)
         {
            this._435670642pocketWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pocketWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pocketWizNav() : NavigatorContent
      {
         return this._326994607pocketWizNav;
      }
      
      public function set pocketWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._326994607pocketWizNav;
         if(_loc2_ !== param1)
         {
            this._326994607pocketWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pocketWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get profile2DWiz() : GWizCCW2DProfile
      {
         return this._1180888109profile2DWiz;
      }
      
      public function set profile2DWiz(param1:GWizCCW2DProfile) : void
      {
         var _loc2_:Object = this._1180888109profile2DWiz;
         if(_loc2_ !== param1)
         {
            this._1180888109profile2DWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profile2DWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get profile2DWizNav() : NavigatorContent
      {
         return this._239388234profile2DWizNav;
      }
      
      public function set profile2DWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._239388234profile2DWizNav;
         if(_loc2_ !== param1)
         {
            this._239388234profile2DWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"profile2DWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get surface3DWiz() : GWizCCW3DSurface
      {
         return this._571546838surface3DWiz;
      }
      
      public function set surface3DWiz(param1:GWizCCW3DSurface) : void
      {
         var _loc2_:Object = this._571546838surface3DWiz;
         if(_loc2_ !== param1)
         {
            this._571546838surface3DWiz = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"surface3DWiz",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get surface3DWizNav() : NavigatorContent
      {
         return this._1701411431surface3DWizNav;
      }
      
      public function set surface3DWizNav(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1701411431surface3DWizNav;
         if(_loc2_ !== param1)
         {
            this._1701411431surface3DWizNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"surface3DWizNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tabNav() : ViewStack
      {
         return this._881406642tabNav;
      }
      
      public function set tabNav(param1:ViewStack) : void
      {
         var _loc2_:Object = this._881406642tabNav;
         if(_loc2_ !== param1)
         {
            this._881406642tabNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tabNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tabs() : TabBar
      {
         return this._3552126tabs;
      }
      
      public function set tabs(param1:TabBar) : void
      {
         var _loc2_:Object = this._3552126tabs;
         if(_loc2_ !== param1)
         {
            this._3552126tabs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tabs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get nativeWin() : DisplayObject
      {
         return this._1008240571nativeWin;
      }
      
      public function set nativeWin(param1:DisplayObject) : void
      {
         var _loc2_:Object = this._1008240571nativeWin;
         if(_loc2_ !== param1)
         {
            this._1008240571nativeWin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"nativeWin",_loc2_,param1));
            }
         }
      }
   }
}
