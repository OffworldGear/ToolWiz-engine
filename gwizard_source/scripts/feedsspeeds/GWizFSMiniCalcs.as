package feedsspeeds
{
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import skins.GWizStylePalette;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import tools.GWizToolDef;
   import utils.GATracker;
   
   use namespace mx_internal;
   
   public class GWizFSMiniCalcs extends HGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _342720287Interpolate:Button;
      
      private var _1901300397Plunge:Button;
      
      private var _2539570Ramp:Button;
      
      private var _839688064SurfaceFinish:Button;
      
      private var _1740213291Vacuum:Button;
      
      public var _GWizFSMiniCalcs_Label1:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var td:GWizToolDef = null;
      
      public var fsr:Function = null;
      
      public var setWidth:Function = null;
      
      public var fsm:GWizFeedSpeedMath = null;
      
      public const INTERPOLATE_LABEL:String = "Helix";
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizFSMiniCalcs()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizFSMiniCalcs_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizFSMiniCalcsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizFSMiniCalcs[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.horizontalAlign = "center";
         this.verticalAlign = "middle";
         this.mxmlContent = [this._GWizFSMiniCalcs_Label1_i(),this._GWizFSMiniCalcs_Button1_i(),this._GWizFSMiniCalcs_Button2_i(),this._GWizFSMiniCalcs_Button3_i(),this._GWizFSMiniCalcs_Button4_i(),this._GWizFSMiniCalcs_Button5_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizFSMiniCalcs._watcherSetupUtil = param1;
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
      
      public function setInterpolate2CutDepth(param1:Boolean) : void
      {
         if(param1)
         {
            this.Interpolate.label = "Cut Depth";
            this.Interpolate.toolTip = "Calculate cut depth based on insert";
            this.Vacuum.visible = false;
         }
         else
         {
            this.Interpolate.label = this.INTERPOLATE_LABEL;
            this.Interpolate.toolTip = "Pop up hole interpolation calculator";
         }
      }
      
      private function showSurfaceFinish() : void
      {
         var _loc1_:GWizSurfaceFinishMill = null;
         var _loc2_:GWizSurfaceFinishLathe = null;
         if(GWizMachSettings.isMill(GWizMachSettings.currMachType))
         {
            _loc1_ = GWizSurfaceFinishMill(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizSurfaceFinishMill,true));
            if(_loc1_)
            {
               _loc1_.init(this.fsr,this.fsm,this.setWidth);
            }
         }
         else if(this.td.IPT)
         {
            _loc2_ = GWizSurfaceFinishLathe(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizSurfaceFinishLathe,true));
            if(_loc2_)
            {
               _loc2_.initParm(this.td.IPT);
            }
         }
      }
      
      private function doInterpolate() : void
      {
         var _loc1_:GWizInterpMC = null;
         var _loc2_:GWizThreadingCutDepthMC = null;
         var _loc3_:GWizTurningCutDepthMC = null;
         if(this.Interpolate.label == this.INTERPOLATE_LABEL)
         {
            _loc1_ = GWizInterpMC(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizInterpMC,true));
         }
         else if(GWizSettings.FeedsSpeedsApp.Tool.selectedLabel.indexOf("Threading") >= 0)
         {
            _loc2_ = GWizThreadingCutDepthMC(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizThreadingCutDepthMC,true));
         }
         else
         {
            _loc3_ = GWizTurningCutDepthMC(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizTurningCutDepthMC,true));
         }
      }
      
      private function doRamping() : void
      {
         var _loc1_:GWizRampMC = GWizRampMC(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizRampMC,true));
      }
      
      private function doPlunge() : void
      {
         var _loc1_:GWizPlungeMC = GWizPlungeMC(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizPlungeMC,true));
      }
      
      private function doVacuum() : void
      {
         var _loc1_:GWizVacuumMC = GWizVacuumMC(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizVacuumMC,true));
      }
      
      private function pageView(param1:String) : void
      {
         GATracker.logPageView("MiniCalc/" + param1,"MiniCalc: " + param1);
      }
      
      private function doEstTEA() : void
      {
         var _loc1_:GWizTEAEst = GWizTEAEst(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizTEAEst,true));
         if(_loc1_)
         {
            _loc1_.setVars(GWizSettings.FeedsSpeedsApp.fsm.effDiam,GWizSettings.FeedsSpeedsApp.cutWidth.getVal(),GWizSettings.FeedsSpeedsApp.setTEA);
         }
      }
      
      private function _GWizFSMiniCalcs_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Mini-Calcs";
         _loc1_.toolTip = "Feeds and Speeds calculators for special situations.";
         _loc1_.id = "_GWizFSMiniCalcs_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizFSMiniCalcs_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizFSMiniCalcs_Label1",this._GWizFSMiniCalcs_Label1);
         return _loc1_;
      }
      
      private function _GWizFSMiniCalcs_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Surface Finish";
         _loc1_.toolTip = "Pop up surface finish calculator for ballnoses and turning";
         _loc1_.addEventListener("click",this.__SurfaceFinish_click);
         _loc1_.id = "SurfaceFinish";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SurfaceFinish = _loc1_;
         BindingManager.executeBindings(this,"SurfaceFinish",this.SurfaceFinish);
         return _loc1_;
      }
      
      public function __SurfaceFinish_click(param1:MouseEvent) : void
      {
         this.showSurfaceFinish();
         this.pageView("SurfaceFinish");
      }
      
      private function _GWizFSMiniCalcs_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Helix";
         _loc1_.toolTip = "Pop up hole helical interpolation calculator";
         _loc1_.addEventListener("click",this.__Interpolate_click);
         _loc1_.id = "Interpolate";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Interpolate = _loc1_;
         BindingManager.executeBindings(this,"Interpolate",this.Interpolate);
         return _loc1_;
      }
      
      public function __Interpolate_click(param1:MouseEvent) : void
      {
         this.doInterpolate();
         this.pageView("Interpolate");
      }
      
      private function _GWizFSMiniCalcs_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Ramp";
         _loc1_.toolTip = "Pop feeds and speeds calculator for ramping";
         _loc1_.enabled = false;
         _loc1_.addEventListener("click",this.__Ramp_click);
         _loc1_.id = "Ramp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Ramp = _loc1_;
         BindingManager.executeBindings(this,"Ramp",this.Ramp);
         return _loc1_;
      }
      
      public function __Ramp_click(param1:MouseEvent) : void
      {
         this.doRamping();
         this.pageView("Ramping");
      }
      
      private function _GWizFSMiniCalcs_Button4_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Plunge";
         _loc1_.enabled = false;
         _loc1_.addEventListener("click",this.__Plunge_click);
         _loc1_.id = "Plunge";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Plunge = _loc1_;
         BindingManager.executeBindings(this,"Plunge",this.Plunge);
         return _loc1_;
      }
      
      public function __Plunge_click(param1:MouseEvent) : void
      {
         this.doPlunge();
         this.pageView("Plunge");
      }
      
      private function _GWizFSMiniCalcs_Button5_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Vacuum";
         _loc1_.addEventListener("click",this.__Vacuum_click);
         _loc1_.id = "Vacuum";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Vacuum = _loc1_;
         BindingManager.executeBindings(this,"Vacuum",this.Vacuum);
         return _loc1_;
      }
      
      public function __Vacuum_click(param1:MouseEvent) : void
      {
         this.doVacuum();
         this.pageView("Vacuum");
      }
      
      private function _GWizFSMiniCalcs_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            _GWizFSMiniCalcs_Label1.setStyle("color",param1);
         },"_GWizFSMiniCalcs_Label1.color");
         result[1] = new Binding(this,function():Boolean
         {
            return Interpolate.enabled;
         },null,"Interpolate.visible");
         result[2] = new Binding(this,function():Boolean
         {
            return Ramp.enabled;
         },null,"Ramp.visible");
         result[3] = new Binding(this,function():Boolean
         {
            return Plunge.enabled;
         },null,"Plunge.visible");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Interpolate() : Button
      {
         return this._342720287Interpolate;
      }
      
      public function set Interpolate(param1:Button) : void
      {
         var _loc2_:Object = this._342720287Interpolate;
         if(_loc2_ !== param1)
         {
            this._342720287Interpolate = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Interpolate",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Plunge() : Button
      {
         return this._1901300397Plunge;
      }
      
      public function set Plunge(param1:Button) : void
      {
         var _loc2_:Object = this._1901300397Plunge;
         if(_loc2_ !== param1)
         {
            this._1901300397Plunge = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Plunge",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Ramp() : Button
      {
         return this._2539570Ramp;
      }
      
      public function set Ramp(param1:Button) : void
      {
         var _loc2_:Object = this._2539570Ramp;
         if(_loc2_ !== param1)
         {
            this._2539570Ramp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Ramp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SurfaceFinish() : Button
      {
         return this._839688064SurfaceFinish;
      }
      
      public function set SurfaceFinish(param1:Button) : void
      {
         var _loc2_:Object = this._839688064SurfaceFinish;
         if(_loc2_ !== param1)
         {
            this._839688064SurfaceFinish = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SurfaceFinish",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Vacuum() : Button
      {
         return this._1740213291Vacuum;
      }
      
      public function set Vacuum(param1:Button) : void
      {
         var _loc2_:Object = this._1740213291Vacuum;
         if(_loc2_ !== param1)
         {
            this._1740213291Vacuum = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Vacuum",_loc2_,param1));
            }
         }
      }
   }
}
