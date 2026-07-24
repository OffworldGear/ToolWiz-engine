package cadcamwiz
{
   import comps.GWizForePanel;
   import comps.GWizNumStepOvr;
   import configinfo.GWizSettings;
   import feedsspeeds.GWizFeedsSpeeds2;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.IList;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   
   use namespace mx_internal;
   
   public class GWizCCPocketOptions extends GWizForePanel implements IBindingClient
   {
      
      private static var _1927507083showEntry:Boolean = true;
      
      public static var entryMode:String = "";
      
      public static var entryModeIdx:int = 0;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _2076430148Carbide:RadioButton;
      
      private var _1710422724CarbideHP:RadioButton;
      
      private var _276736142CarbideTiAlN:RadioButton;
      
      private var _2107381107Flutes:GWizNumStepOvr;
      
      private var _71848HSS:RadioButton;
      
      private var _69048240HSSHP:RadioButton;
      
      private var _1596369118Stickout:GWizNumStepOvr;
      
      private var _524530596ToolDia:GWizNumStepOvr;
      
      public var _GWizCCPocketOptions_Label3:Label;
      
      private var _1464755574plungeMode:DropDownList;
      
      private var _164873550radiogroup2:RadioButtonGroup;
      
      private var _6516163roughLbl:Label;
      
      private var _1960055573roughStrat:DropDownList;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _934922488recalc:Function = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCPocketOptions()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCPocketOptions_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCPocketOptionsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCPocketOptions[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Options";
         this.percentWidth = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCPocketOptions_Array1_c);
         this._GWizCCPocketOptions_RadioButtonGroup1_i();
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCPocketOptions._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get showEntry() : Boolean
      {
         return GWizCCPocketOptions._1927507083showEntry;
      }
      
      public static function set showEntry(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCPocketOptions._1927507083showEntry;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCPocketOptions,"showEntry",_loc2_,param1));
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
      
      private function syncPlungeWithFSTab() : void
      {
         if(GWizSettings.FeedsSpeedsApp && this.plungeMode)
         {
            GWizSettings.FeedsSpeedsApp.plungeModeIdx#1 = this.plungeMode.selectedIndex;
            entryMode = this.plungeMode.selectedItem.label;
            entryModeIdx = this.plungeMode.selectedIndex;
         }
      }
      
      private function _GWizCCPocketOptions_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.addEventListener("valueCommit",this.__radiogroup2_valueCommit);
         _loc1_.initialized(this,"radiogroup2");
         this.radiogroup2 = _loc1_;
         BindingManager.executeBindings(this,"radiogroup2",this.radiogroup2);
         return _loc1_;
      }
      
      public function __radiogroup2_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCPocketOptions_Array1_c() : Array
      {
         return [this._GWizCCPocketOptions_VGroup1_c()];
      }
      
      private function _GWizCCPocketOptions_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCPocketOptions_HGroup1_c(),this._GWizCCPocketOptions_HGroup2_c(),this._GWizCCPocketOptions_HGroup3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.height = 30;
         _loc1_.mxmlContent = [this._GWizCCPocketOptions_Label1_c(),this._GWizCCPocketOptions_RadioButton1_i(),this._GWizCCPocketOptions_RadioButton2_i(),this._GWizCCPocketOptions_RadioButton3_i(),this._GWizCCPocketOptions_RadioButton4_i(),this._GWizCCPocketOptions_RadioButton5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tool:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "HSS";
         _loc1_.groupName = "radiogroup2";
         _loc1_.id = "HSS";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HSS = _loc1_;
         BindingManager.executeBindings(this,"HSS",this.HSS);
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "HSS HP";
         _loc1_.groupName = "radiogroup2";
         _loc1_.id = "HSSHP";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HSSHP = _loc1_;
         BindingManager.executeBindings(this,"HSSHP",this.HSSHP);
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Carbide";
         _loc1_.groupName = "radiogroup2";
         _loc1_.selected = true;
         _loc1_.id = "Carbide";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Carbide = _loc1_;
         BindingManager.executeBindings(this,"Carbide",this.Carbide);
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_RadioButton4_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Carbide HP";
         _loc1_.groupName = "radiogroup2";
         _loc1_.id = "CarbideHP";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CarbideHP = _loc1_;
         BindingManager.executeBindings(this,"CarbideHP",this.CarbideHP);
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_RadioButton5_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Carbide TiAlN";
         _loc1_.groupName = "radiogroup2";
         _loc1_.id = "CarbideTiAlN";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CarbideTiAlN = _loc1_;
         BindingManager.executeBindings(this,"CarbideTiAlN",this.CarbideTiAlN);
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.height = 30;
         _loc1_.mxmlContent = [this._GWizCCPocketOptions_GWizNumStepOvr1_i(),this._GWizCCPocketOptions_GWizNumStepOvr2_i(),this._GWizCCPocketOptions_GWizNumStepOvr3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Tool Dia.:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__ToolDia_initialize);
         _loc1_.addEventListener("change",this.__ToolDia_change);
         _loc1_.id = "ToolDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolDia = _loc1_;
         BindingManager.executeBindings(this,"ToolDia",this.ToolDia);
         return _loc1_;
      }
      
      public function __ToolDia_initialize(param1:FlexEvent) : void
      {
         this.ToolDia.setVal(0.5);
      }
      
      public function __ToolDia_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCPocketOptions_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Flutes:";
         _loc1_.min = 1;
         _loc1_.max = 40;
         _loc1_.steps = 1;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__Flutes_initialize);
         _loc1_.addEventListener("change",this.__Flutes_change);
         _loc1_.id = "Flutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Flutes = _loc1_;
         BindingManager.executeBindings(this,"Flutes",this.Flutes);
         return _loc1_;
      }
      
      public function __Flutes_initialize(param1:FlexEvent) : void
      {
         this.Flutes.setVal(4);
      }
      
      public function __Flutes_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCPocketOptions_GWizNumStepOvr3_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Stickout:";
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__Stickout_initialize);
         _loc1_.addEventListener("change",this.__Stickout_change);
         _loc1_.id = "Stickout";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Stickout = _loc1_;
         BindingManager.executeBindings(this,"Stickout",this.Stickout);
         return _loc1_;
      }
      
      public function __Stickout_initialize(param1:FlexEvent) : void
      {
         this.Stickout.setVal(1);
      }
      
      public function __Stickout_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCPocketOptions_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.height = 30;
         _loc1_.mxmlContent = [this._GWizCCPocketOptions_Label2_i(),this._GWizCCPocketOptions_DropDownList1_i(),this._GWizCCPocketOptions_Label3_i(),this._GWizCCPocketOptions_DropDownList2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Roughing:";
         _loc1_.toolTip = "Roughing Strategy allows toolchanges and better toolpaths to improve roughing performance.";
         _loc1_.id = "roughLbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.roughLbl = _loc1_;
         BindingManager.executeBindings(this,"roughLbl",this.roughLbl);
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "name";
         _loc1_.typicalItem = "Large Corncob Rougher + HSM";
         _loc1_.toolTip = "Roughing Strategy allows toolchanges and better toolpaths to improve roughing performance.";
         _loc1_.addEventListener("change",this.__roughStrat_change);
         _loc1_.id = "roughStrat";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.roughStrat = _loc1_;
         BindingManager.executeBindings(this,"roughStrat",this.roughStrat);
         return _loc1_;
      }
      
      public function __roughStrat_change(param1:IndexChangeEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCPocketOptions_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Entry:";
         _loc1_.id = "_GWizCCPocketOptions_Label3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCPocketOptions_Label3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCPocketOptions_Label3",this._GWizCCPocketOptions_Label3);
         return _loc1_;
      }
      
      private function _GWizCCPocketOptions_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "label";
         _loc1_.toolTip = "Select cut entry mode.";
         _loc1_.selectedIndex = 1;
         _loc1_.addEventListener("change",this.__plungeMode_change);
         _loc1_.addEventListener("valueCommit",this.__plungeMode_valueCommit);
         _loc1_.id = "plungeMode";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.plungeMode = _loc1_;
         BindingManager.executeBindings(this,"plungeMode",this.plungeMode);
         return _loc1_;
      }
      
      public function __plungeMode_change(param1:IndexChangeEvent) : void
      {
         this.recalc();
      }
      
      public function __plungeMode_valueCommit(param1:FlexEvent) : void
      {
         this.syncPlungeWithFSTab();
      }
      
      private function _GWizCCPocketOptions_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizCCWRecalc.roughingStrategies;
         },null,"roughStrat.dataProvider");
         result[1] = new Binding(this,function():int
         {
            return GWizCCWMillOptions.roughStrat;
         },null,"roughStrat.selectedIndex");
         result[2] = new Binding(this,function():Boolean
         {
            return showEntry;
         },null,"_GWizCCPocketOptions_Label3.visible");
         result[3] = new Binding(this,function():IList
         {
            return GWizFeedsSpeeds2.PlungeModes;
         },null,"plungeMode.dataProvider");
         result[4] = new Binding(this,function():Boolean
         {
            return showEntry;
         },null,"plungeMode.visible");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Carbide() : RadioButton
      {
         return this._2076430148Carbide;
      }
      
      public function set Carbide(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2076430148Carbide;
         if(_loc2_ !== param1)
         {
            this._2076430148Carbide = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Carbide",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CarbideHP() : RadioButton
      {
         return this._1710422724CarbideHP;
      }
      
      public function set CarbideHP(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1710422724CarbideHP;
         if(_loc2_ !== param1)
         {
            this._1710422724CarbideHP = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CarbideHP",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CarbideTiAlN() : RadioButton
      {
         return this._276736142CarbideTiAlN;
      }
      
      public function set CarbideTiAlN(param1:RadioButton) : void
      {
         var _loc2_:Object = this._276736142CarbideTiAlN;
         if(_loc2_ !== param1)
         {
            this._276736142CarbideTiAlN = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CarbideTiAlN",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Flutes() : GWizNumStepOvr
      {
         return this._2107381107Flutes;
      }
      
      public function set Flutes(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._2107381107Flutes;
         if(_loc2_ !== param1)
         {
            this._2107381107Flutes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Flutes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HSS() : RadioButton
      {
         return this._71848HSS;
      }
      
      public function set HSS(param1:RadioButton) : void
      {
         var _loc2_:Object = this._71848HSS;
         if(_loc2_ !== param1)
         {
            this._71848HSS = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HSS",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HSSHP() : RadioButton
      {
         return this._69048240HSSHP;
      }
      
      public function set HSSHP(param1:RadioButton) : void
      {
         var _loc2_:Object = this._69048240HSSHP;
         if(_loc2_ !== param1)
         {
            this._69048240HSSHP = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HSSHP",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Stickout() : GWizNumStepOvr
      {
         return this._1596369118Stickout;
      }
      
      public function set Stickout(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1596369118Stickout;
         if(_loc2_ !== param1)
         {
            this._1596369118Stickout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Stickout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolDia() : GWizNumStepOvr
      {
         return this._524530596ToolDia;
      }
      
      public function set ToolDia(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._524530596ToolDia;
         if(_loc2_ !== param1)
         {
            this._524530596ToolDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get plungeMode() : DropDownList
      {
         return this._1464755574plungeMode;
      }
      
      public function set plungeMode(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1464755574plungeMode;
         if(_loc2_ !== param1)
         {
            this._1464755574plungeMode = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"plungeMode",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get radiogroup2() : RadioButtonGroup
      {
         return this._164873550radiogroup2;
      }
      
      public function set radiogroup2(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._164873550radiogroup2;
         if(_loc2_ !== param1)
         {
            this._164873550radiogroup2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radiogroup2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get roughLbl() : Label
      {
         return this._6516163roughLbl;
      }
      
      public function set roughLbl(param1:Label) : void
      {
         var _loc2_:Object = this._6516163roughLbl;
         if(_loc2_ !== param1)
         {
            this._6516163roughLbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"roughLbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get roughStrat() : DropDownList
      {
         return this._1960055573roughStrat;
      }
      
      public function set roughStrat(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1960055573roughStrat;
         if(_loc2_ !== param1)
         {
            this._1960055573roughStrat = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"roughStrat",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get recalc() : Function
      {
         return this._934922488recalc;
      }
      
      public function set recalc(param1:Function) : void
      {
         var _loc2_:Object = this._934922488recalc;
         if(_loc2_ !== param1)
         {
            this._934922488recalc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"recalc",_loc2_,param1));
            }
         }
      }
   }
}
