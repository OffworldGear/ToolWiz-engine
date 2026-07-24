package feedsspeeds
{
   import comps.GWizPanel;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import comps.Rating;
   import comps.skins.PanelSkin;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import localdb.GWizCutKB;
   import localdb.GWizCutKBSQL;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.CloseEvent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColorStroke;
   import spark.components.Button;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.TextArea;
   import spark.components.TextInput;
   import spark.primitives.Line;
   import tools.GWizToolDef;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizCutKBEditAR extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1891179095Chatter:NumericStepper;
      
      private var _537771500Comments:TextInput;
      
      private var _1678102050Coolant:DropDownList;
      
      private var _56677412Description:TextArea;
      
      private var _2127840820Holder:DropDownList;
      
      private var _2331ID:Label;
      
      private var _72710IPM:Label;
      
      private var _72717IPT:Label;
      
      private var _76621MRR:Label;
      
      private var _1805001689Machine:Label;
      
      private var _1790377999MatDesc:TextArea;
      
      private var _81359RPM:Label;
      
      private var _1854235203Rating:Rating;
      
      private var _82010SFM:Label;
      
      private var _919423895ToolDesc:TextArea;
      
      private var _2691999Wear:DropDownList;
      
      private var _1127912604cutType:GWizCutType;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var oldActiveRec:GWizCutKB;
      
      public var refresh:Function = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCutKBEditAR()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCutKBEditAR_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizCutKBEditARWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCutKBEditAR[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.okLabel = "Save";
         this.cancelLabel = "Cancel";
         this.gap = 10;
         this.height = 340;
         this.title = "Add Cut KB Entry: Beta Test";
         this.horizontalAlign = "center";
         this.mxmlContent = [this._GWizCutKBEditAR_HGroup1_c(),this._GWizCutKBEditAR_HGroup2_c(),this._GWizCutKBEditAR_HGroup3_c(),this._GWizCutKBEditAR_Line1_c(),this._GWizCutKBEditAR_GWizCutType1_i(),this._GWizCutKBEditAR_HGroup4_c(),this._GWizCutKBEditAR_HGroup5_c(),this._GWizCutKBEditAR_Spacer1_c(),this._GWizCutKBEditAR_HGroup6_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCutKBEditAR._watcherSetupUtil = param1;
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
      
      private function pctEntry(param1:String, param2:Number, param3:Number, param4:int, param5:Boolean, param6:String) : String
      {
         var _loc7_:String = null;
         _loc7_ = param3 >= 0 ? "+" : "-";
         return param1 + GWizUtils.formatPlaces(param2,param4,param5,param6) + " (" + _loc7_ + param3 + "%)";
      }
      
      public function inputsReady(param1:GWizCutKB, param2:String, param3:String, param4:String, param5:String, param6:String, param7:String) : void
      {
         var _loc8_:* = null;
         this.oldActiveRec = GWizCutKBSQL.activeRec;
         if(param1)
         {
            GWizCutKBSQL.activeRec = param1;
         }
         this.MRR.text = this.pctEntry(param2,GWizCutKBSQL.activeRec.mrr,GWizCutKBSQL.activeRec.mrrPct,0,true,GWizUtils.CC_UNITS);
         this.RPM.text = this.pctEntry(param3,GWizCutKBSQL.activeRec.rpm,GWizCutKBSQL.activeRec.rpmPct,0,false,"");
         this.IPM.text = this.pctEntry(param4,GWizCutKBSQL.activeRec.ipm,GWizCutKBSQL.activeRec.ipmPct,1,true,GWizUtils.MM_UNITS);
         this.SFM.text = this.pctEntry(param5,GWizCutKBSQL.activeRec.sfm,GWizCutKBSQL.activeRec.sfmPct,0,true,GWizUtils.M_UNITS);
         this.IPT.text = this.pctEntry(param6,GWizCutKBSQL.activeRec.ipt,GWizCutKBSQL.activeRec.iptPct,4,true,GWizUtils.MM_UNITS);
         this.ToolDesc.text = GWizToolDef.toolDefDescArgs(GWizCutKBSQL.activeRec.toolDia,GWizCutKBSQL.activeRec.flutes,GWizCutKBSQL.activeRec.leadAng,GWizToolDef.geometryFromBasics(GWizCutKBSQL.activeRec.tool,GWizCutKBSQL.activeRec.geometry),GWizCutKBSQL.activeRec.tool,GWizCutKBSQL.activeRec.stickout,GWizCutKBSQL.activeRec.noseRad);
         this.cutType.cutDepth.text = GWizUtils.formatPlaces(GWizCutKBSQL.activeRec.cutDepth,4,true,GWizUtils.MM_UNITS);
         this.cutType.cutWidth.text = GWizUtils.formatPlaces(GWizCutKBSQL.activeRec.cutWidth,4,true,GWizUtils.MM_UNITS);
         _loc8_ = (_loc8_ = "Material: " + param7 + "\n") + ("Hardness: " + GWizCutKBSQL.activeRec.hardness + " BHN" + "\n");
         this.MatDesc.text = _loc8_;
         this.Description.text = GWizCutKBSQL.activeRec.description;
         this.Rating.value = GWizCutKBSQL.activeRec.rating;
         this.Comments.text = GWizCutKBSQL.activeRec.comments;
         this.Wear.selectedIndex = GWizCutKBSQL.activeRec.wear;
         this.Chatter.value = GWizCutKBSQL.activeRec.chatter;
         this.cutType.CutType.selectedIndex = Math.abs(GWizCutKBSQL.activeRec.cutType);
         this.cutType.RoughFinish.selectedIndex = int(GWizCutKBSQL.activeRec.rough);
         this.Machine.text = "Machine: " + GWizCutKBSQL.activeRec.machine;
         this.Holder.selectedIndex = GWizCutKBSQL.activeRec.holder;
         this.Coolant.selectedIndex = GWizCutKBSQL.activeRec.coolant;
         this.ID.text = "ID: " + GWizCutKBSQL.activeRec.id;
         this.ID.visible = GWizCutKBSQL.activeRec.id != -1;
         this.visible = true;
      }
      
      private function doOK(param1:Boolean) : void
      {
         if(param1)
         {
            this.copyUIToAR();
            GWizSettings.cutKBSQL.updateRowAR();
         }
         super.close();
         if(this.refresh != null)
         {
            this.refresh();
         }
      }
      
      private function alertClickHandler(param1:CloseEvent) : void
      {
         if(param1.detail == GWizPopUpManager.YES)
         {
            GWizSettings.cutKBSQL.deleteRowAR();
         }
         this.doOK(false);
      }
      
      private function doDelete() : void
      {
         if(GWizCutKBSQL.activeRec.id != -1)
         {
            GWizPopUpManager.Show("Are you sure you want to delete that Cut KB entry?","Confirm Delete",GWizPopUpManager.YES | GWizPopUpManager.NO | GWizPopUpManager.WARN,this,this.alertClickHandler);
         }
      }
      
      private function copyUIToAR() : void
      {
         GWizCutKBSQL.activeRec.description = this.Description.text;
         GWizCutKBSQL.activeRec.rating = this.Rating.value;
         GWizCutKBSQL.activeRec.comments = this.Comments.text;
         GWizCutKBSQL.activeRec.wear = this.Wear.selectedIndex;
         GWizCutKBSQL.activeRec.chatter = this.Chatter.value;
         GWizCutKBSQL.activeRec.cutType = GWizCutKB.encodeCutType(this.cutType.CutType.selectedIndex,GWizCutKBSQL.activeRec.machine);
         GWizCutKBSQL.activeRec.rough = this.cutType.RoughFinish.selectedIndex != 0;
         GWizCutKBSQL.activeRec.holder = this.Holder.selectedIndex;
         GWizCutKBSQL.activeRec.coolant = this.Coolant.selectedIndex;
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doOK(true);
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doOK(true);
      }
      
      private function _GWizCutKBEditAR_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCutKBEditAR_Label1_c(),this._GWizCutKBEditAR_Rating1_i(),this._GWizCutKBEditAR_Label2_i(),this._GWizCutKBEditAR_Label3_i(),this._GWizCutKBEditAR_Label4_i(),this._GWizCutKBEditAR_Label5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Rating";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Rating1_i() : Rating
      {
         var _loc1_:Rating = new Rating();
         _loc1_.editable = true;
         _loc1_.toolTip = "1-5 star subjective rating of this cut";
         _loc1_.id = "Rating";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Rating = _loc1_;
         BindingManager.executeBindings(this,"Rating",this.Rating);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "MRR: 10,000 (+15%)";
         _loc1_.toolTip = "Material Removal Rate";
         _loc1_.id = "MRR";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MRR = _loc1_;
         BindingManager.executeBindings(this,"MRR",this.MRR);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "RPM: 10,000 (+15%)";
         _loc1_.toolTip = "Spindle RPM";
         _loc1_.id = "RPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RPM = _loc1_;
         BindingManager.executeBindings(this,"RPM",this.RPM);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Feed (IPM): 1000 (+22%)";
         _loc1_.toolTip = "Feedrate in inches \ror mm per minute";
         _loc1_.id = "IPM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.IPM = _loc1_;
         BindingManager.executeBindings(this,"IPM",this.IPM);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "ID: ";
         _loc1_.toolTip = "Unique identifier for this Cut KB entry.";
         _loc1_.id = "ID";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ID = _loc1_;
         BindingManager.executeBindings(this,"ID",this.ID);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCutKBEditAR_Label6_c(),this._GWizCutKBEditAR_TextInput1_i(),this._GWizCutKBEditAR_Label7_c(),this._GWizCutKBEditAR_DropDownList1_i(),this._GWizCutKBEditAR_Label8_c(),this._GWizCutKBEditAR_NumericStepper1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Comments";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.text = "";
         _loc1_.toolTip = "Your comments on the results of the cut";
         _loc1_.id = "Comments";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Comments = _loc1_;
         BindingManager.executeBindings(this,"Comments",this.Comments);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Wear";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 100;
         _loc1_.toolTip = "Rate wear: Normal, Poor (dulled quickly), Chipped, Broken";
         _loc1_.id = "Wear";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Wear = _loc1_;
         BindingManager.executeBindings(this,"Wear",this.Wear);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Chatter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 5;
         _loc1_.stepSize = 1;
         _loc1_.toolTip = "Rate your chatter: 0=None, 1=Some, 5=Bad";
         _loc1_.id = "Chatter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Chatter = _loc1_;
         BindingManager.executeBindings(this,"Chatter",this.Chatter);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCutKBEditAR_Label9_i(),this._GWizCutKBEditAR_Label10_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "SFM";
         _loc1_.id = "SFM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SFM = _loc1_;
         BindingManager.executeBindings(this,"SFM",this.SFM);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Chipload";
         _loc1_.id = "IPT";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.IPT = _loc1_;
         BindingManager.executeBindings(this,"IPT",this.IPT);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Line1_c() : Line
      {
         var _loc1_:Line = new Line();
         _loc1_.percentWidth = 100;
         _loc1_.stroke = this._GWizCutKBEditAR_SolidColorStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_SolidColorStroke1_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 16777215;
         _loc1_.weight = 2;
         _loc1_.caps = "square";
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_GWizCutType1_i() : GWizCutType
      {
         var _loc1_:GWizCutType = new GWizCutType();
         _loc1_.id = "cutType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutType = _loc1_;
         BindingManager.executeBindings(this,"cutType",this.cutType);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCutKBEditAR_GWizPanel1_c(),this._GWizCutKBEditAR_GWizPanel2_c(),this._GWizCutKBEditAR_GWizPanel3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_GWizPanel1_c() : GWizPanel
      {
         var _loc1_:GWizPanel = new GWizPanel();
         _loc1_.title = "Description";
         _loc1_.height = 115;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCutKBEditAR_Array6_c);
         _loc1_.setStyle("skinClass",PanelSkin);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Array6_c() : Array
      {
         return [this._GWizCutKBEditAR_TextArea1_i()];
      }
      
      private function _GWizCutKBEditAR_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.text = "1/2 inch 2 flute endmill";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.toolTip = "Your descriptive notes on this cut";
         _loc1_.id = "Description";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Description = _loc1_;
         BindingManager.executeBindings(this,"Description",this.Description);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_GWizPanel2_c() : GWizPanel
      {
         var _loc1_:GWizPanel = new GWizPanel();
         _loc1_.title = "Tool Definition";
         _loc1_.height = 115;
         _loc1_.backgroundColor = 14869218;
         _loc1_.backgroundAlpha = 0.4;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCutKBEditAR_Array7_c);
         _loc1_.setStyle("skinClass",PanelSkin);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Array7_c() : Array
      {
         return [this._GWizCutKBEditAR_TextArea2_i()];
      }
      
      private function _GWizCutKBEditAR_TextArea2_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.text = "1/2\" inch 2 Flute HSS Endmill";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.editable = false;
         _loc1_.id = "ToolDesc";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolDesc = _loc1_;
         BindingManager.executeBindings(this,"ToolDesc",this.ToolDesc);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_GWizPanel3_c() : GWizPanel
      {
         var _loc1_:GWizPanel = new GWizPanel();
         _loc1_.title = "Material";
         _loc1_.height = 115;
         _loc1_.backgroundColor = 14869218;
         _loc1_.backgroundAlpha = 0.4;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCutKBEditAR_Array8_c);
         _loc1_.setStyle("skinClass",PanelSkin);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Array8_c() : Array
      {
         return [this._GWizCutKBEditAR_TextArea3_i()];
      }
      
      private function _GWizCutKBEditAR_TextArea3_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.text = "";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.editable = false;
         _loc1_.id = "MatDesc";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MatDesc = _loc1_;
         BindingManager.executeBindings(this,"MatDesc",this.MatDesc);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.gap = 10;
         _loc1_.mxmlContent = [this._GWizCutKBEditAR_Label11_i(),this._GWizCutKBEditAR_Label12_c(),this._GWizCutKBEditAR_DropDownList2_i(),this._GWizCutKBEditAR_Label13_c(),this._GWizCutKBEditAR_DropDownList3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Machine: ";
         _loc1_.id = "Machine";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Machine = _loc1_;
         BindingManager.executeBindings(this,"Machine",this.Machine);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Holder:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.typicalItem = "WWWWWWWWWW";
         _loc1_.id = "Holder";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Holder = _loc1_;
         BindingManager.executeBindings(this,"Holder",this.Holder);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Coolant:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_DropDownList3_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.id = "Coolant";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Coolant = _loc1_;
         BindingManager.executeBindings(this,"Coolant",this.Coolant);
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizCutKBEditAR_Button1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBEditAR_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Delete";
         _loc1_.width = 64;
         _loc1_.toolTip = "Delete this Cut KB entry from your Cut KB.";
         _loc1_.addEventListener("click",this.___GWizCutKBEditAR_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCutKBEditAR_Button1_click(param1:MouseEvent) : void
      {
         this.doDelete();
      }
      
      private function _GWizCutKBEditAR_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return new ArrayList(GWizConfigData.ToolWear);
         },null,"Wear.dataProvider");
         result[1] = new Binding(this,function():IList
         {
            return new ArrayList(GWizConfigData.HolderTypes);
         },null,"Holder.dataProvider");
         result[2] = new Binding(this,function():IList
         {
            return new ArrayList(GWizConfigData.CoolantTypes);
         },null,"Coolant.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Chatter() : NumericStepper
      {
         return this._1891179095Chatter;
      }
      
      public function set Chatter(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1891179095Chatter;
         if(_loc2_ !== param1)
         {
            this._1891179095Chatter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Chatter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Comments() : TextInput
      {
         return this._537771500Comments;
      }
      
      public function set Comments(param1:TextInput) : void
      {
         var _loc2_:Object = this._537771500Comments;
         if(_loc2_ !== param1)
         {
            this._537771500Comments = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Comments",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Coolant() : DropDownList
      {
         return this._1678102050Coolant;
      }
      
      public function set Coolant(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1678102050Coolant;
         if(_loc2_ !== param1)
         {
            this._1678102050Coolant = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Coolant",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Description() : TextArea
      {
         return this._56677412Description;
      }
      
      public function set Description(param1:TextArea) : void
      {
         var _loc2_:Object = this._56677412Description;
         if(_loc2_ !== param1)
         {
            this._56677412Description = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Description",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Holder() : DropDownList
      {
         return this._2127840820Holder;
      }
      
      public function set Holder(param1:DropDownList) : void
      {
         var _loc2_:Object = this._2127840820Holder;
         if(_loc2_ !== param1)
         {
            this._2127840820Holder = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Holder",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ID() : Label
      {
         return this._2331ID;
      }
      
      public function set ID(param1:Label) : void
      {
         var _loc2_:Object = this._2331ID;
         if(_loc2_ !== param1)
         {
            this._2331ID = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ID",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get IPM() : Label
      {
         return this._72710IPM;
      }
      
      public function set IPM(param1:Label) : void
      {
         var _loc2_:Object = this._72710IPM;
         if(_loc2_ !== param1)
         {
            this._72710IPM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IPM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get IPT() : Label
      {
         return this._72717IPT;
      }
      
      public function set IPT(param1:Label) : void
      {
         var _loc2_:Object = this._72717IPT;
         if(_loc2_ !== param1)
         {
            this._72717IPT = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IPT",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MRR() : Label
      {
         return this._76621MRR;
      }
      
      public function set MRR(param1:Label) : void
      {
         var _loc2_:Object = this._76621MRR;
         if(_loc2_ !== param1)
         {
            this._76621MRR = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MRR",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Machine() : Label
      {
         return this._1805001689Machine;
      }
      
      public function set Machine(param1:Label) : void
      {
         var _loc2_:Object = this._1805001689Machine;
         if(_loc2_ !== param1)
         {
            this._1805001689Machine = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Machine",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MatDesc() : TextArea
      {
         return this._1790377999MatDesc;
      }
      
      public function set MatDesc(param1:TextArea) : void
      {
         var _loc2_:Object = this._1790377999MatDesc;
         if(_loc2_ !== param1)
         {
            this._1790377999MatDesc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MatDesc",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RPM() : Label
      {
         return this._81359RPM;
      }
      
      public function set RPM(param1:Label) : void
      {
         var _loc2_:Object = this._81359RPM;
         if(_loc2_ !== param1)
         {
            this._81359RPM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RPM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Rating() : Rating
      {
         return this._1854235203Rating;
      }
      
      public function set Rating(param1:Rating) : void
      {
         var _loc2_:Object = this._1854235203Rating;
         if(_loc2_ !== param1)
         {
            this._1854235203Rating = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Rating",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SFM() : Label
      {
         return this._82010SFM;
      }
      
      public function set SFM(param1:Label) : void
      {
         var _loc2_:Object = this._82010SFM;
         if(_loc2_ !== param1)
         {
            this._82010SFM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SFM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolDesc() : TextArea
      {
         return this._919423895ToolDesc;
      }
      
      public function set ToolDesc(param1:TextArea) : void
      {
         var _loc2_:Object = this._919423895ToolDesc;
         if(_loc2_ !== param1)
         {
            this._919423895ToolDesc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolDesc",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Wear() : DropDownList
      {
         return this._2691999Wear;
      }
      
      public function set Wear(param1:DropDownList) : void
      {
         var _loc2_:Object = this._2691999Wear;
         if(_loc2_ !== param1)
         {
            this._2691999Wear = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Wear",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutType() : GWizCutType
      {
         return this._1127912604cutType;
      }
      
      public function set cutType(param1:GWizCutType) : void
      {
         var _loc2_:Object = this._1127912604cutType;
         if(_loc2_ !== param1)
         {
            this._1127912604cutType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutType",_loc2_,param1));
            }
         }
      }
   }
}
