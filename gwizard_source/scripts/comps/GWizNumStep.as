package comps
{
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.globalization.LocaleID;
   import flash.globalization.NumberFormatter;
   import flash.system.System;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.states.SetProperty;
   import mx.states.State;
   import skins.GWizStylePalette;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.TextInput;
   import spark.layouts.HorizontalLayout;
   import spark.layouts.VerticalLayout;
   import utils.GWizCallChain;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizNumStep extends Group implements IBindingClient, IStateClient2
   {
      
      private static const log:ILogger = Log.getLogger("GWizNumStep");
      
      public static var keystrokeRecalc:Boolean = false;
      
      public static var checkUnitsCC:GWizCallChain = new GWizCallChain();
      
      public static var checkUnitsCreations:int = 0;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _896192468spacer:Spacer;
      
      private var _1893554479stepper:GWizNumericStepperHomeEnd;
      
      private var _1129839150stepperGroup:HGroup;
      
      private var _2099674589suffixLabel:Label;
      
      private var _1078357251theLabel:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var CR:String = "\r";
      
      private var TAB:String = "\t";
      
      private var _1870010120titleTxt:String = "";
      
      private var _1799367701titleColor:uint;
      
      public var ignoreForePanelThemes:Boolean = false;
      
      private var _891422895suffix:String = "";
      
      private var _108114min:Number = 0.0;
      
      private var _1761818514horizontalLayout:Boolean = true;
      
      private var _107876max:Number = 500.0;
      
      private var _429619938metricOneLessDigit:Boolean = false;
      
      private var _65022449stepBySizes:Boolean = false;
      
      private var _846549374stepByPercent:Boolean = false;
      
      private var _UnitLabel:GWizUnitLabel;
      
      private var _694728319unitLabelTarget:Label;
      
      public var titleClickCopy:Boolean = false;
      
      private var _impUnits:String = "Inches";
      
      private var _metUnits:String = "MM";
      
      private var _2000894820usesMetric:Boolean = true;
      
      private var _68996955fatSpacer:Boolean = true;
      
      private var _835562194hideLabel:Boolean = false;
      
      private var _1337300570stepWidth:Number = 0;
      
      public var noUnits:Boolean = false;
      
      public var specKeys:String = "+*/x%=sStTrRcCiImM";
      
      private var HOME:Number = 36;
      
      private var END:Number = 35;
      
      private var keyConstants:Array;
      
      public var stepFormatter:NumberFormatter;
      
      private var ccDone:Boolean = false;
      
      private var _rawValue:Number = 0.0;
      
      private var oldUnits:String = "Inches";
      
      public var customImpInterval:Number = 0.0625;
      
      public var customMetInterval:Number = 0.1;
      
      private var queuedOperator:String = "";
      
      private var queuedOperand:Number = NaN;
      
      private var allowSpecKey:Boolean = true;
      
      private var oldValue:Number;
      
      private var roLabel:Label;
      
      public var wheelStep:Number;
      
      private var shiftKey:Boolean = false;
      
      private var altKey:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizNumStep()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1799367701titleColor = GWizStylePalette.textColor;
         this._UnitLabel = new GWizUnitLabel();
         this.keyConstants = [];
         this.stepFormatter = new NumberFormatter(LocaleID.DEFAULT);
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizNumStep_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizNumStepWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizNumStep[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._GWizNumStep_Label1_i(),this._GWizNumStep_Spacer1_i(),this._GWizNumStep_HGroup1_i()];
         this.currentState = "horizontal";
         this.addEventListener("updateComplete",this.___GWizNumStep_Group1_updateComplete);
         this.addEventListener("creationComplete",this.___GWizNumStep_Group1_creationComplete);
         this.addEventListener("initialize",this.___GWizNumStep_Group1_initialize);
         this.addEventListener("mouseWheel",this.___GWizNumStep_Group1_mouseWheel);
         this.addEventListener("keyDown",this.___GWizNumStep_Group1_keyDown);
         this.addEventListener("keyUp",this.___GWizNumStep_Group1_keyUp);
         states = [new State({
            "name":"horizontal",
            "overrides":[new SetProperty().initializeFromObject({
               "name":"layout",
               "value":this._GWizNumStep_HorizontalLayout1_c()
            })]
         }),new State({
            "name":"vertical",
            "overrides":[new SetProperty().initializeFromObject({
               "name":"layout",
               "value":this._GWizNumStep_VerticalLayout1_c()
            })]
         })];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizNumStep._watcherSetupUtil = param1;
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
      
      public function set redZone(param1:Boolean) : void
      {
         this.stepper.redZone = param1;
      }
      
      public function set redMax(param1:Number) : void
      {
         this.stepper.redMax = param1;
      }
      
      public function set UnitLabel(param1:String) : void
      {
         this._UnitLabel.UnitLabel = param1;
         if(param1.length > 0 && this.ccDone)
         {
            this.unitLabelTarget = this._UnitLabel.setupUnitLabel(this.stepperGroup);
         }
      }
      
      public function get UnitLabel() : String
      {
         return this._UnitLabel.UnitLabel;
      }
      
      private function useMetricFcn() : Boolean
      {
         return !this.noUnits && this.oldUnits == GWizUtils.MM_UNITS && this.usesMetric;
      }
      
      public function set steps(param1:Number) : void
      {
         this.stepper.snapInterval = param1;
         this.stepper.stepSize = param1;
         var _loc2_:String = String(param1);
         var _loc3_:int = _loc2_.indexOf(".");
         var _loc4_:int = _loc3_ == -1 ? 0 : int(_loc2_.length - (_loc3_ + 1));
         this.stepFormatter.fractionalDigits = _loc4_;
      }
      
      public function get steps() : Number
      {
         return this.stepper.stepSize;
      }
      
      public function set impUnits(param1:String) : void
      {
         this._impUnits = param1;
         if(!param1)
         {
            GWizUtils.assert(false);
         }
      }
      
      public function get impUnits() : String
      {
         return this._impUnits;
      }
      
      public function set metUnits(param1:String) : void
      {
         this._metUnits = param1;
         if(!param1)
         {
            GWizUtils.assert(false);
         }
      }
      
      public function get metUnits() : String
      {
         return this._metUnits;
      }
      
      public function addConstKey(param1:Number, param2:String) : Boolean
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc3_:int = -1;
         if(param2.length == 1)
         {
            (_loc4_ = new Object()).key = param2;
            _loc4_.constant = param1;
            if(this.specKeys.search(param2) != -1)
            {
               _loc5_ = 0;
               while(_loc5_ < this.keyConstants.length)
               {
                  if(this.keyConstants[_loc5_].key == param2)
                  {
                     _loc3_ = _loc5_;
                     break;
                  }
                  _loc5_++;
               }
            }
            else
            {
               this.specKeys += param2;
               _loc3_ = this.keyConstants.length;
            }
         }
         if(_loc3_ != -1)
         {
            this.keyConstants[_loc3_] = _loc4_;
         }
         return _loc3_ != -1;
      }
      
      private function set _1657211086labelWidth(param1:Number) : void
      {
         if(param1 > 0)
         {
            this.theLabel.width = param1;
            this.theLabel.setStyle("textAlign","right");
         }
      }
      
      public function get labelWidth() : Number
      {
         return this.theLabel.width;
      }
      
      public function set numStepWidth(param1:Number) : void
      {
         this.stepper.width = param1;
      }
      
      private function onInit() : void
      {
         this.stepFormatter.fractionalDigits = 4;
         this.stepFormatter.trailingZeros = false;
         this.stepFormatter.useGrouping = false;
      }
      
      private function onCreationComplete() : void
      {
         if(this.hideLabel)
         {
            this.removeElement(this.theLabel);
         }
         if(this.stepWidth > 0)
         {
            this.stepper.width = this.stepWidth;
         }
         if(!this.fatSpacer)
         {
            this.removeElement(this.spacer);
         }
         if(this.suffix == "")
         {
            this.stepperGroup.removeElement(this.suffixLabel);
         }
         if(!this.horizontalLayout)
         {
            currentState = "vertical";
         }
         this.invalidateSize();
         this.stepper.textDisplay.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,true,1000);
         checkUnitsCC.addFunction("GWizNumStep",this.checkUnits,false);
         this.checkUnits();
         this._UnitLabel.useMetric = this.useMetricFcn;
         this.ccDone = true;
         this.UnitLabel = this._UnitLabel.UnitLabel;
         var _loc1_:GWizJustASec = new GWizJustASec(this.stepper.checkRedZone);
      }
      
      private function sendUpTheEvent() : void
      {
         var _loc1_:FlexEvent = new FlexEvent(FlexEvent.VALUE_COMMIT);
         this.dispatchEvent(_loc1_);
      }
      
      private function set _111972721value(param1:Number) : void
      {
         this.setVal(param1);
      }
      
      public function get value() : Number
      {
         return this.getVal();
      }
      
      public function setVal(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = this.min;
         }
         if(!this.noUnits && this.oldUnits == GWizUtils.MM_UNITS && this.usesMetric)
         {
            if(this.metUnits == GWizUtils.MM_UNITS && this.impUnits == GWizUtils.INCHES_UNITS)
            {
               param1 *= 25.4;
            }
            else if(this.metUnits == GWizUtils.M_UNITS && this.impUnits == GWizUtils.FEET_UNITS)
            {
               param1 *= 0.3048;
            }
            else if(this.metUnits == GWizUtils.KW_UNITS && this.impUnits == GWizUtils.HP_UNITS)
            {
               param1 *= 0.745699872;
            }
            else if(this.metUnits == GWizUtils.KG_UNITS && this.impUnits == GWizUtils.LB_UNITS)
            {
               param1 /= 2.2;
            }
            else if(this.metUnits == GWizUtils.CC_UNITS && this.impUnits == GWizUtils.CI_UNITS)
            {
               param1 *= 16.387;
            }
            else if(this.metUnits == GWizUtils.NM_UNITS && this.impUnits == GWizUtils.OZIN_UNITS)
            {
               param1 *= 0.0070615518333333;
            }
            else if(this.metUnits == GWizUtils.MBAR_UNITS && this.impUnits == GWizUtils.INHG_UNITS)
            {
               param1 *= 0.02953;
            }
            else if(this.metUnits == GWizUtils.SQCM_UNITS && this.impUnits == GWizUtils.SQIN_UNITS)
            {
               param1 *= 6.4516;
            }
            else
            {
               log.debug("Unknown unit combo in GWizNumStepOver for " + this.titleTxt + ": met = " + this.metUnits + ", imp = " + this.impUnits);
               GWizUtils.assert(false);
            }
         }
         if(this.UnitLabel == "ips")
         {
            param1 /= 60;
         }
         this._rawValue = param1;
         if(this.stepper.value != param1 || keystrokeRecalc && this.stepper.textDisplay && Number(this.stepper.textDisplay.text) != param1)
         {
            this.stepper.value = param1;
            if(this.stepper.textDisplay && this.stepper.textDisplay.text && keystrokeRecalc)
            {
               this.stepper.textDisplay.text = String(param1);
            }
            this.stepper.checkRedZone();
         }
      }
      
      public function getVal() : Number
      {
         var _loc1_:Number = this.stepper.value;
         if(keystrokeRecalc && this.stepper && this.stepper.textDisplay && !isNaN(Number(this.stepper.textDisplay.text)))
         {
            _loc1_ = Number(this.stepper.textDisplay.text);
         }
         if(!this.noUnits && this.oldUnits == GWizUtils.MM_UNITS && this.usesMetric)
         {
            if(this.metUnits == GWizUtils.MM_UNITS && this.impUnits == GWizUtils.INCHES_UNITS)
            {
               _loc1_ /= 25.4;
            }
            else if(this.metUnits == GWizUtils.M_UNITS && this.impUnits == GWizUtils.FEET_UNITS)
            {
               _loc1_ /= 0.3048;
            }
            else if(this.metUnits == GWizUtils.KW_UNITS && this.impUnits == GWizUtils.HP_UNITS)
            {
               _loc1_ /= 0.745699872;
            }
            else if(this.metUnits == GWizUtils.KG_UNITS && this.impUnits == GWizUtils.LB_UNITS)
            {
               _loc1_ *= 2.2;
            }
            else if(this.metUnits == GWizUtils.CC_UNITS && this.impUnits == GWizUtils.CI_UNITS)
            {
               _loc1_ /= 16.387;
            }
            else if(this.metUnits == GWizUtils.NM_UNITS)
            {
               _loc1_ *= 141.61193227812538;
            }
            else if(this.metUnits == GWizUtils.MBAR_UNITS)
            {
               _loc1_ *= 0.02953;
            }
            else if(this.metUnits == GWizUtils.SQCM_UNITS)
            {
               _loc1_ /= 6.4516;
            }
            else
            {
               GWizUtils.assert(false);
            }
         }
         if(this.UnitLabel == "ips")
         {
            _loc1_ *= 60;
         }
         if(isNaN(_loc1_))
         {
            _loc1_ = this.min;
         }
         this.stepper.checkRedZone();
         return _loc1_;
      }
      
      public function getValNU() : Number
      {
         this.stepper.checkRedZone();
         return this.stepper.value;
      }
      
      public function getValCurrUnits() : Number
      {
         this.stepper.checkRedZone();
         return this.stepper.value;
      }
      
      private function convertUnits(param1:Number) : Number
      {
         if(!this.noUnits)
         {
            if(this.oldUnits == GWizUtils.INCHES_UNITS)
            {
               if(this.impUnits == GWizUtils.INCHES_UNITS || !this.impUnits)
               {
                  if(this.metUnits == GWizUtils.MM_UNITS || !this.metUnits)
                  {
                     param1 *= 25.4;
                  }
                  else
                  {
                     GWizUtils.assert(false);
                  }
               }
               else if(this.impUnits == GWizUtils.FEET_UNITS)
               {
                  if(this.metUnits == GWizUtils.M_UNITS)
                  {
                     param1 = param1 * 12 * 25.4 / 1000;
                  }
                  else
                  {
                     GWizUtils.assert(false);
                  }
               }
               else if(this.impUnits == GWizUtils.HP_UNITS)
               {
                  if(this.metUnits == GWizUtils.KW_UNITS)
                  {
                     param1 *= 0.745699872;
                  }
                  else
                  {
                     GWizUtils.assert(false);
                  }
               }
               else if(this.impUnits == GWizUtils.LB_UNITS)
               {
                  if(this.metUnits == GWizUtils.KG_UNITS)
                  {
                     param1 /= 2.2;
                  }
                  else
                  {
                     GWizUtils.assert(false);
                  }
               }
               else if(this.impUnits == GWizUtils.CI_UNITS)
               {
                  if(this.metUnits == GWizUtils.CC_UNITS)
                  {
                     param1 *= 16.387;
                  }
                  else
                  {
                     GWizUtils.assert(false);
                  }
               }
               else if(this.metUnits == GWizUtils.NM_UNITS)
               {
                  param1 /= 141.61193227812538;
               }
               else if(this.metUnits == GWizUtils.MBAR_UNITS)
               {
                  param1 *= 33.8639;
               }
               else if(this.metUnits == GWizUtils.SQCM_UNITS)
               {
                  param1 *= 6.4516;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
            else if(this.metUnits == GWizUtils.MM_UNITS)
            {
               if(this.impUnits == GWizUtils.INCHES_UNITS)
               {
                  param1 /= 25.4;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
            else if(this.metUnits == GWizUtils.M_UNITS)
            {
               if(this.impUnits == GWizUtils.FEET_UNITS)
               {
                  param1 = param1 * 1000 / 25.4 / 12;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
            else if(this.metUnits == GWizUtils.KW_UNITS)
            {
               if(this.impUnits == GWizUtils.HP_UNITS)
               {
                  param1 /= 0.745699872;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
            else if(this.metUnits == GWizUtils.KG_UNITS)
            {
               if(this.impUnits == GWizUtils.LB_UNITS)
               {
                  param1 *= 2.2;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
            else if(this.metUnits == GWizUtils.CC_UNITS)
            {
               if(this.impUnits == GWizUtils.CI_UNITS)
               {
                  param1 /= 16.387;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
            else if(this.metUnits == GWizUtils.NM_UNITS)
            {
               if(this.impUnits == GWizUtils.OZIN_UNITS)
               {
                  param1 /= 0.0070615518333333;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
            else if(this.metUnits == GWizUtils.MBAR_UNITS)
            {
               if(this.impUnits == GWizUtils.INHG_UNITS)
               {
                  param1 *= 0.02953;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
            else if(this.metUnits == GWizUtils.SQCM_UNITS)
            {
               if(this.impUnits == GWizUtils.SQIN_UNITS)
               {
                  param1 /= 6.4516;
               }
               else
               {
                  GWizUtils.assert(false);
               }
            }
            else
            {
               GWizUtils.assert(false);
            }
         }
         return param1;
      }
      
      private function checkUnits(param1:Object = null) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:Number = NaN;
         if(!this.noUnits && this)
         {
            if(GWizUtils.Units != this.oldUnits && this.usesMetric)
            {
               _loc2_ = !this.noUnits && this.oldUnits == GWizUtils.INCHES_UNITS && this.usesMetric;
               _loc3_ = this.stepper.value;
               if(this.metricOneLessDigit && _loc2_)
               {
                  _loc3_ = this._rawValue;
               }
               this.stepper.value = this.convertUnits(_loc3_);
               this.oldUnits = GWizUtils.Units;
               if(this.oldUnits == GWizUtils.INCHES_UNITS)
               {
                  this.stepper.stepSize = this.customImpInterval;
               }
               else
               {
                  this.stepper.stepSize = this.customMetInterval;
               }
               this._UnitLabel.setupUnitLabelText();
            }
            if(this.theLabel.text != this.titleTxt)
            {
               this.theLabel.text = this.titleTxt;
            }
         }
         if(this.unitLabelTarget)
         {
            this._UnitLabel.titleColor = this.titleColor;
         }
         if(!this.ignoreForePanelThemes)
         {
            this.titleColor = GWizStylePalette.textColor;
         }
         return true;
      }
      
      public function customArrowInterval(param1:Number = 0.0625, param2:Number = 0.1) : void
      {
         this.customImpInterval = param1;
         this.customMetInterval = param2;
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            this.stepper.stepSize = this.customImpInterval;
         }
         else
         {
            this.stepper.stepSize = this.customMetInterval;
         }
      }
      
      private function processOp(param1:Number) : void
      {
         switch(this.queuedOperator)
         {
            case "+":
               this.stepper.value = this.queuedOperand + param1;
               break;
            case "-":
               this.stepper.value = this.queuedOperand - param1;
               break;
            case "*":
            case "x":
               this.stepper.value = this.queuedOperand * param1;
               break;
            case "/":
               this.stepper.value = this.queuedOperand / param1;
         }
      }
      
      private function getTextInput() : TextInput
      {
         return this.stepper.textDisplay;
      }
      
      private function clearText() : void
      {
         var _loc2_:Object = null;
         var _loc1_:TextInput = this.getTextInput();
         if(_loc1_)
         {
            _loc2_ = _loc1_.getStyle("textDecoration");
            if(_loc2_)
            {
               _loc1_.text = "";
            }
         }
      }
      
      private function endCursor() : void
      {
         var _loc1_:TextInput = null;
         _loc1_ = this.getTextInput();
         if(_loc1_)
         {
            _loc1_.selectRange(_loc1_.text.length,_loc1_.text.length);
         }
         else
         {
            GWizUtils.assert(false);
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc2_:String = String.fromCharCode(param1.charCode);
         var _loc3_:TextInput = null;
         if(param1.charCode != 0)
         {
            if(param1.ctrlKey)
            {
               param1.preventDefault();
            }
            if(_loc2_.length > 0 && (this.specKeys.indexOf(_loc2_) != -1 || _loc2_ == this.CR) && !param1.ctrlKey)
            {
               _loc4_ = Number(this.stepper.textDisplay.text);
               if(this.allowSpecKey)
               {
                  param1.preventDefault();
                  switch(_loc2_)
                  {
                     case "+":
                     case "*":
                     case "/":
                     case "x":
                        if(this.queuedOperator.length != 0)
                        {
                           this.processOp(_loc4_);
                        }
                        this.queuedOperator = _loc2_;
                        this.queuedOperand = _loc4_;
                        this.clearText();
                        break;
                     case "%":
                        this.stepper.value = _loc4_ / 100;
                        break;
                     case "=":
                     case this.CR:
                        this.processOp(_loc4_);
                        this.queuedOperator = "";
                        break;
                     case "i":
                     case "I":
                        this.stepper.value = GWizUtils.inchToMM(_loc4_);
                        break;
                     case "m":
                     case "M":
                        this.stepper.value = GWizUtils.mmToInch(_loc4_);
                        break;
                     case "s":
                     case "S":
                        this.stepper.value = Math.sin(GWizUtils.radians(_loc4_));
                        break;
                     case "t":
                     case "T":
                        this.stepper.value = Math.tan(GWizUtils.radians(_loc4_));
                        break;
                     case "r":
                     case "R":
                        this.stepper.value = Math.sqrt(_loc4_);
                        break;
                     case "c":
                     case "C":
                        this.stepper.value = Math.cos(GWizUtils.radians(_loc4_));
                        break;
                     default:
                        _loc5_ = 0;
                        while(_loc5_ < this.keyConstants.length)
                        {
                           if(this.keyConstants[_loc5_].key == _loc2_)
                           {
                              this.stepper.value = this.keyConstants[_loc5_].constant;
                              break;
                           }
                           _loc5_++;
                        }
                  }
                  if(isNaN(this.stepper.value) && !isNaN(_loc4_))
                  {
                     this.stepper.value = _loc4_;
                  }
                  this.endCursor();
               }
            }
            else if(_loc2_ == this.TAB)
            {
               this.processOp(_loc4_);
               this.queuedOperator = "";
               this.endCursor();
            }
            else
            {
               this.allowSpecKey = true;
            }
         }
      }
      
      public function onValueCommit(param1:Boolean = false) : void
      {
         this.allowSpecKey = true;
         if(this.roLabel)
         {
            this.roLabel.text = String(this.stepper.value);
         }
         if(!isNaN(this.stepper.value) && (this.stepper.value != this.oldValue || param1))
         {
            this.oldValue = this.stepper.value;
            callLater(this.sendUpTheEvent);
         }
      }
      
      public function onChange(param1:Event) : void
      {
         this.dispatchEvent(param1);
      }
      
      public function readOnly() : void
      {
         this.stepper.visible = false;
         this.stepper.enabled = false;
         if(!this.roLabel)
         {
            this.roLabel = new Label();
            this.addElement(this.roLabel);
            this.roLabel.x = this.stepper.x;
            this.roLabel.y = this.stepper.y;
            this.roLabel.text = String(this.stepper.value);
            this.roLabel.visible = true;
         }
      }
      
      public function valIfEnabledNU() : Number
      {
         if(this.enabled)
         {
            return this.getValNU();
         }
         return NaN;
      }
      
      protected function mouseWheelHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = this.wheelStep;
         if(isNaN(_loc2_))
         {
            _loc2_ = this.stepper.stepSize;
         }
         if(this.shiftKey)
         {
            _loc2_ *= 10;
         }
         if(this.altKey)
         {
            _loc2_ *= 100;
         }
         this.stepper.value += param1.delta * _loc2_;
      }
      
      protected function onKeyDn(param1:KeyboardEvent) : void
      {
         this.shiftKey = param1.shiftKey;
         this.altKey = param1.altKey;
      }
      
      protected function onKeyUp(param1:KeyboardEvent) : void
      {
         this.shiftKey = param1.shiftKey;
         this.altKey = param1.altKey;
      }
      
      private function formatText(param1:Number) : String
      {
         return this.stepFormatter.formatNumber(param1);
      }
      
      private function titleClick() : void
      {
         if(this.titleClickCopy)
         {
            System.setClipboard(this.stepper.textDisplay.text);
         }
      }
      
      private function _GWizNumStep_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.addEventListener("click",this.__theLabel_click);
         _loc1_.id = "theLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theLabel = _loc1_;
         BindingManager.executeBindings(this,"theLabel",this.theLabel);
         return _loc1_;
      }
      
      public function __theLabel_click(param1:MouseEvent) : void
      {
         this.titleClick();
      }
      
      private function _GWizNumStep_Spacer1_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         _loc1_.height = 1;
         _loc1_.id = "spacer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.spacer = _loc1_;
         BindingManager.executeBindings(this,"spacer",this.spacer);
         return _loc1_;
      }
      
      private function _GWizNumStep_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizNumStep_GWizNumericStepperHomeEnd1_i(),this._GWizNumStep_Label2_i()];
         _loc1_.id = "stepperGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stepperGroup = _loc1_;
         BindingManager.executeBindings(this,"stepperGroup",this.stepperGroup);
         return _loc1_;
      }
      
      private function _GWizNumStep_GWizNumericStepperHomeEnd1_i() : GWizNumericStepperHomeEnd
      {
         var _loc1_:GWizNumericStepperHomeEnd = new GWizNumericStepperHomeEnd();
         _loc1_.width = 90;
         _loc1_.valueFormatFunction = this.formatText;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__stepper_valueCommit);
         _loc1_.addEventListener("change",this.__stepper_change);
         _loc1_.id = "stepper";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stepper = _loc1_;
         BindingManager.executeBindings(this,"stepper",this.stepper);
         return _loc1_;
      }
      
      public function __stepper_valueCommit(param1:FlexEvent) : void
      {
         this.onValueCommit();
      }
      
      public function __stepper_change(param1:Event) : void
      {
         this.onChange(param1);
      }
      
      private function _GWizNumStep_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "suffixLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.suffixLabel = _loc1_;
         BindingManager.executeBindings(this,"suffixLabel",this.suffixLabel);
         return _loc1_;
      }
      
      public function ___GWizNumStep_Group1_updateComplete(param1:FlexEvent) : void
      {
         this.checkUnits();
      }
      
      public function ___GWizNumStep_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCreationComplete();
      }
      
      public function ___GWizNumStep_Group1_initialize(param1:FlexEvent) : void
      {
         this.onInit();
      }
      
      public function ___GWizNumStep_Group1_mouseWheel(param1:MouseEvent) : void
      {
         this.mouseWheelHandler(param1);
      }
      
      public function ___GWizNumStep_Group1_keyDown(param1:KeyboardEvent) : void
      {
         this.onKeyDn(param1);
      }
      
      public function ___GWizNumStep_Group1_keyUp(param1:KeyboardEvent) : void
      {
         this.onKeyUp(param1);
      }
      
      private function _GWizNumStep_HorizontalLayout1_c() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = new HorizontalLayout();
         _loc1_.verticalAlign = "middle";
         return _loc1_;
      }
      
      private function _GWizNumStep_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.gap = 1;
         return _loc1_;
      }
      
      private function _GWizNumStep_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"theLabel.text","titleTxt");
         result[1] = new Binding(this,null,function(param1:uint):void
         {
            theLabel.setStyle("color",param1);
         },"theLabel.color","titleColor");
         result[2] = new Binding(this,null,null,"stepper.minimum","min");
         result[3] = new Binding(this,null,null,"stepper.maximum","max");
         result[4] = new Binding(this,function():Boolean
         {
            return this.stepBySizes;
         },null,"stepper.stepBySizes");
         result[5] = new Binding(this,function():Boolean
         {
            return this.stepByPercent;
         },null,"stepper.stepByPct");
         result[6] = new Binding(this,null,null,"suffixLabel.text","suffix");
         result[7] = new Binding(this,null,function(param1:uint):void
         {
            suffixLabel.setStyle("color",param1);
         },"suffixLabel.color","titleColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get spacer() : Spacer
      {
         return this._896192468spacer;
      }
      
      public function set spacer(param1:Spacer) : void
      {
         var _loc2_:Object = this._896192468spacer;
         if(_loc2_ !== param1)
         {
            this._896192468spacer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"spacer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepper() : GWizNumericStepperHomeEnd
      {
         return this._1893554479stepper;
      }
      
      public function set stepper(param1:GWizNumericStepperHomeEnd) : void
      {
         var _loc2_:Object = this._1893554479stepper;
         if(_loc2_ !== param1)
         {
            this._1893554479stepper = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepper",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepperGroup() : HGroup
      {
         return this._1129839150stepperGroup;
      }
      
      public function set stepperGroup(param1:HGroup) : void
      {
         var _loc2_:Object = this._1129839150stepperGroup;
         if(_loc2_ !== param1)
         {
            this._1129839150stepperGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepperGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get suffixLabel() : Label
      {
         return this._2099674589suffixLabel;
      }
      
      public function set suffixLabel(param1:Label) : void
      {
         var _loc2_:Object = this._2099674589suffixLabel;
         if(_loc2_ !== param1)
         {
            this._2099674589suffixLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"suffixLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theLabel() : Label
      {
         return this._1078357251theLabel;
      }
      
      public function set theLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1078357251theLabel;
         if(_loc2_ !== param1)
         {
            this._1078357251theLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get titleTxt() : String
      {
         return this._1870010120titleTxt;
      }
      
      public function set titleTxt(param1:String) : void
      {
         var _loc2_:Object = this._1870010120titleTxt;
         if(_loc2_ !== param1)
         {
            this._1870010120titleTxt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"titleTxt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get titleColor() : uint
      {
         return this._1799367701titleColor;
      }
      
      public function set titleColor(param1:uint) : void
      {
         var _loc2_:Object = this._1799367701titleColor;
         if(_loc2_ !== param1)
         {
            this._1799367701titleColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"titleColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get suffix() : String
      {
         return this._891422895suffix;
      }
      
      public function set suffix(param1:String) : void
      {
         var _loc2_:Object = this._891422895suffix;
         if(_loc2_ !== param1)
         {
            this._891422895suffix = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"suffix",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get min() : Number
      {
         return this._108114min;
      }
      
      public function set min(param1:Number) : void
      {
         var _loc2_:Object = this._108114min;
         if(_loc2_ !== param1)
         {
            this._108114min = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"min",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get horizontalLayout() : Boolean
      {
         return this._1761818514horizontalLayout;
      }
      
      public function set horizontalLayout(param1:Boolean) : void
      {
         var _loc2_:Object = this._1761818514horizontalLayout;
         if(_loc2_ !== param1)
         {
            this._1761818514horizontalLayout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"horizontalLayout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get max() : Number
      {
         return this._107876max;
      }
      
      public function set max(param1:Number) : void
      {
         var _loc2_:Object = this._107876max;
         if(_loc2_ !== param1)
         {
            this._107876max = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"max",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get metricOneLessDigit() : Boolean
      {
         return this._429619938metricOneLessDigit;
      }
      
      public function set metricOneLessDigit(param1:Boolean) : void
      {
         var _loc2_:Object = this._429619938metricOneLessDigit;
         if(_loc2_ !== param1)
         {
            this._429619938metricOneLessDigit = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"metricOneLessDigit",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepBySizes() : Boolean
      {
         return this._65022449stepBySizes;
      }
      
      public function set stepBySizes(param1:Boolean) : void
      {
         var _loc2_:Object = this._65022449stepBySizes;
         if(_loc2_ !== param1)
         {
            this._65022449stepBySizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepBySizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepByPercent() : Boolean
      {
         return this._846549374stepByPercent;
      }
      
      public function set stepByPercent(param1:Boolean) : void
      {
         var _loc2_:Object = this._846549374stepByPercent;
         if(_loc2_ !== param1)
         {
            this._846549374stepByPercent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepByPercent",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get unitLabelTarget() : Label
      {
         return this._694728319unitLabelTarget;
      }
      
      public function set unitLabelTarget(param1:Label) : void
      {
         var _loc2_:Object = this._694728319unitLabelTarget;
         if(_loc2_ !== param1)
         {
            this._694728319unitLabelTarget = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"unitLabelTarget",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get usesMetric() : Boolean
      {
         return this._2000894820usesMetric;
      }
      
      public function set usesMetric(param1:Boolean) : void
      {
         var _loc2_:Object = this._2000894820usesMetric;
         if(_loc2_ !== param1)
         {
            this._2000894820usesMetric = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"usesMetric",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fatSpacer() : Boolean
      {
         return this._68996955fatSpacer;
      }
      
      public function set fatSpacer(param1:Boolean) : void
      {
         var _loc2_:Object = this._68996955fatSpacer;
         if(_loc2_ !== param1)
         {
            this._68996955fatSpacer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fatSpacer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hideLabel() : Boolean
      {
         return this._835562194hideLabel;
      }
      
      public function set hideLabel(param1:Boolean) : void
      {
         var _loc2_:Object = this._835562194hideLabel;
         if(_loc2_ !== param1)
         {
            this._835562194hideLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hideLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepWidth() : Number
      {
         return this._1337300570stepWidth;
      }
      
      public function set stepWidth(param1:Number) : void
      {
         var _loc2_:Object = this._1337300570stepWidth;
         if(_loc2_ !== param1)
         {
            this._1337300570stepWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function set labelWidth(param1:Number) : void
      {
         var _loc2_:Object = this.labelWidth;
         if(_loc2_ !== param1)
         {
            this._1657211086labelWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function set value(param1:Number) : void
      {
         var _loc2_:Object = this.value;
         if(_loc2_ !== param1)
         {
            this._111972721value = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"value",_loc2_,param1));
            }
         }
      }
   }
}
