package feedsspeeds
{
   import comps.GWizFileBrowser;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import localdb.GWizCutKB;
   import localdb.GWizCutKBSQL;
   import material.GWizMaterialsDB;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.List;
   import spark.components.Scroller;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import utils.GWizCSVUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizCutKBSearch extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizCutKBSearch");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _355627065CutDepthCheck:CheckBox;
      
      private var _2126812836CutWidthCheck:CheckBox;
      
      private var _1103581013FlutesCheck:CheckBox;
      
      private var _2228070Grid:List;
      
      private var _587793354Keywords:TextInput;
      
      private var _1175867668LeadCheck:CheckBox;
      
      private var _1976408353MachineCheck:CheckBox;
      
      private var _376381439MaterialCheck:CheckBox;
      
      private var _1433872074StickoutCheck:CheckBox;
      
      private var _2117081148ToolDiaCheck:CheckBox;
      
      private var _872346858ToolTypeCheck:CheckBox;
      
      private var _1896964063advSearchBtn:Button;
      
      private var _35721419listHeader:HGroup;
      
      private var _2000992631numRecs:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1880932050searchResults:ArrayCollection = null;
      
      private var cutKBFieldList:Array;
      
      private var cutKBFiles:GWizFileBrowser;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCutKBSearch()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.cutKBFieldList = ["description","cutType","rough","rating","mrr","mrrPct","rpm","rpmPct","ipm","ipmPct","chatter","wear","comments","sfm","sfmPct","ipt","iptPct","cutDepth","cutWidth","tea","material","hardness","machine","holder","coolant","tool","crib","flutes","ballnose","leadang","Rougher","toolDia","stickout","noseRad","id"];
         this.cutKBFiles = new GWizFileBrowser("CutKBExports","CSV","*.csv");
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCutKBSearch_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizCutKBSearchWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCutKBSearch[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.fullScreen = true;
         this.mxmlContent = [this._GWizCutKBSearch_VGroup1_c()];
         this.addEventListener("creationComplete",this.___GWizCutKBSearch_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCutKBSearch._watcherSetupUtil = param1;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         var factory:IFlexModuleFactory = param1;
         super.moduleFactory = factory;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
         if(!this.styleDeclaration)
         {
            this.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
         }
         this.styleDeclaration.defaultFactory = function():void
         {
            this.color = 16777215;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onCC() : void
      {
         this.refreshGrid();
      }
      
      private function keywordFilter(param1:Object) : Boolean
      {
         var _loc6_:String = null;
         var _loc2_:String = param1.description + " " + param1.comments + " " + param1.machine + " " + param1.tool + " " + param1.crib;
         _loc2_ += " " + GWizMaterialsDB.MaterialsList[param1.material];
         _loc2_ += " " + GWizCutType.CutTypes[param1.cutType].op;
         _loc2_ += " " + GWizConfigData.ToolWear[param1.wear];
         _loc2_ += " " + GWizConfigData.HolderTypes[param1.holder];
         _loc2_ += " " + GWizConfigData.CoolantTypes[param1.coolant];
         var _loc3_:Array = this.Keywords.text.split(" ");
         var _loc4_:Boolean = true;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc5_];
            if(!(_loc4_ = _loc4_ && _loc2_.search(_loc6_) != -1))
            {
               break;
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function refreshGrid() : void
      {
         var _loc1_:Number = GWizSettings.cutKBSQL.countRows();
         this.searchResults = GWizSettings.cutKBSQL.filterList(this.Keywords.text,this.MaterialCheck.selected,this.MachineCheck.selected,this.ToolTypeCheck.selected,this.ToolDiaCheck.selected,this.FlutesCheck.selected,this.LeadCheck.selected,this.StickoutCheck.selected,this.CutDepthCheck.selected,this.CutWidthCheck.selected);
         if(this.searchResults)
         {
            if(this.Keywords.text.length > 0)
            {
               this.searchResults.filterFunction = this.keywordFilter;
               this.searchResults.refresh();
            }
            this.numRecs.text = this.searchResults.length + " of " + String(_loc1_);
            this.Grid.dataProvider = this.searchResults;
         }
         else
         {
            log.debug("filterList returned null in refreshGrid.");
            GWizUtils.assert(false);
         }
      }
      
      private function doAdvSearch() : void
      {
         GWizPopUpManager.Show("We\'re waiting on feedback from you so we know what you can\'t do with the regular search.  Drop us a note to sales@cnccookbook.com with suggestions.","GWizard");
      }
      
      private function selectGridRow() : void
      {
         var _loc1_:Object = this.Grid.selectedItem;
         if(!_loc1_)
         {
            return;
         }
         GWizCutKBSQL.activeRec.mrr = _loc1_.mrr;
         GWizCutKBSQL.activeRec.mrrPct = _loc1_.mrrPct;
         GWizCutKBSQL.activeRec.rpm = _loc1_.rpm;
         GWizCutKBSQL.activeRec.rpmPct = _loc1_.rpmPct;
         GWizCutKBSQL.activeRec.ipm = _loc1_.ipm;
         GWizCutKBSQL.activeRec.ipmPct = _loc1_.ipmPct;
         GWizCutKBSQL.activeRec.sfm = _loc1_.sfm;
         GWizCutKBSQL.activeRec.sfmPct = _loc1_.sfmPct;
         GWizCutKBSQL.activeRec.ipt = _loc1_.ipt;
         GWizCutKBSQL.activeRec.iptPct = _loc1_.iptPct;
         GWizCutKBSQL.activeRec.machine = _loc1_.machine;
         GWizCutKBSQL.activeRec.tool = _loc1_.tool;
         GWizCutKBSQL.activeRec.crib = _loc1_.crib;
         GWizCutKBSQL.activeRec.toolDia = _loc1_.toolDia;
         GWizCutKBSQL.activeRec.flutes = _loc1_.flutes;
         GWizCutKBSQL.activeRec.geometry = _loc1_.geometry;
         GWizCutKBSQL.activeRec.stickout = _loc1_.stickout;
         GWizCutKBSQL.activeRec.leadAng = _loc1_.leadAng;
         GWizCutKBSQL.activeRec.noseRad = _loc1_.noseRad;
         GWizCutKBSQL.activeRec.material = _loc1_.material;
         GWizCutKBSQL.activeRec.hardness = _loc1_.hardness;
         GWizCutKBSQL.activeRec.cutDepth = _loc1_.cutDepth;
         GWizCutKBSQL.activeRec.cutWidth = _loc1_.cutWidth;
         GWizCutKBSQL.activeRec.tea = _loc1_.tea;
         GWizCutKBSQL.activeRec.description = _loc1_.description;
         GWizCutKBSQL.activeRec.rating = _loc1_.rating;
         GWizCutKBSQL.activeRec.comments = _loc1_.comments;
         GWizCutKBSQL.activeRec.wear = _loc1_.wear;
         GWizCutKBSQL.activeRec.chatter = _loc1_.chatter;
         GWizCutKBSQL.activeRec.cutType = GWizCutKB.encodeCutType(_loc1_.cutType,GWizCutKBSQL.activeRec.machine);
         GWizCutKBSQL.activeRec.rough = _loc1_.rough;
         GWizCutKBSQL.activeRec.holder = _loc1_.holder;
         GWizCutKBSQL.activeRec.coolant = _loc1_.coolant;
         if(_loc1_.id != -1)
         {
            GWizCutKBSQL.activeRec.id = _loc1_.id;
         }
      }
      
      private function doFeedsSpeeds() : void
      {
         this.selectGridRow();
         GWizSettings.FeedsSpeedsApp.grabCutKBActiveRec();
         this.close();
      }
      
      private function doEdit() : void
      {
         this.selectGridRow();
         var _loc1_:GWizCutKB = GWizCutKBSQL.activeRec;
         var _loc2_:GWizCutKBEditAR = GWizCutKBEditAR(GWizPopUpManager.createPopUp(this,GWizCutKBEditAR,true));
         if(_loc2_)
         {
            _loc2_.inputsReady(_loc1_,GWizSettings.FeedsSpeedsApp.MRR.labTxt + ": ","RPM: ",GWizSettings.FeedsSpeedsApp.IPM.titleTxt + ": ",GWizSettings.FeedsSpeedsApp.SFM.titleTxt + ": ",GWizSettings.FeedsSpeedsApp.IPT.titleTxt + ": ",GWizSettings.materialSelection);
            _loc2_.refresh = this.refreshGrid;
         }
      }
      
      private function doLast() : void
      {
         if(this.searchResults)
         {
            this.Grid.selectedIndex = this.searchResults.length;
         }
      }
      
      private function doExport() : void
      {
         var _loc4_:Object = null;
         var _loc1_:GWizCSVUtils = new GWizCSVUtils();
         var _loc2_:ArrayCollection = new ArrayCollection();
         var _loc3_:int = 0;
         while(_loc3_ < this.searchResults.length)
         {
            (_loc4_ = GWizUtils.clone(this.searchResults.getItemAt(_loc3_))).material = GWizMaterialsDB.MaterialsList[_loc4_.material];
            _loc4_.holder = GWizConfigData.HolderTypes[_loc4_.holder];
            _loc4_.coolant = GWizConfigData.CoolantTypes[_loc4_.coolant];
            _loc4_.cutType = GWizCutType.CutTypeToString(_loc4_.cutType);
            _loc2_.addItem(_loc4_);
            _loc3_++;
         }
         _loc1_.exportCSVData(_loc2_,this.cutKBFieldList,this.cutKBFiles);
      }
      
      private function showAll() : void
      {
         this.MaterialCheck.selected = false;
         this.MachineCheck.selected = false;
         this.ToolTypeCheck.selected = false;
         this.ToolDiaCheck.selected = false;
         this.FlutesCheck.selected = false;
         this.LeadCheck.selected = false;
         this.StickoutCheck.selected = false;
         this.CutDepthCheck.selected = false;
         this.CutWidthCheck.selected = false;
         this.refreshGrid();
      }
      
      private function _GWizCutKBSearch_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "top";
         _loc1_.mxmlContent = [this._GWizCutKBSearch_HGroup1_c(),this._GWizCutKBSearch_Label2_c(),this._GWizCutKBSearch_HGroup2_c(),this._GWizCutKBSearch_HGroup3_c(),this._GWizCutKBSearch_HGroup4_c(),this._GWizCutKBSearch_Scroller1_c(),this._GWizCutKBSearch_HGroup6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCutKBSearch_Label1_c(),this._GWizCutKBSearch_TextInput1_i(),this._GWizCutKBSearch_Button1_c(),this._GWizCutKBSearch_Button2_c(),this._GWizCutKBSearch_Button3_i(),this._GWizCutKBSearch_Spacer1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Keywords:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Search keywords. Blank matches everything otherwise match keywords against text fields. All keywords must be found to match.";
         _loc1_.id = "Keywords";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Keywords = _loc1_;
         BindingManager.executeBindings(this,"Keywords",this.Keywords);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 30;
         _loc1_.label = "Search KB";
         _loc1_.addEventListener("click",this.___GWizCutKBSearch_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCutKBSearch_Button1_click(param1:MouseEvent) : void
      {
         this.refreshGrid();
      }
      
      private function _GWizCutKBSearch_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 30;
         _loc1_.label = "Show All";
         _loc1_.addEventListener("click",this.___GWizCutKBSearch_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCutKBSearch_Button2_click(param1:MouseEvent) : void
      {
         this.showAll();
      }
      
      private function _GWizCutKBSearch_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 30;
         _loc1_.label = "Advanced";
         _loc1_.toolTip = "Advanced Search";
         _loc1_.visible = false;
         _loc1_.addEventListener("click",this.__advSearchBtn_click);
         _loc1_.id = "advSearchBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.advSearchBtn = _loc1_;
         BindingManager.executeBindings(this,"advSearchBtn",this.advSearchBtn);
         return _loc1_;
      }
      
      public function __advSearchBtn_click(param1:MouseEvent) : void
      {
         this.doAdvSearch();
      }
      
      private function _GWizCutKBSearch_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Match Feeds and Speeds Page on:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCutKBSearch_CheckBox1_i(),this._GWizCutKBSearch_CheckBox2_i(),this._GWizCutKBSearch_CheckBox3_i(),this._GWizCutKBSearch_CheckBox4_i(),this._GWizCutKBSearch_CheckBox5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Material";
         _loc1_.selected = true;
         _loc1_.toolTip = "If checked, match Feeds and Speeds Material on search.";
         _loc1_.id = "MaterialCheck";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MaterialCheck = _loc1_;
         BindingManager.executeBindings(this,"MaterialCheck",this.MaterialCheck);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Machine";
         _loc1_.selected = true;
         _loc1_.toolTip = "If checked, match Feeds and Speeds Machine on search.";
         _loc1_.id = "MachineCheck";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MachineCheck = _loc1_;
         BindingManager.executeBindings(this,"MachineCheck",this.MachineCheck);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_CheckBox3_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Tool Type";
         _loc1_.selected = true;
         _loc1_.toolTip = "If checked, match Feeds and Speeds Tool Type (choice and crib) on search.";
         _loc1_.id = "ToolTypeCheck";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolTypeCheck = _loc1_;
         BindingManager.executeBindings(this,"ToolTypeCheck",this.ToolTypeCheck);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_CheckBox4_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Tool Dia.";
         _loc1_.selected = true;
         _loc1_.toolTip = "If checked, match Feeds and Speeds Tool Diameter on search.";
         _loc1_.id = "ToolDiaCheck";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolDiaCheck = _loc1_;
         BindingManager.executeBindings(this,"ToolDiaCheck",this.ToolDiaCheck);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_CheckBox5_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Flutes";
         _loc1_.selected = true;
         _loc1_.toolTip = "If checked, match Feeds and Flutes on search.";
         _loc1_.id = "FlutesCheck";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FlutesCheck = _loc1_;
         BindingManager.executeBindings(this,"FlutesCheck",this.FlutesCheck);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCutKBSearch_CheckBox6_i(),this._GWizCutKBSearch_CheckBox7_i(),this._GWizCutKBSearch_CheckBox8_i(),this._GWizCutKBSearch_CheckBox9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_CheckBox6_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Lead";
         _loc1_.selected = true;
         _loc1_.toolTip = "If checked, match Feeds and Speeds Lead Angle on search.";
         _loc1_.id = "LeadCheck";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LeadCheck = _loc1_;
         BindingManager.executeBindings(this,"LeadCheck",this.LeadCheck);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_CheckBox7_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Stickout";
         _loc1_.selected = true;
         _loc1_.toolTip = "If checked, match Feeds and Speeds Stickout on search.";
         _loc1_.id = "StickoutCheck";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.StickoutCheck = _loc1_;
         BindingManager.executeBindings(this,"StickoutCheck",this.StickoutCheck);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_CheckBox8_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Cut Depth";
         _loc1_.toolTip = "If checked, match Feeds and Speeds Cut Depth on search.";
         _loc1_.id = "CutDepthCheck";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CutDepthCheck = _loc1_;
         BindingManager.executeBindings(this,"CutDepthCheck",this.CutDepthCheck);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_CheckBox9_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Cut Width";
         _loc1_.toolTip = "If checked, match Feeds and Speeds Cut Width on search.";
         _loc1_.id = "CutWidthCheck";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CutWidthCheck = _loc1_;
         BindingManager.executeBindings(this,"CutWidthCheck",this.CutWidthCheck);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCutKBSearch_Label3_c(),this._GWizCutKBSearch_Spacer2_c(),this._GWizCutKBSearch_Button4_c(),this._GWizCutKBSearch_Button5_c(),this._GWizCutKBSearch_Label4_i(),this._GWizCutKBSearch_Label5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Results:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 14;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Button4_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 30;
         _loc1_.label = "First";
         _loc1_.addEventListener("click",this.___GWizCutKBSearch_Button4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCutKBSearch_Button4_click(param1:MouseEvent) : void
      {
         this.Grid.selectedIndex = 0;
      }
      
      private function _GWizCutKBSearch_Button5_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 30;
         _loc1_.label = "Last";
         _loc1_.addEventListener("click",this.___GWizCutKBSearch_Button5_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCutKBSearch_Button5_click(param1:MouseEvent) : void
      {
         this.doLast();
      }
      
      private function _GWizCutKBSearch_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0";
         _loc1_.id = "numRecs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.numRecs = _loc1_;
         BindingManager.executeBindings(this,"numRecs",this.numRecs);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Matching Entries";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Scroller1_c() : Scroller
      {
         var _loc1_:Scroller = new Scroller();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.styleName = "fontSizeDelta-2";
         _loc1_.viewport = this._GWizCutKBSearch_VGroup2_c();
         _loc1_.setStyle("horizontalScrollPolicy","on");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizCutKBSearch_HGroup5_i(),this._GWizCutKBSearch_List1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_HGroup5_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizCutKBSearch_Label6_c(),this._GWizCutKBSearch_Label7_c(),this._GWizCutKBSearch_Label8_c(),this._GWizCutKBSearch_Label9_c(),this._GWizCutKBSearch_Label10_c(),this._GWizCutKBSearch_Label11_c(),this._GWizCutKBSearch_Label12_c(),this._GWizCutKBSearch_Label13_c(),this._GWizCutKBSearch_Label14_c(),this._GWizCutKBSearch_Label15_c(),this._GWizCutKBSearch_Label16_c(),this._GWizCutKBSearch_Label17_c(),this._GWizCutKBSearch_Label18_c(),this._GWizCutKBSearch_Label19_c(),this._GWizCutKBSearch_Label20_c(),this._GWizCutKBSearch_Label21_c(),this._GWizCutKBSearch_Label22_c(),this._GWizCutKBSearch_Label23_c(),this._GWizCutKBSearch_Label24_c(),this._GWizCutKBSearch_Label25_c(),this._GWizCutKBSearch_Label26_c(),this._GWizCutKBSearch_Label27_c(),this._GWizCutKBSearch_Label28_c(),this._GWizCutKBSearch_Label29_c(),this._GWizCutKBSearch_Label30_c(),this._GWizCutKBSearch_Label31_c(),this._GWizCutKBSearch_Label32_c(),this._GWizCutKBSearch_Label33_c(),this._GWizCutKBSearch_Label34_c(),this._GWizCutKBSearch_Label35_c(),this._GWizCutKBSearch_Label36_c(),this._GWizCutKBSearch_Label37_c(),this._GWizCutKBSearch_Label38_c(),this._GWizCutKBSearch_Label39_c(),this._GWizCutKBSearch_Label40_c()];
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "listHeader";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.listHeader = _loc1_;
         BindingManager.executeBindings(this,"listHeader",this.listHeader);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Description";
         _loc1_.width = 200;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","left");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cut Type";
         _loc1_.width = 100;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","left");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Rough";
         _loc1_.width = 60;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","left");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Rating";
         _loc1_.width = 70;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","center");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "MRR";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label11_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "MRR %";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "RPM";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "RPM %";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label14_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "IPM";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label15_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "IPM %";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label16_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Chatter";
         _loc1_.width = 55;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label17_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Wear";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","center");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label18_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Comments";
         _loc1_.width = 300;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","left");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label19_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "SFM";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label20_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "SFM %";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label21_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "IPT";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label22_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "IPT %";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label23_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cut Depth";
         _loc1_.width = 70;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label24_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cut Width";
         _loc1_.width = 70;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label25_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "TEA";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","center");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label26_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Material";
         _loc1_.width = 250;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","left");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label27_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "BHN";
         _loc1_.width = 50;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","center");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label28_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Machine";
         _loc1_.width = 250;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","left");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label29_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Holder";
         _loc1_.width = 100;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","left");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label30_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Coolant";
         _loc1_.width = 80;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","left");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label31_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Type";
         _loc1_.width = 100;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","left");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label32_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Crib";
         _loc1_.width = 150;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","left");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label33_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Flutes";
         _loc1_.width = 60;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","center");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label34_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Geometry";
         _loc1_.width = 100;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","center");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label35_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Lead";
         _loc1_.width = 60;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label36_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Rougher";
         _loc1_.width = 60;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label37_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Diameter";
         _loc1_.width = 80;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label38_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Stickout";
         _loc1_.width = 80;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label39_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Nose Rad.";
         _loc1_.width = 80;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Label40_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "ID";
         _loc1_.width = 80;
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_List1_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.percentHeight = 100;
         _loc1_.itemRenderer = this._GWizCutKBSearch_ClassFactory1_c();
         _loc1_.setStyle("horizontalScrollPolicy","off");
         _loc1_.setStyle("alternatingItemColors",[16711422,15790320]);
         _loc1_.setStyle("borderColor",2236962);
         _loc1_.id = "Grid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Grid = _loc1_;
         BindingManager.executeBindings(this,"Grid",this.Grid);
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_ClassFactory1_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizCutKBSearchInnerClass0;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizCutKBSearch_Button6_c(),this._GWizCutKBSearch_Button7_c(),this._GWizCutKBSearch_Button8_c(),this._GWizCutKBSearch_Spacer3_c(),this._GWizCutKBSearch_Button9_c(),this._GWizCutKBSearch_Spacer4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Button6_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 30;
         _loc1_.label = "Edit";
         _loc1_.addEventListener("click",this.___GWizCutKBSearch_Button6_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCutKBSearch_Button6_click(param1:MouseEvent) : void
      {
         this.doEdit();
      }
      
      private function _GWizCutKBSearch_Button7_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 30;
         _loc1_.label = "Save to Feeds & Speeds";
         _loc1_.toolTip = "Save currently selected Cut KB record values to Feeds and Speeds.";
         _loc1_.addEventListener("click",this.___GWizCutKBSearch_Button7_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCutKBSearch_Button7_click(param1:MouseEvent) : void
      {
         this.doFeedsSpeeds();
      }
      
      private function _GWizCutKBSearch_Button8_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 30;
         _loc1_.label = "Export";
         _loc1_.toolTip = "Export the results to a CSV file.";
         _loc1_.addEventListener("click",this.___GWizCutKBSearch_Button8_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCutKBSearch_Button8_click(param1:MouseEvent) : void
      {
         this.doExport();
      }
      
      private function _GWizCutKBSearch_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Button9_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 30;
         _loc1_.label = "Del Results";
         _loc1_.toolTip = "Delete all the Cut KB records shown in results.";
         _loc1_.visible = false;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearch_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCutKBSearch_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCutKBSearch_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return listHeader.width;
         },null,"Grid.width");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CutDepthCheck() : CheckBox
      {
         return this._355627065CutDepthCheck;
      }
      
      public function set CutDepthCheck(param1:CheckBox) : void
      {
         var _loc2_:Object = this._355627065CutDepthCheck;
         if(_loc2_ !== param1)
         {
            this._355627065CutDepthCheck = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CutDepthCheck",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CutWidthCheck() : CheckBox
      {
         return this._2126812836CutWidthCheck;
      }
      
      public function set CutWidthCheck(param1:CheckBox) : void
      {
         var _loc2_:Object = this._2126812836CutWidthCheck;
         if(_loc2_ !== param1)
         {
            this._2126812836CutWidthCheck = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CutWidthCheck",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FlutesCheck() : CheckBox
      {
         return this._1103581013FlutesCheck;
      }
      
      public function set FlutesCheck(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1103581013FlutesCheck;
         if(_loc2_ !== param1)
         {
            this._1103581013FlutesCheck = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FlutesCheck",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Grid() : List
      {
         return this._2228070Grid;
      }
      
      public function set Grid(param1:List) : void
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
      public function get Keywords() : TextInput
      {
         return this._587793354Keywords;
      }
      
      public function set Keywords(param1:TextInput) : void
      {
         var _loc2_:Object = this._587793354Keywords;
         if(_loc2_ !== param1)
         {
            this._587793354Keywords = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Keywords",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LeadCheck() : CheckBox
      {
         return this._1175867668LeadCheck;
      }
      
      public function set LeadCheck(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1175867668LeadCheck;
         if(_loc2_ !== param1)
         {
            this._1175867668LeadCheck = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LeadCheck",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MachineCheck() : CheckBox
      {
         return this._1976408353MachineCheck;
      }
      
      public function set MachineCheck(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1976408353MachineCheck;
         if(_loc2_ !== param1)
         {
            this._1976408353MachineCheck = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MachineCheck",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MaterialCheck() : CheckBox
      {
         return this._376381439MaterialCheck;
      }
      
      public function set MaterialCheck(param1:CheckBox) : void
      {
         var _loc2_:Object = this._376381439MaterialCheck;
         if(_loc2_ !== param1)
         {
            this._376381439MaterialCheck = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MaterialCheck",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get StickoutCheck() : CheckBox
      {
         return this._1433872074StickoutCheck;
      }
      
      public function set StickoutCheck(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1433872074StickoutCheck;
         if(_loc2_ !== param1)
         {
            this._1433872074StickoutCheck = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"StickoutCheck",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolDiaCheck() : CheckBox
      {
         return this._2117081148ToolDiaCheck;
      }
      
      public function set ToolDiaCheck(param1:CheckBox) : void
      {
         var _loc2_:Object = this._2117081148ToolDiaCheck;
         if(_loc2_ !== param1)
         {
            this._2117081148ToolDiaCheck = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolDiaCheck",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolTypeCheck() : CheckBox
      {
         return this._872346858ToolTypeCheck;
      }
      
      public function set ToolTypeCheck(param1:CheckBox) : void
      {
         var _loc2_:Object = this._872346858ToolTypeCheck;
         if(_loc2_ !== param1)
         {
            this._872346858ToolTypeCheck = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolTypeCheck",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get advSearchBtn() : Button
      {
         return this._1896964063advSearchBtn;
      }
      
      public function set advSearchBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1896964063advSearchBtn;
         if(_loc2_ !== param1)
         {
            this._1896964063advSearchBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"advSearchBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get listHeader() : HGroup
      {
         return this._35721419listHeader;
      }
      
      public function set listHeader(param1:HGroup) : void
      {
         var _loc2_:Object = this._35721419listHeader;
         if(_loc2_ !== param1)
         {
            this._35721419listHeader = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"listHeader",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get numRecs() : Label
      {
         return this._2000992631numRecs;
      }
      
      public function set numRecs(param1:Label) : void
      {
         var _loc2_:Object = this._2000992631numRecs;
         if(_loc2_ !== param1)
         {
            this._2000992631numRecs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"numRecs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get searchResults() : ArrayCollection
      {
         return this._1880932050searchResults;
      }
      
      private function set searchResults(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._1880932050searchResults;
         if(_loc2_ !== param1)
         {
            this._1880932050searchResults = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"searchResults",_loc2_,param1));
            }
         }
      }
   }
}
