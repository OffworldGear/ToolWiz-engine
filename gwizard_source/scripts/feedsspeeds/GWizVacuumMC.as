package feedsspeeds
{
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizVacuumMC extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizVacuumMC_Label3:Label;
      
      public var _GWizVacuumMC_Label4:Label;
      
      public var _GWizVacuumMC_Label5:Label;
      
      public var _GWizVacuumMC_Label7:Label;
      
      public var _GWizVacuumMC_Label8:Label;
      
      private var _97618667force:Label;
      
      private var _995410849partHt:Label;
      
      private var _858539633powerLbl:Label;
      
      private var _909893934safety:GWizNumStep;
      
      private var _1853231955surface:GWizNumStep;
      
      private var _1885433012torqueLbl:Label;
      
      private var _824080459vacuum:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizVacuumMC()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizVacuumMC_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizVacuumMCWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizVacuumMC[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.okLabel = "Limit Spindle Power";
         this.title = "Vacuum Fixture Mini-Calc";
         this.width = 600;
         this.height = 300;
         this.mxmlContent = [this._GWizVacuumMC_VGroup1_c()];
         this.addEventListener("creationComplete",this.___GWizVacuumMC_GWizPopUp1_creationComplete);
         this.addEventListener("click",this.___GWizVacuumMC_GWizPopUp1_click);
         this.addEventListener("keyUp",this.___GWizVacuumMC_GWizPopUp1_keyUp);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizVacuumMC._watcherSetupUtil = param1;
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
         GWizNumStep.checkUnitsCC.addFunction("GWizVacuumMC",this.checkUnits,true);
         this.checkUnits();
         this.recalc();
      }
      
      private function recalc() : Number
      {
         if(GWizSettings.FeedsSpeedsApp == null)
         {
            return 0;
         }
         this.vacuum.titleColor = 16777215;
         this.surface.titleColor = 16777215;
         var _loc1_:String = " inches";
         var _loc2_:String = " lbs";
         var _loc3_:Number = this.vacuum.value * this.surface.value * 0.5;
         var _loc4_:String = " oz-in";
         if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            _loc1_ = " mm";
            _loc3_ /= 2.2;
            _loc2_ = " kgs";
            _loc4_ = " N-m";
         }
         this.partHt.text = "  " + GWizUtils.roundBigTenths2Str(this.surface.value / 25,true) + _loc1_ + " (taller parts have leverage to pop off)";
         this.force.text = "  " + GWizUtils.roundBigTenths2Str(_loc3_) + _loc2_;
         var _loc5_:Number;
         var _loc6_:Number = _loc5_ = (_loc5_ = (_loc5_ = this.vacuum.value * this.surface.value * 0.5 * GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam / 2) / this.safety.value) * 16;
         if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            _loc6_ *= 0.0070615518333333;
         }
         this.torqueLbl.text = "  " + GWizUtils.roundBigTenths2Str(_loc6_) + _loc4_;
         return _loc5_;
      }
      
      private function checkUnits(param1:Object = null) : Boolean
      {
         this.recalc();
         return true;
      }
      
      override public function onOk(param1:Event) : void
      {
         if(GWizSettings.FeedsSpeedsApp == null)
         {
            return;
         }
         GWizSettings.FeedsSpeedsApp.Torque.setValOverride(this.recalc());
         this.callLater(GWizSettings.FeedsSpeedsApp.recalc);
         super.onOk(param1);
      }
      
      private function _GWizVacuumMC_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizVacuumMC_HGroup1_c(),this._GWizVacuumMC_Label2_c(),this._GWizVacuumMC_HGroup2_c(),this._GWizVacuumMC_Label6_c(),this._GWizVacuumMC_HGroup3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizVacuumMC_Label1_c(),this._GWizVacuumMC_Button1_c(),this._GWizVacuumMC_Button2_c(),this._GWizVacuumMC_Button3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Pump Type:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Positive Displacement";
         _loc1_.addEventListener("click",this.___GWizVacuumMC_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizVacuumMC_Button1_click(param1:MouseEvent) : void
      {
         this.vacuum.value = 28;
      }
      
      private function _GWizVacuumMC_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Regenerative Blower";
         _loc1_.addEventListener("click",this.___GWizVacuumMC_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizVacuumMC_Button2_click(param1:MouseEvent) : void
      {
         this.vacuum.value = 12;
      }
      
      private function _GWizVacuumMC_Button3_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Venturi";
         _loc1_.addEventListener("click",this.___GWizVacuumMC_Button3_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizVacuumMC_Button3_click(param1:MouseEvent) : void
      {
         this.vacuum.value = 22;
      }
      
      private function _GWizVacuumMC_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizVacuumMC_VGroup2_c(),this._GWizVacuumMC_VGroup3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizVacuumMC_Label3_i(),this._GWizVacuumMC_Label4_i(),this._GWizVacuumMC_Label5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Vacuum:";
         _loc1_.id = "_GWizVacuumMC_Label3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizVacuumMC_Label3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizVacuumMC_Label3",this._GWizVacuumMC_Label3);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Part Surface Area:";
         _loc1_.id = "_GWizVacuumMC_Label4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizVacuumMC_Label4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizVacuumMC_Label4",this._GWizVacuumMC_Label4);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Safety Factor:";
         _loc1_.id = "_GWizVacuumMC_Label5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizVacuumMC_Label5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizVacuumMC_Label5",this._GWizVacuumMC_Label5);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizVacuumMC_GWizNumStep1_i(),this._GWizVacuumMC_GWizNumStep2_i(),this._GWizVacuumMC_GWizNumStep3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.1;
         _loc1_.value = 29;
         _loc1_.fatSpacer = false;
         _loc1_.UnitLabel = "in-Hg";
         _loc1_.titleColor = 16777215;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.id = "vacuum";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.vacuum = _loc1_;
         BindingManager.executeBindings(this,"vacuum",this.vacuum);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.1;
         _loc1_.value = 4;
         _loc1_.fatSpacer = false;
         _loc1_.UnitLabel = "sq in";
         _loc1_.titleColor = 16777215;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.id = "surface";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.surface = _loc1_;
         BindingManager.executeBindings(this,"surface",this.surface);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 10;
         _loc1_.steps = 0.1;
         _loc1_.value = 2;
         _loc1_.fatSpacer = false;
         _loc1_.usesMetric = false;
         _loc1_.id = "safety";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.safety = _loc1_;
         BindingManager.executeBindings(this,"safety",this.safety);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizVacuumMC_VGroup4_c(),this._GWizVacuumMC_VGroup5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizVacuumMC_Label7_i(),this._GWizVacuumMC_Label8_i(),this._GWizVacuumMC_Label9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hold-down Force:";
         _loc1_.id = "_GWizVacuumMC_Label7";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizVacuumMC_Label7 = _loc1_;
         BindingManager.executeBindings(this,"_GWizVacuumMC_Label7",this._GWizVacuumMC_Label7);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max Part Height:";
         _loc1_.id = "_GWizVacuumMC_Label8";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizVacuumMC_Label8 = _loc1_;
         BindingManager.executeBindings(this,"_GWizVacuumMC_Label8",this._GWizVacuumMC_Label8);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Max Spindle Torque:";
         _loc1_.id = "powerLbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.powerLbl = _loc1_;
         BindingManager.executeBindings(this,"powerLbl",this.powerLbl);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizVacuumMC_Label10_i(),this._GWizVacuumMC_Label11_i(),this._GWizVacuumMC_Label12_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "984 lbs";
         _loc1_.id = "force";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.force = _loc1_;
         BindingManager.executeBindings(this,"force",this.force);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "partHt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.partHt = _loc1_;
         BindingManager.executeBindings(this,"partHt",this.partHt);
         return _loc1_;
      }
      
      private function _GWizVacuumMC_Label12_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "1.1 HP";
         _loc1_.id = "torqueLbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.torqueLbl = _loc1_;
         BindingManager.executeBindings(this,"torqueLbl",this.torqueLbl);
         return _loc1_;
      }
      
      public function ___GWizVacuumMC_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizVacuumMC_GWizPopUp1_click(param1:MouseEvent) : void
      {
         this.recalc();
      }
      
      public function ___GWizVacuumMC_GWizPopUp1_keyUp(param1:KeyboardEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizVacuumMC_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return vacuum.height;
         },null,"_GWizVacuumMC_Label3.height");
         result[1] = new Binding(this,function():Number
         {
            return vacuum.height;
         },null,"_GWizVacuumMC_Label4.height");
         result[2] = new Binding(this,function():Number
         {
            return vacuum.height;
         },null,"_GWizVacuumMC_Label5.height");
         result[3] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.MBAR_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"vacuum.metUnits");
         result[4] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.INHG_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"vacuum.impUnits");
         result[5] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.SQCM_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"surface.metUnits");
         result[6] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.SQIN_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"surface.impUnits");
         result[7] = new Binding(this,function():Number
         {
            return vacuum.height;
         },null,"_GWizVacuumMC_Label7.height");
         result[8] = new Binding(this,function():Number
         {
            return vacuum.height;
         },null,"_GWizVacuumMC_Label8.height");
         result[9] = new Binding(this,function():Number
         {
            return vacuum.height;
         },null,"powerLbl.height");
         result[10] = new Binding(this,function():Number
         {
            return vacuum.height;
         },null,"force.height");
         result[11] = new Binding(this,function():Number
         {
            return vacuum.height;
         },null,"partHt.height");
         result[12] = new Binding(this,function():Number
         {
            return vacuum.height;
         },null,"torqueLbl.height");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get force() : Label
      {
         return this._97618667force;
      }
      
      public function set force(param1:Label) : void
      {
         var _loc2_:Object = this._97618667force;
         if(_loc2_ !== param1)
         {
            this._97618667force = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"force",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get partHt() : Label
      {
         return this._995410849partHt;
      }
      
      public function set partHt(param1:Label) : void
      {
         var _loc2_:Object = this._995410849partHt;
         if(_loc2_ !== param1)
         {
            this._995410849partHt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"partHt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get powerLbl() : Label
      {
         return this._858539633powerLbl;
      }
      
      public function set powerLbl(param1:Label) : void
      {
         var _loc2_:Object = this._858539633powerLbl;
         if(_loc2_ !== param1)
         {
            this._858539633powerLbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"powerLbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get safety() : GWizNumStep
      {
         return this._909893934safety;
      }
      
      public function set safety(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._909893934safety;
         if(_loc2_ !== param1)
         {
            this._909893934safety = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"safety",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get surface() : GWizNumStep
      {
         return this._1853231955surface;
      }
      
      public function set surface(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1853231955surface;
         if(_loc2_ !== param1)
         {
            this._1853231955surface = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"surface",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get torqueLbl() : Label
      {
         return this._1885433012torqueLbl;
      }
      
      public function set torqueLbl(param1:Label) : void
      {
         var _loc2_:Object = this._1885433012torqueLbl;
         if(_loc2_ !== param1)
         {
            this._1885433012torqueLbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"torqueLbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get vacuum() : GWizNumStep
      {
         return this._824080459vacuum;
      }
      
      public function set vacuum(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._824080459vacuum;
         if(_loc2_ !== param1)
         {
            this._824080459vacuum = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"vacuum",_loc2_,param1));
            }
         }
      }
   }
}
