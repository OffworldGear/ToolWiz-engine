package comps
{
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import post.GWizNumParser;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.TextInput;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizNumParseStepper extends HGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizNumParseStepper");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _896192468spacer:Spacer;
      
      private var _1893554479stepper:NumericStepper;
      
      private var _1078357251theLabel:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var numParser:GWizNumParser = null;
      
      private var CR:String = "\r";
      
      private var TAB:String = "\t";
      
      private var _1870010120titleTxt:String = "";
      
      private var _108114min:Number = 0.0;
      
      private var _107876max:Number = 500.0;
      
      private var _109761319steps:Number = 1;
      
      private var _68996955fatSpacer:Boolean = true;
      
      public var specKeys:String = "+-*/x%=sStTrRcCiImM";
      
      private var HOME:Number = 36;
      
      private var END:Number = 35;
      
      private var _24672618allowHomeMin:Boolean = false;
      
      public var allowEndMax:Boolean = false;
      
      private var keyConstants:Array;
      
      private var oldUnits:String = "Inches";
      
      private var queuedOperator:String = "";
      
      private var queuedOperand:Number = NaN;
      
      private var allowSpecKey:Boolean = true;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizNumParseStepper()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.keyConstants = [];
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizNumParseStepper_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizNumParseStepperWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizNumParseStepper[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._GWizNumParseStepper_Label1_i(),this._GWizNumParseStepper_Spacer1_i(),this._GWizNumParseStepper_NumericStepper1_i()];
         this.addEventListener("creationComplete",this.___GWizNumParseStepper_HGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizNumParseStepper._watcherSetupUtil = param1;
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
      
      public function newParser(param1:GWizNumParser) : void
      {
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
      
      private function onCreationComplete() : void
      {
         if(!this.fatSpacer)
         {
            this.removeChild(this.spacer);
            this.invalidateSize();
         }
         this.stepper.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,true);
      }
      
      private function sendUpTheEvent() : void
      {
         var _loc1_:FlexEvent = new FlexEvent(FlexEvent.VALUE_COMMIT);
         this.dispatchEvent(_loc1_);
      }
      
      public function setVal(param1:Number) : void
      {
         this.stepper.value = param1;
      }
      
      public function getVal() : Number
      {
         return Number(this.stepper.value);
      }
      
      public function getValCurrUnits() : Number
      {
         return this.stepper.value;
      }
      
      private function convertUnits(param1:Number) : Number
      {
         return param1;
      }
      
      private function processOp() : void
      {
         switch(this.queuedOperator)
         {
            case "+":
               this.stepper.value = this.queuedOperand + this.stepper.value;
               break;
            case "-":
               this.stepper.value = this.queuedOperand - this.stepper.value;
               break;
            case "*":
            case "x":
               this.stepper.value = this.queuedOperand * this.stepper.value;
               break;
            case "/":
               this.stepper.value = this.queuedOperand / this.stepper.value;
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
         var _loc4_:int = 0;
         var _loc2_:String = String.fromCharCode(param1.charCode);
         var _loc3_:TextInput = null;
         log.debug("ch = " + _loc2_);
         log.debug("ch.length = " + _loc2_.length + ", code = " + param1.charCode);
         log.debug("ch.keyCode = " + param1.keyCode);
         log.debug("specKeys.search = " + this.specKeys.indexOf(_loc2_));
         log.debug("allow = " + this.allowSpecKey);
         if(param1.charCode != 0)
         {
            if(_loc2_.length > 0 && (this.specKeys.indexOf(_loc2_) != -1 || _loc2_ == this.CR || _loc2_ == this.TAB))
            {
               if(this.allowSpecKey)
               {
                  param1.preventDefault();
                  this.allowSpecKey = false;
                  switch(_loc2_)
                  {
                     case "+":
                     case "-":
                     case "*":
                     case "/":
                     case "x":
                        if(this.queuedOperator.length != 0)
                        {
                           this.processOp();
                        }
                        this.queuedOperator = _loc2_;
                        this.queuedOperand = this.stepper.value;
                        this.clearText();
                        break;
                     case "%":
                        this.stepper.value /= 100;
                        break;
                     case "=":
                     case this.TAB:
                     case this.CR:
                        this.processOp();
                        this.queuedOperator = "";
                        break;
                     case "i":
                     case "I":
                        if(this.oldUnits != GWizUtils.INCHES_UNITS)
                        {
                           this.stepper.value = GWizUtils.inchToMM(this.stepper.value);
                        }
                        break;
                     case "m":
                     case "M":
                        if(this.oldUnits == GWizUtils.INCHES_UNITS)
                        {
                           this.stepper.value = GWizUtils.mmToInch(this.stepper.value);
                        }
                        break;
                     case "s":
                     case "S":
                        this.stepper.value = Math.sin(GWizUtils.radians(this.stepper.value));
                        break;
                     case "t":
                     case "T":
                        this.stepper.value = Math.tan(GWizUtils.radians(this.stepper.value));
                        break;
                     case "r":
                     case "R":
                        this.stepper.value = Math.sqrt(this.stepper.value);
                        break;
                     case "c":
                     case "C":
                        this.stepper.value = Math.cos(GWizUtils.radians(this.stepper.value));
                        break;
                     default:
                        _loc4_ = 0;
                        while(_loc4_ < this.keyConstants.length)
                        {
                           if(this.keyConstants[_loc4_].key == _loc2_)
                           {
                              this.stepper.value = this.keyConstants[_loc4_].constant;
                              break;
                           }
                           _loc4_++;
                        }
                  }
                  this.endCursor();
               }
            }
            else
            {
               this.allowSpecKey = true;
            }
         }
         else if(param1.keyCode == this.HOME && !this.allowHomeMin)
         {
            _loc3_ = this.getTextInput();
            if(_loc3_)
            {
               param1.preventDefault();
               param1.stopPropagation();
               _loc3_.selectRange(0,0);
            }
         }
         else if(param1.keyCode == this.END && !this.allowEndMax)
         {
            param1.preventDefault();
            param1.stopPropagation();
            this.endCursor();
         }
      }
      
      private function onValueCommit() : void
      {
         if(this.titleTxt == "Surface Speed (SMM)")
         {
            log.debug("This is the one...");
         }
         callLater(this.sendUpTheEvent);
         this.allowSpecKey = true;
      }
      
      private function onChange(param1:Event) : void
      {
         this.dispatchEvent(param1);
      }
      
      private function _GWizNumParseStepper_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "theLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theLabel = _loc1_;
         BindingManager.executeBindings(this,"theLabel",this.theLabel);
         return _loc1_;
      }
      
      private function _GWizNumParseStepper_Spacer1_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         _loc1_.id = "spacer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.spacer = _loc1_;
         BindingManager.executeBindings(this,"spacer",this.spacer);
         return _loc1_;
      }
      
      private function _GWizNumParseStepper_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.width = 90;
         _loc1_.setStyle("color",65793);
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
      
      public function ___GWizNumParseStepper_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCreationComplete();
      }
      
      private function _GWizNumParseStepper_bindingsSetup() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new Binding(this,null,null,"theLabel.text","titleTxt");
         _loc1_[1] = new Binding(this,null,null,"stepper.minimum","min");
         _loc1_[2] = new Binding(this,null,null,"stepper.maximum","max");
         _loc1_[3] = new Binding(this,null,null,"stepper.stepSize","steps");
         return _loc1_;
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
      public function get stepper() : NumericStepper
      {
         return this._1893554479stepper;
      }
      
      public function set stepper(param1:NumericStepper) : void
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
      public function get steps() : Number
      {
         return this._109761319steps;
      }
      
      public function set steps(param1:Number) : void
      {
         var _loc2_:Object = this._109761319steps;
         if(_loc2_ !== param1)
         {
            this._109761319steps = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"steps",_loc2_,param1));
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
      public function get allowHomeMin() : Boolean
      {
         return this._24672618allowHomeMin;
      }
      
      public function set allowHomeMin(param1:Boolean) : void
      {
         var _loc2_:Object = this._24672618allowHomeMin;
         if(_loc2_ !== param1)
         {
            this._24672618allowHomeMin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"allowHomeMin",_loc2_,param1));
            }
         }
      }
   }
}
