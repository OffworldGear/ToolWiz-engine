package apps
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import flash.utils.getDefinitionByName;
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
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.VGroup;
   import spark.layouts.VerticalLayout;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizChatterPitch extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _2107381107Flutes:NumericStepper;
      
      private var _1791080911MarkSep:GWizNumStep;
      
      private var _2622S1:Label;
      
      private var _81330S10:Label;
      
      private var _81331S11:Label;
      
      private var _81332S12:Label;
      
      private var _2623S2:Label;
      
      private var _2624S3:Label;
      
      private var _2625S4:Label;
      
      private var _2626S5:Label;
      
      private var _2627S6:Label;
      
      private var _2628S7:Label;
      
      private var _2629S8:Label;
      
      private var _2630S9:Label;
      
      private var _82010SFM:GWizNumStep;
      
      public var _GWizChatterPitch_GWizForePanel1:GWizForePanel;
      
      public var _GWizChatterPitch_GWizForePanel2:GWizForePanel;
      
      public var _GWizChatterPitch_HGroup1:HGroup;
      
      public var _GWizChatterPitch_Label1:Label;
      
      public var _GWizChatterPitch_Label2:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizChatterPitch()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizChatterPitch_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizChatterPitchWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizChatterPitch[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.gap = 1;
         this.mxmlContent = [this._GWizChatterPitch_Label1_i(),this._GWizChatterPitch_GWizForePanel1_i(),this._GWizChatterPitch_GWizForePanel2_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizChatterPitch._watcherSetupUtil = param1;
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
      
      private function recalc() : void
      {
         var _loc1_:Number = 0.2 * this.SFM.getVal() / this.MarkSep.getVal();
         var _loc2_:Number = _loc1_ / this.Flutes.value;
         var _loc3_:int = int(_loc2_);
         this.S1.text = int(6 * _loc3_) + " rpm";
         this.S2.text = int(5 * _loc3_) + " rpm";
         this.S3.text = int(4 * _loc3_) + " rpm";
         this.S4.text = int(3 * _loc3_) + " rpm";
         this.S5.text = int(2 * _loc3_) + " rpm";
         this.S6.text = int(_loc3_ / 1) + " rpm";
         this.S7.text = int(_loc3_ / 2) + " rpm";
         this.S8.text = int(_loc3_ / 3) + " rpm";
         this.S9.text = int(_loc3_ / 4) + " rpm";
         this.S10.text = int(_loc3_ / 5) + " rpm";
         this.S11.text = int(_loc3_ / 6) + " rpm";
         this.S12.text = int(_loc3_ / 7) + " rpm";
      }
      
      private function _GWizChatterPitch_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Chatter Pitch Calculator";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("paddingBottom",5);
         _loc1_.setStyle("paddingTop",5);
         _loc1_.setStyle("paddingLeft",5);
         _loc1_.setStyle("fontSize",16);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizChatterPitch_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChatterPitch_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChatterPitch_Label1",this._GWizChatterPitch_Label1);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Inputs";
         _loc1_.layout = this._GWizChatterPitch_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizChatterPitch_Array2_c);
         _loc1_.id = "_GWizChatterPitch_GWizForePanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChatterPitch_GWizForePanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChatterPitch_GWizForePanel1",this._GWizChatterPitch_GWizForePanel1);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_VerticalLayout1_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizChatterPitch_Array2_c() : Array
      {
         return [this._GWizChatterPitch_GWizNumStep1_i(),this._GWizChatterPitch_GWizNumStep2_i(),this._GWizChatterPitch_HGroup1_i()];
      }
      
      private function _GWizChatterPitch_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0.0001;
         _loc1_.max = 1;
         _loc1_.steps = 0.0001;
         _loc1_.titleTxt = "Separation between chatter marks";
         _loc1_.toolTip = "Distance from center to center of consecutive chatter marks.";
         _loc1_.UnitLabel = "in";
         _loc1_.addEventListener("valueCommit",this.__MarkSep_valueCommit);
         _loc1_.id = "MarkSep";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MarkSep = _loc1_;
         BindingManager.executeBindings(this,"MarkSep",this.MarkSep);
         return _loc1_;
      }
      
      public function __MarkSep_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizChatterPitch_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Surface Speed";
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 1;
         _loc1_.toolTip = "Surface speed in feet per minute \ror meters per minute. Orange = custom tool data.";
         _loc1_.UnitLabel = "sfm";
         _loc1_.addEventListener("valueCommit",this.__SFM_valueCommit);
         _loc1_.id = "SFM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SFM = _loc1_;
         BindingManager.executeBindings(this,"SFM",this.SFM);
         return _loc1_;
      }
      
      public function __SFM_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizChatterPitch_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizChatterPitch_Label2_i(),this._GWizChatterPitch_Spacer1_c(),this._GWizChatterPitch_NumericStepper1_i()];
         _loc1_.id = "_GWizChatterPitch_HGroup1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChatterPitch_HGroup1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChatterPitch_HGroup1",this._GWizChatterPitch_HGroup1);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Cutter Flutes";
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "_GWizChatterPitch_Label2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChatterPitch_Label2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChatterPitch_Label2",this._GWizChatterPitch_Label2);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChatterPitch_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 1;
         _loc1_.maximum = 200;
         _loc1_.stepSize = 1;
         _loc1_.addEventListener("valueCommit",this.__Flutes_valueCommit);
         _loc1_.id = "Flutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Flutes = _loc1_;
         BindingManager.executeBindings(this,"Flutes",this.Flutes);
         return _loc1_;
      }
      
      public function __Flutes_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizChatterPitch_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Results";
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizChatterPitch_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizChatterPitch_Array4_c);
         _loc1_.id = "_GWizChatterPitch_GWizForePanel2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizChatterPitch_GWizForePanel2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizChatterPitch_GWizForePanel2",this._GWizChatterPitch_GWizForePanel2);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_VerticalLayout2_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizChatterPitch_Array4_c() : Array
      {
         return [this._GWizChatterPitch_Label3_c(),this._GWizChatterPitch_Spacer2_c(),this._GWizChatterPitch_Label4_i(),this._GWizChatterPitch_Label5_i(),this._GWizChatterPitch_Label6_i(),this._GWizChatterPitch_Label7_i(),this._GWizChatterPitch_Label8_i(),this._GWizChatterPitch_Label9_i(),this._GWizChatterPitch_Label10_i(),this._GWizChatterPitch_Label11_i(),this._GWizChatterPitch_Label12_i(),this._GWizChatterPitch_Label13_i(),this._GWizChatterPitch_Label14_i(),this._GWizChatterPitch_Label15_i()];
      }
      
      private function _GWizChatterPitch_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Chatter Minimizing Spindle Speeds:";
         _loc1_.styleName = "fontSizeDelta2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S1 = _loc1_;
         BindingManager.executeBindings(this,"S1",this.S1);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S2 = _loc1_;
         BindingManager.executeBindings(this,"S2",this.S2);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S3 = _loc1_;
         BindingManager.executeBindings(this,"S3",this.S3);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S4 = _loc1_;
         BindingManager.executeBindings(this,"S4",this.S4);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S5 = _loc1_;
         BindingManager.executeBindings(this,"S5",this.S5);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S6 = _loc1_;
         BindingManager.executeBindings(this,"S6",this.S6);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S7";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S7 = _loc1_;
         BindingManager.executeBindings(this,"S7",this.S7);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S8";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S8 = _loc1_;
         BindingManager.executeBindings(this,"S8",this.S8);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label12_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S9";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S9 = _loc1_;
         BindingManager.executeBindings(this,"S9",this.S9);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label13_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S10";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S10 = _loc1_;
         BindingManager.executeBindings(this,"S10",this.S10);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label14_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S11";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S11 = _loc1_;
         BindingManager.executeBindings(this,"S11",this.S11);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "S12";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.S12 = _loc1_;
         BindingManager.executeBindings(this,"S12",this.S12);
         return _loc1_;
      }
      
      private function _GWizChatterPitch_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            _GWizChatterPitch_Label1.setStyle("color",param1);
         },"_GWizChatterPitch_Label1.color");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },function(param1:uint):void
         {
            _GWizChatterPitch_Label1.setStyle("backgroundColor",param1);
         },"_GWizChatterPitch_Label1.backgroundColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizChatterPitch_GWizForePanel1.labelBackgroundColor");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizChatterPitch_GWizForePanel1.labelColor");
         result[4] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.FEET_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"SFM.impUnits");
         result[5] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.M_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"SFM.metUnits");
         result[6] = new Binding(this,function():Number
         {
            return MarkSep.theLabel.width;
         },null,"SFM.labelWidth");
         result[7] = new Binding(this,function():Number
         {
            return MarkSep.width;
         },null,"_GWizChatterPitch_HGroup1.width");
         result[8] = new Binding(this,function():Number
         {
            return MarkSep.theLabel.width;
         },null,"_GWizChatterPitch_Label2.width");
         result[9] = new Binding(this,function():Number
         {
            return MarkSep.stepper.width;
         },null,"Flutes.width");
         result[10] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizChatterPitch_GWizForePanel2.labelBackgroundColor");
         result[11] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizChatterPitch_GWizForePanel2.labelColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Flutes() : NumericStepper
      {
         return this._2107381107Flutes;
      }
      
      public function set Flutes(param1:NumericStepper) : void
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
      public function get MarkSep() : GWizNumStep
      {
         return this._1791080911MarkSep;
      }
      
      public function set MarkSep(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1791080911MarkSep;
         if(_loc2_ !== param1)
         {
            this._1791080911MarkSep = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MarkSep",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S1() : Label
      {
         return this._2622S1;
      }
      
      public function set S1(param1:Label) : void
      {
         var _loc2_:Object = this._2622S1;
         if(_loc2_ !== param1)
         {
            this._2622S1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S10() : Label
      {
         return this._81330S10;
      }
      
      public function set S10(param1:Label) : void
      {
         var _loc2_:Object = this._81330S10;
         if(_loc2_ !== param1)
         {
            this._81330S10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S11() : Label
      {
         return this._81331S11;
      }
      
      public function set S11(param1:Label) : void
      {
         var _loc2_:Object = this._81331S11;
         if(_loc2_ !== param1)
         {
            this._81331S11 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S11",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S12() : Label
      {
         return this._81332S12;
      }
      
      public function set S12(param1:Label) : void
      {
         var _loc2_:Object = this._81332S12;
         if(_loc2_ !== param1)
         {
            this._81332S12 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S12",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S2() : Label
      {
         return this._2623S2;
      }
      
      public function set S2(param1:Label) : void
      {
         var _loc2_:Object = this._2623S2;
         if(_loc2_ !== param1)
         {
            this._2623S2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S3() : Label
      {
         return this._2624S3;
      }
      
      public function set S3(param1:Label) : void
      {
         var _loc2_:Object = this._2624S3;
         if(_loc2_ !== param1)
         {
            this._2624S3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S4() : Label
      {
         return this._2625S4;
      }
      
      public function set S4(param1:Label) : void
      {
         var _loc2_:Object = this._2625S4;
         if(_loc2_ !== param1)
         {
            this._2625S4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S5() : Label
      {
         return this._2626S5;
      }
      
      public function set S5(param1:Label) : void
      {
         var _loc2_:Object = this._2626S5;
         if(_loc2_ !== param1)
         {
            this._2626S5 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S5",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S6() : Label
      {
         return this._2627S6;
      }
      
      public function set S6(param1:Label) : void
      {
         var _loc2_:Object = this._2627S6;
         if(_loc2_ !== param1)
         {
            this._2627S6 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S6",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S7() : Label
      {
         return this._2628S7;
      }
      
      public function set S7(param1:Label) : void
      {
         var _loc2_:Object = this._2628S7;
         if(_loc2_ !== param1)
         {
            this._2628S7 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S7",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S8() : Label
      {
         return this._2629S8;
      }
      
      public function set S8(param1:Label) : void
      {
         var _loc2_:Object = this._2629S8;
         if(_loc2_ !== param1)
         {
            this._2629S8 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S8",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get S9() : Label
      {
         return this._2630S9;
      }
      
      public function set S9(param1:Label) : void
      {
         var _loc2_:Object = this._2630S9;
         if(_loc2_ !== param1)
         {
            this._2630S9 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"S9",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SFM() : GWizNumStep
      {
         return this._82010SFM;
      }
      
      public function set SFM(param1:GWizNumStep) : void
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
   }
}
