package feedsspeeds
{
   import comps.GWizFileBrowser;
   import comps.GWizLinkLabelURL;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import material.GWizMaterialsDB;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.CloseEvent;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.collections.Sort;
   import spark.collections.SortField;
   import spark.components.Button;
   import spark.components.DataGrid;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.List;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import spark.components.gridClasses.GridColumn;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizCSVUtils;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizMfgFamilyPopup extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizMfgFamilyPopup");
      
      private static var _selectionText:String;
      
      private static const FAMILY_DOWNLOAD_FOLDER:String = "http://cnccookbook.com/img/GWizard/Downloads/ToolFamilies/";
      
      private static var gotSFM:Boolean = false;
      
      private static var gotIPT:Boolean = false;
      
      private static var callAfter:Function;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _725364997HelpLink:GWizLinkLabelURL;
      
      public var _GWizMfgFamilyPopup_Button1:Button;
      
      public var _GWizMfgFamilyPopup_Button2:Button;
      
      public var _GWizMfgFamilyPopup_Button3:Button;
      
      public var _GWizMfgFamilyPopup_Button4:Button;
      
      public var _GWizMfgFamilyPopup_ClassFactory1:ClassFactory;
      
      private var _1601908882editPane:VGroup;
      
      private var _798502434familyList:List;
      
      private var _2014322039iptData:DataGrid;
      
      private var _1263307720iptDelete:Button;
      
      private var _2014341139iptDupe:Label;
      
      private var _1181938125iptNew:Button;
      
      private var _2006668100sfmData:DataGrid;
      
      private var _28808507sfmDelete:Button;
      
      private var _2006687200sfmDupe:Label;
      
      private var _905090362sfmNew:Button;
      
      private var _984130913topLabel:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var theTextInput:TextInput;
      
      private var _840178206matList:ArrayCollection;
      
      public const FEET_UNITS:String = "Feet";
      
      public const M_UNITS:String = "Meters";
      
      public var saveFcn:Function;
      
      public var familyFiles:GWizFileBrowser;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizMfgFamilyPopup()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._840178206matList = GWizMaterialsDB.MaterialsListAC;
         this.familyFiles = new GWizFileBrowser("ToolFamilies","CSV","*.csv");
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizMfgFamilyPopup_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizMfgFamilyPopupWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizMfgFamilyPopup[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Tool Family...";
         this.cancelLabel = "";
         this.fullScreen = true;
         this.mxmlContent = [this._GWizMfgFamilyPopup_HGroup1_c()];
         this._GWizMfgFamilyPopup_ClassFactory1_i();
         this.addEventListener("creationComplete",this.___GWizMfgFamilyPopup_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function mfgFamilyPopUp(param1:DisplayObject, param2:TextInput, param3:Function) : GWizMfgFamilyPopup
      {
         var _loc4_:GWizMfgFamilyPopup;
         (_loc4_ = GWizMfgFamilyPopup(GWizPopUpManager.createPopUp(param1,GWizMfgFamilyPopup,true))).theTextInput = param2;
         _loc4_.selectionText = param2.text;
         _loc4_.saveFcn = param3;
         return _loc4_;
      }
      
      public static function importCSVToolFamily(param1:ArrayCollection, param2:String) : void
      {
         var _loc4_:String = null;
         var _loc6_:int = 0;
         var _loc9_:String = null;
         if(!param1)
         {
            return;
         }
         var _loc3_:Object = param1.getItemAt(0);
         var _loc5_:Boolean = false;
         if(_loc3_.hasOwnProperty("chipload"))
         {
            _loc5_ = true;
            _loc4_ = GWizUtils.requiredFields(_loc3_,["family","material","diameter","chipload"]);
         }
         else
         {
            _loc4_ = GWizUtils.requiredFields(_loc3_,["family","material","sfm"]);
         }
         if(_loc4_ != "")
         {
            GWizPopUpManager.Show("Error: Imported examples file is missing column " + _loc4_,"Error: Import",GWizPopUpManager.ERROR);
            return;
         }
         var _loc7_:Boolean = false;
         _loc6_ = 0;
         while(_loc6_ < param1.length)
         {
            _loc3_ = param1.getItemAt(_loc6_);
            if(!GWizMaterialsDB.validMaterial(_loc3_.material))
            {
               _loc7_ = true;
               break;
            }
            _loc6_++;
         }
         if(_loc7_)
         {
            GWizPopUpManager.Show("Error: Imported examples file has an unknown material " + _loc3_.material,"Error: Import",GWizPopUpManager.ERROR);
            return;
         }
         var _loc8_:Object = new Object();
         if(_loc5_)
         {
            _loc6_ = 0;
            while(_loc6_ < GWizMfgCutterSpecs.chiploadExamples.length)
            {
               _loc3_ = GWizMfgCutterSpecs.chiploadExamples.getItemAt(_loc6_);
               _loc9_ = iptHash(_loc3_);
               if(_loc8_.hasOwnProperty(_loc9_))
               {
                  if(GWizUtils.debug)
                  {
                     GWizUtils.assert(false);
                  }
               }
               else
               {
                  _loc8_[_loc9_] = true;
               }
               _loc6_++;
            }
         }
         else
         {
            _loc6_ = 0;
            while(_loc6_ < GWizMfgCutterSpecs.sfmExamples.length)
            {
               _loc3_ = GWizMfgCutterSpecs.sfmExamples.getItemAt(_loc6_);
               _loc9_ = sfmHash(_loc3_);
               if(_loc8_.hasOwnProperty(_loc9_))
               {
                  if(GWizUtils.debug)
                  {
                     GWizUtils.assert(false);
                  }
               }
               else
               {
                  _loc8_[_loc9_] = true;
               }
               _loc6_++;
            }
         }
         _loc6_ = 0;
         while(_loc6_ < param1.length)
         {
            _loc3_ = param1.getItemAt(_loc6_);
            if(_loc5_)
            {
               if(!_loc8_.hasOwnProperty(iptHash(_loc3_)))
               {
                  GWizMfgCutterSpecs.chiploadExamples.addItem(_loc3_);
               }
            }
            else if(!_loc8_.hasOwnProperty(sfmHash(_loc3_)))
            {
               GWizMfgCutterSpecs.sfmExamples.addItem(_loc3_);
            }
            _loc6_++;
         }
         GWizMfgCutterSpecs.rebuildFamilyList();
      }
      
      private static function iptHash(param1:Object) : String
      {
         return param1.family + param1.material + String(param1.diameter);
      }
      
      private static function sfmHash(param1:Object) : String
      {
         return param1.family + param1.material;
      }
      
      private static function gotFamily(param1:ArrayCollection) : void
      {
         importCSVToolFamily(param1,"");
         if(gotSFM)
         {
            gotIPT = true;
         }
         else
         {
            gotSFM = true;
         }
      }
      
      private static function downloadExamples(param1:String) : void
      {
         GWizCSVUtils.downloadCSV(FAMILY_DOWNLOAD_FOLDER + param1,gotFamily);
      }
      
      private static function doDownloadAux() : void
      {
         if(gotSFM && !gotIPT)
         {
            downloadExamples("iptexamples.csv");
         }
         else if(gotIPT)
         {
            if(callAfter != null)
            {
               callAfter();
            }
            return;
         }
         var _loc1_:GWizJustASec = new GWizJustASec(doDownloadAux);
      }
      
      public static function doDownload(param1:Function) : void
      {
         GATracker.logPageView("ToolFamily/Download","ToolFamily/Download");
         gotSFM = false;
         gotIPT = false;
         callAfter = param1;
         downloadExamples("sfmexamples.csv");
         doDownloadAux();
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizMfgFamilyPopup._watcherSetupUtil = param1;
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
      }
      
      private function set selectionText(param1:String) : void
      {
         var _loc3_:Object = null;
         _selectionText = param1;
         var _loc2_:int = 0;
         while(_loc2_ < GWizMfgCutterSpecs.familyListData.length)
         {
            _loc3_ = GWizMfgCutterSpecs.familyListData.getItemAt(_loc2_);
            if(_loc3_.label == param1)
            {
               this.familyList.selectedIndex = _loc2_;
               return;
            }
            _loc2_++;
         }
      }
      
      private function get selectionText() : String
      {
         return _selectionText;
      }
      
      override public function close() : void
      {
         this.checkDupes();
         if(!this.sfmDupe.visible && !this.iptDupe.visible)
         {
            if(this.theTextInput && this.familyList.selectedIndex >= 0)
            {
               this.theTextInput.text = this.familyList.selectedItem.label;
               if(this.saveFcn != null)
               {
                  this.saveFcn();
               }
            }
            this.setFilters(false);
            super.close();
         }
      }
      
      private function setFamily() : void
      {
         var _loc1_:Boolean = false;
         if(this.familyList.selectedIndex >= 0)
         {
            _selectionText = this.familyList.selectedItem.label;
            _loc1_ = true;
            if(this.selectionText == GWizMfgCutterSpecs.GENERIC_FAMILY)
            {
               _loc1_ = false;
               this.topLabel.text = "Can\'t edit Generic Family.";
            }
            else
            {
               _loc1_ = true;
               this.topLabel.text = " ";
            }
            this.iptNew.enabled = _loc1_;
            this.iptDelete.enabled = _loc1_;
            this.sfmNew.enabled = _loc1_;
            this.sfmDelete.enabled = _loc1_;
            this.setFilters(true);
         }
      }
      
      private function setFilters(param1:Boolean) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc2_:SortField = new SortField();
         var _loc3_:SortField = new SortField();
         var _loc4_:SortField = new SortField();
         _loc2_.name = "family";
         _loc2_.numeric = false;
         _loc3_.name = "material";
         _loc3_.numeric = false;
         _loc4_.name = "diameter";
         _loc4_.numeric = true;
         var _loc5_:Sort;
         (_loc5_ = new Sort()).fields = [_loc2_,_loc3_];
         GWizMfgCutterSpecs.sfmExamples.sort = _loc5_;
         (_loc5_ = new Sort()).fields = [_loc2_,_loc3_,_loc4_];
         GWizMfgCutterSpecs.chiploadExamples.sort = _loc5_;
         GWizMfgCutterSpecs.sfmExamples.refresh();
         GWizMfgCutterSpecs.chiploadExamples.refresh();
         if(param1)
         {
            GWizMfgCutterSpecs.sfmExamples.filterFunction = this.familyFilter;
            GWizMfgCutterSpecs.chiploadExamples.filterFunction = this.familyFilter;
         }
         else
         {
            GWizMfgCutterSpecs.sfmExamples.filterFunction = null;
            GWizMfgCutterSpecs.chiploadExamples.filterFunction = null;
         }
         GWizMfgCutterSpecs.sfmExamples.refresh();
         GWizMfgCutterSpecs.chiploadExamples.refresh();
         if(GWizUtils.debug && false)
         {
            log.debug("*** Sort Order ***");
            _loc6_ = 0;
            while(_loc6_ < GWizMfgCutterSpecs.chiploadExamples.length)
            {
               _loc7_ = GWizMfgCutterSpecs.chiploadExamples.getItemAt(_loc6_);
               log.debug("Sorted Entry: family = " + _loc7_.family + ", material = " + _loc7_.material + ", diameter = " + _loc7_.diameter);
               _loc6_++;
            }
            log.debug("*** Done ***");
         }
      }
      
      private function familyFilter(param1:Object) : Boolean
      {
         return param1.family == this.selectionText;
      }
      
      private function newSFMExample(param1:String = "") : void
      {
         var _loc2_:Object = {
            "family":"Lakeshore Carbide VFA - 1 Example",
            "material":"Aluminum - Wrought (6061)",
            "sfm":0
         };
         if(param1 == "")
         {
            param1 = this.selectionText;
         }
         _loc2_.family = param1;
         GWizMfgCutterSpecs.sfmExamples.addItem(_loc2_);
         this.checkDupes();
      }
      
      private function delSFMExample() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this.familyList.selectedIndex >= 0 && this.sfmData.selectedIndex >= 0)
         {
            _loc1_ = this.sfmData.selectedItem.material;
            this.setFilters(false);
            _loc2_ = 0;
            while(_loc2_ < GWizMfgCutterSpecs.sfmExamples.length)
            {
               _loc3_ = GWizMfgCutterSpecs.sfmExamples.getItemAt(_loc2_);
               if(_loc3_.family == this.selectionText && _loc3_.material == _loc1_)
               {
                  GWizMfgCutterSpecs.sfmExamples.removeItemAt(_loc2_);
                  break;
               }
               _loc2_++;
            }
            this.setFilters(true);
            this.checkDupes();
         }
      }
      
      private function newIPTExample(param1:String = "") : void
      {
         var _loc2_:Object = {
            "family":"Lakeshore Carbide VFA - 1 Example",
            "material":"Aluminum - Wrought (6061)",
            "diameter":0,
            "chipload":0
         };
         if(param1 == "")
         {
            param1 = this.selectionText;
         }
         _loc2_.family = param1;
         this.setFilters(false);
         GWizMfgCutterSpecs.chiploadExamples.addItem(_loc2_);
         this.setFilters(true);
         this.checkDupes();
      }
      
      private function delIPTExample() : void
      {
         var _loc1_:String = null;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(this.familyList.selectedIndex >= 0 && this.iptData.selectedIndex >= 0)
         {
            _loc1_ = this.iptData.selectedItem.material;
            _loc2_ = this.iptData.selectedItem.diameter;
            this.setFilters(false);
            _loc3_ = 0;
            while(_loc3_ < GWizMfgCutterSpecs.chiploadExamples.length)
            {
               if((_loc4_ = GWizMfgCutterSpecs.chiploadExamples.getItemAt(_loc3_)).family == this.selectionText && _loc4_.material == _loc1_ && _loc4_.diameter == _loc2_)
               {
                  GWizMfgCutterSpecs.chiploadExamples.removeItemAt(_loc3_);
                  break;
               }
               _loc3_++;
            }
            this.setFilters(true);
            this.checkDupes();
         }
      }
      
      private function delFamily() : void
      {
         var _loc1_:* = 0;
         var _loc2_:String = null;
         if(this.familyList.selectedIndex >= 0 && this.selectionText != GWizMfgCutterSpecs.GENERIC_FAMILY)
         {
            _loc1_ = GWizPopUpManager.YES | GWizPopUpManager.CANCEL;
            _loc2_ = "Are you sure you want to delete the family and all its examples?";
            GWizPopUpManager.Show(_loc2_,"Delete Family?",_loc1_ | GWizPopUpManager.WARN,null,this.alertListener);
         }
      }
      
      private function alertListener(param1:CloseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(param1.detail == GWizPopUpManager.YES)
         {
            this.setFilters(false);
            _loc2_ = 0;
            while(_loc2_ < GWizMfgCutterSpecs.chiploadExamples.length)
            {
               _loc3_ = GWizMfgCutterSpecs.chiploadExamples.getItemAt(_loc2_);
               if(_loc3_.family == this.selectionText)
               {
                  GWizMfgCutterSpecs.chiploadExamples.removeItemAt(_loc2_);
                  _loc2_--;
               }
               _loc2_++;
            }
            _loc2_ = 0;
            while(_loc2_ < GWizMfgCutterSpecs.sfmExamples.length)
            {
               _loc3_ = GWizMfgCutterSpecs.sfmExamples.getItemAt(_loc2_);
               if(_loc3_.family == this.selectionText)
               {
                  GWizMfgCutterSpecs.sfmExamples.removeItemAt(_loc2_);
                  _loc2_--;
               }
               _loc2_++;
            }
            GWizMfgCutterSpecs.rebuildFamilyList();
            this.setFilters(true);
            this.checkDupes();
         }
      }
      
      private function doGetFamilyName() : void
      {
         var _loc1_:GWizGetFamilyName = GWizGetFamilyName(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizGetFamilyName,true));
         if(_loc1_)
         {
            _loc1_.okFunc = this.setNewFamilyName;
         }
      }
      
      private function setNewFamilyName(param1:String) : void
      {
         if(param1 == GWizMfgCutterSpecs.GENERIC_FAMILY)
         {
            return;
         }
         this.setFilters(false);
         this.newSFMExample(param1);
         this.newIPTExample(param1);
         GWizMfgCutterSpecs.rebuildFamilyList();
         this.familyList.selectedIndex = 0;
         this.setFilters(true);
         this.checkDupes();
      }
      
      private function checkDupes() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:String = "";
         this.sfmDupe.visible = false;
         this.iptDupe.visible = false;
         _loc3_ = new Object();
         _loc1_ = 0;
         while(_loc1_ < GWizMfgCutterSpecs.sfmExamples.length)
         {
            _loc2_ = GWizMfgCutterSpecs.sfmExamples.getItemAt(_loc1_);
            _loc4_ = sfmHash(_loc2_);
            if(_loc3_.hasOwnProperty(_loc4_))
            {
               this.sfmDupe.visible = true;
               _loc5_ = _loc2_.family;
               break;
            }
            _loc3_[_loc4_] = true;
            _loc1_++;
         }
         if(!this.sfmDupe.visible)
         {
            _loc3_ = new Object();
            _loc1_ = 0;
            while(_loc1_ < GWizMfgCutterSpecs.chiploadExamples.length)
            {
               _loc2_ = GWizMfgCutterSpecs.chiploadExamples.getItemAt(_loc1_);
               _loc4_ = iptHash(_loc2_);
               if(_loc3_.hasOwnProperty(_loc4_))
               {
                  this.iptDupe.visible = true;
                  _loc5_ = _loc2_.family;
                  break;
               }
               _loc3_[_loc4_] = true;
               _loc1_++;
            }
         }
         if(_loc5_ != "")
         {
            _loc1_ = 0;
            while(_loc1_ < GWizMfgCutterSpecs.familyListData.length)
            {
               _loc2_ = GWizMfgCutterSpecs.familyListData.getItemAt(_loc1_);
               if(_loc2_.label == _loc5_)
               {
                  this.familyList.selectedIndex = _loc1_;
                  break;
               }
               _loc1_++;
            }
         }
      }
      
      private function doImport() : void
      {
         var _loc1_:GWizCSVUtils = new GWizCSVUtils();
         _loc1_.importCSVData(importCSVToolFamily,this.familyFiles);
      }
      
      private function _GWizMfgFamilyPopup_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizGetFamilyName;
         _loc1_.properties = {"outerDocument":this};
         this._GWizMfgFamilyPopup_ClassFactory1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMfgFamilyPopup_ClassFactory1",this._GWizMfgFamilyPopup_ClassFactory1);
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMfgFamilyPopup_VGroup1_c(),this._GWizMfgFamilyPopup_VGroup2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizMfgFamilyPopup_List1_i(),this._GWizMfgFamilyPopup_Button1_i(),this._GWizMfgFamilyPopup_Button2_i(),this._GWizMfgFamilyPopup_Button3_i(),this._GWizMfgFamilyPopup_Label1_c(),this._GWizMfgFamilyPopup_Button4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_List1_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.labelField = "label";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("valueCommit",this.__familyList_valueCommit);
         _loc1_.id = "familyList";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.familyList = _loc1_;
         BindingManager.executeBindings(this,"familyList",this.familyList);
         return _loc1_;
      }
      
      public function __familyList_valueCommit(param1:FlexEvent) : void
      {
         this.setFamily();
      }
      
      private function _GWizMfgFamilyPopup_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "New...";
         _loc1_.addEventListener("click",this.___GWizMfgFamilyPopup_Button1_click);
         _loc1_.id = "_GWizMfgFamilyPopup_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMfgFamilyPopup_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMfgFamilyPopup_Button1",this._GWizMfgFamilyPopup_Button1);
         return _loc1_;
      }
      
      public function ___GWizMfgFamilyPopup_Button1_click(param1:MouseEvent) : void
      {
         this.doGetFamilyName();
      }
      
      private function _GWizMfgFamilyPopup_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Download...";
         _loc1_.toolTip = "Download latest Tool Families from CNCCookbook. Will not change families of same name already created.";
         _loc1_.addEventListener("click",this.___GWizMfgFamilyPopup_Button2_click);
         _loc1_.id = "_GWizMfgFamilyPopup_Button2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMfgFamilyPopup_Button2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMfgFamilyPopup_Button2",this._GWizMfgFamilyPopup_Button2);
         return _loc1_;
      }
      
      public function ___GWizMfgFamilyPopup_Button2_click(param1:MouseEvent) : void
      {
         doDownload(null);
      }
      
      private function _GWizMfgFamilyPopup_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Import...";
         _loc1_.addEventListener("click",this.___GWizMfgFamilyPopup_Button3_click);
         _loc1_.id = "_GWizMfgFamilyPopup_Button3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMfgFamilyPopup_Button3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMfgFamilyPopup_Button3",this._GWizMfgFamilyPopup_Button3);
         return _loc1_;
      }
      
      public function ___GWizMfgFamilyPopup_Button3_click(param1:MouseEvent) : void
      {
         this.doImport();
      }
      
      private function _GWizMfgFamilyPopup_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Button4_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Delete...";
         _loc1_.addEventListener("click",this.___GWizMfgFamilyPopup_Button4_click);
         _loc1_.id = "_GWizMfgFamilyPopup_Button4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMfgFamilyPopup_Button4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMfgFamilyPopup_Button4",this._GWizMfgFamilyPopup_Button4);
         return _loc1_;
      }
      
      public function ___GWizMfgFamilyPopup_Button4_click(param1:MouseEvent) : void
      {
         this.delFamily();
      }
      
      private function _GWizMfgFamilyPopup_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizMfgFamilyPopup_HGroup2_c(),this._GWizMfgFamilyPopup_Label3_c(),this._GWizMfgFamilyPopup_HGroup3_c(),this._GWizMfgFamilyPopup_DataGrid1_i(),this._GWizMfgFamilyPopup_Label5_c(),this._GWizMfgFamilyPopup_Label6_c(),this._GWizMfgFamilyPopup_HGroup4_c(),this._GWizMfgFamilyPopup_DataGrid2_i(),this._GWizMfgFamilyPopup_Label8_c()];
         _loc1_.id = "editPane";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.editPane = _loc1_;
         BindingManager.executeBindings(this,"editPane",this.editPane);
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMfgFamilyPopup_Label2_i(),this._GWizMfgFamilyPopup_Spacer1_c(),this._GWizMfgFamilyPopup_GWizLinkLabelURL1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "topLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.topLabel = _loc1_;
         BindingManager.executeBindings(this,"topLabel",this.topLabel);
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_GWizLinkLabelURL1_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Help";
         _loc1_.url = "http://www.cnccookbook.com/Slides/FineTuning/GWFineTuningToolData.html";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "HelpLink";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HelpLink = _loc1_;
         BindingManager.executeBindings(this,"HelpLink",this.HelpLink);
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Surface Speed Examples (displayed in current units, edited in Imperial)";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMfgFamilyPopup_Button5_i(),this._GWizMfgFamilyPopup_Label4_i(),this._GWizMfgFamilyPopup_Spacer2_c(),this._GWizMfgFamilyPopup_Button6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Button5_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "New...";
         _loc1_.addEventListener("click",this.__sfmNew_click);
         _loc1_.id = "sfmNew";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sfmNew = _loc1_;
         BindingManager.executeBindings(this,"sfmNew",this.sfmNew);
         return _loc1_;
      }
      
      public function __sfmNew_click(param1:MouseEvent) : void
      {
         this.newSFMExample();
      }
      
      private function _GWizMfgFamilyPopup_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Warning: Duplicate materials not allowed.";
         _loc1_.visible = false;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "sfmDupe";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sfmDupe = _loc1_;
         BindingManager.executeBindings(this,"sfmDupe",this.sfmDupe);
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Button6_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Delete...";
         _loc1_.addEventListener("click",this.__sfmDelete_click);
         _loc1_.id = "sfmDelete";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sfmDelete = _loc1_;
         BindingManager.executeBindings(this,"sfmDelete",this.sfmDelete);
         return _loc1_;
      }
      
      public function __sfmDelete_click(param1:MouseEvent) : void
      {
         this.delSFMExample();
      }
      
      private function _GWizMfgFamilyPopup_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.editable = true;
         _loc1_.sortableColumns = false;
         _loc1_.columns = this._GWizMfgFamilyPopup_ArrayList1_c();
         _loc1_.addEventListener("valueCommit",this.__sfmData_valueCommit);
         _loc1_.id = "sfmData";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sfmData = _loc1_;
         BindingManager.executeBindings(this,"sfmData",this.sfmData);
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizMfgFamilyPopup_GridColumn1_c(),this._GWizMfgFamilyPopup_GridColumn2_c()];
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Material";
         _loc1_.dataField = "material";
         _loc1_.itemEditor = this._GWizMfgFamilyPopup_ClassFactory2_c();
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_ClassFactory2_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizMfgFamilyPopupInnerClass0;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_GridColumn2_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Surface Speed";
         _loc1_.dataField = "sfm";
         _loc1_.labelFunction = GWizUtils.convUnitsFtMLabelFcn;
         _loc1_.itemEditor = this._GWizMfgFamilyPopup_ClassFactory3_c();
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_ClassFactory3_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizMfgFamilyPopupInnerClass1;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      public function __sfmData_valueCommit(param1:FlexEvent) : void
      {
         this.checkDupes();
      }
      
      private function _GWizMfgFamilyPopup_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Chipload Examples (displayed in current units, edited in Imperial)";
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMfgFamilyPopup_Button7_i(),this._GWizMfgFamilyPopup_Label7_i(),this._GWizMfgFamilyPopup_Spacer3_c(),this._GWizMfgFamilyPopup_Button8_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Button7_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "New...";
         _loc1_.addEventListener("click",this.__iptNew_click);
         _loc1_.id = "iptNew";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.iptNew = _loc1_;
         BindingManager.executeBindings(this,"iptNew",this.iptNew);
         return _loc1_;
      }
      
      public function __iptNew_click(param1:MouseEvent) : void
      {
         this.newIPTExample();
      }
      
      private function _GWizMfgFamilyPopup_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Warning: Only 1 entry for each Material and Diameter.";
         _loc1_.visible = false;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "iptDupe";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.iptDupe = _loc1_;
         BindingManager.executeBindings(this,"iptDupe",this.iptDupe);
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_Button8_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Delete...";
         _loc1_.addEventListener("click",this.__iptDelete_click);
         _loc1_.id = "iptDelete";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.iptDelete = _loc1_;
         BindingManager.executeBindings(this,"iptDelete",this.iptDelete);
         return _loc1_;
      }
      
      public function __iptDelete_click(param1:MouseEvent) : void
      {
         this.delIPTExample();
      }
      
      private function _GWizMfgFamilyPopup_DataGrid2_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.editable = true;
         _loc1_.sortableColumns = false;
         _loc1_.columns = this._GWizMfgFamilyPopup_ArrayList2_c();
         _loc1_.addEventListener("valueCommit",this.__iptData_valueCommit);
         _loc1_.id = "iptData";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.iptData = _loc1_;
         BindingManager.executeBindings(this,"iptData",this.iptData);
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_ArrayList2_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizMfgFamilyPopup_GridColumn3_c(),this._GWizMfgFamilyPopup_GridColumn4_c(),this._GWizMfgFamilyPopup_GridColumn5_c()];
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_GridColumn3_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Material";
         _loc1_.dataField = "material";
         _loc1_.itemEditor = this._GWizMfgFamilyPopup_ClassFactory4_c();
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_ClassFactory4_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizMfgFamilyPopupInnerClass2;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_GridColumn4_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Diameter";
         _loc1_.dataField = "diameter";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.itemEditor = this._GWizMfgFamilyPopup_ClassFactory5_c();
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_ClassFactory5_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizMfgFamilyPopupInnerClass3;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_GridColumn5_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Chipload";
         _loc1_.dataField = "chipload";
         _loc1_.labelFunction = GWizUtils.convUnitsInMMLabelFcn;
         _loc1_.itemEditor = this._GWizMfgFamilyPopup_ClassFactory6_c();
         return _loc1_;
      }
      
      private function _GWizMfgFamilyPopup_ClassFactory6_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizMfgFamilyPopupInnerClass4;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      public function __iptData_valueCommit(param1:FlexEvent) : void
      {
         this.checkDupes();
      }
      
      private function _GWizMfgFamilyPopup_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Each example helps G-Wizard learn about this Family of cutters.  Double click to edit examples.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizMfgFamilyPopup_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizMfgFamilyPopup_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizMfgCutterSpecs.familyListData;
         },null,"familyList.dataProvider");
         result[1] = new Binding(this,function():Number
         {
            return familyList.width;
         },null,"_GWizMfgFamilyPopup_Button1.width");
         result[2] = new Binding(this,function():Number
         {
            return familyList.width;
         },null,"_GWizMfgFamilyPopup_Button2.width");
         result[3] = new Binding(this,function():Number
         {
            return familyList.width;
         },null,"_GWizMfgFamilyPopup_Button3.width");
         result[4] = new Binding(this,function():Number
         {
            return familyList.width;
         },null,"_GWizMfgFamilyPopup_Button4.width");
         result[5] = new Binding(this,function():uint
         {
            return ColorPalette.secondaryb1;
         },function(param1:uint):void
         {
            sfmDupe.setStyle("color",param1);
         },"sfmDupe.color");
         result[6] = new Binding(this,function():IList
         {
            return GWizMfgCutterSpecs.sfmExamples;
         },null,"sfmData.dataProvider");
         result[7] = new Binding(this,function():uint
         {
            return ColorPalette.secondaryb1;
         },function(param1:uint):void
         {
            iptDupe.setStyle("color",param1);
         },"iptDupe.color");
         result[8] = new Binding(this,function():IList
         {
            return GWizMfgCutterSpecs.chiploadExamples;
         },null,"iptData.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get HelpLink() : GWizLinkLabelURL
      {
         return this._725364997HelpLink;
      }
      
      public function set HelpLink(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._725364997HelpLink;
         if(_loc2_ !== param1)
         {
            this._725364997HelpLink = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HelpLink",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get editPane() : VGroup
      {
         return this._1601908882editPane;
      }
      
      public function set editPane(param1:VGroup) : void
      {
         var _loc2_:Object = this._1601908882editPane;
         if(_loc2_ !== param1)
         {
            this._1601908882editPane = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"editPane",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get familyList() : List
      {
         return this._798502434familyList;
      }
      
      public function set familyList(param1:List) : void
      {
         var _loc2_:Object = this._798502434familyList;
         if(_loc2_ !== param1)
         {
            this._798502434familyList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"familyList",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get iptData() : DataGrid
      {
         return this._2014322039iptData;
      }
      
      public function set iptData(param1:DataGrid) : void
      {
         var _loc2_:Object = this._2014322039iptData;
         if(_loc2_ !== param1)
         {
            this._2014322039iptData = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"iptData",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get iptDelete() : Button
      {
         return this._1263307720iptDelete;
      }
      
      public function set iptDelete(param1:Button) : void
      {
         var _loc2_:Object = this._1263307720iptDelete;
         if(_loc2_ !== param1)
         {
            this._1263307720iptDelete = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"iptDelete",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get iptDupe() : Label
      {
         return this._2014341139iptDupe;
      }
      
      public function set iptDupe(param1:Label) : void
      {
         var _loc2_:Object = this._2014341139iptDupe;
         if(_loc2_ !== param1)
         {
            this._2014341139iptDupe = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"iptDupe",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get iptNew() : Button
      {
         return this._1181938125iptNew;
      }
      
      public function set iptNew(param1:Button) : void
      {
         var _loc2_:Object = this._1181938125iptNew;
         if(_loc2_ !== param1)
         {
            this._1181938125iptNew = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"iptNew",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sfmData() : DataGrid
      {
         return this._2006668100sfmData;
      }
      
      public function set sfmData(param1:DataGrid) : void
      {
         var _loc2_:Object = this._2006668100sfmData;
         if(_loc2_ !== param1)
         {
            this._2006668100sfmData = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sfmData",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sfmDelete() : Button
      {
         return this._28808507sfmDelete;
      }
      
      public function set sfmDelete(param1:Button) : void
      {
         var _loc2_:Object = this._28808507sfmDelete;
         if(_loc2_ !== param1)
         {
            this._28808507sfmDelete = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sfmDelete",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sfmDupe() : Label
      {
         return this._2006687200sfmDupe;
      }
      
      public function set sfmDupe(param1:Label) : void
      {
         var _loc2_:Object = this._2006687200sfmDupe;
         if(_loc2_ !== param1)
         {
            this._2006687200sfmDupe = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sfmDupe",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sfmNew() : Button
      {
         return this._905090362sfmNew;
      }
      
      public function set sfmNew(param1:Button) : void
      {
         var _loc2_:Object = this._905090362sfmNew;
         if(_loc2_ !== param1)
         {
            this._905090362sfmNew = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sfmNew",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get topLabel() : Label
      {
         return this._984130913topLabel;
      }
      
      public function set topLabel(param1:Label) : void
      {
         var _loc2_:Object = this._984130913topLabel;
         if(_loc2_ !== param1)
         {
            this._984130913topLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"topLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get matList() : ArrayCollection
      {
         return this._840178206matList;
      }
      
      public function set matList(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._840178206matList;
         if(_loc2_ !== param1)
         {
            this._840178206matList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"matList",_loc2_,param1));
            }
         }
      }
   }
}
