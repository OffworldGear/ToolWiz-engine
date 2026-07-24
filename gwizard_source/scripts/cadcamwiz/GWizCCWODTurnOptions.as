package cadcamwiz
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import configinfo.GWizLatheTools;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IVisualElement;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.DropDownList;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizCCWODTurnOptions extends Group implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1150107804FinishPass:GWizNumStep;
      
      public var _GWizCCWODTurnOptions_Label6:Label;
      
      public var _GWizCCWODTurnOptions_Label7:Label;
      
      private var _1275124271doFinishPass:CheckBox;
      
      private var _269472892finishLeadAngle:NumericStepper;
      
      private var _416625568finishingInsSize:DropDownList;
      
      private var _416670425finishingInsType:DropDownList;
      
      private var _1362519476odTurnOptions:GWizForePanel;
      
      private var _1668174366roughLeadAngle:NumericStepper;
      
      private var _354148422roughingInsSize:DropDownList;
      
      private var _354193279roughingInsType:DropDownList;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var recalc:Function = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWODTurnOptions()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWODTurnOptions_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWODTurnOptionsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWODTurnOptions[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this._GWizCCWODTurnOptions_GWizForePanel1_i();
         this.addEventListener("creationComplete",this.___GWizCCWODTurnOptions_Group1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWODTurnOptions._watcherSetupUtil = param1;
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
      
      public function onCC() : void
      {
         if(GWizCadCam.CADCAMWiz && GWizCadCam.CADCAMWiz.ccwLatheOptions)
         {
            this.selectedChild = this.odTurnOptions;
            this.roughingInsType.selectedIndex = GWizCCWSettings.roughingInsType;
            this.roughingInsSize.selectedIndex = GWizCCWSettings.roughingInsSize;
            this.finishingInsType.selectedIndex = GWizCCWSettings.finishingInsType;
            this.finishingInsSize.selectedIndex = GWizCCWSettings.finishingInsSize;
         }
         else
         {
            this.callLater(this.onCC);
         }
      }
      
      public function set selectedChild(param1:IVisualElement) : void
      {
         this.removeAllElements();
         this.addElement(param1);
      }
      
      private function _GWizCCWODTurnOptions_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Options";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWODTurnOptions_Array1_c);
         _loc1_.id = "odTurnOptions";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.odTurnOptions = _loc1_;
         BindingManager.executeBindings(this,"odTurnOptions",this.odTurnOptions);
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_Array1_c() : Array
      {
         return [this._GWizCCWODTurnOptions_VGroup1_c()];
      }
      
      private function _GWizCCWODTurnOptions_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWODTurnOptions_HGroup1_c(),this._GWizCCWODTurnOptions_HGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWODTurnOptions_Label1_c(),this._GWizCCWODTurnOptions_Label2_c(),this._GWizCCWODTurnOptions_DropDownList1_i(),this._GWizCCWODTurnOptions_Label3_c(),this._GWizCCWODTurnOptions_Spacer1_c(),this._GWizCCWODTurnOptions_DropDownList2_i(),this._GWizCCWODTurnOptions_Label4_c(),this._GWizCCWODTurnOptions_Spacer2_c(),this._GWizCCWODTurnOptions_NumericStepper1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Roughing: ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Insert Type: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__roughingInsType_valueCommit);
         _loc1_.id = "roughingInsType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.roughingInsType = _loc1_;
         BindingManager.executeBindings(this,"roughingInsType",this.roughingInsType);
         return _loc1_;
      }
      
      public function __roughingInsType_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWODTurnOptions_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Insert Size: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__roughingInsSize_valueCommit);
         _loc1_.id = "roughingInsSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.roughingInsSize = _loc1_;
         BindingManager.executeBindings(this,"roughingInsSize",this.roughingInsSize);
         return _loc1_;
      }
      
      public function __roughingInsSize_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWODTurnOptions_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Lead Angle";
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 90;
         _loc1_.stepSize = 1;
         _loc1_.width = 100;
         _loc1_.toolTip = "Angle of the cutting edge of insert to the workpiece. 0 degrees means the cut is straight in.";
         _loc1_.addEventListener("valueCommit",this.__roughLeadAngle_valueCommit);
         _loc1_.id = "roughLeadAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.roughLeadAngle = _loc1_;
         BindingManager.executeBindings(this,"roughLeadAngle",this.roughLeadAngle);
         return _loc1_;
      }
      
      public function __roughLeadAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWODTurnOptions_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWODTurnOptions_Label5_c(),this._GWizCCWODTurnOptions_CheckBox1_i(),this._GWizCCWODTurnOptions_GWizNumStep1_i(),this._GWizCCWODTurnOptions_Label6_i(),this._GWizCCWODTurnOptions_DropDownList3_i(),this._GWizCCWODTurnOptions_Label7_i(),this._GWizCCWODTurnOptions_Spacer3_c(),this._GWizCCWODTurnOptions_DropDownList4_i(),this._GWizCCWODTurnOptions_Label8_c(),this._GWizCCWODTurnOptions_Spacer4_c(),this._GWizCCWODTurnOptions_NumericStepper2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Finish:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.selected = true;
         _loc1_.addEventListener("change",this.__doFinishPass_change);
         _loc1_.id = "doFinishPass";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.doFinishPass = _loc1_;
         BindingManager.executeBindings(this,"doFinishPass",this.doFinishPass);
         return _loc1_;
      }
      
      public function __doFinishPass_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWODTurnOptions_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.0001;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.UnitLabel = "in";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("initialize",this.__FinishPass_initialize);
         _loc1_.addEventListener("change",this.__FinishPass_change);
         _loc1_.id = "FinishPass";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FinishPass = _loc1_;
         BindingManager.executeBindings(this,"FinishPass",this.FinishPass);
         return _loc1_;
      }
      
      public function __FinishPass_initialize(param1:FlexEvent) : void
      {
         this.FinishPass.setVal(0.03);
      }
      
      public function __FinishPass_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWODTurnOptions_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " Insert Type: ";
         _loc1_.id = "_GWizCCWODTurnOptions_Label6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWODTurnOptions_Label6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWODTurnOptions_Label6",this._GWizCCWODTurnOptions_Label6);
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_DropDownList3_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__finishingInsType_valueCommit);
         _loc1_.id = "finishingInsType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.finishingInsType = _loc1_;
         BindingManager.executeBindings(this,"finishingInsType",this.finishingInsType);
         return _loc1_;
      }
      
      public function __finishingInsType_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWODTurnOptions_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Insert Size: ";
         _loc1_.id = "_GWizCCWODTurnOptions_Label7";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWODTurnOptions_Label7 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWODTurnOptions_Label7",this._GWizCCWODTurnOptions_Label7);
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_DropDownList4_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__finishingInsSize_valueCommit);
         _loc1_.id = "finishingInsSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.finishingInsSize = _loc1_;
         BindingManager.executeBindings(this,"finishingInsSize",this.finishingInsSize);
         return _loc1_;
      }
      
      public function __finishingInsSize_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizCCWODTurnOptions_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Lead Angle";
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnOptions_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 90;
         _loc1_.stepSize = 1;
         _loc1_.width = 100;
         _loc1_.toolTip = "Angle of the cutting edge of insert to the workpiece. 0 degrees means the cut is straight in.";
         _loc1_.addEventListener("valueCommit",this.__finishLeadAngle_valueCommit);
         _loc1_.id = "finishLeadAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.finishLeadAngle = _loc1_;
         BindingManager.executeBindings(this,"finishLeadAngle",this.finishLeadAngle);
         return _loc1_;
      }
      
      public function __finishLeadAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function ___GWizCCWODTurnOptions_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCCWODTurnOptions_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizLatheTools.insTypes;
         },null,"roughingInsType.dataProvider");
         result[1] = new Binding(this,function():IList
         {
            return GWizLatheTools.insSizes;
         },null,"roughingInsSize.dataProvider");
         result[2] = new Binding(this,function():Boolean
         {
            return doFinishPass.selected;
         },null,"FinishPass.enabled");
         result[3] = new Binding(this,function():Boolean
         {
            return doFinishPass.selected;
         },null,"_GWizCCWODTurnOptions_Label6.enabled");
         result[4] = new Binding(this,function():IList
         {
            return GWizLatheTools.insTypes;
         },null,"finishingInsType.dataProvider");
         result[5] = new Binding(this,function():Boolean
         {
            return doFinishPass.selected;
         },null,"finishingInsType.enabled");
         result[6] = new Binding(this,function():Boolean
         {
            return doFinishPass.selected;
         },null,"_GWizCCWODTurnOptions_Label7.enabled");
         result[7] = new Binding(this,function():IList
         {
            return GWizLatheTools.insSizes;
         },null,"finishingInsSize.dataProvider");
         result[8] = new Binding(this,function():Boolean
         {
            return doFinishPass.selected;
         },null,"finishingInsSize.enabled");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get FinishPass() : GWizNumStep
      {
         return this._1150107804FinishPass;
      }
      
      public function set FinishPass(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1150107804FinishPass;
         if(_loc2_ !== param1)
         {
            this._1150107804FinishPass = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FinishPass",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get doFinishPass() : CheckBox
      {
         return this._1275124271doFinishPass;
      }
      
      public function set doFinishPass(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1275124271doFinishPass;
         if(_loc2_ !== param1)
         {
            this._1275124271doFinishPass = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"doFinishPass",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get finishLeadAngle() : NumericStepper
      {
         return this._269472892finishLeadAngle;
      }
      
      public function set finishLeadAngle(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._269472892finishLeadAngle;
         if(_loc2_ !== param1)
         {
            this._269472892finishLeadAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"finishLeadAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get finishingInsSize() : DropDownList
      {
         return this._416625568finishingInsSize;
      }
      
      public function set finishingInsSize(param1:DropDownList) : void
      {
         var _loc2_:Object = this._416625568finishingInsSize;
         if(_loc2_ !== param1)
         {
            this._416625568finishingInsSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"finishingInsSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get finishingInsType() : DropDownList
      {
         return this._416670425finishingInsType;
      }
      
      public function set finishingInsType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._416670425finishingInsType;
         if(_loc2_ !== param1)
         {
            this._416670425finishingInsType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"finishingInsType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get odTurnOptions() : GWizForePanel
      {
         return this._1362519476odTurnOptions;
      }
      
      public function set odTurnOptions(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1362519476odTurnOptions;
         if(_loc2_ !== param1)
         {
            this._1362519476odTurnOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"odTurnOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get roughLeadAngle() : NumericStepper
      {
         return this._1668174366roughLeadAngle;
      }
      
      public function set roughLeadAngle(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._1668174366roughLeadAngle;
         if(_loc2_ !== param1)
         {
            this._1668174366roughLeadAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"roughLeadAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get roughingInsSize() : DropDownList
      {
         return this._354148422roughingInsSize;
      }
      
      public function set roughingInsSize(param1:DropDownList) : void
      {
         var _loc2_:Object = this._354148422roughingInsSize;
         if(_loc2_ !== param1)
         {
            this._354148422roughingInsSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"roughingInsSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get roughingInsType() : DropDownList
      {
         return this._354193279roughingInsType;
      }
      
      public function set roughingInsType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._354193279roughingInsType;
         if(_loc2_ !== param1)
         {
            this._354193279roughingInsType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"roughingInsType",_loc2_,param1));
            }
         }
      }
   }
}
