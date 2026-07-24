package feedsspeeds
{
   import comps.GWizNumStep;
   import comps.GWizNumStepOvr;
   import comps.GWizPopUp;
   import configinfo.GWizConfigData;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.IList;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizSurfaceFinishLathe extends GWizPopUp implements IBindingClient
   {
      
      public static var lastRadiusChoice:Number = 0;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _72715IPR:GWizNumStep;
      
      private var _2607RA:Label;
      
      private var _81272RMS:Label;
      
      private var _399888310toolRadius:GWizNumStep;
      
      private var _2040574423toolRadiusCB:DropDownList;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var parm:GWizNumStepOvr;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizSurfaceFinishLathe()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizSurfaceFinishLathe_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizSurfaceFinishLatheWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizSurfaceFinishLathe[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.height = 200;
         this.width = 500;
         this.verticalAlign = "middle";
         this.title = "Surface Finish";
         this.horizontalAlign = "center";
         this.okLabel = "Save IPR";
         this.mxmlContent = [this._GWizSurfaceFinishLathe_HGroup1_c(),this._GWizSurfaceFinishLathe_GWizNumStep2_i(),this._GWizSurfaceFinishLathe_HGroup2_c()];
         this.addEventListener("creationComplete",this.___GWizSurfaceFinishLathe_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizSurfaceFinishLathe._watcherSetupUtil = param1;
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
      
      private function init() : void
      {
         this.toolRadiusCB.selectedIndex = 0;
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            this.IPR.toolTip = "Feedrate in Inches per revolution";
            this.IPR.titleTxt = "IPR";
         }
         else
         {
            this.IPR.toolTip = "Feedrate in mm per revolution";
            this.IPR.titleTxt = "MMPR";
         }
         this.toolRadius.setVal(lastRadiusChoice);
      }
      
      public function initParm(param1:GWizNumStepOvr) : void
      {
         this.parm = param1;
         this.IPR.setVal(this.parm.getVal());
      }
      
      private function exit() : void
      {
         lastRadiusChoice = this.toolRadius.getVal();
         super.close();
      }
      
      private function recalc() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:Number = 0.0313;
         if(this.IPR == null)
         {
            return;
         }
         _loc1_ = this.toolRadius.getVal();
         _loc2_ = this.IPR.getVal() * this.IPR.getVal() / (24 * _loc1_) * 1000000;
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            this.RA.text = "RA Finish (µ”) " + GWizUtils.roundHundredths(_loc2_);
            this.RMS.text = "RMS Finish (µ”) " + GWizUtils.roundHundredths(_loc2_ * 1.11);
         }
         else
         {
            this.RA.text = "RA Finish (microns) " + GWizUtils.roundHundredths(_loc2_ / 39.37);
            this.RMS.text = "RMS Finish (microns) " + GWizUtils.roundHundredths(_loc2_ / 39.37 * 1.11);
         }
      }
      
      private function setNoseRadius() : void
      {
         this.toolRadius.setVal(this.toolRadiusCB.selectedItem.radius);
      }
      
      private function saveFeedsSpeeds() : void
      {
         if(this.parm != null)
         {
            this.parm.setValOverride(this.IPR.getVal());
         }
         this.exit();
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.exit();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.saveFeedsSpeeds();
      }
      
      private function _GWizSurfaceFinishLathe_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizSurfaceFinishLathe_Label1_c(),this._GWizSurfaceFinishLathe_GWizNumStep1_i(),this._GWizSurfaceFinishLathe_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishLathe_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Nose Radius";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishLathe_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "";
         _loc1_.min = 0;
         _loc1_.max = 15;
         _loc1_.steps = 0.001;
         _loc1_.specKeys = "+-*/x%=sStTrRcC";
         _loc1_.toolTip = "Tool nose radius";
         _loc1_.fatSpacer = false;
         _loc1_.addEventListener("valueCommit",this.__toolRadius_valueCommit);
         _loc1_.id = "toolRadius";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolRadius = _loc1_;
         BindingManager.executeBindings(this,"toolRadius",this.toolRadius);
         return _loc1_;
      }
      
      public function __toolRadius_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizSurfaceFinishLathe_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.toolTip = "Standard insert tool nose radius values";
         _loc1_.percentWidth = 100;
         _loc1_.addEventListener("valueCommit",this.__toolRadiusCB_valueCommit);
         _loc1_.id = "toolRadiusCB";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolRadiusCB = _loc1_;
         BindingManager.executeBindings(this,"toolRadiusCB",this.toolRadiusCB);
         return _loc1_;
      }
      
      public function __toolRadiusCB_valueCommit(param1:FlexEvent) : void
      {
         this.setNoseRadius();
      }
      
      private function _GWizSurfaceFinishLathe_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "IPR";
         _loc1_.min = 0.0001;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Feedrate in Inches per revolution";
         _loc1_.addEventListener("valueCommit",this.__IPR_valueCommit);
         _loc1_.id = "IPR";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.IPR = _loc1_;
         BindingManager.executeBindings(this,"IPR",this.IPR);
         return _loc1_;
      }
      
      public function __IPR_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizSurfaceFinishLathe_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizSurfaceFinishLathe_Label2_i(),this._GWizSurfaceFinishLathe_Label3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishLathe_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "RA";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RA = _loc1_;
         BindingManager.executeBindings(this,"RA",this.RA);
         return _loc1_;
      }
      
      private function _GWizSurfaceFinishLathe_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "RMS";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RMS = _loc1_;
         BindingManager.executeBindings(this,"RMS",this.RMS);
         return _loc1_;
      }
      
      public function ___GWizSurfaceFinishLathe_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.init();
      }
      
      private function _GWizSurfaceFinishLathe_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizConfigData.InsertNoseRadiusList;
         },null,"toolRadiusCB.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get IPR() : GWizNumStep
      {
         return this._72715IPR;
      }
      
      public function set IPR(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._72715IPR;
         if(_loc2_ !== param1)
         {
            this._72715IPR = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"IPR",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RA() : Label
      {
         return this._2607RA;
      }
      
      public function set RA(param1:Label) : void
      {
         var _loc2_:Object = this._2607RA;
         if(_loc2_ !== param1)
         {
            this._2607RA = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RA",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RMS() : Label
      {
         return this._81272RMS;
      }
      
      public function set RMS(param1:Label) : void
      {
         var _loc2_:Object = this._81272RMS;
         if(_loc2_ !== param1)
         {
            this._81272RMS = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RMS",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolRadius() : GWizNumStep
      {
         return this._399888310toolRadius;
      }
      
      public function set toolRadius(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._399888310toolRadius;
         if(_loc2_ !== param1)
         {
            this._399888310toolRadius = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolRadius",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolRadiusCB() : DropDownList
      {
         return this._2040574423toolRadiusCB;
      }
      
      public function set toolRadiusCB(param1:DropDownList) : void
      {
         var _loc2_:Object = this._2040574423toolRadiusCB;
         if(_loc2_ !== param1)
         {
            this._2040574423toolRadiusCB = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolRadiusCB",_loc2_,param1));
            }
         }
      }
   }
}
