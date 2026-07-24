package cadcamwiz
{
   import comps.GWizEstOpPickerAPI;
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizNumStepOvr;
   import configinfo.GWizSettings;
   import feedsspeeds.GWizFeedsSpeeds2;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.components.Scroller;
   import spark.components.VGroup;
   import spark.layouts.HorizontalLayout;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizCCWCustomFS extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _514227584FeedsSpeedsApp:GWizFeedsSpeeds2;
      
      private var _873181072PathLen:GWizNumStep;
      
      private var _1898379620TimeFactor:GWizNumStepOvr;
      
      public var _GWizCCWCustomFS_GWizForePanel1:GWizForePanel;
      
      public var _GWizCCWCustomFS_Label1:Label;
      
      public var _GWizCCWCustomFS_Label2:Label;
      
      private var _809612678contentGroup:VGroup;
      
      private var _542676939theScroller:Scroller;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var estInput:GWizCCWEstimatorInput;
      
      public var results:GWizCCWEstRecord;
      
      public var opPickerAPI:GWizEstOpPickerAPI;
      
      private var lastIPM:Number;
      
      private var lastRPM:Number;
      
      private var _1011090354opTime:Number = 0.0;
      
      private var _1449321101estTime:Number = 0.0;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWCustomFS()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.opPickerAPI = new GWizEstOpPickerAPI(this.UIToOp,this.OpToUI);
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWCustomFS_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWCustomFSWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWCustomFS[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.clipAndEnableScrolling = true;
         this.mxmlContent = [this._GWizCCWCustomFS_Scroller1_i()];
         this.addEventListener("creationComplete",this.___GWizCCWCustomFS_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWCustomFS._watcherSetupUtil = param1;
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
      
      public function showMe() : void
      {
      }
      
      public function UIToOp(param1:GWizCCWEstRecord) : void
      {
         param1.desc = this.estInput.EstDesc.text;
         param1.perimeter = this.PathLen.value;
         param1.fromFeedsSpeeds(this.FeedsSpeedsApp);
         param1.workcenter = GWizMachSettings.currMachine;
         param1.material = this.FeedsSpeedsApp.mmsDefault.MatChooser.Selection;
         param1.var1 = this.TimeFactor.value;
         param1.opTime += GWizMachSettings.getToolChangeTime();
         if(param1.hasOwnProperty("opTime"))
         {
            param1.oprate = this.estInput.HourlyRate.getVal() * (param1.opTime / 60);
         }
      }
      
      private function OpToUI(param1:GWizCCWEstRecord) : void
      {
         GWizUtils.assert(false);
         if(param1)
         {
            GWizSettings.FeedsSpeedsApp.api.SetupUIGeometry(param1.workcenter,"",param1.guid,param1.tool,param1.toolDia,param1.flutes,param1.stickout,param1.height,param1.width,param1.roughingTrue(),param1.hsmTrue(),param1.corncobTrue(),false,100,param1.toolOther,0,90,GWizFeedsSpeeds2.plungeModeToIdx(param1.entryMode),true);
            GWizSettings.FeedsSpeedsApp.estInput.EstDesc.text = param1.desc;
            GWizSettings.FeedsSpeedsApp.estInput.HourlyRate.value = param1.hourly;
            this.PathLen.value = param1.perimeter;
            this.TimeFactor.value = param1.var1;
         }
      }
      
      public function addToEstimate() : void
      {
         var _loc1_:int = 0;
         if(this.estInput)
         {
            _loc1_ = 0;
            while(_loc1_ < this.estInput.Qty.getVal())
            {
               this.results = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_FEEDSSPEEDS);
               this.UIToOp(this.results);
               if(!this.estInput.Expand.selected)
               {
                  this.results.qty = this.estInput.Qty.getVal();
                  this.results.opTime = this.estTime;
                  _loc1_ = this.estInput.Qty.getVal();
               }
               else
               {
                  this.results.qty = 1;
               }
               GWizCCWEstimatorInput.addEstimatorItem(this.results,GWizCCWEstimatorInput.isFixedCost());
               _loc1_++;
            }
         }
      }
      
      private function recalc(param1:Number, param2:Number) : void
      {
         if(isNaN(param2))
         {
            param2 = this.lastIPM;
         }
         if(isNaN(param1))
         {
            param1 = this.lastRPM;
         }
         if(this.estInput)
         {
            this.estInput.setHourlyRate();
         }
         this.opTime = this.PathLen.value / param2;
         this.estTime = this.opTime * (this.TimeFactor.value / 100);
         this.lastIPM = param2;
         this.lastRPM = param1;
      }
      
      private function _GWizCCWCustomFS_Scroller1_i() : Scroller
      {
         var _loc1_:Scroller = new Scroller();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.viewport = this._GWizCCWCustomFS_VGroup2_i();
         _loc1_.id = "theScroller";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theScroller = _loc1_;
         BindingManager.executeBindings(this,"theScroller",this.theScroller);
         return _loc1_;
      }
      
      private function _GWizCCWCustomFS_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.clipAndEnableScrolling = true;
         _loc1_.minHeight = 400;
         _loc1_.mxmlContent = [this._GWizCCWCustomFS_GWizForePanel1_i(),this._GWizCCWCustomFS_GWizFeedsSpeeds21_i()];
         _loc1_.id = "contentGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.contentGroup = _loc1_;
         BindingManager.executeBindings(this,"contentGroup",this.contentGroup);
         return _loc1_;
      }
      
      private function _GWizCCWCustomFS_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.layout = this._GWizCCWCustomFS_HorizontalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWCustomFS_Array3_c);
         _loc1_.id = "_GWizCCWCustomFS_GWizForePanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWCustomFS_GWizForePanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWCustomFS_GWizForePanel1",this._GWizCCWCustomFS_GWizForePanel1);
         return _loc1_;
      }
      
      private function _GWizCCWCustomFS_HorizontalLayout1_c() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = new HorizontalLayout();
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizCCWCustomFS_Array3_c() : Array
      {
         return [this._GWizCCWCustomFS_GWizNumStep1_i(),this._GWizCCWCustomFS_Spacer1_c(),this._GWizCCWCustomFS_Label1_i(),this._GWizCCWCustomFS_Spacer2_c(),this._GWizCCWCustomFS_Label2_i(),this._GWizCCWCustomFS_Spacer3_c(),this._GWizCCWCustomFS_GWizNumStepOvr1_i()];
      }
      
      private function _GWizCCWCustomFS_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Path Len:";
         _loc1_.min = -1000000;
         _loc1_.max = 1000000;
         _loc1_.steps = 0.0001;
         _loc1_.addEventListener("valueCommit",this.__PathLen_valueCommit);
         _loc1_.id = "PathLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PathLen = _loc1_;
         BindingManager.executeBindings(this,"PathLen",this.PathLen);
         return _loc1_;
      }
      
      public function __PathLen_valueCommit(param1:FlexEvent) : void
      {
         this.recalc(NaN,NaN);
      }
      
      private function _GWizCCWCustomFS_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWCustomFS_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizCCWCustomFS_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWCustomFS_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWCustomFS_Label1",this._GWizCCWCustomFS_Label1);
         return _loc1_;
      }
      
      private function _GWizCCWCustomFS_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWCustomFS_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizCCWCustomFS_Label2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWCustomFS_Label2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWCustomFS_Label2",this._GWizCCWCustomFS_Label2);
         return _loc1_;
      }
      
      private function _GWizCCWCustomFS_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWCustomFS_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Op Time Factor (%):  ";
         _loc1_.min = 100;
         _loc1_.max = 5000;
         _loc1_.steps = 1;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__TimeFactor_initialize);
         _loc1_.addEventListener("valueCommit",this.__TimeFactor_valueCommit);
         _loc1_.id = "TimeFactor";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TimeFactor = _loc1_;
         BindingManager.executeBindings(this,"TimeFactor",this.TimeFactor);
         return _loc1_;
      }
      
      public function __TimeFactor_initialize(param1:FlexEvent) : void
      {
         this.TimeFactor.setVal(120);
      }
      
      public function __TimeFactor_valueCommit(param1:FlexEvent) : void
      {
         this.recalc(NaN,NaN);
      }
      
      private function _GWizCCWCustomFS_GWizFeedsSpeeds21_i() : GWizFeedsSpeeds2
      {
         var _loc1_:GWizFeedsSpeeds2 = new GWizFeedsSpeeds2();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.labelWidths = 0;
         _loc1_.id = "FeedsSpeedsApp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FeedsSpeedsApp = _loc1_;
         BindingManager.executeBindings(this,"FeedsSpeedsApp",this.FeedsSpeedsApp);
         return _loc1_;
      }
      
      public function ___GWizCCWCustomFS_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCCWCustomFS_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return this.height;
         },null,"theScroller.maxHeight");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizCCWCustomFS_GWizForePanel1.labelBackgroundColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizCCWCustomFS_GWizForePanel1.labelColor");
         result[3] = new Binding(this,function():String
         {
            var _loc1_:* = "Operation Time: " + GWizUtils.formatMinToHMS(opTime);
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizCCWCustomFS_Label1.text");
         result[4] = new Binding(this,function():String
         {
            var _loc1_:* = "Estimate Time: " + GWizUtils.formatMinToHMS(estTime);
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizCCWCustomFS_Label2.text");
         result[5] = new Binding(this,function():String
         {
            var _loc1_:* = GWizFeedsSpeeds2.APP_NAME;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"FeedsSpeedsApp.name");
         result[6] = new Binding(this,function():Function
         {
            return recalc;
         },null,"FeedsSpeedsApp.recalcAuxFcn");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get FeedsSpeedsApp() : GWizFeedsSpeeds2
      {
         return this._514227584FeedsSpeedsApp;
      }
      
      public function set FeedsSpeedsApp(param1:GWizFeedsSpeeds2) : void
      {
         var _loc2_:Object = this._514227584FeedsSpeedsApp;
         if(_loc2_ !== param1)
         {
            this._514227584FeedsSpeedsApp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FeedsSpeedsApp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PathLen() : GWizNumStep
      {
         return this._873181072PathLen;
      }
      
      public function set PathLen(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._873181072PathLen;
         if(_loc2_ !== param1)
         {
            this._873181072PathLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PathLen",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TimeFactor() : GWizNumStepOvr
      {
         return this._1898379620TimeFactor;
      }
      
      public function set TimeFactor(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1898379620TimeFactor;
         if(_loc2_ !== param1)
         {
            this._1898379620TimeFactor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TimeFactor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contentGroup() : VGroup
      {
         return this._809612678contentGroup;
      }
      
      public function set contentGroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._809612678contentGroup;
         if(_loc2_ !== param1)
         {
            this._809612678contentGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theScroller() : Scroller
      {
         return this._542676939theScroller;
      }
      
      public function set theScroller(param1:Scroller) : void
      {
         var _loc2_:Object = this._542676939theScroller;
         if(_loc2_ !== param1)
         {
            this._542676939theScroller = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theScroller",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get opTime() : Number
      {
         return this._1011090354opTime;
      }
      
      private function set opTime(param1:Number) : void
      {
         var _loc2_:Object = this._1011090354opTime;
         if(_loc2_ !== param1)
         {
            this._1011090354opTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"opTime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get estTime() : Number
      {
         return this._1449321101estTime;
      }
      
      private function set estTime(param1:Number) : void
      {
         var _loc2_:Object = this._1449321101estTime;
         if(_loc2_ !== param1)
         {
            this._1449321101estTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"estTime",_loc2_,param1));
            }
         }
      }
   }
}
