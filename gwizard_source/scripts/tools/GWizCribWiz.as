package tools
{
   import comps.GWizForePanel;
   import comps.GWizNumParseStepper;
   import comps.GWizPopUp;
   import configinfo.GWizConfigData;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
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
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.ComboBox;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class GWizCribWiz extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizCribWiz");
      
      private static var _1140054206EndMillTypes:ArrayCollection = new ArrayCollection([{"label":"Carbide"},{"label":"HP Carbide"},{"label":"TiAlN Carbide"},{"label":"HSS"},{"label":"HP HSS"},{"label":"TiAlN HSS"}]);
      
      private static var _841009339TwistDrillTypes:ArrayCollection = new ArrayCollection([{"label":"HSS"},{"label":"HP HSS"},{"label":"Cobalt"},{"label":"Carbide"},{"label":"HP Carbide"}]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1915180979drillInchSizes:CheckBox;
      
      private var _518687921drillLetterSizes:CheckBox;
      
      private var _1643306649drillMetricSizes:CheckBox;
      
      private var _716383929drillWireGaugeSizes:CheckBox;
      
      private var _96599964emMax:GWizNumParseStepper;
      
      private var _96600202emMin:GWizNumParseStepper;
      
      private var _371249689emSuffix:TextInput;
      
      private var _982213837endmillPanel:GWizForePanel;
      
      private var _1278752593endmillType:ComboBox;
      
      private var _1271453357flutes:GWizNumParseStepper;
      
      private var _448489434impSizes:CheckBox;
      
      private var _1154131666mmSizes:CheckBox;
      
      private var _1982855674optionsPanel:GWizForePanel;
      
      private var _109568065tNums:CheckBox;
      
      private var _110184660tdMax:GWizNumParseStepper;
      
      private var _110184898tdMin:GWizNumParseStepper;
      
      private var _1346002401tdSuffix:TextInput;
      
      private var _151597296twistDrillPanel:GWizForePanel;
      
      private var _143579854twistDrillType:ComboBox;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var theCrib:ArrayCollection = null;
      
      private var _844083586maxSlot:int = 0;
      
      public var verifyTblFcn:Function;
      
      public var addEndmillFcn:Function;
      
      public var addDrillFcn:Function;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCribWiz()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCribWiz_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizCribWizWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCribWiz[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Crib Wizard...";
         this.okLabel = "";
         this.cancelLabel = "Exit";
         this.mxmlContent = [this._GWizCribWiz_VGroup1_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCribWiz._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get EndMillTypes() : ArrayCollection
      {
         return GWizCribWiz._1140054206EndMillTypes;
      }
      
      private static function set EndMillTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCribWiz._1140054206EndMillTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCribWiz,"EndMillTypes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get TwistDrillTypes() : ArrayCollection
      {
         return GWizCribWiz._841009339TwistDrillTypes;
      }
      
      private static function set TwistDrillTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCribWiz._841009339TwistDrillTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCribWiz,"TwistDrillTypes",_loc2_,param1));
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
      
      private function addEndmills() : void
      {
         var _loc2_:Object = null;
         if(this.addEndmillFcn == null)
         {
            return;
         }
         GWizConfigData.DrillData.filterFunction = null;
         GWizConfigData.DrillData.refresh();
         var _loc1_:int = 0;
         while(_loc1_ < GWizConfigData.DrillData.length)
         {
            _loc2_ = GWizConfigData.DrillData.getItemAt(_loc1_);
            if(this.emMin.getVal() <= _loc2_.inch && _loc2_.inch <= this.emMax.getVal())
            {
               if(_loc2_.eminch > 0 && this.impSizes.selected)
               {
                  this.addEndmillFcn(_loc2_.inch,this.flutes.getVal(),TwistDrillTypes.getItemAt(this.twistDrillType.selectedIndex).label,_loc2_.designation,this.emSuffix.text,true,this.tNums.selected,GWizToolCrib.tableName);
               }
               else if(_loc2_.emmm > 0 && this.mmSizes.selected)
               {
                  this.addEndmillFcn(_loc2_.inch,this.flutes.getVal(),TwistDrillTypes.getItemAt(this.twistDrillType.selectedIndex).label,_loc2_.designation,this.emSuffix.text,false,this.tNums.selected,GWizToolCrib.tableName);
               }
            }
            _loc1_++;
         }
         if(this.verifyTblFcn != null)
         {
            this.verifyTblFcn();
         }
      }
      
      private function addDrills() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(this.addDrillFcn == null)
         {
            return;
         }
         GWizConfigData.DrillData.filterFunction = null;
         GWizConfigData.DrillData.refresh();
         var _loc1_:int = 0;
         while(_loc1_ < GWizConfigData.DrillData.length)
         {
            _loc2_ = GWizConfigData.DrillData.getItemAt(_loc1_);
            _loc3_ = Number(_loc2_.inch);
            if(this.tdMin.getVal() <= _loc3_ && _loc3_ <= this.tdMax.getVal())
            {
               _loc4_ = false;
               _loc5_ = _loc2_.designation;
               if(this.drillInchSizes.selected && _loc5_.indexOf("\"") >= 0)
               {
                  _loc4_ = true;
               }
               if(this.drillWireGaugeSizes.selected && _loc5_.indexOf("#") >= 0)
               {
                  _loc4_ = true;
               }
               if(this.drillMetricSizes.selected && _loc5_.indexOf("mm") >= 0)
               {
                  _loc4_ = true;
               }
               _loc6_ = String(_loc5_).substr(0,1);
               if(this.drillLetterSizes.selected && "A".charAt(0) <= _loc6_.substr(0,1) && _loc6_.substr(0,1) <= "Z")
               {
                  _loc4_ = true;
               }
               if(_loc4_)
               {
                  this.addDrillFcn(_loc2_.inch,TwistDrillTypes.getItemAt(this.twistDrillType.selectedIndex).label,_loc5_,this.tdSuffix.text,this.tNums.selected,GWizToolCrib.tableName);
               }
            }
            _loc1_++;
         }
         if(this.verifyTblFcn != null)
         {
            this.verifyTblFcn();
         }
      }
      
      override public function onOk(param1:Event) : void
      {
         super.close();
      }
      
      private function _GWizCribWiz_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCribWiz_GWizForePanel1_i(),this._GWizCribWiz_GWizForePanel2_i(),this._GWizCribWiz_GWizForePanel3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Endmills";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribWiz_Array3_c);
         _loc1_.id = "endmillPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.endmillPanel = _loc1_;
         BindingManager.executeBindings(this,"endmillPanel",this.endmillPanel);
         return _loc1_;
      }
      
      private function _GWizCribWiz_Array3_c() : Array
      {
         return [this._GWizCribWiz_VGroup2_c()];
      }
      
      private function _GWizCribWiz_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCribWiz_HGroup1_c(),this._GWizCribWiz_HGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribWiz_Label1_c(),this._GWizCribWiz_GWizNumParseStepper1_i(),this._GWizCribWiz_Label2_c(),this._GWizCribWiz_GWizNumParseStepper2_i(),this._GWizCribWiz_CheckBox1_i(),this._GWizCribWiz_CheckBox2_i(),this._GWizCribWiz_ComboBox1_i(),this._GWizCribWiz_Button1_c()];
         _loc1_.setStyle("color",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Min Size";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_GWizNumParseStepper1_i() : GWizNumParseStepper
      {
         var _loc1_:GWizNumParseStepper = new GWizNumParseStepper();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.id = "emMin";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.emMin = _loc1_;
         BindingManager.executeBindings(this,"emMin",this.emMin);
         return _loc1_;
      }
      
      private function _GWizCribWiz_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max Size";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_GWizNumParseStepper2_i() : GWizNumParseStepper
      {
         var _loc1_:GWizNumParseStepper = new GWizNumParseStepper();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.id = "emMax";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.emMax = _loc1_;
         BindingManager.executeBindings(this,"emMax",this.emMax);
         return _loc1_;
      }
      
      private function _GWizCribWiz_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Imperial";
         _loc1_.selected = true;
         _loc1_.id = "impSizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.impSizes = _loc1_;
         BindingManager.executeBindings(this,"impSizes",this.impSizes);
         return _loc1_;
      }
      
      private function _GWizCribWiz_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Metric";
         _loc1_.id = "mmSizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mmSizes = _loc1_;
         BindingManager.executeBindings(this,"mmSizes",this.mmSizes);
         return _loc1_;
      }
      
      private function _GWizCribWiz_ComboBox1_i() : ComboBox
      {
         var _loc1_:ComboBox = new ComboBox();
         _loc1_.selectedIndex = 0;
         _loc1_.id = "endmillType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.endmillType = _loc1_;
         BindingManager.executeBindings(this,"endmillType",this.endmillType);
         return _loc1_;
      }
      
      private function _GWizCribWiz_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Add";
         _loc1_.addEventListener("click",this.___GWizCribWiz_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCribWiz_Button1_click(param1:MouseEvent) : void
      {
         this.addEndmills();
      }
      
      private function _GWizCribWiz_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribWiz_Label3_c(),this._GWizCribWiz_TextInput1_i(),this._GWizCribWiz_Label4_c(),this._GWizCribWiz_GWizNumParseStepper3_i()];
         _loc1_.setStyle("color",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Add to Description";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.toolTip = "Add this suffix to the description of each tool.";
         _loc1_.id = "emSuffix";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.emSuffix = _loc1_;
         BindingManager.executeBindings(this,"emSuffix",this.emSuffix);
         return _loc1_;
      }
      
      private function _GWizCribWiz_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Flutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_GWizNumParseStepper3_i() : GWizNumParseStepper
      {
         var _loc1_:GWizNumParseStepper = new GWizNumParseStepper();
         _loc1_.min = 1;
         _loc1_.max = 50;
         _loc1_.steps = 1;
         _loc1_.id = "flutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.flutes = _loc1_;
         BindingManager.executeBindings(this,"flutes",this.flutes);
         return _loc1_;
      }
      
      private function _GWizCribWiz_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Twist Drills";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribWiz_Array7_c);
         _loc1_.id = "twistDrillPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.twistDrillPanel = _loc1_;
         BindingManager.executeBindings(this,"twistDrillPanel",this.twistDrillPanel);
         return _loc1_;
      }
      
      private function _GWizCribWiz_Array7_c() : Array
      {
         return [this._GWizCribWiz_VGroup3_c()];
      }
      
      private function _GWizCribWiz_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCribWiz_HGroup3_c(),this._GWizCribWiz_HGroup4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribWiz_Label5_c(),this._GWizCribWiz_GWizNumParseStepper4_i(),this._GWizCribWiz_Label6_c(),this._GWizCribWiz_GWizNumParseStepper5_i(),this._GWizCribWiz_ComboBox2_i(),this._GWizCribWiz_CheckBox3_i(),this._GWizCribWiz_CheckBox4_i(),this._GWizCribWiz_CheckBox5_i(),this._GWizCribWiz_CheckBox6_i()];
         _loc1_.setStyle("color",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Min Size";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_GWizNumParseStepper4_i() : GWizNumParseStepper
      {
         var _loc1_:GWizNumParseStepper = new GWizNumParseStepper();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.id = "tdMin";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdMin = _loc1_;
         BindingManager.executeBindings(this,"tdMin",this.tdMin);
         return _loc1_;
      }
      
      private function _GWizCribWiz_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max Size";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_GWizNumParseStepper5_i() : GWizNumParseStepper
      {
         var _loc1_:GWizNumParseStepper = new GWizNumParseStepper();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.id = "tdMax";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdMax = _loc1_;
         BindingManager.executeBindings(this,"tdMax",this.tdMax);
         return _loc1_;
      }
      
      private function _GWizCribWiz_ComboBox2_i() : ComboBox
      {
         var _loc1_:ComboBox = new ComboBox();
         _loc1_.selectedIndex = 0;
         _loc1_.id = "twistDrillType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.twistDrillType = _loc1_;
         BindingManager.executeBindings(this,"twistDrillType",this.twistDrillType);
         return _loc1_;
      }
      
      private function _GWizCribWiz_CheckBox3_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Imperial";
         _loc1_.id = "drillInchSizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.drillInchSizes = _loc1_;
         BindingManager.executeBindings(this,"drillInchSizes",this.drillInchSizes);
         return _loc1_;
      }
      
      private function _GWizCribWiz_CheckBox4_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Wire Gauge";
         _loc1_.id = "drillWireGaugeSizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.drillWireGaugeSizes = _loc1_;
         BindingManager.executeBindings(this,"drillWireGaugeSizes",this.drillWireGaugeSizes);
         return _loc1_;
      }
      
      private function _GWizCribWiz_CheckBox5_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Letter";
         _loc1_.id = "drillLetterSizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.drillLetterSizes = _loc1_;
         BindingManager.executeBindings(this,"drillLetterSizes",this.drillLetterSizes);
         return _loc1_;
      }
      
      private function _GWizCribWiz_CheckBox6_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Metric";
         _loc1_.id = "drillMetricSizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.drillMetricSizes = _loc1_;
         BindingManager.executeBindings(this,"drillMetricSizes",this.drillMetricSizes);
         return _loc1_;
      }
      
      private function _GWizCribWiz_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribWiz_Label7_c(),this._GWizCribWiz_TextInput2_i(),this._GWizCribWiz_Spacer1_c(),this._GWizCribWiz_Button2_c()];
         _loc1_.setStyle("color",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Add to Description";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.toolTip = "Add this suffix to the description of each tool.";
         _loc1_.id = "tdSuffix";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tdSuffix = _loc1_;
         BindingManager.executeBindings(this,"tdSuffix",this.tdSuffix);
         return _loc1_;
      }
      
      private function _GWizCribWiz_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Add";
         _loc1_.addEventListener("click",this.___GWizCribWiz_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCribWiz_Button2_click(param1:MouseEvent) : void
      {
         this.addDrills();
      }
      
      private function _GWizCribWiz_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Options";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribWiz_Array11_c);
         _loc1_.id = "optionsPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.optionsPanel = _loc1_;
         BindingManager.executeBindings(this,"optionsPanel",this.optionsPanel);
         return _loc1_;
      }
      
      private function _GWizCribWiz_Array11_c() : Array
      {
         return [this._GWizCribWiz_VGroup4_c()];
      }
      
      private function _GWizCribWiz_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCribWiz_CheckBox7_i()];
         _loc1_.setStyle("color",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribWiz_CheckBox7_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Increment T#\'s";
         _loc1_.selected = true;
         _loc1_.toolTip = "If set, consecutive T#\'s are created.  If not, T#\'s are all zeros.";
         _loc1_.id = "tNums";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tNums = _loc1_;
         BindingManager.executeBindings(this,"tNums",this.tNums);
         return _loc1_;
      }
      
      private function _GWizCribWiz_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"endmillPanel.labelBackgroundColor");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"endmillPanel.labelColor");
         result[2] = new Binding(this,function():IList
         {
            return EndMillTypes;
         },null,"endmillType.dataProvider");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"twistDrillPanel.labelBackgroundColor");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"twistDrillPanel.labelColor");
         result[5] = new Binding(this,function():IList
         {
            return TwistDrillTypes;
         },null,"twistDrillType.dataProvider");
         result[6] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"optionsPanel.labelBackgroundColor");
         result[7] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"optionsPanel.labelColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get drillInchSizes() : CheckBox
      {
         return this._1915180979drillInchSizes;
      }
      
      public function set drillInchSizes(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1915180979drillInchSizes;
         if(_loc2_ !== param1)
         {
            this._1915180979drillInchSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"drillInchSizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get drillLetterSizes() : CheckBox
      {
         return this._518687921drillLetterSizes;
      }
      
      public function set drillLetterSizes(param1:CheckBox) : void
      {
         var _loc2_:Object = this._518687921drillLetterSizes;
         if(_loc2_ !== param1)
         {
            this._518687921drillLetterSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"drillLetterSizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get drillMetricSizes() : CheckBox
      {
         return this._1643306649drillMetricSizes;
      }
      
      public function set drillMetricSizes(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1643306649drillMetricSizes;
         if(_loc2_ !== param1)
         {
            this._1643306649drillMetricSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"drillMetricSizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get drillWireGaugeSizes() : CheckBox
      {
         return this._716383929drillWireGaugeSizes;
      }
      
      public function set drillWireGaugeSizes(param1:CheckBox) : void
      {
         var _loc2_:Object = this._716383929drillWireGaugeSizes;
         if(_loc2_ !== param1)
         {
            this._716383929drillWireGaugeSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"drillWireGaugeSizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get emMax() : GWizNumParseStepper
      {
         return this._96599964emMax;
      }
      
      public function set emMax(param1:GWizNumParseStepper) : void
      {
         var _loc2_:Object = this._96599964emMax;
         if(_loc2_ !== param1)
         {
            this._96599964emMax = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"emMax",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get emMin() : GWizNumParseStepper
      {
         return this._96600202emMin;
      }
      
      public function set emMin(param1:GWizNumParseStepper) : void
      {
         var _loc2_:Object = this._96600202emMin;
         if(_loc2_ !== param1)
         {
            this._96600202emMin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"emMin",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get emSuffix() : TextInput
      {
         return this._371249689emSuffix;
      }
      
      public function set emSuffix(param1:TextInput) : void
      {
         var _loc2_:Object = this._371249689emSuffix;
         if(_loc2_ !== param1)
         {
            this._371249689emSuffix = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"emSuffix",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get endmillPanel() : GWizForePanel
      {
         return this._982213837endmillPanel;
      }
      
      public function set endmillPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._982213837endmillPanel;
         if(_loc2_ !== param1)
         {
            this._982213837endmillPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"endmillPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get endmillType() : ComboBox
      {
         return this._1278752593endmillType;
      }
      
      public function set endmillType(param1:ComboBox) : void
      {
         var _loc2_:Object = this._1278752593endmillType;
         if(_loc2_ !== param1)
         {
            this._1278752593endmillType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"endmillType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get flutes() : GWizNumParseStepper
      {
         return this._1271453357flutes;
      }
      
      public function set flutes(param1:GWizNumParseStepper) : void
      {
         var _loc2_:Object = this._1271453357flutes;
         if(_loc2_ !== param1)
         {
            this._1271453357flutes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"flutes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get impSizes() : CheckBox
      {
         return this._448489434impSizes;
      }
      
      public function set impSizes(param1:CheckBox) : void
      {
         var _loc2_:Object = this._448489434impSizes;
         if(_loc2_ !== param1)
         {
            this._448489434impSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"impSizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mmSizes() : CheckBox
      {
         return this._1154131666mmSizes;
      }
      
      public function set mmSizes(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1154131666mmSizes;
         if(_loc2_ !== param1)
         {
            this._1154131666mmSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mmSizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get optionsPanel() : GWizForePanel
      {
         return this._1982855674optionsPanel;
      }
      
      public function set optionsPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1982855674optionsPanel;
         if(_loc2_ !== param1)
         {
            this._1982855674optionsPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"optionsPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tNums() : CheckBox
      {
         return this._109568065tNums;
      }
      
      public function set tNums(param1:CheckBox) : void
      {
         var _loc2_:Object = this._109568065tNums;
         if(_loc2_ !== param1)
         {
            this._109568065tNums = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tNums",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdMax() : GWizNumParseStepper
      {
         return this._110184660tdMax;
      }
      
      public function set tdMax(param1:GWizNumParseStepper) : void
      {
         var _loc2_:Object = this._110184660tdMax;
         if(_loc2_ !== param1)
         {
            this._110184660tdMax = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdMax",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdMin() : GWizNumParseStepper
      {
         return this._110184898tdMin;
      }
      
      public function set tdMin(param1:GWizNumParseStepper) : void
      {
         var _loc2_:Object = this._110184898tdMin;
         if(_loc2_ !== param1)
         {
            this._110184898tdMin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdMin",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tdSuffix() : TextInput
      {
         return this._1346002401tdSuffix;
      }
      
      public function set tdSuffix(param1:TextInput) : void
      {
         var _loc2_:Object = this._1346002401tdSuffix;
         if(_loc2_ !== param1)
         {
            this._1346002401tdSuffix = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tdSuffix",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get twistDrillPanel() : GWizForePanel
      {
         return this._151597296twistDrillPanel;
      }
      
      public function set twistDrillPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._151597296twistDrillPanel;
         if(_loc2_ !== param1)
         {
            this._151597296twistDrillPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"twistDrillPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get twistDrillType() : ComboBox
      {
         return this._143579854twistDrillType;
      }
      
      public function set twistDrillType(param1:ComboBox) : void
      {
         var _loc2_:Object = this._143579854twistDrillType;
         if(_loc2_ !== param1)
         {
            this._143579854twistDrillType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"twistDrillType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get maxSlot() : int
      {
         return this._844083586maxSlot;
      }
      
      public function set maxSlot(param1:int) : void
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
   }
}
